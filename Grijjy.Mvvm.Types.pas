unit Grijjy.Mvvm.Types;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  System.TypInfo,
  System.Rtti,
  System.Generics.Collections,
  Grijjy.Mvvm.Rtti;

type
  { A generic "regular" Delphi event type, that represents a single event in
    a multi-cast event (see TgoMultiCastEvent<T>).

    Parameters:
      ASender: the sender of the event.
      AArg: an argument to the event, of the generic type. }
  TgoEvent<T> = procedure(const ASender: TObject; const AArg: T) of object;

type
  { A generic multi-cast event. You can subscribe and unsubscribe individual
    events using the Add and Remove methods. Call Invoke to fire the event to
    all subscribers.

    Is implemented in the TgoMultiCastEvent<T> class. }
  IgoMultiCastEvent<T> = interface
  ['{270015DD-C9C0-4EF7-9EB0-C875D4E071B6}']
    { Subscribes a regular event.

      Parameters:
        AEvent: the event to subscribe. }
    procedure Add(const AEvent: TgoEvent<T>);

    { Unsubscribes a regular event.

      Parameters:
        AEvent: the event to unsubscribe. }
    procedure Remove(const AEvent: TgoEvent<T>);

    { Removes all events for a particilar subscriber.

      Parameters:
        ASubscriber: the subscriber }
    procedure RemoveAll(const ASubscriber: TObject);

    { Fires the event. This will fire each regular event that has been
      subscribed to using the Add method.

      Parameters:
        ASender: the sender of the event.
        AArg: an argument to the event, of the generic type. }
    procedure Invoke(const ASender: TObject; const AArg: T);
  end;

type
  { Type of multi-cast event that is fired when the value of a bindable property
    has changed.

    The type parameter (string) is the name of the property that has changed.

    Is implemented in the TgoPropertyChangedEvent class. }
  IgoPropertyChangedEvent = IgoMultiCastEvent<String>;

type
  { Type of multi-cast event that is fired when the value of a bindable property
    is changing (for example, for every character entered into a TEdit
    control).

    The type parameter (string) is the name of the property that is changing.

    Is implemented in the TgoPropertyChangeTrackingEvent class. }
  IgoPropertyChangeTrackingEvent = IgoMultiCastEvent<String>;

type
  { Controls (or other objects) that can be the source of a data binding
    must implement this interface. }
  IgoNotifyPropertyChanged = interface
  ['{42337B8A-4508-4079-A732-DC0ED29B59B0}']
    { Gets the multi-cast event that must be fired when a bindable property has
      changed.

      Returns:
        The event. Callers can subscribe to or unsubscribe from this event.

      The implementor must invoke this event for each changed property that is
      the source of a data binding. }
    function GetPropertyChangedEvent: IgoPropertyChangedEvent;
  end;

type
  { Controls (or other objects) that can be the source of a data binding
    can additionally implement this interface if they support change
    tracking. For example, TEdit supports change tracking for every character
    that is entered into its edit box. }
  IgoNotifyPropertyChangeTracking = interface
  ['{4823C491-D8E4-4824-A650-16E9D479DDD2}']
    { Gets the multi-cast event that must be fired when a bindable property is
      changing.

      Returns:
        The event. Callers can subscribe to or unsubscribe from this event.

      The implementor must invoke this event for each trackable property that is
      changing and is the source of a data binding. }
    function GetPropertyChangeTrackingEvent: IgoPropertyChangeTrackingEvent;
  end;

type
  { Describes the action that caused an IgoCollectionChangedEvent. }
  TgoCollectionChangedAction = (
    { An item was added or inserted into the collection.
      The following properties of the associated TgoCollectionChangedEventArgs
      are valid: Item, ItemIndex. }
    Add,

    { An item was removed from the collection.
      The following properties of the associated TgoCollectionChangedEventArgs
      are valid: ItemIndex. }
    Delete,

    { The property of an item in the collection was modified.
      This action is only fired if the items in the collection implement the
      IgoPropertyChangedEvent interface.
      The following properties of the associated TgoCollectionChangedEventArgs
      are valid: Item, PropertyName. }
    ItemChange,

    { The collection was cleared.
      None of the properties of the associated TgoCollectionChangedEventArgs
      are valid. }
    Clear,

    { The items in the collection were rearranged (for example, sorted).
      None of the properties of the associated TgoCollectionChangedEventArgs
      are valid. }
    Rearrange);

