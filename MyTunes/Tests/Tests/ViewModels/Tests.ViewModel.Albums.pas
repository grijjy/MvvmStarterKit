unit Tests.ViewModel.Albums;

interface

uses
  DUnitX.TestFramework,
  Grijjy.Mvvm.Types,
  ViewModel.Albums;

type
  TTestViewModelAlbums = class
  private
    FViewModel: TViewModelAlbums;
    FChangedProperties: String;
  private
    procedure ProperyChangedListener(const ASender: TObject; const AArg: String);
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestAlbums;
    [Test] procedure TestHasSelectedAlbum;
    [Test] procedure TestNotifications;
    [Test] procedure TestAddAlbumCancel;
    [Test] procedure TestAddAlbumOK;
    [Test] procedure TestDeleteAlbum;
    [Test] procedure TestEditAlbumCancel;
    [Test] procedure TestEditAlbumOK;
  end;

implementation

uses
  System.UITypes,
  System.SysUtils,
  Grijjy.Mvvm.ViewFactory,
  Grijjy.Mvvm.Mock,
  Model,
  Model.Album,
  ViewModel.Album;

{ TTestViewModelAlbums }

procedure TTestViewModelAlbums.ProperyChangedListener(const ASender: TObject;
  const AArg: String);
begin
  FChangedProperties := FChangedProperties + AArg + ',';
end;

procedure TTestViewModelAlbums.Setup;
begin
  FViewModel := TViewModelAlbums.Create;
end;

procedure TTestViewModelAlbums.Teardown;
begin
  FViewModel.Free;
end;

procedure TTestViewModelAlbums.TestAddAlbumCancel;
var
  OldCount: Integer;
begin
  { Register a mock view that simulates the Album view.
    It simulates a user pressing the Cancel button. }
  TgoMockView<TViewModelAlbum>.Register('Album',
    function (AViewModel: TViewModelAlbum): TModalResult
    begin
      Result := mrCancel;
    end);

  OldCount := TModel.Instance.Albums.Count;
  FViewModel.AddAlbum;
  Assert.AreEqual(OldCount, TModel.Instance.Albums.Count);
end;

procedure TTestViewModelAlbums.TestAddAlbumOK;
var
  OldCount: Integer;
  Album: TAlbum;
begin
  { Register a mock view that simulates the Album view.
    It simulates a user entering some values and pressing the OK button. }
  TgoMockView<TViewModelAlbum>.Register('Album',
    function (AViewModel: TViewModelAlbum): TModalResult
    begin
      AViewModel.Album.Title := 'New Album Title';
      Result := mrOk;
    end);

  OldCount := TModel.Instance.Albums.Count;
  FViewModel.AddAlbum;
  Assert.AreEqual(OldCount + 1, TModel.Instance.Albums.Count);

  Album := TModel.Instance.Albums[TModel.Instance.Albums.Count - 1];
  Assert.IsNotNull(Album);
  Assert.AreEqual('New Album Title', Album.Title);
end;

procedure TTestViewModelAlbums.TestAlbums;
begin
  Assert.IsNotNull(FViewModel.Albums);
end;

procedure TTestViewModelAlbums.TestDeleteAlbum;
var
  OldCount, NewCount: Integer;
begin
  OldCount := TModel.Instance.Albums.Count;
  FViewModel.SelectedAlbum := TModel.Instance.Albums[0];
  FViewModel.DeleteAlbum;
  NewCount := TModel.Instance.Albums.Count;
  Assert.AreEqual(OldCount - 1, NewCount);
end;

procedure TTestViewModelAlbums.TestEditAlbumCancel;
var
  Album: TAlbum;
begin
  { Register a mock view that simulates the Album view.
    It simulates a user editing some values an pressing the Cancel button. }
  TgoMockView<TViewModelAlbum>.Register('Album',
    function (AViewModel: TViewModelAlbum): TModalResult
    begin
      AViewModel.Album.Title := 'Modified Album Title';
      Result := mrCancel;
    end);

  Album := TModel.Instance.Albums[0];
  Album.Title := 'Original Title';
  FViewModel.SelectedAlbum := Album;
  FViewModel.EditAlbum;

  { Because view is cancelled, title should remain unchanged. }
  Assert.AreEqual('Original Title', Album.Title);
end;

procedure TTestViewModelAlbums.TestEditAlbumOK;
var
  Album: TAlbum;
begin
  { Register a mock view that simulates the Album view.
    It simulates a user editing some values an pressing the OK button. }
  TgoMockView<TViewModelAlbum>.Register('Album',
    function (AViewModel: TViewModelAlbum): TModalResult
    begin
      AViewModel.Album.Title := 'Modified Album Title';
      Result := mrOk;
    end);

  Album := TModel.Instance.Albums[0];
  Album.Title := 'Original Title';
  FViewModel.SelectedAlbum := Album;
  FViewModel.EditAlbum;
  Assert.AreEqual('Modified Album Title', Album.Title);
end;

procedure TTestViewModelAlbums.TestHasSelectedAlbum;
begin
  Assert.IsFalse(FViewModel.HasSelectedAlbum);
  FViewModel.SelectedAlbum := TModel.Instance.Albums[0];
  Assert.IsTrue(FViewModel.HasSelectedAlbum);
end;

procedure TTestViewModelAlbums.TestNotifications;
var
  NPC: IgoNotifyPropertyChanged;
  PCE: IgoPropertyChangedEvent;
begin
  Assert.IsTrue(Supports(FViewModel, IgoNotifyPropertyChanged, NPC));
  PCE := NPC.GetPropertyChangedEvent;
  Assert.IsNotNull(PCE);
  PCE.Add(ProperyChangedListener);

  Assert.AreEqual('', FChangedProperties);
  FViewModel.SelectedAlbum := TModel.Instance.Albums[0];
  Assert.AreEqual('SelectedAlbum,', FChangedProperties);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestViewModelAlbums);

end.
