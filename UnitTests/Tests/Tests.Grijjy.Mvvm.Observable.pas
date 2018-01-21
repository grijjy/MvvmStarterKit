unit Tests.Grijjy.Mvvm.Observable;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  DUnitX.TestFramework,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.Observable;

type
  TObservableFoo = class(TgoObservable)
  private
    FIntValue: Integer;
    FStrValue: String;
    procedure SetIntValue(const Value: Integer);
    procedure SetStrValue(const Value: String);
  public
    property IntValue: Integer read FIntValue write SetIntValue;
    property StrValue: String read FStrValue write SetStrValue;
  end;

type
  TTestTgoObservable = class
  private
    FChangedProps: String;
  private
    procedure PropertyChangedListener(const ASender: TObject;
      const APropertyName: String);
    procedure AnotherPropertyChangedListener(const ASender: TObject;
      const APropertyName: String);
  public
    [Setup] procedure Setup;

    [Test] procedure TestPropertyChanged;
    [Test] procedure TestMultipleListeners;
  end;

type
  TTestTgoObservableCollection = class
  private
    FCUT: TgoObservableCollection<TObservableFoo>;
    FChangedProps: String;
    FChangedArgs: TgoCollectionChangedEventArgs;
  private
    procedure PropertyChangedListener(const ASender: TObject;
      const APropertyName: String);
    procedure CollectionChangedListener(const ASender: TObject;
      const AArgs: TgoCollectionChangedEventArgs);
    procedure Reset;
  public
    [Setup] procedure Setup;
    [Teardown] procedure Teardown;

    [Test] procedure TestAdd;
    [Test] procedure TestAddRangeArray;
    [Test] procedure TestAddRangeEnumerable;
    [Test] procedure TestInsert;
    [Test] procedure TestInsertRangeArray;
    [Test] procedure TestInsertRangeEnumerable;
    [Test] procedure TestDelete;
    [Test] procedure TestDeleteRange;
    [Test] procedure TestRemove;
    [Test] procedure TestClear;
    [Test] procedure TestItemChange;
    [Test] procedure TestReverse;
    [Test] procedure TestSort;
    [Test] procedure TestSortComparer;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections;

{ TObservableFoo }

procedure TObservableFoo.SetIntValue(const Value: Integer);
begin
  if (Value <> FIntValue) then
  begin
    FIntValue := Value;
    PropertyChanged('IntValue');
  end;
end;

procedure TObservableFoo.SetStrValue(const Value: String);
begin
  if (Value <> FStrValue) then
  begin
    FStrValue := Value;
    PropertyChanged('StrValue');
  end;
end;

{ TTestTgoObservable }

procedure TTestTgoObservable.AnotherPropertyChangedListener(
  const ASender: TObject; const APropertyName: String);
begin
  FChangedProps := FChangedProps + ',';
end;

procedure TTestTgoObservable.PropertyChangedListener(const ASender: TObject;
  const APropertyName: String);
begin
  FChangedProps := FChangedProps + APropertyName;
end;

procedure TTestTgoObservable.Setup;
begin
  FChangedProps := '';
end;

procedure TTestTgoObservable.TestMultipleListeners;
var
  Foo: TObservableFoo;
  NPC: IgoNotifyPropertyChanged;
  PCE: IgoPropertyChangedEvent;
begin
  Foo := TObservableFoo.Create;
  try
    Assert.IsTrue(Supports(Foo, IgoNotifyPropertyChanged, NPC));
    PCE := NPC.GetPropertyChangedEvent;
    Assert.IsNotNull(PCE);
    PCE.Add(PropertyChangedListener);
    PCE.Add(AnotherPropertyChangedListener);

    Assert.AreEqual('', FChangedProps);

    Foo.IntValue := 42;
    Assert.AreEqual('IntValue,', FChangedProps);

    Foo.StrValue := 'Bar';
    Assert.AreEqual('IntValue,StrValue,', FChangedProps);

    Foo.IntValue := 42;
    Assert.AreEqual('IntValue,StrValue,', FChangedProps);

    Foo.IntValue := 43;
    Assert.AreEqual('IntValue,StrValue,IntValue,', FChangedProps);

    NPC := nil;
    PCE := nil;
  finally
    Foo.Free;
  end;
end;

