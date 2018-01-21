unit Tests.Model;

interface

uses
  DUnitX.TestFramework,
  Model;

type
  TTestModel = class
  public
    [Test] procedure TestInstance;
  end;

implementation

{ TTestModel }

procedure TTestModel.TestInstance;
begin
  ReportMemoryLeaksOnShutdown := True;
  Assert.IsNotNull(TModel.Instance);
  Assert.IsNotNull(TModel.Instance.Albums);
  Assert.IsTrue(TModel.Instance.Albums.Count > 0);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestModel);

end.
