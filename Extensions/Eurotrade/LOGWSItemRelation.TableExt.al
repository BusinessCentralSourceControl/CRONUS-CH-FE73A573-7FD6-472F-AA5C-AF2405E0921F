tableextension 50010 LOGWSItemRelation extends "LOGWS Item Relation"
{
    fields
    {
        // Add changes to table fields here
        field(50000;"alternative";Text[50])
        {
            Caption = 'Alternative';
        }
    }
    var test: Record "My Customer";
}
