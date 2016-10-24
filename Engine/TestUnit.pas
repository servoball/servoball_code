unit TestUnit;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Global_Variables, mmsystem, Math, lakutpu,
  BasicFunctions, Unit4, TypInfo;

  procedure resetUDPLandscape;
  procedure runExperiment;
 


implementation

procedure resetUDPLandscape;
var
   i, j: integer;
begin
try
     reset_landscape:=true;
     i:= trial[trial_index].start_j;

     udpSendMsg.x_landscape:=  junction[i].x_junction;

     udpSendMsg.z_landscape:=  junction[i].z_junction;

   (*
     showmessage (('resetudpLandscape  junction:')+(inttostr(i))+(' ')+
     (floattostr( junction[i].x_junction))+('  ')+
     (floattostr( junction[i].z_junction)));
    *)

     for j:=0 to trMAXJUNCTIONS do
     begin
               //Spalten: Kreuzungen, Zeilen: Landmarken 0-6
               udpSendMsg.arJunction[j,1]:=  trial[trial_index].trialjunction[j].local_lm_junction[1];
               udpSendMsg.arJunction[j,2]:=  trial[trial_index].trialjunction[j].local_lm_junction[2];
               udpSendMsg.arJunction[j,3]:=  trial[trial_index].trialjunction[j].local_lm_junction[3];
               udpSendMsg.arJunction[j,4]:=  trial[trial_index].trialjunction[j].local_lm_junction[4];
               udpSendMsg.arJunction[j,5]:=  trial[trial_index].trialjunction[j].local_lm_junction[5];
               udpSendMsg.arJunction[j,6]:=  trial[trial_index].trialjunction[j].local_lm_junction[6];
      end;

      llm_colour:=trial[trial_index].llm;

      udpSendMsg.arDistalLM.reLM1:= trial[trial_index].distal_lm[1];
      udpSendMsg.arDistalLM.reLM2:= trial[trial_index].distal_lm[2];
      udpSendMsg.arDistalLM.reLM3:= trial[trial_index].distal_lm[3];
      udpSendMsg.arDistalLM.reLM4:= trial[trial_index].distal_lm[4];
      udpSendMsg.arDistalLM.reLM5:= trial[trial_index].distal_lm[5];
      udpSendMsg.arDistalLM.reLM6:= trial[trial_index].distal_lm[6];
except
      showmessage('error in resetUDPLandscape');
end;
 
end;

procedure init_first_run;
begin
          current_junction:= trial[trial_index].start_j;
          udpSendMsg.rebuild:=1;  //muss noch nach dem senden auf false gesetzt werden
          resetUDPLandscape;
          ballState.current_rat:= trial[trial_index].cage;
          exp_state:= expSTART;
end;




procedure trial_end_and_start_next_trial(current_time: int64);
var
    j: integer;
    delay_time: integer;
begin


     inc(trial_index);
     inc(trial[trial_index].index);

     current_junction:= trial[trial_index].start_j;

     ballState.reset_maze:= true;
     delay_time:= DELAY_RESET;         //kurze Pause bei richtigem Ende

     if wrong_end= true then
        begin
        wrong_end:= false;
        delay_time:= DELAY_RESET + 10000;   //lange Pause bei falschem Ende,
        // showmessage('');

        dec(trial_index);              //20.6.09
        dec(trial[trial_index].index); //20.6.09

        end;

     ballState.reset_time:= current_time+ delay_time;//13.3.09DELAY_RESET;

     udpSendMsg.rebuild:=1;  //muss noch nach dem senden auf false gesetzt werden
     resetUDPLandscape;

end;

