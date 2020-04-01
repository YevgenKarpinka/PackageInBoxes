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

                }
                field("Package No. Series"; "Package No. Series")
                {

                }
                field("Box No. Series"; "Box No. Series")
                {

                }
            }
        }
    }
}