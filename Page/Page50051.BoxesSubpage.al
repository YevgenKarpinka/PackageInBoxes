page 50051 "Boxes Subpage"
{
    CaptionML = ENU = 'Boxes', RUS = 'Коробки';
    PageType = ListPlus;
    ApplicationArea = All;
    UsageCategory = Administration;
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
            part(BoxLinesSubPage; "Box Lines Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Box No." = field("No."), "Warehouse Shipment No." = field("Warehouse Shipment No."), "Warehouse Pick No." = field("Warehouse Pick No.");
                // UpdatePropagation = Both;
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