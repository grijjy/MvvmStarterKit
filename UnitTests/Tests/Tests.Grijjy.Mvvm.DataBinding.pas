unit Tests.Grijjy.Mvvm.DataBinding;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.Classes,
  System.SysUtils,
  DUnitX.TestFramework,
  Grijjy.System,
  Grijjy.Mvvm.Rtti,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.Observable,
  Grijjy.Mvvm.DataBinding,
  Grijjy.Mvvm.DataBinding.Collections;

type
  TFoo = class(TgoObservable)
  strict private
    FReadWriteInt: Integer;
    FReadOnlyFloat: Single;
    FWriteOnlyString: String;
    FBytes: TBytes;
  private
    procedure SetReadWriteInt(const Value: Integer);
    procedure SetWriteOnlyString(const Value: String);
  public
    property ReadWriteInt: Integer read FReadWriteInt write SetReadWriteInt;
    property ReadOnlyFloat: Single read FReadOnlyFloat;
    property WriteOnlyString: String write SetWriteOnlyString;
    property Bytes: TBytes read FBytes write FBytes;
  end;

type
  TBar = class(TgoObservable)
  strict private
    FReadOnlyInt: Integer;
    FWriteOnlyFloat: Single;
    FReadWriteString: String;
    FReadWriteFloat: Single;
    FFoo: TFoo;
    FRec: TSearchRec;
  private
    procedure SetReadWriteString(const Value: String);
    procedure SetWriteOnlyFloat(const Value: Single);
    procedure SetFoo(const Value: TFoo);
    procedure SetReadWriteFloat(const Value: Single);
  public
    property ReadOnlyInt: Integer read FReadOnlyInt;
    property WriteOnlyFloat: Single write SetWriteOnlyFloat;
    property ReadWriteString: String read FReadWriteString write SetReadWriteString;
    property ReadWriteFloat: Single read FReadWriteFloat write SetReadWriteFloat;
    property Foo: TFoo read FFoo write SetFoo;
    property Rec: TSearchRec read FRec write FRec;
  end;

type
  TBaz = class(TgoNonRefCountedObject, IgoNotifyFree) // NOT observable
  strict private
    FOnFree: IgoFreeEvent;
    FWriteOnlyInt: Integer;
    FReadWriteFloat: Single;
    FReadOnlyString: String;
  protected
    { IgrNotifyFree }
    function GetFreeEvent: IgoFreeEvent;
  public
    destructor Destroy; override;

    property WriteOnlyInt: Integer write FWriteOnlyInt;
    property ReadWriteFloat: Single read FReadWriteFloat write FReadWriteFloat;
    property ReadOnlyString: String read FReadOnlyString;
  end;

type
  TLink = class(TgoObservable)
  strict private
    FIntValue: Integer;
    FNext: TLink;
    procedure SetIntValue(const Value: Integer);
    procedure SetNext(const Value: TLink);
  public
    property IntValue: Integer read FIntValue write SetIntValue;
    property Next: TLink read FNext write SetNext;
  end;

type
  TAction = class(TgoNonRefCountedObject, IgoBindableAction)
  private
    FExecute: TgoExecuteMethod;
    FExecuteInt: TgoExecuteMethod<Integer>;
    FCanExecute: TgoCanExecuteMethod;
    FValue: Integer;
  protected
    { IgrBindableAction }
    procedure Bind(const AExecute: TgoExecuteMethod;
      const ACanExecute: TgoCanExecuteMethod = nil); overload;
    procedure Bind(const AExecute: TgoExecuteMethod<Integer>;
      const ACanExecute: TgoCanExecuteMethod = nil); overload;
  public
    constructor Create(const AValue: Integer);
    procedure Execute;
  end;

