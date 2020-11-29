// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 89003 "AZBSA Container Contents"
{

    ApplicationArea = All;
    Caption = 'Container Contents';
    PageType = List;
    SourceTable = "AZBSA Container Content";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Name;
                field("Parent Directory"; Rec."Parent Directory")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'xxx';
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'xxx';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';

                    trigger OnAssistEdit()
                    begin
                        Rec.DownloadBlob(OriginalRequestObject);
                    end;
                }
                field("Creation-Time"; Rec."Creation-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                }
                field("Last-Modified"; Rec."Last-Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                }
                field("Content-Length"; Rec."Content-Length")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'xxx';
                }
                field("Content-Type"; Rec."Content-Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                }
                field(BlobType; Rec.BlobType)
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ShowEntryDetails)
            {
                Caption = 'Show Entry Details';
                Image = ViewDetails;
                // Promoted = true;
                // PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'xxx';

                trigger OnAction()
                var
                    InStr: InStream;
                    OuterXml: Text;
                begin
                    if not Rec."XML Value".HasValue then
                        exit;

                    Rec.CalcFields("XML Value");
                    Rec."XML Value".CreateInStream(InStr);
                    InStr.Read(OuterXml);
                    Message(OuterXml);
                end;
            }
        }
    }
    var
        OriginalRequestObject: Codeunit "AZBSA Request Object";

    procedure AddEntry(ContainerContent: Record "AZBSA Container Content")
    begin
        Rec.TransferFields(ContainerContent);
        Rec.Insert();
    end;

    procedure InitializeFromTempRec(var ContainerContent: Record "AZBSA Container Content")
    begin
        if not ContainerContent.FindSet(false, false) then
            exit;

        ContainerContent.GetRequestObject(OriginalRequestObject);
        repeat
            ContainerContent.CalcFields("XML Value");
            Rec.TransferFields(ContainerContent);
            Rec.Insert();
        until ContainerContent.Next() = 0;
    end;
}
