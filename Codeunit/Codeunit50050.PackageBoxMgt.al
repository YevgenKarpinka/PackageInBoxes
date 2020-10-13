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

        PackageHeader.SetCurrentKey("Sales Order No.");
        PackageHeader.SetRange("Sales Order No.", WhseShptLine."Source No.");
        if not PackageHeader.FindFirst() then
            Error(errCreatePackageBeforePostingWarehouseShipment, WhseShptLine."No.");

        if PackageUnRegistered(PackageHeader."No.") then
            Error(errPackageMustBeRegistered, PackageHeader."No.");

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

        BoxLine.SetCurrentKey("Shipment No.", "Shipment Line No.");
        BoxLine.SetRange("Shipment No.", WarehouseShipmentLine."No.");
        BoxLine.SetRange("Shipment Line No.", WarehouseShipmentLine."Line No.");
        if BoxLine.FindFirst() then
            Error(errCantDeleteShipmentLineWhileItemPackedInBoxNo, WarehouseShipmentLine."No.",
                WarehouseShipmentLine."Line No.", BoxLine."Item No.", BoxLine."Box No.");
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

        PackageHeader.SetCurrentKey("Sales Order No.");
        PackageHeader.SetRange("Sales Order No.", WarehouseActivityLine."Source No.");
        if PackageHeader.FindFirst() then exit;

        PackageHeader.Init();
        PackageHeader."Sales Order No." := WarehouseActivityLine."Source No.";
        if PackageHeader.Insert(true) then;
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

        WhseShptLine.SetCurrentKey("Source Document", "Source No.");
        WhseShptLine.SetRange("Source Document", WhseShptLine."Source Document"::"Sales Order");
        WhseShptLine.SetRange("Source No.", PackageHeader."Sales Order No.");
        if WhseShptLine.FindSet() then
            repeat
                CheckRemainingItemQuantityBeforeRegisterPackage(WhseShptLine."No.");
            until WhseShptLine.Next() = 0;
    end;

    procedure CheckWhseShipmentExist(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        GetWhseSetup();
        if not WhseSetup."Enable Box Packaging" then exit;
        PackageHeader.Get(PackageNo);

        WhseShptLine.SetCurrentKey("Source Document", "Source No.");
        WhseShptLine.SetRange("Source Document", WhseShptLine."Source Document"::"Sales Order");
        WhseShptLine.SetRange("Source No.", PackageHeader."Sales Order No.");
        if not WhseShptLine.FindFirst() then
            Error(errNotAllowUnregisterIfShipmentPosted, WhseShptLine."No.");
    end;

    procedure CheckRemainingItemQuantityBeforeRegisterPackage(ShipmentNo: Code[20])
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        RemainingItemQuantity: Decimal;
    begin
        WhseShipmentLine.SetRange("No.", ShipmentNo);
        if WhseShipmentLine.FindSet() then
            repeat
                RemainingItemQuantity := GetRemainingItemQuantityInShipment(WhseShipmentLine."No.", WhseShipmentLine."Item No.", WhseShipmentLine."Line No.");
                if RemainingItemQuantity > 0 then
                    Error(errItemPickedButNotFullyPackagedToBox, WhseShipmentLine."Item No.", WhseShipmentLine."No.", RemainingItemQuantity);
            until WhseShipmentLine.Next() = 0;
    end;

    procedure CreateNewPackageFromWarehouseShipment(var PackageHeader: Record "Package Header"; WhseShipmentHeader: Record "Warehouse Shipment Header"): Boolean
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        WhseActLine: Record "Warehouse Activity Line";
    begin
        WhseShipmentHeader.TestField(Status, WhseShipmentHeader.Status::Released);

        WhseShipmentLine.SetRange("No.", WhseShipmentHeader."No.");
        WhseShipmentLine.FindFirst();

        PackageHeader.SetCurrentKey("Sales Order No.");
        PackageHeader.SetRange("Sales Order No.", WhseShipmentLine."Source No.");
        if PackageHeader.FindFirst() then exit(true);

        PackageHeader.Init();
        PackageHeader."Sales Order No." := WhseShipmentLine."Source No.";
        if PackageHeader.Insert(true) then;

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

        WhseShipmentLine.SetCurrentKey("Source Document", "Source No.");
        WhseShipmentLine.SetRange("Source Document", WhseShipmentLine."Source Document"::"Sales Order");
        WhseShipmentLine.SetRange("Source No.", BoxHeader."Sales Order No.");
        if WhseShipmentLine.FindSet() then
            repeat
                RemainingQuantity := GetRemainingItemQuantityInShipment(WhseShipmentLine."No.", WhseShipmentLine."Item No.", WhseShipmentLine."Line No.");
                if RemainingQuantity > 0 then
                    AddItemToBox(WhseShipmentLine."No.", BoxNo, WhseShipmentLine."Item No.", WhseShipmentLine."Line No.", RemainingQuantity);
            until WhseShipmentLine.Next() = 0;
    end;

    local procedure AddItemToBox(ShipmentNo: code[20]; BoxNo: Code[20]; ItemNo: Code[20]; ShipmentLineNo: Integer; RemainingQuantity: Decimal);
    var
        BoxLine: Record "Box Line";
        LastBoxLine: Record "Box Line";
        LineNo: Integer;
    begin
        LastBoxLine.SetCurrentKey("Shipment No.", "Item No.", "Shipment Line No.");
        LastBoxLine.SetRange("Box No.", BoxNo);
        LastBoxLine.SetRange("Shipment No.", ShipmentNo);
        LastBoxLine.SetRange("Item No.", ItemNo);
        LastBoxLine.SetRange("Shipment Line No.", ShipmentLineNo);
        if LastBoxLine.FindFirst() then begin
            LastBoxLine."Quantity in Box" += RemainingQuantity;
            LastBoxLine.Modify(true);
            exit;
        end else begin
            LastBoxLine.Reset();
            LastBoxLine.SetRange("Box No.", BoxNo);
            if LastBoxLine.FindLast() then
                LineNo := LastBoxLine."Line No." + 10000
            else
                LineNo := 10000;
        end;

        BoxLine.Init();
        BoxLine."Box No." := BoxNo;
        BoxLine."Line No." := LineNo;
        BoxLine."Item No." := ItemNo;
        BoxLine."Quantity in Box" := RemainingQuantity;
        BoxLine."Shipment No." := ShipmentNo;
        BoxLine."Shipment Line No." := ShipmentLineNo;
        BoxLine.Insert(true);
    end;

    procedure CreateBox(PackageNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        if not PackageUnRegistered(PackageNo) then
            Error(errPackageMustBeUnregister, PackageNo);

        BoxHeader.Init();
        BoxHeader."Package No." := PackageNo;
        BoxHeader.Insert(true);
    end;

    procedure CloseAllBoxes(PackageNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        BoxHeader.SetCurrentKey(Status);
        BoxHeader.SetRange("Package No.", PackageNo);
        BoxHeader.SetRange(Status, BoxHeader.Status::Open);
        if BoxHeader.FindSet() then
            repeat
                CloseBox(BoxHeader."Package No.", BoxHeader."No.");
            until BoxHeader.Next() = 0;
    end;

    procedure ReOpenAllBoxes(PackageNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        BoxHeader.SetCurrentKey(Status);
        BoxHeader.SetRange("Package No.", PackageNo);
        BoxHeader.SetRange(Status, BoxHeader.Status::Closed);
        if BoxHeader.FindFirst() then
            repeat
                OpenBox(BoxHeader."Package No.", BoxHeader."No.");
            until BoxHeader.Next() = 0;
    end;

    procedure PackageSetRegister(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
    begin
        // CheckRemainingItemQuantityBeforeRegisterPackage(PackageNo);
        PackageHeader.Get(PackageNo);
        if PackageHeader.Status = PackageHeader.Status::Registered then exit;
        PackageHeader.Validate(Status, PackageHeader.Status::Registered);
        PackageHeader.Modify(true);
    end;

    procedure PackageSetUnregister(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
    begin
        PackageHeader.Get(PackageNo);
        if PackageHeader.Status = PackageHeader.Status::Unregistered then exit;
        PackageHeader.Status := PackageHeader.Status::Unregistered;
        PackageHeader.Modify(true);
    end;

    procedure CalcItemQuantityInOrder(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey("Document Type", "Document No.", Type, "No.");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesOrderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", ItemNo);
        SalesLine.CalcSums(Quantity);
        exit(SalesLine.Quantity);
    end;

    procedure CalcItemPickedQuantityInShipments(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WhseShipmentLine.SetCurrentKey("Source Document", "Source No.");
        WhseShipmentLine.SetRange("Source Document", WhseShipmentLine."Source Document"::"Sales Order");
        WhseShipmentLine.SetRange("Source No.", SalesOrderNo);
        WhseShipmentLine.SetRange("Item No.", ItemNo);
        WhseShipmentLine.CalcSums("Qty. Picked");
        exit(WhseShipmentLine."Qty. Picked");
    end;

    procedure CalcItemPickedQuantityByShipment(WhseShipmentNo: Code[20]; ItemNo: Code[20]; LineNo: Integer): Decimal
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WhseShipmentLine.SetCurrentKey("Item No.");
        WhseShipmentLine.SetRange("No.", WhseShipmentNo);
        WhseShipmentLine.SetRange("Line No.", LineNo);
        WhseShipmentLine.SetRange("Item No.", ItemNo);
        WhseShipmentLine.CalcSums("Qty. Picked");
        exit(WhseShipmentLine."Qty. Picked");
    end;

    procedure CalcItemQuantityInBoxesByOrder(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    var
        BoxLine: Record "Box Line";
    begin
        BoxLine.SetCurrentKey("Sales Order No.", "Item No.");
        BoxLine.SetRange("Sales Order No.", SalesOrderNo);
        BoxLine.SetRange("Item No.", ItemNo);
        BoxLine.CalcSums("Quantity in Box");
        exit(BoxLine."Quantity in Box");
    end;

    procedure CalcItemQuantityInBoxesByShipment(WhseShipmentNo: Code[20]; ItemNo: Code[20]; LineNo: Integer): Decimal
    var
        BoxLine: Record "Box Line";
    begin
        BoxLine.SetCurrentKey("Shipment No.", "Shipment Line No.", "Item No.");
        BoxLine.SetRange("Shipment No.", WhseShipmentNo);
        BoxLine.SetRange("Shipment Line No.", LineNo);
        BoxLine.SetRange("Item No.", ItemNo);
        BoxLine.CalcSums("Quantity in Box");
        exit(BoxLine."Quantity in Box");
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
        BoxLine.SetRange("Box No.", BoxNo);
        BoxLine.CalcSums("Quantity in Box");
        exit(BoxLine."Quantity in Box");
    end;

    procedure PackageUnRegistered(PackageNo: Code[20]): Boolean
    var
        PackageHeader: Record "Package Header";
    begin
        PackageHeader.Get(PackageNo);
        exit(PackageHeader.Status = PackageHeader.Status::Unregistered);
    end;

    procedure DeleteEmptyBoxes(PackageNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        GetWhseSetup();
        if not WhseSetup."Delete Empty Box" then exit;

        BoxHeader.SetRange("Package No.", PackageNo);
        BoxHeader.FindSet();
        repeat
            if BoxIsEmpty(BoxHeader."No.") then
                BoxHeader.Delete(true);
        until BoxHeader.Next() = 0;
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
                BoxLine.SetCurrentKey("Quantity in Box");
                BoxLine.SetRange("Box No.", BoxHeader."No.");
                BoxLine.SetRange("Quantity in Box", 0);
                BoxLine.DeleteAll(true);
            until BoxHeader.Next() = 0;
    end;

    procedure DeleteEmptyLinesByBox(BoxNo: Code[20])
    var
        BoxLine: Record "Box Line";
    begin
        GetWhseSetup();
        if not WhseSetup."Delete Empty Lines" then exit;

        BoxLine.SetCurrentKey("Quantity in Box");
        BoxLine.SetRange("Box No.", BoxNo);
        BoxLine.SetRange("Quantity in Box", 0);
        BoxLine.DeleteAll(true);
    end;

    procedure BoxIsEmpty(BoxNo: Code[20]): Boolean
    var
        BoxLine: Record "Box Line";
    begin
        BoxLine.SetCurrentKey("Quantity in Box");
        BoxLine.SetRange("Box No.", BoxNo);
        BoxLine.SetFilter("Quantity in Box", '>%1', 0);
        exit(BoxLine.IsEmpty);
    end;

    procedure WhseShipmentIsPosted(ShipmentNo: Code[20]; LineNo: Integer): Boolean
    var
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
    begin
        PostedWhseShipmentLine.SetCurrentKey("Whse. Shipment No.", "Whse Shipment Line No.");
        PostedWhseShipmentLine.SetRange("Whse. Shipment No.", ShipmentNo);
        PostedWhseShipmentLine.SetRange("Whse Shipment Line No.", LineNo);
        exit(PostedWhseShipmentLine.FindFirst());
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
            if not SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo) then begin
                salesInvHeader.SetCurrentKey("Order No.");
                salesInvHeader.SetFilter("Order No.", SalesOrderNo);
                salesInvHeader.FindFirst();
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
        if BoxHeader.Get(PackageNo, BoxNo) and (BoxHeader.Status = BoxHeader.Status::Open) then begin
            BoxHeader.TestField("Gross Weight");
            BoxHeader.Validate(Status, BoxHeader.Status::Closed);
            BoxHeader.Modify(true);
        end;
    end;

    procedure OpenBox(PackageNo: Code[20]; BoxNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        if not PackageUnRegistered(PackageNo) then
            Error(errPackageMustBeUnregister, PackageNo);

        if BoxHeader.Get(PackageNo, BoxNo) then
            if BoxHeader.Status = BoxHeader.Status::Closed then begin
                BoxHeader.TestField("Tracking No.", '');
                BoxHeader.Validate(Status, BoxHeader.Status::Open);
                BoxHeader.Modify(true);
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

        if BoxHeader.Get(PackageNo, BoxNo) then begin
            BoxHeader.TestField("Tracking No.", '');
            BoxHeader.Delete(true);
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
        if not glShipStationSetup.Get() then begin
            glShipStationSetup.Init();
            glShipStationSetup.Insert();
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
        JSObjectHeader.Add('weight', jsonGrossWeight(_BoxHeader."Gross Weight", Format(_BoxHeader."Unit of Measure")));
        JSObjectHeader.WriteTo(JSText);

        JSText := ShipStationMgt.Connect2ShipStation(2, JSText, '');
        JSObjectHeader.ReadFrom(JSText);
        exit(JSObjectHeader);
    end;

    local procedure jsonGrossWeight(GrossWeight: Decimal; UoM: Text): JsonObject
    var
        JSObjectLine: JsonObject;
    begin
        JSObjectLine.Add('value', GrossWeight);
        JSObjectLine.Add('units', UoM);
        exit(JSObjectLine);
    end;

    procedure jsonItemsFromBoxLines(BoxNo: Code[20]): JsonArray
    var
        JSObjectLine: JsonObject;
        JSObjectArray: JsonArray;
        _BoxLine: Record "Box Line";
        // _BoxHeader: Record "Box Header";
        _ItemDescr: Record "Item Description";
        _SalesLine: Record "Sales Line";
    // GrossWeightPerItem: Decimal;
    // _UoM: Text;
    begin
        // with _BoxHeader do begin
        //     SetCurrentKey("Sales Order No.");
        //     SetRange("No.", BoxNo);
        //     FindFirst();
        //     GrossWeightPerItem := _BoxHeader."Gross Weight" / GetQuantityInBox(BoxNo);
        //     _UoM := Format("Unit of Measure");
        // end;

        _BoxLine.SetCurrentKey("Sales Order No.", "Quantity in Box");
        _BoxLine.SetRange("Box No.", BoxNo);
        _BoxLine.SetFilter("Quantity in Box", '<>%1', 0);
        if _BoxLine.FindSet(false, false) then
            repeat
                Clear(JSObjectLine);
                GetSalesLineFromBoxLine(_SalesLine, _BoxLine."Shipment No.", _BoxLine."Shipment Line No.");

                JSObjectLine.Add('lineItemKey', _BoxLine."Line No.");
                JSObjectLine.Add('sku', _BoxLine."Item No.");
                JSObjectLine.Add('name', _SalesLine.Description);
                if _ItemDescr.Get(_BoxLine."Item No.") then
                    JSObjectLine.Add('imageUrl', _ItemDescr."Main Image URL");
                // JSObjectLine.Add('weight', jsonGrossWeight(GrossWeightPerItem, _UoM));
                JSObjectLine.Add('quantity', ShipStationMgt.Decimal2Integer(_BoxLine."Quantity in Box"));
                JSObjectLine.Add('unitPrice', Round(_SalesLine."Amount Including VAT" / _SalesLine.Quantity, 0.01));
                JSObjectLine.Add('taxAmount', Round((_SalesLine."Amount Including VAT" - _SalesLine.Amount) / _SalesLine.Quantity, 0.01));
                JSObjectLine.Add('warehouseLocation', _SalesLine."Location Code");
                JSObjectLine.Add('productId', _BoxLine."Line No.");
                JSObjectLine.Add('adjustment', false);
                JSObjectArray.Add(JSObjectLine);
            until _BoxLine.Next() = 0;
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

        if not _BoxHeader.Get(PackageNo, BoxNo) then exit(false);
        // update Sales Header from ShipStation

        _jsonToken := ShipStationMgt.GetJSToken(_jsonObject, 'carrierCode');
        if not _jsonToken.AsValue().IsNull then begin
            _BoxHeader."Shipping Agent Code" := CopyStr(ShipStationMgt.GetJSToken(_jsonObject, 'carrierCode').AsValue().AsText(), 1, MaxStrLen(_BoxHeader."Shipping Agent Code"));
            _jsonToken := ShipStationMgt.GetJSToken(_jsonObject, 'serviceCode');
            if not _jsonToken.AsValue().IsNull then begin
                _BoxHeader."Shipping Services Code" := CopyStr(ShipStationMgt.GetJSToken(_jsonObject, 'serviceCode').AsValue().AsText(), 1, MaxStrLen(_BoxHeader."Shipping Services Code"));
            end;
        end;

        // Get Rate
        _BoxHeader."ShipStation Order ID" := ShipStationMgt.GetJSToken(_jsonObject, 'orderId').AsValue().AsText();
        _BoxHeader."ShipStation Order Key" := ShipStationMgt.GetJSToken(_jsonObject, 'orderKey').AsValue().AsText();
        _BoxHeader."ShipStation Status" := CopyStr(ShipStationMgt.GetJSToken(_jsonObject, 'orderStatus').AsValue().AsText(), 1, MaxStrLen(_BoxHeader."ShipStation Status"));
        _BoxHeader."ShipStation Shipment Amount" := ShipStationMgt.GetJSToken(_jsonObject, 'shippingAmount').AsValue().AsDecimal();

        // case "ShipStation Order Status" of
        //     "ShipStation Order Status"::"Not Sent":
        //         "ShipStation Order Status" := "ShipStation Order Status"::Sent;
        //     "ShipStation Order Status"::Sent:
        //         "ShipStation Order Status" := "ShipStation Order Status"::Updated;
        // end;

        if _BoxHeader."ShipStation Status" = lblAwaitingShipment then begin
            _BoxHeader."Tracking No." := '';
            _BoxHeader."ShipStation Shipment ID" := '';
        end;

        _BoxHeader.Modify();
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
        if (not _BoxHeader.Get(PackageNo, BoxNo)) or (_BoxHeader."ShipStation Order ID" = '') then Error(errorShipStationOrderNotExist);
        // comment to test Create Label and Attache to Warehouse Shipment
        if not ShipStationMgt.FindWarehouseSipment(_BoxHeader."Sales Order No.", WhseShipDocNo) then Error(errorWhseShipNotExist, _BoxHeader."Sales Order No.");

        if not SalesHeader.Get(SalesHeader."Document Type"::Order, _BoxHeader."Sales Order No.") then Error(errorOrderNotExist, _BoxHeader."Sales Order No.");

        // Get Order from Shipstation to Fill Variables
        JSText := ShipStationMgt.Connect2ShipStation(1, '', StrSubstNo('/%1', _BoxHeader."ShipStation Order ID"));
        JSObject.ReadFrom(JSText);

        // CheckUpdateBox(JSObject, 'orderId');
        // jsObjHeaderUpdate.ReadFrom(JSText);
        UpdateBoxFromShipStation(PackageNo, BoxNo, JSObject);
        JSText := ShipStationMgt.FillValuesFromOrder(JSObject, _BoxHeader."Sales Order No.", SalesHeader."Location Code");


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

    procedure ChangeShipStationStatusToShipped(PackageNo: Code[20]; BoxNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        BoxHeader.Get(PackageNo, BoxNo);
        BoxHeader."ShipStation Status" := lblShipped;
        BoxHeader.Modify();
    end;

    procedure UpdateBoxFromLabel(PackageNo: Code[20]; BoxNo: Code[20]; jsonText: Text);
    var
        _BoxHeader: Record "Box Header";
        jsLabelObject: JsonObject;
    begin
        if not _BoxHeader.Get(PackageNo, BoxNo) then exit;
        jsLabelObject.ReadFrom(jsonText);
        _BoxHeader."Other Cost" := ShipStationMgt.GetJSToken(jsLabelObject, 'insuranceCost').AsValue().AsDecimal();
        _BoxHeader."Shipment Cost" := ShipStationMgt.GetJSToken(jsLabelObject, 'shipmentCost').AsValue().AsDecimal();
        _BoxHeader."Tracking No." := ShipStationMgt.GetJSToken(jsLabelObject, 'trackingNumber').AsValue().AsText();
        _BoxHeader."ShipStation Shipment ID" := ShipStationMgt.GetJSToken(jsLabelObject, 'shipmentId').AsValue().AsText();
        _BoxHeader."ShipStation Status" := lblShipped;
        _BoxHeader.Modify();
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
        if (not _BoxHeader.Get(PackageNo, BoxNo)) or (_BoxHeader."ShipStation Shipment ID" = '') then exit(false);

        if not ShipStationMgt.FindWarehouseSipment(_BoxHeader."Sales Order No.", WhseShipDocNo) then
            Error(errorWhseShipNotExist, _BoxHeader."Sales Order No.");

        // Void Label in Shipstation
        JSObject.Add('shipmentId', _BoxHeader."ShipStation Shipment ID");
        JSObject.WriteTo(JSText);
        JSText := ShipStationMgt.Connect2ShipStation(8, JSText, '');
        // JSObject.ReadFrom(JSText);

        _txtBefore := _BoxHeader."No." + '-' + _BoxHeader."Tracking No.";
        FileName := StrSubstNo('%1-%2', _txtBefore, lblOrder);
        ShipStationMgt.DeleteAttachment(WhseShipDocNo, FileName);

        // Update Box Header From ShipStation
        // JSText := ShipStationMgt.Connect2ShipStation(1, '', StrSubstNo('/%1', "ShipStation Order ID"));
        // JSObject.ReadFrom(JSText);
        // UpdateBoxFromShipStation(PackageNo, BoxNo, JSObject);
        CleareTrackingNoShipmentID(PackageNo, BoxNo);
    end;

    procedure CleareTrackingNoShipmentID(PackageNo: Code[20]; BoxNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        BoxHeader.Get(PackageNo, BoxNo);
        BoxHeader."Tracking No." := '';
        BoxHeader."ShipStation Shipment ID" := '';
        BoxHeader."ShipStation Status" := lblAwaitingShipment;
        BoxHeader.Modify();
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

        _salesLineLast.SetRange("Document Type", _salesLineLast."Document Type"::Order);
        _salesLineLast.SetRange("Document No.", salesOrderNo);
        _salesLineLast.SetRange("No.", _customer."Sales No. Shipment Cost");
        if _salesLineLast.FindFirst() then begin
            salesLineExist := true;
            LineNo := _salesLineLast."Line No."
        end else begin
            _salesLineLast.SetRange("No.");
            if _salesLineLast.FindLast() then
                LineNo := _salesLineLast."Line No." + 10000
            else
                LineNo := 10000;
        end;

        if _salesHeader.Status = _salesHeader.Status::Released then begin
            _salesHeader.Status := _salesHeader.Status::Open;
            _salesHeader.Modify();
        end;

        if salesLineExist then
            _salesLine.Get(_salesLine."Document Type"::Order, salesOrderNo, LineNo)
        else begin
            _salesLine.Init;
            _salesLine."Document Type" := _salesLine."Document Type"::Order;
            _salesLine."Document No." := salesOrderNo;
            _salesLine."Line No." := LineNo;
            _salesLine.Insert(true);
        end;
        _salesLine.Validate(Type, _customer."Posting Type Shipment Cost");
        _salesLine.Validate(Quantity, 1);
        _salesLine.Validate("No.", _customer."Sales No. Shipment Cost");
        // Validate("Amount Including VAT", PackageShippingAmount);
        _salesLine.Validate("Unit Price", PackageShippingAmount);
        _salesLine.Modify(true);

        _salesHeader.Status := _salesHeader.Status::Released;
        _salesHeader.Modify();

        ICExtended.CreateItemChargeAssgnt(_salesHeader."No.", _salesHeader."Sell-to Customer No.");
    end;

    procedure DeleteItemChargeSalesLine(salesOrderNo: Code[20]; ItemNo: Code[20])
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
    begin
        salesHeader.Get(salesHeader."Document Type"::Order, salesOrderNo);
        if salesHeader.Status = salesHeader.Status::Released then begin
            salesHeader.Status := salesHeader.Status::Open;
            salesHeader.Modify();
        end;

        salesLine.SetCurrentKey("No.");
        salesLine.SetRange("Document Type", salesLine."Document Type"::Order);
        salesLine.SetRange("Document No.", salesOrderNo);
        salesLine.SetRange("No.", ItemNo);
        salesLine.DeleteAll(true);

        if salesHeader.Status = salesHeader.Status::Open then begin
            salesHeader.Status := salesHeader.Status::Released;
            salesHeader.Modify();
        end;
    end;

    procedure GetPackageShippingAmountFromSalesOrder(salesOrderNo: Code[20]): Decimal
    var
        boxHeader: Record "Box Header";
    begin
        boxHeader.SetCurrentKey("Sales Order No.", "ShipStation Shipment ID");
        boxHeader.SetRange("Sales Order No.", salesOrderNo);
        boxHeader.SetFilter("ShipStation Shipment ID", '<>%1', '');
        boxHeader.CalcSums("Shipment Cost", "Other Cost", "ShipStation Shipment Amount");
        exit(boxHeader."Shipment Cost" + boxHeader."Other Cost" + boxHeader."ShipStation Shipment Amount");
    end;
}