type
  TTestTgoDataBinder = class
  private
    FBinder: TgoDataBinder;
    FFoo: TFoo;
    FBar: TBar;
    FBaz: TBaz;
    FFoos: array [0..3] of TFoo;
    FLinks: array [0..3] of TLink;
    FAction: TAction;
    FExecutedActionValue: Integer;
  private
    function ReturnFalse: Boolean;
    function ReturnTrue: Boolean;
    procedure ExecuteAction;
    procedure ExecuteActionArg(const AValue: Integer);
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestDefault;
    [Test] procedure TestOneWay;
    [Test] procedure TestApply;
    [Test] procedure TestDontApply;
    [Test] procedure TestConverter;
    [Test] procedure TestSourceNotObservable;
    [Test] procedure TestTargetNotObservable;
    [Test] procedure TestTargetNotObservableOneWay;
    [Test] procedure TestSourcePropertyDoesNotExist;
    [Test] procedure TestTargetPropertyDoesNotExist;
    [Test] procedure TestPropertyUnsupportedType;
    [Test] procedure TestPropertyNotConvertible;
    [Test] procedure TestSourcePropertyNotReadable;
    [Test] procedure TestTargetPropertyNotWritable;
    [Test] procedure TestSourcePropertyNotWritable;
    [Test] procedure TestTargetPropertyNotReadable;
    [Test] procedure TestMultipleTargets;
    [Test] procedure TestMultipleSources;
    [Test] procedure TestMultipleSourcesAndTargets;
    [Test] procedure TestSourceStaticPath;
    [Test] procedure TestSourceDynamicPath;
    [Test] procedure TestTargetStaticPath;
    [Test] procedure TestBindCollection;
    [Test] procedure TestBindActionDefault;
    [Test] procedure TestBindActionDisabled;
    [Test] procedure TestBindActionEnabled;
    [Test] procedure TestBindActionArgDefault;
    [Test] procedure TestBindActionArgDisabled;
    [Test] procedure TestBindActionArgEnabled;
  end;

implementation

uses
  System.SysConst,
  Grijjy.SysUtils;

type
  TMultiplyByTwoConverter = class(TgoValueConverter)
  public
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; override;
    class function ConvertTargetToSource(const ATarget: TgoValue): TgoValue; override;
  end;

type
  TBarCollectionViewItem = record
  public
    Title: String;
    Detail: String;
    ImageIndex: Integer;
  end;

type
  TBarCollectionView = class(TgoCollectionView, IgoCollectionViewProvider)
  private
    FItems: TArray<TBarCollectionViewItem>;
  protected
    { IgrCollectionViewProvider }
    function GetCollectionView: IgoCollectionView;
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
    property Items: TArray<TBarCollectionViewItem> read FItems;
  end;

type
  TBarTemplate = class(TgoDataTemplate)
  public
    class function GetTitle(const AItem: TObject): String; override;
    class function GetDetail(const AItem: TObject): String; override;
    class function GetImageIndex(const AItem: TObject): Integer; override;
  end;

{ TMultiplyByTwoConverter }

class function TMultiplyByTwoConverter.ConvertSourceToTarget(
  const ASource: TgoValue): TgoValue;
begin
  case ASource.ValueType of
    TgoValueType.Ordinal:
      Result := TgoValue.CreateOrdinal(ASource.AsOrdinal * 2);

    TgoValueType.Int64:
      Result := TgoValue.CreateInt64(ASource.AsInt64 * 2);

    TgoValueType.Float:
      Result := TgoValue.CreateFloat(ASource.AsDouble * 2);
  else
    Result := ASource;
  end;
end;

class function TMultiplyByTwoConverter.ConvertTargetToSource(
  const ATarget: TgoValue): TgoValue;
begin
  case ATarget.ValueType of
    TgoValueType.Ordinal:
      Result := TgoValue.CreateOrdinal(ATarget.AsOrdinal div 2);

    TgoValueType.Int64:
      Result := TgoValue.CreateInt64(ATarget.AsInt64 div 2);

    TgoValueType.Float:
      Result := TgoValue.CreateFloat(ATarget.AsDouble / 2);
  else
    Result := ATarget;
  end;
