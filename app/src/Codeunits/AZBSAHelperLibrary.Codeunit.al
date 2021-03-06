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

    procedure PageRangesResultToDictionairy(Document: XmlDocument; var PageRanges: Dictionary of [Integer, Integer])
    var
        NodeList: XmlNodeList;
        Node: XmlNode;
        StartRange: Integer;
        EndRange: Integer;
    begin
        NodeList := CreatePageRangesNodeListFromResponse(Document);

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do begin
            Evaluate(StartRange, GetValueFromNode(Node, 'Start'));
            Evaluate(EndRange, GetValueFromNode(Node, 'End'));
            PageRanges.Add(StartRange, EndRange);
        end;
    end;

    procedure CreatePageRangesNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/PageRange'));
    end;

    procedure BlockListResultToDictionary(Document: XmlDocument; var CommitedBlocks: Dictionary of [Text, Integer]; var UncommitedBlocks: Dictionary of [Text, Integer])
    var
        NodeList: XmlNodeList;
        Node: XmlNode;
        NameValue: Text;
        SizeValue: Integer;
    begin
        NodeList := CreateBlockListCommitedNodeListFromResponse(Document);

        if NodeList.Count > 0 then
            foreach Node in NodeList do begin
                Evaluate(NameValue, GetValueFromNode(Node, 'Name'));
                Evaluate(SizeValue, GetValueFromNode(Node, 'Size'));
                CommitedBlocks.Add(NameValue, SizeValue);
            end;

        NodeList := CreateBlockListUncommitedNodeListFromResponse(Document);

        if NodeList.Count > 0 then
            foreach Node in NodeList do begin
                Evaluate(NameValue, GetValueFromNode(Node, 'Name'));
                Evaluate(SizeValue, GetValueFromNode(Node, 'Size'));
                UncommitedBlocks.Add(NameValue, SizeValue);
            end;
    end;

    procedure CreateBlockListCommitedNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/CommittedBlocks/Block'));
    end;

    procedure CreateBlockListUncommitedNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/UncommittedBlocks/Block'));
    end;

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
            ContainerContents.GetRecord(ContainerContentReturn);
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

    local procedure CreateXPathNodeListFromResponse(Document: XmlDocument; XPath: Text): XmlNodeList
    var
        RootNode: XmlElement;
        NodeList: XmlNodeList;
    begin
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
            Error(''); // TODO: Add error message
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
            Error(''); // TODO: Add error message
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

    // #region Version Comparision
    procedure ApiVersionGreaterThan(CurrApiVersion: Enum "AZBSA API Version"; CompareApiVersion: Enum "AZBSA API Version"): Boolean
    var
        YearCurr: Integer;
        MonthCurr: Integer;
        DayCurr: Integer;
        YearCompare: Integer;
        MonthCompare: Integer;
        DayCompare: Integer;
    begin
        GetApiVersionParts(CurrApiVersion, YearCurr, MonthCurr, DayCurr);
        GetApiVersionParts(CompareApiVersion, YearCompare, MonthCompare, DayCompare);


        if YearCurr > YearCompare then
            exit(true);
        if YearCurr < YearCompare then
            exit(false);
        // Being here means YearCurr = YearCompare
        if MonthCurr > MonthCompare then
            exit(true);
        if MonthCurr < MonthCompare then
            exit(false);
        // Being here means MonthCurr = MonthCompare
        if DayCurr > DayCompare then
            exit(true);
        if DayCurr < DayCompare then
            exit(false);
    end;

    procedure ApiVersionLessThan(CurrApiVersion: Enum "AZBSA API Version"; CompareApiVersion: Enum "AZBSA API Version"): Boolean
    var
        YearCurr: Integer;
        MonthCurr: Integer;
        DayCurr: Integer;
        YearCompare: Integer;
        MonthCompare: Integer;
        DayCompare: Integer;
    begin
        GetApiVersionParts(CurrApiVersion, YearCurr, MonthCurr, DayCurr);
        GetApiVersionParts(CompareApiVersion, YearCompare, MonthCompare, DayCompare);


        if YearCurr > YearCompare then
            exit(false);
        if YearCurr < YearCompare then
            exit(true);
        // Being here means YearCurr = YearCompare
        if MonthCurr > MonthCompare then
            exit(false);
        if MonthCurr < MonthCompare then
            exit(true);
        // Being here means MonthCurr = MonthCompare
        if DayCurr > DayCompare then
            exit(false);
        if DayCurr < DayCompare then
            exit(true);
    end;

    local procedure GetApiVersionParts(ApiVersion: Enum "AZBSA API Version"; var Year: Integer; var Month: Integer; var Day: Integer)
    var
        VersionAsString: Text;
    begin
        // 2019-12-12
        VersionAsString := Format(ApiVersion);
        Evaluate(Year, VersionAsString.Substring(1, 4));
        Evaluate(Month, VersionAsString.Substring(6, 2));
        Evaluate(Day, VersionAsString.Substring(9, 2));
    end;
    // #endregion Version Comparision 
}