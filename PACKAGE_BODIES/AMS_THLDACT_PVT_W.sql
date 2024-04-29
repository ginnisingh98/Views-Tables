--------------------------------------------------------
--  DDL for Package Body AMS_THLDACT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_THLDACT_PVT_W" as
  /* $Header: amswthab.pls 115.1 2003/07/03 14:24:42 cgoyal noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure create_thldact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_trigger_action_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_thldact_rec.trigger_action_id := rosetta_g_miss_num_map(p7_a0);
    ddp_thldact_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_thldact_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_thldact_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_thldact_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_thldact_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_thldact_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_thldact_rec.process_id := rosetta_g_miss_num_map(p7_a7);
    ddp_thldact_rec.trigger_id := rosetta_g_miss_num_map(p7_a8);
    ddp_thldact_rec.order_number := rosetta_g_miss_num_map(p7_a9);
    ddp_thldact_rec.notify_flag := p7_a10;
    ddp_thldact_rec.generate_list_flag := p7_a11;
    ddp_thldact_rec.action_need_approval_flag := p7_a12;
    ddp_thldact_rec.action_approver_user_id := rosetta_g_miss_num_map(p7_a13);
    ddp_thldact_rec.execute_action_type := p7_a14;
    ddp_thldact_rec.list_header_id := rosetta_g_miss_num_map(p7_a15);
    ddp_thldact_rec.list_connected_to_id := rosetta_g_miss_num_map(p7_a16);
    ddp_thldact_rec.arc_list_connected_to := p7_a17;
    ddp_thldact_rec.deliverable_id := rosetta_g_miss_num_map(p7_a18);
    ddp_thldact_rec.activity_offer_id := rosetta_g_miss_num_map(p7_a19);
    ddp_thldact_rec.dscript_name := p7_a20;
    ddp_thldact_rec.program_to_call := p7_a21;
    ddp_thldact_rec.cover_letter_id := rosetta_g_miss_num_map(p7_a22);
    ddp_thldact_rec.mail_subject := p7_a23;
    ddp_thldact_rec.mail_sender_name := p7_a24;
    ddp_thldact_rec.from_fax_no := p7_a25;
    ddp_thldact_rec.action_for_id := rosetta_g_miss_num_map(p7_a26);


    -- here's the delegated call to the old PL/SQL routine
    ams_thldact_pvt.create_thldact(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_thldact_rec,
      x_trigger_action_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_thldact(p_api_version  NUMBER
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
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_thldact_rec.trigger_action_id := rosetta_g_miss_num_map(p7_a0);
    ddp_thldact_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_thldact_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_thldact_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_thldact_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_thldact_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_thldact_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_thldact_rec.process_id := rosetta_g_miss_num_map(p7_a7);
    ddp_thldact_rec.trigger_id := rosetta_g_miss_num_map(p7_a8);
    ddp_thldact_rec.order_number := rosetta_g_miss_num_map(p7_a9);
    ddp_thldact_rec.notify_flag := p7_a10;
    ddp_thldact_rec.generate_list_flag := p7_a11;
    ddp_thldact_rec.action_need_approval_flag := p7_a12;
    ddp_thldact_rec.action_approver_user_id := rosetta_g_miss_num_map(p7_a13);
    ddp_thldact_rec.execute_action_type := p7_a14;
    ddp_thldact_rec.list_header_id := rosetta_g_miss_num_map(p7_a15);
    ddp_thldact_rec.list_connected_to_id := rosetta_g_miss_num_map(p7_a16);
    ddp_thldact_rec.arc_list_connected_to := p7_a17;
    ddp_thldact_rec.deliverable_id := rosetta_g_miss_num_map(p7_a18);
    ddp_thldact_rec.activity_offer_id := rosetta_g_miss_num_map(p7_a19);
    ddp_thldact_rec.dscript_name := p7_a20;
    ddp_thldact_rec.program_to_call := p7_a21;
    ddp_thldact_rec.cover_letter_id := rosetta_g_miss_num_map(p7_a22);
    ddp_thldact_rec.mail_subject := p7_a23;
    ddp_thldact_rec.mail_sender_name := p7_a24;
    ddp_thldact_rec.from_fax_no := p7_a25;
    ddp_thldact_rec.action_for_id := rosetta_g_miss_num_map(p7_a26);

    -- here's the delegated call to the old PL/SQL routine
    ams_thldact_pvt.update_thldact(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_thldact_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_thldact(p_api_version  NUMBER
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
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_thldact_rec.trigger_action_id := rosetta_g_miss_num_map(p6_a0);
    ddp_thldact_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_thldact_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_thldact_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_thldact_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_thldact_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_thldact_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_thldact_rec.process_id := rosetta_g_miss_num_map(p6_a7);
    ddp_thldact_rec.trigger_id := rosetta_g_miss_num_map(p6_a8);
    ddp_thldact_rec.order_number := rosetta_g_miss_num_map(p6_a9);
    ddp_thldact_rec.notify_flag := p6_a10;
    ddp_thldact_rec.generate_list_flag := p6_a11;
    ddp_thldact_rec.action_need_approval_flag := p6_a12;
    ddp_thldact_rec.action_approver_user_id := rosetta_g_miss_num_map(p6_a13);
    ddp_thldact_rec.execute_action_type := p6_a14;
    ddp_thldact_rec.list_header_id := rosetta_g_miss_num_map(p6_a15);
    ddp_thldact_rec.list_connected_to_id := rosetta_g_miss_num_map(p6_a16);
    ddp_thldact_rec.arc_list_connected_to := p6_a17;
    ddp_thldact_rec.deliverable_id := rosetta_g_miss_num_map(p6_a18);
    ddp_thldact_rec.activity_offer_id := rosetta_g_miss_num_map(p6_a19);
    ddp_thldact_rec.dscript_name := p6_a20;
    ddp_thldact_rec.program_to_call := p6_a21;
    ddp_thldact_rec.cover_letter_id := rosetta_g_miss_num_map(p6_a22);
    ddp_thldact_rec.mail_subject := p6_a23;
    ddp_thldact_rec.mail_sender_name := p6_a24;
    ddp_thldact_rec.from_fax_no := p6_a25;
    ddp_thldact_rec.action_for_id := rosetta_g_miss_num_map(p6_a26);

    -- here's the delegated call to the old PL/SQL routine
    ams_thldact_pvt.validate_thldact(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_thldact_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_thldact_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_thldact_rec.trigger_action_id := rosetta_g_miss_num_map(p0_a0);
    ddp_thldact_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_thldact_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_thldact_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_thldact_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_thldact_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_thldact_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_thldact_rec.process_id := rosetta_g_miss_num_map(p0_a7);
    ddp_thldact_rec.trigger_id := rosetta_g_miss_num_map(p0_a8);
    ddp_thldact_rec.order_number := rosetta_g_miss_num_map(p0_a9);
    ddp_thldact_rec.notify_flag := p0_a10;
    ddp_thldact_rec.generate_list_flag := p0_a11;
    ddp_thldact_rec.action_need_approval_flag := p0_a12;
    ddp_thldact_rec.action_approver_user_id := rosetta_g_miss_num_map(p0_a13);
    ddp_thldact_rec.execute_action_type := p0_a14;
    ddp_thldact_rec.list_header_id := rosetta_g_miss_num_map(p0_a15);
    ddp_thldact_rec.list_connected_to_id := rosetta_g_miss_num_map(p0_a16);
    ddp_thldact_rec.arc_list_connected_to := p0_a17;
    ddp_thldact_rec.deliverable_id := rosetta_g_miss_num_map(p0_a18);
    ddp_thldact_rec.activity_offer_id := rosetta_g_miss_num_map(p0_a19);
    ddp_thldact_rec.dscript_name := p0_a20;
    ddp_thldact_rec.program_to_call := p0_a21;
    ddp_thldact_rec.cover_letter_id := rosetta_g_miss_num_map(p0_a22);
    ddp_thldact_rec.mail_subject := p0_a23;
    ddp_thldact_rec.mail_sender_name := p0_a24;
    ddp_thldact_rec.from_fax_no := p0_a25;
    ddp_thldact_rec.action_for_id := rosetta_g_miss_num_map(p0_a26);



    -- here's the delegated call to the old PL/SQL routine
    ams_thldact_pvt.check_thldact_items(ddp_thldact_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_thldact_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  NUMBER := 0-1962.0724
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  NUMBER := 0-1962.0724
    , p1_a19  NUMBER := 0-1962.0724
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  NUMBER := 0-1962.0724
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddp_complete_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_thldact_rec.trigger_action_id := rosetta_g_miss_num_map(p0_a0);
    ddp_thldact_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_thldact_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_thldact_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_thldact_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_thldact_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_thldact_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_thldact_rec.process_id := rosetta_g_miss_num_map(p0_a7);
    ddp_thldact_rec.trigger_id := rosetta_g_miss_num_map(p0_a8);
    ddp_thldact_rec.order_number := rosetta_g_miss_num_map(p0_a9);
    ddp_thldact_rec.notify_flag := p0_a10;
    ddp_thldact_rec.generate_list_flag := p0_a11;
    ddp_thldact_rec.action_need_approval_flag := p0_a12;
    ddp_thldact_rec.action_approver_user_id := rosetta_g_miss_num_map(p0_a13);
    ddp_thldact_rec.execute_action_type := p0_a14;
    ddp_thldact_rec.list_header_id := rosetta_g_miss_num_map(p0_a15);
    ddp_thldact_rec.list_connected_to_id := rosetta_g_miss_num_map(p0_a16);
    ddp_thldact_rec.arc_list_connected_to := p0_a17;
    ddp_thldact_rec.deliverable_id := rosetta_g_miss_num_map(p0_a18);
    ddp_thldact_rec.activity_offer_id := rosetta_g_miss_num_map(p0_a19);
    ddp_thldact_rec.dscript_name := p0_a20;
    ddp_thldact_rec.program_to_call := p0_a21;
    ddp_thldact_rec.cover_letter_id := rosetta_g_miss_num_map(p0_a22);
    ddp_thldact_rec.mail_subject := p0_a23;
    ddp_thldact_rec.mail_sender_name := p0_a24;
    ddp_thldact_rec.from_fax_no := p0_a25;
    ddp_thldact_rec.action_for_id := rosetta_g_miss_num_map(p0_a26);

    ddp_complete_rec.trigger_action_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.process_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.trigger_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.order_number := rosetta_g_miss_num_map(p1_a9);
    ddp_complete_rec.notify_flag := p1_a10;
    ddp_complete_rec.generate_list_flag := p1_a11;
    ddp_complete_rec.action_need_approval_flag := p1_a12;
    ddp_complete_rec.action_approver_user_id := rosetta_g_miss_num_map(p1_a13);
    ddp_complete_rec.execute_action_type := p1_a14;
    ddp_complete_rec.list_header_id := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.list_connected_to_id := rosetta_g_miss_num_map(p1_a16);
    ddp_complete_rec.arc_list_connected_to := p1_a17;
    ddp_complete_rec.deliverable_id := rosetta_g_miss_num_map(p1_a18);
    ddp_complete_rec.activity_offer_id := rosetta_g_miss_num_map(p1_a19);
    ddp_complete_rec.dscript_name := p1_a20;
    ddp_complete_rec.program_to_call := p1_a21;
    ddp_complete_rec.cover_letter_id := rosetta_g_miss_num_map(p1_a22);
    ddp_complete_rec.mail_subject := p1_a23;
    ddp_complete_rec.mail_sender_name := p1_a24;
    ddp_complete_rec.from_fax_no := p1_a25;
    ddp_complete_rec.action_for_id := rosetta_g_miss_num_map(p1_a26);


    -- here's the delegated call to the old PL/SQL routine
    ams_thldact_pvt.check_thldact_record(ddp_thldact_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_thldact_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  NUMBER
  )

  as
    ddx_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_thldact_pvt.init_thldact_rec(ddx_thldact_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_thldact_rec.trigger_action_id);
    p0_a1 := ddx_thldact_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_thldact_rec.last_updated_by);
    p0_a3 := ddx_thldact_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_thldact_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_thldact_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_thldact_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_thldact_rec.process_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_thldact_rec.trigger_id);
    p0_a9 := rosetta_g_miss_num_map(ddx_thldact_rec.order_number);
    p0_a10 := ddx_thldact_rec.notify_flag;
    p0_a11 := ddx_thldact_rec.generate_list_flag;
    p0_a12 := ddx_thldact_rec.action_need_approval_flag;
    p0_a13 := rosetta_g_miss_num_map(ddx_thldact_rec.action_approver_user_id);
    p0_a14 := ddx_thldact_rec.execute_action_type;
    p0_a15 := rosetta_g_miss_num_map(ddx_thldact_rec.list_header_id);
    p0_a16 := rosetta_g_miss_num_map(ddx_thldact_rec.list_connected_to_id);
    p0_a17 := ddx_thldact_rec.arc_list_connected_to;
    p0_a18 := rosetta_g_miss_num_map(ddx_thldact_rec.deliverable_id);
    p0_a19 := rosetta_g_miss_num_map(ddx_thldact_rec.activity_offer_id);
    p0_a20 := ddx_thldact_rec.dscript_name;
    p0_a21 := ddx_thldact_rec.program_to_call;
    p0_a22 := rosetta_g_miss_num_map(ddx_thldact_rec.cover_letter_id);
    p0_a23 := ddx_thldact_rec.mail_subject;
    p0_a24 := ddx_thldact_rec.mail_sender_name;
    p0_a25 := ddx_thldact_rec.from_fax_no;
    p0_a26 := rosetta_g_miss_num_map(ddx_thldact_rec.action_for_id);
  end;

  procedure complete_thldact_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
  )

  as
    ddp_thldact_rec ams_thldact_pvt.thldact_rec_type;
    ddx_complete_rec ams_thldact_pvt.thldact_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_thldact_rec.trigger_action_id := rosetta_g_miss_num_map(p0_a0);
    ddp_thldact_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_thldact_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_thldact_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_thldact_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_thldact_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_thldact_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_thldact_rec.process_id := rosetta_g_miss_num_map(p0_a7);
    ddp_thldact_rec.trigger_id := rosetta_g_miss_num_map(p0_a8);
    ddp_thldact_rec.order_number := rosetta_g_miss_num_map(p0_a9);
    ddp_thldact_rec.notify_flag := p0_a10;
    ddp_thldact_rec.generate_list_flag := p0_a11;
    ddp_thldact_rec.action_need_approval_flag := p0_a12;
    ddp_thldact_rec.action_approver_user_id := rosetta_g_miss_num_map(p0_a13);
    ddp_thldact_rec.execute_action_type := p0_a14;
    ddp_thldact_rec.list_header_id := rosetta_g_miss_num_map(p0_a15);
    ddp_thldact_rec.list_connected_to_id := rosetta_g_miss_num_map(p0_a16);
    ddp_thldact_rec.arc_list_connected_to := p0_a17;
    ddp_thldact_rec.deliverable_id := rosetta_g_miss_num_map(p0_a18);
    ddp_thldact_rec.activity_offer_id := rosetta_g_miss_num_map(p0_a19);
    ddp_thldact_rec.dscript_name := p0_a20;
    ddp_thldact_rec.program_to_call := p0_a21;
    ddp_thldact_rec.cover_letter_id := rosetta_g_miss_num_map(p0_a22);
    ddp_thldact_rec.mail_subject := p0_a23;
    ddp_thldact_rec.mail_sender_name := p0_a24;
    ddp_thldact_rec.from_fax_no := p0_a25;
    ddp_thldact_rec.action_for_id := rosetta_g_miss_num_map(p0_a26);


    -- here's the delegated call to the old PL/SQL routine
    ams_thldact_pvt.complete_thldact_rec(ddp_thldact_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.trigger_action_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.process_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.trigger_id);
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.order_number);
    p1_a10 := ddx_complete_rec.notify_flag;
    p1_a11 := ddx_complete_rec.generate_list_flag;
    p1_a12 := ddx_complete_rec.action_need_approval_flag;
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.action_approver_user_id);
    p1_a14 := ddx_complete_rec.execute_action_type;
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.list_header_id);
    p1_a16 := rosetta_g_miss_num_map(ddx_complete_rec.list_connected_to_id);
    p1_a17 := ddx_complete_rec.arc_list_connected_to;
    p1_a18 := rosetta_g_miss_num_map(ddx_complete_rec.deliverable_id);
    p1_a19 := rosetta_g_miss_num_map(ddx_complete_rec.activity_offer_id);
    p1_a20 := ddx_complete_rec.dscript_name;
    p1_a21 := ddx_complete_rec.program_to_call;
    p1_a22 := rosetta_g_miss_num_map(ddx_complete_rec.cover_letter_id);
    p1_a23 := ddx_complete_rec.mail_subject;
    p1_a24 := ddx_complete_rec.mail_sender_name;
    p1_a25 := ddx_complete_rec.from_fax_no;
    p1_a26 := rosetta_g_miss_num_map(ddx_complete_rec.action_for_id);
  end;

end ams_thldact_pvt_w;

/
