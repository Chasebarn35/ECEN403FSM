EVA
Timer 1 - counts 500 times to generate a switching frequency of 10kHz, control time duraction of current and voltage vectors    THIS IS TIM6

Using the voltage crossing detector circuit connected to the input voltage, 
Input voltage is fixed 60Hz, Input current is fixed 60 Hz

EBV
Timer 3 - THIS IS TIM7
Delta C is calculated by integrator every time input is detected on a positive transition in the zero crossing circuit
Sampling frequency of 50 kHz
output voltage
delta v is calculate by integration of the desired output voltage frequency
delta c and delta v are used to deetermine the sector where the input current vector and output voltage vector are located
Timer 4
180 possible combinations of active and zero vectors, each combination is coded in a 6 bit word length stored in a look up table in the data of the DSP

m_ac = int(m.sin(60deg - detla c).sin(60deg - deltav).5000)
m_ad = int(m*sin(60deg-))