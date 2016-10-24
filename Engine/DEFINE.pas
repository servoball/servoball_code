UNIT DEFINE;

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

    dw_DwordArray   = ARRAY [0..32766] OF DWORD;
    pdw_ArrayPtr   = ^dw_DwordArray;

    d_DoubleArray  = ARRAY [0..32766] OF Double;
    pd_ArrayPtr   = ^d_DoubleArray;

  str_GetAnalogMesureInformation = packed record
	b_InputsResolution : Byte;	    // Return the input resolution
					    // 8 : 8 Bit Resolution
					    // 16: 16 Bit Resolution, ...
	b_CanUsedInterrupt : Byte;	    // 0 : No Interrupt can be generated
					    // 1 : Interrupt can be generated
	b_UnipolarBipolarConfigurable : Byte;	// 0 : Unipolar/Bipolar hardware configurable
						// 1 : Unipolar/Bipolar configurable
	b_UnipolarAvailable : Byte;	    // 0 : Can not configure to unipolar
					    // 1 : Can configure to unipolar
	b_BipolarAvailable : Byte; 	    // 0 : Can not configure to bipolar
					    // 1 : Can configure to bipolar
	b_SingleDifferenceSelected : Byte;	// 0 : Single/difference hardware configurable
						// 1 : Single/difference configurable
	b_DCCouplingAvailable : Byte;	// 0 : Can not configure coupling DC
					// 1 : Can configure coupling DC
        b_ACCouplingAvailable : Byte;	// 0 : Can not configure coupling AC
					// 1 : Can configure coupling AC
	b_BufferAvailable : Byte;	// 0 : No hardware buffer available
					// 1 : Hardware buffer available
	b_CanGerenatedWarning : Byte;	// 0 : Alarm not available
					// 1 : Alarm available
	b_CurrentSourceSetBySoft : Byte;// 0 : The current source must not be activated by the software
			    	         // 1 : The current source must be activated by the software.
	b_NbrOfGain : Byte;		// Return the number of gain value available
        dw_Reserved1 : DWORD;
	d_GainAvailable : Array [0..254] of Double; 	// Define the available gain value
	b_OffsetRangeAvailable : Byte;	// 0 : Offset not allowed
					// 1 : Offset allowed
	b_Reserved2 : Byte;
	w_OffsetRangeResolution : Word;// Offset resolution
					    //8  : 8-bit resolution
					    //16 : 16-bit resolution, ...
	b_OffsetRangeDenominator : Byte;	// Offset denominator step value
	b_OffsetRangeNumerator : Byte;	        // Offset numerator step value
	b_OpenInputDetection : Byte;	// 0 : Open input detection not available
				        // 1 : Open input detection available
	b_ShortCircuitDetection : Byte;// 0 : Short-circuit detection not available
	                                // 1 : Short-circuit detection available
	d_UMax : Double;		// Return the maximal input voltage value in V or A
	d_URef : Double;		// Return the reference input voltage value in V or A
        b_InputType : Byte;		// Selected user input type
					    // ADDIDATA_RTD
					    // ADDIDATA_THERMOCOUPLE
					    // ADDIDATA_TEMPERATURE_ON_BOARD
					    // ADDIDATA_OHM
					    // ADDIDATA_ANALOG_INPUT_V_OR_I
	b_TypePrecision : Byte;	// Precision of the input
					    // ADDIDATA_THERMOCOUPLE_TYPE_B
					    // ADDIDATA_THERMOCOUPLE_TYPE_E
					    // ADDIDATA_THERMOCOUPLE_TYPE_J
					    // ADDIDATA_THERMOCOUPLE_TYPE_K
					    // ADDIDATA_THERMOCOUPLE_TYPE_N
					    // ADDIDATA_THERMOCOUPLE_TYPE_R
					    // ADDIDATA_THERMOCOUPLE_TYPE_S
					    // ADDIDATA_THERMOCOUPLE_TYPE_T
					    // or
					    // ADDIDATA_RTD_TYPE_PT
					    // ADDIDATA_RTD_TYPE_Ni

	w_InputTypeValue : Word;

	b_AutoCalibration : Byte;		// 0 : Auto calibration not available
						// 1 : Auto calibration available
      	b_CJCAvailable : Byte;			// 0 : Without CJC
						// 1 : Wtih CJC
	b_ConversionMustSetting : Byte;	// 0 : The conversion time for a single
						//     acquisition is fixed via Hardware (jumper)
						// 1 : The conversion time for a single
						//     acquisition is fixed via Software
	b_ConversionCalcType : Byte;		// 0 : Binary type
						//     (XX000,XX001,XX010,XX011,XX100)
						// 1 : Multiple type (60,120,240,480,960, ...)
	b_ConversionUnitType : Byte;		// 0 : Time unity      (ns,æs,ms,s, ...)
						// 1 : Frequency unity (MHz,KHz,Hz,mHz, ...)
	b_AvailableConversionUnit : Byte;	//For time unity :
						//D0: 	0 : ns not available
						//	1 : ns available
						//D1:	0 : æs not available
						//	1 : æs available
						//D2:	0 : ms not available
						//	1 : ms available
						//D3:	0 : s not available
						//	1 : s available
						//For frequency unity:
						//D0 : 	0 : MHz not available
						//	1 : MHz available
						//D1:	0 : KHz not available
						//	1 : KHz available
						//D2:	0 : Hz not available
						//	1 : Hz available
						//D3:	0 : mHz not available
						//	1 : mHz available
	w_ConversionResolution : Word;		//  8 : 8-bit resolution
						//  16: 16-bit resolution, ...
	w_MinConversionTime : Word;		//Minimum conversion time.
						//7000  : 7000(ns)
						//10000 : 10000(ns), ...
	w_ConversionStep : Word;		//Conversion time steps
						//20 : 20 steps
						//50 : 50 steps, ...
	b_SEQArrayAvailable : Byte;		// 0 : Sequence array not available
						// 1 : Sequence array available
	b_SEQConfigurable : Byte;		// 0 : Sequence fixed
						// 1 : Sequence configurable
	b_SEQHardwareTriggerAvailable : Byte;	// 0 : Hardware trigger not available
						// 1 : Hardware trigger available
	b_SEQHardwareTriggerHighAvailable : Byte; // 0 : Hardware high trigger level not available
						   // 1 : Hardware high trigger level available
	b_SEQHardwareTriggerLowAvailable : Byte;  // 0 : Hardware low trigger level not available
						   // 1 : Hardware low trigger level available
	b_SEQHardwareTriggerAvailableMode : Byte; // 001 : External trigger start a 1 DMA cycle
						   // 010 : Each trigger start a sequence
						   // 100 : Each trigger start a DMA cycle
	b_SEQHardwareGateAvailable : Byte;	// 0 : Hardware gate not available
						// 1 : Hardware gate available
	b_SEQHardwareGateHighAvailable : Byte; // 0 : Hardware high gate level not available
						// 1 : Hardware high gate level available
	b_SEQHardwareGateLowAvailable : Byte;  // 0 : Hardware low gate level not available
						// 1 : Hardware low gate level available
	b_SEQClrIndexAvailable : Byte;	        // 0 : It is not possible to restart the
						// acquisition which the next selected channel from sequence
						// 1 : It's possible to restart the acquisition
						// which  the next selected channel from sequence
	w_SEQAcquisitionMode : Word;		// 00 : The acquisition can work in Single mode
						// 01 : The acquisition can work in continuous mode
						// 11 : The acquisition can work in single and continuous mode
	b_DMAAvailable : Byte;    		// 0 : Board can not used the DMA
						// 1 : Board can used the DMA
	b_DualDMAChannel : Byte;		// 0 : Only 1 DMA channel used
						// 1 : Board can used 2 DMA channels
	b_SEQCounterAvailable : Byte;		// 0 : DMA/conversion counter not available
						// 1 : DMA/conversion counter available
	b_SEQCounterMode : Byte;		//01 : Counter can counter the number of sequence
						//10 : Counter can counter the number of DMA cycle
						//11 : Counter can counter the number of DMA cycle
						//     or the number of sequence
	b_SEQCommonGain : Byte;		// Define if the gain can be different for each input
						// 0 : Gain is common on each input
						// 1 : Gain can be different for each input.
	b_SEQCommonPolarity : Byte;		// Define if the polarity can be different for each input
						// 0 : Polarity is common on each input
						// 1 : Polarity can be different for each input.
	b_SEQCommonOffsetRange : Byte;		// Define if the offset can be different for each input
						// 0 : Offset is common on each input
						// 1 : Offset can be different for each input.
	b_SEQCommonCoupling : Byte;
	w_SEQCounterResolution : Word;		// Counter resolution
						//8  : 8-bit resolution
						//16 : 16-bit resolution, ...
	b_SEQDelayTimeConfigurable : Byte;	// 0 : Delay after each sequence not available
						// 1 : Delay after each sequence available
	b_SEQDelayMode : Byte;
	b_SEQDelayCalcType : Byte; 		// 0 : Binary type
						//         (XX000,XX001,XX010,XX011,XX100)
						// 1 : Multiple type (60,120,240,480,960, ...)
	b_SEQDelayTimeUnitType : Byte;		// 0 : Time unity	(ns,æs,ms,s, ...)
						// 1 : Frequency unity (MHz,KHz,Hz,mHz, ...)
	b_SEQDelayValueType : Byte;		// 0 : Value to write in the register is the value in s or in Hz
						// 1 : Value to write in the register is the step multiplier
	b_SEQDelayTimeUnit : Byte;		//For time unity:
						//D0: 	0 : ns not available
						//	1 : ns available
						//D1:	0 : us not available
						//	1 : us available
						//D2:	0 : ms not available
						//	1 : ms available
						//D3:	0 : s not available
						//	1 : s available
						//For frequency unity:
						//D0 : 	0 : MHz not available
						//	1 : MHz available
						//D1:	0 : KHz not available
						//	1 : KHz available
						//D2:	0 : Hz not available
						//	1 : Hz available
						//D3:	0 : mHz not available
						//	1 : mHz available
	w_SEQDelayTimeResolution : Word;	// Delay time resolution
						//8  : 8-bit resolution
						//16 : 16-bit resolution, ...
	w_SEQMinDelayTime : Word;		//Min delay time.
						//7000  : 7000(ns)
						//10000 : 10000(ns), ...
	w_SEQDelayTimeStep : Word;		//Conversion delay time steps
						//20 : 20 steps
						//50 : 50 steps, ...
	b_SEQUnipolarBipolarConfigurable : Byte;// 0 : Unipolar/Bipolar hardware configurable
						 // 1 : Unipolar/Bipolar configurable
	b_SEQUnipolarAvailable : Byte;		// 0 : Can not configurat to unipolar
						// 1 : Can configurat to unipolar
	b_SEQBipolarAvailable : Byte; 		// 0 : Can not configurat to bipolar
						// 1 : Can configurat to bipolar
	b_SEQDCCouplingAvailable : Byte;	// 0 : Can not configurate to DC Coupling
						// 1 : Can configurate DC Coupling
	b_SEQACCouplingAvailable : Byte;	// 0 : Can not configurate to AC coupling
						// 1 : Can configurate AC coupling
	b_SEQBufferAvailable : Byte;		// 0 : No hardware buffer available
						// 1 : Hardware buffer available
	b_SEQNbrOfGain : Byte;			// Return the number of gain value available
	b_Reserved3 : Byte;
        w_Reserved4 : Word; 
	dw_Reserved5 : Dword;
	d_SEQGainAvailable : Array[0..254] of Double; // Define the available gain value
	b_SEQOffsetRangeAvailable : Byte;	// 0 : Offset not allowed
						// 1 : Offset allowed
        b_Reserved6 : Byte;
	w_SEQOffsetRangeResolution : Word;	// Offset resolution
						//8  : 8-bit resolution
						//16 : 16-bit resolution, ...
	b_SEQOffsetRangeDenominator : Byte;	// Offset denominator step value
	b_SEQOffsetRangeNumerator : Byte;	// Offset numerator step value

	b_SCANAvailable : Byte;		// 0 : SCAN not available
						// 1 : SCAN available
	b_SCANConfigurable : Byte;		// 0 : SCAN fixed
						// 1 : SCAN configurable (The first and the last
						// channel can be given)
	b_SCANHardwareTriggerAvailable : Byte; // 0 : Hardware trigger not available
						// 1 : Hardware trigger available
	b_SCANHardwareTriggerHighAvailable : Byte; // 0 : Hardware high trigger level not available
						    // 1 : Hardware high trigger level available
	b_SCANHardwareTriggerLowAvailable : Byte;  // 0 : Hardware low trigger level not available
						    // 1 : Hardware low trigger level available
	b_SCANHardwareTriggerAvailableMode : Byte;
						// 0001 : External trigger start each acquisition from a SCAN
						// 0010 : Each trigger start each SCAN
						// 0100 : 
						// 1000 : First Trigger start the SCAN Cycle
	b_SCANHardwareGateAvailable : Byte;	// 0 : Hardware gate not available
						// 1 : Hardware gate available
	b_SCANHardwareGateHighAvailable : Byte;// 0 : Hardware high gate level not available
						// 1 : Hardware high gate level available
	b_SCANHardwareGateLowAvailable : Byte; // 0 : Hardware low gate level not available
						// 1 : Hardware low gate level available
	b_SCANClrIndexAvailable : Byte;	// 0 : It is not possible to restart the
						//         acquisition which the next selected channel from SCAN
						// 1 : It's possible to restart the acquisition
						//	   which  the next selected channel from SCAN
	w_SCANAcquisitionMode : Word;		// 00 : The acquisition can work in Single mode
						// 01 : The acquisition can work in continuous mode
						// 11 : The acquisition can work in single and continuous mode
	b_SCANCounterAvailable : Byte;		// 0 : SCAN/conversion counter not available
						// 1 : SCAN/conversion counter available
	b_SCANCounterMode : Byte;		// 01 : Counter can counter the number of SCAN
	b_SCANCommonGain : Byte;		// Define if the gain can be different for each input
						// 0 : Gain is common on each input
						// 1 : Gain can be different for each input.
	b_SCANCommonPolarity : Byte;		// Define if the polarity can be different for each input
						// 0 : Polarity is common on each input
						// 1 : Polarity can be different for each input.
	b_SCANCommonOffsetRange : Byte;	// Define if the offset can be different for each input
						// 0 : Offset is common on each input
						// 1 : Offset can be different for each input.
	b_SCANCommonCoupling : Byte;
	w_SCANCounterResolution : Word;	// Counter resolution
						//8  : 8-bit resolution
						//16 : 16-bit resolution, ...
	b_SCANDelayTimeConfigurable : Byte;    // 0 : Delay after each sequence not available
						// 1 : Delay after each sequence available
	b_SCANDelayMode : Byte;
	b_SCANDelayCalcType : Byte; 		// 0 : Binary type
						//         (XX000,XX001,XX010,XX011,XX100)
						// 1 : Multiple type (60,120,240,480,960, ...)
	b_SCANDelayTimeUnitType : Byte;	// 0 : Time unity	(ns,æs,ms,s, ...)
						// 1 : Frequency unity (MHz,KHz,Hz,mHz, ...)
	b_SCANDelayValueType : Byte;		// 0 : Value to write in the register is the value in s or in Hz
						// 1 : Value to write in the register is the step multiplier
	b_SCANDelayTimeUnit : Byte;		//For time unity:
						//D0: 	0 : ns not available
						//	1 : ns available
						//D1:	0 : us not available
						//	1 : us available
						//D2:	0 : ms not available
						//	1 : ms available
						//D3:	0 : s not available
						//	1 : s available
						//For frequency unity:
						//D0 : 	0 : MHz not available
						//	1 : MHz available
						//D1:	0 : KHz not available
						//	1 : KHz available
						//D2:	0 : Hz not available
						//	1 : Hz available
						//D3:	0 : mHz not available
						//	1 : mHz available
	w_SCANDelayTimeResolution : Word;	// Delay time resolution
						//8  : 8-bit resolution
						//16 : 16-bit resolution, ...
	w_SCANMinDelayTime : Word;		//Min delay time.
						//7000  : 7000(ns)
						//10000 : 10000(ns), ...
	w_SCANDelayTimeStep : Word;		//Conversion delay time steps
						//20 : 20 steps
						//50 : 50 steps, ...
	b_SCANUnipolarBipolarConfigurable : Byte;// 0 : Unipolar/Bipolar hardware configurable
						  // 1 : Unipolar/Bipolar configurable
	b_SCANUnipolarAvailable : Byte;	// 0 : Can not configure to unipolar
						// 1 : Can configure to unipolar
	b_SCANBipolarAvailable : Byte; 	// 0 : Can not configure to bipolar
						// 1 : Can configure to bipolar
	b_SCANDCCouplingAvailable : Byte;	// 0 : Can not configurate to DC Coupling
						// 1 : Can configurate DC Coupling
	b_SCANACCouplingAvailable : Byte;	// 0 : Can not configurate to AC coupling
						// 1 : Can configurate AC coupling
	b_SCANBufferAvailable : Byte;		// 0 : No hardware buffer available
						// 1 : Hardware buffer available
	b_SCANNbrOfGain : Byte;		// Return the number of gain value available
	b_Reserved7 : Byte;
        w_Reserved8 : Word;
	d_SCANGainAvailable : Array[0..254] of Double; 	// Define the available gain value
	b_SCANOffsetRangeAvailable : Byte;	// 0 : Offset not allowed
						// 1 : Offset allowed
        b_Reserved9 : Byte;
	w_SCANOffsetRangeResolution : Word;	// Offset resolution
						//8  : 8-bit resolution
						//16 : 16-bit resolution, ...
	b_SCANOffsetRangeDenominator : Byte;	// Offset denominator step value
	b_SCANOffsetRangeNumerator  : Byte;	// Offset numerator step value
	w_Reserved10 : Word;

  end;

  pstr_GetAnalogMesureInformation = ^str_GetAnalogMesureInformation;

  str_InitAnalogInput = packed record

      d_Gain : Double;
      b_Polarity : Byte;
                  // ADDIDATA_UNIPOLAR    
                  // ADDIDATA_BIPOLAR
      b_Reserved1 : Byte;
      w_OffsetRange : Word;
      b_Coupling : Byte;
                  // ADDIDATA_DC_COUPLING 
                  // ADDIDATA_AC_COUPLING 
      b_Reserved2 : Byte;
      w_Reserved3 : Word;
   end;

   (* BEGIN JK 15.12.03 : Append transducer *)
   str_InitAnalogMeasureSequenceAcquisition = packed record
         b_ConvertingTimeUnit       : Byte;
         b_DelayTimeMode            : Byte;
         b_DelayTimeUnit            : Byte;
         b_Reserved                 : Array [0..4] of Byte;
        dw_DelayTime                : DWord;
        dw_ConvertingTime           : DWord;
        dw_SequenceCounter          : DWord;
        dw_InterruptSequenceCounter : DWord;
   end;
   (* END JK 15.12.03 : Append transducer *)

   pstr_InitAnalogInput = ^str_InitAnalogInput;

   str_InitResistanceChannel = packed record
      d_Gain : Double;
      b_Polarity : Byte;
                  // ADDIDATA_UNIPOLAR    
                  // ADDIDATA_BIPOLAR     
      b_Reserved1 : Byte;
      w_OffsetRange : Word;
      b_Coupling : Byte;
                  // ADDIDATA_DC_COUPLING 
                  // ADDIDATA_AC_COUPLING 
      b_Reserved2 : Byte;
      w_Reserved3 : Word;
   end;

   pstr_InitResistanceChannel = ^str_InitResistanceChannel;


   str_InitPressure = packed record
      d_Gain              : Double;
      d_OffsetVoltage     : Double;
      d_SensorSensibility : Double;
   end;

   pstr_InitPressure = ^str_InitPressure;


   str_InitAnalogInputSCAN = packed record
      w_FirstChannel : Word;
      w_LastChannel : Word;
      dw_ConversionTime : Dword;
      b_ConversionTimeUnit : Byte;
      b_SCANTimeMode : Byte;
                      // ADDIDATA_DELAY_NOT_USED	
                      // ADDIDATA_DELAY_MODE1_USED	
                      // ADDIDATA_DELAY_MODE2_USED    
      w_Reserved1 : Word;
      dw_SCANTime : Dword;
      b_SCANTimeUnit : Byte;
      b_SCANMode : Byte;
                      // ADDIDATA_SINGLE_SCAN
                      // ADDIDATA_DEFINED_SCAN_NUMBER
                      // ADDIDATA_CONTINUOUS_SCAN     
      b_ExternTriggerMode : Byte;
                      // ADDIDATA_FIRST_LOW_EDGE_START_ALL_SCAN   
                      // ADDIDATA_FIRST_HIGH_EDGE_START_ALL_SCAN  
                      // ADDIDATA_FIRST_EDGE_START_ALL_SCAN	    
                      // ADDIDATA_EACH_LOW_EDGE_START_A_SCAN
                      // ADDIDATA_EACH_HIGH_EDGE_START_A_SCAN	    
                      // ADDIDATA_EACH_EDGE_START_A_SCAN	    
                      // ADDIDATA_EACH_LOW_EDGE_START_A_SINGLE_ACQUISITION	
                      // ADDIDATA_EACH_HIGH_EDGE_START_A_SINGLE_ACQUISITION	
                      // ADDIDATA_EACH_EDGE_START_A_SINGLE_ACQUISITION	
      b_ExternGateMode : Byte;
                      // ADDIDATA_DISABLE
		      // ADDIDATA_LOW           
                      // ADDIDATA_HIGH           
      dw_SCANCounter : DWord;
   end;

   pstr_InitAnalogInputSCAN = ^str_InitAnalogInputSCAN;

   str_InitTemperatureChannelSCAN = packed record
      w_FirstChannel : Word;
      w_LastChannel : Word;
      dw_ConversionTime : Dword;
      b_ConversionTimeUnit : Byte;
      b_SCANTimeMode : Byte;
                      // ADDIDATA_DELAY_NOT_USED
                      // ADDIDATA_DELAY_MODE1_USED	
                      // ADDIDATA_DELAY_MODE2_USED    
      w_Reserved1 : Word;
      dw_SCANTime : DWord;
      b_SCANTimeUnit : Byte;
      b_SCANMode : Byte;
                      // ADDIDATA_SINGLE_SCAN
                      // ADDIDATA_DEFINED_SCAN_NUMBER 
                      // ADDIDATA_CONTINUOUS_SCAN
      b_ExternTriggerMode : Byte;
                      // ADDIDATA_FIRST_LOW_EDGE_START_ALL_SCAN   
                      // ADDIDATA_FIRST_HIGH_EDGE_START_ALL_SCAN
                      // ADDIDATA_FIRST_EDGE_START_ALL_SCAN	    
                      // ADDIDATA_EACH_LOW_EDGE_START_A_SCAN	    
                      // ADDIDATA_EACH_HIGH_EDGE_START_A_SCAN	    
                      // ADDIDATA_EACH_EDGE_START_A_SCAN	    
                      // ADDIDATA_EACH_LOW_EDGE_START_A_SINGLE_ACQUISITION	
                      // ADDIDATA_EACH_HIGH_EDGE_START_A_SINGLE_ACQUISITION	
                      // ADDIDATA_EACH_EDGE_START_A_SINGLE_ACQUISITION	
      b_ExternGateMode : Byte;
                      // ADDIDATA_DISABLE
		      // ADDIDATA_LOW           
                      // ADDIDATA_HIGH           
      dw_SCANCounter : DWord;
   end;

   pstr_InitTemperatureChannelSCAN = ^str_InitTemperatureChannelSCAN;


   str_InitPressureSCAN = packed record
      w_FirstChannel : Word;
      w_LastChannel : Word;
      dw_ConversionTime : Dword;
      b_ConversionTimeUnit : Byte;
      b_SCANTimeMode : Byte;
                      // ADDIDATA_DELAY_NOT_USED	
                      // ADDIDATA_DELAY_MODE1_USED	
                      // ADDIDATA_DELAY_MODE2_USED
      w_Reserved1 : Word;
      dw_SCANTime : DWord;
      b_SCANTimeUnit : Byte;
      b_SCANMode : Byte;
                      // ADDIDATA_SINGLE_SCAN
                      // ADDIDATA_DEFINED_SCAN_NUMBER 
                      // ADDIDATA_CONTINUOUS_SCAN     
      b_ExternTriggerMode : Byte;
                      // ADDIDATA_FIRST_LOW_EDGE_START_ALL_SCAN   
                      // ADDIDATA_FIRST_HIGH_EDGE_START_ALL_SCAN  
                      // ADDIDATA_FIRST_EDGE_START_ALL_SCAN	    
                      // ADDIDATA_EACH_LOW_EDGE_START_A_SCAN	    
                      // ADDIDATA_EACH_HIGH_EDGE_START_A_SCAN	    
                      // ADDIDATA_EACH_EDGE_START_A_SCAN	    
                      // ADDIDATA_EACH_LOW_EDGE_START_A_SINGLE_ACQUISITION	
                      // ADDIDATA_EACH_HIGH_EDGE_START_A_SINGLE_ACQUISITION	
                      // ADDIDATA_EACH_EDGE_START_A_SINGLE_ACQUISITION	
      b_ExternGateMode : Byte;
                      // ADDIDATA_DISABLE
		      // ADDIDATA_LOW           
                      // ADDIDATA_HIGH           
      dw_SCANCounter : DWord;
   end;

   pstr_InitPressureSCAN = ^str_InitPressureSCAN;

   str_InitResistanceChannelSCAN = packed record
      w_FirstChannel : Word;
      w_LastChannel : Word;
      dw_ConversionTime : DWord;
      b_ConversionTimeUnit : Byte;
      b_SCANTimeMode : Byte;
                      // ADDIDATA_DELAY_NOT_USED
                      // ADDIDATA_DELAY_MODE1_USED
                      // ADDIDATA_DELAY_MODE2_USED
      w_Reserved1 : Word;
      dw_SCANTime : Dword;
      b_SCANTimeUnit : Byte;
      b_SCANMode : Byte;
                      // ADDIDATA_SINGLE_SCAN
                      // ADDIDATA_DEFINED_SCAN_NUMBER
                      // ADDIDATA_CONTINUOUS_SCAN
      b_ExternTriggerMode : Byte;
                      // ADDIDATA_FIRST_LOW_EDGE_START_ALL_SCAN
                      // ADDIDATA_FIRST_HIGH_EDGE_START_ALL_SCAN
                      // ADDIDATA_FIRST_EDGE_START_ALL_SCAN
                      // ADDIDATA_EACH_LOW_EDGE_START_A_SCAN
                      // ADDIDATA_EACH_HIGH_EDGE_START_A_SCAN
                      // ADDIDATA_EACH_EDGE_START_A_SCAN
                      // ADDIDATA_EACH_LOW_EDGE_START_A_SINGLE_ACQUISITION
                      // ADDIDATA_EACH_HIGH_EDGE_START_A_SINGLE_ACQUISITION
                      // ADDIDATA_EACH_EDGE_START_A_SINGLE_ACQUISITION
      b_ExternGateMode : Byte;
                      // ADDIDATA_DISABLE
		      // ADDIDATA_LOW
                      // ADDIDATA_HIGH
      dw_SCANCounter : Dword;
    end;
   pstr_InitResistanceChannelSCAN = ^str_InitResistanceChannelSCAN;

