unit Grijjy.Mvvm.Controls.Fmx;

{ Contains bindable versions of standard controls.

  This unit MUST be added to each form containing (two-way) bindable controls,
  AFTER all other FMX.* units!

  This is because all controls have the same (class) names as the original
  controls. This is needed because it is not always possible to derive controls
  (eg. TBindableSpinBox) because the FMX framework uses class names for some
  functionality (for example, see
  IFMXDefaultPropertyValueService.GetDefaultPropertyValue).
  We could replace this service with our own, but there are other cases where
  class names matter (such as with styling). }
{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.Rtti,
  System.Classes,
  FMX.Controls.Model,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Memo,
  FMX.ComboEdit,
  FMX.Colors,
  FMX.DateTimeCtrls,
  FMX.SpinBox,
  FMX.NumberBox,
  FMX.ListBox,
  FMX.ListView,
  FMX.Objects,
  FMX.ActnList,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.DataBinding.Collections;

{$REGION 'FMX.StdCtrls'}
type
  { TCheckBox with support for light-weight two-way data binding.
    Supports property changed notifications for: IsChecked }
  TCheckBox = class(FMX.StdCtrls.TCheckBox, IgoNotifyPropertyChanged)
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
  { TTrackBar with support for light-weight two-way data binding.
    Supports property changed notifications for: Value }
  TTrackBar = class(FMX.StdCtrls.TTrackBar, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoChanged; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TSwitch with support for light-weight two-way data binding.
    Supports property changed notifications for: IsChecked }
  TSwitch = class(FMX.StdCtrls.TSwitch, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoSwitch; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TArcDial with support for light-weight two-way data binding.
    Supports property changed notifications for: Value }
  TArcDial = class(FMX.StdCtrls.TArcDial, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure AfterChangedProc(Sender: TObject); override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.StdCtrls'}

{$REGION 'FMX.Edit'}
type
  { TEdit with support for light-weight two-way data binding.
    Supports property changed notifications for: Text
    Supports property changing notifications for: Text }
  TEdit = class(FMX.Edit.TEdit, IgoNotifyPropertyChanged,
    IgoNotifyPropertyChangeTracking)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FOnPropertyChangeTracking: IgoPropertyChangeTrackingEvent;
  protected
    function DefineModelClass: TDataModelClass; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  protected
    { IgoNotifyPropertyChangeTracking }
    function GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.Edit'}

{$REGION 'FMX.Memo'}
type
  { TMemo with support for light-weight two-way data binding.
    Supports property changed notifications for: Text
    Supports property changing notifications for: Text }
  TMemo = class(FMX.Memo.TMemo, IgoNotifyPropertyChanged,
    IgoNotifyPropertyChangeTracking)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FOnPropertyChangeTracking: IgoPropertyChangeTrackingEvent;
  protected
    function DefineModelClass: TDataModelClass; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  protected
    { IgoNotifyPropertyChangeTracking }
    function GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.Memo'}

{$REGION 'FMX.ComboEdit'}
type
  { TComboEdit with support for light-weight two-way data binding.
    Supports property changed notifications for: Text
    Supports property changing notifications for: Text }
  TComboEdit = class(FMX.ComboEdit.TComboEdit, IgoNotifyPropertyChanged,
    IgoNotifyPropertyChangeTracking)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FOnPropertyChangeTracking: IgoPropertyChangeTrackingEvent;
  protected
    function DefineModelClass: TDataModelClass; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  protected
    { IgoNotifyPropertyChangeTracking }
    function GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.ComboEdit'}

{$REGION 'FMX.Colors'}
type
  { TColorPanel with support for light-weight two-way data binding.
    Supports property changed notifications for: Color }
  TColorPanel = class(FMX.Colors.TColorPanel, IgoNotifyPropertyChanged)
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
  { TComboColorBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Color }
  TComboColorBox = class(FMX.Colors.TComboColorBox, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoColorChange(Sender: TObject); override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TColorListBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Color }
  TColorListBox = class(FMX.Colors.TColorListBox, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoChange; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TColorComboBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Color }
  TColorComboBox = class(FMX.Colors.TColorComboBox, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoChange; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { THueTrackBar with support for light-weight two-way data binding.
    Supports property changed notifications for: Value }
  THueTrackBar = class(FMX.Colors.THueTrackBar, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoChanged; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TAlphaTrackBar with support for light-weight two-way data binding.
    Supports property changed notifications for: Value }
  TAlphaTrackBar = class(FMX.Colors.TAlphaTrackBar, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoChanged; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TBWTrackBar with support for light-weight two-way data binding.
    Supports property changed notifications for: Value }
  TBWTrackBar = class(FMX.Colors.TBWTrackBar, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoChanged; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.Colors'}

{$REGION 'FMX.DateTimeCtrls'}
type
  { TTimeEdit with support for light-weight two-way data binding.
    Supports property changed notifications for: Time }
  TTimeEdit = class(FMX.DateTimeCtrls.TTimeEdit, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoDateTimeChanged; override;
    procedure HandlerPickerDateTimeChanged(Sender: TObject; const ADate: TDateTime); override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { TDateEdit with support for light-weight two-way data binding.
    Supports property changed notifications for: Date }
  TDateEdit = class(FMX.DateTimeCtrls.TDateEdit, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoDateTimeChanged; override;
    procedure HandlerPickerDateTimeChanged(Sender: TObject; const ADate: TDateTime); override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.DateTimeCtrls'}

{$REGION 'FMX.SpinBox'}
type
  { TSpinBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Value }
  TSpinBox = class(FMX.SpinBox.TSpinBox, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    function DefineModelClass: TDataModelClass; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.SpinBox'}

{$REGION 'FMX.NumberBox'}
type
  { TNumberBox with support for light-weight two-way data binding.
    Supports property changed notifications for: Value }
  TNumberBox = class(FMX.NumberBox.TNumberBox, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    function DefineModelClass: TDataModelClass; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.NumberBox'}

{$REGION 'FMX.ListBox'}
type
  { TListBox with support for light-weight two-way data binding.
    Supports property changed notifications for: ItemIndex, Selected, SelectedItem.
    NOTE: When used with data binding, the TListBoxItem.Data property is used
          to store the associated object. }
  TListBox = class(FMX.ListBox.TListBox, IgoCollectionViewProvider,
    IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FView: TgoCollectionView;
    function GetSelectedItem: TObject; inline;
    procedure SetSelectedItem(const Value: TObject);
  private
    procedure DoSelectionChanged;
    function FindListBoxItem(const AItem: TObject): Integer;
  protected
    procedure DoChange; override;
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

    procedure Clear; override;

    { The object that is associated with the selected item, or nil if there is
      no item selected or there is no object associated with the selected item.
      The associated object is the object in the TListBoxItem.Data property. }
    property SelectedItem: TObject read GetSelectedItem write SetSelectedItem;
  end;
{$ENDREGION 'FMX.ListBox'}

{$REGION 'FMX.ListView'}
type
  { TListView with support for light-weight two-way data binding.
    Supports property changed notifications for: ItemIndex, Selected, SelectedItem
    NOTE: When used with data binding, the TListViewItem.Tag property is used
          to store the associated object. This is an unsafe reference, so you
          must make sure that the associated objects are available for the
          lifetime of the list view. }
  TListView = class(FMX.ListView.TListView, IgoCollectionViewProvider,
    IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FView: TgoCollectionView;
    function GetSelectedItem: TObject; inline;
    procedure SetSelectedItem(const Value: TObject);
  private
    function FindListViewItem(const AItem: TObject): Integer;
  protected
    procedure DoChange; override;
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
      The associated object is the object in the TListViewItem.Tag property.
      This is an unsafe reference, so you must make sure that the associated
      objects are available for the lifetime of the list view. }
    property SelectedItem: TObject read GetSelectedItem write SetSelectedItem;
  end;
{$ENDREGION 'FMX.ListView'}

{$REGION 'FMX.Objects'}
type
  { TImage with support for light-weight two-way data binding.
    Supports property changed notifications for: Bitmap }
  TImage = class(FMX.Objects.TImage, IgoNotifyPropertyChanged)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
  protected
    procedure DoChanged; override;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  end;
{$ENDREGION 'FMX.Objects'}

{$REGION 'FMX.ActnList'}
type
  TAction = class(FMX.ActnList.TAction, IgoBindableAction)
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
{$ENDREGION 'FMX.ActnList'}

implementation

uses
  FMX.Forms,
  FMX.Graphics,
  FMX.ListView.Appearances,
  Grijjy.System;

type
  TBindableEditModel = class(TCustomEditModel)
  protected
    procedure DoChange; override;
    procedure DoChangeTracking; override;
  end;

type
  TBindableMemoModel = class(TCustomMemoModel)
  protected
    procedure DoChange; override;
    procedure DoChangeTracking; override;
  end;

type
  TBindableComboEditModel = class(TComboEditModel)
  protected
    procedure DoChange; override;
    procedure DoChangeTracking; override;
  end;

type
  TBindableSpinBoxModel = class(TSpinBoxModel)
  protected
    procedure DoChange; override;
  end;

type
  TBindableNumberBoxModel = class(TNumberBoxModel)
  protected
    procedure DoChange; override;
  end;

type
  TListBoxCollectionView = class(TgoCollectionView)
  private
    [weak] FListBox: TListBox;
  private
    procedure UpdateListBoxItem(const AListBoxItem: TListBoxItem;
      const AItem: TObject);
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
    constructor Create(const AListBox: TListBox);
  end;

type
  TListViewCollectionView = class(TgoCollectionView)
  private
    [weak] FListView: TListView;
  private
    procedure UpdateListViewItem(const AListViewItem: TListViewItem;
      const AItem: TObject);
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

{ TCheckBox }

function TCheckBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TCheckBox.HandleOnChange(Sender: TObject);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'IsChecked');

  if Assigned(FOrigOnChange) then
    FOrigOnChange(Sender);
end;

procedure TCheckBox.Loaded;
begin
  inherited;
  FOrigOnChange := OnChange;
  OnChange := HandleOnChange;
end;

{ TTrackBar }

procedure TTrackBar.DoChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Value');
  inherited;
end;

function TTrackBar.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TSwitch }

procedure TSwitch.DoSwitch;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'IsChecked');
  inherited;
end;

function TSwitch.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TArcDial }

procedure TArcDial.AfterChangedProc(Sender: TObject);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Value');
  inherited;
end;

function TArcDial.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TEdit }

function TEdit.DefineModelClass: TDataModelClass;
begin
  Result := TBindableEditModel;
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

{ TBindableEditModel }

procedure TBindableEditModel.DoChange;
var
  Owner: TComponent;
  Edit: TEdit absolute Owner;
begin
  Owner := Self.Owner; // Strong reference
  if (Owner <> nil) then
  begin
    Assert(Owner is TEdit);
    if Assigned(Edit.FOnPropertyChanged) then
      Edit.FOnPropertyChanged.Invoke(Owner, 'Text');
  end;
  inherited;
end;

procedure TBindableEditModel.DoChangeTracking;
var
  Owner: TComponent;
  Edit: TEdit absolute Owner;
begin
  inherited;
  Owner := Self.Owner; // Strong reference
  if (Owner <> nil) then
  begin
    Assert(Owner is TEdit);
    if Assigned(Edit.FOnPropertyChangeTracking) then
      Edit.FOnPropertyChangeTracking.Invoke(Owner, 'Text');
  end;
end;

{ TMemo }

function TMemo.DefineModelClass: TDataModelClass;
begin
  Result := TBindableMemoModel;
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

{ TBindableMemoModel }

procedure TBindableMemoModel.DoChange;
var
  Owner: TComponent;
  Memo: TMemo absolute Owner;
begin
  Owner := Self.Owner; // Strong reference
  if (Owner <> nil) then
  begin
    Assert(Owner is TMemo);
    if Assigned(Memo.FOnPropertyChanged) then
      Memo.FOnPropertyChanged.Invoke(Owner, 'Text');
  end;
  inherited;
end;

procedure TBindableMemoModel.DoChangeTracking;
var
  Owner: TComponent;
  Memo: TMemo absolute Owner;
begin
  inherited;
  Owner := Self.Owner; // Strong reference
  if (Owner <> nil) then
  begin
    Assert(Owner is TMemo);
    if Assigned(Memo.FOnPropertyChangeTracking) then
      Memo.FOnPropertyChangeTracking.Invoke(Owner, 'Text');
  end;
end;

{ TComboEdit }

function TComboEdit.DefineModelClass: TDataModelClass;
begin
  Result := TBindableComboEditModel;
end;

function TComboEdit.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

function TComboEdit.GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
begin
  if (FOnPropertyChangeTracking = nil) then
    FOnPropertyChangeTracking := TgoPropertyChangeTrackingEvent.Create;

  Result := FOnPropertyChangeTracking;
end;

{ TBindableComboEditModel }

procedure TBindableComboEditModel.DoChange;
var
  Owner: TComponent;
  ComboEdit: TComboEdit absolute Owner;
begin
  Owner := Self.Owner; // Strong reference
  if (Owner <> nil) then
  begin
    Assert(Owner is TComboEdit);
    if Assigned(ComboEdit.FOnPropertyChanged) then
      ComboEdit.FOnPropertyChanged.Invoke(Owner, 'Text');
  end;
  inherited;
end;

procedure TBindableComboEditModel.DoChangeTracking;
var
  Owner: TComponent;
  ComboEdit: TComboEdit absolute Owner;
begin
  inherited;
  Owner := Self.Owner; // Strong reference
  if (Owner <> nil) then
  begin
    Assert(Owner is TComboEdit);
    if Assigned(ComboEdit.FOnPropertyChangeTracking) then
      ComboEdit.FOnPropertyChangeTracking.Invoke(Owner, 'Text');
  end;
end;

{ TColorPanel }

function TColorPanel.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TColorPanel.HandleOnChange(Sender: TObject);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Color');

  if Assigned(FOrigOnChange) then
    FOrigOnChange(Sender);
end;

procedure TColorPanel.Loaded;
begin
  inherited;
  FOrigOnChange := OnChange;
  OnChange := HandleOnChange;
end;

{ TComboColorBox }

procedure TComboColorBox.DoColorChange(Sender: TObject);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Color');
  inherited;
end;

function TComboColorBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TColorListBox }

procedure TColorListBox.DoChange;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Color');
  inherited;
end;

function TColorListBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TColorComboBox }

procedure TColorComboBox.DoChange;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Color');
  inherited;
end;

function TColorComboBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ THueTrackBar }

procedure THueTrackBar.DoChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Value');
  inherited;
end;

function THueTrackBar.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TAlphaTrackBar }

