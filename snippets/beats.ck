SinOsc s1 => Gain mix => dac;
SinOsc s2 => mix;
SinOsc s3 => mix;
SinOsc s4 => mix;
SinOsc s5 => mix;

0.2 => mix.gain;
200 => s1.freq;
200.1 => s2.freq;
300.4 => s3.freq;
401.6 => s4.freq;
402 => s5.freq;

20.0::second => now;