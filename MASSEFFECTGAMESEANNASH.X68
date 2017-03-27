*-----------------------------------------------------------
* Title      : MASS EFFECT GAME
* Written by :SEAN NASH DE ANDRADE - C00217019
* Description:TEXT BASED CYOA GAME MOSTLY FOCUSED ON CHARACTERS AND DETECTIVE WORK
* Date: 23/3/17 - 25/3/17
* Known Issues: In the fight system, the defense action can raise the characters shields above max even though the if statement there is supposed to stop it. I cant work it out but that increases the hp *   to no upper limit other than memory
*-----------------------------------------------------------
    ORG    $1000
    
exit        EQU 0      used to exit assembly program
min_fuel    EQU 100    min fuel requirement
   
    
START:                  ; NOTE TO PHIL - I tried my best, honestly the hardest part was thinking up what to write note the code. Please take into account that I am not in a writing course, the crappy writing is a result of that

    ;STAT ALLOCATION TO KEEP THINGS STRAIGHT
    move.l  #10, WILL_VALUE         ;Will Stat
    move.l  #10, FORTITUDE_VALUE    ;Fortitude Stat
    move.l  #10, REFLEX_VALUE       ;Reflexes Stat
    move.l  #10, INTUITION_VALUE    ;Inuition Stat
    
    MOVE.L  #100, HEALTH_VALUE 
    MOVE.L  #100, FUEL_VALUE_MAX
    MOVE.L  #50, FUEL_VALUE_CURRENT
    MOVE.L  #1, LOCATION_VALUE
    move.l  #0,COMPANION_A 
    move.l  #0,MISSION_TRACKER
    move.l  #0,EXPENSE_VALUE
    move.l  #0,MISSION_VALUE
    move.l  #0,CREWBONUS_DAMAGE
    move.l  #0,WEAPONBONUS_DAMAGE
    move.l  #0,TOTAL_DAMAGE ;Initialise all the values so they are not filled with garbage later

    bra setUpScreen ;Branches to the class Selection 





EXITBRANCH:
    SIMHALT             ; halt simulator


*-------------------------------------------------------
*-------------------      Intros      ------------------
*-------------------------------------------------------

introGeneral: ;Introduces the setting
    lea introGeneral_msg,A1 ;Assigns the general intro to be trapped out output
    move.b  #14,D0
    trap    #15
    lea pressKContinue_msg,A1 ;Assigns the general intro to be trapped out output
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    bsr     clear_screen
    bsr     endl
    lea shipIntroGeneral_msg,A1 ;introduces the ship
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    bra     ShipHub ;Branches to main ship loop
    
*-------------------------------------------------------
*-------------------      Ship Hub    ------------------
*-------------------------------------------------------
    
ShipHub:
    bsr     clear_screen ;clears screen
    lea     shipHub_msg,A1 assigns message to A1 to be trapped and so forth 
    move.b  #14,D0          move 14 to DO
    trap    #15
    move.l  KAYLE,D1 ;Checks which crew mates are active
    cmp     #1,D1
    beq     kayleIdle
    bne     emptyShip
    
kayleIdle:
    lea     kayleIdleHub_msg,A1 ;Flavour text
    move.b  #14,D0
    trap    #15
    bra     selectActionShipHub ;Where the player selects what they want to do
    
emptyShip: ;If the player class has no crew mates
    lea shipHubNoC_Selection_msg,A1
    move.b  #14,D0
    trap    #15
    bra     selectActionShipHub

selectActionShipHub:
    bsr endl
    lea shipHub_BASE_OPTIONS_msg,A1 ;Lists the options available
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0          ;Get Input command
    trap    #15

    cmp     #1,D1              
    beq     talkToCrew             if SR Z register contains 1 beq => Branch Equal
    
    cmp     #2,D1              
    beq     shopMenu            
    
    cmp     #3,D1              
    beq     missionSelect             

    cmp     #4,D1              
    beq     captainRoom             ;Each option will branch to its specific section 
    
    bsr clear_screen    ;if nothing valid is picked the screen clear and rebranching to itself essentially loops it
    bra     ShipHub
    
*-------------------------------------------------------
*-------------------      Crew Talk    -----------------
*-------------------------------------------------------    
    


talkToCrew:
    bsr     crewList ;I made most of this game with open code with the idea that if i wanted to add something like a new crew mate it would be easier and simple
    
* First subroutine        
crewList
    lea exit0_msg,A1 ;generic press 0 to exit
    move.b  #14,D0
    trap    #15
    move.l  KAYLE,D1
    if D1 <eq> #1 then.s
        bsr     kaylePresent      ;branch to subroutine second
    endi
    move.l  NOBODY,D1
     if D1 <eq> #1 then.s
        bsr     nobodyPresent      ;branch to subroutine second
    endi
    
    move.b  #4,D0          ;Get Input command
    trap    #15
    
    cmp     #0,D1              
    beq     ShipHub 
    
    cmp     #1,D1              
    beq     talkToKayle
    
    bsr clear_screen
    bra crewList ;return to script (go back to start)

* Second subroutine
kaylePresent
    
    lea talkToCrewKayle_msg,A1     
    move.b  #14,D0
    trap    #15
    rts
    
nobodyPresent
    
    lea talkToCrewNobody_msg,A1     ;These list the people available to talk to
    move.b  #14,D0
    trap    #15
    rts
    
    
talkToKayle:

    move.l KAYLE,D1  ;if kayle isnt present this returns this back to where it should be
    cmp #0,D1
    BEQ crewList
    
    lea talkToKayle_msg,A1
    move.b  #14,D0
    trap    #15
    
    lea talkToKayleOptionsBase_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0          ;Get Input command
    trap    #15
    
    cmp     #0,D1              
    beq     crewList 
    
    if D1 <eq> #1 then.s
        bsr     kayleShipStatus      
    endi
    if D1 <eq> #2 then.s
        bsr     kayleHelp      
    endi
    if D1 <eq> #3 then.s
        bsr     kayleCoffee    ;These branch to a subroutine if the input command is correct 
    endi
    
    bsr clear_screen
    bra talkToKayle
    
kayleShipStatus:
        lea talkToKayleShipStatus_msg,A1
        move.b  #14,D0
        trap    #15    
        move.b  #4,D0          ;Get Input command
        trap    #15
        bsr clear_screen
        bra talkToKayle
        
kayleHelp:
        lea talkToKayleHelp_msg,A1
        move.b  #14,D0
        trap    #15    
        move.b  #4,D0          ;Get Input command
        trap    #15
        bsr clear_screen
        bra talkToKayle
        
kayleCoffee:
        lea talkToKayleCoffe_msg,A1
        move.b  #14,D0
        trap    #15    
        move.b  #4,D0          ;Get Input command
        trap    #15
        bsr clear_screen
        bra talkToKayle  ;Various Dialogue options are selected by the player

*-------------------------------------------------------
*-------------------      Shop        ------------------
*-------------------------------------------------------    
shopMenu:
    lea     shopMenuBaseMenu_msg,A1
    move.b  #14,D0
    trap    #15
    move.l CREDIT_VALUE, D1  
    MOVE.B  #3, D0
    TRAP    #15
    bsr endl
    
    move.b  #4,D0          ;Get Input command
    trap    #15
      
    cmp     #0,D1              
    beq     ShipHub ;Exit to ship loop

    cmp     #1,D1              
    beq     browseItems ;See items available for the current fame level

    bsr clear_screen
    bra shopMenu  
    
