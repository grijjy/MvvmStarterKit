unit Grijjy.Mvvm.Rtti;

{$INCLUDE 'Grijjy.inc'}

{ Used internally for data bindings. }

interface

uses
  System.TypInfo;

type
  { The supported types that can be stored in a TgoValue. }
  TgoValueType = (
    { Unsupported type }
    Unsupported,

    { Ordinal types such as integers, characters, enums and sets. }
    Ordinal,

    { 64-bit integers }
    Int64,

    { Floating-point types (Single or Double).
      There is no support for Extended, Currency and Comp types. }
    Float,

    { Object type }
    Obj,

    { Unicode string type. There is no support for other types of strings. }
    Str);

type
  { Super lightweight TValue alternative.
    Can only be used in short-lived transactions (like copying properties values
    from one object to another).
    For managed types, TgoValue contains an unsafe reference, so you should not
    keep TgoValue's around. }
  TgoValue = record
  {$REGION 'Internal Declarations'}
  private type
    TValue = record
      case Byte of
        0: (FAsOrdinal: NativeInt);
        1: (FAsInt64: Int64);
        2: (FAsDouble: Double);
        3: (FAsPointer: Pointer);
    end;
  private
    FValueType: TgoValueType;
    FValue: TValue;
    FStringValue: String;
    {$IFDEF AUTOREFCOUNT}
    FObjectValue: TObject;
    {$ENDIF}
  private
    function GetAsDouble: Double; inline;
    function GetAsInt64: Int64; inline;
    function GetAsOrdinal: NativeInt; inline;
    procedure SetAsDouble(const Value: Double); inline;
    procedure SetAsInt64(const Value: Int64); inline;
    procedure SetFAsOrdinal(const Value: NativeInt); inline;
    function GetAsObject: TObject; inline;
    function GetAsString: String; inline;
    procedure SetAsObject(const Value: TObject); inline;
    procedure SetAsString(const Value: String); inline;
  private
    procedure ClearManagedValues; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an ordinal value }
    class function CreateOrdinal(const AValue: NativeInt): TgoValue; static; inline;

    { Creates an Int64 value }
    class function CreateInt64(const AValue: Int64): TgoValue; static; inline;

    { Creates a floating-point value }
    class function CreateFloat(const AValue: Double): TgoValue; static; inline;

    { Creates an object value }
    class function CreateObject(const AValue: TObject): TgoValue; static; inline;

    { Creates a string value }
    class function CreateString(const AValue: String): TgoValue; static; inline;

    { Implicitly creates an ordinal value. }
    class operator Implicit(const AValue: Integer): TgoValue; inline;

    { Implicitly creates an Int64 value. }
    class operator Implicit(const AValue: Int64): TgoValue; inline;

    { Implicitly creates a floating-point value. }
    class operator Implicit(const AValue: Double): TgoValue; inline;

    { Implicitly creates an object value. }
    class operator Implicit(const AValue: TObject): TgoValue; inline;

    { Implicitly creates a string value. }
    class operator Implicit(const AValue: String): TgoValue; inline;

    { The object value, typecast to a specific object type.

      Raises:
        EInvalidCast when getting and ValueType <> Obj or if the value is not
        of type T. }
    function AsType<T: class>: T; inline;

    { The type of the value }
    property ValueType: TgoValueType read FValueType write FValueType;

    { The ordinal value, as a native (32-bit or 64-bit) integer.

      Raises:
        EInvalidCast when getting and ValueType <> Ordinal. }
    property AsOrdinal: NativeInt read GetAsOrdinal write SetFAsOrdinal;

    { The Int64 value.

      Raises:
        EInvalidCast when getting and ValueType <> Int64. }
    property AsInt64: Int64 read GetAsInt64 write SetAsInt64;

    { The floating-point value as a Double.

      Raises:
        EInvalidCast when getting and ValueType <> Double. }
    property AsDouble: Double read GetAsDouble write SetAsDouble;

    { The object value.

      Raises:
        EInvalidCast when getting and ValueType <> Obj. }
    property AsObject: TObject read GetAsObject write SetAsObject;

    { The string value.

      Raises:
        EInvalidCast when getting and ValueType <> Str. }
    property AsString: String read GetAsString write SetAsString;
  end;

type
  { A function type that is used to retrieve a property value.

    Parameters:
      AInstance: the instance containing the property. Cannot be nil.
      APropInfo: information about the property to get. Cannot be nil.

    Returns:
      The value of the property. }
  TgoPropertyGetter = function(const AInstance: TObject;
    const APropInfo: PPropInfo): TgoValue;

