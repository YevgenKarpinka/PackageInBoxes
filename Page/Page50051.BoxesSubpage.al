page 50051 "Boxes Subpage"
{
    CaptionML = ENU = 'Boxes', RUS = 'Коробки';
    PageType = ListPart;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Box Header";
    AccessByPermission = tabledata "Box Header" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Warehouse;
                }
                field(Code; Code)
                {
                    ApplicationArea = Warehouse;
                }
                field(Weight; Weight)
                {
                    ApplicationArea = Warehouse;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                }
                field("Quantity in Box"; "Quantity in Box")
                {
                    ApplicationArea = Warehouse;
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
                ApplicationArea = Warehouse;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}