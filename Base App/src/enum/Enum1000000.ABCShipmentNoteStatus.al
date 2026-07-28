enum 1000000 "ABC Shipment Note Status"
{
    Caption = 'Shipment Note Status';
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Released)
    {
        Caption = 'Released';
    }
    value(2; Closed)
    {
        Caption = 'Closed';
    }
}
