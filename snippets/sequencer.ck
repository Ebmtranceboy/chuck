// sequencer.ck
// sequencer class for sequencing arbitrary samples 
// author: spencer salazar (updated by jason webb)
// Feel free to use/modify/distribute as you see fit.  

public class sequencer
{
	static dur measure_seconds;
	static Event @ new_measure;
	static int on;
	
	fun static void start()
	{
		while( on )
		{
			new_measure.broadcast();
			measure_seconds => now;
		}
	}
	
	fun static void stop()
	{
		0 => on;
	}

	fun static void set_measure_length(dur new_ml )
	{
		// wait until the end of the measure
		new_measure => now;
		new_ml => measure_seconds;
	}

	fun static void sequence( string filename, float bpmeasure, float volumev[] )
	{
		new_measure => now;
	
		SndBuf buf => Gain g => dac;
		filename => buf.read;
		.5 => g.gain;

		0 => int i;
		0 => int j;

		while( on )
		{		
			for( 0 => i; i < bpmeasure; i++ )
			{
				if( volumev[j] > 0 )
				/* only play the sample if its meant to be heard */
				{
					0 => buf.pos;
					volumev[j] => buf.gain;
				}
				
				j++;
				if( j >= volumev.cap() )
					0 => j;
				(measure_seconds/bpmeasure) => now;
			}
			//new_measure => now;
		}
	}

}

Event e @=> sequencer.new_measure;
1.5::second => sequencer.measure_seconds;
1 => sequencer.on;

sequencer.start();
