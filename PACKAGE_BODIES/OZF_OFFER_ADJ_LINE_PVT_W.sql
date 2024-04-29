--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_LINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_LINE_PVT_W" as
  /* $Header: ozfwoalb.pls 120.1 2005/09/26 17:59 rssharma noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ozf_offer_adj_line_pvt.offadj_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_adjustment_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).offer_adjustment_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).arithmetic_operator := a3(indx);
          t(ddindx).original_discount := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).modified_discount := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).accrual_flag := a13(indx);
          t(ddindx).list_line_id_td := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).original_discount_td := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).modified_discount_td := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).quantity := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).created_from_adjustments := a18(indx);
          t(ddindx).discount_end_date := rosetta_g_miss_date_in_map(a19(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ozf_offer_adj_line_pvt.offadj_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adjustment_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adjustment_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a3(indx) := t(ddindx).arithmetic_operator;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).original_discount);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).modified_discount);
          a6(indx) := t(ddindx).last_update_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).creation_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a13(indx) := t(ddindx).accrual_flag;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id_td);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).original_discount_td);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).modified_discount_td);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a18(indx) := t(ddindx).created_from_adjustments;
          a19(indx) := t(ddindx).discount_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p6(t out nocopy ozf_offer_adj_line_pvt.offadj_new_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
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
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).offer_adjustment_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).offer_adjustment_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).list_line_type_code := a4(indx);
          t(ddindx).operand := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).arithmetic_operator := a6(indx);
          t(ddindx).product_attr := a7(indx);
          t(ddindx).product_attr_val := a8(indx);
          t(ddindx).product_uom_code := a9(indx);
          t(ddindx).pricing_attr := a10(indx);
          t(ddindx).pricing_attr_value_from := a11(indx);
          t(ddindx).pricing_attr_value_to := a12(indx);
          t(ddindx).pricing_attribute_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).order_value_from := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).order_value_to := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).qualifier_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).inactive_flag := a17(indx);
          t(ddindx).max_qty_per_order_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).max_qty_per_customer_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).max_qty_per_rule_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).max_orders_per_customer_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).max_amount_per_rule_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).qd_arithmetic_operator := a23(indx);
          t(ddindx).qd_operand := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).qd_estimated_qty_is_max := a25(indx);
          t(ddindx).qd_estimated_amount_is_max := a26(indx);
          t(ddindx).price_by_formula_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).operation := a28(indx);
          t(ddindx).benefit_price_list_line_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).benefit_uom_code := a30(indx);
          t(ddindx).benefit_qty := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).start_date_active := rosetta_g_miss_date_in_map(a38(indx));
          t(ddindx).end_date_active := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).attribute1 := a40(indx);
          t(ddindx).attribute2 := a41(indx);
          t(ddindx).attribute3 := a42(indx);
          t(ddindx).attribute4 := a43(indx);
          t(ddindx).attribute5 := a44(indx);
          t(ddindx).attribute6 := a45(indx);
          t(ddindx).attribute7 := a46(indx);
          t(ddindx).attribute8 := a47(indx);
          t(ddindx).attribute9 := a48(indx);
          t(ddindx).attribute10 := a49(indx);
          t(ddindx).attribute11 := a50(indx);
          t(ddindx).attribute12 := a51(indx);
          t(ddindx).attribute13 := a52(indx);
          t(ddindx).attribute14 := a53(indx);
          t(ddindx).attribute15 := a54(indx);
          t(ddindx).context := a55(indx);
          t(ddindx).discount_end_date := rosetta_g_miss_date_in_map(a56(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ozf_offer_adj_line_pvt.offadj_new_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
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
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_DATE_TABLE
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
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_DATE_TABLE();
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
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_DATE_TABLE();
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
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adjustment_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).offer_adjustment_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a4(indx) := t(ddindx).list_line_type_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).operand);
          a6(indx) := t(ddindx).arithmetic_operator;
          a7(indx) := t(ddindx).product_attr;
          a8(indx) := t(ddindx).product_attr_val;
          a9(indx) := t(ddindx).product_uom_code;
          a10(indx) := t(ddindx).pricing_attr;
          a11(indx) := t(ddindx).pricing_attr_value_from;
          a12(indx) := t(ddindx).pricing_attr_value_to;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_attribute_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).order_value_from);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).order_value_to);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).qualifier_id);
          a17(indx) := t(ddindx).inactive_flag;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_order_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_customer_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).max_qty_per_rule_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).max_orders_per_customer_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).max_amount_per_rule_id);
          a23(indx) := t(ddindx).qd_arithmetic_operator;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).qd_operand);
          a25(indx) := t(ddindx).qd_estimated_qty_is_max;
          a26(indx) := t(ddindx).qd_estimated_amount_is_max;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).price_by_formula_id);
          a28(indx) := t(ddindx).operation;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_price_list_line_id);
          a30(indx) := t(ddindx).benefit_uom_code;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_qty);
          a32(indx) := t(ddindx).last_update_date;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a34(indx) := t(ddindx).creation_date;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a38(indx) := t(ddindx).start_date_active;
          a39(indx) := t(ddindx).end_date_active;
          a40(indx) := t(ddindx).attribute1;
          a41(indx) := t(ddindx).attribute2;
          a42(indx) := t(ddindx).attribute3;
          a43(indx) := t(ddindx).attribute4;
          a44(indx) := t(ddindx).attribute5;
          a45(indx) := t(ddindx).attribute6;
          a46(indx) := t(ddindx).attribute7;
          a47(indx) := t(ddindx).attribute8;
          a48(indx) := t(ddindx).attribute9;
          a49(indx) := t(ddindx).attribute10;
          a50(indx) := t(ddindx).attribute11;
          a51(indx) := t(ddindx).attribute12;
          a52(indx) := t(ddindx).attribute13;
          a53(indx) := t(ddindx).attribute14;
          a54(indx) := t(ddindx).attribute15;
          a55(indx) := t(ddindx).context;
          a56(indx) := t(ddindx).discount_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_offer_adj_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_offer_adjustment_line_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  DATE := fnd_api.g_miss_date
  )

  as
    ddp_offadj_line_rec ozf_offer_adj_line_pvt.offadj_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_offadj_line_rec.offer_adjustment_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_offadj_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_offadj_line_rec.list_line_id := rosetta_g_miss_num_map(p7_a2);
    ddp_offadj_line_rec.arithmetic_operator := p7_a3;
    ddp_offadj_line_rec.original_discount := rosetta_g_miss_num_map(p7_a4);
    ddp_offadj_line_rec.modified_discount := rosetta_g_miss_num_map(p7_a5);
    ddp_offadj_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_offadj_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a7);
    ddp_offadj_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_offadj_line_rec.created_by := rosetta_g_miss_num_map(p7_a9);
    ddp_offadj_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a10);
    ddp_offadj_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a11);
    ddp_offadj_line_rec.list_header_id := rosetta_g_miss_num_map(p7_a12);
    ddp_offadj_line_rec.accrual_flag := p7_a13;
    ddp_offadj_line_rec.list_line_id_td := rosetta_g_miss_num_map(p7_a14);
    ddp_offadj_line_rec.original_discount_td := rosetta_g_miss_num_map(p7_a15);
    ddp_offadj_line_rec.modified_discount_td := rosetta_g_miss_num_map(p7_a16);
    ddp_offadj_line_rec.quantity := rosetta_g_miss_num_map(p7_a17);
    ddp_offadj_line_rec.created_from_adjustments := p7_a18;
    ddp_offadj_line_rec.discount_end_date := rosetta_g_miss_date_in_map(p7_a19);


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_line_pvt.create_offer_adj_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_offadj_line_rec,
      x_offer_adjustment_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_new_offer_adj_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_offer_adjustment_line_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  DATE := fnd_api.g_miss_date
    , p7_a39  DATE := fnd_api.g_miss_date
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  DATE := fnd_api.g_miss_date
  )

  as
    ddp_list_line_rec ozf_offer_adj_line_pvt.offadj_new_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_line_rec.offer_adjustment_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_list_line_rec.list_header_id := rosetta_g_miss_num_map(p7_a2);
    ddp_list_line_rec.list_line_id := rosetta_g_miss_num_map(p7_a3);
    ddp_list_line_rec.list_line_type_code := p7_a4;
    ddp_list_line_rec.operand := rosetta_g_miss_num_map(p7_a5);
    ddp_list_line_rec.arithmetic_operator := p7_a6;
    ddp_list_line_rec.product_attr := p7_a7;
    ddp_list_line_rec.product_attr_val := p7_a8;
    ddp_list_line_rec.product_uom_code := p7_a9;
    ddp_list_line_rec.pricing_attr := p7_a10;
    ddp_list_line_rec.pricing_attr_value_from := p7_a11;
    ddp_list_line_rec.pricing_attr_value_to := p7_a12;
    ddp_list_line_rec.pricing_attribute_id := rosetta_g_miss_num_map(p7_a13);
    ddp_list_line_rec.order_value_from := rosetta_g_miss_num_map(p7_a14);
    ddp_list_line_rec.order_value_to := rosetta_g_miss_num_map(p7_a15);
    ddp_list_line_rec.qualifier_id := rosetta_g_miss_num_map(p7_a16);
    ddp_list_line_rec.inactive_flag := p7_a17;
    ddp_list_line_rec.max_qty_per_order_id := rosetta_g_miss_num_map(p7_a18);
    ddp_list_line_rec.max_qty_per_customer_id := rosetta_g_miss_num_map(p7_a19);
    ddp_list_line_rec.max_qty_per_rule_id := rosetta_g_miss_num_map(p7_a20);
    ddp_list_line_rec.max_orders_per_customer_id := rosetta_g_miss_num_map(p7_a21);
    ddp_list_line_rec.max_amount_per_rule_id := rosetta_g_miss_num_map(p7_a22);
    ddp_list_line_rec.qd_arithmetic_operator := p7_a23;
    ddp_list_line_rec.qd_operand := rosetta_g_miss_num_map(p7_a24);
    ddp_list_line_rec.qd_estimated_qty_is_max := p7_a25;
    ddp_list_line_rec.qd_estimated_amount_is_max := p7_a26;
    ddp_list_line_rec.price_by_formula_id := rosetta_g_miss_num_map(p7_a27);
    ddp_list_line_rec.operation := p7_a28;
    ddp_list_line_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p7_a29);
    ddp_list_line_rec.benefit_uom_code := p7_a30;
    ddp_list_line_rec.benefit_qty := rosetta_g_miss_num_map(p7_a31);
    ddp_list_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a32);
    ddp_list_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a33);
    ddp_list_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_list_line_rec.created_by := rosetta_g_miss_num_map(p7_a35);
    ddp_list_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a36);
    ddp_list_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a37);
    ddp_list_line_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a38);
    ddp_list_line_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a39);
    ddp_list_line_rec.attribute1 := p7_a40;
    ddp_list_line_rec.attribute2 := p7_a41;
    ddp_list_line_rec.attribute3 := p7_a42;
    ddp_list_line_rec.attribute4 := p7_a43;
    ddp_list_line_rec.attribute5 := p7_a44;
    ddp_list_line_rec.attribute6 := p7_a45;
    ddp_list_line_rec.attribute7 := p7_a46;
    ddp_list_line_rec.attribute8 := p7_a47;
    ddp_list_line_rec.attribute9 := p7_a48;
    ddp_list_line_rec.attribute10 := p7_a49;
    ddp_list_line_rec.attribute11 := p7_a50;
    ddp_list_line_rec.attribute12 := p7_a51;
    ddp_list_line_rec.attribute13 := p7_a52;
    ddp_list_line_rec.attribute14 := p7_a53;
    ddp_list_line_rec.attribute15 := p7_a54;
    ddp_list_line_rec.context := p7_a55;
    ddp_list_line_rec.discount_end_date := rosetta_g_miss_date_in_map(p7_a56);


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_line_pvt.create_new_offer_adj_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_line_rec,
      x_offer_adjustment_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_offer_adj_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  DATE := fnd_api.g_miss_date
  )

  as
    ddp_offadj_line_rec ozf_offer_adj_line_pvt.offadj_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_offadj_line_rec.offer_adjustment_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_offadj_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_offadj_line_rec.list_line_id := rosetta_g_miss_num_map(p7_a2);
    ddp_offadj_line_rec.arithmetic_operator := p7_a3;
    ddp_offadj_line_rec.original_discount := rosetta_g_miss_num_map(p7_a4);
    ddp_offadj_line_rec.modified_discount := rosetta_g_miss_num_map(p7_a5);
    ddp_offadj_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_offadj_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a7);
    ddp_offadj_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_offadj_line_rec.created_by := rosetta_g_miss_num_map(p7_a9);
    ddp_offadj_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a10);
    ddp_offadj_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a11);
    ddp_offadj_line_rec.list_header_id := rosetta_g_miss_num_map(p7_a12);
    ddp_offadj_line_rec.accrual_flag := p7_a13;
    ddp_offadj_line_rec.list_line_id_td := rosetta_g_miss_num_map(p7_a14);
    ddp_offadj_line_rec.original_discount_td := rosetta_g_miss_num_map(p7_a15);
    ddp_offadj_line_rec.modified_discount_td := rosetta_g_miss_num_map(p7_a16);
    ddp_offadj_line_rec.quantity := rosetta_g_miss_num_map(p7_a17);
    ddp_offadj_line_rec.created_from_adjustments := p7_a18;
    ddp_offadj_line_rec.discount_end_date := rosetta_g_miss_date_in_map(p7_a19);


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_line_pvt.update_offer_adj_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_offadj_line_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_new_offer_adj_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  DATE := fnd_api.g_miss_date
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  DATE := fnd_api.g_miss_date
    , p7_a39  DATE := fnd_api.g_miss_date
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  DATE := fnd_api.g_miss_date
  )

  as
    ddp_list_line_rec ozf_offer_adj_line_pvt.offadj_new_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin
ozf_utility_pvt.debug_message('EndDateActive in Rosetta:'||p7_a56);
    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_line_rec.offer_adjustment_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_list_line_rec.list_header_id := rosetta_g_miss_num_map(p7_a2);
    ddp_list_line_rec.list_line_id := rosetta_g_miss_num_map(p7_a3);
    ddp_list_line_rec.list_line_type_code := p7_a4;
    ddp_list_line_rec.operand := rosetta_g_miss_num_map(p7_a5);
    ddp_list_line_rec.arithmetic_operator := p7_a6;
    ddp_list_line_rec.product_attr := p7_a7;
    ddp_list_line_rec.product_attr_val := p7_a8;
    ddp_list_line_rec.product_uom_code := p7_a9;
    ddp_list_line_rec.pricing_attr := p7_a10;
    ddp_list_line_rec.pricing_attr_value_from := p7_a11;
    ddp_list_line_rec.pricing_attr_value_to := p7_a12;
    ddp_list_line_rec.pricing_attribute_id := rosetta_g_miss_num_map(p7_a13);
    ddp_list_line_rec.order_value_from := rosetta_g_miss_num_map(p7_a14);
    ddp_list_line_rec.order_value_to := rosetta_g_miss_num_map(p7_a15);
    ddp_list_line_rec.qualifier_id := rosetta_g_miss_num_map(p7_a16);
    ddp_list_line_rec.inactive_flag := p7_a17;
    ddp_list_line_rec.max_qty_per_order_id := rosetta_g_miss_num_map(p7_a18);
    ddp_list_line_rec.max_qty_per_customer_id := rosetta_g_miss_num_map(p7_a19);
    ddp_list_line_rec.max_qty_per_rule_id := rosetta_g_miss_num_map(p7_a20);
    ddp_list_line_rec.max_orders_per_customer_id := rosetta_g_miss_num_map(p7_a21);
    ddp_list_line_rec.max_amount_per_rule_id := rosetta_g_miss_num_map(p7_a22);
    ddp_list_line_rec.qd_arithmetic_operator := p7_a23;
    ddp_list_line_rec.qd_operand := rosetta_g_miss_num_map(p7_a24);
    ddp_list_line_rec.qd_estimated_qty_is_max := p7_a25;
    ddp_list_line_rec.qd_estimated_amount_is_max := p7_a26;
    ddp_list_line_rec.price_by_formula_id := rosetta_g_miss_num_map(p7_a27);
    ddp_list_line_rec.operation := p7_a28;
    ddp_list_line_rec.benefit_price_list_line_id := rosetta_g_miss_num_map(p7_a29);
    ddp_list_line_rec.benefit_uom_code := p7_a30;
    ddp_list_line_rec.benefit_qty := rosetta_g_miss_num_map(p7_a31);
    ddp_list_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a32);
    ddp_list_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a33);
    ddp_list_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_list_line_rec.created_by := rosetta_g_miss_num_map(p7_a35);
    ddp_list_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a36);
    ddp_list_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a37);
    ddp_list_line_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a38);
    ddp_list_line_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a39);
    ddp_list_line_rec.attribute1 := p7_a40;
    ddp_list_line_rec.attribute2 := p7_a41;
    ddp_list_line_rec.attribute3 := p7_a42;
    ddp_list_line_rec.attribute4 := p7_a43;
    ddp_list_line_rec.attribute5 := p7_a44;
    ddp_list_line_rec.attribute6 := p7_a45;
    ddp_list_line_rec.attribute7 := p7_a46;
    ddp_list_line_rec.attribute8 := p7_a47;
    ddp_list_line_rec.attribute9 := p7_a48;
    ddp_list_line_rec.attribute10 := p7_a49;
    ddp_list_line_rec.attribute11 := p7_a50;
    ddp_list_line_rec.attribute12 := p7_a51;
    ddp_list_line_rec.attribute13 := p7_a52;
    ddp_list_line_rec.attribute14 := p7_a53;
    ddp_list_line_rec.attribute15 := p7_a54;
    ddp_list_line_rec.context := p7_a55;
    ddp_list_line_rec.discount_end_date := rosetta_g_miss_date_in_map(p7_a56);


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_line_pvt.update_new_offer_adj_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_line_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_offer_adj_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  DATE := fnd_api.g_miss_date
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  DATE := fnd_api.g_miss_date
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  NUMBER := 0-1962.0724
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  DATE := fnd_api.g_miss_date
  )

  as
    ddp_offadj_line_rec ozf_offer_adj_line_pvt.offadj_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_offadj_line_rec.offer_adjustment_line_id := rosetta_g_miss_num_map(p3_a0);
    ddp_offadj_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p3_a1);
    ddp_offadj_line_rec.list_line_id := rosetta_g_miss_num_map(p3_a2);
    ddp_offadj_line_rec.arithmetic_operator := p3_a3;
    ddp_offadj_line_rec.original_discount := rosetta_g_miss_num_map(p3_a4);
    ddp_offadj_line_rec.modified_discount := rosetta_g_miss_num_map(p3_a5);
    ddp_offadj_line_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_offadj_line_rec.last_updated_by := rosetta_g_miss_num_map(p3_a7);
    ddp_offadj_line_rec.creation_date := rosetta_g_miss_date_in_map(p3_a8);
    ddp_offadj_line_rec.created_by := rosetta_g_miss_num_map(p3_a9);
    ddp_offadj_line_rec.last_update_login := rosetta_g_miss_num_map(p3_a10);
    ddp_offadj_line_rec.object_version_number := rosetta_g_miss_num_map(p3_a11);
    ddp_offadj_line_rec.list_header_id := rosetta_g_miss_num_map(p3_a12);
    ddp_offadj_line_rec.accrual_flag := p3_a13;
    ddp_offadj_line_rec.list_line_id_td := rosetta_g_miss_num_map(p3_a14);
    ddp_offadj_line_rec.original_discount_td := rosetta_g_miss_num_map(p3_a15);
    ddp_offadj_line_rec.modified_discount_td := rosetta_g_miss_num_map(p3_a16);
    ddp_offadj_line_rec.quantity := rosetta_g_miss_num_map(p3_a17);
    ddp_offadj_line_rec.created_from_adjustments := p3_a18;
    ddp_offadj_line_rec.discount_end_date := rosetta_g_miss_date_in_map(p3_a19);





    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_line_pvt.validate_offer_adj_line(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_offadj_line_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_offadj_line_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  DATE := fnd_api.g_miss_date
  )

  as
    ddp_offadj_line_rec ozf_offer_adj_line_pvt.offadj_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_offadj_line_rec.offer_adjustment_line_id := rosetta_g_miss_num_map(p0_a0);
    ddp_offadj_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p0_a1);
    ddp_offadj_line_rec.list_line_id := rosetta_g_miss_num_map(p0_a2);
    ddp_offadj_line_rec.arithmetic_operator := p0_a3;
    ddp_offadj_line_rec.original_discount := rosetta_g_miss_num_map(p0_a4);
    ddp_offadj_line_rec.modified_discount := rosetta_g_miss_num_map(p0_a5);
    ddp_offadj_line_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_offadj_line_rec.last_updated_by := rosetta_g_miss_num_map(p0_a7);
    ddp_offadj_line_rec.creation_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_offadj_line_rec.created_by := rosetta_g_miss_num_map(p0_a9);
    ddp_offadj_line_rec.last_update_login := rosetta_g_miss_num_map(p0_a10);
    ddp_offadj_line_rec.object_version_number := rosetta_g_miss_num_map(p0_a11);
    ddp_offadj_line_rec.list_header_id := rosetta_g_miss_num_map(p0_a12);
    ddp_offadj_line_rec.accrual_flag := p0_a13;
    ddp_offadj_line_rec.list_line_id_td := rosetta_g_miss_num_map(p0_a14);
    ddp_offadj_line_rec.original_discount_td := rosetta_g_miss_num_map(p0_a15);
    ddp_offadj_line_rec.modified_discount_td := rosetta_g_miss_num_map(p0_a16);
    ddp_offadj_line_rec.quantity := rosetta_g_miss_num_map(p0_a17);
    ddp_offadj_line_rec.created_from_adjustments := p0_a18;
    ddp_offadj_line_rec.discount_end_date := rosetta_g_miss_date_in_map(p0_a19);



    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_line_pvt.check_offadj_line_items(ddp_offadj_line_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_offadj_line_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
  )

  as
    ddp_offadj_line_rec ozf_offer_adj_line_pvt.offadj_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_offadj_line_rec.offer_adjustment_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_offadj_line_rec.offer_adjustment_id := rosetta_g_miss_num_map(p5_a1);
    ddp_offadj_line_rec.list_line_id := rosetta_g_miss_num_map(p5_a2);
    ddp_offadj_line_rec.arithmetic_operator := p5_a3;
    ddp_offadj_line_rec.original_discount := rosetta_g_miss_num_map(p5_a4);
    ddp_offadj_line_rec.modified_discount := rosetta_g_miss_num_map(p5_a5);
    ddp_offadj_line_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_offadj_line_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_offadj_line_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_offadj_line_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_offadj_line_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);
    ddp_offadj_line_rec.object_version_number := rosetta_g_miss_num_map(p5_a11);
    ddp_offadj_line_rec.list_header_id := rosetta_g_miss_num_map(p5_a12);
    ddp_offadj_line_rec.accrual_flag := p5_a13;
    ddp_offadj_line_rec.list_line_id_td := rosetta_g_miss_num_map(p5_a14);
    ddp_offadj_line_rec.original_discount_td := rosetta_g_miss_num_map(p5_a15);
    ddp_offadj_line_rec.modified_discount_td := rosetta_g_miss_num_map(p5_a16);
    ddp_offadj_line_rec.quantity := rosetta_g_miss_num_map(p5_a17);
    ddp_offadj_line_rec.created_from_adjustments := p5_a18;
    ddp_offadj_line_rec.discount_end_date := rosetta_g_miss_date_in_map(p5_a19);

    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_line_pvt.validate_offadj_line_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_offadj_line_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ozf_offer_adj_line_pvt_w;

/
