.1 => dac.gain;
SinOsc oscarray[5];
for(0 => int i; i<5; i++){
	oscarray[i] => dac;
	Math.pow(2, i) * 110.0=> oscarray[i].freq;
}

5::second => now;

for(0 => int i; i<5; i++){
	oscarray[i] =< dac;
	1::second => now;
}