(* BEGIN JK 15.12.03 : Append transducer *)

  str_TransducerConvertTimeDivisionFactorInformation = packed record

    b_Configurable         : Byte;  // 0 : Convert time division factor fix
                                    // 1 : Convert time division factor configurable
    b_Steps                : Byte;  // Steps
    b_Initialised          : Byte;  // 0 : Not initialised
                                    // 1 : Initialised
    b_Reserved             : Byte;
    dw_InitialisationValue : DWord;
    dw_MinDivisionFactor   : DWord; // Min division factor
    dw_MaxDivisionFactor   : DWord; // Max division factor
  end;

  str_TransducerInformation = packed record
    c_TransducerType           : Array [0..103] of char;         // Transducer type (name)
    d_Range                    : Double;               // Transducer range (mm)
    d_Sensibility              : Double;               // Transducer sensibility (mv/V/mm)
    d_NominalFrequency         : Double;               // Nominal frequency (Hz)
    d_MinFrequency             : Double;               // Minimal frequency (Hz)
    d_MaxFrequency             : Double;               // Maximal frequency (Hz)
    d_PrimaryNominalVoltage    : Double;               // Primary nominal voltage (Veff)
    w_SelectionIndex           : Word;              // Transducer index selection for the initialisation function
    w_Reserved                 : Array [0..2] of Word;
