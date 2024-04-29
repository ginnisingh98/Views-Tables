--------------------------------------------------------
--  DDL for Package Body PVX_TIMEOUT_SETUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_TIMEOUT_SETUP_PVT_W" as
  /* $Header: pvxwtmob.pls 115.9 2002/12/11 12:40:23 anubhavk ship $ */
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

  procedure create_timeout_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_timeout_setup_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_timeout_setup_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_timeout_setup_rec.timeout_id := rosetta_g_miss_num_map(p7_a0);
    ddp_timeout_setup_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_timeout_setup_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_timeout_setup_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_timeout_setup_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_timeout_setup_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_timeout_setup_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_timeout_setup_rec.timeout_period := rosetta_g_miss_num_map(p7_a7);
    ddp_timeout_setup_rec.timeout_type := p7_a8;
    ddp_timeout_setup_rec.country_code := p7_a9;


    -- here's the delegated call to the old PL/SQL routine
    pvx_timeout_setup_pvt.create_timeout_setup(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_timeout_setup_rec,
      x_timeout_setup_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_timeout_setup(p_api_version  NUMBER
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
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_timeout_setup_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_timeout_setup_rec.timeout_id := rosetta_g_miss_num_map(p7_a0);
    ddp_timeout_setup_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_timeout_setup_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_timeout_setup_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_timeout_setup_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_timeout_setup_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_timeout_setup_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_timeout_setup_rec.timeout_period := rosetta_g_miss_num_map(p7_a7);
    ddp_timeout_setup_rec.timeout_type := p7_a8;
    ddp_timeout_setup_rec.country_code := p7_a9;

    -- here's the delegated call to the old PL/SQL routine
    pvx_timeout_setup_pvt.update_timeout_setup(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_timeout_setup_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_timeout_setup(p_api_version  NUMBER
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
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_timeout_setup_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_timeout_setup_rec.timeout_id := rosetta_g_miss_num_map(p6_a0);
    ddp_timeout_setup_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_timeout_setup_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_timeout_setup_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_timeout_setup_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_timeout_setup_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_timeout_setup_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_timeout_setup_rec.timeout_period := rosetta_g_miss_num_map(p6_a7);
    ddp_timeout_setup_rec.timeout_type := p6_a8;
    ddp_timeout_setup_rec.country_code := p6_a9;

    -- here's the delegated call to the old PL/SQL routine
    pvx_timeout_setup_pvt.validate_timeout_setup(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_timeout_setup_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_timeout_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  DATE := fnd_api.g_miss_date
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  NUMBER := 0-1962.0724
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_timeout_setup_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_timeout_setup_rec.timeout_id := rosetta_g_miss_num_map(p2_a0);
    ddp_timeout_setup_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_timeout_setup_rec.last_updated_by := rosetta_g_miss_num_map(p2_a2);
    ddp_timeout_setup_rec.creation_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_timeout_setup_rec.created_by := rosetta_g_miss_num_map(p2_a4);
    ddp_timeout_setup_rec.last_update_login := rosetta_g_miss_num_map(p2_a5);
    ddp_timeout_setup_rec.object_version_number := rosetta_g_miss_num_map(p2_a6);
    ddp_timeout_setup_rec.timeout_period := rosetta_g_miss_num_map(p2_a7);
    ddp_timeout_setup_rec.timeout_type := p2_a8;
    ddp_timeout_setup_rec.country_code := p2_a9;

    -- here's the delegated call to the old PL/SQL routine
    pvx_timeout_setup_pvt.check_timeout_items(p_validation_mode,
      x_return_status,
      ddp_timeout_setup_rec);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_timeout_rec(p_mode  VARCHAR2
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
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_timeout_setup_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddp_complete_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_timeout_setup_rec.timeout_id := rosetta_g_miss_num_map(p0_a0);
    ddp_timeout_setup_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_timeout_setup_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_timeout_setup_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_timeout_setup_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_timeout_setup_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_timeout_setup_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_timeout_setup_rec.timeout_period := rosetta_g_miss_num_map(p0_a7);
    ddp_timeout_setup_rec.timeout_type := p0_a8;
    ddp_timeout_setup_rec.country_code := p0_a9;

    ddp_complete_rec.timeout_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.timeout_period := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.timeout_type := p1_a8;
    ddp_complete_rec.country_code := p1_a9;



    -- here's the delegated call to the old PL/SQL routine
    pvx_timeout_setup_pvt.check_timeout_rec(ddp_timeout_setup_rec,
      ddp_complete_rec,
      p_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any



  end;

  procedure init_timeout_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  VARCHAR2
  )
  as
    ddx_timeout_setup_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    pvx_timeout_setup_pvt.init_timeout_rec(ddx_timeout_setup_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_timeout_setup_rec.timeout_id);
    p0_a1 := ddx_timeout_setup_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_timeout_setup_rec.last_updated_by);
    p0_a3 := ddx_timeout_setup_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_timeout_setup_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_timeout_setup_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_timeout_setup_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_timeout_setup_rec.timeout_period);
    p0_a8 := ddx_timeout_setup_rec.timeout_type;
    p0_a9 := ddx_timeout_setup_rec.country_code;
  end;

  procedure complete_timeout_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_timeout_setup_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddx_complete_rec pvx_timeout_setup_pvt.timeout_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_timeout_setup_rec.timeout_id := rosetta_g_miss_num_map(p0_a0);
    ddp_timeout_setup_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_timeout_setup_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_timeout_setup_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_timeout_setup_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_timeout_setup_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_timeout_setup_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_timeout_setup_rec.timeout_period := rosetta_g_miss_num_map(p0_a7);
    ddp_timeout_setup_rec.timeout_type := p0_a8;
    ddp_timeout_setup_rec.country_code := p0_a9;


    -- here's the delegated call to the old PL/SQL routine
    pvx_timeout_setup_pvt.complete_timeout_rec(ddp_timeout_setup_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.timeout_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.timeout_period);
    p1_a8 := ddx_complete_rec.timeout_type;
    p1_a9 := ddx_complete_rec.country_code;
  end;

end pvx_timeout_setup_pvt_w;

/
