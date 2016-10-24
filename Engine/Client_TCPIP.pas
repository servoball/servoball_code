
unit Client_TCPIP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, global_variables;

type
  TFrmClient = class(TForm)
    BtVerbinden: TButton;
    MemStatus: TMemo;
    ClientSocket: TClientSocket;
    Button1: TButton;
    Button2: TButton;
    procedure BtVerbindenClick (Sender: TObject);
    procedure ClientSocketConnect (Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketRead (Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnecting (Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketError (Sender: TObject; Socket: TCustomWinSocket;
                                  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketLookup (Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect (Sender: TObject; Socket: TCustomWinSocket);
        procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
   private
  //  Verbunden: Boolean;
  public
    { Public-Deklarationen }
  end;

var FrmClient: TFrmClient;

implementation

{$R *.dfm}

procedure TFrmClient.BtVerbindenClick(Sender: TObject);
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
     end
end;

procedure TFrmClient.ClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
begin
  MemStatus.Lines.Add ('Status: Server wird gesucht')
end;

procedure TFrmClient.ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  MemStatus.Lines.Add ('Status: Verbindung wird aufgebaut')
end;

procedure TFrmClient.ClientSocketConnect (Sender: TObject; Socket: TCustomWinSocket);
begin
  MemStatus.Lines.Add ('Status: Verbindung hergestellt');
end;

procedure TFrmClient.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var
meldung_vom_server: string;
meldung_vom_server_x, meldung_vom_server_Z:string;
sem: boolean;
i:integer;
begin
  // MemStatus.Lines.Add (Socket.ReceiveText)

  meldung_vom_server:=socket.ReceiveText;
  MemStatus.Lines.Add(meldung_vom_server);
  //if meldung_vom_server ='referenceEnd'then ClientSocket.socket.SendText ('segment');
 sem:=false;
  for i:= 5 to length(meldung_vom_server) do          //pos abschneiden
        begin
        if sem then meldung_vom_server_Z:=meldung_vom_server_Z+meldung_vom_server[i]
                else
                if meldung_vom_server[i]=' ' then sem:=true
                else meldung_vom_server_x:=meldung_vom_server_x+meldung_vom_server[i];


        end;
        ClientSocket.socket.SendText (meldung_vom_server_x);
        ClientSocket.socket.SendText (meldung_vom_server_z);


  end;

procedure TFrmClient.ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
                                       ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  MemStatus.Lines.Add ('Status: Fehler ' + IntToStr(ErrorCode));
  ErrorCode := 0;
end;

procedure TFrmClient.ClientSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  MemStatus.Lines.Add ('Status: Verbindung wird getrennt')
end;

procedure TFrmClient.Button1Click(Sender: TObject);
var
TCP_senden:string;
begin
 //TCP_senden:='segment';
//ClientSocket.socket.sendbuf(TCP_senden,sizeof(TCP_senden));
ClientSocket.socket.SendText ('reference');

end;

procedure TFrmClient.Button2Click(Sender: TObject);
begin
ClientSocket.socket.SendText ('segment');
end;

end.

 