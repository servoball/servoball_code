UNIT DIG_OUT;

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



   FUNCTION  b_ADDIDATA_GetNumberOfDigitalOutputs 	     	   (    dw_DriverHandle : Dword;
							                                    VAR pw_NumberOfChannels : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_GetDigitalOutputInformation 	       (    dw_DriverHandle : Dword;
  							                                         w_DigitalOutputNumber : Word;
							                                    VAR pb_DigitalOutputType : BYTE;
							                                    VAR  pb_DigitalInputInterrupt : Byte): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_SetDigitalOutputMemoryOn 	     	   (    dw_DriverHandle : Dword): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_SetDigitalOutputMemoryOnEx 	     	   (    dw_DriverHandle : Dword): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_SetDigitalOutputMemoryOff 	           (    dw_DriverHandle : Dword): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set1DigitalOutputOn 	     	       (    dw_DriverHandle : Dword;
							                                         w_Channel : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set1DigitalOutputOff 	     	       (    dw_DriverHandle : Dword;
							                                         w_Channel : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set2DigitalOutputsOn 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set2DigitalOutputsOff 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set4DigitalOutputsOn 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set4DigitalOutputsOff 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set8DigitalOutputsOn 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set8DigitalOutputsOff 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set16DigitalOutputsOn 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         w_PortValue : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set16DigitalOutputsOff 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                          w_PortValue : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set32DigitalOutputsOn 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                         dw_PortValue : Longint): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Set32DigitalOutputsOff 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                         dw_PortValue : Longint): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Get1DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          w_Channel : Word;
							                                    VAR  pb_ChannelStatus : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Get2DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Get4DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Get8DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Get16DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pw_PortValue : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Get32DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR pdw_PortValue : Longint): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_InitDigitalOutputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word;
							                                          b_CCInterruptFlag : BYTE;
							                                          b_VCCInterruptFlag : BYTE;
							                                    VAR pdw_DigitalOutputArrayForInterruptCC : Longint;
							                                    VAR pdw_DigitalOutputArrayForInterruptVCC : Longint): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_EnableDisableDigitalOutputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word;
							                                          b_VCCInterruptFlag : BYTE;
							                                          b_CCInterruptFlag : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_ReleaseDigitalOutputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word): Byte;FAR;STDCALL;


IMPLEMENTATION
{$O-}
{$A-}


   FUNCTION  b_ADDIDATA_GetNumberOfDigitalOutputs 	     	   (    dw_DriverHandle : Dword;
							                                    VAR pw_NumberOfChannels : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_GetDigitalOutputInformation 	       (    dw_DriverHandle : Dword;
  							                                         w_DigitalOutputNumber : Word;
							                                    VAR pb_DigitalOutputType : BYTE;
							                                    VAR  pb_DigitalInputInterrupt : Byte): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_SetDigitalOutputMemoryOn 	     	   (    dw_DriverHandle : Dword): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_SetDigitalOutputMemoryOnEx 	     	   (    dw_DriverHandle : Dword): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_SetDigitalOutputMemoryOff 	           (    dw_DriverHandle : Dword): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set1DigitalOutputOn 	     	       (    dw_DriverHandle : Dword;
							                                         w_Channel : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set1DigitalOutputOff 	     	       (    dw_DriverHandle : Dword;
							                                         w_Channel : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set2DigitalOutputsOn 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set2DigitalOutputsOff 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set4DigitalOutputsOn 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set4DigitalOutputsOff 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set8DigitalOutputsOn 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set8DigitalOutputsOff 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         b_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set16DigitalOutputsOn 	     	       (    dw_DriverHandle : Dword;
							                                         b_Port : BYTE;
							                                         w_PortValue : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set16DigitalOutputsOff 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                          w_PortValue : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set32DigitalOutputsOn 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                         dw_PortValue : Longint): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Set32DigitalOutputsOff 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                         dw_PortValue : Longint): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Get1DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          w_Channel : Word;
							                                    VAR  pb_ChannelStatus : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Get2DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Get4DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Get8DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Get16DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pw_PortValue : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Get32DigitalOutputStatus 	     	   (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR pdw_PortValue : Longint): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_InitDigitalOutputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word;
							                                          b_CCInterruptFlag : BYTE;
							                                          b_VCCInterruptFlag : BYTE;
							                                    VAR pdw_DigitalOutputArrayForInterruptCC : Longint;
							                                    VAR pdw_DigitalOutputArrayForInterruptVCC : Longint): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_EnableDisableDigitalOutputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word;
							                                          b_VCCInterruptFlag : BYTE;
							                                          b_CCInterruptFlag : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_ReleaseDigitalOutputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';


{$O+}
{$A+}


END.
