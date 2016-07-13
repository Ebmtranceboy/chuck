
Scale sc;
TimeGrid tg;
StifKarp inst;
inst => dac;
0.1 => inst.gain;
tg.set(1::minute/140/2, 8, 8);

[0, 3, 4, 1, 5, 4, 3, 3] @=> int bass[];
 
tg.sync();
while(true){
    tg.guess() => int i;
    tg.mmod(i) => int m;
    sc.arp(tg.bmod(i)/2, 7, [0, 2, 4]) => int a;
    sc.scale(a + bass[m], sc.maj) => int note;
    Std.mtof(2*12 + 7 + note) => inst.freq;
    
    inst.noteOn(0.7);
    tg.beat => now;
    }