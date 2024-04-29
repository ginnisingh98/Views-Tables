--------------------------------------------------------
--  DDL for Package Body OZF_PRICELIST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PRICELIST_PVT_W" as
  /* $Header: ozfwpltb.pls 120.1 2005/08/17 17:56 appldev ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_pricelist_pvt.qualifiers_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).comparison_operator_code := a0(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).excluder_flag := a3(indx);
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).qualifier_attribute := a6(indx);
          t(ddindx).qualifier_attr_value := a7(indx);
          t(ddindx).qualifier_attr_value_to := a8(indx);
          t(ddindx).qualifier_context := a9(indx);
          t(ddindx).qualifier_datatype := a10(indx);
          t(ddindx).qualifier_grouping_no := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).qualifier_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).qualifier_precedence := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).operation := a15(indx);
          t(ddindx).context := a16(indx);
          t(ddindx).attribute1 := a17(indx);
          t(ddindx).attribute2 := a18(indx);
          t(ddindx).attribute3 := a19(indx);
          t(ddindx).attribute4 := a20(indx);
          t(ddindx).attribute5 := a21(indx);
          t(ddindx).attribute6 := a22(indx);
          t(ddindx).attribute7 := a23(indx);
          t(ddindx).attribute8 := a24(indx);
          t(ddindx).attribute9 := a25(indx);
          t(ddindx).attribute10 := a26(indx);
          t(ddindx).attribute11 := a27(indx);
          t(ddindx).attribute12 := a28(indx);
          t(ddindx).attribute13 := a29(indx);
          t(ddindx).attribute14 := a30(indx);
          t(ddindx).attribute15 := a31(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_pricelist_pvt.qualifiers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).comparison_operator_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a2(indx) := t(ddindx).end_date_active;
          a3(indx) := t(ddindx).excluder_flag;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a6(indx) := t(ddindx).qualifier_attribute;
          a7(indx) := t(ddindx).qualifier_attr_value;
          a8(indx) := t(ddindx).qualifier_attr_value_to;
          a9(indx) := t(ddindx).qualifier_context;
          a10(indx) := t(ddindx).qualifier_datatype;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_grouping_no);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_precedence);
          a14(indx) := t(ddindx).start_date_active;
          a15(indx) := t(ddindx).operation;
          a16(indx) := t(ddindx).context;
          a17(indx) := t(ddindx).attribute1;
          a18(indx) := t(ddindx).attribute2;
          a19(indx) := t(ddindx).attribute3;
          a20(indx) := t(ddindx).attribute4;
          a21(indx) := t(ddindx).attribute5;
          a22(indx) := t(ddindx).attribute6;
          a23(indx) := t(ddindx).attribute7;
          a24(indx) := t(ddindx).attribute8;
          a25(indx) := t(ddindx).attribute9;
          a26(indx) := t(ddindx).attribute10;
          a27(indx) := t(ddindx).attribute11;
          a28(indx) := t(ddindx).attribute12;
          a29(indx) := t(ddindx).attribute13;
          a30(indx) := t(ddindx).attribute14;
          a31(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy ozf_pricelist_pvt.price_list_line_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).arithmetic_operator := a0(indx);
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).list_price := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).operand := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).operation := a7(indx);
          t(ddindx).primary_uom_flag := a8(indx);
          t(ddindx).product_precedence := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).static_formula_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).dynamic_formula_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).jtf_note_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).comments := a13(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).context := a15(indx);
          t(ddindx).attribute1 := a16(indx);
          t(ddindx).attribute2 := a17(indx);
          t(ddindx).attribute3 := a18(indx);
          t(ddindx).attribute4 := a19(indx);
          t(ddindx).attribute5 := a20(indx);
          t(ddindx).attribute6 := a21(indx);
          t(ddindx).attribute7 := a22(indx);
          t(ddindx).attribute8 := a23(indx);
          t(ddindx).attribute9 := a24(indx);
          t(ddindx).attribute10 := a25(indx);
          t(ddindx).attribute11 := a26(indx);
          t(ddindx).attribute12 := a27(indx);
          t(ddindx).attribute13 := a28(indx);
          t(ddindx).attribute14 := a29(indx);
          t(ddindx).attribute15 := a30(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ozf_pricelist_pvt.price_list_line_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_2000();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_2000();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).arithmetic_operator;
          a1(indx) := t(ddindx).end_date_active;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).list_price);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).operand);
          a6(indx) := t(ddindx).start_date_active;
          a7(indx) := t(ddindx).operation;
          a8(indx) := t(ddindx).primary_uom_flag;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).product_precedence);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).static_formula_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).dynamic_formula_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).jtf_note_id);
          a13(indx) := t(ddindx).comments;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a15(indx) := t(ddindx).context;
          a16(indx) := t(ddindx).attribute1;
          a17(indx) := t(ddindx).attribute2;
          a18(indx) := t(ddindx).attribute3;
          a19(indx) := t(ddindx).attribute4;
          a20(indx) := t(ddindx).attribute5;
          a21(indx) := t(ddindx).attribute6;
          a22(indx) := t(ddindx).attribute7;
          a23(indx) := t(ddindx).attribute8;
          a24(indx) := t(ddindx).attribute9;
          a25(indx) := t(ddindx).attribute10;
          a26(indx) := t(ddindx).attribute11;
          a27(indx) := t(ddindx).attribute12;
          a28(indx) := t(ddindx).attribute13;
          a29(indx) := t(ddindx).attribute14;
          a30(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy ozf_pricelist_pvt.pricing_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).pricing_attribute := a1(indx);
          t(ddindx).pricing_attribute_context := a2(indx);
          t(ddindx).pricing_attribute_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).pricing_attr_value_from := a4(indx);
          t(ddindx).pricing_attr_value_to := a5(indx);
          t(ddindx).product_attribute := a6(indx);
          t(ddindx).product_attribute_context := a7(indx);
          t(ddindx).product_attr_value := a8(indx);
          t(ddindx).product_uom_code := a9(indx);
          t(ddindx).operation := a10(indx);
          t(ddindx).price_list_line_index := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).comparison_operator_code := a12(indx);
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a13(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ozf_pricelist_pvt.pricing_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a1(indx) := t(ddindx).pricing_attribute;
          a2(indx) := t(ddindx).pricing_attribute_context;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_attribute_id);
          a4(indx) := t(ddindx).pricing_attr_value_from;
          a5(indx) := t(ddindx).pricing_attr_value_to;
          a6(indx) := t(ddindx).product_attribute;
          a7(indx) := t(ddindx).product_attribute_context;
          a8(indx) := t(ddindx).product_attr_value;
          a9(indx) := t(ddindx).product_uom_code;
          a10(indx) := t(ddindx).operation;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_line_index);
          a12(indx) := t(ddindx).comparison_operator_code;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p12(t out nocopy ozf_pricelist_pvt.num_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t ozf_pricelist_pvt.num_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p12;

  procedure process_price_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_DATE_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_DATE_TABLE
    , p8_a7 JTF_VARCHAR2_TABLE_100
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_NUMBER_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_VARCHAR2_TABLE_2000
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_VARCHAR2_TABLE_100
    , p8_a16 JTF_VARCHAR2_TABLE_300
    , p8_a17 JTF_VARCHAR2_TABLE_300
    , p8_a18 JTF_VARCHAR2_TABLE_300
    , p8_a19 JTF_VARCHAR2_TABLE_300
    , p8_a20 JTF_VARCHAR2_TABLE_300
    , p8_a21 JTF_VARCHAR2_TABLE_300
    , p8_a22 JTF_VARCHAR2_TABLE_300
    , p8_a23 JTF_VARCHAR2_TABLE_300
    , p8_a24 JTF_VARCHAR2_TABLE_300
    , p8_a25 JTF_VARCHAR2_TABLE_300
    , p8_a26 JTF_VARCHAR2_TABLE_300
    , p8_a27 JTF_VARCHAR2_TABLE_300
    , p8_a28 JTF_VARCHAR2_TABLE_300
    , p8_a29 JTF_VARCHAR2_TABLE_300
    , p8_a30 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p9_a2 JTF_VARCHAR2_TABLE_100
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_VARCHAR2_TABLE_300
    , p9_a5 JTF_VARCHAR2_TABLE_300
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_100
    , p9_a8 JTF_VARCHAR2_TABLE_300
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_NUMBER_TABLE
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_DATE_TABLE
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_VARCHAR2_TABLE_100
    , p10_a7 JTF_VARCHAR2_TABLE_300
    , p10_a8 JTF_VARCHAR2_TABLE_300
    , p10_a9 JTF_VARCHAR2_TABLE_100
    , p10_a10 JTF_VARCHAR2_TABLE_100
    , p10_a11 JTF_NUMBER_TABLE
    , p10_a12 JTF_NUMBER_TABLE
    , p10_a13 JTF_NUMBER_TABLE
    , p10_a14 JTF_DATE_TABLE
    , p10_a15 JTF_VARCHAR2_TABLE_100
    , p10_a16 JTF_VARCHAR2_TABLE_100
    , p10_a17 JTF_VARCHAR2_TABLE_300
    , p10_a18 JTF_VARCHAR2_TABLE_300
    , p10_a19 JTF_VARCHAR2_TABLE_300
    , p10_a20 JTF_VARCHAR2_TABLE_300
    , p10_a21 JTF_VARCHAR2_TABLE_300
    , p10_a22 JTF_VARCHAR2_TABLE_300
    , p10_a23 JTF_VARCHAR2_TABLE_300
    , p10_a24 JTF_VARCHAR2_TABLE_300
    , p10_a25 JTF_VARCHAR2_TABLE_300
    , p10_a26 JTF_VARCHAR2_TABLE_300
    , p10_a27 JTF_VARCHAR2_TABLE_300
    , p10_a28 JTF_VARCHAR2_TABLE_300
    , p10_a29 JTF_VARCHAR2_TABLE_300
    , p10_a30 JTF_VARCHAR2_TABLE_300
    , p10_a31 JTF_VARCHAR2_TABLE_300
    , x_list_header_id out nocopy  NUMBER
    , x_error_source out nocopy  VARCHAR2
    , x_error_location out nocopy  NUMBER
    , p7_a0  VARCHAR2 := fnd_api.g_miss_char
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  NUMBER := 0-1962.0724
  )

  as
    ddp_price_list_rec ozf_pricelist_pvt.ozf_price_list_rec_type;
    ddp_price_list_line_tbl ozf_pricelist_pvt.price_list_line_tbl_type;
    ddp_pricing_attr_tbl ozf_pricelist_pvt.pricing_attr_tbl_type;
    ddp_qualifiers_tbl ozf_pricelist_pvt.qualifiers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_price_list_rec.currency_code := p7_a0;
    ddp_price_list_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a1);
    ddp_price_list_rec.list_header_id := rosetta_g_miss_num_map(p7_a2);
    ddp_price_list_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a3);
    ddp_price_list_rec.operation := p7_a4;
    ddp_price_list_rec.name := p7_a5;
    ddp_price_list_rec.description := p7_a6;
    ddp_price_list_rec.active_flag := p7_a7;
    ddp_price_list_rec.price_list_attribute_id := rosetta_g_miss_num_map(p7_a8);
    ddp_price_list_rec.user_status_id := rosetta_g_miss_num_map(p7_a9);
    ddp_price_list_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a10);
    ddp_price_list_rec.status_code := p7_a11;
    ddp_price_list_rec.owner_id := rosetta_g_miss_num_map(p7_a12);
    ddp_price_list_rec.qp_list_header_id := rosetta_g_miss_num_map(p7_a13);
    ddp_price_list_rec.object_version_number := rosetta_g_miss_num_map(p7_a14);
    ddp_price_list_rec.status_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_price_list_rec.wf_item_key := p7_a16;
    ddp_price_list_rec.currency_header_id := rosetta_g_miss_num_map(p7_a17);
    ddp_price_list_rec.context := p7_a18;
    ddp_price_list_rec.attribute1 := p7_a19;
    ddp_price_list_rec.attribute2 := p7_a20;
    ddp_price_list_rec.attribute3 := p7_a21;
    ddp_price_list_rec.attribute4 := p7_a22;
    ddp_price_list_rec.attribute5 := p7_a23;
    ddp_price_list_rec.attribute6 := p7_a24;
    ddp_price_list_rec.attribute7 := p7_a25;
    ddp_price_list_rec.attribute8 := p7_a26;
    ddp_price_list_rec.attribute9 := p7_a27;
    ddp_price_list_rec.attribute10 := p7_a28;
    ddp_price_list_rec.attribute11 := p7_a29;
    ddp_price_list_rec.attribute12 := p7_a30;
    ddp_price_list_rec.attribute13 := p7_a31;
    ddp_price_list_rec.attribute14 := p7_a32;
    ddp_price_list_rec.attribute15 := p7_a33;
    ddp_price_list_rec.global_flag := p7_a34;
    ddp_price_list_rec.org_id := rosetta_g_miss_num_map(p7_a35);

    ozf_pricelist_pvt_w.rosetta_table_copy_in_p5(ddp_price_list_line_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      );

    ozf_pricelist_pvt_w.rosetta_table_copy_in_p7(ddp_pricing_attr_tbl, p9_a0
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
      );

    ozf_pricelist_pvt_w.rosetta_table_copy_in_p3(ddp_qualifiers_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_pricelist_pvt.process_price_list(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_price_list_rec,
      ddp_price_list_line_tbl,
      ddp_pricing_attr_tbl,
      ddp_qualifiers_tbl,
      x_list_header_id,
      x_error_source,
      x_error_location);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure add_inventory_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_org_inv_item_id  NUMBER
    , p_new_inv_item_id JTF_NUMBER_TABLE
  )

  as
    ddp_new_inv_item_id ozf_pricelist_pvt.num_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_pricelist_pvt_w.rosetta_table_copy_in_p12(ddp_new_inv_item_id, p_new_inv_item_id);

    -- here's the delegated call to the old PL/SQL routine
    ozf_pricelist_pvt.add_inventory_item(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_org_inv_item_id,
      ddp_new_inv_item_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ozf_pricelist_pvt_w;

/
