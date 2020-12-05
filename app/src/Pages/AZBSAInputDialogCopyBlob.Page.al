page 89007 "AZBSA Input Dialog Copy Blob"
{
    PageType = StandardDialog;
    UsageCategory = None;
    SourceTable = Integer;

    layout
    {
        area(Content)
        {
            group(Detail)
            {
                field("Destination Storage Account"; DestStorageAccount)
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                    Caption = 'Destination Storage Account';
                    Editable = false;
                }
                field("Destination Container Name"; DestContainer)
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                    Caption = 'Destination Container Name';
                }
                field("Destination Blob Name"; DestBlobName)
                {
                    ApplicationArea = All;
                    ToolTip = 'xxx';
                    Caption = 'Destination Blob Name';
                }
            }
        }
    }

    var
        DestStorageAccount: Text;
        DestContainer: Text;
        DestBlobName: Text;

    procedure InitPage(NewDestStorageAccount: Text; NewDestContainer: Text; NewDestBlobName: Text)
    begin
        DestStorageAccount := NewDestStorageAccount;
        DestContainer := NewDestContainer;
        DestBlobName := NewDestBlobName;
    end;

    procedure GetResults(var NewDestStorageAccount: Text; var NewDestContainer: Text; var NewDestBlobName: Text)
    begin
        NewDestBlobName := DestBlobName;
        NewDestContainer := DestContainer;
        NewDestStorageAccount := DestStorageAccount;
    end;
}