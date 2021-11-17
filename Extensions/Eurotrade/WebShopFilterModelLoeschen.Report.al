report 50070 WebShopFilterModelLoeschen
//löscht die Filter für Model
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = True;

    trigger OnPreReport()begin
        ItemAttributeValueMapping.Setrange("Table ID", 5722);
        ItemAttributeValueMapping.SETFILTER("Item Attribute ID", '1|4|2');
        ItemAttributeValueMapping.deleteall;
    end;
    var ItemAttributeValueMapping: record "Item Attribute Value Mapping";
}
