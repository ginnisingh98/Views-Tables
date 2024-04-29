--------------------------------------------------------
--  DDL for Package Body XDP_TYPES_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_TYPES_W" as
  /* $Header: XDPTYPWB.pls 120.3 2005/06/22 03:06:51 appldev ship $ */
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

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY xdp_types.order_header_list, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).order_number := a0(indx);
          t(ddindx).order_version := a1(indx);
          t(ddindx).provisioning_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).priority := a3(indx);
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).customer_required_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).order_type := a6(indx);
          t(ddindx).order_action := a7(indx);
          t(ddindx).order_source := a8(indx);
          t(ddindx).related_order_id := a9(indx);
          t(ddindx).org_id := a10(indx);
          t(ddindx).customer_name := a11(indx);
          t(ddindx).customer_id := a12(indx);
          t(ddindx).service_provider_id := a13(indx);
          t(ddindx).telephone_number := a14(indx);
          t(ddindx).order_status := a15(indx);
          t(ddindx).order_state := a16(indx);
          t(ddindx).actual_provisioning_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).completion_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).previous_order_id := a19(indx);
          t(ddindx).next_order_id := a20(indx);
          t(ddindx).sdp_order_id := a21(indx);
          t(ddindx).jeopardy_enabled_flag := a22(indx);
          t(ddindx).order_ref_name := a23(indx);
          t(ddindx).order_ref_value := a24(indx);
          t(ddindx).sp_order_number := a25(indx);
          t(ddindx).sp_userid := a26(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t xdp_types.order_header_list, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_DATE_TABLE
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_DATE_TABLE
    , a5 OUT NOCOPY JTF_DATE_TABLE
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY JTF_DATE_TABLE
    , a18 OUT NOCOPY JTF_DATE_TABLE
    , a19 OUT NOCOPY JTF_NUMBER_TABLE
    , a20 OUT NOCOPY JTF_NUMBER_TABLE
    , a21 OUT NOCOPY JTF_NUMBER_TABLE
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a26 OUT NOCOPY JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
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
        a25.extend(t.count);
        a26.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).order_number;
          a1(indx) := t(ddindx).order_version;
          a2(indx) := t(ddindx).provisioning_date;
          a3(indx) := t(ddindx).priority;
          a4(indx) := t(ddindx).due_date;
          a5(indx) := t(ddindx).customer_required_date;
          a6(indx) := t(ddindx).order_type;
          a7(indx) := t(ddindx).order_action;
          a8(indx) := t(ddindx).order_source;
          a9(indx) := t(ddindx).related_order_id;
          a10(indx) := t(ddindx).org_id;
          a11(indx) := t(ddindx).customer_name;
          a12(indx) := t(ddindx).customer_id;
          a13(indx) := t(ddindx).service_provider_id;
          a14(indx) := t(ddindx).telephone_number;
          a15(indx) := t(ddindx).order_status;
          a16(indx) := t(ddindx).order_state;
          a17(indx) := t(ddindx).actual_provisioning_date;
          a18(indx) := t(ddindx).completion_date;
          a19(indx) := t(ddindx).previous_order_id;
          a20(indx) := t(ddindx).next_order_id;
          a21(indx) := t(ddindx).sdp_order_id;
          a22(indx) := t(ddindx).jeopardy_enabled_flag;
          a23(indx) := t(ddindx).order_ref_name;
          a24(indx) := t(ddindx).order_ref_value;
          a25(indx) := t(ddindx).sp_order_number;
          a26(indx) := t(ddindx).sp_userid;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY xdp_types.order_parameter_list, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parameter_name := a0(indx);
          t(ddindx).parameter_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t xdp_types.order_parameter_list, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).parameter_name;
          a1(indx) := t(ddindx).parameter_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t OUT NOCOPY xdp_types.order_line_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_number := a0(indx);
          t(ddindx).line_item_name := a1(indx);
          t(ddindx).version := a2(indx);
          t(ddindx).is_workitem_flag := a3(indx);
          t(ddindx).action := a4(indx);
          t(ddindx).provisioning_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).provisioning_required_flag := a6(indx);
          t(ddindx).provisioning_sequence := a7(indx);
          t(ddindx).bundle_id := a8(indx);
          t(ddindx).bundle_sequence := a9(indx);
          t(ddindx).priority := a10(indx);
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).customer_required_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).line_status := a13(indx);
          t(ddindx).completion_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).service_id := a15(indx);
          t(ddindx).package_id := a16(indx);
          t(ddindx).workitem_id := a17(indx);
          t(ddindx).line_state := a18(indx);
          t(ddindx).line_item_id := a19(indx);
          t(ddindx).jeopardy_enabled_flag := a20(indx);
          t(ddindx).starting_number := a21(indx);
          t(ddindx).ending_number := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t xdp_types.order_line_list, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY JTF_DATE_TABLE
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_DATE_TABLE
    , a12 OUT NOCOPY JTF_DATE_TABLE
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_DATE_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_NUMBER_TABLE
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a19 OUT NOCOPY JTF_NUMBER_TABLE
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a21 OUT NOCOPY JTF_NUMBER_TABLE
    , a22 OUT NOCOPY JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_number;
          a1(indx) := t(ddindx).line_item_name;
          a2(indx) := t(ddindx).version;
          a3(indx) := t(ddindx).is_workitem_flag;
          a4(indx) := t(ddindx).action;
          a5(indx) := t(ddindx).provisioning_date;
          a6(indx) := t(ddindx).provisioning_required_flag;
          a7(indx) := t(ddindx).provisioning_sequence;
          a8(indx) := t(ddindx).bundle_id;
          a9(indx) := t(ddindx).bundle_sequence;
          a10(indx) := t(ddindx).priority;
          a11(indx) := t(ddindx).due_date;
          a12(indx) := t(ddindx).customer_required_date;
          a13(indx) := t(ddindx).line_status;
          a14(indx) := t(ddindx).completion_date;
          a15(indx) := t(ddindx).service_id;
          a16(indx) := t(ddindx).package_id;
          a17(indx) := t(ddindx).workitem_id;
          a18(indx) := t(ddindx).line_state;
          a19(indx) := t(ddindx).line_item_id;
          a20(indx) := t(ddindx).jeopardy_enabled_flag;
          a21(indx) := t(ddindx).starting_number;
          a22(indx) := t(ddindx).ending_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t OUT NOCOPY xdp_types.line_param_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_number := a0(indx);
          t(ddindx).parameter_name := a1(indx);
          t(ddindx).parameter_value := a2(indx);
          t(ddindx).parameter_ref_value := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t xdp_types.line_param_list, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_number;
          a1(indx) := t(ddindx).parameter_name;
          a2(indx) := t(ddindx).parameter_value;
          a3(indx) := t(ddindx).parameter_ref_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p11(t OUT NOCOPY xdp_types.service_order_line_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_number := a0(indx);
          t(ddindx).line_source := a1(indx);
          t(ddindx).inventory_item_id := a2(indx);
          t(ddindx).service_item_name := a3(indx);
          t(ddindx).version := a4(indx);
          t(ddindx).action_code := a5(indx);
          t(ddindx).organization_code := a6(indx);
          t(ddindx).organization_id := a7(indx);
          t(ddindx).site_use_id := a8(indx);
          t(ddindx).ib_source := a9(indx);
          t(ddindx).ib_source_id := a10(indx);
          t(ddindx).required_fulfillment_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).fulfillment_required_flag := a12(indx);
          t(ddindx).is_package_flag := a13(indx);
          t(ddindx).fulfillment_sequence := a14(indx);
          t(ddindx).bundle_id := a15(indx);
          t(ddindx).bundle_sequence := a16(indx);
          t(ddindx).priority := a17(indx);
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).jeopardy_enabled_flag := a19(indx);
          t(ddindx).customer_required_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).starting_number := a21(indx);
          t(ddindx).ending_number := a22(indx);
          t(ddindx).line_item_id := a23(indx);
          t(ddindx).workitem_id := a24(indx);
          t(ddindx).line_status := a25(indx);
          t(ddindx).completion_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).actual_fulfillment_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).parent_line_number := a28(indx);
          t(ddindx).is_virtual_line_flag := a29(indx);
          t(ddindx).attribute_category := a30(indx);
          t(ddindx).attribute1 := a31(indx);
          t(ddindx).attribute2 := a32(indx);
          t(ddindx).attribute3 := a33(indx);
          t(ddindx).attribute4 := a34(indx);
          t(ddindx).attribute5 := a35(indx);
          t(ddindx).attribute6 := a36(indx);
          t(ddindx).attribute7 := a37(indx);
          t(ddindx).attribute8 := a38(indx);
          t(ddindx).attribute9 := a39(indx);
          t(ddindx).attribute10 := a40(indx);
          t(ddindx).attribute11 := a41(indx);
          t(ddindx).attribute12 := a42(indx);
          t(ddindx).attribute13 := a43(indx);
          t(ddindx).attribute14 := a44(indx);
          t(ddindx).attribute15 := a45(indx);
          t(ddindx).attribute16 := a46(indx);
          t(ddindx).attribute17 := a47(indx);
          t(ddindx).attribute18 := a48(indx);
          t(ddindx).attribute19 := a49(indx);
          t(ddindx).attribute20 := a50(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t xdp_types.service_order_line_list, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_DATE_TABLE
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_NUMBER_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_NUMBER_TABLE
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    , a18 OUT NOCOPY JTF_DATE_TABLE
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a20 OUT NOCOPY JTF_DATE_TABLE
    , a21 OUT NOCOPY JTF_NUMBER_TABLE
    , a22 OUT NOCOPY JTF_NUMBER_TABLE
    , a23 OUT NOCOPY JTF_NUMBER_TABLE
    , a24 OUT NOCOPY JTF_NUMBER_TABLE
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a26 OUT NOCOPY JTF_DATE_TABLE
    , a27 OUT NOCOPY JTF_DATE_TABLE
    , a28 OUT NOCOPY JTF_NUMBER_TABLE
    , a29 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a30 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a31 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a32 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a33 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a34 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a35 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a36 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a37 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a38 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a39 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a40 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a41 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a42 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a43 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a44 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a45 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a46 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a47 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a48 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a49 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a50 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_300();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_300();
    a45 := JTF_VARCHAR2_TABLE_300();
    a46 := JTF_VARCHAR2_TABLE_300();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_VARCHAR2_TABLE_300();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_300();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_300();
      a45 := JTF_VARCHAR2_TABLE_300();
      a46 := JTF_VARCHAR2_TABLE_300();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_VARCHAR2_TABLE_300();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_300();
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
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_number;
          a1(indx) := t(ddindx).line_source;
          a2(indx) := t(ddindx).inventory_item_id;
          a3(indx) := t(ddindx).service_item_name;
          a4(indx) := t(ddindx).version;
          a5(indx) := t(ddindx).action_code;
          a6(indx) := t(ddindx).organization_code;
          a7(indx) := t(ddindx).organization_id;
          a8(indx) := t(ddindx).site_use_id;
          a9(indx) := t(ddindx).ib_source;
          a10(indx) := t(ddindx).ib_source_id;
          a11(indx) := t(ddindx).required_fulfillment_date;
          a12(indx) := t(ddindx).fulfillment_required_flag;
          a13(indx) := t(ddindx).is_package_flag;
          a14(indx) := t(ddindx).fulfillment_sequence;
          a15(indx) := t(ddindx).bundle_id;
          a16(indx) := t(ddindx).bundle_sequence;
          a17(indx) := t(ddindx).priority;
          a18(indx) := t(ddindx).due_date;
          a19(indx) := t(ddindx).jeopardy_enabled_flag;
          a20(indx) := t(ddindx).customer_required_date;
          a21(indx) := t(ddindx).starting_number;
          a22(indx) := t(ddindx).ending_number;
          a23(indx) := t(ddindx).line_item_id;
          a24(indx) := t(ddindx).workitem_id;
          a25(indx) := t(ddindx).line_status;
          a26(indx) := t(ddindx).completion_date;
          a27(indx) := t(ddindx).actual_fulfillment_date;
          a28(indx) := t(ddindx).parent_line_number;
          a29(indx) := t(ddindx).is_virtual_line_flag;
          a30(indx) := t(ddindx).attribute_category;
          a31(indx) := t(ddindx).attribute1;
          a32(indx) := t(ddindx).attribute2;
          a33(indx) := t(ddindx).attribute3;
          a34(indx) := t(ddindx).attribute4;
          a35(indx) := t(ddindx).attribute5;
          a36(indx) := t(ddindx).attribute6;
          a37(indx) := t(ddindx).attribute7;
          a38(indx) := t(ddindx).attribute8;
          a39(indx) := t(ddindx).attribute9;
          a40(indx) := t(ddindx).attribute10;
          a41(indx) := t(ddindx).attribute11;
          a42(indx) := t(ddindx).attribute12;
          a43(indx) := t(ddindx).attribute13;
          a44(indx) := t(ddindx).attribute14;
          a45(indx) := t(ddindx).attribute15;
          a46(indx) := t(ddindx).attribute16;
          a47(indx) := t(ddindx).attribute17;
          a48(indx) := t(ddindx).attribute18;
          a49(indx) := t(ddindx).attribute19;
          a50(indx) := t(ddindx).attribute20;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p15(t OUT NOCOPY xdp_types.service_order_param_list, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parameter_name := a0(indx);
          t(ddindx).parameter_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t xdp_types.service_order_param_list, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).parameter_name;
          a1(indx) := t(ddindx).parameter_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p19(t OUT NOCOPY xdp_types.service_line_param_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_number := a0(indx);
          t(ddindx).parameter_name := a1(indx);
          t(ddindx).parameter_value := a2(indx);
          t(ddindx).parameter_ref_value := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t xdp_types.service_line_param_list, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_4000();
    a3 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_4000();
      a3 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_number;
          a1(indx) := t(ddindx).parameter_name;
          a2(indx) := t(ddindx).parameter_value;
          a3(indx) := t(ddindx).parameter_ref_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

end xdp_types_w;

/
