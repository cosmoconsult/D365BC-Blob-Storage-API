// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 89004 "AZBSA Web Request Helper"
{
    trigger OnRun()
    begin

    end;

    var
        ContentLengthLbl: Label '%1', Comment = '%1 = Length';
        ReadResponseFailedErr: Label 'Could not read response.';
        IntitialGetFailedErr: Label 'Could not connect to %1.\\Response Code: %2 %3', Comment = '%1 = Base URL; %2 = Status Code; %3 = Reason Phrase';
        HttpResponseInfoErr: Label '%1.\\Response Code: %2 %3', Comment = '%1 = Default Error Message ; %2 = Status Code; %3 = Reason Phrase';
        DeleteContainerOperationNotSuccessfulErr: Label 'Could not delete container %1.', Comment = '%1 = Container Name';

    // #region GET-Request
    procedure GetResponseAsText(var RequestObject: Codeunit "AZBSA Request Object"; var ResponseText: Text)
    var
        Response: HttpResponseMessage;
    begin
        GetResponse(RequestObject, Response);

        if not Response.Content.ReadAs(ResponseText) then
            Error(ReadResponseFailedErr);
    end;

    procedure GetResponseAsStream(var RequestObject: Codeunit "AZBSA Request Object"; var Stream: InStream)
    var
        Response: HttpResponseMessage;
    begin
        GetResponse(RequestObject, Response);

        if not Response.Content.ReadAs(Stream) then
            Error(ReadResponseFailedErr);
    end;

    local procedure GetResponse(var RequestObject: Codeunit "AZBSA Request Object"; var Response: HttpResponseMessage)
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::GET, Client, RequestObject);

        RequestMsg.Method(Format(HttpRequestType::GET));
        RequestMsg.SetRequestUri(RequestObject.ConstructUri());
        if not Client.Send(RequestMsg, Response) then
            Error(IntitialGetFailedErr, RequestObject.ConstructUri(), Response.HttpStatusCode, Response.ReasonPhrase);
        RequestObject.SetHttpResponse(Response);
        if not Response.IsSuccessStatusCode then
            Error(IntitialGetFailedErr, FormatHelper.RemoveSasTokenParameterFromUrl(RequestObject.ConstructUri()), Response.HttpStatusCode, Response.ReasonPhrase);
    end;
    // #endregion GET-Request

    // #region PUT-Request
    procedure PutOperation(var RequestObject: Codeunit "AZBSA Request Object"; OperationNotSuccessfulErr: Text)
    var
        Content: HttpContent;
    begin
        PutOperation(RequestObject, Content, OperationNotSuccessfulErr);
    end;

    procedure PutOperation(var RequestObject: Codeunit "AZBSA Request Object"; Content: HttpContent; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        PutOperation(RequestObject, Content, Response, OperationNotSuccessfulErr);
    end;

    local procedure PutOperation(var RequestObject: Codeunit "AZBSA Request Object"; Content: HttpContent; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
        DebugText: Text;
    begin
        HandleHeaders(HttpRequestType::PUT, Client, RequestObject);
        // Prepare HttpRequestMessage
        RequestMsg.Method(Format(HttpRequestType::PUT));
        if ContentSet(Content) or HandleContentHeaders(Content, RequestObject) then
            RequestMsg.Content := Content;
        RequestMsg.SetRequestUri(RequestObject.ConstructUri());

        // Send Request    
        Client.Send(RequestMsg, Response);
        RequestObject.SetHttpResponse(Response);
        Response.Content.ReadAs(DebugText);
        if not Response.IsSuccessStatusCode then
            Error(HttpResponseInfoErr, OperationNotSuccessfulErr, Response.HttpStatusCode, Response.ReasonPhrase);
    end;

    local procedure ContentSet(Content: HttpContent): Boolean
    var
        VarContent: Text;
    begin
        Content.ReadAs(VarContent);
        if StrLen(VarContent) > 0 then
            exit(true);

        exit(VarContent <> '');
    end;
    // #endregion PUT-Request

    // #region DELETE-Request
    procedure DeleteOperation(var RequestObject: Codeunit "AZBSA Request Object")
    var
        Response: HttpResponseMessage;
    begin
        DeleteOperation(RequestObject, Response, StrSubstNo(DeleteContainerOperationNotSuccessfulErr, RequestObject.GetContainerName()));
    end;

    procedure DeleteOperation(var RequestObject: Codeunit "AZBSA Request Object"; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        DeleteOperation(RequestObject, Response, OperationNotSuccessfulErr);
    end;

    local procedure DeleteOperation(var RequestObject: Codeunit "AZBSA Request Object"; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::DELETE, Client, RequestObject);
        // Prepare HttpRequestMessage
        RequestMsg.Method(Format(HttpRequestType::DELETE));
        RequestMsg.SetRequestUri(RequestObject.ConstructUri());
        // Send Request    
        Client.Send(RequestMsg, Response);
        RequestObject.SetHttpResponse(Response);
        if not Response.IsSuccessStatusCode then
            Error(HttpResponseInfoErr, OperationNotSuccessfulErr, Response.HttpStatusCode, Response.ReasonPhrase);
    end;
    // #endregion DELETE-Request
    // #region POST-Request
    procedure PostOperation(var RequestObject: Codeunit "AZBSA Request Object"; OperationNotSuccessfulErr: Text)
    var
        Content: HttpContent;
    begin
        PostOperation(RequestObject, Content, OperationNotSuccessfulErr);
    end;

    procedure PostOperation(var RequestObject: Codeunit "AZBSA Request Object"; Content: HttpContent; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        PostOperation(RequestObject, Content, Response, OperationNotSuccessfulErr);
    end;

    local procedure PostOperation(var RequestObject: Codeunit "AZBSA Request Object"; Content: HttpContent; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::POST, Client, RequestObject);
        // Prepare HttpRequestMessage
        RequestMsg.Method(Format(HttpRequestType::POST));
        if ContentSet(Content) or HandleContentHeaders(Content, RequestObject) then
            RequestMsg.Content := Content;
        RequestMsg.SetRequestUri(RequestObject.ConstructUri());

        // Send Request    
        Client.Send(RequestMsg, Response);
        RequestObject.SetHttpResponse(Response);
        if not Response.IsSuccessStatusCode then
            Error(HttpResponseInfoErr, OperationNotSuccessfulErr, Response.HttpStatusCode, Response.ReasonPhrase);
    end;
    // #endregion POST-Request

    // #region OPTIONS-Request
    procedure OptionsOperation(var RequestObject: Codeunit "AZBSA Request Object"; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        OptionsOperation(RequestObject, Response, OperationNotSuccessfulErr);
    end;

    procedure OptionsOperation(var RequestObject: Codeunit "AZBSA Request Object"; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders('OPTIONS', Client, RequestObject);
        // Prepare HttpRequestMessage
        RequestMsg.Method('OPTIONS');
        RequestMsg.SetRequestUri(RequestObject.ConstructUri());

        // Send Request    
        Client.Send(RequestMsg, Response);
        RequestObject.SetHttpResponse(Response);
        if not Response.IsSuccessStatusCode then
            Error(HttpResponseInfoErr, OperationNotSuccessfulErr, Response.HttpStatusCode, Response.ReasonPhrase);
    end;
    // #endregion OPTIONS-Request

    // #region HTTP Header Helper
    procedure AddBlobPutBlockBlobContentHeaders(var Content: HttpContent; RequestObject: Codeunit "AZBSA Request Object"; var SourceStream: InStream)
    var
        BlobType: Enum "AZBSA Blob Type";
    begin
        AddBlobPutContentHeaders(Content, RequestObject, SourceStream, BlobType::BlockBlob)
    end;

    procedure AddBlobPutBlockBlobContentHeaders(var Content: HttpContent; RequestObject: Codeunit "AZBSA Request Object"; var SourceText: Text)
    var
        BlobType: Enum "AZBSA Blob Type";
    begin
        AddBlobPutContentHeaders(Content, RequestObject, SourceText, BlobType::BlockBlob)
    end;

    procedure AddBlobPutPageBlobContentHeaders(RequestObject: Codeunit "AZBSA Request Object"; ContentLength: Integer; ContentType: Text)
    var
        BlobType: Enum "AZBSA Blob Type";
        Content: HttpContent;
    begin
        if ContentLength = 0 then
            ContentLength := 512;
        AddBlobPutContentHeaders(Content, RequestObject, BlobType::PageBlob, ContentLength, ContentType)
    end;

    procedure AddBlobPutAppendBlobContentHeaders(RequestObject: Codeunit "AZBSA Request Object"; ContentType: Text)
    var
        BlobType: Enum "AZBSA Blob Type";
        Content: HttpContent;
    begin
        AddBlobPutContentHeaders(Content, RequestObject, BlobType::AppendBlob, 0, ContentType)
    end;

    local procedure AddBlobPutContentHeaders(var Content: HttpContent; RequestObject: Codeunit "AZBSA Request Object"; var SourceStream: InStream; BlobType: Enum "AZBSA Blob Type")
    var
        Length: Integer;
    begin
        // Do this before calling "GetStreamLength", because for some reason the system errors out with "Cannot access a closed Stream."
        Content.WriteFrom(SourceStream);

        Length := GetContentLength(SourceStream);

        AddBlobPutContentHeaders(Content, RequestObject, BlobType, Length, 'application/octet-stream');
    end;

    local procedure AddBlobPutContentHeaders(var Content: HttpContent; RequestObject: Codeunit "AZBSA Request Object"; var SourceText: Text; BlobType: Enum "AZBSA Blob Type")
    var
        Length: Integer;
    begin
        Content.WriteFrom(SourceText);

        Length := GetContentLength(SourceText);

        AddBlobPutContentHeaders(Content, RequestObject, BlobType, Length, 'text/plain; charset=UTF-8');
    end;

    local procedure AddBlobPutContentHeaders(var Content: HttpContent; RequestObject: Codeunit "AZBSA Request Object"; BlobType: Enum "AZBSA Blob Type"; ContentLength: Integer; ContentType: Text)
    var
        Headers: HttpHeaders;
    begin
        if ContentType = '' then
            ContentType := 'application/octet-stream';
        Content.GetHeaders(Headers);
        RequestObject.AddHeader(Headers, 'Content-Type', ContentType);
        case BlobType of
            BlobType::PageBlob:
                begin
                    RequestObject.AddHeader(Headers, 'x-ms-blob-content-length', StrSubstNo(ContentLengthLbl, ContentLength));
                    RequestObject.AddHeader(Headers, 'Content-Length', StrSubstNo(ContentLengthLbl, 0));
                end;
            else
                RequestObject.AddHeader(Headers, 'Content-Length', StrSubstNo(ContentLengthLbl, ContentLength));
        end;
        RequestObject.AddHeader(Headers, 'x-ms-blob-type', Format(BlobType));
    end;

    procedure AddServicePropertiesContent(var Content: HttpContent; var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, RequestObject, Document);
    end;

    procedure AddContainerAclDefinition(var Content: HttpContent; var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, RequestObject, Document);
    end;

    procedure AddTagsContent(var Content: HttpContent; var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, RequestObject, Document);
    end;

    procedure AddBlockListContent(var Content: HttpContent; var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, RequestObject, Document);
    end;

    procedure AddUserDelegationRequestContent(var Content: HttpContent; var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, RequestObject, Document);
    end;

    procedure AddQueryBlobContentRequestContent(var Content: HttpContent; var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, RequestObject, Document);
    end;

    local procedure AddXmlDocumentAsContent(var Content: HttpContent; var RequestObject: Codeunit "AZBSA Request Object"; Document: XmlDocument)
    var
        Headers: HttpHeaders;
        Length: Integer;
        DocumentAsText: Text;
    begin
        DocumentAsText := Format(Document);
        Length := StrLen(DocumentAsText);

        Content.WriteFrom(DocumentAsText);

        Content.GetHeaders(Headers);
        RequestObject.AddHeader(Headers, 'Content-Type', 'application/xml');
        RequestObject.AddHeader(Headers, 'Content-Length', Format(Length));
    end;

    local procedure HandleContentHeaders(var Content: HttpContent; var RequestObject: Codeunit "AZBSA Request Object"): Boolean
    var
        Headers: HttpHeaders;
        HeadersDictionary: Dictionary of [Text, Text];
        HeaderKey: Text;
        ContainsContentHeader: Boolean;
    begin
        Content.GetHeaders(Headers);
        RequestObject.GetSortedHeadersDictionary(HeadersDictionary);
        foreach HeaderKey in HeadersDictionary.Keys do
            if IsContentHeader(HeaderKey) then begin
                RequestObject.AddHeader(Headers, HeaderKey, HeadersDictionary.Get(HeaderKey));
                ContainsContentHeader := true;
            end;
        exit(ContainsContentHeader);
    end;

    local procedure HandleHeaders(HttpRequestType: Enum "Http Request Type"; var Client: HttpClient; var RequestObject: Codeunit "AZBSA Request Object")
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        UsedDateTimeText: Text;
        Headers: HttpHeaders;
        HeadersDictionary: Dictionary of [Text, Text];
        HeaderKey: Text;
        AuthType: enum "AZBSA Authorization Type";
    begin
        Headers := Client.DefaultRequestHeaders;
        // Add to all requests >>
        UsedDateTimeText := FormatHelper.GetRfc1123DateTime();
        RequestObject.AddHeader('x-ms-date', UsedDateTimeText);
        RequestObject.AddHeader('x-ms-version', Format(RequestObject.GetApiVersion()));
        // Add to all requests <<
        RequestObject.GetSortedHeadersDictionary(HeadersDictionary);
        RequestObject.SetHeaderValues(HeadersDictionary);
        foreach HeaderKey in HeadersDictionary.Keys do
            if not IsContentHeader(HeaderKey) then
                RequestObject.AddHeader(Headers, HeaderKey, HeadersDictionary.Get(HeaderKey));
        case RequestObject.GetAuthorizationType() of
            AuthType::SharedKey:
                RequestObject.AddHeader(Headers, 'Authorization', RequestObject.GetSharedKeySignature(HttpRequestType));
            AuthType::"AAD (Client Credentials)":
                RequestObject.AddHeader(Headers, 'Authorization', RequestObject.GetAADBearerToken(HttpRequestType));
        end;
    end;

    local procedure HandleHeaders(HttpRequestType: Text; var Client: HttpClient; var RequestObject: Codeunit "AZBSA Request Object")
    var
        Headers: HttpHeaders;
        HeadersDictionary: Dictionary of [Text, Text];
        HeaderKey: Text;
    begin
        // Only used right now for "OPTIONS"-request for Operation "PreflightBlobRequest"
        // For this Operation only some headers are necessary
        if HttpRequestType <> 'OPTIONS' then
            Error('You should use this function only for  OPTIONS-requests');

        Headers := Client.DefaultRequestHeaders;
        RequestObject.GetSortedHeadersDictionary(HeadersDictionary);
        RequestObject.SetHeaderValues(HeadersDictionary);
        foreach HeaderKey in HeadersDictionary.Keys do
            if not IsContentHeader(HeaderKey) then
                RequestObject.AddHeader(Headers, HeaderKey, HeadersDictionary.Get(HeaderKey));
    end;

    // #endregion
    local procedure IsContentHeader(HeaderKey: Text): Boolean
    begin
        if HeaderKey in ['Content-Type', 'x-ms-blob-content-length', 'Content-Length', 'x-ms-blob-type'] then // TODO: Check if these are all
            exit(true);
        exit(false);
    end;

    /// <summary>
    /// Retrieves the length of the given stream (used for "Content-Length" header in PUT-operations)
    /// </summary>
    /// <param name="SourceStream">The InStream for Request Body.</param>
    /// <returns>The length of the current stream</returns>
    local procedure GetContentLength(var SourceStream: InStream): Integer
    var
        MemoryStream: Codeunit "MemoryStream Wrapper";
        Length: Integer;
    begin
        // Load the memory stream and get the size
        MemoryStream.Create(0);
        MemoryStream.ReadFrom(SourceStream);
        Length := MemoryStream.Length();
        MemoryStream.GetInStream(SourceStream);
        MemoryStream.SetPosition(0);
        exit(Length);
    end;

    /// <summary>
    /// Retrieves the length of the given stream (used for "Content-Length" header in PUT-operations)
    /// </summary>
    /// <param name="SourceText">The Text for Request Body.</param>
    /// <returns>The length of the current stream</returns>
    local procedure GetContentLength(var SourceText: Text): Integer
    var
        Length: Integer;
    begin
        Length := StrLen(SourceText);
        exit(Length);
    end;
}