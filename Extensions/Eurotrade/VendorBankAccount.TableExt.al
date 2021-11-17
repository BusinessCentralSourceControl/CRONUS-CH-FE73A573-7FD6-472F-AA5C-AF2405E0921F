tableextension 50004 VendorBankAccount extends "Vendor Bank Account"
{
    fields
    {
        // Add changes to table fields here
        field(50000;"Message to Reciver";Text[50])
        {
            Caption = 'Nachricht an Empfänger';
        }
    }
    var myInt: Integer;
}
