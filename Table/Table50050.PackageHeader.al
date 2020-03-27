table 50050 "Package Header"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Package', RUS = 'Упаковка';

    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Create Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Create User ID"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Last Modified Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Last Modified User ID"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Packing Date"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Warehouse Shipment No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Warehouse Pick No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Create User Security ID"; Guid)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Last Modified User Security ID"; Guid)
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
        key(PK; "No.", "Create Date")
        {
            Clustered = true;
        }
    }

    var
        WhseSetup: Record "Warehouse Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        WhseSetupGetted: Boolean;
        errCantDeletePackageNo: TextConst ENU = 'Can''t Delete Package No. = %1', RUS = 'Нельзя удалить документ Упаковки Но. = %1';

    trigger OnInsert()
    begin
        InitInsert();
        ModifyRecord();
    end;

    trigger OnModify()
    begin
        ModifyRecord();
    end;

    trigger OnDelete()
    begin
        // Error(errCantDeletePackageNo, "No.");
        DeleteBoxHeader();
    end;

    trigger OnRename()
    begin

    end;

    local procedure InitInsert()
    begin
        if "No." = '' then begin
            TestNoSeries();
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", DT2Date("Create Date"), "No.", "No. Series");
        end;

        "Create Date" := CurrentDateTime;
        "Create User ID" := UserId;
        "Create User Security ID" := UserSecurityId();
    end;

    procedure ModifyRecord()
    begin
        "Last Modified Date" := CurrentDateTime;
        "Last Modified User ID" := UserId;
        "Last Modified User Security ID" := UserSecurityId();
    end;

    local procedure TestNoSeries()
    var
        WhseSetup: Record "Warehouse Setup";
    begin
        GetWhseSetup();
        with WhseSetup do
            TestField("Package No. Series");
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
    begin
        GetWhseSetup();
        NoSeriesCode := WhseSetup."Box No. Series";
        exit(NoSeriesMgt.GetNoSeriesWithCheck(NoSeriesCode, false, "No. Series"))
    end;

    local procedure DeleteBoxHeader();
    var
        BoxHeader: Record "Box Header";
    begin
        with BoxHeader do begin
            SetRange("Package No.", "No.");
            DeleteAll(true);
        end;
    end;

    local procedure GetWhseSetup()
    begin
        if WhseSetupGetted then exit;
        WhseSetup.Get();
        WhseSetupGetted := true;
    end;
}