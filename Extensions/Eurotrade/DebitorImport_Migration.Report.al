report 50062 "DebitorImport_Migration"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        DialogCaption:='Bitte Debitoren .CSV Datei auswählen:';
        UploadResult:=UploadIntoStream(DialogCaption, '', '', CSVFilename, CSVInStream);
        CSVBuffer.DeleteAll();
        CSVBuffer.LoadDataFromStream(CSVInStream, ';');
        IF CSVBuffer.Findset then repeat CSVBuffer.Value:=delchr(CSVBuffer.Value, '>', ' '); //leerzeichen am ende der Felder entfernen
                //Zeile 1 = TitelZeile
                if CSVBuffer."Line No." > 1 THEN begin
                    case csvbuffer."field no." of 1: begin
                        _CustomerNO:=CSVBuffer.Value;
                        if not Customer.get(CSVBuffer.Value)THEN begin
                            Customer.init;
                            Customer."No.":=CSVBuffer.value;
                            Customer.insert(true);
                        end;
                    end;
                    2: begin
                        Customer.validate(name, CSVBuffer.Value);
                        Customer.Validate("Payment Terms Code", '30 TAGE');
                        Customer.modify(true);
                    end;
                    3: begin
                        Customer.validate("name 2", CSVBuffer.Value);
                        Customer.modify(true);
                    end;
                    4: begin
                        Customer.validate("Address", CSVBuffer.Value);
                        Customer.modify(true);
                    end;
                    5: begin
                        Customer.validate("Post code", CSVBuffer.Value);
                        Customer.modify(true);
                    end;
                    6: begin
                        Customer.validate("City", CSVBuffer.Value);
                        Customer.modify(true);
                    end;
                    7: begin
                        //Geschlecht?
                        if not Salutation.gET('HERR')THEN begin
                            Salutation.init;
                            Salutation.Code:='Herr';
                            Salutation.Insert;
                        end;
                        if not Salutation.gET('Frau')THEN begin
                            Salutation.init;
                            Salutation.Code:='Frau';
                            Salutation.Insert;
                        end;
                        ContactBusinessRelation.Reset;
                        ContactBusinessRelation.setrange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                        ContactBusinessRelation.SetRange("No.", customer."No.");
                        ContactBusinessRelation.Findfirst;
                        contact.get(ContactBusinessRelation."Contact No.");
                        IF Uppercase(CSVBuffer.value) = 'M' then Contact."Salutation Code":='HERR';
                        IF Uppercase(CSVBuffer.value) = 'W' then Contact."Salutation Code":='Frau';
                        contact.modify(True);
                    end;
                    8: begin
                        Evaluate(Contact.Birthday, CSVBuffer.value);
                        Contact.modify(true);
                    end;
                    9: begin
                        IF(Contact.Birthday = 0D) AND (CSVBuffer.value <> '')THEN BEGIN
                            Evaluate(Contact.Birthday, CSVBuffer.value + '00');
                            Contact.modify(true);
                        END;
                    end;
                    10: begin
                        Customer."E-Mail":=copystr(CSVBuffer.Value, 1, MaxStrLen(customer."E-Mail"));
                        Customer.modify(true);
                    end;
                    11: begin
                        IF CSVBuffer.value = '2' then customer."Language Code":='FRS';
                        IF CSVBuffer.value = '3' then customer."Language Code":='ENU';
                        Customer.modify(true);
                    end;
                    13: begin
                        IF CSVBuffer.value = 'Kunstschmiede/Schlosserei' then CSVBuffer.value:='Kunstschmiede';
                        //Customer.validate("Customer Disc. Group", Copystr(CSVBuffer.Value, 1, MaxStrLen(Customer."Customer Disc. Group")));
                        //Customer.modify(true);
                        IF not IndustryGroup.get(Copystr(CSVBuffer.Value, 1, MaxStrLen(IndustryGroup."Code")))THEN begin
                            IndustryGroup.init;
                            IndustryGroup.code:=Copystr(CSVBuffer.Value, 1, MaxStrLen(IndustryGroup."Code"));
                            IndustryGroup.Description:=CSVBuffer.Value;
                            IndustryGroup.insert;
                        end;
                        if not ContactIndustryGroup.get(Contact."no.", Copystr(CSVBuffer.Value, 1, MaxStrLen(ContactIndustryGroup."Industry Group Code")))THEN begin
                            ContactIndustryGroup.init;
                            ContactIndustryGroup."Contact No.":=contact."no.";
                            ContactIndustryGroup."Industry Group Code":=Copystr(CSVBuffer.Value, 1, MaxStrLen(ContactIndustryGroup."Industry Group Code"));
                            ContactIndustryGroup.Insert;
                        end;
                    end;
                    14: begin
                        IF CSVBuffer.Value = 'B2B' Then Customer.validate("B2B", true);
                        IF CSVBuffer.Value = 'B2C' Then Customer.validate("B2C", true);
                        Customer.validate("Customer Disc. Group", Copystr(CSVBuffer.Value, 1, MaxStrLen(Customer."Customer Disc. Group")));
                        Customer.modify(true);
                    end;
                    15: begin
                        Customer.validate("Country/Region Code", CSVBuffer.Value);
                        Customer.modify(true);
                    end;
                    16: begin
                        IF CSVBuffer.Value = 'Inland' Then begin
                            Customer.validate("Gen. Bus. Posting Group", 'Inland');
                            Customer.Validate("Reminder Terms Code", 'INLAND');
                        end;
                        IF CSVBuffer.Value = 'EU' Then BEGIN
                            Customer.validate("Gen. Bus. Posting Group", 'EU');
                            customer.Validate("Currency Code", 'EUR');
                            Customer.Validate("Reminder Terms Code", 'Ausland');
                        END;
                        IF CSVBuffer.Value = 'non EU' Then begin
                            Customer.validate("Gen. Bus. Posting Group", 'Export');
                            Customer.Validate("Reminder Terms Code", 'Ausland');
                        end;
                        IF CSVBuffer.Value = 'Inland' Then Customer.validate("Customer Posting Group", 'Inland');
                        IF CSVBuffer.Value = 'EU' Then Customer.validate("Customer Posting Group", 'EU');
                        IF CSVBuffer.Value = 'non EU' Then Customer.validate("Customer Posting Group", 'Ausland');
                        Customer.modify(true);
                    end;
                    17: begin
                        Customer.validate(Contact, CSVBuffer.Value);
                        Customer.modify(true);
                        customer.SetForceUpdateContact(true);
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
    _CustomerNO: Code[20];
    Customer: Record Customer;
    Contact: Record Contact;
    ContactBusinessRelation: Record "Contact Business Relation";
    Salutation: Record Salutation;
    ContactIndustryGroup: Record "Contact Industry Group";
    IndustryGroup: Record "Industry Group";
}
