codeunit 50002 "LOGWS Request Handler ET"
{
    procedure ProcessMessage(_IN: Text;
    var _OUT: Text)var WSProcessHandler: Codeunit "LOGWS Process Handler";
    test2: Codeunit test2;
    DOMIn: XmlDocument;
    DOMOut: XmlDocument;
    begin
        GetXmlFromBase64String(_IN, DOMIn);
        DOMOut:=XmlDocument.Create();
        test2.ProcessWsRequest(DOMIn, DOMOut);
        GetBase64StringFromXml(DOMOut, _OUT);
    end;
    local procedure GetBase64StringFromXml(XMLDoc: XmlDocument;
    var TextOut: Text)var Base64Convert: Codeunit "Base64 Convert";
    begin
        Clear(TextOut);
        if not XMLDoc.WriteTo(TextOut)then;
        TextOut:=Base64Convert.ToBase64(TextOut);
    end;
    local procedure GetXmlFromBase64String(TextIn: Text;
    var XMLDoc: XmlDocument)var Base64Convert: Codeunit "Base64 Convert";
    begin
        Clear(XMLDoc);
        XMLDoc:=XmlDocument.Create();
        XmlDocument.ReadFrom(Base64Convert.FromBase64(TextIn), XMLDoc);
    end;
}
