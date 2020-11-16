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

                field("No."; Rec."No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Sales Order No."; Rec."Sales Order No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the sales order number on the basis of which the packaging document was created',
                                RUS = 'Определяет номер заказа продажи на основании которого был создан документ упаковки.';
                }
                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time the box document was created.',
                                RUS = 'Определяет дату и время создания документа коробки.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies status the box document.',
                                RUS = 'Определяет статус документа коробки.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the external document number.',
                                RUS = 'Определяет номер внешнего документа.';
                }
                field("Box Code"; Rec."Box Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the box code according to the directory.',
                                RUS = 'Определяет код коробки согласно справочника.';
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies gross weight of the box.',
                                RUS = 'Определяет вес брутто коробки.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies unit of measure of the gross weight of the box.',
                                RUS = 'Определяет единицу измерения веса брутто коробки.';
                }
                field("Quantity In Box"; PackageBoxMgt.GetQuantityInBox(Rec."No."))
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
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery.',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
                field("Shipping Agent"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the Shipping Agent of the box.',
                                RUS = 'Определяет агента доставки для коробки.';
                }
                field("Shipping Services"; Rec."Shipping Services Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the Shipping Services of the box.',
                                RUS = 'Определяет услугу доставки для коробки.';
                }
                field("Shipment Cost"; Rec."Shipment Cost")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the Shipment Cost of the box.',
                                RUS = 'Определяет стоимость доставки коробки.';
                }
                field("Other Cost"; Rec."Other Cost")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the Other Cost of the box for delivery.',
                                RUS = 'Определяет иные затраты по доставке коробки.';
                }
                field("ShipStation Status"; Rec."ShipStation Status")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTipML = ENU = 'Specifies the ShipStation Status of the box.',
                                RUS = 'Определяет ShipStation статус коробки.';
                }
                field("ShipStation Shipment ID"; Rec."ShipStation Shipment ID")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTipML = ENU = 'Specifies the ShipStation Shipment ID of the box.',
                                RUS = 'Определяет ShipStation ID отгрузки коробки.';
                }
                field("ShipStation Order ID"; Rec."ShipStation Order ID")
                {
                    ApplicationArea = Warehouse;
                    Importance = Additional;
                    ToolTipML = ENU = 'Specifies the ShipStation Order ID of the box.',
                                RUS = 'Определяет ShipStation ID заказа коробки.';
                }
                field("ShipStation Order Key"; Rec."ShipStation Order Key")
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
                    PackageBoxMgt.CloseBox(Rec."Package No.", Rec."No.");
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
                    PackageBoxMgt.OpenBox(Rec."Package No.", Rec."No.");
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
                    PackageBoxMgt.AssemblyBox(Rec."Package No.", Rec."No.");
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
                    BoxHeader.SetCurrentKey(Status, "ShipStation Shipment ID");
                    BoxHeader.SetRange(Status, BoxHeader.Status::Closed);
                    BoxHeader.SetFilter("ShipStation Shipment ID", '=%1', '');
                    if BoxHeader.FindSet(false, false) then
                        repeat
                            if PackageBoxMgt.GetQuantityInBox(BoxHeader."No.") > 0 then
                                PackageBoxMgt.SentBoxInShipStation(BoxHeader."Package No.", BoxHeader."No.");
                        until BoxHeader.Next() = 0;
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
                    BoxHeader.SetCurrentKey(Status, "ShipStation Order Key", "ShipStation Shipment ID");
                    BoxHeader.SetRange(Status, BoxHeader.Status::Closed);
                    BoxHeader.SetFilter("ShipStation Order Key", '<>%1', '');
                    BoxHeader.SetFilter("ShipStation Shipment ID", '=%1', '');
                    if BoxHeader.FindSet(false, false) then begin
                        repeat
                            PackageBoxMgt.CreateLabel2OrderInShipStation(BoxHeader."Package No.", BoxHeader."No.");
                        until BoxHeader.Next() = 0;
                        PackageBoxMgt.CreateDeliverySalesLineFromPackage(BoxHeader."Sales Order No.");
                        Message(lblLabelsCreated);
                    end else begin
                        Error(errNoBoxesFoundForCreatingLabel);
                    end;
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
                    BoxHeader.SetCurrentKey("ShipStation Shipment ID");
                    BoxHeader.SetFilter("ShipStation Shipment ID", '<>%1', '');
                    if BoxHeader.FindSet(false, false) then begin
                        repeat
                            PackageBoxMgt.VoidLabel2OrderInShipStation(BoxHeader."Package No.", BoxHeader."No.");
                        until BoxHeader.Next() = 0;
                        PackageBoxMgt.CreateDeliverySalesLineFromPackage(BoxHeader."Sales Order No.");
                        Message(lblLabelVoided);
                    end else begin
                        Error(errNoLabelForVoid);
                    end;

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
        errNoBoxesFoundForCreatingLabel: TextConst ENU = 'No boxes found for creating label.',
                                                    RUS = 'Коробок для создания бирок не найдено.';
        errNoLabelForVoid: TextConst ENU = 'No label found for void.',
                                    RUS = 'Бирки для аннулирования не найдено.';

}