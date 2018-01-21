unit Template.Track;

interface

uses
  Grijjy.Mvvm.Types;

type
  TTemplateTrack = class(TgoDataTemplate)
  public
    class function GetTitle(const AItem: TObject): String; override;
    class function GetDetail(const AItem: TObject): String; override;
  end;

implementation

uses
  System.SysUtils,
  Model.Track;

{ TTemplateTrack }

class function TTemplateTrack.GetDetail(const AItem: TObject): String;
var
  Track: TAlbumTrack absolute AItem;
begin
  Assert(AItem is TAlbumTrack);
  Result := Format('%d:%.2d', [Track.Duration.Minutes, Track.Duration.Seconds]);
end;

class function TTemplateTrack.GetTitle(const AItem: TObject): String;
begin
  Assert(AItem is TAlbumTrack);
  Result := TAlbumTrack(AItem).Name;
end;

end.
