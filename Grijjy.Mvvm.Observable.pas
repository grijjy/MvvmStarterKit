unit Grijjy.Mvvm.Observable;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.Types,
  System.Generics.Defaults,
  System.Generics.Collections,
  Grijjy.System,
  Grijjy.Mvvm.Types;

type
  { Abstract base class for classes with observable properties.
    That is, other classes can observe classes derived from TgoObservable for
    changes in its properties.
    Classes derived from this type can be sources (and targets) for data
    binding.

    To be the source of a data binding, the class must call PropertyChanged
    whenever a property that is the source of a data binding has changed. Care
    must be taken to only call this method when the property value has actually
    changed (using the normal "if (Value <> SomeProp) then" pattern), and
    AFTER the value has changed.

    This class also implements IgoNotifyFree so it sends a free notification
    when it is about to be destroyed.

    NOTE: This class implements interfaces but is not reference counted. }
  TgoObservable = class abstract(TgoNonRefCountedObject, IgoNotifyPropertyChanged, IgoNotifyFree)
  {$REGION 'Internal Declarations'}
  private
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FOnFree: IgoFreeEvent;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  protected
    { IgoNotifyFree }
    function GetFreeEvent: IgoFreeEvent;
  {$ENDREGION 'Internal Declarations'}
  protected
    { A derived class should call this method every time a property that is
      the source of a data binding has changed.

      Parameters:
        APropertyName: the name of the property that has changed. This name
          is case sensitive and must exactly match the name of the property.

      Care must be taken to only call this method when the property value has
      actually changed (using the normal "if (Value <> SomeProp) then"
      pattern), and AFTER the value has changed. }
    procedure PropertyChanged(const APropertyName: String);
  public
    { The destructor also sends a free notification to its subscribers. }
    destructor Destroy; override;
  end;

