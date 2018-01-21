unit Tests.Grijjy.Mvvm.Rtti;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.TypInfo,
  DUnitX.TestFramework,
  Grijjy.Mvvm.Rtti;

type
  TTestTgoValue = class
  private
    FCUT: TgoValue;
  public
    [Test] procedure TestCreateOrdinal;
    [Test] procedure TestCreateInt64;
    [Test] procedure TestCreateFloat;
    [Test] procedure TestCreateObject;
    [Test] procedure TestCreateString;
    [Test] procedure TestImplicitInteger;
    [Test] procedure TestImplicitInt64;
    [Test] procedure TestImplicitDouble;
    [Test] procedure TestImplicitObject;
    [Test] procedure TestImplicitString;
  end;

type
  TTestMvvmRtti = class
  private
    FBar: TObject;
    FFoo: TObject;
    FPropIntValue: PPropInfo;
    FPropCharValue: PPropInfo;
    FPropEnumValue: PPropInfo;
    FPropSetValue: PPropInfo;
    FPropInt64Value: PPropInfo;
    FPropFloatValue: PPropInfo;
    FPropObjectValue: PPropInfo;
    FPropStringValue: PPropInfo;
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestPropertyGetter;
    [Test] procedure TestPropertySetter;
  end;

implementation

uses
  System.Classes,
  System.SysConst,
  System.SysUtils;

type
  TEnum = (Opt1, Opt2, Opt3);
  TSet = set of TEnum;

{$M+}
type
  TFoo = class
  strict private
    FValue: Integer;
  public
    constructor Create(const AValue: Integer);
  published
    property Value: Integer read FValue write FValue;
  end;

type
  TBar = class(TFoo)
  strict private
    FCharValue: Char;
    FEnumValue: TEnum;
    FSetValue: TSet;
    FInt64Value: Int64;
    FFloatValue: Double;
    [unsafe] FObjectValue: TObject;
    FStringValue: String;
  published
    property CharValue: Char read FCharValue write FCharValue;
    property EnumValue: TEnum read FEnumValue write FEnumValue;
    property SetValue: TSet read FSetValue write FSetValue;
    property Int64Value: Int64 read FInt64Value write FInt64Value;
    property FloatValue: Double read FFloatValue write FFloatValue;
    property ObjectValue: TObject read FObjectValue write FObjectValue;
    property StringValue: String read FStringValue write FStringValue;
  end;
{$M-}

type
  TStaticArray = array [0..1] of Integer;

{ TFoo }

constructor TFoo.Create(const AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

{ TTestTgoValue }

procedure TTestTgoValue.TestCreateFloat;
begin
  FCUT := TgoValue.CreateFloat(3.2);
  Assert.AreEqual<TgoValueType>(TgoValueType.Float, FCUT.ValueType);
  Assert.AreEqual(3.2, FCUT.AsDouble, 0.0001);

  Assert.WillRaise(procedure begin FCUT.AsOrdinal; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsInt64; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsObject; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsString; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsType<TObject>; end, EInvalidCast);
end;

procedure TTestTgoValue.TestCreateInt64;
begin
  FCUT := TgoValue.CreateInt64($1234567890);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FCUT.ValueType);
  Assert.AreEqual($1234567890, FCUT.AsInt64);

  Assert.WillRaise(procedure begin FCUT.AsOrdinal; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsDouble; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsObject; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsString; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsType<TObject>; end, EInvalidCast);
end;

procedure TTestTgoValue.TestCreateObject;
var
  Foo: TFoo;
begin
  Foo := TFoo.Create(42);
  try
    FCUT := TgoValue.CreateObject(Foo);
    Assert.AreEqual<TgoValueType>(TgoValueType.Obj, FCUT.ValueType);
    Assert.IsTrue(FCUT.AsObject = Foo);
    Assert.IsTrue(FCUT.AsType<TFoo> = Foo);

    Assert.WillRaise(procedure begin FCUT.AsOrdinal; end, EInvalidCast);
    Assert.WillRaise(procedure begin FCUT.AsInt64; end, EInvalidCast);
    Assert.WillRaise(procedure begin FCUT.AsDouble; end, EInvalidCast);
    Assert.WillRaise(procedure begin FCUT.AsString; end, EInvalidCast);
    Assert.WillRaise(procedure begin FCUT.AsType<TBar>; end, EInvalidCast);
  finally
    Foo.Free;
  end;
end;

procedure TTestTgoValue.TestCreateOrdinal;
begin
  FCUT := TgoValue.CreateOrdinal(42);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FCUT.ValueType);
  Assert.AreEqual<Integer>(42, FCUT.AsOrdinal);

  Assert.WillRaise(procedure begin FCUT.AsInt64; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsDouble; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsObject; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsString; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsType<TObject>; end, EInvalidCast);