type
  { A function type that is used to convert and set a property value.

    Parameters:
      AInstance: the instance containing the property. Cannot be nil.
      APropInfo: information about the property to set. Cannot be nil.
      AValue: the value to set the property to. }
  TgoPropertySetter = procedure(const AInstance: TObject;
    const APropInfo: PPropInfo; const AValue: TgoValue);

{ Returns a property getter appropriate for a given type.

  Parameters:
    AType: information about the type of the property.

  Returns:
    A getter to retrieve properties of the given type, or nil if the type
    is unsupported. }
function goGetPropertyGetter(const AType: PTypeInfo): TgoPropertyGetter;

{ Returns a property setter that also converts a property from a source type to
  a target type if needed.

  Parameters:
    ASourceType: the type of the source property.
    ATargetType: the type of the target property.

  Returns:
    A setter that sets a property and converts it if needed, or nil if the
    source or target type is unsupported.

  The setter tries to convert between all types, even when Delphi's TValue type
  would not be able to convert it. For example, a Double can be converted to an
  Integer, but it will truncate the result. Likewise, a string can be converted
  to an Integer or Double (using US format settings), but the result will be 0
  if the string does not contain a valid number. }
function goGetPropertySetter(const ASourceType, ATargetType: PTypeInfo): TgoPropertySetter; overload;
function goGetPropertySetter(const ASourceType: TgoValueType;
  const ATargetType: PTypeInfo): TgoPropertySetter; overload;

implementation

uses
  System.SysConst,
  System.SysUtils,
  Grijjy.SysUtils;

{ TgoValue }

function TgoValue.AsType<T>: T;
var
  Obj: TObject;
begin
  Obj := AsObject;
  if (Obj = nil) then
    Result := nil
  else
    Result := Obj as T;
end;

procedure TgoValue.ClearManagedValues;
begin
  FStringValue := '';
  {$IFDEF AUTOREFCOUNT}
  FObjectValue := nil;
  {$ENDIF}
end;

class function TgoValue.CreateFloat(const AValue: Double): TgoValue;
begin
  Result.FValueType := TgoValueType.Float;
  Result.FValue.FAsDouble := AValue;
end;

class function TgoValue.CreateInt64(const AValue: Int64): TgoValue;
begin
  Result.FValueType := TgoValueType.Int64;
  Result.FValue.FAsInt64 := AValue;
end;

class function TgoValue.CreateObject(const AValue: TObject): TgoValue;
begin
  Result.FValueType := TgoValueType.Obj;
  {$IFDEF AUTOREFCOUNT}
  Result.FObjectValue := AValue;
  {$ELSE}
  Result.FValue.FAsPointer := AValue;
  {$ENDIF}
end;

class function TgoValue.CreateOrdinal(const AValue: NativeInt): TgoValue;
begin
  Result.FValueType := TgoValueType.Ordinal;
  Result.FValue.FAsOrdinal := AValue;
end;

class function TgoValue.CreateString(const AValue: String): TgoValue;
begin
  Result.FValueType := TgoValueType.Str;
  Result.FStringValue := AValue;
end;

function TgoValue.GetAsDouble: Double;
begin
  if (FValueType <> TgoValueType.Float) then
    raise EInvalidCast.CreateRes(@SInvalidCast);
  Result := FValue.FAsDouble;
end;

function TgoValue.GetAsInt64: Int64;
begin
  if (FValueType <> TgoValueType.Int64) then
    raise EInvalidCast.CreateRes(@SInvalidCast);
  Result := FValue.FAsInt64;
end;

function TgoValue.GetAsObject: TObject;
begin
  if (FValueType <> TgoValueType.Obj) then
    raise EInvalidCast.CreateRes(@SInvalidCast);
  {$IFDEF AUTOREFCOUNT}
  Result := FObjectValue;
  {$ELSE}
  Result := FValue.FAsPointer;
  {$ENDIF}
end;

function TgoValue.GetAsOrdinal: NativeInt;
begin
  if (FValueType <> TgoValueType.Ordinal) then
    raise EInvalidCast.CreateRes(@SInvalidCast);
  Result := FValue.FAsOrdinal;
end;

function TgoValue.GetAsString: String;
begin
  if (FValueType <> TgoValueType.Str) then
    raise EInvalidCast.CreateRes(@SInvalidCast);
  Result := FStringValue;
end;

class operator TgoValue.Implicit(const AValue: Int64): TgoValue;
begin
  Result.FValueType := TgoValueType.Int64;
  Result.FValue.FAsInt64 := AValue;
end;

class operator TgoValue.Implicit(const AValue: Integer): TgoValue;
begin
  Result.FValueType := TgoValueType.Ordinal;
  Result.FValue.FAsOrdinal := AValue;
end;

class operator TgoValue.Implicit(const AValue: Double): TgoValue;
begin
  Result.FValueType := TgoValueType.Float;
  Result.FValue.FAsDouble := AValue;
