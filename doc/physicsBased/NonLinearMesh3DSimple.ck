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
//   This one has added AllPass Filter for non-linearity
//   NOTE, much higher computational burdon, but worth it
//   DOUBLE NOTE!!!  Danger here, be careful and keep the volume down.
//    by Perry Cook, 2015
public class NonLinearMesh3DSimple extends Chubgraph  {
    Impulse imp => Junction6 yo => outlet;
    inlet => yo;  // optional: you can feed any signal into this
    Delay wgs[6]; // 6 delay lines
    Gain nlIn => PoleZero nl => Dyno clip; // clipper and all pass (for non-linearity)
    clip.slopeAbove(0.0); // hard clip
    clip.thresh(0.5); // safety, and distortion!        
    0.1 => float nonLin;
    
// prime number delay lengths, you can mess with these, CPU is same no matter what
    [127,137,157,181,199,227] @=> int primes[];  // some bigger ones
//    [59,83,101,113,127,139] @=> int primes[];  // some smaller ones
//    [239,199,159,119,79,39] @=> int primes[];  // nearly not primes at all!!
    0.99 => float dmp;

    for (int i; i < 6; i++)  {   // set up and connect everybody
        primes[i]::samp => wgs[i].delay; // set delay lengths
        yo.input(i,wgs[i]);           // connect delays to junction
        yo.out(i) => wgs[i]; // junction to delays
                    //  added all pass filters here
        dmp => wgs[i].gain;           // set damping 
    }
    yo.out(0) =< wgs[0];  // disconnect, and wire NonLinearity
    yo.out(0) => nlIn; clip => wgs[0]; // into one delay path
    
    spork ~ doAllPass();   // start up shred (runs per-sample)

    fun float nonLinearity(float nlin)  {
 //  NOTE:  Hack here, seems to decay fine for 0.43 or less 
            //   (or so, depending a lot on damping) 
       if (nlin < 0.43) nlin => nonLin => nl.allpass;
       else <<< "Setting to max of: ", 0.43 => nonLin => nl.allpass >>>;
       return nonLin;
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
    
    fun void noteOn(float vel)  {
        vel => imp.next;
    }        
    
    fun void doAllPass()  {
        while (true)  {
            if ( nlIn.last() > 0) nonLin => nl.allpass;
            else -0.5*nonLin => nl.allpass;
            Math.random2(1,10)::samp => now; // hack to avoid 1/2 sample rate/other limit cycles
        }
    }
}

/*
//  Un-comment this back in to see what it can do
// Test Simple NonLinear Mesh //

NonLinearMesh3DSimple dm => dac;

0.995 => dm.damp; // set damping for all modes 
//     (NOTE:   careful, especially with nonLinearity enabled)

while (1)  {
    <<< "Semi-random modes, linear" >>>;
    0.0 => dm.nonLinearity;
    Math.random2f(0.0,0.2) => dm.randomModes; // randomize +/- 20%
    1 => dm.noteOn;
    3*second => now;
    
    Math.random2f(0.2,0.43) => float temp => dm.nonLinearity;
    <<< "Same modes, nonLinear:", temp >>>; // non-linearity
    1 => dm.noteOn;
    10*second => now;
}
*/

