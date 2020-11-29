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
}