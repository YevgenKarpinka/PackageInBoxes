page 50052 "Box Lines Subpage"
{
    CaptionML = ENU = 'Items in Box', RUS = 'Товары в коробке';
    PageType = ListPart;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Box Line";
    AutoSplitKey = true;
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("Item No."; "Item No.")
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
        SalesOrderNo: Code[20];

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if xRec."Sales Order No." = '' then
            "Sales Order No." := SalesOrderNo;
    end;

    procedure SetUpSalesOrderNo(locSalesOrderNo: Code[20])
    begin
        SalesOrderNo := locSalesOrderNo;
    end;
}