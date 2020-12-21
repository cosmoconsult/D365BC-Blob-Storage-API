// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 89000 "AZBSA Blob Storage Operation"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = '';
    }
    value(1; GetAccountInformation)
    {
        Caption = 'Get Account Information';
    }
    value(10; ListContainers)
    {
        Caption = 'List Containers';
    }
    value(11; ListContainerContents)
    {
        Caption = 'List Container Contents';
    }
    value(12; PutContainer)
    {
        Caption = 'Create Container';
    }
    value(13; DeleteContainer)
    {
        Caption = 'Delete Container';
    }
    value(14; GetContainerMetadata)
    {
        Caption = 'Get Container Metadata';
    }
    value(15; SetContainerMetadata)
    {
        Caption = 'Set Container Metadata';
    }
    value(16; GetContainerAcl)
    {
        Caption = 'Get Container ACL';
    }
    value(17; SetContainerAcl)
    {
        Caption = 'Set Container ACL';
    }
    value(18; GetContainerProperties)
    {
        Caption = 'Get Container Properties';
    }
    value(20; GetBlob)
    {
        Caption = 'Get Blob';
    }
    value(21; PutBlob)
    {
        Caption = 'Upload Blob';
    }
    value(22; DeleteBlob)
    {
        Caption = 'Delete Blob';
    }
    value(23; CopyBlob)
    {
        Caption = 'Copy Blob';
    }
    value(24; AbortCopyBlob)
    {
        Caption = 'Abort Copy Blob';
    }
    value(25; GetBlobMetadata)
    {
        Caption = 'Get Blob Metadata';
    }
    value(26; SetBlobMetadata)
    {
        Caption = 'Set Blob Metadata';
    }
    value(27; GetBlobTags)
    {
        Caption = 'Get Blob Tags';
    }
    value(28; SetBlobTags)
    {
        Caption = 'Set Blob Tags';
    }
    value(29; FindBlobByTags)
    {
        Caption = 'Find Blobs by Tags';
    }
    value(30; LeaseContainer)
    {
        Caption = 'Lease Container';
    }
    value(31; LeaseBlob)
    {
        Caption = 'Lease Blob';
    }
    value(32; SnapshotBlob)
    {
        Caption = 'Snapshot Blob';
    }
    value(33; UndeleteBlob)
    {
        Caption = 'Undelete Blob';
    }
    value(34; AppendBlock)
    {
        Caption = 'Append Block';
    }
    value(40; GetBlobServiceProperties)
    {
        Caption = 'Get Blob Service Properties';
    }
    value(41; SetBlobServiceProperties)
    {
        Caption = 'Set Blob Service Properties';
    }
    value(42; GetBlobServiceStats)
    {
        Caption = 'Get Blob Service Stats';
    }
    value(50; GetBlobProperties)
    {
        Caption = 'Get Blob Properties';
    }
    value(51; SetBlobProperties)
    {
        Caption = 'Set Blob Properties';
    }
    value(52; SetBlobExpiry)
    {
        Caption = 'Set Blob Expiry';
    }
}