;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 2/4/2017
; Last Modified: 1/17/2020
; Brief description of the program
;   The LED toggles at 2 Hz and a varying duty-cycle
; Hardware connections (External: One button and one LED)
;  PE1 is Button input  (1 means pressed, 0 means not pressed)
;  PE2 is LED output (1 activates external LED on protoboard)
;  PF4 is builtin button SW1 on Launchpad (Internal) 
;        Negative Logic (0 means pressed, 1 means not pressed)
; Overall functionality of this system is to operate like this
;   1) Make PE2 an output and make PE1 and PF4 inputs.
;   2) The system starts with the the LED toggling at 2Hz,
;      which is 2 times per second with a duty-cycle of 30%.
;      Therefore, the LED is ON for 150ms and off for 350 ms.
;   3) When the button (PE1) is pressed-and-released increase
;      the duty cycle by 20% (modulo 100%). Therefore for each
;      press-and-release the duty cycle changes from 30% to 70% to 70%
;      to 90% to 10% to 30% so on
;   4) Implement a "breathing LED" when SW1 (PF4) on the Launchpad is pressed:
;      a) Be creative and play around with what "breathing" means.
;         An example of "breathing" is most computers power LED in sleep mode
;         (e.g., https://www.youtube.com/watch?v=ZT6siXyIjvQ).
;      b) When (PF4) is released while in breathing mode, resume blinking at 2Hz.
;         The duty cycle can either match the most recent duty-
;         cycle or reset to 30%.
;      TIP: debugging the breathing LED algorithm using the real board.
; PortE device registers
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_AFSEL_R EQU 0x40024420
GPIO_PORTE_DEN_R   EQU 0x4002451C
; PortF device registers
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
SYSCTL_RCGCGPIO_R  EQU 0x400FE608

       IMPORT  TExaS_Init
       THUMB
       AREA    DATA, ALIGN=2
;global variables go here


       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
	  
Start
 ; TExaS_Init sets bus clock at 80 MHz
     BL  TExaS_Init ; voltmeter, scope on PD3
 ; Initialization goes here 
     LDR R0, = SYSCTL_RCGCGPIO_R ;intialize port E clock
	 LDR R1, [R0]
	 ORR R1, #0x10
	 STR R1, [R0]
	 NOP
	 NOP
	 LDR R0, = GPIO_PORTE_DIR_R ;port E2 set to output
	 MOV R1, #0x04
	 STR R1, [R0]
	 LDR R0, = GPIO_PORTE_DEN_R ;temp digital enable to test on sim
	 MOV R1, #0x06
	 STR R1, [R0]
	 
	 
	 
	 
	 


     CPSIE  I    ; TExaS voltmeter, scope runs on interrupts
	 ;these are some registers I used because I was too lazy to make variables
	 
	 LDR R5, = 3333333 ;The base length of a cycle	
	 LDR R9, = 3000000 ;The max value we want to let a high run
	 LDR R6, = 666666	;amount incrementing duration of high
	 LDR R4, = 1000000  ;length of high in the beginning
loop  
; main engine goes here
;FACT: (20M) cycles == 1s
	
	 LDR R0, = GPIO_PORTE_DATA_R
	 LDR R1, [R0]    
	 LDR R2, [R0]	;sees if PE1 is turned on or off 
	 BFC R2, #1,#1
	 CMP R2, R1
	 BMI change		;if CMP is negative that means PE1 is turned on, so then branch change the cycle
return
     ;LDR R0, = GPIO_PORTE_DATA_R
	 LDR R1, [R0]
	 ORR R1, #0x04
	 STR R1, [R0]
	 BFC R2, #0, #31
	 ADD R2, R4, #0
Delay1
	 ADD R8, R8, #0
	 LDR R1, [R0]
	 LDR R7, [R0]	;sees if PE1 is turned on or off 
	 BFC R7, #1,#1
	 CMP R7, R1
	 BMI change 
	 SUBS R2, R2, #1
	 BNE Delay1
     
	 
	 LDR R1, [R0]
	 BFC R1, #2, #2
	 STR R1, [R0]
	 BFC R3, #0, #31
	 SUBS R3, R5, R4
Delay2
     ADD R8, R8, #0
     LDR R1, [R0]
	 LDR R7, [R0]	;sees if PE1 is turned on or off 
	 BFC R7, #1,#1
	 CMP R7, R1
	 BMI change
	 SUBS R3, R3, #1
	 BNE Delay2
	 
     B    loop
	 
	 
change
	 CMP R4, R9	;check if R4 is already at 9M
	 BPL Zero
	 ADD R4, R4, R6 ;R4+=2M

loop2	 ;sits here till PE1 turned off
	 LDR R0, = GPIO_PORTE_DATA_R
	 LDR R1, [R0]
	 LDR R2, [R0]	;sees if PE1 is turned on or off 
	 BFC R2, #1,#1
	 CMP R2, R1
	 BMI loop2		;if CMP is negative that means PE1 is turned on, so then branch change the cycle
	 B return
	 
Zero 
	 LDR R4, =1000000	;3M
	 
loop3	 ;sits here till PE1 turned off
	 LDR R0, = GPIO_PORTE_DATA_R
	 LDR R1, [R0]
	 LDR R2, [R0]	;sees if PE1 is turned on or off 
	 BFC R2, #1,#1
	 CMP R2, R1
	 BMI loop3		;if CMP is negative that means PE1 is turned on, so then branch change the cycle

	 
	 B return

      
     ALIGN      ; make sure the end of this section is aligned
     END        ; end of file

