unit Setup;   //Knoepfe der T-Form abfragen, Rechnerwahl, Labyrinthform,...
               // und UDP- Verbindung einrichten
(*
 Raumrichtungen auf der Kugel:

                          +x             -x             +z              -z

 Kamera                :   Tür           Fenster        Wand          Schrank

 Motor+ (>2050)        :   Tür (M1)      Fenster (M1)   Schrank(M2)   Wand (M2)
 Motor- (<2050)        :

 Wegaufnehmer          :   Tür (S1)      Fenster (S1)   Schrank(S2)   Wand (S2)
 (von beiden nur z
 Komponente verwenden)

 Landschaft            :   Tür           Fenster

 Gangrichtung          :   0°            180°           90°           270°
                           Ratte
                           Richtung Tür



distale Landmarken:
Tränkennummer   ° distale Lm                 Anordunung auf Kugel
                                                       Fenster
   1               180                                  1
   2               120                         2                6
   3                60
   4                 0                       Wand                Schrank
   5               300                         3                5
   6               240
                                                        4
                                                        Tür

  *)
 interface

uses
  Windows, Messages, SysUtils, {Classes,} Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls,MapandVars, Unit1, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPServer, Idsockethandle, IdUDPClient,log,lakutpu,
  SerialNG, global_variables, mmsystem, Variants, Classes, {SerialNGBasic,}
  Buttons, Unit3, TestUnit, Unit_Calibration, Math,
  BasicFunctions, Unit4, TypInfo, ADDI_DATA, Unit5;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ButtonAbort: TButton;
    Server: TIdUDPServer;
    //IdUDPClient1: TIdUDPClient;
    Client1: TIdUDPClient;
    Rechnerwahl: TLabeledEdit;

    Lab_file: TLabeledEdit;
    Procedure_file: TLabeledEdit;
    Timer1: TTimer;
    Memo_Sendepuffer: TMemo;
    Memo_Empfang: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Edit_Spannung_M1: TEdit;
    Edit_Spannung_M2: TEdit;
    Spannung: TLabel;
    Label4: TLabel;
    RewardForm: TBitBtn;
    SensorButton: TButton;
    Edit_exec_counter: TEdit;
    Label3: TLabel;
    Edit_position: TEdit;
    Edit_corridor: TEdit;
    Edit_Junction: TLabeledEdit;
    ButtonCalibrate: TButton;
    Button2: TButton;

    SerialPortNG1: TSerialPortNG;
    SerialPortNG2: TSerialPortNG;
    Edit_Trial: TLabeledEdit;
    Edit_mazeState: TEdit;
    Edit_cage: TLabeledEdit;
    LEdit_coord: TLabeledEdit;
    Edit_Procedure_Control: TLabeledEdit;
    Button3: TButton;
    Experiment_State: TLabeledEdit;
    Session_Change_OK: TButton;
    ball_control: TButton;


    procedure Button1Click(Sender: TObject);
    procedure ButtonAbortClick(Sender: TObject);
    procedure ServerUDPRead(Sender: TObject; AData: TStream;ABinding: TIdSocketHandle);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

    procedure SerialPortNG1RxClusterEvent(Sender: TObject);
    procedure SerialPortNG1CommStat(Sender: TObject);
    procedure SerialPortNG1ProcessError(Sender: TObject; Place,
      Code: Cardinal; Msg: String; Noise: Byte);
    procedure SerialPortNG1RxCharEvent(Sender: TObject);
    procedure SerialPortNG1RxEventCharEvent(Sender: TObject);
    procedure SerialPortNG1WriteDone(Sender: TObject);

    procedure NG2RxClusterEvent(Sender: TObject);
    procedure NG2CommStat(Sender: TObject);
    procedure NG2ProcessError(Sender: TObject; Place,
      Code: Cardinal; Msg: String; Noise: Byte);
    procedure NG2RxCharEvent(Sender: TObject);
    procedure NG2RxEventCharEvent(Sender: TObject);
    procedure NG2WriteDone(Sender: TObject);

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure RewardFormClick(Sender: TObject);
    procedure SensorButtonClick(Sender: TObject);
    procedure ButtonCalibrateClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Experiment_StateChange(Sender: TObject);
    procedure Session_Change_OKClick(Sender: TObject);
    procedure ball_controlClick(Sender: TObject);

  private
    { Private-Deklarationen }
    RxDCharStartTimer : Boolean;
    RxDCharResetTimer : Boolean;
    exec_counter: integer;
    prev_exec_time, prev_store_time: int64;

    procedure MyIdleHandler(Sender: TObject; var Done: Boolean);

  public
    { Public-Deklarationen }
    Counter: integer; //Eine Variable zum Zählen der Timer Durchläufe

end;

  procedure init_laku;
  procedure init_grafic;
  procedure close_laku;
  procedure Get_VMaze_Coord;
  procedure Initialize_LB_Feeder;
  procedure Get_Animal_Position;
  procedure Reset_Corridor_Coord;
  procedure Test_Maze;
  procedure LB_Filter;

var
   Form1: TForm1;
   rechner_nummer: integer;
   length_str: string;

  WndClass:TWndClass;
  Wnd:HWnd;
  RC:HGLRC;
  DC:HDC;
  mp:TPoint;
	sTime,Frame,NewFrame,
	MyTime,LastFrame:WORD;
  Done:Boolean;
  SendDataSize : DWord;

  index_serial : integer;
  Idle_Counter : integer;
   i_old: integer; //29.7.08

implementation
uses SerialNGAdv, Unit2; // Include Advanced Dialog
{$R *.DFM}
///////////////////////////////////////////////////////////////////////////////
procedure seriell_senden(IDSerialPort: integer; data: string);
// sendet Daten über serielle Schnittstelle zum Mega 128
// und wird aufgerufen von Check_Serial_Buffer(current_time : int64)
var
   SendStr, dummy : string;
   i : integer; // zähler
begin
     SendDataSize := Length(data);
     case IDSerialPort of
          1: Form1.SerialPortNG1.SendString(data);
          2: Form1.SerialPortNG2.SendString(data);
     end;

     for i := 1 to 8 do
         dummy := dummy + inttohex(byte(data[i]), 2) + ' ';
     //if dummy[11] <> '4' then
     form1.Memo_Sendepuffer.Lines.add('seriell senden: '+ dummy);
end;

///////////////////////////////////////////////////////////////////////////////
Procedure Koordinaten_senden; //UDP
// Koordinaten_senden sendet über UDP den Inhalt der Variable udpSendMsg.
// udpSendMsg enthält alle Daten die für einen neuen Aufbau des Labyrinthes
// auf den Grafikrechnern notwendig sind.


var
 s : TStringStream;
 str: string;
 len, i, j: integer;
 size: integer;
begin

(*
if reset_landscape=true then
 begin
 showmessage(' reset_landscape='+ booltostr(reset_landscape)+
             ' current_junction='+inttostr(current_junction));

 reset_landscape:=false;
 //die Werte für  udpSendMsg.x_landscape und udpSendMsg.z_landscape aus der
 //Datei benützen und hier nicht überschreiben!
 end

 else *)
 begin
 //Hier: die Landschaft kalibrieren:
// 50 ist ein provisorischer und frei erfundener Wert
   udpSendMsg.x_landscape:= x_animal_landscape/25; //9.8.08 /25, 27.7./50;
   udpSendMsg.y_landscape:= y_animal_landscape; //20.8.08
   udpSendMsg.z_landscape:= z_animal_landscape/25; //9.8.08 /25, 27.7./50;

form1.LEdit_coord.Text:=
         'x= '+ floattostrF((x_animal_landscape/25), ffFixed, 2, 2)+
        ' y= '+ floattostrF((y_animal_landscape), ffFixed, 2, 2)+
        ' z= '+ floattostrF((z_animal_landscape/25), ffFixed, 2, 2);



 end;
   s:= TStringStream.Create(str);
   try
        // send rebuild and the current position
//**********************************************
     len:= SizeOf(udpSendMsg.rebuild);
     s.write(udpSendMsg.rebuild, len);
     len:= SizeOf(udpSendMsg.x_landscape);
     s.write(udpSendMsg.x_landscape, len);
     len:= SizeOf(udpSendMsg.y_landscape);
     s.write(udpSendMsg.y_landscape, len);
     len:= SizeOf(udpSendMsg.z_landscape);
     s.write(udpSendMsg.z_landscape, len);
//**********************************************
    if udpSendMsg.rebuild= 1 then
    begin
        for i:= 0 to max_number_of_junctions do
        // send local landmarks
        begin
                len:= SizeOf(udpSendMsg.arJunction[i, 1]);
                s.Write(udpSendMsg.arJunction[i, 1], len);
               // len:= SizeOf(udpSendMsg.arJunction[i, 2]);  //8.2.09 len für alle lm extra
                s.Write(udpSendMsg.arJunction[i, 2], len);
               // len:= SizeOf(udpSendMsg.arJunction[i, 3]);
                s.Write(udpSendMsg.arJunction[i, 3], len);
               // len:= SizeOf(udpSendMsg.arJunction[i, 4]);
                s.Write(udpSendMsg.arJunction[i, 4], len);
               // len:= SizeOf(udpSendMsg.arJunction[i, 5]);
                s.Write(udpSendMsg.arJunction[i, 5], len);
              //  len:= SizeOf(udpSendMsg.arJunction[i, 6]);
                s.Write(udpSendMsg.arJunction[i, 6], len);
        end;

         //send colour and shape local landmarks
         len:=SizeOf (llm_colour);
         s.Write(llm_colour, len);
         // send the angles of the 6 distal LMs
        len:= SizeOf(udpSendMsg.arDistalLM.reLM1);
        s.Write(udpSendMsg.arDistalLM.reLM1, len);
        //len:= SizeOf(udpSendMsg.arDistalLM.reLM2);
        s.Write(udpSendMsg.arDistalLM.reLM2, len);
       // len:= SizeOf(udpSendMsg.arDistalLM.reLM3);
        s.Write(udpSendMsg.arDistalLM.reLM3, len);
      //  len:= SizeOf(udpSendMsg.arDistalLM.reLM4);
        s.Write(udpSendMsg.arDistalLM.reLM4, len);
      //  len:= SizeOf(udpSendMsg.arDistalLM.reLM5);
        s.Write(udpSendMsg.arDistalLM.reLM5, len);
      //  len:= SizeOf(udpSendMsg.arDistalLM.reLM6);
        s.Write(udpSendMsg.arDistalLM.reLM6, len);


        udpSendMsg.rebuild:= 0;
   end;

   finally
     form1.Client1.Active := true;
     //form1.Client1.broadcast(x_z_koordinaten,8080);
     form1.Client1.broadcast(s.DataString,8080);
     form1.Client1.Active := false;

     s.Free;
   end;
//   udpSendMsg.rebuild:=FALSE;
end;

///////////////////////////////////////////////////////////////////////////////
function Check_Serial_Buffer(current_time : int64): integer;
// prüft den Puffer und bestimmt, wann etwas gesendet werden muss
// Daten werden zum seriell senden von den einzelnen "ausführenden Prozeduren"
// aus jeder beliebigen Stelle mit Zeitstempel in den Sendepuffer geschrieben
var
   index, delay : integer;
begin
 result:= MAX_IO_CHANNELS+1;

 // check the array fields for data that is to be sent
 for index := 0 to MAX_IO_CHANNELS- 1 do
 begin
      if sende_puffer[index].ready then
      begin
      // check the property SendInProgress of SerialPortNG and wait until
      // previous data has been sent
      // omitting this line leads inevitably to a program crash
         if (current_time >= sende_puffer[index].send_time) and
         (not Form1.SerialPortNG1.SendInProgress) then
         begin
            seriell_senden(1, sende_puffer[index].Frame_Str); // sends data
            delay := current_time - sende_puffer[index].send_time;
            sende_puffer[index].ready := false;//tag the current field as "sent"
            result:= index;
            //form1.Memo_Sendepuffer.Lines.Add('index ser= '+ inttostr(index)+' delay= '+ inttostr(delay));
         end;
      end;
      // else
      //if not sende_puffer[index].ready then
      //   result:= MAX_IO_CHANNELS+1;
 end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure check_state(iBuffer: integer);
