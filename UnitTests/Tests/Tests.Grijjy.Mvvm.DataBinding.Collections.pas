unit Tests.Grijjy.Mvvm.DataBinding.Collections;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections,
  DUnitX.TestFramework,
  Grijjy.SysUtils,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.Observable,
  Grijjy.Mvvm.DataBinding.Collections;

type
  TFoo = class(TgoObservable)
  strict private
    FStrValue: String;
    FFloatValue: Single;
    FIntValue: Integer;
    procedure SetFloatValue(const Value: Single);
    procedure SetIntValue(const Value: Integer);
    procedure SetStrValue(const Value: String);
  public
    property StrValue: String read FStrValue write SetStrValue;
    property FloatValue: Single read FFloatValue write SetFloatValue;
    property IntValue: Integer read FIntValue write SetIntValue;
  end;

type
  TCollectionViewItem = record
  public
    Item: TObject;
    Title: String;
    Detail: String;
    ImageIndex: Integer;
  end;

type
  TCollectionView = class(TgoCollectionView, IgoCollectionViewProvider)
  private
    FItems: TList<TCollectionViewItem>;
    FWorkItems: TList<TCollectionViewItem>;
    FUpdateLock: Integer;
  private
    class function FindItem(const AItems: TList<TCollectionViewItem>;
      const ASource: TObject): Integer; static;
  private
    procedure UpdateItem(var AItem: TCollectionViewItem; const ASource: TObject);
  protected
    { IgoCollectionViewProvider }
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
    constructor Create;
    destructor Destroy; override;

    property Items: TList<TCollectionViewItem> read FItems;
  end;

type
  TTemplate = class(TgoDataTemplate)
  public
    class function GetTitle(const AItem: TObject): String; override;
    class function GetDetail(const AItem: TObject): String; override;
    class function GetImageIndex(const AItem: TObject): Integer; override;
  end;

type
  TTestTgoCollectionView = class
  private
    FCUT: TCollectionView;
    FCollection: TgoObservableCollection<TFoo>;
  private
    class function CreateFoo(const ASeed: Integer): TFoo; static;
  private
    procedure CheckEquals(const ASeed: Integer; const AItem: TCollectionViewItem);
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestSource;
    [Test] procedure TestClearItemsInView;
    [Test] procedure TestClearItemsInViewInUpdate;
    [Test] procedure TestAddItemToView;
    [Test] procedure TestDeleteItemFromView;
    [Test] procedure TestUpdateItemInView;
    [Test] procedure TestUpdateAllItemsInView;
  end;

implementation

{ TFoo }

procedure TFoo.SetFloatValue(const Value: Single);
begin
  if (Value <> FFloatValue) then
  begin
    FFloatValue := Value;
    PropertyChanged('FloatValue');
  end;
end;

procedure TFoo.SetIntValue(const Value: Integer);
begin
  if (Value <> FIntValue) then
  begin
    FIntValue := Value;
    PropertyChanged('IntValue');
  end;
end;

procedure TFoo.SetStrValue(const Value: String);
begin
  if (Value <> FStrValue) then
  begin
    FStrValue := Value;
    PropertyChanged('StrValue');
  end;
end;

{ TCollectionView }

procedure TCollectionView.AddItemToView(const AItem: TObject);
var
  Item: TCollectionViewItem;
begin
  UpdateItem(Item, AItem);
  if (FUpdateLock = 0) then
    FItems.Add(Item)
  else
    FWorkItems.Add(Item);
end;

procedure TCollectionView.BeginUpdateView;
begin
  if (FUpdateLock = 0) then
  begin
    FWorkItems.Clear;
    FWorkItems.AddRange(FItems);
  end;
  Inc(FUpdateLock);
end;

procedure TCollectionView.ClearItemsInView;
begin
  if (FUpdateLock = 0) then
    FItems.Clear
  else
    FWorkItems.Clear;
end;

constructor TCollectionView.Create;
begin
  inherited;
  FItems := TList<TCollectionViewItem>.Create;
  FWorkItems := TList<TCollectionViewItem>.Create;
end;

procedure TCollectionView.DeleteItemFromView(const AItemIndex: Integer);
begin
  if (FUpdateLock = 0) then
    FItems.Delete(AItemIndex)
  else
    FWorkItems.Delete(AItemIndex);
