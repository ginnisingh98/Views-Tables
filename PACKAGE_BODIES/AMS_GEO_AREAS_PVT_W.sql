--------------------------------------------------------
--  DDL for Package Body AMS_GEO_AREAS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_GEO_AREAS_PVT_W" as
  /* $Header: amswgeob.pls 115.6 2002/11/16 01:47:04 dbiswas ship $ */
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

  procedure create_geo_area(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_geo_area_id OUT NOCOPY  NUMBER
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
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
  )
  as
    ddp_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_geo_area_rec.activity_geo_area_id := rosetta_g_miss_num_map(p7_a0);
    ddp_geo_area_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_geo_area_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_geo_area_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_geo_area_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_geo_area_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_geo_area_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_geo_area_rec.act_geo_area_used_by_id := rosetta_g_miss_num_map(p7_a7);
    ddp_geo_area_rec.arc_act_geo_area_used_by := p7_a8;
    ddp_geo_area_rec.attribute_category := p7_a9;
    ddp_geo_area_rec.attribute1 := p7_a10;
    ddp_geo_area_rec.attribute2 := p7_a11;
    ddp_geo_area_rec.attribute3 := p7_a12;
    ddp_geo_area_rec.attribute4 := p7_a13;
    ddp_geo_area_rec.attribute5 := p7_a14;
    ddp_geo_area_rec.attribute6 := p7_a15;
    ddp_geo_area_rec.attribute7 := p7_a16;
    ddp_geo_area_rec.attribute8 := p7_a17;
    ddp_geo_area_rec.attribute9 := p7_a18;
    ddp_geo_area_rec.attribute10 := p7_a19;
    ddp_geo_area_rec.attribute11 := p7_a20;
    ddp_geo_area_rec.attribute12 := p7_a21;
    ddp_geo_area_rec.attribute13 := p7_a22;
    ddp_geo_area_rec.attribute14 := p7_a23;
    ddp_geo_area_rec.attribute15 := p7_a24;
    ddp_geo_area_rec.geo_area_type_code := p7_a25;
    ddp_geo_area_rec.geo_hierarchy_id := rosetta_g_miss_num_map(p7_a26);


    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.create_geo_area(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_geo_area_rec,
      x_geo_area_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_geo_area(p_api_version  NUMBER
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
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
  )
  as
    ddp_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_geo_area_rec.activity_geo_area_id := rosetta_g_miss_num_map(p7_a0);
    ddp_geo_area_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_geo_area_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_geo_area_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_geo_area_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_geo_area_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_geo_area_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_geo_area_rec.act_geo_area_used_by_id := rosetta_g_miss_num_map(p7_a7);
    ddp_geo_area_rec.arc_act_geo_area_used_by := p7_a8;
    ddp_geo_area_rec.attribute_category := p7_a9;
    ddp_geo_area_rec.attribute1 := p7_a10;
    ddp_geo_area_rec.attribute2 := p7_a11;
    ddp_geo_area_rec.attribute3 := p7_a12;
    ddp_geo_area_rec.attribute4 := p7_a13;
    ddp_geo_area_rec.attribute5 := p7_a14;
    ddp_geo_area_rec.attribute6 := p7_a15;
    ddp_geo_area_rec.attribute7 := p7_a16;
    ddp_geo_area_rec.attribute8 := p7_a17;
    ddp_geo_area_rec.attribute9 := p7_a18;
    ddp_geo_area_rec.attribute10 := p7_a19;
    ddp_geo_area_rec.attribute11 := p7_a20;
    ddp_geo_area_rec.attribute12 := p7_a21;
    ddp_geo_area_rec.attribute13 := p7_a22;
    ddp_geo_area_rec.attribute14 := p7_a23;
    ddp_geo_area_rec.attribute15 := p7_a24;
    ddp_geo_area_rec.geo_area_type_code := p7_a25;
    ddp_geo_area_rec.geo_hierarchy_id := rosetta_g_miss_num_map(p7_a26);

    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.update_geo_area(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_geo_area_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_geo_area(p_api_version  NUMBER
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
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  NUMBER := 0-1962.0724
  )
  as
    ddp_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_geo_area_rec.activity_geo_area_id := rosetta_g_miss_num_map(p6_a0);
    ddp_geo_area_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_geo_area_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_geo_area_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_geo_area_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_geo_area_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_geo_area_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_geo_area_rec.act_geo_area_used_by_id := rosetta_g_miss_num_map(p6_a7);
    ddp_geo_area_rec.arc_act_geo_area_used_by := p6_a8;
    ddp_geo_area_rec.attribute_category := p6_a9;
    ddp_geo_area_rec.attribute1 := p6_a10;
    ddp_geo_area_rec.attribute2 := p6_a11;
    ddp_geo_area_rec.attribute3 := p6_a12;
    ddp_geo_area_rec.attribute4 := p6_a13;
    ddp_geo_area_rec.attribute5 := p6_a14;
    ddp_geo_area_rec.attribute6 := p6_a15;
    ddp_geo_area_rec.attribute7 := p6_a16;
    ddp_geo_area_rec.attribute8 := p6_a17;
    ddp_geo_area_rec.attribute9 := p6_a18;
    ddp_geo_area_rec.attribute10 := p6_a19;
    ddp_geo_area_rec.attribute11 := p6_a20;
    ddp_geo_area_rec.attribute12 := p6_a21;
    ddp_geo_area_rec.attribute13 := p6_a22;
    ddp_geo_area_rec.attribute14 := p6_a23;
    ddp_geo_area_rec.attribute15 := p6_a24;
    ddp_geo_area_rec.geo_area_type_code := p6_a25;
    ddp_geo_area_rec.geo_hierarchy_id := rosetta_g_miss_num_map(p6_a26);

    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.validate_geo_area(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_geo_area_rec);

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
    , p2_a7  NUMBER := 0-1962.0724
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  VARCHAR2 := fnd_api.g_miss_char
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  NUMBER := 0-1962.0724
  )
  as
    ddp_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_geo_area_rec.activity_geo_area_id := rosetta_g_miss_num_map(p2_a0);
    ddp_geo_area_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a1);
    ddp_geo_area_rec.last_updated_by := rosetta_g_miss_num_map(p2_a2);
    ddp_geo_area_rec.creation_date := rosetta_g_miss_date_in_map(p2_a3);
    ddp_geo_area_rec.created_by := rosetta_g_miss_num_map(p2_a4);
    ddp_geo_area_rec.last_update_login := rosetta_g_miss_num_map(p2_a5);
    ddp_geo_area_rec.object_version_number := rosetta_g_miss_num_map(p2_a6);
    ddp_geo_area_rec.act_geo_area_used_by_id := rosetta_g_miss_num_map(p2_a7);
    ddp_geo_area_rec.arc_act_geo_area_used_by := p2_a8;
    ddp_geo_area_rec.attribute_category := p2_a9;
    ddp_geo_area_rec.attribute1 := p2_a10;
    ddp_geo_area_rec.attribute2 := p2_a11;
    ddp_geo_area_rec.attribute3 := p2_a12;
    ddp_geo_area_rec.attribute4 := p2_a13;
    ddp_geo_area_rec.attribute5 := p2_a14;
    ddp_geo_area_rec.attribute6 := p2_a15;
    ddp_geo_area_rec.attribute7 := p2_a16;
    ddp_geo_area_rec.attribute8 := p2_a17;
    ddp_geo_area_rec.attribute9 := p2_a18;
    ddp_geo_area_rec.attribute10 := p2_a19;
    ddp_geo_area_rec.attribute11 := p2_a20;
    ddp_geo_area_rec.attribute12 := p2_a21;
    ddp_geo_area_rec.attribute13 := p2_a22;
    ddp_geo_area_rec.attribute14 := p2_a23;
    ddp_geo_area_rec.attribute15 := p2_a24;
    ddp_geo_area_rec.geo_area_type_code := p2_a25;
    ddp_geo_area_rec.geo_hierarchy_id := rosetta_g_miss_num_map(p2_a26);

    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.check_items(p_validation_mode,
      x_return_status,
      ddp_geo_area_rec);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_geo_area_req_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
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
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
  )
  as
    ddp_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_geo_area_rec.activity_geo_area_id := rosetta_g_miss_num_map(p1_a0);
    ddp_geo_area_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_geo_area_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_geo_area_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_geo_area_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_geo_area_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_geo_area_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_geo_area_rec.act_geo_area_used_by_id := rosetta_g_miss_num_map(p1_a7);
    ddp_geo_area_rec.arc_act_geo_area_used_by := p1_a8;
    ddp_geo_area_rec.attribute_category := p1_a9;
    ddp_geo_area_rec.attribute1 := p1_a10;
    ddp_geo_area_rec.attribute2 := p1_a11;
    ddp_geo_area_rec.attribute3 := p1_a12;
    ddp_geo_area_rec.attribute4 := p1_a13;
    ddp_geo_area_rec.attribute5 := p1_a14;
    ddp_geo_area_rec.attribute6 := p1_a15;
    ddp_geo_area_rec.attribute7 := p1_a16;
    ddp_geo_area_rec.attribute8 := p1_a17;
    ddp_geo_area_rec.attribute9 := p1_a18;
    ddp_geo_area_rec.attribute10 := p1_a19;
    ddp_geo_area_rec.attribute11 := p1_a20;
    ddp_geo_area_rec.attribute12 := p1_a21;
    ddp_geo_area_rec.attribute13 := p1_a22;
    ddp_geo_area_rec.attribute14 := p1_a23;
    ddp_geo_area_rec.attribute15 := p1_a24;
    ddp_geo_area_rec.geo_area_type_code := p1_a25;
    ddp_geo_area_rec.geo_hierarchy_id := rosetta_g_miss_num_map(p1_a26);


    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.check_geo_area_req_items(p_validation_mode,
      ddp_geo_area_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_geo_area_uk_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
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
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
  )
  as
    ddp_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_geo_area_rec.activity_geo_area_id := rosetta_g_miss_num_map(p1_a0);
    ddp_geo_area_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_geo_area_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_geo_area_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_geo_area_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_geo_area_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_geo_area_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_geo_area_rec.act_geo_area_used_by_id := rosetta_g_miss_num_map(p1_a7);
    ddp_geo_area_rec.arc_act_geo_area_used_by := p1_a8;
    ddp_geo_area_rec.attribute_category := p1_a9;
    ddp_geo_area_rec.attribute1 := p1_a10;
    ddp_geo_area_rec.attribute2 := p1_a11;
    ddp_geo_area_rec.attribute3 := p1_a12;
    ddp_geo_area_rec.attribute4 := p1_a13;
    ddp_geo_area_rec.attribute5 := p1_a14;
    ddp_geo_area_rec.attribute6 := p1_a15;
    ddp_geo_area_rec.attribute7 := p1_a16;
    ddp_geo_area_rec.attribute8 := p1_a17;
    ddp_geo_area_rec.attribute9 := p1_a18;
    ddp_geo_area_rec.attribute10 := p1_a19;
    ddp_geo_area_rec.attribute11 := p1_a20;
    ddp_geo_area_rec.attribute12 := p1_a21;
    ddp_geo_area_rec.attribute13 := p1_a22;
    ddp_geo_area_rec.attribute14 := p1_a23;
    ddp_geo_area_rec.attribute15 := p1_a24;
    ddp_geo_area_rec.geo_area_type_code := p1_a25;
    ddp_geo_area_rec.geo_hierarchy_id := rosetta_g_miss_num_map(p1_a26);


    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.check_geo_area_uk_items(p_validation_mode,
      ddp_geo_area_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_geo_area_fk_items(x_return_status OUT NOCOPY  VARCHAR2
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
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
  )
  as
    ddp_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_geo_area_rec.activity_geo_area_id := rosetta_g_miss_num_map(p0_a0);
    ddp_geo_area_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_geo_area_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_geo_area_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_geo_area_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_geo_area_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_geo_area_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_geo_area_rec.act_geo_area_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddp_geo_area_rec.arc_act_geo_area_used_by := p0_a8;
    ddp_geo_area_rec.attribute_category := p0_a9;
    ddp_geo_area_rec.attribute1 := p0_a10;
    ddp_geo_area_rec.attribute2 := p0_a11;
    ddp_geo_area_rec.attribute3 := p0_a12;
    ddp_geo_area_rec.attribute4 := p0_a13;
    ddp_geo_area_rec.attribute5 := p0_a14;
    ddp_geo_area_rec.attribute6 := p0_a15;
    ddp_geo_area_rec.attribute7 := p0_a16;
    ddp_geo_area_rec.attribute8 := p0_a17;
    ddp_geo_area_rec.attribute9 := p0_a18;
    ddp_geo_area_rec.attribute10 := p0_a19;
    ddp_geo_area_rec.attribute11 := p0_a20;
    ddp_geo_area_rec.attribute12 := p0_a21;
    ddp_geo_area_rec.attribute13 := p0_a22;
    ddp_geo_area_rec.attribute14 := p0_a23;
    ddp_geo_area_rec.attribute15 := p0_a24;
    ddp_geo_area_rec.geo_area_type_code := p0_a25;
    ddp_geo_area_rec.geo_hierarchy_id := rosetta_g_miss_num_map(p0_a26);


    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.check_geo_area_fk_items(ddp_geo_area_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any

  end;

  procedure complete_geo_area_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  VARCHAR2
    , p1_a14 OUT NOCOPY  VARCHAR2
    , p1_a15 OUT NOCOPY  VARCHAR2
    , p1_a16 OUT NOCOPY  VARCHAR2
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  VARCHAR2
    , p1_a19 OUT NOCOPY  VARCHAR2
    , p1_a20 OUT NOCOPY  VARCHAR2
    , p1_a21 OUT NOCOPY  VARCHAR2
    , p1_a22 OUT NOCOPY  VARCHAR2
    , p1_a23 OUT NOCOPY  VARCHAR2
    , p1_a24 OUT NOCOPY  VARCHAR2
    , p1_a25 OUT NOCOPY  VARCHAR2
    , p1_a26 OUT NOCOPY  NUMBER
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
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
  )
  as
    ddp_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddx_complete_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_geo_area_rec.activity_geo_area_id := rosetta_g_miss_num_map(p0_a0);
    ddp_geo_area_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_geo_area_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_geo_area_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_geo_area_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_geo_area_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_geo_area_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_geo_area_rec.act_geo_area_used_by_id := rosetta_g_miss_num_map(p0_a7);
    ddp_geo_area_rec.arc_act_geo_area_used_by := p0_a8;
    ddp_geo_area_rec.attribute_category := p0_a9;
    ddp_geo_area_rec.attribute1 := p0_a10;
    ddp_geo_area_rec.attribute2 := p0_a11;
    ddp_geo_area_rec.attribute3 := p0_a12;
    ddp_geo_area_rec.attribute4 := p0_a13;
    ddp_geo_area_rec.attribute5 := p0_a14;
    ddp_geo_area_rec.attribute6 := p0_a15;
    ddp_geo_area_rec.attribute7 := p0_a16;
    ddp_geo_area_rec.attribute8 := p0_a17;
    ddp_geo_area_rec.attribute9 := p0_a18;
    ddp_geo_area_rec.attribute10 := p0_a19;
    ddp_geo_area_rec.attribute11 := p0_a20;
    ddp_geo_area_rec.attribute12 := p0_a21;
    ddp_geo_area_rec.attribute13 := p0_a22;
    ddp_geo_area_rec.attribute14 := p0_a23;
    ddp_geo_area_rec.attribute15 := p0_a24;
    ddp_geo_area_rec.geo_area_type_code := p0_a25;
    ddp_geo_area_rec.geo_hierarchy_id := rosetta_g_miss_num_map(p0_a26);


    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.complete_geo_area_rec(ddp_geo_area_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.activity_geo_area_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.act_geo_area_used_by_id);
    p1_a8 := ddx_complete_rec.arc_act_geo_area_used_by;
    p1_a9 := ddx_complete_rec.attribute_category;
    p1_a10 := ddx_complete_rec.attribute1;
    p1_a11 := ddx_complete_rec.attribute2;
    p1_a12 := ddx_complete_rec.attribute3;
    p1_a13 := ddx_complete_rec.attribute4;
    p1_a14 := ddx_complete_rec.attribute5;
    p1_a15 := ddx_complete_rec.attribute6;
    p1_a16 := ddx_complete_rec.attribute7;
    p1_a17 := ddx_complete_rec.attribute8;
    p1_a18 := ddx_complete_rec.attribute9;
    p1_a19 := ddx_complete_rec.attribute10;
    p1_a20 := ddx_complete_rec.attribute11;
    p1_a21 := ddx_complete_rec.attribute12;
    p1_a22 := ddx_complete_rec.attribute13;
    p1_a23 := ddx_complete_rec.attribute14;
    p1_a24 := ddx_complete_rec.attribute15;
    p1_a25 := ddx_complete_rec.geo_area_type_code;
    p1_a26 := rosetta_g_miss_num_map(ddx_complete_rec.geo_hierarchy_id);
  end;

  procedure init_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  VARCHAR2
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  VARCHAR2
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  VARCHAR2
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  VARCHAR2
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  VARCHAR2
    , p0_a20 OUT NOCOPY  VARCHAR2
    , p0_a21 OUT NOCOPY  VARCHAR2
    , p0_a22 OUT NOCOPY  VARCHAR2
    , p0_a23 OUT NOCOPY  VARCHAR2
    , p0_a24 OUT NOCOPY  VARCHAR2
    , p0_a25 OUT NOCOPY  VARCHAR2
    , p0_a26 OUT NOCOPY  NUMBER
  )
  as
    ddx_geo_area_rec ams_geo_areas_pvt.geo_area_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_geo_areas_pvt.init_rec(ddx_geo_area_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_geo_area_rec.activity_geo_area_id);
    p0_a1 := ddx_geo_area_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_geo_area_rec.last_updated_by);
    p0_a3 := ddx_geo_area_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_geo_area_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_geo_area_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_geo_area_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_geo_area_rec.act_geo_area_used_by_id);
    p0_a8 := ddx_geo_area_rec.arc_act_geo_area_used_by;
    p0_a9 := ddx_geo_area_rec.attribute_category;
    p0_a10 := ddx_geo_area_rec.attribute1;
    p0_a11 := ddx_geo_area_rec.attribute2;
    p0_a12 := ddx_geo_area_rec.attribute3;
    p0_a13 := ddx_geo_area_rec.attribute4;
    p0_a14 := ddx_geo_area_rec.attribute5;
    p0_a15 := ddx_geo_area_rec.attribute6;
    p0_a16 := ddx_geo_area_rec.attribute7;
    p0_a17 := ddx_geo_area_rec.attribute8;
    p0_a18 := ddx_geo_area_rec.attribute9;
    p0_a19 := ddx_geo_area_rec.attribute10;
    p0_a20 := ddx_geo_area_rec.attribute11;
    p0_a21 := ddx_geo_area_rec.attribute12;
    p0_a22 := ddx_geo_area_rec.attribute13;
    p0_a23 := ddx_geo_area_rec.attribute14;
    p0_a24 := ddx_geo_area_rec.attribute15;
    p0_a25 := ddx_geo_area_rec.geo_area_type_code;
    p0_a26 := rosetta_g_miss_num_map(ddx_geo_area_rec.geo_hierarchy_id);
  end;

end ams_geo_areas_pvt_w;

/
