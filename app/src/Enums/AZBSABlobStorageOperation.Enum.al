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
    value(30; LeaseContainer)
    {
        Caption = 'Lease Container';
    }
    value(31; LeaseBlob)
    {
        Caption = 'Lease Blob';
    }
}