codeunit 50150 "ABC Shipment Note Test"
{
    // Fully self-contained: no dependency on any Microsoft test-library app
    // (no Library Assert, no Library - Sales, no Library - Inventory).
    // - Test data is created directly against base tables with Init/Insert/Validate.
    // - Posting is done with a direct Codeunit.Run call, matching what
    //   Library - Sales.PostSalesDocument does internally.
    // - Assertions are hand-rolled local helpers at the bottom of this codeunit.
    //
    // Trade-off: because we skip Microsoft's data-setup helpers, the two posting
    // tests assume the test company allows a blank/blank posting-group combination
    // (true for the default BC demo/evaluation company). If your company enforces
    // specific posting groups, extend CreateCustomer/CreateItem below to set them.
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure ReleaseFailsWhenDescriptionIsBlank()
    var
        ShipmentNote: Record "ABC Shipment Note";
    begin
        // [GIVEN] a new Shipment Note with no Description
        CreateShipmentNote(ShipmentNote, '', WorkDate(), CreateCustomer());

        // [WHEN] the note is released
        asserterror ShipmentNote.Release();

        // [THEN] the release is blocked because Description is required
        VerifyLastErrorContains('Description');
    end;

    [Test]
    procedure ReleaseFailsWhenShipmentDateIsBlank()
    var
        ShipmentNote: Record "ABC Shipment Note";
    begin
        // [GIVEN] a new Shipment Note with no Shipment Date
        CreateShipmentNote(ShipmentNote, 'Test shipment', 0D, CreateCustomer());

        // [WHEN] the note is released
        asserterror ShipmentNote.Release();

        // [THEN] the release is blocked because Shipment Date is required
        VerifyLastErrorContains('Shipment Date');
    end;

    [Test]
    procedure ReleaseSucceedsWhenRequiredFieldsAreFilledIn()
    var
        ShipmentNote: Record "ABC Shipment Note";
    begin
        // [GIVEN] a fully filled in Shipment Note
        CreateShipmentNote(ShipmentNote, 'Test shipment', WorkDate(), CreateCustomer());

        // [WHEN] the note is released
        ShipmentNote.Release();

        // [THEN] the status is Released
        VerifyStatusEqual(ShipmentNote.Status::Released, ShipmentNote.Status, 'Status should be Released.');
    end;

    [Test]
    procedure CannotCloseNoteThatIsStillOpen()
    var
        ShipmentNote: Record "ABC Shipment Note";
    begin
        // [GIVEN] an Open Shipment Note
        CreateShipmentNote(ShipmentNote, 'Test shipment', WorkDate(), CreateCustomer());

        // [WHEN] the note is closed without first being released
        asserterror ShipmentNote.CloseNote();

        // [THEN] an error is raised
        VerifyLastErrorContains('must be Released');
    end;

    [Test]
    procedure CannotChangeStatusOfClosedNote()
    var
        ShipmentNote: Record "ABC Shipment Note";
    begin
        // [GIVEN] a Closed Shipment Note
        CreateShipmentNote(ShipmentNote, 'Test shipment', WorkDate(), CreateCustomer());
        ShipmentNote.Release();
        ShipmentNote.CloseNote();

        // [WHEN] an attempt is made to reopen it
        asserterror ShipmentNote.Validate(Status, ShipmentNote.Status::Open);

        // [THEN] an error is raised because Closed is locked
        VerifyLastErrorContains('cannot be changed');
    end;

    [Test]
    procedure NumberSeriesAssignsSequentialNos()
    var
        FirstNote: Record "ABC Shipment Note";
        SecondNote: Record "ABC Shipment Note";
    begin
        // [GIVEN] Setup has a number series configured
        EnsureNoSeriesConfigured();

        // [WHEN] two Shipment Notes are inserted
        FirstNote.Insert(true);
        SecondNote.Insert(true);

        // [THEN] both received a non-blank, distinct number
        VerifyCodeNotBlank(FirstNote."No.", 'First note should have a number.');
        VerifyCodesNotEqual(FirstNote."No.", SecondNote."No.", 'Numbers should be unique.');
    end;

    [Test]
    procedure PostingSalesOrderFailsWhenShipmentNotConfirmed()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [GIVEN] a Sales Order where Shipment Confirmed is not ticked
        CreateSalesOrder(SalesHeader, SalesLine, false);

        // [WHEN] the order is posted
        asserterror PostSalesOrder(SalesHeader);

        // [THEN] posting is blocked with the expected error
        VerifyLastErrorContains('Shipment Confirmed');
    end;

    [Test]
    procedure PostingSalesOrderSucceedsWhenShipmentConfirmed()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [GIVEN] a Sales Order where Shipment Confirmed is ticked
        CreateSalesOrder(SalesHeader, SalesLine, true);

        // [WHEN] the order is posted
        PostSalesOrder(SalesHeader);

        // [THEN] no error occurs - reaching this line is the assertion
    end;

    local procedure CreateShipmentNote(var ShipmentNote: Record "ABC Shipment Note"; Description: Text[100]; ShipmentDate: Date; CustomerNo: Code[20])
    begin
        EnsureNoSeriesConfigured();

        ShipmentNote.Init();
        ShipmentNote.Insert(true);
        ShipmentNote.Description := Description;
        ShipmentNote."Shipment Date" := ShipmentDate;
        ShipmentNote."Customer No." := CustomerNo;
        ShipmentNote.Modify(true);
    end;

    local procedure EnsureNoSeriesConfigured()
    var
        ABCSetup: Record "ABC Setup";
    begin
        ABCSetup.GetSetup();
        if ABCSetup."Shipment Note Nos." = '' then begin
            ABCSetup."Shipment Note Nos." := CreateNoSeries();
            ABCSetup.Modify();
        end;
    end;

    local procedure CreateNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Init();
        NoSeries.Code := 'ABC-SHIPNOTE';
        NoSeries.Description := 'Shipment Note Test Series';
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := 'SN00001';
        NoSeriesLine."Ending No." := 'SN99999';
        NoSeriesLine.Insert(true);

        exit(NoSeries.Code);
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := CreateUniqueCode();
        Customer.Insert(true);
        Customer.Validate(Name, 'Test Customer ' + Customer."No.");
        Customer.Validate("Customer Posting Group", 'DOMESTIC');
        Customer.Validate("Gen. Bus. Posting Group", 'DOMESTIC');
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateItem(): Code[20]
    var
        Item: Record Item;
    begin
        Item.Init();
        Item."No." := CreateUniqueCode();
        Item.Insert(true);
        Item.Validate(Description, 'Test Item ' + Item."No.");
        Item.Validate("Gen. Prod. Posting Group", 'SERVICES');
        Item.Validate("Inventory Posting Group", 'RESALE');
        Item.Validate("Base Unit of Measure", 'BOX');
        Item.Modify(true);
        exit(Item."No.");
    end;

    local procedure CreateUniqueCode(): Code[20]
    begin
        // Sidesteps any dependency on number-series setup for Customer/Item/Sales
        // Header - this test app never needs those series configured.
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20));
    end;

    local procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShipmentConfirmed: Boolean)
    var
        ABCSetup: Record "ABC Setup";
    begin
        ABCSetup.GetSetup();
        ABCSetup."Require Shipment Confirmation" := true;
        ABCSetup.Modify();

        CreateSalesOrderHeader(SalesHeader, CreateCustomer());
        CreateSalesOrderLine(SalesLine, SalesHeader, CreateItem());

        SalesHeader."ABC Shipment Confirmed" := ShipmentConfirmed;
        SalesHeader.Modify();
    end;

    local procedure CreateSalesOrderHeader(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20])
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := CreateUniqueCode();
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Modify(true);
    end;

    local procedure CreateSalesOrderLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; ItemNo: Code[20])
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        SalesLine.Validate("Unit of Measure Code", 'BOX');
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);
    end;

    local procedure PostSalesOrder(var SalesHeader: Record "Sales Header")
    begin
        // Mirrors what Library - Sales.PostSalesDocument(SalesHeader, true, true) does
        // internally: set the posting flags the base Sales-Post codeunit reads, then run it.
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify();
        Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
    end;

    // ------------------------------------------------------------------
    // Local assertion helpers - no Codeunit "Library Assert" dependency.
    // ------------------------------------------------------------------

    local procedure VerifyLastErrorContains(ExpectedTextPart: Text)
    var
        ActualError: Text;
        AssertFailedErr: Label 'Assertion failed. Expected error text to contain "%1", but the actual error was: "%2".';
    begin
        ActualError := GetLastErrorText();
        if StrPos(ActualError, ExpectedTextPart) = 0 then
            Error(AssertFailedErr, ExpectedTextPart, ActualError);
    end;

    local procedure VerifyStatusEqual(Expected: Enum "ABC Shipment Note Status"; Actual: Enum "ABC Shipment Note Status"; FailureMessage: Text)
    var
        AssertFailedErr: Label 'Assertion failed: %1 Expected: %2. Actual: %3.';
    begin
        if Expected <> Actual then
            Error(AssertFailedErr, FailureMessage, Format(Expected), Format(Actual));
    end;

    local procedure VerifyCodeNotBlank(Value: Code[20]; FailureMessage: Text)
    var
        AssertFailedErr: Label 'Assertion failed: %1';
    begin
        if Value = '' then
            Error(AssertFailedErr, FailureMessage);
    end;

    local procedure VerifyCodesNotEqual(Value1: Code[20]; Value2: Code[20]; FailureMessage: Text)
    var
        AssertFailedErr: Label 'Assertion failed: %1 Both values were "%2".';
    begin
        if Value1 = Value2 then
            Error(AssertFailedErr, FailureMessage, Value1);
    end;
}
