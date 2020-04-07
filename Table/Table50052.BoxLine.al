table 50052 "Box Line"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Box Line', RUS = 'Строки Коробки';

    fields
    {

        field(1; "Box No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            var
                WhseShipmentLine: Record "Warehouse Shipment Line";
                tempWhseShipmentLine: Record "Warehouse Shipment Line" temporary;
            begin
                GetSalesOrderNo();
                with WhseShipmentLine do begin
                    SetCurrentKey("Source Document", "Source No.");
                    SetRange("Source Document", "Source Document"::"Sales Order");
                    SetRange("Source No.", "Sales Order No.");
                    if FindSet() then
                        repeat
                            tempWhseShipmentLine.SetRange("No.", "No.");
                            tempWhseShipmentLine.SetRange("Item No.", "Item No.");
                            if tempWhseShipmentLine.IsEmpty
                              and (PackageBoxMgt.GetRemainingItemQuantityInShipment("No.", "Item No.", "Line No.") > 0) then begin
                                tempWhseShipmentLine := WhseShipmentLine;
                                tempWhseShipmentLine.Insert();
                            end;
                        until Next() = 0;
                end;

                if Page.RunModal(Page::"Whse. Shipment Item Lookup", tempWhseShipmentLine) = Action::LookupOK then begin
                    Validate("Item No.", tempWhseShipmentLine."Item No.");
                    Validate("Shipment No.", tempWhseShipmentLine."No.");
                    Validate("Shipment Line No.", tempWhseShipmentLine."Line No.");
                end;
            end;
        }
        field(4; "Quantity in Box"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                RemainingItemQuantity: Decimal;
            begin
                if xRec."Quantity in Box" = "Quantity in Box" then exit;
                RemainingItemQuantity := PackageBoxMgt.GetRemainingItemQuantityInShipment("Shipment No.", "Item No.", "Shipment Line No.");
                if "Quantity in Box" > xRec."Quantity in Box" + RemainingItemQuantity then
                    Error(errPickedQuantityInShipmentLessEntered, xRec."Quantity in Box" + RemainingItemQuantity, "Quantity in Box");
            end;
        }
        field(5; "Sales Order No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Shipment No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Shipment Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Box No.", "Line No.")
        {
            Clustered = true;
        }
        key(SK; "Sales Order No.", "Item No.")
        {

        }
    }

    trigger OnInsert()
    begin
        InitInsert();
        BoxLineModify();
    end;

    trigger OnModify()
    begin
        BoxLineModify();
    end;

    trigger OnDelete()
    begin
        BoxLineModify();
    end;

    trigger OnRename()
    begin

    end;

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        errPickedQuantityInShipmentLessEntered: TextConst ENU = 'Picked Quantity In Shipment %1\Entered Quantity %2\Not Allowed Enter Bigest Picked Quantity!',
                                            RUS = 'Подобранное количество %1\Ввели %2\Нельзя ввести больше подобранного количества!';

    local procedure InitInsert()
    var
        BoxHeader: Record "Box Header";
    begin
        if "Sales Order No." = '' then
            GetSalesOrderNo();
    end;

    local procedure GetSalesOrderNo()
    var
        BoxHeader: Record "Box Header";
    begin
        if "Sales Order No." <> '' then exit;
        with BoxHeader do begin
            SetRange("No.", "Box No.");
            FindFirst();
        end;
        "Sales Order No." := BoxHeader."Sales Order No.";
    end;

    local procedure BoxLineModify()
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            SetRange("No.", "Box No.");
            FindFirst();
            BoxModify();
        end;
    end;
}