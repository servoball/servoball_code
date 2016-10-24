UNIT INIT;

INTERFACE

USES
    WINDOWS,DEFINE;

TYPE
    PPointer      = ^Pointer;
    pw_WordPtr    = ^WORD;

    b_ByteArray   = ARRAY [0..32766] OF BYTE;
    pb_ArrayPtr   = ^b_ByteArray;

    w_WordArray   = ARRAY [0..32766] OF WORD;
    pw_ArrayPtr   = ^w_WordArray;

    l_LongArray   = ARRAY [0..32766] OF LONGINT;
    pl_ArrayPtr   = ^l_LongArray;


   FUNCTION   i_ADDIDATA_OpenWin32Driver		(     b_CompilerDefine : BYTE;
						                         VAR pdw_DriverHandle   : Dword): INTEGER;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_CloseWin32Driver		(	 dw_DriverHandle   : Dword): Byte;FAR;STDCALL;

   PROCEDURE  v_ADDIDATA_GetDriverVersion (VAR pdw_DriverVersion : DWord);FAR;STDCALL;


   FUNCTION   i_ADDIDATA_GetLocalisation    (s_RequestInformation                 : str_RequestInformation;
                                             dw_RequestInformationStructSize      : Dword;
                                             Var ps_LocalisationInformation       : str_LocalisationInformation;
                                             dw_LocalisationInformationStructSize : Dword): INTEGER;FAR;STDCALL;


IMPLEMENTATION
{$O-}
{$A-}


   FUNCTION   i_ADDIDATA_OpenWin32Driver		(     b_CompilerDefine : BYTE;
						                         VAR pdw_DriverHandle   : Dword): INTEGER;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_CloseWin32Driver		(	 dw_DriverHandle   : Dword): Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   PROCEDURE  v_ADDIDATA_GetDriverVersion (VAR pdw_DriverVersion : DWord);FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   i_ADDIDATA_GetLocalisation    (s_RequestInformation                 : str_RequestInformation;
                                             dw_RequestInformationStructSize      : Dword;
                                             Var ps_LocalisationInformation       : str_LocalisationInformation;
                                             dw_LocalisationInformationStructSize : Dword): INTEGER;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

{$O+}
{$A+}

END.
