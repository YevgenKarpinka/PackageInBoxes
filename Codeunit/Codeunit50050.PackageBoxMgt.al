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
        WhseSetup: Record "Warehouse Setup";
        errItemPickedButNotFullyPackagedToBox: TextConst ENU = 'The Item %1 are picked to Shipment %2 but not fully packed!',
                                                              RUS = 'Товара %1 подобран в Отгрузке %2 но не упакован!';

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
            FindFirst();
            if not PackageUnRegistered(PackageHeader."No.") then exit;
        end;

        with WhseShptLine do begin
            SetCurrentKey("Source No.");
            SetRange("Source No.", WhseShptLine."Source No.");
            if FindSet() then
                repeat
                    CheckRemainingItemQuantityBeforeRegisterPackage(WhseShptLine."No.");
                until Next() = 0;
        end;

        CloseAllBoxes(PackageHeader."No.");
        RegisterPackage(PackageHeader."No.");
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
        if not PackageUnRegistered(PackageHeader."No.") then exit;

        with WhseShptLine do begin
            SetCurrentKey("Source Document", "Source No.");
            SetRange("Source Document", "Source Document"::"Sales Order");
            SetRange("Source No.", PackageHeader."Sales Order No.");
            FindFirst();
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
                        Error(errItemPickedButNotFullyPackagedToBox, "Item No.", "No.");
                until Next() = 0;
        end;
    end;

    procedure CreateNewPackageFromWarehouseShipment(var PackageHeader: Record "Package Header"; WhseShipmentHeader: Record "Warehouse Shipment Header"): Boolean
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        WhseActLine: Record "Warehouse Activity Line";
    begin
        with WhseShipmentLine do begin
            SetRange("No.", WhseShipmentHeader."No.");
            FindFirst();
        end;

        with PackageHeader do begin
            SetCurrentKey("Sales Order No.");
            SetRange("Sales Order No.", WhseShipmentLine."Source No.");
            if FindFirst() then exit(true);
        end;

        with WhseActLine do begin
            SetCurrentKey("Source Document", "Source No.");
            SetRange("Source Document", "Source Document"::"Sales Order");
            SetRange("Source No.", WhseShipmentLine."Source No.");
            FindFirst();
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
        BoxHeader.Get(PackageNo, BoxNo);

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
                SetRange("Shipment No.");
                SetRange("Item No.");
                SetRange("Shipment Line No.");
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
        CheckRemainingItemQuantityBeforeRegisterPackage(PackageNo);
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
            if Status = Status::UnRegistered then exit;
            Status := Status::UnRegistered;
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
            SetCurrentKey("Shipment No.", "Item No.", "Line No.");
            SetRange("Shipment No.", WhseShipmentNo);
            SetRange("Shipment Line No.", LineNo);
            SetRange("Item No.", ItemNo);
            CalcSums("Quantity in Box");
            exit("Quantity in Box");
        end;
    end;

    procedure GetRemainingItemQuantityInOrder(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    begin
        exit(CalcItemQuantityInOrder(SalesOrderNo, ItemNo) -
             CalcItemQuantityInBoxesByOrder(SalesOrderNo, ItemNo));
    end;

    procedure GetRemainingItemQuantityInShipment(WhseShipmentNo: Code[20]; ItemNo: Code[20]; LineNo: Integer): Decimal
    begin
        exit(CalcItemPickedQuantitybyShipment(WhseShipmentNo, ItemNo, LineNo) -
             CalcItemQuantityInBoxesByShipment(WhseShipmentNo, ItemNo, LineNo));
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
            exit(Status = Status::UnRegistered);
        end;
    end;

    procedure DeleteEmptyBoxes(PackageNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
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
        with BoxHeader do begin
            SetRange("Package No.", PackageNo);
            FindSet();
        end;

        with BoxLine do begin
            SetCurrentKey("Sales Order No.");
            SetRange("Sales Order No.", BoxHeader."Sales Order No.");
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

    local procedure GetWhseSetup()
    begin
        WhseSetup.Get();
    end;
}