unit GraBloki;

{$mode delphi}{$H+}{$codepage utf8}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus;

type cegla = record
        LP : Byte;                   // liczba punktów tworzących cegiełkę
         P : Array[1..10] of TPoint; // punkty tworzące kształt cegiełki
     Kolor : Tcolor;                 // kolor cegiełki
     end;

type
  TKierunekPoziomy = (kpLewo, kpPrawo);


type
  TForm1 = class(TForm)
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    Pomoc1: TMenuItem;
    Klawiszologia1: TMenuItem;
    Pliki1: TMenuItem;
    onieczabawyspadajcymicegiekami1: TMenuItem;
    Ustawienia1: TMenuItem;
    Szybkie1: TMenuItem;
    Ogrze1: TMenuItem;
    Rozmiarcegieek1: TMenuItem;
    Strasznekobyy1: TMenuItem;
    Dlaprzedszkolakw1: TMenuItem;
    Normalne1: TMenuItem;
    Dlaprofesjonalistw1: TMenuItem;
    Grawitacja1: TMenuItem;
    Image1: TImage;
    Image2: TImage;
    SP1: TMenuItem;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    procedure Zrobkwadracik ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
    procedure Zrobzetuszke ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
    procedure ZrobZetke (NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
    procedure ZrobTetke ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
    procedure ZrobElke ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
    procedure ZrobKropka ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
    function  CzyMozeSpadac(Obiekt : Array of TPoint; LP:Byte; Sender:TObject):Boolean;
    procedure ZrobCetke (NR,X,Y : Integer;Kolor:TColor; Sender:TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure LosujElement1 (Sender:TObject);
    function  Obroocony (Obiekt : Cegla; Sender:Tobject):Cegla;
    procedure PrzeunWszystkieCegielki (Sender:TObject);
    procedure MalujWszystkieCegielki (Sender:TObject);
    procedure RysujSiatke (Sender:TOBject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    function  CzyGameOver (Sender:TObject):Boolean;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Klawiszologia1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure onieczabawyspadajcymicegiekami1Click(Sender: TObject);
    procedure Szybkie1Click(Sender: TObject);
    procedure Ogrze1Click(Sender: TObject);
    function  SprawdzWypelnieniePlanszy (Sender:TOBject):Integer;
    procedure Strasznekobyy1Click(Sender: TObject);
    procedure RestartGry (Sender:TObject);
    procedure Dlaprzedszkolakw1Click(Sender: TObject);
    procedure Normalne1Click(Sender: TObject);
    procedure Dlaprofesjonalistw1Click(Sender: TObject);
    procedure Grawitacja1Click(Sender: TObject);
    procedure SP1Click(Sender: TObject);
    function  CzyMoznaWPrawo (Sender:TOBject):Boolean;
    function  CzyMoznaWLewo (Sender:TOBject):Boolean;

  private
    { Private declarations }
    function CzyMoznaPrzesunacPoziomo(
      Kierunek: TKierunekPoziomy): Boolean;
    function CzyPunktWewnatrzCegly(const SprawdzanaCegla: Cegla;
      PunktX, PunktY: Integer): Boolean;
    function CzyCeglyNakladajaSie(const PierwszaCegla,
      DrugaCegla: Cegla): Boolean;
    function CzyMoznaObrocic(const ObroconaCegla: Cegla): Boolean;
    procedure ZakonczGre;
    procedure UsunWypelnioneWiersze;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses GraBlok2, Grablok3;

{$R *.lfm}

const LMarg      = 10;
      PMarg      = 70;                             // prawy na owocki
      GMarg      = 10;
      MaxLiczbaC = 3000;                           // max. liczba cegiełek

var     Cegielki : Array[1..MaxLiczbaC] of Cegla;  // cegiełki
      NrCegielki : Integer;                        // numer aktualnej cegiełki
     TajnaKartka : TBitmap;                        // deklaracja bitmapki
      SieRuszaja : Boolean;                        // 1 bezpiecznik generatora
      BylKlawisz : Boolean;                        // 2 bezpiecznik generatora
      GraZakonczona : Boolean;
      CeglaZamrozona : array[1..MaxLiczbaC] of Boolean;
      Xstart     : Integer;
      Vtimera    : Integer;
           SzerC : Integer;                         // rozmiary podstawowej kostki
       Punktacja : Integer;
     PunktcjaStr : String;
         MaxSzer : Integer;


procedure TForm1.FormCreate(Sender: TObject);
begin
  TajnaKartka:=TBitmap.Create;           // tworzenie niewidocznej bitmapki
  TajnaKartka.Height:=Form1.Height;      // wysokość niewidocznej bitmapki
  TajnaKartka.Width:=Form1.Width;        // szerokość niewidocznej bitmapki
  TajnaKartka.Canvas.Font.Name:='Impact';
  TajnaKartka.Canvas.Font.Size:=24;
  TajnaKartka.Canvas.Font.Color:=clGray;
  BylKlawisz:=False;                     // do zabezpieczenia losowania cegiełek
  SieRuszaja:=false;                     // do zabezpieczenia losowania cegiełek
  GraZakonczona:=False;
  NrCegielki:=0;                         // nie ma żadnej cegiełki
  Randomize;                             // uruchomienie generatora liczb losowych
  SzerC:=21;                             // wielkość cegiełki
  Vtimera:=500;  
  RestartGry(Sender);
end;

procedure TForm1.RestartGry (Sender:TObject);
var i,j : Integer;
begin
  for i:=1 to NrCegielki do
  begin
    for j:=1 to 10 do
    begin
      Cegielki[i].P[j].X:=0;
      Cegielki[i].P[j].Y:=0;
    end;
  end;
  TajnaKartka.Canvas.Brush.Color:=clSilver;
  TajnaKartka.Canvas.Rectangle(-1,-1,TajnaKartka.Width,TajnaKartka.Height);
  Sleep(500);
  Form1.Caption:='Nasze własne cegiełki';
  Punktacja:=0;
  Str(Punktacja,PunktcjaStr);
  while Length(PunktcjaStr)<4 do PunktcjaStr:=' '+PunktcjaStr;
  GraZakonczona:=False;
  FillChar(CeglaZamrozona,SizeOf(CeglaZamrozona),0);
  MaxSzer:=((Form1.ClientWidth-LMarg-PMarg) div SzerC)*SzerC;
  Xstart:=LMarg+((MaxSzer div SzerC) div 2)*SzerC;
  LosujElement1(Sender);  
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  // rozmiary planszy są stałe
  Form1.Width:=692;
  Form1.Height:=499;
end;

procedure Tform1.ZrobCetke (NR,X,Y : Integer;Kolor:TColor; Sender:TObject);
 begin
 // Rysowanie kształtki "C"
  Cegielki[NR].Kolor:=Kolor;
  Cegielki[NR].LP:=8;
  Cegielki[NR].P[1]:=Point(X,Y);
  Cegielki[NR].P[2]:=Point(X+2*SzerC,Y);
  Cegielki[NR].P[3]:=Point(X+2*SzerC,Y+1*SzerC);
  Cegielki[NR].P[4]:=Point(X+1*SzerC,Y+1*SzerC);
  Cegielki[NR].P[5]:=Point(X+1*SzerC,Y+2*SzerC);
  Cegielki[NR].P[6]:=Point(X+2*SzerC,Y+2*SzerC);
  Cegielki[NR].P[7]:=Point(X+2*SzerC,Y+3*SzerC);
  Cegielki[NR].P[8]:=Point(X,Y+3*SzerC);
end;

procedure Tform1.Zrobzetuszke ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
begin
 // rysowanie małej zetuszki
  Cegielki[NR].Kolor:=Kolor;
  Cegielki[NR].LP:=8;
  Cegielki[NR].P[1]:=Point(X,Y);
  Cegielki[NR].P[2]:=Point(X+2*SzerC,Y);
  Cegielki[NR].P[3]:=Point(X+2*SzerC,Y+1*SzerC);
  Cegielki[NR].P[4]:=Point(X+3*SzerC,Y+1*SzerC);
  Cegielki[NR].P[5]:=Point(X+3*SzerC,Y+2*SzerC);
  Cegielki[NR].P[6]:=Point(X+1*SzerC,Y+2*SzerC);
  Cegielki[NR].P[7]:=Point(X+1*SzerC,Y+1*SzerC);
  Cegielki[NR].P[8]:=Point(X,Y+1*SzerC);
end;

procedure TForm1.Zrobkwadracik ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
begin
  Cegielki[NR].Kolor:=Kolor;
  Cegielki[NR].LP:=4;
  Cegielki[NR].P[1]:=Point(X,Y);
  Cegielki[NR].P[2]:=Point(X+2*SzerC,Y);
  Cegielki[NR].P[3]:=Point(X+2*SzerC,Y+2*SzerC);
  Cegielki[NR].P[4]:=Point(X,Y+2*SzerC);
end;

procedure TForm1.ZrobZetke (NR,X,Y : Integer;Kolor:TColor; Sender:TObject);
begin
  // wstawienie kształtki "Z" do tablicy
  Cegielki[NR].Kolor:=Kolor;
  Cegielki[NR].LP:=8;
  Cegielki[NR].P[1]:=Point(X,Y);
  Cegielki[NR].P[2]:=Point(X+2*SzerC,Y);
  Cegielki[NR].P[3]:=Point(X+2*SzerC,Y+2*SzerC);
  Cegielki[NR].P[4]:=Point(X+3*SzerC,Y+2*SzerC);
  Cegielki[NR].P[5]:=Point(X+3*SzerC,Y+3*SzerC);
  Cegielki[NR].P[6]:=Point(X+1*SzerC,Y+3*SzerC);
  Cegielki[NR].P[7]:=Point(X+1*SzerC,Y+1*SzerC);
  Cegielki[NR].P[8]:=Point(X        ,Y+1*SzerC);
end;

procedure TForm1.ZrobElke ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
begin
  // Rysowanie kształtki "L"
  Cegielki[NR].Kolor:=Kolor;
  Cegielki[NR].LP:=6;
  Cegielki[NR].P[1]:=Point(X,Y);
  Cegielki[NR].P[2]:=Point(X+1*SzerC,Y);
  Cegielki[NR].P[3]:=Point(X+1*SzerC,Y+2*SzerC);
  Cegielki[NR].P[4]:=Point(X+2*SzerC,Y+2*SzerC);
  Cegielki[NR].P[5]:=Point(X+2*SzerC,Y+3*SzerC);
  Cegielki[NR].P[6]:=Point(X,Y+3*SzerC);
end;

procedure TForm1.ZrobKropka ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
begin
  // Rysowanie kształtki - kilka kwadracików
  Cegielki[NR].Kolor:=Kolor;
  Cegielki[NR].LP:=4;
  Cegielki[NR].P[1]:=Point(X,Y);
  Cegielki[NR].P[2]:=Point(X+4*SzerC,Y);
  Cegielki[NR].P[3]:=Point(X+4*SzerC,Y+1*SzerC);
  Cegielki[NR].P[4]:=Point(X        ,Y+1*SzerC);
end;
procedure TForm1.ZrobTetke ( NR,X,Y : Integer; Kolor:TColor; Sender:TObject);
begin
// Rysowanie kształtki "T"
  Cegielki[NR].Kolor:=Kolor;
  Cegielki[NR].LP:=8;
  Cegielki[NR].P[1]:=Point(X,Y);
  Cegielki[NR].P[2]:=Point(X+3*SzerC,Y);
  Cegielki[NR].P[3]:=Point(X+3*SzerC,Y+1*SzerC);
  Cegielki[NR].P[4]:=Point(X+2*SzerC,Y+1*SzerC);
  Cegielki[NR].P[5]:=Point(X+2*SzerC,Y+2*SzerC);
  Cegielki[NR].P[6]:=Point(X+1*SzerC,Y+2*SzerC);
  Cegielki[NR].P[7]:=Point(X+1*SzerC,Y+1*SzerC);
  Cegielki[NR].P[8]:=Point(X,Y+1*SzerC);
end;


function TForm1.CzyMozeSpadac(Obiekt : Array of TPoint; LP:Byte; Sender:TObject):Boolean;
var  i,j,Ymin,Ymax : Integer;
             PP,PK : Integer;
 LiczbaS,xs,ys,NrS : Integer;
         XTST,YTST : Integer;
         TestPomoc : Boolean;
                TS : Array[1..99] of TPoint;
begin
  // zerujemy zmienne
  for i:=1 to 99 do TS[i]:=Point(0,0);
  NrS:=0;
  Ymin:=Obiekt[1].Y;
  Ymax:=Obiekt[1].Y;
  // szukamy Ymax
  for i:=1 to LP-1  do if Obiekt[i].Y>Ymax then Ymax:=Obiekt[i].Y;
  // sprawdzamy czy nie spadł do końca
  if (Ymax>=Form1.ClientHeight-SzerC) then
  begin
    CzyMozeSpadac:=False;
    EXIT;
  end;
  // szukamy Ymin.
  for i:=0 to LP  do if Obiekt[i].Y<Ymin then Ymin:=Obiekt[i].Y;
  // wyznaczamy środki dla poziomych odcinków
  for i:=0 to LP-1 do
  begin
    PP:=i;
    if (i<LP-1) then PK:=i+1 else PK:=0;
    // szukamy linii poziomych
    TajnaKartka.Canvas.Pen.Color:=clBlack;
    if (Obiekt[PP].Y=Obiekt[PK].Y) then
    begin
      // ile będzie środków nad tym odcinkiem
      LiczbaS:=Trunc((Abs(Obiekt[PP].X-Obiekt[PK].X))/SzerC);
      // wyznaczamy wsp. środków pól nad poziomymi kreskami
      For j:=0 to LiczbaS-1 Do
      Begin
        ys:=Obiekt[PP].Y-1;
        if (Obiekt[PP].X<Obiekt[PK].X) then
        begin
          xs:=Obiekt[PP].X+j*(SzerC)+(SzerC div 2);
        end
        else
        begin
          xs:=Obiekt[PK].X+j*(SzerC)+(SzerC div 2);
        end;
        // czy środek znajduje się pod Ymin
        if (ys>Ymin) then
        begin
          inc(NrS);
          TS[NrS]:=Point(xs,ys);
        end;
      End;
    end;
  end;
  // sprawdzamy czy pod którymś środkiem jest inny środek
  For i:=1 to NrS Do
  Begin
    For j:=1 to NrS Do
    Begin
      if ((i<>j)and(TS[i].X=TS[j].X)and(TS[i].X<>0)and(TS[i].Y<>0)) then
      begin
        if (TS[j].Y>TS[i].Y) then
        begin
          TS[i]:=Point(0,0);
        end
        else
        begin
          TS[j]:=Point(0,0);
        end;
      end;
    End;
  End;
  // I NA KONIEC SPRAWDZAMY CZY MOŻE SPADAĆ CZY NIE !
  TestPomoc:=True;
  For i:=1 to NrS Do
  Begin
    if ((TS[i].X<>0)and(TS[i].Y<>0)) then
    begin
      // Współrzędne testowanego miejsca
      XTST:=TS[i].x;
      YTST:=TS[i].y+SzerC div 2;
      // Kropki kontrolne
      // TajnaKartka.Canvas.Pen.Color:=$008000FF;
      // TajnaKartka.Canvas.Ellipse(XTST-1,YTST-1,XTST+1,YTST+1);
      // TajnaKartka.Canvas.Pen.Color:=clBlack;
      // Test
      if ((TajnaKartka.Canvas.Pixels[XTST,YTST]<>clSilver)and(TajnaKartka.Canvas.Pixels[XTST,YTST]<>clBlack)) then
      begin
        TestPomoc:=False;
      end;
    end;
  End;
  CzyMozeSpadac:=TestPomoc;
end;

procedure TForm1.MalujWszystkieCegielki (Sender:TObject);
var  i,j : Integer;
       c : array[1..10] of TPoint;  // pomocnicza cegiełka
begin
  // Czyszczenie tajnej kartki
  TajnaKartka.Canvas.Brush.Color:=clSilver;
  TajnaKartka.Canvas.Rectangle(-1,-1,TajnaKartka.Width,TajnaKartka.Height);
  // Siatka pomocnicza
  if (SP1.Checked) then RysujSiatke (Sender);
  // Punktacja
  TajnaKartka.Canvas.Pen.Color:=clBlack;
  // Rysujemy teraz wszystkie cegiełki
  For i:=1 To MaxLiczbaC Do
  Begin
    if (Cegielki[i].LP>0) then
    begin
      // wyczyścimy pomocniczą cegiełkę:
      for j:=1 to 10 do C[j]:=Cegielki[i].P[1];
      // a teraz wpisujemy do niej prawdziwe punkty:
      for j:=1 to Cegielki[i].LP do C[j]:=Cegielki[i].P[j];
      // ustalamy kolor pędzla
      TajnaKartka.Canvas.Brush.Color:=Cegielki[i].Kolor;
      // i rysujemy ją.
      TajnaKartka.Canvas.Polygon(C);
      TajnaKartka.Canvas.Polygon(C);
    end;
  End;
  // Przerysowanie Tajnej Kartki na Form1
  SprawdzWypelnieniePlanszy (Sender);
  // Dorysowanie punktacji
  If (Punktacja>=2) then TajnaKartka.Canvas.Draw(625,376,Image1.Picture.Bitmap);
  If (Punktacja>=4) then TajnaKartka.Canvas.Draw(625,328,Image2.Picture.Bitmap);
  If (Punktacja>=6) then TajnaKartka.Canvas.Draw(625,280,Image3.Picture.Bitmap);
  If (Punktacja>=8) then TajnaKartka.Canvas.Draw(624,224,Image4.Picture.Bitmap);
  // Wyświetlanie
  Form1.Canvas.Draw(0,0,TajnaKartka);
end;

procedure TForm1.PrzeunWszystkieCegielki (Sender:TObject);
var i,j : Integer;
      c : array[1..10] of TPoint;  // pomocnicza cegiełka
begin
  SieRuszaja:=False;
  // przesuwanie wszystkich cegiełek
  For i:=1 To MaxLiczbaC Do
  Begin
    if (Cegielki[i].LP>0) and not CeglaZamrozona[i] then
    begin
      // wyczyścimy pomocniczą cegiełkę:
      for j:=1 to 10 do C[j]:=Cegielki[i].P[1];
      // a teraz wpisujemy do niej prawdziwe punkty:
      for j:=1 to Cegielki[i].LP do C[j]:=Cegielki[i].P[j];
      // sprawdzimy czy można cegiełkę przesunąć w dół
      if (CzyMozeSpadac(C,Cegielki[i].LP,Sender)) then
      begin
        // jeżeli można to dodajemy do y szerokość cegiełki SzerC
        for j:=1 to Cegielki[i].LP do Cegielki[i].P[j].Y:=Cegielki[i].P[j].Y+SzerC;
        SieRuszaja:=True;
      end;
    end;
  end;
  if not SieRuszaja then
    for i:=1 to NrCegielki do
      if Cegielki[i].LP>0 then CeglaZamrozona[i]:=True;
end;

procedure TForm1.UsunWypelnioneWiersze;
const
  MaksymalnyRozmiarPlanszy = 100;
type
  TPlanszaIndeksow = array[0..MaksymalnyRozmiarPlanszy-1,
    0..MaksymalnyRozmiarPlanszy-1] of Integer;
  TPlanszaKolorow = array[0..MaksymalnyRozmiarPlanszy-1,
    0..MaksymalnyRozmiarPlanszy-1] of TColor;
  TPlanszaOdwiedzonych = array[0..MaksymalnyRozmiarPlanszy-1,
    0..MaksymalnyRozmiarPlanszy-1] of Boolean;
  TListaKomorek = array[1..MaksymalnyRozmiarPlanszy*
    MaksymalnyRozmiarPlanszy] of TPoint;
  TListaPunktow = array[1..40] of TPoint;
  TKrawedz = record
    Poczatek: TPoint;
    Koniec: TPoint;
  end;
  TListaKrawedzi = array[1..40] of TKrawedz;
var
  IndeksyPol: TPlanszaIndeksow;
  KoloryPol: TPlanszaKolorow;
  OdwiedzonePola: TPlanszaOdwiedzonych;
  WierszPelny: array[0..MaksymalnyRozmiarPlanszy-1] of Boolean;
  KoloryCegiel: array[1..MaxLiczbaC] of TColor;
  ZamrozoneCegly: array[1..MaxLiczbaC] of Boolean;
  Kolejka: TListaKomorek;
  Krawedzie: TListaKrawedzi;
  LiczbaKolumn, LiczbaWierszy: Integer;
  Indeks, IndeksPunktu, Kolumna, Wiersz: Integer;
  MinX, MaxX, MinY, MaxY: Integer;
  MinKolumna, MaxKolumna, MinWiersz, MaxWiersz: Integer;
  ZrodloWiersza, DocelowyWiersz: Integer;
  LiczbaPelnychWierszy: Integer;
  GlowaKolejki, OgonKolejki, LiczbaKrawedzi: Integer;
  IndeksKrawedzi, NastepnaKrawedz, LiczbaPunktow: Integer;
  LiczbaPunktowBrzegowych, IndeksWierzcholka: Integer;
  PoprzedniWierzcholek, NastepnyWierzcholek: Integer;
  NumerCegly: Integer;
  X, Y: Integer;
  PunktPoczatkowy, PunktKoncowy: TPoint;
  PunktyBrzegowe: TListaPunktow;
  ZnalezionoWiersz, ZnalezionoKrawedz: Boolean;
  KrawedzUzyta: array[1..40] of Boolean;

  procedure DodajKrawedz(const Poczatek, Koniec: TPoint);
  begin
    if LiczbaKrawedzi=High(Krawedzie) then
      raise Exception.Create('Za duzo krawedzi podczas usuwania wiersza.');
    Inc(LiczbaKrawedzi);
    Krawedzie[LiczbaKrawedzi].Poczatek:=Poczatek;
    Krawedzie[LiczbaKrawedzi].Koniec:=Koniec;
  end;

begin
  LiczbaKolumn:=MaxSzer div SzerC;
  LiczbaWierszy:=(Form1.ClientHeight-GMarg) div SzerC;
  if (LiczbaKolumn>MaksymalnyRozmiarPlanszy) or
     (LiczbaWierszy>MaksymalnyRozmiarPlanszy) then
    raise Exception.Create('Plansza jest za duza do usuwania wierszy.');
  if (LiczbaKolumn=0) or (LiczbaWierszy=0) then Exit;

  FillChar(IndeksyPol,SizeOf(IndeksyPol),0);
  FillChar(OdwiedzonePola,SizeOf(OdwiedzonePola),0);
  for Wiersz:=0 to LiczbaWierszy-1 do
  begin
    WierszPelny[Wiersz]:=False;
    for Kolumna:=0 to LiczbaKolumn-1 do
      KoloryPol[Kolumna,Wiersz]:=clSilver;
  end;
  for Indeks:=1 to NrCegielki do
  begin
    KoloryCegiel[Indeks]:=Cegielki[Indeks].Kolor;
    ZamrozoneCegly[Indeks]:=CeglaZamrozona[Indeks];
  end;

  for Indeks:=1 to NrCegielki do
    if Cegielki[Indeks].LP>0 then
    begin
      MinX:=Cegielki[Indeks].P[1].X;
      MaxX:=MinX;
      MinY:=Cegielki[Indeks].P[1].Y;
      MaxY:=MinY;
      for IndeksPunktu:=2 to Cegielki[Indeks].LP do
      begin
        MinX:=Min(MinX,Cegielki[Indeks].P[IndeksPunktu].X);
        MaxX:=Max(MaxX,Cegielki[Indeks].P[IndeksPunktu].X);
        MinY:=Min(MinY,Cegielki[Indeks].P[IndeksPunktu].Y);
        MaxY:=Max(MaxY,Cegielki[Indeks].P[IndeksPunktu].Y);
      end;
      MinKolumna:=Max(0,(MinX-LMarg) div SzerC);
      MaxKolumna:=Min(LiczbaKolumn-1,(MaxX-LMarg-1) div SzerC);
      MinWiersz:=Max(0,(MinY-GMarg) div SzerC);
      MaxWiersz:=Min(LiczbaWierszy-1,(MaxY-GMarg-1) div SzerC);
      for Wiersz:=MinWiersz to MaxWiersz do
        for Kolumna:=MinKolumna to MaxKolumna do
          if CzyPunktWewnatrzCegly(Cegielki[Indeks],
            LMarg+Kolumna*SzerC+(SzerC div 2),
            GMarg+Wiersz*SzerC+(SzerC div 2)) then
          begin
            IndeksyPol[Kolumna,Wiersz]:=Indeks;
            KoloryPol[Kolumna,Wiersz]:=Cegielki[Indeks].Kolor;
          end;
    end;

  ZnalezionoWiersz:=False;
  LiczbaPelnychWierszy:=0;
  for Wiersz:=0 to LiczbaWierszy-1 do
  begin
    WierszPelny[Wiersz]:=True;
    for Kolumna:=0 to LiczbaKolumn-1 do
      if IndeksyPol[Kolumna,Wiersz]=0 then
      begin
        WierszPelny[Wiersz]:=False;
        Break;
      end;
    if WierszPelny[Wiersz] then
    begin
      ZnalezionoWiersz:=True;
      Inc(LiczbaPelnychWierszy);
    end;
  end;
  if not ZnalezionoWiersz then Exit;

  Inc(Punktacja,LiczbaPelnychWierszy);
  Str(Punktacja,PunktcjaStr);
  while Length(PunktcjaStr)<4 do PunktcjaStr:=' '+PunktcjaStr;

  DocelowyWiersz:=LiczbaWierszy-1;
  for ZrodloWiersza:=LiczbaWierszy-1 downto 0 do
    if not WierszPelny[ZrodloWiersza] then
    begin
      if DocelowyWiersz<>ZrodloWiersza then
        for Kolumna:=0 to LiczbaKolumn-1 do
        begin
          IndeksyPol[Kolumna,DocelowyWiersz]:=
            IndeksyPol[Kolumna,ZrodloWiersza];
          KoloryPol[Kolumna,DocelowyWiersz]:=
            KoloryPol[Kolumna,ZrodloWiersza];
        end;
      Dec(DocelowyWiersz);
    end;
  for Wiersz:=0 to DocelowyWiersz do
    for Kolumna:=0 to LiczbaKolumn-1 do
    begin
      IndeksyPol[Kolumna,Wiersz]:=0;
      KoloryPol[Kolumna,Wiersz]:=clSilver;
    end;

  for Indeks:=1 to MaxLiczbaC do
    Cegielki[Indeks].LP:=0;
  NrCegielki:=0;

  for Wiersz:=0 to LiczbaWierszy-1 do
    for Kolumna:=0 to LiczbaKolumn-1 do
      if (IndeksyPol[Kolumna,Wiersz]>0) and
         not OdwiedzonePola[Kolumna,Wiersz] then
      begin
        NumerCegly:=IndeksyPol[Kolumna,Wiersz];
        GlowaKolejki:=1;
        OgonKolejki:=1;
        Kolejka[1]:=Point(Kolumna,Wiersz);
        OdwiedzonePola[Kolumna,Wiersz]:=True;
        while GlowaKolejki<=OgonKolejki do
        begin
          X:=Kolejka[GlowaKolejki].X;
          Y:=Kolejka[GlowaKolejki].Y;
          Inc(GlowaKolejki);
          if (X>0) and (IndeksyPol[X-1,Y]=NumerCegly) and
             not OdwiedzonePola[X-1,Y] then
          begin
            Inc(OgonKolejki);
            Kolejka[OgonKolejki]:=Point(X-1,Y);
            OdwiedzonePola[X-1,Y]:=True;
          end;
          if (X<LiczbaKolumn-1) and
             (IndeksyPol[X+1,Y]=NumerCegly) and
             not OdwiedzonePola[X+1,Y] then
          begin
            Inc(OgonKolejki);
            Kolejka[OgonKolejki]:=Point(X+1,Y);
            OdwiedzonePola[X+1,Y]:=True;
          end;
          if (Y>0) and (IndeksyPol[X,Y-1]=NumerCegly) and
             not OdwiedzonePola[X,Y-1] then
          begin
            Inc(OgonKolejki);
            Kolejka[OgonKolejki]:=Point(X,Y-1);
            OdwiedzonePola[X,Y-1]:=True;
          end;
          if (Y<LiczbaWierszy-1) and
             (IndeksyPol[X,Y+1]=NumerCegly) and
             not OdwiedzonePola[X,Y+1] then
          begin
            Inc(OgonKolejki);
            Kolejka[OgonKolejki]:=Point(X,Y+1);
            OdwiedzonePola[X,Y+1]:=True;
          end;
        end;

        LiczbaKrawedzi:=0;
        for IndeksPunktu:=1 to OgonKolejki do
        begin
          X:=Kolejka[IndeksPunktu].X;
          Y:=Kolejka[IndeksPunktu].Y;
          if Y=0 then
            DodajKrawedz(Point(LMarg+X*SzerC,GMarg+Y*SzerC),
              Point(LMarg+(X+1)*SzerC,GMarg+Y*SzerC))
          else if IndeksyPol[X,Y-1]<>NumerCegly then
            DodajKrawedz(Point(LMarg+X*SzerC,GMarg+Y*SzerC),
              Point(LMarg+(X+1)*SzerC,GMarg+Y*SzerC));
          if X=LiczbaKolumn-1 then
            DodajKrawedz(Point(LMarg+(X+1)*SzerC,GMarg+Y*SzerC),
              Point(LMarg+(X+1)*SzerC,GMarg+(Y+1)*SzerC))
          else if IndeksyPol[X+1,Y]<>NumerCegly then
            DodajKrawedz(Point(LMarg+(X+1)*SzerC,GMarg+Y*SzerC),
              Point(LMarg+(X+1)*SzerC,GMarg+(Y+1)*SzerC));
          if Y=LiczbaWierszy-1 then
            DodajKrawedz(Point(LMarg+(X+1)*SzerC,GMarg+(Y+1)*SzerC),
              Point(LMarg+X*SzerC,GMarg+(Y+1)*SzerC))
          else if IndeksyPol[X,Y+1]<>NumerCegly then
            DodajKrawedz(Point(LMarg+(X+1)*SzerC,GMarg+(Y+1)*SzerC),
              Point(LMarg+X*SzerC,GMarg+(Y+1)*SzerC));
          if X=0 then
            DodajKrawedz(Point(LMarg+X*SzerC,GMarg+(Y+1)*SzerC),
              Point(LMarg+X*SzerC,GMarg+Y*SzerC))
          else if IndeksyPol[X-1,Y]<>NumerCegly then
            DodajKrawedz(Point(LMarg+X*SzerC,GMarg+(Y+1)*SzerC),
              Point(LMarg+X*SzerC,GMarg+Y*SzerC));
        end;

        FillChar(KrawedzUzyta,SizeOf(KrawedzUzyta),0);
        Inc(NrCegielki);
        if NrCegielki>MaxLiczbaC then
          raise Exception.Create('Za duzo cegiel po usunieciu wiersza.');
        Cegielki[NrCegielki].Kolor:=KoloryCegiel[NumerCegly];
        CeglaZamrozona[NrCegielki]:=ZamrozoneCegly[NumerCegly];
        LiczbaPunktowBrzegowych:=0;
        IndeksKrawedzi:=1;
        PunktPoczatkowy:=Krawedzie[IndeksKrawedzi].Poczatek;
        repeat
          if KrawedzUzyta[IndeksKrawedzi] then
            raise Exception.Create('Nie mozna odtworzyc ksztaltu cegly.');
          KrawedzUzyta[IndeksKrawedzi]:=True;
          Inc(LiczbaPunktowBrzegowych);
          PunktyBrzegowe[LiczbaPunktowBrzegowych]:=
            Krawedzie[IndeksKrawedzi].Poczatek;
          PunktKoncowy:=Krawedzie[IndeksKrawedzi].Koniec;
          if (PunktKoncowy.X=PunktPoczatkowy.X) and
             (PunktKoncowy.Y=PunktPoczatkowy.Y) then Break;

          ZnalezionoKrawedz:=False;
          for NastepnaKrawedz:=1 to LiczbaKrawedzi do
            if not KrawedzUzyta[NastepnaKrawedz] and
               (Krawedzie[NastepnaKrawedz].Poczatek.X=PunktKoncowy.X) and
               (Krawedzie[NastepnaKrawedz].Poczatek.Y=PunktKoncowy.Y) then
            begin
              IndeksKrawedzi:=NastepnaKrawedz;
              ZnalezionoKrawedz:=True;
              Break;
            end;
          if not ZnalezionoKrawedz then
            raise Exception.Create('Nie mozna zamknac ksztaltu cegly.');
        until False;

        LiczbaPunktow:=0;
        for IndeksWierzcholka:=1 to LiczbaPunktowBrzegowych do
        begin
          PoprzedniWierzcholek:=IndeksWierzcholka-1;
          if PoprzedniWierzcholek=0 then
            PoprzedniWierzcholek:=LiczbaPunktowBrzegowych;
          NastepnyWierzcholek:=IndeksWierzcholka+1;
          if NastepnyWierzcholek>LiczbaPunktowBrzegowych then
            NastepnyWierzcholek:=1;

          if ((PunktyBrzegowe[IndeksWierzcholka].X-
               PunktyBrzegowe[PoprzedniWierzcholek].X)*
              (PunktyBrzegowe[NastepnyWierzcholek].Y-
               PunktyBrzegowe[IndeksWierzcholka].Y) <>
              (PunktyBrzegowe[IndeksWierzcholka].Y-
               PunktyBrzegowe[PoprzedniWierzcholek].Y)*
              (PunktyBrzegowe[NastepnyWierzcholek].X-
               PunktyBrzegowe[IndeksWierzcholka].X)) then
          begin
            Inc(LiczbaPunktow);
            if LiczbaPunktow>High(Cegielki[NrCegielki].P) then
              raise Exception.Create('Ksztalt cegly ma za duzo punktow.');
            Cegielki[NrCegielki].P[LiczbaPunktow]:=
              PunktyBrzegowe[IndeksWierzcholka];
          end;
        end;
        Cegielki[NrCegielki].LP:=LiczbaPunktow;
      end;
end;

procedure TForm1.RysujSiatke (Sender:TOBject);
var i,x : Integer;
begin
  // rysowanie linii pionowych siatki
  x:=LMarg;
  TajnaKartka.Canvas.Pen.Color:=$00BBBBBB;
  Repeat
    TajnaKartka.Canvas.MoveTo(x,GMarg);
    TajnaKartka.Canvas.LineTo(x,Form1.ClientHeight);
    x:=x+SzerC;
  Until (x>MaxSzer);
  TajnaKartka.Canvas.MoveTo(x,GMarg);
  TajnaKartka.Canvas.LineTo(x,Form1.ClientHeight);
  // rysowanie linii poziomych
  for i:=0 to (Form1.ClientHeight div SzerC) do
  begin
    TajnaKartka.Canvas.MoveTo(LMarg,GMarg+SzerC*i);
    TajnaKartka.Canvas.LineTo(LMarg+(MaxSzer div SzerC)*SzerC,GMarg+SzerC*i)
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (Grawitacja1.Checked) then PrzeunWszystkieCegielki(Sender);
  if not GraZakonczona and not SieRuszaja then
    UsunWypelnioneWiersze;
  MalujWszystkieCegielki (Sender);
  if (not GraZakonczona) and ((Not(SieRuszaja)){and(Not(BylKlawisz))}) then
  begin
    if (CzyGameOver(Sender)) then
      ZakonczGre
    else
    begin
      form1.caption:='Nasze własne cegiełki';
      LosujElement1(Sender);
    end;
  end;
  BylKlawisz:=False;
end;

procedure TForm1.ZakonczGre;
var
  Komunikat: UnicodeString;
begin
  if GraZakonczona then Exit;
  Form1.Caption:='Game Over';
  GraZakonczona:=True;
  Komunikat:=UTF8Decode('Koniec gry! Twój wynik: ');
  Komunikat:=Komunikat+UnicodeString(Trim(PunktcjaStr));
  ShowMessage(UTF8Encode(Komunikat));
end;

procedure TForm1.LosujElement1 (Sender:TObject);
var
  IndeksCegly: Integer;
begin
  if (NrCegielki<MaxLiczbaC) then Inc(NrCegielki);
  CeglaZamrozona[NrCegielki]:=False;
  Case (Random(7)+1) Of
    1: ZrobZetke    (NrCegielki,Xstart,GMarg,(clred)    ,Sender);
    2: ZrobElke     (NrCegielki,Xstart,GMarg,(clblue)   ,Sender);
    3: ZrobKropka   (NrCegielki,Xstart,GMarg,(clyellow) ,Sender);
    4: ZrobCetke    (NrCegielki,Xstart,GMarg,(cllime)   ,Sender);
    5: ZrobTetke    (NrCegielki,Xstart,GMarg,($000080FF),Sender);
    6: Zrobzetuszke (NrCegielki,Xstart,GMarg,($00C080FF),Sender);
    7: Zrobkwadracik(NrCegielki,Xstart,GMarg,(clfuchsia),Sender);
  End;

  for IndeksCegly:=1 to NrCegielki-1 do
    if (Cegielki[IndeksCegly].LP>0) and
       CzyCeglyNakladajaSie(Cegielki[NrCegielki],
                            Cegielki[IndeksCegly]) then
    begin
      Cegielki[NrCegielki].LP:=0;
      ZakonczGre;
      Exit;
    end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i : Integer;
  ObroconaCegla: Cegla;
begin
  BylKlawisz:=True;
  if (key=13) then
  begin
    key:=0;
    RestartGry(Sender);
  end;
  // przesuwanie w lewo
  if ((key=37)and(CzyMoznaWLewo(Sender))) then
  begin
    for i:=1 to Cegielki[NrCegielki].LP do Cegielki[NrCegielki].P[i].X:=Cegielki[NrCegielki].P[i].X-SzerC;
  end;
  // przesuwanie w prawo
  if ((key=39)and(CzyMoznaWPrawo(Sender))) then
  begin
    for i:=1 to Cegielki[NrCegielki].LP do Cegielki[NrCegielki].P[i].X:=Cegielki[NrCegielki].P[i].X+SzerC;
  end;
  // skok w dół
  if (key=34) then
  begin
    for i:=1 to Trunc(Form1.Height/SzerC) do
    begin
      PrzeunWszystkieCegielki(Sender);
      MalujWszystkieCegielki (Sender);
    end;
  end;
  // przyspieszacz
  if (key=40) then
  begin
    timer1.interval:=Vtimera div 10;
    exit;
  end;
  // obrót
  if (key=32) then
  begin
    ObroconaCegla:=Obroocony(Cegielki[NrCegielki],Sender);
    if CzyMoznaObrocic(ObroconaCegla) then
      Cegielki[NrCegielki]:=ObroconaCegla;
  end;
  // ta linia przyspiesza reakcję na naciskanie klawiszy
  MalujWszystkieCegielki (Sender);
end;

function TForm1.Obroocony (Obiekt : Cegla; Sender:Tobject):Cegla;
var Xmin,Ymin : Integer;
    Xmax,Ymax : Integer;
      i,Xs,Ys : Integer;
      Tymczas : Cegla;
begin
  // obracanie cegiełek o +90 stopni:
  Tymczas:=Obiekt;
  Xmin:= 9999;
  Ymin:= 9999;
  Xmax:=-9999;
  Ymax:=-9999;
  // poszukiwanie min i max:
  for i:=1 to Obiekt.LP do
  begin
    if (Obiekt.P[i].X>Xmax) then Xmax:=Obiekt.P[i].X;
    if (Obiekt.P[i].X<Xmin) then Xmin:=Obiekt.P[i].X;
    if (Obiekt.P[i].Y>Ymax) then Ymax:=Obiekt.P[i].Y;
    if (Obiekt.P[i].Y<Ymin) then Ymin:=Obiekt.P[i].Y;
  end;
  // wyznaczenie środka
  Xs:=Xmin+((Xmax-Xmin) div Trunc((Xmax-Xmin)/SzerC));
  Ys:=Ymin+((Ymax-Ymin) div Trunc((Ymax-Ymin)/SzerC));
  // zmiana współrzędnych
  for i:=1 to Obiekt.LP do
  begin
    Obiekt.P[i].X:=Xs-(Tymczas.P[i].Y-Ys);
    Obiekt.P[i].Y:=Ys+(Tymczas.P[i].X-Xs);
    if (Frac(((Xmax-Xmin)/SzerC)/2)=0.5) then Obiekt.P[i].X:=Obiekt.P[i].X+SzerC;
  end;
  Obroocony:=Obiekt;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  Timer1.Interval:=100;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=40) then timer1.interval:=Vtimera;
end;

function TForm1.CzyGameOver (Sender:TObject):Boolean;
var i,x : Integer;
begin
  CzyGameOver:=False;
  for i:=0 to 3 do
  begin
    x:=Xstart+i*SzerC+(SzerC div 2);
    if (TajnaKartka.Canvas.Pixels[x,10+(SzerC div 2)]<>clSilver) then
    begin
      CzyGameOver:=True;
    end;
  end;
end;

procedure TForm1.Klawiszologia1Click(Sender: TObject);
begin
  form2.Show;
end;

procedure TForm1.onieczabawyspadajcymicegiekami1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.Szybkie1Click(Sender: TObject);
begin
  Szybkie1.Checked:=not(Szybkie1.Checked);
  if (Szybkie1.Checked) then Vtimera:=150 else Vtimera:=500;
  Timer1.Interval:=Vtimera;
end;

procedure TForm1.Ogrze1Click(Sender: TObject);
begin
  form3.show;
end;


procedure TForm1.Strasznekobyy1Click(Sender: TObject);
begin
  SzerC:=40;
  RestartGry(Sender);
end;

procedure TForm1.Dlaprzedszkolakw1Click(Sender: TObject);
begin
  SzerC:=30;
  RestartGry(Sender);
end;

procedure TForm1.Normalne1Click(Sender: TObject);
begin
  SzerC:=20;
  RestartGry(Sender);
end;

procedure TForm1.Dlaprofesjonalistw1Click(Sender: TObject);
begin
  SzerC:=10;
  RestartGry(Sender);
end;

procedure TForm1.Grawitacja1Click(Sender: TObject);
begin
  Grawitacja1.checked:=not(Grawitacja1.checked);
end;

function TForm1.SprawdzWypelnieniePlanszy (Sender:TOBject):Integer;
begin
  SprawdzWypelnieniePlanszy:=0;
  TajnaKartka.Canvas.Brush.Color:=clSilver;
  TajnaKartka.Canvas.Pen.Color:=$008100F1;
  TajnaKartka.Canvas.TextOut(Form1.ClientWidth-PMarg,2,PunktcjaStr);
end;

procedure TForm1.SP1Click(Sender: TObject);
begin
 SP1.Checked:=not(SP1.Checked);
end;

function TForm1.CzyMoznaWLewo (Sender:TOBject):Boolean;
begin
  CzyMoznaWLewo:=CzyMoznaPrzesunacPoziomo(kpLewo);
end;

function TForm1.CzyMoznaWPrawo (Sender:TOBject):Boolean;
begin
  CzyMoznaWPrawo:=CzyMoznaPrzesunacPoziomo(kpPrawo);
end;

function TForm1.CzyMoznaPrzesunacPoziomo(
  Kierunek: TKierunekPoziomy): Boolean;
var
  Indeks, NastepnyIndeks: Integer;
  WartoscKierunku: Integer;
  WspolrzednaX, WspolrzednaY, KoniecOdcinka: Integer;

  function CzyPoleZajete(const PunktX, PunktY: Integer): Boolean;
  var
    IndeksInnejCegly: Integer;
  begin
    Result:=False;
    for IndeksInnejCegly:=1 to MaxLiczbaC do
      if (IndeksInnejCegly<>NrCegielki) and
         (Cegielki[IndeksInnejCegly].LP>0) and
         Self.CzyPunktWewnatrzCegly(Cegielki[IndeksInnejCegly],
                                    PunktX,PunktY) then
      begin
        Result:=True;
        Exit;
      end;
  end;

begin
  if not (Ord(Kierunek) in [Ord(kpLewo), Ord(kpPrawo)]) then
  begin
    Result:=False;
    Exit;
  end;
  WartoscKierunku:=Ord(Kierunek)*2-1;
  Result:=True;

  for Indeks:=1 to Cegielki[NrCegielki].LP do
  begin
    if (Kierunek=kpLewo) and
       (Cegielki[NrCegielki].P[Indeks].X-SzerC<LMarg) then
    begin
      Result:=False;
      Exit;
    end;
    if (Kierunek=kpPrawo) and
       (Cegielki[NrCegielki].P[Indeks].X+SzerC>LMarg+MaxSzer) then
    begin
      Result:=False;
      Exit;
    end;
  end;

  for Indeks:=1 to Cegielki[NrCegielki].LP do
  begin
    NastepnyIndeks:=Indeks+1;
    if NastepnyIndeks>Cegielki[NrCegielki].LP then
      NastepnyIndeks:=1;

    if (Cegielki[NrCegielki].P[Indeks].X=
        Cegielki[NrCegielki].P[NastepnyIndeks].X) and
       (((Kierunek=kpPrawo) and
         (Cegielki[NrCegielki].P[NastepnyIndeks].Y>
          Cegielki[NrCegielki].P[Indeks].Y)) or
        ((Kierunek=kpLewo) and
         (Cegielki[NrCegielki].P[NastepnyIndeks].Y<
          Cegielki[NrCegielki].P[Indeks].Y))) then
    begin
      WspolrzednaX:=Cegielki[NrCegielki].P[Indeks].X+
                    WartoscKierunku*(SzerC div 2);
      if Kierunek=kpPrawo then
      begin
        WspolrzednaY:=Cegielki[NrCegielki].P[Indeks].Y+(SzerC div 2);
        KoniecOdcinka:=Cegielki[NrCegielki].P[NastepnyIndeks].Y;
      end
      else
      begin
        WspolrzednaY:=Cegielki[NrCegielki].P[NastepnyIndeks].Y+
                      (SzerC div 2);
        KoniecOdcinka:=Cegielki[NrCegielki].P[Indeks].Y;
      end;

      while WspolrzednaY<KoniecOdcinka do
      begin
        if CzyPoleZajete(WspolrzednaX,WspolrzednaY) then
        begin
          Result:=False;
          Exit;
        end;
        Inc(WspolrzednaY,SzerC);
      end;
    end;
  end;
end;

function TForm1.CzyPunktWewnatrzCegly(const SprawdzanaCegla: Cegla;
  PunktX, PunktY: Integer): Boolean;
var
  IndeksPunktu, PoprzedniIndeks: Integer;
begin
  Result:=False;
  PoprzedniIndeks:=SprawdzanaCegla.LP;
  for IndeksPunktu:=1 to SprawdzanaCegla.LP do
  begin
    if (SprawdzanaCegla.P[IndeksPunktu].Y>PunktY) <>
       (SprawdzanaCegla.P[PoprzedniIndeks].Y>PunktY) then
      if (SprawdzanaCegla.P[IndeksPunktu].X=
          SprawdzanaCegla.P[PoprzedniIndeks].X) and
         (PunktX<SprawdzanaCegla.P[IndeksPunktu].X) then
        Result:=not Result;
    PoprzedniIndeks:=IndeksPunktu;
  end;
end;

function TForm1.CzyCeglyNakladajaSie(const PierwszaCegla,
  DrugaCegla: Cegla): Boolean;
var
  Indeks: Integer;
  PierwszaMinX, PierwszaMinY, PierwszaMaxX, PierwszaMaxY: Integer;
  DrugaMinX, DrugaMinY, DrugaMaxX, DrugaMaxY: Integer;
  WspolrzednaX, WspolrzednaY: Integer;
begin
  Result:=False;
  if (PierwszaCegla.LP=0) or (DrugaCegla.LP=0) then Exit;

  PierwszaMinX:=PierwszaCegla.P[1].X;
  PierwszaMaxX:=PierwszaCegla.P[1].X;
  PierwszaMinY:=PierwszaCegla.P[1].Y;
  PierwszaMaxY:=PierwszaCegla.P[1].Y;
  DrugaMinX:=DrugaCegla.P[1].X;
  DrugaMaxX:=DrugaCegla.P[1].X;
  DrugaMinY:=DrugaCegla.P[1].Y;
  DrugaMaxY:=DrugaCegla.P[1].Y;

  for Indeks:=2 to PierwszaCegla.LP do
  begin
    PierwszaMinX:=Min(PierwszaMinX,PierwszaCegla.P[Indeks].X);
    PierwszaMaxX:=Max(PierwszaMaxX,PierwszaCegla.P[Indeks].X);
    PierwszaMinY:=Min(PierwszaMinY,PierwszaCegla.P[Indeks].Y);
    PierwszaMaxY:=Max(PierwszaMaxY,PierwszaCegla.P[Indeks].Y);
  end;
  for Indeks:=2 to DrugaCegla.LP do
  begin
    DrugaMinX:=Min(DrugaMinX,DrugaCegla.P[Indeks].X);
    DrugaMaxX:=Max(DrugaMaxX,DrugaCegla.P[Indeks].X);
    DrugaMinY:=Min(DrugaMinY,DrugaCegla.P[Indeks].Y);
    DrugaMaxY:=Max(DrugaMaxY,DrugaCegla.P[Indeks].Y);
  end;

  WspolrzednaY:=Max(PierwszaMinY,DrugaMinY)+(SzerC div 2);
  while WspolrzednaY<Min(PierwszaMaxY,DrugaMaxY) do
  begin
    WspolrzednaX:=Max(PierwszaMinX,DrugaMinX)+(SzerC div 2);
    while WspolrzednaX<Min(PierwszaMaxX,DrugaMaxX) do
    begin
      if CzyPunktWewnatrzCegly(PierwszaCegla,WspolrzednaX,WspolrzednaY) and
         CzyPunktWewnatrzCegly(DrugaCegla,WspolrzednaX,WspolrzednaY) then
      begin
        Result:=True;
        Exit;
      end;
      Inc(WspolrzednaX,SzerC);
    end;
    Inc(WspolrzednaY,SzerC);
  end;
end;

function TForm1.CzyMoznaObrocic(const ObroconaCegla: Cegla): Boolean;
var
  Indeks, IndeksStalejCegly: Integer;
  MinX, MaxX, MinY, MaxY: Integer;
begin
  Result:=False;
  if ObroconaCegla.LP=0 then Exit;

  MinX:=ObroconaCegla.P[1].X;
  MaxX:=ObroconaCegla.P[1].X;
  MinY:=ObroconaCegla.P[1].Y;
  MaxY:=ObroconaCegla.P[1].Y;
  for Indeks:=2 to ObroconaCegla.LP do
  begin
    MinX:=Min(MinX,ObroconaCegla.P[Indeks].X);
    MaxX:=Max(MaxX,ObroconaCegla.P[Indeks].X);
    MinY:=Min(MinY,ObroconaCegla.P[Indeks].Y);
    MaxY:=Max(MaxY,ObroconaCegla.P[Indeks].Y);
  end;

  if (MinX<LMarg) or (MaxX>LMarg+MaxSzer) or
     (MinY<GMarg) or (MaxY>Form1.ClientHeight) then Exit;

  for IndeksStalejCegly:=1 to MaxLiczbaC do
    if (IndeksStalejCegly<>NrCegielki) and
       (Cegielki[IndeksStalejCegly].LP>0) and
       CzyCeglyNakladajaSie(ObroconaCegla,
         Cegielki[IndeksStalejCegly]) then Exit;

  Result:=True;
end;



end.
