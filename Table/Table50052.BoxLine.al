table 50052 "Box Line"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Box Line', RUS = 'Строки Коробки';

    fields
    {
        field(1; "Sales Order No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Box No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Warehouse Shipment Line"."Item No." WHERE("Source Document" = const("Sales Order"),
            //                 "Source No." = field("Sales Order No."));

            trigger OnLookup()
            var
                WhseShipmentLine: Record "Warehouse Shipment Line";
                Item: Record Item;
                tempItem: Record Item temporary;
            begin
                with WhseShipmentLine do begin
                    SetRange("Source Document", "Source Document"::"Sales Order");
                    SetRange("Source No.", "Sales Order No.");
                    if FindSet() then
                        repeat
                            if Item.Get(WhseShipmentLine."Item No.") then begin
                                tempItem := Item;
                                tempItem.Insert();
                            end;
                        until Next() = 0;
                end;

                if Page.RunModal(Page::"Item Lookup", tempItem) = Action::LookupOK then begin
                    Validate("Item No.", tempItem."No.");
                end;
            end;

            trigger OnValidate()
            begin
                CalcRemainingQuantity();
            end;
        }
        field(5; "Remaining Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(6; "Quantity in Box"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CalcRemainingQuantity();
            end;
        }
    }

    keys
    {
        key(PK; "Sales Order No.", "Box No.", "Line No.")
        {
            Clustered = true;
        }
        key(SK; "Item No.")
        {

        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    local procedure CalcRemainingQuantity()
    begin
        // to do
        // Error('Procedure not implemented.');
        "Remaining Quantity" := 11;
    end;
}