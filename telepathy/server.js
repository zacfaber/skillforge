// Strudel Mirror — local server. Node stdlib only, no dependencies, no network calls out.
//   GET  /         -> index.html
//   GET  /state    -> state.json (fresh read every request)
//   GET  /live     -> live.json (the performer's audio analysis feed; {"live":false} until it exists)
//   GET  /events   -> Server-Sent Events: pushes state whenever state.json's mtime changes
//   POST /edit     -> appends one JSON line to edits.json (an edit REQUEST for the performer)
//   GET  /edits    -> edits.json as a JSON array (for debugging / the performer)
'use strict';
const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PORT = Number(process.env.PORT) || 8931;
const HOST = '127.0.0.1';
const DIR = __dirname;
const STATE = path.join(DIR, 'state.json');
const LIVEF = path.join(DIR, 'live.json');
const EDITS = path.join(DIR, 'edits.json');
const INDEX = path.join(DIR, 'index.html');

const clients = new Set();
let lastMtime = 0;
let lastBody = '';

function readState(cb, tries = 0) {
  fs.readFile(STATE, 'utf8', (err, txt) => {
    if (err) return cb(err);
    try { JSON.parse(txt); cb(null, txt); }
    catch (e) {
      // the performer may be mid-write; retry briefly
      if (tries < 6) setTimeout(() => readState(cb, tries + 1), 40);
      else cb(e);
    }
  });
}

function broadcast(txt) {
  const payload = 'event: state\ndata: ' + txt.replace(/\n/g, '') + '\n\n';
  for (const res of clients) { try { res.write(payload); } catch (_) {} }
}

let checkTimer = null;
function checkState() {
  clearTimeout(checkTimer);
  checkTimer = setTimeout(() => {
    fs.stat(STATE, (err, st) => {
      if (err || st.mtimeMs === lastMtime) return;
      lastMtime = st.mtimeMs;
      readState((e, txt) => {
        if (e || txt === lastBody) return;
        lastBody = txt;
        broadcast(JSON.stringify(JSON.parse(txt)));
      });
    });
  }, 15);
}

// Watch the directory (survives atomic rename-style writes), plus a slow stat poll as a safety net.
try {
  fs.watch(DIR, (evt, file) => { if (!file || file === 'state.json') checkState(); });
} catch (e) { console.error('fs.watch unavailable, polling only:', e.message); }
setInterval(checkState, 500);
fs.stat(STATE, (e, st) => { if (!e) lastMtime = st.mtimeMs; });
readState((e, txt) => { if (!e) lastBody = txt; });

// keep SSE connections alive through idle stretches
setInterval(() => { for (const res of clients) { try { res.write(': hb\n\n'); } catch (_) {} } }, 15000);

function send(res, code, type, body) {
  res.writeHead(code, { 'Content-Type': type, 'Cache-Control': 'no-store' });
  res.end(body);
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://localhost');

  if (req.method === 'GET' && (url.pathname === '/' || url.pathname === '/index.html')) {
    return fs.readFile(INDEX, (err, buf) =>
      err ? send(res, 500, 'text/plain', 'index.html missing') : send(res, 200, 'text/html; charset=utf-8', buf));
  }

  if (req.method === 'GET' && url.pathname === '/state') {
    return readState((err, txt) =>
      err ? send(res, 503, 'application/json', JSON.stringify({ error: 'state.json unreadable: ' + err.message }))
          : send(res, 200, 'application/json; charset=utf-8', txt));
  }

  if (req.method === 'GET' && url.pathname === '/events') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-store',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no',
    });
    res.write('retry: 1000\n\n');
    clients.add(res);
    readState((err, txt) => { if (!err) res.write('event: state\ndata: ' + JSON.stringify(JSON.parse(txt)) + '\n\n'); });
    req.on('close', () => clients.delete(res));
    return;
  }

  if (req.method === 'POST' && url.pathname === '/edit') {
    let body = '';
    req.on('data', (c) => { body += c; if (body.length > 65536) req.destroy(); });
    req.on('end', () => {
      let edit;
      try { edit = JSON.parse(body); } catch (e) { return send(res, 400, 'application/json', '{"error":"bad json"}'); }
      if (!edit || typeof edit !== 'object' || !edit.op || !edit.layer) {
        return send(res, 400, 'application/json', '{"error":"edit needs op and layer"}');
      }
      edit.id = String(edit.id || crypto.randomUUID());
      edit.receivedAt = Date.now();
      edit.status = 'requested';
      fs.appendFile(EDITS, JSON.stringify(edit) + '\n', (err) =>
        err ? send(res, 500, 'application/json', JSON.stringify({ error: err.message }))
            : send(res, 200, 'application/json', JSON.stringify({ ok: true, id: edit.id })));
    });
    return;
  }

  if (req.method === 'GET' && url.pathname === '/edits') {
    return fs.readFile(EDITS, 'utf8', (err, txt) => {
      const lines = err ? [] : txt.split('\n').filter(Boolean).map((l) => { try { return JSON.parse(l); } catch (_) { return null; } }).filter(Boolean);
      send(res, 200, 'application/json', JSON.stringify(lines));
    });
  }

  if (req.method === 'GET' && url.pathname === '/live') {
    return fs.readFile(LIVEF, 'utf8', (err, txt) => {
      if (err) return send(res, 200, 'application/json; charset=utf-8', JSON.stringify({ live: false }));
      try { JSON.parse(txt); send(res, 200, 'application/json; charset=utf-8', txt); }
      catch (_) { send(res, 200, 'application/json; charset=utf-8', JSON.stringify({ live: false })); }
    });
  }

  send(res, 404, 'text/plain', 'not found');
});

server.listen(PORT, HOST, () => console.log(`Strudel Mirror watching ${STATE}\n  -> http://localhost:${PORT}`));
