--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_PVT_OA" as
  /* $Header: ozfaofub.pls 120.2 2006/07/20 12:01:28 mgudivak ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ozf_offer_pvt.modifier_line_tbl_type, a0 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).list_line_id := a2(indx);
          t(ddindx).list_header_id := a3(indx);
          t(ddindx).list_line_type_code := a4(indx);
          t(ddindx).operand := a5(indx);
          t(ddindx).start_date_active := a6(indx);
          t(ddindx).end_date_active := a7(indx);
          t(ddindx).arithmetic_operator := a8(indx);
          t(ddindx).inactive_flag := a9(indx);
          t(ddindx).qd_operand := a10(indx);
          t(ddindx).qd_arithmetic_operator := a11(indx);
          t(ddindx).qd_related_deal_lines_id := a12(indx);
          t(ddindx).qd_object_version_number := a13(indx);
          t(ddindx).qd_estimated_qty_is_max := a14(indx);
          t(ddindx).qd_list_line_id := a15(indx);
          t(ddindx).qd_estimated_amount_is_max := a16(indx);
          t(ddindx).estim_gl_value := a17(indx);
          t(ddindx).benefit_price_list_line_id := a18(indx);
          t(ddindx).benefit_limit := a19(indx);
          t(ddindx).benefit_qty := a20(indx);
          t(ddindx).benefit_uom_code := a21(indx);
          t(ddindx).substitution_context := a22(indx);
          t(ddindx).substitution_attr := a23(indx);
          t(ddindx).substitution_val := a24(indx);
          t(ddindx).price_break_type_code := a25(indx);
          t(ddindx).pricing_attribute_id := a26(indx);
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
          t(ddindx).qualifier_id := a38(indx);
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
          t(ddindx).max_qty_per_order := a56(indx);
          t(ddindx).max_qty_per_order_id := a57(indx);
          t(ddindx).max_qty_per_customer := a58(indx);
          t(ddindx).max_qty_per_customer_id := a59(indx);
          t(ddindx).max_qty_per_rule := a60(indx);
          t(ddindx).max_qty_per_rule_id := a61(indx);
          t(ddindx).max_orders_per_customer := a62(indx);
          t(ddindx).max_orders_per_customer_id := a63(indx);
          t(ddindx).max_amount_per_rule := a64(indx);
          t(ddindx).max_amount_per_rule_id := a65(indx);
          t(ddindx).estimate_qty_uom := a66(indx);
          t(ddindx).generate_using_formula_id := a67(indx);
          t(ddindx).price_by_formula_id := a68(indx);
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ozf_offer_pvt.modifier_line_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
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
          a2(indx) := t(ddindx).list_line_id;
          a3(indx) := t(ddindx).list_header_id;
          a4(indx) := t(ddindx).list_line_type_code;
          a5(indx) := t(ddindx).operand;
          a6(indx) := t(ddindx).start_date_active;
          a7(indx) := t(ddindx).end_date_active;
          a8(indx) := t(ddindx).arithmetic_operator;
          a9(indx) := t(ddindx).inactive_flag;
          a10(indx) := t(ddindx).qd_operand;
          a11(indx) := t(ddindx).qd_arithmetic_operator;
          a12(indx) := t(ddindx).qd_related_deal_lines_id;
          a13(indx) := t(ddindx).qd_object_version_number;
          a14(indx) := t(ddindx).qd_estimated_qty_is_max;
          a15(indx) := t(ddindx).qd_list_line_id;
          a16(indx) := t(ddindx).qd_estimated_amount_is_max;
          a17(indx) := t(ddindx).estim_gl_value;
          a18(indx) := t(ddindx).benefit_price_list_line_id;
          a19(indx) := t(ddindx).benefit_limit;
          a20(indx) := t(ddindx).benefit_qty;
          a21(indx) := t(ddindx).benefit_uom_code;
          a22(indx) := t(ddindx).substitution_context;
          a23(indx) := t(ddindx).substitution_attr;
          a24(indx) := t(ddindx).substitution_val;
          a25(indx) := t(ddindx).price_break_type_code;
          a26(indx) := t(ddindx).pricing_attribute_id;
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
          a38(indx) := t(ddindx).qualifier_id;
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
          a56(indx) := t(ddindx).max_qty_per_order;
          a57(indx) := t(ddindx).max_qty_per_order_id;
          a58(indx) := t(ddindx).max_qty_per_customer;
          a59(indx) := t(ddindx).max_qty_per_customer_id;
          a60(indx) := t(ddindx).max_qty_per_rule;
          a61(indx) := t(ddindx).max_qty_per_rule_id;
          a62(indx) := t(ddindx).max_orders_per_customer;
          a63(indx) := t(ddindx).max_orders_per_customer_id;
          a64(indx) := t(ddindx).max_amount_per_rule;
          a65(indx) := t(ddindx).max_amount_per_rule_id;
          a66(indx) := t(ddindx).estimate_qty_uom;
          a67(indx) := t(ddindx).generate_using_formula_id;
          a68(indx) := t(ddindx).price_by_formula_id;
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy ozf_offer_pvt.pricing_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
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
          t(ddindx).list_line_id := a0(indx);
          t(ddindx).excluder_flag := a1(indx);
          t(ddindx).pricing_attribute_id := a2(indx);
          t(ddindx).product_attribute_context := a3(indx);
          t(ddindx).product_attribute := a4(indx);
          t(ddindx).product_attr_value := a5(indx);
          t(ddindx).product_uom_code := a6(indx);
          t(ddindx).pricing_attribute_context := a7(indx);
          t(ddindx).pricing_attribute := a8(indx);
          t(ddindx).pricing_attr_value_from := a9(indx);
          t(ddindx).pricing_attr_value_to := a10(indx);
          t(ddindx).modifiers_index := a11(indx);
          t(ddindx).operation := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ozf_offer_pvt.pricing_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := t(ddindx).list_line_id;
          a1(indx) := t(ddindx).excluder_flag;
          a2(indx) := t(ddindx).pricing_attribute_id;
          a3(indx) := t(ddindx).product_attribute_context;
          a4(indx) := t(ddindx).product_attribute;
          a5(indx) := t(ddindx).product_attr_value;
          a6(indx) := t(ddindx).product_uom_code;
          a7(indx) := t(ddindx).pricing_attribute_context;
          a8(indx) := t(ddindx).pricing_attribute;
          a9(indx) := t(ddindx).pricing_attr_value_from;
          a10(indx) := t(ddindx).pricing_attr_value_to;
          a11(indx) := t(ddindx).modifiers_index;
          a12(indx) := t(ddindx).operation;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy ozf_offer_pvt.qualifiers_tbl_type, a0 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).qualifier_grouping_no := a5(indx);
          t(ddindx).list_line_id := a6(indx);
          t(ddindx).list_header_id := a7(indx);
          t(ddindx).qualifier_id := a8(indx);
          t(ddindx).start_date_active := a9(indx);
          t(ddindx).end_date_active := a10(indx);
          t(ddindx).activity_market_segment_id := a11(indx);
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
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ozf_offer_pvt.qualifiers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
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
          a5(indx) := t(ddindx).qualifier_grouping_no;
          a6(indx) := t(ddindx).list_line_id;
          a7(indx) := t(ddindx).list_header_id;
          a8(indx) := t(ddindx).qualifier_id;
          a9(indx) := t(ddindx).start_date_active;
          a10(indx) := t(ddindx).end_date_active;
          a11(indx) := t(ddindx).activity_market_segment_id;
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
  end rosetta_table_copy_out_p6;

  procedure process_modifiers(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_offer_type  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  DATE
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  DATE
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  DATE
    , p7_a52  DATE
    , p7_a53  VARCHAR2
    , p7_a54  DATE
    , p7_a55  DATE
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  NUMBER
    , p7_a65  VARCHAR2
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  NUMBER
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  NUMBER
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
    , x_qp_list_header_id out nocopy  NUMBER
    , x_error_location out nocopy  NUMBER
  )

  as
    ddp_modifier_list_rec ozf_offer_pvt.modifier_list_rec_type;
    ddp_modifier_line_tbl ozf_offer_pvt.modifier_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_modifier_list_rec.offer_id := p7_a0;
    ddp_modifier_list_rec.qp_list_header_id := p7_a1;
    ddp_modifier_list_rec.offer_type := p7_a2;
    ddp_modifier_list_rec.offer_code := p7_a3;
    ddp_modifier_list_rec.activity_media_id := p7_a4;
    ddp_modifier_list_rec.reusable := p7_a5;
    ddp_modifier_list_rec.user_status_id := p7_a6;
    ddp_modifier_list_rec.owner_id := p7_a7;
    ddp_modifier_list_rec.wf_item_key := p7_a8;
    ddp_modifier_list_rec.customer_reference := p7_a9;
    ddp_modifier_list_rec.buying_group_contact_id := p7_a10;
    ddp_modifier_list_rec.object_version_number := p7_a11;
    ddp_modifier_list_rec.perf_date_from := p7_a12;
    ddp_modifier_list_rec.perf_date_to := p7_a13;
    ddp_modifier_list_rec.status_code := p7_a14;
    ddp_modifier_list_rec.status_date := p7_a15;
    ddp_modifier_list_rec.modifier_level_code := p7_a16;
    ddp_modifier_list_rec.order_value_discount_type := p7_a17;
    ddp_modifier_list_rec.lumpsum_amount := p7_a18;
    ddp_modifier_list_rec.lumpsum_payment_type := p7_a19;
    ddp_modifier_list_rec.custom_setup_id := p7_a20;
    ddp_modifier_list_rec.offer_amount := p7_a21;
    ddp_modifier_list_rec.budget_amount_tc := p7_a22;
    ddp_modifier_list_rec.budget_amount_fc := p7_a23;
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
    ddp_modifier_list_rec.start_date_active := p7_a43;
    ddp_modifier_list_rec.end_date_active := p7_a44;
    ddp_modifier_list_rec.list_type_code := p7_a45;
    ddp_modifier_list_rec.discount_lines_flag := p7_a46;
    ddp_modifier_list_rec.name := p7_a47;
    ddp_modifier_list_rec.description := p7_a48;
    ddp_modifier_list_rec.comments := p7_a49;
    ddp_modifier_list_rec.ask_for_flag := p7_a50;
    ddp_modifier_list_rec.start_date_active_first := p7_a51;
    ddp_modifier_list_rec.end_date_active_first := p7_a52;
    ddp_modifier_list_rec.active_date_first_type := p7_a53;
    ddp_modifier_list_rec.start_date_active_second := p7_a54;
    ddp_modifier_list_rec.end_date_active_second := p7_a55;
    ddp_modifier_list_rec.active_date_second_type := p7_a56;
    ddp_modifier_list_rec.active_flag := p7_a57;
    ddp_modifier_list_rec.max_no_of_uses := p7_a58;
    ddp_modifier_list_rec.budget_source_id := p7_a59;
    ddp_modifier_list_rec.budget_source_type := p7_a60;
    ddp_modifier_list_rec.offer_used_by_id := p7_a61;
    ddp_modifier_list_rec.offer_used_by := p7_a62;
    ddp_modifier_list_rec.ql_qualifier_type := p7_a63;
    ddp_modifier_list_rec.ql_qualifier_id := p7_a64;
    ddp_modifier_list_rec.distribution_type := p7_a65;
    ddp_modifier_list_rec.amount_limit_id := p7_a66;
    ddp_modifier_list_rec.uses_limit_id := p7_a67;
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
    ddp_modifier_list_rec.na_rule_header_id := p7_a79;
    ddp_modifier_list_rec.sales_method_flag := p7_a80;
    ddp_modifier_list_rec.global_flag := p7_a81;
    ddp_modifier_list_rec.orig_org_id := p7_a82;

    ozf_offer_pvt_oa.rosetta_table_copy_in_p2(ddp_modifier_line_tbl, p8_a0
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



    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pvt.process_modifiers(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_offer_type,
      ddp_modifier_list_rec,
      ddp_modifier_line_tbl,
      x_qp_list_header_id,
      x_error_location);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;
/*
  procedure create_offer_tiers(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_DATE_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_VARCHAR2_TABLE_100
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_VARCHAR2_TABLE_300
    , p6_a25 JTF_VARCHAR2_TABLE_100
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_VARCHAR2_TABLE_100
    , p6_a29 JTF_VARCHAR2_TABLE_300
    , p6_a30 JTF_VARCHAR2_TABLE_100
    , p6_a31 JTF_VARCHAR2_TABLE_100
    , p6_a32 JTF_VARCHAR2_TABLE_100
    , p6_a33 JTF_VARCHAR2_TABLE_300
    , p6_a34 JTF_VARCHAR2_TABLE_300
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_VARCHAR2_TABLE_300
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_VARCHAR2_TABLE_2000
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_300
    , p6_a42 JTF_VARCHAR2_TABLE_300
    , p6_a43 JTF_VARCHAR2_TABLE_300
    , p6_a44 JTF_VARCHAR2_TABLE_300
    , p6_a45 JTF_VARCHAR2_TABLE_300
    , p6_a46 JTF_VARCHAR2_TABLE_300
    , p6_a47 JTF_VARCHAR2_TABLE_300
    , p6_a48 JTF_VARCHAR2_TABLE_300
    , p6_a49 JTF_VARCHAR2_TABLE_300
    , p6_a50 JTF_VARCHAR2_TABLE_300
    , p6_a51 JTF_VARCHAR2_TABLE_300
    , p6_a52 JTF_VARCHAR2_TABLE_300
    , p6_a53 JTF_VARCHAR2_TABLE_300
    , p6_a54 JTF_VARCHAR2_TABLE_300
    , p6_a55 JTF_VARCHAR2_TABLE_300
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_NUMBER_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_NUMBER_TABLE
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_NUMBER_TABLE
    , p6_a63 JTF_NUMBER_TABLE
    , p6_a64 JTF_NUMBER_TABLE
    , p6_a65 JTF_NUMBER_TABLE
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_NUMBER_TABLE
    , p6_a68 JTF_NUMBER_TABLE
    , p6_a69 JTF_VARCHAR2_TABLE_300
    , p6_a70 JTF_VARCHAR2_TABLE_300
    , x_error_location out nocopy  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_DATE_TABLE
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_DATE_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_DATE_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a32 out nocopy JTF_NUMBER_TABLE
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_NUMBER_TABLE
    , p8_a35 out nocopy JTF_NUMBER_TABLE
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_DATE_TABLE
    , p8_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a52 out nocopy JTF_DATE_TABLE
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a54 out nocopy JTF_DATE_TABLE
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a59 out nocopy JTF_NUMBER_TABLE
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a62 out nocopy JTF_NUMBER_TABLE
    , p8_a63 out nocopy JTF_NUMBER_TABLE
    , p8_a64 out nocopy JTF_NUMBER_TABLE
    , p8_a65 out nocopy JTF_NUMBER_TABLE
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a67 out nocopy JTF_NUMBER_TABLE
    , p8_a68 out nocopy JTF_NUMBER_TABLE
    , p8_a69 out nocopy JTF_DATE_TABLE
    , p8_a70 out nocopy JTF_NUMBER_TABLE
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a72 out nocopy JTF_DATE_TABLE
    , p8_a73 out nocopy JTF_NUMBER_TABLE
    , p8_a74 out nocopy JTF_NUMBER_TABLE
    , p8_a75 out nocopy JTF_NUMBER_TABLE
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a78 out nocopy JTF_NUMBER_TABLE
    , p8_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a80 out nocopy JTF_NUMBER_TABLE
    , p8_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a83 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a86 out nocopy JTF_NUMBER_TABLE
    , p8_a87 out nocopy JTF_NUMBER_TABLE
    , p8_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_modifier_line_tbl ozf_offer_pvt.modifier_line_tbl_type;
    ddx_modifiers_tbl qp_modifiers_pub.modifiers_tbl_type;
    ddx_pricing_attr_tbl qp_modifiers_pub.pricing_attr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ozf_offer_pvt_oa.rosetta_table_copy_in_p2(ddp_modifier_line_tbl, p6_a0
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
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pvt.create_offer_tiers(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_modifier_line_tbl,
      x_error_location,
      ddx_modifiers_tbl,
      ddx_pricing_attr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    qp_modifiers_pub_oa.rosetta_table_copy_out_p3(ddx_modifiers_tbl, p8_a0
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
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      );

    qp_modifiers_pub_oa.rosetta_table_copy_out_p1(ddx_pricing_attr_tbl, p9_a0
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
      );
  end;
*/
  procedure process_market_qualifiers(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_VARCHAR2_TABLE_300
    , p6_a3 JTF_VARCHAR2_TABLE_300
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_300
    , p6_a15 JTF_VARCHAR2_TABLE_300
    , p6_a16 JTF_VARCHAR2_TABLE_300
    , p6_a17 JTF_VARCHAR2_TABLE_300
    , p6_a18 JTF_VARCHAR2_TABLE_300
    , p6_a19 JTF_VARCHAR2_TABLE_300
    , p6_a20 JTF_VARCHAR2_TABLE_300
    , p6_a21 JTF_VARCHAR2_TABLE_300
    , p6_a22 JTF_VARCHAR2_TABLE_300
    , p6_a23 JTF_VARCHAR2_TABLE_300
    , p6_a24 JTF_VARCHAR2_TABLE_300
    , p6_a25 JTF_VARCHAR2_TABLE_300
    , p6_a26 JTF_VARCHAR2_TABLE_300
    , p6_a27 JTF_VARCHAR2_TABLE_300
    , p6_a28 JTF_VARCHAR2_TABLE_300
    , x_error_location out nocopy  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_DATE_TABLE
    , p8_a20 out nocopy JTF_DATE_TABLE
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_DATE_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_DATE_TABLE
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a35 out nocopy JTF_NUMBER_TABLE
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_NUMBER_TABLE
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_NUMBER_TABLE
    , p8_a40 out nocopy JTF_DATE_TABLE
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_NUMBER_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qualifiers_tbl ozf_offer_pvt.qualifiers_tbl_type;
    ddx_qualifiers_tbl qp_qualifier_rules_pub.qualifiers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ozf_offer_pvt_oa.rosetta_table_copy_in_p6(ddp_qualifiers_tbl, p6_a0
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
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      );



    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pvt.process_market_qualifiers(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qualifiers_tbl,
      x_error_location,
      ddx_qualifiers_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    qp_qualifier_rules_pub_oa.rosetta_table_copy_out_p1(ddx_qualifiers_tbl, p8_a0
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
      );
  end;

  procedure process_exclusions(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_300
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_300
    , p6_a10 JTF_VARCHAR2_TABLE_300
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , x_error_location out nocopy  NUMBER
  )

  as
    ddp_pricing_attr_tbl ozf_offer_pvt.pricing_attr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ozf_offer_pvt_oa.rosetta_table_copy_in_p4(ddp_pricing_attr_tbl, p6_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pvt.process_exclusions(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pricing_attr_tbl,
      x_error_location);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure process_adv_options(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  NUMBER
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  NUMBER
  )

  as
    ddp_advanced_options_rec ozf_offer_pvt.advanced_option_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_advanced_options_rec.list_line_id := p6_a0;
    ddp_advanced_options_rec.list_header_id := p6_a1;
    ddp_advanced_options_rec.offer_type := p6_a2;
    ddp_advanced_options_rec.modifier_level_code := p6_a3;
    ddp_advanced_options_rec.pricing_phase_id := p6_a4;
    ddp_advanced_options_rec.incompatibility_grp_code := p6_a5;
    ddp_advanced_options_rec.product_precedence := p6_a6;
    ddp_advanced_options_rec.pricing_group_sequence := p6_a7;
    ddp_advanced_options_rec.print_on_invoice_flag := p6_a8;
    ddp_advanced_options_rec.autopay_flag := p6_a9;
    ddp_advanced_options_rec.autopay_days := p6_a10;
    ddp_advanced_options_rec.autopay_method := p6_a11;
    ddp_advanced_options_rec.autopay_party_attr := p6_a12;
    ddp_advanced_options_rec.autopay_party_id := p6_a13;

    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pvt.process_adv_options(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_advanced_options_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure activate_offer_over(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_called_from  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  DATE
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  DATE
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  DATE
    , p7_a52  DATE
    , p7_a53  VARCHAR2
    , p7_a54  DATE
    , p7_a55  DATE
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  NUMBER
    , p7_a65  VARCHAR2
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  NUMBER
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  NUMBER
    , x_amount_error out nocopy  VARCHAR2
  )

  as
    ddp_offer_rec ozf_offer_pvt.modifier_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_offer_rec.offer_id := p7_a0;
    ddp_offer_rec.qp_list_header_id := p7_a1;
    ddp_offer_rec.offer_type := p7_a2;
    ddp_offer_rec.offer_code := p7_a3;
    ddp_offer_rec.activity_media_id := p7_a4;
    ddp_offer_rec.reusable := p7_a5;
    ddp_offer_rec.user_status_id := p7_a6;
    ddp_offer_rec.owner_id := p7_a7;
    ddp_offer_rec.wf_item_key := p7_a8;
    ddp_offer_rec.customer_reference := p7_a9;
    ddp_offer_rec.buying_group_contact_id := p7_a10;
    ddp_offer_rec.object_version_number := p7_a11;
    ddp_offer_rec.perf_date_from := p7_a12;
    ddp_offer_rec.perf_date_to := p7_a13;
    ddp_offer_rec.status_code := p7_a14;
    ddp_offer_rec.status_date := p7_a15;
    ddp_offer_rec.modifier_level_code := p7_a16;
    ddp_offer_rec.order_value_discount_type := p7_a17;
    ddp_offer_rec.lumpsum_amount := p7_a18;
    ddp_offer_rec.lumpsum_payment_type := p7_a19;
    ddp_offer_rec.custom_setup_id := p7_a20;
    ddp_offer_rec.offer_amount := p7_a21;
    ddp_offer_rec.budget_amount_tc := p7_a22;
    ddp_offer_rec.budget_amount_fc := p7_a23;
    ddp_offer_rec.transaction_currency_code := p7_a24;
    ddp_offer_rec.functional_currency_code := p7_a25;
    ddp_offer_rec.context := p7_a26;
    ddp_offer_rec.attribute1 := p7_a27;
    ddp_offer_rec.attribute2 := p7_a28;
    ddp_offer_rec.attribute3 := p7_a29;
    ddp_offer_rec.attribute4 := p7_a30;
    ddp_offer_rec.attribute5 := p7_a31;
    ddp_offer_rec.attribute6 := p7_a32;
    ddp_offer_rec.attribute7 := p7_a33;
    ddp_offer_rec.attribute8 := p7_a34;
    ddp_offer_rec.attribute9 := p7_a35;
    ddp_offer_rec.attribute10 := p7_a36;
    ddp_offer_rec.attribute11 := p7_a37;
    ddp_offer_rec.attribute12 := p7_a38;
    ddp_offer_rec.attribute13 := p7_a39;
    ddp_offer_rec.attribute14 := p7_a40;
    ddp_offer_rec.attribute15 := p7_a41;
    ddp_offer_rec.currency_code := p7_a42;
    ddp_offer_rec.start_date_active := p7_a43;
    ddp_offer_rec.end_date_active := p7_a44;
    ddp_offer_rec.list_type_code := p7_a45;
    ddp_offer_rec.discount_lines_flag := p7_a46;
    ddp_offer_rec.name := p7_a47;
    ddp_offer_rec.description := p7_a48;
    ddp_offer_rec.comments := p7_a49;
    ddp_offer_rec.ask_for_flag := p7_a50;
    ddp_offer_rec.start_date_active_first := p7_a51;
    ddp_offer_rec.end_date_active_first := p7_a52;
    ddp_offer_rec.active_date_first_type := p7_a53;
    ddp_offer_rec.start_date_active_second := p7_a54;
    ddp_offer_rec.end_date_active_second := p7_a55;
    ddp_offer_rec.active_date_second_type := p7_a56;
    ddp_offer_rec.active_flag := p7_a57;
    ddp_offer_rec.max_no_of_uses := p7_a58;
    ddp_offer_rec.budget_source_id := p7_a59;
    ddp_offer_rec.budget_source_type := p7_a60;
    ddp_offer_rec.offer_used_by_id := p7_a61;
    ddp_offer_rec.offer_used_by := p7_a62;
    ddp_offer_rec.ql_qualifier_type := p7_a63;
    ddp_offer_rec.ql_qualifier_id := p7_a64;
    ddp_offer_rec.distribution_type := p7_a65;
    ddp_offer_rec.amount_limit_id := p7_a66;
    ddp_offer_rec.uses_limit_id := p7_a67;
    ddp_offer_rec.offer_operation := p7_a68;
    ddp_offer_rec.modifier_operation := p7_a69;
    ddp_offer_rec.budget_offer_yn := p7_a70;
    ddp_offer_rec.break_type := p7_a71;
    ddp_offer_rec.retroactive := p7_a72;
    ddp_offer_rec.volume_offer_type := p7_a73;
    ddp_offer_rec.confidential_flag := p7_a74;
    ddp_offer_rec.committed_amount_eq_max := p7_a75;
    ddp_offer_rec.source_from_parent := p7_a76;
    ddp_offer_rec.buyer_name := p7_a77;
    ddp_offer_rec.tier_level := p7_a78;
    ddp_offer_rec.na_rule_header_id := p7_a79;
    ddp_offer_rec.sales_method_flag := p7_a80;
    ddp_offer_rec.global_flag := p7_a81;
    ddp_offer_rec.orig_org_id := p7_a82;


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pvt.activate_offer_over(p_init_msg_list,
      p_api_version,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_called_from,
      ddp_offer_rec,
      x_amount_error);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_offer_status(p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p4_a11  NUMBER
    , p4_a12  DATE
    , p4_a13  DATE
    , p4_a14  VARCHAR2
    , p4_a15  DATE
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  NUMBER
    , p4_a19  VARCHAR2
    , p4_a20  NUMBER
    , p4_a21  NUMBER
    , p4_a22  NUMBER
    , p4_a23  NUMBER
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  DATE
    , p4_a44  DATE
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  DATE
    , p4_a52  DATE
    , p4_a53  VARCHAR2
    , p4_a54  DATE
    , p4_a55  DATE
    , p4_a56  VARCHAR2
    , p4_a57  VARCHAR2
    , p4_a58  NUMBER
    , p4_a59  NUMBER
    , p4_a60  VARCHAR2
    , p4_a61  NUMBER
    , p4_a62  VARCHAR2
    , p4_a63  VARCHAR2
    , p4_a64  NUMBER
    , p4_a65  VARCHAR2
    , p4_a66  NUMBER
    , p4_a67  NUMBER
    , p4_a68  VARCHAR2
    , p4_a69  VARCHAR2
    , p4_a70  VARCHAR2
    , p4_a71  VARCHAR2
    , p4_a72  VARCHAR2
    , p4_a73  VARCHAR2
    , p4_a74  VARCHAR2
    , p4_a75  VARCHAR2
    , p4_a76  VARCHAR2
    , p4_a77  VARCHAR2
    , p4_a78  VARCHAR2
    , p4_a79  NUMBER
    , p4_a80  VARCHAR2
    , p4_a81  VARCHAR2
    , p4_a82  NUMBER
  )

  as
    ddp_modifier_list_rec ozf_offer_pvt.modifier_list_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_modifier_list_rec.offer_id := p4_a0;
    ddp_modifier_list_rec.qp_list_header_id := p4_a1;
    ddp_modifier_list_rec.offer_type := p4_a2;
    ddp_modifier_list_rec.offer_code := p4_a3;
    ddp_modifier_list_rec.activity_media_id := p4_a4;
    ddp_modifier_list_rec.reusable := p4_a5;
    ddp_modifier_list_rec.user_status_id := p4_a6;
    ddp_modifier_list_rec.owner_id := p4_a7;
    ddp_modifier_list_rec.wf_item_key := p4_a8;
    ddp_modifier_list_rec.customer_reference := p4_a9;
    ddp_modifier_list_rec.buying_group_contact_id := p4_a10;
    ddp_modifier_list_rec.object_version_number := p4_a11;
    ddp_modifier_list_rec.perf_date_from := p4_a12;
    ddp_modifier_list_rec.perf_date_to := p4_a13;
    ddp_modifier_list_rec.status_code := p4_a14;
    ddp_modifier_list_rec.status_date := p4_a15;
    ddp_modifier_list_rec.modifier_level_code := p4_a16;
    ddp_modifier_list_rec.order_value_discount_type := p4_a17;
    ddp_modifier_list_rec.lumpsum_amount := p4_a18;
    ddp_modifier_list_rec.lumpsum_payment_type := p4_a19;
    ddp_modifier_list_rec.custom_setup_id := p4_a20;
    ddp_modifier_list_rec.offer_amount := p4_a21;
    ddp_modifier_list_rec.budget_amount_tc := p4_a22;
    ddp_modifier_list_rec.budget_amount_fc := p4_a23;
    ddp_modifier_list_rec.transaction_currency_code := p4_a24;
    ddp_modifier_list_rec.functional_currency_code := p4_a25;
    ddp_modifier_list_rec.context := p4_a26;
    ddp_modifier_list_rec.attribute1 := p4_a27;
    ddp_modifier_list_rec.attribute2 := p4_a28;
    ddp_modifier_list_rec.attribute3 := p4_a29;
    ddp_modifier_list_rec.attribute4 := p4_a30;
    ddp_modifier_list_rec.attribute5 := p4_a31;
    ddp_modifier_list_rec.attribute6 := p4_a32;
    ddp_modifier_list_rec.attribute7 := p4_a33;
    ddp_modifier_list_rec.attribute8 := p4_a34;
    ddp_modifier_list_rec.attribute9 := p4_a35;
    ddp_modifier_list_rec.attribute10 := p4_a36;
    ddp_modifier_list_rec.attribute11 := p4_a37;
    ddp_modifier_list_rec.attribute12 := p4_a38;
    ddp_modifier_list_rec.attribute13 := p4_a39;
    ddp_modifier_list_rec.attribute14 := p4_a40;
    ddp_modifier_list_rec.attribute15 := p4_a41;
    ddp_modifier_list_rec.currency_code := p4_a42;
    ddp_modifier_list_rec.start_date_active := p4_a43;
    ddp_modifier_list_rec.end_date_active := p4_a44;
    ddp_modifier_list_rec.list_type_code := p4_a45;
    ddp_modifier_list_rec.discount_lines_flag := p4_a46;
    ddp_modifier_list_rec.name := p4_a47;
    ddp_modifier_list_rec.description := p4_a48;
    ddp_modifier_list_rec.comments := p4_a49;
    ddp_modifier_list_rec.ask_for_flag := p4_a50;
    ddp_modifier_list_rec.start_date_active_first := p4_a51;
    ddp_modifier_list_rec.end_date_active_first := p4_a52;
    ddp_modifier_list_rec.active_date_first_type := p4_a53;
    ddp_modifier_list_rec.start_date_active_second := p4_a54;
    ddp_modifier_list_rec.end_date_active_second := p4_a55;
    ddp_modifier_list_rec.active_date_second_type := p4_a56;
    ddp_modifier_list_rec.active_flag := p4_a57;
    ddp_modifier_list_rec.max_no_of_uses := p4_a58;
    ddp_modifier_list_rec.budget_source_id := p4_a59;
    ddp_modifier_list_rec.budget_source_type := p4_a60;
    ddp_modifier_list_rec.offer_used_by_id := p4_a61;
    ddp_modifier_list_rec.offer_used_by := p4_a62;
    ddp_modifier_list_rec.ql_qualifier_type := p4_a63;
    ddp_modifier_list_rec.ql_qualifier_id := p4_a64;
    ddp_modifier_list_rec.distribution_type := p4_a65;
    ddp_modifier_list_rec.amount_limit_id := p4_a66;
    ddp_modifier_list_rec.uses_limit_id := p4_a67;
    ddp_modifier_list_rec.offer_operation := p4_a68;
    ddp_modifier_list_rec.modifier_operation := p4_a69;
    ddp_modifier_list_rec.budget_offer_yn := p4_a70;
    ddp_modifier_list_rec.break_type := p4_a71;
    ddp_modifier_list_rec.retroactive := p4_a72;
    ddp_modifier_list_rec.volume_offer_type := p4_a73;
    ddp_modifier_list_rec.confidential_flag := p4_a74;
    ddp_modifier_list_rec.committed_amount_eq_max := p4_a75;
    ddp_modifier_list_rec.source_from_parent := p4_a76;
    ddp_modifier_list_rec.buyer_name := p4_a77;
    ddp_modifier_list_rec.tier_level := p4_a78;
    ddp_modifier_list_rec.na_rule_header_id := p4_a79;
    ddp_modifier_list_rec.sales_method_flag := p4_a80;
    ddp_modifier_list_rec.global_flag := p4_a81;
    ddp_modifier_list_rec.orig_org_id := p4_a82;

    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pvt.update_offer_status(p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_modifier_list_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure process_qp_list_lines(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_offer_type  VARCHAR2
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_DATE_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_VARCHAR2_TABLE_100
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_VARCHAR2_TABLE_100
    , p4_a22 JTF_VARCHAR2_TABLE_100
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_VARCHAR2_TABLE_300
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_NUMBER_TABLE
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_VARCHAR2_TABLE_300
    , p4_a30 JTF_VARCHAR2_TABLE_100
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_VARCHAR2_TABLE_300
    , p4_a34 JTF_VARCHAR2_TABLE_300
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_300
    , p4_a37 JTF_VARCHAR2_TABLE_300
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_VARCHAR2_TABLE_2000
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_300
    , p4_a42 JTF_VARCHAR2_TABLE_300
    , p4_a43 JTF_VARCHAR2_TABLE_300
    , p4_a44 JTF_VARCHAR2_TABLE_300
    , p4_a45 JTF_VARCHAR2_TABLE_300
    , p4_a46 JTF_VARCHAR2_TABLE_300
    , p4_a47 JTF_VARCHAR2_TABLE_300
    , p4_a48 JTF_VARCHAR2_TABLE_300
    , p4_a49 JTF_VARCHAR2_TABLE_300
    , p4_a50 JTF_VARCHAR2_TABLE_300
    , p4_a51 JTF_VARCHAR2_TABLE_300
    , p4_a52 JTF_VARCHAR2_TABLE_300
    , p4_a53 JTF_VARCHAR2_TABLE_300
    , p4_a54 JTF_VARCHAR2_TABLE_300
    , p4_a55 JTF_VARCHAR2_TABLE_300
    , p4_a56 JTF_NUMBER_TABLE
    , p4_a57 JTF_NUMBER_TABLE
    , p4_a58 JTF_NUMBER_TABLE
    , p4_a59 JTF_NUMBER_TABLE
    , p4_a60 JTF_NUMBER_TABLE
    , p4_a61 JTF_NUMBER_TABLE
    , p4_a62 JTF_NUMBER_TABLE
    , p4_a63 JTF_NUMBER_TABLE
    , p4_a64 JTF_NUMBER_TABLE
    , p4_a65 JTF_NUMBER_TABLE
    , p4_a66 JTF_VARCHAR2_TABLE_100
    , p4_a67 JTF_NUMBER_TABLE
    , p4_a68 JTF_NUMBER_TABLE
    , p4_a69 JTF_VARCHAR2_TABLE_300
    , p4_a70 JTF_VARCHAR2_TABLE_300
    , p_list_header_id  NUMBER
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_DATE_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_DATE_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_DATE_TABLE
    , p6_a73 out nocopy JTF_NUMBER_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a78 out nocopy JTF_NUMBER_TABLE
    , p6_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a83 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_NUMBER_TABLE
    , p6_a87 out nocopy JTF_NUMBER_TABLE
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , x_error_location out nocopy  NUMBER
  )

  as
    ddp_modifier_line_tbl ozf_offer_pvt.modifier_line_tbl_type;
    ddx_modifier_line_tbl qp_modifiers_pub.modifiers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ozf_offer_pvt_oa.rosetta_table_copy_in_p2(ddp_modifier_line_tbl, p4_a0
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
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      , p4_a68
      , p4_a69
      , p4_a70
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_pvt.process_qp_list_lines(x_return_status,
      x_msg_count,
      x_msg_data,
      p_offer_type,
      ddp_modifier_line_tbl,
      p_list_header_id,
      ddx_modifier_line_tbl,
      x_error_location);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    qp_modifiers_pub_oa.rosetta_table_copy_out_p3(ddx_modifier_line_tbl, p6_a0
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
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      );

  end;

end ozf_offer_pvt_oa;

/
