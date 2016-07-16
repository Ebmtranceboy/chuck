
Scale sc;
TimeGrid tg;
StifKarp inst;
inst => dac;
0.05 => inst.gain;
tg.set(1::minute/140/2, 8, 8); // 140BPM, 8 beats, 8 measures

[0, 3, 4, 1, 5, 4, 3, 3] @=> int bass[];
 
tg.sync();
while(true){
    tg.guess() => int i; // global beat
    tg.mmod(i) => int m; // measure
    sc.arp(tg.bmod(i)/2, 7, [0, 2, 4]) => int a; // double note, 7-note scale, [uni,3rd,5th]
    sc.scale(a + bass[m], sc.maj) => int note;
    Std.mtof(2*12 + 7 + note) => inst.freq;
    
    inst.noteOn(0.7);
    tg.beat => now;
    }