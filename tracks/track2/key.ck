
Scale sc;
TimeGrid tg;
Faust logan;
logan => dac;
logan.compile("generators/logan.dsp");
0.001 => logan.gain;
tg.set(1::minute/140/2, 8, 8); // 140BPM, 8 beats, 8 measures

[0, 3, 4, 1, 5, 4, 3, 3] @=> int bass[];
 
tg.sync();
while(true){
    tg.guess() => int i; // global beat
    tg.mmod(i) => int m; // measure
    sc.arp(tg.bmod(i)/2, 7, [4, 2, 0]) => int a; // double note, 7-note scale, [uni,3rd,5th]
    sc.scale(a + bass[m], sc.maj) => int note;
    logan.v("freq", Std.mtof(2*12 + 7 + note));
    0.93 => float wet;
    0.5 => float dry;
    for(0 => int i; i<100; i++){
        logan.v("wet", wet-i*(wet-dry)/100);
        tg.beat/100 => now;
    }
    //inst.noteOn(0.7);
    //tg.beat => now;
    }