unit View.Album;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.ListBox,
  FMX.Layouts,
  FMX.Edit,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.DateTimeCtrls,
  FMX.Colors,
  Grijjy.Mvvm.Controls.Fmx, // MUST be listed AFTER all other FMX.* units!
  Grijjy.Mvvm.Views.Fmx,
  ViewModel.Album;

type
  TViewAlbum = class(TgoFormView<TViewModelAlbum>)
    ToolBar: TToolBar;
    ButtonCancel: TButton;
    ButtonOK: TButton;
    ListBox: TListBox;
    ListBoxItemTitle: TListBoxItem;
    EditTitle: TEdit;
    ListBoxItemArtist: TListBoxItem;
    EditArtist: TEdit;
    ListBoxItemRecordLabel: TListBoxItem;
    EditRecordLabel: TEdit;
    ListBoxItemCopyright: TListBoxItem;
    EditCopyright: TEdit;
    ListBoxItemReleaseDate: TListBoxItem;
    DateEditReleaseDate: TDateEdit;
    ListBoxItemNotes: TListBoxItem;
    MemoNotes: TMemo;
    ListBoxItemTracks: TListBoxItem;
    ListBoxItemBackgroundColor: TListBoxItem;
    ComboColorBoxBackground: TComboColorBox;
    procedure ListBoxItemTracksClick(Sender: TObject);
  protected
    { TgoFormView }
    procedure SetupView; override;
  end;

implementation

uses
  System.SysConst,
  Grijjy.Mvvm.Rtti,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.DataBinding,
  Grijjy.Mvvm.ViewFactory,
  Converter.TitleToCaption;

{$R *.fmx}
{$R *.iPhone4in.fmx IOS}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Macintosh.fmx MACOS}

type
  { Prefix an album title with the text 'Album: ' }
  TTrackCountToText = class(TgoValueConverter)
  public
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; override;
  end;

{ TViewAlbum }

procedure TViewAlbum.ListBoxItemTracksClick(Sender: TObject);
begin
  ViewModel.EditTracks;
end;

procedure TViewAlbum.SetupView;
begin
  { Bind properties }
  Binder.Bind(ViewModel.Album, 'Title', Self, 'Caption',
    TgoBindDirection.OneWay, [], TTitleToCaption);
  Binder.Bind(ViewModel.Album, 'Title', EditTitle, 'Text',
    TgoBindDirection.TwoWay, [TgoBindFlag.TargetTracking]);
  Binder.Bind(ViewModel.Album, 'Artist', EditArtist, 'Text',
    TgoBindDirection.TwoWay, [TgoBindFlag.TargetTracking]);
  Binder.Bind(ViewModel.Album, 'RecordLabel', EditRecordLabel, 'Text');
  Binder.Bind(ViewModel.Album, 'Copyright', EditCopyright, 'Text');
  Binder.Bind(ViewModel.Album, 'ReleaseDate', DateEditReleaseDate, 'Date');
  Binder.Bind(ViewModel.Album, 'BackgroundColor', ComboColorBoxBackground, 'Color');
  Binder.Bind(ViewModel.Album, 'Notes', MemoNotes, 'Text');
  Binder.Bind(ViewModel.Album, 'TrackCount', ListBoxItemTracks.ItemData, 'Detail',
    TgoBindDirection.OneWay, [], TTrackCountToText);
  Binder.Bind(ViewModel.Album, 'IsValid', ButtonOK, 'Enabled',
    TgoBindDirection.OneWay);
end;

{ TTrackCountToText }

class function TTrackCountToText.ConvertSourceToTarget(
  const ASource: TgoValue): TgoValue;
var
  Count: Integer;
begin
  Assert(ASource.ValueType = TgoValueType.Ordinal);
  Count := ASource.AsOrdinal;
  case Count of
    0: Result := 'No tracks';
    1: Result := '1 track';
  else
    Result := Count.ToString + ' tracks';
  end;
end;

initialization
  TgoViewFactory.Register(TViewAlbum, 'Album');

end.
