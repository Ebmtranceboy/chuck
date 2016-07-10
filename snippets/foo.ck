SinOsc s => dac;
440 => int freq;
<<<200 => freq>>>;
#(2,3)=>complex c;
<<<c>>>;
while(true){
0.01::second => now;
Std.rand2f(30.0, 1000.0) => s.freq;
}