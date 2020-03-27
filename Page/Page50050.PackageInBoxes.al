page 50050 "Package In Boxes"
{
    CaptionML = ENU = 'Package In Boxes', RUS = 'Упаковка в коробки';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "Package Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = All;
                }
                field("Create User ID"; "Create User ID")
                {
                    ApplicationArea = All;
                }
                field("Last Modified Date"; "Last Modified Date")
                {
                    ApplicationArea = All;
                }
                field("Last Modified User ID"; "Last Modified User ID")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Pick No."; "Warehouse Pick No.")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Shipment No."; "Warehouse Shipment No.")
                {
                    ApplicationArea = All;
                }
            }
            part(BoxesSubPage; "Boxes Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Package No." = field("No."), "Warehouse Shipment No." = field("Warehouse Shipment No."), "Warehouse Pick No." = field("Warehouse Pick No.");
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
}