Faust saw => dac;
saw.eval(`
    freq=button("freq");
    process=sawtooth(freq)/100;
    `);
20000 => int t;
100 => float freq;
saw.v("freq",freq);
    
while (t>0) {
    0.9999 *=> freq;
    saw.v("freq",freq);;
    t--;
    samp => now;
}
