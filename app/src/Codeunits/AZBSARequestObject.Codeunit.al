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
        ResponseIsSet: Boolean;

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
        // TODO: Add "case NewOperation of" validation, to make sure that the minimum parameters (StorageAccountName, ContainerName, etc) are set here
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
        ResponseIsSet := true;
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

    procedure GetHttpResponseHeaders(var NewResponseHeaders: HttpHeaders)
    begin
        NewResponseHeaders := Response.Headers;
    end;

    procedure GetHeaderValueFromResponseHeaders(HeaderName: Text): Text
    var
        Headers: HttpHeaders;
        Values: array[100] of Text;
    begin
        if not ResponseIsSet then
            Error('HttpResponseMessage is not set');

        Headers := Response.Headers;
        if not Headers.GetValues(HeaderName, Values) then
            exit('');
        exit(Values[1]);
    end;

    procedure GetCopyIdFromResponseHeaders(): Text
    var
        ReturnValue: Text;
    begin
        ReturnValue := GetHeaderValueFromResponseHeaders('x-ms-copy-id');
        exit(ReturnValue);
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

    procedure AddOptionalHeader(NewReqHeaders: Dictionary of [Text, Text])
    begin
        OptionalHeaderValues := NewReqHeaders;
    end;

    procedure SetLeaseIdHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-lease-id', "Value");
    end;

    procedure SetSourceLeaseIdHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-source-lease-id', "Value");
    end;

    procedure SetLeaseActionHeader("Value": Text)
    begin
        // TODO: Check if "Value" should be an option or enum
        if not ("Value" in ['acquire', 'renew', 'change', 'release', 'break']) then
            Error('Not allowed value');
        AddOptionalHeader('x-ms-lease-action', "Value");
    end;

    procedure SetLeaseBreakPeriodHeader("Value": Integer)
    var
        LeaseAction: Text;
    begin
        if not OptionalHeaderValues.Get('x-ms-lease-action', LeaseAction) then
            Error('You need to specify the "x-ms-lease-action"-Header to use this');
        if LeaseAction <> 'break' then
            Error('"x-ms-lease-break-period" can only be set if "x-ms-lease-action" is "break"');
        AddOptionalHeader('x-ms-lease-break-period', Format("Value"));
    end;

    procedure SetLeaseDurationHeader("Value": Integer)
    var
        LeaseAction: Text;
    begin
        if not OptionalHeaderValues.Get('x-ms-lease-action', LeaseAction) then
            Error('You need to specify the "x-ms-lease-action"-Header to use this');
        if LeaseAction <> 'acquire' then
            Error('"x-ms-lease-duration" can only be set if "x-ms-lease-action" is "acquire"');
        AddOptionalHeader('x-ms-lease-duration', Format("Value"));
    end;

    procedure SetProposedLeaseIdHeader("Value": Text)
    var
        LeaseAction: Text;
    begin
        if not OptionalHeaderValues.Get('x-ms-lease-action', LeaseAction) then
            Error('You need to specify the "x-ms-lease-action"-Header to use this');
        if not (LeaseAction in ['acquire', 'change']) then
            Error('"x-ms-proposed-lease-id" can only be set if "x-ms-lease-action" is "acquire" or "change"');
        AddOptionalHeader('x-ms-proposed-lease-id', "Value");
    end;

    procedure SetOriginHeader("Value": Text)
    begin
        AddOptionalHeader('Origin', "Value");
    end;

    procedure SetClientRequestIdHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-client-request-id', "Value");
    end;

    procedure SetBlobPublicAccessHeader("Value": Text)
    begin
        // TODO: Check if "Value" should be an option or enum
        if not ("Value" in ['container', 'blob']) then
            Error('Not allowed value');
        AddOptionalHeader('x-ms-blob-public-access', "Value");
    end;

    procedure SetMetadataNameValueHeader("Name": Text; "Value": Text)
    var
        MetaKeyValuePairLbl: Label 'x-ms-meta-%1', Comment = '%1 = Key';
    begin
        AddOptionalHeader(StrSubstNo(MetaKeyValuePairLbl, "Name"), "Value");
    end;

    procedure SetTagsValueHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-tags', "Value"); // Supported in version 2019-12-12 and newer.
    end;

    procedure SetSourceIfModifiedSinceHeader("Value": DateTime)
    begin
        AddOptionalHeader('x-ms-source-if-modified-since', Format("Value")); // TODO: Check DateTime-format for URI
    end;

    procedure SetSourceIfUnmodifiedSinceHeader("Value": DateTime)
    begin
        AddOptionalHeader('x-ms-source-if-unmodified-since', Format("Value")); // TODO: Check DateTime-format for URI
    end;

    procedure SetSourceIfMatchHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-source-if-match', "Value");
    end;

    procedure SetSourceIfNoneMatchHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-source-if-none-match', "Value");
    end;

    procedure SetCopySourceNameHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-copy-source', "Value");
    end;

    procedure SetAccessTierHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-access-tier', "Value"); // valid values are Hot/Cool/Archive
    end;

    procedure SetRehydratePriorityHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-rehydrate-priority', "Value"); // Valid values are High/Standard
    end;

    procedure SetCopyActionHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-copy-action', "Value"); // Valid value is 'abort'
    end;

    procedure SetBlobExpiryOptionHeader("Value": Text)
    begin
        AddOptionalHeader('x-ms-expiry-option', "Value"); // Valid values are RelativeToCreation/RelativeToNow/Absolute/NeverExpire
    end;

    procedure SetBlobExpiryTimeHeader("Value": Integer)
    begin
        AddOptionalHeader('x-ms-expiry-time', Format("Value")); // Either an RFC 1123 datetime or miliseconds-value
    end;

    procedure SetBlobExpiryTimeHeader("Value": DateTime)
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
    begin
        AddOptionalHeader('x-ms-expiry-time', FormatHelper.GetRfc1123DateTime(("Value"))); // Either an RFC 1123 datetime or miliseconds-value
    end;

    procedure SetBlobAccessTierHeader("Value": Enum "AZBSA Blob Access Tier")
    begin
        AddOptionalHeader('x-ms-access-tier', Format("Value"));
    end;

    procedure SetHeaderValues(NewHeaderValues: Dictionary of [Text, Text])
    begin
        HeaderValues := NewHeaderValues;
    end;

    procedure AddHeader("Key": Text; "Value": Text)
    begin
        if HeaderValues.ContainsKey("Key") then
            HeaderValues.Remove("Key");
        HeaderValues.Add("Key", "Value");
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

    procedure RemoveHeader(var Headers: HttpHeaders; "Key": Text)
    var
    begin
        if HeaderValues.ContainsKey("Key") then
            HeaderValues.Remove("Key");
        if Headers.Contains("Key") then
            Headers.Remove("Key");
    end;

    procedure ClearHeaders()
    begin
        Clear(HeaderValues);
    end;

    procedure GetCombinedHeadersDictionary(var NewHeaders: Dictionary of [Text, Text])
    var
        HeaderKey: Text;
    begin
        Clear(NewHeaders);
        foreach HeaderKey in HeaderValues.Keys do
            NewHeaders.Add(HeaderKey, HeaderValues.Get(HeaderKey));

        foreach HeaderKey in OptionalHeaderValues.Keys do
            if not NewHeaders.ContainsKey(HeaderKey) then
                NewHeaders.Add(HeaderKey, OptionalHeaderValues.Get(HeaderKey));
    end;

    procedure GetSortedHeadersDictionary(var NewHeaders: Dictionary of [Text, Text])
    var
        SortTable: Record "AZBSA Temp. Sort Table";
        HeaderKey: Text;
    begin
        Clear(NewHeaders);
        SortTable.Reset();
        SortTable.DeleteAll();
        foreach HeaderKey in HeaderValues.Keys do begin
            SortTable."Key" := CopyStr(HeaderKey, 1, 250);
            SortTable."Value" := CopyStr(HeaderValues.Get(HeaderKey), 1, 250);
            SortTable.Insert();
        end;
        foreach HeaderKey in OptionalHeaderValues.Keys do begin
            SortTable."Key" := CopyStr(HeaderKey, 1, 250);
            SortTable."Value" := CopyStr(OptionalHeaderValues.Get(HeaderKey), 1, 250);
            if SortTable.Insert() then
                ;
        end;
        SortTable.SetCurrentKey("Key");
        SortTable.Ascending(true);

        if not SortTable.FindSet() then
            exit;
        repeat
            NewHeaders.Add(SortTable."Key", SortTable.Value);
        until SortTable.Next() = 0;
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
        ReqAuthAccessKey.SetApiVersion(ApiVersion);
        exit(ReqAuthAccessKey.GetSharedKeySignature(HttpRequestType, StorageAccountName, ConstructUri(), Secret));
    end;
    // #endregion Shared Key Signature Generation
}