type
  { A dynamic data collection that provides notifications (through
    IgoNotifyCollectionChanged) when the collection or items in the collection
    change.

    To support notifications of changes to individual items, the type parameter
    T must implement the IgoPropertyChangedEvent interface.

    The collection itself supports property changed notifications for: Count }
  TgoObservableCollection<T: class> = class(TEnumerable<T>,
    IgoNotifyPropertyChanged, IgoNotifyCollectionChanged)
  {$REGION 'Internal Declarations'}
  private
    FList: TObjectList<T>;
    FOnPropertyChanged: IgoPropertyChangedEvent;
    FOnCollectionChanged: IgoCollectionChangedEvent;
    function GetCapacity: Integer; inline;
    function GetCount: Integer; inline;
    function GetItem(const AIndex: Integer): T; inline;
    procedure SetItem(const AIndex: Integer; const Value: T); inline;
  private
    procedure DoItemPropertyChanged(const ASender: TObject;
      const APropertyName: String);
    procedure DoPropertyChanged(const APropertyName: String);
    procedure DoCollectionChanged(const AAction: TgoCollectionChangedAction;
      const AItem: TObject = nil; const AItemIndex: Integer = -1;
      const APropertyName: String = '');
  protected
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  protected
    { IgoNotifyPropertyChanged }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  protected
    { IgoNotifyCollectionChanged }
    function GetCollectionChangedEvent: IgoCollectionChangedEvent;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AOwnsObjects: Boolean = False);
    destructor Destroy; override;
  public
    { TEnumerable<T> }

    { Copies the elements in the collection to a dynamic array }
    function ToArray: TArray<T>; override; final;

    { Allow <tt>for..in</tt> enumeration of the collection. }
    function DoGetEnumerator: TEnumerator<T>; override;
  public
    { Checks whether the collection contains a given item.
      This method performs a O(n) linear search and uses the collection's
      comparer to check for equality. For a faster check, use BinarySearch.

      Parameters:
        AItem: The item to check.

      Returns:
        True if the collection contains AValue. }
    function Contains(const AItem: T): Boolean; inline;

    { Returns the index of a given item or -1 if not found.
      This method performs a O(n) linear search and uses the collection's
      comparer to check for equality. For a faster check, use BinarySearch.

      Parameters:
        AItem: The item to find. }
    function IndexOf(const AItem: T): Integer; inline;

    { Returns the last index of a given item or -1 if not found.
      This method performs a O(n) backwards linear search and uses the
      collection's comparer to check for equality. For a faster check, use
      BinarySearch.

      Parameters:
        AItem: The item to find. }
    function LastIndexOf(const AItem: T): Integer; inline;

    { Returns the index of a given item or -1 if not found.
      This method performs a O(n) linear search and uses the collection's
      comparer to check for equality. For a faster check, use BinarySearch.

      Parameters:
        AItem: The item to find.
        ADirection: Whether to search forwards or backwards. }
    function IndexOfItem(const AItem: T; const ADirection: TDirection): Integer; inline;

    { Performs a binary search for a given item. This requires that the
      collection is sorted. This is an O(log n) operation that uses the default
      comparer to check for equality.

      Parameters:
        AItem: The item to find.
        AIndex: is set to the index of AItem if found. If not found, it is set
          to the index of the first entry larger than AItem.

      Returns:
        Whether the collection contains the item. }
    function BinarySearch(const AItem: T; out AIndex: Integer): Boolean; overload; inline;

    { Performs a binary search for a given item. This requires that the
      collection is sorted. This is an O(log n) operation that uses the given
      comparer to check for equality.

      Parameters:
        AItem: The item to find.
        AIndex: is set to the index of AItem if found. If not found, it is set
          to the index of the first entry larger than AItem.
        AComparer: the comparer to use to check for equality.

      Returns:
        Whether the collection contains the item. }
    function BinarySearch(const AItem: T; out AIndex: Integer;
      const AComparer: IComparer<T>): Boolean; overload; inline;

    { Returns the first item in the collection. }
    function First: T; inline;

    { Returns the last item in the collection. }
    function Last: T; inline;

    { Clears the collection }
    procedure Clear;

    { Adds an item to the end of the collection.

      Parameters:
        AItem: the item to add.

      Returns:
        The index of the added item. }
    function Add(const AItem: T): Integer;

    { Adds a range of items to the end of the collection.

      Parameters:
        AItems: an array of items to add. }
    procedure AddRange(const AItems: array of T); overload;

    { Adds the items of another collection to the end of the collection.

      Parameters:
        ACollection: the collection containing the items to add. Can be any
          class that descends from TEnumerable<T>. }
    procedure AddRange(const ACollection: TEnumerable<T>); overload;

    { Inserts an item into the collection.

      Parameters:
        AIndex: the index in the collection to insert the item. The item will be
          inserted before AIndex. Set to 0 to insert at the beginning to the
          collection. Set to Count to add to the end of the collection.
        AItem: the item to insert. }
    procedure Insert(const AIndex: Integer; const AItem: T);

    { Inserts a range of items into the collection.

      Parameters:
        AIndex: the index in the collection to insert the items. The items will
          be inserted before AIndex. Set to 0 to insert at the beginning to the
          collection. Set to Count to add to the end of the collection.
        AItems: the items to insert. }
    procedure InsertRange(const AIndex: Integer; const AItems: array of T); overload;

    { Inserts the items from another collection into the collection.

      Parameters:
        AIndex: the index in the collection to insert the items. The items will
          be inserted before AIndex. Set to 0 to insert at the beginning to the
          collection. Set to Count to add to the end of the collection.
        ACollection: the collection containing the items to insert. Can be any
          class that descends from TEnumerable<T>. }
    procedure InsertRange(const AIndex: Integer; const ACollection: TEnumerable<T>); overload;

    { Deletes an item from the collection.

      Parameters:
        AIndex: the index of the item to delete }
    procedure Delete(const AIndex: Integer);

    { Deletes a range of items from the collection.

      Parameters:
        AIndex: the index of the first item to delete
        ACount: the number of items to delete }
    procedure DeleteRange(const AIndex, ACount: Integer);

    { Removes an item from the collection.

      Parameters:
        AItem: the item to remove. It this collection does not contain this
          item, nothing happens.

      Returns:
        The index of the removed item, or -1 of the collection does not contain
        AItem.

      If the collection contains multiple items with the same value, only the
      first item is removed. }
    function Remove(const AItem: T): Integer;

    { Reverses the order of the elements in the collection. }
    procedure Reverse;

    { Sort the collection using the default comparer for the element type }
    procedure Sort; overload;

    { Sort the collection using a custom comparer.

      Parameters:
        AComparer: the comparer to use to sort the collection. }
    procedure Sort(const AComparer: IComparer<T>); overload;

    { Trims excess memory used by the collection. To improve performance and
      reduce memory reallocations, the collection usually contains space for
      more items than are actually stored in this collection. That is,
      Capacity >= Count. Call this method free that excess memory. You can do
      this when you are done filling the collection to free memory. }
    procedure TrimExcess; inline;

    { The number of items in the collection }
    property Count: Integer read GetCount;

    { The items in the collection }
    property Items[const AIndex: Integer]: T read GetItem write SetItem; default;

    { The number of reserved items in the collection. Is >= Count to improve
      performance by reducing memory reallocations. }
    property Capacity: Integer read GetCapacity;
  end;

