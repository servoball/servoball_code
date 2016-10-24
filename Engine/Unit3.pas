unit Unit3;  //Belohnungssreuerung

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Global_Variables, mmsystem, Math, lakutpu,
  BasicFunctions, Unit4, TypInfo, ExtCtrls;


    procedure reset_SerialData_signal;
    procedure init_reward_junctions;
    procedure reward_signal_check;
    procedure ReadSer(serial_char: char; var SerFrame: TSerFrame);
    Procedure Process_IoPin_Data(signalFeeder, signalPos: integer);
    Procedure Reset_LB_Data;


type
  TForm3 = class(TForm)
    OptSensor1_label: TLabel;
    OptSensor2_label: TLabel;
    Camera_label: TLabel;
    Edit_Weg1_xy: TEdit;
    Edit_Weg2_xy: TEdit;
    Edit_Cam_xz: TEdit;
    Edit_Weg1_squal: TEdit;
    Edit_Weg2_squal: TEdit;
    Squal1: TLabel;
    Squal2: TLabel;
    Velocity_label: TLabel;
    Sens1_avg_label: TLabel;
    Sens2_avg_label: TLabel;
    Sens1_average_value: TLabel;
    Sens2_average_value: TLabel;
    Coord_Scaled: TEdit;
    Edit_Choice: TEdit;
    Edit_expState: TEdit;
    Label1: TLabel;
    current_junction_in_Maze_junction: TLabeledEdit;
    current_junction_coordinates_in_Maze_junction: TLabeledEdit;
    current_junction_in_Maze_corridor: TLabeledEdit;
    current_junction_in_get_Vmaze_coord: TLabeledEdit;
    current_junction_coordinates_in_get_Vmaze_coord: TLabeledEdit;
    poy_Y: TLabeledEdit;
    procedure CloseButtonClick(Sender: TObject);
    procedure poy_YChange(Sender: TObject);
   


  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form3: TForm3;



implementation
// **************************************************************** //
procedure init_reward_junctions;
var
   ji  : byte;  //counter
begin
   // Initializing a simple Y maze in which the rat first steps onto the sphere
   // in the center of the 'Y' shape, called Junction 1. There are 4 total junctions.
   // 4 is to the 'south', 3 is the left handed slope, 2 is the right handed slope
   // (counting clockwise). Junction = J. Duct = D.
   // \ J3 \   / J2 /
   //  \ D2 \ / D1 /
   //   \   J1   /
   //     | D3 |
   //     | J4 |
   for ji := 1 to max_number_of_rats do
   begin
      Reward_Rec[ji].reward_feeder_arr[2] := ((ji+2)mod 6);
      Reward_Rec[ji].reward_feeder_arr[3] := ((ji-2)mod 6);
      Reward_Rec[ji].reward_feeder_arr[4] := ji;
   end; //end for (ji)
end;

procedure reward_training_VM; // Belohnungsprozedur bei Kompensation
var
   allowed, correct: boolean;
   time_execute: int64;
   feeder: integer;
begin
     if reward_rec[1].prev_reward_junct <> current_junction then
        allowed := TRUE else
        allowed := FALSE;

     if reward_rec[1].reward_feeder_arr[current_junction]= last_event_feeder then
        correct := TRUE else
        correct := FALSE;

     feeder:= last_event_feeder;
     if allowed and correct then
     begin
           time_execute := signal_time + TrEinheit[feeder].feeder_duration[0] ;
             // Reset the rewarded junction to the current one.
           Reward_Rec[1].prev_reward_junct := current_junction;
           // Increments the reward counts by current_junction and feeder unit
           inc(Reward_Rec[ballState.current_rat].reward_count_arr[current_junction]);
           dummy_str := dummy_str + 'reward given at feeder'+ IntToStr(feeder)+
                        ' in junction '+ IntToStr(current_junction);
     end;
end;

procedure reward_training;
var
   allowed, correct: boolean;
   time_execute: int64;
   feeder: integer;
begin
     feeder:= last_event_feeder;

     if experiment.available_feeder[feeder] and experiment.available_feeder[previous_feeder] then
        allowed:= TRUE else
        allowed:= FALSE;

     if feeder <> previous_feeder then
        correct:= TRUE else
        correct:= FALSE;

     if experiment.available_feeder[feeder] then
        previous_feeder:= feeder; // store previous feeder no.

     if allowed and correct then
     begin
           time_execute := signal_time + TrEinheit[feeder].feeder_duration[0] ;

           // Turn on the feeder.
           // Reset the rewarded junction to the current one.
           Reward_Rec[1].prev_reward_junct := current_junction;
           // Increments the reward counts by current_junction and feeder unit
           inc(Reward_Rec[ballState.current_rat].reward_count_arr[current_junction]);
