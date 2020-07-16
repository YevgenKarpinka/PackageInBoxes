page 50057 "Package List"
{
    CaptionML = ENU = 'Package List',
                RUS = 'Список Упаковки';
    InsertAllowed = false;
    SourceTable = "Package Header";
    CardPageId = "Package Card";
    SourceTableView = sorting("No.")
                      order(Descending);
    DataCaptionFields = "No.";
    ApplicationArea = Warehouse;
    Editable = false;
    PageType = List;
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(repeaterName)
            {
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
        }
        area(FactBoxes)
        {
            part(BoxesFactBox; "Boxes FactBox")
            {
                ApplicationArea = Warehouse;
                SubPageLink = "Package No." = field("No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(actionShipStation)
            {
                CaptionML = ENU = 'ShipStation', RUS = 'ShipStation';
                Image = ReleaseShipment;
                Visible = false;

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
                                with BoxHeader do begin
                                    SetCurrentKey(Status, "ShipStation Shipment ID");
                                    SetRange("Package No.", PackageHeader."No.");
                                    SetRange(Status, Status::Close);
                                    SetFilter("ShipStation Shipment ID", '=%1', '');
                                    if FindSet(false, false) then
                                        repeat
                                            if PackageBoxMgt.GetQuantityInBox("No.") > 0 then
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

                    trigger OnAction()
                    begin
                        PackageHeader.Reset();
                        BoxHeader.Reset();
                        CurrPage.SetSelectionFilter(PackageHeader);
                        if PackageHeader.FindSet(false, false) then
                            repeat
                                with BoxHeader do begin
                                    SetCurrentKey(Status, "ShipStation Order Key", "ShipStation Shipment ID");
                                    SetRange("Package No.", PackageHeader."No.");
                                    SetRange(Status, Status::Close);
                                    SetFilter("ShipStation Order Key", '<>%1', '');
                                    SetFilter("ShipStation Shipment ID", '=%1', '');
                                    if FindSet(false, false) then begin
                                        repeat
                                            PackageBoxMgt.CreateLabel2OrderInShipStation("Package No.", "No.");
                                        until Next() = 0;
                                        PackageBoxMgt.CreateDeliverySalesLineFromPackage(PackageHeader."Sales Order No.");
                                    end;
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

                    trigger OnAction()
                    begin
                        PackageHeader.Reset();
                        BoxHeader.Reset();
                        CurrPage.SetSelectionFilter(PackageHeader);
                        if PackageHeader.FindSet(false, false) then
                            repeat
                                with BoxHeader do begin
                                    SetCurrentKey("ShipStation Shipment ID");
                                    SetRange("Package No.", PackageHeader."No.");
                                    SetFilter("ShipStation Shipment ID", '<>%1', '');
                                    if FindSet(false, false) then begin
                                        repeat
                                            PackageBoxMgt.VoidLabel2OrderInShipStation("Package No.", "No.");
                                        until Next() = 0;
                                        PackageBoxMgt.CreateDeliverySalesLineFromPackage(PackageHeader."Sales Order No.");
                                    end;
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