end;

class operator TgoValue.Implicit(const AValue: String): TgoValue;
begin
  Result.FValueType := TgoValueType.Str;
  Result.FStringValue := AValue;
end;

class operator TgoValue.Implicit(const AValue: TObject): TgoValue;
begin
  Result.FValueType := TgoValueType.Obj;
  {$IFDEF AUTOREFCOUNT}
  Result.FObjectValue := AValue;
  {$ELSE}
  Result.FValue.FAsPointer := AValue;
  {$ENDIF}
end;

procedure TgoValue.SetAsDouble(const Value: Double);
begin
  ClearManagedValues;
  FValueType := TgoValueType.Float;
  FValue.FAsDouble := Value;
end;

procedure TgoValue.SetAsInt64(const Value: Int64);
begin
  ClearManagedValues;
  FValueType := TgoValueType.Int64;
  FValue.FAsInt64 := Value;
end;

procedure TgoValue.SetAsObject(const Value: TObject);
begin
  ClearManagedValues;
  FValueType := TgoValueType.Obj;
  {$IFDEF AUTOREFCOUNT}
  FObjectValue := Value;
  {$ELSE}
  FValue.FAsPointer := Value;
  {$ENDIF}
end;

procedure TgoValue.SetAsString(const Value: String);
begin
  ClearManagedValues;
  FValueType := TgoValueType.Str;
  FStringValue := Value;
end;

procedure TgoValue.SetFAsOrdinal(const Value: NativeInt);
begin
  ClearManagedValues;
  FValueType := TgoValueType.Ordinal;
  FValue.FAsOrdinal := Value;
end;

{ Globals }

const
  TYPE_KIND_TO_VALUE_TYPE: array [TTypeKind] of TgoValueType = (
    TgoValueType.Unsupported,  // tkUnknown
    TgoValueType.Ordinal,      // tkInteger
    TgoValueType.Ordinal,      // tkChar
    TgoValueType.Ordinal,      // tkEnumeration
    TgoValueType.Float,        // tkFloat
    TgoValueType.Unsupported,  // tkString
    TgoValueType.Ordinal,      // tkSet
    TgoValueType.Obj,          // tkClass
    TgoValueType.Unsupported,  // tkMethod
    TgoValueType.Ordinal,      // tkWChar
    TgoValueType.Unsupported,  // tkLString
    TgoValueType.Unsupported,  // tkWString
    TgoValueType.Unsupported,  // tkVariant
    TgoValueType.Unsupported,  // tkArray
    TgoValueType.Unsupported,  // tkRecord
    TgoValueType.Unsupported,  // tkInterface
    TgoValueType.Int64,        // tkInt64
    TgoValueType.Unsupported,  // tkDynArray
    TgoValueType.Str,          // tkUString,
    TgoValueType.Unsupported,  // tkClassRef
    TgoValueType.Ordinal,      // tkPointer
    TgoValueType.Unsupported); // tkProcedure

{ Property Getters }

function GetPropertyOrdinal(const AInstance: TObject; const APropInfo: PPropInfo): TgoValue;
begin
  Result := TgoValue.CreateOrdinal(GetOrdProp(AInstance, APropInfo));
end;

function GetPropertyInt64(const AInstance: TObject; const APropInfo: PPropInfo): TgoValue;
begin
  Result := TgoValue.CreateInt64(GetInt64Prop(AInstance, APropInfo));
end;

function GetPropertyDouble(const AInstance: TObject; const APropInfo: PPropInfo): TgoValue;
begin
  Result := TgoValue.CreateFloat(GetFloatProp(AInstance, APropInfo));
end;

function GetPropertyObject(const AInstance: TObject; const APropInfo: PPropInfo): TgoValue;
begin
  Result := TgoValue.CreateObject(GetObjectProp(AInstance, APropInfo));
end;

function GetPropertyString(const AInstance: TObject; const APropInfo: PPropInfo): TgoValue;
begin
  Result := TgoValue.CreateString(GetStrProp(AInstance, APropInfo));
end;

{ Property Setters (with conversion) }

