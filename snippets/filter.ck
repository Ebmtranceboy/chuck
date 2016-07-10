Impulse imp => ResonZ filt => dac;
1000.0 => filt.freq;
50 => filt.Q;
5.0 => imp.next;

2.0::second => now;