unit ViewModel.Album;

interface

uses
  Grijjy.Mvvm.Observable,
  Model.Album;

type
  TViewModelAlbum = class(TgoObservable)
  {$REGION 'Internal Declarations'}
  private
    FAlbum: TAlbum;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AAlbum: TAlbum);

    { Actions }
    procedure EditTracks;

    { Bindable properties }
    property Album: TAlbum read FAlbum;
  end;

implementation

uses
  System.UITypes,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.ViewFactory,
  Model.Track,
  ViewModel.Tracks;

{ TViewModelAlbum }

constructor TViewModelAlbum.Create(const AAlbum: TAlbum);
begin
  Assert(Assigned(AAlbum));
  inherited Create;
  FAlbum := AAlbum;
end;

procedure TViewModelAlbum.EditTracks;
var
  Clone: TAlbumTracks;
  ViewModel: TViewModelTracks;
  View: IgoView;
begin
  Clone := TAlbumTracks.Create;
  try
    Clone.Assign(Album.Tracks);
    ViewModel := TViewModelTracks.Create(Clone);

    { The view becomes owner of the view model }
    View := TgoViewFactory.CreateView('Tracks', nil, ViewModel);
    View.ExecuteModal(
      procedure (AModalResult: TModalResult)
      begin
        if (AModalResult = mrOk) then
          Album.SetTracks(Clone);
        Clone.DisposeOf;
      end);
  except
    Clone.DisposeOf;
    raise;
  end;
end;

end.
