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
        }
        field(4; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Create Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Warehouse Shipment No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Warehouse Pick No."; code[20])
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
    end;

    local procedure TestNoSeries()
    var
        WhseSetup: Record "Warehouse Setup";
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