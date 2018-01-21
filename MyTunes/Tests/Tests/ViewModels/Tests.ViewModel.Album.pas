unit Tests.ViewModel.Album;

interface

uses
  DUnitX.TestFramework,
  Grijjy.Mvvm.Types,
  ViewModel.Album,
  Model.Album;

type
  TTestViewModelAlbum = class
  private
    FAlbum: TAlbum;
    FViewModel: TViewModelAlbum;
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestEditTracksCancel;
    [Test] procedure TestEditTracksOK;
  end;

implementation

uses
  System.UITypes,
  System.SysUtils,
  System.TimeSpan,
  Grijjy.Mvvm.ViewFactory,
  Grijjy.Mvvm.Mock,
  ViewModel.Tracks,
  Model.Track;

{ TTestViewModelAlbum }

procedure TTestViewModelAlbum.Setup;
var
  I: Integer;
  Track: TAlbumTrack;
begin
  FAlbum := TAlbum.Create;

  FAlbum.Title := 'Album Title';
  FAlbum.Artist := 'Album Artist';

  for I := 0 to 2 do
  begin
    Track := FAlbum.AddTrack;
    Track.Name := 'Track ' + I.ToString;
    Track.Duration := TTimeSpan.FromMinutes(I);
    Track.TrackNumber := I + 1;
  end;

  FViewModel := TViewModelAlbum.Create(FAlbum);
end;

procedure TTestViewModelAlbum.Teardown;
begin
  FViewModel.Free;
  FAlbum.Free;
end;

procedure TTestViewModelAlbum.TestEditTracksCancel;
var
  I: Integer;
  Track: TAlbumTrack;
begin
  { Register a mock view that simulates the Tracks view.
    It simulates a user editing some values an pressing the Cancel button. }
  TgoMockView<TViewModelTracks>.Register('Tracks',
    function (AViewModel: TViewModelTracks): TModalResult
    var
      Track: TAlbumTrack;
    begin
      { Modify existing tracks }
      for Track in AViewModel.Tracks do
      begin
        Track.Name := 'New ' + Track.Name;
        Track.Duration := TTimeSpan.FromMinutes(Track.Duration.Minutes + 10);
        Track.TrackNumber := Track.TrackNumber * 2;
      end;

      Result := mrCancel;
    end);

  FViewModel.EditTracks;

  { Because view is cancelled, tracks should remain unchanged. }
  I := 0;
  for Track in FAlbum.Tracks do
  begin
    Assert.AreEqual('Track ' + I.ToString, Track.Name);
    Assert.AreEqual(I, Track.Duration.Minutes);
    Assert.AreEqual(I + 1, Track.TrackNumber);
    Inc(I);
  end;
  Assert.AreEqual(3, I);
end;

procedure TTestViewModelAlbum.TestEditTracksOK;
var
  I: Integer;
  Track: TAlbumTrack;
begin
  { Register a mock view that simulates the Tracks view.
    It simulates a user editing some values an pressing the OK button. }
  TgoMockView<TViewModelTracks>.Register('Tracks',
    function (AViewModel: TViewModelTracks): TModalResult
    var
      Track: TAlbumTrack;
    begin
      { Modify existing tracks }
      for Track in AViewModel.Tracks do
      begin
        Track.Name := 'New ' + Track.Name;
        Track.Duration := TTimeSpan.FromMinutes(Track.Duration.Minutes + 10);
        Track.TrackNumber := Track.TrackNumber * 2;
      end;

      Result := mrOk;
    end);

  FViewModel.EditTracks;

  { Tracks should be modified. }
  I := 0;
  for Track in FAlbum.Tracks do
  begin
    Assert.AreEqual('New Track ' + I.ToString, Track.Name);
    Assert.AreEqual(I + 10, Track.Duration.Minutes);
    Assert.AreEqual((I + 1) * 2, Track.TrackNumber);
    Inc(I);
  end;
  Assert.AreEqual(3, I);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestViewModelAlbum);

end.
