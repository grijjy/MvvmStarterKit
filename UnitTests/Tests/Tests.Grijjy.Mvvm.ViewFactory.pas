unit Tests.Grijjy.Mvvm.ViewFactory;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  DUnitX.TestFramework;

type
  TTestTgoViewFactory = class
  public
    [Test] procedure TestMockViewCancel;
    [Test] procedure TestMockViewOk;
  end;

implementation

uses
  System.UITypes,
  Grijjy.Mvvm.Mock,
  Grijjy.Mvvm.Types,
  Grijjy.Mvvm.Observable,
  Grijjy.Mvvm.ViewFactory;

type
  TMyViewModel = class(TgoObservable)
  strict private
    FValue: Integer;
  public
    property Value: Integer read FValue write FValue;
  end;

{ TTestTgoViewFactory }

procedure TTestTgoViewFactory.TestMockViewCancel;
var
  ViewModel: TMyViewModel;
  View: IgoView;
  Value: Integer;
begin
  TgoMockView<TMyViewModel>.Register('MyView',
    function (AViewModel: TMyViewModel): TModalResult
    begin
      AViewModel.Value := 42;
      Result := mrCancel;
    end);

  Value := 1;
  ViewModel := TMyViewModel.Create;
  View := TgoViewFactory.CreateView('MyView', nil, ViewModel);
  View.ExecuteModal(
    procedure (AModalResult: TModalResult)
    begin
      if (AModalResult = mrOk) then
        Value := ViewModel.Value;
    end);
  Assert.AreEqual(1, Value);
end;

procedure TTestTgoViewFactory.TestMockViewOk;
var
  ViewModel: TMyViewModel;
  View: IgoView;
  Value: Integer;
begin
  TgoMockView<TMyViewModel>.Register('MyView',
    function (AViewModel: TMyViewModel): TModalResult
    begin
      AViewModel.Value := 42;
      Result := mrOk;
    end);

  Value := 1;
  ViewModel := TMyViewModel.Create;
  View := TgoViewFactory.CreateView('MyView', nil, ViewModel);
  View.ExecuteModal(
    procedure (AModalResult: TModalResult)
    begin
      if (AModalResult = mrOk) then
        Value := ViewModel.Value;
    end);
  Assert.AreEqual(42, Value);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTgoViewFactory);

end.
