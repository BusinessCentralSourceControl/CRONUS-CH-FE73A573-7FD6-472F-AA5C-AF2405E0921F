page 50001 "Hersteller-Marke"
{
    PageType = ListPlus;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Statistik-Gruppen";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code;rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description;rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()begin
                end;
            }
        }
    }
    var myInt: Integer;
}
