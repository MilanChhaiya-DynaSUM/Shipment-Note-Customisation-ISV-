permissionset 1000000 "ABC SHIP NOTE"
{
    Access = Public;
    Assignable = true;
    Caption = 'ABC Shipment Note - Full Access';
    Permissions = table "ABC Setup" = X,
        tabledata "ABC Setup" = RIMD,
        table "ABC Shipment Note" = X,
        tabledata "ABC Shipment Note" = RIMD,
        page "ABC Setup Card" = X,
        page "ABC Shipment Note List" = X,
        page "ABC Shipment Note Card" = X,
        codeunit "ABC Sales Post Subscriber" = X;
}