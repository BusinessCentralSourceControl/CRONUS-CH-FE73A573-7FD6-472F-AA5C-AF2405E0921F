pageextension 50002 ContactCard extends "Contact card"
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
        addafter("Name")
        {
            field("Name 2";rec."Name 2")
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
        addafter("Search Name")
        {
            field("Birthday";rec.Birthday)
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
        addlast(General)
        {
            field("Newsletter";rec.Newsletter)
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
    }
    var myInt: Integer;
}
