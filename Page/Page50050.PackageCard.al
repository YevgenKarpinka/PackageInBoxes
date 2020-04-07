page 50050 "Package Card"
{
    CaptionML = ENU = 'Package Card', RUS = 'Карточка Упаковки';
    PageType = Card;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Package Header";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = false;

                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Create User ID"; "Create User ID")
                {
                    ApplicationArea = Warehouse;
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = Warehouse;
                }
                field("Last Modified User ID"; "Last Modified User ID")
                {
                    ApplicationArea = Warehouse;
                }
                field("Last Modified Date"; "Last Modified Date")
                {
                    ApplicationArea = Warehouse;
                }
                field(Status; Status)
                {
                    ApplicationArea = Warehouse;
                }
            }
            part(BoxesSubPage; "Boxes Subpage")
            {
                ApplicationArea = Warehouse;
                SubPageLink = "Package No." = field("No.");
                UpdatePropagation = Both;
                Editable = Status = Status::UnRegistered;
            }
        }
        area(FactBoxes)
        {
            part(BoxLineFactBox; "Box Lines FactBox")
            {
                ApplicationArea = Warehouse;
                Provider = BoxesSubPage;
                SubPageLink = "Box No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Register)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Register', RUS = 'Зарегистрировать';

                trigger OnAction()
                begin
                    PackageBoxMgt.CheckPackageBeforeRegister("No.");
                    PackageBoxMgt.CloseAllBoxes("No.");
                    PackageBoxMgt.RegisterPackage("No.");
                end;
            }
            action(UnRegistered)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'UnRegister', RUS = 'Отменить регистрацию';
                Enabled = Status = Status::Registered;

                trigger OnAction()
                begin
                    PackageBoxMgt.ReOpenAllBoxes("No.");
                    PackageBoxMgt.UnRegisterPackage("No.");
                end;
            }
            action(CloseAll)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Close All', RUS = 'Закрыть Все';
                Enabled = Status = Status::UnRegistered;

                trigger OnAction()
                var
                    BoxHeader: Record "Box Header";
                begin
                    PackageBoxMgt.CloseAllBoxes("No.");
                end;
            }
            action(ReOpenAll)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Reopen All', RUS = 'Открыть Все';
                Enabled = Status = Status::UnRegistered;

                trigger OnAction()
                begin
                    PackageBoxMgt.ReOpenAllBoxes("No.");
                end;
            }
            action(DeleteEmptyBoxes)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Delete Empty Boxes', RUS = 'Удалить пустые коробки';
                Enabled = Status = Status::UnRegistered;

                trigger OnAction()
                begin
                    PackageBoxMgt.DeleteEmptyBoxes("No.");
                end;
            }
        }
    }

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}