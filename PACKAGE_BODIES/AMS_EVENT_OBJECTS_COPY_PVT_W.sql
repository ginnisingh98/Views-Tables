--------------------------------------------------------
--  DDL for Package Body AMS_EVENT_OBJECTS_COPY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENT_OBJECTS_COPY_PVT_W" as
  /* $Header: amsweocb.pls 115.6 2003/07/30 08:38:18 anchaudh ship $ */
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


  procedure copy_event_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_object_id  NUMBER
    , p_attributes_table JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , x_new_object_id out nocopy  NUMBER
    , x_custom_setup_id out nocopy  NUMBER
  )

  as
    ddp_attributes_table ams_cpyutility_pvt.copy_attributes_table_type;
    ddp_copy_columns_table ams_cpyutility_pvt.copy_columns_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_cpyutility_pvt_w.rosetta_table_copy_in_p0(ddp_attributes_table, p_attributes_table);

    ams_cpyutility_pvt_w.rosetta_table_copy_in_p2(ddp_copy_columns_table, p9_a0
      , p9_a1
      );



    -- here's the delegated call to the old PL/SQL routine
    ams_event_objects_copy_pvt.copy_event_header(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_object_id,
      ddp_attributes_table,
      ddp_copy_columns_table,
      x_new_object_id,
      x_custom_setup_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end ams_event_objects_copy_pvt_w;

/
