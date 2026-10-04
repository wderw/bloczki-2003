program Bloczki;

uses
  Forms,
  GraBloki in 'GraBloki.pas' {Form1},
  GraBlok2 in 'GraBlok2.pas' {Form2},
  Grablok3 in 'Grablok3.pas' {Form3};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
