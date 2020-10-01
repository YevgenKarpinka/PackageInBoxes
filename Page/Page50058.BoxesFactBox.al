page 50058 "Boxes FactBox"
{
    CaptionML = ENU = 'Boxes', RUS = 'Коробки';
    PageType = ListPart;
    ApplicationArea = Warehouse;
    UsageCategory = History;
    SourceTable = "Box Header";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date the box document was created.',
                                RUS = 'Определяет дату создания документа коробка.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies status the box document.',
                                RUS = 'Определяет статус документа коробка.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies external document number the box document.',
                                RUS = 'Определяет внешний номер документа коробка.';
                }
                field("Box Code"; Rec."Box Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies a box code from a box reference.',
                                RUS = 'Определяет код коробки из справочника коробки.';
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies a gross weight of the box.',
                                RUS = 'Определяет вес брутто коробки.';
                }
                field(QuantityInBox; PackageBoxMgt.GetQuantityInBox(Rec."No."))
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Quantity in Box', RUS = 'Количество в коробке';
                    ToolTipML = ENU = 'Specifies the quantity of item that lies in the box.',
                                RUS = 'Определяет количество товара который лежит в коробке.';
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery..',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
            }

        }
    }

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}