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
                field("No."; Rec."No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number of the involved entry or record, according to the specified number series.',
                                RUS = 'Определяет номер соответствующей записи или операции в соответствии с указанной серией номеров.';
                }
                field("Create Date"; Rec."Create Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the date and time the box document was created.',
                                RUS = 'Определяет дату и время создания документа коробка.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies status the box document.',
                                RUS = 'Определяет статус документа коробка.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies external document number the box document.',
                                RUS = 'Определяет внешний номер документа коробка.';
                }
                field("Box Code"; Rec."Box Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies a box code from a box reference.',
                                RUS = 'Определяет код коробки из справочника коробки.';
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies a gross weight of the box.',
                                RUS = 'Определяет вес брутто коробки.';
                }
                field(QuantityInBox; PackageBoxMgt.GetQuantityInBox(Rec."No."))
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Quantity in Box', RUS = 'Количество в коробке';
                    ToolTipML = ENU = 'Specifies the quantity of item that lies in the box.',
                                RUS = 'Определяет количество товара который лежит в коробке.';
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the trace number of the box for delivery.',
                                RUS = 'Определяет номер отслеживания коробки для доставки.';
                }
                field("ShipStation Shipment ID"; Rec."ShipStation Shipment ID")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the ShipStation shipmentID of the box.',
                                RUS = 'Определяет ShipStation ID отгрузки коробки.';
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
                    PackageBoxMgt.CreateBox(Rec."Package No.");

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
                Enabled = Rec.Status = Rec.Status::Open;
                Image = ItemLines;

                trigger OnAction()
                begin
                    BoxHeader.Reset();
                    CurrPage.SetSelectionFilter(BoxHeader);
                    BoxHeader.FindSet(false, false);
                    repeat
                        PackageBoxMgt.CloseBox(BoxHeader."Package No.", BoxHeader."No.");
                    until BoxHeader.Next() = 0;
                end;
            }
            action(ReOpen)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Reopen', RUS = 'Открыть';
                ToolTipML = ENU = 'Reopen the box document to change.',
                            RUS = 'Повторное открытие документа коробки для его изменения.';
                Enabled = Rec.Status = Rec.Status::Closed;
                Image = RefreshLines;

                trigger OnAction()
                begin
                    BoxHeader.Reset();
                    CurrPage.SetSelectionFilter(BoxHeader);
                    BoxHeader.FindSet(false, false);
                    repeat
                        PackageBoxMgt.OpenBox(BoxHeader."Package No.", BoxHeader."No.");
                    until BoxHeader.Next() = 0;
                end;
            }
            action(AssemblyBox)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Assembly', RUS = 'Собрать';
                ToolTipML = ENU = 'Assembly in the box all the items remaining on the table.',
                            RUS = 'Собрать в коробку весь оставшийся на столе товар.';
                Enabled = Rec.Status = Rec.Status::Open;
                Image = GetActionMessages;

                trigger OnAction()
                begin
                    PackageBoxMgt.AssemblyBox(Rec."Package No.", Rec."No.");
                end;
            }
        }
    }

    var
        WhseSetup: Record "Warehouse Setup";
        PackageHeader: Record "Package Header";
        BoxHeader: Record "Box Header";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        errPackageMustBeUnregister: TextConst ENU = 'Package %1 must be unregister!',
                                              RUS = 'Упаковка %1 должна быть не зарегистрирована';

    local procedure GetWhseSetup()
    begin
        WhseSetup.Get();
    end;
}