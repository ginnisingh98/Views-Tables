--------------------------------------------------------
--  DDL for Package Body CSP_SCH_INT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_SCH_INT_PVT_W" as
  /* $Header: cspvscib.pls 120.0.12010000.9 2012/02/02 09:10:33 htank ship $ */
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

  procedure rosetta_table_copy_in_p13(t out nocopy csp_sch_int_pvt.csp_sch_resource_tbl_typ, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.csp_sch_resource_tbl_typ();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.csp_sch_resource_tbl_typ();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := a0(indx);
          t(ddindx).resource_type := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t csp_sch_int_pvt.csp_sch_resource_tbl_typ, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).resource_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p14(t out nocopy csp_sch_int_pvt.csp_sch_options_tbl_typ, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_4000
    , a7 JTF_VARCHAR2_TABLE_4000
    , a8 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.csp_sch_options_tbl_typ();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.csp_sch_options_tbl_typ();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := a0(indx);
          t(ddindx).resource_type := a1(indx);
          t(ddindx).start_time := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).transfer_cost := a3(indx);
          t(ddindx).missing_parts := a4(indx);
          t(ddindx).available_parts := a5(indx);
          t(ddindx).src_warehouse := a6(indx);
          t(ddindx).ship_method := a7(indx);
          t(ddindx).distance_str := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t csp_sch_int_pvt.csp_sch_options_tbl_typ, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , a8 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_4000();
    a7 := JTF_VARCHAR2_TABLE_4000();
    a8 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_4000();
      a7 := JTF_VARCHAR2_TABLE_4000();
      a8 := JTF_VARCHAR2_TABLE_4000();
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
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).resource_type;
          a2(indx) := t(ddindx).start_time;
          a3(indx) := t(ddindx).transfer_cost;
          a4(indx) := t(ddindx).missing_parts;
          a5(indx) := t(ddindx).available_parts;
          a6(indx) := t(ddindx).src_warehouse;
          a7(indx) := t(ddindx).ship_method;
          a8(indx) := t(ddindx).distance_str;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p15(t out nocopy csp_sch_int_pvt.csp_unavailability_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.csp_unavailability_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.csp_unavailability_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := a0(indx);
          t(ddindx).resource_type := a1(indx);
          t(ddindx).organization_id := a2(indx);
          t(ddindx).item_id := a3(indx);
          t(ddindx).revision := a4(indx);
          t(ddindx).item_uom := a5(indx);
          t(ddindx).item_type := a6(indx);
          t(ddindx).line_id := a7(indx);
          t(ddindx).quantity := a8(indx);
          t(ddindx).ship_set_name := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t csp_sch_int_pvt.csp_unavailability_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).resource_type;
          a2(indx) := t(ddindx).organization_id;
          a3(indx) := t(ddindx).item_id;
          a4(indx) := t(ddindx).revision;
          a5(indx) := t(ddindx).item_uom;
          a6(indx) := t(ddindx).item_type;
          a7(indx) := t(ddindx).line_id;
          a8(indx) := t(ddindx).quantity;
          a9(indx) := t(ddindx).ship_set_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p16(t out nocopy csp_sch_int_pvt.csp_availability_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.csp_availability_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.csp_availability_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := a0(indx);
          t(ddindx).resource_type := a1(indx);
          t(ddindx).organization_id := a2(indx);
          t(ddindx).destination_location_id := a3(indx);
          t(ddindx).line_id := a4(indx);
          t(ddindx).item_id := a5(indx);
          t(ddindx).item_uom := a6(indx);
          t(ddindx).item_type := a7(indx);
          t(ddindx).revision := a8(indx);
          t(ddindx).quantity := a9(indx);
          t(ddindx).available_quantity := a10(indx);
          t(ddindx).source_org := a11(indx);
          t(ddindx).sub_inventory := a12(indx);
          t(ddindx).available_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).shipping_methode := a14(indx);
          t(ddindx).intransit_time := a15(indx);
          t(ddindx).replenishment_source := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p16;
  procedure rosetta_table_copy_out_p16(t csp_sch_int_pvt.csp_availability_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
    a12 := null;
    a13 := null;
    a14 := null;
    a15 := null;
    a16 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).resource_type;
          a2(indx) := t(ddindx).organization_id;
          a3(indx) := t(ddindx).destination_location_id;
          a4(indx) := t(ddindx).line_id;
          a5(indx) := t(ddindx).item_id;
          a6(indx) := t(ddindx).item_uom;
          a7(indx) := t(ddindx).item_type;
          a8(indx) := t(ddindx).revision;
          a9(indx) := t(ddindx).quantity;
          a10(indx) := t(ddindx).available_quantity;
          a11(indx) := t(ddindx).source_org;
          a12(indx) := t(ddindx).sub_inventory;
          a13(indx) := t(ddindx).available_date;
          a14(indx) := t(ddindx).shipping_methode;
          a15(indx) := t(ddindx).intransit_time;
          a16(indx) := t(ddindx).replenishment_source;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p16;

  procedure rosetta_table_copy_in_p17(t out nocopy csp_sch_int_pvt.csp_parts_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.csp_parts_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.csp_parts_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := a0(indx);
          t(ddindx).item_uom := a1(indx);
          t(ddindx).revision := a2(indx);
          t(ddindx).quantity := a3(indx);
          t(ddindx).ship_set_name := a4(indx);
          t(ddindx).line_id := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t csp_sch_int_pvt.csp_parts_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).item_id;
          a1(indx) := t(ddindx).item_uom;
          a2(indx) := t(ddindx).revision;
          a3(indx) := t(ddindx).quantity;
          a4(indx) := t(ddindx).ship_set_name;
          a5(indx) := t(ddindx).line_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p18(t out nocopy csp_sch_int_pvt.available_parts_tbl_typ, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.available_parts_tbl_typ();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.available_parts_tbl_typ();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := a0(indx);
          t(ddindx).item_uom := a1(indx);
          t(ddindx).required_quantity := a2(indx);
          t(ddindx).source_org_id := a3(indx);
          t(ddindx).sub_inventory_code := a4(indx);
          t(ddindx).reserved_quantity := a5(indx);
          t(ddindx).ordered_quantity := a6(indx);
          t(ddindx).available_quantity := a7(indx);
          t(ddindx).shipping_methode := a8(indx);
          t(ddindx).arraival_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).order_by_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).source_type := a11(indx);
          t(ddindx).line_id := a12(indx);
          t(ddindx).item_type := a13(indx);
          t(ddindx).recommended_option := a14(indx);
          t(ddindx).revision := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t csp_sch_int_pvt.available_parts_tbl_typ, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
    a12 := null;
    a13 := null;
    a14 := null;
    a15 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).item_id;
          a1(indx) := t(ddindx).item_uom;
          a2(indx) := t(ddindx).required_quantity;
          a3(indx) := t(ddindx).source_org_id;
          a4(indx) := t(ddindx).sub_inventory_code;
          a5(indx) := t(ddindx).reserved_quantity;
          a6(indx) := t(ddindx).ordered_quantity;
          a7(indx) := t(ddindx).available_quantity;
          a8(indx) := t(ddindx).shipping_methode;
          a9(indx) := t(ddindx).arraival_date;
          a10(indx) := t(ddindx).order_by_date;
          a11(indx) := t(ddindx).source_type;
          a12(indx) := t(ddindx).line_id;
          a13(indx) := t(ddindx).item_type;
          a14(indx) := t(ddindx).recommended_option;
          a15(indx) := t(ddindx).revision;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure rosetta_table_copy_in_p19(t out nocopy csp_sch_int_pvt.available_parts_tbl_typ1, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := a0(indx);
          t(ddindx).item_uom := a1(indx);
          t(ddindx).required_quantity := a2(indx);
          t(ddindx).source_org_id := a3(indx);
          t(ddindx).sub_inventory_code := a4(indx);
          t(ddindx).reserved_quantity := a5(indx);
          t(ddindx).ordered_quantity := a6(indx);
          t(ddindx).available_quantity := a7(indx);
          t(ddindx).shipping_methode := a8(indx);
          t(ddindx).arraival_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).order_by_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).source_type := a11(indx);
          t(ddindx).line_id := a12(indx);
          t(ddindx).item_type := a13(indx);
          t(ddindx).recommended_option := a14(indx);
          t(ddindx).revision := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t csp_sch_int_pvt.available_parts_tbl_typ1, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).item_id;
          a1(indx) := t(ddindx).item_uom;
          a2(indx) := t(ddindx).required_quantity;
          a3(indx) := t(ddindx).source_org_id;
          a4(indx) := t(ddindx).sub_inventory_code;
          a5(indx) := t(ddindx).reserved_quantity;
          a6(indx) := t(ddindx).ordered_quantity;
          a7(indx) := t(ddindx).available_quantity;
          a8(indx) := t(ddindx).shipping_methode;
          a9(indx) := t(ddindx).arraival_date;
          a10(indx) := t(ddindx).order_by_date;
          a11(indx) := t(ddindx).source_type;
          a12(indx) := t(ddindx).line_id;
          a13(indx) := t(ddindx).item_type;
          a14(indx) := t(ddindx).recommended_option;
          a15(indx) := t(ddindx).revision;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p20(t out nocopy csp_sch_int_pvt.csp_parts_tbl_typ1, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_id := a0(indx);
          t(ddindx).item_uom := a1(indx);
          t(ddindx).revision := a2(indx);
          t(ddindx).quantity := a3(indx);
          t(ddindx).ship_set_name := a4(indx);
          t(ddindx).line_id := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t csp_sch_int_pvt.csp_parts_tbl_typ1, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).item_id;
          a1(indx) := t(ddindx).item_uom;
          a2(indx) := t(ddindx).revision;
          a3(indx) := t(ddindx).quantity;
          a4(indx) := t(ddindx).ship_set_name;
          a5(indx) := t(ddindx).line_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure rosetta_table_copy_in_p21(t out nocopy csp_sch_int_pvt.ws_available_parts_tbl_typ, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.ws_available_parts_tbl_typ();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.ws_available_parts_tbl_typ();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := a0(indx);
          t(ddindx).resource_type := a1(indx);
          t(ddindx).distance := a2(indx);
          t(ddindx).unit := a3(indx);
          t(ddindx).phone_number := a4(indx);
          t(ddindx).name := a5(indx);
          t(ddindx).item_id := a6(indx);
          t(ddindx).item_number := a7(indx);
          t(ddindx).item_uom := a8(indx);
          t(ddindx).item_type := a9(indx);
          t(ddindx).source_org_id := a10(indx);
          t(ddindx).location_id := a11(indx);
          t(ddindx).sub_inventory_code := a12(indx);
          t(ddindx).available_quantity := a13(indx);
          t(ddindx).on_hand_quantity := a14(indx);
          t(ddindx).shipping_method_code := a15(indx);
          t(ddindx).shipping_methode := a16(indx);
          t(ddindx).arraival_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).order_by_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).source_type := a19(indx);
          t(ddindx).revision := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t csp_sch_int_pvt.ws_available_parts_tbl_typ, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
    a12 := null;
    a13 := null;
    a14 := null;
    a15 := null;
    a16 := null;
    a17 := null;
    a18 := null;
    a19 := null;
    a20 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).resource_type;
          a2(indx) := t(ddindx).distance;
          a3(indx) := t(ddindx).unit;
          a4(indx) := t(ddindx).phone_number;
          a5(indx) := t(ddindx).name;
          a6(indx) := t(ddindx).item_id;
          a7(indx) := t(ddindx).item_number;
          a8(indx) := t(ddindx).item_uom;
          a9(indx) := t(ddindx).item_type;
          a10(indx) := t(ddindx).source_org_id;
          a11(indx) := t(ddindx).location_id;
          a12(indx) := t(ddindx).sub_inventory_code;
          a13(indx) := t(ddindx).available_quantity;
          a14(indx) := t(ddindx).on_hand_quantity;
          a15(indx) := t(ddindx).shipping_method_code;
          a16(indx) := t(ddindx).shipping_methode;
          a17(indx) := t(ddindx).arraival_date;
          a18(indx) := t(ddindx).order_by_date;
          a19(indx) := t(ddindx).source_type;
          a20(indx) := t(ddindx).revision;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure rosetta_table_copy_in_p22(t out nocopy csp_sch_int_pvt.csp_ws_resource_table_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.csp_ws_resource_table_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.csp_ws_resource_table_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_type := a0(indx);
          t(ddindx).resource_id := a1(indx);
          t(ddindx).distance := a2(indx);
          t(ddindx).unit := a3(indx);
          t(ddindx).phone_number := a4(indx);
          t(ddindx).name := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t csp_sch_int_pvt.csp_ws_resource_table_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_type;
          a1(indx) := t(ddindx).resource_id;
          a2(indx) := t(ddindx).distance;
          a3(indx) := t(ddindx).unit;
          a4(indx) := t(ddindx).phone_number;
          a5(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p23(t out nocopy csp_sch_int_pvt.alternate_items_table_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csp_sch_int_pvt.alternate_items_table_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csp_sch_int_pvt.alternate_items_table_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item := a0(indx);
          t(ddindx).revision := a1(indx);
          t(ddindx).item_uom := a2(indx);
          t(ddindx).item_quantity := a3(indx);
          t(ddindx).alternate_item := a4(indx);
          t(ddindx).alternate_item_uom := a5(indx);
          t(ddindx).alternate_item_quantity := a6(indx);
          t(ddindx).relation_type := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t csp_sch_int_pvt.alternate_items_table_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).item;
          a1(indx) := t(ddindx).revision;
          a2(indx) := t(ddindx).item_uom;
          a3(indx) := t(ddindx).item_quantity;
          a4(indx) := t(ddindx).alternate_item;
          a5(indx) := t(ddindx).alternate_item_uom;
          a6(indx) := t(ddindx).alternate_item_quantity;
          a7(indx) := t(ddindx).relation_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure get_availability_options(p_api_version_number  NUMBER
    , p_task_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p3_a0  DATE
    , p3_a1  DATE
    , p_likelihood  NUMBER
    , p_subinv_only  number
    , p_mandatory  number
    , p_trunk  number
    , p_warehouse  number
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_DATE_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_resources csp_sch_int_pvt.csp_sch_resource_tbl_typ;
    ddp_interval csp_sch_int_pvt.csp_sch_interval_rec_typ;
    ddp_subinv_only boolean;
    ddp_mandatory boolean;
    ddp_trunk boolean;
    ddp_warehouse boolean;
    ddx_options csp_sch_int_pvt.csp_sch_options_tbl_typ;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    csp_sch_int_pvt_w.rosetta_table_copy_in_p13(ddp_resources, p2_a0
      , p2_a1
      );

    ddp_interval.earliest_time := rosetta_g_miss_date_in_map(p3_a0);
    ddp_interval.latest_time := rosetta_g_miss_date_in_map(p3_a1);


    if p_subinv_only is null
      then ddp_subinv_only := null;
    elsif p_subinv_only = 0
      then ddp_subinv_only := false;
    else ddp_subinv_only := true;
    end if;

    if p_mandatory is null
      then ddp_mandatory := null;
    elsif p_mandatory = 0
      then ddp_mandatory := false;
    else ddp_mandatory := true;
    end if;

    if p_trunk is null
      then ddp_trunk := null;
    elsif p_trunk = 0
      then ddp_trunk := false;
    else ddp_trunk := true;
    end if;

    if p_warehouse is null
      then ddp_warehouse := null;
    elsif p_warehouse = 0
      then ddp_warehouse := false;
    else ddp_warehouse := true;
    end if;





    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.get_availability_options(p_api_version_number,
      p_task_id,
      ddp_resources,
      ddp_interval,
      p_likelihood,
      ddp_subinv_only,
      ddp_mandatory,
      ddp_trunk,
      ddp_warehouse,
      ddx_options,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    csp_sch_int_pvt_w.rosetta_table_copy_out_p14(ddx_options, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      );



  end;

  procedure choose_option(p_api_version_number  NUMBER
    , p_task_id  NUMBER
    , p_task_assignment_id  NUMBER
    , p_likelihood  NUMBER
    , p_mandatory  number
    , p_trunk  number
    , p_warehouse  number
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_mandatory boolean;
    ddp_trunk boolean;
    ddp_warehouse boolean;
    ddp_options csp_sch_int_pvt.csp_sch_options_rec_typ;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    if p_mandatory is null
      then ddp_mandatory := null;
    elsif p_mandatory = 0
      then ddp_mandatory := false;
    else ddp_mandatory := true;
    end if;

    if p_trunk is null
      then ddp_trunk := null;
    elsif p_trunk = 0
      then ddp_trunk := false;
    else ddp_trunk := true;
    end if;

    if p_warehouse is null
      then ddp_warehouse := null;
    elsif p_warehouse = 0
      then ddp_warehouse := false;
    else ddp_warehouse := true;
    end if;

    ddp_options.resource_id := p7_a0;
    ddp_options.resource_type := p7_a1;
    ddp_options.start_time := rosetta_g_miss_date_in_map(p7_a2);
    ddp_options.transfer_cost := p7_a3;
    ddp_options.missing_parts := p7_a4;
    ddp_options.available_parts := p7_a5;
    ddp_options.src_warehouse := p7_a6;
    ddp_options.ship_method := p7_a7;
    ddp_options.distance_str := p7_a8;




    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.choose_option(p_api_version_number,
      p_task_id,
      p_task_assignment_id,
      p_likelihood,
      ddp_mandatory,
      ddp_trunk,
      ddp_warehouse,
      ddp_options,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure check_parts_availability(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p_organization_id  NUMBER
    , p_subinv_code  VARCHAR2
    , p_need_by_date  date
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p_timezone_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_called_from  VARCHAR2
    , p_location_id  NUMBER
  )

  as
    ddp_resource csp_sch_int_pvt.csp_sch_resources_rec_typ;
    ddp_need_by_date date;
    ddp_parts_list csp_sch_int_pvt.csp_parts_tbl_typ1;
    ddx_availability csp_sch_int_pvt.available_parts_tbl_typ1;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_resource.resource_id := p0_a0;
    ddp_resource.resource_type := p0_a1;



    ddp_need_by_date := rosetta_g_miss_date_in_map(p_need_by_date);

    csp_sch_int_pvt_w.rosetta_table_copy_in_p20(ddp_parts_list, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      );








    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.check_parts_availability(ddp_resource,
      p_organization_id,
      p_subinv_code,
      ddp_need_by_date,
      ddp_parts_list,
      p_timezone_id,
      ddx_availability,
      x_return_status,
      x_msg_data,
      x_msg_count,
      p_called_from,
      p_location_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    csp_sch_int_pvt_w.rosetta_table_copy_out_p19(ddx_availability, p6_a0
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
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      );





  end;

  function create_reservation(p0_a0  DATE
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  VARCHAR2
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  ) return number

  as
    ddp_reservation_parts csp_sch_int_pvt.reservation_rec_typ;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_reservation_parts.need_by_date := rosetta_g_miss_date_in_map(p0_a0);
    ddp_reservation_parts.organization_id := p0_a1;
    ddp_reservation_parts.item_id := p0_a2;
    ddp_reservation_parts.item_uom_code := p0_a3;
    ddp_reservation_parts.quantity_needed := p0_a4;
    ddp_reservation_parts.sub_inventory_code := p0_a5;
    ddp_reservation_parts.line_id := p0_a6;
    ddp_reservation_parts.revision := p0_a7;



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := csp_sch_int_pvt.create_reservation(ddp_reservation_parts,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  procedure ws_check_other_eng_subinv(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_VARCHAR2_TABLE_100
    , p0_a5 JTF_VARCHAR2_TABLE_300
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_VARCHAR2_TABLE_100
    , p1_a5 JTF_NUMBER_TABLE
    , p_include_alternate  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a17 out nocopy JTF_DATE_TABLE
    , p3_a18 out nocopy JTF_DATE_TABLE
    , p3_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_resource_list csp_sch_int_pvt.csp_ws_resource_table_type;
    ddp_parts_list csp_sch_int_pvt.csp_parts_tbl_typ1;
    ddx_available_list csp_sch_int_pvt.ws_available_parts_tbl_typ;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csp_sch_int_pvt_w.rosetta_table_copy_in_p22(ddp_resource_list, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      );

    csp_sch_int_pvt_w.rosetta_table_copy_in_p20(ddp_parts_list, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      );






    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.ws_check_other_eng_subinv(ddp_resource_list,
      ddp_parts_list,
      p_include_alternate,
      ddx_available_list,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csp_sch_int_pvt_w.rosetta_table_copy_out_p21(ddx_available_list, p3_a0
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
      );



  end;

  procedure ws_check_engineers_subinv(p_resource_type  VARCHAR2
    , p_resource_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_NUMBER_TABLE
    , p_include_alternate  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_NUMBER_TABLE
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a17 out nocopy JTF_DATE_TABLE
    , p4_a18 out nocopy JTF_DATE_TABLE
    , p4_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_parts_list csp_sch_int_pvt.csp_parts_tbl_typ1;
    ddx_available_list csp_sch_int_pvt.ws_available_parts_tbl_typ;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    csp_sch_int_pvt_w.rosetta_table_copy_in_p20(ddp_parts_list, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      );






    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.ws_check_engineers_subinv(p_resource_type,
      p_resource_id,
      ddp_parts_list,
      p_include_alternate,
      ddx_available_list,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csp_sch_int_pvt_w.rosetta_table_copy_out_p21(ddx_available_list, p4_a0
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
      , p4_a19
      , p4_a20
      );



  end;

  procedure ws_check_organizations(p_resource_type  VARCHAR2
    , p_resource_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_NUMBER_TABLE
    , p_include_alternate  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_NUMBER_TABLE
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a17 out nocopy JTF_DATE_TABLE
    , p4_a18 out nocopy JTF_DATE_TABLE
    , p4_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_parts_list csp_sch_int_pvt.csp_parts_tbl_typ1;
    ddx_available_list csp_sch_int_pvt.ws_available_parts_tbl_typ;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    csp_sch_int_pvt_w.rosetta_table_copy_in_p20(ddp_parts_list, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      );






    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.ws_check_organizations(p_resource_type,
      p_resource_id,
      ddp_parts_list,
      p_include_alternate,
      ddx_available_list,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csp_sch_int_pvt_w.rosetta_table_copy_out_p21(ddx_available_list, p4_a0
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
      , p4_a19
      , p4_a20
      );



  end;

  procedure get_alternates(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  NUMBER
    , p_org_id  NUMBER
    , p2_a0 in out nocopy JTF_NUMBER_TABLE
    , p2_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a3 in out nocopy JTF_NUMBER_TABLE
    , p2_a4 in out nocopy JTF_NUMBER_TABLE
    , p2_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 in out nocopy JTF_NUMBER_TABLE
    , p2_a7 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_parts_rec csp_sch_int_pvt.csp_parts_rec_type;
    ddpx_alternate_items csp_sch_int_pvt.alternate_items_table_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_parts_rec.item_id := p0_a0;
    ddp_parts_rec.item_uom := p0_a1;
    ddp_parts_rec.revision := p0_a2;
    ddp_parts_rec.quantity := p0_a3;
    ddp_parts_rec.ship_set_name := p0_a4;
    ddp_parts_rec.line_id := p0_a5;


    csp_sch_int_pvt_w.rosetta_table_copy_in_p23(ddpx_alternate_items, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      );




    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.get_alternates(ddp_parts_rec,
      p_org_id,
      ddpx_alternate_items,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    csp_sch_int_pvt_w.rosetta_table_copy_out_p23(ddpx_alternate_items, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      );



  end;

  procedure get_delivery_date(p_relation_ship_id  NUMBER
    , x_delivery_date out nocopy  DATE
    , x_shipping_option out nocopy  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddx_shipping_option boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.get_delivery_date(p_relation_ship_id,
      x_delivery_date,
      ddx_shipping_option,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_shipping_option is null
    then x_shipping_option := null;
  elsif ddx_shipping_option
    then x_shipping_option := 1;
  else x_shipping_option := 0;
  end if;



  end;

  function get_arrival_date(p_ship_date  date
    , p_lead_time  NUMBER
    , p_org_id  NUMBER
  ) return date

  as
    ddp_ship_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval date;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ship_date := rosetta_g_miss_date_in_map(p_ship_date);



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := csp_sch_int_pvt.get_arrival_date(ddp_ship_date,
      p_lead_time,
      p_org_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  procedure spares_check2(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p_task_id  NUMBER
    , p_need_by_date  date
    , p_trunk  number
    , p_warehouse  number
    , p_mandatory  number
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_resources csp_sch_int_pvt.csp_sch_resource_tbl_typ;
    ddp_need_by_date date;
    ddp_trunk boolean;
    ddp_warehouse boolean;
    ddp_mandatory boolean;
    ddx_options csp_sch_int_pvt.csp_sch_options_tbl_typ;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    csp_sch_int_pvt_w.rosetta_table_copy_in_p13(ddp_resources, p0_a0
      , p0_a1
      );


    ddp_need_by_date := rosetta_g_miss_date_in_map(p_need_by_date);

    if p_trunk is null
      then ddp_trunk := null;
    elsif p_trunk = 0
      then ddp_trunk := false;
    else ddp_trunk := true;
    end if;

    if p_warehouse is null
      then ddp_warehouse := null;
    elsif p_warehouse = 0
      then ddp_warehouse := false;
    else ddp_warehouse := true;
    end if;

    if p_mandatory is null
      then ddp_mandatory := null;
    elsif p_mandatory = 0
      then ddp_mandatory := false;
    else ddp_mandatory := true;
    end if;





    -- here's the delegated call to the old PL/SQL routine
    csp_sch_int_pvt.spares_check2(ddp_resources,
      p_task_id,
      ddp_need_by_date,
      ddp_trunk,
      ddp_warehouse,
      ddp_mandatory,
      ddx_options,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    csp_sch_int_pvt_w.rosetta_table_copy_out_p14(ddx_options, p6_a0
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

end csp_sch_int_pvt_w;

/
