unit View.Tracks;

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
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ActnList,
  Vcl.StdCtrls,
  Grijjy.Mvvm.Controls.Vcl, // MUST be listed AFTER all other FMX.* units!
  Grijjy.Mvvm.Views.Vcl,
  ViewModel.Tracks;

type
  TViewTracks = class(TgoFormView<TViewModelTracks>)
    ActionList: TActionList;
    ActionAddTrack: TAction;
    ActionDeleteTrack: TAction;
    PanelTracks: TPanel;
    PanelAlbumsHeader: TPanel;
    SpeedButtonDeleteAlbum: TSpeedButton;
    SpeedButtonAddAlbum: TSpeedButton;
    ListViewTracks: TListView;
    PanelDetailContainer: TPanel;
    PanelDetails: TPanel;
    PanelDetailsHeader: TPanel;
    Splitter: TSplitter;
    PanelButtons: TPanel;
    ButtonCancel: TButton;
    ButtonOK: TButton;
    LabelName: TLabel;
    LabelTrackNumber: TLabel;
    EditTrackNumber: TEdit;
    EditName: TEdit;
    UpDownTrackNumber: TUpDown;
    LabelDuration: TLabel;
    EditDurationMinutes: TEdit;
    UpDownDurationMinutes: TUpDown;
    LabelMinutes: TLabel;
    EditDurationSeconds: TEdit;
    UpDownDurationSeconds: TUpDown;
    LabelSeconds: TLabel;
    LabelGenres: TLabel;
    MemoGenres: TMemo;
  private
    procedure DeleteTrack;
  protected
    { TgoFormView }
    procedure SetupView; override;
  end;

implementation

uses
  Grijjy.Mvvm.ViewFactory,
  Grijjy.Mvvm.DataBinding,
  Template.Track,
  Model.Track;

{$R *.dfm}

{ TViewTracks }

procedure TViewTracks.DeleteTrack;
begin
  Assert(Assigned(ViewModel.SelectedTrack));
  if (MessageDlg(Format('Are you sure you want to delete track "%s"?', [ViewModel.SelectedTrack.Name]),
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0,
    TMsgDlgBtn.mbNo) = mrYes)
  then
    ViewModel.DeleteTrack;
end;

procedure TViewTracks.SetupView;
begin
  inherited;

  { Bind properties }
  Binder.Bind(ViewModel, 'SelectedTrack', ListViewTracks, 'SelectedItem');
  Binder.Bind(ViewModel, 'SelectedTrack.Name', EditName, 'Text',
    TgoBindDirection.TwoWay, [TgoBindFlag.TargetTracking]);
  Binder.Bind(ViewModel, 'SelectedTrack.TrackNumber', UpDownTrackNumber, 'Position');
  Binder.Bind(ViewModel, 'SelectedTrackDurationMinutes', UpDownDurationMinutes, 'Position');
  Binder.Bind(ViewModel, 'SelectedTrackDurationSeconds', UpDownDurationSeconds, 'Position');
  Binder.Bind(ViewModel, 'SelectedTrack.Genres', MemoGenres, 'Text');

  { Note that you can bind an Object property (SelectedTrack) to a Boolean
    property (Enabled). The target property will be False if the object is nil,
    or True otherwise. This obviously only works in one direction. }
  Binder.Bind(ViewModel, 'SelectedTrack', PanelDetails, 'Enabled',
    TgoBindDirection.OneWay);

  { Bind collections }
  Binder.BindCollection<TAlbumTrack>(ViewModel.Tracks, ListViewTracks, TTemplateTrack);

  { Bind actions }
  ActionAddTrack.Bind(ViewModel.AddTrack);
  ActionDeleteTrack.Bind(Self.DeleteTrack, ViewModel.HasSelectedTrack);
end;

initialization
  TgoViewFactory.Register(TViewTracks, 'Tracks');

end.
