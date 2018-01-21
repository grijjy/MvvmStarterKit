unit Tests.Model.Album;

interface

uses
  DUnitX.TestFramework,
  Model.Album,
  Model.Track;

type
  TTestAlbum = class
  private
    FAlbum: TAlbum;
    FChangedProperties: String;
  private
    procedure ProperyChangedListener(const ASender: TObject; const AArg: String);
    procedure SetAlbumProperties;
    procedure CheckAlbumProperties(const AAlbum: TAlbum);
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestNotifications;
    [Test] procedure TestValid;
    [Test] procedure TestAssign;
    [Test] procedure TestAddTrack;
    [Test] procedure TestRemoveTrack;
  end;

implementation

uses
  System.SysUtils,
  Grijjy.Mvvm.Types;

{ TTestAlbum }

procedure TTestAlbum.CheckAlbumProperties(const AAlbum: TAlbum);
begin
  Assert.AreEqual('Album Title', AAlbum.Title);
  Assert.AreEqual('Album Artist', AAlbum.Artist);
  Assert.AreEqual('Album Record Label', AAlbum.RecordLabel);
  Assert.AreEqual('Album Copyright', AAlbum.Copyright);
  Assert.AreEqual('Album Notes', AAlbum.Notes);
  Assert.AreEqual(EncodeDate(2018, 1, 8), AAlbum.ReleaseDate);
  Assert.AreEqual($FF012345, AAlbum.BackgroundColor);
  Assert.AreEqual($FF000001, AAlbum.TextColor1);
  Assert.AreEqual($FF000002, AAlbum.TextColor2);
  Assert.AreEqual($FF000003, AAlbum.TextColor3);
end;

procedure TTestAlbum.ProperyChangedListener(const ASender: TObject;
  const AArg: String);
begin
  FChangedProperties := FChangedProperties + AArg + ',';
end;

procedure TTestAlbum.SetAlbumProperties;
begin
  FAlbum.Title := 'Album Title';
  FAlbum.Artist := 'Album Artist';
  FAlbum.RecordLabel := 'Album Record Label';
  FAlbum.Copyright := 'Album Copyright';
  FAlbum.Notes := 'Album Notes';
  FAlbum.ReleaseDate := EncodeDate(2018, 1, 8);
  FAlbum.BackgroundColor := $FF012345;
  FAlbum.TextColor1 := $FF000001;
  FAlbum.TextColor2 := $FF000002;
  FAlbum.TextColor3 := $FF000003;
end;

procedure TTestAlbum.Setup;
begin
  FAlbum := TAlbum.Create;
end;

procedure TTestAlbum.Teardown;
begin
  FAlbum.Free;
end;

procedure TTestAlbum.TestAddTrack;
var
  Track: TAlbumTrack;
  I: Integer;
begin
  for I := 0 to 2 do
  begin
    Track := FAlbum.AddTrack;
    Track.TrackNumber := I;
  end;
  Assert.AreEqual(3, FAlbum.TrackCount);

  I := 0;
  for Track in FAlbum.Tracks do
  begin
    Assert.AreEqual(I, Track.TrackNumber);
    Inc(I);
  end;
  Assert.AreEqual(3, I);
end;

procedure TTestAlbum.TestAssign;
var
  Clone: TAlbum;
  Track: TAlbumTrack;
begin
  SetAlbumProperties;
  Track := FAlbum.AddTrack;
  Track.Name := 'Foo';
  Track.TrackNumber := 42;

  Clone := TAlbum.Create;
  try
    Clone.Assign(FAlbum);

    { Modify original properties }
    FAlbum.Title := 'New Title';
    FAlbum.Artist := 'New Artist';
    FAlbum.RecordLabel := 'New Record Label';
    FAlbum.Copyright := 'New Copyright';
    FAlbum.Notes := 'New Notes';
    FAlbum.ReleaseDate := EncodeDate(2019, 2, 9);
    FAlbum.BackgroundColor := $FF012346;
    FAlbum.TextColor1 := $FF000010;
    FAlbum.TextColor2 := $FF000020;
    FAlbum.TextColor3 := $FF000030;
    for Track in FAlbum.Tracks do
    begin
      Track.Name := 'Bar';
      Track.TrackNumber := 1;
    end;

    { Clone should be unmodified }
    CheckAlbumProperties(Clone);
    Assert.AreEqual(1, Clone.TrackCount);
    for Track in Clone.Tracks do
    begin
      Assert.AreEqual('Foo', Track.Name);
      Assert.AreEqual(42, Track.TrackNumber);
    end;
  finally
    Clone.Free;
  end;
end;

procedure TTestAlbum.TestNotifications;
var
  NPC: IgoNotifyPropertyChanged;
  PCE: IgoPropertyChangedEvent;
begin
  Assert.IsTrue(Supports(FAlbum, IgoNotifyPropertyChanged, NPC));
  PCE := NPC.GetPropertyChangedEvent;
  Assert.IsNotNull(PCE);
  PCE.Add(ProperyChangedListener);

  Assert.AreEqual('', FChangedProperties);

  SetAlbumProperties;

  Assert.AreEqual('Title,IsValid,Artist,IsValid,RecordLabel,Copyright,Notes,' +
    'ReleaseDate,BackgroundColor,TextColor1,TextColor2,TextColor3,', FChangedProperties);

  CheckAlbumProperties(FAlbum);
end;

procedure TTestAlbum.TestRemoveTrack;
var
  Tracks: array [0..2] of TAlbumTrack;
  Track: TAlbumTrack;
  I: Integer;
begin
  for I := 0 to 2 do
  begin
    Tracks[I] := FAlbum.AddTrack;
    Tracks[I].TrackNumber := I;
  end;
  Assert.AreEqual(3, FAlbum.TrackCount);

  FAlbum.RemoveTrack(Tracks[1]);
  Assert.AreEqual(2, FAlbum.TrackCount);

  I := 0;
  for Track in FAlbum.Tracks do
  begin
    Assert.AreEqual(I * 2, Track.TrackNumber);
    Inc(I);
  end;
  Assert.AreEqual(2, I);
end;

procedure TTestAlbum.TestValid;
begin
  Assert.IsFalse(FAlbum.IsValid);

  FAlbum.Title := 'Foo';
  Assert.IsFalse(FAlbum.IsValid);

  FAlbum.Artist := 'Bar';
  Assert.IsTrue(FAlbum.IsValid);

  FAlbum.Title := '';
  Assert.IsFalse(FAlbum.IsValid);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestAlbum);

end.
