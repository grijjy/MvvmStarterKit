unit Grijjy.Mvvm.Controls.Vcl;

{ Contains bindable versions of standard controls.

  This unit MUST be added to each form containing (two-way) bindable controls,
  AFTER all other Vcl.* units!

  This is because all controls have the same (class) names as the original
  controls. }

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.Classes,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.WinXCtrls,
  Vcl.WinXPickers,
  Vcl.WinXCalendars,
  Vcl.ActnList,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.DataBinding.Collections;

{$REGION 'Vcl.StdCtrs'}
type
  { TEdit with support for light-weight two-way data binding.
    Supports property changed notifications for: Text
    Supports property changing notifications for: Text
    NOTE: Both PropertyChanged and PropertyChangeTracking notifications are
    fired for each individual keypress. }
  TEdit = class(Vcl.StdCtrls.TEdit, IgoNotifyPropertyChanged,
    IgoNotifyPropertyChangeTracking)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FOnPropertyChangeTracking: IgoPropertyChangeTrackingEvent;
  protected
    procedure Change; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  protected
    { IgoNotifyPropertyChangeTracking }
    function GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TMemo with support for light-weight two-way data binding.
    Supports property changed notifications for: Text
    Supports property changing notifications for: Text
    NOTE: Both PropertyChanged and PropertyChangeTracking notifications are
    fired for each individual keypress. }
  TMemo = class(Vcl.StdCtrls.TMemo, IgoNotifyPropertyChanged,
    IgoNotifyPropertyChangeTracking)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FOnPropertyChangeTracking: IgoPropertyChangeTrackingEvent;
  protected
    procedure Change; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  protected
    { IgoNotifyPropertyChangeTracking }
    function GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TComboBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Text
    Supports property changing notifications for: Text
    NOTE: Both PropertyChanged and PropertyChangeTracking notifications are
    fired for each individual keypress. }
  TComboBox = class(Vcl.StdCtrls.TComboBox, IgoNotifyPropertyChanged,
    IgoNotifyPropertyChangeTracking)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FOnPropertyChangeTracking: IgoPropertyChangeTrackingEvent;
  protected
    procedure Change; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  protected
    { IgoNotifyPropertyChangeTracking }
    function GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TCheckBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Checked }
  TCheckBox = class(Vcl.StdCtrls.TCheckBox, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Click; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TRadioButton with support for light-weight two-way data binding.
    Supports property changed notifications for: Checked }
  TRadioButton = class(Vcl.StdCtrls.TRadioButton, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Click; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'Vcl.StdCtrs'}

{$REGION 'Vcl.ExtCtrs'}
type
  { TColorBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Selected }
  TColorBox = class(Vcl.ExtCtrls.TColorBox, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Change; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TColorListBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Selected }
  TColorListBox = class(Vcl.ExtCtrls.TColorListBox, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Click; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TRadioGroup with support for light-weight two-way data binding.
    Supports property changed notifications for: ItemIndex }
  TRadioGroup = class(Vcl.ExtCtrls.TRadioGroup, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Click; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TImage with support for light-weight two-way data binding.
    Supports property changed notifications for: Picture }
  TImage = class(Vcl.ExtCtrls.TImage, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOrigPictureChanged: TNotifyEvent;
    FOnPropertyChanged: IgoPropertyChangedEvent;
  private
    procedure PictureChanged(Sender: TObject);
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  public
    constructor Create(AOwner: TComponent); override;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'Vcl.ExtCtrs'}