implementation

uses
  System.SysUtils;

{ TgoObservable }

destructor TgoObservable.Destroy;
begin
  if Assigned(FOnFree) then
    FOnFree.Invoke(Self, Self);
  inherited;
end;

function TgoObservable.GetFreeEvent: IgoFreeEvent;
begin
  if (FOnFree = nil) then
    FOnFree := TgoFreeEvent.Create;

  Result := FOnFree;
end;

function TgoObservable.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

procedure TgoObservable.PropertyChanged(const APropertyName: String);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, APropertyName);
end;

{ TgoObservableCollection<T> }

function TgoObservableCollection<T>.Add(const AItem: T): Integer;
var
  NPC: IgoNotifyPropertyChanged;
begin
  Result := FList.Add(AItem);
  if Supports(AItem, IgoNotifyPropertyChanged, NPC) then
    NPC.GetPropertyChangedEvent.Add(DoItemPropertyChanged);
  DoCollectionChanged(TgoCollectionChangedAction.Add, AItem, Result);
  DoPropertyChanged('Count');
end;

procedure TgoObservableCollection<T>.AddRange(const AItems: array of T);
var
  I, Index: Integer;
  Item: T;
  NPC: IgoNotifyPropertyChanged;
begin
  Index := FList.Count;
  FList.AddRange(AItems);

  for I := 0 to Length(AItems) - 1 do
  begin
    Item := AItems[I];
    if Supports(Item, IgoNotifyPropertyChanged, NPC) then
      NPC.GetPropertyChangedEvent.Add(DoItemPropertyChanged);

    DoCollectionChanged(TgoCollectionChangedAction.Add, Item, Index);
    Inc(Index);
  end;

  if (Length(AItems) > 0) then
    DoPropertyChanged('Count');
end;

procedure TgoObservableCollection<T>.AddRange(
  const ACollection: TEnumerable<T>);
var
  Index: Integer;
  Item: T;
  NPC: IgoNotifyPropertyChanged;
begin
  Index := FList.Count;
  FList.AddRange(ACollection);

  for Item in ACollection do
  begin
    if Supports(Item, IgoNotifyPropertyChanged, NPC) then
      NPC.GetPropertyChangedEvent.Add(DoItemPropertyChanged);

    DoCollectionChanged(TgoCollectionChangedAction.Add, Item, Index);
    Inc(Index);
  end;

  if Assigned(ACollection) then
    DoPropertyChanged('Count');
end;

function TgoObservableCollection<T>.BinarySearch(const AItem: T;
  out AIndex: Integer; const AComparer: IComparer<T>): Boolean;
begin
  Result := FList.BinarySearch(AItem, AIndex, AComparer);
end;

function TgoObservableCollection<T>.BinarySearch(const AItem: T;
  out AIndex: Integer): Boolean;
begin
  Result := FList.BinarySearch(AItem, AIndex);
end;

procedure TgoObservableCollection<T>.Clear;
var
  I: Integer;
  Item: T;
  NPC: IgoNotifyPropertyChanged;
begin
  if (FList.Count > 0) then
  begin
    for I := 0 to FList.Count - 1 do
    begin
      Item := FList[I];
      if Supports(Item, IgoNotifyPropertyChanged, NPC) then
      begin
        NPC.GetPropertyChangedEvent.Remove(DoItemPropertyChanged);
        NPC := nil;
      end;
    end;
    FList.Clear;
    DoCollectionChanged(TgoCollectionChangedAction.Clear);
    DoPropertyChanged('Count');
  end;
