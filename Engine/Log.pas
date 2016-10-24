unit Log;

interface

Uses
	Windows, Messages, SysUtils;

Var
	f:TextFile;

Procedure OpenLog;
Procedure CloseLog;
Procedure AddToLog(s:String;FinishLn,AddDate:Boolean);

implementation

Procedure OpenLog;
begin
  AssignFile(f,'Log.txt');
  Rewrite(f);
  WriteLn(f,'Opening Log at '+DateToStr(Date)+' '+TimeToStr(Time));
end;


Procedure CloseLog;
begin
	WriteLn(f,'Closing Log at '+DateToStr(Date)+' '+TimeToStr(Time));
	CloseFile(f);
end;


Procedure AddToLog(s:String;FinishLn,AddDate:Boolean);
begin
    If AddDate then s:=DateToStr(Date)+' '+TimeToStr(Time)+': '+s;
    If FinishLn then WriteLn(f,s) else Write(f,s);
end;

end.
