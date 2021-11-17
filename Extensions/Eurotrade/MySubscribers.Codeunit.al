codeunit 50000 MySubscribers
{
    EventSubscriberInstance = StaticAutomatic;
    Permissions = TableData "Issued Reminder Header"=rm;

    //EURO000 12.08.21 - START (E-Mail Adresse nicht prüfen)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mail Management", 'OnBeforeCheckValidEmailAddr', '', true, true)]
    local procedure OnBeforeCheckValidEmailAddr(var IsHandled: Boolean);
    begin
        IsHandled:=TRUE;
    end;
    //EURO000 12.08.21 - END (E-Mail Adresse nicht prüfen)
    //EURO000 12.08.21 - Start - (Neue Felder in Synch Debitor / Kreditor / Kontakt)
    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnBeforeIsContactUpdateNeeded', '', true, true)]
    local procedure OnBeforeIsContactUpdateNeeded(Customer: Record Customer;
    xCustomer: Record Customer;
    var UpdateNeeded: Boolean);
    begin
        IF UpdateNeeded = False THEN UpdateNeeded:=((customer."Phone No. 2" <> xCustomer."Phone No. 2") or (customer.Newsletter <> xCustomer."Newsletter"));
    end;
    [EventSubscriber(ObjectType::Table, Database::"Vendor", 'OnBeforeIsContactUpdateNeeded', '', true, true)]
    local procedure VendOnBeforeIsContactUpdateNeeded(Vendor: Record Vendor;
    xVendor: Record Vendor;
    var UpdateNeeded: Boolean);
    begin
        IF UpdateNeeded = False THEN UpdateNeeded:=((Vendor."Phone No. 2" <> xvendor."Phone No. 2") or (Vendor.Newsletter <> xvendor."Newsletter"));
    end;
    [EventSubscriber(ObjectType::Table, Database::"Contact", 'OnBeforeIsUpdateNeeded', '', true, true)]
    local procedure OnBeforeIsUpdateNeeded(var Contact: Record Contact;
    xContact: Record Contact;
    var UpdateNeeded: Boolean);
    begin
        IF UpdateNeeded = False THEN UpdateNeeded:=((Contact."Phone No. 2" <> xContact."Phone No. 2") or (Contact."newsletter" <> xContact."newsletter"));
    end;
    //EURO000 12.08.21 - End - (Neue Felder in Synch Debitor / Kreditor / Kontakt)
    //EURO000 18.08.21 - START (Porto in Auftrag)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', true, true)]
    local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header");
    var SalesLine: Record "sales line";
    ItemUnitofMeasure: Record "Item Unit of Measure";
    Porto: Record Porto;
    Item: Record item;
    GewichtKG: Decimal;
    PortoLabel: Label 'Postage packing';
    begin
        GewichtKG:=0;
        SalesLine.reset;
        SalesLine.Setrange("Document No.", SalesHeader."No.");
        SalesLine.Setrange("Document type", SalesHeader."Document Type");
        SalesLine.Setrange("type", SalesLine.Type::"G/L Account");
        SalesLine.Setrange("Line No.", 99999999);
        IF not SalesLine.FINDFIRSt THEN BEGIN
            SalesLine.reset;
            SalesLine.Setrange("Document No.", SalesHeader."No.");
            SalesLine.Setrange("Document type", SalesHeader."Document Type");
            SalesLine.Setrange("type", SalesLine.Type::Item);
            IF SalesLine.findset THEN repeat ItemUnitofMeasure.reset;
                    ItemUnitofMeasure.SetRange("Item No.", SalesLine."no.");
                    ItemUnitofMeasure.Setrange(code, SalesLine."Unit of Measure Code");
                    IF ItemUnitofMeasure.Findfirst then GewichtKG:=GewichtKG + (SalesLine.Quantity * ItemUnitofMeasure.Weight)
                    else
                    begin
                        item.get(SalesLine."no.");
                        GewichtKG:=GewichtKG + (SalesLine.Quantity * item."Net Weight")end;
                until SalesLine.next = 0;
            Porto.reset;
            porto.Setrange(Country, SalesHeader."Ship-to Country/Region Code");
            porto.Setrange(Currency, SalesHeader."Currency Code");
            porto.SetFilter("Fracht Betrag", '<>%1', 0);
            porto.SetFilter("Fracht Fibukonto", '<>%1', '');
            porto.setfilter("Bis Gewicht", '>=%1', GewichtKG);
            IF porto.Findfirst then begin
                SalesLine.init;
                SalesLine."Document No.":=SalesHeader."No.";
                SalesLine."Document type":=SalesHeader."Document Type";
                SalesLine."type":=SalesLine.Type::"G/L Account";
                SalesLine."Line No.":=99999999;
                SalesLine.insert;
                SalesLine.validate("no.", Porto."Fracht Fibukonto");
                SalesLine.Validate(Quantity, 1);
                SalesLine.Validate("Unit Price", Porto."Fracht Betrag");
                SalesLine.Description:=PortoLabel;
                salesline."Allow Invoice Disc.":=False;
                SalesLine.Modify();
            end;
        END;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReopenSalesDoc', '', true, true)]
    local procedure OnBeforeReopenSalesDoc(var SalesHeader: Record "Sales Header");
    var SalesLine: Record "sales line";
    begin
        SalesLine.reset;
        SalesLine.Setrange("Document No.", SalesHeader."No.");
        SalesLine.Setrange("Document type", SalesHeader."Document Type");
        SalesLine.Setrange("type", SalesLine.Type::"G/L Account");
        SalesLine.Setrange("Line No.", 99999999);
        SalesLine.Setrange("Quantity Shipped", 0);
        SalesLine.DeleteAll();
    end;
    //EURO000 18.08.21 - END (Porto in Auftrag)
    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterValidateEvent', 'Unit of Measure Code', true, true)]
    local procedure OnAfterValidateEvent(var Rec: Record "Sales Line");
    var begin
        IF rec."Qty. per Unit of Measure" <> 0 then BEGIN
            rec."Unit of Measure":=rec."Unit of Measure" + ' (' + FORMAT(rec."Qty. per Unit of Measure") + ')';
        end;
    end;
    //EURO000 18.08.21 - START (Ursprungsland in VK-Zeile)
    [EventSubscriber(ObjectType::Table, Database::"Sales line", 'OnAfterCopyFromItem', '', true, true)]
    local procedure OnAfterCopyFromItem(var SalesLine: Record "Sales Line";
    Item: Record Item);
    var country: Record "Country/Region";
    SalesHeader: Record "Sales Header";
    begin
        if item."Country/Region of Origin Code" <> '' THEN begin
            country.get(item."Country/Region of Origin Code");
            SalesHeader.get(SalesLine."Document Type", SalesLine."Document No.");
            IF(SalesHeader."Ship-to Country/Region Code" <> 'CH') AND (SalesHeader."Ship-to Country/Region Code" <> '')THEN begin
                SalesLine."Country/Region of Origin Code":=country.code;
                SalesLine."Country/Region of Origin Text":=Country.Name;
            end;
        end;
        SalesLine."Tariff No.":=item."Tariff No.";
    end;
    //EURO000 18.08.21 - End (Ursprungsland in VK-Zeile)
    [EventSubscriber(ObjectType::Table, Database::"My Customer", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertEvent(var Rec: Record "My Customer");
    var Customer: Record "Customer";
    begin
        if customer.get(rec."Customer No.")THEN BEGIN
            rec."Mobile Phone No.":=Customer."Mobile Phone No.";
            rec.modify;
        END end;
}