var
   feeder: integer;
begin
{     feeder:= sende_puffer[iBuffer].feeder_No;
     if sende_puffer[iBuffer].feeder_No < MAX_TR_EINHEITEN then
     begin
        if sende_puffer[iBuffer].level then
        begin
           TrEinheit[ballState.current_rat].feeder_active[feeder]:= TRUE;
        end
           else
        begin
           TrEinheit[ballState.current_rat].feeder_active[feeder]:= FALSE;
        end;
     end; }
end;


///////////////////////////////////////////////////////////////////////////////
procedure TForm1.MyIdleHandler(Sender:TObject;var Done:Boolean);
// = Hauptschleife, wird ständig ausgeführt

var
   current_time, y_current_time, time_pos_y_down: int64;
   iBufferIndex: integer;
   executed: boolean;
   //////////////////////////
begin

 if rechner_nummer=0  then
 begin
     Done := False;
     current_time := TimeGetTime; // get the current time in ms
     y_current_time:=timegettime; //18.08.08 hier eingefügt
     
     // check the number of idle-calls per second and display the value
     inc(exec_counter);
     if (current_time - prev_exec_time) >= 1000 then // set the refresh time
     begin
          form1.Edit_exec_counter.Text:= (inttostr(exec_counter));
          prev_exec_time := current_time;
          exec_counter := 0; // reset the counter
     end;



     // use "dummy_str" in order to display data from procedures/functions
     // that can't directly access Form1 memo fields
     if length(dummy_str) <> 0 then
     begin
          Form1.Memo_Empfang.lines.add(dummy_str);
          dummy_str := ''; // reset the message string
     end;

     LB_Filter;      //wird dauernd aufgerufen, speichert aktuelle IO Werte(LB)
                     //und die zugehörige Zeit

     if FLAG_VMAZE_COORD then
     // new data is available - set by Add_path_Data  Wegaufnehmer...        16 times/second
     // diese Schleife wird erst nach "go-Button",= u.a. initialisieren Mega 128,
     // ausgeführt

     begin

          Get_VMaze_Coord;    // hier werdem die Koordinaten gesendet, wenn Wegaufnehmer etwas mitteilen
          // process coordinates from optical sensors and send with UDP
          //if rechner_nummer <> 9 then
          get_animal_position; // process Wegaufnehmer data camera data

          // Die Belohnungsprozedur reward_training wird immer gleich aufgerufen,
          // wenn neue Daten über die ser Schnittstelle reinkommen
          // in der Prozedur: Add_IoPin_Data, in Unit3

          try
          runExperiment;
          //test_doors;
          //Test_Procedure;      // call the door system
          except
          showmessage('error in test_procedure');
          end;    //try-except-Block

          Test_Maze; // calculate the current position in the virtual maze and
                     //sets motor values
          Form1.Edit_Trial.Text:= inttostr(trial_index);
          FLAG_VMAZE_COORD := FALSE; // reset flag
          Form1.edit_cage.text:= inttostr(trial[trial_index].cage);

          Form1.Experiment_State.Text:=session_control;
        (*
          if ((udpSendMsg.rebuild=1) and (udpRecMsg.old = false) )then
            begin

           ///////////////////////////////////////////////////////////
           //hier testen: die Landschaft in y-Richtung absenken,
           // um für kurze Zeit schwarze Bildschirme zu bekommen
           // geht im Prinzip, nur sehr kurz:time_down ist auf 4000 gesetzt,
           // aber es wird nur sehr kurz abgesenkt!

           // y_current_time:=timegettime; //für y-Absenkung 18.08.08: auskommentiert
            //time_pos_y_down:=y_current_time; 21.8.08. raus, dafür so:
            time_pos_y_down:=timegettime;
            // prev_store_time:= current_time;
            time_pos_y_down:= current_time;
            //y_animal_landscape:=20.0;          // 18.08.08: + = Froschperspektive
            y_animal_landscape:=5.0;         //7.2.09 auf 5 gesetzt, evtl verhindert das den Bildschirmrechner absturz
            form3.poy_Y.Text:=floattostr(y_animal_landscape);

            udpRecMsg.old:=true;             // 18.08.08 auskommentiert
            Koordinaten_senden;   //hier wird gesetzt: udpSendMsg.rebuild:= 0;
            end;

           //if (time_pos_y_down+ time_down> y_current_time) and //18.08.08 auskommentiert
           //  udpRecMsg.old = true then
           //if ((y_current_time > (time_pos_y_down + time_down)) and
                if ((current_time- time_pos_y_down) > time_down) and
                (udpRecMsg.old = true) and
                (udpSendMsg.rebuild= 0)then     //18.08.08 neu definiert

          //   if (current_time- time_pos_y_down) > time_down then
          //   begin
        14.3.09*)
         //    begin
              // 14.3.09 y_animal_landscape:=0; //Ende Absenken
              //  14.3.09form3.poy_Y.Text:=floattostr(y_animal_landscape);
              //  14.3.09udpRecMsg.old:=false;                          //18.08.08 auskommentiert
           //  Koordinaten_senden;
            if X_Y_Z_send_koordinates then
            begin
            koordinaten_senden;
            X_Y_Z_send_koordinates:=false;
            end;


     end;// FLAG_VMAZE_COORD

     // check if commands have to be sent to the periphery
     iBufferIndex:= Check_Serial_Buffer(current_time);
     if iBufferIndex<= MAX_IO_CHANNELS then
        check_state(iBufferIndex);   //!!! hier passiert nichts!

     // the following block is executed only after the start button has been
     // pressed
     if timer_start and file_created then
     begin
          if (current_time- prev_store_time) > STORE_PERIOD then
          begin

             save_data_to_output_file(current_time);
             prev_store_time:= current_time;
          end;

          if save_data_counter > 60000 then  //output file is full
          begin
             save_data_counter:=0;
             create_data_file;  //create file for the next 60000 events
          end;

     end; // if timer_start and file_created
end
else exit;//end; //rechnernummer 0

end; // TForm1.MyIdleHandler


///////////////////////////////////////////////////////////////////////////////
 procedure LB_Filter;
  var
  current_time: int64;
  i:integer;
  byNewEventPos, byNewEventFeeder: integer;

begin
     current_time:= TimeGetTime;
     for i:=1 to 12 do
     begin
          if LB_wait[i]=true then//neues, positives Signal ist eingegangen-MERKEN
          begin

               //Zeit ist um und Signal noch positiv
               if (current_time > (LB_current_time[i]+2000) ) then // showmessage('Process_IoPin_Data Pin='+ inttostr(i));
               begin    //Lichtschranken-Ereignis zählt
                        LB_wait[i]:=false; //Wartezeit mit Erfolg vorbei
                        // showmessage('Process_IoPin_Data');


               if i=1  then begin byNewEventPos:= 1; byNewEventFeeder:=1 end;
               if i=2  then begin byNewEventPos:= 1; byNewEventFeeder:=2 end;
               if i=3  then begin byNewEventPos:= 1; byNewEventFeeder:=3 end;
               if i=4  then begin byNewEventPos:= 1; byNewEventFeeder:=4 end;
               if i=5  then begin byNewEventPos:= 1; byNewEventFeeder:=5 end;
               if i=6  then begin byNewEventPos:= 1; byNewEventFeeder:=6 end;

               if i=7  then begin byNewEventPos:= 4; byNewEventFeeder:=1 end;
               if i=8  then begin byNewEventPos:= 4; byNewEventFeeder:=2 end;
               if i=9  then begin byNewEventPos:= 4; byNewEventFeeder:=3 end;
               if i=10 then begin byNewEventPos:= 4; byNewEventFeeder:=4 end;
               if i=11 then begin byNewEventPos:= 4; byNewEventFeeder:=5 end;
               if i=12 then begin byNewEventPos:= 4; byNewEventFeeder:=6 end;

               (*showmessage('i= '+ inttostr(i)+ '; byNewEventPos= '+
                                        inttostr(byNewEventPos)+ '; byNewEventFeeder'+
                                        inttostr(byNewEventFeeder));
                *)
               Process_IoPin_Data(byNewEventFeeder, byNewEventPos);
               end;
                //Zeit ist noch nicht um, aber Signal ist positiv

          end;
     end;
end;


////////////////////////////////////////////////////////////////////////////////
procedure delta_corridor(xy_Data,xy_Data_prev: TADNS_Frame;var d_distance:real);
// berechnet die gelaufene Strecke aus 2 aufeinanderfolgenden Wegaufnehmer Daten
// ( neue Daten: ca. 16x PRO SEC
// verarbeitet Überlauf
// aufgerufen von: Get_VMaze_Coord
var
   temp: integer; // covered way in sensor units (i.e. pixels)
   pixel_distance: real;
begin
          temp := xy_Data.z - xy_Data_prev.z; // covered way in sensor units
                                              //(i.e. pixels)
          if abs(temp) < 10000 then
          begin
               pixel_distance := temp; // no shortint overflow (i.e. 65535 -> 0)
          end
             else
          begin
               // overflow
               pixel_distance := xy_Data.z + (-sign(temp)*65535 - xy_Data_prev.z);
          end;

          d_distance := pixel_distance * SCALE_FACTOR; // transform sensor units
                                                       // into mm !!!
                                                       // SCALE_FACTOR 1/63
end;

///////////////////////////////////////////////////////////////////////////////
procedure Get_VMaze_Coord;
// berechnet die Koordinaten des Tieres im virtuellen Raum
// 63 Einheiten/mm = 1/63 mm/Einheit
var
   x, z :string;
   i: integer;
begin
//      form1.Memo_Sendepuffer.lines.add('Get VMaze Coord...');

        delta_corridor(xy_Data[1], xy_Data_prev[1], d_corridor.k1);
        delta_corridor(xy_Data[2], xy_Data_prev[2], d_corridor.k2);

        corridor_x := corridor_x + d_corridor.k1 ;    //
        corridor_z := corridor_z + d_corridor.k2;   // war bis 8.8.08 - d_corr..., Anschlüsse Wegaufnehmer wurden getauscht

        form1.Edit_corridor.text := ' x= '+ floattostrF(corridor_x, ffFixed, 2, 2)+
                                  ' z= '+ floattostrF(corridor_z, ffFixed, 2, 2);

     i:= current_junction; {die aktuelle Kreuzungsnummer verwenden}
    
      form3.current_junction_in_get_Vmaze_coord.Text:= inttostr(current_junction); //15.8.08
    // showmessage ('i'+inttostr(i)+'getvmazekoord');  1.8.08: wechsel von 0 auf 1 klappt, dann kommt die Meldung zu oft
     //??? 26.7.08 oder so? i:= trial[trial_index].start_j;
     (*
     i:=2;//31.7.08  nützt nichts  1.8.08 es kommt an x=0, z=20, mit passerdem teleport
     i:=1; //1.8.08 x=0, z=0
     *)
     (*
     junction[i].x_junction:=20; //31.7.08
     junction[i].z_junction:=20;
     *)

     x_animal_landscape:=  junction[i].x_junction + corridor_x;    //26.7.08???
     z_animal_landscape:=  junction[i].z_junction + corridor_z;

     form3.current_junction_coordinates_in_get_Vmaze_coord.Text:=
        ('x= ')+ floattostr(junction[i].x_junction)+
       ( 'z= ')+ floattostr(junction[i].z_junction);

     (*
     if changed_junction    then          //2.8.08
     begin
     showmessage(' current_junction='+inttostr(current_junction)+
                 ' junction[i].x_junction '+floattostr(junction[i].x_junction)+
                 ' junction[i].z_junction '+floattostr(junction[i].z_junction)+
                 ' Kreuzungsaktualisierung ohns rebuild' );
     changed_junction:=false;
     end;
     *)
     x:= FloatToStrF(x_animal_landscape, ffExponent, 7, 1);
     z:= FloatToStrF(z_animal_landscape, ffExponent, 7, 1);

       // koordinaten auf 0 setzen, damit das Bild nicht wackelt
       // muss raus bei Kompensationsversuchen
       //x:=inttostr(0);
       //z:=inttostr(0);

       x_z_koordinaten := x+ ';'+ z;

       if (x_z_koordinaten <> x_z_koordinaten_old) then
       begin
            koordinaten_senden;  // per UDP die Koordinaten senden
            x_z_koordinaten_old:=x_z_koordinaten;
       end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure transmit_to_DAC_I2C;
