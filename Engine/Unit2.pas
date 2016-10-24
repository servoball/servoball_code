unit Unit2;
// Anzeige der Tränkenbesuche und der Belohnungen
interface
           
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, global_variables;

type
  TForm2 = class(TForm)
    Circle: TShape;
    Unit1: TStaticText;
    Unit2: TStaticText;
    Unit3: TStaticText;
    Unit4: TStaticText;
    Unit5: TStaticText;
    Unit6: TStaticText;
    Attempt1: TLabel;
    Reward1: TLabel;
    Attempt1_value: TLabel;
    Reward1_value: TLabel;
    Attempt2: TLabel;
    Reward2: TLabel;
    Attempt2_value: TLabel;
    Reward2_value: TLabel;
    Attempt3: TLabel;
    Reward3: TLabel;
    Attempt3_value: TLabel;
    Reward3_value: TLabel;
    Attempt6: TLabel;
    Reward6: TLabel;
    Attempt6_value: TLabel;
    Reward6_value: TLabel;
    Attempt5: TLabel;
    Reward5: TLabel;
    Attempt5_value: TLabel;
    Reward5_value: TLabel;
    Attempt4: TLabel;
    Reward4: TLabel;
    Attempt4_value: TLabel;
    Reward4_value: TLabel;
    RatNumComboBox: TComboBox;
    RatLabel: TLabel;

    
    procedure CloseButtonClick(Sender: TObject);
    procedure RatNumComboBoxSelect(Sender: TObject);


  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.CloseButtonClick(Sender: TObject);
begin
     Form2.Close;
end;


procedure TForm2.RatNumComboBoxSelect(Sender: TObject);
var
  choice     : integer;
  a1, a2, a3, a4, a5, a6, r1, r2, r3, r4, r5, r6 : integer;
  cyclecount : byte; // forloop variable.
begin
    //Need to change values when available
    if (RatNumComboBox.Text = 'Total') then
    begin
        //Clear variables.
        for cyclecount := 1 to 6 do
        begin
           a1 := 0; a2 := 0; a3 := 0; a4 := 0; a5 := 0; a6 := 0;
           r1 := 0; r2 := 0; r3 := 0; r4 := 0; r5 := 0; r6 := 0;
        end; // end forloop.

        //Calculate the total values for each Unit.
        for cyclecount := 1 to 6 do
        begin
           a1 := a1 + Reward_Rec[cyclecount].feeder_attempt_arr[1];
           a2 := a2 + Reward_Rec[cyclecount].feeder_attempt_arr[2];
           a3 := a3 + Reward_Rec[cyclecount].feeder_attempt_arr[3];
           a4 := a4 + Reward_Rec[cyclecount].feeder_attempt_arr[4];
           a5 := a5 + Reward_Rec[cyclecount].feeder_attempt_arr[5];
           a6 := a6 + Reward_Rec[cyclecount].feeder_attempt_arr[6];
           r1 := r1 + Reward_Rec[cyclecount].feeder_count_arr[1];
           r2 := r2 + Reward_Rec[cyclecount].feeder_count_arr[2];
           r3 := r3 + Reward_Rec[cyclecount].feeder_count_arr[3];
           r4 := r4 + Reward_Rec[cyclecount].feeder_count_arr[4];
           r5 := r5 + Reward_Rec[cyclecount].feeder_count_arr[5];
           r6 := r6 + Reward_Rec[cyclecount].feeder_count_arr[6];
        end; // end for loop.

        // Display onto Form2
        Attempt1_value.Caption := IntToStr(a1);
        Attempt2_value.Caption := IntToStr(a2);
        Attempt3_value.Caption := IntToStr(a3);
        Attempt4_value.Caption := IntToStr(a4);
        Attempt5_value.Caption := IntToStr(a5);
        Attempt6_value.Caption := IntToStr(a6);

        Reward1_value.Caption := IntToStr(r1);
        Reward2_value.Caption := IntToStr(r2);
        Reward3_value.Caption := IntToStr(r3);
        Reward4_value.Caption := IntToStr(r4);
        Reward5_value.Caption := IntToStr(r5);
        Reward6_value.Caption := IntToStr(r6);
    end else
    begin // Anything but 'Total'
        choice := StrToInt(RatNumComboBox.Text);  // rat_num
                                                            
        Attempt1_value.Caption := IntToStr(Reward_Rec[choice].feeder_attempt_arr[1]);
        Attempt2_value.Caption := IntToStr(Reward_Rec[choice].feeder_attempt_arr[2]);
        Attempt3_value.Caption := IntToStr(Reward_Rec[choice].feeder_attempt_arr[3]);
        Attempt4_value.Caption := IntToStr(Reward_Rec[choice].feeder_attempt_arr[4]);
        Attempt5_value.Caption := IntToStr(Reward_Rec[choice].feeder_attempt_arr[5]);
        Attempt6_value.Caption := IntToStr(Reward_Rec[choice].feeder_attempt_arr[6]);

        Reward1_value.Caption := IntToStr(Reward_Rec[choice].feeder_count_arr[1]);
        Reward2_value.Caption := IntToStr(Reward_Rec[choice].feeder_count_arr[2]);
        Reward3_value.Caption := IntToStr(Reward_Rec[choice].feeder_count_arr[3]);
        Reward4_value.Caption := IntToStr(Reward_Rec[choice].feeder_count_arr[4]);
        Reward5_value.Caption := IntToStr(Reward_Rec[choice].feeder_count_arr[5]);
        Reward6_value.Caption := IntToStr(Reward_Rec[choice].feeder_count_arr[6]);
    end;
end; // end procedure.

end. // end of file. Unit2.
