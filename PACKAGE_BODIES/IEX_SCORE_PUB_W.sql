--------------------------------------------------------
--  DDL for Package Body IEX_SCORE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCORE_PUB_W" as
  /* $Header: iexwscrb.pls 120.6 2004/11/08 19:20:08 clchang ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy iex_score_pub.score_eng_comp_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).score_id := a0(indx);
          t(ddindx).score_component_id := a1(indx);
          t(ddindx).score_comp_weight := a2(indx);
          t(ddindx).score_comp_value := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iex_score_pub.score_eng_comp_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).score_id;
          a1(indx) := t(ddindx).score_component_id;
          a2(indx) := t(ddindx).score_comp_weight;
          a3(indx) := t(ddindx).score_comp_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy iex_score_pub.score_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_1000
    , a23 JTF_VARCHAR2_TABLE_1000
    , a24 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).score_id := a0(indx);
          t(ddindx).score_name := a1(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).score_description := a7(indx);
          t(ddindx).enabled_flag := a8(indx);
          t(ddindx).valid_from_dt := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).valid_to_dt := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).campaign_sched_id := a11(indx);
          t(ddindx).jtf_object_code := a12(indx);
          t(ddindx).concurrent_prog_id := a13(indx);
          t(ddindx).concurrent_prog_name := a14(indx);
          t(ddindx).security_group_id := a15(indx);
          t(ddindx).request_id := a16(indx);
          t(ddindx).program_application_id := a17(indx);
          t(ddindx).program_id := a18(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).status_determination := a20(indx);
          t(ddindx).weight_required := a21(indx);
          t(ddindx).score_range_low := a22(indx);
          t(ddindx).score_range_high := a23(indx);
          t(ddindx).out_of_range_rule := a24(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t iex_score_pub.score_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_1000
    , a23 out nocopy JTF_VARCHAR2_TABLE_1000
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_1000();
    a23 := JTF_VARCHAR2_TABLE_1000();
    a24 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_1000();
      a23 := JTF_VARCHAR2_TABLE_1000();
      a24 := JTF_VARCHAR2_TABLE_100();
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
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).score_id;
          a1(indx) := t(ddindx).score_name;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).score_description;
          a8(indx) := t(ddindx).enabled_flag;
          a9(indx) := t(ddindx).valid_from_dt;
          a10(indx) := t(ddindx).valid_to_dt;
          a11(indx) := t(ddindx).campaign_sched_id;
          a12(indx) := t(ddindx).jtf_object_code;
          a13(indx) := t(ddindx).concurrent_prog_id;
          a14(indx) := t(ddindx).concurrent_prog_name;
          a15(indx) := t(ddindx).security_group_id;
          a16(indx) := t(ddindx).request_id;
          a17(indx) := t(ddindx).program_application_id;
          a18(indx) := t(ddindx).program_id;
          a19(indx) := t(ddindx).program_update_date;
          a20(indx) := t(ddindx).status_determination;
          a21(indx) := t(ddindx).weight_required;
          a22(indx) := t(ddindx).score_range_low;
          a23(indx) := t(ddindx).score_range_high;
          a24(indx) := t(ddindx).out_of_range_rule;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p7(t out nocopy iex_score_pub.score_comp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).score_component_id := a0(indx);
          t(ddindx).score_comp_weight := a1(indx);
          t(ddindx).score_id := a2(indx);
          t(ddindx).enabled_flag := a3(indx);
          t(ddindx).score_comp_type_id := a4(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := a6(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).created_by := a8(indx);
          t(ddindx).last_update_login := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t iex_score_pub.score_comp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).score_component_id;
          a1(indx) := t(ddindx).score_comp_weight;
          a2(indx) := t(ddindx).score_id;
          a3(indx) := t(ddindx).enabled_flag;
          a4(indx) := t(ddindx).score_comp_type_id;
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := t(ddindx).last_updated_by;
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := t(ddindx).created_by;
          a9(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p11(t out nocopy iex_score_pub.score_comp_det_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).score_comp_det_id := a0(indx);
          t(ddindx).range_low := a1(indx);
          t(ddindx).range_high := a2(indx);
          t(ddindx).value := a3(indx);
          t(ddindx).new_value := a4(indx);
          t(ddindx).score_component_id := a5(indx);
          t(ddindx).object_version_number := a6(indx);
          t(ddindx).program_id := a7(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := a9(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).created_by := a11(indx);
          t(ddindx).last_update_login := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t iex_score_pub.score_comp_det_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
        a12.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).score_comp_det_id;
          a1(indx) := t(ddindx).range_low;
          a2(indx) := t(ddindx).range_high;
          a3(indx) := t(ddindx).value;
          a4(indx) := t(ddindx).new_value;
          a5(indx) := t(ddindx).score_component_id;
          a6(indx) := t(ddindx).object_version_number;
          a7(indx) := t(ddindx).program_id;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_updated_by;
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := t(ddindx).created_by;
          a12(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p15(t out nocopy iex_score_pub.score_comp_type_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).score_comp_type_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).program_id := a2(indx);
          t(ddindx).security_group_id := a3(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_updated_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).created_by := a8(indx);
          t(ddindx).score_comp_value := a9(indx);
          t(ddindx).active_flag := a10(indx);
          t(ddindx).jtf_object_code := a11(indx);
          t(ddindx).source_lang := a12(indx);
          t(ddindx).score_comp_name := a13(indx);
          t(ddindx).description := a14(indx);
          t(ddindx).function_flag := a15(indx);
          t(ddindx).metric_flag := a16(indx);
          t(ddindx).display_order := a17(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t iex_score_pub.score_comp_type_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
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
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).score_comp_type_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).program_id;
          a3(indx) := t(ddindx).security_group_id;
          a4(indx) := t(ddindx).last_update_date;
          a5(indx) := t(ddindx).last_updated_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := t(ddindx).created_by;
          a9(indx) := t(ddindx).score_comp_value;
          a10(indx) := t(ddindx).active_flag;
          a11(indx) := t(ddindx).jtf_object_code;
          a12(indx) := t(ddindx).source_lang;
          a13(indx) := t(ddindx).score_comp_name;
          a14(indx) := t(ddindx).description;
          a15(indx) := t(ddindx).function_flag;
          a16(indx) := t(ddindx).metric_flag;
          a17(indx) := t(ddindx).display_order;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p18(t out nocopy iex_score_pub.score_id_tbl, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t iex_score_pub.score_id_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p18;

  procedure rosetta_table_copy_in_p19(t out nocopy iex_score_pub.score_comp_id_tbl, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t iex_score_pub.score_comp_id_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p20(t out nocopy iex_score_pub.score_comp_det_id_tbl, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t iex_score_pub.score_comp_det_id_tbl, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p20;

  procedure create_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  DATE
    , p3_a10  DATE
    , p3_a11  NUMBER
    , p3_a12  VARCHAR2
    , p3_a13  NUMBER
    , p3_a14  VARCHAR2
    , p3_a15  NUMBER
    , p3_a16  NUMBER
    , p3_a17  NUMBER
    , p3_a18  NUMBER
    , p3_a19  DATE
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_score_id out nocopy  NUMBER
  )

  as
    ddp_score_rec iex_score_pub.score_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_score_rec.score_id := p3_a0;
    ddp_score_rec.score_name := p3_a1;
    ddp_score_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_score_rec.last_updated_by := p3_a3;
    ddp_score_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_score_rec.created_by := p3_a5;
    ddp_score_rec.last_update_login := p3_a6;
    ddp_score_rec.score_description := p3_a7;
    ddp_score_rec.enabled_flag := p3_a8;
    ddp_score_rec.valid_from_dt := rosetta_g_miss_date_in_map(p3_a9);
    ddp_score_rec.valid_to_dt := rosetta_g_miss_date_in_map(p3_a10);
    ddp_score_rec.campaign_sched_id := p3_a11;
    ddp_score_rec.jtf_object_code := p3_a12;
    ddp_score_rec.concurrent_prog_id := p3_a13;
    ddp_score_rec.concurrent_prog_name := p3_a14;
    ddp_score_rec.security_group_id := p3_a15;
    ddp_score_rec.request_id := p3_a16;
    ddp_score_rec.program_application_id := p3_a17;
    ddp_score_rec.program_id := p3_a18;
    ddp_score_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a19);
    ddp_score_rec.status_determination := p3_a20;
    ddp_score_rec.weight_required := p3_a21;
    ddp_score_rec.score_range_low := p3_a22;
    ddp_score_rec.score_range_high := p3_a23;
    ddp_score_rec.out_of_range_rule := p3_a24;






    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.create_score(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_rec,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_score_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_VARCHAR2_TABLE_300
    , p3_a2 JTF_DATE_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_DATE_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_200
    , p3_a8 JTF_VARCHAR2_TABLE_100
    , p3_a9 JTF_DATE_TABLE
    , p3_a10 JTF_DATE_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_VARCHAR2_TABLE_100
    , p3_a15 JTF_NUMBER_TABLE
    , p3_a16 JTF_NUMBER_TABLE
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_NUMBER_TABLE
    , p3_a19 JTF_DATE_TABLE
    , p3_a20 JTF_VARCHAR2_TABLE_100
    , p3_a21 JTF_VARCHAR2_TABLE_100
    , p3_a22 JTF_VARCHAR2_TABLE_1000
    , p3_a23 JTF_VARCHAR2_TABLE_1000
    , p3_a24 JTF_VARCHAR2_TABLE_100
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_score_tbl iex_score_pub.score_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_score_pub_w.rosetta_table_copy_in_p3(ddp_score_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      );





    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.update_score(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_tbl,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_score(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_score_id_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_score_id_tbl iex_score_pub.score_id_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_score_pub_w.rosetta_table_copy_in_p18(ddp_score_id_tbl, p_score_id_tbl);




    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.delete_score(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_id_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_score_comp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  NUMBER
    , p3_a5  DATE
    , p3_a6  NUMBER
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_score_comp_id out nocopy  NUMBER
  )

  as
    ddp_score_comp_rec iex_score_pub.score_comp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_score_comp_rec.score_component_id := p3_a0;
    ddp_score_comp_rec.score_comp_weight := p3_a1;
    ddp_score_comp_rec.score_id := p3_a2;
    ddp_score_comp_rec.enabled_flag := p3_a3;
    ddp_score_comp_rec.score_comp_type_id := p3_a4;
    ddp_score_comp_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_score_comp_rec.last_updated_by := p3_a6;
    ddp_score_comp_rec.creation_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_score_comp_rec.created_by := p3_a8;
    ddp_score_comp_rec.last_update_login := p3_a9;





    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.create_score_comp(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_comp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_score_comp_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_score_comp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_score_comp_tbl iex_score_pub.score_comp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_score_pub_w.rosetta_table_copy_in_p7(ddp_score_comp_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.update_score_comp(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_comp_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure delete_score_comp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_score_id  NUMBER
    , p_score_comp_id_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_score_comp_id_tbl iex_score_pub.score_comp_id_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    iex_score_pub_w.rosetta_table_copy_in_p19(ddp_score_comp_id_tbl, p_score_comp_id_tbl);




    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.delete_score_comp(p_api_version,
      p_init_msg_list,
      p_commit,
      p_score_id,
      ddp_score_comp_id_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_score_comp_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  NUMBER
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_score_comp_type_id out nocopy  NUMBER
  )

  as
    ddp_score_comp_type_rec iex_score_pub.score_comp_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_score_comp_type_rec.score_comp_type_id := p3_a0;
    ddp_score_comp_type_rec.object_version_number := p3_a1;
    ddp_score_comp_type_rec.program_id := p3_a2;
    ddp_score_comp_type_rec.security_group_id := p3_a3;
    ddp_score_comp_type_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_score_comp_type_rec.last_updated_by := p3_a5;
    ddp_score_comp_type_rec.last_update_login := p3_a6;
    ddp_score_comp_type_rec.creation_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_score_comp_type_rec.created_by := p3_a8;
    ddp_score_comp_type_rec.score_comp_value := p3_a9;
    ddp_score_comp_type_rec.active_flag := p3_a10;
    ddp_score_comp_type_rec.jtf_object_code := p3_a11;
    ddp_score_comp_type_rec.source_lang := p3_a12;
    ddp_score_comp_type_rec.score_comp_name := p3_a13;
    ddp_score_comp_type_rec.description := p3_a14;
    ddp_score_comp_type_rec.function_flag := p3_a15;
    ddp_score_comp_type_rec.metric_flag := p3_a16;
    ddp_score_comp_type_rec.display_order := p3_a17;






    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.create_score_comp_type(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_comp_type_rec,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_score_comp_type_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_score_comp_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_DATE_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_2000
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_VARCHAR2_TABLE_100
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , p3_a13 JTF_VARCHAR2_TABLE_100
    , p3_a14 JTF_VARCHAR2_TABLE_100
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_score_comp_type_tbl iex_score_pub.score_comp_type_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_score_pub_w.rosetta_table_copy_in_p15(ddp_score_comp_type_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      );





    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.update_score_comp_type(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_comp_type_tbl,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_score_comp_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_DATE_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_DATE_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_2000
    , p3_a10 JTF_VARCHAR2_TABLE_100
    , p3_a11 JTF_VARCHAR2_TABLE_100
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , p3_a13 JTF_VARCHAR2_TABLE_100
    , p3_a14 JTF_VARCHAR2_TABLE_100
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_score_comp_type_tbl iex_score_pub.score_comp_type_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_score_pub_w.rosetta_table_copy_in_p15(ddp_score_comp_type_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      );




    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.delete_score_comp_type(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_comp_type_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_score_comp_det(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
    , p3_a2 in out nocopy JTF_NUMBER_TABLE
    , p3_a3 in out nocopy JTF_NUMBER_TABLE
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a5 in out nocopy JTF_NUMBER_TABLE
    , p3_a6 in out nocopy JTF_NUMBER_TABLE
    , p3_a7 in out nocopy JTF_NUMBER_TABLE
    , p3_a8 in out nocopy JTF_DATE_TABLE
    , p3_a9 in out nocopy JTF_NUMBER_TABLE
    , p3_a10 in out nocopy JTF_DATE_TABLE
    , p3_a11 in out nocopy JTF_NUMBER_TABLE
    , p3_a12 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_score_comp_det_tbl iex_score_pub.score_comp_det_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_score_pub_w.rosetta_table_copy_in_p11(ddpx_score_comp_det_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      );




    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.create_score_comp_det(p_api_version,
      p_init_msg_list,
      p_commit,
      ddpx_score_comp_det_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    iex_score_pub_w.rosetta_table_copy_out_p11(ddpx_score_comp_det_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      );



  end;

  procedure update_score_comp_det(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_VARCHAR2_TABLE_2000
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_DATE_TABLE
    , p3_a9 JTF_NUMBER_TABLE
    , p3_a10 JTF_DATE_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_score_comp_det_tbl iex_score_pub.score_comp_det_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    iex_score_pub_w.rosetta_table_copy_in_p11(ddp_score_comp_det_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      );




    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.update_score_comp_det(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_score_comp_det_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure delete_score_comp_det(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_score_comp_id  NUMBER
    , p_score_comp_det_id_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_score_comp_det_id_tbl iex_score_pub.score_comp_det_id_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    iex_score_pub_w.rosetta_table_copy_in_p20(ddp_score_comp_det_id_tbl, p_score_comp_det_id_tbl);




    -- here's the delegated call to the old PL/SQL routine
    iex_score_pub.delete_score_comp_det(p_api_version,
      p_init_msg_list,
      p_commit,
      p_score_comp_id,
      ddp_score_comp_det_id_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end iex_score_pub_w;

/
