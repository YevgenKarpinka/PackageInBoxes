tableextension 50051 "Location Pckg Ext." extends Location //5769
{
    fields
    {
        // Add changes to table fields here
        field(50050; "Enable Box Packaging"; Boolean)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Enable Box Packaging', RUS = 'Активировать Упаковку в Коробки';
        }
        // CAS-03614-Q4C7
        field(50051; "Extra Cost of the Box"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            CaptionML = ENU = 'Extra Cost of the Box', RUS = 'Добавочная стоимость коробки';
        }
    }
}