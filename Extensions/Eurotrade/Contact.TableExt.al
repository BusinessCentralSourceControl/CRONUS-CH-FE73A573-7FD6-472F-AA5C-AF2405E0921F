tableextension 50002 Contact extends Contact
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
        }
        field(50006;"Newsletter";Boolean)
        {
            Caption = 'Newsletter';
        }
    }
    var myInt: Integer;
}
