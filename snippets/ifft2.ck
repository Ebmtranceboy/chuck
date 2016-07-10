// our patch
SinOsc g => FFT fft => blackhole;
// synthesize
IFFT ifft => Gain gain => dac;
2 => gain.op;
g => gain;

// set parameters
1024 => fft.size;
440 => g.freq;

// use this to hold contents
complex s[fft.size()/2];

// control loop
while( true )
{
    // take fft
    fft.upchuck();
    // get contents
    fft.spectrum( s );
    // take ifft
    #(0.1,0.2)=>s[Std.rand2(0,fft.size()/2-1)];
    ifft.transform( s );

    // advance time
    fft.size()::samp => now;
}