browseItems:

    move.l  RENOWN_VALUE,D1
  if D1 <eq> #0 then.s
        bra     browseRenownZero  ;branch to subroutine second
    endi

    bsr clear_screen
    bra shopMenu

browseRenownZero: 

    lea     displayCredits_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l CREDIT_VALUE, D1  ;Displays the Credits owned
    MOVE.B  #3, D0
    TRAP    #15

    lea     itemRenownZero_msg,A1
    move.b  #14,D0
    trap    #15 
 
    move.b  #4,D0          ;Get Input command
    trap    #15
              
    if D1 <eq> #0 then.s
        bra     shopMenu ;branch to subroutine second
    endi
    if D1 <eq> #1 then.s
    bra pistolPresent
    endi
          bsr clear_screen
          bra browseItems

pistolPresent:        
         move.l  PISTOL_PRESENT,D1 ;Only one of each weapon may be had this function checks if there is one present, if there is it stops it, otherwise it goes ahead.
         cmp.l    #0,D1
         beq    purchasePistol
         
         lea     ownedWeapon_msg,A1
         move.b  #14,D0
         trap    #15 
          
         move.b  #4,D0          ;Get Input command
         trap    #15
         
         bsr clear_screen
         bra    browseItems    

purchasePistol: ;Code that checks to see if the player has enough credits

       move.l CREDIT_VALUE,D1
       sub.l #1000,D1
       cmp.l #0,D1
       bgt cashDecreasePistol
         
        lea notEnoughCash_msg,A1
        move.b  #14,D0
        trap    #15 
        
        move.b  #4,D0          ;Get Input command
        trap    #15
         
        bsr clear_screen
        bra browseItems
       
       
cashDecreasePistol: ;part of the code that decreases credits from purchasing the pistol

    move.l #1000,D1
    SUB.l D1,CREDIT_VALUE
    move.l #1,PISTOL_PRESENT

    lea packAway_msg,A1
    move.b  #14,D0
    trap    #15  
     
     move.b  #4,D0          ;Get Input command
     trap    #15
     
    bsr clear_screen
    bra browseItems
    
    
    
    
*-------------------------------------------------------
*-------------      Captains Quarters    --------------- 
*-------------------------------------------------------

captainRoom:
    lea     captainRoomIntro_msg,A1 ;This place is just to review the character and later to retire it
    move.b  #14,D0
    trap    #15  
    
    bsr displayStats
    
    lea     exit0_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l RENOWN_VALUE,D1
    if D1 <eq> #2 then.s
    bsr retirementMessage ;Ends the game later
    endi 

     move.b  #4,D0          ;Get Input command
     trap    #15 
    
    cmp     #0,D1             
    beq     ShipHub
    
    cmp     #1,D1             
    beq     retirement
    
    bra captainRoom

retirementMessage: ;displays the option if the condition renown level is adequate

    lea retirementMessage_msg,A1
    move.b  #14,D0
    trap    #15
    rts

retirement:

    move.l RENOWN_VALUE,D1 ;this stops random buttons from using this code until the condtitions are met
    if D1 <lt> #2 then.s
    bra captainRoom 
    endi
    
    lea retirement_msg,A1
    move.b  #14,D0
    trap    #15
     
    move.b  #4,D0          ;Get Input command
     trap    #15
     
     bra    exitBranch
    
displayStats:  ;Code that displays all stats as a group in a line breaked section
    lea     lineBreak_msg,A1
    move.b  #14,D0
    trap    #15 
    
    lea     displayWill_msg,A1
    move.b  #14,D0
    trap    #15  
    
    move.l Will_VALUE, D1  
    MOVE.B  #3, D0
    TRAP    #15  

    lea     displayFortitude_msg,A1
    move.b  #14,D0
    trap    #15  
    
    move.l FORTITUDE_VALUE, D1  
    MOVE.B  #3, D0
    TRAP    #15 

    lea     displayReflex_msg,A1
    move.b  #14,D0
    trap    #15  
    
    move.l REFLEX_VALUE, D1  
    MOVE.B  #3, D0
    TRAP    #15 

    lea     displayIntuition_msg,A1
    move.b  #14,D0
    trap    #15  
    
    move.l INTUITION_VALUE, D1  
    MOVE.B  #3, D0
    TRAP    #15   
    
    lea     displayCredits_msg,A1
    move.b  #14,D0
    trap    #15  
    
    move.l CREDIT_VALUE, D1  
    MOVE.B  #3, D0
    TRAP    #15     

    lea     displayHealth_msg,A1
    move.b  #14,D0
    trap    #15  
    
    move.l HEALTH_VALUE, D1  
    MOVE.B  #3, D0
    TRAP    #15
   
    bsr     endl
 
    lea     lineBreak_msg,A1
    move.b  #14,D0
    trap    #15   
     
     rts

displayFuel: ;Displays fuel

    lea     displayFuel_msg,A1
    move.b  #14,D0
    trap    #15  

    move.l FUEL_VALUE_CURRENT, D1  
    MOVE.B  #3, D0
    TRAP    #15

    lea     slashBreak_msg,A1
    move.b  #14,D0
    trap    #15  
    
    move.l FUEL_VALUE_MAX, D1  
    MOVE.B  #3, D0
    TRAP    #15    

    rts 

displayLocation: ;Displays location based on location value

    move.l LOCATION_VALUE,D1
    if D1 <eq> #1 then.s
        lea     planet1_msg,A1
        move.b  #14,D0
        trap    #15  ;branch to subroutine second;branch to subroutine second
    endi
    rts

*------------------------------------------------------
*-------------------  Mission Select   ------------------
*------------------------------------------------------- 

missionSelect:             ;Select if you want to do a mission

    lea     missionConsoleIntro_msg,A1
    move.b  #14,D0
    trap    #15 
    bsr endl
    bsr displayFuel
    bsr endl
    bsr displayLocation
    
    move.l RENOWN_VALUE,D1
    if D1 <eq> #0 then.s
        bsr endl
        bsr mission1Briefing
    endi 

     move.b  #4,D0          ;Get Input command
     trap    #15 
     
     lea exit0_msg,A1
     move.b  #14,D0
     trap    #15 
    
    cmp     #0,D1             
    beq     ShipHub
    
    cmp     #1,D1             
    beq     missionChoice  

    bsr clear_screen
    bra missionSelect  


mission1Briefing:
        lea     mission1Briefing_msg,A1
        move.b  #14,D0
        trap    #15  ;branch to subroutine second
        
        
        rts
        
missionChoice:
    move.l RENOWN_VALUE,D1 ;;Selects a mission to do
    if D1 <eq> #0 then.s
        bsr clear_screen
        lea mission1SetUp_msg,A1
        move.b  #14,D0
        trap    #15  ;branch to subroutine second
    endi 
    
    lea missionChoiceOptions_msg,A1
    move.b  #14,D0
    trap    #15  ;branch to subroutine second
    
     move.b  #4,D0          ;Get Input command
     trap    #15 
    
    cmp     #0,D1             
    beq     missionSelect
    
    cmp     #1,D1             
    beq     missionPrep 

    bsr clear_screen
    bra missionChoice
    
