unit Grijjy.Mvvm.DataBinding;

{$INCLUDE 'Grijjy.inc'}

{ Light-weight data binding framework.

  Any object can be the target of a data binding, as long as that object has
  public properties to bind to. This includes visual controls.

  Some objects (including visual controls) can also be the source of a data
  binding. To support this, the object must implement the
  IgoNotifyPropertyChanged and/or IgoNotifyPropertyChangeTracking interface.
  For each property that can be the source of a data binding, that object must
  fire an OnPropertyChanged and/or OnPropertyChangeTracking event when that
  property is changed (or changing). Those events are supplied by the two
  IgoNotify* interfaces. Care must be taken to only fire those events when the
  property value has actually changed, and AFTER the property has changed.

  For non-visual classes (such as Models and View Models), you can use
  TgoObservable as a base class for objects that can be a source of a data
  binding. TgoObservable already implements IgoNotifyPropertyChanged.

  For controls, the IgoNotify* interfaces must be manually implemented. The
  units Grijjy.Mvvm.Controls.Fmx and Grijjy.Mvvm.Controls.Vcl contain may
  controls that already support this. This means that you can also bind two
  controls together.

  To actually bind data together, you need to create a TgoDataBinder object.
  Call its Bind method to bind the properties of two objects together. }

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.Rtti,
  System.TypInfo,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Grijjy.Collections,
  Grijjy.Mvvm.Observable,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.Rtti;

type
  { Exception type for data binding errors. These can occur for example when
    binding to properties that do not exist. }
  EgoBindError = class(Exception);

type
  { Data binding direction. }
  TgoBindDirection = (
    { Data flows in one direction, from the source (eg a view model) to a target
      (eg a control). }
    OneWay,

    { Data flows two ways. A change to the source results in a change to the
      target and vice versa. }
    TwoWay);

type
  { Optional flags to customize a data binding }
  TgoBindFlag = (
    { If you want to get notified while a property of the source object
      is changing (for example, for each character added to a TEdit).
      The source object must implement the IgoNotifyPropertyChangeTracking
      interface to support this. }
    SourceTracking,

    { If you want to get notified while a property of the target object
      is changing (for example, for each character added to a TEdit).
      The target object must implement the IgoNotifyPropertyChangeTracking
      interface to support this. }
    TargetTracking,

    { Normally, when creating a binding, the initial value of the source
      property will be applied to given target property. If you don't want this,
      then you can specify this flag.
      A reason you want to do this is if you have a one-way binding from the
      View to the ViewModel, but you don't want to update the View Model with
      the current value in the View. }
    DontApply);
  TgoBindFlags = set of TgoBindFlag;