{$REGION 'Vcl.ComCtrs'}
type
  { TDateTimePicker with support for light-weight two-way data binding.
    Supports property changed notifications for: Date, Time }
  TDateTimePicker = class(Vcl.ComCtrls.TDateTimePicker, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Change; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TMonthCalendar with support for light-weight two-way data binding.
    Supports property changed notifications for: Date }
  TMonthCalendar = class(Vcl.ComCtrls.TMonthCalendar, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Click; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TUpDown with support for light-weight two-way data binding.
    Supports property changed notifications for: Position }
  TUpDown = class(Vcl.ComCtrls.TUpDown, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Click(Button: TUDBtnType); override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TTrackBar with support for light-weight two-way data binding.
    Supports property changed notifications for: Position }
  TTrackBar = class(Vcl.ComCtrls.TTrackBar, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Changed; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TListView with support for light-weight two-way data binding.
    Supports property changed notifications for: Selected, SelectedItem.
    NOTE: When used with data binding, the TListItem.Data property is used
          to store the associated object.
    NOTE: When used with data binding, the GetDetail value of a data template
          is assigned to TListItem.SubItems[0]. }
  TListView = class(Vcl.ComCtrls.TListView, IgoCollectionViewProvider,
    IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FView: TgoCollectionView;
    function GetSelectedItem: TObject; inline;
    procedure SetSelectedItem(const Value: TObject);
  private
    function FindListItem(const AItem: TObject): TListItem;
  protected
    procedure DoSelectItem(Item: TListItem; Selected: Boolean); override;
  protected
    { IgoCollectionViewProvider }
    function GetCollectionView: IgoCollectionView;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  public
    { Destructor }
    destructor Destroy; override;

    { The object that is associated with the selected item, or nil if there is
      no item selected or there is no object associated with the selected item.
      The associated object is the object in the TListItem.Data property. }
    property SelectedItem: TObject read GetSelectedItem write SetSelectedItem;
  end;
{$ENDREGION 'Vcl.ComCtrs'}

{$REGION 'Vcl.WinXCtrls'}
type
  { TToggleSwitch with support for light-weight two-way data binding.
    Supports property changed notifications for: State }
  TToggleSwitch = class(Vcl.WinXCtrls.TToggleSwitch, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure Click; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'Vcl.WinXCtrls'}

{$REGION 'Vcl.WinXPickers'}
type
  { TDatePicker with support for light-weight two-way data binding.
    Supports property changed notifications for: Date }
  TDatePicker = class(Vcl.WinXPickers.TDatePicker, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOrigOnChange: TNotifyEvent;
    FOnPropertyChanged: IgoPropertyChangedEvent;
  private
    procedure HandleOnChange(Sender: TObject);
  protected
    procedure Loaded; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TTimePicker with support for light-weight two-way data binding.
    Supports property changed notifications for: Time }
  TTimePicker = class(Vcl.WinXPickers.TTimePicker, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOrigOnChange: TNotifyEvent;
    FOnPropertyChanged: IgoPropertyChangedEvent;
  private
    procedure HandleOnChange(Sender: TObject);
  protected
    procedure Loaded; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'Vcl.WinXPickers'}

{$REGION 'Vcl.WinXCalendars'}
type
  { TCalendarPicker with support for light-weight two-way data binding.
    Supports property changed notifications for: Date }
  TCalendarPicker = class(Vcl.WinXCalendars.TCalendarPicker, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOrigOnChange: TNotifyEvent;
    FOnPropertyChanged: IgoPropertyChangedEvent;
  private
    procedure HandleOnChange(Sender: TObject);
  protected
    procedure Loaded; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'Vcl.WinXCalendars'}

{$REGION 'Vcl.ActnList'}
type
  TAction = class(Vcl.ActnList.TAction, IgoBindableAction)
  {$REGION 'Internal Declarations'}
  private
    FExecute: TgoExecuteMethod;
    FExecuteInt: TgoExecuteMethod<Integer>;
    FCanExecute: TgoCanExecuteMethod;
  {$ENDREGION 'Internal Declarations'}
  public
    { IgoBindableAction }
    procedure Bind(const AExecute: TgoExecuteMethod;
      const ACanExecute: TgoCanExecuteMethod = nil); overload;
    procedure Bind(const AExecute: TgoExecuteMethod<Integer>;
      const ACanExecute: TgoCanExecuteMethod = nil); overload;
  public
    constructor Create(AOwner: TComponent); override;
    function Update: Boolean; override;
    function Execute: Boolean; override;
  end;
{$ENDREGION 'Vcl.ActnList'}

implementation

uses
  Vcl.Graphics;

type
  TListViewCollectionView = class(TgoCollectionView)
  private
    FListView: TListView;
  private
    procedure UpdateListItem(const AListItem: TListItem; const AItem: TObject);
  protected
    procedure ClearItemsInView; override;
    procedure BeginUpdateView; override;
    procedure EndUpdateView; override;
    procedure AddItemToView(const AItem: TObject); override;
    procedure DeleteItemFromView(const AItemIndex: Integer); override;
    procedure UpdateItemInView(const AItem: TObject;
      const APropertyName: String); override;
    procedure UpdateAllItemsInView; override;
  public
    constructor Create(const AListView: TListView);
  end;

{ TEdit }

procedure TEdit.Change;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Text');

  if Assigned(FOnPropertyChangeTracking) then
    FOnPropertyChangeTracking.Invoke(Self, 'Text');
  inherited;
end;

function TEdit.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

function TEdit.GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
begin
  if (FOnPropertyChangeTracking = nil) then
    FOnPropertyChangeTracking := TgoPropertyChangeTrackingEvent.Create;

  Result := FOnPropertyChangeTracking;
end;

{ TMemo }

procedure TMemo.Change;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Text');

  if Assigned(FOnPropertyChangeTracking) then
    FOnPropertyChangeTracking.Invoke(Self, 'Text');
  inherited;
end;

function TMemo.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

function TMemo.GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
begin
  if (FOnPropertyChangeTracking = nil) then
    FOnPropertyChangeTracking := TgoPropertyChangeTrackingEvent.Create;

  Result := FOnPropertyChangeTracking;
end;

{ TComboBox }

procedure TComboBox.Change;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Text');

  if Assigned(FOnPropertyChangeTracking) then
    FOnPropertyChangeTracking.Invoke(Self, 'Text');
  inherited;
end;

function TComboBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

function TComboBox.GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
begin
  if (FOnPropertyChangeTracking = nil) then
    FOnPropertyChangeTracking := TgoPropertyChangeTrackingEvent.Create;

  Result := FOnPropertyChangeTracking;
end;

{ TCheckBox }

procedure TCheckBox.Click;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Checked');
  inherited;
end;

function TCheckBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TRadioButton }

