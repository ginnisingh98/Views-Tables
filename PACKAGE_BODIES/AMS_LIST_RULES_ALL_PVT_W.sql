--------------------------------------------------------
--  DDL for Package Body AMS_LIST_RULES_ALL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_RULES_ALL_PVT_W" as
  /* $Header: amswruab.pls 115.5 2002/11/22 08:57:47 jieli ship $ */
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

  procedure create_list_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_list_rule_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_list_rule_rec.list_rule_name := p7_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p7_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_list_rule_rec.description := p7_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p7_a12);
    ddp_list_rule_rec.list_rule_type := p7_a13;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.create_list_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_rule_rec,
      x_list_rule_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_list_rule(p_api_version  NUMBER
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
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_list_rule_rec.list_rule_name := p7_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p7_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_list_rule_rec.description := p7_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p7_a12);
    ddp_list_rule_rec.list_rule_type := p7_a13;

    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.update_list_rule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_rule_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_list_rule(p_api_version  NUMBER
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
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p6_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_list_rule_rec.list_rule_name := p6_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p6_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_list_rule_rec.description := p6_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p6_a12);
    ddp_list_rule_rec.list_rule_type := p6_a13;

    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.validate_list_rule(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_rule_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  DATE := fnd_api.g_miss_date
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  NUMBER := 0-1962.0724
    , p2_a9  DATE := fnd_api.g_miss_date
    , p2_a10  DATE := fnd_api.g_miss_date
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  NUMBER := 0-1962.0724
    , p2_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p2_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p2_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p2_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p2_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p2_a6);
    ddp_list_rule_rec.list_rule_name := p2_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p2_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p2_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p2_a10);
    ddp_list_rule_rec.description := p2_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p2_a12);
    ddp_list_rule_rec.list_rule_type := p2_a13;

    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.check_items(p_validation_mode,
      x_return_status,
      ddp_list_rule_rec);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_req_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  DATE := fnd_api.g_miss_date
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p1_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_list_rule_rec.list_rule_name := p1_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p1_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_list_rule_rec.description := p1_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p1_a12);
    ddp_list_rule_rec.list_rule_type := p1_a13;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.check_req_items(p_validation_mode,
      ddp_list_rule_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_uk_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  DATE := fnd_api.g_miss_date
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p1_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_list_rule_rec.list_rule_name := p1_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p1_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_list_rule_rec.description := p1_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p1_a12);
    ddp_list_rule_rec.list_rule_type := p1_a13;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.check_uk_items(p_validation_mode,
      ddp_list_rule_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_lookup_items(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_list_rule_rec.list_rule_name := p0_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p0_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_list_rule_rec.description := p0_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p0_a12);
    ddp_list_rule_rec.list_rule_type := p0_a13;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.check_lookup_items(ddp_list_rule_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure check_record(x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  DATE := fnd_api.g_miss_date
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddp_complete_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_list_rule_rec.list_rule_name := p0_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p0_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_list_rule_rec.description := p0_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p0_a12);
    ddp_list_rule_rec.list_rule_type := p0_a13;

    ddp_complete_rec.list_rule_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.list_rule_name := p1_a7;
    ddp_complete_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.active_from_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_complete_rec.active_to_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_complete_rec.description := p1_a11;
    ddp_complete_rec.org_id := rosetta_g_miss_num_map(p1_a12);
    ddp_complete_rec.list_rule_type := p1_a13;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.check_record(ddp_list_rule_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure complete_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  VARCHAR2
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  DATE
    , p1_a10 OUT NOCOPY  DATE
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  NUMBER
    , p1_a13 OUT NOCOPY  VARCHAR
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR := fnd_api.g_miss_char
  )
  as
    ddp_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddx_complete_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_list_rule_rec.list_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_list_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_list_rule_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_list_rule_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_list_rule_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_list_rule_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_list_rule_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_list_rule_rec.list_rule_name := p0_a7;
    ddp_list_rule_rec.weightage_for_dedupe := rosetta_g_miss_num_map(p0_a8);
    ddp_list_rule_rec.active_from_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_list_rule_rec.active_to_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_list_rule_rec.description := p0_a11;
    ddp_list_rule_rec.org_id := rosetta_g_miss_num_map(p0_a12);
    ddp_list_rule_rec.list_rule_type := p0_a13;


    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.complete_rec(ddp_list_rule_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.list_rule_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.list_rule_name;
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.weightage_for_dedupe);
    p1_a9 := ddx_complete_rec.active_from_date;
    p1_a10 := ddx_complete_rec.active_to_date;
    p1_a11 := ddx_complete_rec.description;
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.org_id);
    p1_a13 := ddx_complete_rec.list_rule_type;
  end;

  procedure init_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  VARCHAR2
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  DATE
    , p0_a10 OUT NOCOPY  DATE
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  NUMBER
    , p0_a13 OUT NOCOPY  VARCHAR
  )
  as
    ddx_list_rule_rec ams_list_rules_all_pvt.list_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_list_rules_all_pvt.init_rec(ddx_list_rule_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_list_rule_rec.list_rule_id);
    p0_a1 := ddx_list_rule_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_list_rule_rec.last_updated_by);
    p0_a3 := ddx_list_rule_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_list_rule_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_list_rule_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_list_rule_rec.object_version_number);
    p0_a7 := ddx_list_rule_rec.list_rule_name;
    p0_a8 := rosetta_g_miss_num_map(ddx_list_rule_rec.weightage_for_dedupe);
    p0_a9 := ddx_list_rule_rec.active_from_date;
    p0_a10 := ddx_list_rule_rec.active_to_date;
    p0_a11 := ddx_list_rule_rec.description;
    p0_a12 := rosetta_g_miss_num_map(ddx_list_rule_rec.org_id);
    p0_a13 := ddx_list_rule_rec.list_rule_type;
  end;

end ams_list_rules_all_pvt_w;

/
