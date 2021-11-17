pageextension 50008 MYCustomerList extends "My Customers"
{
    layout
    {
        // Add changes to page layout here
        addafter("Phone No.")
        {
            field("Mobile Phone No.";rec."Mobile Phone No.")
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
    }
    var myInt: Integer;
}