missionPrep: ;;Selects the crew mate to bring along

    lea missionCrewSelect_msg,A1
    move.b  #14,D0
    trap    #15  ;branch to subroutine second
    
        move.l KAYLE,D1
  if D1 <eq> #1 then.s
    bsr kayleSelect
    endi     

        move.l NOBODY,D1
  if D1 <eq> #0 then.s
    bsr nobodySelect
    endi     
   
     move.b  #4,D0          ;Only 1 crew mate may be brought along, no crewmates can also be selected
     trap    #15 
     
    cmp     #0,D1             
    beq     missionSelect
    
  if D1 <eq> #1 then.s
    bra kayleSelected
    endi
    
      if D1 <eq> #5 then.s
    bra nobodySelected
    endi
        
    bra ShipHub   
    
kayleSelect:
    lea     missionKayle_msg,A1
    move.b  #14,D0
    trap    #15  ;branch to subroutine second  
    rts

nobodySelect:
    lea     missionNobody_msg,A1
    move.b  #14,D0
    trap    #15  ;branch to subroutine second  
    rts    
    
kayleSelected:
    move.l KAYLE,D1
    if D1 <eq> #1 then.s
    move.l #1,COMPANION_A ;This is the variable that tracks which Companion is with the player
    move.l #4,CREWBONUS_DAMAGE
    bra missionGo
    endi
    bra missionPrep
    
nobodySelected:
    move.l NOBODY,D1
    if D1 <eq> #1 then.s
    move.l #0,COMPANION_A 
    bra missionGo
    endi   
    bra missionPrep 


missionGo:

    move.l MISSION_VALUE,D1
    cmp #0,D1
    beq mission1Intro
    bra ShipHub   


*------------------------------------------------------
*-------------------Mission One -----------------------
*------------------------------------------------------

resetMission1:

    bsr clear_screen
    lea mission1GameOver_msg,A1
    move.b  #14,D0
    trap    #15  ;branch to subroutine second 
     move.b  #4,D0          ;Get Input command
     trap    #15
     
    move.l #0,HE_PRESENT
    move.l EXPENSE_VALUE,D1
    add.l  D1,CREDIT_VALUE
    move.l #0,EXPENSE_VALUE
    bsr resetHealth
    bra mission1Intro



mission1Intro:
    
    lea mission1Intro_msg,A1 ;introduces the time value
    move.b  #14,D0
    trap    #15 

     move.b  #4,D0          ;Get Input command
     trap    #15 

     move.l #8,TIME_VALUE  ;The time is a resource that must be managed, resets the mission if this reaches zero
    move.l #0,CLUE_ONE  
 
    bra mission1Hub
    
mission1Hub:

     move.l TIME_VALUE,D1 ;checks if the time has ended
     cmp #0,D1
     beq resetMission1

    lea mission1Hub_msg,A1
    move.b  #14,D0
    trap    #15 
    
    bsr endl
    
    lea displayTime_msg,A1
    move.b  #14,D0
    trap    #15 

     move.l TIME_VALUE,D1
     MOVE.B  #3, D0
     TRAP    #15

    lea mission1HubOptions_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l CLUE_ONE,D1 ;if the player has found the required events then allows them to continue
    if D1 <eq> #1 then.s
    bsr mission1BomberHouseOption
    endi  


     move.b  #4,D0          ;Get Input command
     trap    #15   

    cmp     #1,D1             
    beq     mission1Police
    
    cmp     #2,D1             
    beq     mission1Bar
    
    cmp     #3,D1             
    beq     mission1InfoBroker
    
    cmp     #4,D1             
    beq     mission1BomberHouse

    bsr clear_screen
    bra mission1Hub  

mission1BomberHouseOption:
    lea mission1bomberHouseOption_msg,A1
    move.b  #14,D0
    trap    #15
    rts
    
mission1Police:
        
    sub.l #1,TIME_VALUE
    lea mission1PoliceStationDesc_msg,A1
    move.b  #14,D0
    trap    #15

    move.b  #4,D0          ;Get Input command and pauses
    trap    #15 

    lea mission1PoliceStationResult_msg,A1
    move.b  #14,D0
    trap    #15

    move.b  #4,D0          ;Get Input command and pauses
    trap    #15 
    bra    mission1Hub

mission1Bar:

    lea mission1BarDesc_msg,A1
    move.b  #14,D0
    trap    #15

    move.b  #4,D0          ;Get Input command and pauses
    trap    #15
    
    lea mission1BarSearch_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l INTUITION_VALUE,D1
    if D1 <gt> #12 then.s  ;Certain options are only available to characters with certain stats
    bsr mission1BarSpecialIntuition
    endi     

    move.b  #4,D0          ;Get Input command and pauses
    trap    #15
    
    cmp     #1,D1             
    beq     mission1SearchResult
    
    cmp     #2,D1             
    beq     mission1IntuitionResult
  
  
    bsr clear_screen
    bra mission1Bar
    
mission1BarSpecialIntuition:
    lea mission1BarIntuitionOption_msg,A1
    move.b  #14,D0
    trap    #15
    rts

mission1SearchResult:
    lea mission1BarSearchResult_msg,A1
    move.b  #14,D0
    trap    #15
    sub.l #1,TIME_VALUE
    bra mission1Hub
    
mission1IntuitionResult:

    move.l INTUITION_VALUE,D1
    if D1 <gt> #12 then.s
    lea mission1BarIntuitionResult_msg,A1
    move.b  #14,D0
    trap    #15
    move.l #1,CLUE_ONE
    sub.l #1,TIME_VALUE
    bra mission1Hub 
    endi
    
    bra mission1Bar   


mission1InfoBroker:

    lea mission1InfoBrokerDesc_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0          ;Get Input command
    trap    #15
    
    cmp     #2,D1             
    beq     mission1InfoBrokerNo
    
    cmp     #1,D1             
    beq     mission1InfoBrokerYes
    
    bsr clear_screen
    bra mission1InfoBroker
    
mission1InfoBrokerNo:

    lea mission1InfoBrokerNoResult_msg,A1
    move.b  #14,D0
    trap    #15 
    sub.l #1,TIME_VALUE
    bra mission1Hub           

mission1InfoBrokerYes:
    move.l CREDIT_VALUE,D1    
     if D1 <gt> #500 then.s
    lea mission1InfoBrokerYesResult_msg,A1
    move.b  #14,D0
    trap    #15 
    sub.l #1,TIME_VALUE
    sub.l #500,CREDIT_VALUE
    add.l #500,EXPENSE_VALUE
    move.l #1,CLUE_ONE
    bra mission1Hub
    endi
    lea notEnoughCash_msg,A1
    move.b  #14,D0
    trap    #15
    bra mission1InfoBroker