procedure TTestTgoObservable.TestPropertyChanged;
var
  Foo: TObservableFoo;
  NPC: IgoNotifyPropertyChanged;
  PCE: IgoPropertyChangedEvent;
begin
  Foo := TObservableFoo.Create;
  try
    Assert.IsTrue(Supports(Foo, IgoNotifyPropertyChanged, NPC));
    PCE := NPC.GetPropertyChangedEvent;
    Assert.IsNotNull(PCE);
    PCE.Add(PropertyChangedListener);

    Assert.AreEqual('', FChangedProps);

    Foo.IntValue := 42;
    Assert.AreEqual('IntValue', FChangedProps);

    Foo.StrValue := 'Bar';
    Assert.AreEqual('IntValueStrValue', FChangedProps);

    Foo.IntValue := 42;
    Assert.AreEqual('IntValueStrValue', FChangedProps);

    Foo.IntValue := 43;
    Assert.AreEqual('IntValueStrValueIntValue', FChangedProps);

    NPC := nil;
    PCE := nil;
  finally
    Foo.Free;
  end;
end;

{ TTestTgoObservableCollection }

procedure TTestTgoObservableCollection.CollectionChangedListener(
  const ASender: TObject; const AArgs: TgoCollectionChangedEventArgs);
begin
  FChangedArgs := AArgs;
end;

procedure TTestTgoObservableCollection.PropertyChangedListener(
  const ASender: TObject; const APropertyName: String);
begin
  FChangedProps := FChangedProps + APropertyName + ',';
end;

procedure TTestTgoObservableCollection.Reset;
begin
  FChangedArgs := TgoCollectionChangedEventArgs.Create(
    TgoCollectionChangedAction(-1), nil, -2, '?');
end;

procedure TTestTgoObservableCollection.SetUp;
var
  NPC: IgoNotifyPropertyChanged;
  PCE: IgoPropertyChangedEvent;
  NCC: IgoNotifyCollectionChanged;
  CCE: IgoCollectionChangedEvent;
begin
  inherited;
  FCUT := TgoObservableCollection<TObservableFoo>.Create(True);

  Assert.IsTrue(Supports(FCUT, IgoNotifyPropertyChanged, NPC));
  PCE := NPC.GetPropertyChangedEvent;
  Assert.IsNotNull(PCE);
  PCE.Add(PropertyChangedListener);

  Assert.IsTrue(Supports(FCUT, IgoNotifyCollectionChanged, NCC));
  CCE := NCC.GetCollectionChangedEvent;
  Assert.IsNotNull(CCE);
  CCE.Add(CollectionChangedListener);

  FChangedProps := '';
  Reset;
end;

procedure TTestTgoObservableCollection.TearDown;
begin
  inherited;
  FCUT.Free;
end;

procedure TTestTgoObservableCollection.TestAdd;
var
  Foo: TObservableFoo;
