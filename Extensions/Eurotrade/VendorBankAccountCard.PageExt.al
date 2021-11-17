pageextension 50004 VendorBankAccountCard extends "Vendor Bank Account Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Bank Account No.")
        {
            field("Message to Reciver";rec."Message to Reciver")
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
    }
    var myInt: Integer;
}
