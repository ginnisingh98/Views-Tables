--------------------------------------------------------
--  DDL for Package Body AP_VENDOR_PUB_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_VENDOR_PUB_PKG_W" as
  /* $Header: appvndwb.pls 120.0.12000000.1 2007/04/24 19:05:31 xili noship $ */
  --Global constants for logging
  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_VENDOR_PUB_PKG_W';
  G_MSG_UERROR        CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_VENDOR_PUB_PKG_W';

  G_Vendor_Type_Lookup_Code VARCHAR2(30);

  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_vendor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  DATE
    , p7_a31  VARCHAR2
    , p7_a32  DATE
    , p7_a33  DATE
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  DATE
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  DATE
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  NUMBER
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  VARCHAR2
    , p7_a113  NUMBER
    , p7_a114  NUMBER
    , p7_a115  VARCHAR2
    , p7_a116  NUMBER
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  NUMBER
    , p7_a120  NUMBER
    , p7_a121  NUMBER
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  DATE
    , p7_a132  VARCHAR2
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , x_vendor_id out nocopy  NUMBER
    , x_party_id out nocopy  NUMBER
  )

  as
    ddp_vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vendor_rec.vendor_id := p7_a0;
    ddp_vendor_rec.segment1 := p7_a1;
    ddp_vendor_rec.vendor_name := p7_a2;
    ddp_vendor_rec.vendor_name_alt := p7_a3;
    ddp_vendor_rec.summary_flag := p7_a4;
    ddp_vendor_rec.enabled_flag := p7_a5;
    ddp_vendor_rec.segment2 := p7_a6;
    ddp_vendor_rec.segment3 := p7_a7;
    ddp_vendor_rec.segment4 := p7_a8;
    ddp_vendor_rec.segment5 := p7_a9;
    ddp_vendor_rec.employee_id := p7_a10;
    ddp_vendor_rec.vendor_type_lookup_code := p7_a11;
    ddp_vendor_rec.customer_num := p7_a12;
    ddp_vendor_rec.one_time_flag := p7_a13;
    ddp_vendor_rec.parent_vendor_id := p7_a14;
    ddp_vendor_rec.min_order_amount := p7_a15;
    ddp_vendor_rec.terms_id := p7_a16;
    ddp_vendor_rec.set_of_books_id := p7_a17;
    ddp_vendor_rec.always_take_disc_flag := p7_a18;
    ddp_vendor_rec.pay_date_basis_lookup_code := p7_a19;
    ddp_vendor_rec.pay_group_lookup_code := p7_a20;
    ddp_vendor_rec.payment_priority := p7_a21;
    ddp_vendor_rec.invoice_currency_code := p7_a22;
    ddp_vendor_rec.payment_currency_code := p7_a23;
    ddp_vendor_rec.invoice_amount_limit := p7_a24;
    ddp_vendor_rec.hold_all_payments_flag := p7_a25;
    ddp_vendor_rec.hold_future_payments_flag := p7_a26;
    ddp_vendor_rec.hold_reason := p7_a27;
    ddp_vendor_rec.type_1099 := p7_a28;
    ddp_vendor_rec.withholding_status_lookup_code := p7_a29;
    ddp_vendor_rec.withholding_start_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_vendor_rec.organization_type_lookup_code := p7_a31;
    ddp_vendor_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a32);
    ddp_vendor_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a33);
    ddp_vendor_rec.minority_group_lookup_code := p7_a34;
    ddp_vendor_rec.women_owned_flag := p7_a35;
    ddp_vendor_rec.small_business_flag := p7_a36;
    ddp_vendor_rec.hold_flag := p7_a37;
    ddp_vendor_rec.purchasing_hold_reason := p7_a38;
    ddp_vendor_rec.hold_by := p7_a39;
    ddp_vendor_rec.hold_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_vendor_rec.terms_date_basis := p7_a41;
    ddp_vendor_rec.inspection_required_flag := p7_a42;
    ddp_vendor_rec.receipt_required_flag := p7_a43;
    ddp_vendor_rec.qty_rcv_tolerance := p7_a44;
    ddp_vendor_rec.qty_rcv_exception_code := p7_a45;
    ddp_vendor_rec.enforce_ship_to_location_code := p7_a46;
    ddp_vendor_rec.days_early_receipt_allowed := p7_a47;
    ddp_vendor_rec.days_late_receipt_allowed := p7_a48;
    ddp_vendor_rec.receipt_days_exception_code := p7_a49;
    ddp_vendor_rec.receiving_routing_id := p7_a50;
    ddp_vendor_rec.allow_substitute_receipts_flag := p7_a51;
    ddp_vendor_rec.allow_unordered_receipts_flag := p7_a52;
    ddp_vendor_rec.hold_unmatched_invoices_flag := p7_a53;
    ddp_vendor_rec.tax_verification_date := rosetta_g_miss_date_in_map(p7_a54);
    ddp_vendor_rec.name_control := p7_a55;
    ddp_vendor_rec.state_reportable_flag := p7_a56;
    ddp_vendor_rec.federal_reportable_flag := p7_a57;
    ddp_vendor_rec.attribute_category := p7_a58;
    ddp_vendor_rec.attribute1 := p7_a59;
    ddp_vendor_rec.attribute2 := p7_a60;
    ddp_vendor_rec.attribute3 := p7_a61;
    ddp_vendor_rec.attribute4 := p7_a62;
    ddp_vendor_rec.attribute5 := p7_a63;
    ddp_vendor_rec.attribute6 := p7_a64;
    ddp_vendor_rec.attribute7 := p7_a65;
    ddp_vendor_rec.attribute8 := p7_a66;
    ddp_vendor_rec.attribute9 := p7_a67;
    ddp_vendor_rec.attribute10 := p7_a68;
    ddp_vendor_rec.attribute11 := p7_a69;
    ddp_vendor_rec.attribute12 := p7_a70;
    ddp_vendor_rec.attribute13 := p7_a71;
    ddp_vendor_rec.attribute14 := p7_a72;
    ddp_vendor_rec.attribute15 := p7_a73;
    ddp_vendor_rec.auto_calculate_interest_flag := p7_a74;
    ddp_vendor_rec.validation_number := p7_a75;
    ddp_vendor_rec.exclude_freight_from_discount := p7_a76;
    ddp_vendor_rec.tax_reporting_name := p7_a77;
    ddp_vendor_rec.check_digits := p7_a78;
    ddp_vendor_rec.allow_awt_flag := p7_a79;
    ddp_vendor_rec.awt_group_id := p7_a80;
    ddp_vendor_rec.awt_group_name := p7_a81;
    ddp_vendor_rec.global_attribute1 := p7_a82;
    ddp_vendor_rec.global_attribute2 := p7_a83;
    ddp_vendor_rec.global_attribute3 := p7_a84;
    ddp_vendor_rec.global_attribute4 := p7_a85;
    ddp_vendor_rec.global_attribute5 := p7_a86;
    ddp_vendor_rec.global_attribute6 := p7_a87;
    ddp_vendor_rec.global_attribute7 := p7_a88;
    ddp_vendor_rec.global_attribute8 := p7_a89;
    ddp_vendor_rec.global_attribute9 := p7_a90;
    ddp_vendor_rec.global_attribute10 := p7_a91;
    ddp_vendor_rec.global_attribute11 := p7_a92;
    ddp_vendor_rec.global_attribute12 := p7_a93;
    ddp_vendor_rec.global_attribute13 := p7_a94;
    ddp_vendor_rec.global_attribute14 := p7_a95;
    ddp_vendor_rec.global_attribute15 := p7_a96;
    ddp_vendor_rec.global_attribute16 := p7_a97;
    ddp_vendor_rec.global_attribute17 := p7_a98;
    ddp_vendor_rec.global_attribute18 := p7_a99;
    ddp_vendor_rec.global_attribute19 := p7_a100;
    ddp_vendor_rec.global_attribute20 := p7_a101;
    ddp_vendor_rec.global_attribute_category := p7_a102;
    ddp_vendor_rec.bank_charge_bearer := p7_a103;
    ddp_vendor_rec.match_option := p7_a104;
    ddp_vendor_rec.create_debit_memo_flag := p7_a105;
    ddp_vendor_rec.party_id := p7_a106;
    ddp_vendor_rec.parent_party_id := p7_a107;
    ddp_vendor_rec.jgzz_fiscal_code := p7_a108;
    ddp_vendor_rec.sic_code := p7_a109;
    ddp_vendor_rec.tax_reference := p7_a110;
    ddp_vendor_rec.inventory_organization_id := p7_a111;
    ddp_vendor_rec.terms_name := p7_a112;
    ddp_vendor_rec.default_terms_id := p7_a113;
    ddp_vendor_rec.vendor_interface_id := p7_a114;
    ddp_vendor_rec.ni_number := p7_a115;
    ddp_vendor_rec.ext_payee_rec.payee_party_id := p7_a116;
    ddp_vendor_rec.ext_payee_rec.payment_function := p7_a117;
    ddp_vendor_rec.ext_payee_rec.exclusive_pay_flag := p7_a118;
    ddp_vendor_rec.ext_payee_rec.payee_party_site_id := p7_a119;
    ddp_vendor_rec.ext_payee_rec.supplier_site_id := p7_a120;
    ddp_vendor_rec.ext_payee_rec.payer_org_id := p7_a121;
    ddp_vendor_rec.ext_payee_rec.payer_org_type := p7_a122;
    ddp_vendor_rec.ext_payee_rec.default_pmt_method := p7_a123;
    ddp_vendor_rec.ext_payee_rec.ece_tp_loc_code := p7_a124;
    ddp_vendor_rec.ext_payee_rec.bank_charge_bearer := p7_a125;
    ddp_vendor_rec.ext_payee_rec.bank_instr1_code := p7_a126;
    ddp_vendor_rec.ext_payee_rec.bank_instr2_code := p7_a127;
    ddp_vendor_rec.ext_payee_rec.bank_instr_detail := p7_a128;
    ddp_vendor_rec.ext_payee_rec.pay_reason_code := p7_a129;
    ddp_vendor_rec.ext_payee_rec.pay_reason_com := p7_a130;
    ddp_vendor_rec.ext_payee_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a131);
    ddp_vendor_rec.ext_payee_rec.pay_message1 := p7_a132;
    ddp_vendor_rec.ext_payee_rec.pay_message2 := p7_a133;
    ddp_vendor_rec.ext_payee_rec.pay_message3 := p7_a134;
    ddp_vendor_rec.ext_payee_rec.delivery_channel := p7_a135;
    ddp_vendor_rec.ext_payee_rec.pmt_format := p7_a136;
    ddp_vendor_rec.ext_payee_rec.settlement_priority := p7_a137;



    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.create_vendor(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vendor_rec,
      x_vendor_id,
      x_party_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_vendor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  DATE
    , p7_a31  VARCHAR2
    , p7_a32  DATE
    , p7_a33  DATE
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  DATE
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  DATE
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  NUMBER
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  VARCHAR2
    , p7_a113  NUMBER
    , p7_a114  NUMBER
    , p7_a115  VARCHAR2
    , p7_a116  NUMBER
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  NUMBER
    , p7_a120  NUMBER
    , p7_a121  NUMBER
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  DATE
    , p7_a132  VARCHAR2
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , p_vendor_id  NUMBER
  )

  as
    ddp_vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;
    ddindx binary_integer; indx binary_integer;
    l_debug_info               VARCHAR2(2000);
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Update_Vendor_W';
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vendor_rec.vendor_id := p7_a0;
    ddp_vendor_rec.segment1 := p7_a1;
    ddp_vendor_rec.vendor_name := p7_a2;
    ddp_vendor_rec.vendor_name_alt := p7_a3;
    ddp_vendor_rec.summary_flag := p7_a4;
    ddp_vendor_rec.enabled_flag := p7_a5;
    ddp_vendor_rec.segment2 := p7_a6;
    ddp_vendor_rec.segment3 := p7_a7;
    ddp_vendor_rec.segment4 := p7_a8;
    ddp_vendor_rec.segment5 := p7_a9;
    ddp_vendor_rec.employee_id := p7_a10;
    ddp_vendor_rec.vendor_type_lookup_code := p7_a11;
    ddp_vendor_rec.customer_num := p7_a12;
    ddp_vendor_rec.one_time_flag := p7_a13;
    ddp_vendor_rec.parent_vendor_id := p7_a14;
    ddp_vendor_rec.min_order_amount := p7_a15;
    ddp_vendor_rec.terms_id := p7_a16;
    ddp_vendor_rec.set_of_books_id := p7_a17;
    ddp_vendor_rec.always_take_disc_flag := p7_a18;
    ddp_vendor_rec.pay_date_basis_lookup_code := p7_a19;
    ddp_vendor_rec.pay_group_lookup_code := p7_a20;
    ddp_vendor_rec.payment_priority := p7_a21;
    ddp_vendor_rec.invoice_currency_code := p7_a22;
    ddp_vendor_rec.payment_currency_code := p7_a23;
    ddp_vendor_rec.invoice_amount_limit := p7_a24;
    ddp_vendor_rec.hold_all_payments_flag := p7_a25;
    ddp_vendor_rec.hold_future_payments_flag := p7_a26;
    ddp_vendor_rec.hold_reason := p7_a27;
    ddp_vendor_rec.type_1099 := p7_a28;
    ddp_vendor_rec.withholding_status_lookup_code := p7_a29;
    ddp_vendor_rec.withholding_start_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_vendor_rec.organization_type_lookup_code := p7_a31;
    ddp_vendor_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a32);
    ddp_vendor_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a33);
    ddp_vendor_rec.minority_group_lookup_code := p7_a34;
    ddp_vendor_rec.women_owned_flag := p7_a35;
    ddp_vendor_rec.small_business_flag := p7_a36;
    ddp_vendor_rec.hold_flag := p7_a37;
    ddp_vendor_rec.purchasing_hold_reason := p7_a38;
    ddp_vendor_rec.hold_by := p7_a39;
    ddp_vendor_rec.hold_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_vendor_rec.terms_date_basis := p7_a41;
    ddp_vendor_rec.inspection_required_flag := p7_a42;
    ddp_vendor_rec.receipt_required_flag := p7_a43;
    ddp_vendor_rec.qty_rcv_tolerance := p7_a44;
    ddp_vendor_rec.qty_rcv_exception_code := p7_a45;
    ddp_vendor_rec.enforce_ship_to_location_code := p7_a46;
    ddp_vendor_rec.days_early_receipt_allowed := p7_a47;
    ddp_vendor_rec.days_late_receipt_allowed := p7_a48;
    ddp_vendor_rec.receipt_days_exception_code := p7_a49;
    ddp_vendor_rec.receiving_routing_id := p7_a50;
    ddp_vendor_rec.allow_substitute_receipts_flag := p7_a51;
    ddp_vendor_rec.allow_unordered_receipts_flag := p7_a52;
    ddp_vendor_rec.hold_unmatched_invoices_flag := p7_a53;
    ddp_vendor_rec.tax_verification_date := rosetta_g_miss_date_in_map(p7_a54);
    ddp_vendor_rec.name_control := p7_a55;
    ddp_vendor_rec.state_reportable_flag := p7_a56;
    ddp_vendor_rec.federal_reportable_flag := p7_a57;
    ddp_vendor_rec.attribute_category := p7_a58;
    ddp_vendor_rec.attribute1 := p7_a59;
    ddp_vendor_rec.attribute2 := p7_a60;
    ddp_vendor_rec.attribute3 := p7_a61;
    ddp_vendor_rec.attribute4 := p7_a62;
    ddp_vendor_rec.attribute5 := p7_a63;
    ddp_vendor_rec.attribute6 := p7_a64;
    ddp_vendor_rec.attribute7 := p7_a65;
    ddp_vendor_rec.attribute8 := p7_a66;
    ddp_vendor_rec.attribute9 := p7_a67;
    ddp_vendor_rec.attribute10 := p7_a68;
    ddp_vendor_rec.attribute11 := p7_a69;
    ddp_vendor_rec.attribute12 := p7_a70;
    ddp_vendor_rec.attribute13 := p7_a71;
    ddp_vendor_rec.attribute14 := p7_a72;
    ddp_vendor_rec.attribute15 := p7_a73;
    ddp_vendor_rec.auto_calculate_interest_flag := p7_a74;
    ddp_vendor_rec.validation_number := p7_a75;
    ddp_vendor_rec.exclude_freight_from_discount := p7_a76;
    ddp_vendor_rec.tax_reporting_name := p7_a77;
    ddp_vendor_rec.check_digits := p7_a78;
    ddp_vendor_rec.allow_awt_flag := p7_a79;
    ddp_vendor_rec.awt_group_id := p7_a80;
    ddp_vendor_rec.awt_group_name := p7_a81;
    ddp_vendor_rec.global_attribute1 := p7_a82;
    ddp_vendor_rec.global_attribute2 := p7_a83;
    ddp_vendor_rec.global_attribute3 := p7_a84;
    ddp_vendor_rec.global_attribute4 := p7_a85;
    ddp_vendor_rec.global_attribute5 := p7_a86;
    ddp_vendor_rec.global_attribute6 := p7_a87;
    ddp_vendor_rec.global_attribute7 := p7_a88;
    ddp_vendor_rec.global_attribute8 := p7_a89;
    ddp_vendor_rec.global_attribute9 := p7_a90;
    ddp_vendor_rec.global_attribute10 := p7_a91;
    ddp_vendor_rec.global_attribute11 := p7_a92;
    ddp_vendor_rec.global_attribute12 := p7_a93;
    ddp_vendor_rec.global_attribute13 := p7_a94;
    ddp_vendor_rec.global_attribute14 := p7_a95;
    ddp_vendor_rec.global_attribute15 := p7_a96;
    ddp_vendor_rec.global_attribute16 := p7_a97;
    ddp_vendor_rec.global_attribute17 := p7_a98;
    ddp_vendor_rec.global_attribute18 := p7_a99;
    ddp_vendor_rec.global_attribute19 := p7_a100;
    ddp_vendor_rec.global_attribute20 := p7_a101;
    ddp_vendor_rec.global_attribute_category := p7_a102;
    ddp_vendor_rec.bank_charge_bearer := p7_a103;
    ddp_vendor_rec.match_option := p7_a104;
    ddp_vendor_rec.create_debit_memo_flag := p7_a105;
    ddp_vendor_rec.party_id := p7_a106;
    ddp_vendor_rec.parent_party_id := p7_a107;
    ddp_vendor_rec.jgzz_fiscal_code := p7_a108;
    ddp_vendor_rec.sic_code := p7_a109;
    ddp_vendor_rec.tax_reference := p7_a110;
    ddp_vendor_rec.inventory_organization_id := p7_a111;
    ddp_vendor_rec.terms_name := p7_a112;
    ddp_vendor_rec.default_terms_id := p7_a113;
    ddp_vendor_rec.vendor_interface_id := p7_a114;
    ddp_vendor_rec.ni_number := p7_a115;
    ddp_vendor_rec.ext_payee_rec.payee_party_id := p7_a116;
    ddp_vendor_rec.ext_payee_rec.payment_function := p7_a117;
    ddp_vendor_rec.ext_payee_rec.exclusive_pay_flag := p7_a118;
    ddp_vendor_rec.ext_payee_rec.payee_party_site_id := p7_a119;
    ddp_vendor_rec.ext_payee_rec.supplier_site_id := p7_a120;
    ddp_vendor_rec.ext_payee_rec.payer_org_id := p7_a121;
    ddp_vendor_rec.ext_payee_rec.payer_org_type := p7_a122;
    ddp_vendor_rec.ext_payee_rec.default_pmt_method := p7_a123;
    ddp_vendor_rec.ext_payee_rec.ece_tp_loc_code := p7_a124;
    ddp_vendor_rec.ext_payee_rec.bank_charge_bearer := p7_a125;
    ddp_vendor_rec.ext_payee_rec.bank_instr1_code := p7_a126;
    ddp_vendor_rec.ext_payee_rec.bank_instr2_code := p7_a127;
    ddp_vendor_rec.ext_payee_rec.bank_instr_detail := p7_a128;
    ddp_vendor_rec.ext_payee_rec.pay_reason_code := p7_a129;
    ddp_vendor_rec.ext_payee_rec.pay_reason_com := p7_a130;
    ddp_vendor_rec.ext_payee_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a131);
    ddp_vendor_rec.ext_payee_rec.pay_message1 := p7_a132;
    ddp_vendor_rec.ext_payee_rec.pay_message2 := p7_a133;
    ddp_vendor_rec.ext_payee_rec.pay_message3 := p7_a134;
    ddp_vendor_rec.ext_payee_rec.delivery_channel := p7_a135;
    ddp_vendor_rec.ext_payee_rec.pmt_format := p7_a136;
    ddp_vendor_rec.ext_payee_rec.settlement_priority := p7_a137;

