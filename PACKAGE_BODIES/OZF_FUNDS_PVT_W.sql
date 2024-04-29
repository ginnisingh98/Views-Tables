--------------------------------------------------------
--  DDL for Package Body OZF_FUNDS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUNDS_PVT_W" as
  /* $Header: ozfwfunb.pls 120.3 2008/06/11 06:07:12 kdass ship $ */
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

  procedure create_fund(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
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
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  DATE
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  NUMBER
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  NUMBER
    , p7_a109  NUMBER
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  NUMBER
    , p7_a115  NUMBER
    , p7_a116  NUMBER
    , p7_a117  DATE
    , p7_a118  NUMBER
    , x_fund_id out nocopy  NUMBER
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_fund_rec.fund_id := p7_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_fund_rec.last_updated_by := p7_a2;
    ddp_fund_rec.last_update_login := p7_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_fund_rec.created_by := p7_a5;
    ddp_fund_rec.created_from := p7_a6;
    ddp_fund_rec.request_id := p7_a7;
    ddp_fund_rec.program_application_id := p7_a8;
    ddp_fund_rec.program_id := p7_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_fund_rec.fund_number := p7_a11;
    ddp_fund_rec.parent_fund_id := p7_a12;
    ddp_fund_rec.category_id := p7_a13;
    ddp_fund_rec.fund_type := p7_a14;
    ddp_fund_rec.status_code := p7_a15;
    ddp_fund_rec.user_status_id := p7_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_fund_rec.accrued_liable_account := p7_a18;
    ddp_fund_rec.ded_adjustment_account := p7_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a21);
    ddp_fund_rec.currency_code_tc := p7_a22;
    ddp_fund_rec.owner := p7_a23;
    ddp_fund_rec.hierarchy := p7_a24;
    ddp_fund_rec.hierarchy_level := p7_a25;
    ddp_fund_rec.hierarchy_id := p7_a26;
    ddp_fund_rec.parent_node_id := p7_a27;
    ddp_fund_rec.node_id := p7_a28;
    ddp_fund_rec.object_version_number := p7_a29;
    ddp_fund_rec.org_id := p7_a30;
    ddp_fund_rec.earned_flag := p7_a31;
    ddp_fund_rec.original_budget := p7_a32;
    ddp_fund_rec.transfered_in_amt := p7_a33;
    ddp_fund_rec.transfered_out_amt := p7_a34;
    ddp_fund_rec.holdback_amt := p7_a35;
    ddp_fund_rec.planned_amt := p7_a36;
    ddp_fund_rec.committed_amt := p7_a37;
    ddp_fund_rec.earned_amt := p7_a38;
    ddp_fund_rec.paid_amt := p7_a39;
    ddp_fund_rec.liable_accnt_segments := p7_a40;
    ddp_fund_rec.adjustment_accnt_segments := p7_a41;
    ddp_fund_rec.short_name := p7_a42;
    ddp_fund_rec.description := p7_a43;
    ddp_fund_rec.language := p7_a44;
    ddp_fund_rec.source_lang := p7_a45;
    ddp_fund_rec.start_period_name := p7_a46;
    ddp_fund_rec.end_period_name := p7_a47;
    ddp_fund_rec.fund_calendar := p7_a48;
    ddp_fund_rec.accrue_to_level_id := p7_a49;
    ddp_fund_rec.accrual_quantity := p7_a50;
    ddp_fund_rec.accrual_phase := p7_a51;
    ddp_fund_rec.accrual_cap := p7_a52;
    ddp_fund_rec.accrual_uom := p7_a53;
    ddp_fund_rec.accrual_method := p7_a54;
    ddp_fund_rec.accrual_operand := p7_a55;
    ddp_fund_rec.accrual_rate := p7_a56;
    ddp_fund_rec.accrual_basis := p7_a57;
    ddp_fund_rec.accrual_discount_level := p7_a58;
    ddp_fund_rec.custom_setup_id := p7_a59;
    ddp_fund_rec.threshold_id := p7_a60;
    ddp_fund_rec.business_unit_id := p7_a61;
    ddp_fund_rec.country_id := p7_a62;
    ddp_fund_rec.task_id := p7_a63;
    ddp_fund_rec.recal_committed := p7_a64;
    ddp_fund_rec.attribute_category := p7_a65;
    ddp_fund_rec.attribute1 := p7_a66;
    ddp_fund_rec.attribute2 := p7_a67;
    ddp_fund_rec.attribute3 := p7_a68;
    ddp_fund_rec.attribute4 := p7_a69;
    ddp_fund_rec.attribute5 := p7_a70;
    ddp_fund_rec.attribute6 := p7_a71;
    ddp_fund_rec.attribute7 := p7_a72;
    ddp_fund_rec.attribute8 := p7_a73;
    ddp_fund_rec.attribute9 := p7_a74;
    ddp_fund_rec.attribute10 := p7_a75;
    ddp_fund_rec.attribute11 := p7_a76;
    ddp_fund_rec.attribute12 := p7_a77;
    ddp_fund_rec.attribute13 := p7_a78;
    ddp_fund_rec.attribute14 := p7_a79;
    ddp_fund_rec.attribute15 := p7_a80;
    ddp_fund_rec.fund_usage := p7_a81;
    ddp_fund_rec.plan_type := p7_a82;
    ddp_fund_rec.plan_id := p7_a83;
    ddp_fund_rec.apply_accrual_on := p7_a84;
    ddp_fund_rec.level_value := p7_a85;
    ddp_fund_rec.budget_flag := p7_a86;
    ddp_fund_rec.liability_flag := p7_a87;
    ddp_fund_rec.set_of_books_id := p7_a88;
    ddp_fund_rec.start_period_id := p7_a89;
    ddp_fund_rec.end_period_id := p7_a90;
    ddp_fund_rec.budget_amount_tc := p7_a91;
    ddp_fund_rec.budget_amount_fc := p7_a92;
    ddp_fund_rec.available_amount := p7_a93;
    ddp_fund_rec.distributed_amount := p7_a94;
    ddp_fund_rec.currency_code_fc := p7_a95;
    ddp_fund_rec.exchange_rate_type := p7_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a97);
    ddp_fund_rec.exchange_rate := p7_a98;
    ddp_fund_rec.department_id := p7_a99;
    ddp_fund_rec.costcentre_id := p7_a100;
    ddp_fund_rec.rollup_original_budget := p7_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p7_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p7_a103;
    ddp_fund_rec.rollup_holdback_amt := p7_a104;
    ddp_fund_rec.rollup_planned_amt := p7_a105;
    ddp_fund_rec.rollup_committed_amt := p7_a106;
    ddp_fund_rec.rollup_earned_amt := p7_a107;
    ddp_fund_rec.rollup_paid_amt := p7_a108;
    ddp_fund_rec.rollup_recal_committed := p7_a109;
    ddp_fund_rec.retroactive_flag := p7_a110;
    ddp_fund_rec.qualifier_id := p7_a111;
    ddp_fund_rec.prev_fund_id := p7_a112;
    ddp_fund_rec.transfered_flag := p7_a113;
    ddp_fund_rec.utilized_amt := p7_a114;
    ddp_fund_rec.rollup_utilized_amt := p7_a115;
    ddp_fund_rec.product_spread_time_id := p7_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p7_a117);
    ddp_fund_rec.ledger_id := p7_a118;


    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.create_fund(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fund_rec,
      x_fund_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_fund(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
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
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  DATE
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  NUMBER
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  NUMBER
    , p7_a109  NUMBER
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  NUMBER
    , p7_a115  NUMBER
    , p7_a116  NUMBER
    , p7_a117  DATE
    , p7_a118  NUMBER
    , p_mode  VARCHAR2
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_fund_rec.fund_id := p7_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_fund_rec.last_updated_by := p7_a2;
    ddp_fund_rec.last_update_login := p7_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_fund_rec.created_by := p7_a5;
    ddp_fund_rec.created_from := p7_a6;
    ddp_fund_rec.request_id := p7_a7;
    ddp_fund_rec.program_application_id := p7_a8;
    ddp_fund_rec.program_id := p7_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_fund_rec.fund_number := p7_a11;
    ddp_fund_rec.parent_fund_id := p7_a12;
    ddp_fund_rec.category_id := p7_a13;
    ddp_fund_rec.fund_type := p7_a14;
    ddp_fund_rec.status_code := p7_a15;
    ddp_fund_rec.user_status_id := p7_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_fund_rec.accrued_liable_account := p7_a18;
    ddp_fund_rec.ded_adjustment_account := p7_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a21);
    ddp_fund_rec.currency_code_tc := p7_a22;
    ddp_fund_rec.owner := p7_a23;
    ddp_fund_rec.hierarchy := p7_a24;
    ddp_fund_rec.hierarchy_level := p7_a25;
    ddp_fund_rec.hierarchy_id := p7_a26;
    ddp_fund_rec.parent_node_id := p7_a27;
    ddp_fund_rec.node_id := p7_a28;
    ddp_fund_rec.object_version_number := p7_a29;
    ddp_fund_rec.org_id := p7_a30;
    ddp_fund_rec.earned_flag := p7_a31;
    ddp_fund_rec.original_budget := p7_a32;
    ddp_fund_rec.transfered_in_amt := p7_a33;
    ddp_fund_rec.transfered_out_amt := p7_a34;
    ddp_fund_rec.holdback_amt := p7_a35;
    ddp_fund_rec.planned_amt := p7_a36;
    ddp_fund_rec.committed_amt := p7_a37;
    ddp_fund_rec.earned_amt := p7_a38;
    ddp_fund_rec.paid_amt := p7_a39;
    ddp_fund_rec.liable_accnt_segments := p7_a40;
    ddp_fund_rec.adjustment_accnt_segments := p7_a41;
    ddp_fund_rec.short_name := p7_a42;
    ddp_fund_rec.description := p7_a43;
    ddp_fund_rec.language := p7_a44;
    ddp_fund_rec.source_lang := p7_a45;
    ddp_fund_rec.start_period_name := p7_a46;
    ddp_fund_rec.end_period_name := p7_a47;
    ddp_fund_rec.fund_calendar := p7_a48;
    ddp_fund_rec.accrue_to_level_id := p7_a49;
    ddp_fund_rec.accrual_quantity := p7_a50;
    ddp_fund_rec.accrual_phase := p7_a51;
    ddp_fund_rec.accrual_cap := p7_a52;
    ddp_fund_rec.accrual_uom := p7_a53;
    ddp_fund_rec.accrual_method := p7_a54;
    ddp_fund_rec.accrual_operand := p7_a55;
    ddp_fund_rec.accrual_rate := p7_a56;
    ddp_fund_rec.accrual_basis := p7_a57;
    ddp_fund_rec.accrual_discount_level := p7_a58;
    ddp_fund_rec.custom_setup_id := p7_a59;
    ddp_fund_rec.threshold_id := p7_a60;
    ddp_fund_rec.business_unit_id := p7_a61;
    ddp_fund_rec.country_id := p7_a62;
    ddp_fund_rec.task_id := p7_a63;
    ddp_fund_rec.recal_committed := p7_a64;
    ddp_fund_rec.attribute_category := p7_a65;
    ddp_fund_rec.attribute1 := p7_a66;
    ddp_fund_rec.attribute2 := p7_a67;
    ddp_fund_rec.attribute3 := p7_a68;
    ddp_fund_rec.attribute4 := p7_a69;
    ddp_fund_rec.attribute5 := p7_a70;
    ddp_fund_rec.attribute6 := p7_a71;
    ddp_fund_rec.attribute7 := p7_a72;
    ddp_fund_rec.attribute8 := p7_a73;
    ddp_fund_rec.attribute9 := p7_a74;
    ddp_fund_rec.attribute10 := p7_a75;
    ddp_fund_rec.attribute11 := p7_a76;
    ddp_fund_rec.attribute12 := p7_a77;
    ddp_fund_rec.attribute13 := p7_a78;
    ddp_fund_rec.attribute14 := p7_a79;
    ddp_fund_rec.attribute15 := p7_a80;
    ddp_fund_rec.fund_usage := p7_a81;
    ddp_fund_rec.plan_type := p7_a82;
    ddp_fund_rec.plan_id := p7_a83;
    ddp_fund_rec.apply_accrual_on := p7_a84;
    ddp_fund_rec.level_value := p7_a85;
    ddp_fund_rec.budget_flag := p7_a86;
    ddp_fund_rec.liability_flag := p7_a87;
    ddp_fund_rec.set_of_books_id := p7_a88;
    ddp_fund_rec.start_period_id := p7_a89;
    ddp_fund_rec.end_period_id := p7_a90;
    ddp_fund_rec.budget_amount_tc := p7_a91;
    ddp_fund_rec.budget_amount_fc := p7_a92;
    ddp_fund_rec.available_amount := p7_a93;
    ddp_fund_rec.distributed_amount := p7_a94;
    ddp_fund_rec.currency_code_fc := p7_a95;
    ddp_fund_rec.exchange_rate_type := p7_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a97);
    ddp_fund_rec.exchange_rate := p7_a98;
    ddp_fund_rec.department_id := p7_a99;
    ddp_fund_rec.costcentre_id := p7_a100;
    ddp_fund_rec.rollup_original_budget := p7_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p7_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p7_a103;
    ddp_fund_rec.rollup_holdback_amt := p7_a104;
    ddp_fund_rec.rollup_planned_amt := p7_a105;
    ddp_fund_rec.rollup_committed_amt := p7_a106;
    ddp_fund_rec.rollup_earned_amt := p7_a107;
    ddp_fund_rec.rollup_paid_amt := p7_a108;
    ddp_fund_rec.rollup_recal_committed := p7_a109;
    ddp_fund_rec.retroactive_flag := p7_a110;
    ddp_fund_rec.qualifier_id := p7_a111;
    ddp_fund_rec.prev_fund_id := p7_a112;
    ddp_fund_rec.transfered_flag := p7_a113;
    ddp_fund_rec.utilized_amt := p7_a114;
    ddp_fund_rec.rollup_utilized_amt := p7_a115;
    ddp_fund_rec.product_spread_time_id := p7_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p7_a117);
    ddp_fund_rec.ledger_id := p7_a118;


    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.update_fund(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fund_rec,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_fund(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  VARCHAR2
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  DATE
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  DATE
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  DATE
    , p6_a21  DATE
    , p6_a22  VARCHAR2
    , p6_a23  NUMBER
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  VARCHAR2
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  VARCHAR2
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  NUMBER
    , p6_a60  NUMBER
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  VARCHAR2
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  VARCHAR2
    , p6_a74  VARCHAR2
    , p6_a75  VARCHAR2
    , p6_a76  VARCHAR2
    , p6_a77  VARCHAR2
    , p6_a78  VARCHAR2
    , p6_a79  VARCHAR2
    , p6_a80  VARCHAR2
    , p6_a81  VARCHAR2
    , p6_a82  VARCHAR2
    , p6_a83  NUMBER
    , p6_a84  VARCHAR2
    , p6_a85  VARCHAR2
    , p6_a86  VARCHAR2
    , p6_a87  VARCHAR2
    , p6_a88  NUMBER
    , p6_a89  NUMBER
    , p6_a90  NUMBER
    , p6_a91  NUMBER
    , p6_a92  NUMBER
    , p6_a93  NUMBER
    , p6_a94  NUMBER
    , p6_a95  VARCHAR2
    , p6_a96  VARCHAR2
    , p6_a97  DATE
    , p6_a98  NUMBER
    , p6_a99  NUMBER
    , p6_a100  NUMBER
    , p6_a101  NUMBER
    , p6_a102  NUMBER
    , p6_a103  NUMBER
    , p6_a104  NUMBER
    , p6_a105  NUMBER
    , p6_a106  NUMBER
    , p6_a107  NUMBER
    , p6_a108  NUMBER
    , p6_a109  NUMBER
    , p6_a110  VARCHAR2
    , p6_a111  NUMBER
    , p6_a112  NUMBER
    , p6_a113  VARCHAR2
    , p6_a114  NUMBER
    , p6_a115  NUMBER
    , p6_a116  NUMBER
    , p6_a117  DATE
    , p6_a118  NUMBER
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_fund_rec.fund_id := p6_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_fund_rec.last_updated_by := p6_a2;
    ddp_fund_rec.last_update_login := p6_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_fund_rec.created_by := p6_a5;
    ddp_fund_rec.created_from := p6_a6;
    ddp_fund_rec.request_id := p6_a7;
    ddp_fund_rec.program_application_id := p6_a8;
    ddp_fund_rec.program_id := p6_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_fund_rec.fund_number := p6_a11;
    ddp_fund_rec.parent_fund_id := p6_a12;
    ddp_fund_rec.category_id := p6_a13;
    ddp_fund_rec.fund_type := p6_a14;
    ddp_fund_rec.status_code := p6_a15;
    ddp_fund_rec.user_status_id := p6_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p6_a17);
    ddp_fund_rec.accrued_liable_account := p6_a18;
    ddp_fund_rec.ded_adjustment_account := p6_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p6_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p6_a21);
    ddp_fund_rec.currency_code_tc := p6_a22;
    ddp_fund_rec.owner := p6_a23;
    ddp_fund_rec.hierarchy := p6_a24;
    ddp_fund_rec.hierarchy_level := p6_a25;
    ddp_fund_rec.hierarchy_id := p6_a26;
    ddp_fund_rec.parent_node_id := p6_a27;
    ddp_fund_rec.node_id := p6_a28;
    ddp_fund_rec.object_version_number := p6_a29;
    ddp_fund_rec.org_id := p6_a30;
    ddp_fund_rec.earned_flag := p6_a31;
    ddp_fund_rec.original_budget := p6_a32;
    ddp_fund_rec.transfered_in_amt := p6_a33;
    ddp_fund_rec.transfered_out_amt := p6_a34;
    ddp_fund_rec.holdback_amt := p6_a35;
    ddp_fund_rec.planned_amt := p6_a36;
    ddp_fund_rec.committed_amt := p6_a37;
    ddp_fund_rec.earned_amt := p6_a38;
    ddp_fund_rec.paid_amt := p6_a39;
    ddp_fund_rec.liable_accnt_segments := p6_a40;
    ddp_fund_rec.adjustment_accnt_segments := p6_a41;
    ddp_fund_rec.short_name := p6_a42;
    ddp_fund_rec.description := p6_a43;
    ddp_fund_rec.language := p6_a44;
    ddp_fund_rec.source_lang := p6_a45;
    ddp_fund_rec.start_period_name := p6_a46;
    ddp_fund_rec.end_period_name := p6_a47;
    ddp_fund_rec.fund_calendar := p6_a48;
    ddp_fund_rec.accrue_to_level_id := p6_a49;
    ddp_fund_rec.accrual_quantity := p6_a50;
    ddp_fund_rec.accrual_phase := p6_a51;
    ddp_fund_rec.accrual_cap := p6_a52;
    ddp_fund_rec.accrual_uom := p6_a53;
    ddp_fund_rec.accrual_method := p6_a54;
    ddp_fund_rec.accrual_operand := p6_a55;
    ddp_fund_rec.accrual_rate := p6_a56;
    ddp_fund_rec.accrual_basis := p6_a57;
    ddp_fund_rec.accrual_discount_level := p6_a58;
    ddp_fund_rec.custom_setup_id := p6_a59;
    ddp_fund_rec.threshold_id := p6_a60;
    ddp_fund_rec.business_unit_id := p6_a61;
    ddp_fund_rec.country_id := p6_a62;
    ddp_fund_rec.task_id := p6_a63;
    ddp_fund_rec.recal_committed := p6_a64;
    ddp_fund_rec.attribute_category := p6_a65;
    ddp_fund_rec.attribute1 := p6_a66;
    ddp_fund_rec.attribute2 := p6_a67;
    ddp_fund_rec.attribute3 := p6_a68;
    ddp_fund_rec.attribute4 := p6_a69;
    ddp_fund_rec.attribute5 := p6_a70;
    ddp_fund_rec.attribute6 := p6_a71;
    ddp_fund_rec.attribute7 := p6_a72;
    ddp_fund_rec.attribute8 := p6_a73;
    ddp_fund_rec.attribute9 := p6_a74;
    ddp_fund_rec.attribute10 := p6_a75;
    ddp_fund_rec.attribute11 := p6_a76;
    ddp_fund_rec.attribute12 := p6_a77;
    ddp_fund_rec.attribute13 := p6_a78;
    ddp_fund_rec.attribute14 := p6_a79;
    ddp_fund_rec.attribute15 := p6_a80;
    ddp_fund_rec.fund_usage := p6_a81;
    ddp_fund_rec.plan_type := p6_a82;
    ddp_fund_rec.plan_id := p6_a83;
    ddp_fund_rec.apply_accrual_on := p6_a84;
    ddp_fund_rec.level_value := p6_a85;
    ddp_fund_rec.budget_flag := p6_a86;
    ddp_fund_rec.liability_flag := p6_a87;
    ddp_fund_rec.set_of_books_id := p6_a88;
    ddp_fund_rec.start_period_id := p6_a89;
    ddp_fund_rec.end_period_id := p6_a90;
    ddp_fund_rec.budget_amount_tc := p6_a91;
    ddp_fund_rec.budget_amount_fc := p6_a92;
    ddp_fund_rec.available_amount := p6_a93;
    ddp_fund_rec.distributed_amount := p6_a94;
    ddp_fund_rec.currency_code_fc := p6_a95;
    ddp_fund_rec.exchange_rate_type := p6_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p6_a97);
    ddp_fund_rec.exchange_rate := p6_a98;
    ddp_fund_rec.department_id := p6_a99;
    ddp_fund_rec.costcentre_id := p6_a100;
    ddp_fund_rec.rollup_original_budget := p6_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p6_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p6_a103;
    ddp_fund_rec.rollup_holdback_amt := p6_a104;
    ddp_fund_rec.rollup_planned_amt := p6_a105;
    ddp_fund_rec.rollup_committed_amt := p6_a106;
    ddp_fund_rec.rollup_earned_amt := p6_a107;
    ddp_fund_rec.rollup_paid_amt := p6_a108;
    ddp_fund_rec.rollup_recal_committed := p6_a109;
    ddp_fund_rec.retroactive_flag := p6_a110;
    ddp_fund_rec.qualifier_id := p6_a111;
    ddp_fund_rec.prev_fund_id := p6_a112;
    ddp_fund_rec.transfered_flag := p6_a113;
    ddp_fund_rec.utilized_amt := p6_a114;
    ddp_fund_rec.rollup_utilized_amt := p6_a115;
    ddp_fund_rec.product_spread_time_id := p6_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p6_a117);
    ddp_fund_rec.ledger_id := p6_a118;

    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.validate_fund(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fund_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_fund_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  DATE
    , p2_a5  NUMBER
    , p2_a6  VARCHAR2
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  DATE
    , p2_a11  VARCHAR2
    , p2_a12  NUMBER
    , p2_a13  NUMBER
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  NUMBER
    , p2_a17  DATE
    , p2_a18  NUMBER
    , p2_a19  NUMBER
    , p2_a20  DATE
    , p2_a21  DATE
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  NUMBER
    , p2_a27  NUMBER
    , p2_a28  NUMBER
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  VARCHAR2
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  NUMBER
    , p2_a35  NUMBER
    , p2_a36  NUMBER
    , p2_a37  NUMBER
    , p2_a38  NUMBER
    , p2_a39  NUMBER
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  NUMBER
    , p2_a50  NUMBER
    , p2_a51  VARCHAR2
    , p2_a52  NUMBER
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  NUMBER
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  NUMBER
    , p2_a60  NUMBER
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  NUMBER
    , p2_a65  VARCHAR2
    , p2_a66  VARCHAR2
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p2_a70  VARCHAR2
    , p2_a71  VARCHAR2
    , p2_a72  VARCHAR2
    , p2_a73  VARCHAR2
    , p2_a74  VARCHAR2
    , p2_a75  VARCHAR2
    , p2_a76  VARCHAR2
    , p2_a77  VARCHAR2
    , p2_a78  VARCHAR2
    , p2_a79  VARCHAR2
    , p2_a80  VARCHAR2
    , p2_a81  VARCHAR2
    , p2_a82  VARCHAR2
    , p2_a83  NUMBER
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  NUMBER
    , p2_a89  NUMBER
    , p2_a90  NUMBER
    , p2_a91  NUMBER
    , p2_a92  NUMBER
    , p2_a93  NUMBER
    , p2_a94  NUMBER
    , p2_a95  VARCHAR2
    , p2_a96  VARCHAR2
    , p2_a97  DATE
    , p2_a98  NUMBER
    , p2_a99  NUMBER
    , p2_a100  NUMBER
    , p2_a101  NUMBER
    , p2_a102  NUMBER
    , p2_a103  NUMBER
    , p2_a104  NUMBER
    , p2_a105  NUMBER
    , p2_a106  NUMBER
    , p2_a107  NUMBER
    , p2_a108  NUMBER
    , p2_a109  NUMBER
    , p2_a110  VARCHAR2
    , p2_a111  NUMBER
    , p2_a112  NUMBER
    , p2_a113  VARCHAR2
    , p2_a114  NUMBER
    , p2_a115  NUMBER
    , p2_a116  NUMBER
    , p2_a117  DATE
    , p2_a118  NUMBER
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_fund_rec.fund_id := p2_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_fund_rec.last_updated_by := p2_a2;
    ddp_fund_rec.last_update_login := p2_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p2_a4);
    ddp_fund_rec.created_by := p2_a5;
    ddp_fund_rec.created_from := p2_a6;
    ddp_fund_rec.request_id := p2_a7;
    ddp_fund_rec.program_application_id := p2_a8;
    ddp_fund_rec.program_id := p2_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p2_a10);
    ddp_fund_rec.fund_number := p2_a11;
    ddp_fund_rec.parent_fund_id := p2_a12;
    ddp_fund_rec.category_id := p2_a13;
    ddp_fund_rec.fund_type := p2_a14;
    ddp_fund_rec.status_code := p2_a15;
    ddp_fund_rec.user_status_id := p2_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p2_a17);
    ddp_fund_rec.accrued_liable_account := p2_a18;
    ddp_fund_rec.ded_adjustment_account := p2_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p2_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p2_a21);
    ddp_fund_rec.currency_code_tc := p2_a22;
    ddp_fund_rec.owner := p2_a23;
    ddp_fund_rec.hierarchy := p2_a24;
    ddp_fund_rec.hierarchy_level := p2_a25;
    ddp_fund_rec.hierarchy_id := p2_a26;
    ddp_fund_rec.parent_node_id := p2_a27;
    ddp_fund_rec.node_id := p2_a28;
    ddp_fund_rec.object_version_number := p2_a29;
    ddp_fund_rec.org_id := p2_a30;
    ddp_fund_rec.earned_flag := p2_a31;
    ddp_fund_rec.original_budget := p2_a32;
    ddp_fund_rec.transfered_in_amt := p2_a33;
    ddp_fund_rec.transfered_out_amt := p2_a34;
    ddp_fund_rec.holdback_amt := p2_a35;
    ddp_fund_rec.planned_amt := p2_a36;
    ddp_fund_rec.committed_amt := p2_a37;
    ddp_fund_rec.earned_amt := p2_a38;
    ddp_fund_rec.paid_amt := p2_a39;
    ddp_fund_rec.liable_accnt_segments := p2_a40;
    ddp_fund_rec.adjustment_accnt_segments := p2_a41;
    ddp_fund_rec.short_name := p2_a42;
    ddp_fund_rec.description := p2_a43;
    ddp_fund_rec.language := p2_a44;
    ddp_fund_rec.source_lang := p2_a45;
    ddp_fund_rec.start_period_name := p2_a46;
    ddp_fund_rec.end_period_name := p2_a47;
    ddp_fund_rec.fund_calendar := p2_a48;
    ddp_fund_rec.accrue_to_level_id := p2_a49;
    ddp_fund_rec.accrual_quantity := p2_a50;
    ddp_fund_rec.accrual_phase := p2_a51;
    ddp_fund_rec.accrual_cap := p2_a52;
    ddp_fund_rec.accrual_uom := p2_a53;
    ddp_fund_rec.accrual_method := p2_a54;
    ddp_fund_rec.accrual_operand := p2_a55;
    ddp_fund_rec.accrual_rate := p2_a56;
    ddp_fund_rec.accrual_basis := p2_a57;
    ddp_fund_rec.accrual_discount_level := p2_a58;
    ddp_fund_rec.custom_setup_id := p2_a59;
    ddp_fund_rec.threshold_id := p2_a60;
    ddp_fund_rec.business_unit_id := p2_a61;
    ddp_fund_rec.country_id := p2_a62;
    ddp_fund_rec.task_id := p2_a63;
    ddp_fund_rec.recal_committed := p2_a64;
    ddp_fund_rec.attribute_category := p2_a65;
    ddp_fund_rec.attribute1 := p2_a66;
    ddp_fund_rec.attribute2 := p2_a67;
    ddp_fund_rec.attribute3 := p2_a68;
    ddp_fund_rec.attribute4 := p2_a69;
    ddp_fund_rec.attribute5 := p2_a70;
    ddp_fund_rec.attribute6 := p2_a71;
    ddp_fund_rec.attribute7 := p2_a72;
    ddp_fund_rec.attribute8 := p2_a73;
    ddp_fund_rec.attribute9 := p2_a74;
    ddp_fund_rec.attribute10 := p2_a75;
    ddp_fund_rec.attribute11 := p2_a76;
    ddp_fund_rec.attribute12 := p2_a77;
    ddp_fund_rec.attribute13 := p2_a78;
    ddp_fund_rec.attribute14 := p2_a79;
    ddp_fund_rec.attribute15 := p2_a80;
    ddp_fund_rec.fund_usage := p2_a81;
    ddp_fund_rec.plan_type := p2_a82;
    ddp_fund_rec.plan_id := p2_a83;
    ddp_fund_rec.apply_accrual_on := p2_a84;
    ddp_fund_rec.level_value := p2_a85;
    ddp_fund_rec.budget_flag := p2_a86;
    ddp_fund_rec.liability_flag := p2_a87;
    ddp_fund_rec.set_of_books_id := p2_a88;
    ddp_fund_rec.start_period_id := p2_a89;
    ddp_fund_rec.end_period_id := p2_a90;
    ddp_fund_rec.budget_amount_tc := p2_a91;
    ddp_fund_rec.budget_amount_fc := p2_a92;
    ddp_fund_rec.available_amount := p2_a93;
    ddp_fund_rec.distributed_amount := p2_a94;
    ddp_fund_rec.currency_code_fc := p2_a95;
    ddp_fund_rec.exchange_rate_type := p2_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p2_a97);
    ddp_fund_rec.exchange_rate := p2_a98;
    ddp_fund_rec.department_id := p2_a99;
    ddp_fund_rec.costcentre_id := p2_a100;
    ddp_fund_rec.rollup_original_budget := p2_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p2_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p2_a103;
    ddp_fund_rec.rollup_holdback_amt := p2_a104;
    ddp_fund_rec.rollup_planned_amt := p2_a105;
    ddp_fund_rec.rollup_committed_amt := p2_a106;
    ddp_fund_rec.rollup_earned_amt := p2_a107;
    ddp_fund_rec.rollup_paid_amt := p2_a108;
    ddp_fund_rec.rollup_recal_committed := p2_a109;
    ddp_fund_rec.retroactive_flag := p2_a110;
    ddp_fund_rec.qualifier_id := p2_a111;
    ddp_fund_rec.prev_fund_id := p2_a112;
    ddp_fund_rec.transfered_flag := p2_a113;
    ddp_fund_rec.utilized_amt := p2_a114;
    ddp_fund_rec.rollup_utilized_amt := p2_a115;
    ddp_fund_rec.product_spread_time_id := p2_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p2_a117);
    ddp_fund_rec.ledger_id := p2_a118;

    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.check_fund_items(p_validation_mode,
      x_return_status,
      ddp_fund_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_fund_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  DATE
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  DATE
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  DATE
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p0_a105  NUMBER
    , p0_a106  NUMBER
    , p0_a107  NUMBER
    , p0_a108  NUMBER
    , p0_a109  NUMBER
    , p0_a110  VARCHAR2
    , p0_a111  NUMBER
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  NUMBER
    , p0_a116  NUMBER
    , p0_a117  DATE
    , p0_a118  NUMBER
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  VARCHAR2
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  DATE
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  DATE
    , p1_a21  DATE
    , p1_a22  VARCHAR2
    , p1_a23  NUMBER
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  NUMBER
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  VARCHAR2
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  VARCHAR2
    , p1_a52  NUMBER
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  NUMBER
    , p1_a60  NUMBER
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  VARCHAR2
    , p1_a66  VARCHAR2
    , p1_a67  VARCHAR2
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  VARCHAR2
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  VARCHAR2
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  VARCHAR2
    , p1_a83  NUMBER
    , p1_a84  VARCHAR2
    , p1_a85  VARCHAR2
    , p1_a86  VARCHAR2
    , p1_a87  VARCHAR2
    , p1_a88  NUMBER
    , p1_a89  NUMBER
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  NUMBER
    , p1_a93  NUMBER
    , p1_a94  NUMBER
    , p1_a95  VARCHAR2
    , p1_a96  VARCHAR2
    , p1_a97  DATE
    , p1_a98  NUMBER
    , p1_a99  NUMBER
    , p1_a100  NUMBER
    , p1_a101  NUMBER
    , p1_a102  NUMBER
    , p1_a103  NUMBER
    , p1_a104  NUMBER
    , p1_a105  NUMBER
    , p1_a106  NUMBER
    , p1_a107  NUMBER
    , p1_a108  NUMBER
    , p1_a109  NUMBER
    , p1_a110  VARCHAR2
    , p1_a111  NUMBER
    , p1_a112  NUMBER
    , p1_a113  VARCHAR2
    , p1_a114  NUMBER
    , p1_a115  NUMBER
    , p1_a116  NUMBER
    , p1_a117  DATE
    , p1_a118  NUMBER
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddp_complete_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_fund_rec.fund_id := p0_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_fund_rec.last_updated_by := p0_a2;
    ddp_fund_rec.last_update_login := p0_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_fund_rec.created_by := p0_a5;
    ddp_fund_rec.created_from := p0_a6;
    ddp_fund_rec.request_id := p0_a7;
    ddp_fund_rec.program_application_id := p0_a8;
    ddp_fund_rec.program_id := p0_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_fund_rec.fund_number := p0_a11;
    ddp_fund_rec.parent_fund_id := p0_a12;
    ddp_fund_rec.category_id := p0_a13;
    ddp_fund_rec.fund_type := p0_a14;
    ddp_fund_rec.status_code := p0_a15;
    ddp_fund_rec.user_status_id := p0_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_fund_rec.accrued_liable_account := p0_a18;
    ddp_fund_rec.ded_adjustment_account := p0_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a21);
    ddp_fund_rec.currency_code_tc := p0_a22;
    ddp_fund_rec.owner := p0_a23;
    ddp_fund_rec.hierarchy := p0_a24;
    ddp_fund_rec.hierarchy_level := p0_a25;
    ddp_fund_rec.hierarchy_id := p0_a26;
    ddp_fund_rec.parent_node_id := p0_a27;
    ddp_fund_rec.node_id := p0_a28;
    ddp_fund_rec.object_version_number := p0_a29;
    ddp_fund_rec.org_id := p0_a30;
    ddp_fund_rec.earned_flag := p0_a31;
    ddp_fund_rec.original_budget := p0_a32;
    ddp_fund_rec.transfered_in_amt := p0_a33;
    ddp_fund_rec.transfered_out_amt := p0_a34;
    ddp_fund_rec.holdback_amt := p0_a35;
    ddp_fund_rec.planned_amt := p0_a36;
    ddp_fund_rec.committed_amt := p0_a37;
    ddp_fund_rec.earned_amt := p0_a38;
    ddp_fund_rec.paid_amt := p0_a39;
    ddp_fund_rec.liable_accnt_segments := p0_a40;
    ddp_fund_rec.adjustment_accnt_segments := p0_a41;
    ddp_fund_rec.short_name := p0_a42;
    ddp_fund_rec.description := p0_a43;
    ddp_fund_rec.language := p0_a44;
    ddp_fund_rec.source_lang := p0_a45;
    ddp_fund_rec.start_period_name := p0_a46;
    ddp_fund_rec.end_period_name := p0_a47;
    ddp_fund_rec.fund_calendar := p0_a48;
    ddp_fund_rec.accrue_to_level_id := p0_a49;
    ddp_fund_rec.accrual_quantity := p0_a50;
    ddp_fund_rec.accrual_phase := p0_a51;
    ddp_fund_rec.accrual_cap := p0_a52;
    ddp_fund_rec.accrual_uom := p0_a53;
    ddp_fund_rec.accrual_method := p0_a54;
    ddp_fund_rec.accrual_operand := p0_a55;
    ddp_fund_rec.accrual_rate := p0_a56;
    ddp_fund_rec.accrual_basis := p0_a57;
    ddp_fund_rec.accrual_discount_level := p0_a58;
    ddp_fund_rec.custom_setup_id := p0_a59;
    ddp_fund_rec.threshold_id := p0_a60;
    ddp_fund_rec.business_unit_id := p0_a61;
    ddp_fund_rec.country_id := p0_a62;
    ddp_fund_rec.task_id := p0_a63;
    ddp_fund_rec.recal_committed := p0_a64;
    ddp_fund_rec.attribute_category := p0_a65;
    ddp_fund_rec.attribute1 := p0_a66;
    ddp_fund_rec.attribute2 := p0_a67;
    ddp_fund_rec.attribute3 := p0_a68;
    ddp_fund_rec.attribute4 := p0_a69;
    ddp_fund_rec.attribute5 := p0_a70;
    ddp_fund_rec.attribute6 := p0_a71;
    ddp_fund_rec.attribute7 := p0_a72;
    ddp_fund_rec.attribute8 := p0_a73;
    ddp_fund_rec.attribute9 := p0_a74;
    ddp_fund_rec.attribute10 := p0_a75;
    ddp_fund_rec.attribute11 := p0_a76;
    ddp_fund_rec.attribute12 := p0_a77;
    ddp_fund_rec.attribute13 := p0_a78;
    ddp_fund_rec.attribute14 := p0_a79;
    ddp_fund_rec.attribute15 := p0_a80;
    ddp_fund_rec.fund_usage := p0_a81;
    ddp_fund_rec.plan_type := p0_a82;
    ddp_fund_rec.plan_id := p0_a83;
    ddp_fund_rec.apply_accrual_on := p0_a84;
    ddp_fund_rec.level_value := p0_a85;
    ddp_fund_rec.budget_flag := p0_a86;
    ddp_fund_rec.liability_flag := p0_a87;
    ddp_fund_rec.set_of_books_id := p0_a88;
    ddp_fund_rec.start_period_id := p0_a89;
    ddp_fund_rec.end_period_id := p0_a90;
    ddp_fund_rec.budget_amount_tc := p0_a91;
    ddp_fund_rec.budget_amount_fc := p0_a92;
    ddp_fund_rec.available_amount := p0_a93;
    ddp_fund_rec.distributed_amount := p0_a94;
    ddp_fund_rec.currency_code_fc := p0_a95;
    ddp_fund_rec.exchange_rate_type := p0_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a97);
    ddp_fund_rec.exchange_rate := p0_a98;
    ddp_fund_rec.department_id := p0_a99;
    ddp_fund_rec.costcentre_id := p0_a100;
    ddp_fund_rec.rollup_original_budget := p0_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p0_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p0_a103;
    ddp_fund_rec.rollup_holdback_amt := p0_a104;
    ddp_fund_rec.rollup_planned_amt := p0_a105;
    ddp_fund_rec.rollup_committed_amt := p0_a106;
    ddp_fund_rec.rollup_earned_amt := p0_a107;
    ddp_fund_rec.rollup_paid_amt := p0_a108;
    ddp_fund_rec.rollup_recal_committed := p0_a109;
    ddp_fund_rec.retroactive_flag := p0_a110;
    ddp_fund_rec.qualifier_id := p0_a111;
    ddp_fund_rec.prev_fund_id := p0_a112;
    ddp_fund_rec.transfered_flag := p0_a113;
    ddp_fund_rec.utilized_amt := p0_a114;
    ddp_fund_rec.rollup_utilized_amt := p0_a115;
    ddp_fund_rec.product_spread_time_id := p0_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p0_a117);
    ddp_fund_rec.ledger_id := p0_a118;

    ddp_complete_rec.fund_id := p1_a0;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.last_update_login := p1_a3;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_rec.created_by := p1_a5;
    ddp_complete_rec.created_from := p1_a6;
    ddp_complete_rec.request_id := p1_a7;
    ddp_complete_rec.program_application_id := p1_a8;
    ddp_complete_rec.program_id := p1_a9;
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_complete_rec.fund_number := p1_a11;
    ddp_complete_rec.parent_fund_id := p1_a12;
    ddp_complete_rec.category_id := p1_a13;
    ddp_complete_rec.fund_type := p1_a14;
    ddp_complete_rec.status_code := p1_a15;
    ddp_complete_rec.user_status_id := p1_a16;
    ddp_complete_rec.status_date := rosetta_g_miss_date_in_map(p1_a17);
    ddp_complete_rec.accrued_liable_account := p1_a18;
    ddp_complete_rec.ded_adjustment_account := p1_a19;
    ddp_complete_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a20);
    ddp_complete_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a21);
    ddp_complete_rec.currency_code_tc := p1_a22;
    ddp_complete_rec.owner := p1_a23;
    ddp_complete_rec.hierarchy := p1_a24;
    ddp_complete_rec.hierarchy_level := p1_a25;
    ddp_complete_rec.hierarchy_id := p1_a26;
    ddp_complete_rec.parent_node_id := p1_a27;
    ddp_complete_rec.node_id := p1_a28;
    ddp_complete_rec.object_version_number := p1_a29;
    ddp_complete_rec.org_id := p1_a30;
    ddp_complete_rec.earned_flag := p1_a31;
    ddp_complete_rec.original_budget := p1_a32;
    ddp_complete_rec.transfered_in_amt := p1_a33;
    ddp_complete_rec.transfered_out_amt := p1_a34;
    ddp_complete_rec.holdback_amt := p1_a35;
    ddp_complete_rec.planned_amt := p1_a36;
    ddp_complete_rec.committed_amt := p1_a37;
    ddp_complete_rec.earned_amt := p1_a38;
    ddp_complete_rec.paid_amt := p1_a39;
    ddp_complete_rec.liable_accnt_segments := p1_a40;
    ddp_complete_rec.adjustment_accnt_segments := p1_a41;
    ddp_complete_rec.short_name := p1_a42;
    ddp_complete_rec.description := p1_a43;
    ddp_complete_rec.language := p1_a44;
    ddp_complete_rec.source_lang := p1_a45;
    ddp_complete_rec.start_period_name := p1_a46;
    ddp_complete_rec.end_period_name := p1_a47;
    ddp_complete_rec.fund_calendar := p1_a48;
    ddp_complete_rec.accrue_to_level_id := p1_a49;
    ddp_complete_rec.accrual_quantity := p1_a50;
    ddp_complete_rec.accrual_phase := p1_a51;
    ddp_complete_rec.accrual_cap := p1_a52;
    ddp_complete_rec.accrual_uom := p1_a53;
    ddp_complete_rec.accrual_method := p1_a54;
    ddp_complete_rec.accrual_operand := p1_a55;
    ddp_complete_rec.accrual_rate := p1_a56;
    ddp_complete_rec.accrual_basis := p1_a57;
    ddp_complete_rec.accrual_discount_level := p1_a58;
    ddp_complete_rec.custom_setup_id := p1_a59;
    ddp_complete_rec.threshold_id := p1_a60;
    ddp_complete_rec.business_unit_id := p1_a61;
    ddp_complete_rec.country_id := p1_a62;
    ddp_complete_rec.task_id := p1_a63;
    ddp_complete_rec.recal_committed := p1_a64;
    ddp_complete_rec.attribute_category := p1_a65;
    ddp_complete_rec.attribute1 := p1_a66;
    ddp_complete_rec.attribute2 := p1_a67;
    ddp_complete_rec.attribute3 := p1_a68;
    ddp_complete_rec.attribute4 := p1_a69;
    ddp_complete_rec.attribute5 := p1_a70;
    ddp_complete_rec.attribute6 := p1_a71;
    ddp_complete_rec.attribute7 := p1_a72;
    ddp_complete_rec.attribute8 := p1_a73;
    ddp_complete_rec.attribute9 := p1_a74;
    ddp_complete_rec.attribute10 := p1_a75;
    ddp_complete_rec.attribute11 := p1_a76;
    ddp_complete_rec.attribute12 := p1_a77;
    ddp_complete_rec.attribute13 := p1_a78;
    ddp_complete_rec.attribute14 := p1_a79;
    ddp_complete_rec.attribute15 := p1_a80;
    ddp_complete_rec.fund_usage := p1_a81;
    ddp_complete_rec.plan_type := p1_a82;
    ddp_complete_rec.plan_id := p1_a83;
    ddp_complete_rec.apply_accrual_on := p1_a84;
    ddp_complete_rec.level_value := p1_a85;
    ddp_complete_rec.budget_flag := p1_a86;
    ddp_complete_rec.liability_flag := p1_a87;
    ddp_complete_rec.set_of_books_id := p1_a88;
    ddp_complete_rec.start_period_id := p1_a89;
    ddp_complete_rec.end_period_id := p1_a90;
    ddp_complete_rec.budget_amount_tc := p1_a91;
    ddp_complete_rec.budget_amount_fc := p1_a92;
    ddp_complete_rec.available_amount := p1_a93;
    ddp_complete_rec.distributed_amount := p1_a94;
    ddp_complete_rec.currency_code_fc := p1_a95;
    ddp_complete_rec.exchange_rate_type := p1_a96;
    ddp_complete_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p1_a97);
    ddp_complete_rec.exchange_rate := p1_a98;
    ddp_complete_rec.department_id := p1_a99;
    ddp_complete_rec.costcentre_id := p1_a100;
    ddp_complete_rec.rollup_original_budget := p1_a101;
    ddp_complete_rec.rollup_transfered_in_amt := p1_a102;
    ddp_complete_rec.rollup_transfered_out_amt := p1_a103;
    ddp_complete_rec.rollup_holdback_amt := p1_a104;
    ddp_complete_rec.rollup_planned_amt := p1_a105;
    ddp_complete_rec.rollup_committed_amt := p1_a106;
    ddp_complete_rec.rollup_earned_amt := p1_a107;
    ddp_complete_rec.rollup_paid_amt := p1_a108;
    ddp_complete_rec.rollup_recal_committed := p1_a109;
    ddp_complete_rec.retroactive_flag := p1_a110;
    ddp_complete_rec.qualifier_id := p1_a111;
    ddp_complete_rec.prev_fund_id := p1_a112;
    ddp_complete_rec.transfered_flag := p1_a113;
    ddp_complete_rec.utilized_amt := p1_a114;
    ddp_complete_rec.rollup_utilized_amt := p1_a115;
    ddp_complete_rec.product_spread_time_id := p1_a116;
    ddp_complete_rec.activation_date := rosetta_g_miss_date_in_map(p1_a117);
    ddp_complete_rec.ledger_id := p1_a118;



    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.check_fund_record(ddp_fund_rec,
      ddp_complete_rec,
      p_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure init_fund_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  VARCHAR2
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  DATE
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  DATE
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  DATE
    , p0_a21 out nocopy  DATE
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  NUMBER
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  NUMBER
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  NUMBER
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  NUMBER
    , p0_a38 out nocopy  NUMBER
    , p0_a39 out nocopy  NUMBER
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  VARCHAR2
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  NUMBER
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  VARCHAR2
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  NUMBER
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  NUMBER
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  VARCHAR2
    , p0_a66 out nocopy  VARCHAR2
    , p0_a67 out nocopy  VARCHAR2
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  VARCHAR2
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  VARCHAR2
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  VARCHAR2
    , p0_a76 out nocopy  VARCHAR2
    , p0_a77 out nocopy  VARCHAR2
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  VARCHAR2
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  VARCHAR2
    , p0_a82 out nocopy  VARCHAR2
    , p0_a83 out nocopy  NUMBER
    , p0_a84 out nocopy  VARCHAR2
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  VARCHAR2
    , p0_a87 out nocopy  VARCHAR2
    , p0_a88 out nocopy  NUMBER
    , p0_a89 out nocopy  NUMBER
    , p0_a90 out nocopy  NUMBER
    , p0_a91 out nocopy  NUMBER
    , p0_a92 out nocopy  NUMBER
    , p0_a93 out nocopy  NUMBER
    , p0_a94 out nocopy  NUMBER
    , p0_a95 out nocopy  VARCHAR2
    , p0_a96 out nocopy  VARCHAR2
    , p0_a97 out nocopy  DATE
    , p0_a98 out nocopy  NUMBER
    , p0_a99 out nocopy  NUMBER
    , p0_a100 out nocopy  NUMBER
    , p0_a101 out nocopy  NUMBER
    , p0_a102 out nocopy  NUMBER
    , p0_a103 out nocopy  NUMBER
    , p0_a104 out nocopy  NUMBER
    , p0_a105 out nocopy  NUMBER
    , p0_a106 out nocopy  NUMBER
    , p0_a107 out nocopy  NUMBER
    , p0_a108 out nocopy  NUMBER
    , p0_a109 out nocopy  NUMBER
    , p0_a110 out nocopy  VARCHAR2
    , p0_a111 out nocopy  NUMBER
    , p0_a112 out nocopy  NUMBER
    , p0_a113 out nocopy  VARCHAR2
    , p0_a114 out nocopy  NUMBER
    , p0_a115 out nocopy  NUMBER
    , p0_a116 out nocopy  NUMBER
    , p0_a117 out nocopy  DATE
    , p0_a118 out nocopy  NUMBER
  )

  as
    ddx_fund_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.init_fund_rec(ddx_fund_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_fund_rec.fund_id;
    p0_a1 := ddx_fund_rec.last_update_date;
    p0_a2 := ddx_fund_rec.last_updated_by;
    p0_a3 := ddx_fund_rec.last_update_login;
    p0_a4 := ddx_fund_rec.creation_date;
    p0_a5 := ddx_fund_rec.created_by;
    p0_a6 := ddx_fund_rec.created_from;
    p0_a7 := ddx_fund_rec.request_id;
    p0_a8 := ddx_fund_rec.program_application_id;
    p0_a9 := ddx_fund_rec.program_id;
    p0_a10 := ddx_fund_rec.program_update_date;
    p0_a11 := ddx_fund_rec.fund_number;
    p0_a12 := ddx_fund_rec.parent_fund_id;
    p0_a13 := ddx_fund_rec.category_id;
    p0_a14 := ddx_fund_rec.fund_type;
    p0_a15 := ddx_fund_rec.status_code;
    p0_a16 := ddx_fund_rec.user_status_id;
    p0_a17 := ddx_fund_rec.status_date;
    p0_a18 := ddx_fund_rec.accrued_liable_account;
    p0_a19 := ddx_fund_rec.ded_adjustment_account;
    p0_a20 := ddx_fund_rec.start_date_active;
    p0_a21 := ddx_fund_rec.end_date_active;
    p0_a22 := ddx_fund_rec.currency_code_tc;
    p0_a23 := ddx_fund_rec.owner;
    p0_a24 := ddx_fund_rec.hierarchy;
    p0_a25 := ddx_fund_rec.hierarchy_level;
    p0_a26 := ddx_fund_rec.hierarchy_id;
    p0_a27 := ddx_fund_rec.parent_node_id;
    p0_a28 := ddx_fund_rec.node_id;
    p0_a29 := ddx_fund_rec.object_version_number;
    p0_a30 := ddx_fund_rec.org_id;
    p0_a31 := ddx_fund_rec.earned_flag;
    p0_a32 := ddx_fund_rec.original_budget;
    p0_a33 := ddx_fund_rec.transfered_in_amt;
    p0_a34 := ddx_fund_rec.transfered_out_amt;
    p0_a35 := ddx_fund_rec.holdback_amt;
    p0_a36 := ddx_fund_rec.planned_amt;
    p0_a37 := ddx_fund_rec.committed_amt;
    p0_a38 := ddx_fund_rec.earned_amt;
    p0_a39 := ddx_fund_rec.paid_amt;
    p0_a40 := ddx_fund_rec.liable_accnt_segments;
    p0_a41 := ddx_fund_rec.adjustment_accnt_segments;
    p0_a42 := ddx_fund_rec.short_name;
    p0_a43 := ddx_fund_rec.description;
    p0_a44 := ddx_fund_rec.language;
    p0_a45 := ddx_fund_rec.source_lang;
    p0_a46 := ddx_fund_rec.start_period_name;
    p0_a47 := ddx_fund_rec.end_period_name;
    p0_a48 := ddx_fund_rec.fund_calendar;
    p0_a49 := ddx_fund_rec.accrue_to_level_id;
    p0_a50 := ddx_fund_rec.accrual_quantity;
    p0_a51 := ddx_fund_rec.accrual_phase;
    p0_a52 := ddx_fund_rec.accrual_cap;
    p0_a53 := ddx_fund_rec.accrual_uom;
    p0_a54 := ddx_fund_rec.accrual_method;
    p0_a55 := ddx_fund_rec.accrual_operand;
    p0_a56 := ddx_fund_rec.accrual_rate;
    p0_a57 := ddx_fund_rec.accrual_basis;
    p0_a58 := ddx_fund_rec.accrual_discount_level;
    p0_a59 := ddx_fund_rec.custom_setup_id;
    p0_a60 := ddx_fund_rec.threshold_id;
    p0_a61 := ddx_fund_rec.business_unit_id;
    p0_a62 := ddx_fund_rec.country_id;
    p0_a63 := ddx_fund_rec.task_id;
    p0_a64 := ddx_fund_rec.recal_committed;
    p0_a65 := ddx_fund_rec.attribute_category;
    p0_a66 := ddx_fund_rec.attribute1;
    p0_a67 := ddx_fund_rec.attribute2;
    p0_a68 := ddx_fund_rec.attribute3;
    p0_a69 := ddx_fund_rec.attribute4;
    p0_a70 := ddx_fund_rec.attribute5;
    p0_a71 := ddx_fund_rec.attribute6;
    p0_a72 := ddx_fund_rec.attribute7;
    p0_a73 := ddx_fund_rec.attribute8;
    p0_a74 := ddx_fund_rec.attribute9;
    p0_a75 := ddx_fund_rec.attribute10;
    p0_a76 := ddx_fund_rec.attribute11;
    p0_a77 := ddx_fund_rec.attribute12;
    p0_a78 := ddx_fund_rec.attribute13;
    p0_a79 := ddx_fund_rec.attribute14;
    p0_a80 := ddx_fund_rec.attribute15;
    p0_a81 := ddx_fund_rec.fund_usage;
    p0_a82 := ddx_fund_rec.plan_type;
    p0_a83 := ddx_fund_rec.plan_id;
    p0_a84 := ddx_fund_rec.apply_accrual_on;
    p0_a85 := ddx_fund_rec.level_value;
    p0_a86 := ddx_fund_rec.budget_flag;
    p0_a87 := ddx_fund_rec.liability_flag;
    p0_a88 := ddx_fund_rec.set_of_books_id;
    p0_a89 := ddx_fund_rec.start_period_id;
    p0_a90 := ddx_fund_rec.end_period_id;
    p0_a91 := ddx_fund_rec.budget_amount_tc;
    p0_a92 := ddx_fund_rec.budget_amount_fc;
    p0_a93 := ddx_fund_rec.available_amount;
    p0_a94 := ddx_fund_rec.distributed_amount;
    p0_a95 := ddx_fund_rec.currency_code_fc;
    p0_a96 := ddx_fund_rec.exchange_rate_type;
    p0_a97 := ddx_fund_rec.exchange_rate_date;
    p0_a98 := ddx_fund_rec.exchange_rate;
    p0_a99 := ddx_fund_rec.department_id;
    p0_a100 := ddx_fund_rec.costcentre_id;
    p0_a101 := ddx_fund_rec.rollup_original_budget;
    p0_a102 := ddx_fund_rec.rollup_transfered_in_amt;
    p0_a103 := ddx_fund_rec.rollup_transfered_out_amt;
    p0_a104 := ddx_fund_rec.rollup_holdback_amt;
    p0_a105 := ddx_fund_rec.rollup_planned_amt;
    p0_a106 := ddx_fund_rec.rollup_committed_amt;
    p0_a107 := ddx_fund_rec.rollup_earned_amt;
    p0_a108 := ddx_fund_rec.rollup_paid_amt;
    p0_a109 := ddx_fund_rec.rollup_recal_committed;
    p0_a110 := ddx_fund_rec.retroactive_flag;
    p0_a111 := ddx_fund_rec.qualifier_id;
    p0_a112 := ddx_fund_rec.prev_fund_id;
    p0_a113 := ddx_fund_rec.transfered_flag;
    p0_a114 := ddx_fund_rec.utilized_amt;
    p0_a115 := ddx_fund_rec.rollup_utilized_amt;
    p0_a116 := ddx_fund_rec.product_spread_time_id;
    p0_a117 := ddx_fund_rec.activation_date;
    p0_a118 := ddx_fund_rec.ledger_id;
  end;

  procedure complete_fund_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  DATE
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  DATE
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  DATE
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p0_a105  NUMBER
    , p0_a106  NUMBER
    , p0_a107  NUMBER
    , p0_a108  NUMBER
    , p0_a109  NUMBER
    , p0_a110  VARCHAR2
    , p0_a111  NUMBER
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  NUMBER
    , p0_a116  NUMBER
    , p0_a117  DATE
    , p0_a118  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  VARCHAR2
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  DATE
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  DATE
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  DATE
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  NUMBER
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  NUMBER
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  NUMBER
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  NUMBER
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  VARCHAR2
    , p1_a66 out nocopy  VARCHAR2
    , p1_a67 out nocopy  VARCHAR2
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  VARCHAR2
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  VARCHAR2
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  VARCHAR2
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  VARCHAR2
    , p1_a82 out nocopy  VARCHAR2
    , p1_a83 out nocopy  NUMBER
    , p1_a84 out nocopy  VARCHAR2
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  VARCHAR2
    , p1_a87 out nocopy  VARCHAR2
    , p1_a88 out nocopy  NUMBER
    , p1_a89 out nocopy  NUMBER
    , p1_a90 out nocopy  NUMBER
    , p1_a91 out nocopy  NUMBER
    , p1_a92 out nocopy  NUMBER
    , p1_a93 out nocopy  NUMBER
    , p1_a94 out nocopy  NUMBER
    , p1_a95 out nocopy  VARCHAR2
    , p1_a96 out nocopy  VARCHAR2
    , p1_a97 out nocopy  DATE
    , p1_a98 out nocopy  NUMBER
    , p1_a99 out nocopy  NUMBER
    , p1_a100 out nocopy  NUMBER
    , p1_a101 out nocopy  NUMBER
    , p1_a102 out nocopy  NUMBER
    , p1_a103 out nocopy  NUMBER
    , p1_a104 out nocopy  NUMBER
    , p1_a105 out nocopy  NUMBER
    , p1_a106 out nocopy  NUMBER
    , p1_a107 out nocopy  NUMBER
    , p1_a108 out nocopy  NUMBER
    , p1_a109 out nocopy  NUMBER
    , p1_a110 out nocopy  VARCHAR2
    , p1_a111 out nocopy  NUMBER
    , p1_a112 out nocopy  NUMBER
    , p1_a113 out nocopy  VARCHAR2
    , p1_a114 out nocopy  NUMBER
    , p1_a115 out nocopy  NUMBER
    , p1_a116 out nocopy  NUMBER
    , p1_a117 out nocopy  DATE
    , p1_a118 out nocopy  NUMBER
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddx_complete_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_fund_rec.fund_id := p0_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_fund_rec.last_updated_by := p0_a2;
    ddp_fund_rec.last_update_login := p0_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_fund_rec.created_by := p0_a5;
    ddp_fund_rec.created_from := p0_a6;
    ddp_fund_rec.request_id := p0_a7;
    ddp_fund_rec.program_application_id := p0_a8;
    ddp_fund_rec.program_id := p0_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_fund_rec.fund_number := p0_a11;
    ddp_fund_rec.parent_fund_id := p0_a12;
    ddp_fund_rec.category_id := p0_a13;
    ddp_fund_rec.fund_type := p0_a14;
    ddp_fund_rec.status_code := p0_a15;
    ddp_fund_rec.user_status_id := p0_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_fund_rec.accrued_liable_account := p0_a18;
    ddp_fund_rec.ded_adjustment_account := p0_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a21);
    ddp_fund_rec.currency_code_tc := p0_a22;
    ddp_fund_rec.owner := p0_a23;
    ddp_fund_rec.hierarchy := p0_a24;
    ddp_fund_rec.hierarchy_level := p0_a25;
    ddp_fund_rec.hierarchy_id := p0_a26;
    ddp_fund_rec.parent_node_id := p0_a27;
    ddp_fund_rec.node_id := p0_a28;
    ddp_fund_rec.object_version_number := p0_a29;
    ddp_fund_rec.org_id := p0_a30;
    ddp_fund_rec.earned_flag := p0_a31;
    ddp_fund_rec.original_budget := p0_a32;
    ddp_fund_rec.transfered_in_amt := p0_a33;
    ddp_fund_rec.transfered_out_amt := p0_a34;
    ddp_fund_rec.holdback_amt := p0_a35;
    ddp_fund_rec.planned_amt := p0_a36;
    ddp_fund_rec.committed_amt := p0_a37;
    ddp_fund_rec.earned_amt := p0_a38;
    ddp_fund_rec.paid_amt := p0_a39;
    ddp_fund_rec.liable_accnt_segments := p0_a40;
    ddp_fund_rec.adjustment_accnt_segments := p0_a41;
    ddp_fund_rec.short_name := p0_a42;
    ddp_fund_rec.description := p0_a43;
    ddp_fund_rec.language := p0_a44;
    ddp_fund_rec.source_lang := p0_a45;
    ddp_fund_rec.start_period_name := p0_a46;
    ddp_fund_rec.end_period_name := p0_a47;
    ddp_fund_rec.fund_calendar := p0_a48;
    ddp_fund_rec.accrue_to_level_id := p0_a49;
    ddp_fund_rec.accrual_quantity := p0_a50;
    ddp_fund_rec.accrual_phase := p0_a51;
    ddp_fund_rec.accrual_cap := p0_a52;
    ddp_fund_rec.accrual_uom := p0_a53;
    ddp_fund_rec.accrual_method := p0_a54;
    ddp_fund_rec.accrual_operand := p0_a55;
    ddp_fund_rec.accrual_rate := p0_a56;
    ddp_fund_rec.accrual_basis := p0_a57;
    ddp_fund_rec.accrual_discount_level := p0_a58;
    ddp_fund_rec.custom_setup_id := p0_a59;
    ddp_fund_rec.threshold_id := p0_a60;
    ddp_fund_rec.business_unit_id := p0_a61;
    ddp_fund_rec.country_id := p0_a62;
    ddp_fund_rec.task_id := p0_a63;
    ddp_fund_rec.recal_committed := p0_a64;
    ddp_fund_rec.attribute_category := p0_a65;
    ddp_fund_rec.attribute1 := p0_a66;
    ddp_fund_rec.attribute2 := p0_a67;
    ddp_fund_rec.attribute3 := p0_a68;
    ddp_fund_rec.attribute4 := p0_a69;
    ddp_fund_rec.attribute5 := p0_a70;
    ddp_fund_rec.attribute6 := p0_a71;
    ddp_fund_rec.attribute7 := p0_a72;
    ddp_fund_rec.attribute8 := p0_a73;
    ddp_fund_rec.attribute9 := p0_a74;
    ddp_fund_rec.attribute10 := p0_a75;
    ddp_fund_rec.attribute11 := p0_a76;
    ddp_fund_rec.attribute12 := p0_a77;
    ddp_fund_rec.attribute13 := p0_a78;
    ddp_fund_rec.attribute14 := p0_a79;
    ddp_fund_rec.attribute15 := p0_a80;
    ddp_fund_rec.fund_usage := p0_a81;
    ddp_fund_rec.plan_type := p0_a82;
    ddp_fund_rec.plan_id := p0_a83;
    ddp_fund_rec.apply_accrual_on := p0_a84;
    ddp_fund_rec.level_value := p0_a85;
    ddp_fund_rec.budget_flag := p0_a86;
    ddp_fund_rec.liability_flag := p0_a87;
    ddp_fund_rec.set_of_books_id := p0_a88;
    ddp_fund_rec.start_period_id := p0_a89;
    ddp_fund_rec.end_period_id := p0_a90;
    ddp_fund_rec.budget_amount_tc := p0_a91;
    ddp_fund_rec.budget_amount_fc := p0_a92;
    ddp_fund_rec.available_amount := p0_a93;
    ddp_fund_rec.distributed_amount := p0_a94;
    ddp_fund_rec.currency_code_fc := p0_a95;
    ddp_fund_rec.exchange_rate_type := p0_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a97);
    ddp_fund_rec.exchange_rate := p0_a98;
    ddp_fund_rec.department_id := p0_a99;
    ddp_fund_rec.costcentre_id := p0_a100;
    ddp_fund_rec.rollup_original_budget := p0_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p0_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p0_a103;
    ddp_fund_rec.rollup_holdback_amt := p0_a104;
    ddp_fund_rec.rollup_planned_amt := p0_a105;
    ddp_fund_rec.rollup_committed_amt := p0_a106;
    ddp_fund_rec.rollup_earned_amt := p0_a107;
    ddp_fund_rec.rollup_paid_amt := p0_a108;
    ddp_fund_rec.rollup_recal_committed := p0_a109;
    ddp_fund_rec.retroactive_flag := p0_a110;
    ddp_fund_rec.qualifier_id := p0_a111;
    ddp_fund_rec.prev_fund_id := p0_a112;
    ddp_fund_rec.transfered_flag := p0_a113;
    ddp_fund_rec.utilized_amt := p0_a114;
    ddp_fund_rec.rollup_utilized_amt := p0_a115;
    ddp_fund_rec.product_spread_time_id := p0_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p0_a117);
    ddp_fund_rec.ledger_id := p0_a118;


    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.complete_fund_rec(ddp_fund_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.fund_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.last_update_login;
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := ddx_complete_rec.created_by;
    p1_a6 := ddx_complete_rec.created_from;
    p1_a7 := ddx_complete_rec.request_id;
    p1_a8 := ddx_complete_rec.program_application_id;
    p1_a9 := ddx_complete_rec.program_id;
    p1_a10 := ddx_complete_rec.program_update_date;
    p1_a11 := ddx_complete_rec.fund_number;
    p1_a12 := ddx_complete_rec.parent_fund_id;
    p1_a13 := ddx_complete_rec.category_id;
    p1_a14 := ddx_complete_rec.fund_type;
    p1_a15 := ddx_complete_rec.status_code;
    p1_a16 := ddx_complete_rec.user_status_id;
    p1_a17 := ddx_complete_rec.status_date;
    p1_a18 := ddx_complete_rec.accrued_liable_account;
    p1_a19 := ddx_complete_rec.ded_adjustment_account;
    p1_a20 := ddx_complete_rec.start_date_active;
    p1_a21 := ddx_complete_rec.end_date_active;
    p1_a22 := ddx_complete_rec.currency_code_tc;
    p1_a23 := ddx_complete_rec.owner;
    p1_a24 := ddx_complete_rec.hierarchy;
    p1_a25 := ddx_complete_rec.hierarchy_level;
    p1_a26 := ddx_complete_rec.hierarchy_id;
    p1_a27 := ddx_complete_rec.parent_node_id;
    p1_a28 := ddx_complete_rec.node_id;
    p1_a29 := ddx_complete_rec.object_version_number;
    p1_a30 := ddx_complete_rec.org_id;
    p1_a31 := ddx_complete_rec.earned_flag;
    p1_a32 := ddx_complete_rec.original_budget;
    p1_a33 := ddx_complete_rec.transfered_in_amt;
    p1_a34 := ddx_complete_rec.transfered_out_amt;
    p1_a35 := ddx_complete_rec.holdback_amt;
    p1_a36 := ddx_complete_rec.planned_amt;
    p1_a37 := ddx_complete_rec.committed_amt;
    p1_a38 := ddx_complete_rec.earned_amt;
    p1_a39 := ddx_complete_rec.paid_amt;
    p1_a40 := ddx_complete_rec.liable_accnt_segments;
    p1_a41 := ddx_complete_rec.adjustment_accnt_segments;
    p1_a42 := ddx_complete_rec.short_name;
    p1_a43 := ddx_complete_rec.description;
    p1_a44 := ddx_complete_rec.language;
    p1_a45 := ddx_complete_rec.source_lang;
    p1_a46 := ddx_complete_rec.start_period_name;
    p1_a47 := ddx_complete_rec.end_period_name;
    p1_a48 := ddx_complete_rec.fund_calendar;
    p1_a49 := ddx_complete_rec.accrue_to_level_id;
    p1_a50 := ddx_complete_rec.accrual_quantity;
    p1_a51 := ddx_complete_rec.accrual_phase;
    p1_a52 := ddx_complete_rec.accrual_cap;
    p1_a53 := ddx_complete_rec.accrual_uom;
    p1_a54 := ddx_complete_rec.accrual_method;
    p1_a55 := ddx_complete_rec.accrual_operand;
    p1_a56 := ddx_complete_rec.accrual_rate;
    p1_a57 := ddx_complete_rec.accrual_basis;
    p1_a58 := ddx_complete_rec.accrual_discount_level;
    p1_a59 := ddx_complete_rec.custom_setup_id;
    p1_a60 := ddx_complete_rec.threshold_id;
    p1_a61 := ddx_complete_rec.business_unit_id;
    p1_a62 := ddx_complete_rec.country_id;
    p1_a63 := ddx_complete_rec.task_id;
    p1_a64 := ddx_complete_rec.recal_committed;
    p1_a65 := ddx_complete_rec.attribute_category;
    p1_a66 := ddx_complete_rec.attribute1;
    p1_a67 := ddx_complete_rec.attribute2;
    p1_a68 := ddx_complete_rec.attribute3;
    p1_a69 := ddx_complete_rec.attribute4;
    p1_a70 := ddx_complete_rec.attribute5;
    p1_a71 := ddx_complete_rec.attribute6;
    p1_a72 := ddx_complete_rec.attribute7;
    p1_a73 := ddx_complete_rec.attribute8;
    p1_a74 := ddx_complete_rec.attribute9;
    p1_a75 := ddx_complete_rec.attribute10;
    p1_a76 := ddx_complete_rec.attribute11;
    p1_a77 := ddx_complete_rec.attribute12;
    p1_a78 := ddx_complete_rec.attribute13;
    p1_a79 := ddx_complete_rec.attribute14;
    p1_a80 := ddx_complete_rec.attribute15;
    p1_a81 := ddx_complete_rec.fund_usage;
    p1_a82 := ddx_complete_rec.plan_type;
    p1_a83 := ddx_complete_rec.plan_id;
    p1_a84 := ddx_complete_rec.apply_accrual_on;
    p1_a85 := ddx_complete_rec.level_value;
    p1_a86 := ddx_complete_rec.budget_flag;
    p1_a87 := ddx_complete_rec.liability_flag;
    p1_a88 := ddx_complete_rec.set_of_books_id;
    p1_a89 := ddx_complete_rec.start_period_id;
    p1_a90 := ddx_complete_rec.end_period_id;
    p1_a91 := ddx_complete_rec.budget_amount_tc;
    p1_a92 := ddx_complete_rec.budget_amount_fc;
    p1_a93 := ddx_complete_rec.available_amount;
    p1_a94 := ddx_complete_rec.distributed_amount;
    p1_a95 := ddx_complete_rec.currency_code_fc;
    p1_a96 := ddx_complete_rec.exchange_rate_type;
    p1_a97 := ddx_complete_rec.exchange_rate_date;
    p1_a98 := ddx_complete_rec.exchange_rate;
    p1_a99 := ddx_complete_rec.department_id;
    p1_a100 := ddx_complete_rec.costcentre_id;
    p1_a101 := ddx_complete_rec.rollup_original_budget;
    p1_a102 := ddx_complete_rec.rollup_transfered_in_amt;
    p1_a103 := ddx_complete_rec.rollup_transfered_out_amt;
    p1_a104 := ddx_complete_rec.rollup_holdback_amt;
    p1_a105 := ddx_complete_rec.rollup_planned_amt;
    p1_a106 := ddx_complete_rec.rollup_committed_amt;
    p1_a107 := ddx_complete_rec.rollup_earned_amt;
    p1_a108 := ddx_complete_rec.rollup_paid_amt;
    p1_a109 := ddx_complete_rec.rollup_recal_committed;
    p1_a110 := ddx_complete_rec.retroactive_flag;
    p1_a111 := ddx_complete_rec.qualifier_id;
    p1_a112 := ddx_complete_rec.prev_fund_id;
    p1_a113 := ddx_complete_rec.transfered_flag;
    p1_a114 := ddx_complete_rec.utilized_amt;
    p1_a115 := ddx_complete_rec.rollup_utilized_amt;
    p1_a116 := ddx_complete_rec.product_spread_time_id;
    p1_a117 := ddx_complete_rec.activation_date;
    p1_a118 := ddx_complete_rec.ledger_id;
  end;

  procedure check_fund_inter_entity(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  DATE
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  DATE
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  DATE
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p0_a105  NUMBER
    , p0_a106  NUMBER
    , p0_a107  NUMBER
    , p0_a108  NUMBER
    , p0_a109  NUMBER
    , p0_a110  VARCHAR2
    , p0_a111  NUMBER
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  NUMBER
    , p0_a116  NUMBER
    , p0_a117  DATE
    , p0_a118  NUMBER
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  VARCHAR2
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  DATE
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  DATE
    , p1_a21  DATE
    , p1_a22  VARCHAR2
    , p1_a23  NUMBER
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  NUMBER
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  VARCHAR2
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  VARCHAR2
    , p1_a52  NUMBER
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  NUMBER
    , p1_a60  NUMBER
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  VARCHAR2
    , p1_a66  VARCHAR2
    , p1_a67  VARCHAR2
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  VARCHAR2
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  VARCHAR2
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  VARCHAR2
    , p1_a83  NUMBER
    , p1_a84  VARCHAR2
    , p1_a85  VARCHAR2
    , p1_a86  VARCHAR2
    , p1_a87  VARCHAR2
    , p1_a88  NUMBER
    , p1_a89  NUMBER
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  NUMBER
    , p1_a93  NUMBER
    , p1_a94  NUMBER
    , p1_a95  VARCHAR2
    , p1_a96  VARCHAR2
    , p1_a97  DATE
    , p1_a98  NUMBER
    , p1_a99  NUMBER
    , p1_a100  NUMBER
    , p1_a101  NUMBER
    , p1_a102  NUMBER
    , p1_a103  NUMBER
    , p1_a104  NUMBER
    , p1_a105  NUMBER
    , p1_a106  NUMBER
    , p1_a107  NUMBER
    , p1_a108  NUMBER
    , p1_a109  NUMBER
    , p1_a110  VARCHAR2
    , p1_a111  NUMBER
    , p1_a112  NUMBER
    , p1_a113  VARCHAR2
    , p1_a114  NUMBER
    , p1_a115  NUMBER
    , p1_a116  NUMBER
    , p1_a117  DATE
    , p1_a118  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddp_complete_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_fund_rec.fund_id := p0_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_fund_rec.last_updated_by := p0_a2;
    ddp_fund_rec.last_update_login := p0_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_fund_rec.created_by := p0_a5;
    ddp_fund_rec.created_from := p0_a6;
    ddp_fund_rec.request_id := p0_a7;
    ddp_fund_rec.program_application_id := p0_a8;
    ddp_fund_rec.program_id := p0_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_fund_rec.fund_number := p0_a11;
    ddp_fund_rec.parent_fund_id := p0_a12;
    ddp_fund_rec.category_id := p0_a13;
    ddp_fund_rec.fund_type := p0_a14;
    ddp_fund_rec.status_code := p0_a15;
    ddp_fund_rec.user_status_id := p0_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_fund_rec.accrued_liable_account := p0_a18;
    ddp_fund_rec.ded_adjustment_account := p0_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a21);
    ddp_fund_rec.currency_code_tc := p0_a22;
    ddp_fund_rec.owner := p0_a23;
    ddp_fund_rec.hierarchy := p0_a24;
    ddp_fund_rec.hierarchy_level := p0_a25;
    ddp_fund_rec.hierarchy_id := p0_a26;
    ddp_fund_rec.parent_node_id := p0_a27;
    ddp_fund_rec.node_id := p0_a28;
    ddp_fund_rec.object_version_number := p0_a29;
    ddp_fund_rec.org_id := p0_a30;
    ddp_fund_rec.earned_flag := p0_a31;
    ddp_fund_rec.original_budget := p0_a32;
    ddp_fund_rec.transfered_in_amt := p0_a33;
    ddp_fund_rec.transfered_out_amt := p0_a34;
    ddp_fund_rec.holdback_amt := p0_a35;
    ddp_fund_rec.planned_amt := p0_a36;
    ddp_fund_rec.committed_amt := p0_a37;
    ddp_fund_rec.earned_amt := p0_a38;
    ddp_fund_rec.paid_amt := p0_a39;
    ddp_fund_rec.liable_accnt_segments := p0_a40;
    ddp_fund_rec.adjustment_accnt_segments := p0_a41;
    ddp_fund_rec.short_name := p0_a42;
    ddp_fund_rec.description := p0_a43;
    ddp_fund_rec.language := p0_a44;
    ddp_fund_rec.source_lang := p0_a45;
    ddp_fund_rec.start_period_name := p0_a46;
    ddp_fund_rec.end_period_name := p0_a47;
    ddp_fund_rec.fund_calendar := p0_a48;
    ddp_fund_rec.accrue_to_level_id := p0_a49;
    ddp_fund_rec.accrual_quantity := p0_a50;
    ddp_fund_rec.accrual_phase := p0_a51;
    ddp_fund_rec.accrual_cap := p0_a52;
    ddp_fund_rec.accrual_uom := p0_a53;
    ddp_fund_rec.accrual_method := p0_a54;
    ddp_fund_rec.accrual_operand := p0_a55;
    ddp_fund_rec.accrual_rate := p0_a56;
    ddp_fund_rec.accrual_basis := p0_a57;
    ddp_fund_rec.accrual_discount_level := p0_a58;
    ddp_fund_rec.custom_setup_id := p0_a59;
    ddp_fund_rec.threshold_id := p0_a60;
    ddp_fund_rec.business_unit_id := p0_a61;
    ddp_fund_rec.country_id := p0_a62;
    ddp_fund_rec.task_id := p0_a63;
    ddp_fund_rec.recal_committed := p0_a64;
    ddp_fund_rec.attribute_category := p0_a65;
    ddp_fund_rec.attribute1 := p0_a66;
    ddp_fund_rec.attribute2 := p0_a67;
    ddp_fund_rec.attribute3 := p0_a68;
    ddp_fund_rec.attribute4 := p0_a69;
    ddp_fund_rec.attribute5 := p0_a70;
    ddp_fund_rec.attribute6 := p0_a71;
    ddp_fund_rec.attribute7 := p0_a72;
    ddp_fund_rec.attribute8 := p0_a73;
    ddp_fund_rec.attribute9 := p0_a74;
    ddp_fund_rec.attribute10 := p0_a75;
    ddp_fund_rec.attribute11 := p0_a76;
    ddp_fund_rec.attribute12 := p0_a77;
    ddp_fund_rec.attribute13 := p0_a78;
    ddp_fund_rec.attribute14 := p0_a79;
    ddp_fund_rec.attribute15 := p0_a80;
    ddp_fund_rec.fund_usage := p0_a81;
    ddp_fund_rec.plan_type := p0_a82;
    ddp_fund_rec.plan_id := p0_a83;
    ddp_fund_rec.apply_accrual_on := p0_a84;
    ddp_fund_rec.level_value := p0_a85;
    ddp_fund_rec.budget_flag := p0_a86;
    ddp_fund_rec.liability_flag := p0_a87;
    ddp_fund_rec.set_of_books_id := p0_a88;
    ddp_fund_rec.start_period_id := p0_a89;
    ddp_fund_rec.end_period_id := p0_a90;
    ddp_fund_rec.budget_amount_tc := p0_a91;
    ddp_fund_rec.budget_amount_fc := p0_a92;
    ddp_fund_rec.available_amount := p0_a93;
    ddp_fund_rec.distributed_amount := p0_a94;
    ddp_fund_rec.currency_code_fc := p0_a95;
    ddp_fund_rec.exchange_rate_type := p0_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a97);
    ddp_fund_rec.exchange_rate := p0_a98;
    ddp_fund_rec.department_id := p0_a99;
    ddp_fund_rec.costcentre_id := p0_a100;
    ddp_fund_rec.rollup_original_budget := p0_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p0_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p0_a103;
    ddp_fund_rec.rollup_holdback_amt := p0_a104;
    ddp_fund_rec.rollup_planned_amt := p0_a105;
    ddp_fund_rec.rollup_committed_amt := p0_a106;
    ddp_fund_rec.rollup_earned_amt := p0_a107;
    ddp_fund_rec.rollup_paid_amt := p0_a108;
    ddp_fund_rec.rollup_recal_committed := p0_a109;
    ddp_fund_rec.retroactive_flag := p0_a110;
    ddp_fund_rec.qualifier_id := p0_a111;
    ddp_fund_rec.prev_fund_id := p0_a112;
    ddp_fund_rec.transfered_flag := p0_a113;
    ddp_fund_rec.utilized_amt := p0_a114;
    ddp_fund_rec.rollup_utilized_amt := p0_a115;
    ddp_fund_rec.product_spread_time_id := p0_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p0_a117);
    ddp_fund_rec.ledger_id := p0_a118;

    ddp_complete_rec.fund_id := p1_a0;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.last_update_login := p1_a3;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_rec.created_by := p1_a5;
    ddp_complete_rec.created_from := p1_a6;
    ddp_complete_rec.request_id := p1_a7;
    ddp_complete_rec.program_application_id := p1_a8;
    ddp_complete_rec.program_id := p1_a9;
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_complete_rec.fund_number := p1_a11;
    ddp_complete_rec.parent_fund_id := p1_a12;
    ddp_complete_rec.category_id := p1_a13;
    ddp_complete_rec.fund_type := p1_a14;
    ddp_complete_rec.status_code := p1_a15;
    ddp_complete_rec.user_status_id := p1_a16;
    ddp_complete_rec.status_date := rosetta_g_miss_date_in_map(p1_a17);
    ddp_complete_rec.accrued_liable_account := p1_a18;
    ddp_complete_rec.ded_adjustment_account := p1_a19;
    ddp_complete_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a20);
    ddp_complete_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a21);
    ddp_complete_rec.currency_code_tc := p1_a22;
    ddp_complete_rec.owner := p1_a23;
    ddp_complete_rec.hierarchy := p1_a24;
    ddp_complete_rec.hierarchy_level := p1_a25;
    ddp_complete_rec.hierarchy_id := p1_a26;
    ddp_complete_rec.parent_node_id := p1_a27;
    ddp_complete_rec.node_id := p1_a28;
    ddp_complete_rec.object_version_number := p1_a29;
    ddp_complete_rec.org_id := p1_a30;
    ddp_complete_rec.earned_flag := p1_a31;
    ddp_complete_rec.original_budget := p1_a32;
    ddp_complete_rec.transfered_in_amt := p1_a33;
    ddp_complete_rec.transfered_out_amt := p1_a34;
    ddp_complete_rec.holdback_amt := p1_a35;
    ddp_complete_rec.planned_amt := p1_a36;
    ddp_complete_rec.committed_amt := p1_a37;
    ddp_complete_rec.earned_amt := p1_a38;
    ddp_complete_rec.paid_amt := p1_a39;
    ddp_complete_rec.liable_accnt_segments := p1_a40;
    ddp_complete_rec.adjustment_accnt_segments := p1_a41;
    ddp_complete_rec.short_name := p1_a42;
    ddp_complete_rec.description := p1_a43;
    ddp_complete_rec.language := p1_a44;
    ddp_complete_rec.source_lang := p1_a45;
    ddp_complete_rec.start_period_name := p1_a46;
    ddp_complete_rec.end_period_name := p1_a47;
    ddp_complete_rec.fund_calendar := p1_a48;
    ddp_complete_rec.accrue_to_level_id := p1_a49;
    ddp_complete_rec.accrual_quantity := p1_a50;
    ddp_complete_rec.accrual_phase := p1_a51;
    ddp_complete_rec.accrual_cap := p1_a52;
    ddp_complete_rec.accrual_uom := p1_a53;
    ddp_complete_rec.accrual_method := p1_a54;
    ddp_complete_rec.accrual_operand := p1_a55;
    ddp_complete_rec.accrual_rate := p1_a56;
    ddp_complete_rec.accrual_basis := p1_a57;
    ddp_complete_rec.accrual_discount_level := p1_a58;
    ddp_complete_rec.custom_setup_id := p1_a59;
    ddp_complete_rec.threshold_id := p1_a60;
    ddp_complete_rec.business_unit_id := p1_a61;
    ddp_complete_rec.country_id := p1_a62;
    ddp_complete_rec.task_id := p1_a63;
    ddp_complete_rec.recal_committed := p1_a64;
    ddp_complete_rec.attribute_category := p1_a65;
    ddp_complete_rec.attribute1 := p1_a66;
    ddp_complete_rec.attribute2 := p1_a67;
    ddp_complete_rec.attribute3 := p1_a68;
    ddp_complete_rec.attribute4 := p1_a69;
    ddp_complete_rec.attribute5 := p1_a70;
    ddp_complete_rec.attribute6 := p1_a71;
    ddp_complete_rec.attribute7 := p1_a72;
    ddp_complete_rec.attribute8 := p1_a73;
    ddp_complete_rec.attribute9 := p1_a74;
    ddp_complete_rec.attribute10 := p1_a75;
    ddp_complete_rec.attribute11 := p1_a76;
    ddp_complete_rec.attribute12 := p1_a77;
    ddp_complete_rec.attribute13 := p1_a78;
    ddp_complete_rec.attribute14 := p1_a79;
    ddp_complete_rec.attribute15 := p1_a80;
    ddp_complete_rec.fund_usage := p1_a81;
    ddp_complete_rec.plan_type := p1_a82;
    ddp_complete_rec.plan_id := p1_a83;
    ddp_complete_rec.apply_accrual_on := p1_a84;
    ddp_complete_rec.level_value := p1_a85;
    ddp_complete_rec.budget_flag := p1_a86;
    ddp_complete_rec.liability_flag := p1_a87;
    ddp_complete_rec.set_of_books_id := p1_a88;
    ddp_complete_rec.start_period_id := p1_a89;
    ddp_complete_rec.end_period_id := p1_a90;
    ddp_complete_rec.budget_amount_tc := p1_a91;
    ddp_complete_rec.budget_amount_fc := p1_a92;
    ddp_complete_rec.available_amount := p1_a93;
    ddp_complete_rec.distributed_amount := p1_a94;
    ddp_complete_rec.currency_code_fc := p1_a95;
    ddp_complete_rec.exchange_rate_type := p1_a96;
    ddp_complete_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p1_a97);
    ddp_complete_rec.exchange_rate := p1_a98;
    ddp_complete_rec.department_id := p1_a99;
    ddp_complete_rec.costcentre_id := p1_a100;
    ddp_complete_rec.rollup_original_budget := p1_a101;
    ddp_complete_rec.rollup_transfered_in_amt := p1_a102;
    ddp_complete_rec.rollup_transfered_out_amt := p1_a103;
    ddp_complete_rec.rollup_holdback_amt := p1_a104;
    ddp_complete_rec.rollup_planned_amt := p1_a105;
    ddp_complete_rec.rollup_committed_amt := p1_a106;
    ddp_complete_rec.rollup_earned_amt := p1_a107;
    ddp_complete_rec.rollup_paid_amt := p1_a108;
    ddp_complete_rec.rollup_recal_committed := p1_a109;
    ddp_complete_rec.retroactive_flag := p1_a110;
    ddp_complete_rec.qualifier_id := p1_a111;
    ddp_complete_rec.prev_fund_id := p1_a112;
    ddp_complete_rec.transfered_flag := p1_a113;
    ddp_complete_rec.utilized_amt := p1_a114;
    ddp_complete_rec.rollup_utilized_amt := p1_a115;
    ddp_complete_rec.product_spread_time_id := p1_a116;
    ddp_complete_rec.activation_date := rosetta_g_miss_date_in_map(p1_a117);
    ddp_complete_rec.ledger_id := p1_a118;



    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.check_fund_inter_entity(ddp_fund_rec,
      ddp_complete_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure copy_fund(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_object_id  NUMBER
    , p_attributes_table JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , x_new_object_id out nocopy  NUMBER
    , x_custom_setup_id out nocopy  NUMBER
  )

  as
    ddp_attributes_table ams_cpyutility_pvt.copy_attributes_table_type;
    ddp_copy_columns_table ams_cpyutility_pvt.copy_columns_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_cpyutility_pvt_w.rosetta_table_copy_in_p0(ddp_attributes_table, p_attributes_table);

    ams_cpyutility_pvt_w.rosetta_table_copy_in_p2(ddp_copy_columns_table, p9_a0
      , p9_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.copy_fund(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_object_id,
      ddp_attributes_table,
      ddp_copy_columns_table,
      x_new_object_id,
      x_custom_setup_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_rollup_amount(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
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
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  DATE
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  NUMBER
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  NUMBER
    , p7_a109  NUMBER
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  NUMBER
    , p7_a115  NUMBER
    , p7_a116  NUMBER
    , p7_a117  DATE
    , p7_a118  NUMBER
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_fund_rec.fund_id := p7_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_fund_rec.last_updated_by := p7_a2;
    ddp_fund_rec.last_update_login := p7_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_fund_rec.created_by := p7_a5;
    ddp_fund_rec.created_from := p7_a6;
    ddp_fund_rec.request_id := p7_a7;
    ddp_fund_rec.program_application_id := p7_a8;
    ddp_fund_rec.program_id := p7_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_fund_rec.fund_number := p7_a11;
    ddp_fund_rec.parent_fund_id := p7_a12;
    ddp_fund_rec.category_id := p7_a13;
    ddp_fund_rec.fund_type := p7_a14;
    ddp_fund_rec.status_code := p7_a15;
    ddp_fund_rec.user_status_id := p7_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_fund_rec.accrued_liable_account := p7_a18;
    ddp_fund_rec.ded_adjustment_account := p7_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a21);
    ddp_fund_rec.currency_code_tc := p7_a22;
    ddp_fund_rec.owner := p7_a23;
    ddp_fund_rec.hierarchy := p7_a24;
    ddp_fund_rec.hierarchy_level := p7_a25;
    ddp_fund_rec.hierarchy_id := p7_a26;
    ddp_fund_rec.parent_node_id := p7_a27;
    ddp_fund_rec.node_id := p7_a28;
    ddp_fund_rec.object_version_number := p7_a29;
    ddp_fund_rec.org_id := p7_a30;
    ddp_fund_rec.earned_flag := p7_a31;
    ddp_fund_rec.original_budget := p7_a32;
    ddp_fund_rec.transfered_in_amt := p7_a33;
    ddp_fund_rec.transfered_out_amt := p7_a34;
    ddp_fund_rec.holdback_amt := p7_a35;
    ddp_fund_rec.planned_amt := p7_a36;
    ddp_fund_rec.committed_amt := p7_a37;
    ddp_fund_rec.earned_amt := p7_a38;
    ddp_fund_rec.paid_amt := p7_a39;
    ddp_fund_rec.liable_accnt_segments := p7_a40;
    ddp_fund_rec.adjustment_accnt_segments := p7_a41;
    ddp_fund_rec.short_name := p7_a42;
    ddp_fund_rec.description := p7_a43;
    ddp_fund_rec.language := p7_a44;
    ddp_fund_rec.source_lang := p7_a45;
    ddp_fund_rec.start_period_name := p7_a46;
    ddp_fund_rec.end_period_name := p7_a47;
    ddp_fund_rec.fund_calendar := p7_a48;
    ddp_fund_rec.accrue_to_level_id := p7_a49;
    ddp_fund_rec.accrual_quantity := p7_a50;
    ddp_fund_rec.accrual_phase := p7_a51;
    ddp_fund_rec.accrual_cap := p7_a52;
    ddp_fund_rec.accrual_uom := p7_a53;
    ddp_fund_rec.accrual_method := p7_a54;
    ddp_fund_rec.accrual_operand := p7_a55;
    ddp_fund_rec.accrual_rate := p7_a56;
    ddp_fund_rec.accrual_basis := p7_a57;
    ddp_fund_rec.accrual_discount_level := p7_a58;
    ddp_fund_rec.custom_setup_id := p7_a59;
    ddp_fund_rec.threshold_id := p7_a60;
    ddp_fund_rec.business_unit_id := p7_a61;
    ddp_fund_rec.country_id := p7_a62;
    ddp_fund_rec.task_id := p7_a63;
    ddp_fund_rec.recal_committed := p7_a64;
    ddp_fund_rec.attribute_category := p7_a65;
    ddp_fund_rec.attribute1 := p7_a66;
    ddp_fund_rec.attribute2 := p7_a67;
    ddp_fund_rec.attribute3 := p7_a68;
    ddp_fund_rec.attribute4 := p7_a69;
    ddp_fund_rec.attribute5 := p7_a70;
    ddp_fund_rec.attribute6 := p7_a71;
    ddp_fund_rec.attribute7 := p7_a72;
    ddp_fund_rec.attribute8 := p7_a73;
    ddp_fund_rec.attribute9 := p7_a74;
    ddp_fund_rec.attribute10 := p7_a75;
    ddp_fund_rec.attribute11 := p7_a76;
    ddp_fund_rec.attribute12 := p7_a77;
    ddp_fund_rec.attribute13 := p7_a78;
    ddp_fund_rec.attribute14 := p7_a79;
    ddp_fund_rec.attribute15 := p7_a80;
    ddp_fund_rec.fund_usage := p7_a81;
    ddp_fund_rec.plan_type := p7_a82;
    ddp_fund_rec.plan_id := p7_a83;
    ddp_fund_rec.apply_accrual_on := p7_a84;
    ddp_fund_rec.level_value := p7_a85;
    ddp_fund_rec.budget_flag := p7_a86;
    ddp_fund_rec.liability_flag := p7_a87;
    ddp_fund_rec.set_of_books_id := p7_a88;
    ddp_fund_rec.start_period_id := p7_a89;
    ddp_fund_rec.end_period_id := p7_a90;
    ddp_fund_rec.budget_amount_tc := p7_a91;
    ddp_fund_rec.budget_amount_fc := p7_a92;
    ddp_fund_rec.available_amount := p7_a93;
    ddp_fund_rec.distributed_amount := p7_a94;
    ddp_fund_rec.currency_code_fc := p7_a95;
    ddp_fund_rec.exchange_rate_type := p7_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a97);
    ddp_fund_rec.exchange_rate := p7_a98;
    ddp_fund_rec.department_id := p7_a99;
    ddp_fund_rec.costcentre_id := p7_a100;
    ddp_fund_rec.rollup_original_budget := p7_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p7_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p7_a103;
    ddp_fund_rec.rollup_holdback_amt := p7_a104;
    ddp_fund_rec.rollup_planned_amt := p7_a105;
    ddp_fund_rec.rollup_committed_amt := p7_a106;
    ddp_fund_rec.rollup_earned_amt := p7_a107;
    ddp_fund_rec.rollup_paid_amt := p7_a108;
    ddp_fund_rec.rollup_recal_committed := p7_a109;
    ddp_fund_rec.retroactive_flag := p7_a110;
    ddp_fund_rec.qualifier_id := p7_a111;
    ddp_fund_rec.prev_fund_id := p7_a112;
    ddp_fund_rec.transfered_flag := p7_a113;
    ddp_fund_rec.utilized_amt := p7_a114;
    ddp_fund_rec.rollup_utilized_amt := p7_a115;
    ddp_fund_rec.product_spread_time_id := p7_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p7_a117);
    ddp_fund_rec.ledger_id := p7_a118;

    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.update_rollup_amount(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fund_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_funds_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
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
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  DATE
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  NUMBER
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  NUMBER
    , p7_a109  NUMBER
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  NUMBER
    , p7_a115  NUMBER
    , p7_a116  NUMBER
    , p7_a117  DATE
    , p7_a118  NUMBER
    , p_mode  VARCHAR2
  )

  as
    ddp_fund_rec ozf_funds_pvt.fund_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_fund_rec.fund_id := p7_a0;
    ddp_fund_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_fund_rec.last_updated_by := p7_a2;
    ddp_fund_rec.last_update_login := p7_a3;
    ddp_fund_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_fund_rec.created_by := p7_a5;
    ddp_fund_rec.created_from := p7_a6;
    ddp_fund_rec.request_id := p7_a7;
    ddp_fund_rec.program_application_id := p7_a8;
    ddp_fund_rec.program_id := p7_a9;
    ddp_fund_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_fund_rec.fund_number := p7_a11;
    ddp_fund_rec.parent_fund_id := p7_a12;
    ddp_fund_rec.category_id := p7_a13;
    ddp_fund_rec.fund_type := p7_a14;
    ddp_fund_rec.status_code := p7_a15;
    ddp_fund_rec.user_status_id := p7_a16;
    ddp_fund_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_fund_rec.accrued_liable_account := p7_a18;
    ddp_fund_rec.ded_adjustment_account := p7_a19;
    ddp_fund_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a20);
    ddp_fund_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a21);
    ddp_fund_rec.currency_code_tc := p7_a22;
    ddp_fund_rec.owner := p7_a23;
    ddp_fund_rec.hierarchy := p7_a24;
    ddp_fund_rec.hierarchy_level := p7_a25;
    ddp_fund_rec.hierarchy_id := p7_a26;
    ddp_fund_rec.parent_node_id := p7_a27;
    ddp_fund_rec.node_id := p7_a28;
    ddp_fund_rec.object_version_number := p7_a29;
    ddp_fund_rec.org_id := p7_a30;
    ddp_fund_rec.earned_flag := p7_a31;
    ddp_fund_rec.original_budget := p7_a32;
    ddp_fund_rec.transfered_in_amt := p7_a33;
    ddp_fund_rec.transfered_out_amt := p7_a34;
    ddp_fund_rec.holdback_amt := p7_a35;
    ddp_fund_rec.planned_amt := p7_a36;
    ddp_fund_rec.committed_amt := p7_a37;
    ddp_fund_rec.earned_amt := p7_a38;
    ddp_fund_rec.paid_amt := p7_a39;
    ddp_fund_rec.liable_accnt_segments := p7_a40;
    ddp_fund_rec.adjustment_accnt_segments := p7_a41;
    ddp_fund_rec.short_name := p7_a42;
    ddp_fund_rec.description := p7_a43;
    ddp_fund_rec.language := p7_a44;
    ddp_fund_rec.source_lang := p7_a45;
    ddp_fund_rec.start_period_name := p7_a46;
    ddp_fund_rec.end_period_name := p7_a47;
    ddp_fund_rec.fund_calendar := p7_a48;
    ddp_fund_rec.accrue_to_level_id := p7_a49;
    ddp_fund_rec.accrual_quantity := p7_a50;
    ddp_fund_rec.accrual_phase := p7_a51;
    ddp_fund_rec.accrual_cap := p7_a52;
    ddp_fund_rec.accrual_uom := p7_a53;
    ddp_fund_rec.accrual_method := p7_a54;
    ddp_fund_rec.accrual_operand := p7_a55;
    ddp_fund_rec.accrual_rate := p7_a56;
    ddp_fund_rec.accrual_basis := p7_a57;
    ddp_fund_rec.accrual_discount_level := p7_a58;
    ddp_fund_rec.custom_setup_id := p7_a59;
    ddp_fund_rec.threshold_id := p7_a60;
    ddp_fund_rec.business_unit_id := p7_a61;
    ddp_fund_rec.country_id := p7_a62;
    ddp_fund_rec.task_id := p7_a63;
    ddp_fund_rec.recal_committed := p7_a64;
    ddp_fund_rec.attribute_category := p7_a65;
    ddp_fund_rec.attribute1 := p7_a66;
    ddp_fund_rec.attribute2 := p7_a67;
    ddp_fund_rec.attribute3 := p7_a68;
    ddp_fund_rec.attribute4 := p7_a69;
    ddp_fund_rec.attribute5 := p7_a70;
    ddp_fund_rec.attribute6 := p7_a71;
    ddp_fund_rec.attribute7 := p7_a72;
    ddp_fund_rec.attribute8 := p7_a73;
    ddp_fund_rec.attribute9 := p7_a74;
    ddp_fund_rec.attribute10 := p7_a75;
    ddp_fund_rec.attribute11 := p7_a76;
    ddp_fund_rec.attribute12 := p7_a77;
    ddp_fund_rec.attribute13 := p7_a78;
    ddp_fund_rec.attribute14 := p7_a79;
    ddp_fund_rec.attribute15 := p7_a80;
    ddp_fund_rec.fund_usage := p7_a81;
    ddp_fund_rec.plan_type := p7_a82;
    ddp_fund_rec.plan_id := p7_a83;
    ddp_fund_rec.apply_accrual_on := p7_a84;
    ddp_fund_rec.level_value := p7_a85;
    ddp_fund_rec.budget_flag := p7_a86;
    ddp_fund_rec.liability_flag := p7_a87;
    ddp_fund_rec.set_of_books_id := p7_a88;
    ddp_fund_rec.start_period_id := p7_a89;
    ddp_fund_rec.end_period_id := p7_a90;
    ddp_fund_rec.budget_amount_tc := p7_a91;
    ddp_fund_rec.budget_amount_fc := p7_a92;
    ddp_fund_rec.available_amount := p7_a93;
    ddp_fund_rec.distributed_amount := p7_a94;
    ddp_fund_rec.currency_code_fc := p7_a95;
    ddp_fund_rec.exchange_rate_type := p7_a96;
    ddp_fund_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a97);
    ddp_fund_rec.exchange_rate := p7_a98;
    ddp_fund_rec.department_id := p7_a99;
    ddp_fund_rec.costcentre_id := p7_a100;
    ddp_fund_rec.rollup_original_budget := p7_a101;
    ddp_fund_rec.rollup_transfered_in_amt := p7_a102;
    ddp_fund_rec.rollup_transfered_out_amt := p7_a103;
    ddp_fund_rec.rollup_holdback_amt := p7_a104;
    ddp_fund_rec.rollup_planned_amt := p7_a105;
    ddp_fund_rec.rollup_committed_amt := p7_a106;
    ddp_fund_rec.rollup_earned_amt := p7_a107;
    ddp_fund_rec.rollup_paid_amt := p7_a108;
    ddp_fund_rec.rollup_recal_committed := p7_a109;
    ddp_fund_rec.retroactive_flag := p7_a110;
    ddp_fund_rec.qualifier_id := p7_a111;
    ddp_fund_rec.prev_fund_id := p7_a112;
    ddp_fund_rec.transfered_flag := p7_a113;
    ddp_fund_rec.utilized_amt := p7_a114;
    ddp_fund_rec.rollup_utilized_amt := p7_a115;
    ddp_fund_rec.product_spread_time_id := p7_a116;
    ddp_fund_rec.activation_date := rosetta_g_miss_date_in_map(p7_a117);
    ddp_fund_rec.ledger_id := p7_a118;


    -- here's the delegated call to the old PL/SQL routine
    ozf_funds_pvt.update_funds_access(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fund_rec,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ozf_funds_pvt_w;

/