type
  { Class that keeps track of data bindings between objects. }
  TgoDataBinder = class(TObject)
  {$REGION 'Internal Declarations'}
  private type
    TConverter = function(const AValue: TgoValue): TgoValue of object;
  private type
    TPropertyPath = record
    strict private
      FNodes: TArray<PPropInfo>;
      FLeaf: PPropInfo;
      FNodePropertyNames: TArray<String>;
      FLeafPropertyName: String;
    public
      constructor Create(const ANodes: TArray<PPropInfo>;
        const ALeaf: PPropInfo);

      procedure CheckNotificationSupport(const ARoot: TObject;
        const ATracking: Boolean);

      function Evaluate(const ARoot: TObject): TObject; overload; inline;
      function Evaluate(const ARootClass: TClass): TClass; overload;

      property Nodes: TArray<PPropInfo> read FNodes;
      property Leaf: PPropInfo read FLeaf;
      property NodePropertyNames: TArray<String> read FNodePropertyNames;
      property LeafPropertyName: String read FLeafPropertyName;
    end;
  private type
    TBinding = class(TComponent)
    strict private
      [unsafe] FBinder: TgoDataBinder;
      [unsafe] FSourceRoot: TObject;
      [unsafe] FTargetRoot: TObject;
      FSourcePath: TPropertyPath;
      FTargetPath: TPropertyPath;
      FSourceGetter: TgoPropertyGetter;
      FTargetGetter: TgoPropertyGetter;
      FSourceSetter: TgoPropertySetter;
      FTargetSetter: TgoPropertySetter;
      FConverter: TgoValueConverterClass;
      FTrackedInstances: TgoSet<Pointer>; // [Unsafe] TObject
      FDirection: TgoBindDirection;
      FSourcePropagating: Boolean;
      FTargetPropagating: Boolean;
    private
      procedure SetFreeNotification(const AInstance: TObject);
      procedure RemoveFreeNotification(const AInstance: TObject);
      procedure SetPropertyNotifications(const ARoot: TObject;
        const APath: TPropertyPath; const ANodeEvent, ALeafEvent:
        TgoEvent<String>; const ATracking: Boolean);
      procedure RemovePropertyNotifications(const AInstance: TObject);
      procedure ApplySourcePropertyValue;
    private
      procedure HandleFreeEvent(const ASender, AInstance: TObject);
      procedure HandleSourceNodePropertyChanged(const ASender: TObject;
        const APropertyName: String);
      procedure HandleSourceLeafPropertyChanged(const ASender: TObject;
        const APropertyName: String);
      procedure HandleTargetNodePropertyChanged(const ASender: TObject;
        const APropertyName: String);
      procedure HandleTargetLeafPropertyChanged(const ASender: TObject;
        const APropertyName: String);
    protected
      procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    public
      constructor Create(const ABinder: TgoDataBinder; const ASourceRoot,
        ATargetRoot: TObject; const ASourcePath, ATargetPath: TPropertyPath;
        const ASourceGetter, ATargetGetter: TgoPropertyGetter;
        const ASourceSetter, ATargetSetter: TgoPropertySetter;
        const AConverterClass: TgoValueConverterClass;
        const ADirection: TgoBindDirection; const AFlags: TgoBindFlags); reintroduce;
      destructor Destroy; override;
    end;
  private class var
    FSharedRttiContext: TRttiContext;
  private
    FBindings: TgoObjectSet<TBinding>;
  private
    class function GetPropertyPath(const ARoot: TObject;
      const APropertyPath: String): TPropertyPath; static;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create;
    destructor Destroy; override;

    { Creates a data binding.

      Parameters:
        ASource: the source of a data binding. This object must implement the
          IgoNotifyPropertyChanged and/or IgoNotifyPropertyChangeTracking
          interface. Also (for lifetime management), it should either derive
          from TComponent or implement the IgoNotifyFree interface (although
          this is not required).
        ASourcePropertyPath: the property name or path of the source to bind to.
          Can contain sub properties (such as 'Customer.Name'), as long as every
          property on the path (except for the last one) is of a class type.
          Property names are case-sensitive.
        ATarget: the target of a data binding. When TwoWay binding is used, then
          this object must also implement the IgoNotifyPropertyChanged and/or
          IgoNotifyPropertyChangeTracking interface. Like ASource, it is best if
          this object either derives from TComponent or implements
          IgoNotifyFree.
        ATargetPropertyPath: the property name or path of the target to bind to.
          Has the same features/restrictions as ASourcePropertyPath.
        ADirection: (optional) bind direction. Defaults to a two way binding.
        AFlags: (optional) binding customization flags. Used to specify if
          tracking should be enabled for the source and/or target. This means
          that property changes are propagated while the property is changing
          (for example, for every character entered into a TEdit control).
          Defaults to an empty set.
        AValueConverterClass: (optional) converter class that converts the value
          and/or type of ASourcePropertyPath to a value (and/or type) that is
          appropriate for ATargetPropertyPath (and vice verse if two-way binding
          is enabled).
          The data binder uses our own TgoValue type to copy property values.
          This mechanism already allows for many built-in type conversions.
          However, some types cannot be automatically converted. In that case,
          an exception will be raised and you must provide a value converter.
          You can also use a value converter to convert the value itself. For
          example, you can use the TgoMinusOneConverter to subtract 1 from the
          source property, before assigning it to the target property. This is
          useful when assigning Count-1 of a collection to the Max property of
          a track bar. This, and some other standard converters can be found in
          the Grijjy.Mvvm.ValueConverters unit.

      Raises:
        EgoBindError when a data binding cannot be created.

      When setting the binding, the initial value of the source property will
      be applied to the target property. If you don't want this behaviour, then
      you must specify the DontApply flag in AFlags.

      If ADirection is TwoWay, then the ATarget object must implement the
      IgoNotifyPropertyChanged interface. An exception will be raised if this is
      not the case. In addition, if tracking is enabled in AFlags, then the
      corresponding object(s) must implement the IgoNotifyPropertyChangeTracking
      interface. Again, an exception will be raised if that is not the case.

      The binding will take care of a lot of type conversions between source and
      target properties (and vice-versa if two-way binding is used). Besides
      trivial conversions (like Integer to floating-point), some less trivial
      conversions are also supported:
      * Floating-point to integer with truncation (that is, the fractional part
        is ignored).
      * Integer to string and floating-point to string (using US format
        settings).
      * String to integer and string to floating point (using US format
        settings). Results in 0 if string does not contain a number.
      * Object to string, using the TObject.ToString method (or an empty string
        if the object is not assigned).
      * Object to Boolean: nil-objects convert to False and assigned objects
        convert to True. This is useful for example to bind the Selected
        property of a TListBox to the Enabled property of a button (so the
        button is only enabled if there is an item selected).

      An exception will be raised in the following situations:
      * There is no RTTI available for ASource or ATarget.
      * The source doesn't implement the IgoNotifyPropertyChanged interface.
      * If TwoWay binding is used and the target doesn't implement the
        IgoNotifyPropertyChanged interface.
      * Tracking is enabled for the source and/or target, and that object
        doesn't implement the IgoNotifyPropertyChangeTracking interface.
      * The property ASourcePropertyPath or ATargetPropertyPath does not exist.
      * The source or target property are of an unsupported data type.
      * The source property type cannot be converted to the target property type
        (or vice-verse if two-way binding is used).
      * When the source property is write-only.
      * When the target property is read-only.
      * When the direction is TwoWay, and the source property is read-only.
      * When the direction is TwoWay, and the target property is write-only. }
    procedure Bind(const ASource: TObject; const ASourcePropertyPath: String;
      const ATarget: TObject; const ATargetPropertyPath: String;
      const ADirection: TgoBindDirection = TgoBindDirection.TwoWay;
      const AFlags: TgoBindFlags = [];
      const AValueConverterClass: TgoValueConverterClass = nil);

    { Binds a collection (such as a TList<>) to a view (such as a TListBox).

      Parameters:
        T: type parameter that indicates the type of the objects in the
          collection.
        ACollection: the collection to bind. Must be derived from
          TEnumerable<T> (for example, a TList<T>).
          When the target needs to get notified when the collection changes, use
          a collection that implements the IgoNotifyCollectionChanged interface,
          such as TgoObservableCollection<T>.
        ATarget: the target view provider. This is a class that implements
          the IgoCollectionViewProvider interface. Bindable list controls
          such as TListBox implement this interface.
        ATemplate: a template class that defines the mapping between
          properties of each item in the collection (of type T) and the
          corresponding item in the view. You usually create a custom class
          derived from TgoDataTemplate. For example, if the collection contains
          objects of type TCustomer, than you can create a mapping between the
          customer name and the item title in the view.
          If the view is a TListBox for example, then the item title will
          be assigned to the TListBoxItem.Text property.

      Raises an exception if ATarget.GetCollectionView returns nil. }
    procedure BindCollection<T: class>(const ACollection: TEnumerable<T>;
      const ATarget: IgoCollectionViewProvider;
      const ATemplate: TgoDataTemplateClass);

    { Binds an action to Execute and CanExecute methods.

      Parameters:
        AAction: the action to bind. An action is an object that implements the
          IgoBindableAction interface. The TAction classes in the
          Grijjy.Mvvm.Controls.Fmx and Grijjy.Mvvm.Controls.Vcl units implement
          this interface.
        AExecute: the method to invoke when the action is executed.
        ACanExecute: (optional) method to invoke to check whether the action
          can be executed. The Enabled property of the action will be set to the
          result of this function.

      This method is identical (or an alternative) to calling
      AAction.Bind(AExecute, ACanExecute) directly.

      You can pass either a regular method for the AExecute parameter, or a
      method that accepts a single argument of type Integer. In the later case,
      the value of the argument passed to AExecute depends on the implementor of
      this interface. The TAction class will pass its Tag value as argument. }
    procedure BindAction(const AAction: IgoBindableAction;
      const AExecute: TgoExecuteMethod;
      const ACanExecute: TgoCanExecuteMethod = nil); overload; inline;
    procedure BindAction(const AAction: IgoBindableAction;
      const AExecute: TgoExecuteMethod<Integer>;
      const ACanExecute: TgoCanExecuteMethod = nil); overload; inline;
  end;

