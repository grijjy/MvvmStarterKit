unit Model.Track;

interface

uses
  System.TimeSpan,
  System.Generics.Collections,
  Grijjy.Mvvm.Observable;

type
  { A model that represents a musical track an on album }
  TAlbumTrack = class(TgoObservable)
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FDuration: TTimeSpan;
    FTrackNumber: Integer;
    FGenres: String;
    procedure SetDuration(const Value: TTimeSpan);
    procedure SetName(const Value: String);
    procedure SetGenres(const Value: String);
    procedure SetTrackNumber(const Value: Integer);
  {$ENDREGION 'Internal Declarations'}
  public
    procedure Assign(const ASource: TAlbumTrack);

    { Bindable properties }
    property Name: String read FName write SetName;
    property Duration: TTimeSpan read FDuration write SetDuration;
    property TrackNumber: Integer read FTrackNumber write SetTrackNumber;
    property Genres: String read FGenres write SetGenres;
  end;

type
  TAlbumTracks = class(TgoObservableCollection<TAlbumTrack>)
  public
    constructor Create;
    procedure Assign(const ASource: TEnumerable<TAlbumTrack>);
  end;

implementation

{ TAlbumTrack }

procedure TAlbumTrack.Assign(const ASource: TAlbumTrack);
begin
  Assert(Assigned(ASource));
  { Important: do not assign to fields. Assign to properties instead, so it
    will fire PropertyChanged notifications. }
  Name := ASource.FName;
  Duration := ASource.FDuration;
  TrackNumber := ASource.FTrackNumber;
  Genres := ASource.FGenres;
end;

procedure TAlbumTrack.SetDuration(const Value: TTimeSpan);
begin
  if (Value <> FDuration) then
  begin
    FDuration := Value;
    PropertyChanged('Duration');
  end;
end;

procedure TAlbumTrack.SetGenres(const Value: String);
begin
  if (Value <> FGenres) then
  begin
    FGenres := Value;
    PropertyChanged('Genres');
  end;
end;

procedure TAlbumTrack.SetName(const Value: String);
begin
  if (Value <> FName) then
  begin
    FName := Value;
    PropertyChanged('Name');
  end;
end;

procedure TAlbumTrack.SetTrackNumber(const Value: Integer);
begin
  if (Value <> FTrackNumber) then
  begin
    FTrackNumber := Value;
    PropertyChanged('TrackNumber');
  end;
end;

{ TAlbumTracks }

procedure TAlbumTracks.Assign(const ASource: TEnumerable<TAlbumTrack>);
var
  SrcTrack, DstTrack: TAlbumTrack;
begin
  Clear;
  for SrcTrack in ASource do
  begin
    DstTrack := TAlbumTrack.Create;
    DstTrack.Assign(SrcTrack);
    Add(DstTrack)
  end;
end;

constructor TAlbumTracks.Create;
begin
  inherited Create(True);
end;

end.
