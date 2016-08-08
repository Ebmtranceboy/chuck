//------------------------------------------------
// name: polyFaust.ck
// desc: polyfonic Faust instrument model
//
// initially by: Ananya Misra and Ge Wang
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
.5 => r.mix;

// handler for a single voice
fun void handler()
{
    // don't connect to dac until we need it
    Faust imp => Faust inst;
    
    // simple instrument with amplitude driven by impulsion
    inst.eval(`
       freq=button("freq");
       gain(imp) = (+(imp) : *(0.9999)) ~ _;
       proc = gain : *(sawtooth(freq));
       process = _ <: proc, proc;
    `);
    0.5 => inst.gain;
    
    Event off;
    int note;

    while( true )
    {
        // impulse instrument
        imp.eval("process = 1 - 1';");
        on => now;
        on.note => note;
        // dynamically repatch
        inst => g;
        inst.v("freq", Std.mtof( note ));
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
