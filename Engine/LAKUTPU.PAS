unit lakutpu;
// ??? Erkl‰rung neu schreiben
{****************************************************************************
Die Unit Lakutpu erzeugt ein virtuelles Labyrinth aus den Informationen
einer Labyrinth-Datei, registriert die Bewegungen der Maus in diesem
Labyrinth und speichert die Laufdaten auf der Festplatte ab. Das Programm
kennt 7 verschiedene Zustaende (siehe Kommentare zum status_set). Die Be-
wegungen des Tieres werden in den Kreuzungen ueber die Positionskoordinaten
des Kamerasystems und im Gang ueber optische Wegaufnehmer gemes-
sen. Im Zustand 2 (Lauf im Gang) werden die Zaehlerstaende der Wegaufnehmer
mit Informationen zur seitlichen Abweichung der Maus aus der Gangmitte
verrechnet, da das Tier bei seitlichem Versatz nicht mehr auf einem
Grosskreis laeuft, die Kompensationsdrehungen der Motoren aber weiter auf
Grosskreisen erfolgen muessen. Laby verÑndert die globale Variable "Status"
fÅr den Unitbereich Kugel und erhaelt vom Versuchssteuerungsprogramm "versuch"
die Koordinaten des Tieres im Kamerafeld (Status 3, 5) bzw. die Koordinaten
des Kompensationspunktes auf der
Basislinie quer zum Gang (Status 2) fuer die Berechnung der Korrektur der
seitlichen Abweichung aus der Gangmitte.
Das Betreten einer Kreuzung bzw. eines Ganges wird an den Versuchsrechner
gemeldet, damit dieser eine eventuelle Belohnung oder Schaltung von Licht-
signalen vornehmen kann.
Nach Absolvierung eines Testlaufes kann das Tier virtuell wieder an den
Ausgangspunkt oder in eine beliebige andere Kreuzung teleportiert werden.
Teleportierung in die Kreuzung 0 ist gleichbedeutend mit dem Sperren aller
Ausgaenge der aktuellen Kreuzung.
Teleportierung wird vom Versuchsrechner ausgeloest und dem Labyrinthrechner
mitgeteilt. Ob der Labyrinthrechner auf Teleport-Requests reagiert, haengt
von der Variablen teleport_flag ab, die in der Labyrinthdefinitionsdatei
festgelegt wird. Eine 1 erzeugt teleport_flag=True und erlaubt Tele-
portierung.


Die Daten der Mausbewegungen werden im Format

          status;junction;exit;xd;yd;angle;hh;mm;ss;cs in der

Output-Datei abgelegt. Dabei bedeuten

status = 1: Tier wird voll kompensiert
status = 2: Tier befindet sich in einem Gang.
status = 3: Tier befindet sich in einer Endkreuzung.
status = 4: Tier wird in die Kreuzungsmitte gebracht
status = 5: Tier befindet sich in einer Kreuzung mit mehreren Ausgaengen
            oder in der Kreuzung 0 ohne Ausgaenge.
status = 6: Tier wird auf Basislinie eines Ganges gezogen
status = 7: keine Kompensation

junction = 1, 2, ...:  Kreuzungsnummer
junction = 0:          Nummer der Kreuzung ohne Ausgaenge

exit = 1, 2, ..., 6:   Nummer eines Ausganges der aktuellen Kreuzung,
                       durch den das Tier die Kreuzung verlassen hat.
exit = 0:              Tier hat noch keinen Ausgang gewaehlt.

xd, yd in status 3, 5: Tierposition in Kamerakoordinaten (Kugel aus Frank-
                       furt: 1 Einheit entspricht 45/254 = 0,17716 cm).
xd     in status 2:    Laenge der im Gang zurueckgelegten Strecke in Ein-
                       heiten der inkrementalen Wegaufnehmer (Kugel aus
                       Frankfurt: 1/15 cm)
yd     in status 2:    Abweichung des Tieres quer zur Gangrichtung in
                       Einheiten der Kamerakoordinaten (Kugel aus Frank-
                       furt: 0,17716 cm).

angle:                 im Status 2 die Gangrichtung in Grad, sonst leer

hh, mm, ss, cs:        Systemzeit in Stunden, Minuten, Sekunden und
                       1/100 Sekunden

Zur Synchronisierung der Outputdatei mit den Ereignissen des Versuchs-
rechners werden die Teleport-Requests mit folgender Ereigniszeile in die
Outputdatei geschrieben:

                        T;junction;0;0;0;;hh;mm;ss;cs

d.h. es wird nach der Statusbezeichnung 'T' noch die Nummer der Kreuzung,
in die teleportiert wird, und der Zeitpunkt der Aktion abgespeichert.

Teleportierung in die Kreuzung 0 haelt das Tier in einer Kreuzung ohne
Ausgaenge fuer eine gewisse Zeit fest, die der Versuchsrechner bestimmt.
Derzeit wird diese Zeitdauer in Schritten von 1 Minute festgelegt, so dass
genug Zeit fuer den Labyrinthrechner gegeben ist, die bisher angefallenen
Laufdaten an die Outputdatei zu senden. Damit kann die Beschraenkung auf
16000 events umgangen werden. Die waehrend des Abspeichervorganges
anfallenden Laufdaten in Kreuzung 0 werden zwar vom Kugelrechner in den
Datenpuffer geschrieben, aber erst bei Ende des Abspeichervorganges aus-
gelesen und mit der aktuellen Zeit versehen, so dass hier die zeitliche
Zuordnung nicht verwertet werden kann. Erkennbar ist das daran, dass der
Abstand der Ereignisse nicht mehr mit der Uebertragungsrate von derzeit
5 Koordinatenpaare pro Sekunde uebereinstimmt.

Der Inhalt der Labyrinthdefinitionsdatei wird an des Ende der Output-
datei kopiert.


Es wird geprueft, ob die Zielkreuzung des Teleport-Requests
existiert und fuer Teleports zugelassen ist. Diese Eigenschaft wird fuer
jede Kreuzung in der Labyrinthdefinitionsdatei festgelegt. Wird ein Teleport-
Request mit nicht zugelassener Zielkreuzung erkannt, wird ein Ereignis

                        F;junction;0;0;0;;hh;mm;ss;cs

in die Outputdatei eingetragen und die falsche Kreuzungsmitteilung
ignoriert.

Neben den oben beschriebenen Statuswerten gibt es im Betrieb noch
andere, die aber in der Outputdatei nicht erscheinen.

Insgesamt gibt es derzeit folgende Statuswerte

                   0 = program termination
                   1 = full compensation at x0, y_comppoint
                   2 = animal in duct
                   3 = animal in end junction, no compensation
                   4 = get animal to new destination; full compensation
                   5 = animal in junction, no compensation
                   6 = soft transition from junction to duct base line
                   7 = no compensation
****************************************************************************}
interface

Uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, global_variables,
  TypInfo;

procedure save_data_to_output_file(current_time: int64);

  procedure   read_labyrinth_definition_file;
  procedure   read_procedure_file;

 implementation

procedure save_data_to_output_file(current_time: int64); 
var
Stream:TStream;
Mapdaten: string;
trial_number:integer;
cyclecount:integer;

begin
//          dummy_str:= dummy_str+ #13+ #10+ 'save data '+#13+ #10;
try


        Trial_number:= trial[trial_index].index;
        Mapdaten:=(

        DateTimeToStr(Now)+ ';'+ inttostr(current_time)+ ';'
        +inttostr(ballState.current_rat)+';'
        +inttostr(current_junction)+';'
        +(inttostr(current_duct))+';'+floattostr(alpha)+';'
        +(inttostr(round(position_in_duct)))+';'

        + FloatToStrF(x_animal_landscape, ffGeneral, 3, 3)+';'
        + FloatToStrF(y_animal_landscape, ffGeneral, 3, 3)+';' //15.5.09
        + FloatToStrF(z_animal_landscape, ffGeneral, 3, 3)+';'
        + inttostr(x_animal_cam)+';'+ inttostr(z_animal_cam)
        +';'+FloatToStrF(motor_x, ffGeneral, 3, 3)+';'+FloatToStrF(motor_z, ffGeneral, 3, 3)+';'  // Motor Spannungen


        {+ BoolToStr(available_data)+';'}+ IntToStr(last_event_feeder)+';'
        +IntToStr(last_event_pos)+';'+ IntToStr(state)+';'
        +inttostr(reward)+';'
        +GetEnumName(TypeInfo(TexpState), integer(exp_state))+ ';'
        +inttostr(Trial_number)+';'
        {+meldung_vom_server_global +';' }

        + #13+ #10
        );


        Stream:=TFileStream.Create(out_file_name, fmOpenReadWrite);
        Stream.Seek(0, soFromEnd);

        stream.Write(Pchar(Mapdaten)^,length(mapdaten));
        stream.free;
        save_data_counter:= save_data_counter+1;


