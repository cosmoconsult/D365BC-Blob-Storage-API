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
        DeleteBlobOperationNotSuccessfulErr: Label 'Could not Blob %1 in container %2.', Comment = '%1 = Blob Name; %2 = Container Name';
        UploadBlobOperationNotSuccessfulErr: Label 'Could not upload %1 to %2', Comment = '%1 = Blob Name; %2 = Container Name';
        LeaseOperationNotSuccessfulErr: Label 'Could not %1 lease for %2 %3.', Comment = '%1 = Lease Action, %2 = Type (Container or Blob), %3 = Name';
        CopyOperationNotSuccessfulErr: Label 'Could not copy %1 to %2.', Comment = '%1 = Source, %2 = Desctination';
        AbortCopyOperationNotSuccessfulErr: Label 'Could not abort copy operation for %1.', Comment = '%1 = Blobname';
        PropertiesOperationNotSuccessfulErr: Label 'Could not %1%2 Properties.', Comment = '%1 = Get/Set, %2 = Service/"", ';
        MetadataOperationNotSuccessfulErr: Label 'Could not %1%2 Metadata.', Comment = '%1 = Get/Set, %2 = Container/Blob, ';
        ContainerAclOperationNotSuccessfulErr: Label 'Could not %1 Container ACL.', Comment = '%1 = Get/Set ';
        ParameterDurationErr: Label 'Duration can be -1 (for infinite) or between 15 and 60 seconds. Parameter Value: %1', Comment = '%1 = Current Value';
        ParameterMissingErr: Label 'You need to specify %1 (%2)', Comment = '%1 = Variable Name, %2 = Header Identifer';

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
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
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
    // #endregion

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
        WebRequestHelper.DeleteOperation(RequestObject, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName()));
    end;

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
    // #endregion (GET) Get Get Account Information
}