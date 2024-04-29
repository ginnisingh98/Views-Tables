--------------------------------------------------------
--  DDL for Package Body AMS_ACCESS_PVT_W_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACCESS_PVT_W_NEW" as
  /* $Header: amsacesb.pls 120.1 2005/08/29 06:01 anskumar noship $ */
  procedure create_access(p_api_version  NUMBER
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
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  DATE
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , x_access_id out nocopy  NUMBER
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_access_rec.activity_access_id := p7_a0;
    ddp_access_rec.last_update_date := p7_a1;
    ddp_access_rec.last_updated_by := p7_a2;
    ddp_access_rec.creation_date := p7_a3;
    ddp_access_rec.created_by := p7_a4;
    ddp_access_rec.last_update_login := p7_a5;
    ddp_access_rec.object_version_number := p7_a6;
    ddp_access_rec.act_access_to_object_id := p7_a7;
    ddp_access_rec.arc_act_access_to_object := p7_a8;
    ddp_access_rec.user_or_role_id := p7_a9;
    ddp_access_rec.arc_user_or_role_type := p7_a10;
    ddp_access_rec.active_from_date := p7_a11;
    ddp_access_rec.admin_flag := p7_a12;
    ddp_access_rec.approver_flag := p7_a13;
    ddp_access_rec.active_to_date := p7_a14;
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
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  DATE
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_access_rec.activity_access_id := p7_a0;
    ddp_access_rec.last_update_date := p7_a1;
    ddp_access_rec.last_updated_by := p7_a2;
    ddp_access_rec.creation_date := p7_a3;
    ddp_access_rec.created_by := p7_a4;
    ddp_access_rec.last_update_login := p7_a5;
    ddp_access_rec.object_version_number := p7_a6;
    ddp_access_rec.act_access_to_object_id := p7_a7;
    ddp_access_rec.arc_act_access_to_object := p7_a8;
    ddp_access_rec.user_or_role_id := p7_a9;
    ddp_access_rec.arc_user_or_role_type := p7_a10;
    ddp_access_rec.active_from_date := p7_a11;
    ddp_access_rec.admin_flag := p7_a12;
    ddp_access_rec.approver_flag := p7_a13;
    ddp_access_rec.active_to_date := p7_a14;
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
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
    , p6_a11  DATE
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  DATE
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_access_rec.activity_access_id := p6_a0;
    ddp_access_rec.last_update_date := p6_a1;
    ddp_access_rec.last_updated_by := p6_a2;
    ddp_access_rec.creation_date := p6_a3;
    ddp_access_rec.created_by := p6_a4;
    ddp_access_rec.last_update_login := p6_a5;
    ddp_access_rec.object_version_number := p6_a6;
    ddp_access_rec.act_access_to_object_id := p6_a7;
    ddp_access_rec.arc_act_access_to_object := p6_a8;
    ddp_access_rec.user_or_role_id := p6_a9;
    ddp_access_rec.arc_user_or_role_type := p6_a10;
    ddp_access_rec.active_from_date := p6_a11;
    ddp_access_rec.admin_flag := p6_a12;
    ddp_access_rec.approver_flag := p6_a13;
    ddp_access_rec.active_to_date := p6_a14;
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

  procedure check_access_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_access_rec.activity_access_id := p0_a0;
    ddp_access_rec.last_update_date := p0_a1;
    ddp_access_rec.last_updated_by := p0_a2;
    ddp_access_rec.creation_date := p0_a3;
    ddp_access_rec.created_by := p0_a4;
    ddp_access_rec.last_update_login := p0_a5;
    ddp_access_rec.object_version_number := p0_a6;
    ddp_access_rec.act_access_to_object_id := p0_a7;
    ddp_access_rec.arc_act_access_to_object := p0_a8;
    ddp_access_rec.user_or_role_id := p0_a9;
    ddp_access_rec.arc_user_or_role_type := p0_a10;
    ddp_access_rec.active_from_date := p0_a11;
    ddp_access_rec.admin_flag := p0_a12;
    ddp_access_rec.approver_flag := p0_a13;
    ddp_access_rec.active_to_date := p0_a14;
    ddp_access_rec.owner_flag := p0_a15;
    ddp_access_rec.delete_flag := p0_a16;



    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.check_access_items(ddp_access_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_access_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  DATE
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  DATE
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddp_complete_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_access_rec.activity_access_id := p0_a0;
    ddp_access_rec.last_update_date := p0_a1;
    ddp_access_rec.last_updated_by := p0_a2;
    ddp_access_rec.creation_date := p0_a3;
    ddp_access_rec.created_by := p0_a4;
    ddp_access_rec.last_update_login := p0_a5;
    ddp_access_rec.object_version_number := p0_a6;
    ddp_access_rec.act_access_to_object_id := p0_a7;
    ddp_access_rec.arc_act_access_to_object := p0_a8;
    ddp_access_rec.user_or_role_id := p0_a9;
    ddp_access_rec.arc_user_or_role_type := p0_a10;
    ddp_access_rec.active_from_date := p0_a11;
    ddp_access_rec.admin_flag := p0_a12;
    ddp_access_rec.approver_flag := p0_a13;
    ddp_access_rec.active_to_date := p0_a14;
    ddp_access_rec.owner_flag := p0_a15;
    ddp_access_rec.delete_flag := p0_a16;

    ddp_complete_rec.activity_access_id := p1_a0;
    ddp_complete_rec.last_update_date := p1_a1;
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.creation_date := p1_a3;
    ddp_complete_rec.created_by := p1_a4;
    ddp_complete_rec.last_update_login := p1_a5;
    ddp_complete_rec.object_version_number := p1_a6;
    ddp_complete_rec.act_access_to_object_id := p1_a7;
    ddp_complete_rec.arc_act_access_to_object := p1_a8;
    ddp_complete_rec.user_or_role_id := p1_a9;
    ddp_complete_rec.arc_user_or_role_type := p1_a10;
    ddp_complete_rec.active_from_date := p1_a11;
    ddp_complete_rec.admin_flag := p1_a12;
    ddp_complete_rec.approver_flag := p1_a13;
    ddp_complete_rec.active_to_date := p1_a14;
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
    p0_a0 := ddx_access_rec.activity_access_id;
    p0_a1 := ddx_access_rec.last_update_date;
    p0_a2 := ddx_access_rec.last_updated_by;
    p0_a3 := ddx_access_rec.creation_date;
    p0_a4 := ddx_access_rec.created_by;
    p0_a5 := ddx_access_rec.last_update_login;
    p0_a6 := ddx_access_rec.object_version_number;
    p0_a7 := ddx_access_rec.act_access_to_object_id;
    p0_a8 := ddx_access_rec.arc_act_access_to_object;
    p0_a9 := ddx_access_rec.user_or_role_id;
    p0_a10 := ddx_access_rec.arc_user_or_role_type;
    p0_a11 := ddx_access_rec.active_from_date;
    p0_a12 := ddx_access_rec.admin_flag;
    p0_a13 := ddx_access_rec.approver_flag;
    p0_a14 := ddx_access_rec.active_to_date;
    p0_a15 := ddx_access_rec.owner_flag;
    p0_a16 := ddx_access_rec.delete_flag;
  end;

  procedure complete_access_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p1_a0 out nocopy  NUMBER
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
  )

  as
    ddp_access_rec ams_access_pvt.access_rec_type;
    ddx_complete_rec ams_access_pvt.access_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_access_rec.activity_access_id := p0_a0;
    ddp_access_rec.last_update_date := p0_a1;
    ddp_access_rec.last_updated_by := p0_a2;
    ddp_access_rec.creation_date := p0_a3;
    ddp_access_rec.created_by := p0_a4;
    ddp_access_rec.last_update_login := p0_a5;
    ddp_access_rec.object_version_number := p0_a6;
    ddp_access_rec.act_access_to_object_id := p0_a7;
    ddp_access_rec.arc_act_access_to_object := p0_a8;
    ddp_access_rec.user_or_role_id := p0_a9;
    ddp_access_rec.arc_user_or_role_type := p0_a10;
    ddp_access_rec.active_from_date := p0_a11;
    ddp_access_rec.admin_flag := p0_a12;
    ddp_access_rec.approver_flag := p0_a13;
    ddp_access_rec.active_to_date := p0_a14;
    ddp_access_rec.owner_flag := p0_a15;
    ddp_access_rec.delete_flag := p0_a16;


    -- here's the delegated call to the old PL/SQL routine
    ams_access_pvt.complete_access_rec(ddp_access_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.activity_access_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.object_version_number;
    p1_a7 := ddx_complete_rec.act_access_to_object_id;
    p1_a8 := ddx_complete_rec.arc_act_access_to_object;
    p1_a9 := ddx_complete_rec.user_or_role_id;
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

end ams_access_pvt_w_new;

/