// berechnet Werte für den DA Wandler an den Kugelmotoren
// ruft auf: Send_To_Ser_Buffer(...)
// wird aufgerufen von:   ???
var
   dummy_Data1, dummy_Data2 : byte;
   dv_motor_x, dv_motor_z: real;
   acc_x, acc_z: real;
   dt_motor: int64;
   current_time: int64;
   io_ok: boolean;
   display_message_x, display_message_z: string;
begin
     current_time := TimeGetTime; // get the current time in ms
     
     //Motoren scallieren:
     //MotorXscale und MotorZscale: Werte aus Eichung:
     //Motor für 10s mit x Volt gedreht, dann Strecke gemessen
     //d.h. Abstand vom Mittelpunkt (in mm)entspricht einer bestimmten Voltzahl
     //und einer best. Drehgeschwindigkeit der Motoren.
     //Mit MotorXscale (1.64) und MotorZscale(1) werden die beiden Motoren in ihrer
     //tatsächlichen Kugeldrehung angeglichen,
     //mit MotorScale die Drehgeschwindigkeit an die Tiere angepasst (ist gerade 0.7)


     //Motor_x: Motor Wand   blau/braun
     //MOtor_z: Motor Fenster
     d_motor_x:= -(d_motor_x* MotorXscale * MotorScale);   //Motor Fenster =Motor11= Motor2
     d_motor_z:= d_motor_z* MotorZscale * MotorScale;      //Motor Wand    =Motor 10=Motor1

     // d_motor_x bzw. z = Sollwert
    (*
     motor_x := 2049+ (-d_motor_x); //* MAX_ALLOWED_DAC / MAX_POSSIBLE_DREF; // $800
     motor_z := 2050+ (-d_motor_z);// * MAX_ALLOWED_DAC / MAX_POSSIBLE_DREF;
     *)
     motor_x := 2052+ (-d_motor_x); //8.12.08
     motor_z := 2052+ (-d_motor_z);


   //zum testen
    //motor_x:=2100;
    //motor_z:=2100;

     // Nullstellung Motoren:
     // Motor1 (Wand) 2048
     // Motor2 (Tür) 2051

     // limit acceleration
    (* dv_motor_x:= motor_x - motor_x_prev; // calculate velocity increase
     dv_motor_z:= motor_z - motor_z_prev;
     dt_motor:= current_time- time_motor_prev; // calculate time difference

     acc_x:= dv_motor_x / dt_motor; // calculate acceleration
     acc_z:= dv_motor_z / dt_motor;


     if abs(acc_x) > MAX_ALLOWED_ACC then
          motor_x := motor_x_prev+ sign(motor_x)* (MAX_ALLOWED_ACC* dt_motor);
     if abs(acc_z) > MAX_ALLOWED_ACC then
          motor_z := motor_z_prev+ sign(motor_z)* (MAX_ALLOWED_ACC* dt_motor);

     // store current values
     motor_x_prev:= motor_x;
     motor_z_prev:= motor_z;
     time_motor_prev:= current_time;
     *)
     
     // Geschwindigkeitsbegrenzung falls Berechnung falsch ist
      // limit the maximal velocity

    (* geändert 7.12.08
    if abs(motor_x) > 2200 then  motor_x := 2200;//3000;
    if abs(motor_x) < 1900 then  motor_x := 1900;//1000;
    if abs(motor_z) > 2200 then  motor_z := 2200;//3000;
    if abs(motor_z) < 1900 then  motor_z := 1900;//1000;
    *)

    if abs(motor_x) > 2100 then  motor_x := 2100;//3000;
    if abs(motor_x) < 2000 then  motor_x := 2000;//1000;
    if abs(motor_z) > 2100 then  motor_z := 2100;//3000;
    if abs(motor_z) < 2000 then  motor_z := 2000;//1000;
     (*
    if abs(motor_x) > 2080 then  motor_x := 2080;//3000;
    if abs(motor_x) < 2020 then  motor_x := 2020;//1000;
    if abs(motor_z) > 2080 then  motor_z := 2080;//3000;
    if abs(motor_z) < 2020 then  motor_z := 2020;//1000;
     *)

    if maze_state= st_standby then
        begin
         motor_x:= 2052;// 20.3.09 motor_x:= 2052;   //  motor_x:= 2048; // geändert 7.12.08
         motor_z:= 2052;// motor_z:= 2052;   //  motor_z:= 2048;
        end;

   // motor_z:=2060;//test   4.11.08 funktioniert nicht: Motor , Anzeige in engine funktioniert
   //                           16.11.08 Motor geht wieder: schlechte Lötstelle in Handsteuerungskästchen gefunden
   // motor_x:=2060; // test 4.11.08 funktioniert: Motor und Anzeige in engine

   io_ok:= ADDI_DATA_setOutput(round(motor_x), round(motor_z));

   if io_ok then
      begin
           display_message_x:= inttostr(round(motor_x));
           display_message_z:= inttostr(round(motor_z));
      end
   else
       begin
           display_message_x:= 'ADDI DATA ERROR';
           display_message_z:= 'ADDI DATA ERROR';
       end;

     form1.Edit_Spannung_M1.text := display_message_x;
     form1.Edit_Spannung_M2.text := display_message_z;
end;

///////////////////////////////////////////////////////////////////////////////
procedure Reset_Corridor_Coord;
// setzt Korridorlänge und Koordinaten zurück, wenn eine neue Junction
// erreicht wird
var
i:integer;
begin
//          if junction[current_junction].Y_center = 1 then ???
//          begin
              corridor_x := 0;   //weg 10.8.08???
              corridor_z := 0;   //weg 10.8.08???
          //27.7.     landscape.k1:= junction[current_junction].x_landscape;
          //          landscape.k2:= junction[current_junction].z_landscape;
          // wenn dann
     //reset_landscape:=true;
     // i:= trial[trial_index].start_j;      9.8.08 auskommentiert
    // i:= current_junction;                // 9.8.08 i wird statt Zeile oben so neu gesetzt
                                            // current_junction wurde in Maze_Corridor aktualisiert
                                            // kann komplett entfallen, da in dieser Prozedur nicht mehr verwendet
    
     //udpSendMsg.x_landscape:=  junction[i].x_junction/25;  //9.8.08 /25, wenn dann überall gleich...
     //udpSendMsg.z_landscape:=  junction[i].z_junction/25;  //9.8.08 vereinheitlicht auf /25 noch ausprobieren

     //x_animal_landscape:= junction[i].x_junction; //10.8.08 ... jetzt mal so probieren
     //z_animal_landscape:= junction[i].z_junction; //10.8.08 ... oder ganz weglassen, wird in GetVmazeCoord sowieso gesetzt

     //...wie in reset udp message
     //          end;
     position_in_duct:= 0;
   //  showmessage('Reset_Corridor_Coord: i='+inttostr(i)+'udpSendMsg.z_landscape'+floattostr(udpSendMsg.z_landscape));
   // i war 2, z war nur 1,5 bzw 1,6 (müsste eigentlich 20 oder 40 sein!
   end;

///////////////////////////////////////////////////////////////////////////////
procedure calc_comp_point(V: TVector; var VKomp: TVector);
// bestimmt den Kompensationspunkt aus aktuellem Positionsvektor und Kreisradius
var
   beta: real;
begin
     beta:= VAngle(V);
     VKomp.k1 := decision_radius* cos(beta);
     VKomp.k2 := decision_radius* sin(beta);
end;

///////////////////////////////////////////////////////////////////////////////
procedure Maze_No_Comp(var VMotor: TVector);
// wird aufgerufen von: Test_Maze wenn maze_state = st_NIX
begin
           VMotor.k1:= 0;
           VMotor.k2:= 0;
end;

///////////////////////////////////////////////////////////////////////////////
procedure Maze_Open_Field(VRatte: TVector; var VMotor: TVector);
// ruft auf: calc_comp_point(...)
// wird aufgerufen von: Test_Maze wenn maze_state = st_OPEN_FIELD
var
   VKomp: TVector;
begin
      if ballState.detected and (not ballState.center) then
      begin
           calc_comp_point(VRatte, VKomp);
           VMotor.k1:= VRatte.k1- VKomp.k1;
           VMotor.k2:= VRatte.k2- VKomp.k2;
      end
         else
      Maze_No_Comp(VMotor);
end;

///////////////////////////////////////////////////////////////////////////////
procedure Maze_Junction(VRatte: TVector; var VMotor: TVector);
// wird aufgerufen von: Test_Maze wenn maze_state = st_JUNCTION
var
   exit_nr : integer;
begin
     Maze_No_Comp(VMotor); // set motor data to 0
     exit_nr:= choice(VRatte); // which corridor does the animal choose?
     // change the color of the edit field according to the choice made
     if exit_nr = 0 then
        form3.edit_choice.Color:= clRed
        else
        form3.edit_choice.Color:= clGreen;

     form3.edit_choice.Text:= IntToStr(exit_nr); // display the result of
                                                 // the function choice(VRatte)
     form3.current_junction_in_Maze_junction.Text:= inttostr(current_junction); //15.8.08

     if exit_nr<>0 then              // animal leaves junction
        with junction[current_junction] do
        begin
                 length_of_duct:= duct_length[exit_nr];// set duct length
                 current_duct:= exit_nr;               // set nr of corridor
                 alpha:= exit_angle[exit_nr]/180*pi;   // alpha in rad
                 maze_state:= st_CORRIDOR;             // change state->corridor
        end;

 x_animal_landscape:=  junction[current_junction].x_junction ;    //neu hier rein 15.8.08
 z_animal_landscape:=  junction[current_junction].z_junction ;


form3.current_junction_coordinates_in_Maze_junction.text:=(('x= ')+ floattostr(x_animal_landscape)+
                                         ( 'z= ')+ floattostr(z_animal_landscape));
end;

///////////////////////////////////////////////////////////////////////////////
procedure Maze_Corridor(VRatte: TVector; var VMotor: TVector);
// wird aufgerufen von: Test_Maze wenn maze_state = st_CORRIDOR
var
   VGang, VRatte_Proj, VKomp: TVector;
   beta, angle_diff : real;
