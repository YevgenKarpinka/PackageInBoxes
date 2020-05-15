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
        Item: Record Item;
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

            if not PackageUnRegistered(PackageHeader."No.") then
                Error(errPackageMustBeRegistered, PackageHeader."No.");
        end;

        CheckRemainingItemQuantityBeforeRegisterPackage(WhseShptLine."No.");
        DeleteEmptyBoxes(PackageHeader."No.");
        DeleteEmptyLines(PackageHeader."No.");
        CloseAllBoxes(PackageHeader."No.");
        RegisterPackage(PackageHeader."No.");
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Act.-Register (Yes/No)", 'OnAfterCode', '', false, false)]
    local procedure CreatePackageAfterRegisterPick(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        PackageHeader: Record "Package Header";
    begin
        GetWhseSetup();
        if not WhseSetup."Enable Box Packaging"
        and not (WarehouseActivityLine."Source Document" = WarehouseActivityLine."Source Document"::"Sales Order") then
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

    procedure AsemblyBox(PackageNo: Code[20]; BoxNo: Code[20])
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

    procedure CreateBox(PackageNo: Code[20]);
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
            ModifyAll(Status, Status::Close, true);
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
            ModifyAll(Status, Status::Open, true);
        end;
    end;

    procedure RegisterPackage(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
    begin
        // CheckRemainingItemQuantityBeforeRegisterPackage(PackageNo);
        with PackageHeader do begin
            Get(PackageNo);
            if Status = Status::Registered then exit;
            Status := Status::Registered;
            Modify(true);
        end;
    end;

    procedure UnRegisterPackage(PackageNo: Code[20])
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

    procedure DeleteEmptyLines(PackageNo: Code[20])
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
        if SalesOrderNo = SalesHeader."No." then exit;
        SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo);
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
        exit(SalesHeader."Bill-to Name" + SalesHeader."Bill-to Name 2");
    end;

    procedure GetShipToNameByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        exit(SalesHeader."Ship-to Name" + SalesHeader."Ship-to Name 2");
    end;

    procedure GetBillToAddressByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        exit(SalesHeader."Bill-to Address" + SalesHeader."Bill-to Address 2");
    end;

    procedure GetShipToAddressByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        exit(SalesHeader."Ship-to Address" + SalesHeader."Ship-to Address 2");
    end;

    procedure GetBillToCityByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        exit(SalesHeader."Bill-to City" + ', ' + SalesHeader."Bill-to County" + ' ' + SalesHeader."Bill-to Post Code");
    end;

    procedure GetShipToCityByOrder(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        exit(SalesHeader."Ship-to City" + ', ' + SalesHeader."Ship-to County" + ' ' + SalesHeader."Ship-to Post Code");
    end;

    procedure GetSalesOrderData(SalesOrderNo: Code[20]): Text
    begin
        GetSalesOrderByNo(SalesOrderNo);
        exit(Format(SalesHeader."Document Date"));
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if ItemNo = Item."No." then exit;
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
                Status := Status::Close;
                Modify();
            end;
        end;
    end;

    procedure ReopenBox(PackageNo: Code[20]; BoxNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        if not PackageUnRegistered(PackageNo) then
            Error(errPackageMustBeUnregister, PackageNo);
        with BoxHeader do begin
            if Status = Status::Close then begin
                Status := Status::Open;
                Modify();
            end;
        end;
    end;
}