//           inc(Reward_Rec[rat_rec.current_rat].feeder_count_arr[(Reward_Rec[rat_num].reward_feeder_arr[current_junction])]);

           dummy_str := dummy_str + 'reward given at feeder'+ IntToStr(feeder)+
                        ' in junction '+ IntToStr(current_junction);
     end;
end;
 ///////////////////////////////////////////////////////
function check_trial_end(current_time: Int64): boolean;
begin
//die Endkreuzung wurde erreicht und in der Endkreuzung ist eine best. Zeit verstrichen
// das ist wichtig, wenn die Endkreuzung eine belohnte Kreuzung ist
// evtl noch die Fälle auftrennen: Endkreuzung = belohnt und Endkreuzung <> belohnt

     if (current_junction= trial[trial_index].end_j) and
        (current_time- current_junction_enter_time> trDELAYENDJ) then
         check_trial_end:= TRUE else
         check_trial_end:= FALSE;

end;

procedure doReward(feeder_No: integer);
var
      current_time, time_execute: int64;
      level: boolean;
      feeder_pin: integer;
begin
     current_time:= TimeGetTime;
     time_execute := current_time + TrEinheit[feeder_No].feeder_duration[0] ;
     feeder_pin:= TrEinheit[feeder_No].adresse[0];
          // Turn on the feeder.
          send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                              feeder_code, (feeder_pin or $80),
                              0, signal_time, feeder_No, MAX_TR_EINHEITEN+1, TRUE);
          TrEinheit[ballState.current_rat].feeder_active[feeder_No]:= TRUE;
          // Turn it off at time_execute.
          send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                              feeder_code, (feeder_pin or $00),
                              0, time_execute, feeder_No, MAX_TR_EINHEITEN+1, FALSE);
end;

procedure reward_trial(iEventFeeder: integer; iEventPos: integer);
var
   rew_j, rew_f: boolean;
   j_index, feeder: integer;
   i: integer;
   prev, allowed,allowed_junction: boolean;

   current_time: int64;


begin
     // feeder:= last_event_feeder;
     allowed :=false;
     allowed_junction:=false;

     if trial[trial_index].trialjunction[current_junction].feeder[iEventFeeder]=1 then
     begin
        allowed:= TRUE;
        //trial[trial_index].trialjunction[current_junction].feeder[iEventFeeder]:= 0;
     end;
   // nur in einer Kreuzung belohnen
   if maze_state= st_JUNCTION then allowed_junction:=true;
   // nur 1x pro Trial belohnen

    if allowed and allowed_junction and (not trial[trial_index].reward_current_trial)
       and (y_animal_landscape=0)// 15.5.09
     then
    begin
         doReward(iEventFeeder);
         // Belohnung speichern, damit trial zu Ende geht
         trial[trial_index].reward_current_trial:= TRUE;
         dummy_str := dummy_str + 'reward at feeder'+ IntToStr(iEventFeeder)+
                        ' in junction '+ IntToStr(current_junction);
     end;

 // Zeitstrafe bei falscher TränkenLichtschrankenunterbrechung in der Zielkreuzung 29.6.09
   current_time:= TimeGetTime;
   if
    (( allowed_junction = true)             //gilt nur für Kreuzungen, nicht Gang
       and  (y_animal_landscape=0)
       and  (current_junction=  trial[trial_index].end_j   )  // nur in Endkreuzung, evtl auch  für alle Kreuzungen
       and not ( trial[trial_index].trialjunction[current_junction].feeder[iEventFeeder]=1)
       and   (not trial[trial_index].reward_current_trial)
       )
       then begin  // zeitstrafe bei falscher Tränke
                         ballstate.reset_maze:=true;
                         ballstate.reset_time:=  current_time+ 5000+15000;//10000;
                         //udpSendMsg.rebuild:=1;  //muss noch nach dem senden auf false gesetzt werden
                         y_animal_landscape:=25;//14.3.09 jetzt hier nicht mehr in test_maze
                         X_Y_Z_send_koordinates:=true;//15.5.09
            end;
end;

 /////////////////////////////////////////////////
// **************************************************************** //
// reward_signal_check
//     This procedure checks to make sure that the current junction has a valid
//     reward feeder and that the feeder from which the signal originates from
//     is the correct feeder to provide the reward.
procedure reward_signal_check;
var
    signal_feeder : byte;
    rat_num       : byte;
    flagF         : boolean;