-- xili - test begin
   SELECT to_char(sysdate, 'MON-DD-YYYY HH24:MI:SS')
     INTO l_debug_info
     FROM DUAL;
   l_debug_info := 'xili#1: Before update_vendor, parent_vendor_id=='||ddp_vendor_rec.parent_vendor_id||' -- ' || l_debug_info;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- xili - test end

    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.update_vendor(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vendor_rec,
      p_vendor_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_vendor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  NUMBER
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  NUMBER
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  NUMBER
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  DATE
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  DATE
    , p7_a33 in out nocopy  DATE
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  VARCHAR2
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  NUMBER
    , p7_a40 in out nocopy  DATE
    , p7_a41 in out nocopy  VARCHAR2
    , p7_a42 in out nocopy  VARCHAR2
    , p7_a43 in out nocopy  VARCHAR2
    , p7_a44 in out nocopy  NUMBER
    , p7_a45 in out nocopy  VARCHAR2
    , p7_a46 in out nocopy  VARCHAR2
    , p7_a47 in out nocopy  NUMBER
    , p7_a48 in out nocopy  NUMBER
    , p7_a49 in out nocopy  VARCHAR2
    , p7_a50 in out nocopy  NUMBER
    , p7_a51 in out nocopy  VARCHAR2
    , p7_a52 in out nocopy  VARCHAR2
    , p7_a53 in out nocopy  VARCHAR2
    , p7_a54 in out nocopy  DATE
    , p7_a55 in out nocopy  VARCHAR2
    , p7_a56 in out nocopy  VARCHAR2
    , p7_a57 in out nocopy  VARCHAR2
    , p7_a58 in out nocopy  VARCHAR2
    , p7_a59 in out nocopy  VARCHAR2
    , p7_a60 in out nocopy  VARCHAR2
    , p7_a61 in out nocopy  VARCHAR2
    , p7_a62 in out nocopy  VARCHAR2
    , p7_a63 in out nocopy  VARCHAR2
    , p7_a64 in out nocopy  VARCHAR2
    , p7_a65 in out nocopy  VARCHAR2
    , p7_a66 in out nocopy  VARCHAR2
    , p7_a67 in out nocopy  VARCHAR2
    , p7_a68 in out nocopy  VARCHAR2
    , p7_a69 in out nocopy  VARCHAR2
    , p7_a70 in out nocopy  VARCHAR2
    , p7_a71 in out nocopy  VARCHAR2
    , p7_a72 in out nocopy  VARCHAR2
    , p7_a73 in out nocopy  VARCHAR2
    , p7_a74 in out nocopy  VARCHAR2
    , p7_a75 in out nocopy  NUMBER
    , p7_a76 in out nocopy  VARCHAR2
    , p7_a77 in out nocopy  VARCHAR2
    , p7_a78 in out nocopy  VARCHAR2
    , p7_a79 in out nocopy  VARCHAR2
    , p7_a80 in out nocopy  NUMBER
    , p7_a81 in out nocopy  VARCHAR2
    , p7_a82 in out nocopy  VARCHAR2
    , p7_a83 in out nocopy  VARCHAR2
    , p7_a84 in out nocopy  VARCHAR2
    , p7_a85 in out nocopy  VARCHAR2
    , p7_a86 in out nocopy  VARCHAR2
    , p7_a87 in out nocopy  VARCHAR2
    , p7_a88 in out nocopy  VARCHAR2
    , p7_a89 in out nocopy  VARCHAR2
    , p7_a90 in out nocopy  VARCHAR2
    , p7_a91 in out nocopy  VARCHAR2
    , p7_a92 in out nocopy  VARCHAR2
    , p7_a93 in out nocopy  VARCHAR2
    , p7_a94 in out nocopy  VARCHAR2
    , p7_a95 in out nocopy  VARCHAR2
    , p7_a96 in out nocopy  VARCHAR2
    , p7_a97 in out nocopy  VARCHAR2
    , p7_a98 in out nocopy  VARCHAR2
    , p7_a99 in out nocopy  VARCHAR2
    , p7_a100 in out nocopy  VARCHAR2
    , p7_a101 in out nocopy  VARCHAR2
    , p7_a102 in out nocopy  VARCHAR2
    , p7_a103 in out nocopy  VARCHAR2
    , p7_a104 in out nocopy  VARCHAR2
    , p7_a105 in out nocopy  VARCHAR2
    , p7_a106 in out nocopy  NUMBER
    , p7_a107 in out nocopy  NUMBER
    , p7_a108 in out nocopy  VARCHAR2
    , p7_a109 in out nocopy  VARCHAR2
    , p7_a110 in out nocopy  VARCHAR2
    , p7_a111 in out nocopy  NUMBER
    , p7_a112 in out nocopy  VARCHAR2
    , p7_a113 in out nocopy  NUMBER
    , p7_a114 in out nocopy  NUMBER
    , p7_a115 in out nocopy  VARCHAR2
    , p7_a116 in out nocopy  NUMBER
    , p7_a117 in out nocopy  VARCHAR2
    , p7_a118 in out nocopy  VARCHAR2
    , p7_a119 in out nocopy  NUMBER
    , p7_a120 in out nocopy  NUMBER
    , p7_a121 in out nocopy  NUMBER
    , p7_a122 in out nocopy  VARCHAR2
    , p7_a123 in out nocopy  VARCHAR2
    , p7_a124 in out nocopy  VARCHAR2
    , p7_a125 in out nocopy  VARCHAR2
    , p7_a126 in out nocopy  VARCHAR2
    , p7_a127 in out nocopy  VARCHAR2
    , p7_a128 in out nocopy  VARCHAR2
    , p7_a129 in out nocopy  VARCHAR2
    , p7_a130 in out nocopy  VARCHAR2
    , p7_a131 in out nocopy  DATE
    , p7_a132 in out nocopy  VARCHAR2
    , p7_a133 in out nocopy  VARCHAR2
    , p7_a134 in out nocopy  VARCHAR2
    , p7_a135 in out nocopy  VARCHAR2
    , p7_a136 in out nocopy  VARCHAR2
    , p7_a137 in out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p_calling_prog  VARCHAR2
    , x_party_valid out nocopy  VARCHAR2
    , x_payee_valid out nocopy  VARCHAR2
    , p_vendor_id  NUMBER
  )

  as
    ddp_vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vendor_rec.vendor_id := p7_a0;
    ddp_vendor_rec.segment1 := p7_a1;
    ddp_vendor_rec.vendor_name := p7_a2;
    ddp_vendor_rec.vendor_name_alt := p7_a3;
    ddp_vendor_rec.summary_flag := p7_a4;
    ddp_vendor_rec.enabled_flag := p7_a5;
    ddp_vendor_rec.segment2 := p7_a6;
    ddp_vendor_rec.segment3 := p7_a7;
    ddp_vendor_rec.segment4 := p7_a8;
    ddp_vendor_rec.segment5 := p7_a9;
    ddp_vendor_rec.employee_id := p7_a10;
    ddp_vendor_rec.vendor_type_lookup_code := p7_a11;
    ddp_vendor_rec.customer_num := p7_a12;
    ddp_vendor_rec.one_time_flag := p7_a13;
    ddp_vendor_rec.parent_vendor_id := p7_a14;
    ddp_vendor_rec.min_order_amount := p7_a15;
    ddp_vendor_rec.terms_id := p7_a16;
    ddp_vendor_rec.set_of_books_id := p7_a17;
    ddp_vendor_rec.always_take_disc_flag := p7_a18;
    ddp_vendor_rec.pay_date_basis_lookup_code := p7_a19;
    ddp_vendor_rec.pay_group_lookup_code := p7_a20;
    ddp_vendor_rec.payment_priority := p7_a21;
    ddp_vendor_rec.invoice_currency_code := p7_a22;
    ddp_vendor_rec.payment_currency_code := p7_a23;
    ddp_vendor_rec.invoice_amount_limit := p7_a24;
    ddp_vendor_rec.hold_all_payments_flag := p7_a25;
    ddp_vendor_rec.hold_future_payments_flag := p7_a26;
    ddp_vendor_rec.hold_reason := p7_a27;
    ddp_vendor_rec.type_1099 := p7_a28;
    ddp_vendor_rec.withholding_status_lookup_code := p7_a29;
    ddp_vendor_rec.withholding_start_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_vendor_rec.organization_type_lookup_code := p7_a31;
    ddp_vendor_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a32);
    ddp_vendor_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a33);
    ddp_vendor_rec.minority_group_lookup_code := p7_a34;
    ddp_vendor_rec.women_owned_flag := p7_a35;
    ddp_vendor_rec.small_business_flag := p7_a36;
    ddp_vendor_rec.hold_flag := p7_a37;
    ddp_vendor_rec.purchasing_hold_reason := p7_a38;
    ddp_vendor_rec.hold_by := p7_a39;
    ddp_vendor_rec.hold_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_vendor_rec.terms_date_basis := p7_a41;
    ddp_vendor_rec.inspection_required_flag := p7_a42;
    ddp_vendor_rec.receipt_required_flag := p7_a43;
    ddp_vendor_rec.qty_rcv_tolerance := p7_a44;
    ddp_vendor_rec.qty_rcv_exception_code := p7_a45;
    ddp_vendor_rec.enforce_ship_to_location_code := p7_a46;
    ddp_vendor_rec.days_early_receipt_allowed := p7_a47;
    ddp_vendor_rec.days_late_receipt_allowed := p7_a48;
    ddp_vendor_rec.receipt_days_exception_code := p7_a49;
    ddp_vendor_rec.receiving_routing_id := p7_a50;
    ddp_vendor_rec.allow_substitute_receipts_flag := p7_a51;
    ddp_vendor_rec.allow_unordered_receipts_flag := p7_a52;
    ddp_vendor_rec.hold_unmatched_invoices_flag := p7_a53;
    ddp_vendor_rec.tax_verification_date := rosetta_g_miss_date_in_map(p7_a54);
    ddp_vendor_rec.name_control := p7_a55;
    ddp_vendor_rec.state_reportable_flag := p7_a56;
    ddp_vendor_rec.federal_reportable_flag := p7_a57;
    ddp_vendor_rec.attribute_category := p7_a58;
    ddp_vendor_rec.attribute1 := p7_a59;
    ddp_vendor_rec.attribute2 := p7_a60;
    ddp_vendor_rec.attribute3 := p7_a61;
    ddp_vendor_rec.attribute4 := p7_a62;
    ddp_vendor_rec.attribute5 := p7_a63;
    ddp_vendor_rec.attribute6 := p7_a64;
    ddp_vendor_rec.attribute7 := p7_a65;
    ddp_vendor_rec.attribute8 := p7_a66;
    ddp_vendor_rec.attribute9 := p7_a67;
    ddp_vendor_rec.attribute10 := p7_a68;
    ddp_vendor_rec.attribute11 := p7_a69;
    ddp_vendor_rec.attribute12 := p7_a70;
    ddp_vendor_rec.attribute13 := p7_a71;
    ddp_vendor_rec.attribute14 := p7_a72;
    ddp_vendor_rec.attribute15 := p7_a73;
    ddp_vendor_rec.auto_calculate_interest_flag := p7_a74;
    ddp_vendor_rec.validation_number := p7_a75;
    ddp_vendor_rec.exclude_freight_from_discount := p7_a76;
    ddp_vendor_rec.tax_reporting_name := p7_a77;
    ddp_vendor_rec.check_digits := p7_a78;
    ddp_vendor_rec.allow_awt_flag := p7_a79;
    ddp_vendor_rec.awt_group_id := p7_a80;
    ddp_vendor_rec.awt_group_name := p7_a81;
    ddp_vendor_rec.global_attribute1 := p7_a82;
    ddp_vendor_rec.global_attribute2 := p7_a83;
    ddp_vendor_rec.global_attribute3 := p7_a84;
    ddp_vendor_rec.global_attribute4 := p7_a85;
    ddp_vendor_rec.global_attribute5 := p7_a86;
    ddp_vendor_rec.global_attribute6 := p7_a87;
    ddp_vendor_rec.global_attribute7 := p7_a88;
    ddp_vendor_rec.global_attribute8 := p7_a89;
    ddp_vendor_rec.global_attribute9 := p7_a90;
    ddp_vendor_rec.global_attribute10 := p7_a91;
    ddp_vendor_rec.global_attribute11 := p7_a92;
    ddp_vendor_rec.global_attribute12 := p7_a93;
    ddp_vendor_rec.global_attribute13 := p7_a94;
    ddp_vendor_rec.global_attribute14 := p7_a95;
    ddp_vendor_rec.global_attribute15 := p7_a96;
    ddp_vendor_rec.global_attribute16 := p7_a97;
    ddp_vendor_rec.global_attribute17 := p7_a98;
    ddp_vendor_rec.global_attribute18 := p7_a99;
    ddp_vendor_rec.global_attribute19 := p7_a100;
    ddp_vendor_rec.global_attribute20 := p7_a101;
    ddp_vendor_rec.global_attribute_category := p7_a102;
    ddp_vendor_rec.bank_charge_bearer := p7_a103;
    ddp_vendor_rec.match_option := p7_a104;
    ddp_vendor_rec.create_debit_memo_flag := p7_a105;
    ddp_vendor_rec.party_id := p7_a106;
    ddp_vendor_rec.parent_party_id := p7_a107;
    ddp_vendor_rec.jgzz_fiscal_code := p7_a108;
    ddp_vendor_rec.sic_code := p7_a109;
    ddp_vendor_rec.tax_reference := p7_a110;
    ddp_vendor_rec.inventory_organization_id := p7_a111;
    ddp_vendor_rec.terms_name := p7_a112;
    ddp_vendor_rec.default_terms_id := p7_a113;
    ddp_vendor_rec.vendor_interface_id := p7_a114;
    ddp_vendor_rec.ni_number := p7_a115;
    ddp_vendor_rec.ext_payee_rec.payee_party_id := p7_a116;
    ddp_vendor_rec.ext_payee_rec.payment_function := p7_a117;
    ddp_vendor_rec.ext_payee_rec.exclusive_pay_flag := p7_a118;
    ddp_vendor_rec.ext_payee_rec.payee_party_site_id := p7_a119;
    ddp_vendor_rec.ext_payee_rec.supplier_site_id := p7_a120;
    ddp_vendor_rec.ext_payee_rec.payer_org_id := p7_a121;
    ddp_vendor_rec.ext_payee_rec.payer_org_type := p7_a122;
    ddp_vendor_rec.ext_payee_rec.default_pmt_method := p7_a123;
    ddp_vendor_rec.ext_payee_rec.ece_tp_loc_code := p7_a124;
    ddp_vendor_rec.ext_payee_rec.bank_charge_bearer := p7_a125;
    ddp_vendor_rec.ext_payee_rec.bank_instr1_code := p7_a126;
    ddp_vendor_rec.ext_payee_rec.bank_instr2_code := p7_a127;
    ddp_vendor_rec.ext_payee_rec.bank_instr_detail := p7_a128;
    ddp_vendor_rec.ext_payee_rec.pay_reason_code := p7_a129;
    ddp_vendor_rec.ext_payee_rec.pay_reason_com := p7_a130;
    ddp_vendor_rec.ext_payee_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a131);
    ddp_vendor_rec.ext_payee_rec.pay_message1 := p7_a132;
    ddp_vendor_rec.ext_payee_rec.pay_message2 := p7_a133;
    ddp_vendor_rec.ext_payee_rec.pay_message3 := p7_a134;
    ddp_vendor_rec.ext_payee_rec.delivery_channel := p7_a135;
    ddp_vendor_rec.ext_payee_rec.pmt_format := p7_a136;
    ddp_vendor_rec.ext_payee_rec.settlement_priority := p7_a137;






    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.validate_vendor(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vendor_rec,
      p_mode,
      p_calling_prog,
      x_party_valid,
      x_payee_valid,
      p_vendor_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_vendor_rec.vendor_id;
    p7_a1 := ddp_vendor_rec.segment1;
    p7_a2 := ddp_vendor_rec.vendor_name;
    p7_a3 := ddp_vendor_rec.vendor_name_alt;
    p7_a4 := ddp_vendor_rec.summary_flag;
    p7_a5 := ddp_vendor_rec.enabled_flag;
    p7_a6 := ddp_vendor_rec.segment2;
    p7_a7 := ddp_vendor_rec.segment3;
    p7_a8 := ddp_vendor_rec.segment4;
    p7_a9 := ddp_vendor_rec.segment5;
    p7_a10 := ddp_vendor_rec.employee_id;
    p7_a11 := ddp_vendor_rec.vendor_type_lookup_code;
    p7_a12 := ddp_vendor_rec.customer_num;
    p7_a13 := ddp_vendor_rec.one_time_flag;
    p7_a14 := ddp_vendor_rec.parent_vendor_id;
    p7_a15 := ddp_vendor_rec.min_order_amount;
    p7_a16 := ddp_vendor_rec.terms_id;
    p7_a17 := ddp_vendor_rec.set_of_books_id;
    p7_a18 := ddp_vendor_rec.always_take_disc_flag;
    p7_a19 := ddp_vendor_rec.pay_date_basis_lookup_code;
    p7_a20 := ddp_vendor_rec.pay_group_lookup_code;
    p7_a21 := ddp_vendor_rec.payment_priority;
    p7_a22 := ddp_vendor_rec.invoice_currency_code;
    p7_a23 := ddp_vendor_rec.payment_currency_code;
    p7_a24 := ddp_vendor_rec.invoice_amount_limit;
    p7_a25 := ddp_vendor_rec.hold_all_payments_flag;
    p7_a26 := ddp_vendor_rec.hold_future_payments_flag;
    p7_a27 := ddp_vendor_rec.hold_reason;
    p7_a28 := ddp_vendor_rec.type_1099;
    p7_a29 := ddp_vendor_rec.withholding_status_lookup_code;
    p7_a30 := ddp_vendor_rec.withholding_start_date;
    p7_a31 := ddp_vendor_rec.organization_type_lookup_code;
    p7_a32 := ddp_vendor_rec.start_date_active;
    p7_a33 := ddp_vendor_rec.end_date_active;
    p7_a34 := ddp_vendor_rec.minority_group_lookup_code;
    p7_a35 := ddp_vendor_rec.women_owned_flag;
    p7_a36 := ddp_vendor_rec.small_business_flag;
    p7_a37 := ddp_vendor_rec.hold_flag;
    p7_a38 := ddp_vendor_rec.purchasing_hold_reason;
    p7_a39 := ddp_vendor_rec.hold_by;
    p7_a40 := ddp_vendor_rec.hold_date;
    p7_a41 := ddp_vendor_rec.terms_date_basis;
    p7_a42 := ddp_vendor_rec.inspection_required_flag;
    p7_a43 := ddp_vendor_rec.receipt_required_flag;
    p7_a44 := ddp_vendor_rec.qty_rcv_tolerance;
    p7_a45 := ddp_vendor_rec.qty_rcv_exception_code;
    p7_a46 := ddp_vendor_rec.enforce_ship_to_location_code;
    p7_a47 := ddp_vendor_rec.days_early_receipt_allowed;
    p7_a48 := ddp_vendor_rec.days_late_receipt_allowed;
    p7_a49 := ddp_vendor_rec.receipt_days_exception_code;
    p7_a50 := ddp_vendor_rec.receiving_routing_id;
    p7_a51 := ddp_vendor_rec.allow_substitute_receipts_flag;
    p7_a52 := ddp_vendor_rec.allow_unordered_receipts_flag;
    p7_a53 := ddp_vendor_rec.hold_unmatched_invoices_flag;
    p7_a54 := ddp_vendor_rec.tax_verification_date;
    p7_a55 := ddp_vendor_rec.name_control;
    p7_a56 := ddp_vendor_rec.state_reportable_flag;
    p7_a57 := ddp_vendor_rec.federal_reportable_flag;
    p7_a58 := ddp_vendor_rec.attribute_category;
    p7_a59 := ddp_vendor_rec.attribute1;
    p7_a60 := ddp_vendor_rec.attribute2;
    p7_a61 := ddp_vendor_rec.attribute3;
    p7_a62 := ddp_vendor_rec.attribute4;
    p7_a63 := ddp_vendor_rec.attribute5;
    p7_a64 := ddp_vendor_rec.attribute6;
    p7_a65 := ddp_vendor_rec.attribute7;
    p7_a66 := ddp_vendor_rec.attribute8;
    p7_a67 := ddp_vendor_rec.attribute9;
    p7_a68 := ddp_vendor_rec.attribute10;
    p7_a69 := ddp_vendor_rec.attribute11;
    p7_a70 := ddp_vendor_rec.attribute12;
    p7_a71 := ddp_vendor_rec.attribute13;
    p7_a72 := ddp_vendor_rec.attribute14;
    p7_a73 := ddp_vendor_rec.attribute15;
    p7_a74 := ddp_vendor_rec.auto_calculate_interest_flag;
    p7_a75 := ddp_vendor_rec.validation_number;
    p7_a76 := ddp_vendor_rec.exclude_freight_from_discount;
    p7_a77 := ddp_vendor_rec.tax_reporting_name;
    p7_a78 := ddp_vendor_rec.check_digits;
    p7_a79 := ddp_vendor_rec.allow_awt_flag;
    p7_a80 := ddp_vendor_rec.awt_group_id;
    p7_a81 := ddp_vendor_rec.awt_group_name;
    p7_a82 := ddp_vendor_rec.global_attribute1;
    p7_a83 := ddp_vendor_rec.global_attribute2;
    p7_a84 := ddp_vendor_rec.global_attribute3;
    p7_a85 := ddp_vendor_rec.global_attribute4;
    p7_a86 := ddp_vendor_rec.global_attribute5;
    p7_a87 := ddp_vendor_rec.global_attribute6;
    p7_a88 := ddp_vendor_rec.global_attribute7;
    p7_a89 := ddp_vendor_rec.global_attribute8;
    p7_a90 := ddp_vendor_rec.global_attribute9;
    p7_a91 := ddp_vendor_rec.global_attribute10;
    p7_a92 := ddp_vendor_rec.global_attribute11;
    p7_a93 := ddp_vendor_rec.global_attribute12;
    p7_a94 := ddp_vendor_rec.global_attribute13;
    p7_a95 := ddp_vendor_rec.global_attribute14;
    p7_a96 := ddp_vendor_rec.global_attribute15;
    p7_a97 := ddp_vendor_rec.global_attribute16;
    p7_a98 := ddp_vendor_rec.global_attribute17;
    p7_a99 := ddp_vendor_rec.global_attribute18;
    p7_a100 := ddp_vendor_rec.global_attribute19;
    p7_a101 := ddp_vendor_rec.global_attribute20;
    p7_a102 := ddp_vendor_rec.global_attribute_category;
    p7_a103 := ddp_vendor_rec.bank_charge_bearer;
    p7_a104 := ddp_vendor_rec.match_option;
    p7_a105 := ddp_vendor_rec.create_debit_memo_flag;
    p7_a106 := ddp_vendor_rec.party_id;
    p7_a107 := ddp_vendor_rec.parent_party_id;
    p7_a108 := ddp_vendor_rec.jgzz_fiscal_code;
    p7_a109 := ddp_vendor_rec.sic_code;
    p7_a110 := ddp_vendor_rec.tax_reference;
    p7_a111 := ddp_vendor_rec.inventory_organization_id;
    p7_a112 := ddp_vendor_rec.terms_name;
    p7_a113 := ddp_vendor_rec.default_terms_id;
    p7_a114 := ddp_vendor_rec.vendor_interface_id;
    p7_a115 := ddp_vendor_rec.ni_number;
    p7_a116 := ddp_vendor_rec.ext_payee_rec.payee_party_id;
    p7_a117 := ddp_vendor_rec.ext_payee_rec.payment_function;
    p7_a118 := ddp_vendor_rec.ext_payee_rec.exclusive_pay_flag;
    p7_a119 := ddp_vendor_rec.ext_payee_rec.payee_party_site_id;
    p7_a120 := ddp_vendor_rec.ext_payee_rec.supplier_site_id;
    p7_a121 := ddp_vendor_rec.ext_payee_rec.payer_org_id;
    p7_a122 := ddp_vendor_rec.ext_payee_rec.payer_org_type;
    p7_a123 := ddp_vendor_rec.ext_payee_rec.default_pmt_method;
    p7_a124 := ddp_vendor_rec.ext_payee_rec.ece_tp_loc_code;
    p7_a125 := ddp_vendor_rec.ext_payee_rec.bank_charge_bearer;
    p7_a126 := ddp_vendor_rec.ext_payee_rec.bank_instr1_code;
    p7_a127 := ddp_vendor_rec.ext_payee_rec.bank_instr2_code;
    p7_a128 := ddp_vendor_rec.ext_payee_rec.bank_instr_detail;
    p7_a129 := ddp_vendor_rec.ext_payee_rec.pay_reason_code;
    p7_a130 := ddp_vendor_rec.ext_payee_rec.pay_reason_com;
    p7_a131 := ddp_vendor_rec.ext_payee_rec.inactive_date;
    p7_a132 := ddp_vendor_rec.ext_payee_rec.pay_message1;
    p7_a133 := ddp_vendor_rec.ext_payee_rec.pay_message2;
    p7_a134 := ddp_vendor_rec.ext_payee_rec.pay_message3;
    p7_a135 := ddp_vendor_rec.ext_payee_rec.delivery_channel;
    p7_a136 := ddp_vendor_rec.ext_payee_rec.pmt_format;
    p7_a137 := ddp_vendor_rec.ext_payee_rec.settlement_priority;





  end;

  procedure create_vendor_site(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  DATE
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  NUMBER
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  VARCHAR2
    , p7_a112  VARCHAR2
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  NUMBER
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  NUMBER
    , p7_a123  NUMBER
    , p7_a124  NUMBER
    , p7_a125  NUMBER
    , p7_a126  VARCHAR2
    , p7_a127  NUMBER
    , p7_a128  NUMBER
    , p7_a129  NUMBER
    , p7_a130  VARCHAR2
    , p7_a131  VARCHAR2
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  NUMBER
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , p7_a144  DATE
    , p7_a145  VARCHAR2
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p7_a148  VARCHAR2
    , p7_a149  VARCHAR2
    , p7_a150  VARCHAR2
    , p7_a151  NUMBER
    , p7_a152  NUMBER
    , p7_a153  VARCHAR2
    , p7_a154  NUMBER
    , x_vendor_site_id out nocopy  NUMBER
    , x_party_site_id out nocopy  NUMBER
    , x_location_id out nocopy  NUMBER
  )

  as
    ddp_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vendor_site_rec.area_code := p7_a0;
    ddp_vendor_site_rec.phone := p7_a1;
    ddp_vendor_site_rec.customer_num := p7_a2;
    ddp_vendor_site_rec.ship_to_location_id := p7_a3;
    ddp_vendor_site_rec.bill_to_location_id := p7_a4;
    ddp_vendor_site_rec.ship_via_lookup_code := p7_a5;
    ddp_vendor_site_rec.freight_terms_lookup_code := p7_a6;
    ddp_vendor_site_rec.fob_lookup_code := p7_a7;
    ddp_vendor_site_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_vendor_site_rec.fax := p7_a9;
    ddp_vendor_site_rec.fax_area_code := p7_a10;
    ddp_vendor_site_rec.telex := p7_a11;
    ddp_vendor_site_rec.terms_date_basis := p7_a12;
    ddp_vendor_site_rec.distribution_set_id := p7_a13;
    ddp_vendor_site_rec.accts_pay_code_combination_id := p7_a14;
    ddp_vendor_site_rec.prepay_code_combination_id := p7_a15;
    ddp_vendor_site_rec.pay_group_lookup_code := p7_a16;
    ddp_vendor_site_rec.payment_priority := p7_a17;
    ddp_vendor_site_rec.terms_id := p7_a18;
    ddp_vendor_site_rec.invoice_amount_limit := p7_a19;
    ddp_vendor_site_rec.pay_date_basis_lookup_code := p7_a20;
    ddp_vendor_site_rec.always_take_disc_flag := p7_a21;
    ddp_vendor_site_rec.invoice_currency_code := p7_a22;
    ddp_vendor_site_rec.payment_currency_code := p7_a23;
    ddp_vendor_site_rec.vendor_site_id := p7_a24;
    ddp_vendor_site_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a25);
    ddp_vendor_site_rec.last_updated_by := p7_a26;
    ddp_vendor_site_rec.vendor_id := p7_a27;
    ddp_vendor_site_rec.vendor_site_code := p7_a28;
    ddp_vendor_site_rec.vendor_site_code_alt := p7_a29;
    ddp_vendor_site_rec.purchasing_site_flag := p7_a30;
    ddp_vendor_site_rec.rfq_only_site_flag := p7_a31;
    ddp_vendor_site_rec.pay_site_flag := p7_a32;
    ddp_vendor_site_rec.attention_ar_flag := p7_a33;
    ddp_vendor_site_rec.hold_all_payments_flag := p7_a34;
    ddp_vendor_site_rec.hold_future_payments_flag := p7_a35;
    ddp_vendor_site_rec.hold_reason := p7_a36;
    ddp_vendor_site_rec.hold_unmatched_invoices_flag := p7_a37;
    ddp_vendor_site_rec.tax_reporting_site_flag := p7_a38;
    ddp_vendor_site_rec.attribute_category := p7_a39;
    ddp_vendor_site_rec.attribute1 := p7_a40;
    ddp_vendor_site_rec.attribute2 := p7_a41;
    ddp_vendor_site_rec.attribute3 := p7_a42;
    ddp_vendor_site_rec.attribute4 := p7_a43;
    ddp_vendor_site_rec.attribute5 := p7_a44;
    ddp_vendor_site_rec.attribute6 := p7_a45;
    ddp_vendor_site_rec.attribute7 := p7_a46;
    ddp_vendor_site_rec.attribute8 := p7_a47;
    ddp_vendor_site_rec.attribute9 := p7_a48;
    ddp_vendor_site_rec.attribute10 := p7_a49;
    ddp_vendor_site_rec.attribute11 := p7_a50;
    ddp_vendor_site_rec.attribute12 := p7_a51;
    ddp_vendor_site_rec.attribute13 := p7_a52;
    ddp_vendor_site_rec.attribute14 := p7_a53;
    ddp_vendor_site_rec.attribute15 := p7_a54;
    ddp_vendor_site_rec.validation_number := p7_a55;
    ddp_vendor_site_rec.exclude_freight_from_discount := p7_a56;
    ddp_vendor_site_rec.bank_charge_bearer := p7_a57;
    ddp_vendor_site_rec.org_id := p7_a58;
    ddp_vendor_site_rec.check_digits := p7_a59;
    ddp_vendor_site_rec.allow_awt_flag := p7_a60;
    ddp_vendor_site_rec.awt_group_id := p7_a61;
    ddp_vendor_site_rec.default_pay_site_id := p7_a62;
    ddp_vendor_site_rec.pay_on_code := p7_a63;
    ddp_vendor_site_rec.pay_on_receipt_summary_code := p7_a64;
    ddp_vendor_site_rec.global_attribute_category := p7_a65;
    ddp_vendor_site_rec.global_attribute1 := p7_a66;
    ddp_vendor_site_rec.global_attribute2 := p7_a67;
    ddp_vendor_site_rec.global_attribute3 := p7_a68;
    ddp_vendor_site_rec.global_attribute4 := p7_a69;
    ddp_vendor_site_rec.global_attribute5 := p7_a70;
    ddp_vendor_site_rec.global_attribute6 := p7_a71;
    ddp_vendor_site_rec.global_attribute7 := p7_a72;
    ddp_vendor_site_rec.global_attribute8 := p7_a73;
    ddp_vendor_site_rec.global_attribute9 := p7_a74;
    ddp_vendor_site_rec.global_attribute10 := p7_a75;
    ddp_vendor_site_rec.global_attribute11 := p7_a76;
    ddp_vendor_site_rec.global_attribute12 := p7_a77;
    ddp_vendor_site_rec.global_attribute13 := p7_a78;
    ddp_vendor_site_rec.global_attribute14 := p7_a79;
    ddp_vendor_site_rec.global_attribute15 := p7_a80;
    ddp_vendor_site_rec.global_attribute16 := p7_a81;
    ddp_vendor_site_rec.global_attribute17 := p7_a82;
    ddp_vendor_site_rec.global_attribute18 := p7_a83;
    ddp_vendor_site_rec.global_attribute19 := p7_a84;
    ddp_vendor_site_rec.global_attribute20 := p7_a85;
    ddp_vendor_site_rec.tp_header_id := p7_a86;
    ddp_vendor_site_rec.ece_tp_location_code := p7_a87;
    ddp_vendor_site_rec.pcard_site_flag := p7_a88;
    ddp_vendor_site_rec.match_option := p7_a89;
    ddp_vendor_site_rec.country_of_origin_code := p7_a90;
    ddp_vendor_site_rec.future_dated_payment_ccid := p7_a91;
    ddp_vendor_site_rec.create_debit_memo_flag := p7_a92;
    ddp_vendor_site_rec.supplier_notif_method := p7_a93;
    ddp_vendor_site_rec.email_address := p7_a94;
    ddp_vendor_site_rec.primary_pay_site_flag := p7_a95;
    ddp_vendor_site_rec.shipping_control := p7_a96;
    ddp_vendor_site_rec.selling_company_identifier := p7_a97;
    ddp_vendor_site_rec.gapless_inv_num_flag := p7_a98;
    ddp_vendor_site_rec.location_id := p7_a99;
    ddp_vendor_site_rec.party_site_id := p7_a100;
    ddp_vendor_site_rec.org_name := p7_a101;
    ddp_vendor_site_rec.duns_number := p7_a102;
    ddp_vendor_site_rec.address_style := p7_a103;
    ddp_vendor_site_rec.language := p7_a104;
    ddp_vendor_site_rec.province := p7_a105;
    ddp_vendor_site_rec.country := p7_a106;
    ddp_vendor_site_rec.address_line1 := p7_a107;
    ddp_vendor_site_rec.address_line2 := p7_a108;
    ddp_vendor_site_rec.address_line3 := p7_a109;
    ddp_vendor_site_rec.address_line4 := p7_a110;
    ddp_vendor_site_rec.address_lines_alt := p7_a111;
    ddp_vendor_site_rec.county := p7_a112;
    ddp_vendor_site_rec.city := p7_a113;
    ddp_vendor_site_rec.state := p7_a114;
    ddp_vendor_site_rec.zip := p7_a115;
    ddp_vendor_site_rec.terms_name := p7_a116;
    ddp_vendor_site_rec.default_terms_id := p7_a117;
    ddp_vendor_site_rec.awt_group_name := p7_a118;
    ddp_vendor_site_rec.distribution_set_name := p7_a119;
    ddp_vendor_site_rec.ship_to_location_code := p7_a120;
    ddp_vendor_site_rec.bill_to_location_code := p7_a121;
    ddp_vendor_site_rec.default_dist_set_id := p7_a122;
    ddp_vendor_site_rec.default_ship_to_loc_id := p7_a123;
    ddp_vendor_site_rec.default_bill_to_loc_id := p7_a124;
    ddp_vendor_site_rec.tolerance_id := p7_a125;
    ddp_vendor_site_rec.tolerance_name := p7_a126;
    ddp_vendor_site_rec.vendor_interface_id := p7_a127;
    ddp_vendor_site_rec.vendor_site_interface_id := p7_a128;
    ddp_vendor_site_rec.ext_payee_rec.payee_party_id := p7_a129;
    ddp_vendor_site_rec.ext_payee_rec.payment_function := p7_a130;
    ddp_vendor_site_rec.ext_payee_rec.exclusive_pay_flag := p7_a131;
    ddp_vendor_site_rec.ext_payee_rec.payee_party_site_id := p7_a132;
    ddp_vendor_site_rec.ext_payee_rec.supplier_site_id := p7_a133;
    ddp_vendor_site_rec.ext_payee_rec.payer_org_id := p7_a134;
    ddp_vendor_site_rec.ext_payee_rec.payer_org_type := p7_a135;
    ddp_vendor_site_rec.ext_payee_rec.default_pmt_method := p7_a136;
    ddp_vendor_site_rec.ext_payee_rec.ece_tp_loc_code := p7_a137;
    ddp_vendor_site_rec.ext_payee_rec.bank_charge_bearer := p7_a138;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr1_code := p7_a139;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr2_code := p7_a140;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr_detail := p7_a141;
    ddp_vendor_site_rec.ext_payee_rec.pay_reason_code := p7_a142;
    ddp_vendor_site_rec.ext_payee_rec.pay_reason_com := p7_a143;
    ddp_vendor_site_rec.ext_payee_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a144);
    ddp_vendor_site_rec.ext_payee_rec.pay_message1 := p7_a145;
    ddp_vendor_site_rec.ext_payee_rec.pay_message2 := p7_a146;
    ddp_vendor_site_rec.ext_payee_rec.pay_message3 := p7_a147;
    ddp_vendor_site_rec.ext_payee_rec.delivery_channel := p7_a148;
    ddp_vendor_site_rec.ext_payee_rec.pmt_format := p7_a149;
    ddp_vendor_site_rec.ext_payee_rec.settlement_priority := p7_a150;
    ddp_vendor_site_rec.retainage_rate := p7_a151;
    ddp_vendor_site_rec.services_tolerance_id := p7_a152;
    ddp_vendor_site_rec.services_tolerance_name := p7_a153;
    ddp_vendor_site_rec.shipping_location_id := p7_a154;




    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.create_vendor_site(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vendor_site_rec,
      x_vendor_site_id,
      x_party_site_id,
      x_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_vendor_site(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  DATE
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  NUMBER
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  VARCHAR2
    , p7_a112  VARCHAR2
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  NUMBER
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  NUMBER
    , p7_a123  NUMBER
    , p7_a124  NUMBER
    , p7_a125  NUMBER
    , p7_a126  VARCHAR2
    , p7_a127  NUMBER
    , p7_a128  NUMBER
    , p7_a129  NUMBER
    , p7_a130  VARCHAR2
    , p7_a131  VARCHAR2
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  NUMBER
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , p7_a144  DATE
    , p7_a145  VARCHAR2
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p7_a148  VARCHAR2
    , p7_a149  VARCHAR2
    , p7_a150  VARCHAR2
    , p7_a151  NUMBER
    , p7_a152  NUMBER
    , p7_a153  VARCHAR2
    , p7_a154  NUMBER
    , p_vendor_site_id  NUMBER
  )

  as
    ddp_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
    ddindx binary_integer; indx binary_integer;
    l_debug_info               VARCHAR2(2000);
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Update_Vendor_W';
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vendor_site_rec.area_code := p7_a0;
    ddp_vendor_site_rec.phone := p7_a1;
    ddp_vendor_site_rec.customer_num := p7_a2;
    ddp_vendor_site_rec.ship_to_location_id := p7_a3;
    ddp_vendor_site_rec.bill_to_location_id := p7_a4;
    ddp_vendor_site_rec.ship_via_lookup_code := p7_a5;
    ddp_vendor_site_rec.freight_terms_lookup_code := p7_a6;
    ddp_vendor_site_rec.fob_lookup_code := p7_a7;
    ddp_vendor_site_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_vendor_site_rec.fax := p7_a9;
    ddp_vendor_site_rec.fax_area_code := p7_a10;
    ddp_vendor_site_rec.telex := p7_a11;
    ddp_vendor_site_rec.terms_date_basis := p7_a12;
    ddp_vendor_site_rec.distribution_set_id := p7_a13;
    ddp_vendor_site_rec.accts_pay_code_combination_id := p7_a14;
    ddp_vendor_site_rec.prepay_code_combination_id := p7_a15;
    ddp_vendor_site_rec.pay_group_lookup_code := p7_a16;
    ddp_vendor_site_rec.payment_priority := p7_a17;
    ddp_vendor_site_rec.terms_id := p7_a18;
    ddp_vendor_site_rec.invoice_amount_limit := p7_a19;
    ddp_vendor_site_rec.pay_date_basis_lookup_code := p7_a20;
    ddp_vendor_site_rec.always_take_disc_flag := p7_a21;
    ddp_vendor_site_rec.invoice_currency_code := p7_a22;
    ddp_vendor_site_rec.payment_currency_code := p7_a23;
    ddp_vendor_site_rec.vendor_site_id := p7_a24;
    ddp_vendor_site_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a25);
    ddp_vendor_site_rec.last_updated_by := p7_a26;
    ddp_vendor_site_rec.vendor_id := p7_a27;
    ddp_vendor_site_rec.vendor_site_code := p7_a28;
    ddp_vendor_site_rec.vendor_site_code_alt := p7_a29;
    ddp_vendor_site_rec.purchasing_site_flag := p7_a30;
    ddp_vendor_site_rec.rfq_only_site_flag := p7_a31;
    ddp_vendor_site_rec.pay_site_flag := p7_a32;
    ddp_vendor_site_rec.attention_ar_flag := p7_a33;
    ddp_vendor_site_rec.hold_all_payments_flag := p7_a34;
    ddp_vendor_site_rec.hold_future_payments_flag := p7_a35;
    ddp_vendor_site_rec.hold_reason := p7_a36;
    ddp_vendor_site_rec.hold_unmatched_invoices_flag := p7_a37;
    ddp_vendor_site_rec.tax_reporting_site_flag := p7_a38;
    ddp_vendor_site_rec.attribute_category := p7_a39;
    ddp_vendor_site_rec.attribute1 := p7_a40;
    ddp_vendor_site_rec.attribute2 := p7_a41;
    ddp_vendor_site_rec.attribute3 := p7_a42;
    ddp_vendor_site_rec.attribute4 := p7_a43;
    ddp_vendor_site_rec.attribute5 := p7_a44;
    ddp_vendor_site_rec.attribute6 := p7_a45;
    ddp_vendor_site_rec.attribute7 := p7_a46;
    ddp_vendor_site_rec.attribute8 := p7_a47;
    ddp_vendor_site_rec.attribute9 := p7_a48;
    ddp_vendor_site_rec.attribute10 := p7_a49;
    ddp_vendor_site_rec.attribute11 := p7_a50;
    ddp_vendor_site_rec.attribute12 := p7_a51;
    ddp_vendor_site_rec.attribute13 := p7_a52;
    ddp_vendor_site_rec.attribute14 := p7_a53;
    ddp_vendor_site_rec.attribute15 := p7_a54;
    ddp_vendor_site_rec.validation_number := p7_a55;
    ddp_vendor_site_rec.exclude_freight_from_discount := p7_a56;
    ddp_vendor_site_rec.bank_charge_bearer := p7_a57;
    ddp_vendor_site_rec.org_id := p7_a58;
    ddp_vendor_site_rec.check_digits := p7_a59;
    ddp_vendor_site_rec.allow_awt_flag := p7_a60;
    ddp_vendor_site_rec.awt_group_id := p7_a61;
    ddp_vendor_site_rec.default_pay_site_id := p7_a62;
    ddp_vendor_site_rec.pay_on_code := p7_a63;
    ddp_vendor_site_rec.pay_on_receipt_summary_code := p7_a64;
    ddp_vendor_site_rec.global_attribute_category := p7_a65;
    ddp_vendor_site_rec.global_attribute1 := p7_a66;
    ddp_vendor_site_rec.global_attribute2 := p7_a67;
    ddp_vendor_site_rec.global_attribute3 := p7_a68;
    ddp_vendor_site_rec.global_attribute4 := p7_a69;
    ddp_vendor_site_rec.global_attribute5 := p7_a70;
    ddp_vendor_site_rec.global_attribute6 := p7_a71;
    ddp_vendor_site_rec.global_attribute7 := p7_a72;
    ddp_vendor_site_rec.global_attribute8 := p7_a73;
    ddp_vendor_site_rec.global_attribute9 := p7_a74;
    ddp_vendor_site_rec.global_attribute10 := p7_a75;
    ddp_vendor_site_rec.global_attribute11 := p7_a76;
    ddp_vendor_site_rec.global_attribute12 := p7_a77;
    ddp_vendor_site_rec.global_attribute13 := p7_a78;
    ddp_vendor_site_rec.global_attribute14 := p7_a79;
    ddp_vendor_site_rec.global_attribute15 := p7_a80;
    ddp_vendor_site_rec.global_attribute16 := p7_a81;
    ddp_vendor_site_rec.global_attribute17 := p7_a82;
    ddp_vendor_site_rec.global_attribute18 := p7_a83;
    ddp_vendor_site_rec.global_attribute19 := p7_a84;
    ddp_vendor_site_rec.global_attribute20 := p7_a85;
    ddp_vendor_site_rec.tp_header_id := p7_a86;
    ddp_vendor_site_rec.ece_tp_location_code := p7_a87;
    ddp_vendor_site_rec.pcard_site_flag := p7_a88;
    ddp_vendor_site_rec.match_option := p7_a89;
    ddp_vendor_site_rec.country_of_origin_code := p7_a90;
    ddp_vendor_site_rec.future_dated_payment_ccid := p7_a91;
    ddp_vendor_site_rec.create_debit_memo_flag := p7_a92;
    ddp_vendor_site_rec.supplier_notif_method := p7_a93;
    ddp_vendor_site_rec.email_address := p7_a94;
    ddp_vendor_site_rec.primary_pay_site_flag := p7_a95;
    ddp_vendor_site_rec.shipping_control := p7_a96;
    ddp_vendor_site_rec.selling_company_identifier := p7_a97;
    ddp_vendor_site_rec.gapless_inv_num_flag := p7_a98;
    ddp_vendor_site_rec.location_id := p7_a99;
    ddp_vendor_site_rec.party_site_id := p7_a100;
    ddp_vendor_site_rec.org_name := p7_a101;
    ddp_vendor_site_rec.duns_number := p7_a102;
    ddp_vendor_site_rec.address_style := p7_a103;
    ddp_vendor_site_rec.language := p7_a104;
    ddp_vendor_site_rec.province := p7_a105;
    ddp_vendor_site_rec.country := p7_a106;
    ddp_vendor_site_rec.address_line1 := p7_a107;
    ddp_vendor_site_rec.address_line2 := p7_a108;
    ddp_vendor_site_rec.address_line3 := p7_a109;
    ddp_vendor_site_rec.address_line4 := p7_a110;
    ddp_vendor_site_rec.address_lines_alt := p7_a111;
    ddp_vendor_site_rec.county := p7_a112;
    ddp_vendor_site_rec.city := p7_a113;
    ddp_vendor_site_rec.state := p7_a114;
    ddp_vendor_site_rec.zip := p7_a115;
    ddp_vendor_site_rec.terms_name := p7_a116;
    ddp_vendor_site_rec.default_terms_id := p7_a117;
    ddp_vendor_site_rec.awt_group_name := p7_a118;
    ddp_vendor_site_rec.distribution_set_name := p7_a119;
    ddp_vendor_site_rec.ship_to_location_code := p7_a120;
    ddp_vendor_site_rec.bill_to_location_code := p7_a121;
    ddp_vendor_site_rec.default_dist_set_id := p7_a122;
    ddp_vendor_site_rec.default_ship_to_loc_id := p7_a123;
    ddp_vendor_site_rec.default_bill_to_loc_id := p7_a124;
    ddp_vendor_site_rec.tolerance_id := p7_a125;
    ddp_vendor_site_rec.tolerance_name := p7_a126;
    ddp_vendor_site_rec.vendor_interface_id := p7_a127;
    ddp_vendor_site_rec.vendor_site_interface_id := p7_a128;
    ddp_vendor_site_rec.ext_payee_rec.payee_party_id := p7_a129;
    ddp_vendor_site_rec.ext_payee_rec.payment_function := p7_a130;
    ddp_vendor_site_rec.ext_payee_rec.exclusive_pay_flag := p7_a131;
    ddp_vendor_site_rec.ext_payee_rec.payee_party_site_id := p7_a132;
    ddp_vendor_site_rec.ext_payee_rec.supplier_site_id := p7_a133;
    ddp_vendor_site_rec.ext_payee_rec.payer_org_id := p7_a134;
    ddp_vendor_site_rec.ext_payee_rec.payer_org_type := p7_a135;
    ddp_vendor_site_rec.ext_payee_rec.default_pmt_method := p7_a136;
    ddp_vendor_site_rec.ext_payee_rec.ece_tp_loc_code := p7_a137;
    ddp_vendor_site_rec.ext_payee_rec.bank_charge_bearer := p7_a138;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr1_code := p7_a139;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr2_code := p7_a140;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr_detail := p7_a141;
    ddp_vendor_site_rec.ext_payee_rec.pay_reason_code := p7_a142;
    ddp_vendor_site_rec.ext_payee_rec.pay_reason_com := p7_a143;
    ddp_vendor_site_rec.ext_payee_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a144);
    ddp_vendor_site_rec.ext_payee_rec.pay_message1 := p7_a145;
    ddp_vendor_site_rec.ext_payee_rec.pay_message2 := p7_a146;
    ddp_vendor_site_rec.ext_payee_rec.pay_message3 := p7_a147;
    ddp_vendor_site_rec.ext_payee_rec.delivery_channel := p7_a148;
    ddp_vendor_site_rec.ext_payee_rec.pmt_format := p7_a149;
    ddp_vendor_site_rec.ext_payee_rec.settlement_priority := p7_a150;
    ddp_vendor_site_rec.retainage_rate := p7_a151;
    ddp_vendor_site_rec.services_tolerance_id := p7_a152;
    ddp_vendor_site_rec.services_tolerance_name := p7_a153;
    ddp_vendor_site_rec.shipping_location_id := p7_a154;


