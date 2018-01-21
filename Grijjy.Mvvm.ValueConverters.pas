unit Grijjy.Mvvm.ValueConverters;

{ Some standard value converters. }

{$INCLUDE 'Grijjy.inc'}

interface

uses
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.Rtti;

type
  { A value converter that subtracts 1 from the source value.
    When run in reverse (target-to-source), it adds 1 to the target value. }
  TgoMinusOneConverter = class(TgoValueConverter)
  public
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; override;
    class function ConvertTargetToSource(const ATarget: TgoValue): TgoValue; override;
  end;

type
  { A value converter that converts a TColor to a (fully opaque) TAlphaColor.
    When run in reverse the Alpha value is ignored. }
  TgoColorToAlphaColor = class(TgoValueConverter)
  public
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; override;
    class function ConvertTargetToSource(const ATarget: TgoValue): TgoValue; override;
  end;

type
  { A value converter that converts a TAlphaColor to a TColor (discarding the
    Alpha part). When run in reverse the Alpha value is set to opaque. }
  TgoAlphaColorToColor = class(TgoValueConverter)
  public
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; override;
    class function ConvertTargetToSource(const ATarget: TgoValue): TgoValue; override;
  end;

type
  { A value converter that converts a TAlphaColor to a TColor for use with the
    VCL (ignoring the Alpha part). When run in reverse the Alpha value is set
    to opaque. VCL colors have the Red and Blue values swapped. }
  TgoAlphaColorToVclColor = class(TgoValueConverter)
  public
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; override;
    class function ConvertTargetToSource(const ATarget: TgoValue): TgoValue; override;
  end;

type
  { A value converter that converts a TColor for use with the VCL to a
    (fully opaque) TAlphaColor (discarding the Alpha part). When run in reverse
    the Alpha value is ignored. VCL colors have the Red and Blue values swapped. }
  TgoVclColorToAlphaColor = class(TgoValueConverter)
  public
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; override;
    class function ConvertTargetToSource(const ATarget: TgoValue): TgoValue; override;
  end;

implementation

uses
  System.SysConst,
  System.SysUtils;

function goSwapRB(const AValue: UInt32): Integer;
begin
  Result := ((AValue and $000000FF) shl 16)
         or ((AValue and $00FF0000) shr 16)
         or  (AValue and $FF00FF00);
end;

{ TgoMinusOneConverter }

class function TgoMinusOneConverter.ConvertSourceToTarget(
  const ASource: TgoValue): TgoValue;
begin
  case ASource.ValueType of
    TgoValueType.Ordinal:
      Result := TgoValue.CreateOrdinal(ASource.AsOrdinal - 1);

    TgoValueType.Int64:
      Result := TgoValue.CreateInt64(ASource.AsInt64 - 1);

    TgoValueType.Float:
      Result := TgoValue.CreateFloat(ASource.AsDouble - 1);
  else
    Result := ASource;
  end;
end;

class function TgoMinusOneConverter.ConvertTargetToSource(
  const ATarget: TgoValue): TgoValue;
begin
  case ATarget.ValueType of
    TgoValueType.Ordinal:
      Result := TgoValue.CreateOrdinal(ATarget.AsOrdinal + 1);

    TgoValueType.Int64:
      Result := TgoValue.CreateInt64(ATarget.AsInt64 + 1);

    TgoValueType.Float:
      Result := TgoValue.CreateFloat(ATarget.AsDouble + 1);
  else
    Result := ATarget;
  end;
end;

{ TgoColorToAlphaColor }

class function TgoColorToAlphaColor.ConvertSourceToTarget(
  const ASource: TgoValue): TgoValue;
begin
  if (ASource.ValueType = TgoValueType.Ordinal) then
    Result := TgoValue.CreateOrdinal(ASource.AsOrdinal or NativeInt($FF000000))
  else
    Result := ASource;
end;

class function TgoColorToAlphaColor.ConvertTargetToSource(
  const ATarget: TgoValue): TgoValue;
begin
  if (ATarget.ValueType = TgoValueType.Ordinal) then
    Result := TgoValue.CreateOrdinal(ATarget.AsOrdinal and $00FFFFFF)
  else
    Result := ATarget;
end;

{ TgoAlphaColorToColor }

class function TgoAlphaColorToColor.ConvertSourceToTarget(
  const ASource: TgoValue): TgoValue;
begin
  if (ASource.ValueType = TgoValueType.Ordinal) then
    Result := TgoValue.CreateOrdinal(ASource.AsOrdinal and $00FFFFFF)
  else
    Result := ASource;
end;

class function TgoAlphaColorToColor.ConvertTargetToSource(
  const ATarget: TgoValue): TgoValue;
begin
  if (ATarget.ValueType = TgoValueType.Ordinal) then
    Result := TgoValue.CreateOrdinal(ATarget.AsOrdinal or NativeInt($FF000000))
  else
    Result := ATarget;
end;

{ TgoAlphaColorToVclColor }

class function TgoAlphaColorToVclColor.ConvertSourceToTarget(
  const ASource: TgoValue): TgoValue;
begin
  if (ASource.ValueType = TgoValueType.Ordinal) then
    Result := TgoValue.CreateOrdinal(goSwapRB(ASource.AsOrdinal) and $00FFFFFF)
  else
    Result := ASource;
end;

class function TgoAlphaColorToVclColor.ConvertTargetToSource(
  const ATarget: TgoValue): TgoValue;
begin
  if (ATarget.ValueType = TgoValueType.Ordinal) then
    Result := TgoValue.CreateOrdinal(goSwapRB(ATarget.AsOrdinal) or NativeInt($FF000000))
  else
    Result := ATarget;
end;

{ TgoVclColorToAlphaColor }

class function TgoVclColorToAlphaColor.ConvertSourceToTarget(
  const ASource: TgoValue): TgoValue;
begin
  if (ASource.ValueType = TgoValueType.Ordinal) then
    Result := TgoValue.CreateOrdinal(goSwapRB(ASource.AsOrdinal) or NativeInt($FF000000))
  else
    Result := ASource;
end;

class function TgoVclColorToAlphaColor.ConvertTargetToSource(
  const ATarget: TgoValue): TgoValue;
begin
  if (ATarget.ValueType = TgoValueType.Ordinal) then
    Result := TgoValue.CreateOrdinal(goSwapRB(ATarget.AsOrdinal) and $00FFFFFF)
  else
    Result := ATarget;
end;

end.
