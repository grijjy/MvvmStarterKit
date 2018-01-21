object ViewTracks: TViewTracks
  Left = 0
  Top = 0
  Caption = 'Tracks'
  ClientHeight = 331
  ClientWidth = 609
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
  object Splitter: TSplitter
    Left = 283
    Top = 0
    Width = 5
    Height = 290
    Align = alRight
    Color = clBtnShadow
    ParentColor = False
    ResizeStyle = rsUpdate
    ExplicitLeft = 242
    ExplicitHeight = 336
  end
  object PanelTracks: TPanel
    Left = 0
    Top = 0
    Width = 283
    Height = 290
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 315
    object PanelAlbumsHeader: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 0
      Width = 279
      Height = 41
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = 'Albums'
      TabOrder = 0
      object SpeedButtonDeleteAlbum: TSpeedButton
        Left = 237
        Top = 0
        Width = 42
        Height = 41
        Action = ActionDeleteTrack
        Align = alRight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -27
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 204
      end
      object SpeedButtonAddAlbum: TSpeedButton
        Left = 195
        Top = 0
        Width = 42
        Height = 41
        Action = ActionAddTrack
        Align = alRight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -27
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 204
      end
    end
    object ListViewTracks: TListView
      Left = 0
      Top = 41
      Width = 283
      Height = 249
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = 'Name'
        end
        item
          Caption = 'Duration'
          Width = 75
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      ExplicitHeight = 274
    end
  end
  object PanelDetailContainer: TPanel
    Left = 288
    Top = 0
    Width = 321
    Height = 290
    Align = alRight
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    ExplicitHeight = 315
    object PanelDetails: TPanel
      Left = 0
      Top = 41
      Width = 321
      Height = 249
      Align = alClient
      BevelOuter = bvNone
      Padding.Left = 12
      Padding.Top = 4
      Padding.Right = 12
      Padding.Bottom = 12
      ParentBackground = False
      TabOrder = 0
      ExplicitHeight = 274
      object LabelName: TLabel
        Left = 12
        Top = 13
        Width = 20
        Height = 13
        Caption = 'Title'
      end
      object LabelTrackNumber: TLabel
        Left = 12
        Top = 43
        Width = 34
        Height = 13
        Caption = 'Track#'
      end
      object LabelDuration: TLabel
        Left = 12
        Top = 73
        Width = 41
        Height = 13
        Caption = 'Duration'
      end
      object LabelMinutes: TLabel
        Left = 170
        Top = 73
        Width = 16
        Height = 13
        Caption = 'Min'
      end
      object LabelSeconds: TLabel
        Left = 286
        Top = 73
        Width = 17
        Height = 13
        Caption = 'Sec'
      end
      object LabelGenres: TLabel
        Left = 12
        Top = 103
        Width = 20
        Height = 13
        Caption = 'Title'
      end
      object EditTrackNumber: TEdit
        Left = 86
        Top = 40
        Width = 203
        Height = 21
        TabOrder = 0
        Text = '0'
      end
      object EditName: TEdit
        Left = 86
        Top = 10
        Width = 219
        Height = 21
        TabOrder = 1
      end
      object UpDownTrackNumber: TUpDown
        Left = 289
        Top = 40
        Width = 16
        Height = 21
        Associate = EditTrackNumber
        TabOrder = 2
      end
      object EditDurationMinutes: TEdit
        Left = 86
        Top = 70
        Width = 64
        Height = 21
        TabOrder = 3
        Text = '0'
      end
      object UpDownDurationMinutes: TUpDown
        Left = 150
        Top = 70
        Width = 16
        Height = 21
        Associate = EditDurationMinutes
        TabOrder = 4
      end
      object EditDurationSeconds: TEdit
        Left = 204
        Top = 70
        Width = 64
        Height = 21
        TabOrder = 5
        Text = '0'
      end
      object UpDownDurationSeconds: TUpDown
        Left = 268
        Top = 70
        Width = 16
        Height = 21
        Associate = EditDurationSeconds
        TabOrder = 6
      end
      object MemoGenres: TMemo
        Left = 86
        Top = 100
        Width = 219
        Height = 65
        ScrollBars = ssVertical
        TabOrder = 7
        WordWrap = False
      end
    end
    object PanelDetailsHeader: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 0
      Width = 317
      Height = 41
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = 'Track Detauls'
      Padding.Left = 4
      Padding.Top = 4
      Padding.Right = 4
      Padding.Bottom = 4
      TabOrder = 1
    end
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 290
    Width = 609
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
    TabOrder = 2
    ExplicitTop = 315
    object ButtonCancel: TButton
      Left = 507
      Top = 4
      Width = 98
      Height = 33
      Align = alRight
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object ButtonOK: TButton
      Left = 409
      Top = 4
      Width = 98
      Height = 33
      Align = alRight
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 1
    end
  end
  object ActionList: TActionList
    Left = 24
    Top = 80
    object ActionAddTrack: TAction
      Caption = '+'
      Hint = 'Add track'
    end
    object ActionDeleteTrack: TAction
      Caption = '-'
      Hint = 'Delete track'
    end
  end
end