end;

function TgoObservableCollection<T>.Contains(const AItem: T): Boolean;
begin
  Result := FList.Contains(AItem)
end;

constructor TgoObservableCollection<T>.Create(const AOwnsObjects: Boolean);
begin
  inherited Create;
  FList := TObjectList<T>.Create;
  FList.OwnsObjects := AOwnsObjects;
end;

procedure TgoObservableCollection<T>.Delete(const AIndex: Integer);
var
  Item: T;
  NPC: IgoNotifyPropertyChanged;
begin
  Item := FList[AIndex];
  if Supports(Item, IgoNotifyPropertyChanged, NPC) then
  begin
    NPC.GetPropertyChangedEvent.Remove(DoItemPropertyChanged);

    { Set NPC to nil BEFORE removing item from list. The list owns the item, so
      deleting it frees the item, and NPC would be invalid and an Access
      Violation would happen when NPC would be cleaned up as it goes out of
      scope. }
    NPC := nil;
  end;

  FList.Delete(AIndex);
  DoCollectionChanged(TgoCollectionChangedAction.Delete, nil, AIndex);
  DoPropertyChanged('Count');
end;

procedure TgoObservableCollection<T>.DeleteRange(const AIndex, ACount: Integer);
var
  I: Integer;
  Item: T;
  NPC: IgoNotifyPropertyChanged;
begin
  for I := AIndex to AIndex + ACount - 1 do
  begin
    Item := FList[I];
    if Supports(Item, IgoNotifyPropertyChanged, NPC) then
    begin
      NPC.GetPropertyChangedEvent.Remove(DoItemPropertyChanged);
      NPC := nil;
    end;
  end;

  FList.DeleteRange(AIndex, ACount);
  for I := AIndex to AIndex + ACount - 1 do
    DoCollectionChanged(TgoCollectionChangedAction.Delete, nil, I);

  if (ACount > 0) then
    DoPropertyChanged('Count');
end;

destructor TgoObservableCollection<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TgoObservableCollection<T>.DoCollectionChanged(
  const AAction: TgoCollectionChangedAction; const AItem: TObject;
  const AItemIndex: Integer; const APropertyName: String);
var
  Args: TgoCollectionChangedEventArgs;
begin
  if Assigned(FOnCollectionChanged) then
  begin
    Args := TgoCollectionChangedEventArgs.Create(AAction, AItem, AItemIndex, APropertyName);
    FOnCollectionChanged.Invoke(Self, Args);
  end;
end;

function TgoObservableCollection<T>.DoGetEnumerator: TEnumerator<T>;
begin
  Result := FList.GetEnumerator;
end;

procedure TgoObservableCollection<T>.DoItemPropertyChanged(
  const ASender: TObject; const APropertyName: String);
begin
  DoCollectionChanged(TgoCollectionChangedAction.ItemChange, ASender, -1,
    APropertyName);
end;

procedure TgoObservableCollection<T>.DoPropertyChanged(
  const APropertyName: String);
begin
  if Assigned(FOnPropertyChanged) then
    FOnPropertyChanged.Invoke(Self, APropertyName);
end;

function TgoObservableCollection<T>.First: T;
begin
  Result := FList.First;
end;

function TgoObservableCollection<T>.GetCapacity: Integer;
begin
  Result := FList.Capacity;
end;

function TgoObservableCollection<T>.GetCollectionChangedEvent: IgoCollectionChangedEvent;
begin
  if (FOnCollectionChanged = nil) then
    FOnCollectionChanged := TgoCollectionChangedEvent.Create;

  Result := FOnCollectionChanged;
end;

function TgoObservableCollection<T>.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TgoObservableCollection<T>.GetItem(const AIndex: Integer): T;
begin
  Result := FList[AIndex];
end;

function TgoObservableCollection<T>.GetPropertyChangedEvent: IgoPropertyChangedEvent;
begin
  if (FOnPropertyChanged = nil) then
    FOnPropertyChanged := TgoPropertyChangedEvent.Create;

  Result := FOnPropertyChanged;
end;

function TgoObservableCollection<T>.IndexOf(const AItem: T): Integer;
begin
  Result := FList.IndexOf(AItem);
