unit View.Album;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  Vcl.ActnList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Grijjy.Mvvm.Controls.Vcl, // MUST be listed AFTER all other FMX.* units!
  Grijjy.Mvvm.Views.Vcl,
  ViewModel.Album;

type
  TViewAlbum = class(TgoFormView<TViewModelAlbum>)
    PanelButtons: TPanel;
    ButtonCancel: TButton;
    ButtonOK: TButton;
    ButtonEditTracks: TButton;
    LabelTitle: TLabel;
    EditTitle: TEdit;
    EditArtist: TEdit;
    LabelArtist: TLabel;
    LabelRecordLabel: TLabel;
    LabelCopyright: TLabel;
    EditCopyright: TEdit;
    EditRecordLabel: TEdit;
    LabelReleaseDate: TLabel;
    DateTimePickerReleaseDate: TDateTimePicker;
    LabelNotes: TLabel;
    MemoNotes: TMemo;
    ActionList: TActionList;
    ActionEditTracks: TAction;
    LabelBackgroundColor: TLabel;
    ColorBoxBackground: TColorBox;
  protected
    { TgoFormView }
    procedure SetupView; override;
  end;

implementation

uses
  Grijjy.Mvvm.DataBinding,
  Grijjy.Mvvm.ViewFactory,
  Grijjy.Mvvm.ValueConverters,
  Converter.TitleToCaption;

{$R *.dfm}

{ TViewAlbum }

procedure TViewAlbum.SetupView;
begin
  inherited;

  { Bind properties }
  Binder.Bind(ViewModel.Album, 'Title', Self, 'Caption',
    TgoBindDirection.OneWay, [], TTitleToCaption);
  Binder.Bind(ViewModel.Album, 'Title', EditTitle, 'Text',
    TgoBindDirection.TwoWay, [TgoBindFlag.TargetTracking]);
  Binder.Bind(ViewModel.Album, 'Artist', EditArtist, 'Text',
    TgoBindDirection.TwoWay, [TgoBindFlag.TargetTracking]);
  Binder.Bind(ViewModel.Album, 'RecordLabel', EditRecordLabel, 'Text');
  Binder.Bind(ViewModel.Album, 'Copyright', EditCopyright, 'Text');
  Binder.Bind(ViewModel.Album, 'ReleaseDate', DateTimePickerReleaseDate, 'Date');
  Binder.Bind(ViewModel.Album, 'BackgroundColor', ColorBoxBackground, 'Selected',
    TgoBindDirection.TwoWay, [], TgoAlphaColorToVclColor);
  Binder.Bind(ViewModel.Album, 'Notes', MemoNotes, 'Text');
  Binder.Bind(ViewModel.Album, 'IsValid', ButtonOK, 'Enabled',
    TgoBindDirection.OneWay);

  { Bind actions }
  ActionEditTracks.Bind(ViewModel.EditTracks);
end;

initialization
  TgoViewFactory.Register(TViewAlbum, 'Album');

end.
