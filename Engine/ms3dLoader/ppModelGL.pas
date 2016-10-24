{
********************[ Model-Baseclass for Delphi OpenGL  ]******************

Author:       Lithander
e-mail:       lithander@gmx.de
website:      http://pixelpracht.flipcode.com
              http://dgl.thechaoscompany.net


Contains a static and an animated Model-Class. These classes contain all
methods for rendering and controlling their animation. There are no methods
for loading or saving. These kind of methods are implemented in other
units. To load a milkshape model you would bind this unit and a milkshape-loader
unit and call ms3dLoadModel(path). That function will return an instance of an
Model-Class defined in this unit.

Advantages:

* The model-structure is minimalistic. It contains only necessary data and that
  saves memory.
* Every model has the same structure. This allows you to apply the same mani-
  pulations to all kind of models - weather it originally was an ms3d or md3 or
  what ever.
* You bind only this baseclass and the loader you need. That keeps your filesize
  small.
* It's easy to add support for new model-formats. Just write an other loader and
  you're fine.

A Warning:

I don't have used propertys in the Model-Classes and all Data is public.
I know that that's not what i should do in OOP. I also know that allowing direct
access of dynamic arrays is very dangerous.
But I hope that the guys who use this know what they do. If you want it to be save
rewrite it with propertys - i prefered the small, direct way because it allows me
to manipulate the models from wherever i want!

Parts of this Code are a conversion from C++ Code by Brett Porter.
(brettporter@yahoo.com, http://rsn.gamedev.net/pl3d)

Happy coding!
     Lithander (lithander@gmx.de)

****************************[Version 1.0 26.08.2002]****************************
}

unit ppModelGL;

//*********************************************************
                          INTERFACE
//*********************************************************

uses OpenGL, Geometry, GeometryEx;

type

  //Let's first define some Data-Types that we will need for our
  //Model-Classes.

  TModelGLMatrix = TMatrix;

  TModelVertex = record
    Position             : ThreeSingles;
    BoneID               : byte;
  end;

  TModelTriangle = record
    VertexIndices        : ThreeWords;
    VertexNormals        : ThreeThreeSingles;
    S,T                  : ThreeSingles;
  end;

  TModelMaterial = record
    Ambient              : FourSingles;
    Diffuse              : FourSingles;
    Specular             : FourSingles;
    Emissive             : FourSingles;
    Shininess            : single;
    Transparency         : single;
    Texture              : gluint;
  end;

  TModelGroup = record
    MaterialIndex        : byte;
    nTriangles           : word;
    TriangleIndices      : array of word;
  end;

  TModelKeyframe = record
    JointIndex           : word;
    Time                 : Single; //in ms
    Parameter            : ThreeSingles;
  end;

  TModelJoint  = record
    LocalRotation        : ThreeSingles;
    LocalTranslation     : ThreeSingles;
    AbsoluteMatrix       : TModelGLMatrix;
    RelativeMatrix       : TModelGLMatrix;
    FinalMatrix          : TModelGLMatrix;
    CurTransKeyframe     : word;
    CurRotKeyframe       : word;
    Parent               : integer;
    nRotationKeyframes   : word;
    nTranslationKeyframes: word;
    RotationKeyframes    : array of TModelKeyframe;
    TranslationKeyframes : array of TModelKeyframe;
  end;

  TModelGLRenderResult = (RENDERED_OKAY, NO_OPENGL, MATERIAL_NOT_FOUND);

  //Now it's time for the Model-Classes!

  TStaticModelGL = class
  public
    numGroups            : word;
    numMaterials         : word;
    numTriangles         : word;
    numVertices          : word;
    Vertices             : array of TModelVertex;
    Triangles            : array of TModelTriangle;
    Groups               : array of TModelGroup;
    Materials            : array of TModelMaterial;
    function Render : TModelGLRenderResult;
  end;

  TAnimatedModelGL = class(TStaticModelGL)
  public
    Time                 : Integer; //increased by calling AdvanceAnimation()
    MaxTime              : Integer;
    Looping              : boolean;
    numJoints            : word;
    Joints               : array of TModelJoint;
    procedure Restart;
    function Render : TModelGLRenderResult;
    procedure AdvanceAnimation(aTime : Integer);
  end;

//*********************************************************
                         IMPLEMENTATION
//*********************************************************

  uses Windows;

  procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


  function TStaticModelGL.Render : TModelGLRenderResult;
  var i,j,k:integer;
  begin
    for i:=0 to numGroups-1 do with Groups[i] do begin
      //Setup the Materials
      if MaterialIndex >= numMaterials then begin
        result := MATERIAL_NOT_FOUND;
        exit;
      end;

      glMaterialfv(GL_FRONT_AND_BACK,  GL_AMBIENT,  @Materials[materialIndex].Ambient);
      glMaterialfv(GL_FRONT_AND_BACK,  GL_DIFFUSE,  @Materials[materialIndex].Diffuse);
      glMaterialfv(GL_FRONT_AND_BACK,  GL_SPECULAR, @Materials[materialIndex].Specular);
      glMaterialfv(GL_FRONT_AND_BACK,  GL_SHININESS,@Materials[materialIndex].Shininess);
      glMaterialfv(GL_FRONT_AND_BACK,  GL_EMISSION, @Materials[materialIndex].Emissive);

      //Bind the Texture if there is one
      glBindTexture(GL_TEXTURE_2D, Materials[materialIndex].texture);

      glBegin(GL_TRIANGLES);
        for j:=0 to nTriangles-1 do begin
          for k := 0 to 2 do with Triangles[triangleIndices[j]] do begin
            glNormal3fv(@vertexNormals[k]);
            glTexCoord2f(s[k],1-t[k]);
            glVertex3fv(@Vertices[vertexIndices[k]].Position);
          end;
        end;
      glEnd();

      result := RENDERED_OKAY;
    end;
  end;


  procedure TAnimatedModelGL.Restart;
  var i : integer;
  begin
    if numJoints = 0 then exit;//exit if the model isn't animated

    for i := 0 to numJoints - 1 do begin
      Joints[i].CurRotKeyframe := 0;
      Joints[i].CurTransKeyframe := 0;
      Joints[i].FinalMatrix := Joints[i].AbsoluteMatrix;
    end;

    Time := 0;
  end;


  function TAnimatedModelGL.Render : TModelGLRenderResult;
  var i,j,k,index:integer;
      vector : ThreeSingles;
      BoneID : integer;
  begin
    for i:=0 to numGroups-1 do with Groups[i] do begin
      //Setup the Materials
      if MaterialIndex >= numMaterials then begin
        result := MATERIAL_NOT_FOUND;
        exit;
      end;

      glMaterialfv(GL_FRONT_AND_BACK,  GL_AMBIENT,  @Materials[materialIndex].Ambient);
      glMaterialfv(GL_FRONT_AND_BACK,  GL_DIFFUSE,  @Materials[materialIndex].Diffuse);
      glMaterialfv(GL_FRONT_AND_BACK,  GL_SPECULAR, @Materials[materialIndex].Specular);
      glMaterialfv(GL_FRONT_AND_BACK,  GL_SHININESS,@Materials[materialIndex].Shininess);
      glMaterialfv(GL_FRONT_AND_BACK,  GL_EMISSION, @Materials[materialIndex].Emissive);

      //Bind the Texture if there is one
      glBindTexture(GL_TEXTURE_2D, Materials[materialIndex].texture);

      if numJoints = 0 then begin //render the group without animation...

        glBegin(GL_TRIANGLES);
        for j:=0 to nTriangles-1 do begin
          for k := 0 to 2 do with Triangles[triangleIndices[j]] do begin
            glNormal3fv(@vertexNormals[k]);
            glTexCoord2f(s[k],1-t[k]);
            glVertex3fv(@Vertices[vertexIndices[k]].Position);
          end;
        end;
        glEnd;

      end else begin  //render the group with animation

        glBegin(GL_TRIANGLES);
        for j:=0 to nTriangles-1 do begin
          for k := 0 to 2 do with Triangles[triangleIndices[j]] do begin
            index := vertexIndices[k];
            BoneID := Vertices[index].BoneID;
            if BoneID = -1 then begin
              glNormal3fv(@vertexNormals[k]);
              glTexCoord2f(s[k],1-t[k]);
              glVertex3fv(@Vertices[index].Position);
            end else begin
              glTexCoord2f(s[k],1-t[k]);
              // rotate according to transformation matrix
              vector := vertexNormals[k];
              MatrixRotate(Joints[BoneID].FinalMatrix,vector);
              glNormal3fv(@vector);

              vector := ThreeSingles(VectorTransform(TVector3f(Vertices[index].Position), Joints[BoneID].FinalMatrix));
              glVertex3fv(@vector);
            end;
          end;
        end;
        glEnd;

      end;
    end;
    result := RENDERED_OKAY;
  end;


  procedure TAnimatedModelGL.AdvanceAnimation(aTime : integer);
  var a,b,i,frame                : integer;
      TimeDelta, InterpValue     : Single;
      TransVec, RotVec           : ThreeSingles;
      TransMatrix, RelativeFinal : TMatrix;
      CurFrame, PrevFrame        : TModelKeyframe;
  begin
    if numJoints = 0 then exit;//exit if the model isn't animated

    TransMatrix := IdentityMatrix;
    RelativeFinal := IdentityMatrix;

    inc(Time, aTime);
    if Time > MaxTime then begin
      dec(Time,MaxTime);
      Restart;
    end;

    for i := 0 to numJoints do begin
      if (Joints[i].nRotationKeyframes = 0) and (Joints[i].nTranslationKeyframes = 0) then begin
        Joints[i].FinalMatrix := Joints[i].AbsoluteMatrix;
        exit;
      end;
      //TRANSLATION - Interpolate between Keyframes to get TransVec

      //find the current TransKeyframe...
      frame := Joints[i].CurTransKeyframe;
      while (frame < Joints[i].nTranslationKeyframes) and (Joints[i].TranslationKeyframes[frame].Time < Time) do inc(frame);
      Joints[i].curTransKeyframe := frame;
      if frame = 0 then transVec := Joints[i].TranslationKeyframes[frame].Parameter
      //calculate the Translation Vector
      else if frame = Joints[i].nTranslationKeyframes then transVec := Joints[i].TranslationKeyframes[frame-1].Parameter
      else begin
        CurFrame    := Joints[i].TranslationKeyframes[frame];
        PrevFrame   := Joints[i].TranslationKeyframes[frame-1];
        TimeDelta   := CurFrame.Time - PrevFrame.Time;
        InterpValue := (Time - PrevFrame.Time) / TimeDelta;

        TransVec[0] := PrevFrame.Parameter[0] + (CurFrame.Parameter[0] - prevFrame.Parameter[0])*InterpValue;
        TransVec[1] := PrevFrame.Parameter[1] + (CurFrame.Parameter[1] - prevFrame.Parameter[1])*InterpValue;
        TransVec[2] := PrevFrame.Parameter[2] + (CurFrame.Parameter[2] - prevFrame.Parameter[2])*InterpValue;
      end;
      //ROTATION - Interpolate between Keyframes to get RotVect;

      //find the current RotKeyframe...
      frame := Joints[i].CurRotKeyframe;
      while (frame < Joints[i].nRotationKeyframes) and (Joints[i].RotationKeyframes[frame].Time < Time) do inc(frame);
      Joints[i].CurRotKeyframe := frame;
      //calculate the Rotation Matrix
      if frame = 0 then MatrixSetRotationRad(TransMatrix,Joints[i].RotationKeyframes[frame].Parameter)
      else if frame = Joints[i].nRotationKeyframes then MatrixSetRotationRad(TransMatrix,Joints[i].RotationKeyframes[frame-1].Parameter)
      else begin
        CurFrame    := Joints[i].RotationKeyframes[frame];
        PrevFrame   := Joints[i].RotationKeyframes[frame-1];
        TimeDelta   := CurFrame.Time - PrevFrame.Time;
        InterpValue := (Time - PrevFrame.Time) / TimeDelta;

        RotVec[0] := PrevFrame.Parameter[0] + (CurFrame.Parameter[0] - prevFrame.Parameter[0])*InterpValue;
        RotVec[1] := PrevFrame.Parameter[1] + (CurFrame.Parameter[1] - prevFrame.Parameter[1])*InterpValue;
        RotVec[2] := PrevFrame.Parameter[2] + (CurFrame.Parameter[2] - prevFrame.Parameter[2])*InterpValue;

        MatrixSetRotationRad(TransMatrix,RotVec);
      end;

      //Combine the RotationMatrix with the Translation Vector
      MatrixSetTranslation(TransMatrix,TransVec);

      RelativeFinal := Joints[i].RelativeMatrix;
      RelativeFinal := MatrixMultiply(TransMatrix,RelativeFinal);

      if Joints[i].Parent = -1 then Joints[i].FinalMatrix := RelativeFinal
      else begin
        Joints[i].FinalMatrix := Joints[Joints[i].Parent].FinalMatrix;
        Joints[i].FinalMatrix := MatrixMultiply(RelativeFinal, Joints[i].FinalMatrix);
      end;
    end;
  end;


end.
