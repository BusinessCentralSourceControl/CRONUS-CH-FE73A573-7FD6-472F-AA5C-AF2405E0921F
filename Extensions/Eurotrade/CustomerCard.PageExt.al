pageextension 50003 CustomerCard extends "Customer card"
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
        addafter(Blocked)
        {
            field("B2C";rec."B2C")
            {
                Visible = true;
                ApplicationArea = all;
            }
            field("B2B";rec."B2B")
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
        modify("Name 2")
        {
        Visible = True;
        }
        addlast(General)
        {
            field("Industry Group";rec."Industry Group")
            {
                Visible = true;
                ApplicationArea = all;
            }
            field("Position";rec.Position)
            {
                Visible = true;
                ApplicationArea = all;
            }
            field("Newsletter";rec.Newsletter)
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
    }
    var myInt: Integer;
}