procedure TAlphaTrackBar.DoChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Value');
  inherited;
end;

function TAlphaTrackBar.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TBWTrackBar }

procedure TBWTrackBar.DoChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Value');
  inherited;
end;

function TBWTrackBar.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TTimeEdit }

procedure TTimeEdit.DoDateTimeChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Time');
  inherited;
end;

function TTimeEdit.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TTimeEdit.HandlerPickerDateTimeChanged(Sender: TObject;
  const ADate: TDateTime);
begin
  { This method can be called from an OS specific picker (on iOS and Android).
    FMX does not protect those with the usual try..except block.
    So we do that here to make sure the application doesn't crash when an
    exception occurs in this method. }
  try
    inherited;
  except
    Application.HandleException(Self);
  end;
end;

{ TDateEdit }

procedure TDateEdit.DoDateTimeChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Date');
  inherited;
end;

function TDateEdit.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TDateEdit.HandlerPickerDateTimeChanged(Sender: TObject;
  const ADate: TDateTime);
begin
  { This method can be called from an OS specific picker (on iOS and Android).
    FMX does not protect those with the usual try..except block.
    So we do that here to make sure the application doesn't crash when an
    exception occurs in this method. }
  try
    inherited;
  except
    Application.HandleException(Self);
  end;
