declare name "hocico";
declare author "ebmtranceboy";
declare copyright "hellektropole";
declare version "1.00";
declare license "BSD"; 

import("oscillator.lib");
import("effect.lib");

/******** parameters **********/

excitation_duration = nentry("2-excitation_duration in s",1,0,10,0.01);
excitation = bpf.start(0.0,0.31)
	:bpf.point(94.0,0.67)
	:bpf.point(188,0)
	:bpf.point(203,0.77)
	:bpf.point(208,0.38)
	:bpf.point(306,0.25)
	:bpf.point(380,0.53)
	:bpf.point(459,0.42)
	:bpf.point(508,0.15)
	:bpf.point(518,0)
	:bpf.point(685,0.46)
	:bpf.point(813,0.06)
	:bpf.end(1024,0);

freq = nentry("1-freq in Hz",60,0,3000,0.5);
k1 = 0.7; // coefficient of resonnance of the string
trans = 0.15; // stabilization time of pitchshifter in s
roomSize = 2.92;
reverb = environment{
	gain = 0.087;
	del = 0;
	f1 = 50;
	f2 = 8000;
	t60dc = roomSize*3;
	t60m = roomSize*20;
	fsmax = 44100;};

/******************************/

mirror(a, b, x) = a + mir(pos(x - a)) with {
	c = b - a;
	pos(y) = if(y < 0, y + 2*c*floor(1 - y/(2*c)), y);
	mir(y) = if(f2 < c, f2, 2*c - f2) with{
		f2 = fmod(y, 2*c);
	};};

phasor0(freq) = phasor(freq, 0);
phasor(freq, phase) = initial - initial' :
	((+ : maybeDec : maybeInc) ~ +(d)) with {
	d = freq/SR;
	maybeDec(x) = if(x > 1, x - 1, x);
	maybeInc(x) = if(x < 0, x + 1, x);
	initial = phase - d ;};

pitchshifter(nsemis, maxdelsec, sig) = 
	tap1*fade1 + tap2*fade2 with {
	basehz = midikey2hz(60); //  middle C
	newhz = midikey2hz(60 + nsemis);
	ratio = newhz/basehz;
	delrate = (ratio - 1)/maxdelsec;
	vdel1 = phasor0(-delrate);
	vdel2 = phasor(-delrate, 0.5);
	fade1 = vdel1*2 : mirror(0,1);
	fade2 = 1 - fade1;

	tap1 = fdelay1s(vdel1*maxdelsec*SR, sig);
	tap2 = fdelay1s(vdel2*maxdelsec*SR, sig);};

damp(f, i, t) = (i - i') : ((*(x), _ : +) ~ _) with{
	n = SR*t; 
	x = pow(f, 1/n);};

wavesolve(freq, k1, sig) = begp + endb, begb + endp with{
	sampsfrac = SR/freq;
	k0 = (1 - k1)/2;
	
	bd1 = fdelay1s(sampsfrac);
	bd2 = _ <: *(k0), (mem <: *(k1), (mem : *(k0))) :> _;
	circuit = sig : ((_, _ :> _ <: (bd1 <: (bd2 <: bd1, _), _), _) ~ _);
	begp = circuit : !, !, !, _;
	endp = circuit : !, !, _, !;
	begb = circuit : !, _, !, !;
	endb = circuit : _, !, !, !;};

scale(n) = n*1024/nn with{nn = excitation_duration*SR;};

naturals = (+(1) ~ _) - 1;
in = (naturals : scale : excitation) 
	*imptrain(freq) 
	*damp(1/100, 1, excitation_duration);
waves = wavesolve(freq, k1, in);

wave_left  = waves : _, !;
wave_right = waves : !, _;
wave = (wave_left + wave_right)/2;

shift_neg = pitchshifter(-12, trans, wave);
shift_pos = pitchshifter(+12, trans, wave);
shift = shift_neg + shift_pos;

left  = wave_left + shift;
right = wave_right + shift;
instrReverb = _, _ <: *(reverb.gain)
			, *(reverb.gain)
			, *(1 - reverb.gain)
			, *(1 - reverb.gain) : 
	zita_rev1_stereo(reverb.del
		, reverb.f1
		, reverb.f2
		, reverb.t60dc
		, reverb.t60m
		, reverb.fsmax), _, _ 
		<: _, !, _, !, !, _, !, _ : +, +;
       
process = left, right : instrReverb;
