unit UDebug;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UPatternMatcher, StdCtrls, ComCtrls, UVariables;

type
  TDebugForm = class(TForm)
    Edit1: TEdit;
    Memo1: TMemo;
    Label1: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    edName: TEdit;
    Label2: TLabel;
    edValue: TEdit;
    Label3: TLabel;
    Button2: TButton;
    Button6: TButton;
    ListBox1: TListBox;
    Button7: TButton;
    Button8: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DebugForm: TDebugForm;

implementation

uses UAIMLLoader,UTemplateprocessor, UBotLoader;



{$R *.DFM}

procedure TDebugForm.FormCreate(Sender: TObject);
begin
  ListBox1.Items:=memory.vars;
end;

procedure TDebugForm.Button2Click(Sender: TObject);
begin
  Memory.setVar(edName.text,edValue.text);
  ListBox1.Items:=Memory.vars;
end;

procedure TDebugForm.Button3Click(Sender: TObject);
var m:THeapStatus;
begin
m:=GetHeapStatus;
Label1.Caption:='Free:'+inttostr(m.TotalFree)+'  patterns:'+InttoStr(PatternMatcher._count);
end;

procedure TDebugForm.Button4Click(Sender: TObject);
var
  M:TMatch;
  i:integer;
begin
Memory.setvar('input',edit1.Text);
M:=PatternMatcher.match;
if m._template='' then
  Memo1.Lines.Add('No match')
else begin
  Memo1.Lines.Add('Pattern:'+M._path);
  for i:=1 to m.count(0) do
    Memo1.Lines.Add('star '+inttostr(i)+ ':'+ M.get(0,i));
  for i:=1 to m.count(1) do
    Memo1.Lines.Add('thatstar '+inttostr(i)+ ':'+ M.get(1,i));
  for i:=1 to m.count(2) do
    Memo1.Lines.Add('topicstar '+inttostr(i)+ ':'+ M.get(2,i));
  Memo1.Lines.Add('------------');
  Memo1.Lines.Add(m._template);
  Memo1.Lines.Add('------------');
  Memo1.Lines.Add(TemplateProcessor.Process(m));
  Memo1.Lines.Add('------------');
end;
m.Free;
end;

procedure TDebugForm.Button5Click(Sender: TObject);
//var
//  loader:TBotLoader;
begin
  TBotloaderThread.Create(false);
end;

procedure TDebugForm.Button7Click(Sender: TObject);
begin
  Memory.setProp(edName.text,edValue.text);
  ListBox1.Items:=Memory.vars;
end;

procedure TDebugForm.Button6Click(Sender: TObject);
begin
  edValue.Text:=Memory.getVar(edName.Text);
end;

procedure TDebugForm.Button8Click(Sender: TObject);
begin
  edValue.Text:=Memory.getProp(edName.Text);
end;

end.