end;

   str_TransducerModuleInformation = packed record
        b_InputsResolution                  : Byte;    // Returns the input resolution
                                                       // 8: 8-bit resolution
                                                       // 16: 16-bit resolution, ...
        b_SingleAcquisition                 : Byte;    // 0 : Single acquisition not available
                                                       // 1 : Single acquisition available
        b_AutoRefreshAcquisition            : Byte;    // 0 : Auto refresh acquisition not available
                                                       // 1 : Auto refresh acquisition available
        b_ScanAcquisition                   : Byte;    // 0 : Scan acquisition not available
                                                       // 1 : Scan acquisition available
        b_SequenceAcquisition               : Byte;    // 0 : Sequence acquisition not available
                                                       // 1 : Sequence acquisition available
        b_PrimaryOpenInputDetection         : Byte;    // 0: Primary circuit open input detection not available
                                                       // 1: Primary circuit open input detection available
        b_PrimaryShortCircuitDetection      : Byte;    // 0: Primary circuit short-circuit detection not available
                                                       // 1: Primary circuit short-circuit detection available
        b_SecondaryOpenInputDetection       : Byte;    // 0: Secondary circuit open input detection not available
                                                       // 1: Secondary circuit open input detection available
        b_SecondaryShortCircuitDetection    : Byte;    // 0: Secondary circuit short-circuit detection not available
                                                       // 1: Secondary circuit short-circuit detection available
        b_PrimaryOpenInputDetectionIRQ      : Byte;    // 0: Primary circuit open input detection interrupt not available
                                                       // 1: Primary circuit open input detection interrupt available
	b_PrimaryShortCircuitDetectionIRQ   : Byte;    // 0: Primary circuit short-circuit detection interrupt not available
                                                       // 1: Primary circuit short-circuit detection interrupt available
        b_SecondaryOpenInputDetectionIRQ    : Byte;    // 0: Secondary circuit open input detection interrupt not available
                                                       // 1: Secondary circuit open input detection interrupt available
        b_SecondaryShortCircuitDetectionIRQ : Byte;    // 0: Secondary circuit short-circuit detection interrupt not available
                                                       // 1: Secondary circuit short-circuit detection interrupt available
        b_Reserved1                         : Array [0..2] of Byte;
        w_FirstChannelNumber                : Word;    // Return the number from first channel number
        w_LastChannelNumber                 : Word;    // Return the number from last channel number
        b_Reserved2                         : Array [0..3] of Byte;

        b_NumberOfAvailableTransducersType  : Byte;    // Return the number of available transducers type.
        b_Reserved3                         : Array [0..6] of Byte;

        s_TransducerInformation             : Array [0..49] of str_TransducerInformation;
end;

   str_TransducerSingleAcquisitionInformation = packed record
        b_SoftwareTrigger         : Byte;      // 0 : Software trigger not available
                                               // 1 : Software trigger available
	b_HardwareTrigger         : Byte;      // 0 : Hardware trigger not available
					       // 1 : Hardware trigger available
	b_HardwareGate            : Byte;      // 0 : Hardware gate not available
					       // 1 : Hardware gate available
	b_Interrupt               : Byte;      // 0 : Interrupt can not by generated
					       // 1 : Interrupt can by generated (EOC)
	b_Reserved                : Array [0..3] of Byte;
end;

   str_TransducerAutoRefreshInformation = packed record
	b_SoftwareTrigger  : Byte;                     // 0 : Software trigger not available
                                                       // 1 : Software trigger available
        b_HardwareTrigger  : Byte;                     // 0 : Hardware trigger not available
                                                       // 1 : Hardware trigger available
        b_HardwareGate     : Byte;                     // 0 : Hardware gate not available
                                                       // 1 : Hardware gate available
        b_Interrupt        : Byte;                     // 0 : Interrupt can not by generated
                                                       // 1 : Interrupt can by generated (EOC)
        b_AccessMode       : Byte;                     // 8  : 8-bit access mode
                                                       // 16 : 16-bit access mode
						       // 32 : 32-bit access mode
        b_Reserved         : Array [0..2] of Byte;
end;

   str_TransducerSequenceInformation = packed record
        b_SequenceConfigurable      : Byte;            // 0 : Sequence fixed. User muss pass the first and last channel
                                                       // 1 : Sequence configurable
        b_SoftwareTrigger           : Byte;            // 0 : Software trigger not available
                                                       // 1 : Software trigger available
        b_HardwareTrigger           : Byte;            // 0 : Hardware trigger not available
						       // 1 : Hardware trigger available
        b_HardwareGate              : Byte;            // 0 : Hardware gate not available
                                                       // 1 : Hardware gate available
        b_DelayTimeConfigurable     : Byte;            // 0 : Delay after each sequence not available
                                                       // 1 : Delay after each sequence available
        b_DelayAvailableMode        : Byte;            // D0:   0: Mode 1 not available
                                                       //       1: Mode 1 available
                                                       // D1:   0: Mode 2 not available
                                                       //       1: Mode 2 available
        b_DelayCalcType             : Byte;            // 0: Binary type (XX000,XX001,XX010,XX011)
						       // 1: Multiple type (60,120,240,480,960, ...)
        b_DelayTimeUnitType         : Byte;            // 0: Time unit (ns,µs,ms,s, ...)
                                                       // 1: Frequency unit (MHz,kHz,Hz,mHz, ...)
        b_DelayTimeUnit             : Byte;            // For time unit:
                                                       // D0:   0: ns not available
                                                       //       1: ns available
                                                       // D1:   0: µs not available
                                                       //       1: µs available
                                                       // D2:   0: ms not available
                                                       //       1: ms available
						       // D3:   0: s not available
						       //       1: s available
                                                       // For frequency unit:
                                                       // D0:   0: MHz not available
                                                       //       1: MHz available
                                                       // D1:   0: kHz not available
                                                       //       1: kHz available
                                                       // D2:   0: Hz not available
                                                       //       1: Hz available
                                                       // D3:   0: mHz not available
						       //       1: mHz available
        b_Reserved1                 : Array [0..6] of Byte;
        w_DelayTimeResolution       : Word;            // Delay time resolution
                                                       // 8 : 8-bit resolution
                                                       // 16: 16-bit resolution, ...
        w_MinDelayTime              : Word;            // Minimum delay time.
                                                       // 7000 : 7000(ns)
                                                       // 10000: 10000(ns), ...
        w_DelayTimeStep             : Word;            // Conversion delay time steps
                                                       // 20: 20 steps
						       // 50: 50 steps, ...
	b_Reserved2                 : Array [0..1] of Byte;

	dw_MaxNumberOfAcquisition   : DWord;           // Return the max number of acauisition for the single acquisition sequence mode
	b_Reserved3                 : Array [0..3] of Byte;
end;

(* END JK 15.12.03 : Append transducer *)



   str_AnalogInputModuleInformation = packed record
	b_InputsResolution            : Byte;			// Returns the input resolution
								// 8: 8-bit resolution
								// 16: 16-bit resolution, ...
	b_UnipolarBipolarConfigurable : Byte;			// 0 : Unipolar/Bipolar hardware configurable
								// 1 : Unipolar/Bipolar configurable
	b_UnipolarAvailable           : Byte;			// 0 : Can not configure to unipolar
								// 1 : Can configure to unipolar
	b_BipolarAvailable            : Byte; 			// 0 : Can not configure to bipolar
								// 1 : Can configure to bipolar
	b_SingleDifferenceSelected    : Byte;			// 0 : Single mode selected
								// 1 : Difference mode selected
	b_ACAvailable                 : Byte;			// 0 : AC available
								// 1 : AC not available
	b_DCAvailable                 : Byte;			// 0 : DC available
								// 1 : DC not available
	b_AutoCalibration             : Byte;			// 0 : Auto calibration not available
								// 1 : Auto calibration available
	d_UMax                        : Double;			// Return the maximal input voltage value in V or A
	b_ConversionCalcType          : Byte;			// 0 : Binary type
								//     (XX000,XX001,XX010,XX011,XX100)
								// 1 : Multiple type (60,120,240,480,960, ...)
	b_ConversionUnitType          : Byte;			// 0 : Time unity      (ns,æs,ms,s, ...)
								// 1 : Frequency unity (MHz,KHz,Hz,mHz, ...)
	b_AvailableConversionUnit     : Byte;			//For time unity :
								//D0: 	0 : ns not available
								//	1 : ns available
								//D1:	0 : æs not available
								//	1 : æs available
								//D2:	0 : ms not available
								//	1 : ms available
								//D3:	0 : s not available
								//	1 : s available
								//For frequency unity:
								//D0 : 	0 : MHz not available
								//	1 : MHz available
								//D1:	0 : KHz not available
								//	1 : KHz available
								//D2:	0 : Hz not available
								//	1 : Hz available
								//D3:	0 : mHz not available
								//	1 : mHz available
	b_Reserved2                   : Array [0..4] Of Byte;
	w_ConversionResolution        : Word;			//  8 : 8-bit resolution
								//  16: 16-bit resolution, ...
	w_MinConversionTime           : Word;			//Minimum conversion time.
								//7000  : 7000(ns)
								//10000 : 10000(ns), ...
	w_ConversionStep              : Word;			//Conversion time steps
								//20 : 20 steps
								//50 : 50 steps, ...
	b_Reserved3                   : Array [0..1] Of Byte;
	b_SingleAcquisition           : Byte;			// 0 : Single acquisition not available
								// 1 : Single acquisition available
	b_AutoRefreshAcquisition      : Byte;			// 0 : Auto refresh acquisition not available
								// 1 : Auto refresh acquisition available
	b_ScanAcquisition             : Byte;			// 0 : Scan acquisition not available
								// 1 : Scan acquisition available
	b_SequenceAcquisition         : Byte;			// 0 : Sequence acquisition not available
								// 1 : Sequence acquisition available
	b_Reserved4                   : Array [0..3] Of Byte;
	w_FirstChannelNumber          : Word;			// Return the number from first channel number
	w_LastChannelNumber           : Word;			// Return the number from last channel number
	b_Reserved5                   : Array [0..3] Of Byte;
end;

   str_AnalogInputSingleAcquisitionInformation = packed record
	b_Interrupt          : Byte;				// 0 : No interrupt can by generated
								// 1 : Interrupt can by generated
	b_SoftwareTrigger    : Byte;				// 0 : Software trigger not available
								// 1 : Software trigger available
	b_HardwareTrigger    : Byte;				// 0 : Hardware trigger not available
								// 1 : Hardware trigger available
	b_HardwareGate       : Byte;				// 0 : Hardware gate not available
								// 1 : Hardware gate available
	b_NbrOfGain          : Byte;				// Returns the number of gain values available
	b_Reserved1          : Array [0..2] Of Byte;
	d_GainAvailable      : Array [0..254] Of Double;	// Defines the available gain value
end;

   str_AnalogInputAutoRefreshInformation = packed record
	b_Interrupt          : Byte;				// 0 : Interrupt can not by generated
								// 1 : Interrupt can by generated (EOC)
	b_SoftwareTrigger    : Byte;				// 0 : Software trigger not available
								// 1 : Software trigger available
	b_HardwareTrigger    : Byte;				// 0 : Hardware trigger not available
								// 1 : Hardware trigger available
	b_HardwareGate       : Byte;				// 0 : Hardware gate not available
								// 1 : Hardware gate available
	b_AccessMode         : Byte;				// 8  : 8-bit access mode
								// 16 : 16-bit access mode
								// 32 : 32-bit access mode
	b_CommonGain         : Byte;				// Define if the gain can be different for each input
								// 0 : Gain is common on each input
								// 1 : Gain can be different for each input.
	b_CommonPolarity     : Byte;				// Define if the polarity can be different for each input
								// 0 : Polarity is common on each input
								// 1 : Polarity can be different for each input.
	b_Reserved1          : Byte;
	b_NbrOfGain          : Byte;				// Returns the number of gain values available
	b_Reserved2          : Array [0..6] Of Byte;
	d_GainAvailable      : Array [0..254] Of Double;	// Defines the available gain value
end;

   str_AnalogInputSCANInformation = packed record
	b_SCANConfigurable	 : Byte;			// 0 : Sequence fixed. User muss pass the first and last channel
								// 1 : Sequence configurable
	b_SoftwareTrigger	 : Byte;			// 0 : Software trigger not available
								// 1 : Software trigger available
	b_HardwareTrigger	 : Byte;			// 0 : Hardware trigger not available
								// 1 : Hardware trigger available
	b_HardwareGate		 : Byte;			// 0 : Hardware gate not available
								// 1 : Hardware gate available

	b_CommonGain		 : Byte;			// Define if the gain can be different for each input
								// 0 : Gain is common on each input
								// 1 : Gain can be different for each input.
	b_CommonPolarity	 : Byte;			// Define if the polarity can be different for each input
								// 0 : Polarity is common on each input
								// 1 : Polarity can be different for each input.
	b_Reserved1               : Byte;
	b_NbrOfGain		  : Byte;			// Returns the number of gain values available
	d_GainAvailable           : Array [0..254] Of Double;	// Defines the available gain value

	b_DelayTimeConfigurable	  : Byte;			// 0 : Delay after each sequence not available
								// 1 : Delay after each sequence available
	b_DelayAvailableMode	  : Byte;			// D0: 	0: Mode 1 not available
								//	1: Mode 1 available
								// D1: 	0: Mode 2 not available
								//	1: Mode 2 available
	b_DelayCalcType 	  : Byte;			// 0: Binary type (XX000,XX001,XX010,XX011)
								// 1: Multiple type (60,120,240,480,960, ...)
	b_DelayTimeUnitType	  : Byte;			// 0: Time unit (ns,µs,ms,s, ...)
								// 1: Frequency unit (MHz,kHz,Hz,mHz, ...)
	b_DelayTimeUnit		  : Byte;			// For time unit:
								// D0: 	0: ns not available
								//	1: ns available
								// D1:	0: µs not available
								//	1: µs available
								// D2:	0: ms not available
								//	1: ms available
								// D3:	0: s not available
								//	1: s available
								// For frequency unit:
								// D0: 	0: MHz not available
								//	1: MHz available
								// D1:	0: kHz not available
								//	1: kHz available
								// D2:	0: Hz not available
								//	1: Hz available
								// D3:	0: mHz not available
								//	1: mHz available
	b_Reserved2               : Array [0..2] Of Byte;
	w_DelayTimeResolution	  : Word;			// Delay time resolution
								// 8 : 8-bit resolution
								// 16: 16-bit resolution, ...
	w_MinDelayTime		  : Word;			// Minimum delay time.
								// 7000 : 7000(ns)
								// 10000: 10000(ns), ...
	w_DelayTimeStep		  : Word;			// Conversion delay time steps
								// 20: 20 steps
								// 50: 50 steps, ...
	w_AcquisitionMode	  : Word;			// XX1 : The acquisition can work in Single mode
								// X11 : The acquisition can work in continuous mode
								// 1XX : The acquisition can work in conting mode
	dw_MaxNumberOfAcquisition : Dword;			// Return the max number of acauisition for the single acquisition sequence mode
	b_Reserved4               : Array [0..3] of Byte;
