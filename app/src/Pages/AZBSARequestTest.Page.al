// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 89004 "AZBSA Request Test"
{

    ApplicationArea = All;
    Caption = 'Request Test';
    PageType = List;
    SourceTable = Integer;
    SourceTableTemporary = true;
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Code; BlobStorageConn.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'XXX';
                    Lookup = true;
                    TableRelation = "AZBSA Blob Storage Connection".Code;

                    trigger OnValidate()
                    begin
                        BlobStorageConn.Get(BlobStorageConn.Code);
                    end;
                }
                field(APIAction; APIAction)
                {
                    ApplicationArea = All;
                    ToolTip = 'XXX';
                    Caption = 'API Action';
                    OptionCaption = 'List Containers,Create Container,Delete Container';
                }
                field(ContainerName; ContainerName)
                {
                    ApplicationArea = All;
                    ToolTip = 'XXX';
                    Caption = 'Container Name';
                }

                field(BlobName; BlobName)
                {
                    ApplicationArea = All;
                    ToolTip = 'XXX';
                    Caption = 'Blob Name';
                }
            }
            group(Result)
            {
                field(ResultText; ResultText)
                {
                    ApplicationArea = All;
                    Caption = 'Result';
                    ToolTip = 'XXX';
                    Editable = false;
                    MultiLine = true;

                    trigger OnAssistEdit()
                    begin
                        Message(ResultText);
                    end;
                }
            }
            part(UriParams; "AZBSA Req. Test URI Params")
            {
                ApplicationArea = All;
                Editable = true;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Execute)
            {
                ApplicationArea = All;
                ToolTip = 'XXX';
                Image = Start;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Container: Record "AZBSA Container";
                    API: Codeunit "AZBSA Blob Storage API";
                    RequestObject: Codeunit "AZBSA Request Object";
                    OptionalUriParameters: Dictionary of [Text, Text];
                begin
                    CurrPage.UriParams.Page.GetRecordAsDictionairy(OptionalUriParameters);
                    RequestObject.InitializeRequest(BlobStorageConn."Storage Account Name", ContainerName, BlobName);
                    RequestObject.InitializeAuthorization(BlobStorageConn."Authorization Type", BlobStorageConn.Secret);
                    RequestObject.AddOptionalUriParameter(OptionalUriParameters);

                    case APIAction of
                        APIAction::"List Containers":
                            API.ListContainers(RequestObject, Container, false);
                    end;
                    ResultText := RequestObject.GetHttpResponseAsText();
                end;
            }
        }
    }
    var
        BlobStorageConn: Record "AZBSA Blob Storage Connection";
        APIAction: Option "List Containers","Create Container","Delete Container";
        ContainerName: Text;
        BlobName: Text;
        ResultText: Text;
}
