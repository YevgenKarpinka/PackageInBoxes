page 50052 "Box Lines Subpage"
{
    CaptionML = ENU = 'Box Lines Subpage', RUS = 'Содержимое коробки';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Box Line";
    AccessByPermission = tabledata "Box Line" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field("Quantity in Box"; "Quantity in Box")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}