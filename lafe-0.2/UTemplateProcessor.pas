unit UTemplateProcessor;

interface
uses
   LibXMLParser,UPatternMatcher,classes,UElementFactory;
type
  TTemplateProcessor=class
    function Process(Match:Tmatch):string;
  end;

  function ProcessContents(Match:TMatch;Parser:TXMLParser):string;
var
  TemplateProcessor:TTemplateProcessor;
implementation
uses
  UVariables,SysUtils,UUtils;

  function ProcessContents(Match:TMatch;Parser:TXMLParser):string;
    var
      name:string;
    begin
     result:='';
     if parser.CurPartType=ptEmptyTag then exit;
     name:=Parser.CurName;

     while parser.Scan do begin
       if (parser.CurPartType=ptendTag) and (parser.CurName=name) then
         break
       else
       case parser.CurPartType of
         ptContent:result:=result+GetElementContents(parser);
         ptEmptyTag,
         ptStartTag,
         ptEndTag:begin
                    if parser.CurStart[-1] in CWhitespace then result:=result+' ';         
                    result:=result+ElementFactory.get(parser.CurName).Process(Match,Parser);
                  end;
       end
     end;
    end;

function TTEmplateProcessor.Process(match:TMatch):string;
  var
    Parser:TXMLParser;
  begin
    result:='';
    if match._template='' then exit;
    Parser:=TXMLParser.Create;
    Parser.LoadFromBuffer(PChar(match._template));
    Parser.StartScan;
     while parser.Scan do begin
       case parser.CurPartType of
        ptContent:result:=result+GetElementContents(parser);
        ptEmptyTag,
        ptStartTag,
        ptEndTag:begin
                   if (parser.CurStart<>Parser.DocBuffer) and (parser.CurStart[-1] in CWhitespace) then result:=result+' ';
                   result:=result+ElementFactory.get(parser.CurName).Process(Match,Parser);
                 end;
      end
    end;
    Parser.Free;
    result:=ConvertWs(result,true);
    result:=Trim(result);
  end;
end.
