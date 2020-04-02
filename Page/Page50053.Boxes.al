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
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Weight; Weight)
                {
                    ApplicationArea = All;
                }
                field(Length; Length)
                {
                    ApplicationArea = All;
                }
                field(Width; Width)
                {
                    ApplicationArea = All;
                }
                field(Height; Height)
                {
                    ApplicationArea = All;
                }
                field(Cubage; Cubage)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}