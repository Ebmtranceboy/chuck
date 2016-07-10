//  init.ck file serves as the master program

// add public classes first
Machine.add(me.dir()+"../../snippets/BPM.ck");     //  Adds master BPM class definition

// then add instruments, scores, etc.
Machine.add(me.dir()+"../../snippets/sequencer.ck");
Machine.add(me.dir()+"Track1.ck");


