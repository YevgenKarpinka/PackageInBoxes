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

                field("Sales Order No."; Rec."Sales Order No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the sales order number on the basis of which the packaging document was created',
                                RUS = 'Определяет номер заказа продажи на основании которого был создан документ упаковки.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Create User ID"; Rec."Create User ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the user id that created the packaging document.',
                                RUS = 'Определяет код пользователя который создал документ упаковки.';
                }
                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time the packaging document was created.',
                                RUS = 'Определяет дату и время создания документа упаковки.';
                }
                field("Last Modified User ID"; Rec."Last Modified User ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the user id that last modified the packaging document.',
                                RUS = 'Определяет код пользователя который последним изменил документ упаковки.';
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time of the last modification of the packaging document.',
                                RUS = 'Определяет дату и время последниего изменения документа упаковки.';
                }
                field(Status; Rec.Status)
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
                Editable = Rec.Status = Rec.Status::Unregistered;
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
                        PackageBoxMgt.RegisterPackage(Rec."No.");
                    end;
                }
                action(Unregistered)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Unregister', RUS = 'Отменить регистрацию';
                    ToolTipML = ENU = 'Unregister package document to change.',
                            RUS = 'Отменить регистрацию документа упаковки для изменения.';
                    Enabled = Rec.Status = Rec.Status::Registered;
                    Image = Undo;

                    trigger OnAction()
                    begin
                        PackageBoxMgt.UnregisterPackage(Rec."No.");
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
                    Enabled = Rec.Status = Rec.Status::Unregistered;
                    Image = ItemLines;

                    trigger OnAction()
                    var
                        BoxHeader: Record "Box Header";
                    begin
                        PackageBoxMgt.CloseAllBoxes(Rec."No.");
                    end;
                }
                action(ReOpenAll)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Reopen All', RUS = 'Открыть Все';
                    ToolTipML = ENU = 'Reopen all the document of the box to change.',
                            RUS = 'Повторное открытие всех документа коробки для их изменения.';
                    Enabled = Rec.Status = Rec.Status::Unregistered;
                    Image = RefreshLines;

                    trigger OnAction()
                    begin
                        PackageBoxMgt.ReOpenAllBoxes(Rec."No.");
                    end;
                }
                action(DeleteEmptyBoxes)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Delete Empty Boxes', RUS = 'Удалить пустые коробки';
                    ToolTipML = ENU = 'Delete empty box documents.',
                            RUS = 'Удаление пустых документов коробки.';
                    Enabled = Rec.Status = Rec.Status::Unregistered;
                    Image = Delete;

                    trigger OnAction()
                    begin
                        PackageBoxMgt.DeleteEmptyBoxes(Rec."No.");
                    end;
                }
                action(DeleteEmptyLines)
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Delete Empty Lines', RUS = 'Удалить пустые строки';
                    ToolTipML = ENU = 'Delete blank lines in box documents.',
                            RUS = 'Удаление пустых строк в документах коробки.';
                    Enabled = Rec.Status = Rec.Status::Unregistered;
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

                    trigger OnAction()
                    begin
                        PackageHeader.Reset();
                        BoxHeader.Reset();
                        CurrPage.SetSelectionFilter(PackageHeader);
                        if PackageHeader.FindSet(false, false) then
                            repeat
                                BoxHeader.SetCurrentKey(Status, "ShipStation Shipment ID");
                                BoxHeader.SetRange("Package No.", PackageHeader."No.");
                                BoxHeader.SetRange(Status, BoxHeader.Status::Closed);
                                BoxHeader.SetFilter("ShipStation Shipment ID", '=%1', '');
                                if BoxHeader.FindSet(false, false) then
                                    repeat
                                        if PackageBoxMgt.GetQuantityInBox(BoxHeader."No.") > 0 then
                                            PackageBoxMgt.SentBoxInShipStation(BoxHeader."Package No.", BoxHeader."No.");
                                    until BoxHeader.Next() = 0;
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

                    trigger OnAction()
                    var
                        LabelCreated: Boolean;
                    begin
                        PackageHeader.Reset();
                        BoxHeader.Reset();
                        CurrPage.SetSelectionFilter(PackageHeader);
                        if PackageHeader.FindSet(false, false) then
                            repeat
                                BoxHeader.SetCurrentKey(Status, "ShipStation Order Key", "ShipStation Shipment ID");
                                BoxHeader.SetRange("Package No.", PackageHeader."No.");
                                BoxHeader.SetRange(Status, BoxHeader.Status::Closed);
                                BoxHeader.SetFilter("ShipStation Order Key", '<>%1', '');
                                BoxHeader.SetFilter("ShipStation Shipment ID", '=%1', '');
                                if BoxHeader.FindSet() then begin
                                    repeat
                                        PackageBoxMgt.CreateLabel2OrderInShipStation(BoxHeader."Package No.", BoxHeader."No.");
                                        LabelCreated := true;
                                    until BoxHeader.Next() = 0;
                                    PackageBoxMgt.CreateDeliverySalesLineFromPackage(PackageHeader."Sales Order No.");
                                    ShipStationMgt.SentOrderShipmentStatusForWooComerse(BoxHeader."Sales Order No.", 1);
                                end;
                            until PackageHeader.Next() = 0;
                        if LabelCreated then
                            Message(lblLabelsCreated, PackageHeader."Sales Order No.")
                        else
                            Error(errNoBoxesFoundForCreatingLabels);
                    end;
                }
                action("Void Labels")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Void Labels', RUS = 'Отменить бирки';
                    ToolTipML = ENU = 'Void Labels all of the box document.',
                                RUS = 'Отменить бирки для всех коробок.';
                    Image = VoidCreditCard;

                    trigger OnAction()
                    var
                        LabelsVoided: Boolean;
                    begin
                        PackageHeader.Reset();
                        BoxHeader.Reset();
                        CurrPage.SetSelectionFilter(PackageHeader);
                        if PackageHeader.FindSet(false, false) then
                            repeat
                                BoxHeader.SetCurrentKey("ShipStation Shipment ID");
                                BoxHeader.SetRange("Package No.", PackageHeader."No.");
                                BoxHeader.SetFilter("ShipStation Shipment ID", '<>%1', '');
                                if BoxHeader.FindSet(false, false) then begin
                                    LabelsVoided := true;
                                    repeat
                                        PackageBoxMgt.VoidLabel2OrderInShipStation(BoxHeader."Package No.", BoxHeader."No.");
                                    until BoxHeader.Next() = 0;
                                    PackageBoxMgt.CreateDeliverySalesLineFromPackage(PackageHeader."Sales Order No.");
                                end;
                            until PackageHeader.Next() = 0;
                        if LabelsVoided then
                            Message(lblLabelsVoided)
                        else
                            Error(errNoLabelsForVoid);
                    end;
                }
            }
        }
    }

    var
        PackageHeader: Record "Package Header";
        BoxHeader: Record "Box Header";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        ShipStationMgt: Codeunit "ShipStation Mgt.";
        lblOrdersCreated: TextConst ENU = 'Orders Created in ShipStation!',
                                    RUS = 'Заказы в ShipStation созданы!';
        lblLabelsCreated: TextConst ENU = 'Labels Created and Attached to Sales Order %1',
                                    RUS = 'Бирки созданы и прикреплены к Заказу на продажу %1';
        lblLabelsVoided: TextConst ENU = 'Labels Voided!',
                                    RUS = 'Бирки отменены!';
        errNoBoxesFoundForCreatingLabels: TextConst ENU = 'No boxes found for creating labels.',
                                                    RUS = 'Коробок для создания бирок не найдено.';
        errNoLabelsForVoid: TextConst ENU = 'No labels found for void.',
                                    RUS = 'Бирок для аннулирования не найдено.';
}