type
  { The arguments passed to an IgoCollectionChangedEvent. }
  TgoCollectionChangedEventArgs = record
  {$REGION 'Internal Declarations'}
  private
    FAction: TgoCollectionChangedAction;
    FItem: TObject;
    FItemIndex: Integer;
    FPropertyName: String;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AAction: TgoCollectionChangedAction;
      const AItem: TObject; const AItemIndex: Integer;
      const APropertyName: String);

    { The action that caused the event. The availability of the other properties
      depends on this action. }
    property Action: TgoCollectionChangedAction read FAction;

    { The item in the collection to which the action applies.
      Is only valid for the Add and ItemChange actions.
      Will be nil for all other actions. }
    property Item: TObject read FItem;

    { The index of the item in the collection to which the action applies.
      Is only valid for the Add and Delete actions.
      Will be -1 for all other actions. }
    property ItemIndex: Integer read FItemIndex;

    { The name of the property of Item whose value has changed.
      Is only valid for the ItemChange action.
      Will be an empty string for all other actions. }
    property PropertyName: String read FPropertyName;
  end;

type
  { Type of multi-cast event that is fired when a change happened to a
    collection that implements the IgoNotifyCollectionChanged interface.

    The type parameter (TgoCollectionChangedEventArgs) contains the details
    of the change.

    Is implemented in the TgoCollectionChangedEvent class. }
  IgoCollectionChangedEvent = IgoMultiCastEvent<TgoCollectionChangedEventArgs>;

type
  { Collection classes can implement this interface to notify when changes
    to the collection occur. The TgoObservableCollection<T> class provides a
    reusable implementation of this interface. }
  IgoNotifyCollectionChanged = interface
  ['{A0BED600-AF8B-478B-8B38-0C2DED5B5D29}']
    { Gets the multi-cast event that must be fired when a collection or an
      item in a collection has changed.

      Returns:
        The event. Callers can subscribe to or unsubscribe from this event.

      To support notifications of changes to individual items, the items in the
      collection implement the IgoPropertyChangedEvent interface.

      The implementor must invoke this event when the collection or an item
      in the collection has changed. }
    function GetCollectionChangedEvent: IgoCollectionChangedEvent;
  end;

type
  { Type of multi-cast event that is fired when on object that implements the
    TgoNotifyFree interfaces is freed.

    The type parameter is the object that is about to be freed.

    Is implemented in the TgoFreeEvent class. }
  IgoFreeEvent = IgoMultiCastEvent<TObject>;

type
  { Implement this interface that let other objects know when you are freed.
    Objects that are used as sources or targets in a data binding must either
    implement this interface or derive from TComponent. }
  IgoNotifyFree = interface
  ['{CA0B0B93-7A7A-45F4-9B1B-9CD40CB67DB3}']
    { Gets the multi-cast event that must be fired when the object is freed.

      Returns:
        The event. Callers can subscribe to or unsubscribe from this event.

      The implementor must invoke this event when the object is about to be
      freed. }
    function GetFreeEvent: IgoFreeEvent;
  end;

type
  { Abstract (static) class for converting a source TgoValue to a target
    TgoValue and vice versa. The converter can change both the type of the
    value and/or the value itself. Is used with TgoDataBinder.Bind. }
  TgoValueConverter = class abstract
  public
    { Converts a property value from a data binding source to a property value
      of for the data binding target.

      This method gets called for OneWay data bindings from a source to a
      target.

      Parameters:
        ASource: the property value of the data binding source.

      Returns:
        ASource converted for the target binding. }
    class function ConvertSourceToTarget(const ASource: TgoValue): TgoValue; virtual; abstract;

    { Converts a property value from a data binding target to a property value
      for the data binding source.

      This method gets called for TwoWay data bindings when the data flows in
      the opposite direction (from target to source).

      Parameters:
        ATarget: the property value of the data binding target.

      Returns:
        ATarget converted for the source binding.

      This method is optional. It returns ATarget by default. }
    class function ConvertTargetToSource(const ATarget: TgoValue): TgoValue; virtual;
  end;
  TgoValueConverterClass = class of TgoValueConverter;

