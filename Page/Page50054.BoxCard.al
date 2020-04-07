page 50054 "Box Card"
{
    CaptionML = ENU = 'Box Card', RUS = 'Карточка Коробки';
    PageType = Card;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Box Header";
    InsertAllowed = false;
    DeleteAllowed = true;


    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = Status = Status::Open;

                field("No.";
                "No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Sales Order No."; "Sales Order No.")
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
                field("Quantity In Box"; PackageBoxMgt.GetQuantityInBox("No."))
                {
                    ApplicationArea = Warehouse;
                }
            }
            part(BoxLinesSubPage; "Box Lines Subpage")
            {
                ApplicationArea = Warehouse;
                SubPageLink = "Box No." = field("No.");
                UpdatePropagation = Both;
                Editable = Status = Status::Open;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Close)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Close', RUS = 'Закрыть';
                Image = ItemLines;

                trigger OnAction()
                begin
                    if Status = Status::Open then begin
                        Status := Status::Close;
                        Modify(true);
                    end;
                end;
            }
            action(ReOpen)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Reopen', RUS = 'Открыть';
                Enabled = Status = Status::Close;
                Image = RefreshLines;

                trigger OnAction()
                begin
                    PackageHeader.Get("Package No.");
                    if PackageHeader.Status = PackageHeader.Status::UnRegistered then
                        if Status = Status::Close then begin
                            Status := Status::Open;
                            Modify(true);
                        end;
                end;
            }
            action(AssemblyBox)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Assembly', RUS = 'Собрать';
                Image = GetActionMessages;
                Enabled = Status = Status::Open;

                trigger OnAction()
                begin
                    PackageBoxMgt.AsemblyBox("Package No.", "No.");
                end;
            }
        }
    }

    var
        PackageHeader: Record "Package Header";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}