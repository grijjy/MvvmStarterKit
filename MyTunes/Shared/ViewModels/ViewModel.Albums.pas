unit ViewModel.Albums;

interface

uses
  System.UITypes,
  System.SysUtils,
  System.Generics.Collections,
  Grijjy.Mvvm.Observable,
  Model.Album,
  Model;

type
  TViewModelAlbums = class(TgoObservable)
  {$REGION 'Internal Declarations'}
  private
    FSelectedAlbum: TAlbum;
    function GetAlbums: TEnumerable<TAlbum>; inline;
    procedure SetSelectedAlbum(const Value: TAlbum);
  private
    procedure ShowAlbumView(const AAlbum: TAlbum;
      const AResultProc: TProc<TModalResult>);
  {$ENDREGION 'Internal Declarations'}
  public
    { Actions }
    procedure AddAlbum;
    procedure DeleteAlbum;
    procedure EditAlbum;
    function HasSelectedAlbum: Boolean;

    { Bindable properties }
    property Albums: TEnumerable<TAlbum> read GetAlbums;
    property SelectedAlbum: TAlbum read FSelectedAlbum write SetSelectedAlbum;
  end;

implementation

uses
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.ViewFactory,
  ViewModel.Album;

{ TViewModelAlbums }

procedure TViewModelAlbums.AddAlbum;
var
  Album: TAlbum;
begin
  Album := TAlbum.Create;
  try
    ShowAlbumView(Album,
      procedure (AModalResult: TModalResult)
      begin
        if (AModalResult = mrOk) then
        begin
          TModel.Instance.Albums.Add(Album);
          SetSelectedAlbum(Album);
        end
        else
          Album.DisposeOf;
      end);
  except
    Album.DisposeOf;
    raise;
  end;
end;

procedure TViewModelAlbums.DeleteAlbum;
begin
  Assert(Assigned(FSelectedAlbum));
  TModel.Instance.Albums.Remove(FSelectedAlbum);
  SetSelectedAlbum(nil);
end;

procedure TViewModelAlbums.EditAlbum;
var
  Clone: TAlbum;
begin
  Assert(Assigned(FSelectedAlbum));
  Clone := TAlbum.Create;
  try
    Clone.Assign(FSelectedAlbum);
    ShowAlbumView(Clone,
      procedure (AModalResult: TModalResult)
      begin
        if (AModalResult = mrOk) then
        begin
          FSelectedAlbum.Assign(Clone);
          PropertyChanged('SelectedAlbum');
        end;
        Clone.DisposeOf;
      end);
  except
    Clone.DisposeOf;
    raise;
  end;
end;

function TViewModelAlbums.GetAlbums: TEnumerable<TAlbum>;
begin
  Result := TModel.Instance.Albums;
end;


function TViewModelAlbums.HasSelectedAlbum: Boolean;
begin
  Result := Assigned(FSelectedAlbum);
end;

procedure TViewModelAlbums.SetSelectedAlbum(const Value: TAlbum);
begin
  if (Value <> FSelectedAlbum) then
  begin
    FSelectedAlbum := Value;
    PropertyChanged('SelectedAlbum');
  end;
end;

procedure TViewModelAlbums.ShowAlbumView(const AAlbum: TAlbum;
  const AResultProc: TProc<TModalResult>);
var
  ViewModel: TViewModelAlbum;
  View: IgoView;
begin
  Assert(Assigned(AAlbum));
  Assert(Assigned(AResultProc));
  ViewModel := TViewModelAlbum.Create(AAlbum);

  { The view becomes owner of the view model. }
  View := TgoViewFactory.CreateView('Album', nil, ViewModel);
  View.ExecuteModal(
    procedure (AModalResult: TModalResult)
    begin
      AResultProc(AModalResult);
    end);
end;

end.