type
  { Objects of this (or a derived) type can be the source of a collection.
    The source doesn't have to be declared using the TObject type parameter:
    you can use the actual type of objects in the collection. For example, a
    TList<TPerson> is a valid collection source (as long as TPerson is a
    class).

    When you need to get notified when the collection changes, use a collection
    that implements the IgoNotifyCollectionChanged interface, such as
    TgoObservableCollection<T>.

    (In technical terms: TList<TPerson> is covariant, meaning that it is
    convertible to TList<TObject>. However, Delphi does not support covariance
    (and contravariance) with generics, so you need to typecast to
    TgoCollectionSource yourself.) }
  TgoCollectionSource = TEnumerable<TObject>;

type
  { Abstract base template class that defines the mapping between properties of
    each item in a collection and the corresponding item in the view.
    For example, if the collection contains objects of type TCustomer, than you
    can create a mapping between the customer name and the item title in the
    view (by overriding the GetTitle method).
    If the view is a TListBox for example, then the item title will
    be assigned to the TListBoxItem.Text property.

    You can pass the template to the TgoDataBinder.BindCollection method. }
  TgoDataTemplate = class abstract
  public
    { Must be overridden to return the title of a given object.
      This title will be used to fill the Text property of items in a TListBox
      or TListView.

      Parameters:
        AItem: the object whose title to get. You need to typecast it to the
          type of the objects in the collection (as passed to
          TgoDataBinder.BindCollection).

      Returns:
        The title for this object. Should not be an empty string. }
    class function GetTitle(const AItem: TObject): String; virtual; abstract;

    { Returns some details of a given object.
      These details will be used to fill the Details property of items in a
      TListBox or TListView.

      Parameters:
        AItem: the object whose details to get. You need to typecast it to the
          type of the objects in the collection (as passed to
          TgoDataBinder.BindCollection).

      Returns:
        The details for this object.

      Returns an empty string by default. }
    class function GetDetail(const AItem: TObject): String; virtual;

    { Returns the index of an image that represents a given object.
      This index will be used to fill the ImageIndex property of items in a
      TListBox or TListView.

      Parameters:
        AItem: the object whose image index to get. You need to typecast it to
          the type of the objects in the collection (as passed to
          TgoDataBinder.BindCollection).

      Returns:
        The image index for this object, or -1 if there is no image associated
        with the object.

      Returns -1 by default. }
    class function GetImageIndex(const AItem: TObject): Integer; virtual;
    class function GetStyle(const AItem: TObject): string; virtual;
  end;
  TgoDataTemplateClass = class of TgoDataTemplate;

type
  { A view of items in a collection. Is uses by controls that present a
    collection of items, such as TListBox and TListView. These controls will
    implement the IgoCollectionViewProvider interface, that provides an object
    that implements this interface.

    Implementors should use the abstract TgoCollectionView class in the
    Grijjy.Mvvm.DataBinding.Collections unit as a base for their views. }
  IgoCollectionView = interface
  ['{4E22CB1D-931F-4F51-955C-077A5719C927}']
    {$REGION 'Internal Declarations'}
    function GetSource: TgoCollectionSource;
    procedure SetSource(const AValue: TgoCollectionSource);
    function GetTemplate: TgoDataTemplateClass;
    procedure SetTemplate(const AValue: TgoDataTemplateClass);
    {$ENDREGION 'Internal Declarations'}

    { The collection to show in the view. This can be any class derived from
      TEnumerable<T>, as long is T is a class type. You must typecast it to
      TgoCollectionSource to set the property.

      When you need to get notified when the collection changes, use a
      collection that implements the IgoNotifyCollectionChanged interface, such
      as TgoObservableCollection<T>.

      (In technical terms: TList<TPerson> is covariant, meaning that it is
      convertible to TList<TObject> if TPerson is a class. However, Delphi
      does not support covariance (and contravariance) with generics, so you
      need to typecast to TgoCollectionSource yourself.) }
    property Source: TgoCollectionSource read GetSource write SetSource;

    { The class that is used as a template to map items in the collection to
      properties of items in the view. }
    property Template: TgoDataTemplateClass read GetTemplate write SetTemplate;
  end;

