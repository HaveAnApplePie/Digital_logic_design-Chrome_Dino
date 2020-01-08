

 
 
 

 



window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /Birds_Up_ip_tb/status
      waveform add -signals /Birds_Up_ip_tb/Birds_Up_ip_synth_inst/bmg_port/CLKA
      waveform add -signals /Birds_Up_ip_tb/Birds_Up_ip_synth_inst/bmg_port/ADDRA
      waveform add -signals /Birds_Up_ip_tb/Birds_Up_ip_synth_inst/bmg_port/DOUTA

console submit -using simulator -wait no "run"
