
{
********************[ Delphi OpenGL Template für die Win-Api ]******************

Ein Template ist so etwas wie eine Vorlage oder Schablone. Eine Anwendung,
die die Win-Api nutzt, muss standardmäßig bestimmten Code für Initialisierung
und Message Behandlung enthalten. Für OpenGL gilt das selbe... wer keine
Lust hat den selben Code immer wieder zu benutzen kann dieses Template benutzen.

Folgende standard Methoden sind enthalten:
   glDraw()         -  rendert die Scene (leer!)
   glInit()         -  initialisiert OpenGl
   glResizeWnd()    -  ermöglicht die Veränderung der Fenstergröße zur Laufzeit
   glCreateWnd()    -  Initialisiert das Fenster
   glKillWnd()      -  Löst das Fenster auf
   ProcessKeys()    -  Tastatur-Eingaben werden ausgewertet
   WndProc()        -  übernimmt das Behandeln der Windows-Messages
   WinMain          -  Wie der Name schon sagt. Enthält u.a. die Main-Loop


Dieses Template ist das Grundgerüst für die Win-Api Versionen der DGL-Samples.
(zu bekommen unter http://dgl.thechaoscompany.net)
Teile des Code stammen aus dem Template von Jan Horn (www.sulaco.co.za).

Happy coding!
     Lithander (lithander@gmx.de)

****************************[Version 1.0 22.05.2001]****************************
}

program ms3dTest;

uses
  Windows,
  Messages,
  OpenGL,
  ppModelGL in 'ppModelGL.pas',
  ppLoadms3d in 'ppLoadms3d.pas',
  geometryEx,
  geometry;

const
  WND_TITLE = 'OpenGL Sample';
  FPS_TIMER = 1;                     // Timer zur FPS berechnung
  FPS_INTERVAL = 1000;               // Zeit zwischen FPS-Updates

var
  h_Wnd  : HWND;                     // Handle aufs Fenster
  h_DC   : HDC;                      // Device Context
  h_RC   : HGLRC;                    // OpenGL Rendering Context
  Keys : Array[0..255] of Boolean;   // Tasten-Status des Keyboards
  FPSCount : Integer = 0;            // Frame-Zähler (für FPS berechnen)
  ElapsedTime : Integer;             // Programmlaufzeit
  Finished : Boolean;

  LightAmbient : array[0..3] of Single = (0.5, 0.5, 0.5, 1);
  LightDiffuse : array[0..3] of Single = (1.0, 0.6, 0.5, 1);
  LightSpecular: array[0..3] of Single = (0.0, 0.0, 1.0, 1);
  LightDirection:array[0..2] of Single = (-1, 0, 0);
  LightPosition: array[0..3] of Single = (10.0, 0.0, -10.0, 1);
  gray         : array[0..3] of Single = (1.0, 1.0, 1.0, 1);
  model : TAnimatedModelGL;
  LastFrameTime : Integer;
  angle : integer = 0;
{$R *.RES}

{------------------------------------------------------------------}
{  Konvertiert Integers in Strings                                 }
{------------------------------------------------------------------}
function IntToStr(Num : Integer) : String;  // vermeidet die Benutzung von SysUtils und spart so 100K
begin
  Str(Num, result);
end;


{------------------------------------------------------------------}
{  Zeichnen der Szene                                              }
{------------------------------------------------------------------}
procedure glDraw;
var t : integer;
begin
  glClearColor(0,0,0,0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  // Hier kommt der OpenGL Code rein
  glLoadIdentity;
  gltranslate(0,0,-15);
  inc(angle);
  glRotate(angle,0.0,1,0);
  glScalef(0.1,0.1,0.1);
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @gray);
  t := ElapsedTime - LastFrameTime;
  model.AdvanceAnimation(t);
  model.render;
end;


{------------------------------------------------------------------}
{  Initialisierung von OpenGL                                      }
{------------------------------------------------------------------}
procedure glInit();
begin
  glEnable(GL_TEXTURE_2D);	       // Aktiviert Texture Mapping
  glShadeModel(GL_SMOOTH);	       // Aktiviert weiches Shading
  glClearColor(0.0, 0.0, 0.0, 0.5);    // Bildschirm löschen (schwarz)
  glClearDepth(1.0);		       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);	       // Aktiviert Depth Testing
  glDepthFunc(GL_LEQUAL);	       // Bestimmt den Typ des Depth Testing
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);  // Qualitativ bessere Koordinaten Interpolation
  glLightfv(GL_LIGHT1, GL_AMBIENT, @LightAmbient);
  glLightfv(GL_Light1, GL_DIFFUSE, @LightDiffuse);
  glLightfv(GL_LIGHT1, GL_POSITION, @LightPosition);
  glLightfv(GL_LIGHT1, GL_SPOT_DIRECTION, @LightDirection);
  glLightfv(GL_LIGHT1, GL_SPECULAR, @LightSpecular);
  glEnable(GL_LIGHT1);
  glEnable(GL_LIGHTING);
  glEnable(GL_NORMALIZE);

  model := ms3dLoadAnimatedModel('models\model.ms3d');
  LastFrameTime := ElapsedTime;
