page 50059 "Link Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Link Setup";
    CaptionML = ENU = 'Link Setup',
                RUS = 'Ссылки Настройка';
    DataCaptionFields = Code, Description;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(repeaterName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                    ApplicationArea = All;
                }
                field(Default; Rec.Default)
                {
                    ToolTip = 'Specifies the value of the Default field.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = All;
                }
                field(Format; Rec."Format URL")
                {
                    ToolTip = 'Specifies the value of the Format URL field.';
                    ApplicationArea = All;
                }
                field("Prefix URL"; Rec."Prefix URL")
                {
                    ToolTip = 'Specifies the value of the Prefix URL field.';
                    ApplicationArea = All;
                }
                field("Suffix URL"; Rec."Suffix URL")
                {
                    ToolTip = 'Specifies the value of the Suffix URL field.';
                    ApplicationArea = All;
                }
                field("Example String"; Rec."Example String")
                {
                    ToolTip = 'Specifies the value of the Example String field.';
                    ApplicationArea = All;
                }
                field("Hyperlink Example"; Rec."Example String")
                {
                    Caption = 'Hyperlink Example';
                    ToolTip = 'Specifies the value of the Example String field.';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if DelChr(Rec."Example String", '<>', ' ') = '' then exit;
                        Hyperlink(Rec.GetPreviewURL());
                    end;
                }
                field("Preview URL"; Rec.GetPreviewURL())
                {
                    ToolTip = 'Specifies the value of the Example String field.';
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                }
            }
        }
    }
}