procedure TRadioButton.Click;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Checked');
  inherited;
end;

function TRadioButton.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TColorBox }

procedure TColorBox.Change;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Selected');
  inherited;
end;

function TColorBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TColorListBox }

procedure TColorListBox.Click;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Selected');
  inherited;
end;

function TColorListBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TRadioGroup }

procedure TRadioGroup.Click;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'ItemIndex');
  inherited;
end;

function TRadioGroup.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TImage }

constructor TImage.Create(AOwner: TComponent);
begin
  inherited;
  FOrigPictureChanged := Picture.OnChange;
  Picture.OnChange := PictureChanged;
end;

function TImage.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TImage.PictureChanged(Sender: TObject);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Picture');

  if Assigned(FOrigPictureChanged) then
    FOrigPictureChanged(Self);
end;

{ TDateTimePicker }

procedure TDateTimePicker.Change;
begin
  if Assigned(FOnPropertyChanged) then
  begin
    if (Kind = TDateTimeKind.dtkDate) then
      FOnPropertyChanged.Invoke(Self, 'Date')
    else
      FOnPropertyChanged.Invoke(Self, 'Time');
  end;
  inherited;
end;

function TDateTimePicker.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TMonthCalendar }

procedure TMonthCalendar.Click;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Date');
  inherited;
end;

function TMonthCalendar.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TUpDown }

procedure TUpDown.Click(Button: TUDBtnType);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Position');
  inherited;
end;

function TUpDown.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TTrackBar }

procedure TTrackBar.Changed;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Position');
  inherited;
end;

function TTrackBar.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TListView }

destructor TListView.Destroy;
begin
  FView.Free;
  inherited;
end;

procedure TListView.DoSelectItem(Item: TListItem; Selected: Boolean);
begin
  if Selected and Assigned(FOnPropertyChanged) then
  begin
    FOnPropertyChanged.Invoke(Self, 'Selected');
    FOnPropertyChanged.Invoke(Self, 'SelectedItem');
  end;
  inherited;
end;

function TListView.FindListItem(const AItem: TObject): TListItem;
var
  I: Integer;
begin
  for I := 0 to Items.Count - 1 do
  begin
    Result := Items[I];
    if (Result.Data = AItem) then
      Exit;
  end;
  Result := nil;
end;

function TListView.GetCollectionView: IgoCollectionView;
begin
  if (FView = nil) then
    FView := TListViewCollectionView.Create(Self);

  Result := FView;
end;

function TListView.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

function TListView.GetSelectedItem: TObject;
var
  Sel: TListItem;
begin
  Sel := Selected;
  if (Sel = nil) then
    Result := nil
  else
    Result := Sel.Data;
end;

procedure TListView.SetSelectedItem(const Value: TObject);
begin
  Selected := FindListItem(Value);
end;

{ TToggleSwitch }

procedure TToggleSwitch.Click;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'State');
  inherited;
end;

function TToggleSwitch.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TDatePicker }

function TDatePicker.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TDatePicker.HandleOnChange(Sender: TObject);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Date');

  if Assigned(FOrigOnChange) then
    FOrigOnChange(Sender);
end;

procedure TDatePicker.Loaded;
begin
  inherited;
  FOrigOnChange := OnChange;
  OnChange := HandleOnChange;
end;

{ TTimePicker }

function TTimePicker.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TTimePicker.HandleOnChange(Sender: TObject);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Time');

  if Assigned(FOrigOnChange) then
    FOrigOnChange(Sender);
end;

