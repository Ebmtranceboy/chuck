//  Sitar test program, Perry Cook, 2015
//    walks randomly up and down a raga (scale) table
//  An appropriately set delay line yields free polyphony!!

Sitar sitar => NRev r => dac;
0.06 => r.mix;
r => Delay loop => PoleZero dcblock => r; // delay loop = free polyphony!!
0.99 => dcblock.blockZero; // to keep things from building up
0.5 => loop.gain;
2*second => loop.max => loop.delay;

// scale to randomly walk up and down (you could add notes!!)
[50,51,54,55,57,58,61,62] @=> int rag[];

4 => int note; // scale pointer

while (1)  {
    Math.random2(-1,1) +=> note;  // walk up and down scale
    if (note < 0) 0 => note;
    if (note >= rag.cap()-1) rag.cap()-1 => note;

    Std.mtof(rag[note]) => sitar.freq;      // play a note
    Math.random2f(0.5,1.0) => sitar.noteOn;

    (Math.random2(1,3)*0.2) :: second => now; // free rhythm!!!
}


