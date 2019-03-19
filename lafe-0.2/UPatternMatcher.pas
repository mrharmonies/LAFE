{Here resides the 'Graphmaster' of PASCALice, used to store & match the
 loaded AIML}

unit UPatternMatcher;

interface
uses classes,uUtils;
const
{these constants will be made into a separate class for handling user
 defined contexts}
  CNumContext=3;
  CContext:array[0..CNumContext-1] of string=
    ('<INPUT>','<THAT>','<TOPIC>');
type
{TContexts maintains a list of contexts, their order and variable bindings}
  TContexts=class
  end;
  
{TMatch stores information about a match, such as matched wildcards,
 or the resulting template}
  TMatch=class
    _m:array of array of string; {array for handling user defined context matches}
    _template:string;            {the activated category's template}
    _processed:string;           {the processed template}
    _path:string;                {the path of the activated category}
    _fifo:boolean;               {behaviour of get method}
    constructor create;
    procedure add(context:integer;s:string);  {adds a matched wildcard of a context}
    function get(context:integer;i:integer):string;overload;
    function count(context:integer):integer;   {the number of 'stars' in the context}
    {function get(context:integer):string);overload;}

  end;
  TPatternNode=class
    _pattern:string;           {the word this node represents, can be a wildcard or a context separator}
    _context:integer;          {the id of the context}
    _template:string;          {if this node is a leaf node, contains the template}
    _path:string;              {if leaf node, then it's the path to the category it represents}
    //_file:string;
    _parent:TPatternNode;      {not currently used}
    _childs:array of TStringList; {list of childcontexts, will probably need replacing by custom container}
    _count:array of integer;      {number of childnodes in each context}
    constructor create(pattern:string;parent:TPatternNode);

    //function add(n:TPatternNode):TPatternNode;overload; {not used; adds already created node object}
    //function add(p:String):TPatternNode;overload; {not used; adds node without context id}
    function add(p:String;context:integer):TPatternNode;overload; {creates and adds a node if there isn't one already present}

    {matches the tokens in input from token number depth, if sucessfull returns the matched childnode}
    function match(input:TStringList;depth:integer;var m:TMatch):TPatternNode;
    Procedure delete(context:integer;i:integer); {delete &free child node i}
    Procedure clear;             {free all child nodes recursively}
    function contains(context:integer;p:string):integer; {returns index of child node with the pattern p}
    //function get(i:integer):TpatternNode;overload; {returns child node i}
    //function get(p:string):TpatternNode;overload;  {returns child node with pattern p}

    function get(context:integer; i:integer):TPatternNode;overload;
    function get(context:integer;p:string):TPatternNode;overload;

  end;

  TPatternMatcher=class
    _root:TPatternNode;
    _tokenizer:TStringTokenizer;
    _SentenceTokenizer:TStringTokenizer;
    _count:integer;
    _locked:boolean;
    _matchfault:integer;
    procedure add(path:string;t:string);
    function match:TMatch;overload;
    function match(path:string):TMatch;overload;
    function match(input,that,topic:string):TMatch;overload;
    function matchinput(input:string):TMatch;
    constructor Create;
    destructor destroy;override;
  end;
var
  PatternMatcher:TPatternMatcher;
  Nodecount:integer;
implementation
  uses SysUtils,UVariables;
  var matchfault:integer;
  constructor TMatch.create;
    var
      i:integer;
    begin
      _fifo:=false;
      _template:='';
      Setlength(_m,CNumContext);
      for i:=0 to CNumContext-1 do
        _m[i]:=nil
    end;
  procedure TMatch.Add(context:integer;s:string);
    begin
      setlength(_m[context],Length(_m[context])+1);
      _m[context,length(_m[context])-1]:=s;
    end;
  function TMatch.count(context:integer):integer;
    begin
      if (_m[context]=nil)or (context>=Cnumcontext) then
        result:=0
      else
        result:=length(_m[context]);
    end;
  function TMatch.get(context:integer;i:integer):string;
    begin
      if count(context)<i then begin
        result:='';
        exit;
      end;
      if _fifo then dec(i)
      else i:=count(context)-i;

      result:=_m[context,i];
    end;
  constructor TPatternNode.Create(pattern:string;parent:TPatternNode);
    begin
      _pattern:=pattern;
      _parent:=parent;
      _template:='';
      SetLength(_childs,CNumContext);
      SetLength(_count,CNumContext);
      inc(nodecount);
    end;
  function TPatternNode.Contains(context:integer;p:string):integer;
    begin
      if _childs[context]<>nil then
        result:=_childs[context].IndexOf(p)
      else
        result:=-1;
    end;


  function TPatternNode.get(context:integer;i:integer):TPatternNode;
    begin
      if i>=_Count[context] then result := nil else
        result:=TPatternnode(_childs[context].Objects[i]);
    end;
  function TPatternNode.get(context:integer;p:string):TPatternNode;
    var i:integer;
    begin
      if _count[context]=0 then begin
        result:=nil;
        exit;
      end;
      I:=_childs[context].indexof(p);
      if i>=0 then result:=TPatternNode(_Childs[context].Objects[i])
      else result:=nil;

    end;
(*
  function TPatternNode.Add(n:TPatternNode):TPatternNode;
    var
      i:integer;
    begin
      if _childs=nil then begin
        _childs:=TStringList.Create;
        _childs.sorted:=true;
        _childs.duplicates:=dupIgnore;
      end;
      i:=_childs.indexof(n._pattern);
      if i<0 then begin
        _childs.AddObject(n._pattern,n);
        result:=n;
      end else begin
        result:=TPatternNode(_childs.Objects[i]);
        n.Destroy;
      end;
      _count:=_childs.count;
    end;
*)
(*
  function TPatternNode.Add(p:string):TPatternNode;
    var
      i:integer;
      n:TPatternnode;
    begin
      if _childs=nil then begin
        _childs:=TStringList.Create;
        _childs.sorted:=true;
        _childs.duplicates:=dupIgnore;
      end;

      i:=_childs.indexof(p);
      if i<0 then begin {create new child node}
        n:=TPatternNode.create(p,self);
        _childs.AddObject(p,n);
        result:=n;
      end else begin {this node already exists, just return it}
        result:=TPatternNode(_childs.Objects[i]);
      end;
      _count:=_childs.count;
    end;
*)
  function TPatternNode.Add(p:string;context:integer):TPatternNode;
    var
      i:integer;
      n:TPatternnode;
    begin
      if _childs[context]=nil then begin
        _childs[context]:=TStringList.Create;
        _childs[context].sorted:=true;
        _childs[context].duplicates:=dupIgnore;
      end;

      i:=_childs[context].indexof(p);
      if i<0 then begin {create new child node}
        n:=TPatternNode.create(p,self);
        _childs[context].AddObject(p,n);
        result:=n;
      end else begin {child node already exists}
        result:=TPatternNode(_childs[context].Objects[i]);
      end;
      result._context:=context;
      _count[context]:=_childs[context].count;
    end;
  function TPatternNode.match(input:TStringList;depth:integer;var m:TMatch):TPatternNode;
    var
      n:TPatternNode;
      i:integer;
      wcl:integer; {number of words in the current wildcard, starting from depth}
      wc:string; {matched wildcard}
      newcontext:integer;
    begin
      inc(matchfault);
      result:=nil;
      wcl:=0;
      wc:='';
      {check current context from input (get the variable bound to the context if we've reached the end)}
      newcontext:=_context;
      for i:=_context to CNumContext-1 do
        if ansisametext(input[depth],CContext[i]) then begin
          newcontext:=i;
          break;
        end;
      if _count[newcontext]=0 then begin
        result:=nil;
        exit;
      end;
      n:=get(newcontext,'_');
      {try to match the underscore wildcard}
      if (n<>nil) then begin
        repeat {try to match words with the wildcard}
          if (depth+wcl<input.Count-1) then
            result:=n.Match(input,depth+wcl+1,m) {we haven't reached the end of the input, and there's still childnodes to try}
          else if n._template<>'' then
            result:=n; {we've found a category}
          inc(wcl);
        until (result<> nil) or (depth+wcl>=input.Count); {until we match or we reach end of input}
        if result<> nil then begin {if we matched}
          if m=nil then m.create;  {just in case this is the first match}
          for i:=depth to depth+wcl-1 do
            wc:=wc+input[i]+' '; {construct the individual words into the matched wildcard}
          m.add(_context,wc); {add the matched wildcard to the match using the current context}
          exit;
        end;
      end;

      {try to match the exact word}
      n:=get(newcontext,input[depth]);
      if n<>nil then begin
        if depth<input.Count-1 then {check if we aren't at the last word in the input}
          result:=n.Match(input,depth+1,m)
        else if n._template<>'' then
          result:=n;
        if result<> nil then exit;
      end;

      wcl:=0;
      n:=get(newcontext,'*');
      {try to match the * wildcard}
      if n<>nil then begin
        repeat
          if (depth+wcl<input.Count-1) then
            result:=n.Match(input,depth+wcl+1,m)
          else if n._template<>'' then
            result:=n;
          inc(wcl);
        until (result<> nil) or (depth+wcl>=input.Count);
        if result<>nil then begin
          if m=nil then m.create;
          for i:=depth to depth+wcl-1 do
            wc:=wc+input[i]+' ';
          m.add(_context,wc);
          exit;
        end;
      end;


    end;
  procedure TPatternnode.delete(context:integer;I:integer);
    begin
      if i<=_count[context] then begin
        TPatternNode(_childs[context].Objects[i]).clear;
        _childs[context].Delete(i);
        dec(_count[context]);
      end;
    end;
  Procedure TPatternnode.clear;
    var i:integer;
    begin
      for i:=0 to CNumContext-1 do
        while _count[i] >0 do delete(i,0);
    end;
  constructor TPatternMatcher.Create;
    begin
      _root:=TPatternNode.Create('',nil);
      _tokenizer:=TStringTokenizer.create(' ');

      _locked:=false;
    end;
  destructor TPatternMatcher.destroy;
    var
      N:TPatternNode;
    begin
      _tokenizer.free;
      N:=_root;
      n.clear;
      n.destroy;
      inherited destroy;
    end;
  procedure TPatternMatcher.Add(path:string;t:string);
    var
      i:integer;
      n:Tpatternnode;
      c:integer;
      ci:integer;
    begin
      while _locked do ;
      _locked:=true;
      Path:=Trim(path);
      n:=_root;
      _Tokenizer.tokenize(path);
      c:=0; {context=<input>}
      for i:=0 to _Tokenizer._count-1 do begin
        for ci:=0 to CNumContext-1 do
          if AnsiSameText(_Tokenizer._tokens[i],CContext[ci]) then
            c:=ci;

        n:=n.add(_Tokenizer._tokens[i],c);
      end;
      if n._template='' then begin
        n._template:=t;
        n._path:=path;
        inc(_count);
      end;
      _locked:=false;
    end;
  function TPatternMatcher.Match:TMatch;
    var
      input,that,topic:string;
      i:integer;
    begin
      result:=nil;
      if not assigned(_SentenceTokenizer) then
        _SentenceTokenizer:=TStringTokenizer.Create(UUtils.SentenceSplitterChars);

      input:=Memory.getVAr('input');
      input:=Preprocessor.process(' '+input+' ');
      input:=Trim(input);

      _SentenceTokenizer.Tokenize(input);
      For i:=0 to _sentenceTokenizer._count-1 do begin
        that:=Memory.getVar('that');
        if that='' then that:='*';
        topic:=Memory.getVar('topic');
        if topic='' then topic:='*';
        input:=trim(_sentenceTokenizer._Tokens[i]);
        if (input<>' ') and (input<>'') then begin
          if result<>nil then begin
            result.free;
          end;
          result:=Match(input,that,topic);

        end;
      end;
    end;
  function TPatternMatcher.Match(path:string):TMatch;
    var
      n:Tpatternnode;
    begin
      while _locked do ;
      _locked:=true;
      Matchfault:=0;
      Path:=Trim(path);
      n:=_root;
      _Tokenizer.tokenize(path);
      result:=TMatch.create;
      n:=n.match(_tokenizer._tokens,0,result);
      _locked:=false;
      if n<> nil then begin
        result._template:=n._template;
        result._path:=n._path;
      end;
      _matchfault:=matchfault;
      //Memory.Match:=Result;
      //result:=n._template;
      //result:=result + '//'+ inttostr(matchfault);
    end;
  function TPatternMatcher.Match(input,that,topic:string):TMatch;
    begin
      result:=Match(input+' <that> '+that+' <topic> '+topic);
    end;
  function TPatternMatcher.MatchInput(input:string):TMatch;
    var
      that,topic:string;
    begin
      that:=Memory.getVar('that');
      if that='' then that:='*';
      topic:=Memory.getVar('topic');
      if topic='' then topic:='*';
      result:=Match(input,that,topic);
    end;
begin
nodecount:=0;
end.
