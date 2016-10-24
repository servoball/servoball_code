program Engine;          //Hauptprogramm

uses
  Forms,
  Setup in 'Setup.pas' {Form1},
  Unit1 in 'Unit1.pas',
  mapandvars in 'MapandVars.pas',
  lakutpu in 'LAKUTPU.PAS',
  {SerialNGBasic in 'SerialNGBasic.pas',}
  SerialNG in 'SerialNG.pas',
  ppModelGL in 'ppModelGL.pas',
  Geometry in 'Geometry.pas',
  GeometryEx in 'GeometryEx.pas',
  ppLoadMS3D in 'ppLoadms3d.pas',
  Textures in 'Textures.pas',
  global_variables in 'global_variables.pas',
  glBitmap in 'glBitmap.pas',
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  BasicFunctions in 'BasicFunctions.pas',
  Unit_Calibration in 'Unit_Calibration.pas' {FormCalibration},
  Unit4 in 'Unit4.pas' {Form4},
  TestUnit in 'TestUnit.pas',
  ADDI_DATA in 'ADDI_DATA.pas',
  Unit5 in 'Unit5.pas' {Form5};

//dglOpenGL in '..\..\..\..\Programme\Borland\Delphi6\Source\Vcl\dglOpenGL.pas';
  //dglopengl in 'dglopengl.pas'


begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TFormCalibration, FormCalibration);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
