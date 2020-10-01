page 50052 "Box Lines Subpage"
{
    CaptionML = ENU = 'Items in Box', RUS = 'Товары в коробке';
    PageType = ListPart;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Box Line";
    AutoSplitKey = true;
    DelayedInsert = true;
    MultipleNewLines = true;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the item code of warehouse shipment that lies in the box.',
                                RUS = 'Определяет код товара складской отгрузки который лежит в коробке.';
                }
                field("Quantity in Box"; Rec."Quantity in Box")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the quantity of item in the warehouse shipment that lies in the box.',
                                RUS = 'Определяет количество товара складской отгрузки который лежит в коробке.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Unpacked Quantity"; PackageBoxMgt.GetRemainingItemQuantityInShipment(Rec."Shipment No.", Rec."Item No.", Rec."Shipment Line No."))
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Unpacked Quantity', RUS = 'Не упакованное количество';
                    ToolTipML = ENU = 'Specifies the unpacked quantity of the items of the warehouse shipment to be put in the box of the packaging document.',
                                RUS = 'Определяет не упакованное количество товара складской отгрузки который нужно положить в коробку документа упаковки.';
                }
                field("Shipment No."; Rec."Shipment No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of warehouse shipment items that are in the box.',
                                RUS = 'Определяет номер складской отгрузки товар который лежит в коробке.';
                }
                field("Shipment Line No."; Rec."Shipment Line No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the line number of the warehouse shipment of the items with which lies in the box.',
                                RUS = 'Определяет номер строки складской отгрузки товар с который лежит в коробке.';
                }
                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time the box document was created.',
                                RUS = 'Определяет дату и время создания документа коробка.';
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}