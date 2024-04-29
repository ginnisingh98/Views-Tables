--------------------------------------------------------
--  DDL for Package Body AMS_MANUAL_LIST_GEN_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MANUAL_LIST_GEN_W" as
  /* $Header: amswlmlb.pls 120.0 2005/05/31 21:54:19 appldev noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ams_manual_list_gen.primary_key_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_manual_list_gen.primary_key_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy ams_manual_list_gen.varchar2_tbl_type, a0 JTF_VARCHAR2_TABLE_400) as
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
  procedure rosetta_table_copy_out_p2(t ams_manual_list_gen.varchar2_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_VARCHAR2_TABLE_400();
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_manual_list_gen.child_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_manual_list_gen.child_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p3;

  procedure process_manual_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_list_header_id  NUMBER
    , p_primary_key_tbl JTF_NUMBER_TABLE
    , p_master_type  VARCHAR2
    , x_added_entry_count out nocopy  NUMBER
  )

  as
    ddp_primary_key_tbl ams_manual_list_gen.primary_key_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_manual_list_gen_w.rosetta_table_copy_in_p1(ddp_primary_key_tbl, p_primary_key_tbl);



    -- here's the delegated call to the old PL/SQL routine
    ams_manual_list_gen.process_manual_list(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_list_header_id,
--    ddp_primary_key_tbl,
      p_primary_key_tbl,
      p_master_type,
      x_added_entry_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure process_manual_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_list_header_id  NUMBER
    , p_primary_key_tbl JTF_NUMBER_TABLE
    , p_master_type  VARCHAR2
  )

  as
    ddp_primary_key_tbl ams_manual_list_gen.primary_key_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_manual_list_gen_w.rosetta_table_copy_in_p1(ddp_primary_key_tbl, p_primary_key_tbl);


    -- here's the delegated call to the old PL/SQL routine
    ams_manual_list_gen.process_manual_list(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_list_header_id,
--    ddp_primary_key_tbl,
      p_primary_key_tbl,
      p_master_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure process_employee_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_list_header_id  NUMBER
    , p_primary_key_tbl JTF_NUMBER_TABLE
    , p_last_name_tbl JTF_VARCHAR2_TABLE_400
    , p_first_name_tbl JTF_VARCHAR2_TABLE_400
    , p_email_tbl JTF_VARCHAR2_TABLE_400
    , p_master_type  VARCHAR2
  )

  as
    ddp_primary_key_tbl ams_manual_list_gen.primary_key_tbl_type;
    ddp_last_name_tbl ams_manual_list_gen.varchar2_tbl_type;
    ddp_first_name_tbl ams_manual_list_gen.varchar2_tbl_type;
    ddp_email_tbl ams_manual_list_gen.varchar2_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ams_manual_list_gen_w.rosetta_table_copy_in_p1(ddp_primary_key_tbl, p_primary_key_tbl);

    ams_manual_list_gen_w.rosetta_table_copy_in_p2(ddp_last_name_tbl, p_last_name_tbl);

    ams_manual_list_gen_w.rosetta_table_copy_in_p2(ddp_first_name_tbl, p_first_name_tbl);

    ams_manual_list_gen_w.rosetta_table_copy_in_p2(ddp_email_tbl, p_email_tbl);


    -- here's the delegated call to the old PL/SQL routine
    ams_manual_list_gen.process_employee_list(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_list_header_id,
      ddp_primary_key_tbl,
      ddp_last_name_tbl,
      ddp_first_name_tbl,
      ddp_email_tbl,
      p_master_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end ams_manual_list_gen_w;

/
