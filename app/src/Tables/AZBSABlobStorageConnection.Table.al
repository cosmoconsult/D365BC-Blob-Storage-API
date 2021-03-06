// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 89000 "AZBSA Blob Storage Connection"
{
    Caption = 'Blob Storage Connection';
    DataClassification = CustomerContent;
    LookupPageId = "AZBSA Blob Stor. Connections";
    DrillDownPageId = "AZBSA Blob Stor. Connections";

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }

        field(2; Description; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "Storage Account Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Storage Account Name';
        }

        field(4; "Authorization Type"; Enum "AZBSA Authorization Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Authorization Type';
        }
        field(5; Secret; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Secret';
            ExtendedDatatype = Masked;

            trigger OnValidate()
            begin
                if Rec."Authorization Type" = Rec."Authorization Type"::SasToken then
                    if Rec."Secret".StartsWith('?') then
                        Rec."Secret" := CopyStr(Rec."Secret", 2, 250);
            end;
        }

        field(6; "API Version"; Enum "AZBSA API Version")
        {
            DataClassification = CustomerContent;
            Caption = 'API Version';
        }

        field(7; "Tenant ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Tenant ID';
        }

        field(8; "Client ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Client ID';
        }

        field(10; "Source Container Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Container Name';
        }
        field(11; "Target Container Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Target Container Name';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    local procedure InitializeRequestObject(var RequestObject: Codeunit "AZBSA Request Object"; NewStorageAccountName: Text)
    begin
        InitializeRequestObject(RequestObject, NewStorageAccountName, '', '');
    end;

    local procedure InitializeRequestObject(var RequestObject: Codeunit "AZBSA Request Object"; NewStorageAccountName: Text; NewContainerName: Text)
    begin
        InitializeRequestObject(RequestObject, NewStorageAccountName, NewContainerName, '');
    end;

    local procedure InitializeRequestObject(var RequestObject: Codeunit "AZBSA Request Object"; NewStorageAccountName: Text; NewContainerName: Text; NewBlobName: Text)
    begin
        if Rec."Authorization Type" <> Rec."Authorization Type"::"AAD (Client Credentials)" then
            RequestObject.InitializeAuthorization(Rec."Authorization Type", Rec.Secret)
        else
            RequestObject.InitializeAuthorization(Rec."Authorization Type", Rec.Secret, Rec."Client ID", Rec."Tenant ID");
        RequestObject.InitializeRequest(NewStorageAccountName, NewContainerName, NewBlobName);
        RequestObject.SetApiVersion(Rec."API Version");
    end;

    procedure TestSetup(ForDestination: Boolean)
    begin
        Rec.TestField("Storage Account Name");
        Rec.TestField("Secret");
        Rec.TestField("Storage Account Name");
        if ForDestination then
            Rec.TestField("Target Container Name")
        else
            Rec.TestField("Source Container Name");
    end;

    procedure ListContainers()
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name");
        API.ListContainers(RequestObject);
    end;

    procedure GetUserDelegationKey()
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name");
        Message(API.GetUserDelegationKey(RequestObject, CreateDateTime(CalcDate('<+5D>', Today), Time())));
    end;

    procedure ListContentSource()
    begin
        ListContentContainer(Rec."Source Container Name");
    end;

    procedure ListContentTarget()
    begin
        ListContentContainer(Rec."Target Container Name");
    end;

    local procedure ListContentContainer(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.ListBlobs(RequestObject);
    end;

    procedure FindBlobsByTags()
    var
        RequestObject: Codeunit "AZBSA Request Object";
        SearchTags: Dictionary of [Text, Text];
    begin
        // Only as an example
        InitializeRequestObject(RequestObject, Rec."Storage Account Name");
        RequestObject.SetApiVersion(Rec."API Version");
        SearchTags.Add('DummyTagName', '= DummyTagValue');
        FindBlobsByTags(RequestObject, SearchTags);
    end;

    procedure FindBlobsByTags(var RequestObject: Codeunit "AZBSA Request Object"; SearchTags: Dictionary of [Text, Text])
    var
        API: Codeunit "AZBSA Blob Storage API";
        Document: XmlDocument;
    begin
        Document := API.FindBlobsByTags(RequestObject, SearchTags)
    end;

    procedure CreateRandomPageBlobInContainer(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        FormatHelper: Codeunit "AZBSA Format Helper";
        BlobName: Text;
    begin
        BlobName := FormatHelper.CreateRandomBlobname(0);
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName, BlobName);
        API.PutBlobPageBlobTextPlain(RequestObject, 0);
    end;

    procedure CreateRandomAppendBlobInContainer(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        FormatHelper: Codeunit "AZBSA Format Helper";
        BlobName: Text;
    begin
        BlobName := FormatHelper.CreateRandomBlobname(0);
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName, BlobName);
        API.PutBlobAppendBlobTextPlain(RequestObject);
    end;

    procedure CreateSourceContainer()
    begin
        CreateContainer(Rec."Source Container Name");
    end;

    procedure CreateTargetContainer()
    begin
        CreateContainer(Rec."Target Container Name");
    end;

    local procedure CreateContainer(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.CreateContainer(RequestObject);
    end;

    procedure DeleteSourceContainer()
    begin
        DeleteContainer(Rec."Source Container Name");
    end;

    procedure DeleteTargetContainer()
    begin
        DeleteContainer(Rec."Target Container Name");
    end;

    local procedure DeleteContainer(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.DeleteContainer(RequestObject);
    end;

    procedure UploadFileUI(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.UploadBlobIntoContainerUI(RequestObject);
    end;

    procedure DownloadFileUI(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.DownloadBlobAsFileWithSelect(RequestObject);
    end;

    procedure DownloadFile(ContainerName: Text; BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName, BlobName);
        API.DownloadBlobAsFile(RequestObject);
    end;

    procedure DeleteBlobFromSourceContainerUI()
    begin
        DeleteBlobFromContainerUI(Rec."Source Container Name");
    end;

    procedure DeleteBlobFromTargetContainerUI()
    begin
        DeleteBlobFromContainerUI(Rec."Target Container Name");
    end;

    local procedure DeleteBlobFromContainerUI(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.DeleteBlobFromContainerUI(RequestObject);
    end;

    procedure ContainerLeaseAcquireSource()
    begin
        ContainerLeaseAcquire(Rec."Source Container Name");
    end;

    local procedure ContainerLeaseAcquire(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.ContainerLeaseAcquire(RequestObject, 15);
        GlobalLeaseId := RequestObject.GetHeaderValueFromResponseHeaders('x-ms-lease-id');
        Message('Initiated 15-second lease. Saved LeaseId to Global variable');
    end;

    procedure ContainerLeaseReleaseSource(LeaseID: Guid)
    begin
        if IsNullGuid(LeaseID) then
            ContainerLeaseRelease(Rec."Source Container Name", GlobalLeaseId)
        else
            ContainerLeaseRelease(Rec."Source Container Name", LeaseID);
    end;

    local procedure ContainerLeaseRelease(ContainerName: Text; LeaseID: Guid)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        if IsNullGuid(LeaseID) then
            Error('You need to call "Acquire Lease" first (global variable "LeaseId" is not set)');
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.ContainerLeaseRelease(RequestObject, LeaseID);
        Clear(GlobalLeaseId);
    end;

    procedure ContainerLeaseRenewSource(LeaseID: Guid)
    begin
        if IsNullGuid(LeaseID) then
            ContainerLeaseRenew(Rec."Source Container Name", GlobalLeaseId)
        else
            ContainerLeaseRenew(Rec."Source Container Name", LeaseID);
    end;

    local procedure ContainerLeaseRenew(ContainerName: Text; LeaseID: Guid)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        if IsNullGuid(LeaseID) then
            Error('You need to call "Acquire Lease" first (global variable "LeaseId" is not set)');
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.ContainerLeaseRenew(RequestObject, LeaseID);
    end;

    procedure GetBlobServiceProperties()
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name");
        Message(Format(API.GetBlobServiceProperties(RequestObject)));
    end;

    procedure SetBlobServiceProperties()
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        Document: XmlDocument;
    begin
        // Dummy-call; reads the current properties and calls the setter method with the result
        InitializeRequestObject(RequestObject, Rec."Storage Account Name");
        Document := API.GetBlobServiceProperties(RequestObject);
        Clear(RequestObject);
        InitializeRequestObject(RequestObject, Rec."Storage Account Name");
        API.SetBlobServiceProperties(RequestObject, Document);
    end;

    procedure GetContainerMetadataSource()
    begin
        GetContainerMetadata(Rec."Source Container Name");
    end;

    local procedure GetContainerMetadata(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.GetContainerMetadata(RequestObject);
    end;

    procedure SetContainerMetadataSource()
    begin
        SetContainerMetadata(Rec."Source Container Name");
    end;

    local procedure SetContainerMetadata(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        RequestObject.SetMetadataNameValueHeader('Dummy', 'DummyValue01');
        API.SetContainerMetadata(RequestObject);
    end;

    procedure GetContainerAclSource()
    begin
        GetContainerAcl(Rec."Source Container Name");
    end;

    local procedure GetContainerAcl(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.GetContainerACL(RequestObject);
    end;

    procedure SetContainerAclSource()
    begin
        SetContainerAcl(Rec."Source Container Name");
    end;

    local procedure SetContainerAcl(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        Document: XmlDocument;
    begin
        // Dummy call
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        Document := API.GetContainerACL(RequestObject);
        Clear(RequestObject);
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.SetContainerACL(RequestObject, Document);
    end;

    procedure GetContainerPropertiesSource()
    begin
        GetContainerProperties(Rec."Source Container Name");
    end;

    local procedure GetContainerProperties(ContainerName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", ContainerName);
        API.GetContainerProperties(RequestObject);
    end;

    procedure GetAccountInformation()
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", Rec."Source Container Name");
        API.GetAccountInformation(RequestObject);
    end;

    procedure GetBlobServiceStats()
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObject(RequestObject, Rec."Storage Account Name", Rec."Source Container Name");
        Message(Format(API.GetBlobServiceStats(RequestObject)));
    end;

    var
        GlobalLeaseId: Guid;
}