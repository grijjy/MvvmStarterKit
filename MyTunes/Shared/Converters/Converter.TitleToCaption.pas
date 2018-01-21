unit Converter.TitleToCaption;

interface

uses
  Grijjy.Mvvm.Rtti,
  Grijjy.Mvvm.Types;

type
  { Prefix an album title with the text 'Album: ' }
  TTitleToCaption = class(TgoValueConverter)
  public
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; override;
  end;

implementation

uses
  System.SysConst,
  System.SysUtils;

{ TTitleToCaption }

class function TTitleToCaption.ConvertSourceToTarget(
  const ASource: TgoValue): TgoValue;
begin
  Assert(ASource.ValueType = TgoValueType.Str);
  Result := 'Album: ' + ASource.AsString;
end;

end.