mission1BomberHouse: ;the secondary hub of the mission
    move.l CLUE_ONE,D1 ;Checks to see if the player is allowed to be here or has found this place by randomly pressing buttons.
    cmp #0,D1
    beq mission1Hub
    
     move.l TIME_VALUE,D1
     cmp #0,D1
     beq resetMission1
     
     bsr clear_screen
    
    lea mission1BomberHouseDesc_msg,A1
    move.b  #14,D0
    trap    #15 
    move.l #1,HE_PRESENT
    
    lea displayTime_msg,A1
    move.b  #14,D0
    trap    #15 

     move.l TIME_VALUE,D1
     MOVE.B  #3, D0
     TRAP    #15

    bsr endl

    move.b  #4,D0          ;Get Input command
    trap    #15
    
    cmp     #1,D1             
    beq     mission1BomberPolice
    
    cmp     #3,D1             
    beq     mission1BomberEx   

    cmp     #2,D1             
    beq     mission1BomberCouncil

    bsr clear_screen
    bra mission1BomberHouse 

mission1BomberPolice:

    lea  mission1BomberPolice_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0          ;Get Input command
    trap    #15
    sub.l #1,TIME_VALUE
    bra mission1BomberHouse 
   
mission1BomberEx:

    lea  mission1BomberEx_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0          ;Get Input command
    trap    #15
    sub.l #1,TIME_VALUE    
    bra mission1BomberHouse 
       
mission1BomberCouncil:

    lea  mission1BomberCouncil_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l COMPANION_A,D1    
    if D1 <eq> #1 then.s
    bsr mission1BomberKayle
    endi
    
    move.b  #4,D0          ;Get Input command
    trap    #15

    cmp     #1,D1             
    beq     mission1BomberFight
                 
    cmp     #2,D1             
     beq     mission1BomberFightKayle
    
    
    bra mission1BomberHouse
mission1BomberKayle:
    lea  mission1BomberKayle_msg,A1
    move.b  #14,D0
    trap    #15
    rts
    
mission1BomberFightKayle:

   move.l COMPANION_A,D1    
    if D1 <eq> #1 then.s
    lea  mission1BomberFightKayle_msg,A1 ;Some options are only available if certain crewmates are brought with
    move.b  #14,D0
    trap    #15
 
    move.b  #4,D0          ;Get Input command
    trap    #15
    
   bra mission1Conlusion
    endi
   bra mission1BomberCouncil
   
   
mission1BomberFight: ;the fight system is made so the variables are given and the same code can be used for different missions this is how the stats are set for the fight
    move.l  #5,ENEMY_DAMAGE
    move.l  #80,ENEMY_HEALTH
    move.l  #1,FIGHT_VALUE
    bsr fightSystem   

mission1Conlusion:
    lea mission1Conclusion_msg,A1 ;ends the mission and gives the required rewards
    move.b  #14,D0
    trap    #15
    
    add.l   #1500,CREDIT_VALUE
    bsr resetHealth
    move.l  #2,RENOWN_VALUE
    
    move.b  #4,D0          ;Get Input command
    trap    #15
    
    bra ShipHub

*------------------------------------------------------
*-------------------  Combat   ------------------ 
*-------------------------------------------------------
fightSystem:    
    lea     displayHealth_msg,A1 ;Displays the players health and what actions he can take
    move.b  #14,D0
    trap    #15  
    
    move.l HEALTH_VALUE, D1  
    MOVE.B  #3, D0
    TRAP    #15
    
   bsr endl
 
    lea combatOptions_msg,A1
    move.b  #14,D0
    trap    #15   

    move.b  #4,D0          ;Get Input command
    trap    #15
    
    if D1 <eq> #1 then.s
    bra fightSystemAttack
    endi
    
    if D1 <eq> #2 then.s
    bra fightSystemDefend
    endi

    if D1 <eq> #3 then.s
    bra fightSystemSpecial
    endi
    
    bra fightSystem

fightSystemAttack: ;calculates the damage after all the modifications and stats
    move.l  #0,TOTAL_DAMAGE
    move.l  CREWBONUS_DAMAGE,D1
    add.l   D1,TOTAL_DAMAGE
    move.l  WEAPONBONUS_DAMAGE,D1
    add.l   D1,TOTAL_DAMAGE
    move.l  REFLEX_VALUE,D1
    sub.l   #10,D1
    divu    #2,D1
    add.l   D1,TOTAL_DAMAGE
    move.l  TOTAL_DAMAGE,D1
    sub.l   D1,ENEMY_HEALTH
    
    bra fightSystemEnemyAttack

fightSystemEnemyAttack: ;sees if the player killed the enemy lets him win, if not attacks the player. Checks if the player has died, resets if he did
    move.l ENEMY_HEALTH,D1
    MOVE.B  #3, D0
    TRAP    #15
    if D1 <lt> #0 then.s
    bsr fightSystemVictory
    endi
    move.l ENEMY_DAMAGE,D1
    sub.l   D1,HEALTH_VALUE
    move.l HEALTH_VALUE,D1
    if D1 <lt> #0 then.s
    bsr fightSystemLoss
    endi
    bra fightSystem
    
fightSystemDefend:
    add.l #10,HEALTH_VALUE
    move.l HEALTH_VALUE,D1
    move.l FORTITUDE_VALUE,D2
    sub.l   #10,D2
    divu    #2,D2
    mulu    #10,D2
    add.l   #100,D2
    
    if D1 <gt> D2 then.s
    move.l D2,D1
    endi 
    bra fightSystem 
  
fightSystemSpecial:
    move.l HE_PRESENT,D1
      if D1 <eq> #1 then.s
    bsr fightSystemHE_Pres
    endi
    
    move.b  #4,D0          ;Get Input command
    trap    #15
    
    cmp #0,D1
    beq fightSystem
    
    cmp #1,D1
    beq fightSystemHE
    
    bsr clear_screen
    bra fightSystemSpecial

fightSystemHE_Pres:
    lea fightSystemHE_Pres_msg,A1 
    move.b  #14,D0
    trap    #15  
    rts

fightSystemHE:
    move.l HE_PRESENT,D1
         if D1 <eq> #1 then.s
        move.l #-10,ENEMY_HEALTH
        bra fightSystemEnemyAttack
    endi
    bra fightSystemSpecial
    
fightSystemVictory:
    move.l FIGHT_VALUE,D1
        if D1 <eq> #1 then.s
        bra mission1Conlusion
    endi
    rts

fightSystemLoss: 
    move.l FIGHT_VALUE,D1
        if D1 <eq> #1 then.s
        bra resetMission1
    endi
    rts   
*------------------------------------------------------
*-------------------Set Up Screen ------------------ (SETS UP CLASS AT START)
*-------------------------------------------------------
setUpScreen:
 
    lea     classIntro_msg,A1 assigns message to A1 to be trapped and so forth 
    move.b  #14,D0          move 14 to DO
    trap    #15             trap and interpret value in D0
    lea     captain_msg,A1  assign message to address register A1
    trap    #15             trap and interpret value in D0
    bra classSelection

classSelection:
    move.b  #4,D0           ;Get the class selection from the player via them writing the number they want
    trap    #15

    cmp     #1,D1               ;Checks to see if the number is the captain`s number
    beq     captainSetUp              if SR Z register contains 1 beq => Branch Equal
    
    bsr clear_screen
    bra     setUpScreen
    

