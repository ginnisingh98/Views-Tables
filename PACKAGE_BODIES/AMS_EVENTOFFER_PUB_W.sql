--------------------------------------------------------
--  DDL for Package Body AMS_EVENTOFFER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTOFFER_PUB_W" as
  /* $Header: amswevob.pls 115.21 2003/05/31 00:28:45 dbiswas ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_eventoffer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_evo_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  DATE := fnd_api.g_miss_date
    , p7_a39  DATE := fnd_api.g_miss_date
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  DATE := fnd_api.g_miss_date
    , p7_a42  DATE := fnd_api.g_miss_date
    , p7_a43  DATE := fnd_api.g_miss_date
    , p7_a44  DATE := fnd_api.g_miss_date
    , p7_a45  DATE := fnd_api.g_miss_date
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  NUMBER := 0-1962.0724
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  DATE := fnd_api.g_miss_date
    , p7_a52  NUMBER := 0-1962.0724
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  NUMBER := 0-1962.0724
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  NUMBER := 0-1962.0724
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  NUMBER := 0-1962.0724
    , p7_a63  NUMBER := 0-1962.0724
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  NUMBER := 0-1962.0724
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  NUMBER := 0-1962.0724
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  NUMBER := 0-1962.0724
    , p7_a82  NUMBER := 0-1962.0724
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  VARCHAR2 := fnd_api.g_miss_char
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  VARCHAR2 := fnd_api.g_miss_char
    , p7_a104  VARCHAR2 := fnd_api.g_miss_char
    , p7_a105  NUMBER := 0-1962.0724
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  NUMBER := 0-1962.0724
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
    , p7_a109  VARCHAR2 := fnd_api.g_miss_char
    , p7_a110  VARCHAR2 := fnd_api.g_miss_char
    , p7_a111  VARCHAR2 := fnd_api.g_miss_char
    , p7_a112  NUMBER := 0-1962.0724
    , p7_a113  VARCHAR2 := fnd_api.g_miss_char
    , p7_a114  NUMBER := 0-1962.0724
    , p7_a115  VARCHAR2 := fnd_api.g_miss_char
    , p7_a116  VARCHAR2 := fnd_api.g_miss_char
    , p7_a117  VARCHAR2 := fnd_api.g_miss_char
    , p7_a118  NUMBER := 0-1962.0724
    , p7_a119  VARCHAR2 := fnd_api.g_miss_char
    , p7_a120  VARCHAR2 := fnd_api.g_miss_char
    , p7_a121  VARCHAR2 := fnd_api.g_miss_char
    , p7_a122  VARCHAR2 := fnd_api.g_miss_char
    , p7_a123  VARCHAR2 := fnd_api.g_miss_char
    , p7_a124  VARCHAR2 := fnd_api.g_miss_char
    , p7_a125  DATE := fnd_api.g_miss_date
    , p7_a126  DATE := fnd_api.g_miss_date
    , p7_a127  NUMBER := 0-1962.0724
    , p7_a128  NUMBER := 0-1962.0724
    , p7_a129  VARCHAR2 := fnd_api.g_miss_char
    , p7_a130  VARCHAR2 := fnd_api.g_miss_char
    , p7_a131  VARCHAR2 := fnd_api.g_miss_char
    , p7_a132  VARCHAR2 := fnd_api.g_miss_char
    , p7_a133  VARCHAR2 := fnd_api.g_miss_char
    , p7_a134  VARCHAR2 := fnd_api.g_miss_char
    , p7_a135  VARCHAR2 := fnd_api.g_miss_char
    , p7_a136  NUMBER := 0-1962.0724
    , p7_a137  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_evo_rec.event_offer_id := p7_a0;
    ddp_evo_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_evo_rec.last_updated_by := p7_a2;
    ddp_evo_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_evo_rec.created_by := p7_a4;
    ddp_evo_rec.last_update_login := p7_a5;
    ddp_evo_rec.object_version_number := p7_a6;
    ddp_evo_rec.application_id := p7_a7;
    ddp_evo_rec.event_header_id := p7_a8;
    ddp_evo_rec.private_flag := p7_a9;
    ddp_evo_rec.active_flag := p7_a10;
    ddp_evo_rec.source_code := p7_a11;
    ddp_evo_rec.event_level := p7_a12;
    ddp_evo_rec.user_status_id := p7_a13;
    ddp_evo_rec.last_status_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_evo_rec.system_status_code := p7_a15;
    ddp_evo_rec.event_type_code := p7_a16;
    ddp_evo_rec.event_delivery_method_id := p7_a17;
    ddp_evo_rec.event_delivery_method_code := p7_a18;
    ddp_evo_rec.event_required_flag := p7_a19;
    ddp_evo_rec.event_language_code := p7_a20;
    ddp_evo_rec.event_location_id := p7_a21;
    ddp_evo_rec.city := p7_a22;
    ddp_evo_rec.state := p7_a23;
    ddp_evo_rec.province := p7_a24;
    ddp_evo_rec.country := p7_a25;
    ddp_evo_rec.overflow_flag := p7_a26;
    ddp_evo_rec.partner_flag := p7_a27;
    ddp_evo_rec.event_standalone_flag := p7_a28;
    ddp_evo_rec.reg_frozen_flag := p7_a29;
    ddp_evo_rec.reg_required_flag := p7_a30;
    ddp_evo_rec.reg_charge_flag := p7_a31;
    ddp_evo_rec.reg_invited_only_flag := p7_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p7_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p7_a34;
    ddp_evo_rec.parent_event_offer_id := p7_a35;
    ddp_evo_rec.event_duration := p7_a36;
    ddp_evo_rec.event_duration_uom_code := p7_a37;
    ddp_evo_rec.event_start_date := rosetta_g_miss_date_in_map(p7_a38);
    ddp_evo_rec.event_start_date_time := rosetta_g_miss_date_in_map(p7_a39);
    ddp_evo_rec.event_end_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_evo_rec.event_end_date_time := rosetta_g_miss_date_in_map(p7_a41);
    ddp_evo_rec.reg_start_date := rosetta_g_miss_date_in_map(p7_a42);
    ddp_evo_rec.reg_start_time := rosetta_g_miss_date_in_map(p7_a43);
    ddp_evo_rec.reg_end_date := rosetta_g_miss_date_in_map(p7_a44);
    ddp_evo_rec.reg_end_time := rosetta_g_miss_date_in_map(p7_a45);
    ddp_evo_rec.reg_maximum_capacity := p7_a46;
    ddp_evo_rec.reg_overbook_pct := p7_a47;
    ddp_evo_rec.reg_effective_capacity := p7_a48;
    ddp_evo_rec.reg_waitlist_pct := p7_a49;
    ddp_evo_rec.reg_minimum_capacity := p7_a50;
    ddp_evo_rec.reg_minimum_req_by_date := rosetta_g_miss_date_in_map(p7_a51);
    ddp_evo_rec.inventory_item_id := p7_a52;
    ddp_evo_rec.inventory_item := p7_a53;
    ddp_evo_rec.organization_id := p7_a54;
    ddp_evo_rec.pricelist_header_id := p7_a55;
    ddp_evo_rec.pricelist_line_id := p7_a56;
    ddp_evo_rec.org_id := p7_a57;
    ddp_evo_rec.waitlist_action_type_code := p7_a58;
    ddp_evo_rec.stream_type_code := p7_a59;
    ddp_evo_rec.owner_user_id := p7_a60;
    ddp_evo_rec.event_full_flag := p7_a61;
    ddp_evo_rec.forecasted_revenue := p7_a62;
    ddp_evo_rec.actual_revenue := p7_a63;
    ddp_evo_rec.forecasted_cost := p7_a64;
    ddp_evo_rec.actual_cost := p7_a65;
    ddp_evo_rec.fund_source_type_code := p7_a66;
    ddp_evo_rec.fund_source_id := p7_a67;
    ddp_evo_rec.cert_credit_type_code := p7_a68;
    ddp_evo_rec.certification_credits := p7_a69;
    ddp_evo_rec.coordinator_id := p7_a70;
    ddp_evo_rec.priority_type_code := p7_a71;
    ddp_evo_rec.cancellation_reason_code := p7_a72;
    ddp_evo_rec.auto_register_flag := p7_a73;
    ddp_evo_rec.email := p7_a74;
    ddp_evo_rec.phone := p7_a75;
    ddp_evo_rec.fund_amount_tc := p7_a76;
    ddp_evo_rec.fund_amount_fc := p7_a77;
    ddp_evo_rec.currency_code_tc := p7_a78;
    ddp_evo_rec.currency_code_fc := p7_a79;
    ddp_evo_rec.url := p7_a80;
    ddp_evo_rec.timezone_id := p7_a81;
    ddp_evo_rec.event_venue_id := p7_a82;
    ddp_evo_rec.pricelist_header_currency_code := p7_a83;
    ddp_evo_rec.pricelist_list_price := p7_a84;
    ddp_evo_rec.inbound_script_name := p7_a85;
    ddp_evo_rec.attribute_category := p7_a86;
    ddp_evo_rec.attribute1 := p7_a87;
    ddp_evo_rec.attribute2 := p7_a88;
    ddp_evo_rec.attribute3 := p7_a89;
    ddp_evo_rec.attribute4 := p7_a90;
    ddp_evo_rec.attribute5 := p7_a91;
    ddp_evo_rec.attribute6 := p7_a92;
    ddp_evo_rec.attribute7 := p7_a93;
    ddp_evo_rec.attribute8 := p7_a94;
    ddp_evo_rec.attribute9 := p7_a95;
    ddp_evo_rec.attribute10 := p7_a96;
    ddp_evo_rec.attribute11 := p7_a97;
    ddp_evo_rec.attribute12 := p7_a98;
    ddp_evo_rec.attribute13 := p7_a99;
    ddp_evo_rec.attribute14 := p7_a100;
    ddp_evo_rec.attribute15 := p7_a101;
    ddp_evo_rec.event_offer_name := p7_a102;
    ddp_evo_rec.event_mktg_message := p7_a103;
    ddp_evo_rec.description := p7_a104;
    ddp_evo_rec.custom_setup_id := p7_a105;
    ddp_evo_rec.country_code := p7_a106;
    ddp_evo_rec.business_unit_id := p7_a107;
    ddp_evo_rec.event_calendar := p7_a108;
    ddp_evo_rec.start_period_name := p7_a109;
    ddp_evo_rec.end_period_name := p7_a110;
    ddp_evo_rec.global_flag := p7_a111;
    ddp_evo_rec.task_id := p7_a112;
    ddp_evo_rec.parent_type := p7_a113;
    ddp_evo_rec.parent_id := p7_a114;
    ddp_evo_rec.create_attendant_lead_flag := p7_a115;
    ddp_evo_rec.create_registrant_lead_flag := p7_a116;
    ddp_evo_rec.event_object_type := p7_a117;
    ddp_evo_rec.reg_timezone_id := p7_a118;
    ddp_evo_rec.event_password := p7_a119;
    ddp_evo_rec.record_event_flag := p7_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p7_a121;
    ddp_evo_rec.publish_attendees_flag := p7_a122;
    ddp_evo_rec.direct_join_flag := p7_a123;
    ddp_evo_rec.event_notification_method := p7_a124;
    ddp_evo_rec.actual_start_time := rosetta_g_miss_date_in_map(p7_a125);
    ddp_evo_rec.actual_end_time := rosetta_g_miss_date_in_map(p7_a126);
    ddp_evo_rec.server_id := p7_a127;
    ddp_evo_rec.owner_fnd_user_id := p7_a128;
    ddp_evo_rec.meeting_dial_in_info := p7_a129;
    ddp_evo_rec.meeting_email_subject := p7_a130;
    ddp_evo_rec.meeting_schedule_type := p7_a131;
    ddp_evo_rec.meeting_status := p7_a132;
    ddp_evo_rec.meeting_misc_info := p7_a133;
    ddp_evo_rec.publish_flag := p7_a134;
    ddp_evo_rec.meeting_encryption_key_code := p7_a135;
    ddp_evo_rec.number_of_attendees := p7_a136;
    ddp_evo_rec.event_purpose_code := p7_a137;


    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pub.create_eventoffer(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evo_rec,
      x_evo_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_eventoffer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  DATE := fnd_api.g_miss_date
    , p7_a39  DATE := fnd_api.g_miss_date
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  DATE := fnd_api.g_miss_date
    , p7_a42  DATE := fnd_api.g_miss_date
    , p7_a43  DATE := fnd_api.g_miss_date
    , p7_a44  DATE := fnd_api.g_miss_date
    , p7_a45  DATE := fnd_api.g_miss_date
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  NUMBER := 0-1962.0724
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  DATE := fnd_api.g_miss_date
    , p7_a52  NUMBER := 0-1962.0724
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  NUMBER := 0-1962.0724
    , p7_a56  NUMBER := 0-1962.0724
    , p7_a57  NUMBER := 0-1962.0724
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  NUMBER := 0-1962.0724
    , p7_a63  NUMBER := 0-1962.0724
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  NUMBER := 0-1962.0724
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  NUMBER := 0-1962.0724
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  NUMBER := 0-1962.0724
    , p7_a82  NUMBER := 0-1962.0724
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  VARCHAR2 := fnd_api.g_miss_char
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  VARCHAR2 := fnd_api.g_miss_char
    , p7_a104  VARCHAR2 := fnd_api.g_miss_char
    , p7_a105  NUMBER := 0-1962.0724
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  NUMBER := 0-1962.0724
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
    , p7_a109  VARCHAR2 := fnd_api.g_miss_char
    , p7_a110  VARCHAR2 := fnd_api.g_miss_char
    , p7_a111  VARCHAR2 := fnd_api.g_miss_char
    , p7_a112  NUMBER := 0-1962.0724
    , p7_a113  VARCHAR2 := fnd_api.g_miss_char
    , p7_a114  NUMBER := 0-1962.0724
    , p7_a115  VARCHAR2 := fnd_api.g_miss_char
    , p7_a116  VARCHAR2 := fnd_api.g_miss_char
    , p7_a117  VARCHAR2 := fnd_api.g_miss_char
    , p7_a118  NUMBER := 0-1962.0724
    , p7_a119  VARCHAR2 := fnd_api.g_miss_char
    , p7_a120  VARCHAR2 := fnd_api.g_miss_char
    , p7_a121  VARCHAR2 := fnd_api.g_miss_char
    , p7_a122  VARCHAR2 := fnd_api.g_miss_char
    , p7_a123  VARCHAR2 := fnd_api.g_miss_char
    , p7_a124  VARCHAR2 := fnd_api.g_miss_char
    , p7_a125  DATE := fnd_api.g_miss_date
    , p7_a126  DATE := fnd_api.g_miss_date
    , p7_a127  NUMBER := 0-1962.0724
    , p7_a128  NUMBER := 0-1962.0724
    , p7_a129  VARCHAR2 := fnd_api.g_miss_char
    , p7_a130  VARCHAR2 := fnd_api.g_miss_char
    , p7_a131  VARCHAR2 := fnd_api.g_miss_char
    , p7_a132  VARCHAR2 := fnd_api.g_miss_char
    , p7_a133  VARCHAR2 := fnd_api.g_miss_char
    , p7_a134  VARCHAR2 := fnd_api.g_miss_char
    , p7_a135  VARCHAR2 := fnd_api.g_miss_char
    , p7_a136  NUMBER := 0-1962.0724
    , p7_a137  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_evo_rec.event_offer_id := p7_a0;
    ddp_evo_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_evo_rec.last_updated_by := p7_a2;
    ddp_evo_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_evo_rec.created_by := p7_a4;
    ddp_evo_rec.last_update_login := p7_a5;
    ddp_evo_rec.object_version_number := p7_a6;
    ddp_evo_rec.application_id := p7_a7;
    ddp_evo_rec.event_header_id := p7_a8;
    ddp_evo_rec.private_flag := p7_a9;
    ddp_evo_rec.active_flag := p7_a10;
    ddp_evo_rec.source_code := p7_a11;
    ddp_evo_rec.event_level := p7_a12;
    ddp_evo_rec.user_status_id := p7_a13;
    ddp_evo_rec.last_status_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_evo_rec.system_status_code := p7_a15;
    ddp_evo_rec.event_type_code := p7_a16;
    ddp_evo_rec.event_delivery_method_id := p7_a17;
    ddp_evo_rec.event_delivery_method_code := p7_a18;
    ddp_evo_rec.event_required_flag := p7_a19;
    ddp_evo_rec.event_language_code := p7_a20;
    ddp_evo_rec.event_location_id := p7_a21;
    ddp_evo_rec.city := p7_a22;
    ddp_evo_rec.state := p7_a23;
    ddp_evo_rec.province := p7_a24;
    ddp_evo_rec.country := p7_a25;
    ddp_evo_rec.overflow_flag := p7_a26;
    ddp_evo_rec.partner_flag := p7_a27;
    ddp_evo_rec.event_standalone_flag := p7_a28;
    ddp_evo_rec.reg_frozen_flag := p7_a29;
    ddp_evo_rec.reg_required_flag := p7_a30;
    ddp_evo_rec.reg_charge_flag := p7_a31;
    ddp_evo_rec.reg_invited_only_flag := p7_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p7_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p7_a34;
    ddp_evo_rec.parent_event_offer_id := p7_a35;
    ddp_evo_rec.event_duration := p7_a36;
    ddp_evo_rec.event_duration_uom_code := p7_a37;
    ddp_evo_rec.event_start_date := rosetta_g_miss_date_in_map(p7_a38);
    ddp_evo_rec.event_start_date_time := rosetta_g_miss_date_in_map(p7_a39);
    ddp_evo_rec.event_end_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_evo_rec.event_end_date_time := rosetta_g_miss_date_in_map(p7_a41);
    ddp_evo_rec.reg_start_date := rosetta_g_miss_date_in_map(p7_a42);
    ddp_evo_rec.reg_start_time := rosetta_g_miss_date_in_map(p7_a43);
    ddp_evo_rec.reg_end_date := rosetta_g_miss_date_in_map(p7_a44);
    ddp_evo_rec.reg_end_time := rosetta_g_miss_date_in_map(p7_a45);
    ddp_evo_rec.reg_maximum_capacity := p7_a46;
    ddp_evo_rec.reg_overbook_pct := p7_a47;
    ddp_evo_rec.reg_effective_capacity := p7_a48;
    ddp_evo_rec.reg_waitlist_pct := p7_a49;
    ddp_evo_rec.reg_minimum_capacity := p7_a50;
    ddp_evo_rec.reg_minimum_req_by_date := rosetta_g_miss_date_in_map(p7_a51);
    ddp_evo_rec.inventory_item_id := p7_a52;
    ddp_evo_rec.inventory_item := p7_a53;
    ddp_evo_rec.organization_id := p7_a54;
    ddp_evo_rec.pricelist_header_id := p7_a55;
    ddp_evo_rec.pricelist_line_id := p7_a56;
    ddp_evo_rec.org_id := p7_a57;
    ddp_evo_rec.waitlist_action_type_code := p7_a58;
    ddp_evo_rec.stream_type_code := p7_a59;
    ddp_evo_rec.owner_user_id := p7_a60;
    ddp_evo_rec.event_full_flag := p7_a61;
    ddp_evo_rec.forecasted_revenue := p7_a62;
    ddp_evo_rec.actual_revenue := p7_a63;
    ddp_evo_rec.forecasted_cost := p7_a64;
    ddp_evo_rec.actual_cost := p7_a65;
    ddp_evo_rec.fund_source_type_code := p7_a66;
    ddp_evo_rec.fund_source_id := p7_a67;
    ddp_evo_rec.cert_credit_type_code := p7_a68;
    ddp_evo_rec.certification_credits := p7_a69;
    ddp_evo_rec.coordinator_id := p7_a70;
    ddp_evo_rec.priority_type_code := p7_a71;
    ddp_evo_rec.cancellation_reason_code := p7_a72;
    ddp_evo_rec.auto_register_flag := p7_a73;
    ddp_evo_rec.email := p7_a74;
    ddp_evo_rec.phone := p7_a75;
    ddp_evo_rec.fund_amount_tc := p7_a76;
    ddp_evo_rec.fund_amount_fc := p7_a77;
    ddp_evo_rec.currency_code_tc := p7_a78;
    ddp_evo_rec.currency_code_fc := p7_a79;
    ddp_evo_rec.url := p7_a80;
    ddp_evo_rec.timezone_id := p7_a81;
    ddp_evo_rec.event_venue_id := p7_a82;
    ddp_evo_rec.pricelist_header_currency_code := p7_a83;
    ddp_evo_rec.pricelist_list_price := p7_a84;
    ddp_evo_rec.inbound_script_name := p7_a85;
    ddp_evo_rec.attribute_category := p7_a86;
    ddp_evo_rec.attribute1 := p7_a87;
    ddp_evo_rec.attribute2 := p7_a88;
    ddp_evo_rec.attribute3 := p7_a89;
    ddp_evo_rec.attribute4 := p7_a90;
    ddp_evo_rec.attribute5 := p7_a91;
    ddp_evo_rec.attribute6 := p7_a92;
    ddp_evo_rec.attribute7 := p7_a93;
    ddp_evo_rec.attribute8 := p7_a94;
    ddp_evo_rec.attribute9 := p7_a95;
    ddp_evo_rec.attribute10 := p7_a96;
    ddp_evo_rec.attribute11 := p7_a97;
    ddp_evo_rec.attribute12 := p7_a98;
    ddp_evo_rec.attribute13 := p7_a99;
    ddp_evo_rec.attribute14 := p7_a100;
    ddp_evo_rec.attribute15 := p7_a101;
    ddp_evo_rec.event_offer_name := p7_a102;
    ddp_evo_rec.event_mktg_message := p7_a103;
    ddp_evo_rec.description := p7_a104;
    ddp_evo_rec.custom_setup_id := p7_a105;
    ddp_evo_rec.country_code := p7_a106;
    ddp_evo_rec.business_unit_id := p7_a107;
    ddp_evo_rec.event_calendar := p7_a108;
    ddp_evo_rec.start_period_name := p7_a109;
    ddp_evo_rec.end_period_name := p7_a110;
    ddp_evo_rec.global_flag := p7_a111;
    ddp_evo_rec.task_id := p7_a112;
    ddp_evo_rec.parent_type := p7_a113;
    ddp_evo_rec.parent_id := p7_a114;
    ddp_evo_rec.create_attendant_lead_flag := p7_a115;
    ddp_evo_rec.create_registrant_lead_flag := p7_a116;
    ddp_evo_rec.event_object_type := p7_a117;
    ddp_evo_rec.reg_timezone_id := p7_a118;
    ddp_evo_rec.event_password := p7_a119;
    ddp_evo_rec.record_event_flag := p7_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p7_a121;
    ddp_evo_rec.publish_attendees_flag := p7_a122;
    ddp_evo_rec.direct_join_flag := p7_a123;
    ddp_evo_rec.event_notification_method := p7_a124;
    ddp_evo_rec.actual_start_time := rosetta_g_miss_date_in_map(p7_a125);
    ddp_evo_rec.actual_end_time := rosetta_g_miss_date_in_map(p7_a126);
    ddp_evo_rec.server_id := p7_a127;
    ddp_evo_rec.owner_fnd_user_id := p7_a128;
    ddp_evo_rec.meeting_dial_in_info := p7_a129;
    ddp_evo_rec.meeting_email_subject := p7_a130;
    ddp_evo_rec.meeting_schedule_type := p7_a131;
    ddp_evo_rec.meeting_status := p7_a132;
    ddp_evo_rec.meeting_misc_info := p7_a133;
    ddp_evo_rec.publish_flag := p7_a134;
    ddp_evo_rec.meeting_encryption_key_code := p7_a135;
    ddp_evo_rec.number_of_attendees := p7_a136;
    ddp_evo_rec.event_purpose_code := p7_a137;

    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pub.update_eventoffer(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evo_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_eventoffer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  DATE := fnd_api.g_miss_date
    , p6_a39  DATE := fnd_api.g_miss_date
    , p6_a40  DATE := fnd_api.g_miss_date
    , p6_a41  DATE := fnd_api.g_miss_date
    , p6_a42  DATE := fnd_api.g_miss_date
    , p6_a43  DATE := fnd_api.g_miss_date
    , p6_a44  DATE := fnd_api.g_miss_date
    , p6_a45  DATE := fnd_api.g_miss_date
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  NUMBER := 0-1962.0724
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  DATE := fnd_api.g_miss_date
    , p6_a52  NUMBER := 0-1962.0724
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  NUMBER := 0-1962.0724
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  NUMBER := 0-1962.0724
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  NUMBER := 0-1962.0724
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  NUMBER := 0-1962.0724
    , p6_a63  NUMBER := 0-1962.0724
    , p6_a64  NUMBER := 0-1962.0724
    , p6_a65  NUMBER := 0-1962.0724
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  NUMBER := 0-1962.0724
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  NUMBER := 0-1962.0724
    , p6_a82  NUMBER := 0-1962.0724
    , p6_a83  VARCHAR2 := fnd_api.g_miss_char
    , p6_a84  NUMBER := 0-1962.0724
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  VARCHAR2 := fnd_api.g_miss_char
    , p6_a94  VARCHAR2 := fnd_api.g_miss_char
    , p6_a95  VARCHAR2 := fnd_api.g_miss_char
    , p6_a96  VARCHAR2 := fnd_api.g_miss_char
    , p6_a97  VARCHAR2 := fnd_api.g_miss_char
    , p6_a98  VARCHAR2 := fnd_api.g_miss_char
    , p6_a99  VARCHAR2 := fnd_api.g_miss_char
    , p6_a100  VARCHAR2 := fnd_api.g_miss_char
    , p6_a101  VARCHAR2 := fnd_api.g_miss_char
    , p6_a102  VARCHAR2 := fnd_api.g_miss_char
    , p6_a103  VARCHAR2 := fnd_api.g_miss_char
    , p6_a104  VARCHAR2 := fnd_api.g_miss_char
    , p6_a105  NUMBER := 0-1962.0724
    , p6_a106  VARCHAR2 := fnd_api.g_miss_char
    , p6_a107  NUMBER := 0-1962.0724
    , p6_a108  VARCHAR2 := fnd_api.g_miss_char
    , p6_a109  VARCHAR2 := fnd_api.g_miss_char
    , p6_a110  VARCHAR2 := fnd_api.g_miss_char
    , p6_a111  VARCHAR2 := fnd_api.g_miss_char
    , p6_a112  NUMBER := 0-1962.0724
    , p6_a113  VARCHAR2 := fnd_api.g_miss_char
    , p6_a114  NUMBER := 0-1962.0724
    , p6_a115  VARCHAR2 := fnd_api.g_miss_char
    , p6_a116  VARCHAR2 := fnd_api.g_miss_char
    , p6_a117  VARCHAR2 := fnd_api.g_miss_char
    , p6_a118  NUMBER := 0-1962.0724
    , p6_a119  VARCHAR2 := fnd_api.g_miss_char
    , p6_a120  VARCHAR2 := fnd_api.g_miss_char
    , p6_a121  VARCHAR2 := fnd_api.g_miss_char
    , p6_a122  VARCHAR2 := fnd_api.g_miss_char
    , p6_a123  VARCHAR2 := fnd_api.g_miss_char
    , p6_a124  VARCHAR2 := fnd_api.g_miss_char
    , p6_a125  DATE := fnd_api.g_miss_date
    , p6_a126  DATE := fnd_api.g_miss_date
    , p6_a127  NUMBER := 0-1962.0724
    , p6_a128  NUMBER := 0-1962.0724
    , p6_a129  VARCHAR2 := fnd_api.g_miss_char
    , p6_a130  VARCHAR2 := fnd_api.g_miss_char
    , p6_a131  VARCHAR2 := fnd_api.g_miss_char
    , p6_a132  VARCHAR2 := fnd_api.g_miss_char
    , p6_a133  VARCHAR2 := fnd_api.g_miss_char
    , p6_a134  VARCHAR2 := fnd_api.g_miss_char
    , p6_a135  VARCHAR2 := fnd_api.g_miss_char
    , p6_a136  NUMBER := 0-1962.0724
    , p6_a137  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_evo_rec ams_eventoffer_pvt.evo_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_evo_rec.event_offer_id := p6_a0;
    ddp_evo_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_evo_rec.last_updated_by := p6_a2;
    ddp_evo_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_evo_rec.created_by := p6_a4;
    ddp_evo_rec.last_update_login := p6_a5;
    ddp_evo_rec.object_version_number := p6_a6;
    ddp_evo_rec.application_id := p6_a7;
    ddp_evo_rec.event_header_id := p6_a8;
    ddp_evo_rec.private_flag := p6_a9;
    ddp_evo_rec.active_flag := p6_a10;
    ddp_evo_rec.source_code := p6_a11;
    ddp_evo_rec.event_level := p6_a12;
    ddp_evo_rec.user_status_id := p6_a13;
    ddp_evo_rec.last_status_date := rosetta_g_miss_date_in_map(p6_a14);
    ddp_evo_rec.system_status_code := p6_a15;
    ddp_evo_rec.event_type_code := p6_a16;
    ddp_evo_rec.event_delivery_method_id := p6_a17;
    ddp_evo_rec.event_delivery_method_code := p6_a18;
    ddp_evo_rec.event_required_flag := p6_a19;
    ddp_evo_rec.event_language_code := p6_a20;
    ddp_evo_rec.event_location_id := p6_a21;
    ddp_evo_rec.city := p6_a22;
    ddp_evo_rec.state := p6_a23;
    ddp_evo_rec.province := p6_a24;
    ddp_evo_rec.country := p6_a25;
    ddp_evo_rec.overflow_flag := p6_a26;
    ddp_evo_rec.partner_flag := p6_a27;
    ddp_evo_rec.event_standalone_flag := p6_a28;
    ddp_evo_rec.reg_frozen_flag := p6_a29;
    ddp_evo_rec.reg_required_flag := p6_a30;
    ddp_evo_rec.reg_charge_flag := p6_a31;
    ddp_evo_rec.reg_invited_only_flag := p6_a32;
    ddp_evo_rec.reg_waitlist_allowed_flag := p6_a33;
    ddp_evo_rec.reg_overbook_allowed_flag := p6_a34;
    ddp_evo_rec.parent_event_offer_id := p6_a35;
    ddp_evo_rec.event_duration := p6_a36;
    ddp_evo_rec.event_duration_uom_code := p6_a37;
    ddp_evo_rec.event_start_date := rosetta_g_miss_date_in_map(p6_a38);
    ddp_evo_rec.event_start_date_time := rosetta_g_miss_date_in_map(p6_a39);
    ddp_evo_rec.event_end_date := rosetta_g_miss_date_in_map(p6_a40);
    ddp_evo_rec.event_end_date_time := rosetta_g_miss_date_in_map(p6_a41);
    ddp_evo_rec.reg_start_date := rosetta_g_miss_date_in_map(p6_a42);
    ddp_evo_rec.reg_start_time := rosetta_g_miss_date_in_map(p6_a43);
    ddp_evo_rec.reg_end_date := rosetta_g_miss_date_in_map(p6_a44);
    ddp_evo_rec.reg_end_time := rosetta_g_miss_date_in_map(p6_a45);
    ddp_evo_rec.reg_maximum_capacity := p6_a46;
    ddp_evo_rec.reg_overbook_pct := p6_a47;
    ddp_evo_rec.reg_effective_capacity := p6_a48;
    ddp_evo_rec.reg_waitlist_pct := p6_a49;
    ddp_evo_rec.reg_minimum_capacity := p6_a50;
    ddp_evo_rec.reg_minimum_req_by_date := rosetta_g_miss_date_in_map(p6_a51);
    ddp_evo_rec.inventory_item_id := p6_a52;
    ddp_evo_rec.inventory_item := p6_a53;
    ddp_evo_rec.organization_id := p6_a54;
    ddp_evo_rec.pricelist_header_id := p6_a55;
    ddp_evo_rec.pricelist_line_id := p6_a56;
    ddp_evo_rec.org_id := p6_a57;
    ddp_evo_rec.waitlist_action_type_code := p6_a58;
    ddp_evo_rec.stream_type_code := p6_a59;
    ddp_evo_rec.owner_user_id := p6_a60;
    ddp_evo_rec.event_full_flag := p6_a61;
    ddp_evo_rec.forecasted_revenue := p6_a62;
    ddp_evo_rec.actual_revenue := p6_a63;
    ddp_evo_rec.forecasted_cost := p6_a64;
    ddp_evo_rec.actual_cost := p6_a65;
    ddp_evo_rec.fund_source_type_code := p6_a66;
    ddp_evo_rec.fund_source_id := p6_a67;
    ddp_evo_rec.cert_credit_type_code := p6_a68;
    ddp_evo_rec.certification_credits := p6_a69;
    ddp_evo_rec.coordinator_id := p6_a70;
    ddp_evo_rec.priority_type_code := p6_a71;
    ddp_evo_rec.cancellation_reason_code := p6_a72;
    ddp_evo_rec.auto_register_flag := p6_a73;
    ddp_evo_rec.email := p6_a74;
    ddp_evo_rec.phone := p6_a75;
    ddp_evo_rec.fund_amount_tc := p6_a76;
    ddp_evo_rec.fund_amount_fc := p6_a77;
    ddp_evo_rec.currency_code_tc := p6_a78;
    ddp_evo_rec.currency_code_fc := p6_a79;
    ddp_evo_rec.url := p6_a80;
    ddp_evo_rec.timezone_id := p6_a81;
    ddp_evo_rec.event_venue_id := p6_a82;
    ddp_evo_rec.pricelist_header_currency_code := p6_a83;
    ddp_evo_rec.pricelist_list_price := p6_a84;
    ddp_evo_rec.inbound_script_name := p6_a85;
    ddp_evo_rec.attribute_category := p6_a86;
    ddp_evo_rec.attribute1 := p6_a87;
    ddp_evo_rec.attribute2 := p6_a88;
    ddp_evo_rec.attribute3 := p6_a89;
    ddp_evo_rec.attribute4 := p6_a90;
    ddp_evo_rec.attribute5 := p6_a91;
    ddp_evo_rec.attribute6 := p6_a92;
    ddp_evo_rec.attribute7 := p6_a93;
    ddp_evo_rec.attribute8 := p6_a94;
    ddp_evo_rec.attribute9 := p6_a95;
    ddp_evo_rec.attribute10 := p6_a96;
    ddp_evo_rec.attribute11 := p6_a97;
    ddp_evo_rec.attribute12 := p6_a98;
    ddp_evo_rec.attribute13 := p6_a99;
    ddp_evo_rec.attribute14 := p6_a100;
    ddp_evo_rec.attribute15 := p6_a101;
    ddp_evo_rec.event_offer_name := p6_a102;
    ddp_evo_rec.event_mktg_message := p6_a103;
    ddp_evo_rec.description := p6_a104;
    ddp_evo_rec.custom_setup_id := p6_a105;
    ddp_evo_rec.country_code := p6_a106;
    ddp_evo_rec.business_unit_id := p6_a107;
    ddp_evo_rec.event_calendar := p6_a108;
    ddp_evo_rec.start_period_name := p6_a109;
    ddp_evo_rec.end_period_name := p6_a110;
    ddp_evo_rec.global_flag := p6_a111;
    ddp_evo_rec.task_id := p6_a112;
    ddp_evo_rec.parent_type := p6_a113;
    ddp_evo_rec.parent_id := p6_a114;
    ddp_evo_rec.create_attendant_lead_flag := p6_a115;
    ddp_evo_rec.create_registrant_lead_flag := p6_a116;
    ddp_evo_rec.event_object_type := p6_a117;
    ddp_evo_rec.reg_timezone_id := p6_a118;
    ddp_evo_rec.event_password := p6_a119;
    ddp_evo_rec.record_event_flag := p6_a120;
    ddp_evo_rec.allow_register_in_middle_flag := p6_a121;
    ddp_evo_rec.publish_attendees_flag := p6_a122;
    ddp_evo_rec.direct_join_flag := p6_a123;
    ddp_evo_rec.event_notification_method := p6_a124;
    ddp_evo_rec.actual_start_time := rosetta_g_miss_date_in_map(p6_a125);
    ddp_evo_rec.actual_end_time := rosetta_g_miss_date_in_map(p6_a126);
    ddp_evo_rec.server_id := p6_a127;
    ddp_evo_rec.owner_fnd_user_id := p6_a128;
    ddp_evo_rec.meeting_dial_in_info := p6_a129;
    ddp_evo_rec.meeting_email_subject := p6_a130;
    ddp_evo_rec.meeting_schedule_type := p6_a131;
    ddp_evo_rec.meeting_status := p6_a132;
    ddp_evo_rec.meeting_misc_info := p6_a133;
    ddp_evo_rec.publish_flag := p6_a134;
    ddp_evo_rec.meeting_encryption_key_code := p6_a135;
    ddp_evo_rec.number_of_attendees := p6_a136;
    ddp_evo_rec.event_purpose_code := p6_a137;

    -- here's the delegated call to the old PL/SQL routine
    ams_eventoffer_pub.validate_eventoffer(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evo_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end ams_eventoffer_pub_w;

/
