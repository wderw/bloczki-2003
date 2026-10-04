program Bloczki;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms,
  GraBloki, GraBlok2, Grablok3;

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
