// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 89000 "AZBSA Blob Storage API"
{
    // See: https://docs.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api

    trigger OnRun()
    begin

    end;

    var
        CreateContainerOperationNotSuccessfulErr: Label 'Could not create container %1.', Comment = '%1 = Container Name';
        DeleteContainerOperationNotSuccessfulErr: Label 'Could not delete container %1.', Comment = '%1 = Container Name';
        DeleteBlobOperationNotSuccessfulErr: Label 'Could not %3 Blob %1 in container %2.', Comment = '%1 = Blob Name; %2 = Container Name, %3 = Delete/Undelete';
        UploadBlobOperationNotSuccessfulErr: Label 'Could not upload %1 to %2', Comment = '%1 = Blob Name; %2 = Container Name';
        LeaseOperationNotSuccessfulErr: Label 'Could not %1 lease for %2 %3.', Comment = '%1 = Lease Action, %2 = Type (Container or Blob), %3 = Name';
        CopyOperationNotSuccessfulErr: Label 'Could not copy %1 to %2.', Comment = '%1 = Source, %2 = Desctination';
        AbortCopyOperationNotSuccessfulErr: Label 'Could not abort copy operation for %1.', Comment = '%1 = Blobname';
        PropertiesOperationNotSuccessfulErr: Label 'Could not %1%2 Properties.', Comment = '%1 = Get/Set, %2 = Service/"", ';
        TagsOperationNotSuccessfulErr: Label 'Could not %1%2 Tags.', Comment = '%1 = Get/Set, %2 = Service/Blob, ';
        MetadataOperationNotSuccessfulErr: Label 'Could not %1%2 Metadata.', Comment = '%1 = Get/Set, %2 = Container/Blob, ';
        ContainerAclOperationNotSuccessfulErr: Label 'Could not %1 Container ACL.', Comment = '%1 = Get/Set ';
        ExpiryOperationNotSuccessfulErr: Label 'Could not set expiration on %1.', Comment = '%1 = Blob';
        SnapshotOperationNotSuccessfulErr: Label 'Could not create snapshot for %1.', Comment = '%1 = Blob';
        ParameterDurationErr: Label 'Duration can be -1 (for infinite) or between 15 and 60 seconds. Parameter Value: %1', Comment = '%1 = Current Value';
        ParameterMissingErr: Label 'You need to specify %1 (%2)', Comment = '%1 = Variable Name, %2 = Header Identifer';
        BlobTierOperationNotSuccessfulErr: Label 'Could not set tier %1 on %2.', Comment = '%1 = Tier; %2 = Blob';
        PutPageOperationNotSuccessfulErr: Label 'Could not put page on %1.', Comment = '%1 = Blob';
        IncrementalCopyOperationNotSuccessfulErr: Label 'Could not copy from %1 to %2.', Comment = '%1 = Source; %2 = Destination';
        PutBlockOperationNotSuccessfulErr: Label 'Could not put block on %1.', Comment = '%1 = Blob';
        PutBlockListOperationNotSuccessfulErr: Label 'Could not put block list on %1.', Comment = '%1 = Blob';

    // #region (PUT) Create Containers
    /// <summary>
    /// Creates a new Container in the Storage Account
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure CreateContainer(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::PutContainer);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(CreateContainerOperationNotSuccessfulErr, RequestObject.GetContainerName()));
    end;
    // #endregion 

    // #region (GET) List Available Containers
    // TODO: Implement optional parameters

    /// <summary>
    /// List all Containers in specific Storage Account and outputs the result to the user
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-containers2
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure ListContainers(var RequestObject: Codeunit "AZBSA Request Object")
    begin
        ListContainers(RequestObject, true);
    end;

    /// <summary>
    /// List all Containers in specific Storage Account
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-containers2
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListContainers(var RequestObject: Codeunit "AZBSA Request Object"; ShowOutput: Boolean)
    var
        Container: Record "AZBSA Container";
    begin
        ListContainers(RequestObject, Container, ShowOutput);
    end;

    /// <summary>
    /// List all Containers in specific Storage Account
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-containers2
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="Container">Collection of the result (temporary record).</param>
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListContainers(var RequestObject: Codeunit "AZBSA Request Object"; var Container: Record "AZBSA Container"; ShowOutput: Boolean)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        HelperLibrary: Codeunit "AZBSA Helper Library";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        RequestObject.SetOperation(Operation::ListContainers);

        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error

        NodeList := HelperLibrary.CreateContainerNodeListFromResponse(ResponseText);
        Container.SetBaseInfos(RequestObject);
        HelperLibrary.ContainerNodeListTotempRecord(NodeList, Container);
        if ShowOutput then
            HelperLibrary.ShowTempRecordLookup(Container);
    end;
    // #endregion

    // #region (DELETE) Delete Containers
    /// <summary>
    /// Delete a Container in the Storage Account
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure DeleteContainer(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::DeleteContainer);
        WebRequestHelper.DeleteOperation(RequestObject, StrSubstNo(DeleteContainerOperationNotSuccessfulErr, RequestObject.GetContainerName()));
    end;
    // #endregion (DELETE) Delete Containers

    // #region (GET) List Container Contents
    /// <summary>
    /// Lists the Blobs in a specific container and outputs the result to the user
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure ListBlobs(var RequestObject: Codeunit "AZBSA Request Object")
    begin
        ListBlobs(RequestObject, true);
    end;

    /// <summary>
    /// Lists the Blobs in a specific container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListBlobs(var RequestObject: Codeunit "AZBSA Request Object"; ShowOutput: Boolean)
    var
        ContainerContent: Record "AZBSA Container Content";
    begin
        ListBlobs(RequestObject, ContainerContent, ShowOutput);
    end;

    /// <summary>
    /// Lists the Blobs in a specific container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ContainerContent">Collection of the result (temporary record).</param>
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListBlobs(var RequestObject: Codeunit "AZBSA Request Object"; var ContainerContent: Record "AZBSA Container Content"; ShowOutput: Boolean)
    var
        HelperLibrary: Codeunit "AZBSA Helper Library";
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        RequestObject.SetOperation(Operation::ListContainerContents);

        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error

        NodeList := HelperLibrary.CreateBlobNodeListFromResponse(ResponseText);
        ContainerContent.SetBaseInfos(RequestObject);
        HelperLibrary.BlobNodeListToTempRecord(NodeList, ContainerContent);
        if ShowOutput then
            HelperLibrary.ShowTempRecordLookup(ContainerContent);
    end;
    // #endregion (GET) ListContainerContents

    // #region (PUT) Upload Blob into Container
    /// <summary>
    /// Uploads (PUT) a File to a Container (with File Selection Dialog)
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary para#meters for the request.</param>    
    procedure UploadBlobIntoContainerUI(var RequestObject: Codeunit "AZBSA Request Object")
    var
        Filename: Text;
        SourceStream: InStream;
    begin
        if UploadIntoStream('Upload File', '', '', Filename, SourceStream) then
            UploadBlobIntoContainerStream(RequestObject, Filename, SourceStream);
    end;

    /// <summary>
    /// Uploads (PUT) the content of an InStream to a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="BlobName">The Name of the Blob to Upload.</param>
    /// <param name="SourceStream">The Content of the Blob as InStream.</param>
    procedure UploadBlobIntoContainerStream(var RequestObject: Codeunit "AZBSA Request Object"; BlobName: Text; var SourceStream: InStream)
    var
        SourceContent: Variant;
    begin
        SourceContent := SourceStream;
        RequestObject.SetBlobName(BlobName);
        UploadBlobIntoContainer(RequestObject, SourceContent);
    end;

    /// <summary>
    /// Uploads (PUT) the content of a Text-Variable to a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="BlobName">The Name of the Blob to Upload.</param>
    /// <param name="SourceText">The Content of the Blob as Text.</param>
    procedure UploadBlobIntoContainerText(var RequestObject: Codeunit "AZBSA Request Object"; BlobName: Text; var SourceText: Text)
    var
        SourceContent: Variant;
    begin
        SourceContent := SourceText;
        RequestObject.SetBlobName(BlobName);
        UploadBlobIntoContainer(RequestObject, SourceContent);
    end;

    local procedure UploadBlobIntoContainer(var RequestObject: Codeunit "AZBSA Request Object"; var SourceContent: Variant)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        RequestObject.SetOperation(Operation::PutBlob);

        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    WebRequestHelper.AddBlobPutBlockBlobContentHeaders(Content, RequestObject, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    WebRequestHelper.AddBlobPutBlockBlobContentHeaders(Content, RequestObject, SourceText);
                end;
        end;

        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(UploadBlobOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName()));
    end;

    procedure PutBlobPageBlobTextPlain(var RequestObject: Codeunit "AZBSA Request Object"; PageSize: Integer)
    begin
        PutBlobPageBlob(RequestObject, PageSize, 'text/plain; charset=UTF-8');
    end;

    procedure PutBlobPageBlob(var RequestObject: Codeunit "AZBSA Request Object"; PageSize: Integer; ContentType: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::PutBlob);
        WebRequestHelper.AddBlobPutPageBlobContentHeaders(RequestObject, PageSize, ContentType);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(UploadBlobOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName()));
    end;

    procedure PutBlobAppendBlobTextPlain(var RequestObject: Codeunit "AZBSA Request Object")
    begin
        PutBlobAppendBlob(RequestObject, 'text/plain; charset=UTF-8');
    end;

    procedure PutBlobAppendBlob(var RequestObject: Codeunit "AZBSA Request Object"; ContentType: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::PutBlob);
        WebRequestHelper.AddBlobPutAppendBlobContentHeaders(RequestObject, ContentType);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(UploadBlobOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName()));
    end;
    // #endregion (PUT) Upload Blob into Container

    // #region (PUT) Append Block
    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// Uses 'text/plain; charset=UTF-8' as Content-Type
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="ContentAsText">Text-variable containing the content that should be added to the Blob</param>
    procedure AppendBlockText(var RequestObject: Codeunit "AZBSA Request Object"; ContentAsText: Text)
    begin
        AppendBlockText(RequestObject, ContentAsText, 'text/plain; charset=UTF-8');
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="ContentAsText">Text-variable containing the content that should be added to the Blob</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    procedure AppendBlockText(var RequestObject: Codeunit "AZBSA Request Object"; ContentAsText: Text; ContentType: Text)
    begin
        AppendBlock(RequestObject, ContentType, ContentAsText);
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// Uses 'application/octet-stream' as Content-Type
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="ContentAsStream">InStream containing the content that should be added to the Blob</param>
    procedure AppendBlockStream(var RequestObject: Codeunit "AZBSA Request Object"; ContentAsStream: InStream)
    begin
        AppendBlockStream(RequestObject, ContentAsStream, 'application/octet-stream');
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="ContentAsStream">InStream containing the content that should be added to the Blob</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    procedure AppendBlockStream(var RequestObject: Codeunit "AZBSA Request Object"; ContentAsStream: InStream; ContentType: Text)
    begin
        AppendBlock(RequestObject, ContentType, ContentAsStream);
    end;

    /// <summary>
    /// The Append Block operation commits a new block of data to the end of an existing append blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="ContentType">Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the Blob</param>
    procedure AppendBlock(var RequestObject: Codeunit "AZBSA Request Object"; ContentType: Text; SourceContent: Variant)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        Content: HttpContent;
        Headers: HttpHeaders;
        SourceStream: InStream;
        SourceText: Text;
    begin
        RequestObject.SetOperation(Operation::AppendBlock);
        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    WebRequestHelper.AddBlobPutBlockBlobContentHeaders(Content, RequestObject, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    WebRequestHelper.AddBlobPutBlockBlobContentHeaders(Content, RequestObject, SourceText);
                end;
        end;
        Content.GetHeaders(Headers);
        // TODO: Check if it would be better to create a helper-function, that allows adding Content without the unnecessary headers
        RequestObject.RemoveHeader(Headers, 'x-ms-blob-type'); // was automatically added in AddBlobPutBlockBlobContentHeaders, needs to removed
        RequestObject.RemoveHeader(Headers, 'Content-Type'); // was automatically added in AddBlobPutBlockBlobContentHeaders, needs to removed

        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(UploadBlobOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName()));
    end;
    // #endregion (PUT) Append Block

    // #region (GET) Get Blob from Container
    /// <summary>
    /// Downloads (GET) a Blob as a File from a Container; shows a Lookup of existing Blobs to select from
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure DownloadBlobAsFileWithSelect(var RequestObject: Codeunit "AZBSA Request Object")
    var
        ContainerContent: Record "AZBSA Container Content";
        HelperLibrary: Codeunit "AZBSA Helper Library";
        BlobName: Text;
    begin
        // Get list of available blobs
        ListBlobs(RequestObject, ContainerContent, false);
        // Show Lookup Page to select Blob to download
        BlobName := HelperLibrary.LookupContainerContent(ContainerContent);
        // Download Blob
        RequestObject.SetBlobName(BlobName);
        DownloadBlobAsFile(RequestObject);
    end;

    /// <summary>
    /// Downloads (GET) a Blob as a File from a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure DownloadBlobAsFile(var RequestObject: Codeunit "AZBSA Request Object")
    var
        BlobName: Text;
        TargetStream: InStream;
    begin
        DownloadBlobAsStream(RequestObject, TargetStream);
        BlobName := RequestObject.GetBlobName();
        DownloadFromStream(TargetStream, '', '', '', BlobName);
    end;

    /// <summary>
    /// Downloads (GET) a Blob as a InStream from a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="TargetStream">The result InStream containg the content of the Blob.</param>
    procedure DownloadBlobAsStream(var RequestObject: Codeunit "AZBSA Request Object"; var TargetStream: InStream)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::GetBlob);
        WebRequestHelper.GetResponseAsStream(RequestObject, TargetStream);
    end;

    /// <summary>
    /// Downloads (GET) a Blob as Text from a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="TargetText">The result Text containg the content of the Blob.</param>
    procedure DownloadBlobAsText(var RequestObject: Codeunit "AZBSA Request Object"; var TargetText: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::GetBlob);
        WebRequestHelper.GetResponseAsText(RequestObject, TargetText);
    end;
    // #endregion

    procedure DeleteBlobFromContainerUI(var RequestObject: Codeunit "AZBSA Request Object")
    var
        ContainerContent: Record "AZBSA Container Content";
        HelperLibrary: Codeunit "AZBSA Helper Library";
        BlobName: Text;
    begin
        // Get list of available blobs
        ListBlobs(RequestObject, ContainerContent, false);
        // Show Lookup Page to select Blob to download
        BlobName := HelperLibrary.LookupContainerContent(ContainerContent);
        // Download Blob
        RequestObject.SetBlobName(BlobName);
        DeleteBlobFromContainer(RequestObject);
    end;

    procedure DeleteBlobFromContainer(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::DeleteBlob);
        WebRequestHelper.DeleteOperation(RequestObject, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName(), 'Delete'));
    end;

    // #region (PUT) Undelete Blob
    /// <summary>
    /// The Undelete Blob operation restores the contents and metadata of a soft deleted blob and any associated soft deleted snapshots (version 2017-07-29 or later)
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/undelete-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure UndeleteBlob(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::UndeleteBlob);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName(), 'Undelete'));
    end;
    // #endregion (PUT) Undelete Blob

    // #region (PUT) Container Acquire Lease
    /// <summary>
    /// Establishes a lock on a container for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure ContainerLeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object")
    var
        ProposedLeaseId: Guid;
    begin
        ContainerLeaseAcquire(RequestObject, -1, ProposedLeaseId); // Infinite duration, null Guid
    end;

    /// <summary>
    /// Establishes a lock on a container for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    procedure ContainerLeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object"; DurationSeconds: Integer)
    var
        ProposedLeaseId: Guid;
    begin
        ContainerLeaseAcquire(RequestObject, DurationSeconds, ProposedLeaseId); // Custom duration, new Guid
    end;

    /// <summary>
    /// Establishes a lock on a container for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    procedure ContainerLeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object"; ProposedLeaseId: Guid)
    begin
        ContainerLeaseAcquire(RequestObject, -1, ProposedLeaseId); // Infinite duration, custom Guid
    end;

    /// <summary>
    /// Establishes a lock on a container for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    procedure ContainerLeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object"; DurationSeconds: Integer; ProposedLeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseContainer);
        LeaseAcquire(RequestObject, DurationSeconds, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'acquire', 'Container', RequestObject.GetContainerName()));
    end;
    // #endregion (PUT) Container Acquire Lease

    // #region (PUT) Container Release Lease
    /// <summary>
    /// Releases a lock on a container if it is no longer needed so that another client may immediately acquire a lease against the container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be freed</param>
    procedure ContainerLeaseRelease(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseContainer);
        LeaseRelease(RequestObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'release', 'Container', RequestObject.GetContainerName()));
    end;
    // #endregion (PUT) Container Release Lease

    // #region (PUT) Container Renew Lease
    /// <summary>
    /// Renews a lock on a container to keep it locked again for the same amount of time as before
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be renewed</param>
    procedure ContainerLeaseRenew(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseContainer);
        LeaseRenew(RequestObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'renew', 'Container', RequestObject.GetContainerName()));
    end;
    // #endregion (PUT) Container Renew Lease

    // #region (PUT) Container Break Lease
    /// <summary>
    /// Breaks a lock on a container but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    procedure ContainerLeaseBreak(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseContainer);
        LeaseBreak(RequestObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'break', 'Container', RequestObject.GetContainerName()));
    end;
    // #endregion (PUT) Container Break Lease

    // #region (PUT) Container Change Lease
    /// <summary>
    /// Changes the lock ID for a lease on a container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-container
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be changed</param>
    /// <param name="ProposedLeaseId">The Guid that should be used in future</param>
    procedure ContainerLeaseChange(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid; ProposedLeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseContainer);
        LeaseChange(RequestObject, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'change', 'Container', RequestObject.GetContainerName()));
    end;
    // #endregion (PUT) Container Change Lease

    // #region (PUT) Blob Acquire Lease
    /// <summary>
    /// Establishes a lock on a Blob for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure BlobLeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object")
    var
        ProposedLeaseId: Guid;
    begin
        BlobLeaseAcquire(RequestObject, -1, ProposedLeaseId); // Infinite duration, null Guid
    end;

    /// <summary>
    /// Establishes a lock on a Blob for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    procedure BlobLeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object"; DurationSeconds: Integer)
    var
        ProposedLeaseId: Guid;
    begin
        BlobLeaseAcquire(RequestObject, DurationSeconds, ProposedLeaseId); // Custom duration, new Guid
    end;

    /// <summary>
    /// Establishes a lock on a Blob for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    procedure BlobLeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object"; ProposedLeaseId: Guid)
    begin
        BlobLeaseAcquire(RequestObject, -1, ProposedLeaseId); // Infinite duration, custom Guid
    end;

    /// <summary>
    /// Establishes a lock on a Blob for delete operations. The lock duration can be 15 to 60 seconds or can be infinite
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="DurationSeconds">Specifies the duration of the lease, in seconds, or negative one (-1) for a lease that never expires</param>
    /// <param name="ProposedLeaseId">Proposed lease ID, in a GUID string format</param>
    procedure BlobLeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object"; DurationSeconds: Integer; ProposedLeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseBlob);
        LeaseAcquire(RequestObject, DurationSeconds, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'acquire', 'Blob', RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Blob Acquire Lease

    // #region (PUT) Blob Release Lease
    /// <summary>
    /// Releases a lock on a Blob if it is no longer needed so that another client may immediately acquire a lease against the container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be freed</param>
    procedure BlobLeaseRelease(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseBlob);
        LeaseRelease(RequestObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'release', 'Blob', RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Blob Release Lease

    // #region (PUT) Blob Renew Lease
    /// <summary>
    /// Renews a lock on a Blob to keep it locked again for the same amount of time as before
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be renewed</param>
    procedure BlobLeaseRenew(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseBlob);
        LeaseRenew(RequestObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'renew', 'Blob', RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Blob Renew Lease

    // #region (PUT) Blob Break Lease
    /// <summary>
    /// Breaks a lock on a blob but ensures that another client cannot acquire a new lease until the current lease period has expired
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be broken</param>
    procedure BlobLeaseBreak(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseBlob);
        LeaseBreak(RequestObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'break', 'Blob', RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Blob Break Lease

    // #region (PUT) Blob Change Lease
    /// <summary>
    /// Changes the lock ID for a lease on a Blob
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/lease-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="LeaseId">The Guid for the lease that should be changed</param>
    /// <param name="ProposedLeaseId">The Guid that should be used in future</param>    
    procedure BlobLeaseChange(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid; ProposedLeaseId: Guid)
    var
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::LeaseBlob);
        LeaseChange(RequestObject, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'change', 'Blob', RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Blob Change Lease

    // #region Private Lease-functions
    local procedure LeaseAcquire(var RequestObject: Codeunit "AZBSA Request Object"; DurationSeconds: Integer; ProposedLeaseId: Guid; OperationNotSuccessfulErr: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
    begin
        if ((DurationSeconds > 0) and ((DurationSeconds < 15) or (DurationSeconds > 60))) xor (not (DurationSeconds <> -1)) then
            Error(ParameterDurationErr, DurationSeconds);
        RequestObject.SetLeaseActionHeader('acquire');
        RequestObject.SetLeaseDurationHeader(DurationSeconds);
        if not IsNullGuid(ProposedLeaseId) then
            RequestObject.SetProposedLeaseIdHeader(ProposedLeaseId);
        WebRequestHelper.PutOperation(RequestObject, OperationNotSuccessfulErr);
    end;

    local procedure LeaseRelease(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid; OperationNotSuccessfulErr: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
    begin
        RequestObject.SetLeaseActionHeader('release');
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        RequestObject.SetLeaseIdHeader(LeaseId);
        WebRequestHelper.PutOperation(RequestObject, OperationNotSuccessfulErr);
    end;

    local procedure LeaseRenew(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid; OperationNotSuccessfulErr: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
    begin
        RequestObject.SetLeaseActionHeader('renew');
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        RequestObject.SetLeaseIdHeader(LeaseId);
        WebRequestHelper.PutOperation(RequestObject, OperationNotSuccessfulErr);
    end;

    local procedure LeaseBreak(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid; OperationNotSuccessfulErr: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
    begin
        RequestObject.SetLeaseActionHeader('break');
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        RequestObject.SetLeaseIdHeader(LeaseId);
        WebRequestHelper.PutOperation(RequestObject, OperationNotSuccessfulErr);
    end;

    local procedure LeaseChange(var RequestObject: Codeunit "AZBSA Request Object"; LeaseId: Guid; ProposedLeaseId: Guid; OperationNotSuccessfulErr: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
    begin
        RequestObject.SetLeaseActionHeader('change');
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        if IsNullGuid(ProposedLeaseId) then
            Error(ParameterMissingErr, 'ProposedLeaseId', 'x-ms-proposed-lease-id');
        RequestObject.SetLeaseIdHeader(LeaseId);
        RequestObject.SetProposedLeaseIdHeader(ProposedLeaseId);
        WebRequestHelper.PutOperation(RequestObject, OperationNotSuccessfulErr);
    end;
    // #endregion Private Lease-functions

    // #region (PUT) Copy Blob
    /// <summary>
    /// The Copy Blob operation copies a blob to a destination within the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="SourceName">Specifies the name of the source blob or file.</param>
    procedure CopyBlob(var RequestObject: Codeunit "AZBSA Request Object"; SourceName: Text)
    var
        LeaseId: Guid;
    begin
        CopyBlob(RequestObject, SourceName, LeaseId);
    end;

    /// <summary>
    /// The Copy Blob operation copies a blob to a destination within the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="SourceName">Specifies the name of the source blob or file.</param>
    /// <param name="LeaseId">Required if the destination blob has an active lease. The lease ID specified must match the lease ID of the destination blob.</param>
    procedure CopyBlob(var RequestObject: Codeunit "AZBSA Request Object"; SourceName: Text; LeaseId: Guid)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::DeleteBlob);
        RequestObject.SetCopySourceNameHeader(SourceName);
        if not IsNullGuid(LeaseId) then
            RequestObject.SetLeaseIdHeader(LeaseId);
        WebRequestHelper.PutOperation(RequestObject, CopyOperationNotSuccessfulErr);
    end;
    // #endregion (PUT) Copy Blob

    // #region (PUT) Abort Copy Blob
    /// <summary>
    /// The Abort Copy Blob operation aborts a pending Copy Blob operation, and leaves a destination blob with zero length and full metadata.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/abort-copy-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="CopyId">Id with the copy identifier provided in the x-ms-copy-id header of the original Copy Blob operation.</param>
    procedure AbortCopyBlob(var RequestObject: Codeunit "AZBSA Request Object"; CopyId: Guid)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        FormatHelper: Codeunit "AZBSA Format Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::AbortCopyBlob);
        RequestObject.AddOptionalUriParameter('copyid', FormatHelper.RemoveCurlyBracketsFromString(CopyId));
        RequestObject.SetCopyActionHeader('abort');
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(AbortCopyOperationNotSuccessfulErr, CopyId));
    end;
    // #endregion (PUT) Abort Copy Blob

    // #region (GET) Get Blob Service Properties
    /// <summary>
    /// The Get Blob Service Properties operation gets the properties of a storage account’s Blob service, including properties for Storage Analytics and CORS (Cross-Origin Resource Sharing) rules
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-service-properties
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <returns>XmlDocument containing the current properties</returns>
    procedure GetBlobServiceProperties(var RequestObject: Codeunit "AZBSA Request Object"): XmlDocument
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        FormatHelper: Codeunit "AZBSA Format Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetBlobServiceProperties);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;
    // #endregion (GET) Get Blob Service Properties

    // #region (PUT) Set Blob Service Properties
    /// <summary>
    /// The Set Blob Service Properties operation sets properties for a storage account’s Blob service endpoint, including properties for Storage Analytics, CORS (Cross-Origin Resource Sharing) rules and soft delete settings.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-service-properties
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="Document">The XmlDocument containing the Properties</param>
    procedure SetBlobServiceProperties(var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        Content: HttpContent;
    begin
        RequestObject.SetOperation(Operation::SetBlobServiceProperties);
        WebRequestHelper.AddServicePropertiesContent(Content, RequestObject, Document);
        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'set', 'Service'));
    end;
    // #endregion (PUT) Set Blob Service Properties

    // #region (GET) Get Blob Properties
    /// <summary>
    /// The Get Blob Service Properties operation gets the properties of a storage account’s Blob service, including properties for Storage Analytics and CORS (Cross-Origin Resource Sharing) rules
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-service-properties
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure GetBlobProperties(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetBlobProperties);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
    end;
    // #endregion (GET) Get Blob Properties

    // #region (PUT) Set Blob Properties
    /// <summary>
    /// The Set Blob Properties operation sets system properties on the blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-properties
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure SetBlobProperties(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        Content: HttpContent;
    begin
        RequestObject.SetOperation(Operation::SetBlobProperties);
        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'set', ''));
    end;
    // #endregion (PUT) Set Blob Properties

    // #region (GET) Get Container Metadata
    /// <summary>
    /// The Get Container Metadata operation returns all user-defined metadata for the container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-container-metadata
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure GetContainerMetadata(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetContainerMetadata);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
    end;
    // #endregion (GET) Get Container Metadata

    // #region (PUT) Set Container Metadata
    /// <summary>
    /// The Set Container Metadata operation sets one or more user-defined name-value pairs for the specified container.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-container-metadata
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure SetContainerMetadata(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::SetContainerMetadata);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(MetadataOperationNotSuccessfulErr, 'set', 'Container'));
    end;
    // #endregion (PUT) Set Container Metadata

    // #region (GET) Get Blob Metadata
    /// <summary>
    /// The Get Blob Metadata operation returns all user-defined metadata for the specified blob or snapshot.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-metadata
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure GetBlobMetadata(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetBlobMetadata);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
    end;
    // #endregion (GET) Get Blob Metadata

    // #region (PUT) Set Blob Metadata
    /// <summary>
    /// The Set Blob Metadata operation sets user-defined metadata for the specified blob as one or more name-value pairs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-metadata
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure SetBlobMetadata(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::SetBlobMetadata);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(MetadataOperationNotSuccessfulErr, 'set', 'Blob'));
    end;
    // #endregion (PUT) Set Blob Metadata

    // #region (GET) Get Container ACL
    /// <summary>
    /// The Get Container ACL operation gets the permissions for the specified container. The permissions indicate whether container data may be accessed publicly.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-container-acl
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <returns>XmlDocument containing the current ACL</returns>
    procedure GetContainerACL(var RequestObject: Codeunit "AZBSA Request Object"): XmlDocument
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        FormatHelper: Codeunit "AZBSA Format Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetContainerAcl);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;
    // #endregion (GET) Get Container ACL

    // #region (PUT) Set Container ACL
    /// <summary>
    /// The Set Container ACL operation sets the permissions for the specified container. The permissions indicate whether blobs in a container may be accessed publicly.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-container-acl
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="Document">The XmlDocument containing the ACL definition</param>
    procedure SetContainerACL(var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        Content: HttpContent;
    begin
        RequestObject.SetOperation(Operation::SetContainerAcl);
        WebRequestHelper.AddContainerAclDefinition(Content, RequestObject, Document);
        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(ContainerAclOperationNotSuccessfulErr, 'set'));
    end;
    // #endregion (PUT) Set Container ACL

    // #region (GET) Get Container Properties
    /// <summary>
    /// The Get Container Properties operation returns all user-defined metadata and system properties for the specified container. The data returned does not include the container's list of blobs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-container-properties
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure GetContainerProperties(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetContainerProperties);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
    end;
    // #endregion (GET) Get Container Properties

    // #region (GET) Get Account Information
    /// <summary>
    /// The Get Account Information operation returns the sku name and account kind for the specified account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-account-information
    /// Read the result from the Response Headers after using this
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure GetAccountInformation(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetAccountInformation);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
    end;
    // #endregion (GET) Get Account Information

    // #region (GET) Get Blob Service Stats
    /// <summary>
    /// The Get Blob Service Stats operation retrieves statistics related to replication for the Blob service. It is only available on the secondary location endpoint when read-access geo-redundant replication is enabled for the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-service-stats
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure GetBlobServiceStats(var RequestObject: Codeunit "AZBSA Request Object"): XmlDocument
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        FormatHelper: Codeunit "AZBSA Format Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetBlobServiceStats);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;
    // #endregion (GET) Get Blob Service Stats

    // #region (GET) Get Blob Tags
    /// <summary>
    /// The Get Blob Tags operation returns all user-defined tags for the specified blob, version, or snapshot.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob-tags
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure GetBlobTags(var RequestObject: Codeunit "AZBSA Request Object"): XmlDocument
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        FormatHelper: Codeunit "AZBSA Format Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetBlobTags);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;
    // #endregion (GET) Get Blob Tags

    // #region (PUT) Set Blob Tags
    /// <summary>
    /// The Set Blob Tags operation sets user-defined tags for the specified blob as one or more key-value pairs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-tags
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="Tags">A Dictionary of [Text, Text] which contains the Tags you want to set.</param>    
    procedure SetBlobTags(var RequestObject: Codeunit "AZBSA Request Object"; Tags: Dictionary of [Text, Text])
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        Document: XmlDocument;
    begin
        Document := FormatHelper.TagsDictionaryToXmlDocument(Tags);
        SetBlobTags(RequestObject, Document);
    end;

    /// <summary>
    /// The Set Blob Tags operation sets user-defined tags for the specified blob as one or more key-value pairs.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-tags
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="Tags">A Dictionary of [Text, Text] which contains the Tags you want to set.</param>    
    procedure SetBlobTags(var RequestObject: Codeunit "AZBSA Request Object"; Tags: XmlDocument)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Content: HttpContent;
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::SetBlobTags);
        WebRequestHelper.AddTagsContent(Content, RequestObject, Tags);
        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(TagsOperationNotSuccessfulErr, 'set', 'Blob'));
    end;
    // #endregion (PUT) Set Blob Tags

    // #region (GET) Find Blob by Tags
    /// <summary>
    /// The Find Blobs by Tags operation finds all blobs in the storage account whose tags match a given search expression.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/find-blobs-by-tags
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure FindBlobsByTags(var RequestObject: Codeunit "AZBSA Request Object"; SearchTags: Dictionary of [Text, Text]): XmlDocument
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
    begin
        exit(FindBlobsByTags(RequestObject, FormatHelper.TagsDictionaryToSearchExpression(SearchTags)));
    end;

    /// <summary>
    /// The Find Blobs by Tags operation finds all blobs in the storage account whose tags match a given search expression.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/find-blobs-by-tags
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure FindBlobsByTags(var RequestObject: Codeunit "AZBSA Request Object"; SearchExpression: Text): XmlDocument
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        FormatHelper: Codeunit "AZBSA Format Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::FindBlobByTags);
        RequestObject.AddOptionalUriParameter('where', SearchExpression);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;
    // #endregion (GET) Find Blob by Tags

    // #region (PUT) Set Blob Expiry
    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry time relative to the file creation time, x-ms-expiry-time must be specified as the number of milliseconds to elapse from creation time.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ExpiryTime">Number if miliseconds (Integer) until the expiration.</param>
    procedure SetBlobExpiryRelativeToCreation(var RequestObject: Codeunit "AZBSA Request Object"; ExpiryTime: Integer)
    var
        ExpiryOption: Enum "AZBSA Blob Expiry Option";
    begin
        SetBlobExpiry(RequestObject, ExpiryOption::RelativeToCreation, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, RequestObject.GetBlobName()));
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry relative to the current time, x-ms-expiry-time must be specified as the number of milliseconds to elapse from now.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ExpiryTime">Number if miliseconds (Integer) until the expiration.</param>
    procedure SetBlobExpiryRelativeToNow(var RequestObject: Codeunit "AZBSA Request Object"; ExpiryTime: Integer)
    var
        ExpiryOption: Enum "AZBSA Blob Expiry Option";
    begin
        SetBlobExpiry(RequestObject, ExpiryOption::RelativeToNow, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, RequestObject.GetBlobName()));
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the expiry to an absolute DateTime
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ExpiryTime">Absolute DateTime for the expiration.</param>
    procedure SetBlobExpiryAbsolute(var RequestObject: Codeunit "AZBSA Request Object"; ExpiryTime: DateTime)
    var
        ExpiryOption: Enum "AZBSA Blob Expiry Option";
    begin
        SetBlobExpiry(RequestObject, ExpiryOption::Absolute, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, RequestObject.GetBlobName()));
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// Sets the file to never expire or removes the current expiry time, x-ms-expiry-time must not to be specified.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure SetBlobExpiryNever(var RequestObject: Codeunit "AZBSA Request Object")
    var
        ExpiryOption: Enum "AZBSA Blob Expiry Option";
    begin
        SetBlobExpiry(RequestObject, ExpiryOption::NeverExpire, '', StrSubstNo(ExpiryOperationNotSuccessfulErr, RequestObject.GetBlobName()));
    end;

    /// <summary>
    /// The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ExpiryOption">The type of expiration that should be set.</param>
    /// <param name="ExpiryTime">Variant containing Nothing, number if miliseconds (Integer) or the absolute DateTime for the expiration.</param>
    /// <param name="OperationNotSuccessfulErr">The error message that should be thrown when the request fails.</param>
    procedure SetBlobExpiry(var RequestObject: Codeunit "AZBSA Request Object"; ExpiryOption: Enum "AZBSA Blob Expiry Option"; ExpiryTime: Variant; OperationNotSuccessfulErr: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        DateTimeValue: DateTime;
        IntegerValue: Integer;
        SpecifyMilisecondsErr: Label 'You need to specify an Integer Value (number of miliseconds) for option %1', Comment = '%1 = Expiry Option';
        SpecifyDateTimeErr: Label 'You need to specify an DateTime Value for option %1', Comment = '%1 = Expiry Option';
    begin
        RequestObject.SetOperation(Operation::SetBlobExpiry);
        RequestObject.SetBlobExpiryOptionHeader(Format(ExpiryOption));
        case ExpiryOption of
            ExpiryOption::RelativeToCreation, ExpiryOption::RelativeToNow:
                if not ExpiryTime.IsInteger() then
                    Error(SpecifyMilisecondsErr, ExpiryOption);
            ExpiryOption::Absolute:
                if not ExpiryTime.IsDateTime() then
                    Error(SpecifyDateTimeErr, ExpiryOption);
        end;
        if not (ExpiryOption in [ExpiryOption::NeverExpire]) then
            case true of
                ExpiryTime.IsInteger():
                    begin
                        IntegerValue := ExpiryTime;
                        RequestObject.SetBlobExpiryTimeHeader(IntegerValue);
                    end;
                ExpiryTime.IsDateTime():
                    begin
                        DateTimeValue := ExpiryTime;
                        RequestObject.SetBlobExpiryTimeHeader(DateTimeValue);
                    end;
            end;
        WebRequestHelper.PutOperation(RequestObject, OperationNotSuccessfulErr);
    end;
    // #endregion (PUT) Set Blob Expiry

    // #region (PUT) Snapshot Blob
    /// <summary>
    /// The Snapshot Blob operation creates a read-only snapshot of a blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/snapshot-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>        
    procedure SnapshotBlob(var RequestObject: Codeunit "AZBSA Request Object")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Content: HttpContent;
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::SnapshotBlob);
        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(SnapshotOperationNotSuccessfulErr, RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Snapshot Blob

    // #region (PUT) Set Blob Tier
    /// <summary>
    /// The Set Blob Tier operation sets the access tier on a blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-tier
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="BlobAccessTier">The Access Tier the blob should be set to.</param>
    procedure SetBlobTier(var RequestObject: Codeunit "AZBSA Request Object"; BlobAccessTier: Enum "AZBSA Blob Access Tier")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::SetBlobTier);
        RequestObject.SetBlobAccessTierHeader(BlobAccessTier);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(BlobTierOperationNotSuccessfulErr, BlobAccessTier, RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Set Blob Tier

    // #region (PUT) Put Page
    /// <summary>
    /// The Put Page operation writes a range of pages to a page blob.
    /// 'Update' will add the specified content to the defined range
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-page
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="StartRange">Specifies the start of the range of bytes to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes to be written as a page</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the page</param>
    procedure PutPageUpdate(var RequestObject: Codeunit "AZBSA Request Object"; StartRange: Integer; EndRange: Integer; SourceContent: Variant)
    var
        PageWriteOption: Enum "AZBSA Page Write Option";
    begin
        PutPage(RequestObject, StartRange, EndRange, SourceContent, PageWriteOption::Update);
    end;

    /// <summary>
    /// The Put Page operation writes a range of pages to a page blob.
    /// 'Clear' will empty the defined range
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-page
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="StartRange">Specifies the start of the range of bytes to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes to be cleared</param>    
    procedure PutPageClear(var RequestObject: Codeunit "AZBSA Request Object"; StartRange: Integer; EndRange: Integer)
    var
        PageWriteOption: Enum "AZBSA Page Write Option";
    begin
        PutPage(RequestObject, StartRange, EndRange, '', PageWriteOption::Clear);
    end;

    /// <summary>
    /// The Put Page operation writes a range of pages to a page blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-page
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="StartRange">Specifies the start of the range of bytes to be written as a page</param>
    /// <param name="EndRange">Specifies the end of the range of bytes to be written as a page</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the page</param>
    /// <param name="PageWriteOption">Either 'update' or 'clear'; defines if content is added to or cleared from a page</param>
    procedure PutPage(var RequestObject: Codeunit "AZBSA Request Object"; StartRange: Integer; EndRange: Integer; SourceContent: Variant; PageWriteOption: Enum "AZBSA Page Write Option")
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        Content: HttpContent;
        Headers: HttpHeaders;
        SourceStream: InStream;
        SourceText: Text;
    begin
        RequestObject.SetOperation(Operation::PutPage);
        RequestObject.SetPageWriteOptionHeader(PageWriteOption);
        RequestObject.SetRangeHeader(StartRange, EndRange);
        if PageWriteOption <> PageWriteOption::Clear then
            case true of
                SourceContent.IsInStream():
                    begin
                        SourceStream := SourceContent;
                        WebRequestHelper.AddBlobPutBlockBlobContentHeaders(Content, RequestObject, SourceStream);
                    end;
                SourceContent.IsText():
                    begin
                        SourceText := SourceContent;
                        WebRequestHelper.AddBlobPutBlockBlobContentHeaders(Content, RequestObject, SourceText);
                    end;
            end;
        Content.GetHeaders(Headers);
        // TODO: Check if it would be better to create a helper-function, that allows adding Content without the unnecessary headers
        RequestObject.RemoveHeader(Headers, 'x-ms-blob-type'); // was automatically added in AddBlobPutBlockBlobContentHeaders, needs to removed
        RequestObject.RemoveHeader(Headers, 'Content-Type'); // was automatically added in AddBlobPutBlockBlobContentHeaders, needs to removed
        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(PutPageOperationNotSuccessfulErr, RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Put Page

    // #region (GET) Get Page Ranges
    /// <summary>
    /// The Get Page Ranges operation returns the list of valid page ranges for a page blob or snapshot of a page blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-page-ranges
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="PageRanges">A Dictionairy containing the result in structured form.</param>
    procedure GetPageRanges(var RequestObject: Codeunit "AZBSA Request Object"; var PageRanges: Dictionary of [Integer, Integer])
    var
        HelperLibrary: Codeunit "AZBSA Helper Library";
        Document: XmlDocument;
    begin
        Document := GetPageRanges(RequestObject);
        HelperLibrary.PageRangesResultToDictionairy(Document, PageRanges);
    end;

    /// <summary>
    /// The Get Page Ranges operation returns the list of valid page ranges for a page blob or snapshot of a page blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-page-ranges
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <returns>XmlDocument containing the Page ranges</returns>
    procedure GetPageRanges(var RequestObject: Codeunit "AZBSA Request Object"): XmlDocument
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        FormatHelper: Codeunit "AZBSA Format Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetPageRanges);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;
    // #endregion (GET) Get Page Ranges

    // #region (PUT) Incremental Copy Blob
    /// <summary>
    /// The Incremental Copy Blob operation copies a snapshot of the source page blob to a destination page blob. 
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/incremental-copy-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="SourceUri">Specifies the name of the source page blob snapshot.</param>
    procedure IncrementalCopyBlob(var RequestObject: Codeunit "AZBSA Request Object"; SourceUri: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::IncrementalCopyBlob);
        RequestObject.SetCopySourceNameHeader(SourceUri);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(IncrementalCopyOperationNotSuccessfulErr, SourceUri, RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Incremental Copy Blob

    // #region (PUT) Put Block
    /// <summary>
    /// https://docs.microsoft.com/en-us/rest/api/storageservices/put-block
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the page</param>
    /// <param name="BlockId">A valid Base64 string value that identifies the block</param>
    procedure PutBlock(var RequestObject: Codeunit "AZBSA Request Object"; SourceContent: Variant)
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
    begin
        PutBlock(RequestObject, SourceContent, FormatHelper.GetBase64BlockId());
    end;
    /// <summary>
    /// https://docs.microsoft.com/en-us/rest/api/storageservices/put-block
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="SourceContent">Variant containing the content that should be added to the page</param>
    /// <param name="BlockId">A valid Base64 string value that identifies the block</param>
    procedure PutBlock(var RequestObject: Codeunit "AZBSA Request Object"; SourceContent: Variant; BlockId: Text)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        Content: HttpContent;
        Headers: HttpHeaders;
        SourceStream: InStream;
        SourceText: Text;
    begin
        RequestObject.SetOperation(Operation::PutBlock);
        RequestObject.SetBlockIdParameter(BlockId);
        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    WebRequestHelper.AddBlobPutBlockBlobContentHeaders(Content, RequestObject, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    WebRequestHelper.AddBlobPutBlockBlobContentHeaders(Content, RequestObject, SourceText);
                end;
        end;
        Content.GetHeaders(Headers);
        // TODO: Check if it would be better to create a helper-function, that allows adding Content without the unnecessary headers
        RequestObject.RemoveHeader(Headers, 'x-ms-blob-type'); // was automatically added in AddBlobPutBlockBlobContentHeaders, needs to removed
        RequestObject.RemoveHeader(Headers, 'Content-Type'); // was automatically added in AddBlobPutBlockBlobContentHeaders, needs to removed

        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(PutBlockOperationNotSuccessfulErr, RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Put Block

    // #region (GET) Get Block List
    /// <summary>
    /// The Get Block List operation retrieves the list of blocks that have been uploaded as part of a block blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-block-list
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="BlockListType">Specifies whether to return the list of committed blocks, the list of uncommitted blocks, or both lists together.</param>
    /// <param name="CommitedBlocks">Dictionary of [Text, Integer] containing the list of commited blocks (BLockId and Size)</param>
    /// <param name="UncommitedBlocks">Dictionary of [Text, Integer] containing the list of uncommited blocks (BLockId and Size)</param>
    procedure GetBlockList(var RequestObject: Codeunit "AZBSA Request Object"; BlockListType: Enum "AZBSA Block List Type"; var CommitedBlocks: Dictionary of [Text, Integer]; var UncommitedBlocks: Dictionary of [Text, Integer])
    var
        HelperLibrary: Codeunit "AZBSA Helper Library";
        Document: XmlDocument;
    begin
        Document := GetBlockList(RequestObject, BlockListType);
        HelperLibrary.BlockListResultToDictionary(Document, CommitedBlocks, UncommitedBlocks);
    end;

    /// <summary>
    /// The Get Block List operation retrieves the list of blocks that have been uploaded as part of a block blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-block-list
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <returns>XmlDocument containing the Block List</returns>
    procedure GetBlockList(var RequestObject: Codeunit "AZBSA Request Object"): XmlDocument
    var
        BlockListType: Enum "AZBSA Block List Type";
    begin
        exit(GetBlockList(RequestObject, BlockListType::committed)); // default API value is "committed"
    end;

    /// <summary>
    /// The Get Block List operation retrieves the list of blocks that have been uploaded as part of a block blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-block-list
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="BlockListType">Specifies whether to return the list of committed blocks, the list of uncommitted blocks, or both lists together.</param>
    /// <returns>XmlDocument containing the Block List</returns>
    procedure GetBlockList(var RequestObject: Codeunit "AZBSA Request Object"; BlockListType: Enum "AZBSA Block List Type"): XmlDocument
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        FormatHelper: Codeunit "AZBSA Format Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        ResponseText: Text;
    begin
        RequestObject.SetOperation(Operation::GetBlockList);
        RequestObject.SetBlockListTypeParameter(BlockListType);
        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;
    // #endregion (GET) Get Block List

    // #region (PUT) Put Block List
    /// <summary>
    /// The Put Block List operation writes a blob by specifying the list of block IDs that make up the blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-list
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="CommitedBlocks">Dictionary of [Text, Integer] containing the list of commited blocks that should be put to the Blob</param>
    /// <param name="UncommitedBlocks">Dictionary of [Text, Integer] containing the list of uncommited blocks that should be put to the Blob</param>
    procedure PutBlockList(var RequestObject: Codeunit "AZBSA Request Object"; CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer])
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        BlockList: Dictionary of [Text, Text];
        BlockListAsXml: XmlDocument;
    begin
        FormatHelper.BlockDictionariesToBlockListDictionary(CommitedBlocks, UncommitedBlocks, BlockList, false);
        BlockListAsXml := FormatHelper.BlockListDictionaryToXmlDocument(BlockList);
        PutBlockList(RequestObject, BlockListAsXml);
    end;
    /// <summary>
    /// The Put Block List operation writes a blob by specifying the list of block IDs that make up the blob.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-list
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure PutBlockList(var RequestObject: Codeunit "AZBSA Request Object"; BlockList: XmlDocument)
    var
        WebRequestHelper: Codeunit "AZBSA Web Request Helper";
        Operation: Enum "AZBSA Blob Storage Operation";
        Content: HttpContent;
    begin
        RequestObject.SetOperation(Operation::PutBlockList);
        WebRequestHelper.AddBlockListContent(Content, RequestObject, BlockList);
        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(PutBlockListOperationNotSuccessfulErr, RequestObject.GetBlobName()));
    end;
    // #endregion (PUT) Put Block List
}