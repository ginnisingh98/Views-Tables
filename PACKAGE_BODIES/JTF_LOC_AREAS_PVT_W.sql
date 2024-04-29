--------------------------------------------------------
--  DDL for Package Body JTF_LOC_AREAS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_AREAS_PVT_W" as
  /* $Header: jtfwloab.pls 120.2 2005/08/18 22:55:53 stopiwal ship $ */
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

  procedure create_loc_area(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_loc_area_id OUT NOCOPY /* file.sql.39 change */  NUMBER
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
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p7_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p7_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p7_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p7_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_loc_area_rec.location_type_code := p7_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a13);
    ddp_loc_area_rec.location_area_code := p7_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p7_a15);
    ddp_loc_area_rec.orig_system_ref := p7_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p7_a17);
    ddp_loc_area_rec.location_area_name := p7_a18;
    ddp_loc_area_rec.location_area_description := p7_a19;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.create_loc_area(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_loc_area_rec,
      x_loc_area_id);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any








  end;

  procedure update_loc_area(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_remove_flag  VARCHAR2
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
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p7_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p7_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p7_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p7_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_loc_area_rec.location_type_code := p7_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a13);
    ddp_loc_area_rec.location_area_code := p7_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p7_a15);
    ddp_loc_area_rec.orig_system_ref := p7_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p7_a17);
    ddp_loc_area_rec.location_area_name := p7_a18;
    ddp_loc_area_rec.location_area_description := p7_a19;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.update_loc_area(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_loc_area_rec,
      p_remove_flag);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any








  end;

  procedure validate_loc_area(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count OUT NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  DATE := fnd_api.g_miss_date
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p6_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p6_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p6_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p6_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_loc_area_rec.location_type_code := p6_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p6_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p6_a13);
    ddp_loc_area_rec.location_area_code := p6_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p6_a15);
    ddp_loc_area_rec.orig_system_ref := p6_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p6_a17);
    ddp_loc_area_rec.location_area_name := p6_a18;
    ddp_loc_area_rec.location_area_description := p6_a19;

    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.validate_loc_area(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_loc_area_rec);

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
    , p2_a7  NUMBER := 0-1962.0724
    , p2_a8  NUMBER := 0-1962.0724
    , p2_a9  NUMBER := 0-1962.0724
    , p2_a10  DATE := fnd_api.g_miss_date
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  DATE := fnd_api.g_miss_date
    , p2_a13  DATE := fnd_api.g_miss_date
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  NUMBER := 0-1962.0724
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p2_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p2_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p2_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p2_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p2_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p2_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p2_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p2_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p2_a10);
    ddp_loc_area_rec.location_type_code := p2_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p2_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p2_a13);
    ddp_loc_area_rec.location_area_code := p2_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p2_a15);
    ddp_loc_area_rec.orig_system_ref := p2_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p2_a17);
    ddp_loc_area_rec.location_area_name := p2_a18;
    ddp_loc_area_rec.location_area_description := p2_a19;

    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.check_items(p_validation_mode,
      x_return_status,
      ddp_loc_area_rec);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any


  end;

  procedure check_loc_area_req_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p1_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p1_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p1_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_loc_area_rec.location_type_code := p1_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a13);
    ddp_loc_area_rec.location_area_code := p1_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p1_a15);
    ddp_loc_area_rec.orig_system_ref := p1_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p1_a17);
    ddp_loc_area_rec.location_area_name := p1_a18;
    ddp_loc_area_rec.location_area_description := p1_a19;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.check_loc_area_req_items(p_validation_mode,
      ddp_loc_area_rec,
      x_return_status);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any


  end;

  procedure check_loc_area_uk_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p1_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p1_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p1_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_loc_area_rec.location_type_code := p1_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a13);
    ddp_loc_area_rec.location_area_code := p1_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p1_a15);
    ddp_loc_area_rec.orig_system_ref := p1_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p1_a17);
    ddp_loc_area_rec.location_area_name := p1_a18;
    ddp_loc_area_rec.location_area_description := p1_a19;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.check_loc_area_uk_items(p_validation_mode,
      ddp_loc_area_rec,
      x_return_status);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any


  end;

  procedure check_loc_area_fk_items(x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p0_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p0_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p0_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_loc_area_rec.location_type_code := p0_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a13);
    ddp_loc_area_rec.location_area_code := p0_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p0_a15);
    ddp_loc_area_rec.orig_system_ref := p0_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p0_a17);
    ddp_loc_area_rec.location_area_name := p0_a18;
    ddp_loc_area_rec.location_area_description := p0_a19;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.check_loc_area_fk_items(ddp_loc_area_rec,
      x_return_status);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any

  end;

  procedure check_record(x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
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
    , p1_a10  DATE := fnd_api.g_miss_date
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  DATE := fnd_api.g_miss_date
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddp_complete_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p0_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p0_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p0_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_loc_area_rec.location_type_code := p0_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a13);
    ddp_loc_area_rec.location_area_code := p0_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p0_a15);
    ddp_loc_area_rec.orig_system_ref := p0_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p0_a17);
    ddp_loc_area_rec.location_area_name := p0_a18;
    ddp_loc_area_rec.location_area_description := p0_a19;

    ddp_complete_rec.location_area_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.request_id := rosetta_g_miss_num_map(p1_a7);
    ddp_complete_rec.program_application_id := rosetta_g_miss_num_map(p1_a8);
    ddp_complete_rec.program_id := rosetta_g_miss_num_map(p1_a9);
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a10);
    ddp_complete_rec.location_type_code := p1_a11;
    ddp_complete_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a12);
    ddp_complete_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a13);
    ddp_complete_rec.location_area_code := p1_a14;
    ddp_complete_rec.orig_system_id := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.orig_system_ref := p1_a16;
    ddp_complete_rec.parent_location_area_id := rosetta_g_miss_num_map(p1_a17);
    ddp_complete_rec.location_area_name := p1_a18;
    ddp_complete_rec.location_area_description := p1_a19;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.check_record(ddp_loc_area_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any


  end;

  procedure complete_loc_area_rec(p1_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a1 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a2 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a3 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a4 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a5 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a6 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a7 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a8 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a9 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a10 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a11 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a12 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a13 OUT NOCOPY /* file.sql.39 change */  DATE
    , p1_a14 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a15 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a16 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a17 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a18 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a19 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  DATE := fnd_api.g_miss_date
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddx_complete_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_loc_area_rec.location_area_id := rosetta_g_miss_num_map(p0_a0);
    ddp_loc_area_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_loc_area_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_loc_area_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_loc_area_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_loc_area_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_loc_area_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_loc_area_rec.request_id := rosetta_g_miss_num_map(p0_a7);
    ddp_loc_area_rec.program_application_id := rosetta_g_miss_num_map(p0_a8);
    ddp_loc_area_rec.program_id := rosetta_g_miss_num_map(p0_a9);
    ddp_loc_area_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_loc_area_rec.location_type_code := p0_a11;
    ddp_loc_area_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a12);
    ddp_loc_area_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a13);
    ddp_loc_area_rec.location_area_code := p0_a14;
    ddp_loc_area_rec.orig_system_id := rosetta_g_miss_num_map(p0_a15);
    ddp_loc_area_rec.orig_system_ref := p0_a16;
    ddp_loc_area_rec.parent_location_area_id := rosetta_g_miss_num_map(p0_a17);
    ddp_loc_area_rec.location_area_name := p0_a18;
    ddp_loc_area_rec.location_area_description := p0_a19;


    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.complete_loc_area_rec(ddp_loc_area_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.location_area_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.request_id);
    p1_a8 := rosetta_g_miss_num_map(ddx_complete_rec.program_application_id);
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.program_id);
    p1_a10 := ddx_complete_rec.program_update_date;
    p1_a11 := ddx_complete_rec.location_type_code;
    p1_a12 := ddx_complete_rec.start_date_active;
    p1_a13 := ddx_complete_rec.end_date_active;
    p1_a14 := ddx_complete_rec.location_area_code;
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.orig_system_id);
    p1_a16 := ddx_complete_rec.orig_system_ref;
    p1_a17 := rosetta_g_miss_num_map(ddx_complete_rec.parent_location_area_id);
    p1_a18 := ddx_complete_rec.location_area_name;
    p1_a19 := ddx_complete_rec.location_area_description;
  end;

  procedure init_rec(p0_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a1 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a2 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a3 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a4 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a5 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a6 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a7 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a8 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a9 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a10 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a11 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a12 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a13 OUT NOCOPY /* file.sql.39 change */  DATE
    , p0_a14 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a15 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a16 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a17 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p0_a18 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a19 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  )
  as
    ddx_loc_area_rec jtf_loc_areas_pvt.loc_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    jtf_loc_areas_pvt.init_rec(ddx_loc_area_rec);

    -- copy data back from the local OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_loc_area_rec.location_area_id);
    p0_a1 := ddx_loc_area_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_loc_area_rec.last_updated_by);
    p0_a3 := ddx_loc_area_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_loc_area_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_loc_area_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_loc_area_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_loc_area_rec.request_id);
    p0_a8 := rosetta_g_miss_num_map(ddx_loc_area_rec.program_application_id);
    p0_a9 := rosetta_g_miss_num_map(ddx_loc_area_rec.program_id);
    p0_a10 := ddx_loc_area_rec.program_update_date;
    p0_a11 := ddx_loc_area_rec.location_type_code;
    p0_a12 := ddx_loc_area_rec.start_date_active;
    p0_a13 := ddx_loc_area_rec.end_date_active;
    p0_a14 := ddx_loc_area_rec.location_area_code;
    p0_a15 := rosetta_g_miss_num_map(ddx_loc_area_rec.orig_system_id);
    p0_a16 := ddx_loc_area_rec.orig_system_ref;
    p0_a17 := rosetta_g_miss_num_map(ddx_loc_area_rec.parent_location_area_id);
    p0_a18 := ddx_loc_area_rec.location_area_name;
    p0_a19 := ddx_loc_area_rec.location_area_description;
  end;

end jtf_loc_areas_pvt_w;

/