end;

{ TBarCollectionView }

procedure TBarCollectionView.AddItemToView(const AItem: TObject);
var
  ViewItem: TBarCollectionViewItem;
begin
  ViewItem.Title := Template.GetTitle(AItem);
  ViewItem.Detail := Template.GetDetail(AItem);
  ViewItem.ImageIndex := Template.GetImageIndex(AItem);
  FItems := FItems + [ViewItem];
end;

procedure TBarCollectionView.BeginUpdateView;
begin
  { NOP }
end;

procedure TBarCollectionView.ClearItemsInView;
begin
  FItems := nil;
end;

procedure TBarCollectionView.DeleteItemFromView(const AItemIndex: Integer);
begin
  System.Assert(False, 'Should not reach here');
end;

procedure TBarCollectionView.EndUpdateView;
begin
  { NOP }
end;

function TBarCollectionView.GetCollectionView: IgoCollectionView;
begin
  Result := Self;
end;

procedure TBarCollectionView.UpdateAllItemsInView;
begin
  System.Assert(False, 'Should not reach here');
end;

procedure TBarCollectionView.UpdateItemInView(const AItem: TObject;
  const APropertyName: String);
begin
  System.Assert(False, 'Should not reach here');
end;

{ TBarTemplate }

class function TBarTemplate.GetDetail(const AItem: TObject): String;
begin
  System.Assert(AItem is TBar);
  Result := FloatToStr(TBar(AItem).ReadWriteFloat, goUSFormatSettings)
end;

class function TBarTemplate.GetImageIndex(const AItem: TObject): Integer;
begin
  System.Assert(AItem is TBar);
  Result := Trunc(TBar(AItem).ReadWriteFloat)
end;

class function TBarTemplate.GetTitle(const AItem: TObject): String;
begin
  System.Assert(AItem is TBar);
  Result := TBar(AItem).ReadWriteString;
end;

{ TAction }

procedure TAction.Bind(const AExecute: TgoExecuteMethod<Integer>;
  const ACanExecute: TgoCanExecuteMethod);
begin
  FExecuteInt := AExecute;
  FCanExecute := ACanExecute;
end;

procedure TAction.Bind(const AExecute: TgoExecuteMethod;
  const ACanExecute: TgoCanExecuteMethod);
begin
  FExecute := AExecute;
  FCanExecute := ACanExecute;
end;

