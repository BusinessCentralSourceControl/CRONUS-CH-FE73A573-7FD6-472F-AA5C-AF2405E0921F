report 50068 "BilderParent_Migration"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        DialogCaption:='Bitte Bilder Parent .CSV Datei auswählen:';
        UploadResult:=UploadIntoStream(DialogCaption, '', '', CSVFilename, CSVInStream);
        CSVBuffer.DeleteAll();
        CSVBuffer.LoadDataFromStream(CSVInStream, ';');
        IF CSVBuffer.Findset then repeat CSVBuffer.Value:=delchr(CSVBuffer.Value, '>', ' '); //leerzeichen am ende der Felder entfernen
                //Zeile 1 = TitelZeile
                if CSVBuffer."Line No." > 1 THEN begin
                    case csvbuffer."field no." of 1: begin
                        ItemExits:=False;
                        if item.get(CSVBuffer.value)then ItemExits:=TRUE;
                    end;
                    7: begin
                        If ItemExits then begin
                            if CSVBuffer.Value <> '' THEN begin
                                IF item2.get(CSVBuffer.Value)THEN BEGIN
                                    item.Validate("Parent Picture", CSVBuffer.value);
                                    item.modify;
                                END;
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
    _CustomerNO: Code[20];
    Customer: Record Customer;
    ItemExits: Boolean;
    Contact: Record Contact;
    ContactBusinessRelation: Record "Contact Business Relation";
    item: Record Item;
    item2: Record Item;
}
