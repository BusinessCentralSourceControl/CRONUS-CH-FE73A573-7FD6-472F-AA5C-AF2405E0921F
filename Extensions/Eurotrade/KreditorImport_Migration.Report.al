report 50061 "KreditorImport_Migration"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = False;

    trigger OnPreReport()begin
        DialogCaption:='Bitte Kreditoren .CSV Datei auswählen:';
        UploadResult:=UploadIntoStream(DialogCaption, '', '', CSVFilename, CSVInStream);
        CSVBuffer.DeleteAll();
        CSVBuffer.LoadDataFromStream(CSVInStream, ';');
        IF CSVBuffer.Findset then repeat CSVBuffer.Value:=delchr(CSVBuffer.Value, '>', ' '); //leerzeichen am ende der Felder entfernen
                //Zeile 1 = TitelZeile
                if CSVBuffer."Line No." > 1 THEN begin
                    case csvbuffer."field no." of 1: begin
                        _VendorNO:=CSVBuffer.Value;
                        if not Vendor.get(CSVBuffer.Value)THEN begin
                            Vendor.init;
                            Vendor."No.":=CSVBuffer.value;
                            Vendor.insert(true);
                        end;
                    end;
                    2: begin
                        Vendor.validate(name, CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    3: begin
                        Vendor.validate("name 2", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    4: begin
                        Vendor.validate("Address", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    5: begin
                        Vendor.validate("post code", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    6: begin
                        Vendor.validate("City", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    7: begin
                        Vendor.validate("Country/Region Code", CSVBuffer.Value);
                        Vendor.modify(true);
                        If not Country.get(vendor."Country/Region Code")THEN begin
                            Vendor.Validate("Gen. Bus. Posting Group", 'INLAND');
                            vendor.Validate("Vendor Posting Group", 'INLAND');
                        end
                        else
                        begin
                            IF vendor."Country/Region Code" = 'CH' THEN begin
                                Vendor.Validate("Gen. Bus. Posting Group", 'INLAND');
                                vendor.Validate("Vendor Posting Group", 'INLAND');
                            end;
                            IF Country."EU Country/Region Code" <> '' THEN begin
                                Vendor.Validate("Gen. Bus. Posting Group", 'EU');
                                vendor.Validate("Vendor Posting Group", 'EU');
                            end;
                            IF vendor."Gen. Bus. Posting Group" = '' THEN begin
                                Vendor.Validate("Gen. Bus. Posting Group", 'Export');
                                vendor.Validate("Vendor Posting Group", 'AUSLAND');
                            end;
                        end;
                        Vendor.modify(true);
                    end;
                    8: begin
                        Vendor.validate("Phone No.", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    9: begin
                        Vendor.validate("Phone No. 2", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    10: begin
                        Vendor.validate("Fax No.", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    11: begin
                        Vendor.validate(Contact, CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    12: begin
                        Vendor.validate("Mobile Phone No.", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    13: begin
                        Vendor.validate("Address 2", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    14: begin
                        Vendor."E-Mail":=Copystr(CSVBuffer.Value, 1, 80);
                        Vendor.modify(true);
                    end;
                    15: begin
                        Vendor.validate("Home Page", CSVBuffer.Value);
                        Vendor.modify(true);
                    end;
                    16: begin
                    //Feld 16 muss nicht importiert werden
                    end;
                    17: begin
                        Clear(_Postkonto);
                        Clear(_BESRTeilnehmer);
                        Clear(_Clearing);
                        Clear(_Bankname);
                        Clear(_PLZBank);
                        Clear(_OrtBank);
                        Clear(_Bankkontonr);
                        Clear(_BemerkungBank);
                        Clear(_WährungBank);
                        Clear(_BICSwift);
                        Clear(_IBAN);
                        if not VendorBankAccount.get(Vendor."No.", 1)THEN begin
                            VendorBankAccount.init;
                            VendorBankAccount."Vendor No.":=vendor."No.";
                            VendorBankAccount.Code:='1';
                            VendorBankAccount.Insert;
                        end;
                        _Postkonto:=CSVBuffer.Value;
                    end;
                    18: begin
                        _BESRTeilnehmer:=CSVBuffer.Value;
                    end;
                    19: begin
                        _Clearing:=CSVBuffer.Value;
                    end;
                    20: begin
                        _Bankname:=CSVBuffer.Value;
                    end;
                    21: begin
                        _PLZBank:=CSVBuffer.Value;
                    end;
                    22: begin
                        _OrtBank:=CSVBuffer.Value;
                    end;
                    23: begin
                        _Bankkontonr:=CSVBuffer.Value;
                    end;
                    24: begin
                        _BemerkungBank:=CSVBuffer.Value;
                    end;
                    25: begin
                        Clear(_Postkonto2);
                        Clear(_BESRTeilnehmer2);
                        Clear(_Clearing2);
                        Clear(_Bankname2);
                        Clear(_PLZBank2);
                        Clear(_OrtBank2);
                        Clear(_Bankkontonr2);
                        Clear(_BemerkungBank2);
                        Clear(_WährungBank2);
                        Clear(_BICSwift2);
                        Clear(_IBAN2);
                        if not VendorBankAccount.get(Vendor."No.", 2)THEN begin
                            VendorBankAccount.init;
                            VendorBankAccount."Vendor No.":=vendor."No.";
                            VendorBankAccount.Code:='2';
                            VendorBankAccount.Insert;
                        end;
                        _Clearing2:=CSVBuffer.Value;
                    end;
                    26: begin
                        _Bankname2:=CSVBuffer.Value;
                    end;
                    27: begin
                        _PLZBank2:=CSVBuffer.Value;
                    end;
                    28: begin
                        _OrtBank2:=CSVBuffer.Value;
                    end;
                    29: begin
                        _Bankkontonr2:=CSVBuffer.Value;
                    end;
                    30: begin
                        _BESRTeilnehmer2:=CSVBuffer.Value;
                    end;
                    31: begin
                        "_WährungBank":=CSVBuffer.Value;
                        "_WährungBank2":=CSVBuffer.Value;
                    end;
                    32: begin
                        _BICSwift:=CSVBuffer.Value;
                    end;
                    33: begin
                        _BICSwift2:=CSVBuffer.Value;
                    end;
                    34: begin
                        _IBAN:=CSVBuffer.Value;
                        //Bankdaten 1 füllen
                        VendorBankAccount.get(vendor."No.", '1');
                        IF(Copystr(_IBAN, 1, 2) = 'CH')then begin
                            VendorBankAccount."Payment Form":=VendorBankAccount."Payment Form"::"Bank Payment Domestic";
                        end
                        else
                            VendorBankAccount."Payment Form":=VendorBankAccount."Payment Form"::"Bank Payment Abroad";
                        IF(_Postkonto <> '') AND (_BESRTeilnehmer <> '')then begin
                            VendorBankAccount."Payment Form":=VendorBankAccount."Payment Form"::ESR;
                            VendorBankAccount."ESR Type":=VendorBankAccount."ESR Type"::"9/27";
                        end;
                        IF(_Postkonto <> '') AND (_BESRTeilnehmer = '')then begin
                            VendorBankAccount."Payment Form":=VendorBankAccount."Payment Form"::"Post Payment Domestic";
                        end;
                        IF _Postkonto <> '' then VendorBankAccount."Giro Account No.":=_Postkonto;
                        IF _BESRTeilnehmer <> '' then VendorBankAccount."ESR Account No.":=_BESRTeilnehmer;
                        IF _Clearing <> '' then VendorBankAccount."Clearing No.":=_Clearing;
                        IF _Bankname <> '' then VendorBankAccount.Name:=_bankname;
                        IF _PLZBank <> '' then VendorBankAccount."Post Code":=_PLZBank;
                        IF _OrtBank <> '' then VendorBankAccount.City:=_OrtBank;
                        IF _Bankkontonr <> '' then VendorBankAccount."Bank Account No.":=_Bankkontonr;
                        IF _BemerkungBank <> '' then VendorBankAccount."Message to Reciver":=_BemerkungBank;
                        IF _WährungBank = '1' then VendorBankAccount."Currency Code":='EUR';
                        IF _WährungBank = '2' then VendorBankAccount."Currency Code":='USD';
                        IF _WährungBank = '3' then VendorBankAccount."Currency Code":='GBP';
                        IF _BICSwift <> '' then VendorBankAccount."SWIFT Code":=_BICSwift;
                        IF _IBAN <> '' then VendorBankAccount.IBAN:=_iban;
                        VendorBankAccount.modify(TRUE);
                        IF(VendorBankAccount."Giro Account No." = '') AND (VendorBankAccount."ESR Account No." = '') AND (VendorBankAccount.IBAN = '') AND (VendorBankAccount."Bank Account No." = '')then VendorBankAccount.delete;
                    end;
                    35: begin
                        _IBAN2:=CSVBuffer.Value;
                        //Bankdaten 2 füllen
                        VendorBankAccount.get(vendor."No.", '2');
                        IF(Copystr(_IBAN2, 1, 2) = 'CH')then begin
                            VendorBankAccount."Payment Form":=VendorBankAccount."Payment Form"::"Bank Payment Domestic";
                        end
                        else
                            VendorBankAccount."Payment Form":=VendorBankAccount."Payment Form"::"Bank Payment Abroad";
                        IF(_Postkonto2 <> '') AND (_BESRTeilnehmer2 <> '')then begin
                            VendorBankAccount."Payment Form":=VendorBankAccount."Payment Form"::ESR;
                            VendorBankAccount."ESR Type":=VendorBankAccount."ESR Type"::"9/27";
                        end;
                        IF(_Postkonto2 <> '') AND (_BESRTeilnehmer2 = '')then begin
                            VendorBankAccount."Payment Form":=VendorBankAccount."Payment Form"::"Post Payment Domestic";
                        end;
                        IF _Postkonto2 <> '' then VendorBankAccount."Giro Account No.":=_Postkonto2;
                        IF _BESRTeilnehmer2 <> '' then VendorBankAccount."ESR Account No.":=_BESRTeilnehmer2;
                        IF _Clearing2 <> '' then VendorBankAccount."Clearing No.":=_Clearing2;
                        IF _Bankname2 <> '' then VendorBankAccount.Name:=_bankname2;
                        IF _PLZBank2 <> '' then VendorBankAccount."Post Code":=_PLZBank2;
                        IF _OrtBank2 <> '' then VendorBankAccount.City:=_OrtBank2;
                        IF _Bankkontonr2 <> '' then VendorBankAccount."Bank Account No.":=_Bankkontonr2;
                        IF _BemerkungBank2 <> '' then VendorBankAccount."Message to Reciver":=_BemerkungBank2;
                        IF _WährungBank = '1' then VendorBankAccount."Currency Code":='EUR';
                        IF _WährungBank = '2' then VendorBankAccount."Currency Code":='USD';
                        IF _WährungBank = '3' then VendorBankAccount."Currency Code":='GBP';
                        IF _BICSwift2 <> '' then VendorBankAccount."SWIFT Code":=_BICSwift2;
                        IF _IBAN2 <> '' then VendorBankAccount.IBAN:=_iban2;
                        VendorBankAccount.modify(TRUE);
                        IF(VendorBankAccount."Giro Account No." = '') AND (VendorBankAccount."ESR Account No." = '') AND (VendorBankAccount.IBAN = '') AND (VendorBankAccount."Bank Account No." = '')then VendorBankAccount.delete;
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
    _VendorNO: Code[20];
    Vendor: Record Vendor;
    Country: Record "Country/Region";
    VendorBankAccount: Record "Vendor Bank Account";
    _Postkonto: Text;
    _BESRTeilnehmer: Text;
    _Clearing: Text;
    _Bankname: Text;
    _PLZBank: Text;
    _OrtBank: Text;
    _Bankkontonr: Text;
    _BemerkungBank: Text;
    _WährungBank: Text;
    _BICSwift: Text;
    _IBAN: Text;
    _Postkonto2: Text;
    _BESRTeilnehmer2: Text;
    _Clearing2: Text;
    _Bankname2: Text;
    _PLZBank2: Text;
    _OrtBank2: Text;
    _Bankkontonr2: Text;
    _BemerkungBank2: Text;
    _WährungBank2: Text;
    _BICSwift2: Text;
    _IBAN2: Text;
    Contact: Record Contact;
    ContactBusinessRelation: Record "Contact Business Relation";
}
