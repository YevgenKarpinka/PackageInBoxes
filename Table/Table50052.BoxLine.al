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
                SalesLine: Record "Sales Line";
                Item: Record Item;
                tempItem: Record Item temporary;
            begin
                GetSalesOrderNo();
                with SalesLine do begin
                    SetCurrentKey(Type);
                    SetRange("Document Type", "Document Type"::Order);
                    SetRange("Document No.", "Sales Order No.");
                    SetRange(Type, Type::Item);
                    if FindSet() then
                        repeat
                            if not tempItem.get("No.")
                              and (PackageBoxMgt.GetRemainingItemQuantityInOrder("Sales Order No.", "No.") > 0) then begin
                                Item.Get("No.");
                                tempItem := Item;
                                tempItem.Insert();
                            end;
                        until Next() = 0;
                end;

                if Page.RunModal(Page::"Item Lookup", tempItem) = Action::LookupOK then begin
                    Validate("Item No.", tempItem."No.");
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
                RemainingItemQuantity := PackageBoxMgt.GetRemainingItemQuantityInOrder("Sales Order No.", "Item No.");
                if xRec."Quantity in Box" < "Quantity in Box" then
                    if "Quantity in Box" > RemainingItemQuantity then
                        Error(errAllowedQuantityLess, RemainingItemQuantity);
            end;
        }
        field(5; "Sales Order No."; code[20])
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
        errAllowedQuantityLess: TextConst ENU = 'Maximum Allowed Quantity %1!',
                                            RUS = 'Количество в Заказе продажи %1!';

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