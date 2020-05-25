tableextension 50050 "Warehouse Setup Ext." extends "Warehouse Setup" //5769
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
        field(50053; "Delete Empty Box"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Delete Empty Box', RUS = 'Удалять пустые коробки';
        }
        field(50054; "Delete Empty Lines"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Delete Empty Lines', RUS = 'Удалять пустые строки';
        }
        field(50055; "Create and Open Box"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Create and Open Box', RUS = 'Создать и открыть Коробку';
        }
        field(50056; "Unregister and Status Open"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Unregister and Open Box', RUS = 'Отменить регистрацию и открыть коробку';
        }
    }
}