end;

   str_AnalogInputSequenceInformation = packed record
	b_SequenceConfigurable	  : Byte;		// 0 : Sequence fixed. User muss pass the first and last channel
							// 1 : Sequence configurable
	b_SoftwareTrigger	  : Byte;		// 0 : Software trigger not available
							// 1 : Software trigger available
	b_HardwareTrigger	  : Byte;		// 0 : Hardware trigger not available
							// 1 : Hardware trigger available
	b_HardwareGate		  : Byte;		// 0 : Hardware gate not available
							// 1 : Hardware gate available

	b_CommonGain		  : Byte;		// Define if the gain can be different for each input
							// 0 : Gain is common on each input
							// 1 : Gain can be different for each input.
	b_CommonPolarity	  : Byte;		// Define if the polarity can be different for each input
							// 0 : Polarity is common on each input
							// 1 : Polarity can be different for each input.
	b_Reserved1               : Byte;
	b_NbrOfGain		  : Byte;		// Returns the number of gain values available
	d_GainAvailable 	  : Array [0..254] Of Double;	// Defines the available gain value

	b_DelayTimeConfigurable	  : Byte;		// 0 : Delay after each sequence not available
							// 1 : Delay after each sequence available
	b_DelayAvailableMode	  : Byte;		// D0: 	0: Mode 1 not available
							//	1: Mode 1 available
							// D1: 	0: Mode 2 not available
							//	1: Mode 2 available
	b_DelayCalcType 	  : Byte;		// 0: Binary type (XX000,XX001,XX010,XX011)
							// 1: Multiple type (60,120,240,480,960, ...)
	b_DelayTimeUnitType	  : Byte;		// 0: Time unit (ns,µs,ms,s, ...)
							// 1: Frequency unit (MHz,kHz,Hz,mHz, ...)
	b_DelayTimeUnit		  : Byte;		// For time unit:
							// D0: 	0: ns not available
							//	1: ns available
							// D1:	0: µs not available
							//	1: µs available
							// D2:	0: ms not available
							//	1: ms available
							// D3:	0: s not available
							//	1: s available
							// For frequency unit:
							// D0: 	0: MHz not available
							//	1: MHz available
							// D1:	0: kHz not available
							//	1: kHz available
							// D2:	0: Hz not available
							//	1: Hz available
							// D3:	0: mHz not available
							//	1: mHz available
	b_Reserved2               : Array [0..2] Of Byte;
	w_DelayTimeResolution	  : Word;		// Delay time resolution
							// 8 : 8-bit resolution
							// 16: 16-bit resolution, ...
	w_MinDelayTime		  : Word;		// Minimum delay time.
							// 7000 : 7000(ns)
							// 10000: 10000(ns), ...
	w_DelayTimeStep		  : Word;		// Conversion delay time steps
							// 20: 20 steps
							// 50: 50 steps, ...
	w_AcquisitionMode	  : Word;		// XX1 : The acquisition can work in Single mode
							// X11 : The acquisition can work in continuous mode
							// 1XX : The acquisition can work in conting mode

	dw_MaxNumberOfAcquisition : Dword;		// Return the max number of acquisition for the single acquisition sequence mode
	b_Reserved4               : Array [0..3] Of Byte;
end;

   str_InitAnalogInputSCANAcquisition = packed record
	w_FirstChannel       : Word;
	w_LastChannel        : Word;
	dw_ConversionTime    : DWord;
	b_ConversionTimeUnit : Byte;
	b_DelayTimeMode	     : Byte;			// ADDIDATA_DELAY_NOT_USED
							// ADDIDATA_DELAY_MODE1_USED
							// ADDIDATA_DELAY_MODE2_USED
	b_DelayTimeUnit      : Byte;
	b_Reserved1          : Array [0..4] Of Byte;
	dw_DelayTime         : DWord;
	dw_SCANCounter       : DWord;

	b_SCANMode	     : Byte;			// ADDIDATA_SINGLE_SCAN
							// ADDIDATA_DEFINED_SCAN_NUMBER
							// ADDIDATA_CONTINUOUS_SCAN
	b_Reserved2          : Array [0..6] Of Byte;
end;

   str_AnalogInputHardwareTriggerInformation = packed record
	b_LowLevelTrigger			  : Byte;	// 0 : Hardware low trigger level not available
								// 1 : Hardware low trigger level available
	b_HighLevelTrigger			  : Byte;	// 0 : Hardware high trigger level not available
								// 1 : Hardware high trigger level available
	b_HardwareTriggerCount			  : Byte;	// 0 : Hardware trigger counter not available
								// 1 : Hardware trigger counter available
	b_HardwareTriggerAutoRefreshAvailableMode : Byte;	// XXX1 : One shot trigger available
								// XX1X : Single autorefresh trigger available
								// X1XX : X autorefresh trigger available
	b_HardwareTriggerSCANAvailableMode	  : Byte;	// XXX1 : One shot trigger available
								// XX1X : Single scan trigger available
								// X1XX : X scan trigger available
	b_HardwareTriggerSequenceAvailableMode	  : Byte;	// XXX1 : One shot trigger available
								// XX1X : Single sequence trigger available
								// X1XX : X sequence trigger available
	b_Reserverd1                              : Array [0..1] Of Byte;
	dw_MaxTriggerCountValue                   : DWord;
	b_Reserverd2                              : Array [0..3] Of Byte;
end;

   str_AnalogInputSoftwareTriggerInformation = packed record
	b_SoftwareTriggerSCANAvailableMode	  : Byte;	// XXX1 : One shot trigger available
								// XX1X : Single scan trigger available
								// X1XX : X scan trigger available
	b_SoftwareTriggerAutoRefreshAvailableMode : Byte;	// XXX1 : One shot trigger available
								// XX1X : Single autorefresh trigger available
								// X1XX : X autorefresh trigger available
	b_SoftwareTriggerSequenceAvailableMode	  : Byte;	// XXX1 : One shot trigger available
								// XX1X : Single sequence trigger available
								// X1XX : X sequence trigger available
	b_Reserverd1                              : Array [0..4] Of Byte;
end;




   str_RequestInformation = packed record
	w_EntityVirtualIndex		: Word; // Virtual Index
	b_EntityType			: Byte; // ADDIDATA_LOCALISATION_CHANNEL or ADDIDATA_LOCALISATION_MODULE
	b_Reserved1			: Byte; // Not used
	w_Functionality			: Word; // from 0 to (ADDIDATA_NUMBER_OF_FUNCTIONALITY - 1)
	b_Reserved2			: Byte; // Not used
	b_Reserved3			: Byte; // Not used
end;

   str_LocalisationInformation = packed record
	w_ChannelRealIndex		: Word;			 // Real index of the channel 
	w_ModuleRealIndex		: word;			 // Real Index of the Modul
        c_BoardName			: Array [0..259] Of Byte;// Board name of the Device which contains this entity
        dw_BoardAddress			: Array [0..5] Of DWord; // Base address of the Device which contains this entity
        b_BoardInterrupt		: Byte;			 // Interrupt address of the Device which contains this entity
        b_DeviceNbr			: Byte;			 // Device Number (BIOS) of the Device which contains this entity
	b_Reserved			: Array [0..1] Of Byte;  // Not used
        c_PCISlotNumberInformation	: Array [0..259] Of Byte;// PCI Slot of the Device which contains this entity
        dw_DeviceSerialNumber		: Dword;		 // Serial number of the Device which contains this entity
        dw_Reserved			: Dword;		 // Not used
end;


