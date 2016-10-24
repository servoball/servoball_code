unit global_variables;          // hier werden alle globalen Variablen definiert

interface
uses
        Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

const
      max_number_of_exits     = 6;    {max number of exits in a junction}
      max_number_of_rats      = 6;
      number_of_monitors      = 6;    // Anzahl Monitore, bei mir 6
      max_number_of_ducts     = 6;
      max_number_of_junctions = 25;
      lab_file_path           ='C:\Labyrinth\engine\lab\';
      trMAXTRIALS             =800; // Anzahl max. Trials im Procedure_file                  = 2000;     // time between trials in ms
      time_down               =140000;//23.2.09, fr¸her war es 40000  //Zeit f¸r absenken der Landschaft bei neuem Trial

const
  MAX_IO_CHANNELS              = 100; // maximale Anzahl von IO Kan‰len
  MAX_TR_EINHEITEN             = 6;  // Anzahl der Tr‰nken-Einheiten.
                                     // entspricht hier der maximalen Anzahl an Monitoren

  RADIUS_OPEN_FIELD            = 20;

  SCALE_FACTOR                 = 1/63; // f¸r Wegaufnehmer
  MAX_ALLOWED_DAC              = 2200; // max allowed DAC value [0..2^12]
  MAX_POSSIBLE_DREF            = 80;   // distance between current position and reference point
  MAX_ALLOWED_ACC              = 5; // camera pixels / second

  HEADER_SENSOR                = $7FFF;  // Header von seriellen Frames, die Daten von der Kamera und den Wegaufnehmern enthalten
  HEADER_IO_PIN                = $7FFE;  // Header von seriellen Frames, die Daten von IO Pin Ereignissen enthalten

  // CAM_X_MAX                    = 68;
  // CAM_Y_MAX                    = 142;
  BASLER_DX                       = 1.27; // mm/px
  BASLER_DZ                       = 1.27; // mm/px
  DOOR_OPEN_TIME               = 3000; // time needed by the servo in order to open the door.
                                       // turn off power after this delay
  DOOR_CHANGE_DELAY            = 5000; // ms
  STORE_PERIOD                 = 6000;  // ms

  SENSOR_FRAME_LENGTH          = 14; // the sensor frame delivers 16 bytes i.e. 14 data bytes + header
  PERIPHERY_FRAME_LENGTH       = 4; // the perifery modules send a 6 bytes frame i.e. 4 data bytes + header
  BUFFER_PERIPHERY             = 9; // buffer length for the serial interface

  MAX_REWARDS                  = 5;
  MAX_RUNTIME                  = 3600000;//36000;10s//3600000;//1h 10800000;//=2min //10800000= 3h; // 6000000= 100min        60000ms=1min
  MAX_TRIALS                   = 800; // maximal no of trials / experiment


  // Parameter f¸r Filter
  DATA_MIN_PERIOD              = 1000;   //(millisecs) minimum length of time at LB needed
  DATA_MAX_PERIOD              = 1000; //(millisecs) max length of time to wait before next LB signal

  trMAXJUNCTIONS               = 6; // maximale Anzahl von junctions mit Belohnung/ trial
  trDELAYENDJ                  = 5000;//3000;//60000; // in der end junction eines trials warten
  DELAY_RESET                  = 5000;//3000; // Zeit zwischen Trials
// hardware addresses of the IO Pins used for light barriers, servo motors and feeders
// these data can be placed into a .csv file
  LB_Controller             = 1;
  LB_Bus                    = 0;
  LB_I2C                    = 0;
  LB_Code                   = $A0;
  LB_Init                   = $40;

  //Opt_Sensor_Controller     = 1;
  //Opt_Sensor1_Bus           = 1;
  //Opt_Sensor2_Bus           = 1;
  //Opt_Sensor1_I2            = 1;
  //Opt_Sensor2_I2C           = 1;

  Feeder_Controller         = 1;
  Feeder_Bus                = 0;
  Feeder_I2C                = 0;
  Feeder_Code               = $A0;
  Feeder_Init               = $C0;

  Cam_Controller            = 1;
  Cam_Bus                   = 2;
  Cam_I2C                   = 1;

  Motor_Controller          = 1;
  Motor1_Bus                = 4;
  Motor2_Bus                = 4;
  Motor1_I2C                = $10;
  Motor2_I2C                = $11;
  Motor_PowerUp             = $40;
  Motor_Code                = $30;
  Motor_Command             = $C0;

  MotorScale                = 0.7;
  MotorXscale               = 1;//8.12.08    //1.64;
  MotorZscale               = 1;

