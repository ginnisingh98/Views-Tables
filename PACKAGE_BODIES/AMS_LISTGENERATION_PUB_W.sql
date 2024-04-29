--------------------------------------------------------
--  DDL for Package Body AMS_LISTGENERATION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTGENERATION_PUB_W" as
  /* $Header: amszlgnb.pls 120.1 2005/06/27 05:43:53 appldev ship $ */
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

  procedure create_list_from_query(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_list_name  VARCHAR2
    , p_list_type  VARCHAR2
    , p_owner_user_id  NUMBER
    , p_list_header_id  NUMBER
    , p_sql_string_tbl JTF_VARCHAR2_TABLE_4000
    , p_primary_key  VARCHAR2
    , p_source_object_name  VARCHAR2
    , p_master_type  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  )
  as
    ddp_sql_string_tbl ams_list_query_pvt.sql_string_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_list_query_pvt_w.rosetta_table_copy_in_p2(ddp_sql_string_tbl, p_sql_string_tbl);







    -- here's the delegated call to the old PL/SQL routine
    ams_listgeneration_pub.create_list_from_query(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_list_name,
      p_list_type,
      p_owner_user_id,
      p_list_header_id,
      ddp_sql_string_tbl,
      p_primary_key,
      p_source_object_name,
      p_master_type,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any














  end;

  procedure create_list_from_query(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_list_name  VARCHAR2
    , p_list_type  VARCHAR2
    , p_owner_user_id  NUMBER
    , p_list_header_id  NUMBER
    , p_sql_string_tbl JTF_VARCHAR2_TABLE_4000
    , p_primary_key  VARCHAR2
    , p_source_object_name  VARCHAR2
    , p_master_type  VARCHAR2
    , p_query_param JTF_VARCHAR2_TABLE_4000
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  )
  as
    ddp_sql_string_tbl ams_list_query_pvt.sql_string_tbl;
    ddp_query_param ams_list_query_pvt.sql_string_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_list_query_pvt_w.rosetta_table_copy_in_p2(ddp_sql_string_tbl, p_sql_string_tbl);




    ams_list_query_pvt_w.rosetta_table_copy_in_p2(ddp_query_param, p_query_param);




    -- here's the delegated call to the old PL/SQL routine
    ams_listgeneration_pub.create_list_from_query(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_list_name,
      p_list_type,
      p_owner_user_id,
      p_list_header_id,
      ddp_sql_string_tbl,
      p_primary_key,
      p_source_object_name,
      p_master_type,
      ddp_query_param,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any















  end;

end ams_listgeneration_pub_w;

/
