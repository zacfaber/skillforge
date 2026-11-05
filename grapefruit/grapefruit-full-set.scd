// GRAPEFRUIT - FULL SET PERFORMANCE - called by Zac Nov 4 2026
// One process, one server. Leg 1 build from bar 1, TEASE LIFT TENSION, SWAP to leg 2 core at 127, SETTLE, THIN, DUB OUT, final chord.
// Mix pass: every layer high pass carved to its slot, master bus 16 -> HPF 24 -> gentle comp -> presence shelf -> limiter -> out 0. Feed reads the mastered bus 0.
s = Server.default;
s.waitForBoot {
	Server.default.volume.volume = -6;
	s.recHeaderFormat = "wav";
	s.recSampleFormat = "int16";
	~mb = 16;
	~bpmNow = 125;
	~phase = "boot";
	~evts = Array.new;
	~staticTail = File("/Users/zacfaber/strudel-mirror/perf-static.txt", "r").readAllString;
	~feedData = [0, 0, 0, 0, 0, 0, 0, 0];
	SynthDef(\perfMaster, { |inBus = 16|
		var sig;
		sig = In.ar(inBus, 2);
		sig = HPF.ar(sig, 24);
		sig = Compander.ar(sig, sig, 0.45, 1.0, 0.55, 0.003, 0.12);
		sig = BHiShelf.ar(sig, 6500, 1.0, 1.2);
		sig = Limiter.ar(sig, 0.96, 0.01);
		Out.ar(0, sig);
	}).add;

	SynthDef(\hvKick, { |out = 16, amp = 0.9|
			var pitchEnv, ampEnv, body, click, sig;
			pitchEnv = EnvGen.kr(Env([150, 45], [0.07], \exp));
			ampEnv = EnvGen.kr(Env.perc(0.001, 0.21, 1, -4), doneAction: 2);
			body = SinOsc.ar(pitchEnv) * ampEnv;
			click = BPF.ar(WhiteNoise.ar, 2400, 0.7) * EnvGen.kr(Env.perc(0.001, 0.005, 1, -4)) * 0.12;
			sig = body + click;
			sig = LeakDC.ar((sig * 1.25).tanh * 0.8);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\hvBass, { |out = 16, freq = 49, amp = 0.4, sustain = 0.2|
			var osc, cutoff, sig, ampEnv;
			osc = (SinOsc.ar(freq) * 0.70) + (LFTri.ar(freq) * 0.15) + (Saw.ar(freq) * 0.20) + (LFPulse.ar(freq, 0, 0.5) * 0.10);
			cutoff = EnvGen.kr(Env([360, 240], [0.13], -4));
			sig = RLPF.ar(osc, cutoff, 0.75);
			ampEnv = EnvGen.kr(Env([0, 1, 0.7, 0.7, 0], [0.005, 0.07, sustain * 0.5, 0.06], -4), doneAction: 2);
			sig = (sig * 1.3).tanh * 0.77;
			sig = HPF.ar(sig, 27);
			Out.ar(out, (sig * ampEnv * amp).dup);
		}).add;
	SynthDef(\hvPad, { |out = 16, freq = 440, amp = 0.05, sustain = 8, cutoff = 1600|
			var partials, shimmer, sig, env;
			partials = (SinOsc.ar(freq) * 1.0) + (SinOsc.ar(freq * 2) * 0.22) + (SinOsc.ar(freq * 3) * 0.08) + (SinOsc.ar(freq * 4) * 0.04);
			shimmer = SinOsc.ar(freq * 2.003) * 0.07;
			env = EnvGen.kr(Env([0, 1, 0.55, 0.55, 0], [2.8, 2.0, sustain, 4.5], -3), doneAction: 2);
			sig = LPF.ar(partials + shimmer, cutoff);
			sig = HPF.ar(sig, 170);
			Out.ar(out, (sig * env * amp).dup);
		}).add;
	SynthDef(\hvClap, { |out = 16, amp = 0.6|
			var b1, b2, b3, bursts, sig, bodyEnv, freeEnv;
			b1 = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.011, 1, -4));
			b2 = DelayN.ar(WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.013, 0.85, -4)), 0.05, 0.011);
			b3 = DelayN.ar(WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.085, 0.6, -4)), 0.05, 0.023);
			bursts = b1 + b2 + b3;
			sig = HPF.ar(BPF.ar(bursts, 1700, 0.9), 520);
			bodyEnv = EnvGen.kr(Env.perc(0.002, 0.13, 1, -4));
			sig = sig * bodyEnv;
			sig = FreeVerb.ar(sig, 0.12, 0.3, 0.85);
			freeEnv = EnvGen.kr(Env.perc(0.002, 0.42, 1, -4), doneAction: 2);
			sig = HPF.ar(sig, 850);
			Out.ar(out, (sig * freeEnv * amp).dup);
		}).add;
	SynthDef(\hvHat, { |out = 16, amp = 0.3|
			var sig, env, cutoff, decay;
			cutoff = 3200 + (amp * 3000);
			decay = 0.055 + (amp * 0.17);
			env = EnvGen.kr(Env.perc(0.004, decay, 1, -3), doneAction: 2);
			sig = HPF.ar(WhiteNoise.ar, cutoff) * env;
			sig = HPF.ar(sig, 6800);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\hvOpenHat, { |out = 16, amp = 0.4|
			var sig, env;
			env = EnvGen.kr(Env.perc(0.002, 0.3, 1, -3), doneAction: 2);
			sig = HPF.ar(WhiteNoise.ar, 6000) * env;
			sig = HPF.ar(sig, 7000);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\hvShaker, { |out = 16, amp = 0.2|
			var sig, env;
			env = EnvGen.kr(Env.perc(0.001, 0.05, 1, -4), doneAction: 2);
			sig = HPF.ar(BPF.ar(WhiteNoise.ar, 6500, 0.8), 4000) * env;
			sig = HPF.ar(sig, 8200);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\hvChop, { |out = 16, freq = 392, amp = 0.16|
			var src, f1, f2, f3, sig, env;
			src = Saw.ar(freq);
			f1 = BPF.ar(src, 730, 0.6);
			f2 = BPF.ar(src, 1090, 0.7) * 0.6;
			f3 = BPF.ar(src, 2440, 0.8) * 0.35;
			sig = LPF.ar(f1 + f2 + f3, 3500);
			env = EnvGen.kr(Env.perc(0.01, 0.28, 1, -3), doneAction: 2);
			sig = HPF.ar(sig, 350);
			Out.ar(out, (sig * env * amp).dup);
		}).add;
	SynthDef(\g2Kick, { |out = 16, amp = 0.9|
			var pitchEnv, ampEnv, body, click, sig;
			pitchEnv = EnvGen.kr(Env([150, 45], [0.07], \exp));
			ampEnv = EnvGen.kr(Env.perc(0.001, 0.21, 1, -4), doneAction: 2);
			body = SinOsc.ar(pitchEnv) * ampEnv;
			click = BPF.ar(WhiteNoise.ar, 2400, 0.7) * EnvGen.kr(Env.perc(0.001, 0.005, 1, -4)) * 0.12;
			sig = body + click;
			sig = LeakDC.ar((sig * 1.25).tanh * 0.8);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\g2Bass, { |out = 16, freq = 49, amp = 0.4, sustain = 0.2|
			var osc, cutoff, sig, ampEnv;
			osc = (SinOsc.ar(freq) * 0.70) + (LFTri.ar(freq) * 0.15) + (Saw.ar(freq) * 0.20) + (LFPulse.ar(freq, 0, 0.5) * 0.10);
			cutoff = EnvGen.kr(Env([360, 240], [0.13], -4));
			sig = RLPF.ar(osc, cutoff, 0.75);
			ampEnv = EnvGen.kr(Env([0, 1, 0.7, 0.7, 0], [0.005, 0.07, sustain * 0.5, 0.06], -4), doneAction: 2);
			sig = (sig * 1.3).tanh * 0.77;
			sig = HPF.ar(sig, 27);
			Out.ar(out, (sig * ampEnv * amp).dup);
		}).add;
	SynthDef(\g2Pad, { |out = 16, freq = 440, amp = 0.05, sustain = 8, cutoff = 1600|
			var partials, shimmer, sig, env;
			partials = (SinOsc.ar(freq) * 1.0) + (SinOsc.ar(freq * 2) * 0.22) + (SinOsc.ar(freq * 3) * 0.08) + (SinOsc.ar(freq * 4) * 0.04);
			shimmer = SinOsc.ar(freq * 2.003) * 0.07;
			env = EnvGen.kr(Env([0, 1, 0.55, 0.55, 0], [2.8, 2.0, sustain, 4.5], -3), doneAction: 2);
			sig = LPF.ar(partials + shimmer, cutoff);
			sig = HPF.ar(sig, 170);
			Out.ar(out, (sig * env * amp).dup);
		}).add;
	SynthDef(\g2Clap, { |out = 16, amp = 0.6|
			var b1, b2, b3, bursts, sig, bodyEnv, freeEnv;
			b1 = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.011, 1, -4));
			b2 = DelayN.ar(WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.013, 0.85, -4)), 0.05, 0.011);
			b3 = DelayN.ar(WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.085, 0.6, -4)), 0.05, 0.023);
			bursts = b1 + b2 + b3;
			sig = HPF.ar(BPF.ar(bursts, 1700, 0.9), 520);
			bodyEnv = EnvGen.kr(Env.perc(0.002, 0.13, 1, -4));
			sig = sig * bodyEnv;
			sig = FreeVerb.ar(sig, 0.12, 0.3, 0.85);
			freeEnv = EnvGen.kr(Env.perc(0.002, 0.42, 1, -4), doneAction: 2);
			sig = HPF.ar(sig, 850);
			Out.ar(out, (sig * freeEnv * amp).dup);
		}).add;
	SynthDef(\g2Hat, { |out = 16, amp = 0.3|
			var sig, env, cutoff, decay;
			cutoff = 3200 + (amp * 3000);
			decay = 0.055 + (amp * 0.17);
			env = EnvGen.kr(Env.perc(0.004, decay, 1, -3), doneAction: 2);
			sig = HPF.ar(WhiteNoise.ar, cutoff) * env;
			sig = HPF.ar(sig, 6800);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\g2OpenHat, { |out = 16, amp = 0.4|
			var sig, env;
			env = EnvGen.kr(Env.perc(0.002, 0.3, 1, -3), doneAction: 2);
			sig = HPF.ar(WhiteNoise.ar, 6000) * env;
			sig = HPF.ar(sig, 7000);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\g2Shaker, { |out = 16, amp = 0.2|
			var sig, env;
			env = EnvGen.kr(Env.perc(0.001, 0.05, 1, -4), doneAction: 2);
			sig = HPF.ar(BPF.ar(WhiteNoise.ar, 6500, 0.8), 4000) * env;
			sig = HPF.ar(sig, 8200);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\g2Chop, { |out = 16, freq = 392, amp = 0.16|
			var src, f1, f2, f3, sig, env;
			src = Saw.ar(freq);
			f1 = BPF.ar(src, 730, 0.6);
			f2 = BPF.ar(src, 1090, 0.7) * 0.6;
			f3 = BPF.ar(src, 2440, 0.8) * 0.35;
			sig = LPF.ar(f1 + f2 + f3, 3500);
			env = EnvGen.kr(Env.perc(0.01, 0.28, 1, -3), doneAction: 2);
			sig = HPF.ar(sig, 350);
			Out.ar(out, (sig * env * amp).dup);
		}).add;
	SynthDef(\g2Tamb, { |out = 16, amp = 0.15|
			var sig, env;
			env = EnvGen.kr(Env.perc(0.001, 0.032, 1, -4), doneAction: 2);
			sig = HPF.ar(BPF.ar(WhiteNoise.ar, 8200, 0.7), 5000) * env;
			sig = HPF.ar(sig, 8200);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\g2Ride, { |out = 16, amp = 0.16|
			var partials, env, sig;
			partials = (SinOsc.ar(6230) * 0.4) + (SinOsc.ar(8450) * 0.3) + (SinOsc.ar(11730) * 0.22) + (SinOsc.ar(5320) * 0.26);
			env = EnvGen.kr(Env.perc(0.001, 0.19, 1, -3), doneAction: 2);
			sig = (partials + (HPF.ar(WhiteNoise.ar, 9000) * 0.12)) * env;
			sig = HPF.ar(sig, 5000);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\g2Stab, { |out = 16, freq = 440, amp = 0.12|
			var osc, env, sig;
			osc = (SinOsc.ar(freq) * 0.8) + (SinOsc.ar(freq * 2) * 0.35) + (LFTri.ar(freq * 3) * 0.10) + (SinOsc.ar(freq * 0.5) * 0.3);
			env = EnvGen.kr(Env.perc(0.004, 0.34, 1, -3), doneAction: 2);
			sig = LPF.ar(osc, 2300) * env;
			sig = HPF.ar(sig, 190);
			Out.ar(out, (sig * amp).dup);
		}).add;
	SynthDef(\g2Vox, { |out = 16, freq = 392, amp = 0.1|
			var src, f1, f2, f3, sig, env;
			src = Saw.ar(freq);
			f1 = BPF.ar(src, 730, 0.6);
			f2 = BPF.ar(src, 1090, 0.7) * 0.6;
			f3 = BPF.ar(src, 2440, 0.8) * 0.35;
			sig = LPF.ar(f1 + f2 + f3, 3200);
			env = EnvGen.kr(Env([0, 1, 0.65, 0], [2.2, 3.0, 3.4], -3), doneAction: 2);
			sig = HPF.ar(sig, 280);
			Out.ar(out, (sig * env * amp).dup);
		}).add;
	SynthDef(\perfFeed, {
			var sig, mono, trig, rms, peak, bands, gains;
			sig = In.ar(0, 2);
			mono = (sig[0] + sig[1]) * 0.5;
			trig = Impulse.kr(10);
			rms = Amplitude.kr(mono, 0.01, 0.1);
			peak = Peak.kr(mono, trig);
			gains = [2.0, 1.4, 1.0, 0.9, 1.0, 1.2];
			bands = [60, 160, 400, 1000, 2500, 6000].collect { |f, i|
				Amplitude.kr(BPF.ar(mono, f, 0.8), 0.01, 0.15) * gains[i];
			};
			SendReply.kr(trig, '/mirrorfeed', [rms, peak] ++ bands);
		}).add;
	Pdef(\hvKickP, Pbind(\instrument, \hvKick, \dur, 1, \amp, 0.78));
	Pdef(\hvBassP, Pbind(
			\instrument, \hvBass,
			\dur, 0.25,
			\midinote, Pseq([\rest, \rest, 31, \rest, \rest, \rest, 31, \rest, \rest, 38, \rest, 34, \rest, \rest, 31, \rest, \rest, \rest, 31, \rest, \rest, 34, \rest, 38, \rest, \rest, 31, \rest, \rest, 29, 31, \rest], inf),
			\amp, Pseq([0, 0, 0.645, 0, 0, 0, 0.465, 0, 0, 0.5475, 0, 0.4125, 0, 0, 0.615, 0, 0, 0, 0.6225, 0, 0, 0.36, 0, 0.465, 0, 0, 0.5775, 0, 0, 0.285, 0.6525, 0], inf),
			\sustain, Pseq([0.1, 0.1, 0.2122, 0.1, 0.1, 0.1, 0.2122, 0.1, 0.1, 0.1061, 0.1, 0.2122, 0.1, 0.1, 0.2122, 0.1, 0.1, 0.1, 0.2122, 0.1, 0.1, 0.1061, 0.1, 0.1061, 0.1, 0.1, 0.2122, 0.1, 0.1, 0.1061, 0.2122, 0.1], inf)
		));
	Pdef(\hvPadP, Pbind(
			\instrument, \hvPad,
			\dur, 32,
			\midinote, Pseq([[55, 58, 62, 65, 69], [55, 58, 62, 65], [55, 58, 62, 65, 69], [51, 55, 58, 62, 65]], inf),
			\amp, 0.05,
			\sustain, 8,
			\cutoff, Pseq([1600, 1300, 1800, 1400], inf)
		));
	Pdef(\hvClapP, Pbind(
			\instrument, \hvClap,
			\dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, 60, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 60, \rest, \rest, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0.558, 0, 0, 0, 0, 0, 0, 0, 0.621, 0, 0, 0], inf)
		));
	Pdef(\hvHatP, Pbind(
			\instrument, \hvHat,
			\dur, 0.25,
			\midinote, Pseq([\rest, \rest, 60, \rest, \rest, \rest, 60, \rest, \rest, \rest, 60, \rest, \rest, \rest, 60, \rest], inf),
			\amp, Pseq([0, 0, 0.22, 0, 0, 0, 0.31, 0, 0, 0, 0.25, 0, 0, 0, 0.34, 0], inf)
		));
	Pdef(\hvOpenHatP, Pbind(
			\instrument, \hvOpenHat,
			\dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, 60, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 60, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 0, 0, 0, 0.4, 0], inf)
		));
	Pdef(\hvShakerP, Pbind(
			\instrument, \hvShaker,
			\dur, 0.25,
			\midinote, 60,
			\amp, Pseq([0.20, 0.13, 0.16, 0.14, 0.23, 0.12, 0.17, 0.13, 0.22, 0.13, 0.17, 0.14, 0.22, 0.13, 0.18, 0.14], inf)
		));
	Pdef(\hvChopP, Pbind(
			\instrument, \hvChop,
			\dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 67, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 70, \rest, \rest, \rest, 65, \rest, \rest, \rest, \rest, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.14, 0, 0, 0, 0.15, 0, 0, 0, 0, 0], inf)
		));
	Pdef(\g2KickP, Pbind(\instrument, \g2Kick, \dur, 1, \amp, 0.86));
	Pdef(\g2BassMainP, Pbind(\instrument, \g2Bass, \dur, 0.25,
			\midinote, Pseq([\rest, \rest, 31, \rest, 43, \rest, 31, \rest, \rest, 38, \rest, 34, 43, \rest, 31, \rest, \rest, \rest, 31, \rest, \rest, 34, \rest, 38, \rest, \rest, 31, 36, \rest, 29, 31, \rest], inf),
			\amp, Pseq([0, 0, 0.645, 0, 0.35, 0, 0.465, 0, 0, 0.5475, 0, 0.4125, 0.35, 0, 0.615, 0, 0, 0, 0.6225, 0, 0, 0.36, 0, 0.465, 0, 0, 0.5775, 0.30, 0, 0.285, 0.6525, 0], inf),
			\sustain, Pseq([0.1, 0.1, 0.2122, 0.1, 0.1, 0.1, 0.2122, 0.1, 0.1, 0.1061, 0.1, 0.2122, 0.1, 0.1, 0.2122, 0.1, 0.1, 0.1, 0.2122, 0.1, 0.1, 0.1061, 0.1, 0.1061, 0.1, 0.1, 0.2122, 0.1061, 0.1, 0.1061, 0.2122, 0.1], inf)));
	Pdef(\g2PadMainP, Pbind(\instrument, \g2Pad, \dur, 32,
			\midinote, Pseq([[55, 58, 62, 65, 69], [55, 58, 62, 65, 69], [52, 58, 62, 69], [51, 55, 58, 62, 65]], inf),
			\amp, 0.05, \sustain, 8, \cutoff, Pseq([1600, 1500, 1700, 1400], inf)));
	Pdef(\g2ClapP, Pbind(\instrument, \g2Clap, \dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, 60, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 60, \rest, \rest, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0.558, 0, 0, 0, 0, 0, 0, 0, 0.621, 0, 0, 0], inf)));
	Pdef(\g2HatMainP, Pbind(\instrument, \g2Hat, \dur, 0.25, \midinote, 60,
			\amp, Pseq([0.10, 0, 0.22, 0, 0, 0, 0.31, 0, 0.12, 0, 0.25, 0, 0, 0, 0.34, 0], inf)));
	Pdef(\g2OpenHatP, Pbind(\instrument, \g2OpenHat, \dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, 60, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 60, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 0, 0, 0, 0.4, 0], inf)));
	Pdef(\g2ShakerP, Pbind(\instrument, \g2Shaker, \dur, 0.25, \midinote, 60,
			\amp, Pseq([0.20, 0.13, 0.16, 0.14, 0.23, 0.12, 0.17, 0.13, 0.22, 0.13, 0.17, 0.14, 0.22, 0.13, 0.18, 0.14], inf)));
	Pdef(\g2ChopP, Pbind(\instrument, \g2Chop, \dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 67, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 70, \rest, \rest, \rest, 65, \rest, \rest, \rest, \rest, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.14, 0, 0, 0, 0.15, 0, 0, 0, 0, 0], inf)));
	Pdef(\g2TambP, Pbind(\instrument, \g2Tamb, \dur, 0.25, \amp, Pseq([0.16, 0.08, 0.11, 0.09, 0.19, 0.08, 0.12, 0.09, 0.17, 0.08, 0.11, 0.09, 0.20, 0.08, 0.12, 0.10], inf)));
	Pdef(\g2RideP, Pbind(\instrument, \g2Ride, \dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, 60, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 60, \rest, \rest, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0.18, 0, 0, 0, 0, 0, 0, 0, 0.15, 0, 0, 0], inf)));
	Pdef(\g2StabP, Pbind(\instrument, \g2Stab, \dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, [55, 58, 62, 65, 69], \rest, \rest, \rest, \rest, \rest, \rest, [55, 58, 62, 65, 69], \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, [52, 58, 62, 69], \rest, \rest, \rest, \rest, \rest, \rest, [52, 58, 62, 69], \rest, \rest, \rest, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0.13, 0, 0, 0, 0, 0, 0, 0.13, 0, 0, 0, 0, 0, 0, 0, 0.13, 0, 0, 0, 0, 0, 0, 0.13, 0, 0, 0, 0], inf)));
	Pdef(\g2VoxP, Pbind(\instrument, \g2Vox, \dur, 32, \midinote, Pseq([67, 74], inf), \amp, 0.10));
	Pdef(\g2PopsP, Pbind(\instrument, \g2Bass, \dur, 0.25,
			\midinote, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 43, \rest, \rest, \rest, \rest, \rest, \rest, \rest, 43, \rest, \rest, \rest], inf),
			\amp, Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.32, 0, 0, 0, 0, 0, 0, 0, 0.32, 0, 0, 0], inf),
			\sustain, 0.12));
	[\hvKickP, \hvBassP, \hvPadP, \hvClapP, \hvHatP, \hvOpenHatP, \hvShakerP, \hvChopP, \g2KickP, \g2BassMainP, \g2PadMainP, \g2ClapP, \g2HatMainP, \g2OpenHatP, \g2ShakerP, \g2ChopP, \g2TambP, \g2RideP, \g2StabP, \g2VoxP, \g2PopsP].do { |n| Pdef(n).quant = 4; };
	s.sync;
	~master = Synth(\perfMaster, [\inBus, ~mb], s, \addToTail);
	Synth(\perfFeed);
	OSCFunc({ |msg| ~feedData = msg[3..10]; }, '/mirrorfeed');
	{ 2.wait; Synth(\perfFeed); "PERF_FEED_STARTED".postln; }.fork;
	~stamp = { (Date.getDate.rawSeconds * 1000).round.asString; };
	~evt = { |text, kind| ~evts = ~evts.add("{\"t\": " ++ ~stamp.() ++ ", \"text\": \"" ++ text ++ "\", \"kind\": \"" ++ kind ++ "\"}"); };
	~writeState = {
		var body, f;
		body = "{\"set\": \"GRAPEFRUIT FULL SET\", \"mode\": \"PERFORMANCE\", \"phase\": \"" ++ ~phase ++ "\", \"bpm\": " ++ ~bpmNow ++ ", \"key\": \"G minor\", \"anchorBeat\": " ++ ~clock.beats.round(0.001) ++ ", \"anchorTime\": " ++ ~stamp.() ++ ", \"events\": [" ++ ~evts.join(", ") ++ "]" ++ ~staticTail;
		f = File("/Users/zacfaber/strudel-mirror/state.json.tmp", "w");
		f.write(body);
		f.close;
		unixCmd("mv /Users/zacfaber/strudel-mirror/state.json.tmp /Users/zacfaber/strudel-mirror/state.json");
	};
	~say = { |text, kind| ~evt.(text, kind); ~writeState.(); text.postln; };
	{
		loop {
			var d, bands, f2, body2;
			d = ~feedData;
			bands = "[" ++ d[2].round(4) ++ ", " ++ d[3].round(4) ++ ", " ++ d[4].round(4) ++ ", " ++ d[5].round(4) ++ ", " ++ d[6].round(4) ++ ", " ++ d[7].round(4) ++ "]";
			body2 = "{\"t\": " ++ ~stamp.() ++ ", \"rms\": " ++ d[0].round(4) ++ ", \"peak\": " ++ d[1].round(4) ++ ", \"bands\": " ++ bands ++ "}";
			f2 = File("/Users/zacfaber/strudel-mirror/live.json.tmp", "w");
			f2.write(body2);
			f2.close;
			unixCmd("mv /Users/zacfaber/strudel-mirror/live.json.tmp /Users/zacfaber/strudel-mirror/live.json");
			0.1.wait;
		};
	}.fork(SystemClock);
	"PERF_BOOTED defs master feed live".postln;
	~on = { |n| Pdef(n).play(~clock); };
	~off = { |n| Pdef(n).stop; };
	{
		var nowMs, curBeat, nextB, waitSecs;
		nowMs = Date.getDate.rawSeconds * 1000;
		curBeat = 3520.0 + ((nowMs - 1793832446199.6) * 0.001 * (127.0/60));
		nextB = (curBeat / 4).ceil * 4;
		if ((nextB - curBeat) < 1) { nextB = nextB + 4; };
		waitSecs = (nextB - curBeat) / (127.0/60);
		("PERF_HANDOFF at leg2 beat " ++ nextB ++ " in " ++ waitSecs.round(0.01) ++ " s").postln;
		waitSecs.wait;
		unixCmd("kill -9 35256 35298");
		~clock = TempoClock.new(125/60);
		s.record("/Users/zacfaber/beats/grapefruit/grapefruit-full-set.wav");
		"PERF_RECORDING".postln;
		{
			~phase = "LEG 1 BUILD";
			~on.(\hvKickP); ~on.(\hvBassP);
			~say.("SET START: Grapefruit from the top. Gate A, kick and bass, 125 BPM", "phase");
			32.wait; ~on.(\hvPadP); ~say.("pad in: the ethereal layer", "note");
			32.wait; ~on.(\hvClapP); ~say.("clap in", "note");
			32.wait; ~on.(\hvHatP); ~say.("closed hats in", "note");
			32.wait; ~on.(\hvOpenHatP); ~on.(\hvShakerP); ~say.("open hat and shaker in", "note");
			32.wait; ~on.(\hvChopP); ~say.("vocal chop in: leg 1 complete, 8 layers", "phase");
			64.wait;
			~phase = "TRANSITION";
			~on.(\g2TambP); ~say.("TEASE: tambourine in over leg 1", "phase");
			32.wait; ~on.(\g2RideP); ~say.("ride ping in", "note");
			32.wait; ~on.(\g2StabP); ~on.(\g2PopsP); ~say.("LIFT: chord stabs in, bass octave pops", "phase");
			32.wait; ~on.(\g2VoxP); ~say.("TENSION: vocal long tones in", "phase");
			16.wait; ~off.(\hvClapP); ~say.("subtraction: clap out", "note");
			16.wait; ~off.(\hvHatP); ~say.("hats thin before the swap", "note");
			32.wait;
			~phase = "LEG 2 SETTLE";
			~off.(\hvKickP); ~off.(\hvBassP); ~off.(\hvPadP); ~off.(\g2PopsP);
			~clock.tempo = 127/60; ~bpmNow = 127;
			~on.(\g2KickP); ~on.(\g2BassMainP); ~on.(\g2PadMainP); ~on.(\g2ClapP); ~on.(\g2HatMainP);
			~say.("SWAP: leg 2 core in, tempo 125 to 127, full stack", "phase");
			128.wait;
			~off.(\g2KickP); ~say.("THIN: kick out, tension by subtraction", "phase");
			16.wait; ~on.(\g2KickP); ~say.("kick back in", "note");
			176.wait;
			~phase = "DUB OUT";
			~off.(\g2VoxP); ~off.(\g2ChopP); ~say.("DUB OUT: vocals and chop strip first", "phase");
			32.wait; ~off.(\g2StabP); ~say.("stabs out", "note");
			32.wait; ~off.(\g2RideP); ~off.(\g2TambP); ~say.("ride and tambourine out", "note");
			32.wait; ~off.(\g2PadMainP); ~say.("pad out", "note");
			32.wait; ~off.(\g2HatMainP); ~off.(\g2OpenHatP); ~off.(\g2ShakerP); ~say.("hats and shaker out", "note");
			32.wait; ~off.(\g2ClapP); ~off.(\g2BassMainP); ~say.("clap and bass out: kick alone", "note");
			32.wait; ~off.(\g2KickP);
			[55, 58, 62, 65, 69].do { |n| Synth(\g2Pad, [\freq, n.midicps, \amp, 0.045]); };
			~phase = "END";
			~say.("final chord: Gm9, the set resolves", "phase");
			16.wait;
			s.stopRecording;
			~say.("SET COMPLETE: Grapefruit, full performance, recorded", "phase");
			"PERF_DONE".postln;
			loop { 60.wait; "PERF_IDLE feed live".postln; };
		}.fork(~clock);
	}.fork(SystemClock);
};
"PERF_FILE_LOADED".postln;