type

    TJunction = record
                  number_junction  : integer; // Kreuzungsnummer, redundant, aber sicher ist sicher
                  tele_enable      : Byte;
                  maze_shape       : Byte;
                  Y_center         : integer; // echtes und unechtes Zentrum
                  x_junction       : Real; {x-Multiplikator des Verschiebefaktors der Kreuzung}
                  z_junction       : Real; {y-Multiplikator des Verschiebefaktors der Kreuzung}
                  x_junction_grafic: Real;
                  z_junction_grafic: Real;
                  x_junction_grafic_llm: Real;
                  z_junction_grafic_llm: Real;
                  number_of_exits  : integer;    // Anzahl der Ausg‰nge/ Wege
                  local_lm         : array[1..number_of_monitors] of Byte; //lokale Landmarken an max 8 Orten pro Kreuzung vorhanden
                  feeder_available : array[1..number_of_monitors] of Byte; // Tr‰nken vorhanden? 0 oder 1
                  feeder_signal    : array[1..number_of_monitors] of Byte; // Tr‰nken Marken vorhanden? o oder 1
                  duct_identifier  : array[1..max_number_of_exits] of integer; //Gangnummer
                  exit_angle       : array[1..max_number_of_exits] of Word;
                  exit_low_angle      : array[1..max_number_of_ducts] of Integer;
                  exit_high_angle     : array[1..max_number_of_ducts] of Integer;
                  next_junction    : array[1..max_number_of_exits] of Integer;
                  duct_length      : array[1..max_number_of_exits] of Real;
                  duct_length_grafic:array[1..max_number_of_exits] of Real;

                  wall_height      : array[1..max_number_of_exits] of Byte;
                  upper_wall       : array[1..max_number_of_exits] of Byte;// oberer Wandteil vorhanden, 0 oder 1
                  upper_wall_height: array[1..max_number_of_exits] of Byte;
                  duct_wall_height:  array[1..max_number_of_exits] of Byte;
                  lm_typ1_a        : array[1..max_number_of_exits] of byte; // LM vom Typ 1 am Ganganfang
                  lm_typ1_b        : array[1..max_number_of_exits] of byte; // LM vom Typ 1 in Gangmitte
                  lm_typ1_c        : array[1..max_number_of_exits] of byte; // LM vom Typ 1 am Gangende
                  lm_typ2_a        : array[1..max_number_of_exits] of byte; // LM vom Typ 2 am Ganganfang
                  lm_typ2_b        : array[1..max_number_of_exits] of byte; // LM vom Typ 2 in Gangmitte
                  lm_typ2_c        : array[1..max_number_of_exits] of byte; // LM vom Typ 2 am Gangende
                  
                  x_landscape      : real; {berechneter x-Koordinatenwert der Kreuzung}
                  z_landscape      : real; {berechneter y-Koordinatenwert der Kreuzung}
                end;

type

     TexpState = (expSTART, expCONTROL, expRUNNING, expGOHOME, expWAIT,
               expCONTROL_HOME);
     TmazeState = (st_OPEN_FIELD, st_JUNCTION, st_CORRIDOR, st_NIX, st_STANDBY);