end;

procedure TTestTgoValue.TestCreateString;
begin
  FCUT := TgoValue.CreateString('Foo');
  Assert.AreEqual<TgoValueType>(TgoValueType.Str, FCUT.ValueType);
  Assert.AreEqual('Foo', FCUT.AsString);

  Assert.WillRaise(procedure begin FCUT.AsOrdinal; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsInt64; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsObject; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsDouble; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsType<TObject>; end, EInvalidCast);
end;

procedure TTestTgoValue.TestImplicitDouble;
begin
  FCUT := 3.2;
  Assert.AreEqual<TgoValueType>(TgoValueType.Float, FCUT.ValueType);
  Assert.AreEqual(3.2, FCUT.AsDouble, 0.0001);

  Assert.WillRaise(procedure begin FCUT.AsOrdinal; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsInt64; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsObject; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsString; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsType<TObject>; end, EInvalidCast);
end;

procedure TTestTgoValue.TestImplicitInt64;
begin
  FCUT := $1234567890;
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FCUT.ValueType);
  Assert.AreEqual($1234567890, FCUT.AsInt64);

  Assert.WillRaise(procedure begin FCUT.AsOrdinal; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsDouble; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsObject; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsString; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsType<TObject>; end, EInvalidCast);
end;

procedure TTestTgoValue.TestImplicitInteger;
begin
  FCUT := 42;
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FCUT.ValueType);
  Assert.AreEqual<Integer>(42, FCUT.AsOrdinal);

  Assert.WillRaise(procedure begin FCUT.AsInt64; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsDouble; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsObject; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsString; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsType<TObject>; end, EInvalidCast);
end;

procedure TTestTgoValue.TestImplicitObject;
var
  Foo: TFoo;
begin
  Foo := TFoo.Create(42);
  try
    FCUT := Foo;
    Assert.AreEqual<TgoValueType>(TgoValueType.Obj, FCUT.ValueType);
    Assert.IsTrue(FCUT.AsObject = Foo);
    Assert.IsTrue(FCUT.AsType<TFoo> = Foo);

    Assert.WillRaise(procedure begin FCUT.AsOrdinal; end, EInvalidCast);
    Assert.WillRaise(procedure begin FCUT.AsInt64; end, EInvalidCast);
    Assert.WillRaise(procedure begin FCUT.AsDouble; end, EInvalidCast);
    Assert.WillRaise(procedure begin FCUT.AsString; end, EInvalidCast);
    Assert.WillRaise(procedure begin FCUT.AsType<TBar>; end, EInvalidCast);
  finally
    Foo.Free;
  end;
end;

procedure TTestTgoValue.TestImplicitString;
begin
  FCUT := 'Foo';
  Assert.AreEqual<TgoValueType>(TgoValueType.Str, FCUT.ValueType);
  Assert.AreEqual('Foo', FCUT.AsString);

  Assert.WillRaise(procedure begin FCUT.AsOrdinal; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsInt64; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsObject; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsDouble; end, EInvalidCast);
  Assert.WillRaise(procedure begin FCUT.AsType<TObject>; end, EInvalidCast);
end;

{ TTestMvvmRtti }

procedure TTestMvvmRtti.SetUp;
var
  Bar: TBar;
begin
  inherited;
  FFoo := TFoo.Create(1);
  Bar := TBar.Create(42);
  FBar := Bar;

  Bar.CharValue := 'X';
  Bar.EnumValue := TEnum.Opt2;
  Bar.SetValue := [TEnum.Opt1, TEnum.Opt3];
  Bar.Int64Value := $1234567890;
  Bar.FloatValue := 3.2;
  Bar.ObjectValue := FFoo;
  Bar.StringValue := 'Bar';

  FPropIntValue := GetPropInfo(TypeInfo(TBar), 'Value');
  Assert.IsTrue(FPropIntValue <> nil);

  FPropCharValue := GetPropInfo(TypeInfo(TBar), 'CharValue');
  Assert.IsTrue(FPropCharValue <> nil);

  FPropEnumValue := GetPropInfo(TypeInfo(TBar), 'EnumValue');
  Assert.IsTrue(FPropEnumValue <> nil);

  FPropSetValue := GetPropInfo(TypeInfo(TBar), 'SetValue');
  Assert.IsTrue(FPropSetValue <> nil);

  FPropInt64Value := GetPropInfo(TypeInfo(TBar), 'Int64Value');
  Assert.IsTrue(FPropInt64Value <> nil);

  FPropFloatValue := GetPropInfo(TypeInfo(TBar), 'FloatValue');
  Assert.IsTrue(FPropFloatValue <> nil);

  FPropObjectValue := GetPropInfo(TypeInfo(TBar), 'ObjectValue');
  Assert.IsTrue(FPropObjectValue <> nil);

  FPropStringValue := GetPropInfo(TypeInfo(TBar), 'StringValue');
  Assert.IsTrue(FPropStringValue <> nil);
