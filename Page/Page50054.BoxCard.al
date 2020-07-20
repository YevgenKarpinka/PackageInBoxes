page 50054 "Box Card"
{
    CaptionML = ENU = 'Box Card', RUS = 'Карточка Коробки';
    PageType = Card;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Box Header";
    InsertAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = Status = Status::Open;

                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the sales order number on the basis of which the packaging document was created',
                                RUS = 'Определяет номер заказа продажи на основании которого был создан документ упаковки.';
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time the box document was created.',
                                RUS = 'Определяет дату и время создания документа коробки.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies status the box document.',
                                RUS = 'Определяет статус документа коробки.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the external document number.',
                                RUS = 'Определяет номер внешнего документа.';
                }
                field("Box Code"; "Box Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the box code according to the directory.',
                                RUS = 'Определяет код коробки согласно справочника.';
                }
                field("Gross Weight"; "Gross Weight")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies gross weight of the box.',
                                RUS = 'Определяет вес брутто коробки.';
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies unit of measure of the gross weight of the box.',
                                RUS = 'Определяет единицу измерения веса брутто коробки.';
                }
                field("Quantity In Box"; PackageBoxMgt.GetQuantityInBox("No."))
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the quantity of units of item that lies in the box.',
                                RUS = 'Определяет количество единиц товара который лежит в коробке.';
                }
            }
            part(BoxLinesSubPage; "Box Lines Subpage")
            {
                ApplicationArea = Warehouse;
                SubPageLink = "Box No." = field("No.");
                UpdatePropagation = Both;
                Editable = Status = Status::Open;
            }
            group(ShipStation)
            {
                Editable = Status = Status::Open;
                field("Tracking No."; "Tracking No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery.',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
                field("Shipping Agent"; "Shipping Agent Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the Shipping Agent of the box.',
                                RUS = 'Определяет агента доставки для коробки.';
                }
                field("Shipping Services"; "Shipping Services Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the Shipping Services of the box.',
                                RUS = 'Определяет услугу доставки для коробки.';
                }
                field("Shipment Cost"; "Shipment Cost")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the Shipment Cost of the box.',
                                RUS = 'Определяет стоимость доставки коробки.';
                }
                field("Other Cost"; "Other Cost")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the Other Cost of the box for delivery.',
                                RUS = 'Определяет иные затраты по доставке коробки.';
                }
                field("ShipStation Status"; "ShipStation Status")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTipML = ENU = 'Specifies the ShipStation Status of the box.',
                                RUS = 'Определяет ShipStation статус коробки.';
                }
                field("ShipStation Shipment ID"; "ShipStation Shipment ID")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTipML = ENU = 'Specifies the ShipStation Shipment ID of the box.',
                                RUS = 'Определяет ShipStation ID отгрузки коробки.';
                }
                field("ShipStation Order ID"; "ShipStation Order ID")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTipML = ENU = 'Specifies the ShipStation Order ID of the box.',
                                RUS = 'Определяет ShipStation ID заказа коробки.';
                }
                field("ShipStation Order Key"; "ShipStation Order Key")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTipML = ENU = 'Specifies the ShipStation Order Key of the box.',
                                RUS = 'Определяет ShipStation ключ заказа коробки.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Close)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Close', RUS = 'Закрыть';
                ToolTipML = ENU = 'Close the document of the box to the next stage of processing. You must reopen the document before you can make changes to it.',
                            RUS = 'Закрытие документа коробки на следующий этап обработки. Необходимо заново открыть документ, чтобы в него можно было вносить изменения.';
                Enabled = Status = Status::Open;
                Image = ItemLines;

                trigger OnAction()
                begin
                    PackageBoxMgt.CloseBox("Package No.", "No.");
                end;
            }
            action(ReOpen)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Reopen', RUS = 'Открыть';
                ToolTipML = ENU = 'Reopen the document of the box to change.',
                            RUS = 'Повторное открытие документа коробки для его изменения.';
                Enabled = Status = Status::Closed;
                Image = RefreshLines;

                trigger OnAction()
                begin
                    PackageBoxMgt.OpenBox("Package No.", "No.");
                end;
            }
            action(AssemblyBox)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Assembly', RUS = 'Собрать';
                ToolTipML = ENU = 'Assembly in the box all the items remaining on the table.',
                            RUS = 'Собрать в коробку весь оставшийся на столе товар.';
                Enabled = Status = Status::Open;
                Image = GetActionMessages;

                trigger OnAction()
                begin
                    PackageBoxMgt.AssemblyBox("Package No.", "No.");
                end;
            }

            action("Create Orders")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Create Order', RUS = 'Создать Заказ';
                ToolTipML = ENU = 'Send to the ShipStation of the box document.',
                                RUS = 'Отправить в ShipStation документ коробки.';
                Image = CreateDocuments;
                Visible = (Status = Status::Closed) and ("ShipStation Shipment ID" = '');

                trigger OnAction()
                begin
                    BoxHeader.Reset();
                    CurrPage.SetSelectionFilter(BoxHeader);
                    with BoxHeader do begin
                        SetCurrentKey(Status, "ShipStation Shipment ID");
                        SetRange(Status, Status::Closed);
                        SetFilter("ShipStation Shipment ID", '=%1', '');
                        if FindSet(false, false) then
                            repeat
                                if PackageBoxMgt.GetQuantityInBox("No.") > 0 then
                                    PackageBoxMgt.SentBoxInShipStation("Package No.", BoxHeader."No.");
                            until Next() = 0;
                    end;
                    Message(lblOrdersCreated);
                end;
            }
            action("Create Labels")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Create Label', RUS = 'Создать бирку';
                ToolTipML = ENU = 'Create Label to the box document.',
                                RUS = 'Создать бирку для коробки.';
                Image = PrintReport;
                Visible = ("ShipStation Order Key" <> '')
                and ("ShipStation Shipment ID" = '')
                and (Status = Status::Closed);

                trigger OnAction()
                begin
                    BoxHeader.Reset();
                    CurrPage.SetSelectionFilter(BoxHeader);
                    with BoxHeader do begin
                        SetCurrentKey(Status, "ShipStation Order Key", "ShipStation Shipment ID");
                        SetRange(Status, Status::Closed);
                        SetFilter("ShipStation Order Key", '<>%1', '');
                        SetFilter("ShipStation Shipment ID", '=%1', '');
                        if FindSet(false, false) then
                            repeat
                                PackageBoxMgt.CreateLabel2OrderInShipStation("Package No.", "No.");
                            until Next() = 0;
                        PackageBoxMgt.CreateDeliverySalesLineFromPackage("Sales Order No.");
                    end;
                    Message(lblLabelsCreated);
                end;
            }
            action("Void Labels")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Void Label', RUS = 'Отменить бирку';
                ToolTipML = ENU = 'Void Label to the box document.',
                                RUS = 'Отменить бирку для коробоки.';
                Image = VoidCreditCard;
                Visible = "ShipStation Shipment ID" <> '';

                trigger OnAction()
                begin
                    BoxHeader.Reset();
                    CurrPage.SetSelectionFilter(BoxHeader);
                    with BoxHeader do begin
                        SetCurrentKey("ShipStation Shipment ID");
                        SetFilter("ShipStation Shipment ID", '<>%1', '');
                        if FindSet(false, false) then
                            repeat
                                PackageBoxMgt.VoidLabel2OrderInShipStation("Package No.", "No.");
                            until Next() = 0;
                        PackageBoxMgt.CreateDeliverySalesLineFromPackage("Sales Order No.");
                    end;
                    Message(lblLabelVoided);
                end;
            }
        }
    }

    var
        PackageHeader: Record "Package Header";
        BoxHeader: Record "Box Header";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        lblOrdersCreated: TextConst ENU = 'Orders Created in ShipStation!',
                                    RUS = 'Заказы в ShipStation созданы!';
        lblLabelsCreated: TextConst ENU = 'Labels Created and Attached to Warehouse Shipments!',
                                    RUS = 'Бирки созданы и прикреплены к Отгрузкам!';
        lblLabelVoided: TextConst ENU = 'Label Voided!',
                                    RUS = 'Бирка отменена!';
}