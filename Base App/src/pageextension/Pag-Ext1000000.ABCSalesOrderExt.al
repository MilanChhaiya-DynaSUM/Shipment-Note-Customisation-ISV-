pageextension 1000000 "ABC Sales Order Ext" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("ABC Shipment Confirmed"; Rec."ABC Shipment Confirmed")
            {
                ApplicationArea = All;
            }
        }
    }
}
