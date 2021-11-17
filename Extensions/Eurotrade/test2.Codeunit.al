codeunit 50001 test2
{
    var TempNameValueBuffer: Record "Name/Value Buffer" temporary;
    WSSetup: Record "LOGWS Setup";
    WSFunctions: Codeunit "LOGWS Functions";
    DOMOutRootEmt: XmlElement;
    DOMIn: XmlDocument;
    DOMOut: XmlDocument;
    CurrXmlAttr: XmlAttribute;
    WSGuidList: Dictionary of[Guid, Integer];
    FieldSkipValidate: List of[Boolean];
    GlobalQtyDisc: Boolean;
    MetaData: Boolean;
    ReCalc: Boolean;
    GlobalCustomerNo: Code[20];
    GlobalJobNo: Code[20];
    GlobalUoM: Code[10];
    GlobalVariantCode: Code[10];
    MainRecList: List of[Code[20]];
    GlobalAmt: Decimal;
    GlobalQty: Decimal;
    FieldNo: List of[Integer];
    FilterFieldNo: List of[Integer];
    LastKeyFieldNo: Integer;
    MaxOccurrence: Integer;
    NoOfRecords: Integer;
    StartRow: Integer;
    TableNo: Integer;
    WebshopVersion: Enum "LOGWS Webshop Version";
    WSManualEventMode: Enum "LOGWS Manual Event Mode";
    CurrNamespace: Text;
    FieldElementName: List of[Text];
    FieldName: List of[Text];
    FieldValue: List of[Text];
    FilterValue: List of[Text];
    NamespaceTable: List of[Text];
    OptionName: List of[Text];
    OptionValue: List of[Text];
    TableLinkField: Text;
    TableLinkFilter: Text;
    TableName: Text;
    TableType: Text;
    WebLoginType: Text;
    WebMethod: Text;
    ContactForCustomerNoNotFoundErr: Label 'Contact for Customer No. ''%1'' not found. [85031].';
    ContactNotRegisteredInWSErr: Label 'Contact ''%1'' is not registered in Webshop. [85028].';
    CustomerBlockedErr: Label 'Customer ''%1'' is blocked. [85012].';
    CustomerForContactNoNotFoundErr: Label 'Customer for Contact No. ''%1'' not found. [85029].';
    CustomerNoForContactNotFoundErr: Label 'Customer No. ''%1'' for Contact not found. [85030].';
    CustomerNotRegisteredInWSErr: Label 'Customer ''%1'' is not registered in Webshop. [85021].';
    InvalidNamespaceErr: Label 'Invalid Namespace ''%1''. [85013].';
    InvalidTableNameErr: Label 'Invalid Table Name: ''%1''. [85002].';
    InvalidUsernamePasswordErr: Label 'Invalid Username or Password. [85000].';
    LastErrorErr: Label 'Last Error: %1';
    LinkFieldMissingErr: Label 'If a ''Type'' is specified on table ''%1'', a ''LinkField must be specified too. [85014].';
    MoreThanOneRecInFilterErr: Label 'Filter criteria ''%1'' to table ''%2'' result in more than one record. [85007].';
    NamespaceUrlLbl: Label 'http://www.logicolu.ch/dynamicsnav/', Locked=true;
    RecAlreadyExistsErr: Label 'Record ''%1'' already exists. [85018].';
    RecordsDeletedMsg: Label '%1 records deleted. [85016].';
    RecordsInsertedMsg: Label '%1 records inserted. [85015].';
    RecordsModifiedMsg: Label '%1 records modified. [85011].';
    ReportLbl: Label 'Report %1';
    UnknownFieldInTableErr: Label 'Unknown Field ''%1'' in Table ''%2''. [85005]';
    UnknownWebMethodErr: Label 'Unknown WebMethod: ''%1''. [85006].';
    WebshopCustomerNoLbl: Label 'Webshop Customer No.', Locked=true;
    WebshopPasswordLbl: Label 'Webshop Password', Locked=true;
    WebshopVersionMatchErr: Label 'Webshop Version must be greater than or equal to ''%1''.';
    WSAvailabilityLbl: Label 'WS Availability', Locked=true;
    WSPasswordChangedMsg: Label 'Webshop Password changed. [85027].';
    WSPasswordNotChangedMsg: Label 'Webshop Password not changed. [87001].';
    WSRequestActivityDescriptionLbl: Label 'LogiWebshop Web Service Request', Locked=true;
    WSRequestLbl: Label 'WSRequest', Locked=true;
    WSResponseLbl: Label 'WSResponse', Locked=true;
    WSSignalLbl: Label 'WS Signal', Locked=true;
    CurrXmlAttributes: XmlAttributeCollection;
    NSMgr: XmlNamespaceManager;
    trigger OnRun()begin
        TryProcessRequest();
    end;
    procedure ProcessWsRequest(InMessage: XmlDocument;
    var OutMessage: XmlDocument)var OldGlobalLanguage: Integer;
    begin
        OldGlobalLanguage:=GlobalLanguage();
        DOMIn:=InMessage;
        ProcessRequest();
        OutMessage:=DOMOut;
        GlobalLanguage:=OldGlobalLanguage;
    end;
    [TryFunction]
    procedure TextToDateTimeFilter(Mode: Integer;
    var FilterText: Text)var Regex: Codeunit Regex;
    DateTimePattern: Text;
    OutputFormat: Text;
    begin
        // Ex.: 2019-06-06 00:00:00
        DateTimePattern:='\b(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})\b';
        case Mode of 0: // Date
 OutputFormat:='${year}-${month}-${day}';
        1: // Time
 OutputFormat:='${hour}:${minute}:${second}';
        end;
        FilterText:=Regex.Replace(FilterText, DateTimePattern, OutputFormat);
    end;
    local procedure AppendAttribute(var ParentEmt: XmlElement;
    AttributeName: Text;
    AttributeValue: Text): Boolean begin
        if AttributeName = '' then AttributeName:='Name';
        CurrXmlAttr:=XmlAttribute.Create(AttributeName, AttributeValue);
        exit(ParentEmt.Add(CurrXmlAttr));
    end;
    local procedure AppendField(var ParentEmt: XmlElement;
    NodeName: Text;
    FieldName: Text;
    FieldValue: Text): Boolean var FieldEmt: XmlElement;
    begin
        if NodeName = '' then NodeName:='Field';
        FieldEmt:=XmlElement.Create(NodeName, CurrNamespace);
        FieldEmt.Add(XmlText.Create(FieldValue));
        if FieldName <> '' then AppendAttribute(FieldEmt, '', FieldName);
        exit(ParentEmt.Add(FieldEmt));
    end;
    local procedure AppendWSCategoryAsXml(WSCategoryParm: Record "LOGWS Category";
    BelongsToLineNo: Integer;
    var LineNo: Integer;
    var TableEmt: XmlElement)var WSCategory: Record "LOGWS Category";
    BelongsToLineNo2: Integer;
    begin
        AppendWSCategoryParentNode(WSCategoryParm, 0, BelongsToLineNo, LineNo, TableEmt);
        BelongsToLineNo2:=LineNo;
        // Add child items
        AppendWSCategoryRelationAsXml(WSCategoryParm, LineNo, TableEmt);
        // Add child categories
        WSCategory.SetCurrentKey("Presentation Order");
        WSCategory.SetRange("Parent Category", WSCategoryParm."Code Value");
        WSCategory.SetRange(Excluded, false);
        if WSCategory.FindSet()then repeat AppendWSCategoryAsXml(WSCategory, BelongsToLineNo2, LineNo, TableEmt);
            until WSCategory.Next() = 0;
        AppendWSCategoryParentNode(WSCategoryParm, 1, BelongsToLineNo, LineNo, TableEmt);
    end;
    local procedure AppendWSCategoryItemNode(WSCategory: Record "LOGWS Category";
    Item: Record Item;
    BelongsToLineNo: Integer;
    var LineNo: Integer;
    var TableEmt: XmlElement)var FieldsEmt: XmlElement;
    NodeTypeText: Text;
    begin
        FieldsEmt:=XmlElement.Create('Fields', CurrNamespace);
        TableEmt.Add(FieldsEmt);
        LineNo+=1;
        NodeTypeText:='Item';
        AppendField(FieldsEmt, '', 'Line No.', Format(LineNo));
        AppendField(FieldsEmt, '', 'Main Level No.', Format(WSCategory."Main Level"));
        AppendField(FieldsEmt, '', 'Belongs to Line No.', Format(BelongsToLineNo));
        AppendField(FieldsEmt, '', 'Level', Format(WSCategory.Indentation + 2));
        AppendField(FieldsEmt, '', 'Type', NodeTypeText);
        AppendField(FieldsEmt, '', 'Number', Item."No.");
        AppendField(FieldsEmt, '', 'Description', Item.Description);
        AppendField(FieldsEmt, '', 'Item Category Code', '');
        AppendField(FieldsEmt, '', 'Display Type', '');
    end;
    local procedure AppendWSCategoryParentNode(WSCategory: Record "LOGWS Category";
    NodeType: Integer;
    BelongsToLineNo: Integer;
    var LineNo: Integer;
    var TableEmt: XmlElement)var FieldsEmt: XmlElement;
    DescriptionText: Text;
    DisplayTypeText: Text;
    ItemCategoryText: Text;
    NodeTypeText: Text;
    NumberText: Text;
    begin
        FieldsEmt:=XmlElement.Create('Fields', CurrNamespace);
        TableEmt.Add(FieldsEmt);
        LineNo+=1;
        case NodeType of 0: // Begin-Level
 begin
            NodeTypeText:='Begin-Level';
            NumberText:=WSCategory."Code Value";
            DescriptionText:=WSCategory.Description;
            ItemCategoryText:=WSCategory."Item Category Code";
            DisplayTypeText:=Format(WSCategory."Display Type");
        end;
        1: // End-Level
 begin
            NodeTypeText:='End-Level';
            DescriptionText:='Total ' + WSCategory.Description;
        end;
        end;
        AppendField(FieldsEmt, '', 'Line No.', Format(LineNo));
        AppendField(FieldsEmt, '', 'Main Level No.', Format(WSCategory."Main Level"));
        AppendField(FieldsEmt, '', 'Belongs to Line No.', Format(BelongsToLineNo));
        AppendField(FieldsEmt, '', 'Level', Format(WSCategory.Indentation + 1));
        AppendField(FieldsEmt, '', 'Type', NodeTypeText);
        AppendField(FieldsEmt, '', 'Number', NumberText);
        AppendField(FieldsEmt, '', 'Description', DescriptionText);
        AppendField(FieldsEmt, '', 'Item Category Code', ItemCategoryText);
        AppendField(FieldsEmt, '', 'Display Type', DisplayTypeText);
    end;
    local procedure AppendWSCategoryRelationAsXml(WSCategoryParm: Record "LOGWS Category";
    var LineNo: Integer;
    var TableEmt: XmlElement)var Item: Record Item;
    test: Codeunit Test;
    BelongsToLineNo: Integer;
    begin
        BelongsToLineNo:=LineNo;
        // Get WS Category Items
        test.GetWSCategoryItems(WSCategoryParm, Item);
        Item.MarkedOnly(true);
        if Item.FindSet()then repeat AppendWSCategoryItemNode(WSCategoryParm, Item, BelongsToLineNo, LineNo, TableEmt);
            until Item.Next() = 0;
    end;
    // local procedure ChangeWSPassword()
    // var
    //     Contact: Record Contact;
    //     Customer: Record Customer;
    //     AnswerEmt: XmlElement;
    //     FieldsEmt: XmlElement;
    //     WSPasswordChanged: Boolean;
    //     AnswerText: Text;
    //     NewWSPasswordText: Text;
    //     UserIdText: Text;
    //     ChildNode: XmlNode;
    //     FieldList: XmlNodeList;
    //     FieldNode: XmlNode;
    // begin
    //     DOMIn.SelectNodes('//def:Fields', NSMgr, FieldList);
    //     FieldList.Get(1, FieldNode);
    //     foreach ChildNode in FieldNode.AsXmlElement().GetChildElements() do begin
    //         case ChildNode.AsXmlElement().LocalName() of
    //             'UserId':
    //                 UserIdText := ChildNode.AsXmlElement().InnerText();
    //             'NewPassword':
    //                 NewWSPasswordText := ChildNode.AsXmlElement().InnerText();
    //         end;
    //     end;
    //     case WebLoginType of
    //         Customer.TableName():
    //             begin
    //                 Customer.SetCurrentKey("LOGWS Webshop Login");
    //                 Customer.SetRange("LOGWS Webshop Login", LowerCase(UserIdText));
    //                 Customer.FindFirst();
    //                 if WSFunctions.GetIsolatedStorage(Customer."LOGWS Password Key") <> NewWSPasswordText then begin
    //                     WSFunctions.SavePasswordText(Customer, Customer.FieldNo("LOGWS Password Key"), NewWSPasswordText);
    //                     WSPasswordChanged := true;
    //                 end;
    //             end;
    //         Contact.TableName():
    //             begin
    //                 Contact.SetCurrentKey("LOGWS Webshop Login");
    //                 Contact.SetRange("LOGWS Webshop Login", LowerCase(UserIdText));
    //                 Contact.FindFirst();
    //                 if WSFunctions.GetIsolatedStorage(Contact."LOGWS Password Key") <> NewWSPasswordText then begin
    //                     WSFunctions.SavePasswordText(Contact, Contact.FieldNo("LOGWS Password Key"), NewWSPasswordText);
    //                     WSPasswordChanged := true;
    //                 end;
    //             end;
    //     end;
    //     // Return Result
    //     FieldsEmt := XmlElement.Create('Fields', CurrNamespace);
    //     DOMOutRootEmt.Add(FieldsEmt);
    //     AnswerEmt := XmlElement.Create('Message', CurrNamespace);
    //     if WSPasswordChanged then
    //         AnswerText := WSPasswordChangedMsg
    //     else
    //         AnswerText := WSPasswordNotChangedMsg;
    //     AnswerEmt.Add(XmlText.Create(AnswerText));
    //     FieldsEmt.Add(AnswerEmt)
    // end;
    local procedure ClearGlobalVars()begin
        Clear(GlobalCustomerNo);
        Clear(GlobalJobNo);
        Clear(GlobalQty);
        Clear(GlobalAmt);
        Clear(GlobalQtyDisc);
        Clear(GlobalUoM);
        Clear(GlobalVariantCode);
    end;
    local procedure DateTimeToText(ValueParam: DateTime): Text begin
        exit(Format(ValueParam, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
    end;
    local procedure DateToText(ValueParam: Date): Text begin
        exit(Format(ValueParam, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;
    local procedure DecimalToText(ValueParam: Decimal): Text begin
        exit(Format(ValueParam, 0, '<Sign><Integer><Decimals><comma,.>'));
    end;
    local procedure DeleteData(RecRef: RecordRef)begin
        if RecRef.Count() > 1 then Error(MoreThanOneRecInFilterErr, RecRef.GetFilters(), TableName);
        RecRef.FindFirst();
        UpdateRecCounter();
        RecRef.Delete(true);
    end;
    local procedure EvaluateFieldRefValue(var FieldRefValue: FieldRef;
    TextValue: Text;
    XMLValue: Boolean;
    SkipValidate: Boolean)var ConfigValidateMgt: Codeunit "Config. Validate Management";
    ErrorText: Text;
    begin
        case FieldRefValue.Type()of FieldType::Date: begin
            // Ex.: 2019-06-06 00:00:00
            TextValue:=CopyStr(TextValue, 1, 10);
        end;
        FieldType::Time: begin
            // Ex.: 0000-00-00 12:34:37
            TextValue:=CopyStr(TextValue, 11, 8);
        end;
        end;
        if SkipValidate then ErrorText:=ConfigValidateMgt.EvaluateValue(FieldRefValue, CopyStr(TextValue, 1, 250), XMLValue)
        else
            ErrorText:=ConfigValidateMgt.EvaluateValueWithValidate(FieldRefValue, CopyStr(TextValue, 1, 250), XMLValue);
        if ErrorText <> '' then Error(ErrorText);
    end;
    local procedure GetFieldNo(TableNoParm: Integer;
    FieldNameParm: Text): Integer begin
        exit(GetFieldNo(TableNoParm, FieldNameParm, false));
    end;
    local procedure GetFieldNo(TableNoParm: Integer;
    FieldNameParm: Text;
    ExcludeSpecialFields: Boolean)FieldNo: Integer begin
        FieldNo:=WSFunctions.GetFieldNoFromName(TableNoParm, FieldNameParm, false);
        // Exclude not existing fields
        if FieldNo <> 0 then exit;
        if ExcludeSpecialFields then begin
            TempNameValueBuffer.SetRange(Name, Format(TableNoParm, 0, 9));
            TempNameValueBuffer.SetRange("Value", FieldNameParm);
            if not TempNameValueBuffer.IsEmpty()then exit;
        end;
        Error(UnknownFieldInTableErr, FieldNameParm, TableName);
    end;
    local procedure GetParametersFromXmlNode(XmlNodeParam: XmlNode)var FieldRec: Record Field;
    LanguageMgt: Codeunit Language;
    CurrFieldNodeText: Text;
    CurrNameValue: Text;
    CurrSkipValidateValue: Text;
    ChildNode: XmlNode;
    FieldNode: XmlNode;
    begin
        // Reset values
        Clear(FilterFieldNo);
        Clear(FilterValue);
        Clear(FieldNo);
        Clear(FieldElementName);
        Clear(FieldName);
        Clear(OptionName);
        Clear(OptionValue);
        // Get Child Node info
        foreach ChildNode in XmlNodeParam.AsXmlElement().GetChildElements()do begin
            foreach FieldNode in ChildNode.AsXmlElement().GetChildElements()do begin
                // Get Attribute Values
                FieldNode.AsXmlElement().Attributes().Get('Name', CurrXmlAttr);
                CurrNameValue:=CurrXmlAttr.Value();
                Clear(CurrSkipValidateValue);
                if FieldNode.AsXmlElement().Attributes().Get('SkipValidate', CurrXmlAttr)then CurrSkipValidateValue:=CurrXmlAttr.Value();
                // Get Field Node Text
                CurrFieldNodeText:=FieldNode.AsXmlElement().InnerText();
                case ChildNode.AsXmlElement().LocalName()of 'Filters': begin
                    if((TableNo = Database::AllObjWithCaption) and (CurrNameValue = 'Language')) or ((TableNo = Database::Field) and (CurrNameValue = 'LanguageCode'))then GlobalLanguage:=LanguageMgt.GetLanguageIdOrDefault(CopyStr(CurrFieldNodeText, 1, 10))
                    else
                    begin
                        FilterFieldNo.Add(GetFieldNo(TableNo, CurrNameValue));
                        CurrFieldNodeText:=ConvertStr(CurrFieldNodeText, '@', '?');
                        FilterValue.Add(CurrFieldNodeText);
                    end;
                end;
                'Fields': begin
                    if(WebMethod = 'ReadData') and (CurrNameValue = '*')then begin
                        FieldRec.SetRange(TableNo, TableNo);
                        FieldRec.SetRange(Enabled, true);
                        FieldRec.SetFilter(ObsoleteState, '<>%1', FieldRec.ObsoleteState::Removed);
                        FieldRec.SetFilter("No.", '<%1', 2000000000);
                        if FieldRec.FindSet()then repeat FieldElementName.Add(FieldNode.AsXmlElement().LocalName());
                                FieldName.Add(FieldRec.FieldName);
                                FieldNo.Add(FieldRec."No.");
                            until FieldRec.Next() = 0;
                    end
                    else
                    begin
                        if not((TableNo = Database::Field) and ((CurrNameValue = 'Option String') or (CurrNameValue = 'Option Caption')))then begin
                            FieldElementName.Add(FieldNode.AsXmlElement().LocalName());
                            FieldName.Add(CurrNameValue);
                            FieldNo.Add(GetFieldNo(TableNo, CurrNameValue, true));
                            FieldValue.Add(CurrFieldNodeText);
                            FieldSkipValidate.Add(TextBoolean(CurrSkipValidateValue));
                        end;
                    end;
                end;
                'Options': begin
                    OptionName.Add(CurrNameValue);
                    OptionValue.Add(CurrFieldNodeText);
                end;
                end;
            end;
        end;
        // Handle special cases
        case TableNo of Database::Field: begin
            // Non Removed fields
            FilterFieldNo.Add(GetFieldNo(TableNo, 'ObsoleteState'));
            FilterValue.Add('<>Removed');
            // Non System fields
            FilterFieldNo.Add(GetFieldNo(TableNo, 'No.'));
            FilterValue.Add('<2000000000');
        end;
        end;
    end;
    local procedure GetRealFieldTypeAsString(TableNo: Integer;
    FieldNo: Integer): Text var FldRef: FieldRef;
    RecRef: RecordRef;
    begin
        RecRef.Open(TableNo);
        FldRef:=RecRef.Field(FieldNo);
        exit(Format(FldRef.Type()));
    end;
    local procedure GetReportAsPdf(ReportId: Integer;
    LanguageId: Integer;
    var RecRef: RecordRef;
    var PdfData: BigText)Result: Boolean var Base64Convert: Codeunit "Base64 Convert";
    TempBlob: Codeunit "Temp Blob";
    InStr: InStream;
    OutStr: OutStream;
    Base64Source: Text;
    begin
        Clear(PdfData);
        GlobalLanguage:=LanguageId;
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        Result:=Report.SaveAs(ReportId, '', ReportFormat::Pdf, OutStr, RecRef);
        if Result then begin
            TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
            Base64Source:=Base64Convert.ToBase64(InStr);
            PdfData.AddText(Base64Source);
        end;
    end;
    local procedure InitNamespaces()begin
        SetNamespace('readdata');
        SetNamespace('modifydata');
        SetNamespace('insertdata');
        SetNamespace('deletedata');
        SetNamespace('pricing');
        SetNamespace('newsalesorder');
        SetNamespace('readwebshopgrouping');
        SetNamespace('customerlogin');
        SetNamespace('registeruser');
        SetNamespace('changepassword');
        SetNamespace('printreport');
    end;
    local procedure InitSpecialFieldList()begin
        TempNameValueBuffer.AddNewEntry(Format(Database::Item, 0, 9), WSAvailabilityLbl);
        TempNameValueBuffer.AddNewEntry(Format(Database::Item, 0, 9), WSSignalLbl);
        TempNameValueBuffer.AddNewEntry(Format(Database::Customer, 0, 9), WebshopPasswordLbl);
        TempNameValueBuffer.AddNewEntry(Format(Database::Contact, 0, 9), WebshopPasswordLbl);
        TempNameValueBuffer.AddNewEntry(Format(Database::Contact, 0, 9), WebshopCustomerNoLbl);
    end;
    local procedure InsertDataFields(RecRef: RecordRef)var Contact: Record Contact;
    Customer: Record Customer;
    FldRef: FieldRef;
    RecInserted: Boolean;
    CurrFieldNo: Integer;
    i: Integer;
    begin
        UpdateRecCounter();
        for i:=1 to FieldNo.Count()do begin
            CurrFieldNo:=FieldNo.Get(i);
            if CurrFieldNo > 0 then begin
                FldRef:=RecRef.Field(CurrFieldNo);
                EvaluateFieldRefValue(FldRef, FieldValue.Get(i), false, FieldSkipValidate.Get(i));
                if(CurrFieldNo >= LastKeyFieldNo) and not RecInserted then begin
                    if not RecRef.Insert(true)then Error(RecAlreadyExistsErr, Format(RecRef.RecordId(), 0, 1));
                    RecInserted:=true;
                end;
            end
            else
            begin
                // Handle special fields
                case RecRef.Number()of Database::Customer: begin
                    RecRef.SetTable(Customer);
                    case FieldName.Get(i)of WebshopPasswordLbl: begin
                        RecRef.Modify(true);
                        // WSFunctions.SavePasswordText(RecRef, Customer.FieldNo("LOGWS Password Key"), FieldValue.Get(i));
                        RecRef.Get(Customer.RecordId());
                    end;
                    end;
                end;
                Database::Contact: begin
                    RecRef.SetTable(Contact);
                    case FieldName.Get(i)of WebshopPasswordLbl: begin
                        RecRef.Modify(true);
                        // WSFunctions.SavePasswordText(RecRef, Contact.FieldNo("LOGWS Password Key"), FieldValue.Get(i));
                        RecRef.Get(Contact.RecordId());
                    end;
                    end;
                end;
                end;
            end;
        end;
        RecRef.Modify(true);
    end;
    local procedure LoginWSUser()var Contact: Record Contact;
    ContactBusinessRelation: Record "Contact Business Relation";
    Customer: Record Customer;
    SalesSetup: Record "Sales & Receivables Setup";
    FieldsEmt: XmlElement;
    LoginSuccess: Boolean;
    BalanceLCY: Decimal;
    UserIdText: Text;
    WSPasswordText: Text;
    ChildNode: XmlNode;
    FieldList: XmlNodeList;
    FieldNode: XmlNode;
    begin
        DOMIn.SelectNodes('//def:Fields', NSMgr, FieldList);
        FieldList.Get(1, FieldNode);
        foreach ChildNode in FieldNode.AsXmlElement().GetChildElements()do begin
            case ChildNode.AsXmlElement().LocalName()of 'UserId': UserIdText:=ChildNode.AsXmlElement().InnerText();
            'Password': WSPasswordText:=ChildNode.AsXmlElement().InnerText();
            end;
        end;
        LoginSuccess:=false;
        Customer.SetCurrentKey("LOGWS Webshop Login");
        Customer.SetRange("LOGWS Webshop Login", LowerCase(UserIdText));
        if Customer.FindFirst()then begin
            // Find in Customer
            if Customer.Blocked <> Customer.Blocked::" " then Error(CustomerBlockedErr, Customer."No.");
            if WSPasswordText <> WSFunctions.GetIsolatedStorage(Customer."LOGWS Password Key")then Error(InvalidUsernamePasswordErr);
            if not Customer."LOGWS Registered in Webshop" then Error(CustomerNotRegisteredInWSErr, Customer."No.");
            WebLoginType:=Customer.TableName();
            LoginSuccess:=true;
        end
        else
        begin
            // Find in Contact
            Contact.SetCurrentKey("LOGWS Webshop Login");
            Contact.SetRange("LOGWS Webshop Login", LowerCase(UserIdText));
            if not Contact.FindFirst()then Error(InvalidUsernamePasswordErr);
            if WSPasswordText <> WSFunctions.GetIsolatedStorage(Contact."LOGWS Password Key")then Error(InvalidUsernamePasswordErr);
            if not Contact."LOGWS Registered in Webshop" then Error(ContactNotRegisteredInWSErr, Contact."No.");
            // Find Customer Company
            ContactBusinessRelation.Reset();
            ContactBusinessRelation.SetRange("Contact No.", Contact."Company No.");
            ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
            ContactBusinessRelation.SetFilter("No.", '<>%1', '''''');
            if ContactBusinessRelation.Count() = 1 then begin
                ContactBusinessRelation.FindFirst();
                Customer.Get(ContactBusinessRelation."No.");
                WebLoginType:=Contact.TableName();
                LoginSuccess:=true;
            end
            else
                Error(CustomerForContactNoNotFoundErr, Contact."No.");
        end;
        if LoginSuccess then begin
            // Return Result
            FieldsEmt:=XmlElement.Create('Fields', CurrNamespace);
            AppendAttribute(FieldsEmt, 'CustomerNo', Customer."No.");
            DOMOutRootEmt.Add(FieldsEmt);
            AppendField(FieldsEmt, '', 'LoginType', WebLoginType);
            case WebLoginType of Customer.TableName(): begin
                AppendField(FieldsEmt, '', Customer.FieldName("Last Date Modified"), DateToText(Customer."Last Date Modified"));
                AppendField(FieldsEmt, '', 'LoginName', Customer.Name);
                AppendField(FieldsEmt, '', 'SalespersonCode', Customer."Salesperson Code");
                AppendField(FieldsEmt, '', 'LanguageCode', Customer."Language Code");
                AppendField(FieldsEmt, '', 'ContactNo', '');
                AppendField(FieldsEmt, '', 'ContactName', '');
                AppendField(FieldsEmt, '', 'ContactEMail', '');
            end;
            Contact.TableName(): begin
                AppendField(FieldsEmt, '', Contact.FieldName("Last Date Modified"), DateToText(Contact."Last Date Modified"));
                AppendField(FieldsEmt, '', 'LoginName', Contact."Company Name");
                AppendField(FieldsEmt, '', 'SalespersonCode', Contact."Salesperson Code");
                AppendField(FieldsEmt, '', 'LanguageCode', Contact."Language Code");
                AppendField(FieldsEmt, '', 'ContactNo', Contact."No.");
                AppendField(FieldsEmt, '', 'ContactName', Contact.Name);
                AppendField(FieldsEmt, '', 'ContactEMail', Contact."E-Mail");
            end;
            end;
            // Add Credit Limit info
            if(Customer."Bill-to Customer No." <> '') and (Customer."Bill-to Customer No." <> Customer."No.")then Customer.Get(Customer."Bill-to Customer No.");
            AppendField(FieldsEmt, '', Customer.FieldName("Credit Limit (LCY)"), DecimalToText(Customer."Credit Limit (LCY)"));
            // Find Balance info
            SalesSetup.Get();
            case SalesSetup."Credit Warnings" of SalesSetup."Credit Warnings"::"Both Warnings": begin
                Customer.CalcFields("Balance (LCY)", "Balance Due (LCY)");
                if Customer."Balance (LCY)" > Customer."Balance Due (LCY)" then BalanceLCY:=Customer."Balance (LCY)"
                else
                    BalanceLCY:=Customer."Balance Due (LCY)";
            end;
            SalesSetup."Credit Warnings"::"Credit Limit": begin
                Customer.CalcFields("Balance (LCY)");
                BalanceLCY:=Customer."Balance (LCY)";
            end;
            SalesSetup."Credit Warnings"::"Overdue Balance": begin
                Customer.CalcFields("Balance Due (LCY)");
                BalanceLCY:=Customer."Balance Due (LCY)";
            end;
            SalesSetup."Credit Warnings"::"No Warning": BalanceLCY:=0;
            end;
            AppendField(FieldsEmt, '', Customer.FieldName("Balance (LCY)"), DecimalToText(BalanceLCY));
            AppendField(FieldsEmt, '', Customer.FieldName("Bill-to Customer No."), Customer."Bill-to Customer No.");
        end;
    end;
    local procedure ModfiyDataFields(RecRef: RecordRef)var Contact: Record Contact;
    Customer: Record Customer;
    FldRef: FieldRef;
    CurrFieldNo: Integer;
    i: Integer;
    begin
        if RecRef.Count() > 1 then Error(MoreThanOneRecInFilterErr, RecRef.GetFilters(), TableName);
        RecRef.FindFirst();
        UpdateRecCounter();
        for i:=1 to FieldNo.Count()do begin
            CurrFieldNo:=FieldNo.Get(i);
            if CurrFieldNo > 0 then begin
                FldRef:=RecRef.Field(CurrFieldNo);
                EvaluateFieldRefValue(FldRef, FieldValue.Get(i), false, FieldSkipValidate.Get(i));
            end
            else
            begin
                // Handle special fields
                case RecRef.Number()of Database::Customer: begin
                    RecRef.SetTable(Customer);
                    case FieldName.Get(i)of WebshopPasswordLbl: begin
                        RecRef.Modify(true);
                        // WSFunctions.SavePasswordText(RecRef, Customer.FieldNo("LOGWS Password Key"), FieldValue.Get(i));
                        RecRef.Get(Customer.RecordId());
                    end;
                    end;
                end;
                Database::Contact: begin
                    RecRef.SetTable(Contact);
                    case FieldName.Get(i)of WebshopPasswordLbl: begin
                        RecRef.Modify(true);
                        // WSFunctions.SavePasswordText(RecRef, Contact.FieldNo("LOGWS Password Key"), FieldValue.Get(i));
                        RecRef.Get(Contact.RecordId());
                    end;
                    end;
                end;
                end;
            end;
        end;
        RecRef.Modify(true);
    end;
    local procedure NewSalesDocument()var OrderList: XmlNodeList;
    OrderNode: XmlNode;
    begin
        DOMIn.SelectNodes('//def:Order', NSMgr, OrderList);
        foreach OrderNode in OrderList do NewSalesDocumentHeader(OrderNode);
    end;
    local procedure NewSalesDocumentCommentFields(ParentNode: XmlNode;
    var SalesHeader: Record "Sales Header")var SalesCommentLine: Record "Sales Comment Line";
    FldRef: FieldRef;
    RecRef: RecordRef;
    NextLineNo: Integer;
    CurrFieldNodeText: Text;
    CurrNameValue: Text;
    CurrSkipValidateValue: Text;
    FieldNode: XmlNode;
    begin
        SalesCommentLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesCommentLine.SetRange("No.", SalesHeader."No.");
        SalesCommentLine.SetRange("Document Line No.", 0);
        if SalesCommentLine.FindLast()then NextLineNo:=SalesCommentLine."Line No." + 10000
        else
            NextLineNo:=10000;
        SalesCommentLine.Init();
        SalesCommentLine.SetUpNewLine();
        SalesCommentLine."Document Type":=SalesHeader."Document Type";
        SalesCommentLine."No.":=SalesHeader."No.";
        SalesCommentLine."Document Line No.":=0;
        SalesCommentLine."Line No.":=NextLineNo;
        RecRef.GetTable(SalesCommentLine);
        foreach FieldNode in ParentNode.AsXmlElement().GetChildElements()do begin
            // Get Attribute Values
            FieldNode.AsXmlElement().Attributes().Get('Name', CurrXmlAttr);
            CurrNameValue:=CurrXmlAttr.Value();
            Clear(CurrSkipValidateValue);
            if FieldNode.AsXmlElement().Attributes().Get('SkipValidate', CurrXmlAttr)then CurrSkipValidateValue:=CurrXmlAttr.Value();
            // Get Field Node Text
            CurrFieldNodeText:=FieldNode.AsXmlElement().InnerText();
            FldRef:=RecRef.Field(GetFieldNo(RecRef.Number(), CurrNameValue));
            EvaluateFieldRefValue(FldRef, CurrFieldNodeText, false, TextBoolean(CurrSkipValidateValue));
        end;
        RecRef.Insert();
    end;
    local procedure NewSalesDocumentComments(ParentNode: XmlNode;
    var SalesHeader: Record "Sales Header")var ChildNode: XmlNode;
    begin
        foreach ChildNode in ParentNode.AsXmlElement().GetChildElements()do if ChildNode.AsXmlElement().HasElements()then begin
                case ChildNode.AsXmlElement().LocalName()of 'CommentFields': NewSalesDocumentCommentFields(ChildNode, SalesHeader);
                end;
            end;
    end;
    local procedure NewSalesDocumentHeader(OrderNode: XmlNode)var Customer: Record Customer;
    Item: Record Item;
    PaymentTerms: Record "Payment Terms";
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    SalesSetup: Record "Sales & Receivables Setup";
    TempSalesLine: Record "Sales Line" temporary;
    TotalSalesLine: Record "Sales Line";
    TotalSalesLineLCY: Record "Sales Line";
    SalesPost: Codeunit "Sales-Post";
    WSManualEvents: Codeunit "LOGWS Manual Events";
    LineFieldsEmt: XmlElement;
    LinesEmt: XmlElement;
    OrderEmt: XmlElement;
    OrderFieldsEmt: XmlElement;
    CalculateOnly: Boolean;
    LineAmtPerQty: Decimal;
    LineDiscAmtPerQty: Decimal;
    ProfitLCY: Decimal;
    ProfitPct: Decimal;
    QtyDiscount: Decimal;
    QtyDiscountAmt: Decimal;
    QtyPrice: Decimal;
    TotalAdjCostLCY: Decimal;
    VATAmount: Decimal;
    WSGuidValue: Integer;
    OrderMessageText: Text;
    VATAmountText: Text[30];
    ChildNode: XmlNode;
    begin
        SalesSetup.Get();
        SalesHeader.Init();
        CalculateOnly:=false;
        // Read Header Attributes
        CurrXmlAttributes:=OrderNode.AsXmlElement().Attributes();
        foreach CurrXmlAttr in CurrXmlAttributes do begin
            case CurrXmlAttr.Name of 'DocumentType': begin
                case CurrXmlAttr.Value of 'Quote': SalesHeader."Document Type":=SalesHeader."Document Type"::Quote;
                'Order': SalesHeader."Document Type":=SalesHeader."Document Type"::Order;
                end;
            end;
            'CalculateOnly': CalculateOnly:=TextBoolean(CurrXmlAttr.Value);
            end;
        end;
        if CalculateOnly then SalesHeader."No.":=CopyStr('T' + WSFunctions.GetTempSalesDocNo(), 1, MaxStrLen(SalesHeader."No."));
        SalesHeader."Shipment Date":=Today();
        SalesHeader.Insert(true);
        SalesHeader.InitRecord();
        SalesHeader."LOGWS Document Status":=SalesHeader."LOGWS Document Status"::New;
        SalesHeader.Modify();
        foreach ChildNode in OrderNode.AsXmlElement().GetChildElements()do if ChildNode.AsXmlElement().HasElements()then begin
                case ChildNode.AsXmlElement().LocalName()of 'OrderFields': NewSalesDocumentHeaderFields(ChildNode, SalesHeader);
                'Comments': NewSalesDocumentComments(ChildNode, SalesHeader);
                'Lines': NewSalesDocumentLines(ChildNode, SalesHeader);
                end;
            end;
        if SalesSetup."Calc. Inv. Discount" then begin
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindFirst()then Codeunit.Run(Codeunit::"Sales-Calc. Discount", SalesLine);
        end;
        Clear(SalesPost);
        SalesPost.SumSalesLines(SalesHeader, 0, TotalSalesLine, TotalSalesLineLCY, VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);
        OrderEmt:=XmlElement.Create('Order', CurrNamespace);
        DOMOutRootEmt.Add(OrderEmt);
        OrderFieldsEmt:=XmlElement.Create('OrderFields', CurrNamespace);
        OrderEmt.Add(OrderFieldsEmt);
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        if StrLen(SalesHeader."Sell-to E-Mail") = 0 then begin
            Customer.Get(SalesHeader."Sell-to Customer No.");
            SalesHeader."Sell-to E-Mail":=Customer."E-Mail";
            SalesHeader.Modify();
        end;
        if SalesHeader."Requested Delivery Date" <> 0D then WSFunctions.SetWSSalesDocPromDelDate(SalesHeader);
        if PaymentTerms.Get(SalesHeader."Payment Method Code")then begin
            SalesHeader.Validate("Payment Terms Code", SalesHeader."Payment Method Code");
            SalesHeader.Modify();
        end;
        // Append OrderFields
        AppendField(OrderFieldsEmt, '', SalesHeader.FieldName("No."), SalesHeader."No.");
        AppendField(OrderFieldsEmt, '', SalesHeader.FieldName("Currency Code"), SalesHeader."Currency Code");
        AppendField(OrderFieldsEmt, '', SalesHeader.FieldName(Amount), DecimalToText(Round(TotalSalesLine.Amount, 0.01)));
        AppendField(OrderFieldsEmt, '', 'VATAmount', DecimalToText(Round(VATAmount, 0.01)));
        AppendField(OrderFieldsEmt, '', SalesHeader.FieldName("Amount Including VAT"), DecimalToText(Round(TotalSalesLine."Amount Including VAT", 0.01)));
        AppendField(OrderFieldsEmt, '', SalesHeader.FieldName("Invoice Discount Amount"), DecimalToText(Round(TotalSalesLine."Inv. Discount Amount", 0.01)));
        AppendField(OrderFieldsEmt, '', SalesHeader.FieldName("Invoice Discount Value"), DecimalToText(SalesHeader."Invoice Discount Value"));
        AppendField(OrderFieldsEmt, '', SalesHeader.FieldName("Prices Including VAT"), Format(SalesHeader."Prices Including VAT", 0, '<Number>'));
        if SalesHeader."Requested Delivery Date" <> 0D then AppendField(OrderFieldsEmt, '', SalesHeader.FieldName("Promised Delivery Date"), DateToText(SalesHeader."Promised Delivery Date"));
        // Append Lines + LineFields
        LinesEmt:=XmlElement.Create('Lines', CurrNamespace);
        OrderEmt.Add(LinesEmt);
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet()then repeat LineFieldsEmt:=XmlElement.Create('LineFields', CurrNamespace);
                LinesEmt.Add(LineFieldsEmt);
                if SalesLine.Type.AsInteger() = 0 then AppendAttribute(LineFieldsEmt, 'Type', 'blank')
                else
                    AppendAttribute(LineFieldsEmt, 'Type', Format(SalesLine.Type));
                // Get WS GUID from Dictionary
                if WSGuidList.Get(SalesLine.SystemId, WSGuidValue)then AppendField(LineFieldsEmt, '', 'WS GUID', Format(WSGuidValue));
                AppendField(LineFieldsEmt, '', SalesLine.FieldName(Description), SalesLine.Description);
                if SalesLine.Type.AsInteger() <> 0 then begin
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("No."), SalesLine."No.");
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName(Quantity), DecimalToText(SalesLine.Quantity));
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("Unit Price"), DecimalToText(Round(SalesLine."Unit Price", 0.01)));
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("Line Discount %"), DecimalToText(SalesLine."Line Discount %"));
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("Line Discount Amount"), DecimalToText(Round(SalesLine."Line Discount Amount", 0.01)));
                    LineDiscAmtPerQty:=SalesLine."Unit Price" * SalesLine."Line Discount %" / 100;
                    AppendField(LineFieldsEmt, '', 'LineDiscountAmountPerQty', DecimalToText(Round(LineDiscAmtPerQty, 0.01)));
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("Line Amount"), DecimalToText(Round(SalesLine."Line Amount", 0.01)));
                    LineAmtPerQty:=SalesLine."Unit Price" * (1 - (SalesLine."Line Discount %" / 100));
                    AppendField(LineFieldsEmt, '', 'LineAmountPerQty', DecimalToText(Round(LineAmtPerQty, 0.01)));
                    if(SalesLine.Type = SalesLine.Type::Item)then begin
                        // Get price for 1 quantity
                        if SalesLine.Quantity <> 1 then begin
                            TempSalesLine:=SalesLine;
                            TempSalesLine.Quantity:=1;
                            WSFunctions.GetWSSalesLinePriceValues(SalesHeader, TempSalesLine);
                            QtyPrice:=TempSalesLine.Amount;
                        end
                        else
                            QtyPrice:=LineAmtPerQty;
                        QtyDiscount:=WSFunctions.CalcTotalDiscount(QtyPrice, LineAmtPerQty);
                        QtyDiscountAmt:=WSFunctions.CalcTotalDiscount(QtyPrice, LineAmtPerQty);
                        AppendField(LineFieldsEmt, '', 'QtyPrice', DecimalToText(Round(QtyPrice, 0.01)));
                        AppendField(LineFieldsEmt, '', 'QtyDiscount', DecimalToText(Round(QtyDiscount, 0.01)));
                        AppendField(LineFieldsEmt, '', 'QtyDiscountAmount', DecimalToText(Round(QtyDiscountAmt, 0.01)));
                    end;
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("VAT %"), DecimalToText(SalesLine."VAT %"));
                    if CalculateOnly and (SalesLine.Type = SalesLine.Type::Item)then begin
                        Item.Reset();
                        Item.Get(SalesLine."No.");
                        if SalesLine."Variant Code" <> '' then Item.SetRange("Variant Filter", SalesLine."Variant Code");
                        AppendField(LineFieldsEmt, '', 'WS Availability', DecimalToText(WSFunctions.CalcItemAvailabilityValue(Item)));
                        AppendField(LineFieldsEmt, '', 'WS Signal', DecimalToText(WSFunctions.CalcItemSignalValue(Item)));
                    end;
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("Unit of Measure Code"), SalesLine."Unit of Measure Code");
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("Variant Code"), SalesLine."Variant Code");
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName(Amount), DecimalToText(Round(SalesLine.Amount, 0.01)));
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("Amount Including VAT"), DecimalToText(Round(SalesLine."Amount Including VAT", 0.01)));
                    AppendField(LineFieldsEmt, '', SalesLine.FieldName("Inv. Discount Amount"), DecimalToText(Round(SalesLine."Inv. Discount Amount", 0.01)));
                end;
            until SalesLine.Next() = 0;
        AppendAttribute(OrderEmt, 'Message', OrderMessageText);
        if CalculateOnly then begin
            BindSubscription(WSManualEvents);
            WSManualEvents.SetManualEventMode(WSManualEventMode::PreventAutoArchiveSalesDoc);
            SalesHeader.Delete(true);
            UnbindSubscription(WSManualEvents);
        end;
    end;
    local procedure NewSalesDocumentHeaderFields(ParentNode: XmlNode;
    var SalesHeader: Record "Sales Header")var FldRef: FieldRef;
    RecRef: RecordRef;
    CurrFieldNodeText: Text;
    CurrNameValue: Text;
    CurrSkipValidateValue: Text;
    FieldNode: XmlNode;
    begin
        // Get RecRef
        RecRef.GetTable(SalesHeader);
        foreach FieldNode in ParentNode.AsXmlElement().GetChildElements()do begin
            // Get Attribute Values
            FieldNode.AsXmlElement().Attributes().Get('Name', CurrXmlAttr);
            CurrNameValue:=CurrXmlAttr.Value();
            Clear(CurrSkipValidateValue);
            if FieldNode.AsXmlElement().Attributes().Get('SkipValidate', CurrXmlAttr)then CurrSkipValidateValue:=CurrXmlAttr.Value();
            // Get Field Node Text
            CurrFieldNodeText:=FieldNode.AsXmlElement().InnerText();
            FldRef:=RecRef.Field(GetFieldNo(RecRef.Number(), CurrNameValue));
            EvaluateFieldRefValue(FldRef, CurrFieldNodeText, false, TextBoolean(CurrSkipValidateValue));
        end;
        RecRef.Modify();
        RecRef.SetTable(SalesHeader);
    end;
    local procedure NewSalesDocumentLineFields(ParentNode: XmlNode;
    var SalesHeader: Record "Sales Header")var SalesLine: Record "Sales Line";
    TransferExtendedText: Codeunit "Transfer Extended Text";
    FldRef: FieldRef;
    SystemIdValue: Guid;
    RecRef: RecordRef;
    NextLineNo: Integer;
    WSGuidValue: Integer;
    SalesLineType: Enum "Sales Line Type";
    CurrFieldNodeText: Text;
    CurrNameValue: Text;
    CurrSkipValidateValue: Text;
    TypeText: Text;
    FieldNode: XmlNode;
    begin
        // Get Attributes
        CurrXmlAttributes:=ParentNode.AsXmlElement().Attributes();
        foreach CurrXmlAttr in CurrXmlAttributes do begin
            case CurrXmlAttr.Name of 'Type': TypeText:=CurrXmlAttr.Value;
            end;
        end;
        if TypeText = 'blank' then TypeText:=' ';
        if Evaluate(SalesLineType, TypeText)then;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast()then NextLineNo:=SalesLine."Line No." + 10000
        else
            NextLineNo:=10000;
        SalesLine.Init();
        SalesLine."Document Type":=SalesHeader."Document Type";
        SalesLine."Document No.":=SalesHeader."No.";
        SalesLine."Line No.":=NextLineNo;
        SalesLine.Validate(Type, SalesLineType);
        SalesLine.Insert();
        SystemIdValue:=SalesLine.SystemId;
        RecRef.GetTable(SalesLine);
        foreach FieldNode in ParentNode.AsXmlElement().GetChildElements()do begin
            Clear(FldRef);
            // Get Attribute Values
            FieldNode.AsXmlElement().Attributes().Get('Name', CurrXmlAttr);
            CurrNameValue:=CurrXmlAttr.Value();
            Clear(CurrSkipValidateValue);
            if FieldNode.AsXmlElement().Attributes().Get('SkipValidate', CurrXmlAttr)then CurrSkipValidateValue:=CurrXmlAttr.Value();
            // Get Field Node Text
            CurrFieldNodeText:=FieldNode.AsXmlElement().InnerText();
            // Fill WS GUID to Dictionary for return usage
            case CurrNameValue of 'WS GUID': begin
                if Evaluate(WSGuidValue, CurrFieldNodeText)then;
                WSGuidList.Add(SystemIdValue, WSGuidValue);
            end;
            else
            begin
                FldRef:=RecRef.Field(GetFieldNo(RecRef.Number(), CurrNameValue));
                EvaluateFieldRefValue(FldRef, CurrFieldNodeText, false, TextBoolean(CurrSkipValidateValue));
            end;
            end;
        end;
        RecRef.Modify();
        RecRef.SetTable(SalesLine);
        if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, false)then TransferExtendedText.InsertSalesExtText(SalesLine);
    end;
    local procedure NewSalesDocumentLines(ParentNode: XmlNode;
    var SalesHeader: Record "Sales Header")var ChildNode: XmlNode;
    begin
        foreach ChildNode in ParentNode.AsXmlElement().GetChildElements()do if ChildNode.AsXmlElement().HasElements()then begin
                case ChildNode.AsXmlElement().LocalName()of 'LineFields': NewSalesDocumentLineFields(ChildNode, SalesHeader);
                end;
            end;
    end;
    local procedure PrintReport()var Language: Record Language;
    LanguageMgt: Codeunit Language;
    AnswerEmt: XmlElement;
    PdfDataEmt: XmlElement;
    RecRef: RecordRef;
    PdfData: BigText;
    ReportId: Integer;
    LanguageCodeText: Text;
    ReportList: XmlNodeList;
    ReportNode: XmlNode;
    begin
        DOMIn.SelectNodes('//def:Report', NSMgr, ReportList);
        ReportList.Get(1, ReportNode);
        CurrXmlAttributes:=ReportNode.AsXmlElement().Attributes();
        foreach CurrXmlAttr in CurrXmlAttributes do begin
            case CurrXmlAttr.Name of 'ReportID': Evaluate(ReportId, CurrXmlAttr.Value);
            'TableName': TableName:=CurrXmlAttr.Value;
            'LanguageCode': LanguageCodeText:=CurrXmlAttr.Value;
            end;
        end;
        if not Language.Get(LanguageCodeText)then LanguageCodeText:=WSSetup."Shop Default Language";
        TableNo:=WSFunctions.GetTableNoFromName(TableName);
        if TableNo = 0 then Error(InvalidTableNameErr, TableName);
        GetParametersFromXmlNode(ReportNode);
        RecRef.Open(TableNo);
        // Set Filters
        SetRecFilters(RecRef);
        GetReportAsPdf(ReportId, LanguageMgt.GetLanguageIdOrDefault(CopyStr(LanguageCodeText, 1, 10)), RecRef, PdfData);
        AnswerEmt:=XmlElement.Create('Report', CurrNamespace);
        AppendAttribute(AnswerEmt, 'Description', StrSubstNo(ReportLbl, ReportId));
        AppendAttribute(AnswerEmt, 'ReportID', Format(ReportId));
        DOMOutRootEmt.Add(AnswerEmt);
        PdfDataEmt:=XmlElement.Create('PDFData', CurrNamespace);
        AnswerEmt.Add(PdfDataEmt);
        PdfDataEmt.Add(XmlText.Create(Format(PdfData)));
    end;
    local procedure ProcessDataTable(ProcessMode: Text)var AnswerEmt: XmlElement;
    FldRef: FieldRef;
    RecRef: RecordRef;
    KeyRefVar: KeyRef;
    i: Integer;
    AnswerText: Text;
    TableKey: Text;
    TableList: XmlNodeList;
    TableNode: XmlNode;
    begin
        // Get Table info
        DOMIn.SelectNodes('//def:Table', NSMgr, TableList);
        foreach TableNode in TableList do begin
            // Reset values
            TableName:='';
            TableType:='';
            TableKey:='';
            TableLinkField:='';
            MaxOccurrence:=0;
            StartRow:=0;
            MetaData:=false;
            ReCalc:=false;
            NoOfRecords:=0;
            // Get Table Attributes
            CurrXmlAttributes:=TableNode.AsXmlElement().Attributes();
            foreach CurrXmlAttr in CurrXmlAttributes do begin
                case CurrXmlAttr.Name of 'Name': TableName:=CurrXmlAttr.Value;
                'Type': TableType:=CurrXmlAttr.Value;
                'Key': TableKey:=CurrXmlAttr.Value;
                'LinkField': TableLinkField:=CurrXmlAttr.Value;
                'MaxOccurence': Evaluate(MaxOccurrence, CurrXmlAttr.Value);
                'StartRow': Evaluate(StartRow, CurrXmlAttr.Value);
                'MetaData': MetaData:=TextBoolean(CurrXmlAttr.Value);
                'ReCalc': ReCalc:=TextBoolean(CurrXmlAttr.Value);
                end;
            end;
            TableNo:=WSFunctions.GetTableNoFromName(TableName);
            if TableNo = 0 then Error(InvalidTableNameErr, TableName);
            if TableType = 'Main' then begin
                // Reset values
                TableLinkFilter:='';
                Clear(MainRecList);
            end;
            if(TableType <> '') and (TableLinkField = '')then Error(LinkFieldMissingErr, TableName);
            GetParametersFromXmlNode(TableNode);
            Clear(RecRef);
            RecRef.Open(TableNo);
            // Get Primary Key
            KeyRefVar:=RecRef.KeyIndex(1);
            for i:=1 to KeyRefVar.FieldCount()do begin
                FldRef:=KeyRefVar.FieldIndex(i);
                LastKeyFieldNo:=FldRef.Number();
            end;
            if TableKey <> '' then RecRef.SetView('sorting(' + TableKey + ')');
            // Set Filters
            SetRecFilters(RecRef);
            if(TableType = 'Sub') and (TableLinkFilter <> '')then begin
                FldRef:=RecRef.Field(GetFieldNo(TableNo, TableLinkField));
                FldRef.SetFilter(TableLinkFilter);
            end;
            case ProcessMode of 'Read': ReadDataFields(RecRef);
            'Modify': ModfiyDataFields(RecRef);
            'Insert': InsertDataFields(RecRef);
            'Delete': DeleteData(RecRef);
            end;
            if ProcessMode in['Modify', 'Insert', 'Delete']then begin
                case ProcessMode of 'Modify': AnswerText:=StrSubstNo(RecordsModifiedMsg, NoOfRecords);
                'Insert': AnswerText:=StrSubstNo(RecordsInsertedMsg, NoOfRecords);
                'Delete': AnswerText:=StrSubstNo(RecordsDeletedMsg, NoOfRecords);
                end;
                AnswerEmt:=XmlElement.Create('Message', CurrNamespace);
                AnswerEmt.Add(XmlText.Create(AnswerText));
                DOMOutRootEmt.Add(AnswerEmt);
            end;
        end;
    end;
    local procedure ProcessRequest()var Result: Boolean;
    DOMInText: Text;
    DOMOutText: Text;
    LastErrorText: Text;
    begin
        WSSetup.Get();
        ClearLastError();
        Commit();
        Result:=Run();
        LastErrorText:=StrSubstNo(LastErrorErr, GetLastErrorText());
        if WSSetup."WS Debugging Enabled" then begin
            // Log Request
            if DOMIn.WriteTo(DOMInText)then;
            WSFunctions.LogWSActivity(0, WebMethod, WSRequestActivityDescriptionLbl, WSRequestLbl, DOMInText);
            // Log Response
            if Result then begin
                if DOMOut.WriteTo(DOMOutText)then;
                WSFunctions.LogWSActivity(0, WebMethod, WSRequestActivityDescriptionLbl, WSResponseLbl, DOMOutText);
            end
            else
            begin
                WSFunctions.LogWSActivity(1, WebMethod, WSRequestActivityDescriptionLbl, LastErrorText, LastErrorText);
            end;
            Commit();
        end;
        if not Result then Error(LastErrorText);
    end;
    local procedure ReadDataFields(RecRef: RecordRef)var Contact: Record Contact;
    ContBusRel: Record "Contact Business Relation";
    Customer: Record Customer;
    Item: Record Item;
    TempBlob: Codeunit "Temp Blob";
    test: Codeunit Test;
    FieldEmt: XmlElement;
    FieldsEmt: XmlElement;
    TableEmt: XmlElement;
    FldRef: FieldRef;
    OptFldRef: FieldRef;
    OptRecRef: RecordRef;
    InStr: InStream;
    ProcessRecord: Boolean;
    CurrFieldNo: Integer;
    i: Integer;
    MaxRow: Integer;
    MinRow: Integer;
    OptTableNo: Integer;
    RecordCount: Integer;
    RecordCounter: Integer;
    StringPos: Integer;
    BufferTxt: Text;
    OptFldName: Text;
    OptTableName: Text;
    TextValue: Text;
    TxtBuilder: TextBuilder;
    begin
        TableEmt:=XmlElement.Create('Table', CurrNamespace);
        DOMOutRootEmt.Add(TableEmt);
        AppendAttribute(TableEmt, '', TableName);
        if TableType = 'Sub' then if MainRecList.Count() = 0 then exit;
        RecordCount:=RecRef.Count();
        if MaxOccurrence = 0 then MaxOccurrence:=RecordCount;
        if StartRow = 0 then StartRow:=1;
        if StartRow < 0 then begin
            MinRow:=RecordCount + (StartRow + 1) - (MaxOccurrence - 1);
            MaxRow:=RecordCount + (StartRow + 1);
        end
        else
        begin
            MinRow:=StartRow;
            MaxRow:=(StartRow - 1) + MaxOccurrence;
        end;
        if(TableNo = Database::Item) and ReCalc then test.RecalcWSAssortmentItems();
        if RecRef.FindSet()then repeat Clear(OptTableName);
                Clear(OptFldName);
                RecordCounter+=1;
                if(RecordCounter < MinRow) or (RecordCounter > MaxRow)then ProcessRecord:=false
                else
                    ProcessRecord:=true;
                if(TableType = 'Main') and ProcessRecord then begin
                    FldRef:=RecRef.Field(GetFieldNo(TableNo, TableLinkField));
                    MainRecList.Add(Format(FldRef.Value()));
                    if TableLinkFilter = '' then TableLinkFilter:='''' + Format(FldRef.Value()) + ''''
                    else
                        TableLinkFilter+='|''' + Format(FldRef.Value()) + '''';
                end;
                if TableType = 'Sub' then begin
                    FldRef:=RecRef.Field(GetFieldNo(TableNo, TableLinkField));
                    ProcessRecord:=MainRecList.Contains(Format(FldRef.Value()));
                end;
                if ProcessRecord then begin
                    UpdateRecCounter();
                    FieldsEmt:=XmlElement.Create('Fields', CurrNamespace);
                    TableEmt.Add(FieldsEmt);
                    for i:=1 to FieldNo.Count()do begin
                        CurrFieldNo:=FieldNo.Get(i);
                        TextValue:='';
                        if CurrFieldNo > 0 then begin
                            FldRef:=RecRef.Field(CurrFieldNo);
                            if FldRef.Class() = FieldClass::FlowField then FldRef.CalcField();
                            // Get Text Value
                            case FldRef.Type of FieldType::Option: begin
                                if(TableNo = Database::Field) and (FldRef.Name() = 'Type')then begin
                                    OptTableNo:=WSFunctions.GetTableNoFromName(OptTableName);
                                    TextValue:=GetRealFieldTypeAsString(OptTableNo, GetFieldNo(OptTableNo, OptFldName));
                                end
                                else
                                begin
                                    TextValue:=Format(FldRef.Value);
                                    if Evaluate(StringPos, TextValue)then TextValue:=SelectStr(StringPos + 1, Format(FldRef.OptionMembers()));
                                end;
                            end;
                            FieldType::Boolean: begin
                                TextValue:=Format(FldRef.Value, 0, '<Number>');
                            end;
                            FieldType::Decimal: begin
                                TextValue:=DecimalToText(FldRef.Value());
                            end;
                            FieldType::Date: begin
                                TextValue:=DateToText(FldRef.Value());
                            end;
                            FieldType::Time: begin
                                TextValue:=TimeToText(FldRef.Value());
                            end;
                            FieldType::DateTime: begin
                                TextValue:=DateTimeToText(FldRef.Value());
                            end;
                            FieldType::Blob: begin
                                TempBlob.FromFieldRef(FldRef);
                                if TempBlob.HasValue()then begin
                                    TempBlob.CreateInStream(InStr);
                                    TxtBuilder.Clear();
                                    while InStr.Read(BufferTxt) <> 0 do TxtBuilder.Append(BufferTxt);
                                    TextValue:=CopyStr(TxtBuilder.ToText(), 1, 4000);
                                end
                                else
                                    TextValue:='';
                            end;
                            else
                                TextValue:=Format(FldRef.Value());
                            end;
                        end
                        else
                        begin
                            // Handle special fields
                            case RecRef.Number()of Database::Item: begin
                                RecRef.SetTable(Item);
                                case FieldName.Get(i)of WSAvailabilityLbl: TextValue:=DecimalToText(WSFunctions.CalcItemAvailabilityValue(Item));
                                WSSignalLbl: TextValue:=DecimalToText(WSFunctions.CalcItemSignalValue(Item));
                                end;
                            end;
                            Database::Customer: begin
                                RecRef.SetTable(Customer);
                                case FieldName.Get(i)of WebshopPasswordLbl: begin
                                    FldRef:=RecRef.Field(Customer.FieldNo("LOGWS Password Key"));
                                    TextValue:=WSFunctions.GetIsolatedStorage(FldRef.Value());
                                end;
                                end;
                            end;
                            Database::Contact: begin
                                RecRef.SetTable(Contact);
                                case FieldName.Get(i)of WebshopPasswordLbl: begin
                                    FldRef:=RecRef.Field(Contact.FieldNo("LOGWS Password Key"));
                                    TextValue:=WSFunctions.GetIsolatedStorage(FldRef.Value());
                                end;
                                WebshopCustomerNoLbl: begin
                                    ContBusRel.SetRange("Contact No.", Contact."Company No.");
                                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                                    ContBusRel.SetFilter("No.", '<>%1', '');
                                    if ContBusRel.FindFirst() and (ContBusRel.Count() = 1)then TextValue:=ContBusRel."No.";
                                end;
                                end;
                            end;
                            end;
                        end;
                        FieldEmt:=XmlElement.Create(FieldElementName.Get(i), CurrNamespace);
                        FieldEmt.Add(XmlText.Create(TextValue));
                        AppendAttribute(FieldEmt, '', FieldName.Get(i));
                        if MetaData and (CurrFieldNo > 0)then begin
                            AppendAttribute(FieldEmt, 'Length', Format(FldRef.Length()));
                            AppendAttribute(FieldEmt, 'Type', Format(FldRef.Type()));
                        end;
                        FieldsEmt.Add(FieldEmt);
                        case FieldName.Get(i)of 'TableName': OptTableName:=TextValue;
                        'FieldName': OptFldName:=TextValue;
                        end;
                    end;
                    if(RecRef.Number() = Database::Field)then begin
                        OptTableNo:=WSFunctions.GetTableNoFromName(OptTableName);
                        OptRecRef.Open(OptTableNo);
                        OptFldRef:=OptRecRef.Field(GetFieldNo(OptTableNo, OptFldName));
                        // Option Members
                        FieldEmt:=XmlElement.Create(FieldElementName.Get(i), CurrNamespace);
                        FieldEmt.Add(XmlText.Create(OptFldRef.OptionMembers()));
                        AppendAttribute(FieldEmt, '', 'Option String');
                        if MetaData then begin
                            AppendAttribute(FieldEmt, 'Length', '250');
                            AppendAttribute(FieldEmt, 'Type', 'Text');
                        end;
                        FieldsEmt.Add(FieldEmt);
                        // Option Caption
                        FieldEmt:=XmlElement.Create(FieldElementName.Get(i), CurrNamespace);
                        FieldEmt.Add(XmlText.Create(OptFldRef.OptionCaption()));
                        AppendAttribute(FieldEmt, '', 'Option Caption');
                        if MetaData then begin
                            AppendAttribute(FieldEmt, 'Length', '250');
                            AppendAttribute(FieldEmt, 'Type', 'Text');
                        end;
                        FieldsEmt.Add(FieldEmt);
                        OptRecRef.Close();
                    end;
                end;
            until RecRef.Next() = 0;
        AppendAttribute(TableEmt, 'NoOfRecords', Format(NoOfRecords));
    end;
    local procedure ReadWSGrouping()var WSCategory: Record "LOGWS Category";
    test: Codeunit Test;
    TableEmt: XmlElement;
    LineNo: Integer;
    begin
        TableEmt:=XmlElement.Create('Table', CurrNamespace);
        DOMOutRootEmt.Add(TableEmt);
        AppendAttribute(TableEmt, '', 'WebshopGrouping');
        test.UpdateWSCategoryPresentationOrder();
        test.UpdateWSCategorySorting();
        test.RecalcWSAssortmentItems();
        WSCategory.SetCurrentKey("Presentation Order");
        WSCategory.SetRange("Parent Category", '');
        WSCategory.SetRange(Excluded, false);
        if WSCategory.FindSet()then repeat AppendWSCategoryAsXml(WSCategory, 0, LineNo, TableEmt);
            until WSCategory.Next() = 0;
    end;
    local procedure RegisterWSUser()var Contact: Record Contact;
    ContactBusinessRelation: Record "Contact Business Relation";
    ContactCompany: Record Contact;
    Customer: Record Customer;
    CustomerCompany: Record Customer;
    MarketingSetup: Record "Marketing Setup";
    CustContUpdate: Codeunit "CustCont-Update";
    FieldsEmt: XmlElement;
    FldRef: FieldRef;
    RecRef: RecordRef;
    CustomerNo: Code[20];
    TableList: XmlNodeList;
    TableNode: XmlNode;
    begin
        DOMIn.SelectNodes('//def:Table', NSMgr, TableList);
        foreach TableNode in TableList do begin
            // Reset values
            TableName:='';
            // Get Table Attributes
            CurrXmlAttributes:=TableNode.AsXmlElement().Attributes();
            foreach CurrXmlAttr in CurrXmlAttributes do begin
                case CurrXmlAttr.Name of 'Name': TableName:=CurrXmlAttr.Value;
                'CustomerNo': CustomerNo:=CopyStr(CurrXmlAttr.Value, 1, MaxStrLen(CustomerNo));
                end;
            end;
            TableNo:=WSFunctions.GetTableNoFromName(TableName);
            if(TableNo = 0) or not(TableNo in[Database::Customer, Database::Contact])then Error(InvalidTableNameErr, TableName);
            GetParametersFromXmlNode(TableNode);
            Clear(RecRef);
            RecRef.Open(TableNo);
            case TableNo of Database::Customer: begin
                // Insert fields generically
                InsertDataFields(RecRef);
                // Check inserted fields
                FldRef:=RecRef.Field(Customer.FieldNo("LOGWS Webshop Login"));
                FldRef.TestField();
                FldRef:=RecRef.Field(Customer.FieldNo("LOGWS Password Key"));
                FldRef.TestField();
                // Apply Cust. Template
                RecRef.SetTable(Customer);
                WSFunctions.ApplyCustomerTemplateToWSCustomer(Customer);
                CustContUpdate.OnModify(Customer);
                // Return Result
                FieldsEmt:=XmlElement.Create('Fields', CurrNamespace);
                AppendAttribute(FieldsEmt, 'CustomerNo', Customer."No.");
                AppendField(FieldsEmt, '', Customer.FieldName("Credit Limit (LCY)"), DecimalToText(Customer."Credit Limit (LCY)"));
                AppendField(FieldsEmt, '', Customer.FieldName("Payment Terms Code"), Customer."Payment Terms Code");
                DOMOutRootEmt.Add(FieldsEmt);
            end;
            Database::Contact: begin
                MarketingSetup.Get();
                MarketingSetup.TestField("Bus. Rel. Code for Customers");
                // Customer from given node attribute has higher priority than inserted Customer
                if not CustomerCompany.Get(CustomerNo)then begin
                    if Customer."No." <> '' then CustomerCompany:=Customer
                    else
                        Error(CustomerNoForContactNotFoundErr, CustomerNo);
                end;
                ContactBusinessRelation.SetRange("Business Relation Code", MarketingSetup."Bus. Rel. Code for Customers");
                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                ContactBusinessRelation.SetRange("No.", CustomerCompany."No.");
                if not ContactBusinessRelation.FindFirst()then Error(ContactForCustomerNoNotFoundErr, CustomerCompany."No.");
                if not ContactCompany.Get(ContactBusinessRelation."Contact No.")then Error(ContactForCustomerNoNotFoundErr, CustomerCompany."No.");
                // Insert fields generically
                InsertDataFields(RecRef);
                // Check inserted fields
                FldRef:=RecRef.Field(Contact.FieldNo("LOGWS Webshop Login"));
                FldRef.TestField();
                FldRef:=RecRef.Field(Contact.FieldNo("LOGWS Password Key"));
                FldRef.TestField();
                RecRef.SetTable(Contact);
                Contact.Type:=Contact.Type::Person;
                Contact."Company No.":=ContactCompany."No.";
                Contact."Company Name":=ContactCompany.Name;
                Contact.Modify(true);
                // Return Result
                FieldsEmt:=XmlElement.Create('Fields', CurrNamespace);
                AppendAttribute(FieldsEmt, 'CustomerNo', CustomerCompany."No.");
                AppendField(FieldsEmt, '', Contact.TableCaption() + ' ' + Contact.FieldName("No."), Contact."No.");
                AppendField(FieldsEmt, '', CustomerCompany.FieldName("Credit Limit (LCY)"), DecimalToText(CustomerCompany."Credit Limit (LCY)"));
                AppendField(FieldsEmt, '', CustomerCompany.FieldName("Payment Terms Code"), CustomerCompany."Payment Terms Code");
                DOMOutRootEmt.Add(FieldsEmt);
            end;
            end;
        end;
    end;
    local procedure SalesPricing()var FieldsList: XmlNodeList;
    FieldsNode: XmlNode;
    begin
        ClearGlobalVars();
        DOMIn.SelectNodes('//def:Fields', NSMgr, FieldsList);
        foreach FieldsNode in FieldsList do SalesPricingItem(FieldsNode);
    end;
    local procedure SalesPricingItem(FieldsNode: XmlNode)var CurrencyExchangeRate: Record "Currency Exchange Rate";
    Customer: Record Customer;
    Item: Record Item;
    Job: Record Job;
    TempSalesHeader: Record "Sales Header" temporary;
    TempSalesLine: Record "Sales Line" temporary;
    TempSalesLineBulkDisc: Record "Sales Line" temporary;
    VATPostingSetup: Record "VAT Posting Setup";
    UoMMgt: Codeunit "Unit of Measure Management";
    ItemPriceEmt: XmlElement;
    SalesPriceEmt: XmlElement;
    SalesPricesEmt: XmlElement;
    QtyDisc: Boolean;
    UoM: Code[10];
    VariantCode: Code[10];
    Amt: Decimal;
    Qty: Decimal;
    GuidValue: Integer;
    ChildNode: XmlNode;
    begin
        if GlobalCustomerNo <> '' then Customer."No.":=GlobalCustomerNo;
        if GlobalJobNo <> '' then Job."No.":=GlobalJobNo;
        if GlobalQty <> 0 then Qty:=GlobalQty;
        if GlobalAmt <> 0 then Amt:=GlobalAmt;
        if GlobalQtyDisc then QtyDisc:=GlobalQtyDisc;
        if GlobalUoM <> '' then UoM:=GlobalUoM;
        if GlobalVariantCode <> '' then VariantCode:=GlobalVariantCode;
        foreach ChildNode in FieldsNode.AsXmlElement().GetChildElements()do begin
            case ChildNode.AsXmlElement().LocalName()of 'CustomerNo': Customer."No.":=CopyStr(ChildNode.AsXmlElement().InnerText(), 1, MaxStrLen(Customer."No."));
            'JobNo': Job."No.":=CopyStr(ChildNode.AsXmlElement().InnerText(), 1, MaxStrLen(Job."No."));
            'ItemNo': Item."No.":=CopyStr(ChildNode.AsXmlElement().InnerText(), 1, MaxStrLen(Item."No."));
            'GUID': Evaluate(GuidValue, ChildNode.AsXmlElement().InnerText());
            'Quantity': Evaluate(Qty, ChildNode.AsXmlElement().InnerText());
            'Amount': Evaluate(Amt, ChildNode.AsXmlElement().InnerText());
            'QtyDisc': if LowerCase(ChildNode.AsXmlElement().InnerText()) = 'true' then QtyDisc:=true;
            'UoM': Evaluate(UoM, ChildNode.AsXmlElement().InnerText());
            'Variant': Evaluate(VariantCode, ChildNode.AsXmlElement().InnerText());
            end;
        end;
        // Set Global Fields
        if FieldsNode.AsXmlElement().HasAttributes()then begin
            FieldsNode.AsXmlElement().Attributes().Get(1, CurrXmlAttr);
            if CurrXmlAttr.Value = 'Global' then begin
                GlobalCustomerNo:=Customer."No.";
                GlobalJobNo:=Job."No.";
                GlobalQty:=Qty;
                GlobalAmt:=Amt;
                GlobalQtyDisc:=QtyDisc;
                GlobalUoM:=UoM;
                GlobalVariantCode:=VariantCode;
                exit;
            end;
        end;
        ItemPriceEmt:=XmlElement.Create('ItemPrice', CurrNamespace);
        DOMOutRootEmt.Add(ItemPriceEmt);
        Item.Get(Item."No.");
        if Customer."No." <> '' then Customer.Get(Customer."No.");
        if Customer."Bill-to Customer No." <> '' then Customer.Get(Customer."Bill-to Customer No.");
        if UoM = '' then UoM:=Item."Sales Unit of Measure";
        if VariantCode <> '' then Item.SetRange("Variant Filter", VariantCode);
        TempSalesHeader."Currency Code":=Customer."Currency Code";
        TempSalesHeader."Currency Factor":=CurrencyExchangeRate.ExchangeRate(Today(), Customer."Currency Code");
        TempSalesHeader."Posting Date":=Today;
        TempSalesHeader."Order Date":=Today;
        TempSalesHeader."Prices Including VAT":=Customer."Prices Including VAT";
        TempSalesHeader."Allow Line Disc.":=Customer."Allow Line Disc.";
        TempSalesHeader."Bill-to Customer No.":=Customer."No.";
        TempSalesLine.Type:=TempSalesLine.Type::Item;
        TempSalesLine."No.":=Item."No.";
        TempSalesLine."Bill-to Customer No.":=Customer."No.";
        TempSalesLine."Customer Price Group":=Customer."Customer Price Group";
        TempSalesLine.Quantity:=Qty;
        TempSalesLine."Unit of Measure Code":=UoM;
        TempSalesLine."Qty. per Unit of Measure":=UoMMgt.GetQtyPerUnitOfMeasure(Item, UoM);
        TempSalesLine."Variant Code":=VariantCode;
        TempSalesLine."VAT Bus. Posting Group":=Customer."VAT Bus. Posting Group";
        TempSalesLine."Allow Line Disc.":=Customer."Allow Line Disc.";
        TempSalesLine."Customer Disc. Group":=Customer."Customer Disc. Group";
        TempSalesLine."Currency Code":=Customer."Currency Code";
        VATPostingSetup.Get(TempSalesLine."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
        TempSalesLine."VAT %":=VATPostingSetup."VAT %";
        WSFunctions.GetWSSalesPrices(TempSalesHeader, TempSalesLine, TempSalesLineBulkDisc, QtyDisc);
        AppendField(ItemPriceEmt, 'GUID', '', Format(GuidValue));
        AppendField(ItemPriceEmt, 'Quantity', '', DecimalToText(Qty));
        AppendField(ItemPriceEmt, 'Number', '', Item."No.");
        AppendField(ItemPriceEmt, 'Description', '', Item.Description);
        AppendField(ItemPriceEmt, 'UnitPrice', '', DecimalToText(Round(TempSalesLine."Unit Price", 0.01)));
        AppendField(ItemPriceEmt, 'LineDiscount', '', DecimalToText(TempSalesLine."Line Discount %"));
        AppendField(ItemPriceEmt, 'LineDiscountAmount', '', DecimalToText(Round(TempSalesLine."Line Discount Amount", 0.01)));
        AppendField(ItemPriceEmt, 'LineDiscountAmountPerQty', '', DecimalToText(Round(TempSalesLine."Amount Including VAT", 0.01)));
        AppendField(ItemPriceEmt, 'LineAmount', '', DecimalToText(Round(TempSalesLine."Line Amount", 0.01)));
        AppendField(ItemPriceEmt, 'LineAmountPerQty', '', DecimalToText(Round(TempSalesLine.Amount, 0.01)));
        AppendField(ItemPriceEmt, 'QtyPrice', '', DecimalToText(Round(TempSalesLine."Unit Volume", 0.01)));
        AppendField(ItemPriceEmt, 'QtyDiscount', '', DecimalToText(Round(TempSalesLine."Gross Weight", 0.01)));
        AppendField(ItemPriceEmt, 'QtyDiscountAmount', '', DecimalToText(Round(TempSalesLine."Net Weight", 0.01)));
        AppendField(ItemPriceEmt, 'VAT', '', DecimalToText(TempSalesLine."VAT %"));
        AppendField(ItemPriceEmt, 'Availability', '', DecimalToText(Round(WSFunctions.CalcItemAvailabilityValue(Item), 0.01)));
        AppendField(ItemPriceEmt, 'Signal', '', DecimalToText(WSFunctions.CalcItemSignalValue(Item)));
        AppendField(ItemPriceEmt, 'UoM', '', UoM);
        AppendField(ItemPriceEmt, 'Variant', '', VariantCode);
        if not QtyDisc then exit;
        TempSalesLineBulkDisc.Reset();
        if TempSalesLineBulkDisc.FindSet()then begin
            SalesPricesEmt:=XmlElement.Create('SalesPrices', CurrNamespace);
            ItemPriceEmt.Add(SalesPricesEmt);
            repeat SalesPriceEmt:=XmlElement.Create('SalesPrice', CurrNamespace);
                SalesPricesEmt.Add(SalesPriceEmt);
                AppendField(SalesPriceEmt, 'Quantity', '', DecimalToText(TempSalesLineBulkDisc.Quantity));
                AppendField(SalesPriceEmt, 'UnitPrice', '', DecimalToText(Round(TempSalesLineBulkDisc."Unit Price", 0.01)));
                AppendField(SalesPriceEmt, 'LineDiscount', '', DecimalToText(TempSalesLineBulkDisc."Line Discount %"));
                AppendField(SalesPriceEmt, 'LineDiscountAmount', '', DecimalToText(Round(TempSalesLineBulkDisc."Line Discount Amount", 0.01)));
                AppendField(SalesPriceEmt, 'LineDiscountAmountPerQty', '', DecimalToText(Round(TempSalesLineBulkDisc."Amount Including VAT", 0.01)));
                AppendField(SalesPriceEmt, 'LineAmount', '', DecimalToText(Round(TempSalesLineBulkDisc."Line Amount", 0.01)));
                AppendField(SalesPriceEmt, 'LineAmountPerQty', '', DecimalToText(Round(TempSalesLineBulkDisc.Amount, 0.01)));
                AppendField(SalesPriceEmt, 'QtyPrice', '', DecimalToText(Round(TempSalesLine."Unit Volume", 0.01)));
                AppendField(SalesPriceEmt, 'QtyDiscount', '', DecimalToText(Round(TempSalesLineBulkDisc."Gross Weight", 0.01)));
                AppendField(SalesPriceEmt, 'QtyDiscountAmount', '', DecimalToText(Round(TempSalesLineBulkDisc."Net Weight", 0.01)));
                AppendField(SalesPriceEmt, 'VAT', '', DecimalToText(TempSalesLineBulkDisc."VAT %"));
            until TempSalesLineBulkDisc.Next() = 0;
        end;
    end;
    local procedure SetNamespace(NamespaceText: Text)begin
        NamespaceText:=NamespaceUrlLbl + NamespaceText;
        NamespaceTable.Add(NamespaceText);
    end;
    local procedure SetRecFilters(var RecRef: RecordRef)var FilterTokens: Codeunit "Filter Tokens";
    FldRef: FieldRef;
    CurrFilterFieldNo: Integer;
    i: Integer;
    CurrFilterValue: Text;
    begin
        for i:=1 to FilterFieldNo.Count()do begin
            CurrFilterFieldNo:=FilterFieldNo.Get(i);
            if CurrFilterFieldNo > 0 then begin
                FldRef:=RecRef.Field(CurrFilterFieldNo);
                CurrFilterValue:=FilterValue.Get(i);
                case FldRef.Type()of FieldType::Date: begin
                    TextToDateTimeFilter(0, CurrFilterValue);
                    FilterTokens.MakeDateFilter(CurrFilterValue);
                end;
                FieldType::Time: begin
                    TextToDateTimeFilter(1, CurrFilterValue);
                    FilterTokens.MakeTimeFilter(CurrFilterValue);
                end;
                FieldType::DateTime: begin
                    FilterTokens.MakeDateTimeFilter(CurrFilterValue);
                end;
                end;
                FldRef.SetFilter(CurrFilterValue);
            end;
        end;
    end;
    local procedure TextBoolean(TextIn: Text)BooleanOut: Boolean begin
        if TextIn = '' then TextIn:='0';
        if LowerCase(TextIn) = 'true' then TextIn:='1';
        if LowerCase(TextIn) = 'false' then TextIn:='0';
        Evaluate(BooleanOut, TextIn);
    end;
    local procedure TimeToText(ValueParam: Time): Text begin
        exit(Format(ValueParam, 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'));
    end;
    local procedure TryProcessRequest()var WSManualEvents: Codeunit "LOGWS Manual Events";
    CurrXmlElement: XmlElement;
    CurrXmlNodeList: XmlNodeList;
    XmlDeclarationVar: XmlDeclaration;
    XmlRootNode: XmlNode;
    begin
        InitNamespaces();
        InitSpecialFieldList();
        // Get and validate Root Namespace
        DOMIn.GetRoot(CurrXmlElement);
        CurrNamespace:=CurrXmlElement.NamespaceUri();
        ValidateNamespace(CurrNamespace);
        NSMgr.NameTable(DOMIn.NameTable());
        NSMgr.AddNamespace('def', CurrNamespace);
        DOMIn.SelectNodes('//def:Parameters', NSMgr, CurrXmlNodeList);
        CurrXmlNodeList.Get(1, XmlRootNode);
        CurrXmlAttributes:=XmlRootNode.AsXmlElement().Attributes();
        foreach CurrXmlAttr in CurrXmlAttributes do begin
            case CurrXmlAttr.Name of 'Method': WebMethod:=CurrXmlAttr.Value;
            'WebLoginType': WebLoginType:=CurrXmlAttr.Value;
            'WebShopVersion': WebshopVersion:=WSFunctions.GetWebshopVersionEnum(CurrXmlAttr.Value);
            end;
        end;
        if not WSFunctions.CheckWebshopVersion(WebshopVersion)then Error(WebshopVersionMatchErr, Format(WebshopVersion));
        Clear(DOMOut);
        DOMOut:=XmlDocument.Create();
        XmlDeclarationVar:=XmlDeclaration.Create('1.0', 'UTF-8', 'no');
        DOMOut.SetDeclaration(XmlDeclarationVar);
        DOMOutRootEmt:=XmlElement.Create('Response', CurrNamespace);
        DOMOut.Add(DOMOutRootEmt);
        // Bind manual events
        BindSubscription(WSManualEvents);
        WSManualEvents.SetManualEventMode(WSManualEventMode::ProcessWsRequestExecutionMode);
        case WebMethod of 'ReadData': ProcessDataTable('Read');
        'ModifyData': ProcessDataTable('Modify');
        'InsertData': ProcessDataTable('Insert');
        'DeleteData': ProcessDataTable('Delete');
        'Pricing': SalesPricing();
        'NewSalesOrder': NewSalesDocument();
        'ReadWebshopGrouping': ReadWSGrouping();
        'CustomerLogin': LoginWSUser();
        'RegisterUser': RegisterWSUser();
        // 'ChangePassword':
        //     ChangeWSPassword();
        'PrintReport': PrintReport();
        else
            Error(UnknownWebMethodErr, WebMethod);
        end;
    end;
    local procedure UpdateRecCounter()begin
        NoOfRecords+=1;
    end;
    local procedure ValidateNamespace(NamespaceTxt: Text)begin
        // Check specified namespace
        if NamespaceTxt = '' then exit;
        if not NamespaceTable.Contains(NamespaceTxt)then Error(InvalidNamespaceErr, NamespaceTxt);
    end;
}