except
      showmessage('Fehler in save_data_to_output_file');
end;
 // f¸r Reward Form-Anzeige:

          cyclecount:= ballState.current_rat;

          //belohnte Tr‰nkenbesuche

    if (last_event_feeder=1) and (last_event_pos=0) and (state=1) and (reward=1)
                then  Reward_Rec[cyclecount].feeder_count_arr[1]:=Reward_Rec[cyclecount].feeder_count_arr[1]+1;

    if (last_event_feeder=2) and (last_event_pos=0) and (state=1) and (reward=1)
                then  Reward_Rec[cyclecount].feeder_count_arr[2]:=Reward_Rec[cyclecount].feeder_count_arr[2]+1;

    if (last_event_feeder=3) and (last_event_pos=0) and (state=1) and (reward=1)
                then  Reward_Rec[cyclecount].feeder_count_arr[3]:=Reward_Rec[cyclecount].feeder_count_arr[3]+1;

    if (last_event_feeder=4) and (last_event_pos=0) and (state=1) and (reward=1)
                then  Reward_Rec[cyclecount].feeder_count_arr[4]:=Reward_Rec[cyclecount].feeder_count_arr[4]+1;

    if (last_event_feeder=5) and (last_event_pos=0) and (state=1) and (reward=1)
                then  Reward_Rec[cyclecount].feeder_count_arr[5]:=Reward_Rec[cyclecount].feeder_count_arr[5]+1;

    if (last_event_feeder=6) and (last_event_pos=0) and (state=1) and (reward=1)
                then  Reward_Rec[cyclecount].feeder_count_arr[6]:=Reward_Rec[cyclecount].feeder_count_arr[6]+1;


          //unbelohnte Tr‰nkenbesuche
               // Reward_Rec[choice].feeder_attempt_arr[1]

    if (last_event_feeder=1) and (last_event_pos=1) and (state=1){ and (reward=0) }
                then  Reward_Rec[cyclecount].feeder_attempt_arr[1]:=Reward_Rec[cyclecount].feeder_attempt_arr[1]+1;

    if (last_event_feeder=2) and (last_event_pos=1) and (state=1) {and (reward=0)}
                then  Reward_Rec[cyclecount].feeder_attempt_arr[2]:=Reward_Rec[cyclecount].feeder_attempt_arr[2]+1;

    if (last_event_feeder=3) and (last_event_pos=1) and (state=1){ and (reward=0) }
                then  Reward_Rec[cyclecount].feeder_attempt_arr[3]:=Reward_Rec[cyclecount].feeder_attempt_arr[3]+1;

    if (last_event_feeder=4) and (last_event_pos=1) and (state=1){ and (reward=0)}
                then  Reward_Rec[cyclecount].feeder_attempt_arr[4]:=Reward_Rec[cyclecount].feeder_attempt_arr[4]+1;

    if (last_event_feeder=5) and (last_event_pos=1) and (state=1) {and (reward=-1)}
                then  Reward_Rec[cyclecount].feeder_attempt_arr[5]:=Reward_Rec[cyclecount].feeder_attempt_arr[5]+1;

    if (last_event_feeder=6) and (last_event_pos=1) and (state=1){ and (reward=0)}
                then  Reward_Rec[cyclecount].feeder_attempt_arr[6]:=Reward_Rec[cyclecount].feeder_attempt_arr[6]+1;
        //if iEventFeeder:=2 then  Reward_Rec[cyclecount].feeder_count_arr[2]:=1;
        //if iEventFeeder:=3 then  Reward_Rec[cyclecount].feeder_count_arr[3]:=1;
        //if iEventFeeder:=4 then  Reward_Rec[cyclecount].feeder_count_arr[4]:=1;
        //if iEventFeeder:=5 then  Reward_Rec[cyclecount].feeder_count_arr[5]:=1;
        //if iEventFeeder:=6 then  Reward_Rec[cyclecount].feeder_count_arr[6]:=1;


