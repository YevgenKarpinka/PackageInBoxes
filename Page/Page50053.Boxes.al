page 50053 "Boxes"
{
    CaptionML = ENU = 'Boxes', RUS = 'Коробки';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Box;

    layout
    {
        area(Content)
        {
            repeater(repeaterName)
            {
                field("Box Code"; Rec."Box Code")
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies the user box code of the directory box.',
                                RUS = 'Определяет указанный пользователем код коробки справочника.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a description of the box.',
                                RUS = 'Определяет описание коробки.';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a weight of the box.',
                                RUS = 'Определяет вес коробки.';
                }
                field(Length; Rec.Length)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a length of the box.',
                                RUS = 'Определяет длинну коробки.';
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a width of the box.',
                                RUS = 'Определяет ширину коробки.';
                }
                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a height of the box.',
                                RUS = 'Определяет высоту коробки.';
                }
                field(Cubage; Rec.Cubage)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a cubage of the box.',
                                RUS = 'Определяет объем коробки.';
                }
            }
        }
    }
}