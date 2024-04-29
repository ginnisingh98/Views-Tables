--------------------------------------------------------
--  DDL for Package Body CSP_PARTS_REQUIREMENT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PARTS_REQUIREMENT_W" as
  /* $Header: cspwprqb.pls 120.0.12010000.4 2012/02/13 17:31:50 htank ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy csp_parts_requirement.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).requisition_line_id := a0(indx);
          t(ddindx).order_line_id := a1(indx);
          t(ddindx).line_num := a2(indx);
          t(ddindx).inventory_item_id := a3(indx);
          t(ddindx).item_description := a4(indx);
          t(ddindx).revision := a5(indx);
          t(ddindx).quantity := a6(indx);
          t(ddindx).unit_of_measure := a7(indx);
          t(ddindx).dest_subinventory := a8(indx);
          t(ddindx).source_organization_id := a9(indx);
          t(ddindx).source_subinventory := a10(indx);
          t(ddindx).ship_complete := a11(indx);
          t(ddindx).shipping_method_code := a12(indx);
          t(ddindx).likelihood := a13(indx);
          t(ddindx).ordered_quantity := a14(indx);
          t(ddindx).order_by_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).arrival_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).need_by_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).reservation_id := a18(indx);
          t(ddindx).requirement_line_id := a19(indx);
          t(ddindx).change_reason := a20(indx);
          t(ddindx).change_comments := a21(indx);
          t(ddindx).booked_flag := a22(indx);
          t(ddindx).sourced_from := a23(indx);
          t(ddindx).available_by_need_date := a24(indx);
          t(ddindx).attribute_category := a25(indx);
          t(ddindx).attribute1 := a26(indx);
          t(ddindx).attribute2 := a27(indx);
          t(ddindx).attribute3 := a28(indx);
          t(ddindx).attribute4 := a29(indx);
          t(ddindx).attribute5 := a30(indx);
          t(ddindx).attribute6 := a31(indx);
          t(ddindx).attribute7 := a32(indx);
          t(ddindx).attribute8 := a33(indx);
          t(ddindx).attribute9 := a34(indx);
          t(ddindx).attribute10 := a35(indx);
          t(ddindx).attribute11 := a36(indx);
          t(ddindx).attribute12 := a37(indx);
          t(ddindx).attribute13 := a38(indx);
          t(ddindx).attribute14 := a39(indx);
          t(ddindx).attribute15 := a40(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t csp_parts_requirement.line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_VARCHAR2_TABLE_200();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_VARCHAR2_TABLE_200();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).requisition_line_id;
          a1(indx) := t(ddindx).order_line_id;
          a2(indx) := t(ddindx).line_num;
          a3(indx) := t(ddindx).inventory_item_id;
          a4(indx) := t(ddindx).item_description;
          a5(indx) := t(ddindx).revision;
          a6(indx) := t(ddindx).quantity;
          a7(indx) := t(ddindx).unit_of_measure;
          a8(indx) := t(ddindx).dest_subinventory;
          a9(indx) := t(ddindx).source_organization_id;
          a10(indx) := t(ddindx).source_subinventory;
          a11(indx) := t(ddindx).ship_complete;
          a12(indx) := t(ddindx).shipping_method_code;
          a13(indx) := t(ddindx).likelihood;
          a14(indx) := t(ddindx).ordered_quantity;
          a15(indx) := t(ddindx).order_by_date;
          a16(indx) := t(ddindx).arrival_date;
          a17(indx) := t(ddindx).need_by_date;
          a18(indx) := t(ddindx).reservation_id;
          a19(indx) := t(ddindx).requirement_line_id;
          a20(indx) := t(ddindx).change_reason;
          a21(indx) := t(ddindx).change_comments;
          a22(indx) := t(ddindx).booked_flag;
          a23(indx) := t(ddindx).sourced_from;
          a24(indx) := t(ddindx).available_by_need_date;
          a25(indx) := t(ddindx).attribute_category;
          a26(indx) := t(ddindx).attribute1;
          a27(indx) := t(ddindx).attribute2;
          a28(indx) := t(ddindx).attribute3;
          a29(indx) := t(ddindx).attribute4;
          a30(indx) := t(ddindx).attribute5;
          a31(indx) := t(ddindx).attribute6;
          a32(indx) := t(ddindx).attribute7;
          a33(indx) := t(ddindx).attribute8;
          a34(indx) := t(ddindx).attribute9;
          a35(indx) := t(ddindx).attribute10;
          a36(indx) := t(ddindx).attribute11;
          a37(indx) := t(ddindx).attribute12;
          a38(indx) := t(ddindx).attribute13;
          a39(indx) := t(ddindx).attribute14;
          a40(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy csp_parts_requirement.line_detail_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).req_line_detail_id := a0(indx);
          t(ddindx).req_line_id := a1(indx);
          t(ddindx).source_type := a2(indx);
          t(ddindx).source_id := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t csp_parts_requirement.line_detail_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).req_line_detail_id;
          a1(indx) := t(ddindx).req_line_id;
          a2(indx) := t(ddindx).source_type;
          a3(indx) := t(ddindx).source_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy csp_parts_requirement.rqmt_line_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).requirement_line_id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t csp_parts_requirement.rqmt_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
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
          a0(indx) := t(ddindx).requirement_line_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy csp_parts_requirement.order_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).source_type := a0(indx);
          t(ddindx).order_number := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t csp_parts_requirement.order_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).source_type;
          a1(indx) := t(ddindx).order_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure process_requirement(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p_create_order_flag  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_header_rec csp_parts_requirement.header_rec_type;
    ddpx_line_table csp_parts_requirement.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddpx_header_rec.requisition_header_id := p3_a0;
    ddpx_header_rec.requisition_number := p3_a1;
    ddpx_header_rec.description := p3_a2;
    ddpx_header_rec.order_header_id := p3_a3;
    ddpx_header_rec.order_type_id := p3_a4;
    ddpx_header_rec.ship_to_location_id := p3_a5;
    ddpx_header_rec.shipping_method_code := p3_a6;
    ddpx_header_rec.task_id := p3_a7;
    ddpx_header_rec.task_assignment_id := p3_a8;
    ddpx_header_rec.need_by_date := rosetta_g_miss_date_in_map(p3_a9);
    ddpx_header_rec.dest_organization_id := p3_a10;
    ddpx_header_rec.dest_subinventory := p3_a11;
    ddpx_header_rec.operation := p3_a12;
    ddpx_header_rec.requirement_header_id := p3_a13;
    ddpx_header_rec.change_reason := p3_a14;
    ddpx_header_rec.change_comments := p3_a15;
    ddpx_header_rec.resource_type := p3_a16;
    ddpx_header_rec.resource_id := p3_a17;
    ddpx_header_rec.incident_id := p3_a18;
    ddpx_header_rec.address_type := p3_a19;
    ddpx_header_rec.justification := p3_a20;
    ddpx_header_rec.note_to_buyer := p3_a21;
    ddpx_header_rec.note1_id := p3_a22;
    ddpx_header_rec.note1_title := p3_a23;
    ddpx_header_rec.called_from := p3_a24;
    ddpx_header_rec.suggested_vendor_id := p3_a25;
    ddpx_header_rec.suggested_vendor_name := p3_a26;
    ddpx_header_rec.attribute_category := p3_a27;
    ddpx_header_rec.attribute1 := p3_a28;
    ddpx_header_rec.attribute2 := p3_a29;
    ddpx_header_rec.attribute3 := p3_a30;
    ddpx_header_rec.attribute4 := p3_a31;
    ddpx_header_rec.attribute5 := p3_a32;
    ddpx_header_rec.attribute6 := p3_a33;
    ddpx_header_rec.attribute7 := p3_a34;
    ddpx_header_rec.attribute8 := p3_a35;
    ddpx_header_rec.attribute9 := p3_a36;
    ddpx_header_rec.attribute10 := p3_a37;
    ddpx_header_rec.attribute11 := p3_a38;
    ddpx_header_rec.attribute12 := p3_a39;
    ddpx_header_rec.attribute13 := p3_a40;
    ddpx_header_rec.attribute14 := p3_a41;
    ddpx_header_rec.attribute15 := p3_a42;
    ddpx_header_rec.ship_to_contact_id := p3_a43;

    csp_parts_requirement_w.rosetta_table_copy_in_p2(ddpx_line_table, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );





    -- here's the delegated call to the old PL/SQL routine
    csp_parts_requirement.process_requirement(p_api_version,
      p_init_msg_list,
      p_commit,
      ddpx_header_rec,
      ddpx_line_table,
      p_create_order_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddpx_header_rec.requisition_header_id;
    p3_a1 := ddpx_header_rec.requisition_number;
    p3_a2 := ddpx_header_rec.description;
    p3_a3 := ddpx_header_rec.order_header_id;
    p3_a4 := ddpx_header_rec.order_type_id;
    p3_a5 := ddpx_header_rec.ship_to_location_id;
    p3_a6 := ddpx_header_rec.shipping_method_code;
    p3_a7 := ddpx_header_rec.task_id;
    p3_a8 := ddpx_header_rec.task_assignment_id;
    p3_a9 := ddpx_header_rec.need_by_date;
    p3_a10 := ddpx_header_rec.dest_organization_id;
    p3_a11 := ddpx_header_rec.dest_subinventory;
    p3_a12 := ddpx_header_rec.operation;
    p3_a13 := ddpx_header_rec.requirement_header_id;
    p3_a14 := ddpx_header_rec.change_reason;
    p3_a15 := ddpx_header_rec.change_comments;
    p3_a16 := ddpx_header_rec.resource_type;
    p3_a17 := ddpx_header_rec.resource_id;
    p3_a18 := ddpx_header_rec.incident_id;
    p3_a19 := ddpx_header_rec.address_type;
    p3_a20 := ddpx_header_rec.justification;
    p3_a21 := ddpx_header_rec.note_to_buyer;
    p3_a22 := ddpx_header_rec.note1_id;
    p3_a23 := ddpx_header_rec.note1_title;
    p3_a24 := ddpx_header_rec.called_from;
    p3_a25 := ddpx_header_rec.suggested_vendor_id;
    p3_a26 := ddpx_header_rec.suggested_vendor_name;
    p3_a27 := ddpx_header_rec.attribute_category;
    p3_a28 := ddpx_header_rec.attribute1;
    p3_a29 := ddpx_header_rec.attribute2;
    p3_a30 := ddpx_header_rec.attribute3;
    p3_a31 := ddpx_header_rec.attribute4;
    p3_a32 := ddpx_header_rec.attribute5;
    p3_a33 := ddpx_header_rec.attribute6;
    p3_a34 := ddpx_header_rec.attribute7;
    p3_a35 := ddpx_header_rec.attribute8;
    p3_a36 := ddpx_header_rec.attribute9;
    p3_a37 := ddpx_header_rec.attribute10;
    p3_a38 := ddpx_header_rec.attribute11;
    p3_a39 := ddpx_header_rec.attribute12;
    p3_a40 := ddpx_header_rec.attribute13;
    p3_a41 := ddpx_header_rec.attribute14;
    p3_a42 := ddpx_header_rec.attribute15;
    p3_a43 := ddpx_header_rec.ship_to_contact_id;

    csp_parts_requirement_w.rosetta_table_copy_out_p2(ddpx_line_table, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );




  end;

  procedure csptrreq_fm_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_header_rec csp_parts_requirement.header_rec_type;
    ddpx_line_table csp_parts_requirement.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddpx_header_rec.requisition_header_id := p3_a0;
    ddpx_header_rec.requisition_number := p3_a1;
    ddpx_header_rec.description := p3_a2;
    ddpx_header_rec.order_header_id := p3_a3;
    ddpx_header_rec.order_type_id := p3_a4;
    ddpx_header_rec.ship_to_location_id := p3_a5;
    ddpx_header_rec.shipping_method_code := p3_a6;
    ddpx_header_rec.task_id := p3_a7;
    ddpx_header_rec.task_assignment_id := p3_a8;
    ddpx_header_rec.need_by_date := rosetta_g_miss_date_in_map(p3_a9);
    ddpx_header_rec.dest_organization_id := p3_a10;
    ddpx_header_rec.dest_subinventory := p3_a11;
    ddpx_header_rec.operation := p3_a12;
    ddpx_header_rec.requirement_header_id := p3_a13;
    ddpx_header_rec.change_reason := p3_a14;
    ddpx_header_rec.change_comments := p3_a15;
    ddpx_header_rec.resource_type := p3_a16;
    ddpx_header_rec.resource_id := p3_a17;
    ddpx_header_rec.incident_id := p3_a18;
    ddpx_header_rec.address_type := p3_a19;
    ddpx_header_rec.justification := p3_a20;
    ddpx_header_rec.note_to_buyer := p3_a21;
    ddpx_header_rec.note1_id := p3_a22;
    ddpx_header_rec.note1_title := p3_a23;
    ddpx_header_rec.called_from := p3_a24;
    ddpx_header_rec.suggested_vendor_id := p3_a25;
    ddpx_header_rec.suggested_vendor_name := p3_a26;
    ddpx_header_rec.attribute_category := p3_a27;
    ddpx_header_rec.attribute1 := p3_a28;
    ddpx_header_rec.attribute2 := p3_a29;
    ddpx_header_rec.attribute3 := p3_a30;
    ddpx_header_rec.attribute4 := p3_a31;
    ddpx_header_rec.attribute5 := p3_a32;
    ddpx_header_rec.attribute6 := p3_a33;
    ddpx_header_rec.attribute7 := p3_a34;
    ddpx_header_rec.attribute8 := p3_a35;
    ddpx_header_rec.attribute9 := p3_a36;
    ddpx_header_rec.attribute10 := p3_a37;
    ddpx_header_rec.attribute11 := p3_a38;
    ddpx_header_rec.attribute12 := p3_a39;
    ddpx_header_rec.attribute13 := p3_a40;
    ddpx_header_rec.attribute14 := p3_a41;
    ddpx_header_rec.attribute15 := p3_a42;
    ddpx_header_rec.ship_to_contact_id := p3_a43;

    csp_parts_requirement_w.rosetta_table_copy_in_p2(ddpx_line_table, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );




    -- here's the delegated call to the old PL/SQL routine
    csp_parts_requirement.csptrreq_fm_order(p_api_version,
      p_init_msg_list,
      p_commit,
      ddpx_header_rec,
      ddpx_line_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddpx_header_rec.requisition_header_id;
    p3_a1 := ddpx_header_rec.requisition_number;
    p3_a2 := ddpx_header_rec.description;
    p3_a3 := ddpx_header_rec.order_header_id;
    p3_a4 := ddpx_header_rec.order_type_id;
    p3_a5 := ddpx_header_rec.ship_to_location_id;
    p3_a6 := ddpx_header_rec.shipping_method_code;
    p3_a7 := ddpx_header_rec.task_id;
    p3_a8 := ddpx_header_rec.task_assignment_id;
    p3_a9 := ddpx_header_rec.need_by_date;
    p3_a10 := ddpx_header_rec.dest_organization_id;
    p3_a11 := ddpx_header_rec.dest_subinventory;
    p3_a12 := ddpx_header_rec.operation;
    p3_a13 := ddpx_header_rec.requirement_header_id;
    p3_a14 := ddpx_header_rec.change_reason;
    p3_a15 := ddpx_header_rec.change_comments;
    p3_a16 := ddpx_header_rec.resource_type;
    p3_a17 := ddpx_header_rec.resource_id;
    p3_a18 := ddpx_header_rec.incident_id;
    p3_a19 := ddpx_header_rec.address_type;
    p3_a20 := ddpx_header_rec.justification;
    p3_a21 := ddpx_header_rec.note_to_buyer;
    p3_a22 := ddpx_header_rec.note1_id;
    p3_a23 := ddpx_header_rec.note1_title;
    p3_a24 := ddpx_header_rec.called_from;
    p3_a25 := ddpx_header_rec.suggested_vendor_id;
    p3_a26 := ddpx_header_rec.suggested_vendor_name;
    p3_a27 := ddpx_header_rec.attribute_category;
    p3_a28 := ddpx_header_rec.attribute1;
    p3_a29 := ddpx_header_rec.attribute2;
    p3_a30 := ddpx_header_rec.attribute3;
    p3_a31 := ddpx_header_rec.attribute4;
    p3_a32 := ddpx_header_rec.attribute5;
    p3_a33 := ddpx_header_rec.attribute6;
    p3_a34 := ddpx_header_rec.attribute7;
    p3_a35 := ddpx_header_rec.attribute8;
    p3_a36 := ddpx_header_rec.attribute9;
    p3_a37 := ddpx_header_rec.attribute10;
    p3_a38 := ddpx_header_rec.attribute11;
    p3_a39 := ddpx_header_rec.attribute12;
    p3_a40 := ddpx_header_rec.attribute13;
    p3_a41 := ddpx_header_rec.attribute14;
    p3_a42 := ddpx_header_rec.attribute15;
    p3_a43 := ddpx_header_rec.ship_to_contact_id;

    csp_parts_requirement_w.rosetta_table_copy_out_p2(ddpx_line_table, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );



  end;

  procedure csptrreq_order_res(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_header_rec csp_parts_requirement.header_rec_type;
    ddpx_line_table csp_parts_requirement.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddpx_header_rec.requisition_header_id := p3_a0;
    ddpx_header_rec.requisition_number := p3_a1;
    ddpx_header_rec.description := p3_a2;
    ddpx_header_rec.order_header_id := p3_a3;
    ddpx_header_rec.order_type_id := p3_a4;
    ddpx_header_rec.ship_to_location_id := p3_a5;
    ddpx_header_rec.shipping_method_code := p3_a6;
    ddpx_header_rec.task_id := p3_a7;
    ddpx_header_rec.task_assignment_id := p3_a8;
    ddpx_header_rec.need_by_date := rosetta_g_miss_date_in_map(p3_a9);
    ddpx_header_rec.dest_organization_id := p3_a10;
    ddpx_header_rec.dest_subinventory := p3_a11;
    ddpx_header_rec.operation := p3_a12;
    ddpx_header_rec.requirement_header_id := p3_a13;
    ddpx_header_rec.change_reason := p3_a14;
    ddpx_header_rec.change_comments := p3_a15;
    ddpx_header_rec.resource_type := p3_a16;
    ddpx_header_rec.resource_id := p3_a17;
    ddpx_header_rec.incident_id := p3_a18;
    ddpx_header_rec.address_type := p3_a19;
    ddpx_header_rec.justification := p3_a20;
    ddpx_header_rec.note_to_buyer := p3_a21;
    ddpx_header_rec.note1_id := p3_a22;
    ddpx_header_rec.note1_title := p3_a23;
    ddpx_header_rec.called_from := p3_a24;
    ddpx_header_rec.suggested_vendor_id := p3_a25;
    ddpx_header_rec.suggested_vendor_name := p3_a26;
    ddpx_header_rec.attribute_category := p3_a27;
    ddpx_header_rec.attribute1 := p3_a28;
    ddpx_header_rec.attribute2 := p3_a29;
    ddpx_header_rec.attribute3 := p3_a30;
    ddpx_header_rec.attribute4 := p3_a31;
    ddpx_header_rec.attribute5 := p3_a32;
    ddpx_header_rec.attribute6 := p3_a33;
    ddpx_header_rec.attribute7 := p3_a34;
    ddpx_header_rec.attribute8 := p3_a35;
    ddpx_header_rec.attribute9 := p3_a36;
    ddpx_header_rec.attribute10 := p3_a37;
    ddpx_header_rec.attribute11 := p3_a38;
    ddpx_header_rec.attribute12 := p3_a39;
    ddpx_header_rec.attribute13 := p3_a40;
    ddpx_header_rec.attribute14 := p3_a41;
    ddpx_header_rec.attribute15 := p3_a42;
    ddpx_header_rec.ship_to_contact_id := p3_a43;

    csp_parts_requirement_w.rosetta_table_copy_in_p2(ddpx_line_table, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );




    -- here's the delegated call to the old PL/SQL routine
    csp_parts_requirement.csptrreq_order_res(p_api_version,
      p_init_msg_list,
      p_commit,
      ddpx_header_rec,
      ddpx_line_table,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddpx_header_rec.requisition_header_id;
    p3_a1 := ddpx_header_rec.requisition_number;
    p3_a2 := ddpx_header_rec.description;
    p3_a3 := ddpx_header_rec.order_header_id;
    p3_a4 := ddpx_header_rec.order_type_id;
    p3_a5 := ddpx_header_rec.ship_to_location_id;
    p3_a6 := ddpx_header_rec.shipping_method_code;
    p3_a7 := ddpx_header_rec.task_id;
    p3_a8 := ddpx_header_rec.task_assignment_id;
    p3_a9 := ddpx_header_rec.need_by_date;
    p3_a10 := ddpx_header_rec.dest_organization_id;
    p3_a11 := ddpx_header_rec.dest_subinventory;
    p3_a12 := ddpx_header_rec.operation;
    p3_a13 := ddpx_header_rec.requirement_header_id;
    p3_a14 := ddpx_header_rec.change_reason;
    p3_a15 := ddpx_header_rec.change_comments;
    p3_a16 := ddpx_header_rec.resource_type;
    p3_a17 := ddpx_header_rec.resource_id;
    p3_a18 := ddpx_header_rec.incident_id;
    p3_a19 := ddpx_header_rec.address_type;
    p3_a20 := ddpx_header_rec.justification;
    p3_a21 := ddpx_header_rec.note_to_buyer;
    p3_a22 := ddpx_header_rec.note1_id;
    p3_a23 := ddpx_header_rec.note1_title;
    p3_a24 := ddpx_header_rec.called_from;
    p3_a25 := ddpx_header_rec.suggested_vendor_id;
    p3_a26 := ddpx_header_rec.suggested_vendor_name;
    p3_a27 := ddpx_header_rec.attribute_category;
    p3_a28 := ddpx_header_rec.attribute1;
    p3_a29 := ddpx_header_rec.attribute2;
    p3_a30 := ddpx_header_rec.attribute3;
    p3_a31 := ddpx_header_rec.attribute4;
    p3_a32 := ddpx_header_rec.attribute5;
    p3_a33 := ddpx_header_rec.attribute6;
    p3_a34 := ddpx_header_rec.attribute7;
    p3_a35 := ddpx_header_rec.attribute8;
    p3_a36 := ddpx_header_rec.attribute9;
    p3_a37 := ddpx_header_rec.attribute10;
    p3_a38 := ddpx_header_rec.attribute11;
    p3_a39 := ddpx_header_rec.attribute12;
    p3_a40 := ddpx_header_rec.attribute13;
    p3_a41 := ddpx_header_rec.attribute14;
    p3_a42 := ddpx_header_rec.attribute15;
    p3_a43 := ddpx_header_rec.ship_to_contact_id;

    csp_parts_requirement_w.rosetta_table_copy_out_p2(ddpx_line_table, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );



  end;

  procedure save_rqmt_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy  NUMBER
    , p3_a1 in out nocopy  VARCHAR2
    , p3_a2 in out nocopy  VARCHAR2
    , p3_a3 in out nocopy  NUMBER
    , p3_a4 in out nocopy  NUMBER
    , p3_a5 in out nocopy  NUMBER
    , p3_a6 in out nocopy  VARCHAR2
    , p3_a7 in out nocopy  NUMBER
    , p3_a8 in out nocopy  NUMBER
    , p3_a9 in out nocopy  DATE
    , p3_a10 in out nocopy  NUMBER
    , p3_a11 in out nocopy  VARCHAR2
    , p3_a12 in out nocopy  VARCHAR2
    , p3_a13 in out nocopy  NUMBER
    , p3_a14 in out nocopy  VARCHAR2
    , p3_a15 in out nocopy  VARCHAR2
    , p3_a16 in out nocopy  VARCHAR2
    , p3_a17 in out nocopy  NUMBER
    , p3_a18 in out nocopy  NUMBER
    , p3_a19 in out nocopy  VARCHAR2
    , p3_a20 in out nocopy  VARCHAR2
    , p3_a21 in out nocopy  VARCHAR2
    , p3_a22 in out nocopy  NUMBER
    , p3_a23 in out nocopy  VARCHAR2
    , p3_a24 in out nocopy  VARCHAR2
    , p3_a25 in out nocopy  NUMBER
    , p3_a26 in out nocopy  VARCHAR2
    , p3_a27 in out nocopy  VARCHAR2
    , p3_a28 in out nocopy  VARCHAR2
    , p3_a29 in out nocopy  VARCHAR2
    , p3_a30 in out nocopy  VARCHAR2
    , p3_a31 in out nocopy  VARCHAR2
    , p3_a32 in out nocopy  VARCHAR2
    , p3_a33 in out nocopy  VARCHAR2
    , p3_a34 in out nocopy  VARCHAR2
    , p3_a35 in out nocopy  VARCHAR2
    , p3_a36 in out nocopy  VARCHAR2
    , p3_a37 in out nocopy  VARCHAR2
    , p3_a38 in out nocopy  VARCHAR2
    , p3_a39 in out nocopy  VARCHAR2
    , p3_a40 in out nocopy  VARCHAR2
    , p3_a41 in out nocopy  VARCHAR2
    , p3_a42 in out nocopy  VARCHAR2
    , p3_a43 in out nocopy  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_NUMBER_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_DATE_TABLE
    , p4_a16 in out nocopy JTF_DATE_TABLE
    , p4_a17 in out nocopy JTF_DATE_TABLE
    , p4_a18 in out nocopy JTF_NUMBER_TABLE
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_header_rec csp_parts_requirement.header_rec_type;
    ddpx_line_tbl csp_parts_requirement.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddpx_header_rec.requisition_header_id := p3_a0;
    ddpx_header_rec.requisition_number := p3_a1;
    ddpx_header_rec.description := p3_a2;
    ddpx_header_rec.order_header_id := p3_a3;
    ddpx_header_rec.order_type_id := p3_a4;
    ddpx_header_rec.ship_to_location_id := p3_a5;
    ddpx_header_rec.shipping_method_code := p3_a6;
    ddpx_header_rec.task_id := p3_a7;
    ddpx_header_rec.task_assignment_id := p3_a8;
    ddpx_header_rec.need_by_date := rosetta_g_miss_date_in_map(p3_a9);
    ddpx_header_rec.dest_organization_id := p3_a10;
    ddpx_header_rec.dest_subinventory := p3_a11;
    ddpx_header_rec.operation := p3_a12;
    ddpx_header_rec.requirement_header_id := p3_a13;
    ddpx_header_rec.change_reason := p3_a14;
    ddpx_header_rec.change_comments := p3_a15;
    ddpx_header_rec.resource_type := p3_a16;
    ddpx_header_rec.resource_id := p3_a17;
    ddpx_header_rec.incident_id := p3_a18;
    ddpx_header_rec.address_type := p3_a19;
    ddpx_header_rec.justification := p3_a20;
    ddpx_header_rec.note_to_buyer := p3_a21;
    ddpx_header_rec.note1_id := p3_a22;
    ddpx_header_rec.note1_title := p3_a23;
    ddpx_header_rec.called_from := p3_a24;
    ddpx_header_rec.suggested_vendor_id := p3_a25;
    ddpx_header_rec.suggested_vendor_name := p3_a26;
    ddpx_header_rec.attribute_category := p3_a27;
    ddpx_header_rec.attribute1 := p3_a28;
    ddpx_header_rec.attribute2 := p3_a29;
    ddpx_header_rec.attribute3 := p3_a30;
    ddpx_header_rec.attribute4 := p3_a31;
    ddpx_header_rec.attribute5 := p3_a32;
    ddpx_header_rec.attribute6 := p3_a33;
    ddpx_header_rec.attribute7 := p3_a34;
    ddpx_header_rec.attribute8 := p3_a35;
    ddpx_header_rec.attribute9 := p3_a36;
    ddpx_header_rec.attribute10 := p3_a37;
    ddpx_header_rec.attribute11 := p3_a38;
    ddpx_header_rec.attribute12 := p3_a39;
    ddpx_header_rec.attribute13 := p3_a40;
    ddpx_header_rec.attribute14 := p3_a41;
    ddpx_header_rec.attribute15 := p3_a42;
    ddpx_header_rec.ship_to_contact_id := p3_a43;

    csp_parts_requirement_w.rosetta_table_copy_in_p2(ddpx_line_tbl, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );




    -- here's the delegated call to the old PL/SQL routine
    csp_parts_requirement.save_rqmt_line(p_api_version,
      p_init_msg_list,
      p_commit,
      ddpx_header_rec,
      ddpx_line_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := ddpx_header_rec.requisition_header_id;
    p3_a1 := ddpx_header_rec.requisition_number;
    p3_a2 := ddpx_header_rec.description;
    p3_a3 := ddpx_header_rec.order_header_id;
    p3_a4 := ddpx_header_rec.order_type_id;
    p3_a5 := ddpx_header_rec.ship_to_location_id;
    p3_a6 := ddpx_header_rec.shipping_method_code;
    p3_a7 := ddpx_header_rec.task_id;
    p3_a8 := ddpx_header_rec.task_assignment_id;
    p3_a9 := ddpx_header_rec.need_by_date;
    p3_a10 := ddpx_header_rec.dest_organization_id;
    p3_a11 := ddpx_header_rec.dest_subinventory;
    p3_a12 := ddpx_header_rec.operation;
    p3_a13 := ddpx_header_rec.requirement_header_id;
    p3_a14 := ddpx_header_rec.change_reason;
    p3_a15 := ddpx_header_rec.change_comments;
    p3_a16 := ddpx_header_rec.resource_type;
    p3_a17 := ddpx_header_rec.resource_id;
    p3_a18 := ddpx_header_rec.incident_id;
    p3_a19 := ddpx_header_rec.address_type;
    p3_a20 := ddpx_header_rec.justification;
    p3_a21 := ddpx_header_rec.note_to_buyer;
    p3_a22 := ddpx_header_rec.note1_id;
    p3_a23 := ddpx_header_rec.note1_title;
    p3_a24 := ddpx_header_rec.called_from;
    p3_a25 := ddpx_header_rec.suggested_vendor_id;
    p3_a26 := ddpx_header_rec.suggested_vendor_name;
    p3_a27 := ddpx_header_rec.attribute_category;
    p3_a28 := ddpx_header_rec.attribute1;
    p3_a29 := ddpx_header_rec.attribute2;
    p3_a30 := ddpx_header_rec.attribute3;
    p3_a31 := ddpx_header_rec.attribute4;
    p3_a32 := ddpx_header_rec.attribute5;
    p3_a33 := ddpx_header_rec.attribute6;
    p3_a34 := ddpx_header_rec.attribute7;
    p3_a35 := ddpx_header_rec.attribute8;
    p3_a36 := ddpx_header_rec.attribute9;
    p3_a37 := ddpx_header_rec.attribute10;
    p3_a38 := ddpx_header_rec.attribute11;
    p3_a39 := ddpx_header_rec.attribute12;
    p3_a40 := ddpx_header_rec.attribute13;
    p3_a41 := ddpx_header_rec.attribute14;
    p3_a42 := ddpx_header_rec.attribute15;
    p3_a43 := ddpx_header_rec.ship_to_contact_id;

    csp_parts_requirement_w.rosetta_table_copy_out_p2(ddpx_line_tbl, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );



  end;

  procedure delete_rqmt_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_line_tbl csp_parts_requirement.rqmt_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    csp_parts_requirement_w.rosetta_table_copy_in_p6(ddp_line_tbl, p3_a0
      );




    -- here's the delegated call to the old PL/SQL routine
    csp_parts_requirement.delete_rqmt_line(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_line_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    csp_parts_requirement_w.rosetta_table_copy_out_p6(ddp_line_tbl, p3_a0
      );



  end;

  procedure check_availability(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_header_id  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a13 out nocopy JTF_NUMBER_TABLE
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_DATE_TABLE
    , p4_a16 out nocopy JTF_DATE_TABLE
    , p4_a17 out nocopy JTF_DATE_TABLE
    , p4_a18 out nocopy JTF_NUMBER_TABLE
    , p4_a19 out nocopy JTF_NUMBER_TABLE
    , p4_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , x_avail_flag out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_line_tbl csp_parts_requirement.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    csp_parts_requirement.check_availability(p_api_version,
      p_init_msg_list,
      p_commit,
      p_header_id,
      ddx_line_tbl,
      x_avail_flag,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csp_parts_requirement_w.rosetta_table_copy_out_p2(ddx_line_tbl, p4_a0
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
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      );




  end;

  procedure create_order(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_header_id  NUMBER
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_order_tbl csp_parts_requirement.order_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    csp_parts_requirement.create_order(p_api_version,
      p_init_msg_list,
      p_commit,
      p_header_id,
      ddx_order_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    csp_parts_requirement_w.rosetta_table_copy_out_p8(ddx_order_tbl, p4_a0
      , p4_a1
      );



  end;

end csp_parts_requirement_w;

/
