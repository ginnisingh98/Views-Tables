--------------------------------------------------------
--  DDL for Package Body AMS_APPROVERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVERS_PVT_W" as
  /* $Header: amswaprb.pls 115.7 2002/12/29 08:57:27 vmodur ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');


  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_approvers(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
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
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
    , x_approver_id OUT NOCOPY  NUMBER
  )

  as
    ddp_approvers_rec ams_approvers_pvt.approvers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approvers_rec.approver_id := p7_a0;
    ddp_approvers_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_approvers_rec.last_updated_by := p7_a2;
    ddp_approvers_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_approvers_rec.created_by := p7_a4;
    ddp_approvers_rec.last_update_login := p7_a5;
    ddp_approvers_rec.object_version_number := p7_a6;
    ddp_approvers_rec.security_group_id := p7_a7;
    ddp_approvers_rec.ams_approval_detail_id := p7_a8;
    ddp_approvers_rec.approver_seq := p7_a9;
    ddp_approvers_rec.approver_type := p7_a10;
    ddp_approvers_rec.object_approver_id := p7_a11;
    ddp_approvers_rec.notification_type := p7_a12;
    ddp_approvers_rec.notification_timeout := p7_a13;
    ddp_approvers_rec.seeded_flag := p7_a14;
    ddp_approvers_rec.active_flag := p7_a15;
    ddp_approvers_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a16);
    ddp_approvers_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a17);


    -- here's the delegated call to the old PL/SQL routine
    ams_approvers_pvt.create_approvers(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_approvers_rec,
      x_approver_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_approvers(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
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
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
  )

  as
    ddp_approvers_rec ams_approvers_pvt.approvers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approvers_rec.approver_id := p7_a0;
    ddp_approvers_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_approvers_rec.last_updated_by := p7_a2;
    ddp_approvers_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_approvers_rec.created_by := p7_a4;
    ddp_approvers_rec.last_update_login := p7_a5;
    ddp_approvers_rec.object_version_number := p7_a6;
    ddp_approvers_rec.security_group_id := p7_a7;
    ddp_approvers_rec.ams_approval_detail_id := p7_a8;
    ddp_approvers_rec.approver_seq := p7_a9;
    ddp_approvers_rec.approver_type := p7_a10;
    ddp_approvers_rec.object_approver_id := p7_a11;
    ddp_approvers_rec.notification_type := p7_a12;
    ddp_approvers_rec.notification_timeout := p7_a13;
    ddp_approvers_rec.seeded_flag := p7_a14;
    ddp_approvers_rec.active_flag := p7_a15;
    ddp_approvers_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a16);
    ddp_approvers_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a17);

    -- here's the delegated call to the old PL/SQL routine
    ams_approvers_pvt.update_approvers(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_approvers_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_approvers(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
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
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
  )

  as
    ddp_approvers_rec ams_approvers_pvt.approvers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approvers_rec.approver_id := p7_a0;
    ddp_approvers_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_approvers_rec.last_updated_by := p7_a2;
    ddp_approvers_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_approvers_rec.created_by := p7_a4;
    ddp_approvers_rec.last_update_login := p7_a5;
    ddp_approvers_rec.object_version_number := p7_a6;
    ddp_approvers_rec.security_group_id := p7_a7;
    ddp_approvers_rec.ams_approval_detail_id := p7_a8;
    ddp_approvers_rec.approver_seq := p7_a9;
    ddp_approvers_rec.approver_type := p7_a10;
    ddp_approvers_rec.object_approver_id := p7_a11;
    ddp_approvers_rec.notification_type := p7_a12;
    ddp_approvers_rec.notification_timeout := p7_a13;
    ddp_approvers_rec.seeded_flag := p7_a14;
    ddp_approvers_rec.active_flag := p7_a15;
    ddp_approvers_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a16);
    ddp_approvers_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a17);

    -- here's the delegated call to the old PL/SQL routine
    ams_approvers_pvt.validate_approvers(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_approvers_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_approvers_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  NUMBER
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  DATE
    , p0_a17  DATE
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
  )

  as
    ddp_approvers_rec ams_approvers_pvt.approvers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_approvers_rec.approver_id := p0_a0;
    ddp_approvers_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_approvers_rec.last_updated_by := p0_a2;
    ddp_approvers_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_approvers_rec.created_by := p0_a4;
    ddp_approvers_rec.last_update_login := p0_a5;
    ddp_approvers_rec.object_version_number := p0_a6;
    ddp_approvers_rec.security_group_id := p0_a7;
    ddp_approvers_rec.ams_approval_detail_id := p0_a8;
    ddp_approvers_rec.approver_seq := p0_a9;
    ddp_approvers_rec.approver_type := p0_a10;
    ddp_approvers_rec.object_approver_id := p0_a11;
    ddp_approvers_rec.notification_type := p0_a12;
    ddp_approvers_rec.notification_timeout := p0_a13;
    ddp_approvers_rec.seeded_flag := p0_a14;
    ddp_approvers_rec.active_flag := p0_a15;
    ddp_approvers_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a16);
    ddp_approvers_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a17);



    -- here's the delegated call to the old PL/SQL routine
    ams_approvers_pvt.check_approvers_items(ddp_approvers_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_approvers_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  NUMBER
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  DATE
    , p0_a17  DATE
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  DATE
    , p1_a17  DATE
    , x_return_status OUT NOCOPY  VARCHAR2
  )

  as
    ddp_approvers_rec ams_approvers_pvt.approvers_rec_type;
    ddp_complete_rec ams_approvers_pvt.approvers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_approvers_rec.approver_id := p0_a0;
    ddp_approvers_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_approvers_rec.last_updated_by := p0_a2;
    ddp_approvers_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_approvers_rec.created_by := p0_a4;
    ddp_approvers_rec.last_update_login := p0_a5;
    ddp_approvers_rec.object_version_number := p0_a6;
    ddp_approvers_rec.security_group_id := p0_a7;
    ddp_approvers_rec.ams_approval_detail_id := p0_a8;
    ddp_approvers_rec.approver_seq := p0_a9;
    ddp_approvers_rec.approver_type := p0_a10;
    ddp_approvers_rec.object_approver_id := p0_a11;
    ddp_approvers_rec.notification_type := p0_a12;
    ddp_approvers_rec.notification_timeout := p0_a13;
    ddp_approvers_rec.seeded_flag := p0_a14;
    ddp_approvers_rec.active_flag := p0_a15;
    ddp_approvers_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a16);
    ddp_approvers_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a17);

    ddp_complete_rec.approver_id := p1_a0;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := p1_a4;
    ddp_complete_rec.last_update_login := p1_a5;
    ddp_complete_rec.object_version_number := p1_a6;
    ddp_complete_rec.security_group_id := p1_a7;
    ddp_complete_rec.ams_approval_detail_id := p1_a8;
    ddp_complete_rec.approver_seq := p1_a9;
    ddp_complete_rec.approver_type := p1_a10;
    ddp_complete_rec.object_approver_id := p1_a11;
    ddp_complete_rec.notification_type := p1_a12;
    ddp_complete_rec.notification_timeout := p1_a13;
    ddp_complete_rec.seeded_flag := p1_a14;
    ddp_complete_rec.active_flag := p1_a15;
    ddp_complete_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a16);
    ddp_complete_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a17);


    -- here's the delegated call to the old PL/SQL routine
    ams_approvers_pvt.check_approvers_record(ddp_approvers_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_approvers_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  NUMBER
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  NUMBER
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  NUMBER
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  VARCHAR2
    , p0_a16 OUT NOCOPY  DATE
    , p0_a17 OUT NOCOPY  DATE
  )

  as
    ddx_approvers_rec ams_approvers_pvt.approvers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_approvers_pvt.init_approvers_rec(ddx_approvers_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_approvers_rec.approver_id;
    p0_a1 := ddx_approvers_rec.last_update_date;
    p0_a2 := ddx_approvers_rec.last_updated_by;
    p0_a3 := ddx_approvers_rec.creation_date;
    p0_a4 := ddx_approvers_rec.created_by;
    p0_a5 := ddx_approvers_rec.last_update_login;
    p0_a6 := ddx_approvers_rec.object_version_number;
    p0_a7 := ddx_approvers_rec.security_group_id;
    p0_a8 := ddx_approvers_rec.ams_approval_detail_id;
    p0_a9 := ddx_approvers_rec.approver_seq;
    p0_a10 := ddx_approvers_rec.approver_type;
    p0_a11 := ddx_approvers_rec.object_approver_id;
    p0_a12 := ddx_approvers_rec.notification_type;
    p0_a13 := ddx_approvers_rec.notification_timeout;
    p0_a14 := ddx_approvers_rec.seeded_flag;
    p0_a15 := ddx_approvers_rec.active_flag;
    p0_a16 := ddx_approvers_rec.start_date_active;
    p0_a17 := ddx_approvers_rec.end_date_active;
  end;

  procedure complete_approvers_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  NUMBER
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  DATE
    , p0_a17  DATE
    , p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  NUMBER
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  NUMBER
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  NUMBER
    , p1_a14 OUT NOCOPY  VARCHAR2
    , p1_a15 OUT NOCOPY  VARCHAR2
    , p1_a16 OUT NOCOPY  DATE
    , p1_a17 OUT NOCOPY  DATE
  )

  as
    ddp_approvers_rec ams_approvers_pvt.approvers_rec_type;
    ddx_complete_rec ams_approvers_pvt.approvers_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_approvers_rec.approver_id := p0_a0;
    ddp_approvers_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_approvers_rec.last_updated_by := p0_a2;
    ddp_approvers_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_approvers_rec.created_by := p0_a4;
    ddp_approvers_rec.last_update_login := p0_a5;
    ddp_approvers_rec.object_version_number := p0_a6;
    ddp_approvers_rec.security_group_id := p0_a7;
    ddp_approvers_rec.ams_approval_detail_id := p0_a8;
    ddp_approvers_rec.approver_seq := p0_a9;
    ddp_approvers_rec.approver_type := p0_a10;
    ddp_approvers_rec.object_approver_id := p0_a11;
    ddp_approvers_rec.notification_type := p0_a12;
    ddp_approvers_rec.notification_timeout := p0_a13;
    ddp_approvers_rec.seeded_flag := p0_a14;
    ddp_approvers_rec.active_flag := p0_a15;
    ddp_approvers_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a16);
    ddp_approvers_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a17);


    -- here's the delegated call to the old PL/SQL routine
    ams_approvers_pvt.complete_approvers_rec(ddp_approvers_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.approver_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.object_version_number;
    p1_a7 := ddx_complete_rec.security_group_id;
    p1_a8 := ddx_complete_rec.ams_approval_detail_id;
    p1_a9 := ddx_complete_rec.approver_seq;
    p1_a10 := ddx_complete_rec.approver_type;
    p1_a11 := ddx_complete_rec.object_approver_id;
    p1_a12 := ddx_complete_rec.notification_type;
    p1_a13 := ddx_complete_rec.notification_timeout;
    p1_a14 := ddx_complete_rec.seeded_flag;
    p1_a15 := ddx_complete_rec.active_flag;
    p1_a16 := ddx_complete_rec.start_date_active;
    p1_a17 := ddx_complete_rec.end_date_active;
  end;

end ams_approvers_pvt_w;

/
