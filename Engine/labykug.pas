 unit labykug;


interface

Uses
	lakutpu,Windows, Messages, OpenGL, Dialogs,log,global_variables;

//type

  //end;





var
  durchlnr: integer;  {nur zum testen}
  status_a: char;
  ende: char; {Abbruchbedingung in LabyKug Eingabe von '5'}
(*
 program Laby_Kug;

{!!!!!!!!!!!!!!Wichtig!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Die Labyrinthdefinitionsdatei heisst xxx.txt und muss in einem Unterverzeichnis
mit dem Namen "lab" stehen.
FÅr die Protokolldateien muss ein Unterverzeichnis mit dem Namen labdat angelegt
werden.
Der Abbruch des Programms kann durch drÅcken von "5" ausgelîst werden}

 uses lakutpu, crt;
(*
   var {global}

        junction_id:    Byte;      {aktuelle Kreuzungsnummer}
        old_junction_id:Byte;      {wirklich notwendig???}
        new_junction_id:Boolean;   {wird bei Teleport von Versuch auf true gesetzt}
        junction_id_versuch: Byte; {Kreuzungsnummer, von Versuch gesetzt}
        start_junction: Byte;      {Startkreuzung}
        duct_id:        Byte;      {aktuelle Gangnummer}
        exit_number:    Byte;
        status:         Char;      {Status}
        new_status:     Char;
        weg_1_x:        Integer;   {X-Koordinate von Wegaufnehmer 1}
        weg_1_y:        Integer;   {Y-Koordinate von Wegaufnehmer 1}
        weg_2_x:        Integer;   {X-Koordinate von Wegaufnehmer 2}
        weg_2_y:        Integer;   {Y-Koordinate von Wegaufnehmer 2}
        x_count:        Integer;   {gerundeter Mittelwert aus weg_1_x und weg_2_x}
        y_count:        Integer;   {gerundeter Mittelwert aus weg_1_y und weg_2_y}
        x_count_new:    Boolean;   {neue x-Wegaufnehmerkoordinaten?}
        y_count_new:    Boolean;   {neue y-Wegaufnehmerkoordinaten?}

        cam_x:          shortint;  {X-Koordinate von Kamera, unbehandelter Wert}
        cam_y:          shortint;  {Y-Koordinate von Kamera, unbehandelter Wert}
        x_animal_cam  : Shortint;
        y_animal_cam  : Shortint;  {frÅher:x,y---Kamerakoordinaten des Tieres fÅr Laby}
        x_mitte:        byte;      {Koordinaten auf der Mittellinie des Ganges,}
        y_mitte:        byte;      { bzw Koordinaten des Kreuzungsmittelpunkts}
        motor_x:        byte;      {Spannungswert fÅr Motor x}
        motor_y:        byte;      {Spannungswert fÅr Motor y}

 *)
 {------------------------------------------------------------------
   serielle_Schnittstelle_abfragen
  ------------------------------------------------------------------
       Empfang Wegaufnehmer 1
      3 Byte Adresse und 4Byte Koordinaten (erst 2 fÅr x, dann 2 fÅr y)
               weg_1_x
               weg_1_y

       Empfang Wegaufnehmer 2
       Adresse und 2 Koordinaten
               weg_2_x
               weg_2_y

       Empfang Kamera
       Adresse und 2 Koordinaten

               cam_x
               cam_y

       Senden Motor 1   in LakuTPU
       Adresse und Spannung:
       3 (Modul), 0, 0, 70, 16, 192 (command) + U1 high, U1 low

       Senden Motor 2   in LakuTPU
       Adresse und Spannung:
       3 (Modul), 0, 0, 70, 17, 192 (command) + U1 high, U1 low
       }

  implementation

  procedure wegaufnehmer_simulieren;
   begin
   weg_1_x:= weg_1_x + 10;         {X-Koordinate von Wegaufnehmer 1}
   weg_1_z:=weg_1_z +1;           {Y-Koordinate von Wegaufnehmer 1}
   weg_2_x:=weg_2_x + 2;          {X-Koordinate von Wegaufnehmer 2}
   weg_2_z:=weg_2_z -1;
   end;

   procedure camera_simulieren;

   begin
   cam_x:= cam_x + 5;
   cam_z:= cam_z + 0;
   end;

 {*main************************************************************}

end.



