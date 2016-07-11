Faust fck => dac;
fck.eval(` 
    freq=button("freq");    
    process=sawtooth(freq);    
    `);
    
while(true){
    fck.v("freq", Math.random2f(400,800));
    fck.dump();
    100::ms => now;
}