begin
    signal_feeder := last_event_feeder;    //The feeder where signal originated.
    rat_num       := ballState.current_rat;  //Current rat.

    // Checking if initialized reward feeder is the same as signal originator feeder.
    if ( signal_feeder = Reward_Rec[rat_num].reward_feeder_arr[current_junction] ) then
        flagF := true;
    // If feeders match by junction, then call subroutine to give the reward.
    if flagF then begin
       // hier Belohnungsprozedur aufrufen ******************************
    end else begin // Otherwise, increment attempt signal.
        inc(Reward_Rec[rat_num].feeder_attempt_arr[(Reward_Rec[rat_num].reward_feeder_arr[current_junction])]);
    end; //end if then else.
end;  //end procedure reward_signal_check();

// **************************************************************** //
// reset_SerialData_signal
//   This procedure will reset the variables set by Serial Data:
//   (available_data, last_event_feeder, last_event_pos, signal_time).
procedure reset_SerialData_signal;
begin
  available_data    := FALSE;
  last_event_feeder := 0;
  last_event_pos    := 0;
  signal_time       := 0;
end; //end procedure reset_SerialData_signal.
procedure Add_path_Data(SerFrame : TSerFrame);
var
    i : integer;
    dummy_string : string;
    vel_values : TFourItemArray;
    sum1, sum2 : integer;
begin
try

if length(SerFrame.Data) = SENSOR_FRAME_LENGTH then
begin
     // hier werden die Daten des ersten Wegaufnehmers eingefügt

            xy_Data_prev[2]:= xy_Data[2];

            xy_Data[2].x := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            xy_Data[2].z := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            xy_Data[2].squal := byte(SerFrame.Data[1]); // shl 8 + byte(SerFrame.Data[2]);
//            Delete(SerFrame.Data, 1, 2);
            Delete(SerFrame.Data, 1, 1);
            xy_Data[2].position_time := TimeGetTime;

     // hier werden die Daten des zweiten Wegaufnehmers eingefügt
            xy_Data_prev[1]:= xy_Data[1];

            xy_Data[1].x := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            xy_Data[1].z := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            xy_Data[1].squal := byte(SerFrame.Data[1]); // shl 8 + byte(SerFrame.Data[2]);
//            Delete(SerFrame.Data, 1, 2);
            Delete(SerFrame.Data, 1, 1);
            xy_Data[1].position_time := TimeGetTime;

     // hier werden die Kameradaten eingefügt

//            velocity_calculation( vel_values );

            sum1 := xy_Data[1].x + xy_Data[1].z;
            sum2 := xy_Data[2].x + xy_Data[2].z;

            if (sum1 = 0) or (sum2 = 0) then
            begin
               xy_Data[1]:= xy_Data_prev[1];
               xy_Data[2]:= xy_Data_prev[2];
            end;
            // set the flag which tells that new data is available
            FLAG_VMAZE_COORD := TRUE;
end;
except
showmessage('error in add cam data');
end;
end;

procedure Add_IoPin_Data(SerFrame : TSerFrame);
var i, j, n : integer;
  //global  pin_nr, pin_state, byNewEventFeeder, byNewEventPos : integer;
    current_time : int64;
    other_pin: boolean;
