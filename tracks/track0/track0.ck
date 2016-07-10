sawtooth saw => dac;
20000 => int t;
100 => float freq;
freq => saw.freq;
    
while (t>0) {
    0.9999 *=> freq;
    freq => saw.freq;
    t--;
    samp => now;
}