end;


{------------------------------------------------------------------}
{  Behandelt Größenveränderung des Fensters                        }
{------------------------------------------------------------------}
procedure glResizeWnd(Width, Height : Integer);
begin
  if (Height = 0) then Height := 1;
  glViewport(0, 0, Width, Height);    // Setzt den Viewport für das OpenGL Fenster
  glMatrixMode(GL_PROJECTION);        // Matrix Mode auf Projection setzen
  glLoadIdentity();                   // Reset View
  gluPerspective(45.0, Width/Height, 1.0, 100.0);  // Perspektive den neuen Maßen anpassen.
  glMatrixMode(GL_MODELVIEW);         // Zurück zur Modelview Matrix
  glLoadIdentity();                   // Reset View
end;


{------------------------------------------------------------------}
{  Tastatur Eingaben verarbeiten                                    }
{------------------------------------------------------------------}
procedure ProcessKeys;
begin
  if (keys[VK_ESCAPE]) then finished := true;
end;


{------------------------------------------------------------------}
{  Message-Behandlung des Programs festlegen                       }
{------------------------------------------------------------------}
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
begin
  case (Msg) of
    WM_CREATE:
      begin
        // Hier kann Zeugs rein das beim Programmstart ausgeführt werden soll
      end;
    WM_CLOSE:
      begin
        PostQuitMessage(0);
        Result := 0
      end;
    WM_KEYDOWN:       // Taste als 'pressed' markieren
      begin
        keys[wParam] := True;
        Result := 0;
      end;
    WM_KEYUP:         // Taste als 'up' markieren
      begin
        keys[wParam] := False;
        Result := 0;
      end;
    WM_SIZE:          // Größe anpassen
      begin
        glResizeWnd(LOWORD(lParam),HIWORD(lParam));
        Result := 0;
      end;
    WM_TIMER :                     // Hier werden alle benutzten Timer behandelt
      begin
        if wParam = FPS_TIMER then
        begin
          FPSCount :=Round(FPSCount * 1000/FPS_INTERVAL);   // FPS berechnen...
          SetWindowText(h_Wnd, PChar(WND_TITLE + '   [' + IntToStr(FPSCount) + ' FPS]')); //... und ausgeben!
          FPSCount := 0;
          Result := 0;
        end;
      end;
    else
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);    //  Standard-Behandlung aller anderen Messages
  end;
end;