end;

procedure read_labyrinth_definition_file; {+++kann Abfrage so bleiben???*****************************}
var
    number_of_ducts     : Byte;
    exit_id             : Byte;
    teleport            : Byte;
    inverse             : Byte;
    i,j,l               : Byte;
    k                   : Word;
    number_of_exits_old : Byte;
    //dl                  : array[1..max_number_of_ducts] of Real;
    dummy_alpha_lab     : byte;
    //dummy               : string;

begin
    Assign(lab,lab_file_path+lab_file_name);
    Reset(lab);

    ReadLn(lab,out_file_path);           // Zeile 1 //c:labdat  path to save data
    //showmessage(out_file_path);
    //
    ReadLn(lab,dummy_alpha_lab);         // Zeile 2//(lab,alpha_lab);         teleport enable/disable flag}
    ReadLn(lab,maze_shape);              // Zeile 3  // Form des Labyrinths

    ReadLn(lab,colour_ground);      // Zeile 4//0 oder 1, Farbverlauf am Boden
    ReadLn(lab,colour_sky);         // Zeile 5//0 oder 1, Farbverlauf am Himmel
    ReadLn(lab,start_junction);     // Zeile 6// Startkreuzung
    ReadLn(lab,number_of_ypsilons); // Zeile 7
    ReadLn(lab,decision_radius);    // Zeile 8// Decision distance in camera units  decision_radius in cm;??
    ReadLn(lab,duct_width);        // Zeile 9
    ReadLn(lab,number_of_junctions); // Zeile 10 //             {define all junctions}
    readln (lab);                    // Zeile 11   //*****************

 for i:=0 to (number_of_junctions-1) do     //Kreuzungsblock
  with junction[i] do
  begin
      readln (lab); // Zeile mit Kommentar    // Zeile 12     //1.Zeile der Tabelle pro Kreuzung
      //showmessage(floattostr(i));

      read(lab,number_junction,Y_center, number_of_exits,x_junction,z_junction);  // 2.Zeile

      readln (lab);   //********************

      readln (lab);   //Beschriftung Wege-Block
        //showmessage(floattostr(z_junction));

      for j:= 1 to number_of_exits do read(lab, junction[i].duct_identifier[j]);
      readln(lab);

      for j:= 1 to number_of_exits do read (lab, exit_angle[j]);
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, next_junction[j]);
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, duct_length [j]);
      readln (lab);
      (*
      for j:= 1 to number_of_exits do read (lab, duct_wall_height[j]);
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, upper_wall[j]);
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, upper_wall_height[j]);
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, lm_typ1_a[j]);                  // lokale LM of Typ1 at the begining of the duct,,
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, lm_typ1_b[j]);                  // lokale LM of Typ1 at the begining of the duct,,
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, lm_typ1_c[j]);                  // lokale LM of Typ1 at the begining of the duct,,
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, lm_typ2_a[j]);                  // lokale LM of Typ1 at the begining of the duct,,
      readln (lab);

      for j:= 1 to number_of_exits do read (lab, lm_typ2_b[j]);                  // lokale LM of Typ1 at the begining of the duct,,
      readln (lab);

      for j:= 1 to number_of_exits do
       begin
       //showmessage('j='+floattostr(j));
       read (lab, lm_typ2_c[j]);                  // lokale LM of Typ1 at the begining of the duct,,
       end;  *)
      readln (lab);

      for j:= 1 to number_of_exits do
       begin
       exit_angle[j]:=exit_angle[j]+ alpha_lab; //alpha_lab wird im procedure_file f¸r jede Ratte festgelegt
       exit_low_angle[j]:=exit_angle[j]-60;
       if exit_low_angle[j]<0 then exit_low_angle[j]:= exit_low_angle[j]+360;
       exit_high_angle[j]:= exit_angle[j]+60;
       if exit_high_angle[j]>360 then exit_high_angle[j]:=exit_high_angle[j]-360;
       end;

