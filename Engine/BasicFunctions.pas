unit BasicFunctions;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Global_Variables, mmsystem, Math, lakutpu;

procedure send_to_ser_buffer(controller: byte; i2c_bus: byte; i2c_addr: byte;
                         config: byte; data1: byte; data2 : byte; time : int64;
                         feeder_No: integer; door_No: integer; level: boolean);
  procedure door(TrNummer: integer; open: boolean; time: int64);
  function choice(VRat: TVector): integer;
    function VAngle(v: TVector): real;
    function VLength(v: TVector): real;
    function vector_projection(v1, v2: TVector; angle_diff: real): TVector;
    function vector_skalar(v1, v2: TVector): real;
    procedure create_data_file;
    procedure fill_array(var data : array of integer; b1: integer; b2: integer;
                             b3: integer; b4: integer; b5: integer); overload;

implementation

procedure send_to_ser_buffer(controller: byte; i2c_bus: byte; i2c_addr: byte;
                         config: byte; data1: byte; data2 : byte; time : int64;
                         feeder_No: integer; door_No: integer; level: boolean);
var
   i, j : integer;
   dummy_string, temp_str : string;
begin
     i := 0;
     while sende_puffer[i].ready do
           inc(i);
     // write header into temp string
     temp_str := char(hi(HEADER_IO_PIN)) + char(lo(HEADER_IO_PIN));
     // add data to the temp string
     temp_str := temp_str+ char(controller)+ char(i2c_bus)+ char(i2c_addr)+
                            char(config)+ char(data1)+ char(data2);

     sende_puffer[i].Frame_str := temp_str;
     sende_puffer[i].send_time := time;
     sende_puffer[i].ready     := true;
     sende_puffer[i].feeder_No := feeder_No;
     sende_puffer[i].door_No   := door_No;
     sende_puffer[i].level     := level;
//  display currently written data in Memo_Sendepuffer
{    for j := 1 to 8 do
         dummy_string := dummy_string + inttohex(integer(sende_puffer[i].frame_str[j]), 2) + ' ';
    dummy_str := dummy_str+ 'send to ser buffer: '+ dummy_string+ ' i= '+ inttostr(i)+ #13+ #10; }
//    dummy_str := dummy_str + 'send to ser buffer: '+ sende_puffer[i].Frame_str+ ' i= '+ inttostr(i)+ #13+ #10;
end;

function Acc_Limitation(V: TVector): TVector;
begin
end;

//********************* procedure door
//öffnet das Türchen der entsprechenden Ratten= Käfignummer,
//"erst open servo, dann stop servo"
procedure door(TrNummer: integer; open: boolean; time: int64);
var
   IO_byte, open_bit : byte;
   time_U_off : int64;
begin
     open_bit := byte(open);
     time_U_off := time+ DOOR_OPEN_TIME;

    io_byte := (TrEinheit[TrNummer].adresse[2] and $3F) or (open_bit shl 7);
    send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                                      feeder_code, IO_byte, 0, time,
                                      MAX_TR_EINHEITEN+1, TrNummer, TRUE);

    io_byte := (TrEinheit[TrNummer].adresse[3] and $3F) or ((not open_bit) shl 7);
    send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                                      feeder_code, IO_byte, 0, time,
                                      MAX_TR_EINHEITEN+1, TrNummer, TRUE);

// turn voltage off
    io_byte := (TrEinheit[TrNummer].adresse[2] and $3F);
    send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                                      feeder_code, IO_byte, 0, time_U_off,
                                      MAX_TR_EINHEITEN+1, TrNummer, FALSE);

    io_byte := (TrEinheit[TrNummer].adresse[3] and $3F);
    send_to_ser_buffer(feeder_controller, feeder_bus, feeder_i2c,
                                      feeder_code, IO_byte, 0, time_U_off,
                                      MAX_TR_EINHEITEN+1, TrNummer, FALSE);
end;

function choice(VRat: TVector): integer;
var
   angle_rat: real;
   temp, i : integer;
begin
     temp:= 0;

     angle_rat:= VAngle(VRat); // delivers values between -pi and + pi
     angle_rat:= angle_rat* 180/pi; // convert into deg
     if angle_rat < 0 then          // convert negative angles
        angle_rat := 360 + angle_rat;

     with junction[current_junction] do
     begin
     // if camera detects the animal and this one is not in the center circle
     if (not ballState.center) and ballState.detected then
          for i := 1 to number_of_exits do // check all stored corridors
          begin
              if exit_high_angle[i] < exit_low_angle[i] then
              begin
                 if ( round(angle_rat) <= exit_high_angle[i] ) or ( round(angle_rat) > exit_low_angle[i] ) then
                          temp := i
              end else
              begin
                 if ( round(angle_rat) <= exit_high_angle[i] ) and ( round(angle_rat) > exit_low_angle[i] ) then
                          temp := i
              end;
          end // for i := 1 to number_of_exits do
              else // if (not Rat_Rec.center) and Rat_Rec.detected then
          temp:= 0;
     end; // with

     choice:= temp;
end;

procedure create_data_file;
var
   data_file, file_header : String;
   Stream: TStream;
begin
     // convert date and time into an easy to sort string
    DateTimeToString(data_file, 'ss_nn_hh dd_mm_yy', Now);
    // add the file path and the extension
    out_file_name:= out_file_path+ data_file+'.csv';
    // create file
    Stream:=TFileStream.Create(out_file_name, fmCreate);

    // write a header
    file_header:= lab_file_name+ #13+#10;
    stream.Write(Pchar(file_header)^,length(file_header));
    file_header:= 'Time'+';'+'Time / ms'+';'+'rat nr'+';'
                  +'junction'+';'+'corridor'+';'+'alpha'+';'+'pos in corridor'+';'
                  +'landscape x'+';'+'landscape y'+';'+'landscape z'+';'+'cam x'+';'+'cam y'
                  +';'+'motor x'+';'+'motor z'
                  +';'+{'new data'+';'+}'feeder nr'+';'+'position'+';'+'IO state'+';'
                  +'reward'+';' + 'global state'+'Trial_number'+'meldung_vom_server '
                  +#10+#13;

    stream.Write(Pchar(file_header)^,length(file_header));
    // release the stream
    Stream.free;
    // set flag
    file_created:= TRUE;
end;

function VAngle(v: TVector): real;
begin
     if v.k1 <> 0 then
        VAngle := arctan2(v.k2, v.k1) else
        begin
             if v.k2 > 0 then
                VAngle := pi/2 else
                VAngle := -pi/2;
        end;
end;

function VLength(v: TVector): real;
begin
     VLength := sqrt( sqr(v.k1) + sqr(v.k2) );
end;

function vector_skalar(v1, v2: TVector): real;
begin
     vector_skalar:= v1.k1*v2.k1 + v1.k2*v2.k2;
end;

function vector_projection(v1, v2: TVector; angle_diff: real): TVector;
var
   VResult: TVector;
   length, angle : real;
begin
     angle:= VAngle(v2);

     length := VLength(v1)* cos(angle_diff);
     VResult.k1 := cos(angle)* length;
     VResult.k2 := sin(angle)* length;
     vector_projection := VResult;
end;

procedure fill_array(var data : array of integer; b1: integer; b2: integer; b3: integer; b4: integer; b5: integer); overload;
begin
  data[0] := b1;
  data[1] := b2;
  data[2] := b3;
  data[3] := b4;
  data[4] := b5;
end;


end.
 