procedure TTimePicker.Loaded;
begin
  inherited;
  FOrigOnChange := OnChange;
  OnChange := HandleOnChange;
end;

{ TCalendarPicker }

function TCalendarPicker.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TCalendarPicker.HandleOnChange(Sender: TObject);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Date');

  if Assigned(FOrigOnChange) then
    FOrigOnChange(Sender);
end;

procedure TCalendarPicker.Loaded;
begin
  inherited;
  FOrigOnChange := OnChange;
  OnChange := HandleOnChange;
end;

{ TListViewCollectionView }

procedure TListViewCollectionView.AddItemToView(const AItem: TObject);
var
  Item: TListItem;
begin
  Item := FListView.Items.Add;
  UpdateListItem(Item, AItem);
end;

procedure TListViewCollectionView.BeginUpdateView;
begin
  FListView.Items.BeginUpdate;
end;

procedure TListViewCollectionView.ClearItemsInView;
begin
  FListView.Items.Clear;
end;

constructor TListViewCollectionView.Create(const AListView: TListView);
begin
  Assert(Assigned(AListView));
  inherited Create;
  FListView := AListView;
end;

procedure TListViewCollectionView.DeleteItemFromView(const AItemIndex: Integer);
begin
  FListView.Items.Delete(AItemIndex);
end;

procedure TListViewCollectionView.EndUpdateView;
begin
  FListView.Items.EndUpdate;
end;

procedure TListViewCollectionView.UpdateAllItemsInView;
var
  Index: Integer;
  Item: TObject;
  ListItem: TListItem;
begin
  Index := 0;
  for Item in Source do
  begin
    ListItem := FListView.Items[Index];
    UpdateListItem(ListItem, Item);
    Inc(Index);
  end;
end;

procedure TListViewCollectionView.UpdateItemInView(const AItem: TObject;
  const APropertyName: String);
var
  ListItem: TListItem;
begin
  ListItem := FListView.FindListItem(AItem);
  if (ListItem <> nil) then
    UpdateListItem(ListItem, AItem);
end;

procedure TListViewCollectionView.UpdateListItem(const AListItem: TListItem;
  const AItem: TObject);
var
  Detail: String;
begin
  AListItem.Caption := Template.GetTitle(AItem);

  Detail := Template.GetDetail(AItem);
  if (Detail = '') then
  begin
    if (AListItem.SubItems.Count > 0) then
      AListItem.SubItems[0] := '';
  end
  else
  begin
    if (AListItem.SubItems.Count = 0) then
      AListItem.SubItems.Add(Detail)
    else
      AListItem.SubItems[0] := Detail;
  end;

  AListItem.ImageIndex := Template.GetImageIndex(AItem);
  AListItem.Data := AItem;
end;

{ Globals }

function LoadVclBitmap(const AStream: TStream): TObject;
var
  Bitmap: TBitmap;
  WICImage: TWICImage;
begin
  Bitmap := TBitmap.Create;
  try
    if (Bitmap.CanLoadFromStream(AStream)) then
      { .bmp format }
      Bitmap.LoadFromStream(AStream)
    else
    begin
      { Try WIC }
      WICImage := TWICImage.Create;
      try
        WICImage.LoadFromStream(AStream);
        Bitmap.Assign(WICImage);
      finally
        WICImage.Free;
      end;
    end;
  except
    Bitmap.Free;
    raise;
  end;
  Result := Bitmap;
end;

{ TAction }

procedure TAction.Bind(const AExecute: TgoExecuteMethod;
  const ACanExecute: TgoCanExecuteMethod);
begin
  FExecute := AExecute;
  FCanExecute := ACanExecute;
end;

procedure TAction.Bind(const AExecute: TgoExecuteMethod<Integer>;
  const ACanExecute: TgoCanExecuteMethod);
begin
  FExecuteInt := AExecute;
  FCanExecute := ACanExecute;
end;

constructor TAction.Create(AOwner: TComponent);
begin
  inherited;
  DisableIfNoHandler := False;
end;

function TAction.Execute: Boolean;
begin
  { The inherted Execute method also calls Update, so Enabled will be set to
    False if the action should not execute. }
  Result := inherited Execute;
  if (not Suspended) and (Enabled) then
  begin
    if Assigned(FExecute) then
      FExecute()
    else if Assigned(FExecuteInt) then
      FExecuteInt(Tag);
  end;
end;

function TAction.Update: Boolean;
begin
  Result := inherited Update;
  if Assigned(FCanExecute) then
    Enabled := FCanExecute();
end;

initialization
  TgoBitmap._LoadBitmapFunc := LoadVclBitmap;

end.
