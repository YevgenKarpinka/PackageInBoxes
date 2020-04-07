page 50051 "Boxes Subpage"
{
    CaptionML = ENU = 'Boxes', RUS = 'Коробки';
    PageType = ListPart;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Box Header";
    CardPageId = "Box Card";
    InsertAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Warehouse;
                }
                field(Code; Code)
                {
                    ApplicationArea = Warehouse;
                }
                field(Weight; Weight)
                {
                    ApplicationArea = Warehouse;
                }
                field(QuantityInBox; PackageBoxMgt.GetQuantityInBox("No."))
                {
                    ApplicationArea = Warehouse;
                }
            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(Create)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Create', RUS = 'Создать';
                Image = PickLines;

                trigger OnAction()
                var
                    BoxHeader: Record "Box Header";
                begin
                    if not PackageBoxMgt.PackageUnRegistered("Package No.") then exit;
                    with BoxHeader do begin
                        Init();
                        "Package No." := Rec."Package No.";
                        Insert(true);
                    end;
                    Commit();
                    Page.RunModal(Page::"Box Card", BoxHeader);
                end;
            }
            action(Close)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Close', RUS = 'Закрыть';
                Image = ItemLines;

                trigger OnAction()
                var
                begin
                    if Status = Status::Open then begin
                        Status := Status::Close;
                        Modify();
                    end;
                end;
            }
            action(ReOpen)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'ReOpen', RUS = 'Открыть';
                Enabled = Status = Status::Close;
                Image = RefreshLines;

                trigger OnAction()
                var
                begin
                    if not PackageBoxMgt.PackageUnRegistered("Package No.") then exit;
                    if Status = Status::Close then begin
                        Status := Status::Open;
                        Modify();
                    end;
                end;
            }
            action(AssemblyBox)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Assembly', RUS = 'Собрать';
                Enabled = Status = Status::Open;
                Image = GetActionMessages;

                trigger OnAction()
                begin
                    if not PackageBoxMgt.PackageUnRegistered("Package No.") then exit;
                    PackageBoxMgt.AsemblyBox("Package No.", "No.");
                end;
            }
        }
    }

    var
        PackageHeader: Record "Package Header";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}