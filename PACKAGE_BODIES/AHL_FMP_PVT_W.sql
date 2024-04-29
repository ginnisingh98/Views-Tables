--------------------------------------------------------
--  DDL for Package Body AHL_FMP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_PVT_W" as
  /* $Header: AHLWFMPB.pls 120.0.12000000.3 2007/10/19 23:29:21 sracha ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ahl_fmp_pvt.mr_item_instance_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_400
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_number := a0(indx);
          t(ddindx).serial_number := a1(indx);
          t(ddindx).location := a2(indx);
          t(ddindx).status := a3(indx);
          t(ddindx).owner := a4(indx);
          t(ddindx).condition := a5(indx);
          t(ddindx).unit_name := a6(indx);
          t(ddindx).item_instance_id := a7(indx);
          t(ddindx).inventory_item_id := a8(indx);
          t(ddindx).mr_effectivity_id := a9(indx);
          t(ddindx).uc_header_id := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_fmp_pvt.mr_item_instance_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_400
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_400();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_400();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).item_number;
          a1(indx) := t(ddindx).serial_number;
          a2(indx) := t(ddindx).location;
          a3(indx) := t(ddindx).status;
          a4(indx) := t(ddindx).owner;
          a5(indx) := t(ddindx).condition;
          a6(indx) := t(ddindx).unit_name;
          a7(indx) := t(ddindx).item_instance_id;
          a8(indx) := t(ddindx).inventory_item_id;
          a9(indx) := t(ddindx).mr_effectivity_id;
          a10(indx) := t(ddindx).uc_header_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_fmp_pvt.applicable_mr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mr_header_id := a0(indx);
          t(ddindx).mr_effectivity_id := a1(indx);
          t(ddindx).item_instance_id := a2(indx);
          t(ddindx).repetitive_flag := a3(indx);
          t(ddindx).show_repetitive_code := a4(indx);
          t(ddindx).preceding_mr_header_id := a5(indx);
          t(ddindx).copy_accomplishment_flag := a6(indx);
          t(ddindx).implement_status_code := a7(indx);
          t(ddindx).descendent_count := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_fmp_pvt.applicable_mr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).mr_header_id;
          a1(indx) := t(ddindx).mr_effectivity_id;
          a2(indx) := t(ddindx).item_instance_id;
          a3(indx) := t(ddindx).repetitive_flag;
          a4(indx) := t(ddindx).show_repetitive_code;
          a5(indx) := t(ddindx).preceding_mr_header_id;
          a6(indx) := t(ddindx).copy_accomplishment_flag;
          a7(indx) := t(ddindx).implement_status_code;
          a8(indx) := t(ddindx).descendent_count;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy ahl_fmp_pvt.applicable_activities_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).mr_header_id := a0(indx);
          t(ddindx).program_mr_header_id := a1(indx);
          t(ddindx).service_line_id := a2(indx);
          t(ddindx).mr_effectivity_id := a3(indx);
          t(ddindx).item_instance_id := a4(indx);
          t(ddindx).repetitive_flag := a5(indx);
          t(ddindx).whichever_first_code := a6(indx);
          t(ddindx).show_repetitive_code := a7(indx);
          t(ddindx).implement_status_code := a8(indx);
          t(ddindx).act_schedule_exists := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ahl_fmp_pvt.applicable_activities_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).mr_header_id;
          a1(indx) := t(ddindx).program_mr_header_id;
          a2(indx) := t(ddindx).service_line_id;
          a3(indx) := t(ddindx).mr_effectivity_id;
          a4(indx) := t(ddindx).item_instance_id;
          a5(indx) := t(ddindx).repetitive_flag;
          a6(indx) := t(ddindx).whichever_first_code;
          a7(indx) := t(ddindx).show_repetitive_code;
          a8(indx) := t(ddindx).implement_status_code;
          a9(indx) := t(ddindx).act_schedule_exists;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy ahl_fmp_pvt.applicable_programs_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).contract_id := a0(indx);
          t(ddindx).contract_number := a1(indx);
          t(ddindx).contract_number_modifier := a2(indx);
          t(ddindx).sts_code := a3(indx);
          t(ddindx).service_line_id := a4(indx);
          t(ddindx).service_name := a5(indx);
          t(ddindx).service_description := a6(indx);
          t(ddindx).coverage_term_line_id := a7(indx);
          t(ddindx).coverage_term_name := a8(indx);
          t(ddindx).coverage_term_description := a9(indx);
          t(ddindx).coverage_type_code := a10(indx);
          t(ddindx).coverage_type_meaning := a11(indx);
          t(ddindx).coverage_type_imp_level := a12(indx);
          t(ddindx).service_start_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).service_end_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).warranty_flag := a15(indx);
          t(ddindx).eligible_for_entitlement := a16(indx);
          t(ddindx).exp_reaction_time := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).exp_resolution_time := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).status_code := a19(indx);
          t(ddindx).status_text := a20(indx);
          t(ddindx).date_terminated := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).pm_program_id := a22(indx);
          t(ddindx).pm_schedule_exists := a23(indx);
          t(ddindx).mr_effectivity_id := a24(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ahl_fmp_pvt.applicable_programs_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_2000();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_2000();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).contract_id;
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := t(ddindx).contract_number_modifier;
          a3(indx) := t(ddindx).sts_code;
          a4(indx) := t(ddindx).service_line_id;
          a5(indx) := t(ddindx).service_name;
          a6(indx) := t(ddindx).service_description;
          a7(indx) := t(ddindx).coverage_term_line_id;
          a8(indx) := t(ddindx).coverage_term_name;
          a9(indx) := t(ddindx).coverage_term_description;
          a10(indx) := t(ddindx).coverage_type_code;
          a11(indx) := t(ddindx).coverage_type_meaning;
          a12(indx) := t(ddindx).coverage_type_imp_level;
          a13(indx) := t(ddindx).service_start_date;
          a14(indx) := t(ddindx).service_end_date;
          a15(indx) := t(ddindx).warranty_flag;
          a16(indx) := t(ddindx).eligible_for_entitlement;
          a17(indx) := t(ddindx).exp_reaction_time;
          a18(indx) := t(ddindx).exp_resolution_time;
          a19(indx) := t(ddindx).status_code;
          a20(indx) := t(ddindx).status_text;
          a21(indx) := t(ddindx).date_terminated;
          a22(indx) := t(ddindx).pm_program_id;
          a23(indx) := t(ddindx).pm_schedule_exists;
          a24(indx) := t(ddindx).mr_effectivity_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure get_mr_affected_items(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mr_header_id  NUMBER
    , p_mr_effectivity_id  NUMBER
    , p_top_node_flag  VARCHAR2
    , p_unique_inst_flag  VARCHAR2
    , p_sort_flag  VARCHAR2
    , p12_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_NUMBER_TABLE
    , p12_a8 out nocopy JTF_NUMBER_TABLE
    , p12_a9 out nocopy JTF_NUMBER_TABLE
    , p12_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_mr_item_inst_tbl ahl_fmp_pvt.mr_item_instance_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    ahl_fmp_pvt.get_mr_affected_items(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_mr_header_id,
      p_mr_effectivity_id,
      p_top_node_flag,
      p_unique_inst_flag,
      p_sort_flag,
      ddx_mr_item_inst_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    ahl_fmp_pvt_w.rosetta_table_copy_out_p1(ddx_mr_item_inst_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      );
  end;

  procedure get_applicable_mrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_instance_id  NUMBER
    , p_mr_header_id  NUMBER
    , p_components_flag  VARCHAR2
    , p_include_donotimplmt  VARCHAR2
    , p_visit_type_code  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a8 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_applicable_mr_tbl ahl_fmp_pvt.applicable_mr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    ahl_fmp_pvt.get_applicable_mrs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_instance_id,
      p_mr_header_id,
      p_components_flag,
      p_include_donotimplmt,
      p_visit_type_code,
      ddx_applicable_mr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    ahl_fmp_pvt_w.rosetta_table_copy_out_p3(ddx_applicable_mr_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      );
  end;

  procedure get_pm_applicable_mrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_instance_id  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_DATE_TABLE
    , p9_a14 out nocopy JTF_DATE_TABLE
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 out nocopy JTF_DATE_TABLE
    , p9_a18 out nocopy JTF_DATE_TABLE
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a21 out nocopy JTF_DATE_TABLE
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_applicable_activities_tbl ahl_fmp_pvt.applicable_activities_tbl_type;
    ddx_applicable_programs_tbl ahl_fmp_pvt.applicable_programs_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    ahl_fmp_pvt.get_pm_applicable_mrs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_item_instance_id,
      ddx_applicable_activities_tbl,
      ddx_applicable_programs_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ahl_fmp_pvt_w.rosetta_table_copy_out_p5(ddx_applicable_activities_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      );

    ahl_fmp_pvt_w.rosetta_table_copy_out_p7(ddx_applicable_programs_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      );
  end;

end ahl_fmp_pvt_w;

/