*-------------------------------------------------------
*-------------------Class Set Up ------------------ (SETS UP CLASS AT START)
*-------------------------------------------------------

captainSetUp:
    move.l  #14,WILL_VALUE   ;Will Stat
    move.l  #14,FORTITUDE_VALUE   ;Fortitude Stat
    bsr     healthCalculation ;Health Adjustment
    move.l  #14,REFLEX_VALUE   ;Reflexes Stat
    move.l  #16,INTUITION_VALUE   ;Inuition Stat
    move.l  #1,KAYLE
    move.l  #0,NOBODY
    move.l  #0,NOBODY
    move.l  #1500,CREDIT_VALUE
    move.l  #0,RENOWN_VALUE
    move.l  #1,PISTOL_PRESENT
    move.l  #4,WEAPONBONUS_DAMAGE
    move.l  #0,HE_PRESENT ;Various stats and equipment yes/no values
    bsr     clear_screen
    bra introGeneral


*-------------------------------------------------------
*-------------------Stat Calculations ------------------ 
*-------------------------------------------------------
healthCalculation: ;sets the players fortitude bonus health
    move.l FORTITUDE_VALUE,D1
    sub.l #10,D1
    divu #2,D1
    mulu #10,D1
    add.l D1,HEALTH_VALUE
    rts
    
resetHealth:
    move.l #100,HEALTH_VALUE     ;resets players health to max
    move.l FORTITUDE_VALUE,D1
    sub.l #10,D1
    divu #2,D1
    mulu #10,D1
    add.l D1,HEALTH_VALUE
    rts      
   
*-------------------------------------------------------
*-------------------Screen Control Functions ------------------ 
*-------------------------------------------------------
   
clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
   
endl:                   ;Does the Same thing as in visual studio, skips a line. Use to separate texts.
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
   
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------

crlf:           dc.b    $0D,$0A,0

classIntro_msg: dc.b    '-------------------------------------------------------'
                dc.b    $0D,$0A
                dc.b    'The Galaxy is a big place, plenty of room for all kinds'
                dc.b    $0D,$0A
                dc.b    'But what would you be?'
                dc.b    $0D,$0A
                dc.b    '-------------------------------------------------------'
                dc.b    $0D,$0A,0

captain_msg:    dc.b    '---------------  Press 1 To Select  -------------------'
                dc.b    $0D,$0A
                dc.b    'Captain, No specializations but no real flaws. Has seen it all and returned in one piece.'
                dc.b    $0D,$0A
                dc.b    'Equipment - Pistol and a Loyal Crew.'
                dc.b    $0D,$0A
                dc.b    '-------------------------------------------------------'
                dc.b    $0D,$0A,0
                

introGeneral_msg:
                dc.b    $0D,$0A
                dc.b    'Some people just have the road in their stars. You have for your own reasons for being where you are either for profit or lack of any alternative '
                dc.b    $0D,$0A
                dc.b    'Now you find yourself in orbit around a backwater planet, mercenary work has been slow for the last while and it shows'
                dc.b    $0D,$0A
                dc.b    'The ship, Clarity is not in as good condition as you would like,'
                dc.b    ' some crew were let loose and compromises had to be made.'
                dc.b    $0D,$0A
                dc.b    'You dont think Kayle has forgiven you '
                dc.b    ' for the loss of the coffee machine yet.'
                dc.b    $0D,$0A
                dc.b    'But that doesn`t matter, You know that something is picking up. Whispers'
                dc.b    ' in dark corners and hushed tones'
                dc.b    ' hint of a time where things get a bit... messy. '
                dc.b    $0D,$0A
                dc.b    'Never a better chance to strike it big.'
                dc.b    $0D,$0A,0
                
shipIntroGeneral_msg:
                dc.b    'Blinking you find yourself, face down on a tacky plastic table. '
                dc.b    'Kayle will probably give an earful about that later. Something about propriety'
                dc.b    $0D,$0A
                dc.b    'Shaking your head and looking around.'
                dc.b    $0D,$0A,0
                
shipHub_msg:
                dc.b    'The ship seems to be running as intended, quiet humming in the background broken up by the few remaining technicians talking at their stations'
                dc.b    $0D,$0A,0
shipHubNoC_Selection_msg:
                dc.b    'Nobody seems to be around, Might be time to look around the ship.'
                dc.b    $0D,$0A,0
                
kayleIdleHub_msg:
                dc.b    $0D,$0A
                dc.b    'You can vaguely see Kayle off in the corner speaking with Navigation.'
                dc.b    $0D,$0A,0

                
shipHub_BASE_OPTIONS_msg:
                dc.b    $0D,$0A
                dc.b    'Try and find a crew member (1), Head to the Ship Quartermaster (2), Check your Console for Job Opportunities (3), Head to your Quarters (4)'
                dc.b    $0D,$0A,0
                
talkToCrewKayle_msg: 
                dc.b    $0D,$0A
                dc.b    'You know Kayle is on the command Deck [1]'
                dc.b    $0D,$0A,0  
                
talkToCrewNobody_msg: 
                dc.b    $0D,$0A
                dc.b    'The ship is empty, you are on your own...'
                dc.b    $0D,$0A,0     

talkToKayle_msg: 
                dc.b    $0D,$0A
                dc.b    'Kayle is busy working with the pilot making sure the ship doesn`t crash while you walk around aimlessly.'
                dc.b    $0D,$0A 
                dc.b    'She does look up when you come around, raising an eyebrow. You wanted something? '
                dc.b    $0D,$0A,0
                
talkToKayleOptionsBase_msg:
                dc.b    $0D,$0A
                dc.b    'Press 0 to exit...'
                dc.b    $0D,$0A 
                dc.b    '"Whats the status of the ship? [1]"'
                dc.b    $0D,$0A 
                dc.b    '"Any ideas what to do now? [2]"'
                dc.b    $0D,$0A
                dc.b    '"About the coffe machine... [3]"'
                dc.b    $0D,$0A,0                

talkToKayleShipStatus_msg:
                dc.b    $0D,$0A
                dc.b    'She frowns for a second thinking, "Is there a better word for a flying deathtrap?" '
                dc.b    $0D,$0A
                dc.b    'Shakes her head "We are in as good a state as we can hope for, when we die it wont be because of a goddamn engine failure"'
                dc.b    $0D,$0A
                dc.b    'She gives you the side eye, its clear to her who`s bright idea will lead to said fiery death in a ignoble fashion.'
                dc.b    $0D,$0A,0   
                
talkToKayleHelp_msg:
                dc.b    $0D,$0A
                dc.b    'She blink, face blank for a second. "Isn`t that your job to figure out?" Theres a drawn out sigh and mutters about past job opportunities'
                dc.b    $0D,$0A
                dc.b    'Taking a breath she responds "Look I know you generally just make things up as you go along but could you at least pretend you have a plan?"'
                dc.b    $0D,$0A
                dc.b    'A vague gesture towards your console followed by a backhanded mention to check it for job offer that actually pay might be the best plan.'
                dc.b    $0D,$0A,0   
                
