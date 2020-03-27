codeunit 50050 "Package Box Mgt."
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    procedure CreateNewPackageFromWarehousePick(var PackageHeader: Record "Package Header"; WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin
        with WhseActLine do begin
            SetRange("Activity Type", WhseActHeader.Type);
            SetRange("No.", WhseActHeader."No.");
            if not FindFirst() then exit(false);
        end;

        with PackageHeader do begin
            Init();
            "Warehouse Pick No." := WhseActLine."No.";
            "Warehouse Shipment No." := WhseActLine."Whse. Document No.";
            Insert(true);
        end;
    end;
}