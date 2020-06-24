report 50051 "Packing Slip"
{
    CaptionML = ENU = 'Packing Slip', RUS = 'Упаковочный лист';
    DefaultLayout = RDLC;
    RDLCLayout = 'Packing Slip.rdl';

    dataset
    {
        dataitem(PackageHeader; "Package Header")
        {
            RequestFilterFields = "No.";
            DataItemTableView = sorting("No.");

            column(CompanyName; PackageBoxMgt.GetCompanyName()) { }
            column(CompanyAddress; PackageBoxMgt.GetCompanyAddress()) { }
            column(CompanyCityCounty; PackageBoxMgt.GetCompanyCityStatePostCode()) { }
            column(CompanyPhone; PackageBoxMgt.GetCompanyPhone()) { }
            column(CompanyPhone2; PackageBoxMgt.GetCompanyPhone2()) { }
            column(CompanyEmail; PackageBoxMgt.GetCompanyEmail()) { }
            column(CompanyContactName; PackageBoxMgt.GetCompanyContactName()) { }
            column(BillToName; PackageBoxMgt.GetBillToNameByOrder("Sales Order No.")) { }
            column(BillToAddress; PackageBoxMgt.GetBillToaddressByOrder("Sales Order No.")) { }
            column(BillToCity; PackageBoxMgt.GetBillToCityByOrder("Sales Order No.")) { }
            column(ShipToName; PackageBoxMgt.GetShipToNameByOrder("Sales Order No.")) { }
            column(ShipToAddress; PackageBoxMgt.GetShipToAddressByOrder("Sales Order No.")) { }
            column(ShipToCity; PackageBoxMgt.GetShipToCityByOrder("Sales Order No.")) { }
            column(Sales_Order_No_; "Sales Order No.") { }
            column(OrderDate; PackageBoxMgt.GetSalesOrderData("Sales Order No.")) { }

            dataitem(BoxHeader; "Box Header")
            {
                DataItemTableView = sorting("No.");
                DataItemLink = "Package No." = field("No.");
                DataItemLinkReference = PackageHeader;

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
                    DataItemLinkReference = BoxHeader;

                    column(Position_No; PositionNo) { }
                    column(Item_No_; "Item No.") { }
                    column(Description; PackageBoxMgt.GetItemDescription("Item No.")) { }
                    column(ItemUoM; PackageBoxMgt.GetItemUoM("Item No.")) { }
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
    }

    requestpage
    {
        SaveValues = true;
        layout { }
        actions { }
    }

    labels { }

    var
        PackageBoxMgt: Codeunit "Package Box Mgt.";
        PositionNo: Integer;
}