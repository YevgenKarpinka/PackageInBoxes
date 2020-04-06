page 50055 "Box Lines FactBox"
{
    CaptionML = ENU = 'Items in Box', RUS = 'Товары в коробке';
    PageType = ListPart;
    ApplicationArea = Warehouse;
    UsageCategory = History;
    SourceTable = "Box Line";
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;

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
                field("Quantity in Box"; "Quantity in Box")
                {
                    ApplicationArea = Warehouse;
                }
                field("Remaining Quantity"; PackageBoxMgt.GetRemainingItemQuantityInOrder("Sales Order No.", "Item No."))
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Remaining Quantity', RUS = 'Количество для упаковки';
                }
            }
        }
    }
    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}