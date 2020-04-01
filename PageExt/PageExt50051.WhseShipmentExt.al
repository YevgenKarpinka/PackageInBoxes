pageextension 50051 "Warehouse Shipment Ext." extends "Warehouse Shipment" //7335
{
    layout
    {

    }

    actions
    {
        addafter("Create Pick")
        {
            action(CreatePackage)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Create Package', RUS = 'Создать Упаковку';
                Image = InventoryPick;

                trigger OnAction()
                var
                    PackageHeader: Record "Package Header";
                begin
                    if not PackageBoxMgt.CreateNewPackageFromWarehousePick(PackageHeader, Rec) then exit;
                    Page.RunModal(Page::"Package Card", PackageHeader);
                end;
            }
        }
    }

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}