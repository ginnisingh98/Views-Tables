--------------------------------------------------------
--  DDL for Package Body OZF_ACTBUDGETS_PVT_OAW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTBUDGETS_PVT_OAW" as
  /* $Header: ozfabdgb.pls 115.2 2004/06/29 17:16:48 feliu noship $ */
  procedure create_act_budgets(p_api_version  NUMBER
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
    , x_act_budget_id out nocopy  NUMBER
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := p7_a1;
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := p7_a3;
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
    ddp_act_budgets_rec.request_date := p7_a14;
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := p7_a20;
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := p7_a24;
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
    ddp_act_budgets_rec.date_required_by := p7_a35;
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


    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.create_act_budgets(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec,
      x_act_budget_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_act_budgets(p_api_version  NUMBER
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
    , x_act_budget_id out nocopy  NUMBER
    , p_approval_flag  VARCHAR2
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddp_act_util_rec ozf_actbudgets_pvt.act_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := p7_a1;
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := p7_a3;
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
    ddp_act_budgets_rec.request_date := p7_a14;
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := p7_a20;
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := p7_a24;
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
    ddp_act_budgets_rec.date_required_by := p7_a35;
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
    ddp_act_util_rec.adjustment_date := p8_a10;
    ddp_act_util_rec.gl_date := p8_a11;
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



    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.create_act_budgets(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec,
      ddp_act_util_rec,
      x_act_budget_id,
      p_approval_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure create_act_budgets(p_api_version  NUMBER
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
    , x_act_budget_id out nocopy  NUMBER
    , p_approval_flag  VARCHAR2
    , x_utilized_amount out nocopy  NUMBER
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddp_act_util_rec ozf_actbudgets_pvt.act_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := p7_a1;
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := p7_a3;
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
    ddp_act_budgets_rec.request_date := p7_a14;
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := p7_a20;
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := p7_a24;
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
    ddp_act_budgets_rec.date_required_by := p7_a35;
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
    ddp_act_util_rec.adjustment_date := p8_a10;
    ddp_act_util_rec.gl_date := p8_a11;
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




    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.create_act_budgets(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec,
      ddp_act_util_rec,
      x_act_budget_id,
      p_approval_flag,
      x_utilized_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure update_act_budgets(p_api_version  NUMBER
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
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := p7_a1;
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := p7_a3;
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
    ddp_act_budgets_rec.request_date := p7_a14;
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := p7_a20;
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := p7_a24;
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
    ddp_act_budgets_rec.date_required_by := p7_a35;
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

    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.update_act_budgets(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_act_budgets(p_api_version  NUMBER
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
    , p_parent_process_flag  VARCHAR2
    , p_parent_process_key  VARCHAR2
    , p_parent_context  VARCHAR2
    , p_parent_approval_flag  VARCHAR2
    , p_continue_flow  VARCHAR2
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p15_a0  VARCHAR2
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  NUMBER
    , p15_a5  VARCHAR2
    , p15_a6  NUMBER
    , p15_a7  NUMBER
    , p15_a8  NUMBER
    , p15_a9  VARCHAR2
    , p15_a10  DATE
    , p15_a11  DATE
    , p15_a12  NUMBER
    , p15_a13  NUMBER
    , p15_a14  NUMBER
    , p15_a15  NUMBER
    , p15_a16  NUMBER
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  NUMBER
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  NUMBER
    , p15_a23  VARCHAR2
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddp_act_util_rec ozf_actbudgets_pvt.act_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := p7_a1;
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := p7_a3;
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
    ddp_act_budgets_rec.request_date := p7_a14;
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := p7_a20;
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := p7_a24;
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
    ddp_act_budgets_rec.date_required_by := p7_a35;
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








    ddp_act_util_rec.object_type := p15_a0;
    ddp_act_util_rec.object_id := p15_a1;
    ddp_act_util_rec.adjustment_type := p15_a2;
    ddp_act_util_rec.camp_schedule_id := p15_a3;
    ddp_act_util_rec.adjustment_type_id := p15_a4;
    ddp_act_util_rec.product_level_type := p15_a5;
    ddp_act_util_rec.product_id := p15_a6;
    ddp_act_util_rec.cust_account_id := p15_a7;
    ddp_act_util_rec.price_adjustment_id := p15_a8;
    ddp_act_util_rec.utilization_type := p15_a9;
    ddp_act_util_rec.adjustment_date := p15_a10;
    ddp_act_util_rec.gl_date := p15_a11;
    ddp_act_util_rec.scan_unit := p15_a12;
    ddp_act_util_rec.scan_unit_remaining := p15_a13;
    ddp_act_util_rec.activity_product_id := p15_a14;
    ddp_act_util_rec.scan_type_id := p15_a15;
    ddp_act_util_rec.volume_offer_tiers_id := p15_a16;
    ddp_act_util_rec.billto_cust_account_id := p15_a17;
    ddp_act_util_rec.reference_type := p15_a18;
    ddp_act_util_rec.reference_id := p15_a19;
    ddp_act_util_rec.order_line_id := p15_a20;
    ddp_act_util_rec.org_id := p15_a21;
    ddp_act_util_rec.orig_utilization_id := p15_a22;
    ddp_act_util_rec.gl_posted_flag := p15_a23;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.update_act_budgets(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec,
      p_parent_process_flag,
      p_parent_process_key,
      p_parent_context,
      p_parent_approval_flag,
      p_continue_flow,
      p_child_approval_flag,
      p_requestor_owner_flag,
      ddp_act_util_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

  procedure update_act_budgets(p_api_version  NUMBER
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
    , p_parent_process_flag  VARCHAR2
    , p_parent_process_key  VARCHAR2
    , p_parent_context  VARCHAR2
    , p_parent_approval_flag  VARCHAR2
    , p_continue_flow  VARCHAR2
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p15_a0  VARCHAR2
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  NUMBER
    , p15_a5  VARCHAR2
    , p15_a6  NUMBER
    , p15_a7  NUMBER
    , p15_a8  NUMBER
    , p15_a9  VARCHAR2
    , p15_a10  DATE
    , p15_a11  DATE
    , p15_a12  NUMBER
    , p15_a13  NUMBER
    , p15_a14  NUMBER
    , p15_a15  NUMBER
    , p15_a16  NUMBER
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  NUMBER
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  NUMBER
    , p15_a23  VARCHAR2
    , x_utilized_amount out nocopy  NUMBER
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddp_act_util_rec ozf_actbudgets_pvt.act_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := p7_a1;
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := p7_a3;
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
    ddp_act_budgets_rec.request_date := p7_a14;
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := p7_a20;
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := p7_a24;
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
    ddp_act_budgets_rec.date_required_by := p7_a35;
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








    ddp_act_util_rec.object_type := p15_a0;
    ddp_act_util_rec.object_id := p15_a1;
    ddp_act_util_rec.adjustment_type := p15_a2;
    ddp_act_util_rec.camp_schedule_id := p15_a3;
    ddp_act_util_rec.adjustment_type_id := p15_a4;
    ddp_act_util_rec.product_level_type := p15_a5;
    ddp_act_util_rec.product_id := p15_a6;
    ddp_act_util_rec.cust_account_id := p15_a7;
    ddp_act_util_rec.price_adjustment_id := p15_a8;
    ddp_act_util_rec.utilization_type := p15_a9;
    ddp_act_util_rec.adjustment_date := p15_a10;
    ddp_act_util_rec.gl_date := p15_a11;
    ddp_act_util_rec.scan_unit := p15_a12;
    ddp_act_util_rec.scan_unit_remaining := p15_a13;
    ddp_act_util_rec.activity_product_id := p15_a14;
    ddp_act_util_rec.scan_type_id := p15_a15;
    ddp_act_util_rec.volume_offer_tiers_id := p15_a16;
    ddp_act_util_rec.billto_cust_account_id := p15_a17;
    ddp_act_util_rec.reference_type := p15_a18;
    ddp_act_util_rec.reference_id := p15_a19;
    ddp_act_util_rec.order_line_id := p15_a20;
    ddp_act_util_rec.org_id := p15_a21;
    ddp_act_util_rec.orig_utilization_id := p15_a22;
    ddp_act_util_rec.gl_posted_flag := p15_a23;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.update_act_budgets(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec,
      p_parent_process_flag,
      p_parent_process_key,
      p_parent_context,
      p_parent_approval_flag,
      p_continue_flow,
      p_child_approval_flag,
      p_requestor_owner_flag,
      ddp_act_util_rec,
      x_utilized_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure update_act_budgets(p_api_version  NUMBER
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
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p10_a0  VARCHAR2
    , p10_a1  NUMBER
    , p10_a2  VARCHAR2
    , p10_a3  NUMBER
    , p10_a4  NUMBER
    , p10_a5  VARCHAR2
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  NUMBER
    , p10_a9  VARCHAR2
    , p10_a10  DATE
    , p10_a11  DATE
    , p10_a12  NUMBER
    , p10_a13  NUMBER
    , p10_a14  NUMBER
    , p10_a15  NUMBER
    , p10_a16  NUMBER
    , p10_a17  NUMBER
    , p10_a18  VARCHAR2
    , p10_a19  NUMBER
    , p10_a20  NUMBER
    , p10_a21  NUMBER
    , p10_a22  NUMBER
    , p10_a23  VARCHAR2
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddp_act_util_rec ozf_actbudgets_pvt.act_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := p7_a1;
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := p7_a3;
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
    ddp_act_budgets_rec.request_date := p7_a14;
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := p7_a20;
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := p7_a24;
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
    ddp_act_budgets_rec.date_required_by := p7_a35;
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



    ddp_act_util_rec.object_type := p10_a0;
    ddp_act_util_rec.object_id := p10_a1;
    ddp_act_util_rec.adjustment_type := p10_a2;
    ddp_act_util_rec.camp_schedule_id := p10_a3;
    ddp_act_util_rec.adjustment_type_id := p10_a4;
    ddp_act_util_rec.product_level_type := p10_a5;
    ddp_act_util_rec.product_id := p10_a6;
    ddp_act_util_rec.cust_account_id := p10_a7;
    ddp_act_util_rec.price_adjustment_id := p10_a8;
    ddp_act_util_rec.utilization_type := p10_a9;
    ddp_act_util_rec.adjustment_date := p10_a10;
    ddp_act_util_rec.gl_date := p10_a11;
    ddp_act_util_rec.scan_unit := p10_a12;
    ddp_act_util_rec.scan_unit_remaining := p10_a13;
    ddp_act_util_rec.activity_product_id := p10_a14;
    ddp_act_util_rec.scan_type_id := p10_a15;
    ddp_act_util_rec.volume_offer_tiers_id := p10_a16;
    ddp_act_util_rec.billto_cust_account_id := p10_a17;
    ddp_act_util_rec.reference_type := p10_a18;
    ddp_act_util_rec.reference_id := p10_a19;
    ddp_act_util_rec.order_line_id := p10_a20;
    ddp_act_util_rec.org_id := p10_a21;
    ddp_act_util_rec.orig_utilization_id := p10_a22;
    ddp_act_util_rec.gl_posted_flag := p10_a23;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.update_act_budgets(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec,
      p_child_approval_flag,
      p_requestor_owner_flag,
      ddp_act_util_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_act_budgets(p_api_version  NUMBER
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
    , p_child_approval_flag  VARCHAR2
    , p_requestor_owner_flag  VARCHAR2
    , p10_a0  VARCHAR2
    , p10_a1  NUMBER
    , p10_a2  VARCHAR2
    , p10_a3  NUMBER
    , p10_a4  NUMBER
    , p10_a5  VARCHAR2
    , p10_a6  NUMBER
    , p10_a7  NUMBER
    , p10_a8  NUMBER
    , p10_a9  VARCHAR2
    , p10_a10  DATE
    , p10_a11  DATE
    , p10_a12  NUMBER
    , p10_a13  NUMBER
    , p10_a14  NUMBER
    , p10_a15  NUMBER
    , p10_a16  NUMBER
    , p10_a17  NUMBER
    , p10_a18  VARCHAR2
    , p10_a19  NUMBER
    , p10_a20  NUMBER
    , p10_a21  NUMBER
    , p10_a22  NUMBER
    , p10_a23  VARCHAR2
    , x_utilized_amount out nocopy  NUMBER
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddp_act_util_rec ozf_actbudgets_pvt.act_util_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_act_budgets_rec.activity_budget_id := p7_a0;
    ddp_act_budgets_rec.last_update_date := p7_a1;
    ddp_act_budgets_rec.last_updated_by := p7_a2;
    ddp_act_budgets_rec.creation_date := p7_a3;
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
    ddp_act_budgets_rec.request_date := p7_a14;
    ddp_act_budgets_rec.user_status_id := p7_a15;
    ddp_act_budgets_rec.status_code := p7_a16;
    ddp_act_budgets_rec.approved_amount := p7_a17;
    ddp_act_budgets_rec.approved_original_amount := p7_a18;
    ddp_act_budgets_rec.approved_in_currency := p7_a19;
    ddp_act_budgets_rec.approval_date := p7_a20;
    ddp_act_budgets_rec.approver_id := p7_a21;
    ddp_act_budgets_rec.spent_amount := p7_a22;
    ddp_act_budgets_rec.partner_po_number := p7_a23;
    ddp_act_budgets_rec.partner_po_date := p7_a24;
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
    ddp_act_budgets_rec.date_required_by := p7_a35;
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



    ddp_act_util_rec.object_type := p10_a0;
    ddp_act_util_rec.object_id := p10_a1;
    ddp_act_util_rec.adjustment_type := p10_a2;
    ddp_act_util_rec.camp_schedule_id := p10_a3;
    ddp_act_util_rec.adjustment_type_id := p10_a4;
    ddp_act_util_rec.product_level_type := p10_a5;
    ddp_act_util_rec.product_id := p10_a6;
    ddp_act_util_rec.cust_account_id := p10_a7;
    ddp_act_util_rec.price_adjustment_id := p10_a8;
    ddp_act_util_rec.utilization_type := p10_a9;
    ddp_act_util_rec.adjustment_date := p10_a10;
    ddp_act_util_rec.gl_date := p10_a11;
    ddp_act_util_rec.scan_unit := p10_a12;
    ddp_act_util_rec.scan_unit_remaining := p10_a13;
    ddp_act_util_rec.activity_product_id := p10_a14;
    ddp_act_util_rec.scan_type_id := p10_a15;
    ddp_act_util_rec.volume_offer_tiers_id := p10_a16;
    ddp_act_util_rec.billto_cust_account_id := p10_a17;
    ddp_act_util_rec.reference_type := p10_a18;
    ddp_act_util_rec.reference_id := p10_a19;
    ddp_act_util_rec.order_line_id := p10_a20;
    ddp_act_util_rec.org_id := p10_a21;
    ddp_act_util_rec.orig_utilization_id := p10_a22;
    ddp_act_util_rec.gl_posted_flag := p10_a23;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.update_act_budgets(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec,
      p_child_approval_flag,
      p_requestor_owner_flag,
      ddp_act_util_rec,
      x_utilized_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure validate_act_budgets(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  DATE
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  DATE
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR
    , p6_a29  VARCHAR
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  NUMBER
    , p6_a35  DATE
    , p6_a36  NUMBER
    , p6_a37  VARCHAR2
    , p6_a38  NUMBER
    , p6_a39  VARCHAR2
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  NUMBER
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
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  VARCHAR2
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  NUMBER
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_act_budgets_rec.activity_budget_id := p6_a0;
    ddp_act_budgets_rec.last_update_date := p6_a1;
    ddp_act_budgets_rec.last_updated_by := p6_a2;
    ddp_act_budgets_rec.creation_date := p6_a3;
    ddp_act_budgets_rec.created_by := p6_a4;
    ddp_act_budgets_rec.last_update_login := p6_a5;
    ddp_act_budgets_rec.object_version_number := p6_a6;
    ddp_act_budgets_rec.act_budget_used_by_id := p6_a7;
    ddp_act_budgets_rec.arc_act_budget_used_by := p6_a8;
    ddp_act_budgets_rec.budget_source_type := p6_a9;
    ddp_act_budgets_rec.budget_source_id := p6_a10;
    ddp_act_budgets_rec.transaction_type := p6_a11;
    ddp_act_budgets_rec.request_amount := p6_a12;
    ddp_act_budgets_rec.request_currency := p6_a13;
    ddp_act_budgets_rec.request_date := p6_a14;
    ddp_act_budgets_rec.user_status_id := p6_a15;
    ddp_act_budgets_rec.status_code := p6_a16;
    ddp_act_budgets_rec.approved_amount := p6_a17;
    ddp_act_budgets_rec.approved_original_amount := p6_a18;
    ddp_act_budgets_rec.approved_in_currency := p6_a19;
    ddp_act_budgets_rec.approval_date := p6_a20;
    ddp_act_budgets_rec.approver_id := p6_a21;
    ddp_act_budgets_rec.spent_amount := p6_a22;
    ddp_act_budgets_rec.partner_po_number := p6_a23;
    ddp_act_budgets_rec.partner_po_date := p6_a24;
    ddp_act_budgets_rec.partner_po_approver := p6_a25;
    ddp_act_budgets_rec.adjusted_flag := p6_a26;
    ddp_act_budgets_rec.posted_flag := p6_a27;
    ddp_act_budgets_rec.justification := p6_a28;
    ddp_act_budgets_rec.comment := p6_a29;
    ddp_act_budgets_rec.parent_act_budget_id := p6_a30;
    ddp_act_budgets_rec.contact_id := p6_a31;
    ddp_act_budgets_rec.reason_code := p6_a32;
    ddp_act_budgets_rec.transfer_type := p6_a33;
    ddp_act_budgets_rec.requester_id := p6_a34;
    ddp_act_budgets_rec.date_required_by := p6_a35;
    ddp_act_budgets_rec.parent_source_id := p6_a36;
    ddp_act_budgets_rec.parent_src_curr := p6_a37;
    ddp_act_budgets_rec.parent_src_apprvd_amt := p6_a38;
    ddp_act_budgets_rec.partner_holding_type := p6_a39;
    ddp_act_budgets_rec.partner_address_id := p6_a40;
    ddp_act_budgets_rec.vendor_id := p6_a41;
    ddp_act_budgets_rec.owner_id := p6_a42;
    ddp_act_budgets_rec.recal_flag := p6_a43;
    ddp_act_budgets_rec.attribute_category := p6_a44;
    ddp_act_budgets_rec.attribute1 := p6_a45;
    ddp_act_budgets_rec.attribute2 := p6_a46;
    ddp_act_budgets_rec.attribute3 := p6_a47;
    ddp_act_budgets_rec.attribute4 := p6_a48;
    ddp_act_budgets_rec.attribute5 := p6_a49;
    ddp_act_budgets_rec.attribute6 := p6_a50;
    ddp_act_budgets_rec.attribute7 := p6_a51;
    ddp_act_budgets_rec.attribute8 := p6_a52;
    ddp_act_budgets_rec.attribute9 := p6_a53;
    ddp_act_budgets_rec.attribute10 := p6_a54;
    ddp_act_budgets_rec.attribute11 := p6_a55;
    ddp_act_budgets_rec.attribute12 := p6_a56;
    ddp_act_budgets_rec.attribute13 := p6_a57;
    ddp_act_budgets_rec.attribute14 := p6_a58;
    ddp_act_budgets_rec.attribute15 := p6_a59;
    ddp_act_budgets_rec.src_curr_req_amt := p6_a60;

    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.validate_act_budgets(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_act_budgets_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_act_budgets_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR
    , p0_a29  VARCHAR
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  NUMBER
    , p0_a35  DATE
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  VARCHAR2
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
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
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_budgets_rec.activity_budget_id := p0_a0;
    ddp_act_budgets_rec.last_update_date := p0_a1;
    ddp_act_budgets_rec.last_updated_by := p0_a2;
    ddp_act_budgets_rec.creation_date := p0_a3;
    ddp_act_budgets_rec.created_by := p0_a4;
    ddp_act_budgets_rec.last_update_login := p0_a5;
    ddp_act_budgets_rec.object_version_number := p0_a6;
    ddp_act_budgets_rec.act_budget_used_by_id := p0_a7;
    ddp_act_budgets_rec.arc_act_budget_used_by := p0_a8;
    ddp_act_budgets_rec.budget_source_type := p0_a9;
    ddp_act_budgets_rec.budget_source_id := p0_a10;
    ddp_act_budgets_rec.transaction_type := p0_a11;
    ddp_act_budgets_rec.request_amount := p0_a12;
    ddp_act_budgets_rec.request_currency := p0_a13;
    ddp_act_budgets_rec.request_date := p0_a14;
    ddp_act_budgets_rec.user_status_id := p0_a15;
    ddp_act_budgets_rec.status_code := p0_a16;
    ddp_act_budgets_rec.approved_amount := p0_a17;
    ddp_act_budgets_rec.approved_original_amount := p0_a18;
    ddp_act_budgets_rec.approved_in_currency := p0_a19;
    ddp_act_budgets_rec.approval_date := p0_a20;
    ddp_act_budgets_rec.approver_id := p0_a21;
    ddp_act_budgets_rec.spent_amount := p0_a22;
    ddp_act_budgets_rec.partner_po_number := p0_a23;
    ddp_act_budgets_rec.partner_po_date := p0_a24;
    ddp_act_budgets_rec.partner_po_approver := p0_a25;
    ddp_act_budgets_rec.adjusted_flag := p0_a26;
    ddp_act_budgets_rec.posted_flag := p0_a27;
    ddp_act_budgets_rec.justification := p0_a28;
    ddp_act_budgets_rec.comment := p0_a29;
    ddp_act_budgets_rec.parent_act_budget_id := p0_a30;
    ddp_act_budgets_rec.contact_id := p0_a31;
    ddp_act_budgets_rec.reason_code := p0_a32;
    ddp_act_budgets_rec.transfer_type := p0_a33;
    ddp_act_budgets_rec.requester_id := p0_a34;
    ddp_act_budgets_rec.date_required_by := p0_a35;
    ddp_act_budgets_rec.parent_source_id := p0_a36;
    ddp_act_budgets_rec.parent_src_curr := p0_a37;
    ddp_act_budgets_rec.parent_src_apprvd_amt := p0_a38;
    ddp_act_budgets_rec.partner_holding_type := p0_a39;
    ddp_act_budgets_rec.partner_address_id := p0_a40;
    ddp_act_budgets_rec.vendor_id := p0_a41;
    ddp_act_budgets_rec.owner_id := p0_a42;
    ddp_act_budgets_rec.recal_flag := p0_a43;
    ddp_act_budgets_rec.attribute_category := p0_a44;
    ddp_act_budgets_rec.attribute1 := p0_a45;
    ddp_act_budgets_rec.attribute2 := p0_a46;
    ddp_act_budgets_rec.attribute3 := p0_a47;
    ddp_act_budgets_rec.attribute4 := p0_a48;
    ddp_act_budgets_rec.attribute5 := p0_a49;
    ddp_act_budgets_rec.attribute6 := p0_a50;
    ddp_act_budgets_rec.attribute7 := p0_a51;
    ddp_act_budgets_rec.attribute8 := p0_a52;
    ddp_act_budgets_rec.attribute9 := p0_a53;
    ddp_act_budgets_rec.attribute10 := p0_a54;
    ddp_act_budgets_rec.attribute11 := p0_a55;
    ddp_act_budgets_rec.attribute12 := p0_a56;
    ddp_act_budgets_rec.attribute13 := p0_a57;
    ddp_act_budgets_rec.attribute14 := p0_a58;
    ddp_act_budgets_rec.attribute15 := p0_a59;
    ddp_act_budgets_rec.src_curr_req_amt := p0_a60;



    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.validate_act_budgets_items(ddp_act_budgets_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_act_budgets_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR
    , p0_a29  VARCHAR
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  NUMBER
    , p0_a35  DATE
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  VARCHAR2
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
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
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_budgets_rec.activity_budget_id := p0_a0;
    ddp_act_budgets_rec.last_update_date := p0_a1;
    ddp_act_budgets_rec.last_updated_by := p0_a2;
    ddp_act_budgets_rec.creation_date := p0_a3;
    ddp_act_budgets_rec.created_by := p0_a4;
    ddp_act_budgets_rec.last_update_login := p0_a5;
    ddp_act_budgets_rec.object_version_number := p0_a6;
    ddp_act_budgets_rec.act_budget_used_by_id := p0_a7;
    ddp_act_budgets_rec.arc_act_budget_used_by := p0_a8;
    ddp_act_budgets_rec.budget_source_type := p0_a9;
    ddp_act_budgets_rec.budget_source_id := p0_a10;
    ddp_act_budgets_rec.transaction_type := p0_a11;
    ddp_act_budgets_rec.request_amount := p0_a12;
    ddp_act_budgets_rec.request_currency := p0_a13;
    ddp_act_budgets_rec.request_date := p0_a14;
    ddp_act_budgets_rec.user_status_id := p0_a15;
    ddp_act_budgets_rec.status_code := p0_a16;
    ddp_act_budgets_rec.approved_amount := p0_a17;
    ddp_act_budgets_rec.approved_original_amount := p0_a18;
    ddp_act_budgets_rec.approved_in_currency := p0_a19;
    ddp_act_budgets_rec.approval_date := p0_a20;
    ddp_act_budgets_rec.approver_id := p0_a21;
    ddp_act_budgets_rec.spent_amount := p0_a22;
    ddp_act_budgets_rec.partner_po_number := p0_a23;
    ddp_act_budgets_rec.partner_po_date := p0_a24;
    ddp_act_budgets_rec.partner_po_approver := p0_a25;
    ddp_act_budgets_rec.adjusted_flag := p0_a26;
    ddp_act_budgets_rec.posted_flag := p0_a27;
    ddp_act_budgets_rec.justification := p0_a28;
    ddp_act_budgets_rec.comment := p0_a29;
    ddp_act_budgets_rec.parent_act_budget_id := p0_a30;
    ddp_act_budgets_rec.contact_id := p0_a31;
    ddp_act_budgets_rec.reason_code := p0_a32;
    ddp_act_budgets_rec.transfer_type := p0_a33;
    ddp_act_budgets_rec.requester_id := p0_a34;
    ddp_act_budgets_rec.date_required_by := p0_a35;
    ddp_act_budgets_rec.parent_source_id := p0_a36;
    ddp_act_budgets_rec.parent_src_curr := p0_a37;
    ddp_act_budgets_rec.parent_src_apprvd_amt := p0_a38;
    ddp_act_budgets_rec.partner_holding_type := p0_a39;
    ddp_act_budgets_rec.partner_address_id := p0_a40;
    ddp_act_budgets_rec.vendor_id := p0_a41;
    ddp_act_budgets_rec.owner_id := p0_a42;
    ddp_act_budgets_rec.recal_flag := p0_a43;
    ddp_act_budgets_rec.attribute_category := p0_a44;
    ddp_act_budgets_rec.attribute1 := p0_a45;
    ddp_act_budgets_rec.attribute2 := p0_a46;
    ddp_act_budgets_rec.attribute3 := p0_a47;
    ddp_act_budgets_rec.attribute4 := p0_a48;
    ddp_act_budgets_rec.attribute5 := p0_a49;
    ddp_act_budgets_rec.attribute6 := p0_a50;
    ddp_act_budgets_rec.attribute7 := p0_a51;
    ddp_act_budgets_rec.attribute8 := p0_a52;
    ddp_act_budgets_rec.attribute9 := p0_a53;
    ddp_act_budgets_rec.attribute10 := p0_a54;
    ddp_act_budgets_rec.attribute11 := p0_a55;
    ddp_act_budgets_rec.attribute12 := p0_a56;
    ddp_act_budgets_rec.attribute13 := p0_a57;
    ddp_act_budgets_rec.attribute14 := p0_a58;
    ddp_act_budgets_rec.attribute15 := p0_a59;
    ddp_act_budgets_rec.src_curr_req_amt := p0_a60;



    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.validate_act_budgets_record(ddp_act_budgets_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_act_budgets_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR
    , p0_a29  VARCHAR
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  NUMBER
    , p0_a35  DATE
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  VARCHAR2
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
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
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  DATE
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  DATE
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR
    , p1_a29 out nocopy  VARCHAR
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  NUMBER
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  DATE
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  NUMBER
    , p1_a42 out nocopy  NUMBER
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
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  NUMBER
  )

  as
    ddp_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddx_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_act_budgets_rec.activity_budget_id := p0_a0;
    ddp_act_budgets_rec.last_update_date := p0_a1;
    ddp_act_budgets_rec.last_updated_by := p0_a2;
    ddp_act_budgets_rec.creation_date := p0_a3;
    ddp_act_budgets_rec.created_by := p0_a4;
    ddp_act_budgets_rec.last_update_login := p0_a5;
    ddp_act_budgets_rec.object_version_number := p0_a6;
    ddp_act_budgets_rec.act_budget_used_by_id := p0_a7;
    ddp_act_budgets_rec.arc_act_budget_used_by := p0_a8;
    ddp_act_budgets_rec.budget_source_type := p0_a9;
    ddp_act_budgets_rec.budget_source_id := p0_a10;
    ddp_act_budgets_rec.transaction_type := p0_a11;
    ddp_act_budgets_rec.request_amount := p0_a12;
    ddp_act_budgets_rec.request_currency := p0_a13;
    ddp_act_budgets_rec.request_date := p0_a14;
    ddp_act_budgets_rec.user_status_id := p0_a15;
    ddp_act_budgets_rec.status_code := p0_a16;
    ddp_act_budgets_rec.approved_amount := p0_a17;
    ddp_act_budgets_rec.approved_original_amount := p0_a18;
    ddp_act_budgets_rec.approved_in_currency := p0_a19;
    ddp_act_budgets_rec.approval_date := p0_a20;
    ddp_act_budgets_rec.approver_id := p0_a21;
    ddp_act_budgets_rec.spent_amount := p0_a22;
    ddp_act_budgets_rec.partner_po_number := p0_a23;
    ddp_act_budgets_rec.partner_po_date := p0_a24;
    ddp_act_budgets_rec.partner_po_approver := p0_a25;
    ddp_act_budgets_rec.adjusted_flag := p0_a26;
    ddp_act_budgets_rec.posted_flag := p0_a27;
    ddp_act_budgets_rec.justification := p0_a28;
    ddp_act_budgets_rec.comment := p0_a29;
    ddp_act_budgets_rec.parent_act_budget_id := p0_a30;
    ddp_act_budgets_rec.contact_id := p0_a31;
    ddp_act_budgets_rec.reason_code := p0_a32;
    ddp_act_budgets_rec.transfer_type := p0_a33;
    ddp_act_budgets_rec.requester_id := p0_a34;
    ddp_act_budgets_rec.date_required_by := p0_a35;
    ddp_act_budgets_rec.parent_source_id := p0_a36;
    ddp_act_budgets_rec.parent_src_curr := p0_a37;
    ddp_act_budgets_rec.parent_src_apprvd_amt := p0_a38;
    ddp_act_budgets_rec.partner_holding_type := p0_a39;
    ddp_act_budgets_rec.partner_address_id := p0_a40;
    ddp_act_budgets_rec.vendor_id := p0_a41;
    ddp_act_budgets_rec.owner_id := p0_a42;
    ddp_act_budgets_rec.recal_flag := p0_a43;
    ddp_act_budgets_rec.attribute_category := p0_a44;
    ddp_act_budgets_rec.attribute1 := p0_a45;
    ddp_act_budgets_rec.attribute2 := p0_a46;
    ddp_act_budgets_rec.attribute3 := p0_a47;
    ddp_act_budgets_rec.attribute4 := p0_a48;
    ddp_act_budgets_rec.attribute5 := p0_a49;
    ddp_act_budgets_rec.attribute6 := p0_a50;
    ddp_act_budgets_rec.attribute7 := p0_a51;
    ddp_act_budgets_rec.attribute8 := p0_a52;
    ddp_act_budgets_rec.attribute9 := p0_a53;
    ddp_act_budgets_rec.attribute10 := p0_a54;
    ddp_act_budgets_rec.attribute11 := p0_a55;
    ddp_act_budgets_rec.attribute12 := p0_a56;
    ddp_act_budgets_rec.attribute13 := p0_a57;
    ddp_act_budgets_rec.attribute14 := p0_a58;
    ddp_act_budgets_rec.attribute15 := p0_a59;
    ddp_act_budgets_rec.src_curr_req_amt := p0_a60;


    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.complete_act_budgets_rec(ddp_act_budgets_rec,
      ddx_act_budgets_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_act_budgets_rec.activity_budget_id;
    p1_a1 := ddx_act_budgets_rec.last_update_date;
    p1_a2 := ddx_act_budgets_rec.last_updated_by;
    p1_a3 := ddx_act_budgets_rec.creation_date;
    p1_a4 := ddx_act_budgets_rec.created_by;
    p1_a5 := ddx_act_budgets_rec.last_update_login;
    p1_a6 := ddx_act_budgets_rec.object_version_number;
    p1_a7 := ddx_act_budgets_rec.act_budget_used_by_id;
    p1_a8 := ddx_act_budgets_rec.arc_act_budget_used_by;
    p1_a9 := ddx_act_budgets_rec.budget_source_type;
    p1_a10 := ddx_act_budgets_rec.budget_source_id;
    p1_a11 := ddx_act_budgets_rec.transaction_type;
    p1_a12 := ddx_act_budgets_rec.request_amount;
    p1_a13 := ddx_act_budgets_rec.request_currency;
    p1_a14 := ddx_act_budgets_rec.request_date;
    p1_a15 := ddx_act_budgets_rec.user_status_id;
    p1_a16 := ddx_act_budgets_rec.status_code;
    p1_a17 := ddx_act_budgets_rec.approved_amount;
    p1_a18 := ddx_act_budgets_rec.approved_original_amount;
    p1_a19 := ddx_act_budgets_rec.approved_in_currency;
    p1_a20 := ddx_act_budgets_rec.approval_date;
    p1_a21 := ddx_act_budgets_rec.approver_id;
    p1_a22 := ddx_act_budgets_rec.spent_amount;
    p1_a23 := ddx_act_budgets_rec.partner_po_number;
    p1_a24 := ddx_act_budgets_rec.partner_po_date;
    p1_a25 := ddx_act_budgets_rec.partner_po_approver;
    p1_a26 := ddx_act_budgets_rec.adjusted_flag;
    p1_a27 := ddx_act_budgets_rec.posted_flag;
    p1_a28 := ddx_act_budgets_rec.justification;
    p1_a29 := ddx_act_budgets_rec.comment;
    p1_a30 := ddx_act_budgets_rec.parent_act_budget_id;
    p1_a31 := ddx_act_budgets_rec.contact_id;
    p1_a32 := ddx_act_budgets_rec.reason_code;
    p1_a33 := ddx_act_budgets_rec.transfer_type;
    p1_a34 := ddx_act_budgets_rec.requester_id;
    p1_a35 := ddx_act_budgets_rec.date_required_by;
    p1_a36 := ddx_act_budgets_rec.parent_source_id;
    p1_a37 := ddx_act_budgets_rec.parent_src_curr;
    p1_a38 := ddx_act_budgets_rec.parent_src_apprvd_amt;
    p1_a39 := ddx_act_budgets_rec.partner_holding_type;
    p1_a40 := ddx_act_budgets_rec.partner_address_id;
    p1_a41 := ddx_act_budgets_rec.vendor_id;
    p1_a42 := ddx_act_budgets_rec.owner_id;
    p1_a43 := ddx_act_budgets_rec.recal_flag;
    p1_a44 := ddx_act_budgets_rec.attribute_category;
    p1_a45 := ddx_act_budgets_rec.attribute1;
    p1_a46 := ddx_act_budgets_rec.attribute2;
    p1_a47 := ddx_act_budgets_rec.attribute3;
    p1_a48 := ddx_act_budgets_rec.attribute4;
    p1_a49 := ddx_act_budgets_rec.attribute5;
    p1_a50 := ddx_act_budgets_rec.attribute6;
    p1_a51 := ddx_act_budgets_rec.attribute7;
    p1_a52 := ddx_act_budgets_rec.attribute8;
    p1_a53 := ddx_act_budgets_rec.attribute9;
    p1_a54 := ddx_act_budgets_rec.attribute10;
    p1_a55 := ddx_act_budgets_rec.attribute11;
    p1_a56 := ddx_act_budgets_rec.attribute12;
    p1_a57 := ddx_act_budgets_rec.attribute13;
    p1_a58 := ddx_act_budgets_rec.attribute14;
    p1_a59 := ddx_act_budgets_rec.attribute15;
    p1_a60 := ddx_act_budgets_rec.src_curr_req_amt;
  end;

  procedure init_act_budgets_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  DATE
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  DATE
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  DATE
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR
    , p0_a29 out nocopy  VARCHAR
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  NUMBER
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  NUMBER
    , p0_a35 out nocopy  DATE
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  NUMBER
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  NUMBER
    , p0_a41 out nocopy  NUMBER
    , p0_a42 out nocopy  NUMBER
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
    , p0_a54 out nocopy  VARCHAR2
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  VARCHAR2
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  NUMBER
  )

  as
    ddx_act_budgets_rec ozf_actbudgets_pvt.act_budgets_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_actbudgets_pvt.init_act_budgets_rec(ddx_act_budgets_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_act_budgets_rec.activity_budget_id;
    p0_a1 := ddx_act_budgets_rec.last_update_date;
    p0_a2 := ddx_act_budgets_rec.last_updated_by;
    p0_a3 := ddx_act_budgets_rec.creation_date;
    p0_a4 := ddx_act_budgets_rec.created_by;
    p0_a5 := ddx_act_budgets_rec.last_update_login;
    p0_a6 := ddx_act_budgets_rec.object_version_number;
    p0_a7 := ddx_act_budgets_rec.act_budget_used_by_id;
    p0_a8 := ddx_act_budgets_rec.arc_act_budget_used_by;
    p0_a9 := ddx_act_budgets_rec.budget_source_type;
    p0_a10 := ddx_act_budgets_rec.budget_source_id;
    p0_a11 := ddx_act_budgets_rec.transaction_type;
    p0_a12 := ddx_act_budgets_rec.request_amount;
    p0_a13 := ddx_act_budgets_rec.request_currency;
    p0_a14 := ddx_act_budgets_rec.request_date;
    p0_a15 := ddx_act_budgets_rec.user_status_id;
    p0_a16 := ddx_act_budgets_rec.status_code;
    p0_a17 := ddx_act_budgets_rec.approved_amount;
    p0_a18 := ddx_act_budgets_rec.approved_original_amount;
    p0_a19 := ddx_act_budgets_rec.approved_in_currency;
    p0_a20 := ddx_act_budgets_rec.approval_date;
    p0_a21 := ddx_act_budgets_rec.approver_id;
    p0_a22 := ddx_act_budgets_rec.spent_amount;
    p0_a23 := ddx_act_budgets_rec.partner_po_number;
    p0_a24 := ddx_act_budgets_rec.partner_po_date;
    p0_a25 := ddx_act_budgets_rec.partner_po_approver;
    p0_a26 := ddx_act_budgets_rec.adjusted_flag;
    p0_a27 := ddx_act_budgets_rec.posted_flag;
    p0_a28 := ddx_act_budgets_rec.justification;
    p0_a29 := ddx_act_budgets_rec.comment;
    p0_a30 := ddx_act_budgets_rec.parent_act_budget_id;
    p0_a31 := ddx_act_budgets_rec.contact_id;
    p0_a32 := ddx_act_budgets_rec.reason_code;
    p0_a33 := ddx_act_budgets_rec.transfer_type;
    p0_a34 := ddx_act_budgets_rec.requester_id;
    p0_a35 := ddx_act_budgets_rec.date_required_by;
    p0_a36 := ddx_act_budgets_rec.parent_source_id;
    p0_a37 := ddx_act_budgets_rec.parent_src_curr;
    p0_a38 := ddx_act_budgets_rec.parent_src_apprvd_amt;
    p0_a39 := ddx_act_budgets_rec.partner_holding_type;
    p0_a40 := ddx_act_budgets_rec.partner_address_id;
    p0_a41 := ddx_act_budgets_rec.vendor_id;
    p0_a42 := ddx_act_budgets_rec.owner_id;
    p0_a43 := ddx_act_budgets_rec.recal_flag;
    p0_a44 := ddx_act_budgets_rec.attribute_category;
    p0_a45 := ddx_act_budgets_rec.attribute1;
    p0_a46 := ddx_act_budgets_rec.attribute2;
    p0_a47 := ddx_act_budgets_rec.attribute3;
    p0_a48 := ddx_act_budgets_rec.attribute4;
    p0_a49 := ddx_act_budgets_rec.attribute5;
    p0_a50 := ddx_act_budgets_rec.attribute6;
    p0_a51 := ddx_act_budgets_rec.attribute7;
    p0_a52 := ddx_act_budgets_rec.attribute8;
    p0_a53 := ddx_act_budgets_rec.attribute9;
    p0_a54 := ddx_act_budgets_rec.attribute10;
    p0_a55 := ddx_act_budgets_rec.attribute11;
    p0_a56 := ddx_act_budgets_rec.attribute12;
    p0_a57 := ddx_act_budgets_rec.attribute13;
    p0_a58 := ddx_act_budgets_rec.attribute14;
    p0_a59 := ddx_act_budgets_rec.attribute15;
    p0_a60 := ddx_act_budgets_rec.src_curr_req_amt;
  end;

end ozf_actbudgets_pvt_oaw;

/