end;

function TgoObservableCollection<T>.IndexOfItem(const AItem: T;
  const ADirection: TDirection): Integer;
begin
  Result := FList.IndexOfItem(AItem, ADirection);
end;

procedure TgoObservableCollection<T>.Insert(const AIndex: Integer;
  const AItem: T);
var
  NPC: IgoNotifyPropertyChanged;
begin
  FList.Insert(AIndex, AItem);
  if Supports(AItem, IgoNotifyPropertyChanged, NPC) then
    NPC.GetPropertyChangedEvent.Add(DoItemPropertyChanged);
  DoCollectionChanged(TgoCollectionChangedAction.Add, AItem, AIndex);
  DoPropertyChanged('Count');
end;

procedure TgoObservableCollection<T>.InsertRange(const AIndex: Integer;
  const AItems: array of T);
var
  I, Index: Integer;
  Item: T;
  NPC: IgoNotifyPropertyChanged;
begin
  Index := AIndex;
  FList.InsertRange(AIndex, AItems);

  for I := 0 to Length(AItems) - 1 do
  begin
    Item := AItems[I];
    if Supports(Item, IgoNotifyPropertyChanged, NPC) then
      NPC.GetPropertyChangedEvent.Add(DoItemPropertyChanged);

    DoCollectionChanged(TgoCollectionChangedAction.Add, Item, Index);
    Inc(Index);
  end;

  if (Length(AItems) > 0) then
    DoPropertyChanged('Count');
end;

procedure TgoObservableCollection<T>.InsertRange(const AIndex: Integer;
  const ACollection: TEnumerable<T>);
var
  Index: Integer;
  Item: T;
  NPC: IgoNotifyPropertyChanged;
begin
  Index := AIndex;
  FList.InsertRange(AIndex, ACollection);

  for Item in ACollection do
  begin
    if Supports(Item, IgoNotifyPropertyChanged, NPC) then
      NPC.GetPropertyChangedEvent.Add(DoItemPropertyChanged);

    DoCollectionChanged(TgoCollectionChangedAction.Add, Item, Index);
    Inc(Index);
  end;

  if Assigned(ACollection) then
    DoPropertyChanged('Count');
end;

function TgoObservableCollection<T>.Last: T;
begin
  Result := FList.Last;
end;

function TgoObservableCollection<T>.LastIndexOf(const AItem: T): Integer;
begin
  Result := FList.LastIndexOf(AItem);
end;

function TgoObservableCollection<T>.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TgoObservableCollection<T>.Remove(const AItem: T): Integer;
var
  NPC: IgoNotifyPropertyChanged;
begin
  if Supports(AItem, IgoNotifyPropertyChanged, NPC) then
  begin
    NPC.GetPropertyChangedEvent.Remove(DoItemPropertyChanged);
    NPC := nil;
  end;

  Result := FList.Remove(AItem);

  if (Result >= 0) then
  begin
    DoCollectionChanged(TgoCollectionChangedAction.Delete, nil, Result);
    DoPropertyChanged('Count');
  end;
end;

procedure TgoObservableCollection<T>.Reverse;
begin
  FList.Reverse;
  DoCollectionChanged(TgoCollectionChangedAction.Rearrange);
end;

procedure TgoObservableCollection<T>.SetItem(const AIndex: Integer;
  const Value: T);
begin
  FList[AIndex] := Value;
end;

procedure TgoObservableCollection<T>.Sort;
begin
  FList.Sort;
  DoCollectionChanged(TgoCollectionChangedAction.Rearrange);
end;

procedure TgoObservableCollection<T>.Sort(const AComparer: IComparer<T>);
begin
  FList.Sort(AComparer);
  DoCollectionChanged(TgoCollectionChangedAction.Rearrange);
end;

function TgoObservableCollection<T>.ToArray: TArray<T>;
begin
  Result := FList.ToArray;
end;

procedure TgoObservableCollection<T>.TrimExcess;
begin
  FList.TrimExcess;
end;

function TgoObservableCollection<T>._AddRef: Integer;
begin
  Result := -1;
end;

function TgoObservableCollection<T>._Release: Integer;
begin
  Result := -1;
end;

end.
