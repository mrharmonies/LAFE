{This unit contains classes to process template elements}
unit UElements;

interface
implementation
uses
  UElementFActory,UPatternMatcher,UVariables,UAIMLLoader,UTemplateProcessor,
  LibXMLParser,SysUtils,classes,UUtils;

type
  TBotElement=class(TTEmplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TxStarElement=class(TTEmplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;
type
  TGetElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;
type
  TSetElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TDefaultElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TLearnElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;
type
  TSrElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TThinkElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TSraiElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TRandomElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TBrElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TConditionElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    function blockCondition(variable,value:string;Match:TMatch;Parser:TXMLParser):string;
    function blockSwitch(variable:string;Match:TMatch;Parser:TXMLParser):string;
    //function blockMulti(Match:TMatch;Parser:TXMLParser):string;

    procedure register;override;
  end;
type
  TCaseElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TThatElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TVersionElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TidElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TSizeElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TDateElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TGossipElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TInputElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TSubstElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TJScriptElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TSystemElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

type
  TforgetElement=class(TTemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;


  function TSetElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      name:string;
    begin
      name:=parser.CurAttr.Value('name');
      result:=ProcessContents(Match,Parser);
      result:=TrimWS(ConvertWs(result,true));
      Memory.setVar(name,result);
    end;
  procedure TSetElement.register;
    begin
      ElementFactory.register('set',self);
    end;

  function TBotElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=Memory.getProp(parser.CurAttr.Value('name'));
    end;
  procedure TBotElement.register;
    begin
      ElementFactory.register('bot',Self);
    end;
  function TGetElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=Memory.getVar(parser.CurAttr.Value('name'));
      if (Parser.CurPartType=ptEmptyTag) or
         (Parser.CurPartType=ptEndTag) then exit;
      if result<>'' then
        repeat until
          (not parser.Scan)or
          ((parser.CurPartType=ptEndTag)and
           (parser.CurName='get'))
      else
        result:=ProcessContents(Match,Parser);
    end;
  procedure TGetElement.register;
    begin
      ElementFactory.register('get',Self);
    end;

  function TxStarElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      context:integer;
      index:string;
    begin
      if parser.CurPartType<>ptEndTag then begin
        if parser.CurName='star' then context:=0;
        if parser.CurName='thatstar' then context:=1;
        if parser.CurName='topicstar' then context:=2;
        index:=Parser.CurAttr.Value('index');
        if index='' then index:='1';
        result:=Match.get(context,strtoint(index));
        result:=TrimWS(result);
      end else
        result:='';
    end;
  procedure TxStarElement.register;
    begin
      ElementFactory.register('star',self);
      ElementFactory.register('thatstar',self);
      ElementFactory.register('topicstar',self);
    end;

  function TDefaultElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      SetLength(result,Parser.CurFinal-Parser.CurStart+1);
      result:=StrLCopy(PCHar(result),Parser.CurStart,Parser.CurFinal-Parser.CurStart+1);
    end;
  procedure TDefaultElement.register;
    begin
      ElementFactory.registerdefault(Self);
    end;

  function TLearnElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:='';
      if parser.CurPartType=ptEmptyTag then exit;
      result:=ProcessContents(Match,Parser);
      if not assigned(AIMLLoader) then AIMLLoader:=TAIMLLoader.Create;
      AIMLLoader.load(result);
    end;
  procedure TLearnElement.register;
    begin
      ElementFactory.register('learn',Self);
    end;

  function TSrElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      temp:TMatch;
    begin
      temp:=PatternMatcher.Matchinput(Match.get(0,1));
      result:=TemplateProcessor.Process(temp);
      temp.free;
      if parser.curPartType=ptStartTag then
      while (parser.scan) and (parser.curparttype<>ptEndTag) and (parser.curName<>'sr') do;
    end;
  procedure TSrElement.register;
    begin
      ElementFactory.register('sr',Self);
    end;

  function TThinkElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      ProcessContents(Match,Parser);
      result:='';
    end;
  procedure TThinkElement.register;
    begin
      ElementFactory.register('think',Self);
    end;
  function TSraiElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      temp:TMatch;
    begin
      result:=ProcessContents(Match,Parser);
      if result='' then begin
        temp:=PatternMatcher.Matchinput(Match.get(0,1));
        result:=TemplateProcessor.Process(temp);
        temp.free;
      end else begin
        temp:=PatternMatcher.Matchinput(result);
        result:=TemplateProcessor.Process(temp);
        temp.free;
      end;
    end;
  procedure TSraiElement.register;
    begin
      ElementFactory.register('srai',Self);
    end;

  function TRandomElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      Options:Tlist;
      //Start:PChar;
      continue:PChar;
      //i:integer;
    begin
      Options:=Tlist.Create;
      result:='';
      While parser.Scan do begin
        case parser.CurPartType of
          ptStartTag:if (parser.CurName='li') then begin
                         Options.Add(Parser.CurFinal);
                         SkipElement(Parser);
                     end;
          ptEndTag:if (parser.CurName='random') then break;
        end;
      end;
      continue:=parser.curfinal;

      Parser.CurFinal:=Options[random(options.count)];
      Parser.CurName:='li';
      result:=ProcessContents(Match,Parser);
      Options.Free;
      parser.CurFinal:=Continue;
    end;
  procedure TRandomElement.register;
    begin
      Randomize;
      ElementFactory.register('random',Self);
    end;

  function TConditionElement.blockCondition(variable,value:string;Match:TMatch;Parser:TXMLParser):string;
    begin
      if AnsiCompareStr(Memory.getVar(variable),value)=0 then begin
        result:=ProcessContents(Match,Parser);
      end else begin
        result:='';
        SkipElement(Parser);
      end;
    end;
  function TConditionElement.blockSwitch(variable:string;Match:TMatch;Parser:TXMLParser):string;

    var
      curval:string;
      curvar:string;
      defaultitem:boolean;
      nvItem:boolean; {<li name="xx" value=""></li>}
      vItem:boolean;  {<li name="xx" value=""></li>}
    begin
      result:='';
      While (Parser.Scan) do begin
        case parser.CurPartType of
          ptStartTag,
          ptEmptyTag:if parser.CurName='li' then begin
                       curval:=Parser.CurAttr.Value('value');
                       curvar:=Parser.CurAttr.Value('name');
                       defaultItem:=(Parser.CurAttr.Count= 0);
                       nvItem:=(Parser.CurAttr.Count= 2)and AnsiSameStr(Memory.getVar(curvar),curval);
                       vItem:=(variable<>'') and AnsiSameStr(Memory.getVar(variable),curval);
                       if (defaultItem or nvItem or vItem)
                       then begin
                         result:=ProcessContents(Match,Parser);
                         SkipElement('condition',parser);
                         break;
                       end else
                         SkipElement(parser);
                     end;
        end;
      end;
    end;
  function TConditionElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      mainval:string;
      mainvar:string;
    begin
      mainval:=Parser.CurAttr.Value('value');
      mainvar:=Parser.CurAttr.Value('name');
      if (mainvar<>'') and (Parser.CurAttr.Node('value')<>nil) then begin
        result:=blockCondition(mainvar,mainval,Match,Parser);
      end else if (mainval='') then begin
        result:=blockSwitch(mainvar,Match,Parser);
      end;
    end;
  procedure TConditionElement.register;
    begin
      ElementFactory.register('condition',Self);
    end;
  function TBrElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=' ';
    end;
  procedure TBrElement.register;
    begin
      ElementFactory.register('br',Self);
    end;

  function TCaseElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      specificElement:string;
      upstr:string;
      i:integer;
    begin
      result:='';
      specificElement:=Parser.Curname;
      result:=ProcessContents(MAtch,Parser);
      result:=convertWS(result,true);
      if SpecificElement='uppercase' then
        result:=AnsiUpperCase(result)
      else if SpecificElement='lowercase' then
        result:=AnsiLowerCase(result)
      else if (SpecificElement='formal') and (result<>'')then begin
        upstr:=AnsiUpperCase(result);
        result[1]:=upstr[1];
        for i:=1 to length(result)-1 do
          if result[i]=' ' then
            result[i+1]:=upstr[i+1];
      end else if SpecificElement='sentence' then
        result[1]:=AnsiUpperCase(result)[1];
    end;
  procedure TCaseElement.register;
    begin
      ElementFactory.register('uppercase',Self);
      ElementFactory.register('lowercase',Self);
      ElementFactory.register('formal',Self);
      ElementFactory.register('sentence',Self);
    end;

  function TThatElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      thisTag:string;
    begin
      ThisTag:=Parser.CurName;
      if ThisTag='botsaid' then thistag:='that';
      if Parser.CurAttr.Count<>0 then result :=''
      else if ThisTag='that' then
        result:=Memory.getVar('that')
      else if ThisTag='justbeforethat' then
        result:=Memory.getVar('that',1);

      SkipElement(parser);
    end;
  procedure TThatElement.register;
    begin
      ElementFactory.register('that',Self);
      ElementFactory.register('justbeforethat',Self);
      ElementFactory.register('botsaid',Self);
    end;

  function TVersionElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:='PASCAlice v1.5';
      SkipElement(Parser);
    end;
  procedure TVersionElement.register;
    begin
      ElementFactory.register('version',Self);
      ElementFactory.register('getversion',Self);
    end;

  function TIdElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:='0';
      SkipElement(Parser);
    end;
  procedure TIdElement.register;
    begin
      ElementFactory.register('id',Self);
      ElementFactory.register('get_ip',Self);
    end;

  function TSizeElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=inttostr(PatternMatcher._count);
      SkipElement(Parser);
    end;
  procedure TSizeElement.register;
    begin
      ElementFactory.register('size',Self);
      ElementFactory.register('getsize',Self);
    end;

  function TDateElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=DatetoStr(now);
      skipElement(parser);
    end;
  procedure TDateElement.register;
    begin
      ElementFactory.register('date',Self);
    end;

  function TGossipElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=ProcessContents(Match,Parser);
      WrFile('gossip.log',result);
    end;
  procedure TGossipElement.register;
    begin
      ElementFactory.register('gossip',Self);
    end;

  function TInputElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      thisTag:string;
      i:integer;
      si:string;
    begin
      ThisTag:=Parser.CurName;
      SkipElement(Parser);

      if ThisTag='input' then begin
        si:=Parser.CurAttr.Value('index');
        if si<>'' then
          i:=strtoint(si)-1
        else
          i:=0;
        result:=Memory.getVar('input',i)
      end else if ThisTag='justthat' then
        result:=Memory.getVar('input',1)
      else if ThisTag='beforethat' then
        result:=Memory.getVar('input',2);

    end;
  procedure TInputElement.register;
    begin
      ElementFactory.register('input',Self);
      ElementFactory.register('justthat',Self);
      ElementFactory.register('beforethat',Self);
    end;
  function TSubstElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      if parser.CurPartType=ptEmptyTag then
        result:=Match.get(0,1)
      else
        result:='';
    end;
  procedure TSubstElement.register;
    begin
      ElementFactory.register('person',Self);
      ElementFactory.register('person2',Self);
      ElementFactory.register('gender',Self);
    end;
  function TJScriptElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=Parser.CurAttr.Value('alt');
      SkipElement(parser);
    end;
  procedure TJScriptElement.register;
    begin
      ElementFactory.register('javascript',Self);
    end;
  function TSystemElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=Parser.CurAttr.Value('alt');;
      if result<>'' then SkipElement(parser);
    end;
  procedure TSystemElement.register;
    begin
      ElementFactory.register('system',Self);
    end;

  function TForgetElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:='';
      SkipElement(parser);
      Memory.ClearVars;
    end;
  procedure TForgetElement.register;
    begin
      ElementFactory.register('forget',Self);
    end;

begin
  if not assigned(ElementFactory) then ElementFactory:=TElementFactory.Create;
  TBotElement.Create;
  TDefaultElement.Create;
  TGetElement.Create;
  TxStarElement.Create;
  TLearnElement.Create;
  TSetElement.Create;
  TSrElement.Create;
  TThinkElement.Create;
  TSraiElement.Create;
  TRandomElement.Create;
  TConditionElement.Create;
  TBrElement.Create;
  TCaseElement.Create;
  TThatElement.Create;
  TVersionElement.Create;
  TIdElement.Create;
  TSizeElement.Create;
  TDateElement.Create;
  TGossipElement.Create;
  TInputElement.Create;
  TsubstElement.Create;
  TJscriptElement.Create;
  TsystemElement.Create;

  TForgetElement.Create;

end.
