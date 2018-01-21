unit Data;
{ This unit represents a database backend.
  To keep things simple, we do not use an actual database.
  Instead, we load data from a Google Protocol Buffer file which is embedded
  into the executable as a resource. This file is created using the Apple Music
  API (https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/)
  by requesting the top albums at the time of writing.
  In reality, the data usually comes from a backend server or REST API. }

interface

uses
  System.SysUtils,
  Grijjy.ProtocolBuffers;

{ Data records that can be used with Google Protocol Buffers. }

type
  TDataTrack = record
  public
    [Serialize(1)] Name: String;
    [Serialize(2)] DurationMs: Integer;
    [Serialize(3)] TrackNumber: Integer;
    [Serialize(4)] Genres: String;
  end;

type
  TDataAlbum = record
  public
    [Serialize( 1)] Name: String;
    [Serialize( 2)] ArtistName: String;
    [Serialize( 3)] RecordLabel: String;
    [Serialize( 4)] Copyright: String;
    [Serialize( 5)] ReleaseDate: TDateTime;
    [Serialize( 6)] Notes: String;
    [Serialize( 7)] Image: TBytes;
    [Serialize( 8)] BackgroundColor: FixedUInt32;
    [Serialize( 9)] TextColor1: FixedUInt32;
    [Serialize(10)] TextColor2: FixedUInt32;
    [Serialize(11)] TextColor3: FixedUInt32;
    [Serialize(12)] Tracks: TArray<TDataTrack>;
  end;

type
  TDatabase = record
  public
    [Serialize(1)] Albums: TArray<TDataAlbum>;
  public
    procedure Load;
  end;

implementation

uses
  System.Types,
  System.Classes;

{ This resource contains the Google Protocol Buffers file }
{$R '..\Shared\Resources\Resources.res'}

{ TDataBase }

procedure TDataBase.Load;
var
  Stream: TResourceStream;
begin
  Stream := TResourceStream.Create(HInstance, 'MYTUNES', RT_RCDATA);
  try
    TgoProtocolBuffer.Deserialize(Self, Stream);
  finally
    Stream.Free;
  end;
end;

end.
