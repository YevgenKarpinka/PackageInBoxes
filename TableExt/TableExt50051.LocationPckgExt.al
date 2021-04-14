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
    }
}