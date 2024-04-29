--------------------------------------------------------
--  DDL for Package Body CN_GET_TX_DATA_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_TX_DATA_PUB_W" as
  /* $Header: cnwxadjb.pls 120.5.12010000.3 2009/02/02 13:04:28 gmarwah ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_get_tx_data_pub.adj_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_1800
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
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
    , a129 JTF_NUMBER_TABLE
    , a130 JTF_VARCHAR2_TABLE_100
    , a131 JTF_NUMBER_TABLE
    , a132 JTF_VARCHAR2_TABLE_100
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_NUMBER_TABLE
    , a138 JTF_NUMBER_TABLE
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_NUMBER_TABLE
    , a141 JTF_NUMBER_TABLE
    , a142 JTF_VARCHAR2_TABLE_100
    , a143 JTF_NUMBER_TABLE
    , a144 JTF_NUMBER_TABLE
    , a145 JTF_NUMBER_TABLE
    , a146 JTF_NUMBER_TABLE
    , a147 JTF_DATE_TABLE
    , a148 JTF_NUMBER_TABLE
    , a149 JTF_VARCHAR2_TABLE_100
    , a150 JTF_DATE_TABLE
    , a151 JTF_NUMBER_TABLE
    , a152 JTF_DATE_TABLE
    , a153 JTF_NUMBER_TABLE
    , a154 JTF_NUMBER_TABLE
    , a155 JTF_NUMBER_TABLE
    , a156 JTF_NUMBER_TABLE
    , a157 JTF_NUMBER_TABLE
    , a158 JTF_NUMBER_TABLE
    , a159 JTF_VARCHAR2_TABLE_100
    , a160 JTF_VARCHAR2_TABLE_100
    , a161 JTF_VARCHAR2_TABLE_100
    , a162 JTF_VARCHAR2_TABLE_100
    , a163 JTF_DATE_TABLE
    , a164 JTF_VARCHAR2_TABLE_100
    , a165 JTF_VARCHAR2_TABLE_100
    , a166 JTF_VARCHAR2_TABLE_100
    , a167 JTF_VARCHAR2_TABLE_2000
    , a168 JTF_VARCHAR2_TABLE_100
    , a169 JTF_VARCHAR2_TABLE_100
    , a170 JTF_NUMBER_TABLE
    , a171 JTF_NUMBER_TABLE
    , a172 JTF_NUMBER_TABLE
    , a173 JTF_VARCHAR2_TABLE_100
    , a174 JTF_NUMBER_TABLE
    , a175 JTF_NUMBER_TABLE
    , a176 JTF_VARCHAR2_TABLE_100
    , a177 JTF_NUMBER_TABLE
    , a178 JTF_VARCHAR2_TABLE_100
    , a179 JTF_VARCHAR2_TABLE_100
    , a180 JTF_VARCHAR2_TABLE_100
    , a181 JTF_VARCHAR2_TABLE_100
    , a182 JTF_VARCHAR2_TABLE_100
    , a183 JTF_NUMBER_TABLE
    , a184 JTF_NUMBER_TABLE
    , a185 JTF_NUMBER_TABLE
    , a186 JTF_NUMBER_TABLE
    , a187 JTF_NUMBER_TABLE
    , a188 JTF_NUMBER_TABLE
    , a189 JTF_VARCHAR2_TABLE_100
    , a190 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).commission_header_id := a0(indx);
          t(ddindx).direct_salesrep_number := a1(indx);
          t(ddindx).direct_salesrep_name := a2(indx);
          t(ddindx).direct_salesrep_id := a3(indx);
          t(ddindx).processed_period_id := a4(indx);
          t(ddindx).processed_period := a5(indx);
          t(ddindx).processed_date := a6(indx);
          t(ddindx).rollup_date := a7(indx);
          t(ddindx).transaction_amount := a8(indx);
          t(ddindx).transaction_amount_orig := a9(indx);
          t(ddindx).quantity := a10(indx);
          t(ddindx).discount_percentage := a11(indx);
          t(ddindx).margin_percentage := a12(indx);
          t(ddindx).orig_currency_code := a13(indx);
          t(ddindx).exchange_rate := a14(indx);
          t(ddindx).status_disp := a15(indx);
          t(ddindx).status := a16(indx);
          t(ddindx).trx_type_disp := a17(indx);
          t(ddindx).trx_type := a18(indx);
          t(ddindx).reason := a19(indx);
          t(ddindx).reason_code := a20(indx);
          t(ddindx).comments := a21(indx);
          t(ddindx).trx_batch_id := a22(indx);
          t(ddindx).created_by := a23(indx);
          t(ddindx).creation_date := a24(indx);
          t(ddindx).last_updated_by := a25(indx);
          t(ddindx).last_update_login := a26(indx);
          t(ddindx).last_update_date := a27(indx);
          t(ddindx).attribute_category := a28(indx);
          t(ddindx).attribute1 := a29(indx);
          t(ddindx).attribute2 := a30(indx);
          t(ddindx).attribute3 := a31(indx);
          t(ddindx).attribute4 := a32(indx);
          t(ddindx).attribute5 := a33(indx);
          t(ddindx).attribute6 := a34(indx);
          t(ddindx).attribute7 := a35(indx);
          t(ddindx).attribute8 := a36(indx);
          t(ddindx).attribute9 := a37(indx);
          t(ddindx).attribute10 := a38(indx);
          t(ddindx).attribute11 := a39(indx);
          t(ddindx).attribute12 := a40(indx);
          t(ddindx).attribute13 := a41(indx);
          t(ddindx).attribute14 := a42(indx);
          t(ddindx).attribute15 := a43(indx);
          t(ddindx).attribute16 := a44(indx);
          t(ddindx).attribute17 := a45(indx);
          t(ddindx).attribute18 := a46(indx);
          t(ddindx).attribute19 := a47(indx);
          t(ddindx).attribute20 := a48(indx);
          t(ddindx).attribute21 := a49(indx);
          t(ddindx).attribute22 := a50(indx);
          t(ddindx).attribute23 := a51(indx);
          t(ddindx).attribute24 := a52(indx);
          t(ddindx).attribute25 := a53(indx);
          t(ddindx).attribute26 := a54(indx);
          t(ddindx).attribute27 := a55(indx);
          t(ddindx).attribute28 := a56(indx);
          t(ddindx).attribute29 := a57(indx);
          t(ddindx).attribute30 := a58(indx);
          t(ddindx).attribute31 := a59(indx);
          t(ddindx).attribute32 := a60(indx);
          t(ddindx).attribute33 := a61(indx);
          t(ddindx).attribute34 := a62(indx);
          t(ddindx).attribute35 := a63(indx);
          t(ddindx).attribute36 := a64(indx);
          t(ddindx).attribute37 := a65(indx);
          t(ddindx).attribute38 := a66(indx);
          t(ddindx).attribute39 := a67(indx);
          t(ddindx).attribute40 := a68(indx);
          t(ddindx).attribute41 := a69(indx);
          t(ddindx).attribute42 := a70(indx);
          t(ddindx).attribute43 := a71(indx);
          t(ddindx).attribute44 := a72(indx);
          t(ddindx).attribute45 := a73(indx);
          t(ddindx).attribute46 := a74(indx);
          t(ddindx).attribute47 := a75(indx);
          t(ddindx).attribute48 := a76(indx);
          t(ddindx).attribute49 := a77(indx);
          t(ddindx).attribute50 := a78(indx);
          t(ddindx).attribute51 := a79(indx);
          t(ddindx).attribute52 := a80(indx);
          t(ddindx).attribute53 := a81(indx);
          t(ddindx).attribute54 := a82(indx);
          t(ddindx).attribute55 := a83(indx);
          t(ddindx).attribute56 := a84(indx);
          t(ddindx).attribute57 := a85(indx);
          t(ddindx).attribute58 := a86(indx);
          t(ddindx).attribute59 := a87(indx);
          t(ddindx).attribute60 := a88(indx);
          t(ddindx).attribute61 := a89(indx);
          t(ddindx).attribute62 := a90(indx);
          t(ddindx).attribute63 := a91(indx);
          t(ddindx).attribute64 := a92(indx);
          t(ddindx).attribute65 := a93(indx);
          t(ddindx).attribute66 := a94(indx);
          t(ddindx).attribute67 := a95(indx);
          t(ddindx).attribute68 := a96(indx);
          t(ddindx).attribute69 := a97(indx);
          t(ddindx).attribute70 := a98(indx);
          t(ddindx).attribute71 := a99(indx);
          t(ddindx).attribute72 := a100(indx);
          t(ddindx).attribute73 := a101(indx);
          t(ddindx).attribute74 := a102(indx);
          t(ddindx).attribute75 := a103(indx);
          t(ddindx).attribute76 := a104(indx);
          t(ddindx).attribute77 := a105(indx);
          t(ddindx).attribute78 := a106(indx);
          t(ddindx).attribute79 := a107(indx);
          t(ddindx).attribute80 := a108(indx);
          t(ddindx).attribute81 := a109(indx);
          t(ddindx).attribute82 := a110(indx);
          t(ddindx).attribute83 := a111(indx);
          t(ddindx).attribute84 := a112(indx);
          t(ddindx).attribute85 := a113(indx);
          t(ddindx).attribute86 := a114(indx);
          t(ddindx).attribute87 := a115(indx);
          t(ddindx).attribute88 := a116(indx);
          t(ddindx).attribute89 := a117(indx);
          t(ddindx).attribute90 := a118(indx);
          t(ddindx).attribute91 := a119(indx);
          t(ddindx).attribute92 := a120(indx);
          t(ddindx).attribute93 := a121(indx);
          t(ddindx).attribute94 := a122(indx);
          t(ddindx).attribute95 := a123(indx);
          t(ddindx).attribute96 := a124(indx);
          t(ddindx).attribute97 := a125(indx);
          t(ddindx).attribute98 := a126(indx);
          t(ddindx).attribute99 := a127(indx);
          t(ddindx).attribute100 := a128(indx);
          t(ddindx).quota_id := a129(indx);
          t(ddindx).quota_name := a130(indx);
          t(ddindx).revenue_class_id := a131(indx);
          t(ddindx).revenue_class_name := a132(indx);
          t(ddindx).trx_batch_name := a133(indx);
          t(ddindx).source_trx_number := a134(indx);
          t(ddindx).trx_sales_line_id := a135(indx);
          t(ddindx).trx_line_id := a136(indx);
          t(ddindx).trx_id := a137(indx);
          t(ddindx).comm_lines_api_id := a138(indx);
          t(ddindx).source_doc_type := a139(indx);
          t(ddindx).upside_amount := a140(indx);
          t(ddindx).upside_quantity := a141(indx);
          t(ddindx).uom_code := a142(indx);
          t(ddindx).forecast_id := a143(indx);
          t(ddindx).program_id := a144(indx);
          t(ddindx).request_id := a145(indx);
          t(ddindx).program_application_id := a146(indx);
          t(ddindx).program_update_date := a147(indx);
          t(ddindx).adj_comm_lines_api_id := a148(indx);
          t(ddindx).invoice_number := a149(indx);
          t(ddindx).invoice_date := a150(indx);
          t(ddindx).order_number := a151(indx);
          t(ddindx).order_date := a152(indx);
          t(ddindx).line_number := a153(indx);
          t(ddindx).customer_id := a154(indx);
          t(ddindx).bill_to_address_id := a155(indx);
          t(ddindx).ship_to_address_id := a156(indx);
          t(ddindx).bill_to_contact_id := a157(indx);
          t(ddindx).ship_to_contact_id := a158(indx);
          t(ddindx).load_status := a159(indx);
          t(ddindx).revenue_type_disp := a160(indx);
          t(ddindx).revenue_type := a161(indx);
          t(ddindx).adjust_rollup_flag := a162(indx);
          t(ddindx).adjust_date := a163(indx);
          t(ddindx).adjusted_by := a164(indx);
          t(ddindx).adjust_status_disp := a165(indx);
          t(ddindx).adjust_status := NVL(a166(indx),'NEW');
          t(ddindx).adjust_comments := a167(indx);
          t(ddindx).type := a168(indx);
          t(ddindx).pre_processed_code := a169(indx);
          t(ddindx).comp_group_id := a170(indx);
          t(ddindx).srp_plan_assign_id := a171(indx);
          t(ddindx).role_id := a172(indx);
          t(ddindx).sales_channel := a173(indx);
          t(ddindx).object_version_number := a174(indx);
          t(ddindx).split_pct := a175(indx);
          t(ddindx).split_status := a176(indx);
          t(ddindx).commission_amount := a177(indx);
          t(ddindx).role_name := a178(indx);
          t(ddindx).comp_group_name := a179(indx);
          t(ddindx).pre_processed_code_disp := a180(indx);
          t(ddindx).customer_name := a181(indx);
          t(ddindx).customer_number := a182(indx);
          t(ddindx).inventory_item_id := a183(indx);
          t(ddindx).source_trx_id := a184(indx);
          t(ddindx).source_trx_line_id := a185(indx);
          t(ddindx).source_trx_sales_line_id := a186(indx);
          t(ddindx).org_id := a187(indx);
          t(ddindx).terr_id := a188(indx);
          t(ddindx).preserve_credit_override_flag := NVL(a189(indx),'N');
          t(ddindx).terr_name := a190(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_get_tx_data_pub.adj_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
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
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_VARCHAR2_TABLE_300
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_VARCHAR2_TABLE_300
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_VARCHAR2_TABLE_300
    , a72 out nocopy JTF_VARCHAR2_TABLE_300
    , a73 out nocopy JTF_VARCHAR2_TABLE_300
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_VARCHAR2_TABLE_300
    , a76 out nocopy JTF_VARCHAR2_TABLE_300
    , a77 out nocopy JTF_VARCHAR2_TABLE_300
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_300
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_300
    , a83 out nocopy JTF_VARCHAR2_TABLE_300
    , a84 out nocopy JTF_VARCHAR2_TABLE_300
    , a85 out nocopy JTF_VARCHAR2_TABLE_300
    , a86 out nocopy JTF_VARCHAR2_TABLE_300
    , a87 out nocopy JTF_VARCHAR2_TABLE_300
    , a88 out nocopy JTF_VARCHAR2_TABLE_300
    , a89 out nocopy JTF_VARCHAR2_TABLE_300
    , a90 out nocopy JTF_VARCHAR2_TABLE_300
    , a91 out nocopy JTF_VARCHAR2_TABLE_300
    , a92 out nocopy JTF_VARCHAR2_TABLE_300
    , a93 out nocopy JTF_VARCHAR2_TABLE_300
    , a94 out nocopy JTF_VARCHAR2_TABLE_300
    , a95 out nocopy JTF_VARCHAR2_TABLE_300
    , a96 out nocopy JTF_VARCHAR2_TABLE_300
    , a97 out nocopy JTF_VARCHAR2_TABLE_300
    , a98 out nocopy JTF_VARCHAR2_TABLE_300
    , a99 out nocopy JTF_VARCHAR2_TABLE_300
    , a100 out nocopy JTF_VARCHAR2_TABLE_300
    , a101 out nocopy JTF_VARCHAR2_TABLE_300
    , a102 out nocopy JTF_VARCHAR2_TABLE_300
    , a103 out nocopy JTF_VARCHAR2_TABLE_300
    , a104 out nocopy JTF_VARCHAR2_TABLE_300
    , a105 out nocopy JTF_VARCHAR2_TABLE_300
    , a106 out nocopy JTF_VARCHAR2_TABLE_300
    , a107 out nocopy JTF_VARCHAR2_TABLE_300
    , a108 out nocopy JTF_VARCHAR2_TABLE_300
    , a109 out nocopy JTF_VARCHAR2_TABLE_300
    , a110 out nocopy JTF_VARCHAR2_TABLE_300
    , a111 out nocopy JTF_VARCHAR2_TABLE_300
    , a112 out nocopy JTF_VARCHAR2_TABLE_300
    , a113 out nocopy JTF_VARCHAR2_TABLE_300
    , a114 out nocopy JTF_VARCHAR2_TABLE_300
    , a115 out nocopy JTF_VARCHAR2_TABLE_300
    , a116 out nocopy JTF_VARCHAR2_TABLE_300
    , a117 out nocopy JTF_VARCHAR2_TABLE_300
    , a118 out nocopy JTF_VARCHAR2_TABLE_300
    , a119 out nocopy JTF_VARCHAR2_TABLE_300
    , a120 out nocopy JTF_VARCHAR2_TABLE_300
    , a121 out nocopy JTF_VARCHAR2_TABLE_300
    , a122 out nocopy JTF_VARCHAR2_TABLE_300
    , a123 out nocopy JTF_VARCHAR2_TABLE_300
    , a124 out nocopy JTF_VARCHAR2_TABLE_300
    , a125 out nocopy JTF_VARCHAR2_TABLE_300
    , a126 out nocopy JTF_VARCHAR2_TABLE_300
    , a127 out nocopy JTF_VARCHAR2_TABLE_300
    , a128 out nocopy JTF_VARCHAR2_TABLE_300
    , a129 out nocopy JTF_NUMBER_TABLE
    , a130 out nocopy JTF_VARCHAR2_TABLE_100
    , a131 out nocopy JTF_NUMBER_TABLE
    , a132 out nocopy JTF_VARCHAR2_TABLE_100
    , a133 out nocopy JTF_VARCHAR2_TABLE_100
    , a134 out nocopy JTF_VARCHAR2_TABLE_100
    , a135 out nocopy JTF_NUMBER_TABLE
    , a136 out nocopy JTF_NUMBER_TABLE
    , a137 out nocopy JTF_NUMBER_TABLE
    , a138 out nocopy JTF_NUMBER_TABLE
    , a139 out nocopy JTF_VARCHAR2_TABLE_100
    , a140 out nocopy JTF_NUMBER_TABLE
    , a141 out nocopy JTF_NUMBER_TABLE
    , a142 out nocopy JTF_VARCHAR2_TABLE_100
    , a143 out nocopy JTF_NUMBER_TABLE
    , a144 out nocopy JTF_NUMBER_TABLE
    , a145 out nocopy JTF_NUMBER_TABLE
    , a146 out nocopy JTF_NUMBER_TABLE
    , a147 out nocopy JTF_DATE_TABLE
    , a148 out nocopy JTF_NUMBER_TABLE
    , a149 out nocopy JTF_VARCHAR2_TABLE_100
    , a150 out nocopy JTF_DATE_TABLE
    , a151 out nocopy JTF_NUMBER_TABLE
    , a152 out nocopy JTF_DATE_TABLE
    , a153 out nocopy JTF_NUMBER_TABLE
    , a154 out nocopy JTF_NUMBER_TABLE
    , a155 out nocopy JTF_NUMBER_TABLE
    , a156 out nocopy JTF_NUMBER_TABLE
    , a157 out nocopy JTF_NUMBER_TABLE
    , a158 out nocopy JTF_NUMBER_TABLE
    , a159 out nocopy JTF_VARCHAR2_TABLE_100
    , a160 out nocopy JTF_VARCHAR2_TABLE_100
    , a161 out nocopy JTF_VARCHAR2_TABLE_100
    , a162 out nocopy JTF_VARCHAR2_TABLE_100
    , a163 out nocopy JTF_DATE_TABLE
    , a164 out nocopy JTF_VARCHAR2_TABLE_100
    , a165 out nocopy JTF_VARCHAR2_TABLE_100
    , a166 out nocopy JTF_VARCHAR2_TABLE_100
    , a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , a168 out nocopy JTF_VARCHAR2_TABLE_100
    , a169 out nocopy JTF_VARCHAR2_TABLE_100
    , a170 out nocopy JTF_NUMBER_TABLE
    , a171 out nocopy JTF_NUMBER_TABLE
    , a172 out nocopy JTF_NUMBER_TABLE
    , a173 out nocopy JTF_VARCHAR2_TABLE_100
    , a174 out nocopy JTF_NUMBER_TABLE
    , a175 out nocopy JTF_NUMBER_TABLE
    , a176 out nocopy JTF_VARCHAR2_TABLE_100
    , a177 out nocopy JTF_NUMBER_TABLE
    , a178 out nocopy JTF_VARCHAR2_TABLE_100
    , a179 out nocopy JTF_VARCHAR2_TABLE_100
    , a180 out nocopy JTF_VARCHAR2_TABLE_100
    , a181 out nocopy JTF_VARCHAR2_TABLE_100
    , a182 out nocopy JTF_VARCHAR2_TABLE_100
    , a183 out nocopy JTF_NUMBER_TABLE
    , a184 out nocopy JTF_NUMBER_TABLE
    , a185 out nocopy JTF_NUMBER_TABLE
    , a186 out nocopy JTF_NUMBER_TABLE
    , a187 out nocopy JTF_NUMBER_TABLE
    , a188 out nocopy JTF_NUMBER_TABLE
    , a189 out nocopy JTF_VARCHAR2_TABLE_100
    , a190 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_1800();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
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
    a129 := JTF_NUMBER_TABLE();
    a130 := JTF_VARCHAR2_TABLE_100();
    a131 := JTF_NUMBER_TABLE();
    a132 := JTF_VARCHAR2_TABLE_100();
    a133 := JTF_VARCHAR2_TABLE_100();
    a134 := JTF_VARCHAR2_TABLE_100();
    a135 := JTF_NUMBER_TABLE();
    a136 := JTF_NUMBER_TABLE();
    a137 := JTF_NUMBER_TABLE();
    a138 := JTF_NUMBER_TABLE();
    a139 := JTF_VARCHAR2_TABLE_100();
    a140 := JTF_NUMBER_TABLE();
    a141 := JTF_NUMBER_TABLE();
    a142 := JTF_VARCHAR2_TABLE_100();
    a143 := JTF_NUMBER_TABLE();
    a144 := JTF_NUMBER_TABLE();
    a145 := JTF_NUMBER_TABLE();
    a146 := JTF_NUMBER_TABLE();
    a147 := JTF_DATE_TABLE();
    a148 := JTF_NUMBER_TABLE();
    a149 := JTF_VARCHAR2_TABLE_100();
    a150 := JTF_DATE_TABLE();
    a151 := JTF_NUMBER_TABLE();
    a152 := JTF_DATE_TABLE();
    a153 := JTF_NUMBER_TABLE();
    a154 := JTF_NUMBER_TABLE();
    a155 := JTF_NUMBER_TABLE();
    a156 := JTF_NUMBER_TABLE();
    a157 := JTF_NUMBER_TABLE();
    a158 := JTF_NUMBER_TABLE();
    a159 := JTF_VARCHAR2_TABLE_100();
    a160 := JTF_VARCHAR2_TABLE_100();
    a161 := JTF_VARCHAR2_TABLE_100();
    a162 := JTF_VARCHAR2_TABLE_100();
    a163 := JTF_DATE_TABLE();
    a164 := JTF_VARCHAR2_TABLE_100();
    a165 := JTF_VARCHAR2_TABLE_100();
    a166 := JTF_VARCHAR2_TABLE_100();
    a167 := JTF_VARCHAR2_TABLE_2000();
    a168 := JTF_VARCHAR2_TABLE_100();
    a169 := JTF_VARCHAR2_TABLE_100();
    a170 := JTF_NUMBER_TABLE();
    a171 := JTF_NUMBER_TABLE();
    a172 := JTF_NUMBER_TABLE();
    a173 := JTF_VARCHAR2_TABLE_100();
    a174 := JTF_NUMBER_TABLE();
    a175 := JTF_NUMBER_TABLE();
    a176 := JTF_VARCHAR2_TABLE_100();
    a177 := JTF_NUMBER_TABLE();
    a178 := JTF_VARCHAR2_TABLE_100();
    a179 := JTF_VARCHAR2_TABLE_100();
    a180 := JTF_VARCHAR2_TABLE_100();
    a181 := JTF_VARCHAR2_TABLE_100();
    a182 := JTF_VARCHAR2_TABLE_100();
    a183 := JTF_NUMBER_TABLE();
    a184 := JTF_NUMBER_TABLE();
    a185 := JTF_NUMBER_TABLE();
    a186 := JTF_NUMBER_TABLE();
    a187 := JTF_NUMBER_TABLE();
    a188 := JTF_NUMBER_TABLE();
    a189 := JTF_VARCHAR2_TABLE_100();
    a190 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_1800();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
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
      a129 := JTF_NUMBER_TABLE();
      a130 := JTF_VARCHAR2_TABLE_100();
      a131 := JTF_NUMBER_TABLE();
      a132 := JTF_VARCHAR2_TABLE_100();
      a133 := JTF_VARCHAR2_TABLE_100();
      a134 := JTF_VARCHAR2_TABLE_100();
      a135 := JTF_NUMBER_TABLE();
      a136 := JTF_NUMBER_TABLE();
      a137 := JTF_NUMBER_TABLE();
      a138 := JTF_NUMBER_TABLE();
      a139 := JTF_VARCHAR2_TABLE_100();
      a140 := JTF_NUMBER_TABLE();
      a141 := JTF_NUMBER_TABLE();
      a142 := JTF_VARCHAR2_TABLE_100();
      a143 := JTF_NUMBER_TABLE();
      a144 := JTF_NUMBER_TABLE();
      a145 := JTF_NUMBER_TABLE();
      a146 := JTF_NUMBER_TABLE();
      a147 := JTF_DATE_TABLE();
      a148 := JTF_NUMBER_TABLE();
      a149 := JTF_VARCHAR2_TABLE_100();
      a150 := JTF_DATE_TABLE();
      a151 := JTF_NUMBER_TABLE();
      a152 := JTF_DATE_TABLE();
      a153 := JTF_NUMBER_TABLE();
      a154 := JTF_NUMBER_TABLE();
      a155 := JTF_NUMBER_TABLE();
      a156 := JTF_NUMBER_TABLE();
      a157 := JTF_NUMBER_TABLE();
      a158 := JTF_NUMBER_TABLE();
      a159 := JTF_VARCHAR2_TABLE_100();
      a160 := JTF_VARCHAR2_TABLE_100();
      a161 := JTF_VARCHAR2_TABLE_100();
      a162 := JTF_VARCHAR2_TABLE_100();
      a163 := JTF_DATE_TABLE();
      a164 := JTF_VARCHAR2_TABLE_100();
      a165 := JTF_VARCHAR2_TABLE_100();
      a166 := JTF_VARCHAR2_TABLE_100();
      a167 := JTF_VARCHAR2_TABLE_2000();
      a168 := JTF_VARCHAR2_TABLE_100();
      a169 := JTF_VARCHAR2_TABLE_100();
      a170 := JTF_NUMBER_TABLE();
      a171 := JTF_NUMBER_TABLE();
      a172 := JTF_NUMBER_TABLE();
      a173 := JTF_VARCHAR2_TABLE_100();
      a174 := JTF_NUMBER_TABLE();
      a175 := JTF_NUMBER_TABLE();
      a176 := JTF_VARCHAR2_TABLE_100();
      a177 := JTF_NUMBER_TABLE();
      a178 := JTF_VARCHAR2_TABLE_100();
      a179 := JTF_VARCHAR2_TABLE_100();
      a180 := JTF_VARCHAR2_TABLE_100();
      a181 := JTF_VARCHAR2_TABLE_100();
      a182 := JTF_VARCHAR2_TABLE_100();
      a183 := JTF_NUMBER_TABLE();
      a184 := JTF_NUMBER_TABLE();
      a185 := JTF_NUMBER_TABLE();
      a186 := JTF_NUMBER_TABLE();
      a187 := JTF_NUMBER_TABLE();
      a188 := JTF_NUMBER_TABLE();
      a189 := JTF_VARCHAR2_TABLE_100();
      a190 := JTF_VARCHAR2_TABLE_2000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).commission_header_id;
          a1(indx) := t(ddindx).direct_salesrep_number;
          a2(indx) := t(ddindx).direct_salesrep_name;
          a3(indx) := t(ddindx).direct_salesrep_id;
          a4(indx) := t(ddindx).processed_period_id;
          a5(indx) := t(ddindx).processed_period;
          a6(indx) := t(ddindx).processed_date;
          a7(indx) := t(ddindx).rollup_date;
          a8(indx) := t(ddindx).transaction_amount;
          a9(indx) := t(ddindx).transaction_amount_orig;
          a10(indx) := t(ddindx).quantity;
          a11(indx) := t(ddindx).discount_percentage;
          a12(indx) := t(ddindx).margin_percentage;
          a13(indx) := t(ddindx).orig_currency_code;
          a14(indx) := t(ddindx).exchange_rate;
          a15(indx) := t(ddindx).status_disp;
          a16(indx) := t(ddindx).status;
          a17(indx) := t(ddindx).trx_type_disp;
          a18(indx) := t(ddindx).trx_type;
          a19(indx) := t(ddindx).reason;
          a20(indx) := t(ddindx).reason_code;
          a21(indx) := t(ddindx).comments;
          a22(indx) := t(ddindx).trx_batch_id;
          a23(indx) := t(ddindx).created_by;
          a24(indx) := t(ddindx).creation_date;
          a25(indx) := t(ddindx).last_updated_by;
          a26(indx) := t(ddindx).last_update_login;
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := t(ddindx).attribute_category;
          a29(indx) := t(ddindx).attribute1;
          a30(indx) := t(ddindx).attribute2;
          a31(indx) := t(ddindx).attribute3;
          a32(indx) := t(ddindx).attribute4;
          a33(indx) := t(ddindx).attribute5;
          a34(indx) := t(ddindx).attribute6;
          a35(indx) := t(ddindx).attribute7;
          a36(indx) := t(ddindx).attribute8;
          a37(indx) := t(ddindx).attribute9;
          a38(indx) := t(ddindx).attribute10;
          a39(indx) := t(ddindx).attribute11;
          a40(indx) := t(ddindx).attribute12;
          a41(indx) := t(ddindx).attribute13;
          a42(indx) := t(ddindx).attribute14;
          a43(indx) := t(ddindx).attribute15;
          a44(indx) := t(ddindx).attribute16;
          a45(indx) := t(ddindx).attribute17;
          a46(indx) := t(ddindx).attribute18;
          a47(indx) := t(ddindx).attribute19;
          a48(indx) := t(ddindx).attribute20;
          a49(indx) := t(ddindx).attribute21;
          a50(indx) := t(ddindx).attribute22;
          a51(indx) := t(ddindx).attribute23;
          a52(indx) := t(ddindx).attribute24;
          a53(indx) := t(ddindx).attribute25;
          a54(indx) := t(ddindx).attribute26;
          a55(indx) := t(ddindx).attribute27;
          a56(indx) := t(ddindx).attribute28;
          a57(indx) := t(ddindx).attribute29;
          a58(indx) := t(ddindx).attribute30;
          a59(indx) := t(ddindx).attribute31;
          a60(indx) := t(ddindx).attribute32;
          a61(indx) := t(ddindx).attribute33;
          a62(indx) := t(ddindx).attribute34;
          a63(indx) := t(ddindx).attribute35;
          a64(indx) := t(ddindx).attribute36;
          a65(indx) := t(ddindx).attribute37;
          a66(indx) := t(ddindx).attribute38;
          a67(indx) := t(ddindx).attribute39;
          a68(indx) := t(ddindx).attribute40;
          a69(indx) := t(ddindx).attribute41;
          a70(indx) := t(ddindx).attribute42;
          a71(indx) := t(ddindx).attribute43;
          a72(indx) := t(ddindx).attribute44;
          a73(indx) := t(ddindx).attribute45;
          a74(indx) := t(ddindx).attribute46;
          a75(indx) := t(ddindx).attribute47;
          a76(indx) := t(ddindx).attribute48;
          a77(indx) := t(ddindx).attribute49;
          a78(indx) := t(ddindx).attribute50;
          a79(indx) := t(ddindx).attribute51;
          a80(indx) := t(ddindx).attribute52;
          a81(indx) := t(ddindx).attribute53;
          a82(indx) := t(ddindx).attribute54;
          a83(indx) := t(ddindx).attribute55;
          a84(indx) := t(ddindx).attribute56;
          a85(indx) := t(ddindx).attribute57;
          a86(indx) := t(ddindx).attribute58;
          a87(indx) := t(ddindx).attribute59;
          a88(indx) := t(ddindx).attribute60;
          a89(indx) := t(ddindx).attribute61;
          a90(indx) := t(ddindx).attribute62;
          a91(indx) := t(ddindx).attribute63;
          a92(indx) := t(ddindx).attribute64;
          a93(indx) := t(ddindx).attribute65;
          a94(indx) := t(ddindx).attribute66;
          a95(indx) := t(ddindx).attribute67;
          a96(indx) := t(ddindx).attribute68;
          a97(indx) := t(ddindx).attribute69;
          a98(indx) := t(ddindx).attribute70;
          a99(indx) := t(ddindx).attribute71;
          a100(indx) := t(ddindx).attribute72;
          a101(indx) := t(ddindx).attribute73;
          a102(indx) := t(ddindx).attribute74;
          a103(indx) := t(ddindx).attribute75;
          a104(indx) := t(ddindx).attribute76;
          a105(indx) := t(ddindx).attribute77;
          a106(indx) := t(ddindx).attribute78;
          a107(indx) := t(ddindx).attribute79;
          a108(indx) := t(ddindx).attribute80;
          a109(indx) := t(ddindx).attribute81;
          a110(indx) := t(ddindx).attribute82;
          a111(indx) := t(ddindx).attribute83;
          a112(indx) := t(ddindx).attribute84;
          a113(indx) := t(ddindx).attribute85;
          a114(indx) := t(ddindx).attribute86;
          a115(indx) := t(ddindx).attribute87;
          a116(indx) := t(ddindx).attribute88;
          a117(indx) := t(ddindx).attribute89;
          a118(indx) := t(ddindx).attribute90;
          a119(indx) := t(ddindx).attribute91;
          a120(indx) := t(ddindx).attribute92;
          a121(indx) := t(ddindx).attribute93;
          a122(indx) := t(ddindx).attribute94;
          a123(indx) := t(ddindx).attribute95;
          a124(indx) := t(ddindx).attribute96;
          a125(indx) := t(ddindx).attribute97;
          a126(indx) := t(ddindx).attribute98;
          a127(indx) := t(ddindx).attribute99;
          a128(indx) := t(ddindx).attribute100;
          a129(indx) := t(ddindx).quota_id;
          a130(indx) := t(ddindx).quota_name;
          a131(indx) := t(ddindx).revenue_class_id;
          a132(indx) := t(ddindx).revenue_class_name;
          a133(indx) := t(ddindx).trx_batch_name;
          a134(indx) := t(ddindx).source_trx_number;
          a135(indx) := t(ddindx).trx_sales_line_id;
          a136(indx) := t(ddindx).trx_line_id;
          a137(indx) := t(ddindx).trx_id;
          a138(indx) := t(ddindx).comm_lines_api_id;
          a139(indx) := t(ddindx).source_doc_type;
          a140(indx) := t(ddindx).upside_amount;
          a141(indx) := t(ddindx).upside_quantity;
          a142(indx) := t(ddindx).uom_code;
          a143(indx) := t(ddindx).forecast_id;
          a144(indx) := t(ddindx).program_id;
          a145(indx) := t(ddindx).request_id;
          a146(indx) := t(ddindx).program_application_id;
          a147(indx) := t(ddindx).program_update_date;
          a148(indx) := t(ddindx).adj_comm_lines_api_id;
          a149(indx) := t(ddindx).invoice_number;
          a150(indx) := t(ddindx).invoice_date;
          a151(indx) := t(ddindx).order_number;
          a152(indx) := t(ddindx).order_date;
          a153(indx) := t(ddindx).line_number;
          a154(indx) := t(ddindx).customer_id;
          a155(indx) := t(ddindx).bill_to_address_id;
          a156(indx) := t(ddindx).ship_to_address_id;
          a157(indx) := t(ddindx).bill_to_contact_id;
          a158(indx) := t(ddindx).ship_to_contact_id;
          a159(indx) := t(ddindx).load_status;
          a160(indx) := t(ddindx).revenue_type_disp;
          a161(indx) := t(ddindx).revenue_type;
          a162(indx) := t(ddindx).adjust_rollup_flag;
          a163(indx) := t(ddindx).adjust_date;
          a164(indx) := t(ddindx).adjusted_by;
          a165(indx) := t(ddindx).adjust_status_disp;
          a166(indx) := t(ddindx).adjust_status;
          a167(indx) := t(ddindx).adjust_comments;
          a168(indx) := t(ddindx).type;
          a169(indx) := t(ddindx).pre_processed_code;
          a170(indx) := t(ddindx).comp_group_id;
          a171(indx) := t(ddindx).srp_plan_assign_id;
          a172(indx) := t(ddindx).role_id;
          a173(indx) := t(ddindx).sales_channel;
          a174(indx) := t(ddindx).object_version_number;
          a175(indx) := t(ddindx).split_pct;
          a176(indx) := t(ddindx).split_status;
          a177(indx) := t(ddindx).commission_amount;
          a178(indx) := t(ddindx).role_name;
          a179(indx) := t(ddindx).comp_group_name;
          a180(indx) := t(ddindx).pre_processed_code_disp;
          a181(indx) := t(ddindx).customer_name;
          a182(indx) := t(ddindx).customer_number;
          a183(indx) := t(ddindx).inventory_item_id;
          a184(indx) := t(ddindx).source_trx_id;
          a185(indx) := t(ddindx).source_trx_line_id;
          a186(indx) := t(ddindx).source_trx_sales_line_id;
          a187(indx) := t(ddindx).org_id;
          a188(indx) := t(ddindx).terr_id;
          a189(indx) := NVL(t(ddindx).preserve_credit_override_flag,'N');
          a190(indx) := t(ddindx).terr_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_get_tx_data_pub.tx_adj_data_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).salesrep_id := a0(indx);
          t(ddindx).employee_number := a1(indx);
          t(ddindx).salesrep_name := a2(indx);
          t(ddindx).processed_date := a3(indx);
          t(ddindx).processed_period_id := a4(indx);
          t(ddindx).comm_lines_api_id := a5(indx);
          t(ddindx).commission_header_id := a6(indx);
          t(ddindx).load_status := a7(indx);
          t(ddindx).adjust_status := NVL(a8(indx),'NEW');
          t(ddindx).revenue_type := a9(indx);
          t(ddindx).order_number := a10(indx);
          t(ddindx).order_date := a11(indx);
          t(ddindx).invoice_number := a12(indx);
          t(ddindx).invoice_date := a13(indx);
          t(ddindx).transaction_amount := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_get_tx_data_pub.tx_adj_data_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).salesrep_id;
          a1(indx) := t(ddindx).employee_number;
          a2(indx) := t(ddindx).salesrep_name;
          a3(indx) := t(ddindx).processed_date;
          a4(indx) := t(ddindx).processed_period_id;
          a5(indx) := t(ddindx).comm_lines_api_id;
          a6(indx) := t(ddindx).commission_header_id;
          a7(indx) := t(ddindx).load_status;
          a8(indx) := t(ddindx).adjust_status;
          a9(indx) := t(ddindx).revenue_type;
          a10(indx) := t(ddindx).order_number;
          a11(indx) := t(ddindx).order_date;
          a12(indx) := t(ddindx).invoice_number;
          a13(indx) := t(ddindx).invoice_date;
          a14(indx) := t(ddindx).transaction_amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy cn_get_tx_data_pub.split_data_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).salesrep_id := a0(indx);
          t(ddindx).salesrep_number := a1(indx);
          t(ddindx).revenue_type := a2(indx);
          t(ddindx).split_pct := a3(indx);
          t(ddindx).split_amount := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_get_tx_data_pub.split_data_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).salesrep_id;
          a1(indx) := t(ddindx).salesrep_number;
          a2(indx) := t(ddindx).revenue_type;
          a3(indx) := t(ddindx).split_pct;
          a4(indx) := t(ddindx).split_amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy cn_get_tx_data_pub.trx_line_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_400
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).commission_line_id := a0(indx);
          t(ddindx).commission_header_id := a1(indx);
          t(ddindx).credited_salesrep_id := a2(indx);
          t(ddindx).credited_salesrep_name := a3(indx);
          t(ddindx).credited_salesrep_number := a4(indx);
          t(ddindx).processed_period_id := a5(indx);
          t(ddindx).processed_date := a6(indx);
          t(ddindx).plan_element := a7(indx);
          t(ddindx).payment_uplift := a8(indx);
          t(ddindx).quota_uplift := a9(indx);
          t(ddindx).commission_amount := a10(indx);
          t(ddindx).commission_rate := a11(indx);
          t(ddindx).created_during := a12(indx);
          t(ddindx).pay_period := a13(indx);
          t(ddindx).accumulation_period := a14(indx);
          t(ddindx).perf_achieved := a15(indx);
          t(ddindx).posting_status := a16(indx);
          t(ddindx).pending_status := a17(indx);
          t(ddindx).trx_status := a18(indx);
          t(ddindx).payee := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t cn_get_tx_data_pub.trx_line_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_400
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_400();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_400();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_400();
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
          a0(indx) := t(ddindx).commission_line_id;
          a1(indx) := t(ddindx).commission_header_id;
          a2(indx) := t(ddindx).credited_salesrep_id;
          a3(indx) := t(ddindx).credited_salesrep_name;
          a4(indx) := t(ddindx).credited_salesrep_number;
          a5(indx) := t(ddindx).processed_period_id;
          a6(indx) := t(ddindx).processed_date;
          a7(indx) := t(ddindx).plan_element;
          a8(indx) := t(ddindx).payment_uplift;
          a9(indx) := t(ddindx).quota_uplift;
          a10(indx) := t(ddindx).commission_amount;
          a11(indx) := t(ddindx).commission_rate;
          a12(indx) := t(ddindx).created_during;
          a13(indx) := t(ddindx).pay_period;
          a14(indx) := t(ddindx).accumulation_period;
          a15(indx) := t(ddindx).perf_achieved;
          a16(indx) := t(ddindx).posting_status;
          a17(indx) := t(ddindx).pending_status;
          a18(indx) := t(ddindx).trx_status;
          a19(indx) := t(ddindx).payee;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy cn_get_tx_data_pub.cust_info_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_400
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).customer_id := a0(indx);
          t(ddindx).customer_number := a1(indx);
          t(ddindx).customer_name := a2(indx);
          t(ddindx).bill_to_address_id := a3(indx);
          t(ddindx).bill_to_address1 := a4(indx);
          t(ddindx).bill_to_address2 := a5(indx);
          t(ddindx).bill_to_address3 := a6(indx);
          t(ddindx).bill_to_address4 := a7(indx);
          t(ddindx).bill_to_city := a8(indx);
          t(ddindx).bill_to_postal_code := a9(indx);
          t(ddindx).bill_to_state := a10(indx);
          t(ddindx).ship_to_address_id := a11(indx);
          t(ddindx).ship_to_address1 := a12(indx);
          t(ddindx).ship_to_address2 := a13(indx);
          t(ddindx).ship_to_address3 := a14(indx);
          t(ddindx).ship_to_address4 := a15(indx);
          t(ddindx).ship_to_city := a16(indx);
          t(ddindx).ship_to_postal_code := a17(indx);
          t(ddindx).ship_to_state := a18(indx);
          t(ddindx).bill_to_contact_id := a19(indx);
          t(ddindx).bill_to_contact := a20(indx);
          t(ddindx).ship_to_contact_id := a21(indx);
          t(ddindx).ship_to_contact := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t cn_get_tx_data_pub.cust_info_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_400
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_400();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_400();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_400();
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
          a0(indx) := t(ddindx).customer_id;
          a1(indx) := t(ddindx).customer_number;
          a2(indx) := t(ddindx).customer_name;
          a3(indx) := t(ddindx).bill_to_address_id;
          a4(indx) := t(ddindx).bill_to_address1;
          a5(indx) := t(ddindx).bill_to_address2;
          a6(indx) := t(ddindx).bill_to_address3;
          a7(indx) := t(ddindx).bill_to_address4;
          a8(indx) := t(ddindx).bill_to_city;
          a9(indx) := t(ddindx).bill_to_postal_code;
          a10(indx) := t(ddindx).bill_to_state;
          a11(indx) := t(ddindx).ship_to_address_id;
          a12(indx) := t(ddindx).ship_to_address1;
          a13(indx) := t(ddindx).ship_to_address2;
          a14(indx) := t(ddindx).ship_to_address3;
          a15(indx) := t(ddindx).ship_to_address4;
          a16(indx) := t(ddindx).ship_to_city;
          a17(indx) := t(ddindx).ship_to_postal_code;
          a18(indx) := t(ddindx).ship_to_state;
          a19(indx) := t(ddindx).bill_to_contact_id;
          a20(indx) := t(ddindx).bill_to_contact;
          a21(indx) := t(ddindx).ship_to_contact_id;
          a22(indx) := t(ddindx).ship_to_contact;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy cn_get_tx_data_pub.attribute_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute_name := a0(indx);
          t(ddindx).attribute_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t cn_get_tx_data_pub.attribute_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
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
          a0(indx) := t(ddindx).attribute_name;
          a1(indx) := t(ddindx).attribute_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure get_api_data(p_comm_lines_api_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a3 out nocopy JTF_NUMBER_TABLE
    , p1_a4 out nocopy JTF_NUMBER_TABLE
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 out nocopy JTF_DATE_TABLE
    , p1_a7 out nocopy JTF_DATE_TABLE
    , p1_a8 out nocopy JTF_NUMBER_TABLE
    , p1_a9 out nocopy JTF_NUMBER_TABLE
    , p1_a10 out nocopy JTF_NUMBER_TABLE
    , p1_a11 out nocopy JTF_NUMBER_TABLE
    , p1_a12 out nocopy JTF_NUMBER_TABLE
    , p1_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a14 out nocopy JTF_NUMBER_TABLE
    , p1_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , p1_a22 out nocopy JTF_NUMBER_TABLE
    , p1_a23 out nocopy JTF_NUMBER_TABLE
    , p1_a24 out nocopy JTF_DATE_TABLE
    , p1_a25 out nocopy JTF_NUMBER_TABLE
    , p1_a26 out nocopy JTF_NUMBER_TABLE
    , p1_a27 out nocopy JTF_DATE_TABLE
    , p1_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a117 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a118 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a129 out nocopy JTF_NUMBER_TABLE
    , p1_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a131 out nocopy JTF_NUMBER_TABLE
    , p1_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a134 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a135 out nocopy JTF_NUMBER_TABLE
    , p1_a136 out nocopy JTF_NUMBER_TABLE
    , p1_a137 out nocopy JTF_NUMBER_TABLE
    , p1_a138 out nocopy JTF_NUMBER_TABLE
    , p1_a139 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a140 out nocopy JTF_NUMBER_TABLE
    , p1_a141 out nocopy JTF_NUMBER_TABLE
    , p1_a142 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a143 out nocopy JTF_NUMBER_TABLE
    , p1_a144 out nocopy JTF_NUMBER_TABLE
    , p1_a145 out nocopy JTF_NUMBER_TABLE
    , p1_a146 out nocopy JTF_NUMBER_TABLE
    , p1_a147 out nocopy JTF_DATE_TABLE
    , p1_a148 out nocopy JTF_NUMBER_TABLE
    , p1_a149 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a150 out nocopy JTF_DATE_TABLE
    , p1_a151 out nocopy JTF_NUMBER_TABLE
    , p1_a152 out nocopy JTF_DATE_TABLE
    , p1_a153 out nocopy JTF_NUMBER_TABLE
    , p1_a154 out nocopy JTF_NUMBER_TABLE
    , p1_a155 out nocopy JTF_NUMBER_TABLE
    , p1_a156 out nocopy JTF_NUMBER_TABLE
    , p1_a157 out nocopy JTF_NUMBER_TABLE
    , p1_a158 out nocopy JTF_NUMBER_TABLE
    , p1_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a160 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a162 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a163 out nocopy JTF_DATE_TABLE
    , p1_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a170 out nocopy JTF_NUMBER_TABLE
    , p1_a171 out nocopy JTF_NUMBER_TABLE
    , p1_a172 out nocopy JTF_NUMBER_TABLE
    , p1_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a174 out nocopy JTF_NUMBER_TABLE
    , p1_a175 out nocopy JTF_NUMBER_TABLE
    , p1_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a177 out nocopy JTF_NUMBER_TABLE
    , p1_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a183 out nocopy JTF_NUMBER_TABLE
    , p1_a184 out nocopy JTF_NUMBER_TABLE
    , p1_a185 out nocopy JTF_NUMBER_TABLE
    , p1_a186 out nocopy JTF_NUMBER_TABLE
    , p1_a187 out nocopy JTF_NUMBER_TABLE
    , p1_a188 out nocopy JTF_NUMBER_TABLE
    , p1_a189 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a190 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddx_adj_tbl cn_get_tx_data_pub.adj_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.get_api_data(p_comm_lines_api_id,
      ddx_adj_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    cn_get_tx_data_pub_w.rosetta_table_copy_out_p1(ddx_adj_tbl, p1_a0
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
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      , p1_a41
      , p1_a42
      , p1_a43
      , p1_a44
      , p1_a45
      , p1_a46
      , p1_a47
      , p1_a48
      , p1_a49
      , p1_a50
      , p1_a51
      , p1_a52
      , p1_a53
      , p1_a54
      , p1_a55
      , p1_a56
      , p1_a57
      , p1_a58
      , p1_a59
      , p1_a60
      , p1_a61
      , p1_a62
      , p1_a63
      , p1_a64
      , p1_a65
      , p1_a66
      , p1_a67
      , p1_a68
      , p1_a69
      , p1_a70
      , p1_a71
      , p1_a72
      , p1_a73
      , p1_a74
      , p1_a75
      , p1_a76
      , p1_a77
      , p1_a78
      , p1_a79
      , p1_a80
      , p1_a81
      , p1_a82
      , p1_a83
      , p1_a84
      , p1_a85
      , p1_a86
      , p1_a87
      , p1_a88
      , p1_a89
      , p1_a90
      , p1_a91
      , p1_a92
      , p1_a93
      , p1_a94
      , p1_a95
      , p1_a96
      , p1_a97
      , p1_a98
      , p1_a99
      , p1_a100
      , p1_a101
      , p1_a102
      , p1_a103
      , p1_a104
      , p1_a105
      , p1_a106
      , p1_a107
      , p1_a108
      , p1_a109
      , p1_a110
      , p1_a111
      , p1_a112
      , p1_a113
      , p1_a114
      , p1_a115
      , p1_a116
      , p1_a117
      , p1_a118
      , p1_a119
      , p1_a120
      , p1_a121
      , p1_a122
      , p1_a123
      , p1_a124
      , p1_a125
      , p1_a126
      , p1_a127
      , p1_a128
      , p1_a129
      , p1_a130
      , p1_a131
      , p1_a132
      , p1_a133
      , p1_a134
      , p1_a135
      , p1_a136
      , p1_a137
      , p1_a138
      , p1_a139
      , p1_a140
      , p1_a141
      , p1_a142
      , p1_a143
      , p1_a144
      , p1_a145
      , p1_a146
      , p1_a147
      , p1_a148
      , p1_a149
      , p1_a150
      , p1_a151
      , p1_a152
      , p1_a153
      , p1_a154
      , p1_a155
      , p1_a156
      , p1_a157
      , p1_a158
      , p1_a159
      , p1_a160
      , p1_a161
      , p1_a162
      , p1_a163
      , p1_a164
      , p1_a165
      , p1_a166
      , p1_a167
      , p1_a168
      , p1_a169
      , p1_a170
      , p1_a171
      , p1_a172
      , p1_a173
      , p1_a174
      , p1_a175
      , p1_a176
      , p1_a177
      , p1_a178
      , p1_a179
      , p1_a180
      , p1_a181
      , p1_a182
      , p1_a183
      , p1_a184
      , p1_a185
      , p1_a186
      , p1_a187
      , p1_a188
      , p1_a189
      , p1_a190
      );
  end;

  procedure get_adj(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_org_id  NUMBER
    , p_salesrep_id  NUMBER
    , p_pr_date_to  DATE
    , p_pr_date_from  DATE
    , p_calc_status  VARCHAR2
    , p_adj_status  VARCHAR2
    , p_load_status  VARCHAR2
    , p_invoice_num  VARCHAR2
    , p_order_num  NUMBER
    , p12_a0  NUMBER
    , p12_a1  VARCHAR2
    , p12_a2  VARCHAR2
    , p12_a3  NUMBER
    , p12_a4  NUMBER
    , p12_a5  VARCHAR2
    , p12_a6  DATE
    , p12_a7  DATE
    , p12_a8  NUMBER
    , p12_a9  NUMBER
    , p12_a10  NUMBER
    , p12_a11  NUMBER
    , p12_a12  NUMBER
    , p12_a13  VARCHAR2
    , p12_a14  NUMBER
    , p12_a15  VARCHAR2
    , p12_a16  VARCHAR2
    , p12_a17  VARCHAR2
    , p12_a18  VARCHAR2
    , p12_a19  VARCHAR2
    , p12_a20  VARCHAR2
    , p12_a21  VARCHAR2
    , p12_a22  NUMBER
    , p12_a23  NUMBER
    , p12_a24  DATE
    , p12_a25  NUMBER
    , p12_a26  NUMBER
    , p12_a27  DATE
    , p12_a28  VARCHAR2
    , p12_a29  VARCHAR2
    , p12_a30  VARCHAR2
    , p12_a31  VARCHAR2
    , p12_a32  VARCHAR2
    , p12_a33  VARCHAR2
    , p12_a34  VARCHAR2
    , p12_a35  VARCHAR2
    , p12_a36  VARCHAR2
    , p12_a37  VARCHAR2
    , p12_a38  VARCHAR2
    , p12_a39  VARCHAR2
    , p12_a40  VARCHAR2
    , p12_a41  VARCHAR2
    , p12_a42  VARCHAR2
    , p12_a43  VARCHAR2
    , p12_a44  VARCHAR2
    , p12_a45  VARCHAR2
    , p12_a46  VARCHAR2
    , p12_a47  VARCHAR2
    , p12_a48  VARCHAR2
    , p12_a49  VARCHAR2
    , p12_a50  VARCHAR2
    , p12_a51  VARCHAR2
    , p12_a52  VARCHAR2
    , p12_a53  VARCHAR2
    , p12_a54  VARCHAR2
    , p12_a55  VARCHAR2
    , p12_a56  VARCHAR2
    , p12_a57  VARCHAR2
    , p12_a58  VARCHAR2
    , p12_a59  VARCHAR2
    , p12_a60  VARCHAR2
    , p12_a61  VARCHAR2
    , p12_a62  VARCHAR2
    , p12_a63  VARCHAR2
    , p12_a64  VARCHAR2
    , p12_a65  VARCHAR2
    , p12_a66  VARCHAR2
    , p12_a67  VARCHAR2
    , p12_a68  VARCHAR2
    , p12_a69  VARCHAR2
    , p12_a70  VARCHAR2
    , p12_a71  VARCHAR2
    , p12_a72  VARCHAR2
    , p12_a73  VARCHAR2
    , p12_a74  VARCHAR2
    , p12_a75  VARCHAR2
    , p12_a76  VARCHAR2
    , p12_a77  VARCHAR2
    , p12_a78  VARCHAR2
    , p12_a79  VARCHAR2
    , p12_a80  VARCHAR2
    , p12_a81  VARCHAR2
    , p12_a82  VARCHAR2
    , p12_a83  VARCHAR2
    , p12_a84  VARCHAR2
    , p12_a85  VARCHAR2
    , p12_a86  VARCHAR2
    , p12_a87  VARCHAR2
    , p12_a88  VARCHAR2
    , p12_a89  VARCHAR2
    , p12_a90  VARCHAR2
    , p12_a91  VARCHAR2
    , p12_a92  VARCHAR2
    , p12_a93  VARCHAR2
    , p12_a94  VARCHAR2
    , p12_a95  VARCHAR2
    , p12_a96  VARCHAR2
    , p12_a97  VARCHAR2
    , p12_a98  VARCHAR2
    , p12_a99  VARCHAR2
    , p12_a100  VARCHAR2
    , p12_a101  VARCHAR2
    , p12_a102  VARCHAR2
    , p12_a103  VARCHAR2
    , p12_a104  VARCHAR2
    , p12_a105  VARCHAR2
    , p12_a106  VARCHAR2
    , p12_a107  VARCHAR2
    , p12_a108  VARCHAR2
    , p12_a109  VARCHAR2
    , p12_a110  VARCHAR2
    , p12_a111  VARCHAR2
    , p12_a112  VARCHAR2
    , p12_a113  VARCHAR2
    , p12_a114  VARCHAR2
    , p12_a115  VARCHAR2
    , p12_a116  VARCHAR2
    , p12_a117  VARCHAR2
    , p12_a118  VARCHAR2
    , p12_a119  VARCHAR2
    , p12_a120  VARCHAR2
    , p12_a121  VARCHAR2
    , p12_a122  VARCHAR2
    , p12_a123  VARCHAR2
    , p12_a124  VARCHAR2
    , p12_a125  VARCHAR2
    , p12_a126  VARCHAR2
    , p12_a127  VARCHAR2
    , p12_a128  VARCHAR2
    , p12_a129  NUMBER
    , p12_a130  VARCHAR2
    , p12_a131  NUMBER
    , p12_a132  VARCHAR2
    , p12_a133  VARCHAR2
    , p12_a134  VARCHAR2
    , p12_a135  NUMBER
    , p12_a136  NUMBER
    , p12_a137  NUMBER
    , p12_a138  NUMBER
    , p12_a139  VARCHAR2
    , p12_a140  NUMBER
    , p12_a141  NUMBER
    , p12_a142  VARCHAR2
    , p12_a143  NUMBER
    , p12_a144  NUMBER
    , p12_a145  NUMBER
    , p12_a146  NUMBER
    , p12_a147  DATE
    , p12_a148  NUMBER
    , p12_a149  VARCHAR2
    , p12_a150  DATE
    , p12_a151  NUMBER
    , p12_a152  DATE
    , p12_a153  NUMBER
    , p12_a154  NUMBER
    , p12_a155  NUMBER
    , p12_a156  NUMBER
    , p12_a157  NUMBER
    , p12_a158  NUMBER
    , p12_a159  VARCHAR2
    , p12_a160  VARCHAR2
    , p12_a161  VARCHAR2
    , p12_a162  VARCHAR2
    , p12_a163  DATE
    , p12_a164  VARCHAR2
    , p12_a165  VARCHAR2
    , p12_a166  VARCHAR2
    , p12_a167  VARCHAR2
    , p12_a168  VARCHAR2
    , p12_a169  VARCHAR2
    , p12_a170  NUMBER
    , p12_a171  NUMBER
    , p12_a172  NUMBER
    , p12_a173  VARCHAR2
    , p12_a174  NUMBER
    , p12_a175  NUMBER
    , p12_a176  VARCHAR2
    , p12_a177  NUMBER
    , p12_a178  VARCHAR2
    , p12_a179  VARCHAR2
    , p12_a180  VARCHAR2
    , p12_a181  VARCHAR2
    , p12_a182  VARCHAR2
    , p12_a183  NUMBER
    , p12_a184  NUMBER
    , p12_a185  NUMBER
    , p12_a186  NUMBER
    , p12_a187  NUMBER
    , p12_a188  NUMBER
    , p12_a189  VARCHAR2
    , p12_a190  VARCHAR2
    , p_first  NUMBER
    , p_last  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p19_a0 out nocopy JTF_NUMBER_TABLE
    , p19_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p19_a3 out nocopy JTF_NUMBER_TABLE
    , p19_a4 out nocopy JTF_NUMBER_TABLE
    , p19_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a6 out nocopy JTF_DATE_TABLE
    , p19_a7 out nocopy JTF_DATE_TABLE
    , p19_a8 out nocopy JTF_NUMBER_TABLE
    , p19_a9 out nocopy JTF_NUMBER_TABLE
    , p19_a10 out nocopy JTF_NUMBER_TABLE
    , p19_a11 out nocopy JTF_NUMBER_TABLE
    , p19_a12 out nocopy JTF_NUMBER_TABLE
    , p19_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a14 out nocopy JTF_NUMBER_TABLE
    , p19_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , p19_a22 out nocopy JTF_NUMBER_TABLE
    , p19_a23 out nocopy JTF_NUMBER_TABLE
    , p19_a24 out nocopy JTF_DATE_TABLE
    , p19_a25 out nocopy JTF_NUMBER_TABLE
    , p19_a26 out nocopy JTF_NUMBER_TABLE
    , p19_a27 out nocopy JTF_DATE_TABLE
    , p19_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a117 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a118 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a129 out nocopy JTF_NUMBER_TABLE
    , p19_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a131 out nocopy JTF_NUMBER_TABLE
    , p19_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a134 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a135 out nocopy JTF_NUMBER_TABLE
    , p19_a136 out nocopy JTF_NUMBER_TABLE
    , p19_a137 out nocopy JTF_NUMBER_TABLE
    , p19_a138 out nocopy JTF_NUMBER_TABLE
    , p19_a139 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a140 out nocopy JTF_NUMBER_TABLE
    , p19_a141 out nocopy JTF_NUMBER_TABLE
    , p19_a142 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a143 out nocopy JTF_NUMBER_TABLE
    , p19_a144 out nocopy JTF_NUMBER_TABLE
    , p19_a145 out nocopy JTF_NUMBER_TABLE
    , p19_a146 out nocopy JTF_NUMBER_TABLE
    , p19_a147 out nocopy JTF_DATE_TABLE
    , p19_a148 out nocopy JTF_NUMBER_TABLE
    , p19_a149 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a150 out nocopy JTF_DATE_TABLE
    , p19_a151 out nocopy JTF_NUMBER_TABLE
    , p19_a152 out nocopy JTF_DATE_TABLE
    , p19_a153 out nocopy JTF_NUMBER_TABLE
    , p19_a154 out nocopy JTF_NUMBER_TABLE
    , p19_a155 out nocopy JTF_NUMBER_TABLE
    , p19_a156 out nocopy JTF_NUMBER_TABLE
    , p19_a157 out nocopy JTF_NUMBER_TABLE
    , p19_a158 out nocopy JTF_NUMBER_TABLE
    , p19_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a160 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a162 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a163 out nocopy JTF_DATE_TABLE
    , p19_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a170 out nocopy JTF_NUMBER_TABLE
    , p19_a171 out nocopy JTF_NUMBER_TABLE
    , p19_a172 out nocopy JTF_NUMBER_TABLE
    , p19_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a174 out nocopy JTF_NUMBER_TABLE
    , p19_a175 out nocopy JTF_NUMBER_TABLE
    , p19_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a177 out nocopy JTF_NUMBER_TABLE
    , p19_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a183 out nocopy JTF_NUMBER_TABLE
    , p19_a184 out nocopy JTF_NUMBER_TABLE
    , p19_a185 out nocopy JTF_NUMBER_TABLE
    , p19_a186 out nocopy JTF_NUMBER_TABLE
    , p19_a187 out nocopy JTF_NUMBER_TABLE
    , p19_a188 out nocopy JTF_NUMBER_TABLE
    , p19_a189 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a190 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_adj_count out nocopy  NUMBER
    , x_valid_trx_count out nocopy  NUMBER
  )

  as
    ddp_srch_attr_rec cn_get_tx_data_pub.adj_rec_type;
    ddx_adj_tbl cn_get_tx_data_pub.adj_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_srch_attr_rec.commission_header_id := p12_a0;
    ddp_srch_attr_rec.direct_salesrep_number := p12_a1;
    ddp_srch_attr_rec.direct_salesrep_name := p12_a2;
    ddp_srch_attr_rec.direct_salesrep_id := p12_a3;
    ddp_srch_attr_rec.processed_period_id := p12_a4;
    ddp_srch_attr_rec.processed_period := p12_a5;
    ddp_srch_attr_rec.processed_date := p12_a6;
    ddp_srch_attr_rec.rollup_date := p12_a7;
    ddp_srch_attr_rec.transaction_amount := p12_a8;
    ddp_srch_attr_rec.transaction_amount_orig := p12_a9;
    ddp_srch_attr_rec.quantity := p12_a10;
    ddp_srch_attr_rec.discount_percentage := p12_a11;
    ddp_srch_attr_rec.margin_percentage := p12_a12;
    ddp_srch_attr_rec.orig_currency_code := p12_a13;
    ddp_srch_attr_rec.exchange_rate := p12_a14;
    ddp_srch_attr_rec.status_disp := p12_a15;
    ddp_srch_attr_rec.status := p12_a16;
    ddp_srch_attr_rec.trx_type_disp := p12_a17;
    ddp_srch_attr_rec.trx_type := p12_a18;
    ddp_srch_attr_rec.reason := p12_a19;
    ddp_srch_attr_rec.reason_code := p12_a20;
    ddp_srch_attr_rec.comments := p12_a21;
    ddp_srch_attr_rec.trx_batch_id := p12_a22;
    ddp_srch_attr_rec.created_by := p12_a23;
    ddp_srch_attr_rec.creation_date := p12_a24;
    ddp_srch_attr_rec.last_updated_by := p12_a25;
    ddp_srch_attr_rec.last_update_login := p12_a26;
    ddp_srch_attr_rec.last_update_date := p12_a27;
    ddp_srch_attr_rec.attribute_category := p12_a28;
    ddp_srch_attr_rec.attribute1 := p12_a29;
    ddp_srch_attr_rec.attribute2 := p12_a30;
    ddp_srch_attr_rec.attribute3 := p12_a31;
    ddp_srch_attr_rec.attribute4 := p12_a32;
    ddp_srch_attr_rec.attribute5 := p12_a33;
    ddp_srch_attr_rec.attribute6 := p12_a34;
    ddp_srch_attr_rec.attribute7 := p12_a35;
    ddp_srch_attr_rec.attribute8 := p12_a36;
    ddp_srch_attr_rec.attribute9 := p12_a37;
    ddp_srch_attr_rec.attribute10 := p12_a38;
    ddp_srch_attr_rec.attribute11 := p12_a39;
    ddp_srch_attr_rec.attribute12 := p12_a40;
    ddp_srch_attr_rec.attribute13 := p12_a41;
    ddp_srch_attr_rec.attribute14 := p12_a42;
    ddp_srch_attr_rec.attribute15 := p12_a43;
    ddp_srch_attr_rec.attribute16 := p12_a44;
    ddp_srch_attr_rec.attribute17 := p12_a45;
    ddp_srch_attr_rec.attribute18 := p12_a46;
    ddp_srch_attr_rec.attribute19 := p12_a47;
    ddp_srch_attr_rec.attribute20 := p12_a48;
    ddp_srch_attr_rec.attribute21 := p12_a49;
    ddp_srch_attr_rec.attribute22 := p12_a50;
    ddp_srch_attr_rec.attribute23 := p12_a51;
    ddp_srch_attr_rec.attribute24 := p12_a52;
    ddp_srch_attr_rec.attribute25 := p12_a53;
    ddp_srch_attr_rec.attribute26 := p12_a54;
    ddp_srch_attr_rec.attribute27 := p12_a55;
    ddp_srch_attr_rec.attribute28 := p12_a56;
    ddp_srch_attr_rec.attribute29 := p12_a57;
    ddp_srch_attr_rec.attribute30 := p12_a58;
    ddp_srch_attr_rec.attribute31 := p12_a59;
    ddp_srch_attr_rec.attribute32 := p12_a60;
    ddp_srch_attr_rec.attribute33 := p12_a61;
    ddp_srch_attr_rec.attribute34 := p12_a62;
    ddp_srch_attr_rec.attribute35 := p12_a63;
    ddp_srch_attr_rec.attribute36 := p12_a64;
    ddp_srch_attr_rec.attribute37 := p12_a65;
    ddp_srch_attr_rec.attribute38 := p12_a66;
    ddp_srch_attr_rec.attribute39 := p12_a67;
    ddp_srch_attr_rec.attribute40 := p12_a68;
    ddp_srch_attr_rec.attribute41 := p12_a69;
    ddp_srch_attr_rec.attribute42 := p12_a70;
    ddp_srch_attr_rec.attribute43 := p12_a71;
    ddp_srch_attr_rec.attribute44 := p12_a72;
    ddp_srch_attr_rec.attribute45 := p12_a73;
    ddp_srch_attr_rec.attribute46 := p12_a74;
    ddp_srch_attr_rec.attribute47 := p12_a75;
    ddp_srch_attr_rec.attribute48 := p12_a76;
    ddp_srch_attr_rec.attribute49 := p12_a77;
    ddp_srch_attr_rec.attribute50 := p12_a78;
    ddp_srch_attr_rec.attribute51 := p12_a79;
    ddp_srch_attr_rec.attribute52 := p12_a80;
    ddp_srch_attr_rec.attribute53 := p12_a81;
    ddp_srch_attr_rec.attribute54 := p12_a82;
    ddp_srch_attr_rec.attribute55 := p12_a83;
    ddp_srch_attr_rec.attribute56 := p12_a84;
    ddp_srch_attr_rec.attribute57 := p12_a85;
    ddp_srch_attr_rec.attribute58 := p12_a86;
    ddp_srch_attr_rec.attribute59 := p12_a87;
    ddp_srch_attr_rec.attribute60 := p12_a88;
    ddp_srch_attr_rec.attribute61 := p12_a89;
    ddp_srch_attr_rec.attribute62 := p12_a90;
    ddp_srch_attr_rec.attribute63 := p12_a91;
    ddp_srch_attr_rec.attribute64 := p12_a92;
    ddp_srch_attr_rec.attribute65 := p12_a93;
    ddp_srch_attr_rec.attribute66 := p12_a94;
    ddp_srch_attr_rec.attribute67 := p12_a95;
    ddp_srch_attr_rec.attribute68 := p12_a96;
    ddp_srch_attr_rec.attribute69 := p12_a97;
    ddp_srch_attr_rec.attribute70 := p12_a98;
    ddp_srch_attr_rec.attribute71 := p12_a99;
    ddp_srch_attr_rec.attribute72 := p12_a100;
    ddp_srch_attr_rec.attribute73 := p12_a101;
    ddp_srch_attr_rec.attribute74 := p12_a102;
    ddp_srch_attr_rec.attribute75 := p12_a103;
    ddp_srch_attr_rec.attribute76 := p12_a104;
    ddp_srch_attr_rec.attribute77 := p12_a105;
    ddp_srch_attr_rec.attribute78 := p12_a106;
    ddp_srch_attr_rec.attribute79 := p12_a107;
    ddp_srch_attr_rec.attribute80 := p12_a108;
    ddp_srch_attr_rec.attribute81 := p12_a109;
    ddp_srch_attr_rec.attribute82 := p12_a110;
    ddp_srch_attr_rec.attribute83 := p12_a111;
    ddp_srch_attr_rec.attribute84 := p12_a112;
    ddp_srch_attr_rec.attribute85 := p12_a113;
    ddp_srch_attr_rec.attribute86 := p12_a114;
    ddp_srch_attr_rec.attribute87 := p12_a115;
    ddp_srch_attr_rec.attribute88 := p12_a116;
    ddp_srch_attr_rec.attribute89 := p12_a117;
    ddp_srch_attr_rec.attribute90 := p12_a118;
    ddp_srch_attr_rec.attribute91 := p12_a119;
    ddp_srch_attr_rec.attribute92 := p12_a120;
    ddp_srch_attr_rec.attribute93 := p12_a121;
    ddp_srch_attr_rec.attribute94 := p12_a122;
    ddp_srch_attr_rec.attribute95 := p12_a123;
    ddp_srch_attr_rec.attribute96 := p12_a124;
    ddp_srch_attr_rec.attribute97 := p12_a125;
    ddp_srch_attr_rec.attribute98 := p12_a126;
    ddp_srch_attr_rec.attribute99 := p12_a127;
    ddp_srch_attr_rec.attribute100 := p12_a128;
    ddp_srch_attr_rec.quota_id := p12_a129;
    ddp_srch_attr_rec.quota_name := p12_a130;
    ddp_srch_attr_rec.revenue_class_id := p12_a131;
    ddp_srch_attr_rec.revenue_class_name := p12_a132;
    ddp_srch_attr_rec.trx_batch_name := p12_a133;
    ddp_srch_attr_rec.source_trx_number := p12_a134;
    ddp_srch_attr_rec.trx_sales_line_id := p12_a135;
    ddp_srch_attr_rec.trx_line_id := p12_a136;
    ddp_srch_attr_rec.trx_id := p12_a137;
    ddp_srch_attr_rec.comm_lines_api_id := p12_a138;
    ddp_srch_attr_rec.source_doc_type := p12_a139;
    ddp_srch_attr_rec.upside_amount := p12_a140;
    ddp_srch_attr_rec.upside_quantity := p12_a141;
    ddp_srch_attr_rec.uom_code := p12_a142;
    ddp_srch_attr_rec.forecast_id := p12_a143;
    ddp_srch_attr_rec.program_id := p12_a144;
    ddp_srch_attr_rec.request_id := p12_a145;
    ddp_srch_attr_rec.program_application_id := p12_a146;
    ddp_srch_attr_rec.program_update_date := p12_a147;
    ddp_srch_attr_rec.adj_comm_lines_api_id := p12_a148;
    ddp_srch_attr_rec.invoice_number := p12_a149;
    ddp_srch_attr_rec.invoice_date := p12_a150;
    ddp_srch_attr_rec.order_number := p12_a151;
    ddp_srch_attr_rec.order_date := p12_a152;
    ddp_srch_attr_rec.line_number := p12_a153;
    ddp_srch_attr_rec.customer_id := p12_a154;
    ddp_srch_attr_rec.bill_to_address_id := p12_a155;
    ddp_srch_attr_rec.ship_to_address_id := p12_a156;
    ddp_srch_attr_rec.bill_to_contact_id := p12_a157;
    ddp_srch_attr_rec.ship_to_contact_id := p12_a158;
    ddp_srch_attr_rec.load_status := p12_a159;
    ddp_srch_attr_rec.revenue_type_disp := p12_a160;
    ddp_srch_attr_rec.revenue_type := p12_a161;
    ddp_srch_attr_rec.adjust_rollup_flag := p12_a162;
    ddp_srch_attr_rec.adjust_date := p12_a163;
    ddp_srch_attr_rec.adjusted_by := p12_a164;
    ddp_srch_attr_rec.adjust_status_disp := p12_a165;
    ddp_srch_attr_rec.adjust_status := NVL(p12_a166,'NEW');
    ddp_srch_attr_rec.adjust_comments := p12_a167;
    ddp_srch_attr_rec.type := p12_a168;
    ddp_srch_attr_rec.pre_processed_code := p12_a169;
    ddp_srch_attr_rec.comp_group_id := p12_a170;
    ddp_srch_attr_rec.srp_plan_assign_id := p12_a171;
    ddp_srch_attr_rec.role_id := p12_a172;
    ddp_srch_attr_rec.sales_channel := p12_a173;
    ddp_srch_attr_rec.object_version_number := p12_a174;
    ddp_srch_attr_rec.split_pct := p12_a175;
    ddp_srch_attr_rec.split_status := p12_a176;
    ddp_srch_attr_rec.commission_amount := p12_a177;
    ddp_srch_attr_rec.role_name := p12_a178;
    ddp_srch_attr_rec.comp_group_name := p12_a179;
    ddp_srch_attr_rec.pre_processed_code_disp := p12_a180;
    ddp_srch_attr_rec.customer_name := p12_a181;
    ddp_srch_attr_rec.customer_number := p12_a182;
    ddp_srch_attr_rec.inventory_item_id := p12_a183;
    ddp_srch_attr_rec.source_trx_id := p12_a184;
    ddp_srch_attr_rec.source_trx_line_id := p12_a185;
    ddp_srch_attr_rec.source_trx_sales_line_id := p12_a186;
    ddp_srch_attr_rec.org_id := p12_a187;
    ddp_srch_attr_rec.terr_id := p12_a188;
    ddp_srch_attr_rec.preserve_credit_override_flag := NVL(p12_a189,'N');
    ddp_srch_attr_rec.terr_name := p12_a190;










    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.get_adj(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_org_id,
      p_salesrep_id,
      p_pr_date_to,
      p_pr_date_from,
      p_calc_status,
      p_adj_status,
      p_load_status,
      p_invoice_num,
      p_order_num,
      ddp_srch_attr_rec,
      p_first,
      p_last,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddx_adj_tbl,
      x_adj_count,
      x_valid_trx_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















    cn_get_tx_data_pub_w.rosetta_table_copy_out_p1(ddx_adj_tbl, p19_a0
      , p19_a1
      , p19_a2
      , p19_a3
      , p19_a4
      , p19_a5
      , p19_a6
      , p19_a7
      , p19_a8
      , p19_a9
      , p19_a10
      , p19_a11
      , p19_a12
      , p19_a13
      , p19_a14
      , p19_a15
      , p19_a16
      , p19_a17
      , p19_a18
      , p19_a19
      , p19_a20
      , p19_a21
      , p19_a22
      , p19_a23
      , p19_a24
      , p19_a25
      , p19_a26
      , p19_a27
      , p19_a28
      , p19_a29
      , p19_a30
      , p19_a31
      , p19_a32
      , p19_a33
      , p19_a34
      , p19_a35
      , p19_a36
      , p19_a37
      , p19_a38
      , p19_a39
      , p19_a40
      , p19_a41
      , p19_a42
      , p19_a43
      , p19_a44
      , p19_a45
      , p19_a46
      , p19_a47
      , p19_a48
      , p19_a49
      , p19_a50
      , p19_a51
      , p19_a52
      , p19_a53
      , p19_a54
      , p19_a55
      , p19_a56
      , p19_a57
      , p19_a58
      , p19_a59
      , p19_a60
      , p19_a61
      , p19_a62
      , p19_a63
      , p19_a64
      , p19_a65
      , p19_a66
      , p19_a67
      , p19_a68
      , p19_a69
      , p19_a70
      , p19_a71
      , p19_a72
      , p19_a73
      , p19_a74
      , p19_a75
      , p19_a76
      , p19_a77
      , p19_a78
      , p19_a79
      , p19_a80
      , p19_a81
      , p19_a82
      , p19_a83
      , p19_a84
      , p19_a85
      , p19_a86
      , p19_a87
      , p19_a88
      , p19_a89
      , p19_a90
      , p19_a91
      , p19_a92
      , p19_a93
      , p19_a94
      , p19_a95
      , p19_a96
      , p19_a97
      , p19_a98
      , p19_a99
      , p19_a100
      , p19_a101
      , p19_a102
      , p19_a103
      , p19_a104
      , p19_a105
      , p19_a106
      , p19_a107
      , p19_a108
      , p19_a109
      , p19_a110
      , p19_a111
      , p19_a112
      , p19_a113
      , p19_a114
      , p19_a115
      , p19_a116
      , p19_a117
      , p19_a118
      , p19_a119
      , p19_a120
      , p19_a121
      , p19_a122
      , p19_a123
      , p19_a124
      , p19_a125
      , p19_a126
      , p19_a127
      , p19_a128
      , p19_a129
      , p19_a130
      , p19_a131
      , p19_a132
      , p19_a133
      , p19_a134
      , p19_a135
      , p19_a136
      , p19_a137
      , p19_a138
      , p19_a139
      , p19_a140
      , p19_a141
      , p19_a142
      , p19_a143
      , p19_a144
      , p19_a145
      , p19_a146
      , p19_a147
      , p19_a148
      , p19_a149
      , p19_a150
      , p19_a151
      , p19_a152
      , p19_a153
      , p19_a154
      , p19_a155
      , p19_a156
      , p19_a157
      , p19_a158
      , p19_a159
      , p19_a160
      , p19_a161
      , p19_a162
      , p19_a163
      , p19_a164
      , p19_a165
      , p19_a166
      , p19_a167
      , p19_a168
      , p19_a169
      , p19_a170
      , p19_a171
      , p19_a172
      , p19_a173
      , p19_a174
      , p19_a175
      , p19_a176
      , p19_a177
      , p19_a178
      , p19_a179
      , p19_a180
      , p19_a181
      , p19_a182
      , p19_a183
      , p19_a184
      , p19_a185
      , p19_a186
      , p19_a187
      , p19_a188
      , p19_a189
      , p19_a190
      );


  end;

  procedure get_split_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_comm_lines_api_id  NUMBER
    , p_load_status  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_DATE_TABLE
    , p9_a7 out nocopy JTF_DATE_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_DATE_TABLE
    , p9_a25 out nocopy JTF_NUMBER_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_DATE_TABLE
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a117 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a118 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a129 out nocopy JTF_NUMBER_TABLE
    , p9_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a131 out nocopy JTF_NUMBER_TABLE
    , p9_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a134 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a135 out nocopy JTF_NUMBER_TABLE
    , p9_a136 out nocopy JTF_NUMBER_TABLE
    , p9_a137 out nocopy JTF_NUMBER_TABLE
    , p9_a138 out nocopy JTF_NUMBER_TABLE
    , p9_a139 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a140 out nocopy JTF_NUMBER_TABLE
    , p9_a141 out nocopy JTF_NUMBER_TABLE
    , p9_a142 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a143 out nocopy JTF_NUMBER_TABLE
    , p9_a144 out nocopy JTF_NUMBER_TABLE
    , p9_a145 out nocopy JTF_NUMBER_TABLE
    , p9_a146 out nocopy JTF_NUMBER_TABLE
    , p9_a147 out nocopy JTF_DATE_TABLE
    , p9_a148 out nocopy JTF_NUMBER_TABLE
    , p9_a149 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a150 out nocopy JTF_DATE_TABLE
    , p9_a151 out nocopy JTF_NUMBER_TABLE
    , p9_a152 out nocopy JTF_DATE_TABLE
    , p9_a153 out nocopy JTF_NUMBER_TABLE
    , p9_a154 out nocopy JTF_NUMBER_TABLE
    , p9_a155 out nocopy JTF_NUMBER_TABLE
    , p9_a156 out nocopy JTF_NUMBER_TABLE
    , p9_a157 out nocopy JTF_NUMBER_TABLE
    , p9_a158 out nocopy JTF_NUMBER_TABLE
    , p9_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a160 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a162 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a163 out nocopy JTF_DATE_TABLE
    , p9_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a170 out nocopy JTF_NUMBER_TABLE
    , p9_a171 out nocopy JTF_NUMBER_TABLE
    , p9_a172 out nocopy JTF_NUMBER_TABLE
    , p9_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a174 out nocopy JTF_NUMBER_TABLE
    , p9_a175 out nocopy JTF_NUMBER_TABLE
    , p9_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a177 out nocopy JTF_NUMBER_TABLE
    , p9_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a183 out nocopy JTF_NUMBER_TABLE
    , p9_a184 out nocopy JTF_NUMBER_TABLE
    , p9_a185 out nocopy JTF_NUMBER_TABLE
    , p9_a186 out nocopy JTF_NUMBER_TABLE
    , p9_a187 out nocopy JTF_NUMBER_TABLE
    , p9_a188 out nocopy JTF_NUMBER_TABLE
    , p9_a189 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a190 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_adj_count out nocopy  NUMBER
  )

  as
    ddx_adj_tbl cn_get_tx_data_pub.adj_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.get_split_data(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_comm_lines_api_id,
      p_load_status,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddx_adj_tbl,
      x_adj_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    cn_get_tx_data_pub_w.rosetta_table_copy_out_p1(ddx_adj_tbl, p9_a0
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
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      , p9_a61
      , p9_a62
      , p9_a63
      , p9_a64
      , p9_a65
      , p9_a66
      , p9_a67
      , p9_a68
      , p9_a69
      , p9_a70
      , p9_a71
      , p9_a72
      , p9_a73
      , p9_a74
      , p9_a75
      , p9_a76
      , p9_a77
      , p9_a78
      , p9_a79
      , p9_a80
      , p9_a81
      , p9_a82
      , p9_a83
      , p9_a84
      , p9_a85
      , p9_a86
      , p9_a87
      , p9_a88
      , p9_a89
      , p9_a90
      , p9_a91
      , p9_a92
      , p9_a93
      , p9_a94
      , p9_a95
      , p9_a96
      , p9_a97
      , p9_a98
      , p9_a99
      , p9_a100
      , p9_a101
      , p9_a102
      , p9_a103
      , p9_a104
      , p9_a105
      , p9_a106
      , p9_a107
      , p9_a108
      , p9_a109
      , p9_a110
      , p9_a111
      , p9_a112
      , p9_a113
      , p9_a114
      , p9_a115
      , p9_a116
      , p9_a117
      , p9_a118
      , p9_a119
      , p9_a120
      , p9_a121
      , p9_a122
      , p9_a123
      , p9_a124
      , p9_a125
      , p9_a126
      , p9_a127
      , p9_a128
      , p9_a129
      , p9_a130
      , p9_a131
      , p9_a132
      , p9_a133
      , p9_a134
      , p9_a135
      , p9_a136
      , p9_a137
      , p9_a138
      , p9_a139
      , p9_a140
      , p9_a141
      , p9_a142
      , p9_a143
      , p9_a144
      , p9_a145
      , p9_a146
      , p9_a147
      , p9_a148
      , p9_a149
      , p9_a150
      , p9_a151
      , p9_a152
      , p9_a153
      , p9_a154
      , p9_a155
      , p9_a156
      , p9_a157
      , p9_a158
      , p9_a159
      , p9_a160
      , p9_a161
      , p9_a162
      , p9_a163
      , p9_a164
      , p9_a165
      , p9_a166
      , p9_a167
      , p9_a168
      , p9_a169
      , p9_a170
      , p9_a171
      , p9_a172
      , p9_a173
      , p9_a174
      , p9_a175
      , p9_a176
      , p9_a177
      , p9_a178
      , p9_a179
      , p9_a180
      , p9_a181
      , p9_a182
      , p9_a183
      , p9_a184
      , p9_a185
      , p9_a186
      , p9_a187
      , p9_a188
      , p9_a189
      , p9_a190
      );

  end;

  procedure insert_api_record(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_action  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  DATE
    , p4_a7  DATE
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  NUMBER
    , p4_a11  NUMBER
    , p4_a12  NUMBER
    , p4_a13  VARCHAR2
    , p4_a14  NUMBER
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  NUMBER
    , p4_a23  NUMBER
    , p4_a24  DATE
    , p4_a25  NUMBER
    , p4_a26  NUMBER
    , p4_a27  DATE
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
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  VARCHAR2
    , p4_a55  VARCHAR2
    , p4_a56  VARCHAR2
    , p4_a57  VARCHAR2
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  VARCHAR2
    , p4_a61  VARCHAR2
    , p4_a62  VARCHAR2
    , p4_a63  VARCHAR2
    , p4_a64  VARCHAR2
    , p4_a65  VARCHAR2
    , p4_a66  VARCHAR2
    , p4_a67  VARCHAR2
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
    , p4_a79  VARCHAR2
    , p4_a80  VARCHAR2
    , p4_a81  VARCHAR2
    , p4_a82  VARCHAR2
    , p4_a83  VARCHAR2
    , p4_a84  VARCHAR2
    , p4_a85  VARCHAR2
    , p4_a86  VARCHAR2
    , p4_a87  VARCHAR2
    , p4_a88  VARCHAR2
    , p4_a89  VARCHAR2
    , p4_a90  VARCHAR2
    , p4_a91  VARCHAR2
    , p4_a92  VARCHAR2
    , p4_a93  VARCHAR2
    , p4_a94  VARCHAR2
    , p4_a95  VARCHAR2
    , p4_a96  VARCHAR2
    , p4_a97  VARCHAR2
    , p4_a98  VARCHAR2
    , p4_a99  VARCHAR2
    , p4_a100  VARCHAR2
    , p4_a101  VARCHAR2
    , p4_a102  VARCHAR2
    , p4_a103  VARCHAR2
    , p4_a104  VARCHAR2
    , p4_a105  VARCHAR2
    , p4_a106  VARCHAR2
    , p4_a107  VARCHAR2
    , p4_a108  VARCHAR2
    , p4_a109  VARCHAR2
    , p4_a110  VARCHAR2
    , p4_a111  VARCHAR2
    , p4_a112  VARCHAR2
    , p4_a113  VARCHAR2
    , p4_a114  VARCHAR2
    , p4_a115  VARCHAR2
    , p4_a116  VARCHAR2
    , p4_a117  VARCHAR2
    , p4_a118  VARCHAR2
    , p4_a119  VARCHAR2
    , p4_a120  VARCHAR2
    , p4_a121  VARCHAR2
    , p4_a122  VARCHAR2
    , p4_a123  VARCHAR2
    , p4_a124  VARCHAR2
    , p4_a125  VARCHAR2
    , p4_a126  VARCHAR2
    , p4_a127  VARCHAR2
    , p4_a128  VARCHAR2
    , p4_a129  NUMBER
    , p4_a130  VARCHAR2
    , p4_a131  NUMBER
    , p4_a132  VARCHAR2
    , p4_a133  VARCHAR2
    , p4_a134  VARCHAR2
    , p4_a135  NUMBER
    , p4_a136  NUMBER
    , p4_a137  NUMBER
    , p4_a138  NUMBER
    , p4_a139  VARCHAR2
    , p4_a140  NUMBER
    , p4_a141  NUMBER
    , p4_a142  VARCHAR2
    , p4_a143  NUMBER
    , p4_a144  NUMBER
    , p4_a145  NUMBER
    , p4_a146  NUMBER
    , p4_a147  DATE
    , p4_a148  NUMBER
    , p4_a149  VARCHAR2
    , p4_a150  DATE
    , p4_a151  NUMBER
    , p4_a152  DATE
    , p4_a153  NUMBER
    , p4_a154  NUMBER
    , p4_a155  NUMBER
    , p4_a156  NUMBER
    , p4_a157  NUMBER
    , p4_a158  NUMBER
    , p4_a159  VARCHAR2
    , p4_a160  VARCHAR2
    , p4_a161  VARCHAR2
    , p4_a162  VARCHAR2
    , p4_a163  DATE
    , p4_a164  VARCHAR2
    , p4_a165  VARCHAR2
    , p4_a166  VARCHAR2
    , p4_a167  VARCHAR2
    , p4_a168  VARCHAR2
    , p4_a169  VARCHAR2
    , p4_a170  NUMBER
    , p4_a171  NUMBER
    , p4_a172  NUMBER
    , p4_a173  VARCHAR2
    , p4_a174  NUMBER
    , p4_a175  NUMBER
    , p4_a176  VARCHAR2
    , p4_a177  NUMBER
    , p4_a178  VARCHAR2
    , p4_a179  VARCHAR2
    , p4_a180  VARCHAR2
    , p4_a181  VARCHAR2
    , p4_a182  VARCHAR2
    , p4_a183  NUMBER
    , p4_a184  NUMBER
    , p4_a185  NUMBER
    , p4_a186  NUMBER
    , p4_a187  NUMBER
    , p4_a188  NUMBER
    , p4_a189  VARCHAR2
    , p4_a190  VARCHAR2
    , x_api_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_newtx_rec cn_get_tx_data_pub.adj_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_newtx_rec.commission_header_id := p4_a0;
    ddp_newtx_rec.direct_salesrep_number := p4_a1;
    ddp_newtx_rec.direct_salesrep_name := p4_a2;
    ddp_newtx_rec.direct_salesrep_id := p4_a3;
    ddp_newtx_rec.processed_period_id := p4_a4;
    ddp_newtx_rec.processed_period := p4_a5;
    ddp_newtx_rec.processed_date := p4_a6;
    ddp_newtx_rec.rollup_date := p4_a7;
    ddp_newtx_rec.transaction_amount := p4_a8;
    ddp_newtx_rec.transaction_amount_orig := p4_a9;
    ddp_newtx_rec.quantity := p4_a10;
    ddp_newtx_rec.discount_percentage := p4_a11;
    ddp_newtx_rec.margin_percentage := p4_a12;
    ddp_newtx_rec.orig_currency_code := p4_a13;
    ddp_newtx_rec.exchange_rate := p4_a14;
    ddp_newtx_rec.status_disp := p4_a15;
    ddp_newtx_rec.status := p4_a16;
    ddp_newtx_rec.trx_type_disp := p4_a17;
    ddp_newtx_rec.trx_type := p4_a18;
    ddp_newtx_rec.reason := p4_a19;
    ddp_newtx_rec.reason_code := p4_a20;
    ddp_newtx_rec.comments := p4_a21;
    ddp_newtx_rec.trx_batch_id := p4_a22;
    ddp_newtx_rec.created_by := p4_a23;
    ddp_newtx_rec.creation_date := p4_a24;
    ddp_newtx_rec.last_updated_by := p4_a25;
    ddp_newtx_rec.last_update_login := p4_a26;
    ddp_newtx_rec.last_update_date := p4_a27;
    ddp_newtx_rec.attribute_category := p4_a28;
    ddp_newtx_rec.attribute1 := p4_a29;
    ddp_newtx_rec.attribute2 := p4_a30;
    ddp_newtx_rec.attribute3 := p4_a31;
    ddp_newtx_rec.attribute4 := p4_a32;
    ddp_newtx_rec.attribute5 := p4_a33;
    ddp_newtx_rec.attribute6 := p4_a34;
    ddp_newtx_rec.attribute7 := p4_a35;
    ddp_newtx_rec.attribute8 := p4_a36;
    ddp_newtx_rec.attribute9 := p4_a37;
    ddp_newtx_rec.attribute10 := p4_a38;
    ddp_newtx_rec.attribute11 := p4_a39;
    ddp_newtx_rec.attribute12 := p4_a40;
    ddp_newtx_rec.attribute13 := p4_a41;
    ddp_newtx_rec.attribute14 := p4_a42;
    ddp_newtx_rec.attribute15 := p4_a43;
    ddp_newtx_rec.attribute16 := p4_a44;
    ddp_newtx_rec.attribute17 := p4_a45;
    ddp_newtx_rec.attribute18 := p4_a46;
    ddp_newtx_rec.attribute19 := p4_a47;
    ddp_newtx_rec.attribute20 := p4_a48;
    ddp_newtx_rec.attribute21 := p4_a49;
    ddp_newtx_rec.attribute22 := p4_a50;
    ddp_newtx_rec.attribute23 := p4_a51;
    ddp_newtx_rec.attribute24 := p4_a52;
    ddp_newtx_rec.attribute25 := p4_a53;
    ddp_newtx_rec.attribute26 := p4_a54;
    ddp_newtx_rec.attribute27 := p4_a55;
    ddp_newtx_rec.attribute28 := p4_a56;
    ddp_newtx_rec.attribute29 := p4_a57;
    ddp_newtx_rec.attribute30 := p4_a58;
    ddp_newtx_rec.attribute31 := p4_a59;
    ddp_newtx_rec.attribute32 := p4_a60;
    ddp_newtx_rec.attribute33 := p4_a61;
    ddp_newtx_rec.attribute34 := p4_a62;
    ddp_newtx_rec.attribute35 := p4_a63;
    ddp_newtx_rec.attribute36 := p4_a64;
    ddp_newtx_rec.attribute37 := p4_a65;
    ddp_newtx_rec.attribute38 := p4_a66;
    ddp_newtx_rec.attribute39 := p4_a67;
    ddp_newtx_rec.attribute40 := p4_a68;
    ddp_newtx_rec.attribute41 := p4_a69;
    ddp_newtx_rec.attribute42 := p4_a70;
    ddp_newtx_rec.attribute43 := p4_a71;
    ddp_newtx_rec.attribute44 := p4_a72;
    ddp_newtx_rec.attribute45 := p4_a73;
    ddp_newtx_rec.attribute46 := p4_a74;
    ddp_newtx_rec.attribute47 := p4_a75;
    ddp_newtx_rec.attribute48 := p4_a76;
    ddp_newtx_rec.attribute49 := p4_a77;
    ddp_newtx_rec.attribute50 := p4_a78;
    ddp_newtx_rec.attribute51 := p4_a79;
    ddp_newtx_rec.attribute52 := p4_a80;
    ddp_newtx_rec.attribute53 := p4_a81;
    ddp_newtx_rec.attribute54 := p4_a82;
    ddp_newtx_rec.attribute55 := p4_a83;
    ddp_newtx_rec.attribute56 := p4_a84;
    ddp_newtx_rec.attribute57 := p4_a85;
    ddp_newtx_rec.attribute58 := p4_a86;
    ddp_newtx_rec.attribute59 := p4_a87;
    ddp_newtx_rec.attribute60 := p4_a88;
    ddp_newtx_rec.attribute61 := p4_a89;
    ddp_newtx_rec.attribute62 := p4_a90;
    ddp_newtx_rec.attribute63 := p4_a91;
    ddp_newtx_rec.attribute64 := p4_a92;
    ddp_newtx_rec.attribute65 := p4_a93;
    ddp_newtx_rec.attribute66 := p4_a94;
    ddp_newtx_rec.attribute67 := p4_a95;
    ddp_newtx_rec.attribute68 := p4_a96;
    ddp_newtx_rec.attribute69 := p4_a97;
    ddp_newtx_rec.attribute70 := p4_a98;
    ddp_newtx_rec.attribute71 := p4_a99;
    ddp_newtx_rec.attribute72 := p4_a100;
    ddp_newtx_rec.attribute73 := p4_a101;
    ddp_newtx_rec.attribute74 := p4_a102;
    ddp_newtx_rec.attribute75 := p4_a103;
    ddp_newtx_rec.attribute76 := p4_a104;
    ddp_newtx_rec.attribute77 := p4_a105;
    ddp_newtx_rec.attribute78 := p4_a106;
    ddp_newtx_rec.attribute79 := p4_a107;
    ddp_newtx_rec.attribute80 := p4_a108;
    ddp_newtx_rec.attribute81 := p4_a109;
    ddp_newtx_rec.attribute82 := p4_a110;
    ddp_newtx_rec.attribute83 := p4_a111;
    ddp_newtx_rec.attribute84 := p4_a112;
    ddp_newtx_rec.attribute85 := p4_a113;
    ddp_newtx_rec.attribute86 := p4_a114;
    ddp_newtx_rec.attribute87 := p4_a115;
    ddp_newtx_rec.attribute88 := p4_a116;
    ddp_newtx_rec.attribute89 := p4_a117;
    ddp_newtx_rec.attribute90 := p4_a118;
    ddp_newtx_rec.attribute91 := p4_a119;
    ddp_newtx_rec.attribute92 := p4_a120;
    ddp_newtx_rec.attribute93 := p4_a121;
    ddp_newtx_rec.attribute94 := p4_a122;
    ddp_newtx_rec.attribute95 := p4_a123;
    ddp_newtx_rec.attribute96 := p4_a124;
    ddp_newtx_rec.attribute97 := p4_a125;
    ddp_newtx_rec.attribute98 := p4_a126;
    ddp_newtx_rec.attribute99 := p4_a127;
    ddp_newtx_rec.attribute100 := p4_a128;
    ddp_newtx_rec.quota_id := p4_a129;
    ddp_newtx_rec.quota_name := p4_a130;
    ddp_newtx_rec.revenue_class_id := p4_a131;
    ddp_newtx_rec.revenue_class_name := p4_a132;
    ddp_newtx_rec.trx_batch_name := p4_a133;
    ddp_newtx_rec.source_trx_number := p4_a134;
    ddp_newtx_rec.trx_sales_line_id := p4_a135;
    ddp_newtx_rec.trx_line_id := p4_a136;
    ddp_newtx_rec.trx_id := p4_a137;
    ddp_newtx_rec.comm_lines_api_id := p4_a138;
    ddp_newtx_rec.source_doc_type := p4_a139;
    ddp_newtx_rec.upside_amount := p4_a140;
    ddp_newtx_rec.upside_quantity := p4_a141;
    ddp_newtx_rec.uom_code := p4_a142;
    ddp_newtx_rec.forecast_id := p4_a143;
    ddp_newtx_rec.program_id := p4_a144;
    ddp_newtx_rec.request_id := p4_a145;
    ddp_newtx_rec.program_application_id := p4_a146;
    ddp_newtx_rec.program_update_date := p4_a147;
    ddp_newtx_rec.adj_comm_lines_api_id := p4_a148;
    ddp_newtx_rec.invoice_number := p4_a149;
    ddp_newtx_rec.invoice_date := p4_a150;
    ddp_newtx_rec.order_number := p4_a151;
    ddp_newtx_rec.order_date := p4_a152;
    ddp_newtx_rec.line_number := p4_a153;
    ddp_newtx_rec.customer_id := p4_a154;
    ddp_newtx_rec.bill_to_address_id := p4_a155;
    ddp_newtx_rec.ship_to_address_id := p4_a156;
    ddp_newtx_rec.bill_to_contact_id := p4_a157;
    ddp_newtx_rec.ship_to_contact_id := p4_a158;
    ddp_newtx_rec.load_status := p4_a159;
    ddp_newtx_rec.revenue_type_disp := p4_a160;
    ddp_newtx_rec.revenue_type := p4_a161;
    ddp_newtx_rec.adjust_rollup_flag := p4_a162;
    ddp_newtx_rec.adjust_date := p4_a163;
    ddp_newtx_rec.adjusted_by := p4_a164;
    ddp_newtx_rec.adjust_status_disp := p4_a165;
    ddp_newtx_rec.adjust_status := NVL(p4_a166,'NEW');
    ddp_newtx_rec.adjust_comments := p4_a167;
    ddp_newtx_rec.type := p4_a168;
    ddp_newtx_rec.pre_processed_code := p4_a169;
    ddp_newtx_rec.comp_group_id := p4_a170;
    ddp_newtx_rec.srp_plan_assign_id := p4_a171;
    ddp_newtx_rec.role_id := p4_a172;
    ddp_newtx_rec.sales_channel := p4_a173;
    ddp_newtx_rec.object_version_number := p4_a174;
    ddp_newtx_rec.split_pct := p4_a175;
    ddp_newtx_rec.split_status := p4_a176;
    ddp_newtx_rec.commission_amount := p4_a177;
    ddp_newtx_rec.role_name := p4_a178;
    ddp_newtx_rec.comp_group_name := p4_a179;
    ddp_newtx_rec.pre_processed_code_disp := p4_a180;
    ddp_newtx_rec.customer_name := p4_a181;
    ddp_newtx_rec.customer_number := p4_a182;
    ddp_newtx_rec.inventory_item_id := p4_a183;
    ddp_newtx_rec.source_trx_id := p4_a184;
    ddp_newtx_rec.source_trx_line_id := p4_a185;
    ddp_newtx_rec.source_trx_sales_line_id := p4_a186;
    ddp_newtx_rec.org_id := p4_a187;
    ddp_newtx_rec.terr_id := p4_a188;
    ddp_newtx_rec.preserve_credit_override_flag := NVL(p4_a189,'N');
    ddp_newtx_rec.terr_name := p4_a190;






    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.insert_api_record(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_action,
      ddp_newtx_rec,
      x_api_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure call_mass_update(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_org_id  NUMBER
    , p_salesrep_id  NUMBER
    , p_pr_date_to  DATE
    , p_pr_date_from  DATE
    , p_calc_status  VARCHAR2
    , p_adj_status  VARCHAR2
    , p_load_status  VARCHAR2
    , p_invoice_num  VARCHAR2
    , p_order_num  NUMBER
    , p12_a0  NUMBER
    , p12_a1  VARCHAR2
    , p12_a2  VARCHAR2
    , p12_a3  NUMBER
    , p12_a4  NUMBER
    , p12_a5  VARCHAR2
    , p12_a6  DATE
    , p12_a7  DATE
    , p12_a8  NUMBER
    , p12_a9  NUMBER
    , p12_a10  NUMBER
    , p12_a11  NUMBER
    , p12_a12  NUMBER
    , p12_a13  VARCHAR2
    , p12_a14  NUMBER
    , p12_a15  VARCHAR2
    , p12_a16  VARCHAR2
    , p12_a17  VARCHAR2
    , p12_a18  VARCHAR2
    , p12_a19  VARCHAR2
    , p12_a20  VARCHAR2
    , p12_a21  VARCHAR2
    , p12_a22  NUMBER
    , p12_a23  NUMBER
    , p12_a24  DATE
    , p12_a25  NUMBER
    , p12_a26  NUMBER
    , p12_a27  DATE
    , p12_a28  VARCHAR2
    , p12_a29  VARCHAR2
    , p12_a30  VARCHAR2
    , p12_a31  VARCHAR2
    , p12_a32  VARCHAR2
    , p12_a33  VARCHAR2
    , p12_a34  VARCHAR2
    , p12_a35  VARCHAR2
    , p12_a36  VARCHAR2
    , p12_a37  VARCHAR2
    , p12_a38  VARCHAR2
    , p12_a39  VARCHAR2
    , p12_a40  VARCHAR2
    , p12_a41  VARCHAR2
    , p12_a42  VARCHAR2
    , p12_a43  VARCHAR2
    , p12_a44  VARCHAR2
    , p12_a45  VARCHAR2
    , p12_a46  VARCHAR2
    , p12_a47  VARCHAR2
    , p12_a48  VARCHAR2
    , p12_a49  VARCHAR2
    , p12_a50  VARCHAR2
    , p12_a51  VARCHAR2
    , p12_a52  VARCHAR2
    , p12_a53  VARCHAR2
    , p12_a54  VARCHAR2
    , p12_a55  VARCHAR2
    , p12_a56  VARCHAR2
    , p12_a57  VARCHAR2
    , p12_a58  VARCHAR2
    , p12_a59  VARCHAR2
    , p12_a60  VARCHAR2
    , p12_a61  VARCHAR2
    , p12_a62  VARCHAR2
    , p12_a63  VARCHAR2
    , p12_a64  VARCHAR2
    , p12_a65  VARCHAR2
    , p12_a66  VARCHAR2
    , p12_a67  VARCHAR2
    , p12_a68  VARCHAR2
    , p12_a69  VARCHAR2
    , p12_a70  VARCHAR2
    , p12_a71  VARCHAR2
    , p12_a72  VARCHAR2
    , p12_a73  VARCHAR2
    , p12_a74  VARCHAR2
    , p12_a75  VARCHAR2
    , p12_a76  VARCHAR2
    , p12_a77  VARCHAR2
    , p12_a78  VARCHAR2
    , p12_a79  VARCHAR2
    , p12_a80  VARCHAR2
    , p12_a81  VARCHAR2
    , p12_a82  VARCHAR2
    , p12_a83  VARCHAR2
    , p12_a84  VARCHAR2
    , p12_a85  VARCHAR2
    , p12_a86  VARCHAR2
    , p12_a87  VARCHAR2
    , p12_a88  VARCHAR2
    , p12_a89  VARCHAR2
    , p12_a90  VARCHAR2
    , p12_a91  VARCHAR2
    , p12_a92  VARCHAR2
    , p12_a93  VARCHAR2
    , p12_a94  VARCHAR2
    , p12_a95  VARCHAR2
    , p12_a96  VARCHAR2
    , p12_a97  VARCHAR2
    , p12_a98  VARCHAR2
    , p12_a99  VARCHAR2
    , p12_a100  VARCHAR2
    , p12_a101  VARCHAR2
    , p12_a102  VARCHAR2
    , p12_a103  VARCHAR2
    , p12_a104  VARCHAR2
    , p12_a105  VARCHAR2
    , p12_a106  VARCHAR2
    , p12_a107  VARCHAR2
    , p12_a108  VARCHAR2
    , p12_a109  VARCHAR2
    , p12_a110  VARCHAR2
    , p12_a111  VARCHAR2
    , p12_a112  VARCHAR2
    , p12_a113  VARCHAR2
    , p12_a114  VARCHAR2
    , p12_a115  VARCHAR2
    , p12_a116  VARCHAR2
    , p12_a117  VARCHAR2
    , p12_a118  VARCHAR2
    , p12_a119  VARCHAR2
    , p12_a120  VARCHAR2
    , p12_a121  VARCHAR2
    , p12_a122  VARCHAR2
    , p12_a123  VARCHAR2
    , p12_a124  VARCHAR2
    , p12_a125  VARCHAR2
    , p12_a126  VARCHAR2
    , p12_a127  VARCHAR2
    , p12_a128  VARCHAR2
    , p12_a129  NUMBER
    , p12_a130  VARCHAR2
    , p12_a131  NUMBER
    , p12_a132  VARCHAR2
    , p12_a133  VARCHAR2
    , p12_a134  VARCHAR2
    , p12_a135  NUMBER
    , p12_a136  NUMBER
    , p12_a137  NUMBER
    , p12_a138  NUMBER
    , p12_a139  VARCHAR2
    , p12_a140  NUMBER
    , p12_a141  NUMBER
    , p12_a142  VARCHAR2
    , p12_a143  NUMBER
    , p12_a144  NUMBER
    , p12_a145  NUMBER
    , p12_a146  NUMBER
    , p12_a147  DATE
    , p12_a148  NUMBER
    , p12_a149  VARCHAR2
    , p12_a150  DATE
    , p12_a151  NUMBER
    , p12_a152  DATE
    , p12_a153  NUMBER
    , p12_a154  NUMBER
    , p12_a155  NUMBER
    , p12_a156  NUMBER
    , p12_a157  NUMBER
    , p12_a158  NUMBER
    , p12_a159  VARCHAR2
    , p12_a160  VARCHAR2
    , p12_a161  VARCHAR2
    , p12_a162  VARCHAR2
    , p12_a163  DATE
    , p12_a164  VARCHAR2
    , p12_a165  VARCHAR2
    , p12_a166  VARCHAR2
    , p12_a167  VARCHAR2
    , p12_a168  VARCHAR2
    , p12_a169  VARCHAR2
    , p12_a170  NUMBER
    , p12_a171  NUMBER
    , p12_a172  NUMBER
    , p12_a173  VARCHAR2
    , p12_a174  NUMBER
    , p12_a175  NUMBER
    , p12_a176  VARCHAR2
    , p12_a177  NUMBER
    , p12_a178  VARCHAR2
    , p12_a179  VARCHAR2
    , p12_a180  VARCHAR2
    , p12_a181  VARCHAR2
    , p12_a182  VARCHAR2
    , p12_a183  NUMBER
    , p12_a184  NUMBER
    , p12_a185  NUMBER
    , p12_a186  NUMBER
    , p12_a187  NUMBER
    , p12_a188  NUMBER
    , p12_a189  VARCHAR2
    , p12_a190  VARCHAR2
    , p_mass_adj_type  VARCHAR2
    , p14_a0  NUMBER
    , p14_a1  VARCHAR2
    , p14_a2  VARCHAR2
    , p14_a3  NUMBER
    , p14_a4  NUMBER
    , p14_a5  VARCHAR2
    , p14_a6  DATE
    , p14_a7  DATE
    , p14_a8  NUMBER
    , p14_a9  NUMBER
    , p14_a10  NUMBER
    , p14_a11  NUMBER
    , p14_a12  NUMBER
    , p14_a13  VARCHAR2
    , p14_a14  NUMBER
    , p14_a15  VARCHAR2
    , p14_a16  VARCHAR2
    , p14_a17  VARCHAR2
    , p14_a18  VARCHAR2
    , p14_a19  VARCHAR2
    , p14_a20  VARCHAR2
    , p14_a21  VARCHAR2
    , p14_a22  NUMBER
    , p14_a23  NUMBER
    , p14_a24  DATE
    , p14_a25  NUMBER
    , p14_a26  NUMBER
    , p14_a27  DATE
    , p14_a28  VARCHAR2
    , p14_a29  VARCHAR2
    , p14_a30  VARCHAR2
    , p14_a31  VARCHAR2
    , p14_a32  VARCHAR2
    , p14_a33  VARCHAR2
    , p14_a34  VARCHAR2
    , p14_a35  VARCHAR2
    , p14_a36  VARCHAR2
    , p14_a37  VARCHAR2
    , p14_a38  VARCHAR2
    , p14_a39  VARCHAR2
    , p14_a40  VARCHAR2
    , p14_a41  VARCHAR2
    , p14_a42  VARCHAR2
    , p14_a43  VARCHAR2
    , p14_a44  VARCHAR2
    , p14_a45  VARCHAR2
    , p14_a46  VARCHAR2
    , p14_a47  VARCHAR2
    , p14_a48  VARCHAR2
    , p14_a49  VARCHAR2
    , p14_a50  VARCHAR2
    , p14_a51  VARCHAR2
    , p14_a52  VARCHAR2
    , p14_a53  VARCHAR2
    , p14_a54  VARCHAR2
    , p14_a55  VARCHAR2
    , p14_a56  VARCHAR2
    , p14_a57  VARCHAR2
    , p14_a58  VARCHAR2
    , p14_a59  VARCHAR2
    , p14_a60  VARCHAR2
    , p14_a61  VARCHAR2
    , p14_a62  VARCHAR2
    , p14_a63  VARCHAR2
    , p14_a64  VARCHAR2
    , p14_a65  VARCHAR2
    , p14_a66  VARCHAR2
    , p14_a67  VARCHAR2
    , p14_a68  VARCHAR2
    , p14_a69  VARCHAR2
    , p14_a70  VARCHAR2
    , p14_a71  VARCHAR2
    , p14_a72  VARCHAR2
    , p14_a73  VARCHAR2
    , p14_a74  VARCHAR2
    , p14_a75  VARCHAR2
    , p14_a76  VARCHAR2
    , p14_a77  VARCHAR2
    , p14_a78  VARCHAR2
    , p14_a79  VARCHAR2
    , p14_a80  VARCHAR2
    , p14_a81  VARCHAR2
    , p14_a82  VARCHAR2
    , p14_a83  VARCHAR2
    , p14_a84  VARCHAR2
    , p14_a85  VARCHAR2
    , p14_a86  VARCHAR2
    , p14_a87  VARCHAR2
    , p14_a88  VARCHAR2
    , p14_a89  VARCHAR2
    , p14_a90  VARCHAR2
    , p14_a91  VARCHAR2
    , p14_a92  VARCHAR2
    , p14_a93  VARCHAR2
    , p14_a94  VARCHAR2
    , p14_a95  VARCHAR2
    , p14_a96  VARCHAR2
    , p14_a97  VARCHAR2
    , p14_a98  VARCHAR2
    , p14_a99  VARCHAR2
    , p14_a100  VARCHAR2
    , p14_a101  VARCHAR2
    , p14_a102  VARCHAR2
    , p14_a103  VARCHAR2
    , p14_a104  VARCHAR2
    , p14_a105  VARCHAR2
    , p14_a106  VARCHAR2
    , p14_a107  VARCHAR2
    , p14_a108  VARCHAR2
    , p14_a109  VARCHAR2
    , p14_a110  VARCHAR2
    , p14_a111  VARCHAR2
    , p14_a112  VARCHAR2
    , p14_a113  VARCHAR2
    , p14_a114  VARCHAR2
    , p14_a115  VARCHAR2
    , p14_a116  VARCHAR2
    , p14_a117  VARCHAR2
    , p14_a118  VARCHAR2
    , p14_a119  VARCHAR2
    , p14_a120  VARCHAR2
    , p14_a121  VARCHAR2
    , p14_a122  VARCHAR2
    , p14_a123  VARCHAR2
    , p14_a124  VARCHAR2
    , p14_a125  VARCHAR2
    , p14_a126  VARCHAR2
    , p14_a127  VARCHAR2
    , p14_a128  VARCHAR2
    , p14_a129  NUMBER
    , p14_a130  VARCHAR2
    , p14_a131  NUMBER
    , p14_a132  VARCHAR2
    , p14_a133  VARCHAR2
    , p14_a134  VARCHAR2
    , p14_a135  NUMBER
    , p14_a136  NUMBER
    , p14_a137  NUMBER
    , p14_a138  NUMBER
    , p14_a139  VARCHAR2
    , p14_a140  NUMBER
    , p14_a141  NUMBER
    , p14_a142  VARCHAR2
    , p14_a143  NUMBER
    , p14_a144  NUMBER
    , p14_a145  NUMBER
    , p14_a146  NUMBER
    , p14_a147  DATE
    , p14_a148  NUMBER
    , p14_a149  VARCHAR2
    , p14_a150  DATE
    , p14_a151  NUMBER
    , p14_a152  DATE
    , p14_a153  NUMBER
    , p14_a154  NUMBER
    , p14_a155  NUMBER
    , p14_a156  NUMBER
    , p14_a157  NUMBER
    , p14_a158  NUMBER
    , p14_a159  VARCHAR2
    , p14_a160  VARCHAR2
    , p14_a161  VARCHAR2
    , p14_a162  VARCHAR2
    , p14_a163  DATE
    , p14_a164  VARCHAR2
    , p14_a165  VARCHAR2
    , p14_a166  VARCHAR2
    , p14_a167  VARCHAR2
    , p14_a168  VARCHAR2
    , p14_a169  VARCHAR2
    , p14_a170  NUMBER
    , p14_a171  NUMBER
    , p14_a172  NUMBER
    , p14_a173  VARCHAR2
    , p14_a174  NUMBER
    , p14_a175  NUMBER
    , p14_a176  VARCHAR2
    , p14_a177  NUMBER
    , p14_a178  VARCHAR2
    , p14_a179  VARCHAR2
    , p14_a180  VARCHAR2
    , p14_a181  VARCHAR2
    , p14_a182  VARCHAR2
    , p14_a183  NUMBER
    , p14_a184  NUMBER
    , p14_a185  NUMBER
    , p14_a186  NUMBER
    , p14_a187  NUMBER
    , p14_a188  NUMBER
    , p14_a189  VARCHAR2
    , p14_a190  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_srch_attr_rec cn_get_tx_data_pub.adj_rec_type;
    ddp_adj_rec cn_get_tx_data_pub.adj_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_srch_attr_rec.commission_header_id := p12_a0;
    ddp_srch_attr_rec.direct_salesrep_number := p12_a1;
    ddp_srch_attr_rec.direct_salesrep_name := p12_a2;
    ddp_srch_attr_rec.direct_salesrep_id := p12_a3;
    ddp_srch_attr_rec.processed_period_id := p12_a4;
    ddp_srch_attr_rec.processed_period := p12_a5;
    ddp_srch_attr_rec.processed_date := p12_a6;
    ddp_srch_attr_rec.rollup_date := p12_a7;
    ddp_srch_attr_rec.transaction_amount := p12_a8;
    ddp_srch_attr_rec.transaction_amount_orig := p12_a9;
    ddp_srch_attr_rec.quantity := p12_a10;
    ddp_srch_attr_rec.discount_percentage := p12_a11;
    ddp_srch_attr_rec.margin_percentage := p12_a12;
    ddp_srch_attr_rec.orig_currency_code := p12_a13;
    ddp_srch_attr_rec.exchange_rate := p12_a14;
    ddp_srch_attr_rec.status_disp := p12_a15;
    ddp_srch_attr_rec.status := p12_a16;
    ddp_srch_attr_rec.trx_type_disp := p12_a17;
    ddp_srch_attr_rec.trx_type := p12_a18;
    ddp_srch_attr_rec.reason := p12_a19;
    ddp_srch_attr_rec.reason_code := p12_a20;
    ddp_srch_attr_rec.comments := p12_a21;
    ddp_srch_attr_rec.trx_batch_id := p12_a22;
    ddp_srch_attr_rec.created_by := p12_a23;
    ddp_srch_attr_rec.creation_date := p12_a24;
    ddp_srch_attr_rec.last_updated_by := p12_a25;
    ddp_srch_attr_rec.last_update_login := p12_a26;
    ddp_srch_attr_rec.last_update_date := p12_a27;
    ddp_srch_attr_rec.attribute_category := p12_a28;
    ddp_srch_attr_rec.attribute1 := p12_a29;
    ddp_srch_attr_rec.attribute2 := p12_a30;
    ddp_srch_attr_rec.attribute3 := p12_a31;
    ddp_srch_attr_rec.attribute4 := p12_a32;
    ddp_srch_attr_rec.attribute5 := p12_a33;
    ddp_srch_attr_rec.attribute6 := p12_a34;
    ddp_srch_attr_rec.attribute7 := p12_a35;
    ddp_srch_attr_rec.attribute8 := p12_a36;
    ddp_srch_attr_rec.attribute9 := p12_a37;
    ddp_srch_attr_rec.attribute10 := p12_a38;
    ddp_srch_attr_rec.attribute11 := p12_a39;
    ddp_srch_attr_rec.attribute12 := p12_a40;
    ddp_srch_attr_rec.attribute13 := p12_a41;
    ddp_srch_attr_rec.attribute14 := p12_a42;
    ddp_srch_attr_rec.attribute15 := p12_a43;
    ddp_srch_attr_rec.attribute16 := p12_a44;
    ddp_srch_attr_rec.attribute17 := p12_a45;
    ddp_srch_attr_rec.attribute18 := p12_a46;
    ddp_srch_attr_rec.attribute19 := p12_a47;
    ddp_srch_attr_rec.attribute20 := p12_a48;
    ddp_srch_attr_rec.attribute21 := p12_a49;
    ddp_srch_attr_rec.attribute22 := p12_a50;
    ddp_srch_attr_rec.attribute23 := p12_a51;
    ddp_srch_attr_rec.attribute24 := p12_a52;
    ddp_srch_attr_rec.attribute25 := p12_a53;
    ddp_srch_attr_rec.attribute26 := p12_a54;
    ddp_srch_attr_rec.attribute27 := p12_a55;
    ddp_srch_attr_rec.attribute28 := p12_a56;
    ddp_srch_attr_rec.attribute29 := p12_a57;
    ddp_srch_attr_rec.attribute30 := p12_a58;
    ddp_srch_attr_rec.attribute31 := p12_a59;
    ddp_srch_attr_rec.attribute32 := p12_a60;
    ddp_srch_attr_rec.attribute33 := p12_a61;
    ddp_srch_attr_rec.attribute34 := p12_a62;
    ddp_srch_attr_rec.attribute35 := p12_a63;
    ddp_srch_attr_rec.attribute36 := p12_a64;
    ddp_srch_attr_rec.attribute37 := p12_a65;
    ddp_srch_attr_rec.attribute38 := p12_a66;
    ddp_srch_attr_rec.attribute39 := p12_a67;
    ddp_srch_attr_rec.attribute40 := p12_a68;
    ddp_srch_attr_rec.attribute41 := p12_a69;
    ddp_srch_attr_rec.attribute42 := p12_a70;
    ddp_srch_attr_rec.attribute43 := p12_a71;
    ddp_srch_attr_rec.attribute44 := p12_a72;
    ddp_srch_attr_rec.attribute45 := p12_a73;
    ddp_srch_attr_rec.attribute46 := p12_a74;
    ddp_srch_attr_rec.attribute47 := p12_a75;
    ddp_srch_attr_rec.attribute48 := p12_a76;
    ddp_srch_attr_rec.attribute49 := p12_a77;
    ddp_srch_attr_rec.attribute50 := p12_a78;
    ddp_srch_attr_rec.attribute51 := p12_a79;
    ddp_srch_attr_rec.attribute52 := p12_a80;
    ddp_srch_attr_rec.attribute53 := p12_a81;
    ddp_srch_attr_rec.attribute54 := p12_a82;
    ddp_srch_attr_rec.attribute55 := p12_a83;
    ddp_srch_attr_rec.attribute56 := p12_a84;
    ddp_srch_attr_rec.attribute57 := p12_a85;
    ddp_srch_attr_rec.attribute58 := p12_a86;
    ddp_srch_attr_rec.attribute59 := p12_a87;
    ddp_srch_attr_rec.attribute60 := p12_a88;
    ddp_srch_attr_rec.attribute61 := p12_a89;
    ddp_srch_attr_rec.attribute62 := p12_a90;
    ddp_srch_attr_rec.attribute63 := p12_a91;
    ddp_srch_attr_rec.attribute64 := p12_a92;
    ddp_srch_attr_rec.attribute65 := p12_a93;
    ddp_srch_attr_rec.attribute66 := p12_a94;
    ddp_srch_attr_rec.attribute67 := p12_a95;
    ddp_srch_attr_rec.attribute68 := p12_a96;
    ddp_srch_attr_rec.attribute69 := p12_a97;
    ddp_srch_attr_rec.attribute70 := p12_a98;
    ddp_srch_attr_rec.attribute71 := p12_a99;
    ddp_srch_attr_rec.attribute72 := p12_a100;
    ddp_srch_attr_rec.attribute73 := p12_a101;
    ddp_srch_attr_rec.attribute74 := p12_a102;
    ddp_srch_attr_rec.attribute75 := p12_a103;
    ddp_srch_attr_rec.attribute76 := p12_a104;
    ddp_srch_attr_rec.attribute77 := p12_a105;
    ddp_srch_attr_rec.attribute78 := p12_a106;
    ddp_srch_attr_rec.attribute79 := p12_a107;
    ddp_srch_attr_rec.attribute80 := p12_a108;
    ddp_srch_attr_rec.attribute81 := p12_a109;
    ddp_srch_attr_rec.attribute82 := p12_a110;
    ddp_srch_attr_rec.attribute83 := p12_a111;
    ddp_srch_attr_rec.attribute84 := p12_a112;
    ddp_srch_attr_rec.attribute85 := p12_a113;
    ddp_srch_attr_rec.attribute86 := p12_a114;
    ddp_srch_attr_rec.attribute87 := p12_a115;
    ddp_srch_attr_rec.attribute88 := p12_a116;
    ddp_srch_attr_rec.attribute89 := p12_a117;
    ddp_srch_attr_rec.attribute90 := p12_a118;
    ddp_srch_attr_rec.attribute91 := p12_a119;
    ddp_srch_attr_rec.attribute92 := p12_a120;
    ddp_srch_attr_rec.attribute93 := p12_a121;
    ddp_srch_attr_rec.attribute94 := p12_a122;
    ddp_srch_attr_rec.attribute95 := p12_a123;
    ddp_srch_attr_rec.attribute96 := p12_a124;
    ddp_srch_attr_rec.attribute97 := p12_a125;
    ddp_srch_attr_rec.attribute98 := p12_a126;
    ddp_srch_attr_rec.attribute99 := p12_a127;
    ddp_srch_attr_rec.attribute100 := p12_a128;
    ddp_srch_attr_rec.quota_id := p12_a129;
    ddp_srch_attr_rec.quota_name := p12_a130;
    ddp_srch_attr_rec.revenue_class_id := p12_a131;
    ddp_srch_attr_rec.revenue_class_name := p12_a132;
    ddp_srch_attr_rec.trx_batch_name := p12_a133;
    ddp_srch_attr_rec.source_trx_number := p12_a134;
    ddp_srch_attr_rec.trx_sales_line_id := p12_a135;
    ddp_srch_attr_rec.trx_line_id := p12_a136;
    ddp_srch_attr_rec.trx_id := p12_a137;
    ddp_srch_attr_rec.comm_lines_api_id := p12_a138;
    ddp_srch_attr_rec.source_doc_type := p12_a139;
    ddp_srch_attr_rec.upside_amount := p12_a140;
    ddp_srch_attr_rec.upside_quantity := p12_a141;
    ddp_srch_attr_rec.uom_code := p12_a142;
    ddp_srch_attr_rec.forecast_id := p12_a143;
    ddp_srch_attr_rec.program_id := p12_a144;
    ddp_srch_attr_rec.request_id := p12_a145;
    ddp_srch_attr_rec.program_application_id := p12_a146;
    ddp_srch_attr_rec.program_update_date := p12_a147;
    ddp_srch_attr_rec.adj_comm_lines_api_id := p12_a148;
    ddp_srch_attr_rec.invoice_number := p12_a149;
    ddp_srch_attr_rec.invoice_date := p12_a150;
    ddp_srch_attr_rec.order_number := p12_a151;
    ddp_srch_attr_rec.order_date := p12_a152;
    ddp_srch_attr_rec.line_number := p12_a153;
    ddp_srch_attr_rec.customer_id := p12_a154;
    ddp_srch_attr_rec.bill_to_address_id := p12_a155;
    ddp_srch_attr_rec.ship_to_address_id := p12_a156;
    ddp_srch_attr_rec.bill_to_contact_id := p12_a157;
    ddp_srch_attr_rec.ship_to_contact_id := p12_a158;
    ddp_srch_attr_rec.load_status := p12_a159;
    ddp_srch_attr_rec.revenue_type_disp := p12_a160;
    ddp_srch_attr_rec.revenue_type := p12_a161;
    ddp_srch_attr_rec.adjust_rollup_flag := p12_a162;
    ddp_srch_attr_rec.adjust_date := p12_a163;
    ddp_srch_attr_rec.adjusted_by := p12_a164;
    ddp_srch_attr_rec.adjust_status_disp := p12_a165;
    ddp_srch_attr_rec.adjust_status := NVL(p12_a166,'NEW');
    ddp_srch_attr_rec.adjust_comments := p12_a167;
    ddp_srch_attr_rec.type := p12_a168;
    ddp_srch_attr_rec.pre_processed_code := p12_a169;
    ddp_srch_attr_rec.comp_group_id := p12_a170;
    ddp_srch_attr_rec.srp_plan_assign_id := p12_a171;
    ddp_srch_attr_rec.role_id := p12_a172;
    ddp_srch_attr_rec.sales_channel := p12_a173;
    ddp_srch_attr_rec.object_version_number := p12_a174;
    ddp_srch_attr_rec.split_pct := p12_a175;
    ddp_srch_attr_rec.split_status := p12_a176;
    ddp_srch_attr_rec.commission_amount := p12_a177;
    ddp_srch_attr_rec.role_name := p12_a178;
    ddp_srch_attr_rec.comp_group_name := p12_a179;
    ddp_srch_attr_rec.pre_processed_code_disp := p12_a180;
    ddp_srch_attr_rec.customer_name := p12_a181;
    ddp_srch_attr_rec.customer_number := p12_a182;
    ddp_srch_attr_rec.inventory_item_id := p12_a183;
    ddp_srch_attr_rec.source_trx_id := p12_a184;
    ddp_srch_attr_rec.source_trx_line_id := p12_a185;
    ddp_srch_attr_rec.source_trx_sales_line_id := p12_a186;
    ddp_srch_attr_rec.org_id := p12_a187;
    ddp_srch_attr_rec.terr_id := p12_a188;
    ddp_srch_attr_rec.preserve_credit_override_flag := NVL( p12_a189,'N');
    ddp_srch_attr_rec.terr_name := p12_a190;


    ddp_adj_rec.commission_header_id := p14_a0;
    ddp_adj_rec.direct_salesrep_number := p14_a1;
    ddp_adj_rec.direct_salesrep_name := p14_a2;
    ddp_adj_rec.direct_salesrep_id := p14_a3;
    ddp_adj_rec.processed_period_id := p14_a4;
    ddp_adj_rec.processed_period := p14_a5;
    ddp_adj_rec.processed_date := p14_a6;
    ddp_adj_rec.rollup_date := p14_a7;
    ddp_adj_rec.transaction_amount := p14_a8;
    ddp_adj_rec.transaction_amount_orig := p14_a9;
    ddp_adj_rec.quantity := p14_a10;
    ddp_adj_rec.discount_percentage := p14_a11;
    ddp_adj_rec.margin_percentage := p14_a12;
    ddp_adj_rec.orig_currency_code := p14_a13;
    ddp_adj_rec.exchange_rate := p14_a14;
    ddp_adj_rec.status_disp := p14_a15;
    ddp_adj_rec.status := p14_a16;
    ddp_adj_rec.trx_type_disp := p14_a17;
    ddp_adj_rec.trx_type := p14_a18;
    ddp_adj_rec.reason := p14_a19;
    ddp_adj_rec.reason_code := p14_a20;
    ddp_adj_rec.comments := p14_a21;
    ddp_adj_rec.trx_batch_id := p14_a22;
    ddp_adj_rec.created_by := p14_a23;
    ddp_adj_rec.creation_date := p14_a24;
    ddp_adj_rec.last_updated_by := p14_a25;
    ddp_adj_rec.last_update_login := p14_a26;
    ddp_adj_rec.last_update_date := p14_a27;
    ddp_adj_rec.attribute_category := p14_a28;
    ddp_adj_rec.attribute1 := p14_a29;
    ddp_adj_rec.attribute2 := p14_a30;
    ddp_adj_rec.attribute3 := p14_a31;
    ddp_adj_rec.attribute4 := p14_a32;
    ddp_adj_rec.attribute5 := p14_a33;
    ddp_adj_rec.attribute6 := p14_a34;
    ddp_adj_rec.attribute7 := p14_a35;
    ddp_adj_rec.attribute8 := p14_a36;
    ddp_adj_rec.attribute9 := p14_a37;
    ddp_adj_rec.attribute10 := p14_a38;
    ddp_adj_rec.attribute11 := p14_a39;
    ddp_adj_rec.attribute12 := p14_a40;
    ddp_adj_rec.attribute13 := p14_a41;
    ddp_adj_rec.attribute14 := p14_a42;
    ddp_adj_rec.attribute15 := p14_a43;
    ddp_adj_rec.attribute16 := p14_a44;
    ddp_adj_rec.attribute17 := p14_a45;
    ddp_adj_rec.attribute18 := p14_a46;
    ddp_adj_rec.attribute19 := p14_a47;
    ddp_adj_rec.attribute20 := p14_a48;
    ddp_adj_rec.attribute21 := p14_a49;
    ddp_adj_rec.attribute22 := p14_a50;
    ddp_adj_rec.attribute23 := p14_a51;
    ddp_adj_rec.attribute24 := p14_a52;
    ddp_adj_rec.attribute25 := p14_a53;
    ddp_adj_rec.attribute26 := p14_a54;
    ddp_adj_rec.attribute27 := p14_a55;
    ddp_adj_rec.attribute28 := p14_a56;
    ddp_adj_rec.attribute29 := p14_a57;
    ddp_adj_rec.attribute30 := p14_a58;
    ddp_adj_rec.attribute31 := p14_a59;
    ddp_adj_rec.attribute32 := p14_a60;
    ddp_adj_rec.attribute33 := p14_a61;
    ddp_adj_rec.attribute34 := p14_a62;
    ddp_adj_rec.attribute35 := p14_a63;
    ddp_adj_rec.attribute36 := p14_a64;
    ddp_adj_rec.attribute37 := p14_a65;
    ddp_adj_rec.attribute38 := p14_a66;
    ddp_adj_rec.attribute39 := p14_a67;
    ddp_adj_rec.attribute40 := p14_a68;
    ddp_adj_rec.attribute41 := p14_a69;
    ddp_adj_rec.attribute42 := p14_a70;
    ddp_adj_rec.attribute43 := p14_a71;
    ddp_adj_rec.attribute44 := p14_a72;
    ddp_adj_rec.attribute45 := p14_a73;
    ddp_adj_rec.attribute46 := p14_a74;
    ddp_adj_rec.attribute47 := p14_a75;
    ddp_adj_rec.attribute48 := p14_a76;
    ddp_adj_rec.attribute49 := p14_a77;
    ddp_adj_rec.attribute50 := p14_a78;
    ddp_adj_rec.attribute51 := p14_a79;
    ddp_adj_rec.attribute52 := p14_a80;
    ddp_adj_rec.attribute53 := p14_a81;
    ddp_adj_rec.attribute54 := p14_a82;
    ddp_adj_rec.attribute55 := p14_a83;
    ddp_adj_rec.attribute56 := p14_a84;
    ddp_adj_rec.attribute57 := p14_a85;
    ddp_adj_rec.attribute58 := p14_a86;
    ddp_adj_rec.attribute59 := p14_a87;
    ddp_adj_rec.attribute60 := p14_a88;
    ddp_adj_rec.attribute61 := p14_a89;
    ddp_adj_rec.attribute62 := p14_a90;
    ddp_adj_rec.attribute63 := p14_a91;
    ddp_adj_rec.attribute64 := p14_a92;
    ddp_adj_rec.attribute65 := p14_a93;
    ddp_adj_rec.attribute66 := p14_a94;
    ddp_adj_rec.attribute67 := p14_a95;
    ddp_adj_rec.attribute68 := p14_a96;
    ddp_adj_rec.attribute69 := p14_a97;
    ddp_adj_rec.attribute70 := p14_a98;
    ddp_adj_rec.attribute71 := p14_a99;
    ddp_adj_rec.attribute72 := p14_a100;
    ddp_adj_rec.attribute73 := p14_a101;
    ddp_adj_rec.attribute74 := p14_a102;
    ddp_adj_rec.attribute75 := p14_a103;
    ddp_adj_rec.attribute76 := p14_a104;
    ddp_adj_rec.attribute77 := p14_a105;
    ddp_adj_rec.attribute78 := p14_a106;
    ddp_adj_rec.attribute79 := p14_a107;
    ddp_adj_rec.attribute80 := p14_a108;
    ddp_adj_rec.attribute81 := p14_a109;
    ddp_adj_rec.attribute82 := p14_a110;
    ddp_adj_rec.attribute83 := p14_a111;
    ddp_adj_rec.attribute84 := p14_a112;
    ddp_adj_rec.attribute85 := p14_a113;
    ddp_adj_rec.attribute86 := p14_a114;
    ddp_adj_rec.attribute87 := p14_a115;
    ddp_adj_rec.attribute88 := p14_a116;
    ddp_adj_rec.attribute89 := p14_a117;
    ddp_adj_rec.attribute90 := p14_a118;
    ddp_adj_rec.attribute91 := p14_a119;
    ddp_adj_rec.attribute92 := p14_a120;
    ddp_adj_rec.attribute93 := p14_a121;
    ddp_adj_rec.attribute94 := p14_a122;
    ddp_adj_rec.attribute95 := p14_a123;
    ddp_adj_rec.attribute96 := p14_a124;
    ddp_adj_rec.attribute97 := p14_a125;
    ddp_adj_rec.attribute98 := p14_a126;
    ddp_adj_rec.attribute99 := p14_a127;
    ddp_adj_rec.attribute100 := p14_a128;
    ddp_adj_rec.quota_id := p14_a129;
    ddp_adj_rec.quota_name := p14_a130;
    ddp_adj_rec.revenue_class_id := p14_a131;
    ddp_adj_rec.revenue_class_name := p14_a132;
    ddp_adj_rec.trx_batch_name := p14_a133;
    ddp_adj_rec.source_trx_number := p14_a134;
    ddp_adj_rec.trx_sales_line_id := p14_a135;
    ddp_adj_rec.trx_line_id := p14_a136;
    ddp_adj_rec.trx_id := p14_a137;
    ddp_adj_rec.comm_lines_api_id := p14_a138;
    ddp_adj_rec.source_doc_type := p14_a139;
    ddp_adj_rec.upside_amount := p14_a140;
    ddp_adj_rec.upside_quantity := p14_a141;
    ddp_adj_rec.uom_code := p14_a142;
    ddp_adj_rec.forecast_id := p14_a143;
    ddp_adj_rec.program_id := p14_a144;
    ddp_adj_rec.request_id := p14_a145;
    ddp_adj_rec.program_application_id := p14_a146;
    ddp_adj_rec.program_update_date := p14_a147;
    ddp_adj_rec.adj_comm_lines_api_id := p14_a148;
    ddp_adj_rec.invoice_number := p14_a149;
    ddp_adj_rec.invoice_date := p14_a150;
    ddp_adj_rec.order_number := p14_a151;
    ddp_adj_rec.order_date := p14_a152;
    ddp_adj_rec.line_number := p14_a153;
    ddp_adj_rec.customer_id := p14_a154;
    ddp_adj_rec.bill_to_address_id := p14_a155;
    ddp_adj_rec.ship_to_address_id := p14_a156;
    ddp_adj_rec.bill_to_contact_id := p14_a157;
    ddp_adj_rec.ship_to_contact_id := p14_a158;
    ddp_adj_rec.load_status := p14_a159;
    ddp_adj_rec.revenue_type_disp := p14_a160;
    ddp_adj_rec.revenue_type := p14_a161;
    ddp_adj_rec.adjust_rollup_flag := p14_a162;
    ddp_adj_rec.adjust_date := p14_a163;
    ddp_adj_rec.adjusted_by := p14_a164;
    ddp_adj_rec.adjust_status_disp := p14_a165;
    ddp_adj_rec.adjust_status := NVL(p14_a166,'NEW');
    ddp_adj_rec.adjust_comments := p14_a167;
    ddp_adj_rec.type := p14_a168;
    ddp_adj_rec.pre_processed_code := p14_a169;
    ddp_adj_rec.comp_group_id := p14_a170;
    ddp_adj_rec.srp_plan_assign_id := p14_a171;
    ddp_adj_rec.role_id := p14_a172;
    ddp_adj_rec.sales_channel := p14_a173;
    ddp_adj_rec.object_version_number := p14_a174;
    ddp_adj_rec.split_pct := p14_a175;
    ddp_adj_rec.split_status := p14_a176;
    ddp_adj_rec.commission_amount := p14_a177;
    ddp_adj_rec.role_name := p14_a178;
    ddp_adj_rec.comp_group_name := p14_a179;
    ddp_adj_rec.pre_processed_code_disp := p14_a180;
    ddp_adj_rec.customer_name := p14_a181;
    ddp_adj_rec.customer_number := p14_a182;
    ddp_adj_rec.inventory_item_id := p14_a183;
    ddp_adj_rec.source_trx_id := p14_a184;
    ddp_adj_rec.source_trx_line_id := p14_a185;
    ddp_adj_rec.source_trx_sales_line_id := p14_a186;
    ddp_adj_rec.org_id := p14_a187;
    ddp_adj_rec.terr_id := p14_a188;
    ddp_adj_rec.preserve_credit_override_flag := NVL(p14_a189,'N');
    ddp_adj_rec.terr_name := p14_a190;





    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.call_mass_update(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_org_id,
      p_salesrep_id,
      p_pr_date_to,
      p_pr_date_from,
      p_calc_status,
      p_adj_status,
      p_load_status,
      p_invoice_num,
      p_order_num,
      ddp_srch_attr_rec,
      p_mass_adj_type,
      ddp_adj_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


















  end;

  procedure call_split(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_split_type  VARCHAR2
    , p_from_salesrep_id  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p_comm_lines_api_id  NUMBER
    , p_invoice_number  VARCHAR2
    , p_order_number  NUMBER
    , p_transaction_amount  NUMBER
    , p_adjusted_by  VARCHAR2
    , p_adjust_comments  VARCHAR2
    , p_org_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_split_data_tbl cn_get_tx_data_pub.split_data_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    cn_get_tx_data_pub_w.rosetta_table_copy_in_p5(ddp_split_data_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      );












    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.call_split(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_split_type,
      p_from_salesrep_id,
      ddp_split_data_tbl,
      p_comm_lines_api_id,
      p_invoice_number,
      p_order_number,
      p_transaction_amount,
      p_adjusted_by,
      p_adjust_comments,
      p_org_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
















  end;

  procedure get_trx_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_header_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , x_tbl_count out nocopy  NUMBER
  )

  as
    ddx_trx_line_tbl cn_get_tx_data_pub.trx_line_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.get_trx_lines(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_header_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddx_trx_line_tbl,
      x_tbl_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    cn_get_tx_data_pub_w.rosetta_table_copy_out_p7(ddx_trx_line_tbl, p8_a0
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
      );

  end;

  procedure get_trx_history(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_adj_comm_lines_api_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_DATE_TABLE
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a117 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a118 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a129 out nocopy JTF_NUMBER_TABLE
    , p8_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a131 out nocopy JTF_NUMBER_TABLE
    , p8_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a134 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a135 out nocopy JTF_NUMBER_TABLE
    , p8_a136 out nocopy JTF_NUMBER_TABLE
    , p8_a137 out nocopy JTF_NUMBER_TABLE
    , p8_a138 out nocopy JTF_NUMBER_TABLE
    , p8_a139 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a140 out nocopy JTF_NUMBER_TABLE
    , p8_a141 out nocopy JTF_NUMBER_TABLE
    , p8_a142 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a143 out nocopy JTF_NUMBER_TABLE
    , p8_a144 out nocopy JTF_NUMBER_TABLE
    , p8_a145 out nocopy JTF_NUMBER_TABLE
    , p8_a146 out nocopy JTF_NUMBER_TABLE
    , p8_a147 out nocopy JTF_DATE_TABLE
    , p8_a148 out nocopy JTF_NUMBER_TABLE
    , p8_a149 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a150 out nocopy JTF_DATE_TABLE
    , p8_a151 out nocopy JTF_NUMBER_TABLE
    , p8_a152 out nocopy JTF_DATE_TABLE
    , p8_a153 out nocopy JTF_NUMBER_TABLE
    , p8_a154 out nocopy JTF_NUMBER_TABLE
    , p8_a155 out nocopy JTF_NUMBER_TABLE
    , p8_a156 out nocopy JTF_NUMBER_TABLE
    , p8_a157 out nocopy JTF_NUMBER_TABLE
    , p8_a158 out nocopy JTF_NUMBER_TABLE
    , p8_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a160 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a162 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a163 out nocopy JTF_DATE_TABLE
    , p8_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a170 out nocopy JTF_NUMBER_TABLE
    , p8_a171 out nocopy JTF_NUMBER_TABLE
    , p8_a172 out nocopy JTF_NUMBER_TABLE
    , p8_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a174 out nocopy JTF_NUMBER_TABLE
    , p8_a175 out nocopy JTF_NUMBER_TABLE
    , p8_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a177 out nocopy JTF_NUMBER_TABLE
    , p8_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a183 out nocopy JTF_NUMBER_TABLE
    , p8_a184 out nocopy JTF_NUMBER_TABLE
    , p8_a185 out nocopy JTF_NUMBER_TABLE
    , p8_a186 out nocopy JTF_NUMBER_TABLE
    , p8_a187 out nocopy JTF_NUMBER_TABLE
    , p8_a188 out nocopy JTF_NUMBER_TABLE
    , p8_a189 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a190 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_adj_count out nocopy  NUMBER
  )

  as
    ddx_adj_tbl cn_get_tx_data_pub.adj_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.get_trx_history(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_adj_comm_lines_api_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddx_adj_tbl,
      x_adj_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    cn_get_tx_data_pub_w.rosetta_table_copy_out_p1(ddx_adj_tbl, p8_a0
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
      , p8_a90
      , p8_a91
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      , p8_a99
      , p8_a100
      , p8_a101
      , p8_a102
      , p8_a103
      , p8_a104
      , p8_a105
      , p8_a106
      , p8_a107
      , p8_a108
      , p8_a109
      , p8_a110
      , p8_a111
      , p8_a112
      , p8_a113
      , p8_a114
      , p8_a115
      , p8_a116
      , p8_a117
      , p8_a118
      , p8_a119
      , p8_a120
      , p8_a121
      , p8_a122
      , p8_a123
      , p8_a124
      , p8_a125
      , p8_a126
      , p8_a127
      , p8_a128
      , p8_a129
      , p8_a130
      , p8_a131
      , p8_a132
      , p8_a133
      , p8_a134
      , p8_a135
      , p8_a136
      , p8_a137
      , p8_a138
      , p8_a139
      , p8_a140
      , p8_a141
      , p8_a142
      , p8_a143
      , p8_a144
      , p8_a145
      , p8_a146
      , p8_a147
      , p8_a148
      , p8_a149
      , p8_a150
      , p8_a151
      , p8_a152
      , p8_a153
      , p8_a154
      , p8_a155
      , p8_a156
      , p8_a157
      , p8_a158
      , p8_a159
      , p8_a160
      , p8_a161
      , p8_a162
      , p8_a163
      , p8_a164
      , p8_a165
      , p8_a166
      , p8_a167
      , p8_a168
      , p8_a169
      , p8_a170
      , p8_a171
      , p8_a172
      , p8_a173
      , p8_a174
      , p8_a175
      , p8_a176
      , p8_a177
      , p8_a178
      , p8_a179
      , p8_a180
      , p8_a181
      , p8_a182
      , p8_a183
      , p8_a184
      , p8_a185
      , p8_a186
      , p8_a187
      , p8_a188
      , p8_a189
      , p8_a190
      );

  end;

  procedure get_cust_info(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_comm_lines_api_id  NUMBER
    , p_load_status  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  VARCHAR2
  )

  as
    ddx_cust_info_rec cn_get_tx_data_pub.cust_info_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.get_cust_info(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_comm_lines_api_id,
      p_load_status,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status,
      ddx_cust_info_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_cust_info_rec.customer_id;
    p9_a1 := ddx_cust_info_rec.customer_number;
    p9_a2 := ddx_cust_info_rec.customer_name;
    p9_a3 := ddx_cust_info_rec.bill_to_address_id;
    p9_a4 := ddx_cust_info_rec.bill_to_address1;
    p9_a5 := ddx_cust_info_rec.bill_to_address2;
    p9_a6 := ddx_cust_info_rec.bill_to_address3;
    p9_a7 := ddx_cust_info_rec.bill_to_address4;
    p9_a8 := ddx_cust_info_rec.bill_to_city;
    p9_a9 := ddx_cust_info_rec.bill_to_postal_code;
    p9_a10 := ddx_cust_info_rec.bill_to_state;
    p9_a11 := ddx_cust_info_rec.ship_to_address_id;
    p9_a12 := ddx_cust_info_rec.ship_to_address1;
    p9_a13 := ddx_cust_info_rec.ship_to_address2;
    p9_a14 := ddx_cust_info_rec.ship_to_address3;
    p9_a15 := ddx_cust_info_rec.ship_to_address4;
    p9_a16 := ddx_cust_info_rec.ship_to_city;
    p9_a17 := ddx_cust_info_rec.ship_to_postal_code;
    p9_a18 := ddx_cust_info_rec.ship_to_state;
    p9_a19 := ddx_cust_info_rec.bill_to_contact_id;
    p9_a20 := ddx_cust_info_rec.bill_to_contact;
    p9_a21 := ddx_cust_info_rec.ship_to_contact_id;
    p9_a22 := ddx_cust_info_rec.ship_to_contact;
  end;

  procedure update_api_record(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  NUMBER
    , p3_a5  VARCHAR2
    , p3_a6  DATE
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  VARCHAR2
    , p3_a14  NUMBER
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  DATE
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  DATE
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  VARCHAR2
    , p3_a48  VARCHAR2
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  VARCHAR2
    , p3_a61  VARCHAR2
    , p3_a62  VARCHAR2
    , p3_a63  VARCHAR2
    , p3_a64  VARCHAR2
    , p3_a65  VARCHAR2
    , p3_a66  VARCHAR2
    , p3_a67  VARCHAR2
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  VARCHAR2
    , p3_a76  VARCHAR2
    , p3_a77  VARCHAR2
    , p3_a78  VARCHAR2
    , p3_a79  VARCHAR2
    , p3_a80  VARCHAR2
    , p3_a81  VARCHAR2
    , p3_a82  VARCHAR2
    , p3_a83  VARCHAR2
    , p3_a84  VARCHAR2
    , p3_a85  VARCHAR2
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  VARCHAR2
    , p3_a91  VARCHAR2
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  VARCHAR2
    , p3_a96  VARCHAR2
    , p3_a97  VARCHAR2
    , p3_a98  VARCHAR2
    , p3_a99  VARCHAR2
    , p3_a100  VARCHAR2
    , p3_a101  VARCHAR2
    , p3_a102  VARCHAR2
    , p3_a103  VARCHAR2
    , p3_a104  VARCHAR2
    , p3_a105  VARCHAR2
    , p3_a106  VARCHAR2
    , p3_a107  VARCHAR2
    , p3_a108  VARCHAR2
    , p3_a109  VARCHAR2
    , p3_a110  VARCHAR2
    , p3_a111  VARCHAR2
    , p3_a112  VARCHAR2
    , p3_a113  VARCHAR2
    , p3_a114  VARCHAR2
    , p3_a115  VARCHAR2
    , p3_a116  VARCHAR2
    , p3_a117  VARCHAR2
    , p3_a118  VARCHAR2
    , p3_a119  VARCHAR2
    , p3_a120  VARCHAR2
    , p3_a121  VARCHAR2
    , p3_a122  VARCHAR2
    , p3_a123  VARCHAR2
    , p3_a124  VARCHAR2
    , p3_a125  VARCHAR2
    , p3_a126  VARCHAR2
    , p3_a127  VARCHAR2
    , p3_a128  VARCHAR2
    , p3_a129  NUMBER
    , p3_a130  VARCHAR2
    , p3_a131  NUMBER
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  NUMBER
    , p3_a136  NUMBER
    , p3_a137  NUMBER
    , p3_a138  NUMBER
    , p3_a139  VARCHAR2
    , p3_a140  NUMBER
    , p3_a141  NUMBER
    , p3_a142  VARCHAR2
    , p3_a143  NUMBER
    , p3_a144  NUMBER
    , p3_a145  NUMBER
    , p3_a146  NUMBER
    , p3_a147  DATE
    , p3_a148  NUMBER
    , p3_a149  VARCHAR2
    , p3_a150  DATE
    , p3_a151  NUMBER
    , p3_a152  DATE
    , p3_a153  NUMBER
    , p3_a154  NUMBER
    , p3_a155  NUMBER
    , p3_a156  NUMBER
    , p3_a157  NUMBER
    , p3_a158  NUMBER
    , p3_a159  VARCHAR2
    , p3_a160  VARCHAR2
    , p3_a161  VARCHAR2
    , p3_a162  VARCHAR2
    , p3_a163  DATE
    , p3_a164  VARCHAR2
    , p3_a165  VARCHAR2
    , p3_a166  VARCHAR2
    , p3_a167  VARCHAR2
    , p3_a168  VARCHAR2
    , p3_a169  VARCHAR2
    , p3_a170  NUMBER
    , p3_a171  NUMBER
    , p3_a172  NUMBER
    , p3_a173  VARCHAR2
    , p3_a174  NUMBER
    , p3_a175  NUMBER
    , p3_a176  VARCHAR2
    , p3_a177  NUMBER
    , p3_a178  VARCHAR2
    , p3_a179  VARCHAR2
    , p3_a180  VARCHAR2
    , p3_a181  VARCHAR2
    , p3_a182  VARCHAR2
    , p3_a183  NUMBER
    , p3_a184  NUMBER
    , p3_a185  NUMBER
    , p3_a186  NUMBER
    , p3_a187  NUMBER
    , p3_a188  NUMBER
    , p3_a189  VARCHAR2
    , p3_a190  VARCHAR2
    , x_api_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  )

  as
    ddp_newtx_rec cn_get_tx_data_pub.adj_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_newtx_rec.commission_header_id := p3_a0;
    ddp_newtx_rec.direct_salesrep_number := p3_a1;
    ddp_newtx_rec.direct_salesrep_name := p3_a2;
    ddp_newtx_rec.direct_salesrep_id := p3_a3;
    ddp_newtx_rec.processed_period_id := p3_a4;
    ddp_newtx_rec.processed_period := p3_a5;
    ddp_newtx_rec.processed_date := p3_a6;
    ddp_newtx_rec.rollup_date := p3_a7;
    ddp_newtx_rec.transaction_amount := p3_a8;
    ddp_newtx_rec.transaction_amount_orig := p3_a9;
    ddp_newtx_rec.quantity := p3_a10;
    ddp_newtx_rec.discount_percentage := p3_a11;
    ddp_newtx_rec.margin_percentage := p3_a12;
    ddp_newtx_rec.orig_currency_code := p3_a13;
    ddp_newtx_rec.exchange_rate := p3_a14;
    ddp_newtx_rec.status_disp := p3_a15;
    ddp_newtx_rec.status := p3_a16;
    ddp_newtx_rec.trx_type_disp := p3_a17;
    ddp_newtx_rec.trx_type := p3_a18;
    ddp_newtx_rec.reason := p3_a19;
    ddp_newtx_rec.reason_code := p3_a20;
    ddp_newtx_rec.comments := p3_a21;
    ddp_newtx_rec.trx_batch_id := p3_a22;
    ddp_newtx_rec.created_by := p3_a23;
    ddp_newtx_rec.creation_date := p3_a24;
    ddp_newtx_rec.last_updated_by := p3_a25;
    ddp_newtx_rec.last_update_login := p3_a26;
    ddp_newtx_rec.last_update_date := p3_a27;
    ddp_newtx_rec.attribute_category := p3_a28;
    ddp_newtx_rec.attribute1 := p3_a29;
    ddp_newtx_rec.attribute2 := p3_a30;
    ddp_newtx_rec.attribute3 := p3_a31;
    ddp_newtx_rec.attribute4 := p3_a32;
    ddp_newtx_rec.attribute5 := p3_a33;
    ddp_newtx_rec.attribute6 := p3_a34;
    ddp_newtx_rec.attribute7 := p3_a35;
    ddp_newtx_rec.attribute8 := p3_a36;
    ddp_newtx_rec.attribute9 := p3_a37;
    ddp_newtx_rec.attribute10 := p3_a38;
    ddp_newtx_rec.attribute11 := p3_a39;
    ddp_newtx_rec.attribute12 := p3_a40;
    ddp_newtx_rec.attribute13 := p3_a41;
    ddp_newtx_rec.attribute14 := p3_a42;
    ddp_newtx_rec.attribute15 := p3_a43;
    ddp_newtx_rec.attribute16 := p3_a44;
    ddp_newtx_rec.attribute17 := p3_a45;
    ddp_newtx_rec.attribute18 := p3_a46;
    ddp_newtx_rec.attribute19 := p3_a47;
    ddp_newtx_rec.attribute20 := p3_a48;
    ddp_newtx_rec.attribute21 := p3_a49;
    ddp_newtx_rec.attribute22 := p3_a50;
    ddp_newtx_rec.attribute23 := p3_a51;
    ddp_newtx_rec.attribute24 := p3_a52;
    ddp_newtx_rec.attribute25 := p3_a53;
    ddp_newtx_rec.attribute26 := p3_a54;
    ddp_newtx_rec.attribute27 := p3_a55;
    ddp_newtx_rec.attribute28 := p3_a56;
    ddp_newtx_rec.attribute29 := p3_a57;
    ddp_newtx_rec.attribute30 := p3_a58;
    ddp_newtx_rec.attribute31 := p3_a59;
    ddp_newtx_rec.attribute32 := p3_a60;
    ddp_newtx_rec.attribute33 := p3_a61;
    ddp_newtx_rec.attribute34 := p3_a62;
    ddp_newtx_rec.attribute35 := p3_a63;
    ddp_newtx_rec.attribute36 := p3_a64;
    ddp_newtx_rec.attribute37 := p3_a65;
    ddp_newtx_rec.attribute38 := p3_a66;
    ddp_newtx_rec.attribute39 := p3_a67;
    ddp_newtx_rec.attribute40 := p3_a68;
    ddp_newtx_rec.attribute41 := p3_a69;
    ddp_newtx_rec.attribute42 := p3_a70;
    ddp_newtx_rec.attribute43 := p3_a71;
    ddp_newtx_rec.attribute44 := p3_a72;
    ddp_newtx_rec.attribute45 := p3_a73;
    ddp_newtx_rec.attribute46 := p3_a74;
    ddp_newtx_rec.attribute47 := p3_a75;
    ddp_newtx_rec.attribute48 := p3_a76;
    ddp_newtx_rec.attribute49 := p3_a77;
    ddp_newtx_rec.attribute50 := p3_a78;
    ddp_newtx_rec.attribute51 := p3_a79;
    ddp_newtx_rec.attribute52 := p3_a80;
    ddp_newtx_rec.attribute53 := p3_a81;
    ddp_newtx_rec.attribute54 := p3_a82;
    ddp_newtx_rec.attribute55 := p3_a83;
    ddp_newtx_rec.attribute56 := p3_a84;
    ddp_newtx_rec.attribute57 := p3_a85;
    ddp_newtx_rec.attribute58 := p3_a86;
    ddp_newtx_rec.attribute59 := p3_a87;
    ddp_newtx_rec.attribute60 := p3_a88;
    ddp_newtx_rec.attribute61 := p3_a89;
    ddp_newtx_rec.attribute62 := p3_a90;
    ddp_newtx_rec.attribute63 := p3_a91;
    ddp_newtx_rec.attribute64 := p3_a92;
    ddp_newtx_rec.attribute65 := p3_a93;
    ddp_newtx_rec.attribute66 := p3_a94;
    ddp_newtx_rec.attribute67 := p3_a95;
    ddp_newtx_rec.attribute68 := p3_a96;
    ddp_newtx_rec.attribute69 := p3_a97;
    ddp_newtx_rec.attribute70 := p3_a98;
    ddp_newtx_rec.attribute71 := p3_a99;
    ddp_newtx_rec.attribute72 := p3_a100;
    ddp_newtx_rec.attribute73 := p3_a101;
    ddp_newtx_rec.attribute74 := p3_a102;
    ddp_newtx_rec.attribute75 := p3_a103;
    ddp_newtx_rec.attribute76 := p3_a104;
    ddp_newtx_rec.attribute77 := p3_a105;
    ddp_newtx_rec.attribute78 := p3_a106;
    ddp_newtx_rec.attribute79 := p3_a107;
    ddp_newtx_rec.attribute80 := p3_a108;
    ddp_newtx_rec.attribute81 := p3_a109;
    ddp_newtx_rec.attribute82 := p3_a110;
    ddp_newtx_rec.attribute83 := p3_a111;
    ddp_newtx_rec.attribute84 := p3_a112;
    ddp_newtx_rec.attribute85 := p3_a113;
    ddp_newtx_rec.attribute86 := p3_a114;
    ddp_newtx_rec.attribute87 := p3_a115;
    ddp_newtx_rec.attribute88 := p3_a116;
    ddp_newtx_rec.attribute89 := p3_a117;
    ddp_newtx_rec.attribute90 := p3_a118;
    ddp_newtx_rec.attribute91 := p3_a119;
    ddp_newtx_rec.attribute92 := p3_a120;
    ddp_newtx_rec.attribute93 := p3_a121;
    ddp_newtx_rec.attribute94 := p3_a122;
    ddp_newtx_rec.attribute95 := p3_a123;
    ddp_newtx_rec.attribute96 := p3_a124;
    ddp_newtx_rec.attribute97 := p3_a125;
    ddp_newtx_rec.attribute98 := p3_a126;
    ddp_newtx_rec.attribute99 := p3_a127;
    ddp_newtx_rec.attribute100 := p3_a128;
    ddp_newtx_rec.quota_id := p3_a129;
    ddp_newtx_rec.quota_name := p3_a130;
    ddp_newtx_rec.revenue_class_id := p3_a131;
    ddp_newtx_rec.revenue_class_name := p3_a132;
    ddp_newtx_rec.trx_batch_name := p3_a133;
    ddp_newtx_rec.source_trx_number := p3_a134;
    ddp_newtx_rec.trx_sales_line_id := p3_a135;
    ddp_newtx_rec.trx_line_id := p3_a136;
    ddp_newtx_rec.trx_id := p3_a137;
    ddp_newtx_rec.comm_lines_api_id := p3_a138;
    ddp_newtx_rec.source_doc_type := p3_a139;
    ddp_newtx_rec.upside_amount := p3_a140;
    ddp_newtx_rec.upside_quantity := p3_a141;
    ddp_newtx_rec.uom_code := p3_a142;
    ddp_newtx_rec.forecast_id := p3_a143;
    ddp_newtx_rec.program_id := p3_a144;
    ddp_newtx_rec.request_id := p3_a145;
    ddp_newtx_rec.program_application_id := p3_a146;
    ddp_newtx_rec.program_update_date := p3_a147;
    ddp_newtx_rec.adj_comm_lines_api_id := p3_a148;
    ddp_newtx_rec.invoice_number := p3_a149;
    ddp_newtx_rec.invoice_date := p3_a150;
    ddp_newtx_rec.order_number := p3_a151;
    ddp_newtx_rec.order_date := p3_a152;
    ddp_newtx_rec.line_number := p3_a153;
    ddp_newtx_rec.customer_id := p3_a154;
    ddp_newtx_rec.bill_to_address_id := p3_a155;
    ddp_newtx_rec.ship_to_address_id := p3_a156;
    ddp_newtx_rec.bill_to_contact_id := p3_a157;
    ddp_newtx_rec.ship_to_contact_id := p3_a158;
    ddp_newtx_rec.load_status := p3_a159;
    ddp_newtx_rec.revenue_type_disp := p3_a160;
    ddp_newtx_rec.revenue_type := p3_a161;
    ddp_newtx_rec.adjust_rollup_flag := p3_a162;
    ddp_newtx_rec.adjust_date := p3_a163;
    ddp_newtx_rec.adjusted_by := p3_a164;
    ddp_newtx_rec.adjust_status_disp := p3_a165;
    ddp_newtx_rec.adjust_status := NVL(p3_a166,'NEW');
    ddp_newtx_rec.adjust_comments := p3_a167;
    ddp_newtx_rec.type := p3_a168;
    ddp_newtx_rec.pre_processed_code := p3_a169;
    ddp_newtx_rec.comp_group_id := p3_a170;
    ddp_newtx_rec.srp_plan_assign_id := p3_a171;
    ddp_newtx_rec.role_id := p3_a172;
    ddp_newtx_rec.sales_channel := p3_a173;
    ddp_newtx_rec.object_version_number := p3_a174;
    ddp_newtx_rec.split_pct := p3_a175;
    ddp_newtx_rec.split_status := p3_a176;
    ddp_newtx_rec.commission_amount := p3_a177;
    ddp_newtx_rec.role_name := p3_a178;
    ddp_newtx_rec.comp_group_name := p3_a179;
    ddp_newtx_rec.pre_processed_code_disp := p3_a180;
    ddp_newtx_rec.customer_name := p3_a181;
    ddp_newtx_rec.customer_number := p3_a182;
    ddp_newtx_rec.inventory_item_id := p3_a183;
    ddp_newtx_rec.source_trx_id := p3_a184;
    ddp_newtx_rec.source_trx_line_id := p3_a185;
    ddp_newtx_rec.source_trx_sales_line_id := p3_a186;
    ddp_newtx_rec.org_id := p3_a187;
    ddp_newtx_rec.terr_id := p3_a188;
    ddp_newtx_rec.preserve_credit_override_flag := NVL(p3_a189,'N');
    ddp_newtx_rec.terr_name := p3_a190;






    -- here's the delegated call to the old PL/SQL routine
    cn_get_tx_data_pub.update_api_record(p_api_version,
      p_init_msg_list,
      p_validation_level,
      ddp_newtx_rec,
      x_api_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_loading_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end cn_get_tx_data_pub_w;

/