end;

{ TSpinBox }

function TSpinBox.DefineModelClass: TDataModelClass;
begin
  Result := TBindableSpinBoxModel;
end;

function TSpinBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TBindableSpinBoxModel }

procedure TBindableSpinBoxModel.DoChange;
var
  Owner: TComponent;
  SpinBox: TSpinBox absolute Owner;
begin
  Owner := Self.Owner; // Strong reference
  if (Owner <> nil) then
  begin
    Assert(Owner is TSpinBox);
    if Assigned(SpinBox.FOnPropertyChanged) then
      SpinBox.FOnPropertyChanged.Invoke(Owner, 'Value');
  end;
  inherited;
end;

{ TNumberBox }

function TNumberBox.DefineModelClass: TDataModelClass;
begin
  Result := TBindableNumberBoxModel;
end;

function TNumberBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

{ TBindableNumberBoxModel }

procedure TBindableNumberBoxModel.DoChange;
var
  Owner: TComponent;
  NumberBox: TNumberBox absolute Owner;
begin
  Owner := Self.Owner; // Strong reference
  if (Owner <> nil) then
  begin
    Assert(Owner is TNumberBox);
    if Assigned(NumberBox.FOnPropertyChanged) then
      NumberBox.FOnPropertyChanged.Invoke(Owner, 'Value');
  end;
  inherited;
