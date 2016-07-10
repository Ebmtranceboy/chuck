//  Banded Waveguide demo, P. Cook, 2005 - now (2015)
//    NOTE:  You can also bow this sucker, but for
//           PONG you probably just want to whack it.

BandedWG band => dac;

["Uniform Bar","Tuned Bar",
"Glass Harmonica","Tibetan Bowl"] @=> string presets[];

while (1)  {
   Math.random2(0,3) => int preset;
   preset => band.preset;
   Math.random2f(100,1500) => float freq;
   <<< "Preset=",presets[preset]," Freq=", freq >>>; 
   freq => band.freq;
   1.0 => band.noteOn;
   second => now;
}

