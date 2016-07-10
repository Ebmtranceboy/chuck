Impulse imp => dac;

while(true){
    Math.random2f(0.01, 0.1)::second => now;
    1.0 => imp.next;
}