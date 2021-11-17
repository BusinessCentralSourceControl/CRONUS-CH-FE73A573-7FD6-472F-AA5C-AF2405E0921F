pageextension 50009 SalesOrderSubform extends "Sales Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Shipment Date")
        {
            field("Country/Region of Origin Code";rec."Country/Region of Origin Code")
            {
                Visible = true;
                ApplicationArea = all;
            }
            field("Tariff No.";rec."Tariff No.")
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
    }
    var myInt: Integer;
}
