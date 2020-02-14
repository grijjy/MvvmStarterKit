unit Grijjy.Mvvm.Views.Vcl;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.UITypes,
  System.Classes,
  System.SysUtils,
  Vcl.Forms,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.DataBinding;

type
  { A base form that you can use for view in a MVVM model.
    This form takes care of the following:
    * It implements the IgoView interfaces.
    * It provides a default data binder through the Binder property.
    * By default, it frees the form when it closes (that is, the CloseAction
      is set to caFree). You can change this by overriding DoClose or
      assigning an OnClose event.

    The type parameter TVM is the type of the view model used by the view. }
  TgoFormView<TVM: class> = class(TForm, IgoView, IgoView<TVM>)
  {$REGION 'Internal Declarations'}
  private
    FBinder: TgoDataBinder;
    FViewModel: TVM;
    FOwnsViewModel: Boolean;
  protected
    procedure DoClose(var Action: TCloseAction); override;
  {$ENDREGION 'Internal Declarations'}
  protected
    { Override this method to setup any data bindings for the view.
      At this point, the ViewModel property will be available.
      This method does nothing by default. }
    procedure SetupView; virtual;

    { The view model associated with the view }
    property ViewModel: TVM read FViewModel;
  public
    { IgoView<TVM> }

    { Initializes the view and associates it with a view model.

      Parameters:
        AViewModel: the view model to associate with the view.
          The view model MUST remain alive for the duration of the view. The
          view does NOT become owner of the view model.
        AOwnsViewModel: whether the view becomes owner of the view model. If
          True, then the view model will automatically be freed when the view is
          freed.

      Should usually be overridden to set up the data bindings. }
    procedure InitView(const AViewModel: TVM; const AOwnsViewModel: Boolean);

    { Executes the view }
    procedure Execute;

    { Executes the view in a modal way.

      Parameters:
        AResultProc: an anonymous method that will be called when the view
          closes. The parameter to this method is a TModalResult that indicates
          how the view was closed.

      NOTE: this method uses an anonymous method (instead of just returning a
      modal result) for compatibility with the FMX version and the lack of
      modal views on Android. }
    procedure ExecuteModal(const AResultProc: TProc<TModalResult>);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { A default data binder for the view. }
    property Binder: TgoDataBinder read FBinder;
  end;

implementation

{ TgoFormView<TVM> }

constructor TgoFormView<TVM>.Create(AOwner: TComponent);
begin
  inherited;
  FBinder := TgoDataBinder.Create;
end;

destructor TgoFormView<TVM>.Destroy;
begin
  FBinder.Free;
  if (FOwnsViewModel) then
    FViewModel.Free;
  inherited;
end;

procedure TgoFormView<TVM>.DoClose(var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  inherited;
end;

procedure TgoFormView<TVM>.Execute;
begin
  Show;
end;

procedure TgoFormView<TVM>.ExecuteModal(const AResultProc: TProc<TModalResult>);
var
  Result: TModalResult;
begin
  Result := ShowModal;
  if Assigned(AResultProc) then
    AResultProc(Result);
end;

procedure TgoFormView<TVM>.InitView(const AViewModel: TVM;
  const AOwnsViewModel: Boolean);
begin
  Assert(Assigned(AViewModel));
  Assert(FViewModel = nil);
  FViewModel := AViewModel;
  FOwnsViewModel := AOwnsViewModel;
  if Assigned(FViewModel) then
    SetupView;
end;

procedure TgoFormView<TVM>.SetupView;
begin
  { No default implementation }
end;

end.