begin
  current_time := TimeGetTime;
  other_pin:= FALSE;

  pin_nr := byte(SerFrame.Data[4]) and $7F; // $7F = %01111111;
  pin_state := byte(SerFrame.Data[4]) shr 7;

  for i := 1 to MAX_TR_EINHEITEN do // i: check all feeding units
    for j := 0 to 4 do // j: reads the pin no. -> ReadIOConfig
      if (TrEinheit[i].adresse[j]= pin_nr) then
      begin
        byNewEventFeeder:= i;
        byNewEventPos   := j;
       end;
       
        if pin_state=1 then
        begin

         if ((byNewEventPos= 1) and (byNewEventFeeder=1)) then   begin  LB_current_time[1] := current_time; lb_wait[1]:=true;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=2)) then   begin  LB_current_time[2] := current_time; lb_wait[2]:=true;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=3)) then   begin  LB_current_time[3] := current_time; lb_wait[3]:=true;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=4)) then   begin  LB_current_time[4] := current_time; lb_wait[4]:=true;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=5)) then   begin  LB_current_time[5] := current_time; lb_wait[5]:=true;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=6)) then   begin  LB_current_time[6] := current_time; lb_wait[6]:=true;end;

         if ((byNewEventPos= 4) and (byNewEventFeeder=1)) then   begin  LB_current_time[7] := current_time; lb_wait[7]:=true;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=2)) then   begin  LB_current_time[8] := current_time; lb_wait[8]:=true;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=3)) then   begin  LB_current_time[9] := current_time; lb_wait[9]:=true;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=4)) then   begin  LB_current_time[10] := current_time; lb_wait[10]:=true;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=5)) then   begin  LB_current_time[11] := current_time; lb_wait[11]:=true;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=6)) then   begin  LB_current_time[12] := current_time; lb_wait[12]:=true;end;
         
        end ;

        if pin_state=0 then //pin_state=0 d.h.  Signal aus
         begin
         if ((byNewEventPos= 1) and (byNewEventFeeder=1)) then   begin   lb_wait[1]:=false;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=2)) then   begin   lb_wait[2]:=false;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=3)) then   begin   lb_wait[3]:=false;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=4)) then   begin   lb_wait[4]:=false;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=5)) then   begin   lb_wait[5]:=false;end;
         if ((byNewEventPos= 1) and (byNewEventFeeder=6)) then   begin   lb_wait[6]:=false;end;

         if ((byNewEventPos= 4) and (byNewEventFeeder=1)) then   begin   lb_wait[7]:=false;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=2)) then   begin   lb_wait[8]:=false;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=3)) then   begin   lb_wait[9]:=false;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=4)) then   begin   lb_wait[10]:=false;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=5)) then   begin   lb_wait[11]:=false;end;
         if ((byNewEventPos= 4) and (byNewEventFeeder=6)) then   begin   lb_wait[12]:=false;end;
         end;
         //showmessage ((' new_LB_data ')+inttostr(i)+booltostr(new_LB_data[i]));

     for n:= 1 to 12 do
       if lb_wait[i]= TRUE then other_pin:= TRUE;
     if not other_pin then Process_IoPin_Data(byNewEventFeeder, byNewEventPos) ;      // wenn kein LB-Pin: ohne Filter weitermachen wie bisher


  end;
 ///////////////////////////////////////////////
 Procedure Reset_LB_Data;

 begin     //setzt nach Filtereingriff die Pins zurück auf "kein Signal"
    byNewEventFeeder:= -1;
    byNewEventPos   := -1;
    last_event_feeder:= -1;
    last_event_pos:= -1;
 end;
 ///////////////////////////////////////
 Procedure Process_IoPin_Data(signalFeeder: integer; signalPos: integer);
 var
 current_time : int64;

begin
  current_time := TimeGetTime;

    try

    // wenn Ventil-LS ein Signal sendet
   if signalPos= 1 then
      reward_trial(signalFeeder, signalPos);

  if (signalPos= 1) or (signalPos=0) then // *process only LB1 and feeder
  begin
    available_data := TRUE;
    last_event_feeder := signalFeeder;              // store current feeder no.
    last_event_pos := signalPos;
    state := pin_state;
    if (signalPos=0) and (state=1) then // only data file
      reward:= 1 else
      reward:= 0;

    signal_time := current_time;
  end; // if (signalPos= 1) or (signalPos=0)

  if (signalPos= 4) and (signalFeeder= ballState.current_rat) then begin     // *process  LB cage (4)
    ballState.on_sphere:= false;
  end;

  except
  showmessage('error in add io pin data');
  end;

  save_data_to_output_file(current_time);
  dummy_str := dummy_str+ 'Pin: '+ IntToStr(pin_nr)+ ' state '+ IntToStr(pin_state)
               + ' event pos= ' + IntToStr(last_event_pos)
               + ' available: '+ BoolToStr(available_data)+ #13+ #10;
  last_event_feeder:= -1;
  last_event_pos:= -1;
  reward:= -1;
  state:= -1;
end;

////////////////////////////////////////////////////////////////////////////////

  /////

procedure ReadSer(serial_char: char; var SerFrame: TSerFrame);
var
   header_word : word;
begin
with SerFrame do
begin
  header_word := (word(last_byte) shl 8)+ byte(serial_char) ;
  last_byte := byte(serial_char);
//  form1.Memo_Empfang.Lines.Add(' new header = '+ inttohex( integer(header_word), 4 ));

  if (header_word = HEADER_IO_PIN) or (header_word = HEADER_SENSOR) then
  begin
       Data := ''; // erase previous data
       case header_word of
            HEADER_SENSOR: current_frame_length := SENSOR_FRAME_LENGTH;
            HEADER_IO_PIN: current_frame_length := PERIPHERY_FRAME_LENGTH;
       end; // case
  end
     else
  begin
       Data := Data+ serial_char;
       if Length(Data) = current_frame_length then
       begin
            case current_frame_length of
                 SENSOR_FRAME_LENGTH : Add_path_Data(SerFrame);
                 PERIPHERY_FRAME_LENGTH :  Add_IoPin_Data(SerFrame);
            end;
       end;
  end;
end; // with SerFrame do

end;


procedure TForm3.CloseButtonClick(Sender: TObject);
begin
    Form3.Close;
end;





procedure TForm3.poy_YChange(Sender: TObject);
begin
form3.poy_Y.Text:=floattostr(y_animal_landscape);
end;

end.
