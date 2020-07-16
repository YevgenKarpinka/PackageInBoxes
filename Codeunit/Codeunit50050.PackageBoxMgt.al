codeunit 50050 "Package Box Mgt."
{
    Permissions = tabledata "Warehouse Shipment Line" = r,
                  tabledata "Warehouse Activity Line" = r,
                  tabledata "Package Header" = rimd,
                  tabledata "Warehouse Shipment Header" = r,
                  tabledata "Box Header" = rimd,
                  tabledata "Box Line" = rimd;

    trigger OnRun()
    begin

    end;

    var
        CompanyInfo: Record "Company Information";
        WhseSetup: Record "Warehouse Setup";
        SalesHeader: Record "Sales Header";
        salesInvHeader: Record "Sales Invoice Header";
        Item: Record Item;
        glShipStationSetup: Record "ShipStation Setup";
        ShipStationMgt: Codeunit "ShipStation Mgt.";
        CompanyInfoGetted: Boolean;
        errItemPickedButNotFullyPackagedToBox: TextConst ENU = 'The Item %1 are picked to Shipment %2 but not packed %3!',
                                                              RUS = 'Товара %1 подобран в Отгрузке %2 но не упакован %3!';
        errNotAllowUnregisterIfShipmentPosted: TextConst ENU = 'Not allow uregister Package %1 if Warehouse shipment posted!',
                                                         RUS = 'Нельзя отменить регистрацию Упаковки %1 если Складских отгрузка учтена!';
        errCreatePackageBeforePostingWarehouseShipment: TextConst ENU = 'Create Package before posting Warehouse Shipment %1.',
                                                                  RUS = 'Создайте Упаковку перед учетом Складской отгрузки %1.';
        errPackageMustBeRegistered: TextConst ENU = 'Package %1 must be registered.',
                                              RUS = 'Упаковка %1 должна быть зарегистрирована.';
        errCreateBoxForPackage: TextConst ENU = 'Create box for Package %1.',
                                          RUS = 'Создайте коробку для Упаковки %1.';
        errCantDeleteShipmentLineWhileItemPackedInBoxNo: TextConst ENU = 'Can''t delete Shipment %1 Line %2 while Item %3 packed in Box %4.',
                                                                   RUS = 'Нельзя удалить строку %2 Отгрузки %1 пока Товар %3 запакован в Коробку %4.';
        errPackageMustBeUnregister: TextConst ENU = 'Package %1 must be unregister!',
                                              RUS = 'Упаковка %1 должна быть не зарегистрирована';
        errOpenBoxNotAllowedTrackginNoExist: TextConst ENU = 'Box document %1 cannot be open because the tracking number %2  is exist.',
                                                    RUS = 'Документ коробки %1 открыть нельзя, потому что заполнен номер отслеживания %2.';
        errDeleteBoxNotAllowedTrackginNoExist: TextConst ENU = 'Box document %1 cannot be delete because the tracking number %2  is exist.',
                                                    RUS = 'Документ коробки %1 удалить нельзя, потому что заполнен номер отслеживания %2.';
        lblAwaitingShipment: Label 'awaiting_shipment';
        lblShipped: Label 'shipped';
        errorWhseShipNotExist: TextConst ENU = 'Warehouse Shipment is not Created for Sales Order = %1!',
                                         RUS = 'Для Заказа продажи = %1 не создана Складская отгрузка!';
        errorShipStationOrderNotExist: TextConst ENU = 'Order in ShipStation is not Existed!';
        errorOrderNotExist: TextConst ENU = 'Sales Order %1 is Posted or Deleted!';
        errShipStationIntegrationDisable: TextConst ENU = 'ShipStation Integration Disable.',
                                         RUS = 'Интеграция с ShipStation отключена.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment (Yes/No)", 'OnBeforeConfirmWhseShipmentPost', '', false, false)]
    local procedure OnRegisterPackage(var WhseShptLine: Record "Warehouse Shipment Line")
    var
        PackageHeader: Record "Package Header";
    begin
        GetWhseSetup();
        if not WhseSetup."Enable Box Packaging"
        and not (WhseShptLine."Source Document" = WhseShptLine."Source Document"::"Sales Order") then
            exit;

        with PackageHeader do begin
            SetCurrentKey("Sales Order No.");
            SetRange("Sales Order No.", WhseShptLine."Source No.");
            if not FindFirst() then
                Error(errCreatePackageBeforePostingWarehouseShipment, WhseShptLine."No.");

            if PackageUnRegistered(PackageHeader."No.") then
                Error(errPackageMustBeRegistered, PackageHeader."No.");
        end;

        // CheckRemainingItemQuantityBeforeRegisterPackage(WhseShptLine."No.");
        // DeleteEmptyBoxes(PackageHeader."No.");
        // DeleteEmptyLinesByPackag(PackageHeader."No.");
        // CloseAllBoxes(PackageHeader."No.");
        // PackageSetRegister(PackageHeader."No.");
    end;

    [EventSubscriber(ObjectType::Table, 7320, 'OnBeforeWhseShptLineDelete', '', false, false)]
    local procedure CheckBoxLineExist(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        BoxLine: Record "Box Line";
    begin
        GetWhseSetup();
        if not WhseSetup."Enable Box Packaging"
        and not (WarehouseShipmentLine."Source Document" = WarehouseShipmentLine."Source Document"::"Sales Order") then
            exit;

        with BoxLine do begin
            SetCurrentKey("Shipment No.", "Shipment Line No.");
            SetRange("Shipment No.", WarehouseShipmentLine."No.");
            SetRange("Shipment Line No.", WarehouseShipmentLine."Line No.");
            if FindFirst() then
                Error(errCantDeleteShipmentLineWhileItemPackedInBoxNo, WarehouseShipmentLine."No.",
                    WarehouseShipmentLine."Line No.", "Item No.", "Box No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnBeforeCode', '', false, false)]
    local procedure CreatePackageAfterRegisterPick(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        PackageHeader: Record "Package Header";
    begin
        GetWhseSetup();
        if not WhseSetup."Enable Box Packaging"
        or not (WarehouseActivityLine."Source Document" = WarehouseActivityLine."Source Document"::"Sales Order") then
            exit;

        with PackageHeader do begin
            SetCurrentKey("Sales Order No.");
            SetRange("Sales Order No.", WarehouseActivityLine."Source No.");
            if FindFirst() then exit;
        end;

        with PackageHeader do begin
            Init();
            "Sales Order No." := WarehouseActivityLine."Source No.";
            if Insert(true) then;
        end;
    end;

    procedure CheckPackageBeforeRegister(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        GetWhseSetup();
        if not WhseSetup."Enable Box Packaging" then exit;
        PackageHeader.Get(PackageNo);
        if not PackageUnRegistered(PackageHeader."No.") then exit;

        with WhseShptLine do begin
            SetCurrentKey("Source Document", "Source No.");
            SetRange("Source Document", "Source Document"::"Sales Order");
            SetRange("Source No.", PackageHeader."Sales Order No.");
            if FindSet() then
                repeat
                    CheckRemainingItemQuantityBeforeRegisterPackage(WhseShptLine."No.");
                until Next() = 0;
        end;
    end;

    procedure CheckWhseShipmentExist(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        GetWhseSetup();
        if not WhseSetup."Enable Box Packaging" then exit;
        PackageHeader.Get(PackageNo);

        with WhseShptLine do begin
            SetCurrentKey("Source Document", "Source No.");
            SetRange("Source Document", "Source Document"::"Sales Order");
            SetRange("Source No.", PackageHeader."Sales Order No.");
            if not FindFirst() then
                Error(errNotAllowUnregisterIfShipmentPosted, "No.");
        end;
    end;

    procedure CheckRemainingItemQuantityBeforeRegisterPackage(ShipmentNo: Code[20])
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        RemainingItemQuantity: Decimal;
    begin
        with WhseShipmentLine do begin
            SetRange("No.", ShipmentNo);
            if FindSet() then
                repeat
                    RemainingItemQuantity := GetRemainingItemQuantityInShipment("No.", "Item No.", "Line No.");
                    if RemainingItemQuantity > 0 then
                        Error(errItemPickedButNotFullyPackagedToBox, "Item No.", "No.", RemainingItemQuantity);
                until Next() = 0;
        end;
    end;

    procedure CreateNewPackageFromWarehouseShipment(var PackageHeader: Record "Package Header"; WhseShipmentHeader: Record "Warehouse Shipment Header"): Boolean
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        WhseActLine: Record "Warehouse Activity Line";
    begin
        with WhseShipmentHeader do
            TestField(Status, Status::Released);

        with WhseShipmentLine do begin
            SetRange("No.", WhseShipmentHeader."No.");
            FindFirst();
        end;

        with PackageHeader do begin
            SetCurrentKey("Sales Order No.");
            SetRange("Sales Order No.", WhseShipmentLine."Source No.");
            if FindFirst() then exit(true);
        end;

        with PackageHeader do begin
            Init();
            "Sales Order No." := WhseShipmentLine."Source No.";
            if Insert(true) then;
        end;

        exit(true);
    end;

    procedure AssemblyBox(PackageNo: Code[20]; BoxNo: Code[20])
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        BoxHeader: Record "Box Header";
        RemainingQuantity: Decimal;
    begin
        if not PackageUnRegistered(PackageNo) then
            Error(errPackageMustBeUnregister, PackageNo);

        if not BoxHeader.Get(PackageNo, BoxNo) then
            Error(errCreateBoxForPackage, PackageNo);

        with WhseShipmentLine do begin
            SetCurrentKey("Source Document", "Source No.");
            SetRange("Source Document", "Source Document"::"Sales Order");
            SetRange("Source No.", BoxHeader."Sales Order No.");
            FindSet();
            repeat
                RemainingQuantity := GetRemainingItemQuantityInShipment("No.", "Item No.", "Line No.");
                if RemainingQuantity > 0 then
                    AddItemToBox("No.", BoxNo, "Item No.", "Line No.", RemainingQuantity);
            until Next() = 0;
        end;
    end;

    local procedure AddItemToBox(ShipmentNo: code[20]; BoxNo: Code[20]; ItemNo: Code[20]; ShipmentLineNo: Integer; RemainingQuantity: Decimal);
    var
        BoxLine: Record "Box Line";
        LastBoxLine: Record "Box Line";
        LineNo: Integer;
    begin
        with LastBoxLine do begin
            SetCurrentKey("Shipment No.", "Item No.", "Shipment Line No.");
            SetRange("Box No.", BoxNo);
            SetRange("Shipment No.", ShipmentNo);
            SetRange("Item No.", ItemNo);
            SetRange("Shipment Line No.", ShipmentLineNo);
            if FindFirst() then begin
                "Quantity in Box" += RemainingQuantity;
                Modify(true);
                exit;
            end else begin
                Reset();
                SetRange("Box No.", BoxNo);
                if FindLast() then
                    LineNo := "Line No." + 10000
                else
                    LineNo := 10000;
            end;
        end;

        with BoxLine do begin
            Init();
            "Box No." := BoxNo;
            "Line No." := LineNo;
            "Item No." := ItemNo;
            "Quantity in Box" := RemainingQuantity;
            "Shipment No." := ShipmentNo;
            "Shipment Line No." := ShipmentLineNo;
            Insert(true);
        end;
    end;

    procedure CreateBox(PackageNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        if not PackageUnRegistered(PackageNo) then
            Error(errPackageMustBeUnregister, PackageNo);

        with BoxHeader do begin
            Init();
            "Package No." := PackageNo;
            Insert(true);
        end;
    end;

    procedure CloseAllBoxes(PackageNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            SetCurrentKey(Status);
            SetRange("Package No.", PackageNo);
            SetRange(Status, Status::Open);
            if FindSet() then
                repeat
                    Validate(Status, Status::Close);
                    Modify(true);
                until Next() = 0;
            // ModifyAll(Status, Status::Close, true);
        end;
    end;

    procedure ReOpenAllBoxes(PackageNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            SetCurrentKey(Status);
            SetRange("Package No.", PackageNo);
            SetRange(Status, Status::Close);
            // ModifyAll(Status, Status::Open, true);
            if FindFirst() then
                repeat
                    OpenBox("Package No.", "No.");
                until Next() = 0;
        end;
    end;

    procedure PackageSetRegister(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
    begin
        // CheckRemainingItemQuantityBeforeRegisterPackage(PackageNo);
        with PackageHeader do begin
            Get(PackageNo);
            if Status = Status::Registered then exit;
            Validate(Status, Status::Registered);
            Modify(true);
        end;
    end;

    procedure PackageSetUnregister(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
    begin
        with PackageHeader do begin
            Get(PackageNo);
            if Status = Status::Unregistered then exit;
            Status := Status::Unregistered;
            Modify(true);
        end;
    end;

    procedure CalcItemQuantityInOrder(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
            SetCurrentKey("Document Type", "Document No.", Type, "No.");
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", SalesOrderNo);
            SetRange(Type, Type::Item);
            SetRange("No.", ItemNo);
            CalcSums(Quantity);
            exit(Quantity);
        end;
    end;

    procedure CalcItemPickedQuantityInShipments(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        with WhseShipmentLine do begin
            SetCurrentKey("Source Document", "Source No.");
            SetRange("Source Document", "Source Document"::"Sales Order");
            SetRange("Source No.", SalesOrderNo);
            SetRange("Item No.", ItemNo);
            CalcSums("Qty. Picked");
            exit("Qty. Picked");
        end;
    end;

    procedure CalcItemPickedQuantityByShipment(WhseShipmentNo: Code[20]; ItemNo: Code[20]; LineNo: Integer): Decimal
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        with WhseShipmentLine do begin
            SetCurrentKey("Item No.");
            SetRange("No.", WhseShipmentNo);
            SetRange("Line No.", LineNo);
            SetRange("Item No.", ItemNo);
            CalcSums("Qty. Picked");
            exit("Qty. Picked");
        end;
    end;

    procedure CalcItemQuantityInBoxesByOrder(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    var
        BoxLine: Record "Box Line";
    begin
        with BoxLine do begin
            SetCurrentKey("Sales Order No.", "Item No.");
            SetRange("Sales Order No.", SalesOrderNo);
            SetRange("Item No.", ItemNo);
            CalcSums("Quantity in Box");
            exit("Quantity in Box");
        end;
    end;

    procedure CalcItemQuantityInBoxesByShipment(WhseShipmentNo: Code[20]; ItemNo: Code[20]; LineNo: Integer): Decimal
    var
        BoxLine: Record "Box Line";
    begin
        with BoxLine do begin
            SetCurrentKey("Shipment No.", "Shipment Line No.", "Item No.");
            SetRange("Shipment No.", WhseShipmentNo);
            SetRange("Shipment Line No.", LineNo);
            SetRange("Item No.", ItemNo);
            CalcSums("Quantity in Box");
            exit("Quantity in Box");
        end;
    end;

    procedure GetRemainingItemQuantityInOrder(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    var
        RemainingQuantityInOrder: Decimal;
    begin
        RemainingQuantityInOrder := CalcItemQuantityInOrder(SalesOrderNo, ItemNo) -
                                        CalcItemQuantityInBoxesByOrder(SalesOrderNo, ItemNo);

        if RemainingQuantityInOrder < 0 then
            exit(0)
        else
            exit(RemainingQuantityInOrder);
    end;

    procedure GetRemainingItemQuantityInShipment(WhseShipmentNo: Code[20]; ItemNo: Code[20]; LineNo: Integer): Decimal
    var
        RemainingQuantityInShipment: Decimal;
    begin
        RemainingQuantityInShipment := CalcItemPickedQuantitybyShipment(WhseShipmentNo, ItemNo, LineNo) -
                                           CalcItemQuantityInBoxesByShipment(WhseShipmentNo, ItemNo, LineNo);

        if RemainingQuantityInShipment < 0 then
            exit(0)
        else
            exit(RemainingQuantityInShipment);
    end;

    procedure GetQuantityInBox(BoxNo: Code[20]): Decimal
    var
        BoxLine: Record "Box Line";
    begin
        with BoxLine do begin
            SetRange("Box No.", BoxNo);
            CalcSums("Quantity in Box");
            exit("Quantity in Box");
        end;
    end;

    procedure PackageUnRegistered(PackageNo: Code[20]): Boolean
    var
        PackageHeader: Record "Package Header";
    begin
        with PackageHeader do begin
            Get(PackageNo);
            exit(Status = Status::Unregistered);
        end;
    end;

    procedure DeleteEmptyBoxes(PackageNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        GetWhseSetup();
        if not WhseSetup."Delete Empty Box" then exit;

        with BoxHeader do begin
            SetRange("Package No.", PackageNo);
            FindSet();
            repeat
                if BoxIsEmpty("No.") then
                    Delete(true);
            until Next() = 0;
        end;
    end;

    procedure DeleteEmptyLinesByPackag(PackageNo: Code[20])
    var
        BoxHeader: Record "Box Header";
        BoxLine: Record "Box Line";
    begin
        GetWhseSetup();
        if not WhseSetup."Delete Empty Lines" then exit;

        BoxHeader.SetRange("Package No.", PackageNo);
        if BoxHeader.FindSet() then
            repeat
                with BoxLine do begin
                    SetCurrentKey("Quantity in Box");
                    SetRange("Box No.", BoxHeader."No.");
                    SetRange("Quantity in Box", 0);
                    DeleteAll(true);
                end;
            until BoxHeader.Next() = 0;
    end;

    procedure DeleteEmptyLinesByBox(BoxNo: Code[20])
    var
        BoxLine: Record "Box Line";
    begin
        GetWhseSetup();
        if not WhseSetup."Delete Empty Lines" then exit;

        with BoxLine do begin
            SetCurrentKey("Quantity in Box");
            SetRange("Box No.", BoxNo);
            SetRange("Quantity in Box", 0);
            DeleteAll(true);
        end;
    end;

    procedure BoxIsEmpty(BoxNo: Code[20]): Boolean
    var
        BoxLine: Record "Box Line";
    begin
        with BoxLine do begin
            SetCurrentKey("Quantity in Box");
            SetRange("Box No.", BoxNo);
            SetFilter("Quantity in Box", '>%1', 0);
            exit(IsEmpty);
        end;
    end;

    procedure WhseShipmentIsPosted(ShipmentNo: Code[20]; LineNo: Integer): Boolean
    var
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
    begin
        with PostedWhseShipmentLine do begin
            SetCurrentKey("Whse. Shipment No.", "Whse Shipment Line No.");
            SetRange("Whse. Shipment No.", ShipmentNo);
            SetRange("Whse Shipment Line No.", LineNo);
            exit(FindFirst());
        end;
    end;

    local procedure GetWhseSetup()
    begin
        WhseSetup.Get();
    end;

    local procedure GetCompanyInfo()
    begin
        if CompanyInfoGetted then exit;
        CompanyInfoGetted := true;
        CompanyInfo.Get();
    end;

    local procedure GetSalesOrderByNo(SalesOrderNo: Code[20])
    begin
        if SalesOrderNo <> SalesHeader."No." then
            if not SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo) then
                with salesInvHeader do begin
                    SetCurrentKey("Order No.");
                    SetFilter("Order No.", SalesOrderNo);
                    FindFirst();
                end;
    end;

    procedure GetCompanyName(): Text
    begin
        GetCompanyInfo();
        exit(CompanyInfo.Name + CompanyInfo."Name 2");
    end;

    procedure GetCompanyAddress(): Text
    begin
        GetCompanyInfo();
        exit(CompanyInfo.Address + CompanyInfo."Address 2");
    end;

    procedure GetCompanyCityStatePostCode(): Text
    begin
        GetCompanyInfo();
        exit(CompanyInfo.City + ', ' + CompanyInfo.County + ' ' + CompanyInfo."Post Code");
    end;

    procedure GetCompanyPhone(): Text
    begin
        GetCompanyInfo();
        exit(CompanyInfo."Phone No.");
    end;

    procedure GetCompanyPhone2(): Text
    begin
        GetCompanyInfo();
        exit(CompanyInfo."Phone No. 2");
    end;

    procedure GetCompanyEmail(): Text
    begin
        GetCompanyInfo();
        exit(CompanyInfo."E-Mail");
    end;

    procedure GetCompanyContactName(): Text
    begin
        GetCompanyInfo();
        exit(CompanyInfo."Contact Person");
    end;

    procedure GetBillToNameByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        if salesInvHeader."Order No." = SalesOrderNo then
            exit(salesInvHeader."Bill-to Name" + salesInvHeader."Bill-to Name 2")
        else
            exit(SalesHeader."Bill-to Name" + SalesHeader."Bill-to Name 2");
    end;

    procedure GetShipToNameByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        if salesInvHeader."Order No." = SalesOrderNo then
            exit(salesInvHeader."Ship-to Name" + salesInvHeader."Ship-to Name 2")
        else
            exit(SalesHeader."Ship-to Name" + SalesHeader."Ship-to Name 2");
    end;

    procedure GetBillToAddressByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        if salesInvHeader."Order No." = SalesOrderNo then
            exit(salesInvHeader."Bill-to Address" + salesInvHeader."Bill-to Address 2")
        else
            exit(SalesHeader."Bill-to Address" + SalesHeader."Bill-to Address 2");
    end;

    procedure GetShipToAddressByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        if salesInvHeader."Order No." = SalesOrderNo then
            exit(salesInvHeader."Ship-to Address" + salesInvHeader."Ship-to Address 2")
        else
            exit(SalesHeader."Ship-to Address" + SalesHeader."Ship-to Address 2");
    end;

    procedure GetBillToCityByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        if salesInvHeader."Order No." = SalesOrderNo then
            exit(salesInvHeader."Bill-to City" + ', ' + salesInvHeader."Bill-to County" + ' ' + salesInvHeader."Bill-to Post Code")
        else
            exit(SalesHeader."Bill-to City" + ', ' + SalesHeader."Bill-to County" + ' ' + SalesHeader."Bill-to Post Code");
    end;

    procedure GetShipToCityByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        if salesInvHeader."Order No." = SalesOrderNo then
            exit(salesInvHeader."Ship-to City" + ', ' + salesInvHeader."Ship-to County" + ' ' + salesInvHeader."Ship-to Post Code")
        else
            exit(SalesHeader."Ship-to City" + ', ' + SalesHeader."Ship-to County" + ' ' + SalesHeader."Ship-to Post Code");
    end;

    procedure GetSalesOrderData(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        if salesInvHeader."Order No." = SalesOrderNo then
            exit(Format(salesInvHeader."Document Date"))
        else
            exit(Format(SalesHeader."Document Date"));
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if ItemNo <> Item."No." then
            Item.Get(ItemNo);
    end;

    procedure GetItemDescription(ItemNo: Code[20]): Text
    begin
        GetItem(ItemNo);
        exit(Item.Description + Item."Description 2");
    end;

    procedure GetItemUoM(ItemNo: Code[20]): Text
    begin
        GetItem(ItemNo);
        exit(Item."Sales Unit of Measure");
    end;

    procedure CloseBox(PackageNo: Code[20]; BoxNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            if Get(PackageNo, BoxNo) and (Status = Status::Open) then begin
                TestField("Gross Weight");
                Validate(Status, Status::Close);
                Modify(true);
            end;
        end;
    end;

    procedure OpenBox(PackageNo: Code[20]; BoxNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        if not PackageUnRegistered(PackageNo) then
            Error(errPackageMustBeUnregister, PackageNo);

        with BoxHeader do
            if Get(PackageNo, BoxNo) then
                if Status = Status::Close then begin
                    TestField("Tracking No.", '');
                    Validate(Status, Status::Open);
                    Modify(true);
                end;
    end;

    procedure RegisterPackage(PackageNo: Code[20])
    begin
        CheckPackageBeforeRegister(PackageNo);
        DeleteEmptyBoxes(PackageNo);
        DeleteEmptyLinesByPackag(PackageNo);
        CloseAllBoxes(PackageNo);
        PackageSetRegister(PackageNo);
    end;

    procedure DeleteBox(PackageNo: Code[20]; BoxNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        if not PackageUnRegistered(PackageNo) then
            Error(errPackageMustBeUnregister, PackageNo);

        with BoxHeader do
            if Get(PackageNo, BoxNo) then begin
                TestField("Tracking No.", '');
                Delete(true);
            end;
    end;

    procedure UnregisterPackage(PackageNo: Code[20])
    begin
        CheckWhseShipmentExist(PackageNo);
        PackageSetUnregister(PackageNo);
        GetWhseSetup();
        if WhseSetup."Unregister and Status Open" then
            ReOpenAllBoxes(PackageNo);
    end;

    procedure SentBoxInShipStation(PackageNo: Code[20]; BoxNo: Code[20])
    var
        jsonUpdateBox: JsonObject;
    begin
        GetShipStationSetup();
        if not glShipStationSetup."ShipStation Integration Enable" then Error(errShipStationIntegrationDisable);

        jsonUpdateBox := SentBox2Shipstation(PackageNo, BoxNo);
        if CheckUpdateBox(jsonUpdateBox, 'orderId') then
            UpdateBox(PackageNo, BoxNo, jsonUpdateBox);
    end;

    local procedure SentBox2Shipstation(PackageNo: Code[20]; BoxNo: Code[20]): JsonObject
    begin
        exit(CreateOrderFromBoxInShipStation(PackageNo, BoxNo));
    end;

    local procedure CheckUpdateBox(jsonUpdateBox: JsonObject; TokenKey: Text): Boolean
    var
        _jsonToken: JsonToken;
    begin
        _jsonToken := ShipStationMgt.GetJSToken(jsonUpdateBox, TokenKey);
        exit(not _jsonToken.AsValue().IsNull);
    end;

    local procedure UpdateBox(PackageNo: Code[20]; BoxNo: Code[20]; jsonUpdateBox: JsonObject)
    begin
        UpdateBoxFromShipStation(PackageNo, BoxNo, jsonUpdateBox)
    end;

    local procedure GetShipStationSetup()
    begin
        with glShipStationSetup do
            if not Get() then begin
                Init();
                Insert();
            end;
    end;

    procedure CreateOrderFromBoxInShipStation(PackageNo: Code[20]; BoxNo: Code[20]): JsonObject
    var
        _BoxHeader: Record "Box Header";
        _SH: Record "Sales Header";
        _Cust: Record Customer;
        JSText: Text;
        JSObjectHeader: JsonObject;
        jsonTagsArray: JsonArray;
    begin
        if not _BoxHeader.Get(PackageNo, BoxNo) then exit(JSObjectHeader);

        if not _SH.Get(_SH."Document Type"::Order, _BoxHeader."Sales Order No.") then exit(JSObjectHeader);

        if not _Cust.Get(_SH."Sell-to Customer No.") then exit(JSObjectHeader);

        JSObjectHeader.Add('orderNumber', BoxNo);
        if _BoxHeader."ShipStation Order Key" <> '' then
            JSObjectHeader.Add('orderKey', _BoxHeader."ShipStation Order Key");
        JSObjectHeader.Add('orderDate', ShipStationMgt.Date2Text4JSON(_SH."Posting Date"));
        JSObjectHeader.Add('paymentDate', ShipStationMgt.Date2Text4JSON(_SH."Prepayment Due Date"));
        JSObjectHeader.Add('shipByDate', ShipStationMgt.Date2Text4JSON(_SH."Shipment Date"));
        JSObjectHeader.Add('orderStatus', lblAwaitingShipment);
        JSObjectHeader.Add('customerUsername', _Cust."E-Mail");
        JSObjectHeader.Add('customerEmail', _Cust."E-Mail");
        JSObjectHeader.Add('billTo', ShipStationMgt.jsonBillToFromSH(_SH."No."));
        JSObjectHeader.Add('shipTo', ShipStationMgt.jsonShipToFromSH(_SH."No."));
        JSObjectHeader.Add('items', jsonItemsFromBoxLines(BoxNo));
        JSObjectHeader.Add('weight', ShipStationMgt.jsonWeightFromItem(_BoxHeader."Gross Weight"));
        JSObjectHeader.WriteTo(JSText);

        JSText := ShipStationMgt.Connect2ShipStation(2, JSText, '');
        JSObjectHeader.ReadFrom(JSText);
        exit(JSObjectHeader);
    end;

    procedure jsonItemsFromBoxLines(BoxNo: Code[20]): JsonArray
    var
        JSObjectLine: JsonObject;
        JSObjectArray: JsonArray;
        _BoxLine: Record "Box Line";
        _ItemDescr: Record "Item Description";
        _SalesLine: Record "Sales Line";
    begin
        with _BoxLine do begin
            SetCurrentKey("Quantity in Box");
            SetRange("Box No.", BoxNo);
            SetFilter("Quantity in Box", '<>%1', 0);
            if FindSet(false, false) then
                repeat
                    Clear(JSObjectLine);
                    GetSalesLineFromBoxLine(_SalesLine, "Shipment No.", "Shipment Line No.");

                    JSObjectLine.Add('lineItemKey', "Line No.");
                    JSObjectLine.Add('sku', "Item No.");
                    JSObjectLine.Add('name', _SalesLine.Description);
                    if _ItemDescr.Get("item No.") then
                        JSObjectLine.Add('imageUrl', _ItemDescr."Main Image URL");
                    // JSObjectLine.Add('weight', ShipStationMgt.jsonWeightFromItem(_SalesLine."Gross Weight"));
                    JSObjectLine.Add('quantity', ShipStationMgt.Decimal2Integer("Quantity in Box"));
                    JSObjectLine.Add('unitPrice', Round(_SalesLine."Amount Including VAT" / _SalesLine.Quantity, 0.01));
                    JSObjectLine.Add('taxAmount', Round((_SalesLine."Amount Including VAT" - _SalesLine.Amount) / _SalesLine.Quantity, 0.01));
                    JSObjectLine.Add('warehouseLocation', _SalesLine."Location Code");
                    JSObjectLine.Add('productId', "Line No.");
                    JSObjectLine.Add('adjustment', false);
                    JSObjectArray.Add(JSObjectLine);
                until Next() = 0;
        end;
        exit(JSObjectArray);
    end;

    local procedure GetSalesLineFromBoxLine(var SalesLine: Record "Sales Line"; ShipmentNo: Code[20]; ShipmentLineNo: Integer): Boolean
    var
        WhseShipment: Record "Warehouse Shipment Line";
    begin
        if WhseShipment.Get(ShipmentNo, ShipmentLineNo) and
           SalesLine.Get(SalesLine."Document Type"::Order, WhseShipment."Source No.", WhseShipment."Source Line No.") then
            exit(true);
        exit(false);
    end;

    procedure UpdateBoxFromShipStation(PackageNo: Code[20]; BoxNo: Code[20]; _jsonObject: JsonObject): Boolean
    var
        _BoxHeader: Record "Box Header";
        _jsonToken: JsonToken;
    begin
        with _BoxHeader do begin

            if not Get(PackageNo, BoxNo) then exit(false);
            // update Sales Header from ShipStation

            _jsonToken := ShipStationMgt.GetJSToken(_jsonObject, 'carrierCode');
            if not _jsonToken.AsValue().IsNull then begin
                "Shipping Agent Code" := CopyStr(ShipStationMgt.GetJSToken(_jsonObject, 'carrierCode').AsValue().AsText(), 1, MaxStrLen("Shipping Agent Code"));
                _jsonToken := ShipStationMgt.GetJSToken(_jsonObject, 'serviceCode');
                if not _jsonToken.AsValue().IsNull then begin
                    "Shipping Services Code" := CopyStr(ShipStationMgt.GetJSToken(_jsonObject, 'serviceCode').AsValue().AsText(), 1, MaxStrLen("Shipping Services Code"));
                end;
            end;

            // Get Rate
            "ShipStation Order ID" := ShipStationMgt.GetJSToken(_jsonObject, 'orderId').AsValue().AsText();
            "ShipStation Order Key" := ShipStationMgt.GetJSToken(_jsonObject, 'orderKey').AsValue().AsText();
            "ShipStation Status" := CopyStr(ShipStationMgt.GetJSToken(_jsonObject, 'orderStatus').AsValue().AsText(), 1, MaxStrLen(_BoxHeader."ShipStation Status"));
            "ShipStation Shipment Amount" := ShipStationMgt.GetJSToken(_jsonObject, 'shippingAmount').AsValue().AsDecimal();

            // case "ShipStation Order Status" of
            //     "ShipStation Order Status"::"Not Sent":
            //         "ShipStation Order Status" := "ShipStation Order Status"::Sent;
            //     "ShipStation Order Status"::Sent:
            //         "ShipStation Order Status" := "ShipStation Order Status"::Updated;
            // end;

            if "ShipStation Status" = lblAwaitingShipment then begin
                "Tracking No." := '';
                "ShipStation Shipment ID" := '';
            end;

            Modify();
        end;
    end;

    procedure CreateLabel2OrderInShipStation(PackageNo: Code[20]; BoxNo: Code[20]): Boolean
    var
        _BoxHeader: Record "Box Header";
        JSText: Text;
        JSObject: JsonObject;
        jsLabelObject: JsonObject;
        OrdersJSArray: JsonArray;
        OrderJSToken: JsonToken;
        Counter: Integer;
        notExistOrdersList: Text;
        OrdersListCreateLabel: Text;
        OrdersCancelled: Text;
        txtLabel: Text;
        txtBeforeName: Text;
        WhseShipDocNo: Code[20];

    begin
        with _BoxHeader do begin
            if (not Get(PackageNo, BoxNo)) or ("ShipStation Order ID" = '') then Error(errorShipStationOrderNotExist);
            // comment to test Create Label and Attache to Warehouse Shipment
            if not ShipStationMgt.FindWarehouseSipment("Sales Order No.", WhseShipDocNo) then Error(errorWhseShipNotExist, "Sales Order No.");

            if not SalesHeader.Get(SalesHeader."Document Type"::Order, "Sales Order No.") then Error(errorOrderNotExist, "Sales Order No.");

            // Get Order from Shipstation to Fill Variables
            JSText := ShipStationMgt.Connect2ShipStation(1, '', StrSubstNo('/%1', "ShipStation Order ID"));
            JSObject.ReadFrom(JSText);

            // CheckUpdateBox(JSObject, 'orderId');
            // jsObjHeaderUpdate.ReadFrom(JSText);
            UpdateBoxFromShipStation(PackageNo, BoxNo, JSObject);
            JSText := ShipStationMgt.FillValuesFromOrder(JSObject, "Sales Order No.", SalesHeader."Location Code");


            JSObject.ReadFrom(JSText);
            // CheckUpdateBox(JSObject, 'orderId');
            JSText := ShipStationMgt.Connect2ShipStation(3, JSText, '');

            JSObject.ReadFrom(JSText);
            // CheckUpdateBox(JSObject, 'orderId');
            // Update Order From Label
            UpdateBoxFromLabel(PackageNo, BoxNo, JSText);

            // Add Lable to Shipment
            jsLabelObject.ReadFrom(JSText);
            txtLabel := ShipStationMgt.GetJSToken(jsLabelObject, 'labelData').AsValue().AsText();
            txtBeforeName := _BoxHeader."No." + '-' + ShipStationMgt.GetJSToken(jsLabelObject, 'trackingNumber').AsValue().AsText();
            ShipStationMgt.SaveLabel2Shipment(txtBeforeName, txtLabel, WhseShipDocNo);

            // Update Sales Header From ShipStation
            // JSText := ShipStationMgt.Connect2ShipStation(1, '', StrSubstNo('/%1', "ShipStation Order ID"));
            // JSObject.ReadFrom(JSText);
            // UpdateBoxFromShipStation(PackageNo, BoxNo, JSObject);
            ChangeShipStationStatusToShipped(PackageNo, BoxNo);
        end;
    end;

    procedure ChangeShipStationStatusToShipped(PackageNo: Code[20]; BoxNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            Get(PackageNo, BoxNo);
            "ShipStation Status" := lblShipped;
            Modify();
        end;
    end;

    procedure UpdateBoxFromLabel(PackageNo: Code[20]; BoxNo: Code[20]; jsonText: Text);
    var
        _BoxHeader: Record "Box Header";
        jsLabelObject: JsonObject;
    begin
        with _BoxHeader do begin
            if not Get(PackageNo, BoxNo) then exit;
            jsLabelObject.ReadFrom(jsonText);
            "Other Cost" := ShipStationMgt.GetJSToken(jsLabelObject, 'insuranceCost').AsValue().AsDecimal();
            "Shipment Cost" := ShipStationMgt.GetJSToken(jsLabelObject, 'shipmentCost').AsValue().AsDecimal();
            "Tracking No." := ShipStationMgt.GetJSToken(jsLabelObject, 'trackingNumber').AsValue().AsText();
            "ShipStation Shipment ID" := ShipStationMgt.GetJSToken(jsLabelObject, 'shipmentId').AsValue().AsText();
            "ShipStation Status" := lblShipped;
            Modify();
        end;
    end;

    procedure VoidLabel2OrderInShipStation(PackageNo: Code[20]; BoxNo: Code[20]): Boolean
    var
        _BoxHeader: Record "Box Header";
        JSText: Text;
        JSObject: JsonObject;
        WhseShipDocNo: Code[20];
        lblOrder: TextConst ENU = 'LabelOrder';
        FileName: Text;
        _txtBefore: Text;

    begin
        with _BoxHeader do begin
            if (not Get(PackageNo, BoxNo)) or ("ShipStation Shipment ID" = '') then exit(false);

            if not ShipStationMgt.FindWarehouseSipment("Sales Order No.", WhseShipDocNo) then
                Error(errorWhseShipNotExist, "Sales Order No.");

            // Void Label in Shipstation
            JSObject.Add('shipmentId', "ShipStation Shipment ID");
            JSObject.WriteTo(JSText);
            JSText := ShipStationMgt.Connect2ShipStation(8, JSText, '');
            // JSObject.ReadFrom(JSText);

            _txtBefore := "No." + '-' + "Tracking No.";
            FileName := StrSubstNo('%1-%2', _txtBefore, lblOrder);
            ShipStationMgt.DeleteAttachment(WhseShipDocNo, FileName);

            // Update Box Header From ShipStation
            // JSText := ShipStationMgt.Connect2ShipStation(1, '', StrSubstNo('/%1', "ShipStation Order ID"));
            // JSObject.ReadFrom(JSText);
            // UpdateBoxFromShipStation(PackageNo, BoxNo, JSObject);
            CleareTrackingNoShipmentID(PackageNo, BoxNo);
        end;
    end;

    procedure CleareTrackingNoShipmentID(PackageNo: Code[20]; BoxNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            Get(PackageNo, BoxNo);
            "Tracking No." := '';
            "ShipStation Shipment ID" := '';
            "ShipStation Status" := lblAwaitingShipment;
            Modify();
        end;
    end;

    procedure CreateDeliverySalesLineFromPackage(salesOrderNo: Code[20])
    var
        _salesHeader: Record "Sales Header";
        _salesLine: Record "Sales Line";
        _salesLineLast: Record "Sales Line";
        _customer: Record Customer;
        LineNo: Integer;
        PackageShippingAmount: Decimal;
        salesLineExist: Boolean;
        ICExtended: Codeunit "IC Extended";
    begin
        if not _salesHeader.Get(_salesHeader."Document Type"::Order, salesOrderNo) then exit;

        if (not _customer.Get(_salesHeader."Sell-to Customer No."))
            or (_customer."Sales No. Shipment Cost" = '') then
            exit;

        PackageShippingAmount := GetPackageShippingAmountFromSalesOrder(salesOrderNo);
        if PackageShippingAmount = 0 then begin
            DeleteItemChargeSalesLine(salesOrderNo, _customer."Sales No. Shipment Cost");
            exit;
        end;

        with _salesLineLast do begin
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", salesOrderNo);
            SetRange("No.", _customer."Sales No. Shipment Cost");
            if FindFirst() then begin
                salesLineExist := true;
                LineNo := "Line No."
            end else begin
                SetRange("No.");
                if FindLast() then
                    LineNo := "Line No." + 10000
                else
                    LineNo := 10000;
            end;
        end;

        with _salesHeader do
            if Status = Status::Released then begin
                Status := Status::Open;
                Modify();
            end;

        with _salesLine do begin
            if salesLineExist then
                Get("Document Type"::Order, salesOrderNo, LineNo)
            else begin
                Init;
                "Document Type" := "Document Type"::Order;
                "Document No." := salesOrderNo;
                "Line No." := LineNo;
                Insert(true);
            end;
            Validate(Type, _customer."Posting Type Shipment Cost");
            Validate(Quantity, 1);
            Validate("No.", _customer."Sales No. Shipment Cost");
            Validate("Unit Price", PackageShippingAmount);
            Modify(true)
        end;

        with _salesHeader do begin
            Status := Status::Released;
            Modify();
        end;

        ICExtended.CreateItemChargeAssgnt(_salesHeader."No.", _salesHeader."Sell-to Customer No.");
    end;

    procedure DeleteItemChargeSalesLine(salesOrderNo: Code[20]; ItemNo: Code[20])
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
    begin
        with salesHeader do begin
            Get("Document Type"::Order, salesOrderNo);
            if Status = Status::Released then begin
                Status := Status::Open;
                Modify();
            end;
        end;

        with salesLine do begin
            SetCurrentKey("No.");
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", salesOrderNo);
            SetRange("No.", ItemNo);
            DeleteAll(true);
        end;

        with salesHeader do
            if Status = Status::Open then begin
                Status := Status::Released;
                Modify();
            end;
    end;

    procedure GetPackageShippingAmountFromSalesOrder(salesOrderNo: Code[20]): Decimal
    var
        boxHeader: Record "Box Header";
    begin
        with boxHeader do begin
            SetCurrentKey("Sales Order No.", "ShipStation Shipment ID");
            SetRange("Sales Order No.", salesOrderNo);
            SetFilter("ShipStation Shipment ID", '<>%1', '');
            CalcSums("Shipment Cost", "Other Cost", "ShipStation Shipment Amount");
            exit("Shipment Cost" + "Other Cost" + "ShipStation Shipment Amount");
        end;
    end;
}