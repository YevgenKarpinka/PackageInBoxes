pageextension 50051 "Whse. Shipment Ext." extends "Warehouse Shipment" //7335
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
                    GetPackageEnable();
                    if not PackageBoxMgt.CreateNewPackageFromWarehouseShipment(PackageHeader, Rec) then exit;
                    Commit();
                    Page.RunModal(Page::"Package Card", PackageHeader);
                end;
            }
        }
    }

    local procedure GetPackageEnable()
    begin
        Location.Get("Location Code");
        Location.TestField("Enable Box Packaging");
    end;

    var
        Location: Record Location;
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}