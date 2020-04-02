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
        WhseActLine: Record "Warehouse Activity Line";
    begin
        with WhseShipmentLine do begin
            SetRange("No.", WhseShipmentHeader."No.");
            FindFirst();
        end;

        with PackageHeader do begin
            SetRange("Sales Order No.", WhseShipmentLine."Source No.");
            if FindFirst() then exit(true);
        end;

        with WhseActLine do begin
            SetRange("Source Document", "Source Document"::"Sales Order");
            SetRange("Source No.", WhseShipmentLine."Source No.");
            FindFirst();
        end;

        with PackageHeader do begin
            Init();
            "Sales Order No." := WhseShipmentLine."Source No.";
            // "Warehouse Shipment No." := WhseShipmentLine."No.";
            // "Whse. Pick No." := WhseActLine."No.";
            if Insert(true) then;
        end;

        exit(true);
    end;
}