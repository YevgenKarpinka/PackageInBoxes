page 50050 "Package Card"
{
    CaptionML = ENU = 'Package Card', RUS = 'Карточка Упаковки';
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
                field("Reg. Whse Pick No."; "Reg. Whse Pick No.")
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
                SubPageLink = "Package No." = field("No."),
                                "Sales Order No." = field("Sales Order No.");
                // UpdatePropagation = Both;
            }
            part(BoxLinesSubPage; "Box Lines Subpage")
            {
                ApplicationArea = All;
                Provider = BoxesSubPage;
                SubPageLink = "Box No." = field("No."),
                                "Sales Order No." = field("Sales Order No.");
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