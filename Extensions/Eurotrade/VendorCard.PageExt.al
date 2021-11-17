pageextension 50001 VendorCard extends "Vendor card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Phone No.")
        {
            field("Phone No. 2";rec."Phone No. 2")
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
    }
    var myInt: Integer;
}
