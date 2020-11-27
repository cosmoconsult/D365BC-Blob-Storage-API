// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 89006 "AZBSA URI Helper"
{
    trigger OnRun()
    begin

    end;

    var
        OptionalUriParameters: Dictionary of [Text, Text];

    procedure SetOptionalUriParameter(NewOptionalUriParameters: Dictionary of [Text, Text])
    begin
        OptionalUriParameters := NewOptionalUriParameters;
    end;

    // #region Uri generation
    procedure ConstructUri(StorageAccountName: Text; ContainerName: Text; BlobName: Text; Operation: Enum "AZBSA Blob Storage Operation"; AuthType: Enum "AZBSA Authorization Type"; Secret: Text): Text
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        AuthorizationType: Enum "AZBSA Authorization Type";
        ConstructedUrl: Text;
        BlobStorageBaseUrlLbl: Label 'https://%1.blob.core.windows.net', Comment = '%1 = Storage Account Name';
        SingleContainerLbl: Label '%1/%2?restype=container%3', Comment = '%1 = Base URL; %2 = Container Name ; %3 = List-extension (if applicable)';
        ListContainerExtensionLbl: Label '&comp=list';
        SingleBlobInContainerLbl: Label '%1/%2/%3', Comment = '%1 = Base URL; %2 = Container Name ; %3 = Blob Name';
    begin
        TestConstructUrlParameter(StorageAccountName, ContainerName, BlobName, Operation, AuthType, Secret);

        ConstructedUrl := StrSubstNo(BlobStorageBaseUrlLbl, StorageAccountName);
        case Operation of
            Operation::ListContainers:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, '', ListContainerExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/?restype=container&comp=list
            Operation::DeleteContainer:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, ContainerName, ''); // https://<StorageAccountName>.blob.core.windows.net/?restype=container&comp=list
            Operation::ListContainerContents:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, ContainerName, ListContainerExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/<ContainerName>?restype=container&comp=list
            Operation::PutContainer:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, ContainerName, ''); // https://<StorageAccountName>.blob.core.windows.net/<ContainerName>?restype=container
            Operation::GetBlob, Operation::PutBlob, Operation::DeleteBlob:
                ConstructedUrl := StrSubstNo(SingleBlobInContainerLbl, ConstructedUrl, ContainerName, BlobName); // https://<StorageAccountName>.blob.core.windows.net/<ContainerName>/<BlobName>
        end;

        AddOptionalUriParameters(ConstructedUrl);

        // If SaS-Token is used for authentication, append it to the URI
        if AuthType = AuthorizationType::SasToken then
            FormatHelper.AppendToUri(ConstructedUrl, '', Secret);
        exit(ConstructedUrl);
    end;

    local procedure AddOptionalUriParameters(var Uri: Text)
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        ParameterIdentifier: Text;
        ParameterValue: Text;
    begin
        if OptionalUriParameters.Count = 0 then
            exit;

        foreach ParameterIdentifier in OptionalUriParameters.Keys do begin
            OptionalUriParameters.Get(ParameterIdentifier, ParameterValue);
            FormatHelper.AppendToUri(Uri, ParameterIdentifier, ParameterValue);
        end;
    end;

    local procedure TestConstructUrlParameter(StorageAccountName: Text; ContainerName: Text; BlobName: Text; Operation: Enum "AZBSA Blob Storage Operation"; AuthType: Enum "AZBSA Authorization Type"; Secret: Text)
    var
        AuthorizationType: Enum "AZBSA Authorization Type";
        ValueCanNotBeEmptyErr: Label '%1 can not be empty', Comment = '%1 = Variable Name';
        StorageAccountNameLbl: Label 'Storage Account Name';
        SasTokenLbl: Label 'Shared Access Signature (Token)';
        AccesKeyLbl: Label 'Access Key';
        ContainerNameLbl: Label 'Container Name';
        BlobNameLbl: Label 'Blob Name';
        OperationLbl: Label 'Operation';
    begin
        if StorageAccountName = '' then
            Error(ValueCanNotBeEmptyErr, StorageAccountNameLbl);

        case AuthType of
            AuthorizationType::SasToken:
                if Secret = '' then
                    Error(ValueCanNotBeEmptyErr, SasTokenLbl);
            AuthorizationType::SharedKey:
                if Secret = '' then
                    Error(ValueCanNotBeEmptyErr, AccesKeyLbl);
        end;
        if Operation = Operation::" " then
            Error(ValueCanNotBeEmptyErr, OperationLbl);

        case true of
            Operation in [Operation::GetBlob, Operation::PutBlob, Operation::DeleteBlob]:
                begin
                    if ContainerName = '' then
                        Error(ValueCanNotBeEmptyErr, ContainerNameLbl);
                    if BlobName = '' then
                        Error(ValueCanNotBeEmptyErr, BlobNameLbl);
                end;
        end;
    end;
    // #endregion Uri generation

}