begin
  Foo := TObservableFoo.Create;
  FCUT.Add(Foo);
  Assert.AreEqual('Count,', FChangedProps);
  Assert.AreEqual(1, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Add, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = Foo);
  Assert.AreEqual(0, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
  Reset;

  Foo := TObservableFoo.Create;
  FCUT.Add(Foo);
  Assert.AreEqual('Count,Count,', FChangedProps);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Add, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = Foo);
  Assert.AreEqual(1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestAddRangeArray;
var
  I: Integer;
  Foos: array [0..2] of TObservableFoo;
begin
  for I := 0 to 2 do
    Foos[I] := TObservableFoo.Create;
  FCUT.AddRange(Foos);
  for I := 0 to 2 do
    Assert.IsTrue(FCUT[I] = Foos[I]);

  Assert.AreEqual('Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Add, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = Foos[2]);
  Assert.AreEqual(2, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestAddRangeEnumerable;
var
  I: Integer;
  Foos: TList<TObservableFoo>;
begin
  Foos := TList<TObservableFoo>.Create;
  try
    for I := 0 to 2 do
      Foos.Add(TObservableFoo.Create);
    FCUT.AddRange(Foos);

    for I := 0 to 2 do
      Assert.IsTrue(FCUT[I] = Foos[I]);

    Assert.AreEqual('Count,', FChangedProps);
    Assert.AreEqual(3, FCUT.Count);
    Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Add, FChangedArgs.Action);
    Assert.IsTrue(FChangedArgs.Item = Foos[2]);
    Assert.AreEqual(2, FChangedArgs.ItemIndex);
    Assert.AreEqual('', FChangedArgs.PropertyName);
  finally
    Foos.Free;
  end;
end;

procedure TTestTgoObservableCollection.TestClear;
var
  I: Integer;
  Foo: TObservableFoo;
begin
  for I := 0 to 2 do
  begin
    Foo := TObservableFoo.Create;
    FCUT.Add(Foo);
  end;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual('Count,Count,Count,Count,', FChangedProps);
  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Clear, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(-1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestDelete;
var
  I: Integer;
  Foo: TObservableFoo;
begin
  for I := 0 to 2 do
  begin
    Foo := TObservableFoo.Create;
    FCUT.Add(Foo);
  end;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Reset;

  FCUT.Delete(1);
  Assert.AreEqual('Count,Count,Count,Count,', FChangedProps);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Delete, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
  Reset;

  FCUT.Delete(0);
  Assert.AreEqual('Count,Count,Count,Count,Count,', FChangedProps);
  Assert.AreEqual(1, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Delete, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(0, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestDeleteRange;
var
  I: Integer;
  Foo: TObservableFoo;
begin
  for I := 0 to 2 do
  begin
    Foo := TObservableFoo.Create;
    FCUT.Add(Foo);
  end;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Reset;

  FCUT.DeleteRange(0, 2);
  Assert.AreEqual('Count,Count,Count,Count,', FChangedProps);
  Assert.AreEqual(1, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Delete, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestInsert;
var
  I: Integer;
  Foos: array [0..2] of TObservableFoo;
  Foo: TObservableFoo;
begin
  for I := 0 to 2 do
    Foos[I] := TObservableFoo.Create;
  FCUT.AddRange(Foos);
  Assert.AreEqual('Count,', FChangedProps);
  Foo := TObservableFoo.Create;
  FCUT.Insert(1, Foo);
  Assert.AreEqual('Count,Count,', FChangedProps);

  Assert.AreEqual(4, FCUT.Count);
  Assert.IsTrue(FCUT[0] = Foos[0]);
  Assert.IsTrue(FCUT[1] = Foo);
  Assert.IsTrue(FCUT[2] = Foos[1]);
  Assert.IsTrue(FCUT[3] = Foos[2]);

  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Add, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = Foo);
  Assert.AreEqual(1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestInsertRangeArray;
var
  I: Integer;
  Foos1, Foos2: array [0..2] of TObservableFoo;
begin
  for I := 0 to 2 do
  begin
    Foos1[I] := TObservableFoo.Create;
    Foos2[I] := TObservableFoo.Create;
  end;
  FCUT.AddRange(Foos1);
  Reset;
  Assert.AreEqual('Count,', FChangedProps);
  FCUT.InsertRange(2, Foos2);
  Assert.AreEqual('Count,Count,', FChangedProps);

  Assert.AreEqual(6, FCUT.Count);
  Assert.IsTrue(FCUT[0] = Foos1[0]);
  Assert.IsTrue(FCUT[1] = Foos1[1]);
  Assert.IsTrue(FCUT[2] = Foos2[0]);
  Assert.IsTrue(FCUT[3] = Foos2[1]);
  Assert.IsTrue(FCUT[4] = Foos2[2]);
  Assert.IsTrue(FCUT[5] = Foos1[2]);

  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Add, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = Foos2[2]);
  Assert.AreEqual(4, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestInsertRangeEnumerable;
var
  I: Integer;
  Foos1: array [0..2] of TObservableFoo;
  Foos2: TList<TObservableFoo>;
begin
  Foos2 := TList<TObservableFoo>.Create;
  try
    for I := 0 to 2 do
    begin
      Foos1[I] := TObservableFoo.Create;
      Foos2.Add(TObservableFoo.Create);
    end;
    FCUT.AddRange(Foos1);
    Reset;
    Assert.AreEqual('Count,', FChangedProps);
    FCUT.InsertRange(0, Foos2);
    Assert.AreEqual('Count,Count,', FChangedProps);

    Assert.AreEqual(6, FCUT.Count);
    Assert.IsTrue(FCUT[0] = Foos2[0]);
    Assert.IsTrue(FCUT[1] = Foos2[1]);
    Assert.IsTrue(FCUT[2] = Foos2[2]);
    Assert.IsTrue(FCUT[3] = Foos1[0]);
    Assert.IsTrue(FCUT[4] = Foos1[1]);
    Assert.IsTrue(FCUT[5] = Foos1[2]);

    Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Add, FChangedArgs.Action);
    Assert.IsTrue(FChangedArgs.Item = Foos2[2]);
    Assert.AreEqual(2, FChangedArgs.ItemIndex);
    Assert.AreEqual('', FChangedArgs.PropertyName);
  finally
    Foos2.Free;
  end;
end;

procedure TTestTgoObservableCollection.TestItemChange;
var
  Foo1, Foo2: TObservableFoo;
begin
  Foo1 := TObservableFoo.Create;
  FCUT.Add(Foo1);

  Foo2 := TObservableFoo.Create;
  FCUT.Add(Foo2);
  Assert.AreEqual('Count,Count,', FChangedProps);
  Assert.AreEqual(2, FCUT.Count);
  Reset;

  Foo1.IntValue := 42;
  Assert.AreEqual('Count,Count,', FChangedProps);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.ItemChange, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = Foo1);
  Assert.AreEqual(-1, FChangedArgs.ItemIndex);
  Assert.AreEqual('IntValue', FChangedArgs.PropertyName);
  Reset;

  Foo2.StrValue := 'Bar';
  Assert.AreEqual('Count,Count,', FChangedProps);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.ItemChange, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = Foo2);
  Assert.AreEqual(-1, FChangedArgs.ItemIndex);
  Assert.AreEqual('StrValue', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestReverse;
var
  I: Integer;
  Foo: TObservableFoo;
begin
  for I := 0 to 2 do
  begin
    Foo := TObservableFoo.Create;
    FCUT.Add(Foo);
  end;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Reset;

  FCUT.Reverse;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Rearrange, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(-1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestSort;
var
  I: Integer;
  Foo: TObservableFoo;
begin
  for I := 0 to 2 do
  begin
    Foo := TObservableFoo.Create;
    FCUT.Add(Foo);
  end;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Reset;

  FCUT.Sort;
  Assert.IsTrue(UIntPtr(FCUT[0]) < UIntPtr(FCUT[1]));
  Assert.IsTrue(UIntPtr(FCUT[1]) < UIntPtr(FCUT[2]));
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Rearrange, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(-1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestSortComparer;
var
  I: Integer;
  Foo: TObservableFoo;
begin
  for I := 0 to 2 do
  begin
    Foo := TObservableFoo.Create;
    Foo.IntValue := 2 - I;
    FCUT.Add(Foo);
  end;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Reset;

  FCUT.Sort(TComparer<TObservableFoo>.Construct(
    function (const ALeft, ARight: TObservableFoo): Integer
    begin
      Result := ALeft.IntValue - ARight.IntValue;
    end));

  Assert.IsTrue(FCUT[0].IntValue < FCUT[1].IntValue);
  Assert.IsTrue(FCUT[1].IntValue < FCUT[2].IntValue);
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Rearrange, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(-1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

procedure TTestTgoObservableCollection.TestRemove;
var
  I: Integer;
  Foo: TObservableFoo;
begin
  for I := 0 to 2 do
  begin
    Foo := TObservableFoo.Create;
    FCUT.Add(Foo);
  end;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Reset;

  Foo := TObservableFoo.Create;
  try
    FCUT.Remove(Foo);
  finally
    Foo.Free;
  end;
  Assert.AreEqual('Count,Count,Count,', FChangedProps);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction(-1), FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(-2, FChangedArgs.ItemIndex);
  Assert.AreEqual('?', FChangedArgs.PropertyName);
  Reset;

  Foo := FCUT[1];
  FCUT.Remove(Foo);
  Assert.AreEqual('Count,Count,Count,Count,', FChangedProps);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual<TgoCollectionChangedAction>(TgoCollectionChangedAction.Delete, FChangedArgs.Action);
  Assert.IsTrue(FChangedArgs.Item = nil);
  Assert.AreEqual(1, FChangedArgs.ItemIndex);
  Assert.AreEqual('', FChangedArgs.PropertyName);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTgoObservable);
  TDUnitX.RegisterTestFixture(TTestTgoObservableCollection);

end.
