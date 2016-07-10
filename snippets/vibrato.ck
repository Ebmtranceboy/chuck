SinOsc vib => SawOsc viol => ADSR env => dac;
( 0.5::second, 0.1::second, 0.6, 0.5::second ) => env.set;
220.0 => viol.freq;
6.0 => vib.freq;
2 => viol.sync; // set sync mode to FM
8.0 => vib.gain;
1 => env.keyOn;

2.0::second => now;
1 => env.keyOff;

2.0::second => now;