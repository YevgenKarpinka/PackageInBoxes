page 50057 "Package List"
{
    CaptionML = ENU = 'Package List',
                RUS = 'Список Упаковки';
    InsertAllowed = false;
    SourceTable = "Package Header";
    SourceTableView = sorting("No.")
                      order(Descending);
    DataCaptionFields = "No.", "Sales Order No.";
    PageType = Document;
    RefreshOnActivate = true;
    ApplicationArea = Warehouse;
    UsageCategory = Lists;

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
}