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

    procedure CreateNewPackageFromWarehousePick(var PackageHeader: Record "Package Header"; WhseShipmentHeader: Record "Warehouse Shipment Header"): Boolean
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
        SalesLine: Record "Sales Line";
        BoxHeader: Record "Box Header";
        RemainingQuantity: Decimal;
    begin
        BoxHeader.Get(PackageNo, BoxNo);

        with SalesLine do begin
            SetCurrentKey("Document Type", "Document No.", Type);
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", BoxHeader."Sales Order No.");
            SetRange(Type, Type::Item);
            FindSet();
            repeat
                RemainingQuantity := GetRemainingItemQuantityInOrder("Document No.", "No.");
                if RemainingQuantity > 0 then
                    AddItemToBox(BoxNo, "No.", RemainingQuantity);
            until Next() = 0;
        end;
    end;

    local procedure AddItemToBox(BoxNo: Code[20]; ItemNo: Code[20]; RemainingQuantity: Decimal);
    var
        BoxLine: Record "Box Line";
        LastBoxLine: Record "Box Line";
        LineNo: Integer;
    begin
        with LastBoxLine do begin
            SetRange("Box No.", BoxNo);
            SetRange("Item No.", ItemNo);
            if FindLast() then begin
                "Quantity in Box" += RemainingQuantity;
                Modify(true);
                exit;
            end else begin
                SetRange("Item No.");
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
            Insert(true);
        end;
    end;

    procedure CloseAllBoxes(PackageNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            SetRange("Package No.", "No.");
            ModifyAll(Status, Status::Close);
        end;
    end;

    procedure ReOpenAllBoxes(PackageNo: Code[20]);
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            SetRange("Package No.", "No.");
            ModifyAll(Status, Status::Open);
        end;
    end;

    procedure RegisteredPackage(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
    begin
        with PackageHeader do begin
            Get(PackageNo);
            if Status = Status::Registered then exit;
            Status := Status::Registered;
            Modify();
        end;
    end;

    procedure UnRegisteredPackage(PackageNo: Code[20])
    var
        PackageHeader: Record "Package Header";
    begin
        with PackageHeader do begin
            Get(PackageNo);
            if Status = Status::UnRegistered then exit;
            Status := Status::UnRegistered;
            Modify();
        end;
    end;

    procedure CalcItemQuantityInOrder(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
            SetCurrentKey("Document Type", "Document No.", "No.");
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", SalesOrderNo);
            SetRange(Type, Type::Item);
            SetRange("No.", ItemNo);
            CalcSums(Quantity);
            exit(Quantity);
        end;
    end;

    procedure CalcItemQuantityInBoxes(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
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

    procedure GetRemainingItemQuantityInOrder(SalesOrderNo: Code[20]; ItemNo: Code[20]): Decimal
    begin
        exit(CalcItemQuantityInOrder(SalesOrderNo, ItemNo) -
             CalcItemQuantityInBoxes(SalesOrderNo, ItemNo));
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
}