type
  { Is implemented by controls (such as TListBox and TListView) that provide
    a collection view. }
  IgoCollectionViewProvider = interface
  ['{22F1E2A9-0078-4401-BA80-C8EFFEE091EA}']
    function GetCollectionView: IgoCollectionView;
  end;

type
  { Implements IgoMultiCastEvent<T> }
  TgoMultiCastEvent<T> = class(TInterfacedObject, IgoMultiCastEvent<T>)
  {$REGION 'Internal Declarations'}
  private
    FEvents: TArray<TgoEvent<T>>;
  private
    function IndexOf(const AEvent: TgoEvent<T>): Integer;
    procedure Delete(const AIndex: Integer);
  protected
    { IgoMultiCastEvent<T> }
    procedure Add(const AEvent: TgoEvent<T>);
    procedure Remove(const AEvent: TgoEvent<T>);
    procedure RemoveAll(const ASubscriber: TObject);
    procedure Invoke(const ASender: TObject; const AArg: T);
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { Implements IgoPropertyChangedEvent }
  TgoPropertyChangedEvent = TgoMultiCastEvent<String>;

  { Implements IgoPropertyChangeTrackingEvent }
  TgoPropertyChangeTrackingEvent = TgoMultiCastEvent<String>;

  { Implements IgoCollectionChangedEvent }
  TgoCollectionChangedEvent = TgoMultiCastEvent<TgoCollectionChangedEventArgs>;

  { Implements IgoFreeEvent }
  TgoFreeEvent = TgoMultiCastEvent<TObject>;

type
  { The type of method to invoke when an IgoBindableAction is executed. }
  TgoExecuteMethod = procedure of Object;
  TgoExecuteMethod<T> = procedure(const AArg: T) of Object;

  { The type of method to invoke to check whether an IgoBindableAction can be
    executed. The Enabled property of the action will be set to the result of
    this function. }
  TgoCanExecuteMethod = function: Boolean of object;

type
  { An action that can be bound to Execute and CanExecute method (usually
    defined in a View Model). The VCL/FMX TAction class implements this
    interface. }
  IgoBindableAction = interface
  ['{F6750B64-0DA6-42C9-A334-994271882B38}']
    { Binds the action to Execute and CanExecute methods.

      Parameters:
        AExecute: the method to invoke when the action is executed.
        ACanExecute: (optional) method to invoke to check whether the action
          can be executed. The Enabled property of the action will be set to the
          result of this function. }
    procedure Bind(const AExecute: TgoExecuteMethod;
      const ACanExecute: TgoCanExecuteMethod = nil); overload;

    { Binds the action to Execute and CanExecute methods.

      Parameters:
        AExecute: the method to invoke when the action is executed. A single
          argument of type Integer is passed to this method.
        ACanExecute: (optional) method to invoke to check whether the action
          can be executed. The Enabled property of the action will be set to the
          result of this function.

      The value of the argument passed to AExecute depends on the implementor of
      this interface. The TAction class will pass its Tag value as argument. }
    procedure Bind(const AExecute: TgoExecuteMethod<Integer>;
      const ACanExecute: TgoCanExecuteMethod = nil); overload;
  end;

