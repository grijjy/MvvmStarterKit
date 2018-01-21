unit Model.Album;

interface

uses
  System.SysUtils,
  System.UITypes,
  System.Generics.Collections,
  Grijjy.Mvvm.Observable,
  Model.Track;

type
  { A model that represents a musical album }
  TAlbum = class(TgoObservable)
  {$REGION 'Internal Declarations'}
  private
    FTitle: String;
    FArtist: String;
    FRecordLabel: String;
    FCopyright: String;
    FNotes: String;
    FReleaseDate: TDateTime;
    FRawImage: TBytes;
    FBackgroundColor: TAlphaColor;
    FTextColor1: TAlphaColor;
    FTextColor2: TAlphaColor;
    FTextColor3: TAlphaColor;
    FTracks: TAlbumTracks;
    FBitmap: TObject;
    procedure SetTitle(const Value: String);
    function GetTrackCount: Integer; inline;
    procedure SetArtist(const Value: String);
    function GetBitmap: TObject;
    procedure SetCopyright(const Value: String);
    procedure SetNotes(const Value: String);
    procedure SetRecordLabel(const Value: String);
    procedure SetReleaseDate(const Value: TDateTime);
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetTextColor1(const Value: TAlphaColor);
    procedure SetTextColor2(const Value: TAlphaColor);
    procedure SetTextColor3(const Value: TAlphaColor);
    function GetIsValid: Boolean;
    function GetTracks: TEnumerable<TAlbumTrack>; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(const ASource: TAlbum);

    function AddTrack: TAlbumTrack;
    procedure RemoveTrack(const ATrack: TAlbumTrack);
    procedure SetTracks(const ATracks: TAlbumTracks);

    property RawImage: TBytes read FRawImage write FRawImage;

    { Bindable properties }
    property Title: String read FTitle write SetTitle;
    property Artist: String read FArtist write SetArtist;
    property RecordLabel: String read FRecordLabel write SetRecordLabel;
    property Copyright: String read FCopyright write SetCopyright;
    property Notes: String read FNotes write SetNotes;
    property ReleaseDate: TDateTime read FReleaseDate write SetReleaseDate;
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor;
    property TextColor1: TAlphaColor read FTextColor1 write SetTextColor1;
    property TextColor2: TAlphaColor read FTextColor2 write SetTextColor2;
    property TextColor3: TAlphaColor read FTextColor3 write SetTextColor3;
    property Tracks: TEnumerable<TAlbumTrack> read GetTracks;
    property TrackCount: Integer read GetTrackCount;
    property Bitmap: TObject read GetBitmap;
    property IsValid: Boolean read GetIsValid;
  end;

type
  TAlbums = TgoObservableCollection<TAlbum>;

implementation

uses
  Grijjy.Mvvm.Types;

{ TAlbum }

function TAlbum.AddTrack: TAlbumTrack;
begin
  Result := TAlbumTrack.Create;
  FTracks.Add(Result);
end;

procedure TAlbum.Assign(const ASource: TAlbum);
begin
  Assert(Assigned(ASource));
  { Important: do not assign to fields. Assign to properties instead, so it
    will fire PropertyChanged notifications. }
  Title := ASource.FTitle;
  Artist := ASource.FArtist;
  RecordLabel := ASource.FRecordLabel;
  Copyright := ASource.FCopyright;
  Notes := ASource.FNotes;
  ReleaseDate := ASource.FReleaseDate;
  RawImage := ASource.FRawImage;
  BackgroundColor := ASource.FBackgroundColor;
  TextColor1 := ASource.FTextColor1;
  TextColor2 := ASource.FTextColor2;
  TextColor3 := ASource.FTextColor3;
  FTracks.Assign(ASource.FTracks);
  PropertyChanged('TrackCount');

  { In the example, we don't clone FBitmap, since we don't allow users to set
    a bitmap anyway. }
end;

constructor TAlbum.Create;
begin
  inherited;
  FTracks := TAlbumTracks.Create;
  FTextColor1 := TAlphaColors.Black;
  FTextColor2 := TAlphaColors.Black;
  FTextColor3 := TAlphaColors.Black;
end;

destructor TAlbum.Destroy;
begin
  FTracks.Free;
  FBitmap.Free;
  inherited;
end;

function TAlbum.GetBitmap: TObject;
begin
  if (FBitmap = nil) and (FRawImage <> nil) then
  begin
    FBitmap := TgoBitmap.Load(FRawImage);

    { Don't need raw image anymore. Release it. }
    FRawImage := nil;
  end;
  Result := FBitmap;
end;

function TAlbum.GetIsValid: Boolean;
begin
  Result := (FTitle <> '') and (FArtist <> '');
end;

function TAlbum.GetTrackCount: Integer;
begin
  Result := FTracks.Count;
end;

function TAlbum.GetTracks: TEnumerable<TAlbumTrack>;
begin
  Result := FTracks;
end;

procedure TAlbum.RemoveTrack(const ATrack: TAlbumTrack);
begin
  FTracks.Remove(ATrack);
end;

procedure TAlbum.SetArtist(const Value: String);
begin
  if (Value <> FArtist) then
  begin
    FArtist := Value;
    PropertyChanged('Artist');
    PropertyChanged('IsValid');
  end;
end;

procedure TAlbum.SetBackgroundColor(const Value: TAlphaColor);
begin
  if (Value <> FBackgroundColor) then
  begin
    FBackgroundColor := Value;
    PropertyChanged('BackgroundColor');
  end;
end;

procedure TAlbum.SetCopyright(const Value: String);
begin
  if (Value <> FCopyright) then
  begin
    FCopyright := Value;
    PropertyChanged('Copyright');
  end;
end;

procedure TAlbum.SetNotes(const Value: String);
begin
  if (Value <> FNotes) then
  begin
    FNotes := Value;
    PropertyChanged('Notes');
  end;
end;

procedure TAlbum.SetRecordLabel(const Value: String);
begin
  if (Value <> FRecordLabel) then
  begin
    FRecordLabel := Value;
    PropertyChanged('RecordLabel');
  end;
end;

procedure TAlbum.SetReleaseDate(const Value: TDateTime);
begin
  if (Value <> FReleaseDate) then
  begin
    FReleaseDate := Value;
    PropertyChanged('ReleaseDate');
  end;
end;

procedure TAlbum.SetTextColor1(const Value: TAlphaColor);
begin
  if (Value <> FTextColor1) then
  begin
    FTextColor1 := Value;
    PropertyChanged('TextColor1');
  end;
end;

procedure TAlbum.SetTextColor2(const Value: TAlphaColor);
begin
  if (Value <> FTextColor2) then
  begin
    FTextColor2 := Value;
    PropertyChanged('TextColor2');
  end;
end;

procedure TAlbum.SetTextColor3(const Value: TAlphaColor);
begin
  if (Value <> FTextColor3) then
  begin
    FTextColor3 := Value;
    PropertyChanged('TextColor3');
  end;
end;

procedure TAlbum.SetTitle(const Value: String);
begin
  if (Value <> FTitle) then
  begin
    FTitle := Value;
    PropertyChanged('Title');
    PropertyChanged('IsValid');
  end;
end;

procedure TAlbum.SetTracks(const ATracks: TAlbumTracks);
begin
  if Assigned(ATracks) then
  begin
    FTracks.Assign(ATracks);
    PropertyChanged('TrackCount');
  end;
end;

end.
