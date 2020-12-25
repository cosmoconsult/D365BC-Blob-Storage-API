// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 89003 "AZBSA Container Contents"
{

    ApplicationArea = All;
    Caption = 'Container Contents';
    PageType = List;
    SourceTable = "AZBSA Container Content";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Name;
                field("Parent Directory"; Rec."Parent Directory")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'xxx';
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'xxx';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';

                    trigger OnAssistEdit()
                    begin
                        Rec.DownloadBlob(OriginalRequestObject);
                    end;
                }
                field("Creation-Time"; Rec."Creation-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                }
                field("Last-Modified"; Rec."Last-Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                }
                field("Content-Length"; Rec."Content-Length")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'xxx';
                }
                field("Content-Type"; Rec."Content-Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                }
                field(BlobType; Rec.BlobType)
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ShowEntryDetails)
            {
                Caption = 'Show Entry Details';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                var
                    InStr: InStream;
                    OuterXml: Text;
                begin
                    if not Rec."XML Value".HasValue then
                        exit;

                    Rec.CalcFields("XML Value");
                    Rec."XML Value".CreateInStream(InStr);
                    InStr.Read(OuterXml);
                    Message(OuterXml);
                end;
            }

            action(GetBlobPropertiesAction)
            {
                Caption = 'Get Properties';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    GetBlobProperties(Rec.Name);
                end;
            }

            action(SetBlobPropertiesAction)
            {
                Caption = 'Set Properties (Dummy)';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    SetBlobProperties(Rec.Name);
                end;
            }

            action(GetBlobMetadataAction)
            {
                Caption = 'Get Metadata';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    GetBlobMetadata(Rec.Name);
                end;
            }

            action(SetBlobMetadataAction)
            {
                Caption = 'Set Metadata';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    SetBlobMetadata(Rec.Name);
                end;
            }

            action(GetBlobTagsAction)
            {
                Caption = 'Get Tags';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    GetBlobTags(Rec.Name);
                end;
            }
            action(SetBlobTagsAction)
            {
                Caption = 'Set Tags (Dummy)';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    SetBlobTags(Rec.Name);
                end;
            }

            action(CopyBlobAction)
            {
                Caption = 'Copy Blob';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    CopyBlob(Rec.Name);
                end;
            }

            action(AbortCopyBlobAction)
            {
                Caption = 'Abort Copy Blob';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    if IsNullGuid(GlobalCopyId) then
                        Error('You need to initiate a "Copy Blob"-action first');
                    AbortCopyBlob(GlobalCopyId, GlobalLastDestContainer, GlobalLastDestBlobName);
                end;
            }

            action(AcquireLeaseBlob)
            {
                Caption = 'Acquire Lease';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    BlobAcquireLease(Rec.Name);
                end;
            }
            action(RenewLeaseBlob)
            {
                Caption = 'Renew Lease';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    BlobRenewLease(Rec.Name, GlobalLeaseId);
                end;
            }
            action(ReleaseLeaseBlob)
            {
                Caption = 'Release Lease';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    BlobReleaseLease(Rec.Name, GlobalLeaseId);
                end;
            }
            action(SetExpirationRelativeToNow)
            {
                Caption = 'Set Expiration (+15 seconds)';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    SetBlobExpirationRelativeToNow(Rec.Name, 15000);
                end;
            }
            action(SnapshotBlobAction)
            {
                Caption = 'Snapshot Blob';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    SnapshotBlob(Rec.Name);
                end;
            }

            action(DeleteBlobAction)
            {
                Caption = 'Delete Blob';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    DeleteBlob(Rec.Name);
                end;
            }
            action(UndeleteBlobAction)
            {
                Caption = 'Undelete Blob';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    if GlobalLastDeleteBlobName = '' then
                        Error('You need to delete a Blob first to set "GlobalLastDeleteBlobName"');
                    UndeleteBlob(GlobalLastDeleteBlobName);
                end;
            }
            action(AppendBlockAction)
            {
                Caption = 'Append Block';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    AppendBlock(Rec.Name);
                end;
            }
            action(PutPageUpdateAction)
            {
                Caption = 'Put Page (Update)';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    PutPageUpdate(Rec.Name);
                end;
            }

            action(GetPageRangeseAction)
            {
                Caption = 'Get Page Ranges';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    GetPageRanges(Rec.Name);
                end;
            }

            action(PutBlockAction)
            {
                Caption = 'Put Block';
                Image = ViewDetails;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                begin
                    PutBlock(Rec.Name);
                end;
            }
        }
    }
    var
        OriginalRequestObject: Codeunit "AZBSA Request Object";
        GlobalLeaseId: Guid;
        GlobalCopyId: Guid;
        GlobalLastDestContainer: Text;
        GlobalLastDestBlobName: Text;
        GlobalLastDeleteBlobName: Text;

    procedure AddEntry(ContainerContent: Record "AZBSA Container Content")
    begin
        Rec.TransferFields(ContainerContent);
        Rec.Insert();
    end;

    procedure InitializeFromTempRec(var ContainerContent: Record "AZBSA Container Content")
    begin
        if not ContainerContent.FindSet(false, false) then
            exit;

        ContainerContent.GetRequestObject(OriginalRequestObject);
        repeat
            ContainerContent.CalcFields("XML Value");
            Rec.TransferFields(ContainerContent);
            Rec.Insert();
        until ContainerContent.Next() = 0;
    end;

    local procedure CopyBlob(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        SourceRequestObject: Codeunit "AZBSA Request Object";
        URIHelper: Codeunit "AZBSA URI Helper";
        InputDialog: Page "AZBSA Input Dialog Copy Blob";
        Operation: Enum "AZBSA Blob Storage Operation";
        DestStorAccName: Text;
        DestContainer: Text;
        DestBlobName: Text;
        SourceURI: Text;
    begin
        // Get Information from User
        InputDialog.InitPage(OriginalRequestObject.GetStorageAccountName(), OriginalRequestObject.GetContainerName(), BlobName);
        if InputDialog.RunModal() <> Action::OK then
            exit;
        InputDialog.GetResults(DestStorAccName, DestContainer, DestBlobName);

        // Create two "Request Objects"; one for Source one for Destination
        InitializeRequestObjectFromOriginal(SourceRequestObject, DestBlobName); // copy from "OriginalRequestObject"
        SourceRequestObject.SetOperation(Operation::CopyBlob);

        InitializeRequestObjectFromOriginal(RequestObject, ''); // copy from "OriginalRequestObject"
        RequestObject.InitializeRequest(DestStorAccName, DestContainer, DestBlobName); // Update with user Values
        GlobalLastDestContainer := DestContainer;
        GlobalLastDestBlobName := DestBlobName;

        // Create URI for Source Blob
        SourceURI := URIHelper.ConstructUri(SourceRequestObject);

        API.CopyBlob(RequestObject, SourceURI);
        GlobalCopyId := RequestObject.GetCopyIdFromResponseHeaders();
    end;

    local procedure AbortCopyBlob(CopyId: Guid; ContainerName: Text; BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, '');
        RequestObject.SetContainerName(ContainerName);
        RequestObject.SetBlobName(BlobName);
        API.AbortCopyBlob(RequestObject, CopyId);
    end;

    local procedure GetBlobProperties(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.GetBlobProperties(RequestObject);
    end;

    local procedure SetBlobProperties(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        RequestObject.AddOptionalHeader('x-ms-blob-content-type', 'application/octet-stream');
        API.SetBlobProperties(RequestObject);
    end;

    local procedure InitializeRequestObjectFromOriginal(var RequestObject: Codeunit "AZBSA Request Object"; BlobName: Text)
    begin
        if BlobName = '' then
            BlobName := OriginalRequestObject.GetBlobName();
        RequestObject.InitializeAuthorization(OriginalRequestObject.GetAuthorizationType(), OriginalRequestObject.GetSecret());
        RequestObject.InitializeRequest(OriginalRequestObject.GetStorageAccountName(), OriginalRequestObject.GetContainerName(), BlobName);
        RequestObject.SetApiVersion(OriginalRequestObject.GetApiVersion());
    end;

    local procedure GetBlobMetadata(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.GetBlobMetadata(RequestObject);
    end;

    local procedure SetBlobMetadata(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        RequestObject.SetMetadataNameValueHeader('Dummy', 'DummyValue01');
        API.SetBlobMetadata(RequestObject);
    end;

    local procedure GetBlobTags(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        Message(Format(API.GetBlobTags(RequestObject)));
    end;

    local procedure SetBlobTags(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        Tags: Dictionary of [Text, Text];
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        Tags.Add('tag-name-1', 'tag-value-1');
        Tags.Add('tag-name-2', 'tag-value-2');
        API.SetBlobTags(RequestObject, Tags);
    end;

    local procedure BlobAcquireLease(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.BlobLeaseAcquire(RequestObject, 15);
        GlobalLeaseId := RequestObject.GetHeaderValueFromResponseHeaders('x-ms-lease-id');
        Message('Initiated 15-second lease. Saved LeaseId to Global variable');
    end;

    local procedure BlobRenewLease(BlobName: Text; LeaseId: Guid)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        if IsNullGuid(LeaseID) then
            Error('You need to call "Acquire Lease" first (global variable "LeaseId" is not set)');
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.BlobLeaseRenew(RequestObject, LeaseID);
    end;

    local procedure BlobReleaseLease(BlobName: Text; LeaseId: Guid)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        if IsNullGuid(LeaseID) then
            Error('You need to call "Acquire Lease" first (global variable "LeaseId" is not set)');
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.BlobLeaseRelease(RequestObject, LeaseID);
    end;

    local procedure SetBlobExpirationRelativeToNow(BlobName: Text; ExpiryTime: Integer)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.SetBlobExpiryRelativeToNow(RequestObject, ExpiryTime);
    end;

    local procedure SnapshotBlob(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.SnapshotBlob(RequestObject);
    end;

    local procedure DeleteBlob(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.DeleteBlobFromContainer(RequestObject);
        GlobalLastDeleteBlobName := BlobName;
    end;

    local procedure UndeleteBlob(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.UndeleteBlob(RequestObject);
    end;

    local procedure AppendBlock(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.AppendBlockText(RequestObject, 'This is some sample text to append');
    end;

    local procedure PutPageUpdate(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        SampleText: Text;
    begin
        SampleText := 'This is some sample text';
        SampleText := SampleText.PadRight(512, '.');
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.PutPageUpdate(RequestObject, 0, 511, SampleText);
    end;

    local procedure GetPageRanges(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
        PageRanges: Dictionary of [Integer, Integer];
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.GetPageRanges(RequestObject, PageRanges);
    end;

    local procedure PutBlock(BlobName: Text)
    var
        API: Codeunit "AZBSA Blob Storage API";
        RequestObject: Codeunit "AZBSA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.PutBlock(RequestObject, 'This is some sample text');
    end;
}
