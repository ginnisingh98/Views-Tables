--------------------------------------------------------
--  DDL for Package Body OE_ORDER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_PUB_W" as
  /* $Header: ONTRORDB.pls 120.1 2005/07/01 13:02:59 appldev ship $ */
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

  procedure rosetta_table_copy_in_p1(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
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
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
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
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_DATE_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_NUMBER_TABLE
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_DATE_TABLE
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_NUMBER_TABLE
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_VARCHAR2_TABLE_100
    , a95 JTF_NUMBER_TABLE
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_DATE_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_DATE_TABLE
    , a102 JTF_DATE_TABLE
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_VARCHAR2_TABLE_100
    , a105 JTF_NUMBER_TABLE
    , a106 JTF_VARCHAR2_TABLE_100
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_VARCHAR2_TABLE_100
    , a109 JTF_NUMBER_TABLE
    , a110 JTF_NUMBER_TABLE
    , a111 JTF_NUMBER_TABLE
    , a112 JTF_NUMBER_TABLE
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_NUMBER_TABLE
    , a115 JTF_NUMBER_TABLE
    , a116 JTF_NUMBER_TABLE
    , a117 JTF_NUMBER_TABLE
    , a118 JTF_NUMBER_TABLE
    , a119 JTF_NUMBER_TABLE
    , a120 JTF_VARCHAR2_TABLE_100
    , a121 JTF_VARCHAR2_TABLE_100
    , a122 JTF_VARCHAR2_TABLE_100
    , a123 JTF_VARCHAR2_TABLE_100
    , a124 JTF_VARCHAR2_TABLE_100
    , a125 JTF_NUMBER_TABLE
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_VARCHAR2_TABLE_100
    , a128 JTF_VARCHAR2_TABLE_100
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_DATE_TABLE
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_DATE_TABLE
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_2000
    , a135 JTF_VARCHAR2_TABLE_100
    , a136 JTF_VARCHAR2_TABLE_100
    , a137 JTF_VARCHAR2_TABLE_100
    , a138 JTF_VARCHAR2_TABLE_100
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_VARCHAR2_TABLE_100
    , a141 JTF_NUMBER_TABLE
    , a142 JTF_VARCHAR2_TABLE_100
    , a143 JTF_NUMBER_TABLE
    , a144 JTF_VARCHAR2_TABLE_100
    , a145 JTF_VARCHAR2_TABLE_100
    , a146 JTF_VARCHAR2_TABLE_100
    , a147 JTF_VARCHAR2_TABLE_100
    , a148 JTF_DATE_TABLE
    , a149 JTF_VARCHAR2_TABLE_100
    , a150 JTF_DATE_TABLE
    , a151 JTF_VARCHAR2_TABLE_2000
    , a152 JTF_VARCHAR2_TABLE_2000
    , a153 JTF_VARCHAR2_TABLE_100
    , a154 JTF_DATE_TABLE
    , a155 JTF_NUMBER_TABLE
    , a156 JTF_VARCHAR2_TABLE_100
    , a157 JTF_NUMBER_TABLE
    , a158 JTF_VARCHAR2_TABLE_100
    , a159 JTF_VARCHAR2_TABLE_100
    , a160 JTF_VARCHAR2_TABLE_100
    , a161 JTF_VARCHAR2_TABLE_100
    , a162 JTF_NUMBER_TABLE
    , a163 JTF_NUMBER_TABLE
    , a164 JTF_NUMBER_TABLE
    , a165 JTF_NUMBER_TABLE
    , a166 JTF_VARCHAR2_TABLE_100
    , a167 JTF_NUMBER_TABLE
    , a168 JTF_NUMBER_TABLE
    , a169 JTF_NUMBER_TABLE
    , a170 JTF_NUMBER_TABLE
    , a171 JTF_NUMBER_TABLE
    , a172 JTF_VARCHAR2_TABLE_100
    , a173 JTF_NUMBER_TABLE
    , a174 JTF_VARCHAR2_TABLE_100
    , a175 JTF_VARCHAR2_TABLE_100
    , a176 JTF_VARCHAR2_TABLE_100
    , a177 JTF_DATE_TABLE
    , a178 JTF_NUMBER_TABLE
    , a179 JTF_VARCHAR2_TABLE_300
    , a180 JTF_VARCHAR2_TABLE_100
    , a181 JTF_VARCHAR2_TABLE_100
    , a182 JTF_VARCHAR2_TABLE_100
    , a183 JTF_NUMBER_TABLE
    , a184 JTF_NUMBER_TABLE
    , a185 JTF_NUMBER_TABLE
    , a186 JTF_VARCHAR2_TABLE_100
    , a187 JTF_VARCHAR2_TABLE_100
    , a188 JTF_VARCHAR2_TABLE_100
    , a189 JTF_NUMBER_TABLE
    , a190 JTF_NUMBER_TABLE
    , a191 JTF_NUMBER_TABLE
    , a192 JTF_VARCHAR2_TABLE_300
    , a193 JTF_DATE_TABLE
    , a194 JTF_VARCHAR2_TABLE_300
    , a195 JTF_DATE_TABLE
    , a196 JTF_NUMBER_TABLE
    , a197 JTF_NUMBER_TABLE
    , a198 JTF_NUMBER_TABLE
    , a199 JTF_NUMBER_TABLE
    , a200 JTF_NUMBER_TABLE
    , a201 JTF_NUMBER_TABLE
    , a202 JTF_NUMBER_TABLE
    , a203 JTF_NUMBER_TABLE
    , a204 JTF_NUMBER_TABLE
    , a205 JTF_NUMBER_TABLE
    , a206 JTF_NUMBER_TABLE
    , a207 JTF_NUMBER_TABLE
    , a208 JTF_NUMBER_TABLE
    , a209 JTF_NUMBER_TABLE
    , a210 JTF_NUMBER_TABLE
    , a211 JTF_NUMBER_TABLE
    , a212 JTF_NUMBER_TABLE
    , a213 JTF_NUMBER_TABLE
    , a214 JTF_VARCHAR2_TABLE_100
    , a215 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).accounting_rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).agreement_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).attribute1 := a2(indx);
          t(ddindx).attribute10 := a3(indx);
          t(ddindx).attribute11 := a4(indx);
          t(ddindx).attribute12 := a5(indx);
          t(ddindx).attribute13 := a6(indx);
          t(ddindx).attribute14 := a7(indx);
          t(ddindx).attribute15 := a8(indx);
          t(ddindx).attribute16 := a9(indx);
          t(ddindx).attribute17 := a10(indx);
          t(ddindx).attribute18 := a11(indx);
          t(ddindx).attribute19 := a12(indx);
          t(ddindx).attribute2 := a13(indx);
          t(ddindx).attribute20 := a14(indx);
          t(ddindx).attribute3 := a15(indx);
          t(ddindx).attribute4 := a16(indx);
          t(ddindx).attribute5 := a17(indx);
          t(ddindx).attribute6 := a18(indx);
          t(ddindx).attribute7 := a19(indx);
          t(ddindx).attribute8 := a20(indx);
          t(ddindx).attribute9 := a21(indx);
          t(ddindx).booked_flag := a22(indx);
          t(ddindx).cancelled_flag := a23(indx);
          t(ddindx).context := a24(indx);
          t(ddindx).conversion_rate := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).conversion_rate_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).conversion_type_code := a27(indx);
          t(ddindx).customer_preference_set_code := a28(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).cust_po_number := a31(indx);
          t(ddindx).deliver_to_contact_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).deliver_to_org_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).demand_class_code := a34(indx);
          t(ddindx).earliest_schedule_limit := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).fob_point_code := a37(indx);
          t(ddindx).freight_carrier_code := a38(indx);
          t(ddindx).freight_terms_code := a39(indx);
          t(ddindx).global_attribute1 := a40(indx);
          t(ddindx).global_attribute10 := a41(indx);
          t(ddindx).global_attribute11 := a42(indx);
          t(ddindx).global_attribute12 := a43(indx);
          t(ddindx).global_attribute13 := a44(indx);
          t(ddindx).global_attribute14 := a45(indx);
          t(ddindx).global_attribute15 := a46(indx);
          t(ddindx).global_attribute16 := a47(indx);
          t(ddindx).global_attribute17 := a48(indx);
          t(ddindx).global_attribute18 := a49(indx);
          t(ddindx).global_attribute19 := a50(indx);
          t(ddindx).global_attribute2 := a51(indx);
          t(ddindx).global_attribute20 := a52(indx);
          t(ddindx).global_attribute3 := a53(indx);
          t(ddindx).global_attribute4 := a54(indx);
          t(ddindx).global_attribute5 := a55(indx);
          t(ddindx).global_attribute6 := a56(indx);
          t(ddindx).global_attribute7 := a57(indx);
          t(ddindx).global_attribute8 := a58(indx);
          t(ddindx).global_attribute9 := a59(indx);
          t(ddindx).global_attribute_category := a60(indx);
          t(ddindx).tp_context := a61(indx);
          t(ddindx).tp_attribute1 := a62(indx);
          t(ddindx).tp_attribute2 := a63(indx);
          t(ddindx).tp_attribute3 := a64(indx);
          t(ddindx).tp_attribute4 := a65(indx);
          t(ddindx).tp_attribute5 := a66(indx);
          t(ddindx).tp_attribute6 := a67(indx);
          t(ddindx).tp_attribute7 := a68(indx);
          t(ddindx).tp_attribute8 := a69(indx);
          t(ddindx).tp_attribute9 := a70(indx);
          t(ddindx).tp_attribute10 := a71(indx);
          t(ddindx).tp_attribute11 := a72(indx);
          t(ddindx).tp_attribute12 := a73(indx);
          t(ddindx).tp_attribute13 := a74(indx);
          t(ddindx).tp_attribute14 := a75(indx);
          t(ddindx).tp_attribute15 := a76(indx);
          t(ddindx).header_id := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).invoice_to_contact_id := rosetta_g_miss_num_map(a78(indx));
          t(ddindx).invoice_to_org_id := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).invoicing_rule_id := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a81(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a82(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a83(indx));
          t(ddindx).latest_schedule_limit := rosetta_g_miss_num_map(a84(indx));
          t(ddindx).open_flag := a85(indx);
          t(ddindx).order_category_code := a86(indx);
          t(ddindx).ordered_date := rosetta_g_miss_date_in_map(a87(indx));
          t(ddindx).order_date_type_code := a88(indx);
          t(ddindx).order_number := rosetta_g_miss_num_map(a89(indx));
          t(ddindx).order_source_id := rosetta_g_miss_num_map(a90(indx));
          t(ddindx).order_type_id := rosetta_g_miss_num_map(a91(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a92(indx));
          t(ddindx).orig_sys_document_ref := a93(indx);
          t(ddindx).partial_shipments_allowed := a94(indx);
          t(ddindx).payment_term_id := rosetta_g_miss_num_map(a95(indx));
          t(ddindx).price_list_id := rosetta_g_miss_num_map(a96(indx));
          t(ddindx).price_request_code := a97(indx);
          t(ddindx).pricing_date := rosetta_g_miss_date_in_map(a98(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a99(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a100(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a101(indx));
          t(ddindx).request_date := rosetta_g_miss_date_in_map(a102(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a103(indx));
          t(ddindx).return_reason_code := a104(indx);
          t(ddindx).salesrep_id := rosetta_g_miss_num_map(a105(indx));
          t(ddindx).sales_channel_code := a106(indx);
          t(ddindx).shipment_priority_code := a107(indx);
          t(ddindx).shipping_method_code := a108(indx);
          t(ddindx).ship_from_org_id := rosetta_g_miss_num_map(a109(indx));
          t(ddindx).ship_tolerance_above := rosetta_g_miss_num_map(a110(indx));
          t(ddindx).ship_tolerance_below := rosetta_g_miss_num_map(a111(indx));
          t(ddindx).ship_to_contact_id := rosetta_g_miss_num_map(a112(indx));
          t(ddindx).ship_to_org_id := rosetta_g_miss_num_map(a113(indx));
          t(ddindx).sold_from_org_id := rosetta_g_miss_num_map(a114(indx));
          t(ddindx).sold_to_contact_id := rosetta_g_miss_num_map(a115(indx));
          t(ddindx).sold_to_org_id := rosetta_g_miss_num_map(a116(indx));
          t(ddindx).sold_to_phone_id := rosetta_g_miss_num_map(a117(indx));
          t(ddindx).source_document_id := rosetta_g_miss_num_map(a118(indx));
          t(ddindx).source_document_type_id := rosetta_g_miss_num_map(a119(indx));
          t(ddindx).tax_exempt_flag := a120(indx);
          t(ddindx).tax_exempt_number := a121(indx);
          t(ddindx).tax_exempt_reason_code := a122(indx);
          t(ddindx).tax_point_code := a123(indx);
          t(ddindx).transactional_curr_code := a124(indx);
          t(ddindx).version_number := rosetta_g_miss_num_map(a125(indx));
          t(ddindx).return_status := a126(indx);
          t(ddindx).db_flag := a127(indx);
          t(ddindx).operation := a128(indx);
          t(ddindx).first_ack_code := a129(indx);
          t(ddindx).first_ack_date := rosetta_g_miss_date_in_map(a130(indx));
          t(ddindx).last_ack_code := a131(indx);
          t(ddindx).last_ack_date := rosetta_g_miss_date_in_map(a132(indx));
          t(ddindx).change_reason := a133(indx);
          t(ddindx).change_comments := a134(indx);
          t(ddindx).change_sequence := a135(indx);
          t(ddindx).change_request_code := a136(indx);
          t(ddindx).ready_flag := a137(indx);
          t(ddindx).status_flag := a138(indx);
          t(ddindx).force_apply_flag := a139(indx);
          t(ddindx).drop_ship_flag := a140(indx);
          t(ddindx).customer_payment_term_id := rosetta_g_miss_num_map(a141(indx));
          t(ddindx).payment_type_code := a142(indx);
          t(ddindx).payment_amount := rosetta_g_miss_num_map(a143(indx));
          t(ddindx).check_number := a144(indx);
          t(ddindx).credit_card_code := a145(indx);
          t(ddindx).credit_card_holder_name := a146(indx);
          t(ddindx).credit_card_number := a147(indx);
          t(ddindx).credit_card_expiration_date := rosetta_g_miss_date_in_map(a148(indx));
          t(ddindx).credit_card_approval_code := a149(indx);
          t(ddindx).credit_card_approval_date := rosetta_g_miss_date_in_map(a150(indx));
          t(ddindx).shipping_instructions := a151(indx);
          t(ddindx).packing_instructions := a152(indx);
          t(ddindx).flow_status_code := a153(indx);
          t(ddindx).booked_date := rosetta_g_miss_date_in_map(a154(indx));
          t(ddindx).marketing_source_code_id := rosetta_g_miss_num_map(a155(indx));
          t(ddindx).upgraded_flag := a156(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a157(indx));
          t(ddindx).ship_to_edi_location_code := a158(indx);
          t(ddindx).sold_to_edi_location_code := a159(indx);
          t(ddindx).bill_to_edi_location_code := a160(indx);
          t(ddindx).ship_from_edi_location_code := a161(indx);
          t(ddindx).ship_from_address_id := rosetta_g_miss_num_map(a162(indx));
          t(ddindx).sold_to_address_id := rosetta_g_miss_num_map(a163(indx));
          t(ddindx).ship_to_address_id := rosetta_g_miss_num_map(a164(indx));
          t(ddindx).invoice_address_id := rosetta_g_miss_num_map(a165(indx));
          t(ddindx).ship_to_address_code := a166(indx);
          t(ddindx).xml_message_id := rosetta_g_miss_num_map(a167(indx));
          t(ddindx).ship_to_customer_id := rosetta_g_miss_num_map(a168(indx));
          t(ddindx).invoice_to_customer_id := rosetta_g_miss_num_map(a169(indx));
          t(ddindx).deliver_to_customer_id := rosetta_g_miss_num_map(a170(indx));
          t(ddindx).accounting_rule_duration := rosetta_g_miss_num_map(a171(indx));
          t(ddindx).xml_transaction_type_code := a172(indx);
          t(ddindx).blanket_number := rosetta_g_miss_num_map(a173(indx));
          t(ddindx).line_set_name := a174(indx);
          t(ddindx).fulfillment_set_name := a175(indx);
          t(ddindx).default_fulfillment_set := a176(indx);
          t(ddindx).quote_date := rosetta_g_miss_date_in_map(a177(indx));
          t(ddindx).quote_number := rosetta_g_miss_num_map(a178(indx));
          t(ddindx).sales_document_name := a179(indx);
          t(ddindx).transaction_phase_code := a180(indx);
          t(ddindx).user_status_code := a181(indx);
          t(ddindx).draft_submitted_flag := a182(indx);
          t(ddindx).source_document_version_number := rosetta_g_miss_num_map(a183(indx));
          t(ddindx).sold_to_site_use_id := rosetta_g_miss_num_map(a184(indx));
          t(ddindx).minisite_id := rosetta_g_miss_num_map(a185(indx));
          t(ddindx).ib_owner := a186(indx);
          t(ddindx).ib_installed_at_location := a187(indx);
          t(ddindx).ib_current_location := a188(indx);
          t(ddindx).end_customer_id := rosetta_g_miss_num_map(a189(indx));
          t(ddindx).end_customer_contact_id := rosetta_g_miss_num_map(a190(indx));
          t(ddindx).end_customer_site_use_id := rosetta_g_miss_num_map(a191(indx));
          t(ddindx).supplier_signature := a192(indx);
          t(ddindx).supplier_signature_date := rosetta_g_miss_date_in_map(a193(indx));
          t(ddindx).customer_signature := a194(indx);
          t(ddindx).customer_signature_date := rosetta_g_miss_date_in_map(a195(indx));
          t(ddindx).sold_to_party_id := rosetta_g_miss_num_map(a196(indx));
          t(ddindx).sold_to_org_contact_id := rosetta_g_miss_num_map(a197(indx));
          t(ddindx).ship_to_party_id := rosetta_g_miss_num_map(a198(indx));
          t(ddindx).ship_to_party_site_id := rosetta_g_miss_num_map(a199(indx));
          t(ddindx).ship_to_party_site_use_id := rosetta_g_miss_num_map(a200(indx));
          t(ddindx).deliver_to_party_id := rosetta_g_miss_num_map(a201(indx));
          t(ddindx).deliver_to_party_site_id := rosetta_g_miss_num_map(a202(indx));
          t(ddindx).deliver_to_party_site_use_id := rosetta_g_miss_num_map(a203(indx));
          t(ddindx).invoice_to_party_id := rosetta_g_miss_num_map(a204(indx));
          t(ddindx).invoice_to_party_site_id := rosetta_g_miss_num_map(a205(indx));
          t(ddindx).invoice_to_party_site_use_id := rosetta_g_miss_num_map(a206(indx));
          t(ddindx).ship_to_customer_party_id := rosetta_g_miss_num_map(a207(indx));
          t(ddindx).deliver_to_customer_party_id := rosetta_g_miss_num_map(a208(indx));
          t(ddindx).invoice_to_customer_party_id := rosetta_g_miss_num_map(a209(indx));
          t(ddindx).ship_to_org_contact_id := rosetta_g_miss_num_map(a210(indx));
          t(ddindx).deliver_to_org_contact_id := rosetta_g_miss_num_map(a211(indx));
          t(ddindx).invoice_to_org_contact_id := rosetta_g_miss_num_map(a212(indx));
          t(ddindx).contract_template_id := rosetta_g_miss_num_map(a213(indx));
          t(ddindx).contract_source_doc_type_code := a214(indx);
          t(ddindx).contract_source_document_id := rosetta_g_miss_num_map(a215(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t oe_order_pub.header_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a29 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a36 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a78 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a79 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a80 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a81 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a82 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a83 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a84 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a87 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a89 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a90 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a91 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a92 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a95 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a96 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a99 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a100 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a101 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a103 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a105 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a109 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a110 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a111 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a112 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a113 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a114 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a115 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a116 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a117 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a118 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a119 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a125 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a130 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a132 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a138 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a141 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a142 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a143 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a144 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a145 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a146 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a147 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a148 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a149 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a150 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a151 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a152 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a153 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a154 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a155 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a156 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a157 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a158 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a159 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a160 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a161 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a162 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a163 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a164 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a165 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a166 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a167 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a168 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a169 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a170 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a171 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a172 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a173 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a174 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a175 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a176 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a177 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a178 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a179 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a180 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a181 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a182 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a183 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a184 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a185 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a186 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a187 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a188 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a189 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a190 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a191 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a192 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a193 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a194 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a195 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a196 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a197 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a198 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a199 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a200 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a201 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a202 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a203 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a204 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a205 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a206 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a207 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a208 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a209 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a210 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a211 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a212 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a213 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a214 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a215 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
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
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
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
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_300();
    a73 := JTF_VARCHAR2_TABLE_300();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_300();
    a76 := JTF_VARCHAR2_TABLE_300();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_DATE_TABLE();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_NUMBER_TABLE();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_100();
    a87 := JTF_DATE_TABLE();
    a88 := JTF_VARCHAR2_TABLE_100();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_NUMBER_TABLE();
    a91 := JTF_NUMBER_TABLE();
    a92 := JTF_NUMBER_TABLE();
    a93 := JTF_VARCHAR2_TABLE_100();
    a94 := JTF_VARCHAR2_TABLE_100();
    a95 := JTF_NUMBER_TABLE();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_VARCHAR2_TABLE_300();
    a98 := JTF_DATE_TABLE();
    a99 := JTF_NUMBER_TABLE();
    a100 := JTF_NUMBER_TABLE();
    a101 := JTF_DATE_TABLE();
    a102 := JTF_DATE_TABLE();
    a103 := JTF_NUMBER_TABLE();
    a104 := JTF_VARCHAR2_TABLE_100();
    a105 := JTF_NUMBER_TABLE();
    a106 := JTF_VARCHAR2_TABLE_100();
    a107 := JTF_VARCHAR2_TABLE_100();
    a108 := JTF_VARCHAR2_TABLE_100();
    a109 := JTF_NUMBER_TABLE();
    a110 := JTF_NUMBER_TABLE();
    a111 := JTF_NUMBER_TABLE();
    a112 := JTF_NUMBER_TABLE();
    a113 := JTF_NUMBER_TABLE();
    a114 := JTF_NUMBER_TABLE();
    a115 := JTF_NUMBER_TABLE();
    a116 := JTF_NUMBER_TABLE();
    a117 := JTF_NUMBER_TABLE();
    a118 := JTF_NUMBER_TABLE();
    a119 := JTF_NUMBER_TABLE();
    a120 := JTF_VARCHAR2_TABLE_100();
    a121 := JTF_VARCHAR2_TABLE_100();
    a122 := JTF_VARCHAR2_TABLE_100();
    a123 := JTF_VARCHAR2_TABLE_100();
    a124 := JTF_VARCHAR2_TABLE_100();
    a125 := JTF_NUMBER_TABLE();
    a126 := JTF_VARCHAR2_TABLE_100();
    a127 := JTF_VARCHAR2_TABLE_100();
    a128 := JTF_VARCHAR2_TABLE_100();
    a129 := JTF_VARCHAR2_TABLE_100();
    a130 := JTF_DATE_TABLE();
    a131 := JTF_VARCHAR2_TABLE_100();
    a132 := JTF_DATE_TABLE();
    a133 := JTF_VARCHAR2_TABLE_100();
    a134 := JTF_VARCHAR2_TABLE_2000();
    a135 := JTF_VARCHAR2_TABLE_100();
    a136 := JTF_VARCHAR2_TABLE_100();
    a137 := JTF_VARCHAR2_TABLE_100();
    a138 := JTF_VARCHAR2_TABLE_100();
    a139 := JTF_VARCHAR2_TABLE_100();
    a140 := JTF_VARCHAR2_TABLE_100();
    a141 := JTF_NUMBER_TABLE();
    a142 := JTF_VARCHAR2_TABLE_100();
    a143 := JTF_NUMBER_TABLE();
    a144 := JTF_VARCHAR2_TABLE_100();
    a145 := JTF_VARCHAR2_TABLE_100();
    a146 := JTF_VARCHAR2_TABLE_100();
    a147 := JTF_VARCHAR2_TABLE_100();
    a148 := JTF_DATE_TABLE();
    a149 := JTF_VARCHAR2_TABLE_100();
    a150 := JTF_DATE_TABLE();
    a151 := JTF_VARCHAR2_TABLE_2000();
    a152 := JTF_VARCHAR2_TABLE_2000();
    a153 := JTF_VARCHAR2_TABLE_100();
    a154 := JTF_DATE_TABLE();
    a155 := JTF_NUMBER_TABLE();
    a156 := JTF_VARCHAR2_TABLE_100();
    a157 := JTF_NUMBER_TABLE();
    a158 := JTF_VARCHAR2_TABLE_100();
    a159 := JTF_VARCHAR2_TABLE_100();
    a160 := JTF_VARCHAR2_TABLE_100();
    a161 := JTF_VARCHAR2_TABLE_100();
    a162 := JTF_NUMBER_TABLE();
    a163 := JTF_NUMBER_TABLE();
    a164 := JTF_NUMBER_TABLE();
    a165 := JTF_NUMBER_TABLE();
    a166 := JTF_VARCHAR2_TABLE_100();
    a167 := JTF_NUMBER_TABLE();
    a168 := JTF_NUMBER_TABLE();
    a169 := JTF_NUMBER_TABLE();
    a170 := JTF_NUMBER_TABLE();
    a171 := JTF_NUMBER_TABLE();
    a172 := JTF_VARCHAR2_TABLE_100();
    a173 := JTF_NUMBER_TABLE();
    a174 := JTF_VARCHAR2_TABLE_100();
    a175 := JTF_VARCHAR2_TABLE_100();
    a176 := JTF_VARCHAR2_TABLE_100();
    a177 := JTF_DATE_TABLE();
    a178 := JTF_NUMBER_TABLE();
    a179 := JTF_VARCHAR2_TABLE_300();
    a180 := JTF_VARCHAR2_TABLE_100();
    a181 := JTF_VARCHAR2_TABLE_100();
    a182 := JTF_VARCHAR2_TABLE_100();
    a183 := JTF_NUMBER_TABLE();
    a184 := JTF_NUMBER_TABLE();
    a185 := JTF_NUMBER_TABLE();
    a186 := JTF_VARCHAR2_TABLE_100();
    a187 := JTF_VARCHAR2_TABLE_100();
    a188 := JTF_VARCHAR2_TABLE_100();
    a189 := JTF_NUMBER_TABLE();
    a190 := JTF_NUMBER_TABLE();
    a191 := JTF_NUMBER_TABLE();
    a192 := JTF_VARCHAR2_TABLE_300();
    a193 := JTF_DATE_TABLE();
    a194 := JTF_VARCHAR2_TABLE_300();
    a195 := JTF_DATE_TABLE();
    a196 := JTF_NUMBER_TABLE();
    a197 := JTF_NUMBER_TABLE();
    a198 := JTF_NUMBER_TABLE();
    a199 := JTF_NUMBER_TABLE();
    a200 := JTF_NUMBER_TABLE();
    a201 := JTF_NUMBER_TABLE();
    a202 := JTF_NUMBER_TABLE();
    a203 := JTF_NUMBER_TABLE();
    a204 := JTF_NUMBER_TABLE();
    a205 := JTF_NUMBER_TABLE();
    a206 := JTF_NUMBER_TABLE();
    a207 := JTF_NUMBER_TABLE();
    a208 := JTF_NUMBER_TABLE();
    a209 := JTF_NUMBER_TABLE();
    a210 := JTF_NUMBER_TABLE();
    a211 := JTF_NUMBER_TABLE();
    a212 := JTF_NUMBER_TABLE();
    a213 := JTF_NUMBER_TABLE();
    a214 := JTF_VARCHAR2_TABLE_100();
    a215 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
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
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
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
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_300();
      a73 := JTF_VARCHAR2_TABLE_300();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_300();
      a76 := JTF_VARCHAR2_TABLE_300();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_DATE_TABLE();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_NUMBER_TABLE();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_100();
      a87 := JTF_DATE_TABLE();
      a88 := JTF_VARCHAR2_TABLE_100();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_NUMBER_TABLE();
      a91 := JTF_NUMBER_TABLE();
      a92 := JTF_NUMBER_TABLE();
      a93 := JTF_VARCHAR2_TABLE_100();
      a94 := JTF_VARCHAR2_TABLE_100();
      a95 := JTF_NUMBER_TABLE();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_VARCHAR2_TABLE_300();
      a98 := JTF_DATE_TABLE();
      a99 := JTF_NUMBER_TABLE();
      a100 := JTF_NUMBER_TABLE();
      a101 := JTF_DATE_TABLE();
      a102 := JTF_DATE_TABLE();
      a103 := JTF_NUMBER_TABLE();
      a104 := JTF_VARCHAR2_TABLE_100();
      a105 := JTF_NUMBER_TABLE();
      a106 := JTF_VARCHAR2_TABLE_100();
      a107 := JTF_VARCHAR2_TABLE_100();
      a108 := JTF_VARCHAR2_TABLE_100();
      a109 := JTF_NUMBER_TABLE();
      a110 := JTF_NUMBER_TABLE();
      a111 := JTF_NUMBER_TABLE();
      a112 := JTF_NUMBER_TABLE();
      a113 := JTF_NUMBER_TABLE();
      a114 := JTF_NUMBER_TABLE();
      a115 := JTF_NUMBER_TABLE();
      a116 := JTF_NUMBER_TABLE();
      a117 := JTF_NUMBER_TABLE();
      a118 := JTF_NUMBER_TABLE();
      a119 := JTF_NUMBER_TABLE();
      a120 := JTF_VARCHAR2_TABLE_100();
      a121 := JTF_VARCHAR2_TABLE_100();
      a122 := JTF_VARCHAR2_TABLE_100();
      a123 := JTF_VARCHAR2_TABLE_100();
      a124 := JTF_VARCHAR2_TABLE_100();
      a125 := JTF_NUMBER_TABLE();
      a126 := JTF_VARCHAR2_TABLE_100();
      a127 := JTF_VARCHAR2_TABLE_100();
      a128 := JTF_VARCHAR2_TABLE_100();
      a129 := JTF_VARCHAR2_TABLE_100();
      a130 := JTF_DATE_TABLE();
      a131 := JTF_VARCHAR2_TABLE_100();
      a132 := JTF_DATE_TABLE();
      a133 := JTF_VARCHAR2_TABLE_100();
      a134 := JTF_VARCHAR2_TABLE_2000();
      a135 := JTF_VARCHAR2_TABLE_100();
      a136 := JTF_VARCHAR2_TABLE_100();
      a137 := JTF_VARCHAR2_TABLE_100();
      a138 := JTF_VARCHAR2_TABLE_100();
      a139 := JTF_VARCHAR2_TABLE_100();
      a140 := JTF_VARCHAR2_TABLE_100();
      a141 := JTF_NUMBER_TABLE();
      a142 := JTF_VARCHAR2_TABLE_100();
      a143 := JTF_NUMBER_TABLE();
      a144 := JTF_VARCHAR2_TABLE_100();
      a145 := JTF_VARCHAR2_TABLE_100();
      a146 := JTF_VARCHAR2_TABLE_100();
      a147 := JTF_VARCHAR2_TABLE_100();
      a148 := JTF_DATE_TABLE();
      a149 := JTF_VARCHAR2_TABLE_100();
      a150 := JTF_DATE_TABLE();
      a151 := JTF_VARCHAR2_TABLE_2000();
      a152 := JTF_VARCHAR2_TABLE_2000();
      a153 := JTF_VARCHAR2_TABLE_100();
      a154 := JTF_DATE_TABLE();
      a155 := JTF_NUMBER_TABLE();
      a156 := JTF_VARCHAR2_TABLE_100();
      a157 := JTF_NUMBER_TABLE();
      a158 := JTF_VARCHAR2_TABLE_100();
      a159 := JTF_VARCHAR2_TABLE_100();
      a160 := JTF_VARCHAR2_TABLE_100();
      a161 := JTF_VARCHAR2_TABLE_100();
      a162 := JTF_NUMBER_TABLE();
      a163 := JTF_NUMBER_TABLE();
      a164 := JTF_NUMBER_TABLE();
      a165 := JTF_NUMBER_TABLE();
      a166 := JTF_VARCHAR2_TABLE_100();
      a167 := JTF_NUMBER_TABLE();
      a168 := JTF_NUMBER_TABLE();
      a169 := JTF_NUMBER_TABLE();
      a170 := JTF_NUMBER_TABLE();
      a171 := JTF_NUMBER_TABLE();
      a172 := JTF_VARCHAR2_TABLE_100();
      a173 := JTF_NUMBER_TABLE();
      a174 := JTF_VARCHAR2_TABLE_100();
      a175 := JTF_VARCHAR2_TABLE_100();
      a176 := JTF_VARCHAR2_TABLE_100();
      a177 := JTF_DATE_TABLE();
      a178 := JTF_NUMBER_TABLE();
      a179 := JTF_VARCHAR2_TABLE_300();
      a180 := JTF_VARCHAR2_TABLE_100();
      a181 := JTF_VARCHAR2_TABLE_100();
      a182 := JTF_VARCHAR2_TABLE_100();
      a183 := JTF_NUMBER_TABLE();
      a184 := JTF_NUMBER_TABLE();
      a185 := JTF_NUMBER_TABLE();
      a186 := JTF_VARCHAR2_TABLE_100();
      a187 := JTF_VARCHAR2_TABLE_100();
      a188 := JTF_VARCHAR2_TABLE_100();
      a189 := JTF_NUMBER_TABLE();
      a190 := JTF_NUMBER_TABLE();
      a191 := JTF_NUMBER_TABLE();
      a192 := JTF_VARCHAR2_TABLE_300();
      a193 := JTF_DATE_TABLE();
      a194 := JTF_VARCHAR2_TABLE_300();
      a195 := JTF_DATE_TABLE();
      a196 := JTF_NUMBER_TABLE();
      a197 := JTF_NUMBER_TABLE();
      a198 := JTF_NUMBER_TABLE();
      a199 := JTF_NUMBER_TABLE();
      a200 := JTF_NUMBER_TABLE();
      a201 := JTF_NUMBER_TABLE();
      a202 := JTF_NUMBER_TABLE();
      a203 := JTF_NUMBER_TABLE();
      a204 := JTF_NUMBER_TABLE();
      a205 := JTF_NUMBER_TABLE();
      a206 := JTF_NUMBER_TABLE();
      a207 := JTF_NUMBER_TABLE();
      a208 := JTF_NUMBER_TABLE();
      a209 := JTF_NUMBER_TABLE();
      a210 := JTF_NUMBER_TABLE();
      a211 := JTF_NUMBER_TABLE();
      a212 := JTF_NUMBER_TABLE();
      a213 := JTF_NUMBER_TABLE();
      a214 := JTF_VARCHAR2_TABLE_100();
      a215 := JTF_NUMBER_TABLE();
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
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        a146.extend(t.count);
        a147.extend(t.count);
        a148.extend(t.count);
        a149.extend(t.count);
        a150.extend(t.count);
        a151.extend(t.count);
        a152.extend(t.count);
        a153.extend(t.count);
        a154.extend(t.count);
        a155.extend(t.count);
        a156.extend(t.count);
        a157.extend(t.count);
        a158.extend(t.count);
        a159.extend(t.count);
        a160.extend(t.count);
        a161.extend(t.count);
        a162.extend(t.count);
        a163.extend(t.count);
        a164.extend(t.count);
        a165.extend(t.count);
        a166.extend(t.count);
        a167.extend(t.count);
        a168.extend(t.count);
        a169.extend(t.count);
        a170.extend(t.count);
        a171.extend(t.count);
        a172.extend(t.count);
        a173.extend(t.count);
        a174.extend(t.count);
        a175.extend(t.count);
        a176.extend(t.count);
        a177.extend(t.count);
        a178.extend(t.count);
        a179.extend(t.count);
        a180.extend(t.count);
        a181.extend(t.count);
        a182.extend(t.count);
        a183.extend(t.count);
        a184.extend(t.count);
        a185.extend(t.count);
        a186.extend(t.count);
        a187.extend(t.count);
        a188.extend(t.count);
        a189.extend(t.count);
        a190.extend(t.count);
        a191.extend(t.count);
        a192.extend(t.count);
        a193.extend(t.count);
        a194.extend(t.count);
        a195.extend(t.count);
        a196.extend(t.count);
        a197.extend(t.count);
        a198.extend(t.count);
        a199.extend(t.count);
        a200.extend(t.count);
        a201.extend(t.count);
        a202.extend(t.count);
        a203.extend(t.count);
        a204.extend(t.count);
        a205.extend(t.count);
        a206.extend(t.count);
        a207.extend(t.count);
        a208.extend(t.count);
        a209.extend(t.count);
        a210.extend(t.count);
        a211.extend(t.count);
        a212.extend(t.count);
        a213.extend(t.count);
        a214.extend(t.count);
        a215.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).accounting_rule_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).agreement_id);
          a2(indx) := t(ddindx).attribute1;
          a3(indx) := t(ddindx).attribute10;
          a4(indx) := t(ddindx).attribute11;
          a5(indx) := t(ddindx).attribute12;
          a6(indx) := t(ddindx).attribute13;
          a7(indx) := t(ddindx).attribute14;
          a8(indx) := t(ddindx).attribute15;
          a9(indx) := t(ddindx).attribute16;
          a10(indx) := t(ddindx).attribute17;
          a11(indx) := t(ddindx).attribute18;
          a12(indx) := t(ddindx).attribute19;
          a13(indx) := t(ddindx).attribute2;
          a14(indx) := t(ddindx).attribute20;
          a15(indx) := t(ddindx).attribute3;
          a16(indx) := t(ddindx).attribute4;
          a17(indx) := t(ddindx).attribute5;
          a18(indx) := t(ddindx).attribute6;
          a19(indx) := t(ddindx).attribute7;
          a20(indx) := t(ddindx).attribute8;
          a21(indx) := t(ddindx).attribute9;
          a22(indx) := t(ddindx).booked_flag;
          a23(indx) := t(ddindx).cancelled_flag;
          a24(indx) := t(ddindx).context;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).conversion_rate);
          a26(indx) := t(ddindx).conversion_rate_date;
          a27(indx) := t(ddindx).conversion_type_code;
          a28(indx) := t(ddindx).customer_preference_set_code;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a30(indx) := t(ddindx).creation_date;
          a31(indx) := t(ddindx).cust_po_number;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_contact_id);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_org_id);
          a34(indx) := t(ddindx).demand_class_code;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).earliest_schedule_limit);
          a36(indx) := t(ddindx).expiration_date;
          a37(indx) := t(ddindx).fob_point_code;
          a38(indx) := t(ddindx).freight_carrier_code;
          a39(indx) := t(ddindx).freight_terms_code;
          a40(indx) := t(ddindx).global_attribute1;
          a41(indx) := t(ddindx).global_attribute10;
          a42(indx) := t(ddindx).global_attribute11;
          a43(indx) := t(ddindx).global_attribute12;
          a44(indx) := t(ddindx).global_attribute13;
          a45(indx) := t(ddindx).global_attribute14;
          a46(indx) := t(ddindx).global_attribute15;
          a47(indx) := t(ddindx).global_attribute16;
          a48(indx) := t(ddindx).global_attribute17;
          a49(indx) := t(ddindx).global_attribute18;
          a50(indx) := t(ddindx).global_attribute19;
          a51(indx) := t(ddindx).global_attribute2;
          a52(indx) := t(ddindx).global_attribute20;
          a53(indx) := t(ddindx).global_attribute3;
          a54(indx) := t(ddindx).global_attribute4;
          a55(indx) := t(ddindx).global_attribute5;
          a56(indx) := t(ddindx).global_attribute6;
          a57(indx) := t(ddindx).global_attribute7;
          a58(indx) := t(ddindx).global_attribute8;
          a59(indx) := t(ddindx).global_attribute9;
          a60(indx) := t(ddindx).global_attribute_category;
          a61(indx) := t(ddindx).tp_context;
          a62(indx) := t(ddindx).tp_attribute1;
          a63(indx) := t(ddindx).tp_attribute2;
          a64(indx) := t(ddindx).tp_attribute3;
          a65(indx) := t(ddindx).tp_attribute4;
          a66(indx) := t(ddindx).tp_attribute5;
          a67(indx) := t(ddindx).tp_attribute6;
          a68(indx) := t(ddindx).tp_attribute7;
          a69(indx) := t(ddindx).tp_attribute8;
          a70(indx) := t(ddindx).tp_attribute9;
          a71(indx) := t(ddindx).tp_attribute10;
          a72(indx) := t(ddindx).tp_attribute11;
          a73(indx) := t(ddindx).tp_attribute12;
          a74(indx) := t(ddindx).tp_attribute13;
          a75(indx) := t(ddindx).tp_attribute14;
          a76(indx) := t(ddindx).tp_attribute15;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a78(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_contact_id);
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_org_id);
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).invoicing_rule_id);
          a81(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a82(indx) := t(ddindx).last_update_date;
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a84(indx) := rosetta_g_miss_num_map(t(ddindx).latest_schedule_limit);
          a85(indx) := t(ddindx).open_flag;
          a86(indx) := t(ddindx).order_category_code;
          a87(indx) := t(ddindx).ordered_date;
          a88(indx) := t(ddindx).order_date_type_code;
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).order_number);
          a90(indx) := rosetta_g_miss_num_map(t(ddindx).order_source_id);
          a91(indx) := rosetta_g_miss_num_map(t(ddindx).order_type_id);
          a92(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a93(indx) := t(ddindx).orig_sys_document_ref;
          a94(indx) := t(ddindx).partial_shipments_allowed;
          a95(indx) := rosetta_g_miss_num_map(t(ddindx).payment_term_id);
          a96(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_id);
          a97(indx) := t(ddindx).price_request_code;
          a98(indx) := t(ddindx).pricing_date;
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a100(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a101(indx) := t(ddindx).program_update_date;
          a102(indx) := t(ddindx).request_date;
          a103(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a104(indx) := t(ddindx).return_reason_code;
          a105(indx) := rosetta_g_miss_num_map(t(ddindx).salesrep_id);
          a106(indx) := t(ddindx).sales_channel_code;
          a107(indx) := t(ddindx).shipment_priority_code;
          a108(indx) := t(ddindx).shipping_method_code;
          a109(indx) := rosetta_g_miss_num_map(t(ddindx).ship_from_org_id);
          a110(indx) := rosetta_g_miss_num_map(t(ddindx).ship_tolerance_above);
          a111(indx) := rosetta_g_miss_num_map(t(ddindx).ship_tolerance_below);
          a112(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_contact_id);
          a113(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_org_id);
          a114(indx) := rosetta_g_miss_num_map(t(ddindx).sold_from_org_id);
          a115(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_contact_id);
          a116(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_org_id);
          a117(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_phone_id);
          a118(indx) := rosetta_g_miss_num_map(t(ddindx).source_document_id);
          a119(indx) := rosetta_g_miss_num_map(t(ddindx).source_document_type_id);
          a120(indx) := t(ddindx).tax_exempt_flag;
          a121(indx) := t(ddindx).tax_exempt_number;
          a122(indx) := t(ddindx).tax_exempt_reason_code;
          a123(indx) := t(ddindx).tax_point_code;
          a124(indx) := t(ddindx).transactional_curr_code;
          a125(indx) := rosetta_g_miss_num_map(t(ddindx).version_number);
          a126(indx) := t(ddindx).return_status;
          a127(indx) := t(ddindx).db_flag;
          a128(indx) := t(ddindx).operation;
          a129(indx) := t(ddindx).first_ack_code;
          a130(indx) := t(ddindx).first_ack_date;
          a131(indx) := t(ddindx).last_ack_code;
          a132(indx) := t(ddindx).last_ack_date;
          a133(indx) := t(ddindx).change_reason;
          a134(indx) := t(ddindx).change_comments;
          a135(indx) := t(ddindx).change_sequence;
          a136(indx) := t(ddindx).change_request_code;
          a137(indx) := t(ddindx).ready_flag;
          a138(indx) := t(ddindx).status_flag;
          a139(indx) := t(ddindx).force_apply_flag;
          a140(indx) := t(ddindx).drop_ship_flag;
          a141(indx) := rosetta_g_miss_num_map(t(ddindx).customer_payment_term_id);
          a142(indx) := t(ddindx).payment_type_code;
          a143(indx) := rosetta_g_miss_num_map(t(ddindx).payment_amount);
          a144(indx) := t(ddindx).check_number;
          a145(indx) := t(ddindx).credit_card_code;
          a146(indx) := t(ddindx).credit_card_holder_name;
          a147(indx) := t(ddindx).credit_card_number;
          a148(indx) := t(ddindx).credit_card_expiration_date;
          a149(indx) := t(ddindx).credit_card_approval_code;
          a150(indx) := t(ddindx).credit_card_approval_date;
          a151(indx) := t(ddindx).shipping_instructions;
          a152(indx) := t(ddindx).packing_instructions;
          a153(indx) := t(ddindx).flow_status_code;
          a154(indx) := t(ddindx).booked_date;
          a155(indx) := rosetta_g_miss_num_map(t(ddindx).marketing_source_code_id);
          a156(indx) := t(ddindx).upgraded_flag;
          a157(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          a158(indx) := t(ddindx).ship_to_edi_location_code;
          a159(indx) := t(ddindx).sold_to_edi_location_code;
          a160(indx) := t(ddindx).bill_to_edi_location_code;
          a161(indx) := t(ddindx).ship_from_edi_location_code;
          a162(indx) := rosetta_g_miss_num_map(t(ddindx).ship_from_address_id);
          a163(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_address_id);
          a164(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_address_id);
          a165(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_address_id);
          a166(indx) := t(ddindx).ship_to_address_code;
          a167(indx) := rosetta_g_miss_num_map(t(ddindx).xml_message_id);
          a168(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_customer_id);
          a169(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_customer_id);
          a170(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_customer_id);
          a171(indx) := rosetta_g_miss_num_map(t(ddindx).accounting_rule_duration);
          a172(indx) := t(ddindx).xml_transaction_type_code;
          a173(indx) := rosetta_g_miss_num_map(t(ddindx).blanket_number);
          a174(indx) := t(ddindx).line_set_name;
          a175(indx) := t(ddindx).fulfillment_set_name;
          a176(indx) := t(ddindx).default_fulfillment_set;
          a177(indx) := t(ddindx).quote_date;
          a178(indx) := rosetta_g_miss_num_map(t(ddindx).quote_number);
          a179(indx) := t(ddindx).sales_document_name;
          a180(indx) := t(ddindx).transaction_phase_code;
          a181(indx) := t(ddindx).user_status_code;
          a182(indx) := t(ddindx).draft_submitted_flag;
          a183(indx) := rosetta_g_miss_num_map(t(ddindx).source_document_version_number);
          a184(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_site_use_id);
          a185(indx) := rosetta_g_miss_num_map(t(ddindx).minisite_id);
          a186(indx) := t(ddindx).ib_owner;
          a187(indx) := t(ddindx).ib_installed_at_location;
          a188(indx) := t(ddindx).ib_current_location;
          a189(indx) := rosetta_g_miss_num_map(t(ddindx).end_customer_id);
          a190(indx) := rosetta_g_miss_num_map(t(ddindx).end_customer_contact_id);
          a191(indx) := rosetta_g_miss_num_map(t(ddindx).end_customer_site_use_id);
          a192(indx) := t(ddindx).supplier_signature;
          a193(indx) := t(ddindx).supplier_signature_date;
          a194(indx) := t(ddindx).customer_signature;
          a195(indx) := t(ddindx).customer_signature_date;
          a196(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_party_id);
          a197(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_org_contact_id);
          a198(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_party_id);
          a199(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_party_site_id);
          a200(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_party_site_use_id);
          a201(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_party_id);
          a202(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_party_site_id);
          a203(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_party_site_use_id);
          a204(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_id);
          a205(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_site_id);
          a206(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_site_use_id);
          a207(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_customer_party_id);
          a208(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_customer_party_id);
          a209(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_customer_party_id);
          a210(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_org_contact_id);
          a211(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_org_contact_id);
          a212(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_org_contact_id);
          a213(indx) := rosetta_g_miss_num_map(t(ddindx).contract_template_id);
          a214(indx) := t(ddindx).contract_source_doc_type_code;
          a215(indx) := rosetta_g_miss_num_map(t(ddindx).contract_source_document_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_400
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
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
    , a29 JTF_VARCHAR2_TABLE_400
    , a30 JTF_VARCHAR2_TABLE_300
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
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_400
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_400
    , a82 JTF_VARCHAR2_TABLE_400
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_VARCHAR2_TABLE_100
    , a95 JTF_VARCHAR2_TABLE_400
    , a96 JTF_VARCHAR2_TABLE_400
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_VARCHAR2_TABLE_100
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_NUMBER_TABLE
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_400
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_400
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_VARCHAR2_TABLE_400
    , a109 JTF_VARCHAR2_TABLE_100
    , a110 JTF_VARCHAR2_TABLE_400
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    , a114 JTF_VARCHAR2_TABLE_300
    , a115 JTF_VARCHAR2_TABLE_300
    , a116 JTF_VARCHAR2_TABLE_300
    , a117 JTF_VARCHAR2_TABLE_300
    , a118 JTF_VARCHAR2_TABLE_300
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_300
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_300
    , a124 JTF_VARCHAR2_TABLE_400
    , a125 JTF_VARCHAR2_TABLE_100
    , a126 JTF_VARCHAR2_TABLE_400
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_300
    , a129 JTF_VARCHAR2_TABLE_300
    , a130 JTF_VARCHAR2_TABLE_300
    , a131 JTF_VARCHAR2_TABLE_300
    , a132 JTF_VARCHAR2_TABLE_300
    , a133 JTF_VARCHAR2_TABLE_300
    , a134 JTF_VARCHAR2_TABLE_300
    , a135 JTF_VARCHAR2_TABLE_300
    , a136 JTF_VARCHAR2_TABLE_300
    , a137 JTF_VARCHAR2_TABLE_300
    , a138 JTF_VARCHAR2_TABLE_300
    , a139 JTF_VARCHAR2_TABLE_300
    , a140 JTF_VARCHAR2_TABLE_300
    , a141 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).accounting_rule := a0(indx);
          t(ddindx).agreement := a1(indx);
          t(ddindx).conversion_type := a2(indx);
          t(ddindx).deliver_to_address1 := a3(indx);
          t(ddindx).deliver_to_address2 := a4(indx);
          t(ddindx).deliver_to_address3 := a5(indx);
          t(ddindx).deliver_to_address4 := a6(indx);
          t(ddindx).deliver_to_contact := a7(indx);
          t(ddindx).deliver_to_location := a8(indx);
          t(ddindx).deliver_to_org := a9(indx);
          t(ddindx).deliver_to_state := a10(indx);
          t(ddindx).deliver_to_city := a11(indx);
          t(ddindx).deliver_to_zip := a12(indx);
          t(ddindx).deliver_to_country := a13(indx);
          t(ddindx).deliver_to_county := a14(indx);
          t(ddindx).deliver_to_province := a15(indx);
          t(ddindx).demand_class := a16(indx);
          t(ddindx).fob_point := a17(indx);
          t(ddindx).freight_terms := a18(indx);
          t(ddindx).invoice_to_address1 := a19(indx);
          t(ddindx).invoice_to_address2 := a20(indx);
          t(ddindx).invoice_to_address3 := a21(indx);
          t(ddindx).invoice_to_address4 := a22(indx);
          t(ddindx).invoice_to_state := a23(indx);
          t(ddindx).invoice_to_city := a24(indx);
          t(ddindx).invoice_to_zip := a25(indx);
          t(ddindx).invoice_to_country := a26(indx);
          t(ddindx).invoice_to_county := a27(indx);
          t(ddindx).invoice_to_province := a28(indx);
          t(ddindx).invoice_to_contact := a29(indx);
          t(ddindx).invoice_to_contact_first_name := a30(indx);
          t(ddindx).invoice_to_contact_last_name := a31(indx);
          t(ddindx).invoice_to_location := a32(indx);
          t(ddindx).invoice_to_org := a33(indx);
          t(ddindx).invoicing_rule := a34(indx);
          t(ddindx).order_source := a35(indx);
          t(ddindx).order_type := a36(indx);
          t(ddindx).payment_term := a37(indx);
          t(ddindx).price_list := a38(indx);
          t(ddindx).return_reason := a39(indx);
          t(ddindx).salesrep := a40(indx);
          t(ddindx).shipment_priority := a41(indx);
          t(ddindx).ship_from_address1 := a42(indx);
          t(ddindx).ship_from_address2 := a43(indx);
          t(ddindx).ship_from_address3 := a44(indx);
          t(ddindx).ship_from_address4 := a45(indx);
          t(ddindx).ship_from_location := a46(indx);
          t(ddindx).ship_from_city := a47(indx);
          t(ddindx).ship_from_postal_code := a48(indx);
          t(ddindx).ship_from_country := a49(indx);
          t(ddindx).ship_from_region1 := a50(indx);
          t(ddindx).ship_from_region2 := a51(indx);
          t(ddindx).ship_from_region3 := a52(indx);
          t(ddindx).ship_from_org := a53(indx);
          t(ddindx).sold_to_address1 := a54(indx);
          t(ddindx).sold_to_address2 := a55(indx);
          t(ddindx).sold_to_address3 := a56(indx);
          t(ddindx).sold_to_address4 := a57(indx);
          t(ddindx).sold_to_state := a58(indx);
          t(ddindx).sold_to_country := a59(indx);
          t(ddindx).sold_to_zip := a60(indx);
          t(ddindx).sold_to_county := a61(indx);
          t(ddindx).sold_to_province := a62(indx);
          t(ddindx).sold_to_city := a63(indx);
          t(ddindx).sold_to_contact_last_name := a64(indx);
          t(ddindx).sold_to_contact_first_name := a65(indx);
          t(ddindx).ship_to_address1 := a66(indx);
          t(ddindx).ship_to_address2 := a67(indx);
          t(ddindx).ship_to_address3 := a68(indx);
          t(ddindx).ship_to_address4 := a69(indx);
          t(ddindx).ship_to_state := a70(indx);
          t(ddindx).ship_to_country := a71(indx);
          t(ddindx).ship_to_zip := a72(indx);
          t(ddindx).ship_to_county := a73(indx);
          t(ddindx).ship_to_province := a74(indx);
          t(ddindx).ship_to_city := a75(indx);
          t(ddindx).ship_to_contact := a76(indx);
          t(ddindx).ship_to_contact_last_name := a77(indx);
          t(ddindx).ship_to_contact_first_name := a78(indx);
          t(ddindx).ship_to_location := a79(indx);
          t(ddindx).ship_to_org := a80(indx);
          t(ddindx).sold_to_contact := a81(indx);
          t(ddindx).sold_to_org := a82(indx);
          t(ddindx).sold_from_org := a83(indx);
          t(ddindx).tax_exempt := a84(indx);
          t(ddindx).tax_exempt_reason := a85(indx);
          t(ddindx).tax_point := a86(indx);
          t(ddindx).customer_payment_term := a87(indx);
          t(ddindx).payment_type := a88(indx);
          t(ddindx).credit_card := a89(indx);
          t(ddindx).status := a90(indx);
          t(ddindx).freight_carrier := a91(indx);
          t(ddindx).shipping_method := a92(indx);
          t(ddindx).order_date_type := a93(indx);
          t(ddindx).customer_number := a94(indx);
          t(ddindx).ship_to_customer_name := a95(indx);
          t(ddindx).invoice_to_customer_name := a96(indx);
          t(ddindx).sales_channel := a97(indx);
          t(ddindx).ship_to_customer_number := a98(indx);
          t(ddindx).invoice_to_customer_number := a99(indx);
          t(ddindx).ship_to_customer_id := rosetta_g_miss_num_map(a100(indx));
          t(ddindx).invoice_to_customer_id := rosetta_g_miss_num_map(a101(indx));
          t(ddindx).deliver_to_customer_id := rosetta_g_miss_num_map(a102(indx));
          t(ddindx).deliver_to_customer_number := a103(indx);
          t(ddindx).deliver_to_customer_name := a104(indx);
          t(ddindx).deliver_to_customer_number_oi := a105(indx);
          t(ddindx).deliver_to_customer_name_oi := a106(indx);
          t(ddindx).ship_to_customer_number_oi := a107(indx);
          t(ddindx).ship_to_customer_name_oi := a108(indx);
          t(ddindx).invoice_to_customer_number_oi := a109(indx);
          t(ddindx).invoice_to_customer_name_oi := a110(indx);
          t(ddindx).user_status := a111(indx);
          t(ddindx).transaction_phase := a112(indx);
          t(ddindx).sold_to_location_address1 := a113(indx);
          t(ddindx).sold_to_location_address2 := a114(indx);
          t(ddindx).sold_to_location_address3 := a115(indx);
          t(ddindx).sold_to_location_address4 := a116(indx);
          t(ddindx).sold_to_location := a117(indx);
          t(ddindx).sold_to_location_city := a118(indx);
          t(ddindx).sold_to_location_state := a119(indx);
          t(ddindx).sold_to_location_postal := a120(indx);
          t(ddindx).sold_to_location_country := a121(indx);
          t(ddindx).sold_to_location_county := a122(indx);
          t(ddindx).sold_to_location_province := a123(indx);
          t(ddindx).end_customer_name := a124(indx);
          t(ddindx).end_customer_number := a125(indx);
          t(ddindx).end_customer_contact := a126(indx);
          t(ddindx).end_cust_contact_last_name := a127(indx);
          t(ddindx).end_cust_contact_first_name := a128(indx);
          t(ddindx).end_customer_site_address1 := a129(indx);
          t(ddindx).end_customer_site_address2 := a130(indx);
          t(ddindx).end_customer_site_address3 := a131(indx);
          t(ddindx).end_customer_site_address4 := a132(indx);
          t(ddindx).end_customer_site_state := a133(indx);
          t(ddindx).end_customer_site_country := a134(indx);
          t(ddindx).end_customer_site_location := a135(indx);
          t(ddindx).end_customer_site_zip := a136(indx);
          t(ddindx).end_customer_site_county := a137(indx);
          t(ddindx).end_customer_site_province := a138(indx);
          t(ddindx).end_customer_site_city := a139(indx);
          t(ddindx).end_customer_site_postal_code := a140(indx);
          t(ddindx).blanket_agreement_name := a141(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t oe_order_pub.header_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a100 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a101 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a112 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a113 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a114 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a138 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a141 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_400();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
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
    a29 := JTF_VARCHAR2_TABLE_400();
    a30 := JTF_VARCHAR2_TABLE_300();
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
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_300();
    a73 := JTF_VARCHAR2_TABLE_300();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_300();
    a76 := JTF_VARCHAR2_TABLE_400();
    a77 := JTF_VARCHAR2_TABLE_300();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_400();
    a82 := JTF_VARCHAR2_TABLE_400();
    a83 := JTF_VARCHAR2_TABLE_300();
    a84 := JTF_VARCHAR2_TABLE_300();
    a85 := JTF_VARCHAR2_TABLE_300();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_VARCHAR2_TABLE_300();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_100();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_VARCHAR2_TABLE_100();
    a94 := JTF_VARCHAR2_TABLE_100();
    a95 := JTF_VARCHAR2_TABLE_400();
    a96 := JTF_VARCHAR2_TABLE_400();
    a97 := JTF_VARCHAR2_TABLE_100();
    a98 := JTF_VARCHAR2_TABLE_100();
    a99 := JTF_VARCHAR2_TABLE_100();
    a100 := JTF_NUMBER_TABLE();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_NUMBER_TABLE();
    a103 := JTF_VARCHAR2_TABLE_100();
    a104 := JTF_VARCHAR2_TABLE_400();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_VARCHAR2_TABLE_400();
    a107 := JTF_VARCHAR2_TABLE_100();
    a108 := JTF_VARCHAR2_TABLE_400();
    a109 := JTF_VARCHAR2_TABLE_100();
    a110 := JTF_VARCHAR2_TABLE_400();
    a111 := JTF_VARCHAR2_TABLE_300();
    a112 := JTF_VARCHAR2_TABLE_300();
    a113 := JTF_VARCHAR2_TABLE_300();
    a114 := JTF_VARCHAR2_TABLE_300();
    a115 := JTF_VARCHAR2_TABLE_300();
    a116 := JTF_VARCHAR2_TABLE_300();
    a117 := JTF_VARCHAR2_TABLE_300();
    a118 := JTF_VARCHAR2_TABLE_300();
    a119 := JTF_VARCHAR2_TABLE_300();
    a120 := JTF_VARCHAR2_TABLE_300();
    a121 := JTF_VARCHAR2_TABLE_300();
    a122 := JTF_VARCHAR2_TABLE_300();
    a123 := JTF_VARCHAR2_TABLE_300();
    a124 := JTF_VARCHAR2_TABLE_400();
    a125 := JTF_VARCHAR2_TABLE_100();
    a126 := JTF_VARCHAR2_TABLE_400();
    a127 := JTF_VARCHAR2_TABLE_300();
    a128 := JTF_VARCHAR2_TABLE_300();
    a129 := JTF_VARCHAR2_TABLE_300();
    a130 := JTF_VARCHAR2_TABLE_300();
    a131 := JTF_VARCHAR2_TABLE_300();
    a132 := JTF_VARCHAR2_TABLE_300();
    a133 := JTF_VARCHAR2_TABLE_300();
    a134 := JTF_VARCHAR2_TABLE_300();
    a135 := JTF_VARCHAR2_TABLE_300();
    a136 := JTF_VARCHAR2_TABLE_300();
    a137 := JTF_VARCHAR2_TABLE_300();
    a138 := JTF_VARCHAR2_TABLE_300();
    a139 := JTF_VARCHAR2_TABLE_300();
    a140 := JTF_VARCHAR2_TABLE_300();
    a141 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_400();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
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
      a29 := JTF_VARCHAR2_TABLE_400();
      a30 := JTF_VARCHAR2_TABLE_300();
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
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_300();
      a73 := JTF_VARCHAR2_TABLE_300();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_300();
      a76 := JTF_VARCHAR2_TABLE_400();
      a77 := JTF_VARCHAR2_TABLE_300();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_400();
      a82 := JTF_VARCHAR2_TABLE_400();
      a83 := JTF_VARCHAR2_TABLE_300();
      a84 := JTF_VARCHAR2_TABLE_300();
      a85 := JTF_VARCHAR2_TABLE_300();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_VARCHAR2_TABLE_300();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_100();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_VARCHAR2_TABLE_100();
      a94 := JTF_VARCHAR2_TABLE_100();
      a95 := JTF_VARCHAR2_TABLE_400();
      a96 := JTF_VARCHAR2_TABLE_400();
      a97 := JTF_VARCHAR2_TABLE_100();
      a98 := JTF_VARCHAR2_TABLE_100();
      a99 := JTF_VARCHAR2_TABLE_100();
      a100 := JTF_NUMBER_TABLE();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_NUMBER_TABLE();
      a103 := JTF_VARCHAR2_TABLE_100();
      a104 := JTF_VARCHAR2_TABLE_400();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_VARCHAR2_TABLE_400();
      a107 := JTF_VARCHAR2_TABLE_100();
      a108 := JTF_VARCHAR2_TABLE_400();
      a109 := JTF_VARCHAR2_TABLE_100();
      a110 := JTF_VARCHAR2_TABLE_400();
      a111 := JTF_VARCHAR2_TABLE_300();
      a112 := JTF_VARCHAR2_TABLE_300();
      a113 := JTF_VARCHAR2_TABLE_300();
      a114 := JTF_VARCHAR2_TABLE_300();
      a115 := JTF_VARCHAR2_TABLE_300();
      a116 := JTF_VARCHAR2_TABLE_300();
      a117 := JTF_VARCHAR2_TABLE_300();
      a118 := JTF_VARCHAR2_TABLE_300();
      a119 := JTF_VARCHAR2_TABLE_300();
      a120 := JTF_VARCHAR2_TABLE_300();
      a121 := JTF_VARCHAR2_TABLE_300();
      a122 := JTF_VARCHAR2_TABLE_300();
      a123 := JTF_VARCHAR2_TABLE_300();
      a124 := JTF_VARCHAR2_TABLE_400();
      a125 := JTF_VARCHAR2_TABLE_100();
      a126 := JTF_VARCHAR2_TABLE_400();
      a127 := JTF_VARCHAR2_TABLE_300();
      a128 := JTF_VARCHAR2_TABLE_300();
      a129 := JTF_VARCHAR2_TABLE_300();
      a130 := JTF_VARCHAR2_TABLE_300();
      a131 := JTF_VARCHAR2_TABLE_300();
      a132 := JTF_VARCHAR2_TABLE_300();
      a133 := JTF_VARCHAR2_TABLE_300();
      a134 := JTF_VARCHAR2_TABLE_300();
      a135 := JTF_VARCHAR2_TABLE_300();
      a136 := JTF_VARCHAR2_TABLE_300();
      a137 := JTF_VARCHAR2_TABLE_300();
      a138 := JTF_VARCHAR2_TABLE_300();
      a139 := JTF_VARCHAR2_TABLE_300();
      a140 := JTF_VARCHAR2_TABLE_300();
      a141 := JTF_VARCHAR2_TABLE_400();
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
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).accounting_rule;
          a1(indx) := t(ddindx).agreement;
          a2(indx) := t(ddindx).conversion_type;
          a3(indx) := t(ddindx).deliver_to_address1;
          a4(indx) := t(ddindx).deliver_to_address2;
          a5(indx) := t(ddindx).deliver_to_address3;
          a6(indx) := t(ddindx).deliver_to_address4;
          a7(indx) := t(ddindx).deliver_to_contact;
          a8(indx) := t(ddindx).deliver_to_location;
          a9(indx) := t(ddindx).deliver_to_org;
          a10(indx) := t(ddindx).deliver_to_state;
          a11(indx) := t(ddindx).deliver_to_city;
          a12(indx) := t(ddindx).deliver_to_zip;
          a13(indx) := t(ddindx).deliver_to_country;
          a14(indx) := t(ddindx).deliver_to_county;
          a15(indx) := t(ddindx).deliver_to_province;
          a16(indx) := t(ddindx).demand_class;
          a17(indx) := t(ddindx).fob_point;
          a18(indx) := t(ddindx).freight_terms;
          a19(indx) := t(ddindx).invoice_to_address1;
          a20(indx) := t(ddindx).invoice_to_address2;
          a21(indx) := t(ddindx).invoice_to_address3;
          a22(indx) := t(ddindx).invoice_to_address4;
          a23(indx) := t(ddindx).invoice_to_state;
          a24(indx) := t(ddindx).invoice_to_city;
          a25(indx) := t(ddindx).invoice_to_zip;
          a26(indx) := t(ddindx).invoice_to_country;
          a27(indx) := t(ddindx).invoice_to_county;
          a28(indx) := t(ddindx).invoice_to_province;
          a29(indx) := t(ddindx).invoice_to_contact;
          a30(indx) := t(ddindx).invoice_to_contact_first_name;
          a31(indx) := t(ddindx).invoice_to_contact_last_name;
          a32(indx) := t(ddindx).invoice_to_location;
          a33(indx) := t(ddindx).invoice_to_org;
          a34(indx) := t(ddindx).invoicing_rule;
          a35(indx) := t(ddindx).order_source;
          a36(indx) := t(ddindx).order_type;
          a37(indx) := t(ddindx).payment_term;
          a38(indx) := t(ddindx).price_list;
          a39(indx) := t(ddindx).return_reason;
          a40(indx) := t(ddindx).salesrep;
          a41(indx) := t(ddindx).shipment_priority;
          a42(indx) := t(ddindx).ship_from_address1;
          a43(indx) := t(ddindx).ship_from_address2;
          a44(indx) := t(ddindx).ship_from_address3;
          a45(indx) := t(ddindx).ship_from_address4;
          a46(indx) := t(ddindx).ship_from_location;
          a47(indx) := t(ddindx).ship_from_city;
          a48(indx) := t(ddindx).ship_from_postal_code;
          a49(indx) := t(ddindx).ship_from_country;
          a50(indx) := t(ddindx).ship_from_region1;
          a51(indx) := t(ddindx).ship_from_region2;
          a52(indx) := t(ddindx).ship_from_region3;
          a53(indx) := t(ddindx).ship_from_org;
          a54(indx) := t(ddindx).sold_to_address1;
          a55(indx) := t(ddindx).sold_to_address2;
          a56(indx) := t(ddindx).sold_to_address3;
          a57(indx) := t(ddindx).sold_to_address4;
          a58(indx) := t(ddindx).sold_to_state;
          a59(indx) := t(ddindx).sold_to_country;
          a60(indx) := t(ddindx).sold_to_zip;
          a61(indx) := t(ddindx).sold_to_county;
          a62(indx) := t(ddindx).sold_to_province;
          a63(indx) := t(ddindx).sold_to_city;
          a64(indx) := t(ddindx).sold_to_contact_last_name;
          a65(indx) := t(ddindx).sold_to_contact_first_name;
          a66(indx) := t(ddindx).ship_to_address1;
          a67(indx) := t(ddindx).ship_to_address2;
          a68(indx) := t(ddindx).ship_to_address3;
          a69(indx) := t(ddindx).ship_to_address4;
          a70(indx) := t(ddindx).ship_to_state;
          a71(indx) := t(ddindx).ship_to_country;
          a72(indx) := t(ddindx).ship_to_zip;
          a73(indx) := t(ddindx).ship_to_county;
          a74(indx) := t(ddindx).ship_to_province;
          a75(indx) := t(ddindx).ship_to_city;
          a76(indx) := t(ddindx).ship_to_contact;
          a77(indx) := t(ddindx).ship_to_contact_last_name;
          a78(indx) := t(ddindx).ship_to_contact_first_name;
          a79(indx) := t(ddindx).ship_to_location;
          a80(indx) := t(ddindx).ship_to_org;
          a81(indx) := t(ddindx).sold_to_contact;
          a82(indx) := t(ddindx).sold_to_org;
          a83(indx) := t(ddindx).sold_from_org;
          a84(indx) := t(ddindx).tax_exempt;
          a85(indx) := t(ddindx).tax_exempt_reason;
          a86(indx) := t(ddindx).tax_point;
          a87(indx) := t(ddindx).customer_payment_term;
          a88(indx) := t(ddindx).payment_type;
          a89(indx) := t(ddindx).credit_card;
          a90(indx) := t(ddindx).status;
          a91(indx) := t(ddindx).freight_carrier;
          a92(indx) := t(ddindx).shipping_method;
          a93(indx) := t(ddindx).order_date_type;
          a94(indx) := t(ddindx).customer_number;
          a95(indx) := t(ddindx).ship_to_customer_name;
          a96(indx) := t(ddindx).invoice_to_customer_name;
          a97(indx) := t(ddindx).sales_channel;
          a98(indx) := t(ddindx).ship_to_customer_number;
          a99(indx) := t(ddindx).invoice_to_customer_number;
          a100(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_customer_id);
          a101(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_customer_id);
          a102(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_customer_id);
          a103(indx) := t(ddindx).deliver_to_customer_number;
          a104(indx) := t(ddindx).deliver_to_customer_name;
          a105(indx) := t(ddindx).deliver_to_customer_number_oi;
          a106(indx) := t(ddindx).deliver_to_customer_name_oi;
          a107(indx) := t(ddindx).ship_to_customer_number_oi;
          a108(indx) := t(ddindx).ship_to_customer_name_oi;
          a109(indx) := t(ddindx).invoice_to_customer_number_oi;
          a110(indx) := t(ddindx).invoice_to_customer_name_oi;
          a111(indx) := t(ddindx).user_status;
          a112(indx) := t(ddindx).transaction_phase;
          a113(indx) := t(ddindx).sold_to_location_address1;
          a114(indx) := t(ddindx).sold_to_location_address2;
          a115(indx) := t(ddindx).sold_to_location_address3;
          a116(indx) := t(ddindx).sold_to_location_address4;
          a117(indx) := t(ddindx).sold_to_location;
          a118(indx) := t(ddindx).sold_to_location_city;
          a119(indx) := t(ddindx).sold_to_location_state;
          a120(indx) := t(ddindx).sold_to_location_postal;
          a121(indx) := t(ddindx).sold_to_location_country;
          a122(indx) := t(ddindx).sold_to_location_county;
          a123(indx) := t(ddindx).sold_to_location_province;
          a124(indx) := t(ddindx).end_customer_name;
          a125(indx) := t(ddindx).end_customer_number;
          a126(indx) := t(ddindx).end_customer_contact;
          a127(indx) := t(ddindx).end_cust_contact_last_name;
          a128(indx) := t(ddindx).end_cust_contact_first_name;
          a129(indx) := t(ddindx).end_customer_site_address1;
          a130(indx) := t(ddindx).end_customer_site_address2;
          a131(indx) := t(ddindx).end_customer_site_address3;
          a132(indx) := t(ddindx).end_customer_site_address4;
          a133(indx) := t(ddindx).end_customer_site_state;
          a134(indx) := t(ddindx).end_customer_site_country;
          a135(indx) := t(ddindx).end_customer_site_location;
          a136(indx) := t(ddindx).end_customer_site_zip;
          a137(indx) := t(ddindx).end_customer_site_county;
          a138(indx) := t(ddindx).end_customer_site_province;
          a139(indx) := t(ddindx).end_customer_site_city;
          a140(indx) := t(ddindx).end_customer_site_postal_code;
          a141(indx) := t(ddindx).blanket_agreement_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_adj_tbl_type, a0 JTF_VARCHAR2_TABLE_300
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_2000
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_DATE_TABLE
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_DATE_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_200
    , a104 JTF_NUMBER_TABLE
    , a105 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute1 := a0(indx);
          t(ddindx).attribute10 := a1(indx);
          t(ddindx).attribute11 := a2(indx);
          t(ddindx).attribute12 := a3(indx);
          t(ddindx).attribute13 := a4(indx);
          t(ddindx).attribute14 := a5(indx);
          t(ddindx).attribute15 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).automatic_flag := a15(indx);
          t(ddindx).context := a16(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).discount_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).discount_line_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).header_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).price_adjustment_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).return_status := a32(indx);
          t(ddindx).db_flag := a33(indx);
          t(ddindx).operation := a34(indx);
          t(ddindx).orig_sys_discount_ref := a35(indx);
          t(ddindx).change_request_code := a36(indx);
          t(ddindx).status_flag := a37(indx);
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).list_line_type_code := a40(indx);
          t(ddindx).modifier_mechanism_type_code := a41(indx);
          t(ddindx).modified_from := a42(indx);
          t(ddindx).modified_to := a43(indx);
          t(ddindx).updated_flag := a44(indx);
          t(ddindx).update_allowed := a45(indx);
          t(ddindx).applied_flag := a46(indx);
          t(ddindx).change_reason_code := a47(indx);
          t(ddindx).change_reason_text := a48(indx);
          t(ddindx).operand := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).operand_per_pqty := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).arithmetic_operator := a51(indx);
          t(ddindx).cost_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).tax_code := a53(indx);
          t(ddindx).tax_exempt_flag := a54(indx);
          t(ddindx).tax_exempt_number := a55(indx);
          t(ddindx).tax_exempt_reason_code := a56(indx);
          t(ddindx).parent_adjustment_id := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).invoiced_flag := a58(indx);
          t(ddindx).estimated_flag := a59(indx);
          t(ddindx).inc_in_sales_performance := a60(indx);
          t(ddindx).split_action_code := a61(indx);
          t(ddindx).adjusted_amount := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).adjusted_amount_per_pqty := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).pricing_phase_id := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).charge_type_code := a65(indx);
          t(ddindx).charge_subtype_code := a66(indx);
          t(ddindx).list_line_no := a67(indx);
          t(ddindx).source_system_code := a68(indx);
          t(ddindx).benefit_qty := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).benefit_uom_code := a70(indx);
          t(ddindx).print_on_invoice_flag := a71(indx);
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a72(indx));
          t(ddindx).rebate_transaction_type_code := a73(indx);
          t(ddindx).rebate_transaction_reference := a74(indx);
          t(ddindx).rebate_payment_system_code := a75(indx);
          t(ddindx).redeemed_date := rosetta_g_miss_date_in_map(a76(indx));
          t(ddindx).redeemed_flag := a77(indx);
          t(ddindx).accrual_flag := a78(indx);
          t(ddindx).range_break_quantity := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).accrual_conversion_rate := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).pricing_group_sequence := rosetta_g_miss_num_map(a81(indx));
          t(ddindx).modifier_level_code := a82(indx);
          t(ddindx).price_break_type_code := a83(indx);
          t(ddindx).substitution_attribute := a84(indx);
          t(ddindx).proration_type_code := a85(indx);
          t(ddindx).credit_or_charge_flag := a86(indx);
          t(ddindx).include_on_returns_flag := a87(indx);
          t(ddindx).ac_attribute1 := a88(indx);
          t(ddindx).ac_attribute10 := a89(indx);
          t(ddindx).ac_attribute11 := a90(indx);
          t(ddindx).ac_attribute12 := a91(indx);
          t(ddindx).ac_attribute13 := a92(indx);
          t(ddindx).ac_attribute14 := a93(indx);
          t(ddindx).ac_attribute15 := a94(indx);
          t(ddindx).ac_attribute2 := a95(indx);
          t(ddindx).ac_attribute3 := a96(indx);
          t(ddindx).ac_attribute4 := a97(indx);
          t(ddindx).ac_attribute5 := a98(indx);
          t(ddindx).ac_attribute6 := a99(indx);
          t(ddindx).ac_attribute7 := a100(indx);
          t(ddindx).ac_attribute8 := a101(indx);
          t(ddindx).ac_attribute9 := a102(indx);
          t(ddindx).ac_context := a103(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a104(indx));
          t(ddindx).invoiced_amount := rosetta_g_miss_num_map(a105(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t oe_order_pub.header_adj_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a49 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a50 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a52 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a57 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a62 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a63 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a64 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a69 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a72 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a76 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a79 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a80 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a81 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a104 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a105 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_2000();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_DATE_TABLE();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_DATE_TABLE();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_100();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_300();
    a96 := JTF_VARCHAR2_TABLE_300();
    a97 := JTF_VARCHAR2_TABLE_300();
    a98 := JTF_VARCHAR2_TABLE_300();
    a99 := JTF_VARCHAR2_TABLE_300();
    a100 := JTF_VARCHAR2_TABLE_300();
    a101 := JTF_VARCHAR2_TABLE_300();
    a102 := JTF_VARCHAR2_TABLE_300();
    a103 := JTF_VARCHAR2_TABLE_200();
    a104 := JTF_NUMBER_TABLE();
    a105 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_2000();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_DATE_TABLE();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_DATE_TABLE();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_100();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_300();
      a96 := JTF_VARCHAR2_TABLE_300();
      a97 := JTF_VARCHAR2_TABLE_300();
      a98 := JTF_VARCHAR2_TABLE_300();
      a99 := JTF_VARCHAR2_TABLE_300();
      a100 := JTF_VARCHAR2_TABLE_300();
      a101 := JTF_VARCHAR2_TABLE_300();
      a102 := JTF_VARCHAR2_TABLE_300();
      a103 := JTF_VARCHAR2_TABLE_200();
      a104 := JTF_NUMBER_TABLE();
      a105 := JTF_NUMBER_TABLE();
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
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute1;
          a1(indx) := t(ddindx).attribute10;
          a2(indx) := t(ddindx).attribute11;
          a3(indx) := t(ddindx).attribute12;
          a4(indx) := t(ddindx).attribute13;
          a5(indx) := t(ddindx).attribute14;
          a6(indx) := t(ddindx).attribute15;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).automatic_flag;
          a16(indx) := t(ddindx).context;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a18(indx) := t(ddindx).creation_date;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).discount_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).discount_line_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a23(indx) := t(ddindx).last_update_date;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).price_adjustment_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a30(indx) := t(ddindx).program_update_date;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a32(indx) := t(ddindx).return_status;
          a33(indx) := t(ddindx).db_flag;
          a34(indx) := t(ddindx).operation;
          a35(indx) := t(ddindx).orig_sys_discount_ref;
          a36(indx) := t(ddindx).change_request_code;
          a37(indx) := t(ddindx).status_flag;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a40(indx) := t(ddindx).list_line_type_code;
          a41(indx) := t(ddindx).modifier_mechanism_type_code;
          a42(indx) := t(ddindx).modified_from;
          a43(indx) := t(ddindx).modified_to;
          a44(indx) := t(ddindx).updated_flag;
          a45(indx) := t(ddindx).update_allowed;
          a46(indx) := t(ddindx).applied_flag;
          a47(indx) := t(ddindx).change_reason_code;
          a48(indx) := t(ddindx).change_reason_text;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).operand);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).operand_per_pqty);
          a51(indx) := t(ddindx).arithmetic_operator;
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).cost_id);
          a53(indx) := t(ddindx).tax_code;
          a54(indx) := t(ddindx).tax_exempt_flag;
          a55(indx) := t(ddindx).tax_exempt_number;
          a56(indx) := t(ddindx).tax_exempt_reason_code;
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).parent_adjustment_id);
          a58(indx) := t(ddindx).invoiced_flag;
          a59(indx) := t(ddindx).estimated_flag;
          a60(indx) := t(ddindx).inc_in_sales_performance;
          a61(indx) := t(ddindx).split_action_code;
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).adjusted_amount);
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).adjusted_amount_per_pqty);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_phase_id);
          a65(indx) := t(ddindx).charge_type_code;
          a66(indx) := t(ddindx).charge_subtype_code;
          a67(indx) := t(ddindx).list_line_no;
          a68(indx) := t(ddindx).source_system_code;
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_qty);
          a70(indx) := t(ddindx).benefit_uom_code;
          a71(indx) := t(ddindx).print_on_invoice_flag;
          a72(indx) := t(ddindx).expiration_date;
          a73(indx) := t(ddindx).rebate_transaction_type_code;
          a74(indx) := t(ddindx).rebate_transaction_reference;
          a75(indx) := t(ddindx).rebate_payment_system_code;
          a76(indx) := t(ddindx).redeemed_date;
          a77(indx) := t(ddindx).redeemed_flag;
          a78(indx) := t(ddindx).accrual_flag;
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).range_break_quantity);
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).accrual_conversion_rate);
          a81(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_group_sequence);
          a82(indx) := t(ddindx).modifier_level_code;
          a83(indx) := t(ddindx).price_break_type_code;
          a84(indx) := t(ddindx).substitution_attribute;
          a85(indx) := t(ddindx).proration_type_code;
          a86(indx) := t(ddindx).credit_or_charge_flag;
          a87(indx) := t(ddindx).include_on_returns_flag;
          a88(indx) := t(ddindx).ac_attribute1;
          a89(indx) := t(ddindx).ac_attribute10;
          a90(indx) := t(ddindx).ac_attribute11;
          a91(indx) := t(ddindx).ac_attribute12;
          a92(indx) := t(ddindx).ac_attribute13;
          a93(indx) := t(ddindx).ac_attribute14;
          a94(indx) := t(ddindx).ac_attribute15;
          a95(indx) := t(ddindx).ac_attribute2;
          a96(indx) := t(ddindx).ac_attribute3;
          a97(indx) := t(ddindx).ac_attribute4;
          a98(indx) := t(ddindx).ac_attribute5;
          a99(indx) := t(ddindx).ac_attribute6;
          a100(indx) := t(ddindx).ac_attribute7;
          a101(indx) := t(ddindx).ac_attribute8;
          a102(indx) := t(ddindx).ac_attribute9;
          a103(indx) := t(ddindx).ac_context;
          a104(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          a105(indx) := rosetta_g_miss_num_map(t(ddindx).invoiced_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_adj_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).discount := a0(indx);
          t(ddindx).list_name := a1(indx);
          t(ddindx).version_no := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t oe_order_pub.header_adj_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).discount;
          a1(indx) := t(ddindx).list_name;
          a2(indx) := t(ddindx).version_no;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_price_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
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
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
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
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_300
    , a106 JTF_VARCHAR2_TABLE_300
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_300
    , a109 JTF_VARCHAR2_TABLE_300
    , a110 JTF_VARCHAR2_TABLE_300
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_VARCHAR2_TABLE_300
    , a116 JTF_VARCHAR2_TABLE_300
    , a117 JTF_VARCHAR2_TABLE_300
    , a118 JTF_VARCHAR2_TABLE_300
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_300
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_300
    , a124 JTF_VARCHAR2_TABLE_300
    , a125 JTF_VARCHAR2_TABLE_300
    , a126 JTF_VARCHAR2_TABLE_300
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_300
    , a129 JTF_VARCHAR2_TABLE_300
    , a130 JTF_VARCHAR2_TABLE_100
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_VARCHAR2_TABLE_100
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_NUMBER_TABLE
    , a135 JTF_VARCHAR2_TABLE_100
    , a136 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).order_price_attrib_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).header_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).flex_title := a12(indx);
          t(ddindx).pricing_context := a13(indx);
          t(ddindx).pricing_attribute1 := a14(indx);
          t(ddindx).pricing_attribute2 := a15(indx);
          t(ddindx).pricing_attribute3 := a16(indx);
          t(ddindx).pricing_attribute4 := a17(indx);
          t(ddindx).pricing_attribute5 := a18(indx);
          t(ddindx).pricing_attribute6 := a19(indx);
          t(ddindx).pricing_attribute7 := a20(indx);
          t(ddindx).pricing_attribute8 := a21(indx);
          t(ddindx).pricing_attribute9 := a22(indx);
          t(ddindx).pricing_attribute10 := a23(indx);
          t(ddindx).pricing_attribute11 := a24(indx);
          t(ddindx).pricing_attribute12 := a25(indx);
          t(ddindx).pricing_attribute13 := a26(indx);
          t(ddindx).pricing_attribute14 := a27(indx);
          t(ddindx).pricing_attribute15 := a28(indx);
          t(ddindx).pricing_attribute16 := a29(indx);
          t(ddindx).pricing_attribute17 := a30(indx);
          t(ddindx).pricing_attribute18 := a31(indx);
          t(ddindx).pricing_attribute19 := a32(indx);
          t(ddindx).pricing_attribute20 := a33(indx);
          t(ddindx).pricing_attribute21 := a34(indx);
          t(ddindx).pricing_attribute22 := a35(indx);
          t(ddindx).pricing_attribute23 := a36(indx);
          t(ddindx).pricing_attribute24 := a37(indx);
          t(ddindx).pricing_attribute25 := a38(indx);
          t(ddindx).pricing_attribute26 := a39(indx);
          t(ddindx).pricing_attribute27 := a40(indx);
          t(ddindx).pricing_attribute28 := a41(indx);
          t(ddindx).pricing_attribute29 := a42(indx);
          t(ddindx).pricing_attribute30 := a43(indx);
          t(ddindx).pricing_attribute31 := a44(indx);
          t(ddindx).pricing_attribute32 := a45(indx);
          t(ddindx).pricing_attribute33 := a46(indx);
          t(ddindx).pricing_attribute34 := a47(indx);
          t(ddindx).pricing_attribute35 := a48(indx);
          t(ddindx).pricing_attribute36 := a49(indx);
          t(ddindx).pricing_attribute37 := a50(indx);
          t(ddindx).pricing_attribute38 := a51(indx);
          t(ddindx).pricing_attribute39 := a52(indx);
          t(ddindx).pricing_attribute40 := a53(indx);
          t(ddindx).pricing_attribute41 := a54(indx);
          t(ddindx).pricing_attribute42 := a55(indx);
          t(ddindx).pricing_attribute43 := a56(indx);
          t(ddindx).pricing_attribute44 := a57(indx);
          t(ddindx).pricing_attribute45 := a58(indx);
          t(ddindx).pricing_attribute46 := a59(indx);
          t(ddindx).pricing_attribute47 := a60(indx);
          t(ddindx).pricing_attribute48 := a61(indx);
          t(ddindx).pricing_attribute49 := a62(indx);
          t(ddindx).pricing_attribute50 := a63(indx);
          t(ddindx).pricing_attribute51 := a64(indx);
          t(ddindx).pricing_attribute52 := a65(indx);
          t(ddindx).pricing_attribute53 := a66(indx);
          t(ddindx).pricing_attribute54 := a67(indx);
          t(ddindx).pricing_attribute55 := a68(indx);
          t(ddindx).pricing_attribute56 := a69(indx);
          t(ddindx).pricing_attribute57 := a70(indx);
          t(ddindx).pricing_attribute58 := a71(indx);
          t(ddindx).pricing_attribute59 := a72(indx);
          t(ddindx).pricing_attribute60 := a73(indx);
          t(ddindx).pricing_attribute61 := a74(indx);
          t(ddindx).pricing_attribute62 := a75(indx);
          t(ddindx).pricing_attribute63 := a76(indx);
          t(ddindx).pricing_attribute64 := a77(indx);
          t(ddindx).pricing_attribute65 := a78(indx);
          t(ddindx).pricing_attribute66 := a79(indx);
          t(ddindx).pricing_attribute67 := a80(indx);
          t(ddindx).pricing_attribute68 := a81(indx);
          t(ddindx).pricing_attribute69 := a82(indx);
          t(ddindx).pricing_attribute70 := a83(indx);
          t(ddindx).pricing_attribute71 := a84(indx);
          t(ddindx).pricing_attribute72 := a85(indx);
          t(ddindx).pricing_attribute73 := a86(indx);
          t(ddindx).pricing_attribute74 := a87(indx);
          t(ddindx).pricing_attribute75 := a88(indx);
          t(ddindx).pricing_attribute76 := a89(indx);
          t(ddindx).pricing_attribute77 := a90(indx);
          t(ddindx).pricing_attribute78 := a91(indx);
          t(ddindx).pricing_attribute79 := a92(indx);
          t(ddindx).pricing_attribute80 := a93(indx);
          t(ddindx).pricing_attribute81 := a94(indx);
          t(ddindx).pricing_attribute82 := a95(indx);
          t(ddindx).pricing_attribute83 := a96(indx);
          t(ddindx).pricing_attribute84 := a97(indx);
          t(ddindx).pricing_attribute85 := a98(indx);
          t(ddindx).pricing_attribute86 := a99(indx);
          t(ddindx).pricing_attribute87 := a100(indx);
          t(ddindx).pricing_attribute88 := a101(indx);
          t(ddindx).pricing_attribute89 := a102(indx);
          t(ddindx).pricing_attribute90 := a103(indx);
          t(ddindx).pricing_attribute91 := a104(indx);
          t(ddindx).pricing_attribute92 := a105(indx);
          t(ddindx).pricing_attribute93 := a106(indx);
          t(ddindx).pricing_attribute94 := a107(indx);
          t(ddindx).pricing_attribute95 := a108(indx);
          t(ddindx).pricing_attribute96 := a109(indx);
          t(ddindx).pricing_attribute97 := a110(indx);
          t(ddindx).pricing_attribute98 := a111(indx);
          t(ddindx).pricing_attribute99 := a112(indx);
          t(ddindx).pricing_attribute100 := a113(indx);
          t(ddindx).context := a114(indx);
          t(ddindx).attribute1 := a115(indx);
          t(ddindx).attribute2 := a116(indx);
          t(ddindx).attribute3 := a117(indx);
          t(ddindx).attribute4 := a118(indx);
          t(ddindx).attribute5 := a119(indx);
          t(ddindx).attribute6 := a120(indx);
          t(ddindx).attribute7 := a121(indx);
          t(ddindx).attribute8 := a122(indx);
          t(ddindx).attribute9 := a123(indx);
          t(ddindx).attribute10 := a124(indx);
          t(ddindx).attribute11 := a125(indx);
          t(ddindx).attribute12 := a126(indx);
          t(ddindx).attribute13 := a127(indx);
          t(ddindx).attribute14 := a128(indx);
          t(ddindx).attribute15 := a129(indx);
          t(ddindx).override_flag := a130(indx);
          t(ddindx).return_status := a131(indx);
          t(ddindx).db_flag := a132(indx);
          t(ddindx).operation := a133(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a134(indx));
          t(ddindx).orig_sys_atts_ref := a135(indx);
          t(ddindx).change_request_code := a136(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t oe_order_pub.header_price_att_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a112 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a113 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a114 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a134 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
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
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
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
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_300();
    a73 := JTF_VARCHAR2_TABLE_300();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_300();
    a76 := JTF_VARCHAR2_TABLE_300();
    a77 := JTF_VARCHAR2_TABLE_300();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_300();
    a83 := JTF_VARCHAR2_TABLE_300();
    a84 := JTF_VARCHAR2_TABLE_300();
    a85 := JTF_VARCHAR2_TABLE_300();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_VARCHAR2_TABLE_300();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_300();
    a96 := JTF_VARCHAR2_TABLE_300();
    a97 := JTF_VARCHAR2_TABLE_300();
    a98 := JTF_VARCHAR2_TABLE_300();
    a99 := JTF_VARCHAR2_TABLE_300();
    a100 := JTF_VARCHAR2_TABLE_300();
    a101 := JTF_VARCHAR2_TABLE_300();
    a102 := JTF_VARCHAR2_TABLE_300();
    a103 := JTF_VARCHAR2_TABLE_300();
    a104 := JTF_VARCHAR2_TABLE_300();
    a105 := JTF_VARCHAR2_TABLE_300();
    a106 := JTF_VARCHAR2_TABLE_300();
    a107 := JTF_VARCHAR2_TABLE_300();
    a108 := JTF_VARCHAR2_TABLE_300();
    a109 := JTF_VARCHAR2_TABLE_300();
    a110 := JTF_VARCHAR2_TABLE_300();
    a111 := JTF_VARCHAR2_TABLE_300();
    a112 := JTF_VARCHAR2_TABLE_300();
    a113 := JTF_VARCHAR2_TABLE_300();
    a114 := JTF_VARCHAR2_TABLE_100();
    a115 := JTF_VARCHAR2_TABLE_300();
    a116 := JTF_VARCHAR2_TABLE_300();
    a117 := JTF_VARCHAR2_TABLE_300();
    a118 := JTF_VARCHAR2_TABLE_300();
    a119 := JTF_VARCHAR2_TABLE_300();
    a120 := JTF_VARCHAR2_TABLE_300();
    a121 := JTF_VARCHAR2_TABLE_300();
    a122 := JTF_VARCHAR2_TABLE_300();
    a123 := JTF_VARCHAR2_TABLE_300();
    a124 := JTF_VARCHAR2_TABLE_300();
    a125 := JTF_VARCHAR2_TABLE_300();
    a126 := JTF_VARCHAR2_TABLE_300();
    a127 := JTF_VARCHAR2_TABLE_300();
    a128 := JTF_VARCHAR2_TABLE_300();
    a129 := JTF_VARCHAR2_TABLE_300();
    a130 := JTF_VARCHAR2_TABLE_100();
    a131 := JTF_VARCHAR2_TABLE_100();
    a132 := JTF_VARCHAR2_TABLE_100();
    a133 := JTF_VARCHAR2_TABLE_100();
    a134 := JTF_NUMBER_TABLE();
    a135 := JTF_VARCHAR2_TABLE_100();
    a136 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
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
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_300();
      a73 := JTF_VARCHAR2_TABLE_300();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_300();
      a76 := JTF_VARCHAR2_TABLE_300();
      a77 := JTF_VARCHAR2_TABLE_300();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_300();
      a83 := JTF_VARCHAR2_TABLE_300();
      a84 := JTF_VARCHAR2_TABLE_300();
      a85 := JTF_VARCHAR2_TABLE_300();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_VARCHAR2_TABLE_300();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_300();
      a96 := JTF_VARCHAR2_TABLE_300();
      a97 := JTF_VARCHAR2_TABLE_300();
      a98 := JTF_VARCHAR2_TABLE_300();
      a99 := JTF_VARCHAR2_TABLE_300();
      a100 := JTF_VARCHAR2_TABLE_300();
      a101 := JTF_VARCHAR2_TABLE_300();
      a102 := JTF_VARCHAR2_TABLE_300();
      a103 := JTF_VARCHAR2_TABLE_300();
      a104 := JTF_VARCHAR2_TABLE_300();
      a105 := JTF_VARCHAR2_TABLE_300();
      a106 := JTF_VARCHAR2_TABLE_300();
      a107 := JTF_VARCHAR2_TABLE_300();
      a108 := JTF_VARCHAR2_TABLE_300();
      a109 := JTF_VARCHAR2_TABLE_300();
      a110 := JTF_VARCHAR2_TABLE_300();
      a111 := JTF_VARCHAR2_TABLE_300();
      a112 := JTF_VARCHAR2_TABLE_300();
      a113 := JTF_VARCHAR2_TABLE_300();
      a114 := JTF_VARCHAR2_TABLE_100();
      a115 := JTF_VARCHAR2_TABLE_300();
      a116 := JTF_VARCHAR2_TABLE_300();
      a117 := JTF_VARCHAR2_TABLE_300();
      a118 := JTF_VARCHAR2_TABLE_300();
      a119 := JTF_VARCHAR2_TABLE_300();
      a120 := JTF_VARCHAR2_TABLE_300();
      a121 := JTF_VARCHAR2_TABLE_300();
      a122 := JTF_VARCHAR2_TABLE_300();
      a123 := JTF_VARCHAR2_TABLE_300();
      a124 := JTF_VARCHAR2_TABLE_300();
      a125 := JTF_VARCHAR2_TABLE_300();
      a126 := JTF_VARCHAR2_TABLE_300();
      a127 := JTF_VARCHAR2_TABLE_300();
      a128 := JTF_VARCHAR2_TABLE_300();
      a129 := JTF_VARCHAR2_TABLE_300();
      a130 := JTF_VARCHAR2_TABLE_100();
      a131 := JTF_VARCHAR2_TABLE_100();
      a132 := JTF_VARCHAR2_TABLE_100();
      a133 := JTF_VARCHAR2_TABLE_100();
      a134 := JTF_NUMBER_TABLE();
      a135 := JTF_VARCHAR2_TABLE_100();
      a136 := JTF_VARCHAR2_TABLE_100();
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
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).order_price_attrib_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a10(indx) := t(ddindx).program_update_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a12(indx) := t(ddindx).flex_title;
          a13(indx) := t(ddindx).pricing_context;
          a14(indx) := t(ddindx).pricing_attribute1;
          a15(indx) := t(ddindx).pricing_attribute2;
          a16(indx) := t(ddindx).pricing_attribute3;
          a17(indx) := t(ddindx).pricing_attribute4;
          a18(indx) := t(ddindx).pricing_attribute5;
          a19(indx) := t(ddindx).pricing_attribute6;
          a20(indx) := t(ddindx).pricing_attribute7;
          a21(indx) := t(ddindx).pricing_attribute8;
          a22(indx) := t(ddindx).pricing_attribute9;
          a23(indx) := t(ddindx).pricing_attribute10;
          a24(indx) := t(ddindx).pricing_attribute11;
          a25(indx) := t(ddindx).pricing_attribute12;
          a26(indx) := t(ddindx).pricing_attribute13;
          a27(indx) := t(ddindx).pricing_attribute14;
          a28(indx) := t(ddindx).pricing_attribute15;
          a29(indx) := t(ddindx).pricing_attribute16;
          a30(indx) := t(ddindx).pricing_attribute17;
          a31(indx) := t(ddindx).pricing_attribute18;
          a32(indx) := t(ddindx).pricing_attribute19;
          a33(indx) := t(ddindx).pricing_attribute20;
          a34(indx) := t(ddindx).pricing_attribute21;
          a35(indx) := t(ddindx).pricing_attribute22;
          a36(indx) := t(ddindx).pricing_attribute23;
          a37(indx) := t(ddindx).pricing_attribute24;
          a38(indx) := t(ddindx).pricing_attribute25;
          a39(indx) := t(ddindx).pricing_attribute26;
          a40(indx) := t(ddindx).pricing_attribute27;
          a41(indx) := t(ddindx).pricing_attribute28;
          a42(indx) := t(ddindx).pricing_attribute29;
          a43(indx) := t(ddindx).pricing_attribute30;
          a44(indx) := t(ddindx).pricing_attribute31;
          a45(indx) := t(ddindx).pricing_attribute32;
          a46(indx) := t(ddindx).pricing_attribute33;
          a47(indx) := t(ddindx).pricing_attribute34;
          a48(indx) := t(ddindx).pricing_attribute35;
          a49(indx) := t(ddindx).pricing_attribute36;
          a50(indx) := t(ddindx).pricing_attribute37;
          a51(indx) := t(ddindx).pricing_attribute38;
          a52(indx) := t(ddindx).pricing_attribute39;
          a53(indx) := t(ddindx).pricing_attribute40;
          a54(indx) := t(ddindx).pricing_attribute41;
          a55(indx) := t(ddindx).pricing_attribute42;
          a56(indx) := t(ddindx).pricing_attribute43;
          a57(indx) := t(ddindx).pricing_attribute44;
          a58(indx) := t(ddindx).pricing_attribute45;
          a59(indx) := t(ddindx).pricing_attribute46;
          a60(indx) := t(ddindx).pricing_attribute47;
          a61(indx) := t(ddindx).pricing_attribute48;
          a62(indx) := t(ddindx).pricing_attribute49;
          a63(indx) := t(ddindx).pricing_attribute50;
          a64(indx) := t(ddindx).pricing_attribute51;
          a65(indx) := t(ddindx).pricing_attribute52;
          a66(indx) := t(ddindx).pricing_attribute53;
          a67(indx) := t(ddindx).pricing_attribute54;
          a68(indx) := t(ddindx).pricing_attribute55;
          a69(indx) := t(ddindx).pricing_attribute56;
          a70(indx) := t(ddindx).pricing_attribute57;
          a71(indx) := t(ddindx).pricing_attribute58;
          a72(indx) := t(ddindx).pricing_attribute59;
          a73(indx) := t(ddindx).pricing_attribute60;
          a74(indx) := t(ddindx).pricing_attribute61;
          a75(indx) := t(ddindx).pricing_attribute62;
          a76(indx) := t(ddindx).pricing_attribute63;
          a77(indx) := t(ddindx).pricing_attribute64;
          a78(indx) := t(ddindx).pricing_attribute65;
          a79(indx) := t(ddindx).pricing_attribute66;
          a80(indx) := t(ddindx).pricing_attribute67;
          a81(indx) := t(ddindx).pricing_attribute68;
          a82(indx) := t(ddindx).pricing_attribute69;
          a83(indx) := t(ddindx).pricing_attribute70;
          a84(indx) := t(ddindx).pricing_attribute71;
          a85(indx) := t(ddindx).pricing_attribute72;
          a86(indx) := t(ddindx).pricing_attribute73;
          a87(indx) := t(ddindx).pricing_attribute74;
          a88(indx) := t(ddindx).pricing_attribute75;
          a89(indx) := t(ddindx).pricing_attribute76;
          a90(indx) := t(ddindx).pricing_attribute77;
          a91(indx) := t(ddindx).pricing_attribute78;
          a92(indx) := t(ddindx).pricing_attribute79;
          a93(indx) := t(ddindx).pricing_attribute80;
          a94(indx) := t(ddindx).pricing_attribute81;
          a95(indx) := t(ddindx).pricing_attribute82;
          a96(indx) := t(ddindx).pricing_attribute83;
          a97(indx) := t(ddindx).pricing_attribute84;
          a98(indx) := t(ddindx).pricing_attribute85;
          a99(indx) := t(ddindx).pricing_attribute86;
          a100(indx) := t(ddindx).pricing_attribute87;
          a101(indx) := t(ddindx).pricing_attribute88;
          a102(indx) := t(ddindx).pricing_attribute89;
          a103(indx) := t(ddindx).pricing_attribute90;
          a104(indx) := t(ddindx).pricing_attribute91;
          a105(indx) := t(ddindx).pricing_attribute92;
          a106(indx) := t(ddindx).pricing_attribute93;
          a107(indx) := t(ddindx).pricing_attribute94;
          a108(indx) := t(ddindx).pricing_attribute95;
          a109(indx) := t(ddindx).pricing_attribute96;
          a110(indx) := t(ddindx).pricing_attribute97;
          a111(indx) := t(ddindx).pricing_attribute98;
          a112(indx) := t(ddindx).pricing_attribute99;
          a113(indx) := t(ddindx).pricing_attribute100;
          a114(indx) := t(ddindx).context;
          a115(indx) := t(ddindx).attribute1;
          a116(indx) := t(ddindx).attribute2;
          a117(indx) := t(ddindx).attribute3;
          a118(indx) := t(ddindx).attribute4;
          a119(indx) := t(ddindx).attribute5;
          a120(indx) := t(ddindx).attribute6;
          a121(indx) := t(ddindx).attribute7;
          a122(indx) := t(ddindx).attribute8;
          a123(indx) := t(ddindx).attribute9;
          a124(indx) := t(ddindx).attribute10;
          a125(indx) := t(ddindx).attribute11;
          a126(indx) := t(ddindx).attribute12;
          a127(indx) := t(ddindx).attribute13;
          a128(indx) := t(ddindx).attribute14;
          a129(indx) := t(ddindx).attribute15;
          a130(indx) := t(ddindx).override_flag;
          a131(indx) := t(ddindx).return_status;
          a132(indx) := t(ddindx).db_flag;
          a133(indx) := t(ddindx).operation;
          a134(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          a135(indx) := t(ddindx).orig_sys_atts_ref;
          a136(indx) := t(ddindx).change_request_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_adj_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).price_adj_attrib_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).price_adjustment_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).adj_index := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).flex_title := a3(indx);
          t(ddindx).pricing_context := a4(indx);
          t(ddindx).pricing_attribute := a5(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).pricing_attr_value_from := a15(indx);
          t(ddindx).pricing_attr_value_to := a16(indx);
          t(ddindx).comparison_operator := a17(indx);
          t(ddindx).return_status := a18(indx);
          t(ddindx).db_flag := a19(indx);
          t(ddindx).operation := a20(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a21(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t oe_order_pub.header_adj_att_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
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
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).price_adj_attrib_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).price_adjustment_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).adj_index);
          a3(indx) := t(ddindx).flex_title;
          a4(indx) := t(ddindx).pricing_context;
          a5(indx) := t(ddindx).pricing_attribute;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a13(indx) := t(ddindx).program_update_date;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a15(indx) := t(ddindx).pricing_attr_value_from;
          a16(indx) := t(ddindx).pricing_attr_value_to;
          a17(indx) := t(ddindx).comparison_operator;
          a18(indx) := t(ddindx).return_status;
          a19(indx) := t(ddindx).db_flag;
          a20(indx) := t(ddindx).operation;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_adj_assoc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).price_adj_assoc_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).line_index := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).price_adjustment_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).adj_index := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).rltd_price_adj_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).rltd_adj_index := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).return_status := a16(indx);
          t(ddindx).db_flag := a17(indx);
          t(ddindx).operation := a18(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a19(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t oe_order_pub.header_adj_assoc_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).price_adj_assoc_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).line_index);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).price_adjustment_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).adj_index);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).rltd_price_adj_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).rltd_adj_index);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a14(indx) := t(ddindx).program_update_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a16(indx) := t(ddindx).return_status;
          a17(indx) := t(ddindx).db_flag;
          a18(indx) := t(ddindx).operation;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p15(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_scredit_tbl_type, a0 JTF_VARCHAR2_TABLE_300
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_2000
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute1 := a0(indx);
          t(ddindx).attribute10 := a1(indx);
          t(ddindx).attribute11 := a2(indx);
          t(ddindx).attribute12 := a3(indx);
          t(ddindx).attribute13 := a4(indx);
          t(ddindx).attribute14 := a5(indx);
          t(ddindx).attribute15 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).context := a15(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).dw_update_advice_flag := a18(indx);
          t(ddindx).header_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).salesrep_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).sales_credit_type_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).sales_credit_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).wh_update_date := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).return_status := a29(indx);
          t(ddindx).db_flag := a30(indx);
          t(ddindx).operation := a31(indx);
          t(ddindx).orig_sys_credit_ref := a32(indx);
          t(ddindx).change_request_code := a33(indx);
          t(ddindx).status_flag := a34(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).change_reason := a36(indx);
          t(ddindx).change_comments := a37(indx);
          t(ddindx).sales_group_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).sales_group_updated_flag := a39(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t oe_order_pub.header_scredit_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a38 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_2000();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_2000();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute1;
          a1(indx) := t(ddindx).attribute10;
          a2(indx) := t(ddindx).attribute11;
          a3(indx) := t(ddindx).attribute12;
          a4(indx) := t(ddindx).attribute13;
          a5(indx) := t(ddindx).attribute14;
          a6(indx) := t(ddindx).attribute15;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).context;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a17(indx) := t(ddindx).creation_date;
          a18(indx) := t(ddindx).dw_update_advice_flag;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a21(indx) := t(ddindx).last_update_date;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).salesrep_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).sales_credit_type_id);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).sales_credit_id);
          a28(indx) := t(ddindx).wh_update_date;
          a29(indx) := t(ddindx).return_status;
          a30(indx) := t(ddindx).db_flag;
          a31(indx) := t(ddindx).operation;
          a32(indx) := t(ddindx).orig_sys_credit_ref;
          a33(indx) := t(ddindx).change_request_code;
          a34(indx) := t(ddindx).status_flag;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          a36(indx) := t(ddindx).change_reason;
          a37(indx) := t(ddindx).change_comments;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).sales_group_id);
          a39(indx) := t(ddindx).sales_group_updated_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p17(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_scredit_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).salesrep := a0(indx);
          t(ddindx).sales_credit_type := a1(indx);
          t(ddindx).sales_group := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t oe_order_pub.header_scredit_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).salesrep;
          a1(indx) := t(ddindx).sales_credit_type;
          a2(indx) := t(ddindx).sales_group;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p19(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_1000
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_DATE_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_DATE_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_2000
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_DATE_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_NUMBER_TABLE
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_DATE_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_VARCHAR2_TABLE_100
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_DATE_TABLE
    , a93 JTF_NUMBER_TABLE
    , a94 JTF_DATE_TABLE
    , a95 JTF_VARCHAR2_TABLE_100
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_NUMBER_TABLE
    , a99 JTF_VARCHAR2_TABLE_100
    , a100 JTF_DATE_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_NUMBER_TABLE
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_100
    , a105 JTF_NUMBER_TABLE
    , a106 JTF_DATE_TABLE
    , a107 JTF_DATE_TABLE
    , a108 JTF_VARCHAR2_TABLE_100
    , a109 JTF_VARCHAR2_TABLE_100
    , a110 JTF_NUMBER_TABLE
    , a111 JTF_VARCHAR2_TABLE_100
    , a112 JTF_NUMBER_TABLE
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_NUMBER_TABLE
    , a117 JTF_NUMBER_TABLE
    , a118 JTF_VARCHAR2_TABLE_100
    , a119 JTF_VARCHAR2_TABLE_100
    , a120 JTF_NUMBER_TABLE
    , a121 JTF_VARCHAR2_TABLE_100
    , a122 JTF_NUMBER_TABLE
    , a123 JTF_NUMBER_TABLE
    , a124 JTF_NUMBER_TABLE
    , a125 JTF_NUMBER_TABLE
    , a126 JTF_NUMBER_TABLE
    , a127 JTF_NUMBER_TABLE
    , a128 JTF_NUMBER_TABLE
    , a129 JTF_NUMBER_TABLE
    , a130 JTF_VARCHAR2_TABLE_2000
    , a131 JTF_NUMBER_TABLE
    , a132 JTF_NUMBER_TABLE
    , a133 JTF_NUMBER_TABLE
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_VARCHAR2_TABLE_100
    , a138 JTF_DATE_TABLE
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_VARCHAR2_TABLE_100
    , a141 JTF_VARCHAR2_TABLE_100
    , a142 JTF_VARCHAR2_TABLE_100
    , a143 JTF_NUMBER_TABLE
    , a144 JTF_NUMBER_TABLE
    , a145 JTF_VARCHAR2_TABLE_100
    , a146 JTF_NUMBER_TABLE
    , a147 JTF_NUMBER_TABLE
    , a148 JTF_NUMBER_TABLE
    , a149 JTF_NUMBER_TABLE
    , a150 JTF_NUMBER_TABLE
    , a151 JTF_NUMBER_TABLE
    , a152 JTF_NUMBER_TABLE
    , a153 JTF_VARCHAR2_TABLE_100
    , a154 JTF_VARCHAR2_TABLE_100
    , a155 JTF_VARCHAR2_TABLE_100
    , a156 JTF_VARCHAR2_TABLE_100
    , a157 JTF_VARCHAR2_TABLE_100
    , a158 JTF_DATE_TABLE
    , a159 JTF_VARCHAR2_TABLE_100
    , a160 JTF_DATE_TABLE
    , a161 JTF_VARCHAR2_TABLE_100
    , a162 JTF_VARCHAR2_TABLE_2000
    , a163 JTF_VARCHAR2_TABLE_100
    , a164 JTF_VARCHAR2_TABLE_100
    , a165 JTF_VARCHAR2_TABLE_100
    , a166 JTF_NUMBER_TABLE
    , a167 JTF_VARCHAR2_TABLE_100
    , a168 JTF_VARCHAR2_TABLE_100
    , a169 JTF_VARCHAR2_TABLE_100
    , a170 JTF_VARCHAR2_TABLE_100
    , a171 JTF_VARCHAR2_TABLE_100
    , a172 JTF_VARCHAR2_TABLE_100
    , a173 JTF_VARCHAR2_TABLE_100
    , a174 JTF_NUMBER_TABLE
    , a175 JTF_NUMBER_TABLE
    , a176 JTF_NUMBER_TABLE
    , a177 JTF_VARCHAR2_TABLE_100
    , a178 JTF_VARCHAR2_TABLE_2000
    , a179 JTF_VARCHAR2_TABLE_2000
    , a180 JTF_VARCHAR2_TABLE_100
    , a181 JTF_NUMBER_TABLE
    , a182 JTF_VARCHAR2_TABLE_100
    , a183 JTF_VARCHAR2_TABLE_2000
    , a184 JTF_NUMBER_TABLE
    , a185 JTF_VARCHAR2_TABLE_100
    , a186 JTF_DATE_TABLE
    , a187 JTF_DATE_TABLE
    , a188 JTF_VARCHAR2_TABLE_100
    , a189 JTF_NUMBER_TABLE
    , a190 JTF_NUMBER_TABLE
    , a191 JTF_NUMBER_TABLE
    , a192 JTF_NUMBER_TABLE
    , a193 JTF_VARCHAR2_TABLE_100
    , a194 JTF_NUMBER_TABLE
    , a195 JTF_NUMBER_TABLE
    , a196 JTF_NUMBER_TABLE
    , a197 JTF_NUMBER_TABLE
    , a198 JTF_VARCHAR2_TABLE_100
    , a199 JTF_VARCHAR2_TABLE_100
    , a200 JTF_VARCHAR2_TABLE_100
    , a201 JTF_NUMBER_TABLE
    , a202 JTF_NUMBER_TABLE
    , a203 JTF_NUMBER_TABLE
    , a204 JTF_NUMBER_TABLE
    , a205 JTF_VARCHAR2_TABLE_300
    , a206 JTF_VARCHAR2_TABLE_100
    , a207 JTF_VARCHAR2_TABLE_100
    , a208 JTF_VARCHAR2_TABLE_100
    , a209 JTF_VARCHAR2_TABLE_100
    , a210 JTF_VARCHAR2_TABLE_100
    , a211 JTF_VARCHAR2_TABLE_100
    , a212 JTF_NUMBER_TABLE
    , a213 JTF_NUMBER_TABLE
    , a214 JTF_DATE_TABLE
    , a215 JTF_NUMBER_TABLE
    , a216 JTF_VARCHAR2_TABLE_100
    , a217 JTF_NUMBER_TABLE
    , a218 JTF_VARCHAR2_TABLE_100
    , a219 JTF_VARCHAR2_TABLE_100
    , a220 JTF_VARCHAR2_TABLE_100
    , a221 JTF_VARCHAR2_TABLE_100
    , a222 JTF_VARCHAR2_TABLE_100
    , a223 JTF_VARCHAR2_TABLE_100
    , a224 JTF_NUMBER_TABLE
    , a225 JTF_NUMBER_TABLE
    , a226 JTF_NUMBER_TABLE
    , a227 JTF_NUMBER_TABLE
    , a228 JTF_VARCHAR2_TABLE_100
    , a229 JTF_NUMBER_TABLE
    , a230 JTF_VARCHAR2_TABLE_100
    , a231 JTF_NUMBER_TABLE
    , a232 JTF_VARCHAR2_TABLE_2000
    , a233 JTF_VARCHAR2_TABLE_100
    , a234 JTF_NUMBER_TABLE
    , a235 JTF_VARCHAR2_TABLE_100
    , a236 JTF_NUMBER_TABLE
    , a237 JTF_NUMBER_TABLE
    , a238 JTF_NUMBER_TABLE
    , a239 JTF_NUMBER_TABLE
    , a240 JTF_NUMBER_TABLE
    , a241 JTF_VARCHAR2_TABLE_1000
    , a242 JTF_VARCHAR2_TABLE_100
    , a243 JTF_NUMBER_TABLE
    , a244 JTF_NUMBER_TABLE
    , a245 JTF_NUMBER_TABLE
    , a246 JTF_NUMBER_TABLE
    , a247 JTF_VARCHAR2_TABLE_100
    , a248 JTF_VARCHAR2_TABLE_100
    , a249 JTF_DATE_TABLE
    , a250 JTF_VARCHAR2_TABLE_100
    , a251 JTF_NUMBER_TABLE
    , a252 JTF_NUMBER_TABLE
    , a253 JTF_VARCHAR2_TABLE_100
    , a254 JTF_VARCHAR2_TABLE_100
    , a255 JTF_VARCHAR2_TABLE_100
    , a256 JTF_NUMBER_TABLE
    , a257 JTF_NUMBER_TABLE
    , a258 JTF_NUMBER_TABLE
    , a259 JTF_VARCHAR2_TABLE_300
    , a260 JTF_DATE_TABLE
    , a261 JTF_VARCHAR2_TABLE_300
    , a262 JTF_DATE_TABLE
    , a263 JTF_NUMBER_TABLE
    , a264 JTF_NUMBER_TABLE
    , a265 JTF_NUMBER_TABLE
    , a266 JTF_NUMBER_TABLE
    , a267 JTF_NUMBER_TABLE
    , a268 JTF_NUMBER_TABLE
    , a269 JTF_NUMBER_TABLE
    , a270 JTF_NUMBER_TABLE
    , a271 JTF_NUMBER_TABLE
    , a272 JTF_NUMBER_TABLE
    , a273 JTF_NUMBER_TABLE
    , a274 JTF_NUMBER_TABLE
    , a275 JTF_NUMBER_TABLE
    , a276 JTF_NUMBER_TABLE
    , a277 JTF_NUMBER_TABLE
    , a278 JTF_NUMBER_TABLE
    , a279 JTF_NUMBER_TABLE
    , a280 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).accounting_rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).actual_arrival_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).actual_shipment_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).agreement_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).arrival_set_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).ato_line_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).authorized_to_ship_flag := a6(indx);
          t(ddindx).auto_selected_quantity := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).booked_flag := a8(indx);
          t(ddindx).cancelled_flag := a9(indx);
          t(ddindx).cancelled_quantity := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).cancelled_quantity2 := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).commitment_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).component_code := a13(indx);
          t(ddindx).component_number := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).component_sequence_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).config_header_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).config_rev_nbr := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).config_display_sequence := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).configuration_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).context := a20(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).credit_invoice_line_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).customer_dock_code := a24(indx);
          t(ddindx).customer_job := a25(indx);
          t(ddindx).customer_production_line := a26(indx);
          t(ddindx).customer_trx_line_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).cust_model_serial_number := a28(indx);
          t(ddindx).cust_po_number := a29(indx);
          t(ddindx).cust_production_seq_num := a30(indx);
          t(ddindx).delivery_lead_time := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).deliver_to_contact_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).deliver_to_org_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).demand_bucket_type_code := a34(indx);
          t(ddindx).demand_class_code := a35(indx);
          t(ddindx).dep_plan_required_flag := a36(indx);
          t(ddindx).earliest_acceptable_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).end_item_unit_number := a38(indx);
          t(ddindx).explosion_date := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).fob_point_code := a40(indx);
          t(ddindx).freight_carrier_code := a41(indx);
          t(ddindx).freight_terms_code := a42(indx);
          t(ddindx).fulfilled_quantity := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).fulfilled_quantity2 := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).header_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).intermed_ship_to_org_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).intermed_ship_to_contact_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).invoice_interface_status_code := a49(indx);
          t(ddindx).invoice_to_contact_id := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).invoice_to_org_id := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).invoicing_rule_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).ordered_item := a53(indx);
          t(ddindx).item_revision := a54(indx);
          t(ddindx).item_type_code := a55(indx);
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a57(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).latest_acceptable_date := rosetta_g_miss_date_in_map(a59(indx));
          t(ddindx).line_category_code := a60(indx);
          t(ddindx).line_id := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).line_type_id := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).link_to_line_ref := a64(indx);
          t(ddindx).link_to_line_id := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).link_to_line_index := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).model_group_number := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).mfg_component_sequence_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).mfg_lead_time := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).open_flag := a70(indx);
          t(ddindx).option_flag := a71(indx);
          t(ddindx).option_number := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).ordered_quantity := rosetta_g_miss_num_map(a73(indx));
          t(ddindx).ordered_quantity2 := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).order_quantity_uom := a75(indx);
          t(ddindx).ordered_quantity_uom2 := a76(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).orig_sys_document_ref := a78(indx);
          t(ddindx).orig_sys_line_ref := a79(indx);
          t(ddindx).over_ship_reason_code := a80(indx);
          t(ddindx).over_ship_resolved_flag := a81(indx);
          t(ddindx).payment_term_id := rosetta_g_miss_num_map(a82(indx));
          t(ddindx).planning_priority := rosetta_g_miss_num_map(a83(indx));
          t(ddindx).preferred_grade := a84(indx);
          t(ddindx).price_list_id := rosetta_g_miss_num_map(a85(indx));
          t(ddindx).price_request_code := a86(indx);
          t(ddindx).pricing_date := rosetta_g_miss_date_in_map(a87(indx));
          t(ddindx).pricing_quantity := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).pricing_quantity_uom := a89(indx);
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a90(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a91(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a92(indx));
          t(ddindx).project_id := rosetta_g_miss_num_map(a93(indx));
          t(ddindx).promise_date := rosetta_g_miss_date_in_map(a94(indx));
          t(ddindx).re_source_flag := a95(indx);
          t(ddindx).reference_customer_trx_line_id := rosetta_g_miss_num_map(a96(indx));
          t(ddindx).reference_header_id := rosetta_g_miss_num_map(a97(indx));
          t(ddindx).reference_line_id := rosetta_g_miss_num_map(a98(indx));
          t(ddindx).reference_type := a99(indx);
          t(ddindx).request_date := rosetta_g_miss_date_in_map(a100(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a101(indx));
          t(ddindx).reserved_quantity := rosetta_g_miss_num_map(a102(indx));
          t(ddindx).return_reason_code := a103(indx);
          t(ddindx).rla_schedule_type_code := a104(indx);
          t(ddindx).salesrep_id := rosetta_g_miss_num_map(a105(indx));
          t(ddindx).schedule_arrival_date := rosetta_g_miss_date_in_map(a106(indx));
          t(ddindx).schedule_ship_date := rosetta_g_miss_date_in_map(a107(indx));
          t(ddindx).schedule_action_code := a108(indx);
          t(ddindx).schedule_status_code := a109(indx);
          t(ddindx).shipment_number := rosetta_g_miss_num_map(a110(indx));
          t(ddindx).shipment_priority_code := a111(indx);
          t(ddindx).shipped_quantity := rosetta_g_miss_num_map(a112(indx));
          t(ddindx).shipped_quantity2 := rosetta_g_miss_num_map(a113(indx));
          t(ddindx).shipping_interfaced_flag := a114(indx);
          t(ddindx).shipping_method_code := a115(indx);
          t(ddindx).shipping_quantity := rosetta_g_miss_num_map(a116(indx));
          t(ddindx).shipping_quantity2 := rosetta_g_miss_num_map(a117(indx));
          t(ddindx).shipping_quantity_uom := a118(indx);
          t(ddindx).shipping_quantity_uom2 := a119(indx);
          t(ddindx).ship_from_org_id := rosetta_g_miss_num_map(a120(indx));
          t(ddindx).ship_model_complete_flag := a121(indx);
          t(ddindx).ship_set_id := rosetta_g_miss_num_map(a122(indx));
          t(ddindx).fulfillment_set_id := rosetta_g_miss_num_map(a123(indx));
          t(ddindx).ship_tolerance_above := rosetta_g_miss_num_map(a124(indx));
          t(ddindx).ship_tolerance_below := rosetta_g_miss_num_map(a125(indx));
          t(ddindx).ship_to_contact_id := rosetta_g_miss_num_map(a126(indx));
          t(ddindx).ship_to_org_id := rosetta_g_miss_num_map(a127(indx));
          t(ddindx).sold_to_org_id := rosetta_g_miss_num_map(a128(indx));
          t(ddindx).sold_from_org_id := rosetta_g_miss_num_map(a129(indx));
          t(ddindx).sort_order := a130(indx);
          t(ddindx).source_document_id := rosetta_g_miss_num_map(a131(indx));
          t(ddindx).source_document_line_id := rosetta_g_miss_num_map(a132(indx));
          t(ddindx).source_document_type_id := rosetta_g_miss_num_map(a133(indx));
          t(ddindx).source_type_code := a134(indx);
          t(ddindx).split_from_line_id := rosetta_g_miss_num_map(a135(indx));
          t(ddindx).task_id := rosetta_g_miss_num_map(a136(indx));
          t(ddindx).tax_code := a137(indx);
          t(ddindx).tax_date := rosetta_g_miss_date_in_map(a138(indx));
          t(ddindx).tax_exempt_flag := a139(indx);
          t(ddindx).tax_exempt_number := a140(indx);
          t(ddindx).tax_exempt_reason_code := a141(indx);
          t(ddindx).tax_point_code := a142(indx);
          t(ddindx).tax_rate := rosetta_g_miss_num_map(a143(indx));
          t(ddindx).tax_value := rosetta_g_miss_num_map(a144(indx));
          t(ddindx).top_model_line_ref := a145(indx);
          t(ddindx).top_model_line_id := rosetta_g_miss_num_map(a146(indx));
          t(ddindx).top_model_line_index := rosetta_g_miss_num_map(a147(indx));
          t(ddindx).unit_list_price := rosetta_g_miss_num_map(a148(indx));
          t(ddindx).unit_list_price_per_pqty := rosetta_g_miss_num_map(a149(indx));
          t(ddindx).unit_selling_price := rosetta_g_miss_num_map(a150(indx));
          t(ddindx).unit_selling_price_per_pqty := rosetta_g_miss_num_map(a151(indx));
          t(ddindx).veh_cus_item_cum_key_id := rosetta_g_miss_num_map(a152(indx));
          t(ddindx).visible_demand_flag := a153(indx);
          t(ddindx).return_status := a154(indx);
          t(ddindx).db_flag := a155(indx);
          t(ddindx).operation := a156(indx);
          t(ddindx).first_ack_code := a157(indx);
          t(ddindx).first_ack_date := rosetta_g_miss_date_in_map(a158(indx));
          t(ddindx).last_ack_code := a159(indx);
          t(ddindx).last_ack_date := rosetta_g_miss_date_in_map(a160(indx));
          t(ddindx).change_reason := a161(indx);
          t(ddindx).change_comments := a162(indx);
          t(ddindx).arrival_set := a163(indx);
          t(ddindx).ship_set := a164(indx);
          t(ddindx).fulfillment_set := a165(indx);
          t(ddindx).order_source_id := rosetta_g_miss_num_map(a166(indx));
          t(ddindx).orig_sys_shipment_ref := a167(indx);
          t(ddindx).change_sequence := a168(indx);
          t(ddindx).change_request_code := a169(indx);
          t(ddindx).status_flag := a170(indx);
          t(ddindx).drop_ship_flag := a171(indx);
          t(ddindx).customer_line_number := a172(indx);
          t(ddindx).customer_shipment_number := a173(indx);
          t(ddindx).customer_item_net_price := rosetta_g_miss_num_map(a174(indx));
          t(ddindx).customer_payment_term_id := rosetta_g_miss_num_map(a175(indx));
          t(ddindx).ordered_item_id := rosetta_g_miss_num_map(a176(indx));
          t(ddindx).item_identifier_type := a177(indx);
          t(ddindx).shipping_instructions := a178(indx);
          t(ddindx).packing_instructions := a179(indx);
          t(ddindx).calculate_price_flag := a180(indx);
          t(ddindx).invoiced_quantity := rosetta_g_miss_num_map(a181(indx));
          t(ddindx).service_txn_reason_code := a182(indx);
          t(ddindx).service_txn_comments := a183(indx);
          t(ddindx).service_duration := rosetta_g_miss_num_map(a184(indx));
          t(ddindx).service_period := a185(indx);
          t(ddindx).service_start_date := rosetta_g_miss_date_in_map(a186(indx));
          t(ddindx).service_end_date := rosetta_g_miss_date_in_map(a187(indx));
          t(ddindx).service_coterminate_flag := a188(indx);
          t(ddindx).unit_list_percent := rosetta_g_miss_num_map(a189(indx));
          t(ddindx).unit_selling_percent := rosetta_g_miss_num_map(a190(indx));
          t(ddindx).unit_percent_base_price := rosetta_g_miss_num_map(a191(indx));
          t(ddindx).service_number := rosetta_g_miss_num_map(a192(indx));
          t(ddindx).service_reference_type_code := a193(indx);
          t(ddindx).service_reference_line_id := rosetta_g_miss_num_map(a194(indx));
          t(ddindx).service_reference_system_id := rosetta_g_miss_num_map(a195(indx));
          t(ddindx).service_ref_order_number := rosetta_g_miss_num_map(a196(indx));
          t(ddindx).service_ref_line_number := rosetta_g_miss_num_map(a197(indx));
          t(ddindx).service_reference_order := a198(indx);
          t(ddindx).service_reference_line := a199(indx);
          t(ddindx).service_reference_system := a200(indx);
          t(ddindx).service_ref_shipment_number := rosetta_g_miss_num_map(a201(indx));
          t(ddindx).service_ref_option_number := rosetta_g_miss_num_map(a202(indx));
          t(ddindx).service_line_index := rosetta_g_miss_num_map(a203(indx));
          t(ddindx).line_set_id := rosetta_g_miss_num_map(a204(indx));
          t(ddindx).split_by := a205(indx);
          t(ddindx).split_action_code := a206(indx);
          t(ddindx).shippable_flag := a207(indx);
          t(ddindx).model_remnant_flag := a208(indx);
          t(ddindx).flow_status_code := a209(indx);
          t(ddindx).fulfilled_flag := a210(indx);
          t(ddindx).fulfillment_method_code := a211(indx);
          t(ddindx).revenue_amount := rosetta_g_miss_num_map(a212(indx));
          t(ddindx).marketing_source_code_id := rosetta_g_miss_num_map(a213(indx));
          t(ddindx).fulfillment_date := rosetta_g_miss_date_in_map(a214(indx));
          if a215(indx) is null
            then t(ddindx).semi_processed_flag := null;
          elsif a215(indx) = 0
            then t(ddindx).semi_processed_flag := false;
          else t(ddindx).semi_processed_flag := true;
          end if;
          t(ddindx).upgraded_flag := a216(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a217(indx));
          t(ddindx).subinventory := a218(indx);
          t(ddindx).split_from_line_ref := a219(indx);
          t(ddindx).split_from_shipment_ref := a220(indx);
          t(ddindx).ship_to_edi_location_code := a221(indx);
          t(ddindx).bill_to_edi_location_code := a222(indx);
          t(ddindx).ship_from_edi_location_code := a223(indx);
          t(ddindx).ship_from_address_id := rosetta_g_miss_num_map(a224(indx));
          t(ddindx).sold_to_address_id := rosetta_g_miss_num_map(a225(indx));
          t(ddindx).ship_to_address_id := rosetta_g_miss_num_map(a226(indx));
          t(ddindx).invoice_address_id := rosetta_g_miss_num_map(a227(indx));
          t(ddindx).ship_to_address_code := a228(indx);
          t(ddindx).original_inventory_item_id := rosetta_g_miss_num_map(a229(indx));
          t(ddindx).original_item_identifier_type := a230(indx);
          t(ddindx).original_ordered_item_id := rosetta_g_miss_num_map(a231(indx));
          t(ddindx).original_ordered_item := a232(indx);
          t(ddindx).item_substitution_type_code := a233(indx);
          t(ddindx).late_demand_penalty_factor := rosetta_g_miss_num_map(a234(indx));
          t(ddindx).override_atp_date_code := a235(indx);
          t(ddindx).ship_to_customer_id := rosetta_g_miss_num_map(a236(indx));
          t(ddindx).invoice_to_customer_id := rosetta_g_miss_num_map(a237(indx));
          t(ddindx).deliver_to_customer_id := rosetta_g_miss_num_map(a238(indx));
          t(ddindx).accounting_rule_duration := rosetta_g_miss_num_map(a239(indx));
          t(ddindx).unit_cost := rosetta_g_miss_num_map(a240(indx));
          t(ddindx).user_item_description := a241(indx);
          t(ddindx).xml_transaction_type_code := a242(indx);
          t(ddindx).item_relationship_type := rosetta_g_miss_num_map(a243(indx));
          t(ddindx).blanket_number := rosetta_g_miss_num_map(a244(indx));
          t(ddindx).blanket_line_number := rosetta_g_miss_num_map(a245(indx));
          t(ddindx).blanket_version_number := rosetta_g_miss_num_map(a246(indx));
          t(ddindx).cso_response_flag := a247(indx);
          t(ddindx).firm_demand_flag := a248(indx);
          t(ddindx).earliest_ship_date := rosetta_g_miss_date_in_map(a249(indx));
          t(ddindx).transaction_phase_code := a250(indx);
          t(ddindx).source_document_version_number := rosetta_g_miss_num_map(a251(indx));
          t(ddindx).minisite_id := rosetta_g_miss_num_map(a252(indx));
          t(ddindx).ib_owner := a253(indx);
          t(ddindx).ib_installed_at_location := a254(indx);
          t(ddindx).ib_current_location := a255(indx);
          t(ddindx).end_customer_id := rosetta_g_miss_num_map(a256(indx));
          t(ddindx).end_customer_contact_id := rosetta_g_miss_num_map(a257(indx));
          t(ddindx).end_customer_site_use_id := rosetta_g_miss_num_map(a258(indx));
          t(ddindx).supplier_signature := a259(indx);
          t(ddindx).supplier_signature_date := rosetta_g_miss_date_in_map(a260(indx));
          t(ddindx).customer_signature := a261(indx);
          t(ddindx).customer_signature_date := rosetta_g_miss_date_in_map(a262(indx));
          t(ddindx).ship_to_party_id := rosetta_g_miss_num_map(a263(indx));
          t(ddindx).ship_to_party_site_id := rosetta_g_miss_num_map(a264(indx));
          t(ddindx).ship_to_party_site_use_id := rosetta_g_miss_num_map(a265(indx));
          t(ddindx).deliver_to_party_id := rosetta_g_miss_num_map(a266(indx));
          t(ddindx).deliver_to_party_site_id := rosetta_g_miss_num_map(a267(indx));
          t(ddindx).deliver_to_party_site_use_id := rosetta_g_miss_num_map(a268(indx));
          t(ddindx).invoice_to_party_id := rosetta_g_miss_num_map(a269(indx));
          t(ddindx).invoice_to_party_site_id := rosetta_g_miss_num_map(a270(indx));
          t(ddindx).invoice_to_party_site_use_id := rosetta_g_miss_num_map(a271(indx));
          t(ddindx).ship_to_customer_party_id := rosetta_g_miss_num_map(a272(indx));
          t(ddindx).deliver_to_customer_party_id := rosetta_g_miss_num_map(a273(indx));
          t(ddindx).invoice_to_customer_party_id := rosetta_g_miss_num_map(a274(indx));
          t(ddindx).ship_to_org_contact_id := rosetta_g_miss_num_map(a275(indx));
          t(ddindx).deliver_to_org_contact_id := rosetta_g_miss_num_map(a276(indx));
          t(ddindx).invoice_to_org_contact_id := rosetta_g_miss_num_map(a277(indx));
          t(ddindx).retrobill_request_id := rosetta_g_miss_num_map(a278(indx));
          t(ddindx).original_list_price := rosetta_g_miss_num_map(a279(indx));
          t(ddindx).commitment_applied_amount := rosetta_g_miss_num_map(a280(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t oe_order_pub.line_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , a14 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a37 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a39 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a43 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a44 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a45 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a46 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a47 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a48 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a50 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a51 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a52 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a56 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a57 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a58 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a59 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a61 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a62 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a63 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a65 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a66 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a67 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a68 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a69 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a72 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a73 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a74 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a77 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a82 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a83 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a85 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a88 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a90 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a91 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a92 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a93 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a94 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a96 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a97 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a98 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a100 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a101 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a105 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a106 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a107 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a110 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a112 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a113 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a114 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a116 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a117 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a120 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a122 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a123 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a124 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a125 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a126 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a127 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a128 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a129 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a131 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a132 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a133 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a135 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a136 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a138 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a141 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a142 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a143 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a144 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a145 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a146 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a147 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a148 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a149 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a150 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a151 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a152 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a153 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a154 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a155 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a156 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a157 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a158 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a159 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a160 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a161 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a162 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a163 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a164 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a165 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a166 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a167 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a168 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a169 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a170 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a171 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a172 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a173 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a174 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a175 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a176 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a177 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a178 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a179 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a180 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a181 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a182 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a183 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a184 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a185 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a186 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a187 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a188 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a189 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a190 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a191 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a192 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a193 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a194 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a195 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a196 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a197 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a198 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a199 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a200 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a201 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a202 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a203 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a204 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a205 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a206 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a207 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a208 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a209 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a210 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a211 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a212 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a213 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a214 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a215 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a216 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a217 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a218 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a219 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a220 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a221 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a222 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a223 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a224 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a225 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a226 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a227 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a228 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a229 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a230 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a231 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a232 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a233 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a234 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a235 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a236 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a237 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a238 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a239 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a240 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a241 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , a242 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a243 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a244 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a245 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a246 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a247 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a248 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a249 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a250 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a251 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a252 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a253 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a254 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a255 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a256 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a257 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a258 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a259 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a260 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a261 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a262 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a263 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a264 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a265 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a266 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a267 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a268 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a269 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a270 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a271 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a272 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a273 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a274 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a275 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a276 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a277 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a278 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a279 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a280 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_1000();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_2000();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_DATE_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_NUMBER_TABLE();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_DATE_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_VARCHAR2_TABLE_100();
    a90 := JTF_NUMBER_TABLE();
    a91 := JTF_NUMBER_TABLE();
    a92 := JTF_DATE_TABLE();
    a93 := JTF_NUMBER_TABLE();
    a94 := JTF_DATE_TABLE();
    a95 := JTF_VARCHAR2_TABLE_100();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_NUMBER_TABLE();
    a98 := JTF_NUMBER_TABLE();
    a99 := JTF_VARCHAR2_TABLE_100();
    a100 := JTF_DATE_TABLE();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_NUMBER_TABLE();
    a103 := JTF_VARCHAR2_TABLE_100();
    a104 := JTF_VARCHAR2_TABLE_100();
    a105 := JTF_NUMBER_TABLE();
    a106 := JTF_DATE_TABLE();
    a107 := JTF_DATE_TABLE();
    a108 := JTF_VARCHAR2_TABLE_100();
    a109 := JTF_VARCHAR2_TABLE_100();
    a110 := JTF_NUMBER_TABLE();
    a111 := JTF_VARCHAR2_TABLE_100();
    a112 := JTF_NUMBER_TABLE();
    a113 := JTF_NUMBER_TABLE();
    a114 := JTF_VARCHAR2_TABLE_100();
    a115 := JTF_VARCHAR2_TABLE_100();
    a116 := JTF_NUMBER_TABLE();
    a117 := JTF_NUMBER_TABLE();
    a118 := JTF_VARCHAR2_TABLE_100();
    a119 := JTF_VARCHAR2_TABLE_100();
    a120 := JTF_NUMBER_TABLE();
    a121 := JTF_VARCHAR2_TABLE_100();
    a122 := JTF_NUMBER_TABLE();
    a123 := JTF_NUMBER_TABLE();
    a124 := JTF_NUMBER_TABLE();
    a125 := JTF_NUMBER_TABLE();
    a126 := JTF_NUMBER_TABLE();
    a127 := JTF_NUMBER_TABLE();
    a128 := JTF_NUMBER_TABLE();
    a129 := JTF_NUMBER_TABLE();
    a130 := JTF_VARCHAR2_TABLE_2000();
    a131 := JTF_NUMBER_TABLE();
    a132 := JTF_NUMBER_TABLE();
    a133 := JTF_NUMBER_TABLE();
    a134 := JTF_VARCHAR2_TABLE_100();
    a135 := JTF_NUMBER_TABLE();
    a136 := JTF_NUMBER_TABLE();
    a137 := JTF_VARCHAR2_TABLE_100();
    a138 := JTF_DATE_TABLE();
    a139 := JTF_VARCHAR2_TABLE_100();
    a140 := JTF_VARCHAR2_TABLE_100();
    a141 := JTF_VARCHAR2_TABLE_100();
    a142 := JTF_VARCHAR2_TABLE_100();
    a143 := JTF_NUMBER_TABLE();
    a144 := JTF_NUMBER_TABLE();
    a145 := JTF_VARCHAR2_TABLE_100();
    a146 := JTF_NUMBER_TABLE();
    a147 := JTF_NUMBER_TABLE();
    a148 := JTF_NUMBER_TABLE();
    a149 := JTF_NUMBER_TABLE();
    a150 := JTF_NUMBER_TABLE();
    a151 := JTF_NUMBER_TABLE();
    a152 := JTF_NUMBER_TABLE();
    a153 := JTF_VARCHAR2_TABLE_100();
    a154 := JTF_VARCHAR2_TABLE_100();
    a155 := JTF_VARCHAR2_TABLE_100();
    a156 := JTF_VARCHAR2_TABLE_100();
    a157 := JTF_VARCHAR2_TABLE_100();
    a158 := JTF_DATE_TABLE();
    a159 := JTF_VARCHAR2_TABLE_100();
    a160 := JTF_DATE_TABLE();
    a161 := JTF_VARCHAR2_TABLE_100();
    a162 := JTF_VARCHAR2_TABLE_2000();
    a163 := JTF_VARCHAR2_TABLE_100();
    a164 := JTF_VARCHAR2_TABLE_100();
    a165 := JTF_VARCHAR2_TABLE_100();
    a166 := JTF_NUMBER_TABLE();
    a167 := JTF_VARCHAR2_TABLE_100();
    a168 := JTF_VARCHAR2_TABLE_100();
    a169 := JTF_VARCHAR2_TABLE_100();
    a170 := JTF_VARCHAR2_TABLE_100();
    a171 := JTF_VARCHAR2_TABLE_100();
    a172 := JTF_VARCHAR2_TABLE_100();
    a173 := JTF_VARCHAR2_TABLE_100();
    a174 := JTF_NUMBER_TABLE();
    a175 := JTF_NUMBER_TABLE();
    a176 := JTF_NUMBER_TABLE();
    a177 := JTF_VARCHAR2_TABLE_100();
    a178 := JTF_VARCHAR2_TABLE_2000();
    a179 := JTF_VARCHAR2_TABLE_2000();
    a180 := JTF_VARCHAR2_TABLE_100();
    a181 := JTF_NUMBER_TABLE();
    a182 := JTF_VARCHAR2_TABLE_100();
    a183 := JTF_VARCHAR2_TABLE_2000();
    a184 := JTF_NUMBER_TABLE();
    a185 := JTF_VARCHAR2_TABLE_100();
    a186 := JTF_DATE_TABLE();
    a187 := JTF_DATE_TABLE();
    a188 := JTF_VARCHAR2_TABLE_100();
    a189 := JTF_NUMBER_TABLE();
    a190 := JTF_NUMBER_TABLE();
    a191 := JTF_NUMBER_TABLE();
    a192 := JTF_NUMBER_TABLE();
    a193 := JTF_VARCHAR2_TABLE_100();
    a194 := JTF_NUMBER_TABLE();
    a195 := JTF_NUMBER_TABLE();
    a196 := JTF_NUMBER_TABLE();
    a197 := JTF_NUMBER_TABLE();
    a198 := JTF_VARCHAR2_TABLE_100();
    a199 := JTF_VARCHAR2_TABLE_100();
    a200 := JTF_VARCHAR2_TABLE_100();
    a201 := JTF_NUMBER_TABLE();
    a202 := JTF_NUMBER_TABLE();
    a203 := JTF_NUMBER_TABLE();
    a204 := JTF_NUMBER_TABLE();
    a205 := JTF_VARCHAR2_TABLE_300();
    a206 := JTF_VARCHAR2_TABLE_100();
    a207 := JTF_VARCHAR2_TABLE_100();
    a208 := JTF_VARCHAR2_TABLE_100();
    a209 := JTF_VARCHAR2_TABLE_100();
    a210 := JTF_VARCHAR2_TABLE_100();
    a211 := JTF_VARCHAR2_TABLE_100();
    a212 := JTF_NUMBER_TABLE();
    a213 := JTF_NUMBER_TABLE();
    a214 := JTF_DATE_TABLE();
    a215 := JTF_NUMBER_TABLE();
    a216 := JTF_VARCHAR2_TABLE_100();
    a217 := JTF_NUMBER_TABLE();
    a218 := JTF_VARCHAR2_TABLE_100();
    a219 := JTF_VARCHAR2_TABLE_100();
    a220 := JTF_VARCHAR2_TABLE_100();
    a221 := JTF_VARCHAR2_TABLE_100();
    a222 := JTF_VARCHAR2_TABLE_100();
    a223 := JTF_VARCHAR2_TABLE_100();
    a224 := JTF_NUMBER_TABLE();
    a225 := JTF_NUMBER_TABLE();
    a226 := JTF_NUMBER_TABLE();
    a227 := JTF_NUMBER_TABLE();
    a228 := JTF_VARCHAR2_TABLE_100();
    a229 := JTF_NUMBER_TABLE();
    a230 := JTF_VARCHAR2_TABLE_100();
    a231 := JTF_NUMBER_TABLE();
    a232 := JTF_VARCHAR2_TABLE_2000();
    a233 := JTF_VARCHAR2_TABLE_100();
    a234 := JTF_NUMBER_TABLE();
    a235 := JTF_VARCHAR2_TABLE_100();
    a236 := JTF_NUMBER_TABLE();
    a237 := JTF_NUMBER_TABLE();
    a238 := JTF_NUMBER_TABLE();
    a239 := JTF_NUMBER_TABLE();
    a240 := JTF_NUMBER_TABLE();
    a241 := JTF_VARCHAR2_TABLE_1000();
    a242 := JTF_VARCHAR2_TABLE_100();
    a243 := JTF_NUMBER_TABLE();
    a244 := JTF_NUMBER_TABLE();
    a245 := JTF_NUMBER_TABLE();
    a246 := JTF_NUMBER_TABLE();
    a247 := JTF_VARCHAR2_TABLE_100();
    a248 := JTF_VARCHAR2_TABLE_100();
    a249 := JTF_DATE_TABLE();
    a250 := JTF_VARCHAR2_TABLE_100();
    a251 := JTF_NUMBER_TABLE();
    a252 := JTF_NUMBER_TABLE();
    a253 := JTF_VARCHAR2_TABLE_100();
    a254 := JTF_VARCHAR2_TABLE_100();
    a255 := JTF_VARCHAR2_TABLE_100();
    a256 := JTF_NUMBER_TABLE();
    a257 := JTF_NUMBER_TABLE();
    a258 := JTF_NUMBER_TABLE();
    a259 := JTF_VARCHAR2_TABLE_300();
    a260 := JTF_DATE_TABLE();
    a261 := JTF_VARCHAR2_TABLE_300();
    a262 := JTF_DATE_TABLE();
    a263 := JTF_NUMBER_TABLE();
    a264 := JTF_NUMBER_TABLE();
    a265 := JTF_NUMBER_TABLE();
    a266 := JTF_NUMBER_TABLE();
    a267 := JTF_NUMBER_TABLE();
    a268 := JTF_NUMBER_TABLE();
    a269 := JTF_NUMBER_TABLE();
    a270 := JTF_NUMBER_TABLE();
    a271 := JTF_NUMBER_TABLE();
    a272 := JTF_NUMBER_TABLE();
    a273 := JTF_NUMBER_TABLE();
    a274 := JTF_NUMBER_TABLE();
    a275 := JTF_NUMBER_TABLE();
    a276 := JTF_NUMBER_TABLE();
    a277 := JTF_NUMBER_TABLE();
    a278 := JTF_NUMBER_TABLE();
    a279 := JTF_NUMBER_TABLE();
    a280 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_1000();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_2000();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_DATE_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_NUMBER_TABLE();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_DATE_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_VARCHAR2_TABLE_100();
      a90 := JTF_NUMBER_TABLE();
      a91 := JTF_NUMBER_TABLE();
      a92 := JTF_DATE_TABLE();
      a93 := JTF_NUMBER_TABLE();
      a94 := JTF_DATE_TABLE();
      a95 := JTF_VARCHAR2_TABLE_100();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_NUMBER_TABLE();
      a98 := JTF_NUMBER_TABLE();
      a99 := JTF_VARCHAR2_TABLE_100();
      a100 := JTF_DATE_TABLE();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_NUMBER_TABLE();
      a103 := JTF_VARCHAR2_TABLE_100();
      a104 := JTF_VARCHAR2_TABLE_100();
      a105 := JTF_NUMBER_TABLE();
      a106 := JTF_DATE_TABLE();
      a107 := JTF_DATE_TABLE();
      a108 := JTF_VARCHAR2_TABLE_100();
      a109 := JTF_VARCHAR2_TABLE_100();
      a110 := JTF_NUMBER_TABLE();
      a111 := JTF_VARCHAR2_TABLE_100();
      a112 := JTF_NUMBER_TABLE();
      a113 := JTF_NUMBER_TABLE();
      a114 := JTF_VARCHAR2_TABLE_100();
      a115 := JTF_VARCHAR2_TABLE_100();
      a116 := JTF_NUMBER_TABLE();
      a117 := JTF_NUMBER_TABLE();
      a118 := JTF_VARCHAR2_TABLE_100();
      a119 := JTF_VARCHAR2_TABLE_100();
      a120 := JTF_NUMBER_TABLE();
      a121 := JTF_VARCHAR2_TABLE_100();
      a122 := JTF_NUMBER_TABLE();
      a123 := JTF_NUMBER_TABLE();
      a124 := JTF_NUMBER_TABLE();
      a125 := JTF_NUMBER_TABLE();
      a126 := JTF_NUMBER_TABLE();
      a127 := JTF_NUMBER_TABLE();
      a128 := JTF_NUMBER_TABLE();
      a129 := JTF_NUMBER_TABLE();
      a130 := JTF_VARCHAR2_TABLE_2000();
      a131 := JTF_NUMBER_TABLE();
      a132 := JTF_NUMBER_TABLE();
      a133 := JTF_NUMBER_TABLE();
      a134 := JTF_VARCHAR2_TABLE_100();
      a135 := JTF_NUMBER_TABLE();
      a136 := JTF_NUMBER_TABLE();
      a137 := JTF_VARCHAR2_TABLE_100();
      a138 := JTF_DATE_TABLE();
      a139 := JTF_VARCHAR2_TABLE_100();
      a140 := JTF_VARCHAR2_TABLE_100();
      a141 := JTF_VARCHAR2_TABLE_100();
      a142 := JTF_VARCHAR2_TABLE_100();
      a143 := JTF_NUMBER_TABLE();
      a144 := JTF_NUMBER_TABLE();
      a145 := JTF_VARCHAR2_TABLE_100();
      a146 := JTF_NUMBER_TABLE();
      a147 := JTF_NUMBER_TABLE();
      a148 := JTF_NUMBER_TABLE();
      a149 := JTF_NUMBER_TABLE();
      a150 := JTF_NUMBER_TABLE();
      a151 := JTF_NUMBER_TABLE();
      a152 := JTF_NUMBER_TABLE();
      a153 := JTF_VARCHAR2_TABLE_100();
      a154 := JTF_VARCHAR2_TABLE_100();
      a155 := JTF_VARCHAR2_TABLE_100();
      a156 := JTF_VARCHAR2_TABLE_100();
      a157 := JTF_VARCHAR2_TABLE_100();
      a158 := JTF_DATE_TABLE();
      a159 := JTF_VARCHAR2_TABLE_100();
      a160 := JTF_DATE_TABLE();
      a161 := JTF_VARCHAR2_TABLE_100();
      a162 := JTF_VARCHAR2_TABLE_2000();
      a163 := JTF_VARCHAR2_TABLE_100();
      a164 := JTF_VARCHAR2_TABLE_100();
      a165 := JTF_VARCHAR2_TABLE_100();
      a166 := JTF_NUMBER_TABLE();
      a167 := JTF_VARCHAR2_TABLE_100();
      a168 := JTF_VARCHAR2_TABLE_100();
      a169 := JTF_VARCHAR2_TABLE_100();
      a170 := JTF_VARCHAR2_TABLE_100();
      a171 := JTF_VARCHAR2_TABLE_100();
      a172 := JTF_VARCHAR2_TABLE_100();
      a173 := JTF_VARCHAR2_TABLE_100();
      a174 := JTF_NUMBER_TABLE();
      a175 := JTF_NUMBER_TABLE();
      a176 := JTF_NUMBER_TABLE();
      a177 := JTF_VARCHAR2_TABLE_100();
      a178 := JTF_VARCHAR2_TABLE_2000();
      a179 := JTF_VARCHAR2_TABLE_2000();
      a180 := JTF_VARCHAR2_TABLE_100();
      a181 := JTF_NUMBER_TABLE();
      a182 := JTF_VARCHAR2_TABLE_100();
      a183 := JTF_VARCHAR2_TABLE_2000();
      a184 := JTF_NUMBER_TABLE();
      a185 := JTF_VARCHAR2_TABLE_100();
      a186 := JTF_DATE_TABLE();
      a187 := JTF_DATE_TABLE();
      a188 := JTF_VARCHAR2_TABLE_100();
      a189 := JTF_NUMBER_TABLE();
      a190 := JTF_NUMBER_TABLE();
      a191 := JTF_NUMBER_TABLE();
      a192 := JTF_NUMBER_TABLE();
      a193 := JTF_VARCHAR2_TABLE_100();
      a194 := JTF_NUMBER_TABLE();
      a195 := JTF_NUMBER_TABLE();
      a196 := JTF_NUMBER_TABLE();
      a197 := JTF_NUMBER_TABLE();
      a198 := JTF_VARCHAR2_TABLE_100();
      a199 := JTF_VARCHAR2_TABLE_100();
      a200 := JTF_VARCHAR2_TABLE_100();
      a201 := JTF_NUMBER_TABLE();
      a202 := JTF_NUMBER_TABLE();
      a203 := JTF_NUMBER_TABLE();
      a204 := JTF_NUMBER_TABLE();
      a205 := JTF_VARCHAR2_TABLE_300();
      a206 := JTF_VARCHAR2_TABLE_100();
      a207 := JTF_VARCHAR2_TABLE_100();
      a208 := JTF_VARCHAR2_TABLE_100();
      a209 := JTF_VARCHAR2_TABLE_100();
      a210 := JTF_VARCHAR2_TABLE_100();
      a211 := JTF_VARCHAR2_TABLE_100();
      a212 := JTF_NUMBER_TABLE();
      a213 := JTF_NUMBER_TABLE();
      a214 := JTF_DATE_TABLE();
      a215 := JTF_NUMBER_TABLE();
      a216 := JTF_VARCHAR2_TABLE_100();
      a217 := JTF_NUMBER_TABLE();
      a218 := JTF_VARCHAR2_TABLE_100();
      a219 := JTF_VARCHAR2_TABLE_100();
      a220 := JTF_VARCHAR2_TABLE_100();
      a221 := JTF_VARCHAR2_TABLE_100();
      a222 := JTF_VARCHAR2_TABLE_100();
      a223 := JTF_VARCHAR2_TABLE_100();
      a224 := JTF_NUMBER_TABLE();
      a225 := JTF_NUMBER_TABLE();
      a226 := JTF_NUMBER_TABLE();
      a227 := JTF_NUMBER_TABLE();
      a228 := JTF_VARCHAR2_TABLE_100();
      a229 := JTF_NUMBER_TABLE();
      a230 := JTF_VARCHAR2_TABLE_100();
      a231 := JTF_NUMBER_TABLE();
      a232 := JTF_VARCHAR2_TABLE_2000();
      a233 := JTF_VARCHAR2_TABLE_100();
      a234 := JTF_NUMBER_TABLE();
      a235 := JTF_VARCHAR2_TABLE_100();
      a236 := JTF_NUMBER_TABLE();
      a237 := JTF_NUMBER_TABLE();
      a238 := JTF_NUMBER_TABLE();
      a239 := JTF_NUMBER_TABLE();
      a240 := JTF_NUMBER_TABLE();
      a241 := JTF_VARCHAR2_TABLE_1000();
      a242 := JTF_VARCHAR2_TABLE_100();
      a243 := JTF_NUMBER_TABLE();
      a244 := JTF_NUMBER_TABLE();
      a245 := JTF_NUMBER_TABLE();
      a246 := JTF_NUMBER_TABLE();
      a247 := JTF_VARCHAR2_TABLE_100();
      a248 := JTF_VARCHAR2_TABLE_100();
      a249 := JTF_DATE_TABLE();
      a250 := JTF_VARCHAR2_TABLE_100();
      a251 := JTF_NUMBER_TABLE();
      a252 := JTF_NUMBER_TABLE();
      a253 := JTF_VARCHAR2_TABLE_100();
      a254 := JTF_VARCHAR2_TABLE_100();
      a255 := JTF_VARCHAR2_TABLE_100();
      a256 := JTF_NUMBER_TABLE();
      a257 := JTF_NUMBER_TABLE();
      a258 := JTF_NUMBER_TABLE();
      a259 := JTF_VARCHAR2_TABLE_300();
      a260 := JTF_DATE_TABLE();
      a261 := JTF_VARCHAR2_TABLE_300();
      a262 := JTF_DATE_TABLE();
      a263 := JTF_NUMBER_TABLE();
      a264 := JTF_NUMBER_TABLE();
      a265 := JTF_NUMBER_TABLE();
      a266 := JTF_NUMBER_TABLE();
      a267 := JTF_NUMBER_TABLE();
      a268 := JTF_NUMBER_TABLE();
      a269 := JTF_NUMBER_TABLE();
      a270 := JTF_NUMBER_TABLE();
      a271 := JTF_NUMBER_TABLE();
      a272 := JTF_NUMBER_TABLE();
      a273 := JTF_NUMBER_TABLE();
      a274 := JTF_NUMBER_TABLE();
      a275 := JTF_NUMBER_TABLE();
      a276 := JTF_NUMBER_TABLE();
      a277 := JTF_NUMBER_TABLE();
      a278 := JTF_NUMBER_TABLE();
      a279 := JTF_NUMBER_TABLE();
      a280 := JTF_NUMBER_TABLE();
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
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        a146.extend(t.count);
        a147.extend(t.count);
        a148.extend(t.count);
        a149.extend(t.count);
        a150.extend(t.count);
        a151.extend(t.count);
        a152.extend(t.count);
        a153.extend(t.count);
        a154.extend(t.count);
        a155.extend(t.count);
        a156.extend(t.count);
        a157.extend(t.count);
        a158.extend(t.count);
        a159.extend(t.count);
        a160.extend(t.count);
        a161.extend(t.count);
        a162.extend(t.count);
        a163.extend(t.count);
        a164.extend(t.count);
        a165.extend(t.count);
        a166.extend(t.count);
        a167.extend(t.count);
        a168.extend(t.count);
        a169.extend(t.count);
        a170.extend(t.count);
        a171.extend(t.count);
        a172.extend(t.count);
        a173.extend(t.count);
        a174.extend(t.count);
        a175.extend(t.count);
        a176.extend(t.count);
        a177.extend(t.count);
        a178.extend(t.count);
        a179.extend(t.count);
        a180.extend(t.count);
        a181.extend(t.count);
        a182.extend(t.count);
        a183.extend(t.count);
        a184.extend(t.count);
        a185.extend(t.count);
        a186.extend(t.count);
        a187.extend(t.count);
        a188.extend(t.count);
        a189.extend(t.count);
        a190.extend(t.count);
        a191.extend(t.count);
        a192.extend(t.count);
        a193.extend(t.count);
        a194.extend(t.count);
        a195.extend(t.count);
        a196.extend(t.count);
        a197.extend(t.count);
        a198.extend(t.count);
        a199.extend(t.count);
        a200.extend(t.count);
        a201.extend(t.count);
        a202.extend(t.count);
        a203.extend(t.count);
        a204.extend(t.count);
        a205.extend(t.count);
        a206.extend(t.count);
        a207.extend(t.count);
        a208.extend(t.count);
        a209.extend(t.count);
        a210.extend(t.count);
        a211.extend(t.count);
        a212.extend(t.count);
        a213.extend(t.count);
        a214.extend(t.count);
        a215.extend(t.count);
        a216.extend(t.count);
        a217.extend(t.count);
        a218.extend(t.count);
        a219.extend(t.count);
        a220.extend(t.count);
        a221.extend(t.count);
        a222.extend(t.count);
        a223.extend(t.count);
        a224.extend(t.count);
        a225.extend(t.count);
        a226.extend(t.count);
        a227.extend(t.count);
        a228.extend(t.count);
        a229.extend(t.count);
        a230.extend(t.count);
        a231.extend(t.count);
        a232.extend(t.count);
        a233.extend(t.count);
        a234.extend(t.count);
        a235.extend(t.count);
        a236.extend(t.count);
        a237.extend(t.count);
        a238.extend(t.count);
        a239.extend(t.count);
        a240.extend(t.count);
        a241.extend(t.count);
        a242.extend(t.count);
        a243.extend(t.count);
        a244.extend(t.count);
        a245.extend(t.count);
        a246.extend(t.count);
        a247.extend(t.count);
        a248.extend(t.count);
        a249.extend(t.count);
        a250.extend(t.count);
        a251.extend(t.count);
        a252.extend(t.count);
        a253.extend(t.count);
        a254.extend(t.count);
        a255.extend(t.count);
        a256.extend(t.count);
        a257.extend(t.count);
        a258.extend(t.count);
        a259.extend(t.count);
        a260.extend(t.count);
        a261.extend(t.count);
        a262.extend(t.count);
        a263.extend(t.count);
        a264.extend(t.count);
        a265.extend(t.count);
        a266.extend(t.count);
        a267.extend(t.count);
        a268.extend(t.count);
        a269.extend(t.count);
        a270.extend(t.count);
        a271.extend(t.count);
        a272.extend(t.count);
        a273.extend(t.count);
        a274.extend(t.count);
        a275.extend(t.count);
        a276.extend(t.count);
        a277.extend(t.count);
        a278.extend(t.count);
        a279.extend(t.count);
        a280.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).accounting_rule_id);
          a1(indx) := t(ddindx).actual_arrival_date;
          a2(indx) := t(ddindx).actual_shipment_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).agreement_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).arrival_set_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).ato_line_id);
          a6(indx) := t(ddindx).authorized_to_ship_flag;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).auto_selected_quantity);
          a8(indx) := t(ddindx).booked_flag;
          a9(indx) := t(ddindx).cancelled_flag;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).cancelled_quantity);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).cancelled_quantity2);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_id);
          a13(indx) := t(ddindx).component_code;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).component_number);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).component_sequence_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).config_header_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).config_rev_nbr);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).config_display_sequence);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).configuration_id);
          a20(indx) := t(ddindx).context;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a22(indx) := t(ddindx).creation_date;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).credit_invoice_line_id);
          a24(indx) := t(ddindx).customer_dock_code;
          a25(indx) := t(ddindx).customer_job;
          a26(indx) := t(ddindx).customer_production_line;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).customer_trx_line_id);
          a28(indx) := t(ddindx).cust_model_serial_number;
          a29(indx) := t(ddindx).cust_po_number;
          a30(indx) := t(ddindx).cust_production_seq_num;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).delivery_lead_time);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_contact_id);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_org_id);
          a34(indx) := t(ddindx).demand_bucket_type_code;
          a35(indx) := t(ddindx).demand_class_code;
          a36(indx) := t(ddindx).dep_plan_required_flag;
          a37(indx) := t(ddindx).earliest_acceptable_date;
          a38(indx) := t(ddindx).end_item_unit_number;
          a39(indx) := t(ddindx).explosion_date;
          a40(indx) := t(ddindx).fob_point_code;
          a41(indx) := t(ddindx).freight_carrier_code;
          a42(indx) := t(ddindx).freight_terms_code;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).fulfilled_quantity);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).fulfilled_quantity2);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).intermed_ship_to_org_id);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).intermed_ship_to_contact_id);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a49(indx) := t(ddindx).invoice_interface_status_code;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_contact_id);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_org_id);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).invoicing_rule_id);
          a53(indx) := t(ddindx).ordered_item;
          a54(indx) := t(ddindx).item_revision;
          a55(indx) := t(ddindx).item_type_code;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a57(indx) := t(ddindx).last_update_date;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a59(indx) := t(ddindx).latest_acceptable_date;
          a60(indx) := t(ddindx).line_category_code;
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).line_type_id);
          a64(indx) := t(ddindx).link_to_line_ref;
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).link_to_line_id);
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).link_to_line_index);
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).model_group_number);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).mfg_component_sequence_id);
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).mfg_lead_time);
          a70(indx) := t(ddindx).open_flag;
          a71(indx) := t(ddindx).option_flag;
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).option_number);
          a73(indx) := rosetta_g_miss_num_map(t(ddindx).ordered_quantity);
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).ordered_quantity2);
          a75(indx) := t(ddindx).order_quantity_uom;
          a76(indx) := t(ddindx).ordered_quantity_uom2;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a78(indx) := t(ddindx).orig_sys_document_ref;
          a79(indx) := t(ddindx).orig_sys_line_ref;
          a80(indx) := t(ddindx).over_ship_reason_code;
          a81(indx) := t(ddindx).over_ship_resolved_flag;
          a82(indx) := rosetta_g_miss_num_map(t(ddindx).payment_term_id);
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).planning_priority);
          a84(indx) := t(ddindx).preferred_grade;
          a85(indx) := rosetta_g_miss_num_map(t(ddindx).price_list_id);
          a86(indx) := t(ddindx).price_request_code;
          a87(indx) := t(ddindx).pricing_date;
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_quantity);
          a89(indx) := t(ddindx).pricing_quantity_uom;
          a90(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a91(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a92(indx) := t(ddindx).program_update_date;
          a93(indx) := rosetta_g_miss_num_map(t(ddindx).project_id);
          a94(indx) := t(ddindx).promise_date;
          a95(indx) := t(ddindx).re_source_flag;
          a96(indx) := rosetta_g_miss_num_map(t(ddindx).reference_customer_trx_line_id);
          a97(indx) := rosetta_g_miss_num_map(t(ddindx).reference_header_id);
          a98(indx) := rosetta_g_miss_num_map(t(ddindx).reference_line_id);
          a99(indx) := t(ddindx).reference_type;
          a100(indx) := t(ddindx).request_date;
          a101(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a102(indx) := rosetta_g_miss_num_map(t(ddindx).reserved_quantity);
          a103(indx) := t(ddindx).return_reason_code;
          a104(indx) := t(ddindx).rla_schedule_type_code;
          a105(indx) := rosetta_g_miss_num_map(t(ddindx).salesrep_id);
          a106(indx) := t(ddindx).schedule_arrival_date;
          a107(indx) := t(ddindx).schedule_ship_date;
          a108(indx) := t(ddindx).schedule_action_code;
          a109(indx) := t(ddindx).schedule_status_code;
          a110(indx) := rosetta_g_miss_num_map(t(ddindx).shipment_number);
          a111(indx) := t(ddindx).shipment_priority_code;
          a112(indx) := rosetta_g_miss_num_map(t(ddindx).shipped_quantity);
          a113(indx) := rosetta_g_miss_num_map(t(ddindx).shipped_quantity2);
          a114(indx) := t(ddindx).shipping_interfaced_flag;
          a115(indx) := t(ddindx).shipping_method_code;
          a116(indx) := rosetta_g_miss_num_map(t(ddindx).shipping_quantity);
          a117(indx) := rosetta_g_miss_num_map(t(ddindx).shipping_quantity2);
          a118(indx) := t(ddindx).shipping_quantity_uom;
          a119(indx) := t(ddindx).shipping_quantity_uom2;
          a120(indx) := rosetta_g_miss_num_map(t(ddindx).ship_from_org_id);
          a121(indx) := t(ddindx).ship_model_complete_flag;
          a122(indx) := rosetta_g_miss_num_map(t(ddindx).ship_set_id);
          a123(indx) := rosetta_g_miss_num_map(t(ddindx).fulfillment_set_id);
          a124(indx) := rosetta_g_miss_num_map(t(ddindx).ship_tolerance_above);
          a125(indx) := rosetta_g_miss_num_map(t(ddindx).ship_tolerance_below);
          a126(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_contact_id);
          a127(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_org_id);
          a128(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_org_id);
          a129(indx) := rosetta_g_miss_num_map(t(ddindx).sold_from_org_id);
          a130(indx) := t(ddindx).sort_order;
          a131(indx) := rosetta_g_miss_num_map(t(ddindx).source_document_id);
          a132(indx) := rosetta_g_miss_num_map(t(ddindx).source_document_line_id);
          a133(indx) := rosetta_g_miss_num_map(t(ddindx).source_document_type_id);
          a134(indx) := t(ddindx).source_type_code;
          a135(indx) := rosetta_g_miss_num_map(t(ddindx).split_from_line_id);
          a136(indx) := rosetta_g_miss_num_map(t(ddindx).task_id);
          a137(indx) := t(ddindx).tax_code;
          a138(indx) := t(ddindx).tax_date;
          a139(indx) := t(ddindx).tax_exempt_flag;
          a140(indx) := t(ddindx).tax_exempt_number;
          a141(indx) := t(ddindx).tax_exempt_reason_code;
          a142(indx) := t(ddindx).tax_point_code;
          a143(indx) := rosetta_g_miss_num_map(t(ddindx).tax_rate);
          a144(indx) := rosetta_g_miss_num_map(t(ddindx).tax_value);
          a145(indx) := t(ddindx).top_model_line_ref;
          a146(indx) := rosetta_g_miss_num_map(t(ddindx).top_model_line_id);
          a147(indx) := rosetta_g_miss_num_map(t(ddindx).top_model_line_index);
          a148(indx) := rosetta_g_miss_num_map(t(ddindx).unit_list_price);
          a149(indx) := rosetta_g_miss_num_map(t(ddindx).unit_list_price_per_pqty);
          a150(indx) := rosetta_g_miss_num_map(t(ddindx).unit_selling_price);
          a151(indx) := rosetta_g_miss_num_map(t(ddindx).unit_selling_price_per_pqty);
          a152(indx) := rosetta_g_miss_num_map(t(ddindx).veh_cus_item_cum_key_id);
          a153(indx) := t(ddindx).visible_demand_flag;
          a154(indx) := t(ddindx).return_status;
          a155(indx) := t(ddindx).db_flag;
          a156(indx) := t(ddindx).operation;
          a157(indx) := t(ddindx).first_ack_code;
          a158(indx) := t(ddindx).first_ack_date;
          a159(indx) := t(ddindx).last_ack_code;
          a160(indx) := t(ddindx).last_ack_date;
          a161(indx) := t(ddindx).change_reason;
          a162(indx) := t(ddindx).change_comments;
          a163(indx) := t(ddindx).arrival_set;
          a164(indx) := t(ddindx).ship_set;
          a165(indx) := t(ddindx).fulfillment_set;
          a166(indx) := rosetta_g_miss_num_map(t(ddindx).order_source_id);
          a167(indx) := t(ddindx).orig_sys_shipment_ref;
          a168(indx) := t(ddindx).change_sequence;
          a169(indx) := t(ddindx).change_request_code;
          a170(indx) := t(ddindx).status_flag;
          a171(indx) := t(ddindx).drop_ship_flag;
          a172(indx) := t(ddindx).customer_line_number;
          a173(indx) := t(ddindx).customer_shipment_number;
          a174(indx) := rosetta_g_miss_num_map(t(ddindx).customer_item_net_price);
          a175(indx) := rosetta_g_miss_num_map(t(ddindx).customer_payment_term_id);
          a176(indx) := rosetta_g_miss_num_map(t(ddindx).ordered_item_id);
          a177(indx) := t(ddindx).item_identifier_type;
          a178(indx) := t(ddindx).shipping_instructions;
          a179(indx) := t(ddindx).packing_instructions;
          a180(indx) := t(ddindx).calculate_price_flag;
          a181(indx) := rosetta_g_miss_num_map(t(ddindx).invoiced_quantity);
          a182(indx) := t(ddindx).service_txn_reason_code;
          a183(indx) := t(ddindx).service_txn_comments;
          a184(indx) := rosetta_g_miss_num_map(t(ddindx).service_duration);
          a185(indx) := t(ddindx).service_period;
          a186(indx) := t(ddindx).service_start_date;
          a187(indx) := t(ddindx).service_end_date;
          a188(indx) := t(ddindx).service_coterminate_flag;
          a189(indx) := rosetta_g_miss_num_map(t(ddindx).unit_list_percent);
          a190(indx) := rosetta_g_miss_num_map(t(ddindx).unit_selling_percent);
          a191(indx) := rosetta_g_miss_num_map(t(ddindx).unit_percent_base_price);
          a192(indx) := rosetta_g_miss_num_map(t(ddindx).service_number);
          a193(indx) := t(ddindx).service_reference_type_code;
          a194(indx) := rosetta_g_miss_num_map(t(ddindx).service_reference_line_id);
          a195(indx) := rosetta_g_miss_num_map(t(ddindx).service_reference_system_id);
          a196(indx) := rosetta_g_miss_num_map(t(ddindx).service_ref_order_number);
          a197(indx) := rosetta_g_miss_num_map(t(ddindx).service_ref_line_number);
          a198(indx) := t(ddindx).service_reference_order;
          a199(indx) := t(ddindx).service_reference_line;
          a200(indx) := t(ddindx).service_reference_system;
          a201(indx) := rosetta_g_miss_num_map(t(ddindx).service_ref_shipment_number);
          a202(indx) := rosetta_g_miss_num_map(t(ddindx).service_ref_option_number);
          a203(indx) := rosetta_g_miss_num_map(t(ddindx).service_line_index);
          a204(indx) := rosetta_g_miss_num_map(t(ddindx).line_set_id);
          a205(indx) := t(ddindx).split_by;
          a206(indx) := t(ddindx).split_action_code;
          a207(indx) := t(ddindx).shippable_flag;
          a208(indx) := t(ddindx).model_remnant_flag;
          a209(indx) := t(ddindx).flow_status_code;
          a210(indx) := t(ddindx).fulfilled_flag;
          a211(indx) := t(ddindx).fulfillment_method_code;
          a212(indx) := rosetta_g_miss_num_map(t(ddindx).revenue_amount);
          a213(indx) := rosetta_g_miss_num_map(t(ddindx).marketing_source_code_id);
          a214(indx) := t(ddindx).fulfillment_date;
          if t(ddindx).semi_processed_flag is null
            then a215(indx) := null;
          elsif t(ddindx).semi_processed_flag
            then a215(indx) := 1;
          else a215(indx) := 0;
          end if;
          a216(indx) := t(ddindx).upgraded_flag;
          a217(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          a218(indx) := t(ddindx).subinventory;
          a219(indx) := t(ddindx).split_from_line_ref;
          a220(indx) := t(ddindx).split_from_shipment_ref;
          a221(indx) := t(ddindx).ship_to_edi_location_code;
          a222(indx) := t(ddindx).bill_to_edi_location_code;
          a223(indx) := t(ddindx).ship_from_edi_location_code;
          a224(indx) := rosetta_g_miss_num_map(t(ddindx).ship_from_address_id);
          a225(indx) := rosetta_g_miss_num_map(t(ddindx).sold_to_address_id);
          a226(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_address_id);
          a227(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_address_id);
          a228(indx) := t(ddindx).ship_to_address_code;
          a229(indx) := rosetta_g_miss_num_map(t(ddindx).original_inventory_item_id);
          a230(indx) := t(ddindx).original_item_identifier_type;
          a231(indx) := rosetta_g_miss_num_map(t(ddindx).original_ordered_item_id);
          a232(indx) := t(ddindx).original_ordered_item;
          a233(indx) := t(ddindx).item_substitution_type_code;
          a234(indx) := rosetta_g_miss_num_map(t(ddindx).late_demand_penalty_factor);
          a235(indx) := t(ddindx).override_atp_date_code;
          a236(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_customer_id);
          a237(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_customer_id);
          a238(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_customer_id);
          a239(indx) := rosetta_g_miss_num_map(t(ddindx).accounting_rule_duration);
          a240(indx) := rosetta_g_miss_num_map(t(ddindx).unit_cost);
          a241(indx) := t(ddindx).user_item_description;
          a242(indx) := t(ddindx).xml_transaction_type_code;
          a243(indx) := rosetta_g_miss_num_map(t(ddindx).item_relationship_type);
          a244(indx) := rosetta_g_miss_num_map(t(ddindx).blanket_number);
          a245(indx) := rosetta_g_miss_num_map(t(ddindx).blanket_line_number);
          a246(indx) := rosetta_g_miss_num_map(t(ddindx).blanket_version_number);
          a247(indx) := t(ddindx).cso_response_flag;
          a248(indx) := t(ddindx).firm_demand_flag;
          a249(indx) := t(ddindx).earliest_ship_date;
          a250(indx) := t(ddindx).transaction_phase_code;
          a251(indx) := rosetta_g_miss_num_map(t(ddindx).source_document_version_number);
          a252(indx) := rosetta_g_miss_num_map(t(ddindx).minisite_id);
          a253(indx) := t(ddindx).ib_owner;
          a254(indx) := t(ddindx).ib_installed_at_location;
          a255(indx) := t(ddindx).ib_current_location;
          a256(indx) := rosetta_g_miss_num_map(t(ddindx).end_customer_id);
          a257(indx) := rosetta_g_miss_num_map(t(ddindx).end_customer_contact_id);
          a258(indx) := rosetta_g_miss_num_map(t(ddindx).end_customer_site_use_id);
          a259(indx) := t(ddindx).supplier_signature;
          a260(indx) := t(ddindx).supplier_signature_date;
          a261(indx) := t(ddindx).customer_signature;
          a262(indx) := t(ddindx).customer_signature_date;
          a263(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_party_id);
          a264(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_party_site_id);
          a265(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_party_site_use_id);
          a266(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_party_id);
          a267(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_party_site_id);
          a268(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_party_site_use_id);
          a269(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_id);
          a270(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_site_id);
          a271(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_party_site_use_id);
          a272(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_customer_party_id);
          a273(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_customer_party_id);
          a274(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_customer_party_id);
          a275(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_org_contact_id);
          a276(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_org_contact_id);
          a277(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_org_contact_id);
          a278(indx) := rosetta_g_miss_num_map(t(ddindx).retrobill_request_id);
          a279(indx) := rosetta_g_miss_num_map(t(ddindx).original_list_price);
          a280(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_applied_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p21(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
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
    , a26 JTF_VARCHAR2_TABLE_400
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
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
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_400
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_400
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_NUMBER_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_VARCHAR2_TABLE_100
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_100
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_400
    , a109 JTF_VARCHAR2_TABLE_400
    , a110 JTF_VARCHAR2_TABLE_100
    , a111 JTF_VARCHAR2_TABLE_100
    , a112 JTF_NUMBER_TABLE
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_NUMBER_TABLE
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_400
    , a117 JTF_VARCHAR2_TABLE_2000
    , a118 JTF_VARCHAR2_TABLE_2000
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_100
    , a121 JTF_VARCHAR2_TABLE_400
    , a122 JTF_VARCHAR2_TABLE_100
    , a123 JTF_VARCHAR2_TABLE_400
    , a124 JTF_VARCHAR2_TABLE_100
    , a125 JTF_VARCHAR2_TABLE_400
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_400
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_VARCHAR2_TABLE_400
    , a131 JTF_VARCHAR2_TABLE_300
    , a132 JTF_VARCHAR2_TABLE_300
    , a133 JTF_VARCHAR2_TABLE_300
    , a134 JTF_VARCHAR2_TABLE_300
    , a135 JTF_VARCHAR2_TABLE_300
    , a136 JTF_VARCHAR2_TABLE_300
    , a137 JTF_VARCHAR2_TABLE_300
    , a138 JTF_VARCHAR2_TABLE_300
    , a139 JTF_VARCHAR2_TABLE_300
    , a140 JTF_VARCHAR2_TABLE_300
    , a141 JTF_VARCHAR2_TABLE_300
    , a142 JTF_VARCHAR2_TABLE_300
    , a143 JTF_VARCHAR2_TABLE_300
    , a144 JTF_VARCHAR2_TABLE_300
    , a145 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).accounting_rule := a0(indx);
          t(ddindx).agreement := a1(indx);
          t(ddindx).commitment := a2(indx);
          t(ddindx).commitment_applied_amount := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).deliver_to_address1 := a4(indx);
          t(ddindx).deliver_to_address2 := a5(indx);
          t(ddindx).deliver_to_address3 := a6(indx);
          t(ddindx).deliver_to_address4 := a7(indx);
          t(ddindx).deliver_to_contact := a8(indx);
          t(ddindx).deliver_to_location := a9(indx);
          t(ddindx).deliver_to_org := a10(indx);
          t(ddindx).deliver_to_state := a11(indx);
          t(ddindx).deliver_to_city := a12(indx);
          t(ddindx).deliver_to_zip := a13(indx);
          t(ddindx).deliver_to_country := a14(indx);
          t(ddindx).deliver_to_county := a15(indx);
          t(ddindx).deliver_to_province := a16(indx);
          t(ddindx).demand_class := a17(indx);
          t(ddindx).demand_bucket_type := a18(indx);
          t(ddindx).fob_point := a19(indx);
          t(ddindx).freight_terms := a20(indx);
          t(ddindx).inventory_item := a21(indx);
          t(ddindx).invoice_to_address1 := a22(indx);
          t(ddindx).invoice_to_address2 := a23(indx);
          t(ddindx).invoice_to_address3 := a24(indx);
          t(ddindx).invoice_to_address4 := a25(indx);
          t(ddindx).invoice_to_contact := a26(indx);
          t(ddindx).invoice_to_location := a27(indx);
          t(ddindx).invoice_to_org := a28(indx);
          t(ddindx).invoice_to_state := a29(indx);
          t(ddindx).invoice_to_city := a30(indx);
          t(ddindx).invoice_to_zip := a31(indx);
          t(ddindx).invoice_to_country := a32(indx);
          t(ddindx).invoice_to_county := a33(indx);
          t(ddindx).invoice_to_province := a34(indx);
          t(ddindx).invoicing_rule := a35(indx);
          t(ddindx).item_type := a36(indx);
          t(ddindx).line_type := a37(indx);
          t(ddindx).over_ship_reason := a38(indx);
          t(ddindx).payment_term := a39(indx);
          t(ddindx).price_list := a40(indx);
          t(ddindx).project := a41(indx);
          t(ddindx).return_reason := a42(indx);
          t(ddindx).rla_schedule_type := a43(indx);
          t(ddindx).salesrep := a44(indx);
          t(ddindx).shipment_priority := a45(indx);
          t(ddindx).ship_from_address1 := a46(indx);
          t(ddindx).ship_from_address2 := a47(indx);
          t(ddindx).ship_from_address3 := a48(indx);
          t(ddindx).ship_from_address4 := a49(indx);
          t(ddindx).ship_from_location := a50(indx);
          t(ddindx).ship_from_city := a51(indx);
          t(ddindx).ship_from_postal_code := a52(indx);
          t(ddindx).ship_from_country := a53(indx);
          t(ddindx).ship_from_region1 := a54(indx);
          t(ddindx).ship_from_region2 := a55(indx);
          t(ddindx).ship_from_region3 := a56(indx);
          t(ddindx).ship_from_org := a57(indx);
          t(ddindx).ship_to_address1 := a58(indx);
          t(ddindx).ship_to_address2 := a59(indx);
          t(ddindx).ship_to_address3 := a60(indx);
          t(ddindx).ship_to_address4 := a61(indx);
          t(ddindx).ship_to_state := a62(indx);
          t(ddindx).ship_to_country := a63(indx);
          t(ddindx).ship_to_zip := a64(indx);
          t(ddindx).ship_to_county := a65(indx);
          t(ddindx).ship_to_province := a66(indx);
          t(ddindx).ship_to_city := a67(indx);
          t(ddindx).ship_to_contact := a68(indx);
          t(ddindx).ship_to_contact_last_name := a69(indx);
          t(ddindx).ship_to_contact_first_name := a70(indx);
          t(ddindx).ship_to_location := a71(indx);
          t(ddindx).ship_to_org := a72(indx);
          t(ddindx).source_type := a73(indx);
          t(ddindx).intermed_ship_to_address1 := a74(indx);
          t(ddindx).intermed_ship_to_address2 := a75(indx);
          t(ddindx).intermed_ship_to_address3 := a76(indx);
          t(ddindx).intermed_ship_to_address4 := a77(indx);
          t(ddindx).intermed_ship_to_contact := a78(indx);
          t(ddindx).intermed_ship_to_location := a79(indx);
          t(ddindx).intermed_ship_to_org := a80(indx);
          t(ddindx).intermed_ship_to_state := a81(indx);
          t(ddindx).intermed_ship_to_city := a82(indx);
          t(ddindx).intermed_ship_to_zip := a83(indx);
          t(ddindx).intermed_ship_to_country := a84(indx);
          t(ddindx).intermed_ship_to_county := a85(indx);
          t(ddindx).intermed_ship_to_province := a86(indx);
          t(ddindx).sold_to_org := a87(indx);
          t(ddindx).sold_from_org := a88(indx);
          t(ddindx).task := a89(indx);
          t(ddindx).tax_exempt := a90(indx);
          t(ddindx).tax_exempt_reason := a91(indx);
          t(ddindx).tax_point := a92(indx);
          t(ddindx).veh_cus_item_cum_key := a93(indx);
          t(ddindx).visible_demand := a94(indx);
          t(ddindx).customer_payment_term := a95(indx);
          t(ddindx).ref_order_number := rosetta_g_miss_num_map(a96(indx));
          t(ddindx).ref_line_number := rosetta_g_miss_num_map(a97(indx));
          t(ddindx).ref_shipment_number := rosetta_g_miss_num_map(a98(indx));
          t(ddindx).ref_option_number := rosetta_g_miss_num_map(a99(indx));
          t(ddindx).ref_invoice_number := a100(indx);
          t(ddindx).ref_invoice_line_number := rosetta_g_miss_num_map(a101(indx));
          t(ddindx).credit_invoice_number := a102(indx);
          t(ddindx).tax_group := a103(indx);
          t(ddindx).status := a104(indx);
          t(ddindx).freight_carrier := a105(indx);
          t(ddindx).shipping_method := a106(indx);
          t(ddindx).calculate_price_descr := a107(indx);
          t(ddindx).ship_to_customer_name := a108(indx);
          t(ddindx).invoice_to_customer_name := a109(indx);
          t(ddindx).ship_to_customer_number := a110(indx);
          t(ddindx).invoice_to_customer_number := a111(indx);
          t(ddindx).ship_to_customer_id := rosetta_g_miss_num_map(a112(indx));
          t(ddindx).invoice_to_customer_id := rosetta_g_miss_num_map(a113(indx));
          t(ddindx).deliver_to_customer_id := rosetta_g_miss_num_map(a114(indx));
          t(ddindx).deliver_to_customer_number := a115(indx);
          t(ddindx).deliver_to_customer_name := a116(indx);
          t(ddindx).original_ordered_item := a117(indx);
          t(ddindx).original_inventory_item := a118(indx);
          t(ddindx).original_item_identifier_type := a119(indx);
          t(ddindx).deliver_to_customer_number_oi := a120(indx);
          t(ddindx).deliver_to_customer_name_oi := a121(indx);
          t(ddindx).ship_to_customer_number_oi := a122(indx);
          t(ddindx).ship_to_customer_name_oi := a123(indx);
          t(ddindx).invoice_to_customer_number_oi := a124(indx);
          t(ddindx).invoice_to_customer_name_oi := a125(indx);
          t(ddindx).item_relationship_type_dsp := a126(indx);
          t(ddindx).transaction_phase := a127(indx);
          t(ddindx).end_customer_name := a128(indx);
          t(ddindx).end_customer_number := a129(indx);
          t(ddindx).end_customer_contact := a130(indx);
          t(ddindx).end_cust_contact_last_name := a131(indx);
          t(ddindx).end_cust_contact_first_name := a132(indx);
          t(ddindx).end_customer_site_address1 := a133(indx);
          t(ddindx).end_customer_site_address2 := a134(indx);
          t(ddindx).end_customer_site_address3 := a135(indx);
          t(ddindx).end_customer_site_address4 := a136(indx);
          t(ddindx).end_customer_site_location := a137(indx);
          t(ddindx).end_customer_site_state := a138(indx);
          t(ddindx).end_customer_site_country := a139(indx);
          t(ddindx).end_customer_site_zip := a140(indx);
          t(ddindx).end_customer_site_county := a141(indx);
          t(ddindx).end_customer_site_province := a142(indx);
          t(ddindx).end_customer_site_city := a143(indx);
          t(ddindx).end_customer_site_postal_code := a144(indx);
          t(ddindx).blanket_agreement_name := a145(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t oe_order_pub.line_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a97 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a98 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a99 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a101 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a112 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a113 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a114 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a138 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a141 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a142 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a143 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a144 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a145 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_400();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
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
    a26 := JTF_VARCHAR2_TABLE_400();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
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
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_400();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_300();
    a73 := JTF_VARCHAR2_TABLE_300();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_300();
    a76 := JTF_VARCHAR2_TABLE_300();
    a77 := JTF_VARCHAR2_TABLE_300();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_300();
    a83 := JTF_VARCHAR2_TABLE_300();
    a84 := JTF_VARCHAR2_TABLE_300();
    a85 := JTF_VARCHAR2_TABLE_300();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_VARCHAR2_TABLE_400();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_300();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_NUMBER_TABLE();
    a98 := JTF_NUMBER_TABLE();
    a99 := JTF_NUMBER_TABLE();
    a100 := JTF_VARCHAR2_TABLE_100();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_VARCHAR2_TABLE_100();
    a103 := JTF_VARCHAR2_TABLE_100();
    a104 := JTF_VARCHAR2_TABLE_300();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_VARCHAR2_TABLE_100();
    a107 := JTF_VARCHAR2_TABLE_300();
    a108 := JTF_VARCHAR2_TABLE_400();
    a109 := JTF_VARCHAR2_TABLE_400();
    a110 := JTF_VARCHAR2_TABLE_100();
    a111 := JTF_VARCHAR2_TABLE_100();
    a112 := JTF_NUMBER_TABLE();
    a113 := JTF_NUMBER_TABLE();
    a114 := JTF_NUMBER_TABLE();
    a115 := JTF_VARCHAR2_TABLE_100();
    a116 := JTF_VARCHAR2_TABLE_400();
    a117 := JTF_VARCHAR2_TABLE_2000();
    a118 := JTF_VARCHAR2_TABLE_2000();
    a119 := JTF_VARCHAR2_TABLE_300();
    a120 := JTF_VARCHAR2_TABLE_100();
    a121 := JTF_VARCHAR2_TABLE_400();
    a122 := JTF_VARCHAR2_TABLE_100();
    a123 := JTF_VARCHAR2_TABLE_400();
    a124 := JTF_VARCHAR2_TABLE_100();
    a125 := JTF_VARCHAR2_TABLE_400();
    a126 := JTF_VARCHAR2_TABLE_100();
    a127 := JTF_VARCHAR2_TABLE_300();
    a128 := JTF_VARCHAR2_TABLE_400();
    a129 := JTF_VARCHAR2_TABLE_100();
    a130 := JTF_VARCHAR2_TABLE_400();
    a131 := JTF_VARCHAR2_TABLE_300();
    a132 := JTF_VARCHAR2_TABLE_300();
    a133 := JTF_VARCHAR2_TABLE_300();
    a134 := JTF_VARCHAR2_TABLE_300();
    a135 := JTF_VARCHAR2_TABLE_300();
    a136 := JTF_VARCHAR2_TABLE_300();
    a137 := JTF_VARCHAR2_TABLE_300();
    a138 := JTF_VARCHAR2_TABLE_300();
    a139 := JTF_VARCHAR2_TABLE_300();
    a140 := JTF_VARCHAR2_TABLE_300();
    a141 := JTF_VARCHAR2_TABLE_300();
    a142 := JTF_VARCHAR2_TABLE_300();
    a143 := JTF_VARCHAR2_TABLE_300();
    a144 := JTF_VARCHAR2_TABLE_300();
    a145 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_400();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
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
      a26 := JTF_VARCHAR2_TABLE_400();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
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
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_400();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_300();
      a73 := JTF_VARCHAR2_TABLE_300();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_300();
      a76 := JTF_VARCHAR2_TABLE_300();
      a77 := JTF_VARCHAR2_TABLE_300();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_300();
      a83 := JTF_VARCHAR2_TABLE_300();
      a84 := JTF_VARCHAR2_TABLE_300();
      a85 := JTF_VARCHAR2_TABLE_300();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_VARCHAR2_TABLE_400();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_300();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_NUMBER_TABLE();
      a98 := JTF_NUMBER_TABLE();
      a99 := JTF_NUMBER_TABLE();
      a100 := JTF_VARCHAR2_TABLE_100();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_VARCHAR2_TABLE_100();
      a103 := JTF_VARCHAR2_TABLE_100();
      a104 := JTF_VARCHAR2_TABLE_300();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_VARCHAR2_TABLE_100();
      a107 := JTF_VARCHAR2_TABLE_300();
      a108 := JTF_VARCHAR2_TABLE_400();
      a109 := JTF_VARCHAR2_TABLE_400();
      a110 := JTF_VARCHAR2_TABLE_100();
      a111 := JTF_VARCHAR2_TABLE_100();
      a112 := JTF_NUMBER_TABLE();
      a113 := JTF_NUMBER_TABLE();
      a114 := JTF_NUMBER_TABLE();
      a115 := JTF_VARCHAR2_TABLE_100();
      a116 := JTF_VARCHAR2_TABLE_400();
      a117 := JTF_VARCHAR2_TABLE_2000();
      a118 := JTF_VARCHAR2_TABLE_2000();
      a119 := JTF_VARCHAR2_TABLE_300();
      a120 := JTF_VARCHAR2_TABLE_100();
      a121 := JTF_VARCHAR2_TABLE_400();
      a122 := JTF_VARCHAR2_TABLE_100();
      a123 := JTF_VARCHAR2_TABLE_400();
      a124 := JTF_VARCHAR2_TABLE_100();
      a125 := JTF_VARCHAR2_TABLE_400();
      a126 := JTF_VARCHAR2_TABLE_100();
      a127 := JTF_VARCHAR2_TABLE_300();
      a128 := JTF_VARCHAR2_TABLE_400();
      a129 := JTF_VARCHAR2_TABLE_100();
      a130 := JTF_VARCHAR2_TABLE_400();
      a131 := JTF_VARCHAR2_TABLE_300();
      a132 := JTF_VARCHAR2_TABLE_300();
      a133 := JTF_VARCHAR2_TABLE_300();
      a134 := JTF_VARCHAR2_TABLE_300();
      a135 := JTF_VARCHAR2_TABLE_300();
      a136 := JTF_VARCHAR2_TABLE_300();
      a137 := JTF_VARCHAR2_TABLE_300();
      a138 := JTF_VARCHAR2_TABLE_300();
      a139 := JTF_VARCHAR2_TABLE_300();
      a140 := JTF_VARCHAR2_TABLE_300();
      a141 := JTF_VARCHAR2_TABLE_300();
      a142 := JTF_VARCHAR2_TABLE_300();
      a143 := JTF_VARCHAR2_TABLE_300();
      a144 := JTF_VARCHAR2_TABLE_300();
      a145 := JTF_VARCHAR2_TABLE_400();
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
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).accounting_rule;
          a1(indx) := t(ddindx).agreement;
          a2(indx) := t(ddindx).commitment;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_applied_amount);
          a4(indx) := t(ddindx).deliver_to_address1;
          a5(indx) := t(ddindx).deliver_to_address2;
          a6(indx) := t(ddindx).deliver_to_address3;
          a7(indx) := t(ddindx).deliver_to_address4;
          a8(indx) := t(ddindx).deliver_to_contact;
          a9(indx) := t(ddindx).deliver_to_location;
          a10(indx) := t(ddindx).deliver_to_org;
          a11(indx) := t(ddindx).deliver_to_state;
          a12(indx) := t(ddindx).deliver_to_city;
          a13(indx) := t(ddindx).deliver_to_zip;
          a14(indx) := t(ddindx).deliver_to_country;
          a15(indx) := t(ddindx).deliver_to_county;
          a16(indx) := t(ddindx).deliver_to_province;
          a17(indx) := t(ddindx).demand_class;
          a18(indx) := t(ddindx).demand_bucket_type;
          a19(indx) := t(ddindx).fob_point;
          a20(indx) := t(ddindx).freight_terms;
          a21(indx) := t(ddindx).inventory_item;
          a22(indx) := t(ddindx).invoice_to_address1;
          a23(indx) := t(ddindx).invoice_to_address2;
          a24(indx) := t(ddindx).invoice_to_address3;
          a25(indx) := t(ddindx).invoice_to_address4;
          a26(indx) := t(ddindx).invoice_to_contact;
          a27(indx) := t(ddindx).invoice_to_location;
          a28(indx) := t(ddindx).invoice_to_org;
          a29(indx) := t(ddindx).invoice_to_state;
          a30(indx) := t(ddindx).invoice_to_city;
          a31(indx) := t(ddindx).invoice_to_zip;
          a32(indx) := t(ddindx).invoice_to_country;
          a33(indx) := t(ddindx).invoice_to_county;
          a34(indx) := t(ddindx).invoice_to_province;
          a35(indx) := t(ddindx).invoicing_rule;
          a36(indx) := t(ddindx).item_type;
          a37(indx) := t(ddindx).line_type;
          a38(indx) := t(ddindx).over_ship_reason;
          a39(indx) := t(ddindx).payment_term;
          a40(indx) := t(ddindx).price_list;
          a41(indx) := t(ddindx).project;
          a42(indx) := t(ddindx).return_reason;
          a43(indx) := t(ddindx).rla_schedule_type;
          a44(indx) := t(ddindx).salesrep;
          a45(indx) := t(ddindx).shipment_priority;
          a46(indx) := t(ddindx).ship_from_address1;
          a47(indx) := t(ddindx).ship_from_address2;
          a48(indx) := t(ddindx).ship_from_address3;
          a49(indx) := t(ddindx).ship_from_address4;
          a50(indx) := t(ddindx).ship_from_location;
          a51(indx) := t(ddindx).ship_from_city;
          a52(indx) := t(ddindx).ship_from_postal_code;
          a53(indx) := t(ddindx).ship_from_country;
          a54(indx) := t(ddindx).ship_from_region1;
          a55(indx) := t(ddindx).ship_from_region2;
          a56(indx) := t(ddindx).ship_from_region3;
          a57(indx) := t(ddindx).ship_from_org;
          a58(indx) := t(ddindx).ship_to_address1;
          a59(indx) := t(ddindx).ship_to_address2;
          a60(indx) := t(ddindx).ship_to_address3;
          a61(indx) := t(ddindx).ship_to_address4;
          a62(indx) := t(ddindx).ship_to_state;
          a63(indx) := t(ddindx).ship_to_country;
          a64(indx) := t(ddindx).ship_to_zip;
          a65(indx) := t(ddindx).ship_to_county;
          a66(indx) := t(ddindx).ship_to_province;
          a67(indx) := t(ddindx).ship_to_city;
          a68(indx) := t(ddindx).ship_to_contact;
          a69(indx) := t(ddindx).ship_to_contact_last_name;
          a70(indx) := t(ddindx).ship_to_contact_first_name;
          a71(indx) := t(ddindx).ship_to_location;
          a72(indx) := t(ddindx).ship_to_org;
          a73(indx) := t(ddindx).source_type;
          a74(indx) := t(ddindx).intermed_ship_to_address1;
          a75(indx) := t(ddindx).intermed_ship_to_address2;
          a76(indx) := t(ddindx).intermed_ship_to_address3;
          a77(indx) := t(ddindx).intermed_ship_to_address4;
          a78(indx) := t(ddindx).intermed_ship_to_contact;
          a79(indx) := t(ddindx).intermed_ship_to_location;
          a80(indx) := t(ddindx).intermed_ship_to_org;
          a81(indx) := t(ddindx).intermed_ship_to_state;
          a82(indx) := t(ddindx).intermed_ship_to_city;
          a83(indx) := t(ddindx).intermed_ship_to_zip;
          a84(indx) := t(ddindx).intermed_ship_to_country;
          a85(indx) := t(ddindx).intermed_ship_to_county;
          a86(indx) := t(ddindx).intermed_ship_to_province;
          a87(indx) := t(ddindx).sold_to_org;
          a88(indx) := t(ddindx).sold_from_org;
          a89(indx) := t(ddindx).task;
          a90(indx) := t(ddindx).tax_exempt;
          a91(indx) := t(ddindx).tax_exempt_reason;
          a92(indx) := t(ddindx).tax_point;
          a93(indx) := t(ddindx).veh_cus_item_cum_key;
          a94(indx) := t(ddindx).visible_demand;
          a95(indx) := t(ddindx).customer_payment_term;
          a96(indx) := rosetta_g_miss_num_map(t(ddindx).ref_order_number);
          a97(indx) := rosetta_g_miss_num_map(t(ddindx).ref_line_number);
          a98(indx) := rosetta_g_miss_num_map(t(ddindx).ref_shipment_number);
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).ref_option_number);
          a100(indx) := t(ddindx).ref_invoice_number;
          a101(indx) := rosetta_g_miss_num_map(t(ddindx).ref_invoice_line_number);
          a102(indx) := t(ddindx).credit_invoice_number;
          a103(indx) := t(ddindx).tax_group;
          a104(indx) := t(ddindx).status;
          a105(indx) := t(ddindx).freight_carrier;
          a106(indx) := t(ddindx).shipping_method;
          a107(indx) := t(ddindx).calculate_price_descr;
          a108(indx) := t(ddindx).ship_to_customer_name;
          a109(indx) := t(ddindx).invoice_to_customer_name;
          a110(indx) := t(ddindx).ship_to_customer_number;
          a111(indx) := t(ddindx).invoice_to_customer_number;
          a112(indx) := rosetta_g_miss_num_map(t(ddindx).ship_to_customer_id);
          a113(indx) := rosetta_g_miss_num_map(t(ddindx).invoice_to_customer_id);
          a114(indx) := rosetta_g_miss_num_map(t(ddindx).deliver_to_customer_id);
          a115(indx) := t(ddindx).deliver_to_customer_number;
          a116(indx) := t(ddindx).deliver_to_customer_name;
          a117(indx) := t(ddindx).original_ordered_item;
          a118(indx) := t(ddindx).original_inventory_item;
          a119(indx) := t(ddindx).original_item_identifier_type;
          a120(indx) := t(ddindx).deliver_to_customer_number_oi;
          a121(indx) := t(ddindx).deliver_to_customer_name_oi;
          a122(indx) := t(ddindx).ship_to_customer_number_oi;
          a123(indx) := t(ddindx).ship_to_customer_name_oi;
          a124(indx) := t(ddindx).invoice_to_customer_number_oi;
          a125(indx) := t(ddindx).invoice_to_customer_name_oi;
          a126(indx) := t(ddindx).item_relationship_type_dsp;
          a127(indx) := t(ddindx).transaction_phase;
          a128(indx) := t(ddindx).end_customer_name;
          a129(indx) := t(ddindx).end_customer_number;
          a130(indx) := t(ddindx).end_customer_contact;
          a131(indx) := t(ddindx).end_cust_contact_last_name;
          a132(indx) := t(ddindx).end_cust_contact_first_name;
          a133(indx) := t(ddindx).end_customer_site_address1;
          a134(indx) := t(ddindx).end_customer_site_address2;
          a135(indx) := t(ddindx).end_customer_site_address3;
          a136(indx) := t(ddindx).end_customer_site_address4;
          a137(indx) := t(ddindx).end_customer_site_location;
          a138(indx) := t(ddindx).end_customer_site_state;
          a139(indx) := t(ddindx).end_customer_site_country;
          a140(indx) := t(ddindx).end_customer_site_zip;
          a141(indx) := t(ddindx).end_customer_site_county;
          a142(indx) := t(ddindx).end_customer_site_province;
          a143(indx) := t(ddindx).end_customer_site_city;
          a144(indx) := t(ddindx).end_customer_site_postal_code;
          a145(indx) := t(ddindx).blanket_agreement_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure rosetta_table_copy_in_p23(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_adj_tbl_type, a0 JTF_VARCHAR2_TABLE_300
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_2000
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_DATE_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_DATE_TABLE
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_200
    , a105 JTF_NUMBER_TABLE
    , a106 JTF_NUMBER_TABLE
    , a107 JTF_NUMBER_TABLE
    , a108 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute1 := a0(indx);
          t(ddindx).attribute10 := a1(indx);
          t(ddindx).attribute11 := a2(indx);
          t(ddindx).attribute12 := a3(indx);
          t(ddindx).attribute13 := a4(indx);
          t(ddindx).attribute14 := a5(indx);
          t(ddindx).attribute15 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).automatic_flag := a15(indx);
          t(ddindx).context := a16(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).discount_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).discount_line_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).header_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).price_adjustment_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).return_status := a32(indx);
          t(ddindx).db_flag := a33(indx);
          t(ddindx).operation := a34(indx);
          t(ddindx).line_index := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).orig_sys_discount_ref := a36(indx);
          t(ddindx).change_request_code := a37(indx);
          t(ddindx).status_flag := a38(indx);
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).list_line_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).list_line_type_code := a41(indx);
          t(ddindx).modifier_mechanism_type_code := a42(indx);
          t(ddindx).modified_from := a43(indx);
          t(ddindx).modified_to := a44(indx);
          t(ddindx).updated_flag := a45(indx);
          t(ddindx).update_allowed := a46(indx);
          t(ddindx).applied_flag := a47(indx);
          t(ddindx).change_reason_code := a48(indx);
          t(ddindx).change_reason_text := a49(indx);
          t(ddindx).operand := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).operand_per_pqty := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).arithmetic_operator := a52(indx);
          t(ddindx).cost_id := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).tax_code := a54(indx);
          t(ddindx).tax_exempt_flag := a55(indx);
          t(ddindx).tax_exempt_number := a56(indx);
          t(ddindx).tax_exempt_reason_code := a57(indx);
          t(ddindx).parent_adjustment_id := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).invoiced_flag := a59(indx);
          t(ddindx).estimated_flag := a60(indx);
          t(ddindx).inc_in_sales_performance := a61(indx);
          t(ddindx).split_action_code := a62(indx);
          t(ddindx).adjusted_amount := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).adjusted_amount_per_pqty := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).pricing_phase_id := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).charge_type_code := a66(indx);
          t(ddindx).charge_subtype_code := a67(indx);
          t(ddindx).list_line_no := a68(indx);
          t(ddindx).source_system_code := a69(indx);
          t(ddindx).benefit_qty := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).benefit_uom_code := a71(indx);
          t(ddindx).print_on_invoice_flag := a72(indx);
          t(ddindx).expiration_date := rosetta_g_miss_date_in_map(a73(indx));
          t(ddindx).rebate_transaction_type_code := a74(indx);
          t(ddindx).rebate_transaction_reference := a75(indx);
          t(ddindx).rebate_payment_system_code := a76(indx);
          t(ddindx).redeemed_date := rosetta_g_miss_date_in_map(a77(indx));
          t(ddindx).redeemed_flag := a78(indx);
          t(ddindx).accrual_flag := a79(indx);
          t(ddindx).range_break_quantity := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).accrual_conversion_rate := rosetta_g_miss_num_map(a81(indx));
          t(ddindx).pricing_group_sequence := rosetta_g_miss_num_map(a82(indx));
          t(ddindx).modifier_level_code := a83(indx);
          t(ddindx).price_break_type_code := a84(indx);
          t(ddindx).substitution_attribute := a85(indx);
          t(ddindx).proration_type_code := a86(indx);
          t(ddindx).credit_or_charge_flag := a87(indx);
          t(ddindx).include_on_returns_flag := a88(indx);
          t(ddindx).ac_attribute1 := a89(indx);
          t(ddindx).ac_attribute10 := a90(indx);
          t(ddindx).ac_attribute11 := a91(indx);
          t(ddindx).ac_attribute12 := a92(indx);
          t(ddindx).ac_attribute13 := a93(indx);
          t(ddindx).ac_attribute14 := a94(indx);
          t(ddindx).ac_attribute15 := a95(indx);
          t(ddindx).ac_attribute2 := a96(indx);
          t(ddindx).ac_attribute3 := a97(indx);
          t(ddindx).ac_attribute4 := a98(indx);
          t(ddindx).ac_attribute5 := a99(indx);
          t(ddindx).ac_attribute6 := a100(indx);
          t(ddindx).ac_attribute7 := a101(indx);
          t(ddindx).ac_attribute8 := a102(indx);
          t(ddindx).ac_attribute9 := a103(indx);
          t(ddindx).ac_context := a104(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a105(indx));
          t(ddindx).group_value := rosetta_g_miss_num_map(a106(indx));
          t(ddindx).invoiced_amount := rosetta_g_miss_num_map(a107(indx));
          t(ddindx).retrobill_request_id := rosetta_g_miss_num_map(a108(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t oe_order_pub.line_adj_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a50 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a51 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a53 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a58 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a63 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a64 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a65 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a70 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a73 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a77 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a80 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a81 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a82 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a105 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a106 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a107 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a108 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_300();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_2000();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_DATE_TABLE();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_DATE_TABLE();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_100();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_VARCHAR2_TABLE_100();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_300();
    a96 := JTF_VARCHAR2_TABLE_300();
    a97 := JTF_VARCHAR2_TABLE_300();
    a98 := JTF_VARCHAR2_TABLE_300();
    a99 := JTF_VARCHAR2_TABLE_300();
    a100 := JTF_VARCHAR2_TABLE_300();
    a101 := JTF_VARCHAR2_TABLE_300();
    a102 := JTF_VARCHAR2_TABLE_300();
    a103 := JTF_VARCHAR2_TABLE_300();
    a104 := JTF_VARCHAR2_TABLE_200();
    a105 := JTF_NUMBER_TABLE();
    a106 := JTF_NUMBER_TABLE();
    a107 := JTF_NUMBER_TABLE();
    a108 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_300();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_2000();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_DATE_TABLE();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_DATE_TABLE();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_100();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_VARCHAR2_TABLE_100();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_300();
      a96 := JTF_VARCHAR2_TABLE_300();
      a97 := JTF_VARCHAR2_TABLE_300();
      a98 := JTF_VARCHAR2_TABLE_300();
      a99 := JTF_VARCHAR2_TABLE_300();
      a100 := JTF_VARCHAR2_TABLE_300();
      a101 := JTF_VARCHAR2_TABLE_300();
      a102 := JTF_VARCHAR2_TABLE_300();
      a103 := JTF_VARCHAR2_TABLE_300();
      a104 := JTF_VARCHAR2_TABLE_200();
      a105 := JTF_NUMBER_TABLE();
      a106 := JTF_NUMBER_TABLE();
      a107 := JTF_NUMBER_TABLE();
      a108 := JTF_NUMBER_TABLE();
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
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute1;
          a1(indx) := t(ddindx).attribute10;
          a2(indx) := t(ddindx).attribute11;
          a3(indx) := t(ddindx).attribute12;
          a4(indx) := t(ddindx).attribute13;
          a5(indx) := t(ddindx).attribute14;
          a6(indx) := t(ddindx).attribute15;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).automatic_flag;
          a16(indx) := t(ddindx).context;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a18(indx) := t(ddindx).creation_date;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).discount_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).discount_line_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a23(indx) := t(ddindx).last_update_date;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).price_adjustment_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a30(indx) := t(ddindx).program_update_date;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a32(indx) := t(ddindx).return_status;
          a33(indx) := t(ddindx).db_flag;
          a34(indx) := t(ddindx).operation;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).line_index);
          a36(indx) := t(ddindx).orig_sys_discount_ref;
          a37(indx) := t(ddindx).change_request_code;
          a38(indx) := t(ddindx).status_flag;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).list_line_id);
          a41(indx) := t(ddindx).list_line_type_code;
          a42(indx) := t(ddindx).modifier_mechanism_type_code;
          a43(indx) := t(ddindx).modified_from;
          a44(indx) := t(ddindx).modified_to;
          a45(indx) := t(ddindx).updated_flag;
          a46(indx) := t(ddindx).update_allowed;
          a47(indx) := t(ddindx).applied_flag;
          a48(indx) := t(ddindx).change_reason_code;
          a49(indx) := t(ddindx).change_reason_text;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).operand);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).operand_per_pqty);
          a52(indx) := t(ddindx).arithmetic_operator;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).cost_id);
          a54(indx) := t(ddindx).tax_code;
          a55(indx) := t(ddindx).tax_exempt_flag;
          a56(indx) := t(ddindx).tax_exempt_number;
          a57(indx) := t(ddindx).tax_exempt_reason_code;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).parent_adjustment_id);
          a59(indx) := t(ddindx).invoiced_flag;
          a60(indx) := t(ddindx).estimated_flag;
          a61(indx) := t(ddindx).inc_in_sales_performance;
          a62(indx) := t(ddindx).split_action_code;
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).adjusted_amount);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).adjusted_amount_per_pqty);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_phase_id);
          a66(indx) := t(ddindx).charge_type_code;
          a67(indx) := t(ddindx).charge_subtype_code;
          a68(indx) := t(ddindx).list_line_no;
          a69(indx) := t(ddindx).source_system_code;
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).benefit_qty);
          a71(indx) := t(ddindx).benefit_uom_code;
          a72(indx) := t(ddindx).print_on_invoice_flag;
          a73(indx) := t(ddindx).expiration_date;
          a74(indx) := t(ddindx).rebate_transaction_type_code;
          a75(indx) := t(ddindx).rebate_transaction_reference;
          a76(indx) := t(ddindx).rebate_payment_system_code;
          a77(indx) := t(ddindx).redeemed_date;
          a78(indx) := t(ddindx).redeemed_flag;
          a79(indx) := t(ddindx).accrual_flag;
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).range_break_quantity);
          a81(indx) := rosetta_g_miss_num_map(t(ddindx).accrual_conversion_rate);
          a82(indx) := rosetta_g_miss_num_map(t(ddindx).pricing_group_sequence);
          a83(indx) := t(ddindx).modifier_level_code;
          a84(indx) := t(ddindx).price_break_type_code;
          a85(indx) := t(ddindx).substitution_attribute;
          a86(indx) := t(ddindx).proration_type_code;
          a87(indx) := t(ddindx).credit_or_charge_flag;
          a88(indx) := t(ddindx).include_on_returns_flag;
          a89(indx) := t(ddindx).ac_attribute1;
          a90(indx) := t(ddindx).ac_attribute10;
          a91(indx) := t(ddindx).ac_attribute11;
          a92(indx) := t(ddindx).ac_attribute12;
          a93(indx) := t(ddindx).ac_attribute13;
          a94(indx) := t(ddindx).ac_attribute14;
          a95(indx) := t(ddindx).ac_attribute15;
          a96(indx) := t(ddindx).ac_attribute2;
          a97(indx) := t(ddindx).ac_attribute3;
          a98(indx) := t(ddindx).ac_attribute4;
          a99(indx) := t(ddindx).ac_attribute5;
          a100(indx) := t(ddindx).ac_attribute6;
          a101(indx) := t(ddindx).ac_attribute7;
          a102(indx) := t(ddindx).ac_attribute8;
          a103(indx) := t(ddindx).ac_attribute9;
          a104(indx) := t(ddindx).ac_context;
          a105(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          a106(indx) := rosetta_g_miss_num_map(t(ddindx).group_value);
          a107(indx) := rosetta_g_miss_num_map(t(ddindx).invoiced_amount);
          a108(indx) := rosetta_g_miss_num_map(t(ddindx).retrobill_request_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p25(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_adj_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).discount := a0(indx);
          t(ddindx).list_name := a1(indx);
          t(ddindx).version_no := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p25;
  procedure rosetta_table_copy_out_p25(t oe_order_pub.line_adj_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).discount;
          a1(indx) := t(ddindx).list_name;
          a2(indx) := t(ddindx).version_no;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p25;

  procedure rosetta_table_copy_in_p27(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_price_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
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
    , a30 JTF_VARCHAR2_TABLE_300
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
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_300
    , a106 JTF_VARCHAR2_TABLE_300
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_300
    , a109 JTF_VARCHAR2_TABLE_300
    , a110 JTF_VARCHAR2_TABLE_300
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    , a114 JTF_VARCHAR2_TABLE_300
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_300
    , a117 JTF_VARCHAR2_TABLE_300
    , a118 JTF_VARCHAR2_TABLE_300
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_300
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_300
    , a124 JTF_VARCHAR2_TABLE_300
    , a125 JTF_VARCHAR2_TABLE_300
    , a126 JTF_VARCHAR2_TABLE_300
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_300
    , a129 JTF_VARCHAR2_TABLE_300
    , a130 JTF_VARCHAR2_TABLE_300
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_VARCHAR2_TABLE_100
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_VARCHAR2_TABLE_100
    , a137 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).order_price_attrib_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).header_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).line_index := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).flex_title := a13(indx);
          t(ddindx).pricing_context := a14(indx);
          t(ddindx).pricing_attribute1 := a15(indx);
          t(ddindx).pricing_attribute2 := a16(indx);
          t(ddindx).pricing_attribute3 := a17(indx);
          t(ddindx).pricing_attribute4 := a18(indx);
          t(ddindx).pricing_attribute5 := a19(indx);
          t(ddindx).pricing_attribute6 := a20(indx);
          t(ddindx).pricing_attribute7 := a21(indx);
          t(ddindx).pricing_attribute8 := a22(indx);
          t(ddindx).pricing_attribute9 := a23(indx);
          t(ddindx).pricing_attribute10 := a24(indx);
          t(ddindx).pricing_attribute11 := a25(indx);
          t(ddindx).pricing_attribute12 := a26(indx);
          t(ddindx).pricing_attribute13 := a27(indx);
          t(ddindx).pricing_attribute14 := a28(indx);
          t(ddindx).pricing_attribute15 := a29(indx);
          t(ddindx).pricing_attribute16 := a30(indx);
          t(ddindx).pricing_attribute17 := a31(indx);
          t(ddindx).pricing_attribute18 := a32(indx);
          t(ddindx).pricing_attribute19 := a33(indx);
          t(ddindx).pricing_attribute20 := a34(indx);
          t(ddindx).pricing_attribute21 := a35(indx);
          t(ddindx).pricing_attribute22 := a36(indx);
          t(ddindx).pricing_attribute23 := a37(indx);
          t(ddindx).pricing_attribute24 := a38(indx);
          t(ddindx).pricing_attribute25 := a39(indx);
          t(ddindx).pricing_attribute26 := a40(indx);
          t(ddindx).pricing_attribute27 := a41(indx);
          t(ddindx).pricing_attribute28 := a42(indx);
          t(ddindx).pricing_attribute29 := a43(indx);
          t(ddindx).pricing_attribute30 := a44(indx);
          t(ddindx).pricing_attribute31 := a45(indx);
          t(ddindx).pricing_attribute32 := a46(indx);
          t(ddindx).pricing_attribute33 := a47(indx);
          t(ddindx).pricing_attribute34 := a48(indx);
          t(ddindx).pricing_attribute35 := a49(indx);
          t(ddindx).pricing_attribute36 := a50(indx);
          t(ddindx).pricing_attribute37 := a51(indx);
          t(ddindx).pricing_attribute38 := a52(indx);
          t(ddindx).pricing_attribute39 := a53(indx);
          t(ddindx).pricing_attribute40 := a54(indx);
          t(ddindx).pricing_attribute41 := a55(indx);
          t(ddindx).pricing_attribute42 := a56(indx);
          t(ddindx).pricing_attribute43 := a57(indx);
          t(ddindx).pricing_attribute44 := a58(indx);
          t(ddindx).pricing_attribute45 := a59(indx);
          t(ddindx).pricing_attribute46 := a60(indx);
          t(ddindx).pricing_attribute47 := a61(indx);
          t(ddindx).pricing_attribute48 := a62(indx);
          t(ddindx).pricing_attribute49 := a63(indx);
          t(ddindx).pricing_attribute50 := a64(indx);
          t(ddindx).pricing_attribute51 := a65(indx);
          t(ddindx).pricing_attribute52 := a66(indx);
          t(ddindx).pricing_attribute53 := a67(indx);
          t(ddindx).pricing_attribute54 := a68(indx);
          t(ddindx).pricing_attribute55 := a69(indx);
          t(ddindx).pricing_attribute56 := a70(indx);
          t(ddindx).pricing_attribute57 := a71(indx);
          t(ddindx).pricing_attribute58 := a72(indx);
          t(ddindx).pricing_attribute59 := a73(indx);
          t(ddindx).pricing_attribute60 := a74(indx);
          t(ddindx).pricing_attribute61 := a75(indx);
          t(ddindx).pricing_attribute62 := a76(indx);
          t(ddindx).pricing_attribute63 := a77(indx);
          t(ddindx).pricing_attribute64 := a78(indx);
          t(ddindx).pricing_attribute65 := a79(indx);
          t(ddindx).pricing_attribute66 := a80(indx);
          t(ddindx).pricing_attribute67 := a81(indx);
          t(ddindx).pricing_attribute68 := a82(indx);
          t(ddindx).pricing_attribute69 := a83(indx);
          t(ddindx).pricing_attribute70 := a84(indx);
          t(ddindx).pricing_attribute71 := a85(indx);
          t(ddindx).pricing_attribute72 := a86(indx);
          t(ddindx).pricing_attribute73 := a87(indx);
          t(ddindx).pricing_attribute74 := a88(indx);
          t(ddindx).pricing_attribute75 := a89(indx);
          t(ddindx).pricing_attribute76 := a90(indx);
          t(ddindx).pricing_attribute77 := a91(indx);
          t(ddindx).pricing_attribute78 := a92(indx);
          t(ddindx).pricing_attribute79 := a93(indx);
          t(ddindx).pricing_attribute80 := a94(indx);
          t(ddindx).pricing_attribute81 := a95(indx);
          t(ddindx).pricing_attribute82 := a96(indx);
          t(ddindx).pricing_attribute83 := a97(indx);
          t(ddindx).pricing_attribute84 := a98(indx);
          t(ddindx).pricing_attribute85 := a99(indx);
          t(ddindx).pricing_attribute86 := a100(indx);
          t(ddindx).pricing_attribute87 := a101(indx);
          t(ddindx).pricing_attribute88 := a102(indx);
          t(ddindx).pricing_attribute89 := a103(indx);
          t(ddindx).pricing_attribute90 := a104(indx);
          t(ddindx).pricing_attribute91 := a105(indx);
          t(ddindx).pricing_attribute92 := a106(indx);
          t(ddindx).pricing_attribute93 := a107(indx);
          t(ddindx).pricing_attribute94 := a108(indx);
          t(ddindx).pricing_attribute95 := a109(indx);
          t(ddindx).pricing_attribute96 := a110(indx);
          t(ddindx).pricing_attribute97 := a111(indx);
          t(ddindx).pricing_attribute98 := a112(indx);
          t(ddindx).pricing_attribute99 := a113(indx);
          t(ddindx).pricing_attribute100 := a114(indx);
          t(ddindx).context := a115(indx);
          t(ddindx).attribute1 := a116(indx);
          t(ddindx).attribute2 := a117(indx);
          t(ddindx).attribute3 := a118(indx);
          t(ddindx).attribute4 := a119(indx);
          t(ddindx).attribute5 := a120(indx);
          t(ddindx).attribute6 := a121(indx);
          t(ddindx).attribute7 := a122(indx);
          t(ddindx).attribute8 := a123(indx);
          t(ddindx).attribute9 := a124(indx);
          t(ddindx).attribute10 := a125(indx);
          t(ddindx).attribute11 := a126(indx);
          t(ddindx).attribute12 := a127(indx);
          t(ddindx).attribute13 := a128(indx);
          t(ddindx).attribute14 := a129(indx);
          t(ddindx).attribute15 := a130(indx);
          t(ddindx).override_flag := a131(indx);
          t(ddindx).return_status := a132(indx);
          t(ddindx).db_flag := a133(indx);
          t(ddindx).operation := a134(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a135(indx));
          t(ddindx).orig_sys_atts_ref := a136(indx);
          t(ddindx).change_request_code := a137(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p27;
  procedure rosetta_table_copy_out_p27(t oe_order_pub.line_price_att_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a112 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a113 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a114 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a135 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
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
    a30 := JTF_VARCHAR2_TABLE_300();
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
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_300();
    a55 := JTF_VARCHAR2_TABLE_300();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_VARCHAR2_TABLE_300();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_VARCHAR2_TABLE_300();
    a63 := JTF_VARCHAR2_TABLE_300();
    a64 := JTF_VARCHAR2_TABLE_300();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_300();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_300();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_300();
    a71 := JTF_VARCHAR2_TABLE_300();
    a72 := JTF_VARCHAR2_TABLE_300();
    a73 := JTF_VARCHAR2_TABLE_300();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_300();
    a76 := JTF_VARCHAR2_TABLE_300();
    a77 := JTF_VARCHAR2_TABLE_300();
    a78 := JTF_VARCHAR2_TABLE_300();
    a79 := JTF_VARCHAR2_TABLE_300();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_300();
    a83 := JTF_VARCHAR2_TABLE_300();
    a84 := JTF_VARCHAR2_TABLE_300();
    a85 := JTF_VARCHAR2_TABLE_300();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_VARCHAR2_TABLE_300();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_300();
    a96 := JTF_VARCHAR2_TABLE_300();
    a97 := JTF_VARCHAR2_TABLE_300();
    a98 := JTF_VARCHAR2_TABLE_300();
    a99 := JTF_VARCHAR2_TABLE_300();
    a100 := JTF_VARCHAR2_TABLE_300();
    a101 := JTF_VARCHAR2_TABLE_300();
    a102 := JTF_VARCHAR2_TABLE_300();
    a103 := JTF_VARCHAR2_TABLE_300();
    a104 := JTF_VARCHAR2_TABLE_300();
    a105 := JTF_VARCHAR2_TABLE_300();
    a106 := JTF_VARCHAR2_TABLE_300();
    a107 := JTF_VARCHAR2_TABLE_300();
    a108 := JTF_VARCHAR2_TABLE_300();
    a109 := JTF_VARCHAR2_TABLE_300();
    a110 := JTF_VARCHAR2_TABLE_300();
    a111 := JTF_VARCHAR2_TABLE_300();
    a112 := JTF_VARCHAR2_TABLE_300();
    a113 := JTF_VARCHAR2_TABLE_300();
    a114 := JTF_VARCHAR2_TABLE_300();
    a115 := JTF_VARCHAR2_TABLE_100();
    a116 := JTF_VARCHAR2_TABLE_300();
    a117 := JTF_VARCHAR2_TABLE_300();
    a118 := JTF_VARCHAR2_TABLE_300();
    a119 := JTF_VARCHAR2_TABLE_300();
    a120 := JTF_VARCHAR2_TABLE_300();
    a121 := JTF_VARCHAR2_TABLE_300();
    a122 := JTF_VARCHAR2_TABLE_300();
    a123 := JTF_VARCHAR2_TABLE_300();
    a124 := JTF_VARCHAR2_TABLE_300();
    a125 := JTF_VARCHAR2_TABLE_300();
    a126 := JTF_VARCHAR2_TABLE_300();
    a127 := JTF_VARCHAR2_TABLE_300();
    a128 := JTF_VARCHAR2_TABLE_300();
    a129 := JTF_VARCHAR2_TABLE_300();
    a130 := JTF_VARCHAR2_TABLE_300();
    a131 := JTF_VARCHAR2_TABLE_100();
    a132 := JTF_VARCHAR2_TABLE_100();
    a133 := JTF_VARCHAR2_TABLE_100();
    a134 := JTF_VARCHAR2_TABLE_100();
    a135 := JTF_NUMBER_TABLE();
    a136 := JTF_VARCHAR2_TABLE_100();
    a137 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
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
      a30 := JTF_VARCHAR2_TABLE_300();
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
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_300();
      a55 := JTF_VARCHAR2_TABLE_300();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_VARCHAR2_TABLE_300();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_VARCHAR2_TABLE_300();
      a63 := JTF_VARCHAR2_TABLE_300();
      a64 := JTF_VARCHAR2_TABLE_300();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_300();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_300();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_300();
      a71 := JTF_VARCHAR2_TABLE_300();
      a72 := JTF_VARCHAR2_TABLE_300();
      a73 := JTF_VARCHAR2_TABLE_300();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_300();
      a76 := JTF_VARCHAR2_TABLE_300();
      a77 := JTF_VARCHAR2_TABLE_300();
      a78 := JTF_VARCHAR2_TABLE_300();
      a79 := JTF_VARCHAR2_TABLE_300();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_300();
      a83 := JTF_VARCHAR2_TABLE_300();
      a84 := JTF_VARCHAR2_TABLE_300();
      a85 := JTF_VARCHAR2_TABLE_300();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_VARCHAR2_TABLE_300();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_300();
      a96 := JTF_VARCHAR2_TABLE_300();
      a97 := JTF_VARCHAR2_TABLE_300();
      a98 := JTF_VARCHAR2_TABLE_300();
      a99 := JTF_VARCHAR2_TABLE_300();
      a100 := JTF_VARCHAR2_TABLE_300();
      a101 := JTF_VARCHAR2_TABLE_300();
      a102 := JTF_VARCHAR2_TABLE_300();
      a103 := JTF_VARCHAR2_TABLE_300();
      a104 := JTF_VARCHAR2_TABLE_300();
      a105 := JTF_VARCHAR2_TABLE_300();
      a106 := JTF_VARCHAR2_TABLE_300();
      a107 := JTF_VARCHAR2_TABLE_300();
      a108 := JTF_VARCHAR2_TABLE_300();
      a109 := JTF_VARCHAR2_TABLE_300();
      a110 := JTF_VARCHAR2_TABLE_300();
      a111 := JTF_VARCHAR2_TABLE_300();
      a112 := JTF_VARCHAR2_TABLE_300();
      a113 := JTF_VARCHAR2_TABLE_300();
      a114 := JTF_VARCHAR2_TABLE_300();
      a115 := JTF_VARCHAR2_TABLE_100();
      a116 := JTF_VARCHAR2_TABLE_300();
      a117 := JTF_VARCHAR2_TABLE_300();
      a118 := JTF_VARCHAR2_TABLE_300();
      a119 := JTF_VARCHAR2_TABLE_300();
      a120 := JTF_VARCHAR2_TABLE_300();
      a121 := JTF_VARCHAR2_TABLE_300();
      a122 := JTF_VARCHAR2_TABLE_300();
      a123 := JTF_VARCHAR2_TABLE_300();
      a124 := JTF_VARCHAR2_TABLE_300();
      a125 := JTF_VARCHAR2_TABLE_300();
      a126 := JTF_VARCHAR2_TABLE_300();
      a127 := JTF_VARCHAR2_TABLE_300();
      a128 := JTF_VARCHAR2_TABLE_300();
      a129 := JTF_VARCHAR2_TABLE_300();
      a130 := JTF_VARCHAR2_TABLE_300();
      a131 := JTF_VARCHAR2_TABLE_100();
      a132 := JTF_VARCHAR2_TABLE_100();
      a133 := JTF_VARCHAR2_TABLE_100();
      a134 := JTF_VARCHAR2_TABLE_100();
      a135 := JTF_NUMBER_TABLE();
      a136 := JTF_VARCHAR2_TABLE_100();
      a137 := JTF_VARCHAR2_TABLE_100();
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
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).order_price_attrib_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).line_index);
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := t(ddindx).last_update_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a11(indx) := t(ddindx).program_update_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a13(indx) := t(ddindx).flex_title;
          a14(indx) := t(ddindx).pricing_context;
          a15(indx) := t(ddindx).pricing_attribute1;
          a16(indx) := t(ddindx).pricing_attribute2;
          a17(indx) := t(ddindx).pricing_attribute3;
          a18(indx) := t(ddindx).pricing_attribute4;
          a19(indx) := t(ddindx).pricing_attribute5;
          a20(indx) := t(ddindx).pricing_attribute6;
          a21(indx) := t(ddindx).pricing_attribute7;
          a22(indx) := t(ddindx).pricing_attribute8;
          a23(indx) := t(ddindx).pricing_attribute9;
          a24(indx) := t(ddindx).pricing_attribute10;
          a25(indx) := t(ddindx).pricing_attribute11;
          a26(indx) := t(ddindx).pricing_attribute12;
          a27(indx) := t(ddindx).pricing_attribute13;
          a28(indx) := t(ddindx).pricing_attribute14;
          a29(indx) := t(ddindx).pricing_attribute15;
          a30(indx) := t(ddindx).pricing_attribute16;
          a31(indx) := t(ddindx).pricing_attribute17;
          a32(indx) := t(ddindx).pricing_attribute18;
          a33(indx) := t(ddindx).pricing_attribute19;
          a34(indx) := t(ddindx).pricing_attribute20;
          a35(indx) := t(ddindx).pricing_attribute21;
          a36(indx) := t(ddindx).pricing_attribute22;
          a37(indx) := t(ddindx).pricing_attribute23;
          a38(indx) := t(ddindx).pricing_attribute24;
          a39(indx) := t(ddindx).pricing_attribute25;
          a40(indx) := t(ddindx).pricing_attribute26;
          a41(indx) := t(ddindx).pricing_attribute27;
          a42(indx) := t(ddindx).pricing_attribute28;
          a43(indx) := t(ddindx).pricing_attribute29;
          a44(indx) := t(ddindx).pricing_attribute30;
          a45(indx) := t(ddindx).pricing_attribute31;
          a46(indx) := t(ddindx).pricing_attribute32;
          a47(indx) := t(ddindx).pricing_attribute33;
          a48(indx) := t(ddindx).pricing_attribute34;
          a49(indx) := t(ddindx).pricing_attribute35;
          a50(indx) := t(ddindx).pricing_attribute36;
          a51(indx) := t(ddindx).pricing_attribute37;
          a52(indx) := t(ddindx).pricing_attribute38;
          a53(indx) := t(ddindx).pricing_attribute39;
          a54(indx) := t(ddindx).pricing_attribute40;
          a55(indx) := t(ddindx).pricing_attribute41;
          a56(indx) := t(ddindx).pricing_attribute42;
          a57(indx) := t(ddindx).pricing_attribute43;
          a58(indx) := t(ddindx).pricing_attribute44;
          a59(indx) := t(ddindx).pricing_attribute45;
          a60(indx) := t(ddindx).pricing_attribute46;
          a61(indx) := t(ddindx).pricing_attribute47;
          a62(indx) := t(ddindx).pricing_attribute48;
          a63(indx) := t(ddindx).pricing_attribute49;
          a64(indx) := t(ddindx).pricing_attribute50;
          a65(indx) := t(ddindx).pricing_attribute51;
          a66(indx) := t(ddindx).pricing_attribute52;
          a67(indx) := t(ddindx).pricing_attribute53;
          a68(indx) := t(ddindx).pricing_attribute54;
          a69(indx) := t(ddindx).pricing_attribute55;
          a70(indx) := t(ddindx).pricing_attribute56;
          a71(indx) := t(ddindx).pricing_attribute57;
          a72(indx) := t(ddindx).pricing_attribute58;
          a73(indx) := t(ddindx).pricing_attribute59;
          a74(indx) := t(ddindx).pricing_attribute60;
          a75(indx) := t(ddindx).pricing_attribute61;
          a76(indx) := t(ddindx).pricing_attribute62;
          a77(indx) := t(ddindx).pricing_attribute63;
          a78(indx) := t(ddindx).pricing_attribute64;
          a79(indx) := t(ddindx).pricing_attribute65;
          a80(indx) := t(ddindx).pricing_attribute66;
          a81(indx) := t(ddindx).pricing_attribute67;
          a82(indx) := t(ddindx).pricing_attribute68;
          a83(indx) := t(ddindx).pricing_attribute69;
          a84(indx) := t(ddindx).pricing_attribute70;
          a85(indx) := t(ddindx).pricing_attribute71;
          a86(indx) := t(ddindx).pricing_attribute72;
          a87(indx) := t(ddindx).pricing_attribute73;
          a88(indx) := t(ddindx).pricing_attribute74;
          a89(indx) := t(ddindx).pricing_attribute75;
          a90(indx) := t(ddindx).pricing_attribute76;
          a91(indx) := t(ddindx).pricing_attribute77;
          a92(indx) := t(ddindx).pricing_attribute78;
          a93(indx) := t(ddindx).pricing_attribute79;
          a94(indx) := t(ddindx).pricing_attribute80;
          a95(indx) := t(ddindx).pricing_attribute81;
          a96(indx) := t(ddindx).pricing_attribute82;
          a97(indx) := t(ddindx).pricing_attribute83;
          a98(indx) := t(ddindx).pricing_attribute84;
          a99(indx) := t(ddindx).pricing_attribute85;
          a100(indx) := t(ddindx).pricing_attribute86;
          a101(indx) := t(ddindx).pricing_attribute87;
          a102(indx) := t(ddindx).pricing_attribute88;
          a103(indx) := t(ddindx).pricing_attribute89;
          a104(indx) := t(ddindx).pricing_attribute90;
          a105(indx) := t(ddindx).pricing_attribute91;
          a106(indx) := t(ddindx).pricing_attribute92;
          a107(indx) := t(ddindx).pricing_attribute93;
          a108(indx) := t(ddindx).pricing_attribute94;
          a109(indx) := t(ddindx).pricing_attribute95;
          a110(indx) := t(ddindx).pricing_attribute96;
          a111(indx) := t(ddindx).pricing_attribute97;
          a112(indx) := t(ddindx).pricing_attribute98;
          a113(indx) := t(ddindx).pricing_attribute99;
          a114(indx) := t(ddindx).pricing_attribute100;
          a115(indx) := t(ddindx).context;
          a116(indx) := t(ddindx).attribute1;
          a117(indx) := t(ddindx).attribute2;
          a118(indx) := t(ddindx).attribute3;
          a119(indx) := t(ddindx).attribute4;
          a120(indx) := t(ddindx).attribute5;
          a121(indx) := t(ddindx).attribute6;
          a122(indx) := t(ddindx).attribute7;
          a123(indx) := t(ddindx).attribute8;
          a124(indx) := t(ddindx).attribute9;
          a125(indx) := t(ddindx).attribute10;
          a126(indx) := t(ddindx).attribute11;
          a127(indx) := t(ddindx).attribute12;
          a128(indx) := t(ddindx).attribute13;
          a129(indx) := t(ddindx).attribute14;
          a130(indx) := t(ddindx).attribute15;
          a131(indx) := t(ddindx).override_flag;
          a132(indx) := t(ddindx).return_status;
          a133(indx) := t(ddindx).db_flag;
          a134(indx) := t(ddindx).operation;
          a135(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          a136(indx) := t(ddindx).orig_sys_atts_ref;
          a137(indx) := t(ddindx).change_request_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p27;

  procedure rosetta_table_copy_in_p29(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_adj_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).price_adj_attrib_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).price_adjustment_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).adj_index := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).flex_title := a3(indx);
          t(ddindx).pricing_context := a4(indx);
          t(ddindx).pricing_attribute := a5(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).pricing_attr_value_from := a15(indx);
          t(ddindx).pricing_attr_value_to := a16(indx);
          t(ddindx).comparison_operator := a17(indx);
          t(ddindx).return_status := a18(indx);
          t(ddindx).db_flag := a19(indx);
          t(ddindx).operation := a20(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a21(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p29;
  procedure rosetta_table_copy_out_p29(t oe_order_pub.line_adj_att_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
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
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).price_adj_attrib_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).price_adjustment_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).adj_index);
          a3(indx) := t(ddindx).flex_title;
          a4(indx) := t(ddindx).pricing_context;
          a5(indx) := t(ddindx).pricing_attribute;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a13(indx) := t(ddindx).program_update_date;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a15(indx) := t(ddindx).pricing_attr_value_from;
          a16(indx) := t(ddindx).pricing_attr_value_to;
          a17(indx) := t(ddindx).comparison_operator;
          a18(indx) := t(ddindx).return_status;
          a19(indx) := t(ddindx).db_flag;
          a20(indx) := t(ddindx).operation;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p29;

  procedure rosetta_table_copy_in_p31(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_adj_assoc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).price_adj_assoc_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).line_index := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).price_adjustment_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).adj_index := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).rltd_price_adj_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).rltd_adj_index := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).return_status := a16(indx);
          t(ddindx).db_flag := a17(indx);
          t(ddindx).operation := a18(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a19(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t oe_order_pub.line_adj_assoc_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).price_adj_assoc_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).line_index);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).price_adjustment_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).adj_index);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).rltd_price_adj_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).rltd_adj_index);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a14(indx) := t(ddindx).program_update_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a16(indx) := t(ddindx).return_status;
          a17(indx) := t(ddindx).db_flag;
          a18(indx) := t(ddindx).operation;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p31;

  procedure rosetta_table_copy_in_p33(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_scredit_tbl_type, a0 JTF_VARCHAR2_TABLE_300
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_2000
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute1 := a0(indx);
          t(ddindx).attribute10 := a1(indx);
          t(ddindx).attribute11 := a2(indx);
          t(ddindx).attribute12 := a3(indx);
          t(ddindx).attribute13 := a4(indx);
          t(ddindx).attribute14 := a5(indx);
          t(ddindx).attribute15 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).context := a15(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).dw_update_advice_flag := a18(indx);
          t(ddindx).header_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).salesrep_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).sales_credit_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).sales_credit_type_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).wh_update_date := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).return_status := a29(indx);
          t(ddindx).db_flag := a30(indx);
          t(ddindx).operation := a31(indx);
          t(ddindx).line_index := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).orig_sys_credit_ref := a33(indx);
          t(ddindx).change_request_code := a34(indx);
          t(ddindx).status_flag := a35(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).change_reason := a37(indx);
          t(ddindx).change_comments := a38(indx);
          t(ddindx).sales_group_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).sales_group_updated_flag := a40(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p33;
  procedure rosetta_table_copy_out_p33(t oe_order_pub.line_scredit_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_2000();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_2000();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).attribute1;
          a1(indx) := t(ddindx).attribute10;
          a2(indx) := t(ddindx).attribute11;
          a3(indx) := t(ddindx).attribute12;
          a4(indx) := t(ddindx).attribute13;
          a5(indx) := t(ddindx).attribute14;
          a6(indx) := t(ddindx).attribute15;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).context;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a17(indx) := t(ddindx).creation_date;
          a18(indx) := t(ddindx).dw_update_advice_flag;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a21(indx) := t(ddindx).last_update_date;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).salesrep_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).sales_credit_id);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).sales_credit_type_id);
          a28(indx) := t(ddindx).wh_update_date;
          a29(indx) := t(ddindx).return_status;
          a30(indx) := t(ddindx).db_flag;
          a31(indx) := t(ddindx).operation;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).line_index);
          a33(indx) := t(ddindx).orig_sys_credit_ref;
          a34(indx) := t(ddindx).change_request_code;
          a35(indx) := t(ddindx).status_flag;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          a37(indx) := t(ddindx).change_reason;
          a38(indx) := t(ddindx).change_comments;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).sales_group_id);
          a40(indx) := t(ddindx).sales_group_updated_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p33;

  procedure rosetta_table_copy_in_p35(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_scredit_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).salesrep := a0(indx);
          t(ddindx).sales_credit_type := a1(indx);
          t(ddindx).sales_group := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p35;
  procedure rosetta_table_copy_out_p35(t oe_order_pub.line_scredit_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).salesrep;
          a1(indx) := t(ddindx).sales_credit_type;
          a2(indx) := t(ddindx).sales_group;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p35;

  procedure rosetta_table_copy_in_p37(t out NOCOPY /* file.sql.39 change */ oe_order_pub.lot_serial_tbl_type, a0 JTF_VARCHAR2_TABLE_300
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute1 := a0(indx);
          t(ddindx).attribute10 := a1(indx);
          t(ddindx).attribute11 := a2(indx);
          t(ddindx).attribute12 := a3(indx);
          t(ddindx).attribute13 := a4(indx);
          t(ddindx).attribute14 := a5(indx);
          t(ddindx).attribute15 := a6(indx);
          t(ddindx).attribute2 := a7(indx);
          t(ddindx).attribute3 := a8(indx);
          t(ddindx).attribute4 := a9(indx);
          t(ddindx).attribute5 := a10(indx);
          t(ddindx).attribute6 := a11(indx);
          t(ddindx).attribute7 := a12(indx);
          t(ddindx).attribute8 := a13(indx);
          t(ddindx).attribute9 := a14(indx);
          t(ddindx).context := a15(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).from_serial_number := a18(indx);
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).lot_number := a23(indx);
          t(ddindx).sublot_number := a24(indx);
          t(ddindx).lot_serial_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).quantity := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).quantity2 := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).to_serial_number := a28(indx);
          t(ddindx).return_status := a29(indx);
          t(ddindx).db_flag := a30(indx);
          t(ddindx).operation := a31(indx);
          t(ddindx).line_index := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).orig_sys_lotserial_ref := a33(indx);
          t(ddindx).change_request_code := a34(indx);
          t(ddindx).status_flag := a35(indx);
          t(ddindx).line_set_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).lock_control := rosetta_g_miss_num_map(a37(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p37;
  procedure rosetta_table_copy_out_p37(t oe_order_pub.lot_serial_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute1;
          a1(indx) := t(ddindx).attribute10;
          a2(indx) := t(ddindx).attribute11;
          a3(indx) := t(ddindx).attribute12;
          a4(indx) := t(ddindx).attribute13;
          a5(indx) := t(ddindx).attribute14;
          a6(indx) := t(ddindx).attribute15;
          a7(indx) := t(ddindx).attribute2;
          a8(indx) := t(ddindx).attribute3;
          a9(indx) := t(ddindx).attribute4;
          a10(indx) := t(ddindx).attribute5;
          a11(indx) := t(ddindx).attribute6;
          a12(indx) := t(ddindx).attribute7;
          a13(indx) := t(ddindx).attribute8;
          a14(indx) := t(ddindx).attribute9;
          a15(indx) := t(ddindx).context;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a17(indx) := t(ddindx).creation_date;
          a18(indx) := t(ddindx).from_serial_number;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a20(indx) := t(ddindx).last_update_date;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a23(indx) := t(ddindx).lot_number;
          a24(indx) := t(ddindx).sublot_number;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).lot_serial_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).quantity2);
          a28(indx) := t(ddindx).to_serial_number;
          a29(indx) := t(ddindx).return_status;
          a30(indx) := t(ddindx).db_flag;
          a31(indx) := t(ddindx).operation;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).line_index);
          a33(indx) := t(ddindx).orig_sys_lotserial_ref;
          a34(indx) := t(ddindx).change_request_code;
          a35(indx) := t(ddindx).status_flag;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).line_set_id);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p37;

  procedure rosetta_table_copy_in_p39(t out NOCOPY /* file.sql.39 change */ oe_order_pub.lot_serial_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line := a0(indx);
          t(ddindx).lot_serial := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p39;
  procedure rosetta_table_copy_out_p39(t oe_order_pub.lot_serial_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line;
          a1(indx) := t(ddindx).lot_serial;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p39;

  procedure rosetta_table_copy_in_p41(t out NOCOPY /* file.sql.39 change */ oe_order_pub.reservation_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).orig_sys_reservation_ref := a0(indx);
          t(ddindx).revision := a1(indx);
          t(ddindx).lot_number_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).subinventory_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).locator_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).quantity := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).attribute_category := a6(indx);
          t(ddindx).attribute1 := a7(indx);
          t(ddindx).attribute2 := a8(indx);
          t(ddindx).attribute3 := a9(indx);
          t(ddindx).attribute4 := a10(indx);
          t(ddindx).attribute5 := a11(indx);
          t(ddindx).attribute6 := a12(indx);
          t(ddindx).attribute7 := a13(indx);
          t(ddindx).attribute8 := a14(indx);
          t(ddindx).attribute9 := a15(indx);
          t(ddindx).attribute10 := a16(indx);
          t(ddindx).attribute11 := a17(indx);
          t(ddindx).attribute12 := a18(indx);
          t(ddindx).attribute13 := a19(indx);
          t(ddindx).attribute14 := a20(indx);
          t(ddindx).attribute15 := a21(indx);
          t(ddindx).operation := a22(indx);
          t(ddindx).status_flag := a23(indx);
          t(ddindx).return_status := a24(indx);
          t(ddindx).line_index := rosetta_g_miss_num_map(a25(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t oe_order_pub.reservation_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_300();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_300();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).orig_sys_reservation_ref;
          a1(indx) := t(ddindx).revision;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).lot_number_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).subinventory_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).locator_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a6(indx) := t(ddindx).attribute_category;
          a7(indx) := t(ddindx).attribute1;
          a8(indx) := t(ddindx).attribute2;
          a9(indx) := t(ddindx).attribute3;
          a10(indx) := t(ddindx).attribute4;
          a11(indx) := t(ddindx).attribute5;
          a12(indx) := t(ddindx).attribute6;
          a13(indx) := t(ddindx).attribute7;
          a14(indx) := t(ddindx).attribute8;
          a15(indx) := t(ddindx).attribute9;
          a16(indx) := t(ddindx).attribute10;
          a17(indx) := t(ddindx).attribute11;
          a18(indx) := t(ddindx).attribute12;
          a19(indx) := t(ddindx).attribute13;
          a20(indx) := t(ddindx).attribute14;
          a21(indx) := t(ddindx).attribute15;
          a22(indx) := t(ddindx).operation;
          a23(indx) := t(ddindx).status_flag;
          a24(indx) := t(ddindx).return_status;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).line_index);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure rosetta_table_copy_in_p43(t out NOCOPY /* file.sql.39 change */ oe_order_pub.reservation_val_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lot_number := a0(indx);
          t(ddindx).subinventory_code := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p43;
  procedure rosetta_table_copy_out_p43(t oe_order_pub.reservation_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).lot_number;
          a1(indx) := t(ddindx).subinventory_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p43;

  procedure rosetta_table_copy_in_p47(t out NOCOPY /* file.sql.39 change */ oe_order_pub.request_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
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
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_2000
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_DATE_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).entity_code := a0(indx);
          t(ddindx).entity_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).entity_index := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).request_type := a3(indx);
          t(ddindx).return_status := a4(indx);
          t(ddindx).request_unique_key1 := a5(indx);
          t(ddindx).request_unique_key2 := a6(indx);
          t(ddindx).request_unique_key3 := a7(indx);
          t(ddindx).request_unique_key4 := a8(indx);
          t(ddindx).request_unique_key5 := a9(indx);
          t(ddindx).param1 := a10(indx);
          t(ddindx).param2 := a11(indx);
          t(ddindx).param3 := a12(indx);
          t(ddindx).param4 := a13(indx);
          t(ddindx).param5 := a14(indx);
          t(ddindx).param6 := a15(indx);
          t(ddindx).param7 := a16(indx);
          t(ddindx).param8 := a17(indx);
          t(ddindx).param9 := a18(indx);
          t(ddindx).param10 := a19(indx);
          t(ddindx).param11 := a20(indx);
          t(ddindx).param12 := a21(indx);
          t(ddindx).param13 := a22(indx);
          t(ddindx).param14 := a23(indx);
          t(ddindx).param15 := a24(indx);
          t(ddindx).param16 := a25(indx);
          t(ddindx).param17 := a26(indx);
          t(ddindx).param18 := a27(indx);
          t(ddindx).param19 := a28(indx);
          t(ddindx).param20 := a29(indx);
          t(ddindx).param21 := a30(indx);
          t(ddindx).param22 := a31(indx);
          t(ddindx).param23 := a32(indx);
          t(ddindx).param24 := a33(indx);
          t(ddindx).param25 := a34(indx);
          t(ddindx).long_param1 := a35(indx);
          t(ddindx).date_param1 := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).date_param2 := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).date_param3 := rosetta_g_miss_date_in_map(a38(indx));
          t(ddindx).date_param4 := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).date_param5 := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).date_param6 := rosetta_g_miss_date_in_map(a41(indx));
          t(ddindx).date_param7 := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).date_param8 := rosetta_g_miss_date_in_map(a43(indx));
          t(ddindx).processed := a44(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p47;
  procedure rosetta_table_copy_out_p47(t oe_order_pub.request_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a36 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a38 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a41 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a42 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a43 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
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
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_2000();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_DATE_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
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
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_2000();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_DATE_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).entity_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).entity_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).entity_index);
          a3(indx) := t(ddindx).request_type;
          a4(indx) := t(ddindx).return_status;
          a5(indx) := t(ddindx).request_unique_key1;
          a6(indx) := t(ddindx).request_unique_key2;
          a7(indx) := t(ddindx).request_unique_key3;
          a8(indx) := t(ddindx).request_unique_key4;
          a9(indx) := t(ddindx).request_unique_key5;
          a10(indx) := t(ddindx).param1;
          a11(indx) := t(ddindx).param2;
          a12(indx) := t(ddindx).param3;
          a13(indx) := t(ddindx).param4;
          a14(indx) := t(ddindx).param5;
          a15(indx) := t(ddindx).param6;
          a16(indx) := t(ddindx).param7;
          a17(indx) := t(ddindx).param8;
          a18(indx) := t(ddindx).param9;
          a19(indx) := t(ddindx).param10;
          a20(indx) := t(ddindx).param11;
          a21(indx) := t(ddindx).param12;
          a22(indx) := t(ddindx).param13;
          a23(indx) := t(ddindx).param14;
          a24(indx) := t(ddindx).param15;
          a25(indx) := t(ddindx).param16;
          a26(indx) := t(ddindx).param17;
          a27(indx) := t(ddindx).param18;
          a28(indx) := t(ddindx).param19;
          a29(indx) := t(ddindx).param20;
          a30(indx) := t(ddindx).param21;
          a31(indx) := t(ddindx).param22;
          a32(indx) := t(ddindx).param23;
          a33(indx) := t(ddindx).param24;
          a34(indx) := t(ddindx).param25;
          a35(indx) := t(ddindx).long_param1;
          a36(indx) := t(ddindx).date_param1;
          a37(indx) := t(ddindx).date_param2;
          a38(indx) := t(ddindx).date_param3;
          a39(indx) := t(ddindx).date_param4;
          a40(indx) := t(ddindx).date_param5;
          a41(indx) := t(ddindx).date_param6;
          a42(indx) := t(ddindx).date_param7;
          a43(indx) := t(ddindx).date_param8;
          a44(indx) := t(ddindx).processed;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p47;

  procedure rosetta_table_copy_in_p49(t out NOCOPY /* file.sql.39 change */ oe_order_pub.requesting_entity_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).entity_code := a0(indx);
          t(ddindx).entity_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).request_index := rosetta_g_miss_num_map(a2(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p49;
  procedure rosetta_table_copy_out_p49(t oe_order_pub.requesting_entity_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).entity_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).entity_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).request_index);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p49;

  procedure rosetta_table_copy_in_p51(t out NOCOPY /* file.sql.39 change */ oe_order_pub.cancel_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).header_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).cancellation_type := a2(indx);
          t(ddindx).cancel_by_quantity := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).cancellation_reason_code := a4(indx);
          t(ddindx).cancellation_comments := a5(indx);
          t(ddindx).security_result := a6(indx);
          t(ddindx).business_object := a7(indx);
          t(ddindx).wf_item_type := a8(indx);
          t(ddindx).user_app_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).user_resp_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).cancellation_result := a11(indx);
          t(ddindx).wf_cancellation := a12(indx);
          t(ddindx).resolving_activity_item_type := a13(indx);
          t(ddindx).resolving_activity_name := a14(indx);
          t(ddindx).resolving_responsibility_id := rosetta_g_miss_num_map(a15(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p51;
  procedure rosetta_table_copy_out_p51(t oe_order_pub.cancel_line_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a15 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a2(indx) := t(ddindx).cancellation_type;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).cancel_by_quantity);
          a4(indx) := t(ddindx).cancellation_reason_code;
          a5(indx) := t(ddindx).cancellation_comments;
          a6(indx) := t(ddindx).security_result;
          a7(indx) := t(ddindx).business_object;
          a8(indx) := t(ddindx).wf_item_type;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).user_app_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).user_resp_id);
          a11(indx) := t(ddindx).cancellation_result;
          a12(indx) := t(ddindx).wf_cancellation;
          a13(indx) := t(ddindx).resolving_activity_item_type;
          a14(indx) := t(ddindx).resolving_activity_name;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).resolving_responsibility_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p51;

  procedure rosetta_table_copy_in_p53(t out NOCOPY /* file.sql.39 change */ oe_order_pub.payment_types_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
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
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).payment_trx_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).commitment_applied_amount := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).commitment_interfaced_amount := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).payment_level_code := a3(indx);
          t(ddindx).header_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a14(indx));
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
          t(ddindx).db_flag := a31(indx);
          t(ddindx).operation := a32(indx);
          t(ddindx).return_status := a33(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p53;
  procedure rosetta_table_copy_out_p53(t oe_order_pub.payment_types_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
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
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
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
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
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
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
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
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).payment_trx_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_applied_amount);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_interfaced_amount);
          a3(indx) := t(ddindx).payment_level_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a14(indx) := t(ddindx).program_update_date;
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
          a31(indx) := t(ddindx).db_flag;
          a32(indx) := t(ddindx).operation;
          a33(indx) := t(ddindx).return_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p53;

  procedure rosetta_table_copy_in_p55(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_payment_tbl_type, a0 JTF_VARCHAR2_TABLE_300
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute1 := a0(indx);
          t(ddindx).attribute2 := a1(indx);
          t(ddindx).attribute3 := a2(indx);
          t(ddindx).attribute4 := a3(indx);
          t(ddindx).attribute5 := a4(indx);
          t(ddindx).attribute6 := a5(indx);
          t(ddindx).attribute7 := a6(indx);
          t(ddindx).attribute8 := a7(indx);
          t(ddindx).attribute9 := a8(indx);
          t(ddindx).attribute10 := a9(indx);
          t(ddindx).attribute11 := a10(indx);
          t(ddindx).attribute12 := a11(indx);
          t(ddindx).attribute13 := a12(indx);
          t(ddindx).attribute14 := a13(indx);
          t(ddindx).attribute15 := a14(indx);
          t(ddindx).check_number := a15(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).credit_card_approval_code := a18(indx);
          t(ddindx).credit_card_approval_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).credit_card_code := a20(indx);
          t(ddindx).credit_card_expiration_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).credit_card_holder_name := a22(indx);
          t(ddindx).credit_card_number := a23(indx);
          t(ddindx).commitment_applied_amount := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).commitment_interfaced_amount := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).context := a26(indx);
          t(ddindx).header_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).payment_number := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).payment_amount := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).payment_collection_event := a34(indx);
          t(ddindx).payment_level_code := a35(indx);
          t(ddindx).payment_trx_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).payment_type_code := a37(indx);
          t(ddindx).payment_set_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).prepaid_amount := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).receipt_method_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).tangible_id := a45(indx);
          t(ddindx).orig_sys_payment_ref := a46(indx);
          t(ddindx).change_request_code := a47(indx);
          t(ddindx).status_flag := a48(indx);
          t(ddindx).return_status := a49(indx);
          t(ddindx).db_flag := a50(indx);
          t(ddindx).operation := a51(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a52(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p55;
  procedure rosetta_table_copy_out_p55(t oe_order_pub.header_payment_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a41 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a42 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a43 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a44 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a52 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute1;
          a1(indx) := t(ddindx).attribute2;
          a2(indx) := t(ddindx).attribute3;
          a3(indx) := t(ddindx).attribute4;
          a4(indx) := t(ddindx).attribute5;
          a5(indx) := t(ddindx).attribute6;
          a6(indx) := t(ddindx).attribute7;
          a7(indx) := t(ddindx).attribute8;
          a8(indx) := t(ddindx).attribute9;
          a9(indx) := t(ddindx).attribute10;
          a10(indx) := t(ddindx).attribute11;
          a11(indx) := t(ddindx).attribute12;
          a12(indx) := t(ddindx).attribute13;
          a13(indx) := t(ddindx).attribute14;
          a14(indx) := t(ddindx).attribute15;
          a15(indx) := t(ddindx).check_number;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a17(indx) := t(ddindx).creation_date;
          a18(indx) := t(ddindx).credit_card_approval_code;
          a19(indx) := t(ddindx).credit_card_approval_date;
          a20(indx) := t(ddindx).credit_card_code;
          a21(indx) := t(ddindx).credit_card_expiration_date;
          a22(indx) := t(ddindx).credit_card_holder_name;
          a23(indx) := t(ddindx).credit_card_number;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_applied_amount);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_interfaced_amount);
          a26(indx) := t(ddindx).context;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a29(indx) := t(ddindx).last_update_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).payment_number);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).payment_amount);
          a34(indx) := t(ddindx).payment_collection_event;
          a35(indx) := t(ddindx).payment_level_code;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).payment_trx_id);
          a37(indx) := t(ddindx).payment_type_code;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).payment_set_id);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).prepaid_amount);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a42(indx) := t(ddindx).program_update_date;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).receipt_method_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a45(indx) := t(ddindx).tangible_id;
          a46(indx) := t(ddindx).orig_sys_payment_ref;
          a47(indx) := t(ddindx).change_request_code;
          a48(indx) := t(ddindx).status_flag;
          a49(indx) := t(ddindx).return_status;
          a50(indx) := t(ddindx).db_flag;
          a51(indx) := t(ddindx).operation;
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p55;

  procedure rosetta_table_copy_in_p57(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_payment_val_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).payment_collection_event_name := a0(indx);
          t(ddindx).receipt_method := a1(indx);
          t(ddindx).payment_type := a2(indx);
          t(ddindx).commitment := a3(indx);
          t(ddindx).payment_percentage := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p57;
  procedure rosetta_table_copy_out_p57(t oe_order_pub.header_payment_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).payment_collection_event_name;
          a1(indx) := t(ddindx).receipt_method;
          a2(indx) := t(ddindx).payment_type;
          a3(indx) := t(ddindx).commitment;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).payment_percentage);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p57;

  procedure rosetta_table_copy_in_p59(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_payment_tbl_type, a0 JTF_VARCHAR2_TABLE_300
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
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute1 := a0(indx);
          t(ddindx).attribute2 := a1(indx);
          t(ddindx).attribute3 := a2(indx);
          t(ddindx).attribute4 := a3(indx);
          t(ddindx).attribute5 := a4(indx);
          t(ddindx).attribute6 := a5(indx);
          t(ddindx).attribute7 := a6(indx);
          t(ddindx).attribute8 := a7(indx);
          t(ddindx).attribute9 := a8(indx);
          t(ddindx).attribute10 := a9(indx);
          t(ddindx).attribute11 := a10(indx);
          t(ddindx).attribute12 := a11(indx);
          t(ddindx).attribute13 := a12(indx);
          t(ddindx).attribute14 := a13(indx);
          t(ddindx).attribute15 := a14(indx);
          t(ddindx).check_number := a15(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).credit_card_approval_code := a18(indx);
          t(ddindx).credit_card_approval_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).credit_card_code := a20(indx);
          t(ddindx).credit_card_expiration_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).credit_card_holder_name := a22(indx);
          t(ddindx).credit_card_number := a23(indx);
          t(ddindx).commitment_applied_amount := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).commitment_interfaced_amount := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).context := a26(indx);
          t(ddindx).header_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).payment_number := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).payment_amount := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).payment_collection_event := a34(indx);
          t(ddindx).payment_level_code := a35(indx);
          t(ddindx).payment_trx_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).payment_type_code := a37(indx);
          t(ddindx).payment_set_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).prepaid_amount := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).receipt_method_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).tangible_id := a45(indx);
          t(ddindx).orig_sys_payment_ref := a46(indx);
          t(ddindx).change_request_code := a47(indx);
          t(ddindx).status_flag := a48(indx);
          t(ddindx).return_status := a49(indx);
          t(ddindx).db_flag := a50(indx);
          t(ddindx).line_index := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).operation := a52(indx);
          t(ddindx).lock_control := rosetta_g_miss_num_map(a53(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p59;
  procedure rosetta_table_copy_out_p59(t oe_order_pub.line_payment_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a41 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a42 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a43 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a44 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a51 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a53 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
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
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
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
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute1;
          a1(indx) := t(ddindx).attribute2;
          a2(indx) := t(ddindx).attribute3;
          a3(indx) := t(ddindx).attribute4;
          a4(indx) := t(ddindx).attribute5;
          a5(indx) := t(ddindx).attribute6;
          a6(indx) := t(ddindx).attribute7;
          a7(indx) := t(ddindx).attribute8;
          a8(indx) := t(ddindx).attribute9;
          a9(indx) := t(ddindx).attribute10;
          a10(indx) := t(ddindx).attribute11;
          a11(indx) := t(ddindx).attribute12;
          a12(indx) := t(ddindx).attribute13;
          a13(indx) := t(ddindx).attribute14;
          a14(indx) := t(ddindx).attribute15;
          a15(indx) := t(ddindx).check_number;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a17(indx) := t(ddindx).creation_date;
          a18(indx) := t(ddindx).credit_card_approval_code;
          a19(indx) := t(ddindx).credit_card_approval_date;
          a20(indx) := t(ddindx).credit_card_code;
          a21(indx) := t(ddindx).credit_card_expiration_date;
          a22(indx) := t(ddindx).credit_card_holder_name;
          a23(indx) := t(ddindx).credit_card_number;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_applied_amount);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).commitment_interfaced_amount);
          a26(indx) := t(ddindx).context;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a29(indx) := t(ddindx).last_update_date;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).payment_number);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).payment_amount);
          a34(indx) := t(ddindx).payment_collection_event;
          a35(indx) := t(ddindx).payment_level_code;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).payment_trx_id);
          a37(indx) := t(ddindx).payment_type_code;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).payment_set_id);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).prepaid_amount);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a42(indx) := t(ddindx).program_update_date;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).receipt_method_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a45(indx) := t(ddindx).tangible_id;
          a46(indx) := t(ddindx).orig_sys_payment_ref;
          a47(indx) := t(ddindx).change_request_code;
          a48(indx) := t(ddindx).status_flag;
          a49(indx) := t(ddindx).return_status;
          a50(indx) := t(ddindx).db_flag;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).line_index);
          a52(indx) := t(ddindx).operation;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).lock_control);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p59;

  procedure rosetta_table_copy_in_p61(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_payment_val_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).payment_collection_event_name := a0(indx);
          t(ddindx).receipt_method := a1(indx);
          t(ddindx).payment_type := a2(indx);
          t(ddindx).commitment := a3(indx);
          t(ddindx).payment_percentage := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p61;
  procedure rosetta_table_copy_out_p61(t oe_order_pub.line_payment_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).payment_collection_event_name;
          a1(indx) := t(ddindx).receipt_method;
          a2(indx) := t(ddindx).payment_type;
          a3(indx) := t(ddindx).commitment;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).payment_percentage);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p61;

end oe_order_pub_w;

/
