--------------------------------------------------------
--  DDL for Package Body OZF_SYS_PARAMETERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SYS_PARAMETERS_PVT_W" as
  /* $Header: ozfwsysb.pls 120.4.12010000.5 2009/07/27 09:36:21 nirprasa ship $ */
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

  procedure create_sys_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  NUMBER
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  NUMBER
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
    , p7_a54  NUMBER
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  NUMBER
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  NUMBER
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
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
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , x_set_of_books_id out nocopy  NUMBER
  )

  as
    ddp_sys_parameters_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_sys_parameters_rec.set_of_books_id := p7_a0;
    ddp_sys_parameters_rec.object_version_number := p7_a1;
    ddp_sys_parameters_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_sys_parameters_rec.last_updated_by := p7_a3;
    ddp_sys_parameters_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_sys_parameters_rec.created_by := p7_a5;
    ddp_sys_parameters_rec.last_update_login := p7_a6;
    ddp_sys_parameters_rec.request_id := p7_a7;
    ddp_sys_parameters_rec.program_application_id := p7_a8;
    ddp_sys_parameters_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_sys_parameters_rec.program_id := p7_a10;
    ddp_sys_parameters_rec.created_from := p7_a11;
    ddp_sys_parameters_rec.post_to_gl := p7_a12;
    ddp_sys_parameters_rec.transfer_to_gl_in := p7_a13;
    ddp_sys_parameters_rec.ap_payment_term_id := p7_a14;
    ddp_sys_parameters_rec.rounding_level_flag := p7_a15;
    ddp_sys_parameters_rec.gl_id_rounding := p7_a16;
    ddp_sys_parameters_rec.gl_id_ded_clearing := p7_a17;
    ddp_sys_parameters_rec.gl_id_ded_adj := p7_a18;
    ddp_sys_parameters_rec.gl_id_accr_promo_liab := p7_a19;
    ddp_sys_parameters_rec.gl_id_ded_adj_clearing := p7_a20;
    ddp_sys_parameters_rec.gl_rec_ded_account := p7_a21;
    ddp_sys_parameters_rec.gl_rec_clearing_account := p7_a22;
    ddp_sys_parameters_rec.gl_cost_adjustment_acct := p7_a23;
    ddp_sys_parameters_rec.gl_contra_liability_acct := p7_a24;
    ddp_sys_parameters_rec.gl_pp_accrual_acct := p7_a25;
    ddp_sys_parameters_rec.gl_date_type := p7_a26;
    ddp_sys_parameters_rec.days_due := p7_a27;
    ddp_sys_parameters_rec.claim_type_id := p7_a28;
    ddp_sys_parameters_rec.reason_code_id := p7_a29;
    ddp_sys_parameters_rec.autopay_claim_type_id := p7_a30;
    ddp_sys_parameters_rec.autopay_reason_code_id := p7_a31;
    ddp_sys_parameters_rec.autopay_flag := p7_a32;
    ddp_sys_parameters_rec.autopay_periodicity := p7_a33;
    ddp_sys_parameters_rec.autopay_periodicity_type := p7_a34;
    ddp_sys_parameters_rec.accounting_method_option := p7_a35;
    ddp_sys_parameters_rec.billback_trx_type_id := p7_a36;
    ddp_sys_parameters_rec.cm_trx_type_id := p7_a37;
    ddp_sys_parameters_rec.attribute_category := p7_a38;
    ddp_sys_parameters_rec.attribute1 := p7_a39;
    ddp_sys_parameters_rec.attribute2 := p7_a40;
    ddp_sys_parameters_rec.attribute3 := p7_a41;
    ddp_sys_parameters_rec.attribute4 := p7_a42;
    ddp_sys_parameters_rec.attribute5 := p7_a43;
    ddp_sys_parameters_rec.attribute6 := p7_a44;
    ddp_sys_parameters_rec.attribute7 := p7_a45;
    ddp_sys_parameters_rec.attribute8 := p7_a46;
    ddp_sys_parameters_rec.attribute9 := p7_a47;
    ddp_sys_parameters_rec.attribute10 := p7_a48;
    ddp_sys_parameters_rec.attribute11 := p7_a49;
    ddp_sys_parameters_rec.attribute12 := p7_a50;
    ddp_sys_parameters_rec.attribute13 := p7_a51;
    ddp_sys_parameters_rec.attribute14 := p7_a52;
    ddp_sys_parameters_rec.attribute15 := p7_a53;
    ddp_sys_parameters_rec.org_id := p7_a54;
    ddp_sys_parameters_rec.batch_source_id := p7_a55;
    ddp_sys_parameters_rec.payables_source := p7_a56;
    ddp_sys_parameters_rec.default_owner_id := p7_a57;
    ddp_sys_parameters_rec.auto_assign_flag := p7_a58;
    ddp_sys_parameters_rec.exchange_rate_type := p7_a59;
    ddp_sys_parameters_rec.order_type_id := p7_a60;
    ddp_sys_parameters_rec.gl_acct_for_offinv_flag := p7_a61;
    ddp_sys_parameters_rec.cb_trx_type_id := p7_a62;
    ddp_sys_parameters_rec.pos_write_off_threshold := p7_a63;
    ddp_sys_parameters_rec.neg_write_off_threshold := p7_a64;
    ddp_sys_parameters_rec.adj_rec_trx_id := p7_a65;
    ddp_sys_parameters_rec.wo_rec_trx_id := p7_a66;
    ddp_sys_parameters_rec.neg_wo_rec_trx_id := p7_a67;
    ddp_sys_parameters_rec.un_earned_pay_allow_to := p7_a68;
    ddp_sys_parameters_rec.un_earned_pay_thold_type := p7_a69;
    ddp_sys_parameters_rec.un_earned_pay_threshold := p7_a70;
    ddp_sys_parameters_rec.un_earned_pay_thold_flag := p7_a71;
    ddp_sys_parameters_rec.header_tolerance_calc_code := p7_a72;
    ddp_sys_parameters_rec.header_tolerance_operand := p7_a73;
    ddp_sys_parameters_rec.line_tolerance_calc_code := p7_a74;
    ddp_sys_parameters_rec.line_tolerance_operand := p7_a75;
    ddp_sys_parameters_rec.ship_debit_accrual_flag := p7_a76;
    ddp_sys_parameters_rec.ship_debit_calc_type := p7_a77;
    ddp_sys_parameters_rec.inventory_tracking_flag := p7_a78;
    ddp_sys_parameters_rec.end_cust_relation_flag := p7_a79;
    ddp_sys_parameters_rec.auto_tp_accrual_flag := p7_a80;
    ddp_sys_parameters_rec.gl_balancing_flex_value := p7_a81;
    ddp_sys_parameters_rec.prorate_earnings_flag := p7_a82;
    ddp_sys_parameters_rec.sales_credit_default_type := p7_a83;
    ddp_sys_parameters_rec.net_amt_for_mass_settle_flag := p7_a84;
    ddp_sys_parameters_rec.claim_tax_incl_flag := p7_a85;
    ddp_sys_parameters_rec.rule_based := p7_a86;
    ddp_sys_parameters_rec.approval_new_credit := p7_a87;
    ddp_sys_parameters_rec.approval_matched_credit := p7_a88;
    ddp_sys_parameters_rec.cust_name_match_type := p7_a89;
    ddp_sys_parameters_rec.credit_matching_thold_type := p7_a90;
    ddp_sys_parameters_rec.credit_tolerance_operand := p7_a91;
    ddp_sys_parameters_rec.automate_notification_days := p7_a92;
    ddp_sys_parameters_rec.ssd_inc_adj_type_id := p7_a93;
    ddp_sys_parameters_rec.ssd_dec_adj_type_id := p7_a94;


    -- here's the delegated call to the old PL/SQL routine
    ozf_sys_parameters_pvt.create_sys_parameters(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sys_parameters_rec,
      x_set_of_books_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_sys_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  NUMBER
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  NUMBER
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
    , p7_a54  NUMBER
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  NUMBER
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  NUMBER
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
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
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p_mode  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_sys_parameters_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_sys_parameters_rec.set_of_books_id := p7_a0;
    ddp_sys_parameters_rec.object_version_number := p7_a1;
    ddp_sys_parameters_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_sys_parameters_rec.last_updated_by := p7_a3;
    ddp_sys_parameters_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_sys_parameters_rec.created_by := p7_a5;
    ddp_sys_parameters_rec.last_update_login := p7_a6;
    ddp_sys_parameters_rec.request_id := p7_a7;
    ddp_sys_parameters_rec.program_application_id := p7_a8;
    ddp_sys_parameters_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_sys_parameters_rec.program_id := p7_a10;
    ddp_sys_parameters_rec.created_from := p7_a11;
    ddp_sys_parameters_rec.post_to_gl := p7_a12;
    ddp_sys_parameters_rec.transfer_to_gl_in := p7_a13;
    ddp_sys_parameters_rec.ap_payment_term_id := p7_a14;
    ddp_sys_parameters_rec.rounding_level_flag := p7_a15;
    ddp_sys_parameters_rec.gl_id_rounding := p7_a16;
    ddp_sys_parameters_rec.gl_id_ded_clearing := p7_a17;
    ddp_sys_parameters_rec.gl_id_ded_adj := p7_a18;
    ddp_sys_parameters_rec.gl_id_accr_promo_liab := p7_a19;
    ddp_sys_parameters_rec.gl_id_ded_adj_clearing := p7_a20;
    ddp_sys_parameters_rec.gl_rec_ded_account := p7_a21;
    ddp_sys_parameters_rec.gl_rec_clearing_account := p7_a22;
    ddp_sys_parameters_rec.gl_cost_adjustment_acct := p7_a23;
    ddp_sys_parameters_rec.gl_contra_liability_acct := p7_a24;
    ddp_sys_parameters_rec.gl_pp_accrual_acct := p7_a25;
    ddp_sys_parameters_rec.gl_date_type := p7_a26;
    ddp_sys_parameters_rec.days_due := p7_a27;
    ddp_sys_parameters_rec.claim_type_id := p7_a28;
    ddp_sys_parameters_rec.reason_code_id := p7_a29;
    ddp_sys_parameters_rec.autopay_claim_type_id := p7_a30;
    ddp_sys_parameters_rec.autopay_reason_code_id := p7_a31;
    ddp_sys_parameters_rec.autopay_flag := p7_a32;
    ddp_sys_parameters_rec.autopay_periodicity := p7_a33;
    ddp_sys_parameters_rec.autopay_periodicity_type := p7_a34;
    ddp_sys_parameters_rec.accounting_method_option := p7_a35;
    ddp_sys_parameters_rec.billback_trx_type_id := p7_a36;
    ddp_sys_parameters_rec.cm_trx_type_id := p7_a37;
    ddp_sys_parameters_rec.attribute_category := p7_a38;
    ddp_sys_parameters_rec.attribute1 := p7_a39;
    ddp_sys_parameters_rec.attribute2 := p7_a40;
    ddp_sys_parameters_rec.attribute3 := p7_a41;
    ddp_sys_parameters_rec.attribute4 := p7_a42;
    ddp_sys_parameters_rec.attribute5 := p7_a43;
    ddp_sys_parameters_rec.attribute6 := p7_a44;
    ddp_sys_parameters_rec.attribute7 := p7_a45;
    ddp_sys_parameters_rec.attribute8 := p7_a46;
    ddp_sys_parameters_rec.attribute9 := p7_a47;
    ddp_sys_parameters_rec.attribute10 := p7_a48;
    ddp_sys_parameters_rec.attribute11 := p7_a49;
    ddp_sys_parameters_rec.attribute12 := p7_a50;
    ddp_sys_parameters_rec.attribute13 := p7_a51;
    ddp_sys_parameters_rec.attribute14 := p7_a52;
    ddp_sys_parameters_rec.attribute15 := p7_a53;
    ddp_sys_parameters_rec.org_id := p7_a54;
    ddp_sys_parameters_rec.batch_source_id := p7_a55;
    ddp_sys_parameters_rec.payables_source := p7_a56;
    ddp_sys_parameters_rec.default_owner_id := p7_a57;
    ddp_sys_parameters_rec.auto_assign_flag := p7_a58;
    ddp_sys_parameters_rec.exchange_rate_type := p7_a59;
    ddp_sys_parameters_rec.order_type_id := p7_a60;
    ddp_sys_parameters_rec.gl_acct_for_offinv_flag := p7_a61;
    ddp_sys_parameters_rec.cb_trx_type_id := p7_a62;
    ddp_sys_parameters_rec.pos_write_off_threshold := p7_a63;
    ddp_sys_parameters_rec.neg_write_off_threshold := p7_a64;
    ddp_sys_parameters_rec.adj_rec_trx_id := p7_a65;
    ddp_sys_parameters_rec.wo_rec_trx_id := p7_a66;
    ddp_sys_parameters_rec.neg_wo_rec_trx_id := p7_a67;
    ddp_sys_parameters_rec.un_earned_pay_allow_to := p7_a68;
    ddp_sys_parameters_rec.un_earned_pay_thold_type := p7_a69;
    ddp_sys_parameters_rec.un_earned_pay_threshold := p7_a70;
    ddp_sys_parameters_rec.un_earned_pay_thold_flag := p7_a71;
    ddp_sys_parameters_rec.header_tolerance_calc_code := p7_a72;
    ddp_sys_parameters_rec.header_tolerance_operand := p7_a73;
    ddp_sys_parameters_rec.line_tolerance_calc_code := p7_a74;
    ddp_sys_parameters_rec.line_tolerance_operand := p7_a75;
    ddp_sys_parameters_rec.ship_debit_accrual_flag := p7_a76;
    ddp_sys_parameters_rec.ship_debit_calc_type := p7_a77;
    ddp_sys_parameters_rec.inventory_tracking_flag := p7_a78;
    ddp_sys_parameters_rec.end_cust_relation_flag := p7_a79;
    ddp_sys_parameters_rec.auto_tp_accrual_flag := p7_a80;
    ddp_sys_parameters_rec.gl_balancing_flex_value := p7_a81;
    ddp_sys_parameters_rec.prorate_earnings_flag := p7_a82;
    ddp_sys_parameters_rec.sales_credit_default_type := p7_a83;
    ddp_sys_parameters_rec.net_amt_for_mass_settle_flag := p7_a84;
    ddp_sys_parameters_rec.claim_tax_incl_flag := p7_a85;
    ddp_sys_parameters_rec.rule_based := p7_a86;
    ddp_sys_parameters_rec.approval_new_credit := p7_a87;
    ddp_sys_parameters_rec.approval_matched_credit := p7_a88;
    ddp_sys_parameters_rec.cust_name_match_type := p7_a89;
    ddp_sys_parameters_rec.credit_matching_thold_type := p7_a90;
    ddp_sys_parameters_rec.credit_tolerance_operand := p7_a91;
    ddp_sys_parameters_rec.automate_notification_days := p7_a92;
    ddp_sys_parameters_rec.ssd_inc_adj_type_id := p7_a93;
    ddp_sys_parameters_rec.ssd_dec_adj_type_id := p7_a94;



    -- here's the delegated call to the old PL/SQL routine
    ozf_sys_parameters_pvt.update_sys_parameters(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sys_parameters_rec,
      p_mode,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure validate_sys_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  VARCHAR2
    , p6_a33  NUMBER
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  NUMBER
    , p6_a55  NUMBER
    , p6_a56  VARCHAR2
    , p6_a57  NUMBER
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  NUMBER
    , p6_a61  VARCHAR2
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  NUMBER
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  NUMBER
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  NUMBER
    , p6_a74  VARCHAR2
    , p6_a75  NUMBER
    , p6_a76  VARCHAR2
    , p6_a77  VARCHAR2
    , p6_a78  VARCHAR2
    , p6_a79  VARCHAR2
    , p6_a80  VARCHAR2
    , p6_a81  VARCHAR2
    , p6_a82  VARCHAR2
    , p6_a83  VARCHAR2
    , p6_a84  VARCHAR2
    , p6_a85  VARCHAR2
    , p6_a86  VARCHAR2
    , p6_a87  VARCHAR2
    , p6_a88  VARCHAR2
    , p6_a89  VARCHAR2
    , p6_a90  VARCHAR2
    , p6_a91  NUMBER
    , p6_a92  NUMBER
    , p6_a93  NUMBER
    , p6_a94  NUMBER
  )

  as
    ddp_sys_parameters_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_sys_parameters_rec.set_of_books_id := p6_a0;
    ddp_sys_parameters_rec.object_version_number := p6_a1;
    ddp_sys_parameters_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_sys_parameters_rec.last_updated_by := p6_a3;
    ddp_sys_parameters_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_sys_parameters_rec.created_by := p6_a5;
    ddp_sys_parameters_rec.last_update_login := p6_a6;
    ddp_sys_parameters_rec.request_id := p6_a7;
    ddp_sys_parameters_rec.program_application_id := p6_a8;
    ddp_sys_parameters_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_sys_parameters_rec.program_id := p6_a10;
    ddp_sys_parameters_rec.created_from := p6_a11;
    ddp_sys_parameters_rec.post_to_gl := p6_a12;
    ddp_sys_parameters_rec.transfer_to_gl_in := p6_a13;
    ddp_sys_parameters_rec.ap_payment_term_id := p6_a14;
    ddp_sys_parameters_rec.rounding_level_flag := p6_a15;
    ddp_sys_parameters_rec.gl_id_rounding := p6_a16;
    ddp_sys_parameters_rec.gl_id_ded_clearing := p6_a17;
    ddp_sys_parameters_rec.gl_id_ded_adj := p6_a18;
    ddp_sys_parameters_rec.gl_id_accr_promo_liab := p6_a19;
    ddp_sys_parameters_rec.gl_id_ded_adj_clearing := p6_a20;
    ddp_sys_parameters_rec.gl_rec_ded_account := p6_a21;
    ddp_sys_parameters_rec.gl_rec_clearing_account := p6_a22;
    ddp_sys_parameters_rec.gl_cost_adjustment_acct := p6_a23;
    ddp_sys_parameters_rec.gl_contra_liability_acct := p6_a24;
    ddp_sys_parameters_rec.gl_pp_accrual_acct := p6_a25;
    ddp_sys_parameters_rec.gl_date_type := p6_a26;
    ddp_sys_parameters_rec.days_due := p6_a27;
    ddp_sys_parameters_rec.claim_type_id := p6_a28;
    ddp_sys_parameters_rec.reason_code_id := p6_a29;
    ddp_sys_parameters_rec.autopay_claim_type_id := p6_a30;
    ddp_sys_parameters_rec.autopay_reason_code_id := p6_a31;
    ddp_sys_parameters_rec.autopay_flag := p6_a32;
    ddp_sys_parameters_rec.autopay_periodicity := p6_a33;
    ddp_sys_parameters_rec.autopay_periodicity_type := p6_a34;
    ddp_sys_parameters_rec.accounting_method_option := p6_a35;
    ddp_sys_parameters_rec.billback_trx_type_id := p6_a36;
    ddp_sys_parameters_rec.cm_trx_type_id := p6_a37;
    ddp_sys_parameters_rec.attribute_category := p6_a38;
    ddp_sys_parameters_rec.attribute1 := p6_a39;
    ddp_sys_parameters_rec.attribute2 := p6_a40;
    ddp_sys_parameters_rec.attribute3 := p6_a41;
    ddp_sys_parameters_rec.attribute4 := p6_a42;
    ddp_sys_parameters_rec.attribute5 := p6_a43;
    ddp_sys_parameters_rec.attribute6 := p6_a44;
    ddp_sys_parameters_rec.attribute7 := p6_a45;
    ddp_sys_parameters_rec.attribute8 := p6_a46;
    ddp_sys_parameters_rec.attribute9 := p6_a47;
    ddp_sys_parameters_rec.attribute10 := p6_a48;
    ddp_sys_parameters_rec.attribute11 := p6_a49;
    ddp_sys_parameters_rec.attribute12 := p6_a50;
    ddp_sys_parameters_rec.attribute13 := p6_a51;
    ddp_sys_parameters_rec.attribute14 := p6_a52;
    ddp_sys_parameters_rec.attribute15 := p6_a53;
    ddp_sys_parameters_rec.org_id := p6_a54;
    ddp_sys_parameters_rec.batch_source_id := p6_a55;
    ddp_sys_parameters_rec.payables_source := p6_a56;
    ddp_sys_parameters_rec.default_owner_id := p6_a57;
    ddp_sys_parameters_rec.auto_assign_flag := p6_a58;
    ddp_sys_parameters_rec.exchange_rate_type := p6_a59;
    ddp_sys_parameters_rec.order_type_id := p6_a60;
    ddp_sys_parameters_rec.gl_acct_for_offinv_flag := p6_a61;
    ddp_sys_parameters_rec.cb_trx_type_id := p6_a62;
    ddp_sys_parameters_rec.pos_write_off_threshold := p6_a63;
    ddp_sys_parameters_rec.neg_write_off_threshold := p6_a64;
    ddp_sys_parameters_rec.adj_rec_trx_id := p6_a65;
    ddp_sys_parameters_rec.wo_rec_trx_id := p6_a66;
    ddp_sys_parameters_rec.neg_wo_rec_trx_id := p6_a67;
    ddp_sys_parameters_rec.un_earned_pay_allow_to := p6_a68;
    ddp_sys_parameters_rec.un_earned_pay_thold_type := p6_a69;
    ddp_sys_parameters_rec.un_earned_pay_threshold := p6_a70;
    ddp_sys_parameters_rec.un_earned_pay_thold_flag := p6_a71;
    ddp_sys_parameters_rec.header_tolerance_calc_code := p6_a72;
    ddp_sys_parameters_rec.header_tolerance_operand := p6_a73;
    ddp_sys_parameters_rec.line_tolerance_calc_code := p6_a74;
    ddp_sys_parameters_rec.line_tolerance_operand := p6_a75;
    ddp_sys_parameters_rec.ship_debit_accrual_flag := p6_a76;
    ddp_sys_parameters_rec.ship_debit_calc_type := p6_a77;
    ddp_sys_parameters_rec.inventory_tracking_flag := p6_a78;
    ddp_sys_parameters_rec.end_cust_relation_flag := p6_a79;
    ddp_sys_parameters_rec.auto_tp_accrual_flag := p6_a80;
    ddp_sys_parameters_rec.gl_balancing_flex_value := p6_a81;
    ddp_sys_parameters_rec.prorate_earnings_flag := p6_a82;
    ddp_sys_parameters_rec.sales_credit_default_type := p6_a83;
    ddp_sys_parameters_rec.net_amt_for_mass_settle_flag := p6_a84;
    ddp_sys_parameters_rec.claim_tax_incl_flag := p6_a85;
    ddp_sys_parameters_rec.rule_based := p6_a86;
    ddp_sys_parameters_rec.approval_new_credit := p6_a87;
    ddp_sys_parameters_rec.approval_matched_credit := p6_a88;
    ddp_sys_parameters_rec.cust_name_match_type := p6_a89;
    ddp_sys_parameters_rec.credit_matching_thold_type := p6_a90;
    ddp_sys_parameters_rec.credit_tolerance_operand := p6_a91;
    ddp_sys_parameters_rec.automate_notification_days := p6_a92;
    ddp_sys_parameters_rec.ssd_inc_adj_type_id := p6_a93;
    ddp_sys_parameters_rec.ssd_dec_adj_type_id := p6_a94;

    -- here's the delegated call to the old PL/SQL routine
    ozf_sys_parameters_pvt.validate_sys_parameters(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sys_parameters_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_sys_parameters_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  VARCHAR2
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  NUMBER
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  VARCHAR2
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_sys_parameters_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_sys_parameters_rec.set_of_books_id := p0_a0;
    ddp_sys_parameters_rec.object_version_number := p0_a1;
    ddp_sys_parameters_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_sys_parameters_rec.last_updated_by := p0_a3;
    ddp_sys_parameters_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_sys_parameters_rec.created_by := p0_a5;
    ddp_sys_parameters_rec.last_update_login := p0_a6;
    ddp_sys_parameters_rec.request_id := p0_a7;
    ddp_sys_parameters_rec.program_application_id := p0_a8;
    ddp_sys_parameters_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_sys_parameters_rec.program_id := p0_a10;
    ddp_sys_parameters_rec.created_from := p0_a11;
    ddp_sys_parameters_rec.post_to_gl := p0_a12;
    ddp_sys_parameters_rec.transfer_to_gl_in := p0_a13;
    ddp_sys_parameters_rec.ap_payment_term_id := p0_a14;
    ddp_sys_parameters_rec.rounding_level_flag := p0_a15;
    ddp_sys_parameters_rec.gl_id_rounding := p0_a16;
    ddp_sys_parameters_rec.gl_id_ded_clearing := p0_a17;
    ddp_sys_parameters_rec.gl_id_ded_adj := p0_a18;
    ddp_sys_parameters_rec.gl_id_accr_promo_liab := p0_a19;
    ddp_sys_parameters_rec.gl_id_ded_adj_clearing := p0_a20;
    ddp_sys_parameters_rec.gl_rec_ded_account := p0_a21;
    ddp_sys_parameters_rec.gl_rec_clearing_account := p0_a22;
    ddp_sys_parameters_rec.gl_cost_adjustment_acct := p0_a23;
    ddp_sys_parameters_rec.gl_contra_liability_acct := p0_a24;
    ddp_sys_parameters_rec.gl_pp_accrual_acct := p0_a25;
    ddp_sys_parameters_rec.gl_date_type := p0_a26;
    ddp_sys_parameters_rec.days_due := p0_a27;
    ddp_sys_parameters_rec.claim_type_id := p0_a28;
    ddp_sys_parameters_rec.reason_code_id := p0_a29;
    ddp_sys_parameters_rec.autopay_claim_type_id := p0_a30;
    ddp_sys_parameters_rec.autopay_reason_code_id := p0_a31;
    ddp_sys_parameters_rec.autopay_flag := p0_a32;
    ddp_sys_parameters_rec.autopay_periodicity := p0_a33;
    ddp_sys_parameters_rec.autopay_periodicity_type := p0_a34;
    ddp_sys_parameters_rec.accounting_method_option := p0_a35;
    ddp_sys_parameters_rec.billback_trx_type_id := p0_a36;
    ddp_sys_parameters_rec.cm_trx_type_id := p0_a37;
    ddp_sys_parameters_rec.attribute_category := p0_a38;
    ddp_sys_parameters_rec.attribute1 := p0_a39;
    ddp_sys_parameters_rec.attribute2 := p0_a40;
    ddp_sys_parameters_rec.attribute3 := p0_a41;
    ddp_sys_parameters_rec.attribute4 := p0_a42;
    ddp_sys_parameters_rec.attribute5 := p0_a43;
    ddp_sys_parameters_rec.attribute6 := p0_a44;
    ddp_sys_parameters_rec.attribute7 := p0_a45;
    ddp_sys_parameters_rec.attribute8 := p0_a46;
    ddp_sys_parameters_rec.attribute9 := p0_a47;
    ddp_sys_parameters_rec.attribute10 := p0_a48;
    ddp_sys_parameters_rec.attribute11 := p0_a49;
    ddp_sys_parameters_rec.attribute12 := p0_a50;
    ddp_sys_parameters_rec.attribute13 := p0_a51;
    ddp_sys_parameters_rec.attribute14 := p0_a52;
    ddp_sys_parameters_rec.attribute15 := p0_a53;
    ddp_sys_parameters_rec.org_id := p0_a54;
    ddp_sys_parameters_rec.batch_source_id := p0_a55;
    ddp_sys_parameters_rec.payables_source := p0_a56;
    ddp_sys_parameters_rec.default_owner_id := p0_a57;
    ddp_sys_parameters_rec.auto_assign_flag := p0_a58;
    ddp_sys_parameters_rec.exchange_rate_type := p0_a59;
    ddp_sys_parameters_rec.order_type_id := p0_a60;
    ddp_sys_parameters_rec.gl_acct_for_offinv_flag := p0_a61;
    ddp_sys_parameters_rec.cb_trx_type_id := p0_a62;
    ddp_sys_parameters_rec.pos_write_off_threshold := p0_a63;
    ddp_sys_parameters_rec.neg_write_off_threshold := p0_a64;
    ddp_sys_parameters_rec.adj_rec_trx_id := p0_a65;
    ddp_sys_parameters_rec.wo_rec_trx_id := p0_a66;
    ddp_sys_parameters_rec.neg_wo_rec_trx_id := p0_a67;
    ddp_sys_parameters_rec.un_earned_pay_allow_to := p0_a68;
    ddp_sys_parameters_rec.un_earned_pay_thold_type := p0_a69;
    ddp_sys_parameters_rec.un_earned_pay_threshold := p0_a70;
    ddp_sys_parameters_rec.un_earned_pay_thold_flag := p0_a71;
    ddp_sys_parameters_rec.header_tolerance_calc_code := p0_a72;
    ddp_sys_parameters_rec.header_tolerance_operand := p0_a73;
    ddp_sys_parameters_rec.line_tolerance_calc_code := p0_a74;
    ddp_sys_parameters_rec.line_tolerance_operand := p0_a75;
    ddp_sys_parameters_rec.ship_debit_accrual_flag := p0_a76;
    ddp_sys_parameters_rec.ship_debit_calc_type := p0_a77;
    ddp_sys_parameters_rec.inventory_tracking_flag := p0_a78;
    ddp_sys_parameters_rec.end_cust_relation_flag := p0_a79;
    ddp_sys_parameters_rec.auto_tp_accrual_flag := p0_a80;
    ddp_sys_parameters_rec.gl_balancing_flex_value := p0_a81;
    ddp_sys_parameters_rec.prorate_earnings_flag := p0_a82;
    ddp_sys_parameters_rec.sales_credit_default_type := p0_a83;
    ddp_sys_parameters_rec.net_amt_for_mass_settle_flag := p0_a84;
    ddp_sys_parameters_rec.claim_tax_incl_flag := p0_a85;
    ddp_sys_parameters_rec.rule_based := p0_a86;
    ddp_sys_parameters_rec.approval_new_credit := p0_a87;
    ddp_sys_parameters_rec.approval_matched_credit := p0_a88;
    ddp_sys_parameters_rec.cust_name_match_type := p0_a89;
    ddp_sys_parameters_rec.credit_matching_thold_type := p0_a90;
    ddp_sys_parameters_rec.credit_tolerance_operand := p0_a91;
    ddp_sys_parameters_rec.automate_notification_days := p0_a92;
    ddp_sys_parameters_rec.ssd_inc_adj_type_id := p0_a93;
    ddp_sys_parameters_rec.ssd_dec_adj_type_id := p0_a94;



    -- here's the delegated call to the old PL/SQL routine
    ozf_sys_parameters_pvt.check_sys_parameters_items(ddp_sys_parameters_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_sys_parameters_record(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  VARCHAR2
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  NUMBER
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  VARCHAR2
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  DATE
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  NUMBER
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  VARCHAR2
    , p1_a33  NUMBER
    , p1_a34  VARCHAR2
    , p1_a35  VARCHAR2
    , p1_a36  NUMBER
    , p1_a37  NUMBER
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
    , p1_a54  NUMBER
    , p1_a55  NUMBER
    , p1_a56  VARCHAR2
    , p1_a57  NUMBER
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  NUMBER
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  NUMBER
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  NUMBER
    , p1_a74  VARCHAR2
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  VARCHAR2
    , p1_a83  VARCHAR2
    , p1_a84  VARCHAR2
    , p1_a85  VARCHAR2
    , p1_a86  VARCHAR2
    , p1_a87  VARCHAR2
    , p1_a88  VARCHAR2
    , p1_a89  VARCHAR2
    , p1_a90  VARCHAR2
    , p1_a91  NUMBER
    , p1_a92  NUMBER
    , p1_a93  NUMBER
    , p1_a94  NUMBER
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_sys_parameters_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddp_complete_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_sys_parameters_rec.set_of_books_id := p0_a0;
    ddp_sys_parameters_rec.object_version_number := p0_a1;
    ddp_sys_parameters_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_sys_parameters_rec.last_updated_by := p0_a3;
    ddp_sys_parameters_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_sys_parameters_rec.created_by := p0_a5;
    ddp_sys_parameters_rec.last_update_login := p0_a6;
    ddp_sys_parameters_rec.request_id := p0_a7;
    ddp_sys_parameters_rec.program_application_id := p0_a8;
    ddp_sys_parameters_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_sys_parameters_rec.program_id := p0_a10;
    ddp_sys_parameters_rec.created_from := p0_a11;
    ddp_sys_parameters_rec.post_to_gl := p0_a12;
    ddp_sys_parameters_rec.transfer_to_gl_in := p0_a13;
    ddp_sys_parameters_rec.ap_payment_term_id := p0_a14;
    ddp_sys_parameters_rec.rounding_level_flag := p0_a15;
    ddp_sys_parameters_rec.gl_id_rounding := p0_a16;
    ddp_sys_parameters_rec.gl_id_ded_clearing := p0_a17;
    ddp_sys_parameters_rec.gl_id_ded_adj := p0_a18;
    ddp_sys_parameters_rec.gl_id_accr_promo_liab := p0_a19;
    ddp_sys_parameters_rec.gl_id_ded_adj_clearing := p0_a20;
    ddp_sys_parameters_rec.gl_rec_ded_account := p0_a21;
    ddp_sys_parameters_rec.gl_rec_clearing_account := p0_a22;
    ddp_sys_parameters_rec.gl_cost_adjustment_acct := p0_a23;
    ddp_sys_parameters_rec.gl_contra_liability_acct := p0_a24;
    ddp_sys_parameters_rec.gl_pp_accrual_acct := p0_a25;
    ddp_sys_parameters_rec.gl_date_type := p0_a26;
    ddp_sys_parameters_rec.days_due := p0_a27;
    ddp_sys_parameters_rec.claim_type_id := p0_a28;
    ddp_sys_parameters_rec.reason_code_id := p0_a29;
    ddp_sys_parameters_rec.autopay_claim_type_id := p0_a30;
    ddp_sys_parameters_rec.autopay_reason_code_id := p0_a31;
    ddp_sys_parameters_rec.autopay_flag := p0_a32;
    ddp_sys_parameters_rec.autopay_periodicity := p0_a33;
    ddp_sys_parameters_rec.autopay_periodicity_type := p0_a34;
    ddp_sys_parameters_rec.accounting_method_option := p0_a35;
    ddp_sys_parameters_rec.billback_trx_type_id := p0_a36;
    ddp_sys_parameters_rec.cm_trx_type_id := p0_a37;
    ddp_sys_parameters_rec.attribute_category := p0_a38;
    ddp_sys_parameters_rec.attribute1 := p0_a39;
    ddp_sys_parameters_rec.attribute2 := p0_a40;
    ddp_sys_parameters_rec.attribute3 := p0_a41;
    ddp_sys_parameters_rec.attribute4 := p0_a42;
    ddp_sys_parameters_rec.attribute5 := p0_a43;
    ddp_sys_parameters_rec.attribute6 := p0_a44;
    ddp_sys_parameters_rec.attribute7 := p0_a45;
    ddp_sys_parameters_rec.attribute8 := p0_a46;
    ddp_sys_parameters_rec.attribute9 := p0_a47;
    ddp_sys_parameters_rec.attribute10 := p0_a48;
    ddp_sys_parameters_rec.attribute11 := p0_a49;
    ddp_sys_parameters_rec.attribute12 := p0_a50;
    ddp_sys_parameters_rec.attribute13 := p0_a51;
    ddp_sys_parameters_rec.attribute14 := p0_a52;
    ddp_sys_parameters_rec.attribute15 := p0_a53;
    ddp_sys_parameters_rec.org_id := p0_a54;
    ddp_sys_parameters_rec.batch_source_id := p0_a55;
    ddp_sys_parameters_rec.payables_source := p0_a56;
    ddp_sys_parameters_rec.default_owner_id := p0_a57;
    ddp_sys_parameters_rec.auto_assign_flag := p0_a58;
    ddp_sys_parameters_rec.exchange_rate_type := p0_a59;
    ddp_sys_parameters_rec.order_type_id := p0_a60;
    ddp_sys_parameters_rec.gl_acct_for_offinv_flag := p0_a61;
    ddp_sys_parameters_rec.cb_trx_type_id := p0_a62;
    ddp_sys_parameters_rec.pos_write_off_threshold := p0_a63;
    ddp_sys_parameters_rec.neg_write_off_threshold := p0_a64;
    ddp_sys_parameters_rec.adj_rec_trx_id := p0_a65;
    ddp_sys_parameters_rec.wo_rec_trx_id := p0_a66;
    ddp_sys_parameters_rec.neg_wo_rec_trx_id := p0_a67;
    ddp_sys_parameters_rec.un_earned_pay_allow_to := p0_a68;
    ddp_sys_parameters_rec.un_earned_pay_thold_type := p0_a69;
    ddp_sys_parameters_rec.un_earned_pay_threshold := p0_a70;
    ddp_sys_parameters_rec.un_earned_pay_thold_flag := p0_a71;
    ddp_sys_parameters_rec.header_tolerance_calc_code := p0_a72;
    ddp_sys_parameters_rec.header_tolerance_operand := p0_a73;
    ddp_sys_parameters_rec.line_tolerance_calc_code := p0_a74;
    ddp_sys_parameters_rec.line_tolerance_operand := p0_a75;
    ddp_sys_parameters_rec.ship_debit_accrual_flag := p0_a76;
    ddp_sys_parameters_rec.ship_debit_calc_type := p0_a77;
    ddp_sys_parameters_rec.inventory_tracking_flag := p0_a78;
    ddp_sys_parameters_rec.end_cust_relation_flag := p0_a79;
    ddp_sys_parameters_rec.auto_tp_accrual_flag := p0_a80;
    ddp_sys_parameters_rec.gl_balancing_flex_value := p0_a81;
    ddp_sys_parameters_rec.prorate_earnings_flag := p0_a82;
    ddp_sys_parameters_rec.sales_credit_default_type := p0_a83;
    ddp_sys_parameters_rec.net_amt_for_mass_settle_flag := p0_a84;
    ddp_sys_parameters_rec.claim_tax_incl_flag := p0_a85;
    ddp_sys_parameters_rec.rule_based := p0_a86;
    ddp_sys_parameters_rec.approval_new_credit := p0_a87;
    ddp_sys_parameters_rec.approval_matched_credit := p0_a88;
    ddp_sys_parameters_rec.cust_name_match_type := p0_a89;
    ddp_sys_parameters_rec.credit_matching_thold_type := p0_a90;
    ddp_sys_parameters_rec.credit_tolerance_operand := p0_a91;
    ddp_sys_parameters_rec.automate_notification_days := p0_a92;
    ddp_sys_parameters_rec.ssd_inc_adj_type_id := p0_a93;
    ddp_sys_parameters_rec.ssd_dec_adj_type_id := p0_a94;

    ddp_complete_rec.set_of_books_id := p1_a0;
    ddp_complete_rec.object_version_number := p1_a1;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_complete_rec.last_updated_by := p1_a3;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_rec.created_by := p1_a5;
    ddp_complete_rec.last_update_login := p1_a6;
    ddp_complete_rec.request_id := p1_a7;
    ddp_complete_rec.program_application_id := p1_a8;
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_complete_rec.program_id := p1_a10;
    ddp_complete_rec.created_from := p1_a11;
    ddp_complete_rec.post_to_gl := p1_a12;
    ddp_complete_rec.transfer_to_gl_in := p1_a13;
    ddp_complete_rec.ap_payment_term_id := p1_a14;
    ddp_complete_rec.rounding_level_flag := p1_a15;
    ddp_complete_rec.gl_id_rounding := p1_a16;
    ddp_complete_rec.gl_id_ded_clearing := p1_a17;
    ddp_complete_rec.gl_id_ded_adj := p1_a18;
    ddp_complete_rec.gl_id_accr_promo_liab := p1_a19;
    ddp_complete_rec.gl_id_ded_adj_clearing := p1_a20;
    ddp_complete_rec.gl_rec_ded_account := p1_a21;
    ddp_complete_rec.gl_rec_clearing_account := p1_a22;
    ddp_complete_rec.gl_cost_adjustment_acct := p1_a23;
    ddp_complete_rec.gl_contra_liability_acct := p1_a24;
    ddp_complete_rec.gl_pp_accrual_acct := p1_a25;
    ddp_complete_rec.gl_date_type := p1_a26;
    ddp_complete_rec.days_due := p1_a27;
    ddp_complete_rec.claim_type_id := p1_a28;
    ddp_complete_rec.reason_code_id := p1_a29;
    ddp_complete_rec.autopay_claim_type_id := p1_a30;
    ddp_complete_rec.autopay_reason_code_id := p1_a31;
    ddp_complete_rec.autopay_flag := p1_a32;
    ddp_complete_rec.autopay_periodicity := p1_a33;
    ddp_complete_rec.autopay_periodicity_type := p1_a34;
    ddp_complete_rec.accounting_method_option := p1_a35;
    ddp_complete_rec.billback_trx_type_id := p1_a36;
    ddp_complete_rec.cm_trx_type_id := p1_a37;
    ddp_complete_rec.attribute_category := p1_a38;
    ddp_complete_rec.attribute1 := p1_a39;
    ddp_complete_rec.attribute2 := p1_a40;
    ddp_complete_rec.attribute3 := p1_a41;
    ddp_complete_rec.attribute4 := p1_a42;
    ddp_complete_rec.attribute5 := p1_a43;
    ddp_complete_rec.attribute6 := p1_a44;
    ddp_complete_rec.attribute7 := p1_a45;
    ddp_complete_rec.attribute8 := p1_a46;
    ddp_complete_rec.attribute9 := p1_a47;
    ddp_complete_rec.attribute10 := p1_a48;
    ddp_complete_rec.attribute11 := p1_a49;
    ddp_complete_rec.attribute12 := p1_a50;
    ddp_complete_rec.attribute13 := p1_a51;
    ddp_complete_rec.attribute14 := p1_a52;
    ddp_complete_rec.attribute15 := p1_a53;
    ddp_complete_rec.org_id := p1_a54;
    ddp_complete_rec.batch_source_id := p1_a55;
    ddp_complete_rec.payables_source := p1_a56;
    ddp_complete_rec.default_owner_id := p1_a57;
    ddp_complete_rec.auto_assign_flag := p1_a58;
    ddp_complete_rec.exchange_rate_type := p1_a59;
    ddp_complete_rec.order_type_id := p1_a60;
    ddp_complete_rec.gl_acct_for_offinv_flag := p1_a61;
    ddp_complete_rec.cb_trx_type_id := p1_a62;
    ddp_complete_rec.pos_write_off_threshold := p1_a63;
    ddp_complete_rec.neg_write_off_threshold := p1_a64;
    ddp_complete_rec.adj_rec_trx_id := p1_a65;
    ddp_complete_rec.wo_rec_trx_id := p1_a66;
    ddp_complete_rec.neg_wo_rec_trx_id := p1_a67;
    ddp_complete_rec.un_earned_pay_allow_to := p1_a68;
    ddp_complete_rec.un_earned_pay_thold_type := p1_a69;
    ddp_complete_rec.un_earned_pay_threshold := p1_a70;
    ddp_complete_rec.un_earned_pay_thold_flag := p1_a71;
    ddp_complete_rec.header_tolerance_calc_code := p1_a72;
    ddp_complete_rec.header_tolerance_operand := p1_a73;
    ddp_complete_rec.line_tolerance_calc_code := p1_a74;
    ddp_complete_rec.line_tolerance_operand := p1_a75;
    ddp_complete_rec.ship_debit_accrual_flag := p1_a76;
    ddp_complete_rec.ship_debit_calc_type := p1_a77;
    ddp_complete_rec.inventory_tracking_flag := p1_a78;
    ddp_complete_rec.end_cust_relation_flag := p1_a79;
    ddp_complete_rec.auto_tp_accrual_flag := p1_a80;
    ddp_complete_rec.gl_balancing_flex_value := p1_a81;
    ddp_complete_rec.prorate_earnings_flag := p1_a82;
    ddp_complete_rec.sales_credit_default_type := p1_a83;
    ddp_complete_rec.net_amt_for_mass_settle_flag := p1_a84;
    ddp_complete_rec.claim_tax_incl_flag := p1_a85;
    ddp_complete_rec.rule_based := p1_a86;
    ddp_complete_rec.approval_new_credit := p1_a87;
    ddp_complete_rec.approval_matched_credit := p1_a88;
    ddp_complete_rec.cust_name_match_type := p1_a89;
    ddp_complete_rec.credit_matching_thold_type := p1_a90;
    ddp_complete_rec.credit_tolerance_operand := p1_a91;
    ddp_complete_rec.automate_notification_days := p1_a92;
    ddp_complete_rec.ssd_inc_adj_type_id := p1_a93;
    ddp_complete_rec.ssd_dec_adj_type_id := p1_a94;



    -- here's the delegated call to the old PL/SQL routine
    ozf_sys_parameters_pvt.check_sys_parameters_record(ddp_sys_parameters_rec,
      ddp_complete_rec,
      p_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure init_sys_parameters_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  NUMBER
    , p0_a2 out nocopy  DATE
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  DATE
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  NUMBER
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  NUMBER
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  NUMBER
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  VARCHAR2
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  VARCHAR2
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  VARCHAR2
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  NUMBER
    , p0_a56 out nocopy  VARCHAR2
    , p0_a57 out nocopy  NUMBER
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  VARCHAR2
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  NUMBER
    , p0_a66 out nocopy  NUMBER
    , p0_a67 out nocopy  NUMBER
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  NUMBER
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  NUMBER
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  NUMBER
    , p0_a76 out nocopy  VARCHAR2
    , p0_a77 out nocopy  VARCHAR2
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  VARCHAR2
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  VARCHAR2
    , p0_a82 out nocopy  VARCHAR2
    , p0_a83 out nocopy  VARCHAR2
    , p0_a84 out nocopy  VARCHAR2
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  VARCHAR2
    , p0_a87 out nocopy  VARCHAR2
    , p0_a88 out nocopy  VARCHAR2
    , p0_a89 out nocopy  VARCHAR2
    , p0_a90 out nocopy  VARCHAR2
    , p0_a91 out nocopy  NUMBER
    , p0_a92 out nocopy  NUMBER
    , p0_a93 out nocopy  NUMBER
    , p0_a94 out nocopy  NUMBER
  )

  as
    ddx_sys_parameters_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_sys_parameters_pvt.init_sys_parameters_rec(ddx_sys_parameters_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_sys_parameters_rec.set_of_books_id;
    p0_a1 := ddx_sys_parameters_rec.object_version_number;
    p0_a2 := ddx_sys_parameters_rec.last_update_date;
    p0_a3 := ddx_sys_parameters_rec.last_updated_by;
    p0_a4 := ddx_sys_parameters_rec.creation_date;
    p0_a5 := ddx_sys_parameters_rec.created_by;
    p0_a6 := ddx_sys_parameters_rec.last_update_login;
    p0_a7 := ddx_sys_parameters_rec.request_id;
    p0_a8 := ddx_sys_parameters_rec.program_application_id;
    p0_a9 := ddx_sys_parameters_rec.program_update_date;
    p0_a10 := ddx_sys_parameters_rec.program_id;
    p0_a11 := ddx_sys_parameters_rec.created_from;
    p0_a12 := ddx_sys_parameters_rec.post_to_gl;
    p0_a13 := ddx_sys_parameters_rec.transfer_to_gl_in;
    p0_a14 := ddx_sys_parameters_rec.ap_payment_term_id;
    p0_a15 := ddx_sys_parameters_rec.rounding_level_flag;
    p0_a16 := ddx_sys_parameters_rec.gl_id_rounding;
    p0_a17 := ddx_sys_parameters_rec.gl_id_ded_clearing;
    p0_a18 := ddx_sys_parameters_rec.gl_id_ded_adj;
    p0_a19 := ddx_sys_parameters_rec.gl_id_accr_promo_liab;
    p0_a20 := ddx_sys_parameters_rec.gl_id_ded_adj_clearing;
    p0_a21 := ddx_sys_parameters_rec.gl_rec_ded_account;
    p0_a22 := ddx_sys_parameters_rec.gl_rec_clearing_account;
    p0_a23 := ddx_sys_parameters_rec.gl_cost_adjustment_acct;
    p0_a24 := ddx_sys_parameters_rec.gl_contra_liability_acct;
    p0_a25 := ddx_sys_parameters_rec.gl_pp_accrual_acct;
    p0_a26 := ddx_sys_parameters_rec.gl_date_type;
    p0_a27 := ddx_sys_parameters_rec.days_due;
    p0_a28 := ddx_sys_parameters_rec.claim_type_id;
    p0_a29 := ddx_sys_parameters_rec.reason_code_id;
    p0_a30 := ddx_sys_parameters_rec.autopay_claim_type_id;
    p0_a31 := ddx_sys_parameters_rec.autopay_reason_code_id;
    p0_a32 := ddx_sys_parameters_rec.autopay_flag;
    p0_a33 := ddx_sys_parameters_rec.autopay_periodicity;
    p0_a34 := ddx_sys_parameters_rec.autopay_periodicity_type;
    p0_a35 := ddx_sys_parameters_rec.accounting_method_option;
    p0_a36 := ddx_sys_parameters_rec.billback_trx_type_id;
    p0_a37 := ddx_sys_parameters_rec.cm_trx_type_id;
    p0_a38 := ddx_sys_parameters_rec.attribute_category;
    p0_a39 := ddx_sys_parameters_rec.attribute1;
    p0_a40 := ddx_sys_parameters_rec.attribute2;
    p0_a41 := ddx_sys_parameters_rec.attribute3;
    p0_a42 := ddx_sys_parameters_rec.attribute4;
    p0_a43 := ddx_sys_parameters_rec.attribute5;
    p0_a44 := ddx_sys_parameters_rec.attribute6;
    p0_a45 := ddx_sys_parameters_rec.attribute7;
    p0_a46 := ddx_sys_parameters_rec.attribute8;
    p0_a47 := ddx_sys_parameters_rec.attribute9;
    p0_a48 := ddx_sys_parameters_rec.attribute10;
    p0_a49 := ddx_sys_parameters_rec.attribute11;
    p0_a50 := ddx_sys_parameters_rec.attribute12;
    p0_a51 := ddx_sys_parameters_rec.attribute13;
    p0_a52 := ddx_sys_parameters_rec.attribute14;
    p0_a53 := ddx_sys_parameters_rec.attribute15;
    p0_a54 := ddx_sys_parameters_rec.org_id;
    p0_a55 := ddx_sys_parameters_rec.batch_source_id;
    p0_a56 := ddx_sys_parameters_rec.payables_source;
    p0_a57 := ddx_sys_parameters_rec.default_owner_id;
    p0_a58 := ddx_sys_parameters_rec.auto_assign_flag;
    p0_a59 := ddx_sys_parameters_rec.exchange_rate_type;
    p0_a60 := ddx_sys_parameters_rec.order_type_id;
    p0_a61 := ddx_sys_parameters_rec.gl_acct_for_offinv_flag;
    p0_a62 := ddx_sys_parameters_rec.cb_trx_type_id;
    p0_a63 := ddx_sys_parameters_rec.pos_write_off_threshold;
    p0_a64 := ddx_sys_parameters_rec.neg_write_off_threshold;
    p0_a65 := ddx_sys_parameters_rec.adj_rec_trx_id;
    p0_a66 := ddx_sys_parameters_rec.wo_rec_trx_id;
    p0_a67 := ddx_sys_parameters_rec.neg_wo_rec_trx_id;
    p0_a68 := ddx_sys_parameters_rec.un_earned_pay_allow_to;
    p0_a69 := ddx_sys_parameters_rec.un_earned_pay_thold_type;
    p0_a70 := ddx_sys_parameters_rec.un_earned_pay_threshold;
    p0_a71 := ddx_sys_parameters_rec.un_earned_pay_thold_flag;
    p0_a72 := ddx_sys_parameters_rec.header_tolerance_calc_code;
    p0_a73 := ddx_sys_parameters_rec.header_tolerance_operand;
    p0_a74 := ddx_sys_parameters_rec.line_tolerance_calc_code;
    p0_a75 := ddx_sys_parameters_rec.line_tolerance_operand;
    p0_a76 := ddx_sys_parameters_rec.ship_debit_accrual_flag;
    p0_a77 := ddx_sys_parameters_rec.ship_debit_calc_type;
    p0_a78 := ddx_sys_parameters_rec.inventory_tracking_flag;
    p0_a79 := ddx_sys_parameters_rec.end_cust_relation_flag;
    p0_a80 := ddx_sys_parameters_rec.auto_tp_accrual_flag;
    p0_a81 := ddx_sys_parameters_rec.gl_balancing_flex_value;
    p0_a82 := ddx_sys_parameters_rec.prorate_earnings_flag;
    p0_a83 := ddx_sys_parameters_rec.sales_credit_default_type;
    p0_a84 := ddx_sys_parameters_rec.net_amt_for_mass_settle_flag;
    p0_a85 := ddx_sys_parameters_rec.claim_tax_incl_flag;
    p0_a86 := ddx_sys_parameters_rec.rule_based;
    p0_a87 := ddx_sys_parameters_rec.approval_new_credit;
    p0_a88 := ddx_sys_parameters_rec.approval_matched_credit;
    p0_a89 := ddx_sys_parameters_rec.cust_name_match_type;
    p0_a90 := ddx_sys_parameters_rec.credit_matching_thold_type;
    p0_a91 := ddx_sys_parameters_rec.credit_tolerance_operand;
    p0_a92 := ddx_sys_parameters_rec.automate_notification_days;
    p0_a93 := ddx_sys_parameters_rec.ssd_inc_adj_type_id;
    p0_a94 := ddx_sys_parameters_rec.ssd_dec_adj_type_id;
  end;

  procedure complete_sys_parameters_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  VARCHAR2
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  NUMBER
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  VARCHAR2
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  DATE
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  NUMBER
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  NUMBER
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  VARCHAR2
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  VARCHAR2
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  NUMBER
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  VARCHAR2
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  NUMBER
    , p1_a67 out nocopy  NUMBER
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  NUMBER
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  NUMBER
    , p1_a76 out nocopy  VARCHAR2
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  VARCHAR2
    , p1_a82 out nocopy  VARCHAR2
    , p1_a83 out nocopy  VARCHAR2
    , p1_a84 out nocopy  VARCHAR2
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  VARCHAR2
    , p1_a87 out nocopy  VARCHAR2
    , p1_a88 out nocopy  VARCHAR2
    , p1_a89 out nocopy  VARCHAR2
    , p1_a90 out nocopy  VARCHAR2
    , p1_a91 out nocopy  NUMBER
    , p1_a92 out nocopy  NUMBER
    , p1_a93 out nocopy  NUMBER
    , p1_a94 out nocopy  NUMBER
  )

  as
    ddp_sys_parameters_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddx_complete_rec ozf_sys_parameters_pvt.sys_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_sys_parameters_rec.set_of_books_id := p0_a0;
    ddp_sys_parameters_rec.object_version_number := p0_a1;
    ddp_sys_parameters_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_sys_parameters_rec.last_updated_by := p0_a3;
    ddp_sys_parameters_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_sys_parameters_rec.created_by := p0_a5;
    ddp_sys_parameters_rec.last_update_login := p0_a6;
    ddp_sys_parameters_rec.request_id := p0_a7;
    ddp_sys_parameters_rec.program_application_id := p0_a8;
    ddp_sys_parameters_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_sys_parameters_rec.program_id := p0_a10;
    ddp_sys_parameters_rec.created_from := p0_a11;
    ddp_sys_parameters_rec.post_to_gl := p0_a12;
    ddp_sys_parameters_rec.transfer_to_gl_in := p0_a13;
    ddp_sys_parameters_rec.ap_payment_term_id := p0_a14;
    ddp_sys_parameters_rec.rounding_level_flag := p0_a15;
    ddp_sys_parameters_rec.gl_id_rounding := p0_a16;
    ddp_sys_parameters_rec.gl_id_ded_clearing := p0_a17;
    ddp_sys_parameters_rec.gl_id_ded_adj := p0_a18;
    ddp_sys_parameters_rec.gl_id_accr_promo_liab := p0_a19;
    ddp_sys_parameters_rec.gl_id_ded_adj_clearing := p0_a20;
    ddp_sys_parameters_rec.gl_rec_ded_account := p0_a21;
    ddp_sys_parameters_rec.gl_rec_clearing_account := p0_a22;
    ddp_sys_parameters_rec.gl_cost_adjustment_acct := p0_a23;
    ddp_sys_parameters_rec.gl_contra_liability_acct := p0_a24;
    ddp_sys_parameters_rec.gl_pp_accrual_acct := p0_a25;
    ddp_sys_parameters_rec.gl_date_type := p0_a26;
    ddp_sys_parameters_rec.days_due := p0_a27;
    ddp_sys_parameters_rec.claim_type_id := p0_a28;
    ddp_sys_parameters_rec.reason_code_id := p0_a29;
    ddp_sys_parameters_rec.autopay_claim_type_id := p0_a30;
    ddp_sys_parameters_rec.autopay_reason_code_id := p0_a31;
    ddp_sys_parameters_rec.autopay_flag := p0_a32;
    ddp_sys_parameters_rec.autopay_periodicity := p0_a33;
    ddp_sys_parameters_rec.autopay_periodicity_type := p0_a34;
    ddp_sys_parameters_rec.accounting_method_option := p0_a35;
    ddp_sys_parameters_rec.billback_trx_type_id := p0_a36;
    ddp_sys_parameters_rec.cm_trx_type_id := p0_a37;
    ddp_sys_parameters_rec.attribute_category := p0_a38;
    ddp_sys_parameters_rec.attribute1 := p0_a39;
    ddp_sys_parameters_rec.attribute2 := p0_a40;
    ddp_sys_parameters_rec.attribute3 := p0_a41;
    ddp_sys_parameters_rec.attribute4 := p0_a42;
    ddp_sys_parameters_rec.attribute5 := p0_a43;
    ddp_sys_parameters_rec.attribute6 := p0_a44;
    ddp_sys_parameters_rec.attribute7 := p0_a45;
    ddp_sys_parameters_rec.attribute8 := p0_a46;
    ddp_sys_parameters_rec.attribute9 := p0_a47;
    ddp_sys_parameters_rec.attribute10 := p0_a48;
    ddp_sys_parameters_rec.attribute11 := p0_a49;
    ddp_sys_parameters_rec.attribute12 := p0_a50;
    ddp_sys_parameters_rec.attribute13 := p0_a51;
    ddp_sys_parameters_rec.attribute14 := p0_a52;
    ddp_sys_parameters_rec.attribute15 := p0_a53;
    ddp_sys_parameters_rec.org_id := p0_a54;
    ddp_sys_parameters_rec.batch_source_id := p0_a55;
    ddp_sys_parameters_rec.payables_source := p0_a56;
    ddp_sys_parameters_rec.default_owner_id := p0_a57;
    ddp_sys_parameters_rec.auto_assign_flag := p0_a58;
    ddp_sys_parameters_rec.exchange_rate_type := p0_a59;
    ddp_sys_parameters_rec.order_type_id := p0_a60;
    ddp_sys_parameters_rec.gl_acct_for_offinv_flag := p0_a61;
    ddp_sys_parameters_rec.cb_trx_type_id := p0_a62;
    ddp_sys_parameters_rec.pos_write_off_threshold := p0_a63;
    ddp_sys_parameters_rec.neg_write_off_threshold := p0_a64;
    ddp_sys_parameters_rec.adj_rec_trx_id := p0_a65;
    ddp_sys_parameters_rec.wo_rec_trx_id := p0_a66;
    ddp_sys_parameters_rec.neg_wo_rec_trx_id := p0_a67;
    ddp_sys_parameters_rec.un_earned_pay_allow_to := p0_a68;
    ddp_sys_parameters_rec.un_earned_pay_thold_type := p0_a69;
    ddp_sys_parameters_rec.un_earned_pay_threshold := p0_a70;
    ddp_sys_parameters_rec.un_earned_pay_thold_flag := p0_a71;
    ddp_sys_parameters_rec.header_tolerance_calc_code := p0_a72;
    ddp_sys_parameters_rec.header_tolerance_operand := p0_a73;
    ddp_sys_parameters_rec.line_tolerance_calc_code := p0_a74;
    ddp_sys_parameters_rec.line_tolerance_operand := p0_a75;
    ddp_sys_parameters_rec.ship_debit_accrual_flag := p0_a76;
    ddp_sys_parameters_rec.ship_debit_calc_type := p0_a77;
    ddp_sys_parameters_rec.inventory_tracking_flag := p0_a78;
    ddp_sys_parameters_rec.end_cust_relation_flag := p0_a79;
    ddp_sys_parameters_rec.auto_tp_accrual_flag := p0_a80;
    ddp_sys_parameters_rec.gl_balancing_flex_value := p0_a81;
    ddp_sys_parameters_rec.prorate_earnings_flag := p0_a82;
    ddp_sys_parameters_rec.sales_credit_default_type := p0_a83;
    ddp_sys_parameters_rec.net_amt_for_mass_settle_flag := p0_a84;
    ddp_sys_parameters_rec.claim_tax_incl_flag := p0_a85;
    ddp_sys_parameters_rec.rule_based := p0_a86;
    ddp_sys_parameters_rec.approval_new_credit := p0_a87;
    ddp_sys_parameters_rec.approval_matched_credit := p0_a88;
    ddp_sys_parameters_rec.cust_name_match_type := p0_a89;
    ddp_sys_parameters_rec.credit_matching_thold_type := p0_a90;
    ddp_sys_parameters_rec.credit_tolerance_operand := p0_a91;
    ddp_sys_parameters_rec.automate_notification_days := p0_a92;
    ddp_sys_parameters_rec.ssd_inc_adj_type_id := p0_a93;
    ddp_sys_parameters_rec.ssd_dec_adj_type_id := p0_a94;


    -- here's the delegated call to the old PL/SQL routine
    ozf_sys_parameters_pvt.complete_sys_parameters_rec(ddp_sys_parameters_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.set_of_books_id;
    p1_a1 := ddx_complete_rec.object_version_number;
    p1_a2 := ddx_complete_rec.last_update_date;
    p1_a3 := ddx_complete_rec.last_updated_by;
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := ddx_complete_rec.created_by;
    p1_a6 := ddx_complete_rec.last_update_login;
    p1_a7 := ddx_complete_rec.request_id;
    p1_a8 := ddx_complete_rec.program_application_id;
    p1_a9 := ddx_complete_rec.program_update_date;
    p1_a10 := ddx_complete_rec.program_id;
    p1_a11 := ddx_complete_rec.created_from;
    p1_a12 := ddx_complete_rec.post_to_gl;
    p1_a13 := ddx_complete_rec.transfer_to_gl_in;
    p1_a14 := ddx_complete_rec.ap_payment_term_id;
    p1_a15 := ddx_complete_rec.rounding_level_flag;
    p1_a16 := ddx_complete_rec.gl_id_rounding;
    p1_a17 := ddx_complete_rec.gl_id_ded_clearing;
    p1_a18 := ddx_complete_rec.gl_id_ded_adj;
    p1_a19 := ddx_complete_rec.gl_id_accr_promo_liab;
    p1_a20 := ddx_complete_rec.gl_id_ded_adj_clearing;
    p1_a21 := ddx_complete_rec.gl_rec_ded_account;
    p1_a22 := ddx_complete_rec.gl_rec_clearing_account;
    p1_a23 := ddx_complete_rec.gl_cost_adjustment_acct;
    p1_a24 := ddx_complete_rec.gl_contra_liability_acct;
    p1_a25 := ddx_complete_rec.gl_pp_accrual_acct;
    p1_a26 := ddx_complete_rec.gl_date_type;
    p1_a27 := ddx_complete_rec.days_due;
    p1_a28 := ddx_complete_rec.claim_type_id;
    p1_a29 := ddx_complete_rec.reason_code_id;
    p1_a30 := ddx_complete_rec.autopay_claim_type_id;
    p1_a31 := ddx_complete_rec.autopay_reason_code_id;
    p1_a32 := ddx_complete_rec.autopay_flag;
    p1_a33 := ddx_complete_rec.autopay_periodicity;
    p1_a34 := ddx_complete_rec.autopay_periodicity_type;
    p1_a35 := ddx_complete_rec.accounting_method_option;
    p1_a36 := ddx_complete_rec.billback_trx_type_id;
    p1_a37 := ddx_complete_rec.cm_trx_type_id;
    p1_a38 := ddx_complete_rec.attribute_category;
    p1_a39 := ddx_complete_rec.attribute1;
    p1_a40 := ddx_complete_rec.attribute2;
    p1_a41 := ddx_complete_rec.attribute3;
    p1_a42 := ddx_complete_rec.attribute4;
    p1_a43 := ddx_complete_rec.attribute5;
    p1_a44 := ddx_complete_rec.attribute6;
    p1_a45 := ddx_complete_rec.attribute7;
    p1_a46 := ddx_complete_rec.attribute8;
    p1_a47 := ddx_complete_rec.attribute9;
    p1_a48 := ddx_complete_rec.attribute10;
    p1_a49 := ddx_complete_rec.attribute11;
    p1_a50 := ddx_complete_rec.attribute12;
    p1_a51 := ddx_complete_rec.attribute13;
    p1_a52 := ddx_complete_rec.attribute14;
    p1_a53 := ddx_complete_rec.attribute15;
    p1_a54 := ddx_complete_rec.org_id;
    p1_a55 := ddx_complete_rec.batch_source_id;
    p1_a56 := ddx_complete_rec.payables_source;
    p1_a57 := ddx_complete_rec.default_owner_id;
    p1_a58 := ddx_complete_rec.auto_assign_flag;
    p1_a59 := ddx_complete_rec.exchange_rate_type;
    p1_a60 := ddx_complete_rec.order_type_id;
    p1_a61 := ddx_complete_rec.gl_acct_for_offinv_flag;
    p1_a62 := ddx_complete_rec.cb_trx_type_id;
    p1_a63 := ddx_complete_rec.pos_write_off_threshold;
    p1_a64 := ddx_complete_rec.neg_write_off_threshold;
    p1_a65 := ddx_complete_rec.adj_rec_trx_id;
    p1_a66 := ddx_complete_rec.wo_rec_trx_id;
    p1_a67 := ddx_complete_rec.neg_wo_rec_trx_id;
    p1_a68 := ddx_complete_rec.un_earned_pay_allow_to;
    p1_a69 := ddx_complete_rec.un_earned_pay_thold_type;
    p1_a70 := ddx_complete_rec.un_earned_pay_threshold;
    p1_a71 := ddx_complete_rec.un_earned_pay_thold_flag;
    p1_a72 := ddx_complete_rec.header_tolerance_calc_code;
    p1_a73 := ddx_complete_rec.header_tolerance_operand;
    p1_a74 := ddx_complete_rec.line_tolerance_calc_code;
    p1_a75 := ddx_complete_rec.line_tolerance_operand;
    p1_a76 := ddx_complete_rec.ship_debit_accrual_flag;
    p1_a77 := ddx_complete_rec.ship_debit_calc_type;
    p1_a78 := ddx_complete_rec.inventory_tracking_flag;
    p1_a79 := ddx_complete_rec.end_cust_relation_flag;
    p1_a80 := ddx_complete_rec.auto_tp_accrual_flag;
    p1_a81 := ddx_complete_rec.gl_balancing_flex_value;
    p1_a82 := ddx_complete_rec.prorate_earnings_flag;
    p1_a83 := ddx_complete_rec.sales_credit_default_type;
    p1_a84 := ddx_complete_rec.net_amt_for_mass_settle_flag;
    p1_a85 := ddx_complete_rec.claim_tax_incl_flag;
    p1_a86 := ddx_complete_rec.rule_based;
    p1_a87 := ddx_complete_rec.approval_new_credit;
    p1_a88 := ddx_complete_rec.approval_matched_credit;
    p1_a89 := ddx_complete_rec.cust_name_match_type;
    p1_a90 := ddx_complete_rec.credit_matching_thold_type;
    p1_a91 := ddx_complete_rec.credit_tolerance_operand;
    p1_a92 := ddx_complete_rec.automate_notification_days;
    p1_a93 := ddx_complete_rec.ssd_inc_adj_type_id;
    p1_a94 := ddx_complete_rec.ssd_dec_adj_type_id;
  end;

end ozf_sys_parameters_pvt_w;

/
