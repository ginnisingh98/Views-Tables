--------------------------------------------------------
--  DDL for Package Body AMS_EVENTOFFER_PVT_W_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTOFFER_PVT_W_NEW" as
  /* $Header: amsaevob.pls 120.0 2005/08/24 12:06 sikalyan noship $ */
  procedure create_event_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  NUMBER
    , p4_a14  DATE
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  NUMBER
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  NUMBER
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  NUMBER
    , p4_a36  NUMBER
    , p4_a37  VARCHAR2
    , p4_a38  DATE
    , p4_a39  DATE
    , p4_a40  DATE
    , p4_a41  DATE
    , p4_a42  DATE
    , p4_a43  DATE
    , p4_a44  DATE
    , p4_a45  DATE
    , p4_a46  NUMBER
    , p4_a47  NUMBER
    , p4_a48  NUMBER
    , p4_a49  NUMBER
    , p4_a50  NUMBER
    , p4_a51  DATE
    , p4_a52  NUMBER
    , p4_a53  VARCHAR2
    , p4_a54  NUMBER
    , p4_a55  NUMBER
    , p4_a56  NUMBER
    , p4_a57  NUMBER
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  NUMBER
    , p4_a61  VARCHAR2
    , p4_a62  NUMBER
    , p4_a63  NUMBER
    , p4_a64  NUMBER
    , p4_a65  NUMBER
    , p4_a66  VARCHAR2
    , p4_a67  NUMBER
    , p4_a68  VARCHAR2
    , p4_a69  NUMBER
    , p4_a70  NUMBER
    , p4_a71  VARCHAR2
    , p4_a72  VARCHAR2
    , p4_a73  VARCHAR2
    , p4_a74  VARCHAR2
    , p4_a75  VARCHAR2
    , p4_a76  NUMBER
    , p4_a77  NUMBER
    , p4_a78  VARCHAR2
    , p4_a79  VARCHAR2
    , p4_a80  VARCHAR2
    , p4_a81  NUMBER
    , p4_a82  NUMBER
    , p4_a83  VARCHAR2
    , p4_a84  NUMBER
    , p4_a85  VARCHAR2
    , p4_a86  VARCHAR2
    , p4_a87  VARCHAR2
    , p4_a88  VARCHAR2
    , p4_a89  VARCHAR2
    , p4_a90  VARCHAR2
    , p4_a91  VARCHAR2
    , p4_a92  VARCHAR2
    , p4_a93  VARCHAR2
    , p4_a94  VARCHAR2
    , p4_a95  VARCHAR2
    , p4_a96  VARCHAR2
    , p4_a97  VARCHAR2
    , p4_a98  VARCHAR2
    , p4_a99  VARCHAR2
    , p4_a100  VARCHAR2
    , p4_a101  VARCHAR2
    , p4_a102  VARCHAR2
    , p4_a103  VARCHAR2
    , p4_a104  VARCHAR2
    , p4_a105  NUMBER
    , p4_a106  VARCHAR2
    , p4_a107  NUMBER
    , p4_a108  VARCHAR2
    , p4_a109  VARCHAR2
    , p4_a110  VARCHAR2
    , p4_a111  VARCHAR2
    , p4_a112  NUMBER
    , p4_a113  VARCHAR2
    , p4_a114  NUMBER
    , p4_a115  VARCHAR2
    , p4_a116  VARCHAR2
    , p4_a117  VARCHAR2
    , p4_a118  NUMBER
    , p4_a119  VARCHAR2
    , p4_a120  VARCHAR2
    , p4_a121  VARCHAR2
    , p4_a122  VARCHAR2
    , p4_a123  VARCHAR2
    , p4_a124  VARCHAR2
    , p4_a125  DATE
    , p4_a126  DATE
    , p4_a127  NUMBER
    , p4_a128  NUMBER
    , p4_a129  VARCHAR2
    , p4_a130  VARCHAR2
    , p4_a131  VARCHAR2
    , p4_a132  VARCHAR2
    , p4_a133  VARCHAR2
    , p4_a134  VARCHAR2
    , p4_a135  VARCHAR2
    , p4_a136  NUMBER
    , p4_a137  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_evo_id out nocopy  NUMBER
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_evo_rec.event_offer_id := p4_a0;
    ddp_evo_rec.last_update_date := p4_a1;
    ddp_evo_rec.last_updated_by := p4_a2;
    ddp_evo_rec.creation_date := p4_a3;
    ddp_evo_rec.created_by := p4_a4;
    ddp_evo_rec.last_update_login := p4_a5;
    ddp_evo_rec.object_version_number := p4_a6;
    ddp_evo_rec.application_id := p4_a7;
    ddp_evo_rec.event_header_id := p4_a8;
    ddp_evo_rec.private_flag := p4_a9;
    ddp_evo_rec.active_flag := p4_a10;
    ddp_evo_rec.source_code := p4_a11;
    ddp_evo_rec.event_level := p4_a12;
    ddp_evo_rec.user_status_id := p4_a13;
    ddp_evo_rec.last_status_date := p4_a14;
    ddp_evo_rec.system_status_code := p4_a15;
    ddp_evo_rec.event_type_code := p4_a16;
    ddp_evo_rec.event_delivery_method_id := p4_a17;
    ddp_evo_rec.event_delivery_method_code := p4_a18;
    ddp_evo_rec.event_required_flag := p4_a19;
    ddp_evo_rec.event_language_code := p4_a20;
    ddp_evo_rec.event_location_id := p4_a21;
    ddp_evo_rec.city := p4_a22;
    ddp_evo_rec.state := p4_a23;
    ddp_evo_rec.province := p4_a24;
    ddp_evo_rec.country := p4_a25;
    ddp_evo_rec.overflow_flag := p4_a26;
    ddp_evo_rec.partner_flag := p4_a27;
    ddp_evo_rec.event_standalone_flag := p4_a28;
    ddp_evo_rec.reg_frozen_flag := p4_a29;
    ddp_evo_rec.reg_required_flag := p4_a30;
    ddp_evo_rec.reg_charge_flag := p4_a31;
    ddp_evo_rec.reg_invited_only_flag := p4_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p4_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p4_a34;
    ddp_evo_rec.parent_event_offer_id := p4_a35;
    ddp_evo_rec.event_duration := p4_a36;
    ddp_evo_rec.event_duration_uom_code := p4_a37;
    ddp_evo_rec.event_start_date := p4_a38;
    ddp_evo_rec.event_start_date_time := p4_a39;
    ddp_evo_rec.event_end_date := p4_a40;
    ddp_evo_rec.event_end_date_time := p4_a41;
    ddp_evo_rec.reg_start_date := p4_a42;
    ddp_evo_rec.reg_start_time := p4_a43;
    ddp_evo_rec.reg_end_date := p4_a44;
    ddp_evo_rec.reg_end_time := p4_a45;
    ddp_evo_rec.reg_maximum_capacity := p4_a46;
    ddp_evo_rec.reg_overbook_pct := p4_a47;
    ddp_evo_rec.reg_effective_capacity := p4_a48;
    ddp_evo_rec.reg_waitlist_pct := p4_a49;
    ddp_evo_rec.reg_minimum_capacity := p4_a50;
    ddp_evo_rec.reg_minimum_req_by_date := p4_a51;
    ddp_evo_rec.inventory_item_id := p4_a52;
    ddp_evo_rec.inventory_item := p4_a53;
    ddp_evo_rec.organization_id := p4_a54;
    ddp_evo_rec.pricelist_header_id := p4_a55;
    ddp_evo_rec.pricelist_line_id := p4_a56;
    ddp_evo_rec.org_id := p4_a57;
    ddp_evo_rec.waitlist_action_type_code := p4_a58;
    ddp_evo_rec.stream_type_code := p4_a59;
    ddp_evo_rec.owner_user_id := p4_a60;
    ddp_evo_rec.event_full_flag := p4_a61;
    ddp_evo_rec.forecasted_revenue := p4_a62;
    ddp_evo_rec.actual_revenue := p4_a63;
    ddp_evo_rec.forecasted_cost := p4_a64;
    ddp_evo_rec.actual_cost := p4_a65;
    ddp_evo_rec.fund_source_type_code := p4_a66;
    ddp_evo_rec.fund_source_id := p4_a67;
    ddp_evo_rec.cert_credit_type_code := p4_a68;
    ddp_evo_rec.certification_credits := p4_a69;
    ddp_evo_rec.coordinator_id := p4_a70;
    ddp_evo_rec.priority_type_code := p4_a71;
    ddp_evo_rec.cancellation_reason_code := p4_a72;
    ddp_evo_rec.auto_register_flag := p4_a73;
    ddp_evo_rec.email := p4_a74;
    ddp_evo_rec.phone := p4_a75;
    ddp_evo_rec.fund_amount_tc := p4_a76;
    ddp_evo_rec.fund_amount_fc := p4_a77;
    ddp_evo_rec.currency_code_tc := p4_a78;
    ddp_evo_rec.currency_code_fc := p4_a79;
    ddp_evo_rec.url := p4_a80;
    ddp_evo_rec.timezone_id := p4_a81;
    ddp_evo_rec.event_venue_id := p4_a82;
    ddp_evo_rec.pricelist_header_currency_code := p4_a83;
    ddp_evo_rec.pricelist_list_price := p4_a84;
    ddp_evo_rec.inbound_script_name := p4_a85;
    ddp_evo_rec.attribute_category := p4_a86;
    ddp_evo_rec.attribute1 := p4_a87;
    ddp_evo_rec.attribute2 := p4_a88;
    ddp_evo_rec.attribute3 := p4_a89;
    ddp_evo_rec.attribute4 := p4_a90;
    ddp_evo_rec.attribute5 := p4_a91;
    ddp_evo_rec.attribute6 := p4_a92;
    ddp_evo_rec.attribute7 := p4_a93;
    ddp_evo_rec.attribute8 := p4_a94;
    ddp_evo_rec.attribute9 := p4_a95;
    ddp_evo_rec.attribute10 := p4_a96;
    ddp_evo_rec.attribute11 := p4_a97;
    ddp_evo_rec.attribute12 := p4_a98;
    ddp_evo_rec.attribute13 := p4_a99;
    ddp_evo_rec.attribute14 := p4_a100;
    ddp_evo_rec.attribute15 := p4_a101;
    ddp_evo_rec.event_offer_name := p4_a102;
    ddp_evo_rec.event_mktg_message := p4_a103;
    ddp_evo_rec.description := p4_a104;
    ddp_evo_rec.custom_setup_id := p4_a105;
    ddp_evo_rec.country_code := p4_a106;
    ddp_evo_rec.business_unit_id := p4_a107;
    ddp_evo_rec.event_calendar := p4_a108;
    ddp_evo_rec.start_period_name := p4_a109;
    ddp_evo_rec.end_period_name := p4_a110;
    ddp_evo_rec.global_flag := p4_a111;
    ddp_evo_rec.task_id := p4_a112;
    ddp_evo_rec.parent_type := p4_a113;
    ddp_evo_rec.parent_id := p4_a114;
    ddp_evo_rec.create_attendant_lead_flag := p4_a115;
    ddp_evo_rec.create_registrant_lead_flag := p4_a116;
    ddp_evo_rec.event_object_type := p4_a117;
    ddp_evo_rec.reg_timezone_id := p4_a118;
    ddp_evo_rec.event_password := p4_a119;
    ddp_evo_rec.record_event_flag := p4_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p4_a121;
    ddp_evo_rec.publish_attendees_flag := p4_a122;
    ddp_evo_rec.direct_join_flag := p4_a123;
    ddp_evo_rec.event_notification_method := p4_a124;
    ddp_evo_rec.actual_start_time := p4_a125;
    ddp_evo_rec.actual_end_time := p4_a126;
    ddp_evo_rec.server_id := p4_a127;
    ddp_evo_rec.owner_fnd_user_id := p4_a128;
    ddp_evo_rec.meeting_dial_in_info := p4_a129;
    ddp_evo_rec.meeting_email_subject := p4_a130;
    ddp_evo_rec.meeting_schedule_type := p4_a131;
    ddp_evo_rec.meeting_status := p4_a132;
    ddp_evo_rec.meeting_misc_info := p4_a133;
    ddp_evo_rec.publish_flag := p4_a134;
    ddp_evo_rec.meeting_encryption_key_code := p4_a135;
    ddp_evo_rec.number_of_attendees := p4_a136;
    ddp_evo_rec.event_purpose_code := p4_a137;





    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pvt.create_event_offer(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_evo_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_evo_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_event_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  NUMBER
    , p4_a14  DATE
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  NUMBER
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  NUMBER
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  NUMBER
    , p4_a36  NUMBER
    , p4_a37  VARCHAR2
    , p4_a38  DATE
    , p4_a39  DATE
    , p4_a40  DATE
    , p4_a41  DATE
    , p4_a42  DATE
    , p4_a43  DATE
    , p4_a44  DATE
    , p4_a45  DATE
    , p4_a46  NUMBER
    , p4_a47  NUMBER
    , p4_a48  NUMBER
    , p4_a49  NUMBER
    , p4_a50  NUMBER
    , p4_a51  DATE
    , p4_a52  NUMBER
    , p4_a53  VARCHAR2
    , p4_a54  NUMBER
    , p4_a55  NUMBER
    , p4_a56  NUMBER
    , p4_a57  NUMBER
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  NUMBER
    , p4_a61  VARCHAR2
    , p4_a62  NUMBER
    , p4_a63  NUMBER
    , p4_a64  NUMBER
    , p4_a65  NUMBER
    , p4_a66  VARCHAR2
    , p4_a67  NUMBER
    , p4_a68  VARCHAR2
    , p4_a69  NUMBER
    , p4_a70  NUMBER
    , p4_a71  VARCHAR2
    , p4_a72  VARCHAR2
    , p4_a73  VARCHAR2
    , p4_a74  VARCHAR2
    , p4_a75  VARCHAR2
    , p4_a76  NUMBER
    , p4_a77  NUMBER
    , p4_a78  VARCHAR2
    , p4_a79  VARCHAR2
    , p4_a80  VARCHAR2
    , p4_a81  NUMBER
    , p4_a82  NUMBER
    , p4_a83  VARCHAR2
    , p4_a84  NUMBER
    , p4_a85  VARCHAR2
    , p4_a86  VARCHAR2
    , p4_a87  VARCHAR2
    , p4_a88  VARCHAR2
    , p4_a89  VARCHAR2
    , p4_a90  VARCHAR2
    , p4_a91  VARCHAR2
    , p4_a92  VARCHAR2
    , p4_a93  VARCHAR2
    , p4_a94  VARCHAR2
    , p4_a95  VARCHAR2
    , p4_a96  VARCHAR2
    , p4_a97  VARCHAR2
    , p4_a98  VARCHAR2
    , p4_a99  VARCHAR2
    , p4_a100  VARCHAR2
    , p4_a101  VARCHAR2
    , p4_a102  VARCHAR2
    , p4_a103  VARCHAR2
    , p4_a104  VARCHAR2
    , p4_a105  NUMBER
    , p4_a106  VARCHAR2
    , p4_a107  NUMBER
    , p4_a108  VARCHAR2
    , p4_a109  VARCHAR2
    , p4_a110  VARCHAR2
    , p4_a111  VARCHAR2
    , p4_a112  NUMBER
    , p4_a113  VARCHAR2
    , p4_a114  NUMBER
    , p4_a115  VARCHAR2
    , p4_a116  VARCHAR2
    , p4_a117  VARCHAR2
    , p4_a118  NUMBER
    , p4_a119  VARCHAR2
    , p4_a120  VARCHAR2
    , p4_a121  VARCHAR2
    , p4_a122  VARCHAR2
    , p4_a123  VARCHAR2
    , p4_a124  VARCHAR2
    , p4_a125  DATE
    , p4_a126  DATE
    , p4_a127  NUMBER
    , p4_a128  NUMBER
    , p4_a129  VARCHAR2
    , p4_a130  VARCHAR2
    , p4_a131  VARCHAR2
    , p4_a132  VARCHAR2
    , p4_a133  VARCHAR2
    , p4_a134  VARCHAR2
    , p4_a135  VARCHAR2
    , p4_a136  NUMBER
    , p4_a137  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_evo_rec.event_offer_id := p4_a0;
    ddp_evo_rec.last_update_date := p4_a1;
    ddp_evo_rec.last_updated_by := p4_a2;
    ddp_evo_rec.creation_date := p4_a3;
    ddp_evo_rec.created_by := p4_a4;
    ddp_evo_rec.last_update_login := p4_a5;
    ddp_evo_rec.object_version_number := p4_a6;
    ddp_evo_rec.application_id := p4_a7;
    ddp_evo_rec.event_header_id := p4_a8;
    ddp_evo_rec.private_flag := p4_a9;
    ddp_evo_rec.active_flag := p4_a10;
    ddp_evo_rec.source_code := p4_a11;
    ddp_evo_rec.event_level := p4_a12;
    ddp_evo_rec.user_status_id := p4_a13;
    ddp_evo_rec.last_status_date := p4_a14;
    ddp_evo_rec.system_status_code := p4_a15;
    ddp_evo_rec.event_type_code := p4_a16;
    ddp_evo_rec.event_delivery_method_id := p4_a17;
    ddp_evo_rec.event_delivery_method_code := p4_a18;
    ddp_evo_rec.event_required_flag := p4_a19;
    ddp_evo_rec.event_language_code := p4_a20;
    ddp_evo_rec.event_location_id := p4_a21;
    ddp_evo_rec.city := p4_a22;
    ddp_evo_rec.state := p4_a23;
    ddp_evo_rec.province := p4_a24;
    ddp_evo_rec.country := p4_a25;
    ddp_evo_rec.overflow_flag := p4_a26;
    ddp_evo_rec.partner_flag := p4_a27;
    ddp_evo_rec.event_standalone_flag := p4_a28;
    ddp_evo_rec.reg_frozen_flag := p4_a29;
    ddp_evo_rec.reg_required_flag := p4_a30;
    ddp_evo_rec.reg_charge_flag := p4_a31;
    ddp_evo_rec.reg_invited_only_flag := p4_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p4_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p4_a34;
    ddp_evo_rec.parent_event_offer_id := p4_a35;
    ddp_evo_rec.event_duration := p4_a36;
    ddp_evo_rec.event_duration_uom_code := p4_a37;
    ddp_evo_rec.event_start_date := p4_a38;
    ddp_evo_rec.event_start_date_time := p4_a39;
    ddp_evo_rec.event_end_date := p4_a40;
    ddp_evo_rec.event_end_date_time := p4_a41;
    ddp_evo_rec.reg_start_date := p4_a42;
    ddp_evo_rec.reg_start_time := p4_a43;
    ddp_evo_rec.reg_end_date := p4_a44;
    ddp_evo_rec.reg_end_time := p4_a45;
    ddp_evo_rec.reg_maximum_capacity := p4_a46;
    ddp_evo_rec.reg_overbook_pct := p4_a47;
    ddp_evo_rec.reg_effective_capacity := p4_a48;
    ddp_evo_rec.reg_waitlist_pct := p4_a49;
    ddp_evo_rec.reg_minimum_capacity := p4_a50;
    ddp_evo_rec.reg_minimum_req_by_date := p4_a51;
    ddp_evo_rec.inventory_item_id := p4_a52;
    ddp_evo_rec.inventory_item := p4_a53;
    ddp_evo_rec.organization_id := p4_a54;
    ddp_evo_rec.pricelist_header_id := p4_a55;
    ddp_evo_rec.pricelist_line_id := p4_a56;
    ddp_evo_rec.org_id := p4_a57;
    ddp_evo_rec.waitlist_action_type_code := p4_a58;
    ddp_evo_rec.stream_type_code := p4_a59;
    ddp_evo_rec.owner_user_id := p4_a60;
    ddp_evo_rec.event_full_flag := p4_a61;
    ddp_evo_rec.forecasted_revenue := p4_a62;
    ddp_evo_rec.actual_revenue := p4_a63;
    ddp_evo_rec.forecasted_cost := p4_a64;
    ddp_evo_rec.actual_cost := p4_a65;
    ddp_evo_rec.fund_source_type_code := p4_a66;
    ddp_evo_rec.fund_source_id := p4_a67;
    ddp_evo_rec.cert_credit_type_code := p4_a68;
    ddp_evo_rec.certification_credits := p4_a69;
    ddp_evo_rec.coordinator_id := p4_a70;
    ddp_evo_rec.priority_type_code := p4_a71;
    ddp_evo_rec.cancellation_reason_code := p4_a72;
    ddp_evo_rec.auto_register_flag := p4_a73;
    ddp_evo_rec.email := p4_a74;
    ddp_evo_rec.phone := p4_a75;
    ddp_evo_rec.fund_amount_tc := p4_a76;
    ddp_evo_rec.fund_amount_fc := p4_a77;
    ddp_evo_rec.currency_code_tc := p4_a78;
    ddp_evo_rec.currency_code_fc := p4_a79;
    ddp_evo_rec.url := p4_a80;
    ddp_evo_rec.timezone_id := p4_a81;
    ddp_evo_rec.event_venue_id := p4_a82;
    ddp_evo_rec.pricelist_header_currency_code := p4_a83;
    ddp_evo_rec.pricelist_list_price := p4_a84;
    ddp_evo_rec.inbound_script_name := p4_a85;
    ddp_evo_rec.attribute_category := p4_a86;
    ddp_evo_rec.attribute1 := p4_a87;
    ddp_evo_rec.attribute2 := p4_a88;
    ddp_evo_rec.attribute3 := p4_a89;
    ddp_evo_rec.attribute4 := p4_a90;
    ddp_evo_rec.attribute5 := p4_a91;
    ddp_evo_rec.attribute6 := p4_a92;
    ddp_evo_rec.attribute7 := p4_a93;
    ddp_evo_rec.attribute8 := p4_a94;
    ddp_evo_rec.attribute9 := p4_a95;
    ddp_evo_rec.attribute10 := p4_a96;
    ddp_evo_rec.attribute11 := p4_a97;
    ddp_evo_rec.attribute12 := p4_a98;
    ddp_evo_rec.attribute13 := p4_a99;
    ddp_evo_rec.attribute14 := p4_a100;
    ddp_evo_rec.attribute15 := p4_a101;
    ddp_evo_rec.event_offer_name := p4_a102;
    ddp_evo_rec.event_mktg_message := p4_a103;
    ddp_evo_rec.description := p4_a104;
    ddp_evo_rec.custom_setup_id := p4_a105;
    ddp_evo_rec.country_code := p4_a106;
    ddp_evo_rec.business_unit_id := p4_a107;
    ddp_evo_rec.event_calendar := p4_a108;
    ddp_evo_rec.start_period_name := p4_a109;
    ddp_evo_rec.end_period_name := p4_a110;
    ddp_evo_rec.global_flag := p4_a111;
    ddp_evo_rec.task_id := p4_a112;
    ddp_evo_rec.parent_type := p4_a113;
    ddp_evo_rec.parent_id := p4_a114;
    ddp_evo_rec.create_attendant_lead_flag := p4_a115;
    ddp_evo_rec.create_registrant_lead_flag := p4_a116;
    ddp_evo_rec.event_object_type := p4_a117;
    ddp_evo_rec.reg_timezone_id := p4_a118;
    ddp_evo_rec.event_password := p4_a119;
    ddp_evo_rec.record_event_flag := p4_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p4_a121;
    ddp_evo_rec.publish_attendees_flag := p4_a122;
    ddp_evo_rec.direct_join_flag := p4_a123;
    ddp_evo_rec.event_notification_method := p4_a124;
    ddp_evo_rec.actual_start_time := p4_a125;
    ddp_evo_rec.actual_end_time := p4_a126;
    ddp_evo_rec.server_id := p4_a127;
    ddp_evo_rec.owner_fnd_user_id := p4_a128;
    ddp_evo_rec.meeting_dial_in_info := p4_a129;
    ddp_evo_rec.meeting_email_subject := p4_a130;
    ddp_evo_rec.meeting_schedule_type := p4_a131;
    ddp_evo_rec.meeting_status := p4_a132;
    ddp_evo_rec.meeting_misc_info := p4_a133;
    ddp_evo_rec.publish_flag := p4_a134;
    ddp_evo_rec.meeting_encryption_key_code := p4_a135;
    ddp_evo_rec.number_of_attendees := p4_a136;
    ddp_evo_rec.event_purpose_code := p4_a137;




    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pvt.update_event_offer(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_evo_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_event_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  DATE
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  NUMBER
    , p3_a14  DATE
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  NUMBER
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
    , p3_a36  NUMBER
    , p3_a37  VARCHAR2
    , p3_a38  DATE
    , p3_a39  DATE
    , p3_a40  DATE
    , p3_a41  DATE
    , p3_a42  DATE
    , p3_a43  DATE
    , p3_a44  DATE
    , p3_a45  DATE
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  DATE
    , p3_a52  NUMBER
    , p3_a53  VARCHAR2
    , p3_a54  NUMBER
    , p3_a55  NUMBER
    , p3_a56  NUMBER
    , p3_a57  NUMBER
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
    , p3_a62  NUMBER
    , p3_a63  NUMBER
    , p3_a64  NUMBER
    , p3_a65  NUMBER
    , p3_a66  VARCHAR2
    , p3_a67  NUMBER
    , p3_a68  VARCHAR2
    , p3_a69  NUMBER
    , p3_a70  NUMBER
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  VARCHAR2
    , p3_a76  NUMBER
    , p3_a77  NUMBER
    , p3_a78  VARCHAR2
    , p3_a79  VARCHAR2
    , p3_a80  VARCHAR2
    , p3_a81  NUMBER
    , p3_a82  NUMBER
    , p3_a83  VARCHAR2
    , p3_a84  NUMBER
    , p3_a85  VARCHAR2
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  VARCHAR2
    , p3_a91  VARCHAR2
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  VARCHAR2
    , p3_a96  VARCHAR2
    , p3_a97  VARCHAR2
    , p3_a98  VARCHAR2
    , p3_a99  VARCHAR2
    , p3_a100  VARCHAR2
    , p3_a101  VARCHAR2
    , p3_a102  VARCHAR2
    , p3_a103  VARCHAR2
    , p3_a104  VARCHAR2
    , p3_a105  NUMBER
    , p3_a106  VARCHAR2
    , p3_a107  NUMBER
    , p3_a108  VARCHAR2
    , p3_a109  VARCHAR2
    , p3_a110  VARCHAR2
    , p3_a111  VARCHAR2
    , p3_a112  NUMBER
    , p3_a113  VARCHAR2
    , p3_a114  NUMBER
    , p3_a115  VARCHAR2
    , p3_a116  VARCHAR2
    , p3_a117  VARCHAR2
    , p3_a118  NUMBER
    , p3_a119  VARCHAR2
    , p3_a120  VARCHAR2
    , p3_a121  VARCHAR2
    , p3_a122  VARCHAR2
    , p3_a123  VARCHAR2
    , p3_a124  VARCHAR2
    , p3_a125  DATE
    , p3_a126  DATE
    , p3_a127  NUMBER
    , p3_a128  NUMBER
    , p3_a129  VARCHAR2
    , p3_a130  VARCHAR2
    , p3_a131  VARCHAR2
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  VARCHAR2
    , p3_a136  NUMBER
    , p3_a137  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_evo_rec.event_offer_id := p3_a0;
    ddp_evo_rec.last_update_date := p3_a1;
    ddp_evo_rec.last_updated_by := p3_a2;
    ddp_evo_rec.creation_date := p3_a3;
    ddp_evo_rec.created_by := p3_a4;
    ddp_evo_rec.last_update_login := p3_a5;
    ddp_evo_rec.object_version_number := p3_a6;
    ddp_evo_rec.application_id := p3_a7;
    ddp_evo_rec.event_header_id := p3_a8;
    ddp_evo_rec.private_flag := p3_a9;
    ddp_evo_rec.active_flag := p3_a10;
    ddp_evo_rec.source_code := p3_a11;
    ddp_evo_rec.event_level := p3_a12;
    ddp_evo_rec.user_status_id := p3_a13;
    ddp_evo_rec.last_status_date := p3_a14;
    ddp_evo_rec.system_status_code := p3_a15;
    ddp_evo_rec.event_type_code := p3_a16;
    ddp_evo_rec.event_delivery_method_id := p3_a17;
    ddp_evo_rec.event_delivery_method_code := p3_a18;
    ddp_evo_rec.event_required_flag := p3_a19;
    ddp_evo_rec.event_language_code := p3_a20;
    ddp_evo_rec.event_location_id := p3_a21;
    ddp_evo_rec.city := p3_a22;
    ddp_evo_rec.state := p3_a23;
    ddp_evo_rec.province := p3_a24;
    ddp_evo_rec.country := p3_a25;
    ddp_evo_rec.overflow_flag := p3_a26;
    ddp_evo_rec.partner_flag := p3_a27;
    ddp_evo_rec.event_standalone_flag := p3_a28;
    ddp_evo_rec.reg_frozen_flag := p3_a29;
    ddp_evo_rec.reg_required_flag := p3_a30;
    ddp_evo_rec.reg_charge_flag := p3_a31;
    ddp_evo_rec.reg_invited_only_flag := p3_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p3_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p3_a34;
    ddp_evo_rec.parent_event_offer_id := p3_a35;
    ddp_evo_rec.event_duration := p3_a36;
    ddp_evo_rec.event_duration_uom_code := p3_a37;
    ddp_evo_rec.event_start_date := p3_a38;
    ddp_evo_rec.event_start_date_time := p3_a39;
    ddp_evo_rec.event_end_date := p3_a40;
    ddp_evo_rec.event_end_date_time := p3_a41;
    ddp_evo_rec.reg_start_date := p3_a42;
    ddp_evo_rec.reg_start_time := p3_a43;
    ddp_evo_rec.reg_end_date := p3_a44;
    ddp_evo_rec.reg_end_time := p3_a45;
    ddp_evo_rec.reg_maximum_capacity := p3_a46;
    ddp_evo_rec.reg_overbook_pct := p3_a47;
    ddp_evo_rec.reg_effective_capacity := p3_a48;
    ddp_evo_rec.reg_waitlist_pct := p3_a49;
    ddp_evo_rec.reg_minimum_capacity := p3_a50;
    ddp_evo_rec.reg_minimum_req_by_date := p3_a51;
    ddp_evo_rec.inventory_item_id := p3_a52;
    ddp_evo_rec.inventory_item := p3_a53;
    ddp_evo_rec.organization_id := p3_a54;
    ddp_evo_rec.pricelist_header_id := p3_a55;
    ddp_evo_rec.pricelist_line_id := p3_a56;
    ddp_evo_rec.org_id := p3_a57;
    ddp_evo_rec.waitlist_action_type_code := p3_a58;
    ddp_evo_rec.stream_type_code := p3_a59;
    ddp_evo_rec.owner_user_id := p3_a60;
    ddp_evo_rec.event_full_flag := p3_a61;
    ddp_evo_rec.forecasted_revenue := p3_a62;
    ddp_evo_rec.actual_revenue := p3_a63;
    ddp_evo_rec.forecasted_cost := p3_a64;
    ddp_evo_rec.actual_cost := p3_a65;
    ddp_evo_rec.fund_source_type_code := p3_a66;
    ddp_evo_rec.fund_source_id := p3_a67;
    ddp_evo_rec.cert_credit_type_code := p3_a68;
    ddp_evo_rec.certification_credits := p3_a69;
    ddp_evo_rec.coordinator_id := p3_a70;
    ddp_evo_rec.priority_type_code := p3_a71;
    ddp_evo_rec.cancellation_reason_code := p3_a72;
    ddp_evo_rec.auto_register_flag := p3_a73;
    ddp_evo_rec.email := p3_a74;
    ddp_evo_rec.phone := p3_a75;
    ddp_evo_rec.fund_amount_tc := p3_a76;
    ddp_evo_rec.fund_amount_fc := p3_a77;
    ddp_evo_rec.currency_code_tc := p3_a78;
    ddp_evo_rec.currency_code_fc := p3_a79;
    ddp_evo_rec.url := p3_a80;
    ddp_evo_rec.timezone_id := p3_a81;
    ddp_evo_rec.event_venue_id := p3_a82;
    ddp_evo_rec.pricelist_header_currency_code := p3_a83;
    ddp_evo_rec.pricelist_list_price := p3_a84;
    ddp_evo_rec.inbound_script_name := p3_a85;
    ddp_evo_rec.attribute_category := p3_a86;
    ddp_evo_rec.attribute1 := p3_a87;
    ddp_evo_rec.attribute2 := p3_a88;
    ddp_evo_rec.attribute3 := p3_a89;
    ddp_evo_rec.attribute4 := p3_a90;
    ddp_evo_rec.attribute5 := p3_a91;
    ddp_evo_rec.attribute6 := p3_a92;
    ddp_evo_rec.attribute7 := p3_a93;
    ddp_evo_rec.attribute8 := p3_a94;
    ddp_evo_rec.attribute9 := p3_a95;
    ddp_evo_rec.attribute10 := p3_a96;
    ddp_evo_rec.attribute11 := p3_a97;
    ddp_evo_rec.attribute12 := p3_a98;
    ddp_evo_rec.attribute13 := p3_a99;
    ddp_evo_rec.attribute14 := p3_a100;
    ddp_evo_rec.attribute15 := p3_a101;
    ddp_evo_rec.event_offer_name := p3_a102;
    ddp_evo_rec.event_mktg_message := p3_a103;
    ddp_evo_rec.description := p3_a104;
    ddp_evo_rec.custom_setup_id := p3_a105;
    ddp_evo_rec.country_code := p3_a106;
    ddp_evo_rec.business_unit_id := p3_a107;
    ddp_evo_rec.event_calendar := p3_a108;
    ddp_evo_rec.start_period_name := p3_a109;
    ddp_evo_rec.end_period_name := p3_a110;
    ddp_evo_rec.global_flag := p3_a111;
    ddp_evo_rec.task_id := p3_a112;
    ddp_evo_rec.parent_type := p3_a113;
    ddp_evo_rec.parent_id := p3_a114;
    ddp_evo_rec.create_attendant_lead_flag := p3_a115;
    ddp_evo_rec.create_registrant_lead_flag := p3_a116;
    ddp_evo_rec.event_object_type := p3_a117;
    ddp_evo_rec.reg_timezone_id := p3_a118;
    ddp_evo_rec.event_password := p3_a119;
    ddp_evo_rec.record_event_flag := p3_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p3_a121;
    ddp_evo_rec.publish_attendees_flag := p3_a122;
    ddp_evo_rec.direct_join_flag := p3_a123;
    ddp_evo_rec.event_notification_method := p3_a124;
    ddp_evo_rec.actual_start_time := p3_a125;
    ddp_evo_rec.actual_end_time := p3_a126;
    ddp_evo_rec.server_id := p3_a127;
    ddp_evo_rec.owner_fnd_user_id := p3_a128;
    ddp_evo_rec.meeting_dial_in_info := p3_a129;
    ddp_evo_rec.meeting_email_subject := p3_a130;
    ddp_evo_rec.meeting_schedule_type := p3_a131;
    ddp_evo_rec.meeting_status := p3_a132;
    ddp_evo_rec.meeting_misc_info := p3_a133;
    ddp_evo_rec.publish_flag := p3_a134;
    ddp_evo_rec.meeting_encryption_key_code := p3_a135;
    ddp_evo_rec.number_of_attendees := p3_a136;
    ddp_evo_rec.event_purpose_code := p3_a137;




    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pvt.validate_event_offer(p_api_version,
      p_init_msg_list,
      p_validation_level,
      ddp_evo_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_evo_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  DATE
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  DATE
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  DATE
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  DATE
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  VARCHAR2
    , p0_a84  NUMBER
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p0_a93  VARCHAR2
    , p0_a94  VARCHAR2
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  VARCHAR2
    , p0_a98  VARCHAR2
    , p0_a99  VARCHAR2
    , p0_a100  VARCHAR2
    , p0_a101  VARCHAR2
    , p0_a102  VARCHAR2
    , p0_a103  VARCHAR2
    , p0_a104  VARCHAR2
    , p0_a105  NUMBER
    , p0_a106  VARCHAR2
    , p0_a107  NUMBER
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  VARCHAR2
    , p0_a111  VARCHAR2
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  NUMBER
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  DATE
    , p0_a126  DATE
    , p0_a127  NUMBER
    , p0_a128  NUMBER
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  VARCHAR2
    , p0_a132  VARCHAR2
    , p0_a133  VARCHAR2
    , p0_a134  VARCHAR2
    , p0_a135  VARCHAR2
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evo_rec.event_offer_id := p0_a0;
    ddp_evo_rec.last_update_date := p0_a1;
    ddp_evo_rec.last_updated_by := p0_a2;
    ddp_evo_rec.creation_date := p0_a3;
    ddp_evo_rec.created_by := p0_a4;
    ddp_evo_rec.last_update_login := p0_a5;
    ddp_evo_rec.object_version_number := p0_a6;
    ddp_evo_rec.application_id := p0_a7;
    ddp_evo_rec.event_header_id := p0_a8;
    ddp_evo_rec.private_flag := p0_a9;
    ddp_evo_rec.active_flag := p0_a10;
    ddp_evo_rec.source_code := p0_a11;
    ddp_evo_rec.event_level := p0_a12;
    ddp_evo_rec.user_status_id := p0_a13;
    ddp_evo_rec.last_status_date := p0_a14;
    ddp_evo_rec.system_status_code := p0_a15;
    ddp_evo_rec.event_type_code := p0_a16;
    ddp_evo_rec.event_delivery_method_id := p0_a17;
    ddp_evo_rec.event_delivery_method_code := p0_a18;
    ddp_evo_rec.event_required_flag := p0_a19;
    ddp_evo_rec.event_language_code := p0_a20;
    ddp_evo_rec.event_location_id := p0_a21;
    ddp_evo_rec.city := p0_a22;
    ddp_evo_rec.state := p0_a23;
    ddp_evo_rec.province := p0_a24;
    ddp_evo_rec.country := p0_a25;
    ddp_evo_rec.overflow_flag := p0_a26;
    ddp_evo_rec.partner_flag := p0_a27;
    ddp_evo_rec.event_standalone_flag := p0_a28;
    ddp_evo_rec.reg_frozen_flag := p0_a29;
    ddp_evo_rec.reg_required_flag := p0_a30;
    ddp_evo_rec.reg_charge_flag := p0_a31;
    ddp_evo_rec.reg_invited_only_flag := p0_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p0_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p0_a34;
    ddp_evo_rec.parent_event_offer_id := p0_a35;
    ddp_evo_rec.event_duration := p0_a36;
    ddp_evo_rec.event_duration_uom_code := p0_a37;
    ddp_evo_rec.event_start_date := p0_a38;
    ddp_evo_rec.event_start_date_time := p0_a39;
    ddp_evo_rec.event_end_date := p0_a40;
    ddp_evo_rec.event_end_date_time := p0_a41;
    ddp_evo_rec.reg_start_date := p0_a42;
    ddp_evo_rec.reg_start_time := p0_a43;
    ddp_evo_rec.reg_end_date := p0_a44;
    ddp_evo_rec.reg_end_time := p0_a45;
    ddp_evo_rec.reg_maximum_capacity := p0_a46;
    ddp_evo_rec.reg_overbook_pct := p0_a47;
    ddp_evo_rec.reg_effective_capacity := p0_a48;
    ddp_evo_rec.reg_waitlist_pct := p0_a49;
    ddp_evo_rec.reg_minimum_capacity := p0_a50;
    ddp_evo_rec.reg_minimum_req_by_date := p0_a51;
    ddp_evo_rec.inventory_item_id := p0_a52;
    ddp_evo_rec.inventory_item := p0_a53;
    ddp_evo_rec.organization_id := p0_a54;
    ddp_evo_rec.pricelist_header_id := p0_a55;
    ddp_evo_rec.pricelist_line_id := p0_a56;
    ddp_evo_rec.org_id := p0_a57;
    ddp_evo_rec.waitlist_action_type_code := p0_a58;
    ddp_evo_rec.stream_type_code := p0_a59;
    ddp_evo_rec.owner_user_id := p0_a60;
    ddp_evo_rec.event_full_flag := p0_a61;
    ddp_evo_rec.forecasted_revenue := p0_a62;
    ddp_evo_rec.actual_revenue := p0_a63;
    ddp_evo_rec.forecasted_cost := p0_a64;
    ddp_evo_rec.actual_cost := p0_a65;
    ddp_evo_rec.fund_source_type_code := p0_a66;
    ddp_evo_rec.fund_source_id := p0_a67;
    ddp_evo_rec.cert_credit_type_code := p0_a68;
    ddp_evo_rec.certification_credits := p0_a69;
    ddp_evo_rec.coordinator_id := p0_a70;
    ddp_evo_rec.priority_type_code := p0_a71;
    ddp_evo_rec.cancellation_reason_code := p0_a72;
    ddp_evo_rec.auto_register_flag := p0_a73;
    ddp_evo_rec.email := p0_a74;
    ddp_evo_rec.phone := p0_a75;
    ddp_evo_rec.fund_amount_tc := p0_a76;
    ddp_evo_rec.fund_amount_fc := p0_a77;
    ddp_evo_rec.currency_code_tc := p0_a78;
    ddp_evo_rec.currency_code_fc := p0_a79;
    ddp_evo_rec.url := p0_a80;
    ddp_evo_rec.timezone_id := p0_a81;
    ddp_evo_rec.event_venue_id := p0_a82;
    ddp_evo_rec.pricelist_header_currency_code := p0_a83;
    ddp_evo_rec.pricelist_list_price := p0_a84;
    ddp_evo_rec.inbound_script_name := p0_a85;
    ddp_evo_rec.attribute_category := p0_a86;
    ddp_evo_rec.attribute1 := p0_a87;
    ddp_evo_rec.attribute2 := p0_a88;
    ddp_evo_rec.attribute3 := p0_a89;
    ddp_evo_rec.attribute4 := p0_a90;
    ddp_evo_rec.attribute5 := p0_a91;
    ddp_evo_rec.attribute6 := p0_a92;
    ddp_evo_rec.attribute7 := p0_a93;
    ddp_evo_rec.attribute8 := p0_a94;
    ddp_evo_rec.attribute9 := p0_a95;
    ddp_evo_rec.attribute10 := p0_a96;
    ddp_evo_rec.attribute11 := p0_a97;
    ddp_evo_rec.attribute12 := p0_a98;
    ddp_evo_rec.attribute13 := p0_a99;
    ddp_evo_rec.attribute14 := p0_a100;
    ddp_evo_rec.attribute15 := p0_a101;
    ddp_evo_rec.event_offer_name := p0_a102;
    ddp_evo_rec.event_mktg_message := p0_a103;
    ddp_evo_rec.description := p0_a104;
    ddp_evo_rec.custom_setup_id := p0_a105;
    ddp_evo_rec.country_code := p0_a106;
    ddp_evo_rec.business_unit_id := p0_a107;
    ddp_evo_rec.event_calendar := p0_a108;
    ddp_evo_rec.start_period_name := p0_a109;
    ddp_evo_rec.end_period_name := p0_a110;
    ddp_evo_rec.global_flag := p0_a111;
    ddp_evo_rec.task_id := p0_a112;
    ddp_evo_rec.parent_type := p0_a113;
    ddp_evo_rec.parent_id := p0_a114;
    ddp_evo_rec.create_attendant_lead_flag := p0_a115;
    ddp_evo_rec.create_registrant_lead_flag := p0_a116;
    ddp_evo_rec.event_object_type := p0_a117;
    ddp_evo_rec.reg_timezone_id := p0_a118;
    ddp_evo_rec.event_password := p0_a119;
    ddp_evo_rec.record_event_flag := p0_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p0_a121;
    ddp_evo_rec.publish_attendees_flag := p0_a122;
    ddp_evo_rec.direct_join_flag := p0_a123;
    ddp_evo_rec.event_notification_method := p0_a124;
    ddp_evo_rec.actual_start_time := p0_a125;
    ddp_evo_rec.actual_end_time := p0_a126;
    ddp_evo_rec.server_id := p0_a127;
    ddp_evo_rec.owner_fnd_user_id := p0_a128;
    ddp_evo_rec.meeting_dial_in_info := p0_a129;
    ddp_evo_rec.meeting_email_subject := p0_a130;
    ddp_evo_rec.meeting_schedule_type := p0_a131;
    ddp_evo_rec.meeting_status := p0_a132;
    ddp_evo_rec.meeting_misc_info := p0_a133;
    ddp_evo_rec.publish_flag := p0_a134;
    ddp_evo_rec.meeting_encryption_key_code := p0_a135;
    ddp_evo_rec.number_of_attendees := p0_a136;
    ddp_evo_rec.event_purpose_code := p0_a137;



    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pvt.check_evo_items(ddp_evo_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_evo_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  DATE
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  DATE
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  DATE
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  DATE
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  VARCHAR2
    , p0_a84  NUMBER
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p0_a93  VARCHAR2
    , p0_a94  VARCHAR2
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  VARCHAR2
    , p0_a98  VARCHAR2
    , p0_a99  VARCHAR2
    , p0_a100  VARCHAR2
    , p0_a101  VARCHAR2
    , p0_a102  VARCHAR2
    , p0_a103  VARCHAR2
    , p0_a104  VARCHAR2
    , p0_a105  NUMBER
    , p0_a106  VARCHAR2
    , p0_a107  NUMBER
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  VARCHAR2
    , p0_a111  VARCHAR2
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  NUMBER
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  DATE
    , p0_a126  DATE
    , p0_a127  NUMBER
    , p0_a128  NUMBER
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  VARCHAR2
    , p0_a132  VARCHAR2
    , p0_a133  VARCHAR2
    , p0_a134  VARCHAR2
    , p0_a135  VARCHAR2
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  NUMBER
    , p1_a14  DATE
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  NUMBER
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  NUMBER
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p1_a32  VARCHAR2
    , p1_a33  VARCHAR2
    , p1_a34  VARCHAR2
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  VARCHAR2
    , p1_a38  DATE
    , p1_a39  DATE
    , p1_a40  DATE
    , p1_a41  DATE
    , p1_a42  DATE
    , p1_a43  DATE
    , p1_a44  DATE
    , p1_a45  DATE
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  DATE
    , p1_a52  NUMBER
    , p1_a53  VARCHAR2
    , p1_a54  NUMBER
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  NUMBER
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  NUMBER
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  VARCHAR2
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  NUMBER
    , p1_a70  NUMBER
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  VARCHAR2
    , p1_a76  NUMBER
    , p1_a77  NUMBER
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  NUMBER
    , p1_a82  NUMBER
    , p1_a83  VARCHAR2
    , p1_a84  NUMBER
    , p1_a85  VARCHAR2
    , p1_a86  VARCHAR2
    , p1_a87  VARCHAR2
    , p1_a88  VARCHAR2
    , p1_a89  VARCHAR2
    , p1_a90  VARCHAR2
    , p1_a91  VARCHAR2
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  VARCHAR2
    , p1_a96  VARCHAR2
    , p1_a97  VARCHAR2
    , p1_a98  VARCHAR2
    , p1_a99  VARCHAR2
    , p1_a100  VARCHAR2
    , p1_a101  VARCHAR2
    , p1_a102  VARCHAR2
    , p1_a103  VARCHAR2
    , p1_a104  VARCHAR2
    , p1_a105  NUMBER
    , p1_a106  VARCHAR2
    , p1_a107  NUMBER
    , p1_a108  VARCHAR2
    , p1_a109  VARCHAR2
    , p1_a110  VARCHAR2
    , p1_a111  VARCHAR2
    , p1_a112  NUMBER
    , p1_a113  VARCHAR2
    , p1_a114  NUMBER
    , p1_a115  VARCHAR2
    , p1_a116  VARCHAR2
    , p1_a117  VARCHAR2
    , p1_a118  NUMBER
    , p1_a119  VARCHAR2
    , p1_a120  VARCHAR2
    , p1_a121  VARCHAR2
    , p1_a122  VARCHAR2
    , p1_a123  VARCHAR2
    , p1_a124  VARCHAR2
    , p1_a125  DATE
    , p1_a126  DATE
    , p1_a127  NUMBER
    , p1_a128  NUMBER
    , p1_a129  VARCHAR2
    , p1_a130  VARCHAR2
    , p1_a131  VARCHAR2
    , p1_a132  VARCHAR2
    , p1_a133  VARCHAR2
    , p1_a134  VARCHAR2
    , p1_a135  VARCHAR2
    , p1_a136  NUMBER
    , p1_a137  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddp_complete_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evo_rec.event_offer_id := p0_a0;
    ddp_evo_rec.last_update_date := p0_a1;
    ddp_evo_rec.last_updated_by := p0_a2;
    ddp_evo_rec.creation_date := p0_a3;
    ddp_evo_rec.created_by := p0_a4;
    ddp_evo_rec.last_update_login := p0_a5;
    ddp_evo_rec.object_version_number := p0_a6;
    ddp_evo_rec.application_id := p0_a7;
    ddp_evo_rec.event_header_id := p0_a8;
    ddp_evo_rec.private_flag := p0_a9;
    ddp_evo_rec.active_flag := p0_a10;
    ddp_evo_rec.source_code := p0_a11;
    ddp_evo_rec.event_level := p0_a12;
    ddp_evo_rec.user_status_id := p0_a13;
    ddp_evo_rec.last_status_date := p0_a14;
    ddp_evo_rec.system_status_code := p0_a15;
    ddp_evo_rec.event_type_code := p0_a16;
    ddp_evo_rec.event_delivery_method_id := p0_a17;
    ddp_evo_rec.event_delivery_method_code := p0_a18;
    ddp_evo_rec.event_required_flag := p0_a19;
    ddp_evo_rec.event_language_code := p0_a20;
    ddp_evo_rec.event_location_id := p0_a21;
    ddp_evo_rec.city := p0_a22;
    ddp_evo_rec.state := p0_a23;
    ddp_evo_rec.province := p0_a24;
    ddp_evo_rec.country := p0_a25;
    ddp_evo_rec.overflow_flag := p0_a26;
    ddp_evo_rec.partner_flag := p0_a27;
    ddp_evo_rec.event_standalone_flag := p0_a28;
    ddp_evo_rec.reg_frozen_flag := p0_a29;
    ddp_evo_rec.reg_required_flag := p0_a30;
    ddp_evo_rec.reg_charge_flag := p0_a31;
    ddp_evo_rec.reg_invited_only_flag := p0_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p0_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p0_a34;
    ddp_evo_rec.parent_event_offer_id := p0_a35;
    ddp_evo_rec.event_duration := p0_a36;
    ddp_evo_rec.event_duration_uom_code := p0_a37;
    ddp_evo_rec.event_start_date := p0_a38;
    ddp_evo_rec.event_start_date_time := p0_a39;
    ddp_evo_rec.event_end_date := p0_a40;
    ddp_evo_rec.event_end_date_time := p0_a41;
    ddp_evo_rec.reg_start_date := p0_a42;
    ddp_evo_rec.reg_start_time := p0_a43;
    ddp_evo_rec.reg_end_date := p0_a44;
    ddp_evo_rec.reg_end_time := p0_a45;
    ddp_evo_rec.reg_maximum_capacity := p0_a46;
    ddp_evo_rec.reg_overbook_pct := p0_a47;
    ddp_evo_rec.reg_effective_capacity := p0_a48;
    ddp_evo_rec.reg_waitlist_pct := p0_a49;
    ddp_evo_rec.reg_minimum_capacity := p0_a50;
    ddp_evo_rec.reg_minimum_req_by_date := p0_a51;
    ddp_evo_rec.inventory_item_id := p0_a52;
    ddp_evo_rec.inventory_item := p0_a53;
    ddp_evo_rec.organization_id := p0_a54;
    ddp_evo_rec.pricelist_header_id := p0_a55;
    ddp_evo_rec.pricelist_line_id := p0_a56;
    ddp_evo_rec.org_id := p0_a57;
    ddp_evo_rec.waitlist_action_type_code := p0_a58;
    ddp_evo_rec.stream_type_code := p0_a59;
    ddp_evo_rec.owner_user_id := p0_a60;
    ddp_evo_rec.event_full_flag := p0_a61;
    ddp_evo_rec.forecasted_revenue := p0_a62;
    ddp_evo_rec.actual_revenue := p0_a63;
    ddp_evo_rec.forecasted_cost := p0_a64;
    ddp_evo_rec.actual_cost := p0_a65;
    ddp_evo_rec.fund_source_type_code := p0_a66;
    ddp_evo_rec.fund_source_id := p0_a67;
    ddp_evo_rec.cert_credit_type_code := p0_a68;
    ddp_evo_rec.certification_credits := p0_a69;
    ddp_evo_rec.coordinator_id := p0_a70;
    ddp_evo_rec.priority_type_code := p0_a71;
    ddp_evo_rec.cancellation_reason_code := p0_a72;
    ddp_evo_rec.auto_register_flag := p0_a73;
    ddp_evo_rec.email := p0_a74;
    ddp_evo_rec.phone := p0_a75;
    ddp_evo_rec.fund_amount_tc := p0_a76;
    ddp_evo_rec.fund_amount_fc := p0_a77;
    ddp_evo_rec.currency_code_tc := p0_a78;
    ddp_evo_rec.currency_code_fc := p0_a79;
    ddp_evo_rec.url := p0_a80;
    ddp_evo_rec.timezone_id := p0_a81;
    ddp_evo_rec.event_venue_id := p0_a82;
    ddp_evo_rec.pricelist_header_currency_code := p0_a83;
    ddp_evo_rec.pricelist_list_price := p0_a84;
    ddp_evo_rec.inbound_script_name := p0_a85;
    ddp_evo_rec.attribute_category := p0_a86;
    ddp_evo_rec.attribute1 := p0_a87;
    ddp_evo_rec.attribute2 := p0_a88;
    ddp_evo_rec.attribute3 := p0_a89;
    ddp_evo_rec.attribute4 := p0_a90;
    ddp_evo_rec.attribute5 := p0_a91;
    ddp_evo_rec.attribute6 := p0_a92;
    ddp_evo_rec.attribute7 := p0_a93;
    ddp_evo_rec.attribute8 := p0_a94;
    ddp_evo_rec.attribute9 := p0_a95;
    ddp_evo_rec.attribute10 := p0_a96;
    ddp_evo_rec.attribute11 := p0_a97;
    ddp_evo_rec.attribute12 := p0_a98;
    ddp_evo_rec.attribute13 := p0_a99;
    ddp_evo_rec.attribute14 := p0_a100;
    ddp_evo_rec.attribute15 := p0_a101;
    ddp_evo_rec.event_offer_name := p0_a102;
    ddp_evo_rec.event_mktg_message := p0_a103;
    ddp_evo_rec.description := p0_a104;
    ddp_evo_rec.custom_setup_id := p0_a105;
    ddp_evo_rec.country_code := p0_a106;
    ddp_evo_rec.business_unit_id := p0_a107;
    ddp_evo_rec.event_calendar := p0_a108;
    ddp_evo_rec.start_period_name := p0_a109;
    ddp_evo_rec.end_period_name := p0_a110;
    ddp_evo_rec.global_flag := p0_a111;
    ddp_evo_rec.task_id := p0_a112;
    ddp_evo_rec.parent_type := p0_a113;
    ddp_evo_rec.parent_id := p0_a114;
    ddp_evo_rec.create_attendant_lead_flag := p0_a115;
    ddp_evo_rec.create_registrant_lead_flag := p0_a116;
    ddp_evo_rec.event_object_type := p0_a117;
    ddp_evo_rec.reg_timezone_id := p0_a118;
    ddp_evo_rec.event_password := p0_a119;
    ddp_evo_rec.record_event_flag := p0_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p0_a121;
    ddp_evo_rec.publish_attendees_flag := p0_a122;
    ddp_evo_rec.direct_join_flag := p0_a123;
    ddp_evo_rec.event_notification_method := p0_a124;
    ddp_evo_rec.actual_start_time := p0_a125;
    ddp_evo_rec.actual_end_time := p0_a126;
    ddp_evo_rec.server_id := p0_a127;
    ddp_evo_rec.owner_fnd_user_id := p0_a128;
    ddp_evo_rec.meeting_dial_in_info := p0_a129;
    ddp_evo_rec.meeting_email_subject := p0_a130;
    ddp_evo_rec.meeting_schedule_type := p0_a131;
    ddp_evo_rec.meeting_status := p0_a132;
    ddp_evo_rec.meeting_misc_info := p0_a133;
    ddp_evo_rec.publish_flag := p0_a134;
    ddp_evo_rec.meeting_encryption_key_code := p0_a135;
    ddp_evo_rec.number_of_attendees := p0_a136;
    ddp_evo_rec.event_purpose_code := p0_a137;

    ddp_complete_rec.event_offer_id := p1_a0;
    ddp_complete_rec.last_update_date := p1_a1;
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.creation_date := p1_a3;
    ddp_complete_rec.created_by := p1_a4;
    ddp_complete_rec.last_update_login := p1_a5;
    ddp_complete_rec.object_version_number := p1_a6;
    ddp_complete_rec.application_id := p1_a7;
    ddp_complete_rec.event_header_id := p1_a8;
    ddp_complete_rec.private_flag := p1_a9;
    ddp_complete_rec.active_flag := p1_a10;
    ddp_complete_rec.source_code := p1_a11;
    ddp_complete_rec.event_level := p1_a12;
    ddp_complete_rec.user_status_id := p1_a13;
    ddp_complete_rec.last_status_date := p1_a14;
    ddp_complete_rec.system_status_code := p1_a15;
    ddp_complete_rec.event_type_code := p1_a16;
    ddp_complete_rec.event_delivery_method_id := p1_a17;
    ddp_complete_rec.event_delivery_method_code := p1_a18;
    ddp_complete_rec.event_required_flag := p1_a19;
    ddp_complete_rec.event_language_code := p1_a20;
    ddp_complete_rec.event_location_id := p1_a21;
    ddp_complete_rec.city := p1_a22;
    ddp_complete_rec.state := p1_a23;
    ddp_complete_rec.province := p1_a24;
    ddp_complete_rec.country := p1_a25;
    ddp_complete_rec.overflow_flag := p1_a26;
    ddp_complete_rec.partner_flag := p1_a27;
    ddp_complete_rec.event_standalone_flag := p1_a28;
    ddp_complete_rec.reg_frozen_flag := p1_a29;
    ddp_complete_rec.reg_required_flag := p1_a30;
    ddp_complete_rec.reg_charge_flag := p1_a31;
    ddp_complete_rec.reg_invited_only_flag := p1_a32;
    ddp_complete_rec.reg_waitlist_allowed_flag := p1_a33;
    ddp_complete_rec.reg_overbook_allowed_flag := p1_a34;
    ddp_complete_rec.parent_event_offer_id := p1_a35;
    ddp_complete_rec.event_duration := p1_a36;
    ddp_complete_rec.event_duration_uom_code := p1_a37;
    ddp_complete_rec.event_start_date := p1_a38;
    ddp_complete_rec.event_start_date_time := p1_a39;
    ddp_complete_rec.event_end_date := p1_a40;
    ddp_complete_rec.event_end_date_time := p1_a41;
    ddp_complete_rec.reg_start_date := p1_a42;
    ddp_complete_rec.reg_start_time := p1_a43;
    ddp_complete_rec.reg_end_date := p1_a44;
    ddp_complete_rec.reg_end_time := p1_a45;
    ddp_complete_rec.reg_maximum_capacity := p1_a46;
    ddp_complete_rec.reg_overbook_pct := p1_a47;
    ddp_complete_rec.reg_effective_capacity := p1_a48;
    ddp_complete_rec.reg_waitlist_pct := p1_a49;
    ddp_complete_rec.reg_minimum_capacity := p1_a50;
    ddp_complete_rec.reg_minimum_req_by_date := p1_a51;
    ddp_complete_rec.inventory_item_id := p1_a52;
    ddp_complete_rec.inventory_item := p1_a53;
    ddp_complete_rec.organization_id := p1_a54;
    ddp_complete_rec.pricelist_header_id := p1_a55;
    ddp_complete_rec.pricelist_line_id := p1_a56;
    ddp_complete_rec.org_id := p1_a57;
    ddp_complete_rec.waitlist_action_type_code := p1_a58;
    ddp_complete_rec.stream_type_code := p1_a59;
    ddp_complete_rec.owner_user_id := p1_a60;
    ddp_complete_rec.event_full_flag := p1_a61;
    ddp_complete_rec.forecasted_revenue := p1_a62;
    ddp_complete_rec.actual_revenue := p1_a63;
    ddp_complete_rec.forecasted_cost := p1_a64;
    ddp_complete_rec.actual_cost := p1_a65;
    ddp_complete_rec.fund_source_type_code := p1_a66;
    ddp_complete_rec.fund_source_id := p1_a67;
    ddp_complete_rec.cert_credit_type_code := p1_a68;
    ddp_complete_rec.certification_credits := p1_a69;
    ddp_complete_rec.coordinator_id := p1_a70;
    ddp_complete_rec.priority_type_code := p1_a71;
    ddp_complete_rec.cancellation_reason_code := p1_a72;
    ddp_complete_rec.auto_register_flag := p1_a73;
    ddp_complete_rec.email := p1_a74;
    ddp_complete_rec.phone := p1_a75;
    ddp_complete_rec.fund_amount_tc := p1_a76;
    ddp_complete_rec.fund_amount_fc := p1_a77;
    ddp_complete_rec.currency_code_tc := p1_a78;
    ddp_complete_rec.currency_code_fc := p1_a79;
    ddp_complete_rec.url := p1_a80;
    ddp_complete_rec.timezone_id := p1_a81;
    ddp_complete_rec.event_venue_id := p1_a82;
    ddp_complete_rec.pricelist_header_currency_code := p1_a83;
    ddp_complete_rec.pricelist_list_price := p1_a84;
    ddp_complete_rec.inbound_script_name := p1_a85;
    ddp_complete_rec.attribute_category := p1_a86;
    ddp_complete_rec.attribute1 := p1_a87;
    ddp_complete_rec.attribute2 := p1_a88;
    ddp_complete_rec.attribute3 := p1_a89;
    ddp_complete_rec.attribute4 := p1_a90;
    ddp_complete_rec.attribute5 := p1_a91;
    ddp_complete_rec.attribute6 := p1_a92;
    ddp_complete_rec.attribute7 := p1_a93;
    ddp_complete_rec.attribute8 := p1_a94;
    ddp_complete_rec.attribute9 := p1_a95;
    ddp_complete_rec.attribute10 := p1_a96;
    ddp_complete_rec.attribute11 := p1_a97;
    ddp_complete_rec.attribute12 := p1_a98;
    ddp_complete_rec.attribute13 := p1_a99;
    ddp_complete_rec.attribute14 := p1_a100;
    ddp_complete_rec.attribute15 := p1_a101;
    ddp_complete_rec.event_offer_name := p1_a102;
    ddp_complete_rec.event_mktg_message := p1_a103;
    ddp_complete_rec.description := p1_a104;
    ddp_complete_rec.custom_setup_id := p1_a105;
    ddp_complete_rec.country_code := p1_a106;
    ddp_complete_rec.business_unit_id := p1_a107;
    ddp_complete_rec.event_calendar := p1_a108;
    ddp_complete_rec.start_period_name := p1_a109;
    ddp_complete_rec.end_period_name := p1_a110;
    ddp_complete_rec.global_flag := p1_a111;
    ddp_complete_rec.task_id := p1_a112;
    ddp_complete_rec.parent_type := p1_a113;
    ddp_complete_rec.parent_id := p1_a114;
    ddp_complete_rec.create_attendant_lead_flag := p1_a115;
    ddp_complete_rec.create_registrant_lead_flag := p1_a116;
    ddp_complete_rec.event_object_type := p1_a117;
    ddp_complete_rec.reg_timezone_id := p1_a118;
    ddp_complete_rec.event_password := p1_a119;
    ddp_complete_rec.record_event_flag := p1_a120;
    ddp_complete_rec.allow_register_in_middle_flag := p1_a121;
    ddp_complete_rec.publish_attendees_flag := p1_a122;
    ddp_complete_rec.direct_join_flag := p1_a123;
    ddp_complete_rec.event_notification_method := p1_a124;
    ddp_complete_rec.actual_start_time := p1_a125;
    ddp_complete_rec.actual_end_time := p1_a126;
    ddp_complete_rec.server_id := p1_a127;
    ddp_complete_rec.owner_fnd_user_id := p1_a128;
    ddp_complete_rec.meeting_dial_in_info := p1_a129;
    ddp_complete_rec.meeting_email_subject := p1_a130;
    ddp_complete_rec.meeting_schedule_type := p1_a131;
    ddp_complete_rec.meeting_status := p1_a132;
    ddp_complete_rec.meeting_misc_info := p1_a133;
    ddp_complete_rec.publish_flag := p1_a134;
    ddp_complete_rec.meeting_encryption_key_code := p1_a135;
    ddp_complete_rec.number_of_attendees := p1_a136;
    ddp_complete_rec.event_purpose_code := p1_a137;


    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pvt.check_evo_record(ddp_evo_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_evo_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  DATE
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  DATE
    , p0_a39 out nocopy  DATE
    , p0_a40 out nocopy  DATE
    , p0_a41 out nocopy  DATE
    , p0_a42 out nocopy  DATE
    , p0_a43 out nocopy  DATE
    , p0_a44 out nocopy  DATE
    , p0_a45 out nocopy  DATE
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  NUMBER
    , p0_a48 out nocopy  NUMBER
    , p0_a49 out nocopy  NUMBER
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  DATE
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  NUMBER
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  NUMBER
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  VARCHAR2
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  NUMBER
    , p0_a66 out nocopy  VARCHAR2
    , p0_a67 out nocopy  NUMBER
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  NUMBER
    , p0_a70 out nocopy  NUMBER
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  VARCHAR2
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  VARCHAR2
    , p0_a76 out nocopy  NUMBER
    , p0_a77 out nocopy  NUMBER
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  VARCHAR2
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  NUMBER
    , p0_a82 out nocopy  NUMBER
    , p0_a83 out nocopy  VARCHAR2
    , p0_a84 out nocopy  NUMBER
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  VARCHAR2
    , p0_a87 out nocopy  VARCHAR2
    , p0_a88 out nocopy  VARCHAR2
    , p0_a89 out nocopy  VARCHAR2
    , p0_a90 out nocopy  VARCHAR2
    , p0_a91 out nocopy  VARCHAR2
    , p0_a92 out nocopy  VARCHAR2
    , p0_a93 out nocopy  VARCHAR2
    , p0_a94 out nocopy  VARCHAR2
    , p0_a95 out nocopy  VARCHAR2
    , p0_a96 out nocopy  VARCHAR2
    , p0_a97 out nocopy  VARCHAR2
    , p0_a98 out nocopy  VARCHAR2
    , p0_a99 out nocopy  VARCHAR2
    , p0_a100 out nocopy  VARCHAR2
    , p0_a101 out nocopy  VARCHAR2
    , p0_a102 out nocopy  VARCHAR2
    , p0_a103 out nocopy  VARCHAR2
    , p0_a104 out nocopy  VARCHAR2
    , p0_a105 out nocopy  NUMBER
    , p0_a106 out nocopy  VARCHAR2
    , p0_a107 out nocopy  NUMBER
    , p0_a108 out nocopy  VARCHAR2
    , p0_a109 out nocopy  VARCHAR2
    , p0_a110 out nocopy  VARCHAR2
    , p0_a111 out nocopy  VARCHAR2
    , p0_a112 out nocopy  NUMBER
    , p0_a113 out nocopy  VARCHAR2
    , p0_a114 out nocopy  NUMBER
    , p0_a115 out nocopy  VARCHAR2
    , p0_a116 out nocopy  VARCHAR2
    , p0_a117 out nocopy  VARCHAR2
    , p0_a118 out nocopy  NUMBER
    , p0_a119 out nocopy  VARCHAR2
    , p0_a120 out nocopy  VARCHAR2
    , p0_a121 out nocopy  VARCHAR2
    , p0_a122 out nocopy  VARCHAR2
    , p0_a123 out nocopy  VARCHAR2
    , p0_a124 out nocopy  VARCHAR2
    , p0_a125 out nocopy  DATE
    , p0_a126 out nocopy  DATE
    , p0_a127 out nocopy  NUMBER
    , p0_a128 out nocopy  NUMBER
    , p0_a129 out nocopy  VARCHAR2
    , p0_a130 out nocopy  VARCHAR2
    , p0_a131 out nocopy  VARCHAR2
    , p0_a132 out nocopy  VARCHAR2
    , p0_a133 out nocopy  VARCHAR2
    , p0_a134 out nocopy  VARCHAR2
    , p0_a135 out nocopy  VARCHAR2
    , p0_a136 out nocopy  NUMBER
    , p0_a137 out nocopy  VARCHAR2
  )

  as
    ddx_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pvt.init_evo_rec(ddx_evo_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_evo_rec.event_offer_id;
    p0_a1 := ddx_evo_rec.last_update_date;
    p0_a2 := ddx_evo_rec.last_updated_by;
    p0_a3 := ddx_evo_rec.creation_date;
    p0_a4 := ddx_evo_rec.created_by;
    p0_a5 := ddx_evo_rec.last_update_login;
    p0_a6 := ddx_evo_rec.object_version_number;
    p0_a7 := ddx_evo_rec.application_id;
    p0_a8 := ddx_evo_rec.event_header_id;
    p0_a9 := ddx_evo_rec.private_flag;
    p0_a10 := ddx_evo_rec.active_flag;
    p0_a11 := ddx_evo_rec.source_code;
    p0_a12 := ddx_evo_rec.event_level;
    p0_a13 := ddx_evo_rec.user_status_id;
    p0_a14 := ddx_evo_rec.last_status_date;
    p0_a15 := ddx_evo_rec.system_status_code;
    p0_a16 := ddx_evo_rec.event_type_code;
    p0_a17 := ddx_evo_rec.event_delivery_method_id;
    p0_a18 := ddx_evo_rec.event_delivery_method_code;
    p0_a19 := ddx_evo_rec.event_required_flag;
    p0_a20 := ddx_evo_rec.event_language_code;
    p0_a21 := ddx_evo_rec.event_location_id;
    p0_a22 := ddx_evo_rec.city;
    p0_a23 := ddx_evo_rec.state;
    p0_a24 := ddx_evo_rec.province;
    p0_a25 := ddx_evo_rec.country;
    p0_a26 := ddx_evo_rec.overflow_flag;
    p0_a27 := ddx_evo_rec.partner_flag;
    p0_a28 := ddx_evo_rec.event_standalone_flag;
    p0_a29 := ddx_evo_rec.reg_frozen_flag;
    p0_a30 := ddx_evo_rec.reg_required_flag;
    p0_a31 := ddx_evo_rec.reg_charge_flag;
    p0_a32 := ddx_evo_rec.reg_invited_only_flag;
    p0_a33 := ddx_evo_rec.reg_waitlist_allowed_flag;
    p0_a34 := ddx_evo_rec.reg_overbook_allowed_flag;
    p0_a35 := ddx_evo_rec.parent_event_offer_id;
    p0_a36 := ddx_evo_rec.event_duration;
    p0_a37 := ddx_evo_rec.event_duration_uom_code;
    p0_a38 := ddx_evo_rec.event_start_date;
    p0_a39 := ddx_evo_rec.event_start_date_time;
    p0_a40 := ddx_evo_rec.event_end_date;
    p0_a41 := ddx_evo_rec.event_end_date_time;
    p0_a42 := ddx_evo_rec.reg_start_date;
    p0_a43 := ddx_evo_rec.reg_start_time;
    p0_a44 := ddx_evo_rec.reg_end_date;
    p0_a45 := ddx_evo_rec.reg_end_time;
    p0_a46 := ddx_evo_rec.reg_maximum_capacity;
    p0_a47 := ddx_evo_rec.reg_overbook_pct;
    p0_a48 := ddx_evo_rec.reg_effective_capacity;
    p0_a49 := ddx_evo_rec.reg_waitlist_pct;
    p0_a50 := ddx_evo_rec.reg_minimum_capacity;
    p0_a51 := ddx_evo_rec.reg_minimum_req_by_date;
    p0_a52 := ddx_evo_rec.inventory_item_id;
    p0_a53 := ddx_evo_rec.inventory_item;
    p0_a54 := ddx_evo_rec.organization_id;
    p0_a55 := ddx_evo_rec.pricelist_header_id;
    p0_a56 := ddx_evo_rec.pricelist_line_id;
    p0_a57 := ddx_evo_rec.org_id;
    p0_a58 := ddx_evo_rec.waitlist_action_type_code;
    p0_a59 := ddx_evo_rec.stream_type_code;
    p0_a60 := ddx_evo_rec.owner_user_id;
    p0_a61 := ddx_evo_rec.event_full_flag;
    p0_a62 := ddx_evo_rec.forecasted_revenue;
    p0_a63 := ddx_evo_rec.actual_revenue;
    p0_a64 := ddx_evo_rec.forecasted_cost;
    p0_a65 := ddx_evo_rec.actual_cost;
    p0_a66 := ddx_evo_rec.fund_source_type_code;
    p0_a67 := ddx_evo_rec.fund_source_id;
    p0_a68 := ddx_evo_rec.cert_credit_type_code;
    p0_a69 := ddx_evo_rec.certification_credits;
    p0_a70 := ddx_evo_rec.coordinator_id;
    p0_a71 := ddx_evo_rec.priority_type_code;
    p0_a72 := ddx_evo_rec.cancellation_reason_code;
    p0_a73 := ddx_evo_rec.auto_register_flag;
    p0_a74 := ddx_evo_rec.email;
    p0_a75 := ddx_evo_rec.phone;
    p0_a76 := ddx_evo_rec.fund_amount_tc;
    p0_a77 := ddx_evo_rec.fund_amount_fc;
    p0_a78 := ddx_evo_rec.currency_code_tc;
    p0_a79 := ddx_evo_rec.currency_code_fc;
    p0_a80 := ddx_evo_rec.url;
    p0_a81 := ddx_evo_rec.timezone_id;
    p0_a82 := ddx_evo_rec.event_venue_id;
    p0_a83 := ddx_evo_rec.pricelist_header_currency_code;
    p0_a84 := ddx_evo_rec.pricelist_list_price;
    p0_a85 := ddx_evo_rec.inbound_script_name;
    p0_a86 := ddx_evo_rec.attribute_category;
    p0_a87 := ddx_evo_rec.attribute1;
    p0_a88 := ddx_evo_rec.attribute2;
    p0_a89 := ddx_evo_rec.attribute3;
    p0_a90 := ddx_evo_rec.attribute4;
    p0_a91 := ddx_evo_rec.attribute5;
    p0_a92 := ddx_evo_rec.attribute6;
    p0_a93 := ddx_evo_rec.attribute7;
    p0_a94 := ddx_evo_rec.attribute8;
    p0_a95 := ddx_evo_rec.attribute9;
    p0_a96 := ddx_evo_rec.attribute10;
    p0_a97 := ddx_evo_rec.attribute11;
    p0_a98 := ddx_evo_rec.attribute12;
    p0_a99 := ddx_evo_rec.attribute13;
    p0_a100 := ddx_evo_rec.attribute14;
    p0_a101 := ddx_evo_rec.attribute15;
    p0_a102 := ddx_evo_rec.event_offer_name;
    p0_a103 := ddx_evo_rec.event_mktg_message;
    p0_a104 := ddx_evo_rec.description;
    p0_a105 := ddx_evo_rec.custom_setup_id;
    p0_a106 := ddx_evo_rec.country_code;
    p0_a107 := ddx_evo_rec.business_unit_id;
    p0_a108 := ddx_evo_rec.event_calendar;
    p0_a109 := ddx_evo_rec.start_period_name;
    p0_a110 := ddx_evo_rec.end_period_name;
    p0_a111 := ddx_evo_rec.global_flag;
    p0_a112 := ddx_evo_rec.task_id;
    p0_a113 := ddx_evo_rec.parent_type;
    p0_a114 := ddx_evo_rec.parent_id;
    p0_a115 := ddx_evo_rec.create_attendant_lead_flag;
    p0_a116 := ddx_evo_rec.create_registrant_lead_flag;
    p0_a117 := ddx_evo_rec.event_object_type;
    p0_a118 := ddx_evo_rec.reg_timezone_id;
    p0_a119 := ddx_evo_rec.event_password;
    p0_a120 := ddx_evo_rec.record_event_flag;
    p0_a121 := ddx_evo_rec.allow_register_in_middle_flag;
    p0_a122 := ddx_evo_rec.publish_attendees_flag;
    p0_a123 := ddx_evo_rec.direct_join_flag;
    p0_a124 := ddx_evo_rec.event_notification_method;
    p0_a125 := ddx_evo_rec.actual_start_time;
    p0_a126 := ddx_evo_rec.actual_end_time;
    p0_a127 := ddx_evo_rec.server_id;
    p0_a128 := ddx_evo_rec.owner_fnd_user_id;
    p0_a129 := ddx_evo_rec.meeting_dial_in_info;
    p0_a130 := ddx_evo_rec.meeting_email_subject;
    p0_a131 := ddx_evo_rec.meeting_schedule_type;
    p0_a132 := ddx_evo_rec.meeting_status;
    p0_a133 := ddx_evo_rec.meeting_misc_info;
    p0_a134 := ddx_evo_rec.publish_flag;
    p0_a135 := ddx_evo_rec.meeting_encryption_key_code;
    p0_a136 := ddx_evo_rec.number_of_attendees;
    p0_a137 := ddx_evo_rec.event_purpose_code;
  end;

  procedure complete_evo_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  DATE
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  DATE
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  DATE
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  DATE
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  VARCHAR2
    , p0_a84  NUMBER
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p0_a93  VARCHAR2
    , p0_a94  VARCHAR2
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  VARCHAR2
    , p0_a98  VARCHAR2
    , p0_a99  VARCHAR2
    , p0_a100  VARCHAR2
    , p0_a101  VARCHAR2
    , p0_a102  VARCHAR2
    , p0_a103  VARCHAR2
    , p0_a104  VARCHAR2
    , p0_a105  NUMBER
    , p0_a106  VARCHAR2
    , p0_a107  NUMBER
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  VARCHAR2
    , p0_a111  VARCHAR2
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  NUMBER
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  DATE
    , p0_a126  DATE
    , p0_a127  NUMBER
    , p0_a128  NUMBER
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  VARCHAR2
    , p0_a132  VARCHAR2
    , p0_a133  VARCHAR2
    , p0_a134  VARCHAR2
    , p0_a135  VARCHAR2
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  DATE
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  DATE
    , p1_a39 out nocopy  DATE
    , p1_a40 out nocopy  DATE
    , p1_a41 out nocopy  DATE
    , p1_a42 out nocopy  DATE
    , p1_a43 out nocopy  DATE
    , p1_a44 out nocopy  DATE
    , p1_a45 out nocopy  DATE
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  DATE
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  NUMBER
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  VARCHAR2
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  VARCHAR2
    , p1_a67 out nocopy  NUMBER
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  NUMBER
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  VARCHAR2
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  NUMBER
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  NUMBER
    , p1_a82 out nocopy  NUMBER
    , p1_a83 out nocopy  VARCHAR2
    , p1_a84 out nocopy  NUMBER
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  VARCHAR2
    , p1_a87 out nocopy  VARCHAR2
    , p1_a88 out nocopy  VARCHAR2
    , p1_a89 out nocopy  VARCHAR2
    , p1_a90 out nocopy  VARCHAR2
    , p1_a91 out nocopy  VARCHAR2
    , p1_a92 out nocopy  VARCHAR2
    , p1_a93 out nocopy  VARCHAR2
    , p1_a94 out nocopy  VARCHAR2
    , p1_a95 out nocopy  VARCHAR2
    , p1_a96 out nocopy  VARCHAR2
    , p1_a97 out nocopy  VARCHAR2
    , p1_a98 out nocopy  VARCHAR2
    , p1_a99 out nocopy  VARCHAR2
    , p1_a100 out nocopy  VARCHAR2
    , p1_a101 out nocopy  VARCHAR2
    , p1_a102 out nocopy  VARCHAR2
    , p1_a103 out nocopy  VARCHAR2
    , p1_a104 out nocopy  VARCHAR2
    , p1_a105 out nocopy  NUMBER
    , p1_a106 out nocopy  VARCHAR2
    , p1_a107 out nocopy  NUMBER
    , p1_a108 out nocopy  VARCHAR2
    , p1_a109 out nocopy  VARCHAR2
    , p1_a110 out nocopy  VARCHAR2
    , p1_a111 out nocopy  VARCHAR2
    , p1_a112 out nocopy  NUMBER
    , p1_a113 out nocopy  VARCHAR2
    , p1_a114 out nocopy  NUMBER
    , p1_a115 out nocopy  VARCHAR2
    , p1_a116 out nocopy  VARCHAR2
    , p1_a117 out nocopy  VARCHAR2
    , p1_a118 out nocopy  NUMBER
    , p1_a119 out nocopy  VARCHAR2
    , p1_a120 out nocopy  VARCHAR2
    , p1_a121 out nocopy  VARCHAR2
    , p1_a122 out nocopy  VARCHAR2
    , p1_a123 out nocopy  VARCHAR2
    , p1_a124 out nocopy  VARCHAR2
    , p1_a125 out nocopy  DATE
    , p1_a126 out nocopy  DATE
    , p1_a127 out nocopy  NUMBER
    , p1_a128 out nocopy  NUMBER
    , p1_a129 out nocopy  VARCHAR2
    , p1_a130 out nocopy  VARCHAR2
    , p1_a131 out nocopy  VARCHAR2
    , p1_a132 out nocopy  VARCHAR2
    , p1_a133 out nocopy  VARCHAR2
    , p1_a134 out nocopy  VARCHAR2
    , p1_a135 out nocopy  VARCHAR2
    , p1_a136 out nocopy  NUMBER
    , p1_a137 out nocopy  VARCHAR2
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddx_complete_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evo_rec.event_offer_id := p0_a0;
    ddp_evo_rec.last_update_date := p0_a1;
    ddp_evo_rec.last_updated_by := p0_a2;
    ddp_evo_rec.creation_date := p0_a3;
    ddp_evo_rec.created_by := p0_a4;
    ddp_evo_rec.last_update_login := p0_a5;
    ddp_evo_rec.object_version_number := p0_a6;
    ddp_evo_rec.application_id := p0_a7;
    ddp_evo_rec.event_header_id := p0_a8;
    ddp_evo_rec.private_flag := p0_a9;
    ddp_evo_rec.active_flag := p0_a10;
    ddp_evo_rec.source_code := p0_a11;
    ddp_evo_rec.event_level := p0_a12;
    ddp_evo_rec.user_status_id := p0_a13;
    ddp_evo_rec.last_status_date := p0_a14;
    ddp_evo_rec.system_status_code := p0_a15;
    ddp_evo_rec.event_type_code := p0_a16;
    ddp_evo_rec.event_delivery_method_id := p0_a17;
    ddp_evo_rec.event_delivery_method_code := p0_a18;
    ddp_evo_rec.event_required_flag := p0_a19;
    ddp_evo_rec.event_language_code := p0_a20;
    ddp_evo_rec.event_location_id := p0_a21;
    ddp_evo_rec.city := p0_a22;
    ddp_evo_rec.state := p0_a23;
    ddp_evo_rec.province := p0_a24;
    ddp_evo_rec.country := p0_a25;
    ddp_evo_rec.overflow_flag := p0_a26;
    ddp_evo_rec.partner_flag := p0_a27;
    ddp_evo_rec.event_standalone_flag := p0_a28;
    ddp_evo_rec.reg_frozen_flag := p0_a29;
    ddp_evo_rec.reg_required_flag := p0_a30;
    ddp_evo_rec.reg_charge_flag := p0_a31;
    ddp_evo_rec.reg_invited_only_flag := p0_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p0_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p0_a34;
    ddp_evo_rec.parent_event_offer_id := p0_a35;
    ddp_evo_rec.event_duration := p0_a36;
    ddp_evo_rec.event_duration_uom_code := p0_a37;
    ddp_evo_rec.event_start_date := p0_a38;
    ddp_evo_rec.event_start_date_time := p0_a39;
    ddp_evo_rec.event_end_date := p0_a40;
    ddp_evo_rec.event_end_date_time := p0_a41;
    ddp_evo_rec.reg_start_date := p0_a42;
    ddp_evo_rec.reg_start_time := p0_a43;
    ddp_evo_rec.reg_end_date := p0_a44;
    ddp_evo_rec.reg_end_time := p0_a45;
    ddp_evo_rec.reg_maximum_capacity := p0_a46;
    ddp_evo_rec.reg_overbook_pct := p0_a47;
    ddp_evo_rec.reg_effective_capacity := p0_a48;
    ddp_evo_rec.reg_waitlist_pct := p0_a49;
    ddp_evo_rec.reg_minimum_capacity := p0_a50;
    ddp_evo_rec.reg_minimum_req_by_date := p0_a51;
    ddp_evo_rec.inventory_item_id := p0_a52;
    ddp_evo_rec.inventory_item := p0_a53;
    ddp_evo_rec.organization_id := p0_a54;
    ddp_evo_rec.pricelist_header_id := p0_a55;
    ddp_evo_rec.pricelist_line_id := p0_a56;
    ddp_evo_rec.org_id := p0_a57;
    ddp_evo_rec.waitlist_action_type_code := p0_a58;
    ddp_evo_rec.stream_type_code := p0_a59;
    ddp_evo_rec.owner_user_id := p0_a60;
    ddp_evo_rec.event_full_flag := p0_a61;
    ddp_evo_rec.forecasted_revenue := p0_a62;
    ddp_evo_rec.actual_revenue := p0_a63;
    ddp_evo_rec.forecasted_cost := p0_a64;
    ddp_evo_rec.actual_cost := p0_a65;
    ddp_evo_rec.fund_source_type_code := p0_a66;
    ddp_evo_rec.fund_source_id := p0_a67;
    ddp_evo_rec.cert_credit_type_code := p0_a68;
    ddp_evo_rec.certification_credits := p0_a69;
    ddp_evo_rec.coordinator_id := p0_a70;
    ddp_evo_rec.priority_type_code := p0_a71;
    ddp_evo_rec.cancellation_reason_code := p0_a72;
    ddp_evo_rec.auto_register_flag := p0_a73;
    ddp_evo_rec.email := p0_a74;
    ddp_evo_rec.phone := p0_a75;
    ddp_evo_rec.fund_amount_tc := p0_a76;
    ddp_evo_rec.fund_amount_fc := p0_a77;
    ddp_evo_rec.currency_code_tc := p0_a78;
    ddp_evo_rec.currency_code_fc := p0_a79;
    ddp_evo_rec.url := p0_a80;
    ddp_evo_rec.timezone_id := p0_a81;
    ddp_evo_rec.event_venue_id := p0_a82;
    ddp_evo_rec.pricelist_header_currency_code := p0_a83;
    ddp_evo_rec.pricelist_list_price := p0_a84;
    ddp_evo_rec.inbound_script_name := p0_a85;
    ddp_evo_rec.attribute_category := p0_a86;
    ddp_evo_rec.attribute1 := p0_a87;
    ddp_evo_rec.attribute2 := p0_a88;
    ddp_evo_rec.attribute3 := p0_a89;
    ddp_evo_rec.attribute4 := p0_a90;
    ddp_evo_rec.attribute5 := p0_a91;
    ddp_evo_rec.attribute6 := p0_a92;
    ddp_evo_rec.attribute7 := p0_a93;
    ddp_evo_rec.attribute8 := p0_a94;
    ddp_evo_rec.attribute9 := p0_a95;
    ddp_evo_rec.attribute10 := p0_a96;
    ddp_evo_rec.attribute11 := p0_a97;
    ddp_evo_rec.attribute12 := p0_a98;
    ddp_evo_rec.attribute13 := p0_a99;
    ddp_evo_rec.attribute14 := p0_a100;
    ddp_evo_rec.attribute15 := p0_a101;
    ddp_evo_rec.event_offer_name := p0_a102;
    ddp_evo_rec.event_mktg_message := p0_a103;
    ddp_evo_rec.description := p0_a104;
    ddp_evo_rec.custom_setup_id := p0_a105;
    ddp_evo_rec.country_code := p0_a106;
    ddp_evo_rec.business_unit_id := p0_a107;
    ddp_evo_rec.event_calendar := p0_a108;
    ddp_evo_rec.start_period_name := p0_a109;
    ddp_evo_rec.end_period_name := p0_a110;
    ddp_evo_rec.global_flag := p0_a111;
    ddp_evo_rec.task_id := p0_a112;
    ddp_evo_rec.parent_type := p0_a113;
    ddp_evo_rec.parent_id := p0_a114;
    ddp_evo_rec.create_attendant_lead_flag := p0_a115;
    ddp_evo_rec.create_registrant_lead_flag := p0_a116;
    ddp_evo_rec.event_object_type := p0_a117;
    ddp_evo_rec.reg_timezone_id := p0_a118;
    ddp_evo_rec.event_password := p0_a119;
    ddp_evo_rec.record_event_flag := p0_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p0_a121;
    ddp_evo_rec.publish_attendees_flag := p0_a122;
    ddp_evo_rec.direct_join_flag := p0_a123;
    ddp_evo_rec.event_notification_method := p0_a124;
    ddp_evo_rec.actual_start_time := p0_a125;
    ddp_evo_rec.actual_end_time := p0_a126;
    ddp_evo_rec.server_id := p0_a127;
    ddp_evo_rec.owner_fnd_user_id := p0_a128;
    ddp_evo_rec.meeting_dial_in_info := p0_a129;
    ddp_evo_rec.meeting_email_subject := p0_a130;
    ddp_evo_rec.meeting_schedule_type := p0_a131;
    ddp_evo_rec.meeting_status := p0_a132;
    ddp_evo_rec.meeting_misc_info := p0_a133;
    ddp_evo_rec.publish_flag := p0_a134;
    ddp_evo_rec.meeting_encryption_key_code := p0_a135;
    ddp_evo_rec.number_of_attendees := p0_a136;
    ddp_evo_rec.event_purpose_code := p0_a137;


    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pvt.complete_evo_rec(ddp_evo_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.event_offer_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.object_version_number;
    p1_a7 := ddx_complete_rec.application_id;
    p1_a8 := ddx_complete_rec.event_header_id;
    p1_a9 := ddx_complete_rec.private_flag;
    p1_a10 := ddx_complete_rec.active_flag;
    p1_a11 := ddx_complete_rec.source_code;
    p1_a12 := ddx_complete_rec.event_level;
    p1_a13 := ddx_complete_rec.user_status_id;
    p1_a14 := ddx_complete_rec.last_status_date;
    p1_a15 := ddx_complete_rec.system_status_code;
    p1_a16 := ddx_complete_rec.event_type_code;
    p1_a17 := ddx_complete_rec.event_delivery_method_id;
    p1_a18 := ddx_complete_rec.event_delivery_method_code;
    p1_a19 := ddx_complete_rec.event_required_flag;
    p1_a20 := ddx_complete_rec.event_language_code;
    p1_a21 := ddx_complete_rec.event_location_id;
    p1_a22 := ddx_complete_rec.city;
    p1_a23 := ddx_complete_rec.state;
    p1_a24 := ddx_complete_rec.province;
    p1_a25 := ddx_complete_rec.country;
    p1_a26 := ddx_complete_rec.overflow_flag;
    p1_a27 := ddx_complete_rec.partner_flag;
    p1_a28 := ddx_complete_rec.event_standalone_flag;
    p1_a29 := ddx_complete_rec.reg_frozen_flag;
    p1_a30 := ddx_complete_rec.reg_required_flag;
    p1_a31 := ddx_complete_rec.reg_charge_flag;
    p1_a32 := ddx_complete_rec.reg_invited_only_flag;
    p1_a33 := ddx_complete_rec.reg_waitlist_allowed_flag;
    p1_a34 := ddx_complete_rec.reg_overbook_allowed_flag;
    p1_a35 := ddx_complete_rec.parent_event_offer_id;
    p1_a36 := ddx_complete_rec.event_duration;
    p1_a37 := ddx_complete_rec.event_duration_uom_code;
    p1_a38 := ddx_complete_rec.event_start_date;
    p1_a39 := ddx_complete_rec.event_start_date_time;
    p1_a40 := ddx_complete_rec.event_end_date;
    p1_a41 := ddx_complete_rec.event_end_date_time;
    p1_a42 := ddx_complete_rec.reg_start_date;
    p1_a43 := ddx_complete_rec.reg_start_time;
    p1_a44 := ddx_complete_rec.reg_end_date;
    p1_a45 := ddx_complete_rec.reg_end_time;
    p1_a46 := ddx_complete_rec.reg_maximum_capacity;
    p1_a47 := ddx_complete_rec.reg_overbook_pct;
    p1_a48 := ddx_complete_rec.reg_effective_capacity;
    p1_a49 := ddx_complete_rec.reg_waitlist_pct;
    p1_a50 := ddx_complete_rec.reg_minimum_capacity;
    p1_a51 := ddx_complete_rec.reg_minimum_req_by_date;
    p1_a52 := ddx_complete_rec.inventory_item_id;
    p1_a53 := ddx_complete_rec.inventory_item;
    p1_a54 := ddx_complete_rec.organization_id;
    p1_a55 := ddx_complete_rec.pricelist_header_id;
    p1_a56 := ddx_complete_rec.pricelist_line_id;
    p1_a57 := ddx_complete_rec.org_id;
    p1_a58 := ddx_complete_rec.waitlist_action_type_code;
    p1_a59 := ddx_complete_rec.stream_type_code;
    p1_a60 := ddx_complete_rec.owner_user_id;
    p1_a61 := ddx_complete_rec.event_full_flag;
    p1_a62 := ddx_complete_rec.forecasted_revenue;
    p1_a63 := ddx_complete_rec.actual_revenue;
    p1_a64 := ddx_complete_rec.forecasted_cost;
    p1_a65 := ddx_complete_rec.actual_cost;
    p1_a66 := ddx_complete_rec.fund_source_type_code;
    p1_a67 := ddx_complete_rec.fund_source_id;
    p1_a68 := ddx_complete_rec.cert_credit_type_code;
    p1_a69 := ddx_complete_rec.certification_credits;
    p1_a70 := ddx_complete_rec.coordinator_id;
    p1_a71 := ddx_complete_rec.priority_type_code;
    p1_a72 := ddx_complete_rec.cancellation_reason_code;
    p1_a73 := ddx_complete_rec.auto_register_flag;
    p1_a74 := ddx_complete_rec.email;
    p1_a75 := ddx_complete_rec.phone;
    p1_a76 := ddx_complete_rec.fund_amount_tc;
    p1_a77 := ddx_complete_rec.fund_amount_fc;
    p1_a78 := ddx_complete_rec.currency_code_tc;
    p1_a79 := ddx_complete_rec.currency_code_fc;
    p1_a80 := ddx_complete_rec.url;
    p1_a81 := ddx_complete_rec.timezone_id;
    p1_a82 := ddx_complete_rec.event_venue_id;
    p1_a83 := ddx_complete_rec.pricelist_header_currency_code;
    p1_a84 := ddx_complete_rec.pricelist_list_price;
    p1_a85 := ddx_complete_rec.inbound_script_name;
    p1_a86 := ddx_complete_rec.attribute_category;
    p1_a87 := ddx_complete_rec.attribute1;
    p1_a88 := ddx_complete_rec.attribute2;
    p1_a89 := ddx_complete_rec.attribute3;
    p1_a90 := ddx_complete_rec.attribute4;
    p1_a91 := ddx_complete_rec.attribute5;
    p1_a92 := ddx_complete_rec.attribute6;
    p1_a93 := ddx_complete_rec.attribute7;
    p1_a94 := ddx_complete_rec.attribute8;
    p1_a95 := ddx_complete_rec.attribute9;
    p1_a96 := ddx_complete_rec.attribute10;
    p1_a97 := ddx_complete_rec.attribute11;
    p1_a98 := ddx_complete_rec.attribute12;
    p1_a99 := ddx_complete_rec.attribute13;
    p1_a100 := ddx_complete_rec.attribute14;
    p1_a101 := ddx_complete_rec.attribute15;
    p1_a102 := ddx_complete_rec.event_offer_name;
    p1_a103 := ddx_complete_rec.event_mktg_message;
    p1_a104 := ddx_complete_rec.description;
    p1_a105 := ddx_complete_rec.custom_setup_id;
    p1_a106 := ddx_complete_rec.country_code;
    p1_a107 := ddx_complete_rec.business_unit_id;
    p1_a108 := ddx_complete_rec.event_calendar;
    p1_a109 := ddx_complete_rec.start_period_name;
    p1_a110 := ddx_complete_rec.end_period_name;
    p1_a111 := ddx_complete_rec.global_flag;
    p1_a112 := ddx_complete_rec.task_id;
    p1_a113 := ddx_complete_rec.parent_type;
    p1_a114 := ddx_complete_rec.parent_id;
    p1_a115 := ddx_complete_rec.create_attendant_lead_flag;
    p1_a116 := ddx_complete_rec.create_registrant_lead_flag;
    p1_a117 := ddx_complete_rec.event_object_type;
    p1_a118 := ddx_complete_rec.reg_timezone_id;
    p1_a119 := ddx_complete_rec.event_password;
    p1_a120 := ddx_complete_rec.record_event_flag;
    p1_a121 := ddx_complete_rec.allow_register_in_middle_flag;
    p1_a122 := ddx_complete_rec.publish_attendees_flag;
    p1_a123 := ddx_complete_rec.direct_join_flag;
    p1_a124 := ddx_complete_rec.event_notification_method;
    p1_a125 := ddx_complete_rec.actual_start_time;
    p1_a126 := ddx_complete_rec.actual_end_time;
    p1_a127 := ddx_complete_rec.server_id;
    p1_a128 := ddx_complete_rec.owner_fnd_user_id;
    p1_a129 := ddx_complete_rec.meeting_dial_in_info;
    p1_a130 := ddx_complete_rec.meeting_email_subject;
    p1_a131 := ddx_complete_rec.meeting_schedule_type;
    p1_a132 := ddx_complete_rec.meeting_status;
    p1_a133 := ddx_complete_rec.meeting_misc_info;
    p1_a134 := ddx_complete_rec.publish_flag;
    p1_a135 := ddx_complete_rec.meeting_encryption_key_code;
    p1_a136 := ddx_complete_rec.number_of_attendees;
    p1_a137 := ddx_complete_rec.event_purpose_code;
  end;

end ams_eventoffer_pvt_w_new;

/
