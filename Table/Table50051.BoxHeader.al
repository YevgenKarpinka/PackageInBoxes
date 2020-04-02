table 50051 "Box Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Package No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Box;

            trigger OnValidate()
            var
                Box: Record Box;
            begin
                if xRec.Code <> Rec.Code then begin
                    Box.Get(Code);
                    Weight := Box.Weight;
                end;
            end;
        }
        field(4; "Create Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Remaining Quantity"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum ("Box Line"."Remaining Quantity"
            where("Box No." = field("No."),
            "Sales Order No." = field("Sales Order No.")));
        }
        field(6; "Quantity in Box"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum ("Box Line"."Quantity in Box"
            where("Box No." = field("No."),
            "Sales Order No." = field("Sales Order No.")));
        }
        field(7; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            NotBlank = true;
        }
        field(8; "Sales Order No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "External Document No."; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Status"; Enum BoxStatus)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Package No.", "No.")
        {
            Clustered = true;
        }
        key(SK; Code)
        {

        }
    }

    var
        WhseSetup: Record "Warehouse Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        WhseSetupGetted: Boolean;

    trigger OnInsert()
    begin
        InitInsert();
        // InitInsertBoxLine();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        DeleteBoxLine();
    end;

    trigger OnRename()
    begin

    end;

    local procedure DeleteBoxLine();
    var
        BoxLine: Record "Box Line";
    begin
        with BoxLine do begin
            SetRange("Box No.", "No.");
            DeleteAll(true);
        end;
    end;

    local procedure InitInsert()
    var
        PackageHeader: Record "Package Header";
    begin
        if "No." = '' then begin
            TestNoSeries();
            PackageHeader.Get("Package No.");
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", DT2Date(PackageHeader."Create Date"), "No.", "No. Series");
        end;

        PackageHeader.SetRange("No.", "Package No.");
        PackageHeader.FindFirst();
        "Create Date" := DT2Date(CurrentDateTime);
        "Sales Order No." := PackageHeader."Sales Order No.";
        // "Warehouse Shipment No." := PackageHeader."Warehouse Shipment No.";
        // "Whse. Pick No." := PackageHeader."Whse. Pick No.";
    end;

    local procedure InitInsertBoxLine()
    var
        BoxLine: Record "Box Line";
    begin
        BoxLine.SetUpNewLine("No.");
    end;

    local procedure TestNoSeries()
    begin
        GetWhseSetup();
        with WhseSetup do
            TestField("Box No. Series");
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
    begin
        GetWhseSetup();
        NoSeriesCode := WhseSetup."Box No. Series";
        exit(NoSeriesMgt.GetNoSeriesWithCheck(NoSeriesCode, false, "No. Series"))
    end;

    local procedure GetWhseSetup()
    begin
        if WhseSetupGetted then exit;
        WhseSetup.Get();
        WhseSetupGetted := true;
    end;
}

enum 50050 BoxStatus
{
    Extensible = true;

    value(0; Open)
    {
        CaptionML = ENU = 'Open', RUS = 'Открыта';
    }
    value(1; Closed)
    {
        CaptionML = ENU = 'Closed', RUS = 'Закрыта';
    }
}