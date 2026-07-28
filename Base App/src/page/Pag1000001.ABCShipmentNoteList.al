page 1000001 "ABC Shipment Note List"
{
    Caption = 'Shipment Notes';
    PageType = List;
    SourceTable = "ABC Shipment Note";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "ABC Shipment Note Card";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("ABC Release")
            {
                Caption = 'Release';
                ToolTip = 'Releases the Shipment Note after checking that required fields are filled in.';
                ApplicationArea = All;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ABCRelease();
                end;
            }
            action("ABC CloseNote")
            {
                Caption = 'Close';
                ToolTip = 'Closes a Released Shipment Note.';
                ApplicationArea = All;
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.ABCCloseNote();
                end;
            }
        }
    }
}