var
        current_junction, current_duct:    integer; // aktuelle Kreuzungsnummer und Gangnummer
        current_junction_enter_time: int64;
        maze_state, maze_state_before_standby: TmazeState;
         first_run: boolean; //very First run
        exp_state:  TexpState;
        Session_control: string;
        Session_control_ok: boolean;
        ball_control_ok: boolean;
        executed: boolean;
        wrong_end: boolean;
        status: string; //??? -> MapAndVars
        old_status: string; //???

          X_Y_Z_send_koordinates: boolean; //15.3.09
          cam_x, cam_z : integer;
          x_animal_cam, z_animal_cam : integer;
          x_animal_landscape, y_animal_landscape, z_animal_landscape : real; // jeweils 4 byte
          corridor_x, corridor_z : real;
          reset_landscape: boolean;
        
        motor_x, motor_z:        real;      // current data for DAC
        motor_x_prev, motor_z_prev: real;   // previous data for DAC
        time_motor_prev: int64;
        x_z_aninal_landscape: string;{x und y Koordinaten, mit Komma getrennt, zum schicken Åber UDP}
        lab_file_name     : string;           {name of maze definition file}
        lab,out           : Text;   {maze definition file, data output file}
        out_file_name     : String;             {file name for data storage}
        save_data_counter : double;  //after 60000 saving events, a new file is opened
        junction          : array [0..max_number_of_junctions] of Tjunction;
        Proc_file_name    :  string; //File mit Versuchsablauf, muss auch im Ordner Lab stehen

   // Variablen der Labyrinthdatei
      out_file_path: string; // Pfad f¸r die Protokolldatei
      alpha_lab: word;       // Drehwinkel f¸r das ganze Labyrinth 0, 60, 120, 180,...
      colour_ground: byte;   // Farbverlauf am Boden 0, 1
      colour_sky:    byte;   // Farbverlauf am Himmel 0, 1
      start_junction:integer;// Startkreuzung
      duct_width: byte;
      decision_radius: integer;// decision distance in camera units
      number_of_junctions:  integer;// Anzahl der Kreuzungen, Gangenden sind auch Kreuzungen
      number_of_ypsilons:  integer;// Anzahl der Kreuzungen, Gangenden sind auch Kreuzungen
      end_of_labyrinth_definition_file: byte;// ist standartm‰ssig auf 99 gesetzt
      maze_shape:byte;      // 1 =Y

 type
   TVector = record
            k1, k2: real;
  end;


    TBallState = record
                   current_rat, prev_rat : integer;
                   detected, center, on_sphere : boolean;

                   reset_maze: boolean; // Signal f¸r neuen Trial
                   reset_time: int64; // delay
                   previous_feeder : integer;

                   enter_time, exit_time : int64;   //time when door opens,
    end;

    TExperiment = record
                   available_feeder : array[1..MAX_TR_EINHEITEN] of boolean;
                   available_cage : array[1..MAX_TR_EINHEITEN] of boolean;

                   experiment_no : integer; // Runde, Abfolge von Trials

                   // Anzahl der Belohnungen / K‰fig, auch bei mehreren Runden
                   reward_counter_array : array[1..MAX_TR_EINHEITEN] of integer;

                   lm: array[1..32] of TVector;
    end;

 TTrEinheit = record
             adresse         : array[0..4] of integer;
             feeder_duration : array[0..4] of integer;
             current_state   : array[0..4] of boolean;
             open            : boolean;
             feeder_active   : array[1..MAX_TR_EINHEITEN] of boolean;
             // Unit3: LB_data_filter
             //LB_time_data    : array[0..4] of TLB_TimeValues_Data; //array of times for LBs (only 1&4 in use)
                                                                   // [1]=LB_sphere, [4]=LB_cage
  end;

    TReward_Junction = record
       reward_feeder_arr  : array[1..max_number_of_junctions] of integer;
       // for each junction, there is a physical feeder unit that corresponds to it
       //   (for example: reward_feeder_arr[1] = 3, at junction 1, the feeder is unit 3)
       reward_count_arr   : array[1..max_number_of_junctions] of integer;
       // contains the current count of rewards given at each junction
       feeder_count_arr   : array[1..number_of_monitors] of integer;
       // similar to reward_count_arr, but contains the count of rewards given at
       //   each feeder, for displaying to Reward Form (Form2)
       feeder_attempt_arr : array[1..number_of_monitors] of integer;
       // similar to feeder_count_arr, but tracks the number of attempts at each feeder
       prev_reward_junct  : byte;
       // to keep track of the previous junction that a reward was given
    end;

    TTrialJunction= record
            junction: integer;
            feeder: array[1..6] of integer; // rewarded feeders
            local_lm_junction: array[1..6] of integer;//boolean;// landmarks in a specifc junction
    end;

    TTrial= record
            // index: integer; // fortlaufende nr.
            index: longint;
            pause: boolean; // between sessions, wait until rat goes onto sphere

            reward_current_trial: boolean;
            cage: integer;
            start_j: integer; // start junction for current trial
            end_j: integer;
            llm: integer; //colour and shape of llm
            //reward: array[0..trMAXJUNCTIONS] of TTrialJunction; // junctions an denen belohnt wird
            TrialJunction: array [0.. trMAXJUNCTIONS] of TTrialJunction;// lm in the specific junction for this trial
            distal_lm: array [1..6] of real; //angles for the 4 distal lm per Trial
    end;

  var
  llm_colour: integer;
  first_time_trial_end:boolean;
  start_executed,control_executed, control_home_executed, gohome_executed,
                                   running_executed:boolean;
  reward_system: integer;  //=0 wenn ohen Komp, =1 wenn mit Komp
  number_of_rats:  byte;
  // rat_procedure :  array [1..max_number_of_rats] of Trat_procedure;
  ballState : TBallState;
  experiment : TExperiment;
  trial: array[1..trMAXTRIALS] of TTrial;
  trial_end, session_end: boolean;

  trial_index: integer;
  change_cage: boolean;
