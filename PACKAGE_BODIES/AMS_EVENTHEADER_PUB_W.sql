--------------------------------------------------------
--  DDL for Package Body AMS_EVENTHEADER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTHEADER_PUB_W" as
  /* $Header: amswevhb.pls 115.16 2003/05/31 00:28:41 dbiswas ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_eventheader(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_evh_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  DATE := fnd_api.g_miss_date
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  NUMBER := 0-1962.0724
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_evh_rec ams_eventheader_pvt.evh_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_evh_rec.event_header_id := p7_a0;
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_evh_rec.last_updated_by := p7_a2;
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_evh_rec.created_by := p7_a4;
    ddp_evh_rec.last_update_login := p7_a5;
    ddp_evh_rec.object_version_number := p7_a6;
    ddp_evh_rec.event_level := p7_a7;
    ddp_evh_rec.application_id := p7_a8;
    ddp_evh_rec.event_type_code := p7_a9;
    ddp_evh_rec.active_flag := p7_a10;
    ddp_evh_rec.private_flag := p7_a11;
    ddp_evh_rec.user_status_id := p7_a12;
    ddp_evh_rec.system_status_code := p7_a13;
    ddp_evh_rec.last_status_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_evh_rec.stream_type_code := p7_a15;
    ddp_evh_rec.source_code := p7_a16;
    ddp_evh_rec.event_standalone_flag := p7_a17;
    ddp_evh_rec.day_of_event := p7_a18;
    ddp_evh_rec.agenda_start_time := rosetta_g_miss_date_in_map(p7_a19);
    ddp_evh_rec.agenda_end_time := rosetta_g_miss_date_in_map(p7_a20);
    ddp_evh_rec.reg_required_flag := p7_a21;
    ddp_evh_rec.reg_charge_flag := p7_a22;
    ddp_evh_rec.reg_invited_only_flag := p7_a23;
    ddp_evh_rec.partner_flag := p7_a24;
    ddp_evh_rec.overflow_flag := p7_a25;
    ddp_evh_rec.parent_event_header_id := p7_a26;
    ddp_evh_rec.duration := p7_a27;
    ddp_evh_rec.duration_uom_code := p7_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_evh_rec.reg_maximum_capacity := p7_a31;
    ddp_evh_rec.reg_minimum_capacity := p7_a32;
    ddp_evh_rec.main_language_code := p7_a33;
    ddp_evh_rec.cert_credit_type_code := p7_a34;
    ddp_evh_rec.certification_credits := p7_a35;
    ddp_evh_rec.inventory_item_id := p7_a36;
    ddp_evh_rec.organization_id := p7_a37;
    ddp_evh_rec.org_id := p7_a38;
    ddp_evh_rec.forecasted_revenue := p7_a39;
    ddp_evh_rec.actual_revenue := p7_a40;
    ddp_evh_rec.forecasted_cost := p7_a41;
    ddp_evh_rec.actual_cost := p7_a42;
    ddp_evh_rec.coordinator_id := p7_a43;
    ddp_evh_rec.fund_source_type_code := p7_a44;
    ddp_evh_rec.fund_source_id := p7_a45;
    ddp_evh_rec.fund_amount_tc := p7_a46;
    ddp_evh_rec.fund_amount_fc := p7_a47;
    ddp_evh_rec.currency_code_tc := p7_a48;
    ddp_evh_rec.currency_code_fc := p7_a49;
    ddp_evh_rec.owner_user_id := p7_a50;
    ddp_evh_rec.url := p7_a51;
    ddp_evh_rec.email := p7_a52;
    ddp_evh_rec.phone := p7_a53;
    ddp_evh_rec.priority_type_code := p7_a54;
    ddp_evh_rec.cancellation_reason_code := p7_a55;
    ddp_evh_rec.inbound_script_name := p7_a56;
    ddp_evh_rec.attribute_category := p7_a57;
    ddp_evh_rec.attribute1 := p7_a58;
    ddp_evh_rec.attribute2 := p7_a59;
    ddp_evh_rec.attribute3 := p7_a60;
    ddp_evh_rec.attribute4 := p7_a61;
    ddp_evh_rec.attribute5 := p7_a62;
    ddp_evh_rec.attribute6 := p7_a63;
    ddp_evh_rec.attribute7 := p7_a64;
    ddp_evh_rec.attribute8 := p7_a65;
    ddp_evh_rec.attribute9 := p7_a66;
    ddp_evh_rec.attribute10 := p7_a67;
    ddp_evh_rec.attribute11 := p7_a68;
    ddp_evh_rec.attribute12 := p7_a69;
    ddp_evh_rec.attribute13 := p7_a70;
    ddp_evh_rec.attribute14 := p7_a71;
    ddp_evh_rec.attribute15 := p7_a72;
    ddp_evh_rec.event_header_name := p7_a73;
    ddp_evh_rec.event_mktg_message := p7_a74;
    ddp_evh_rec.description := p7_a75;
    ddp_evh_rec.custom_setup_id := p7_a76;
    ddp_evh_rec.country_code := p7_a77;
    ddp_evh_rec.business_unit_id := p7_a78;
    ddp_evh_rec.event_calendar := p7_a79;
    ddp_evh_rec.start_period_name := p7_a80;
    ddp_evh_rec.end_period_name := p7_a81;
    ddp_evh_rec.global_flag := p7_a82;
    ddp_evh_rec.task_id := p7_a83;
    ddp_evh_rec.program_id := p7_a84;
    ddp_evh_rec.create_attendant_lead_flag := p7_a85;
    ddp_evh_rec.create_registrant_lead_flag := p7_a86;
    ddp_evh_rec.event_purpose_code := p7_a87;


    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pub.create_eventheader(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evh_rec,
      x_evh_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_eventheader(p_api_version  NUMBER
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
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  DATE := fnd_api.g_miss_date
    , p7_a30  DATE := fnd_api.g_miss_date
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  NUMBER := 0-1962.0724
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_evh_rec ams_eventheader_pvt.evh_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_evh_rec.event_header_id := p7_a0;
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_evh_rec.last_updated_by := p7_a2;
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_evh_rec.created_by := p7_a4;
    ddp_evh_rec.last_update_login := p7_a5;
    ddp_evh_rec.object_version_number := p7_a6;
    ddp_evh_rec.event_level := p7_a7;
    ddp_evh_rec.application_id := p7_a8;
    ddp_evh_rec.event_type_code := p7_a9;
    ddp_evh_rec.active_flag := p7_a10;
    ddp_evh_rec.private_flag := p7_a11;
    ddp_evh_rec.user_status_id := p7_a12;
    ddp_evh_rec.system_status_code := p7_a13;
    ddp_evh_rec.last_status_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_evh_rec.stream_type_code := p7_a15;
    ddp_evh_rec.source_code := p7_a16;
    ddp_evh_rec.event_standalone_flag := p7_a17;
    ddp_evh_rec.day_of_event := p7_a18;
    ddp_evh_rec.agenda_start_time := rosetta_g_miss_date_in_map(p7_a19);
    ddp_evh_rec.agenda_end_time := rosetta_g_miss_date_in_map(p7_a20);
    ddp_evh_rec.reg_required_flag := p7_a21;
    ddp_evh_rec.reg_charge_flag := p7_a22;
    ddp_evh_rec.reg_invited_only_flag := p7_a23;
    ddp_evh_rec.partner_flag := p7_a24;
    ddp_evh_rec.overflow_flag := p7_a25;
    ddp_evh_rec.parent_event_header_id := p7_a26;
    ddp_evh_rec.duration := p7_a27;
    ddp_evh_rec.duration_uom_code := p7_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_evh_rec.reg_maximum_capacity := p7_a31;
    ddp_evh_rec.reg_minimum_capacity := p7_a32;
    ddp_evh_rec.main_language_code := p7_a33;
    ddp_evh_rec.cert_credit_type_code := p7_a34;
    ddp_evh_rec.certification_credits := p7_a35;
    ddp_evh_rec.inventory_item_id := p7_a36;
    ddp_evh_rec.organization_id := p7_a37;
    ddp_evh_rec.org_id := p7_a38;
    ddp_evh_rec.forecasted_revenue := p7_a39;
    ddp_evh_rec.actual_revenue := p7_a40;
    ddp_evh_rec.forecasted_cost := p7_a41;
    ddp_evh_rec.actual_cost := p7_a42;
    ddp_evh_rec.coordinator_id := p7_a43;
    ddp_evh_rec.fund_source_type_code := p7_a44;
    ddp_evh_rec.fund_source_id := p7_a45;
    ddp_evh_rec.fund_amount_tc := p7_a46;
    ddp_evh_rec.fund_amount_fc := p7_a47;
    ddp_evh_rec.currency_code_tc := p7_a48;
    ddp_evh_rec.currency_code_fc := p7_a49;
    ddp_evh_rec.owner_user_id := p7_a50;
    ddp_evh_rec.url := p7_a51;
    ddp_evh_rec.email := p7_a52;
    ddp_evh_rec.phone := p7_a53;
    ddp_evh_rec.priority_type_code := p7_a54;
    ddp_evh_rec.cancellation_reason_code := p7_a55;
    ddp_evh_rec.inbound_script_name := p7_a56;
    ddp_evh_rec.attribute_category := p7_a57;
    ddp_evh_rec.attribute1 := p7_a58;
    ddp_evh_rec.attribute2 := p7_a59;
    ddp_evh_rec.attribute3 := p7_a60;
    ddp_evh_rec.attribute4 := p7_a61;
    ddp_evh_rec.attribute5 := p7_a62;
    ddp_evh_rec.attribute6 := p7_a63;
    ddp_evh_rec.attribute7 := p7_a64;
    ddp_evh_rec.attribute8 := p7_a65;
    ddp_evh_rec.attribute9 := p7_a66;
    ddp_evh_rec.attribute10 := p7_a67;
    ddp_evh_rec.attribute11 := p7_a68;
    ddp_evh_rec.attribute12 := p7_a69;
    ddp_evh_rec.attribute13 := p7_a70;
    ddp_evh_rec.attribute14 := p7_a71;
    ddp_evh_rec.attribute15 := p7_a72;
    ddp_evh_rec.event_header_name := p7_a73;
    ddp_evh_rec.event_mktg_message := p7_a74;
    ddp_evh_rec.description := p7_a75;
    ddp_evh_rec.custom_setup_id := p7_a76;
    ddp_evh_rec.country_code := p7_a77;
    ddp_evh_rec.business_unit_id := p7_a78;
    ddp_evh_rec.event_calendar := p7_a79;
    ddp_evh_rec.start_period_name := p7_a80;
    ddp_evh_rec.end_period_name := p7_a81;
    ddp_evh_rec.global_flag := p7_a82;
    ddp_evh_rec.task_id := p7_a83;
    ddp_evh_rec.program_id := p7_a84;
    ddp_evh_rec.create_attendant_lead_flag := p7_a85;
    ddp_evh_rec.create_registrant_lead_flag := p7_a86;
    ddp_evh_rec.event_purpose_code := p7_a87;

    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pub.update_eventheader(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evh_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_eventheader(p_api_version  NUMBER
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
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  DATE := fnd_api.g_miss_date
    , p6_a20  DATE := fnd_api.g_miss_date
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  DATE := fnd_api.g_miss_date
    , p6_a30  DATE := fnd_api.g_miss_date
    , p6_a31  NUMBER := 0-1962.0724
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  NUMBER := 0-1962.0724
    , p6_a41  NUMBER := 0-1962.0724
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  NUMBER := 0-1962.0724
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  NUMBER := 0-1962.0724
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_evh_rec ams_eventheader_pvt.evh_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_evh_rec.event_header_id := p6_a0;
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_evh_rec.last_updated_by := p6_a2;
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_evh_rec.created_by := p6_a4;
    ddp_evh_rec.last_update_login := p6_a5;
    ddp_evh_rec.object_version_number := p6_a6;
    ddp_evh_rec.event_level := p6_a7;
    ddp_evh_rec.application_id := p6_a8;
    ddp_evh_rec.event_type_code := p6_a9;
    ddp_evh_rec.active_flag := p6_a10;
    ddp_evh_rec.private_flag := p6_a11;
    ddp_evh_rec.user_status_id := p6_a12;
    ddp_evh_rec.system_status_code := p6_a13;
    ddp_evh_rec.last_status_date := rosetta_g_miss_date_in_map(p6_a14);
    ddp_evh_rec.stream_type_code := p6_a15;
    ddp_evh_rec.source_code := p6_a16;
    ddp_evh_rec.event_standalone_flag := p6_a17;
    ddp_evh_rec.day_of_event := p6_a18;
    ddp_evh_rec.agenda_start_time := rosetta_g_miss_date_in_map(p6_a19);
    ddp_evh_rec.agenda_end_time := rosetta_g_miss_date_in_map(p6_a20);
    ddp_evh_rec.reg_required_flag := p6_a21;
    ddp_evh_rec.reg_charge_flag := p6_a22;
    ddp_evh_rec.reg_invited_only_flag := p6_a23;
    ddp_evh_rec.partner_flag := p6_a24;
    ddp_evh_rec.overflow_flag := p6_a25;
    ddp_evh_rec.parent_event_header_id := p6_a26;
    ddp_evh_rec.duration := p6_a27;
    ddp_evh_rec.duration_uom_code := p6_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p6_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p6_a30);
    ddp_evh_rec.reg_maximum_capacity := p6_a31;
    ddp_evh_rec.reg_minimum_capacity := p6_a32;
    ddp_evh_rec.main_language_code := p6_a33;
    ddp_evh_rec.cert_credit_type_code := p6_a34;
    ddp_evh_rec.certification_credits := p6_a35;
    ddp_evh_rec.inventory_item_id := p6_a36;
    ddp_evh_rec.organization_id := p6_a37;
    ddp_evh_rec.org_id := p6_a38;
    ddp_evh_rec.forecasted_revenue := p6_a39;
    ddp_evh_rec.actual_revenue := p6_a40;
    ddp_evh_rec.forecasted_cost := p6_a41;
    ddp_evh_rec.actual_cost := p6_a42;
    ddp_evh_rec.coordinator_id := p6_a43;
    ddp_evh_rec.fund_source_type_code := p6_a44;
    ddp_evh_rec.fund_source_id := p6_a45;
    ddp_evh_rec.fund_amount_tc := p6_a46;
    ddp_evh_rec.fund_amount_fc := p6_a47;
    ddp_evh_rec.currency_code_tc := p6_a48;
    ddp_evh_rec.currency_code_fc := p6_a49;
    ddp_evh_rec.owner_user_id := p6_a50;
    ddp_evh_rec.url := p6_a51;
    ddp_evh_rec.email := p6_a52;
    ddp_evh_rec.phone := p6_a53;
    ddp_evh_rec.priority_type_code := p6_a54;
    ddp_evh_rec.cancellation_reason_code := p6_a55;
    ddp_evh_rec.inbound_script_name := p6_a56;
    ddp_evh_rec.attribute_category := p6_a57;
    ddp_evh_rec.attribute1 := p6_a58;
    ddp_evh_rec.attribute2 := p6_a59;
    ddp_evh_rec.attribute3 := p6_a60;
    ddp_evh_rec.attribute4 := p6_a61;
    ddp_evh_rec.attribute5 := p6_a62;
    ddp_evh_rec.attribute6 := p6_a63;
    ddp_evh_rec.attribute7 := p6_a64;
    ddp_evh_rec.attribute8 := p6_a65;
    ddp_evh_rec.attribute9 := p6_a66;
    ddp_evh_rec.attribute10 := p6_a67;
    ddp_evh_rec.attribute11 := p6_a68;
    ddp_evh_rec.attribute12 := p6_a69;
    ddp_evh_rec.attribute13 := p6_a70;
    ddp_evh_rec.attribute14 := p6_a71;
    ddp_evh_rec.attribute15 := p6_a72;
    ddp_evh_rec.event_header_name := p6_a73;
    ddp_evh_rec.event_mktg_message := p6_a74;
    ddp_evh_rec.description := p6_a75;
    ddp_evh_rec.custom_setup_id := p6_a76;
    ddp_evh_rec.country_code := p6_a77;
    ddp_evh_rec.business_unit_id := p6_a78;
    ddp_evh_rec.event_calendar := p6_a79;
    ddp_evh_rec.start_period_name := p6_a80;
    ddp_evh_rec.end_period_name := p6_a81;
    ddp_evh_rec.global_flag := p6_a82;
    ddp_evh_rec.task_id := p6_a83;
    ddp_evh_rec.program_id := p6_a84;
    ddp_evh_rec.create_attendant_lead_flag := p6_a85;
    ddp_evh_rec.create_registrant_lead_flag := p6_a86;
    ddp_evh_rec.event_purpose_code := p6_a87;

    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pub.validate_eventheader(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evh_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end ams_eventheader_pub_w;

/