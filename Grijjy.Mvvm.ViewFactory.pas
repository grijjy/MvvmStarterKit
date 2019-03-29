unit Grijjy.Mvvm.ViewFactory;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.UITypes,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Grijjy.Mvvm.Types;

type
  { A factory for creating views based on their names.
    This allows for loose coupling between view models and views, since the
    view model can create a view without knowing its actual type.

    All views (except the main form) should implement the IgoView interface and
    register the view class by calling TgoViewFactory.Register (usually in the
    Initialization section of the unit).

    View models can create a view by calling TgoViewFactory.CreateView. }
  TgoViewFactory = class // abstract
  {$REGION 'Internal Declarations'}
  private class var
    FRegisteredViews: TDictionary<String, TComponentClass>;
  public
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    { Registers a view class with the factory.

      Parameters:
        AViewClass: the class of the view (such as a form) to register.
          AViewClass MUST implement the IgoView interface.
        AViewName: the name to register the view under.

      Raises:
        EInvalidOperation if AViewClass does not implement IgoView.

      This method should be called once for each view type, usually in the
      Initialization section of the unit of that view. }
    class procedure Register(const AViewClass: TComponentClass;
      const AViewName: String); static;

    { Creates a view using a previously registered view class.

      Parameters:
        TVM: type parameter with the type of view model used by the view.
        AViewName: the name of the view. This must be one of the names
          previously registered using the Register method. The name determines
          the type of view that is created.
        AOwner: the owner for the view. This is passed as the standard AOwner
          parameter of the view class.
        AViewModel: the view model for the the view. This method will call
          IgoView.Initialize to associate the view model with the view.
        AOwnsViewModel: (optional) whether the view becomes owner of the view
          model. If True (the default), then the view model will automatically
          be freed when the view is freed.

      Returns:
        A newly created view that represents AViewName.

      Raises:
        EListError if there is no view registered with the given AViewName. }
    class function CreateView<TVM: class>(const AViewName: String;
      const AOwner: TComponent; const AViewModel: TVM;
      const AOwnsViewModel: Boolean = True): IgoView<TVM>; static;
  end;

type
  { Internal class used to manage lifetimes of views. }
  TgoViewProxy<TVM: class> = class(TInterfacedObject, IgoView, IgoView<TVM>)
  {$REGION 'Internal Declarations'}
  private type
    TViewFreeListener = class(TComponent)
    strict private
      FActualView: IgoView<TVM>;
      [unsafe] FActualViewObject: TComponent;
    protected
      procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    public
      constructor Create(const AView: IgoView<TVM>); reintroduce;
      destructor Destroy; override;

      property ActualView: IgoView<TVM> read FActualView;
    end;
  private
    FViewFreeListener: TViewFreeListener;
  protected
    { IgoView }
    procedure Execute;
    procedure ExecuteModal(const AResultProc: TProc<TModalResult>);
  protected
    { IgoView<TVM> }
    procedure InitView(const AViewModel: TVM; const AOwnsViewModel: Boolean);
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AActualView: IgoView<TVM>);
    destructor Destroy; override;
  end;

implementation

uses
  System.Generics.Defaults;

{ TgoViewProxy<TVM> }

constructor TgoViewProxy<TVM>.Create(const AActualView: IgoView<TVM>);
begin
  Assert(Assigned(AActualView));
  inherited Create;
  { Executing a view may free it (for example, when the view is a form and its
    CloseAction is set to caFree). When that happens, the IgoView interface
    will contain an invalid reference, and you may get an access violation when
    it goes out of scope. To avoid this, we use a view proxy. This proxy
    subscribes to a free notification of the view, so it can set the IgoView
    interface to nil BEFORE the view is destroyed. }
  FViewFreeListener := TViewFreeListener.Create(AActualView);
end;

destructor TgoViewProxy<TVM>.Destroy;
begin
  FViewFreeListener.Free;
  inherited;
end;

procedure TgoViewProxy<TVM>.Execute;
begin
  if Assigned(FViewFreeListener.ActualView) then
    FViewFreeListener.ActualView.Execute;
end;

procedure TgoViewProxy<TVM>.ExecuteModal(const AResultProc: TProc<TModalResult>);
begin
  if Assigned(FViewFreeListener.ActualView) then
    FViewFreeListener.ActualView.ExecuteModal(AResultProc);
end;

procedure TgoViewProxy<TVM>.InitView(const AViewModel: TVM;
  const AOwnsViewModel: Boolean);
begin
  if Assigned(FViewFreeListener.ActualView) then
    FViewFreeListener.ActualView.InitView(AViewModel, AOwnsViewModel);
end;

{ TgoViewProxy<TVM>.TViewFreeListener }

constructor TgoViewProxy<TVM>.TViewFreeListener.Create(const AView: IgoView<TVM>);
var
  Instance: TObject;
begin
  inherited Create(nil);
  FActualView := AView;
  Instance := TObject(AView);
  if (Instance is TComponent) then
  begin
    FActualViewObject := TComponent(Instance);
    FActualViewObject.FreeNotification(Self);
  end;
end;

destructor TgoViewProxy<TVM>.TViewFreeListener.Destroy;
begin
  if (FActualViewObject <> nil) then
    FActualViewObject.RemoveFreeNotification(Self);
  inherited;
end;

procedure TgoViewProxy<TVM>.TViewFreeListener.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FActualViewObject) and (Operation = opRemove) then
  begin
    FActualView := nil;
    FActualViewObject := nil;
  end;
end;

{ TgoViewFactory }

class function TgoViewFactory.CreateView<TVM>(const AViewName: String;
  const AOwner: TComponent; const AViewModel: TVM;
  const AOwnsViewModel: Boolean): IgoView<TVM>;
var
  ViewClass: TComponentClass;
  ViewComp: TComponent;
  View: IgoView<TVM>;
begin
  try
    ViewClass := nil;
    if Assigned(FRegisteredViews) then
      FRegisteredViews.TryGetValue(AViewName, ViewClass);

    if (ViewClass = nil) then
      raise EListError.CreateFmt('Cannot create view. View "%s" is not registered.', [AViewName]);

    ViewComp := ViewClass.Create(AOwner);
    View := ViewComp as IgoView<TVM>;
    Result := TgoViewProxy<TVM>.Create(View);
    Result.InitView(AViewModel, AOwnsViewModel);
  except
    if (AOwnsViewModel) then
      AViewModel.DisposeOf;
    raise;
  end;
end;

class destructor TgoViewFactory.Destroy;
begin
  FreeAndNil(FRegisteredViews);
end;

class procedure TgoViewFactory.Register(const AViewClass: TComponentClass;
  const AViewName: String);
begin
  if (not Supports(AViewClass, IgoView)) then
    raise EInvalidOperation.CreateFmt('View class %s must implement the IgoView interface',
      [AViewClass.ClassName]);

  if (FRegisteredViews = nil) then
    FRegisteredViews := TDictionary<String, TComponentClass>.Create(
      TIStringComparer.Ordinal);

  FRegisteredViews.AddOrSetValue(AViewName, AViewClass);
end;

end.
