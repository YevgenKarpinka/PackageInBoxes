table 50052 "Box Line"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Box Line', RUS = 'Строки Коробки';

    fields
    {

        field(1; "Box No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Box No.', RUS = 'Коробка Но.';
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Line No.', RUS = 'Строка Но.';
            Editable = false;
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Item No.', RUS = 'Товар Но.';

            trigger OnLookup()
            var
                WhseShipmentLine: Record "Warehouse Shipment Line";
                tempWhseShipmentLine: Record "Warehouse Shipment Line" temporary;
                RemainingItemQuantity: Decimal;
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
                            if tempWhseShipmentLine.IsEmpty then begin
                                RemainingItemQuantity := PackageBoxMgt.GetRemainingItemQuantityInShipment("No.", "Item No.", "Line No.");
                                if RemainingItemQuantity > 0 then begin
                                    tempWhseShipmentLine := WhseShipmentLine;
                                    tempWhseShipmentLine."Qty. to Ship" := RemainingItemQuantity;
                                    tempWhseShipmentLine.Insert();
                                end;
                            end;
                        until Next() = 0;
                end;

                tempWhseShipmentLine.Reset();
                if tempWhseShipmentLine.Count = 0 then
                    Error(errPickedItemsPacked);

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
            CaptionML = ENU = 'Quantity in Box', RUS = 'Количество в коробке';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                BoxHeader: Record "Box Header";
                RemainingItemQuantity: Decimal;
            begin
                if xRec."Quantity in Box" = "Quantity in Box" then exit;

                with BoxHeader do begin
                    SetRange("No.", "Box No.");
                    FindFirst();
                    PackageBoxMgt.CheckWhseShipmentExist("Package No.");
                end;

                RemainingItemQuantity := PackageBoxMgt.GetRemainingItemQuantityInShipment("Shipment No.", "Item No.", "Shipment Line No.");
                if "Quantity in Box" > xRec."Quantity in Box" + RemainingItemQuantity then
                    Error(errRemainingQuantityToPacking, xRec."Quantity in Box" + RemainingItemQuantity);
            end;
        }
        field(5; "Sales Order No."; code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Sales Order No.', RUS = 'Заказ продажи Но.';
            Editable = false;
        }
        field(6; "Shipment No."; code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Shipment No.', RUS = 'Отгрузка Но.';
            Editable = false;
        }
        field(7; "Shipment Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Shipment Line No.', RUS = 'Строка отгрузки Но.';
            Editable = false;
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
        key(SK1; "Shipment No.", "Shipment Line No.", "Item No.")
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
        errRemainingQuantityToPacking: TextConst ENU = 'Remaining quantity to packing %1!',
                                                 RUS = 'Остаток для упаковки %1!';
        errPickedItemsPacked: TextConst ENU = 'Picked items are packed.',
                                        RUS = 'Подобранный товар упакован.';

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