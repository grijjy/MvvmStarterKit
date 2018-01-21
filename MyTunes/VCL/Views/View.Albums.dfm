object ViewAlbums: TViewAlbums
  Left = 0
  Top = 0
  Caption = 'MyTunes - VCL Edition'
  ClientHeight = 480
  ClientWidth = 736
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 341
    Top = 0
    Width = 5
    Height = 480
    Align = alRight
    Color = clBtnShadow
    ParentColor = False
    ResizeStyle = rsUpdate
    ExplicitLeft = 343
  end
  object PanelAlbums: TPanel
    Left = 0
    Top = 0
    Width = 341
    Height = 480
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PanelAlbumsHeader: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 0
      Width = 337
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
        Left = 295
        Top = 0
        Width = 42
        Height = 41
        Action = ActionDeleteAlbum
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
        Left = 253
        Top = 0
        Width = 42
        Height = 41
        Action = ActionAddAlbum
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
    object ListViewAlbums: TListView
      Left = 0
      Top = 41
      Width = 341
      Height = 439
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = 'Title'
        end
        item
          Caption = 'Artist'
          Width = 150
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      OnDeletion = ListViewAlbumsDeletion
      OnSelectItem = ListViewAlbumsSelectItem
    end
  end
  object PanelDetails: TPanel
    Left = 346
    Top = 0
    Width = 390
    Height = 480
    Align = alRight
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    object PanelBackground: TPanel
      Left = 0
      Top = 41
      Width = 390
      Height = 439
      Align = alClient
      BevelOuter = bvNone
      Padding.Left = 12
      Padding.Top = 4
      Padding.Right = 12
      Padding.Bottom = 12
      ParentBackground = False
      TabOrder = 0
      object ImageAlbumCover: TImage
        AlignWithMargins = True
        Left = 12
        Top = 54
        Width = 366
        Height = 245
        Margins.Left = 0
        Margins.Top = 4
        Margins.Right = 0
        Margins.Bottom = 4
        Align = alClient
        Center = True
        Proportional = True
        Stretch = True
        ExplicitLeft = 144
        ExplicitTop = 172
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
      object LabelArtist: TLabel
        Left = 12
        Top = 29
        Width = 366
        Height = 21
        Align = alTop
        Caption = 'Artist'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ExplicitWidth = 37
      end
      object LabelTitle: TLabel
        Left = 12
        Top = 4
        Width = 366
        Height = 25
        Align = alTop
        Caption = 'Title'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ExplicitWidth = 36
      end
      object ListViewTracks: TListView
        Left = 12
        Top = 303
        Width = 366
        Height = 124
        Align = alBottom
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
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object PanelDetailsHeader: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 0
      Width = 386
      Height = 41
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = 'Album Details'
      Padding.Left = 4
      Padding.Top = 4
      Padding.Right = 4
      Padding.Bottom = 4
      TabOrder = 1
      object ButtonEditAlbum: TButton
        Left = 284
        Top = 4
        Width = 98
        Height = 33
        Action = ActionEditAlbum
        Align = alRight
        TabOrder = 0
      end
    end
  end
  object ActionList: TActionList
    Left = 24
    Top = 80
    object ActionAddAlbum: TAction
      Caption = '+'
      Hint = 'Add album'
    end
    object ActionDeleteAlbum: TAction
      Caption = '-'
      Hint = 'Delete album'
    end
    object ActionEditAlbum: TAction
      Caption = 'Edit Album'
    end
  end
end
