pageextension 50000 ItemCard extends "Item card"
{
    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {
            field("no. 2";rec."No. 2")
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
            field("Statistik-Group";rec."Statistik-Group")
            {
                Visible = true;
                ApplicationArea = all;
            }
            field("Hersteller-Marke";rec."Hersteller-Marke")
            {
                Visible = true;
                ApplicationArea = all;
            }
            field("Parent Picture";rec."Parent Picture")
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
    }
    var myInt: Integer;
}
