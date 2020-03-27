page 50051 "Boxes Subpage"
{
    CaptionML = ENU = 'Boxes Subpage';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Box Header";
    // SourceTableView = where("Shipment Cost" = filter('<>0'));
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