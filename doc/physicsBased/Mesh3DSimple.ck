// Lossless Waveguide Scattering Junction, 6 inputs/outputs (3D mesh)
//    by Perry Cook, 2015
class Junction6 extends Chubgraph {
    //  inlet lets us inject energy, blackhole makes it run no matter what 
    inlet => Gain mix => outlet => blackhole;
    // don't connect waveguides to inlet, use input function below 
    Gain ot[6]; // connection/computation points for output scattering
    Gain in[6]; // connection points for inputs (along with mix)
    2.0/6.0 => mix.gain; // junction pressure normalization
    
    for (int i; i < 6; i++)  { 
        mix => ot[i];  // junction pressure
        2 => ot[i].op; // subtract this next input
        in[i] => ot[i]; // out[i] = junctionPressure - in[i]
    }        

    fun void input(int i, UGen ug) { 
        ug => mix;
        ug => in[i];
    }

    fun Gain out(int o) { return ot[o]; }
}

// Simple 6-way Waveguide Network (a minimum 3D wave equation system)
//    by Perry Cook, 2015
public class Mesh3DSimple extends Chubgraph  {
    Impulse imp => Junction6 yo => outlet;
    inlet => yo;  // optional: you can feed any signal into this
    Delay wgs[6]; // 6 delay lines
    // prime number delay lengths, you can mess with these, CPU is same no matter what
//    [127,137,157,181,199,227] @=> int primes[];  // some bigger ones
    [59,83,101,113,127,139] @=> int primes[];  // some smaller ones
//    [239,199,159,119,79,39] @=> int primes[];  // not primes at all!!

    0.99 => float dmp;

    for (int i; i < 6; i++)  {   // set up and connect everybody
        primes[i]::samp => wgs[i].delay;
        yo.input(i,wgs[i]);
        yo.out(i) => wgs[i];
        dmp => wgs[i].gain;
    }

    fun float damp(float d) {  // note: damping can be negative too
        d => dmp;    // just has to be less than 1.0 absolute value tho
        for (int i; i < 6; i++)  { 
            dmp => wgs[i].gain;
        }
    }

    fun void randomModes(float rnd)  {
        for (int i; i < 6; i++)  {
            Math.random2f((1.0-rnd)*primes[i],(1.0+rnd)*primes[i])::samp => wgs[i].delay;
        }
    }
    
    fun void NoteOn(float vel)  {
        vel => imp.next;
    }        
}

/*
//   Un-Comment this back in to see what it can do!!
 Mesh3DSimple dm => dac;

while (1)  {
    Math.random2f(0.98,0.999) => float damp;
    Math.random2f(0.0,0.1) => float rnd;
    <<< "Damping=", damp, "Randomize Modes=", rnd >>>; 
    damp => dm.damp; // set damping for all modes
    rnd => dm.randomModes; // randomize +/- 10%
    1 => dm.NoteOn;
    second => now;
}
*/
