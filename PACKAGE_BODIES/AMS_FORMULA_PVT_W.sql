--------------------------------------------------------
--  DDL for Package Body AMS_FORMULA_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_FORMULA_PVT_W" as
  /* $Header: amswfmlb.pls 115.4 2002/11/22 00:44:57 yzhao ship $ */
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

  procedure create_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_formula_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_formula_rec ams_formula_pvt.ams_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_formula_rec.formula_id := rosetta_g_miss_num_map(p7_a0);
    ddp_formula_rec.activity_metric_id := rosetta_g_miss_num_map(p7_a1);
    ddp_formula_rec.level_depth := rosetta_g_miss_num_map(p7_a2);
    ddp_formula_rec.parent_formula_id := rosetta_g_miss_num_map(p7_a3);
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_formula_rec.last_updated_by := rosetta_g_miss_num_map(p7_a5);
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_formula_rec.created_by := rosetta_g_miss_num_map(p7_a7);
    ddp_formula_rec.last_update_login := rosetta_g_miss_num_map(p7_a8);
    ddp_formula_rec.object_version_number := rosetta_g_miss_num_map(p7_a9);
    ddp_formula_rec.formula_type := p7_a10;


    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.create_formula(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_rec,
      x_formula_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_formula_rec ams_formula_pvt.ams_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_formula_rec.formula_id := rosetta_g_miss_num_map(p7_a0);
    ddp_formula_rec.activity_metric_id := rosetta_g_miss_num_map(p7_a1);
    ddp_formula_rec.level_depth := rosetta_g_miss_num_map(p7_a2);
    ddp_formula_rec.parent_formula_id := rosetta_g_miss_num_map(p7_a3);
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_formula_rec.last_updated_by := rosetta_g_miss_num_map(p7_a5);
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_formula_rec.created_by := rosetta_g_miss_num_map(p7_a7);
    ddp_formula_rec.last_update_login := rosetta_g_miss_num_map(p7_a8);
    ddp_formula_rec.object_version_number := rosetta_g_miss_num_map(p7_a9);
    ddp_formula_rec.formula_type := p7_a10;

    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.update_formula(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  DATE := fnd_api.g_miss_date
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_formula_rec ams_formula_pvt.ams_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_formula_rec.formula_id := rosetta_g_miss_num_map(p6_a0);
    ddp_formula_rec.activity_metric_id := rosetta_g_miss_num_map(p6_a1);
    ddp_formula_rec.level_depth := rosetta_g_miss_num_map(p6_a2);
    ddp_formula_rec.parent_formula_id := rosetta_g_miss_num_map(p6_a3);
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_formula_rec.last_updated_by := rosetta_g_miss_num_map(p6_a5);
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_formula_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_formula_rec.last_update_login := rosetta_g_miss_num_map(p6_a8);
    ddp_formula_rec.object_version_number := rosetta_g_miss_num_map(p6_a9);
    ddp_formula_rec.formula_type := p6_a10;

    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.validate_formula(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_formula_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_formula_rec ams_formula_pvt.ams_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_rec.formula_id := rosetta_g_miss_num_map(p0_a0);
    ddp_formula_rec.activity_metric_id := rosetta_g_miss_num_map(p0_a1);
    ddp_formula_rec.level_depth := rosetta_g_miss_num_map(p0_a2);
    ddp_formula_rec.parent_formula_id := rosetta_g_miss_num_map(p0_a3);
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_formula_rec.last_updated_by := rosetta_g_miss_num_map(p0_a5);
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_formula_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_formula_rec.last_update_login := rosetta_g_miss_num_map(p0_a8);
    ddp_formula_rec.object_version_number := rosetta_g_miss_num_map(p0_a9);
    ddp_formula_rec.formula_type := p0_a10;



    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.validate_formula_items(ddp_formula_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_formula_rec(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  DATE := fnd_api.g_miss_date
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  DATE := fnd_api.g_miss_date
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_formula_rec ams_formula_pvt.ams_formula_rec_type;
    ddp_complete_formula_rec ams_formula_pvt.ams_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_rec.formula_id := rosetta_g_miss_num_map(p0_a0);
    ddp_formula_rec.activity_metric_id := rosetta_g_miss_num_map(p0_a1);
    ddp_formula_rec.level_depth := rosetta_g_miss_num_map(p0_a2);
    ddp_formula_rec.parent_formula_id := rosetta_g_miss_num_map(p0_a3);
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_formula_rec.last_updated_by := rosetta_g_miss_num_map(p0_a5);
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_formula_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_formula_rec.last_update_login := rosetta_g_miss_num_map(p0_a8);
    ddp_formula_rec.object_version_number := rosetta_g_miss_num_map(p0_a9);
    ddp_formula_rec.formula_type := p0_a10;

    ddp_complete_formula_rec.formula_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_formula_rec.activity_metric_id := rosetta_g_miss_num_map(p1_a1);
    ddp_complete_formula_rec.level_depth := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_formula_rec.parent_formula_id := rosetta_g_miss_num_map(p1_a3);
    ddp_complete_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_formula_rec.last_updated_by := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_formula_rec.creation_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_complete_formula_rec.created_by := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_formula_rec.last_update_login := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_formula_rec.object_version_number := rosetta_g_miss_num_map(p1_a9);
    ddp_complete_formula_rec.formula_type := p1_a10;


    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.validate_formula_rec(ddp_formula_rec,
      ddp_complete_formula_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_formula_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  DATE
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_formula_rec ams_formula_pvt.ams_formula_rec_type;
    ddx_complete_formula_rec ams_formula_pvt.ams_formula_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_rec.formula_id := rosetta_g_miss_num_map(p0_a0);
    ddp_formula_rec.activity_metric_id := rosetta_g_miss_num_map(p0_a1);
    ddp_formula_rec.level_depth := rosetta_g_miss_num_map(p0_a2);
    ddp_formula_rec.parent_formula_id := rosetta_g_miss_num_map(p0_a3);
    ddp_formula_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_formula_rec.last_updated_by := rosetta_g_miss_num_map(p0_a5);
    ddp_formula_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_formula_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_formula_rec.last_update_login := rosetta_g_miss_num_map(p0_a8);
    ddp_formula_rec.object_version_number := rosetta_g_miss_num_map(p0_a9);
    ddp_formula_rec.formula_type := p0_a10;


    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.complete_formula_rec(ddp_formula_rec,
      ddx_complete_formula_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_formula_rec.formula_id);
    p1_a1 := rosetta_g_miss_num_map(ddx_complete_formula_rec.activity_metric_id);
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_formula_rec.level_depth);
    p1_a3 := rosetta_g_miss_num_map(ddx_complete_formula_rec.parent_formula_id);
    p1_a4 := ddx_complete_formula_rec.last_update_date;
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_formula_rec.last_updated_by);
    p1_a6 := ddx_complete_formula_rec.creation_date;
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_formula_rec.created_by);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_formula_rec.last_update_login);
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_formula_rec.object_version_number);
    p1_a10 := ddx_complete_formula_rec.formula_type;
  end;

  procedure create_formula_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_formula_entry_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_formula_entry_rec ams_formula_pvt.ams_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_formula_entry_rec.formula_entry_id := rosetta_g_miss_num_map(p7_a0);
    ddp_formula_entry_rec.formula_id := rosetta_g_miss_num_map(p7_a1);
    ddp_formula_entry_rec.order_number := rosetta_g_miss_num_map(p7_a2);
    ddp_formula_entry_rec.formula_entry_type := p7_a3;
    ddp_formula_entry_rec.formula_entry_value := p7_a4;
    ddp_formula_entry_rec.metric_column_value := p7_a5;
    ddp_formula_entry_rec.formula_entry_operator := p7_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_formula_entry_rec.last_updated_by := rosetta_g_miss_num_map(p7_a8);
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_formula_entry_rec.created_by := rosetta_g_miss_num_map(p7_a10);
    ddp_formula_entry_rec.last_update_login := rosetta_g_miss_num_map(p7_a11);
    ddp_formula_entry_rec.object_version_number := rosetta_g_miss_num_map(p7_a12);


    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.create_formula_entry(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_entry_rec,
      x_formula_entry_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_formula_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_formula_entry_rec ams_formula_pvt.ams_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_formula_entry_rec.formula_entry_id := rosetta_g_miss_num_map(p7_a0);
    ddp_formula_entry_rec.formula_id := rosetta_g_miss_num_map(p7_a1);
    ddp_formula_entry_rec.order_number := rosetta_g_miss_num_map(p7_a2);
    ddp_formula_entry_rec.formula_entry_type := p7_a3;
    ddp_formula_entry_rec.formula_entry_value := p7_a4;
    ddp_formula_entry_rec.metric_column_value := p7_a5;
    ddp_formula_entry_rec.formula_entry_operator := p7_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_formula_entry_rec.last_updated_by := rosetta_g_miss_num_map(p7_a8);
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_formula_entry_rec.created_by := rosetta_g_miss_num_map(p7_a10);
    ddp_formula_entry_rec.last_update_login := rosetta_g_miss_num_map(p7_a11);
    ddp_formula_entry_rec.object_version_number := rosetta_g_miss_num_map(p7_a12);

    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.update_formula_entry(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_entry_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_formula_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  DATE := fnd_api.g_miss_date
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_formula_entry_rec ams_formula_pvt.ams_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_formula_entry_rec.formula_entry_id := rosetta_g_miss_num_map(p6_a0);
    ddp_formula_entry_rec.formula_id := rosetta_g_miss_num_map(p6_a1);
    ddp_formula_entry_rec.order_number := rosetta_g_miss_num_map(p6_a2);
    ddp_formula_entry_rec.formula_entry_type := p6_a3;
    ddp_formula_entry_rec.formula_entry_value := p6_a4;
    ddp_formula_entry_rec.metric_column_value := p6_a5;
    ddp_formula_entry_rec.formula_entry_operator := p6_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a7);
    ddp_formula_entry_rec.last_updated_by := rosetta_g_miss_num_map(p6_a8);
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_formula_entry_rec.created_by := rosetta_g_miss_num_map(p6_a10);
    ddp_formula_entry_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);
    ddp_formula_entry_rec.object_version_number := rosetta_g_miss_num_map(p6_a12);

    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.validate_formula_entry(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_formula_entry_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validate_form_ent_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_formula_entry_rec ams_formula_pvt.ams_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_entry_rec.formula_entry_id := rosetta_g_miss_num_map(p0_a0);
    ddp_formula_entry_rec.formula_id := rosetta_g_miss_num_map(p0_a1);
    ddp_formula_entry_rec.order_number := rosetta_g_miss_num_map(p0_a2);
    ddp_formula_entry_rec.formula_entry_type := p0_a3;
    ddp_formula_entry_rec.formula_entry_value := p0_a4;
    ddp_formula_entry_rec.metric_column_value := p0_a5;
    ddp_formula_entry_rec.formula_entry_operator := p0_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_formula_entry_rec.last_updated_by := rosetta_g_miss_num_map(p0_a8);
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_formula_entry_rec.created_by := rosetta_g_miss_num_map(p0_a10);
    ddp_formula_entry_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);
    ddp_formula_entry_rec.object_version_number := rosetta_g_miss_num_map(p0_a12);



    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.validate_form_ent_items(ddp_formula_entry_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_form_ent_rec(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  DATE := fnd_api.g_miss_date
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  DATE := fnd_api.g_miss_date
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  NUMBER := 0-1962.0724
    , p1_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_formula_entry_rec ams_formula_pvt.ams_formula_entry_rec_type;
    ddp_complete_formula_entry_rec ams_formula_pvt.ams_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_entry_rec.formula_entry_id := rosetta_g_miss_num_map(p0_a0);
    ddp_formula_entry_rec.formula_id := rosetta_g_miss_num_map(p0_a1);
    ddp_formula_entry_rec.order_number := rosetta_g_miss_num_map(p0_a2);
    ddp_formula_entry_rec.formula_entry_type := p0_a3;
    ddp_formula_entry_rec.formula_entry_value := p0_a4;
    ddp_formula_entry_rec.metric_column_value := p0_a5;
    ddp_formula_entry_rec.formula_entry_operator := p0_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_formula_entry_rec.last_updated_by := rosetta_g_miss_num_map(p0_a8);
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_formula_entry_rec.created_by := rosetta_g_miss_num_map(p0_a10);
    ddp_formula_entry_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);
    ddp_formula_entry_rec.object_version_number := rosetta_g_miss_num_map(p0_a12);

    ddp_complete_formula_entry_rec.formula_entry_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_formula_entry_rec.formula_id := rosetta_g_miss_num_map(p1_a1);
    ddp_complete_formula_entry_rec.order_number := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_formula_entry_rec.formula_entry_type := p1_a3;
    ddp_complete_formula_entry_rec.formula_entry_value := p1_a4;
    ddp_complete_formula_entry_rec.metric_column_value := p1_a5;
    ddp_complete_formula_entry_rec.formula_entry_operator := p1_a6;
    ddp_complete_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_complete_formula_entry_rec.last_updated_by := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_complete_formula_entry_rec.created_by := rosetta_g_miss_num_map(p1_a10);
    ddp_complete_formula_entry_rec.last_update_login := rosetta_g_miss_num_map(p1_a11);
    ddp_complete_formula_entry_rec.object_version_number := rosetta_g_miss_num_map(p1_a12);


    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.validate_form_ent_rec(ddp_formula_entry_rec,
      ddp_complete_formula_entry_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_form_ent_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  VARCHAR2
    , p1_a5 out nocopy  VARCHAR2
    , p1_a6 out nocopy  VARCHAR2
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  DATE
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  DATE := fnd_api.g_miss_date
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_formula_entry_rec ams_formula_pvt.ams_formula_entry_rec_type;
    ddx_complete_formula_entry_rec ams_formula_pvt.ams_formula_entry_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_formula_entry_rec.formula_entry_id := rosetta_g_miss_num_map(p0_a0);
    ddp_formula_entry_rec.formula_id := rosetta_g_miss_num_map(p0_a1);
    ddp_formula_entry_rec.order_number := rosetta_g_miss_num_map(p0_a2);
    ddp_formula_entry_rec.formula_entry_type := p0_a3;
    ddp_formula_entry_rec.formula_entry_value := p0_a4;
    ddp_formula_entry_rec.metric_column_value := p0_a5;
    ddp_formula_entry_rec.formula_entry_operator := p0_a6;
    ddp_formula_entry_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_formula_entry_rec.last_updated_by := rosetta_g_miss_num_map(p0_a8);
    ddp_formula_entry_rec.creation_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_formula_entry_rec.created_by := rosetta_g_miss_num_map(p0_a10);
    ddp_formula_entry_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);
    ddp_formula_entry_rec.object_version_number := rosetta_g_miss_num_map(p0_a12);


    -- here's the delegated call to the old PL/SQL routine
    ams_formula_pvt.complete_form_ent_rec(ddp_formula_entry_rec,
      ddx_complete_formula_entry_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_formula_entry_rec.formula_entry_id);
    p1_a1 := rosetta_g_miss_num_map(ddx_complete_formula_entry_rec.formula_id);
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_formula_entry_rec.order_number);
    p1_a3 := ddx_complete_formula_entry_rec.formula_entry_type;
    p1_a4 := ddx_complete_formula_entry_rec.formula_entry_value;
    p1_a5 := ddx_complete_formula_entry_rec.metric_column_value;
    p1_a6 := ddx_complete_formula_entry_rec.formula_entry_operator;
    p1_a7 := ddx_complete_formula_entry_rec.last_update_date;
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_formula_entry_rec.last_updated_by);
    p1_a9 := ddx_complete_formula_entry_rec.creation_date;
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_formula_entry_rec.created_by);
    p1_a11 := rosetta_g_miss_num_map(ddx_complete_formula_entry_rec.last_update_login);
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_formula_entry_rec.object_version_number);
  end;

end ams_formula_pvt_w;

/
