table 1000000 "ABC Setup"
{
    Caption = 'Shipment Note Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Shipment Note Nos."; Code[20])
        {
            Caption = 'Shipment Note Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series used to assign numbers to new Shipment Notes.';

            trigger OnValidate()
            begin
                if "Shipment Note Nos." <> '' then
                    NoSeries.TestManual("Shipment Note Nos.");
            end;
        }
        field(20; "Require Shipment Confirmation"; Boolean)
        {
            Caption = 'Require Shipment Confirmation Before Posting';
            DataClassification = CustomerContent;
            InitValue = true;
            ToolTip = 'Specifies if a Sales Order cannot be posted until its Shipment Confirmed checkbox is ticked.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        NoSeries: Codeunit "No. Series";
}
