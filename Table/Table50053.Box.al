table 50053 "Box"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Box', RUS = 'Коробка';
    LookupPageId = Boxes;
    DrillDownPageId = Boxes;

    fields
    {
        field(1; "Box Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Box Code', RUS = 'Код коробки';
        }
        field(2; Description; Text[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Description', RUS = 'Описание';
        }
        field(3; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Weight', RUS = 'Вес';
            DecimalPlaces = 0 : 5;
            NotBlank = true;
        }
        field(4; Length; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Length', RUS = 'Длинна';
            DecimalPlaces = 0 : 5;
        }
        field(5; Width; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Width', RUS = 'Ширина';
            DecimalPlaces = 0 : 5;
        }
        field(6; Height; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Height', RUS = 'Высота';
            DecimalPlaces = 0 : 5;
        }
        field(7; Cubage; Decimal)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Cubage', RUS = 'Объем';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

    }

    keys
    {
        key(PK; "Box Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Box Code", Description, Weight)
        {
        }
    }
    var
        errCantDeleteBoxBecouseHisExistInPackage: TextConst ENU = 'Can''t Delete Box = %1 Becouse His Exist In Package = %2',
                                                            RUS = 'Нельзя удалить коробку = %1 потому что она используется в упаковке = %2';

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin
        CalcCubage();
    end;

    trigger OnDelete()
    var
        BoxHeader: Record "Box Header";
    begin
        if BoxHeaderExist(BoxHeader) then
            Error(errCantDeleteBoxBecouseHisExistInPackage, "Box Code", BoxHeader."No.");
    end;

    trigger OnRename()
    begin

    end;

    local procedure BoxHeaderExist(var BoxHeader: Record "Box Header"): Boolean
    begin
        BoxHeader.SetCurrentKey("Box Code");
        BoxHeader.SetRange("Box Code", BoxHeader."No.");
        if BoxHeader.FindFirst() then
            exit(true);
        exit(false);
    end;

    local procedure CalcCubage()
    begin
        Cubage := Length * Width * Height;
    end;
}