implementation

{ TgoDataBinder }

procedure TgoDataBinder.BindAction(const AAction: IgoBindableAction;
  const AExecute: TgoExecuteMethod; const ACanExecute: TgoCanExecuteMethod);
begin
  Assert(Assigned(AAction));
  AAction.Bind(AExecute, ACanExecute);
end;

procedure TgoDataBinder.BindAction(const AAction: IgoBindableAction;
  const AExecute: TgoExecuteMethod<Integer>;
  const ACanExecute: TgoCanExecuteMethod);
begin
  Assert(Assigned(AAction));
  AAction.Bind(AExecute, ACanExecute);
end;

procedure TgoDataBinder.BindCollection<T>(const ACollection: TEnumerable<T>;
  const ATarget: IgoCollectionViewProvider; const ATemplate: TgoDataTemplateClass);
var
  View: IgoCollectionView;
begin
  Assert(Assigned(ATarget));
  Assert(Assigned(ATemplate));

  View := ATarget.GetCollectionView;
  if (View = nil) then
    raise EgoBindError.CreateFmt('Function %s.GetCollectionView cannot return nil',
      [TObject(ATarget).ClassName]);

  View.Template := ATemplate;
  View.Source := TgoCollectionSource(ACollection);
end;

procedure TgoDataBinder.Bind(const ASource: TObject;
  const ASourcePropertyPath: String; const ATarget: TObject;
  const ATargetPropertyPath: String; const ADirection: TgoBindDirection;
  const AFlags: TgoBindFlags; const AValueConverterClass: TgoValueConverterClass);
