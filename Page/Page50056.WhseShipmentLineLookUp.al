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
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the item code of warehouse shipment that can be put in the box of the packaging document.',
                                RUS = 'Определяет код товара складской отгрузки который можно положить в коробку документа упаковки.';
                }
                field("Qty. to Ship"; "Qty. to Ship")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the quantity of item of warehouse shipment available for packaging in the box.',
                                RUS = 'Определяет количество товара складской отгрузки доступное для упаковки в коробку.';
                }
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of warehouse shipment that is available for packaging.',
                                RUS = 'Определяет номер складской отгрузки которая доступна для упаковки.';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the line number of the warehouse shipment that is available for packaging.',
                                RUS = 'Определяет номер строки складской отгрузки которая доступна для упаковки.';
                }
            }
        }
    }

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}