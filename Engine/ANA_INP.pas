UNIT ANA_INP;

INTERFACE

USES
    WINDOWS,DEFINE;

   FUNCTION b_ADDIDATA_GetNumberOfAnalogInputs (dw_DriverHandle : Dword;
			                        VAR pw_ChannelNbr : Word):Byte;FAR;STDCALL;


   FUNCTION b_ADDIDATA_GetNumberOfAnalogInputModules (dw_DriverHandle : Dword;
						      VAR pw_ModuleNbr : Word):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetNumberOfAnalogInputsForTheModule (dw_DriverHandle : Dword;
							    w_Module : Word;
							    VAR pw_ChannelNbr : Word):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetAnalogInputModuleGeneralInformation		(dw_DriverHandle         : Dword;
									 w_Module                : Word;
									 Var s_ModuleInformation : str_AnalogInputModuleInformation;
									 dw_StructSize           : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetAnalogInputModuleSingleAcquisitionInformation	(dw_DriverHandle          : Dword;
									 w_Module                 : Word;
									 Var ps_ModuleInformation : str_AnalogInputSingleAcquisitionInformation;
									 dw_StructSize            : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetAnalogInputModuleSCANInformation		(dw_DriverHandle          : Dword;
									 w_Module                 : Word;
									 Var ps_ModuleInformation : str_AnalogInputSCANInformation;
									 dw_StructSize            : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetAnalogInputModuleAutoRefreshInformation	(dw_DriverHandle          : Dword;
									 w_Module                 : Word;
									 Var ps_ModuleInformation : str_AnalogInputAutoRefreshInformation;
									 dw_StructSize            : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetAnalogInputModuleSequenceInformation		(dw_DriverHandle          : Dword;
									 w_Module                 : Word;
									 Var ps_ModuleInformation : str_AnalogInputSequenceInformation;
									 dw_StructSize            : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetAnalogInputInformation (dw_DriverHandle : Dword;
						  w_Channel : Word;
						  VAR ps_ChannelInformation : str_GetAnalogMesureInformation;
						  dw_StructSize : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_InitAnalogInput (dw_DriverHandle : Dword;
		  		        w_Channel : Word;
				        VAR ps_InitParameters : str_InitAnalogInput;
				        dw_StructSize : DWORD):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_TestAnalogInputShortCircuit  (dw_DriverHandle : Dword; 
   				  		     w_Channel : Word;
						     b_SignTest : Byte;
						     d_VoltageValue : Double;
						     VAR pb_ShortCircuit : Byte):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_TestAnalogInputConnection  (dw_DriverHandle : Dword;  
                                                   w_Channel : Word;
                                                   b_SignTest : Byte;
                                                   d_VoltageValue : Double;
                                                   VAR pb_ConnectionStatus : Byte):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_Read1AnalogInput (dw_DriverHandle : Dword;
				         w_Channel : Word;
				         dw_ConversionTime : Dword;
				         b_ConversionTimeUnit : Byte;
				         b_InterruptFlag : Byte;
				         VAR pdw_ChannelValue : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_ReadMoreAnalogInputs (dw_DriverHandle : Dword;
					     w_FirstChannel : Word;
					     w_LastChannel : Word;
					     dw_ConversionTime : Dword;
					     b_ConversionTimeUnit : Byte;
					  b_InterruptFlag : Byte;
					  VAR pdw_ChannelArrayValue : DWord):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_ConvertDigitalToRealAnalogValue (dw_DriverHandle : Dword;
                                                        w_Channel : Word;
                                                        VAR pdw_DigitalValue : DWord;
                                                        VAR pd_RealValue : Double):Byte;FAR;STDCALL;
   
   FUNCTION b_ADDIDATA_ConvertMoreDigitalToRealAnalogValues(dw_DriverHandle : Dword;
                                                            w_FirstChannel : Word;
						            w_LastChannel : Word;
                                                            VAR pdw_DigitalValue : Dword;
                                                            VAR pd_RealValue : Double):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_InitAnalogInputSCAN (dw_DriverHandle : Dword;
					    VAR ps_InitParameters : str_InitAnalogInputSCAN;
					    dw_StructSize : DWord;
					    VAR pdw_SCANHandle : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_InitAnalogInputSCANAcquisition	(dw_DriverHandle       : Dword;
							 VAR ps_InitParameters : str_InitAnalogInputSCANAcquisition;
							 dw_StructSize         : DWord;
							 VAR dw_SCANHandle     : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_StartAnalogInputSCAN (dw_DriverHandle : Dword;
                                             dw_SCANHandle : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetAnalogInputSCANStatus (dw_DriverHandle : Dword;
                                                 dw_SCANHandle : DWord;
                                                 VAR pb_SCANStatus : Byte):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_ConvertDigitalToRealAnalogValueSCAN (dw_DriverHandle : Dword;
                                                            dw_SCANHandle : DWord;
                                                            VAR pdw_DigitalValueArray : Dword;
                                                            VAR pd_RealValueArray : Double):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_StopAnalogInputSCAN (dw_DriverHandle : Dword;
                                            dw_SCANHandle : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_CloseAnalogInputSCAN (dw_DriverHandle : Dword;
                                             dw_SCANHandle : Dword):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_ReleaseAnalogInput	(dw_DriverHandle : Dword;
						 w_Channel : Word):Byte;FAR;STDCALL;



   FUNCTION b_ADDIDATA_TestAnalogInputAsynchronousFIFOFull 	(    dw_DriverHandle : Dword;
								 Var pb_Full         : Byte):Byte;FAR;STDCALL;

   FUNCTION b_ADDIDATA_GetAnalogInputModuleNumber		(    dw_DriverHandle : Dword;
								      w_Channel      : Word;
								 Var pw_Module       : Word):Byte;FAR;STDCALL;


   FUNCTION  b_ADDIDATA_GetAnalogInputAutoRefreshChannelPointer	(dw_DriverHandle             : DWord;
								 w_Channel                   : Word;
								 ppv_ApplicationLevelPointer : PPointer;
								 ppv_KernelLevelPointer      : PPointer):Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_GetAnalogInputAutoRefreshModulePointer	(dw_DriverHandle             : Dword;
								 w_Module                    : Word;
								 ppv_ApplicationLevelPointer : PPointer;
								 ppv_KernelLevelPointer      : PPointer):Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_GetAnalogInputAutoRefreshModuleCounterPointer
								(dw_DriverHandle             : Dword;
								 w_Module                    : Word;
								 ppv_ApplicationLevelPointer : PPointer;
								 ppv_KernelLevelPointer      : PPointer):Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_StartAnalogInputAutoRefresh		(dw_DriverHandle      : DWord;
								 w_Module             : Word;
								 dw_ConversionTime    : DWord;
								 b_ConversionTimeUnit : Byte):Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_StopAnalogInputAutoRefresh		(dw_DriverHandle : Dword;
								 w_Module        : Word):Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_Read1AnalogInputAutoRefreshValue	(dw_DriverHandle      : DWord;
								 w_Channel            : Word;
								 Var pdw_ChannelValue : DWord):Byte;FAR;STDCALL;

   FUNCTION  b_ADDIDATA_InitAnalogInputSequenceAcquisition	(    dw_DriverHandle          : DWord;
								      dw_NbrOfChannel         : DWord;
								 Var  pw_SequenceChannelArray : Word;
								 Var  ps_InitParam            : str_InitAnalogMeasureSequenceAcquisition;
								      dw_StructSize           : Dword;
								 Var pdw_SEQHandle            : DWord):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_StartAnalogInputSequenceAcquisition	(dw_DriverHandle : DWord;
								 dw_SEQHandle    : DWord):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_PauseAnalogInputSequenceAcquisition	(dw_DriverHandle : DWord;
								 dw_SEQHandle    : DWord):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_StopAnalogInputSequenceAcquisition	(dw_DriverHandle : DWord;
								 dw_SEQHandle    : DWord):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_ReleaseAnalogInputSequenceAcquisition	(dw_DriverHandle : DWord;
								 dw_SEQHandle    : DWord):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_ConvertDigitalToRealAnalogValueSequence (    dw_DriverHandle : DWord;
								      dw_SEQHandle    : DWord;
								  Var pdw_DigitalValue: DWord;
								  Var  pd_AnalogValue : Double):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_GetAnalogInputSequenceAcquisitionHandleStatus	(     dw_DriverHandle             : DWord;
									       w_Module                   : Word;
									 Var  pb_InitialisationStatus     : Byte;
									 Var pdw_LastInitialisedSEQHandle : DWord;
									 Var  pb_CurrentSEQStatus         : Byte;
									 Var pdw_CurrentSEQHandle         : DWord):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_GetAnalogInputHardwareTriggerInformation         (    dw_DriverHandle               : DWord;
										w_Module                     : Word;
									   Var ps_HardwareTriggerInformation : str_AnalogInputHardwareTriggerInformation;
									       dw_StructSize                 : DWord):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_EnableDisableAnalogInputHardwareTrigger        (dw_DriverHandle              : DWord;
									 w_Module                     : Word;
									 b_HardwareTriggerFlag        : Byte;
									 b_HardwareTriggerLevel       : Byte;
									 b_HardwareTriggerAction      : Byte;
									 dw_HardwareTriggerCycleCount : Dword;
									 dw_HardwareTriggerCount      : Dword;
									 dw_TimeOut                   : Dword):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_GetAnalogInputHardwareTriggerStatus		(     dw_DriverHandle          : DWord;
									       w_Module                : Word;
									 Var  pb_HardwareTriggerFlag   : Byte;
									 Var  pb_HardwareTriggerStatus : Byte;
									 Var pdw_HardwareTriggerCount  : DWord;
									 Var  pb_HardwareTriggerState  : Byte):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_GetAnalogInputSoftwareTriggerInformation       (   dw_DriverHandle                : DWord;
									     w_Module                      : Word;
									 Var ps_SoftwareTriggerInformation : str_AnalogInputSoftwareTriggerInformation;
									     dw_StructSize                 : DWord):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_EnableDisableAnalogInputSoftwareTrigger        (dw_DriverHandle         : DWord;
									 w_Module                : Word;
									 b_SoftwareTriggerFlag   : Byte;
									 b_SoftwareTriggerAction : Byte):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_AnalogInputSoftwareTrigger			(dw_DriverHandle         : DWord;
									 w_Module                : Word):Byte;FAR;STDCALL;

   FUNCTION   b_ADDIDATA_GetAnalogInputSoftwareTriggerStatus		(    dw_DriverHandle          : DWord;
									      w_Module                : Word;
									 Var pb_SoftwareTriggerFlag   : Byte;
									 Var pb_SoftwareTriggerStatus : Byte):Byte;FAR;STDCALL;

IMPLEMENTATION
{$O-}
{$A-}

   FUNCTION b_ADDIDATA_GetNumberOfAnalogInputs (dw_DriverHandle : Dword;
			                        VAR pw_ChannelNbr : Word):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetNumberOfAnalogInputModules (dw_DriverHandle : Dword;
						      VAR pw_ModuleNbr : Word):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetNumberOfAnalogInputsForTheModule (dw_DriverHandle : Dword;
						            w_Module : Word;
							    VAR pw_ChannelNbr : Word):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetAnalogInputModuleGeneralInformation		(dw_DriverHandle         : Dword;
									 w_Module                : Word;
									 Var s_ModuleInformation : str_AnalogInputModuleInformation;
									 dw_StructSize           : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetAnalogInputModuleSingleAcquisitionInformation	(dw_DriverHandle          : Dword;
									 w_Module                 : Word;
									 Var ps_ModuleInformation : str_AnalogInputSingleAcquisitionInformation;
									 dw_StructSize            : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetAnalogInputModuleSCANInformation		(dw_DriverHandle          : Dword;
									 w_Module                 : Word;
									 Var ps_ModuleInformation : str_AnalogInputSCANInformation;
									 dw_StructSize            : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetAnalogInputModuleAutoRefreshInformation	(dw_DriverHandle          : Dword;
									 w_Module                 : Word;
									 Var ps_ModuleInformation : str_AnalogInputAutoRefreshInformation;
									 dw_StructSize            : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetAnalogInputModuleSequenceInformation		(dw_DriverHandle          : Dword;
									 w_Module                 : Word;
									 Var ps_ModuleInformation : str_AnalogInputSequenceInformation;
									 dw_StructSize            : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetAnalogInputInformation (dw_DriverHandle : Dword;
						  w_Channel : Word;
						  VAR ps_ChannelInformation : str_GetAnalogMesureInformation;
						  dw_StructSize : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_InitAnalogInput (dw_DriverHandle : Dword;
		  		        w_Channel : Word;
				        VAR ps_InitParameters : str_InitAnalogInput;
				        dw_StructSize : DWORD):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_TestAnalogInputShortCircuit  (dw_DriverHandle : Dword; 
   				  		     w_Channel : Word;
						     b_SignTest : Byte;
						     d_VoltageValue : Double;
						     VAR pb_ShortCircuit : Byte):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_TestAnalogInputConnection  (dw_DriverHandle : Dword;  
                                                   w_Channel : Word;
                                                   b_SignTest : Byte;
                                                   d_VoltageValue : Double;
                                                   VAR pb_ConnectionStatus : Byte):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_Read1AnalogInput (dw_DriverHandle : Dword;
				         w_Channel : Word;
				         dw_ConversionTime : Dword;
				         b_ConversionTimeUnit : Byte;
				         b_InterruptFlag : Byte;
				         VAR pdw_ChannelValue : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_ReadMoreAnalogInputs (dw_DriverHandle : Dword;
					     w_FirstChannel : Word;
					     w_LastChannel : Word;
					     dw_ConversionTime : Dword;
					     b_ConversionTimeUnit : Byte;
					  b_InterruptFlag : Byte;
					  VAR pdw_ChannelArrayValue : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_ConvertDigitalToRealAnalogValue (dw_DriverHandle : Dword;
                                                        w_Channel : Word;
                                                        VAR pdw_DigitalValue : DWord;
                                                        VAR pd_RealValue : Double):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';
   
   FUNCTION b_ADDIDATA_ConvertMoreDigitalToRealAnalogValues(dw_DriverHandle : Dword;
                                                            w_FirstChannel : Word;
						            w_LastChannel : Word;
                                                            VAR pdw_DigitalValue : Dword;
                                                            VAR pd_RealValue : Double):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_InitAnalogInputSCAN (dw_DriverHandle : Dword;
					    VAR ps_InitParameters : str_InitAnalogInputSCAN;
                                            dw_StructSize : DWord;  
					    VAR pdw_SCANHandle : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_InitAnalogInputSCANAcquisition	(dw_DriverHandle       : Dword;
							 VAR ps_InitParameters : str_InitAnalogInputSCANAcquisition;
							 dw_StructSize         : DWord;
							 VAR dw_SCANHandle     : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_StartAnalogInputSCAN (dw_DriverHandle : Dword;
                                             dw_SCANHandle : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetAnalogInputSCANStatus (dw_DriverHandle : Dword;
                                                 dw_SCANHandle : DWord;
                                                 VAR pb_SCANStatus : Byte):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_ConvertDigitalToRealAnalogValueSCAN (dw_DriverHandle : Dword;
                                                            dw_SCANHandle : DWord;
                                                            VAR pdw_DigitalValueArray : Dword;
                                                            VAR pd_RealValueArray : Double):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_StopAnalogInputSCAN (dw_DriverHandle : Dword;
                                            dw_SCANHandle : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_CloseAnalogInputSCAN (dw_DriverHandle : Dword;
					     dw_SCANHandle : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_ReleaseAnalogInput	(dw_DriverHandle : Dword;
						 w_Channel : Word):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_TestAnalogInputAsynchronousFIFOFull 	(    dw_DriverHandle : Dword;
								 Var pb_Full         : Byte):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION b_ADDIDATA_GetAnalogInputModuleNumber		(    dw_DriverHandle : Dword;
								      w_Channel      : Word;
								 Var pw_Module       : Word):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';


   FUNCTION  b_ADDIDATA_GetAnalogInputAutoRefreshChannelPointer	(dw_DriverHandle             : DWord;
								 w_Channel                   : Word;
								 ppv_ApplicationLevelPointer : PPointer;
								 ppv_KernelLevelPointer      : PPointer):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_GetAnalogInputAutoRefreshModulePointer	(dw_DriverHandle             : Dword;
								 w_Module                    : Word;
								 ppv_ApplicationLevelPointer : PPointer;
								 ppv_KernelLevelPointer      : PPointer):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_GetAnalogInputAutoRefreshModuleCounterPointer
								(dw_DriverHandle             : Dword;
								 w_Module                    : Word;
								 ppv_ApplicationLevelPointer : PPointer;
								 ppv_KernelLevelPointer      : PPointer):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_StartAnalogInputAutoRefresh		(dw_DriverHandle      : DWord;
								 w_Module             : Word;
								 dw_ConversionTime    : DWord;
								 b_ConversionTimeUnit : Byte):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_StopAnalogInputAutoRefresh		(dw_DriverHandle : Dword;
								 w_Module        : Word):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_Read1AnalogInputAutoRefreshValue	(dw_DriverHandle      : DWord;
								 w_Channel            : Word;
								 Var pdw_ChannelValue : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION  b_ADDIDATA_InitAnalogInputSequenceAcquisition	(    dw_DriverHandle          : DWord;
								      dw_NbrOfChannel         : DWord;
								 Var  pw_SequenceChannelArray : Word;
								 Var  ps_InitParam            : str_InitAnalogMeasureSequenceAcquisition;
								      dw_StructSize           : Dword;
								 Var pdw_SEQHandle            : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_StartAnalogInputSequenceAcquisition	(dw_DriverHandle : DWord;
								 dw_SEQHandle    : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_PauseAnalogInputSequenceAcquisition	(dw_DriverHandle : DWord;
								 dw_SEQHandle    : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_StopAnalogInputSequenceAcquisition	(dw_DriverHandle : DWord;
								 dw_SEQHandle    : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_ReleaseAnalogInputSequenceAcquisition	(dw_DriverHandle : DWord;
								 dw_SEQHandle    : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_ConvertDigitalToRealAnalogValueSequence (    dw_DriverHandle : DWord;
								      dw_SEQHandle    : DWord;
								  Var pdw_DigitalValue: DWord;
								  Var  pd_AnalogValue : Double):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_GetAnalogInputSequenceAcquisitionHandleStatus	(     dw_DriverHandle             : DWord;
									       w_Module                   : Word;
									 Var  pb_InitialisationStatus     : Byte;
									 Var pdw_LastInitialisedSEQHandle : DWord;
									 Var  pb_CurrentSEQStatus         : Byte;
									 Var pdw_CurrentSEQHandle         : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_GetAnalogInputHardwareTriggerInformation         (    dw_DriverHandle               : DWord;
										w_Module                     : Word;
									   Var ps_HardwareTriggerInformation : str_AnalogInputHardwareTriggerInformation;
									       dw_StructSize                 : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_EnableDisableAnalogInputHardwareTrigger        (dw_DriverHandle              : DWord;
									 w_Module                     : Word;
									 b_HardwareTriggerFlag        : Byte;
									 b_HardwareTriggerLevel       : Byte;
									 b_HardwareTriggerAction      : Byte;
									 dw_HardwareTriggerCycleCount : Dword;
									 dw_HardwareTriggerCount      : Dword;
									 dw_TimeOut                   : Dword):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_GetAnalogInputHardwareTriggerStatus		(     dw_DriverHandle          : DWord;
									       w_Module                : Word;
									 Var  pb_HardwareTriggerFlag   : Byte;
									 Var  pb_HardwareTriggerStatus : Byte;
									 Var pdw_HardwareTriggerCount  : DWord;
									 Var  pb_HardwareTriggerState  : Byte):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_GetAnalogInputSoftwareTriggerInformation       (   dw_DriverHandle                : DWord;
									     w_Module                      : Word;
									 Var ps_SoftwareTriggerInformation : str_AnalogInputSoftwareTriggerInformation;
									     dw_StructSize                 : DWord):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_EnableDisableAnalogInputSoftwareTrigger        (dw_DriverHandle         : DWord;
									 w_Module                : Word;
									 b_SoftwareTriggerFlag   : Byte;
									 b_SoftwareTriggerAction : Byte):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_AnalogInputSoftwareTrigger			(dw_DriverHandle         : DWord;
									 w_Module                : Word):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

   FUNCTION   b_ADDIDATA_GetAnalogInputSoftwareTriggerStatus		(    dw_DriverHandle          : DWord;
									      w_Module                : Word;
									 Var pb_SoftwareTriggerFlag   : Byte;
									 Var pb_SoftwareTriggerStatus : Byte):Byte;FAR;STDCALL;EXTERNAL 'ADDIDATA.DLL';

{$O+}
{$A+}

END.
