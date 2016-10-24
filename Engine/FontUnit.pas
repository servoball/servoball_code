unit FontUnit;

interface

Uses Windows, Messages, OpenGL;

var
	font:HFont;
  Init:Boolean=FALSE;

Procedure LoadFont(DC:HDC);
Procedure KillFont;
Procedure WriteglText(x,y,winWidth,winHeight:Integer;Text:PChar);


implementation

Procedure LoadFont(DC:HDC);
begin
  font := CreateFont(-16,0,0,0,FW_BOLD,0,0,0,0,
		     0,0,0,0,'Courier New');
  SelectObject(DC,font);
  wglUseFontBitmaps(DC,0,255,0);
end;

Procedure WriteglText(x,y,winWidth,winHeight:Integer;Text:PChar);
var
  l:Integer;
begin
  glPushAttrib(GL_ENABLE_BIT);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0,winWidth,winHeight,0,-1,100);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glLoadIdentity;
  l:=Length(Text);
  glBegin(GL_POLYGON);
    glColor3f(0.0,0.7,1.0);
    glvertex3f(x-(l*5)-15,y-9,0);

    glColor3f(0.2,0.2,0.2);
    glvertex3f(x-(l*5)-3,y-1 ,0);
    glvertex3f(x+(l*5)+3,y-1 ,0);

    glColor3f(0.0,0.7,1.0);
    glvertex3f(x+(l*5)+15,y-9,0);

    glColor3f(0.8,0.8,0.8);
    glvertex3f(x+(l*5)+3,y-17,0);
    glvertex3f(x-(l*5)-3,y-17,0);
  glEnd;
  glColor3f(0,0,0);
  glRasterPos3f(x-(l*5),y-4,0);
  glCallLists(l,GL_UNSIGNED_BYTE,Text);

  glPopAttrib;
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glEnable(GL_TEXTURE_2D);
  gluPerspective(45,WinWidth/WinHeight,0.5,250);
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix;
end;

Procedure KillFont;
begin
  glDeleteLists(0,255);
  DeleteObject(font);
end;

end.