constructor TAction.Create(const AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

procedure TAction.Execute;
var
  Enabled: Boolean;
begin
  Enabled := True;
  if Assigned(FCanExecute) then
    Enabled := FCanExecute();

  if Enabled then
  begin
    if Assigned(FExecute) then
      FExecute()
    else if Assigned(FExecuteInt) then
      FExecuteInt(FValue)
  end;
end;

{ TFoo }

procedure TFoo.SetReadWriteInt(const Value: Integer);
begin
  if (Value <> FReadWriteInt) then
  begin
    FReadWriteInt := Value;
    PropertyChanged('ReadWriteInt');
  end;
end;

procedure TFoo.SetWriteOnlyString(const Value: String);
begin
  if (Value <> FWriteOnlyString) then
  begin
    FWriteOnlyString := Value;
    PropertyChanged('WriteOnlyString');
  end;
end;

{ TBar }

procedure TBar.SetFoo(const Value: TFoo);
begin
  if (Value <> FFoo) then
  begin
    FFoo := Value;
    PropertyChanged('Foo');
  end;
end;

procedure TBar.SetReadWriteFloat(const Value: Single);
begin
  if (Value <> FReadWriteFloat) then
  begin
    FReadWriteFloat := Value;
    PropertyChanged('ReadWriteFloat');
  end;
end;

procedure TBar.SetReadWriteString(const Value: String);
begin
  if (Value <> FReadWriteString) then
  begin
    FReadWriteString := Value;
    PropertyChanged('ReadWriteString');
  end;
end;

procedure TBar.SetWriteOnlyFloat(const Value: Single);
begin
  if (Value <> FWriteOnlyFloat) then
  begin
    FWriteOnlyFloat := Value;
    PropertyChanged('WriteOnlyFloat');
  end;
end;

{ TBaz }

destructor TBaz.Destroy;
begin
  if Assigned(FOnFree) then
    FOnFree.Invoke(Self, Self);
  inherited;
end;

function TBaz.GetFreeEvent: IgoFreeEvent;
begin
  if (FOnFree = nil) then
    FOnFree := TgoFreeEvent.Create;

  Result := FOnFree;
end;

{ TLink }

procedure TLink.SetIntValue(const Value: Integer);
begin
  if (Value <> FIntValue) then
  begin
    FIntValue := Value;
    PropertyChanged('IntValue');
  end;
end;

procedure TLink.SetNext(const Value: TLink);
begin
  if (Value <> FNext) then
  begin
    FNext := Value;
    PropertyChanged('Next');
  end;
end;

{ TTestTgoDataBinder }

procedure TTestTgoDataBinder.ExecuteAction;
begin
  FExecutedActionValue := 1;
end;

procedure TTestTgoDataBinder.ExecuteActionArg(const AValue: Integer);
begin
  FExecutedActionValue := AValue;
end;

function TTestTgoDataBinder.ReturnFalse: Boolean;
begin
  Result := False;
end;

function TTestTgoDataBinder.ReturnTrue: Boolean;
begin
  Result := True;
end;

procedure TTestTgoDataBinder.Setup;
var
  I: Integer;
begin
  inherited;
  FBinder := TgoDataBinder.Create;
  FFoo := TFoo.Create;
  FBar := TBar.Create;
  FBaz := TBaz.Create;
  FAction := TAction.Create(42);
  FExecutedActionValue := 0;
  for I := 0 to Length(FLinks) - 1 do
  begin
    FLinks[I] := TLink.Create;
    FLinks[I].IntValue := I + 1;
    FFoos[I] := TFoo.Create;
    FFoos[I].ReadWriteInt := -1 - I;
  end;
end;

procedure TTestTgoDataBinder.Teardown;
var
  I: Integer;
begin
  inherited;
  FAction.Free;
  FBaz.Free;
  FBar.Free;
  FFoo.Free;
  FBinder.Free;
  for I := 0 to Length(FLinks) - 1 do
  begin
    FLinks[I].Free;
    FFoos[I].Free;
  end;
end;

procedure TTestTgoDataBinder.TestApply;
begin
  FFoo.ReadWriteInt := 42;
  FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadWriteString');
  Assert.AreEqual('42', FBar.ReadWriteString);
end;

procedure TTestTgoDataBinder.TestBindActionArgDefault;
begin
  FBinder.BindAction(FAction, ExecuteActionArg);
  FAction.Execute;
  Assert.AreEqual(42, FExecutedActionValue);
end;

procedure TTestTgoDataBinder.TestBindActionArgDisabled;
begin
  FBinder.BindAction(FAction, ExecuteActionArg, ReturnFalse);
  FAction.Execute;
  Assert.AreEqual(0, FExecutedActionValue);
end;

procedure TTestTgoDataBinder.TestBindActionArgEnabled;
begin
  FBinder.BindAction(FAction, ExecuteActionArg, ReturnTrue);
  FAction.Execute;
  Assert.AreEqual(42, FExecutedActionValue);
end;

procedure TTestTgoDataBinder.TestBindActionDefault;
begin
  FBinder.BindAction(FAction, ExecuteAction);
  FAction.Execute;
  Assert.AreEqual(1, FExecutedActionValue);
end;

procedure TTestTgoDataBinder.TestBindActionDisabled;
begin
  FBinder.BindAction(FAction, ExecuteAction, ReturnFalse);
  FAction.Execute;
  Assert.AreEqual(0, FExecutedActionValue);
end;

procedure TTestTgoDataBinder.TestBindActionEnabled;
begin
  FBinder.BindAction(FAction, ExecuteAction, ReturnTrue);
  FAction.Execute;
  Assert.AreEqual(1, FExecutedActionValue);
end;

procedure TTestTgoDataBinder.TestBindCollection;
var
  Collection: TgoObservableCollection<TBar>;
  View: TBarCollectionView;
  Item: TBarCollectionViewItem;
  Bar: TBar;
  I: Integer;
  S: Single;
begin
  View := nil;
  Collection := TgoObservableCollection<TBar>.Create(True);
  try
    View := TBarCollectionView.Create;
    FBinder.BindCollection<TBar>(Collection, View, TBarTemplate);
    for I := 0 to 2 do
    begin
      Bar := TBar.Create;
      Bar.ReadWriteFloat := I * 1.1;
      Bar.ReadWriteString := 'Item ' + (I + 1).ToString;
      Collection.Add(Bar);
    end;

    Assert.AreEqual<Integer>(3, Length(View.Items));
    for I := 0 to 2 do
    begin
      Item := View.Items[I];
      Assert.AreEqual('Item ' + (I + 1).ToString, Item.Title);
      S := I * 1.1;
      Assert.AreEqual(FloatToStr(S, goUSFormatSettings), Item.Detail);
      Assert.AreEqual(I, Item.ImageIndex);
    end;
  finally
    View.Free;
    Collection.Free;
  end;
end;

procedure TTestTgoDataBinder.TestConverter;
begin
  FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadWriteFloat',
    TgoBindDirection.TwoWay, [], TMultiplyByTwoConverter);

  FFoo.ReadWriteInt := 42;
  Assert.AreEqual<Single>(84, FBar.ReadWriteFloat);

  FBar.ReadWriteFloat := 50.9;
  Assert.AreEqual(25, FFoo.ReadWriteInt);