var
  SourcePath, TargetPath: TPropertyPath;
  SourceGetter, TargetGetter: TgoPropertyGetter;
  SourceSetter, TargetSetter: TgoPropertySetter;
  Binding: TBinding;
begin
  Assert(Assigned(ASource));
  Assert(Assigned(ATarget));
  Assert(ASourcePropertyPath <> '');
  Assert(ATargetPropertyPath <> '');

  SourcePath := GetPropertyPath(ASource, ASourcePropertyPath);
  TargetPath := GetPropertyPath(ATarget, ATargetPropertyPath);

  if (SourcePath.Leaf.GetProc = nil) then
    raise EgoBindError.CreateFmt('Source property %s.%s must be readable',
      [ASource.ClassName, ASourcePropertyPath]);

  if (TargetPath.Leaf.SetProc = nil) then
    raise EgoBindError.CreateFmt('Target property %s.%s must be writable',
      [ATarget.ClassName, ATargetPropertyPath]);

  SourcePath.CheckNotificationSupport(ASource, TgoBindFlag.SourceTracking in AFlags);

  SourceGetter := goGetPropertyGetter(SourcePath.Leaf.PropType^);
  if (not Assigned(SourceGetter)) then
    raise EgoBindError.CreateFmt('Property %s.%s is of an unsupported data type: %s',
      [ASource.ClassName, ASourcePropertyPath,
       SourcePath.Leaf.PropType^.NameFld.ToString]);

  TargetSetter := goGetPropertySetter(SourcePath.Leaf.PropType^, TargetPath.Leaf.PropType^);
  if (not Assigned(TargetSetter)) then
    raise EgoBindError.CreateFmt('Property %s.%s cannot be converted from type %s to type %s',
      [ASource.ClassName, ASourcePropertyPath, SourcePath.Leaf.PropType^.NameFld.ToString,
       TargetPath.Leaf.PropType^.NameFld.ToString]);

  TargetGetter := nil;
  SourceSetter := nil;
  if (ADirection = TgoBindDirection.TwoWay) then
  begin
    if (SourcePath.Leaf.SetProc = nil) then
      raise EgoBindError.CreateFmt('Source property %s.%s must be writable',
        [ASource.ClassName, ASourcePropertyPath]);

    if (TargetPath.Leaf.GetProc = nil) then
      raise EgoBindError.CreateFmt('Target property %s.%s must be readable',
        [ATarget.ClassName, ATargetPropertyPath]);

    TargetPath.CheckNotificationSupport(ATarget, TgoBindFlag.TargetTracking in AFlags);

    TargetGetter := goGetPropertyGetter(TargetPath.Leaf.PropType^);
    if (not Assigned(TargetGetter)) then
      raise EgoBindError.CreateFmt('Property %s.%s is of an unsupported data type: %s',
        [ATarget.ClassName, ATargetPropertyPath,
         TargetPath.Leaf.PropType^.NameFld.ToString]);

    SourceSetter := goGetPropertySetter(TargetPath.Leaf.PropType^, SourcePath.Leaf.PropType^);
    if (not Assigned(SourceSetter)) then
      raise EgoBindError.CreateFmt('Property %s.%s cannot be converted from type %s to type %s',
        [ATarget.ClassName, ATargetPropertyPath, TargetPath.Leaf.PropType^.NameFld.ToString,
         SourcePath.Leaf.PropType^.NameFld.ToString]);
  end;

  Binding := TBinding.Create(Self, ASource, ATarget, SourcePath, TargetPath,
    SourceGetter, TargetGetter, SourceSetter, TargetSetter,
    AValueConverterClass, ADirection, AFlags);

  FBindings.Add(Binding);
