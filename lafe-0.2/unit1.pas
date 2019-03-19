unit Unit1; 

{$mode delphi}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, DividerBevel,
  UBotloader,UUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    DividerBevel1: TDividerBevel;
    DividerBevel2: TDividerBevel;
    Image1: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    RichEdit1: TMemo;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RichEdit1Change(Sender: TObject);
  private
    { private declarations }
        _LoaderThread:TBotLoaderThread;
    _SentenceSplitter:TStringTokenizer;
            Procedure Add(s:string);
  public
    { public declarations }
            Procedure AddUserInput(s:string);
    Procedure AddBotReply(s:string);
    Procedure AddLogMessage(s:string);
  end; 

var
  Chat: TForm1;

implementation
Uses UPatternMatcher,UTemplateProcessor,UVariables,ULogging,LibXMLParser;

{$R *.lfm}

{ TForm1 }


Procedure TForm1.Add(s:string);
  begin
    RichEdit1.Lines.Add(s);
    RichEdit1.SelStart:=Length(RichEdit1.TExt);
    SendMessage(RichEdit1.Handle,EM_SCROLLCARET,0,0);
  end;

Procedure TForm1.AddUserInput(s:string);
  var name:string;
  begin

    RichEdit1.SelStart:=Length(RichEdit1.TExt);

    Add('> '+s);
    name:=Memory.getVar('name');
    if name='' then name:='user';
    Log.chatlog(name,s);
  end;

Procedure TForm1.AddBotReply(s:string);
  begin
    if s='' then exit;
    RichEdit1.SelStart:=Length(RichEdit1.TExt);

    Add(s);
    Log.Chatlog(Memory.GetProp('name'),s);

  end;
Procedure TForm1.AddLogMessage(s:string);
  begin
    RichEdit1.SelStart:=Length(RichEdit1.TExt);

    Add(s);
  end;
procedure TForm1.richedit1Change(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  reply:string;
  Match:TMatch;
  input:String;
  i:integer;
begin
  input:=Memo1.Text;
  AddUserInput(input);
  Memory.setVar('input',input);
  input:=Trim(ConvertWS(Preprocessor.process(' '+input+' '),true));

  _SentenceSplitter.SetDelimiter(SentenceSplitterChars); {update, if we're still loading}
  _SentenceSplitter.Tokenize(input);

  for i:=0 to _SentenceSplitter._count-1 do begin
    input:=Trim(_SentenceSplitter._tokens[i]);
    Match:=PatternMatcher.MatchInput(input);
    reply:=TemplateProcessor.Process(match);
    match.free;
  end;

  AddBotReply(reply);
  //AddLogMessage('Nodes traversed: '+inttostr(PatternMatcher._matchfault));
  Add('');
  reply:=PreProcessor.process(reply);
  _SentenceSplitter.SetDelimiter(SentenceSplitterChars);
  _SentenceSplitter.Tokenize(reply);

  Memory.setVar('that',_SentenceSplitter.GetLast);
  Memo1.Clear;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Log.Flush;
  BotLoader.load('robot.xml');
  _LoaderThread:=TBotLoaderThread.Create(true);
  _LoaderThread.Resume;
  _SentenceSplitter:=TStringTokenizer.Create(SentenceSplitterChars);
  memo1.Focused=true;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  if chat.Height <=200 then chat.height:=220;
  if chat.width<=580 then chat.width:=580;
end;



end.

