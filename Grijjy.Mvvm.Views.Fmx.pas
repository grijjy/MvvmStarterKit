unit Grijjy.Mvvm.Views.Fmx;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  FMX.Forms,
  FMX.Objects,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.DataBinding;

type
  { A base form that you can use for view in a MVVM model.
    This form takes care of the following:
    * It implements the IgoView interfaces.
    * It provides a default data binder through the Binder property.
    * On desktop platforms, when the form is shown modally (by calling
      ExecuteModal), it "grays out" the previous active form as a visual
      indicator that it is not accessible. You can disable this behaviour by
      setting GrayOutPreviousForm to False.
    * By default, it frees the form when it closes (that is, the CloseAction
      is set to caFree). You can change this by overriding DoClose or
      assigning an OnClose event.

    True modal forms are not supported on the Android platform. So to make the
    experience the same on all platforms, ExecuteModal is non-blocking and just
    shows the form without waiting for it to be closed. It will call the given
    anonymous AResultProc when the form is closed. (Note: unlike the standard
    ShowModal method, AResultProc is also called if the form is closed when
    the user presses the X button; in that case the AModelResult parameter will
    be mrCancel.)

    The type parameter TVM is the type of the view model used by the view. }
  TgoFormView<TVM: class> = class(TForm, IgoView, IgoView<TVM>)
  {$REGION 'Internal Declarations'}
  private
    {$IFNDEF MOBILE}
    FPrevForm: TCommonCustomForm;
    FOverlay: TRectangle;
    {$ENDIF}
    FBinder: TgoDataBinder;
    FViewModel: TVM;
    FOwnsViewModel: Boolean;
    FGrayOutPreviousForm: Boolean;
  protected
    procedure DoClose(var CloseAction: TCloseAction); override;
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

      This method calls the SetupView method, which you should override to setup
      any data bindings. }
    procedure InitView(const AViewModel: TVM; const AOwnsViewModel: Boolean);

    { Executes the view in a modal way.

      Parameters:
        AResultProc: an anonymous method that will be called when the view
          closes. The parameter to this method is a TModalResult that indicates
          how the view was closed.

      NOTE: unlike the standard ShowModal method, AResultProc is also called if
      the form is closed when the user presses the X icon; in that case the
      AModelResult parameter will be mrCancel. }
    procedure ExecuteModal(const AResultProc: TProc<TModalResult>);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { This property is only used on Desktop platforms. When True and the form is
      shown modally (by calling ExecuteModal), it "grays out" the previous
      active form as a visual indicator that it is not accessible. Set to False
      to disable this behaviour. Defaults to True. }
    property GrayOutPreviousForm: Boolean read FGrayOutPreviousForm write FGrayOutPreviousForm;

    { A default data binder for the view. }
    property Binder: TgoDataBinder read FBinder;
  end;

implementation

uses
  FMX.Graphics,
  Grijjy.System;

{ TgoFormView<TVM> }

constructor TgoFormView<TVM>.Create(AOwner: TComponent);
begin
  {$IFNDEF MOBILE}
  FPrevForm := Screen.ActiveForm;
  {$ENDIF}
  inherited;
  FBinder := TgoDataBinder.Create;
  FGrayOutPreviousForm := True;
end;

destructor TgoFormView<TVM>.Destroy;
begin
  FBinder.Free;
  if (FOwnsViewModel) then
    FViewModel.Free;
  inherited;
end;

procedure TgoFormView<TVM>.DoClose(var CloseAction: TCloseAction);
begin
  CloseAction := TCloseAction.caFree;
  inherited;
  { When ModelResult = mrNone, the user closed the form by clicking the X
    button or some other means.
    When using ShowModal, this would NOT result in a callback to the
    anonymous ResultProc. So we set ModalResult to mrCancel in this case, which
    results in a callback, }
  if (ModalResult = mrNone) then
    ModalResult := mrCancel;

  {$IFNDEF MOBILE}
  if Assigned(FPrevForm) and (FGrayOutPreviousForm) then
  begin
    FPrevForm.RemoveObject(FOverlay);
    FOverlay.DisposeOf;
  end;
  {$ENDIF}
end;

procedure TgoFormView<TVM>.ExecuteModal(const AResultProc: TProc<TModalResult>);
{$IFNDEF ANDROID}
var
  MR: TModalResult;
{$ENDIF}
{$IFNDEF MOBILE}
var
  PrevForm: TCommonCustomForm;
{$ENDIF}
begin
  {$IFNDEF MOBILE}
  PrevForm := Screen.ActiveForm;
  if (PrevForm <> nil) then
    FPrevForm := PrevForm;
  if Assigned(FPrevForm) and (FGrayOutPreviousForm) then
  begin
    { Add overlay to prevent users from interacting with the previous form. }
    FOverlay := TRectangle.Create(FPrevForm);
    FOverlay.SetBounds(0, 0, 9999, 9999);
    FOverlay.Stroke.Kind := TBrushKind.None;
    FOverlay.Fill.Color := $50000000;
    FPrevForm.AddObject(FOverlay);
  end;
  {$ENDIF}

  ShowModal(AResultProc);
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
