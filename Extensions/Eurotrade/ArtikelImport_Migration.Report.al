report 50060 "ArtikelImport_Migration"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        LOGWSCategory.Deleteall;
        LOGWSManufacturerRelation.DeleteAll();
        DialogCaption:='Bitte Artikel .CSV Datei auswählen:';
        UploadResult:=UploadIntoStream(DialogCaption, '', '', CSVFilename, CSVInStream);
        CSVBuffer.DeleteAll();
        CSVBuffer.LoadDataFromStream(CSVInStream, ';');
        IF CSVBuffer.Findset then repeat //Zeile 1 + 2 sind Titelzeilen
                if CSVBuffer."Line No." > 2 THEN begin
                    case csvbuffer."field no." of 1: begin
                        _ItemNo:=CSVBuffer.Value;
                        if not item.get(CSVBuffer.Value)THEN begin
                            item.init;
                            item."No.":=CSVBuffer.value;
                            item.insert(true);
                        end;
                        If not UnitofMeasure.get('Stück')THEN begin
                            UnitofMeasure.init;
                            UnitofMeasure.code:='Stück';
                            UnitofMeasure.Description:='Stück';
                            UnitofMeasure.insert;
                        end;
                        Item.Validate("Base Unit of Measure", 'Stück');
                        Item.modify(true);
                    end;
                    2: begin
                        item."No. 2":=CSVBuffer.value;
                        item.Modify(true);
                    end;
                    3: begin
                        IF CSVBuffer.Value <> '1' then item.Blocked:=true;
                        item.modify(true);
                    end;
                    4: begin
                        if csvBuffer.value = '1' then item.B2C:=TRUE;
                        item.modify(true);
                    end;
                    5: begin
                        item.validate(Description, csvBuffer.value);
                        item.Modify(true);
                    end;
                    6: begin
                        ItemTranslation.reset;
                        ItemTranslation.setrange("Item No.", _ItemNo);
                        ItemTranslation.SETRANGE("Language Code", 'FRS');
                        ItemTranslation.DeleteAll();
                        IF CSVBuffer.Value <> '' THEN begin
                            ItemTranslation.init;
                            ItemTranslation."Item No.":=_itemNo;
                            ItemTranslation."Language Code":='FRS';
                            ItemTranslation.Description:=CSVBuffer.Value;
                            ItemTranslation.Insert();
                        end;
                    end;
                    7: begin
                        ItemTranslation.reset;
                        ItemTranslation.setrange("Item No.", _ItemNo);
                        ItemTranslation.SETRANGE("Language Code", 'ENU');
                        ItemTranslation.DeleteAll();
                        IF CSVBuffer.Value <> '' THEN begin
                            ItemTranslation.init;
                            ItemTranslation."Item No.":=_itemNo;
                            ItemTranslation."Language Code":='ENU';
                            ItemTranslation.Description:=CSVBuffer.Value;
                            ItemTranslation.Insert();
                        end;
                    end;
                    8: begin
                        IF LastMainGroup <> CSVBuffer.Value Then MainGroupCounter:=MainGroupCounter + 1;
                        LastMainGroup:=CSVBuffer.value;
                        LastOptionValue:='';
                        lastParentCategrory:='';
                        FillItemCategory(CSVBuffer.Value, CSVBuffer.Value, '');
                        IF CSVBuffer.Value <> '' THEN lastParentCategrory:=Copystr(CSVBuffer.Value, 1, 20);
                        IF lastParentCategrory <> '' THEN BEGIN
                            item."Item Category Code":=lastParentCategrory;
                            item.Modify(true);
                        END;
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    9: begin
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'FRS');
                    end;
                    10: begin
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'ENU');
                    end;
                    11: begin
                        LastOptionValue:='';
                        FillItemCategory(CSVBuffer.Value, CSVBuffer.Value, lastParentCategrory);
                        IF CSVBuffer.Value <> '' THEN lastParentCategrory:=Copystr(CSVBuffer.Value, 1, 20);
                        IF lastParentCategrory <> '' THEN BEGIN
                            item."Item Category Code":=lastParentCategrory;
                            item.Modify(true);
                        END;
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    12: begin
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'FRS');
                    end;
                    13: begin
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'ENU');
                    end;
                    14: begin
                        LastOptionValue:='';
                        FillItemCategory(CSVBuffer.Value, CSVBuffer.Value, lastParentCategrory);
                        IF CSVBuffer.Value <> '' THEN lastParentCategrory:=Copystr(CSVBuffer.Value, 1, 20);
                        IF lastParentCategrory <> '' THEN BEGIN
                            item."Item Category Code":=lastParentCategrory;
                            item.Modify(true);
                        END;
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    15: begin
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'FRS');
                    end;
                    16: begin
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'ENU');
                    end;
                    17: begin
                        LastOptionValue:='';
                        FillItemAttribute('Modell', CSVBuffer.Value);
                        FillItemCategory(CSVBuffer.Value, CSVBuffer.Value, lastParentCategrory);
                        IF CSVBuffer.Value <> '' THEN lastParentCategrory:=Copystr(CSVBuffer.Value, 1, 20);
                        IF lastParentCategrory <> '' THEN BEGIN
                            item."Item Category Code":=lastParentCategrory;
                            item.Modify(true);
                        END;
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    18: begin
                        FillItemAttributeTranslation('Modell', LastOptionValue, 'FRS', CSVBuffer.Value);
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'FRS');
                    end;
                    19: begin
                        FillItemAttributeTranslation('Modell', LastOptionValue, 'ENU', CSVBuffer.Value);
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'ENU');
                    end;
                    20: begin
                        LastOptionValue:='';
                        FillItemAttribute('Familie', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                        FillItemCategory(CSVBuffer.Value, CSVBuffer.Value, lastParentCategrory);
                        IF CSVBuffer.Value <> '' THEN lastParentCategrory:=Copystr(CSVBuffer.Value, 1, 20);
                        IF lastParentCategrory <> '' THEN BEGIN
                            item."Item Category Code":=lastParentCategrory;
                            item.Modify(true);
                        END;
                    end;
                    21: begin
                        FillItemAttributeTranslation('Familie', LastOptionValue, 'FRS', CSVBuffer.Value);
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'FRS');
                    end;
                    22: begin
                        FillItemAttributeTranslation('Familie', LastOptionValue, 'ENU', CSVBuffer.Value);
                        FillItemCategoryTranslation(LastOptionValue, CSVBuffer.Value, '', 'ENU');
                    end;
                    23: begin
                        LastOptionValue:='';
                        FillItemAttribute('Artikel Filter', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    24: begin
                        FillItemAttributeTranslation('Artikel Filter', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    25: begin
                        FillItemAttributeTranslation('Artikel Filter', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    26: begin
                        //Hersteller
                        if not Manufacturer.get(Copystr(CSVBuffer.value, 1, 10))THEN begin
                            Manufacturer.init;
                            Manufacturer.Code:=Copystr(CSVBuffer.Value, 1, 10);
                            Manufacturer.Name:=CSVBuffer.value;
                            Manufacturer.insert(true);
                        end;
                        //Hersteller VErknüpfung
                        LOGWSManufacturerRelation.Reset;
                        LOGWSManufacturerRelation.SETRANGE("Table No.", 27);
                        LOGWSManufacturerRelation.SETRANGE("Line No.", 10000);
                        LOGWSManufacturerRelation.SETRANGE("Manufacturer Code", Copystr(CSVBuffer.Value, 1, 10));
                        LOGWSManufacturerRelation.setrange("LOGWS Unique Record Identifier", item."LOGWS Unique Record Identifier");
                        IF LOGWSManufacturerRelation.Findfirst then LOGWSManufacturerRelation.delete;
                        LOGWSManufacturerRelation.init;
                        LOGWSManufacturerRelation."Table No.":=27;
                        LOGWSManufacturerRelation."Line No.":=10000;
                        LOGWSManufacturerRelation."Uri Data Source":=_ItemNo;
                        LOGWSManufacturerRelation."LOGWS Unique Record Identifier":=item."LOGWS Unique Record Identifier";
                        LOGWSManufacturerRelation."Manufacturer Code":=Copystr(CSVBuffer.Value, 1, 10);
                        LOGWSManufacturerRelation.insert(true);
                    end;
                    27: begin
                        LastOptionValue:='';
                        FillItemAttribute('Modell Filter', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    28: begin
                        FillItemAttributeTranslation('Modell Filter', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    29: begin
                        FillItemAttributeTranslation('Modell Filter', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    30: begin
                        LastOptionValue:='';
                        FillItemAttribute('Material', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    31: begin
                        FillItemAttributeTranslation('Material', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    32: begin
                        FillItemAttributeTranslation('Material', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    33: begin
                        LastOptionValue:='';
                        FillItemAttribute('Schweissteile Filter', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    34: begin
                        FillItemAttributeTranslation('Schweissteile Filter', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    35: begin
                        FillItemAttributeTranslation('Schweissteile Filter', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    36: begin
                        LastOptionValue:='';
                        FillItemAttribute('Grösse', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    37: begin
                        LastOptionValue:='';
                        FillItemAttribute('Kappen', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    38: begin
                        FillItemAttributeTranslation('Kappen', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    39: begin
                        FillItemAttributeTranslation('Kappen', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    40: begin
                        LastOptionValue:='';
                        FillItemAttribute('Form', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    41: begin
                        FillItemAttributeTranslation('Form', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    42: begin
                        FillItemAttributeTranslation('Form', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    43: begin
                        LastOptionValue:='';
                        FillItemAttribute('Dimension', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    44: begin
                        LastOptionValue:='';
                        FillItemAttribute('Eisen-Breite', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    45: begin
                        LastOptionValue:='';
                        FillItemAttribute('Stab-Dicke', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    46: begin
                        LastOptionValue:='';
                        FillItemAttribute('Stab-Breite', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    47: begin
                        LastOptionValue:='';
                        FillItemAttribute('Nagel-Kopf Form', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    48: begin
                        FillItemAttributeTranslation('Nagel-Kopf Form', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    49: begin
                        FillItemAttributeTranslation('Nagel-Kopf Form', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    50: begin
                        LastOptionValue:='';
                        FillItemAttribute('Nagel-Hals Form', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    51: begin
                        FillItemAttributeTranslation('Nagel-Hals Form', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    52: begin
                        FillItemAttributeTranslation('Nagel-Hals Form', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    53: begin
                        LastOptionValue:='';
                        FillItemAttribute('Nagelgrösse', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    54: begin
                        LastOptionValue:='';
                        FillItemAttribute('Nagellänge', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    55: begin
                        LastOptionValue:='';
                        FillItemAttribute('Hufschuh Grösse', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    56: begin
                        LastOptionValue:='';
                        FillItemAttribute('Hufschuh Breite', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    57: begin
                        LastOptionValue:='';
                        FillItemAttribute('Hufschuh Länge', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    58: begin
                        LastOptionValue:='';
                        FillItemAttribute('Hufschuh Form', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    59: begin
                        FillItemAttributeTranslation('Hufschuh Form', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    60: begin
                        FillItemAttributeTranslation('Hufschuh Form', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    61: begin
                        LastOptionValue:='';
                        FillItemAttribute('Bohrer-Kernloch', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    62: begin
                        FillItemAttributeTranslation('Bohrer-Kernloch', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    63: begin
                        FillItemAttributeTranslation('Bohrer-Kernloch', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    64: begin
                        LastOptionValue:='';
                        FillItemAttribute('Gewinde', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    65: begin
                        LastOptionValue:='';
                        FillItemAttribute('Stollen Kopfhöhe', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    66: begin
                        LastOptionValue:='';
                        FillItemAttribute('Stollen Kopfbreite', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    67: begin
                        LastOptionValue:='';
                        FillItemAttribute('Stollen Zapfenlänge', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    68: begin
                        LastOptionValue:='';
                        FillItemAttribute('Stollen selbstschn', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    69: begin
                        LastOptionValue:='';
                        FillItemAttribute('Gewinderille', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    70: begin
                        FillItemAttributeTranslation('Gewinderille', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    71: begin
                        FillItemAttributeTranslation('Gewinderille', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    72: begin
                        LastOptionValue:='';
                        FillItemAttribute('Hammerkopf', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    73: begin
                        FillItemAttributeTranslation('Hammerkopf', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    74: begin
                        FillItemAttributeTranslation('Hammerkopf', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    75: begin
                        LastOptionValue:='';
                        FillItemAttribute('Hammer gewicht', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    76: begin
                        LastOptionValue:='';
                        FillItemAttribute('Hufmesser Form', CSVBuffer.Value);
                        LastOptionValue:=CSVBuffer.Value;
                    end;
                    77: begin
                        FillItemAttributeTranslation('Hufmesser Form', LastOptionValue, 'FRS', CSVBuffer.Value)end;
                    78: begin
                        FillItemAttributeTranslation('Hufmesser Form', LastOptionValue, 'ENU', CSVBuffer.Value)end;
                    79: begin
                        IF Evaluate(ValueDec, CSVBuffer.Value)THEN FillSalesPrice(_ItemNo, 'Stück', ValueDec);
                    end;
                    80: begin
                        IF CSVBuffer.Value <> '' THEN Evaluate(AnzahlProEinheit, CSVBuffer.Value)
                        else
                            AnzahlProEinheit:=0;
                    end;
                    81: begin
                        Einheit:=CSVBuffer.Value;
                        Einheit_A:=CSVBuffer.Value;
                    end;
                    82: begin
                        if CSVBuffer.Value <> '' then BEGIN
                            Evaluate(ValueDec, CSVBuffer.Value);
                            //Einheit anlegen
                            If not UnitofMeasure.get(Einheit)THEN begin
                                UnitofMeasure.init;
                                UnitofMeasure.code:=Einheit;
                                UnitofMeasure.Description:=Einheit;
                                UnitofMeasure.insert;
                            end;
                            //Verkaufseinheit anlegen
                            ItemUnitofMeasure.Reset;
                            ItemUnitofMeasure.Setrange("Item No.", _ItemNo);
                            ItemUnitofMeasure.Setrange(code, Einheit);
                            IF ItemUnitofMeasure.Findfirst then ItemUnitofMeasure.delete;
                            ItemUnitofMeasure.init;
                            ItemUnitofMeasure."Item No.":=_ItemNo;
                            ItemUnitofMeasure.code:=Einheit;
                            ItemUnitofMeasure."Qty. per Unit of Measure":=AnzahlProEinheit;
                            ItemUnitofMeasure.Insert;
                            //Preis anlegen
                            FillSalesPrice(_ItemNo, Einheit, ValueDec);
                            item.validate("Sales Unit of Measure", Einheit);
                            item.modify(True);
                        END;
                    end;
                    83: begin
                        IF CSVBuffer.value <> '' THEN Evaluate(AnzahlProEinheit, CSVBuffer.Value)
                        else
                            AnzahlProEinheit:=0;
                    end;
                    84: begin
                        Einheit:=CSVBuffer.Value;
                        Einheit_B:=CSVBuffer.Value;
                    end;
                    85: begin
                        if CSVBuffer.Value <> '' then BEGIN
                            Evaluate(ValueDec, CSVBuffer.Value);
                            //Einheit anlegen
                            If not UnitofMeasure.get(Einheit)THEN begin
                                UnitofMeasure.init;
                                UnitofMeasure.code:=Einheit;
                                UnitofMeasure.Description:=Einheit;
                                UnitofMeasure.insert;
                            end;
                            //Verkaufseinheit anlegen
                            ItemUnitofMeasure.Reset;
                            ItemUnitofMeasure.Setrange("Item No.", _ItemNo);
                            ItemUnitofMeasure.Setrange(code, Einheit);
                            IF ItemUnitofMeasure.Findfirst then ItemUnitofMeasure.delete;
                            ItemUnitofMeasure.init;
                            ItemUnitofMeasure."Item No.":=_ItemNo;
                            ItemUnitofMeasure.code:=Einheit;
                            ItemUnitofMeasure."Qty. per Unit of Measure":=AnzahlProEinheit;
                            ItemUnitofMeasure.Insert;
                            //Preis anlegen
                            FillSalesPrice(_ItemNo, Einheit, ValueDec);
                        END;
                    end;
                    86: begin
                        IF not itemDiscountGroup.get(CSVBuffer.value)THEN BEGIN
                            itemDiscountGroup.init;
                            itemDiscountGroup.code:=CSVBuffer.value;
                            itemDiscountGroup.Description:=CSVBuffer.value;
                            itemDiscountGroup.insert;
                        END;
                        item.Validate("Item Disc. Group", CSVBuffer.value);
                    end;
                    87: begin
                        item.validate("Gen. Prod. Posting Group", 'HANDEL');
                        IF CSVBuffer.value = '0.077' then item.Validate("VAT Prod. Posting Group", 'NORMAL');
                        IF CSVBuffer.value = '0.025' then item.Validate("VAT Prod. Posting Group", 'RED.');
                        item.validate("Inventory Posting Group", 'WV');
                        item.Modify(True);
                    end;
                    88: begin
                        if CSVBuffer.Value <> '' then BEGIN
                            Evaluate(item."Net Weight", CSVBuffer.Value);
                            item.Modify(TRUE);
                        END;
                    end;
                    89: begin
                        if CSVBuffer.Value <> '' then BEGIN
                            ItemUnitofMeasure.Reset;
                            ItemUnitofMeasure.Setrange(Code, Einheit_A);
                            ItemUnitofMeasure.Setrange("Item No.", _ItemNo);
                            IF ItemUnitofMeasure.findfirst THEN begin
                                EVALUATE(ItemUnitofMeasure.Weight, CSVBuffer.Value);
                                ItemUnitofMeasure.Modify;
                            end;
                        end;
                    end;
                    90: begin
                        if CSVBuffer.Value <> '' then BEGIN
                            ItemUnitofMeasure.Reset;
                            ItemUnitofMeasure.Setrange(Code, Einheit_B);
                            ItemUnitofMeasure.Setrange("Item No.", _ItemNo);
                            IF ItemUnitofMeasure.findfirst THEN begin
                                EVALUATE(ItemUnitofMeasure.Weight, CSVBuffer.Value);
                                ItemUnitofMeasure.Modify;
                            end;
                        END;
                    end;
                    end;
                end; //END Case
            until CSVBuffer.next = 0;
    end;
    trigger OnPostReport()begin
        Message('Daten wurden verarbeitet')end;
    local procedure FillItemCategory(_code: code[50];
    _Beschreibung: text[50];
    _ParentGroup: code[50])begin
        IF Evaluate(TempInteger, copystr(_Beschreibung, 1, 3))then _Beschreibung:=Copystr(_Beschreibung, 4);
        IF Evaluate(TempInteger, copystr(_Beschreibung, 1, 2))then _Beschreibung:=Copystr(_Beschreibung, 3);
        if not itemCategory.Get(copystr(_code, 1, 20))THEN begin
            itemCategory.init;
            itemCategory.code:=Copystr(_code, 1, 20);
            itemCategory.Description:=_Beschreibung;
            itemCategory."Parent Category":=copystr(_ParentGroup, 1, 20);
            itemCategory.insert;
        end;
        //xxx - START
        //_code := FORMAT(MainGroupCounter) + _code;
        //_ParentGroup := FORMAT(MainGroupCounter) + _ParentGroup;
        //xxx - END
        //WebShop Kategorie
        //if not LOGWSCategory.get(copystr(_code, 1, 5) + copystr(_ParentGroup, 1, 5)) THEN BEGIN
        if not LOGWSCategory.get(copystr(_code, 1, 10))THEN BEGIN
            LOGWSCategory.init;
            LOGWSCategory."Code Value":=Copystr(_code, 1, 10);
            //LOGWSCategory."Code Value" := Copystr(_code, 1, 5) + copystr(_ParentGroup, 1, 5);
            LOGWSCategory.Description:=_Beschreibung;
            LOGWSCategory."Parent Category":=copystr(_ParentGroup, 1, 10);
            LOGWSCategory."Item Category Code":=Copystr(_code, 1, 20);
            LOGWSCategory.insert;
        end;
    end;
    local procedure FillItemCategoryTranslation(_code: code[50];
    _Beschreibung: text[50];
    _ParentGroup: code[50];
    _Languagecode: code[10])begin
        LOGWSTranslation.Reset;
        LOGWSTranslation.SETRANGE(Type, LOGWSTranslation.type::"WS Category");
        LOGWSTranslation.SETRANGE("Code Value", copystr(_code, 1, 10));
        LOGWSTranslation.SETRANGE("Language Code", _Languagecode);
        IF LOGWSTranslation.Findfirst THen LOGWSTranslation.Delete;
        IF _Beschreibung <> '' THEN BEGIN
            LOGWSTranslation.init;
            LOGWSTranslation.Type:=LOGWSTranslation.type::"WS Category";
            LOGWSTranslation."Code Value":=copystr(_code, 1, 10);
            LOGWSTranslation."Language Code":=_Languagecode;
            LOGWSTranslation.Description:=_Beschreibung;
            LOGWSTranslation.insert;
        END;
    end;
    local procedure FillItemAttribute(_AttributeName: text;
    _AttributeValue: text)begin
        if _AttributeValue = '' then exit;
        //Attribute
        ItemAttribute.Reset;
        ItemAttribute.setrange(name, _AttributeName);
        IF not ItemAttribute.findfirst THEN begin
            ItemAttribute.init;
            IF ItemAttribute2.findlast then ItemAttribute.ID:=ItemAttribute2.id + 1
            else
                ItemAttribute.ID:=1;
            ItemAttribute.name:=_AttributeName;
            ItemAttribute.Type:=ItemAttribute.Type::Option;
            ItemAttribute.Insert();
        end;
        //Attribute Value
        ItemAttributeValue.Reset;
        ItemAttributeValue.SETRANGE("Attribute ID", ItemAttribute.id);
        ItemAttributeValue.SETRANGE(Value, _AttributeValue);
        if not ItemAttributeValue.FINDFIRST THEN BEGIN
            ItemAttributeValue.init;
            ItemAttributeValue."Attribute ID":=ItemAttribute.id;
            ItemAttributevalue2.SetRange("Attribute ID", ItemAttribute.id);
            If ItemAttributeValue2.findlast THEN ItemAttributeValue.ID:=ItemAttributeValue2.id + 1
            else
                ItemAttributeValue.ID:=1;
            ItemAttributeValue."Value":=_AttributeValue;
            ItemAttributeValue.insert;
        END;
        //ItemAttributeValueMapping
        ItemAttributeValueMapping.RESET;
        ItemAttributeValueMapping.SETRANGE("Table ID", 27);
        ItemAttributeValueMapping.SETRANGE("No.", _ItemNo);
        ItemAttributeValueMapping.SETRANGE("Item Attribute ID", ItemAttribute.id);
        //ItemAttributeValueMapping.SETRANGE("Item Attribute Value ID", ItemAttributeValue.ID);
        if ItemAttributeValueMapping.findfirst then ItemAttributeValueMapping.delete;
        ItemAttributeValueMapping.init;
        ItemAttributeValueMapping."Table ID":=27;
        ItemAttributeValueMapping."No.":=_ItemNo;
        ItemAttributeValueMapping."Item Attribute ID":=ItemAttribute.id;
        ItemAttributeValueMapping."Item Attribute Value ID":=ItemAttributeValue.ID;
        ItemAttributeValueMapping.Insert;
    end;
    local procedure FillItemAttributeTranslation(_AttributeName: text;
    _AttributeValue: text;
    _LanguageCode: code[20];
    _Translation: text)begin
        if _AttributeValue = '' then exit;
        ItemAttribute2.Reset;
        ItemAttribute2.SetRange(name, _AttributeName);
        ItemAttribute2.Findfirst;
        ItemAttributeValue2.reset;
        ItemAttributeValue2.setrange("Attribute ID", ItemAttribute2.id);
        ItemAttributeValue2.setrange(Value, _AttributeValue);
        ItemAttributeValue2.findfirst;
        ItemAttrValueTranslation.SETRANGE("Attribute ID", ItemAttribute2.id);
        ItemAttrValueTranslation.SETRANGE(ID, ItemAttributeValue2.id);
        ItemAttrValueTranslation.setrange("Language Code", _LanguageCode);
        IF ItemAttrValueTranslation.Findfirst THEN ItemAttrValueTranslation.Delete;
        ItemAttrValueTranslation.Reset;
        ItemAttrValueTranslation.init;
        ItemAttrValueTranslation."Attribute ID":=ItemAttribute2.id;
        ItemAttrValueTranslation.ID:=ItemAttributeValue2.id;
        ItemAttrValueTranslation."Language Code":=_LanguageCode;
        ItemAttrValueTranslation.Name:=_Translation;
        ItemAttrValueTranslation.insert;
        ItemAttribute2.Reset;
        ItemAttributeValue2.reset;
    end;
    local procedure FillSalesPrice(_ItemNo: code[20];
    _Unit: Code[20];
    _Price: Decimal)begin
        if _Price = 0 then exit;
        salesPrice.Setrange("Sales Type", salesPrice."Sales Type"::"All Customers");
        salesPrice.Setrange("Item No.", _ItemNo);
        salesPrice.Setrange("Unit of Measure Code", _Unit);
        IF salesPrice.Findfirst then salesPrice.delete;
        salesPrice.init;
        salesPrice."Sales Type":=salesPrice."Sales Type"::"All Customers";
        salesPrice."Item No.":=_ItemNo;
        salesPrice."Unit of Measure Code":=_Unit;
        salesPrice."Unit Price":=_Price;
        salesPrice."Starting Date":=20210101D;
        salesPrice.insert;
    end;
    var CSVBuffer: Record "CSV Buffer";
    CSVInStream: InStream;
    UploadResult: Boolean;
    DialogCaption: text;
    CSVFilename: Text;
    item: Record item;
    ItemTranslation: Record "Item Translation";
    _ItemNo: code[20];
    itemCategory: Record "Item Category";
    lastParentCategrory: code[50];
    ItemAttribute: Record "Item Attribute";
    ItemAttribute2: Record "Item Attribute";
    ItemAttributeValue: Record "Item Attribute Value";
    ItemAttributeValue2: Record "Item Attribute Value";
    ItemAttrValueTranslation: Record "Item Attr. Value Translation";
    LastOptionValue: Text;
    ItemAttributeValueMapping: record "Item Attribute Value Mapping";
    UnitofMeasure: Record "Unit of Measure";
    ItemUnitofMeasure: Record "Item Unit of Measure";
    salesPrice: Record "Sales Price";
    ValueDec: Decimal;
    AnzahlProEinheit: Decimal;
    Einheit: code[10];
    itemDiscountGroup: Record "Item Discount Group";
    Einheit_A: Code[20];
    Einheit_B: Code[20];
    Manufacturer: Record Manufacturer;
    LOGWSManufacturerRelation: Record "LOGWS Manufacturer Relation";
    LOGWSCategory: Record "LOGWS Category";
    LOGWSTranslation: Record "LOGWS Translation";
    MainGroupCounter: Integer;
    LastMainGroup: Code[50];
    TempInteger: Integer;
}
