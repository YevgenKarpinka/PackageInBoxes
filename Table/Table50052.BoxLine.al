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
            TableRelation = "Warehouse Shipment Line"."Item No." WHERE("Source Document" = const("Sales Order"),
                            "Source No." = field("Sales Order No."));

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

    var
        BoxNo: Code[20];

    trigger OnInsert()
    begin
        InitInsert();
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

    procedure SetUpNewBoxNo(newBoxNo: Code[20])
    begin
        BoxNo := newBoxNo;
    end;

    local procedure InitInsert()
    var
        BoxHeader: Record "Box Header";
    begin
        BoxHeader.SetRange("No.", BoxNo);
        BoxHeader.FindFirst();
        "Box No." := BoxNo;
        "Sales Order No." := BoxHeader."Sales Order No.";
        // "Warehouse Shipment No." := BoxHeader."Warehouse Shipment No.";
        // "Whse. Pick No." := BoxHeader."Whse. Pick No.";
    end;

    procedure SetUpNewLine(newBoxNo: Code[20])
    var
        BoxHeader: Record "Box Header";
    begin
        BoxNo := newBoxNo;
        BoxHeader.SetRange("No.", BoxNo);
        BoxHeader.FindFirst();
        Init();
        "Box No." := BoxNo;
        "Line No." := 10000;
        "Sales Order No." := BoxHeader."Sales Order No.";
        // "Warehouse Shipment No." := BoxHeader."Warehouse Shipment No.";
        // "Whse. Pick No." := BoxHeader."Whse. Pick No.";
        Insert();
    end;

    local procedure CalcRemainingQuantity()
    begin
        // to do
        // Error('Procedure not implemented.');
    end;
}