talkToKayleCoffe_msg:
                dc.b    $0D,$0A
                dc.b    'Just as you start talking theres a twinge at the back of your neck. Kayle`s expression hasn`t changed,'
                dc.b    ' but you get the feeling you should stop for your own health if nothing else.'
                dc.b    $0D,$0A
                dc.b    'You back off from that minefield and try to convince yourself that she had snapped that pen for other unrelated reasons.'
                dc.b    $0D,$0A,0 
                
                
shopMenuBaseMenu_msg:
                dc.b    $0D,$0A
                dc.b    'The quartermaster is really just an old man with very good connections you picked up one day for... reasons?'
                dc.b    $0D,$0A
                dc.b    'Regardless now he can get you what you need, for a price of course.'
                dc.b    $0D,$0A
                dc.b    'Exit ... [0]'
                dc.b    $0D,$0A
                dc.b    'Browse Wares [1]'
                dc.b    $0D,$0A
                dc.b    'Credits : '
                dc.b    $0D,$0A,0 
                

itemRenownZero_msg:
                dc.b    $0D,$0A
                dc.b    'The quartermaster rubs his chin and shrugs. "Hard to get people to go out of their way for nobodies, now if we had some renown.."'
                dc.b    $0D,$0A
                dc.b    'Pistol - +4 AD - 1000 Credits [1]'
                dc.b    $0D,$0A
                dc.b    'Exit ... [0]'
                dc.b    $0D,$0A,0

ownedWeapon_msg:   
                dc.b    $0D,$0A
                dc.b    'You think about it, then remember that you have one just like it. Dual wielding does not work like in the movies.'
                dc.b    $0D,$0A,0   

captainRoomIntro_msg:
                dc.b    $0D,$0A
                dc.b    'You find your way to your quarters, small and cramped but its yours. As you lean back into a chair a relection catches your eye.'
                dc.b    $0D,$0A,0  
        

missionConsoleIntro_msg:
                dc.b    $0D,$0A
                dc.b    'Picking your way to your console you check it over for any good job offers. [1] To begin a mission'
                dc.b    $0D,$0A,0 
                
mission1Briefing_msg:
                dc.b    $0D,$0A
                dc.b    'You look back over the offer that brought you here, an official from the '
                dc.b    'colony below belived a serial bomber had taken up residence in their area.'
                dc.b    $0D,$0A
                dc.b    'Regardless of the circumstances it seems like it will be a bit quieter than '
                dc.b    'most things you have to deal with, the clock would be against you though.'
                dc.b    $0D,$0A,0 
                
mission1SetUp_msg:                
                dc.b    $0D,$0A
                dc.b    'Assignment on Eden - 5, Objective: Find the Bomber before they act again. [1] '
                dc.b    $0D,$0A                
                dc.b    'Expected Conflict - Low'
                dc.b    $0D,$0A
                dc.b    'Reward - 1500 Credits '
                dc.b    $0D,$0A,0 

missionCrewSelect_msg:
                dc.b    $0D,$0A
                dc.b    'Select a partner to come with you. '
                dc.b    $0D,$0A,0
                
missionChoiceOptions_msg:                
 
                dc.b    $0D,$0A
                dc.b    'Select a mission to prepare to embark onto, Press 0 to exit '
                dc.b    $0D,$0A,0
               
missionKayle_msg:
                dc.b    $0D,$0A
                dc.b    'Kayle - Has Gun, Will Travel. Talking isnt her strongest side [1]'
                dc.b    $0D,$0A,0
                
missionNobody_msg:
                dc.b    $0D,$0A
                dc.b    'Nobody - Who needs Friends? [5]'
                dc.b    $0D,$0A,0 


mission1Intro_msg:
                dc.b    $0D,$0A
                dc.b    'After docking and contacting your employers as quickly as '
                dc.b    'possible. They explain the situation.'
                dc.b    $0D,$0A
                dc.b    'Not long ago they recieved a bomb threat from an insane bomber '
                dc.b    'who had been attacking various locations for far too long.'                
                dc.b    $0D,$0A
                dc.b    'On the edge and with their own fledgling security unable to'
                dc.b    ' find the audibly insane man they reached out to you.'
                dc.b    $0D,$0A
                dc.b    'No leads, no help, nothing. You really pulled an easy one here, '
                dc.b    'nobody really expects anything. But if you succeded...'
                dc.b    $0D,$0A
                dc.b    'Shaking off thoughts of the future for now, theres only so much time '
                dc.b    'left. You dont have enough of it waste daydreaming'               
                dc.b    $0D,$0A,0

mission1Hub_msg:
                dc.b    $0D,$0A
                dc.b    'You find yourself in the centre of the colony`s capital, a bomb threat does nothing to stop the lively atmosphere.'
                dc.b    $0D,$0A
                dc.b    'People are threading their way through their own lives and you cant help but wonder if your mark was nearby.'
                dc.b    $0D,$0A
                dc.b    'Pausing for a moment you think about your options, the clock is ticking...'                
                dc.b    $0D,$0A,0
                
                
mission1HubOptions_msg:
                dc.b    $0D,$0A
                dc.b    'There are a few things that could give you a clue, but you should be careful, running around wasting time cant end well...'
                dc.b    $0D,$0A
                dc.b    'The Col.Sec havent found this guy yet but maybe they have some idea about ... something? [1]'
                dc.b    $0D,$0A
                dc.b    'A passing drunk man reminds you of the local watering holes, it would be difficult but maybe someone might let something slip [2]'
                dc.b    $0D,$0A
                dc.b    'The last option is one your wallet dislikes, information can be bought just like anything else, maybe someone`s selling? [3] '                
                dc.b    $0D,$0A,0  
             
mission1PoliceStationDesc_msg:
                dc.b    $0D,$0A
                dc.b    'The somewhat too shiny security quarters has a rather pleasant looking secretary who directs you to the waiting room'
                dc.b    $0D,$0A
                dc.b    'A backhanded comment of being dealt with "Shortly" before you are left to your own devices, leaning back into a seat'
                dc.b    $0D,$0A
                dc.b    'This shouldn`t take long.'                
                dc.b    $0D,$0A,0                 

mission1PoliceStationResult_msg:
                dc.b    $0D,$0A
                dc.b    'You regret alot of things, most of them involve tempting fate. Beauracracy and bruised pride at your presence'
                dc.b    $0D,$0A
                dc.b    'meant that every possible delay was heaped upon you. You dont know if it was pettiness or if that was the norm'
                dc.b    $0D,$0A
                dc.b    'Regardless this was a waste of time they had nothing that`s why you are here. You need to hurry.'                
                dc.b    $0D,$0A,0

mission1BarDesc_msg:
                dc.b    $0D,$0A
                dc.b    'This bar like most of the ones you find yourself dwelling inside in recent times is a dump. Seedy, dark and filled'
                dc.b    $0D,$0A
                dc.b    'with people trying to avoid the crowds and their associated law enforcers your sure. Regardless alcohol has been the'
                dc.b    $0D,$0A
                dc.b    'cause of alot of problems but maybe this time you can fix one with it.'                
                dc.b    $0D,$0A,0
                
mission1BarSearch_msg:
                dc.b    $0D,$0A
                dc.b    'You could find a group, poke them for information while they are too far gone to recognise the probing questions? [1]'                
                dc.b    $0D,$0A,0                

