unit Grijjy.Mvvm.Mock;
{ Some mock classes for unit testing MVVM functionality. }

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.UITypes,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Grijjy.Mvvm.Types;

type
  { A mock view that implements the IgoView interface.
    The type parameter TVM is the type of the view model used by the view. }
  TgoMockView<TVM: class> = class(TComponent, IgoView, IgoView<TVM>)
  {$REGION 'Internal Declarations'}
  private class var
    FRegisteredMockViews: TDictionary<TComponentClass, TFunc<TVM, TModalResult>>;
  private
    FViewModel: TVM;
    FOwnsViewModel: Boolean;
  protected
    { IgoView }
    procedure InitView(const AViewModel: TVM; const AOwnsViewModel: Boolean);
    procedure ExecuteModal(const AResultProc: TProc<TModalResult>);
  public
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    destructor Destroy; override;

    { Registers a mock view with the view factory.

      Parameters:
        AName: the name of the view. The view factory uses this name to look up
          the type of view to create.
        AExecuteModal: an anonymous function that is executed to simulate the
          modal execution of the view. This function has a single parameter with
          the type of the view modal associated with the view. It must return a
          TModalResult value to indicate how the view was closed. Cannot be nil. }
    class procedure Register(const AName: String;
      const AExecuteModal: TFunc<TVM, TModalResult>);

    { The view model for the view. }
    property ViewModel: TVM read FViewModel;
  end;

implementation

uses
  Grijjy.Mvvm.ViewFactory;

{ TgoMockView<TVM> }

destructor TgoMockView<TVM>.Destroy;
begin
  if (FOwnsViewModel) then
    FViewModel.Free;
  inherited;
end;

class destructor TgoMockView<TVM>.Destroy;
begin
  FRegisteredMockViews.Free;
end;

procedure TgoMockView<TVM>.ExecuteModal(const AResultProc: TProc<TModalResult>);
var
  ExecuteModal: TFunc<TVM, TModalResult>;
  ModalResult: TModalResult;
begin
  ModalResult := mrNone;
  if Assigned(FRegisteredMockViews)
    and (FRegisteredMockViews.TryGetValue(TComponentClass(ClassType), ExecuteModal))
  then
    ModalResult := ExecuteModal(FViewModel);

  if Assigned(AResultProc) then
    AResultProc(ModalResult);

  { Mimic the free-on-close behavior of a form }
  DisposeOf;
end;

procedure TgoMockView<TVM>.InitView(const AViewModel: TVM;
  const AOwnsViewModel: Boolean);
begin
  Assert(AViewModel <> nil);
  Assert(FViewModel = nil);
  FViewModel := AViewModel;
  FOwnsViewModel := AOwnsViewModel;
end;

class procedure TgoMockView<TVM>.Register(const AName: String;
  const AExecuteModal: TFunc<TVM, TModalResult>);
begin
  Assert(Assigned(AExecuteModal));
  TgoViewFactory.Register(Self, AName);

  if (FRegisteredMockViews = nil) then
    FRegisteredMockViews := TDictionary<TComponentClass, TFunc<TVM, TModalResult>>.Create;

  FRegisteredMockViews.AddOrSetValue(Self, AExecuteModal);
end;

end.
