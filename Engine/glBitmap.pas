(***********************************************************
glBitmap by Steffen Xonna (2003-2006)
http://www.dev-center.de/
------------------------------------------------------------
This unit implement some textureobjects wich have inspired by

glBMP.pas Copyright by Jason Allen
http://delphigl.cfxweb.net/

and

textures.pas Coypright by Jan Horn
http://www.sulaco.co.za/

It is compatible with an standard Delphi TBitmap.
------------------------------------------------------------
The contents of this file are used with permission, subject to
the Mozilla Public License Version 1.1 (the "License"); you may
not use this file except in compliance with the License. You may
obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html
------------------------------------------------------------
Version 1.4.5
------------------------------------------------------------
History
20-01-2006
- fixed bug with compressed TGAs
30-10-2005
- CRLF now correct
04-07-2005
- Function FillWithColor fills the Image with one Color
- Function LoadNormalMap added  
30-06-2005
- ToNormalMap allows to Create an NormalMap from the Alphachannel
- ToNormalMap now supports Sobel (nmSobel) function.
29-06-2005
- support for RLE Compressed RGB TGAs added
28-06-2005
- Class TglBitmapNormalMap added to support Normalmap generation
- Added function ToNormalMap in class TglBitmap2D to genereate normal maps from textures.
  3 Filters are supported. (4 Samples, 3x3 and 5x5)
16-06-2005
- Method LoadCubeMapClass removed
- LoadCubeMap returnvalue is now the Texture paramter. Such as LoadTextures
- virtual abstract method GenTexture in class TglBitmap now is protected
12-06-2005
- now support DescriptionFlag in LoadTga. Allows vertical flipped images to be loaded as normal
10-06-2005
- little enhancement for IsPowerOfTwo
- TglBitmap1D.GenTexture now tests NPOT Textures
06-06-2005
- some little name changes. All properties or function with Texture in name are
  now without texture in name. We have allways texture so we dosn't name it.
03-06-2005
- GenTexture now tests if texture is NPOT and NPOT-Texture are supported or
  TextureTarget is GL_TEXTURE_RECTANGLE. Else it raised an exception.
02-06-2005
- added support for GL_ARB_texture_rectangle, GL_EXT_texture_rectangle and GL_NV_texture_rectangle
25-04-2005
- Function Unbind added
- call of SetFilter or SetTextureWrap if TextureID exists results in setting properties to opengl texture.
21-04-2005
- class TglBitmapCubeMap added (allows to Create Cubemaps)
29-03-2005
- Added Support for PNG Images. (http://pngdelphi.sourceforge.net/)
  To Enable png's use the define pngimage
22-03-2005
- New Functioninterface added
- Function GetPixel added
27-11-2004
- Property BuildMipMaps renamed to MipMap
21-11-2004
- property Name removed.
- BuildMipMaps is now a set of 3 values. None, GluBuildMipmaps and SGIS_generate_mipmap
22-05-2004
- property name added. Only used in glForms!
26-11-2003
- property FreeDataAfterGenTexture is now available as default (default = true)
- BuildMipmaps now implemented in TglBitmap1D (i've forgotten it)
- function MoveMemory replaced with function Move (little speed change)
- several calculations stored in variables (little speed change)
29-09-2003
- property BuildMipsMaps added (default = True)
  if BuildMipMaps isn't set GenTextures uses glTexImage[12]D else it use gluBuild[12]dMipmaps
- property FreeDataAfterGenTexture added (default = True)
  if FreeDataAfterGenTexture is set the texturedata were deleted after the texture was generated.
- parameter DisableOtherTextureUnits of Bind removed
- parameter FreeDataAfterGeneration of GenTextures removed
12-09-2003
- TglBitmap dosn't delete data if class was destroyed (fixed)
09-09-2003
- Bind now enables TextureUnits (by params)
- GenTextures can leave data (by param)
- LoadTextures now optimal
03-09-2003
- Performance optimization in AddFunc
- procedure Bind moved to subclasses 
- Added new Class TglBitmap1D to support real OpenGL 1D Textures
19-08-2003
- Texturefilter and texturewrap now also as defaults
  Minfilter = GL_LINEAR_MIPMAP_LINEAR
  Magfilter = GL_LINEAR
  Wrap(str) = GL_CLAMP_TO_EDGE
- Added new format tfCompressed to create a compressed texture.
- propertys IsCompressed, TextureSize and IsResident added
  IsCompressed and TextureSize only contains data from level 0
18-08-2003
- Added function AddFunc to add PerPixelEffects to Image
- LoadFromFunc now based on AddFunc
- Invert now based on AddFunc
- SwapColors now based on AddFunc
16-08-2003
- Added function FlipHorz
15-08-2003
- Added function LaodFromFunc to create images with function
- Added function FlipVert
- Added internal format RGB(A) if GL_EXT_bgra or OpenGL 1.2 isn't supported
29-07-2003
- Added Alphafunctions to calculate alpha per function
- Added Alpha from ColorKey using alphafunctions
28-07-2003
- First full functionally Version of glBitmap
- Support for 24Bit and 32Bit TGA Pictures added 
25-07-2003
- begin of programming
***********************************************************)
unit glBitmap;

interface

{$X+,H+}

{ $define pngimage}

// PNG Support: to enable pngsupport you must add the define "pngimage" or uncomment above.
// And you must install a copy of pgnimage. You can download it from http://pngdelphi.sourceforge.net/

uses
  Windows, SyncObjs, dglOpenGL, Graphics, Classes, SysUtils, JPEG{$ifdef pngimage}, pngimage{$endif};

type
  TglBitmap = class;

  // Exception
  EglBitmapException = Exception;
  EglBitmapSizeToLargeException = EglBitmapException;
  EglBitmapNonPowerOfTwoException = EglBitmapException;

  // Einstellungen
  TglBitmapFormat = (tfDefault, tf16Bit, tf32Bit, tfCompressed);
  TglBitmapMipMap = (mmNone, mmMipmap, mmMipmapGlu);
  TglBitmapNormalMapFunc = (nm4Samples, nmSobel, nm3x3, nm5x5);

  // Functions
  TglBitmapPixelDataFields = set of (ffRed, ffGreen, ffBlue, ffAlpha);
  TglBitmapPixelData = record
    Fields : TglBitmapPixelDataFields;
    ptRed : pByte;
    ptGreen : pByte;
    ptBlue : pByte;
    ptAlpha : pByte;
  end;

  TglBitmapPixelPositionFields = set of (ffX, ffY, ffZ);
  TglBitmapPixelPosition = record
    Fields : TglBitmapPixelPositionFields;
    X : Word;
    Y : Word;
    Z : Word;
  end;

  TglBitmapFunction = procedure(
    Sender : TglBitmap;
    const Position, Size: TglBitmapPixelPosition;
    const Source, Dest: TglBitmapPixelData;
    const Data: Pointer);

  TglBitmapGetPixel = procedure (
    const Pos: TglBitmapPixelPosition;
    var Pixel: TglBitmapPixelData) of object;


  // Base Class
  TglBitmap = class
  protected
    FID: TGLuint;
    FTarget: Cardinal;
    FFormat: TglBitmapFormat;
    FMipMap: TglBitmapMipMap;

    FDeleteTextureOnFree: Boolean;
    FFreeDataAfterGenTexture: Boolean;

    // Propertys
    FDataPtr: PByte;
    FHasAlpha: Boolean;
    FIsCompressed: Boolean;
    FIsResident: Boolean;
    FSize: Integer;

    // Filtering
    FFilterMin: TGLint;
    FFilterMag: TGLint;

    // Texturwarp
    FWrapS: TGLint;
    FWrapT: TGLint;
    FWrapR: TGLint;

    FGetPixelFunc: TglBitmapGetPixel;

    function GetData: PByte;  
    procedure AllocData(Size: Integer);
    procedure SetDataPtr(Ptr: PByte); virtual;

    procedure SwapColors; virtual;

    {$ifdef pngimage}
    function LoadPng(const Stream: TStream): Boolean; virtual;
    {$endif}
    function LoadTga(const Stream: TStream): Boolean; virtual;
    function LoadJpg(const Stream: TStream): Boolean; virtual;
    function LoadBmp(const Stream: TStream): Boolean; virtual;

    procedure CreateID;
    procedure SetupParameters(var BuildWithGlu: Boolean);
    procedure SelectFormat(var Format, Components: Cardinal);

    procedure GenTexture(TestTextureSize: Boolean = True); virtual; abstract;

    function FlipHorz: Boolean; virtual;
    function FlipVert: Boolean; virtual;
    function FlipDepth: Boolean; virtual;
  public
    // propertys
    property ID: TGLuint read FID;

    property Target: Cardinal read FTarget
      write FTarget;

    property Format: TglBitmapFormat read FFormat
      write FFormat;

    property MipMap: TglBitmapMipMap read FMipMap write FMipMap;

    property DeleteTextureOnFree: Boolean read FDeleteTextureOnFree
      write FDeleteTextureOnFree;

    property FreeDataAfterGenTexture: Boolean read FFreeDataAfterGenTexture
      write FFreeDataAfterGenTexture;

    property HasAlpha: Boolean read FHasAlpha;
    property IsCompressed: Boolean read FIsCompressed;
    property IsResident: boolean read FIsResident;
    property Size: Integer read FSize;

    // Construction and Destructions Methods
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    constructor Create(); overload;
    constructor Create(FileName: String); overload;
    constructor CreateFromResourceName(Name: String); 
    constructor Create(Stream: TStream); overload;
    constructor Create(ResourceID: Integer); overload;

    // Loading Methods
    procedure LoadFromFile(FileName: String);
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure LoadFromResource(Resource: String);
    procedure LoadFromResourceID(ResourceID: Integer);

    function AddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer = nil): boolean; virtual; abstract;

    function AssignToBitmap(const Bitmap: TBitmap): boolean; virtual; abstract;
    function AssignAlphaToBitmap(const Bitmap: TBitmap): boolean; virtual; abstract;
    function AssignFromBitmap(const Bitmap: TBitmap): boolean; virtual; abstract;

    function AddAlphaFromFunc(Func: TglBitmapFunction; Data: Pointer = nil): boolean; virtual; abstract;
    function AddAlphaFromBitmap(Bitmap: TBitmap; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean; virtual; abstract;
    function AddAlphaFromFile(FileName: String; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;
    function AddAlphaFromStream(Stream: TStream; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;
    function AddAlphaFromResource(Resource: String; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;
    function AddAlphaFromResourceID(ResourceID: Integer; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;

    function AddAlphaFromColorKey(Red, Green, Blue: Byte; Deviation: Byte = 0): Boolean;

    function RemoveAlpha: Boolean; virtual; abstract;

    // Other
    procedure FillWithColor (Red, Green, Blue: Byte; Alpha : Byte = 255);
    procedure Invert(UseRGB: Boolean = true; UseAlpha: Boolean = false);
    procedure SetFilter(Min, Mag : TGLint);
    procedure SetWrap(S: TGLint = GL_CLAMP_TO_EDGE;
      T: TGLint = GL_CLAMP_TO_EDGE; R: TGLint = GL_CLAMP_TO_EDGE);

    procedure GetPixel (const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData); virtual;

    // Generation
    procedure Unbind(DisableTextureUnit: Boolean = True); virtual;
    procedure Bind(EnableTextureUnit: Boolean = True); virtual;
  end;


  TglBitmap2D = class(TglBitmap)
  protected
    // Bildeinstellungen
    FWidth: Integer;
    FHeight: Integer;
    FLines: array of PByte;

    procedure GetPixel2D (const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
    procedure GetPixel2DAlpha (const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);

    function IntAddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean; 
    function IntAddFuncAlpha(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean; 

    procedure SetDataPtr(Ptr: PByte); override;

    procedure UploadData (Target, Format, Components: Cardinal; BuildWithGlu: Boolean);
  public
    // propertys
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;

    procedure AfterConstruction; override;

    constructor Create(Width, Height: Integer; Func: TglBitmapFunction; HasAlpha: Boolean); overload;

    // Loading Methods
    procedure LoadFromFunc(Width, Height: Integer; Func: TglBitmapFunction; HasAlpha: Boolean; Data: Pointer = nil);

    function AddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer = nil): boolean; override;

    function AssignToBitmap(const Bitmap: TBitmap): boolean; override;
    function AssignAlphaToBitmap(const Bitmap: TBitmap): boolean; override;
    function AssignFromBitmap(const Bitmap: TBitmap): boolean; override;

    function AddAlphaFromFunc(Func: TglBitmapFunction; Data: Pointer = nil): boolean; override;
    function AddAlphaFromBitmap(Bitmap: TBitmap; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean; override;

    function RemoveAlpha: Boolean; override;

    // Other
    function FlipHorz: Boolean; override;
    function FlipVert: Boolean; override;

    procedure ToNormalMap(Func: TglBitmapNormalMapFunc = nm3x3; Scale: Single = 2; UseAlpha: Boolean = False); 

    // Generation
    procedure GenTexture(TestTextureSize: Boolean = True); override;
  end;


  TglBitmapCubeMap = class(TglBitmap2d)
  protected
    fGenMode: Integer;
    
    // Hide GenTexture
    procedure GenTexture(TestTextureSize: Boolean = True); reintroduce;
  public
    procedure AfterConstruction; override;

    procedure GenerateCubeMap(CubeTarget: Cardinal; TestTextureSize: Boolean = true);

    procedure Unbind(DisableTexCoordsGen: Boolean = true; DisableTextureUnit: Boolean = True); reintroduce; virtual;
    procedure Bind(EnableTexCoordsGen: Boolean = true; EnableTextureUnit: Boolean = True); reintroduce; virtual;
  end;


  TglBitmapNormalMap = class(TglBitmapCubeMap)
  public
    procedure AfterConstruction; override;

    procedure GenerateNormalMap(Size: Integer = 32; TestTextureSize: Boolean = true);
  end;
  

  TglBitmap1D = class(TglBitmap)
  protected
    // Bildeinstellungen
    FWidth: Integer;

    procedure GetPixel1D (const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
    procedure GetPixel1DAlpha (const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);

    function IntAddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean;
    function IntAddFuncAlpha(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean;

    procedure SetDataPtr(Ptr: PByte); override;

    procedure UploadTextureData (TextureTarget, Format, Components: Cardinal; BuildWithGlu: Boolean);
  public
    // propertys
    property Width: Integer read FWidth;

    procedure AfterConstruction; override;

    constructor Create(Width: Integer; Func: TglBitmapFunction; HasAlpha: Boolean); overload;

    // Loading Methods
    procedure LoadFromFunc(Width: Integer; Func: TglBitmapFunction; HasAlpha: Boolean; Data: Pointer = nil);

    function AddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer = nil): boolean; override;

    function AssignToBitmap(const Bitmap: TBitmap): boolean; override;
    function AssignAlphaToBitmap(const Bitmap: TBitmap): boolean; override;
    function AssignFromBitmap(const Bitmap: TBitmap): boolean; override;

    function AddAlphaFromFunc(Func: TglBitmapFunction; Data: Pointer = nil): boolean; override;
    function AddAlphaFromBitmap(Bitmap: TBitmap; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean; override;

    function RemoveAlpha: Boolean; override;

    // Other
    function FlipHorz: Boolean; override;

    // Generation
    procedure GenTexture(TestTextureSize: Boolean = True); override;
  end;


// methods and vars for Defaults
procedure glBitmapSetDefaultFormat(Format: TglBitmapFormat);
procedure glBitmapSetDefaultFilter(Min, Mag: TGLint);
procedure glBitmapSetDefaultWrap(S: TGLint = GL_CLAMP_TO_EDGE; T: TGLint = GL_CLAMP_TO_EDGE; R: TGLint = GL_CLAMP_TO_EDGE);

procedure glBitmapSetDefaultDeleteTextureOnFree(DeleteTextureOnFree: Boolean);
procedure glBitmapSetDefaultFreeDataAfterGenTexture(FreeData: Boolean);

function glBitmapGetDefaultFormat: TglBitmapFormat;
procedure glBitmapGetDefaultFilter(var Min, Mag: TGLint);
procedure glBitmapGetDefaultTextureWrap(var S, T, R: TGLint);

function glBitmapGetDefaultDeleteTextureOnFree: Boolean;
function glBitmapGetDefaultFreeDataAfterGenTexture: Boolean;


// Call LoadingMethods
function LoadTexture(Filename: String; var Texture: TGLuint; LoadFromRes : Boolean): Boolean;

function LoadCubeMap(PositiveX, NegativeX, PositiveY, NegativeY, PositiveZ, NegativeZ: String; var Texture: TGLuint; LoadFromRes : Boolean): Boolean;

function LoadNormalMap(Size: Integer; var Texture: TGLuint): Boolean;

var
  glBitmapDefaultFormat: TglBitmapFormat;
  glBitmapDefaultFilterMin: TGLint;
  glBitmapDefaultFilterMag: TGLint;
  glBitmapDefaultWrapS: TGLint;
  glBitmapDefaultWrapT: TGLint;
  glBitmapDefaultWrapR: TGLint;

  glBitmapDefaultDeleteTextureOnFree: Boolean;
  glBitmapDefaultFreeDataAfterGenTextures: Boolean;


implementation

uses
  Math;


function IsPowerOfTwo (Number: Integer): Boolean;
begin
  while Number and 1 = 0 do
    Number := Number shr 1;

  Result := Number = 1;
end;


procedure glBitmapDefaultAlphaFunc(Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition; const Source, Dest: TglBitmapPixelData; const Data: Pointer);
begin
  Dest.ptAlpha^ := (Source.ptRed^ + Source.ptGreen^ + Source.ptBlue^) div 3;
end;


// Helper functions
function LoadTexture(Filename: String; var Texture: TGLuint; LoadFromRes : Boolean): Boolean;
var
  glBitmap: TglBitmap2D;
begin
  Result := false;
  Texture := 0;

  if (LoadFromRes)
    then glBitmap := TglBitmap2D.CreateFromResourceName(FileName)
    else glBitmap := TglBitmap2D.Create(FileName);

  try
    glBitmap.DeleteTextureOnFree := False;
    glBitmap.FreeDataAfterGenTexture := False;
    glBitmap.GenTexture(True);
    if (glBitmap.ID > 0) then begin
      Texture := glBitmap.ID;
      Result := True;
    end;
  finally
    glBitmap.Free;
  end;
end;


function LoadCubeMap(PositiveX, NegativeX, PositiveY, NegativeY, PositiveZ, NegativeZ: String; var Texture: TGLuint; LoadFromRes : Boolean): Boolean;
var
  CM: TglBitmapCubeMap;
begin
  Texture := 0;

  CM := TglBitmapCubeMap.Create;
  try
    CM.DeleteTextureOnFree := False;

    // Maps
    if (LoadFromRes)
      then CM.LoadFromResource(PositiveX)
      else CM.LoadFromFile(PositiveX);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_X);

    if (LoadFromRes)
      then CM.LoadFromResource(NegativeX)
      else CM.LoadFromFile(NegativeX);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_X);

    if (LoadFromRes)
      then CM.LoadFromResource(PositiveY)
      else CM.LoadFromFile(PositiveY);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_Y);

    if (LoadFromRes)
      then CM.LoadFromResource(NegativeY)
      else CM.LoadFromFile(NegativeY);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y);

    if (LoadFromRes)
      then CM.LoadFromResource(PositiveZ)
      else CM.LoadFromFile(PositiveZ);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_Z);

    if (LoadFromRes)
      then CM.LoadFromResource(NegativeZ)
      else CM.LoadFromFile(NegativeZ);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z);

    Texture := CM.ID;
    Result := True;
  finally
    CM.Free;
  end;
end;


function LoadNormalMap(Size: Integer; var Texture: TGLuint): Boolean;
var
  NM: TglBitmapNormalMap;
begin
  Texture := 0;

  NM := TglBitmapNormalMap.Create;
  try
    NM.DeleteTextureOnFree := False;
    NM.GenerateNormalMap(Size);

    Texture := NM.ID;
    Result := True;
  finally
    NM.Free;
  end;
end;


// Defaults
procedure glBitmapSetDefaultFormat(Format: TglBitmapFormat);
begin
  glBitmapDefaultFormat := Format;
end;


procedure glBitmapSetDefaultDeleteTextureOnFree(DeleteTextureOnFree: Boolean);
begin
  glBitmapDefaultDeleteTextureOnFree := DeleteTextureOnFree;
end;


procedure glBitmapSetDefaultFilter(Min, Mag: TGLint);
begin
  case min of
    GL_NEAREST:
      glBitmapDefaultFilterMin := GL_NEAREST;
    GL_LINEAR:
      glBitmapDefaultFilterMin := GL_LINEAR;
    GL_NEAREST_MIPMAP_NEAREST:
      glBitmapDefaultFilterMin := GL_NEAREST_MIPMAP_NEAREST;
    GL_LINEAR_MIPMAP_NEAREST:
      glBitmapDefaultFilterMin := GL_LINEAR_MIPMAP_NEAREST;
    GL_NEAREST_MIPMAP_LINEAR:
      glBitmapDefaultFilterMin := GL_NEAREST_MIPMAP_LINEAR;
    GL_LINEAR_MIPMAP_LINEAR:
      glBitmapDefaultFilterMin := GL_LINEAR_MIPMAP_LINEAR;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultFilter - Unknow Minfilter.');
  end;

  case mag of
    GL_NEAREST:
      glBitmapDefaultFilterMag := GL_NEAREST;
    GL_LINEAR:
      glBitmapDefaultFilterMag := GL_LINEAR;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultFilter - Unknow Magfilter.');
  end;
end;


procedure glBitmapSetDefaultWrap(S: TGLint; T: TGLint; R: TGLint);
begin
  case S of
    GL_CLAMP:
      glBitmapDefaultWrapS := GL_CLAMP;
    GL_REPEAT:
      glBitmapDefaultWrapS := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      glBitmapDefaultWrapS := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      glBitmapDefaultWrapS := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultWrap - Unknow Texturewrap(s).');
  end;

  case T of
    GL_CLAMP:
      glBitmapDefaultWrapT := GL_CLAMP;
    GL_REPEAT:
      glBitmapDefaultWrapT := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      glBitmapDefaultWrapT := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      glBitmapDefaultWrapT := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultWrap - Unknow Texturewrap(t).');
  end;

  case R of
    GL_CLAMP:
      glBitmapDefaultWrapR := GL_CLAMP;
    GL_REPEAT:
      glBitmapDefaultWrapR := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      glBitmapDefaultWrapR := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      glBitmapDefaultWrapR := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultWrap - Unknow Texturewrap(r).');
  end;
end;


procedure glBitmapSetDefaultFreeDataAfterGenTexture(FreeData: Boolean);
begin
  glBitmapDefaultFreeDataAfterGenTextures := FreeData;
end;


function glBitmapGetDefaultFormat: TglBitmapFormat;
begin
  Result := glBitmapDefaultFormat;
end;


function glBitmapGetDefaultDeleteTextureOnFree: Boolean;
begin
  Result := glBitmapDefaultDeleteTextureOnFree;
end;


procedure glBitmapGetDefaultFilter(var Min, Mag: TGLint);
begin
  Min := glBitmapDefaultFilterMin;
  Mag := glBitmapDefaultFilterMag;
end;


procedure glBitmapGetDefaultTextureWrap(var S, T, R: TGLint);
begin
  S := glBitmapDefaultWrapS;
  T := glBitmapDefaultWrapT;
  R := glBitmapDefaultWrapR;
end;


function glBitmapGetDefaultFreeDataAfterGenTexture: Boolean;
begin
  Result := glBitmapDefaultFreeDataAfterGenTextures;
end;


{ TglBitmap }

procedure TglBitmap.AfterConstruction;
begin
  inherited;

  FID := 0;
  FTarget := 0;
  FMipMap := mmMipmap;
  FIsCompressed := False;
  FSize := 0;
  FIsResident := False;

  // get defaults
  FFreeDataAfterGenTexture := glBitmapGetDefaultFreeDataAfterGenTexture;
  FDeleteTextureOnFree := glBitmapGetDefaultDeleteTextureOnFree;

  FFormat := glBitmapGetDefaultFormat;

  glBitmapGetDefaultFilter(FFilterMin, FFilterMag);
  glBitmapGetDefaultTextureWrap(FWrapS, FWrapT, FWrapR);
end;


procedure TglBitmap.BeforeDestruction;
begin
  SetDataPtr(nil);
  
  if ((ID > 0) and (FDeleteTextureOnFree))
    then glDeleteTextures(1, @ID);

  inherited;
end;


constructor TglBitmap.Create;
begin
  Assert(ClassType <> TglBitmap, 'Don''t create TglBitmap');

  inherited Create;
end;


constructor TglBitmap.Create(FileName: String);
begin
  Create;
  LoadFromFile(FileName);
end;


constructor TglBitmap.CreateFromResourceName(Name: String);
begin
  Create;
  LoadFromResource(Name)
end;


constructor TglBitmap.Create(Stream: TStream);
begin
  Create;
  LoadFromStream(Stream);
end;


constructor TglBitmap.Create(ResourceID: Integer);
begin
  Create;
  LoadFromResourceID(ResourceID);
end;


procedure TglBitmap.LoadFromFile(FileName: String);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    FS.Position := 0;
    LoadFromStream(FS);
  finally
    FS.Free;
  end;
end;


procedure TglBitmap.LoadFromStream(Stream: TStream);
begin
  {$ifdef pngimage}
  if (not LoadPng(Stream))
    then
  {$endif}
  if (not LoadTga(Stream))
    then
  if (not LoadJpg(Stream))
    then
  if (not LoadBmp(Stream))
    then raise EglBitmapException.Create('TglBitmap.LoadFromStream - Couldn''t load Stream. It''s possible to be an unknow Streamtype.');
end;


procedure TglBitmap.LoadFromResource(Resource: String);
var
  RS: TResourceStream;
begin
  RS := TResourceStream.Create(HInstance, Resource, RT_BITMAP);
  if (not assigned(RS))
    then RS := TResourceStream.Create(HInstance, Resource, RT_RCDATA);

  if (not assigned(RS))
    then raise EglBitmapException.Create('TglBitmap.LoadFromResource - Resourcename were not found.');

  try
    LoadFromStream(RS);
  finally
    RS.Free;
  end;
end;


procedure TglBitmap.LoadFromResourceID(ResourceID: Integer);
var
  RS: TResourceStream;
begin
  RS := TResourceStream.CreateFromID(HInstance, ResourceID, RT_BITMAP);
  if (not assigned(RS))
    then RS := TResourceStream.CreateFromID(HInstance, ResourceID, RT_RCDATA);

  if (not assigned(RS))
    then raise EglBitmapException.Create('TglBitmap.LoadFromResourceID - ResourceID were not found.');

  try
    LoadFromStream(RS);
  finally
    RS.Free;
  end;
end;


function TglBitmap.AddAlphaFromFile(FileName: String;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    Result := AddAlphaFromStream(FS, Func, Data);
  finally
    FS.Free;
  end;
end;


function TglBitmap.AddAlphaFromStream(Stream: TStream;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  bmp: TBitmap;
  glBitmap: TglBitmap2D;
begin
  assert(Assigned(GetData()), 'TglBitmap.AddAlphaFromStream - AddAlpha can only called if data where loaded.');

  glBitmap := TglBitmap2D.Create(Stream);
  try
    bmp := TBitmap.Create;
    try
      glBitmap.AssignToBitmap(bmp);
      bmp.PixelFormat := pf24bit;
      Result := AddAlphaFromBitmap(bmp, Func, Data);
    finally
      bmp.Free;
    end;
  finally
    glBitmap.Free;
  end;
end;


function TglBitmap.AddAlphaFromResource(Resource: String;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  RS: TResourceStream;
begin
  RS := TResourceStream.Create(HInstance, Resource, RT_BITMAP);
  if (not assigned(RS))
    then RS := TResourceStream.Create(HInstance, Resource, RT_RCDATA);

  if (not assigned(RS))
    then raise EglBitmapException.Create('TglBitmap.AddAlphaFromResource - Resourcename were not found.');

  try
    Result := AddAlphaFromStream(RS, Func, Data);
  finally
    RS.Free;
  end;
end;


function TglBitmap.AddAlphaFromResourceID(ResourceID: Integer;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  RS: TResourceStream;
begin
  RS := TResourceStream.CreateFromID(HInstance, ResourceID, RT_BITMAP);
  if (not assigned(RS))
    then RS := TResourceStream.CreateFromID(HInstance, ResourceID, RT_RCDATA);

  if (not assigned(RS))
    then raise EglBitmapException.Create('TglBitmap.AddAlphaFromResource - Resourcename were not found.');

  try
    Result := AddAlphaFromStream(RS, Func, Data);
  finally
    RS.Free;
  end;
end;


procedure glBitmapColorKeyAlphaFunc(Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition; const Source, Dest: TglBitmapPixelData; const Data: Pointer);
begin
  with PRGBQuad(Data)^ do
    if ((Dest.ptRed^   <= rgbRed   + rgbReserved) and (Dest.ptRed^   >= rgbRed   - rgbReserved) and
        (Dest.ptGreen^ <= rgbGreen + rgbReserved) and (Dest.ptGreen^ >= rgbGreen - rgbReserved) and
        (Dest.ptBlue^  <= rgbRed   + rgbReserved) and (Dest.ptBlue^  >= rgbBlue  - rgbReserved))
      then Dest.ptAlpha^ := 0
      else Dest.ptAlpha^ := 255;
end;


function TglBitmap.AddAlphaFromColorKey(Red, Green, Blue, Deviation: Byte): Boolean;
var
  Data: TRGBQuad;
begin
  Data.rgbRed := Red;
  Data.rgbGreen := Green;
  Data.rgbBlue := Blue;
  Data.rgbReserved := Deviation;

  Result := AddAlphaFromFunc(glBitmapColorKeyAlphaFunc, @Data);
end;


procedure glBitmapInvertFunc(Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition; const Source, Dest: TglBitmapPixelData; const Data: Pointer);
begin
  if (Integer(Data) and $1 > 0) then begin
    Dest.ptRed^   := not Dest.ptRed^;
    Dest.ptGreen^ := not Dest.ptGreen^;
    Dest.ptBlue^  := not Dest.ptBlue^;
  end;

  if (Integer(Data) and $2 > 0) then begin
    Dest.ptAlpha^ := not Dest.ptAlpha^;
  end;
end;


procedure TglBitmap.Invert(UseRGB, UseAlpha: Boolean);
begin
  if ((UseRGB) or (UseAlpha))
    then AddFunc(glBitmapInvertFunc, False, Pointer(Integer(UseAlpha and HasAlpha) shl 1 or Integer(UseRGB)));
end;


procedure TglBitmap.SetFilter(Min, Mag: TGLint);
begin
  case Min of
    GL_NEAREST:
      FFilterMin := GL_NEAREST;
    GL_LINEAR:
      FFilterMin := GL_LINEAR;
    GL_NEAREST_MIPMAP_NEAREST:
      FFilterMin := GL_NEAREST_MIPMAP_NEAREST;
    GL_LINEAR_MIPMAP_NEAREST:
      FFilterMin := GL_LINEAR_MIPMAP_NEAREST;
    GL_NEAREST_MIPMAP_LINEAR:
      FFilterMin := GL_NEAREST_MIPMAP_LINEAR;
    GL_LINEAR_MIPMAP_LINEAR:
      FFilterMin := GL_LINEAR_MIPMAP_LINEAR;
  else
    raise EglBitmapException.Create('TglBitmap.SetFilter - Unknow Minfilter.');
  end;

  case Mag of
    GL_NEAREST:
      FFilterMag := GL_NEAREST;
    GL_LINEAR:
      FFilterMag := GL_LINEAR;
  else
    raise EglBitmapException.Create('TglBitmap.SetFilter - Unknow Magfilter.');
  end;

  // If texture is created then assign filter 
  if ID > 0 then begin
    Bind(False);
    
    glTexParameteri(Target, GL_TEXTURE_MAG_FILTER, FFilterMag);
    if (MipMap = mmNone) or (Target = GL_TEXTURE_RECTANGLE_ARB) then begin
      case FFilterMin of
        GL_NEAREST, GL_LINEAR:
          glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, FFilterMin);
        GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR:
          glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_LINEAR:
          glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      end;
    end else
      glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, FFilterMin);
  end;
end;


procedure TglBitmap.SetWrap(S: TGLint; T: TGLint; R: TGLint);
begin
  case S of
    GL_CLAMP:
      FWrapS := GL_CLAMP;
    GL_REPEAT:
      FWrapS := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      FWrapS := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      FWrapS := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('TglBitmap.SetWrap - Unknow Texturewrap(s).');
  end;

  case T of
    GL_CLAMP:
      FWrapT := GL_CLAMP;
    GL_REPEAT:
      FWrapT := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      FWrapT := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      FWrapT := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('TglBitmap.SetWrap - Unknow Texturewrap(t).');
  end;

  case R of
    GL_CLAMP:
      FWrapR := GL_CLAMP;
    GL_REPEAT:
      FWrapR := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      FWrapR := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      FWrapR := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('TglBitmap.SetWrap - Unknow Texturewrap(r).');
  end;

  if ID > 0 then begin
    Bind (False);
    glTexParameteri(Target, GL_TEXTURE_WRAP_S, FWrapS);
    glTexParameteri(Target, GL_TEXTURE_WRAP_T, FWrapT);
    glTexParameteri(Target, GL_TEXTURE_WRAP_R, FWrapR);
  end;
end;


function TglBitmap.GetData: PByte;
begin
  Result := FDataPtr;
end;


procedure TglBitmap.AllocData(Size: Integer);
begin
  SetDataPtr(AllocMem(Size));
end;


procedure TglBitmap.SetDataPtr(Ptr: PByte);
begin
  if FDataPtr <> Ptr then begin
    if (Assigned(FDataPtr))
      then FreeMem(FDataPtr);

    FDataPtr := Ptr;
  end;
end;


function TglBitmap.LoadBmp(const Stream: TStream): Boolean;
var
  bmp: TBitmap;
  StreamPos: Int64;
  Temp: array[0..1]of char;
begin
  Result := False;

  // reading first two bytes to test file and set cursor back to begin
  StreamPos := Stream.Position;
  Stream.Read(Temp[0], 2);
  Stream.Position := StreamPos;

  // if Bitmap then read file.
  if ((Temp[0] = 'B') and (Temp[1] = 'M')) then begin
    bmp := TBitmap.Create;
    try
      bmp.LoadFromStream(Stream);
      if bmp.PixelFormat in [pfDevice, pf1Bit, pf4Bit, pf8Bit, pf15Bit, pf16Bit, pfCustom]
        then bmp.PixelFormat := pf24bit;
      Result := AssignFromBitmap(bmp);
    finally
      bmp.Free;
    end;
  end;
end;


function TglBitmap.LoadJpg(const Stream: TStream): Boolean;
var
  bmp: TBitmap;
  jpg: TJPEGImage;
  StreamPos: Int64;
  Temp: array[0..1]of char;
begin
  Result := False;

  // reading first two bytes to test file and set cursor back to begin
  StreamPos := Stream.Position;
  Stream.Read(Temp[0], 2);
  Stream.Position := StreamPos;

  // if Bitmap then read file.
  if ((Temp[0] = chr($FF)) and (Temp[1] = chr($D8))) then begin
    bmp := TBitmap.Create;
    try
      jpg := TJPEGImage.Create;
      try
        jpg.LoadFromStream(Stream);
        bmp.Assign(jpg);
        Result := AssignFromBitmap(bmp);
      finally
        jpg.Free;
      end;
    finally
      bmp.Free;
    end;
  end;
end;


function TglBitmap.LoadTga(const Stream: TStream): Boolean;
type
  TTGAHeader = packed record
    aType: Byte;
    ColorMapType: Byte;
    ImageType: Byte;
    ColorMapSpec: Array[0..4] of Byte;
    OrigX: Word;
    OrigY: Word;
    Width: Word;
    Height: Word;
    Bpp: Byte;
    ImageDes: Byte;
  end;
  
var
  Header: TTGAHeader;
  bmp: TBitmap;
  pData: PByte;
  StreamPos: Int64;
  RowSize: Integer;
  YStart, YEnd, YInc: Integer;

  Temp: Byte;
  TempBuf: Array [0..3]of Byte;
  Idx, LinePixels, PixelSize, PixelsRead, PixelsToRead: Integer;

  procedure CheckLine;
  begin
    if LinePixels >= Header.Width then begin
      LinePixels := 0;
      Inc(YStart, YInc);
      pData := bmp.Scanline[YStart];
    end;
  end;

begin
  Result := False;

  // reading header to test file and set cursor back to begin
  StreamPos := Stream.Position;
  Stream.Read(Header, SizeOf(Header));
  Stream.Position := StreamPos;

  // uncompressed and compressed images
  if (Header.ImageType = 2) or (Header.ImageType = 10) then begin

    // no colormapped files
    if (Header.ColorMapType = 0) then begin
      if ((Header.Bpp = 32) or (Header.Bpp = 24)) then begin
        bmp := TBitmap.Create;
        try
          // Setting up Bitmap
          bmp.Width := Header.Width;
          bmp.Height := Header.Height;

          if (Header.Bpp = 24) then begin
            bmp.PixelFormat := pf24bit;
            FHasAlpha := False;
          end else begin
            bmp.PixelFormat := pf32bit;
            FHasAlpha := True;
          end;

          PixelSize := (Header.Bpp div 8);

          // Set Streampos to start of data
          Stream.Position := StreamPos + SizeOf(Header);

          // Row direction
          if (Header.ImageDes and $20 > 0) then begin
            YStart := 0;
            YEnd := Header.Height -1;
            YInc := 1;
          end else begin
            YStart := Header.Height -1;
            YEnd := 0;
            YInc := -1;
          end;

          // uncompressed Image
          if (Header.ImageType = 2) then begin
            RowSize := Header.Width * PixelSize;

            // copy line by line
            while YStart <> YEnd + YInc do begin
              pData := bmp.Scanline[YStart];

              Stream.Read(pData^, RowSize);

              Inc(YStart, YInc);
            end;
          end;

          // compressed
          if (Header.ImageType = 10) then begin
            PixelsToRead := Header.Width * Header.Height;
            PixelsRead := 0;
            LinePixels := 0;

            pData := bmp.Scanline[YStart];

            // Read until all Pixels
            repeat
              Stream.Read(Temp, 1);

              if Temp and $80 > 0 then begin
                Stream.Read(TempBuf, PixelSize);

                // repeat Pixel
                for Idx := 0 to Temp and $7F do begin
                  CheckLine;

                  Move(TempBuf, pData^, PixelSize);
                  Inc(pData, PixelSize);

                  Inc(PixelsRead);
                  Inc(LinePixels);
                end;
              end else begin
                // Pixelchunk (### Optimization?)
                for Idx := 0 to Temp and $7F do begin
                  CheckLine;

                  Stream.Read(pData^, PixelSize);
                  Inc(pData, PixelSize);

                  Inc(PixelsRead);
                  Inc(LinePixels);
                end;
              end;
            until PixelsRead >= PixelsToRead;
          end;

          // setting Bitmap
          Result := AssignFromBitmap(bmp);
        finally
          bmp.Free;
        end;
      end;
    end;
  end;
end;


{$ifdef pngimage}
function TglBitmap.LoadPng(const Stream: TStream): Boolean;
var
  StreamPos: Int64;
  Png: TPNGObject;
  Bmp: TBitmap;
  Header: Array[0..7] of Char;
  Row, Col, LineSize: Integer;
  pSource, pDest: pByte;

const
  PngHeader: Array[0..7] of Char = (#137, #80, #78, #71, #13, #10, #26, #10);

begin
  Result := False;

  StreamPos := Stream.Position;
  Stream.Read(Header[0], SizeOf(Header));
  Stream.Position := StreamPos;

  {Test if the header matches}
  if Header = PngHeader then begin
    Png := TPNGObject.Create;
    try
      Png.LoadFromStream(Stream);

      Bmp := TBitmap.Create;
      try
        Bmp.Width := Png.Width;
        Bmp.Height := Png.Height;
        case Png.Header.ColorType of
          COLOR_RGB:
            begin
              Bmp.PixelFormat := pf24bit;
              LineSize := Png.Width * 3;

              for Row := 0 to Png.Height -1 do
                Move (Png.Scanline[Row]^, Bmp.Scanline[Row]^, LineSize);
            end;
          COLOR_RGBALPHA:
            begin
              Bmp.PixelFormat := pf32bit;

              for Row := 0 to Png.Height -1 do begin
                pSource := Png.Scanline[Row];
                pDest := Bmp.Scanline[Row];

                for Col := 0 to Png.Width -1 do begin
                  Move (pSource^, pDest^, 3);
                  Inc(pSource, 3);
                  Inc(pDest, 3);

                  pDest^ := Png.AlphaScanline[Row][Col];
                  Inc(pDest);
                end;
              end;
            end;
          else
            Raise EglBitmapException.Create ('TglBitmap.LoadPng - Unsupported Colortype found.');
        end;

        Result := AssignFromBitmap (Bmp);
      finally
        Bmp.Free;
      end;
    finally
      Png.Free;
    end;
  end;
end;
{$endif}


procedure glBitmapSwapColors(Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition; const Source, Dest: TglBitmapPixelData; const Data: Pointer);
var
  Temp: Byte;
begin
  Temp := Dest.ptRed^;
  Dest.ptRed^  := Dest.ptBlue^;
  Dest.ptBlue^ := Temp;
end;


procedure TglBitmap.SwapColors;
begin
  AddFunc(glBitmapSwapColors, False);
end;


procedure TglBitmap.Bind(EnableTextureUnit: Boolean);
begin
  if EnableTextureUnit
    then glEnable(Target);

  if ID > 0
    then glBindTexture(Target, ID);
end;


procedure TglBitmap.Unbind(DisableTextureUnit: Boolean);
begin
  if DisableTextureUnit
    then glDisable(Target);

  glBindTexture(Target, 0);
end;


procedure TglBitmap.GetPixel(const Pos: TglBitmapPixelPosition;
  var Pixel: TglBitmapPixelData);
begin
  if Assigned (FGetPixelFunc)
    then FGetPixelFunc(Pos, Pixel);
end;


procedure TglBitmap.CreateID;
begin
  // Generate Texture
  if ID <> 0
    then glDeleteTextures(1, @ID);

  glGenTextures(1, @ID);

  Bind(False);
end;


procedure TglBitmap.SetupParameters(var BuildWithGlu: Boolean);
begin
  // Set up parameters
  SetWrap(FWrapS, FWrapT, FWrapR);
  SetFilter(FFilterMin, FFilterMag);

  // Mip Maps generation Mode
  BuildWithGlu := False;

  if (MipMap = mmMipmap) then begin
    if (GL_VERSION_1_4 or GL_SGIS_generate_mipmap)
      then glTexParameteri(Target, GL_GENERATE_MIPMAP, GL_TRUE)
      else BuildWithGlu := True;
  end else
  if (MipMap = mmMipmapGlu)
    then BuildWithGlu := True;
end;


procedure TglBitmap.SelectFormat(var Format, Components: Cardinal);
begin
  // selecting Format
  if ((not GL_VERSION_1_2) and (not GL_EXT_bgra))
    then SwapColors;

  if (HasAlpha) then begin
    if (GL_VERSION_1_2) then begin
      Format := GL_BGRA;
    end else begin
      if (not GL_EXT_bgra)
        then Format := GL_RGBA
        else Format := GL_BGRA_EXT;
    end;
  end else begin
    if (GL_VERSION_1_2) then begin
      Format := GL_BGR;
    end else begin
      if (not GL_EXT_bgra)
        then Format := GL_RGB
        else Format := GL_BGR_EXT;
    end;
  end;

  // Selecting Components
  if (HasAlpha) then begin
    case Self.Format of
      tf16Bit:
        Components := GL_RGBA4;
      tf32Bit:
        Components := GL_RGBA8;
      tfCompressed:
        begin
          if (GL_ARB_texture_compression or GL_VERSION_1_3) then begin
            Components := GL_COMPRESSED_RGBA
          end else begin
            if (GL_EXT_texture_compression_s3tc)
              then Components := GL_COMPRESSED_RGBA_S3TC_DXT1_EXT
              else Components := GL_RGBA;
          end;
        end;
    else
      Components := GL_RGBA;
    end;
  end else begin
    case Self.Format of
      tf16Bit:
        Components := GL_RGB4;
      tf32Bit:
        Components := GL_RGB8;
      tfCompressed:
        begin
          if (GL_ARB_texture_compression or GL_VERSION_1_3) then begin
            Components := GL_COMPRESSED_RGB
          end else begin
            if (GL_EXT_texture_compression_s3tc)
              then Components := GL_COMPRESSED_RGB_S3TC_DXT1_EXT
              else Components := GL_RGB;
          end;
        end;
    else
      Components := GL_RGB;
    end;
  end;
end;


function TglBitmap.FlipDepth: Boolean;
begin
  Result := False;
end;


function TglBitmap.FlipHorz: Boolean;
begin
  Result := False;
end;


function TglBitmap.FlipVert: Boolean;
begin
  Result := False;
end;


procedure glBitmapFillWithColorFunc(Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition; const Source, Dest: TglBitmapPixelData; const Data: Pointer);
begin
  Dest.ptRed^   := PRGBQuad(Data)^.rgbRed;
  Dest.ptGreen^ := PRGBQuad(Data)^.rgbGreen;
  Dest.ptBlue^  := PRGBQuad(Data)^.rgbBlue;

  if ffAlpha in Dest.Fields then
    Dest.ptAlpha^ := PRGBQuad(Data)^.rgbReserved;
end;


procedure TglBitmap.FillWithColor(Red, Green, Blue, Alpha: Byte);
var
  Quad: TRGBQuad;
begin
  Quad.rgbRed      := Red;
  Quad.rgbGreen    := Green;
  Quad.rgbBlue     := Blue;
  Quad.rgbReserved := Alpha;

  AddFunc(glBitmapFillWithColorFunc, False, @Quad);
end;


{ TglBitmap2D }

constructor TglBitmap2D.Create(Width, Height: Integer; Func: TglBitmapFunction;
  HasAlpha: Boolean);
begin
  inherited Create();

  LoadFromFunc(Width, Height, Func, HasAlpha);
end;


procedure TglBitmap2D.SetDataPtr(Ptr: PByte);
var
  Idx, LineWidth: Integer;
begin
  inherited;

  if HasAlpha
    then FGetPixelFunc := GetPixel2DAlpha
    else FGetPixelFunc := GetPixel2D;

  if Assigned(GetData()) then begin
    SetLength(FLines, FHeight);

    if HasAlpha
      then LineWidth := FWidth * 4
      else LineWidth := FWidth * 3;

    for Idx := 0 to FHeight -1
      do FLines [Idx] := PByte(Integer(GetData) + (Idx * LineWidth));
  end
    else SetLength(FLines, 0);
end;


procedure TglBitmap2D.LoadFromFunc(Width, Height: Integer;
  Func: TglBitmapFunction; HasAlpha: Boolean; Data: Pointer);
var
  Size: Integer;
begin
  if (HasAlpha)
    then Size := 4
    else Size := 3;

  FHasAlpha := HasAlpha;
  FWidth := Width;
  FHeight := Height;

  AllocData(Width * Height * Size);

  AddFunc(Func, False, Data);
end;


function TglBitmap2D.IntAddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean;
var
  Col, Row: Integer;
  Pos, Size: TglBitmapPixelPosition;
  Source, Dest: TglBitmapPixelData;
  pTempImage: PByte;
begin
  Result := False;

  pTempImage := nil;

  // empty records
  ZeroMemory (@Pos,    SizeOf (Pos));
  ZeroMemory (@Size,   SizeOf (Size));
  ZeroMemory (@Dest,   SizeOf (Dest));
  ZeroMemory (@Source, SizeOf (Source));

  // Prepare
  Size.X := Width;
  Size.Y := Height;
  Size.Fields := [ffX, ffY];

  Pos.Fields := [ffX, ffY];

  Source.Fields  := [ffRed, ffGreen, ffBlue];
  Source.ptRed   := GetData();
  Source.ptGreen := GetData();
  Source.ptBlue  := GetData();
  Inc(Source.ptRed,   2);
  Inc(Source.ptGreen, 1);

  if CreateTemp then begin
    pTempImage := AllocMem (Width * Height * 3);

    Dest.Fields  := Source.Fields;
    Dest.ptRed   := pTempImage;
    Dest.ptGreen := pTempImage;
    Dest.ptBlue  := pTempImage;
    Inc(Dest.ptRed,   2);
    Inc(Dest.ptGreen, 1);

    Move (Source.ptBlue^, pTempImage^, Width * Height * 3);
  end else begin
    Dest.Fields  := Source.Fields;
    Dest.ptRed   := Source.ptRed;
    Dest.ptGreen := Source.ptGreen;
    Dest.ptBlue  := Source.ptBlue;
  end;

  for Row := 0 to Height -1 do begin
    Pos.Y := Row;

    for Col := 0 to Width -1 do begin
      Pos.X := Col;
      Func (Self, Pos, Size, Source, Dest, Data);

      Inc(Source.ptRed,   3);
      Inc(Source.ptGreen, 3);
      Inc(Source.ptBlue,  3);

      Inc(Dest.ptRed,   3);
      Inc(Dest.ptGreen, 3);
      Inc(Dest.ptBlue,  3);
    end;
  end;

  if CreateTemp
    then SetDataPtr(pTempImage);
end;


function TglBitmap2D.IntAddFuncAlpha(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean;
var
  Col, Row: Integer;
  Pos, Size: TglBitmapPixelPosition;
  Source, Dest: TglBitmapPixelData;
  pTempImage: PByte;
begin
  Result := False;

  pTempImage := nil;

  // empty records
  ZeroMemory (@Pos,    SizeOf (Pos));
  ZeroMemory (@Size,   SizeOf (Size));
  ZeroMemory (@Dest,   SizeOf (Dest));
  ZeroMemory (@Source, SizeOf (Source));

  // Prepare
  Size.X := Width;
  Size.Y := Height;
  Size.Fields := [ffX, ffY];

  Pos.Fields := [ffX, ffY];

  Source.Fields  := [ffRed, ffGreen, ffBlue, ffAlpha];
  Source.ptRed   := GetData();
  Source.ptGreen := GetData();
  Source.ptBlue  := GetData();
  Source.ptAlpha := GetData();
  Inc(Source.ptAlpha, 3);
  Inc(Source.ptRed,   2);
  Inc(Source.ptGreen, 1);

  if CreateTemp then begin
    pTempImage := AllocMem (Width * Height * 4);

    Dest.Fields  := Source.Fields;
    Dest.ptRed   := pTempImage;
    Dest.ptGreen := pTempImage;
    Dest.ptBlue  := pTempImage;
    Dest.ptAlpha := pTempImage;
    Inc(Dest.ptAlpha, 3);
    Inc(Dest.ptRed,   2);
    Inc(Dest.ptGreen, 1);

    Move (Source.ptBlue^, pTempImage^, Width * Height * 4);
  end else begin
    Dest.Fields  := Source.Fields;
    Dest.ptRed   := Source.ptRed;
    Dest.ptGreen := Source.ptGreen;
    Dest.ptBlue  := Source.ptBlue;
    Dest.ptAlpha := Source.ptAlpha;
  end;

  for Row := 0 to Height -1 do begin
    Pos.Y := Row;

    for Col := 0 to Width -1 do begin
      Pos.X := Col;
      Func (Self, Pos, Size, Source, Dest, Data);

      Inc(Source.ptRed,   4);
      Inc(Source.ptGreen, 4);
      Inc(Source.ptBlue,  4);
      Inc(Source.ptAlpha, 4);

      Inc(Dest.ptRed,   4);
      Inc(Dest.ptGreen, 4);
      Inc(Dest.ptBlue,  4);
      Inc(Dest.ptAlpha, 4);
    end;
  end;

  if CreateTemp
    then SetDataPtr(pTempImage);
end;


function TglBitmap2D.AddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean;
begin
  assert (Assigned (GetData()));

  if HasAlpha
    then Result := IntAddFuncAlpha(Func, CreateTemp, Data)
    else Result := IntAddFunc(Func, CreateTemp, Data);
end;


function TglBitmap2D.AssignToBitmap(const Bitmap: TBitmap): boolean;
var
  Row, Size, RowSize: Integer;
  pSource, pData: PByte;
begin
  Result := False;

  if Assigned(GetData()) then begin
    if Assigned(Bitmap) then begin
      Bitmap.Width := Width;
      Bitmap.Height := Height;
      Bitmap.PixelFormat := pf24bit;

      // Copy Data
      pSource := GetData();

      if HasAlpha then begin
        Size := 4;
        Bitmap.PixelFormat := pf32bit;
      end else begin
        Size := 3;
        Bitmap.PixelFormat := pf24bit;
      end;

      RowSize := Width * Size;

      for Row := 0 to Height -1 do begin
        pData := Bitmap.Scanline[Row];
        if Assigned(pData) then begin
          Move(pSource^, pData^, RowSize);
          Inc(pSource, RowSize);
        end;
      end;

      Result := True;
    end;
  end;
end;


function TglBitmap2D.AssignAlphaToBitmap(const Bitmap: TBitmap): boolean;
var
  Row, Col: Integer;
  pSource, pDest: PByte;
begin
  Result := False;

  if Assigned(GetData()) then begin
    if (HasAlpha) then begin
      if Assigned(Bitmap) then begin
        Bitmap.Width := Width;
        Bitmap.Height := Height;
        Bitmap.PixelFormat := pf24bit;

        // Copy Data
        pSource := GetData();

        for Row := 0 to Height -1 do begin
          pDest := Bitmap.Scanline[Row];
          if Assigned(pDest) then begin
            for Col := 0 to Width -1 do begin
              Inc(pSource, 3);
              pDest^ := pSource^;
              Inc(pDest, 1);
              pDest^ := pSource^;
              Inc(pDest, 1);
              pDest^ := pSource^;
              Inc(pDest, 1);
              Inc(pSource, 1);
            end;
          end;
        end;

        Result := True;
      end;
    end;
  end;
end;


function TglBitmap2D.AssignFromBitmap(const Bitmap: TBitmap): boolean;
var
  pSource, pData: PByte;
  Row, Size, RowSize: Integer;
begin
  Result := False;

  if (Assigned(Bitmap)) then begin
    if ((Bitmap.PixelFormat <> pf24Bit) and (Bitmap.PixelFormat <> pf32Bit))
      then raise EglBitmapException.Create('TglBitmap2D.AssignFromBitmap - Only Bitmaps with 24 or 32 bit are Supported. Set the pixelformat.');

    // Copy Data
    if (Bitmap.PixelFormat = pf24Bit) then begin
      FHasAlpha := False;
      Size := 3;
    end else begin
      FHasAlpha := True;
      Size := 4;
    end;
    FWidth := Bitmap.Width;
    FHeight := Bitmap.Height;

    RowSize := FWidth * Size;

    AllocData(Height * RowSize);
    pData := GetData;

    for Row := 0 to Height -1 do begin
      pSource := Bitmap.Scanline[Row];

      if (Assigned(pSource)) then begin
        Move(pSource^, pData^, RowSize);
        Inc(pData, RowSize);
      end;
    end;
    Result := True;
  end;
end;


function TglBitmap2D.AddAlphaFromFunc(
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  Col, Row, TempSize, PixSize: Integer;
  pNewImage, pSource, pDest: pByte;
  Pos, Size: TglBitmapPixelPosition;
  Source, Dest: TglBitmapPixelData;
begin
  Result := false;

  if (Assigned(GetData())) then begin
    TempSize := Width * Height * 4;
    pNewImage := AllocMem(TempSize);
    pDest := pNewImage;

    // empty records
    ZeroMemory (@Pos,    SizeOf (Pos));
    ZeroMemory (@Size,   SizeOf (Size));
    ZeroMemory (@Dest,   SizeOf (Dest));
    ZeroMemory (@Source, SizeOf (Source));

    // Prepare
    Size.X := Width;
    Size.Y := Height;
    Size.Fields := [ffX, ffY];

    Pos.Fields := [ffX, ffY];

    Source.Fields := [ffRed, ffGreen, ffBlue];
    Source.ptRed   := GetData();
    Source.ptGreen := GetData();
    Source.ptBlue  := GetData();
    Inc(Source.ptRed,   2);
    Inc(Source.ptGreen, 1);

    pSource := GetData;
    if HasAlpha then begin
      Source.ptAlpha := GetData();
      Inc(Source.ptAlpha, 3);
      PixSize := 4;
    end else begin
      PixSize := 3;
    end;

    Dest.Fields := [ffRed, ffGreen, ffBlue, ffAlpha];
    Dest.ptRed   := pDest;
    Dest.ptGreen := pDest;
    Dest.ptBlue  := pDest;
    Dest.ptAlpha := pDest;
    Inc(Dest.ptAlpha, 3);
    Inc(Dest.ptRed,   2);
    Inc(Dest.ptGreen, 1);

    // Copy Pixels
    for Row := 0 to Height -1 do begin
      Pos.Y := Row;

      for Col := 0 to Width -1 do begin
        Pos.X := Col;

        MoveMemory(pDest, pSource, PixSize);
        Inc(pSource, PixSize);
        Inc(pDest,   4);

        Func (Self, Pos, Size, Source, Dest, Data);

        Inc(Source.ptRed,   PixSize);
        Inc(Source.ptGreen, PixSize);
        Inc(Source.ptBlue,  PixSize);
        if HasAlpha then
          Inc(Source.ptAlpha, PixSize);

        Inc(Dest.ptRed,   4);
        Inc(Dest.ptGreen, 4);
        Inc(Dest.ptBlue,  4);
        Inc(Dest.ptAlpha, 4);
      end;
    end;

    FHasAlpha := True;
    SetDataPtr(pNewImage);
    Result := True;
  end;
end;


function TglBitmap2D.AddAlphaFromBitmap(Bitmap: TBitmap;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  Col, Row, TempSize, PixSize: Integer;
  pNewImage, pSource, pDest: pByte;
  Pos, Size: TglBitmapPixelPosition;
  Source, Dest: TglBitmapPixelData;
begin
  Result := False;
  assert(Bitmap.PixelFormat = pf24Bit, 'TglBitmap2D.AddAlphaFromBitmap - Only 24Bit Bitmaps supported.');

  if ((Bitmap.Width = Width) and (Bitmap.Height = Height)) then begin
    if (Assigned(GetData())) then begin
      TempSize := Width * Height * 4;
      pNewImage := AllocMem(TempSize);
      try
        pDest := pNewImage;

        if not Assigned(Func)
          then Func := glBitmapDefaultAlphaFunc;

        // empty records
        ZeroMemory (@Pos,    SizeOf (Pos));
        ZeroMemory (@Size,   SizeOf (Size));
        ZeroMemory (@Dest,   SizeOf (Dest));
        ZeroMemory (@Source, SizeOf (Source));

        // Prepare
        Size.X := Width;
        Size.Y := Height;
        Size.Fields := [ffX, ffY];

        Pos.Fields := [ffX, ffY];

        Source.Fields := [ffRed, ffGreen, ffBlue];

        Dest.Fields := [ffRed, ffGreen, ffBlue, ffAlpha];
        Dest.ptRed   := pDest;
        Dest.ptGreen := pDest;
        Dest.ptBlue  := pDest;
        Dest.ptAlpha := pDest;
        Inc(Dest.ptAlpha, 3);
        Inc(Dest.ptRed,   2);
        Inc(Dest.ptGreen, 1);

        pSource := GetData;
        if (HasAlpha)
          then PixSize := 4
          else PixSize := 3;

        // Copy Pixels
        for Row := 0 to Height -1 do begin
          Pos.Y := Row;

          Source.ptRed   := Bitmap.ScanLine[Row];
          Source.ptGreen := Bitmap.ScanLine[Row];
          Source.ptBlue  := Bitmap.ScanLine[Row];
          Inc(Source.ptRed, 2);
          Inc(Source.ptGreen, 1);

          for Col := 0 to Width -1 do begin
            Pos.X := Col;

            MoveMemory(pDest, pSource, PixSize);
            Inc(pSource, PixSize);
            Inc(pDest,   4);

            Func (Self, Pos, Size, Source, Dest, Data);

            Inc(Dest.ptRed,   4);
            Inc(Dest.ptGreen, 4);
            Inc(Dest.ptBlue,  4);
            Inc(Dest.ptAlpha, 4);

            Inc(Source.ptRed,   3);
            Inc(Source.ptGreen, 3);
            Inc(Source.ptBlue,  3);
          end;
        end;

        // If we have Alpha we don't need to realloc
        if not FHasAlpha then begin
          TempSize := Width * Height * 4;
          AllocData(TempSize);
        end;

        // Copy image to Original
        pDest := GetData;
        MoveMemory(pDest, pNewImage, TempSize);

        FHasAlpha := True;
      finally
        FreeMem(pNewImage);
      end;
    end;
  end;
end;


function TglBitmap2D.RemoveAlpha: Boolean;
var
  pSource, pDest, pTempDest: PByte;
  Row, Col, Size: Integer;
begin
  Result := False;

  if (Assigned(Getdata())) then begin
    if (FHasAlpha) then begin
      Size := Width * Height * 3;
      pSource := GetData;
      pDest := AllocMem(Size);
      pTempDest := pDest;

      for Row := 0 to Height -1 do begin
        for Col := 0 to Width -1 do begin
          Move(pSource^, pTempDest^, 3);
          inc(pSource, 4);
          inc(pTempDest, 3);
        end;
      end;

      FHasAlpha := False;
      SetDataPtr(pDest);
    end;
  end;
end;


procedure TglBitmap2D.GetPixel2D(const Pos: TglBitmapPixelPosition;
  var Pixel: TglBitmapPixelData);
var
  BasePtr: Integer;
begin
  inherited;

  if (Pos.Y <= Height) and (Pos.X <= Width) then
    begin
      BasePtr := Integer(FLines[Pos.Y]) + Pos.X * 3;

      Pixel.Fields := [ffRed, ffGreen, ffBlue];
      Pixel.ptRed   := PByte(BasePtr + 2);
      Pixel.ptGreen := PByte(BasePtr + 1);
      Pixel.ptBlue  := PByte(BasePtr);
    end;
end;


procedure TglBitmap2D.GetPixel2DAlpha(const Pos: TglBitmapPixelPosition;
  var Pixel: TglBitmapPixelData);
var
  BasePtr: Integer;
begin
  inherited;

  if (Pos.Y <= Height) and (Pos.X <= Width) then
    begin
      BasePtr := Integer(FLines[Pos.Y]) + Pos.X * 4;

      Pixel.Fields := [ffRed, ffGreen, ffBlue, ffAlpha];
      Pixel.ptAlpha := PByte(BasePtr + 3);
      Pixel.ptRed   := PByte(BasePtr + 2);
      Pixel.ptGreen := PByte(BasePtr + 1);
      Pixel.ptBlue  := PByte(BasePtr);
    end;
end;


function TglBitmap2D.FlipHorz: Boolean;
var
  Col, Row: Integer;
  pTempDest, pDest, pSource: pByte;
  Size, RowSize, ImgSize: Integer;
begin
  Result := Inherited FlipHorz;

  if Assigned(GetData()) then begin
    pSource := GetData();
    if (HasAlpha)
      then Size := 4
      else Size := 3;

    RowSize := Width * Size;
    ImgSize := Height * RowSize;

    pDest := AllocMem(ImgSize);
    pTempDest := pDest;

    Dec(pTempDest, RowSize + Size);
    for Row := 0 to Height -1 do begin
      Inc(pTempDest, RowSize * 2);
      for Col := 0 to Width -1 do begin
        Move(pSource^, pTempDest^, Size);

        Inc(pSource, Size);
        Dec(pTempDest, Size);
      end;
    end;

    SetDataPtr(pDest);

    Result := True;
  end;
end;


function TglBitmap2D.FlipVert: Boolean;
var
  Row: Integer;
  pTempDest, pDest, pSource: pByte;
  Size, RowSize: Integer;
begin
  Result := Inherited FlipVert;

  if Assigned(GetData()) then begin
    pSource := GetData();
    if (HasAlpha)
      then Size := 4
      else Size := 3;

    RowSize := Width * Size;

    pDest := AllocMem(Height * RowSize);
    pTempDest := pDest;

    Inc(pTempDest, Width * (Height -1) * Size);

    for Row := 0 to Height -1 do begin
      Move(pSource^, pTempDest^, RowSize);

      Dec(pTempDest, RowSize);
      Inc(pSource, RowSize);
    end;

    SetDataPtr(pDest);

    Result := True;
  end;
end;


procedure TglBitmap2D.UploadData (Target, Format, Components: Cardinal; BuildWithGlu: Boolean);
begin
  // Upload data
  if BuildWithGlu
    then gluBuild2DMipmaps(Target, Components, Width, Height, Format, GL_UNSIGNED_BYTE, PByte(GetData()))
    else glTexImage2D(Target, 0, Components, Width, Height, 0, Format, GL_UNSIGNED_BYTE, PByte(GetData()));

  // Freigeben
  if (FreeDataAfterGenTexture)
    then SetDataPtr(nil);
end;


procedure TglBitmap2D.GenTexture(TestTextureSize: Boolean);
var
  BuildWithGlu, PotTex, TexRec: Boolean;
  Format, Components: Cardinal;
  TexSize: TGLint;
begin
  if Assigned(GetData()) then begin
    // Check Texture Size
    if (TestTextureSize) then begin
      glGetIntegerv(GL_MAX_TEXTURE_SIZE, @TexSize);

      if ((Height > TexSize) or (Width > TexSize))
        then raise EglBitmapSizeToLargeException.Create('TglBitmap2D.GenTexture - The size for the texture is to large. It''s may be not conform with the Hardware.');

      PotTex := IsPowerOfTwo (Height) and IsPowerOfTwo (Width);
      TexRec := (GL_ARB_texture_rectangle (*or GL_EXT_texture_rectangle*) or GL_NV_texture_rectangle) and
                (Target = GL_TEXTURE_RECTANGLE_ARB);

      if not (PotTex or GL_ARB_texture_non_power_of_two or TexRec)
        then raise EglBitmapNonPowerOfTwoException.Create('TglBitmap2D.GenTexture - Rendercontex dosn''t support non power of two texture.');
    end;

    CreateId;

    SetupParameters(BuildWithGlu);
    SelectFormat(Format, Components);

    UploadData(Target, Format, Components, BuildWithGlu);

    // Infos sammeln
    if (GL_ARB_texture_compression) then begin
      glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_COMPRESSED_ARB, @TexSize);
      FIsCompressed := TexSize <> 0;
      glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_COMPRESSED_IMAGE_SIZE_ARB, @Size);
    end else begin
      FIsCompressed := ((Self.Format = tfCompressed) and (GL_EXT_texture_compression_s3tc));
      FSize := 0;
    end;
    glAreTexturesResident(1, @ID, @FIsResident);
  end;
end;


procedure TglBitmap2D.AfterConstruction;
begin
  inherited;

  Target := GL_TEXTURE_2D;
  FGetPixelFunc := GetPixel2D;
end;

type
  TMaxtrixItem = record
    X, Y: Integer;
    W: Single;
  end;

  PglBitmapToNormalMapRec = ^TglBitmapToNormalMapRec;
  TglBitmapToNormalMapRec = Record
    Scale: Single;
    Heights: array of Single;
    MatrixU : array of TMaxtrixItem;
    MatrixV : array of TMaxtrixItem;
  end;

const
  oneover255 = 1 / 255;

procedure glBitmapToNormalMapPrepareFunc (Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition;
  const Source, Dest: TglBitmapPixelData; const Data: Pointer);
var
  Val: Single;
begin
  Val := Source.ptRed^ * 0.3 + Source.ptGreen^ * 0.59 + Source.ptBlue^ *  0.11;
  PglBitmapToNormalMapRec (Data)^.Heights[Position.Y * Size.X + Position.X] := Val * oneover255;
end;


procedure glBitmapToNormalMapPrepareAlphaFunc (Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition;
  const Source, Dest: TglBitmapPixelData; const Data: Pointer);
begin
  PglBitmapToNormalMapRec (Data)^.Heights[Position.Y * Size.X + Position.X] := Source.ptAlpha^ * oneover255;
end;


procedure glBitmapToNormalMapFunc (Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition;
  const Source, Dest: TglBitmapPixelData; const Data: Pointer);
type
  TVec = Array[0..2] of Single;
var
  Idx: Integer;
  du, dv: Double;
  Len: Single;
  Vec: TVec;

  function GetHeight(X, Y: Integer): Single;
  begin
    X := Max(0, Min(Size.X -1, X));
    Y := Max(0, Min(Size.Y -1, Y));

    Result := PglBitmapToNormalMapRec (Data)^.Heights[Y * Size.X + X];
  end;

begin
  with PglBitmapToNormalMapRec (Data)^ do begin
    du := 0;
    for Idx := Low(MatrixU) to High(MatrixU) do
      du := du + GetHeight(Position.X + MatrixU[Idx].X, Position.Y + MatrixU[Idx].Y) * MatrixU[Idx].W;

    dv := 0;
    for Idx := Low(MatrixU) to High(MatrixU) do
      dv := dv + GetHeight(Position.X + MatrixV[Idx].X, Position.Y + MatrixV[Idx].Y) * MatrixV[Idx].W;

    Vec[0] := -du * Scale;
    Vec[1] := -dv * Scale;
    Vec[2] := 1;
  end;

  // Normalize
  Len := 1 / Sqrt(Sqr(Vec[0]) + Sqr(Vec[1]) + Sqr(Vec[2]));
  if Len <> 0 then begin
    Vec[0] := Vec[0] * Len;
    Vec[1] := Vec[1] * Len;
    Vec[2] := Vec[2] * Len;
  end;

  // Farbe zuweisem
  Dest.ptRed^   := Trunc((Vec[0] + 1) * 127.5);
  Dest.ptGreen^ := Trunc((Vec[1] + 1) * 127.5);
  Dest.ptBlue^  := Trunc((Vec[2] + 1) * 127.5);
end;


procedure TglBitmap2D.ToNormalMap(Func: TglBitmapNormalMapFunc; Scale: Single; UseAlpha: Boolean);
var
  Rec: TglBitmapToNormalMapRec;

  procedure SetEntry (var Matrix: array of TMaxtrixItem; Index, X, Y: Integer; W: Single);
  begin
    if (Index >= Low(Matrix)) and (Index <= High(Matrix)) then begin
      Matrix[Index].X := X;
      Matrix[Index].Y := Y;
      Matrix[Index].W := W;
    end;
  end;

begin
  if Scale > 100
    then Rec.Scale := 100
    else
  if Scale < -100
    then Rec.Scale := -100
    else Rec.Scale := Scale;

  SetLength(Rec.Heights, Width * Height);
  try
    case Func of
      nm4Samples:
        begin
          SetLength(Rec.MatrixU, 2);
          SetEntry(Rec.MatrixU, 0, -1,  0, -0.5);
          SetEntry(Rec.MatrixU, 1,  1,  0,  0.5);

          SetLength(Rec.MatrixV, 2);
          SetEntry(Rec.MatrixV, 0,  0,  1,  0.5);
          SetEntry(Rec.MatrixV, 1,  0, -1, -0.5);
        end;
      nmSobel:
        begin
          SetLength(Rec.MatrixU, 6);
          SetEntry(Rec.MatrixU, 0, -1,  1, -1.0);
          SetEntry(Rec.MatrixU, 1, -1,  0, -2.0);
          SetEntry(Rec.MatrixU, 2, -1, -1, -1.0);
          SetEntry(Rec.MatrixU, 3,  1,  1,  1.0);
          SetEntry(Rec.MatrixU, 4,  1,  0,  2.0);
          SetEntry(Rec.MatrixU, 5,  1, -1,  1.0);

          SetLength(Rec.MatrixV, 6);
          SetEntry(Rec.MatrixV, 0, -1,  1,  1.0);
          SetEntry(Rec.MatrixV, 1,  0,  1,  2.0);
          SetEntry(Rec.MatrixV, 2,  1,  1,  1.0);
          SetEntry(Rec.MatrixV, 3, -1, -1, -1.0);
          SetEntry(Rec.MatrixV, 4,  0, -1, -2.0);
          SetEntry(Rec.MatrixV, 5,  1, -1, -1.0);
        end;
      nm3x3:
        begin
          SetLength(Rec.MatrixU, 6);
          SetEntry(Rec.MatrixU, 0, -1,  1, -1/6);
          SetEntry(Rec.MatrixU, 1, -1,  0, -1/6);
          SetEntry(Rec.MatrixU, 2, -1, -1, -1/6);
          SetEntry(Rec.MatrixU, 3,  1,  1,  1/6);
          SetEntry(Rec.MatrixU, 4,  1,  0,  1/6);
          SetEntry(Rec.MatrixU, 5,  1, -1,  1/6);

          SetLength(Rec.MatrixV, 6);
          SetEntry(Rec.MatrixV, 0, -1,  1,  1/6);
          SetEntry(Rec.MatrixV, 1,  0,  1,  1/6);
          SetEntry(Rec.MatrixV, 2,  1,  1,  1/6);
          SetEntry(Rec.MatrixV, 3, -1, -1, -1/6);
          SetEntry(Rec.MatrixV, 4,  0, -1, -1/6);
          SetEntry(Rec.MatrixV, 5,  1, -1, -1/6);
        end;
      nm5x5:
        begin
          SetLength(Rec.MatrixU, 20);
          SetEntry(Rec.MatrixU,  0, -2,  2, -1 / 16);
          SetEntry(Rec.MatrixU,  1, -1,  2, -1 / 10);
          SetEntry(Rec.MatrixU,  2,  1,  2,  1 / 10);
          SetEntry(Rec.MatrixU,  3,  2,  2,  1 / 16);
          SetEntry(Rec.MatrixU,  4, -2,  1, -1 / 10);
          SetEntry(Rec.MatrixU,  5, -1,  1, -1 /  8);
          SetEntry(Rec.MatrixU,  6,  1,  1,  1 /  8);
          SetEntry(Rec.MatrixU,  7,  2,  1,  1 / 10);
          SetEntry(Rec.MatrixU,  8, -2,  0, -1 / 2.8);
          SetEntry(Rec.MatrixU,  9, -1,  0, -0.5);
          SetEntry(Rec.MatrixU, 10,  1,  0,  0.5);
          SetEntry(Rec.MatrixU, 11,  2,  0,  1 / 2.8);
          SetEntry(Rec.MatrixU, 12, -2, -1, -1 / 10);
          SetEntry(Rec.MatrixU, 13, -1, -1, -1 /  8);
          SetEntry(Rec.MatrixU, 14,  1, -1,  1 /  8);
          SetEntry(Rec.MatrixU, 15,  2, -1,  1 / 10);
          SetEntry(Rec.MatrixU, 16, -2, -2, -1 / 16);
          SetEntry(Rec.MatrixU, 17, -1, -2, -1 / 10);
          SetEntry(Rec.MatrixU, 18,  1, -2,  1 / 10);
          SetEntry(Rec.MatrixU, 19,  2, -2,  1 / 16);

          SetLength(Rec.MatrixV, 20);
          SetEntry(Rec.MatrixV,  0, -2,  2,  1 / 16);
          SetEntry(Rec.MatrixV,  1, -1,  2,  1 / 10);
          SetEntry(Rec.MatrixV,  2,  0,  2,  0.25);
          SetEntry(Rec.MatrixV,  3,  1,  2,  1 / 10);
          SetEntry(Rec.MatrixV,  4,  2,  2,  1 / 16);
          SetEntry(Rec.MatrixV,  5, -2,  1,  1 / 10);
          SetEntry(Rec.MatrixV,  6, -1,  1,  1 /  8);
          SetEntry(Rec.MatrixV,  7,  0,  1,  0.5);
          SetEntry(Rec.MatrixV,  8,  1,  1,  1 /  8);
          SetEntry(Rec.MatrixV,  9,  2,  1,  1 / 16);
          SetEntry(Rec.MatrixV, 10, -2, -1, -1 / 16);
          SetEntry(Rec.MatrixV, 11, -1, -1, -1 /  8);
          SetEntry(Rec.MatrixV, 12,  0, -1, -0.5);
          SetEntry(Rec.MatrixV, 13,  1, -1, -1 /  8);
          SetEntry(Rec.MatrixV, 14,  2, -1, -1 / 10);
          SetEntry(Rec.MatrixV, 15, -2, -2, -1 / 16);
          SetEntry(Rec.MatrixV, 16, -1, -2, -1 / 10);
          SetEntry(Rec.MatrixV, 17,  0, -2, -0.25);
          SetEntry(Rec.MatrixV, 18,  1, -2, -1 / 10);
          SetEntry(Rec.MatrixV, 19,  2, -2, -1 / 16);
        end;
    end;

    // Daten Sammeln
    if UseAlpha and FHasAlpha then
      AddFunc(glBitmapToNormalMapPrepareAlphaFunc, False, @Rec)
    else
      AddFunc(glBitmapToNormalMapPrepareFunc, False, @Rec);

    // Neues Bild berechnen
    AddFunc(glBitmapToNormalMapFunc, False, @Rec);
  finally
    SetLength(Rec.Heights, 0);
  end;
end;


{ TglBitmap1D }

constructor TglBitmap1D.Create(Width: Integer; Func: TglBitmapFunction;
  HasAlpha: Boolean);
begin
  inherited Create();

  LoadFromFunc(Width, Func, HasAlpha);
end;


procedure TglBitmap1D.SetDataPtr(Ptr: PByte);
begin
  inherited;

  if HasAlpha
    then FGetPixelFunc := GetPixel1DAlpha
    else FGetPixelFunc := GetPixel1D;
end;


procedure TglBitmap1D.LoadFromFunc(Width: Integer;
  Func: TglBitmapFunction; HasAlpha: Boolean; Data: Pointer);
var
  Size: Integer;
begin
  if (HasAlpha)
    then Size := 4
    else Size := 3;

  FHasAlpha := HasAlpha;
  FWidth := Width;

  AllocData(Width * Size);

  AddFunc(Func, False, Data);
end;


function TglBitmap1D.IntAddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean;
var
  Col: Integer;
  Pos, Size: TglBitmapPixelPosition;
  Source, Dest: TglBitmapPixelData;
  pTempImage: PByte;
begin
  Result := False;

  pTempImage := nil;

  // empty records
  ZeroMemory (@Pos,    SizeOf (Pos));
  ZeroMemory (@Size,   SizeOf (Size));
  ZeroMemory (@Dest,   SizeOf (Dest));
  ZeroMemory (@Source, SizeOf (Source));

  // Prepare
  Size.X := Width;
  Size.Fields := [ffX];

  Pos.Fields := [ffX];

  Source.Fields  := [ffRed, ffGreen, ffBlue];
  Source.ptRed   := GetData();
  Source.ptGreen := GetData();
  Source.ptBlue  := GetData();
  Inc(Source.ptRed,   2);
  Inc(Source.ptGreen, 1);

  if CreateTemp then begin
    pTempImage := AllocMem (Width * 3);

    Dest.Fields  := Source.Fields;
    Dest.ptRed   := pTempImage;
    Dest.ptGreen := pTempImage;
    Dest.ptBlue  := pTempImage;
    Inc(Dest.ptRed,   2);
    Inc(Dest.ptGreen, 1);

    Move (Source.ptBlue^, pTempImage^, Width * 3);
  end else begin
    Dest.Fields  := Source.Fields;
    Dest.ptRed   := Source.ptRed;
    Dest.ptGreen := Source.ptGreen;
    Dest.ptBlue  := Source.ptBlue;
  end;

  for Col := 0 to Width -1 do begin
    Pos.X := Col;
    Func (Self, Pos, Size, Source, Dest, Data);

    Inc(Source.ptRed,   3);
    Inc(Source.ptGreen, 3);
    Inc(Source.ptBlue,  3);

    Inc(Dest.ptRed,   3);
    Inc(Dest.ptGreen, 3);
    Inc(Dest.ptBlue,  3);
  end;

  if CreateTemp
    then SetDataPtr(pTempImage);
end;


function TglBitmap1D.IntAddFuncAlpha(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean;
var
  Col: Integer;
  Pos, Size: TglBitmapPixelPosition;
  Source, Dest: TglBitmapPixelData;
  pTempImage: PByte;
begin
  Result := False;

  pTempImage := nil;

  // empty records
  ZeroMemory (@Pos,    SizeOf (Pos));
  ZeroMemory (@Size,   SizeOf (Size));
  ZeroMemory (@Dest,   SizeOf (Dest));
  ZeroMemory (@Source, SizeOf (Source));

  // Prepare
  Size.X := Width;
  Size.Fields := [ffX];

  Pos.Fields := [ffX];

  Source.Fields  := [ffRed, ffGreen, ffBlue, ffAlpha];
  Source.ptRed   := GetData();
  Source.ptGreen := GetData();
  Source.ptBlue  := GetData();
  Source.ptAlpha := GetData();
  Inc(Source.ptAlpha, 3);
  Inc(Source.ptRed,   2);
  Inc(Source.ptGreen, 1);

  if CreateTemp then begin
    pTempImage := AllocMem (Width * 4);

    Dest.Fields  := Source.Fields;
    Dest.ptRed   := pTempImage;
    Dest.ptGreen := pTempImage;
    Dest.ptBlue  := pTempImage;
    Dest.ptAlpha := pTempImage;
    Inc(Dest.ptAlpha, 3);
    Inc(Dest.ptRed,   2);
    Inc(Dest.ptGreen, 1);

    Move (Source.ptBlue^, pTempImage^, Width * 3);
    // TODO: Was ist denn das?
  end else begin
    Dest.Fields  := Source.Fields;
    Dest.ptRed   := Source.ptRed;
    Dest.ptGreen := Source.ptGreen;
    Dest.ptBlue  := Source.ptBlue;
    Dest.ptAlpha := Source.ptAlpha;
  end;

  for Col := 0 to Width -1 do begin
    Pos.X := Col;
    Func (Self, Pos, Size, Source, Dest, Data);

    Inc(Source.ptRed,   4);
    Inc(Source.ptGreen, 4);
    Inc(Source.ptBlue,  4);
    Inc(Source.ptAlpha, 4);

    Inc(Dest.ptRed,   4);
    Inc(Dest.ptGreen, 4);
    Inc(Dest.ptBlue,  4);
    Inc(Dest.ptAlpha, 4);
  end;

  if CreateTemp
    then SetDataPtr(pTempImage);
end;


function TglBitmap1D.AddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer): boolean;
begin
  assert (Assigned (GetData()));

  if HasAlpha
    then Result := IntAddFuncAlpha(Func, CreateTemp, Data)
    else Result := IntAddFunc(Func, CreateTemp, Data);
end;


function TglBitmap1D.AssignToBitmap(const Bitmap: TBitmap): boolean;
var
  Size, RowSize: Integer;
  pSource, pData: PByte;
begin
  Result := False;

  if Assigned(GetData()) then begin
    if Assigned(Bitmap) then begin
      Bitmap.Width := Width;
      Bitmap.Height := 1;
      Bitmap.PixelFormat := pf24bit;

      // Copy Data
      pSource := GetData();

      if HasAlpha then begin
        Size := 4;
        Bitmap.PixelFormat := pf32bit;
      end else begin
        Size := 3;
        Bitmap.PixelFormat := pf24bit;
      end;

      RowSize := Width * Size;

      pData := Bitmap.Scanline[0];
      if Assigned(pData) then
        Move(pSource^, pData^, RowSize);

      Result := True;
    end;
  end;
end;


function TglBitmap1D.AssignAlphaToBitmap(const Bitmap: TBitmap): boolean;
var
  Col: Integer;
  pSource, pDest: PByte;
begin
  Result := False;

  if Assigned(GetData()) then begin
    if (HasAlpha) then begin
      if Assigned(Bitmap) then begin
        Bitmap.Width := Width;
        Bitmap.Height := 1;
        Bitmap.PixelFormat := pf24bit;

        // Copy Data
        pSource := GetData();

        pDest := Bitmap.Scanline[0];
        if Assigned(pDest) then begin
          for Col := 0 to Width -1 do begin
            Inc(pSource, 3);
            pDest^ := pSource^;
            Inc(pDest, 1);
            pDest^ := pSource^;
            Inc(pDest, 1);
            pDest^ := pSource^;
            Inc(pDest, 1);
            Inc(pSource, 1);
          end;
        end;

        Result := True;
      end;
    end;
  end;
end;


function TglBitmap1D.AssignFromBitmap(const Bitmap: TBitmap): boolean;
var
  pSource, pData: PByte;
  Size, RowSize: Integer;
begin
  Result := False;

  if (Assigned(Bitmap)) then begin
    if ((Bitmap.PixelFormat <> pf24Bit) and (Bitmap.PixelFormat <> pf32Bit))
      then raise EglBitmapException.Create('TglBitmap2D.AssignFromBitmap - Only Bitmaps with 24 or 32 bit are Supported. Set the pixelformat.');

    // Copy Data
    if (Bitmap.PixelFormat = pf24Bit) then begin
      FHasAlpha := False;
      Size := 3;
    end else begin
      FHasAlpha := True;
      Size := 4;
    end;
    FWidth := Bitmap.Width;

    RowSize := FWidth * Size;

    AllocData(RowSize);
    pData := GetData;

    pSource := Bitmap.Scanline[0];

    if (Assigned(pSource)) then 
      Move(pSource^, pData^, RowSize);

    Result := True;
  end;
end;


function TglBitmap1D.AddAlphaFromFunc(
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  Col, TempSize, PixSize: Integer;
  pNewImage, pSource, pDest: pByte;
  Pos, Size: TglBitmapPixelPosition;
  Source, Dest: TglBitmapPixelData;
begin
  Result := false;

  if (Assigned(GetData())) then begin
    TempSize := Width * 4;
    pNewImage := AllocMem(TempSize);
    pDest := pNewImage;

    // empty records
    ZeroMemory (@Pos,    SizeOf (Pos));
    ZeroMemory (@Size,   SizeOf (Size));
    ZeroMemory (@Dest,   SizeOf (Dest));
    ZeroMemory (@Source, SizeOf (Source));

    // Prepare
    Size.X := Width;
    Size.Fields := [ffX];

    Pos.Fields := [ffX];

    Source.Fields := [ffRed, ffGreen, ffBlue];
    Source.ptRed   := GetData();
    Source.ptGreen := GetData();
    Source.ptBlue  := GetData();
    Inc(Source.ptRed,   2);
    Inc(Source.ptGreen, 1);

    pSource := GetData;
    if HasAlpha then begin
      Source.ptAlpha := GetData();
      Inc(Source.ptAlpha, 3);
      PixSize := 4;
    end else begin
      PixSize := 3;
    end;

    Dest.Fields := [ffRed, ffGreen, ffBlue, ffAlpha];
    Dest.ptRed   := pDest;
    Dest.ptGreen := pDest;
    Dest.ptBlue  := pDest;
    Dest.ptAlpha := pDest;
    Inc(Dest.ptAlpha, 3);
    Inc(Dest.ptRed,   2);
    Inc(Dest.ptGreen, 1);

    // Copy Pixels
    for Col := 0 to Width -1 do begin
      Pos.X := Col;

      MoveMemory(pDest, pSource, PixSize);
      Inc(pSource, PixSize);
      Inc(pDest,   4);

      Func (Self, Pos, Size, Source, Dest, Data);

      Inc(Source.ptRed,   PixSize);
      Inc(Source.ptGreen, PixSize);
      Inc(Source.ptBlue,  PixSize);
      if HasAlpha then
        Inc(Source.ptAlpha, PixSize);

      Inc(Dest.ptRed,   4);
      Inc(Dest.ptGreen, 4);
      Inc(Dest.ptBlue,  4);
      Inc(Dest.ptAlpha, 4);
    end;

    FHasAlpha := True;
    SetDataPtr(pNewImage);
    Result := True;
  end;
end;


function TglBitmap1D.AddAlphaFromBitmap(Bitmap: TBitmap;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  Col, TempSize, PixSize: Integer;
  pNewImage, pSource, pDest: pByte;
  Pos, Size: TglBitmapPixelPosition;
  Source, Dest: TglBitmapPixelData;
begin
  Result := False;
  assert(Bitmap.PixelFormat = pf24Bit, 'TglBitmap1D.AddAlphaFromBitmap - Only 24Bit Bitmaps supported.');

  if (Bitmap.Width = Width) then begin
    if (Assigned(GetData())) then begin
      TempSize := Width * 4;
      pNewImage := AllocMem(TempSize);
      try
        pDest := pNewImage;

        if not Assigned(Func)
          then Func := glBitmapDefaultAlphaFunc;

        // empty records
        ZeroMemory (@Pos,    SizeOf (Pos));
        ZeroMemory (@Size,   SizeOf (Size));
        ZeroMemory (@Dest,   SizeOf (Dest));
        ZeroMemory (@Source, SizeOf (Source));

        // Prepare
        Size.X := Width;
        Size.Fields := [ffX];

        Pos.Fields := [ffX];

        Source.Fields := [ffRed, ffGreen, ffBlue];

        Dest.Fields := [ffRed, ffGreen, ffBlue, ffAlpha];
        Dest.ptRed   := pDest;
        Dest.ptGreen := pDest;
        Dest.ptBlue  := pDest;
        Dest.ptAlpha := pDest;
        Inc(Dest.ptAlpha, 3);
        Inc(Dest.ptRed,   2);
        Inc(Dest.ptGreen, 1);

        pSource := GetData;
        if (HasAlpha)
          then PixSize := 4
          else PixSize := 3;

        // Copy Pixels
        Source.ptRed   := Bitmap.ScanLine[0];
        Source.ptGreen := Bitmap.ScanLine[0];
        Source.ptBlue  := Bitmap.ScanLine[0];
        Inc(Source.ptRed, 2);
        Inc(Source.ptGreen, 1);

        for Col := 0 to Width -1 do begin
          Pos.X := Col;

          MoveMemory(pDest, pSource, PixSize);
          Inc(pSource, PixSize);
          Inc(pDest,   4);

          Func (Self, Pos, Size, Source, Dest, Data);

          Inc(Dest.ptRed,   4);
          Inc(Dest.ptGreen, 4);
          Inc(Dest.ptBlue,  4);
          Inc(Dest.ptAlpha, 4);

          Inc(Source.ptRed,   3);
          Inc(Source.ptGreen, 3);
          Inc(Source.ptBlue,  3);
        end;

        // If we have Alpha we don't need to realloc
        if not FHasAlpha then begin
          TempSize := Width * 4;
          AllocData(TempSize);
        end;

        // Copy image to Original
        pDest := GetData;
        MoveMemory(pDest, pNewImage, TempSize);

        FHasAlpha := True;
      finally
        FreeMem(pNewImage);
      end;
    end;
  end;
end;


function TglBitmap1D.RemoveAlpha: Boolean;
var
  pSource, pDest, pTempDest: PByte;
  Col, Size: Integer;
begin
  Result := False;

  if (Assigned(Getdata())) then begin
    if (FHasAlpha) then begin
      Size := Width * 3;
      pSource := GetData;
      pDest := AllocMem(Size);
      pTempDest := pDest;

      for Col := 0 to Width -1 do begin
        Move(pSource^, pTempDest^, 3);
        inc(pSource, 4);
        inc(pTempDest, 3);
      end;

      FHasAlpha := False;
      SetDataPtr(pDest);
    end;
  end;
end;


procedure TglBitmap1D.GetPixel1D(const Pos: TglBitmapPixelPosition;
  var Pixel: TglBitmapPixelData);
var
  BasePtr: Integer;
begin
  inherited;

  if Pos.X <= Width then
    begin
      BasePtr := Pos.X * 3;

      Pixel.Fields := [ffRed, ffGreen, ffBlue];
      Pixel.ptRed   := PByte(BasePtr + 2);
      Pixel.ptGreen := PByte(BasePtr + 1);
      Pixel.ptBlue  := PByte(BasePtr);
    end;
end;


procedure TglBitmap1D.GetPixel1DAlpha(const Pos: TglBitmapPixelPosition;
  var Pixel: TglBitmapPixelData);
var
  BasePtr: Integer;
begin
  inherited;

  if Pos.X <= Width then
    begin
      BasePtr := Pos.X * 4;

      Pixel.Fields := [ffRed, ffGreen, ffBlue, ffAlpha];
      Pixel.ptAlpha := PByte(BasePtr + 3);
      Pixel.ptRed   := PByte(BasePtr + 2);
      Pixel.ptGreen := PByte(BasePtr + 1);
      Pixel.ptBlue  := PByte(BasePtr);
    end;
end;


function TglBitmap1D.FlipHorz: Boolean;
var
  Col: Integer;
  pTempDest, pDest, pSource: pByte;
  Size, RowSize: Integer;
begin
  Result := Inherited FlipHorz;

  if Assigned(GetData()) then begin
    pSource := GetData();
    if (HasAlpha)
      then Size := 4
      else Size := 3;

    RowSize := Width * Size;

    pDest := AllocMem(RowSize);
    pTempDest := pDest;

    Inc(pTempDest, RowSize);
    for Col := 0 to Width -1 do begin
      Move(pSource^, pTempDest^, Size);

      Inc(pSource, Size);
      Dec(pTempDest, Size);
    end;

    SetDataPtr(pDest);

    Result := True;
  end;
end;


procedure TglBitmap1D.UploadTextureData (TextureTarget, Format, Components: Cardinal; BuildWithGlu: Boolean);
begin
  // Upload data
  if BuildWithGlu
    then gluBuild1DMipmaps(TextureTarget, Components, Width, Format, GL_UNSIGNED_BYTE, PByte(GetData()))
    else glTexImage1D(TextureTarget, 0, Components, Width, 0, Format, GL_UNSIGNED_BYTE, PByte(GetData()));

  // Freigeben
  if (FreeDataAfterGenTexture)
    then SetDataPtr(nil);
end;


procedure TglBitmap1D.GenTexture(TestTextureSize: Boolean);
var
  BuildWithGlu, TexRec: Boolean;
  Format, Components: Cardinal;
  TexSize: TGLint;
begin
  if Assigned(GetData()) then begin
    // Check Texture Size
    if (TestTextureSize) then begin
      glGetIntegerv(GL_MAX_TEXTURE_SIZE, @TexSize);

      if (Width > TexSize)
        then raise EglBitmapSizeToLargeException.Create('TglBitmap1D.GenTexture - The size for the texture is to large. It''s may be not conform with the Hardware.');

      TexRec := (GL_ARB_texture_rectangle or (*GL_EXT_texture_rectangle or*) GL_NV_texture_rectangle) and
                (Target = GL_TEXTURE_RECTANGLE_ARB);

      if not (IsPowerOfTwo (Width) or GL_ARB_texture_non_power_of_two or TexRec)
        then raise EglBitmapNonPowerOfTwoException.Create('TglBitmap1D.GenTexture - Rendercontex dosn''t support non power of two texture.');
    end;

    CreateId;

    SetupParameters(BuildWithGlu);
    SelectFormat(Format, Components);

    UploadTextureData(Target, Format, Components, BuildWithGlu);

    // Infos sammeln
    if (GL_ARB_texture_compression) then begin
      glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_COMPRESSED_ARB, @TexSize);
      FIsCompressed := TexSize <> 0;
      glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_COMPRESSED_IMAGE_SIZE_ARB, @Size);
    end else begin
      FIsCompressed := ((Self.Format = tfCompressed) and (GL_EXT_texture_compression_s3tc));
      FSize := 0;
    end;
    glAreTexturesResident(1, @ID, @FIsResident);
  end;
end;


procedure TglBitmap1D.AfterConstruction;
begin
  inherited;

  Target := GL_TEXTURE_1D;
  FGetPixelFunc := GetPixel1D;
end;


{ TglBitmapCubeMap }

procedure TglBitmapCubeMap.AfterConstruction;
begin
  inherited;

  if not (GL_VERSION_1_3 or GL_ARB_texture_cube_map or GL_EXT_texture_cube_map) then
    raise EglBitmapException.Create('TglBitmapCubeMap.AfterConstruction - CubeMaps are unsupported.');

  SetWrap; // set all to GL_CLAMP_TO_EDGE
  Target := GL_TEXTURE_CUBE_MAP;
  fGenMode := GL_REFLECTION_MAP;
end;


procedure TglBitmapCubeMap.Bind(EnableTexCoordsGen, EnableTextureUnit: Boolean);
begin
  inherited Bind (EnableTextureUnit);

  if EnableTexCoordsGen then begin
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, fGenMode);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, fGenMode);
    glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, fGenMode);
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);
    glEnable(GL_TEXTURE_GEN_R);
  end;
end;


procedure TglBitmapCubeMap.GenerateCubeMap(CubeTarget: Cardinal; TestTextureSize: Boolean);
var
  Format, Components: Cardinal;
  BuildWithGlu: Boolean;
  TexSize: Integer;
begin
  // Check Texture Size
  if (TestTextureSize) then begin
    glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, @TexSize);

    if ((Height > TexSize) or (Width > TexSize))
      then raise EglBitmapSizeToLargeException.Create('TglBitmapCubeMap.GenTexture - The size for the Cubemap is to large. It''s may be not conform with the Hardware.');

    if not ((IsPowerOfTwo (Height) and IsPowerOfTwo (Width)) or GL_ARB_texture_non_power_of_two)
      then raise EglBitmapNonPowerOfTwoException.Create('TglBitmapCubeMap.GenTexture - Cubemaps dosn''t support non power of two texture.');
  end;

  // create Texture
  if ID = 0 then begin
    CreateID;
    SetupParameters(BuildWithGlu);
  end;

  SelectFormat(Format, Components);

  // Never use gluBuild2DMipmaps to UploadTextureData
  UploadData (CubeTarget, Format, Components, BuildWithGlu);
end;


procedure TglBitmapCubeMap.GenTexture(TestTextureSize: Boolean);
begin
  Assert(False, 'TglBitmapCubeMap.GenTexture - Don''t call GenTextures directly.');
end;


procedure TglBitmapCubeMap.Unbind(DisableTexCoordsGen,
  DisableTextureUnit: Boolean);
begin
  inherited Unbind (DisableTextureUnit);

  if DisableTexCoordsGen then begin
    glDisable(GL_TEXTURE_GEN_S);
    glDisable(GL_TEXTURE_GEN_T);
    glDisable(GL_TEXTURE_GEN_R);
  end;
end;


{ TglBitmapNormalMap }

type
  TVec = Array[0..2] of Single;
  TglBitmapNormalMapGetVectorFunc = procedure (var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);

  PglBitmapNormalMapRec = ^TglBitmapNormalMapRec;
  TglBitmapNormalMapRec = record
    HalfSize : Integer;
    Func: TglBitmapNormalMapGetVectorFunc; 
  end;


procedure glBitmapNormalMapPosX(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := HalfSize;
  Vec[1] := - (Position.Y + 0.5 - HalfSize);
  Vec[2] := - (Position.X + 0.5 - HalfSize);
end;


procedure glBitmapNormalMapNegX(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := - HalfSize;
  Vec[1] := - (Position.Y + 0.5 - HalfSize);
  Vec[2] := Position.X + 0.5 - HalfSize;
end;


procedure glBitmapNormalMapPosY(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := Position.X + 0.5 - HalfSize;
  Vec[1] := HalfSize;
  Vec[2] := Position.Y + 0.5 - HalfSize;
end;


procedure glBitmapNormalMapNegY(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := Position.X + 0.5 - HalfSize;
  Vec[1] := - HalfSize;
  Vec[2] := - (Position.Y + 0.5 - HalfSize);
end;


procedure glBitmapNormalMapPosZ(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := Position.X + 0.5 - HalfSize;
  Vec[1] := - (Position.Y + 0.5 - HalfSize);
  Vec[2] := HalfSize;
end;


procedure glBitmapNormalMapNegZ(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := - (Position.X + 0.5 - HalfSize);
  Vec[1] := - (Position.Y + 0.5 - HalfSize);
  Vec[2] := - HalfSize;
end;


procedure glBitmapNormalMapFunc(Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition;
  const Source, Dest: TglBitmapPixelData; const Data: Pointer);
var
  Vec : TVec;
  Len: Single;
begin
  with PglBitmapNormalMapRec (Data)^ do begin
    Func(Vec, Position, HalfSize);
    
    // Normalize
    Len := 1 / Sqrt(Sqr(Vec[0]) + Sqr(Vec[1]) + Sqr(Vec[2]));
    if Len <> 0 then begin
      Vec[0] := Vec[0] * Len;
      Vec[1] := Vec[1] * Len;
      Vec[2] := Vec[2] * Len;
    end;

    // Scale Vector and AddVectro
    Vec[0] := Vec[0] * 0.5 + 0.5;
    Vec[1] := Vec[1] * 0.5 + 0.5;
    Vec[2] := Vec[2] * 0.5 + 0.5;
  end;

  // Set Color
  Dest.ptRed^   := Round(Vec[0] * 255);
  Dest.ptGreen^ := Round(Vec[1] * 255);
  Dest.ptBlue^  := Round(Vec[2] * 255);
end;


procedure TglBitmapNormalMap.AfterConstruction;
begin
  inherited;

  fGenMode := GL_NORMAL_MAP;
end;


procedure TglBitmapNormalMap.GenerateNormalMap(Size: Integer;
  TestTextureSize: Boolean);
var
  Rec: TglBitmapNormalMapRec;  
begin
  Rec.HalfSize := Size div 2;

  FreeDataAfterGenTexture := False;

  // Positive X
  Rec.Func := glBitmapNormalMapPosX;
  LoadFromFunc (Size, Size, glBitmapNormalMapFunc, False, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_X, TestTextureSize);

  // Negative X
  Rec.Func := glBitmapNormalMapNegX;
  LoadFromFunc (Size, Size, glBitmapNormalMapFunc, False, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, TestTextureSize);

  // Positive Y
  Rec.Func := glBitmapNormalMapPosY;
  LoadFromFunc (Size, Size, glBitmapNormalMapFunc, False, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, TestTextureSize);

  // Negative Y
  Rec.Func := glBitmapNormalMapNegY;
  LoadFromFunc (Size, Size, glBitmapNormalMapFunc, False, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, TestTextureSize);

  // Positive Z
  Rec.Func := glBitmapNormalMapPosZ;
  LoadFromFunc (Size, Size, glBitmapNormalMapFunc, False, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, TestTextureSize);

  // Negative Z
  Rec.Func := glBitmapNormalMapNegZ;
  LoadFromFunc (Size, Size, glBitmapNormalMapFunc, False, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, TestTextureSize);
end;


initialization
  glBitmapSetDefaultFormat(tfDefault);
  glBitmapSetDefaultFilter(GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR);
  glBitmapSetDefaultWrap(GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE);

  glBitmapSetDefaultFreeDataAfterGenTexture(True);
  glBitmapSetDefaultDeleteTextureOnFree(True);

finalization

end.

