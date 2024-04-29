--------------------------------------------------------
--  DDL for Package Body AMS_LISTFIELD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTFIELD_PVT_W" as
  /* $Header: amswlfdb.pls 115.5 2002/11/22 08:57:07 jieli ship $ */
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

  procedure update_listfield(p_api_version  NUMBER
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
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listfield_rec ams_listfield_pvt.list_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_listfield_rec.list_field_id := rosetta_g_miss_num_map(p7_a0);
    ddp_listfield_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_listfield_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_listfield_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_listfield_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_listfield_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_listfield_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_listfield_rec.field_table_name := p7_a7;
    ddp_listfield_rec.field_column_name := p7_a8;
    ddp_listfield_rec.column_data_type := p7_a9;
    ddp_listfield_rec.column_data_length := rosetta_g_miss_num_map(p7_a10);
    ddp_listfield_rec.enabled_flag := p7_a11;
    ddp_listfield_rec.list_type_field_apply_on := p7_a12;
    ddp_listfield_rec.description := p7_a13;

    -- here's the delegated call to the old PL/SQL routine
    ams_listfield_pvt.update_listfield(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listfield_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_listfield(p_api_version  NUMBER
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
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listfield_rec ams_listfield_pvt.list_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_listfield_rec.list_field_id := rosetta_g_miss_num_map(p7_a0);
    ddp_listfield_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_listfield_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_listfield_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_listfield_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_listfield_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_listfield_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_listfield_rec.field_table_name := p7_a7;
    ddp_listfield_rec.field_column_name := p7_a8;
    ddp_listfield_rec.column_data_type := p7_a9;
    ddp_listfield_rec.column_data_length := rosetta_g_miss_num_map(p7_a10);
    ddp_listfield_rec.enabled_flag := p7_a11;
    ddp_listfield_rec.list_type_field_apply_on := p7_a12;
    ddp_listfield_rec.description := p7_a13;

    -- here's the delegated call to the old PL/SQL routine
    ams_listfield_pvt.validate_listfield(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_listfield_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_listfield_items(p_validation_mode  VARCHAR2
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
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listfield_rec ams_listfield_pvt.list_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listfield_rec.list_field_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listfield_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listfield_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listfield_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listfield_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listfield_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listfield_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listfield_rec.field_table_name := p0_a7;
    ddp_listfield_rec.field_column_name := p0_a8;
    ddp_listfield_rec.column_data_type := p0_a9;
    ddp_listfield_rec.column_data_length := rosetta_g_miss_num_map(p0_a10);
    ddp_listfield_rec.enabled_flag := p0_a11;
    ddp_listfield_rec.list_type_field_apply_on := p0_a12;
    ddp_listfield_rec.description := p0_a13;



    -- here's the delegated call to the old PL/SQL routine
    ams_listfield_pvt.check_listfield_items(ddp_listfield_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure check_listfield_record(x_return_status OUT NOCOPY  VARCHAR2
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
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
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
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listfield_rec ams_listfield_pvt.list_field_rec_type;
    ddp_complete_rec ams_listfield_pvt.list_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listfield_rec.list_field_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listfield_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listfield_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listfield_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listfield_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listfield_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listfield_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listfield_rec.field_table_name := p0_a7;
    ddp_listfield_rec.field_column_name := p0_a8;
    ddp_listfield_rec.column_data_type := p0_a9;
    ddp_listfield_rec.column_data_length := rosetta_g_miss_num_map(p0_a10);
    ddp_listfield_rec.enabled_flag := p0_a11;
    ddp_listfield_rec.list_type_field_apply_on := p0_a12;
    ddp_listfield_rec.description := p0_a13;

    ddp_complete_rec.list_field_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.field_table_name := p1_a7;
    ddp_complete_rec.field_column_name := p1_a8;
    ddp_complete_rec.column_data_type := p1_a9;
    ddp_complete_rec.column_data_length := rosetta_g_miss_num_map(p1_a10);
    ddp_complete_rec.enabled_flag := p1_a11;
    ddp_complete_rec.list_type_field_apply_on := p1_a12;
    ddp_complete_rec.description := p1_a13;


    -- here's the delegated call to the old PL/SQL routine
    ams_listfield_pvt.check_listfield_record(ddp_listfield_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure init_listfield_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  VARCHAR2
    , p0_a8 OUT NOCOPY  VARCHAR2
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  NUMBER
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  VARCHAR2
  )
  as
    ddx_listfield_rec ams_listfield_pvt.list_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_listfield_pvt.init_listfield_rec(ddx_listfield_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_listfield_rec.list_field_id);
    p0_a1 := ddx_listfield_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_listfield_rec.last_updated_by);
    p0_a3 := ddx_listfield_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_listfield_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_listfield_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_listfield_rec.object_version_number);
    p0_a7 := ddx_listfield_rec.field_table_name;
    p0_a8 := ddx_listfield_rec.field_column_name;
    p0_a9 := ddx_listfield_rec.column_data_type;
    p0_a10 := rosetta_g_miss_num_map(ddx_listfield_rec.column_data_length);
    p0_a11 := ddx_listfield_rec.enabled_flag;
    p0_a12 := ddx_listfield_rec.list_type_field_apply_on;
    p0_a13 := ddx_listfield_rec.description;
  end;

  procedure complete_listfield_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  VARCHAR2
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  NUMBER
    , p1_a11 OUT NOCOPY  VARCHAR2
    , p1_a12 OUT NOCOPY  VARCHAR2
    , p1_a13 OUT NOCOPY  VARCHAR2
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
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_listfield_rec ams_listfield_pvt.list_field_rec_type;
    ddx_complete_rec ams_listfield_pvt.list_field_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_listfield_rec.list_field_id := rosetta_g_miss_num_map(p0_a0);
    ddp_listfield_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_listfield_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_listfield_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_listfield_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_listfield_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_listfield_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_listfield_rec.field_table_name := p0_a7;
    ddp_listfield_rec.field_column_name := p0_a8;
    ddp_listfield_rec.column_data_type := p0_a9;
    ddp_listfield_rec.column_data_length := rosetta_g_miss_num_map(p0_a10);
    ddp_listfield_rec.enabled_flag := p0_a11;
    ddp_listfield_rec.list_type_field_apply_on := p0_a12;
    ddp_listfield_rec.description := p0_a13;


    -- here's the delegated call to the old PL/SQL routine
    ams_listfield_pvt.complete_listfield_rec(ddp_listfield_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.list_field_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.field_table_name;
    p1_a8 := ddx_complete_rec.field_column_name;
    p1_a9 := ddx_complete_rec.column_data_type;
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.column_data_length);
    p1_a11 := ddx_complete_rec.enabled_flag;
    p1_a12 := ddx_complete_rec.list_type_field_apply_on;
    p1_a13 := ddx_complete_rec.description;
  end;

end ams_listfield_pvt_w;

/
