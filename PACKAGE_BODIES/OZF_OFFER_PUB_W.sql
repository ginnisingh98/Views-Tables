--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_PUB_W" as
  /* $Header: ozfwofpb.pls 120.3 2005/08/10 17:37 appldev ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ozf_offer_pub.act_product_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).activity_product_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).act_product_used_by_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).arc_act_product_used_by := a3(indx);
          t(ddindx).product_sale_type := a4(indx);
          t(ddindx).primary_product_flag := a5(indx);
          t(ddindx).enabled_flag := a6(indx);
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).category_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).category_set_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).attribute_category := a11(indx);
          t(ddindx).level_type_code := a12(indx);
          t(ddindx).excluded_flag := a13(indx);
          t(ddindx).line_lumpsum_amount := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).line_lumpsum_qty := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).scan_value := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).uom_code := a17(indx);
          t(ddindx).adjustment_flag := a18(indx);
          t(ddindx).scan_unit_forecast := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).channel_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).quantity := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).operation := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ozf_offer_pub.act_product_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).activity_product_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).act_product_used_by_id);
          a3(indx) := t(ddindx).arc_act_product_used_by;
          a4(indx) := t(ddindx).product_sale_type;
          a5(indx) := t(ddindx).primary_product_flag;
          a6(indx) := t(ddindx).enabled_flag;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).category_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).category_set_id);
          a11(indx) := t(ddindx).attribute_category;
          a12(indx) := t(ddindx).level_type_code;
          a13(indx) := t(ddindx).excluded_flag;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).line_lumpsum_amount);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).line_lumpsum_qty);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).scan_value);
          a17(indx) := t(ddindx).uom_code;
          a18(indx) := t(ddindx).adjustment_flag;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).scan_unit_forecast);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).channel_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a22(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy ozf_offer_pub.discount_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_discount_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).volume_from := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).volume_to := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).volume_operator := a4(indx);
          t(ddindx).volume_type := a5(indx);
          t(ddindx).volume_break_type := a6(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).discount_type := a8(indx);
          t(ddindx).tier_type := a9(indx);
          t(ddindx).tier_level := a10(indx);
          t(ddindx).incompatibility_group := a11(indx);
          t(ddindx).precedence := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).bucket := a13(indx);
          t(ddindx).scan_value := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).scan_data_quantity := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).scan_unit_forecast := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).channel_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).adjustment_flag := a18(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).uom_code := a21(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).off_discount_product_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).parent_off_disc_prod_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).product_level := a31(indx);
          t(ddindx).product_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).excluder_flag := a33(indx);
          t(ddindx).operation := a34(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ozf_offer_pub.discount_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_discount_line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).volume_from);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).volume_to);
          a4(indx) := t(ddindx).volume_operator;
          a5(indx) := t(ddindx).volume_type;
          a6(indx) := t(ddindx).volume_break_type;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a8(indx) := t(ddindx).discount_type;
          a9(indx) := t(ddindx).tier_type;
          a10(indx) := t(ddindx).tier_level;
          a11(indx) := t(ddindx).incompatibility_group;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).precedence);
          a13(indx) := t(ddindx).bucket;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).scan_value);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).scan_data_quantity);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).scan_unit_forecast);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).channel_id);
          a18(indx) := t(ddindx).adjustment_flag;
          a19(indx) := t(ddindx).start_date_active;
          a20(indx) := t(ddindx).end_date_active;
          a21(indx) := t(ddindx).uom_code;
          a22(indx) := t(ddindx).creation_date;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a24(indx) := t(ddindx).last_update_date;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).off_discount_product_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).parent_off_disc_prod_id);
          a31(indx) := t(ddindx).product_level;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).product_id);
          a33(indx) := t(ddindx).excluder_flag;
          a34(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy ozf_offer_pub.prod_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).off_discount_product_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_off_disc_prod_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).product_level := a2(indx);
          t(ddindx).product_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).excluder_flag := a4(indx);
          t(ddindx).uom_code := a5(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).operation := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ozf_offer_pub.prod_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).off_discount_product_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_off_disc_prod_id);
          a2(indx) := t(ddindx).product_level;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).product_id);
          a4(indx) := t(ddindx).excluder_flag;
          a5(indx) := t(ddindx).uom_code;
          a6(indx) := t(ddindx).start_date_active;
          a7(indx) := t(ddindx).end_date_active;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a12(indx) := t(ddindx).last_update_date;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a16(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy ozf_offer_pub.excl_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).off_discount_product_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_off_disc_prod_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).product_level := a2(indx);
          t(ddindx).product_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).operation := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ozf_offer_pub.excl_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).off_discount_product_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_off_disc_prod_id);
          a2(indx) := t(ddindx).product_level;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).product_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := t(ddindx).start_date_active;
          a6(indx) := t(ddindx).end_date_active;
          a7(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy ozf_offer_pub.offer_tier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_discount_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).volume_from := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).volume_to := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).volume_operator := a5(indx);
          t(ddindx).volume_type := a6(indx);
          t(ddindx).volume_break_type := a7(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).discount_type := a9(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).uom_code := a12(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).operation := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t ozf_offer_pub.offer_tier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_discount_line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).volume_from);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).volume_to);
          a5(indx) := t(ddindx).volume_operator;
          a6(indx) := t(ddindx).volume_type;
          a7(indx) := t(ddindx).volume_break_type;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a9(indx) := t(ddindx).discount_type;
          a10(indx) := t(ddindx).start_date_active;
          a11(indx) := t(ddindx).end_date_active;
          a12(indx) := t(ddindx).uom_code;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a14(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p12(t out nocopy ozf_offer_pub.na_qualifier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
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
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).qualifier_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).qualifier_grouping_no := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).qualifier_context := a7(indx);
          t(ddindx).qualifier_attribute := a8(indx);
          t(ddindx).qualifier_attr_value := a9(indx);
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).context := a14(indx);
          t(ddindx).attribute1 := a15(indx);
          t(ddindx).attribute2 := a16(indx);
          t(ddindx).attribute3 := a17(indx);
          t(ddindx).attribute4 := a18(indx);
          t(ddindx).attribute5 := a19(indx);
          t(ddindx).attribute6 := a20(indx);
          t(ddindx).attribute7 := a21(indx);
          t(ddindx).attribute8 := a22(indx);
          t(ddindx).attribute9 := a23(indx);
          t(ddindx).attribute10 := a24(indx);
          t(ddindx).attribute11 := a25(indx);
          t(ddindx).attribute12 := a26(indx);
          t(ddindx).attribute13 := a27(indx);
          t(ddindx).attribute14 := a28(indx);
          t(ddindx).attribute15 := a29(indx);
          t(ddindx).active_flag := a30(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).operation := a32(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t ozf_offer_pub.na_qualifier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
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
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_300();
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
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_300();
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
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_id);
          a1(indx) := t(ddindx).creation_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a3(indx) := t(ddindx).last_update_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_grouping_no);
          a7(indx) := t(ddindx).qualifier_context;
          a8(indx) := t(ddindx).qualifier_attribute;
          a9(indx) := t(ddindx).qualifier_attr_value;
          a10(indx) := t(ddindx).start_date_active;
          a11(indx) := t(ddindx).end_date_active;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a14(indx) := t(ddindx).context;
          a15(indx) := t(ddindx).attribute1;
          a16(indx) := t(ddindx).attribute2;
          a17(indx) := t(ddindx).attribute3;
          a18(indx) := t(ddindx).attribute4;
          a19(indx) := t(ddindx).attribute5;
          a20(indx) := t(ddindx).attribute6;
          a21(indx) := t(ddindx).attribute7;
          a22(indx) := t(ddindx).attribute8;
          a23(indx) := t(ddindx).attribute9;
          a24(indx) := t(ddindx).attribute10;
          a25(indx) := t(ddindx).attribute11;
          a26(indx) := t(ddindx).attribute12;
          a27(indx) := t(ddindx).attribute13;
          a28(indx) := t(ddindx).attribute14;
          a29(indx) := t(ddindx).attribute15;
          a30(indx) := t(ddindx).active_flag;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a32(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p14(t out nocopy ozf_offer_pub.budget_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
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
          t(ddindx).act_budget_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).budget_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).budget_amount := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).operation := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t ozf_offer_pub.budget_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).act_budget_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).budget_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).budget_amount);
          a3(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p17(t out nocopy ozf_offer_pub.modifier_line_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_2000
    , a40 JTF_VARCHAR2_TABLE_100
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
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_line_type := a0(indx);
          t(ddindx).operation := a1(indx);
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).list_line_type_code := a4(indx);
          t(ddindx).operand := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).arithmetic_operator := a8(indx);
          t(ddindx).active_flag := a9(indx);
          t(ddindx).qd_operand := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).qd_arithmetic_operator := a11(indx);
          t(ddindx).qd_related_deal_lines_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).qd_object_version_number := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).qd_estimated_qty_is_max := a14(indx);
          t(ddindx).qd_list_line_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).qd_estimated_amount_is_max := a16(indx);
          t(ddindx).estim_gl_value := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).benefit_price_list_line_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).benefit_limit := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).benefit_qty := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).benefit_uom_code := a21(indx);
          t(ddindx).substitution_context := a22(indx);
          t(ddindx).substitution_attr := a23(indx);
          t(ddindx).substitution_val := a24(indx);
          t(ddindx).price_break_type_code := a25(indx);
          t(ddindx).pricing_attribute_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).product_attribute_context := a27(indx);
          t(ddindx).product_attr := a28(indx);
          t(ddindx).product_attr_val := a29(indx);
          t(ddindx).product_uom_code := a30(indx);
          t(ddindx).pricing_attribute_context := a31(indx);
          t(ddindx).pricing_attr := a32(indx);
          t(ddindx).pricing_attr_value_from := a33(indx);
          t(ddindx).pricing_attr_value_to := a34(indx);
          t(ddindx).excluder_flag := a35(indx);
          t(ddindx).order_value_from := a36(indx);
          t(ddindx).order_value_to := a37(indx);
          t(ddindx).qualifier_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).comments := a39(indx);
          t(ddindx).context := a40(indx);
          t(ddindx).attribute1 := a41(indx);
          t(ddindx).attribute2 := a42(indx);
          t(ddindx).attribute3 := a43(indx);
          t(ddindx).attribute4 := a44(indx);
          t(ddindx).attribute5 := a45(indx);
          t(ddindx).attribute6 := a46(indx);
          t(ddindx).attribute7 := a47(indx);
          t(ddindx).attribute8 := a48(indx);
          t(ddindx).attribute9 := a49(indx);
          t(ddindx).attribute10 := a50(indx);
          t(ddindx).attribute11 := a51(indx);
          t(ddindx).attribute12 := a52(indx);
          t(ddindx).attribute13 := a53(indx);
          t(ddindx).attribute14 := a54(indx);
          t(ddindx).attribute15 := a55(indx);
          t(ddindx).max_qty_per_order := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).max_qty_per_order_id := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).max_qty_per_customer := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).max_qty_per_customer_id := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).max_qty_per_rule := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).max_qty_per_rule_id := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).max_orders_per_customer := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).max_orders_per_customer_id := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).max_amount_per_rule := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).max_amount_per_rule_id := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).estimate_qty_uom := a66(indx);
          t(ddindx).generate_using_formula_id := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).price_by_formula_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).generate_using_formula := a69(indx);
          t(ddindx).price_by_formula := a70(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t ozf_offer_pub.modifier_line_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_2000
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_300
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_300
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_300();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_2000();
    a40 := JTF_VARCHAR2_TABLE_100();
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
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_300();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_2000();
      a40 := JTF_VARCHAR2_TABLE_100();
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
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
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
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).offer_line_type;
          a1(indx) := t(ddindx).operation;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a4(indx) := t(ddindx).list_line_type_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).operand);
          a6(indx) := t(ddindx).start_date_active;
          a7(indx) := t(ddindx).end_date_active;
          a8(indx) := t(ddindx).arithmetic_operator;
          a9(indx) := t(ddindx).active_flag;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).qd_operand);
          a11(indx) := t(ddindx).qd_arithmetic_operator;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).qd_related_deal_lines_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).qd_object_version_number);
          a14(indx) := t(ddindx).qd_estimated_qty_is_max;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).qd_list_line_id);
          a16(indx) := t(ddindx).qd_estimated_amount_is_max;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).estim_gl_value);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_price_list_line_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_limit);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_qty);
          a21(indx) := t(ddindx).benefit_uom_code;
          a22(indx) := t(ddindx).substitution_context;
          a23(indx) := t(ddindx).substitution_attr;
          a24(indx) := t(ddindx).substitution_val;
          a25(indx) := t(ddindx).price_break_type_code;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_attribute_id);
          a27(indx) := t(ddindx).product_attribute_context;
          a28(indx) := t(ddindx).product_attr;
          a29(indx) := t(ddindx).product_attr_val;
          a30(indx) := t(ddindx).product_uom_code;
          a31(indx) := t(ddindx).pricing_attribute_context;
          a32(indx) := t(ddindx).pricing_attr;
          a33(indx) := t(ddindx).pricing_attr_value_from;
          a34(indx) := t(ddindx).pricing_attr_value_to;
          a35(indx) := t(ddindx).excluder_flag;
          a36(indx) := t(ddindx).order_value_from;
          a37(indx) := t(ddindx).order_value_to;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_id);
          a39(indx) := t(ddindx).comments;
          a40(indx) := t(ddindx).context;
          a41(indx) := t(ddindx).attribute1;
          a42(indx) := t(ddindx).attribute2;
          a43(indx) := t(ddindx).attribute3;
          a44(indx) := t(ddindx).attribute4;
          a45(indx) := t(ddindx).attribute5;
          a46(indx) := t(ddindx).attribute6;
          a47(indx) := t(ddindx).attribute7;
          a48(indx) := t(ddindx).attribute8;
          a49(indx) := t(ddindx).attribute9;
          a50(indx) := t(ddindx).attribute10;
          a51(indx) := t(ddindx).attribute11;
          a52(indx) := t(ddindx).attribute12;
          a53(indx) := t(ddindx).attribute13;
          a54(indx) := t(ddindx).attribute14;
          a55(indx) := t(ddindx).attribute15;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_order);
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_order_id);
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_customer);
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_customer_id);
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_rule);
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_rule_id);
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).max_orders_per_customer);
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).max_orders_per_customer_id);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).max_amount_per_rule);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).max_amount_per_rule_id);
          a66(indx) := t(ddindx).estimate_qty_uom;
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).generate_using_formula_id);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).price_by_formula_id);
          a69(indx) := t(ddindx).generate_using_formula;
          a70(indx) := t(ddindx).price_by_formula;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p19(t out nocopy ozf_offer_pub.qualifiers_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).qualifier_context := a0(indx);
          t(ddindx).qualifier_attribute := a1(indx);
          t(ddindx).qualifier_attr_value := a2(indx);
          t(ddindx).qualifier_attr_value_to := a3(indx);
          t(ddindx).comparison_operator_code := a4(indx);
          t(ddindx).qualifier_grouping_no := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).qualifier_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).activity_market_segment_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).operation := a12(indx);
          t(ddindx).context := a13(indx);
          t(ddindx).attribute1 := a14(indx);
          t(ddindx).attribute2 := a15(indx);
          t(ddindx).attribute3 := a16(indx);
          t(ddindx).attribute4 := a17(indx);
          t(ddindx).attribute5 := a18(indx);
          t(ddindx).attribute6 := a19(indx);
          t(ddindx).attribute7 := a20(indx);
          t(ddindx).attribute8 := a21(indx);
          t(ddindx).attribute9 := a22(indx);
          t(ddindx).attribute10 := a23(indx);
          t(ddindx).attribute11 := a24(indx);
          t(ddindx).attribute12 := a25(indx);
          t(ddindx).attribute13 := a26(indx);
          t(ddindx).attribute14 := a27(indx);
          t(ddindx).attribute15 := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t ozf_offer_pub.qualifiers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_300();
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
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).qualifier_context;
          a1(indx) := t(ddindx).qualifier_attribute;
          a2(indx) := t(ddindx).qualifier_attr_value;
          a3(indx) := t(ddindx).qualifier_attr_value_to;
          a4(indx) := t(ddindx).comparison_operator_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_grouping_no);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_id);
          a9(indx) := t(ddindx).start_date_active;
          a10(indx) := t(ddindx).end_date_active;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).activity_market_segment_id);
          a12(indx) := t(ddindx).operation;
          a13(indx) := t(ddindx).context;
          a14(indx) := t(ddindx).attribute1;
          a15(indx) := t(ddindx).attribute2;
          a16(indx) := t(ddindx).attribute3;
          a17(indx) := t(ddindx).attribute4;
          a18(indx) := t(ddindx).attribute5;
          a19(indx) := t(ddindx).attribute6;
          a20(indx) := t(ddindx).attribute7;
          a21(indx) := t(ddindx).attribute8;
          a22(indx) := t(ddindx).attribute9;
          a23(indx) := t(ddindx).attribute10;
          a24(indx) := t(ddindx).attribute11;
          a25(indx) := t(ddindx).attribute12;
          a26(indx) := t(ddindx).attribute13;
          a27(indx) := t(ddindx).attribute14;
          a28(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p21(t out nocopy ozf_offer_pub.vo_disc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_2000
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).parent_discount_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).volume_from := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).volume_to := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).volume_operator := a4(indx);
          t(ddindx).volume_type := a5(indx);
          t(ddindx).volume_break_type := a6(indx);
          t(ddindx).discount := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).discount_type := a8(indx);
          t(ddindx).tier_type := a9(indx);
          t(ddindx).tier_level := a10(indx);
          t(ddindx).uom_code := a11(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).discount_by_code := a14(indx);
          t(ddindx).formula_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).offr_disc_struct_name_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).name := a17(indx);
          t(ddindx).description := a18(indx);
          t(ddindx).operation := a19(indx);
          t(ddindx).pbh_index := rosetta_g_miss_num_map(a20(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t ozf_offer_pub.vo_disc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_2000
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_2000();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_2000();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).parent_discount_line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).volume_from);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).volume_to);
          a4(indx) := t(ddindx).volume_operator;
          a5(indx) := t(ddindx).volume_type;
          a6(indx) := t(ddindx).volume_break_type;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).discount);
          a8(indx) := t(ddindx).discount_type;
          a9(indx) := t(ddindx).tier_type;
          a10(indx) := t(ddindx).tier_level;
          a11(indx) := t(ddindx).uom_code;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a14(indx) := t(ddindx).discount_by_code;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).formula_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).offr_disc_struct_name_id);
          a17(indx) := t(ddindx).name;
          a18(indx) := t(ddindx).description;
          a19(indx) := t(ddindx).operation;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).pbh_index);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure rosetta_table_copy_in_p23(t out nocopy ozf_offer_pub.vo_prod_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).off_discount_product_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).excluder_flag := a1(indx);
          t(ddindx).offer_discount_line_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).product_context := a5(indx);
          t(ddindx).product_attribute := a6(indx);
          t(ddindx).product_attr_value := a7(indx);
          t(ddindx).apply_discount_flag := a8(indx);
          t(ddindx).include_volume_flag := a9(indx);
          t(ddindx).operation := a10(indx);
          t(ddindx).pbh_index := rosetta_g_miss_num_map(a11(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t ozf_offer_pub.vo_prod_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).off_discount_product_id);
          a1(indx) := t(ddindx).excluder_flag;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).offer_discount_line_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := t(ddindx).product_context;
          a6(indx) := t(ddindx).product_attribute;
          a7(indx) := t(ddindx).product_attr_value;
          a8(indx) := t(ddindx).apply_discount_flag;
          a9(indx) := t(ddindx).include_volume_flag;
          a10(indx) := t(ddindx).operation;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).pbh_index);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p25(t out nocopy ozf_offer_pub.vo_mo_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_market_option_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).offer_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).qp_list_header_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).group_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).retroactive_flag := a4(indx);
          t(ddindx).beneficiary_party_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).combine_schedule_flag := a6(indx);
          t(ddindx).volume_tracking_level_code := a7(indx);
          t(ddindx).accrue_to_code := a8(indx);
          t(ddindx).precedence := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).security_group_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).operation := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p25;
  procedure rosetta_table_copy_out_p25(t ozf_offer_pub.vo_mo_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_market_option_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).offer_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).qp_list_header_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).group_number);
          a4(indx) := t(ddindx).retroactive_flag;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).beneficiary_party_id);
          a6(indx) := t(ddindx).combine_schedule_flag;
          a7(indx) := t(ddindx).volume_tracking_level_code;
          a8(indx) := t(ddindx).accrue_to_code;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).precedence);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).security_group_id);
          a12(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p25;

  procedure process_modifiers(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_offer_type  VARCHAR2
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_100
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_DATE_TABLE
    , p8_a7 JTF_DATE_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_VARCHAR2_TABLE_100
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_NUMBER_TABLE
    , p8_a21 JTF_VARCHAR2_TABLE_100
    , p8_a22 JTF_VARCHAR2_TABLE_100
    , p8_a23 JTF_VARCHAR2_TABLE_100
    , p8_a24 JTF_VARCHAR2_TABLE_300
    , p8_a25 JTF_VARCHAR2_TABLE_100
    , p8_a26 JTF_NUMBER_TABLE
    , p8_a27 JTF_VARCHAR2_TABLE_100
    , p8_a28 JTF_VARCHAR2_TABLE_100
    , p8_a29 JTF_VARCHAR2_TABLE_300
    , p8_a30 JTF_VARCHAR2_TABLE_100
    , p8_a31 JTF_VARCHAR2_TABLE_100
    , p8_a32 JTF_VARCHAR2_TABLE_100
    , p8_a33 JTF_VARCHAR2_TABLE_300
    , p8_a34 JTF_VARCHAR2_TABLE_300
    , p8_a35 JTF_VARCHAR2_TABLE_100
    , p8_a36 JTF_VARCHAR2_TABLE_300
    , p8_a37 JTF_VARCHAR2_TABLE_300
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_VARCHAR2_TABLE_2000
    , p8_a40 JTF_VARCHAR2_TABLE_100
    , p8_a41 JTF_VARCHAR2_TABLE_300
    , p8_a42 JTF_VARCHAR2_TABLE_300
    , p8_a43 JTF_VARCHAR2_TABLE_300
    , p8_a44 JTF_VARCHAR2_TABLE_300
    , p8_a45 JTF_VARCHAR2_TABLE_300
    , p8_a46 JTF_VARCHAR2_TABLE_300
    , p8_a47 JTF_VARCHAR2_TABLE_300
    , p8_a48 JTF_VARCHAR2_TABLE_300
    , p8_a49 JTF_VARCHAR2_TABLE_300
    , p8_a50 JTF_VARCHAR2_TABLE_300
    , p8_a51 JTF_VARCHAR2_TABLE_300
    , p8_a52 JTF_VARCHAR2_TABLE_300
    , p8_a53 JTF_VARCHAR2_TABLE_300
    , p8_a54 JTF_VARCHAR2_TABLE_300
    , p8_a55 JTF_VARCHAR2_TABLE_300
    , p8_a56 JTF_NUMBER_TABLE
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_NUMBER_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_NUMBER_TABLE
    , p8_a61 JTF_NUMBER_TABLE
    , p8_a62 JTF_NUMBER_TABLE
    , p8_a63 JTF_NUMBER_TABLE
    , p8_a64 JTF_NUMBER_TABLE
    , p8_a65 JTF_NUMBER_TABLE
    , p8_a66 JTF_VARCHAR2_TABLE_100
    , p8_a67 JTF_NUMBER_TABLE
    , p8_a68 JTF_NUMBER_TABLE
    , p8_a69 JTF_VARCHAR2_TABLE_300
    , p8_a70 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p9_a2 JTF_VARCHAR2_TABLE_300
    , p9_a3 JTF_VARCHAR2_TABLE_300
    , p9_a4 JTF_VARCHAR2_TABLE_100
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_VARCHAR2_TABLE_300
    , p9_a15 JTF_VARCHAR2_TABLE_300
    , p9_a16 JTF_VARCHAR2_TABLE_300
    , p9_a17 JTF_VARCHAR2_TABLE_300
    , p9_a18 JTF_VARCHAR2_TABLE_300
    , p9_a19 JTF_VARCHAR2_TABLE_300
    , p9_a20 JTF_VARCHAR2_TABLE_300
    , p9_a21 JTF_VARCHAR2_TABLE_300
    , p9_a22 JTF_VARCHAR2_TABLE_300
    , p9_a23 JTF_VARCHAR2_TABLE_300
    , p9_a24 JTF_VARCHAR2_TABLE_300
    , p9_a25 JTF_VARCHAR2_TABLE_300
    , p9_a26 JTF_VARCHAR2_TABLE_300
    , p9_a27 JTF_VARCHAR2_TABLE_300
    , p9_a28 JTF_VARCHAR2_TABLE_300
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_VARCHAR2_TABLE_100
    , p11_a5 JTF_VARCHAR2_TABLE_100
    , p11_a6 JTF_VARCHAR2_TABLE_100
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_VARCHAR2_TABLE_100
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p11_a13 JTF_VARCHAR2_TABLE_100
    , p11_a14 JTF_NUMBER_TABLE
    , p11_a15 JTF_NUMBER_TABLE
    , p11_a16 JTF_NUMBER_TABLE
    , p11_a17 JTF_VARCHAR2_TABLE_100
    , p11_a18 JTF_VARCHAR2_TABLE_100
    , p11_a19 JTF_NUMBER_TABLE
    , p11_a20 JTF_NUMBER_TABLE
    , p11_a21 JTF_NUMBER_TABLE
    , p11_a22 JTF_VARCHAR2_TABLE_100
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_NUMBER_TABLE
    , p12_a4 JTF_VARCHAR2_TABLE_100
    , p12_a5 JTF_VARCHAR2_TABLE_100
    , p12_a6 JTF_VARCHAR2_TABLE_100
    , p12_a7 JTF_NUMBER_TABLE
    , p12_a8 JTF_VARCHAR2_TABLE_100
    , p12_a9 JTF_VARCHAR2_TABLE_100
    , p12_a10 JTF_VARCHAR2_TABLE_100
    , p12_a11 JTF_VARCHAR2_TABLE_100
    , p12_a12 JTF_NUMBER_TABLE
    , p12_a13 JTF_VARCHAR2_TABLE_100
    , p12_a14 JTF_NUMBER_TABLE
    , p12_a15 JTF_NUMBER_TABLE
    , p12_a16 JTF_NUMBER_TABLE
    , p12_a17 JTF_NUMBER_TABLE
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_DATE_TABLE
    , p12_a20 JTF_DATE_TABLE
    , p12_a21 JTF_VARCHAR2_TABLE_100
    , p12_a22 JTF_DATE_TABLE
    , p12_a23 JTF_NUMBER_TABLE
    , p12_a24 JTF_DATE_TABLE
    , p12_a25 JTF_NUMBER_TABLE
    , p12_a26 JTF_NUMBER_TABLE
    , p12_a27 JTF_NUMBER_TABLE
    , p12_a28 JTF_NUMBER_TABLE
    , p12_a29 JTF_NUMBER_TABLE
    , p12_a30 JTF_NUMBER_TABLE
    , p12_a31 JTF_VARCHAR2_TABLE_100
    , p12_a32 JTF_NUMBER_TABLE
    , p12_a33 JTF_VARCHAR2_TABLE_100
    , p12_a34 JTF_VARCHAR2_TABLE_100
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_VARCHAR2_TABLE_100
    , p13_a3 JTF_NUMBER_TABLE
    , p13_a4 JTF_NUMBER_TABLE
    , p13_a5 JTF_DATE_TABLE
    , p13_a6 JTF_DATE_TABLE
    , p13_a7 JTF_VARCHAR2_TABLE_100
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_NUMBER_TABLE
    , p14_a2 JTF_NUMBER_TABLE
    , p14_a3 JTF_NUMBER_TABLE
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_VARCHAR2_TABLE_100
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p14_a9 JTF_VARCHAR2_TABLE_100
    , p14_a10 JTF_DATE_TABLE
    , p14_a11 JTF_DATE_TABLE
    , p14_a12 JTF_VARCHAR2_TABLE_100
    , p14_a13 JTF_NUMBER_TABLE
    , p14_a14 JTF_VARCHAR2_TABLE_100
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_VARCHAR2_TABLE_100
    , p15_a3 JTF_NUMBER_TABLE
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_DATE_TABLE
    , p15_a7 JTF_DATE_TABLE
    , p15_a8 JTF_NUMBER_TABLE
    , p15_a9 JTF_NUMBER_TABLE
    , p15_a10 JTF_DATE_TABLE
    , p15_a11 JTF_NUMBER_TABLE
    , p15_a12 JTF_DATE_TABLE
    , p15_a13 JTF_NUMBER_TABLE
    , p15_a14 JTF_NUMBER_TABLE
    , p15_a15 JTF_NUMBER_TABLE
    , p15_a16 JTF_VARCHAR2_TABLE_100
    , p16_a0 JTF_NUMBER_TABLE
    , p16_a1 JTF_DATE_TABLE
    , p16_a2 JTF_NUMBER_TABLE
    , p16_a3 JTF_DATE_TABLE
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_NUMBER_TABLE
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_VARCHAR2_TABLE_100
    , p16_a8 JTF_VARCHAR2_TABLE_100
    , p16_a9 JTF_VARCHAR2_TABLE_300
    , p16_a10 JTF_DATE_TABLE
    , p16_a11 JTF_DATE_TABLE
    , p16_a12 JTF_NUMBER_TABLE
    , p16_a13 JTF_NUMBER_TABLE
    , p16_a14 JTF_VARCHAR2_TABLE_100
    , p16_a15 JTF_VARCHAR2_TABLE_300
    , p16_a16 JTF_VARCHAR2_TABLE_300
    , p16_a17 JTF_VARCHAR2_TABLE_300
    , p16_a18 JTF_VARCHAR2_TABLE_300
    , p16_a19 JTF_VARCHAR2_TABLE_300
    , p16_a20 JTF_VARCHAR2_TABLE_300
    , p16_a21 JTF_VARCHAR2_TABLE_300
    , p16_a22 JTF_VARCHAR2_TABLE_300
    , p16_a23 JTF_VARCHAR2_TABLE_300
    , p16_a24 JTF_VARCHAR2_TABLE_300
    , p16_a25 JTF_VARCHAR2_TABLE_300
    , p16_a26 JTF_VARCHAR2_TABLE_300
    , p16_a27 JTF_VARCHAR2_TABLE_300
    , p16_a28 JTF_VARCHAR2_TABLE_300
    , p16_a29 JTF_VARCHAR2_TABLE_300
    , p16_a30 JTF_VARCHAR2_TABLE_100
    , p16_a31 JTF_NUMBER_TABLE
    , p16_a32 JTF_VARCHAR2_TABLE_100
    , x_qp_list_header_id out nocopy  NUMBER
    , x_error_location out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
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
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  DATE := fnd_api.g_miss_date
    , p7_a44  DATE := fnd_api.g_miss_date
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  DATE := fnd_api.g_miss_date
    , p7_a52  DATE := fnd_api.g_miss_date
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  DATE := fnd_api.g_miss_date
    , p7_a55  DATE := fnd_api.g_miss_date
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  NUMBER := 0-1962.0724
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  NUMBER := 0-1962.0724
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  NUMBER := 0-1962.0724
  )

  as
    ddp_modifier_list_rec ozf_offer_pub.modifier_list_rec_type;
    ddp_modifier_line_tbl ozf_offer_pub.modifier_line_tbl_type;
    ddp_qualifier_tbl ozf_offer_pub.qualifiers_tbl_type;
    ddp_budget_tbl ozf_offer_pub.budget_tbl_type;
    ddp_act_product_tbl ozf_offer_pub.act_product_tbl_type;
    ddp_discount_tbl ozf_offer_pub.discount_line_tbl_type;
    ddp_excl_tbl ozf_offer_pub.excl_rec_tbl_type;
    ddp_offer_tier_tbl ozf_offer_pub.offer_tier_tbl_type;
    ddp_prod_tbl ozf_offer_pub.prod_rec_tbl_type;
    ddp_na_qualifier_tbl ozf_offer_pub.na_qualifier_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_modifier_list_rec.offer_id := rosetta_g_miss_num_map(p7_a0);
    ddp_modifier_list_rec.qp_list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_modifier_list_rec.offer_type := p7_a2;
    ddp_modifier_list_rec.offer_code := p7_a3;
    ddp_modifier_list_rec.activity_media_id := rosetta_g_miss_num_map(p7_a4);
    ddp_modifier_list_rec.reusable := p7_a5;
    ddp_modifier_list_rec.user_status_id := rosetta_g_miss_num_map(p7_a6);
    ddp_modifier_list_rec.owner_id := rosetta_g_miss_num_map(p7_a7);
    ddp_modifier_list_rec.wf_item_key := p7_a8;
    ddp_modifier_list_rec.customer_reference := p7_a9;
    ddp_modifier_list_rec.buying_group_contact_id := rosetta_g_miss_num_map(p7_a10);
    ddp_modifier_list_rec.object_version_number := rosetta_g_miss_num_map(p7_a11);
    ddp_modifier_list_rec.perf_date_from := rosetta_g_miss_date_in_map(p7_a12);
    ddp_modifier_list_rec.perf_date_to := rosetta_g_miss_date_in_map(p7_a13);
    ddp_modifier_list_rec.status_code := p7_a14;
    ddp_modifier_list_rec.status_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_modifier_list_rec.modifier_level_code := p7_a16;
    ddp_modifier_list_rec.order_value_discount_type := p7_a17;
    ddp_modifier_list_rec.lumpsum_amount := rosetta_g_miss_num_map(p7_a18);
    ddp_modifier_list_rec.lumpsum_payment_type := p7_a19;
    ddp_modifier_list_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a20);
    ddp_modifier_list_rec.offer_amount := rosetta_g_miss_num_map(p7_a21);
    ddp_modifier_list_rec.budget_amount_tc := rosetta_g_miss_num_map(p7_a22);
    ddp_modifier_list_rec.budget_amount_fc := rosetta_g_miss_num_map(p7_a23);
    ddp_modifier_list_rec.transaction_currency_code := p7_a24;
    ddp_modifier_list_rec.functional_currency_code := p7_a25;
    ddp_modifier_list_rec.context := p7_a26;
    ddp_modifier_list_rec.attribute1 := p7_a27;
    ddp_modifier_list_rec.attribute2 := p7_a28;
    ddp_modifier_list_rec.attribute3 := p7_a29;
    ddp_modifier_list_rec.attribute4 := p7_a30;
    ddp_modifier_list_rec.attribute5 := p7_a31;
    ddp_modifier_list_rec.attribute6 := p7_a32;
    ddp_modifier_list_rec.attribute7 := p7_a33;
    ddp_modifier_list_rec.attribute8 := p7_a34;
    ddp_modifier_list_rec.attribute9 := p7_a35;
    ddp_modifier_list_rec.attribute10 := p7_a36;
    ddp_modifier_list_rec.attribute11 := p7_a37;
    ddp_modifier_list_rec.attribute12 := p7_a38;
    ddp_modifier_list_rec.attribute13 := p7_a39;
    ddp_modifier_list_rec.attribute14 := p7_a40;
    ddp_modifier_list_rec.attribute15 := p7_a41;
    ddp_modifier_list_rec.currency_code := p7_a42;
    ddp_modifier_list_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a43);
    ddp_modifier_list_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a44);
    ddp_modifier_list_rec.list_type_code := p7_a45;
    ddp_modifier_list_rec.discount_lines_flag := p7_a46;
    ddp_modifier_list_rec.name := p7_a47;
    ddp_modifier_list_rec.description := p7_a48;
    ddp_modifier_list_rec.comments := p7_a49;
    ddp_modifier_list_rec.ask_for_flag := p7_a50;
    ddp_modifier_list_rec.start_date_active_first := rosetta_g_miss_date_in_map(p7_a51);
    ddp_modifier_list_rec.end_date_active_first := rosetta_g_miss_date_in_map(p7_a52);
    ddp_modifier_list_rec.active_date_first_type := p7_a53;
    ddp_modifier_list_rec.start_date_active_second := rosetta_g_miss_date_in_map(p7_a54);
    ddp_modifier_list_rec.end_date_active_second := rosetta_g_miss_date_in_map(p7_a55);
    ddp_modifier_list_rec.active_date_second_type := p7_a56;
    ddp_modifier_list_rec.active_flag := p7_a57;
    ddp_modifier_list_rec.max_no_of_uses := rosetta_g_miss_num_map(p7_a58);
    ddp_modifier_list_rec.budget_source_id := rosetta_g_miss_num_map(p7_a59);
    ddp_modifier_list_rec.budget_source_type := p7_a60;
    ddp_modifier_list_rec.offer_used_by_id := rosetta_g_miss_num_map(p7_a61);
    ddp_modifier_list_rec.offer_used_by := p7_a62;
    ddp_modifier_list_rec.ql_qualifier_type := p7_a63;
    ddp_modifier_list_rec.ql_qualifier_id := rosetta_g_miss_num_map(p7_a64);
    ddp_modifier_list_rec.distribution_type := p7_a65;
    ddp_modifier_list_rec.amount_limit_id := rosetta_g_miss_num_map(p7_a66);
    ddp_modifier_list_rec.uses_limit_id := rosetta_g_miss_num_map(p7_a67);
    ddp_modifier_list_rec.offer_operation := p7_a68;
    ddp_modifier_list_rec.modifier_operation := p7_a69;
    ddp_modifier_list_rec.budget_offer_yn := p7_a70;
    ddp_modifier_list_rec.break_type := p7_a71;
    ddp_modifier_list_rec.retroactive := p7_a72;
    ddp_modifier_list_rec.volume_offer_type := p7_a73;
    ddp_modifier_list_rec.confidential_flag := p7_a74;
    ddp_modifier_list_rec.committed_amount_eq_max := p7_a75;
    ddp_modifier_list_rec.source_from_parent := p7_a76;
    ddp_modifier_list_rec.buyer_name := p7_a77;
    ddp_modifier_list_rec.tier_level := p7_a78;
    ddp_modifier_list_rec.na_rule_header_id := rosetta_g_miss_num_map(p7_a79);
    ddp_modifier_list_rec.sales_method_flag := p7_a80;
    ddp_modifier_list_rec.global_flag := p7_a81;
    ddp_modifier_list_rec.orig_org_id := rosetta_g_miss_num_map(p7_a82);

    ozf_offer_pub_w.rosetta_table_copy_in_p17(ddp_modifier_line_tbl, p8_a0
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
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p19(ddp_qualifier_tbl, p9_a0
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
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p14(ddp_budget_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p2(ddp_act_product_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p4(ddp_discount_tbl, p12_a0
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
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      , p12_a27
      , p12_a28
      , p12_a29
      , p12_a30
      , p12_a31
      , p12_a32
      , p12_a33
      , p12_a34
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p8(ddp_excl_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p10(ddp_offer_tier_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p6(ddp_prod_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      , p15_a12
      , p15_a13
      , p15_a14
      , p15_a15
      , p15_a16
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p12(ddp_na_qualifier_tbl, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      , p16_a5
      , p16_a6
      , p16_a7
      , p16_a8
      , p16_a9
      , p16_a10
      , p16_a11
      , p16_a12
      , p16_a13
      , p16_a14
      , p16_a15
      , p16_a16
      , p16_a17
      , p16_a18
      , p16_a19
      , p16_a20
      , p16_a21
      , p16_a22
      , p16_a23
      , p16_a24
      , p16_a25
      , p16_a26
      , p16_a27
      , p16_a28
      , p16_a29
      , p16_a30
      , p16_a31
      , p16_a32
      );



    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pub.process_modifiers(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_offer_type,
      ddp_modifier_list_rec,
      ddp_modifier_line_tbl,
      ddp_qualifier_tbl,
      ddp_budget_tbl,
      ddp_act_product_tbl,
      ddp_discount_tbl,
      ddp_excl_tbl,
      ddp_offer_tier_tbl,
      ddp_prod_tbl,
      ddp_na_qualifier_tbl,
      x_qp_list_header_id,
      x_error_location);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















  end;

  procedure process_vo(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_VARCHAR2_TABLE_300
    , p7_a18 JTF_VARCHAR2_TABLE_2000
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_100
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_VARCHAR2_TABLE_300
    , p8_a18 JTF_VARCHAR2_TABLE_2000
    , p8_a19 JTF_VARCHAR2_TABLE_100
    , p8_a20 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_300
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_NUMBER_TABLE
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p10_a2 JTF_VARCHAR2_TABLE_300
    , p10_a3 JTF_VARCHAR2_TABLE_300
    , p10_a4 JTF_VARCHAR2_TABLE_100
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_DATE_TABLE
    , p10_a11 JTF_NUMBER_TABLE
    , p10_a12 JTF_VARCHAR2_TABLE_100
    , p10_a13 JTF_VARCHAR2_TABLE_100
    , p10_a14 JTF_VARCHAR2_TABLE_300
    , p10_a15 JTF_VARCHAR2_TABLE_300
    , p10_a16 JTF_VARCHAR2_TABLE_300
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
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_VARCHAR2_TABLE_100
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_VARCHAR2_TABLE_100
    , p11_a7 JTF_VARCHAR2_TABLE_100
    , p11_a8 JTF_VARCHAR2_TABLE_100
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_NUMBER_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_VARCHAR2_TABLE_100
    , x_qp_list_header_id out nocopy  NUMBER
    , x_error_location out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  DATE := fnd_api.g_miss_date
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  DATE := fnd_api.g_miss_date
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  DATE := fnd_api.g_miss_date
    , p6_a44  DATE := fnd_api.g_miss_date
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  DATE := fnd_api.g_miss_date
    , p6_a52  DATE := fnd_api.g_miss_date
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  DATE := fnd_api.g_miss_date
    , p6_a55  DATE := fnd_api.g_miss_date
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  NUMBER := 0-1962.0724
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  NUMBER := 0-1962.0724
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  NUMBER := 0-1962.0724
  )

  as
    ddp_modifier_list_rec ozf_offer_pub.modifier_list_rec_type;
    ddp_vo_pbh_tbl ozf_offer_pub.vo_disc_tbl_type;
    ddp_vo_dis_tbl ozf_offer_pub.vo_disc_tbl_type;
    ddp_vo_prod_tbl ozf_offer_pub.vo_prod_tbl_type;
    ddp_qualifier_tbl ozf_offer_pub.qualifiers_tbl_type;
    ddp_vo_mo_tbl ozf_offer_pub.vo_mo_tbl_type;
    ddp_budget_tbl ozf_offer_pub.budget_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_modifier_list_rec.offer_id := rosetta_g_miss_num_map(p6_a0);
    ddp_modifier_list_rec.qp_list_header_id := rosetta_g_miss_num_map(p6_a1);
    ddp_modifier_list_rec.offer_type := p6_a2;
    ddp_modifier_list_rec.offer_code := p6_a3;
    ddp_modifier_list_rec.activity_media_id := rosetta_g_miss_num_map(p6_a4);
    ddp_modifier_list_rec.reusable := p6_a5;
    ddp_modifier_list_rec.user_status_id := rosetta_g_miss_num_map(p6_a6);
    ddp_modifier_list_rec.owner_id := rosetta_g_miss_num_map(p6_a7);
    ddp_modifier_list_rec.wf_item_key := p6_a8;
    ddp_modifier_list_rec.customer_reference := p6_a9;
    ddp_modifier_list_rec.buying_group_contact_id := rosetta_g_miss_num_map(p6_a10);
    ddp_modifier_list_rec.object_version_number := rosetta_g_miss_num_map(p6_a11);
    ddp_modifier_list_rec.perf_date_from := rosetta_g_miss_date_in_map(p6_a12);
    ddp_modifier_list_rec.perf_date_to := rosetta_g_miss_date_in_map(p6_a13);
    ddp_modifier_list_rec.status_code := p6_a14;
    ddp_modifier_list_rec.status_date := rosetta_g_miss_date_in_map(p6_a15);
    ddp_modifier_list_rec.modifier_level_code := p6_a16;
    ddp_modifier_list_rec.order_value_discount_type := p6_a17;
    ddp_modifier_list_rec.lumpsum_amount := rosetta_g_miss_num_map(p6_a18);
    ddp_modifier_list_rec.lumpsum_payment_type := p6_a19;
    ddp_modifier_list_rec.custom_setup_id := rosetta_g_miss_num_map(p6_a20);
    ddp_modifier_list_rec.offer_amount := rosetta_g_miss_num_map(p6_a21);
    ddp_modifier_list_rec.budget_amount_tc := rosetta_g_miss_num_map(p6_a22);
    ddp_modifier_list_rec.budget_amount_fc := rosetta_g_miss_num_map(p6_a23);
    ddp_modifier_list_rec.transaction_currency_code := p6_a24;
    ddp_modifier_list_rec.functional_currency_code := p6_a25;
    ddp_modifier_list_rec.context := p6_a26;
    ddp_modifier_list_rec.attribute1 := p6_a27;
    ddp_modifier_list_rec.attribute2 := p6_a28;
    ddp_modifier_list_rec.attribute3 := p6_a29;
    ddp_modifier_list_rec.attribute4 := p6_a30;
    ddp_modifier_list_rec.attribute5 := p6_a31;
    ddp_modifier_list_rec.attribute6 := p6_a32;
    ddp_modifier_list_rec.attribute7 := p6_a33;
    ddp_modifier_list_rec.attribute8 := p6_a34;
    ddp_modifier_list_rec.attribute9 := p6_a35;
    ddp_modifier_list_rec.attribute10 := p6_a36;
    ddp_modifier_list_rec.attribute11 := p6_a37;
    ddp_modifier_list_rec.attribute12 := p6_a38;
    ddp_modifier_list_rec.attribute13 := p6_a39;
    ddp_modifier_list_rec.attribute14 := p6_a40;
    ddp_modifier_list_rec.attribute15 := p6_a41;
    ddp_modifier_list_rec.currency_code := p6_a42;
    ddp_modifier_list_rec.start_date_active := rosetta_g_miss_date_in_map(p6_a43);
    ddp_modifier_list_rec.end_date_active := rosetta_g_miss_date_in_map(p6_a44);
    ddp_modifier_list_rec.list_type_code := p6_a45;
    ddp_modifier_list_rec.discount_lines_flag := p6_a46;
    ddp_modifier_list_rec.name := p6_a47;
    ddp_modifier_list_rec.description := p6_a48;
    ddp_modifier_list_rec.comments := p6_a49;
    ddp_modifier_list_rec.ask_for_flag := p6_a50;
    ddp_modifier_list_rec.start_date_active_first := rosetta_g_miss_date_in_map(p6_a51);
    ddp_modifier_list_rec.end_date_active_first := rosetta_g_miss_date_in_map(p6_a52);
    ddp_modifier_list_rec.active_date_first_type := p6_a53;
    ddp_modifier_list_rec.start_date_active_second := rosetta_g_miss_date_in_map(p6_a54);
    ddp_modifier_list_rec.end_date_active_second := rosetta_g_miss_date_in_map(p6_a55);
    ddp_modifier_list_rec.active_date_second_type := p6_a56;
    ddp_modifier_list_rec.active_flag := p6_a57;
    ddp_modifier_list_rec.max_no_of_uses := rosetta_g_miss_num_map(p6_a58);
    ddp_modifier_list_rec.budget_source_id := rosetta_g_miss_num_map(p6_a59);
    ddp_modifier_list_rec.budget_source_type := p6_a60;
    ddp_modifier_list_rec.offer_used_by_id := rosetta_g_miss_num_map(p6_a61);
    ddp_modifier_list_rec.offer_used_by := p6_a62;
    ddp_modifier_list_rec.ql_qualifier_type := p6_a63;
    ddp_modifier_list_rec.ql_qualifier_id := rosetta_g_miss_num_map(p6_a64);
    ddp_modifier_list_rec.distribution_type := p6_a65;
    ddp_modifier_list_rec.amount_limit_id := rosetta_g_miss_num_map(p6_a66);
    ddp_modifier_list_rec.uses_limit_id := rosetta_g_miss_num_map(p6_a67);
    ddp_modifier_list_rec.offer_operation := p6_a68;
    ddp_modifier_list_rec.modifier_operation := p6_a69;
    ddp_modifier_list_rec.budget_offer_yn := p6_a70;
    ddp_modifier_list_rec.break_type := p6_a71;
    ddp_modifier_list_rec.retroactive := p6_a72;
    ddp_modifier_list_rec.volume_offer_type := p6_a73;
    ddp_modifier_list_rec.confidential_flag := p6_a74;
    ddp_modifier_list_rec.committed_amount_eq_max := p6_a75;
    ddp_modifier_list_rec.source_from_parent := p6_a76;
    ddp_modifier_list_rec.buyer_name := p6_a77;
    ddp_modifier_list_rec.tier_level := p6_a78;
    ddp_modifier_list_rec.na_rule_header_id := rosetta_g_miss_num_map(p6_a79);
    ddp_modifier_list_rec.sales_method_flag := p6_a80;
    ddp_modifier_list_rec.global_flag := p6_a81;
    ddp_modifier_list_rec.orig_org_id := rosetta_g_miss_num_map(p6_a82);

    ozf_offer_pub_w.rosetta_table_copy_in_p21(ddp_vo_pbh_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p21(ddp_vo_dis_tbl, p8_a0
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
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p23(ddp_vo_prod_tbl, p9_a0
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
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p19(ddp_qualifier_tbl, p10_a0
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
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p25(ddp_vo_mo_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      );

    ozf_offer_pub_w.rosetta_table_copy_in_p14(ddp_budget_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      );



    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pub.process_vo(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_modifier_list_rec,
      ddp_vo_pbh_tbl,
      ddp_vo_dis_tbl,
      ddp_vo_prod_tbl,
      ddp_qualifier_tbl,
      ddp_vo_mo_tbl,
      ddp_budget_tbl,
      x_qp_list_header_id,
      x_error_location);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

end ozf_offer_pub_w;

/
