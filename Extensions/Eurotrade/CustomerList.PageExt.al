pageextension 50007 CustomerList extends "Customer List"
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
