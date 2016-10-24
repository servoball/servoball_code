UNIT DIG_INP;

INTERFACE

USES
    WINDOWS;

TYPE
    PPointer      = ^Pointer;
    pw_WordPtr    = ^WORD;

    b_ByteArray   = ARRAY [0..32766] OF BYTE;
    pb_ArrayPtr   = ^b_ByteArray;

    w_WordArray   = ARRAY [0..32766] OF WORD;
    pw_ArrayPtr   = ^w_WordArray;

    l_LongArray   = ARRAY [0..32766] OF LONGINT;
    pl_ArrayPtr   = ^l_LongArray;


   FUNCTION  b_ADDIDATA_GetNumberOfDigitalInputs 	     	   (     dw_DriverHandle : Dword;
							                                    VAR  pw_NumberOfChannels : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_GetDigitalInputInformation 	           (     dw_DriverHandle : Dword;
							                                          w_DigitalInputNumber : Word;
							                                    VAR  pb_DigitalInputType : BYTE;
							                                    VAR  pb_DigitalInputInterrupt : LongBool): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Read1DigitalInput 	     	           (     dw_DriverHandle : Dword;
							                                          w_Channel : Word;
							                                    VAR  pb_ChannelStatus : Byte): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Read2DigitalInputs 	     	           (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Read4DigitalInputs 	     	           (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Read8DigitalInputs 	     	           (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Read16DigitalInputs 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pw_PortValue : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Read32DigitalInputs 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR pdw_PortValue : Longint): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_InitDigitalInputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word;
							                                          b_InterruptLogic : BYTE;
							                                    VAR pdw_InterruptMaskMode1 : Longint;
							                                    VAR pdw_InterruptMaskMode2 : Longint): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_EnableDisableDigitalInputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word;
							                                          b_InterruptFlag : BYTE): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_ReleaseDigitalInputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word): Byte;FAR;STDCALL;




IMPLEMENTATION

{$O-}
{$A-}


   FUNCTION  b_ADDIDATA_GetNumberOfDigitalInputs 	     	   (     dw_DriverHandle : Dword;
							                                    VAR  pw_NumberOfChannels : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_GetDigitalInputInformation 	           (     dw_DriverHandle : Dword;
							                                          w_DigitalInputNumber : Word;
							                                    VAR  pb_DigitalInputType : BYTE;
							                                    VAR  pb_DigitalInputInterrupt : LongBool): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Read1DigitalInput 	     	           (     dw_DriverHandle : Dword;
							                                          w_Channel : Word;
							                                    VAR  pb_ChannelStatus : Byte): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Read2DigitalInputs 	     	           (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Read4DigitalInputs 	     	           (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Read8DigitalInputs 	     	           (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pb_PortValue : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Read16DigitalInputs 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR  pw_PortValue : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Read32DigitalInputs 	     	       (     dw_DriverHandle : Dword;
							                                          b_Port : BYTE;
							                                    VAR pdw_PortValue : Longint): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_InitDigitalInputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word;
							                                          b_InterruptLogic : BYTE;
							                                    VAR pdw_InterruptMaskMode1 : Longint;
							                                    VAR pdw_InterruptMaskMode2 : Longint): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_EnableDisableDigitalInputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word;
							                                          b_InterruptFlag : BYTE): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_ReleaseDigitalInputInterrupt     	       (     dw_DriverHandle : Dword;
							                                          w_FirstChannelNbr : Word;
							                                          w_LastChannelNbr : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';


{$O+}
{$A+}

END.
