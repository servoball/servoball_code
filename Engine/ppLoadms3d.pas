{
********************[ Milkshape3D Loader for Delphi OpenGL  ]******************

Author:       Lithander
e-mail:       lithander@gmx.de
website:      http://pixelpracht.flipcode.com
              http://dgl.thechaoscompany.net


This unit provides two methods to load milkshape models:

- You can load non-animated Models by calling ms3dLoadStaticModel(path).
This Method returns an Instance of TStaticModelGL defined in ppModelGL.

- You can load animated Models by calling ms3dLoadAnimatedModel(path).
This Method returns an Instance of TAnimatedModelGL defined in ppModelGL.
You can also load Models that are not animated but this will be a little
bit slower and a bit more memory consuming then using ms3dLoadStaticModel(path)

Have a look on ppModelGL to learn more...

Parts of this Code are a conversion from C++ Code by Brett Porter.
(brettporter@yahoo.com, http://rsn.gamedev.net/pl3d) Check the website! ;)

Happy coding!
     Lithander (lithander@gmx.de)

****************************[Version 1.0 26.08.2002]****************************
}


unit ppLoadMS3D;

//*********************************************************
                          INTERFACE
//*********************************************************

uses ppModelGL;

function ms3dLoadStaticModel(aPath : string)  : TStaticModelGL;

function ms3dLoadAnimatedModel(aPath : string): TAnimatedModelGL;


//*********************************************************
                          IMPLEMENTATION
//*********************************************************

uses windows, classes, Tex2, GeometryEx, Geometry;

type

KeyFrameType          = (ROTATION_KF,TRANSLATION_KF);

//Lets start with setting up some data structures that we want to read
//from the Milkshape file...

MS3D_Header = packed record
    Id               : array[0..9] of char;
    Version          : integer
end;

MS3D_Vertex = packed record
    Flags            : byte;
    Position         : ThreeSingles;
    BoneID           : shortInt;
    refCount         : byte;
end;

MS3D_Triangle = packed record
    Flags             : word;
    VertexIndices     : ThreeWords;
    VertexNormals     : ThreeThreeSingles;
    S,T               : ThreeSingles;
    SmoothingGroup    : byte;
    GroupIndex        : byte;
end;

MS3D_Group = packed record
    Flags             : byte;
    Name              : array[0..31] of char;
    nTriangles        : word;
    TriangleIndices   : array of word;
    MaterialIndex     : byte;
end;

MS3D_Material = packed record
    Name              : array[0..31] of char;
    Ambient           : FourSingles;
    Diffuse           : FourSingles;
    Specular          : FourSingles;
    Emissive          : FourSingles;
    Shininess         : single;
    Transparency      : single;
    Mode              : byte; //unused!
    Texture           : array[0..127] of char;
    Alphamap          : array[0..127] of char;
end;

MS3D_Joint = packed record
    Flags             : byte;
    Name              : array[0..31] of char;
    ParentName        : array[0..31] of char;
    Rotation          : ThreeSingles;
    Translation       : ThreeSingles;
    nRotKeyframes     : word;
    nTransKeyframes   : word;
end;

MS3D_Keyframe = packed record
    Time              : single;
    Parameter         : ThreeSingles;
end;

TJointName = packed record
  JointIndex          : word;
  Name                : string;
end;

var Path  : String;

{Now let's define some helper-methods.
They read the different types of data from a Stream containing the
ms3d-file and write it to our Model-Class.
NOTE: they don't search the data - they just load it. So make sure your
Stream's position is correct when calling these methods.
}

procedure LoadHeader(aModel : TStaticModelGL; aStream : TStream); //This informations aren't used
var ms3dHeader     : MS3D_header;
begin
  with aModel do begin
    aStream.Read(ms3dheader,sizeOf(ms3dheader));
  end;
end;


procedure LoadVertices(aModel : TStaticModelGL; aStream : TStream);
var ms3dVertex     : MS3D_vertex;
    c              : integer;
begin
  with aModel do begin
    aStream.Read(numVertices,SizeOf(NumVertices));
    SetLength(vertices,numVertices);
    for c:=0 to numVertices-1 do begin
      aStream.Read(ms3dvertex,SizeOf(ms3dvertex));
      Vertices[c].Position := ms3dvertex.Position;
      Vertices[c].BoneID   := ms3dvertex.BoneID;
    end;
  end;
end;


procedure LoadTriangles(aModel : TStaticModelGL; aStream : TStream);
var ms3dTriangle     : MS3D_Triangle;
    c              : integer;
begin
  with aModel do begin
    aStream.Read(numTriangles,SizeOf(NumTriangles));
    SetLength(triangles,numTriangles);
    for c:=0 to NumTriangles-1 do begin
      aStream.Read(ms3dtriangle,SizeOf(ms3dtriangle));
      Triangles[c].VertexIndices    := ms3dtriangle.VertexIndices;
      Triangles[c].S                := ms3dtriangle.S;
      Triangles[c].T                := ms3dtriangle.T;
      Triangles[c].VertexNormals    := ms3dtriangle.VertexNormals;
    end;
  end;
end;

procedure LoadGroups(aModel : TStaticModelGL; aStream : TStream);
var ms3dGroup     : MS3D_Group;
    c,c2          : integer;
begin
  with aModel do begin
    aStream.Read(numGroups,sizeOf(NumGroups));
    SetLength(Groups,numGroups);
    for c:=0 to NumGroups-1 do with Groups[c] do begin
      aStream.Read(ms3dgroup.flags,SizeOf(ms3dgroup.flags));//2 byte
      aStream.Read(ms3dgroup.name,SizeOf(ms3dgroup.name));//32 byte
      aStream.Read(nTriangles,sizeof(nTriangles));//2 byte

      SetLength(TriangleIndices,nTriangles);
      for c2 := 0 to nTriangles-1 do aStream.Read(TriangleIndices[c2], sizeof(TriangleIndices[c2]));
      aStream.Read(materialIndex,sizeof(materialIndex));//2 byte
    end;
  end;
end;


//Combines the relative paths from the exe to the model-dir and from the model-dir
//to the texture-dir.

function GetTexturePath(aModelPath : string; aRelTexPath : string) : string;
var i    : integer;
begin
  //for every '..\' we delete one directory from the aModelPath and the '..\'
   while (copy(aRelTexPath,0,3) = '..\') and (aModelPath <> '') do begin
    aRelTexPath := copy(aRelTexPath,4,length(aRelTexPath));
    i := 0;
    while i <= length(aModelPath) do begin
      if aModelPath[i] = '\' then break;
      inc(i);
    end;
    aModelPath := copy(aModelPath,i,length(aModelPath));
  end;

  if aModelPath = '' then result := aRelTexPath else
   result := aModelPath + '\' + copy(aRelTexPath,3,length(aRelTexPath));
end;


procedure LoadMaterials(aModel : TStaticModelGL; aStream : TStream);
var ms3dMaterial     : MS3D_Material;
    c                : integer;
    TexPath          : string;
begin
  with aModel do begin
    aStream.Read(numMaterials,SizeOf(NumMaterials));
    SetLength(Materials,numMaterials);
    for c:=0 to NumMaterials-1 do begin
      aStream.Read(ms3dmaterial,SizeOf(ms3dmaterial));
      Materials[c].Ambient      := ms3dmaterial.Ambient;
      Materials[c].Diffuse      := ms3dmaterial.Diffuse;
      Materials[c].Specular     := ms3dmaterial.Specular;
      Materials[c].Emissive     := ms3dmaterial.Emissive;
      Materials[c].Shininess    := ms3dmaterial.Shininess;
      Materials[c].Transparency := ms3dmaterial.Transparency;
      if ms3dmaterial.Texture <> '' then begin
        TexPath := GetTexturePath(path,ms3dmaterial.texture);
        LoadTextureFromFile(TexPath,Materials[c].texture,FALSE);
      end;
    end;
  end;
end;


//This method is used if you load an animated Model... it's used to translate all vertices to
//the bones they are attached to. This saves some time when it comes to rendering and animating.

procedure SetUpJoints(aModel : TAnimatedModelGL);
var c,c2   : integer;
    Matrix : TMatrix;
    boneID : integer;
begin
  // If the model isn't animated go out...
  if aModel.numJoints = 0 then exit;
  // otherwise Prepare Matrices of every Joint
  for c := 0 to aModel.numJoints -1 do with aModel.Joints[c] do begin
    RelativeMatrix := IdentityMatrix;
    MatrixSetRotationRad(RelativeMatrix, LocalRotation);
    MatrixSetTranslation(RelativeMatrix, LocalTranslation);
    if Parent > -1 then begin
      AbsoluteMatrix := aModel.Joints[Parent].AbsoluteMatrix;
      AbsoluteMatrix := MatrixMultiply(RelativeMatrix, AbsoluteMatrix);
    end else AbsoluteMatrix := RelativeMatrix;
  end;
  //Inverse translate and rotate Vertices
  for c := 0 to aModel.numVertices - 1 do with aModel.Vertices[c] do begin
    if BoneID > -1 then begin
      Matrix :=  aModel.Joints[BoneID].AbsoluteMatrix;
      MatrixInverseTranslate(Matrix,Position);
      MatrixInverseRotate(Matrix,Position);
     end;
  end;
  //Inverse rotate Normals
  for c := 0 to aModel.numTriangles - 1 do
   for c2 := 0 to 2 do with aModel do begin
    BoneID := Vertices[Triangles[c].VertexIndices[c2]].BoneID;
    if BoneID > -1 then
     MatrixInverseRotate(Joints[BoneID].AbsoluteMatrix,Triangles[c].Vertexnormals[c2]);
  end;
end;


procedure LoadAnimation(aModel : TAnimatedModelGL; aStream : TStream);
var ms3dJoint      : MS3D_Joint;
    ms3dKeyframe   : MS3D_Keyframe;
    AnimFPS        : single;
    TotalFrames    : LongInt;
    TempStreamPos  : Integer;
    JointNameList  : array of TJointName;
    ParentIndex    : integer;
    c,c2,i         : Integer;
    s              : string;
begin
 with aModel do begin
    //Header
    aStream.Read(AnimFPS,SizeOf(AnimFPS));
    aStream.Position := aStream.Position + SizeOf(Single);//Skip CurrentTime
    aStream.Read(TotalFrames,SizeOf(TotalFrames));
    MaxTime := round(TotalFrames*1000 / AnimFPS);

    aStream.Read(numJoints,SizeOf(NumJoints));
    SetLength(Joints,numJoints);
    SetLength(JointNameList,numJoints);

    //Create a JointNameList. Needed later to set ParentIndex for every Joint
    TempStreamPos := aStream.Position;
    for c:=0 to NumJoints-1 do begin
      aStream.Read(ms3dJoint,SizeOf(ms3dJoint));
      aStream.Position := aStream.Position + SizeOf(ms3dKeyframe)*(ms3dJoint.nRotKeyframes + ms3dJoint.nTransKeyframes);
      JointNameList[c].JointIndex := c;
      JointNameList[c].Name := string(ms3dJoint.Name);
    end;
    aStream.Position := TempStreamPos;

    ParentIndex := -1;

    for c := 0 to NumJoints-1 do begin
      aStream.Read(ms3dJoint,SizeOf(ms3dJoint));
      //Find the parent's Bone-Index
      s := string(ms3dJoint.ParentName);
      if Length(s) > 0 then begin
        i := NumJoints;
        repeat dec(i) until (s = JointNameList[i].Name) or (i<0);
        if i >= 0 then ParentIndex := JointNameList[i].JointIndex else MessageBox(0, 'Unable to find parent bone in MS3D file', 'Error', MB_OK or MB_ICONERROR);
      end;

      Joints[c].LocalRotation := ms3dJoint.Rotation;
      Joints[c].LocalTranslation := ms3dJoint.Translation;
      Joints[c].parent := ParentIndex;
      Joints[c].nRotationKeyframes := ms3dJoint.nRotKeyframes;
      Joints[c].nTranslationKeyframes := ms3dJoint.nTransKeyframes;

      setLength(Joints[c].RotationKeyframes,Joints[c].nRotationKeyframes);
      setLength(Joints[c].TranslationKeyframes,Joints[c].nTranslationKeyframes);

      for c2 := 0 to ms3dJoint.nRotKeyframes-1 do begin
       aStream.Read(ms3dKeyframe,sizeof(ms3dKeyframe));
       Joints[c].RotationKeyframes[c2].JointIndex := c;
       Joints[c].RotationKeyframes[c2].Time := ms3dKeyframe.Time*1000;
       Joints[c].RotationKeyframes[c2].Parameter := ms3dKeyframe.Parameter;
      end;
      for c2 := 0 to ms3dJoint.nTransKeyframes-1 do begin
       aStream.Read(ms3dKeyframe,sizeof(ms3dKeyframe));
       Joints[c].TranslationKeyframes[c2].JointIndex := c;
       Joints[c].TranslationKeyframes[c2].Time := ms3dKeyframe.Time*1000;
       Joints[c].TranslationKeyframes[c2].Parameter := ms3dKeyframe.Parameter;
      end;
    end;
  end;
end;


//Now we can implement the Model-Loaders...

function ms3dLoadStaticModel(aPath : string) : TStaticModelGL;
var Model          : TStaticModelGL;
    Stream         : TFileStream;
    j              : integer;
begin
  //extract path ... we will need that for our texture loading!
  j := Length(aPath);
  repeat dec(j) until (aPath[j] = '/') or (aPath[j] = '\') or (j<=0);
  Path := copy(aPath,0,j-1);

  //load modelfile into stream
  Stream:=TFileStream.Create(apath,0);
  Model := TStaticModelGL.Create;

  //load filedata into Model;
  LoadHeader(Model,Stream);
  LoadVertices(Model,Stream);
  LoadTriangles(Model, Stream);
  LoadGroups(Model, Stream);
  LoadMaterials(Model, Stream);

  Stream.Free;
  result := model;
end;

function ms3dLoadAnimatedModel(aPath : string) : TAnimatedModelGL;
var Model          : TAnimatedModelGL;
    Stream         : TFileStream;
    j               : integer;
begin
  //extract path ... we will need that for our texture loading!
{  j := Length(aPath);
  repeat dec(j) until (aPath[j] = '/') or (aPath[j] = '\') or (j<=0);
  Path := copy(aPath,0,j-1);

  //load modelfile into stream
  Stream:=TFileStream.Create(apath,0);
  Model := TAnimatedModelGL.Create;

  //load filedata into Model;
  LoadHeader(Model,Stream);
  LoadVertices(Model,Stream);
  LoadTriangles(Model, Stream);
  LoadGroups(Model, Stream);
  LoadMaterials(Model, Stream);

  LoadAnimation(Model, Stream);//NEW!
  setupJoints(Model);//NEW
  Model.restart;//NEW

  Stream.Free;
  result := model;   }
end;

end.
