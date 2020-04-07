page 50052 "Box Lines Subpage"
{
    CaptionML = ENU = 'Items in Box', RUS = 'Товары в коробке';
    PageType = ListPart;
    ApplicationArea = Warehouse;
    UsageCategory = Documents;
    SourceTable = "Box Line";
    AutoSplitKey = true;
    DelayedInsert = true;
    MultipleNewLines = true;


    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Quantity in Box"; "Quantity in Box")
                {
                    ApplicationArea = Warehouse;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Remaining Quantity"; PackageBoxMgt.GetRemainingItemQuantityInShipment("Shipment No.", "Item No.", "Shipment Line No."))
                {
                    ApplicationArea = Warehouse;
                    CaptionML = ENU = 'Remaining Quantity', RUS = 'Количество для упаковки';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action(ActionName)
            // {
            //     ApplicationArea = Warehouse;

            //     trigger OnAction()
            //     begin

            //     end;
            // }
        }
    }


    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}