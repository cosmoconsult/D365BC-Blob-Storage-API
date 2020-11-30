// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 89005 "AZBSA Req. Auth. Access Key"
{
    Access = Internal;

    trigger OnRun()
    begin

    end;

    var
        HeaderValues: Dictionary of [Text, Text];
        OptionalHeaderValues: Dictionary of [Text, Text];
        KeyValuePairLbl: Label '%1:%2', Comment = '%1 = Key; %2 = Value';

    procedure SetHeaderValues(NewHeaderValues: Dictionary of [Text, Text])
    begin
        HeaderValues := NewHeaderValues;
    end;

    procedure SetOptionalHeaderValues(NewOptionalHeaderValues: Dictionary of [Text, Text])
    begin
        OptionalHeaderValues := NewOptionalHeaderValues;
    end;
    // #region Shared Key Signature Generation

    procedure GetSharedKeySignature(HttpRequestType: Enum "Http Request Type"; StorageAccount: Text; UriString: Text; Secret: Text): Text
    var
        StringToSign: Text;
        Signature: Text;
        SignaturePlaceHolderLbl: Label 'SharedKey %1:%2', Comment = '%1 = Account Name; %2 = Calculated Signature';
    begin
        if Secret = '' then
            Error('This should not happen');

        StringToSign := CreateStringToSign(HttpRequestType, StorageAccount, UriString);
        Signature := GetAccessKeyHashCode(StringToSign, Secret);
        exit(StrSubstNo(SignaturePlaceHolderLbl, StorageAccount, Signature));
    end;

    local procedure CreateStringToSign(HttpRequestType: Enum "Http Request Type"; StorageAccount: Text; UriString: Text): Text
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        StringToSign: Text;
    begin
        // TODO: Add Handling-structure for different API-versions
        StringToSign += Format(HttpRequestType) + FormatHelper.GetNewLineCharacter();
        StringToSign += GetHeaderValueOrEmpty('Content-Encoding') + FormatHelper.GetNewLineCharacter(); // Content-Encoding
        StringToSign += GetHeaderValueOrEmpty('Content-Language') + FormatHelper.GetNewLineCharacter(); // Content-Language
        StringToSign += GetHeaderValueOrEmpty('Content-Length') + FormatHelper.GetNewLineCharacter(); // Content-Length
        StringToSign += GetHeaderValueOrEmpty('Content-MD5') + FormatHelper.GetNewLineCharacter(); // Content-MD5
        StringToSign += GetHeaderValueOrEmpty('Content-Type') + FormatHelper.GetNewLineCharacter(); // Content-Type
        StringToSign += GetHeaderValueOrEmpty('Date') + FormatHelper.GetNewLineCharacter(); // Date
        StringToSign += GetHeaderValueOrEmpty('If-Modified-Since') + FormatHelper.GetNewLineCharacter(); // If-Modified-Since
        StringToSign += GetHeaderValueOrEmpty('If-Match') + FormatHelper.GetNewLineCharacter(); // If-Match
        StringToSign += GetHeaderValueOrEmpty('If-None-Match') + FormatHelper.GetNewLineCharacter(); // If-None-Match
        StringToSign += GetHeaderValueOrEmpty('If-Unmodified-Since') + FormatHelper.GetNewLineCharacter(); // If-Unmodified-Since
        StringToSign += GetHeaderValueOrEmpty('Range') + FormatHelper.GetNewLineCharacter(); // Range        
        StringToSign += GetCanonicalizedHeaders(HeaderValues) + FormatHelper.GetNewLineCharacter();
        StringToSign += GetCanonicalizedResource(StorageAccount, UriString);
        exit(StringToSign);
    end;

    local procedure GetHeaderValueOrEmpty(HeaderKey: Text): Text
    var
        ReturnValue: Text;
    begin
        if not HeaderValues.Get(HeaderKey, ReturnValue) then
            exit('');
        exit(ReturnValue);
    end;

    local procedure GetCanonicalizedHeaders(Headers: Dictionary of [Text, Text]): Text
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        HeaderKey: Text;
        CanonicalizedHeaders: Text;
    begin
        // "Headers" needs to be a sorted dictionary
        foreach HeaderKey in Headers.Keys do
            if (HeaderKey.ToLower().StartsWith('x-ms-')) then begin
                if CanonicalizedHeaders <> '' then
                    CanonicalizedHeaders += FormatHelper.GetNewLineCharacter();
                CanonicalizedHeaders += StrSubstNo(KeyValuePairLbl, HeaderKey.ToLower(), Headers.Get(HeaderKey))
            end;
        exit(CanonicalizedHeaders);
    end;

    local procedure GetCanonicalizedResource(StorageAccount: Text; UriString: Text): Text
    var
        SortTable: Record "AZBSA Temp. Sort Table";
        Uri: Codeunit Uri;
        UriBuider: Codeunit "Uri Builder";
        FormatHelper: Codeunit "AZBSA Format Helper";
        QueryString: Text;
        Segments: List of [Text];
        Segment: Text;
        StringBuilderResource: TextBuilder;
        StringBuilderQuery: TextBuilder;
        StringBuilderCanonicalizedResource: TextBuilder;
    begin
        Uri.Init(UriString);
        Uri.GetSegments(Segments);

        UriBuider.Init(UriString);
        QueryString := UriBuider.GetQuery();

        StringBuilderResource.Append('/');
        StringBuilderResource.Append(StorageAccount);
        foreach Segment in Segments do
            StringBuilderResource.Append(Segment);

        if QueryString <> '' then begin
            GetQuerySegments(QueryString, Segments);
            // Need to use temp. Table to sort query alphabetically
            // According to documentation it should be lexicographically, but I don't know how :(
            // see: https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key#constructing-the-canonicalized-headers-string
            GetSortedQueryValues(Segments, SortTable);
            if SortTable.FindSet(false, false) then
                repeat
                    StringBuilderQuery.Append(FormatHelper.GetNewLineCharacter());
                    StringBuilderQuery.Append(StrSubstNo(KeyValuePairLbl, SortTable."Key", SortTable."Value"));
                until SortTable.Next() = 0;
        end;
        StringBuilderCanonicalizedResource.Append(StringBuilderResource.ToText());
        StringBuilderCanonicalizedResource.Append(StringBuilderQuery.ToText());
        exit(StringBuilderCanonicalizedResource.ToText());
    end;

    local procedure GetQuerySegments(QueryString: Text; var Segments: List of [Text])
    begin
        Clear(Segments);
        if QueryString.StartsWith('?') then
            QueryString := CopyStr(QueryString, 2);
        Segments := QueryString.Split('&');
    end;

    local procedure GetKeyValueFromQueryParameter(QueryString: Text; var "Key": Text; var "Value": Text)
    var
        Split: List of [Text];
    begin
        Split := QueryString.Split('=');
        if Split.Count <> 2 then
            Error('This should not happen');
        "Key" := Split.Get(1);
        "Value" := Split.Get(2);
    end;

    local procedure GetSortedQueryValues(Segments: List of [Text]; var TempSortTable: Record "AZBSA Temp. Sort Table")
    var
        Segment: Text;
        "Key": Text;
        "Value": Text;
    begin
        TempSortTable.Reset();
        TempSortTable.DeleteAll();
        foreach Segment in Segments do begin
            GetKeyValueFromQueryParameter(Segment, "Key", "Value");
            TempSortTable."Key" := CopyStr("Key", 1, 250);
            TempSortTable."Value" := CopyStr("Value", 1, 250);
            TempSortTable.Insert();
        end;
        TempSortTable.SetCurrentKey("Key");
        TempSortTable.Ascending(true);
    end;

    local procedure GetAccessKeyHashCode(StringToSign: Text; AccessKey: Text): Text;
    var
        CryptographyMgmt: Codeunit "Cryptography Management";
        HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
    begin
        exit(CryptographyMgmt.GenerateBase64KeyedHashAsBase64String(StringToSign, AccessKey, HashAlgorithmType::HMACSHA256));
    end;
    // #endregion Shared Key Signature Generation
}