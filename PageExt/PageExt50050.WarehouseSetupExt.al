pageextension 50050 "Warehouse Setup Ext." extends "Warehouse Setup" //5775
{
    layout
    {
        // Add changes to page layout here
        addafter(Numbering)
        {
            group(BoxPackage)
            {
                CaptionML = ENU = 'Box Package', RUS = 'Упаковка в коробку';
                field("Enable Box Packaging"; "Enable Box Packaging")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Enabled or Disabled Packagin in Box.';
                }
                field("Package No. Series"; "Package No. Series")
                {
                    ApplicationArea = Warehouse;
                    TableRelation = "No. Series";
                    ToolTipML = ENU = 'Specifies the number series code to use when you assign numbers to Package.';
                }
                field("Box No. Series"; "Box No. Series")
                {
                    ApplicationArea = Warehouse;
                    TableRelation = "No. Series";
                    ToolTipML = ENU = 'Specifies the number series code to use when you assign numbers to Box.';
                }
            }
        }
    }
}