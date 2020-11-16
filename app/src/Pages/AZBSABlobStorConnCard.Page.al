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
    PromotedActionCategories = 'New,Process,Reports,View Container,Create Container,Delete Container,Upload,Download,Delete Blob';

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
        }
    }
}
