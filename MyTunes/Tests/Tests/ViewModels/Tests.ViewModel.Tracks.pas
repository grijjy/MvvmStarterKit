unit Tests.ViewModel.Tracks;

interface

uses
  DUnitX.TestFramework,
  ViewModel.Tracks,
  Model.Track;

type
  TTestViewModelTracks = class
  private
    FTracks: TAlbumTracks;
    FViewModel: TViewModelTracks;
    FChangedProperties: String;
  private
    procedure ProperyChangedListener(const ASender: TObject; const AArg: String);
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestTracks;
    [Test] procedure TestHasSelectedTrack;
    [Test] procedure TestNotifications;
    [Test] procedure TestAddTrack;
    [Test] procedure TestDeleteTrack;
  end;

implementation

uses
  System.SysUtils,
  System.TimeSpan,
  Grijjy.Mvvm.Types;

{ TTestViewModelTracks }

procedure TTestViewModelTracks.ProperyChangedListener(const ASender: TObject;
  const AArg: String);
begin
  FChangedProperties := FChangedProperties + AArg + ',';
end;

procedure TTestViewModelTracks.Setup;
var
  I: Integer;
  Track: TAlbumTrack;
begin
  FTracks := TAlbumTracks.Create;

  for I := 0 to 2 do
  begin
    Track := TAlbumTrack.Create;
    Track.Name := 'Track ' + I.ToString;
    Track.Duration := TTimeSpan.FromMinutes(I);
    Track.TrackNumber := I + 1;
    FTracks.Add(Track)
  end;

  FViewModel := TViewModelTracks.Create(FTracks);
end;

procedure TTestViewModelTracks.Teardown;
begin
  FViewModel.Free;
  FTracks.Free;
end;

procedure TTestViewModelTracks.TestAddTrack;
begin
  Assert.AreEqual(3, FTracks.Count);
  FViewModel.AddTrack;
  Assert.AreEqual(4, FTracks.Count);
end;

procedure TTestViewModelTracks.TestDeleteTrack;
begin
  Assert.AreEqual(3, FTracks.Count);
  FViewModel.SelectedTrack := FTracks[1];
  FViewModel.DeleteTrack;
  Assert.AreEqual(2, FTracks.Count);
end;

procedure TTestViewModelTracks.TestHasSelectedTrack;
begin
  Assert.IsFalse(FViewModel.HasSelectedTrack);
  FViewModel.SelectedTrack := FTracks[0];
  Assert.IsTrue(FViewModel.HasSelectedTrack);
end;

procedure TTestViewModelTracks.TestNotifications;
var
  NPC: IgoNotifyPropertyChanged;
  PCE: IgoPropertyChangedEvent;
begin
  Assert.IsTrue(Supports(FViewModel, IgoNotifyPropertyChanged, NPC));
  PCE := NPC.GetPropertyChangedEvent;
  Assert.IsNotNull(PCE);
  PCE.Add(ProperyChangedListener);

  Assert.AreEqual('', FChangedProperties);
  FViewModel.SelectedTrack := FTracks[0];
  Assert.AreEqual('SelectedTrack,SelectedTrackDurationMinutes,SelectedTrackDurationSeconds,', FChangedProperties);
end;

procedure TTestViewModelTracks.TestTracks;
begin
  Assert.IsNotNull(FViewModel.Tracks);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestViewModelTracks);

end.