{                         if y_center= 1 then
                         begin
                              junction[next_junction[j]].x_junction:= junction[i].x_junction+ cos(exit_angle[j])*duct_length[j];
                              junction[next_junction[j]].z_junction:= junction[i].z_junction+ sin(exit_angle[j])*duct_length[j];
                         end;
}
                //showmessage(inttostr(upper_wall[1]));
            if number_of_exits_old=0 then begin number_of_exits:=number_of_exits_old; number_of_exits_old:=99; //showmessage('mist');
            end;


                //jetzt: Eingabe der Kreuzungskoordinaten ¸ber File!
                //x_landscape:= x_junction *  cos(30/180*pi)   * duct_length[1];
                //z_landscape:= z_junction * (1+sin(30/180*pi))* duct_length[1];

   readln (lab); //*******Zeile zur Trennung zur n‰chsten Kreuzung              //15.Zeile
  end;     // bis hierher gehˆrt alles zu einer Kreuzung



 end_of_labyrinth_definition_file:=0;
 readln (lab);//******************
 readLn(lab,end_of_labyrinth_definition_file); // in Textdatei steht eine 99

 if end_of_labyrinth_definition_file <> 99 then showmessage('No valid labyrinth definition file');
 if end_of_labyrinth_definition_file = 99 then showmessage('valid labyrinth definition file');

 Close(lab);

 //decision_radius:=100;// 4.2.09 auf 90 erniedrigt 150;  // hat sich f¸r Basler Kamera bew‰hrt, in mm
  decision_radius:=125;  // erhˆht 4.3.09,mit laufender Kugel besser ein biﬂchen grˆﬂer

 for k:= 0 to (number_of_junctions-1) do
   with junction[k] do
  begin
  (* zum testen  /25 raus 16.8.08
 // die Kreuzungsmittelpunkte werden beim einlesen durch 25 geteilt!
        junction[k].x_junction:=(junction[k].x_junction/25);
        junction[k].z_junction:=(junction[k].z_junction/25);
        showmessage (' Kreuzumgsnummer:'+ inttostr(k)+
                     ' x_junction '+floattostr(junction[k].x_junction)+
                     ' z_junction '+floattostr(junction[k].z_junction));
   *)
        for j:= 1 to junction[k].number_of_exits do
        junction[k].duct_length_grafic[j]:=junction[k].duct_length[j]/25;
 //9.8.08 neue Variable duct_length_grafic eingef¸gt, duct_length wurde bisher erst in build_list /25 geteilt


    junction[k].x_junction_grafic:=junction[k].x_junction/25;
    junction[k].z_junction_grafic:=junction[k].z_junction/25;
    // 19.11.08 neue Variable junction[k].x_junction_grafic eingef¸gt, damit die
    // lokalen Landmarken am richtigen Ort stehen
  end;

end;

///////////////////////////////////////////////////////////
procedure read_procedure_file;
var i,l,dummy: integer;
     //dummystr: string;
     file_name : String;
 
  number_of_trials: Integer;

  end_of_procedure_file: integer;//real;

