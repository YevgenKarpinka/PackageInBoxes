pageextension 50053 "Sales Order Ext" extends "Sales Order" //7335
{
    layout
    {

    }
    actions
    {
        addafter(PickLines)
        {
            action(Package)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Package', RUS = 'Упаковка';
                ToolTipML = ENU = 'Open Package if package created.',
                            RUS = 'Открыть Упаковку если упаковка создана.';
                Enabled = Rec.Status = Rec.Status::Released;
                Image = InventoryPick;

                trigger OnAction()
                var
                    PackageHeader: Record "Package Header";
                begin
                    GetPackageEnable();
                    PackageBoxMgt.OpenPackageFromSalesOrder(PackageHeader, Rec);
                    Page.RunModal(Page::"Package Card", PackageHeader);
                end;
            }
        }
    }

    local procedure GetPackageEnable()
    begin
        Location.Get(Rec."Location Code");
        Location.TestField("Enable Box Packaging");
    end;

    var
        Location: Record Location;
        PackageBoxMgt: Codeunit "Package Box Mgt.";
}