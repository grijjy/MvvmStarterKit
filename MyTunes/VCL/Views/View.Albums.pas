unit View.Albums;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.UITypes,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.ActnList,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Grijjy.Mvvm.Controls.Vcl, // MUST be listed AFTER all other FMX.* units!
  Grijjy.Mvvm.Views.Vcl,
  ViewModel.Albums;

type
  TViewAlbums = class(TgoFormView<TViewModelAlbums>)
    PanelAlbums: TPanel;
    PanelAlbumsHeader: TPanel;
    SpeedButtonDeleteAlbum: TSpeedButton;
    SpeedButtonAddAlbum: TSpeedButton;
    ActionList: TActionList;
    ActionAddAlbum: TAction;
    ActionDeleteAlbum: TAction;
    ActionEditAlbum: TAction;
    ListViewAlbums: TListView;
    Splitter: TSplitter;
    PanelDetails: TPanel;
    PanelDetailsHeader: TPanel;
    ButtonEditAlbum: TButton;
    LabelTitle: TLabel;
    LabelArtist: TLabel;
    ImageAlbumCover: TImage;
    ListViewTracks: TListView;
    PanelBackground: TPanel;
    procedure ListViewAlbumsDeletion(Sender: TObject; Item: TListItem);
    procedure ListViewAlbumsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
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
  ViewAlbums: TViewAlbums;

implementation

uses
  Grijjy.Mvvm.DataBinding,
  Grijjy.Mvvm.ValueConverters,
  Template.Album,
  Template.Track,
  Model.Album,
  Model.Track,
  Model;

{$R *.dfm}

{ TViewAlbums }

constructor TViewAlbums.Create(AOwner: TComponent);
begin
  inherited;
  ReportMemoryLeaksOnShutdown := True;
  InitView(TViewModelAlbums.Create, True)
end;

procedure TViewAlbums.DeleteAlbum;
begin
  Assert(Assigned(ViewModel.SelectedAlbum));
  if (MessageDlg(Format('Are you sure you want to delete album "%s"?', [ViewModel.SelectedAlbum.Title]),
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    0, TMsgDlgBtn.mbNo) = mrYes)
  then
    ViewModel.DeleteAlbum;
end;

procedure TViewAlbums.ListViewAlbumsDeletion(Sender: TObject; Item: TListItem);
begin
  Binder.BindCollection<TAlbumTrack>(nil, ListViewTracks, TTemplateTrack);
end;

procedure TViewAlbums.ListViewAlbumsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
    Binder.BindCollection<TAlbumTrack>(ViewModel.SelectedAlbum.Tracks,
      ListViewTracks, TTemplateTrack);
end;

procedure TViewAlbums.SetupView;
begin
  inherited;

  { Bind properties }
  Binder.Bind(ViewModel, 'SelectedAlbum', ListViewAlbums, 'SelectedItem');
  Binder.Bind(ViewModel, 'SelectedAlbum.BackgroundColor',
    PanelBackground, 'Color', TgoBindDirection.OneWay, [], TgoAlphaColorToVclColor);
  Binder.Bind(ViewModel, 'SelectedAlbum.Title', LabelTitle, 'Caption',
    TgoBindDirection.OneWay);
  Binder.Bind(ViewModel, 'SelectedAlbum.TextColor1',
    LabelTitle.Font, 'Color', TgoBindDirection.OneWay, [], TgoAlphaColorToVclColor);
  Binder.Bind(ViewModel, 'SelectedAlbum.Artist', LabelArtist, 'Caption',
    TgoBindDirection.OneWay);
  Binder.Bind(ViewModel, 'SelectedAlbum.TextColor2',
    LabelArtist.Font, 'Color', TgoBindDirection.OneWay, [], TgoAlphaColorToVclColor);
  Binder.Bind(ViewModel, 'SelectedAlbum.Bitmap', ImageAlbumCover.Picture, 'Bitmap',
    TgoBindDirection.OneWay);

  { Bind collections }
  Binder.BindCollection<TAlbum>(ViewModel.Albums, ListViewAlbums, TTemplateAlbum);

  { Bind actions }
  ActionAddAlbum.Bind(ViewModel.AddAlbum);
  ActionDeleteAlbum.Bind(Self.DeleteAlbum, ViewModel.HasSelectedAlbum);
  ActionEditAlbum.Bind(ViewModel.EditAlbum, ViewModel.HasSelectedAlbum);
end;

end.
