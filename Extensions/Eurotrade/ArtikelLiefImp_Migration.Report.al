report 50064 "ArtikelLiefImp_Migration"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        DialogCaption:='Bitte Artikel Lieferanten .CSV Datei auswählen:';
        UploadResult:=UploadIntoStream(DialogCaption, '', '', CSVFilename, CSVInStream);
        CSVBuffer.DeleteAll();
        CSVBuffer.LoadDataFromStream(CSVInStream, ';');
        IF CSVBuffer.Findset then repeat CSVBuffer.Value:=delchr(CSVBuffer.Value, '>', ' '); //leerzeichen am ende der Felder entfernen
                //Zeile 1 = TitelZeile
                if CSVBuffer."Line No." > 2 THEN begin
                    case csvbuffer."field no." of 1: begin
                        _ItemNO:=CSVBuffer.Value;
                        ItemExits:=TRUE;
                        if not Item.get(CSVBuffer.Value)THEN begin
                            //Customer.init;
                            //Customer."No." := CSVBuffer.value;
                            //Customer.insert(true);
                            //CurrReport.Skip;
                            clear(Item);
                            ItemExits:=False;
                        end;
                    end;
                    3: begin
                        IF ItemExits THEN BEGIN
                            item."Vendor Item No.":=CSVBuffer.Value;
                            Item.modify(true);
                        end;
                    end;
                    4: begin
                        IF ItemExits THEN BEGIN
                            item."Vendor No.":=CSVBuffer.Value;
                            item.modify(true);
                        end;
                    end;
                    5: begin
                        _EP:=0;
                        IF ItemExits THEN BEGIN
                            Evaluate(_EP, CSVBuffer.Value);
                        end;
                    end;
                    6: begin
                        _Currency:='';
                        IF ItemExits THEN BEGIN
                            _Currency:=CSVBuffer.Value;
                        end;
                    end;
                    8: begin
                        QtyperUnit:=0;
                        IF ItemExits THEN BEGIN
                            Evaluate(QtyperUnit, CSVBuffer.Value);
                        end;
                    end;
                    9: begin
                        IF ItemExits THEN BEGIN
                            IF not ItemUnitofMeasure.get(_ItemNO, CSVBuffer.Value)THEN BEGIN
                                ItemUnitofMeasure.init;
                                ItemUnitofMeasure."Item No.":=_ItemNO;
                                ItemUnitofMeasure.Code:=CSVBuffer.Value;
                                ItemUnitofMeasure."Qty. per Unit of Measure":=QtyperUnit;
                                ItemUnitofMeasure.insert;
                            END;
                            item.Validate("Purch. Unit of Measure", CSVBuffer.value);
                            item.Validate("Last Direct Cost", _EP);
                            item.Validate("Unit Cost", _ep);
                            item.Modify(true);
                            //EK Preis schreiben
                            PurchasePrice.Reset();
                            purchaseprice.SetRange("Item No.", _ItemNO);
                            purchaseprice.Deleteall;
                            IF _EP <> 0 THEN begin
                                IF _Currency = 'CHF' then _Currency:='';
                                PurchasePrice.init;
                                PurchasePrice."Vendor No.":=Item."Vendor No.";
                                PurchasePrice."Item No.":=item."No.";
                                PurchasePrice."Unit of Measure Code":=item."Purch. Unit of Measure";
                                PurchasePrice."Direct Unit Cost":=_ep;
                                PurchasePrice."Currency Code":=_Currency;
                                PurchasePrice."Starting Date":=20210101D;
                                PurchasePrice.Insert();
                            end;
                        end;
                    end;
                    13: begin
                        IF ItemExits THEN BEGIN
                            IF not Statistikgruppe.get(copystr(CSVBuffer.Value, 1, 20))THEN begin
                                Statistikgruppe.init;
                                Statistikgruppe.code:=copystr(CSVBuffer.Value, 1, 20);
                                Statistikgruppe.Description:=CSVBuffer.Value;
                                Statistikgruppe.insert;
                            end;
                            item.validate("Statistik-Group", copystr(CSVBuffer.Value, 1, 20));
                            item.Modify(True);
                        end;
                    end;
                    14: begin
                        IF ItemExits THEN BEGIN
                            IF not HerstellerMarke.get(copystr(CSVBuffer.Value, 1, 20))THEN begin
                                HerstellerMarke.init;
                                HerstellerMarke.Code:=copystr(CSVBuffer.Value, 1, 20);
                                HerstellerMarke.Description:=CSVBuffer.Value;
                                HerstellerMarke.insert;
                            end;
                            item.Validate("Hersteller-Marke", copystr(CSVBuffer.Value, 1, 20));
                            item.Modify(true);
                        end;
                    end;
                    15: begin
                        IF ItemExits THEN BEGIN
                            IF CSVBuffer.Value <> '' THEN BEGIN
                                IF not Country.get(CSVBuffer.Value)THEN begin
                                    country.init;
                                    country.code:=CSVBuffer.Value;
                                    country.insert;
                                end;
                                item.Validate("Country/Region of Origin Code", CSVBuffer.Value);
                                item.Modify(true);
                            END;
                        end;
                    end;
                    16: begin
                        IF ItemExits THEN BEGIN
                            IF CSVBuffer.Value <> '' THEN BEGIN
                                IF not Tariff.get(CSVBuffer.Value)THEN begin
                                    Tariff.init;
                                    tariff."No.":=CSVBuffer.value;
                                    tariff.Description:=CSVBuffer.value;
                                    Tariff.insert;
                                end;
                                item.Validate("Tariff No.", CSVBuffer.Value);
                                item.Modify(true);
                            END;
                        end;
                    end;
                    17: begin
                        IF ItemExits THEN BEGIN
                            if CSVBuffer.Value <> '' THEN begin
                                item.GTIN:=CSVBuffer.Value;
                                item.Modify(True);
                            end;
                        end;
                    end;
                    end; //Case End
                end;
            until csvbuffer.next = 0;
    end;
    trigger OnPostReport()begin
        Message('Daten wurden verarbeitet')end;
    var CSVBuffer: Record "CSV Buffer";
    CSVInStream: InStream;
    UploadResult: Boolean;
    DialogCaption: text;
    CSVFilename: Text;
    _ItemNO: Code[20];
    Item: Record Item;
    ItemExits: Boolean;
    _EP: Decimal;
    _Currency: Code[20];
    Statistikgruppe: Record "Statistik-Gruppen";
    HerstellerMarke: Record "Hersteller-Marke";
    Tariff: Record "Tariff Number";
    QtyperUnit: Decimal;
    ItemUnitofMeasure: Record "Item Unit of Measure";
    country: Record "Country/Region";
    PurchasePrice: Record "Purchase Price";
}
