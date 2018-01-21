unit View.Tracks;

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
  FMX.Objects,
  FMX.MultiView,
  FMX.ListView,
  FMX.Edit, FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.ActnList,
  FMX.EditBox,
  FMX.SpinBox,
  FMX.ListBox,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.DialogService,
  Grijjy.Mvvm.Controls.Fmx, // MUST be listed AFTER all other FMX.* units!
  Grijjy.Mvvm.Views.Fmx,
  ViewModel.Tracks;

type
  TViewTracks = class(TgoFormView<TViewModelTracks>)
    ActionList: TActionList;
    ActionAddTrack: TAction;
    ActionDeleteTrack: TAction;
    LayoutMain: TLayout;
    ToolBarDetails: TToolBar;
    SpeedButtonMaster: TSpeedButton;
    LabelTrackDetails: TLabel;
    MultiView: TMultiView;
    ToolBarMaster: TToolBar;
    LabelTracks: TLabel;
    SpeedButtonAddTrack: TSpeedButton;
    SpeedButtonDeleteTrack: TSpeedButton;
    ListViewTracks: TListView;
    ToolBar: TToolBar;
    ButtonCancel: TButton;
    ButtonOK: TButton;
    ListBoxDetails: TListBox;
    ListBoxItemName: TListBoxItem;
    EditName: TEdit;
    ListBoxItemDuration: TListBoxItem;
    GridPanelLayoutDuration: TGridPanelLayout;
    LayoutDurationMinutes: TLayout;
    LayoutDurationSeconds: TLayout;
    LabelSeconds: TLabel;
    SpinBoxDurationSeconds: TSpinBox;
    LabelDurationMinutes: TLabel;
    SpinBoxDurationMinutes: TSpinBox;
    ListBoxItemNumber: TListBoxItem;
    SpinBoxTrackNumber: TSpinBox;
    ListBoxItemGenres: TListBoxItem;
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
  Model.Album,
  Model.Track,
  Model,
  Template.Track;

{$R *.fmx}
{$R *.iPhone4in.fmx IOS}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Macintosh.fmx MACOS}

procedure TViewTracks.DeleteTrack;
begin
  Assert(Assigned(ViewModel.SelectedTrack));
  TDialogService.MessageDialog(
    Format('Are you sure you want to delete track "%s"?', [ViewModel.SelectedTrack.Name]),
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      if (AResult = mrYes) then
        ViewModel.DeleteTrack;
    end);
end;

procedure TViewTracks.SetupView;
begin
  { Always show master view, also on mobile. }
  MultiView.ShowMaster;

  { Bind properties }
  Binder.Bind(ViewModel, 'SelectedTrack', ListViewTracks, 'SelectedItem');
  Binder.Bind(ViewModel, 'SelectedTrack.Name', EditName, 'Text',
    TgoBindDirection.TwoWay, [TgoBindFlag.TargetTracking]);
  Binder.Bind(ViewModel, 'SelectedTrack.TrackNumber', SpinBoxTrackNumber, 'Value');
  Binder.Bind(ViewModel, 'SelectedTrackDurationMinutes', SpinBoxDurationMinutes, 'Value');
  Binder.Bind(ViewModel, 'SelectedTrackDurationSeconds', SpinBoxDurationSeconds, 'Value');
  Binder.Bind(ViewModel, 'SelectedTrack.Genres', MemoGenres, 'Text');

  { Note that you can bind an Object property (SelectedTrack) to a Boolean
    property (Enabled). The target property will be False if the object is nil,
    or True otherwise. This obviously only works in one direction. }
  Binder.Bind(ViewModel, 'SelectedTrack', ListBoxDetails, 'Enabled',
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
