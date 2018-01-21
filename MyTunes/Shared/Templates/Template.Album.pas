unit Template.Album;

interface

uses
  Grijjy.Mvvm.Types;

type
  TTemplateAlbum = class(TgoDataTemplate)
  public
    class function GetTitle(const AItem: TObject): String; override;
    class function GetDetail(const AItem: TObject): String; override;
  end;

implementation

uses
  Model.Album;

{ TTemplateAlbum }

class function TTemplateAlbum.GetDetail(const AItem: TObject): String;
begin
  Assert(AItem is TAlbum);
  Result := TAlbum(AItem).Artist;
end;

class function TTemplateAlbum.GetTitle(const AItem: TObject): String;
begin
  Assert(AItem is TAlbum);
  Result := TAlbum(AItem).Title;
end;

end.
