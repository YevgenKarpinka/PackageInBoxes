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

                // field("Enable Box Packaging"; Rec."Enable Box Packaging")
                // {
                //     ApplicationArea = Warehouse;
                //     ToolTipML = ENU = 'Enabled or Disabled Packagin in Boxes.',
                //                 RUS = 'Включить или Выключить упаковку в коробки.';
                // }
                field("Create and Open Box"; Rec."Create and Open Box")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Enable or Disable opening a box document when it is created.',
                                RUS = 'Включить или Выключить открытие документа коробки при его создании.';
                }
                field("Unregister and Open Box"; Rec."Unregister and Status Open")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Enable or Disable change status of box to open when package unregistering.',
                                RUS = 'Включить или Выключить изменение статуса коробки на открыта при отмене регистрации упаковки.';
                }
                field("Delete Empty Box"; Rec."Delete Empty Box")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Enable or Disable the removal of empty box documents during registration of a packaging document.',
                                RUS = 'Включить или Выключить удаление пустых документов коробки во время регистрации документа упаковки.';
                }
                field("Delete Empty Lines"; Rec."Delete Empty Lines")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Enable or Disable the removal of blank lines of a box document during registration of a packaging document.',
                                RUS = 'Включить или Выключить удаление пустых строк документа коробки во время регистрации документа упаковки.';
                }
                field("Package No. Series"; Rec."Package No. Series")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number series code to use when you assign numbers to Package.',
                                RUS = 'Указывает код серии номеров, который будет использоваться при назначении номеров для упаковки.';
                }
                field("Box No. Series"; Rec."Box No. Series")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Specifies the number series code to use when you assign numbers to Box.',
                                RUS = 'Указывает код серии номеров, который будет использоваться при назначении номеров для коробки.';
                }
                field("Delete Label After Void"; Rec."Delete Label After Void")
                {
                    ApplicationArea = Warehouse;
                    ToolTipML = ENU = 'Deleting attachment when you voided label in Shipstation.',
                                RUS = 'Удаляет вложение при отмене метки в Shipstation.';
                }
            }
        }
    }
}