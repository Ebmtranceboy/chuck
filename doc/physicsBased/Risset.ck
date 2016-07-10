BlitSaw s[7];
Gain mix => dac;
1.0/7.0 => mix.gain;

for(0 => int i; i<7; i++){
    s[i] => mix;
    <<< (100.0+(0.1*i)) => s[i].freq >>>;
}
20.0::second => now;