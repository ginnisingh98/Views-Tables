--------------------------------------------------------
--  DDL for Package Body AMS_LIST_QUERY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_QUERY_PUB_W" as
  /* $Header: amszliqb.pls 115.5 2002/11/22 08:58:19 jieli ship $ */
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

  procedure create_list_query(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_list_query_id OUT NOCOPY  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec ams_list_query_pvt.list_query_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_list_query_rec.list_query_id := rosetta_g_miss_num_map(p6_a0);
    ddp_list_query_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_list_query_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_list_query_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_list_query_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_list_query_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_list_query_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_list_query_rec.name := p6_a7;
    ddp_list_query_rec.type := p6_a8;
    ddp_list_query_rec.enabled_flag := p6_a9;
    ddp_list_query_rec.primary_key := p6_a10;
    ddp_list_query_rec.source_object_name := p6_a11;
    ddp_list_query_rec.seed_flag := p6_a12;
    ddp_list_query_rec.public_flag := p6_a13;
    ddp_list_query_rec.org_id := rosetta_g_miss_num_map(p6_a14);
    ddp_list_query_rec.comments := p6_a15;
    ddp_list_query_rec.act_list_query_used_by_id := rosetta_g_miss_num_map(p6_a16);
    ddp_list_query_rec.arc_act_list_query_used_by := p6_a17;
    ddp_list_query_rec.sql_string := p6_a18;
    ddp_list_query_rec.parent_list_query_id := rosetta_g_miss_num_map(p6_a19);
    ddp_list_query_rec.sequence_order := rosetta_g_miss_num_map(p6_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pub.create_list_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
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
    ams_list_query_pub.create_list_query(p_api_version_number,
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
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
  )
  as
    ddp_list_query_rec ams_list_query_pvt.list_query_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_list_query_rec.list_query_id := rosetta_g_miss_num_map(p6_a0);
    ddp_list_query_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_list_query_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_list_query_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_list_query_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_list_query_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_list_query_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_list_query_rec.name := p6_a7;
    ddp_list_query_rec.type := p6_a8;
    ddp_list_query_rec.enabled_flag := p6_a9;
    ddp_list_query_rec.primary_key := p6_a10;
    ddp_list_query_rec.source_object_name := p6_a11;
    ddp_list_query_rec.seed_flag := p6_a12;
    ddp_list_query_rec.public_flag := p6_a13;
    ddp_list_query_rec.org_id := rosetta_g_miss_num_map(p6_a14);
    ddp_list_query_rec.comments := p6_a15;
    ddp_list_query_rec.act_list_query_used_by_id := rosetta_g_miss_num_map(p6_a16);
    ddp_list_query_rec.arc_act_list_query_used_by := p6_a17;
    ddp_list_query_rec.sql_string := p6_a18;
    ddp_list_query_rec.parent_list_query_id := rosetta_g_miss_num_map(p6_a19);
    ddp_list_query_rec.sequence_order := rosetta_g_miss_num_map(p6_a20);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_query_pub.update_list_query(p_api_version_number,
      p_init_msg_list,
      p_commit,
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
    ams_list_query_pub.update_list_query(p_api_version_number,
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

end ams_list_query_pub_w;

/
