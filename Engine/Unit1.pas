unit Unit1;      //opengl, Blickrichtung einstellen

interface

Uses Windows, Messages, OpenGL, Textures, Sysutils, MapandVars, Log, FontUnit,
forms, Qdialogs,ppModelGL,ppLoadMS3d,Geometry,GeometryEx,Tex2, global_variables,
mmsystem, variants, Graphics, Controls, Dialogs,
  StdCtrls, ExtCtrls,  IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPServer, Idsockethandle, IdUDPClient,lakutpu,
  SerialNG;
var
  x_z_koordinaten: string;
  WndClass:TWndClass;
  Wnd:HWnd;
  RC:HGLRC;
  DC:HDC;
  mp:TPoint;
	sTime,Frame,NewFrame,
	MyTime,LastFrame:WORD;

  Done:Boolean;
  length_str: string;
  model: TanimatedModelGL;

procedure WinMain;      //für Rechner0, = Versuchssteuerungsrechner
procedure glDraw;
procedure frame_fuer_Hauptschleife;  //ursprünglich ein Teil von winmain
procedure message_fuer_Hauptschleife;  //ursprünglich ein Teil von winmain
procedure killwnd;
procedure draw_model (X,Y,Z:GLfloat);
procedure InitOpenGL;

implementation
function IntToStr(Num:Integer):String;
begin
  str(Num,Result);
end;
////////////////////////////////////////////////////////////////////////
///OPENGL DRAW\\\
procedure glDraw;// wird von allen winmain aufgerufen, Blickwinkel einstellen
var
	i,j:Integer;
        posX_fuer_anzeige:  string;
        posZ_fuer_anzeige:  String;

begin

  Inc(Frame);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glEnable(GL_TEXTURE_2D);
  //original: gluPerspective(45,WinWidth/WinHeight,0.5,250);
  gluPerspective(45,WinWidth/WinHeight,0.5,650);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  RY:=alpha_view; //hier die Blickrichtung einstellen, je nach Rechnernummer
  glRotatef(RY,0,1,0); // later on this won't be necessary
  glEnable(GL_DEPTH_TEST);
  glTranslatef(pos.x,pos.y,pos.z);
  glCullFace(GL_Front); //Seite auf die TExtur gezogen wird
  glCullFace(GL_BACK);
  DrawGroundAndwalls;
  glColor3f(1,1,1);
  draw_maze_of_labfile(0,0,0);
  //drawhex(0,0,0);
  //Koordinatenanzeige auf den Bildschirmrechnern:
  WriteGlText(600,WinHeight-70,WinWidth,WinHeight,PChar
  (' FPS:'+IntToStr(NewFrame)+
  ' pos.x:'+floattostr(pos.x)+
  ' pos.y:'+floattostr(pos.y)+
  ' pos.z:'+floattostr(pos.z)));

   swapBuffers(DC);
end;

///OPENGL INIT\\\
procedure InitOpenGL;        //hier u.a.: Texturen und Landmarken initialisieren
var
  pfd:TPixelFormatDescriptor;
  p:Integer;
begin

  AddToLog('Starting Initialisation of OpenGL...',FALSE,TRUE);
  FillChar(pfd,sizeof(pfd),0);
  DC:=GetDC(Wnd);
  pfd.nSize:=SizeOf(pfd);
  pfd.nVersion:=1;
  pfd.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  pfd.iPixelType:=PFD_TYPE_RGBA;
  pfd.cColorBits:=ColorDepth;
  pfd.cDepthBits:=16;
  p:=ChoosePixelFormat(DC,@pfd);
  SetPixelFormat(DC,p,@pfd);
  RC:=wglCreateContext(DC);
  wglMakeCurrent(DC,RC);
  AddToLog('OK',TRUE,FALSE);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D);
  glEnable(GL_CULL_FACE);
  LoadFont(DC);

  LoadTexture('Data\wall.jpg',Wall,FALSE);
  //  loadtexture( 'Data\caro.jpg',caro,FALSE);
  glBindTexture(GL_TEXTURE_2D,caro);//Textur für den Boden, muss noch skalliert werden mit glTexCoord2f
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  loadtexture( 'Data\caro_mini.jpg',caro,FALSE);
  glBindTexture(GL_TEXTURE_2D,blau_gelb);    //Textur für die Wand, muss noch skalliert werden mit glTexCoord2f
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  loadtexture( 'Data\blau_gelb_mini.jpg',blau_gelb,FALSE);
  // landmark texture
  glBindTexture(GL_TEXTURE_2D,diag);    //Textur für den Boden, muss noch skalliert werden mit glTexCoord2f
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  loadtexture( 'Data\diag.jpg',diag,FALSE);
  //local lm
  glBindTexture(GL_TEXTURE_2D,local_lm_white);    //Textur für den Boden, muss noch skalliert werden mit glTexCoord2f
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  loadtexture( 'Data\local_lm_white.jpg',local_lm_white,FALSE);
  model:=ms3dloadanimatedmodel('\models\model.ms3d');// Milkshape Modell Zylinder wird geladen
  build_list;
end;

///OPENGL RESIZE\\\
procedure ResizeWnd(Width,Height:Integer);
begin
  WinWidth:=Width;
  WinHeight:=Height;
  glViewPort(0,0,width,height);
  glMatrixMode(GL_PROJECTION);    //hier Fehler!!!
  glLoadIdentity;
  gluPerspective(45,width/height,0.5,250);
  glMatrixMode(GL_MODELVIEW);
end;