end;

{ TListBox }

procedure TListBox.Clear;
begin
  if (Count > 0) then
  begin
    inherited;
    DoSelectionChanged;
  end;
end;

destructor TListBox.Destroy;
begin
  FView.Free;
  inherited;
end;

procedure TListBox.DoChange;
begin
  DoSelectionChanged;
  inherited;
end;

procedure TListBox.DoSelectionChanged;
begin
  if Assigned(FOnPropertyChanged) then
  begin
    FOnPropertyChanged.Invoke(Self, 'ItemIndex');
    FOnPropertyChanged.Invoke(Self, 'Selected');
    FOnPropertyChanged.Invoke(Self, 'SelectedItem');
  end;
end;

function TListBox.FindListBoxItem(const AItem: TObject): Integer;
var
  Item: TListBoxItem;
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Item := ItemByIndex(I);
    if (Item.Data = AItem) then
      Exit(I);
  end;

  Result := -1;
end;

function TListBox.GetCollectionView: IgoCollectionView;
begin
  if (FView = nil) then
    FView := TListBoxCollectionView.Create(Self);
  Result := FView;
end;

function TListBox.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

function TListBox.GetSelectedItem: TObject;
var
  Sel: TListBoxItem;
begin
  Sel := Selected;
  if Assigned(Sel) then
    Result := Sel.Data
  else
    Result := nil;
