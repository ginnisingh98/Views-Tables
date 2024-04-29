--------------------------------------------------------
--  DDL for Package Body OZF_FUND_UTILIZED_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_UTILIZED_PVT_W" as
  /* $Header: ozfwfutb.pls 120.7.12010000.2 2008/08/14 15:43:13 nirprasa ship $ */
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

  procedure create_utilization(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_create_gl_entry  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  DATE
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  DATE
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  VARCHAR2
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  DATE
    , p8_a26  NUMBER
    , p8_a27  VARCHAR2
    , p8_a28  DATE
    , p8_a29  NUMBER
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  VARCHAR2
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  NUMBER
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  NUMBER
    , p8_a51  NUMBER
    , p8_a52  DATE
    , p8_a53  VARCHAR2
    , p8_a54  NUMBER
    , p8_a55  NUMBER
    , p8_a56  NUMBER
    , p8_a57  NUMBER
    , p8_a58  NUMBER
    , p8_a59  NUMBER
    , p8_a60  NUMBER
    , p8_a61  NUMBER
    , p8_a62  NUMBER
    , p8_a63  NUMBER
    , p8_a64  NUMBER
    , p8_a65  NUMBER
    , p8_a66  NUMBER
    , p8_a67  VARCHAR2
    , p8_a68  NUMBER
    , p8_a69  VARCHAR2
    , p8_a70  NUMBER
    , p8_a71  NUMBER
    , p8_a72  NUMBER
    , p8_a73  NUMBER
    , p8_a74  NUMBER
    , p8_a75  NUMBER
    , p8_a76  NUMBER
    , p8_a77  NUMBER
    , p8_a78  NUMBER
    , p8_a79  NUMBER
    , x_utilization_id out nocopy  NUMBER
  )

  as
    ddp_utilization_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_utilization_rec.utilization_id := p8_a0;
    ddp_utilization_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a1);
    ddp_utilization_rec.last_updated_by := p8_a2;
    ddp_utilization_rec.last_update_login := p8_a3;
    ddp_utilization_rec.creation_date := rosetta_g_miss_date_in_map(p8_a4);
    ddp_utilization_rec.created_by := p8_a5;
    ddp_utilization_rec.created_from := p8_a6;
    ddp_utilization_rec.request_id := p8_a7;
    ddp_utilization_rec.program_application_id := p8_a8;
    ddp_utilization_rec.program_id := p8_a9;
    ddp_utilization_rec.program_update_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_utilization_rec.utilization_type := p8_a11;
    ddp_utilization_rec.fund_id := p8_a12;
    ddp_utilization_rec.plan_type := p8_a13;
    ddp_utilization_rec.plan_id := p8_a14;
    ddp_utilization_rec.component_type := p8_a15;
    ddp_utilization_rec.component_id := p8_a16;
    ddp_utilization_rec.object_type := p8_a17;
    ddp_utilization_rec.object_id := p8_a18;
    ddp_utilization_rec.order_id := p8_a19;
    ddp_utilization_rec.invoice_id := p8_a20;
    ddp_utilization_rec.amount := p8_a21;
    ddp_utilization_rec.acctd_amount := p8_a22;
    ddp_utilization_rec.currency_code := p8_a23;
    ddp_utilization_rec.exchange_rate_type := p8_a24;
    ddp_utilization_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p8_a25);
    ddp_utilization_rec.exchange_rate := p8_a26;
    ddp_utilization_rec.adjustment_type := p8_a27;
    ddp_utilization_rec.adjustment_date := rosetta_g_miss_date_in_map(p8_a28);
    ddp_utilization_rec.object_version_number := p8_a29;
    ddp_utilization_rec.attribute_category := p8_a30;
    ddp_utilization_rec.attribute1 := p8_a31;
    ddp_utilization_rec.attribute2 := p8_a32;
    ddp_utilization_rec.attribute3 := p8_a33;
    ddp_utilization_rec.attribute4 := p8_a34;
    ddp_utilization_rec.attribute5 := p8_a35;
    ddp_utilization_rec.attribute6 := p8_a36;
    ddp_utilization_rec.attribute7 := p8_a37;
    ddp_utilization_rec.attribute8 := p8_a38;
    ddp_utilization_rec.attribute9 := p8_a39;
    ddp_utilization_rec.attribute10 := p8_a40;
    ddp_utilization_rec.attribute11 := p8_a41;
    ddp_utilization_rec.attribute12 := p8_a42;
    ddp_utilization_rec.attribute13 := p8_a43;
    ddp_utilization_rec.attribute14 := p8_a44;
    ddp_utilization_rec.attribute15 := p8_a45;
    ddp_utilization_rec.org_id := p8_a46;
    ddp_utilization_rec.adjustment_desc := p8_a47;
    ddp_utilization_rec.language := p8_a48;
    ddp_utilization_rec.source_lang := p8_a49;
    ddp_utilization_rec.camp_schedule_id := p8_a50;
    ddp_utilization_rec.adjustment_type_id := p8_a51;
    ddp_utilization_rec.gl_date := rosetta_g_miss_date_in_map(p8_a52);
    ddp_utilization_rec.product_level_type := p8_a53;
    ddp_utilization_rec.product_id := p8_a54;
    ddp_utilization_rec.ams_activity_budget_id := p8_a55;
    ddp_utilization_rec.amount_remaining := p8_a56;
    ddp_utilization_rec.acctd_amount_remaining := p8_a57;
    ddp_utilization_rec.cust_account_id := p8_a58;
    ddp_utilization_rec.price_adjustment_id := p8_a59;
    ddp_utilization_rec.plan_curr_amount := p8_a60;
    ddp_utilization_rec.plan_curr_amount_remaining := p8_a61;
    ddp_utilization_rec.scan_unit := p8_a62;
    ddp_utilization_rec.scan_unit_remaining := p8_a63;
    ddp_utilization_rec.activity_product_id := p8_a64;
    ddp_utilization_rec.scan_data_id := p8_a65;
    ddp_utilization_rec.volume_offer_tiers_id := p8_a66;
    ddp_utilization_rec.gl_posted_flag := p8_a67;
    ddp_utilization_rec.billto_cust_account_id := p8_a68;
    ddp_utilization_rec.reference_type := p8_a69;
    ddp_utilization_rec.reference_id := p8_a70;
    ddp_utilization_rec.order_line_id := p8_a71;
    ddp_utilization_rec.orig_utilization_id := p8_a72;
    ddp_utilization_rec.bill_to_site_use_id := p8_a73;
    ddp_utilization_rec.ship_to_site_use_id := p8_a74;
    ddp_utilization_rec.univ_curr_amount := p8_a75;
    ddp_utilization_rec.univ_curr_amount_remaining := p8_a76;
    ddp_utilization_rec.gl_account_credit := p8_a77;
    ddp_utilization_rec.gl_account_debit := p8_a78;
    ddp_utilization_rec.site_use_id := p8_a79;


    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_utilized_pvt.create_utilization(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_create_gl_entry,
      ddp_utilization_rec,
      x_utilization_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_utilization(p_api_version  NUMBER
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
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  VARCHAR2
    , p7_a28  DATE
    , p7_a29  NUMBER
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
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  DATE
    , p7_a53  VARCHAR2
    , p7_a54  NUMBER
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  VARCHAR2
    , p7_a68  NUMBER
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  NUMBER
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  NUMBER
    , p7_a75  NUMBER
    , p7_a76  NUMBER
    , p7_a77  NUMBER
    , p7_a78  NUMBER
    , p7_a79  NUMBER
    , p_mode  VARCHAR2
  )

  as
    ddp_utilization_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_utilization_rec.utilization_id := p7_a0;
    ddp_utilization_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_utilization_rec.last_updated_by := p7_a2;
    ddp_utilization_rec.last_update_login := p7_a3;
    ddp_utilization_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_utilization_rec.created_by := p7_a5;
    ddp_utilization_rec.created_from := p7_a6;
    ddp_utilization_rec.request_id := p7_a7;
    ddp_utilization_rec.program_application_id := p7_a8;
    ddp_utilization_rec.program_id := p7_a9;
    ddp_utilization_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_utilization_rec.utilization_type := p7_a11;
    ddp_utilization_rec.fund_id := p7_a12;
    ddp_utilization_rec.plan_type := p7_a13;
    ddp_utilization_rec.plan_id := p7_a14;
    ddp_utilization_rec.component_type := p7_a15;
    ddp_utilization_rec.component_id := p7_a16;
    ddp_utilization_rec.object_type := p7_a17;
    ddp_utilization_rec.object_id := p7_a18;
    ddp_utilization_rec.order_id := p7_a19;
    ddp_utilization_rec.invoice_id := p7_a20;
    ddp_utilization_rec.amount := p7_a21;
    ddp_utilization_rec.acctd_amount := p7_a22;
    ddp_utilization_rec.currency_code := p7_a23;
    ddp_utilization_rec.exchange_rate_type := p7_a24;
    ddp_utilization_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a25);
    ddp_utilization_rec.exchange_rate := p7_a26;
    ddp_utilization_rec.adjustment_type := p7_a27;
    ddp_utilization_rec.adjustment_date := rosetta_g_miss_date_in_map(p7_a28);
    ddp_utilization_rec.object_version_number := p7_a29;
    ddp_utilization_rec.attribute_category := p7_a30;
    ddp_utilization_rec.attribute1 := p7_a31;
    ddp_utilization_rec.attribute2 := p7_a32;
    ddp_utilization_rec.attribute3 := p7_a33;
    ddp_utilization_rec.attribute4 := p7_a34;
    ddp_utilization_rec.attribute5 := p7_a35;
    ddp_utilization_rec.attribute6 := p7_a36;
    ddp_utilization_rec.attribute7 := p7_a37;
    ddp_utilization_rec.attribute8 := p7_a38;
    ddp_utilization_rec.attribute9 := p7_a39;
    ddp_utilization_rec.attribute10 := p7_a40;
    ddp_utilization_rec.attribute11 := p7_a41;
    ddp_utilization_rec.attribute12 := p7_a42;
    ddp_utilization_rec.attribute13 := p7_a43;
    ddp_utilization_rec.attribute14 := p7_a44;
    ddp_utilization_rec.attribute15 := p7_a45;
    ddp_utilization_rec.org_id := p7_a46;
    ddp_utilization_rec.adjustment_desc := p7_a47;
    ddp_utilization_rec.language := p7_a48;
    ddp_utilization_rec.source_lang := p7_a49;
    ddp_utilization_rec.camp_schedule_id := p7_a50;
    ddp_utilization_rec.adjustment_type_id := p7_a51;
    ddp_utilization_rec.gl_date := rosetta_g_miss_date_in_map(p7_a52);
    ddp_utilization_rec.product_level_type := p7_a53;
    ddp_utilization_rec.product_id := p7_a54;
    ddp_utilization_rec.ams_activity_budget_id := p7_a55;
    ddp_utilization_rec.amount_remaining := p7_a56;
    ddp_utilization_rec.acctd_amount_remaining := p7_a57;
    ddp_utilization_rec.cust_account_id := p7_a58;
    ddp_utilization_rec.price_adjustment_id := p7_a59;
    ddp_utilization_rec.plan_curr_amount := p7_a60;
    ddp_utilization_rec.plan_curr_amount_remaining := p7_a61;
    ddp_utilization_rec.scan_unit := p7_a62;
    ddp_utilization_rec.scan_unit_remaining := p7_a63;
    ddp_utilization_rec.activity_product_id := p7_a64;
    ddp_utilization_rec.scan_data_id := p7_a65;
    ddp_utilization_rec.volume_offer_tiers_id := p7_a66;
    ddp_utilization_rec.gl_posted_flag := p7_a67;
    ddp_utilization_rec.billto_cust_account_id := p7_a68;
    ddp_utilization_rec.reference_type := p7_a69;
    ddp_utilization_rec.reference_id := p7_a70;
    ddp_utilization_rec.order_line_id := p7_a71;
    ddp_utilization_rec.orig_utilization_id := p7_a72;
    ddp_utilization_rec.bill_to_site_use_id := p7_a73;
    ddp_utilization_rec.ship_to_site_use_id := p7_a74;
    ddp_utilization_rec.univ_curr_amount := p7_a75;
    ddp_utilization_rec.univ_curr_amount_remaining := p7_a76;
    ddp_utilization_rec.gl_account_credit := p7_a77;
    ddp_utilization_rec.gl_account_debit := p7_a78;
    ddp_utilization_rec.site_use_id := p7_a79;


    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_utilized_pvt.update_utilization(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_utilization_rec,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_utilization(p_api_version  NUMBER
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
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  VARCHAR2
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  DATE
    , p6_a26  NUMBER
    , p6_a27  VARCHAR2
    , p6_a28  DATE
    , p6_a29  NUMBER
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  NUMBER
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  NUMBER
    , p6_a51  NUMBER
    , p6_a52  DATE
    , p6_a53  VARCHAR2
    , p6_a54  NUMBER
    , p6_a55  NUMBER
    , p6_a56  NUMBER
    , p6_a57  NUMBER
    , p6_a58  NUMBER
    , p6_a59  NUMBER
    , p6_a60  NUMBER
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  VARCHAR2
    , p6_a68  NUMBER
    , p6_a69  VARCHAR2
    , p6_a70  NUMBER
    , p6_a71  NUMBER
    , p6_a72  NUMBER
    , p6_a73  NUMBER
    , p6_a74  NUMBER
    , p6_a75  NUMBER
    , p6_a76  NUMBER
    , p6_a77  NUMBER
    , p6_a78  NUMBER
    , p6_a79  NUMBER
  )

  as
    ddp_utilization_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_utilization_rec.utilization_id := p6_a0;
    ddp_utilization_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_utilization_rec.last_updated_by := p6_a2;
    ddp_utilization_rec.last_update_login := p6_a3;
    ddp_utilization_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_utilization_rec.created_by := p6_a5;
    ddp_utilization_rec.created_from := p6_a6;
    ddp_utilization_rec.request_id := p6_a7;
    ddp_utilization_rec.program_application_id := p6_a8;
    ddp_utilization_rec.program_id := p6_a9;
    ddp_utilization_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_utilization_rec.utilization_type := p6_a11;
    ddp_utilization_rec.fund_id := p6_a12;
    ddp_utilization_rec.plan_type := p6_a13;
    ddp_utilization_rec.plan_id := p6_a14;
    ddp_utilization_rec.component_type := p6_a15;
    ddp_utilization_rec.component_id := p6_a16;
    ddp_utilization_rec.object_type := p6_a17;
    ddp_utilization_rec.object_id := p6_a18;
    ddp_utilization_rec.order_id := p6_a19;
    ddp_utilization_rec.invoice_id := p6_a20;
    ddp_utilization_rec.amount := p6_a21;
    ddp_utilization_rec.acctd_amount := p6_a22;
    ddp_utilization_rec.currency_code := p6_a23;
    ddp_utilization_rec.exchange_rate_type := p6_a24;
    ddp_utilization_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p6_a25);
    ddp_utilization_rec.exchange_rate := p6_a26;
    ddp_utilization_rec.adjustment_type := p6_a27;
    ddp_utilization_rec.adjustment_date := rosetta_g_miss_date_in_map(p6_a28);
    ddp_utilization_rec.object_version_number := p6_a29;
    ddp_utilization_rec.attribute_category := p6_a30;
    ddp_utilization_rec.attribute1 := p6_a31;
    ddp_utilization_rec.attribute2 := p6_a32;
    ddp_utilization_rec.attribute3 := p6_a33;
    ddp_utilization_rec.attribute4 := p6_a34;
    ddp_utilization_rec.attribute5 := p6_a35;
    ddp_utilization_rec.attribute6 := p6_a36;
    ddp_utilization_rec.attribute7 := p6_a37;
    ddp_utilization_rec.attribute8 := p6_a38;
    ddp_utilization_rec.attribute9 := p6_a39;
    ddp_utilization_rec.attribute10 := p6_a40;
    ddp_utilization_rec.attribute11 := p6_a41;
    ddp_utilization_rec.attribute12 := p6_a42;
    ddp_utilization_rec.attribute13 := p6_a43;
    ddp_utilization_rec.attribute14 := p6_a44;
    ddp_utilization_rec.attribute15 := p6_a45;
    ddp_utilization_rec.org_id := p6_a46;
    ddp_utilization_rec.adjustment_desc := p6_a47;
    ddp_utilization_rec.language := p6_a48;
    ddp_utilization_rec.source_lang := p6_a49;
    ddp_utilization_rec.camp_schedule_id := p6_a50;
    ddp_utilization_rec.adjustment_type_id := p6_a51;
    ddp_utilization_rec.gl_date := rosetta_g_miss_date_in_map(p6_a52);
    ddp_utilization_rec.product_level_type := p6_a53;
    ddp_utilization_rec.product_id := p6_a54;
    ddp_utilization_rec.ams_activity_budget_id := p6_a55;
    ddp_utilization_rec.amount_remaining := p6_a56;
    ddp_utilization_rec.acctd_amount_remaining := p6_a57;
    ddp_utilization_rec.cust_account_id := p6_a58;
    ddp_utilization_rec.price_adjustment_id := p6_a59;
    ddp_utilization_rec.plan_curr_amount := p6_a60;
    ddp_utilization_rec.plan_curr_amount_remaining := p6_a61;
    ddp_utilization_rec.scan_unit := p6_a62;
    ddp_utilization_rec.scan_unit_remaining := p6_a63;
    ddp_utilization_rec.activity_product_id := p6_a64;
    ddp_utilization_rec.scan_data_id := p6_a65;
    ddp_utilization_rec.volume_offer_tiers_id := p6_a66;
    ddp_utilization_rec.gl_posted_flag := p6_a67;
    ddp_utilization_rec.billto_cust_account_id := p6_a68;
    ddp_utilization_rec.reference_type := p6_a69;
    ddp_utilization_rec.reference_id := p6_a70;
    ddp_utilization_rec.order_line_id := p6_a71;
    ddp_utilization_rec.orig_utilization_id := p6_a72;
    ddp_utilization_rec.bill_to_site_use_id := p6_a73;
    ddp_utilization_rec.ship_to_site_use_id := p6_a74;
    ddp_utilization_rec.univ_curr_amount := p6_a75;
    ddp_utilization_rec.univ_curr_amount_remaining := p6_a76;
    ddp_utilization_rec.gl_account_credit := p6_a77;
    ddp_utilization_rec.gl_account_debit := p6_a78;
    ddp_utilization_rec.site_use_id := p6_a79;

    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_utilized_pvt.validate_utilization(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_utilization_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_utilization_items(p_validation_mode  VARCHAR2
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
    , p2_a13  VARCHAR2
    , p2_a14  NUMBER
    , p2_a15  VARCHAR2
    , p2_a16  NUMBER
    , p2_a17  VARCHAR2
    , p2_a18  NUMBER
    , p2_a19  NUMBER
    , p2_a20  NUMBER
    , p2_a21  NUMBER
    , p2_a22  NUMBER
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  DATE
    , p2_a26  NUMBER
    , p2_a27  VARCHAR2
    , p2_a28  DATE
    , p2_a29  NUMBER
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  NUMBER
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  VARCHAR2
    , p2_a50  NUMBER
    , p2_a51  NUMBER
    , p2_a52  DATE
    , p2_a53  VARCHAR2
    , p2_a54  NUMBER
    , p2_a55  NUMBER
    , p2_a56  NUMBER
    , p2_a57  NUMBER
    , p2_a58  NUMBER
    , p2_a59  NUMBER
    , p2_a60  NUMBER
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  NUMBER
    , p2_a65  NUMBER
    , p2_a66  NUMBER
    , p2_a67  VARCHAR2
    , p2_a68  NUMBER
    , p2_a69  VARCHAR2
    , p2_a70  NUMBER
    , p2_a71  NUMBER
    , p2_a72  NUMBER
    , p2_a73  NUMBER
    , p2_a74  NUMBER
    , p2_a75  NUMBER
    , p2_a76  NUMBER
    , p2_a77  NUMBER
    , p2_a78  NUMBER
    , p2_a79  NUMBER
  )

  as
    ddp_utilization_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_utilization_rec.utilization_id := p2_a0;
    ddp_utilization_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_utilization_rec.last_updated_by := p2_a2;
    ddp_utilization_rec.last_update_login := p2_a3;
    ddp_utilization_rec.creation_date := rosetta_g_miss_date_in_map(p2_a4);
    ddp_utilization_rec.created_by := p2_a5;
    ddp_utilization_rec.created_from := p2_a6;
    ddp_utilization_rec.request_id := p2_a7;
    ddp_utilization_rec.program_application_id := p2_a8;
    ddp_utilization_rec.program_id := p2_a9;
    ddp_utilization_rec.program_update_date := rosetta_g_miss_date_in_map(p2_a10);
    ddp_utilization_rec.utilization_type := p2_a11;
    ddp_utilization_rec.fund_id := p2_a12;
    ddp_utilization_rec.plan_type := p2_a13;
    ddp_utilization_rec.plan_id := p2_a14;
    ddp_utilization_rec.component_type := p2_a15;
    ddp_utilization_rec.component_id := p2_a16;
    ddp_utilization_rec.object_type := p2_a17;
    ddp_utilization_rec.object_id := p2_a18;
    ddp_utilization_rec.order_id := p2_a19;
    ddp_utilization_rec.invoice_id := p2_a20;
    ddp_utilization_rec.amount := p2_a21;
    ddp_utilization_rec.acctd_amount := p2_a22;
    ddp_utilization_rec.currency_code := p2_a23;
    ddp_utilization_rec.exchange_rate_type := p2_a24;
    ddp_utilization_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p2_a25);
    ddp_utilization_rec.exchange_rate := p2_a26;
    ddp_utilization_rec.adjustment_type := p2_a27;
    ddp_utilization_rec.adjustment_date := rosetta_g_miss_date_in_map(p2_a28);
    ddp_utilization_rec.object_version_number := p2_a29;
    ddp_utilization_rec.attribute_category := p2_a30;
    ddp_utilization_rec.attribute1 := p2_a31;
    ddp_utilization_rec.attribute2 := p2_a32;
    ddp_utilization_rec.attribute3 := p2_a33;
    ddp_utilization_rec.attribute4 := p2_a34;
    ddp_utilization_rec.attribute5 := p2_a35;
    ddp_utilization_rec.attribute6 := p2_a36;
    ddp_utilization_rec.attribute7 := p2_a37;
    ddp_utilization_rec.attribute8 := p2_a38;
    ddp_utilization_rec.attribute9 := p2_a39;
    ddp_utilization_rec.attribute10 := p2_a40;
    ddp_utilization_rec.attribute11 := p2_a41;
    ddp_utilization_rec.attribute12 := p2_a42;
    ddp_utilization_rec.attribute13 := p2_a43;
    ddp_utilization_rec.attribute14 := p2_a44;
    ddp_utilization_rec.attribute15 := p2_a45;
    ddp_utilization_rec.org_id := p2_a46;
    ddp_utilization_rec.adjustment_desc := p2_a47;
    ddp_utilization_rec.language := p2_a48;
    ddp_utilization_rec.source_lang := p2_a49;
    ddp_utilization_rec.camp_schedule_id := p2_a50;
    ddp_utilization_rec.adjustment_type_id := p2_a51;
    ddp_utilization_rec.gl_date := rosetta_g_miss_date_in_map(p2_a52);
    ddp_utilization_rec.product_level_type := p2_a53;
    ddp_utilization_rec.product_id := p2_a54;
    ddp_utilization_rec.ams_activity_budget_id := p2_a55;
    ddp_utilization_rec.amount_remaining := p2_a56;
    ddp_utilization_rec.acctd_amount_remaining := p2_a57;
    ddp_utilization_rec.cust_account_id := p2_a58;
    ddp_utilization_rec.price_adjustment_id := p2_a59;
    ddp_utilization_rec.plan_curr_amount := p2_a60;
    ddp_utilization_rec.plan_curr_amount_remaining := p2_a61;
    ddp_utilization_rec.scan_unit := p2_a62;
    ddp_utilization_rec.scan_unit_remaining := p2_a63;
    ddp_utilization_rec.activity_product_id := p2_a64;
    ddp_utilization_rec.scan_data_id := p2_a65;
    ddp_utilization_rec.volume_offer_tiers_id := p2_a66;
    ddp_utilization_rec.gl_posted_flag := p2_a67;
    ddp_utilization_rec.billto_cust_account_id := p2_a68;
    ddp_utilization_rec.reference_type := p2_a69;
    ddp_utilization_rec.reference_id := p2_a70;
    ddp_utilization_rec.order_line_id := p2_a71;
    ddp_utilization_rec.orig_utilization_id := p2_a72;
    ddp_utilization_rec.bill_to_site_use_id := p2_a73;
    ddp_utilization_rec.ship_to_site_use_id := p2_a74;
    ddp_utilization_rec.univ_curr_amount := p2_a75;
    ddp_utilization_rec.univ_curr_amount_remaining := p2_a76;
    ddp_utilization_rec.gl_account_credit := p2_a77;
    ddp_utilization_rec.gl_account_debit := p2_a78;
    ddp_utilization_rec.site_use_id := p2_a79;

    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_utilized_pvt.check_utilization_items(p_validation_mode,
      x_return_status,
      ddp_utilization_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_utilization_record(p0_a0  NUMBER
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
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  DATE
    , p0_a26  NUMBER
    , p0_a27  VARCHAR2
    , p0_a28  DATE
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  VARCHAR2
    , p0_a68  NUMBER
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  NUMBER
    , p0_a75  NUMBER
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  NUMBER
    , p0_a79  NUMBER
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
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  VARCHAR2
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  DATE
    , p1_a26  NUMBER
    , p1_a27  VARCHAR2
    , p1_a28  DATE
    , p1_a29  NUMBER
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p1_a32  VARCHAR2
    , p1_a33  VARCHAR2
    , p1_a34  VARCHAR2
    , p1_a35  VARCHAR2
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
    , p1_a46  NUMBER
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  NUMBER
    , p1_a51  NUMBER
    , p1_a52  DATE
    , p1_a53  VARCHAR2
    , p1_a54  NUMBER
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  NUMBER
    , p1_a58  NUMBER
    , p1_a59  NUMBER
    , p1_a60  NUMBER
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  NUMBER
    , p1_a67  VARCHAR2
    , p1_a68  NUMBER
    , p1_a69  VARCHAR2
    , p1_a70  NUMBER
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  NUMBER
    , p1_a77  NUMBER
    , p1_a78  NUMBER
    , p1_a79  NUMBER
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_utilization_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddp_complete_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_utilization_rec.utilization_id := p0_a0;
    ddp_utilization_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_utilization_rec.last_updated_by := p0_a2;
    ddp_utilization_rec.last_update_login := p0_a3;
    ddp_utilization_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_utilization_rec.created_by := p0_a5;
    ddp_utilization_rec.created_from := p0_a6;
    ddp_utilization_rec.request_id := p0_a7;
    ddp_utilization_rec.program_application_id := p0_a8;
    ddp_utilization_rec.program_id := p0_a9;
    ddp_utilization_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_utilization_rec.utilization_type := p0_a11;
    ddp_utilization_rec.fund_id := p0_a12;
    ddp_utilization_rec.plan_type := p0_a13;
    ddp_utilization_rec.plan_id := p0_a14;
    ddp_utilization_rec.component_type := p0_a15;
    ddp_utilization_rec.component_id := p0_a16;
    ddp_utilization_rec.object_type := p0_a17;
    ddp_utilization_rec.object_id := p0_a18;
    ddp_utilization_rec.order_id := p0_a19;
    ddp_utilization_rec.invoice_id := p0_a20;
    ddp_utilization_rec.amount := p0_a21;
    ddp_utilization_rec.acctd_amount := p0_a22;
    ddp_utilization_rec.currency_code := p0_a23;
    ddp_utilization_rec.exchange_rate_type := p0_a24;
    ddp_utilization_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a25);
    ddp_utilization_rec.exchange_rate := p0_a26;
    ddp_utilization_rec.adjustment_type := p0_a27;
    ddp_utilization_rec.adjustment_date := rosetta_g_miss_date_in_map(p0_a28);
    ddp_utilization_rec.object_version_number := p0_a29;
    ddp_utilization_rec.attribute_category := p0_a30;
    ddp_utilization_rec.attribute1 := p0_a31;
    ddp_utilization_rec.attribute2 := p0_a32;
    ddp_utilization_rec.attribute3 := p0_a33;
    ddp_utilization_rec.attribute4 := p0_a34;
    ddp_utilization_rec.attribute5 := p0_a35;
    ddp_utilization_rec.attribute6 := p0_a36;
    ddp_utilization_rec.attribute7 := p0_a37;
    ddp_utilization_rec.attribute8 := p0_a38;
    ddp_utilization_rec.attribute9 := p0_a39;
    ddp_utilization_rec.attribute10 := p0_a40;
    ddp_utilization_rec.attribute11 := p0_a41;
    ddp_utilization_rec.attribute12 := p0_a42;
    ddp_utilization_rec.attribute13 := p0_a43;
    ddp_utilization_rec.attribute14 := p0_a44;
    ddp_utilization_rec.attribute15 := p0_a45;
    ddp_utilization_rec.org_id := p0_a46;
    ddp_utilization_rec.adjustment_desc := p0_a47;
    ddp_utilization_rec.language := p0_a48;
    ddp_utilization_rec.source_lang := p0_a49;
    ddp_utilization_rec.camp_schedule_id := p0_a50;
    ddp_utilization_rec.adjustment_type_id := p0_a51;
    ddp_utilization_rec.gl_date := rosetta_g_miss_date_in_map(p0_a52);
    ddp_utilization_rec.product_level_type := p0_a53;
    ddp_utilization_rec.product_id := p0_a54;
    ddp_utilization_rec.ams_activity_budget_id := p0_a55;
    ddp_utilization_rec.amount_remaining := p0_a56;
    ddp_utilization_rec.acctd_amount_remaining := p0_a57;
    ddp_utilization_rec.cust_account_id := p0_a58;
    ddp_utilization_rec.price_adjustment_id := p0_a59;
    ddp_utilization_rec.plan_curr_amount := p0_a60;
    ddp_utilization_rec.plan_curr_amount_remaining := p0_a61;
    ddp_utilization_rec.scan_unit := p0_a62;
    ddp_utilization_rec.scan_unit_remaining := p0_a63;
    ddp_utilization_rec.activity_product_id := p0_a64;
    ddp_utilization_rec.scan_data_id := p0_a65;
    ddp_utilization_rec.volume_offer_tiers_id := p0_a66;
    ddp_utilization_rec.gl_posted_flag := p0_a67;
    ddp_utilization_rec.billto_cust_account_id := p0_a68;
    ddp_utilization_rec.reference_type := p0_a69;
    ddp_utilization_rec.reference_id := p0_a70;
    ddp_utilization_rec.order_line_id := p0_a71;
    ddp_utilization_rec.orig_utilization_id := p0_a72;
    ddp_utilization_rec.bill_to_site_use_id := p0_a73;
    ddp_utilization_rec.ship_to_site_use_id := p0_a74;
    ddp_utilization_rec.univ_curr_amount := p0_a75;
    ddp_utilization_rec.univ_curr_amount_remaining := p0_a76;
    ddp_utilization_rec.gl_account_credit := p0_a77;
    ddp_utilization_rec.gl_account_debit := p0_a78;
    ddp_utilization_rec.site_use_id := p0_a79;

    ddp_complete_rec.utilization_id := p1_a0;
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
    ddp_complete_rec.utilization_type := p1_a11;
    ddp_complete_rec.fund_id := p1_a12;
    ddp_complete_rec.plan_type := p1_a13;
    ddp_complete_rec.plan_id := p1_a14;
    ddp_complete_rec.component_type := p1_a15;
    ddp_complete_rec.component_id := p1_a16;
    ddp_complete_rec.object_type := p1_a17;
    ddp_complete_rec.object_id := p1_a18;
    ddp_complete_rec.order_id := p1_a19;
    ddp_complete_rec.invoice_id := p1_a20;
    ddp_complete_rec.amount := p1_a21;
    ddp_complete_rec.acctd_amount := p1_a22;
    ddp_complete_rec.currency_code := p1_a23;
    ddp_complete_rec.exchange_rate_type := p1_a24;
    ddp_complete_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p1_a25);
    ddp_complete_rec.exchange_rate := p1_a26;
    ddp_complete_rec.adjustment_type := p1_a27;
    ddp_complete_rec.adjustment_date := rosetta_g_miss_date_in_map(p1_a28);
    ddp_complete_rec.object_version_number := p1_a29;
    ddp_complete_rec.attribute_category := p1_a30;
    ddp_complete_rec.attribute1 := p1_a31;
    ddp_complete_rec.attribute2 := p1_a32;
    ddp_complete_rec.attribute3 := p1_a33;
    ddp_complete_rec.attribute4 := p1_a34;
    ddp_complete_rec.attribute5 := p1_a35;
    ddp_complete_rec.attribute6 := p1_a36;
    ddp_complete_rec.attribute7 := p1_a37;
    ddp_complete_rec.attribute8 := p1_a38;
    ddp_complete_rec.attribute9 := p1_a39;
    ddp_complete_rec.attribute10 := p1_a40;
    ddp_complete_rec.attribute11 := p1_a41;
    ddp_complete_rec.attribute12 := p1_a42;
    ddp_complete_rec.attribute13 := p1_a43;
    ddp_complete_rec.attribute14 := p1_a44;
    ddp_complete_rec.attribute15 := p1_a45;
    ddp_complete_rec.org_id := p1_a46;
    ddp_complete_rec.adjustment_desc := p1_a47;
    ddp_complete_rec.language := p1_a48;
    ddp_complete_rec.source_lang := p1_a49;
    ddp_complete_rec.camp_schedule_id := p1_a50;
    ddp_complete_rec.adjustment_type_id := p1_a51;
    ddp_complete_rec.gl_date := rosetta_g_miss_date_in_map(p1_a52);
    ddp_complete_rec.product_level_type := p1_a53;
    ddp_complete_rec.product_id := p1_a54;
    ddp_complete_rec.ams_activity_budget_id := p1_a55;
    ddp_complete_rec.amount_remaining := p1_a56;
    ddp_complete_rec.acctd_amount_remaining := p1_a57;
    ddp_complete_rec.cust_account_id := p1_a58;
    ddp_complete_rec.price_adjustment_id := p1_a59;
    ddp_complete_rec.plan_curr_amount := p1_a60;
    ddp_complete_rec.plan_curr_amount_remaining := p1_a61;
    ddp_complete_rec.scan_unit := p1_a62;
    ddp_complete_rec.scan_unit_remaining := p1_a63;
    ddp_complete_rec.activity_product_id := p1_a64;
    ddp_complete_rec.scan_data_id := p1_a65;
    ddp_complete_rec.volume_offer_tiers_id := p1_a66;
    ddp_complete_rec.gl_posted_flag := p1_a67;
    ddp_complete_rec.billto_cust_account_id := p1_a68;
    ddp_complete_rec.reference_type := p1_a69;
    ddp_complete_rec.reference_id := p1_a70;
    ddp_complete_rec.order_line_id := p1_a71;
    ddp_complete_rec.orig_utilization_id := p1_a72;
    ddp_complete_rec.bill_to_site_use_id := p1_a73;
    ddp_complete_rec.ship_to_site_use_id := p1_a74;
    ddp_complete_rec.univ_curr_amount := p1_a75;
    ddp_complete_rec.univ_curr_amount_remaining := p1_a76;
    ddp_complete_rec.gl_account_credit := p1_a77;
    ddp_complete_rec.gl_account_debit := p1_a78;
    ddp_complete_rec.site_use_id := p1_a79;



    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_utilized_pvt.check_utilization_record(ddp_utilization_rec,
      ddp_complete_rec,
      p_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure init_utilization_rec(p0_a0 out nocopy  NUMBER
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
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  DATE
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  DATE
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  NUMBER
    , p0_a52 out nocopy  DATE
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  NUMBER
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  NUMBER
    , p0_a58 out nocopy  NUMBER
    , p0_a59 out nocopy  NUMBER
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  NUMBER
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  NUMBER
    , p0_a66 out nocopy  NUMBER
    , p0_a67 out nocopy  VARCHAR2
    , p0_a68 out nocopy  NUMBER
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  NUMBER
    , p0_a71 out nocopy  NUMBER
    , p0_a72 out nocopy  NUMBER
    , p0_a73 out nocopy  NUMBER
    , p0_a74 out nocopy  NUMBER
    , p0_a75 out nocopy  NUMBER
    , p0_a76 out nocopy  NUMBER
    , p0_a77 out nocopy  NUMBER
    , p0_a78 out nocopy  NUMBER
    , p0_a79 out nocopy  NUMBER
  )

  as
    ddx_utilization_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_utilized_pvt.init_utilization_rec(ddx_utilization_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_utilization_rec.utilization_id;
    p0_a1 := ddx_utilization_rec.last_update_date;
    p0_a2 := ddx_utilization_rec.last_updated_by;
    p0_a3 := ddx_utilization_rec.last_update_login;
    p0_a4 := ddx_utilization_rec.creation_date;
    p0_a5 := ddx_utilization_rec.created_by;
    p0_a6 := ddx_utilization_rec.created_from;
    p0_a7 := ddx_utilization_rec.request_id;
    p0_a8 := ddx_utilization_rec.program_application_id;
    p0_a9 := ddx_utilization_rec.program_id;
    p0_a10 := ddx_utilization_rec.program_update_date;
    p0_a11 := ddx_utilization_rec.utilization_type;
    p0_a12 := ddx_utilization_rec.fund_id;
    p0_a13 := ddx_utilization_rec.plan_type;
    p0_a14 := ddx_utilization_rec.plan_id;
    p0_a15 := ddx_utilization_rec.component_type;
    p0_a16 := ddx_utilization_rec.component_id;
    p0_a17 := ddx_utilization_rec.object_type;
    p0_a18 := ddx_utilization_rec.object_id;
    p0_a19 := ddx_utilization_rec.order_id;
    p0_a20 := ddx_utilization_rec.invoice_id;
    p0_a21 := ddx_utilization_rec.amount;
    p0_a22 := ddx_utilization_rec.acctd_amount;
    p0_a23 := ddx_utilization_rec.currency_code;
    p0_a24 := ddx_utilization_rec.exchange_rate_type;
    p0_a25 := ddx_utilization_rec.exchange_rate_date;
    p0_a26 := ddx_utilization_rec.exchange_rate;
    p0_a27 := ddx_utilization_rec.adjustment_type;
    p0_a28 := ddx_utilization_rec.adjustment_date;
    p0_a29 := ddx_utilization_rec.object_version_number;
    p0_a30 := ddx_utilization_rec.attribute_category;
    p0_a31 := ddx_utilization_rec.attribute1;
    p0_a32 := ddx_utilization_rec.attribute2;
    p0_a33 := ddx_utilization_rec.attribute3;
    p0_a34 := ddx_utilization_rec.attribute4;
    p0_a35 := ddx_utilization_rec.attribute5;
    p0_a36 := ddx_utilization_rec.attribute6;
    p0_a37 := ddx_utilization_rec.attribute7;
    p0_a38 := ddx_utilization_rec.attribute8;
    p0_a39 := ddx_utilization_rec.attribute9;
    p0_a40 := ddx_utilization_rec.attribute10;
    p0_a41 := ddx_utilization_rec.attribute11;
    p0_a42 := ddx_utilization_rec.attribute12;
    p0_a43 := ddx_utilization_rec.attribute13;
    p0_a44 := ddx_utilization_rec.attribute14;
    p0_a45 := ddx_utilization_rec.attribute15;
    p0_a46 := ddx_utilization_rec.org_id;
    p0_a47 := ddx_utilization_rec.adjustment_desc;
    p0_a48 := ddx_utilization_rec.language;
    p0_a49 := ddx_utilization_rec.source_lang;
    p0_a50 := ddx_utilization_rec.camp_schedule_id;
    p0_a51 := ddx_utilization_rec.adjustment_type_id;
    p0_a52 := ddx_utilization_rec.gl_date;
    p0_a53 := ddx_utilization_rec.product_level_type;
    p0_a54 := ddx_utilization_rec.product_id;
    p0_a55 := ddx_utilization_rec.ams_activity_budget_id;
    p0_a56 := ddx_utilization_rec.amount_remaining;
    p0_a57 := ddx_utilization_rec.acctd_amount_remaining;
    p0_a58 := ddx_utilization_rec.cust_account_id;
    p0_a59 := ddx_utilization_rec.price_adjustment_id;
    p0_a60 := ddx_utilization_rec.plan_curr_amount;
    p0_a61 := ddx_utilization_rec.plan_curr_amount_remaining;
    p0_a62 := ddx_utilization_rec.scan_unit;
    p0_a63 := ddx_utilization_rec.scan_unit_remaining;
    p0_a64 := ddx_utilization_rec.activity_product_id;
    p0_a65 := ddx_utilization_rec.scan_data_id;
    p0_a66 := ddx_utilization_rec.volume_offer_tiers_id;
    p0_a67 := ddx_utilization_rec.gl_posted_flag;
    p0_a68 := ddx_utilization_rec.billto_cust_account_id;
    p0_a69 := ddx_utilization_rec.reference_type;
    p0_a70 := ddx_utilization_rec.reference_id;
    p0_a71 := ddx_utilization_rec.order_line_id;
    p0_a72 := ddx_utilization_rec.orig_utilization_id;
    p0_a73 := ddx_utilization_rec.bill_to_site_use_id;
    p0_a74 := ddx_utilization_rec.ship_to_site_use_id;
    p0_a75 := ddx_utilization_rec.univ_curr_amount;
    p0_a76 := ddx_utilization_rec.univ_curr_amount_remaining;
    p0_a77 := ddx_utilization_rec.gl_account_credit;
    p0_a78 := ddx_utilization_rec.gl_account_debit;
    p0_a79 := ddx_utilization_rec.site_use_id;
  end;

  procedure complete_utilization_rec(p0_a0  NUMBER
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
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  DATE
    , p0_a26  NUMBER
    , p0_a27  VARCHAR2
    , p0_a28  DATE
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  VARCHAR2
    , p0_a68  NUMBER
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  NUMBER
    , p0_a75  NUMBER
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  NUMBER
    , p0_a79  NUMBER
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
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  DATE
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  DATE
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  NUMBER
    , p1_a52 out nocopy  DATE
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  NUMBER
    , p1_a58 out nocopy  NUMBER
    , p1_a59 out nocopy  NUMBER
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  NUMBER
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  NUMBER
    , p1_a67 out nocopy  VARCHAR2
    , p1_a68 out nocopy  NUMBER
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  NUMBER
    , p1_a72 out nocopy  NUMBER
    , p1_a73 out nocopy  NUMBER
    , p1_a74 out nocopy  NUMBER
    , p1_a75 out nocopy  NUMBER
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  NUMBER
    , p1_a78 out nocopy  NUMBER
    , p1_a79 out nocopy  NUMBER
  )

  as
    ddp_utilization_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddx_complete_rec ozf_fund_utilized_pvt.utilization_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_utilization_rec.utilization_id := p0_a0;
    ddp_utilization_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_utilization_rec.last_updated_by := p0_a2;
    ddp_utilization_rec.last_update_login := p0_a3;
    ddp_utilization_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_utilization_rec.created_by := p0_a5;
    ddp_utilization_rec.created_from := p0_a6;
    ddp_utilization_rec.request_id := p0_a7;
    ddp_utilization_rec.program_application_id := p0_a8;
    ddp_utilization_rec.program_id := p0_a9;
    ddp_utilization_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_utilization_rec.utilization_type := p0_a11;
    ddp_utilization_rec.fund_id := p0_a12;
    ddp_utilization_rec.plan_type := p0_a13;
    ddp_utilization_rec.plan_id := p0_a14;
    ddp_utilization_rec.component_type := p0_a15;
    ddp_utilization_rec.component_id := p0_a16;
    ddp_utilization_rec.object_type := p0_a17;
    ddp_utilization_rec.object_id := p0_a18;
    ddp_utilization_rec.order_id := p0_a19;
    ddp_utilization_rec.invoice_id := p0_a20;
    ddp_utilization_rec.amount := p0_a21;
    ddp_utilization_rec.acctd_amount := p0_a22;
    ddp_utilization_rec.currency_code := p0_a23;
    ddp_utilization_rec.exchange_rate_type := p0_a24;
    ddp_utilization_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a25);
    ddp_utilization_rec.exchange_rate := p0_a26;
    ddp_utilization_rec.adjustment_type := p0_a27;
    ddp_utilization_rec.adjustment_date := rosetta_g_miss_date_in_map(p0_a28);
    ddp_utilization_rec.object_version_number := p0_a29;
    ddp_utilization_rec.attribute_category := p0_a30;
    ddp_utilization_rec.attribute1 := p0_a31;
    ddp_utilization_rec.attribute2 := p0_a32;
    ddp_utilization_rec.attribute3 := p0_a33;
    ddp_utilization_rec.attribute4 := p0_a34;
    ddp_utilization_rec.attribute5 := p0_a35;
    ddp_utilization_rec.attribute6 := p0_a36;
    ddp_utilization_rec.attribute7 := p0_a37;
    ddp_utilization_rec.attribute8 := p0_a38;
    ddp_utilization_rec.attribute9 := p0_a39;
    ddp_utilization_rec.attribute10 := p0_a40;
    ddp_utilization_rec.attribute11 := p0_a41;
    ddp_utilization_rec.attribute12 := p0_a42;
    ddp_utilization_rec.attribute13 := p0_a43;
    ddp_utilization_rec.attribute14 := p0_a44;
    ddp_utilization_rec.attribute15 := p0_a45;
    ddp_utilization_rec.org_id := p0_a46;
    ddp_utilization_rec.adjustment_desc := p0_a47;
    ddp_utilization_rec.language := p0_a48;
    ddp_utilization_rec.source_lang := p0_a49;
    ddp_utilization_rec.camp_schedule_id := p0_a50;
    ddp_utilization_rec.adjustment_type_id := p0_a51;
    ddp_utilization_rec.gl_date := rosetta_g_miss_date_in_map(p0_a52);
    ddp_utilization_rec.product_level_type := p0_a53;
    ddp_utilization_rec.product_id := p0_a54;
    ddp_utilization_rec.ams_activity_budget_id := p0_a55;
    ddp_utilization_rec.amount_remaining := p0_a56;
    ddp_utilization_rec.acctd_amount_remaining := p0_a57;
    ddp_utilization_rec.cust_account_id := p0_a58;
    ddp_utilization_rec.price_adjustment_id := p0_a59;
    ddp_utilization_rec.plan_curr_amount := p0_a60;
    ddp_utilization_rec.plan_curr_amount_remaining := p0_a61;
    ddp_utilization_rec.scan_unit := p0_a62;
    ddp_utilization_rec.scan_unit_remaining := p0_a63;
    ddp_utilization_rec.activity_product_id := p0_a64;
    ddp_utilization_rec.scan_data_id := p0_a65;
    ddp_utilization_rec.volume_offer_tiers_id := p0_a66;
    ddp_utilization_rec.gl_posted_flag := p0_a67;
    ddp_utilization_rec.billto_cust_account_id := p0_a68;
    ddp_utilization_rec.reference_type := p0_a69;
    ddp_utilization_rec.reference_id := p0_a70;
    ddp_utilization_rec.order_line_id := p0_a71;
    ddp_utilization_rec.orig_utilization_id := p0_a72;
    ddp_utilization_rec.bill_to_site_use_id := p0_a73;
    ddp_utilization_rec.ship_to_site_use_id := p0_a74;
    ddp_utilization_rec.univ_curr_amount := p0_a75;
    ddp_utilization_rec.univ_curr_amount_remaining := p0_a76;
    ddp_utilization_rec.gl_account_credit := p0_a77;
    ddp_utilization_rec.gl_account_debit := p0_a78;
    ddp_utilization_rec.site_use_id := p0_a79;


    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_utilized_pvt.complete_utilization_rec(ddp_utilization_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.utilization_id;
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
    p1_a11 := ddx_complete_rec.utilization_type;
    p1_a12 := ddx_complete_rec.fund_id;
    p1_a13 := ddx_complete_rec.plan_type;
    p1_a14 := ddx_complete_rec.plan_id;
    p1_a15 := ddx_complete_rec.component_type;
    p1_a16 := ddx_complete_rec.component_id;
    p1_a17 := ddx_complete_rec.object_type;
    p1_a18 := ddx_complete_rec.object_id;
    p1_a19 := ddx_complete_rec.order_id;
    p1_a20 := ddx_complete_rec.invoice_id;
    p1_a21 := ddx_complete_rec.amount;
    p1_a22 := ddx_complete_rec.acctd_amount;
    p1_a23 := ddx_complete_rec.currency_code;
    p1_a24 := ddx_complete_rec.exchange_rate_type;
    p1_a25 := ddx_complete_rec.exchange_rate_date;
    p1_a26 := ddx_complete_rec.exchange_rate;
    p1_a27 := ddx_complete_rec.adjustment_type;
    p1_a28 := ddx_complete_rec.adjustment_date;
    p1_a29 := ddx_complete_rec.object_version_number;
    p1_a30 := ddx_complete_rec.attribute_category;
    p1_a31 := ddx_complete_rec.attribute1;
    p1_a32 := ddx_complete_rec.attribute2;
    p1_a33 := ddx_complete_rec.attribute3;
    p1_a34 := ddx_complete_rec.attribute4;
    p1_a35 := ddx_complete_rec.attribute5;
    p1_a36 := ddx_complete_rec.attribute6;
    p1_a37 := ddx_complete_rec.attribute7;
    p1_a38 := ddx_complete_rec.attribute8;
    p1_a39 := ddx_complete_rec.attribute9;
    p1_a40 := ddx_complete_rec.attribute10;
    p1_a41 := ddx_complete_rec.attribute11;
    p1_a42 := ddx_complete_rec.attribute12;
    p1_a43 := ddx_complete_rec.attribute13;
    p1_a44 := ddx_complete_rec.attribute14;
    p1_a45 := ddx_complete_rec.attribute15;
    p1_a46 := ddx_complete_rec.org_id;
    p1_a47 := ddx_complete_rec.adjustment_desc;
    p1_a48 := ddx_complete_rec.language;
    p1_a49 := ddx_complete_rec.source_lang;
    p1_a50 := ddx_complete_rec.camp_schedule_id;
    p1_a51 := ddx_complete_rec.adjustment_type_id;
    p1_a52 := ddx_complete_rec.gl_date;
    p1_a53 := ddx_complete_rec.product_level_type;
    p1_a54 := ddx_complete_rec.product_id;
    p1_a55 := ddx_complete_rec.ams_activity_budget_id;
    p1_a56 := ddx_complete_rec.amount_remaining;
    p1_a57 := ddx_complete_rec.acctd_amount_remaining;
    p1_a58 := ddx_complete_rec.cust_account_id;
    p1_a59 := ddx_complete_rec.price_adjustment_id;
    p1_a60 := ddx_complete_rec.plan_curr_amount;
    p1_a61 := ddx_complete_rec.plan_curr_amount_remaining;
    p1_a62 := ddx_complete_rec.scan_unit;
    p1_a63 := ddx_complete_rec.scan_unit_remaining;
    p1_a64 := ddx_complete_rec.activity_product_id;
    p1_a65 := ddx_complete_rec.scan_data_id;
    p1_a66 := ddx_complete_rec.volume_offer_tiers_id;
    p1_a67 := ddx_complete_rec.gl_posted_flag;
    p1_a68 := ddx_complete_rec.billto_cust_account_id;
    p1_a69 := ddx_complete_rec.reference_type;
    p1_a70 := ddx_complete_rec.reference_id;
    p1_a71 := ddx_complete_rec.order_line_id;
    p1_a72 := ddx_complete_rec.orig_utilization_id;
    p1_a73 := ddx_complete_rec.bill_to_site_use_id;
    p1_a74 := ddx_complete_rec.ship_to_site_use_id;
    p1_a75 := ddx_complete_rec.univ_curr_amount;
    p1_a76 := ddx_complete_rec.univ_curr_amount_remaining;
    p1_a77 := ddx_complete_rec.gl_account_credit;
    p1_a78 := ddx_complete_rec.gl_account_debit;
    p1_a79 := ddx_complete_rec.site_use_id;
  end;

  procedure create_act_utilization(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
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
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  DATE
    , p8_a11  DATE
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  VARCHAR2
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  NUMBER
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  VARCHAR2
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , x_act_budget_id out nocopy  NUMBER
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddp_act_util_rec ozf_actbudgets_pvt.act_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_act_budgets_rec.created_by := p7_a4;
    ddp_act_budgets_rec.last_update_login := p7_a5;
    ddp_act_budgets_rec.object_version_number := p7_a6;
    ddp_act_budgets_rec.act_budget_used_by_id := p7_a7;
    ddp_act_budgets_rec.arc_act_budget_used_by := p7_a8;
    ddp_act_budgets_rec.budget_source_type := p7_a9;
    ddp_act_budgets_rec.budget_source_id := p7_a10;
    ddp_act_budgets_rec.transaction_type := p7_a11;
    ddp_act_budgets_rec.request_amount := p7_a12;
    ddp_act_budgets_rec.request_currency := p7_a13;
    ddp_act_budgets_rec.request_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := rosetta_g_miss_date_in_map(p7_a24);
    ddp_act_budgets_rec.partner_po_approver := p7_a25;
    ddp_act_budgets_rec.adjusted_flag := p7_a26;
    ddp_act_budgets_rec.posted_flag := p7_a27;
    ddp_act_budgets_rec.justification := p7_a28;
    ddp_act_budgets_rec.comment := p7_a29;
    ddp_act_budgets_rec.parent_act_budget_id := p7_a30;
    ddp_act_budgets_rec.contact_id := p7_a31;
    ddp_act_budgets_rec.reason_code := p7_a32;
    ddp_act_budgets_rec.transfer_type := p7_a33;
    ddp_act_budgets_rec.requester_id := p7_a34;
    ddp_act_budgets_rec.date_required_by := rosetta_g_miss_date_in_map(p7_a35);
    ddp_act_budgets_rec.parent_source_id := p7_a36;
    ddp_act_budgets_rec.parent_src_curr := p7_a37;
    ddp_act_budgets_rec.parent_src_apprvd_amt := p7_a38;
    ddp_act_budgets_rec.partner_holding_type := p7_a39;
    ddp_act_budgets_rec.partner_address_id := p7_a40;
    ddp_act_budgets_rec.vendor_id := p7_a41;
    ddp_act_budgets_rec.owner_id := p7_a42;
    ddp_act_budgets_rec.recal_flag := p7_a43;
    ddp_act_budgets_rec.attribute_category := p7_a44;
    ddp_act_budgets_rec.attribute1 := p7_a45;
    ddp_act_budgets_rec.attribute2 := p7_a46;
    ddp_act_budgets_rec.attribute3 := p7_a47;
    ddp_act_budgets_rec.attribute4 := p7_a48;
    ddp_act_budgets_rec.attribute5 := p7_a49;
    ddp_act_budgets_rec.attribute6 := p7_a50;
    ddp_act_budgets_rec.attribute7 := p7_a51;
    ddp_act_budgets_rec.attribute8 := p7_a52;
    ddp_act_budgets_rec.attribute9 := p7_a53;
    ddp_act_budgets_rec.attribute10 := p7_a54;
    ddp_act_budgets_rec.attribute11 := p7_a55;
    ddp_act_budgets_rec.attribute12 := p7_a56;
    ddp_act_budgets_rec.attribute13 := p7_a57;
    ddp_act_budgets_rec.attribute14 := p7_a58;
    ddp_act_budgets_rec.attribute15 := p7_a59;
    ddp_act_budgets_rec.src_curr_req_amt := p7_a60;

    ddp_act_util_rec.object_type := p8_a0;
    ddp_act_util_rec.object_id := p8_a1;
    ddp_act_util_rec.adjustment_type := p8_a2;
    ddp_act_util_rec.camp_schedule_id := p8_a3;
    ddp_act_util_rec.adjustment_type_id := p8_a4;
    ddp_act_util_rec.product_level_type := p8_a5;
    ddp_act_util_rec.product_id := p8_a6;
    ddp_act_util_rec.cust_account_id := p8_a7;
    ddp_act_util_rec.price_adjustment_id := p8_a8;
    ddp_act_util_rec.utilization_type := p8_a9;
    ddp_act_util_rec.adjustment_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_act_util_rec.gl_date := rosetta_g_miss_date_in_map(p8_a11);
    ddp_act_util_rec.scan_unit := p8_a12;
    ddp_act_util_rec.scan_unit_remaining := p8_a13;
    ddp_act_util_rec.activity_product_id := p8_a14;
    ddp_act_util_rec.scan_type_id := p8_a15;
    ddp_act_util_rec.volume_offer_tiers_id := p8_a16;
    ddp_act_util_rec.billto_cust_account_id := p8_a17;
    ddp_act_util_rec.reference_type := p8_a18;
    ddp_act_util_rec.reference_id := p8_a19;
    ddp_act_util_rec.order_line_id := p8_a20;
    ddp_act_util_rec.org_id := p8_a21;
    ddp_act_util_rec.orig_utilization_id := p8_a22;
    ddp_act_util_rec.gl_posted_flag := p8_a23;
    ddp_act_util_rec.bill_to_site_use_id := p8_a24;
    ddp_act_util_rec.ship_to_site_use_id := p8_a25;
    ddp_act_util_rec.gl_account_credit := p8_a26;
    ddp_act_util_rec.gl_account_debit := p8_a27;
    ddp_act_util_rec.site_use_id := p8_a28;
    ddp_act_util_rec.attribute_category := p8_a29;
    ddp_act_util_rec.attribute1 := p8_a30;
    ddp_act_util_rec.attribute2 := p8_a31;
    ddp_act_util_rec.attribute3 := p8_a32;
    ddp_act_util_rec.attribute4 := p8_a33;
    ddp_act_util_rec.attribute5 := p8_a34;
    ddp_act_util_rec.attribute6 := p8_a35;
    ddp_act_util_rec.attribute7 := p8_a36;
    ddp_act_util_rec.attribute8 := p8_a37;
    ddp_act_util_rec.attribute9 := p8_a38;
    ddp_act_util_rec.attribute10 := p8_a39;
    ddp_act_util_rec.attribute11 := p8_a40;
    ddp_act_util_rec.attribute12 := p8_a41;
    ddp_act_util_rec.attribute13 := p8_a42;
    ddp_act_util_rec.attribute14 := p8_a43;
    ddp_act_util_rec.attribute15 := p8_a44;


    -- here's the delegated call to the old PL/SQL routine
    ozf_fund_utilized_pvt.create_act_utilization(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec,
      ddp_act_util_rec,
      x_act_budget_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end ozf_fund_utilized_pvt_w;

/
