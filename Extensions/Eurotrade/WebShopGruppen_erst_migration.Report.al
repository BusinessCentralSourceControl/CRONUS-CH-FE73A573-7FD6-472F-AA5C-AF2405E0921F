report 50067 WebShopGruppen_erst_migration
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        LOGWSItemWSGrpRel.DeleteAll();
        Webshopgruppe.Deleteall();
        LOGWSCategoryRelation.DeleteAll();
        IF item.findset then repeat if item."Item Category Code" <> '' THEN begin
                    IF not Webshopgruppe.get(item."Item Category Code")THEN begin
                        ItemCategory.get(item."Item Category Code");
                        Webshopgruppe.init;
                        Webshopgruppe."Code Value":=item."Item Category Code";
                        Webshopgruppe.Description:=ItemCategory.Description;
                        Webshopgruppe.insert;
                    end;
                    LOGWSItemWSGrpRel.init;
                    LOGWSItemWSGrpRel.Validate("Item No.", item."no.");
                    LOGWSItemWSGrpRel.Validate("WS Group Code", item."Item Category Code");
                    LOGWSItemWSGrpRel."Default WS Group":=TRue;
                    LOGWSItemWSGrpRel.Insert();
                    IF not LOGWSCategoryRelation.get(copystr(item."Item Category Code", 1, 10), LOGWSCategoryRelation."WS Category Type"::"WS Group", item."Item Category Code")THEN begin
                        LOGWSCategoryRelation.init;
                        LOGWSCategoryRelation."WS Category Code":=copystr(item."Item Category Code", 1, 10);
                        LOGWSCategoryRelation."WS Category Type":=LOGWSCategoryRelation."WS Category Type"::"WS Group";
                        LOGWSCategoryRelation."No. Filter":=item."Item Category Code";
                        LOGWSCategoryRelation.insert;
                    end;
                end;
            until item.next = 0;
    end;
    var myInt: Integer;
    Item: Record Item;
    Webshopgruppe: Record "LOGWS Group";
    ItemCategory: Record "Item Category";
    LOGWSItemWSGrpRel: Record "LOGWS Item WS Grp. Rel.";
    LOGWSCategoryRelation: record "LOGWS Category Relation";
}
