unit Unit_Calibration;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, BasicFunctions, mmsystem, global_variables, ExtCtrls,
  ADDI_DATA;

type
  TFormCalibration = class(TForm)
    Edit_Feeder: TEdit;
    Edit_Repeats: TEdit;
    Edit_Reward: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button_Go: TButton;
    EditDoor: TEdit;
    Edit_OpenTime: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Edit_Motor_Nr: TLabeledEdit;
    Edit_Motor_V: TLabeledEdit;
    Edit_Motor_time: TLabeledEdit;
    procedure Button_GoClick(Sender: TObject);
    procedure Edit_FeederClick(Sender: TObject);
    procedure EditDoorClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
   
  end;


  procedure Test_Motors(current_time : int64; time_off:int64; Motor_nr: integer; Motor_V:real);


var
  FormCalibration: TFormCalibration;
   Motor_test_x, Motor_test_z: integer;

implementation

uses Setup;

{$R *.dfm}

procedure TFormCalibration.Button_GoClick(Sender: TObject);
var
   FEEDER, REPEATS, REWARD: integer;
   DOOR_NR, OPENTIME,Motor_nr,Motor_Time : integer;
   Motor_V: real;
   current_time, time_on, time_off: int64;
   i: integer;
   //Motor_time: integer;
   Motor_time_on, Motor_time_off,Motor_current_time: int64;
   calibrate_motor_Done:boolean;
begin
     current_time:= TimeGetTime;
     FEEDER:= StrToInt(FormCalibration.Edit_Feeder.text);
     REPEATS:= StrToInt(FormCalibration.Edit_Repeats.text);
     REWARD:= StrToInt(FormCalibration.Edit_Reward.text);
     DOOR_NR:= StrToInt(FormCalibration.EditDoor.Text);
     Motor_nr:= StrToInt(FormCalibration.Edit_Motor_Nr.Text);
     Motor_V:= StrToFloat(FormCalibration.Edit_Motor_V.Text);
     Motor_Time:= StrToInt(FormCalibration.Edit_Motor_time.Text);
     OPENTIME:= StrToInt(FormCalibration.Edit_OpenTime.text);

     time_off:= current_time;
     if FEEDER <> 0 then
        for i := 1 to REPEATS do
        begin
          time_on := time_off + 400;
          time_off := time_on + REWARD;

          send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                        feeder_code, TrEinheit[FEEDER].adresse[0] or $80, 0, time_on,
                        FEEDER, MAX_TR_EINHEITEN+1, TRUE);
          send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                        feeder_code, TrEinheit[FEEDER].adresse[0] or $00, 0, time_off,
                        FEEDER, MAX_TR_EINHEITEN+1, FALSE);
        end;

     if DOOR_NR <> 0 then
     begin
          time_on:= current_time;
          time_off:= time_on+ DOOR_OPEN_TIME+ OPENTIME;
          door(DOOR_NR, true, time_on);
          door(DOOR_NR, false, time_off);
     end;


     if Motor_nr <> 0 then
        begin
        Motor_time_on:= Timegettime;
        Motor_time:=strtoint(formCalibration.Edit_Motor_time.Text);
        Motor_time_off:= Motor_time_on + Motor_time;
        calibrate_motor_Done:=FALSE;

          while calibrate_motor_Done=FALSE do        //!!!!HAUPTSCHLEIFE!!!!
          begin
          Motor_current_time:= TimeGetTime;

          Test_Motors(current_time, time_off, Motor_nr, Motor_V);

          form1.Edit_Spannung_M1.text := inttostr(round(motor_test_x));
             form1.Edit_Spannung_M2.text := inttostr(round(motor_test_z));

          if  Motor_current_time>Motor_time_off then calibrate_motor_Done:=true
          end;
        end;
end;

procedure Test_Motors(current_time : int64; time_off:int64; Motor_nr:integer; Motor_V:real);
var
   i, m_value,motor_bus, motor_i2c,motor_stop : integer;


begin
try


    if motor_nr =1 then
    begin
    motor_test_z:=0;
    motor_test_z:=2050;
    motor_test_X:= strtoint(formCalibration.edit_motor_V.text );

       // Geschwindigkeitsbegrenzung falls Berechnung falsch ist
      // limit the maximal velocity

    if abs(motor_test_x) > 2200 then  motor_test_x := 2200;//3000;
    if abs(motor_test_x) < 1900 then  motor_test_x := 1900;//1000;
    if abs(motor_test_z) > 2200 then  motor_test_z := 2200;//3000;
    if abs(motor_test_z) < 1900 then  motor_test_z := 1900;//1000;


    ADDI_DATA_setOutput(round(motor_test_x), round(motor_test_z));
            form1.Edit_Spannung_M1.text := inttostr(round(motor_test_x));
             form1.Edit_Spannung_M2.text := inttostr(round(motor_test_z));

   end;

     if time_off>timeGettime then
         begin
             motor_test_x := 2049;
             motor_test_z := 2050;
             ADDI_DATA_setOutput(round(motor_test_x), round(motor_test_z));
             form1.Edit_Spannung_M1.text := inttostr(round(motor_test_x));
             form1.Edit_Spannung_M2.text := inttostr(round(motor_test_z));
         end;    



    if motor_nr =2 then
    begin
    motor_test_x:=2049;
    motor_test_Z:= strtoint(formCalibration.edit_motor_V.text );

    if abs(motor_test_x) > 2200 then  motor_test_x := 2200;//3000;
    if abs(motor_test_x) < 1900 then  motor_test_x := 1900;//1000;
    if abs(motor_test_z) > 2200 then  motor_test_z := 2200;//3000;
    if abs(motor_test_z) < 1900 then  motor_test_z := 1900;//1000;

    ADDI_DATA_setOutput(round(motor_test_x), round(motor_test_z));

     form1.Edit_Spannung_M1.text := inttostr(round(motor_test_x));
     form1.Edit_Spannung_M2.text := inttostr(round(motor_test_z));
    end;

except
    messagebox(0, 'error', 0, 0);
end;

end;

procedure TFormCalibration.Edit_FeederClick(Sender: TObject);
begin
     FormCalibration.EditDoor.Text:= '0';
end;

procedure TFormCalibration.EditDoorClick(Sender: TObject);
begin
     FormCalibration.Edit_Feeder.Text:= '0';
end;
end.