end;

procedure TTestTgoDataBinder.TestDefault;
begin
  FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadWriteString');

  FFoo.ReadWriteInt := 42;
  Assert.AreEqual('42', FBar.ReadWriteString);

  FBar.ReadWriteString := '-3';
  Assert.AreEqual(-3, FFoo.ReadWriteInt);
end;

procedure TTestTgoDataBinder.TestDontApply;
begin
  FFoo.ReadWriteInt := 42;
  FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadWriteString',
    TgoBindDirection.TwoWay, [TgoBindFlag.DontApply]);
  Assert.AreEqual('', FBar.ReadWriteString);
end;

procedure TTestTgoDataBinder.TestMultipleSources;
var
  Foo2: TFoo;
begin
  Foo2 := TFoo.Create;
  try
    FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadWriteString');
    FBinder.Bind(Foo2, 'ReadWriteInt', FBar, 'ReadWriteString');

    { This will update FBar.ReadWriteString, which will in turn update
      Foo2.ReadWriteInt }
    FFoo.ReadWriteInt := 42;
    Assert.AreEqual('42', FBar.ReadWriteString);
    Assert.AreEqual(42, Foo2.ReadWriteInt);

    { This will update FBar.ReadWriteString, which will in turn update
      FFoo.ReadWriteInt }
    Foo2.ReadWriteInt := 3;
    Assert.AreEqual('3', FBar.ReadWriteString);
    Assert.AreEqual(3, FFoo.ReadWriteInt);
  finally
    Foo2.Free;
  end;
end;

procedure TTestTgoDataBinder.TestMultipleSourcesAndTargets;
var
  Foo2: TFoo;
  Bar2: TBar;
