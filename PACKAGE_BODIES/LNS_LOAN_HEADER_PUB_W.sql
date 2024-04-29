--------------------------------------------------------
--  DDL for Package Body LNS_LOAN_HEADER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_LOAN_HEADER_PUB_W" as
  /* $Header: LNS_LNHDR_PUBJ_B.pls 120.6.12010000.4 2010/03/19 08:38:36 gparuchu ship $ */
  procedure create_loan(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  DATE
    , p1_a23  DATE
    , p1_a24  DATE
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  NUMBER
    , p1_a29  VARCHAR2
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  DATE
    , p1_a35  NUMBER
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  VARCHAR2
    , p1_a57  DATE
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  VARCHAR2
    , p1_a64  DATE
    , p1_a65  VARCHAR2
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  DATE
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  NUMBER
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  NUMBER
    , p1_a83  VARCHAR2
    , p1_a84  DATE
    , p1_a85  NUMBER
    , p1_a86  VARCHAR2
    , p1_a87  DATE
    , p1_a88  VARCHAR2
    , p1_a89  DATE
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  NUMBER
    , p1_a96  VARCHAR2
    , p1_a97  NUMBER
    , x_loan_id out nocopy  NUMBER
    , x_loan_number out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_header_rec lns_loan_header_pub.loan_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loan_header_rec.loan_id := p1_a0;
    ddp_loan_header_rec.org_id := p1_a1;
    ddp_loan_header_rec.loan_number := p1_a2;
    ddp_loan_header_rec.loan_description := p1_a3;
    ddp_loan_header_rec.loan_application_date := p1_a4;
    ddp_loan_header_rec.end_date := p1_a5;
    ddp_loan_header_rec.initial_loan_balance := p1_a6;
    ddp_loan_header_rec.last_payment_date := p1_a7;
    ddp_loan_header_rec.last_payment_amount := p1_a8;
    ddp_loan_header_rec.loan_term := p1_a9;
    ddp_loan_header_rec.loan_term_period := p1_a10;
    ddp_loan_header_rec.amortized_term := p1_a11;
    ddp_loan_header_rec.amortized_term_period := p1_a12;
    ddp_loan_header_rec.loan_status := p1_a13;
    ddp_loan_header_rec.loan_assigned_to := p1_a14;
    ddp_loan_header_rec.loan_currency := p1_a15;
    ddp_loan_header_rec.loan_class_code := p1_a16;
    ddp_loan_header_rec.loan_type := p1_a17;
    ddp_loan_header_rec.loan_subtype := p1_a18;
    ddp_loan_header_rec.loan_purpose_code := p1_a19;
    ddp_loan_header_rec.cust_account_id := p1_a20;
    ddp_loan_header_rec.bill_to_acct_site_id := p1_a21;
    ddp_loan_header_rec.loan_maturity_date := p1_a22;
    ddp_loan_header_rec.loan_start_date := p1_a23;
    ddp_loan_header_rec.loan_closing_date := p1_a24;
    ddp_loan_header_rec.reference_id := p1_a25;
    ddp_loan_header_rec.reference_number := p1_a26;
    ddp_loan_header_rec.reference_description := p1_a27;
    ddp_loan_header_rec.reference_amount := p1_a28;
    ddp_loan_header_rec.product_flag := p1_a29;
    ddp_loan_header_rec.primary_borrower_id := p1_a30;
    ddp_loan_header_rec.product_id := p1_a31;
    ddp_loan_header_rec.requested_amount := p1_a32;
    ddp_loan_header_rec.funded_amount := p1_a33;
    ddp_loan_header_rec.loan_approval_date := p1_a34;
    ddp_loan_header_rec.loan_approved_by := p1_a35;
    ddp_loan_header_rec.attribute_category := p1_a36;
    ddp_loan_header_rec.attribute1 := p1_a37;
    ddp_loan_header_rec.attribute2 := p1_a38;
    ddp_loan_header_rec.attribute3 := p1_a39;
    ddp_loan_header_rec.attribute4 := p1_a40;
    ddp_loan_header_rec.attribute5 := p1_a41;
    ddp_loan_header_rec.attribute6 := p1_a42;
    ddp_loan_header_rec.attribute7 := p1_a43;
    ddp_loan_header_rec.attribute8 := p1_a44;
    ddp_loan_header_rec.attribute9 := p1_a45;
    ddp_loan_header_rec.attribute10 := p1_a46;
    ddp_loan_header_rec.attribute11 := p1_a47;
    ddp_loan_header_rec.attribute12 := p1_a48;
    ddp_loan_header_rec.attribute13 := p1_a49;
    ddp_loan_header_rec.attribute14 := p1_a50;
    ddp_loan_header_rec.attribute15 := p1_a51;
    ddp_loan_header_rec.attribute16 := p1_a52;
    ddp_loan_header_rec.attribute17 := p1_a53;
    ddp_loan_header_rec.attribute18 := p1_a54;
    ddp_loan_header_rec.attribute19 := p1_a55;
    ddp_loan_header_rec.attribute20 := p1_a56;
    ddp_loan_header_rec.last_billed_date := p1_a57;
    ddp_loan_header_rec.custom_payments_flag := p1_a58;
    ddp_loan_header_rec.billed_flag := p1_a59;
    ddp_loan_header_rec.reference_name := p1_a60;
    ddp_loan_header_rec.reference_type := p1_a61;
    ddp_loan_header_rec.reference_type_id := p1_a62;
    ddp_loan_header_rec.ussgl_transaction_code := p1_a63;
    ddp_loan_header_rec.gl_date := p1_a64;
    ddp_loan_header_rec.rec_adjustment_number := p1_a65;
    ddp_loan_header_rec.contact_rel_party_id := p1_a66;
    ddp_loan_header_rec.contact_pers_party_id := p1_a67;
    ddp_loan_header_rec.credit_review_flag := p1_a68;
    ddp_loan_header_rec.exchange_rate_type := p1_a69;
    ddp_loan_header_rec.exchange_date := p1_a70;
    ddp_loan_header_rec.exchange_rate := p1_a71;
    ddp_loan_header_rec.collateral_percent := p1_a72;
    ddp_loan_header_rec.last_payment_number := p1_a73;
    ddp_loan_header_rec.last_amortization_id := p1_a74;
    ddp_loan_header_rec.legal_entity_id := p1_a75;
    ddp_loan_header_rec.open_to_term_flag := p1_a76;
    ddp_loan_header_rec.multiple_funding_flag := p1_a77;
    ddp_loan_header_rec.loan_type_id := p1_a78;
    ddp_loan_header_rec.secondary_status := p1_a79;
    ddp_loan_header_rec.open_to_term_event := p1_a80;
    ddp_loan_header_rec.balloon_payment_type := p1_a81;
    ddp_loan_header_rec.balloon_payment_amount := p1_a82;
    ddp_loan_header_rec.current_phase := p1_a83;
    ddp_loan_header_rec.open_loan_start_date := p1_a84;
    ddp_loan_header_rec.open_loan_term := p1_a85;
    ddp_loan_header_rec.open_loan_term_period := p1_a86;
    ddp_loan_header_rec.open_maturity_date := p1_a87;
    ddp_loan_header_rec.funds_reserved_flag := p1_a88;
    ddp_loan_header_rec.funds_check_date := p1_a89;
    ddp_loan_header_rec.subsidy_rate := p1_a90;
    ddp_loan_header_rec.application_id := p1_a91;
    ddp_loan_header_rec.created_by_module := p1_a92;
    ddp_loan_header_rec.party_type := p1_a93;
    ddp_loan_header_rec.forgiveness_flag := p1_a94;
    ddp_loan_header_rec.forgiveness_percent := p1_a95;
    ddp_loan_header_rec.disable_billing_flag := p1_a96;
    ddp_loan_header_rec.add_requested_amount := p1_a97;






    -- here's the delegated call to the old PL/SQL routine
    lns_loan_header_pub.create_loan(p_init_msg_list,
      ddp_loan_header_rec,
      x_loan_id,
      x_loan_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure update_loan(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  DATE
    , p1_a23  DATE
    , p1_a24  DATE
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  NUMBER
    , p1_a29  VARCHAR2
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  DATE
    , p1_a35  NUMBER
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  VARCHAR2
    , p1_a57  DATE
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  VARCHAR2
    , p1_a64  DATE
    , p1_a65  VARCHAR2
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  DATE
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  NUMBER
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  NUMBER
    , p1_a83  VARCHAR2
    , p1_a84  DATE
    , p1_a85  NUMBER
    , p1_a86  VARCHAR2
    , p1_a87  DATE
    , p1_a88  VARCHAR2
    , p1_a89  DATE
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  NUMBER
    , p1_a96  VARCHAR2
    , p1_a97  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_header_rec lns_loan_header_pub.loan_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loan_header_rec.loan_id := p1_a0;
    ddp_loan_header_rec.org_id := p1_a1;
    ddp_loan_header_rec.loan_number := p1_a2;
    ddp_loan_header_rec.loan_description := p1_a3;
    ddp_loan_header_rec.loan_application_date := p1_a4;
    ddp_loan_header_rec.end_date := p1_a5;
    ddp_loan_header_rec.initial_loan_balance := p1_a6;
    ddp_loan_header_rec.last_payment_date := p1_a7;
    ddp_loan_header_rec.last_payment_amount := p1_a8;
    ddp_loan_header_rec.loan_term := p1_a9;
    ddp_loan_header_rec.loan_term_period := p1_a10;
    ddp_loan_header_rec.amortized_term := p1_a11;
    ddp_loan_header_rec.amortized_term_period := p1_a12;
    ddp_loan_header_rec.loan_status := p1_a13;
    ddp_loan_header_rec.loan_assigned_to := p1_a14;
    ddp_loan_header_rec.loan_currency := p1_a15;
    ddp_loan_header_rec.loan_class_code := p1_a16;
    ddp_loan_header_rec.loan_type := p1_a17;
    ddp_loan_header_rec.loan_subtype := p1_a18;
    ddp_loan_header_rec.loan_purpose_code := p1_a19;
    ddp_loan_header_rec.cust_account_id := p1_a20;
    ddp_loan_header_rec.bill_to_acct_site_id := p1_a21;
    ddp_loan_header_rec.loan_maturity_date := p1_a22;
    ddp_loan_header_rec.loan_start_date := p1_a23;
    ddp_loan_header_rec.loan_closing_date := p1_a24;
    ddp_loan_header_rec.reference_id := p1_a25;
    ddp_loan_header_rec.reference_number := p1_a26;
    ddp_loan_header_rec.reference_description := p1_a27;
    ddp_loan_header_rec.reference_amount := p1_a28;
    ddp_loan_header_rec.product_flag := p1_a29;
    ddp_loan_header_rec.primary_borrower_id := p1_a30;
    ddp_loan_header_rec.product_id := p1_a31;
    ddp_loan_header_rec.requested_amount := p1_a32;
    ddp_loan_header_rec.funded_amount := p1_a33;
    ddp_loan_header_rec.loan_approval_date := p1_a34;
    ddp_loan_header_rec.loan_approved_by := p1_a35;
    ddp_loan_header_rec.attribute_category := p1_a36;
    ddp_loan_header_rec.attribute1 := p1_a37;
    ddp_loan_header_rec.attribute2 := p1_a38;
    ddp_loan_header_rec.attribute3 := p1_a39;
    ddp_loan_header_rec.attribute4 := p1_a40;
    ddp_loan_header_rec.attribute5 := p1_a41;
    ddp_loan_header_rec.attribute6 := p1_a42;
    ddp_loan_header_rec.attribute7 := p1_a43;
    ddp_loan_header_rec.attribute8 := p1_a44;
    ddp_loan_header_rec.attribute9 := p1_a45;
    ddp_loan_header_rec.attribute10 := p1_a46;
    ddp_loan_header_rec.attribute11 := p1_a47;
    ddp_loan_header_rec.attribute12 := p1_a48;
    ddp_loan_header_rec.attribute13 := p1_a49;
    ddp_loan_header_rec.attribute14 := p1_a50;
    ddp_loan_header_rec.attribute15 := p1_a51;
    ddp_loan_header_rec.attribute16 := p1_a52;
    ddp_loan_header_rec.attribute17 := p1_a53;
    ddp_loan_header_rec.attribute18 := p1_a54;
    ddp_loan_header_rec.attribute19 := p1_a55;
    ddp_loan_header_rec.attribute20 := p1_a56;
    ddp_loan_header_rec.last_billed_date := p1_a57;
    ddp_loan_header_rec.custom_payments_flag := p1_a58;
    ddp_loan_header_rec.billed_flag := p1_a59;
    ddp_loan_header_rec.reference_name := p1_a60;
    ddp_loan_header_rec.reference_type := p1_a61;
    ddp_loan_header_rec.reference_type_id := p1_a62;
    ddp_loan_header_rec.ussgl_transaction_code := p1_a63;
    ddp_loan_header_rec.gl_date := p1_a64;
    ddp_loan_header_rec.rec_adjustment_number := p1_a65;
    ddp_loan_header_rec.contact_rel_party_id := p1_a66;
    ddp_loan_header_rec.contact_pers_party_id := p1_a67;
    ddp_loan_header_rec.credit_review_flag := p1_a68;
    ddp_loan_header_rec.exchange_rate_type := p1_a69;
    ddp_loan_header_rec.exchange_date := p1_a70;
    ddp_loan_header_rec.exchange_rate := p1_a71;
    ddp_loan_header_rec.collateral_percent := p1_a72;
    ddp_loan_header_rec.last_payment_number := p1_a73;
    ddp_loan_header_rec.last_amortization_id := p1_a74;
    ddp_loan_header_rec.legal_entity_id := p1_a75;
    ddp_loan_header_rec.open_to_term_flag := p1_a76;
    ddp_loan_header_rec.multiple_funding_flag := p1_a77;
    ddp_loan_header_rec.loan_type_id := p1_a78;
    ddp_loan_header_rec.secondary_status := p1_a79;
    ddp_loan_header_rec.open_to_term_event := p1_a80;
    ddp_loan_header_rec.balloon_payment_type := p1_a81;
    ddp_loan_header_rec.balloon_payment_amount := p1_a82;
    ddp_loan_header_rec.current_phase := p1_a83;
    ddp_loan_header_rec.open_loan_start_date := p1_a84;
    ddp_loan_header_rec.open_loan_term := p1_a85;
    ddp_loan_header_rec.open_loan_term_period := p1_a86;
    ddp_loan_header_rec.open_maturity_date := p1_a87;
    ddp_loan_header_rec.funds_reserved_flag := p1_a88;
    ddp_loan_header_rec.funds_check_date := p1_a89;
    ddp_loan_header_rec.subsidy_rate := p1_a90;
    ddp_loan_header_rec.application_id := p1_a91;
    ddp_loan_header_rec.created_by_module := p1_a92;
    ddp_loan_header_rec.party_type := p1_a93;
    ddp_loan_header_rec.forgiveness_flag := p1_a94;
    ddp_loan_header_rec.forgiveness_percent := p1_a95;
    ddp_loan_header_rec.disable_billing_flag := p1_a96;
    ddp_loan_header_rec.add_requested_amount := p1_a97;





    -- here's the delegated call to the old PL/SQL routine
    lns_loan_header_pub.update_loan(p_init_msg_list,
      ddp_loan_header_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_loan(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  DATE
    , p1_a23  DATE
    , p1_a24  DATE
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  NUMBER
    , p1_a29  VARCHAR2
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  DATE
    , p1_a35  NUMBER
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  VARCHAR2
    , p1_a57  DATE
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  VARCHAR2
    , p1_a64  DATE
    , p1_a65  VARCHAR2
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  DATE
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  NUMBER
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  NUMBER
    , p1_a83  VARCHAR2
    , p1_a84  DATE
    , p1_a85  NUMBER
    , p1_a86  VARCHAR2
    , p1_a87  DATE
    , p1_a88  VARCHAR2
    , p1_a89  DATE
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  NUMBER
    , p1_a96  VARCHAR2
    , p1_a97  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loan_header_rec lns_loan_header_pub.loan_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loan_header_rec.loan_id := p1_a0;
    ddp_loan_header_rec.org_id := p1_a1;
    ddp_loan_header_rec.loan_number := p1_a2;
    ddp_loan_header_rec.loan_description := p1_a3;
    ddp_loan_header_rec.loan_application_date := p1_a4;
    ddp_loan_header_rec.end_date := p1_a5;
    ddp_loan_header_rec.initial_loan_balance := p1_a6;
    ddp_loan_header_rec.last_payment_date := p1_a7;
    ddp_loan_header_rec.last_payment_amount := p1_a8;
    ddp_loan_header_rec.loan_term := p1_a9;
    ddp_loan_header_rec.loan_term_period := p1_a10;
    ddp_loan_header_rec.amortized_term := p1_a11;
    ddp_loan_header_rec.amortized_term_period := p1_a12;
    ddp_loan_header_rec.loan_status := p1_a13;
    ddp_loan_header_rec.loan_assigned_to := p1_a14;
    ddp_loan_header_rec.loan_currency := p1_a15;
    ddp_loan_header_rec.loan_class_code := p1_a16;
    ddp_loan_header_rec.loan_type := p1_a17;
    ddp_loan_header_rec.loan_subtype := p1_a18;
    ddp_loan_header_rec.loan_purpose_code := p1_a19;
    ddp_loan_header_rec.cust_account_id := p1_a20;
    ddp_loan_header_rec.bill_to_acct_site_id := p1_a21;
    ddp_loan_header_rec.loan_maturity_date := p1_a22;
    ddp_loan_header_rec.loan_start_date := p1_a23;
    ddp_loan_header_rec.loan_closing_date := p1_a24;
    ddp_loan_header_rec.reference_id := p1_a25;
    ddp_loan_header_rec.reference_number := p1_a26;
    ddp_loan_header_rec.reference_description := p1_a27;
    ddp_loan_header_rec.reference_amount := p1_a28;
    ddp_loan_header_rec.product_flag := p1_a29;
    ddp_loan_header_rec.primary_borrower_id := p1_a30;
    ddp_loan_header_rec.product_id := p1_a31;
    ddp_loan_header_rec.requested_amount := p1_a32;
    ddp_loan_header_rec.funded_amount := p1_a33;
    ddp_loan_header_rec.loan_approval_date := p1_a34;
    ddp_loan_header_rec.loan_approved_by := p1_a35;
    ddp_loan_header_rec.attribute_category := p1_a36;
    ddp_loan_header_rec.attribute1 := p1_a37;
    ddp_loan_header_rec.attribute2 := p1_a38;
    ddp_loan_header_rec.attribute3 := p1_a39;
    ddp_loan_header_rec.attribute4 := p1_a40;
    ddp_loan_header_rec.attribute5 := p1_a41;
    ddp_loan_header_rec.attribute6 := p1_a42;
    ddp_loan_header_rec.attribute7 := p1_a43;
    ddp_loan_header_rec.attribute8 := p1_a44;
    ddp_loan_header_rec.attribute9 := p1_a45;
    ddp_loan_header_rec.attribute10 := p1_a46;
    ddp_loan_header_rec.attribute11 := p1_a47;
    ddp_loan_header_rec.attribute12 := p1_a48;
    ddp_loan_header_rec.attribute13 := p1_a49;
    ddp_loan_header_rec.attribute14 := p1_a50;
    ddp_loan_header_rec.attribute15 := p1_a51;
    ddp_loan_header_rec.attribute16 := p1_a52;
    ddp_loan_header_rec.attribute17 := p1_a53;
    ddp_loan_header_rec.attribute18 := p1_a54;
    ddp_loan_header_rec.attribute19 := p1_a55;
    ddp_loan_header_rec.attribute20 := p1_a56;
    ddp_loan_header_rec.last_billed_date := p1_a57;
    ddp_loan_header_rec.custom_payments_flag := p1_a58;
    ddp_loan_header_rec.billed_flag := p1_a59;
    ddp_loan_header_rec.reference_name := p1_a60;
    ddp_loan_header_rec.reference_type := p1_a61;
    ddp_loan_header_rec.reference_type_id := p1_a62;
    ddp_loan_header_rec.ussgl_transaction_code := p1_a63;
    ddp_loan_header_rec.gl_date := p1_a64;
    ddp_loan_header_rec.rec_adjustment_number := p1_a65;
    ddp_loan_header_rec.contact_rel_party_id := p1_a66;
    ddp_loan_header_rec.contact_pers_party_id := p1_a67;
    ddp_loan_header_rec.credit_review_flag := p1_a68;
    ddp_loan_header_rec.exchange_rate_type := p1_a69;
    ddp_loan_header_rec.exchange_date := p1_a70;
    ddp_loan_header_rec.exchange_rate := p1_a71;
    ddp_loan_header_rec.collateral_percent := p1_a72;
    ddp_loan_header_rec.last_payment_number := p1_a73;
    ddp_loan_header_rec.last_amortization_id := p1_a74;
    ddp_loan_header_rec.legal_entity_id := p1_a75;
    ddp_loan_header_rec.open_to_term_flag := p1_a76;
    ddp_loan_header_rec.multiple_funding_flag := p1_a77;
    ddp_loan_header_rec.loan_type_id := p1_a78;
    ddp_loan_header_rec.secondary_status := p1_a79;
    ddp_loan_header_rec.open_to_term_event := p1_a80;
    ddp_loan_header_rec.balloon_payment_type := p1_a81;
    ddp_loan_header_rec.balloon_payment_amount := p1_a82;
    ddp_loan_header_rec.current_phase := p1_a83;
    ddp_loan_header_rec.open_loan_start_date := p1_a84;
    ddp_loan_header_rec.open_loan_term := p1_a85;
    ddp_loan_header_rec.open_loan_term_period := p1_a86;
    ddp_loan_header_rec.open_maturity_date := p1_a87;
    ddp_loan_header_rec.funds_reserved_flag := p1_a88;
    ddp_loan_header_rec.funds_check_date := p1_a89;
    ddp_loan_header_rec.subsidy_rate := p1_a90;
    ddp_loan_header_rec.application_id := p1_a91;
    ddp_loan_header_rec.created_by_module := p1_a92;
    ddp_loan_header_rec.party_type := p1_a93;
    ddp_loan_header_rec.forgiveness_flag := p1_a94;
    ddp_loan_header_rec.forgiveness_percent := p1_a95;
    ddp_loan_header_rec.disable_billing_flag := p1_a96;
    ddp_loan_header_rec.add_requested_amount := p1_a97;




    -- here's the delegated call to the old PL/SQL routine
    lns_loan_header_pub.validate_loan(p_init_msg_list,
      ddp_loan_header_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure get_loan_header_rec(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  DATE
    , p2_a5 out nocopy  DATE
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  DATE
    , p2_a8 out nocopy  NUMBER
    , p2_a9 out nocopy  NUMBER
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  NUMBER
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  NUMBER
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  NUMBER
    , p2_a21 out nocopy  NUMBER
    , p2_a22 out nocopy  DATE
    , p2_a23 out nocopy  DATE
    , p2_a24 out nocopy  DATE
    , p2_a25 out nocopy  NUMBER
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  NUMBER
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  NUMBER
    , p2_a31 out nocopy  NUMBER
    , p2_a32 out nocopy  NUMBER
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  DATE
    , p2_a35 out nocopy  NUMBER
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  VARCHAR2
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  VARCHAR2
    , p2_a41 out nocopy  VARCHAR2
    , p2_a42 out nocopy  VARCHAR2
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  VARCHAR2
    , p2_a45 out nocopy  VARCHAR2
    , p2_a46 out nocopy  VARCHAR2
    , p2_a47 out nocopy  VARCHAR2
    , p2_a48 out nocopy  VARCHAR2
    , p2_a49 out nocopy  VARCHAR2
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  VARCHAR2
    , p2_a52 out nocopy  VARCHAR2
    , p2_a53 out nocopy  VARCHAR2
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  VARCHAR2
    , p2_a56 out nocopy  VARCHAR2
    , p2_a57 out nocopy  DATE
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , p2_a60 out nocopy  VARCHAR2
    , p2_a61 out nocopy  VARCHAR2
    , p2_a62 out nocopy  NUMBER
    , p2_a63 out nocopy  VARCHAR2
    , p2_a64 out nocopy  DATE
    , p2_a65 out nocopy  VARCHAR2
    , p2_a66 out nocopy  NUMBER
    , p2_a67 out nocopy  NUMBER
    , p2_a68 out nocopy  VARCHAR2
    , p2_a69 out nocopy  VARCHAR2
    , p2_a70 out nocopy  DATE
    , p2_a71 out nocopy  NUMBER
    , p2_a72 out nocopy  NUMBER
    , p2_a73 out nocopy  NUMBER
    , p2_a74 out nocopy  NUMBER
    , p2_a75 out nocopy  NUMBER
    , p2_a76 out nocopy  VARCHAR2
    , p2_a77 out nocopy  VARCHAR2
    , p2_a78 out nocopy  NUMBER
    , p2_a79 out nocopy  VARCHAR2
    , p2_a80 out nocopy  VARCHAR2
    , p2_a81 out nocopy  VARCHAR2
    , p2_a82 out nocopy  NUMBER
    , p2_a83 out nocopy  VARCHAR2
    , p2_a84 out nocopy  DATE
    , p2_a85 out nocopy  NUMBER
    , p2_a86 out nocopy  VARCHAR2
    , p2_a87 out nocopy  DATE
    , p2_a88 out nocopy  VARCHAR2
    , p2_a89 out nocopy  DATE
    , p2_a90 out nocopy  NUMBER
    , p2_a91 out nocopy  NUMBER
    , p2_a92 out nocopy  VARCHAR2
    , p2_a93 out nocopy  VARCHAR2
    , p2_a94 out nocopy  VARCHAR2
    , p2_a95 out nocopy  NUMBER
    , p2_a96 out nocopy  VARCHAR2
    , p2_a97 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_loan_header_rec lns_loan_header_pub.loan_header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    lns_loan_header_pub.get_loan_header_rec(p_init_msg_list,
      p_loan_id,
      ddx_loan_header_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddx_loan_header_rec.loan_id;
    p2_a1 := ddx_loan_header_rec.org_id;
    p2_a2 := ddx_loan_header_rec.loan_number;
    p2_a3 := ddx_loan_header_rec.loan_description;
    p2_a4 := ddx_loan_header_rec.loan_application_date;
    p2_a5 := ddx_loan_header_rec.end_date;
    p2_a6 := ddx_loan_header_rec.initial_loan_balance;
    p2_a7 := ddx_loan_header_rec.last_payment_date;
    p2_a8 := ddx_loan_header_rec.last_payment_amount;
    p2_a9 := ddx_loan_header_rec.loan_term;
    p2_a10 := ddx_loan_header_rec.loan_term_period;
    p2_a11 := ddx_loan_header_rec.amortized_term;
    p2_a12 := ddx_loan_header_rec.amortized_term_period;
    p2_a13 := ddx_loan_header_rec.loan_status;
    p2_a14 := ddx_loan_header_rec.loan_assigned_to;
    p2_a15 := ddx_loan_header_rec.loan_currency;
    p2_a16 := ddx_loan_header_rec.loan_class_code;
    p2_a17 := ddx_loan_header_rec.loan_type;
    p2_a18 := ddx_loan_header_rec.loan_subtype;
    p2_a19 := ddx_loan_header_rec.loan_purpose_code;
    p2_a20 := ddx_loan_header_rec.cust_account_id;
    p2_a21 := ddx_loan_header_rec.bill_to_acct_site_id;
    p2_a22 := ddx_loan_header_rec.loan_maturity_date;
    p2_a23 := ddx_loan_header_rec.loan_start_date;
    p2_a24 := ddx_loan_header_rec.loan_closing_date;
    p2_a25 := ddx_loan_header_rec.reference_id;
    p2_a26 := ddx_loan_header_rec.reference_number;
    p2_a27 := ddx_loan_header_rec.reference_description;
    p2_a28 := ddx_loan_header_rec.reference_amount;
    p2_a29 := ddx_loan_header_rec.product_flag;
    p2_a30 := ddx_loan_header_rec.primary_borrower_id;
    p2_a31 := ddx_loan_header_rec.product_id;
    p2_a32 := ddx_loan_header_rec.requested_amount;
    p2_a33 := ddx_loan_header_rec.funded_amount;
    p2_a34 := ddx_loan_header_rec.loan_approval_date;
    p2_a35 := ddx_loan_header_rec.loan_approved_by;
    p2_a36 := ddx_loan_header_rec.attribute_category;
    p2_a37 := ddx_loan_header_rec.attribute1;
    p2_a38 := ddx_loan_header_rec.attribute2;
    p2_a39 := ddx_loan_header_rec.attribute3;
    p2_a40 := ddx_loan_header_rec.attribute4;
    p2_a41 := ddx_loan_header_rec.attribute5;
    p2_a42 := ddx_loan_header_rec.attribute6;
    p2_a43 := ddx_loan_header_rec.attribute7;
    p2_a44 := ddx_loan_header_rec.attribute8;
    p2_a45 := ddx_loan_header_rec.attribute9;
    p2_a46 := ddx_loan_header_rec.attribute10;
    p2_a47 := ddx_loan_header_rec.attribute11;
    p2_a48 := ddx_loan_header_rec.attribute12;
    p2_a49 := ddx_loan_header_rec.attribute13;
    p2_a50 := ddx_loan_header_rec.attribute14;
    p2_a51 := ddx_loan_header_rec.attribute15;
    p2_a52 := ddx_loan_header_rec.attribute16;
    p2_a53 := ddx_loan_header_rec.attribute17;
    p2_a54 := ddx_loan_header_rec.attribute18;
    p2_a55 := ddx_loan_header_rec.attribute19;
    p2_a56 := ddx_loan_header_rec.attribute20;
    p2_a57 := ddx_loan_header_rec.last_billed_date;
    p2_a58 := ddx_loan_header_rec.custom_payments_flag;
    p2_a59 := ddx_loan_header_rec.billed_flag;
    p2_a60 := ddx_loan_header_rec.reference_name;
    p2_a61 := ddx_loan_header_rec.reference_type;
    p2_a62 := ddx_loan_header_rec.reference_type_id;
    p2_a63 := ddx_loan_header_rec.ussgl_transaction_code;
    p2_a64 := ddx_loan_header_rec.gl_date;
    p2_a65 := ddx_loan_header_rec.rec_adjustment_number;
    p2_a66 := ddx_loan_header_rec.contact_rel_party_id;
    p2_a67 := ddx_loan_header_rec.contact_pers_party_id;
    p2_a68 := ddx_loan_header_rec.credit_review_flag;
    p2_a69 := ddx_loan_header_rec.exchange_rate_type;
    p2_a70 := ddx_loan_header_rec.exchange_date;
    p2_a71 := ddx_loan_header_rec.exchange_rate;
    p2_a72 := ddx_loan_header_rec.collateral_percent;
    p2_a73 := ddx_loan_header_rec.last_payment_number;
    p2_a74 := ddx_loan_header_rec.last_amortization_id;
    p2_a75 := ddx_loan_header_rec.legal_entity_id;
    p2_a76 := ddx_loan_header_rec.open_to_term_flag;
    p2_a77 := ddx_loan_header_rec.multiple_funding_flag;
    p2_a78 := ddx_loan_header_rec.loan_type_id;
    p2_a79 := ddx_loan_header_rec.secondary_status;
    p2_a80 := ddx_loan_header_rec.open_to_term_event;
    p2_a81 := ddx_loan_header_rec.balloon_payment_type;
    p2_a82 := ddx_loan_header_rec.balloon_payment_amount;
    p2_a83 := ddx_loan_header_rec.current_phase;
    p2_a84 := ddx_loan_header_rec.open_loan_start_date;
    p2_a85 := ddx_loan_header_rec.open_loan_term;
    p2_a86 := ddx_loan_header_rec.open_loan_term_period;
    p2_a87 := ddx_loan_header_rec.open_maturity_date;
    p2_a88 := ddx_loan_header_rec.funds_reserved_flag;
    p2_a89 := ddx_loan_header_rec.funds_check_date;
    p2_a90 := ddx_loan_header_rec.subsidy_rate;
    p2_a91 := ddx_loan_header_rec.application_id;
    p2_a92 := ddx_loan_header_rec.created_by_module;
    p2_a93 := ddx_loan_header_rec.party_type;
    p2_a94 := ddx_loan_header_rec.forgiveness_flag;
    p2_a95 := ddx_loan_header_rec.forgiveness_percent;
    p2_a96 := ddx_loan_header_rec.disable_billing_flag;
    p2_a97 := ddx_loan_header_rec.add_requested_amount;



  end;

end lns_loan_header_pub_w;

/