end;

procedure TTestMvvmRtti.TearDown;
begin
  inherited;
  FBar.Free;
  FFoo.Free;
end;

procedure TTestMvvmRtti.TestPropertyGetter;
var
  Getter: TgoPropertyGetter;
  Value: TgoValue;
begin
  Getter := goGetPropertyGetter(TypeInfo(Integer));
  Assert.IsTrue(Assigned(Getter));
  Value := Getter(FBar, FPropIntValue);
  Assert.AreEqual<Integer>(42, Value.AsOrdinal);

  Getter := goGetPropertyGetter(TypeInfo(Char));
  Assert.IsTrue(Assigned(Getter));
  Value := Getter(FBar, FPropCharValue);
  Assert.AreEqual<Integer>(Ord('X'), Value.AsOrdinal);

  Getter := goGetPropertyGetter(TypeInfo(TEnum));
  Assert.IsTrue(Assigned(Getter));
  Value := Getter(FBar, FPropEnumValue);
  Assert.AreEqual<Integer>(Ord(TEnum.Opt2), Value.AsOrdinal);

  Getter := goGetPropertyGetter(TypeInfo(TSet));
  Assert.IsTrue(Assigned(Getter));
  Value := Getter(FBar, FPropSetValue);
  Assert.AreEqual<Integer>(5, Value.AsOrdinal);

  Getter := goGetPropertyGetter(TypeInfo(Int64));
  Assert.IsTrue(Assigned(Getter));
  Value := Getter(FBar, FPropInt64Value);
  Assert.AreEqual($1234567890, Value.AsInt64);

  Getter := goGetPropertyGetter(TypeInfo(Double));
  Assert.IsTrue(Assigned(Getter));
  Value := Getter(FBar, FPropFloatValue);
  Assert.AreEqual(3.2, Value.AsDouble, 0.00001);

  Getter := goGetPropertyGetter(TypeInfo(TBar));
  Assert.IsTrue(Assigned(Getter));
  Value := Getter(FBar, FPropObjectValue);
  Assert.IsTrue(Value.AsObject = FFoo);

  Getter := goGetPropertyGetter(TypeInfo(String));
  Assert.IsTrue(Assigned(Getter));
  Value := Getter(FBar, FPropStringValue);
  Assert.AreEqual('Bar', Value.AsString);

  Getter := goGetPropertyGetter(TypeInfo(IInterface));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(TNotifyEvent));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(RawByteString));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(Variant));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(TStaticArray));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(TBytes));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(TSearchRec));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(TClass));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(Pointer));
  Assert.IsFalse(Assigned(Getter));

  Getter := goGetPropertyGetter(TypeInfo(TProcedure));
  Assert.IsFalse(Assigned(Getter));
end;

procedure TTestMvvmRtti.TestPropertySetter;
var
  Setter: TgoPropertySetter;
  Bar, Bar1: TBar;
