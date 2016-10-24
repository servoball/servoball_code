unit MapandVars;
//Labyrinthe zeichnen, Pfeiltasten abfragen, Decke und Boden zeichnen

interface

Uses
	Windows, Messages, OpenGL, Dialogs,log, lakutpu,global_variables,
        Sysutils, mmsystem;

type
	TVertex=record
  	x,y,z:Glfloat;
  end;



procedure DrawMap;
Procedure DrawSkyBox;
Procedure local_landmarks;
Procedure distal_landmarks;
Procedure CaseKeys;
procedure check_keyboard_input;
Procedure DrawGroundandWalls;
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external;
procedure draw_maze_of_labfile(X,Y,Z:GLfloat);
procedure build_list;

var
  CUBES:Integer;
  CubeData:array of TVertex;
  pos:TVertex;
  WinWidth,WinHeight:Integer;
  RX,RY,RZ,FrameTime:Glfloat;
  wall,blau_gelb,caro,diag,local_lm_white:GluInt;
  //Texturen; der Pfad zu den Texturen steht in initgl in unit1
  SkyTex:array[0..5]of GLuInt;
  Keys:array[0..255] of Boolean;
  Fullscreen:Boolean;
  ResX,ResY:Integer;
  ColorDepth:Integer;
  hex_help,hex_help2:double;
  oct_help,oct_help2,oct_help3:double;
  l_height,l_width:integer;


  x_z_koordinaten_old: string;
  alpha_view: integer; // zum Blickrichtung einstellen
  
  maze: gluint;
  lmtest:gluint;
  msg_str: string;
implementation

procedure DrawMap;
var
        i:Integer;
        x,y:Glfloat;
begin
  glLoadIdentity;
  glColor3f(0,0.6,0);
  glBegin(GL_QUADS);
    glVertex3f(000,WinHeight,-1.01);
    glVertex3f(126,WinHeight,-1.01);
    glVertex3f(126,WinHeight-126,-1.01);
    glVertex3f(000,WinHeight-126,-1.01);
  glEnd;
  glLoadIdentity;
  glColor3f(1,0,0);
  x:=126-(pos.x +63);
  y:=WinHeight-(126-(pos.z+63));
  glTranslatef(x,y,-1);
  glRotatef(-RY,0,0,1);
  glBegin(GL_TRIANGLES);
    glVertex3f( 0  ,+4,0);
    glVertex3f(+2.5,-4,0);
    glVertex3f(-2.5,-4,0);
  glEnd;
  glLoadIdentity;
  glPointSize(6);
  glBegin(GL_POINTS);
  for i:=0 to Cubes-1 do
  begin
    x:=cubedata[i].x+ 63;
    y:=cubedata[i].z+ 63;
    glColor3f(0.8,0.8,0.8);
    glVertex3f(x,Winheight-y,-1);
  end;
  glEnd;
  glColor3f(1,1,1);
end;
////////////////////////////////////////////////////////////////////
Procedure DrawSkyBox;   //zeichnet den Himmel
        //      var
      //	x,w:Glfloat;
begin

  (*glColor3f(0,0,1);    //blau
  glBegin(GL_QUADS);
    glVertex3f(-63,3,-63);
    glVertex3f(-63,3, 63);
    glVertex3f( 63,3, 63);
    glVertex3f( 63,3,-63);
  glEnd;
  *)
   glBindTexture(GL_TEXTURE_2D,SkyTex[1]);

   if colour_sky=1 then
   begin
     glBegin(GL_QUADS);
     glColor3f(1,1,1); //black
     glVertex3f(-63,(junction[1].upper_wall_height[1]+20),-63);
     glcolor3f(0,0,0);//white
     glVertex3f(-63,(junction[1].upper_wall_height[1]+20), 63);
     glcolor3f(0,0,0);//weiﬂ
     glVertex3f( 63,(junction[1].upper_wall_height[1]+20), 63);
     glcolor3f(1,1,1);//black
     glVertex3f( 63,(junction[1].upper_wall_height[1]+20),-63);
     glEnd;
   end else
   begin
     glBegin(GL_QUADS);
     glTexCoord2f(100,100);glVertex3f(-63,(junction[1].duct_wall_height[1]+20),-63);
     glTexCoord2f(100,0);glVertex3f(-63,(junction[1].duct_wall_height[1]+20), 63);
     //glcolor3f(0,0,0);//schwarz
     glTexCoord2f(0,0);glVertex3f( 63,(junction[1].duct_wall_height[1]+20), 63);
     glTexCoord2f(0,100);glVertex3f( 63,(junction[1].duct_wall_height[1]+20),-63);
     glEnd;
   end; // end else.
