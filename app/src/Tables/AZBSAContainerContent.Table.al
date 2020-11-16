// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 89002 "AZBSA Container Content"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    LookupPageId = "AZBSA Container Content";
    DrillDownPageId = "AZBSA Container Content";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Parent Directory"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(3; Level; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Full Name"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Creation-Time"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Last-Modified"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Content-Length"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Content-Type"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(15; BlobType; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(100; "XML Value"; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(110; URI; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(120; "Blob Storage Container Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(130; "Container Name"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    var
        RequestObject: Codeunit "AZBSA Request Object";
        StorageAccountName: Text;
        ContainerName: Text;

    procedure SetBaseInfos(NewRequestObject: Codeunit "AZBSA Request Object")
    begin
        StorageAccountName := RequestObject.GetStorageAccountName();
        ContainerName := RequestObject.GetContainerName();
        RequestObject := NewRequestObject;
    end;

    procedure SetBaseInfos(NewStorageAccountName: Text; NewContainerName: Text; NewRequestObject: Codeunit "AZBSA Request Object")
    begin
        StorageAccountName := NewStorageAccountName;
        ContainerName := NewContainerName;
        RequestObject := NewRequestObject;
    end;

    procedure AddNewEntryFromNode(var Node: XmlNode; XPathName: Text)
    begin
        AddNewEntryFromNode('', '', Node, XPathName);
    end;

    procedure AddNewEntryFromNode(StorageContainerCode: Code[10]; ContainerName: Text; var Node: XmlNode; XPathName: Text)
    var
        HelperLibrary: Codeunit "AZBSA Helper Library";
        NameFromXml: Text;
        OuterXml: Text;
        ChildNodes: XmlNodeList;
        PropertiesNode: XmlNode;
    begin
        NameFromXml := HelperLibrary.GetValueFromNode(Node, XPathName);
        Node.WriteTo(OuterXml);
        Node.SelectSingleNode('.//Properties', PropertiesNode);
        ChildNodes := PropertiesNode.AsXmlElement().GetChildNodes();
        if ChildNodes.Count = 0 then
            Rec.AddNewEntry(StorageContainerCode, ContainerName, NameFromXml, OuterXml)
        else
            Rec.AddNewEntry(StorageContainerCode, ContainerName, NameFromXml, OuterXml, ChildNodes);
    end;

    procedure AddNewEntry(StorageContainerCode: Code[10]; ContainerName: Text; NameFromXml: Text; OuterXml: Text)
    var
        ChildNodes: XmlNodeList;
    begin
        AddNewEntry(StorageContainerCode, ContainerName, NameFromXml, OuterXml, ChildNodes);
    end;

    procedure AddNewEntry(StorageContainerCode: Code[10]; ContainerName: Text; NameFromXml: Text; OuterXml: Text; ChildNodes: XmlNodeList)
    var
        NextEntryNo: Integer;
        Outstr: OutStream;
    begin
        if NameFromXml.Contains('/') then
            AddParentEntry(NameFromXml);

        NextEntryNo := GetNextEntryNo();

        Rec.Init();
        Rec."Entry No." := NextEntryNo;
        Rec."Parent Directory" := GetDirectParentName(NameFromXml);
        Rec.Level := GetLevel(NameFromXml);
        Rec."Full Name" := CopyStr(NameFromXml, 1, 250);
        Rec.Name := GetName(NameFromXml);
        SetPropertyFields(ChildNodes);
        Rec."XML Value".CreateOutStream(Outstr);
        Outstr.Write(OuterXml);
        rec."Blob Storage Container Code" := StorageContainerCode;
        rec."Container Name" := ContainerName;
        Rec.Insert(true);
    end;

    local procedure AddParentEntry(NameFromXml: Text)
    var
        NextEntryNo: Integer;
    begin
        NextEntryNo := GetNextEntryNo();

        Rec.Init();
        Rec."Entry No." := NextEntryNo;
        Rec.Level := GetLevel(NameFromXml) - 1;
        Rec.Name := GetDirectParentName(NameFromXml);
        Rec."Parent Directory" := GetDirectParentName(NameFromXml);
        Rec."Content-Type" := 'Directory';
        Rec.Insert(true);
    end;

    local procedure SetPropertyFields(ChildNodes: XmlNodeList)
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        HelperLibrary: Codeunit "AZBSA Helper Library";
        RecRef: RecordRef;
        FldRef: FieldRef;
        ChildNode: XmlNode;
        PropertyName: Text;
        PropertyValue: Text;
        FldNo: Integer;
    begin
        foreach ChildNode in ChildNodes do begin
            PropertyName := ChildNode.AsXmlElement().Name;
            PropertyValue := ChildNode.AsXmlElement().InnerText;
            if PropertyValue <> '' then begin
                RecRef.GetTable(Rec);
                if HelperLibrary.GetFieldByName(Database::"AZBSA Container Content", PropertyName, FldNo) then begin
                    FldRef := RecRef.Field(FldNo);
                    case FldRef.Type of
                        FldRef.Type::DateTime:
                            FldRef.Value := FormatHelper.ConvertToDateTime(PropertyValue);
                        FldRef.Type::Integer:
                            FldRef.Value := FormatHelper.ConvertToInteger(PropertyValue);
                        else
                            FldRef.Value := PropertyValue;
                    end;
                end;
            end;
            RecRef.SetTable(Rec);
        end;
    end;

    local procedure GetNextEntryNo(): Integer
    begin
        if Rec.FindLast() then
            exit(Rec."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure GetLevel(Name: Text): Integer
    var
        StringSplit: List of [Text];
    begin
        if not Name.Contains('/') then
            exit(0);
        StringSplit := Name.Split('/');
        exit(StringSplit.Count() - 1);
    end;

    local procedure GetName(Name: Text): Text[250]
    var
        StringSplit: List of [Text];
    begin
        if not Name.Contains('/') then
            exit(CopyStr(Name, 1, 250));
        StringSplit := Name.Split('/');
        exit(CopyStr(StringSplit.Get(StringSplit.Count()), 1, 250));
    end;

    local procedure GetDirectParentName(Name: Text): Text[250]
    var
        StringSplit: List of [Text];
        Parent: Text;
    begin
        if not Name.Contains('/') then
            exit('root');
        StringSplit := Name.Split('/');
        Parent := StringSplit.Get(1);
        if StringSplit.Count > 2 then
            Parent := StringSplit.Get(StringSplit.Count() - 1);
        exit(CopyStr(Parent, 1, 250));
    end;

    procedure DownloadFile()
    var
        BlobStorageConnection: Record "AZBSA Blob Storage Connection";
    begin
        BlobStorageConnection.get(Rec."Blob Storage Container Code");
        BlobStorageConnection.DownloadFileNoUI("Container Name", "Name");
    end;
}