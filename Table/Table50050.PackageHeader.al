table 50050 "Package Header"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Package', RUS = 'Упаковка';
    LookupPageId = "Package List";
    DrillDownPageId = "Package List";

    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'No.', RUS = 'Но.';
            Editable = false;
        }
        field(2; "Create Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Create Date', RUS = 'Дата создания';
            Editable = false;
        }
        field(3; "Create User ID"; code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Create User ID', RUS = 'Создал Пользователь ID';
            Editable = false;
        }
        field(4; "Create User Security ID"; Guid)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Create User Security ID', RUS = 'Создал Пользователь Security ID';
            Editable = false;
        }
        field(5; "Last Modified Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Last Modified Date', RUS = 'Дата последнего изменение';
            Editable = false;
        }
        field(6; "Last Modified User ID"; code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Last Modified User ID', RUS = 'Последнее изменение Пользователь ID';
            Editable = false;
        }
        field(7; "Last Modified User Security ID"; Guid)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Last Modified User Security ID', RUS = 'Последнее изменение Пользователь Security ID';
            Editable = false;
        }
        field(8; "Sales Order No."; code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Sales Order No.', RUS = 'Заказ продажи Но.';
            Editable = false;
        }
        field(9; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
            CaptionML = ENU = 'No. Series', RUS = 'Серия Но.';
            Editable = false;
        }
        field(10; Status; Enum PackageStatus)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Status', RUS = 'Статус';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        WhseSetup: Record "Warehouse Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        WhseSetupGetted: Boolean;
        errCantDeletePackageNo: TextConst ENU = 'Can''t Delete Package No. = %1',
                                          RUS = 'Нельзя удалить документ Упаковки Но. = %1';
        errPackageMustBeUnregistered: TextConst ENU = 'Package %1 Must Be Unregistered!',
                                                RUS = 'Упаковка %1 должна быть не зарегистрирована!';

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
        if Status <> Status::UnRegistered then
            Error(errPackageMustBeUnregistered, "No.");
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

    procedure PackageModify()
    begin
        Modify(true);
    end;

    local procedure TestNoSeries()
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
        NoSeriesCode := WhseSetup."Package No. Series";
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

enum 50050 PackageStatus
{
    Extensible = true;

    value(0; UnRegistered)
    {
        CaptionML = ENU = 'Unregistered', RUS = 'Не зарегистрирован';
    }
    value(1; Registered)
    {
        CaptionML = ENU = 'Registered', RUS = 'Зарегистрирован';
    }
}