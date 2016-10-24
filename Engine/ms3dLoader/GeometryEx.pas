unit GeometryEx;

{
********************[ Math-Methods for Delphi ]******************

Author:       Lithander
e-mail:       lithander@gmx.de
website:      http://pixelpracht.flipcode.com
              http://dgl.thechaoscompany.net


This unit's adds functionality to the Geometry unit by Mike Lischke...
The inverse stuff could be achieved by setting normal and inverting afterwards
but we need it fast!
This unit was written for use with ppModelGL and ppLoadMS3D.

Happy coding!
     Lithander (lithander@gmx.de)

****************************[Version 1.0 22.08.2002]****************************
}

interface

uses Geometry;

type
  //defining these array types doesn't only simplifies the code but allows you
  //to assign the complete array instead of setting each field for it's own.
  ThreeSingles           = array[0..2] of Single;
  FourSingles            = array[0..3] of Single;
  ThreeWords             = array[0..2] of Word;
  ThreeThreeSingles      = array[0..2] of ThreeSingles;

//procedure MatrixReset(var matrix : TMatrix); // replace matrix with Identity-Matrix
procedure MatrixSetTranslation(var matrix : TMatrix; Translation : ThreeSingles); // Set the translation of the current matrix. Will replace any previous values.
//procedure MatrixSetInverseTranslation(var matrix : TMatrix; Translation : ThreeSingles); //Set the inverse translation of the current matrix. Will erase any previous values.
procedure MatrixSetRotationRad(var matrix : TMatrix; param : ThreeSingles );
procedure MatrixSetRotationDeg(var matrix : TMatrix; param : ThreeSingles );
//procedure MatrixSetRotationQuat(var matrix : TMatrix; Q : TQuaternion );
//procedure MatrixSetInverseRotationRad(var matrix : TMatrix; param : ThreeSingles );
//procedure MatrixSetInverseRotationDeg(var matrix : TMatrix; param : ThreeSingles );
procedure MatrixInverseTranslate(matrix : TMatrix;var Vector : ThreeSingles );
procedure MatrixInverseRotate(matrix : TMatrix;var Vector : ThreeSingles );
procedure MatrixRotate(matrix : TMatrix; var Vector : ThreeSingles );

implementation

uses windows;

const
  X = 0;
  Y = 1;
  Z = 2;
  W = 3;

{procedure MatrixReset(var matrix : TMatrix);
begin
  matrix := IdentityMatrix;
end;}

procedure MatrixSetTranslation(var matrix : TMatrix; Translation : ThreeSingles);
begin
  matrix[W,X] := translation[X];
  matrix[W,Y] := translation[Y];
  matrix[W,Z] := translation[Z];
end;

{procedure MatrixSetInverseTranslation(var matrix : TMatrix; Translation : ThreeSingles);
begin
  matrix[W,X] := -translation[X];
  matrix[W,Y] := -translation[Y];
  matrix[W,Z] := -translation[Z];
end;}

procedure MatrixSetRotationRad(var matrix : TMatrix; param : ThreeSingles );
var cr, cp, cy, sr, sp, sy : Single;
begin
  cr := cos(param[0]);
  sr := sin(param[0]);
  cp := cos(param[1]);
  sp := sin(param[1]);
  cy := cos(param[2]);
  sy := sin(param[2]);

  matrix[X,X] := cp * cy;
  matrix[X,Y] := cp * sy;
  matrix[X,Z] := - sp;

  matrix[Y,X] := sr * sp * cy - cr * sy;
  matrix[Y,Y] := sr * sp * sy + cr * cy;
  matrix[Y,Z] := sr * cp;

  matrix[Z,X] := cr * sp * cy + sr * sy;
  matrix[Z,Y] := cr * sp * sy - sr * cy;
  matrix[Z,Z] := cr * cp;
end;

procedure MatrixSetRotationDeg(var matrix : TMatrix; param : ThreeSingles );
var vec : ThreeSingles;
begin
  vec[0] := param[0]*180/PI;
  vec[1] := param[1]*180/PI;
  vec[2] := param[2]*180/PI;
  MatrixSetRotationRad(matrix, vec);
end;

{procedure MatrixSetInverseRotationRad(var matrix : TMatrix; param : ThreeSingles );
var cr, cp, cy, sr, sp, sy : Single;
begin
  cr := cos(param[0]);
  sr := sin(param[0]);
  cp := cos(param[1]);
  sp := sin(param[1]);
  cy := cos(param[2]);
  sy := sin(param[2]);

  matrix[X,X] := cp * cy;
  matrix[Y,X] := cp * sy;
  matrix[Z,X] := - sp;

  matrix[X,Y] := sr * sp * cy - cr * sy;
  matrix[Y,Y] := sr * sp * sy + cr * cy;
  matrix[Z,Y] := sr * cp;

  matrix[X,Z] := cr * sp * cy + sr * sy;
  matrix[Y,Z] := cr * sp * sy - sr * cy;
  matrix[Z,Z] := cr * cp;

end;   }

{procedure MatrixSetInverseRotationDeg(var matrix : TMatrix; param : ThreeSingles );
var vec : ThreeSingles;
begin
  vec[0] := param[0]*180/PI;
  vec[1] := param[1]*180/PI;
  vec[2] := param[2]*180/PI;
  MatrixSetInverseRotationRad(matrix, vec);
end;  }

procedure MatrixInverseTranslate(matrix : TMatrix;var Vector : ThreeSingles );
begin
  Vector[0] := Vector[0]-matrix[W,X];
  Vector[1] := Vector[1]-matrix[W,Y];
  Vector[2] := Vector[2]-matrix[W,Z];
end;

procedure MatrixInverseRotate(matrix : TMatrix;var Vector : ThreeSingles );
var VOrig : ThreeSingles;
begin
  VOrig := Vector;

  vector[0] := VOrig[0]*matrix[X,X] + VOrig[1]*matrix[X,Y] + VOrig[2]*matrix[X,Z];
  vector[1] := VOrig[0]*matrix[Y,X] + VOrig[1]*matrix[Y,Y] + VOrig[2]*matrix[Y,Z];
  vector[2] := VOrig[0]*matrix[Z,X] + VOrig[1]*matrix[Z,Y] + VOrig[2]*matrix[Z,Z];

end;

procedure MatrixRotate(matrix : TMatrix;var Vector : ThreeSingles );
var VOrig : ThreeSingles;
begin
  VOrig := Vector;

  vector[0] := VOrig[0]*matrix[X,X] + VOrig[1]*matrix[Y,X] + VOrig[2]*matrix[Z,X];
  vector[1] := VOrig[0]*matrix[X,Y] + VOrig[1]*matrix[Y,Y] + VOrig[2]*matrix[Z,Y];
  vector[2] := VOrig[0]*matrix[X,Z] + VOrig[1]*matrix[Y,Z] + VOrig[2]*matrix[Z,Z];

end;

end.
