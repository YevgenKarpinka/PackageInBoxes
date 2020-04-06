table 50053 "Box"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Box', RUS = 'Коробка';
    LookupPageId = Boxes;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            NotBlank = true;
        }
        field(4; Length; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(5; Width; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(6; Height; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(7; Cubage; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Description, Weight)
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
            Error(errCantDeleteBoxBecouseHisExistInPackage, Code, BoxHeader."No.");
    end;

    trigger OnRename()
    begin

    end;

    local procedure BoxHeaderExist(var BoxHeader: Record "Box Header"): Boolean
    begin
        with BoxHeader do begin
            SetCurrentKey(Code);
            SetRange(Code, Code);
            if FindFirst() then
                exit(true);
        end;
        exit(false);
    end;

    local procedure CalcCubage()
    begin
        Cubage := Length * Width * Height;
    end;
}