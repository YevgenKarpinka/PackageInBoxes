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
                field("Quantity In Box"; PackageBoxMgt.GetQuantityInBox("No."))
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the quantity of units of item that lies in the box.',
                                RUS = 'Определяет количество единиц товара который лежит в коробке.';
                }
                field("Tracking No."; "Tracking No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery..',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery..',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
                field("Shipping Services Code"; "Shipping Services Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery..',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
                field("Shipment Cost"; "Shipment Cost")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery..',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
                field("Other Cost"; "Other Cost")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery..',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
            }
            part(BoxLinesSubPage; "Box Lines Subpage")
            {
                ApplicationArea = Warehouse;
                SubPageLink = "Box No." = field("No.");
                UpdatePropagation = Both;
                Editable = Status = Status::Open;
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
                Enabled = Status = Status::Close;
                Image = RefreshLines;

                trigger OnAction()
                begin
                    PackageBoxMgt.OpenBox("Package No.", "No.");
                    // PackageHeader.Get("Package No.");
                    // if PackageHeader.Status = PackageHeader.Status::UnRegistered then
                    //     if Status = Status::Close then begin
                    //         Status := Status::Open;
                    //         Modify(true);
                    //     end;
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
        }
    }

    var
        PackageHeader: Record "Package Header";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}