begin

   file_name:= lab_file_path+ proc_file_name;
   Assign(lab, file_name);
   showmessage(proc_file_name);
    //
    Reset(lab);
    ReadLn(lab,number_of_trials); // Anzahl der Trials in diesem File
    showmessage('this file contains '+inttostr(number_of_trials)+' trials');

    for i:= 1 to (number_of_trials) do
    begin
      trial[i].reward_current_trial:=false;
      readln(lab);      // Zeile 2 ‹berschriften       // Zeile 3 wichtige Variablen
      read(lab,trial[i].index, trial[i].start_j, trial[i].cage, trial[i].end_j);  //showmessage('end_j'+inttostr(trial[i].end_j) );

                // showmessage(inttostr(i));

      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].feeder[1]);
                   //??? trial[i].trialjunction[l].junction:= l;
      end;
      readln(lab);

      read(lab,dummy,dummy,dummy,dummy);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].feeder[2]) end;
      readln(lab);

      read(lab, dummy,dummy,dummy,Trial[i].llm);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].feeder[3]) end;
      readln(lab);

      read(lab, dummy,dummy,dummy,dummy);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].feeder[4]) end;
      readln(lab);

      read(lab, dummy,dummy,dummy,dummy);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].feeder[5]) end;
      readln(lab);

      read(lab, dummy,dummy,dummy,dummy);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].feeder[6]) end;
      readln(lab);
      readln(lab); // ‹berschrift 2. Tabelle


      //Einlesen der distalen und lokalen Landmarken
      read(lab,dummy,dummy,dummy,trial[i].distal_lm[1]);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].local_lm_junction[1]) end;
      readln(lab);

      read(lab,dummy,dummy,dummy,trial[i].distal_lm[2]);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].local_lm_junction[2]) end;
      readln(lab);

      read(lab,dummy,dummy,dummy,trial[i].distal_lm[3]);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].local_lm_junction[3]) end;
      readln(lab);

      read(lab,dummy,dummy,dummy,trial[i].distal_lm[4]);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].local_lm_junction[4]) end;
      readln(lab);

      read(lab,dummy,dummy,dummy,trial[i].distal_lm[5]);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].local_lm_junction[5]) end;
      readln(lab);

      read(lab,dummy,dummy,dummy,trial[i].distal_lm[6]);
      for l:=1 to trMAXJUNCTIONS do
      begin read(lab, trial[i].trialjunction[l].local_lm_junction[6]) end;
      readln(lab);

      readln(lab);

    end;

    readln(lab);
              
    readln (lab, end_of_procedure_file);//showmessage ('end_of_procedure_file= '+inttostr(end_of_procedure_file));
            if    end_of_procedure_file = 99 then
            showmessage ('valid procedure file')
            else
            showmessage ('no valid procedure file');
            //showmessage(inttostr(end_of_procedure_file));
end;
///////////////////////////////////////////////////////////////////////////////
procedure calibrate_labyrinth;
// rechnet mm in opengl-Einheiten um, sodaﬂ die im Labyrinth-file angegebenen
// Zahlen in mm stehen kˆnnen.
// noch machen: Umrechnung der gelaufenen Schritte in setup!!!
//
//
//
//
//
//                                        *I---
//                                         I
//                                  *      I
//                                  *      I
//                             *           I
//                                         I
//                        *                I  y
//                             *           I
//                   *                     I
//                                         I
//              *         *                I
//                                         I
//         *                               I
//          )b        * )a                 I
// --*-------------------------------------I---
//   I      dx       I          x          I
//
//
//
//1)  y/x = tan a
//
//2)  x=y/tan a
//
//3)  y/(x+dx)= tan a
//
//4)  x +dx= y/tan b
//
//5)  x= (y/tan b) -dx
//
//6)  y/tan a=  (y/tan b) -dx
//
//7)  y((1/tan a)-(1/tan b))=-dx
//
//8)  y= -(dx/((1/tan a)-(1/tan b)))
//
//
begin


end;
///////////////////////////////////////////////////////////////////////////////
end.