CONST


   ADDIDATA_RING_3          =    0;
   ADDIDATA_RING_0          =    1;


   ADDIDATA_SINGLE_TEMPERATURE  = $10000;
   ADDIDATA_READ_MORE_TEMPERATURE  = $20000;
   ADDIDATA_SCAN_TEMPERATURE    = $200000;
   ADDIDATA_WARNING_TEMPERATURE = $80000;

   ADDIDATA_SINGLE_ANALOG_INPUT_IRQ  = $10000;
   ADDIDATA_READ_MORE_ANALOG_INPUT_IRQ = $20000;
   ADDIDATA_SCAN_ANALOG_INPUT_IRQ     = $200000;

   ADDIDATA_SINGLE_RESISTANCE     = $10000;
   ADDIDATA_READ_MORE_RESISTANCE  = $20000;
   ADDIDATA_SCAN_RESISTANCE       = $200000;

   ADDIDATA_ASYNCHRONOUS_MODE   =  0;
   ADDIDATA_SYNCHRONOUS_MODE    =  1;
   ADDIDATA_VB_MODE             =  2;
   ADDIDATA_LOCALISATION_CHANNEL = 0;
   ADDIDATA_LOCALISATION_MODULE  = 1;


   ADDIDATA_SHARED_MEMORY_NOT_USED     =  0;
   ADDIDATA_NEW_SHARED_MEMORY          =  1;
   ADDIDATA_ALREADY_USED_SHARED_MEMORY =  2;


   ADDIDATA_FUNCTIONALITY_NOT_AVAILABLE         =   -100;
   ADDIDATA_FUNCTIONALITY_NO_RING_0             =   -101;
   ADDIDATA_SYSTEM_ERROR                        =   -102;
   ADDIDATA_NO_FREE_DRIVER_HANDLE_FOUND         =   -103;
   ADDIDATA_DRIVER_SHARED_MEMORY_ERROR          =   -104;
   ADDIDATA_DRIVER_OPENING_ERROR                =   -105;
   ADDIDATA_CURRENT_PROCESS_HDL_NOT_AVAIBLE     =   -106;
   ADDIDATA_GET_SHARED_MEMORY_ERROR             =   -107;
   ADDIDATA_DRIVER_HANDLE_ERROR                 =   -108;
   ADDIDATA_DRIVER_NOT_OPEN                     =   -109;
   ADDIDATA_ONE_OR_MORE_BOARDS_NOT_FOUND        =   -110;
   ADDIDATA_DRIVER_ALREADY_OPEN                 =   -111;
   ADDIDATA_REGISTRY_PROBLEM                    =   -112;
   ADDIDATA_ADDIDATA_SHARED_PATH_NOT_AVAILABLE  =   -113;
   ADDIDATA_TEMPERATURE_CONVERT_FILE_ERROR      =   -114;
   ADDIDATA_TEMPERATURE_BUFFER_SHARED_MEMORY_ERROR = -115;
   ADDIDATA_COMPILER_DEFINED_ERROR                = -116;
   ADDIDATA_MULTIPROCESS_NOT_AVAILABLE_IN_THIS_VERSION = -117;
   ADDIDATA_READY_BIT_TIMEOUT_OCCUR             =   -118;
   ADDIDATA_ERROR_FILE_NOT_AVAILABLE	      =   -119;
   ADDIDATA_ERROR_STRING_TOO_SMALL	      =   -120;
   ADDIDATA_ERROR_STRING_NOT_FOUND	      =   -121;
   ADDIDATA_REGISTRY_NOT_UPDATED                =   -122;
   ADDIDATA_DRIVER_FREE_SHARED_MEMORY_ERROR     =   -123;
   ADDIDATA_DRIVER_RING_0_PREPARATION_ERROR     =   -124;
   ADDIDATA_DRIVER_MEMORY_MAP_ERROR                   = -125;
   ADDIDATA_REGISTRY_COULD_NOT_BE_TESTED              = -126;
   ADDIDATA_ADDEVICEMAPPER_ALREADY_STARTED            = -127;
   ADDIDATA_EXTERN_DRIVER_DLL_LOAD_ERROR              = -128;
   ADDIDATA_EXTERN_DRIVER_APCI_1500_DLL_NOT_FOUND     = -129;
   ADDIDATA_EXTERN_DRIVER_APCI_1500_DLL_VERSION_ERROR = -130;
   ADDIDATA_VIRTUAL_BOARD_FILE_NOT_FOUND              = -131;
   ADDIDATA_REALBOARD_XML_FILE_NOT_FOUND              = -132;
   ADDIDATA_REALBOARD_XML_FILE_BACKUP_ERROR           = -133;
   ADDIDATA_COPY_VIRTUAL_BOARD_FILE_ERROR             = -134;
   ADDIDATA_ADDEVICEMAPER_CALL_ERROR                  = -135;
   ADDIDATA_IEEE1394a_WRONG_HANDLE                    = -140;
   ADDIDATA_IEEE1394a_WRONG_ADRESS                    = -141;
   ADDIDATA_IEEE1394a_DEVICE_TEMPORARY_NOT_AVAILABLE  = -142;
   ADDIDATA_IEEE1394a_DEVICE_PERMANENTLY_NOT_AVAILABLE= -143;
   ADDIDATA_IEEE1394a_DEVICE_UNKNOWN_ERROR            = -144;
   ADDIDATA_ONE_OR_MORE_DEVICE_NOT_READY              = -145;



   ADDIDATA_INTERRUPT_USER_SHARED_MEMORY_SIZE_ERROR                   =     -150;
   ADDIDATA_INTERRUPT_SHARED_MEMORY_MODE_ERROR                        =     -151;
   ADDIDATA_INTERRUPT_USER_CALLING_MODE_ERROR                         =     -152;
   ADDIDATA_INTERRUPT_FUNCTIONALITY_ALREADY_INSTALLED                 =     -153;
   ADDIDATA_INTERRUPT_USER_SHARED_MEMORY_NOT_FOUND                    =     -154;
   ADDIDATA_INTERRUPT_USER_SHARED_MEMORY_ALLOCATION_ERROR             =     -155;
   ADDIDATA_INTERRUPT_USER_INSTALLATION_FUNCTION_ERROR                =     -156;
   ADDIDATA_INTERRUPT_PREPARE_FUNCTIONALITY_INTERRUPT_FUNCTION_ERROR  =     -157;
   ADDIDATA_INTERRUPT_PREPARE_API_INTERRUPT_FUNCTION_ERROR            =     -158;
   ADDIDATA_INTERRUPT_INSTALL_API_INTERRUPT_FUNCTION_ERROR            =     -159;
   ADDIDATA_INTERRUPT_NO_INDEX_AVAILABLE                              =     -160;
   ADDIDATA_INTERRUPT_INDEX_NUMBER_ERROR                              =     -161;
   ADDIDATA_INTERRUPT_FUNCTIONALITY_NUMBER_ERROR                      =     -162;
   ADDIDATA_INTERRUPT_FUNCTIONALITY_NOT_INSTALLED                     =     -163;
   ADDIDATA_INTERRUPT_END_FUNCTIONALITY_EXEC_ERROR                    =     -164;
   ADDIDATA_INTERRUPT_API_UNINSTALL_ERROR                             =     -165;
   ADDIDATA_INTERRUPT_END_API_EXEC_ERROR                              =     -166;
   ADDIDATA_INTERRUPT_FUNCTIONALITY_SELECTION_ERROR                   =     -167;
   ADDIDATA_INTERRUPT_API_THREAD_CREATION_ERROR                       =     -168;
   ADDIDATA_INTERRUPT_API_EVENT_CREATION_ERROR                        =     -169;
   ADDIDATA_INTERRUPT_NO_INTERRT_INITIALISED                          =     -170;
   ADDIDATA_INTERRUPT_FLAG_ERROR				      =	    -171;
   ADDIDATA_ACPI_ACTIV_AND_USE_OF_WINDOWS_NT4                         =     -172;
   ADDIDATA_PNP_OS_ACPI_AND_USE_OF_WINDOWS_NT4                        =     -173;


   ADDIDATA_TIMER_NUMBER_ERROR                               =    -200;
   ADDIDATA_TIMER_RELOAD_VALUE_ERROR                         =    -201;
   ADDIDATA_TIMER_UNIT_ERROR                                 =    -202;
   ADDIDATA_TIMER_MODE_ERROR                                 =    -203;
   ADDIDATA_TIMER_INTERRUPT_FLAG_ERROR                       =    -204;
   ADDIDATA_TIMER_HARDWARE_GATE_LEVEL_ERROR                  =    -205;
   ADDIDATA_TIMER_HARDWARE_GATE_LEVEL_SELECTION_ERROR        =    -206;
   ADDIDATA_TIMER_HARDWARE_GATE_FLAG_ERROR                   =    -207;
   ADDIDATA_TIMER_HARDWARE_TRIGGER_LEVEL_ERROR               =    -208;
   ADDIDATA_TIMER_HARDWARE_TRIGGER_LEVEL_SELECTION_ERROR     =    -209;
   ADDIDATA_TIMER_HARDWARE_TRIGGER_FLAG_ERROR                =    -210;
   ADDIDATA_TIMER_HARDWARE_OUTPUT_LEVEL_ERROR                =    -211;
   ADDIDATA_TIMER_HARDWARE_OUTPUT_LEVEL_SELECTION_ERROR      =    -212;
   ADDIDATA_TIMER_HARDWARE_OUTPUT_FLAG_ERROR                 =    -213;
   ADDIDATA_TIMER_ALREADY_USED                               =    -214;
   ADDIDATA_TIMER_INFORMATION_STRUCTURE_INVALID_SIZE         =    -215;

   ADDIDATA_COUNTER_NUMBER_ERROR                             = -800;
   ADDIDATA_COUNTER_RELOAD_VALUE_ERROR                       = -801;
   ADDIDATA_COUNTER_COUNTER_UP_DOWN_FLAG_ERROR		     = -802;
   ADDIDATA_COUNTER_INPUT_LEVEL_ERROR			     = -803;
   ADDIDATA_COUNTER_INTERRUPT_FLAG_ERROR                     = -804;
   ADDIDATA_COUNTER_HARDWARE_GATE_LEVEL_ERROR                = -805;
   ADDIDATA_COUNTER_HARDWARE_GATE_LEVEL_SELECTION_ERROR      = -806;
   ADDIDATA_COUNTER_HARDWARE_GATE_FLAG_ERROR                 = -807;
   ADDIDATA_COUNTER_HARDWARE_TRIGGER_LEVEL_ERROR             = -808;
   ADDIDATA_COUNTER_HARDWARE_TRIGGER_LEVEL_SELECTION_ERROR   = -809;
   ADDIDATA_COUNTER_HARDWARE_TRIGGER_FLAG_ERROR              = -810;
   ADDIDATA_COUNTER_HARDWARE_OUTPUT_LEVEL_ERROR              = -811;
   ADDIDATA_COUNTER_HARDWARE_OUTPUT_LEVEL_SELECTION_ERROR    = -812;
   ADDIDATA_COUNTER_HARDWARE_OUTPUT_FLAG_ERROR               = -813;
   ADDIDATA_COUNTER_ALREADY_USED                             = -814;
   ADDIDATA_COUNTER_INFORMATION_STRUCTURE_INVALID_SIZE       = -815;

   ADDIDATA_WATCHDOG_NUMBER_ERROR                            =    -300;
   ADDIDATA_WATCHDOG_DELAY_VALUE_ERROR                       =    -301;
   ADDIDATA_WATCHDOG_UNIT_ERROR                              =    -302;
   ADDIDATA_WATCHDOG_INTERRUPT_FLAG_ERROR                    =    -303;
   ADDIDATA_WATCHDOG_HARDWARE_GATE_LEVEL_ERROR               =    -304;
   ADDIDATA_WATCHDOG_HARDWARE_GATE_LEVEL_SELECTION_ERROR     =    -305;
   ADDIDATA_WATCHDOG_HARDWARE_GATE_FLAG_ERROR                =    -306;
   ADDIDATA_WATCHDOG_HARDWARE_TRIGGER_LEVEL_ERROR            =    -307;
   ADDIDATA_WATCHDOG_HARDWARE_TRIGGER_LEVEL_SELECTION_ERROR  =    -308;
   ADDIDATA_WATCHDOG_HARDWARE_TRIGGER_FLAG_ERROR             =    -309;
   ADDIDATA_WARNING_DELAY_VALUE_ERROR                        =    -310;
   ADDIDATA_WARNING_UNIT_ERROR                               =    -311;
   ADDIDATA_WATCHDOG_WARNING_RELAY_FLAG_ERROR                =    -312;
   ADDIDATA_WATCHDOG_RESET_RELAY_FLAG_ERROR                  =    -313;
   ADDIDATA_WATCHDOG_ALREADY_USED                            =    -314;
   ADDIDATA_WATCHDOG_INFORMATION_STRUCTURE_INVALID_SIZE      =    -315;
   ADDIDATA_WATCHDOG_RESET_RELAY_MODE_SELECTION_ERROR        =    -316;

   ADDIDATA_ANALOG_MEASURE_CHANNEL_NUMBER_ERROR            = -400;
   ADDIDATA_ANALOG_MEASURE_CONVERSION_STARTED              = -401;
   ADDIDATA_ANALOG_MEASURE_WARNING_FLAG_ERROR              = -402;
   ADDIDATA_ANALOG_MEASURE_CONVERTING_TIME_ERROR           = -403;
   ADDIDATA_ANALOG_MEASURE_CONVERTING_TIME_UNIT_ERROR      = -404;
   ADDIDATA_ANALOG_MEASURE_INTERRUPT_FLAG_ERROR            = -405;
   ADDIDATA_ANALOG_MEASURE_INTERRUPT_NOT_AVAILABLE         = -406;
   ADDIDATA_ANALOG_MEASURE_WARNING_VALUE_ERROR             = -407;
   ADDIDATA_ANALOG_MEASURE_CHANNEL_ALREADY_USED            = -408;
   ADDIDATA_ANALOG_MEASURE_WARNING_ALREADY_USED            = -409;
   ADDIDATA_ANALOG_MEASURE_GAIN_ERROR			   = -410;
   ADDIDATA_ANALOG_MEASURE_POLARITY_PARAMETER_ERROR	   = -411;
   ADDIDATA_ANALOG_MEASURE_OFFSET_RANGE_ERROR		   = -412;
   ADDIDATA_ANALOG_MEASURE_CHANNEL_NOT_INITIALISED	   = -413;
   ADDIDATA_ANALOG_MEASURE_POLARITY_MODE_NOT_AVAILABLE	   = -414;
   ADDIDATA_ANALOG_MEASURE_SCAN_MODE_NOT_AVAILABLE	   = -415;
   ADDIDATA_ANALOG_MEASURE_SCAN_MODE_PARAMETER_ERROR	   = -416;
   ADDIDATA_ANALOG_MEASURE_EXTERN_TRIGGER_MODE_NOT_AVAILABLE = -417;
   ADDIDATA_ANALOG_MEASURE_EXTERN_TRIGGER_NOT_AVAILABLE     = -418;
   ADDIDATA_ANALOG_MEASURE_EXTERN_TRIGGER_PARAMETER_ERROR   = -419;
   ADDIDATA_ANALOG_MEASURE_EXTERN_GATE_MODE_NOT_AVAILABLE   = -420;
   ADDIDATA_ANALOG_MEASURE_EXTERN_GATE_NOT_AVAILABLE        = -421;
   ADDIDATA_ANALOG_MEASURE_EXTERN_GATE_PARAMETER_ERROR      = -422;
   ADDIDATA_ANALOG_MEASURE_COMMON_GAIN_ERROR		    = -423;
   ADDIDATA_ANALOG_MEASURE_COMMON_POLARITY_ERROR	    = -424;
   ADDIDATA_ANALOG_MEASURE_COMMON_OFFSET_RANGE_ERROR	    = -425;
   ADDIDATA_ANALOG_MEASURE_SCAN_DELAY_NOT_AVAILABLE	    = -426;
   ADDIDATA_ANALOG_MEASURE_SCAN_DELAY_VALUE_ERROR	    = -427;
   ADDIDATA_ANALOG_MEASURE_INTERRUPT_NOT_INSTALLED	    = -428;
   ADDIDATA_ANALOG_MEASURE_SCAN_NOT_INITIALISED		    = -429;
   ADDIDATA_ANALOG_MEASURE_MODULE_NOT_AVAILABLE             = -430;
   ADDIDATA_ANALOG_MEASURE_SCAN_ALREADY_STARTED		    = -431;
   ADDIDATA_ANALOG_MEASURE_SCAN_COUNTER_VALUE_ERROR	    = -432;
   ADDIDATA_ANALOG_MEASURE_SCAN_NOT_STARTED		    = -433;
   ADDIDATA_ANALOG_MEASURE_SCAN_NOT_STOPPED		    = -434;
   ADDIDATA_ANALOG_MEASURE_SCAN_SAME_MODULE_REQUIRED	    = -435;
   ADDIDATA_ANALOG_MEASURE_SCAN_NOT_AVAILABLE		    = -436;
   ADDIDATA_ANALOG_MEASURE_SCAN_CHANNEL_SELECTION_ERROR	    = -437;
   ADDIDATA_ANALOG_MEASURE_SCAN_DELAY_MODE_NOT_AVAILABLE    = -438;
   ADDIDATA_ANALOG_MEASURE_COUPLING_MODE_NOT_AVAILABLE	    = -439;
   ADDIDATA_ANALOG_MEASURE_COMMON_COUPLING_ERROR	    = -440;
   ADDIDATA_ANALOG_MEASURE_COUPLING_PARAMETER_ERROR	    = -441;
   ADDIDATA_ANALOG_MEASURE_HARDWARE_INDEX_ERROR		    = -442;
   ADDIDATA_ANALOG_MEASURE_CONVERSION_ERROR                 = -443;
   ADDIDATA_ANALOG_MEASURE_INVALID_STRUCTURE                = -444;
   ADDIDATA_ANALOG_MEASURE_SIGN_TEST_PARAMETER_ERROR        = -445;

   (* BEGIN JK 15.12.03 : Append transducer *)
   ADDIDATA_ANALOG_MEASURE_EXTERN_TRIGGER_FLAG_ERROR        = -446;
   ADDIDATA_ANALOG_MEASURE_EXTERN_TRIGGER_COUNTER_ERROR     = -447;
   ADDIDATA_ANALOG_MEASURE_EXTERN_TRIGGER_ALREADY_USED      = -448;
   ADDIDATA_ANALOG_MEASURE_EXTERN_TRIGGER_NOT_INITIALISED   = -449;

   ADDIDATA_ANALOG_MEASURE_SOFTWARE_TRIGGER_NOT_AVAILABLE      = -450;
   ADDIDATA_ANALOG_MEASURE_SOFTWARE_TRIGGER_MODE_NOT_AVAILABLE = -451;
   ADDIDATA_ANALOG_MEASURE_SOFTWARE_TRIGGER_FLAG_ERROR         = -452;
   ADDIDATA_ANALOG_MEASURE_SOFTWARE_TRIGGER_ALREADY_USED       = -453;
   ADDIDATA_ANALOG_MEASURE_SOFTWARE_TRIGGER_NOT_INITIALISED    = -454;

   ADDIDATA_ANALOG_MEASURE_EXTERN_GATE_FLAG_ERROR              = -455;
   ADDIDATA_ANALOG_MEASURE_EXTERN_GATE_ALREADY_USED            = -456;
   ADDIDATA_ANALOG_MEASURE_EXTERN_GATE_NOT_INITIALISED         = -457;

   ADDIDATA_ANALOG_MEASURE_SEQUENCE_SAME_MODULE_REQUIRED          = -458;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_DELAY_NOT_AVAILABLE           = -459;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_DELAY_VALUE_ERROR             = -460;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_DELAY_TIME_UNIT_ERROR         = -461;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_ALREADY_STARTED               = -462;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_COUNTER_VALUE_ERROR           = -463;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_INTERRUPT_COUNTER_VALUE_ERROR = -464;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_NOT_STARTED                   = -465;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_NOT_STOPPED                   = -466;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_CHANNEL_SELECTION_ERROR       = -467;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_DELAY_MODE_NOT_AVAILABLE      = -468;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_NO_FREE_HANDLE_FOUND          = -469;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_MEMORY_ALLOCATION_ERROR       = -470;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_DESCRIPTION_LIST_CREATION_ERROR = -471;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_HANDLE_ERROR                    = -472;

   ADDIDATA_ANALOG_MEASURE_SEQUENCE_DELAY_MODE_SETTING_ERROR         = -473;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_DESCRIPTION_LIST_SETTING_ERROR   = -474;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_RESET_DESCRIPTION_LIST_ERROR     = -475;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_ENABLE_TRANSFER_ERROR            = -476;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_START_TRANSFER_ERROR             = -477;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_STOP_TRANSFER_ERROR              = -478;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_CONTINUE_TRANSFER_ERROR          = -479;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_PAUSE_TRANSFER_ERROR             = -480;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_ABORT_TRANSFER_ERROR             = -481;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_ENABLE_TRANSFER_INTERRUPT_ERROR  = -482;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_DISABLE_TRANSFER_INTERRUPT_ERROR = -483;

   ADDIDATA_ANALOG_MEASURE_SEQUENCE_MODULE_INITIALISATION_ERROR      = -484;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_MODULE_MODE_INITIALISATION_ERROR = -485;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_MODULE_MODE_CLEAR_INDEX_ERROR    = -486;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_MODULE_START_ERROR               = -487;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_MODULE_PAUSE_ERROR               = -488;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_MODULE_STOP_ERROR                = -489;

   ADDIDATA_TRANSDUCER_TYPE_SELECTION_ERROR                          = -490;
   ADDIDATA_TRANSDUCER_FREQUENCY_SELECTION_ERROR                     = -491;
   ADDIDATA_TRANSDUCER_PRIMARY_MODULE_CONNECTION_TEST_ALREADY_USED   = -492;
   ADDIDATA_TRANSDUCER_PRIMARY_MODULE_CONNECTION_FLAG_ERROR          = -493;
   ADDIDATA_TRANSDUCER_NO_SENSOR_CONNECTED                           = -494;

   ADDIDATA_ANALOG_MEASURE_AUTO_REFRESH_NOT_STARTED                     = -495;
   ADDIDATA_ANALOG_MEASURE_AUTO_REFRESH_NOT_STOPPED                     = -496;
   ADDIDATA_TRANSDUCER_PRIMARY_SHORT_CIRCUIT_OCCUR                      = -497;
   ADDIDATA_ANALOG_MEASURE_SEQUENCE_SAME_FREQUENCY_REQUIRED             = -498;
   ADDIDATA_ANALOG_MEASURE_EXTERN_TRIGGER_CYCLE_ERROR                   = -499;
   ADDIDATA_ANALOG_MEASURE_CONVERT_TIME_DIVISION_FACTOR_ALREADY_USED    = -900;
   ADDIDATA_ANALOG_MEASURE_CONVERT_TIME_DIVISION_FACTOR_VALUE_ERROR     = -901;
   ADDIDATA_ANALOG_MEASURE_CONVERT_TIME_DIVISION_FACTOR_NOT_INITIALISED = -902;

   (* END JK 15.12.03 : Append transducer*)

   ADDIDATA_DIGITAL_INPUT_CHANNEL_NUMBER_ERROR               =    -500;
   ADDIDATA_DIGITAL_INPUT_PORT_NUMBER_ERROR                  =    -501;
   ADDIDATA_DIGITAL_INPUT_ACCESS_ERROR                       =    -502;
   ADDIDATA_DIGITAL_INPUT_INTERRUPT_ALREADY_USED             =    -503;
   ADDIDATA_DIGITAL_INPUT_INTERRUPT_ALREADY_RELEASED         =    -504;
   ADDIDATA_DIGITAL_INPUT_INTERRUPT_FLAG_ERROR		     =    -505;
   ADDIDATA_DIGITAL_INPUT_INTERRUPT_LOGIC_ERROR		     =    -506;
   ADDIDATA_DIGITAL_INPUT_INFORMATION_STRUCTURE_INVALID_SIZE =    -507;
   ADDIDATA_DIGITAL_INPUT_LEVEL_VALUE_SELECTION_ERROR        =    -508;
   ADDIDATA_DIGITAL_INPUT_CHANNEL_ARRAY_SIZE_ERROR           =    -509;
   ADDIDATA_DIGITAL_INPUT_CHANNEL_SELECTION_ERROR	     =    -510;
   ADDIDATA_DIGITAL_INPUT_MODULE_SELECTION_ERROR             =    -511;
   ADDIDATA_DIGITAL_INPUT_FILTER_UNIT_ERROR		     =    -512;
   ADDIDATA_DIGITAL_INPUT_FILTER_DELAY_VALUE_ERROR	     =    -513;
   ADDIDATA_DIGITAL_INPUT_FILTER_NOT_INITIALISED             =    -514;
   ADDIDATA_DIGITAL_INPUT_FILTER_FLAG_ERROR                  =    -515;
   ADDIDATA_DIGITAL_INPUT_LEVEL_FLAG_ERROR		     =    -516;
   ADDIDATA_DIGITAL_INPUT_MASK_ERROR			     =    -517;


   ADDIDATA_DIGITAL_OUTPUT_CHANNEL_NUMBER_ERROR              =    -600;
   ADDIDATA_DIGITAL_OUTPUT_PORT_NUMBER_ERROR                 =    -601;
   ADDIDATA_DIGITAL_OUTPUT_VALUE_ERROR                       =    -602;
   ADDIDATA_DIGITAL_OUTPUT_ACCESS_ERROR                      =    -603;
   ADDIDATA_DIGITAL_OUTPUT_MEMORY_ALREADY_ENABLED            =    -604;
   ADDIDATA_DIGITAL_OUTPUT_MEMORY_ALREADY_DISABLED           =    -605;
   ADDIDATA_DIGITAL_OUTPUT_INTERRUPT_ALREADY_USED            =    -606;
   ADDIDATA_DIGITAL_OUTPUT_INTERRUPT_ALREADY_RELEASED        =    -607;
   ADDIDATA_DIGITAL_OUTPUT_INTERRUPT_FLAG_ERROR		     =    -608;



   ADDIDATA_ANALOG_OUTPUT_CHANNEL_NUMBER_ERROR               =    -700;
   ADDIDATA_ANALOG_OUTPUT_VOLTAGE_MODE_ERROR		     =    -701;
   ADDIDATA_ANALOG_OUTPUT_POLARITY_ERROR                     =    -702;
   ADDIDATA_ANALOG_OUTPUT_VALUE_ERROR                        =    -703;
   ADDIDATA_ANALOG_OUTPUT_ENABLE_DISABLE_SYNC_ERROR          =    -704;
   ADDIDATA_ANALOG_OUTPUT_ALREADY_USED                       =    -705;
   ADDIDATA_ANALOG_OUTPUT_TIMEOUT                            = -706;
   ADDIDATA_ANALOG_OUTPUT_TIMEOUT_ERROR                      = -707;
   ADDIDATA_ANALOG_OUTPUT_ALREADY_RELEASED                   = -708;

   ADDIDATA_ENTITY_COULD_NOT_BE_FOUND                      = -1000; //: The entity content in the request information could not be found.
   ADDIDATA_ENTITY_TYPE_IS_WRONG                           = -1001; //: The entity type is wrong.
   ADDIDATA_ENTITY_FUNCTIONALITY_IS_WRONG                  = -1002; //: The entity functionality is wrong.
   ADDIDATA_REQUEST_INFORMATION_STRUCT_SIZE_IS_WRONG       = -1003; //: The dw_RequestInformationStructSize is wrong.
   ADDIDATA_LOCALISATION_INFORMATION_STRUCT_SIZE_IS_WRONG  = -1004; //: The dw_LocalisationInformationStructSize is wrong.

   ADDIDATA_ADDITRAYICON_API_THREAD_CREATION_ERROR         = -1100;
   ADDIDATA_ADDITRAYICON_API_EVENT_CREATION_ERROR          = -1101;
   ADDIDATA_EVENT_FUNCTION_POINTER_IS_NULL                 = -1102;
   ADDIDATA_EVENT_ROUTINE_CAN_NOT_BE_USED_FROM_RING_0      = -1103;
   ADDIDATA_COULD_NOT_OPEN_ADDITRAY_DLL                    = -1104;

   ADDIDATA_RTD                          = 0;
   ADDIDATA_THERMOCOUPLE                 = 1;
   ADDIDATA_TEMPERATURE_ON_BOARD         = 2;
   ADDIDATA_OHM                          = 3;
   ADDIDATA_ANALOG_INPUT_V_OR_I          = 4;


   ADDIDATA_THERMOCOUPLE_TYPE_B   = 0;
   ADDIDATA_THERMOCOUPLE_TYPE_E   = 1;
   ADDIDATA_THERMOCOUPLE_TYPE_J   = 2;
   ADDIDATA_THERMOCOUPLE_TYPE_K   = 3;
   ADDIDATA_THERMOCOUPLE_TYPE_N   = 4;
   ADDIDATA_THERMOCOUPLE_TYPE_R   = 5;
   ADDIDATA_THERMOCOUPLE_TYPE_S   = 6;
   ADDIDATA_THERMOCOUPLE_TYPE_T   = 7;

   ADDIDATA_RTD_TYPE_PT		  = 0;
   ADDIDATA_RTD_TYPE_Ni		  = 1;

   ADDIDATA_ANALOG_INPUT_TYPE_V   = 0;
   ADDIDATA_ANALOG_INPUT_TYPE_I   = 1;

   ADDIDATA_SINGLE_SCAN		= 0;
   ADDIDATA_DEFINED_SCAN_NUMBER = 1;
   ADDIDATA_CONTINUOUS_SCAN     = 2;

   ADDIDATA_DELAY_NOT_USED	= 0;
   ADDIDATA_DELAY_MODE1_USED	= 1;
   ADDIDATA_DELAY_MODE2_USED    = 2;

   ADDIDATA_FIRST_LOW_EDGE_START_ALL_SCAN   = 1;
   ADDIDATA_FIRST_HIGH_EDGE_START_ALL_SCAN  = 2;
   ADDIDATA_FIRST_EDGE_START_ALL_SCAN	    = 3;
   ADDIDATA_EACH_LOW_EDGE_START_A_SCAN	    = 4;
   ADDIDATA_EACH_HIGH_EDGE_START_A_SCAN	    = 5;
   ADDIDATA_EACH_EDGE_START_A_SCAN	    = 6;
   ADDIDATA_EACH_LOW_EDGE_START_A_SINGLE_ACQUISITION	= 7;
   ADDIDATA_EACH_HIGH_EDGE_START_A_SINGLE_ACQUISITION	= 8;
   ADDIDATA_EACH_EDGE_START_A_SINGLE_ACQUISITION	= 9;

   ADDIDATA_DC_COUPLING = 0;
   ADDIDATA_AC_COUPLING = 1;

   ADDIDATA_GREATER_THAN_TEST = 0;
   ADDIDATA_LESS_THAN_TEST = 1;

   ADDIDATA_DISABLE       =       0;
   ADDIDATA_ENABLE        =       1;


   ADDIDATA_LOW           =       1;
   ADDIDATA_HIGH          =       2;
   ADDIDATA_LOW_HIGH      =       3;

   ADDIDATA_DOWN          = 0;
   ADDIDATA_UP            = 1;

   ADDIDATA_OR            = 1;
   ADDIDATA_AND           = 2;

   ADDIDATA_ASYNCHRONOUS  =       0;
   ADDIDATA_SYNCHRONOUS   =       1;
   ADDIDATA_VB            =       2;

