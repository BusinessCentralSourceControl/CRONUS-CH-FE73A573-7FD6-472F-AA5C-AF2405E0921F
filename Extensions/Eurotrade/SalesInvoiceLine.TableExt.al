tableextension 50007 SalesInvoiceLine extends "Sales Invoice Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000;"Country/Region of Origin Code";Code[20])
        {
        }
        field(50001;"Country/Region of Origin Text";Text[50])
        {
            Caption = 'Ursprungsland Text';
        }
        field(50002;"Tariff No.";Text[50])
        {
            Caption = 'Zolltarifnr.';
        }
    }
    var item: Record Item;
}