type
  { Base interface for the generic IgoView<TVM> version }
  IgoView = interface
  ['{5EF31C67-EB85-48EB-A390-8097DB0EFED2}']
    { Executes the view }
    procedure Execute;

    { Executes the view in a modal way.

      Parameters:
        AResultProc: an anonymous method that will be called when the view
          closes. The parameter to this method is a TModalResult that indicates
          how the view was closed.

      NOTE: In the implementation, it is NOT sufficient to just call the
      ShowModal method of the (FMX) form. When the user closes the from (on
      desktop platforms) by pressing the X button, then ShowModal will NOT
      call AResultProc. You MUST make sure AResultProc is always called, no
      matter how the form closes. An easy solution is to override the OnClose
      method of the form and check the value of the ModalResult property. If it
      is mrNone, then set it to mrCancel, which will result in a call to
      AResultProc. TgoFormView already takes care of this. }
    procedure ExecuteModal(const AResultProc: TProc<TModalResult>);
  end;

type
  { All views in the application should implement this interface. You probably
    want to implement this interface in some base form and have all forms
    descend from that. You can use TgoFormView<TVM> as a base form. That view
    implements this interface and also provides a default data binder to use.

    You should register each view using TgoViewFactory.Register so that view
    model can create view without a dependency to the actual view.

    The type parameter TVM is the type of the view model used by the view. }
  IgoView<TVM: class> = interface(IgoView)
  ['{64D3D02E-9054-45F2-8544-04A1026F3CD8}']
    { Initializes the view and associates it with a view model.

      Parameters:
        AViewModel: the view model to associate with the view.
          The view model MUST remain alive for the duration of the view.
        AOwnsViewModel: whether the view becomes owner of the view model. If
          True, then the class that implements this interface must free the view
          model in its destructor.

      You usually set up the data bindings in this method. }
    procedure InitView(const AViewModel: TVM; const AOwnsViewModel: Boolean);
  end;

type
  { Helper class for loading bitmaps in a platform-independent and
    framework-independent way. In VCL applications, it will use
    Vcl.Graphics.TBitmap. In FireMonkey applications, it will use
    Fmx.Graphics.TBitmap. }
  TgoBitmap = class // static
  {$REGION 'Internal Declarations'}
  private
    class function DefaultLoadBitmapFunc(const AStream: TStream): TObject; static;
  {$ENDREGION 'Internal Declarations'}
  public class var
    { Used internally. Contains the actual (framework-dependent) routine that
      is used to load a bitmap. Is set in the unit Grijjy.FMX.Mvvm.Controls or
      Grijjy.VCL.Mvvm.Controls. }
    _LoadBitmapFunc: function(const AStream: TStream): TObject;
  public
    { Loads a bitmap from a file, stream or memory.
      The parameters depend on the overloaded version that is used.

      Parameters:
        AFilename: name of the file containing the bitmap.
        AStream: stream containing the bitmap.
        AData: a TBytes containing the raw bitmap data.
        AMemory: pointer to memory containing the raw bitmap data.
        ASize: size of the data pointed to by AMemory.

      Returns:
        The loaded bitmap. When used in a VCL application, the returned object
        is of type Vcl.Graphics.TBitmap. When used in a FireMonkey application,
        the returned object is of type Fmx.Graphics.TBitmap.

      Raises:
        An exception when the bitmap cannot be loaded; for example because the
        file does not exist or it is in an invalid/unsupported format.

      This method supports at least the BMP, JPEG and PNG formats. Other formats
      may be supported depending on framework and platform. }
    class function Load(const AFilename: String): TObject; overload; static;
    class function Load(const AStream: TStream): TObject; overload; static;
    class function Load(const AData: TBytes): TObject; overload; static;
    class function Load(const AMemory: Pointer; const ASize: Integer): TObject; overload; static;
  end;

implementation

uses
  Grijjy.Collections;

{ TgoMultiCastEvent<T> }

procedure TgoMultiCastEvent<T>.Add(const AEvent: TgoEvent<T>);
var
  Index: Integer;
begin
  if (IndexOf(AEvent) < 0) then
  begin
    Index := Length(FEvents);
    SetLength(FEvents, Index + 1);
    FEvents[Index] := AEvent;
  end;
end;

procedure TgoMultiCastEvent<T>.Delete(const AIndex: Integer);
var
  Count: Integer;
