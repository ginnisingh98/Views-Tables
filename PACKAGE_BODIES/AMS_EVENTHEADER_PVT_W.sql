--------------------------------------------------------
--  DDL for Package Body AMS_EVENTHEADER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTHEADER_PVT_W" as
  /* $Header: amswevhb.pls 115.14 2002/11/16 01:46:54 dbiswas ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_event_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_evh_id OUT NOCOPY  NUMBER
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







    ddp_evh_rec.event_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_evh_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_evh_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_evh_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_evh_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_evh_rec.event_level := p7_a7;
    ddp_evh_rec.application_id := rosetta_g_miss_num_map(p7_a8);
    ddp_evh_rec.event_type_code := p7_a9;
    ddp_evh_rec.active_flag := p7_a10;
    ddp_evh_rec.private_flag := p7_a11;
    ddp_evh_rec.user_status_id := rosetta_g_miss_num_map(p7_a12);
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
    ddp_evh_rec.parent_event_header_id := rosetta_g_miss_num_map(p7_a26);
    ddp_evh_rec.duration := rosetta_g_miss_num_map(p7_a27);
    ddp_evh_rec.duration_uom_code := p7_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_evh_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p7_a31);
    ddp_evh_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p7_a32);
    ddp_evh_rec.main_language_code := p7_a33;
    ddp_evh_rec.cert_credit_type_code := p7_a34;
    ddp_evh_rec.certification_credits := rosetta_g_miss_num_map(p7_a35);
    ddp_evh_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a36);
    ddp_evh_rec.organization_id := rosetta_g_miss_num_map(p7_a37);
    ddp_evh_rec.org_id := rosetta_g_miss_num_map(p7_a38);
    ddp_evh_rec.forecasted_revenue := rosetta_g_miss_num_map(p7_a39);
    ddp_evh_rec.actual_revenue := rosetta_g_miss_num_map(p7_a40);
    ddp_evh_rec.forecasted_cost := rosetta_g_miss_num_map(p7_a41);
    ddp_evh_rec.actual_cost := rosetta_g_miss_num_map(p7_a42);
    ddp_evh_rec.coordinator_id := rosetta_g_miss_num_map(p7_a43);
    ddp_evh_rec.fund_source_type_code := p7_a44;
    ddp_evh_rec.fund_source_id := rosetta_g_miss_num_map(p7_a45);
    ddp_evh_rec.fund_amount_tc := rosetta_g_miss_num_map(p7_a46);
    ddp_evh_rec.fund_amount_fc := rosetta_g_miss_num_map(p7_a47);
    ddp_evh_rec.currency_code_tc := p7_a48;
    ddp_evh_rec.currency_code_fc := p7_a49;
    ddp_evh_rec.owner_user_id := rosetta_g_miss_num_map(p7_a50);
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
    ddp_evh_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a76);
    ddp_evh_rec.country_code := p7_a77;
    ddp_evh_rec.business_unit_id := rosetta_g_miss_num_map(p7_a78);
    ddp_evh_rec.event_calendar := p7_a79;
    ddp_evh_rec.start_period_name := p7_a80;
    ddp_evh_rec.end_period_name := p7_a81;
    ddp_evh_rec.global_flag := p7_a82;
    ddp_evh_rec.task_id := rosetta_g_miss_num_map(p7_a83);
    ddp_evh_rec.program_id := rosetta_g_miss_num_map(p7_a84);
    ddp_evh_rec.create_attendant_lead_flag := p7_a85;
    ddp_evh_rec.create_registrant_lead_flag := p7_a86;
    ddp_evh_rec.event_purpose_code := p7_a87;


    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pvt.create_event_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evh_rec,
      x_evh_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_event_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
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







    ddp_evh_rec.event_header_id := rosetta_g_miss_num_map(p7_a0);
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_evh_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_evh_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_evh_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_evh_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_evh_rec.event_level := p7_a7;
    ddp_evh_rec.application_id := rosetta_g_miss_num_map(p7_a8);
    ddp_evh_rec.event_type_code := p7_a9;
    ddp_evh_rec.active_flag := p7_a10;
    ddp_evh_rec.private_flag := p7_a11;
    ddp_evh_rec.user_status_id := rosetta_g_miss_num_map(p7_a12);
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
    ddp_evh_rec.parent_event_header_id := rosetta_g_miss_num_map(p7_a26);
    ddp_evh_rec.duration := rosetta_g_miss_num_map(p7_a27);
    ddp_evh_rec.duration_uom_code := p7_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a30);
    ddp_evh_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p7_a31);
    ddp_evh_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p7_a32);
    ddp_evh_rec.main_language_code := p7_a33;
    ddp_evh_rec.cert_credit_type_code := p7_a34;
    ddp_evh_rec.certification_credits := rosetta_g_miss_num_map(p7_a35);
    ddp_evh_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a36);
    ddp_evh_rec.organization_id := rosetta_g_miss_num_map(p7_a37);
    ddp_evh_rec.org_id := rosetta_g_miss_num_map(p7_a38);
    ddp_evh_rec.forecasted_revenue := rosetta_g_miss_num_map(p7_a39);
    ddp_evh_rec.actual_revenue := rosetta_g_miss_num_map(p7_a40);
    ddp_evh_rec.forecasted_cost := rosetta_g_miss_num_map(p7_a41);
    ddp_evh_rec.actual_cost := rosetta_g_miss_num_map(p7_a42);
    ddp_evh_rec.coordinator_id := rosetta_g_miss_num_map(p7_a43);
    ddp_evh_rec.fund_source_type_code := p7_a44;
    ddp_evh_rec.fund_source_id := rosetta_g_miss_num_map(p7_a45);
    ddp_evh_rec.fund_amount_tc := rosetta_g_miss_num_map(p7_a46);
    ddp_evh_rec.fund_amount_fc := rosetta_g_miss_num_map(p7_a47);
    ddp_evh_rec.currency_code_tc := p7_a48;
    ddp_evh_rec.currency_code_fc := p7_a49;
    ddp_evh_rec.owner_user_id := rosetta_g_miss_num_map(p7_a50);
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
    ddp_evh_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a76);
    ddp_evh_rec.country_code := p7_a77;
    ddp_evh_rec.business_unit_id := rosetta_g_miss_num_map(p7_a78);
    ddp_evh_rec.event_calendar := p7_a79;
    ddp_evh_rec.start_period_name := p7_a80;
    ddp_evh_rec.end_period_name := p7_a81;
    ddp_evh_rec.global_flag := p7_a82;
    ddp_evh_rec.task_id := rosetta_g_miss_num_map(p7_a83);
    ddp_evh_rec.program_id := rosetta_g_miss_num_map(p7_a84);
    ddp_evh_rec.create_attendant_lead_flag := p7_a85;
    ddp_evh_rec.create_registrant_lead_flag := p7_a86;
    ddp_evh_rec.event_purpose_code := p7_a87;

    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pvt.update_event_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evh_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_event_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
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






    ddp_evh_rec.event_header_id := rosetta_g_miss_num_map(p6_a0);
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_evh_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_evh_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_evh_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_evh_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_evh_rec.event_level := p6_a7;
    ddp_evh_rec.application_id := rosetta_g_miss_num_map(p6_a8);
    ddp_evh_rec.event_type_code := p6_a9;
    ddp_evh_rec.active_flag := p6_a10;
    ddp_evh_rec.private_flag := p6_a11;
    ddp_evh_rec.user_status_id := rosetta_g_miss_num_map(p6_a12);
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
    ddp_evh_rec.parent_event_header_id := rosetta_g_miss_num_map(p6_a26);
    ddp_evh_rec.duration := rosetta_g_miss_num_map(p6_a27);
    ddp_evh_rec.duration_uom_code := p6_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p6_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p6_a30);
    ddp_evh_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p6_a31);
    ddp_evh_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p6_a32);
    ddp_evh_rec.main_language_code := p6_a33;
    ddp_evh_rec.cert_credit_type_code := p6_a34;
    ddp_evh_rec.certification_credits := rosetta_g_miss_num_map(p6_a35);
    ddp_evh_rec.inventory_item_id := rosetta_g_miss_num_map(p6_a36);
    ddp_evh_rec.organization_id := rosetta_g_miss_num_map(p6_a37);
    ddp_evh_rec.org_id := rosetta_g_miss_num_map(p6_a38);
    ddp_evh_rec.forecasted_revenue := rosetta_g_miss_num_map(p6_a39);
    ddp_evh_rec.actual_revenue := rosetta_g_miss_num_map(p6_a40);
    ddp_evh_rec.forecasted_cost := rosetta_g_miss_num_map(p6_a41);
    ddp_evh_rec.actual_cost := rosetta_g_miss_num_map(p6_a42);
    ddp_evh_rec.coordinator_id := rosetta_g_miss_num_map(p6_a43);
    ddp_evh_rec.fund_source_type_code := p6_a44;
    ddp_evh_rec.fund_source_id := rosetta_g_miss_num_map(p6_a45);
    ddp_evh_rec.fund_amount_tc := rosetta_g_miss_num_map(p6_a46);
    ddp_evh_rec.fund_amount_fc := rosetta_g_miss_num_map(p6_a47);
    ddp_evh_rec.currency_code_tc := p6_a48;
    ddp_evh_rec.currency_code_fc := p6_a49;
    ddp_evh_rec.owner_user_id := rosetta_g_miss_num_map(p6_a50);
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
    ddp_evh_rec.custom_setup_id := rosetta_g_miss_num_map(p6_a76);
    ddp_evh_rec.country_code := p6_a77;
    ddp_evh_rec.business_unit_id := rosetta_g_miss_num_map(p6_a78);
    ddp_evh_rec.event_calendar := p6_a79;
    ddp_evh_rec.start_period_name := p6_a80;
    ddp_evh_rec.end_period_name := p6_a81;
    ddp_evh_rec.global_flag := p6_a82;
    ddp_evh_rec.task_id := rosetta_g_miss_num_map(p6_a83);
    ddp_evh_rec.program_id := rosetta_g_miss_num_map(p6_a84);
    ddp_evh_rec.create_attendant_lead_flag := p6_a85;
    ddp_evh_rec.create_registrant_lead_flag := p6_a86;
    ddp_evh_rec.event_purpose_code := p6_a87;

    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pvt.validate_event_header(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_evh_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_evh_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  NUMBER := 0-1962.0724
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  NUMBER := 0-1962.0724
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  NUMBER := 0-1962.0724
    , p0_a84  NUMBER := 0-1962.0724
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evh_rec ams_eventheader_pvt.evh_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evh_rec.event_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evh_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evh_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evh_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evh_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evh_rec.event_level := p0_a7;
    ddp_evh_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evh_rec.event_type_code := p0_a9;
    ddp_evh_rec.active_flag := p0_a10;
    ddp_evh_rec.private_flag := p0_a11;
    ddp_evh_rec.user_status_id := rosetta_g_miss_num_map(p0_a12);
    ddp_evh_rec.system_status_code := p0_a13;
    ddp_evh_rec.last_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evh_rec.stream_type_code := p0_a15;
    ddp_evh_rec.source_code := p0_a16;
    ddp_evh_rec.event_standalone_flag := p0_a17;
    ddp_evh_rec.day_of_event := p0_a18;
    ddp_evh_rec.agenda_start_time := rosetta_g_miss_date_in_map(p0_a19);
    ddp_evh_rec.agenda_end_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_evh_rec.reg_required_flag := p0_a21;
    ddp_evh_rec.reg_charge_flag := p0_a22;
    ddp_evh_rec.reg_invited_only_flag := p0_a23;
    ddp_evh_rec.partner_flag := p0_a24;
    ddp_evh_rec.overflow_flag := p0_a25;
    ddp_evh_rec.parent_event_header_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evh_rec.duration := rosetta_g_miss_num_map(p0_a27);
    ddp_evh_rec.duration_uom_code := p0_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_evh_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p0_a31);
    ddp_evh_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p0_a32);
    ddp_evh_rec.main_language_code := p0_a33;
    ddp_evh_rec.cert_credit_type_code := p0_a34;
    ddp_evh_rec.certification_credits := rosetta_g_miss_num_map(p0_a35);
    ddp_evh_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evh_rec.organization_id := rosetta_g_miss_num_map(p0_a37);
    ddp_evh_rec.org_id := rosetta_g_miss_num_map(p0_a38);
    ddp_evh_rec.forecasted_revenue := rosetta_g_miss_num_map(p0_a39);
    ddp_evh_rec.actual_revenue := rosetta_g_miss_num_map(p0_a40);
    ddp_evh_rec.forecasted_cost := rosetta_g_miss_num_map(p0_a41);
    ddp_evh_rec.actual_cost := rosetta_g_miss_num_map(p0_a42);
    ddp_evh_rec.coordinator_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evh_rec.fund_source_type_code := p0_a44;
    ddp_evh_rec.fund_source_id := rosetta_g_miss_num_map(p0_a45);
    ddp_evh_rec.fund_amount_tc := rosetta_g_miss_num_map(p0_a46);
    ddp_evh_rec.fund_amount_fc := rosetta_g_miss_num_map(p0_a47);
    ddp_evh_rec.currency_code_tc := p0_a48;
    ddp_evh_rec.currency_code_fc := p0_a49;
    ddp_evh_rec.owner_user_id := rosetta_g_miss_num_map(p0_a50);
    ddp_evh_rec.url := p0_a51;
    ddp_evh_rec.email := p0_a52;
    ddp_evh_rec.phone := p0_a53;
    ddp_evh_rec.priority_type_code := p0_a54;
    ddp_evh_rec.cancellation_reason_code := p0_a55;
    ddp_evh_rec.inbound_script_name := p0_a56;
    ddp_evh_rec.attribute_category := p0_a57;
    ddp_evh_rec.attribute1 := p0_a58;
    ddp_evh_rec.attribute2 := p0_a59;
    ddp_evh_rec.attribute3 := p0_a60;
    ddp_evh_rec.attribute4 := p0_a61;
    ddp_evh_rec.attribute5 := p0_a62;
    ddp_evh_rec.attribute6 := p0_a63;
    ddp_evh_rec.attribute7 := p0_a64;
    ddp_evh_rec.attribute8 := p0_a65;
    ddp_evh_rec.attribute9 := p0_a66;
    ddp_evh_rec.attribute10 := p0_a67;
    ddp_evh_rec.attribute11 := p0_a68;
    ddp_evh_rec.attribute12 := p0_a69;
    ddp_evh_rec.attribute13 := p0_a70;
    ddp_evh_rec.attribute14 := p0_a71;
    ddp_evh_rec.attribute15 := p0_a72;
    ddp_evh_rec.event_header_name := p0_a73;
    ddp_evh_rec.event_mktg_message := p0_a74;
    ddp_evh_rec.description := p0_a75;
    ddp_evh_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a76);
    ddp_evh_rec.country_code := p0_a77;
    ddp_evh_rec.business_unit_id := rosetta_g_miss_num_map(p0_a78);
    ddp_evh_rec.event_calendar := p0_a79;
    ddp_evh_rec.start_period_name := p0_a80;
    ddp_evh_rec.end_period_name := p0_a81;
    ddp_evh_rec.global_flag := p0_a82;
    ddp_evh_rec.task_id := rosetta_g_miss_num_map(p0_a83);
    ddp_evh_rec.program_id := rosetta_g_miss_num_map(p0_a84);
    ddp_evh_rec.create_attendant_lead_flag := p0_a85;
    ddp_evh_rec.create_registrant_lead_flag := p0_a86;
    ddp_evh_rec.event_purpose_code := p0_a87;



    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pvt.check_evh_items(ddp_evh_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_evh_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  NUMBER := 0-1962.0724
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  NUMBER := 0-1962.0724
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  NUMBER := 0-1962.0724
    , p0_a84  NUMBER := 0-1962.0724
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  DATE := fnd_api.g_miss_date
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  DATE := fnd_api.g_miss_date
    , p1_a20  DATE := fnd_api.g_miss_date
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  NUMBER := 0-1962.0724
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  DATE := fnd_api.g_miss_date
    , p1_a30  DATE := fnd_api.g_miss_date
    , p1_a31  NUMBER := 0-1962.0724
    , p1_a32  NUMBER := 0-1962.0724
    , p1_a33  VARCHAR2 := fnd_api.g_miss_char
    , p1_a34  VARCHAR2 := fnd_api.g_miss_char
    , p1_a35  NUMBER := 0-1962.0724
    , p1_a36  NUMBER := 0-1962.0724
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  NUMBER := 0-1962.0724
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  NUMBER := 0-1962.0724
    , p1_a41  NUMBER := 0-1962.0724
    , p1_a42  NUMBER := 0-1962.0724
    , p1_a43  NUMBER := 0-1962.0724
    , p1_a44  VARCHAR2 := fnd_api.g_miss_char
    , p1_a45  NUMBER := 0-1962.0724
    , p1_a46  NUMBER := 0-1962.0724
    , p1_a47  NUMBER := 0-1962.0724
    , p1_a48  VARCHAR2 := fnd_api.g_miss_char
    , p1_a49  VARCHAR2 := fnd_api.g_miss_char
    , p1_a50  NUMBER := 0-1962.0724
    , p1_a51  VARCHAR2 := fnd_api.g_miss_char
    , p1_a52  VARCHAR2 := fnd_api.g_miss_char
    , p1_a53  VARCHAR2 := fnd_api.g_miss_char
    , p1_a54  VARCHAR2 := fnd_api.g_miss_char
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  VARCHAR2 := fnd_api.g_miss_char
    , p1_a60  VARCHAR2 := fnd_api.g_miss_char
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  VARCHAR2 := fnd_api.g_miss_char
    , p1_a65  VARCHAR2 := fnd_api.g_miss_char
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  VARCHAR2 := fnd_api.g_miss_char
    , p1_a68  VARCHAR2 := fnd_api.g_miss_char
    , p1_a69  VARCHAR2 := fnd_api.g_miss_char
    , p1_a70  VARCHAR2 := fnd_api.g_miss_char
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  VARCHAR2 := fnd_api.g_miss_char
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  VARCHAR2 := fnd_api.g_miss_char
    , p1_a75  VARCHAR2 := fnd_api.g_miss_char
    , p1_a76  NUMBER := 0-1962.0724
    , p1_a77  VARCHAR2 := fnd_api.g_miss_char
    , p1_a78  NUMBER := 0-1962.0724
    , p1_a79  VARCHAR2 := fnd_api.g_miss_char
    , p1_a80  VARCHAR2 := fnd_api.g_miss_char
    , p1_a81  VARCHAR2 := fnd_api.g_miss_char
    , p1_a82  VARCHAR2 := fnd_api.g_miss_char
    , p1_a83  NUMBER := 0-1962.0724
    , p1_a84  NUMBER := 0-1962.0724
    , p1_a85  VARCHAR2 := fnd_api.g_miss_char
    , p1_a86  VARCHAR2 := fnd_api.g_miss_char
    , p1_a87  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evh_rec ams_eventheader_pvt.evh_rec_type;
    ddp_complete_rec ams_eventheader_pvt.evh_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evh_rec.event_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evh_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evh_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evh_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evh_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evh_rec.event_level := p0_a7;
    ddp_evh_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evh_rec.event_type_code := p0_a9;
    ddp_evh_rec.active_flag := p0_a10;
    ddp_evh_rec.private_flag := p0_a11;
    ddp_evh_rec.user_status_id := rosetta_g_miss_num_map(p0_a12);
    ddp_evh_rec.system_status_code := p0_a13;
    ddp_evh_rec.last_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evh_rec.stream_type_code := p0_a15;
    ddp_evh_rec.source_code := p0_a16;
    ddp_evh_rec.event_standalone_flag := p0_a17;
    ddp_evh_rec.day_of_event := p0_a18;
    ddp_evh_rec.agenda_start_time := rosetta_g_miss_date_in_map(p0_a19);
    ddp_evh_rec.agenda_end_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_evh_rec.reg_required_flag := p0_a21;
    ddp_evh_rec.reg_charge_flag := p0_a22;
    ddp_evh_rec.reg_invited_only_flag := p0_a23;
    ddp_evh_rec.partner_flag := p0_a24;
    ddp_evh_rec.overflow_flag := p0_a25;
    ddp_evh_rec.parent_event_header_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evh_rec.duration := rosetta_g_miss_num_map(p0_a27);
    ddp_evh_rec.duration_uom_code := p0_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_evh_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p0_a31);
    ddp_evh_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p0_a32);
    ddp_evh_rec.main_language_code := p0_a33;
    ddp_evh_rec.cert_credit_type_code := p0_a34;
    ddp_evh_rec.certification_credits := rosetta_g_miss_num_map(p0_a35);
    ddp_evh_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evh_rec.organization_id := rosetta_g_miss_num_map(p0_a37);
    ddp_evh_rec.org_id := rosetta_g_miss_num_map(p0_a38);
    ddp_evh_rec.forecasted_revenue := rosetta_g_miss_num_map(p0_a39);
    ddp_evh_rec.actual_revenue := rosetta_g_miss_num_map(p0_a40);
    ddp_evh_rec.forecasted_cost := rosetta_g_miss_num_map(p0_a41);
    ddp_evh_rec.actual_cost := rosetta_g_miss_num_map(p0_a42);
    ddp_evh_rec.coordinator_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evh_rec.fund_source_type_code := p0_a44;
    ddp_evh_rec.fund_source_id := rosetta_g_miss_num_map(p0_a45);
    ddp_evh_rec.fund_amount_tc := rosetta_g_miss_num_map(p0_a46);
    ddp_evh_rec.fund_amount_fc := rosetta_g_miss_num_map(p0_a47);
    ddp_evh_rec.currency_code_tc := p0_a48;
    ddp_evh_rec.currency_code_fc := p0_a49;
    ddp_evh_rec.owner_user_id := rosetta_g_miss_num_map(p0_a50);
    ddp_evh_rec.url := p0_a51;
    ddp_evh_rec.email := p0_a52;
    ddp_evh_rec.phone := p0_a53;
    ddp_evh_rec.priority_type_code := p0_a54;
    ddp_evh_rec.cancellation_reason_code := p0_a55;
    ddp_evh_rec.inbound_script_name := p0_a56;
    ddp_evh_rec.attribute_category := p0_a57;
    ddp_evh_rec.attribute1 := p0_a58;
    ddp_evh_rec.attribute2 := p0_a59;
    ddp_evh_rec.attribute3 := p0_a60;
    ddp_evh_rec.attribute4 := p0_a61;
    ddp_evh_rec.attribute5 := p0_a62;
    ddp_evh_rec.attribute6 := p0_a63;
    ddp_evh_rec.attribute7 := p0_a64;
    ddp_evh_rec.attribute8 := p0_a65;
    ddp_evh_rec.attribute9 := p0_a66;
    ddp_evh_rec.attribute10 := p0_a67;
    ddp_evh_rec.attribute11 := p0_a68;
    ddp_evh_rec.attribute12 := p0_a69;
    ddp_evh_rec.attribute13 := p0_a70;
    ddp_evh_rec.attribute14 := p0_a71;
    ddp_evh_rec.attribute15 := p0_a72;
    ddp_evh_rec.event_header_name := p0_a73;
    ddp_evh_rec.event_mktg_message := p0_a74;
    ddp_evh_rec.description := p0_a75;
    ddp_evh_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a76);
    ddp_evh_rec.country_code := p0_a77;
    ddp_evh_rec.business_unit_id := rosetta_g_miss_num_map(p0_a78);
    ddp_evh_rec.event_calendar := p0_a79;
    ddp_evh_rec.start_period_name := p0_a80;
    ddp_evh_rec.end_period_name := p0_a81;
    ddp_evh_rec.global_flag := p0_a82;
    ddp_evh_rec.task_id := rosetta_g_miss_num_map(p0_a83);
    ddp_evh_rec.program_id := rosetta_g_miss_num_map(p0_a84);
    ddp_evh_rec.create_attendant_lead_flag := p0_a85;
    ddp_evh_rec.create_registrant_lead_flag := p0_a86;
    ddp_evh_rec.event_purpose_code := p0_a87;

    ddp_complete_rec.event_header_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.event_level := p1_a7;
    ddp_complete_rec.application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.event_type_code := p1_a9;
    ddp_complete_rec.active_flag := p1_a10;
    ddp_complete_rec.private_flag := p1_a11;
    ddp_complete_rec.user_status_id := rosetta_g_miss_num_map(p1_a12);
    ddp_complete_rec.system_status_code := p1_a13;
    ddp_complete_rec.last_status_date := rosetta_g_miss_date_in_map(p1_a14);
    ddp_complete_rec.stream_type_code := p1_a15;
    ddp_complete_rec.source_code := p1_a16;
    ddp_complete_rec.event_standalone_flag := p1_a17;
    ddp_complete_rec.day_of_event := p1_a18;
    ddp_complete_rec.agenda_start_time := rosetta_g_miss_date_in_map(p1_a19);
    ddp_complete_rec.agenda_end_time := rosetta_g_miss_date_in_map(p1_a20);
    ddp_complete_rec.reg_required_flag := p1_a21;
    ddp_complete_rec.reg_charge_flag := p1_a22;
    ddp_complete_rec.reg_invited_only_flag := p1_a23;
    ddp_complete_rec.partner_flag := p1_a24;
    ddp_complete_rec.overflow_flag := p1_a25;
    ddp_complete_rec.parent_event_header_id := rosetta_g_miss_num_map(p1_a26);
    ddp_complete_rec.duration := rosetta_g_miss_num_map(p1_a27);
    ddp_complete_rec.duration_uom_code := p1_a28;
    ddp_complete_rec.active_from_date := rosetta_g_miss_date_in_map(p1_a29);
    ddp_complete_rec.active_to_date := rosetta_g_miss_date_in_map(p1_a30);
    ddp_complete_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p1_a31);
    ddp_complete_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p1_a32);
    ddp_complete_rec.main_language_code := p1_a33;
    ddp_complete_rec.cert_credit_type_code := p1_a34;
    ddp_complete_rec.certification_credits := rosetta_g_miss_num_map(p1_a35);
    ddp_complete_rec.inventory_item_id := rosetta_g_miss_num_map(p1_a36);
    ddp_complete_rec.organization_id := rosetta_g_miss_num_map(p1_a37);
    ddp_complete_rec.org_id := rosetta_g_miss_num_map(p1_a38);
    ddp_complete_rec.forecasted_revenue := rosetta_g_miss_num_map(p1_a39);
    ddp_complete_rec.actual_revenue := rosetta_g_miss_num_map(p1_a40);
    ddp_complete_rec.forecasted_cost := rosetta_g_miss_num_map(p1_a41);
    ddp_complete_rec.actual_cost := rosetta_g_miss_num_map(p1_a42);
    ddp_complete_rec.coordinator_id := rosetta_g_miss_num_map(p1_a43);
    ddp_complete_rec.fund_source_type_code := p1_a44;
    ddp_complete_rec.fund_source_id := rosetta_g_miss_num_map(p1_a45);
    ddp_complete_rec.fund_amount_tc := rosetta_g_miss_num_map(p1_a46);
    ddp_complete_rec.fund_amount_fc := rosetta_g_miss_num_map(p1_a47);
    ddp_complete_rec.currency_code_tc := p1_a48;
    ddp_complete_rec.currency_code_fc := p1_a49;
    ddp_complete_rec.owner_user_id := rosetta_g_miss_num_map(p1_a50);
    ddp_complete_rec.url := p1_a51;
    ddp_complete_rec.email := p1_a52;
    ddp_complete_rec.phone := p1_a53;
    ddp_complete_rec.priority_type_code := p1_a54;
    ddp_complete_rec.cancellation_reason_code := p1_a55;
    ddp_complete_rec.inbound_script_name := p1_a56;
    ddp_complete_rec.attribute_category := p1_a57;
    ddp_complete_rec.attribute1 := p1_a58;
    ddp_complete_rec.attribute2 := p1_a59;
    ddp_complete_rec.attribute3 := p1_a60;
    ddp_complete_rec.attribute4 := p1_a61;
    ddp_complete_rec.attribute5 := p1_a62;
    ddp_complete_rec.attribute6 := p1_a63;
    ddp_complete_rec.attribute7 := p1_a64;
    ddp_complete_rec.attribute8 := p1_a65;
    ddp_complete_rec.attribute9 := p1_a66;
    ddp_complete_rec.attribute10 := p1_a67;
    ddp_complete_rec.attribute11 := p1_a68;
    ddp_complete_rec.attribute12 := p1_a69;
    ddp_complete_rec.attribute13 := p1_a70;
    ddp_complete_rec.attribute14 := p1_a71;
    ddp_complete_rec.attribute15 := p1_a72;
    ddp_complete_rec.event_header_name := p1_a73;
    ddp_complete_rec.event_mktg_message := p1_a74;
    ddp_complete_rec.description := p1_a75;
    ddp_complete_rec.custom_setup_id := rosetta_g_miss_num_map(p1_a76);
    ddp_complete_rec.country_code := p1_a77;
    ddp_complete_rec.business_unit_id := rosetta_g_miss_num_map(p1_a78);
    ddp_complete_rec.event_calendar := p1_a79;
    ddp_complete_rec.start_period_name := p1_a80;
    ddp_complete_rec.end_period_name := p1_a81;
    ddp_complete_rec.global_flag := p1_a82;
    ddp_complete_rec.task_id := rosetta_g_miss_num_map(p1_a83);
    ddp_complete_rec.program_id := rosetta_g_miss_num_map(p1_a84);
    ddp_complete_rec.create_attendant_lead_flag := p1_a85;
    ddp_complete_rec.create_registrant_lead_flag := p1_a86;
    ddp_complete_rec.event_purpose_code := p1_a87;


    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pvt.check_evh_record(ddp_evh_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure init_evh_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  VARCHAR2
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  NUMBER
    , p0_a13 OUT NOCOPY  VARCHAR2
    , p0_a14 OUT NOCOPY  DATE
    , p0_a15 OUT NOCOPY  VARCHAR2
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  VARCHAR2
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  DATE
    , p0_a20 OUT NOCOPY  DATE
    , p0_a21 OUT NOCOPY  VARCHAR2
    , p0_a22 OUT NOCOPY  VARCHAR2
    , p0_a23 OUT NOCOPY  VARCHAR2
    , p0_a24 OUT NOCOPY  VARCHAR2
    , p0_a25 OUT NOCOPY  VARCHAR2
    , p0_a26 OUT NOCOPY  NUMBER
    , p0_a27 OUT NOCOPY  NUMBER
    , p0_a28 OUT NOCOPY  VARCHAR2
    , p0_a29 OUT NOCOPY  DATE
    , p0_a30 OUT NOCOPY  DATE
    , p0_a31 OUT NOCOPY  NUMBER
    , p0_a32 OUT NOCOPY  NUMBER
    , p0_a33 OUT NOCOPY  VARCHAR2
    , p0_a34 OUT NOCOPY  VARCHAR2
    , p0_a35 OUT NOCOPY  NUMBER
    , p0_a36 OUT NOCOPY  NUMBER
    , p0_a37 OUT NOCOPY  NUMBER
    , p0_a38 OUT NOCOPY  NUMBER
    , p0_a39 OUT NOCOPY  NUMBER
    , p0_a40 OUT NOCOPY  NUMBER
    , p0_a41 OUT NOCOPY  NUMBER
    , p0_a42 OUT NOCOPY  NUMBER
    , p0_a43 OUT NOCOPY  NUMBER
    , p0_a44 OUT NOCOPY  VARCHAR2
    , p0_a45 OUT NOCOPY  NUMBER
    , p0_a46 OUT NOCOPY  NUMBER
    , p0_a47 OUT NOCOPY  NUMBER
    , p0_a48 OUT NOCOPY  VARCHAR2
    , p0_a49 OUT NOCOPY  VARCHAR2
    , p0_a50 OUT NOCOPY  NUMBER
    , p0_a51 OUT NOCOPY  VARCHAR2
    , p0_a52 OUT NOCOPY  VARCHAR2
    , p0_a53 OUT NOCOPY  VARCHAR2
    , p0_a54 OUT NOCOPY  VARCHAR2
    , p0_a55 OUT NOCOPY  VARCHAR2
    , p0_a56 OUT NOCOPY  VARCHAR2
    , p0_a57 OUT NOCOPY  VARCHAR2
    , p0_a58 OUT NOCOPY  VARCHAR2
    , p0_a59 OUT NOCOPY  VARCHAR2
    , p0_a60 OUT NOCOPY  VARCHAR2
    , p0_a61 OUT NOCOPY  VARCHAR2
    , p0_a62 OUT NOCOPY  VARCHAR2
    , p0_a63 OUT NOCOPY  VARCHAR2
    , p0_a64 OUT NOCOPY  VARCHAR2
    , p0_a65 OUT NOCOPY  VARCHAR2
    , p0_a66 OUT NOCOPY  VARCHAR2
    , p0_a67 OUT NOCOPY  VARCHAR2
    , p0_a68 OUT NOCOPY  VARCHAR2
    , p0_a69 OUT NOCOPY  VARCHAR2
    , p0_a70 OUT NOCOPY  VARCHAR2
    , p0_a71 OUT NOCOPY  VARCHAR2
    , p0_a72 OUT NOCOPY  VARCHAR2
    , p0_a73 OUT NOCOPY  VARCHAR2
    , p0_a74 OUT NOCOPY  VARCHAR2
    , p0_a75 OUT NOCOPY  VARCHAR2
    , p0_a76 OUT NOCOPY  NUMBER
    , p0_a77 OUT NOCOPY  VARCHAR2
    , p0_a78 OUT NOCOPY  NUMBER
    , p0_a79 OUT NOCOPY  VARCHAR2
    , p0_a80 OUT NOCOPY  VARCHAR2
    , p0_a81 OUT NOCOPY  VARCHAR2
    , p0_a82 OUT NOCOPY  VARCHAR2
    , p0_a83 OUT NOCOPY  NUMBER
    , p0_a84 OUT NOCOPY  NUMBER
    , p0_a85 OUT NOCOPY  VARCHAR2
    , p0_a86 OUT NOCOPY  VARCHAR2
    , p0_a87 OUT NOCOPY  VARCHAR2
  )
  as
    ddx_evh_rec ams_eventheader_pvt.evh_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pvt.init_evh_rec(ddx_evh_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_evh_rec.event_header_id);
    p0_a1 := ddx_evh_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_evh_rec.last_updated_by);
    p0_a3 := ddx_evh_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_evh_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_evh_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_evh_rec.object_version_number);
    p0_a7 := ddx_evh_rec.event_level;
    p0_a8 := rosetta_g_miss_num_map(ddx_evh_rec.application_id);
    p0_a9 := ddx_evh_rec.event_type_code;
    p0_a10 := ddx_evh_rec.active_flag;
    p0_a11 := ddx_evh_rec.private_flag;
    p0_a12 := rosetta_g_miss_num_map(ddx_evh_rec.user_status_id);
    p0_a13 := ddx_evh_rec.system_status_code;
    p0_a14 := ddx_evh_rec.last_status_date;
    p0_a15 := ddx_evh_rec.stream_type_code;
    p0_a16 := ddx_evh_rec.source_code;
    p0_a17 := ddx_evh_rec.event_standalone_flag;
    p0_a18 := ddx_evh_rec.day_of_event;
    p0_a19 := ddx_evh_rec.agenda_start_time;
    p0_a20 := ddx_evh_rec.agenda_end_time;
    p0_a21 := ddx_evh_rec.reg_required_flag;
    p0_a22 := ddx_evh_rec.reg_charge_flag;
    p0_a23 := ddx_evh_rec.reg_invited_only_flag;
    p0_a24 := ddx_evh_rec.partner_flag;
    p0_a25 := ddx_evh_rec.overflow_flag;
    p0_a26 := rosetta_g_miss_num_map(ddx_evh_rec.parent_event_header_id);
    p0_a27 := rosetta_g_miss_num_map(ddx_evh_rec.duration);
    p0_a28 := ddx_evh_rec.duration_uom_code;
    p0_a29 := ddx_evh_rec.active_from_date;
    p0_a30 := ddx_evh_rec.active_to_date;
    p0_a31 := rosetta_g_miss_num_map(ddx_evh_rec.reg_maximum_capacity);
    p0_a32 := rosetta_g_miss_num_map(ddx_evh_rec.reg_minimum_capacity);
    p0_a33 := ddx_evh_rec.main_language_code;
    p0_a34 := ddx_evh_rec.cert_credit_type_code;
    p0_a35 := rosetta_g_miss_num_map(ddx_evh_rec.certification_credits);
    p0_a36 := rosetta_g_miss_num_map(ddx_evh_rec.inventory_item_id);
    p0_a37 := rosetta_g_miss_num_map(ddx_evh_rec.organization_id);
    p0_a38 := rosetta_g_miss_num_map(ddx_evh_rec.org_id);
    p0_a39 := rosetta_g_miss_num_map(ddx_evh_rec.forecasted_revenue);
    p0_a40 := rosetta_g_miss_num_map(ddx_evh_rec.actual_revenue);
    p0_a41 := rosetta_g_miss_num_map(ddx_evh_rec.forecasted_cost);
    p0_a42 := rosetta_g_miss_num_map(ddx_evh_rec.actual_cost);
    p0_a43 := rosetta_g_miss_num_map(ddx_evh_rec.coordinator_id);
    p0_a44 := ddx_evh_rec.fund_source_type_code;
    p0_a45 := rosetta_g_miss_num_map(ddx_evh_rec.fund_source_id);
    p0_a46 := rosetta_g_miss_num_map(ddx_evh_rec.fund_amount_tc);
    p0_a47 := rosetta_g_miss_num_map(ddx_evh_rec.fund_amount_fc);
    p0_a48 := ddx_evh_rec.currency_code_tc;
    p0_a49 := ddx_evh_rec.currency_code_fc;
    p0_a50 := rosetta_g_miss_num_map(ddx_evh_rec.owner_user_id);
    p0_a51 := ddx_evh_rec.url;
    p0_a52 := ddx_evh_rec.email;
    p0_a53 := ddx_evh_rec.phone;
    p0_a54 := ddx_evh_rec.priority_type_code;
    p0_a55 := ddx_evh_rec.cancellation_reason_code;
    p0_a56 := ddx_evh_rec.inbound_script_name;
    p0_a57 := ddx_evh_rec.attribute_category;
    p0_a58 := ddx_evh_rec.attribute1;
    p0_a59 := ddx_evh_rec.attribute2;
    p0_a60 := ddx_evh_rec.attribute3;
    p0_a61 := ddx_evh_rec.attribute4;
    p0_a62 := ddx_evh_rec.attribute5;
    p0_a63 := ddx_evh_rec.attribute6;
    p0_a64 := ddx_evh_rec.attribute7;
    p0_a65 := ddx_evh_rec.attribute8;
    p0_a66 := ddx_evh_rec.attribute9;
    p0_a67 := ddx_evh_rec.attribute10;
    p0_a68 := ddx_evh_rec.attribute11;
    p0_a69 := ddx_evh_rec.attribute12;
    p0_a70 := ddx_evh_rec.attribute13;
    p0_a71 := ddx_evh_rec.attribute14;
    p0_a72 := ddx_evh_rec.attribute15;
    p0_a73 := ddx_evh_rec.event_header_name;
    p0_a74 := ddx_evh_rec.event_mktg_message;
    p0_a75 := ddx_evh_rec.description;
    p0_a76 := rosetta_g_miss_num_map(ddx_evh_rec.custom_setup_id);
    p0_a77 := ddx_evh_rec.country_code;
    p0_a78 := rosetta_g_miss_num_map(ddx_evh_rec.business_unit_id);
    p0_a79 := ddx_evh_rec.event_calendar;
    p0_a80 := ddx_evh_rec.start_period_name;
    p0_a81 := ddx_evh_rec.end_period_name;
    p0_a82 := ddx_evh_rec.global_flag;
    p0_a83 := rosetta_g_miss_num_map(ddx_evh_rec.task_id);
    p0_a84 := rosetta_g_miss_num_map(ddx_evh_rec.program_id);
    p0_a85 := ddx_evh_rec.create_attendant_lead_flag;
    p0_a86 := ddx_evh_rec.create_registrant_lead_flag;
    p0_a87 := ddx_evh_rec.event_purpose_code;
  end;

  procedure complete_evh_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  VARCHAR2
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  NUMBER
    , p1_a13 OUT NOCOPY  VARCHAR2
    , p1_a14 OUT NOCOPY  DATE
    , p1_a15 OUT NOCOPY  VARCHAR2
    , p1_a16 OUT NOCOPY  VARCHAR2
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  VARCHAR2
    , p1_a19 OUT NOCOPY  DATE
    , p1_a20 OUT NOCOPY  DATE
    , p1_a21 OUT NOCOPY  VARCHAR2
    , p1_a22 OUT NOCOPY  VARCHAR2
    , p1_a23 OUT NOCOPY  VARCHAR2
    , p1_a24 OUT NOCOPY  VARCHAR2
    , p1_a25 OUT NOCOPY  VARCHAR2
    , p1_a26 OUT NOCOPY  NUMBER
    , p1_a27 OUT NOCOPY  NUMBER
    , p1_a28 OUT NOCOPY  VARCHAR2
    , p1_a29 OUT NOCOPY  DATE
    , p1_a30 OUT NOCOPY  DATE
    , p1_a31 OUT NOCOPY  NUMBER
    , p1_a32 OUT NOCOPY  NUMBER
    , p1_a33 OUT NOCOPY  VARCHAR2
    , p1_a34 OUT NOCOPY  VARCHAR2
    , p1_a35 OUT NOCOPY  NUMBER
    , p1_a36 OUT NOCOPY  NUMBER
    , p1_a37 OUT NOCOPY  NUMBER
    , p1_a38 OUT NOCOPY  NUMBER
    , p1_a39 OUT NOCOPY  NUMBER
    , p1_a40 OUT NOCOPY  NUMBER
    , p1_a41 OUT NOCOPY  NUMBER
    , p1_a42 OUT NOCOPY  NUMBER
    , p1_a43 OUT NOCOPY  NUMBER
    , p1_a44 OUT NOCOPY  VARCHAR2
    , p1_a45 OUT NOCOPY  NUMBER
    , p1_a46 OUT NOCOPY  NUMBER
    , p1_a47 OUT NOCOPY  NUMBER
    , p1_a48 OUT NOCOPY  VARCHAR2
    , p1_a49 OUT NOCOPY  VARCHAR2
    , p1_a50 OUT NOCOPY  NUMBER
    , p1_a51 OUT NOCOPY  VARCHAR2
    , p1_a52 OUT NOCOPY  VARCHAR2
    , p1_a53 OUT NOCOPY  VARCHAR2
    , p1_a54 OUT NOCOPY  VARCHAR2
    , p1_a55 OUT NOCOPY  VARCHAR2
    , p1_a56 OUT NOCOPY  VARCHAR2
    , p1_a57 OUT NOCOPY  VARCHAR2
    , p1_a58 OUT NOCOPY  VARCHAR2
    , p1_a59 OUT NOCOPY  VARCHAR2
    , p1_a60 OUT NOCOPY  VARCHAR2
    , p1_a61 OUT NOCOPY  VARCHAR2
    , p1_a62 OUT NOCOPY  VARCHAR2
    , p1_a63 OUT NOCOPY  VARCHAR2
    , p1_a64 OUT NOCOPY  VARCHAR2
    , p1_a65 OUT NOCOPY  VARCHAR2
    , p1_a66 OUT NOCOPY  VARCHAR2
    , p1_a67 OUT NOCOPY  VARCHAR2
    , p1_a68 OUT NOCOPY  VARCHAR2
    , p1_a69 OUT NOCOPY  VARCHAR2
    , p1_a70 OUT NOCOPY  VARCHAR2
    , p1_a71 OUT NOCOPY  VARCHAR2
    , p1_a72 OUT NOCOPY  VARCHAR2
    , p1_a73 OUT NOCOPY  VARCHAR2
    , p1_a74 OUT NOCOPY  VARCHAR2
    , p1_a75 OUT NOCOPY  VARCHAR2
    , p1_a76 OUT NOCOPY  NUMBER
    , p1_a77 OUT NOCOPY  VARCHAR2
    , p1_a78 OUT NOCOPY  NUMBER
    , p1_a79 OUT NOCOPY  VARCHAR2
    , p1_a80 OUT NOCOPY  VARCHAR2
    , p1_a81 OUT NOCOPY  VARCHAR2
    , p1_a82 OUT NOCOPY  VARCHAR2
    , p1_a83 OUT NOCOPY  NUMBER
    , p1_a84 OUT NOCOPY  NUMBER
    , p1_a85 OUT NOCOPY  VARCHAR2
    , p1_a86 OUT NOCOPY  VARCHAR2
    , p1_a87 OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  NUMBER := 0-1962.0724
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  NUMBER := 0-1962.0724
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  NUMBER := 0-1962.0724
    , p0_a84  NUMBER := 0-1962.0724
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evh_rec ams_eventheader_pvt.evh_rec_type;
    ddx_complete_rec ams_eventheader_pvt.evh_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evh_rec.event_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evh_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evh_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evh_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evh_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evh_rec.event_level := p0_a7;
    ddp_evh_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evh_rec.event_type_code := p0_a9;
    ddp_evh_rec.active_flag := p0_a10;
    ddp_evh_rec.private_flag := p0_a11;
    ddp_evh_rec.user_status_id := rosetta_g_miss_num_map(p0_a12);
    ddp_evh_rec.system_status_code := p0_a13;
    ddp_evh_rec.last_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evh_rec.stream_type_code := p0_a15;
    ddp_evh_rec.source_code := p0_a16;
    ddp_evh_rec.event_standalone_flag := p0_a17;
    ddp_evh_rec.day_of_event := p0_a18;
    ddp_evh_rec.agenda_start_time := rosetta_g_miss_date_in_map(p0_a19);
    ddp_evh_rec.agenda_end_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_evh_rec.reg_required_flag := p0_a21;
    ddp_evh_rec.reg_charge_flag := p0_a22;
    ddp_evh_rec.reg_invited_only_flag := p0_a23;
    ddp_evh_rec.partner_flag := p0_a24;
    ddp_evh_rec.overflow_flag := p0_a25;
    ddp_evh_rec.parent_event_header_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evh_rec.duration := rosetta_g_miss_num_map(p0_a27);
    ddp_evh_rec.duration_uom_code := p0_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_evh_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p0_a31);
    ddp_evh_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p0_a32);
    ddp_evh_rec.main_language_code := p0_a33;
    ddp_evh_rec.cert_credit_type_code := p0_a34;
    ddp_evh_rec.certification_credits := rosetta_g_miss_num_map(p0_a35);
    ddp_evh_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evh_rec.organization_id := rosetta_g_miss_num_map(p0_a37);
    ddp_evh_rec.org_id := rosetta_g_miss_num_map(p0_a38);
    ddp_evh_rec.forecasted_revenue := rosetta_g_miss_num_map(p0_a39);
    ddp_evh_rec.actual_revenue := rosetta_g_miss_num_map(p0_a40);
    ddp_evh_rec.forecasted_cost := rosetta_g_miss_num_map(p0_a41);
    ddp_evh_rec.actual_cost := rosetta_g_miss_num_map(p0_a42);
    ddp_evh_rec.coordinator_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evh_rec.fund_source_type_code := p0_a44;
    ddp_evh_rec.fund_source_id := rosetta_g_miss_num_map(p0_a45);
    ddp_evh_rec.fund_amount_tc := rosetta_g_miss_num_map(p0_a46);
    ddp_evh_rec.fund_amount_fc := rosetta_g_miss_num_map(p0_a47);
    ddp_evh_rec.currency_code_tc := p0_a48;
    ddp_evh_rec.currency_code_fc := p0_a49;
    ddp_evh_rec.owner_user_id := rosetta_g_miss_num_map(p0_a50);
    ddp_evh_rec.url := p0_a51;
    ddp_evh_rec.email := p0_a52;
    ddp_evh_rec.phone := p0_a53;
    ddp_evh_rec.priority_type_code := p0_a54;
    ddp_evh_rec.cancellation_reason_code := p0_a55;
    ddp_evh_rec.inbound_script_name := p0_a56;
    ddp_evh_rec.attribute_category := p0_a57;
    ddp_evh_rec.attribute1 := p0_a58;
    ddp_evh_rec.attribute2 := p0_a59;
    ddp_evh_rec.attribute3 := p0_a60;
    ddp_evh_rec.attribute4 := p0_a61;
    ddp_evh_rec.attribute5 := p0_a62;
    ddp_evh_rec.attribute6 := p0_a63;
    ddp_evh_rec.attribute7 := p0_a64;
    ddp_evh_rec.attribute8 := p0_a65;
    ddp_evh_rec.attribute9 := p0_a66;
    ddp_evh_rec.attribute10 := p0_a67;
    ddp_evh_rec.attribute11 := p0_a68;
    ddp_evh_rec.attribute12 := p0_a69;
    ddp_evh_rec.attribute13 := p0_a70;
    ddp_evh_rec.attribute14 := p0_a71;
    ddp_evh_rec.attribute15 := p0_a72;
    ddp_evh_rec.event_header_name := p0_a73;
    ddp_evh_rec.event_mktg_message := p0_a74;
    ddp_evh_rec.description := p0_a75;
    ddp_evh_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a76);
    ddp_evh_rec.country_code := p0_a77;
    ddp_evh_rec.business_unit_id := rosetta_g_miss_num_map(p0_a78);
    ddp_evh_rec.event_calendar := p0_a79;
    ddp_evh_rec.start_period_name := p0_a80;
    ddp_evh_rec.end_period_name := p0_a81;
    ddp_evh_rec.global_flag := p0_a82;
    ddp_evh_rec.task_id := rosetta_g_miss_num_map(p0_a83);
    ddp_evh_rec.program_id := rosetta_g_miss_num_map(p0_a84);
    ddp_evh_rec.create_attendant_lead_flag := p0_a85;
    ddp_evh_rec.create_registrant_lead_flag := p0_a86;
    ddp_evh_rec.event_purpose_code := p0_a87;


    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pvt.complete_evh_rec(ddp_evh_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.event_header_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.event_level;
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.application_id);
    p1_a9 := ddx_complete_rec.event_type_code;
    p1_a10 := ddx_complete_rec.active_flag;
    p1_a11 := ddx_complete_rec.private_flag;
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.user_status_id);
    p1_a13 := ddx_complete_rec.system_status_code;
    p1_a14 := ddx_complete_rec.last_status_date;
    p1_a15 := ddx_complete_rec.stream_type_code;
    p1_a16 := ddx_complete_rec.source_code;
    p1_a17 := ddx_complete_rec.event_standalone_flag;
    p1_a18 := ddx_complete_rec.day_of_event;
    p1_a19 := ddx_complete_rec.agenda_start_time;
    p1_a20 := ddx_complete_rec.agenda_end_time;
    p1_a21 := ddx_complete_rec.reg_required_flag;
    p1_a22 := ddx_complete_rec.reg_charge_flag;
    p1_a23 := ddx_complete_rec.reg_invited_only_flag;
    p1_a24 := ddx_complete_rec.partner_flag;
    p1_a25 := ddx_complete_rec.overflow_flag;
    p1_a26 := rosetta_g_miss_num_map(ddx_complete_rec.parent_event_header_id);
    p1_a27 := rosetta_g_miss_num_map(ddx_complete_rec.duration);
    p1_a28 := ddx_complete_rec.duration_uom_code;
    p1_a29 := ddx_complete_rec.active_from_date;
    p1_a30 := ddx_complete_rec.active_to_date;
    p1_a31 := rosetta_g_miss_num_map(ddx_complete_rec.reg_maximum_capacity);
    p1_a32 := rosetta_g_miss_num_map(ddx_complete_rec.reg_minimum_capacity);
    p1_a33 := ddx_complete_rec.main_language_code;
    p1_a34 := ddx_complete_rec.cert_credit_type_code;
    p1_a35 := rosetta_g_miss_num_map(ddx_complete_rec.certification_credits);
    p1_a36 := rosetta_g_miss_num_map(ddx_complete_rec.inventory_item_id);
    p1_a37 := rosetta_g_miss_num_map(ddx_complete_rec.organization_id);
    p1_a38 := rosetta_g_miss_num_map(ddx_complete_rec.org_id);
    p1_a39 := rosetta_g_miss_num_map(ddx_complete_rec.forecasted_revenue);
    p1_a40 := rosetta_g_miss_num_map(ddx_complete_rec.actual_revenue);
    p1_a41 := rosetta_g_miss_num_map(ddx_complete_rec.forecasted_cost);
    p1_a42 := rosetta_g_miss_num_map(ddx_complete_rec.actual_cost);
    p1_a43 := rosetta_g_miss_num_map(ddx_complete_rec.coordinator_id);
    p1_a44 := ddx_complete_rec.fund_source_type_code;
    p1_a45 := rosetta_g_miss_num_map(ddx_complete_rec.fund_source_id);
    p1_a46 := rosetta_g_miss_num_map(ddx_complete_rec.fund_amount_tc);
    p1_a47 := rosetta_g_miss_num_map(ddx_complete_rec.fund_amount_fc);
    p1_a48 := ddx_complete_rec.currency_code_tc;
    p1_a49 := ddx_complete_rec.currency_code_fc;
    p1_a50 := rosetta_g_miss_num_map(ddx_complete_rec.owner_user_id);
    p1_a51 := ddx_complete_rec.url;
    p1_a52 := ddx_complete_rec.email;
    p1_a53 := ddx_complete_rec.phone;
    p1_a54 := ddx_complete_rec.priority_type_code;
    p1_a55 := ddx_complete_rec.cancellation_reason_code;
    p1_a56 := ddx_complete_rec.inbound_script_name;
    p1_a57 := ddx_complete_rec.attribute_category;
    p1_a58 := ddx_complete_rec.attribute1;
    p1_a59 := ddx_complete_rec.attribute2;
    p1_a60 := ddx_complete_rec.attribute3;
    p1_a61 := ddx_complete_rec.attribute4;
    p1_a62 := ddx_complete_rec.attribute5;
    p1_a63 := ddx_complete_rec.attribute6;
    p1_a64 := ddx_complete_rec.attribute7;
    p1_a65 := ddx_complete_rec.attribute8;
    p1_a66 := ddx_complete_rec.attribute9;
    p1_a67 := ddx_complete_rec.attribute10;
    p1_a68 := ddx_complete_rec.attribute11;
    p1_a69 := ddx_complete_rec.attribute12;
    p1_a70 := ddx_complete_rec.attribute13;
    p1_a71 := ddx_complete_rec.attribute14;
    p1_a72 := ddx_complete_rec.attribute15;
    p1_a73 := ddx_complete_rec.event_header_name;
    p1_a74 := ddx_complete_rec.event_mktg_message;
    p1_a75 := ddx_complete_rec.description;
    p1_a76 := rosetta_g_miss_num_map(ddx_complete_rec.custom_setup_id);
    p1_a77 := ddx_complete_rec.country_code;
    p1_a78 := rosetta_g_miss_num_map(ddx_complete_rec.business_unit_id);
    p1_a79 := ddx_complete_rec.event_calendar;
    p1_a80 := ddx_complete_rec.start_period_name;
    p1_a81 := ddx_complete_rec.end_period_name;
    p1_a82 := ddx_complete_rec.global_flag;
    p1_a83 := rosetta_g_miss_num_map(ddx_complete_rec.task_id);
    p1_a84 := rosetta_g_miss_num_map(ddx_complete_rec.program_id);
    p1_a85 := ddx_complete_rec.create_attendant_lead_flag;
    p1_a86 := ddx_complete_rec.create_registrant_lead_flag;
    p1_a87 := ddx_complete_rec.event_purpose_code;
  end;

  procedure check_evh_inter_entity(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  DATE := fnd_api.g_miss_date
    , p0_a20  DATE := fnd_api.g_miss_date
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  NUMBER := 0-1962.0724
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  NUMBER := 0-1962.0724
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  NUMBER := 0-1962.0724
    , p0_a84  NUMBER := 0-1962.0724
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  DATE := fnd_api.g_miss_date
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  DATE := fnd_api.g_miss_date
    , p1_a20  DATE := fnd_api.g_miss_date
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  NUMBER := 0-1962.0724
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  DATE := fnd_api.g_miss_date
    , p1_a30  DATE := fnd_api.g_miss_date
    , p1_a31  NUMBER := 0-1962.0724
    , p1_a32  NUMBER := 0-1962.0724
    , p1_a33  VARCHAR2 := fnd_api.g_miss_char
    , p1_a34  VARCHAR2 := fnd_api.g_miss_char
    , p1_a35  NUMBER := 0-1962.0724
    , p1_a36  NUMBER := 0-1962.0724
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  NUMBER := 0-1962.0724
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  NUMBER := 0-1962.0724
    , p1_a41  NUMBER := 0-1962.0724
    , p1_a42  NUMBER := 0-1962.0724
    , p1_a43  NUMBER := 0-1962.0724
    , p1_a44  VARCHAR2 := fnd_api.g_miss_char
    , p1_a45  NUMBER := 0-1962.0724
    , p1_a46  NUMBER := 0-1962.0724
    , p1_a47  NUMBER := 0-1962.0724
    , p1_a48  VARCHAR2 := fnd_api.g_miss_char
    , p1_a49  VARCHAR2 := fnd_api.g_miss_char
    , p1_a50  NUMBER := 0-1962.0724
    , p1_a51  VARCHAR2 := fnd_api.g_miss_char
    , p1_a52  VARCHAR2 := fnd_api.g_miss_char
    , p1_a53  VARCHAR2 := fnd_api.g_miss_char
    , p1_a54  VARCHAR2 := fnd_api.g_miss_char
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  VARCHAR2 := fnd_api.g_miss_char
    , p1_a60  VARCHAR2 := fnd_api.g_miss_char
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  VARCHAR2 := fnd_api.g_miss_char
    , p1_a65  VARCHAR2 := fnd_api.g_miss_char
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  VARCHAR2 := fnd_api.g_miss_char
    , p1_a68  VARCHAR2 := fnd_api.g_miss_char
    , p1_a69  VARCHAR2 := fnd_api.g_miss_char
    , p1_a70  VARCHAR2 := fnd_api.g_miss_char
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  VARCHAR2 := fnd_api.g_miss_char
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  VARCHAR2 := fnd_api.g_miss_char
    , p1_a75  VARCHAR2 := fnd_api.g_miss_char
    , p1_a76  NUMBER := 0-1962.0724
    , p1_a77  VARCHAR2 := fnd_api.g_miss_char
    , p1_a78  NUMBER := 0-1962.0724
    , p1_a79  VARCHAR2 := fnd_api.g_miss_char
    , p1_a80  VARCHAR2 := fnd_api.g_miss_char
    , p1_a81  VARCHAR2 := fnd_api.g_miss_char
    , p1_a82  VARCHAR2 := fnd_api.g_miss_char
    , p1_a83  NUMBER := 0-1962.0724
    , p1_a84  NUMBER := 0-1962.0724
    , p1_a85  VARCHAR2 := fnd_api.g_miss_char
    , p1_a86  VARCHAR2 := fnd_api.g_miss_char
    , p1_a87  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evh_rec ams_eventheader_pvt.evh_rec_type;
    ddp_complete_rec ams_eventheader_pvt.evh_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evh_rec.event_header_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evh_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evh_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evh_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evh_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evh_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evh_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evh_rec.event_level := p0_a7;
    ddp_evh_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evh_rec.event_type_code := p0_a9;
    ddp_evh_rec.active_flag := p0_a10;
    ddp_evh_rec.private_flag := p0_a11;
    ddp_evh_rec.user_status_id := rosetta_g_miss_num_map(p0_a12);
    ddp_evh_rec.system_status_code := p0_a13;
    ddp_evh_rec.last_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evh_rec.stream_type_code := p0_a15;
    ddp_evh_rec.source_code := p0_a16;
    ddp_evh_rec.event_standalone_flag := p0_a17;
    ddp_evh_rec.day_of_event := p0_a18;
    ddp_evh_rec.agenda_start_time := rosetta_g_miss_date_in_map(p0_a19);
    ddp_evh_rec.agenda_end_time := rosetta_g_miss_date_in_map(p0_a20);
    ddp_evh_rec.reg_required_flag := p0_a21;
    ddp_evh_rec.reg_charge_flag := p0_a22;
    ddp_evh_rec.reg_invited_only_flag := p0_a23;
    ddp_evh_rec.partner_flag := p0_a24;
    ddp_evh_rec.overflow_flag := p0_a25;
    ddp_evh_rec.parent_event_header_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evh_rec.duration := rosetta_g_miss_num_map(p0_a27);
    ddp_evh_rec.duration_uom_code := p0_a28;
    ddp_evh_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_evh_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_evh_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p0_a31);
    ddp_evh_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p0_a32);
    ddp_evh_rec.main_language_code := p0_a33;
    ddp_evh_rec.cert_credit_type_code := p0_a34;
    ddp_evh_rec.certification_credits := rosetta_g_miss_num_map(p0_a35);
    ddp_evh_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evh_rec.organization_id := rosetta_g_miss_num_map(p0_a37);
    ddp_evh_rec.org_id := rosetta_g_miss_num_map(p0_a38);
    ddp_evh_rec.forecasted_revenue := rosetta_g_miss_num_map(p0_a39);
    ddp_evh_rec.actual_revenue := rosetta_g_miss_num_map(p0_a40);
    ddp_evh_rec.forecasted_cost := rosetta_g_miss_num_map(p0_a41);
    ddp_evh_rec.actual_cost := rosetta_g_miss_num_map(p0_a42);
    ddp_evh_rec.coordinator_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evh_rec.fund_source_type_code := p0_a44;
    ddp_evh_rec.fund_source_id := rosetta_g_miss_num_map(p0_a45);
    ddp_evh_rec.fund_amount_tc := rosetta_g_miss_num_map(p0_a46);
    ddp_evh_rec.fund_amount_fc := rosetta_g_miss_num_map(p0_a47);
    ddp_evh_rec.currency_code_tc := p0_a48;
    ddp_evh_rec.currency_code_fc := p0_a49;
    ddp_evh_rec.owner_user_id := rosetta_g_miss_num_map(p0_a50);
    ddp_evh_rec.url := p0_a51;
    ddp_evh_rec.email := p0_a52;
    ddp_evh_rec.phone := p0_a53;
    ddp_evh_rec.priority_type_code := p0_a54;
    ddp_evh_rec.cancellation_reason_code := p0_a55;
    ddp_evh_rec.inbound_script_name := p0_a56;
    ddp_evh_rec.attribute_category := p0_a57;
    ddp_evh_rec.attribute1 := p0_a58;
    ddp_evh_rec.attribute2 := p0_a59;
    ddp_evh_rec.attribute3 := p0_a60;
    ddp_evh_rec.attribute4 := p0_a61;
    ddp_evh_rec.attribute5 := p0_a62;
    ddp_evh_rec.attribute6 := p0_a63;
    ddp_evh_rec.attribute7 := p0_a64;
    ddp_evh_rec.attribute8 := p0_a65;
    ddp_evh_rec.attribute9 := p0_a66;
    ddp_evh_rec.attribute10 := p0_a67;
    ddp_evh_rec.attribute11 := p0_a68;
    ddp_evh_rec.attribute12 := p0_a69;
    ddp_evh_rec.attribute13 := p0_a70;
    ddp_evh_rec.attribute14 := p0_a71;
    ddp_evh_rec.attribute15 := p0_a72;
    ddp_evh_rec.event_header_name := p0_a73;
    ddp_evh_rec.event_mktg_message := p0_a74;
    ddp_evh_rec.description := p0_a75;
    ddp_evh_rec.custom_setup_id := rosetta_g_miss_num_map(p0_a76);
    ddp_evh_rec.country_code := p0_a77;
    ddp_evh_rec.business_unit_id := rosetta_g_miss_num_map(p0_a78);
    ddp_evh_rec.event_calendar := p0_a79;
    ddp_evh_rec.start_period_name := p0_a80;
    ddp_evh_rec.end_period_name := p0_a81;
    ddp_evh_rec.global_flag := p0_a82;
    ddp_evh_rec.task_id := rosetta_g_miss_num_map(p0_a83);
    ddp_evh_rec.program_id := rosetta_g_miss_num_map(p0_a84);
    ddp_evh_rec.create_attendant_lead_flag := p0_a85;
    ddp_evh_rec.create_registrant_lead_flag := p0_a86;
    ddp_evh_rec.event_purpose_code := p0_a87;

    ddp_complete_rec.event_header_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.event_level := p1_a7;
    ddp_complete_rec.application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.event_type_code := p1_a9;
    ddp_complete_rec.active_flag := p1_a10;
    ddp_complete_rec.private_flag := p1_a11;
    ddp_complete_rec.user_status_id := rosetta_g_miss_num_map(p1_a12);
    ddp_complete_rec.system_status_code := p1_a13;
    ddp_complete_rec.last_status_date := rosetta_g_miss_date_in_map(p1_a14);
    ddp_complete_rec.stream_type_code := p1_a15;
    ddp_complete_rec.source_code := p1_a16;
    ddp_complete_rec.event_standalone_flag := p1_a17;
    ddp_complete_rec.day_of_event := p1_a18;
    ddp_complete_rec.agenda_start_time := rosetta_g_miss_date_in_map(p1_a19);
    ddp_complete_rec.agenda_end_time := rosetta_g_miss_date_in_map(p1_a20);
    ddp_complete_rec.reg_required_flag := p1_a21;
    ddp_complete_rec.reg_charge_flag := p1_a22;
    ddp_complete_rec.reg_invited_only_flag := p1_a23;
    ddp_complete_rec.partner_flag := p1_a24;
    ddp_complete_rec.overflow_flag := p1_a25;
    ddp_complete_rec.parent_event_header_id := rosetta_g_miss_num_map(p1_a26);
    ddp_complete_rec.duration := rosetta_g_miss_num_map(p1_a27);
    ddp_complete_rec.duration_uom_code := p1_a28;
    ddp_complete_rec.active_from_date := rosetta_g_miss_date_in_map(p1_a29);
    ddp_complete_rec.active_to_date := rosetta_g_miss_date_in_map(p1_a30);
    ddp_complete_rec.reg_maximum_capacity := rosetta_g_miss_num_map(p1_a31);
    ddp_complete_rec.reg_minimum_capacity := rosetta_g_miss_num_map(p1_a32);
    ddp_complete_rec.main_language_code := p1_a33;
    ddp_complete_rec.cert_credit_type_code := p1_a34;
    ddp_complete_rec.certification_credits := rosetta_g_miss_num_map(p1_a35);
    ddp_complete_rec.inventory_item_id := rosetta_g_miss_num_map(p1_a36);
    ddp_complete_rec.organization_id := rosetta_g_miss_num_map(p1_a37);
    ddp_complete_rec.org_id := rosetta_g_miss_num_map(p1_a38);
    ddp_complete_rec.forecasted_revenue := rosetta_g_miss_num_map(p1_a39);
    ddp_complete_rec.actual_revenue := rosetta_g_miss_num_map(p1_a40);
    ddp_complete_rec.forecasted_cost := rosetta_g_miss_num_map(p1_a41);
    ddp_complete_rec.actual_cost := rosetta_g_miss_num_map(p1_a42);
    ddp_complete_rec.coordinator_id := rosetta_g_miss_num_map(p1_a43);
    ddp_complete_rec.fund_source_type_code := p1_a44;
    ddp_complete_rec.fund_source_id := rosetta_g_miss_num_map(p1_a45);
    ddp_complete_rec.fund_amount_tc := rosetta_g_miss_num_map(p1_a46);
    ddp_complete_rec.fund_amount_fc := rosetta_g_miss_num_map(p1_a47);
    ddp_complete_rec.currency_code_tc := p1_a48;
    ddp_complete_rec.currency_code_fc := p1_a49;
    ddp_complete_rec.owner_user_id := rosetta_g_miss_num_map(p1_a50);
    ddp_complete_rec.url := p1_a51;
    ddp_complete_rec.email := p1_a52;
    ddp_complete_rec.phone := p1_a53;
    ddp_complete_rec.priority_type_code := p1_a54;
    ddp_complete_rec.cancellation_reason_code := p1_a55;
    ddp_complete_rec.inbound_script_name := p1_a56;
    ddp_complete_rec.attribute_category := p1_a57;
    ddp_complete_rec.attribute1 := p1_a58;
    ddp_complete_rec.attribute2 := p1_a59;
    ddp_complete_rec.attribute3 := p1_a60;
    ddp_complete_rec.attribute4 := p1_a61;
    ddp_complete_rec.attribute5 := p1_a62;
    ddp_complete_rec.attribute6 := p1_a63;
    ddp_complete_rec.attribute7 := p1_a64;
    ddp_complete_rec.attribute8 := p1_a65;
    ddp_complete_rec.attribute9 := p1_a66;
    ddp_complete_rec.attribute10 := p1_a67;
    ddp_complete_rec.attribute11 := p1_a68;
    ddp_complete_rec.attribute12 := p1_a69;
    ddp_complete_rec.attribute13 := p1_a70;
    ddp_complete_rec.attribute14 := p1_a71;
    ddp_complete_rec.attribute15 := p1_a72;
    ddp_complete_rec.event_header_name := p1_a73;
    ddp_complete_rec.event_mktg_message := p1_a74;
    ddp_complete_rec.description := p1_a75;
    ddp_complete_rec.custom_setup_id := rosetta_g_miss_num_map(p1_a76);
    ddp_complete_rec.country_code := p1_a77;
    ddp_complete_rec.business_unit_id := rosetta_g_miss_num_map(p1_a78);
    ddp_complete_rec.event_calendar := p1_a79;
    ddp_complete_rec.start_period_name := p1_a80;
    ddp_complete_rec.end_period_name := p1_a81;
    ddp_complete_rec.global_flag := p1_a82;
    ddp_complete_rec.task_id := rosetta_g_miss_num_map(p1_a83);
    ddp_complete_rec.program_id := rosetta_g_miss_num_map(p1_a84);
    ddp_complete_rec.create_attendant_lead_flag := p1_a85;
    ddp_complete_rec.create_registrant_lead_flag := p1_a86;
    ddp_complete_rec.event_purpose_code := p1_a87;



    -- here's the delegated call to the old PL/SQL routine
    ams_eventheader_pvt.check_evh_inter_entity(ddp_evh_rec,
      ddp_complete_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any



  end;

end ams_eventheader_pvt_w;

/