procedure OrdToOrd(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetOrdProp(AInstance, APropInfo, AValue.AsOrdinal);
end;

procedure OrdToI64(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetInt64Prop(AInstance, APropInfo, AValue.AsOrdinal);
end;

procedure OrdToDbl(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetFloatProp(AInstance, APropInfo, AValue.AsOrdinal);
end;

procedure OrdToStr(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetStrProp(AInstance, APropInfo, IntToStr(AValue.AsOrdinal));
end;

procedure I64ToOrd(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetOrdProp(AInstance, APropInfo, AValue.AsInt64);
end;

procedure I64ToI64(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetInt64Prop(AInstance, APropInfo, AValue.AsInt64);
end;

procedure I64ToDbl(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetFloatProp(AInstance, APropInfo, AValue.AsInt64);
end;

procedure I64ToStr(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetStrProp(AInstance, APropInfo, IntToStr(AValue.AsInt64));
end;

procedure DblToOrd(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetOrdProp(AInstance, APropInfo, Trunc(AValue.AsDouble));
end;

procedure DblToI64(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetInt64Prop(AInstance, APropInfo, Trunc(AValue.AsDouble));
end;

procedure DblToDbl(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetFloatProp(AInstance, APropInfo, AValue.AsDouble);
end;

procedure DblToStr(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetStrProp(AInstance, APropInfo, FloatToStr(AValue.AsDouble, goUSFormatSettings));
end;

procedure ObjToObj(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetObjectProp(AInstance, APropInfo, AValue.AsObject);
end;

procedure ObjToStr(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
var
  Obj: TObject;
begin
  Obj := AValue.AsObject;
  if Assigned(Obj) then
    SetStrProp(AInstance, APropInfo, Obj.ToString)
  else
    SetStrProp(AInstance, APropInfo, '')
end;

procedure ObjToBool(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetOrdProp(AInstance, APropInfo, Ord(AValue.AsObject <> nil));
end;

procedure StrToOrd(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  {$IFDEF CPU32BITS}
  SetOrdProp(AInstance, APropInfo, StrToIntDef(AValue.AsString, 0));
  {$ELSE}
  SetOrdProp(AInstance, APropInfo, StrToInt64Def(AValue.AsString, 0));
  {$ENDIF}
end;

procedure StrToI64(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetInt64Prop(AInstance, APropInfo, StrToInt64Def(AValue.AsString, 0));
end;

procedure StrToDbl(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetFloatProp(AInstance, APropInfo, StrToFloatDef(AValue.AsString, 0, goUSFormatSettings));
end;

procedure StrToStr(const AInstance: TObject; const APropInfo: PPropInfo; const AValue: TgoValue);
begin
  SetStrProp(AInstance, APropInfo, AValue.AsString);
end;

const
  SETTERS: array [TgoValueType, TgoValueType] of TgoPropertySetter = (
  {               SourceType    TargetType

     Uns  Ordinal   Int64     Float     Object    String }
    (nil, nil,      nil,      nil,      nil,      nil     ),  // Unsupported
    (nil, OrdToOrd, OrdToI64, OrdToDbl, nil,      OrdToStr),  // Ordinal
    (nil, I64ToOrd, I64ToI64, I64ToDbl, nil,      I64ToStr),  // Int64
    (nil, DblToOrd, DblToI64, DblToDbl, nil,      DblToStr),  // Float
    (nil, nil,      nil,      nil,      ObjToObj, ObjToStr),  // Object
    (nil, StrToOrd, StrToI64, StrToDbl, nil,      StrToStr)); // String

function goGetPropertyGetter(const AType: PTypeInfo): TgoPropertyGetter;
begin
  Assert(Assigned(AType));
  case AType^.Kind of
    tkInteger, tkChar, tkWChar, tkEnumeration, tkSet:
      Result := GetPropertyOrdinal;

    tkInt64:
      Result := GetPropertyInt64;

    tkFloat:
      Result := GetPropertyDouble;

    tkClass:
      Result := GetPropertyObject;

    tkUString:
      Result := GetPropertyString;
  else
    Result := nil;
  end;
end;

function goGetPropertySetter(const ASourceType,
  ATargetType: PTypeInfo): TgoPropertySetter;
var
  SrcType, DstType: TgoValueType;
begin
  Assert(Assigned(ASourceType));
  Assert(Assigned(ATargetType));
  SrcType := TYPE_KIND_TO_VALUE_TYPE[ASourceType^.Kind];
  DstType := TYPE_KIND_TO_VALUE_TYPE[ATargetType^.Kind];
  Result := SETTERS[SrcType, DstType];

  { Special case: when SrcType is an object and DstType is a Boolean, then
    convert nil-objects to False and assigned objects to True. }
  if (not Assigned(Result)) and (SrcType = TgoValueType.Obj)
    and (DstType = TgoValueType.Ordinal) and (ATargetType = TypeInfo(Boolean))
  then
    Result := ObjToBool;
end;

function goGetPropertySetter(const ASourceType: TgoValueType;
  const ATargetType: PTypeInfo): TgoPropertySetter; overload;
var
  DstType: TgoValueType;
begin
  Assert(Assigned(ATargetType));
  DstType := TYPE_KIND_TO_VALUE_TYPE[ATargetType^.Kind];
  Result := SETTERS[ASourceType, DstType];
end;

end.