(* BEGIN JK 15.12.03 : Append transducer *)

   ADDIDATA_TRIGGER_START_A_SINGLE_CONVERSION   = 0;
   ADDIDATA_ONE_SHOT_TRIGGER                    = 1;
   ADDIDATA_TRIGGER_START_A_SEQUENCE_SERIES     = 2;
   ADDIDATA_TRIGGER_START_A_SINGLE_SEQUENCE     = 3;
   ADDIDATA_TRIGGER_START_A_SCAN_SERIES	        = 6;
   ADDIDATA_TRIGGER_START_A_SINGLE_SCAN  	= 7;
   ADDIDATA_TRIGGER_START_A_AUTO_REFRESH_SERIES = 10;
   ADDIDATA_TRIGGER_START_A_SINGLE_AUTO_REFRESH = 11;

   ADDIDATA_GET_TRANSDUCER_MODULE_GENERAL_INFORMATION_STRUCT_SIZE_REV_1_0                      = (160 * 50) + 32;
   ADDIDATA_GET_TRANSDUCER_MODULE_SINGLE_ACQUISITION_INFORMATION_STRUCT_SIZE_REV_1_0           = 8;
   ADDIDATA_GET_TRANSDUCER_MODULE_AUTO_REFRESH_ACQUISITION_INFORMATION_STRUCT_SIZE_REV_1_0     = 8;
   ADDIDATA_GET_TRANSDUCER_MODULE_SEQUENCE_ACQUISITION_INFORMATION_STRUCT_SIZE_REV_1_0         = 32;
   ADDIDATA_INIT_SEQUENCE_ACQUISITION_STRUCT_SIZE_REV_1_0                                      = 24;
   ADDIDATA_GET_TRANSDUCER_MODULE_CONVERT_TIME_DIVISION_FACTOR_STRUCT_SIZE_REV_1_0             = 16;

(* Define interrupt enumeration for transducer *)

   ADDIDATA_SINGLE_TRANSDUCER     = $10000;
   ADDIDATA_READ_MORE_TRANSDUCER  = $20000;
   ADDIDATA_PRIMARY_SHORT_CIRCUIT = $800000;
   ADDIDATA_DMA                   = $100000;
   ADDIDATA_DMA_FIFO_OVERFLOW     = $400000;

