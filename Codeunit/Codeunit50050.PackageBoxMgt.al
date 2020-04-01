codeunit 50050 "Package Box Mgt."
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    procedure CreateNewPackageFromWarehousePick(var PackageHeader: Record "Package Header"; WhseShipmentHeader: Record "Warehouse Shipment Header"): Boolean
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        RegWhseActLine: Record "Registered Whse. Activity Line";
    begin
        with WhseShipmentHeader do begin

        end;

        with RegWhseActLine do begin
            SetRange("Source Document", "Source Document"::"Sales Order");
            SetRange("Source No.", WhseShipmentLine."Source No.");
            if not FindFirst() then exit(false);
        end;

        with PackageHeader do begin
            Init();
            "Reg. Whse Pick No." := RegWhseActLine."No.";
            "Warehouse Shipment No." := WhseShipmentLine."No.";
            "Sales Order No." := WhseShipmentLine."Source No.";
            if Insert(true) then;
        end;
        exit(true);
    end;
}