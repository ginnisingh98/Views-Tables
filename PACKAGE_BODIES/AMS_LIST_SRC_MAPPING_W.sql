--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_MAPPING_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_MAPPING_W" as
  /* $Header: amswlsrb.pls 120.1 2006/01/12 22:09 rmbhanda noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ams_list_src_mapping.l_tbl_type, a0 JTF_VARCHAR2_TABLE_1000) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_list_src_mapping.l_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_1000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_VARCHAR2_TABLE_1000();
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
  end rosetta_table_copy_out_p1;

  procedure create_mapping(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_imp_list_header_id  NUMBER
    , p_source_name  VARCHAR2
    , p_table_name  VARCHAR2
    , p_list_src_fields JTF_VARCHAR2_TABLE_1000
    , p_list_target_fields JTF_VARCHAR2_TABLE_1000
    , px_src_type_id in out nocopy  NUMBER
  )

  as
    ddp_list_src_fields ams_list_src_mapping.l_tbl_type;
    ddp_list_target_fields ams_list_src_mapping.l_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ams_list_src_mapping_w.rosetta_table_copy_in_p1(ddp_list_src_fields, p_list_src_fields);

    ams_list_src_mapping_w.rosetta_table_copy_in_p1(ddp_list_target_fields, p_list_target_fields);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_src_mapping.create_mapping(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_imp_list_header_id,
      p_source_name,
      p_table_name,
      ddp_list_src_fields,
      ddp_list_target_fields,
      px_src_type_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end ams_list_src_mapping_w;

/
