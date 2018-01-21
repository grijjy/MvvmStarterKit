unit Grijjy.Mvvm.DataBinding.Collections;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  Grijjy.System,
  Grijjy.Mvvm.Types;

type
  { Abstract base class for views that implement the IgoCollectionView
    interface.

    NOTE: This class implements an interface but is not reference counted. }
  TgoCollectionView = class abstract(TgoNonRefCountedObject, IgoCollectionView)
  {$REGION 'Internal Declarations'}
  private
    FSource: TgoCollectionSource; // Reference
    FTemplate: TgoDataTemplateClass;
  private
    procedure AddItemsToView;
    procedure UpdateItemsInView;
  private
    procedure CollectionChanged(const ASender: TObject;
      const AArg: TgoCollectionChangedEventArgs);
  protected
    { IgoCollectionView }
    function GetSource: TgoCollectionSource;
    procedure SetSource(const AValue: TgoCollectionSource);
    function GetTemplate: TgoDataTemplateClass;
    procedure SetTemplate(const AValue: TgoDataTemplateClass);
  {$ENDREGION 'Internal Declarations'}
  protected
    { Must be overridden to clear all items in the view.
      For example, when used with a TListBox, it would call the TListBox.Clear
      method. }
    procedure ClearItemsInView; virtual; abstract;

    { Must be overridden to inform the view that a batch of updates will follow.
      For example, when used with a TListBox, it would call the
      TListBox.BeginUpdate method. }
    procedure BeginUpdateView; virtual; abstract;

    { Must be overridden to inform the view that a batch of updates has ended.
      For example, when used with a TListBox, it would call the
      TListBox.EndUpdate method. }
    procedure EndUpdateView; virtual; abstract;

    { Must be overridden to add an item to the view.

      Parameters:
        AItem: the item to add to the view. The type of the item is the same as
          the type of the objects in the Source collection.

      For example, when used with a TListBox, it would create a TListBoxItem
      object, associate it with AItem, and add it to the list box. }
    procedure AddItemToView(const AItem: TObject); virtual; abstract;

    { Must be overridden to delete an item from the view.

      Parameters:
        AItemIndex: the index of the item to delete.

      For example, when used with a TListBox, it would delete item AItemIndex
      from the list box. }
    procedure DeleteItemFromView(const AItemIndex: Integer); virtual; abstract;

    { Must be overridden to update an item in the view.

      Parameters:
        AItem: the item that has changed. The type of the item is the same as
          the type of the objects in the Source collection.
        APropertyName: the name of the property of AItem that has changed.

      For example, when used with a TListBox, it would find the TListBoxItem
      associated with AItem and change one of its properties. }
    procedure UpdateItemInView(const AItem: TObject;
      const APropertyName: String); virtual; abstract;

    { Must be overridden to update all items in the view with new data.
      This method is called when the order of the items in the source collection
      has changed (for example, by sorting).

      The number of items is unchanged, so the view doesn't have to add or
      delete items. For example, when used with a TListBox, the list box would
      update all existing TListBoxItem objects with the properties from the
      corresponding items in the source collection. It also needs to
      re-associate each TListBoxItem with the corresponding item in the
      collection. }
    procedure UpdateAllItemsInView; virtual; abstract;
  public
    { The collection to show in the view. This can be any class derived from
      TEnumerable<T>, as long is T is a class type. You must typecast it to
      TgoCollectionSource to set the property.

      (In technical terms: TList<TPerson> is convariant, meaning that it is
      convertible to TList<TObject> if TPerson is a class. However, Delphi
      does not support covariance (and contravariance) with generics, so you
      need to typecast to TgoCollectionSource yourself.) }
    property Source: TgoCollectionSource read FSource write SetSource;

    { The class that is used as a template to map items in the collection to
      properties of items in the view. }
    property Template: TgoDataTemplateClass read FTemplate write FTemplate;
  end;

implementation

uses
  System.SysUtils;

{ TgoCollectionView }

procedure TgoCollectionView.AddItemsToView;
var
  Item: TObject;
begin
  if (FSource = nil) then
    Exit;

  BeginUpdateView;
  try
    for Item in Source do
      AddItemToView(Item);
  finally
    EndUpdateView;
  end;
end;

procedure TgoCollectionView.CollectionChanged(const ASender: TObject;
  const AArg: TgoCollectionChangedEventArgs);
begin
  if (FTemplate = nil) then
    Exit;

  case AArg.Action of
    TgoCollectionChangedAction.Add:
      AddItemToView(AArg.Item);

    TgoCollectionChangedAction.Delete:
      DeleteItemFromView(AArg.ItemIndex);

    TgoCollectionChangedAction.ItemChange:
      UpdateItemInView(AArg.Item, AArg.PropertyName);

    TgoCollectionChangedAction.Clear:
      ClearItemsInView;

    TgoCollectionChangedAction.Rearrange:
      begin
        BeginUpdateView;
        try
          UpdateAllItemsInView;
        finally
          EndUpdateView;
        end;
      end;
  end;
end;

function TgoCollectionView.GetSource: TgoCollectionSource;
begin
  Result := FSource;
end;

function TgoCollectionView.GetTemplate: TgoDataTemplateClass;
begin
  Result := FTemplate;
end;

procedure TgoCollectionView.SetSource(const AValue: TgoCollectionSource);
var
  NCC: IgoNotifyCollectionChanged;
begin
  if (AValue <> FSource) then
  begin
    { Unsubscribe from collection changed event of old source. }
    if Assigned(FSource) and (Supports(FSource, IgoNotifyCollectionChanged, NCC)) then
      NCC.GetCollectionChangedEvent.Remove(CollectionChanged);

    FSource := AValue;
    if Assigned(FTemplate) then
    begin
      ClearItemsInView;
      AddItemsToView;
    end;

    { Subscribe to collection changed event of new source. }
    if Assigned(FSource) and (Supports(FSource, IgoNotifyCollectionChanged, NCC)) then
      NCC.GetCollectionChangedEvent.Add(CollectionChanged);
  end;
end;

procedure TgoCollectionView.SetTemplate(const AValue: TgoDataTemplateClass);
var
  PrevTemplate: TgoDataTemplateClass;
begin
  if (AValue <> FTemplate) then
  begin
    PrevTemplate := FTemplate;
    FTemplate := AValue;
    if Assigned(FTemplate) and Assigned(FSource) then
    begin
      if Assigned(PrevTemplate) then
        UpdateItemsInView
      else
      begin
        ClearItemsInView;
        AddItemsToView;
      end;
    end;
  end;
end;

procedure TgoCollectionView.UpdateItemsInView;
begin
  Assert(False);
end;

end.