begin
  Count := Length(FEvents) - 1;
  if (AIndex <> Count) then
  begin
    TgoArray<TgoEvent<T>>.Move(FEvents, AIndex + 1, AIndex, Count - AIndex);
    TgoArray<TgoEvent<T>>.Finalize(FEvents, Count);
  end;
  SetLength(FEvents, Count);
end;

function TgoMultiCastEvent<T>.IndexOf(const AEvent: TgoEvent<T>): Integer;
var
  I: Integer;
  Src: TMethod;
  Dst: TMethod absolute AEvent;
begin
  for I := 0 to Length(FEvents) - 1 do
  begin
    Src := TMethod(FEvents[I]);
    if (Src = Dst) then
      Exit(I);
  end;
  Result := -1;
end;

procedure TgoMultiCastEvent<T>.Invoke(const ASender: TObject; const AArg: T);
var
  I: Integer;
begin
  for I := 0 to Length(FEvents) - 1 do
    FEvents[I](ASender, AArg);
end;

procedure TgoMultiCastEvent<T>.Remove(const AEvent: TgoEvent<T>);
var
  Index: Integer;
begin
  Index := IndexOf(AEvent);
  if (Index >= 0) then
    Delete(Index);
end;

procedure TgoMultiCastEvent<T>.RemoveAll(const ASubscriber: TObject);
var
  I: Integer;
  Src: TMethod;
begin
  for I := Length(FEvents) - 1 downto 0 do
  begin
    Src := TMethod(FEvents[I]);
    if (Src.Data = ASubscriber) then
      Delete(I);
  end;
end;

{ TgoCollectionChangedEventArgs }

constructor TgoCollectionChangedEventArgs.Create(
  const AAction: TgoCollectionChangedAction; const AItem: TObject;
  const AItemIndex: Integer; const APropertyName: String);
begin
  FAction := AAction;
  FItem := AItem;
  FItemIndex := AItemIndex;
  FPropertyName := APropertyName;
end;

{ TgoDataTemplate }

class function TgoDataTemplate.GetDetail(const AItem: TObject): String;
begin
  Result := '';
end;

class function TgoDataTemplate.GetImageIndex(const AItem: TObject): Integer;
begin
  Result := -1;
end;

class function TgoDataTemplate.GetStyle(const AItem: TObject): string;
begin
  Result := '';
end;

{ TgoValueConverter }

class function TgoValueConverter.ConvertTargetToSource(
  const ATarget: TgoValue): TgoValue;
begin
  Result := ATarget;
end;

{ TgoBitmap }

class function TgoBitmap.DefaultLoadBitmapFunc(const AStream: TStream): TObject;
begin
  Assert(False, 'Framework-dependent bitmap loading function not set');
  Result := nil;
end;

class function TgoBitmap.Load(const AFilename: String): TObject;
var
  Stream: TFileStream;
begin
  Assert(Assigned(_LoadBitmapFunc));
  Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    Result := _LoadBitmapFunc(Stream);
  finally
    Stream.Free;
  end;
end;

class function TgoBitmap.Load(const AStream: TStream): TObject;
begin
  Assert(Assigned(_LoadBitmapFunc));
  Result := _LoadBitmapFunc(AStream);
end;

class function TgoBitmap.Load(const AData: TBytes): TObject;
var
  Stream: TBytesStream;
begin
  Assert(Assigned(_LoadBitmapFunc));
  Stream := TBytesStream.Create(AData);
  try
    Result := _LoadBitmapFunc(Stream);
  finally
    Stream.Free;
  end;
end;

class function TgoBitmap.Load(const AMemory: Pointer;
  const ASize: Integer): TObject;
var
  Stream: TMemoryStream;
begin
  Assert(Assigned(_LoadBitmapFunc));
  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(AMemory^, ASize);
    Stream.Position := 0;
    Result := _LoadBitmapFunc(Stream);
  finally
    Stream.Free;
  end;
end;

initialization
  TgoBitmap._LoadBitmapFunc := TgoBitmap.DefaultLoadBitmapFunc;

end.
