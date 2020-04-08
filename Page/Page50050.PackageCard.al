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
                    ToolTipML = ENU = 'Specifies the sales order number on the basis of which the packaging document was created',
                                RUS = 'Определяет номер заказа продажи на основании которого был создан документ упаковки.';
                }
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Create User ID"; "Create User ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the user id that created the packaging document.',
                                RUS = 'Определяет код пользователя который создал документ упаковки.';
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time the packaging document was created.',
                                RUS = 'Определяет дату и время создания документа упаковки.';
                }
                field("Last Modified User ID"; "Last Modified User ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the user id that last modified the packaging document.',
                                RUS = 'Определяет код пользователя который последним изменил документ упаковки.';
                }
                field("Last Modified Date"; "Last Modified Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time of the last modification of the packaging document.',
                                RUS = 'Определяет дату и время последниего изменения документа упаковки.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies status the packaging document.',
                                RUS = 'Определяет статус документа упаковки.';
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
                ToolTipML = ENU = 'Register package document to the next stage of processing. You must unregister the document before you can make changes to it.',
                            RUS = 'Зарегистрировать документов упаковки на следующий этап обработки. Необходимо отменить регистрацию документа, чтобы в него можно было вносить изменения.';
                Image = RegisterPick;

                trigger OnAction()
                begin
                    PackageBoxMgt.CheckPackageBeforeRegister("No.");
                    PackageBoxMgt.DeleteEmptyLines("No.");
                    PackageBoxMgt.DeleteEmptyBoxes("No.");
                    PackageBoxMgt.CloseAllBoxes("No.");
                    PackageBoxMgt.RegisterPackage("No.");
                end;
            }
            action(UnRegistered)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'UnRegister', RUS = 'Отменить регистрацию';
                ToolTipML = ENU = 'Unregister package document to change.',
                            RUS = 'Отменить регистрацию документа упаковки для изменения.';
                Enabled = Status = Status::Registered;
                Image = Undo;

                trigger OnAction()
                begin
                    PackageBoxMgt.CheckWhseShipmentExist("No.");
                    PackageBoxMgt.ReOpenAllBoxes("No.");
                    PackageBoxMgt.UnRegisterPackage("No.");
                end;
            }
            action(CloseAll)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Close All', RUS = 'Закрыть Все';
                ToolTipML = ENU = 'Close all of the box document to the next stage of processing. You must reopen the document before you can make changes to it.',
                            RUS = 'Закрытие всех документов коробки на следующий этап обработки. Необходимо заново открыть документ, чтобы в него можно было вносить изменения.';
                Enabled = Status = Status::UnRegistered;
                Image = ItemLines;

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
                ToolTipML = ENU = 'Reopen all the document of the box to change.',
                            RUS = 'Повторное открытие всех документа коробки для их изменения.';
                Enabled = Status = Status::UnRegistered;
                Image = RefreshLines;

                trigger OnAction()
                begin
                    PackageBoxMgt.ReOpenAllBoxes("No.");
                end;
            }
            action(DeleteEmptyBoxes)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Delete Empty Boxes', RUS = 'Удалить пустые коробки';
                ToolTipML = ENU = 'Delete empty box documents.',
                            RUS = 'Удаление пустых документов коробки.';
                Enabled = Status = Status::UnRegistered;
                Image = Delete;

                trigger OnAction()
                begin
                    PackageBoxMgt.DeleteEmptyBoxes("No.");
                end;
            }
            action(DeleteEmptyLines)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Delete Empty Lines', RUS = 'Удалить пустые строки';
                ToolTipML = ENU = 'Delete blank lines in box documents.',
                            RUS = 'Удаление пустых строк в документах коробки.';
                Enabled = Status = Status::UnRegistered;
                Image = DeleteRow;

                trigger OnAction()
                begin
                    PackageBoxMgt.DeleteEmptyLines("No.");
                end;
            }
        }
    }

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}