mission1BarIntuitionOption_msg:
                dc.b    $0D,$0A
                dc.b    '( High Intuition )The back of your neck twinges as you see a line of ragged figures at bar counter... [2]'                
                dc.b    $0D,$0A,0

mission1BarIntuitionResult_msg:
                dc.b    $0D,$0A
                dc.b    'You struck gold, the ragged men were beggars and after a few drinks to their health they dont even notice'
                dc.b    $0D,$0A
                dc.b    'when your questions turn more pointed. Inbetween the many pointless bits of trivia there is one thing.' 
                dc.b    $0D,$0A
                dc.b    'One of the beggars had a favourite spot outside the council estate hall something about symbiotic P.R acts of generosity'
                dc.b    $0D,$0A
                dc.b    'But what catches your attention is his strange encounter with a man who came everyday to the same spot and just watched.'
                dc.b    $0D,$0A
                dc.b    'You spend the rest of your time and patience prodding to get some identification before finally getting an address.'
                dc.b    $0D,$0A
                dc.b    'You`re onto something.'                               
                dc.b    $0D,$0A,0

mission1BarSearchResult_msg:
                dc.b    $0D,$0A
                dc.b    'The hours swim together into a swirl as one drink to fit in becomes several and you find yourself waking in an alley later'
                dc.b    $0D,$0A
                dc.b    'with a headache and nothing much else to show for it. The sun travelling crossing the sky catches your attention, time is ticking'                                
                dc.b    $0D,$0A,0 

mission1InfoBrokerDesc_msg:
                dc.b    $0D,$0A
                dc.b    'Alot of effort and searching afterwards lead you to a broker hidden so well, only scoundrels and their asscociates would know where'
                dc.b    $0D,$0A
                dc.b    'to go. The climate controlled clean office is a bit offputting with the clock you know is ticking down, but knowing how these things'
                dc.b    $0D,$0A
                dc.b    'go you sit down and wait. A small powerplay, aggrevating but nothing someone like you can do about it right now, if you had more of a'  
                dc.b    $0D,$0A
                dc.b    'name to throw about then this would never happen. But such is your lot in life.'
                dc.b    $0D,$0A
                dc.b    'Eventually you are brought into a clean smelling office where a disturbingly pale looking man makes you a deal. It was easy to guess'
                dc.b    $0D,$0A
                dc.b    'what you wanted, so he laid out the deal. 400 credits upfront for a name, address. Nothing more... Agree[1]? Disagree [2]?'                              
                dc.b    $0D,$0A,0 
                
mission1InfoBrokerNoResult_msg:
                dc.b    $0D,$0A
                dc.b    'No'
                dc.b    $0D,$0A
                dc.b    'A sigh before a large meaty hand attached to an equally meating looking mountain of man "guides" you outside.'
                dc.b    $0D,$0A
                dc.b    'Nothing, wonderful. Your watch reminds you that at any time the bomber might decide his patience is gone. You need to hurry'                              
                dc.b    $0D,$0A,0

mission1InfoBrokerYesResult_msg:
                dc.b    $0D,$0A
                dc.b    'Yes'
                dc.b    $0D,$0A
                dc.b    'A clean efficient transaction, a clean folder with a notable lack of any prints or smudges.'
                dc.b    $0D,$0A
                dc.b    'Korvin Smith, M , Age 34 , Known mental issues, Delusions and paranoia related to authority. Known address...'                              
                dc.b    $0D,$0A,0                     

mission1BomberHouseOption_msg:
                dc.b    $0D,$0A
                dc.b    'You have an address, with a bit of luck and alot of speed you can catch him before he does anything. [4]'                             
                dc.b    $0D,$0A,0

mission1BomberHouseDesc_msg:
                dc.b    $0D,$0A
                dc.b    'Moving quickly through the streets, gettin lost at some points but in the end you are able to find his house.'
                dc.b    $0D,$0A
                dc.b    'The outside is clean, the inside however is a different story. After breaking down the door and clearing all the rooms'
                dc.b    $0D,$0A
                dc.b    'you confirm that the bomber is not here, calming slightly after that you set about trying to find where he might have gone.'
                dc.b    $0D,$0A
                dc.b    $0D,$0A
                dc.b    'Looking around you find mountains of trashed sprinkled with unused pill bottles. Checking under the bed nearly gives you '
                dc.b    $0D,$0A
                dc.b    'a heart attack when you see several homemade explosive sachets before realising they`re not live. You think for a moment'
                dc.b    $0D,$0A
                dc.b    'and act, Col.Sec would later find one less explosive than was actually there but never know when something like that could'
                dc.b    $0D,$0A
                dc.b    'come in handy. Eventually your search bears fruit, buried in the written ramblings of a very confused person was a small '
                dc.b    $0D,$0A        
                dc.b    'scrapbook. Flipping through it quickly shows a list of unconnected buildings and buisnesses, except that they had all been '
                dc.b    $0D,$0A 
                dc.b    'blown to cinders in recent times... There were three things in the book that hadn`t been attacked yet as far as you know. '
                dc.b    $0D,$0A 
                dc.b    $0D,$0A 
                dc.b    'A picture of the main Col.Sec Station [1], A series of brochures about the Legislative Council`s Estate Hall and ... '
                 dc.b    $0D,$0A 
                dc.b    'A picture of a couple, a small uneasy looking man you recognise as Mr.Smith, the bomber and a smiling lady beside him [3] '                                       
                dc.b    $0D,$0A,0
                
mission1BomberPolice_msg:                
                dc.b    $0D,$0A 
                dc.b    'Col.Sec has a reputation for beauracracy and slow response times, bad but not enough to let them blow up for. Acting quickly'   
                 dc.b    $0D,$0A 
                dc.b    'you find yourself in the station faster than you expected, shrugging and walk in. What followed was what felt like a slow '
                 dc.b    $0D,$0A 
                dc.b    'response to a bomb threat in your opinion but eventually the station is searched and cleared. No sign of explosive devices'
                 dc.b    $0D,$0A 
                dc.b    'Wrong place, even as you run back to the house you see other Col.Sec guards fanning out in search of your mark.'
                 dc.b    $0D,$0A 
                dc.b    'Even the slow response force is getting with the show, hope it wasnt too late. '                                          
                dc.b    $0D,$0A,0


mission1BomberEx_msg:                
                dc.b    $0D,$0A 
                dc.b    'The house had no signs of more than one person living here, but once there was. Revenge against someone an ex? Excessive '   
                 dc.b    $0D,$0A 
                dc.b    ' but the potential damage that could occur from such an attack makes the decision for you. A search of the house gives a '
                 dc.b    $0D,$0A 
                dc.b    'name. Kelly Waters and her number still written down beside the phone. It takes several calls before you get ahold of her'
                 dc.b    $0D,$0A 
                dc.b    ' while the conversation starts calm it quickly stops being that, and even you can admit telling someone over a phone an'
                 dc.b    $0D,$0A 
                dc.b    'Ex might be out for their blood is a bit.. blunt? Regardless she has agreed to go to Col.Sec Station to stay safe. '                                          
                dc.b    $0D,$0A,0 

