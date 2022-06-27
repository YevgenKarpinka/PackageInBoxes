table 50054 "Link Setup"
{
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Code', RUS = 'Код';
        }
        field(2; Description; Text[50])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Description', RUS = 'Описание';
        }
        field(3; "Prefix URL"; Text[200])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Prefix URL', RUS = 'Префикс URL';
        }
        field(4; "Suffix URL"; Text[100])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Suffix URL', RUS = 'Суфикс URL';
        }
        field(5; Default; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Default', RUS = 'По умолчанию';
        }
        field(6; "Format URL"; Text[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Format URL', RUS = 'Формат URL';
        }
        field(7; "Example String"; Text[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Example String', RUS = 'Пример строки';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(SK; Default) { }
    }

    trigger OnInsert()
    begin
        if Default then
            CheckDefault;
    end;

    trigger OnModify()
    begin
        if Default then
            CheckDefault;
    end;

    var
        Text000: Label 'You can only have one default Link Code.';

    local procedure CheckDefault()
    var
        LinkSetup: Record "Link Setup";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckDefault(Rec, IsHandled);
        if IsHandled then
            exit;

        LinkSetup.SetCurrentKey(Default);
        LinkSetup.SetRange(Default, true);
        if LinkSetup.Count > 1 then
            Error(Text000);
    end;

    procedure GetPreviewURL(): Text
    begin
        exit(StrSubstNo("Format URL", "Prefix URL", "Example String", "Suffix URL"))
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDefault(var LinkSetup: Record "Link Setup"; var IsHandled: Boolean)
    begin
    end;
}