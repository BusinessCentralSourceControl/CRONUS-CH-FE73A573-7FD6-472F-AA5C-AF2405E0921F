report 50066 "DebitorRechrabatt_Migration"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        DialogCaption:='Bitte Debitoren Rechnunsgsrabatt .CSV Datei auswählen:';
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
                        end;
                    end;
                    2: begin
                        IF customerExits THEN BEGIN
                            //Customer.validate("Phone No.", CSVBuffer.Value);
                            CustomerInvDiscount.reset;
                            CustomerInvDiscount.SetRange(Code, _CustomerNO);
                            CustomerInvDiscount.Deleteall;
                            CustomerInvDiscount.Init;
                            CustomerInvDiscount.code:=_CustomerNO;
                            Evaluate(CustomerInvDiscount."Discount %", CSVBuffer.value);
                            CustomerInvDiscount.insert;
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
    CustomerInvDiscount: Record "Cust. Invoice Disc.";
}
