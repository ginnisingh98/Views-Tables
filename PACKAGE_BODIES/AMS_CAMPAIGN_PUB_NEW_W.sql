--------------------------------------------------------
--  DDL for Package Body AMS_CAMPAIGN_PUB_NEW_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMPAIGN_PUB_NEW_W" as
  /* $Header: amsacpnb.pls 120.0 2005/08/10 00:01:32 appldev noship $ */
  procedure create_campaign(p_api_version  NUMBER
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
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  DATE
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
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  DATE
    , p7_a38  DATE
    , p7_a39  DATE
    , p7_a40  DATE
    , p7_a41  DATE
    , p7_a42  DATE
    , p7_a43  DATE
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
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
    , p7_a85  NUMBER
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  NUMBER
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  NUMBER
    , p7_a93  VARCHAR2
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  NUMBER
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
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
    , x_camp_id out nocopy  NUMBER
  )

  as
    ddp_camp_rec ams_campaign_pvt.camp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_camp_rec.campaign_id := p7_a0;
    ddp_camp_rec.last_update_date := p7_a1;
    ddp_camp_rec.last_updated_by := p7_a2;
    ddp_camp_rec.creation_date := p7_a3;
    ddp_camp_rec.created_by := p7_a4;
    ddp_camp_rec.last_update_login := p7_a5;
    ddp_camp_rec.object_version_number := p7_a6;
    ddp_camp_rec.custom_setup_id := p7_a7;
    ddp_camp_rec.owner_user_id := p7_a8;
    ddp_camp_rec.user_status_id := p7_a9;
    ddp_camp_rec.status_code := p7_a10;
    ddp_camp_rec.status_date := p7_a11;
    ddp_camp_rec.active_flag := p7_a12;
    ddp_camp_rec.private_flag := p7_a13;
    ddp_camp_rec.partner_flag := p7_a14;
    ddp_camp_rec.template_flag := p7_a15;
    ddp_camp_rec.cascade_source_code_flag := p7_a16;
    ddp_camp_rec.inherit_attributes_flag := p7_a17;
    ddp_camp_rec.source_code := p7_a18;
    ddp_camp_rec.rollup_type := p7_a19;
    ddp_camp_rec.campaign_type := p7_a20;
    ddp_camp_rec.media_type_code := p7_a21;
    ddp_camp_rec.priority := p7_a22;
    ddp_camp_rec.fund_source_type := p7_a23;
    ddp_camp_rec.fund_source_id := p7_a24;
    ddp_camp_rec.parent_campaign_id := p7_a25;
    ddp_camp_rec.application_id := p7_a26;
    ddp_camp_rec.qp_list_header_id := p7_a27;
    ddp_camp_rec.media_id := p7_a28;
    ddp_camp_rec.channel_id := p7_a29;
    ddp_camp_rec.event_type := p7_a30;
    ddp_camp_rec.arc_channel_from := p7_a31;
    ddp_camp_rec.dscript_name := p7_a32;
    ddp_camp_rec.transaction_currency_code := p7_a33;
    ddp_camp_rec.functional_currency_code := p7_a34;
    ddp_camp_rec.budget_amount_tc := p7_a35;
    ddp_camp_rec.budget_amount_fc := p7_a36;
    ddp_camp_rec.forecasted_plan_start_date := p7_a37;
    ddp_camp_rec.forecasted_plan_end_date := p7_a38;
    ddp_camp_rec.forecasted_exec_start_date := p7_a39;
    ddp_camp_rec.forecasted_exec_end_date := p7_a40;
    ddp_camp_rec.actual_plan_start_date := p7_a41;
    ddp_camp_rec.actual_plan_end_date := p7_a42;
    ddp_camp_rec.actual_exec_start_date := p7_a43;
    ddp_camp_rec.actual_exec_end_date := p7_a44;
    ddp_camp_rec.inbound_url := p7_a45;
    ddp_camp_rec.inbound_email_id := p7_a46;
    ddp_camp_rec.inbound_phone_no := p7_a47;
    ddp_camp_rec.duration := p7_a48;
    ddp_camp_rec.duration_uom_code := p7_a49;
    ddp_camp_rec.ff_priority := p7_a50;
    ddp_camp_rec.ff_override_cover_letter := p7_a51;
    ddp_camp_rec.ff_shipping_method := p7_a52;
    ddp_camp_rec.ff_carrier := p7_a53;
    ddp_camp_rec.content_source := p7_a54;
    ddp_camp_rec.cc_call_strategy := p7_a55;
    ddp_camp_rec.cc_manager_user_id := p7_a56;
    ddp_camp_rec.forecasted_revenue := p7_a57;
    ddp_camp_rec.actual_revenue := p7_a58;
    ddp_camp_rec.forecasted_cost := p7_a59;
    ddp_camp_rec.actual_cost := p7_a60;
    ddp_camp_rec.forecasted_response := p7_a61;
    ddp_camp_rec.actual_response := p7_a62;
    ddp_camp_rec.target_response := p7_a63;
    ddp_camp_rec.country_code := p7_a64;
    ddp_camp_rec.language_code := p7_a65;
    ddp_camp_rec.attribute_category := p7_a66;
    ddp_camp_rec.attribute1 := p7_a67;
    ddp_camp_rec.attribute2 := p7_a68;
    ddp_camp_rec.attribute3 := p7_a69;
    ddp_camp_rec.attribute4 := p7_a70;
    ddp_camp_rec.attribute5 := p7_a71;
    ddp_camp_rec.attribute6 := p7_a72;
    ddp_camp_rec.attribute7 := p7_a73;
    ddp_camp_rec.attribute8 := p7_a74;
    ddp_camp_rec.attribute9 := p7_a75;
    ddp_camp_rec.attribute10 := p7_a76;
    ddp_camp_rec.attribute11 := p7_a77;
    ddp_camp_rec.attribute12 := p7_a78;
    ddp_camp_rec.attribute13 := p7_a79;
    ddp_camp_rec.attribute14 := p7_a80;
    ddp_camp_rec.attribute15 := p7_a81;
    ddp_camp_rec.campaign_name := p7_a82;
    ddp_camp_rec.campaign_theme := p7_a83;
    ddp_camp_rec.description := p7_a84;
    ddp_camp_rec.version_no := p7_a85;
    ddp_camp_rec.campaign_calendar := p7_a86;
    ddp_camp_rec.start_period_name := p7_a87;
    ddp_camp_rec.end_period_name := p7_a88;
    ddp_camp_rec.city_id := p7_a89;
    ddp_camp_rec.global_flag := p7_a90;
    ddp_camp_rec.show_campaign_flag := p7_a91;
    ddp_camp_rec.business_unit_id := p7_a92;
    ddp_camp_rec.accounts_closed_flag := p7_a93;
    ddp_camp_rec.task_id := p7_a94;
    ddp_camp_rec.related_event_from := p7_a95;
    ddp_camp_rec.related_event_id := p7_a96;
    ddp_camp_rec.program_attribute_category := p7_a97;
    ddp_camp_rec.program_attribute1 := p7_a98;
    ddp_camp_rec.program_attribute2 := p7_a99;
    ddp_camp_rec.program_attribute3 := p7_a100;
    ddp_camp_rec.program_attribute4 := p7_a101;
    ddp_camp_rec.program_attribute5 := p7_a102;
    ddp_camp_rec.program_attribute6 := p7_a103;
    ddp_camp_rec.program_attribute7 := p7_a104;
    ddp_camp_rec.program_attribute8 := p7_a105;
    ddp_camp_rec.program_attribute9 := p7_a106;
    ddp_camp_rec.program_attribute10 := p7_a107;
    ddp_camp_rec.program_attribute11 := p7_a108;
    ddp_camp_rec.program_attribute12 := p7_a109;
    ddp_camp_rec.program_attribute13 := p7_a110;
    ddp_camp_rec.program_attribute14 := p7_a111;
    ddp_camp_rec.program_attribute15 := p7_a112;


    -- here's the delegated call to the old PL/SQL routine
    ams_campaign_pub.create_campaign(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_camp_rec,
      x_camp_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_campaign(p_api_version  NUMBER
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
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  DATE
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
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  DATE
    , p7_a38  DATE
    , p7_a39  DATE
    , p7_a40  DATE
    , p7_a41  DATE
    , p7_a42  DATE
    , p7_a43  DATE
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
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
    , p7_a85  NUMBER
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  NUMBER
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  NUMBER
    , p7_a93  VARCHAR2
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  NUMBER
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
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
  )

  as
    ddp_camp_rec ams_campaign_pvt.camp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_camp_rec.campaign_id := p7_a0;
    ddp_camp_rec.last_update_date := p7_a1;
    ddp_camp_rec.last_updated_by := p7_a2;
    ddp_camp_rec.creation_date := p7_a3;
    ddp_camp_rec.created_by := p7_a4;
    ddp_camp_rec.last_update_login := p7_a5;
    ddp_camp_rec.object_version_number := p7_a6;
    ddp_camp_rec.custom_setup_id := p7_a7;
    ddp_camp_rec.owner_user_id := p7_a8;
    ddp_camp_rec.user_status_id := p7_a9;
    ddp_camp_rec.status_code := p7_a10;
    ddp_camp_rec.status_date := p7_a11;
    ddp_camp_rec.active_flag := p7_a12;
    ddp_camp_rec.private_flag := p7_a13;
    ddp_camp_rec.partner_flag := p7_a14;
    ddp_camp_rec.template_flag := p7_a15;
    ddp_camp_rec.cascade_source_code_flag := p7_a16;
    ddp_camp_rec.inherit_attributes_flag := p7_a17;
    ddp_camp_rec.source_code := p7_a18;
    ddp_camp_rec.rollup_type := p7_a19;
    ddp_camp_rec.campaign_type := p7_a20;
    ddp_camp_rec.media_type_code := p7_a21;
    ddp_camp_rec.priority := p7_a22;
    ddp_camp_rec.fund_source_type := p7_a23;
    ddp_camp_rec.fund_source_id := p7_a24;
    ddp_camp_rec.parent_campaign_id := p7_a25;
    ddp_camp_rec.application_id := p7_a26;
    ddp_camp_rec.qp_list_header_id := p7_a27;
    ddp_camp_rec.media_id := p7_a28;
    ddp_camp_rec.channel_id := p7_a29;
    ddp_camp_rec.event_type := p7_a30;
    ddp_camp_rec.arc_channel_from := p7_a31;
    ddp_camp_rec.dscript_name := p7_a32;
    ddp_camp_rec.transaction_currency_code := p7_a33;
    ddp_camp_rec.functional_currency_code := p7_a34;
    ddp_camp_rec.budget_amount_tc := p7_a35;
    ddp_camp_rec.budget_amount_fc := p7_a36;
    ddp_camp_rec.forecasted_plan_start_date := p7_a37;
    ddp_camp_rec.forecasted_plan_end_date := p7_a38;
    ddp_camp_rec.forecasted_exec_start_date := p7_a39;
    ddp_camp_rec.forecasted_exec_end_date := p7_a40;
    ddp_camp_rec.actual_plan_start_date := p7_a41;
    ddp_camp_rec.actual_plan_end_date := p7_a42;
    ddp_camp_rec.actual_exec_start_date := p7_a43;
    ddp_camp_rec.actual_exec_end_date := p7_a44;
    ddp_camp_rec.inbound_url := p7_a45;
    ddp_camp_rec.inbound_email_id := p7_a46;
    ddp_camp_rec.inbound_phone_no := p7_a47;
    ddp_camp_rec.duration := p7_a48;
    ddp_camp_rec.duration_uom_code := p7_a49;
    ddp_camp_rec.ff_priority := p7_a50;
    ddp_camp_rec.ff_override_cover_letter := p7_a51;
    ddp_camp_rec.ff_shipping_method := p7_a52;
    ddp_camp_rec.ff_carrier := p7_a53;
    ddp_camp_rec.content_source := p7_a54;
    ddp_camp_rec.cc_call_strategy := p7_a55;
    ddp_camp_rec.cc_manager_user_id := p7_a56;
    ddp_camp_rec.forecasted_revenue := p7_a57;
    ddp_camp_rec.actual_revenue := p7_a58;
    ddp_camp_rec.forecasted_cost := p7_a59;
    ddp_camp_rec.actual_cost := p7_a60;
    ddp_camp_rec.forecasted_response := p7_a61;
    ddp_camp_rec.actual_response := p7_a62;
    ddp_camp_rec.target_response := p7_a63;
    ddp_camp_rec.country_code := p7_a64;
    ddp_camp_rec.language_code := p7_a65;
    ddp_camp_rec.attribute_category := p7_a66;
    ddp_camp_rec.attribute1 := p7_a67;
    ddp_camp_rec.attribute2 := p7_a68;
    ddp_camp_rec.attribute3 := p7_a69;
    ddp_camp_rec.attribute4 := p7_a70;
    ddp_camp_rec.attribute5 := p7_a71;
    ddp_camp_rec.attribute6 := p7_a72;
    ddp_camp_rec.attribute7 := p7_a73;
    ddp_camp_rec.attribute8 := p7_a74;
    ddp_camp_rec.attribute9 := p7_a75;
    ddp_camp_rec.attribute10 := p7_a76;
    ddp_camp_rec.attribute11 := p7_a77;
    ddp_camp_rec.attribute12 := p7_a78;
    ddp_camp_rec.attribute13 := p7_a79;
    ddp_camp_rec.attribute14 := p7_a80;
    ddp_camp_rec.attribute15 := p7_a81;
    ddp_camp_rec.campaign_name := p7_a82;
    ddp_camp_rec.campaign_theme := p7_a83;
    ddp_camp_rec.description := p7_a84;
    ddp_camp_rec.version_no := p7_a85;
    ddp_camp_rec.campaign_calendar := p7_a86;
    ddp_camp_rec.start_period_name := p7_a87;
    ddp_camp_rec.end_period_name := p7_a88;
    ddp_camp_rec.city_id := p7_a89;
    ddp_camp_rec.global_flag := p7_a90;
    ddp_camp_rec.show_campaign_flag := p7_a91;
    ddp_camp_rec.business_unit_id := p7_a92;
    ddp_camp_rec.accounts_closed_flag := p7_a93;
    ddp_camp_rec.task_id := p7_a94;
    ddp_camp_rec.related_event_from := p7_a95;
    ddp_camp_rec.related_event_id := p7_a96;
    ddp_camp_rec.program_attribute_category := p7_a97;
    ddp_camp_rec.program_attribute1 := p7_a98;
    ddp_camp_rec.program_attribute2 := p7_a99;
    ddp_camp_rec.program_attribute3 := p7_a100;
    ddp_camp_rec.program_attribute4 := p7_a101;
    ddp_camp_rec.program_attribute5 := p7_a102;
    ddp_camp_rec.program_attribute6 := p7_a103;
    ddp_camp_rec.program_attribute7 := p7_a104;
    ddp_camp_rec.program_attribute8 := p7_a105;
    ddp_camp_rec.program_attribute9 := p7_a106;
    ddp_camp_rec.program_attribute10 := p7_a107;
    ddp_camp_rec.program_attribute11 := p7_a108;
    ddp_camp_rec.program_attribute12 := p7_a109;
    ddp_camp_rec.program_attribute13 := p7_a110;
    ddp_camp_rec.program_attribute14 := p7_a111;
    ddp_camp_rec.program_attribute15 := p7_a112;

    -- here's the delegated call to the old PL/SQL routine
    ams_campaign_pub.update_campaign(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_camp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_campaign(p_api_version  NUMBER
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
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
    , p6_a11  DATE
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  DATE
    , p6_a38  DATE
    , p6_a39  DATE
    , p6_a40  DATE
    , p6_a41  DATE
    , p6_a42  DATE
    , p6_a43  DATE
    , p6_a44  DATE
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  NUMBER
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  NUMBER
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  NUMBER
    , p6_a57  NUMBER
    , p6_a58  NUMBER
    , p6_a59  NUMBER
    , p6_a60  NUMBER
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  VARCHAR2
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
    , p6_a83  VARCHAR2
    , p6_a84  VARCHAR2
    , p6_a85  NUMBER
    , p6_a86  VARCHAR2
    , p6_a87  VARCHAR2
    , p6_a88  VARCHAR2
    , p6_a89  NUMBER
    , p6_a90  VARCHAR2
    , p6_a91  VARCHAR2
    , p6_a92  NUMBER
    , p6_a93  VARCHAR2
    , p6_a94  NUMBER
    , p6_a95  VARCHAR2
    , p6_a96  NUMBER
    , p6_a97  VARCHAR2
    , p6_a98  VARCHAR2
    , p6_a99  VARCHAR2
    , p6_a100  VARCHAR2
    , p6_a101  VARCHAR2
    , p6_a102  VARCHAR2
    , p6_a103  VARCHAR2
    , p6_a104  VARCHAR2
    , p6_a105  VARCHAR2
    , p6_a106  VARCHAR2
    , p6_a107  VARCHAR2
    , p6_a108  VARCHAR2
    , p6_a109  VARCHAR2
    , p6_a110  VARCHAR2
    , p6_a111  VARCHAR2
    , p6_a112  VARCHAR2
  )

  as
    ddp_camp_rec ams_campaign_pvt.camp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_camp_rec.campaign_id := p6_a0;
    ddp_camp_rec.last_update_date := p6_a1;
    ddp_camp_rec.last_updated_by := p6_a2;
    ddp_camp_rec.creation_date := p6_a3;
    ddp_camp_rec.created_by := p6_a4;
    ddp_camp_rec.last_update_login := p6_a5;
    ddp_camp_rec.object_version_number := p6_a6;
    ddp_camp_rec.custom_setup_id := p6_a7;
    ddp_camp_rec.owner_user_id := p6_a8;
    ddp_camp_rec.user_status_id := p6_a9;
    ddp_camp_rec.status_code := p6_a10;
    ddp_camp_rec.status_date := p6_a11;
    ddp_camp_rec.active_flag := p6_a12;
    ddp_camp_rec.private_flag := p6_a13;
    ddp_camp_rec.partner_flag := p6_a14;
    ddp_camp_rec.template_flag := p6_a15;
    ddp_camp_rec.cascade_source_code_flag := p6_a16;
    ddp_camp_rec.inherit_attributes_flag := p6_a17;
    ddp_camp_rec.source_code := p6_a18;
    ddp_camp_rec.rollup_type := p6_a19;
    ddp_camp_rec.campaign_type := p6_a20;
    ddp_camp_rec.media_type_code := p6_a21;
    ddp_camp_rec.priority := p6_a22;
    ddp_camp_rec.fund_source_type := p6_a23;
    ddp_camp_rec.fund_source_id := p6_a24;
    ddp_camp_rec.parent_campaign_id := p6_a25;
    ddp_camp_rec.application_id := p6_a26;
    ddp_camp_rec.qp_list_header_id := p6_a27;
    ddp_camp_rec.media_id := p6_a28;
    ddp_camp_rec.channel_id := p6_a29;
    ddp_camp_rec.event_type := p6_a30;
    ddp_camp_rec.arc_channel_from := p6_a31;
    ddp_camp_rec.dscript_name := p6_a32;
    ddp_camp_rec.transaction_currency_code := p6_a33;
    ddp_camp_rec.functional_currency_code := p6_a34;
    ddp_camp_rec.budget_amount_tc := p6_a35;
    ddp_camp_rec.budget_amount_fc := p6_a36;
    ddp_camp_rec.forecasted_plan_start_date := p6_a37;
    ddp_camp_rec.forecasted_plan_end_date := p6_a38;
    ddp_camp_rec.forecasted_exec_start_date := p6_a39;
    ddp_camp_rec.forecasted_exec_end_date := p6_a40;
    ddp_camp_rec.actual_plan_start_date := p6_a41;
    ddp_camp_rec.actual_plan_end_date := p6_a42;
    ddp_camp_rec.actual_exec_start_date := p6_a43;
    ddp_camp_rec.actual_exec_end_date := p6_a44;
    ddp_camp_rec.inbound_url := p6_a45;
    ddp_camp_rec.inbound_email_id := p6_a46;
    ddp_camp_rec.inbound_phone_no := p6_a47;
    ddp_camp_rec.duration := p6_a48;
    ddp_camp_rec.duration_uom_code := p6_a49;
    ddp_camp_rec.ff_priority := p6_a50;
    ddp_camp_rec.ff_override_cover_letter := p6_a51;
    ddp_camp_rec.ff_shipping_method := p6_a52;
    ddp_camp_rec.ff_carrier := p6_a53;
    ddp_camp_rec.content_source := p6_a54;
    ddp_camp_rec.cc_call_strategy := p6_a55;
    ddp_camp_rec.cc_manager_user_id := p6_a56;
    ddp_camp_rec.forecasted_revenue := p6_a57;
    ddp_camp_rec.actual_revenue := p6_a58;
    ddp_camp_rec.forecasted_cost := p6_a59;
    ddp_camp_rec.actual_cost := p6_a60;
    ddp_camp_rec.forecasted_response := p6_a61;
    ddp_camp_rec.actual_response := p6_a62;
    ddp_camp_rec.target_response := p6_a63;
    ddp_camp_rec.country_code := p6_a64;
    ddp_camp_rec.language_code := p6_a65;
    ddp_camp_rec.attribute_category := p6_a66;
    ddp_camp_rec.attribute1 := p6_a67;
    ddp_camp_rec.attribute2 := p6_a68;
    ddp_camp_rec.attribute3 := p6_a69;
    ddp_camp_rec.attribute4 := p6_a70;
    ddp_camp_rec.attribute5 := p6_a71;
    ddp_camp_rec.attribute6 := p6_a72;
    ddp_camp_rec.attribute7 := p6_a73;
    ddp_camp_rec.attribute8 := p6_a74;
    ddp_camp_rec.attribute9 := p6_a75;
    ddp_camp_rec.attribute10 := p6_a76;
    ddp_camp_rec.attribute11 := p6_a77;
    ddp_camp_rec.attribute12 := p6_a78;
    ddp_camp_rec.attribute13 := p6_a79;
    ddp_camp_rec.attribute14 := p6_a80;
    ddp_camp_rec.attribute15 := p6_a81;
    ddp_camp_rec.campaign_name := p6_a82;
    ddp_camp_rec.campaign_theme := p6_a83;
    ddp_camp_rec.description := p6_a84;
    ddp_camp_rec.version_no := p6_a85;
    ddp_camp_rec.campaign_calendar := p6_a86;
    ddp_camp_rec.start_period_name := p6_a87;
    ddp_camp_rec.end_period_name := p6_a88;
    ddp_camp_rec.city_id := p6_a89;
    ddp_camp_rec.global_flag := p6_a90;
    ddp_camp_rec.show_campaign_flag := p6_a91;
    ddp_camp_rec.business_unit_id := p6_a92;
    ddp_camp_rec.accounts_closed_flag := p6_a93;
    ddp_camp_rec.task_id := p6_a94;
    ddp_camp_rec.related_event_from := p6_a95;
    ddp_camp_rec.related_event_id := p6_a96;
    ddp_camp_rec.program_attribute_category := p6_a97;
    ddp_camp_rec.program_attribute1 := p6_a98;
    ddp_camp_rec.program_attribute2 := p6_a99;
    ddp_camp_rec.program_attribute3 := p6_a100;
    ddp_camp_rec.program_attribute4 := p6_a101;
    ddp_camp_rec.program_attribute5 := p6_a102;
    ddp_camp_rec.program_attribute6 := p6_a103;
    ddp_camp_rec.program_attribute7 := p6_a104;
    ddp_camp_rec.program_attribute8 := p6_a105;
    ddp_camp_rec.program_attribute9 := p6_a106;
    ddp_camp_rec.program_attribute10 := p6_a107;
    ddp_camp_rec.program_attribute11 := p6_a108;
    ddp_camp_rec.program_attribute12 := p6_a109;
    ddp_camp_rec.program_attribute13 := p6_a110;
    ddp_camp_rec.program_attribute14 := p6_a111;
    ddp_camp_rec.program_attribute15 := p6_a112;

    -- here's the delegated call to the old PL/SQL routine
    ams_campaign_pub.validate_campaign(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_camp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end ams_campaign_pub_new_w;

/