begin
  Bar2 := nil;
  Foo2 := TFoo.Create;
  try
    Bar2 := TBar.Create;
    FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadWriteString');
    FBinder.Bind(FFoo, 'ReadWriteInt', Bar2, 'ReadWriteFloat');

    FBinder.Bind(Foo2, 'ReadWriteInt', FBar, 'ReadWriteString');
    FBinder.Bind(Foo2, 'ReadWriteInt', Bar2, 'ReadWriteString');

    { This will update FBar.ReadWriteString and Bar2.ReadWriteFloat, which will
      in turn update Foo2.ReadWriteInt and Bar2.ReadWriteString }
    FFoo.ReadWriteInt := 42;
    Assert.AreEqual('42', FBar.ReadWriteString);
    Assert.AreEqual('42', Bar2.ReadWriteString);
    Assert.AreEqual<Single>(42, Bar2.ReadWriteFloat);
    Assert.AreEqual(42, Foo2.ReadWriteInt);

    Foo2.ReadWriteInt := 3;
    Assert.AreEqual('3', FBar.ReadWriteString);
    Assert.AreEqual('3', Bar2.ReadWriteString);
    Assert.AreEqual(3, FFoo.ReadWriteInt);
    Assert.AreEqual<Single>(3, Bar2.ReadWriteFloat);

    FBar.ReadWriteString := '55';
    Assert.AreEqual(55, FFoo.ReadWriteInt);
    Assert.AreEqual(55, Foo2.ReadWriteInt);
    Assert.AreEqual<Single>(55, Bar2.ReadWriteFloat);
    Assert.AreEqual('55', Bar2.ReadWriteString);

    Bar2.ReadWriteString := '66';
    Assert.AreEqual(66, FFoo.ReadWriteInt);
    Assert.AreEqual(66, Foo2.ReadWriteInt);
    Assert.AreEqual('66', FBar.ReadWriteString);

    Bar2.ReadWriteFloat := 8.5;
    Assert.AreEqual(8, FFoo.ReadWriteInt);
    Assert.AreEqual(8, Foo2.ReadWriteInt);
    Assert.AreEqual('8', FBar.ReadWriteString);
  finally
    Bar2.Free;
    Foo2.Free;
  end;
end;

procedure TTestTgoDataBinder.TestMultipleTargets;
var
  Bar2: TBar;
begin
  Bar2 := TBar.Create;
  try
    FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadWriteString');
    FBinder.Bind(FFoo, 'ReadWriteInt', Bar2, 'ReadWriteFloat');

    FFoo.ReadWriteInt := 42;
    Assert.AreEqual('42', FBar.ReadWriteString);
    Assert.AreEqual<Single>(42, Bar2.ReadWriteFloat);

    { This will update FFoo.ReadWriteInt, which will in turn update
      Bar2.ReadWriteFloat. }
    FBar.ReadWriteString := '-3';
    Assert.AreEqual(-3, FFoo.ReadWriteInt);
    Assert.AreEqual<Single>(-3, Bar2.ReadWriteFloat);

    { This will update FFoo.ReadWriteInt, which will in turn update
      FBar.ReadWriteString. }
    Bar2.ReadWriteFloat := 3.2;
    Assert.AreEqual(3, FFoo.ReadWriteInt);
    Assert.AreEqual('3', FBar.ReadWriteString);
  finally
    Bar2.Free;
  end;
end;

procedure TTestTgoDataBinder.TestOneWay;
begin
  FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadWriteString',
    TgoBindDirection.OneWay);

  FFoo.ReadWriteInt := 42;
  Assert.AreEqual('42', FBar.ReadWriteString);

  FBar.ReadWriteString := '-3';
  Assert.AreEqual(42, FFoo.ReadWriteInt);
end;

procedure TTestTgoDataBinder.TestPropertyNotConvertible;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'Foo');
    end, EgoBindError, 'Property TFoo.ReadWriteInt cannot be converted from type Integer to type TFoo');
end;