begin
     VGang.k1 := cos(alpha); // current corridor as vector
     VGang.k2 := sin(alpha);
     // calculate the direction on the corridor: forward or backward movement
     if vector_skalar(VGang, VRatte) >= 0 then
        position_in_duct := position_in_duct+ VLength(d_corridor) // forward
        else
        position_in_duct := position_in_duct- VLength(d_corridor); // backward

     form1.edit_position.Text := FloatToStrF(position_in_duct, ffFixed, 3, 3);
     // display position

     //raus 14.8.08   wieder rein
     //(*
     if position_in_duct < 0 then // go back to the previous junction
     //if position_in_duct < (- decision_radius) then // 14.8.08
     begin
          maze_state:= st_JUNCTION; // change state -> junction
          Reset_Corridor_Coord;     // set coordinates to 0
          Maze_No_Comp(VMotor);     // no compensation
     end;
    // *)
     if position_in_duct >= (length_of_duct)then // rat reaches the next junction
     //  +decision_radius 14.8.08 nächste Kreuzung wird nie erreicht
     begin
     // find out which is the new junction
     current_junction:= junction[current_junction].next_junction[current_duct];
     //  current_junction:=2;  //zum testen 14.8.08

      //showmessage (' position_in_duct >= (length_of_duct) current_junction: '+inttostr (current_junction));

      changed_junction:=true;//2.8.
      current_junction_enter_time:= TimeGetTime;
      Reset_Corridor_Coord;     // set Corridor coordinates to 0
      maze_state:= st_JUNCTION; // change state -> junction
      Maze_No_Comp(VMotor);     // no compensation
     end;

     // movement in the corridor between two junctions
     if (position_in_duct >= 0) and (position_in_duct < length_of_duct) then
     begin
          if (not ballState.center) and ballState.detected then
          // compensate only if rat detected by camera
          begin
               beta:= VAngle(VRatte);
               angle_diff := beta-alpha;
               // calculate the vector component which goes in the direction
               // of the corridor
               VRatte_Proj := vector_projection(VRatte, VGang, angle_diff);
               calc_comp_point(VRatte_Proj, VKomp);
              // maze_state:= st_CORRIDOR; // 9.8.08 eingefügt und wieder raus keep state -> corridor
          end
             else
          Maze_No_Comp(VMotor); // no compensation
     end;
     // calculate motor values
     VMotor.k1:= VRatte_Proj.k1- VKomp.k1;
     VMotor.k2:= VRatte_Proj.k2- VKomp.k2;

form3.current_junction_in_Maze_corridor.Text:= inttostr(current_junction); //15.8.08     

end;

///////////////////////////////////////////////////////////////////////////////
procedure maze_STANDBY;
// wird aufgerufen von: Test_Maze wenn maze_state = st_STANDBY
begin
    if ballState.detected then // don't do anything if cam doesn't see the animal
        maze_state:= maze_state_before_standby;
end;

///////////////////////////////////////////////////////////////////////////////
procedure Test_Maze;
var
 VRatte, VMotor : TVector;
 current_time: int64;
begin
     current_time:= TimeGetTime;
//     maze_state:= st_OPEN_FIELD; // TEST
     VRatte.k1 := x_animal_cam; // copy camera coordinates into the rat vector
     VRatte.k2 := z_animal_cam;
     // steuert die Abfolge von Trials


     if ballState.reset_maze and (ballState.reset_time< current_time)
     and ballState.center then      //10.3.09
     begin
          maze_state:= st_JUNCTION;
          ballState.reset_maze:= FALSE;
          y_animal_landscape:=0;
          X_Y_Z_send_koordinates:=true;//15.3.09
          // showmessage(' ');
     end;

    if ballState.reset_maze then maze_state:= st_STANDBY;        //Kugel darf nicht drehen beim absenken
 

     if not ballState.detected then
     // don't do anything if cam doesn't see the animal
     begin
        if maze_state <> st_STANDBY then
           maze_state_before_standby:= maze_state;
        maze_state:= st_STANDBY;
     end;

     form1.Edit_Junction.Text:= IntToStr(current_junction);

     if exp_State<> expRUNNING then // Kompensation nur wenn Ratte im Experiment
        maze_state:= st_NIX;
     Form1.edit_mazeState.text:= GetEnumName(TypeInfo(TmazeState),
     integer(maze_state));
     
     case maze_state of
          st_OPEN_FIELD: Maze_Open_Field(VRatte, VMotor);
          st_JUNCTION:   Maze_Junction(VRatte, VMotor);
          st_CORRIDOR:   Maze_Corridor(VRatte, VMotor);
          st_NIX:        Maze_No_Comp(VMotor);
          st_STANDBY:    Maze_Standby;
     end;
// read the motor values from the motor vector. d_motor_ will be transmitted
     d_motor_x:= VMotor.k1;
     d_motor_z:= VMotor.k2;

     transmit_to_DAC_I2C; // send motor data to the periphery
end;

///////////////////////////////////////////////////////////////////////////////
procedure Get_Animal_Position;
// wertet Kameradaten aus, legt Rat_Rec.detected fest
// wird aufgerufen von: OnIdle
var
   cam_x_scaled, cam_z_scaled : integer;
begin
  cam_x:= meldung_vom_server_x;
  //showmessage(inttostr(cam_x));
  cam_z:= meldung_vom_server_z;

  if (cam_x= 1000) and (cam_z= 1000) then // no object recognition -> both coordinates equal 0
  begin
       ballState.detected := FALSE;
       x_animal_cam := 0;
       z_animal_cam := 0;
  end

  else begin                            // object has been recognized -> coordinates > 0
       ballState.detected := TRUE;
       // x_animal_cam:=round(cam_x - (+4+ 11+ 68 / 2) ); // korrektur + l rand + mitte
       // z_animal_cam:=-round(cam_z - CAM_X_MAX / 2);
       //                     Sensor1 und Motor2
       //                   191/-20
       //
       //
       //
       //
       // Sensor2 und Motor1
       // z <-   5/190                          7/-197
       //     |
       //     x
       //
       //
       //                    -196/3   -> Tür -> positive x Richtung
       // Mitte:  -3 / -4
       // dx = dy = 0,49m / 387px = 0,00127 m/px = 1,27 mm/px

       // Kamerakoordinaten gemessen mit schwarzem Kästchen 4x4cm, vor den Türchen:
       //  (Koordinaten aus Form1, wie sie im Programm verwendet werden, nicht Rohdaten
       //
       //
       //
       //
       //         220/110               206/-133
       //
       //
       //
       //
       //
       // 13/246                                    -13/-245
       //
       //
       //
       //
       //
       //         -212/128              -220/-109
       //


       x_animal_cam:= round( cam_x * BASLER_DX );
       z_animal_cam:= round( cam_z * BASLER_DZ );
  end;

  if ballState.detected then

     if Sqr(x_animal_cam)+Sqr(z_animal_cam)>Sqr(decision_radius) then           {decision made, decision_radius=150}
     begin
     ballState.center := FALSE;
     form3.Edit_Cam_xz.Color := clGreen;
     end

     else begin
     ballState.center := TRUE;
     form3.Edit_Cam_xz.Color := clRed;
     end;

form3.Edit_Cam_xz.Text:=('x= '+inttostr(x_animal_cam)+' z= '+inttostr(z_animal_cam));

end;


//////////////////////////////////////////////////////////////////////////////
procedure Read_IO_Config;
  var
  zufall: integer;
// reads the hardware address of IO Pins
// function:           Feeder, LB1, Servo L, Servo R, LB2
// index:                 0     1      2       3       4

begin
   (*
   function Random [ ( Range: Integer) ];

Beschreibung

Random gibt eine Zufallszahl im Bereich 0 <= X < Range zurück.

   zufall:= random (2:integer);
      *)
      
    form1.Memo_Sendepuffer.Lines.add('read_IO_config...');
   fill_array(TrEinheit[1].adresse           , 0, 1, 2, 3, 4);
  //   fill_array(TrEinheit[1].feeder_duration   , 488, 0, 2000, 2000, 0);      //feeder_duration for 100 myl water
  fill_array(TrEinheit[1].feeder_duration   , 244, 0, 2000, 2000, 0);       //7.6.09
 //fill_array(TrEinheit[1].feeder_duration   , 1500, 0, 2000, 2000, 0);      //feeder_duration for ca 300 myl water
//   fill_array(TrEinheit[1].current_state     , 0, 1, 0, 0, 1);

   fill_array(TrEinheit[2].adresse           , 5, 6, 7, 16, 17);
  // fill_array(TrEinheit[2].feeder_duration   , 443, 0, 2000, 2000, 0);
    fill_array(TrEinheit[2].feeder_duration   , 222, 0, 2000, 2000, 0);    //7.6.09
  //fill_array(TrEinheit[2].feeder_duration   , 1500, 0, 2000, 2000, 0);      //feeder_duration for ca 300 myl water
  //   fill_array(TrEinheit[2].current_state     , 0, 1, 0, 0, 1);

   fill_array(TrEinheit[3].adresse           , 18, 19, 20, 21, 22);
   //  fill_array(TrEinheit[3].feeder_duration   , 410, 0, 2000, 2000, 0);
    fill_array(TrEinheit[3].feeder_duration   , 205, 0, 2000, 2000, 0);     //7.6.09
 //fill_array(TrEinheit[3].feeder_duration   , 1500, 0, 2000, 2000, 0);      //feeder_duration for ca 300 myl water
 //   fill_array(TrEinheit[3].current_state     , 0, 1, 0, 0, 1);

   fill_array(TrEinheit[4].adresse           , 23, 28, 31, 40, 41);
     // fill_array(TrEinheit[4].feeder_duration   , 477, 0, 2000, 2000, 0);
  fill_array(TrEinheit[4].feeder_duration   , 239, 0, 2000, 2000, 0);     //7.2.09
 //fill_array(TrEinheit[4].feeder_duration   , 1500, 0, 2000, 2000, 0);      //feeder_duration for ca 300 myl water
 //   fill_array(TrEinheit[4].current_state     , 0, 1, 0, 0, 1);

   fill_array(TrEinheit[5].adresse           , 42, 43, 44, 45, 47);
    //  fill_array(TrEinheit[5].feeder_duration   , 468, 0, 2000, 2000, 0);
  fill_array(TrEinheit[5].feeder_duration   , 234, 0, 2000, 2000, 0);     //7.2.09
 //fill_array(TrEinheit[5].feeder_duration   , 1500, 0, 2000, 2000, 0);      //feeder_duration for ca 300 myl water
 //   fill_array(TrEinheit[5].current_state     , 0, 1, 0, 0, 1);

   fill_array(TrEinheit[6].adresse           , 34, 35, 36, 37, 38);
   //  fill_array(TrEinheit[6].feeder_duration   , 396, 0, 2000, 2000, 0);
 fill_array(TrEinheit[6].feeder_duration   , 198, 0, 2000, 2000, 0);      //7.2.09
 //fill_array(TrEinheit[6].feeder_duration   , 1500, 0, 2000, 2000, 0);      //feeder_duration for ca 300 myl water
 //   fill_array(TrEinheit[6].current_state     , 0, 1, 0, 0, 1);

