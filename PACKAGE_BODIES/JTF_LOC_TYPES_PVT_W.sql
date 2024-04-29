--------------------------------------------------------
--  DDL for Package Body JTF_LOC_TYPES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_TYPES_PVT_W" as
  /* $Header: jtfwlotb.pls 120.2 2005/08/18 22:56:10 stopiwal ship $ */
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

  procedure update_loc_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
  )
  as
    ddp_loc_type_rec jtf_loc_types_pvt.loc_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_loc_type_rec.location_type_id := rosetta_g_miss_num_map(p7_a0);
    ddp_loc_type_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_loc_type_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_loc_type_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_loc_type_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_loc_type_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_loc_type_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_loc_type_rec.location_type_code := p7_a7;
    ddp_loc_type_rec.location_type_name := p7_a8;
    ddp_loc_type_rec.description := p7_a9;

    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_types_pvt.update_loc_type(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_loc_type_rec);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any







  end;

  procedure check_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  DATE := fnd_api.g_miss_date
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_type_rec jtf_loc_types_pvt.loc_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_loc_type_rec.location_type_id := rosetta_g_miss_num_map(p2_a0);
    ddp_loc_type_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_loc_type_rec.last_updated_by := rosetta_g_miss_num_map(p2_a2);
    ddp_loc_type_rec.creation_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_loc_type_rec.created_by := rosetta_g_miss_num_map(p2_a4);
    ddp_loc_type_rec.last_update_login := rosetta_g_miss_num_map(p2_a5);
    ddp_loc_type_rec.object_version_number := rosetta_g_miss_num_map(p2_a6);
    ddp_loc_type_rec.location_type_code := p2_a7;
    ddp_loc_type_rec.location_type_name := p2_a8;
    ddp_loc_type_rec.description := p2_a9;

    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_types_pvt.check_items(p_validation_mode,
      x_return_status,
      ddp_loc_type_rec);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any


  end;

  procedure check_loc_type_req_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
  )
  as
    ddp_loc_type_rec jtf_loc_types_pvt.loc_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loc_type_rec.location_type_id := rosetta_g_miss_num_map(p1_a0);
    ddp_loc_type_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_loc_type_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_loc_type_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_loc_type_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_loc_type_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_loc_type_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_loc_type_rec.location_type_code := p1_a7;
    ddp_loc_type_rec.location_type_name := p1_a8;
    ddp_loc_type_rec.description := p1_a9;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_types_pvt.check_loc_type_req_items(p_validation_mode,
      ddp_loc_type_rec,
      x_return_status);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any


  end;

  procedure check_loc_type_uk_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
  )
  as
    ddp_loc_type_rec jtf_loc_types_pvt.loc_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loc_type_rec.location_type_id := rosetta_g_miss_num_map(p1_a0);
    ddp_loc_type_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_loc_type_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_loc_type_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_loc_type_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_loc_type_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_loc_type_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_loc_type_rec.location_type_code := p1_a7;
    ddp_loc_type_rec.location_type_name := p1_a8;
    ddp_loc_type_rec.description := p1_a9;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_types_pvt.check_loc_type_uk_items(p_validation_mode,
      ddp_loc_type_rec,
      x_return_status);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any


  end;

end jtf_loc_types_pvt_w;

/
