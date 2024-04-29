--------------------------------------------------------
--  DDL for Package Body AMS_EVTREGS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVTREGS_PVT_W" as
  /* $Header: amswregb.pls 115.13 2004/04/08 09:12:18 anchaudh ship $ */
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

  procedure create_evtregs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_block_fulfillment  VARCHAR2
    , x_event_registration_id OUT NOCOPY  NUMBER
    , x_confirmation_code OUT NOCOPY  VARCHAR2
    , x_system_status_code OUT NOCOPY  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  DATE := fnd_api.g_miss_date
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  NUMBER := 0-1962.0724
    , p4_a42  NUMBER := 0-1962.0724
    , p4_a43  NUMBER := 0-1962.0724
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  VARCHAR2 := fnd_api.g_miss_char
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  DATE := fnd_api.g_miss_date
    , p4_a68  DATE := fnd_api.g_miss_date
    , p4_a69  DATE := fnd_api.g_miss_date
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p4_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p4_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p4_a8);
    ddp_evt_regs_rec.active_flag := p4_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p4_a10);
    ddp_evt_regs_rec.system_status_code := p4_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p4_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p4_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p4_a14);
    ddp_evt_regs_rec.reg_source_type_code := p4_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p4_a16);
    ddp_evt_regs_rec.confirmation_code := p4_a17;
    ddp_evt_regs_rec.source_code := p4_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p4_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p4_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p4_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p4_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p4_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p4_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p4_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p4_a26);
    ddp_evt_regs_rec.prospect_flag := p4_a27;
    ddp_evt_regs_rec.attended_flag := p4_a28;
    ddp_evt_regs_rec.confirmed_flag := p4_a29;
    ddp_evt_regs_rec.evaluated_flag := p4_a30;
    ddp_evt_regs_rec.waitlisted_flag := p4_a31;
    ddp_evt_regs_rec.attendance_result_code := p4_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p4_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p4_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p4_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p4_a36);
    ddp_evt_regs_rec.cancellation_code := p4_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p4_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p4_a39;
    ddp_evt_regs_rec.attendant_language := p4_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p4_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p4_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p4_a43);
    ddp_evt_regs_rec.description := p4_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p4_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p4_a46;
    ddp_evt_regs_rec.payment_status_code := p4_a47;
    ddp_evt_regs_rec.auto_register_flag := p4_a48;
    ddp_evt_regs_rec.attribute_category := p4_a49;
    ddp_evt_regs_rec.attribute1 := p4_a50;
    ddp_evt_regs_rec.attribute2 := p4_a51;
    ddp_evt_regs_rec.attribute3 := p4_a52;
    ddp_evt_regs_rec.attribute4 := p4_a53;
    ddp_evt_regs_rec.attribute5 := p4_a54;
    ddp_evt_regs_rec.attribute6 := p4_a55;
    ddp_evt_regs_rec.attribute7 := p4_a56;
    ddp_evt_regs_rec.attribute8 := p4_a57;
    ddp_evt_regs_rec.attribute9 := p4_a58;
    ddp_evt_regs_rec.attribute10 := p4_a59;
    ddp_evt_regs_rec.attribute11 := p4_a60;
    ddp_evt_regs_rec.attribute12 := p4_a61;
    ddp_evt_regs_rec.attribute13 := p4_a62;
    ddp_evt_regs_rec.attribute14 := p4_a63;
    ddp_evt_regs_rec.attribute15 := p4_a64;
    ddp_evt_regs_rec.attendee_role_type := p4_a65;
    ddp_evt_regs_rec.notification_type := p4_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p4_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p4_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p4_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p4_a70;








    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.create_evtregs(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_evt_regs_rec,
      p_block_fulfillment,
      x_event_registration_id,
      x_confirmation_code,
      x_system_status_code,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any











  end;

  procedure update_evtregs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_block_fulfillment  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  DATE := fnd_api.g_miss_date
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  NUMBER := 0-1962.0724
    , p4_a42  NUMBER := 0-1962.0724
    , p4_a43  NUMBER := 0-1962.0724
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  VARCHAR2 := fnd_api.g_miss_char
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  DATE := fnd_api.g_miss_date
    , p4_a68  DATE := fnd_api.g_miss_date
    , p4_a69  DATE := fnd_api.g_miss_date
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p4_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p4_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p4_a8);
    ddp_evt_regs_rec.active_flag := p4_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p4_a10);
    ddp_evt_regs_rec.system_status_code := p4_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p4_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p4_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p4_a14);
    ddp_evt_regs_rec.reg_source_type_code := p4_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p4_a16);
    ddp_evt_regs_rec.confirmation_code := p4_a17;
    ddp_evt_regs_rec.source_code := p4_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p4_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p4_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p4_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p4_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p4_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p4_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p4_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p4_a26);
    ddp_evt_regs_rec.prospect_flag := p4_a27;
    ddp_evt_regs_rec.attended_flag := p4_a28;
    ddp_evt_regs_rec.confirmed_flag := p4_a29;
    ddp_evt_regs_rec.evaluated_flag := p4_a30;
    ddp_evt_regs_rec.waitlisted_flag := p4_a31;
    ddp_evt_regs_rec.attendance_result_code := p4_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p4_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p4_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p4_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p4_a36);
    ddp_evt_regs_rec.cancellation_code := p4_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p4_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p4_a39;
    ddp_evt_regs_rec.attendant_language := p4_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p4_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p4_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p4_a43);
    ddp_evt_regs_rec.description := p4_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p4_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p4_a46;
    ddp_evt_regs_rec.payment_status_code := p4_a47;
    ddp_evt_regs_rec.auto_register_flag := p4_a48;
    ddp_evt_regs_rec.attribute_category := p4_a49;
    ddp_evt_regs_rec.attribute1 := p4_a50;
    ddp_evt_regs_rec.attribute2 := p4_a51;
    ddp_evt_regs_rec.attribute3 := p4_a52;
    ddp_evt_regs_rec.attribute4 := p4_a53;
    ddp_evt_regs_rec.attribute5 := p4_a54;
    ddp_evt_regs_rec.attribute6 := p4_a55;
    ddp_evt_regs_rec.attribute7 := p4_a56;
    ddp_evt_regs_rec.attribute8 := p4_a57;
    ddp_evt_regs_rec.attribute9 := p4_a58;
    ddp_evt_regs_rec.attribute10 := p4_a59;
    ddp_evt_regs_rec.attribute11 := p4_a60;
    ddp_evt_regs_rec.attribute12 := p4_a61;
    ddp_evt_regs_rec.attribute13 := p4_a62;
    ddp_evt_regs_rec.attribute14 := p4_a63;
    ddp_evt_regs_rec.attribute15 := p4_a64;
    ddp_evt_regs_rec.attendee_role_type := p4_a65;
    ddp_evt_regs_rec.notification_type := p4_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p4_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p4_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p4_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p4_a70;





    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.update_evtregs(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_evt_regs_rec,
      p_block_fulfillment,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_evtregs_wrapper(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_block_fulfillment  VARCHAR2
    , p_cancellation_reason_code  VARCHAR2
    , x_cancellation_code OUT NOCOPY  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  DATE := fnd_api.g_miss_date
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  NUMBER := 0-1962.0724
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  NUMBER := 0-1962.0724
    , p4_a42  NUMBER := 0-1962.0724
    , p4_a43  NUMBER := 0-1962.0724
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  VARCHAR2 := fnd_api.g_miss_char
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  DATE := fnd_api.g_miss_date
    , p4_a68  DATE := fnd_api.g_miss_date
    , p4_a69  DATE := fnd_api.g_miss_date
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p4_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p4_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p4_a8);
    ddp_evt_regs_rec.active_flag := p4_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p4_a10);
    ddp_evt_regs_rec.system_status_code := p4_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p4_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p4_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p4_a14);
    ddp_evt_regs_rec.reg_source_type_code := p4_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p4_a16);
    ddp_evt_regs_rec.confirmation_code := p4_a17;
    ddp_evt_regs_rec.source_code := p4_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p4_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p4_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p4_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p4_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p4_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p4_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p4_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p4_a26);
    ddp_evt_regs_rec.prospect_flag := p4_a27;
    ddp_evt_regs_rec.attended_flag := p4_a28;
    ddp_evt_regs_rec.confirmed_flag := p4_a29;
    ddp_evt_regs_rec.evaluated_flag := p4_a30;
    ddp_evt_regs_rec.waitlisted_flag := p4_a31;
    ddp_evt_regs_rec.attendance_result_code := p4_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p4_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p4_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p4_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p4_a36);
    ddp_evt_regs_rec.cancellation_code := p4_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p4_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p4_a39;
    ddp_evt_regs_rec.attendant_language := p4_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p4_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p4_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p4_a43);
    ddp_evt_regs_rec.description := p4_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p4_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p4_a46;
    ddp_evt_regs_rec.payment_status_code := p4_a47;
    ddp_evt_regs_rec.auto_register_flag := p4_a48;
    ddp_evt_regs_rec.attribute_category := p4_a49;
    ddp_evt_regs_rec.attribute1 := p4_a50;
    ddp_evt_regs_rec.attribute2 := p4_a51;
    ddp_evt_regs_rec.attribute3 := p4_a52;
    ddp_evt_regs_rec.attribute4 := p4_a53;
    ddp_evt_regs_rec.attribute5 := p4_a54;
    ddp_evt_regs_rec.attribute6 := p4_a55;
    ddp_evt_regs_rec.attribute7 := p4_a56;
    ddp_evt_regs_rec.attribute8 := p4_a57;
    ddp_evt_regs_rec.attribute9 := p4_a58;
    ddp_evt_regs_rec.attribute10 := p4_a59;
    ddp_evt_regs_rec.attribute11 := p4_a60;
    ddp_evt_regs_rec.attribute12 := p4_a61;
    ddp_evt_regs_rec.attribute13 := p4_a62;
    ddp_evt_regs_rec.attribute14 := p4_a63;
    ddp_evt_regs_rec.attribute15 := p4_a64;
    ddp_evt_regs_rec.attendee_role_type := p4_a65;
    ddp_evt_regs_rec.notification_type := p4_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p4_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p4_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p4_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p4_a70;







    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.update_evtregs_wrapper(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_evt_regs_rec,
      p_block_fulfillment,
      p_cancellation_reason_code,
      x_cancellation_code,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any










  end;

  procedure check_evtregs_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  DATE := fnd_api.g_miss_date
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p0_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evt_regs_rec.active_flag := p0_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p0_a10);
    ddp_evt_regs_rec.system_status_code := p0_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p0_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p0_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evt_regs_rec.reg_source_type_code := p0_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_evt_regs_rec.confirmation_code := p0_a17;
    ddp_evt_regs_rec.source_code := p0_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p0_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p0_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p0_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p0_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p0_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p0_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p0_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evt_regs_rec.prospect_flag := p0_a27;
    ddp_evt_regs_rec.attended_flag := p0_a28;
    ddp_evt_regs_rec.confirmed_flag := p0_a29;
    ddp_evt_regs_rec.evaluated_flag := p0_a30;
    ddp_evt_regs_rec.waitlisted_flag := p0_a31;
    ddp_evt_regs_rec.attendance_result_code := p0_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p0_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p0_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p0_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evt_regs_rec.cancellation_code := p0_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p0_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p0_a39;
    ddp_evt_regs_rec.attendant_language := p0_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p0_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p0_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evt_regs_rec.description := p0_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p0_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p0_a46;
    ddp_evt_regs_rec.payment_status_code := p0_a47;
    ddp_evt_regs_rec.auto_register_flag := p0_a48;
    ddp_evt_regs_rec.attribute_category := p0_a49;
    ddp_evt_regs_rec.attribute1 := p0_a50;
    ddp_evt_regs_rec.attribute2 := p0_a51;
    ddp_evt_regs_rec.attribute3 := p0_a52;
    ddp_evt_regs_rec.attribute4 := p0_a53;
    ddp_evt_regs_rec.attribute5 := p0_a54;
    ddp_evt_regs_rec.attribute6 := p0_a55;
    ddp_evt_regs_rec.attribute7 := p0_a56;
    ddp_evt_regs_rec.attribute8 := p0_a57;
    ddp_evt_regs_rec.attribute9 := p0_a58;
    ddp_evt_regs_rec.attribute10 := p0_a59;
    ddp_evt_regs_rec.attribute11 := p0_a60;
    ddp_evt_regs_rec.attribute12 := p0_a61;
    ddp_evt_regs_rec.attribute13 := p0_a62;
    ddp_evt_regs_rec.attribute14 := p0_a63;
    ddp_evt_regs_rec.attribute15 := p0_a64;
    ddp_evt_regs_rec.attendee_role_type := p0_a65;
    ddp_evt_regs_rec.notification_type := p0_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p0_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p0_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p0_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p0_a70;



    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.check_evtregs_items(ddp_evt_regs_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_evtregs_req_items(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  DATE := fnd_api.g_miss_date
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p0_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evt_regs_rec.active_flag := p0_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p0_a10);
    ddp_evt_regs_rec.system_status_code := p0_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p0_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p0_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evt_regs_rec.reg_source_type_code := p0_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_evt_regs_rec.confirmation_code := p0_a17;
    ddp_evt_regs_rec.source_code := p0_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p0_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p0_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p0_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p0_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p0_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p0_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p0_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evt_regs_rec.prospect_flag := p0_a27;
    ddp_evt_regs_rec.attended_flag := p0_a28;
    ddp_evt_regs_rec.confirmed_flag := p0_a29;
    ddp_evt_regs_rec.evaluated_flag := p0_a30;
    ddp_evt_regs_rec.waitlisted_flag := p0_a31;
    ddp_evt_regs_rec.attendance_result_code := p0_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p0_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p0_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p0_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evt_regs_rec.cancellation_code := p0_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p0_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p0_a39;
    ddp_evt_regs_rec.attendant_language := p0_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p0_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p0_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evt_regs_rec.description := p0_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p0_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p0_a46;
    ddp_evt_regs_rec.payment_status_code := p0_a47;
    ddp_evt_regs_rec.auto_register_flag := p0_a48;
    ddp_evt_regs_rec.attribute_category := p0_a49;
    ddp_evt_regs_rec.attribute1 := p0_a50;
    ddp_evt_regs_rec.attribute2 := p0_a51;
    ddp_evt_regs_rec.attribute3 := p0_a52;
    ddp_evt_regs_rec.attribute4 := p0_a53;
    ddp_evt_regs_rec.attribute5 := p0_a54;
    ddp_evt_regs_rec.attribute6 := p0_a55;
    ddp_evt_regs_rec.attribute7 := p0_a56;
    ddp_evt_regs_rec.attribute8 := p0_a57;
    ddp_evt_regs_rec.attribute9 := p0_a58;
    ddp_evt_regs_rec.attribute10 := p0_a59;
    ddp_evt_regs_rec.attribute11 := p0_a60;
    ddp_evt_regs_rec.attribute12 := p0_a61;
    ddp_evt_regs_rec.attribute13 := p0_a62;
    ddp_evt_regs_rec.attribute14 := p0_a63;
    ddp_evt_regs_rec.attribute15 := p0_a64;
    ddp_evt_regs_rec.attendee_role_type := p0_a65;
    ddp_evt_regs_rec.notification_type := p0_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p0_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p0_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p0_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p0_a70;


    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.check_evtregs_req_items(ddp_evt_regs_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure check_evtregs_fk_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  DATE := fnd_api.g_miss_date
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p0_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evt_regs_rec.active_flag := p0_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p0_a10);
    ddp_evt_regs_rec.system_status_code := p0_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p0_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p0_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evt_regs_rec.reg_source_type_code := p0_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_evt_regs_rec.confirmation_code := p0_a17;
    ddp_evt_regs_rec.source_code := p0_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p0_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p0_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p0_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p0_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p0_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p0_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p0_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evt_regs_rec.prospect_flag := p0_a27;
    ddp_evt_regs_rec.attended_flag := p0_a28;
    ddp_evt_regs_rec.confirmed_flag := p0_a29;
    ddp_evt_regs_rec.evaluated_flag := p0_a30;
    ddp_evt_regs_rec.waitlisted_flag := p0_a31;
    ddp_evt_regs_rec.attendance_result_code := p0_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p0_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p0_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p0_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evt_regs_rec.cancellation_code := p0_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p0_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p0_a39;
    ddp_evt_regs_rec.attendant_language := p0_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p0_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p0_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evt_regs_rec.description := p0_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p0_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p0_a46;
    ddp_evt_regs_rec.payment_status_code := p0_a47;
    ddp_evt_regs_rec.auto_register_flag := p0_a48;
    ddp_evt_regs_rec.attribute_category := p0_a49;
    ddp_evt_regs_rec.attribute1 := p0_a50;
    ddp_evt_regs_rec.attribute2 := p0_a51;
    ddp_evt_regs_rec.attribute3 := p0_a52;
    ddp_evt_regs_rec.attribute4 := p0_a53;
    ddp_evt_regs_rec.attribute5 := p0_a54;
    ddp_evt_regs_rec.attribute6 := p0_a55;
    ddp_evt_regs_rec.attribute7 := p0_a56;
    ddp_evt_regs_rec.attribute8 := p0_a57;
    ddp_evt_regs_rec.attribute9 := p0_a58;
    ddp_evt_regs_rec.attribute10 := p0_a59;
    ddp_evt_regs_rec.attribute11 := p0_a60;
    ddp_evt_regs_rec.attribute12 := p0_a61;
    ddp_evt_regs_rec.attribute13 := p0_a62;
    ddp_evt_regs_rec.attribute14 := p0_a63;
    ddp_evt_regs_rec.attribute15 := p0_a64;
    ddp_evt_regs_rec.attendee_role_type := p0_a65;
    ddp_evt_regs_rec.notification_type := p0_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p0_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p0_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p0_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p0_a70;



    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.check_evtregs_fk_items(ddp_evt_regs_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_evtregs_lookup_items(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  DATE := fnd_api.g_miss_date
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p0_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evt_regs_rec.active_flag := p0_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p0_a10);
    ddp_evt_regs_rec.system_status_code := p0_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p0_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p0_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evt_regs_rec.reg_source_type_code := p0_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_evt_regs_rec.confirmation_code := p0_a17;
    ddp_evt_regs_rec.source_code := p0_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p0_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p0_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p0_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p0_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p0_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p0_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p0_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evt_regs_rec.prospect_flag := p0_a27;
    ddp_evt_regs_rec.attended_flag := p0_a28;
    ddp_evt_regs_rec.confirmed_flag := p0_a29;
    ddp_evt_regs_rec.evaluated_flag := p0_a30;
    ddp_evt_regs_rec.waitlisted_flag := p0_a31;
    ddp_evt_regs_rec.attendance_result_code := p0_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p0_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p0_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p0_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evt_regs_rec.cancellation_code := p0_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p0_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p0_a39;
    ddp_evt_regs_rec.attendant_language := p0_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p0_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p0_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evt_regs_rec.description := p0_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p0_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p0_a46;
    ddp_evt_regs_rec.payment_status_code := p0_a47;
    ddp_evt_regs_rec.auto_register_flag := p0_a48;
    ddp_evt_regs_rec.attribute_category := p0_a49;
    ddp_evt_regs_rec.attribute1 := p0_a50;
    ddp_evt_regs_rec.attribute2 := p0_a51;
    ddp_evt_regs_rec.attribute3 := p0_a52;
    ddp_evt_regs_rec.attribute4 := p0_a53;
    ddp_evt_regs_rec.attribute5 := p0_a54;
    ddp_evt_regs_rec.attribute6 := p0_a55;
    ddp_evt_regs_rec.attribute7 := p0_a56;
    ddp_evt_regs_rec.attribute8 := p0_a57;
    ddp_evt_regs_rec.attribute9 := p0_a58;
    ddp_evt_regs_rec.attribute10 := p0_a59;
    ddp_evt_regs_rec.attribute11 := p0_a60;
    ddp_evt_regs_rec.attribute12 := p0_a61;
    ddp_evt_regs_rec.attribute13 := p0_a62;
    ddp_evt_regs_rec.attribute14 := p0_a63;
    ddp_evt_regs_rec.attribute15 := p0_a64;
    ddp_evt_regs_rec.attendee_role_type := p0_a65;
    ddp_evt_regs_rec.notification_type := p0_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p0_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p0_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p0_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p0_a70;


    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.check_evtregs_lookup_items(ddp_evt_regs_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure check_evtregs_flag_items(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  DATE := fnd_api.g_miss_date
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p0_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evt_regs_rec.active_flag := p0_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p0_a10);
    ddp_evt_regs_rec.system_status_code := p0_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p0_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p0_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evt_regs_rec.reg_source_type_code := p0_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_evt_regs_rec.confirmation_code := p0_a17;
    ddp_evt_regs_rec.source_code := p0_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p0_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p0_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p0_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p0_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p0_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p0_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p0_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evt_regs_rec.prospect_flag := p0_a27;
    ddp_evt_regs_rec.attended_flag := p0_a28;
    ddp_evt_regs_rec.confirmed_flag := p0_a29;
    ddp_evt_regs_rec.evaluated_flag := p0_a30;
    ddp_evt_regs_rec.waitlisted_flag := p0_a31;
    ddp_evt_regs_rec.attendance_result_code := p0_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p0_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p0_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p0_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evt_regs_rec.cancellation_code := p0_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p0_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p0_a39;
    ddp_evt_regs_rec.attendant_language := p0_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p0_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p0_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evt_regs_rec.description := p0_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p0_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p0_a46;
    ddp_evt_regs_rec.payment_status_code := p0_a47;
    ddp_evt_regs_rec.auto_register_flag := p0_a48;
    ddp_evt_regs_rec.attribute_category := p0_a49;
    ddp_evt_regs_rec.attribute1 := p0_a50;
    ddp_evt_regs_rec.attribute2 := p0_a51;
    ddp_evt_regs_rec.attribute3 := p0_a52;
    ddp_evt_regs_rec.attribute4 := p0_a53;
    ddp_evt_regs_rec.attribute5 := p0_a54;
    ddp_evt_regs_rec.attribute6 := p0_a55;
    ddp_evt_regs_rec.attribute7 := p0_a56;
    ddp_evt_regs_rec.attribute8 := p0_a57;
    ddp_evt_regs_rec.attribute9 := p0_a58;
    ddp_evt_regs_rec.attribute10 := p0_a59;
    ddp_evt_regs_rec.attribute11 := p0_a60;
    ddp_evt_regs_rec.attribute12 := p0_a61;
    ddp_evt_regs_rec.attribute13 := p0_a62;
    ddp_evt_regs_rec.attribute14 := p0_a63;
    ddp_evt_regs_rec.attribute15 := p0_a64;
    ddp_evt_regs_rec.attendee_role_type := p0_a65;
    ddp_evt_regs_rec.notification_type := p0_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p0_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p0_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p0_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p0_a70;


    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.check_evtregs_flag_items(ddp_evt_regs_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure check_evtregs_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  DATE := fnd_api.g_miss_date
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p0_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evt_regs_rec.active_flag := p0_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p0_a10);
    ddp_evt_regs_rec.system_status_code := p0_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p0_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p0_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evt_regs_rec.reg_source_type_code := p0_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_evt_regs_rec.confirmation_code := p0_a17;
    ddp_evt_regs_rec.source_code := p0_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p0_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p0_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p0_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p0_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p0_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p0_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p0_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evt_regs_rec.prospect_flag := p0_a27;
    ddp_evt_regs_rec.attended_flag := p0_a28;
    ddp_evt_regs_rec.confirmed_flag := p0_a29;
    ddp_evt_regs_rec.evaluated_flag := p0_a30;
    ddp_evt_regs_rec.waitlisted_flag := p0_a31;
    ddp_evt_regs_rec.attendance_result_code := p0_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p0_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p0_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p0_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evt_regs_rec.cancellation_code := p0_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p0_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p0_a39;
    ddp_evt_regs_rec.attendant_language := p0_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p0_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p0_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evt_regs_rec.description := p0_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p0_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p0_a46;
    ddp_evt_regs_rec.payment_status_code := p0_a47;
    ddp_evt_regs_rec.auto_register_flag := p0_a48;
    ddp_evt_regs_rec.attribute_category := p0_a49;
    ddp_evt_regs_rec.attribute1 := p0_a50;
    ddp_evt_regs_rec.attribute2 := p0_a51;
    ddp_evt_regs_rec.attribute3 := p0_a52;
    ddp_evt_regs_rec.attribute4 := p0_a53;
    ddp_evt_regs_rec.attribute5 := p0_a54;
    ddp_evt_regs_rec.attribute6 := p0_a55;
    ddp_evt_regs_rec.attribute7 := p0_a56;
    ddp_evt_regs_rec.attribute8 := p0_a57;
    ddp_evt_regs_rec.attribute9 := p0_a58;
    ddp_evt_regs_rec.attribute10 := p0_a59;
    ddp_evt_regs_rec.attribute11 := p0_a60;
    ddp_evt_regs_rec.attribute12 := p0_a61;
    ddp_evt_regs_rec.attribute13 := p0_a62;
    ddp_evt_regs_rec.attribute14 := p0_a63;
    ddp_evt_regs_rec.attribute15 := p0_a64;
    ddp_evt_regs_rec.attendee_role_type := p0_a65;
    ddp_evt_regs_rec.notification_type := p0_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p0_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p0_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p0_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p0_a70;


    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.check_evtregs_record(ddp_evt_regs_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure validate_evtregs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  DATE := fnd_api.g_miss_date
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  DATE := fnd_api.g_miss_date
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  NUMBER := 0-1962.0724
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  NUMBER := 0-1962.0724
    , p3_a20  NUMBER := 0-1962.0724
    , p3_a21  NUMBER := 0-1962.0724
    , p3_a22  NUMBER := 0-1962.0724
    , p3_a23  NUMBER := 0-1962.0724
    , p3_a24  NUMBER := 0-1962.0724
    , p3_a25  NUMBER := 0-1962.0724
    , p3_a26  NUMBER := 0-1962.0724
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
    , p3_a29  VARCHAR2 := fnd_api.g_miss_char
    , p3_a30  VARCHAR2 := fnd_api.g_miss_char
    , p3_a31  VARCHAR2 := fnd_api.g_miss_char
    , p3_a32  VARCHAR2 := fnd_api.g_miss_char
    , p3_a33  NUMBER := 0-1962.0724
    , p3_a34  NUMBER := 0-1962.0724
    , p3_a35  NUMBER := 0-1962.0724
    , p3_a36  NUMBER := 0-1962.0724
    , p3_a37  VARCHAR2 := fnd_api.g_miss_char
    , p3_a38  VARCHAR2 := fnd_api.g_miss_char
    , p3_a39  VARCHAR2 := fnd_api.g_miss_char
    , p3_a40  VARCHAR2 := fnd_api.g_miss_char
    , p3_a41  NUMBER := 0-1962.0724
    , p3_a42  NUMBER := 0-1962.0724
    , p3_a43  NUMBER := 0-1962.0724
    , p3_a44  VARCHAR2 := fnd_api.g_miss_char
    , p3_a45  VARCHAR2 := fnd_api.g_miss_char
    , p3_a46  VARCHAR2 := fnd_api.g_miss_char
    , p3_a47  VARCHAR2 := fnd_api.g_miss_char
    , p3_a48  VARCHAR2 := fnd_api.g_miss_char
    , p3_a49  VARCHAR2 := fnd_api.g_miss_char
    , p3_a50  VARCHAR2 := fnd_api.g_miss_char
    , p3_a51  VARCHAR2 := fnd_api.g_miss_char
    , p3_a52  VARCHAR2 := fnd_api.g_miss_char
    , p3_a53  VARCHAR2 := fnd_api.g_miss_char
    , p3_a54  VARCHAR2 := fnd_api.g_miss_char
    , p3_a55  VARCHAR2 := fnd_api.g_miss_char
    , p3_a56  VARCHAR2 := fnd_api.g_miss_char
    , p3_a57  VARCHAR2 := fnd_api.g_miss_char
    , p3_a58  VARCHAR2 := fnd_api.g_miss_char
    , p3_a59  VARCHAR2 := fnd_api.g_miss_char
    , p3_a60  VARCHAR2 := fnd_api.g_miss_char
    , p3_a61  VARCHAR2 := fnd_api.g_miss_char
    , p3_a62  VARCHAR2 := fnd_api.g_miss_char
    , p3_a63  VARCHAR2 := fnd_api.g_miss_char
    , p3_a64  VARCHAR2 := fnd_api.g_miss_char
    , p3_a65  VARCHAR2 := fnd_api.g_miss_char
    , p3_a66  VARCHAR2 := fnd_api.g_miss_char
    , p3_a67  DATE := fnd_api.g_miss_date
    , p3_a68  DATE := fnd_api.g_miss_date
    , p3_a69  DATE := fnd_api.g_miss_date
    , p3_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p3_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p3_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p3_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p3_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p3_a8);
    ddp_evt_regs_rec.active_flag := p3_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p3_a10);
    ddp_evt_regs_rec.system_status_code := p3_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p3_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p3_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p3_a14);
    ddp_evt_regs_rec.reg_source_type_code := p3_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p3_a16);
    ddp_evt_regs_rec.confirmation_code := p3_a17;
    ddp_evt_regs_rec.source_code := p3_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p3_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p3_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p3_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p3_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p3_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p3_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p3_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p3_a26);
    ddp_evt_regs_rec.prospect_flag := p3_a27;
    ddp_evt_regs_rec.attended_flag := p3_a28;
    ddp_evt_regs_rec.confirmed_flag := p3_a29;
    ddp_evt_regs_rec.evaluated_flag := p3_a30;
    ddp_evt_regs_rec.waitlisted_flag := p3_a31;
    ddp_evt_regs_rec.attendance_result_code := p3_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p3_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p3_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p3_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p3_a36);
    ddp_evt_regs_rec.cancellation_code := p3_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p3_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p3_a39;
    ddp_evt_regs_rec.attendant_language := p3_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p3_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p3_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p3_a43);
    ddp_evt_regs_rec.description := p3_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p3_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p3_a46;
    ddp_evt_regs_rec.payment_status_code := p3_a47;
    ddp_evt_regs_rec.auto_register_flag := p3_a48;
    ddp_evt_regs_rec.attribute_category := p3_a49;
    ddp_evt_regs_rec.attribute1 := p3_a50;
    ddp_evt_regs_rec.attribute2 := p3_a51;
    ddp_evt_regs_rec.attribute3 := p3_a52;
    ddp_evt_regs_rec.attribute4 := p3_a53;
    ddp_evt_regs_rec.attribute5 := p3_a54;
    ddp_evt_regs_rec.attribute6 := p3_a55;
    ddp_evt_regs_rec.attribute7 := p3_a56;
    ddp_evt_regs_rec.attribute8 := p3_a57;
    ddp_evt_regs_rec.attribute9 := p3_a58;
    ddp_evt_regs_rec.attribute10 := p3_a59;
    ddp_evt_regs_rec.attribute11 := p3_a60;
    ddp_evt_regs_rec.attribute12 := p3_a61;
    ddp_evt_regs_rec.attribute13 := p3_a62;
    ddp_evt_regs_rec.attribute14 := p3_a63;
    ddp_evt_regs_rec.attribute15 := p3_a64;
    ddp_evt_regs_rec.attendee_role_type := p3_a65;
    ddp_evt_regs_rec.notification_type := p3_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p3_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p3_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p3_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p3_a70;





    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.validate_evtregs(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_evt_regs_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure init_evtregs_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  NUMBER
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  DATE
    , p0_a13 OUT NOCOPY  NUMBER
    , p0_a14 OUT NOCOPY  DATE
    , p0_a15 OUT NOCOPY  VARCHAR2
    , p0_a16 OUT NOCOPY  NUMBER
    , p0_a17 OUT NOCOPY  VARCHAR2
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  NUMBER
    , p0_a20 OUT NOCOPY  NUMBER
    , p0_a21 OUT NOCOPY  NUMBER
    , p0_a22 OUT NOCOPY  NUMBER
    , p0_a23 OUT NOCOPY  NUMBER
    , p0_a24 OUT NOCOPY  NUMBER
    , p0_a25 OUT NOCOPY  NUMBER
    , p0_a26 OUT NOCOPY  NUMBER
    , p0_a27 OUT NOCOPY  VARCHAR2
    , p0_a28 OUT NOCOPY  VARCHAR2
    , p0_a29 OUT NOCOPY  VARCHAR2
    , p0_a30 OUT NOCOPY  VARCHAR2
    , p0_a31 OUT NOCOPY  VARCHAR2
    , p0_a32 OUT NOCOPY  VARCHAR2
    , p0_a33 OUT NOCOPY  NUMBER
    , p0_a34 OUT NOCOPY  NUMBER
    , p0_a35 OUT NOCOPY  NUMBER
    , p0_a36 OUT NOCOPY  NUMBER
    , p0_a37 OUT NOCOPY  VARCHAR2
    , p0_a38 OUT NOCOPY  VARCHAR2
    , p0_a39 OUT NOCOPY  VARCHAR2
    , p0_a40 OUT NOCOPY  VARCHAR2
    , p0_a41 OUT NOCOPY  NUMBER
    , p0_a42 OUT NOCOPY  NUMBER
    , p0_a43 OUT NOCOPY  NUMBER
    , p0_a44 OUT NOCOPY  VARCHAR2
    , p0_a45 OUT NOCOPY  VARCHAR2
    , p0_a46 OUT NOCOPY  VARCHAR2
    , p0_a47 OUT NOCOPY  VARCHAR2
    , p0_a48 OUT NOCOPY  VARCHAR2
    , p0_a49 OUT NOCOPY  VARCHAR2
    , p0_a50 OUT NOCOPY  VARCHAR2
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
    , p0_a67 OUT NOCOPY  DATE
    , p0_a68 OUT NOCOPY  DATE
    , p0_a69 OUT NOCOPY  DATE
    , p0_a70 OUT NOCOPY  VARCHAR2
  )
  as
    ddx_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.init_evtregs_rec(ddx_evt_regs_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_evt_regs_rec.event_registration_id);
    p0_a1 := ddx_evt_regs_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_evt_regs_rec.last_updated_by);
    p0_a3 := ddx_evt_regs_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_evt_regs_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_evt_regs_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_evt_regs_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_evt_regs_rec.event_offer_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_evt_regs_rec.application_id);
    p0_a9 := ddx_evt_regs_rec.active_flag;
    p0_a10 := rosetta_g_miss_num_map(ddx_evt_regs_rec.owner_user_id);
    p0_a11 := ddx_evt_regs_rec.system_status_code;
    p0_a12 := ddx_evt_regs_rec.date_registration_placed;
    p0_a13 := rosetta_g_miss_num_map(ddx_evt_regs_rec.user_status_id);
    p0_a14 := ddx_evt_regs_rec.last_reg_status_date;
    p0_a15 := ddx_evt_regs_rec.reg_source_type_code;
    p0_a16 := rosetta_g_miss_num_map(ddx_evt_regs_rec.registration_source_id);
    p0_a17 := ddx_evt_regs_rec.confirmation_code;
    p0_a18 := ddx_evt_regs_rec.source_code;
    p0_a19 := rosetta_g_miss_num_map(ddx_evt_regs_rec.registration_group_id);
    p0_a20 := rosetta_g_miss_num_map(ddx_evt_regs_rec.registrant_party_id);
    p0_a21 := rosetta_g_miss_num_map(ddx_evt_regs_rec.registrant_contact_id);
    p0_a22 := rosetta_g_miss_num_map(ddx_evt_regs_rec.registrant_account_id);
    p0_a23 := rosetta_g_miss_num_map(ddx_evt_regs_rec.attendant_party_id);
    p0_a24 := rosetta_g_miss_num_map(ddx_evt_regs_rec.attendant_contact_id);
    p0_a25 := rosetta_g_miss_num_map(ddx_evt_regs_rec.attendant_account_id);
    p0_a26 := rosetta_g_miss_num_map(ddx_evt_regs_rec.original_registrant_contact_id);
    p0_a27 := ddx_evt_regs_rec.prospect_flag;
    p0_a28 := ddx_evt_regs_rec.attended_flag;
    p0_a29 := ddx_evt_regs_rec.confirmed_flag;
    p0_a30 := ddx_evt_regs_rec.evaluated_flag;
    p0_a31 := ddx_evt_regs_rec.waitlisted_flag;
    p0_a32 := ddx_evt_regs_rec.attendance_result_code;
    p0_a33 := rosetta_g_miss_num_map(ddx_evt_regs_rec.waitlisted_priority);
    p0_a34 := rosetta_g_miss_num_map(ddx_evt_regs_rec.target_list_id);
    p0_a35 := rosetta_g_miss_num_map(ddx_evt_regs_rec.inbound_media_id);
    p0_a36 := rosetta_g_miss_num_map(ddx_evt_regs_rec.inbound_channel_id);
    p0_a37 := ddx_evt_regs_rec.cancellation_code;
    p0_a38 := ddx_evt_regs_rec.cancellation_reason_code;
    p0_a39 := ddx_evt_regs_rec.attendance_failure_reason;
    p0_a40 := ddx_evt_regs_rec.attendant_language;
    p0_a41 := rosetta_g_miss_num_map(ddx_evt_regs_rec.salesrep_id);
    p0_a42 := rosetta_g_miss_num_map(ddx_evt_regs_rec.order_header_id);
    p0_a43 := rosetta_g_miss_num_map(ddx_evt_regs_rec.order_line_id);
    p0_a44 := ddx_evt_regs_rec.description;
    p0_a45 := ddx_evt_regs_rec.max_attendee_override_flag;
    p0_a46 := ddx_evt_regs_rec.invite_only_override_flag;
    p0_a47 := ddx_evt_regs_rec.payment_status_code;
    p0_a48 := ddx_evt_regs_rec.auto_register_flag;
    p0_a49 := ddx_evt_regs_rec.attribute_category;
    p0_a50 := ddx_evt_regs_rec.attribute1;
    p0_a51 := ddx_evt_regs_rec.attribute2;
    p0_a52 := ddx_evt_regs_rec.attribute3;
    p0_a53 := ddx_evt_regs_rec.attribute4;
    p0_a54 := ddx_evt_regs_rec.attribute5;
    p0_a55 := ddx_evt_regs_rec.attribute6;
    p0_a56 := ddx_evt_regs_rec.attribute7;
    p0_a57 := ddx_evt_regs_rec.attribute8;
    p0_a58 := ddx_evt_regs_rec.attribute9;
    p0_a59 := ddx_evt_regs_rec.attribute10;
    p0_a60 := ddx_evt_regs_rec.attribute11;
    p0_a61 := ddx_evt_regs_rec.attribute12;
    p0_a62 := ddx_evt_regs_rec.attribute13;
    p0_a63 := ddx_evt_regs_rec.attribute14;
    p0_a64 := ddx_evt_regs_rec.attribute15;
    p0_a65 := ddx_evt_regs_rec.attendee_role_type;
    p0_a66 := ddx_evt_regs_rec.notification_type;
    p0_a67 := ddx_evt_regs_rec.last_notified_time;
    p0_a68 := ddx_evt_regs_rec.event_join_time;
    p0_a69 := ddx_evt_regs_rec.event_exit_time;
    p0_a70 := ddx_evt_regs_rec.meeting_encryption_key_code;
  end;

  procedure complete_evtreg_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  NUMBER
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  DATE
    , p1_a13 OUT NOCOPY  NUMBER
    , p1_a14 OUT NOCOPY  DATE
    , p1_a15 OUT NOCOPY  VARCHAR2
    , p1_a16 OUT NOCOPY  NUMBER
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  VARCHAR2
    , p1_a19 OUT NOCOPY  NUMBER
    , p1_a20 OUT NOCOPY  NUMBER
    , p1_a21 OUT NOCOPY  NUMBER
    , p1_a22 OUT NOCOPY  NUMBER
    , p1_a23 OUT NOCOPY  NUMBER
    , p1_a24 OUT NOCOPY  NUMBER
    , p1_a25 OUT NOCOPY  NUMBER
    , p1_a26 OUT NOCOPY  NUMBER
    , p1_a27 OUT NOCOPY  VARCHAR2
    , p1_a28 OUT NOCOPY  VARCHAR2
    , p1_a29 OUT NOCOPY  VARCHAR2
    , p1_a30 OUT NOCOPY  VARCHAR2
    , p1_a31 OUT NOCOPY  VARCHAR2
    , p1_a32 OUT NOCOPY  VARCHAR2
    , p1_a33 OUT NOCOPY  NUMBER
    , p1_a34 OUT NOCOPY  NUMBER
    , p1_a35 OUT NOCOPY  NUMBER
    , p1_a36 OUT NOCOPY  NUMBER
    , p1_a37 OUT NOCOPY  VARCHAR2
    , p1_a38 OUT NOCOPY  VARCHAR2
    , p1_a39 OUT NOCOPY  VARCHAR2
    , p1_a40 OUT NOCOPY  VARCHAR2
    , p1_a41 OUT NOCOPY  NUMBER
    , p1_a42 OUT NOCOPY  NUMBER
    , p1_a43 OUT NOCOPY  NUMBER
    , p1_a44 OUT NOCOPY  VARCHAR2
    , p1_a45 OUT NOCOPY  VARCHAR2
    , p1_a46 OUT NOCOPY  VARCHAR2
    , p1_a47 OUT NOCOPY  VARCHAR2
    , p1_a48 OUT NOCOPY  VARCHAR2
    , p1_a49 OUT NOCOPY  VARCHAR2
    , p1_a50 OUT NOCOPY  VARCHAR2
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
    , p1_a67 OUT NOCOPY  DATE
    , p1_a68 OUT NOCOPY  DATE
    , p1_a69 OUT NOCOPY  DATE
    , p1_a70 OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a67  DATE := fnd_api.g_miss_date
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  DATE := fnd_api.g_miss_date
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_evt_regs_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddx_complete_rec ams_evtregs_pvt.evt_regs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_evt_regs_rec.event_registration_id := rosetta_g_miss_num_map(p0_a0);
    ddp_evt_regs_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_evt_regs_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_evt_regs_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_evt_regs_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_evt_regs_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_evt_regs_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_evt_regs_rec.event_offer_id := rosetta_g_miss_num_map(p0_a7);
    ddp_evt_regs_rec.application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_evt_regs_rec.active_flag := p0_a9;
    ddp_evt_regs_rec.owner_user_id := rosetta_g_miss_num_map(p0_a10);
    ddp_evt_regs_rec.system_status_code := p0_a11;
    ddp_evt_regs_rec.date_registration_placed := rosetta_g_miss_date_in_map(p0_a12);
    ddp_evt_regs_rec.user_status_id := rosetta_g_miss_num_map(p0_a13);
    ddp_evt_regs_rec.last_reg_status_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_evt_regs_rec.reg_source_type_code := p0_a15;
    ddp_evt_regs_rec.registration_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_evt_regs_rec.confirmation_code := p0_a17;
    ddp_evt_regs_rec.source_code := p0_a18;
    ddp_evt_regs_rec.registration_group_id := rosetta_g_miss_num_map(p0_a19);
    ddp_evt_regs_rec.registrant_party_id := rosetta_g_miss_num_map(p0_a20);
    ddp_evt_regs_rec.registrant_contact_id := rosetta_g_miss_num_map(p0_a21);
    ddp_evt_regs_rec.registrant_account_id := rosetta_g_miss_num_map(p0_a22);
    ddp_evt_regs_rec.attendant_party_id := rosetta_g_miss_num_map(p0_a23);
    ddp_evt_regs_rec.attendant_contact_id := rosetta_g_miss_num_map(p0_a24);
    ddp_evt_regs_rec.attendant_account_id := rosetta_g_miss_num_map(p0_a25);
    ddp_evt_regs_rec.original_registrant_contact_id := rosetta_g_miss_num_map(p0_a26);
    ddp_evt_regs_rec.prospect_flag := p0_a27;
    ddp_evt_regs_rec.attended_flag := p0_a28;
    ddp_evt_regs_rec.confirmed_flag := p0_a29;
    ddp_evt_regs_rec.evaluated_flag := p0_a30;
    ddp_evt_regs_rec.waitlisted_flag := p0_a31;
    ddp_evt_regs_rec.attendance_result_code := p0_a32;
    ddp_evt_regs_rec.waitlisted_priority := rosetta_g_miss_num_map(p0_a33);
    ddp_evt_regs_rec.target_list_id := rosetta_g_miss_num_map(p0_a34);
    ddp_evt_regs_rec.inbound_media_id := rosetta_g_miss_num_map(p0_a35);
    ddp_evt_regs_rec.inbound_channel_id := rosetta_g_miss_num_map(p0_a36);
    ddp_evt_regs_rec.cancellation_code := p0_a37;
    ddp_evt_regs_rec.cancellation_reason_code := p0_a38;
    ddp_evt_regs_rec.attendance_failure_reason := p0_a39;
    ddp_evt_regs_rec.attendant_language := p0_a40;
    ddp_evt_regs_rec.salesrep_id := rosetta_g_miss_num_map(p0_a41);
    ddp_evt_regs_rec.order_header_id := rosetta_g_miss_num_map(p0_a42);
    ddp_evt_regs_rec.order_line_id := rosetta_g_miss_num_map(p0_a43);
    ddp_evt_regs_rec.description := p0_a44;
    ddp_evt_regs_rec.max_attendee_override_flag := p0_a45;
    ddp_evt_regs_rec.invite_only_override_flag := p0_a46;
    ddp_evt_regs_rec.payment_status_code := p0_a47;
    ddp_evt_regs_rec.auto_register_flag := p0_a48;
    ddp_evt_regs_rec.attribute_category := p0_a49;
    ddp_evt_regs_rec.attribute1 := p0_a50;
    ddp_evt_regs_rec.attribute2 := p0_a51;
    ddp_evt_regs_rec.attribute3 := p0_a52;
    ddp_evt_regs_rec.attribute4 := p0_a53;
    ddp_evt_regs_rec.attribute5 := p0_a54;
    ddp_evt_regs_rec.attribute6 := p0_a55;
    ddp_evt_regs_rec.attribute7 := p0_a56;
    ddp_evt_regs_rec.attribute8 := p0_a57;
    ddp_evt_regs_rec.attribute9 := p0_a58;
    ddp_evt_regs_rec.attribute10 := p0_a59;
    ddp_evt_regs_rec.attribute11 := p0_a60;
    ddp_evt_regs_rec.attribute12 := p0_a61;
    ddp_evt_regs_rec.attribute13 := p0_a62;
    ddp_evt_regs_rec.attribute14 := p0_a63;
    ddp_evt_regs_rec.attribute15 := p0_a64;
    ddp_evt_regs_rec.attendee_role_type := p0_a65;
    ddp_evt_regs_rec.notification_type := p0_a66;
    ddp_evt_regs_rec.last_notified_time := rosetta_g_miss_date_in_map(p0_a67);
    ddp_evt_regs_rec.event_join_time := rosetta_g_miss_date_in_map(p0_a68);
    ddp_evt_regs_rec.event_exit_time := rosetta_g_miss_date_in_map(p0_a69);
    ddp_evt_regs_rec.meeting_encryption_key_code := p0_a70;


    -- here's the delegated call to the old PL/SQL routine
    ams_evtregs_pvt.complete_evtreg_rec(ddp_evt_regs_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.event_registration_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.event_offer_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.application_id);
    p1_a9 := ddx_complete_rec.active_flag;
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.owner_user_id);
    p1_a11 := ddx_complete_rec.system_status_code;
    p1_a12 := ddx_complete_rec.date_registration_placed;
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.user_status_id);
    p1_a14 := ddx_complete_rec.last_reg_status_date;
    p1_a15 := ddx_complete_rec.reg_source_type_code;
    p1_a16 := rosetta_g_miss_num_map(ddx_complete_rec.registration_source_id);
    p1_a17 := ddx_complete_rec.confirmation_code;
    p1_a18 := ddx_complete_rec.source_code;
    p1_a19 := rosetta_g_miss_num_map(ddx_complete_rec.registration_group_id);
    p1_a20 := rosetta_g_miss_num_map(ddx_complete_rec.registrant_party_id);
    p1_a21 := rosetta_g_miss_num_map(ddx_complete_rec.registrant_contact_id);
    p1_a22 := rosetta_g_miss_num_map(ddx_complete_rec.registrant_account_id);
    p1_a23 := rosetta_g_miss_num_map(ddx_complete_rec.attendant_party_id);
    p1_a24 := rosetta_g_miss_num_map(ddx_complete_rec.attendant_contact_id);
    p1_a25 := rosetta_g_miss_num_map(ddx_complete_rec.attendant_account_id);
    p1_a26 := rosetta_g_miss_num_map(ddx_complete_rec.original_registrant_contact_id);
    p1_a27 := ddx_complete_rec.prospect_flag;
    p1_a28 := ddx_complete_rec.attended_flag;
    p1_a29 := ddx_complete_rec.confirmed_flag;
    p1_a30 := ddx_complete_rec.evaluated_flag;
    p1_a31 := ddx_complete_rec.waitlisted_flag;
    p1_a32 := ddx_complete_rec.attendance_result_code;
    p1_a33 := rosetta_g_miss_num_map(ddx_complete_rec.waitlisted_priority);
    p1_a34 := rosetta_g_miss_num_map(ddx_complete_rec.target_list_id);
    p1_a35 := rosetta_g_miss_num_map(ddx_complete_rec.inbound_media_id);
    p1_a36 := rosetta_g_miss_num_map(ddx_complete_rec.inbound_channel_id);
    p1_a37 := ddx_complete_rec.cancellation_code;
    p1_a38 := ddx_complete_rec.cancellation_reason_code;
    p1_a39 := ddx_complete_rec.attendance_failure_reason;
    p1_a40 := ddx_complete_rec.attendant_language;
    p1_a41 := rosetta_g_miss_num_map(ddx_complete_rec.salesrep_id);
    p1_a42 := rosetta_g_miss_num_map(ddx_complete_rec.order_header_id);
    p1_a43 := rosetta_g_miss_num_map(ddx_complete_rec.order_line_id);
    p1_a44 := ddx_complete_rec.description;
    p1_a45 := ddx_complete_rec.max_attendee_override_flag;
    p1_a46 := ddx_complete_rec.invite_only_override_flag;
    p1_a47 := ddx_complete_rec.payment_status_code;
    p1_a48 := ddx_complete_rec.auto_register_flag;
    p1_a49 := ddx_complete_rec.attribute_category;
    p1_a50 := ddx_complete_rec.attribute1;
    p1_a51 := ddx_complete_rec.attribute2;
    p1_a52 := ddx_complete_rec.attribute3;
    p1_a53 := ddx_complete_rec.attribute4;
    p1_a54 := ddx_complete_rec.attribute5;
    p1_a55 := ddx_complete_rec.attribute6;
    p1_a56 := ddx_complete_rec.attribute7;
    p1_a57 := ddx_complete_rec.attribute8;
    p1_a58 := ddx_complete_rec.attribute9;
    p1_a59 := ddx_complete_rec.attribute10;
    p1_a60 := ddx_complete_rec.attribute11;
    p1_a61 := ddx_complete_rec.attribute12;
    p1_a62 := ddx_complete_rec.attribute13;
    p1_a63 := ddx_complete_rec.attribute14;
    p1_a64 := ddx_complete_rec.attribute15;
    p1_a65 := ddx_complete_rec.attendee_role_type;
    p1_a66 := ddx_complete_rec.notification_type;
    p1_a67 := ddx_complete_rec.last_notified_time;
    p1_a68 := ddx_complete_rec.event_join_time;
    p1_a69 := ddx_complete_rec.event_exit_time;
    p1_a70 := ddx_complete_rec.meeting_encryption_key_code;
  end;

end ams_evtregs_pvt_w;

/