end;

destructor TCollectionView.Destroy;
begin
  FWorkItems.Free;
  FItems.Free;
  inherited;
end;

procedure TCollectionView.EndUpdateView;
begin
  Assert.IsTrue(FUpdateLock > 0);
  Dec(FUpdateLock);
  if (FUpdateLock = 0) then
  begin
    FItems.Clear;
    FItems.AddRange(FWorkItems);
    FWorkItems.Clear;
  end;
end;

class function TCollectionView.FindItem(const AItems: TList<TCollectionViewItem>;
  const ASource: TObject): Integer;
var
  I: Integer;
begin
  for I := 0 to AItems.Count - 1 do
  begin
    if (AItems[I].Item = ASource) then
      Exit(I);
  end;
  Exit(-1);
end;

function TCollectionView.GetCollectionView: IgoCollectionView;
begin
  Result := Self;
end;

procedure TCollectionView.UpdateAllItemsInView;
var
  Index: Integer;
  Items: TList<TCollectionViewItem>;
  SrcItem: TObject;
  Item: TCollectionViewItem;
begin
  if (FUpdateLock = 0) then
    Items := FItems
  else
    Items := FWorkItems;

  Index := 0;
  for SrcItem in Source do
  begin
    UpdateItem(Item, SrcItem);
    Items[Index] := Item;
    Inc(Index);
  end;
end;

procedure TCollectionView.UpdateItem(var AItem: TCollectionViewItem;
  const ASource: TObject);
begin
  AItem.Item := ASource;
  AItem.Title := Template.GetTitle(ASource);
  AItem.Detail := Template.GetDetail(ASource);
  AItem.ImageIndex := Template.GetImageIndex(ASource);
end;

procedure TCollectionView.UpdateItemInView(const AItem: TObject;
  const APropertyName: String);
var
  Index: Integer;
  Items: TList<TCollectionViewItem>;
  Item: TCollectionViewItem;
begin
  if (FUpdateLock = 0) then
    Items := FItems
  else
    Items := FWorkItems;

  Index := FindItem(Items, AItem);
  if (Index >= 0) then
  begin
    Item := Items[Index];
    UpdateItem(Item, AItem);
    Items[Index] := Item;
  end;
end;

{ TTemplate }

class function TTemplate.GetDetail(const AItem: TObject): String;
begin
  Assert.IsTrue(AItem is TFoo);
  Result := Format('%.2f', [TFoo(AItem).FloatValue], goUSFormatSettings);
end;

class function TTemplate.GetImageIndex(const AItem: TObject): Integer;
begin
  Assert.IsTrue(AItem is TFoo);
  Result := TFoo(AItem).IntValue;
end;

class function TTemplate.GetTitle(const AItem: TObject): String;
begin
  Assert.IsTrue(AItem is TFoo);
  Result := TFoo(AItem).StrValue;
end;

{ TTestTgoCollectionView }

procedure TTestTgoCollectionView.CheckEquals(const ASeed: Integer;
  const AItem: TCollectionViewItem);
begin
  Assert.AreEqual('Item ' + (ASeed + 1).ToString, AItem.Title);
  Assert.AreEqual(Format('%.2f', [ASeed * 1.1], goUSFormatSettings), AItem.Detail);
  Assert.AreEqual(ASeed * 2, AItem.ImageIndex);
end;

class function TTestTgoCollectionView.CreateFoo(const ASeed: Integer): TFoo;
begin
  Result := TFoo.Create;
  Result.StrValue := 'Item ' + (ASeed + 1).ToString;
  Result.FloatValue := ASeed * 1.1;
  Result.IntValue := ASeed * 2;
end;

procedure TTestTgoCollectionView.Setup;
var
  I: Integer;
begin
  inherited;
  ReportMemoryLeaksOnShutdown := True;
  FCollection := TgoObservableCollection<TFoo>.Create(True);
  for I := 0 to 3 do
    FCollection.Add(CreateFoo(I));

  FCUT := TCollectionView.Create;
  FCUT.SetSource(TgoCollectionSource(FCollection));
  FCUT.SetTemplate(TTemplate);
end;

procedure TTestTgoCollectionView.Teardown;
begin
  FCUT.Free;
  FCollection.Free;
end;

