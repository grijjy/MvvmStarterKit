unit Tests.Grijjy.Mvvm.Types;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  DUnitX.TestFramework,
  Grijjy.Mvvm.Types;

type
  TTestTgoMultiCastEvent = class
  private
    FCUT: IgoMultiCastEvent<Integer>;
    FAccum: Integer;
  private
    procedure ListenerAddOnce(const ASender: TObject; const AArg: Integer);
    procedure ListenerAddTwice(const ASender: TObject; const AArg: Integer);
  public
    [Setup] procedure Setup;

    [Test] procedure AddAndInvoke;
    [Test] procedure DeleteAndInvoke;
  end;

implementation

{ TTestTgoMultiCastEvent }

procedure TTestTgoMultiCastEvent.AddAndInvoke;
begin
  FCUT.Add(ListenerAddOnce);
  Assert.AreEqual(0, FAccum);

  FCUT.Invoke(Self, 10);
  Assert.AreEqual(10, FAccum);

  FCUT.Invoke(Self, 20);
  Assert.AreEqual(30, FAccum);

  FCUT.Add(ListenerAddTwice);

  FCUT.Invoke(Self, 2);
  Assert.AreEqual(36, FAccum);

  FCUT.Invoke(Self, 3);
  Assert.AreEqual(45, FAccum);
end;

procedure TTestTgoMultiCastEvent.DeleteAndInvoke;
begin
  FCUT.Add(ListenerAddOnce);
  FCUT.Add(ListenerAddTwice);
  Assert.AreEqual(0, FAccum);

  FCUT.Invoke(Self, 10);
  Assert.AreEqual(30, FAccum);

  FCUT.Remove(ListenerAddOnce);

  FCUT.Invoke(Self, 2);
  Assert.AreEqual(34, FAccum);

  FCUT.Remove(ListenerAddTwice);

  FCUT.Invoke(Self, 3);
  Assert.AreEqual(34, FAccum);

  FCUT.Add(ListenerAddOnce);
  FCUT.Add(ListenerAddTwice);

  FCUT.Invoke(Self, 3);
  Assert.AreEqual(43, FAccum);

  FCUT.Remove(ListenerAddTwice);

  FCUT.Invoke(Self, 4);
  Assert.AreEqual(47, FAccum);

  FCUT.Remove(ListenerAddOnce);

  FCUT.Invoke(Self, 5);
  Assert.AreEqual(47, FAccum);
end;

procedure TTestTgoMultiCastEvent.ListenerAddOnce(const ASender: TObject;
  const AArg: Integer);
begin
  Assert.IsTrue(ASender = Self);
  Inc(FAccum, AArg);
end;

procedure TTestTgoMultiCastEvent.ListenerAddTwice(const ASender: TObject;
  const AArg: Integer);
begin
  Assert.IsTrue(ASender = Self);
  Inc(FAccum, AArg * 2);
end;

procedure TTestTgoMultiCastEvent.SetUp;
begin
  inherited;
  FCUT := TgoMultiCastEvent<Integer>.Create;
  FAccum := 0;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTgoMultiCastEvent);

end.
