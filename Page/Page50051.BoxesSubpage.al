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
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time the box document was created.',
                                RUS = 'Определяет дату и время создания документа коробка.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies status the box document.',
                                RUS = 'Определяет статус документа коробка.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies external document number the box document.',
                                RUS = 'Определяет внешний номер документа коробка.';
                }
                field("Box Code"; "Box Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies a box code from a box reference.',
                                RUS = 'Определяет код коробки из справочника коробки.';
                }
                field("Gross Weight"; "Gross Weight")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies a gross weight of the box.',
                                RUS = 'Определяет вес брутто коробки.';
                }
                field(QuantityInBox; PackageBoxMgt.GetQuantityInBox("No."))
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Quantity in Box', RUS = 'Количество в коробке';
                    ToolTipML = ENU = 'Specifies the quantity of item that lies in the box.',
                                RUS = 'Определяет количество товара который лежит в коробке.';
                }
                field("Tracking No."; "Tracking No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery..',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
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
                ToolTipML = ENU = 'Create a box document so that you can put goods into it.',
                            RUS = 'Создать документ коробки чтобы в него можно было класть товар.';
                Image = PickLines;

                trigger OnAction()
                var
                    BoxHeader: Record "Box Header";
                begin
                    // if not PackageBoxMgt.PackageUnRegistered("Package No.") then
                    //     Error(errPackageMustBeUnregister, "Package No.");

                    // with BoxHeader do begin
                    //     Init();
                    //     "Package No." := Rec."Package No.";
                    //     Insert(true);
                    // end;

                    PackageBoxMgt.CreateBox("Package No.");

                    GetWhseSetup();
                    if not WhseSetup."Create and Open Box" then exit;
                    Commit();
                    Page.RunModal(Page::"Box Card", BoxHeader);
                end;
            }
            action(Close)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Close', RUS = 'Закрыть';
                ToolTipML = ENU = 'Close the box document to the next stage of processing. You must reopen the document before you can make changes to it.',
                            RUS = 'Закрытие документа коробки на следующий этап обработки. Необходимо заново открыть документ, чтобы в него можно было вносить изменения.';
                Enabled = Status = Status::Open;
                Image = ItemLines;

                trigger OnAction()
                begin
                    PackageBoxMgt.CloseBox("Package No.", "No.");
                end;
            }
            action(ReOpen)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Reopen', RUS = 'Открыть';
                ToolTipML = ENU = 'Reopen the box document to change.',
                            RUS = 'Повторное открытие документа коробки для его изменения.';
                Enabled = Status = Status::Close;
                Image = RefreshLines;

                trigger OnAction()
                var
                begin
                    PackageBoxMgt.OpenBox("Package No.", "No.");
                end;
            }
            action(AssemblyBox)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Assembly', RUS = 'Собрать';
                ToolTipML = ENU = 'Assembly in the box all the items remaining on the table.',
                            RUS = 'Собрать в коробку весь оставшийся на столе товар.';
                Enabled = Status = Status::Open;
                Image = GetActionMessages;

                trigger OnAction()
                begin
                    PackageBoxMgt.AsemblyBox("Package No.", "No.");
                end;
            }
        }
    }

    var
        WhseSetup: Record "Warehouse Setup";
        PackageHeader: Record "Package Header";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        errPackageMustBeUnregister: TextConst ENU = 'Package %1 must be unregister!',
                                              RUS = 'Упаковка %1 должна быть не зарегистрирована';

    local procedure GetWhseSetup()
    begin
        WhseSetup.Get();
    end;
}