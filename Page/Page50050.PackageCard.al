page 50050 "Package Card"
{
    CaptionML = ENU = 'Package Card', RUS = 'Карточка Упаковки';
    SourceTable = "Package Header";
    RefreshOnActivate = true;
    InsertAllowed = false;
    PageType = Document;
    DeleteAllowed = false;

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
                    ToolTipML = ENU = 'Specifies the sales order number on the basis of which the packaging document was created',
                                RUS = 'Определяет номер заказа продажи на основании которого был создан документ упаковки.';
                }
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Create User ID"; "Create User ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the user id that created the packaging document.',
                                RUS = 'Определяет код пользователя который создал документ упаковки.';
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time the packaging document was created.',
                                RUS = 'Определяет дату и время создания документа упаковки.';
                }
                field("Last Modified User ID"; "Last Modified User ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the user id that last modified the packaging document.',
                                RUS = 'Определяет код пользователя который последним изменил документ упаковки.';
                }
                field("Last Modified Date"; "Last Modified Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time of the last modification of the packaging document.',
                                RUS = 'Определяет дату и время последниего изменения документа упаковки.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies status the packaging document.',
                                RUS = 'Определяет статус документа упаковки.';
                }
            }
            part(BoxesSubPage; "Boxes Subpage")
            {
                ApplicationArea = Warehouse;
                SubPageLink = "Package No." = field("No.");
                UpdatePropagation = Both;
                Editable = Status = Status::Unregistered;
            }
        }
        area(FactBoxes)
        {
            part(BoxLineFactBox; "Box Lines FactBox")
            {
                ApplicationArea = Warehouse;
                Provider = BoxesSubPage;
                SubPageLink = "Box No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Package)
            {
                CaptionML = ENU = 'Package', RUS = 'Упаковка';

                action(Register)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Register', RUS = 'Зарегистрировать';
                    ToolTipML = ENU = 'Register package document to the next stage of processing. You must unregister the document before you can make changes to it.',
                            RUS = 'Зарегистрировать документов упаковки на следующий этап обработки. Необходимо отменить регистрацию документа, чтобы в него можно было вносить изменения.';
                    Image = RegisterPick;

                    trigger OnAction()
                    begin
                        PackageBoxMgt.RegisterPackage("No.");
                    end;
                }
                action(Unregistered)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Unregister', RUS = 'Отменить регистрацию';
                    ToolTipML = ENU = 'Unregister package document to change.',
                            RUS = 'Отменить регистрацию документа упаковки для изменения.';
                    Enabled = Status = Status::Registered;
                    Image = Undo;

                    trigger OnAction()
                    begin
                        PackageBoxMgt.UnregisterPackage("No.");
                    end;
                }
                action("Print Packing Slip")
                {
                    ApplicationArea = All;
                    Image = PurchaseInvoice;
                    CaptionML = ENU = 'Print Packing Slip', RUS = 'Печать упаковочного листа';

                    trigger OnAction()
                    var
                        PackageHeader: Record "Package Header";
                        salesHeader: Record "Sales Header";
                    begin
                        CurrPage.SetSelectionFilter(PackageHeader);
                        Report.Run(Report::"Packing Slip", true, false, PackageHeader);
                    end;
                }
            }
            group(Boxes)
            {
                CaptionML = ENU = 'Boxes', RUS = 'Коробки';

                action(CloseAll)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Close All', RUS = 'Закрыть Все';
                    ToolTipML = ENU = 'Close all of the box document to the next stage of processing. You must reopen the document before you can make changes to it.',
                            RUS = 'Закрытие всех документов коробки на следующий этап обработки. Необходимо заново открыть документ, чтобы в него можно было вносить изменения.';
                    Enabled = Status = Status::Unregistered;
                    Image = ItemLines;

                    trigger OnAction()
                    var
                        BoxHeader: Record "Box Header";
                    begin
                        PackageBoxMgt.CloseAllBoxes("No.");
                    end;
                }
                action(ReOpenAll)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Reopen All', RUS = 'Открыть Все';
                    ToolTipML = ENU = 'Reopen all the document of the box to change.',
                            RUS = 'Повторное открытие всех документа коробки для их изменения.';
                    Enabled = Status = Status::Unregistered;
                    Image = RefreshLines;

                    trigger OnAction()
                    begin
                        PackageBoxMgt.ReOpenAllBoxes("No.");
                    end;
                }
                action(DeleteEmptyBoxes)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Delete Empty Boxes', RUS = 'Удалить пустые коробки';
                    ToolTipML = ENU = 'Delete empty box documents.',
                            RUS = 'Удаление пустых документов коробки.';
                    Enabled = Status = Status::Unregistered;
                    Image = Delete;

                    trigger OnAction()
                    begin
                        PackageBoxMgt.DeleteEmptyBoxes("No.");
                    end;
                }
                action(DeleteEmptyLines)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Delete Empty Lines', RUS = 'Удалить пустые строки';
                    ToolTipML = ENU = 'Delete blank lines in box documents.',
                            RUS = 'Удаление пустых строк в документах коробки.';
                    Enabled = Status = Status::Unregistered;
                    Image = DeleteRow;

                    trigger OnAction()
                    begin
                        PackageBoxMgt.DeleteEmptyLinesByPackag(PackageHeader."No.");
                    end;
                }
            }
            group(actionShipStation)
            {
                CaptionML = ENU = 'ShipStation', RUS = 'ShipStation';
                Image = ReleaseShipment;

                action("Create Orders")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Orders', RUS = 'Создать Заказы';
                    ToolTipML = ENU = 'Send to the ShipStation all of the box document.',
                                RUS = 'Отправить в ShipStation все документы коробки.';
                    Image = CreateDocuments;
                    // Visible = (Status = Status::Released) and ("ShipStation Order Key" = '');

                    trigger OnAction()
                    begin
                        PackageHeader.Reset();
                        BoxHeader.Reset();
                        CurrPage.SetSelectionFilter(PackageHeader);
                        if PackageHeader.FindSet(false, false) then
                            repeat
                                with BoxHeader do begin
                                    SetCurrentKey(Status, "ShipStation Order ID");
                                    SetRange(Status, Status::Close);
                                    SetFilter("ShipStation Order ID", '=%1', '');
                                    if FindSet(false, false) then
                                        repeat
                                            PackageBoxMgt.SentBoxInShipStation("Package No.", BoxHeader."No.");
                                        until Next() = 0;
                                end;
                            until PackageHeader.Next() = 0;
                        Message(lblOrdersCreated);
                    end;
                }
                action("Create Labels")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Labels', RUS = 'Создать бирки';
                    ToolTipML = ENU = 'Create Labels all of the box document.',
                                RUS = 'Создать бирки для всех коробок.';
                    Image = PrintReport;
                    // Visible = "ShipStation Order Key" <> '';

                    trigger OnAction()
                    begin
                        PackageHeader.Reset();
                        BoxHeader.Reset();
                        CurrPage.SetSelectionFilter(PackageHeader);
                        if PackageHeader.FindSet(false, false) then
                            repeat
                                with BoxHeader do begin
                                    SetCurrentKey("ShipStation Order Key", "ShipStation Shipment ID");
                                    SetFilter("ShipStation Order Key", '<>%1', '');
                                    SetFilter("ShipStation Shipment ID", '=%1', '');
                                    if FindSet(false, false) then
                                        repeat
                                            if "ShipStation Order Key" <> '' then
                                                PackageBoxMgt.CreateLabel2OrderInShipStation("Package No.", "No.");
                                        until Next() = 0;
                                end;
                            until PackageHeader.Next() = 0;
                        Message(lblLabelsCreated);
                    end;
                }
                action("Void Labels")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Void Labels', RUS = 'Отменить бирки';
                    ToolTipML = ENU = 'Void Labels all of the box document.',
                                RUS = 'Отменить бирки для всех коробок.';
                    Image = VoidCreditCard;
                    // Visible = "ShipStation Shipment ID" <> '';

                    trigger OnAction()
                    begin
                        PackageHeader.Reset();
                        BoxHeader.Reset();
                        CurrPage.SetSelectionFilter(PackageHeader);
                        if PackageHeader.FindSet(false, false) then
                            repeat
                                with BoxHeader do begin
                                    SetCurrentKey("ShipStation Shipment ID");
                                    SetFilter("ShipStation Shipment ID", '<>%1', '');
                                    if FindSet(false, false) then
                                        repeat
                                            PackageBoxMgt.VoidLabel2OrderInShipStation("Package No.", "No.");
                                        until Next() = 0;
                                end;
                            until PackageHeader.Next() = 0;
                        Message(lblLabelsVoided);
                    end;
                }
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
        lblLabelsVoided: TextConst ENU = 'Labels Voided!',
                                    RUS = 'Бирки отменены!';
}