--------------------------------------------------------
--  DDL for Package Body JTF_DELIVERABLE_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DELIVERABLE_GRP_W" as
  /* $Header: JTFGRDLB.pls 115.8 2004/07/09 18:50:36 applrt ship $ */
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

  procedure rosetta_table_copy_in_p1(t out jtf_deliverable_grp.deliverable_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).deliverable_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).access_name := a1(indx);
          t(ddindx).display_name := a2(indx);
          t(ddindx).item_type := a3(indx);
          t(ddindx).item_applicable_to := a4(indx);
          t(ddindx).keywords := a5(indx);
          t(ddindx).description := a6(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).x_action_status := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_deliverable_grp.deliverable_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_300
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_300
    , a6 out JTF_VARCHAR2_TABLE_2000
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).deliverable_id);
          a1(indx) := t(ddindx).access_name;
          a2(indx) := t(ddindx).display_name;
          a3(indx) := t(ddindx).item_type;
          a4(indx) := t(ddindx).item_applicable_to;
          a5(indx) := t(ddindx).keywords;
          a6(indx) := t(ddindx).description;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a8(indx) := t(ddindx).x_action_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out jtf_deliverable_grp.dlv_ath_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).deliverable_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).access_name := a1(indx);
          t(ddindx).display_name := a2(indx);
          t(ddindx).item_type := a3(indx);
          t(ddindx).item_applicable_to := a4(indx);
          t(ddindx).keywords := a5(indx);
          t(ddindx).description := a6(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).x_action_status := a8(indx);
          t(ddindx).ath_file_name := a9(indx);
          t(ddindx).ath_file_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).x_ath_action_status := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_deliverable_grp.dlv_ath_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_300
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_300
    , a6 out JTF_VARCHAR2_TABLE_2000
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_VARCHAR2_TABLE_100
    , a9 out JTF_VARCHAR2_TABLE_300
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_2000();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_2000();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).deliverable_id);
          a1(indx) := t(ddindx).access_name;
          a2(indx) := t(ddindx).display_name;
          a3(indx) := t(ddindx).item_type;
          a4(indx) := t(ddindx).item_applicable_to;
          a5(indx) := t(ddindx).keywords;
          a6(indx) := t(ddindx).description;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a8(indx) := t(ddindx).x_action_status;
          a9(indx) := t(ddindx).ath_file_name;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).ath_file_id);
          a11(indx) := t(ddindx).x_ath_action_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out jtf_deliverable_grp.dlv_id_ver_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).deliverable_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).display_name := a1(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).x_action_status := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t jtf_deliverable_grp.dlv_id_ver_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_300
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).deliverable_id);
          a1(indx) := t(ddindx).display_name;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := t(ddindx).x_action_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out jtf_deliverable_grp.number_table, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_deliverable_grp.number_table();
  else
      if a0.count > 0 then
      t := jtf_deliverable_grp.number_table();
      t.extend(a0.count);
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
  procedure rosetta_table_copy_out_p6(t jtf_deliverable_grp.number_table, a0 out JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
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

  procedure rosetta_table_copy_in_p7(t out jtf_deliverable_grp.varchar2_table_100, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_deliverable_grp.varchar2_table_100();
  else
      if a0.count > 0 then
      t := jtf_deliverable_grp.varchar2_table_100();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t jtf_deliverable_grp.varchar2_table_100, a0 out JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
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
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out jtf_deliverable_grp.varchar2_table_300, a0 JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_deliverable_grp.varchar2_table_300();
  else
      if a0.count > 0 then
      t := jtf_deliverable_grp.varchar2_table_300();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t jtf_deliverable_grp.varchar2_table_300, a0 out JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out jtf_deliverable_grp.varchar2_table_2000, a0 JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := jtf_deliverable_grp.varchar2_table_2000();
  else
      if a0.count > 0 then
      t := jtf_deliverable_grp.varchar2_table_2000();
      t.extend(a0.count);
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
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t jtf_deliverable_grp.varchar2_table_2000, a0 out JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
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
  end rosetta_table_copy_out_p9;

  procedure list_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_item_type  VARCHAR2
    , p_item_applicable_to  VARCHAR2
    , p_search_type  VARCHAR2
    , p_search_value  VARCHAR2
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out  NUMBER
    , x_dlv_id_tbl out JTF_NUMBER_TABLE
    , x_acc_name_tbl out JTF_VARCHAR2_TABLE_100
    , x_dsp_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_item_type_tbl out JTF_VARCHAR2_TABLE_100
    , x_appl_to_tbl out JTF_VARCHAR2_TABLE_100
    , x_keyword_tbl out JTF_VARCHAR2_TABLE_300
    , x_desc_tbl out JTF_VARCHAR2_TABLE_2000
    , x_version_tbl out JTF_NUMBER_TABLE
    , x_file_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out JTF_NUMBER_TABLE
  )
  as
    ddx_dlv_id_tbl jtf_deliverable_grp.number_table;
    ddx_acc_name_tbl jtf_deliverable_grp.varchar2_table_100;
    ddx_dsp_name_tbl jtf_deliverable_grp.varchar2_table_300;
    ddx_item_type_tbl jtf_deliverable_grp.varchar2_table_100;
    ddx_appl_to_tbl jtf_deliverable_grp.varchar2_table_100;
    ddx_keyword_tbl jtf_deliverable_grp.varchar2_table_300;
    ddx_desc_tbl jtf_deliverable_grp.varchar2_table_2000;
    ddx_version_tbl jtf_deliverable_grp.number_table;
    ddx_file_name_tbl jtf_deliverable_grp.varchar2_table_300;
    ddx_file_id_tbl jtf_deliverable_grp.number_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






















    -- here's the delegated call to the old PL/SQL routine
    jtf_deliverable_grp.list_deliverable(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_type,
      p_item_applicable_to,
      p_search_type,
      p_search_value,
      p_start_id,
      p_batch_size,
      x_row_count,
      ddx_dlv_id_tbl,
      ddx_acc_name_tbl,
      ddx_dsp_name_tbl,
      ddx_item_type_tbl,
      ddx_appl_to_tbl,
      ddx_keyword_tbl,
      ddx_desc_tbl,
      ddx_version_tbl,
      ddx_file_name_tbl,
      ddx_file_id_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any












    jtf_deliverable_grp_w.rosetta_table_copy_out_p6(ddx_dlv_id_tbl, x_dlv_id_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p7(ddx_acc_name_tbl, x_acc_name_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p8(ddx_dsp_name_tbl, x_dsp_name_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p7(ddx_item_type_tbl, x_item_type_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p7(ddx_appl_to_tbl, x_appl_to_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p8(ddx_keyword_tbl, x_keyword_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p9(ddx_desc_tbl, x_desc_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p6(ddx_version_tbl, x_version_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p8(ddx_file_name_tbl, x_file_name_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p6(ddx_file_id_tbl, x_file_id_tbl);
  end;

  procedure list_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_category_id  NUMBER
    , p_item_type  VARCHAR2
    , p_item_applicable_to  VARCHAR2
    , p_search_type  VARCHAR2
    , p_search_value  VARCHAR2
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out  NUMBER
    , x_dlv_id_tbl out JTF_NUMBER_TABLE
    , x_acc_name_tbl out JTF_VARCHAR2_TABLE_100
    , x_dsp_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_item_type_tbl out JTF_VARCHAR2_TABLE_100
    , x_appl_to_tbl out JTF_VARCHAR2_TABLE_100
    , x_keyword_tbl out JTF_VARCHAR2_TABLE_300
    , x_desc_tbl out JTF_VARCHAR2_TABLE_2000
    , x_version_tbl out JTF_NUMBER_TABLE
    , x_file_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out JTF_NUMBER_TABLE
  )
  as
    ddx_dlv_id_tbl jtf_deliverable_grp.number_table;
    ddx_acc_name_tbl jtf_deliverable_grp.varchar2_table_100;
    ddx_dsp_name_tbl jtf_deliverable_grp.varchar2_table_300;
    ddx_item_type_tbl jtf_deliverable_grp.varchar2_table_100;
    ddx_appl_to_tbl jtf_deliverable_grp.varchar2_table_100;
    ddx_keyword_tbl jtf_deliverable_grp.varchar2_table_300;
    ddx_desc_tbl jtf_deliverable_grp.varchar2_table_2000;
    ddx_version_tbl jtf_deliverable_grp.number_table;
    ddx_file_name_tbl jtf_deliverable_grp.varchar2_table_300;
    ddx_file_id_tbl jtf_deliverable_grp.number_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any























    -- here's the delegated call to the old PL/SQL routine
    jtf_deliverable_grp.list_deliverable(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_category_id,
      p_item_type,
      p_item_applicable_to,
      p_search_type,
      p_search_value,
      p_start_id,
      p_batch_size,
      x_row_count,
      ddx_dlv_id_tbl,
      ddx_acc_name_tbl,
      ddx_dsp_name_tbl,
      ddx_item_type_tbl,
      ddx_appl_to_tbl,
      ddx_keyword_tbl,
      ddx_desc_tbl,
      ddx_version_tbl,
      ddx_file_name_tbl,
      ddx_file_id_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any













    jtf_deliverable_grp_w.rosetta_table_copy_out_p6(ddx_dlv_id_tbl, x_dlv_id_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p7(ddx_acc_name_tbl, x_acc_name_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p8(ddx_dsp_name_tbl, x_dsp_name_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p7(ddx_item_type_tbl, x_item_type_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p7(ddx_appl_to_tbl, x_appl_to_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p8(ddx_keyword_tbl, x_keyword_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p9(ddx_desc_tbl, x_desc_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p6(ddx_version_tbl, x_version_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p8(ddx_file_name_tbl, x_file_name_tbl);

    jtf_deliverable_grp_w.rosetta_table_copy_out_p6(ddx_file_id_tbl, x_file_id_tbl);
  end;

  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  NUMBER
    , p6_a1 in out  VARCHAR2
    , p6_a2 in out  VARCHAR2
    , p6_a3 in out  VARCHAR2
    , p6_a4 in out  VARCHAR2
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  NUMBER
    , p6_a8 in out  VARCHAR2
  )
  as
    ddp_deliverable_rec jtf_deliverable_grp.deliverable_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_deliverable_rec.deliverable_id := rosetta_g_miss_num_map(p6_a0);
    ddp_deliverable_rec.access_name := p6_a1;
    ddp_deliverable_rec.display_name := p6_a2;
    ddp_deliverable_rec.item_type := p6_a3;
    ddp_deliverable_rec.item_applicable_to := p6_a4;
    ddp_deliverable_rec.keywords := p6_a5;
    ddp_deliverable_rec.description := p6_a6;
    ddp_deliverable_rec.object_version_number := rosetta_g_miss_num_map(p6_a7);
    ddp_deliverable_rec.x_action_status := p6_a8;

    -- here's the delegated call to the old PL/SQL routine
    jtf_deliverable_grp.save_deliverable(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_deliverable_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddp_deliverable_rec.deliverable_id);
    p6_a1 := ddp_deliverable_rec.access_name;
    p6_a2 := ddp_deliverable_rec.display_name;
    p6_a3 := ddp_deliverable_rec.item_type;
    p6_a4 := ddp_deliverable_rec.item_applicable_to;
    p6_a5 := ddp_deliverable_rec.keywords;
    p6_a6 := ddp_deliverable_rec.description;
    p6_a7 := rosetta_g_miss_num_map(ddp_deliverable_rec.object_version_number);
    p6_a8 := ddp_deliverable_rec.x_action_status;
  end;

  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_VARCHAR2_TABLE_100
    , p6_a2 in out JTF_VARCHAR2_TABLE_300
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
    , p6_a4 in out JTF_VARCHAR2_TABLE_100
    , p6_a5 in out JTF_VARCHAR2_TABLE_300
    , p6_a6 in out JTF_VARCHAR2_TABLE_2000
    , p6_a7 in out JTF_NUMBER_TABLE
    , p6_a8 in out JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_deliverable_tbl jtf_deliverable_grp.deliverable_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    jtf_deliverable_grp_w.rosetta_table_copy_in_p1(ddp_deliverable_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_deliverable_grp.save_deliverable(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_deliverable_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any






    jtf_deliverable_grp_w.rosetta_table_copy_out_p1(ddp_deliverable_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );
  end;

  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  NUMBER
    , p6_a1 in out  VARCHAR2
    , p6_a2 in out  VARCHAR2
    , p6_a3 in out  VARCHAR2
    , p6_a4 in out  VARCHAR2
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  NUMBER
    , p6_a8 in out  VARCHAR2
    , p6_a9 in out  VARCHAR2
    , p6_a10 in out  NUMBER
    , p6_a11 in out  VARCHAR2
  )
  as
    ddp_dlv_ath_rec jtf_deliverable_grp.dlv_ath_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_dlv_ath_rec.deliverable_id := rosetta_g_miss_num_map(p6_a0);
    ddp_dlv_ath_rec.access_name := p6_a1;
    ddp_dlv_ath_rec.display_name := p6_a2;
    ddp_dlv_ath_rec.item_type := p6_a3;
    ddp_dlv_ath_rec.item_applicable_to := p6_a4;
    ddp_dlv_ath_rec.keywords := p6_a5;
    ddp_dlv_ath_rec.description := p6_a6;
    ddp_dlv_ath_rec.object_version_number := rosetta_g_miss_num_map(p6_a7);
    ddp_dlv_ath_rec.x_action_status := p6_a8;
    ddp_dlv_ath_rec.ath_file_name := p6_a9;
    ddp_dlv_ath_rec.ath_file_id := rosetta_g_miss_num_map(p6_a10);
    ddp_dlv_ath_rec.x_ath_action_status := p6_a11;

    -- here's the delegated call to the old PL/SQL routine
    jtf_deliverable_grp.save_deliverable(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dlv_ath_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddp_dlv_ath_rec.deliverable_id);
    p6_a1 := ddp_dlv_ath_rec.access_name;
    p6_a2 := ddp_dlv_ath_rec.display_name;
    p6_a3 := ddp_dlv_ath_rec.item_type;
    p6_a4 := ddp_dlv_ath_rec.item_applicable_to;
    p6_a5 := ddp_dlv_ath_rec.keywords;
    p6_a6 := ddp_dlv_ath_rec.description;
    p6_a7 := rosetta_g_miss_num_map(ddp_dlv_ath_rec.object_version_number);
    p6_a8 := ddp_dlv_ath_rec.x_action_status;
    p6_a9 := ddp_dlv_ath_rec.ath_file_name;
    p6_a10 := rosetta_g_miss_num_map(ddp_dlv_ath_rec.ath_file_id);
    p6_a11 := ddp_dlv_ath_rec.x_ath_action_status;
  end;

  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_VARCHAR2_TABLE_100
    , p6_a2 in out JTF_VARCHAR2_TABLE_300
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
    , p6_a4 in out JTF_VARCHAR2_TABLE_100
    , p6_a5 in out JTF_VARCHAR2_TABLE_300
    , p6_a6 in out JTF_VARCHAR2_TABLE_2000
    , p6_a7 in out JTF_NUMBER_TABLE
    , p6_a8 in out JTF_VARCHAR2_TABLE_100
    , p6_a9 in out JTF_VARCHAR2_TABLE_300
    , p6_a10 in out JTF_NUMBER_TABLE
    , p6_a11 in out JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_dlv_ath_tbl jtf_deliverable_grp.dlv_ath_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    jtf_deliverable_grp_w.rosetta_table_copy_in_p3(ddp_dlv_ath_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_deliverable_grp.save_deliverable(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dlv_ath_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any






    jtf_deliverable_grp_w.rosetta_table_copy_out_p3(ddp_dlv_ath_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      );
  end;

  procedure delete_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_VARCHAR2_TABLE_300
    , p6_a2 in out JTF_NUMBER_TABLE
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
  )
  as
    ddp_dlv_id_ver_tbl jtf_deliverable_grp.dlv_id_ver_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    jtf_deliverable_grp_w.rosetta_table_copy_in_p5(ddp_dlv_id_ver_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_deliverable_grp.delete_deliverable(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dlv_id_ver_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any






    jtf_deliverable_grp_w.rosetta_table_copy_out_p5(ddp_dlv_id_ver_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );
  end;

end jtf_deliverable_grp_w;

/
