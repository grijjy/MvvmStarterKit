unit Model;

interface

uses
  Model.Album,
  Data;

type
  { The "master" model that manages other models.
    This is a singleton, which you access through the Instance property. }
  TModel = class
  {$REGION 'Internal Declarations'}
  private class var
    FInstance: TModel;
    FDestroyed: Boolean;
  private
    class function GetInstance: TModel; inline; static;
  private
    FAlbums: TAlbums;
  private
    constructor CreateSingleton(const ADummy: Integer = 0);
    procedure LoadAlbums(const ASource: TArray<TDataAlbum>);
    procedure LoadTracks(const ASource: TArray<TDataTrack>;
      const AAlbum: TAlbum);
  public
    class constructor Create;
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    class property Instance: TModel read GetInstance;

    { Bindable properties }
    property Albums: TAlbums read FAlbums;
  end;

implementation

uses
  System.SysUtils,
  System.TimeSpan,
  System.Generics.Defaults,
  Model.Track;

{ TModel }

class constructor TModel.Create;
begin
  FInstance := nil;
  FDestroyed := False;
end;

constructor TModel.Create;
begin
  Assert(False, 'Do not create a TModel manually. Use TModel.Instance instead.');
end;

constructor TModel.CreateSingleton(const ADummy: Integer = 0);
{ The ADummy parameter is to avoid the compiler warning:
    Duplicate constructor 'TModel.Create' with identical parameters will be inacessible from C++ }
var
  DataBase: TDataBase;
begin
  inherited Create;
  FAlbums := TAlbums.Create(True);

  { Load the model from a "database". In reality, the data usually comes from a
    backend server or REST API.
    We use a Google Protocol Buffers file with data instead. }
  DataBase.Load;

  LoadAlbums(DataBase.Albums);

  { When DataBase goes out of scope, all its data will be released. }
end;

destructor TModel.Destroy;
begin
  FAlbums.Free;
  inherited;
end;

class destructor TModel.Destroy;
begin
  FDestroyed := True;
  FreeAndNil(FInstance);
end;

class function TModel.GetInstance: TModel;
begin
  if (FInstance = nil) then
  begin
    Assert(not FDestroyed, 'Should not access model after it has been destroyed');
    FInstance := TModel.CreateSingleton;
  end;
  Result := FInstance;
end;

procedure TModel.LoadAlbums(const ASource: TArray<TDataAlbum>);
var
  Src: TDataAlbum;
  Dst: TAlbum;
begin
  for Src in ASource do
  begin
    Dst := TAlbum.Create;
    Dst.Title := Src.Name;
    Dst.Artist := Src.ArtistName;
    Dst.RecordLabel := Src.RecordLabel;
    Dst.Copyright := Src.Copyright;
    Dst.ReleaseDate := Src.ReleaseDate;
    Dst.Notes := Src.Notes;
    Dst.BackgroundColor := $FF000000 or Src.BackgroundColor;
    Dst.TextColor1 := $FF000000 or Src.TextColor1;
    Dst.TextColor2 := $FF000000 or Src.TextColor2;
    Dst.TextColor3 := $FF000000 or Src.TextColor3;
    Dst.RawImage := Src.Image;
    LoadTracks(Src.Tracks, Dst);
    FAlbums.Add(Dst);
  end;

  FAlbums.Sort(TComparer<TAlbum>.Construct(
    function(const Left, Right: TAlbum): Integer
    begin
      Result := CompareText(Left.Title, Right.Title);
    end));
end;

procedure TModel.LoadTracks(const ASource: TArray<TDataTrack>;
  const AAlbum: TAlbum);
var
  Src: TDataTrack;
  Dst: TAlbumTrack;
begin
  for Src in ASource do
  begin
    Dst := AAlbum.AddTrack;
    Dst.Name := Src.Name;
    Dst.Duration := TTimeSpan.FromMilliseconds(Src.DurationMs);
    Dst.TrackNumber := Src.TrackNumber;
    Dst.Genres := Src.Genres;
  end;
end;

end.
