//------------------------------------------------
// name: polyfony.ck
// desc: polyfonic mandolin model
//
// by: Ananya Misra and Ge Wang
// send all complaints to prc@cs.princeton.edu
//--------------------------------------------

// device to open (see: chuck --probe)
1 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

MidiIn min;
MidiMsg msg;

// try to open MIDI port (see chuck --probe for available devices)
if( !min.open( device ) ) me.exit();

// print out device that was opened
<<< "MIDI device:", min.num(), " -> ", min.name() >>>;


// make our own event
class NoteEvent extends Event
{
    int note;
    int velocity;
}

// the event
NoteEvent on;
// array of ugen's handling each note
Event @ us[128];

// the base patch
Gain g => JCRev r => dac;
0.8 => g.gain;
.05 => r.mix;

// handler for a single voice
fun void handler()
{
    // don't connect to dac until we need it
    Faust inst;
    inst.compile("generators/logan.dsp");
    //inst.eval(`freq=button("freq");proc=sawtooth(freq);process=proc,proc;`);
    Event off;
    int note;

    while( true )
    {
        on => now;
        on.note => note;
        // dynamically repatch
        inst => g;
        0.1 => inst.gain;
        inst.v("freq", Std.mtof( note ));
        inst.v("wet", 1);
        //Std.rand2f( .6, .8 ) => m.pluckPos;
        //on.velocity / 128.0 => m.pluck;
        off @=> us[note];

        off => now;
        null @=> us[note];
        inst =< g;
    }
}

// spork handlers, one for each voice
for( 0 => int i; i < 10; i++ ) spork ~ handler();

// infinite time-loop
while( true )
{
    // wait on midi event
    min => now;

    // get the midimsg
    while( min.recv( msg ) )
    {
       <<< msg.data1, msg.data2, msg.data3 >>>;
         // catch only noteon
        if( msg.data1 != 144 && msg.data1 != 128)
            continue;

        // check velocity
        if( msg.data1 == 144)
        {
            // store midi note number
            msg.data2 => on.note;
            // store velocity
            msg.data3 => on.velocity;
            // signal the event
            on.signal();
            // yield without advancing time to allow shred to run
            me.yield();
        }
        else
        {
            if( us[msg.data2] != null ) us[msg.data2].signal();
        }
    }
}