-- xili - test begin
   l_debug_info := 'xili#1: befor update_vendor_site, vendor_site_code=='||ddp_vendor_site_rec.vendor_site_code||' -- ' ||  to_char(sysdate, 'MON-DD-YYYY HH24:MI:SS');

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
-- xili - test end

    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.update_vendor_site(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vendor_site_rec,
      p_vendor_site_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_vendor_site(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  VARCHAR2
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  NUMBER
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  NUMBER
    , p7_a19 in out nocopy  NUMBER
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  NUMBER
    , p7_a25 in out nocopy  DATE
    , p7_a26 in out nocopy  NUMBER
    , p7_a27 in out nocopy  NUMBER
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
    , p7_a33 in out nocopy  VARCHAR2
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  VARCHAR2
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  VARCHAR2
    , p7_a40 in out nocopy  VARCHAR2
    , p7_a41 in out nocopy  VARCHAR2
    , p7_a42 in out nocopy  VARCHAR2
    , p7_a43 in out nocopy  VARCHAR2
    , p7_a44 in out nocopy  VARCHAR2
    , p7_a45 in out nocopy  VARCHAR2
    , p7_a46 in out nocopy  VARCHAR2
    , p7_a47 in out nocopy  VARCHAR2
    , p7_a48 in out nocopy  VARCHAR2
    , p7_a49 in out nocopy  VARCHAR2
    , p7_a50 in out nocopy  VARCHAR2
    , p7_a51 in out nocopy  VARCHAR2
    , p7_a52 in out nocopy  VARCHAR2
    , p7_a53 in out nocopy  VARCHAR2
    , p7_a54 in out nocopy  VARCHAR2
    , p7_a55 in out nocopy  NUMBER
    , p7_a56 in out nocopy  VARCHAR2
    , p7_a57 in out nocopy  VARCHAR2
    , p7_a58 in out nocopy  NUMBER
    , p7_a59 in out nocopy  VARCHAR2
    , p7_a60 in out nocopy  VARCHAR2
    , p7_a61 in out nocopy  NUMBER
    , p7_a62 in out nocopy  NUMBER
    , p7_a63 in out nocopy  VARCHAR2
    , p7_a64 in out nocopy  VARCHAR2
    , p7_a65 in out nocopy  VARCHAR2
    , p7_a66 in out nocopy  VARCHAR2
    , p7_a67 in out nocopy  VARCHAR2
    , p7_a68 in out nocopy  VARCHAR2
    , p7_a69 in out nocopy  VARCHAR2
    , p7_a70 in out nocopy  VARCHAR2
    , p7_a71 in out nocopy  VARCHAR2
    , p7_a72 in out nocopy  VARCHAR2
    , p7_a73 in out nocopy  VARCHAR2
    , p7_a74 in out nocopy  VARCHAR2
    , p7_a75 in out nocopy  VARCHAR2
    , p7_a76 in out nocopy  VARCHAR2
    , p7_a77 in out nocopy  VARCHAR2
    , p7_a78 in out nocopy  VARCHAR2
    , p7_a79 in out nocopy  VARCHAR2
    , p7_a80 in out nocopy  VARCHAR2
    , p7_a81 in out nocopy  VARCHAR2
    , p7_a82 in out nocopy  VARCHAR2
    , p7_a83 in out nocopy  VARCHAR2
    , p7_a84 in out nocopy  VARCHAR2
    , p7_a85 in out nocopy  VARCHAR2
    , p7_a86 in out nocopy  NUMBER
    , p7_a87 in out nocopy  VARCHAR2
    , p7_a88 in out nocopy  VARCHAR2
    , p7_a89 in out nocopy  VARCHAR2
    , p7_a90 in out nocopy  VARCHAR2
    , p7_a91 in out nocopy  NUMBER
    , p7_a92 in out nocopy  VARCHAR2
    , p7_a93 in out nocopy  VARCHAR2
    , p7_a94 in out nocopy  VARCHAR2
    , p7_a95 in out nocopy  VARCHAR2
    , p7_a96 in out nocopy  VARCHAR2
    , p7_a97 in out nocopy  VARCHAR2
    , p7_a98 in out nocopy  VARCHAR2
    , p7_a99 in out nocopy  NUMBER
    , p7_a100 in out nocopy  NUMBER
    , p7_a101 in out nocopy  VARCHAR2
    , p7_a102 in out nocopy  VARCHAR2
    , p7_a103 in out nocopy  VARCHAR2
    , p7_a104 in out nocopy  VARCHAR2
    , p7_a105 in out nocopy  VARCHAR2
    , p7_a106 in out nocopy  VARCHAR2
    , p7_a107 in out nocopy  VARCHAR2
    , p7_a108 in out nocopy  VARCHAR2
    , p7_a109 in out nocopy  VARCHAR2
    , p7_a110 in out nocopy  VARCHAR2
    , p7_a111 in out nocopy  VARCHAR2
    , p7_a112 in out nocopy  VARCHAR2
    , p7_a113 in out nocopy  VARCHAR2
    , p7_a114 in out nocopy  VARCHAR2
    , p7_a115 in out nocopy  VARCHAR2
    , p7_a116 in out nocopy  VARCHAR2
    , p7_a117 in out nocopy  NUMBER
    , p7_a118 in out nocopy  VARCHAR2
    , p7_a119 in out nocopy  VARCHAR2
    , p7_a120 in out nocopy  VARCHAR2
    , p7_a121 in out nocopy  VARCHAR2
    , p7_a122 in out nocopy  NUMBER
    , p7_a123 in out nocopy  NUMBER
    , p7_a124 in out nocopy  NUMBER
    , p7_a125 in out nocopy  NUMBER
    , p7_a126 in out nocopy  VARCHAR2
    , p7_a127 in out nocopy  NUMBER
    , p7_a128 in out nocopy  NUMBER
    , p7_a129 in out nocopy  NUMBER
    , p7_a130 in out nocopy  VARCHAR2
    , p7_a131 in out nocopy  VARCHAR2
    , p7_a132 in out nocopy  NUMBER
    , p7_a133 in out nocopy  NUMBER
    , p7_a134 in out nocopy  NUMBER
    , p7_a135 in out nocopy  VARCHAR2
    , p7_a136 in out nocopy  VARCHAR2
    , p7_a137 in out nocopy  VARCHAR2
    , p7_a138 in out nocopy  VARCHAR2
    , p7_a139 in out nocopy  VARCHAR2
    , p7_a140 in out nocopy  VARCHAR2
    , p7_a141 in out nocopy  VARCHAR2
    , p7_a142 in out nocopy  VARCHAR2
    , p7_a143 in out nocopy  VARCHAR2
    , p7_a144 in out nocopy  DATE
    , p7_a145 in out nocopy  VARCHAR2
    , p7_a146 in out nocopy  VARCHAR2
    , p7_a147 in out nocopy  VARCHAR2
    , p7_a148 in out nocopy  VARCHAR2
    , p7_a149 in out nocopy  VARCHAR2
    , p7_a150 in out nocopy  VARCHAR2
    , p7_a151 in out nocopy  NUMBER
    , p7_a152 in out nocopy  NUMBER
    , p7_a153 in out nocopy  VARCHAR2
    , p7_a154 in out nocopy  NUMBER
    , p_mode  VARCHAR2
    , p_calling_prog  VARCHAR2
    , x_party_site_valid out nocopy  VARCHAR2
    , x_location_valid out nocopy  VARCHAR2
    , x_payee_valid out nocopy  VARCHAR2
    , p_vendor_site_id  NUMBER
  )

  as
    ddp_vendor_site_rec ap_vendor_pub_pkg.r_vendor_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vendor_site_rec.area_code := p7_a0;
    ddp_vendor_site_rec.phone := p7_a1;
    ddp_vendor_site_rec.customer_num := p7_a2;
    ddp_vendor_site_rec.ship_to_location_id := p7_a3;
    ddp_vendor_site_rec.bill_to_location_id := p7_a4;
    ddp_vendor_site_rec.ship_via_lookup_code := p7_a5;
    ddp_vendor_site_rec.freight_terms_lookup_code := p7_a6;
    ddp_vendor_site_rec.fob_lookup_code := p7_a7;
    ddp_vendor_site_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_vendor_site_rec.fax := p7_a9;
    ddp_vendor_site_rec.fax_area_code := p7_a10;
    ddp_vendor_site_rec.telex := p7_a11;
    ddp_vendor_site_rec.terms_date_basis := p7_a12;
    ddp_vendor_site_rec.distribution_set_id := p7_a13;
    ddp_vendor_site_rec.accts_pay_code_combination_id := p7_a14;
    ddp_vendor_site_rec.prepay_code_combination_id := p7_a15;
    ddp_vendor_site_rec.pay_group_lookup_code := p7_a16;
    ddp_vendor_site_rec.payment_priority := p7_a17;
    ddp_vendor_site_rec.terms_id := p7_a18;
    ddp_vendor_site_rec.invoice_amount_limit := p7_a19;
    ddp_vendor_site_rec.pay_date_basis_lookup_code := p7_a20;
    ddp_vendor_site_rec.always_take_disc_flag := p7_a21;
    ddp_vendor_site_rec.invoice_currency_code := p7_a22;
    ddp_vendor_site_rec.payment_currency_code := p7_a23;
    ddp_vendor_site_rec.vendor_site_id := p7_a24;
    ddp_vendor_site_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a25);
    ddp_vendor_site_rec.last_updated_by := p7_a26;
    ddp_vendor_site_rec.vendor_id := p7_a27;
    ddp_vendor_site_rec.vendor_site_code := p7_a28;
    ddp_vendor_site_rec.vendor_site_code_alt := p7_a29;
    ddp_vendor_site_rec.purchasing_site_flag := p7_a30;
    ddp_vendor_site_rec.rfq_only_site_flag := p7_a31;
    ddp_vendor_site_rec.pay_site_flag := p7_a32;
    ddp_vendor_site_rec.attention_ar_flag := p7_a33;
    ddp_vendor_site_rec.hold_all_payments_flag := p7_a34;
    ddp_vendor_site_rec.hold_future_payments_flag := p7_a35;
    ddp_vendor_site_rec.hold_reason := p7_a36;
    ddp_vendor_site_rec.hold_unmatched_invoices_flag := p7_a37;
    ddp_vendor_site_rec.tax_reporting_site_flag := p7_a38;
    ddp_vendor_site_rec.attribute_category := p7_a39;
    ddp_vendor_site_rec.attribute1 := p7_a40;
    ddp_vendor_site_rec.attribute2 := p7_a41;
    ddp_vendor_site_rec.attribute3 := p7_a42;
    ddp_vendor_site_rec.attribute4 := p7_a43;
    ddp_vendor_site_rec.attribute5 := p7_a44;
    ddp_vendor_site_rec.attribute6 := p7_a45;
    ddp_vendor_site_rec.attribute7 := p7_a46;
    ddp_vendor_site_rec.attribute8 := p7_a47;
    ddp_vendor_site_rec.attribute9 := p7_a48;
    ddp_vendor_site_rec.attribute10 := p7_a49;
    ddp_vendor_site_rec.attribute11 := p7_a50;
    ddp_vendor_site_rec.attribute12 := p7_a51;
    ddp_vendor_site_rec.attribute13 := p7_a52;
    ddp_vendor_site_rec.attribute14 := p7_a53;
    ddp_vendor_site_rec.attribute15 := p7_a54;
    ddp_vendor_site_rec.validation_number := p7_a55;
    ddp_vendor_site_rec.exclude_freight_from_discount := p7_a56;
    ddp_vendor_site_rec.bank_charge_bearer := p7_a57;
    ddp_vendor_site_rec.org_id := p7_a58;
    ddp_vendor_site_rec.check_digits := p7_a59;
    ddp_vendor_site_rec.allow_awt_flag := p7_a60;
    ddp_vendor_site_rec.awt_group_id := p7_a61;
    ddp_vendor_site_rec.default_pay_site_id := p7_a62;
    ddp_vendor_site_rec.pay_on_code := p7_a63;
    ddp_vendor_site_rec.pay_on_receipt_summary_code := p7_a64;
    ddp_vendor_site_rec.global_attribute_category := p7_a65;
    ddp_vendor_site_rec.global_attribute1 := p7_a66;
    ddp_vendor_site_rec.global_attribute2 := p7_a67;
    ddp_vendor_site_rec.global_attribute3 := p7_a68;
    ddp_vendor_site_rec.global_attribute4 := p7_a69;
    ddp_vendor_site_rec.global_attribute5 := p7_a70;
    ddp_vendor_site_rec.global_attribute6 := p7_a71;
    ddp_vendor_site_rec.global_attribute7 := p7_a72;
    ddp_vendor_site_rec.global_attribute8 := p7_a73;
    ddp_vendor_site_rec.global_attribute9 := p7_a74;
    ddp_vendor_site_rec.global_attribute10 := p7_a75;
    ddp_vendor_site_rec.global_attribute11 := p7_a76;
    ddp_vendor_site_rec.global_attribute12 := p7_a77;
    ddp_vendor_site_rec.global_attribute13 := p7_a78;
    ddp_vendor_site_rec.global_attribute14 := p7_a79;
    ddp_vendor_site_rec.global_attribute15 := p7_a80;
    ddp_vendor_site_rec.global_attribute16 := p7_a81;
    ddp_vendor_site_rec.global_attribute17 := p7_a82;
    ddp_vendor_site_rec.global_attribute18 := p7_a83;
    ddp_vendor_site_rec.global_attribute19 := p7_a84;
    ddp_vendor_site_rec.global_attribute20 := p7_a85;
    ddp_vendor_site_rec.tp_header_id := p7_a86;
    ddp_vendor_site_rec.ece_tp_location_code := p7_a87;
    ddp_vendor_site_rec.pcard_site_flag := p7_a88;
    ddp_vendor_site_rec.match_option := p7_a89;
    ddp_vendor_site_rec.country_of_origin_code := p7_a90;
    ddp_vendor_site_rec.future_dated_payment_ccid := p7_a91;
    ddp_vendor_site_rec.create_debit_memo_flag := p7_a92;
    ddp_vendor_site_rec.supplier_notif_method := p7_a93;
    ddp_vendor_site_rec.email_address := p7_a94;
    ddp_vendor_site_rec.primary_pay_site_flag := p7_a95;
    ddp_vendor_site_rec.shipping_control := p7_a96;
    ddp_vendor_site_rec.selling_company_identifier := p7_a97;
    ddp_vendor_site_rec.gapless_inv_num_flag := p7_a98;
    ddp_vendor_site_rec.location_id := p7_a99;
    ddp_vendor_site_rec.party_site_id := p7_a100;
    ddp_vendor_site_rec.org_name := p7_a101;
    ddp_vendor_site_rec.duns_number := p7_a102;
    ddp_vendor_site_rec.address_style := p7_a103;
    ddp_vendor_site_rec.language := p7_a104;
    ddp_vendor_site_rec.province := p7_a105;
    ddp_vendor_site_rec.country := p7_a106;
    ddp_vendor_site_rec.address_line1 := p7_a107;
    ddp_vendor_site_rec.address_line2 := p7_a108;
    ddp_vendor_site_rec.address_line3 := p7_a109;
    ddp_vendor_site_rec.address_line4 := p7_a110;
    ddp_vendor_site_rec.address_lines_alt := p7_a111;
    ddp_vendor_site_rec.county := p7_a112;
    ddp_vendor_site_rec.city := p7_a113;
    ddp_vendor_site_rec.state := p7_a114;
    ddp_vendor_site_rec.zip := p7_a115;
    ddp_vendor_site_rec.terms_name := p7_a116;
    ddp_vendor_site_rec.default_terms_id := p7_a117;
    ddp_vendor_site_rec.awt_group_name := p7_a118;
    ddp_vendor_site_rec.distribution_set_name := p7_a119;
    ddp_vendor_site_rec.ship_to_location_code := p7_a120;
    ddp_vendor_site_rec.bill_to_location_code := p7_a121;
    ddp_vendor_site_rec.default_dist_set_id := p7_a122;
    ddp_vendor_site_rec.default_ship_to_loc_id := p7_a123;
    ddp_vendor_site_rec.default_bill_to_loc_id := p7_a124;
    ddp_vendor_site_rec.tolerance_id := p7_a125;
    ddp_vendor_site_rec.tolerance_name := p7_a126;
    ddp_vendor_site_rec.vendor_interface_id := p7_a127;
    ddp_vendor_site_rec.vendor_site_interface_id := p7_a128;
    ddp_vendor_site_rec.ext_payee_rec.payee_party_id := p7_a129;
    ddp_vendor_site_rec.ext_payee_rec.payment_function := p7_a130;
    ddp_vendor_site_rec.ext_payee_rec.exclusive_pay_flag := p7_a131;
    ddp_vendor_site_rec.ext_payee_rec.payee_party_site_id := p7_a132;
    ddp_vendor_site_rec.ext_payee_rec.supplier_site_id := p7_a133;
    ddp_vendor_site_rec.ext_payee_rec.payer_org_id := p7_a134;
    ddp_vendor_site_rec.ext_payee_rec.payer_org_type := p7_a135;
    ddp_vendor_site_rec.ext_payee_rec.default_pmt_method := p7_a136;
    ddp_vendor_site_rec.ext_payee_rec.ece_tp_loc_code := p7_a137;
    ddp_vendor_site_rec.ext_payee_rec.bank_charge_bearer := p7_a138;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr1_code := p7_a139;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr2_code := p7_a140;
    ddp_vendor_site_rec.ext_payee_rec.bank_instr_detail := p7_a141;
    ddp_vendor_site_rec.ext_payee_rec.pay_reason_code := p7_a142;
    ddp_vendor_site_rec.ext_payee_rec.pay_reason_com := p7_a143;
    ddp_vendor_site_rec.ext_payee_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a144);
    ddp_vendor_site_rec.ext_payee_rec.pay_message1 := p7_a145;
    ddp_vendor_site_rec.ext_payee_rec.pay_message2 := p7_a146;
    ddp_vendor_site_rec.ext_payee_rec.pay_message3 := p7_a147;
    ddp_vendor_site_rec.ext_payee_rec.delivery_channel := p7_a148;
    ddp_vendor_site_rec.ext_payee_rec.pmt_format := p7_a149;
    ddp_vendor_site_rec.ext_payee_rec.settlement_priority := p7_a150;
    ddp_vendor_site_rec.retainage_rate := p7_a151;
    ddp_vendor_site_rec.services_tolerance_id := p7_a152;
    ddp_vendor_site_rec.services_tolerance_name := p7_a153;
    ddp_vendor_site_rec.shipping_location_id := p7_a154;







    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.validate_vendor_site(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vendor_site_rec,
      p_mode,
      p_calling_prog,
      x_party_site_valid,
      x_location_valid,
      x_payee_valid,
      p_vendor_site_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_vendor_site_rec.area_code;
    p7_a1 := ddp_vendor_site_rec.phone;
    p7_a2 := ddp_vendor_site_rec.customer_num;
    p7_a3 := ddp_vendor_site_rec.ship_to_location_id;
    p7_a4 := ddp_vendor_site_rec.bill_to_location_id;
    p7_a5 := ddp_vendor_site_rec.ship_via_lookup_code;
    p7_a6 := ddp_vendor_site_rec.freight_terms_lookup_code;
    p7_a7 := ddp_vendor_site_rec.fob_lookup_code;
    p7_a8 := ddp_vendor_site_rec.inactive_date;
    p7_a9 := ddp_vendor_site_rec.fax;
    p7_a10 := ddp_vendor_site_rec.fax_area_code;
    p7_a11 := ddp_vendor_site_rec.telex;
    p7_a12 := ddp_vendor_site_rec.terms_date_basis;
    p7_a13 := ddp_vendor_site_rec.distribution_set_id;
    p7_a14 := ddp_vendor_site_rec.accts_pay_code_combination_id;
    p7_a15 := ddp_vendor_site_rec.prepay_code_combination_id;
    p7_a16 := ddp_vendor_site_rec.pay_group_lookup_code;
    p7_a17 := ddp_vendor_site_rec.payment_priority;
    p7_a18 := ddp_vendor_site_rec.terms_id;
    p7_a19 := ddp_vendor_site_rec.invoice_amount_limit;
    p7_a20 := ddp_vendor_site_rec.pay_date_basis_lookup_code;
    p7_a21 := ddp_vendor_site_rec.always_take_disc_flag;
    p7_a22 := ddp_vendor_site_rec.invoice_currency_code;
    p7_a23 := ddp_vendor_site_rec.payment_currency_code;
    p7_a24 := ddp_vendor_site_rec.vendor_site_id;
    p7_a25 := ddp_vendor_site_rec.last_update_date;
    p7_a26 := ddp_vendor_site_rec.last_updated_by;
    p7_a27 := ddp_vendor_site_rec.vendor_id;
    p7_a28 := ddp_vendor_site_rec.vendor_site_code;
    p7_a29 := ddp_vendor_site_rec.vendor_site_code_alt;
    p7_a30 := ddp_vendor_site_rec.purchasing_site_flag;
    p7_a31 := ddp_vendor_site_rec.rfq_only_site_flag;
    p7_a32 := ddp_vendor_site_rec.pay_site_flag;
    p7_a33 := ddp_vendor_site_rec.attention_ar_flag;
    p7_a34 := ddp_vendor_site_rec.hold_all_payments_flag;
    p7_a35 := ddp_vendor_site_rec.hold_future_payments_flag;
    p7_a36 := ddp_vendor_site_rec.hold_reason;
    p7_a37 := ddp_vendor_site_rec.hold_unmatched_invoices_flag;
    p7_a38 := ddp_vendor_site_rec.tax_reporting_site_flag;
    p7_a39 := ddp_vendor_site_rec.attribute_category;
    p7_a40 := ddp_vendor_site_rec.attribute1;
    p7_a41 := ddp_vendor_site_rec.attribute2;
    p7_a42 := ddp_vendor_site_rec.attribute3;
    p7_a43 := ddp_vendor_site_rec.attribute4;
    p7_a44 := ddp_vendor_site_rec.attribute5;
    p7_a45 := ddp_vendor_site_rec.attribute6;
    p7_a46 := ddp_vendor_site_rec.attribute7;
    p7_a47 := ddp_vendor_site_rec.attribute8;
    p7_a48 := ddp_vendor_site_rec.attribute9;
    p7_a49 := ddp_vendor_site_rec.attribute10;
    p7_a50 := ddp_vendor_site_rec.attribute11;
    p7_a51 := ddp_vendor_site_rec.attribute12;
    p7_a52 := ddp_vendor_site_rec.attribute13;
    p7_a53 := ddp_vendor_site_rec.attribute14;
    p7_a54 := ddp_vendor_site_rec.attribute15;
    p7_a55 := ddp_vendor_site_rec.validation_number;
    p7_a56 := ddp_vendor_site_rec.exclude_freight_from_discount;
    p7_a57 := ddp_vendor_site_rec.bank_charge_bearer;
    p7_a58 := ddp_vendor_site_rec.org_id;
    p7_a59 := ddp_vendor_site_rec.check_digits;
    p7_a60 := ddp_vendor_site_rec.allow_awt_flag;
    p7_a61 := ddp_vendor_site_rec.awt_group_id;
    p7_a62 := ddp_vendor_site_rec.default_pay_site_id;
    p7_a63 := ddp_vendor_site_rec.pay_on_code;
    p7_a64 := ddp_vendor_site_rec.pay_on_receipt_summary_code;
    p7_a65 := ddp_vendor_site_rec.global_attribute_category;
    p7_a66 := ddp_vendor_site_rec.global_attribute1;
    p7_a67 := ddp_vendor_site_rec.global_attribute2;
    p7_a68 := ddp_vendor_site_rec.global_attribute3;
    p7_a69 := ddp_vendor_site_rec.global_attribute4;
    p7_a70 := ddp_vendor_site_rec.global_attribute5;
    p7_a71 := ddp_vendor_site_rec.global_attribute6;
    p7_a72 := ddp_vendor_site_rec.global_attribute7;
    p7_a73 := ddp_vendor_site_rec.global_attribute8;
    p7_a74 := ddp_vendor_site_rec.global_attribute9;
    p7_a75 := ddp_vendor_site_rec.global_attribute10;
    p7_a76 := ddp_vendor_site_rec.global_attribute11;
    p7_a77 := ddp_vendor_site_rec.global_attribute12;
    p7_a78 := ddp_vendor_site_rec.global_attribute13;
    p7_a79 := ddp_vendor_site_rec.global_attribute14;
    p7_a80 := ddp_vendor_site_rec.global_attribute15;
    p7_a81 := ddp_vendor_site_rec.global_attribute16;
    p7_a82 := ddp_vendor_site_rec.global_attribute17;
    p7_a83 := ddp_vendor_site_rec.global_attribute18;
    p7_a84 := ddp_vendor_site_rec.global_attribute19;
    p7_a85 := ddp_vendor_site_rec.global_attribute20;
    p7_a86 := ddp_vendor_site_rec.tp_header_id;
    p7_a87 := ddp_vendor_site_rec.ece_tp_location_code;
    p7_a88 := ddp_vendor_site_rec.pcard_site_flag;
    p7_a89 := ddp_vendor_site_rec.match_option;
    p7_a90 := ddp_vendor_site_rec.country_of_origin_code;
    p7_a91 := ddp_vendor_site_rec.future_dated_payment_ccid;
    p7_a92 := ddp_vendor_site_rec.create_debit_memo_flag;
    p7_a93 := ddp_vendor_site_rec.supplier_notif_method;
    p7_a94 := ddp_vendor_site_rec.email_address;
    p7_a95 := ddp_vendor_site_rec.primary_pay_site_flag;
    p7_a96 := ddp_vendor_site_rec.shipping_control;
    p7_a97 := ddp_vendor_site_rec.selling_company_identifier;
    p7_a98 := ddp_vendor_site_rec.gapless_inv_num_flag;
    p7_a99 := ddp_vendor_site_rec.location_id;
    p7_a100 := ddp_vendor_site_rec.party_site_id;
    p7_a101 := ddp_vendor_site_rec.org_name;
    p7_a102 := ddp_vendor_site_rec.duns_number;
    p7_a103 := ddp_vendor_site_rec.address_style;
    p7_a104 := ddp_vendor_site_rec.language;
    p7_a105 := ddp_vendor_site_rec.province;
    p7_a106 := ddp_vendor_site_rec.country;
    p7_a107 := ddp_vendor_site_rec.address_line1;
    p7_a108 := ddp_vendor_site_rec.address_line2;
    p7_a109 := ddp_vendor_site_rec.address_line3;
    p7_a110 := ddp_vendor_site_rec.address_line4;
    p7_a111 := ddp_vendor_site_rec.address_lines_alt;
    p7_a112 := ddp_vendor_site_rec.county;
    p7_a113 := ddp_vendor_site_rec.city;
    p7_a114 := ddp_vendor_site_rec.state;
    p7_a115 := ddp_vendor_site_rec.zip;
    p7_a116 := ddp_vendor_site_rec.terms_name;
    p7_a117 := ddp_vendor_site_rec.default_terms_id;
    p7_a118 := ddp_vendor_site_rec.awt_group_name;
    p7_a119 := ddp_vendor_site_rec.distribution_set_name;
    p7_a120 := ddp_vendor_site_rec.ship_to_location_code;
    p7_a121 := ddp_vendor_site_rec.bill_to_location_code;
    p7_a122 := ddp_vendor_site_rec.default_dist_set_id;
    p7_a123 := ddp_vendor_site_rec.default_ship_to_loc_id;
    p7_a124 := ddp_vendor_site_rec.default_bill_to_loc_id;
    p7_a125 := ddp_vendor_site_rec.tolerance_id;
    p7_a126 := ddp_vendor_site_rec.tolerance_name;
    p7_a127 := ddp_vendor_site_rec.vendor_interface_id;
    p7_a128 := ddp_vendor_site_rec.vendor_site_interface_id;
    p7_a129 := ddp_vendor_site_rec.ext_payee_rec.payee_party_id;
    p7_a130 := ddp_vendor_site_rec.ext_payee_rec.payment_function;
    p7_a131 := ddp_vendor_site_rec.ext_payee_rec.exclusive_pay_flag;
    p7_a132 := ddp_vendor_site_rec.ext_payee_rec.payee_party_site_id;
    p7_a133 := ddp_vendor_site_rec.ext_payee_rec.supplier_site_id;
    p7_a134 := ddp_vendor_site_rec.ext_payee_rec.payer_org_id;
    p7_a135 := ddp_vendor_site_rec.ext_payee_rec.payer_org_type;
    p7_a136 := ddp_vendor_site_rec.ext_payee_rec.default_pmt_method;
    p7_a137 := ddp_vendor_site_rec.ext_payee_rec.ece_tp_loc_code;
    p7_a138 := ddp_vendor_site_rec.ext_payee_rec.bank_charge_bearer;
    p7_a139 := ddp_vendor_site_rec.ext_payee_rec.bank_instr1_code;
    p7_a140 := ddp_vendor_site_rec.ext_payee_rec.bank_instr2_code;
    p7_a141 := ddp_vendor_site_rec.ext_payee_rec.bank_instr_detail;
    p7_a142 := ddp_vendor_site_rec.ext_payee_rec.pay_reason_code;
    p7_a143 := ddp_vendor_site_rec.ext_payee_rec.pay_reason_com;
    p7_a144 := ddp_vendor_site_rec.ext_payee_rec.inactive_date;
    p7_a145 := ddp_vendor_site_rec.ext_payee_rec.pay_message1;
    p7_a146 := ddp_vendor_site_rec.ext_payee_rec.pay_message2;
    p7_a147 := ddp_vendor_site_rec.ext_payee_rec.pay_message3;
    p7_a148 := ddp_vendor_site_rec.ext_payee_rec.delivery_channel;
    p7_a149 := ddp_vendor_site_rec.ext_payee_rec.pmt_format;
    p7_a150 := ddp_vendor_site_rec.ext_payee_rec.settlement_priority;
    p7_a151 := ddp_vendor_site_rec.retainage_rate;
    p7_a152 := ddp_vendor_site_rec.services_tolerance_id;
    p7_a153 := ddp_vendor_site_rec.services_tolerance_name;
    p7_a154 := ddp_vendor_site_rec.shipping_location_id;






  end;

  procedure create_vendor_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  DATE
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , x_vendor_contact_id out nocopy  NUMBER
    , x_per_party_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_rel_id out nocopy  NUMBER
    , x_org_contact_id out nocopy  NUMBER
    , x_party_site_id out nocopy  NUMBER
  )

  as
    ddp_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vendor_contact_rec.vendor_contact_id := p7_a0;
    ddp_vendor_contact_rec.vendor_site_id := p7_a1;
    ddp_vendor_contact_rec.vendor_id := p7_a2;
    ddp_vendor_contact_rec.per_party_id := p7_a3;
    ddp_vendor_contact_rec.relationship_id := p7_a4;
    ddp_vendor_contact_rec.rel_party_id := p7_a5;
    ddp_vendor_contact_rec.party_site_id := p7_a6;
    ddp_vendor_contact_rec.org_contact_id := p7_a7;
    ddp_vendor_contact_rec.org_party_site_id := p7_a8;
    ddp_vendor_contact_rec.person_first_name := p7_a9;
    ddp_vendor_contact_rec.person_middle_name := p7_a10;
    ddp_vendor_contact_rec.person_last_name := p7_a11;
    ddp_vendor_contact_rec.person_title := p7_a12;
    ddp_vendor_contact_rec.organization_name_phonetic := p7_a13;
    ddp_vendor_contact_rec.person_first_name_phonetic := p7_a14;
    ddp_vendor_contact_rec.person_last_name_phonetic := p7_a15;
    ddp_vendor_contact_rec.attribute1 := p7_a16;
    ddp_vendor_contact_rec.attribute2 := p7_a17;
    ddp_vendor_contact_rec.attribute3 := p7_a18;
    ddp_vendor_contact_rec.attribute4 := p7_a19;
    ddp_vendor_contact_rec.attribute5 := p7_a20;
    ddp_vendor_contact_rec.attribute6 := p7_a21;
    ddp_vendor_contact_rec.attribute7 := p7_a22;
    ddp_vendor_contact_rec.attribute8 := p7_a23;
    ddp_vendor_contact_rec.attribute9 := p7_a24;
    ddp_vendor_contact_rec.attribute10 := p7_a25;
    ddp_vendor_contact_rec.attribute11 := p7_a26;
    ddp_vendor_contact_rec.attribute12 := p7_a27;
    ddp_vendor_contact_rec.attribute13 := p7_a28;
    ddp_vendor_contact_rec.attribute14 := p7_a29;
    ddp_vendor_contact_rec.attribute15 := p7_a30;
    ddp_vendor_contact_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a31);
    ddp_vendor_contact_rec.party_number := p7_a32;
    ddp_vendor_contact_rec.department := p7_a33;
    ddp_vendor_contact_rec.mail_stop := p7_a34;
    ddp_vendor_contact_rec.area_code := p7_a35;
    ddp_vendor_contact_rec.phone := p7_a36;
    ddp_vendor_contact_rec.alt_area_code := p7_a37;
    ddp_vendor_contact_rec.alt_phone := p7_a38;
    ddp_vendor_contact_rec.fax_area_code := p7_a39;
    ddp_vendor_contact_rec.fax_phone := p7_a40;
    ddp_vendor_contact_rec.email_address := p7_a41;
    ddp_vendor_contact_rec.url := p7_a42;
    ddp_vendor_contact_rec.vendor_contact_interface_id := p7_a43;
    ddp_vendor_contact_rec.vendor_interface_id := p7_a44;
    ddp_vendor_contact_rec.vendor_site_code := p7_a45;
    ddp_vendor_contact_rec.org_id := p7_a46;
    ddp_vendor_contact_rec.operating_unit_name := p7_a47;
    ddp_vendor_contact_rec.prefix := p7_a48;
    ddp_vendor_contact_rec.contact_name_phonetic := p7_a49;







    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.create_vendor_contact(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vendor_contact_rec,
      x_vendor_contact_id,
      x_per_party_id,
      x_rel_party_id,
      x_rel_id,
      x_org_contact_id,
      x_party_site_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure update_vendor_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  DATE
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  NUMBER
    , p4_a44  NUMBER
    , p4_a45  VARCHAR2
    , p4_a46  NUMBER
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_vendor_contact_rec.vendor_contact_id := p4_a0;
    ddp_vendor_contact_rec.vendor_site_id := p4_a1;
    ddp_vendor_contact_rec.vendor_id := p4_a2;
    ddp_vendor_contact_rec.per_party_id := p4_a3;
    ddp_vendor_contact_rec.relationship_id := p4_a4;
    ddp_vendor_contact_rec.rel_party_id := p4_a5;
    ddp_vendor_contact_rec.party_site_id := p4_a6;
    ddp_vendor_contact_rec.org_contact_id := p4_a7;
    ddp_vendor_contact_rec.org_party_site_id := p4_a8;
    ddp_vendor_contact_rec.person_first_name := p4_a9;
    ddp_vendor_contact_rec.person_middle_name := p4_a10;
    ddp_vendor_contact_rec.person_last_name := p4_a11;
    ddp_vendor_contact_rec.person_title := p4_a12;
    ddp_vendor_contact_rec.organization_name_phonetic := p4_a13;
    ddp_vendor_contact_rec.person_first_name_phonetic := p4_a14;
    ddp_vendor_contact_rec.person_last_name_phonetic := p4_a15;
    ddp_vendor_contact_rec.attribute1 := p4_a16;
    ddp_vendor_contact_rec.attribute2 := p4_a17;
    ddp_vendor_contact_rec.attribute3 := p4_a18;
    ddp_vendor_contact_rec.attribute4 := p4_a19;
    ddp_vendor_contact_rec.attribute5 := p4_a20;
    ddp_vendor_contact_rec.attribute6 := p4_a21;
    ddp_vendor_contact_rec.attribute7 := p4_a22;
    ddp_vendor_contact_rec.attribute8 := p4_a23;
    ddp_vendor_contact_rec.attribute9 := p4_a24;
    ddp_vendor_contact_rec.attribute10 := p4_a25;
    ddp_vendor_contact_rec.attribute11 := p4_a26;
    ddp_vendor_contact_rec.attribute12 := p4_a27;
    ddp_vendor_contact_rec.attribute13 := p4_a28;
    ddp_vendor_contact_rec.attribute14 := p4_a29;
    ddp_vendor_contact_rec.attribute15 := p4_a30;
    ddp_vendor_contact_rec.inactive_date := rosetta_g_miss_date_in_map(p4_a31);
    ddp_vendor_contact_rec.party_number := p4_a32;
    ddp_vendor_contact_rec.department := p4_a33;
    ddp_vendor_contact_rec.mail_stop := p4_a34;
    ddp_vendor_contact_rec.area_code := p4_a35;
    ddp_vendor_contact_rec.phone := p4_a36;
    ddp_vendor_contact_rec.alt_area_code := p4_a37;
    ddp_vendor_contact_rec.alt_phone := p4_a38;
    ddp_vendor_contact_rec.fax_area_code := p4_a39;
    ddp_vendor_contact_rec.fax_phone := p4_a40;
    ddp_vendor_contact_rec.email_address := p4_a41;
    ddp_vendor_contact_rec.url := p4_a42;
    ddp_vendor_contact_rec.vendor_contact_interface_id := p4_a43;
    ddp_vendor_contact_rec.vendor_interface_id := p4_a44;
    ddp_vendor_contact_rec.vendor_site_code := p4_a45;
    ddp_vendor_contact_rec.org_id := p4_a46;
    ddp_vendor_contact_rec.operating_unit_name := p4_a47;
    ddp_vendor_contact_rec.prefix := p4_a48;
    ddp_vendor_contact_rec.contact_name_phonetic := p4_a49;




    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.update_vendor_contact(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_vendor_contact_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_vendor_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  NUMBER
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  DATE
    , p7_a32 in out nocopy  VARCHAR2
    , p7_a33 in out nocopy  VARCHAR2
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  VARCHAR2
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  VARCHAR2
    , p7_a40 in out nocopy  VARCHAR2
    , p7_a41 in out nocopy  VARCHAR2
    , p7_a42 in out nocopy  VARCHAR2
    , p7_a43 in out nocopy  NUMBER
    , p7_a44 in out nocopy  NUMBER
    , p7_a45 in out nocopy  VARCHAR2
    , p7_a46 in out nocopy  NUMBER
    , p7_a47 in out nocopy  VARCHAR2
    , p7_a48 in out nocopy  VARCHAR2
    , p7_a49 in out nocopy  VARCHAR2
    , x_rel_party_valid out nocopy  VARCHAR2
    , x_per_party_valid out nocopy  VARCHAR2
    , x_rel_valid out nocopy  VARCHAR2
    , x_org_party_id out nocopy  NUMBER
    , x_org_contact_valid out nocopy  VARCHAR2
    , x_location_id out nocopy  NUMBER
    , x_party_site_valid out nocopy  VARCHAR2
  )

  as
    ddp_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_vendor_contact_rec.vendor_contact_id := p7_a0;
    ddp_vendor_contact_rec.vendor_site_id := p7_a1;
    ddp_vendor_contact_rec.vendor_id := p7_a2;
    ddp_vendor_contact_rec.per_party_id := p7_a3;
    ddp_vendor_contact_rec.relationship_id := p7_a4;
    ddp_vendor_contact_rec.rel_party_id := p7_a5;
    ddp_vendor_contact_rec.party_site_id := p7_a6;
    ddp_vendor_contact_rec.org_contact_id := p7_a7;
    ddp_vendor_contact_rec.org_party_site_id := p7_a8;
    ddp_vendor_contact_rec.person_first_name := p7_a9;
    ddp_vendor_contact_rec.person_middle_name := p7_a10;
    ddp_vendor_contact_rec.person_last_name := p7_a11;
    ddp_vendor_contact_rec.person_title := p7_a12;
    ddp_vendor_contact_rec.organization_name_phonetic := p7_a13;
    ddp_vendor_contact_rec.person_first_name_phonetic := p7_a14;
    ddp_vendor_contact_rec.person_last_name_phonetic := p7_a15;
    ddp_vendor_contact_rec.attribute1 := p7_a16;
    ddp_vendor_contact_rec.attribute2 := p7_a17;
    ddp_vendor_contact_rec.attribute3 := p7_a18;
    ddp_vendor_contact_rec.attribute4 := p7_a19;
    ddp_vendor_contact_rec.attribute5 := p7_a20;
    ddp_vendor_contact_rec.attribute6 := p7_a21;
    ddp_vendor_contact_rec.attribute7 := p7_a22;
    ddp_vendor_contact_rec.attribute8 := p7_a23;
    ddp_vendor_contact_rec.attribute9 := p7_a24;
    ddp_vendor_contact_rec.attribute10 := p7_a25;
    ddp_vendor_contact_rec.attribute11 := p7_a26;
    ddp_vendor_contact_rec.attribute12 := p7_a27;
    ddp_vendor_contact_rec.attribute13 := p7_a28;
    ddp_vendor_contact_rec.attribute14 := p7_a29;
    ddp_vendor_contact_rec.attribute15 := p7_a30;
    ddp_vendor_contact_rec.inactive_date := rosetta_g_miss_date_in_map(p7_a31);
    ddp_vendor_contact_rec.party_number := p7_a32;
    ddp_vendor_contact_rec.department := p7_a33;
    ddp_vendor_contact_rec.mail_stop := p7_a34;
    ddp_vendor_contact_rec.area_code := p7_a35;
    ddp_vendor_contact_rec.phone := p7_a36;
    ddp_vendor_contact_rec.alt_area_code := p7_a37;
    ddp_vendor_contact_rec.alt_phone := p7_a38;
    ddp_vendor_contact_rec.fax_area_code := p7_a39;
    ddp_vendor_contact_rec.fax_phone := p7_a40;
    ddp_vendor_contact_rec.email_address := p7_a41;
    ddp_vendor_contact_rec.url := p7_a42;
    ddp_vendor_contact_rec.vendor_contact_interface_id := p7_a43;
    ddp_vendor_contact_rec.vendor_interface_id := p7_a44;
    ddp_vendor_contact_rec.vendor_site_code := p7_a45;
    ddp_vendor_contact_rec.org_id := p7_a46;
    ddp_vendor_contact_rec.operating_unit_name := p7_a47;
    ddp_vendor_contact_rec.prefix := p7_a48;
    ddp_vendor_contact_rec.contact_name_phonetic := p7_a49;








    -- here's the delegated call to the old PL/SQL routine
    ap_vendor_pub_pkg.validate_vendor_contact(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vendor_contact_rec,
      x_rel_party_valid,
      x_per_party_valid,
      x_rel_valid,
      x_org_party_id,
      x_org_contact_valid,
      x_location_id,
      x_party_site_valid);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddp_vendor_contact_rec.vendor_contact_id;
    p7_a1 := ddp_vendor_contact_rec.vendor_site_id;
    p7_a2 := ddp_vendor_contact_rec.vendor_id;
    p7_a3 := ddp_vendor_contact_rec.per_party_id;
    p7_a4 := ddp_vendor_contact_rec.relationship_id;
    p7_a5 := ddp_vendor_contact_rec.rel_party_id;
    p7_a6 := ddp_vendor_contact_rec.party_site_id;
    p7_a7 := ddp_vendor_contact_rec.org_contact_id;
    p7_a8 := ddp_vendor_contact_rec.org_party_site_id;
    p7_a9 := ddp_vendor_contact_rec.person_first_name;
    p7_a10 := ddp_vendor_contact_rec.person_middle_name;
    p7_a11 := ddp_vendor_contact_rec.person_last_name;
    p7_a12 := ddp_vendor_contact_rec.person_title;
    p7_a13 := ddp_vendor_contact_rec.organization_name_phonetic;
    p7_a14 := ddp_vendor_contact_rec.person_first_name_phonetic;
    p7_a15 := ddp_vendor_contact_rec.person_last_name_phonetic;
    p7_a16 := ddp_vendor_contact_rec.attribute1;
    p7_a17 := ddp_vendor_contact_rec.attribute2;
    p7_a18 := ddp_vendor_contact_rec.attribute3;
    p7_a19 := ddp_vendor_contact_rec.attribute4;
    p7_a20 := ddp_vendor_contact_rec.attribute5;
    p7_a21 := ddp_vendor_contact_rec.attribute6;
    p7_a22 := ddp_vendor_contact_rec.attribute7;
    p7_a23 := ddp_vendor_contact_rec.attribute8;
    p7_a24 := ddp_vendor_contact_rec.attribute9;
    p7_a25 := ddp_vendor_contact_rec.attribute10;
    p7_a26 := ddp_vendor_contact_rec.attribute11;
    p7_a27 := ddp_vendor_contact_rec.attribute12;
    p7_a28 := ddp_vendor_contact_rec.attribute13;
    p7_a29 := ddp_vendor_contact_rec.attribute14;
    p7_a30 := ddp_vendor_contact_rec.attribute15;
    p7_a31 := ddp_vendor_contact_rec.inactive_date;
    p7_a32 := ddp_vendor_contact_rec.party_number;
    p7_a33 := ddp_vendor_contact_rec.department;
    p7_a34 := ddp_vendor_contact_rec.mail_stop;
    p7_a35 := ddp_vendor_contact_rec.area_code;
    p7_a36 := ddp_vendor_contact_rec.phone;
    p7_a37 := ddp_vendor_contact_rec.alt_area_code;
    p7_a38 := ddp_vendor_contact_rec.alt_phone;
    p7_a39 := ddp_vendor_contact_rec.fax_area_code;
    p7_a40 := ddp_vendor_contact_rec.fax_phone;
    p7_a41 := ddp_vendor_contact_rec.email_address;
    p7_a42 := ddp_vendor_contact_rec.url;
    p7_a43 := ddp_vendor_contact_rec.vendor_contact_interface_id;
    p7_a44 := ddp_vendor_contact_rec.vendor_interface_id;
    p7_a45 := ddp_vendor_contact_rec.vendor_site_code;
    p7_a46 := ddp_vendor_contact_rec.org_id;
    p7_a47 := ddp_vendor_contact_rec.operating_unit_name;
    p7_a48 := ddp_vendor_contact_rec.prefix;
    p7_a49 := ddp_vendor_contact_rec.contact_name_phonetic;







  end;

end ap_vendor_pub_pkg_w;

/
