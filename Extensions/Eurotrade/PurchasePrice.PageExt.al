pageextension 50005 PurchasePrice extends "Purchase Prices"
{
    layout
    {
        // Add changes to page layout here
        modify("Currency Code")
        {
        Visible = TRUE;
        }
    }
    var myInt: Integer;
}
