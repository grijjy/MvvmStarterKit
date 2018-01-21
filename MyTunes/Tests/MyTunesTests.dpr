program MyTunesTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  Model.Album in '..\Shared\Models\Model.Album.pas',
  Model in '..\Shared\Models\Model.pas',
  Model.Track in '..\Shared\Models\Model.Track.pas',
  ViewModel.Album in '..\Shared\ViewModels\ViewModel.Album.pas',
  ViewModel.Albums in '..\Shared\ViewModels\ViewModel.Albums.pas',
  ViewModel.Tracks in '..\Shared\ViewModels\ViewModel.Tracks.pas',
  Data in '..\Shared\Data\Data.pas',
  Tests.Model in 'Tests\Models\Tests.Model.pas',
  Tests.Model.Album in 'Tests\Models\Tests.Model.Album.pas',
  Tests.Model.Track in 'Tests\Models\Tests.Model.Track.pas',
  Tests.ViewModel.Albums in 'Tests\ViewModels\Tests.ViewModel.Albums.pas',
  Tests.ViewModel.Album in 'Tests\ViewModels\Tests.ViewModel.Album.pas',
  Tests.ViewModel.Tracks in 'Tests\ViewModels\Tests.ViewModel.Tracks.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
