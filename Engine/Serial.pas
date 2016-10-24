unit Serial;

interface
uses global_variables, mmsystem;

    procedure velocity_calculation(vel_values: TFourItemArray);
    procedure velocity_average_calculation;
    procedure store_velocity_data(vel_values: TFourItemArray);
//    procedure testvelocitycalc;

implementation

procedure send_to_ser_buffer(controller: byte; i2c_bus: byte; i2c_addr: byte;
                         config: byte; data1: byte; data2 : byte; time : int64);
var
   i, j : integer;
   dummy_string : string;
begin
     i := 0;

   while sende_puffer[i].send_time <> 0 do
         inc(i);

            sende_puffer[i].frame[0] := controller;
            sende_puffer[i].frame[1] := i2c_bus;
            sende_puffer[i].frame[2] := i2c_addr;
            sende_puffer[i].frame[3] := config;
            sende_puffer[i].frame[4] := data1;
            sende_puffer[i].frame[5] := data2;

            sende_puffer[i].send_time := time;

    //  Ausgabe der gepufferten Daten in Memo_Sendepuffer
{    for j := 0 to 5 do
         dummy_string := dummy_string + inttohex(sende_puffer[i].frame[j], 2) + ' ';
    form1.Memo_Sendepuffer.Lines.add('in den sendepuffer gelegt: '+ dummy_string);}
end;

// *******************************************************************
procedure velocity_calculation( vel_values: TFourItemArray );
var
    time_tmp     : extended;    // temp variable for time calculation.
    position_tmp : extended;    // temp variable for position calculation.
    current_tmp  : extended;    // temp variable for current time.
    count        : byte;        // forloop counter
begin
    // velocity calculation
    current_tmp  := TimeGetTime();
    for count := 1 to 2 do
    begin
        With xy_Data[count] do
        begin
           time_tmp := (current_tmp - xy_Data[1].previous_time);
           // case: 24-hour clock overflow
           if (time_tmp < 0) then  //86400000 ms/24hours (millisec/1 day)
               time_tmp     := ((86400000 - xy_Data[1].previous_time)+(current_tmp - 0));
           // case: division by zero error
           if (time_tmp = 0) then time_tmp := 1;

           // * X coordinate
           if (( x > 0 ) and ( x < 3000 )) then
           begin
              case ( previous_x > 63000 ) of
                true : position_tmp := (65536 - previous_x) + x;
                else position_tmp := x - previous_x;
              end;
           end else
              position_tmp := x - previous_x;
           // velocity calc
           vel_values[count] := (position_tmp / time_tmp);
           // * Z coordinate
           if (( z > 0 ) and ( z < 3000 )) then
           begin
              case ( previous_z > 63000 ) of
                true : position_tmp := (65536 - previous_z) + z;
                else position_tmp := z - previous_z;
              end;
           end else
              position_tmp := z - previous_z; // Absolute value
           // velocity calc
           vel_values[count+2] := (position_tmp / time_tmp);
        end;  // end With
    end;  // end for loop

    // store the values
    store_velocity_data( vel_values );
    // calculate average velocity
    velocity_average_calculation;
end;

// *******************************************************************
procedure velocity_average_calculation;
var
   A    : byte;
   B    : byte;
   avgs : TFourItemArray;
begin
    // initialize the avg_values array
    for B := 1 to 4 do
    begin
        avgs[B] := 0;
    end;

    // begin calculations
    for A:= 1 to 2 do
    begin
       // Sensor Data
       With xy_Data[A].velocity_avg do
       begin
          // Summation
          for B := 0 to 9 do
          begin
             avgs[A]   := avgs[A]   + vel_x_array[B];
             avgs[A+2] := avgs[A+2] + vel_z_array[B];
          end; // end forloop 0 to 9.
          // Divide
          avgs[A] := (avgs[A]/10);
          avgs[A+2] := (avgs[A+2]/10);
       end; // end With.
    end;  // end forloop 1 to 2.
end;

// *******************************************************************
procedure store_velocity_data( vel_values : TFourItemArray );
var
  index : byte; // forloop counter
begin
   for index := 1 to 2 do
   begin
      // saving the given velocity values
      With xy_Data[index].velocity_avg do
      begin
         vel_x_array[array_index] := vel_values[index];
         vel_z_array[array_index] := vel_values[index+2];
         // Increment index
         Case array_index of
            9 : array_index := 0;
           else array_index := (array_index+1);
         end;
       end; // end With.
       // saving previous data for next calculation.
       xy_Data[index].previous_x := xy_Data[index].x;
       xy_Data[index].previous_z := xy_Data[index].z;
       xy_Data[index].previous_time := xy_Data[index].position_time;
    end; // end forloop.
end;


procedure Add_Cam_Data(SerFrame : TSerFrame);
var
    i : integer;
    dummy_string : string;
    vel_values : TFourItemArray;
    sum1, sum2 : integer;
