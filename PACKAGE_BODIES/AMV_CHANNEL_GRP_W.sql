--------------------------------------------------------
--  DDL for Package Body AMV_CHANNEL_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CHANNEL_GRP_W" as
  /* $Header: amvwchgb.pls 120.2 2005/06/30 07:51 appldev ship $ */
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

  procedure add_publicchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , x_channel_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.add_publicchannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure add_protectedchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , x_channel_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.add_protectedchannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure add_privatechannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , x_channel_id out nocopy  NUMBER
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.add_privatechannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure add_groupchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_group_id  NUMBER
    , x_channel_id out nocopy  NUMBER
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  DATE := fnd_api.g_miss_date
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  VARCHAR2 := fnd_api.g_miss_char
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  VARCHAR2 := fnd_api.g_miss_char
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  DATE := fnd_api.g_miss_date
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  DATE := fnd_api.g_miss_date
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p9_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p9_a1);
    ddp_channel_record.channel_name := p9_a2;
    ddp_channel_record.description := p9_a3;
    ddp_channel_record.channel_type := p9_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p9_a5);
    ddp_channel_record.status := p9_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p9_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p9_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p9_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p9_a10);
    ddp_channel_record.access_level_type := p9_a11;
    ddp_channel_record.pub_need_approval_flag := p9_a12;
    ddp_channel_record.sub_need_approval_flag := p9_a13;
    ddp_channel_record.match_on_all_criteria_flag := p9_a14;
    ddp_channel_record.match_on_keyword_flag := p9_a15;
    ddp_channel_record.match_on_author_flag := p9_a16;
    ddp_channel_record.match_on_perspective_flag := p9_a17;
    ddp_channel_record.match_on_item_type_flag := p9_a18;
    ddp_channel_record.match_on_content_type_flag := p9_a19;
    ddp_channel_record.match_on_time_flag := p9_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p9_a21);
    ddp_channel_record.external_access_flag := p9_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p9_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p9_a24);
    ddp_channel_record.notification_interval_type := p9_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p9_a26);
    ddp_channel_record.attribute_category := p9_a27;
    ddp_channel_record.attribute1 := p9_a28;
    ddp_channel_record.attribute2 := p9_a29;
    ddp_channel_record.attribute3 := p9_a30;
    ddp_channel_record.attribute4 := p9_a31;
    ddp_channel_record.attribute5 := p9_a32;
    ddp_channel_record.attribute6 := p9_a33;
    ddp_channel_record.attribute7 := p9_a34;
    ddp_channel_record.attribute8 := p9_a35;
    ddp_channel_record.attribute9 := p9_a36;
    ddp_channel_record.attribute10 := p9_a37;
    ddp_channel_record.attribute11 := p9_a38;
    ddp_channel_record.attribute12 := p9_a39;
    ddp_channel_record.attribute13 := p9_a40;
    ddp_channel_record.attribute14 := p9_a41;
    ddp_channel_record.attribute15 := p9_a42;


    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.add_groupchannel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_group_id,
      ddp_channel_record,
      x_channel_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_channel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  VARCHAR2 := fnd_api.g_miss_char
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  NUMBER := 0-1962.0724
    , p8_a8  NUMBER := 0-1962.0724
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  DATE := fnd_api.g_miss_date
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  VARCHAR2 := fnd_api.g_miss_char
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  VARCHAR2 := fnd_api.g_miss_char
    , p8_a17  VARCHAR2 := fnd_api.g_miss_char
    , p8_a18  VARCHAR2 := fnd_api.g_miss_char
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  DATE := fnd_api.g_miss_date
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  DATE := fnd_api.g_miss_date
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  VARCHAR2 := fnd_api.g_miss_char
    , p8_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_channel_record.channel_id := rosetta_g_miss_num_map(p8_a0);
    ddp_channel_record.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_channel_record.channel_name := p8_a2;
    ddp_channel_record.description := p8_a3;
    ddp_channel_record.channel_type := p8_a4;
    ddp_channel_record.channel_category_id := rosetta_g_miss_num_map(p8_a5);
    ddp_channel_record.status := p8_a6;
    ddp_channel_record.owner_user_id := rosetta_g_miss_num_map(p8_a7);
    ddp_channel_record.default_approver_user_id := rosetta_g_miss_num_map(p8_a8);
    ddp_channel_record.effective_start_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_channel_record.expiration_date := rosetta_g_miss_date_in_map(p8_a10);
    ddp_channel_record.access_level_type := p8_a11;
    ddp_channel_record.pub_need_approval_flag := p8_a12;
    ddp_channel_record.sub_need_approval_flag := p8_a13;
    ddp_channel_record.match_on_all_criteria_flag := p8_a14;
    ddp_channel_record.match_on_keyword_flag := p8_a15;
    ddp_channel_record.match_on_author_flag := p8_a16;
    ddp_channel_record.match_on_perspective_flag := p8_a17;
    ddp_channel_record.match_on_item_type_flag := p8_a18;
    ddp_channel_record.match_on_content_type_flag := p8_a19;
    ddp_channel_record.match_on_time_flag := p8_a20;
    ddp_channel_record.application_id := rosetta_g_miss_num_map(p8_a21);
    ddp_channel_record.external_access_flag := p8_a22;
    ddp_channel_record.item_match_count := rosetta_g_miss_num_map(p8_a23);
    ddp_channel_record.last_match_time := rosetta_g_miss_date_in_map(p8_a24);
    ddp_channel_record.notification_interval_type := p8_a25;
    ddp_channel_record.last_notification_time := rosetta_g_miss_date_in_map(p8_a26);
    ddp_channel_record.attribute_category := p8_a27;
    ddp_channel_record.attribute1 := p8_a28;
    ddp_channel_record.attribute2 := p8_a29;
    ddp_channel_record.attribute3 := p8_a30;
    ddp_channel_record.attribute4 := p8_a31;
    ddp_channel_record.attribute5 := p8_a32;
    ddp_channel_record.attribute6 := p8_a33;
    ddp_channel_record.attribute7 := p8_a34;
    ddp_channel_record.attribute8 := p8_a35;
    ddp_channel_record.attribute9 := p8_a36;
    ddp_channel_record.attribute10 := p8_a37;
    ddp_channel_record.attribute11 := p8_a38;
    ddp_channel_record.attribute12 := p8_a39;
    ddp_channel_record.attribute13 := p8_a40;
    ddp_channel_record.attribute14 := p8_a41;
    ddp_channel_record.attribute15 := p8_a42;

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.update_channel(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_channel_record);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure get_channel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  NUMBER
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  DATE
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  VARCHAR2
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  NUMBER
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  NUMBER
    , p10_a24 out nocopy  DATE
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  DATE
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  VARCHAR2
    , p10_a34 out nocopy  VARCHAR2
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  VARCHAR2
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  VARCHAR2
  )

  as
    ddx_channel_record amv_channel_pvt.amv_channel_obj_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.get_channel(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_channel_record);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_channel_record.channel_id);
    p10_a1 := rosetta_g_miss_num_map(ddx_channel_record.object_version_number);
    p10_a2 := ddx_channel_record.channel_name;
    p10_a3 := ddx_channel_record.description;
    p10_a4 := ddx_channel_record.channel_type;
    p10_a5 := rosetta_g_miss_num_map(ddx_channel_record.channel_category_id);
    p10_a6 := ddx_channel_record.status;
    p10_a7 := rosetta_g_miss_num_map(ddx_channel_record.owner_user_id);
    p10_a8 := rosetta_g_miss_num_map(ddx_channel_record.default_approver_user_id);
    p10_a9 := ddx_channel_record.effective_start_date;
    p10_a10 := ddx_channel_record.expiration_date;
    p10_a11 := ddx_channel_record.access_level_type;
    p10_a12 := ddx_channel_record.pub_need_approval_flag;
    p10_a13 := ddx_channel_record.sub_need_approval_flag;
    p10_a14 := ddx_channel_record.match_on_all_criteria_flag;
    p10_a15 := ddx_channel_record.match_on_keyword_flag;
    p10_a16 := ddx_channel_record.match_on_author_flag;
    p10_a17 := ddx_channel_record.match_on_perspective_flag;
    p10_a18 := ddx_channel_record.match_on_item_type_flag;
    p10_a19 := ddx_channel_record.match_on_content_type_flag;
    p10_a20 := ddx_channel_record.match_on_time_flag;
    p10_a21 := rosetta_g_miss_num_map(ddx_channel_record.application_id);
    p10_a22 := ddx_channel_record.external_access_flag;
    p10_a23 := rosetta_g_miss_num_map(ddx_channel_record.item_match_count);
    p10_a24 := ddx_channel_record.last_match_time;
    p10_a25 := ddx_channel_record.notification_interval_type;
    p10_a26 := ddx_channel_record.last_notification_time;
    p10_a27 := ddx_channel_record.attribute_category;
    p10_a28 := ddx_channel_record.attribute1;
    p10_a29 := ddx_channel_record.attribute2;
    p10_a30 := ddx_channel_record.attribute3;
    p10_a31 := ddx_channel_record.attribute4;
    p10_a32 := ddx_channel_record.attribute5;
    p10_a33 := ddx_channel_record.attribute6;
    p10_a34 := ddx_channel_record.attribute7;
    p10_a35 := ddx_channel_record.attribute8;
    p10_a36 := ddx_channel_record.attribute9;
    p10_a37 := ddx_channel_record.attribute10;
    p10_a38 := ddx_channel_record.attribute11;
    p10_a39 := ddx_channel_record.attribute12;
    p10_a40 := ddx_channel_record.attribute13;
    p10_a41 := ddx_channel_record.attribute14;
    p10_a42 := ddx_channel_record.attribute15;
  end;

  procedure set_channelcontenttypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_content_type_id_array JTF_NUMBER_TABLE
  )

  as
    ddp_content_type_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p1(ddp_content_type_id_array, p_content_type_id_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.set_channelcontenttypes(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_content_type_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelcontenttypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_content_type_id_array out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_content_type_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.get_channelcontenttypes(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_content_type_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p1(ddx_content_type_id_array, x_content_type_id_array);
  end;

  procedure set_channelperspectives(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_perspective_id_array JTF_NUMBER_TABLE
  )

  as
    ddp_perspective_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p1(ddp_perspective_id_array, p_perspective_id_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.set_channelperspectives(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_perspective_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelperspectives(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_perspective_id_array out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_perspective_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.get_channelperspectives(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_perspective_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p1(ddx_perspective_id_array, x_perspective_id_array);
  end;

  procedure set_channelitemtypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_item_type_array JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_item_type_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p0(ddp_item_type_array, p_item_type_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.set_channelitemtypes(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_item_type_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelitemtypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_item_type_array out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_item_type_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.get_channelitemtypes(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_item_type_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p0(ddx_item_type_array, x_item_type_array);
  end;

  procedure set_channelkeywords(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_keywords_array JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_keywords_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p0(ddp_keywords_array, p_keywords_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.set_channelkeywords(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_keywords_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelkeywords(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_keywords_array out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_keywords_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.get_channelkeywords(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_keywords_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p0(ddx_keywords_array, x_keywords_array);
  end;

  procedure set_channelauthors(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p_authors_array JTF_VARCHAR2_TABLE_4000
  )

  as
    ddp_authors_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    amv_channel_pvt_w.rosetta_table_copy_in_p0(ddp_authors_array, p_authors_array);

    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.set_channelauthors(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_authors_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_channelauthors(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , x_authors_array out nocopy JTF_VARCHAR2_TABLE_4000
  )

  as
    ddx_authors_array amv_channel_pvt.amv_char_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.get_channelauthors(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddx_authors_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    amv_channel_pvt_w.rosetta_table_copy_out_p0(ddx_authors_array, x_authors_array);
  end;

  procedure get_itemsperchannel(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_channel_id  NUMBER
    , p_channel_name  VARCHAR2
    , p_category_id  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  NUMBER
    , x_document_id_array out nocopy JTF_NUMBER_TABLE
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_subset_request_rec amv_channel_pvt.amv_request_obj_type;
    ddx_subset_return_rec amv_channel_pvt.amv_return_obj_type;
    ddx_document_id_array amv_channel_pvt.amv_number_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_subset_request_rec.records_requested := rosetta_g_miss_num_map(p10_a0);
    ddp_subset_request_rec.start_record_position := rosetta_g_miss_num_map(p10_a1);
    ddp_subset_request_rec.return_total_count_flag := p10_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.get_itemsperchannel(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      p_channel_id,
      p_channel_name,
      p_category_id,
      ddp_subset_request_rec,
      ddx_subset_return_rec,
      ddx_document_id_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := rosetta_g_miss_num_map(ddx_subset_return_rec.returned_record_count);
    p11_a1 := rosetta_g_miss_num_map(ddx_subset_return_rec.next_record_position);
    p11_a2 := rosetta_g_miss_num_map(ddx_subset_return_rec.total_record_count);

    amv_channel_pvt_w.rosetta_table_copy_out_p1(ddx_document_id_array, x_document_id_array);
  end;

  procedure find_channels(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_check_login_user  VARCHAR2
    , p_sort_by  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_NUMBER_TABLE
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_NUMBER_TABLE
    , p11_a8 out nocopy JTF_NUMBER_TABLE
    , p11_a9 out nocopy JTF_DATE_TABLE
    , p11_a10 out nocopy JTF_DATE_TABLE
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a21 out nocopy JTF_NUMBER_TABLE
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a23 out nocopy JTF_NUMBER_TABLE
    , p11_a24 out nocopy JTF_DATE_TABLE
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a26 out nocopy JTF_DATE_TABLE
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p11_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  DATE := fnd_api.g_miss_date
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_criteria_rec amv_channel_pvt.amv_channel_obj_type;
    ddp_subset_request_rec amv_channel_pvt.amv_request_obj_type;
    ddx_subset_return_rec amv_channel_pvt.amv_return_obj_type;
    ddx_content_chan_array amv_channel_pvt.amv_channel_varray_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_criteria_rec.channel_id := rosetta_g_miss_num_map(p7_a0);
    ddp_criteria_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_criteria_rec.channel_name := p7_a2;
    ddp_criteria_rec.description := p7_a3;
    ddp_criteria_rec.channel_type := p7_a4;
    ddp_criteria_rec.channel_category_id := rosetta_g_miss_num_map(p7_a5);
    ddp_criteria_rec.status := p7_a6;
    ddp_criteria_rec.owner_user_id := rosetta_g_miss_num_map(p7_a7);
    ddp_criteria_rec.default_approver_user_id := rosetta_g_miss_num_map(p7_a8);
    ddp_criteria_rec.effective_start_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_criteria_rec.expiration_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_criteria_rec.access_level_type := p7_a11;
    ddp_criteria_rec.pub_need_approval_flag := p7_a12;
    ddp_criteria_rec.sub_need_approval_flag := p7_a13;
    ddp_criteria_rec.match_on_all_criteria_flag := p7_a14;
    ddp_criteria_rec.match_on_keyword_flag := p7_a15;
    ddp_criteria_rec.match_on_author_flag := p7_a16;
    ddp_criteria_rec.match_on_perspective_flag := p7_a17;
    ddp_criteria_rec.match_on_item_type_flag := p7_a18;
    ddp_criteria_rec.match_on_content_type_flag := p7_a19;
    ddp_criteria_rec.match_on_time_flag := p7_a20;
    ddp_criteria_rec.application_id := rosetta_g_miss_num_map(p7_a21);
    ddp_criteria_rec.external_access_flag := p7_a22;
    ddp_criteria_rec.item_match_count := rosetta_g_miss_num_map(p7_a23);
    ddp_criteria_rec.last_match_time := rosetta_g_miss_date_in_map(p7_a24);
    ddp_criteria_rec.notification_interval_type := p7_a25;
    ddp_criteria_rec.last_notification_time := rosetta_g_miss_date_in_map(p7_a26);
    ddp_criteria_rec.attribute_category := p7_a27;
    ddp_criteria_rec.attribute1 := p7_a28;
    ddp_criteria_rec.attribute2 := p7_a29;
    ddp_criteria_rec.attribute3 := p7_a30;
    ddp_criteria_rec.attribute4 := p7_a31;
    ddp_criteria_rec.attribute5 := p7_a32;
    ddp_criteria_rec.attribute6 := p7_a33;
    ddp_criteria_rec.attribute7 := p7_a34;
    ddp_criteria_rec.attribute8 := p7_a35;
    ddp_criteria_rec.attribute9 := p7_a36;
    ddp_criteria_rec.attribute10 := p7_a37;
    ddp_criteria_rec.attribute11 := p7_a38;
    ddp_criteria_rec.attribute12 := p7_a39;
    ddp_criteria_rec.attribute13 := p7_a40;
    ddp_criteria_rec.attribute14 := p7_a41;
    ddp_criteria_rec.attribute15 := p7_a42;


    ddp_subset_request_rec.records_requested := rosetta_g_miss_num_map(p9_a0);
    ddp_subset_request_rec.start_record_position := rosetta_g_miss_num_map(p9_a1);
    ddp_subset_request_rec.return_total_count_flag := p9_a2;



    -- here's the delegated call to the old PL/SQL routine
    amv_channel_grp.find_channels(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_check_login_user,
      ddp_criteria_rec,
      p_sort_by,
      ddp_subset_request_rec,
      ddx_subset_return_rec,
      ddx_content_chan_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_subset_return_rec.returned_record_count);
    p10_a1 := rosetta_g_miss_num_map(ddx_subset_return_rec.next_record_position);
    p10_a2 := rosetta_g_miss_num_map(ddx_subset_return_rec.total_record_count);

    amv_channel_pvt_w.rosetta_table_copy_out_p5(ddx_content_chan_array, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      );
  end;

end amv_channel_grp_w;

/
