// Listing 10.2 Keyboard organ controlled by Hid event
// Hid object
Hid hi;                  // (1) Makes a new Hid object...

// message to convey data from Hid device
HidMsg msg;              // (2) ...and Hid message holder.

// device number: which keyboard to open
0 => int device;         // (3) Keyboard device number.

// open keyboard; or exit if fail to open
if( !hi.openMouse( device ) ) me.exit();  // (4) Opens it, exits if failed.

// print a message!           // (5) Prints message if success.
<<< "mouse '" + hi.name() + "' ready", "" >>>;

// siund chain
SndBuf buffy => dac;
me.dir() + "audio/snare_01.wav" => buffy.read;
buffy.samples() => buffy.pos;

// infinite event loop
while( true )
{
    // wait for event
    hi => now;                    // (7) Waits for mouse event.
    // get message
    while( hi.recv( msg ) )       // (8) loops over all messages (mouse pressed).
    {
        if(msg.isButtonDown()){
            <<< "Button Down !">>>;
            0 => buffy.pos;
        }
        else if(msg.isMouseMotion()){
            if(msg.deltaX != 0){
                <<< "Mouse delta X: ", msg.deltaX >>>;
                msg.deltaX / 20.0 => buffy.rate;
            }
        }
    }
}