end;

procedure TListBox.SetSelectedItem(const Value: TObject);
begin
  ItemIndex := FindListBoxItem(Value);
end;

{ TListBoxCollectionView }

procedure TListBoxCollectionView.AddItemToView(const AItem: TObject);
var
  ListBox: TListBox;
  ListBoxItem: TListBoxItem;
begin
  ListBox := FListBox; // Strong reference
  if Assigned(ListBox) then
  begin
    ListBoxItem := TListBoxItem.Create(ListBox);
    UpdateListBoxItem(ListBoxItem, AItem);
    ListBox.AddObject(ListBoxItem);
  end;
end;

procedure TListBoxCollectionView.BeginUpdateView;
var
  ListBox: TListBox;
begin
  ListBox := FListBox; // Strong reference
  if Assigned(ListBox) then
    ListBox.BeginUpdate;
end;

procedure TListBoxCollectionView.ClearItemsInView;
var
  ListBox: TListBox;
begin
  ListBox := FListBox; // Strong reference
  if Assigned(ListBox) then
    ListBox.Clear;
end;

constructor TListBoxCollectionView.Create(const AListBox: TListBox);
begin
  Assert(Assigned(AListBox));
  inherited Create;
  FListBox := AListBox;
end;

procedure TListBoxCollectionView.DeleteItemFromView(const AItemIndex: Integer);
var
  ListBox: TListBox;
begin
  ListBox := FListBox; // Strong reference
  if Assigned(ListBox) then
    ListBox.Items.Delete(AItemIndex);
end;

procedure TListBoxCollectionView.EndUpdateView;
var
  ListBox: TListBox;
begin
  ListBox := FListBox; // Strong reference
  if Assigned(ListBox) then
    ListBox.EndUpdate;
end;

procedure TListBoxCollectionView.UpdateAllItemsInView;
var
  ListBox: TListBox;
  Item: TObject;
  ListBoxItem: TListBoxItem;
  Index: Integer;
begin
  ListBox := FListBox; // Strong reference
  if Assigned(ListBox) then
  begin
    Index := 0;
    for Item in Source do
    begin
      ListBoxItem := ListBox.ItemByIndex(Index);
      UpdateListBoxItem(ListBoxItem, Item);
      Inc(Index);
    end;
  end;
end;

procedure TListBoxCollectionView.UpdateItemInView(const AItem: TObject;
  const APropertyName: String);
var
  ListBox: TListBox;
  Index: Integer;
begin
  ListBox := FListBox; // Strong reference
  if Assigned(ListBox) then
  begin
    Index := ListBox.FindListBoxItem(AItem);
    if (Index >= 0) then
      UpdateListBoxItem(ListBox.ItemByIndex(Index), AItem);
  end;
end;

procedure TListBoxCollectionView.UpdateListBoxItem(
  const AListBoxItem: TListBoxItem; const AItem: TObject);
begin
  AListBoxItem.ItemData.Text := Template.GetTitle(AItem);
  AListBoxItem.ItemData.Detail := Template.GetDetail(AItem);
  AListBoxItem.ImageIndex := Template.GetImageIndex(AItem);
  AListBoxItem.Data := AItem;
