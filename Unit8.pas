unit Unit8;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,PsAPI, TlHelp32;

type
  TForm8 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BitBtn1: TBitBtn;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form8: TForm8;

implementation

uses Unit1;

{$R *.dfm}


procedure TForm8.BitBtn1Click(Sender: TObject);
var
  f:  file;
  s,s2:  string;
  a:  array [0..255] of char;
  c, iMonth:  Cardinal;
  r,rSec:  real;
  iSec,iMin,iHr,iD: word;  // ������� �� ������� (� iY ����� ���-�� ����)
  aDaysInMonths:  array [1..12] of byte;
  i: Integer;
  ts: tStringList;
begin
  if opendialog1.Execute then
  begin
    if opendialog1.filename<>'' then
    begin
      ts:=TStringList.Create;
      memo1.Lines.Clear;
      aDaysInMonths[1]:=31;
      aDaysInMonths[2]:=28;
      aDaysInMonths[3]:=31;
      aDaysInMonths[4]:=30;
      aDaysInMonths[5]:=31;
      aDaysInMonths[6]:=30;
      aDaysInMonths[7]:=31;
      aDaysInMonths[8]:=31;
      aDaysInMonths[9]:=30;
      aDaysInMonths[10]:=31;
      aDaysInMonths[11]:=30;
      aDaysInMonths[12]:=31;
      assignfile(f, opendialog1.filename);
      reset(f,2);     // 2 ������, ��� UNICODE
      c:=0;
      while not eof(f) do
      begin
        // --- �������� ������ ���� --------------------------------------------
        Blockread(f, c, 2);   // ������ ����
        Blockread(f, a, c);   // ���
        s:=string(a);
        setlength(s,c);
        Blockread(f, c, 2);   // ����, �����
        // - - - ������� ���� - - -
        iSec:= c mod 60;   c:=c div 60;     // �����
        iMin:= c mod 60;   c:=c div 60 + 6; // �����
        iHr:=  c mod 24;   c:=c div 24;     // �����
        c:=c*4;
        iD:=(c mod 1461) div 4; // ��������� c mod 365.25 ������ �������, ������ �� ��������� ��������
        c:=(c div 1461);        // ����� div 4 �� ����   // ���
        c:=1970 + c;  // ���
        { TODO : // ��� ������� ��������, ���������� �� ���..................... }
        // ���� ���., �� aDaysInMonths[2]:=29, else :=28;
        for i := 1 to 12 do
        begin
          if iD>=aDaysInMonths[i] then begin
            iD := iD - aDaysInMonths[i];
            iMonth:=i+1;   // ����� �����.
          end
          else break;
        end;
        iD:=iD+1;          // ����� ����.

        s2:=Format('%.2d.%.2d.%.4d %.2d:%.2d:%.2d', [iD,iMonth,c,iHr,iMin,iSec]);
        // - - - - - -
        s2:=s2 + ': ' + s + ':'#09;
        BlockRead(f, c, 2);
        BlockRead(f, a, c);
        s:=string(a);
        setlength(s,c);

//        memo1.Lines.Add(s2 + s);
        ts.add(s2 + s);
      end;

      memo1.Lines.Assign(ts);
      closefile(f);
      ts.Free;
    end;
  end;
end;

procedure TForm8.FormCreate(Sender: TObject);
begin
  Form1.ImageList1.GetBitmap(1, bitBtn1.Glyph);
end;

procedure TForm8.FormShow(Sender: TObject);
var
  s:  string;
  p, ReadMem, n:  Cardinal;
  h:  HWND;
begin
  s:=Form1.ProcessFileName(pid, true); // scr2
  s:=ExtractFilePath(s);  // scr3
  s:=s + 'userdata\Msg\';
  GetWindowThreadProcessId(hPWHandle, @p);
    h:=OpenProcess(PROCESS_ALL_ACCESS, false, p);
    ReadProcessMemory(h, ptr(baseadr), @ReadMem, 4, n);
    ReadProcessMemory(h, ptr(ReadMem+$20), @ReadMem, 4, n);
    ReadProcessMemory(h, ptr(ReadMem+$458), @ReadMem, 4, n);
    closeHandle(h);
  s:=s + inttostr(readmem);
  OpenDialog1.InitialDir:=s;
end;

end.
