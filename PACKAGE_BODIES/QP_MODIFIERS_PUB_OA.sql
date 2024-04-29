--------------------------------------------------------
--  DDL for Package Body QP_MODIFIERS_PUB_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MODIFIERS_PUB_OA" as
  /* $Header: ozfaqpmb.pls 120.0 2005/08/31 09:43 gramanat noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy qp_modifiers_pub.pricing_attr_tbl_type, a0 JTF_NUMBER_TABLE
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t qp_modifiers_pub.pricing_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy qp_modifiers_pub.modifiers_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_DATE_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_DATE_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_DATE_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_DATE_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).arithmetic_operator := a0(indx);
          t(ddindx).attribute1 := a1(indx);
          t(ddindx).attribute10 := a2(indx);
          t(ddindx).attribute11 := a3(indx);
          t(ddindx).attribute12 := a4(indx);
          t(ddindx).attribute13 := a5(indx);
          t(ddindx).attribute14 := a6(indx);
          t(ddindx).attribute15 := a7(indx);
          t(ddindx).attribute2 := a8(indx);
          t(ddindx).attribute3 := a9(indx);
          t(ddindx).attribute4 := a10(indx);
          t(ddindx).attribute5 := a11(indx);
          t(ddindx).attribute6 := a12(indx);
          t(ddindx).attribute7 := a13(indx);
          t(ddindx).attribute8 := a14(indx);
          t(ddindx).attribute9 := a15(indx);
          t(ddindx).automatic_flag := a16(indx);
          t(ddindx).comments := a17(indx);
          t(ddindx).context := a18(indx);
          t(ddindx).created_by := a19(indx);
          t(ddindx).creation_date := a20(indx);
          t(ddindx).effective_period_uom := a21(indx);
          t(ddindx).end_date_active := a22(indx);
          t(ddindx).estim_accrual_rate := a23(indx);
          t(ddindx).generate_using_formula_id := a24(indx);
          t(ddindx).inventory_item_id := a25(indx);
          t(ddindx).last_updated_by := a26(indx);
          t(ddindx).last_update_date := a27(indx);
          t(ddindx).last_update_login := a28(indx);
          t(ddindx).list_header_id := a29(indx);
          t(ddindx).list_line_id := a30(indx);
          t(ddindx).list_line_type_code := a31(indx);
          t(ddindx).list_price := a32(indx);
          t(ddindx).modifier_level_code := a33(indx);
          t(ddindx).number_effective_periods := a34(indx);
          t(ddindx).operand := a35(indx);
          t(ddindx).organization_id := a36(indx);
          t(ddindx).override_flag := a37(indx);
          t(ddindx).percent_price := a38(indx);
          t(ddindx).price_break_type_code := a39(indx);
          t(ddindx).price_by_formula_id := a40(indx);
          t(ddindx).primary_uom_flag := a41(indx);
          t(ddindx).print_on_invoice_flag := a42(indx);
          t(ddindx).program_application_id := a43(indx);
          t(ddindx).program_id := a44(indx);
          t(ddindx).program_update_date := a45(indx);
          t(ddindx).rebate_trxn_type_code := a46(indx);
          t(ddindx).related_item_id := a47(indx);
          t(ddindx).relationship_type_id := a48(indx);
          t(ddindx).reprice_flag := a49(indx);
          t(ddindx).request_id := a50(indx);
          t(ddindx).revision := a51(indx);
          t(ddindx).revision_date := a52(indx);
          t(ddindx).revision_reason_code := a53(indx);
          t(ddindx).start_date_active := a54(indx);
          t(ddindx).substitution_attribute := a55(indx);
          t(ddindx).substitution_context := a56(indx);
          t(ddindx).substitution_value := a57(indx);
          t(ddindx).accrual_flag := a58(indx);
          t(ddindx).pricing_group_sequence := a59(indx);
          t(ddindx).incompatibility_grp_code := a60(indx);
          t(ddindx).list_line_no := a61(indx);
          t(ddindx).rltd_modifier_id := a62(indx);
          t(ddindx).from_rltd_modifier_id := a63(indx);
          t(ddindx).to_rltd_modifier_id := a64(indx);
          t(ddindx).rltd_modifier_grp_no := a65(indx);
          t(ddindx).rltd_modifier_grp_type := a66(indx);
          t(ddindx).pricing_phase_id := a67(indx);
          t(ddindx).product_precedence := a68(indx);
          t(ddindx).expiration_period_start_date := a69(indx);
          t(ddindx).number_expiration_periods := a70(indx);
          t(ddindx).expiration_period_uom := a71(indx);
          t(ddindx).expiration_date := a72(indx);
          t(ddindx).estim_gl_value := a73(indx);
          t(ddindx).benefit_price_list_line_id := a74(indx);
          t(ddindx).benefit_limit := a75(indx);
          t(ddindx).charge_type_code := a76(indx);
          t(ddindx).charge_subtype_code := a77(indx);
          t(ddindx).benefit_qty := a78(indx);
          t(ddindx).benefit_uom_code := a79(indx);
          t(ddindx).accrual_conversion_rate := a80(indx);
          t(ddindx).proration_type_code := a81(indx);
          t(ddindx).include_on_returns_flag := a82(indx);
          t(ddindx).return_status := a83(indx);
          t(ddindx).db_flag := a84(indx);
          t(ddindx).operation := a85(indx);
          t(ddindx).modifier_parent_index := a86(indx);
          t(ddindx).qualification_ind := a87(indx);
          t(ddindx).net_amount_flag := a88(indx);
          t(ddindx).accum_attribute := a89(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t qp_modifiers_pub.modifiers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_DATE_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_DATE_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_DATE_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_VARCHAR2_TABLE_100
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_VARCHAR2_TABLE_100
    , a89 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_DATE_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_DATE_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_DATE_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_NUMBER_TABLE();
    a87 := JTF_NUMBER_TABLE();
    a88 := JTF_VARCHAR2_TABLE_100();
    a89 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_DATE_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_DATE_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_DATE_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_NUMBER_TABLE();
      a87 := JTF_NUMBER_TABLE();
      a88 := JTF_VARCHAR2_TABLE_100();
      a89 := JTF_VARCHAR2_TABLE_300();
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
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
        a82.extend(t.count);
        a83.extend(t.count);
        a84.extend(t.count);
        a85.extend(t.count);
        a86.extend(t.count);
        a87.extend(t.count);
        a88.extend(t.count);
        a89.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).arithmetic_operator;
          a1(indx) := t(ddindx).attribute1;
          a2(indx) := t(ddindx).attribute10;
          a3(indx) := t(ddindx).attribute11;
          a4(indx) := t(ddindx).attribute12;
          a5(indx) := t(ddindx).attribute13;
          a6(indx) := t(ddindx).attribute14;
          a7(indx) := t(ddindx).attribute15;
          a8(indx) := t(ddindx).attribute2;
          a9(indx) := t(ddindx).attribute3;
          a10(indx) := t(ddindx).attribute4;
          a11(indx) := t(ddindx).attribute5;
          a12(indx) := t(ddindx).attribute6;
          a13(indx) := t(ddindx).attribute7;
          a14(indx) := t(ddindx).attribute8;
          a15(indx) := t(ddindx).attribute9;
          a16(indx) := t(ddindx).automatic_flag;
          a17(indx) := t(ddindx).comments;
          a18(indx) := t(ddindx).context;
          a19(indx) := t(ddindx).created_by;
          a20(indx) := t(ddindx).creation_date;
          a21(indx) := t(ddindx).effective_period_uom;
          a22(indx) := t(ddindx).end_date_active;
          a23(indx) := t(ddindx).estim_accrual_rate;
          a24(indx) := t(ddindx).generate_using_formula_id;
          a25(indx) := t(ddindx).inventory_item_id;
          a26(indx) := t(ddindx).last_updated_by;
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := t(ddindx).last_update_login;
          a29(indx) := t(ddindx).list_header_id;
          a30(indx) := t(ddindx).list_line_id;
          a31(indx) := t(ddindx).list_line_type_code;
          a32(indx) := t(ddindx).list_price;
          a33(indx) := t(ddindx).modifier_level_code;
          a34(indx) := t(ddindx).number_effective_periods;
          a35(indx) := t(ddindx).operand;
          a36(indx) := t(ddindx).organization_id;
          a37(indx) := t(ddindx).override_flag;
          a38(indx) := t(ddindx).percent_price;
          a39(indx) := t(ddindx).price_break_type_code;
          a40(indx) := t(ddindx).price_by_formula_id;
          a41(indx) := t(ddindx).primary_uom_flag;
          a42(indx) := t(ddindx).print_on_invoice_flag;
          a43(indx) := t(ddindx).program_application_id;
          a44(indx) := t(ddindx).program_id;
          a45(indx) := t(ddindx).program_update_date;
          a46(indx) := t(ddindx).rebate_trxn_type_code;
          a47(indx) := t(ddindx).related_item_id;
          a48(indx) := t(ddindx).relationship_type_id;
          a49(indx) := t(ddindx).reprice_flag;
          a50(indx) := t(ddindx).request_id;
          a51(indx) := t(ddindx).revision;
          a52(indx) := t(ddindx).revision_date;
          a53(indx) := t(ddindx).revision_reason_code;
          a54(indx) := t(ddindx).start_date_active;
          a55(indx) := t(ddindx).substitution_attribute;
          a56(indx) := t(ddindx).substitution_context;
          a57(indx) := t(ddindx).substitution_value;
          a58(indx) := t(ddindx).accrual_flag;
          a59(indx) := t(ddindx).pricing_group_sequence;
          a60(indx) := t(ddindx).incompatibility_grp_code;
          a61(indx) := t(ddindx).list_line_no;
          a62(indx) := t(ddindx).rltd_modifier_id;
          a63(indx) := t(ddindx).from_rltd_modifier_id;
          a64(indx) := t(ddindx).to_rltd_modifier_id;
          a65(indx) := t(ddindx).rltd_modifier_grp_no;
          a66(indx) := t(ddindx).rltd_modifier_grp_type;
          a67(indx) := t(ddindx).pricing_phase_id;
          a68(indx) := t(ddindx).product_precedence;
          a69(indx) := t(ddindx).expiration_period_start_date;
          a70(indx) := t(ddindx).number_expiration_periods;
          a71(indx) := t(ddindx).expiration_period_uom;
          a72(indx) := t(ddindx).expiration_date;
          a73(indx) := t(ddindx).estim_gl_value;
          a74(indx) := t(ddindx).benefit_price_list_line_id;
          a75(indx) := t(ddindx).benefit_limit;
          a76(indx) := t(ddindx).charge_type_code;
          a77(indx) := t(ddindx).charge_subtype_code;
          a78(indx) := t(ddindx).benefit_qty;
          a79(indx) := t(ddindx).benefit_uom_code;
          a80(indx) := t(ddindx).accrual_conversion_rate;
          a81(indx) := t(ddindx).proration_type_code;
          a82(indx) := t(ddindx).include_on_returns_flag;
          a83(indx) := t(ddindx).return_status;
          a84(indx) := t(ddindx).db_flag;
          a85(indx) := t(ddindx).operation;
          a86(indx) := t(ddindx).modifier_parent_index;
          a87(indx) := t(ddindx).qualification_ind;
          a88(indx) := t(ddindx).net_amount_flag;
          a89(indx) := t(ddindx).accum_attribute;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

end qp_modifiers_pub_oa;

/