procedure TTestTgoCollectionView.TestAddItemToView;
var
  I: Integer;
begin
  Assert.AreEqual(4, FCUT.Items.Count);
  FCollection.Add(CreateFoo(4));
  Assert.AreEqual(5, FCUT.Items.Count);

  FCUT.BeginUpdateView;
  FCollection.Add(CreateFoo(5));
  Assert.AreEqual(5, FCUT.Items.Count);
  FCUT.EndUpdateView;
  Assert.AreEqual(6, FCUT.Items.Count);

  for I := 0 to 5 do
    CheckEquals(I, FCUT.Items[I]);
end;

procedure TTestTgoCollectionView.TestClearItemsInView;
begin
  Assert.AreEqual(4, FCUT.Items.Count);
  FCUT.ClearItemsInView;
  Assert.AreEqual(0, FCUT.Items.Count);
end;

procedure TTestTgoCollectionView.TestClearItemsInViewInUpdate;
begin
  Assert.AreEqual(4, FCUT.Items.Count);

  FCUT.BeginUpdateView;
  FCUT.ClearItemsInView;
  Assert.AreEqual(4, FCUT.Items.Count);
  FCUT.EndUpdateView;

  Assert.AreEqual(0, FCUT.Items.Count);
end;

procedure TTestTgoCollectionView.TestDeleteItemFromView;
begin
  Assert.AreEqual(4, FCUT.Items.Count); // 0123
  FCollection.Delete(1); // 023
  Assert.AreEqual(3, FCUT.Items.Count);

  FCUT.BeginUpdateView;
  FCollection.Delete(2); // 02
  Assert.AreEqual(3, FCUT.Items.Count);
  FCUT.EndUpdateView;
  Assert.AreEqual(2, FCUT.Items.Count);

  CheckEquals(0, FCUT.Items[0]);
  CheckEquals(2, FCUT.Items[1]);
end;

procedure TTestTgoCollectionView.TestSource;
var
  I: Integer;
begin
  Assert.AreEqual(4, FCUT.Items.Count);
  for I := 0 to 3 do
    CheckEquals(I, FCUT.Items[I]);
end;

procedure TTestTgoCollectionView.TestUpdateAllItemsInView;
var
  I: Integer;
begin
  for I := 0 to 3 do
    CheckEquals(I, FCUT.Items[I]);

  FCollection.Sort(TComparer<TFoo>.Construct(
    function (const ALeft, ARight: TFoo): Integer
    begin
      Result := ARight.IntValue - ALeft.IntValue;
    end));

  for I := 0 to 3 do
    CheckEquals(3 - I, FCUT.Items[I]);

  FCUT.BeginUpdateView;
  FCollection.Sort(TComparer<TFoo>.Construct(
    function (const ALeft, ARight: TFoo): Integer
    begin
      Result := ALeft.IntValue - ARight.IntValue;
    end));

  for I := 0 to 3 do
    CheckEquals(3 - I, FCUT.Items[I]);

  FCUT.EndUpdateView;

  for I := 0 to 3 do
    CheckEquals(I, FCUT.Items[I]);
end;

procedure TTestTgoCollectionView.TestUpdateItemInView;
var
  Foo: TFoo;
  Item: TCollectionViewItem;
begin
  Foo := FCollection[1];
  Foo.StrValue := 'New Value';
  Foo.FloatValue := Pi;
  Foo.IntValue := 42;

  Item := FCUT.Items[1];
  Assert.AreEqual('New Value', Item.Title);
  Assert.AreEqual('3.14', Item.Detail);
  Assert.AreEqual(42, Item.ImageIndex);

  FCUT.BeginUpdateView;
  Foo := FCollection[2];
  Foo.StrValue := 'Another New Value';
  Foo.FloatValue := 4.2;
  Foo.IntValue := -99;

  Item := FCUT.Items[2];
  Assert.AreEqual('Item 3', Item.Title);
  Assert.AreEqual('2.20', Item.Detail);
  Assert.AreEqual(4, Item.ImageIndex);
  FCUT.EndUpdateView;

  Item := FCUT.Items[2];
  Assert.AreEqual('Another New Value', Item.Title);
  Assert.AreEqual('4.20', Item.Detail);
  Assert.AreEqual(-99, Item.ImageIndex);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTgoCollectionView);

end.
