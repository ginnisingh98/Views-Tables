--------------------------------------------------------
--  DDL for Package Body AMS_LISTSOURCETYPE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTSOURCETYPE_PVT_W" as
  /* $Header: amswlstb.pls 115.11 2002/11/22 08:57:43 jieli ship $ */
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

  procedure create_listsourcetype(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_list_source_type_id OUT NOCOPY  NUMBER
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
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listsrctype_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_listsrctype_rec.list_source_type_id := rosetta_g_miss_num_map(p7_a0);
    ddp_listsrctype_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_listsrctype_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_listsrctype_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_listsrctype_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_listsrctype_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_listsrctype_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_listsrctype_rec.list_source_name := p7_a7;
    ddp_listsrctype_rec.list_source_type := p7_a8;
    ddp_listsrctype_rec.source_type_code := p7_a9;
    ddp_listsrctype_rec.source_object_name := p7_a10;
    ddp_listsrctype_rec.master_source_type_flag := p7_a11;
    ddp_listsrctype_rec.source_object_pk_field := p7_a12;
    ddp_listsrctype_rec.enabled_flag := p7_a13;
    ddp_listsrctype_rec.description := p7_a14;
    ddp_listsrctype_rec.view_application_id := rosetta_g_miss_num_map(p7_a15);
    ddp_listsrctype_rec.java_class_name := p7_a16;
    ddp_listsrctype_rec.import_type := p7_a17;
    ddp_listsrctype_rec.arc_act_src_used_by := p7_a18;
    ddp_listsrctype_rec.source_category := p7_a19;


    -- here's the delegated call to the old PL/SQL routine
    ams_listsourcetype_pvt.create_listsourcetype(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listsrctype_rec,
      x_list_source_type_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_listsourcetype(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listsrctype_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_listsrctype_rec.list_source_type_id := rosetta_g_miss_num_map(p7_a0);
    ddp_listsrctype_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_listsrctype_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_listsrctype_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_listsrctype_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_listsrctype_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_listsrctype_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_listsrctype_rec.list_source_name := p7_a7;
    ddp_listsrctype_rec.list_source_type := p7_a8;
    ddp_listsrctype_rec.source_type_code := p7_a9;
    ddp_listsrctype_rec.source_object_name := p7_a10;
    ddp_listsrctype_rec.master_source_type_flag := p7_a11;
    ddp_listsrctype_rec.source_object_pk_field := p7_a12;
    ddp_listsrctype_rec.enabled_flag := p7_a13;
    ddp_listsrctype_rec.description := p7_a14;
    ddp_listsrctype_rec.view_application_id := rosetta_g_miss_num_map(p7_a15);
    ddp_listsrctype_rec.java_class_name := p7_a16;
    ddp_listsrctype_rec.import_type := p7_a17;
    ddp_listsrctype_rec.arc_act_src_used_by := p7_a18;
    ddp_listsrctype_rec.source_category := p7_a19;

    -- here's the delegated call to the old PL/SQL routine
    ams_listsourcetype_pvt.update_listsourcetype(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listsrctype_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_listsourcetype(p_api_version  NUMBER
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
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listsrctype_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_listsrctype_rec.list_source_type_id := rosetta_g_miss_num_map(p7_a0);
    ddp_listsrctype_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_listsrctype_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_listsrctype_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_listsrctype_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_listsrctype_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_listsrctype_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_listsrctype_rec.list_source_name := p7_a7;
    ddp_listsrctype_rec.list_source_type := p7_a8;
    ddp_listsrctype_rec.source_type_code := p7_a9;
    ddp_listsrctype_rec.source_object_name := p7_a10;
    ddp_listsrctype_rec.master_source_type_flag := p7_a11;
    ddp_listsrctype_rec.source_object_pk_field := p7_a12;
    ddp_listsrctype_rec.enabled_flag := p7_a13;
    ddp_listsrctype_rec.description := p7_a14;
    ddp_listsrctype_rec.view_application_id := rosetta_g_miss_num_map(p7_a15);
    ddp_listsrctype_rec.java_class_name := p7_a16;
    ddp_listsrctype_rec.import_type := p7_a17;
    ddp_listsrctype_rec.arc_act_src_used_by := p7_a18;
    ddp_listsrctype_rec.source_category := p7_a19;

    -- here's the delegated call to the old PL/SQL routine
    ams_listsourcetype_pvt.validate_listsourcetype(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listsrctype_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_listsourcetype_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
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
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listsrctype_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listsrctype_rec.list_source_type_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listsrctype_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listsrctype_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listsrctype_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listsrctype_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listsrctype_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listsrctype_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listsrctype_rec.list_source_name := p0_a7;
    ddp_listsrctype_rec.list_source_type := p0_a8;
    ddp_listsrctype_rec.source_type_code := p0_a9;
    ddp_listsrctype_rec.source_object_name := p0_a10;
    ddp_listsrctype_rec.master_source_type_flag := p0_a11;
    ddp_listsrctype_rec.source_object_pk_field := p0_a12;
    ddp_listsrctype_rec.enabled_flag := p0_a13;
    ddp_listsrctype_rec.description := p0_a14;
    ddp_listsrctype_rec.view_application_id := rosetta_g_miss_num_map(p0_a15);
    ddp_listsrctype_rec.java_class_name := p0_a16;
    ddp_listsrctype_rec.import_type := p0_a17;
    ddp_listsrctype_rec.arc_act_src_used_by := p0_a18;
    ddp_listsrctype_rec.source_category := p0_a19;



    -- here's the delegated call to the old PL/SQL routine
    ams_listsourcetype_pvt.check_listsourcetype_items(ddp_listsrctype_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_listsourcetype_record(x_return_status OUT NOCOPY  VARCHAR2
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
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
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
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listsrctype_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddp_complete_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listsrctype_rec.list_source_type_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listsrctype_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listsrctype_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listsrctype_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listsrctype_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listsrctype_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listsrctype_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listsrctype_rec.list_source_name := p0_a7;
    ddp_listsrctype_rec.list_source_type := p0_a8;
    ddp_listsrctype_rec.source_type_code := p0_a9;
    ddp_listsrctype_rec.source_object_name := p0_a10;
    ddp_listsrctype_rec.master_source_type_flag := p0_a11;
    ddp_listsrctype_rec.source_object_pk_field := p0_a12;
    ddp_listsrctype_rec.enabled_flag := p0_a13;
    ddp_listsrctype_rec.description := p0_a14;
    ddp_listsrctype_rec.view_application_id := rosetta_g_miss_num_map(p0_a15);
    ddp_listsrctype_rec.java_class_name := p0_a16;
    ddp_listsrctype_rec.import_type := p0_a17;
    ddp_listsrctype_rec.arc_act_src_used_by := p0_a18;
    ddp_listsrctype_rec.source_category := p0_a19;

    ddp_complete_rec.list_source_type_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.list_source_name := p1_a7;
    ddp_complete_rec.list_source_type := p1_a8;
    ddp_complete_rec.source_type_code := p1_a9;
    ddp_complete_rec.source_object_name := p1_a10;
    ddp_complete_rec.master_source_type_flag := p1_a11;
    ddp_complete_rec.source_object_pk_field := p1_a12;
    ddp_complete_rec.enabled_flag := p1_a13;
    ddp_complete_rec.description := p1_a14;
    ddp_complete_rec.view_application_id := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.java_class_name := p1_a16;
    ddp_complete_rec.import_type := p1_a17;
    ddp_complete_rec.arc_act_src_used_by := p1_a18;
    ddp_complete_rec.source_category := p1_a19;


    -- here's the delegated call to the old PL/SQL routine
    ams_listsourcetype_pvt.check_listsourcetype_record(ddp_listsrctype_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure init_listsourcetype_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  VARCHAR2
    , p0_a8 OUT NOCOPY  VARCHAR2
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  VARCHAR2
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  NUMBER
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  VARCHAR2
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  VARCHAR2
  )
  as
    ddx_listsrctype_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_listsourcetype_pvt.init_listsourcetype_rec(ddx_listsrctype_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_listsrctype_rec.list_source_type_id);
    p0_a1 := ddx_listsrctype_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_listsrctype_rec.last_updated_by);
    p0_a3 := ddx_listsrctype_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_listsrctype_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_listsrctype_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_listsrctype_rec.object_version_number);
    p0_a7 := ddx_listsrctype_rec.list_source_name;
    p0_a8 := ddx_listsrctype_rec.list_source_type;
    p0_a9 := ddx_listsrctype_rec.source_type_code;
    p0_a10 := ddx_listsrctype_rec.source_object_name;
    p0_a11 := ddx_listsrctype_rec.master_source_type_flag;
    p0_a12 := ddx_listsrctype_rec.source_object_pk_field;
    p0_a13 := ddx_listsrctype_rec.enabled_flag;
    p0_a14 := ddx_listsrctype_rec.description;
    p0_a15 := rosetta_g_miss_num_map(ddx_listsrctype_rec.view_application_id);
    p0_a16 := ddx_listsrctype_rec.java_class_name;
    p0_a17 := ddx_listsrctype_rec.import_type;
    p0_a18 := ddx_listsrctype_rec.arc_act_src_used_by;
    p0_a19 := ddx_listsrctype_rec.source_category;
  end;

  procedure complete_listsourcetype_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  VARCHAR2
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  VARCHAR2
    , p1_a14 OUT NOCOPY  VARCHAR2
    , p1_a15 OUT NOCOPY  NUMBER
    , p1_a16 OUT NOCOPY  VARCHAR2
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  VARCHAR2
    , p1_a19 OUT NOCOPY  VARCHAR2
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
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listsrctype_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddx_complete_rec ams_listsourcetype_pvt.listsourcetype_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listsrctype_rec.list_source_type_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listsrctype_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listsrctype_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listsrctype_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listsrctype_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listsrctype_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listsrctype_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listsrctype_rec.list_source_name := p0_a7;
    ddp_listsrctype_rec.list_source_type := p0_a8;
    ddp_listsrctype_rec.source_type_code := p0_a9;
    ddp_listsrctype_rec.source_object_name := p0_a10;
    ddp_listsrctype_rec.master_source_type_flag := p0_a11;
    ddp_listsrctype_rec.source_object_pk_field := p0_a12;
    ddp_listsrctype_rec.enabled_flag := p0_a13;
    ddp_listsrctype_rec.description := p0_a14;
    ddp_listsrctype_rec.view_application_id := rosetta_g_miss_num_map(p0_a15);
    ddp_listsrctype_rec.java_class_name := p0_a16;
    ddp_listsrctype_rec.import_type := p0_a17;
    ddp_listsrctype_rec.arc_act_src_used_by := p0_a18;
    ddp_listsrctype_rec.source_category := p0_a19;


    -- here's the delegated call to the old PL/SQL routine
    ams_listsourcetype_pvt.complete_listsourcetype_rec(ddp_listsrctype_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.list_source_type_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.list_source_name;
    p1_a8 := ddx_complete_rec.list_source_type;
    p1_a9 := ddx_complete_rec.source_type_code;
    p1_a10 := ddx_complete_rec.source_object_name;
    p1_a11 := ddx_complete_rec.master_source_type_flag;
    p1_a12 := ddx_complete_rec.source_object_pk_field;
    p1_a13 := ddx_complete_rec.enabled_flag;
    p1_a14 := ddx_complete_rec.description;
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.view_application_id);
    p1_a16 := ddx_complete_rec.java_class_name;
    p1_a17 := ddx_complete_rec.import_type;
    p1_a18 := ddx_complete_rec.arc_act_src_used_by;
    p1_a19 := ddx_complete_rec.source_category;
  end;

end ams_listsourcetype_pvt_w;

/
