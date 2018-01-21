unit Tests.Grijjy.Mvvm.ValueConverters;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  DUnitX.TestFramework,
  Grijjy.Mvvm.Rtti,
  Grijjy.Mvvm.ValueConverters;

type
  TTestConverterBase = class
  private
    FIn: TgoValue;
    FOut: TgoValue;
  end;

type
  TTestTgoMinusOneConverter = class(TTestConverterBase)
  public
    [Test] procedure TestForward;
    [Test] procedure TestReverse;
  end;

type
  TTestTgoColorToAlphaColor = class(TTestConverterBase)
  public
    [Test] procedure TestForward;
    [Test] procedure TestReverse;
  end;

type
  TTestTgoAlphaColorToColor = class(TTestConverterBase)
  public
    [Test] procedure TestForward;
    [Test] procedure TestReverse;
  end;

type
  TTestTgoAlphaColorToVclColor = class(TTestConverterBase)
  public
    [Test] procedure TestForward;
    [Test] procedure TestReverse;
  end;

type
  TTestTgoVclColorToAlphaColor = class(TTestConverterBase)
  public
    [Test] procedure TestForward;
    [Test] procedure TestReverse;
  end;

implementation

uses
  System.UITypes,
  System.SysConst,
  System.SysUtils;

{ TTestTgoMinusOneConverter }

procedure TTestTgoMinusOneConverter.TestForward;
begin
  FIn := 42;
  FOut := TgoMinusOneConverter.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(41, FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoMinusOneConverter.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($123456788F, FOut.AsInt64);

  FIn := 3.5;
  FOut := TgoMinusOneConverter.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Float, FOut.ValueType);
  Assert.AreEqual<Double>(2.5, FOut.AsDouble);

  FIn := 'Foo';
  FOut := TgoMinusOneConverter.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Str, FOut.ValueType);
  Assert.AreEqual('Foo', FOut.AsString);
end;

procedure TTestTgoMinusOneConverter.TestReverse;
begin
  FIn := 42;
  FOut := TgoMinusOneConverter.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(43, FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoMinusOneConverter.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567891, FOut.AsInt64);

  FIn := 3.5;
  FOut := TgoMinusOneConverter.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Float, FOut.ValueType);
  Assert.AreEqual<Double>(4.5, FOut.AsDouble);

  FIn := 'Foo';
  FOut := TgoMinusOneConverter.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Str, FOut.ValueType);
  Assert.AreEqual('Foo', FOut.AsString);
end;

{ TTestTgoColorToAlphaColor }

procedure TTestTgoColorToAlphaColor.TestForward;
begin
  FIn := $123456;
  FOut := TgoColorToAlphaColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(Integer($FF123456), FOut.AsOrdinal);

  FIn := $78123456;
  FOut := TgoColorToAlphaColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(Integer($FF123456), FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoColorToAlphaColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567890, FOut.AsInt64);
end;

procedure TTestTgoColorToAlphaColor.TestReverse;
begin
  FIn := $123456;
  FOut := TgoColorToAlphaColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>($123456, FOut.AsOrdinal);

  FIn := $78123456;
  FOut := TgoColorToAlphaColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>($123456, FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoColorToAlphaColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567890, FOut.AsInt64);
end;

{ TTestTgoAlphaColorToColor }

procedure TTestTgoAlphaColorToColor.TestForward;
begin
  FIn := $123456;
  FOut := TgoAlphaColorToColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>($123456, FOut.AsOrdinal);

  FIn := $78123456;
  FOut := TgoAlphaColorToColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>($123456, FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoAlphaColorToColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567890, FOut.AsInt64);
end;

procedure TTestTgoAlphaColorToColor.TestReverse;
begin
  FIn := $123456;
  FOut := TgoAlphaColorToColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(Integer($FF123456), FOut.AsOrdinal);

  FIn := $78123456;
  FOut := TgoAlphaColorToColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(Integer($FF123456), FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoAlphaColorToColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567890, FOut.AsInt64);
end;

{ TTestTgoAlphaColorToVclColor }

procedure TTestTgoAlphaColorToVclColor.TestForward;
begin
  FIn := $123456;
  FOut := TgoAlphaColorToVclColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>($563412, FOut.AsOrdinal);

  FIn := $78123456;
  FOut := TgoAlphaColorToVclColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>($563412, FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoAlphaColorToVclColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567890, FOut.AsInt64);
end;

procedure TTestTgoAlphaColorToVclColor.TestReverse;
begin
  FIn := $123456;
  FOut := TgoAlphaColorToVclColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(Integer($FF563412), FOut.AsOrdinal);

  FIn := $78123456;
  FOut := TgoAlphaColorToVclColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(Integer($FF563412), FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoAlphaColorToVclColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567890, FOut.AsInt64);
end;

{ TTestTgoVclColorToAlphaColor }

procedure TTestTgoVclColorToAlphaColor.TestForward;
begin
  FIn := $123456;
  FOut := TgoVclColorToAlphaColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(Integer($FF563412), FOut.AsOrdinal);

  FIn := $78123456;
  FOut := TgoVclColorToAlphaColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>(Integer($FF563412), FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoVclColorToAlphaColor.ConvertSourceToTarget(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567890, FOut.AsInt64);
end;

procedure TTestTgoVclColorToAlphaColor.TestReverse;
begin
  FIn := $123456;
  FOut := TgoVclColorToAlphaColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>($563412, FOut.AsOrdinal);

  FIn := $78123456;
  FOut := TgoVclColorToAlphaColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Ordinal, FOut.ValueType);
  Assert.AreEqual<Integer>($563412, FOut.AsOrdinal);

  FIn := $1234567890;
  FOut := TgoVclColorToAlphaColor.ConvertTargetToSource(FIn);
  Assert.AreEqual<TgoValueType>(TgoValueType.Int64, FOut.ValueType);
  Assert.AreEqual($1234567890, FOut.AsInt64);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTgoMinusOneConverter);
  TDUnitX.RegisterTestFixture(TTestTgoColorToAlphaColor);
  TDUnitX.RegisterTestFixture(TTestTgoAlphaColorToColor);
  TDUnitX.RegisterTestFixture(TTestTgoAlphaColorToVclColor);
  TDUnitX.RegisterTestFixture(TTestTgoVclColorToAlphaColor);

end.
