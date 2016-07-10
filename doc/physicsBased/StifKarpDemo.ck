// Karplus-Strong string with All-Pass Stiffness
StifKarp skarp => dac;

while (1)
{
    <<< "Stretch =" , 
        Math.sqrt(Math.random2f(0.2, 1.0)) => skarp.stretch >>>;
    1 => skarp.noteOn;
    Math.random2f(0.3,0.5) :: second => now;
}