end;

constructor TgoDataBinder.Create;
begin
  inherited;
  FBindings := TgoObjectSet<TBinding>.Create;
end;

destructor TgoDataBinder.Destroy;
begin
  FreeAndNil(FBindings);
  inherited;
end;

class function TgoDataBinder.GetPropertyPath(const ARoot: TObject;
  const APropertyPath: String): TPropertyPath;
var
  Clazz: TClass;
  ClassType, PropType: TRttiType;
  Prop: TRttiProperty;
  Elements: TArray<String>;
  Nodes: TArray<PPropInfo>;
  Leaf: PPropInfo;
  I: Integer;
begin
  Assert(Assigned(ARoot));
  Clazz := ARoot.ClassType;
  Elements := APropertyPath.Split(['.']);
  if (Elements = nil) then
    raise EgoBindError.CreateFmt('Unable to retrieve information for property %s.%s',
      [Clazz.ClassName, APropertyPath]);

  Leaf := nil;
  SetLength(Nodes, Length(Elements) - 1);
  for I := 0 to Length(Elements) - 1 do
  begin
    ClassType := FSharedRttiContext.GetType(Clazz);
    if (ClassType = nil) then
      raise EgoBindError.CreateFmt('Unable to retrieve information for type %s', [Clazz.ClassName]);

    Prop := ClassType.GetProperty(Elements[I]);
    if (Prop = nil) then
      raise EgoBindError.CreateFmt('Unable to retrieve information for property %s.%s',
        [Clazz.ClassName, Elements[I]]);

    if (I = (Length(Elements) - 1)) then
    begin
      Leaf := (Prop as TRttiInstanceProperty).PropInfo;
      Assert(Assigned(Leaf));
    end
    else
    begin
      Nodes[I] := (Prop as TRttiInstanceProperty).PropInfo;
      Assert(Assigned(Nodes[I]));
      PropType := Prop.PropertyType;
      if (PropType = nil) then
        raise EgoBindError.CreateFmt('Unable to retrieve type information for property %s.%s',
          [Clazz.ClassName, Elements[I]]);

      if (PropType.TypeKind <> tkClass) then
        raise EgoBindError.CreateFmt('Invalid property path %s: property %s.%s must be of a class type',
          [APropertyPath, Clazz.ClassName, Elements[I]]);

      Clazz := (PropType as TRttiInstanceType).MetaclassType;
      Assert(Assigned(Clazz));
    end;
  end;

  Assert(Leaf <> nil);
  Result := TPropertyPath.Create(Nodes, Leaf);
end;

{ TgoDataBinder.TPropertyPath }

procedure TgoDataBinder.TPropertyPath.CheckNotificationSupport(
  const ARoot: TObject; const ATracking: Boolean);
var
  Clazz: TClass;
begin
  Assert(Assigned(ARoot));
  Clazz := Evaluate(ARoot.ClassType);
  if (ATracking) then
  begin
    if (not Supports(Clazz, IgoNotifyPropertyChangeTracking)) then
      raise EgoBindError.CreateFmt('Class %s must implement IgoNotifyPropertyChangeTracking to support data binding with tracking',
        [Clazz.ClassName]);
  end
  else
  begin
    if (not Supports(Clazz, IgoNotifyPropertyChanged)) then
      raise EgoBindError.CreateFmt('Class %s must implement IgoNotifyPropertyChanged to support data binding',
        [Clazz.ClassName]);
  end;
end;

constructor TgoDataBinder.TPropertyPath.Create(const ANodes: TArray<PPropInfo>;
  const ALeaf: PPropInfo);
var
  I: Integer;
