object DebugForm: TDebugForm
  Left = 82
  Top = 95
  Width = 661
  Height = 498
  Caption = 'PASCALice debug'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 40
    Top = 28
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 432
    Top = 332
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object Label3: TLabel
    Left = 432
    Top = 364
    Width = 30
    Height = 13
    Caption = 'Value:'
  end
  object Edit1: TEdit
    Left = 148
    Top = 68
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Memo1: TMemo
    Left = 8
    Top = 120
    Width = 345
    Height = 213
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Button3: TButton
    Left = 40
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Memory'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 280
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Match'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 212
    Top = 20
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 4
    OnClick = Button5Click
  end
  object edName: TEdit
    Left = 468
    Top = 328
    Width = 157
    Height = 21
    TabOrder = 5
  end
  object edValue: TEdit
    Left = 468
    Top = 360
    Width = 157
    Height = 21
    TabOrder = 6
  end
  object Button2: TButton
    Left = 444
    Top = 396
    Width = 75
    Height = 25
    Caption = 'Set'
    TabOrder = 7
    OnClick = Button2Click
  end
  object Button6: TButton
    Left = 540
    Top = 396
    Width = 75
    Height = 25
    Caption = 'Get'
    TabOrder = 8
    OnClick = Button6Click
  end
  object ListBox1: TListBox
    Left = 424
    Top = 48
    Width = 217
    Height = 269
    ItemHeight = 13
    TabOrder = 9
  end
  object Button7: TButton
    Left = 444
    Top = 436
    Width = 75
    Height = 25
    Caption = 'SetProp'
    TabOrder = 10
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 544
    Top = 436
    Width = 75
    Height = 25
    Caption = 'GetProp'
    TabOrder = 11
    OnClick = Button8Click
  end
end
