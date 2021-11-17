report 50069 WebShopMigration
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        IF item.FindSet then repeat //Verkaufseinheit für Stück und STk deaktivieren
                IF item."Sales Unit of Measure" <> 'STÜCK' THEN begin
                    ItemUnitOFMeasure.setrange("Item No.", item."No.");
                    ItemUnitOFMeasure.setrange(Code, 'STÜCK');
                    IF ItemUnitOFMeasure.findfirst THEN begin
                        ItemUnitOFMeasure."LOGWS Used in Webshop":=False;
                        ItemUnitOFMeasure.Modify;
                    end;
                    ItemUnitOFMeasure.setrange("Item No.", item."No.");
                    ItemUnitOFMeasure.setrange(Code, 'STK');
                    IF ItemUnitOFMeasure.findfirst THEN begin
                        ItemUnitOFMeasure."LOGWS Used in Webshop":=False;
                        ItemUnitOFMeasure.Modify;
                    end;
                end;
                //Attribute auf artikelkategorie schreiben
                Counter:=5000;
                IF ItemCategory.get(item."Item Category Code")THEN begin
                    ItemAttributeValueMapping.REset;
                    ItemAttributeValueMapping.Setrange("Table ID", 27);
                    ItemAttributeValueMapping.SETRANGE("No.", Item."No.");
                    IF ItemAttributeValueMapping.FINDSET THEN repeat ItemAttributeValue.RESET;
                            ItemAttributeValue.Setrange("Attribute ID", ItemAttributeValueMapping."Item Attribute ID");
                            ItemAttributeValue.SETRANGE("Attribute Name", '');
                            IF not ItemAttributeValue.findfirst THEN begin
                                //ItemAttributeValue3.reset;
                                //ItemAttributeValue3.findlast;
                                Counter:=Counter + 1;
                                ItemAttributeValue2.init;
                                ItemAttributeValue2."Attribute ID":=ItemAttributeValueMapping."Item Attribute ID";
                                ItemAttributeValue2.ID:=Counter;
                                IF ItemAttributeValue2.insert THEN;
                            end;
                            GroupAttributeValueMapping.init;
                            GroupAttributeValueMapping."Table ID":=5722;
                            GroupAttributeValueMapping."No.":=item."Item Category Code";
                            GroupAttributeValueMapping."Item Attribute ID":=ItemAttributeValueMapping."Item Attribute ID";
                            GroupAttributeValueMapping."Item Attribute Value ID":=ItemAttributeValue2.ID; //xxx 
                            IF GroupAttributeValueMapping.insert THEN;
                        until ItemAttributeValueMapping.next = 0;
                end;
            until item.next = 0;
    end;
    var myInt: Integer;
    Item: Record Item;
    Webshopgruppe: Record "LOGWS Group";
    ItemCategory: Record "Item Category";
    LOGWSItemWSGrpRel: Record "LOGWS Item WS Grp. Rel.";
    LOGWSCategoryRelation: record "LOGWS Category Relation";
    ItemUnitOFMeasure: Record "Item Unit of Measure";
    ItemAttributeValue: Record "Item Attribute Value";
    ItemAttributeValue2: Record "Item Attribute Value";
    ItemAttributeValue3: Record "Item Attribute Value";
    ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    GroupAttributeValueMapping: Record "Item Attribute Value Mapping";
    Counter: Integer;
}
