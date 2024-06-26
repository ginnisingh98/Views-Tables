--------------------------------------------------------
--  DDL for Package Body AMS_USER_STATUSES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_USER_STATUSES_PVT_W" as
  /* $Header: amswustb.pls 120.1 2005/09/30 06:55 mayjain noship $ */
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

  procedure create_user_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_user_status_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_user_status_rec ams_user_statuses_pvt.user_status_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_user_status_rec.user_status_id := rosetta_g_miss_num_map(p7_a0);
    ddp_user_status_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_user_status_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_user_status_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_user_status_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_user_status_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_user_status_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_user_status_rec.system_status_type := p7_a7;
    ddp_user_status_rec.system_status_code := p7_a8;
    ddp_user_status_rec.default_flag := p7_a9;
    ddp_user_status_rec.enabled_flag := p7_a10;
    ddp_user_status_rec.seeded_flag := p7_a11;
    ddp_user_status_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a12);
    ddp_user_status_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a13);
    ddp_user_status_rec.name := p7_a14;
    ddp_user_status_rec.description := p7_a15;


    -- here's the delegated call to the old PL/SQL routine
    ams_user_statuses_pvt.create_user_status(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_user_status_rec,
      x_user_status_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_user_status(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_user_status_rec ams_user_statuses_pvt.user_status_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_user_status_rec.user_status_id := rosetta_g_miss_num_map(p7_a0);
    ddp_user_status_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_user_status_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_user_status_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_user_status_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_user_status_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_user_status_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_user_status_rec.system_status_type := p7_a7;
    ddp_user_status_rec.system_status_code := p7_a8;
    ddp_user_status_rec.default_flag := p7_a9;
    ddp_user_status_rec.enabled_flag := p7_a10;
    ddp_user_status_rec.seeded_flag := p7_a11;
    ddp_user_status_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a12);
    ddp_user_status_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a13);
    ddp_user_status_rec.name := p7_a14;
    ddp_user_status_rec.description := p7_a15;

    -- here's the delegated call to the old PL/SQL routine
    ams_user_statuses_pvt.update_user_status(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_user_status_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_user_status(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_user_status_rec ams_user_statuses_pvt.user_status_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_user_status_rec.user_status_id := rosetta_g_miss_num_map(p7_a0);
    ddp_user_status_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_user_status_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_user_status_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_user_status_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_user_status_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_user_status_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_user_status_rec.system_status_type := p7_a7;
    ddp_user_status_rec.system_status_code := p7_a8;
    ddp_user_status_rec.default_flag := p7_a9;
    ddp_user_status_rec.enabled_flag := p7_a10;
    ddp_user_status_rec.seeded_flag := p7_a11;
    ddp_user_status_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a12);
    ddp_user_status_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a13);
    ddp_user_status_rec.name := p7_a14;
    ddp_user_status_rec.description := p7_a15;

    -- here's the delegated call to the old PL/SQL routine
    ams_user_statuses_pvt.validate_user_status(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_user_status_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_user_status_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_user_status_rec ams_user_statuses_pvt.user_status_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_user_status_rec.user_status_id := rosetta_g_miss_num_map(p0_a0);
    ddp_user_status_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_user_status_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_user_status_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_user_status_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_user_status_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_user_status_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_user_status_rec.system_status_type := p0_a7;
    ddp_user_status_rec.system_status_code := p0_a8;
    ddp_user_status_rec.default_flag := p0_a9;
    ddp_user_status_rec.enabled_flag := p0_a10;
    ddp_user_status_rec.seeded_flag := p0_a11;
    ddp_user_status_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a12);
    ddp_user_status_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a13);
    ddp_user_status_rec.name := p0_a14;
    ddp_user_status_rec.description := p0_a15;



    -- here's the delegated call to the old PL/SQL routine
    ams_user_statuses_pvt.check_user_status_items(ddp_user_status_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_user_status_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_user_status_rec ams_user_statuses_pvt.user_status_rec_type;
    ddp_complete_rec ams_user_statuses_pvt.user_status_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_user_status_rec.user_status_id := rosetta_g_miss_num_map(p0_a0);
    ddp_user_status_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_user_status_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_user_status_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_user_status_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_user_status_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_user_status_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_user_status_rec.system_status_type := p0_a7;
    ddp_user_status_rec.system_status_code := p0_a8;
    ddp_user_status_rec.default_flag := p0_a9;
    ddp_user_status_rec.enabled_flag := p0_a10;
    ddp_user_status_rec.seeded_flag := p0_a11;
    ddp_user_status_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a12);
    ddp_user_status_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a13);
    ddp_user_status_rec.name := p0_a14;
    ddp_user_status_rec.description := p0_a15;

    ddp_complete_rec.user_status_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.system_status_type := p1_a7;
    ddp_complete_rec.system_status_code := p1_a8;
    ddp_complete_rec.default_flag := p1_a9;
    ddp_complete_rec.enabled_flag := p1_a10;
    ddp_complete_rec.seeded_flag := p1_a11;
    ddp_complete_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a12);
    ddp_complete_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a13);
    ddp_complete_rec.name := p1_a14;
    ddp_complete_rec.description := p1_a15;


    -- here's the delegated call to the old PL/SQL routine
    ams_user_statuses_pvt.check_user_status_record(ddp_user_status_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_user_status_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  VARCHAR2
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  DATE
    , p0_a13 out nocopy  DATE
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
  )

  as
    ddx_user_status_rec ams_user_statuses_pvt.user_status_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_user_statuses_pvt.init_user_status_rec(ddx_user_status_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_user_status_rec.user_status_id);
    p0_a1 := ddx_user_status_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_user_status_rec.last_updated_by);
    p0_a3 := ddx_user_status_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_user_status_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_user_status_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_user_status_rec.object_version_number);
    p0_a7 := ddx_user_status_rec.system_status_type;
    p0_a8 := ddx_user_status_rec.system_status_code;
    p0_a9 := ddx_user_status_rec.default_flag;
    p0_a10 := ddx_user_status_rec.enabled_flag;
    p0_a11 := ddx_user_status_rec.seeded_flag;
    p0_a12 := ddx_user_status_rec.start_date_active;
    p0_a13 := ddx_user_status_rec.end_date_active;
    p0_a14 := ddx_user_status_rec.name;
    p0_a15 := ddx_user_status_rec.description;
  end;

  procedure complete_user_status_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  DATE
    , p1_a13 out nocopy  DATE
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_user_status_rec ams_user_statuses_pvt.user_status_rec_type;
    ddx_complete_rec ams_user_statuses_pvt.user_status_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_user_status_rec.user_status_id := rosetta_g_miss_num_map(p0_a0);
    ddp_user_status_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_user_status_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_user_status_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_user_status_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_user_status_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_user_status_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_user_status_rec.system_status_type := p0_a7;
    ddp_user_status_rec.system_status_code := p0_a8;
    ddp_user_status_rec.default_flag := p0_a9;
    ddp_user_status_rec.enabled_flag := p0_a10;
    ddp_user_status_rec.seeded_flag := p0_a11;
    ddp_user_status_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a12);
    ddp_user_status_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a13);
    ddp_user_status_rec.name := p0_a14;
    ddp_user_status_rec.description := p0_a15;


    -- here's the delegated call to the old PL/SQL routine
    ams_user_statuses_pvt.complete_user_status_rec(ddp_user_status_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.user_status_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.system_status_type;
    p1_a8 := ddx_complete_rec.system_status_code;
    p1_a9 := ddx_complete_rec.default_flag;
    p1_a10 := ddx_complete_rec.enabled_flag;
    p1_a11 := ddx_complete_rec.seeded_flag;
    p1_a12 := ddx_complete_rec.start_date_active;
    p1_a13 := ddx_complete_rec.end_date_active;
    p1_a14 := ddx_complete_rec.name;
    p1_a15 := ddx_complete_rec.description;
  end;

end ams_user_statuses_pvt_w;

/
