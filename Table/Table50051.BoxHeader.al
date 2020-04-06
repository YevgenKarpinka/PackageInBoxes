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
        field(5; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            NotBlank = true;
        }
        field(6; "Sales Order No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "External Document No."; Text[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(8; "Status"; Enum BoxStatus)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "No. Series"; Code[20])
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
        BoxModify();
    end;

    trigger OnModify()
    begin
        BoxModify();
    end;

    trigger OnDelete()
    begin
        DeleteBoxLine();
        BoxModify();
    end;

    trigger OnRename()
    begin

    end;

    procedure BoxModify()
    var
        PackageHeader: Record "Package Header";
    begin
        with PackageHeader do begin
            Get("Package No.");
            PackageModify();
        end;
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
        PackageHeader.Get("Package No.");
        "Sales Order No." := PackageHeader."Sales Order No.";

        if "No." = '' then begin
            TestNoSeries();
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", DT2Date(PackageHeader."Create Date"), "No.", "No. Series");
        end;

        "Create Date" := DT2Date(CurrentDateTime);
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

enum 50051 BoxStatus
{
    Extensible = true;

    value(0; Open)
    {
        CaptionML = ENU = 'Open', RUS = 'Открыта';
    }
    value(1; Close)
    {
        CaptionML = ENU = 'Close', RUS = 'Закрыта';
    }
}