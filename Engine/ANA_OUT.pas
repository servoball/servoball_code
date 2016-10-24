UNIT ANA_OUT;

INTERFACE

USES
    WINDOWS;

TYPE
    PPointer      = ^Pointer;
    pw_WordPtr    = ^WORD;
    w_WordArray   = ARRAY [0..32766] OF WORD; 
    pw_ArrayPtr   = ^w_WordArray;
    l_LongArray   = ARRAY [0..32766] OF LONGINT;
    pl_ArrayPtr   = ^l_LongArray;


   FUNCTION  b_ADDIDATA_GetNumberOfAnalogOutputs 	     	   (     dw_DriverHandle : Dword;
							    VAR     pw_NumberOfChannels : Word;
							    VAR     pb_AnalogOutputType : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_GetAnalogOutputInformation     	   (     dw_DriverHandle : Dword;
							            w_ChannelNumber : Word;
							    VAR     pb_NumberOfVoltageMode : BYTE;
							    VAR     pb_HighRange : BYTE;
							    VAR     pb_LowRange : BYTE;
							    VAR     pb_SWPolarity : BYTE;
							    VAR     pb_HWPolarity : BYTE;
							    VAR     pb_Resolution : BYTE;
							    VAR     pb_Synchronisation : LongBool): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Init1AnalogOutput     	   (     dw_DriverHandle : Dword;
						         w_ChannelNumber : Word;
						         b_VoltageMode : BYTE;
						         b_Polarity : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_InitMoreAnalogOutputs     	   (     dw_DriverHandle : Dword;
						            w_NumberOfChannels : Word;
						    VAR     pw_ChannelNumber : Word;
						    VAR     pb_VoltageMode : BYTE;
						    VAR     pb_Polarity : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Write1AnalogOutput     	   (     dw_DriverHandle : Dword;
						          w_ChannelNumber : Word;
						         dw_ValueToWrite : Longint): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_WriteMoreAnalogOutputs    	   (     dw_DriverHandle : Dword;
						          w_NumberOfChannels : Word;
						    VAR     pw_ChannelNumber : Word;
						    VAR    pdw_ValueToWrite : Longint): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Release1AnalogOutput     	   (     dw_DriverHandle : Dword;
						          w_ChannelNumber : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_ReleaseMoreAnalogOutputs  	   (     dw_DriverHandle : Dword;
						          w_NumberOfChannels : Word;
						    VAR     pw_ChannelNumber : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_EnableDisable1AnalogOutputSync   (     dw_DriverHandle : Dword;
							      w_ChannelNumber : Word;
							      b_EnableDisableSynchronisation : LongBool): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_EnableDisableMoreAnalogOutputsSync   (     dw_DriverHandle : Dword;
							        w_NumberOfChannels : Word;
							  VAR     pw_ChannelNumber : Word;
							  VAR     pb_EnableDisableSynchronisation : LongBool): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_TriggerAnalogOutput 	     	   (     dw_DriverHandle : Dword): Byte;FAR;STDCALL;





IMPLEMENTATION
{$O-}
{$A-}

   FUNCTION  b_ADDIDATA_GetNumberOfAnalogOutputs 	     	   (     dw_DriverHandle : Dword;
							    VAR     pw_NumberOfChannels : Word;
							    VAR     pb_AnalogOutputType : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_GetAnalogOutputInformation     	   (       dw_DriverHandle : Dword;
							            w_ChannelNumber : Word;
							    VAR     pb_NumberOfVoltageMode : BYTE;
							    VAR     pb_HighRange : BYTE;
							    VAR     pb_LowRange : BYTE;
							    VAR     pb_SWPolarity : BYTE;
							    VAR     pb_HWPolarity : BYTE;
							    VAR     pb_Resolution : BYTE;
							    VAR     pb_Synchronisation : LongBool): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Init1AnalogOutput     	   (     dw_DriverHandle : Dword;
						         w_ChannelNumber : Word;
						         b_VoltageMode : BYTE;
						         b_Polarity : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_InitMoreAnalogOutputs     	   (     dw_DriverHandle : Dword;
						            w_NumberOfChannels : Word;
						    VAR     pw_ChannelNumber : Word;
						    VAR     pb_VoltageMode : BYTE;
						    VAR     pb_Polarity : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Write1AnalogOutput     	   (     dw_DriverHandle : Dword;
						          w_ChannelNumber : Word;
						         dw_ValueToWrite : Longint): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_WriteMoreAnalogOutputs    	   (     dw_DriverHandle : Dword;
						          w_NumberOfChannels : Word;
						    VAR     pw_ChannelNumber : Word;
						    VAR    pdw_ValueToWrite : Longint): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Release1AnalogOutput     	   (     dw_DriverHandle : Dword;
						          w_ChannelNumber : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_ReleaseMoreAnalogOutputs  	   (     dw_DriverHandle : Dword;
						          w_NumberOfChannels : Word;
						    VAR     pw_ChannelNumber : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_EnableDisable1AnalogOutputSync   (     dw_DriverHandle : Dword;
							      w_ChannelNumber : Word;
							      b_EnableDisableSynchronisation : LongBool): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_EnableDisableMoreAnalogOutputsSync   (     dw_DriverHandle : Dword;
							        w_NumberOfChannels : Word;
							  VAR     pw_ChannelNumber : Word;
							  VAR     pb_EnableDisableSynchronisation : LongBool): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_TriggerAnalogOutput 	     	   (     dw_DriverHandle : Dword): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

{$O+}
{$A+}

END.
