// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 89002 "AZBSA Helper Library"
{
    Access = Internal;

    trigger OnRun()
    begin

    end;

    var
        ResultCollectionEmptyMsg: Label 'The result set is empty';
    //PropertyPlaceholderLbl: Label '%1: %2', Comment = '%1 = Property Name, %2 = Property Value';

    // #region Container-specific Helper
    procedure ContainerNodeListTotempRecord(NodeList: XmlNodeList; var ContainerContent: Record "AZBSA Container Content")
    begin
        NodeListToTempRecord(NodeList, './/Name', ContainerContent);
    end;

    procedure ContainerNodeListTotempRecord(NodeList: XmlNodeList; var Container: Record "AZBSA Container")
    begin
        NodeListToTempRecord(NodeList, './/Name', Container);
    end;

    procedure CreateContainerNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Containers/Container'));
    end;
    // #endregion

    // #region Blob-specific Helper
    procedure CreateBlobNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Blobs/Blob'));
    end;

    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList)
    var
        ContainerContent: Record "AZBSA Container Content";
    begin
        BlobNodeListToTempRecord(NodeList, ContainerContent);
    end;

    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList; var ContainerContent: Record "AZBSA Container Content")
    begin
        NodeListToTempRecord(NodeList, './/Name', ContainerContent);
    end;
    // #endregion

    procedure ShowTempRecordLookup(var ContainerContent: Record "AZBSA Container Content")
    var
        ContainerContents: Page "AZBSA Container Contents";
    begin
        if ContainerContent.IsEmpty() then begin
            Message(ResultCollectionEmptyMsg);
            exit;
        end;
        ContainerContents.InitializeFromTempRec(ContainerContent);
        ContainerContents.Run();
    end;

    procedure ShowTempRecordLookup(var Container: Record "AZBSA Container")
    begin
        if Container.IsEmpty() then begin
            Message(ResultCollectionEmptyMsg);
            exit;
        end;
        Page.Run(0, Container);
    end;

    procedure LookupContainerContent(var ContainerContent: Record "AZBSA Container Content"): Text
    var
        ContainerContentReturn: Record "AZBSA Container Content";
        ContainerContents: Page "AZBSA Container Contents";
    begin
        if ContainerContent.IsEmpty() then
            exit('');

        ContainerContent.FindSet(false, false);
        repeat
            ContainerContents.AddEntry(ContainerContent);
        until ContainerContent.Next() = 0;
        ContainerContents.LookupMode(true);
        if ContainerContents.RunModal() = Action::LookupOK then begin
            ContainerContents.GetRecord(ContainerContent);
            exit(ContainerContentReturn."Full Name");
        end;
    end;

    // #region XML Helper
    local procedure GetXmlDocumentFromResponse(var Document: XmlDocument; ResponseAsText: Text)
    var
        ReadingAsXmlErr: Label 'Error reading Response as XML.';
    begin
        if not XmlDocument.ReadFrom(ResponseAsText, Document) then
            Error(ReadingAsXmlErr);
    end;

    local procedure CreateXPathNodeListFromResponse(ResponseAsText: Text; XPath: Text): XmlNodeList
    var
        Document: XmlDocument;
        RootNode: XmlElement;
        NodeList: XmlNodeList;
    begin
        GetXmlDocumentFromResponse(Document, ResponseAsText);
        Document.GetRoot(RootNode);
        RootNode.SelectNodes(XPath, NodeList);
        exit(NodeList);
    end;

    procedure GetValueFromNode(Node: XmlNode; XPath: Text): Text
    var
        Node2: XmlNode;
        Value: Text;
    begin
        Node.SelectSingleNode(XPath, Node2);
        Value := Node2.AsXmlElement().InnerText();
        exit(Value);
    end;

    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var ContainerContent: Record "AZBSA Container Content")
    var
        Node: XmlNode;
    begin
        if not ContainerContent.IsTemporary() then
            Error('');
        ContainerContent.DeleteAll();

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do
            ContainerContent.AddNewEntryFromNode(Node, XPathName);
    end;

    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var Container: Record "AZBSA Container")
    var
        Node: XmlNode;
    begin
        if not Container.IsTemporary() then
            Error('');
        Container.DeleteAll();

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do
            Container.AddNewEntryFromNode(Node, XPathName);
    end;
    // #endregion

    // #region Format Helper
    procedure GetFieldByName(TableNo: Integer; FldName: Text; var FldNo: Integer): Boolean
    var
        Fld: Record Field;
    begin
        Clear(FldNo);
        Fld.Reset();
        Fld.SetRange(TableNo, TableNo);
        Fld.SetRange(FieldName, FldName);
        if Fld.FindFirst() then
            FldNo := Fld."No.";
        exit(FldNo <> 0);
    end;
    // #endregion
}