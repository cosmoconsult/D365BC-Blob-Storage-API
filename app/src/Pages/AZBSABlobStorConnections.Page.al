// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 89000 "AZBSA Blob Stor. Connections"
{
    Caption = 'Blob Storage Connections';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "AZBSA Blob Storage Connection";
    CardPageId = "AZBSA Blob Stor. Conn. Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
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
                    ToolTip = 'Enter the name (not the complete URL) for the Storage Account here';
                }
                field("Authorization Type"; Rec."Authorization Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'The way of authorizing API calls';
                }
                field(Secret; Rec."Secret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shared access signature Token or SharedKey';
                }
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
            group(ListContents)
            {
                Caption = 'View';
                action(TestListContainers)
                {
                    ApplicationArea = All;
                    Caption = 'List all Containers';
                    Image = LaunchWeb;
                    ToolTip = 'List all available Containers in the Storage Account';

                    trigger OnAction();
                    begin
                        Rec.ListContainers();
                    end;
                }

                action(TestListSource)
                {
                    ApplicationArea = All;
                    Caption = 'List Contents of Source';
                    Image = LaunchWeb;
                    ToolTip = 'List all files in the Source Container';

                    trigger OnAction();
                    begin
                        Rec.ListContentSource();
                    end;
                }

                action(TestListTarget)
                {
                    ApplicationArea = All;
                    Caption = 'List Contents of Target';
                    Image = LaunchWeb;
                    ToolTip = 'List all files in the Target Container';

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

                    trigger OnAction();
                    begin
                        Rec.CreateTargetContainer();
                    end;
                }
            }
            group(DeleteContainers)
            {
                Caption = 'Create Containers';

                action(TestDeleteSourceContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Source Container';
                    Image = LaunchWeb;
                    ToolTip = 'Delete the Container (specified in "Source Container Name") in the Storage Account';

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

                    trigger OnAction();
                    begin
                        Rec.DeleteTargetContainer();
                    end;
                }
            }
            group(UploadFile)
            {
                Caption = 'Upload';

                action(UploadFileUI)
                {
                    ApplicationArea = All;
                    Caption = 'Upload File (UI) to Source Container';
                    Image = LaunchWeb;
                    ToolTip = 'Upload a file in the Container (specified in "Source Container Name") of the Storage Account';


                    trigger OnAction()
                    begin
                        Rec.UploadFileUI(Rec."Source Container Name");
                    end;
                }
            }

            group(DownloadFile)
            {
                Caption = 'Download';

                action(DownloadFileUI)
                {
                    ApplicationArea = All;
                    Caption = 'Download File (UI) from Source Container';
                    Image = LaunchWeb;
                    ToolTip = 'Download a file from the Container (specified in "Source Container Name") of the Storage Account';


                    trigger OnAction()
                    begin
                        Rec.DownloadFileUI(Rec."Source Container Name");
                    end;
                }
            }
        }
    }
}