mission1BomberCouncil_msg:                
                dc.b    $0D,$0A 
                dc.b    'The council estate... there were alot of links between his recent behaviour and that building. '   
                 dc.b    $0D,$0A 
                dc.b    ' Taking a chance you order a lift even as you contact your employers about the threat. Evacuations in place you  '
                 dc.b    $0D,$0A 
                dc.b    'get moving as quickly as you can. You see the somewhat bare architechture of the estate hall ahead.'
                 dc.b    $0D,$0A 
                dc.b    'Noting the stream of people slowly making their way out of the building as you take a less used entrance, '
                 dc.b    $0D,$0A 
                dc.b    'what follows is a slow, tense search. You swear that at any moment you might hear a roar of thunder, a wave of heat '
                dc.b    $0D,$0A 
                dc.b    'then nothing. But it doesn`t happen, everything is quiet, all the people long since evacuated. Maybe you were ...'
                dc.b    $0D,$0A 
                dc.b    'a twinge at the back of your neck instinctively brings you to a stop when a hail of bullets spray out from down the '
                dc.b    $0D,$0A 
                dc.b    'hallway you were going to turn down. Just a second later.... shaking off the brush with the reaper before you met him '
                dc.b    $0D,$0A 
                dc.b    'for real. The spray had stopped but you both know where the other is... well you expected this fight? [1]'                           
                dc.b    $0D,$0A,0 

mission1BomberKayle_msg:
                dc.b    $0D,$0A
                dc.b    'A cough from behind you as Kayle reminds you of her presence.'
                dc.b    $0D,$0A
                dc.b    'Need a hand? [2]'                                               
                dc.b    $0D,$0A,0 
                
mission1BomberFightKayle_msg:
                dc.b    $0D,$0A
                dc.b    'This is clearly a very dangerous situation, best time to practice that wonderful skill. Delegation '
                dc.b    $0D,$0A
                dc.b    'You lean back against the wall as Kayle vanishes around the corner, you ignore the noises that occur afterwards.'
                dc.b    $0D,$0A
                dc.b    'Trying instead to think about what to do after this job, but even then those pleads will return in your nightmares'
                dc.b    $0D,$0A
                dc.b    'Kayle rounds the corner wiping her hands on her pants. Nods, Jobs done.'                                               
                dc.b    $0D,$0A,0                
                
combatOptions_msg:                
                dc.b    $0D,$0A
                dc.b    'Attack and deal Damage? [1], Defend and heal ?[2] or use a Special Item [3]'                                               
                dc.b    $0D,$0A,0

fightSystemHE_Pres_msg: 
                dc.b    $0D,$0A
                dc.b    'Use a H.E Sachet?[1]'                                               
                dc.b    $0D,$0A,0               
                
 
mission1GameOver_msg:
                dc.b    $0D,$0A
                dc.b    'A thunderous sound, rising screams and alarms. Failure and de.. You shake your head and move on.'
                dc.b    $0D,$0A
                dc.b    'No need to psyche yourself out with worst case scenarios'                                               
                dc.b    $0D,$0A,0 

mission1Conclusion_msg:
                dc.b    $0D,$0A
                dc.b    'The following events after the mission ended are a bit of a blur. You did get paid and got checked over by a'
                dc.b    $0D,$0A
                dc.b    'doctor.. returning to your ship you are left to wonder. Now what?'                                               
                dc.b    $0D,$0A,0 
                
retirementMessage_msg:                
                dc.b    $0D,$0A
                dc.b    'You have nearly died to many times for you to count to this date. Retire? [1]'                                              
                dc.b    $0D,$0A,0

retirement_msg:                
                dc.b    $0D,$0A
                dc.b    'You survived to retirement with a relatively well known reputation. Thats the game, thanks for playing'                                              
                dc.b    $0D,$0A,0  
                
                
               
pressKContinue_msg:
                dc.b    $0D,$0A
                dc.b    'Press any Key to Continue...'
                dc.b    $0D,$0A,0
                
                

exit0_msg:
                dc.b    $0D,$0A
                dc.b    'Press 0 to exit...'
                dc.b    $0D,$0A,0
                
displayCredits_msg:
                dc.b    $0D,$0A
                dc.b    'Credits : ',0 

notEnoughCash_msg:
                dc.b    $0D,$0A
                dc.b    'The sale comes to halt when your poor bank account cant handle the cost.'
                dc.b    $0D,$0A,0
                

packAway_msg:
                dc.b    $0D,$0A
                dc.b    'The sale completes and you pack away your new toy.'
                dc.b    $0D,$0A,0 
                
planet1_msg:

                dc.b    ' In orbit of Eden - 5 ',0                
                
                
lineBreak_msg:                
                dc.b    $0D,$0A
                dc.b    '-------------------------------------------------------------'
                dc.b    $0D,$0A,0 

slashBreak_msg:                
                dc.b    '/',0                 
                
displayWill_msg: 

                dc.b    $0D,$0A
                dc.b    'Will : ',0
              
displayFortitude_msg: 

                dc.b    $0D,$0A
                dc.b    'Fortitude : ',0
                
                
displayReflex_msg: 

                dc.b    $0D,$0A
                dc.b    'Reflex : ',0

displayIntuition_msg: 

                dc.b    $0D,$0A
                dc.b    'Intuition : ',0
                
displayHealth_msg: 

                dc.b    $0D,$0A
                dc.b    'Health : ',0 
                
displayTime_msg: 

                dc.b    $0D,$0A
                dc.b    'Time : ',0                
                
displayFuel_msg: 

                dc.b    $0D,$0A
                dc.b    'Fuel : ',0               
                

HEALTH_VALUE    dc.l    $5000
WILL_VALUE      dc.l    $4100
FORTITUDE_VALUE dc.l    $4200
REFLEX_VALUE    dc.l    $4300
INTUITION_VALUE dc.l    $4400
CREDIT_VALUE    dc.l    $4500
RENOWN_VALUE    dc.l    $4600
FUEL_VALUE_MAX  dc.l    $4700
FUEL_VALUE_CURRENT  dc.l    $4800
LOCATION_VALUE  dc.l    $4900
TIME_VALUE      dc.l    $3800
EXPENSE_VALUE   dc.l    $3700
FIGHT_VALUE     dc.l    $3900

;Weapons Found
PISTOL_PRESENT  dc.l    $3000 
HE_PRESENT  dc.l    $3100    

;RECRUITED CREW
NOBODY          dc.l    $3500
KAYLE           dc.l    $3600


;CREW/ENEMY ON THE EXCURSION & STATS THEY AFFECT
COMPANION_A             dc.l  $6100
MISSION_TRACKER         dc.l  $6200
CLUE_ONE                dc.l  $6300
CLUE_TWO                dc.l  $6400
CLUE_THREE              dc.l  $6500
MISSION_VALUE           dc.l  $6600
ENEMY_HEALTH            dc.l  $6700
ENEMY_DAMAGE            dc.l  $6800
CREWBONUS_DAMAGE        dc.l  $6900
WEAPONBONUS_DAMAGE      dc.l  $7000
TOTAL_DAMAGE            dc.l  $7100

    END    START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