begin
  Bar := FBar as TBar;

  { Ordinal to other }
  Setter := goGetPropertySetter(TypeInfo(TEnum), TypeInfo(Word));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropIntValue, TgoValue.CreateOrdinal(Ord(TEnum.Opt3)));
  Assert.AreEqual(2, Bar.Value);

  Setter := goGetPropertySetter(TypeInfo(Integer), TypeInfo(Int64));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropInt64Value, 3);
  Assert.AreEqual<Int64>(3, Bar.Int64Value);

  Setter := goGetPropertySetter(TypeInfo(Integer), TypeInfo(Double));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropFloatValue, 4);
  Assert.AreEqual<Single>(4, Bar.FloatValue);

  Setter := goGetPropertySetter(TypeInfo(Integer), TypeInfo(TBar));
  Assert.IsFalse(Assigned(Setter));

  Setter := goGetPropertySetter(TypeInfo(Integer), TypeInfo(String));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropStringValue, 5);
  Assert.AreEqual('5', Bar.StringValue);

  Setter := goGetPropertySetter(TypeInfo(Integer), TypeInfo(TBytes));
  Assert.IsFalse(Assigned(Setter));

  { Int64 to other }
  Setter := goGetPropertySetter(TypeInfo(Int64), TypeInfo(Integer));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropIntValue, $1234567890);
  Assert.AreEqual($34567890, Bar.Value);

  Setter := goGetPropertySetter(TypeInfo(Int64), TypeInfo(Int64));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropInt64Value, Int64(6));
  Assert.AreEqual<Int64>(6, Bar.Int64Value);

  Setter := goGetPropertySetter(TypeInfo(Int64), TypeInfo(Double));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropFloatValue, Int64(7));
  Assert.AreEqual<Single>(7, Bar.FloatValue);

  Setter := goGetPropertySetter(TypeInfo(Int64), TypeInfo(TBar));
  Assert.IsFalse(Assigned(Setter));

  Setter := goGetPropertySetter(TypeInfo(Int64), TypeInfo(String));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropStringValue, Int64(8));
  Assert.AreEqual('8', Bar.StringValue);

  Setter := goGetPropertySetter(TypeInfo(Int64), TypeInfo(TBytes));
  Assert.IsFalse(Assigned(Setter));

  { Float to other }
  Setter := goGetPropertySetter(TypeInfo(Double), TypeInfo(Integer));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropIntValue, 9.9);
  Assert.AreEqual(9, Bar.Value);

  Setter := goGetPropertySetter(TypeInfo(Double), TypeInfo(Int64));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropInt64Value, 10.8);
  Assert.AreEqual<Int64>(10, Bar.Int64Value);

  Setter := goGetPropertySetter(TypeInfo(Double), TypeInfo(Double));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropFloatValue, 11.5);
  Assert.AreEqual<Single>(11.5, Bar.FloatValue);

  Setter := goGetPropertySetter(TypeInfo(Double), TypeInfo(TBar));
  Assert.IsFalse(Assigned(Setter));

  Setter := goGetPropertySetter(TypeInfo(Double), TypeInfo(String));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropStringValue, 12.3);
  Assert.AreEqual('12.3', Bar.StringValue);

  Setter := goGetPropertySetter(TypeInfo(Double), TypeInfo(TBytes));
  Assert.IsFalse(Assigned(Setter));

  { Object to other }
  Bar1 := TBar.Create(55);
  try
    Setter := goGetPropertySetter(TypeInfo(TBar), TypeInfo(Integer));
    Assert.IsFalse(Assigned(Setter));

    Setter := goGetPropertySetter(TypeInfo(TBar), TypeInfo(Int64));
    Assert.IsFalse(Assigned(Setter));

    Setter := goGetPropertySetter(TypeInfo(TBar), TypeInfo(Double));
    Assert.IsFalse(Assigned(Setter));

    Setter := goGetPropertySetter(TypeInfo(TBar), TypeInfo(TObject));
    Assert.IsTrue(Assigned(Setter));
    Setter(FBar, FPropObjectValue, Bar1);
    Assert.IsTrue(Bar.ObjectValue = Bar1);

    Setter := goGetPropertySetter(TypeInfo(TBar), TypeInfo(String));
    Assert.IsTrue(Assigned(Setter));
    Setter(FBar, FPropStringValue, Bar1);
    Assert.AreEqual('TBar', Bar.StringValue);
    Setter(FBar, FPropStringValue, nil);
    Assert.AreEqual('', Bar.StringValue);

    Setter := goGetPropertySetter(TypeInfo(TBar), TypeInfo(TBytes));
    Assert.IsFalse(Assigned(Setter));
  finally
    Bar1.Free;
  end;

  { String to other }
  Setter := goGetPropertySetter(TypeInfo(String), TypeInfo(Integer));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropIntValue, '13');
  Assert.AreEqual(13, Bar.Value);
  Setter(FBar, FPropIntValue, '13.1');
  Assert.AreEqual(0, Bar.Value);

  Setter := goGetPropertySetter(TypeInfo(String), TypeInfo(Int64));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropInt64Value, '14');
  Assert.AreEqual<Int64>(14, Bar.Int64Value);
  Setter(FBar, FPropInt64Value, '14.2');
  Assert.AreEqual<Int64>(0, Bar.Int64Value);

  Setter := goGetPropertySetter(TypeInfo(String), TypeInfo(Double));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropFloatValue, '15.5');
  Assert.AreEqual<Single>(15.5, Bar.FloatValue);

  Setter := goGetPropertySetter(TypeInfo(String), TypeInfo(TBar));
  Assert.IsFalse(Assigned(Setter));

  Setter := goGetPropertySetter(TypeInfo(String), TypeInfo(String));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropStringValue, 'Foo');
  Assert.AreEqual('Foo', Bar.StringValue);

  Setter := goGetPropertySetter(TypeInfo(String), TypeInfo(TBytes));
  Assert.IsFalse(Assigned(Setter));

  { Special case: Object to Boolean }
  Setter := goGetPropertySetter(TypeInfo(TBar), TypeInfo(Boolean));
  Assert.IsTrue(Assigned(Setter));
  Setter(FBar, FPropIntValue, Bar);
  Assert.AreEqual(1, Bar.Value);
  Setter(FBar, FPropIntValue, nil);
  Assert.AreEqual(0, Bar.Value);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTgoValue);
  TDUnitX.RegisterTestFixture(TTestMvvmRtti);

end.
