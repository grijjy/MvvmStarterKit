unit View.Albums;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Actions,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.MultiView,
  FMX.ListView,
  FMX.Edit,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.ActnList,
  FMX.DialogService,
  Grijjy.Mvvm.Controls.Fmx, // MUST be listed AFTER all other FMX.* units!
  Grijjy.Mvvm.Views.Fmx,
  ViewModel.Albums;

type
  TViewAlbums = class(TgoFormView<TViewModelAlbums>)
    ActionList: TActionList;
    ActionAddAlbum: TAction;
    ActionDeleteAlbum: TAction;
    ActionEditAlbum: TAction;
    LayoutMain: TLayout;
    ToolBar: TToolBar;
    SpeedButtonMaster: TSpeedButton;
    LabelAlbumDetails: TLabel;
    ButtonEditAlbum: TButton;
    RectangleBackground: TRectangle;
    MultiView: TMultiView;
    ToolBarMaster: TToolBar;
    LabelAlbums: TLabel;
    SpeedButtonAddAlbum: TSpeedButton;
    SpeedButtonDeleteAlbum: TSpeedButton;
    ListViewAlbums: TListView;
    ImageAlbumCover: TImage;
    TextTitle: TText;
    TextArtist: TText;
    ListViewTracks: TListView;
    procedure ListViewAlbumsChange(Sender: TObject);
    procedure ListViewAlbumsDeleteItem(Sender: TObject; AIndex: Integer);
  private
    { Private declarations }
    procedure DeleteAlbum;
  protected
    { TgoFormView }
    procedure SetupView; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  ViewAlbums: TViewAlbums = nil;

implementation

uses
  Grijjy.Mvvm.DataBinding,
  Template.Album,
  Template.Track,
  Model.Album,
  Model.Track,
  Model;

{$R *.fmx}
{$R *.iPhone4in.fmx IOS}
{$R *.NmXhdpiPh.fmx ANDROID}

{ TViewAlbums }

constructor TViewAlbums.Create(AOwner: TComponent);
begin
  inherited;
  ReportMemoryLeaksOnShutdown := True;

  { Always show master view, also on mobile. }
  MultiView.ShowMaster;

  InitView(TViewModelAlbums.Create, True);
end;

procedure TViewAlbums.DeleteAlbum;
begin
  Assert(Assigned(ViewModel.SelectedAlbum));
  TDialogService.MessageDialog(
    Format('Are you sure you want to delete album "%s"?', [ViewModel.SelectedAlbum.Title]),
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrYes) then
        ViewModel.DeleteAlbum;
    end);
end;

procedure TViewAlbums.ListViewAlbumsChange(Sender: TObject);
begin
  Binder.BindCollection<TAlbumTrack>(ViewModel.SelectedAlbum.Tracks,
    ListViewTracks, TTemplateTrack);
end;

procedure TViewAlbums.ListViewAlbumsDeleteItem(Sender: TObject;
  AIndex: Integer);
begin
  Binder.BindCollection<TAlbumTrack>(nil, ListViewTracks, TTemplateTrack);
end;

procedure TViewAlbums.SetupView;
begin
  inherited;

  { Bind properties }
  Binder.Bind(ViewModel, 'SelectedAlbum', ListViewAlbums, 'SelectedItem');
  Binder.Bind(ViewModel, 'SelectedAlbum.BackgroundColor',
    RectangleBackground.Fill, 'Color', TgoBindDirection.OneWay);
  Binder.Bind(ViewModel, 'SelectedAlbum.Title', TextTitle, 'Text',
    TgoBindDirection.OneWay);
  Binder.Bind(ViewModel, 'SelectedAlbum.TextColor1',
    TextTitle.TextSettings, 'FontColor', TgoBindDirection.OneWay);
  Binder.Bind(ViewModel, 'SelectedAlbum.Artist', TextArtist, 'Text',
    TgoBindDirection.OneWay);
  Binder.Bind(ViewModel, 'SelectedAlbum.TextColor2',
    TextArtist.TextSettings, 'FontColor', TgoBindDirection.OneWay);
  Binder.Bind(ViewModel, 'SelectedAlbum.Bitmap', ImageAlbumCover, 'Bitmap',
    TgoBindDirection.OneWay);

  { Bind collections }
  Binder.BindCollection<TAlbum>(ViewModel.Albums, ListViewAlbums, TTemplateAlbum);

  { Bind actions }
  ActionAddAlbum.Bind(ViewModel.AddAlbum);
  ActionDeleteAlbum.Bind(Self.DeleteAlbum, ViewModel.HasSelectedAlbum);
  ActionEditAlbum.Bind(ViewModel.EditAlbum, ViewModel.HasSelectedAlbum);
end;

end.

