page 50002 "Porto"
{
    PageType = ListPlus;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Porto";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Country;rec.Country)
                {
                    ApplicationArea = All;
                }
                field(Currency;rec.Currency)
                {
                    ApplicationArea = All;
                }
                field("Bis Gewicht";rec."Bis Gewicht")
                {
                    ApplicationArea = All;
                }
                field("Fracht Betrag";rec."Fracht Betrag")
                {
                    ApplicationArea = All;
                }
                field("Fracht Fibukonto";rec."Fracht Fibukonto")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var myInt: Integer;
}
