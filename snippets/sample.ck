SndBuf mySound => dac;

me.dir()=> string path;
"audio/snare_01.wav" => string filename;

filename => mySound.read;

0 => mySound.pos;
0.5 => mySound.gain;
0.7 => mySound.rate;
1::second => now;