end;

{ TListView }

destructor TListView.Destroy;
begin
  FView.Free;
  inherited;
end;

procedure TListView.DoChange;
begin
  if Assigned(FOnPropertyChanged) then
  begin
    FOnPropertyChanged.Invoke(Self, 'ItemIndex');
    FOnPropertyChanged.Invoke(Self, 'Selected');
    FOnPropertyChanged.Invoke(Self, 'SelectedItem');
  end;
  inherited;
end;

function TListView.FindListViewItem(const AItem: TObject): Integer;
var
  I: Integer;
  Item: TListViewItem;
begin
  for I := 0 to ItemCount - 1 do
  begin
    Item := Items[I];
    if (Item.Tag = NativeInt(AItem)) then
      Exit(I);
  end;

  Result := -1;
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
  Sel: TListViewItem;
begin
  Sel := TListViewItem(Selected);
  if Assigned(Sel) then
    Result := TObject(Sel.Tag)
  else
    Result := nil;
end;

procedure TListView.SetSelectedItem(const Value: TObject);
begin
  ItemIndex := FindListViewItem(Value);
end;

{ TListViewCollectionView }

procedure TListViewCollectionView.AddItemToView(const AItem: TObject);
var
  ListView: TListView;
  ListViewItem: TListViewItem;
begin
  ListView := FListView; // Strong reference
  if Assigned(ListView) then
  begin
    ListViewItem := ListView.Items.Add;
    UpdateListViewItem(ListViewItem, AItem);
  end;
end;

procedure TListViewCollectionView.BeginUpdateView;
var
  ListView: TListView;
begin
  ListView := FListView; // Strong reference
  if Assigned(ListView) then
    ListView.BeginUpdate;
end;

procedure TListViewCollectionView.ClearItemsInView;
var
  ListView: TListView;
begin
  ListView := FListView; // Strong reference
  if Assigned(ListView) then
    ListView.Items.Clear;
end;

constructor TListViewCollectionView.Create(const AListView: TListView);
begin
  Assert(Assigned(AListView));
  inherited Create;
  FListView := AListView;
end;

procedure TListViewCollectionView.DeleteItemFromView(const AItemIndex: Integer);
var
  ListView: TListView;
begin
  ListView := FListView; // Strong reference
  if Assigned(ListView) then
    ListView.DeleteItem(AItemIndex);
end;

procedure TListViewCollectionView.EndUpdateView;
var
  ListView: TListView;
begin
  ListView := FListView; // Strong reference
  if Assigned(ListView) then
    ListView.EndUpdate;
end;

procedure TListViewCollectionView.UpdateAllItemsInView;
var
  ListView: TListView;
  Item: TObject;
  ListViewItem: TListViewItem;
  Index: Integer;
begin
  ListView := FListView; // Strong reference
  if Assigned(ListView) then
  begin
    Index := 0;
    for Item in Source do
    begin
      ListViewItem := ListView.Items[Index];
      UpdateListViewItem(ListViewItem, Item);
      Inc(Index);
    end;
  end;
end;

procedure TListViewCollectionView.UpdateItemInView(const AItem: TObject;
  const APropertyName: String);
var
  ListView: TListView;
  Index: Integer;
begin
  ListView := FListView; // Strong reference
  if Assigned(ListView) then
  begin
    Index := ListView.FindListViewItem(AItem);
    if (Index >= 0) then
      UpdateListViewItem(ListView.Items[Index], AItem);
  end;
end;

procedure TListViewCollectionView.UpdateListViewItem(
  const AListViewItem: TListViewItem; const AItem: TObject);
begin
  AListViewItem.Text := Template.GetTitle(AItem);
  AListViewItem.Detail := Template.GetDetail(AItem);
  AListViewItem.ImageIndex := Template.GetImageIndex(AItem);
  AListViewItem.Tag := NativeInt(AItem);
end;

{ TImage }

procedure TImage.DoChanged;
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, 'Bitmap');
  inherited;
end;

function TImage.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
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
  if (Supported) and (not Suspended) and (Enabled) then
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
  if (Supported) and Assigned(FCanExecute) then
    Enabled := FCanExecute();
end;

{ Globals }

function LoadFmxBitmap(const AStream: TStream): TObject;
begin
  Result := TBitmap.CreateFromStream(AStream);
end;

initialization
  TgoBitmap._LoadBitmapFunc := LoadFmxBitmap;

end.
