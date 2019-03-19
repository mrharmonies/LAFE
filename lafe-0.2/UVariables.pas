unit UVariables;

interface
uses classes,UPatternMatcher;
type
  TMemory=class
    vars:TStringList;
    props:TStringList;
    bot_ID:string;   
    //Match:TMatch;
    constructor create;
    destructor Destroy; override;
    procedure setVar(name,value:string); overload; virtual;
    procedure setVar(name:string;index:integer;value:string); overload; virtual;
    function getVar(name:string):string; overload; virtual;
    function getVar(name:string;index:integer):string; overload; virtual;
    procedure ClearVars;


    function getProp(name:string):string;
    procedure setProp(name,value:string);

    Procedure Save;
    Procedure Load;
  end;
var Memory:Tmemory;
implementation
uses sysutils,ULogging;
  constructor TMemory.Create;
    begin
      inherited Create;
      vars:=TStringList.Create;
      vars.Duplicates:=dupError;
      vars.Sorted:=False;
      Props:=TStringList.Create;
      Props.Duplicates:=dupError;
      Props.Sorted:=False;
    end;
  destructor TMemory.Destroy;
    begin
      Save;
      vars.Free;
      inherited Destroy;
    end;
  procedure TMemory.setVar(name,value:string);
    begin
      setVar(name,0,value);
    end;
  procedure TMemory.setVar(name:string;index:integer;value:string);
    begin
      name:=name+'['+inttostr(index)+']';
      vars.values[name]:=value;
    end;

  function TMemory.getVar(name:string):string;
    begin
      result:=getVar(name,0);
    end;
  function TMemory.getVar(name:string;index:integer):string;
    begin
      name:=name+'['+inttostr(index)+']';
      result:=vars.Values[name];
    end;
  procedure TMemory.setprop(name,value:string);
    begin
      props.values[name]:=value;
    end;
  function TMemory.getProp(name:string):string;
    begin
      result:=props.Values[name];
    end;
  procedure TMemory.ClearVars;
    begin
      vars.Clear;
    end;

  Procedure TMemory.Save;
    var filename:string;
    begin
      filename:=bot_id+'.variables';
      Log.Log('variables','Saving variables for the bot '+bot_id);
      try
        Vars.SaveToFile(filename);
      except
        Log.Log('variables','Error while saving variables');
      end;
    end;
  Procedure TMemory.Load;
    var
      filename:string;
    begin
      filename:=bot_id+'.variables';
      if fileexists(filename) then begin
        Log.Log('variables','Loading variables for the bot '+bot_id);
        Vars.LoadFromFile(filename);
      end;
    end;

end.
