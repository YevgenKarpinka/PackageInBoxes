pageextension 50051 "Warehouse Pick Ext." extends "Warehouse Pick" //5779
{
    layout
    {

    }

    actions
    {
        addafter("Delete Qty. to Handle")
        {
            action(PackageInBox)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Package In Box', RUS = 'Упаковка в коробки';
                Image = InventoryPick;

                trigger OnAction()
                var
                    PackageHeader: Record "Package Header";
                begin
                    if not PackageBoxMgt.CreateNewPackageFromWarehousePick(PackageHeader, Rec) then exit;
                    Page.RunModal(Page::"Package In Boxes", PackageHeader);
                end;
            }
        }
    }

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}