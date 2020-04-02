page 50050 "Package Card"
{
    CaptionML = ENU = 'Package Card', RUS = 'Карточка Упаковки';
    PageType = Card;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Package Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = false;

                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Create User ID"; "Create User ID")
                {
                    ApplicationArea = Warehouse;
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = Warehouse;
                }
                field("Last Modified User ID"; "Last Modified User ID")
                {
                    ApplicationArea = Warehouse;
                }
                field("Last Modified Date"; "Last Modified Date")
                {
                    ApplicationArea = Warehouse;
                }
            }
            part(BoxesSubPage; "Boxes Subpage")
            {
                ApplicationArea = Warehouse;
                SubPageLink = "Package No." = field("No."),
                              "Sales Order No." = field("Sales Order No.");
                UpdatePropagation = Both;
            }
            part(BoxLinesSubPage; "Box Lines Subpage")
            {
                ApplicationArea = Warehouse;
                Provider = BoxesSubPage;
                SubPageLink = "Box No." = field("No."),
                              "Sales Order No." = field("Sales Order No.");
                UpdatePropagation = Both;
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

    trigger OnOpenPage()
    begin
        CurrPage.BoxLinesSubPage.Page.SetUpSalesOrderNo("Sales Order No.");
    end;
}