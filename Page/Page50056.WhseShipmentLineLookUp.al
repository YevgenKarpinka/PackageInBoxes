page 50056 "Whse. Shipment Item Lookup"
{
    PageType = List;
    CaptionML = ENU = 'Whse. Shipment Line Lookup', RUS = 'Выбор Товара складской отгрузки';
    Editable = false;
    ApplicationArea = Warehouse;
    UsageCategory = Lists;
    SourceTable = "Warehouse Shipment Line";

    layout
    {
        area(Content)
        {
            repeater(repeaterName)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; PackageBoxMgt.GetRemainingItemQuantityInShipment("No.", "Item No.", "Line No."))
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
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
            // action(ActionName)
            // {
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     begin

            //     end;
            // }
        }
    }

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}