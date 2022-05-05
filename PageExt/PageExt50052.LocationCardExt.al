pageextension 50052 "Location Card Ext." extends "Location Card" //5775
{
    layout
    {
        // Add changes to page layout here
        addafter("Create Move")
        {

            field("Enable Box Packaging"; Rec."Enable Box Packaging")
            {
                ApplicationArea = Warehouse;
                ToolTipML = ENU = 'Enabled or Disabled Packagin in Boxes.',
                            RUS = 'Включить или Выключить упаковку в коробки.';
            }
            field("Extra Cost of the Box"; Rec."Extra Cost of the Box")
            {
                ApplicationArea = Warehouse;
                ToolTipML = ENU = 'Extra Cost of the Box',
                            RUS = 'Указанная сумма увеличит стоимость доставки коробки.';
            }
        }
    }
}