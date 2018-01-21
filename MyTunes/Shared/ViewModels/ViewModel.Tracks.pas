unit ViewModel.Tracks;

interface

uses
  System.Generics.Collections,
  Grijjy.Mvvm.Observable,
  Model.Track;

type
  TViewModelTracks = class(TgoObservable)
  {$REGION 'Internal Declarations'}
  private
    FTracks: TAlbumTracks;
    FSelectedTrack: TAlbumTrack;
    function GetTracks: TEnumerable<TAlbumTrack>; inline;
    procedure SetSelectedTrack(const Value: TAlbumTrack);
    function GetSelectedTrackDurationMinutes: Integer;
    function GetSelectedTrackDurationSeconds: Integer;
    procedure SetSelectedTrackDurationMinutes(const Value: Integer);
    procedure SetSelectedTrackDurationSeconds(const Value: Integer);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const ATracks: TAlbumTracks);

    { Actions }
    procedure AddTrack;
    procedure DeleteTrack;
    function HasSelectedTrack: Boolean;

    { Bindable properties }
    property Tracks: TEnumerable<TAlbumTrack> read GetTracks;
    property SelectedTrack: TAlbumTrack read FSelectedTrack write SetSelectedTrack;
    property SelectedTrackDurationMinutes: Integer read GetSelectedTrackDurationMinutes write SetSelectedTrackDurationMinutes;
    property SelectedTrackDurationSeconds: Integer read GetSelectedTrackDurationSeconds write SetSelectedTrackDurationSeconds;
  end;

implementation

uses
  System.TimeSpan;

{ TViewModelTracks }

procedure TViewModelTracks.AddTrack;
var
  Track: TAlbumTrack;
begin
  Track := TAlbumTrack.Create;
  FTracks.Add(Track);
  SetSelectedTrack(Track);
end;

constructor TViewModelTracks.Create(const ATracks: TAlbumTracks);
begin
  Assert(Assigned(ATracks));
  inherited Create;
  FTracks := ATracks;
end;

procedure TViewModelTracks.DeleteTrack;
begin
  Assert(Assigned(FSelectedTrack));
  FTracks.Remove(FSelectedTrack);
  SetSelectedTrack(nil);
end;

function TViewModelTracks.GetSelectedTrackDurationMinutes: Integer;
begin
  if Assigned(FSelectedTrack) then
    Result := FSelectedTrack.Duration.Minutes
  else
    Result := 0;
end;

function TViewModelTracks.GetSelectedTrackDurationSeconds: Integer;
begin
  if Assigned(FSelectedTrack) then
    Result := FSelectedTrack.Duration.Seconds
  else
    Result := 0;
end;

function TViewModelTracks.GetTracks: TEnumerable<TAlbumTrack>;
begin
  Result := FTracks;
end;

function TViewModelTracks.HasSelectedTrack: Boolean;
begin
  Result := Assigned(FSelectedTrack);
end;

procedure TViewModelTracks.SetSelectedTrack(const Value: TAlbumTrack);
begin
  if (Value <> FSelectedTrack) then
  begin
    FSelectedTrack := Value;
    PropertyChanged('SelectedTrack');
    PropertyChanged('SelectedTrackDurationMinutes');
    PropertyChanged('SelectedTrackDurationSeconds');
  end;
end;

procedure TViewModelTracks.SetSelectedTrackDurationMinutes(
  const Value: Integer);
begin
  if Assigned(FSelectedTrack) then
    FSelectedTrack.Duration := TTimeSpan.Create(0, Value, FSelectedTrack.Duration.Seconds);
end;

procedure TViewModelTracks.SetSelectedTrackDurationSeconds(
  const Value: Integer);
begin
  if Assigned(FSelectedTrack) then
    FSelectedTrack.Duration := TTimeSpan.Create(0, FSelectedTrack.Duration.Minutes, Value);
end;

end.
