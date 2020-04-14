report 50050 "Packing List"
{
    CaptionML = ENU = 'Packing List', RUS = 'Упаковочный лист';
    DefaultLayout = RDLC;
    RDLCLayout = 'Packing List.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    AccessByPermission = report "Packing List" = x;

    dataset
    {
        dataitem(BoxHeader; "Box Header")
        {
            RequestFilterFields = "Package No.", "No.", "Sales Order No.";
            DataItemTableView = sorting("No.");

            column(Package_No_; "Package No.") { }
            column(Box_No; "No.") { }
            column(External_Document_No_; "External Document No.") { }
            column(Gross_Weight; "Gross Weight") { }
            column(QuantityInBox; PackageBoxMgt.GetQuantityInBox("No."))
            {
                DecimalPlaces = 0 : 5;
            }
            dataitem(BoxLine; "Box Line")
            {
                DataItemTableView = sorting("Shipment No.", "Item No.");
                DataItemLink = "Box No." = field("No.");

                column(Position_No; PositionNo) { }
                column(Item_No_; "Item No.") { }
                column(Quantity_in_Box; "Quantity in Box")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(Shipment_No_; "Shipment No.") { }
                column(Shipment_Line_No_; "Shipment Line No.") { }

                trigger OnAfterGetRecord()
                begin
                    PositionNo += 1;
                end;
            }

            trigger OnAfterGetRecord();
            begin
                PositionNo := 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout { }
        actions { }
    }

    labels { }

    trigger OnInitReport()
    begin

    end;

    trigger OnPreReport()
    begin

    end;

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        PositionNo: Integer;
}