codeunit 1000000 "ABC Sales Post Subscriber"
{
    Access = Internal;

    var
        ShipmentNotConfirmedErr: Label 'You cannot post this order because the Shipment Confirmed checkbox is not ticked.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure ABCBlockPostingWhenShipmentNotConfirmed(var SalesHeader: Record "Sales Header")
    var
        ABCSetup: Record "ABC Setup";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        ABCSetup.Get();
        if not ABCSetup."Require Shipment Confirmation" then
            exit;

        if not SalesHeader."ABC Shipment Confirmed" then
            Error(ShipmentNotConfirmedErr);
    end;
}
