--------------------------------------------------------
--  DDL for Package Body FTE_SERVICES_UI_WRAPPER_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_SERVICES_UI_WRAPPER_W" as
  /* $Header: FTESEWPB.pls 120.0 2005/06/29 18:58 jishen noship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy fte_services_ui_wrapper.lane_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lane_id := a0(indx);
          t(ddindx).service_number := a1(indx);
          t(ddindx).rate_chart_type := a2(indx);
          t(ddindx).transport_mode := a3(indx);
          t(ddindx).start_date_active := a4(indx);
          t(ddindx).end_date_active := a5(indx);
          t(ddindx).carrier_id := a6(indx);
          t(ddindx).service_type_code := a7(indx);
          t(ddindx).origin_id := a8(indx);
          t(ddindx).destination_id := a9(indx);
          t(ddindx).lane_type := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t fte_services_ui_wrapper.lane_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).lane_id;
          a1(indx) := t(ddindx).service_number;
          a2(indx) := t(ddindx).rate_chart_type;
          a3(indx) := t(ddindx).transport_mode;
          a4(indx) := t(ddindx).start_date_active;
          a5(indx) := t(ddindx).end_date_active;
          a6(indx) := t(ddindx).carrier_id;
          a7(indx) := t(ddindx).service_type_code;
          a8(indx) := t(ddindx).origin_id;
          a9(indx) := t(ddindx).destination_id;
          a10(indx) := t(ddindx).lane_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy fte_services_ui_wrapper.rate_chart_header_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chart_name := a0(indx);
          t(ddindx).currency_code := a1(indx);
          t(ddindx).carrier_id := a2(indx);
          t(ddindx).service_level := a3(indx);
          t(ddindx).list_header_id := a4(indx);
          t(ddindx).start_date_active := a5(indx);
          t(ddindx).end_date_active := a6(indx);
          t(ddindx).description := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t fte_services_ui_wrapper.rate_chart_header_table, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).chart_name;
          a1(indx) := t(ddindx).currency_code;
          a2(indx) := t(ddindx).carrier_id;
          a3(indx) := t(ddindx).service_level;
          a4(indx) := t(ddindx).list_header_id;
          a5(indx) := t(ddindx).start_date_active;
          a6(indx) := t(ddindx).end_date_active;
          a7(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p9(t out nocopy fte_services_ui_wrapper.rate_chart_line_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_num := a0(indx);
          t(ddindx).type := a1(indx);
          t(ddindx).subtype := a2(indx);
          t(ddindx).rate_type := a3(indx);
          t(ddindx).break_type := a4(indx);
          t(ddindx).origin_id := a5(indx);
          t(ddindx).dest_id := a6(indx);
          t(ddindx).catg_id := a7(indx);
          t(ddindx).service_code := a8(indx);
          t(ddindx).multi_flag := a9(indx);
          t(ddindx).rate_basis := a10(indx);
          t(ddindx).rate_basis_uom := a11(indx);
          t(ddindx).dist_type := a12(indx);
          t(ddindx).vehicle_type := a13(indx);
          t(ddindx).rate := a14(indx);
          t(ddindx).min_charge := a15(indx);
          t(ddindx).start_date := a16(indx);
          t(ddindx).end_date := a17(indx);
          t(ddindx).description := a18(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t fte_services_ui_wrapper.rate_chart_line_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_num;
          a1(indx) := t(ddindx).type;
          a2(indx) := t(ddindx).subtype;
          a3(indx) := t(ddindx).rate_type;
          a4(indx) := t(ddindx).break_type;
          a5(indx) := t(ddindx).origin_id;
          a6(indx) := t(ddindx).dest_id;
          a7(indx) := t(ddindx).catg_id;
          a8(indx) := t(ddindx).service_code;
          a9(indx) := t(ddindx).multi_flag;
          a10(indx) := t(ddindx).rate_basis;
          a11(indx) := t(ddindx).rate_basis_uom;
          a12(indx) := t(ddindx).dist_type;
          a13(indx) := t(ddindx).vehicle_type;
          a14(indx) := t(ddindx).rate;
          a15(indx) := t(ddindx).min_charge;
          a16(indx) := t(ddindx).start_date;
          a17(indx) := t(ddindx).end_date;
          a18(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy fte_services_ui_wrapper.rate_chart_break_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).break_header_index := a0(indx);
          t(ddindx).lower := a1(indx);
          t(ddindx).upper := a2(indx);
          t(ddindx).rate_type := a3(indx);
          t(ddindx).rate := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t fte_services_ui_wrapper.rate_chart_break_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).break_header_index;
          a1(indx) := t(ddindx).lower;
          a2(indx) := t(ddindx).upper;
          a3(indx) := t(ddindx).rate_type;
          a4(indx) := t(ddindx).rate;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t out nocopy fte_services_ui_wrapper.tl_line_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_num := a0(indx);
          t(ddindx).type := a1(indx);
          t(ddindx).region_code := a2(indx);
          t(ddindx).basis := a3(indx);
          t(ddindx).basis_uom_code := a4(indx);
          t(ddindx).charge := a5(indx);
          t(ddindx).min_charge := a6(indx);
          t(ddindx).start_date := a7(indx);
          t(ddindx).end_date := a8(indx);
          t(ddindx).free_stops := a9(indx);
          t(ddindx).first_stop := a10(indx);
          t(ddindx).second_stop := a11(indx);
          t(ddindx).third_stop := a12(indx);
          t(ddindx).fourth_stop := a13(indx);
          t(ddindx).fifth_stop := a14(indx);
          t(ddindx).add_stops := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t fte_services_ui_wrapper.tl_line_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_num;
          a1(indx) := t(ddindx).type;
          a2(indx) := t(ddindx).region_code;
          a3(indx) := t(ddindx).basis;
          a4(indx) := t(ddindx).basis_uom_code;
          a5(indx) := t(ddindx).charge;
          a6(indx) := t(ddindx).min_charge;
          a7(indx) := t(ddindx).start_date;
          a8(indx) := t(ddindx).end_date;
          a9(indx) := t(ddindx).free_stops;
          a10(indx) := t(ddindx).first_stop;
          a11(indx) := t(ddindx).second_stop;
          a12(indx) := t(ddindx).third_stop;
          a13(indx) := t(ddindx).fourth_stop;
          a14(indx) := t(ddindx).fifth_stop;
          a15(indx) := t(ddindx).add_stops;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure edit_tl_services(p_init_msg_list  VARCHAR2
    , p_transaction_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_DATE_TABLE
    , p2_a5 JTF_DATE_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_100
    , p2_a8 JTF_NUMBER_TABLE
    , p2_a9 JTF_NUMBER_TABLE
    , p2_a10 JTF_VARCHAR2_TABLE_100
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_DATE_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_2000
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_VARCHAR2_TABLE_100
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_NUMBER_TABLE
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_DATE_TABLE
    , p4_a17 JTF_DATE_TABLE
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , x_status out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  )

  as
    ddp_lane_table fte_services_ui_wrapper.lane_table;
    ddp_rate_chart_header_table fte_services_ui_wrapper.rate_chart_header_table;
    ddp_rate_chart_line_table fte_services_ui_wrapper.rate_chart_line_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    fte_services_ui_wrapper_w.rosetta_table_copy_in_p4(ddp_lane_table, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      );

    fte_services_ui_wrapper_w.rosetta_table_copy_in_p6(ddp_rate_chart_header_table, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      );

    fte_services_ui_wrapper_w.rosetta_table_copy_in_p9(ddp_rate_chart_line_table, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      );



    -- here's the delegated call to the old PL/SQL routine
    fte_services_ui_wrapper.edit_tl_services(p_init_msg_list,
      p_transaction_type,
      ddp_lane_table,
      ddp_rate_chart_header_table,
      ddp_rate_chart_line_table,
      x_status,
      x_error_msg);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure rate_chart_wrapper(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_VARCHAR2_TABLE_2000
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p1_a4 JTF_VARCHAR2_TABLE_100
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p1_a10 JTF_VARCHAR2_TABLE_100
    , p1_a11 JTF_VARCHAR2_TABLE_100
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_NUMBER_TABLE
    , p1_a16 JTF_DATE_TABLE
    , p1_a17 JTF_DATE_TABLE
    , p1_a18 JTF_VARCHAR2_TABLE_200
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_NUMBER_TABLE
    , p_chart_type  VARCHAR2
    , x_status out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  )

  as
    ddp_header_table fte_services_ui_wrapper.rate_chart_header_table;
    ddp_line_table fte_services_ui_wrapper.rate_chart_line_table;
    ddp_break_table fte_services_ui_wrapper.rate_chart_break_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    fte_services_ui_wrapper_w.rosetta_table_copy_in_p6(ddp_header_table, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      );

    fte_services_ui_wrapper_w.rosetta_table_copy_in_p9(ddp_line_table, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      );

    fte_services_ui_wrapper_w.rosetta_table_copy_in_p11(ddp_break_table, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );




    -- here's the delegated call to the old PL/SQL routine
    fte_services_ui_wrapper.rate_chart_wrapper(ddp_header_table,
      ddp_line_table,
      ddp_break_table,
      p_chart_type,
      x_status,
      x_error_msg);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure tl_surcharge_wrapper(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_VARCHAR2_TABLE_2000
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p1_a4 JTF_VARCHAR2_TABLE_100
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_DATE_TABLE
    , p1_a8 JTF_DATE_TABLE
    , p1_a9 JTF_NUMBER_TABLE
    , p1_a10 JTF_NUMBER_TABLE
    , p1_a11 JTF_NUMBER_TABLE
    , p1_a12 JTF_NUMBER_TABLE
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_NUMBER_TABLE
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_NUMBER_TABLE
    , p_action  VARCHAR2
    , x_status out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  )

  as
    ddp_header_table fte_services_ui_wrapper.rate_chart_header_table;
    ddp_tl_line_table fte_services_ui_wrapper.tl_line_table;
    ddp_break_table fte_services_ui_wrapper.rate_chart_break_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    fte_services_ui_wrapper_w.rosetta_table_copy_in_p6(ddp_header_table, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      );

    fte_services_ui_wrapper_w.rosetta_table_copy_in_p13(ddp_tl_line_table, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      );

    fte_services_ui_wrapper_w.rosetta_table_copy_in_p11(ddp_break_table, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );




    -- here's the delegated call to the old PL/SQL routine
    fte_services_ui_wrapper.tl_surcharge_wrapper(ddp_header_table,
      ddp_tl_line_table,
      ddp_break_table,
      p_action,
      x_status,
      x_error_msg);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end fte_services_ui_wrapper_w;

/
