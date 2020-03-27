tableextension 50050 "Warehouse Setup Ext." extends "Warehouse Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50050; "Enable Box Packaging"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Enable Box Packaging', RUS = 'Активировать Упаковку в Коробки';
        }
        field(50051; "Package No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Package No. Series', RUS = 'Серия Номеров Упаковки';
            TableRelation = "No. Series";
        }
        field(50052; "Box No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Box No. Series', RUS = 'Серия Номеров Коробки';
            TableRelation = "No. Series";
        }
    }
}