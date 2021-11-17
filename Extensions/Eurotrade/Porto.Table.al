table 50002 "Porto"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1;Country;Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region".code;
        }
        field(2;Currency;Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency.code;
        }
        field(3;"Bis Gewicht";Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4;"Fracht Fibukonto";Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
        field(5;"Fracht Betrag";Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1;Country, Currency, "Bis Gewicht")
        {
            Clustered = true;
        }
    }
    var myInt: Integer;
    trigger OnInsert()begin
    end;
    trigger OnModify()begin
    end;
    trigger OnDelete()begin
    end;
    trigger OnRename()begin
    end;
}
