codeunit 89151 "AZBSAT Constants"
{
    trigger OnRun()
    begin

    end;

    var
        StorageAccountNameLbl: Label 'azbsaunittesting001';
        AccessKeyLbl: Label '<Not public, sorry>';

    procedure InitializeSharedKeyAuthorization(var RequestObject: Codeunit "AZBSA Request Object")
    var
        AuthType: Enum "AZBSA Authorization Type";
    begin
        RequestObject.InitializeAuthorization(AuthType::SharedKey, AccessKeyLbl);
    end;

    procedure InitializeRequest(var RequestObject: Codeunit "AZBSA Request Object")
    begin
        InitializeRequest(RequestObject, '');
    end;

    procedure InitializeRequest(var RequestObject: Codeunit "AZBSA Request Object"; ContainerName: Text)
    begin
        InitializeRequest(RequestObject, ContainerName, '');
    end;

    procedure InitializeRequest(var RequestObject: Codeunit "AZBSA Request Object"; ContainerName: Text; BlobName: Text)
    begin
        RequestObject.InitializeRequest(GetStorageAccountName(), ContainerName, BlobName);
    end;

    procedure GetStorageAccountName(): Text
    begin
        exit(StorageAccountNameLbl);
    end;
}