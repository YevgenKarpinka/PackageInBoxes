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
            // TableRelation = "Warehouse Activity Line" WHERE("Activity Type" = const(Pick),
            //                                                 "Whse. Document Type" = const(Shipment),
            //                                                 "Whse. Document No." = field("Warehouse Shipment No."),
            //                                                 "Action Type" = const(Place)
            // );
        }
        field(4; "Remaining Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(5; "Quantity in Box"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        // fields No. 6 and 7 reserved for to do
        field(8; "Sales Order No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Warehouse Shipment No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Reg. Warehouse Pick No."; code[20])
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
        key(SK; "Item No.")
        {

        }
    }

    var
        myInt: Integer;

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

}