procedure TTestTgoDataBinder.TestPropertyUnsupportedType;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'Bytes', FBar, 'ReadWriteString');
    end, EgoBindError, 'Property TFoo.Bytes is of an unsupported data type: TArray<System.Byte>');
end;

procedure TTestTgoDataBinder.TestSourceDynamicPath;
begin
  FBinder.Bind(FLinks[0], 'IntValue', FFoos[0], 'ReadWriteInt');
  FBinder.Bind(FLinks[0], 'Next.IntValue', FFoos[1], 'ReadWriteInt');
  FBinder.Bind(FLinks[0], 'Next.Next.IntValue', FFoos[2], 'ReadWriteInt');
  FBinder.Bind(FLinks[0], 'Next.Next.Next.IntValue', FFoos[3], 'ReadWriteInt');

  FLinks[0].Next := FLinks[1];
  FLinks[1].Next := FLinks[2];

  Assert.AreEqual( 1, FFoos[0].ReadWriteInt);
  Assert.AreEqual( 2, FFoos[1].ReadWriteInt);
  Assert.AreEqual( 3, FFoos[2].ReadWriteInt);
  Assert.AreEqual(-4, FFoos[3].ReadWriteInt);

  FLinks[3].Next := FLinks[1];
  FLinks[0].Next := FLinks[3];

  { Current chain: Links[0] -> Links[3] -> Links[1] -> Links[2] -> nil }

  Assert.AreEqual(1, FFoos[0].ReadWriteInt);
  Assert.AreEqual(4, FFoos[1].ReadWriteInt);
  Assert.AreEqual(2, FFoos[2].ReadWriteInt);
  Assert.AreEqual(3, FFoos[3].ReadWriteInt);

  FFoos[0].ReadWriteInt := 41;
  FFoos[1].ReadWriteInt := 42;
  FFoos[2].ReadWriteInt := 43;
  FFoos[3].ReadWriteInt := 44;

  Assert.AreEqual(41, FLinks[0].IntValue);
  Assert.AreEqual(42, FLinks[3].IntValue);
  Assert.AreEqual(43, FLinks[1].IntValue);
  Assert.AreEqual(44, FLinks[2].IntValue);
end;

procedure TTestTgoDataBinder.TestSourceNotObservable;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FBaz, 'ReadWriteFloat', FBar, 'ReadWriteString');
    end, EgoBindError, 'Class TBaz must implement IgoNotifyPropertyChanged to support data binding');
end;

procedure TTestTgoDataBinder.TestSourcePropertyDoesNotExist;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'BadProperty', FBar, 'ReadWriteString');
    end, EgoBindError, 'Unable to retrieve information for property TFoo.BadProperty');
end;

procedure TTestTgoDataBinder.TestSourcePropertyNotReadable;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'WriteOnlyString', FBar, 'ReadWriteString', TgoBindDirection.OneWay);
    end, EgoBindError, 'Source property TFoo.WriteOnlyString must be readable');
end;

procedure TTestTgoDataBinder.TestSourcePropertyNotWritable;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'ReadOnlyFloat', FBar, 'ReadWriteString');
    end, EgoBindError, 'Source property TFoo.ReadOnlyFloat must be writable');
end;

