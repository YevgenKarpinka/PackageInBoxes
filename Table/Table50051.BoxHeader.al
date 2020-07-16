table 50051 "Box Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Package No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Package No.', RUS = 'Упаковка Но.';
            Editable = false;
        }
        field(2; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'No.', RUS = 'Но.';
            Editable = false;
        }
        field(3; "Box Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Box Code', RUS = 'Код коробки';
            TableRelation = Box;
        }
        field(4; "Create Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Create Date', RUS = 'Дата создания';
            Editable = false;
        }
        field(5; "Gross Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Gross Weight', RUS = 'Вес брутто';
            DecimalPlaces = 0 : 5;
            NotBlank = true;
        }
        field(6; "Sales Order No."; code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Sales Order No.', RUS = 'Заказа продажи Но.';
            Editable = false;
        }
        field(7; "External Document No."; Text[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'External Document No.', RUS = 'Внешний документ Но.';
            NotBlank = true;
        }
        field(8; "Status"; Enum BoxStatus)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Status', RUS = 'Статус';
            Editable = false;

            trigger OnValidate()
            begin
                if Status = Status::Close then begin
                    TestField("Gross Weight");
                    PackageBoxMgt.DeleteEmptyLinesByBox("No.");
                end;
            end;
        }
        field(9; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
            CaptionML = ENU = 'No. Series', RUS = 'Серия Но.';
            Editable = false;
        }
        field(10; "Tracking No."; Text[30])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Tracking No.', RUS = 'Отслеживания Но.';
        }
        field(11; "Shipping Agent Code"; Text[30])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Shipping Agent', RUS = 'Экспедитор';
            Editable = false;
        }
        field(12; "Shipping Services Code"; Text[100])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Shipping Agent Services', RUS = 'Услуга экспедитора';
            Editable = false;
        }
        field(13; "Shipment Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Shipment Cost', RUS = 'Стоимость доставки';
            Editable = false;
            DecimalPlaces = 0 : 2;
        }
        field(14; "Other Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Other Cost', RUS = 'Доп. стоимость';
            Editable = false;
            DecimalPlaces = 0 : 2;
        }
        field(15; "ShipStation Order ID"; Text[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Order ID', RUS = 'Идентификатор Заказа ShipStation';
            // Editable = false;
        }
        field(16; "ShipStation Order Key"; Text[50])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Order Key', RUS = 'Ключ Заказа ShipStation';
            // Editable = false;
        }
        field(17; "Unit of Measure"; Enum GrossWeightUoM)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Unit of Measure', RUS = 'Единица измерения';
        }
        field(18; "ShipStation Status"; Text[50])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Status', RUS = 'Статус ShipStation';
            Editable = false;
        }
        field(19; "ShipStation Shipment Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Shipment Amount', RUS = 'Сума отгрузки ShipStation';
        }
        field(20; "ShipStation Shipment ID"; Text[30])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Shipment ID', RUS = 'ID Отгрузки ShipStation';
            // Editable = false;
        }
    }

    keys
    {
        key(PK; "Package No.", "No.")
        {
            Clustered = true;
        }
        key(SK; "Sales Order No.", "Box Code")
        {

        }
    }

    var
        WhseSetup: Record "Warehouse Setup";
        asdas: Record "Unit of Measure";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        errDeleteBoxNotAllowedTrackingNoExist: TextConst ENU = 'Box document %1 cannot be deleted because the tracking number %2  is exist.',
                                           RUS = 'Документ коробки %1 удалить нельзя, потому что заполнен номер отслеживания %2.';

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
        if "Tracking No." <> '' then
            Error(errDeleteBoxNotAllowedTrackingNoExist, "No.", "Tracking No.");
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
        TestField(Status, Status::Open);
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

        "Create Date" := CurrentDateTime;
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
        WhseSetup.Get();
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
        CaptionML = ENU = 'Closed', RUS = 'Закрыта';
    }
}

enum 50052 GrossWeightUoM
{
    Extensible = true;

    value(0; pounds)
    {
        CaptionML = ENU = 'pounds', RUS = 'фунты';
    }
    value(1; ounces)
    {
        CaptionML = ENU = 'ounces', RUS = 'унции';
    }
    value(2; grams)
    {
        CaptionML = ENU = 'grams', RUS = 'граммы';
    }
}