begin
  FNodes := ANodes;
  FLeaf := ALeaf;
  FLeafPropertyName := ALeaf.NameFld.ToString;
  SetLength(FNodePropertyNames, Length(FNodes));
  for I := 0 to Length(FNodes) - 1 do
    FNodePropertyNames[I] := ANodes[I].NameFld.ToString;
end;

function TgoDataBinder.TPropertyPath.Evaluate(const ARoot: TObject): TObject;
var
  I: Integer;
begin
  Result := ARoot;
  for I := 0 to Length(FNodes) - 1 do
  begin
    Result := GetObjectProp(Result, FNodes[I]);
    if (Result = nil) then
      Exit;
  end;
end;

function TgoDataBinder.TPropertyPath.Evaluate(const ARootClass: TClass): TClass;
var
  I: Integer;
  TypeData: PTypeData;
begin
  Result := ARootClass;
  for I := 0 to Length(FNodes) - 1 do
  begin
    Assert(FNodes[I].PropType^.Kind = tkClass);
    TypeData := FNodes[I].PropType^.TypeData;
    Assert(Assigned(TypeData));
    Result := TypeData.ClassType;
    Assert(Assigned(Result));
  end;
end;

{ TgoDataBinder.TBinding }

procedure TgoDataBinder.TBinding.ApplySourcePropertyValue;
var
  Source: TObject;
begin
  Source := FSourcePath.Evaluate(FSourceRoot);
  if Assigned(Source) then
    HandleSourceLeafPropertyChanged(Source, FSourcePath.LeafPropertyName);
end;

constructor TgoDataBinder.TBinding.Create(const ABinder: TgoDataBinder;
  const ASourceRoot, ATargetRoot: TObject; const ASourcePath,
  ATargetPath: TPropertyPath; const ASourceGetter,
  ATargetGetter: TgoPropertyGetter; const ASourceSetter,
  ATargetSetter: TgoPropertySetter;
  const AConverterClass: TgoValueConverterClass;
  const ADirection: TgoBindDirection; const AFlags: TgoBindFlags);
begin
  Assert(Assigned(ABinder));
  Assert(Assigned(ASourceRoot));
  Assert(Assigned(ATargetRoot));
  Assert(Assigned(ASourcePath.Leaf));
  Assert(Assigned(ATargetPath.Leaf));
  Assert(Assigned(ASourceGetter));
  Assert(Assigned(ATargetSetter));
  inherited Create(nil);
  FBinder := ABinder;
  FTrackedInstances := TgoSet<Pointer>.Create;
  FSourceRoot := ASourceRoot;
  FTargetRoot := ATargetRoot;
  FSourcePath := ASourcePath;
  FTargetPath := ATargetPath;
  FSourceGetter := ASourceGetter;
  FTargetGetter := ATargetGetter;
  FSourceSetter := ASourceSetter;
  FTargetSetter := ATargetSetter;
  FConverter := AConverterClass;
  FDirection := ADirection;

  SetFreeNotification(FSourceRoot);
  SetFreeNotification(FTargetRoot);

  SetPropertyNotifications(FSourceRoot, FSourcePath,
    HandleSourceNodePropertyChanged, HandleSourceLeafPropertyChanged,
    TgoBindFlag.SourceTracking in AFlags);

  if (not (TgoBindFlag.DontApply in AFlags)) then
    ApplySourcePropertyValue;

  if (ADirection = TgoBindDirection.TwoWay) then
  begin
    Assert(Assigned(ATargetGetter));
    Assert(Assigned(ASourceSetter));
    SetPropertyNotifications(FTargetRoot, FTargetPath,
      HandleTargetNodePropertyChanged, HandleTargetLeafPropertyChanged,
      TgoBindFlag.TargetTracking in AFlags);
  end;
end;

destructor TgoDataBinder.TBinding.Destroy;
var
  P: Pointer;
  Instance: TObject;
begin
  if (FTrackedInstances <> nil) then
  begin
    for P in FTrackedInstances do
    begin
      Instance := TObject(P);
      RemoveFreeNotification(Instance);
      RemovePropertyNotifications(Instance);
    end;
    FTrackedInstances.Free;
  end;
  inherited;
end;

procedure TgoDataBinder.TBinding.HandleFreeEvent(const ASender,
  AInstance: TObject);
begin
  FTrackedInstances.Remove(AInstance);
end;

procedure TgoDataBinder.TBinding.HandleSourceLeafPropertyChanged(
  const ASender: TObject; const APropertyName: String);
