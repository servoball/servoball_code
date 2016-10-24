unit Filter_Reward;

interface
uses global_variables, Unit3, mmsystem, setup;

type
        TReward_Junction = record
                reward_feeder_arr : array[1..max_number_of_junctions] of byte;
                reward_count_arr  : array[1..max_number_of_junctions] of integer;
                prev_reward_junct : byte;
        end;

var
        reward_rec : array[1..max_number_of_rats] of TReward_Junction;

 procedure Test_Procedure;

implementation

// **************************************************************** //
// init_reward_junctions
//    This procedure sets the junctions that contain a reward feeder.
//    The record that contains this information is Reward_Rec, with
//       the variable reward_feeder_arr.
//    (Assuming a junction has a maximum of 1 reward feeder.)
//    Should call this procedure once when program begins.
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

// **************************************************************** //
// reward_alternating_check
//     This procedure performs the check for an alternating reward system. It
//     will see if the previously rewarded junction is the same as the current
//     junction.  (Assumes that each junction can have a maximum of one rewarding
//     feeder and that other details are already checked.)
procedure reward_alternating_check( rewardfeeder, rat_num : byte );
var
    flag1        : boolean;
    flag2        : boolean;
    current_time : int64;
    time_execute : int64;
begin
        // Check if the previous reward junction is the current one the signal is from.
        // If it is different, set flag to true.
        if (Reward_Rec[rat_num].prev_reward_junct <> junction_id) then
            flag1 := true;
        // If signal is from a different junction than previous rewarding junction,
        // then give the reward.
        if flag1 then
        begin
           current_time := TimeGetTime;
           time_execute := current_time + TrEinheit[rewardfeeder].feeder_duration[0] ;

           // Turn on the feeder.
           send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                              feeder_code, (TrEinheit[rewardfeeder].adresse[1] or $80),
                              0, current_time);
           // Turn it off at time_execute.
           send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                              feeder_code, (TrEinheit[rewardfeeder].adresse[1] or $00),
                              0, time_execute);
           // Reset the rewarded junction to the current one.
           Reward_Rec[rat_num].prev_reward_junct := junction_id;
           Reward_Rec[rat_num].reward_count_arr[junction_id] := Reward_Rec[rat_num].reward_count_arr[junction_id]+1 ;
        end; // end if flag AND not same feeder
end; // end procedure reward_alternating_check().

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
    signal_feeder := SerFrame.last_event_feeder; //The feeder where signal originated.
    rat_num       := Rat_Rec.current_rat;        //Current rat.

    // Checking if initialized reward feeder is the same as signal originator feeder.
    if ( signal_feeder = Reward_Rec[rat_num].reward_feeder_arr[junction_id] ) then
        flagF := true;
    // If feeders match by junction, then call subroutine to give the reward.
    if flagF then
        reward_alternating_check(signal_feeder, rat_num);  //subroutine call.
    // Otherwise, ignore signal.
end;


// **************************************************************** //
// end_run_check
//     This function returns (true | false) regarding whether the rat should
//     end its current run on the sphere and return to its cage. The conditions
//     depend on the MAX_REWARDS or MAX_RUNTIME.
function end_run_check : boolean;
var
   reward_sum   : int64;
   current_time : int64;
   ci           : byte;
   rat_num      : byte;
begin
    current_time := TimeGetTime();  // get current time.
    reward_sum   := 0;              // initialization value.
    rat_num      := Rat_Rec.current_rat; // current rat on sphere.
    // check if end_time has passed.
    if (Rat_Rec.rat[Rat_Rec.current_rat].exit_time >= current_time) then
    begin // if max_time has been reached, return true and exit this function.
       Result := true;
       Exit;
    end;
    // check if max rewards have been given.
    for ci := 1 to max_number_of_junctions do
    begin  // first, calculate the sum of rewards.
       reward_sum := reward_sum + Reward_Rec[rat_num].reward_count_arr[ci];
    end;
    if ( reward_sum >= MAX_REWARDS ) then
    begin  // max number of rewards given, return true and exit this function.
        Result := true;
        Exit;
    end;
    // otherwise, neither exit condition has been reached. return false and exit.
    Result := false;
end; // end procedure end_run_check().

// ******************************************************************** //
// Test_Proc
procedure Test_Procedure;
var
   current_time : int64;
   max_reward_reached, max_time_reached : boolean;
begin
   max_reward_reached := false;// delete
   max_time_reached := false;// delete
   current_time := TimeGetTime;
   with Rat_Rec do
   begin
     // check if rat is on sphere already
     if (not rat[current_rat].on_sphere) then
     begin
       if not TrEinheit[current_rat].open then
       begin
        // open door to allow rat onto sphere
        door(current_rat, true, current_time);
        TrEinheit[current_rat].open := true;
       end;
       // check if rat is on sphere
       if (cam_data.x>10) and (cam_data.x<160) and (cam_data.z>10) and (cam_data.z<160) then
       begin  // rat is on the sphere - "running"
          // close the door
          door(current_rat, false, current_time);
          // set rat variables
          TrEinheit[current_rat].open := false;
          rat[current_rat].on_sphere := true;
          // initialize the reward junctions
          init_reward_junctions; //procedure.
          // set enter and exit times
          rat[current_rat].enter_time := current_time;
          rat[current_rat].exit_time  := current_time + MAX_RUNTIME;
       end; // end if (cam_data)
     end; // end if !(rat.on_sphere)

     // ALICE:
     // need to call [LB_data_filter] (it calls check signal & reward procedures)

     // check if should end the current rat's run on the sphere.
     if end_run_check then
     begin  // check if door is already open.
       if not TrEinheit[current_rat].open then
       begin // open the door
         door(current_rat, true, current_time);
         TrEinheit[current_rat].open := true;
       end;
       if (TrEinheit[current_rat].adresse[4]= 1) then
       begin
         door(current_rat, false, current_time);
         TrEinheit[current_rat].open := false;
         rat[current_rat].on_sphere  := false;
         // check if last rat, increment accordingly.
         if current_rat >= 6 then
            current_rat := 1
         else
            inc(current_rat);
       end; // if (TrEinheit[current_rat].adresse[4]= 1) then
     end; // if end_run_check then
   end; // with Rat_Rec do
