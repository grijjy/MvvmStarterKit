object ViewAlbum: TViewAlbum
  Left = 0
  Top = 0
  ActiveControl = EditTitle
  BorderStyle = bsDialog
  Caption = 'Album'
  ClientHeight = 337
  ClientWidth = 486
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LabelTitle: TLabel
    Left = 16
    Top = 21
    Width = 20
    Height = 13
    Caption = 'Title'
  end
  object LabelArtist: TLabel
    Left = 16
    Top = 51
    Width = 26
    Height = 13
    Caption = 'Artist'
  end
  object LabelRecordLabel: TLabel
    Left = 16
    Top = 81
    Width = 62
    Height = 13
    Caption = 'Record Label'
  end
  object LabelCopyright: TLabel
    Left = 16
    Top = 111
    Width = 47
    Height = 13
    Caption = 'Copyright'
  end
  object LabelReleaseDate: TLabel
    Left = 16
    Top = 141
    Width = 64
    Height = 13
    Caption = 'Release Date'
  end
  object LabelNotes: TLabel
    Left = 16
    Top = 201
    Width = 28
    Height = 13
    Caption = 'Notes'
  end
  object LabelBackgroundColor: TLabel
    Left = 16
    Top = 171
    Width = 56
    Height = 13
    Caption = 'Background'
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 296
    Width = 486
    Height = 41
    Margins.Left = 4
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 4
    Padding.Bottom = 4
    TabOrder = 7
    ExplicitTop = 270
    object ButtonCancel: TButton
      Left = 384
      Top = 4
      Width = 98
      Height = 33
      Align = alRight
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object ButtonOK: TButton
      Left = 286
      Top = 4
      Width = 98
      Height = 33
      Align = alRight
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 1
    end
    object ButtonEditTracks: TButton
      Left = 4
      Top = 4
      Width = 98
      Height = 33
      Action = ActionEditTracks
      Align = alLeft
      TabOrder = 2
    end
  end
  object EditTitle: TEdit
    Left = 90
    Top = 18
    Width = 381
    Height = 21
    TabOrder = 0
  end
  object EditArtist: TEdit
    Left = 90
    Top = 48
    Width = 381
    Height = 21
    TabOrder = 1
  end
  object EditCopyright: TEdit
    Left = 90
    Top = 108
    Width = 381
    Height = 21
    TabOrder = 3
  end
  object EditRecordLabel: TEdit
    Left = 90
    Top = 78
    Width = 381
    Height = 21
    TabOrder = 2
  end
  object DateTimePickerReleaseDate: TDateTimePicker
    Left = 90
    Top = 138
    Width = 381
    Height = 21
    Date = 43107.410557685190000000
    Time = 43107.410557685190000000
    TabOrder = 4
  end
  object MemoNotes: TMemo
    Left = 90
    Top = 198
    Width = 381
    Height = 89
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object ColorBoxBackground: TColorBox
    Left = 90
    Top = 168
    Width = 381
    Height = 22
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames, cbCustomColors]
    TabOrder = 5
  end
  object ActionList: TActionList
    Left = 28
    Top = 204
    object ActionEditTracks: TAction
      Caption = 'Edit Tracks'
    end
  end
end