type
  TSendeFrame = array[0..15] of byte; // serielle Befehle an Peripherie
  TIoUnit        = record
                     I2CAdr, busNo  : byte; // Hardware Adressen
                     fct_type       : byte; // Funktionstyp
                     Pin            : array[0..3] of byte;
                   end;

  TSerFrame  =  record
                   Data               : String;
                   index              : integer;
                   frame_complete     : boolean;
                   k                  : integer;   // counter
                   current_frame_length : integer;
                   header             : string[2];
                   last_byte          : byte;
  end;

 TSendePuffer = record
                  Frame_str : String[16];
                  send_time : int64;
                  ready : boolean;
                  feeder_No, door_No: integer;
                  level: boolean
 end;
//---------------------------------------------------------------------------
// structures for coordinates that have to be sent to the graphic PCs
 TdistalLM   = record
                reLM1, reLM2, reLM3, reLM4, reLM5,reLM6: single;      //8.2.09 single statt real
 end;

 TUDPMessage = record
                rebuild: integer;
                x_landscape, y_landscape, z_landscape: single;     //8.2.09 single statt real
                arJunction: array[0..max_number_of_junctions, 1..6] of integer;
                arDistalLM: TDistalLM;
                old:boolean;
 end;
 //LB-Filter
 var
 LB_current_time:array[0..1000]of int64;
 LB_last_event_feeder: array[0..1000] of integer;
 LB_last_event_pos_rec: array[0..1000] of integer;
 n_LB,n_LB_now:integer;
 LB_wait: array[1..12] of Boolean;

 new_LB_data:array[1..12] of boolean;
 pin_nr, pin_state, byNewEventFeeder, byNewEventPos : integer;
//---------------------------------------------------------------------------
(*
//-------------------------- Kameradaten
// wird vom Mikrocontroller erledigt
  TTrack_Color   = record
                     red, green, blue: string[2];
                   end;
  TVirtual_Window = record
                      x, y, x1, y1   : byte;
                    end;
//  TShort_Frame   = array[0..10] of byte; // array[0..SHORT_FRAME_LENGTH] of byte;
*)
type
  TCam_Data      = record
                     //track          : TTrack_Color; // min und max Wert der verfolgten Farbe
                     //virtual_window : TVirtual_Window; // Eckpukte des Fensters, das ausgewertet wird
                     x, z           : integer;
                     scale_x, scale_z : real;
                     str_x, str_z   : string[3];
                     //short_frame    : TShort_Frame;
                   end;

 TVelocity_Avg   = record        // to store the last 10 velocity values for average calculation
                      vel_x_array : array[0..9] of double; //storage of previous 10 X coord velocity
                      vel_z_array : array[0..9] of double; //storage of previous 10 Z coord velocity
                      array_index : byte;                  // index of array position
 end;

 TFourItemArray  = array[1..4] of double;

//------------------------ Wegaufnehmer
  TADNS_Frame    = record
                     motion         : byte;   // b7: motion, b4: overflow, b1: resolution
                     delta_x, delta_z: byte;  // von -128 bis +127 ($80.. $00.. $7F) seit dem letzten lesen
                     x, z           : integer;
                     x_prev, z_prev : integer;

                     squal          : byte;   // no. of valid frames / 4
                     //             => no. of features = sqal*4
                     //shutter_upper, shutter_lower: byte; // ADNS ref page 30 // future usage
                     //maximum_pixel  : byte;   // ADNS ref page 30 // future usage
                     //config         : byte;   // ADNS ref page 28f // future usage
                     //frame_period   : word;   // ADNS ref page 32  // future usage
		     previous_time  : int64;  // velocity calc
		     position_time  : int64;  // velocity calc
		     previous_x     : integer;// previous x coordinate
		     previous_z     : integer;// previous z coordinate
                     velocity_avg   : TVelocity_Avg; // Storage of previous 10 velocity values
                     // frame rate  = clk freq / register value
                     vx, vz : real;
                   end;

// f¸r LS Tiefpaﬂ - gerade nicht verwendet, noch anzupassen
// Unit3: LB_data_filter
 TLB_TimeValues_Data     = record // for storing the times of activated LB
                                  // of both LB_sphere and LB_cage and
                                  // determining data to retain or disregard.
            period_start   : int64;  //start time (high signal)
            period_stop    : int64;  //stop time  (low signal)
            period_min     : int64;  //(high|low) time + min period length
            phase_value    : byte;   //(0,1,2,3) for state calculation
            reward_given   : boolean;//(T/F) was reward given?
            write_data     : boolean;//(T/F) flag for writing data
            write_starttime: int64;  //high signal to be written
            write_stoptime : int64;  //low signal to be written
           end;

  TOpenField = record
                     x, z : real;
                     rat_x, rat_z : real;
                     next_x, next_z : real;
                     radius : real;
                     on_field : boolean;
  end;

