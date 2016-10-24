unit Unit5;         //Verbindung TCPIP mit Basler Kamera

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, ScktComp,global_variables, ExtCtrls;

type
  TForm5 = class(TForm)
    MemStatus: TMemo;
    ClientSocket: TClientSocket;
    BtVerbinden: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    min_object_size: TLabeledEdit;
    Button4: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    set_min_object: TButton;
    MaxGrayVal: TLabeledEdit;
    set_Max_Gray: TButton;
    get_Max_Gray: TButton;
    MinGrayVal: TLabeledEdit;
    set_Min_Gray: TButton;
    get_Min_Gray: TButton;
    all_Settings: TButton;
    Button5: TButton;
    circle_param: TLabeledEdit;
    SetCenter: TLabeledEdit;
    Button9: TButton;
    Button10: TButton;

    procedure ClientSocketConnect (Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketRead (Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnecting (Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketError (Sender: TObject; Socket: TCustomWinSocket;
                                  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketLookup (Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect (Sender: TObject; Socket: TCustomWinSocket);

 
   procedure ClientSocket1Connect(Sender: TObject;
     Socket: TCustomWinSocket);
    procedure Bt_VerbindenClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
//    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure set_min_objectClick(Sender: TObject);
    procedure set_Max_GrayClick(Sender: TObject);
    procedure get_Max_GrayClick(Sender: TObject);
    procedure set_Min_GrayClick(Sender: TObject);
    procedure all_SettingsClick(Sender: TObject);
    procedure get_Min_GrayClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
  
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.Bt_VerbindenClick(Sender: TObject);

 begin
   if Verbunden
     then begin
       Verbunden := False;
       ClientSocket.Close;
       BtVerbinden.Caption := 'Mit Server verbinden';

     end
     else begin
       Verbunden := True;
       ClientSocket.Host := '127.0.0.1';//'localhost';  //127.0.0.1
       ClientSocket.Port :=10000;//8181;//10000;   //für segment-server
       ClientSocket.Open;
       BtVerbinden.Caption := 'Vom Server trennen';
       meldung_vom_server_x:=1000;     //zum initialisieren
       meldung_vom_server_z:=1000;
       //ClientSocket.socket.SendText ('reference');

     end
end;


procedure TForm5.ClientSocket1Connect(Sender: TObject; Socket: TCustomWinSocket);

begin
MemStatus.Lines.Add ('Status: Verbindung hergestellt');
end;

procedure TForm5.ClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
begin
  MemStatus.Lines.Add ('Status: Server wird gesucht')
end;

procedure TForm5.ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  MemStatus.Lines.Add ('Status: Verbindung wird aufgebaut')
end;

procedure TForm5.ClientSocketConnect (Sender: TObject; Socket: TCustomWinSocket);
begin
  MemStatus.Lines.Add ('Status: Verbindung hergestellt');
end;

procedure TForm5.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var
meldung_vom_server, s: string;
dummy_meldung_vom_server_x, dummy_meldung_vom_server_z: string ;
sem: boolean;
cr:boolean;
i,j:integer;
begin
  // MemStatus.Lines.Add (Socket.ReceiveText)
  // alles zurücksetzen, vielleicht hilft das
  meldung_vom_server:='';
  meldung_vom_server_global:='';
  dummy_meldung_vom_server_x := '';
  dummy_meldung_vom_server_z := '';


  meldung_vom_server:=socket.ReceiveText;
  meldung_vom_server_global:= meldung_vom_server; //für Dokumantationsdatei
  MemStatus.Lines.Add(meldung_vom_server);
 // if meldung_vom_server ='referenceEnd'then ClientSocket.socket.SendText ('segment');
 // s:= meldung_vom_server[1..4]

 // pos [leer] x [leer] y
 // ASCII: 45= -
 //        48 bis 57 = Ziffern  0 bis 9
 i:= 5;
 if meldung_vom_server[1] = 'p' then
    begin
        //X-Koordinate
      while (ord(meldung_vom_server[i]) >= 48) and (ord(meldung_vom_server[i]) <= 57)
         or (ord(meldung_vom_server[i]) = 45) do
         begin
           dummy_meldung_vom_server_x:= dummy_meldung_vom_server_x+meldung_vom_server[i];
           inc(i);
           if i > 10 then break;
         end;

        //Leerzeichen zur Trennung
         if ord(meldung_vom_server[i]) = 32 then inc(i);

         //Z-Koordinate
       while (ord(meldung_vom_server[i]) >= 48) and (ord(meldung_vom_server[i]) <= 57)
         or (ord(meldung_vom_server[i]) = 45) do
         begin
         dummy_meldung_vom_server_z:= dummy_meldung_vom_server_z+meldung_vom_server[i];
         inc(i);
         if i > 15 then break;
         end;

   end;

   if ((length(dummy_meldung_vom_server_x)>0) and  (length(dummy_meldung_vom_server_z)>0))
       then
       begin
       meldung_vom_server_x:=strtoint(dummy_meldung_vom_server_x);
       meldung_vom_server_z:=strtoint(dummy_meldung_vom_server_z);
       end;
   MemStatus.Lines.Add ('server_x='+dummy_meldung_vom_server_x);
   MemStatus.Lines.Add ('server_z='+dummy_meldung_vom_server_z);



//for j:=0 to 20 do  meldung_vom_server[j]:=' ';

end;

procedure TForm5.ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
                                      ErrorEvent: TErrorEvent; var ErrorCode: Integer);

var
error_time: int64;
begin

  //Error_time:=timegettime;
  MemStatus.Lines.Add ('Status: Fehler ' + IntToStr(ErrorCode)+' Error_time '+DateTimeToStr(Now));
  ErrorCode := 0;

end;

procedure TForm5.ClientSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  MemStatus.Lines.Add ('Status: Verbindung wird getrennt')
end;

 //////////////////////////////////////////////////////////7



procedure TForm5.Button1Click(Sender: TObject);
begin
 ClientSocket.socket.SendText ('reference');
  MemStatus.Lines.Add('reference gesendet');
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
ClientSocket.socket.SendText ('segment');
MemStatus.Lines.Add('segment gesendet');
end;

procedure TForm5.Button3Click(Sender: TObject);
begin
ClientSocket.socket.SendText ('quit');
MemStatus.Lines.Add('quit gesendet');
end;

procedure TForm5.FormCreate(Sender: TObject);


begin
//min_pixel muss zwischen 1 und 1000 liegeb

min_pixel_str:=form5.min_object_size.text;
min_pixel_int:= strtoint(min_pixel_str);
if (min_pixel_int<1) or (min_pixel_int>10000) then
MemStatus.Lines.Add('ungültiger Min_pixel_Wert');

MaxGrayValue:=form5.MaxGrayVal.text;
MinGrayValue:=form5.MinGrayVal.text;
end;

procedure TForm5.Button6Click(Sender: TObject);
var circle_param: string;
begin
circle_param:=form5.circle_param.text;

ClientSocket.socket.SendText ('setCircleParam '+circle_param);

//ClientSocket.socket.SendText ('setCircleParam 321 189 240'); // 'setCircleParam row colum rad'
MemStatus.Lines.Add('setCircleParam gesendet: '+'321 189 240');

end;

procedure TForm5.Button7Click(Sender: TObject);
begin
ClientSocket.socket.SendText ('getMinObject');

end;

procedure TForm5.Button8Click(Sender: TObject);
begin
 ClientSocket.socket.SendText ('circleParam');
end;

procedure TForm5.set_min_objectClick(Sender: TObject);
begin
min_pixel_str:=form5.min_object_size.text;

min_pixel_int:= strtoint(min_pixel_str);
if (min_pixel_int<1) or (min_pixel_int>10000) then
MemStatus.Lines.Add('ungültiger Min_pixel_Wert');

ClientSocket.socket.SendText ('setMinObject '+ min_pixel_str);
MemStatus.Lines.Add('setMinObject size gesendet: '+ min_pixel_str);
end;

procedure TForm5.set_Max_GrayClick(Sender: TObject);
begin
MaxGrayValue:=form5.MaxGrayVal.text;
ClientSocket.socket.SendText ('setMaxGrayVal '+ MaxGrayValue);
MemStatus.Lines.Add('setMaxGrayVal gesendet: '+ MaxGrayValue);
end;

procedure TForm5.get_Max_GrayClick(Sender: TObject);
begin
ClientSocket.socket.SendText ('getMaxGrayVal');
end;

procedure TForm5.set_Min_GrayClick(Sender: TObject);
begin
MinGrayValue:=form5.MinGrayVal.text;
ClientSocket.socket.SendText ('setMinGrayVal '+ MinGrayValue);
MemStatus.Lines.Add('setMinGrayVal gesendet: '+MinGrayValue);
end;

procedure TForm5.all_SettingsClick(Sender: TObject);
begin
ClientSocket.socket.SendText ('setMinObject '+ min_pixel_str);

ClientSocket.socket.SendText ('setCircleParam 321 189 240');

ClientSocket.socket.SendText ('setMaxGrayVal '+ MaxGrayValue);

ClientSocket.socket.SendText ('setMinGrayVal '+ MinGrayValue);

end;

procedure TForm5.get_Min_GrayClick(Sender: TObject);
begin
ClientSocket.socket.SendText ('getMinGrayVal');
end;

procedure TForm5.Button5Click(Sender: TObject);
begin
ClientSocket.socket.SendText ('stopSegment');
end;

procedure TForm5.Button9Click(Sender: TObject);
begin
ClientSocket.socket.SendText ('getCenter');
end;

procedure TForm5.Button10Click(Sender: TObject);
var
strXY: string;

begin
strXY:= form5.SetCenter.Text;
 ClientSocket.socket.SendText ('setCenter '+ strXY);
 MemStatus.Lines.Add('setCenter gesendet: '+ strXY);
end;

end.
