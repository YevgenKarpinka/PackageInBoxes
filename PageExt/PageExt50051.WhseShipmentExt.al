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
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Create Package', RUS = 'Создать Упаковку';
                Image = InventoryPick;

                trigger OnAction()
                var
                    PackageHeader: Record "Package Header";
                begin
                    TestField(Status, Status::Released);
                    GetWhseSetup();
                    WhseSetup.TestField("Enable Box Packaging", true);
                    if not PackageBoxMgt.CreateNewPackageFromWarehousePick(PackageHeader, Rec) then exit;
                    Commit();
                    Page.RunModal(Page::"Package Card", PackageHeader);
                end;
            }
        }
    }

    local procedure GetWhseSetup()
    begin
        if not WhseSetupGetted then begin
            WhseSetup.Get();
            WhseSetupGetted := true;
        end;
    end;

    var
        WhseSetup: Record "Warehouse Setup";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        WhseSetupGetted: Boolean;
        VisibleCreatePackage: Boolean;
}