procedure session_end_and_start_next_session;
begin
     //  Trials überspringen, wenn Zeit um ist, bevor alle Trials der Session absolviert wurden
  {   if trial[trial_index].cage = trial[trial_index-1].cage then // Zeit um, aber nächste Käfignr. gleich }
        while trial[trial_index].cage = trial[trial_index-1].cage do
             inc(trial_index);
     ballState.exit_time:= ballState.exit_time + MAX_RUNTIME;
     ballState.current_rat:= trial[trial_index].cage;
     udpSendMsg.rebuild:=1;  //muss noch nach dem senden auf false gesetzt werden
     resetUDPLandscape;
end;

function check_for_trial_end: boolean;
var
   reached_end_j: boolean;
   got_reward:    boolean;
   min_time_in_j: boolean;
   current_time: int64;
begin
     current_time:= TimeGetTime;
     if current_junction= trial[trial_index].end_j then
        reached_end_j:= TRUE else
        reached_end_j:= FALSE;
     got_reward:= trial[trial_index].reward_current_trial;

     if got_reward then
        begin
           y_animal_landscape:=25;//14.3.09 jetzt hier nicht mehr in test_maze
           X_Y_Z_send_koordinates:=true;//15.5.09
        end;
        
     if current_time- current_junction_enter_time> trDELAYENDJ then
        min_time_in_j:= TRUE else
        min_time_in_j:= FALSE;

     if  ((current_junction>1)and           //13.3.09
          (current_junction<> trial[trial_index].start_j)and  // 20.6.09
          (current_junction <> trial[trial_index].end_j))
                        then begin
                        wrong_end:=true;
                        //y_animal_landscape:=25;
                        save_data_to_output_file(current_time);//15.5.09
                        y_animal_landscape:=25;    //12.12.09 erst Daten speichern, dann y auf 25 setzen: diese 2 Zeilen vertauscht
                        end;



     if ((reached_end_j and got_reward and
                       ballState.center and min_time_in_j)


        or( (current_junction<> trial[trial_index].start_j)and  // 20.6.09
                         (current_junction > 1)and            //10.3.09
                        (current_junction <> trial[trial_index].end_j)) )

         then   result:= TRUE
                
         else
                 Result:= FALSE;


end;

function check_for_session_end: boolean;
// if max_time has been reached, return true and exit this function.
var
   current_time: int64;
begin
     current_time:= TimeGetTime;
     if (current_time > ballState.exit_time) then
        Result:= TRUE else
        Result:= FALSE;
end;

function check_for_last_trial: boolean;
begin
     if (trial[trial_index].cage <> trial[trial_index+1].cage) then
        Result:= TRUE else
        Result:= FALSE;
end;

function experiment_start(current_time: int64): boolean;
begin
  Result:= FALSE;

  // the door is closed and cam sees an animal on the ball -> sth goes wrong
  if ballState.detected and (not TrEinheit[ballState.current_rat].open) then //ballState.detected =cam detected
    Result := FALSE;

  // if not already done, open the door
  if not TrEinheit[ballState.current_rat].open then // check door state
  begin

    door(ballState.current_rat, true, current_time+ DOOR_CHANGE_DELAY); // open door to allow rat onto sphere
    TrEinheit[ballState.current_rat].open := TRUE;   // store door state
    ballState.enter_time := current_time; // set enter time
    ballState.exit_time  := current_time + MAX_RUNTIME; // set exit time
  end;

  // close door when rat reaches the center of the ball
  //ballState.center= camera, inner circle, TrEinheit[ballState.current_rat].open= door state of the current cage = open then...
  if ballState.center and TrEinheit[ballState.current_rat].open then
  begin
    door(ballState.current_rat, false, current_time); // close the door
    TrEinheit[ballState.current_rat].open := false;   // store door state
    ballState.on_sphere := true;                      // rat is on the ball, ballState.on_sphere= false if lb_cage is interrupted
    ballState.reset_maze:= TRUE;
    Result:= TRUE;
  end; // if ballState.center and TrEinheit[ballState.current_rat].open
end;

function experiment_running(current_time: int64): boolean;
begin
     Result:= TRUE;
    (*2.2.09
     if not ballState.on_sphere then       //LB cage
     begin
       Result:= FALSE;
       maze_state:= st_NIX; // do not move the sphere
       Session_control:='button ball_control_ok drücken';
       if ball_control_ok = true
       then begin
               
                ball_control_ok:=false;
                Result:= TRUE;
                end;

     end;
     *)
end;

function experiment_gohome(current_time: int64): boolean;
begin
     Result:= FALSE;
     // if not already done, open the door
     if not TrEinheit[ballState.current_rat].open then
     begin
       door(ballState.current_rat, true, current_time); // open the door
       TrEinheit[ballState.current_rat].open := true;   // store door state
     end;

     // close door when rat gets detected in the cage
     if (not ballState.on_sphere) and TrEinheit[ballState.current_rat].open then //wenn Käfiglichtschranke unterbrochen
     begin
       door(ballState.current_rat, false, current_time); // close the door
       TrEinheit[ballState.current_rat].open := false;   // store door state
       Result:= TRUE;
     end;
end;

function experiment_wait(current_time: int64): boolean;
begin
     Result:= FALSE;

     //16.1.01
     Session_control:='button für Sessionstart drücken';
     if Session_control_ok then
       begin
       Session_control_ok:=false;
       Session_control:='';
       Result:= TRUE;
       end;
end;


procedure runExperiment;
var
   executed, last_trial: boolean;
   current_time: int64;
begin
     current_time:= TimeGetTime;
     // falls zum ersten mal ausgeführt, muss die Landschaft initialisiert werden
     if first_run then
     begin
          init_first_run;
          first_run:=false;
     end;

     trial_end:= check_for_trial_end;
     session_end:= check_for_session_end;
     last_trial:= check_for_last_trial;

     case exp_state of
       expSTART:    executed:= experiment_start(current_time);  //rat is in cage, should go on the ball
       expRUNNING:  executed:= experiment_running(current_time);
       expGOHOME:   executed:= experiment_gohome(current_time);
       expWAIT:     executed:= experiment_wait(current_time);
     end;

     case exp_state of
       expSTART:   begin
                        Session_control:='expSTART';
                        // regulärer Fall: Ratte kommt auf die Kugel und
                        // die Zeit ist noch nicht um
                        if executed and (not session_end) then
                           exp_state:= expRUNNING;
                        // Ratte noch im Käfig, Zeit abgelaufen
                        if session_end and (not executed) then
                        begin
                             if TrEinheit[ballState.current_rat].open then
                             begin
                                  door(ballState.current_rat, false, current_time); // close the door
                                  TrEinheit[ballState.current_rat].open := false;   // store door state
                             end;
                            (* exp_state:= expSTART;
                             trial_end_and_start_next_trial(current_time);
                             session_end_and_start_next_session;*)
                             exp_state:= expWAIT;
                        end;
                   end;
       expRUNNING: begin
                        // Tier im Experiment auf der Kugel
                        // Zeit ist um, bevor alle Trials abgearbeitet sind
                        Session_control:='expRUNNING';
                        if session_end then
                        begin
                             if not TrEinheit[ballState.current_rat].open then
                             begin
                                door(ballState.current_rat, TRUE, current_time); // close the door
                                TrEinheit[ballState.current_rat].open := TRUE;   // store door state
                             end;
                             exp_state:= expGOHOME;
                             //exp_state:= expWAIT;
                             maze_state:= st_NIX; // do not move the sphere
                        end;
                        // Tier im Experiment auf der Kugel
                        // Trial zu Ende, Zeit noch nicht um. Es folgt der nächste Trial
                        if trial_end and (not session_end) and (not last_trial) then
                        begin

                             trial_end_and_start_next_trial(current_time);
                        end;

                        if last_trial and trial_end then
                        begin
                             exp_state:= expGOHOME;
                             //exp_state:= expWAIT;
                             maze_state:= st_NIX; // do not move the sphere

                        end;

                   end;
       expGOHOME:  begin
                        // reguläres Ende: die Ratte ist zurück im Käfig
                        Session_control:='expGOHOME';

                        if executed then
                        begin
                         (*    trial_end_and_start_next_trial(current_time);
                            // Absturz wenn hier:  showmessage('gleich geht die nächste Tür auf: gohome 14.11.08');

                            session_end_and_start_next_session;
                            exp_state:= expSTART;
                           *)
                          exp_state:= expWAIT;
                        end;
                        // Ausnahme
                        if session_end then
                        begin
                             maze_state:= st_NIX; // do not move the sphere
                        end;
                   end;

       expWAIT: begin
                 if executed then
                        begin
                        Session_control:='expWAIT';
                        trial_end_and_start_next_trial(current_time);
                        session_end_and_start_next_session;
                        exp_state:= expSTART;
                       end;
                 end;
     end;
end;


end.
 