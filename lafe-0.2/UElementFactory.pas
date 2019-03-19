unit UElementFactory;

interface
uses LibXMLParser,UPatternMatcher,classes;
type
  {abstract base class for all template elements}
  TTemplateElement=class
    constructor Create;
    procedure Register;virtual;abstract;
    function Process(Match:TMatch;Parser:TXMLParser):string;virtual;abstract;
  end;

  {this is a container class that returns an instance of a template processing element}
  TElementFactory=class
    _Elements:TStringList;
    _default:TTemplateElement;
    constructor Create;
    destructor Destroy; override;
    procedure register(name:string;Element:TTemplateElement);

    procedure registerdefault(element:TTemplateElement);
    function get(name:string):TTEmplateElement;
  end;



var
  ElementFactory:TElementFactory;

implementation

  constructor TTemplateElement.Create;
    begin
      inherited create;
      register;
    end;
  constructor TElementFactory.Create;
    begin
      _Elements:=TStringlist.Create;
      _Elements.Sorted:=True;
    end;
  Destructor TElementFactory.Destroy;
    var
      i:integer;
      j:integer;
      this:TObject;
    begin
      for i:=0 to _Elements.Count-1 do
        if assigned(_Elements.Objects[i]) then begin {frees the current instance, and removes all references to it}
          This:=_Elements.Objects[i];
          _Elements.Objects[i].Free;
          for j:=i+1 to _Elements.Count-1 do
            if _Elements.Objects[j]=this then _Elements.Objects[j]:=nil;
        end;
      _Elements.Free;
      inherited destroy;
    end;
  Procedure TElementFactory.register(name:string;Element:TTemplateElement);
    begin
      _Elements.AddObject(name,Element);
    end;
  Procedure TElementFactory.registerdefault(Element:TTemplateElement);
    begin
      _default:=Element;
    end;
  function TElementFactory.get(name:string):TTEmplateElement;
    var
      i:integer;
    begin
      if _Elements.Find(name,i) then
        result:=_elements.Objects[i] as TTEmplateElement
      else
        result:=_default;
    end;
begin
  if not assigned(ElementFactory) then ElementFactory:=TElementFactory.Create;
end.