{   fill_array(TrEinheit[7].adresse           , 12, 13, 0, 0, 0);
   fill_array(TrEinheit[7].feeder_duration   , 100, 0, 2000, 2000, 0);
//   fill_array(TrEinheit[7].current_state     , 0, 1, 0, 0, 1);

   fill_array(TrEinheit[8].adresse           , 14, 15, 0, 0, 0);
   fill_array(TrEinheit[8].feeder_duration   , 100, 0, 2000, 2000, 0);
//   fill_array(TrEinheit[8].current_state     , 0, 1, 0, 0, 1);            }



   form1.Memo_Sendepuffer.Lines.add('          done');
end;




///////////////////////////////////////////////////////////////////////////////
procedure Initialize_LB_Feeder;

//************* INITIALISIERUNG DER PERIPHERIE GERÄTE

// Initialisierung der IO Pins für Lichtschranken und Ventile
// Man teilt dem Controller mit, ob Pins Input- oder Outputfunktion haben
// und man setzt den Anfangszustand fest (high = 5V, lo = 0V)
// aufgerufen von: init_laku
// ruft auf: send_to_ser_buffer(...)

var
   i : integer;
   init_byte : byte;
   current_time : int64;
begin
     form1.memo_sendepuffer.Lines.add('initialize LB and Feeder...');
     current_time := TimeGetTime;
//   Ventile (= Feeder) initialisieren
     for i := 1 to MAX_TR_EINHEITEN do
     begin
     init_byte := TrEinheit[i].adresse[0] or $C0;
     send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                        feeder_code, init_byte, 0, current_time,
                        MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
//     form1.memo_sendepuffer.Lines.add('Feeder no. ' + inttostr(i) +
//                                       ' initbyte= '+ inttohex(init_byte, 2));
     end;

//   Lichtschranken (= LB1) initialisieren
     for i := 1 to MAX_TR_EINHEITEN do
     begin
       init_byte := TrEinheit[i].adresse[1] or $40;
       send_to_ser_buffer(LB_controller, LB_bus, LB_i2c,
                        LB_code, init_byte, 0, current_time,
                        MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
//       form1.memo_sendepuffer.Lines.add('LB no. ' + inttostr(i)+
//                                       ' initbyte= '+ inttohex(init_byte, 2));
     end;

//   Lichtschranken (= LB2) initialisieren
     for i := 1 to MAX_TR_EINHEITEN do
     begin
       init_byte := TrEinheit[i].adresse[4] or $40;
       send_to_ser_buffer(LB_controller, LB_bus, LB_i2c,
                        LB_code, init_byte, 0, current_time,
                        MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
//       form1.memo_sendepuffer.Lines.add('LB no. ' + inttostr(i)+
//                                      ' initbyte= '+ inttohex(init_byte, 2));
     end;

   form1.Memo_Sendepuffer.Lines.add('          done');
end;


///////////////////////////////////////////////////////////////////////////////
procedure Initialize_Servo;

// Initialisierung der IO Pins für Servo-Motoren
// aufgerufen von: init_laku
// ruft auf: send_to_ser_buffer(...)

var
   i : integer;
   init_byte : byte;
   current_time : int64;
begin
     form1.memo_sendepuffer.Lines.add('init servo...');
     current_time := TimeGetTime;
     for i := 1 to MAX_TR_EINHEITEN do
     begin
          init_byte := TrEinheit[i].adresse[2] or $C0;
          send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                        feeder_code, init_byte, 0, current_time,
                        MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);

          init_byte := TrEinheit[i].adresse[3] or $C0;
          send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                        feeder_code, init_byte, 0, current_time,
                        MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
     end;
   form1.Memo_Sendepuffer.Lines.add('          done');
   // alle Türen bei Programmstart schließen
   // Trafostrom reicht nicht um alle Servos gleichzeitig zu betreiben ->
   // einzeln schließen
  (*  for i:=1 to  MAX_TR_EINHEITEN do

     begin
            door(i, false, current_time); // close all doors, especially door 5
     end;
     *)
     door(5, false, current_time);   //close door 5
    end;

//////////////////////////////////////////////////////////////////////////

Procedure Initialize_Motors;
 //!!!Kommentar alt
// Hier wird der DA Wandler der Motorsteuerung gestartet und die Spannung auf 0 V gelegt
// Einzelheiten zu den Kommandobytes im Datenblatt MAX 5812 S. 10 ff
// Der MAX 5812 muss zuerst in den power-up modus gesetzt werden, erst dann
// sendet man Stellbefehle.
// aufgerufen von: init_laku
// ruft auf: send_to_ser_buffer(...)
// byte 1: Hauptcontroller, hier immer 01
// byte 2: I2C bus am Hauptcontroller
// byte 3: I2C Adresse des DA Wandlers
// byte 4: Kürzel für Funktion - nur für den Hauptcontroller relevant
// byte 5: bits 7..4 Kommando -> Datenblatt
//         bits 3..0 Spannung
// byte 6: Spannung -> Zusammenlegen von byte 5 und 6 ergibt die eingestellte Spannung
// $0800 = 2048 = 0V


var
   current_time : int64;
begin
   form1.Memo_Sendepuffer.Lines.add('Init Motors...');
   current_time := TimeGetTime;
   // Power up
   Send_To_Ser_Buffer(Motor_Controller, Motor1_Bus, Motor1_I2C,
                      Motor_Code, Motor_PowerUp, $00, current_time+100,
                      MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
   // set the output voltage to 0 V
   Send_To_Ser_Buffer(Motor_Controller, Motor1_Bus, Motor1_I2C,
                 Motor_Code or $01, Motor_Command or $08, $00, current_time+200,
                      MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
   // Power up
   Send_To_Ser_Buffer(Motor_Controller, Motor2_Bus, Motor2_I2C,
                      Motor_Code, Motor_PowerUp, $00, current_time+300,
                      MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
   // set the output voltage to 0 V
   Send_To_Ser_Buffer(Motor_Controller, Motor2_Bus, Motor2_I2C,
                 Motor_Code or $01, Motor_Command or $08, $00, current_time+400,
                      MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
   form1.Memo_Sendepuffer.Lines.add('          done');
end;

// ENDE INITIALISIERUNG DER PERIPHERIE GERÄTE
///////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
//Go- Button, Haupt-Knopf zum starten!
/////////////////////////////////////////////////////////////////////////
procedure TForm1.Button1Click(Sender: TObject);
var
x_kor, z_kor:string;
x_kor_int, z_kor_int,j:integer;  // die x/z-Positionen als Integer Var
y_current_time, time_pos_y_down:int64;   //für y-Absenkung 18.08.08 auskommtiert

begin
  Fullscreen:=TRUE;
  ColorDepth:=32;
  resX:=1024;
  resY:=768;

  Try
  rechner_nummer:=strtoint(form1.rechnerwahl.text);  // Rechnernummer von 0
                                                     // bis 6 eingeben
  except
  showmessage('Only integer variables for Labyrinth height and Labyrinth width allowed');
  end;

  form1.server.DefaultPort:=8080;
  form1.Server.active:=True;
  form1.server.BroadcastEnabled:=true;

  if rechner_nummer=0 then // begin
     if timer_start then
     begin
        timer_start := FALSE
     end else
     begin

          timer_start := TRUE;
          init_laku;

     end;

///////////////////////////////////////////////////////////////////////////////



    //neu 24.7.08
     if rechner_nummer=1   then begin
        Form1.hide;
        alpha_view:= 180;
        init_grafic;
        WinMain;

        while Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
        begin

          if udpRecMsg.rebuild=1  then
          begin
           (*18.08.08 hier entfernt, jetzt in MyIdleHandler
           ///////////////////////////////////////////////////////////
           //hier testen: die Landschaft in y-Richtung absenken,
           // um für kurze Zeit schwarze Bildschirme zu bekommen
            pos.y:=-20.0;

           time_pos_y_down:=y_current_time;

           udpRecMsg.old:=true; *)

           InitOpenGL;  //Landmarken aktualisieren
           //showmessage('RESET');
           udpRecMsg.rebuild:=0;

           end;
           (*18.08.08 hier entfernt, jetzt in MyIdleHandler
           if (time_pos_y_down+ time_down> y_current_time) and
             udpRecMsg.old = true then
                begin
                pos.y:=0.0;
                InitOpenGL;  //Landschaft wieder rauffahren
                message_fuer_hauptschleife;
                frame_fuer_hauptschleife; //?
                udpRecMsg.old:=false;
                end; *)
   message_fuer_hauptschleife;
   inc(Frame);
   if keys[VK_ESCAPE] then Done:=TRUE;
   frame_fuer_hauptschleife;    //hier wird gldraw aufgerufen, und in gldraw
                //werden u.a. die Koordinaten auf dem Bildschirm angezeigt
                //und die Koordinaten pos.x,... verwendet


   end;   //Ende der Hauptschleife

        killwnd;
        Form1.Close;
 end;                        //Ende rechner_nummer 1 vom 24.7
 /////////////////////////////////////////////////////////

 /////////////////////////////////////////////////////////
   if rechner_nummer=2   then begin
        Form1.hide;
        alpha_view:= 120;
        init_grafic;
        WinMain;

        while Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
        begin
          y_current_time:=timegettime; //für y-Absenkung

          if udpRecMsg.rebuild=1  then
          begin
         (*   raus 6.2.09///////////////////////////////////////////////////////////
           //hier testen: die Landschaft in y-Richtung absenken,
           // um für kurze Zeit schwarze Bildschirme zu bekommen
            pos.y:=-20.0;

           time_pos_y_down:=y_current_time;

           udpRecMsg.old:=true;
              *)
           InitOpenGL;  //Landmarken aktualisieren  und absenken
           //showmessage('RESET');
           message_fuer_hauptschleife;
           frame_fuer_hauptschleife; //?
            udpRecMsg.rebuild:=0;

            //showmessage('rebuild');
          end;
          ////////Ende rebuild=1
             (*
             if (time_pos_y_down+ time_down> y_current_time) and
             udpRecMsg.old = true then
                begin
                pos.y:=0.0;
                InitOpenGL;  //Landschaft wieder rauffahren
                message_fuer_hauptschleife;
                frame_fuer_hauptschleife; //?
                udpRecMsg.old:=false;
                end;
               *)

                message_fuer_hauptschleife;
                inc(Frame);
                if keys[VK_ESCAPE] then Done:=TRUE;
                frame_fuer_hauptschleife;    //hier wird gldraw aufgerufen, und in gldraw
               //werden u.a. die Koordinaten auf dem Bildschirm angezeigt  und die Koordinaten pos.x,... verwendet


        end;   //Ende der Hauptschleife

        killwnd;
        Form1.Close;
    end;                    //Ende rechner-nummer 2

 /////////////////////////////////////////////////////////
   if rechner_nummer=3   then begin
        Form1.hide;
        alpha_view:= 60;
        init_grafic;
        WinMain;

        while Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
        begin
          y_current_time:=timegettime; //für y-Absenkung

          if udpRecMsg.rebuild=1  then
          begin
          (*   raus 6.2.09  ///////////////////////////////////////////////////////////
           //hier testen: die Landschaft in y-Richtung absenken,
           // um für kurze Zeit schwarze Bildschirme zu bekommen
            pos.y:=-20.0;

           time_pos_y_down:=y_current_time;

           udpRecMsg.old:=true;
            *)
           InitOpenGL;  //Landmarken aktualisieren  und absenken
           //showmessage('RESET');
           message_fuer_hauptschleife;
           frame_fuer_hauptschleife; //?
            udpRecMsg.rebuild:=0;

            //showmessage('rebuild');
          end;
          ////////Ende rebuild=1
           (*
             if (time_pos_y_down+ time_down> y_current_time) and
             udpRecMsg.old = true then
                begin
                pos.y:=0.0;
                InitOpenGL;  //Landschaft wieder rauffahren
                message_fuer_hauptschleife;
                frame_fuer_hauptschleife; //?
                udpRecMsg.old:=false;
                end;
             *)

                message_fuer_hauptschleife;
                inc(Frame);
                if keys[VK_ESCAPE] then Done:=TRUE;
                frame_fuer_hauptschleife;    //hier wird gldraw aufgerufen, und in gldraw
               //werden u.a. die Koordinaten auf dem Bildschirm angezeigt  und die Koordinaten pos.x,... verwendet


        end;   //Ende der Hauptschleife

        killwnd;
        Form1.Close;
    end;                       //Ende rechner-nummer 3


 ////rechner_nr4 vom 24.7./////////////////////////////////////////////////////
     if rechner_nummer=4   then begin
        Form1.hide;
        alpha_view:= 0;
        init_grafic;
        WinMain;

        while Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
        begin

          if udpRecMsg.rebuild=1  then
          begin
           InitOpenGL;  //Landmarken aktualisieren
           //showmessage('RESET');
           udpRecMsg.rebuild:=0;

       (*   raus 6.2.09     ///////////////////////////////////////////////////////////
           //hier testen: die Landschaft in y-Richtung absenken,
           // um für kurze Zeit schwarze Bildschirme zu bekommen
            y_current_time:=timegettime; //für y-Absenkung
            time_pos_y_down:=y_current_time;
            pos.y:=-20.0;
            udpRecMsg.old:=true;
          *)
           end;

       (*    if (time_pos_y_down+ time_down> y_current_time) and
             udpRecMsg.old = true then
                begin
                pos.y:=0.0; //Ende Absenken
                udpRecMsg.old:=false;
                end;

             *)
   message_fuer_hauptschleife;
   inc(Frame);
   if keys[VK_ESCAPE] then Done:=TRUE;
   frame_fuer_hauptschleife;    //hier wird gldraw aufgerufen, und in gldraw
                //werden u.a. die Koordinaten auf dem Bildschirm angezeigt
                //und die Koordinaten pos.x,... verwendet


   end;   //Ende der Hauptschleife

        killwnd;
        Form1.Close;
 end;                        //Ende rechner_nummer 1 vom 24.7
 /////////////////////////////////////////////////////////
 //////////////////////////////////

 /////////////////////////////////////////////////////////

   if rechner_nummer=5   then begin
        Form1.hide;
        alpha_view:= 300;
        init_grafic;
        WinMain;

        while Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
        begin
          y_current_time:=timegettime; //für y-Absenkung

          if udpRecMsg.rebuild=1  then
          begin
          (*   raus 6.2.09  ///////////////////////////////////////////////////////////
           //hier testen: die Landschaft in y-Richtung absenken,
           // um für kurze Zeit schwarze Bildschirme zu bekommen
            pos.y:=-20.0;

           time_pos_y_down:=y_current_time;

           udpRecMsg.old:=true;
           *)
           InitOpenGL;  //Landmarken aktualisieren  und absenken
           //showmessage('RESET');
           message_fuer_hauptschleife;
           frame_fuer_hauptschleife; //?
            udpRecMsg.rebuild:=0;

            //showmessage('rebuild');
          end;
          ////////Ende rebuild=1
          (*
             if (time_pos_y_down+ time_down> y_current_time) and
             udpRecMsg.old = true then
                begin
                pos.y:=0.0;
                InitOpenGL;  //Landschaft wieder rauffahren
                message_fuer_hauptschleife;
                frame_fuer_hauptschleife; //?
                udpRecMsg.old:=false;
                end;
              *)

                message_fuer_hauptschleife;
                inc(Frame);
                if keys[VK_ESCAPE] then Done:=TRUE;
                frame_fuer_hauptschleife;    //hier wird gldraw aufgerufen, und in gldraw
               //werden u.a. die Koordinaten auf dem Bildschirm angezeigt  und die Koordinaten pos.x,... verwendet


        end;   //Ende der Hauptschleife

        killwnd;
        Form1.Close;
    end;                //Ende rechner_nummer 5
 /////////////////////////////////////////////////////////
   if rechner_nummer=6   then begin
        Form1.hide;
        alpha_view:= 240;
        init_grafic;
        WinMain;

        while Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
        begin
          y_current_time:=timegettime; //für y-Absenkung

          if udpRecMsg.rebuild=1  then
          begin
          (*   raus 6.2.09  ///////////////////////////////////////////////////////////
           //hier testen: die Landschaft in y-Richtung absenken,
           // um für kurze Zeit schwarze Bildschirme zu bekommen
            pos.y:=-20.0;

           time_pos_y_down:=y_current_time;

           udpRecMsg.old:=true;
           *)
           InitOpenGL;  //Landmarken aktualisieren  und absenken
           //showmessage('RESET');
           message_fuer_hauptschleife;
           frame_fuer_hauptschleife; //?
            udpRecMsg.rebuild:=0;

            //showmessage('rebuild');
          end;
          ////////Ende rebuild=1
            (*
             if (time_pos_y_down+ time_down> y_current_time) and
             udpRecMsg.old = true then
                begin
                pos.y:=0.0;
                InitOpenGL;  //Landschaft wieder rauffahren
                message_fuer_hauptschleife;
                frame_fuer_hauptschleife; //?
                udpRecMsg.old:=false;
                end;
               *)

                message_fuer_hauptschleife;
                inc(Frame);
                if keys[VK_ESCAPE] then Done:=TRUE;
                frame_fuer_hauptschleife;    //hier wird gldraw aufgerufen, und in gldraw
               //werden u.a. die Koordinaten auf dem Bildschirm angezeigt  und die Koordinaten pos.x,... verwendet


        end;   //Ende der Hauptschleife

        killwnd;
        Form1.Close;
    end;            //Ende rechner_nummer 6
 /////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////

        if rechner_nummer=10 then begin      //zum testen, wie Rechner Nummer1, nur dass keine DAten verschickt werden
//        Form1.hide;
       // alpha_view:=0;       // Blickrichtung gerade nach vorne
        //alpha_view:=350;  //Blickrichtung leicht nach rechts gedreht (mit Uhr)
        //alpha_view:=10;   // Blickrichtung leicht nach links gedreht (gegen die Uhr)
        //alpha_view:=180;     //wie Rechner 1
        alpha_view:=0;     //wie Rechner 4

        init_laku;
        Trial_index:=1;

         for j:=0 to trMAXJUNCTIONS do
                begin
               //Spalten: Kreuzungen, Zeilen: Landmarken 0-6

               udpRecMsg.arJunction[j,1]:=
               trial[trial_index].trialjunction[j].local_lm_junction[1];

               udpRecMsg.arJunction[j,2]:=
               trial[trial_index].trialjunction[j].local_lm_junction[2];

               udpRecMsg.arJunction[j,3]:=
               trial[trial_index].trialjunction[j].local_lm_junction[3];

               udpRecMsg.arJunction[j,4]:=
               trial[trial_index].trialjunction[j].local_lm_junction[4];

               udpRecMsg.arJunction[j,5]:=
               trial[trial_index].trialjunction[j].local_lm_junction[5];

               udpRecMsg.arJunction[j,6]:=
               trial[trial_index].trialjunction[j].local_lm_junction[6];

                end;

               udpRecMsg.arDistalLM.reLM1:= trial[trial_index].distal_lm[1];
               udpRecMsg.arDistalLM.reLM2:= trial[trial_index].distal_lm[2];
               udpRecMsg.arDistalLM.reLM3:= trial[trial_index].distal_lm[3];
               udpRecMsg.arDistalLM.reLM4:= trial[trial_index].distal_lm[4];
               udpRecMsg.arDistalLM.reLM5:= trial[trial_index].distal_lm[5];
               udpRecMsg.arDistalLM.reLM6:= trial[trial_index].distal_lm[6];


        resetUDPLandscape;
        WinMain;


        while Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
                begin
                  if udprecMsg.rebuild=1  then glDraw;  //Landmarken aktualisieren
                udprecMsg.rebuild:=0;
                message_fuer_hauptschleife;
                inc(Frame);
                if keys[VK_ESCAPE] then Done:=TRUE;
                //showmessage('1 vor casekeys');
                CaseKeys; // procedure for movement
                          //legt pos.x und pos.z über Tastatureingabe fest
                // showmessage('1 nach casekeys');


                // Koordinaten zu einem String zusammenbauen aus der Prozedur casekeys

                x_Kor_int:=round(Pos.x);  //x_Kor_int:=round(Pos_x);
                z_Kor_int:=round(Pos.z);  //z_Kor_int:=round(Pos_z);
                x_Kor:=inttostr(x_Kor_int);
                z_Kor:=inttostr(z_Kor_int);

                x_z_koordinaten:=(x_Kor + ';'+z_Kor);
                if x_z_koordinaten<>x_z_koordinaten_old then

                // koordinaten_senden;
                x_z_koordinaten_old:=x_z_koordinaten;
                (*
                x_s:=x_Kor;   //x_s, z_s: Koordinatenbezeichnenugen von Ulf,
                              //werden in glDraw so gebraucht
                z_s:=z_Kor;
                 *)

                frame_fuer_hauptschleife;//hier wird gldraw aufgerufen, und in gldraw
                        //werden u.a. die Koordinaten auf dem Bildschirm angezeigt

       end;   //Ende der Hauptschleife

     killwnd;
  Form1.Close;
  end;
 //////Rechner_nummer_10///////////////////////////////////////

 //////////////////////////////////////////////////////////////////////////

   if rechner_nummer=11 then //   // ähnlich 10, aber ohne Server-Verbindung
   begin
        // Form1.hide;
        // alpha_view:=0;       // Blickrichtung gerade nach vorne
        // alpha_view:=350;  //Blickrichtung leicht nach rechts gedreht (mit Uhr)
        // alpha_view:=10;   // Blickrichtung leicht nach links gedreht (gegen die Uhr)
         alpha_view:=180;     //wie Rechner 1
        // alpha_view:=0;     //wie Rechner 4

        //init_laku;
          init_grafic;
          Proc_file_name:=form1.procedure_file.text;
          read_procedure_file;

        Trial_index:=1;

         for j:=0 to trMAXJUNCTIONS do
                begin
               //Spalten: Kreuzungen, Zeilen: Landmarken 0-6

               udpRecMsg.arJunction[j,1]:=
               trial[trial_index].trialjunction[j].local_lm_junction[1];

               udpRecMsg.arJunction[j,2]:=
               trial[trial_index].trialjunction[j].local_lm_junction[2];

               udpRecMsg.arJunction[j,3]:=
               trial[trial_index].trialjunction[j].local_lm_junction[3];

               udpRecMsg.arJunction[j,4]:=
               trial[trial_index].trialjunction[j].local_lm_junction[4];

               udpRecMsg.arJunction[j,5]:=
               trial[trial_index].trialjunction[j].local_lm_junction[5];

               udpRecMsg.arJunction[j,6]:=
               trial[trial_index].trialjunction[j].local_lm_junction[6];

                end;

               udpRecMsg.arDistalLM.reLM1:= trial[trial_index].distal_lm[1];
               udpRecMsg.arDistalLM.reLM2:= trial[trial_index].distal_lm[2];
               udpRecMsg.arDistalLM.reLM3:= trial[trial_index].distal_lm[3];
               udpRecMsg.arDistalLM.reLM4:= trial[trial_index].distal_lm[4];
               udpRecMsg.arDistalLM.reLM5:= trial[trial_index].distal_lm[5];
               udpRecMsg.arDistalLM.reLM6:= trial[trial_index].distal_lm[6];


        resetUDPLandscape;
        WinMain;


        while Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
                begin
                  if udprecMsg.rebuild=1  then glDraw;  //Landmarken aktualisieren
                udprecMsg.rebuild:=0;
                message_fuer_hauptschleife;
                inc(Frame);
                if keys[VK_ESCAPE] then Done:=TRUE;
                //showmessage('1 vor casekeys');
                CaseKeys; // procedure for movement
                          //legt pos.x und pos.z über Tastatureingabe fest
                // showmessage('1 nach casekeys');
                // pos.y:=-2; //18.8.08 als Test eingefügt: - = Vogelperspektive
                              //                            + = Froschperspektive

                // Koordinaten zu einem String zusammenbauen aus der Prozedur casekeys

                x_Kor_int:=round(Pos.x);  //x_Kor_int:=round(Pos_x);
                z_Kor_int:=round(Pos.z);  //z_Kor_int:=round(Pos_z);
                x_Kor:=inttostr(x_Kor_int);
                z_Kor:=inttostr(z_Kor_int);

                x_z_koordinaten:=(x_Kor + ';'+z_Kor);
                if x_z_koordinaten<>x_z_koordinaten_old then

                // koordinaten_senden;
                x_z_koordinaten_old:=x_z_koordinaten;

                udpRecMsg.x_landscape:= Pos.x; // wird hier so gesetzt, um die
                udpRecMsg.z_landscape:= Pos.z; // Koordinaten am Bildschirm
                                               // (Grafikmodus) anzuzeigen 
                (*
                x_s:=x_Kor;   //x_s, z_s: Koordinatenbezeichnenugen von Ulf,
                              //werden in glDraw so gebraucht
                z_s:=z_Kor;
                 *)

                frame_fuer_hauptschleife;//hier wird gldraw aufgerufen, und in gldraw
                        //werden u.a. die Koordinaten auf dem Bildschirm angezeigt

       end;   //Ende der Hauptschleife

     killwnd;
     Form1.Close;
  end;// ende 11
 ////////////////////////////////////////////////////////////////////////

       close_laku;

       //*****************************************************//


  end;

///////////////////////////////////////////////////////////////////////////////
//Abort-Knopf
procedure TForm1.ButtonAbortClick(Sender: TObject);
begin
     close_laku;
     Form1.Close;
end;


///////////////////////////////////////////////////////////////////////////////
 procedure TForm1.ServerUDPRead(Sender: TObject; AData: TStream;
  ABinding: TIdSocketHandle);

  // bei Rechner-Wahl 1-6: UDP-Daten empfangen

var
   len, i, j: integer;
   temp : real;
   size: integer;
   msg_str: string;

begin
   try
   len:= SizeOf(udpRecMsg.rebuild);
   AData.Read(udpRecMsg.rebuild, len);

   len:= SizeOf(udpRecMsg.x_landscape);
   AData.Read(udpRecMsg.x_landscape, len);

   len:= SizeOf(udpRecMsg.y_landscape);
   AData.Read(udpRecMsg.y_landscape, len);

   //udpRecMsg.y_landscape:=20;// 20.8.08
  
   len:= SizeOf(udpRecMsg.z_landscape);
   AData.Read(udpRecMsg.z_landscape, len);
//**********************************************

  if udpRecMsg.rebuild= 1 then
  begin


        for i:= 0 to max_number_of_junctions do
        begin
                len:= sizeOf(udpRecMsg.arJunction[i, 1]);
                AData.read(udpRecMsg.arJunction[i, 1], len);
              //   len:= sizeOf(udpRecMsg.arJunction[i, 2]);           //8.2.09 len für alle extra
                AData.read(udpRecMsg.arJunction[i, 2], len);         //9.2.02 wieder raus
             //   len:= sizeOf(udpRecMsg.arJunction[i, 3]);
                AData.read(udpRecMsg.arJunction[i, 3], len);
             //   len:= sizeOf(udpRecMsg.arJunction[i, 4]);
                AData.read(udpRecMsg.arJunction[i, 4], len);
             //   len:= sizeOf(udpRecMsg.arJunction[i, 5]);
                 AData.read(udpRecMsg.arJunction[i, 5], len);
             //   len:= sizeOf(udpRecMsg.arJunction[i, 6]);
                AData.read(udpRecMsg.arJunction[i, 6], len);
        end;

     len:=SizeOf(llm_colour);
     AData.read (llm_colour, len);

     len:= SizeOf(udpSendMsg.arDistalLM.reLM1);
     AData.read(udpRecMsg.arDistalLM.reLM1, len);
    // len:= SizeOf(udpSendMsg.arDistalLM.reLM2);
     AData.read(udpRecMsg.arDistalLM.reLM2, len);
   //  len:= SizeOf(udpSendMsg.arDistalLM.reLM3);
     AData.read(udpRecMsg.arDistalLM.reLM3, len);
    // len:= SizeOf(udpSendMsg.arDistalLM.reLM4);
     AData.read(udpRecMsg.arDistalLM.reLM4, len);
   //  len:= SizeOf(udpSendMsg.arDistalLM.reLM5);
     AData.read(udpRecMsg.arDistalLM.reLM5, len);
   //  len:= SizeOf(udpSendMsg.arDistalLM.reLM6);
     AData.read(udpRecMsg.arDistalLM.reLM6, len);

    (*
     udpRecMsg.x_landscape:=udpRecMsg.x_landscape;   //Korrektur *25 vom Wände malen aufheben 29.7.08 erfolglos
     udpRecMsg.z_landscape:=udpRecMsg.z_landscape;
     *)

    // showmessage( 'distLM 1 ' + floattostr(udpRecMsg.arDistalLM.reLM1)+ 'len '+inttostr(len));
    // showmessage( 'distLM 2 ' + floattostr(udpRecMsg.arDistalLM.reLM2)+ 'len '+inttostr(len));
  (* raus 18.8.08
    showmessage(' udpRecMsg.rebuild='+inttostr(udpRecMsg.rebuild)+
                ' udpRecMsg.x_landscape='+ floattostr(udpRecMsg.x_landscape)+
                ' udpRecMsg.z_landscape='+ floattostr(udpRecMsg.z_landscape)+
                ' current_junction='+ inttostr(current_junction) +
                ' junction.number_junction'+inttostr(junction[current_junction].number_junction));
  *)
  end; // Ende rebuild= 1




        pos.x:=udpRecMsg.x_landscape;
        //pos.y:=0.0;
        pos.y:=udpRecMsg.y_landscape;   //eingefügt am 18.08.08 zum Landschaft absenken
        pos.z:=udpRecMsg.z_landscape;

        // temp := pos.x;          am 8.8.08 auskommentiert, Anschlüsse Wegaufnehmer wurden getauscht
        // pos.x := -pos.z;
        // pos.z := temp;
     except
       showmessage('exeption');
   end;
    (* 
   if udpRecMsg.rebuild= 1 then
   begin
     for i:= 0 to 2 do
      edit_distLM.text:= edit_distLM.text+(inttostr(udpRecMsg.arJunction[i, 1])+
                                           ' '+
                                         inttostr(udpRecMsg.arJunction[i, 2])+
                                         ' '+
                                         inttostr(udpRecMsg.arJunction[i, 3])+
                                         ' '+
                                         inttostr(udpRecMsg.arJunction[i, 4])+
                                         ' '+
                                         inttostr(udpRecMsg.arJunction[i, 5])+
                                         ' '+
                                         inttostr(udpRecMsg.arJunction[i, 6])+
                                         ' ');
   end; *)
   //showmessage(edit_distLM.text);
   //edit_distLM.text:= '';
   //showmessage(edit_distLM.text);
end;

////////////////////////////////////////////////////////////////////////////////
procedure TForm1.FormCreate(Sender: TObject);
var
   i: integer;
begin
try
  Counter := 0;
  timer_start := FALSE;
  index_serial := 0;
  ballState.current_rat := 1;

       for i:=1 to 12 do
          LB_wait[i]:= FALSE;

//  cam_data.scale_y := CAM_X_MAX / CAM_Y_MAX;

    form1.Server.DefaultPort := 8080;   //Host
    form1.Server.Broadcastenabled:=true;
    form1.server.active:=true;
    form1.Client1.Port := 8080;    //Client
    //form1.Client1.Host := '169.254.168.98'; //IP-Versuchsrechner
    //form1.Client1.Host := '192.168.2.22';   //IP-Laptop Ursula
    //form1.Client1.Host:= '192.168.2.44';    //IP-Rechner Ursula
    form1.client1.Host:='169.254.168.1';      //IP-Adresse Versuchsrechner acer
    //'127.0.0.1' eigene Adresse  '169.254.168.98' IP-Versuchsrechner
    form1.Client1.Broadcastenabled:=true;

    // start values for the serialNG interface (RS232)
    
  SerialPortNG1.Active := True;
  SerialPortNG2.Active := True;
  RxDCharStartTimer := False;
  RxDCharResetTimer := False;
  SerFrame.frame_complete := false;

// define the procedure to be called when the applications state becomes OnIdle

  Application.OnIdle := Form1.MyIdleHandler;
  except     //Im Fehlerfall wieder freigeben (ältere Versionen)
    form1.Client1.Free;
    form1.Server.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.FormDestroy(Sender: TObject);
begin
     form1.server.free;
     form1.client1.free;
     SerialPortNG1.Active:=false;
     SerialPortNG2.Active:=false;
end;

///////////////////////////////////////////////////////////////////////////////
procedure Read_Bytes(S: String; var SerFrame: TSerFrame);
// ruft auf: ReadSer(...)
// wird aufgerufen von: TForm1.SerialPortNG1RxClusterEvent(...)
var
   i : integer;
begin
//     form1.Memo_Empfang.Lines.add(S);
     for i := 1 to Length(S) do
         ReadSer(S[i], SerFrame);

//------------------- Ausgabe der Koordinaten über Edit-Felder
            form3.Edit_Weg1_xy.text := ('x= '+ inttostr(xy_Data[1].x)+ ' z= '+
                                    inttostr(xy_Data[1].z));
            form3.Edit_Weg1_squal.text := inttostr(xy_Data[1].squal);

            form3.Edit_Weg2_xy.text := ('x= '+ inttostr(xy_Data[2].x)+ ' z= '+
                                    inttostr(xy_Data[2].z));
            form3.Edit_Weg2_squal.text := inttostr(xy_Data[2].squal);

            // the following lines display the unprocessed camera coordinates
//            form3.Edit_Cam_xz.Text := ('x= '+ inttostr(cam_data.x)+ ' z= '+
//                                   inttostr(cam_data.z));
//------------------- Ausgabe der gemessenen Geschwindigkeit
{    Form3.Edit_Sensor1_vX_vZ.Text := floattostrF((xy_Data[1].x), ffFixed, 8, 2)
                             + '  '+ floattostrF((xy_Data[1].z), ffFixed, 8, 2);

       Form3.Edit_Sensor2_vX_vZ.Text := floattostrF(xy_Data[2].x, ffFixed, 8, 2)
                               + '  '+ floattostrF(xy_Data[2].z, ffFixed, 8, 2);
}
end;


///////////////////////////////////////////////////////////////////////////////
procedure TForm1.SerialPortNG1RxClusterEvent(Sender: TObject);

// All receiving is done here

begin
  if SerialPortNG1.NextClusterSize >= 0 then // Data available?
    begin
      if SerialPortNG1.NextClusterCCError = 0 then // Error during receiveing?
//form1.memo_empfang.Lines.Add(FormatDateTime('"Rec " hh:mm:ss  " error:', Now))
      else
        Form1.Memo_Empfang.Lines.Add(FormatDateTime('"RecX " hh:mm:ss"', Now));
//Form1.Memo_Empfang.Lines.Add('daten empfangen'+
//SerialPortNG1.ReadNextClusterAsString);
        Read_Bytes(SerialPortNG1.ReadNextClusterAsString, SerFrame);
    end;

end;

///////////////////////////////////////////////////////////////////////////////
 procedure TForm1.SerialPortNG1WriteDone(Sender: TObject);
begin
  if SerialPortNG1.WrittenBytes <> SendDataSize then
    SerialPortNG1ProcessError(Self, 0001, 0, 'Not all Bytes send',enError);
//  SendBtn.Enabled := True;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.SerialPortNG1RxEventCharEvent(Sender: TObject);
begin
//  Terminal.Lines.Add(FormatDateTime('"Msg " dd.mm.yy hh:mm:ss" :"', Now)+
//  ' RxEventCharEvent occours');
  SerialPortNG1.ReadRequest := True;
end;

//////////////////////////////////////////////////////////////////////////////
procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  SerialPortNG1.Active := False;
  SerialPortNG2.Active := False;
  CanClose := True;
  ADDI_DATA_Close;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.SerialPortNG1ProcessError(Sender: TObject; Place,
  Code: Cardinal; Msg: String; Noise: Byte);
var MaxError : Integer;
begin
{  if CBRecordErrors.Checked then
    begin
      MaxError := StrToIntDef(MaxErrorEdit.Text,256);
      while ErrorMemo.Lines.Count > MaxError do
        ErrorMemo.Lines.Delete(0);
      ErrorMemo.Lines.Add(FormatDateTime('"Msg  " dd.mm.yy hh:mm:ss" :"', Now)+
      Format('Code %d at %d Text: %s',[Code,Place,Msg]));
    end;
    }
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.Timer1Timer(Sender: TObject);
begin
{  if RxDCharResetTimer then // Second Step: Rest Led now
    begin
//      LedImageList.GetBitmap(LedGreenOff,RxDImage.Picture.Bitmap);
//      RxDImage.Repaint;
      RxDCharStartTimer := False;
      RxDCharResetTimer := False;
    end;
  if RxDCharStartTimer then // First Step: Led is On
    RxDCharResetTimer := True; // Reset the Led in the next Timer Event
 }
end;

//////////////////////////////////////////////////////////////////////////////
procedure TForm1.SerialPortNG1CommStat(Sender: TObject);
var s: String;
begin
  s := '';
  if fCtlHold in SerialPortNG1.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting for the CTS (clear-to-send) signal to be sent.'+
      #$0d#$0a;
    end
  else
  if fDsrHold in SerialPortNG1.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting for the DSR (data-set-ready) signal to be sent.'+
      #$0d#$0a;
    end
  else
  if fRlsHold in SerialPortNG1.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting for the RLSD(receive-line-signal-detect)signal.'+
      #$0d#$0a;
    end
  else
  if fXoffHold in SerialPortNG1.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting because the XOFF character was received.'+
      #$0d#$0a;
    end
  else
  if fXoffSent in SerialPortNG1.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting because the XOFF character was transmitted.'+
      #$0d#$0a;
    end
  else
  if fEof in SerialPortNG1.CommStateFlags then
    s := s + 'The end-of-file (EOF) character has been received.'+#$0d#$0a;
  if fTxim in SerialPortNG1.CommStateFlags then
    s := s +
    'There is a character queued for transmission that has come to the'+
    'communications device by way of the TransmitCommChar function.'+
    #$0d#$0a;

  if s <> '' then
    SerialPortNG1ProcessError(Self, 0000, 0, s,enMsg);
//  form1.memo_empfang.Lines.Add('frame length: '+
//  inttostr(serialportng1.CommStateOutQueue));
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.SerialPortNG1RxCharEvent(Sender: TObject);
begin
  //RxDCharStartTimer := True;
  //RxDCharResetTimer := False;
end;

///////////////////////////////////////////////////////////////////////////////
procedure init_laku;
var
   current_time, my_time, my_time2, time_on, time_off : int64;
   i: integer;
   io_ok: boolean;
begin
     Form1.edit_procedure_control.Text:= ('procedure init_laku');
     i_old:=1;  //29.7.
     changed_junction:=false; //2.8.
     
     lab_file_name:=form1.Lab_file.text;
     Proc_file_name:=form1.procedure_file.text;

     read_IO_config; // liest die Hdw Adressen der IO Pins

     change_cage:= FALSE;

     current_time:= TimeGetTime;
     current_junction:=0;      {aktuelle Kreuzungsnummer}
     start_junction:=0;   {Startkreuzung}
     position_in_duct:= 0;  //9.8.08 neu hier eingefügt, bisher nur in Reset_Corridor_Coord gesetzt
     corridor_x := 0;       //9.8.08 neu hier eingefügt, bisher nur in Reset_Corridor_Coord gesetzt
     corridor_z := 0;       //9.8.08 neu hier eingefügt, bisher nur in Reset_Corridor_Coord gesetzt
     reset_landscape:=false;
     wrong_end:=false;
     maze_state:= st_NIX;
     for i:=1 to 12 do  new_LB_data[i]:=false;

     ballState.current_rat:= 0; // Choose_Next_Rat sets the first value
     ballState.exit_time  := current_time + MAX_RUNTIME; // alternativ: Rat_Procedure.rat_max_procedure_time
     // current_junction:= 1;



     // init file vars
     last_event_feeder:= -1;
     last_event_pos:= -1;
     reward:= -1;
     state:= -1;
     (*
     motor_x:=2048;          {Spannungswert fr Motor x}
     motor_z:=2048;          {Spannungswert fr Motor y}
      *)
      // geändert: 7.12.08
     motor_x:=2052;          {Spannungswert fr Motor x}
     motor_z:=2052;          {Spannungswert fr Motor y}

     meldung_vom_server_x := 0;
     meldung_vom_server_z := 0;
     meldung_vom_server_x:=1000;     //d.h. die Kamera "sieht nichts"
     meldung_vom_server_z:=1000;

     read_procedure_file;
     read_labyrinth_definition_file;
     create_data_file;

     //ADDI_DATA_Initialisation(ADDI_DATA.dw_DriverHandle);
     ADDI_DATA_SetStartValues;
     ADDI_DATA_Start;

     io_ok:= ADDI_DATA_setOutput(round(motor_x), round(motor_z));

     if io_ok then
        showmessage('ADDI DATA auf 0V gesetzt')
     else
        showmessage('ADDI DATA ERROR');

     Initialize_Motors;               // DA-Wandler starten und auf 0 V legen
     transmit_to_DAC_I2C;
     Initialize_LB_Feeder; // Pins von Lichtschranken und Ventilen initialisieren
     Initialize_Servo;     // Pins von Servos initialisieren

     for i:=1 to 6 do
         TrEinheit[i].open:= FALSE;

     send_to_ser_buffer($FF, $00, $00, $00, $00, $00, TimeGetTime+ 3000,
                             MAX_TR_EINHEITEN+1, MAX_TR_EINHEITEN+1, FALSE);
                             // send the start condition
     timer_start := TRUE;

     first_run:=true;      // nur für allerersten Trial,
                           // wird beim ersten Aufruf von test_running
                           // auf false gesetzt
     trial_index:= 1;

     //Landschaft initialisieren
     x_animal_landscape:=0;       // auf Bildschirmrechner kommt raus x=10, z=10
     y_animal_landscape:=0;       // 18.08.08 neue Variable eingefügt für Landschaft absenken
     z_animal_landscape:=0;
     Koordinaten_senden;
     udpRecMsg.old:=false;

     (*     //Landschaft initialisieren zum testen 1.8.08
     x_animal_landscape:=50;     // auf Bildschirmrechner kommt raus x=10, z=10
     z_animal_landscape:=50;     // und man wird da auch hinteleportiert
     y_animal_landscape:=50;
     Koordinaten_senden;         //
        *)
       (*
               //Landschaft initialisieren zum testen 1.8.08
     x_animal_landscape:=0;     // auf Bildschirmrechner kommt raus x=10, z=10
     z_animal_landscape:=1000;  // und man wird da auch hinteleportiert
     Koordinaten_senden;        // ändert nichts
     showmessage('init_laku');
     *)
end;

///////////////////////////////////////////////////////////////////////////////
procedure init_grafic;
begin
 Form1.edit_procedure_control.Text:= ('procedure init_grafic');
 lab_file_name:=form1.Lab_file.text;
 read_labyrinth_definition_file;
 udpRecMsg.old:=false;

//wenn hier eingefügt, dann wird abgesenkt: pos.y:=20; //zum testen 20.8.08

 udpRecMsg.arDistalLM.reLM1:=88;  //26.7.08
 udpRecMsg.arDistalLM.reLM2:=88;
 udpRecMsg.arDistalLM.reLM3:=88;
 udpRecMsg.arDistalLM.reLM4:=88;
 udpRecMsg.arDistalLM.reLM5:=88;
 udpRecMsg.arDistalLM.reLM6:=88;

end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.NG2RxClusterEvent(Sender: TObject);

// All receiving is done here

begin
  if SerialPortNG2.NextClusterSize >= 0 then // Data available?
    begin
      if SerialPortNG2.NextClusterCCError = 0 then // Error during receiveing?
//form1.memo_empfang.Lines.Add(FormatDateTime('"Rec  " hh:mm:ss " error:', Now))
      else
        Form1.Memo_Empfang.Lines.Add(FormatDateTime('"RecX " hh:mm:ss"', Now));
//Form1.Memo_Empfang.Lines.Add('daten empfangen'+
// SerialPortNG1.ReadNextClusterAsString);
    end;

end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.NG2WriteDone(Sender: TObject);
begin
  if SerialPortNG2.WrittenBytes <> SendDataSize then
    NG2ProcessError(Self, 0001, 0, 'Not all Bytes send',enError);
//  SendBtn.Enabled := True;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.NG2RxEventCharEvent(Sender: TObject);
begin
//  Terminal.Lines.Add(FormatDateTime('"Msg " dd.mm.yy hh:mm:ss" :"', Now)+
//  ' RxEventCharEvent occours');
  SerialPortNG2.ReadRequest := True;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.NG2ProcessError(Sender: TObject; Place,
  Code: Cardinal; Msg: String; Noise: Byte);
var MaxError : Integer;
begin
{  if CBRecordErrors.Checked then
    begin
      MaxError := StrToIntDef(MaxErrorEdit.Text,256);
      while ErrorMemo.Lines.Count > MaxError do
        ErrorMemo.Lines.Delete(0);
      ErrorMemo.Lines.Add(FormatDateTime('"Msg  " dd.mm.yy hh:mm:ss" :"', Now)+
      Format('Code %d at %d Text: %s',[Code,Place,Msg]));
    end;                   }
end;

//////////////////////////////////////////////////////////////////////////////
procedure TForm1.NG2CommStat(Sender: TObject);
var s: String;
begin
  s := '';
  if fCtlHold in SerialPortNG2.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting for the CTS (clear-to-send) signal to be sent.'+
      #$0d#$0a;
    end
  else
  if fDsrHold in SerialPortNG2.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting for the DSR (data-set-ready) signal to be sent.'+
      #$0d#$0a;
    end
  else
  if fRlsHold in SerialPortNG2.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting for the RLSD (receive-line-signal-detect)signal.'
      +#$0d#$0a;
    end
  else
  if fXoffHold in SerialPortNG2.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting because the XOFF character was received.'+
      #$0d#$0a;
    end
  else
  if fXoffSent in SerialPortNG2.CommStateFlags then
    begin
      s := s +
      'Transmission is waiting because the XOFF character was transmitted.'+
      #$0d#$0a;
    end
  else
  if fEof in SerialPortNG2.CommStateFlags then
    s := s + 'The end-of-file (EOF) character has been received.'+#$0d#$0a;
  if fTxim in SerialPortNG2.CommStateFlags then
    s := s +
    'There is a character queued for transmission that has come to the'+
    ' communications device by way of the TransmitCommChar function.'+
    #$0d#$0a;
  if s <> '' then
    NG2ProcessError(Self, 0000, 0, s,enMsg);
//        form1.memo_empfang.Lines.Add('frame length: '+
//         inttostr(serialportng1.CommStateOutQueue));
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.NG2RxCharEvent(Sender: TObject);
begin
  //RxDCharStartTimer := True;
  //RxDCharResetTimer := False;
end;

// ÜBERARBEITEN ???
// wird aufgerufen von: TForm1.ButtonAbortClick(Sender: TObject);
// speichert aktuelle Labyrinthparameter in Datei

///////////////////////////////////////////////////////////////////////////////
procedure close_laku;
var DateTime: TDateTime;
begin
    motor_x:=0;
    motor_z:=0;
    transmit_to_DAC_I2C;

//    save_labyrinth_definition; // überarbeiten oder löschen
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.RewardFormClick(Sender: TObject);
begin
     Form2.Show;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.SensorButtonClick(Sender: TObject);
begin
      Form3.Show;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.ButtonCalibrateClick(Sender: TObject);
begin
     FormCalibration.Show;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.Button2Click(Sender: TObject);
begin
    Form4.Show;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TForm1.Button3Click(Sender: TObject);
begin
    Form5.Show;
end;
///////////////////////////////////////////////////////////////////////////////
procedure TForm1.Experiment_StateChange(Sender: TObject);
begin
//hier ExpState anzeiegen, Sessionende bestätigen

end;

procedure TForm1.Session_Change_OKClick(Sender: TObject);
begin
Session_control_ok:=true;
end;

procedure TForm1.ball_controlClick(Sender: TObject);
begin
//zum manuellen einstellen von exp running, falls der Ratte etwas nachgeholfenn werden musste und die
//Käfiglichtschranke händisch unterbrochen wurde
ball_control_ok:=true;
end;

end.

