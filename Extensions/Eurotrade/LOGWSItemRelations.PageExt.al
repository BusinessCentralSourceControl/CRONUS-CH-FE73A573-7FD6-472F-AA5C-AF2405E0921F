pageextension 50010 LOGWSItemRelations extends "LOGWS Item Relations"
{
    layout
    {
        // Add changes to page layout here
        addafter(Accessory)
        {
            field(alternative;rec.alternative)
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
    }
    var myInt: Integer;
}
