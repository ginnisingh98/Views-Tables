--------------------------------------------------------
--  DDL for Package Body AMS_ACCESS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACCESS_PVT_W" as
  /* $Header: amswaccb.pls 120.1 2005/09/14 13:04:30 anskumar noship $ */
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

  procedure create_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_access_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_access_rec.activity_access_id := rosetta_g_miss_num_map(p7_a0);
    ddp_access_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_access_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_access_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_access_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_access_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_access_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_access_rec.act_access_to_object_id := rosetta_g_miss_num_map(p7_a7);
    ddp_access_rec.arc_act_access_to_object := p7_a8;
    ddp_access_rec.user_or_role_id := rosetta_g_miss_num_map(p7_a9);
    ddp_access_rec.arc_user_or_role_type := p7_a10;
    ddp_access_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_access_rec.admin_flag := p7_a12;
    ddp_access_rec.approver_flag := p7_a13;
    ddp_access_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_access_rec.owner_flag := p7_a15;
    ddp_access_rec.delete_flag := p7_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.create_access(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_access_rec,
      x_access_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_access(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  DATE := fnd_api.g_miss_date
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_access_rec.activity_access_id := rosetta_g_miss_num_map(p7_a0);
    ddp_access_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_access_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_access_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_access_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_access_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_access_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_access_rec.act_access_to_object_id := rosetta_g_miss_num_map(p7_a7);
    ddp_access_rec.arc_act_access_to_object := p7_a8;
    ddp_access_rec.user_or_role_id := rosetta_g_miss_num_map(p7_a9);
    ddp_access_rec.arc_user_or_role_type := p7_a10;
    ddp_access_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_access_rec.admin_flag := p7_a12;
    ddp_access_rec.approver_flag := p7_a13;
    ddp_access_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a14);
    ddp_access_rec.owner_flag := p7_a15;
    ddp_access_rec.delete_flag := p7_a16;

    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.update_access(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_access_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_access(p_api_version  NUMBER
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
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_access_rec.activity_access_id := rosetta_g_miss_num_map(p6_a0);
    ddp_access_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_access_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_access_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_access_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_access_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_access_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_access_rec.act_access_to_object_id := rosetta_g_miss_num_map(p6_a7);
    ddp_access_rec.arc_act_access_to_object := p6_a8;
    ddp_access_rec.user_or_role_id := rosetta_g_miss_num_map(p6_a9);
    ddp_access_rec.arc_user_or_role_type := p6_a10;
    ddp_access_rec.active_from_date := rosetta_g_miss_date_in_map(p6_a11);
    ddp_access_rec.admin_flag := p6_a12;
    ddp_access_rec.approver_flag := p6_a13;
    ddp_access_rec.active_to_date := rosetta_g_miss_date_in_map(p6_a14);
    ddp_access_rec.owner_flag := p6_a15;
    ddp_access_rec.delete_flag := p6_a16;

    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.validate_access(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_access_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_access_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_access_rec.activity_access_id := rosetta_g_miss_num_map(p0_a0);
    ddp_access_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_access_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_access_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_access_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_access_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_access_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_access_rec.act_access_to_object_id := rosetta_g_miss_num_map(p0_a7);
    ddp_access_rec.arc_act_access_to_object := p0_a8;
    ddp_access_rec.user_or_role_id := rosetta_g_miss_num_map(p0_a9);
    ddp_access_rec.arc_user_or_role_type := p0_a10;
    ddp_access_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_access_rec.admin_flag := p0_a12;
    ddp_access_rec.approver_flag := p0_a13;
    ddp_access_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_access_rec.owner_flag := p0_a15;
    ddp_access_rec.delete_flag := p0_a16;



    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.check_access_items(ddp_access_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_access_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  DATE := fnd_api.g_miss_date
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  DATE := fnd_api.g_miss_date
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddp_complete_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_access_rec.activity_access_id := rosetta_g_miss_num_map(p0_a0);
    ddp_access_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_access_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_access_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_access_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_access_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_access_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_access_rec.act_access_to_object_id := rosetta_g_miss_num_map(p0_a7);
    ddp_access_rec.arc_act_access_to_object := p0_a8;
    ddp_access_rec.user_or_role_id := rosetta_g_miss_num_map(p0_a9);
    ddp_access_rec.arc_user_or_role_type := p0_a10;
    ddp_access_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_access_rec.admin_flag := p0_a12;
    ddp_access_rec.approver_flag := p0_a13;
    ddp_access_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_access_rec.owner_flag := p0_a15;
    ddp_access_rec.delete_flag := p0_a16;

    ddp_complete_rec.activity_access_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.act_access_to_object_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.arc_act_access_to_object := p1_a8;
    ddp_complete_rec.user_or_role_id := rosetta_g_miss_num_map(p1_a9);
    ddp_complete_rec.arc_user_or_role_type := p1_a10;
    ddp_complete_rec.active_from_date := rosetta_g_miss_date_in_map(p1_a11);
    ddp_complete_rec.admin_flag := p1_a12;
    ddp_complete_rec.approver_flag := p1_a13;
    ddp_complete_rec.active_to_date := rosetta_g_miss_date_in_map(p1_a14);
    ddp_complete_rec.owner_flag := p1_a15;
    ddp_complete_rec.delete_flag := p1_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.check_access_record(ddp_access_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_access_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  DATE
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  DATE
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
  )

  as
    ddx_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.init_access_rec(ddx_access_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_access_rec.activity_access_id);
    p0_a1 := ddx_access_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_access_rec.last_updated_by);
    p0_a3 := ddx_access_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_access_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_access_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_access_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_access_rec.act_access_to_object_id);
    p0_a8 := ddx_access_rec.arc_act_access_to_object;
    p0_a9 := rosetta_g_miss_num_map(ddx_access_rec.user_or_role_id);
    p0_a10 := ddx_access_rec.arc_user_or_role_type;
    p0_a11 := ddx_access_rec.active_from_date;
    p0_a12 := ddx_access_rec.admin_flag;
    p0_a13 := ddx_access_rec.approver_flag;
    p0_a14 := ddx_access_rec.active_to_date;
    p0_a15 := ddx_access_rec.owner_flag;
    p0_a16 := ddx_access_rec.delete_flag;
  end;

  procedure complete_access_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  DATE
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  DATE
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  DATE := fnd_api.g_miss_date
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddx_complete_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_access_rec.activity_access_id := rosetta_g_miss_num_map(p0_a0);
    ddp_access_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_access_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_access_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_access_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_access_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_access_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_access_rec.act_access_to_object_id := rosetta_g_miss_num_map(p0_a7);
    ddp_access_rec.arc_act_access_to_object := p0_a8;
    ddp_access_rec.user_or_role_id := rosetta_g_miss_num_map(p0_a9);
    ddp_access_rec.arc_user_or_role_type := p0_a10;
    ddp_access_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_access_rec.admin_flag := p0_a12;
    ddp_access_rec.approver_flag := p0_a13;
    ddp_access_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a14);
    ddp_access_rec.owner_flag := p0_a15;
    ddp_access_rec.delete_flag := p0_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.complete_access_rec(ddp_access_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.activity_access_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.act_access_to_object_id);
    p1_a8 := ddx_complete_rec.arc_act_access_to_object;
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.user_or_role_id);
    p1_a10 := ddx_complete_rec.arc_user_or_role_type;
    p1_a11 := ddx_complete_rec.active_from_date;
    p1_a12 := ddx_complete_rec.admin_flag;
    p1_a13 := ddx_complete_rec.approver_flag;
    p1_a14 := ddx_complete_rec.active_to_date;
    p1_a15 := ddx_complete_rec.owner_flag;
    p1_a16 := ddx_complete_rec.delete_flag;
  end;

  procedure check_admin_access(p_resource_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := ams_access_pvt.check_admin_access(p_resource_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

end ams_access_pvt_w;

/
