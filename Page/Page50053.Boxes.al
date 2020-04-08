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
                field("Box Code"; "Box Code")
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies the user box code of the directory box.',
                                RUS = 'Определяет указанный пользователем код коробки справочника.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a description of the box.',
                                RUS = 'Определяет описание коробки.';
                }
                field(Weight; Weight)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a weight of the box.',
                                RUS = 'Определяет вес коробки.';
                }
                field(Length; Length)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a length of the box.',
                                RUS = 'Определяет длинну коробки.';
                }
                field(Width; Width)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a width of the box.',
                                RUS = 'Определяет ширину коробки.';
                }
                field(Height; Height)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a height of the box.',
                                RUS = 'Определяет высоту коробки.';
                }
                field(Cubage; Cubage)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU = 'Specifies a cubage of the box.',
                                RUS = 'Определяет объем коробки.';
                }
            }
        }
    }
}