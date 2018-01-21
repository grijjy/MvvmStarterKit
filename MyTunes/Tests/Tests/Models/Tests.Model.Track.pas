unit Tests.Model.Track;

interface

uses
  DUnitX.TestFramework,
  Model.Track;

type
  TTestTrack = class
  private
    FTrack: TAlbumTrack;
    FChangedProperties: String;
  private
    procedure ProperyChangedListener(const ASender: TObject; const AArg: String);
    procedure SetTrackProperties;
    procedure CheckTrackProperties(const ATrack: TAlbumTrack);
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestNotifications;
    [Test] procedure TestAssign;
  end;

implementation

uses
  System.SysUtils,
  System.TimeSpan,
  Grijjy.Mvvm.Types;

{ TTestTrack }

procedure TTestTrack.CheckTrackProperties(const ATrack: TAlbumTrack);
begin
  Assert.AreEqual('Track name', ATrack.Name);
  Assert.AreEqual(Double(3.2), ATrack.Duration.TotalMinutes);
  Assert.AreEqual(42, ATrack.TrackNumber);
  Assert.AreEqual('Genre1' + sLineBreak + 'Genre2', ATrack.Genres);
end;

procedure TTestTrack.ProperyChangedListener(const ASender: TObject;
  const AArg: String);
begin
  FChangedProperties := FChangedProperties + AArg + ',';
end;

procedure TTestTrack.SetTrackProperties;
begin
  FTrack.Name := 'Track Name';
  FTrack.Duration := TTimeSpan.FromMinutes(3.2);
  FTrack.TrackNumber := 42;
  FTrack.Genres := 'Genre1' + sLineBreak + 'Genre2';
end;

procedure TTestTrack.Setup;
begin
  FTrack := TAlbumTrack.Create;
end;

procedure TTestTrack.Teardown;
begin
  FTrack.Free;
end;

procedure TTestTrack.TestAssign;
var
  Clone: TAlbumTrack;
begin
  SetTrackProperties;

  Clone := TAlbumTrack.Create;
  try
    Clone.Assign(FTrack);

    { Modify original properties }
    FTrack.Name := 'New Name';
    FTrack.Duration := TTimeSpan.FromMinutes(4.1);
    FTrack.TrackNumber := 3;
    FTrack.Genres := 'Genre3';

    { Clone should be unmodified }
    CheckTrackProperties(Clone);
  finally
    Clone.Free;
  end;
end;

procedure TTestTrack.TestNotifications;
var
  NPC: IgoNotifyPropertyChanged;
  PCE: IgoPropertyChangedEvent;
begin
  Assert.IsTrue(Supports(FTrack, IgoNotifyPropertyChanged, NPC));
  PCE := NPC.GetPropertyChangedEvent;
  Assert.IsNotNull(PCE);
  PCE.Add(ProperyChangedListener);

  Assert.AreEqual('', FChangedProperties);

  SetTrackProperties;

  Assert.AreEqual('Name,Duration,TrackNumber,Genres,', FChangedProperties);

  CheckTrackProperties(FTrack);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTrack);

end.