end; // end Test_Proc.


// uses global_variables;
// **************************************************************** //
// reset_data_signal
//   This procedure will reset the SerFrame variables:
//   (available_data, last_event_feeder, last_event_pos, signal_time).
procedure reset_data_signal;
begin
   With SerFrame do
   begin
       available_data    := false;
       last_event_feeder := 0;
       last_event_pos    := 0;
       signal_time       := 0;
   end;
end; //end procedure reset_data_signal.

// **************************************************************** //
// LB_check_signal
//   This procedure will filter the incoming Light-Barrier (LB) data,
//   checking that the barrier is blocked for a minimum time period.
//   After an appropriate signal is observed, incoming signals will
//   be discarded/ignored until a maximum time period has passed.
//   The constants that determine the minimum and maximum time periods
//   are DATA_MIN_PERIOD & DATA_MAX_PERIOD.
procedure LB_check_signal;
begin
   With TrEinheit[SerFrame.last_event_feeder].LB_time_data[SerFrame.last_event_pos] do
   begin
      //High signal
      if (SerFrame.state = 1) then  //state = 1 is high
      begin
         Case phase_value of
           0  : begin
                 period_start := SerFrame.signal_time;
                 period_min   := (period_start + DATA_MIN_PERIOD);
                 phase_value  := 1;
                 reset_data_signal; //procedure call.
                end; //end Case <0>
           1  : begin
                 if (period_stop = 0) or (period_min >= SerFrame.signal_time) then
                 begin
                    period_start := SerFrame.signal_time;
                    period_min   := (period_start + DATA_MIN_PERIOD);
                 end;  //end if.
                 reset_data_signal; //procedure call.
                end; //end Case <1>
           2,3: begin
                 if (period_end < SerFrame.signal_time) then
                 begin
                    write_data  := true;
//
//
                    reward_signal_check;  //Subroutine call to give reward.
                    phase_value := 3;
                 end; //end if.
                 reset_data_signal; //procedure call.
                end; //end Case <2,3>
         else
//            ShowMessage('LB_check_signal: High signal: Incorrect Phase Value.');
         end; // Case phase_value.
      end;  // state = 1 (high signal)

      //Low signal
      if (SerFrame.state = 0) then //state = 0 is low
      begin
         Case phase_value of
           0  : begin
                 reset_data_signal; //procedure call.
                end; //end Case <0>
           1  : begin
                 if (period_min <= SerFrame.signal_time) then
                 begin
                    period_stop := SerFrame.signal_time;
                    period_end  := (period_stop + DATA_MAX_PERIOD);
                    phase_value := 2;
                 end else // (period_min > SerFrame.signal_time)
                 begin
                    period_start := 0;
                    period_min   := 0;
                    phase_value  := 0;
                 end; // end if then else.
                 reset_data_signal; //procedure call.
                end; //end Case <1>
           2,3: begin
                 if (period_end >= SerFrame.signal_time) then
                 begin
                    period_stop := SerFrame.signal_time;
                 end else // (period_end < SerFrame.signal_time)
                 begin
                    write_data  := true;
//
//
                    reward_signal_check;  //Subroutine call for reward
                    phase_value := 3;
                 end; // end if then else.
                 reset_data_signal; //procedure call.
                end; //end Case <2,3>
         else
//            ShowMessage('LB_check_signal: Low signal: Incorrect Phase Value.');
         end; // Case phase_value.
      end;  // state = 0 (low signal)
    end; // With TrEinheit[].LB_time_data[].
end;  // end procedure LB_check_signal.


// **************************************************************** //
// LB_data_filter
//   This procedure will check for new data. If none is available, it will
//   check if the maximum time pause has passed for data to be written.
procedure LB_data_filter;
var
   time_current : int64;
   unitcount    : byte;
   lb           : byte;
begin
 // New data is available, process in LB_check_signal.
 if SerFrame.available_data then
   begin
      LB_check_signal; //procedure call to check this signal.
   end //if available_data = true.
 // Otherwise, no new data is availabe for processing.
 // Check each unit's two LBs and see if max time period has passed.
 // If so, change write_data to true and phase_value to 3.
 else
 begin
   time_current := TimeGetTime();
   for unitcount := 1 to MAX_TR_EINHEITEN do
   begin
      With TrEinheit[unitcount] do
      begin
         lb := 1;
         While ((lb = 1) or (lb = 4)) and (LB_time_data[lb].phase_value = 2) do
         begin
            if (time_current > LB_time_data[lb].period_end) then
            begin
               LB_time_data[lb].write_data  := true;
               LB_time_data[lb].phase_value := 3;
            end; //end if time_current > period_end.
            lb:= lb+3;
         end; //While loop.
      end; //With TrEinheit[unit].
   end; //for loop (unit).
 end; //if no new signal.
end; //end procedure LB_data_filter.


end.
