page 1000002 "ABC Shipment Note Card"
{
    Caption = 'Shipment Note';
    PageType = Card;
    SourceTable = "ABC Shipment Note";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group("ABC General")
            {
                Caption = 'General';

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    Rec.ABCRelease();
                    CurrPage.Update(false);
                end;
            }
            action("ABC CloseNote")
            {
                Caption = 'Close';
                ToolTip = 'Closes a Released Shipment Note.';
                ApplicationArea = All;
                Image = Close;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = (Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::Released);
                trigger OnAction()
                begin
                    Rec.ABCCloseNote();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
