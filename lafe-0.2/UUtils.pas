unit UUtils;
{general utility methods for parsing strings and TXMLParser elements}
interface
uses
  classes,LibXMLParser;
type
  TStringTokenizer=class
    _tokens:TStringList;
    _count:integer;
    _delim:string;
    _string:string;
    constructor Create(delimiter:String);
    procedure SetDelimiter(delimiter:String);
    procedure Tokenize(s:string);
    function getFirst:string;
    function getLast:string;
    function get(i:integer):string;

  end;

  TSimpleSubstituter=class
    _substFrom,
    _substTo:TStringlist;
    constructor create;
    destructor destroy;override;
    procedure add(_from,_to:string);
    function process(s:string):string;
  end;

procedure WrFile(fname:string;s:string);
procedure SkipElement(Name:string;Parser:TXMLParser);overload;
procedure SkipElement(Parser:TXMLParser);overload;
function  GetElementContents(Parser:TXMLParser):string;

Var
  SentenceSplitterChars:string;
  Preprocessor:TSimpleSubstituter;
implementation
  Uses SysUtils;
  procedure WrFile(fname:string;s:string);
    var
      t:System.text;
    begin
      assignfile(t,fname);
      if FileExists(fname) then
        append(t)
      else
        rewrite(t);
      writeln(t,s);
      flush(t);
      closefile(t);
    end;

  procedure SkipElement(Parser:TXMLParser);
    begin
      SkipElement(parser.CurName,parser);
    end;
  procedure SkipElement(Name:string;Parser:TXMLParser);
    var
      nested:integer;
    begin
      with parser do begin
        if (CurPartType=ptEmptyTag) and (CurName=name)then exit;
        nested:=0;
        while scan do
          case curparttype of
            ptstarttag:if CurName=name then inc(nested);
            ptEndTag:if Curname=name then
                       if nested=0 then break
                       else dec(nested);
          end;
      end;
  end;

  function GetElementContents(Parser:TXMLParser):string;
    begin
      with parser do begin
        if CurPartType<>ptContent then {??}
          result:=CurContent
        else begin
          if CurStart[0] in CWhitespace then result:=' ' else result:='';
          result:=result+CurContent;
          {if CurFinal[0] in CWhitespace then result:=result +' ';}
        end;
      end;
    end;

  constructor TStringTokenizer.create(delimiter:string);
    begin
      _delim:=delimiter;
      _Tokens:=TStringList.Create;
      _tokens.sorted:=false;
    end;
  procedure TStringTokenizer.Tokenize(s:string);
    var
      i:integer;
      thistoken:string;
      spos,epos:integer;
    begin
      i:=1;
      _string:=s;
      if _delim='' then _delim:=' ';
      _tokens.Clear;
      while i<= length(_string) do begin
        while isDelimiter(_delim,_string,i) do inc(i);
        if i>length(_string) then break;
        spos:=i;
        repeat inc(i);
        until (isDelimiter(_delim,_string,i))or (i> length(_string));
        epos:=i;
        ThisToken:=copy(_string,spos,epos-spos);
        _tokens.Add(ThisToken);
      end;
      _count:=_tokens.Count;
    end;
  procedure TStringTokenizer.SetDelimiter(delimiter:string);
    begin
      if delimiter<>_delim then begin
        _delim:=delimiter;
        Tokenize(_string);
      end;
    end;
  function TStringTokenizer.getLast:string;
    begin
      if _Tokens.count>0 then
        result:=_Tokens.Strings[_Tokens.count-1]
      else
        result:='';
    end;
  function TStringTokenizer.getFirst:string;
    begin
      if _Tokens.count>0 then
        result:=_Tokens.Strings[0]
      else
        result:='';
    end;
  function TStringTokenizer.get(i:integer):string;
    begin
      if _Tokens.count>i then
        result:=_Tokens.Strings[i]
      else
        result:='';
    end;
  constructor TSimpleSubstituter.create;
    begin
      inherited create;
      _substFrom:=TStringList.create;
      with _substFrom do begin
        Duplicates:=dupIgnore;
        Sorted:=false;
      end;
      _substTo:=TStringList.create;
      with _substTo do begin
        Duplicates:=dupIgnore;
        Sorted:=false;
      end;
    end;

  destructor TSimpleSubstituter.destroy;
    begin
      _substFrom.free;
      _substTo.free;
      inherited destroy;
    end;

  procedure TSimpleSubstituter.add(_from,_to:string);
    begin
      _substFrom.Add(_from);
      _substTo.Add(_to);
    end;
  function TSimpleSubstituter.process(s:string):string;
    var
      i:integer;
    begin
      result:=s;
      for i:=0 to _substFrom.Count-1 do
        result:=StringReplace(result,_substFrom[i],_substTo[i],[rfReplaceAll, rfIgnoreCase]);
    end;

end.
