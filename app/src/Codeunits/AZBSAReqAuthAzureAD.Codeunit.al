// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 89009 "AZBSA Req. Auth Azure AD"
{
    trigger OnRun()
    begin

    end;

    procedure GetBearerTokenAuthentication(HttpRequestType: Enum "Http Request Type"; StorageAccount: Text; UriString: Text; ClientID: Text; ClientSecret: Text; TenantId: Text): Text
    var
        Token: Text;
        SignaturePlaceHolderLbl: Label 'Bearer %1', Comment = '%1 = Token';
    begin
        if ClientSecret = '' then
            Error('This should not happen');

        Token := AcquireToken(ClientID, ClientSecret, TenantId);
        exit(StrSubstNo(SignaturePlaceHolderLbl, Token));
    end;

    local procedure AcquireToken(ClientID: Text; ClientSecret: Text; TenantId: Text): Text
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        Content: HttpContent;
        ResponseContent: HttpContent;
        ContentAsText: Text;
        HttpRequestType: Enum "Http Request Type";
        AadLoginUrlLbl: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/token', Comment = '%1 = Tenant ID';
    begin
        PrepareOAuthBody(ClientID, ClientSecret, Content);
        RequestMsg.Method(Format(HttpRequestType::POST));
        RequestMsg.Content(Content);
        RequestMsg.SetRequestUri(StrSubstNo(AadLoginUrlLbl, TenantId));

        Client.Send(RequestMsg, ResponseMsg);
        if not ResponseMsg.IsSuccessStatusCode then
            Error('Error acquiring Token. Status Code: %1 Message: %2', ResponseMsg.HttpStatusCode, ResponseMsg.ReasonPhrase);
        ResponseContent := ResponseMsg.Content;
        ResponseContent.ReadAs(ContentAsText);
        exit(GetTokenFromResponseContent(ContentAsText));
    end;

    local procedure PrepareOAuthBody(ClientID: Text; ClientSecret: Text; var Content: HttpContent): Text
    var
        Headers: HttpHeaders;
        ContentAsText: Text;
    begin
        ContentAsText := 'client_id=' + ClientID;
        ContentAsText += '&scope=https%3A%2F%2Fstorage.azure.com%2F.default';
        ContentAsText += '&client_secret=' + ClientSecret;
        ContentAsText += '&grant_type=client_credentials';
        Content.WriteFrom(ContentAsText);
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/x-www-form-urlencoded');
    end;

    local procedure GetTokenFromResponseContent(ContentAsText: Text): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        Token: Text;
    begin
        JObject.ReadFrom(ContentAsText);
        JObject.Get('access_token', JToken);
        JToken.WriteTo(Token);
        Token := Token.Replace('"', '');
        exit(Token);
    end;
}