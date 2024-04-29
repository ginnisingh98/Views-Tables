--------------------------------------------------------
--  DDL for Package Body AMS_LIST_QUERY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_QUERY_PVT_W" as
  /* $Header: amswliqb.pls 115.9 2002/11/22 08:57:20 jieli ship $ */
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_list_query_pvt.sql_string_tbl, a0 JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ams_list_query_pvt.sql_string_tbl, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_4000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p6(t OUT NOCOPY ams_list_query_pvt.list_query_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ams_list_query_pvt.list_query_id_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_list_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_list_query_id OUT NOCOPY  NUMBER
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
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec ams_list_query_pvt.list_query_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_query_rec.list_query_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_query_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_list_query_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_list_query_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_list_query_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_list_query_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_list_query_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_list_query_rec.name := p7_a7;
    ddp_list_query_rec.type := p7_a8;
    ddp_list_query_rec.enabled_flag := p7_a9;
    ddp_list_query_rec.primary_key := p7_a10;
    ddp_list_query_rec.source_object_name := p7_a11;
    ddp_list_query_rec.seed_flag := p7_a12;
    ddp_list_query_rec.public_flag := p7_a13;
    ddp_list_query_rec.org_id := rosetta_g_miss_num_map(p7_a14);
    ddp_list_query_rec.comments := p7_a15;
    ddp_list_query_rec.act_list_query_used_by_id := rosetta_g_miss_num_map(p7_a16);
    ddp_list_query_rec.arc_act_list_query_used_by := p7_a17;
    ddp_list_query_rec.sql_string := p7_a18;
    ddp_list_query_rec.parent_list_query_id := rosetta_g_miss_num_map(p7_a19);
    ddp_list_query_rec.sequence_order := rosetta_g_miss_num_map(p7_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pvt.create_list_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_query_rec,
      x_list_query_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure create_list_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_sql_string_tbl JTF_VARCHAR2_TABLE_4000
    , x_parent_list_query_id OUT NOCOPY  NUMBER
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
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec_tbl ams_list_query_pvt.list_query_rec_type_tbl;
    ddp_sql_string_tbl ams_list_query_pvt.sql_string_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_query_rec_tbl.list_query_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_query_rec_tbl.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_list_query_rec_tbl.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_list_query_rec_tbl.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_list_query_rec_tbl.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_list_query_rec_tbl.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_list_query_rec_tbl.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_list_query_rec_tbl.name := p7_a7;
    ddp_list_query_rec_tbl.type := p7_a8;
    ddp_list_query_rec_tbl.enabled_flag := p7_a9;
    ddp_list_query_rec_tbl.primary_key := p7_a10;
    ddp_list_query_rec_tbl.source_object_name := p7_a11;
    ddp_list_query_rec_tbl.seed_flag := p7_a12;
    ddp_list_query_rec_tbl.public_flag := p7_a13;
    ddp_list_query_rec_tbl.org_id := rosetta_g_miss_num_map(p7_a14);
    ddp_list_query_rec_tbl.comments := p7_a15;
    ddp_list_query_rec_tbl.act_list_query_used_by_id := rosetta_g_miss_num_map(p7_a16);
    ddp_list_query_rec_tbl.arc_act_list_query_used_by := p7_a17;
    ddp_list_query_rec_tbl.parent_list_query_id := rosetta_g_miss_num_map(p7_a18);
    ddp_list_query_rec_tbl.sequence_order := rosetta_g_miss_num_map(p7_a19);

    ams_list_query_pvt_w.rosetta_table_copy_in_p2(ddp_sql_string_tbl, p_sql_string_tbl);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pvt.create_list_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_query_rec_tbl,
      ddp_sql_string_tbl,
      x_parent_list_query_id);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure update_list_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
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
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec ams_list_query_pvt.list_query_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_query_rec.list_query_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_query_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_list_query_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_list_query_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_list_query_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_list_query_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_list_query_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_list_query_rec.name := p7_a7;
    ddp_list_query_rec.type := p7_a8;
    ddp_list_query_rec.enabled_flag := p7_a9;
    ddp_list_query_rec.primary_key := p7_a10;
    ddp_list_query_rec.source_object_name := p7_a11;
    ddp_list_query_rec.seed_flag := p7_a12;
    ddp_list_query_rec.public_flag := p7_a13;
    ddp_list_query_rec.org_id := rosetta_g_miss_num_map(p7_a14);
    ddp_list_query_rec.comments := p7_a15;
    ddp_list_query_rec.act_list_query_used_by_id := rosetta_g_miss_num_map(p7_a16);
    ddp_list_query_rec.arc_act_list_query_used_by := p7_a17;
    ddp_list_query_rec.sql_string := p7_a18;
    ddp_list_query_rec.parent_list_query_id := rosetta_g_miss_num_map(p7_a19);
    ddp_list_query_rec.sequence_order := rosetta_g_miss_num_map(p7_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pvt.update_list_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_query_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_list_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p_sql_string_tbl JTF_VARCHAR2_TABLE_4000
    , x_object_version_number OUT NOCOPY  NUMBER
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
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec_tbl ams_list_query_pvt.list_query_rec_type_tbl;
    ddp_sql_string_tbl ams_list_query_pvt.sql_string_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_query_rec_tbl.list_query_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_query_rec_tbl.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_list_query_rec_tbl.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_list_query_rec_tbl.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_list_query_rec_tbl.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_list_query_rec_tbl.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_list_query_rec_tbl.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_list_query_rec_tbl.name := p7_a7;
    ddp_list_query_rec_tbl.type := p7_a8;
    ddp_list_query_rec_tbl.enabled_flag := p7_a9;
    ddp_list_query_rec_tbl.primary_key := p7_a10;
    ddp_list_query_rec_tbl.source_object_name := p7_a11;
    ddp_list_query_rec_tbl.seed_flag := p7_a12;
    ddp_list_query_rec_tbl.public_flag := p7_a13;
    ddp_list_query_rec_tbl.org_id := rosetta_g_miss_num_map(p7_a14);
    ddp_list_query_rec_tbl.comments := p7_a15;
    ddp_list_query_rec_tbl.act_list_query_used_by_id := rosetta_g_miss_num_map(p7_a16);
    ddp_list_query_rec_tbl.arc_act_list_query_used_by := p7_a17;
    ddp_list_query_rec_tbl.parent_list_query_id := rosetta_g_miss_num_map(p7_a18);
    ddp_list_query_rec_tbl.sequence_order := rosetta_g_miss_num_map(p7_a19);

    ams_list_query_pvt_w.rosetta_table_copy_in_p2(ddp_sql_string_tbl, p_sql_string_tbl);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pvt.update_list_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_query_rec_tbl,
      ddp_sql_string_tbl,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure validate_list_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  NUMBER := 0-1962.0724
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  NUMBER := 0-1962.0724
    , p3_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec ams_list_query_pvt.list_query_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_list_query_rec.list_query_id := rosetta_g_miss_num_map(p3_a0);
    ddp_list_query_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_list_query_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_list_query_rec.creation_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_list_query_rec.created_by := rosetta_g_miss_num_map(p3_a4);
    ddp_list_query_rec.last_update_login := rosetta_g_miss_num_map(p3_a5);
    ddp_list_query_rec.object_version_number := rosetta_g_miss_num_map(p3_a6);
    ddp_list_query_rec.name := p3_a7;
    ddp_list_query_rec.type := p3_a8;
    ddp_list_query_rec.enabled_flag := p3_a9;
    ddp_list_query_rec.primary_key := p3_a10;
    ddp_list_query_rec.source_object_name := p3_a11;
    ddp_list_query_rec.seed_flag := p3_a12;
    ddp_list_query_rec.public_flag := p3_a13;
    ddp_list_query_rec.org_id := rosetta_g_miss_num_map(p3_a14);
    ddp_list_query_rec.comments := p3_a15;
    ddp_list_query_rec.act_list_query_used_by_id := rosetta_g_miss_num_map(p3_a16);
    ddp_list_query_rec.arc_act_list_query_used_by := p3_a17;
    ddp_list_query_rec.sql_string := p3_a18;
    ddp_list_query_rec.parent_list_query_id := rosetta_g_miss_num_map(p3_a19);
    ddp_list_query_rec.sequence_order := rosetta_g_miss_num_map(p3_a20);




    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pvt.validate_list_query(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_list_query_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_list_query_items(p_validation_mode  VARCHAR2
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
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec ams_list_query_pvt.list_query_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_list_query_rec.list_query_id := rosetta_g_miss_num_map(p0_a0);
    ddp_list_query_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_list_query_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_list_query_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_list_query_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_list_query_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_list_query_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_list_query_rec.name := p0_a7;
    ddp_list_query_rec.type := p0_a8;
    ddp_list_query_rec.enabled_flag := p0_a9;
    ddp_list_query_rec.primary_key := p0_a10;
    ddp_list_query_rec.source_object_name := p0_a11;
    ddp_list_query_rec.seed_flag := p0_a12;
    ddp_list_query_rec.public_flag := p0_a13;
    ddp_list_query_rec.org_id := rosetta_g_miss_num_map(p0_a14);
    ddp_list_query_rec.comments := p0_a15;
    ddp_list_query_rec.act_list_query_used_by_id := rosetta_g_miss_num_map(p0_a16);
    ddp_list_query_rec.arc_act_list_query_used_by := p0_a17;
    ddp_list_query_rec.sql_string := p0_a18;
    ddp_list_query_rec.parent_list_query_id := rosetta_g_miss_num_map(p0_a19);
    ddp_list_query_rec.sequence_order := rosetta_g_miss_num_map(p0_a20);



    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pvt.check_list_query_items(ddp_list_query_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_list_query_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec ams_list_query_pvt.list_query_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_list_query_rec.list_query_id := rosetta_g_miss_num_map(p5_a0);
    ddp_list_query_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_list_query_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_list_query_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_list_query_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_list_query_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_list_query_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_list_query_rec.name := p5_a7;
    ddp_list_query_rec.type := p5_a8;
    ddp_list_query_rec.enabled_flag := p5_a9;
    ddp_list_query_rec.primary_key := p5_a10;
    ddp_list_query_rec.source_object_name := p5_a11;
    ddp_list_query_rec.seed_flag := p5_a12;
    ddp_list_query_rec.public_flag := p5_a13;
    ddp_list_query_rec.org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_list_query_rec.comments := p5_a15;
    ddp_list_query_rec.act_list_query_used_by_id := rosetta_g_miss_num_map(p5_a16);
    ddp_list_query_rec.arc_act_list_query_used_by := p5_a17;
    ddp_list_query_rec.sql_string := p5_a18;
    ddp_list_query_rec.parent_list_query_id := rosetta_g_miss_num_map(p5_a19);
    ddp_list_query_rec.sequence_order := rosetta_g_miss_num_map(p5_a20);

    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pvt.validate_list_query_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_query_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_list_query_pvt_w;

/