begin
if length(SerFrame.Data) >= SENSOR_FRAME_LENGTH then
begin
//     form1.Memo_Empfang.Lines.Add('optical sensors: '+ dummy_string);
{    for i := 1 to 12 do
         dummy_string := dummy_string + inttohex(integer(byte(SerFrame.Data[i])), 2) + ' ';
     form1.Memo_Empfang.Lines.Add('optical sensors: '+ dummy_string);
     dummy_string := '';
    for i := 13 to 16 do
         dummy_string := dummy_string + inttohex(integer(byte(SerFrame.Data[i])), 2) + ' ';
     form1.Memo_Empfang.Lines.Add('camera:          '+ dummy_string);
 }
     // hier werden die Daten des ersten Wegaufnehmers eingefügt
            xy_Data[1].x := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            xy_Data[1].z := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            xy_Data[1].squal := byte(SerFrame.Data[1]); // shl 8 + byte(SerFrame.Data[2]);
//            Delete(SerFrame.Data, 1, 2);
            Delete(SerFrame.Data, 1, 1);
            xy_Data[1].position_time := TimeGetTime();

     // hier werden die Daten des zweiten Wegaufnehmers eingefügt
            xy_Data[2].x := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            xy_Data[2].z := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            xy_Data[2].squal := byte(SerFrame.Data[1]); // shl 8 + byte(SerFrame.Data[2]);
//            Delete(SerFrame.Data, 1, 2);
            Delete(SerFrame.Data, 1, 1);
            xy_Data[2].position_time := TimeGetTime();

     // hier werden die Kameradaten eingefügt
            cam_data.x := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);
            cam_data.z := integer(byte(SerFrame.Data[1])) shl 8 + byte(SerFrame.Data[2]);
            Delete(SerFrame.Data,1,2);

            velocity_calculation( vel_values );

            sum1 := xy_Data[1].x + xy_Data[1].z;
            sum2 := xy_Data[2].x + xy_Data[2].z;

            if not( (sum1 = 0) or (sum2 = 0) ) then
                FLAG_PROCESS_DATA := TRUE;

           // JvSimScope1.
end;
end;

procedure Add_IoPin_Data(SerFrame : TSerFrame);
var i, j : integer;
    pin_nr, pin_state : byte;
    current_time : int64;
begin
  current_time := TimeGetTime;

//  form1.memo_empfang.Lines.Add('serial frame= '+ inttostr(byte(SerFrame.Data[1]))+ ' '+ inttostr(byte(SerFrame.Data[2]))
//  +' '+  inttostr(byte(SerFrame.Data[3]))+' '+  inttostr(byte(SerFrame.Data[4]))+' '+  inttostr(byte(SerFrame.Data[5])));

  pin_nr := byte(SerFrame.Data[4]) and $7F; // %01111111;
  pin_state := byte(SerFrame.Data[4]) shr 7;
  for i := 1 to MAX_TR_EINHEITEN do // i: gehe alle Tränken-Einheiten durch
       for j := 0 to 4 do // j: finde die angekommene Pinnr.
           if TrEinheit[i].adresse[j] = pin_nr then // bei Übereinstimmung der Pinnr. speichere Daten
           begin
//              TrEinheit[i]. := tiemgettime;
                if pin_state = 1 then
                   TrEinheit[i].current_state[j] := true else
                   TrEinheit[i].current_state[j] := false;

                SerFrame.available_data := TRUE;
                SerFrame.last_event_feeder := i;
                SerFrame.last_event_pos := j;
                SerFrame.state := pin_state;
                SerFrame.signal_time := current_time;

/////////////////////////////////////// STORE
//              save_data_to_output_file(current_time, i, j);
////////////////////////////////////////
           end; // TrEinheit[i].adresse[j] = pin_nr then //
//  form1.memo_empfang.Lines.Add('Pin '+ inttostr(pin_nr)+ '   state'+ inttostr(pin_state) );
end;

procedure ReadSer(serial_char: char; var SerFrame: TSerFrame);
var
   header_word : word;
begin
with SerFrame do
begin
  header_word := (word(last_byte) shl 8)+ byte(serial_char) ;
  last_byte := byte(serial_char);
//  form1.Memo_Empfang.Lines.Add(' new header = '+ inttohex( integer(header_word), 4 ));

  if frame_complete = FALSE then
  begin
    Data := Data + serial_char; // add the incoming byte to the stored data string
    if Length(Data) > current_frame_length then
    begin
//         form1.Memo_Empfang.Lines.Add('new frame complete= '+ Data);
         case current_frame_length of
            SENSOR_FRAME_LENGTH : Add_Cam_Data(SerFrame);
            PERIPHERY_FRAME_LENGTH :  Add_IoPin_Data(SerFrame);
         end;

         frame_complete := true;
    end; // Length(Data) > current_frame_length then
  end; // if frame_complete = FALSE

  if (header_word = HEADER_IO_PIN) or (header_word = HEADER_SENSOR) then
  begin
       Data := ''; // erase old data
       frame_complete := false; // start recording a new frame

       case header_word of
            HEADER_SENSOR: current_frame_length := SENSOR_FRAME_LENGTH;
            HEADER_IO_PIN: current_frame_length := PERIPHERY_FRAME_LENGTH;
       end; // case
  end; // if (header_word = HEADER_IO_PIN) or (header_word = HEADER_SENSOR) then

end; // with SerFrame do
end;


end.
 