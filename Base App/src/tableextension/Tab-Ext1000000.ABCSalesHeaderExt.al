tableextension 1000000 "ABC Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(1000000; "ABC Shipment Confirmed"; Boolean)
        {
            Caption = 'Shipment Confirmed';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that the shipment for this order has been confirmed. Required before the order can be posted, unless disabled in Shipment Note Setup.';
        }
    }
}
