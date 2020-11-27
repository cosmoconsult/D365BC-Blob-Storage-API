// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 89001 "AZBSA Request Object"
{
    trigger OnRun()
    begin

    end;

    var
        AuthType: Enum "AZBSA Authorization Type";
        ApiVersion: Enum "AZBSA API Version";
        Secret: Text;
        StorageAccountName: Text;
        ContainerName: Text;
        BlobName: Text;
        Operation: Enum "AZBSA Blob Storage Operation";
        HeaderValues: Dictionary of [Text, Text];
        OptionalHeaderValues: Dictionary of [Text, Text];
        OptionalUriParameters: Dictionary of [Text, Text];
        //KeyValuePairLbl: Label '%1:%2', Comment = '%1 = Key; %2 = Value';
        Response: HttpResponseMessage;

    // #region Initialize Requests
    procedure InitializeRequest(NewStorageAccountName: Text)
    begin
        InitializeRequest(NewStorageAccountName, '');
    end;

    procedure InitializeRequest(NewStorageAccountName: Text; NewContainerName: Text)
    begin
        InitializeRequest(NewStorageAccountName, NewContainerName, '');
    end;

    procedure InitializeRequest(NewStorageAccountName: Text; NewContainerName: Text; NewBlobName: Text)
    begin
        InitializeRequest(NewStorageAccountName, NewContainerName, NewBlobName, ApiVersion::"2017-04-17");
    end;

    procedure InitializeRequest(NewStorageAccountName: Text; NewContainerName: Text; NewBlobName: Text; NewApiVersion: Enum "AZBSA API Version")
    begin
        StorageAccountName := NewStorageAccountName;
        ContainerName := NewContainerName;
        BlobName := NewBlobName;
        ApiVersion := NewApiVersion;
    end;
    // #endregion Initialize Requests

    procedure InitializeAuthorization(NewAuthType: Enum "AZBSA Authorization Type"; NewSecret: Text)
    begin
        AuthType := NewAuthType;
        Secret := NewSecret;
    end;

    // #region Set/Get Globals
    procedure SetStorageAccountName(NewStorageAccountName: Text)
    begin
        StorageAccountName := NewStorageAccountName;
    end;

    procedure GetStorageAccountName(): Text
    begin
        exit(StorageAccountName);
    end;

    procedure SetContainerName(NewContainerName: Text)
    begin
        ContainerName := NewContainerName;
    end;

    procedure GetContainerName(): Text
    begin
        exit(ContainerName);
    end;

    procedure SetBlobName(NewBlobName: Text)
    begin
        BlobName := NewBlobName;
    end;

    procedure GetBlobName(): Text
    begin
        exit(BlobName);
    end;

    procedure SetOperation(NewOperation: Enum "AZBSA Blob Storage Operation")
    begin
        Operation := NewOperation;
    end;

    procedure GetOperation(): Enum "AZBSA Blob Storage Operation"
    begin
        exit(Operation);
    end;

    procedure SetAuthorizationType(NewAuthType: Enum "AZBSA Authorization Type")
    begin
        AuthType := NewAuthType;
    end;

    procedure GetAuthorizationType(): Enum "AZBSA Authorization Type"
    begin
        exit(AuthType);
    end;

    procedure SetSecret(NewSecret: Text)
    begin
        Secret := NewSecret;
    end;

    procedure GetSecret(): Text
    begin
        exit(Secret);
    end;

    procedure SetApiVersion(NewApiVersion: Enum "AZBSA API Version")
    begin
        ApiVersion := NewApiVersion;
    end;

    procedure GetApiVersion(): Enum "AZBSA API Version"
    begin
        exit(ApiVersion);
    end;

    procedure SetHttpResponse(NewResponse: HttpResponseMessage)
    begin
        Response := NewResponse;
    end;

    procedure GetHttpResponse(var NewResponse: HttpResponseMessage)
    begin
        NewResponse := Response;
    end;

    procedure GetHttpResponseAsText(): Text;
    var
        ResponseText: Text;
    begin
        Response.Content.ReadAs(ResponseText);
        exit(ResponseText)
    end;

    procedure GetHttpResponseStatusCode(): Integer
    begin
        exit(Response.HttpStatusCode());
    end;

    procedure GetHttpResponseIsSuccessStatusCode(): Boolean
    begin
        exit(Response.IsSuccessStatusCode);
    end;
    // #endregion Set/Get Globals

    procedure AddOptionalHeader("Key": Text; "Value": Text)
    begin
        if OptionalHeaderValues.ContainsKey("Key") then
            OptionalHeaderValues.Remove("Key");
        OptionalHeaderValues.Add("Key", "Value");
    end;

    procedure AddHeader(var Headers: HttpHeaders; "Key": Text; "Value": Text)
    begin
        if HeaderValues.ContainsKey("Key") then
            HeaderValues.Remove("Key");
        HeaderValues.Add("Key", "Value");
        if Headers.Contains("Key") then
            Headers.Remove("Key");
        Headers.Add("Key", "Value");
    end;

    procedure ClearHeaders()
    begin
        Clear(HeaderValues);
    end;

    // #region Optional Uri Parameters
    procedure AddOptionalUriParameter("Key": Text; "Value": Text)
    begin
        if OptionalUriParameters.ContainsKey("Key") then
            OptionalUriParameters.Remove("Key");
        OptionalUriParameters.Add("Key", "Value");
    end;

    procedure AddOptionalUriParameter(NewOptionalUriParameters: Dictionary of [Text, Text])
    begin
        OptionalUriParameters := NewOptionalUriParameters;
    end;

    /// <summary>
    /// Sets the optional timeout value for the Request
    /// </summary>
    /// <param name="Value">Timeout in seconds. Most operations have a max. limit of 30 seconds. For  more Information see: https://docs.microsoft.com/en-us/rest/api/storageservices/setting-timeouts-for-blob-service-operations</param>
    procedure SetTimeoutParameter("Value": Integer)
    begin
        AddOptionalUriParameter('timeout', Format("Value"));
    end;

    /// <summary>
    /// The versionid parameter is an opaque DateTime value that, when present, specifies the Version of the blob to retrieve.
    /// </summary>
    /// <param name="Value">The DateTime identifying the Version</param>
    procedure SetVersionIdParameter("Value": DateTime)
    begin
        // TODO: Add Version check, currently target API is not supported
        // Only allowed for API-Version 2019-12-12 and newer
        AddOptionalUriParameter('versionid', Format("Value")); // TODO: Check DateTime-format for URI
    end;

    /// <summary>
    /// The snapshot parameter is an opaque DateTime value that, when present, specifies the blob snapshot to retrieve. 
    /// </summary>
    /// <param name="Value">The DateTime identifying the Snapshot</param>
    procedure SetSnapshotParameter("Value": DateTime)
    begin
        AddOptionalUriParameter('snapshot', Format("Value")); // TODO: Check DateTime-format for URI
    end;

    /// <summary>
    /// Filters the results to return only blobs whose names begin with the specified prefix.
    /// </summary>
    /// <param name="Value">Prefix to search for</param>
    procedure SetPrefixParameter("Value": Text)
    begin
        AddOptionalUriParameter('prefix', "Value");
    end;

    /// <summary>
    /// When the request includes this parameter, the operation returns a BlobPrefix element in the response body 
    /// that acts as a placeholder for all blobs whose names begin with the same substring up to the appearance of the delimiter character. 
    /// The delimiter may be a single character or a string.
    /// </summary>
    /// <param name="Value">Delimiting character/string</param>
    procedure SetDelimiterParameter("Value": Text)
    begin
        AddOptionalUriParameter('delimiter', "Value");
    end;

    /// <summary>
    /// Specifies the maximum number of blobs to return
    /// </summary>
    /// <param name="Value">Max. number of results to return. Must be positive, must not be greater than 5000</param>
    procedure SetMaxResultsParameter("Value": Integer)
    begin
        AddOptionalUriParameter('maxresults', Format("Value"));
    end;

    // #endregion Optional Uri Parameters

    // #region Uri generation
    procedure ConstructUri(): Text
    var
        URIHelepr: Codeunit "AZBSA URI Helper";
    begin
        URIHelepr.SetOptionalUriParameter(OptionalUriParameters);
        exit(URIHelepr.ConstructUri(StorageAccountName, ContainerName, BlobName, Operation, AuthType, Secret));
    end;
    // #endregion Uri generation

    // #region Shared Key Signature Generation

    procedure GetSharedKeySignature(HttpRequestType: Enum "Http Request Type"): Text
    var
        ReqAuthAccessKey: Codeunit "AZBSA Req. Auth. Access Key";
    begin
        ReqAuthAccessKey.SetHeaderValues(HeaderValues);
        exit(ReqAuthAccessKey.GetSharedKeySignature(HttpRequestType, StorageAccountName, ConstructUri(), Secret));
    end;
    // #endregion Shared Key Signature Generation
}