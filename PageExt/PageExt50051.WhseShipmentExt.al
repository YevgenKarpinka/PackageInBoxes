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
                ToolTipML = ENU = 'Create or Open Package, if package was created.',
                            RUS = 'Создать или Открыть Упаковку, если упаковка была уже создана.';
                Enabled = Status = Status::Released;
                Image = InventoryPick;

                trigger OnAction()
                var
                    PackageHeader: Record "Package Header";
                begin
                    TestField(Status, Status::Released);
                    GetWhseSetup();
                    WhseSetup.TestField("Enable Box Packaging", true);
                    if not PackageBoxMgt.CreateNewPackageFromWarehouseShipment(PackageHeader, Rec) then exit;
                    Commit();
                    Page.RunModal(Page::"Package Card", PackageHeader);
                end;
            }
        }
    }

    local procedure GetWhseSetup()
    begin
        WhseSetup.Get();
    end;

    var
        WhseSetup: Record "Warehouse Setup";
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}