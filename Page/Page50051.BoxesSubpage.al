page 50051 "Boxes Subpage"
{
    CaptionML = ENU = 'Boxes', RUS = 'Коробки';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "Box Header";
    AccessByPermission = tabledata "Box Header" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Weight; Weight)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Quantity in Box"; "Quantity in Box")
                {
                    ApplicationArea = All;
                    Editable = false;
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