var
  Target: TObject;
  Value: TgoValue;
  Setter: TgoPropertySetter;
begin
  if (FSourcePropagating) or (APropertyName <> FSourcePath.LeafPropertyName) then
    Exit;

  { Calling SetValue on a target may trigger another property change, resulting
    in a (possibly infinite) recursive call to this method.
    We use a FSourcePropagating flag to prevent this. }
  FSourcePropagating := True;
  try
    Target := FTargetPath.Evaluate(FTargetRoot);
    if Assigned(Target) then
    begin
      Value := FSourceGetter(ASender, FSourcePath.Leaf);
      if Assigned(FConverter) then
      begin
        Value := FConverter.ConvertSourceToTarget(Value);
        Setter := goGetPropertySetter(Value.ValueType, FTargetPath.Leaf.PropType^);
        if (not Assigned(Setter)) then
          raise EgoBindError.Create('Value converter converts to unsupported data type');
        Setter(Target, FTargetPath.Leaf, Value);
      end
      else
        FTargetSetter(Target, FTargetPath.Leaf, Value);
    end;
  finally
    FSourcePropagating := False;
  end;
end;

procedure TgoDataBinder.TBinding.HandleSourceNodePropertyChanged(
  const ASender: TObject; const APropertyName: String);
var
  Instance: TObject;
  Nodes: TArray<PPropInfo>;
  NotifyPropertyChanged: IgoNotifyPropertyChanged;
  I: Integer;
  SetNotification: Boolean;
begin
  if (FSourcePropagating) then
    Exit;

  Instance := FSourceRoot;
  Nodes := FSourcePath.Nodes;
  SetNotification := False;
  for I := 0 to Length(Nodes) - 1 do
  begin
    if SetNotification and Supports(Instance, IgoNotifyPropertyChanged, NotifyPropertyChanged) then
    begin
      FTrackedInstances.AddOrSet(Instance);
      NotifyPropertyChanged.GetPropertyChangedEvent.Add(HandleSourceNodePropertyChanged);
    end;

    if (Instance = ASender) then
    begin
      if (FSourcePath.NodePropertyNames[I] <> APropertyName) then
        Exit;

      { All next siblings in the chain have changed as well.
        Make sure we subscribe to their changes. }
      SetNotification := True;
    end;

    Instance := GetObjectProp(Instance, Nodes[I]);
    if (Instance = nil) then
      Exit;
  end;

  HandleSourceLeafPropertyChanged(Instance, FSourcePath.LeafPropertyName);
end;

procedure TgoDataBinder.TBinding.HandleTargetLeafPropertyChanged(
  const ASender: TObject; const APropertyName: String);
var
  Source: TObject;
  Value: TgoValue;
  Setter: TgoPropertySetter;
begin
  if (FTargetPropagating) or (APropertyName <> FTargetPath.LeafPropertyName) then
    Exit;

  { Calling SetValue on a Source may trigger another property change, resulting
    in a (possibly infinite) recursive call to this method.
    We use a FTargetPropagating flag to prevent this. }
  FTargetPropagating := True;
  try
    Source := FSourcePath.Evaluate(FSourceRoot);
    if Assigned(Source) then
    begin
      Value := FTargetGetter(ASender, FTargetPath.Leaf);
      if Assigned(FConverter) then
      begin
        Value := FConverter.ConvertTargetToSource(Value);
        Setter := goGetPropertySetter(Value.ValueType, FSourcePath.Leaf.PropType^);
        if (not Assigned(Setter)) then
          raise EgoBindError.Create('Value converter converts to unsupported data type');
        Setter(Source, FSourcePath.Leaf, Value);
      end
      else
        FSourceSetter(Source, FSourcePath.Leaf, Value);
    end;
  finally
    FTargetPropagating := False;
  end;
end;

procedure TgoDataBinder.TBinding.HandleTargetNodePropertyChanged(
  const ASender: TObject; const APropertyName: String);
var
  Instance: TObject;
  Nodes: TArray<PPropInfo>;
  NotifyPropertyChanged: IgoNotifyPropertyChanged;
  I: Integer;
  SetNotification: Boolean;