///OPENGL DESTROY\\\
Procedure KillWnd;
begin
  AddToLog('Starting Exit of All...',TRUE,TRUE);
  If Fullscreen then
  begin
  	If ChangeDisplaySettings(DEVMODE(nil^),0)=0 then AddToLog('Setting to Default Screensettings: OK',TRUE,TRUE) else
    	AddToLog('Setting to Default Screensettings: FAILED',TRUE,TRUE);
  end;
  KillFont;
  wglMakeCurrent(DC,0);
  wglDeleteContext(RC);
  ReleaseDC(Wnd,DC);
  DestroyWindow(Wnd);
  UnRegisterClass('OpenGL',hInstance);
  AddToLog('Destroy of Releases and Exit Application: OK',TRUE,TRUE);
  CloseLog;
end;

//////////////////////////////////////////////////////////////////////////////

///MAINWINDOW-PROC\\\

function WndProc( Wnd:HWND;Msg,wParam,lParam: Integer): Integer; stdcall; // Msg_Timer: TMessage
begin
  Result:=0;

//  if Msg.Msg = Time_Elapsed_Msg  then //Nachricht abfangen
//  begin
//    OnTimer; //Timercode ausführen
//  end;

  case msg of
//  Time_Elapsed_Msg: OnTimer;
    WM_CLOSE:PostQuitMessage(0);
    WM_SIZE:ResizeWnd(LOWORD(lParam),HIWORD(lParam));
    WM_KEYDOWN:keys[wParam]:=TRUE;
    WM_KEYUP:keys[wParam]:=FALSE;
    WM_MOUSEMOVE:
    begin
      GetCursorPos(mp);
      SetCursorPos(WinWidth DIV 2,WinHeight DIV 2);
    	RY:=RY+((mp.x-WinWidth DIV 2)/10);
    	RX:=RX+((mp.y-WinHeight DIV 2)/10);
      If RY>360 then RY:=RY-360;
    	If RY<0 then RY:=360-RY;
    	If RX>90 then RX:=90;
    	If RX<-90 then RX:=-90;
    end
    else Result:=DefWindowProc(Wnd,Msg,wParam,LParam);
  end;


//  inherited;
end;
///////////////////////////////////////////////////////////////////////////////
///MAINWINDOW-LOOP für rechner0\\\
procedure WinMain;
var
  Msg:TMsg;
  //Done:Boolean;   jetzt global
  //FrameTimeStart,help:Integer;     wird jetzt in frame_ fuer_hauptschleife verwendet
  d:DEVMODE;

begin
  Done:=FALSE;
  OpenLog;

  If Fullscreen then begin
    with d do
  	begin
    	dmSize:= SizeOf(d);
   		dmPelsWidth:= resX;
   		dmPelsHeight:= resY;
    	dmBitsPerPel:= ColorDepth;
    	dmFields:=DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
  	end;
  	ChangeDisplaySettings(d,CDS_FULLSCREEN);
      	AddToLog('Change to Fullscreen('+IntToStr(resX)+
      	'x'+IntToStr(resy)+'x'+IntToStr(ColorDepth)+'): OK',TRUE,TRUE);
  end;
  with WndClass do
  begin
    Style:=CS_HREDRAW or CS_VREDRAW;
    hIcon:=LoadIcon(GetModuleHandle(nil),'MAINICON');
    lpfnWndProc:=@WndProc;
    hInstance:=hInstance;
    lpszClassName:='OpenGL';
    hCursor:=LoadCursor(0,IDC_ARROW);
  end;
  RegisterClass(WndClass);
  If Fullscreen then
  Wnd:=CreateWindow('OpenGL','Virtual Treadmill V 0.01',
  		 WS_POPUP,0,0,resX,resY,0,0,hInstance,nil)
  	else Wnd:=CreateWindow('OpenGL','Engine v1.0 by Shadow3D.de.vu',
  		 WS_OVERLAPPEDWINDOW,0,0,resX,resY,0,0,hInstance,nil);

  InitOpenGL;
  ShowWindow(Wnd,SW_SHOW);
  sTime:=GetTickCount;
  SetCursorPos(WinWidth DIV 2,WinHeight DIV 2);
  ShowCursor(false);
  SetForeGroundWindow(wnd);
  SetFocus(wnd);
  end;
   ////////////////////////////////////////////////////////////////////////////
     procedure message_fuer_hauptschleife;

     var
     Msg:TMsg;

     begin
 		if PeekMessage(Msg,0,0,0,PM_REMOVE)then
 		begin
   		if Msg.message=WM_QUIT then Done:=TRUE;
    	                TranslateMessage(Msg);
 			DispatchMessage(Msg);
 		end;
     end;
////////////////////////////////////////////////////////////////////////////

    procedure frame_fuer_hauptschleife; //war früher der letzte Teil von winmain

     var
     FrameTimeStart,help:Integer;

        begin
                MyTime:=GetTickCount-STime;
                FrameTimeStart:=GetTickCount;

                glDraw;
                FrameTime:=GetTickCount-FrameTimeStart;
                If MyTime-LastFrame>=1000 then
  	                begin
  		        NewFrame:=Frame;
  		        Frame:=0;
    	                LastFrame:=MyTime;
  	                end;
        end;
/////////////////////////////////////////////////////////////////////////

 Procedure draw_model (X,Y,Z:GLfloat);  //Baustelle  Bert

 var
 i,j: integer;

 begin
 for i:=1 to number_of_junctions do
 if junction[i].lm_typ1_a[j]= 1 then
         //auch Baustelle: Koordinaten der Landmarken berechnen
        begin

        glLoadIdentity;
        glRotatef(RX,1,0,0);// braucht man wohl nicht
        glRotatef(RY,0,1,0);// auch das hier ist wohl überflüssig
        glTranslatef(pos.x+X,pos.y+Y,pos.z+Z); // jetzige Position (pos.x,y,z)
                                                //wird um XYZ versetzt

        glScalef(0.05,0.05,0.05);
        model.render; // modell rendern
        end;
  end;
end.

