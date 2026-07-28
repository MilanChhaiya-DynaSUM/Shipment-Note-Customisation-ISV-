table 1000001 "ABC Shipment Note"
{
    Caption = 'Shipment Note';
    DataClassification = CustomerContent;
    LookupPageId = "ABC Shipment Note List";
    DrillDownPageId = "ABC Shipment Note List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of the Shipment Note.';
            Editable = false;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies a description of the Shipment Note.';
        }
        field(3; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date the shipment is expected or was made.';
        }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ToolTip = 'Specifies the customer the shipment relates to.';

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                Clear(Customer);
                if Customer.get("Customer No.") then
                    Validate("Customer Name", Customer.Name);
            end;
        }
        field(5; "Customer Name"; Code[20])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the Customer name the shipment relates to.';
        }
        field(6; Status; Enum "ABC Shipment Note Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the current status of the Shipment Note.';

            trigger OnValidate()
            begin
                ABCValidateStatusChange(xRec.Status, Status);
            end;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        MustBeReleasedFirstErr: Label 'The Shipment Note must be Released before it can be Closed.';
        CannotReopenErr: Label 'A Closed Shipment Note cannot be reopened. Create a new Shipment Note instead.';

    trigger OnInsert()
    var
        ABCSetup: Record "ABC Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            ABCSetup.Get();
            ABCSetup.TestField("Shipment Note Nos.");
            "No." := NoSeries.GetNextNo(ABCSetup."Shipment Note Nos.");
        end;
    end;

    procedure ABCValidateStatusChange(OldStatus: Enum "ABC Shipment Note Status"; NewStatus: Enum "ABC Shipment Note Status")
    begin
        case NewStatus of
            NewStatus::Released:
                begin
                    TestField(Description);
                    TestField("Shipment Date");
                    TestField("Customer No.");
                end;
            NewStatus::Closed:
                if OldStatus <> OldStatus::Released then
                    Error(MustBeReleasedFirstErr);
            NewStatus::Open:
                if OldStatus = OldStatus::Closed then
                    Error(CannotReopenErr);
        end;
    end;

    procedure ABCRelease()
    begin
        ABCValidateStatusChange(Status, Status::Released);
        Status := Status::Released;
        Modify(true);
    end;

    procedure ABCCloseNote()
    begin
        ABCValidateStatusChange(Status, Status::Closed);
        Status := Status::Closed;
        Modify(true);
    end;
}
