page 1000000 "ABC Setup Card"
{
    Caption = 'Shipment Note Setup';
    PageType = Card;
    SourceTable = "ABC Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group("ABC General")
            {
                Caption = 'General';

                field("Shipment Note Nos."; Rec."Shipment Note Nos.")
                {
                    ApplicationArea = All;
                }
                field("Require Shipment Confirmation"; Rec."Require Shipment Confirmation")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