var
  cam_data             : TCAM_Data;
  xy_Data              : array[1..2] of TADNS_Frame;    // stores sensor coordinates
  xy_Data_prev         : array[1..2] of TADNS_Frame;    // stores previous sensor coordinates
  SerFrame             : TSerFrame;
  SerFrameCam          : TSerFrame;
  sende_puffer         : array[0..MAX_IO_CHANNELS-1] of TSendePuffer;
  //previous_action      : array[0..4] of integer;
  timer_start          : boolean;
  dummy_str            : string;

  open_field           : TOpenField;
  landscape            : TVector;
  d_corridor           : TVector;

  udpSendMsg, udpRecMsg: TUDPMessage;

  available_data       : boolean;   // true|false if new data available
  last_event_feeder    : integer;      // unit 1-6
  previous_feeder : integer;
  last_event_pos       : integer;      // LB 1|4 : 1=sphere, 4=cage
  state                : integer;      // 0-low |1-high
  signal_time          : int64;     // time of signal (millisecs)
  index_serial         : integer;

  reward               : integer;     // is 1 in data file in case of reward
  Reward_Rec           : array[1..max_number_of_rats] of TReward_Junction; // ???

  TrEinheit            : array [1..6]  of TTrEinheit;
  file_created         : boolean;
  FLAG_VMAZE_COORD     : boolean;


     alpha             : real;      {Gangrichtung}
     x_comp_point, z_comp_point : real;

     cam_x_kor, cam_z_kor : integer;

     new_animal_position: Boolean;  {wird in der Prozedur get_animal_position ÅberprÅft}
     x_z_animal_landscape:string;   //wird so von Bildschirmrechnern erwartet
     y_shift_up        :boolean;     //wenn true, wird der y-Wert wieder auf 0.0 gesetzt
     { Laby}
     position_in_duct  : Real;  {animal position in duct, x' co-ordinate}
     length_of_duct    : Real;     {length in units of incremental steps}
     d_motor_x, d_motor_z: double; {uk berechnete Werte fÅr die Motoren, ohne }
                                 {VerstÑrkungsfaktor oder Ñhnliches}
     {Kugel}
     x_moving_junction : Integer;         {Verschiebefaktor der Kreuzungsmittelpunkte fÅr landscape}
     z_moving_junction : Integer;         {Verschiebefaktor der Kreuzungsmittelpunkte fÅr landscape}
     junction_id_vm,lm1_vm,lm2_vm,lm3_vm,lm4_vm: single; {Landmarkeninformationen f¸r Landscape}

    //Variablen aus map and wars
    Ganglaenge, halbe_Ganglaenge,  Wandhoehe: double;
    const
    Gang_Endverlaengerung = 14 ;
    var
    Radius, kg, gg : double;
    local_lm_Radius: double;
    distal_lm_Radius: double;
    distal_lm_width: integer;

    Y_Mittelpunkt_x,Y_Mittelpunkt_z: real;
    V_x, V_z:double; //Verschiebefaktor x und Verschiebefaktor y
    
    obere_Wandhoehe, missing_angle: integer;
    Y_Mittelpunkt_x_round,Y_Mittelpunkt_z_round: real;
     y_center_local_lm_x, y_center_local_lm_z:real;
     y_center_distal_lm_x, y_center_distal_lm_z:real;
     reLM1_angle, reLM2_angle, reLM3_angle, reLM4_angle, reLM5_angle,reLM6_angle: real;

    const //aus map and wars
    halbe_Gangbreite = 15;
    local_lm_height = 4 ;//14.11.09 4.8;  //7.3.09  5;
    local_lm_width = 2.5;//14.11.09 2;// 7.3.09  1;
    distal_lm_height =150;

    var  //TCP_IP
    Verbunden: Boolean;
    meldung_vom_server_x, meldung_vom_server_Z:integer;
    meldung_vom_server_global:string;
    min_pixel_int: integer;
    min_pixel_str: string;
    MaxGrayValue: string;
    MinGrayValue: string;

    //zum Testen 2.8.
    changed_junction: boolean;

  implementation

begin
end.
