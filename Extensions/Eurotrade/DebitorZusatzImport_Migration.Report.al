report 50063 "DebitorZusatzImport_Migration"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        DialogCaption:='Bitte Debitoren Zusatz .CSV Datei auswählen:';
        UploadResult:=UploadIntoStream(DialogCaption, '', '', CSVFilename, CSVInStream);
        CSVBuffer.DeleteAll();
        CSVBuffer.LoadDataFromStream(CSVInStream, ';');
        IF CSVBuffer.Findset then repeat CSVBuffer.Value:=delchr(CSVBuffer.Value, '>', ' '); //leerzeichen am ende der Felder entfernen
                //Zeile 1 = TitelZeile
                if CSVBuffer."Line No." > 1 THEN begin
                    case csvbuffer."field no." of 1: begin
                        _CustomerNO:=CSVBuffer.Value;
                        customerExits:=TRUE;
                        if not Customer.get(CSVBuffer.Value)THEN begin
                            //Customer.init;
                            //Customer."No." := CSVBuffer.value;
                            //Customer.insert(true);
                            //CurrReport.Skip;
                            clear(customer);
                            customerExits:=False;
                        end
                        else
                        begin
                            ContactBusinessRelation.Reset;
                            ContactBusinessRelation.setrange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                            ContactBusinessRelation.SetRange("No.", customer."No.");
                            ContactBusinessRelation.Findfirst;
                            contact.get(ContactBusinessRelation."Contact No.");
                        end;
                    end;
                    6: begin
                        IF customerExits THEN BEGIN
                            //Customer.validate("Phone No.", CSVBuffer.Value);
                            Customer."Phone No.":=CSVBuffer.Value;
                            Customer.modify(true);
                            Contact."Phone No.":=CSVBuffer.Value;
                            Contact.modify(true);
                        end;
                    end;
                    7: begin
                        IF customerExits THEN BEGIN
                            Customer.validate("Phone No. 2", CSVBuffer.Value);
                            Customer.modify(true);
                            Contact.validate("Phone No. 2", CSVBuffer.Value);
                            Contact.modify(true);
                        end;
                    end;
                    8: begin
                        IF customerExits THEN BEGIN
                            Customer.validate("Fax No.", CSVBuffer.Value);
                            Customer.modify(true);
                            Contact.validate("Fax No.", CSVBuffer.Value);
                            Contact.modify(true);
                        end;
                    end;
                    9: begin
                        IF customerExits THEN BEGIN
                            //Customer.validate("Mobile Phone No.", CSVBuffer.Value);
                            Customer."Mobile Phone No.":=CSVBuffer.Value;
                            Customer.modify(true);
                            Contact."Mobile Phone No.":=CSVBuffer.Value;
                            Contact.modify(true);
                        end;
                    end;
                    11: begin
                        IF customerExits THEN BEGIN
                            Customer.validate("Home Page", CSVBuffer.Value);
                            Customer.modify(true);
                            Contact.validate("Home Page", CSVBuffer.Value);
                            Contact.modify(true);
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
    _CustomerNO: Code[20];
    Customer: Record Customer;
    customerExits: Boolean;
    Contact: Record Contact;
    ContactBusinessRelation: Record "Contact Business Relation";
}
