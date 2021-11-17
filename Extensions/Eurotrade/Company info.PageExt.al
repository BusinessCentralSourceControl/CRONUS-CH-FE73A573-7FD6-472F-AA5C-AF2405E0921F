pageextension 50006 "Company info" extends "Company Information"
{
    actions
    {
        addlast(Processing)
        {
            action(TestActn)
            {
                ApplicationArea = All;
                Caption = 'Test';

                trigger OnAction()var WSCatmgt: Codeunit "LOGWS Category Mgt.";
                item: Record Item;
                test: Codeunit Test;
                FileMgt: Codeunit "File Management";
                LanguageMgt: Codeunit Language;
                TempBlob: Codeunit "Temp Blob";
                WSProcessHandler: Codeunit "LOGWS Process Handler";
                XMLDocIn: XmlDocument;
                XMLDocOut: XmlDocument;
                InStr: InStream;
                OStr: OutStream;
                OldGlobalLanguage: Integer;
                FileFilterXmlTxt: Text;
                FileName: Text;
                test2: Codeunit test2;
                begin
                    //  WSCatmgt.RecalcWSAssortmentItems();
                    //item.ModifyAll("LOGWS Assortment Item", false, false);
                    // item.FindSet(true, false);
                    // repeat
                    //     item."LOGWS Assortment Item" := false;
                    //     item.Modify(false);
                    // until item.Next() = 0;
                    // test.RecalcWSAssortmentItems();
                    // item.FindFirst();
                    // item."LOGWS Assortment Item" := true;
                    // item.Modify();
                    FileFilterXmlTxt:=FileMgt.GetToFilterText('', '.xml');
                    FileName:=FileMgt.BLOBImportWithFilter(TempBlob, 'Import WSRequest XML', '', FileFilterXmlTxt, FileFilterXmlTxt);
                    if FileName = '' then exit;
                    TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
                    XMLDocIn:=XmlDocument.Create();
                    XmlDocument.ReadFrom(InStr, XMLDocIn);
                    OldGlobalLanguage:=GlobalLanguage();
                    GlobalLanguage:=LanguageMgt.GetDefaultApplicationLanguageId();
                    test2.ProcessWsRequest(XMLDocIn, XMLDocOut);
                    GlobalLanguage:=OldGlobalLanguage;
                    Clear(TempBlob);
                    TempBlob.CreateOutStream(OStr);
                    XMLDocOut.WriteTo(OStr);
                    FileName:=FileMgt.GetFileNameWithoutExtension(FileName);
                    FileName+=' WSResponse.xml';
                    FileMgt.BLOBExportWithEncoding(TempBlob, FileName, true, TextEncoding::UTF8);
                end;
            }
        }
    }
    var myInt: Integer;
}