begin
  if (FTargetPropagating) then
    Exit;

  Instance := FTargetRoot;
  Nodes := FTargetPath.Nodes;
  SetNotification := False;
  for I := 0 to Length(Nodes) - 1 do
  begin
    if SetNotification and Supports(Instance, IgoNotifyPropertyChanged, NotifyPropertyChanged) then
    begin
      FTrackedInstances.AddOrSet(Instance);
      NotifyPropertyChanged.GetPropertyChangedEvent.Add(HandleTargetNodePropertyChanged);
    end;

    if (Instance = ASender) then
    begin
      if (FTargetPath.NodePropertyNames[I] <> APropertyName) then
        Exit;

      { All next siblings in the chain have changed as well.
        Make sure we subscribe to their changes. }
      SetNotification := True;
    end;

    Instance := GetObjectProp(Instance, Nodes[I]);
    if (Instance = nil) then
      Exit;
  end;

  HandleTargetLeafPropertyChanged(Instance, FTargetPath.LeafPropertyName);
end;

procedure TgoDataBinder.TBinding.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) then
    HandleFreeEvent(AComponent, AComponent);
end;

procedure TgoDataBinder.TBinding.RemoveFreeNotification(
  const AInstance: TObject);
var
  NotifyFree: IgoNotifyFree;
begin
  if (AInstance is TComponent) then
    TComponent(AInstance).RemoveFreeNotification(Self)
  else if Supports(AInstance, IgoNotifyFree, NotifyFree) then
    NotifyFree.GetFreeEvent.Remove(HandleFreeEvent);
end;

procedure TgoDataBinder.TBinding.RemovePropertyNotifications(
  const AInstance: TObject);
var
  NotifyPropertyChanged: IgoNotifyPropertyChanged;
  NotifyPropertyChangeTracking: IgoNotifyPropertyChangeTracking;
begin
  if Supports(AInstance, IgoNotifyPropertyChangeTracking, NotifyPropertyChangeTracking) then
    NotifyPropertyChangeTracking.GetPropertyChangeTrackingEvent.RemoveAll(Self);

  if Supports(AInstance, IgoNotifyPropertyChanged, NotifyPropertyChanged) then
    NotifyPropertyChanged.GetPropertyChangedEvent.RemoveAll(Self);
end;

procedure TgoDataBinder.TBinding.SetFreeNotification(const AInstance: TObject);
var
  NotifyFree: IgoNotifyFree;
begin
  if (AInstance is TComponent) then
  begin
    FTrackedInstances.AddOrSet(AInstance);
    TComponent(AInstance).FreeNotification(Self);
  end
  else if Supports(AInstance, IgoNotifyFree, NotifyFree) then
  begin
    FTrackedInstances.AddOrSet(AInstance);
    NotifyFree.GetFreeEvent.Add(HandleFreeEvent);
  end;
end;

procedure TgoDataBinder.TBinding.SetPropertyNotifications(const ARoot: TObject;
  const APath: TPropertyPath; const ANodeEvent, ALeafEvent: TgoEvent<String>;
  const ATracking: Boolean);
var
  NotifyPropertyChanged: IgoNotifyPropertyChanged;
  NotifyPropertyChangeTracking: IgoNotifyPropertyChangeTracking;
  Nodes: TArray<PPropInfo>;
  Instance: TObject;
  I: Integer;
begin
  Nodes := APath.Nodes;
  Instance := ARoot;
  for I := 0 to Length(Nodes) - 1 do
  begin
    if Supports(Instance, IgoNotifyPropertyChanged, NotifyPropertyChanged) then
    begin
      FTrackedInstances.AddOrSet(Instance);
      NotifyPropertyChanged.GetPropertyChangedEvent.Add(ANodeEvent);
    end;

    Instance := GetObjectProp(Instance, Nodes[I]);
    if (Instance = nil) then
      Exit;
  end;

  if ATracking then
  begin
    if Supports(Instance, IgoNotifyPropertyChangeTracking, NotifyPropertyChangeTracking) then
    begin
      FTrackedInstances.AddOrSet(Instance);
      NotifyPropertyChangeTracking.GetPropertyChangeTrackingEvent.Add(ALeafEvent)
    end
    else
      Assert(False, 'Should not get here. This check has been made earlier.');
  end
  else
  begin
    if Supports(Instance, IgoNotifyPropertyChanged, NotifyPropertyChanged) then
    begin
      FTrackedInstances.AddOrSet(Instance);
      NotifyPropertyChanged.GetPropertyChangedEvent.Add(ALeafEvent)
    end
    else
      Assert(False, 'Should not get here. This check has been made earlier.');
  end;
end;

end.
