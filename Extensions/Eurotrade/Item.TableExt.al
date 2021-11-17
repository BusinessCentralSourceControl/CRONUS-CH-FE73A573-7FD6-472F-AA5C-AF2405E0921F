tableextension 50000 Item extends Item
{
    fields
    {
        // Add changes to table fields here
        field(50000;B2C;Boolean)
        {
            Caption = 'B2C';
        }
        field(50001;"Statistik-Group";code[20])
        {
            Caption = 'Statistik-Gruppe';
            TableRelation = "Statistik-Gruppen".Code;
        }
        field(50002;"Hersteller-Marke";code[20])
        {
            Caption = 'Hersteller-Marke';
            TableRelation = "Hersteller-Marke".Code;
        }
        field(50003;"Parent Picture";code[20])
        {
            Caption = 'Bild Parent';
            TableRelation = "Item"."no.";
        }
    }
    var myInt: Integer;
}
