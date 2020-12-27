// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 89001 "AZBSA Blob Stor. Conn. Card"
{

    Caption = 'Blob Storage Connection Card';
    PageType = Card;
    SourceTable = "AZBSA Blob Storage Connection";
    UsageCategory = Administration;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Reports,View Container,Create Container,Delete Container,Upload,Download,Delete Blob,Lease,Properties';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Identifier';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }
                field("Storage Account Name"; Rec."Storage Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The name (not the complete URL) for the Storage Account';
                }
                field("API Version"; Rec."API Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'The API Version to use';
                }
            }
            group(RequestObject)
            {
                field("Authorization Type"; Rec."Authorization Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'The way of authorizing API calls';
                }
                field(Secret; Rec.Secret)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shared access signature Token or SharedKey';
                }
            }
            group(Container)
            {
                field("Source Container Name"; Rec."Source Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Name of the Container (or Directory) to download files from';
                }
                field("Target Container Name"; Rec."Target Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Name of the Container (or Directory) to upload files to';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(OpenTester)
            {
                Caption = 'Open Test-Page';
                Image = TestFile;
                ApplicationArea = All;
                ToolTip = 'Use this page to test API actions and view the "raw" HTTP response for it';
                RunObject = page "AZBSA Request Test";
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
            }
            group(View)
            {
                Caption = 'View Container';
                action(ListContainers)
                {
                    ApplicationArea = All;
                    Caption = 'List all Containers';
                    Image = LaunchWeb;
                    ToolTip = 'List all available Containers in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;

                    trigger OnAction();
                    begin
                        Rec.ListContainers();
                    end;
                }

                action(FindBlobsByTags)
                {
                    ApplicationArea = All;
                    Caption = 'Find Blobs By Tags';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;

                    trigger OnAction();
                    begin
                        Rec.FindBlobsByTags();
                    end;
                }

                action(ListSourceContents)
                {
                    ApplicationArea = All;
                    Caption = 'List Contents of Source';
                    Image = LaunchWeb;
                    ToolTip = 'List all files in the Source Container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;

                    trigger OnAction();
                    begin
                        Rec.ListContentSource();
                    end;
                }

                action(ListTargetContents)
                {
                    ApplicationArea = All;
                    Caption = 'List Contents of Target';
                    Image = LaunchWeb;
                    ToolTip = 'List all files in the Target Container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;

                    trigger OnAction();
                    begin
                        Rec.ListContentTarget();
                    end;
                }
                action(GetUserDelegationKey)
                {
                    ApplicationArea = All;
                    Caption = 'Get User Delegation Key';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;

                    trigger OnAction();
                    begin
                        Rec.GetUserDelegationKey();
                    end;
                }
            }
            group(CreateContainers)
            {
                Caption = 'Create Containers';
                action(TestCreateSourceContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Create Source Container';
                    Image = LaunchWeb;
                    ToolTip = 'Create the Container (specified in "Source Container Name") in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;

                    trigger OnAction();
                    begin
                        Rec.CreateSourceContainer();
                    end;
                }

                action(TestCreateTargetContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Create Target Container';
                    Image = LaunchWeb;
                    ToolTip = 'Create the Container (specified in "Target Container Name") in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;

                    trigger OnAction();
                    begin
                        Rec.CreateTargetContainer();
                    end;
                }
            }
            group(DeleteContainers)
            {
                Caption = 'Delete Containers';
                action(TestDeleteSourceContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Source Container';
                    Image = LaunchWeb;
                    ToolTip = 'Delete the Container (specified in "Source Container Name") in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;

                    trigger OnAction();
                    begin
                        Rec.DeleteSourceContainer();
                    end;
                }

                action(TestDeleteTargetContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Target Container';
                    Image = LaunchWeb;
                    ToolTip = 'Delete the Container (specified in "Target Container Name") in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;

                    trigger OnAction();
                    begin
                        Rec.DeleteTargetContainer();
                    end;
                }
            }
            group(Lease)
            {
                Caption = 'Lease...';

                action(LeaseContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Acquire Lease Container';
                    Image = LaunchWeb;
                    ToolTip = 'Acquires a lease for a container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;

                    trigger OnAction()
                    begin
                        Rec.ContainerLeaseAcquireSource();
                    end;
                }

                action(ReleaseContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Release Lease Container';
                    Image = LaunchWeb;
                    ToolTip = 'Release a lease for a container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;

                    trigger OnAction()
                    var
                        NullGuid: Guid;
                    begin
                        Rec.ContainerLeaseReleaseSource(NullGuid);
                    end;
                }

                action(RenewLeaseContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Renew Lease Container';
                    Image = LaunchWeb;
                    ToolTip = 'Renew a lease for a container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;

                    trigger OnAction()
                    var
                        NullGuid: Guid;
                    begin
                        Rec.ContainerLeaseRenewSource(NullGuid);
                    end;
                }
            }
            group(UploadFile)
            {
                Caption = 'Upload';

                action(UploadFileUISource)
                {
                    ApplicationArea = All;
                    Caption = 'Upload File (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'Upload a file in the Container (specified in "Source Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    begin
                        Rec.UploadFileUI(Rec."Source Container Name");
                    end;
                }
                action(UploadFileUITarget)
                {
                    ApplicationArea = All;
                    Caption = 'Upload File (Target)';
                    Image = LaunchWeb;
                    ToolTip = 'Upload a file in the Container (specified in "Target Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    begin
                        Rec.UploadFileUI(Rec."Target Container Name");
                    end;
                }

                action(CreateRandomPageBlobSource)
                {
                    ApplicationArea = All;
                    Caption = 'Create Page Blob (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'Creates a PageBlob with a Random name in Container (specified in "Source Container Name")';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    begin
                        Rec.CreateRandomPageBlobInContainer(Rec."Source Container Name");
                    end;
                }

                action(CreateRandomAppendBlobSource)
                {
                    ApplicationArea = All;
                    Caption = 'Create Append Blob (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'Creates a AppendBlob with a Random name in Container (specified in "Source Container Name")';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    begin
                        Rec.CreateRandomAppendBlobInContainer(Rec."Source Container Name");
                    end;
                }
            }
            group(DownloadFile)
            {
                Caption = 'Download';

                action(DownloadFileUISource)
                {
                    ApplicationArea = All;
                    Caption = 'Download File (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'Download a file from the Container (specified in "Source Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category8;

                    trigger OnAction()
                    begin
                        Rec.DownloadFileUI(Rec."Source Container Name");
                    end;
                }
                action(DownloadFileUITarget)
                {
                    ApplicationArea = All;
                    Caption = 'Download File (Target)';
                    Image = LaunchWeb;
                    ToolTip = 'Download a file from the Container (specified in "Target Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category8;

                    trigger OnAction()
                    begin
                        Rec.DownloadFileUI(Rec."Target Container Name");
                    end;
                }
            }

            group(DeleteBlob)
            {
                Caption = 'Delete Blob';

                action(DeleteBlobUISource)
                {
                    ApplicationArea = All;
                    Caption = 'Delete File (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'Delete a file from the Container (specified in "Source Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category9;

                    trigger OnAction()
                    begin
                        Rec.DeleteBlobFromSourceContainerUI();
                    end;
                }
                action(DeleteBlobUITarget)
                {
                    ApplicationArea = All;
                    Caption = 'Delete File (Target)';
                    Image = LaunchWeb;
                    ToolTip = 'Delete a file from the Container (specified in "Target Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category9;

                    trigger OnAction()
                    begin
                        Rec.DeleteBlobFromTargetContainerUI();
                    end;
                }
            }
            group(BlobProperties)
            {
                Caption = 'Properties';
                action(GetServiceProperties)
                {
                    ApplicationArea = All;
                    Caption = 'Get Service Properties';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.GetBlobServiceProperties();
                    end;
                }
                action(SetServiceProperties)
                {
                    ApplicationArea = All;
                    Caption = 'Set Service Properties';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.SetBlobServiceProperties();
                    end;
                }
                action(GetAccountInformation)
                {
                    ApplicationArea = All;
                    Caption = 'Get Account Information';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.GetAccountInformation();
                    end;
                }
                action(GetBlobServiceStats)
                {
                    ApplicationArea = All;
                    Caption = 'Get Service Stats';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.GetBlobServiceStats();
                    end;
                }

                action(GetContainerMetadataSource)
                {
                    ApplicationArea = All;
                    Caption = 'Get Container Metadata (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.GetContainerMetadataSource();
                    end;
                }

                action(SetContainerMetadataSource)
                {
                    ApplicationArea = All;
                    Caption = 'Set Container Metadata (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.SetContainerMetadataSource();
                    end;
                }

                action(GetContainerAclSource)
                {
                    ApplicationArea = All;
                    Caption = 'Get Container ACL (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.GetContainerAclSource();
                    end;
                }

                action(SetContainerAclSource)
                {
                    ApplicationArea = All;
                    Caption = 'Set Container ACL (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.SetContainerAclSource();
                    end;
                }
                action(GetContainerPropertiesSource)
                {
                    ApplicationArea = All;
                    Caption = 'Get Container Properties (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'xxx';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    begin
                        Rec.GetContainerPropertiesSource();
                    end;
                }
            }
        }
    }
}
