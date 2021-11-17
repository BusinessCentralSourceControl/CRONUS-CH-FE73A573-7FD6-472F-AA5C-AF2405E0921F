tableextension 50001 Vendor extends Vendor
{
    fields
    {
        // Add changes to table fields here
        field(50000;"Phone No. 2";Text[30])
        {
            Caption = 'Telefon 2';
        }
        field(50001;B2C;Boolean)
        {
            Caption = 'B2C';
        }
        field(50002;B2B;Boolean)
        {
            Caption = 'B2B';
        }
        field(50003;"Birthday";Date)
        {
            Caption = 'Geburtsdatum';
            Enabled = False;
        }
        field(50004;"Industry Group";Code[10])
        {
            Caption = 'Branche';
            TableRelation = "Industry Group".Code;
        }
        field(50005;"Position";Code[10])
        {
            Caption = 'Position';
            TableRelation = "Organizational Level".Code;
        }
        field(50006;"Newsletter";Boolean)
        {
            Caption = 'Newsletter';
        }
    }
    var myInt: Integer;
}
