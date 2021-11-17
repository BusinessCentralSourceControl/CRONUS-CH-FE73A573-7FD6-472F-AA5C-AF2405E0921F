tableextension 50009 MyCustomer extends "My Customer"
{
    fields
    {
        // Add changes to table fields here
        field(50000;"Mobile Phone No.";Text[50])
        {
            Caption = 'Mobiltelefon';
        }
    }
    var test: Record "My Customer";
}
