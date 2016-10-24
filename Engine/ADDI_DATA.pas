unit ADDI_DATA;     //Motorsteuerung

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, WinTypes, WinProcs,
  Math, DEFINE, INIT, ERROR, ANA_OUT;

var
  i_ReturnValue : Integer;
  b_ReturnValue : Byte;
  b_InitialisationOk : Boolean;
  dw_DriverHandle : Dword;
  w_NumberOfChannels : Word;
  w_ChannelChoice : Array [0..3] of Word;
  b_VoltageChoice : Array [0..3] of Byte;
  b_PolarityChoice : Array [0..3] of Byte;
  b_Resolution : Array [0..3,0..16] of Byte;
  dw_ValueToWrite : Array [0..3] of Longint;

function  ADDI_DATA_Initialisation (Var dw_DriverHandle : Dword):Integer;
procedure ADDI_DATA_SetStartValues;
procedure ADDI_DATA_Start;
function ADDI_DATA_setOutput(out1: integer; out2: integer): boolean;
procedure ADDI_DATA_Close;

implementation

function  ADDI_DATA_Initialisation (Var dw_DriverHandle : Dword):Integer;

Begin
     (* Open the Win32 driver *)
     i_ReturnValue := i_ADDIDATA_OpenWin32Driver ( ADDIDATA_DLL_COMPILER_PASCAL,
							  dw_DriverHandle);

     Case i_ReturnValue of
          0:
                   ADDI_DATA_Initialisation := 0;
          else
               ADDI_DATA_Initialisation := -1;
          end;
End;

procedure ADDI_DATA_SetStartValues;
var
   i: integer;
begin
// Kanalnummer definieren
// Spannungsmodus einstellen ** 2= bipolar, 12 bit; 1= unipolar= 11 bit
    for i := 0 to 3 do
    begin
       w_ChannelChoice[i] := i;
       b_VoltageChoice[i] := 0;
       b_PolarityChoice[i] := 2;
    end;
end;

procedure ADDI_DATA_Start;
var
    i : Integer;
    w_Channel : Word;
    b_Voltage : Byte;
    b_AnalogOutputType : Array [0..3] of Byte;
    b_NumberOfVoltageMode : Array [0..3] of Byte;
    b_HighRange : Array [0..3,0..16] of Byte;
    b_LowRange : Array [0..3,0..16] of Byte;
    b_SWPolarity : Array [0..3,0..16] of Byte;
    b_HWPolarity : Array [0..3,0..16] of Byte;
    b_Synchronisation : Array [0..3] of LongBool;

    fct_no: integer;
begin
     ADDI_DATA_SetStartValues;

    i_ReturnValue := ADDI_DATA_Initialisation(dw_DriverHandle);

    If (i_ReturnValue = 0) Then
       Begin
	  b_InitialisationOk  := True;
          ShowMessage('OpenDriver OK');


          (***********************************************)
          (* Gets the number of available digital inputs *)
          (***********************************************)

          if (b_ADDIDATA_GetNumberOfAnalogOutputs (dw_DriverHandle,
                                                   w_NumberOfChannels,
                                                   b_AnalogOutputType[0]) = 1)
          (*********************)
          (* If no error ocurr *)
          (*********************)
          Then
              Begin
              Showmessage('GetNumberOfAnalogOutputs OK'+ ' No= '+ inttostr(w_NumberOfChannels));
              for i := 0 to 3 do
                 begin
                 b_ADDIDATA_GetAnalogOutputInformation (dw_DriverHandle,
                                                         w_ChannelChoice[i],
                                                         b_NumberOfVoltageMode[i],
                                                         b_HighRange[i,0],
                                                         b_LowRange[i,0],
                                                         b_SWPolarity[i,0],
                                                         b_HWPolarity[i,0],
                                                         b_Resolution[i,0],
                                                         b_Synchronisation[i])
                 end;

          if (b_ADDIDATA_GetAnalogOutputInformation (dw_DriverHandle,
                                                        w_ChannelChoice[0],
                                                        b_NumberOfVoltageMode[0],
                                                        b_HighRange[0,0],
                                                        b_LowRange[0,0],
                                                        b_SWPolarity[0,0],
                                                        b_HWPolarity[0,0],
                                                        b_Resolution[0,0],
                                                 b_Synchronisation[0]) = 1) then

                  (*********************)
                  (* If no error ocurr *)
                  (*********************)
                   ShowMessage('GetAnalogOutputInformation OK')
                   else
                   ShowMessage('GetAnalogOutputInformation ERROR')
          end
            else
              Showmessage('GetNumberOfAnalogOutputs ERROR');
          end // If (i_ReturnValue = 0) Then
          else
          ShowMessage('OpenDriver ERROR');

        b_ReturnValue := b_ADDIDATA_InitMoreAnalogOutputs  (dw_DriverHandle,
     w_NumberOfChannels,
     w_ChannelChoice[0],
     b_VoltageChoice[0],
     b_PolarityChoice[0]);
                        if b_ReturnValue = 1  then
                 begin
                      ShowMessage('InitMoreAnalogOutputs OK')
                 end
                    else
                 begin
                      fct_no:= 703;
                      ShowMessage('InitMoreAnalogOutputs ERROR');
                    {  b_ReturnValue:= i_ADDIDATA_GetLastError(dw_DriverHandle,
                                      fct_no,
                                      b_ReturnValue,
                                      0); }
                      ShowMessage('letzter Fehler: '+ inttostr(b_ReturnValue));
                 end;
   end;

function ADDI_DATA_setOutput(out1: integer; out2: integer): boolean;
var
   k1, k2: integer;
begin
    dw_ValueToWrite[0]:= out1;
    dw_ValueToWrite[1]:= out2;

    k1:= b_ADDIDATA_WriteMoreAnalogOutputs (dw_DriverHandle,
                                             2,        // 2 Kanäle
                                             w_ChannelChoice[0], // Kanalnummer
                                            dw_ValueToWrite[0]);

     k2:= b_ADDIDATA_WriteMoreAnalogOutputs (dw_DriverHandle,
                                             2,        // 2 Kanäle
                                             w_ChannelChoice[1], // Kanalnummer
                                            dw_ValueToWrite[1]);
     if (k1 <> 1) or (k2 <> 1) then
         ADDI_DATA_setOutput:= FALSE
     else
         ADDI_DATA_setOutput:= TRUE;
end;

procedure ADDI_DATA_Close;
begin
     If (b_InitialisationOk = True) Then
	Begin
	   (* Close the board handle *)
	   b_ReturnValue := b_ADDIDATA_CloseWin32Driver (dw_DriverHandle);
           Showmessage('ADDI_DATA CloseDriver: '+ inttostr(b_ReturnValue));
	End;
end;
   end.
