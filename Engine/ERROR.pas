UNIT ERROR;

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
    Handle        = Longint;



   FUNCTION   i_ADDIDATA_GetLastError	        (    dw_DriverHandle : DWORD;
					                             VAR pw_FunctionNumber : Word;
					                             VAR pi_ErrorCode : Integer;
					                             VAR pb_ErrorLevel : BYTE): INTEGER;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_EnableErrorMessage      (    dw_DriverHandle : Dword;
					                                  h_WndHandle : Handle;
					                                  w_Message : Word): Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_DisableErrorMessage     (    dw_DriverHandle : Dword): Byte;FAR;STDCALL;


   FUNCTION  b_ADDIDATA_FormatErrorMessage (dw_DriverHandle : Dword;
                                            i_ErrorNumber : Integer;
                       		            pc_ErrorString : PCHAR;
                              	            w_ErrorStringSize : Word;
                          	            w_FunctionNumber : Word;
                             	            pc_FunctionName : PCHAR;
                          	            w_FunctionStringSize : Word) : Byte;FAR;STDCALL;



IMPLEMENTATION
{$O-}
{$A-}



   FUNCTION   i_ADDIDATA_GetLastError	        (    dw_DriverHandle : Dword;
					                             VAR pw_FunctionNumber : Word;
					                             VAR pi_ErrorCode : Integer;
					                             VAR pb_ErrorLevel : BYTE): INTEGER;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_EnableErrorMessage      (    dw_DriverHandle : Dword;
					                                  h_WndHandle : Handle;
					                                  w_Message : Word): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_DisableErrorMessage     (    dw_DriverHandle : Dword): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_FormatErrorMessage (dw_DriverHandle : Dword;
                                            i_ErrorNumber : Integer;
                       		            pc_ErrorString : PCHAR;
                              	            w_ErrorStringSize : Word;
                          	            w_FunctionNumber : Word;
                             	            pc_FunctionName : PCHAR;
                          	            w_FunctionStringSize : Word) : Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

{$O+}
{$A+}

END.