(* END JK 15.12.03 : Append transducer *)

   ADDIDATA_OPEN_WIN32_DRIVER               = 10;
   ADDIDATA_CLOSE_WIN32_DRIVER              = 11;

   ADDIDATA_SET_FUNCTIONALITY_INT_ROUTINE   = 50;
   ADDIDATA_TEST_INTERRUPT                  = 51;
   ADDIDATA_RESET_FUNCTIONALITY_INT_ROUTINE = 52;


   ADDIDATA_GET_LAST_ERROR_MESSAGE          = 100;
   ADDIDATA_ENABLE_ERROR_MESSAGE            = 101;
   ADDIDATA_DISABLE_ERROR_MESSAGE           = 102;
   ADDIDATA_FORMAT_ERROR_MESSAGE            = 103;


   ADDIDATA_GET_NUMBER_OF_TIMERS            = 200;
   ADDIDATA_GET_TIMER_INFORMATION           = 201;
   ADDIDATA_INIT_TIMER                      = 202;
   ADDIDATA_ENABLE_DISABLE_TIMER_INTERRUPT  = 203;
   ADDIDATA_START_TIMER                     = 204;
   ADDIDATA_START_ALL_TIMERS                = 205;
   ADDIDATA_TRIGGER_TIMER                   = 206;
   ADDIDATA_TRIGGER_ALL_TIMERS              = 207;
   ADDIDATA_STOP_TIMER                      = 208;
   ADDIDATA_STOP_ALL_TIMERS                 = 209;
   ADDIDATA_READ_TIMER_VALUE                = 210;
   ADDIDATA_READ_TIMER_STATUS               = 211;
   ADDIDATA_ENABLE_DISABLE_TIMER_HARDWARE_GATE    = 212;
   ADDIDATA_GET_TIMER_HARDWARE_GATE_STATUS        = 213;
   ADDIDATA_ENABLE_DISABLE_TIMER_HARDWARE_TRIGGER = 214;
   ADDIDATA_GET_TIMER_HARDWARE_TRIGGER_STATUS     = 215;
   ADDIDATA_ENABLE_DISABLE_TIMER_HARDWARE_OUTPUT  = 216;
   ADDIDATA_GET_TIMER_HARDWARE_OUTPUT_STATUS      = 217;
   ADDIDATA_RELEASE_TIMER                         = 218;
   ADDIDATA_TEST_TIMER_ASYNCHRONOUS_FIFO_FULL     = 219;
   ADDIDATA_GET_TIMER_INFORMATION_EX              = 220;

   ADDIDATA_GET_NUMBER_OF_COUNTERS                  = 1000;
   ADDIDATA_GET_COUNTER_INFORMATION                 = 1001;
   ADDIDATA_INIT_COUNTER                            = 1002;
   ADDIDATA_COUNTER_DIRECTION                       = 1003;
   ADDIDATA_ENABLE_DISABLE_COUNTER_INTERRUPT        = 1004;
   ADDIDATA_START_COUNTER                           = 1005;
   ADDIDATA_START_ALL_COUNTERS                      = 1006;
   ADDIDATA_CLEAR_COUNTER                           = 1007;
   ADDIDATA_TRIGGER_COUNTER                         = 1008;
   ADDIDATA_TRIGGER_ALL_COUNTERS                    = 1009;
   ADDIDATA_STOP_COUNTER                            = 1010;
   ADDIDATA_STOP_ALL_COUNTERS                       = 1011;
   ADDIDATA_READ_COUNTER_VALUE                      = 1012;
   ADDIDATA_READ_COUNTER_STATUS                     = 1013;
   ADDIDATA_ENABLE_DISABLE_COUNTER_HARDWARE_GATE    = 1014;
   ADDIDATA_GET_COUNTER_HARDWARE_GATE_STATUS        = 1015;
   ADDIDATA_ENABLE_DISABLE_COUNTER_HARDWARE_TRIGGER = 1016;
   ADDIDATA_GET_COUNTER_HARDWARE_TRIGGER_STATUS     = 1017;
   ADDIDATA_ENABLE_DISABLE_COUNTER_HARDWARE_OUTPUT  = 1018;
   ADDIDATA_GET_COUNTER_HARDWARE_OUTPUT_STATUS      = 1019;
   ADDIDATA_RELEASE_COUNTER                         = 1020;
   ADDIDATA_TEST_COUNTER_ASYNCHRONOUS_FIFO_FULL     = 1021;
   ADDIDATA_GET_COUNTER_INFORMATION_EX              = 1022;

   ADDIDATA_GET_NUMBER_OF_WATCHDOGS               = 300;
   ADDIDATA_GET_WATCHDOG_INFORMATION              = 301;
   ADDIDATA_INIT_WATCHDOG                         = 302;
   ADDIDATA_ENABLE_DISABLE_WATCHDOG_INTERRUPT     = 303;
   ADDIDATA_START_WATCHDOG                        = 304;
   ADDIDATA_START_ALL_WATCHDOGS                   = 305;
   ADDIDATA_TRIGGER_WATCHDOG                      = 306;
   ADDIDATA_TRIGGER_ALL_WATCHDOGS                 = 307;
   ADDIDATA_STOP_WATCHDOG                         = 308;
   ADDIDATA_STOP_ALL_WATCHDOGS                    = 309;
   ADDIDATA_READ_WATCHDOG_STATUS                  = 310;
   ADDIDATA_ENABLE_DISABLE_WATCHDOG_HARDWARE_GATE = 311;
   ADDIDATA_GET_WATCHDOG_HARDWARE_GATE_STATUS     = 312;
   ADDIDATA_ENABLE_DISABLE_WATCHDOG_HARDWARE_TRIGGER = 313;
   ADDIDATA_GET_WATCHDOG_HARDWARE_TRIGGER_STATUS     = 314;
   ADDIDATA_GET_WARNING_DELAY_INFORMATION            = 315;
   ADDIDATA_INIT_WARNING_DELAY                       = 316;
   ADDIDATA_ENABLE_DISABLE_WATCHDOG_WARNING_RELAY    = 317;
   ADDIDATA_ENABLE_DISABLE_WATCHDOG_RESET_RELAY      = 318;
   ADDIDATA_RELEASE_WATCHDOG                         = 319;
   ADDIDATA_GET_WATCHDOG_INFORMATION_EX              = 320;
   ADDIDATA_SET_WATCHDOG_RESET_RELAY_MODE            = 321;
   ADDIDATA_TEST_WATCHDOG_ASYNCHRONOUS_FIFO_FULL     = 322;
   ADDIDATA_ENABLE_DISABLE_WATCHDOG_HARDWARE_OUTPUT  = 323;
   ADDIDATA_GET_WATCHDOG_HARDWARE_OUTPUT_STATUS      = 324;


   ADDIDATA_INIT_TEMPERATURE_CHANNEL                       = 400;
   ADDIDATA_READ_1_TEMPERATURE_CHANNEL                     = 401;
   ADDIDATA_GET_NUMBER_OF_TEMPERATURE_CHANNELS             = 402;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_TEMPERATURE_VALUE      = 403;
   ADDIDATA_GET_TEMPERATURE_CHANNEL_INFORMATION            = 404;
   ADDIDATA_INIT_TEMPERATURE_WARNING                       = 405;
   ADDIDATA_ENABLE_DISABLE_TEMPERATURE_WARNING_CHANNEL     = 406;
   ADDIDATA_START_ALL_TEMPERATURE_WARNINGS                 = 407;
   ADDIDATA_STOP_ALL_TEMPERATURE_WARNINGS                  = 408;
   ADDIDATA_RELEASE_TEMPERATURE_WARNING                    = 409;
   ADDIDATA_RELEASE_TEMPERATURE_CHANNEL                    = 410;
   ADDIDATA_READ_MORE_TEMPERATURE_CHANNELS                 = 411;
   ADDIDATA_INIT_TEMPERATURE_CHANNEL_SCAN                  = 412;
   ADDIDATA_START_TEMPERATURE_CHANNEL_SCAN                 = 413;
   ADDIDATA_GET_TEMPERATURE_CHANNEL_SCAN_STATUS            = 414;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_TEMPERATURE_VALUE_SCAN = 415;
   ADDIDATA_STOP_TEMPERATURE_CHANNEL_SCAN                  = 416;
   ADDIDATA_CLOSE_TEMPERATURE_CHANNEL_SCAN                 = 417;
   ADDIDATA_INIT_TEMPERATURE_CHANNEL_VIA_INIT_FILE         = 418;
   ADDIDATA_GET_NUMBER_OF_TEMPERATURE_MODULES              = 419;
   ADDIDATA_GET_NUMBER_OF_TEMPERATURE_CHANNELS_FOR_THE_MODULE = 420;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_TEMPERATURE_VALUE_WITH_CORRECTION_PARAMETERS = 421;
   ADDIDATA_CONVERT_MORE_DIGITAL_TO_REAL_TEMPERATURE_VALUES = 422;
   ADDIDATA_TEST_TEMPERATURE_CHANNEL_SHORT_CIRCUIT         = 423;
   ADDIDATA_TEST_TEMPERATURE_CHANNEL_CONNECTION            = 424;
   ADDIDATA_TEST_TEMPERATURE_ASYNCHRONOUS_FIFO_FULL        = 425;


   ADDIDATA_GET_NUMBER_OF_DIGITAL_INPUTS             = 500;
   ADDIDATA_GET_DIGITAL_INPUT_INFORMATION            = 501;
   ADDIDATA_READ_1_DIGITAL_INPUT                     = 502;
   ADDIDATA_READ_2_DIGITAL_INPUTS                    = 503;
   ADDIDATA_READ_4_DIGITAL_INPUTS                    = 504;
   ADDIDATA_READ_8_DIGITAL_INPUTS                    = 505;
   ADDIDATA_READ_16_DIGITAL_INPUTS                   = 506;
   ADDIDATA_READ_32_DIGITAL_INPUTS                   = 507;
   ADDIDATA_INIT_DIGITAL_INPUT_INTERRUPT             = 508;
   ADDIDATA_ENABLE_DISABLE_DIGITAL_INPUT_INTERRUPT   = 509;
   ADDIDATA_RELEASE_DIGITAL_INPUT_INTERRUPT          = 510;
   ADDIDATA_GET_DIGITAL_INPUT_INFORMATION_EX            = 511;
   ADDIDATA_INIT_1_DIGITAL_INPUT_LEVEL                  = 512;
   ADDIDATA_READ_1_DIGITAL_INPUT_STATUS                 = 513;
   ADDIDATA_READ_MORE_DIGITAL_INPUT_STATUS              = 514;
   ADDIDATA_READ_1_DIGITAL_INPUT_VALUE                  = 515;
   ADDIDATA_READ_MORE_DIGITAL_INPUT_VALUE               = 516;
   ADDIDATA_CONVERT_1_DIGITAL_INPUT_VALUE               = 517;
   ADDIDATA_GET_DIGITAL_INPUT_MODULE_FILTER_INFORMATION = 518;
   ADDIDATA_INIT_DIGITAL_INPUT_MODULE_FILTER            = 519;
   ADDIDATA_ENABLE_DISABLE_DIGITAL_INPUT_MODULE_FILTER  = 520;
   ADDIDATA_SET_DIGITAL_INPUT_MODULE_LEVEL_SELECTION    = 521;
   ADDIDATA_SAVE_DIGITAL_INPUT_MODULE_LEVEL             = 522;
   ADDIDATA_TEST_DIGITAL_INPUT_ASYNCHRONOUS_FIFO_FULL   = 523;


   ADDIDATA_GET_NUMBER_OF_DIGITAL_OUTPUTS            = 600;
   ADDIDATA_GET_DIGITAL_OUTPUT_INFORMATION           = 601;
   ADDIDATA_SET_DIGITAL_OUTPUT_MEMORY_ON             = 602;
   ADDIDATA_SET_DIGITAL_OUTPUT_MEMORY_OFF            = 603;
   ADDIDATA_SET_1_DIGITAL_OUTPUT_ON                  = 604;
   ADDIDATA_SET_2_DIGITAL_OUTPUTS_ON                 = 605;
   ADDIDATA_SET_4_DIGITAL_OUTPUTS_ON                 = 606;
   ADDIDATA_SET_8_DIGITAL_OUTPUTS_ON                 = 607;
   ADDIDATA_SET_16_DIGITAL_OUTPUTS_ON                = 608;
   ADDIDATA_SET_32_DIGITAL_OUTPUTS_ON                = 609;
   ADDIDATA_SET_1_DIGITAL_OUTPUT_OFF                 = 610;
   ADDIDATA_SET_2_DIGITAL_OUTPUTS_OFF                = 611;
   ADDIDATA_SET_4_DIGITAL_OUTPUTS_OFF                = 612;
   ADDIDATA_SET_8_DIGITAL_OUTPUTS_OFF                = 613;
   ADDIDATA_SET_16_DIGITAL_OUTPUTS_OFF               = 614;
   ADDIDATA_SET_32_DIGITAL_OUTPUTS_OFF               = 615;
   ADDIDATA_GET_1_DIGITAL_OUTPUT_STATUS              = 616;
   ADDIDATA_GET_2_DIGITAL_OUTPUT_STATUS              = 617;
   ADDIDATA_GET_4_DIGITAL_OUTPUT_STATUS              = 618;
   ADDIDATA_GET_8_DIGITAL_OUTPUT_STATUS              = 619;
   ADDIDATA_GET_16_DIGITAL_OUTPUT_STATUS             = 620;
   ADDIDATA_GET_32_DIGITAL_OUTPUT_STATUS             = 621;
   ADDIDATA_SET_ALL_DIGITAL_OUTPUT_OFF               = 622;
   ADDIDATA_INIT_DIGITAL_OUTPUT_INTERRUPT            = 623;
   ADDIDATA_ENABLE_DISABLE_DIGITAL_OUTPUT_INTERRUPT  = 624;
   ADDIDATA_RELEASE_DIGITAL_OUTPUT_INTERRUPT         = 625;
   ADDIDATA_TEST_DIGITAL_OUTPUT_ASYNCHRONOUS_FIFO_FULL = 626;
   ADDIDATA_SET_DIGITAL_OUTPUT_MEMORY_ON_EX          = 627;


   ADDIDATA_GET_NUMBER_OF_ANALOG_OUTPUTS             = 700;
   ADDIDATA_GET_ANALOG_OUTPUT_INFORMATION            = 701;
   ADDIDATA_INIT_1_ANALOG_OUTPUT                     = 702;
   ADDIDATA_INIT_MORE_ANALOG_OUTPUTS                 = 703;
   ADDIDATA_WRITE_1_ANALOG_OUTPUT                    = 704;
   ADDIDATA_WRITE_MORE_ANALOG_OUTPUTS                = 705;
   ADDIDATA_RELEASE_1_ANALOG_OUTPUT                  = 706;
   ADDIDATA_RELEASE_MORE_ANALOG_OUTPUTS              = 707;
   ADDIDATA_ENABLE_DISABLE_1_ANALOG_OUTPUT_SYNC      = 708;
   ADDIDATA_ENABLE_DISABLE_MORE_ANALOG_OUTPUTS_SYNC  = 709;
   ADDIDATA_TRIGGER_ANALOG_OUTPUT                    = 710;

   ADDIDATA_GET_NUMBER_OF_ANALOG_INPUTS             = 800;
   ADDIDATA_GET_NUMBER_OF_ANALOG_INPUT_MODULES      = 801;
   ADDIDATA_GET_NUMBER_OF_ANALOG_INPUTS_FOR_THE_MODULE = 802;
   ADDIDATA_GET_ANALOG_INPUT_INFORMATION            = 803;
   ADDIDATA_INIT_ANALOG_INPUT                       = 804;
   ADDIDATA_TEST_ANALOG_INPUT_SHORT_CIRCUIT         = 805;
   ADDIDATA_TEST_ANALOG_INPUT_CONNECTION            = 806;
   ADDIDATA_READ_1_ANALOG_INPUT                     = 807;
   ADDIDATA_READ_MORE_ANALOG_INPUTS                 = 808;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_ANALOG_VALUE    = 809;
   ADDIDATA_CONVERT_MORE_DIGITAL_TO_REAL_ANALOG_VALUES = 810;
   ADDIDATA_INIT_ANALOG_INPUT_SCAN                  = 811;
   ADDIDATA_START_ANALOG_INPUT_SCAN                 = 812;
   ADDIDATA_GET_ANALOG_INPUT_SCAN_STATUS            = 813;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_ANALOG_VALUE_SCAN = 814;
   ADDIDATA_STOP_ANALOG_INPUT_SCAN                  = 815;
   ADDIDATA_CLOSE_ANALOG_INPUT_SCAN                 = 816;
   ADDIDATA_RELEASE_ANALOG_INPUT                    = 817;
   ADDIDATA_TEST_ANALOG_INPUT_ASYNCHRONOUS_FIFO_FULL                     = 818;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_NUMBER                               = 819;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_AUTO_REFRESH_ACQUISITION_INFORMATION = 820;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_SEQUENCE_ACQUISITION_INFORMATION     = 821;
   ADDIDATA_GET_ANALOG_INPUT_AUTO_REFRESH_CHANNEL_POINTER                = 822;
   ADDIDATA_GET_ANALOG_INPUT_AUTO_REFRESH_MODULE_POINTER                 = 823;
   ADDIDATA_START_ANALOG_INPUT_AUTO_REFRESH                              = 824;
   ADDIDATA_STOP_ANALOG_INPUT_AUTO_REFRESH                               = 825;
   ADDIDATA_READ_1_ANALOG_INPUT_AUTO_REFRESH_VALUE                       = 826;
   ADDIDATA_INIT_ANALOG_INPUT_SEQUENCE_ACQUISITION                       = 827;
   ADDIDATA_START_ANALOG_INPUT_SEQUENCE_ACQUISITION                      = 828;
   ADDIDATA_PAUSE_ANALOG_INPUT_SEQUENCE_ACQUISITION                      = 829;
   ADDIDATA_STOP_ANALOG_INPUT_SEQUENCE_ACQUISITION                       = 830;
   ADDIDATA_RELEASE_ANALOG_INPUT_SEQUENCE_ACQUISITION                    = 831;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_ANALOG_VALUE_SEQUENCE                = 832;
   ADDIDATA_GET_ANALOG_INPUT_SEQUENCE_ACQUISITION_HANDLE_STATUS          = 833;
   ADDIDATA_GET_ANALOG_INPUT_HARDWARE_TRIGGER_INFORMATION                = 834;
   ADDIDATA_ENABLE_DISABLE_ANALOG_INPUT_HARDWARE_TRIGGER                 = 835;
   ADDIDATA_GET_ANALOG_INPUT_HARDWARE_TRIGGER_STATUS                     = 836;
   ADDIDATA_ENABLE_DISABLE_ANALOG_INPUT_SOFTWARE_TRIGGER                 = 837;
   ADDIDATA_ANALOG_INPUT_SOFTWARE_TRIGGER                                = 838;
   ADDIDATA_GET_ANALOG_INPUT_SOFTWARE_TRIGGER_STATUS                     = 839;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_GENERAL_INFORMATION                  = 840;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_SINGLE_ACQUISITION_INFORMATION       = 841;
   ADDIDATA_GET_ANALOG_INPUT_AUTO_REFRESH_MODULE_COUNTER_POINTER         = 842;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_SCAN_ACQUISITION_INFORMATION         = 843;
   ADDIDATA_INIT_ANALOG_INPUT_SCAN_ACQUISITION                           = 844;
   ADDIDATA_GET_ANALOG_INPUT_SOFTWARE_TRIGGER_INFORMATION                = 845;

   ADDIDATA_GET_NUMBER_OF_RESISTANCE_CHANNELS             = 900;
   ADDIDATA_GET_NUMBER_OF_RESISTANCE_MODULES              = 901;
   ADDIDATA_GET_NUMBER_OF_RESISTANCE_CHANNELS_FOR_THE_MODULE = 902;
   ADDIDATA_GET_RESISTANCE_CHANNEL_INFORMATION            = 903;
   ADDIDATA_INIT_RESISTANCE_CHANNEL                       = 904;
   ADDIDATA_TEST_RESISTANCE_CHANNEL_SHORT_CIRCUIT         = 905;
   ADDIDATA_TEST_RESISTANCE_CHANNEL_CONNECTION            = 906;
   ADDIDATA_READ_1_RESISTANCE_CHANNEL                     = 907;
   ADDIDATA_READ_MORE_RESISTANCE_CHANNELS                 = 908;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_RESISTANCE_VALUE      = 909;
   ADDIDATA_CONVERT_MORE_DIGITAL_TO_REAL_RESISTANCE_VALUES = 910;
   ADDIDATA_INIT_RESISTANCE_CHANNEL_SCAN                  = 911;
   ADDIDATA_START_RESISTANCE_CHANNEL_SCAN                 = 912;
   ADDIDATA_GET_RESISTANCE_CHANNEL_SCAN_STATUS            = 913;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_RESISTANCE_VALUE_SCAN = 914;
   ADDIDATA_STOP_RESISTANCE_CHANNEL_SCAN                  = 915;
   ADDIDATA_CLOSE_RESISTANCE_CHANNEL_SCAN                 = 916;
   ADDIDATA_RELEASE_RESISTANCE_CHANNEL                    = 917;
   ADDIDATA_TEST_RESISTANCE_ASYNCHRONOUS_FIFO_FULL        = 918;

   ADDIDATA_GET_NUMBER_OF_PRESSURE_CHANNELS                = 1100;
   ADDIDATA_GET_NUMBER_OF_PRESSURE_MODULES                 = 1101;
   ADDIDATA_GET_NUMBER_OF_PRESSURE_CHANNELS_FOR_THE_MODULE = 1102;
   ADDIDATA_GET_PRESSURE_CHANNEL_INFORMATION               = 1103;
   ADDIDATA_INIT_PRESSURE_CHANNEL                          = 1104;
   ADDIDATA_READ_1_PRESSURE_CHANNEL                        = 1105;
   ADDIDATA_READ_MORE_PRESSURE_CHANNELS                    = 1106;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_PRESSURE_VALUE         = 1107;
   ADDIDATA_CONVERT_MORE_DIGITAL_TO_REAL_PRESSURE_VALUES   = 1108;
   ADDIDATA_INIT_PRESSURE_SCAN                             = 1109;
   ADDIDATA_START_PRESSURE_SCAN                            = 1110;
   ADDIDATA_GET_PRESSURE_SCAN_STATUS                       = 1111;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_PRESSURE_SCAN          = 1112;
   ADDIDATA_STOP_PRESSURE_SCAN                             = 1113;
   ADDIDATA_CLOSE_PRESSURE_SCAN                            = 1114;
   ADDIDATA_RELEASE_PRESSURE_CHANNEL                       = 1115;
   ADDIDATA_TEST_PRESSURE_ASYNCHRONOUS_FIFO_FULL           = 1116;
   ADDIDATA_GET_PRESSURE_CHANNEL_REFERENCE_VOLTAGE         = 1117;
   ADDIDATA_GET_PRESSURE_CHANNEL_GAIN_FACTOR               = 1118;

   ADDIDATA_GET_NUMBER_OF_TRANSDUCERS_CHANNELS                                = 1200;
   ADDIDATA_GET_NUMBER_OF_TRANSDUCER_MODULES                                  = 1201;
   ADDIDATA_GET_NUMBER_OF_TRANSDUCER_CHANNELS_FOR_THE_MODULE                  = 1202;
   ADDIDATA_GET_TRANSDUCER_CHANNEL_MODULE_NUMBER                              = 1203;
   ADDIDATA_GET_TRANSDUCER_MODULE_GENERAL_INFORMATION                         = 1204;
   ADDIDATA_GET_TRANSDUCER_MODULE_SINGLE_ACQUISITION_INFORMATION              = 1205;
   ADDIDATA_GET_TRANSDUCER_MODULE_AUTO_REFRESH_ACQUISITION_INFORMATION        = 1206;
   ADDIDATA_GET_TRANSDUCER_MODULE_SEQUENCE_ACQUISITION_INFORMATION            = 1207;
   ADDIDATA_INIT_TRANSDUCER_CHANNEL                                           = 1208;
   ADDIDATA_RELEASE_TRANSDUCER_CHANNEL                                        = 1209;
   ADDIDATA_READ_1_TRANSDUCER_CHANNEL                                         = 1210;
   ADDIDATA_CONVERT_DIGITAL_TO_REAL_METRIC_VALUE                              = 1211;
   ADDIDATA_READ_MORE_TRANSDUCER_CHANNELS                                     = 1212;
   ADDIDATA_CONVERT_MORE_DIGITAL_TO_REAL_METRIC_VALUE                         = 1213;
   ADDIDATA_GET_TRANSDUCER_HARDWARE_TRIGGER_INFORMATION                       = 1214;
   ADDIDATA_ENABLE_DISABLE_TRANSDUCER_HARDWARE_TRIGGER                        = 1215;
   ADDIDATA_GET_TRANSDUCER_HARDWARE_TRIGGER_STATUS                            = 1216;
   ADDIDATA_ENABLE_DISABLE_TRANSDUCER_SOFTWARE_TRIGGER                        = 1217;
   ADDIDATA_TRANSDUCER_SOFTWARE_TRIGGER                                       = 1218;
   ADDIDATA_GET_TRANSDUCER_SOFTWARE_TRIGGER_STATUS                            = 1219;
   ADDIDATA_GET_TRANSDUCER_HARDWARE_GATE_INFORMATION                          = 1220;
   ADDIDATA_ENABLE_DISABLE_TRANSDUCER_HARDWARE_GATE                           = 1221;
   ADDIDATA_GET_TRANSDUCER_HARDWARE_GATE_STATUS                               = 1222;
   ADDIDATA_TEST_TRANSDUCER_CHANNEL_SECONDARY_CONNECTION                      = 1223;
   ADDIDATA_ENABLE_DISABLE_TRANSDUCER_MODULE_PRIMARY_CONNECTION_TEST          = 1224;
   ADDIDATA_TEST_TRANSDUCER_MODULE_PRIMARY_CONNECTION                         = 1225;
   ADDIDATA_ENABLE_DISABLE_TRANSDUCER_MODULE_PRIMARY_SHORT_CIRCUIT_INTERRUPT  = 1226;
   ADDIDATA_INIT_TRANSDUCER_SEQUENCE_ACQUISITION                              = 1227;
   ADDIDATA_START_TRANSDUCER_SEQUENCE_ACQUISITION                             = 1228;
   ADDIDATA_PAUSE_TRANSDUCER_SEQUENCE_ACQUISITION                             = 1229;
   ADDIDATA_STOP_TRANSDUCER_SEQUENCE_ACQUISITION                              = 1230;
   ADDIDATA_RELEASE_TRANSDUCER_SEQUENCE_ACQUISITION                           = 1231;
   ADDIDATA_CONVERT_TRANSDUCER_SEQUENCE_DIGITAL_TO_REAL_METRIC_VALUE          = 1232;
   ADDIDATA_GET_TRANSDUCER_SEQUENCE_ACQUISITION_HANDLE_STATUS                 = 1233;
   ADDIDATA_REARM_TRANSDUCER_MODULE_PRIMARY_SHORT_CIRCUIT_CONNECTION_TEST     = 1234;
   ADDIDATA_GET_TRANSDUCER_MODULE_CONVERT_TIME_DIVISION_FACTOR_INFORMATION    = 1235;
   ADDIDATA_INIT_TRANSDUCER_MODULE_CONVERT_TIME_DIVISION_FACTOR               = 1236;
   ADDIDATA_RELEASE_TRANSDUCER_MODULE_CONVERT_TIME_DIVISION_FACTOR            = 1237;
   ADDIDATA_GET_TRANSDUSER_AUTO_REFRESH_CHANNEL_POINTER                       = 1238;
   ADDIDATA_GET_TRANSDUSER_AUTO_REFRESH_MODULE_POINTER                        = 1239;
   ADDIDATA_GET_TRANSDUSER_AUTO_REFRESH_MODULE_COUNTER_POINTER                = 1240;
   ADDIDATA_START_TRANSDUSER_AUTO_REFRESH                                     = 1241;
   ADDIDATA_STOP_TRANSDUSER_AUTO_REFRESH                                      = 1242;
   ADDIDATA_SET_TRANSDUSER_AUTO_REFRESH_OVERAGE_VALUE                         = 1243;

   ADDIDATA_DIGITAL_INPUT                      =  0;
   ADDIDATA_DIGITAL_OUTPUT                     =  1;
   ADDIDATA_ANALOG_INPUT                       =  2;
   ADDIDATA_ANALOG_OUTPUT                      =  3;
   ADDIDATA_TIMER                              =  4;
   ADDIDATA_WATCHDOG                           =  5;
   ADDIDATA_TEMPERATURE                        =  6;
   ADDIDATA_COUNTER                            =  7;
   ADDIDATA_BI_DIRECTIONAL                     =  8;
   ADDIDATA_RESISTANCE			       =  9;
   (* BEGIN JK 15.12.03 : Append tranducer *)
   ADDIDATA_PRESSURE                           = 11;
   ADDIDATA_TRANSDUCER                         = 12;
   (* END JK 15.12.03 : Append tranducer *)
   ADDIDATA_NUMBER_OF_FUNNCTIONALITY           =  13;
   ADDIDATA_CUSTOMER_INFORMATION               = $3F;


   ADDIDATA_NONE    	                       =  0;
   ADDIDATA_UNIPOLAR                           =  1;
   ADDIDATA_BIPOLAR                            =  2;
   ADDIDATA_BOTH     	                       =  3;

   ADDIDATA_RANGE_0    	                       =  0;
   ADDIDATA_RANGE_1    	                       =  1;
   ADDIDATA_RANGE_2    	                       =  2;
   ADDIDATA_RANGE_3    	                       =  3;
   ADDIDATA_RANGE_4    	                       =  4;



   ADDIDATA_DIGITAL_OUTPUT_WATCHDOG            =  1;
   ADDIDATA_ANALOG_OUTPUT_WATCHDOG             =  2;
   ADDIDATA_ANA_DIG_OUTPUT_WATCHDOG            =  3;
   ADDIDATA_SYSTEM_WATCHDOG                    =  4;



   ADDIDATA_DLL_COMPILER_C                     =  0;
   ADDIDATA_DLL_COMPILER_PASCAL                =  1;
   ADDIDATA_DLL_COMPILER_VB                    =  2;
   ADDIDATA_DLL_LABVIEW                        =  3;
   ADDIDATA_DLL_COMPILER_VB_5                  =  4;
   ADDIDATA_DLL_COMPILER_VB_6 = ADDIDATA_DLL_COMPILER_VB_5;


   ADDIDATA_GET_ANALOG_INPUT_MODULE_GENERAL_INFORMATION_STRUCT_SIZE_REV_1_0			= 48;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_SINGLE_ACQUISITION_INFORMATION_STRUCT_SIZE_REV_1_0          = 2048;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_AUTO_REFRESH_ACQUISITION_INFORMATION_STRUCT_SIZE_REV_1_0	= 2056;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_SEQUENCE_ACQUISITION_INFORMATION_STRUCT_SIZE_REV_1_0	= 2072;
   ADDIDATA_GET_ANALOG_INPUT_MODULE_SCAN_ACQUISITION_INFORMATION_STRUCT_SIZE_REV_1_0		= 2072;
   ADDIDATA_GET_ANALOG_INPUT_HARDWARE_TRIGGER_INFORMATION_STRUCT_SIZE_REV_1_0		        = 16;
   ADDIDATA_GET_ANALOG_INPUT_SOFTWARE_TRIGGER_INFORMATION_STRUCT_SIZE_REV_1_0		        = 8;
   ADDIDATA_INIT_ANALOG_INPUT_MODULE_SCAN_ACQUISITION_STRUCT_SIZE_REV_1_0                       = 32;

IMPLEMENTATION

END.