end;
 ///////////////////////////////////////////////////////////////
 (*    6 verschiedene jeweils winkelabh‰ngige Landmarken    *)
procedure distal_landmarks;
 begin

 distal_lm_width:=150;
 distal_lm_Radius:=250;//100;
 
 y_center_distal_lm_x:=0;
 y_center_distal_lm_z:=0;

 if udpRecMsg.arDistalLM.reLM1<>88 then
 begin
        //showmessage('dlm1');
        reLM1_angle:=udpRecMsg.arDistalLM.reLM1;
        //reLM0_angle:=180;
        //distale LM vom Typ 1, f¸r diesen Trial bei reLM1_angle Grad
        //glColor3f(1.0,1.0,0.1); // yellow
        glBindTexture(GL_TEXTURE_2D,local_lm_white);
        glBegin(GL_QUADS);
        begin
        glNormal3f(-1, 0, 0);   //  Feeder_signal von innen in Richtung 0∞
        glTexCoord2f(30,30);glVertex3f ((cos((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0,30);glVertex3f ((cos((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0, 0);glVertex3f ((cos((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f(30, 0);glVertex3f ((cos((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM1_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM1_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        end;
        glend;
  end;

 if udpRecMsg.arDistalLM.reLM2<>88 then
    begin
        reLM2_angle:=udpRecMsg.arDistalLM.reLM2;
        glBindTexture(GL_TEXTURE_2D,local_lm_white);
        glBegin(GL_QUADS);
        begin
        glNormal3f(-1, 0, 0);   //  Feeder_signal von innen in Richtung 0∞
        glTexCoord2f(30,30);glVertex3f ((cos((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0,30);glVertex3f ((cos((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0, 0);glVertex3f ((cos((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f(30, 0);glVertex3f ((cos((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM2_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM2_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        end;
        glend;
     end;

 if udpRecMsg.arDistalLM.reLM3<>88 then
   begin
        reLM3_angle:=udpRecMsg.arDistalLM.reLM3;
        glColor3f(0.9,0.1,0.1);  // red
        glBegin(GL_QUADS);
        begin
        glNormal3f(-1, 0, 0);   //  Feeder_signal von innen in Richtung 0∞
        glTexCoord2f(30,30);glVertex3f ((cos((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0,30);glVertex3f ((cos((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0, 0);glVertex3f ((cos((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f(30, 0);glVertex3f ((cos((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM3_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM3_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        end;
        glend;
   end;

 if udpRecMsg.arDistalLM.reLM4<>88 then
   begin
        reLM4_angle:=udpRecMsg.arDistalLM.reLM4;
     //   reLM3_angle:=210;
        //distale LM vom Typ 4, f¸r diesen Trial bei reLM4_angle Grad
        glColor3f(1.0,1.0,0.1); // yellow
        glBegin(GL_QUADS);
        begin
        glNormal3f(-1, 0, 0);   //  Feeder_signal von innen in Richtung 0∞
        glTexCoord2f(30,30);glVertex3f ((cos((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0,30);glVertex3f ((cos((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0, 0);glVertex3f ((cos((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f(30, 0);glVertex3f ((cos((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM4_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM4_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        end;
        glend;

    end;

 if udpRecMsg.arDistalLM.reLM5<>88 then
   begin
        reLM5_angle:=udpRecMsg.arDistalLM.reLM5;
        //distale LM vom Typ 5, f¸r diesen Trial bei reLM5_angle Grad
        glColor3f(0.2,1.0,0.1); // green-blue
        glBindTexture(GL_TEXTURE_2D,diag); //binds the file diag.jpg
        glBegin(GL_QUADS);
        begin
        glNormal3f(-1, 0, 0);   //  Feeder_signal von innen in Richtung 0∞
        glTexCoord2f(30,30);glVertex3f ((cos((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0,30);glVertex3f ((cos((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0, 0);glVertex3f ((cos((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f(30, 0);glVertex3f ((cos((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM5_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM5_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        end;
        glend;
   end;

 if udpRecMsg.arDistalLM.reLM6<>88 then
  begin
        reLM6_angle:=udpRecMsg.arDistalLM.reLM6;
        //   reLM5_angle:=180;
        //distale LM vom Typ 6, f¸r diesen Trial bei reLM6_angle Grad
        //glColor3f(0.9,0.1,0.1);  // red
        glBegin(GL_QUADS);
        begin
        glNormal3f(-1, 0, 0);   //  Feeder_signal von innen in Richtung 0∞
        glTexCoord2f(30,30);glVertex3f ((cos((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0,30);glVertex3f ((cos((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x),  distal_lm_height                    , (sin((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f( 0, 0);glVertex3f ((cos((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) - sin((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x-distal_lm_width) + cos((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        glTexCoord2f(30, 0);glVertex3f ((cos((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) - sin((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           )- cos((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x + sin((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_x), (distal_lm_height-distal_lm_height-3), (sin((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_x+distal_lm_width) + cos((reLM6_angle+ alpha_lab)/180*pi)*(y_center_distal_lm_z-(distal_lm_radius*0.99)           ) - sin((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_x - cos((reLM6_angle+ alpha_lab)/180*pi)* y_center_distal_lm_z + y_center_distal_lm_z));
        end;
        glend;
  end;

end;


//////////////////////////////////////////////////

 procedure local_landmarks;

var
 j,k: integer;
 local_lm_width_cross1  : real;     //15.12.09
 local_lm_height_cross1 : real;
 local_lm_width_cross2  : real;
 local_lm_height_cross2 : real;

begin

local_lm_Radius:= 2* halbe_Gangbreite*cos(30/180*pi)/3;//radius des Innenkreis vom Kreuzungsdreieck
// local_lm_Radius= ca.8,6  wenn halbe_Gangbreite= 15 (const)
//glBindTexture(GL_TEXTURE_2D,blau_gelb);//caro//wall); //Textur festlegen, z.B.wall.jpg
glBindTexture(GL_TEXTURE_2D,local_lm_white); //binds the file local_lm_white.jpg
glBegin(GL_QUADS);

msg_str:= '';
for j:= 1 to 6 do
 begin
    msg_str:= msg_str+ inttostr(udpRecMsg.arJunction[1,j])+ ' ';

  //zum testen 2.12.08
  junction[j].x_junction_grafic_llm:=-junction[j].x_junction_grafic;  // so geht es!
  junction[j].z_junction_grafic_llm:= junction[j].z_junction_grafic;
  // evtl noch anderen Namen nehmen
 end;

for j:=1 to  number_of_junctions do
begin
 for k:=1 to 6 do
 begin
 //udpRecMsg.arJunction[j,k]:=1;   //Zeile nicht notwendig, wenn eingelesen wird

 //glColor3f(2.0,2.0,7.0); //   Farbe der lokalen Landmarken
        if llm_colour=88 then glColor3f(7.0,7.0,7.0); //   Farbe der lokalen Landmarken weiﬂ
        if llm_colour=1 then glColor3f(0.0,0.0,0.0); //   Farbe der lokalen Landmarken schwarz
        if llm_colour=2 then  glColor3f(1.0,1.0,0.1); // yellow  Farbe der lokalen Landmarken


   if ((udpRecMsg.arJunction[j,k]=1) and (llm_colour<>99))then
      begin

        glNormal3f(-1, 0, 0);   //  Feeder_signal von innen in Richtung k∞

        glTexCoord2f(30,30);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  -local_lm_height + 6 , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f( 0,30);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  -local_lm_height + 6 , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f( 0, 0);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  -local_lm_height     , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f(30, 0);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  -local_lm_height     , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
      end;

   if LLm_colour=99 then         //15.12.09
      //schwarzes Kreuz malen
      begin
        //showmessage('colour 99');
        glColor3f(0.0,0.0,0.0); //   Farbe der lokalen Landmarken schwarz
        if ((udpRecMsg.arJunction[j,k]=1) and (llm_colour=99))then
        begin
        glNormal3f(-1, 0, 0);   //  Feeder_signal von innen in Richtung k∞
         //ein "Hochkant Rechteck malen"
         local_lm_width_cross1:= 0.8;         //bei ein Rechteck Height=4, width=2.5
         local_lm_height_cross1:= 3.1;
        glTexCoord2f(30,30);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width_cross1) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  -local_lm_height_cross1 + 6 , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width_cross1) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f( 0,30);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width_cross1) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  -local_lm_height_cross1 + 6 , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width_cross1) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f( 0, 0);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width_cross1) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  -local_lm_height_cross1     , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width_cross1) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f(30, 0);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width_cross1) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  -local_lm_height_cross1     , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width_cross1) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));

        //ein "quer liegendes Rechteck malen"
        local_lm_width_cross2:=2.4;
        //local_lm_height_cross2:=3;
        glTexCoord2f(30,30);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width_cross2) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  1.7,    (SIN(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width_cross2) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f( 0,30);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width_cross2) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  1.7,    (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width_cross2) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f( 0, 0);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width_cross2) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  0.4   , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm-local_lm_width_cross2) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));
        glTexCoord2f(30, 0);glVertex3f ((cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width_cross2) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           )- cos(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm + sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) + junction[j].x_junction_grafic_llm),  0.4   , (sin(((8-k)*(60)+ alpha_lab+120)/180*pi)*(junction[j].x_junction_grafic_llm+local_lm_width_cross2) + cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm-(local_lm_Radius*0.99)           ) - sin(((8-k)*(60)+ alpha_lab+120)/180*pi)* junction[j].x_junction_grafic_llm - cos(((8-k)*(60)+ alpha_lab+120)/180*pi)*(-junction[j].z_junction_grafic_llm) - junction[j].z_junction_grafic_llm));

        end;


      end;  //schwarzes Kreuz malen

 end;           // for k

 end;           // for j
glend;

end;            // procedure

///////////////////////////////////////////////////////////////////////////
Procedure DrawGroundandWalls;  //zeichnet nur den Boden
begin
  glColor3f(1,1,1);             //Farbe f¸r den Boden, weiﬂ

  glBindTexture(GL_TEXTURE_2D,caro);    //Textur f¸r den Boden, muss noch skalliert werden mit glTexCoord2f

  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);

   //Farbverlauf von schwarz nach weiﬂ am Boden

   if colour_ground=1
       then begin
          glBegin(GL_QUADS);
          glColor3f(1,1,1); //black
          glVertex3f(-63,0,-63);
          glcolor3f(0,0,0); //white
          glVertex3f(-63,0, 63);
          glcolor3f(0,0,0); //white
          glVertex3f( 63,0, 63);
          glcolor3f(1,1,1); //black
          glVertex3f( 63,0,-63);
          glEnd;
       end
   else
       begin
          glBegin(GL_QUADS);
          glTexCoord2f(2000,2000);glVertex3f(-6663,0,-6663);
          glTexCoord2f(2000,0);glVertex3f(-6663,-3, 6663);
          //glcolor3f(0,0,0);//schwarz

          glTexCoord2f(0,0);glVertex3f( 6663,0, 6663);
          glTexCoord2f(0,2000);glVertex3f( 6663,0,-6663);

          {   glTexCoord2f(1,1);glVertex3f(-63,-3,-63);
             glTexCoord2f(1,0);glVertex3f(-63,-3, 63);
             //glcolor3f(0,0,0);//schwarz
             glTexCoord2f(0,0);glVertex3f( 63,-3, 63);
             glTexCoord2f(0,1);glVertex3f( 63,-3,-63);        }
          glEnd;
        end;

end;
/////////////////////////////////////////////////////////////////////////////
Procedure CaseKeys;
var
	Move:Glfloat;
begin
	Move:=FrameTime/80;
	If Keys[VK_LEFT] then
  begin
    (*If CaseCollision(VK_LEFT)=FALSE then
    begin
    	Pos.x:=Pos.x-sin((-RY-90)*PI/180)*Move;
    	Pos.z:=Pos.z-cos((-RY-90)*PI/180)*Move;
    end else *)
    begin
      Pos.x:=Pos.x-sin((-RY-90)*PI/180)*Move;
    end;
  end;
  If Keys[VK_RIGHT] then
  begin
    (*If CaseCollision(VK_RIGHT)=FALSE then
    begin
    	Pos.x:=Pos.x+sin((-RY-90)*PI/180)*Move;
    	Pos.z:=Pos.z+cos((-RY-90)*PI/180)*Move;
    end else *)
    begin
      Pos.x:=Pos.x+sin((-RY-90)*PI/180)*Move;
      end;
  end;
  If Keys[VK_UP] then
  begin
   //If CaseCollision(VK_UP)=FALSE then
    begin
    	Pos.x := Pos.x+sin(-RY*PI/180)*Move;
    	Pos.z := Pos.z+cos(-RY*PI/180)*Move;
    end;//else
    begin
      Pos.x:=Pos.x+sin(-RY*PI/180)*Move;
     end;
  end;
  If Keys[VK_DOWN] then
  begin
    //If CaseCollision(VK_DOWN)=FALSE then
    begin
      Pos.x := Pos.x-sin(-RY*PI/180)*Move;
      Pos.z := Pos.z-cos(-RY*PI/180)*Move;
    end; //else
    begin
      Pos.x:=Pos.x-sin(-RY*PI/180)*Move;
    end;
  end;
end;
 /////////////////////////////////////////////////////////////////////////////
 procedure check_keyboard_input;{+++drinlassen?*ja*************}

var
     s     : char;

begin
         s:= ' ';
          if Keys[VK_f10] {eigentlich vk_o?} then s:= '0';
         if keys[vk_f1] {eigentlich vk_1?} then s:= '1';
         if keys[vk_f7] {eigentlich vk_7?} then s:= '7';

         if s = '0' then
           begin
             old_status:=status;
             status:=s;
           end;

           if s = '1' then
           begin
             old_status:=status;
             status:=s;
           end;

           if s = '7' then
           begin
             old_status:=status;
             status:=s;
           end
         else { fr¸her: WriteLn('Input ignored.')}
         begin
         //showmessage ('Input ignored');
         end;

end;


 //////////////////////////////////////////////////////////////////////////////

Function WallExists(x,z:Glfloat):Boolean;
var
	i:Integer;
begin
	Result:=FALSE;
  for i:=0 to Cubes do
    if (CubeData[i].x=x)and (CubeData[i].z=z)then
    begin
      Result:=TRUE;
      Exit;
    end;
end;


//************************

procedure build_list; //wird von InitOpenGLin Unit1 aufgerufen


// Achtung: alle L‰ngenangaben (Gangl‰ngen, Kreuzungsmittelpunkte werden f¸r die
// Grafik hier durch 25 geteilt, damit es zu den anderen Systemen passt

// Kreuzungsmittelpunkte: wichtig f¸r lokale Landmarken:
// die Kreuzungsmittelpunkte werden unmittelbar nach dem Einlesen gerade durch 25 geteilt
//
//                     Norden
//                     Kreuzungsmittelpunkt x=0,z=0
//                        +z
//
//
//
//
//  +x                                         -x
//
//
//
//
//                        -z
//                     Kreuzungsmittelpunkt x=0,z=-1000
//                     S¸den




    var
    i: integer; //Y-Zaehler
begin
 maze:=glgenlists(1);
 glnewlist(maze,gl_compile);

 glBindTexture(GL_TEXTURE_2D,blau_gelb);//caro);//Textur festlegen,z.B.wall.jpg
 glBegin(GL_QUADS);

 //ein Y:  Variablen aus Mazefile verwenden

 Ganglaenge:= junction[1].duct_length_grafic[1]+ Gang_Endverlaengerung;
 Radius:= 2* halbe_Gangbreite*cos(30/180*pi)/3;
 //radius des Innenkreis vom Kreuzungsdreieck
 Wandhoehe:=junction[1].duct_wall_height[1];
 obere_Wandhoehe:= junction[1].upper_wall_height[1];
 //Wandbereich ¸ber den eigentlichen Labyrinthw‰nden, f¸r Landmarken
 missing_angle:=99;

Y_Mittelpunkt_x:=0;
Y_Mittelpunkt_z:=0;
V_x:= cos (30/180*pi)* Ganglaenge              + halbe_Gangbreite;
V_z:= sin (30/180*pi)* Ganglaenge + Ganglaenge + 3 * Radius;

wandhoehe:=4;
//wandhoehe:=wandhoehe-6; //sonst schweben die W‰nde
for i:=1 to number_of_junctions do

 begin

      if junction[i].Y_center=1 then

        begin
         Y_Mittelpunkt_x:= junction[i].x_junction;
         Y_Mittelpunkt_z:= junction[i].z_junction;

          if junction[i].number_of_exits = 3 then

            begin
          //0 Grad

     ///3exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand links auﬂen mit der Uhr um 0∞ gedreht
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite)  - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite)   - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite)  - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

   ///3exits, Y_center1, normale Wand////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand links auﬂen mit der Uhr um 0∞ gedreht
   glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite)  - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite)  - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite)   - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite)  - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));


       ///3exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand rechts auﬂen mit der Uhr um 0∞ gedreht

    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       ///3exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand rechts auﬂen mit der Uhr um 0∞ gedreht
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

    //240
   ///3exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links innen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

   ///3exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links auﬂen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));


       ///3exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts innen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       ///3exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts auﬂen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

    //120
     ///3exits, Y_center1, normale Wand///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links innen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

   ///3exits, Y_center1, normale Wand////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links auﬂen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));


       ///3exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts innen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       ///3exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts auﬂen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
        end;    //number_of_exits=3

if junction[i].number_of_exits = 2 then
   begin
   if (junction[i].exit_angle[1]=0) and (junction[i].exit_angle[2]=120) then begin missing_angle:=240; showmessage('2 exits, missing_angle 240∞'); end;
   if (junction[i].exit_angle[1]=0) and (junction[i].exit_angle[2]=240) then begin missing_angle:=120; showmessage('2 exits, missing_angle 120∞'); end;
   if (junction[i].exit_angle[1]=120) and (junction[i].exit_angle[2]=240) then begin missing_angle:=0; showmessage('2 exits, missing_angle 0∞'); end;

     if junction[i].exit_angle[1]=0 then
     begin
    //0 Grad
        ///2exits, Y_center1, normale Wand////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand links auﬂen mit der Uhr um 0∞ gedreht
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

   ///2exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand links auﬂen mit der Uhr um 0∞ gedreht
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));


       ///2exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand rechts auﬂen mit der Uhr um 0∞ gedreht

    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       ///2exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand rechts auﬂen mit der Uhr um 0∞ gedreht
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    end;  //exit_angle=0

    if junction[i].exit_Angle[2]=240 then
    begin

    //240
   ///2exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links innen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

   ///2exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links auﬂen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));


       ///2exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts innen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       ///2exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts auﬂen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
     end;  //exit_angle=240

     if (junction[i].exit_angle[1]=120) or (junction[i].exit_angle[2]=120) then
       begin
    //120
     ///2exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links innen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

   ///2exits, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links auﬂen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));



       ///2exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts innen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       ///2exits, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts auﬂen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
        end;  //exit_angle=120
    end; //number_of_exits=2

 if junction[i].number_of_exits = 1 then
   begin

     if (junction[i].exit_angle[1]=0) then
     begin
    //0 Grad

     ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand links auﬂen mit der Uhr um 0∞ gedreht
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

   ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand links auﬂen mit der Uhr um 0∞ gedreht
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));


       ///1exit, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand rechts auﬂen mit der Uhr um 0∞ gedreht

    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       ///1exit, Y_center1, normale Wand///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // gerade Wand rechts auﬂen mit der Uhr um 0∞ gedreht
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    end; //0∞

    if (junction[i].exit_Angle[1]=240) then
    begin

    //240
   ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links innen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

   ///1exit, Y_center1, normale Wand///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links auﬂen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));


       ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts innen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       ///1exit, Y_center1, normale Wand//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts auﬂen mit der Uhr um 240∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
     end;  //240∞

     if (junction[i].exit_angle[1]=120) then
       begin
    //120
    ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links innen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

    ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links auﬂen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

    ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts innen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

    ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts auﬂen mit der Uhr um 120∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
        end;   //120∞

     if (junction[i].exit_angle[1]=180) then
       begin
    //180
    ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links innen mit der Uhr um 180∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

    ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege links auﬂen mit der Uhr um 180∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

    ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts innen mit der Uhr um 180∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

    ///1exit, Y_center1, normale Wand/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      glNormal3f(-1, 0, 0);   // schraege rechts auﬂen mit der Uhr um 180∞ gedreht    richtige Richtung, noch nicht richtiger Ort   y ist falsch!
    glTexCoord2f(10,10);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((180+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((180+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
        end;   //180∞

      end;  //number_of_exits=1

 //////////////////////////////////////////////////////////////////////////////////////////////////
 //Verschlussw‰nde

if ((junction[i].number_of_exits= 0) or (missing_angle=0) or ((junction[i].number_of_exits=1)and((junction[i].exit_angle[1]=120) or (junction[i].exit_angle[1]=240)))) then

 //0∞-Gang wird verschlossen:

 begin
    glNormal3f(-1, 0, 0);   //  Verschlusswand von innen in Richtung 0∞ , Y_center1
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f  ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f   ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f  ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

       glNormal3f(-1, 0, 0);   // Verschlusswand von auﬂen in Richtung 0∞ , Y_center1
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f  ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f   ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f  ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
end; // 0∞-Gang wird verschlossen

if (junction[i].number_of_exits= 0)or (missing_angle=120) or ((junction[i].number_of_exits=1)and((junction[i].exit_angle[1]=0) or (junction[i].exit_angle[1]=240))) then

     //120∞-Gang wird verschlossen

begin
      glNormal3f(-1, 0, 0);   //  Verschlusswand von innen in Richtung 120∞ , Y_center1
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

      glNormal3f(-1, 0, 0);   // Verschlusswand von auﬂen in Richtung 120∞ , Y_center1
    glTexCoord2f(20,20);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,20);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(20, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
end; //120∞-Gang wird verschlossen

if (junction[i].number_of_exits= 0) or(missing_angle=240) or ((junction[i].number_of_exits=1)and((junction[i].exit_angle[1]=0) or (junction[i].exit_angle[1]=120))) then

  //240∞-Gang wird verschlossen:

begin

      glNormal3f(-1, 0, 0);   //  Verschlusswand von innen in Richtung 240∞ , Y_center1
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

      glNormal3f(-1, 0, 0);   // Verschlusswand von auﬂen in Richtung 240∞ , Y_center1
    glTexCoord2f(20,20);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,20);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(20, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           )- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius           ) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
end; //240∞-Gang wird verschlossen


    missing_angle:=-1;
//    glend;
 end;  //Y_center=1


 ///////////////////////////////////////////////////////////////////////////////////////
 //Verschluﬂw‰nde Y_center = 0
 ///////////////////////////////////////////////////////////////////////////////////////

if junction[i].Y_center=0 then
 //showmessage('Y_center=0');
begin
// glBindTexture(GL_TEXTURE_2D,caro);//blau_gelb);//caro//wall); //Textur festlegen, z.B.wall.jpg
// glBegin(GL_QUADS);


 if (junction[i].number_of_exits= 0) or (missing_angle=0) or ((junction[i].number_of_exits=1)and((junction[i].exit_angle[1]=300) or (junction[i].exit_angle[1]=60))) then

 //0∞-Gang wird verschlossen:

 begin
//showmessage('hallo 0∞ Y_center0 verschlossen...junction');
 //showmessage('number_of_exits' + inttostr(junction[i].number_of_exits));
 //showmessage('exit_angle' + inttostr(junction[i].exit_angle[1]));

//  glTexCoord2f(20,20);glVertex3f (-20.0,-5.0,-60.0);  Beispiel f¸r Wand, Punkte gegen Uhrzeigersinn
//  glTexCoord2f(20, 0);glVertex3f  (20.0,-5.0,-60.0);  Beispiel f¸r Wand, Punkte gegen Uhrzeigersinn
//  glTexCoord2f( 0, 0);glVertex3f  (20.0, 5.0,-60.0);  Beispiel f¸r Wand, Punkte gegen Uhrzeigersinn
//  glTexCoord2f( 0,20);glVertex3f  (-20.0,5.0,-60.0);  Beispiel f¸r Wand, Punkte gegen Uhrzeigersinn

      glNormal3f(-1, 0, 0);   //  Verschlusswand von innen in Richtung 0∞ NEU
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

      glNormal3f(-1, 0, 0);   //  Verschlusswand von auﬂen in Richtung 0∞ NEU
    glTexCoord2f(10,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((0+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((0+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));


end; // 0∞-Gang wird verschlossen

if (junction[i].number_of_exits= 0)or (missing_angle=120) or ((junction[i].number_of_exits=1)and((junction[i].exit_angle[1]=180) or (junction[i].exit_angle[1]=60))) then

     //120∞-Gang wird verschlossen

begin

      glNormal3f(-1, 0, 0);   //  Verschlusswand von innen in Richtung 120∞ NEU
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

      glNormal3f(-1, 0, 0);   //  Verschlusswand von auﬂen in Richtung 120∞ NEU
    glTexCoord2f(10,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((120+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((120+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

     end; //120∞-Gang wird verschlossen

if (junction[i].number_of_exits= 0) or(missing_angle=240) or ((junction[i].number_of_exits=1)and((junction[i].exit_angle[1]=180) or (junction[i].exit_angle[1]=300))) then

  //240∞-Gang wird verschlossen:

begin
      glNormal3f(-1, 0, 0);   //  Verschlusswand von innen in Richtung 120∞ NEU
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

      glNormal3f(-1, 0, 0);   //  Verschlusswand von auﬂen in Richtung 120∞ NEU
    glTexCoord2f(10,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0,10);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x),  Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f( 0, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x-halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));
    glTexCoord2f(10, 0);glVertex3f ((cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) - sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge)- cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x + sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_x), -Wandhoehe, (sin((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_x+halbe_Gangbreite) + cos((240+ alpha_lab)/180*pi)*(Y_Mittelpunkt_z-Radius-Ganglaenge) - sin((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_x - cos((240+ alpha_lab)/180*pi)* Y_Mittelpunkt_z + Y_Mittelpunkt_z));

end; //240∞-Gang wird verschlossen
      missing_angle:=-1;
// glend;
 end; //Y_center = 0
  end;// for i:=1 to number_of_junctions do
   glEnd;
   distal_landmarks;
 local_landmarks;
 glendlist;
end;
 //////////////////////////////////////////////////////////////////////////////
procedure draw_maze_of_labfile(X,Y,Z:GLfloat);

begin  //Variablen aus Labyrinthdefinitionsfile verwenden:

  //glLoadIdentity;
  //glRotatef(RX,1,0,0);
  //glRotatef(RY,0,1,0);
  //glTranslatef(pos.x+X,pos.y+Y,pos.z+Z);
  glcalllist(maze);
  // glcalllist(lmtest);
end; // procedure draw_maze_of_labfile(X,Y,Z:GLfloat)
///////////////////////////////////////////////////////////////////////////////

end.
