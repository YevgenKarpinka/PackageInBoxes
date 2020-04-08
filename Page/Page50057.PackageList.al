page 50057 "Package List"
{
    CaptionML = ENU = 'Package List', RUS = 'Список Упаковки';
    PageType = List;
    ApplicationArea = Warehouse;
    UsageCategory = Lists;
    SourceTable = "Package Header";
    // CardPageId = "Package Card";
    RefreshOnActivate = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(repeaterName)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the sales order number on the basis of which the packaging document was created',
                                RUS = 'Определяет номер заказа продажи на основании которого был создан документ упаковки.';
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
        }
        area(FactBoxes)
        {
            part(BoxesFactBox; "Boxes FactBox")
            {
                ApplicationArea = Warehouse;
                SubPageLink = "Package No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenPackage)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Open Package', RUS = 'Открыть упаковку';
                ToolTipML = ENU = 'Open package document to the next view or changes. You must unregister the document before you can make changes to it.',
                            RUS = 'Открыть документов упаковки для просмотра либо изменения. Необходимо отменить регистрацию документа, чтобы в него можно было вносить изменения.';
                Image = Open;

                trigger OnAction()
                var
                    tempPackageHeader: Record "Package Header" temporary;
                begin
                    with tempPackageHeader do begin
                        tempPackageHeader := Rec;
                        Insert();
                    end;

                    Page.RunModal(Page::"Package Card", tempPackageHeader);
                end;
            }
            action(DeletePackage)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Delete Package', RUS = 'Удалить упаковку';
                ToolTipML = ENU = 'Remove documents from unregistered packaging. To delete a document, you must unregister.',
                            RUS = 'Удалить документов незарегистрированной упаковки. Чтобы удалить документ необходимо отменить регистрацию.';
                Image = Delete;

                trigger OnAction()
                var
                    PackageHeader: Record "Package Header";
                begin
                    CurrPage.SetSelectionFilter(PackageHeader);
                    with PackageHeader do begin
                        FindFirst();
                        repeat
                            if Status <> Status::UnRegistered then
                                Error(errPackageMustBeUnregistered, "No.");
                            Delete(true);
                        until Next() = 0;
                    end;
                end;
            }
        }
    }

    var
        errPackageMustBeUnregistered: TextConst ENU = 'Package %1 Must Be Unregistered!',
                                                RUS = 'Упаковка %1 должна быть не зарегистрирована!';
}