{---------------------------------------------------------------------}
{  Freigabe aller Fenster, Zeiger, Variablen                          }
{---------------------------------------------------------------------}
procedure glKillWnd(Fullscreen : Boolean);
begin
  if Fullscreen then begin            // Wenn Vollbild in Standardauflösung zurückkehren
    ChangeDisplaySettings(devmode(nil^), 0);
    ShowCursor(True);
  end;

  // Freigabe des Device und Rendering Contexts.
  if (not wglMakeCurrent(h_DC, 0)) then
    MessageBox(0, 'Release of DC and RC failed!', 'Error', MB_OK or MB_ICONERROR);

  // Löscht Rendering Context
  if (not wglDeleteContext(h_RC)) then begin
    MessageBox(0, 'Release of rendering context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_RC := 0;
  end;

  // Gibt Device Context fre
  if ((h_DC > 0) and (ReleaseDC(h_Wnd, h_DC) = 0)) then  begin
    MessageBox(0, 'Release of device context failed!', 'Error', MB_OK or MB_ICONERROR);
    h_DC := 0;
  end;

  // Schließt das Fenster
  if ((h_Wnd <> 0) and (not DestroyWindow(h_Wnd))) then begin
    MessageBox(0, 'Unable to destroy window!', 'Error', MB_OK or MB_ICONERROR);
    h_Wnd := 0;
  end;

  // Entfernt window class Registrierung
  if (not UnRegisterClass('OpenGL', hInstance)) then begin
    MessageBox(0, 'Unable to unregister window class!', 'Error', MB_OK or MB_ICONERROR);
    hInstance := 0;
  end;
end;


{--------------------------------------------------------------------}
{  Erstellt ein Fenster mit Passendem OpenGL Rendering Context       }
{--------------------------------------------------------------------}
function glCreateWnd(Width, Height : Integer; Fullscreen : Boolean; PixelDepth : Integer) : Boolean;
var
  wndClass : TWndClass;         // Fenster Klasse
  dwStyle : DWORD;              // Fenster Stil
  dwExStyle : DWORD;            // Erweiterter Fenster Stil
  dmScreenSettings : DEVMODE;   // Bildschirm Einstellungen (fullscreen, etc...)
  PixelFormat : GLuint;         // OpenGL Einstellungen (Pixelformat)
  h_Instance : HINST;           // aktuelle Instanz
  pfd : TPIXELFORMATDESCRIPTOR;  // Einstellungen für das OpenGL Fenster
begin
  h_Instance := GetModuleHandle(nil);       // Instanz für's Fenster holen
  ZeroMemory(@wndClass, SizeOf(wndClass));  // Daten in wndClass löschen

  with wndClass do                    // Setup der Fenster Klasse
  begin
    style         := CS_HREDRAW or    // Neuzeichenen wenn Fenster-Breite geändert
                     CS_VREDRAW or    // Neuzeichenen wenn Fenster-Höhe geändert
                     CS_OWNDC;        // Device Context exlusiv
    lpfnWndProc   := @WndProc;        // WndProc wird als Window Procedure gesetzt
    hInstance     := h_Instance;
    hCursor       := LoadCursor(0, IDC_ARROW);
    lpszClassName := 'OpenGL';
  end;

  if (RegisterClass(wndClass) = 0) then  // Fenster Klasse registrieren
  begin
    MessageBox(0, 'Failed to register the window class!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit
  end;

  // Vollbild wenn Parameter Fullscreen = true
  if Fullscreen then
  begin
    ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
    with dmScreenSettings do begin              // Bildschirm Einstellungen werden festgelegt
      dmSize       := SizeOf(dmScreenSettings);
      dmPelsWidth  := Width;                    // Fenster Breite
      dmPelsHeight := Height;                   // Fenster Höhe
      dmBitsPerPel := PixelDepth;               // Farbtiefe (32bit etc)
      dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
    end;

    // Bilschirm Modus auf Vollbild setzen
    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
    begin
      MessageBox(0, 'Unable to switch to fullscreen!', 'Error', MB_OK or MB_ICONERROR);
      Fullscreen := False;
    end;
  end;

  // Wenn wir immer noch im Vollbildmodus sind....
  if (Fullscreen) then
  begin
    dwStyle := WS_POPUP or                // Popup Fenster Stil
               WS_CLIPCHILDREN            // Kein Zeichnen in Child Fenstern
               or WS_CLIPSIBLINGS;        // Kein Zeichnen in Sibling Fenstern
    dwExStyle := WS_EX_APPWINDOW;         // Fenster im Vordergrund
    ShowCursor(False);                    // Mauszeiger verstecken
  end
  else // Für Normale Fenster
  begin
    dwStyle := WS_OVERLAPPEDWINDOW or     // Überschneidung zulassen
               WS_CLIPCHILDREN or         // Kein Zeichnen in Child Fenstern
               WS_CLIPSIBLINGS;           // Kein Zeichnen in Sibling Fenstern
    dwExStyle := WS_EX_APPWINDOW or       // Fenster im Fordergrund
                 WS_EX_WINDOWEDGE;        // Erhobener Rand
  end;

  // Das oben definierte Fenster wird erstellt
  h_Wnd := CreateWindowEx(dwExStyle,      // Erweiterter Fenster Stil
                          'OpenGL',       // Name der Klasse
                          WND_TITLE,      // Fenster Titel (caption)
                          dwStyle,        // Fenster Stil
                          0, 0,           // Fenster Position
                          Width, Height,  // Größe des Fensters
                          0,              // Keine Paren-Windows
                          0,              // Kein Menü
                          h_Instance,     // die Instanz
                          nil);           // Kein Parameter für WM_CREATE
  if h_Wnd = 0 then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to create window!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Den Device Kontext unseres Fensters besorgen
  h_DC := GetDC(h_Wnd);
  if (h_DC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Das Pixelformat einstellen
  with pfd do
  begin
    nSize           := SizeOf(TPIXELFORMATDESCRIPTOR); // Größe des Pixel Format Descriptor
    nVersion        := 1;                    // Version des Daten Structs
    dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer erlaubt zeichenen auf Fenster
                       or PFD_SUPPORT_OPENGL // Buffer unterstützt OpenGL drawing
                       or PFD_DOUBLEBUFFER;  // Double Buffering benutzen
    iPixelType      := PFD_TYPE_RGBA;        // RGBA Farbformat
    cColorBits      := PixelDepth;           // OpenGL Farbtiefe
    cRedBits        := 0;
    cRedShift       := 0;
    cGreenBits      := 0;
    cGreenShift     := 0;
    cBlueBits       := 0;
    cBlueShift      := 0;
    cAlphaBits      := 0;                    // Not supported
    cAlphaShift     := 0;                    // Not supported
    cAccumBits      := 0;                    // Kein Accumulation Buffer
    cAccumRedBits   := 0;
    cAccumGreenBits := 0;
    cAccumBlueBits  := 0;
    cAccumAlphaBits := 0;
    cDepthBits      := 16;                   // Genauigkeit des Depht-Buffers
    cStencilBits    := 0;                    // Stencil Buffer ausschalten
    cAuxBuffers     := 0;                    // Not supported
    iLayerType      := PFD_MAIN_PLANE;       // Wird Ignoriert!
    bReserved       := 0;                    // Anzahl der Overlay und Underlay Planes
    dwLayerMask     := 0;                    // Wird Ignoriert!
    dwVisibleMask   := 0;                    // Transparente Farbe der Underlay Plane
    dwDamageMask    := 0;                    // Wird Ignoriert!
  end;

  // Gibt ein unterstützes Pixelformat zurück das dem geforderten so gut wie möglich enspricht
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Das Pixelformat unseres Device Kontexts wird durch das neue ersetzt
  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // OpenGL Rendering Context wird erstellt
  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Der OpenGL Rendering Context wird aktiviert
  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    glKillWnd(Fullscreen);
    MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Initialisierung des Timers zur FPS-Berechnung
  SetTimer(h_Wnd, FPS_TIMER, FPS_INTERVAL, nil);

  // Das Fenster wird in Vordergrund gebracht
  ShowWindow(h_Wnd, SW_SHOW);
  SetForegroundWindow(h_Wnd);
  SetFocus(h_Wnd);

  // Das Fenster bekommt nochmal die Größe zugewiesen um OpenGl richtig zu initialisieren
  glResizeWnd(Width, Height);
  glInit();

  Result := True;
end;


{--------------------------------------------------------------------}
{  Main message loop for the application                             }
{--------------------------------------------------------------------}
function WinMain(hInstance : HINST; hPrevInstance : HINST;
                 lpCmdLine : PChar; nCmdShow : Integer) : Integer; stdcall;
var
  msg : TMsg;
  appStart : DWord;
begin
  Finished := False;

  // Das Programm wird initialisiert (Fenster erstellen!)
  if not glCreateWnd(800, 600, FALSE, 32) then
  begin
    Result := 0;
    Exit;
  end;

  appStart := GetTickCount();            // Die Zeit zum Programmstart nehmen

  // Main message loop:
  while not finished do
  begin
    if (PeekMessage(msg, 0, 0, 0, PM_REMOVE)) then // Nach Windows-Messages suchen
    begin
      if (msg.message = WM_QUIT) then     // Falls WM_QUIT dabei ist sind wir fertig
        finished := True
      else
      begin                               // Ansonsten wird die Message an das Programm weitergegeben
  	TranslateMessage(msg);
        DispatchMessage(msg);
      end;
    end
    else
    begin
      Inc(FPSCount);                      // FPS Zähler erhöhen

      LastFrameTime := ElapsedTime;
      ElapsedTime := GetTickCount() - appStart;     // Programmlaufzeit berechnen


      glDraw();                           // Szene zeichnen
      SwapBuffers(h_DC);                  // Szene ausgeben

      ProcessKeys;                      // Tastatureingaben verarbeiten

    end;
  end;
  glKillWnd(FALSE);
  Result := msg.wParam;
end;


begin
  WinMain( hInstance, hPrevInst, CmdLine, CmdShow );
end.
