# GRAPEFRUIT - Set Notes
Saved Nov 4, 2026, on Zac's word: "save whatever song we just made as grapefruit"

## What it is
The Hidde van Wee level set built live in this session, 125 BPM, G minor, 8 layers.
Zac's verdicts, verbatim: Gate A "i like it", pad version "this is hard", full stack "love this" (LOCKED).
The bridge/build/drop experiment on top of it got "not the best" and was reverted. The loved plain groove is the song. That is now two scripted drops in a row Zac's ear has rejected (Nov 3 DEEP CURRENT drop: "awful"). Drops are parked unless he calls one by name.

## Files (on the Mac, ~/beats/grapefruit/)
- grapefruit.scd - the full set as one reloadable file (identical to hidde-full-LOCKED-loved.scd)
- grapefruit.wav - 54.21 sec proof of the full build, gates entering in succession, peak 0.500, RMS 0.091, no clipping
- GRAPEFRUIT-NOTES.md - this file

## Layer map (entry order in the build)
1. Kick - hvKick, four on the floor, sine drop 150 to 45 Hz in 70 ms, decay 210 ms, amp 0.78
2. Bass - hvBass, 2 bar G minor motif: G1 steps 2/6/14, D2 step 9, Bb1 step 11, then G1, Bb1, D2, G1, F1 approach, G1. The hook.
3. Ethereal pad - hvPad, Gm9 sustained (attack 2.8 sec, release 4.5 sec), Ebmaj9 colour every 4th cycle
4. Clap - hvClap, steps 4 and 12
5. Closed hats - hvHat, steps 2, 6, 10, 14
6. Open hat - hvOpenHat, steps 6 and 14
7. Shaker - hvShaker, quiet 16ths
8. Vocal chop - hvChop, formant synth, G4/Bb4/F4, 3 hits per 2 bars

## Reload
Boot SuperCollider, load grapefruit.scd with sclang or in the REPL. The build runs itself: base first, then one gate every 4 bars, records a proof to ~/beats/hidde-full-proof.wav, then keeps playing. It does not auto stop.
Master volume in the file: -6 dB.

## Parked
- Bridge/build/drop version: ~/beats/hidde-bridge-drop.scd, proof hidde-bridge-drop-proof.wav. Zac: "not the best". Do not re-run unprompted.