procedure TTestTgoDataBinder.TestSourceStaticPath;
begin
  FLinks[0].Next := FLinks[1];
  FLinks[1].Next := FLinks[2];

  FBinder.Bind(FLinks[0], 'IntValue', FFoos[0], 'ReadWriteInt');
  FBinder.Bind(FLinks[0], 'Next.IntValue', FFoos[1], 'ReadWriteInt');
  FBinder.Bind(FLinks[0], 'Next.Next.IntValue', FFoos[2], 'ReadWriteInt');
  FBinder.Bind(FLinks[0], 'Next.Next.Next.IntValue', FFoos[3], 'ReadWriteInt');

  Assert.AreEqual( 1, FFoos[0].ReadWriteInt);
  Assert.AreEqual( 2, FFoos[1].ReadWriteInt);
  Assert.AreEqual( 3, FFoos[2].ReadWriteInt);
  Assert.AreEqual(-4, FFoos[3].ReadWriteInt);

  FLinks[0].IntValue := 41;
  FLinks[1].IntValue := 42;
  FLinks[2].IntValue := 43;

  Assert.AreEqual(41, FFoos[0].ReadWriteInt);
  Assert.AreEqual(42, FFoos[1].ReadWriteInt);
  Assert.AreEqual(43, FFoos[2].ReadWriteInt);

  FFoos[0].ReadWriteInt := 51;
  FFoos[1].ReadWriteInt := 52;
  FFoos[2].ReadWriteInt := 53;

  Assert.AreEqual(51, FLinks[0].IntValue);
  Assert.AreEqual(52, FLinks[1].IntValue);
  Assert.AreEqual(53, FLinks[2].IntValue);
end;

procedure TTestTgoDataBinder.TestTargetNotObservable;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'ReadWriteInt', FBaz, 'ReadWriteFloat');
    end, EgoBindError, 'Class TBaz must implement IgoNotifyPropertyChanged to support data binding');
end;

procedure TTestTgoDataBinder.TestTargetNotObservableOneWay;
begin
  FBinder.Bind(FFoo, 'ReadWriteInt', FBaz, 'ReadWriteFloat',
    TgoBindDirection.OneWay);

  FFoo.ReadWriteInt := 42;
  Assert.AreEqual<Single>(42, FBaz.ReadWriteFloat);
end;

procedure TTestTgoDataBinder.TestTargetPropertyDoesNotExist;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'BadProperty');
    end, EgoBindError, 'Unable to retrieve information for property TBar.BadProperty');
end;

procedure TTestTgoDataBinder.TestTargetPropertyNotReadable;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'WriteOnlyFloat');
    end, EgoBindError, 'Target property TBar.WriteOnlyFloat must be readable');
end;

procedure TTestTgoDataBinder.TestTargetPropertyNotWritable;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FBinder.Bind(FFoo, 'ReadWriteInt', FBar, 'ReadOnlyInt', TgoBindDirection.OneWay);
    end, EgoBindError, 'Target property TBar.ReadOnlyInt must be writable');
end;

procedure TTestTgoDataBinder.TestTargetStaticPath;
begin
  FLinks[0].Next := FLinks[1];
  FLinks[1].Next := FLinks[2];

  FBinder.Bind(FFoos[0], 'ReadWriteInt', FLinks[0], 'IntValue');
  FBinder.Bind(FFoos[1], 'ReadWriteInt', FLinks[0], 'Next.IntValue');
  FBinder.Bind(FFoos[2], 'ReadWriteInt', FLinks[0], 'Next.Next.IntValue');
  FBinder.Bind(FFoos[3], 'ReadWriteInt', FLinks[0], 'Next.Next.Next.IntValue');

  Assert.AreEqual(-1, FLinks[0].IntValue);
  Assert.AreEqual(-2, FLinks[1].IntValue);
  Assert.AreEqual(-3, FLinks[2].IntValue);
  Assert.AreEqual( 4, FLinks[3].IntValue);

  FFoos[0].ReadWriteInt := -41;
  FFoos[1].ReadWriteInt := -42;
  FFoos[2].ReadWriteInt := -43;

  Assert.AreEqual(-41, FLinks[0].IntValue);
  Assert.AreEqual(-42, FLinks[1].IntValue);
  Assert.AreEqual(-43, FLinks[2].IntValue);

  FLinks[0].IntValue := 41;
  FLinks[1].IntValue := 42;
  FLinks[2].IntValue := 43;

  Assert.AreEqual(41, FFoos[0].ReadWriteInt);
  Assert.AreEqual(42, FFoos[1].ReadWriteInt);
  Assert.AreEqual(43, FFoos[2].ReadWriteInt);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTgoDataBinder);

end.
