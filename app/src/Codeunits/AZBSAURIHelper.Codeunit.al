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
    procedure ConstructUri(var RequestObject: Codeunit "AZBSA Request Object"): Text
    begin
        exit(ConstructUri(RequestObject.GetStorageAccountName(), RequestObject.GetContainerName(), RequestObject.GetBlobName(), RequestObject.GetOperation(), RequestObject.GetAuthorizationType(), RequestObject.GetSecret()));
    end;

    procedure ConstructUri(StorageAccountName: Text; ContainerName: Text; BlobName: Text; Operation: Enum "AZBSA Blob Storage Operation"; AuthType: Enum "AZBSA Authorization Type"; Secret: Text): Text
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        AuthorizationType: Enum "AZBSA Authorization Type";
        ConstructedUrl: Text;
        BlobStorageBaseUrlLbl: Label 'https://%1.blob.core.windows.net', Comment = '%1 = Storage Account Name';
        SingleContainerLbl: Label '%1/%2?restype=container%3', Comment = '%1 = Base URL; %2 = Container Name ; %3 = Extension (if applicable)';
        ServiceExtensionLbl: Label '%1/?restype=service%2', Comment = '%1 = Base URL; %2 = Extension (if applicable)';
        ListContainerExtensionLbl: Label 'comp=list';
        LeaseContainerExtensionLbl: Label 'comp=lease';
        CopyContainerExtensionLbl: Label 'comp=copy';
        PropertiesExtensionLbl: Label 'comp=properties';
        MetadataExtensionLbl: Label 'comp=metadata';
        BlobInContainerLbl: Label '%1/%2/%3', Comment = '%1 = Base URL; %2 = Container Name ; %3 = Blob Name';
        BlobInContainerWithExtensionLbl: Label '%1/%2/%3%4', Comment = '%1 = Base URL; %2 = Container Name ; %3 = Blob Name; %4 = Extension';
    begin
        TestConstructUrlParameter(StorageAccountName, ContainerName, BlobName, Operation, AuthType, Secret);

        ConstructedUrl := StrSubstNo(BlobStorageBaseUrlLbl, StorageAccountName);
        // If using Azure Storage Emulator (indicated by Account Name "devstoreaccount1") then use a different Uri
        if StorageAccountName = 'devstoreaccount1' then
            ConstructedUrl := 'http://127.0.0.1:10000/devstoreaccount1';

        case Operation of
            Operation::ListContainers:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, '', '&' + ListContainerExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/?restype=container&comp=list
            Operation::DeleteContainer:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, ContainerName, ''); // https://<StorageAccountName>.blob.core.windows.net/?restype=container&comp=list
            Operation::ListContainerContents:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, ContainerName, '&' + ListContainerExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/<ContainerName>?restype=container&comp=list
            Operation::PutContainer:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, ContainerName, ''); // https://<StorageAccountName>.blob.core.windows.net/<ContainerName>?restype=container
            Operation::GetBlob, Operation::PutBlob, Operation::DeleteBlob, Operation::CopyBlob:
                ConstructedUrl := StrSubstNo(BlobInContainerLbl, ConstructedUrl, ContainerName, BlobName); // https://<StorageAccountName>.blob.core.windows.net/<ContainerName>/<BlobName>
            Operation::LeaseContainer:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, ContainerName, '&' + LeaseContainerExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/<Container>?restype=container&comp=lease
            Operation::LeaseBlob:
                ConstructedUrl := StrSubstNo(BlobInContainerWithExtensionLbl, ConstructedUrl, ContainerName, BlobName, '?' + LeaseContainerExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/<Container>/<BlobName>?comp=lease
            Operation::AbortCopyBlob:
                begin
                    ConstructedUrl := StrSubstNo(BlobInContainerWithExtensionLbl, ConstructedUrl, ContainerName, BlobName, '?' + CopyContainerExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/<Container>/<BlobName>?comp=copy&coppyid=<Id>
                    FormatHelper.AppendToUri(ConstructedUrl, 'copyid', RetrieveFromOptionalUriParameters('copyid'));
                end;
            Operation::GetBlobServiceProperties, Operation::SetBlobServiceProperties:
                ConstructedUrl := StrSubstNo(ServiceExtensionLbl, ConstructedUrl, '&' + PropertiesExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/?restype=service&comp=properties
            Operation::GetBlobProperties:
                ConstructedUrl := StrSubstNo(BlobInContainerLbl, ConstructedUrl, ContainerName, BlobName); // https://<StorageAccountName>.blob.core.windows.net/<Container>/<BlobName>
            Operation::SetBlobProperties:
                ConstructedUrl := StrSubstNo(BlobInContainerWithExtensionLbl, ConstructedUrl, ContainerName, BlobName, '?' + PropertiesExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/<Container>/<BlobName>
            Operation::GetContainerMetadata, Operation::SetContainerMetadata:
                ConstructedUrl := StrSubstNo(SingleContainerLbl, ConstructedUrl, ContainerName, '&' + MetadataExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/<Container>?restype=container&comp=metadata
            Operation::GetBlobMetadata, Operation::SetBlobMetadata:
                ConstructedUrl := StrSubstNo(BlobInContainerWithExtensionLbl, ConstructedUrl, ContainerName, BlobName, '?' + MetadataExtensionLbl); // https://<StorageAccountName>.blob.core.windows.net/<Container>/<BlobName>?comp=lease
            else
                Error('Operation needs to be defined');
        end;

        AddOptionalUriParameters(ConstructedUrl);

        // If SaS-Token is used for authentication, append it to the URI
        if AuthType = AuthorizationType::SasToken then
            FormatHelper.AppendToUri(ConstructedUrl, '', Secret);
        exit(ConstructedUrl);
    end;

    local procedure RetrieveFromOptionalUriParameters(Identifier: Text): Text
    var
        ReturnValue: Text;
    begin
        if not OptionalUriParameters.ContainsKey(Identifier) then
            exit;

        OptionalUriParameters.Get(Identifier, ReturnValue);
        exit(ReturnValue);
    end;

    local procedure AddOptionalUriParameters(var Uri: Text)
    var
        FormatHelper: Codeunit "AZBSA Format Helper";
        ParameterIdentifier: Text;
        ParameterValue: Text;
    begin
        if OptionalUriParameters.Count = 0 then
            exit;

        foreach ParameterIdentifier in OptionalUriParameters.Keys do
            if not (ParameterIdentifier in ['copyid']) then begin
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