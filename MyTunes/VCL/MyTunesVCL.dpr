program MyTunesVCL;

uses
  Vcl.Forms,
  View.Albums in 'Views\View.Albums.pas' {ViewAlbums},
  Data in '..\Shared\Data\Data.pas',
  Model.Album in '..\Shared\Models\Model.Album.pas',
  Model in '..\Shared\Models\Model.pas',
  Model.Track in '..\Shared\Models\Model.Track.pas',
  ViewModel.Album in '..\Shared\ViewModels\ViewModel.Album.pas',
  ViewModel.Albums in '..\Shared\ViewModels\ViewModel.Albums.pas',
  ViewModel.Tracks in '..\Shared\ViewModels\ViewModel.Tracks.pas',
  Template.Album in '..\Shared\Templates\Template.Album.pas',
  Template.Track in '..\Shared\Templates\Template.Track.pas',
  View.Album in 'Views\View.Album.pas' {ViewAlbum},
  Converter.TitleToCaption in '..\Shared\Converters\Converter.TitleToCaption.pas',
  View.Tracks in 'Views\View.Tracks.pas' {ViewTracks};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TViewAlbums, ViewAlbums);
  Application.Run;
end.
