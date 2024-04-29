--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_PVT_W" as
  /* $Header: ozfwclab.pls 120.4.12010000.3 2009/07/27 06:38:08 kpatro ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_claim_pvt.claim_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_2000
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_DATE_TABLE
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_DATE_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_DATE_TABLE
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_DATE_TABLE
    , a84 JTF_NUMBER_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_DATE_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_VARCHAR2_TABLE_2000
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_VARCHAR2_TABLE_200
    , a95 JTF_VARCHAR2_TABLE_200
    , a96 JTF_VARCHAR2_TABLE_200
    , a97 JTF_VARCHAR2_TABLE_200
    , a98 JTF_VARCHAR2_TABLE_200
    , a99 JTF_VARCHAR2_TABLE_200
    , a100 JTF_VARCHAR2_TABLE_200
    , a101 JTF_VARCHAR2_TABLE_200
    , a102 JTF_VARCHAR2_TABLE_200
    , a103 JTF_VARCHAR2_TABLE_200
    , a104 JTF_VARCHAR2_TABLE_200
    , a105 JTF_VARCHAR2_TABLE_200
    , a106 JTF_VARCHAR2_TABLE_200
    , a107 JTF_VARCHAR2_TABLE_200
    , a108 JTF_VARCHAR2_TABLE_200
    , a109 JTF_VARCHAR2_TABLE_100
    , a110 JTF_VARCHAR2_TABLE_200
    , a111 JTF_VARCHAR2_TABLE_200
    , a112 JTF_VARCHAR2_TABLE_200
    , a113 JTF_VARCHAR2_TABLE_200
    , a114 JTF_VARCHAR2_TABLE_200
    , a115 JTF_VARCHAR2_TABLE_200
    , a116 JTF_VARCHAR2_TABLE_200
    , a117 JTF_VARCHAR2_TABLE_200
    , a118 JTF_VARCHAR2_TABLE_200
    , a119 JTF_VARCHAR2_TABLE_200
    , a120 JTF_VARCHAR2_TABLE_200
    , a121 JTF_VARCHAR2_TABLE_200
    , a122 JTF_VARCHAR2_TABLE_200
    , a123 JTF_VARCHAR2_TABLE_200
    , a124 JTF_VARCHAR2_TABLE_200
    , a125 JTF_NUMBER_TABLE
    , a126 JTF_NUMBER_TABLE
    , a127 JTF_VARCHAR2_TABLE_100
    , a128 JTF_NUMBER_TABLE
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_VARCHAR2_TABLE_100
    , a131 JTF_NUMBER_TABLE
    , a132 JTF_NUMBER_TABLE
    , a133 JTF_NUMBER_TABLE
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_VARCHAR2_TABLE_300
    , a138 JTF_VARCHAR2_TABLE_300
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_VARCHAR2_TABLE_100
    , a141 JTF_NUMBER_TABLE
    , a142 JTF_NUMBER_TABLE
    , a143 JTF_VARCHAR2_TABLE_100
    , a144 JTF_VARCHAR2_TABLE_100
    , a145 JTF_NUMBER_TABLE
    , a146 JTF_VARCHAR2_TABLE_100
    , a147 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).claim_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).request_id := a7(indx);
          t(ddindx).program_application_id := a8(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).program_id := a10(indx);
          t(ddindx).created_from := a11(indx);
          t(ddindx).batch_id := a12(indx);
          t(ddindx).claim_number := a13(indx);
          t(ddindx).claim_type_id := a14(indx);
          t(ddindx).claim_class := a15(indx);
          t(ddindx).claim_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).owner_id := a18(indx);
          t(ddindx).history_event := a19(indx);
          t(ddindx).history_event_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).history_event_description := a21(indx);
          t(ddindx).split_from_claim_id := a22(indx);
          t(ddindx).duplicate_claim_id := a23(indx);
          t(ddindx).split_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).root_claim_id := a25(indx);
          t(ddindx).amount := a26(indx);
          t(ddindx).amount_adjusted := a27(indx);
          t(ddindx).amount_remaining := a28(indx);
          t(ddindx).amount_settled := a29(indx);
          t(ddindx).acctd_amount := a30(indx);
          t(ddindx).acctd_amount_remaining := a31(indx);
          t(ddindx).acctd_amount_adjusted := a32(indx);
          t(ddindx).acctd_amount_settled := a33(indx);
          t(ddindx).tax_amount := a34(indx);
          t(ddindx).tax_code := a35(indx);
          t(ddindx).tax_calculation_flag := a36(indx);
          t(ddindx).currency_code := a37(indx);
          t(ddindx).exchange_rate_type := a38(indx);
          t(ddindx).exchange_rate_date := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).exchange_rate := a40(indx);
          t(ddindx).set_of_books_id := a41(indx);
          t(ddindx).original_claim_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).source_object_id := a43(indx);
          t(ddindx).source_object_class := a44(indx);
          t(ddindx).source_object_type_id := a45(indx);
          t(ddindx).source_object_number := a46(indx);
          t(ddindx).cust_account_id := a47(indx);
          t(ddindx).cust_billto_acct_site_id := a48(indx);
          t(ddindx).cust_shipto_acct_site_id := a49(indx);
          t(ddindx).location_id := a50(indx);
          t(ddindx).pay_related_account_flag := a51(indx);
          t(ddindx).related_cust_account_id := a52(indx);
          t(ddindx).related_site_use_id := a53(indx);
          t(ddindx).relationship_type := a54(indx);
          t(ddindx).vendor_id := a55(indx);
          t(ddindx).vendor_site_id := a56(indx);
          t(ddindx).reason_type := a57(indx);
          t(ddindx).reason_code_id := a58(indx);
          t(ddindx).task_template_group_id := a59(indx);
          t(ddindx).status_code := a60(indx);
          t(ddindx).user_status_id := a61(indx);
          t(ddindx).sales_rep_id := a62(indx);
          t(ddindx).collector_id := a63(indx);
          t(ddindx).contact_id := a64(indx);
          t(ddindx).broker_id := a65(indx);
          t(ddindx).territory_id := a66(indx);
          t(ddindx).customer_ref_date := rosetta_g_miss_date_in_map(a67(indx));
          t(ddindx).customer_ref_number := a68(indx);
          t(ddindx).assigned_to := a69(indx);
          t(ddindx).receipt_id := a70(indx);
          t(ddindx).receipt_number := a71(indx);
          t(ddindx).doc_sequence_id := a72(indx);
          t(ddindx).doc_sequence_value := a73(indx);
          t(ddindx).gl_date := rosetta_g_miss_date_in_map(a74(indx));
          t(ddindx).payment_method := a75(indx);
          t(ddindx).voucher_id := a76(indx);
          t(ddindx).voucher_number := a77(indx);
          t(ddindx).payment_reference_id := a78(indx);
          t(ddindx).payment_reference_number := a79(indx);
          t(ddindx).payment_reference_date := rosetta_g_miss_date_in_map(a80(indx));
          t(ddindx).payment_status := a81(indx);
          t(ddindx).approved_flag := a82(indx);
          t(ddindx).approved_date := rosetta_g_miss_date_in_map(a83(indx));
          t(ddindx).approved_by := a84(indx);
          t(ddindx).settled_date := rosetta_g_miss_date_in_map(a85(indx));
          t(ddindx).settled_by := a86(indx);
          t(ddindx).effective_date := rosetta_g_miss_date_in_map(a87(indx));
          t(ddindx).custom_setup_id := a88(indx);
          t(ddindx).task_id := a89(indx);
          t(ddindx).country_id := a90(indx);
          t(ddindx).order_type_id := a91(indx);
          t(ddindx).comments := a92(indx);
          t(ddindx).attribute_category := a93(indx);
          t(ddindx).attribute1 := a94(indx);
          t(ddindx).attribute2 := a95(indx);
          t(ddindx).attribute3 := a96(indx);
          t(ddindx).attribute4 := a97(indx);
          t(ddindx).attribute5 := a98(indx);
          t(ddindx).attribute6 := a99(indx);
          t(ddindx).attribute7 := a100(indx);
          t(ddindx).attribute8 := a101(indx);
          t(ddindx).attribute9 := a102(indx);
          t(ddindx).attribute10 := a103(indx);
          t(ddindx).attribute11 := a104(indx);
          t(ddindx).attribute12 := a105(indx);
          t(ddindx).attribute13 := a106(indx);
          t(ddindx).attribute14 := a107(indx);
          t(ddindx).attribute15 := a108(indx);
          t(ddindx).deduction_attribute_category := a109(indx);
          t(ddindx).deduction_attribute1 := a110(indx);
          t(ddindx).deduction_attribute2 := a111(indx);
          t(ddindx).deduction_attribute3 := a112(indx);
          t(ddindx).deduction_attribute4 := a113(indx);
          t(ddindx).deduction_attribute5 := a114(indx);
          t(ddindx).deduction_attribute6 := a115(indx);
          t(ddindx).deduction_attribute7 := a116(indx);
          t(ddindx).deduction_attribute8 := a117(indx);
          t(ddindx).deduction_attribute9 := a118(indx);
          t(ddindx).deduction_attribute10 := a119(indx);
          t(ddindx).deduction_attribute11 := a120(indx);
          t(ddindx).deduction_attribute12 := a121(indx);
          t(ddindx).deduction_attribute13 := a122(indx);
          t(ddindx).deduction_attribute14 := a123(indx);
          t(ddindx).deduction_attribute15 := a124(indx);
          t(ddindx).org_id := a125(indx);
          t(ddindx).legal_entity_id := a126(indx);
          t(ddindx).write_off_flag := a127(indx);
          t(ddindx).write_off_threshold_amount := a128(indx);
          t(ddindx).under_write_off_threshold := a129(indx);
          t(ddindx).customer_reason := a130(indx);
          t(ddindx).ship_to_cust_account_id := a131(indx);
          t(ddindx).amount_applied := a132(indx);
          t(ddindx).applied_receipt_id := a133(indx);
          t(ddindx).applied_receipt_number := a134(indx);
          t(ddindx).wo_rec_trx_id := a135(indx);
          t(ddindx).group_claim_id := a136(indx);
          t(ddindx).appr_wf_item_key := a137(indx);
          t(ddindx).cstl_wf_item_key := a138(indx);
          t(ddindx).batch_type := a139(indx);
          t(ddindx).tax_action := a140(indx);
          t(ddindx).close_status_id := a141(indx);
          t(ddindx).open_status_id := a142(indx);
          t(ddindx).pre_auth_deduction_number := a143(indx);
          t(ddindx).pre_auth_deduction_normalized := a144(indx);
          t(ddindx).offer_id := a145(indx);
          t(ddindx).settled_from := a146(indx);
          t(ddindx).approval_in_prog := a147(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_claim_pvt.claim_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_2000
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_DATE_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_DATE_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_DATE_TABLE
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_NUMBER_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_DATE_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_VARCHAR2_TABLE_2000
    , a93 out nocopy JTF_VARCHAR2_TABLE_100
    , a94 out nocopy JTF_VARCHAR2_TABLE_200
    , a95 out nocopy JTF_VARCHAR2_TABLE_200
    , a96 out nocopy JTF_VARCHAR2_TABLE_200
    , a97 out nocopy JTF_VARCHAR2_TABLE_200
    , a98 out nocopy JTF_VARCHAR2_TABLE_200
    , a99 out nocopy JTF_VARCHAR2_TABLE_200
    , a100 out nocopy JTF_VARCHAR2_TABLE_200
    , a101 out nocopy JTF_VARCHAR2_TABLE_200
    , a102 out nocopy JTF_VARCHAR2_TABLE_200
    , a103 out nocopy JTF_VARCHAR2_TABLE_200
    , a104 out nocopy JTF_VARCHAR2_TABLE_200
    , a105 out nocopy JTF_VARCHAR2_TABLE_200
    , a106 out nocopy JTF_VARCHAR2_TABLE_200
    , a107 out nocopy JTF_VARCHAR2_TABLE_200
    , a108 out nocopy JTF_VARCHAR2_TABLE_200
    , a109 out nocopy JTF_VARCHAR2_TABLE_100
    , a110 out nocopy JTF_VARCHAR2_TABLE_200
    , a111 out nocopy JTF_VARCHAR2_TABLE_200
    , a112 out nocopy JTF_VARCHAR2_TABLE_200
    , a113 out nocopy JTF_VARCHAR2_TABLE_200
    , a114 out nocopy JTF_VARCHAR2_TABLE_200
    , a115 out nocopy JTF_VARCHAR2_TABLE_200
    , a116 out nocopy JTF_VARCHAR2_TABLE_200
    , a117 out nocopy JTF_VARCHAR2_TABLE_200
    , a118 out nocopy JTF_VARCHAR2_TABLE_200
    , a119 out nocopy JTF_VARCHAR2_TABLE_200
    , a120 out nocopy JTF_VARCHAR2_TABLE_200
    , a121 out nocopy JTF_VARCHAR2_TABLE_200
    , a122 out nocopy JTF_VARCHAR2_TABLE_200
    , a123 out nocopy JTF_VARCHAR2_TABLE_200
    , a124 out nocopy JTF_VARCHAR2_TABLE_200
    , a125 out nocopy JTF_NUMBER_TABLE
    , a126 out nocopy JTF_NUMBER_TABLE
    , a127 out nocopy JTF_VARCHAR2_TABLE_100
    , a128 out nocopy JTF_NUMBER_TABLE
    , a129 out nocopy JTF_VARCHAR2_TABLE_100
    , a130 out nocopy JTF_VARCHAR2_TABLE_100
    , a131 out nocopy JTF_NUMBER_TABLE
    , a132 out nocopy JTF_NUMBER_TABLE
    , a133 out nocopy JTF_NUMBER_TABLE
    , a134 out nocopy JTF_VARCHAR2_TABLE_100
    , a135 out nocopy JTF_NUMBER_TABLE
    , a136 out nocopy JTF_NUMBER_TABLE
    , a137 out nocopy JTF_VARCHAR2_TABLE_300
    , a138 out nocopy JTF_VARCHAR2_TABLE_300
    , a139 out nocopy JTF_VARCHAR2_TABLE_100
    , a140 out nocopy JTF_VARCHAR2_TABLE_100
    , a141 out nocopy JTF_NUMBER_TABLE
    , a142 out nocopy JTF_NUMBER_TABLE
    , a143 out nocopy JTF_VARCHAR2_TABLE_100
    , a144 out nocopy JTF_VARCHAR2_TABLE_100
    , a145 out nocopy JTF_NUMBER_TABLE
    , a146 out nocopy JTF_VARCHAR2_TABLE_100
    , a147 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_VARCHAR2_TABLE_2000();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_DATE_TABLE();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_DATE_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_DATE_TABLE();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_DATE_TABLE();
    a84 := JTF_NUMBER_TABLE();
    a85 := JTF_DATE_TABLE();
    a86 := JTF_NUMBER_TABLE();
    a87 := JTF_DATE_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_NUMBER_TABLE();
    a91 := JTF_NUMBER_TABLE();
    a92 := JTF_VARCHAR2_TABLE_2000();
    a93 := JTF_VARCHAR2_TABLE_100();
    a94 := JTF_VARCHAR2_TABLE_200();
    a95 := JTF_VARCHAR2_TABLE_200();
    a96 := JTF_VARCHAR2_TABLE_200();
    a97 := JTF_VARCHAR2_TABLE_200();
    a98 := JTF_VARCHAR2_TABLE_200();
    a99 := JTF_VARCHAR2_TABLE_200();
    a100 := JTF_VARCHAR2_TABLE_200();
    a101 := JTF_VARCHAR2_TABLE_200();
    a102 := JTF_VARCHAR2_TABLE_200();
    a103 := JTF_VARCHAR2_TABLE_200();
    a104 := JTF_VARCHAR2_TABLE_200();
    a105 := JTF_VARCHAR2_TABLE_200();
    a106 := JTF_VARCHAR2_TABLE_200();
    a107 := JTF_VARCHAR2_TABLE_200();
    a108 := JTF_VARCHAR2_TABLE_200();
    a109 := JTF_VARCHAR2_TABLE_100();
    a110 := JTF_VARCHAR2_TABLE_200();
    a111 := JTF_VARCHAR2_TABLE_200();
    a112 := JTF_VARCHAR2_TABLE_200();
    a113 := JTF_VARCHAR2_TABLE_200();
    a114 := JTF_VARCHAR2_TABLE_200();
    a115 := JTF_VARCHAR2_TABLE_200();
    a116 := JTF_VARCHAR2_TABLE_200();
    a117 := JTF_VARCHAR2_TABLE_200();
    a118 := JTF_VARCHAR2_TABLE_200();
    a119 := JTF_VARCHAR2_TABLE_200();
    a120 := JTF_VARCHAR2_TABLE_200();
    a121 := JTF_VARCHAR2_TABLE_200();
    a122 := JTF_VARCHAR2_TABLE_200();
    a123 := JTF_VARCHAR2_TABLE_200();
    a124 := JTF_VARCHAR2_TABLE_200();
    a125 := JTF_NUMBER_TABLE();
    a126 := JTF_NUMBER_TABLE();
    a127 := JTF_VARCHAR2_TABLE_100();
    a128 := JTF_NUMBER_TABLE();
    a129 := JTF_VARCHAR2_TABLE_100();
    a130 := JTF_VARCHAR2_TABLE_100();
    a131 := JTF_NUMBER_TABLE();
    a132 := JTF_NUMBER_TABLE();
    a133 := JTF_NUMBER_TABLE();
    a134 := JTF_VARCHAR2_TABLE_100();
    a135 := JTF_NUMBER_TABLE();
    a136 := JTF_NUMBER_TABLE();
    a137 := JTF_VARCHAR2_TABLE_300();
    a138 := JTF_VARCHAR2_TABLE_300();
    a139 := JTF_VARCHAR2_TABLE_100();
    a140 := JTF_VARCHAR2_TABLE_100();
    a141 := JTF_NUMBER_TABLE();
    a142 := JTF_NUMBER_TABLE();
    a143 := JTF_VARCHAR2_TABLE_100();
    a144 := JTF_VARCHAR2_TABLE_100();
    a145 := JTF_NUMBER_TABLE();
    a146 := JTF_VARCHAR2_TABLE_100();
    a147 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_VARCHAR2_TABLE_2000();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_DATE_TABLE();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_DATE_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_DATE_TABLE();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_DATE_TABLE();
      a84 := JTF_NUMBER_TABLE();
      a85 := JTF_DATE_TABLE();
      a86 := JTF_NUMBER_TABLE();
      a87 := JTF_DATE_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_NUMBER_TABLE();
      a91 := JTF_NUMBER_TABLE();
      a92 := JTF_VARCHAR2_TABLE_2000();
      a93 := JTF_VARCHAR2_TABLE_100();
      a94 := JTF_VARCHAR2_TABLE_200();
      a95 := JTF_VARCHAR2_TABLE_200();
      a96 := JTF_VARCHAR2_TABLE_200();
      a97 := JTF_VARCHAR2_TABLE_200();
      a98 := JTF_VARCHAR2_TABLE_200();
      a99 := JTF_VARCHAR2_TABLE_200();
      a100 := JTF_VARCHAR2_TABLE_200();
      a101 := JTF_VARCHAR2_TABLE_200();
      a102 := JTF_VARCHAR2_TABLE_200();
      a103 := JTF_VARCHAR2_TABLE_200();
      a104 := JTF_VARCHAR2_TABLE_200();
      a105 := JTF_VARCHAR2_TABLE_200();
      a106 := JTF_VARCHAR2_TABLE_200();
      a107 := JTF_VARCHAR2_TABLE_200();
      a108 := JTF_VARCHAR2_TABLE_200();
      a109 := JTF_VARCHAR2_TABLE_100();
      a110 := JTF_VARCHAR2_TABLE_200();
      a111 := JTF_VARCHAR2_TABLE_200();
      a112 := JTF_VARCHAR2_TABLE_200();
      a113 := JTF_VARCHAR2_TABLE_200();
      a114 := JTF_VARCHAR2_TABLE_200();
      a115 := JTF_VARCHAR2_TABLE_200();
      a116 := JTF_VARCHAR2_TABLE_200();
      a117 := JTF_VARCHAR2_TABLE_200();
      a118 := JTF_VARCHAR2_TABLE_200();
      a119 := JTF_VARCHAR2_TABLE_200();
      a120 := JTF_VARCHAR2_TABLE_200();
      a121 := JTF_VARCHAR2_TABLE_200();
      a122 := JTF_VARCHAR2_TABLE_200();
      a123 := JTF_VARCHAR2_TABLE_200();
      a124 := JTF_VARCHAR2_TABLE_200();
      a125 := JTF_NUMBER_TABLE();
      a126 := JTF_NUMBER_TABLE();
      a127 := JTF_VARCHAR2_TABLE_100();
      a128 := JTF_NUMBER_TABLE();
      a129 := JTF_VARCHAR2_TABLE_100();
      a130 := JTF_VARCHAR2_TABLE_100();
      a131 := JTF_NUMBER_TABLE();
      a132 := JTF_NUMBER_TABLE();
      a133 := JTF_NUMBER_TABLE();
      a134 := JTF_VARCHAR2_TABLE_100();
      a135 := JTF_NUMBER_TABLE();
      a136 := JTF_NUMBER_TABLE();
      a137 := JTF_VARCHAR2_TABLE_300();
      a138 := JTF_VARCHAR2_TABLE_300();
      a139 := JTF_VARCHAR2_TABLE_100();
      a140 := JTF_VARCHAR2_TABLE_100();
      a141 := JTF_NUMBER_TABLE();
      a142 := JTF_NUMBER_TABLE();
      a143 := JTF_VARCHAR2_TABLE_100();
      a144 := JTF_VARCHAR2_TABLE_100();
      a145 := JTF_NUMBER_TABLE();
      a146 := JTF_VARCHAR2_TABLE_100();
      a147 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).claim_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).request_id;
          a8(indx) := t(ddindx).program_application_id;
          a9(indx) := t(ddindx).program_update_date;
          a10(indx) := t(ddindx).program_id;
          a11(indx) := t(ddindx).created_from;
          a12(indx) := t(ddindx).batch_id;
          a13(indx) := t(ddindx).claim_number;
          a14(indx) := t(ddindx).claim_type_id;
          a15(indx) := t(ddindx).claim_class;
          a16(indx) := t(ddindx).claim_date;
          a17(indx) := t(ddindx).due_date;
          a18(indx) := t(ddindx).owner_id;
          a19(indx) := t(ddindx).history_event;
          a20(indx) := t(ddindx).history_event_date;
          a21(indx) := t(ddindx).history_event_description;
          a22(indx) := t(ddindx).split_from_claim_id;
          a23(indx) := t(ddindx).duplicate_claim_id;
          a24(indx) := t(ddindx).split_date;
          a25(indx) := t(ddindx).root_claim_id;
          a26(indx) := t(ddindx).amount;
          a27(indx) := t(ddindx).amount_adjusted;
          a28(indx) := t(ddindx).amount_remaining;
          a29(indx) := t(ddindx).amount_settled;
          a30(indx) := t(ddindx).acctd_amount;
          a31(indx) := t(ddindx).acctd_amount_remaining;
          a32(indx) := t(ddindx).acctd_amount_adjusted;
          a33(indx) := t(ddindx).acctd_amount_settled;
          a34(indx) := t(ddindx).tax_amount;
          a35(indx) := t(ddindx).tax_code;
          a36(indx) := t(ddindx).tax_calculation_flag;
          a37(indx) := t(ddindx).currency_code;
          a38(indx) := t(ddindx).exchange_rate_type;
          a39(indx) := t(ddindx).exchange_rate_date;
          a40(indx) := t(ddindx).exchange_rate;
          a41(indx) := t(ddindx).set_of_books_id;
          a42(indx) := t(ddindx).original_claim_date;
          a43(indx) := t(ddindx).source_object_id;
          a44(indx) := t(ddindx).source_object_class;
          a45(indx) := t(ddindx).source_object_type_id;
          a46(indx) := t(ddindx).source_object_number;
          a47(indx) := t(ddindx).cust_account_id;
          a48(indx) := t(ddindx).cust_billto_acct_site_id;
          a49(indx) := t(ddindx).cust_shipto_acct_site_id;
          a50(indx) := t(ddindx).location_id;
          a51(indx) := t(ddindx).pay_related_account_flag;
          a52(indx) := t(ddindx).related_cust_account_id;
          a53(indx) := t(ddindx).related_site_use_id;
          a54(indx) := t(ddindx).relationship_type;
          a55(indx) := t(ddindx).vendor_id;
          a56(indx) := t(ddindx).vendor_site_id;
          a57(indx) := t(ddindx).reason_type;
          a58(indx) := t(ddindx).reason_code_id;
          a59(indx) := t(ddindx).task_template_group_id;
          a60(indx) := t(ddindx).status_code;
          a61(indx) := t(ddindx).user_status_id;
          a62(indx) := t(ddindx).sales_rep_id;
          a63(indx) := t(ddindx).collector_id;
          a64(indx) := t(ddindx).contact_id;
          a65(indx) := t(ddindx).broker_id;
          a66(indx) := t(ddindx).territory_id;
          a67(indx) := t(ddindx).customer_ref_date;
          a68(indx) := t(ddindx).customer_ref_number;
          a69(indx) := t(ddindx).assigned_to;
          a70(indx) := t(ddindx).receipt_id;
          a71(indx) := t(ddindx).receipt_number;
          a72(indx) := t(ddindx).doc_sequence_id;
          a73(indx) := t(ddindx).doc_sequence_value;
          a74(indx) := t(ddindx).gl_date;
          a75(indx) := t(ddindx).payment_method;
          a76(indx) := t(ddindx).voucher_id;
          a77(indx) := t(ddindx).voucher_number;
          a78(indx) := t(ddindx).payment_reference_id;
          a79(indx) := t(ddindx).payment_reference_number;
          a80(indx) := t(ddindx).payment_reference_date;
          a81(indx) := t(ddindx).payment_status;
          a82(indx) := t(ddindx).approved_flag;
          a83(indx) := t(ddindx).approved_date;
          a84(indx) := t(ddindx).approved_by;
          a85(indx) := t(ddindx).settled_date;
          a86(indx) := t(ddindx).settled_by;
          a87(indx) := t(ddindx).effective_date;
          a88(indx) := t(ddindx).custom_setup_id;
          a89(indx) := t(ddindx).task_id;
          a90(indx) := t(ddindx).country_id;
          a91(indx) := t(ddindx).order_type_id;
          a92(indx) := t(ddindx).comments;
          a93(indx) := t(ddindx).attribute_category;
          a94(indx) := t(ddindx).attribute1;
          a95(indx) := t(ddindx).attribute2;
          a96(indx) := t(ddindx).attribute3;
          a97(indx) := t(ddindx).attribute4;
          a98(indx) := t(ddindx).attribute5;
          a99(indx) := t(ddindx).attribute6;
          a100(indx) := t(ddindx).attribute7;
          a101(indx) := t(ddindx).attribute8;
          a102(indx) := t(ddindx).attribute9;
          a103(indx) := t(ddindx).attribute10;
          a104(indx) := t(ddindx).attribute11;
          a105(indx) := t(ddindx).attribute12;
          a106(indx) := t(ddindx).attribute13;
          a107(indx) := t(ddindx).attribute14;
          a108(indx) := t(ddindx).attribute15;
          a109(indx) := t(ddindx).deduction_attribute_category;
          a110(indx) := t(ddindx).deduction_attribute1;
          a111(indx) := t(ddindx).deduction_attribute2;
          a112(indx) := t(ddindx).deduction_attribute3;
          a113(indx) := t(ddindx).deduction_attribute4;
          a114(indx) := t(ddindx).deduction_attribute5;
          a115(indx) := t(ddindx).deduction_attribute6;
          a116(indx) := t(ddindx).deduction_attribute7;
          a117(indx) := t(ddindx).deduction_attribute8;
          a118(indx) := t(ddindx).deduction_attribute9;
          a119(indx) := t(ddindx).deduction_attribute10;
          a120(indx) := t(ddindx).deduction_attribute11;
          a121(indx) := t(ddindx).deduction_attribute12;
          a122(indx) := t(ddindx).deduction_attribute13;
          a123(indx) := t(ddindx).deduction_attribute14;
          a124(indx) := t(ddindx).deduction_attribute15;
          a125(indx) := t(ddindx).org_id;
          a126(indx) := t(ddindx).legal_entity_id;
          a127(indx) := t(ddindx).write_off_flag;
          a128(indx) := t(ddindx).write_off_threshold_amount;
          a129(indx) := t(ddindx).under_write_off_threshold;
          a130(indx) := t(ddindx).customer_reason;
          a131(indx) := t(ddindx).ship_to_cust_account_id;
          a132(indx) := t(ddindx).amount_applied;
          a133(indx) := t(ddindx).applied_receipt_id;
          a134(indx) := t(ddindx).applied_receipt_number;
          a135(indx) := t(ddindx).wo_rec_trx_id;
          a136(indx) := t(ddindx).group_claim_id;
          a137(indx) := t(ddindx).appr_wf_item_key;
          a138(indx) := t(ddindx).cstl_wf_item_key;
          a139(indx) := t(ddindx).batch_type;
          a140(indx) := t(ddindx).tax_action;
          a141(indx) := t(ddindx).close_status_id;
          a142(indx) := t(ddindx).open_status_id;
          a143(indx) := t(ddindx).pre_auth_deduction_number;
          a144(indx) := t(ddindx).pre_auth_deduction_normalized;
          a145(indx) := t(ddindx).offer_id;
          a146(indx) := t(ddindx).settled_from;
          a147(indx) := t(ddindx).approval_in_prog;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  DATE
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  DATE
    , p7_a43  NUMBER
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  DATE
    , p7_a68  VARCHAR2
    , p7_a69  NUMBER
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  DATE
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  NUMBER
    , p7_a79  VARCHAR2
    , p7_a80  DATE
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  DATE
    , p7_a84  NUMBER
    , p7_a85  DATE
    , p7_a86  NUMBER
    , p7_a87  DATE
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  VARCHAR2
    , p7_a112  VARCHAR2
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  NUMBER
    , p7_a126  NUMBER
    , p7_a127  VARCHAR2
    , p7_a128  NUMBER
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  NUMBER
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  NUMBER
    , p7_a142  NUMBER
    , p7_a143  VARCHAR2
    , p7_a144  VARCHAR2
    , p7_a145  NUMBER
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , x_claim_id out nocopy  NUMBER
  )

  as
    ddp_claim ozf_claim_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claim.claim_id := p7_a0;
    ddp_claim.object_version_number := p7_a1;
    ddp_claim.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claim.last_updated_by := p7_a3;
    ddp_claim.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claim.created_by := p7_a5;
    ddp_claim.last_update_login := p7_a6;
    ddp_claim.request_id := p7_a7;
    ddp_claim.program_application_id := p7_a8;
    ddp_claim.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claim.program_id := p7_a10;
    ddp_claim.created_from := p7_a11;
    ddp_claim.batch_id := p7_a12;
    ddp_claim.claim_number := p7_a13;
    ddp_claim.claim_type_id := p7_a14;
    ddp_claim.claim_class := p7_a15;
    ddp_claim.claim_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_claim.due_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_claim.owner_id := p7_a18;
    ddp_claim.history_event := p7_a19;
    ddp_claim.history_event_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_claim.history_event_description := p7_a21;
    ddp_claim.split_from_claim_id := p7_a22;
    ddp_claim.duplicate_claim_id := p7_a23;
    ddp_claim.split_date := rosetta_g_miss_date_in_map(p7_a24);
    ddp_claim.root_claim_id := p7_a25;
    ddp_claim.amount := p7_a26;
    ddp_claim.amount_adjusted := p7_a27;
    ddp_claim.amount_remaining := p7_a28;
    ddp_claim.amount_settled := p7_a29;
    ddp_claim.acctd_amount := p7_a30;
    ddp_claim.acctd_amount_remaining := p7_a31;
    ddp_claim.acctd_amount_adjusted := p7_a32;
    ddp_claim.acctd_amount_settled := p7_a33;
    ddp_claim.tax_amount := p7_a34;
    ddp_claim.tax_code := p7_a35;
    ddp_claim.tax_calculation_flag := p7_a36;
    ddp_claim.currency_code := p7_a37;
    ddp_claim.exchange_rate_type := p7_a38;
    ddp_claim.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a39);
    ddp_claim.exchange_rate := p7_a40;
    ddp_claim.set_of_books_id := p7_a41;
    ddp_claim.original_claim_date := rosetta_g_miss_date_in_map(p7_a42);
    ddp_claim.source_object_id := p7_a43;
    ddp_claim.source_object_class := p7_a44;
    ddp_claim.source_object_type_id := p7_a45;
    ddp_claim.source_object_number := p7_a46;
    ddp_claim.cust_account_id := p7_a47;
    ddp_claim.cust_billto_acct_site_id := p7_a48;
    ddp_claim.cust_shipto_acct_site_id := p7_a49;
    ddp_claim.location_id := p7_a50;
    ddp_claim.pay_related_account_flag := p7_a51;
    ddp_claim.related_cust_account_id := p7_a52;
    ddp_claim.related_site_use_id := p7_a53;
    ddp_claim.relationship_type := p7_a54;
    ddp_claim.vendor_id := p7_a55;
    ddp_claim.vendor_site_id := p7_a56;
    ddp_claim.reason_type := p7_a57;
    ddp_claim.reason_code_id := p7_a58;
    ddp_claim.task_template_group_id := p7_a59;
    ddp_claim.status_code := p7_a60;
    ddp_claim.user_status_id := p7_a61;
    ddp_claim.sales_rep_id := p7_a62;
    ddp_claim.collector_id := p7_a63;
    ddp_claim.contact_id := p7_a64;
    ddp_claim.broker_id := p7_a65;
    ddp_claim.territory_id := p7_a66;
    ddp_claim.customer_ref_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_claim.customer_ref_number := p7_a68;
    ddp_claim.assigned_to := p7_a69;
    ddp_claim.receipt_id := p7_a70;
    ddp_claim.receipt_number := p7_a71;
    ddp_claim.doc_sequence_id := p7_a72;
    ddp_claim.doc_sequence_value := p7_a73;
    ddp_claim.gl_date := rosetta_g_miss_date_in_map(p7_a74);
    ddp_claim.payment_method := p7_a75;
    ddp_claim.voucher_id := p7_a76;
    ddp_claim.voucher_number := p7_a77;
    ddp_claim.payment_reference_id := p7_a78;
    ddp_claim.payment_reference_number := p7_a79;
    ddp_claim.payment_reference_date := rosetta_g_miss_date_in_map(p7_a80);
    ddp_claim.payment_status := p7_a81;
    ddp_claim.approved_flag := p7_a82;
    ddp_claim.approved_date := rosetta_g_miss_date_in_map(p7_a83);
    ddp_claim.approved_by := p7_a84;
    ddp_claim.settled_date := rosetta_g_miss_date_in_map(p7_a85);
    ddp_claim.settled_by := p7_a86;
    ddp_claim.effective_date := rosetta_g_miss_date_in_map(p7_a87);
    ddp_claim.custom_setup_id := p7_a88;
    ddp_claim.task_id := p7_a89;
    ddp_claim.country_id := p7_a90;
    ddp_claim.order_type_id := p7_a91;
    ddp_claim.comments := p7_a92;
    ddp_claim.attribute_category := p7_a93;
    ddp_claim.attribute1 := p7_a94;
    ddp_claim.attribute2 := p7_a95;
    ddp_claim.attribute3 := p7_a96;
    ddp_claim.attribute4 := p7_a97;
    ddp_claim.attribute5 := p7_a98;
    ddp_claim.attribute6 := p7_a99;
    ddp_claim.attribute7 := p7_a100;
    ddp_claim.attribute8 := p7_a101;
    ddp_claim.attribute9 := p7_a102;
    ddp_claim.attribute10 := p7_a103;
    ddp_claim.attribute11 := p7_a104;
    ddp_claim.attribute12 := p7_a105;
    ddp_claim.attribute13 := p7_a106;
    ddp_claim.attribute14 := p7_a107;
    ddp_claim.attribute15 := p7_a108;
    ddp_claim.deduction_attribute_category := p7_a109;
    ddp_claim.deduction_attribute1 := p7_a110;
    ddp_claim.deduction_attribute2 := p7_a111;
    ddp_claim.deduction_attribute3 := p7_a112;
    ddp_claim.deduction_attribute4 := p7_a113;
    ddp_claim.deduction_attribute5 := p7_a114;
    ddp_claim.deduction_attribute6 := p7_a115;
    ddp_claim.deduction_attribute7 := p7_a116;
    ddp_claim.deduction_attribute8 := p7_a117;
    ddp_claim.deduction_attribute9 := p7_a118;
    ddp_claim.deduction_attribute10 := p7_a119;
    ddp_claim.deduction_attribute11 := p7_a120;
    ddp_claim.deduction_attribute12 := p7_a121;
    ddp_claim.deduction_attribute13 := p7_a122;
    ddp_claim.deduction_attribute14 := p7_a123;
    ddp_claim.deduction_attribute15 := p7_a124;
    ddp_claim.org_id := p7_a125;
    ddp_claim.legal_entity_id := p7_a126;
    ddp_claim.write_off_flag := p7_a127;
    ddp_claim.write_off_threshold_amount := p7_a128;
    ddp_claim.under_write_off_threshold := p7_a129;
    ddp_claim.customer_reason := p7_a130;
    ddp_claim.ship_to_cust_account_id := p7_a131;
    ddp_claim.amount_applied := p7_a132;
    ddp_claim.applied_receipt_id := p7_a133;
    ddp_claim.applied_receipt_number := p7_a134;
    ddp_claim.wo_rec_trx_id := p7_a135;
    ddp_claim.group_claim_id := p7_a136;
    ddp_claim.appr_wf_item_key := p7_a137;
    ddp_claim.cstl_wf_item_key := p7_a138;
    ddp_claim.batch_type := p7_a139;
    ddp_claim.tax_action := p7_a140;
    ddp_claim.close_status_id := p7_a141;
    ddp_claim.open_status_id := p7_a142;
    ddp_claim.pre_auth_deduction_number := p7_a143;
    ddp_claim.pre_auth_deduction_normalized := p7_a144;
    ddp_claim.offer_id := p7_a145;
    ddp_claim.settled_from := p7_a146;
    ddp_claim.approval_in_prog := p7_a147;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.create_claim(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_claim,
      x_claim_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  DATE
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  DATE
    , p7_a43  NUMBER
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  DATE
    , p7_a68  VARCHAR2
    , p7_a69  NUMBER
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  DATE
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  NUMBER
    , p7_a79  VARCHAR2
    , p7_a80  DATE
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  DATE
    , p7_a84  NUMBER
    , p7_a85  DATE
    , p7_a86  NUMBER
    , p7_a87  DATE
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  VARCHAR2
    , p7_a112  VARCHAR2
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  NUMBER
    , p7_a126  NUMBER
    , p7_a127  VARCHAR2
    , p7_a128  NUMBER
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  NUMBER
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  NUMBER
    , p7_a142  NUMBER
    , p7_a143  VARCHAR2
    , p7_a144  VARCHAR2
    , p7_a145  NUMBER
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p_event  VARCHAR2
    , p_mode  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_claim ozf_claim_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claim.claim_id := p7_a0;
    ddp_claim.object_version_number := p7_a1;
    ddp_claim.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claim.last_updated_by := p7_a3;
    ddp_claim.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claim.created_by := p7_a5;
    ddp_claim.last_update_login := p7_a6;
    ddp_claim.request_id := p7_a7;
    ddp_claim.program_application_id := p7_a8;
    ddp_claim.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claim.program_id := p7_a10;
    ddp_claim.created_from := p7_a11;
    ddp_claim.batch_id := p7_a12;
    ddp_claim.claim_number := p7_a13;
    ddp_claim.claim_type_id := p7_a14;
    ddp_claim.claim_class := p7_a15;
    ddp_claim.claim_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_claim.due_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_claim.owner_id := p7_a18;
    ddp_claim.history_event := p7_a19;
    ddp_claim.history_event_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_claim.history_event_description := p7_a21;
    ddp_claim.split_from_claim_id := p7_a22;
    ddp_claim.duplicate_claim_id := p7_a23;
    ddp_claim.split_date := rosetta_g_miss_date_in_map(p7_a24);
    ddp_claim.root_claim_id := p7_a25;
    ddp_claim.amount := p7_a26;
    ddp_claim.amount_adjusted := p7_a27;
    ddp_claim.amount_remaining := p7_a28;
    ddp_claim.amount_settled := p7_a29;
    ddp_claim.acctd_amount := p7_a30;
    ddp_claim.acctd_amount_remaining := p7_a31;
    ddp_claim.acctd_amount_adjusted := p7_a32;
    ddp_claim.acctd_amount_settled := p7_a33;
    ddp_claim.tax_amount := p7_a34;
    ddp_claim.tax_code := p7_a35;
    ddp_claim.tax_calculation_flag := p7_a36;
    ddp_claim.currency_code := p7_a37;
    ddp_claim.exchange_rate_type := p7_a38;
    ddp_claim.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a39);
    ddp_claim.exchange_rate := p7_a40;
    ddp_claim.set_of_books_id := p7_a41;
    ddp_claim.original_claim_date := rosetta_g_miss_date_in_map(p7_a42);
    ddp_claim.source_object_id := p7_a43;
    ddp_claim.source_object_class := p7_a44;
    ddp_claim.source_object_type_id := p7_a45;
    ddp_claim.source_object_number := p7_a46;
    ddp_claim.cust_account_id := p7_a47;
    ddp_claim.cust_billto_acct_site_id := p7_a48;
    ddp_claim.cust_shipto_acct_site_id := p7_a49;
    ddp_claim.location_id := p7_a50;
    ddp_claim.pay_related_account_flag := p7_a51;
    ddp_claim.related_cust_account_id := p7_a52;
    ddp_claim.related_site_use_id := p7_a53;
    ddp_claim.relationship_type := p7_a54;
    ddp_claim.vendor_id := p7_a55;
    ddp_claim.vendor_site_id := p7_a56;
    ddp_claim.reason_type := p7_a57;
    ddp_claim.reason_code_id := p7_a58;
    ddp_claim.task_template_group_id := p7_a59;
    ddp_claim.status_code := p7_a60;
    ddp_claim.user_status_id := p7_a61;
    ddp_claim.sales_rep_id := p7_a62;
    ddp_claim.collector_id := p7_a63;
    ddp_claim.contact_id := p7_a64;
    ddp_claim.broker_id := p7_a65;
    ddp_claim.territory_id := p7_a66;
    ddp_claim.customer_ref_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_claim.customer_ref_number := p7_a68;
    ddp_claim.assigned_to := p7_a69;
    ddp_claim.receipt_id := p7_a70;
    ddp_claim.receipt_number := p7_a71;
    ddp_claim.doc_sequence_id := p7_a72;
    ddp_claim.doc_sequence_value := p7_a73;
    ddp_claim.gl_date := rosetta_g_miss_date_in_map(p7_a74);
    ddp_claim.payment_method := p7_a75;
    ddp_claim.voucher_id := p7_a76;
    ddp_claim.voucher_number := p7_a77;
    ddp_claim.payment_reference_id := p7_a78;
    ddp_claim.payment_reference_number := p7_a79;
    ddp_claim.payment_reference_date := rosetta_g_miss_date_in_map(p7_a80);
    ddp_claim.payment_status := p7_a81;
    ddp_claim.approved_flag := p7_a82;
    ddp_claim.approved_date := rosetta_g_miss_date_in_map(p7_a83);
    ddp_claim.approved_by := p7_a84;
    ddp_claim.settled_date := rosetta_g_miss_date_in_map(p7_a85);
    ddp_claim.settled_by := p7_a86;
    ddp_claim.effective_date := rosetta_g_miss_date_in_map(p7_a87);
    ddp_claim.custom_setup_id := p7_a88;
    ddp_claim.task_id := p7_a89;
    ddp_claim.country_id := p7_a90;
    ddp_claim.order_type_id := p7_a91;
    ddp_claim.comments := p7_a92;
    ddp_claim.attribute_category := p7_a93;
    ddp_claim.attribute1 := p7_a94;
    ddp_claim.attribute2 := p7_a95;
    ddp_claim.attribute3 := p7_a96;
    ddp_claim.attribute4 := p7_a97;
    ddp_claim.attribute5 := p7_a98;
    ddp_claim.attribute6 := p7_a99;
    ddp_claim.attribute7 := p7_a100;
    ddp_claim.attribute8 := p7_a101;
    ddp_claim.attribute9 := p7_a102;
    ddp_claim.attribute10 := p7_a103;
    ddp_claim.attribute11 := p7_a104;
    ddp_claim.attribute12 := p7_a105;
    ddp_claim.attribute13 := p7_a106;
    ddp_claim.attribute14 := p7_a107;
    ddp_claim.attribute15 := p7_a108;
    ddp_claim.deduction_attribute_category := p7_a109;
    ddp_claim.deduction_attribute1 := p7_a110;
    ddp_claim.deduction_attribute2 := p7_a111;
    ddp_claim.deduction_attribute3 := p7_a112;
    ddp_claim.deduction_attribute4 := p7_a113;
    ddp_claim.deduction_attribute5 := p7_a114;
    ddp_claim.deduction_attribute6 := p7_a115;
    ddp_claim.deduction_attribute7 := p7_a116;
    ddp_claim.deduction_attribute8 := p7_a117;
    ddp_claim.deduction_attribute9 := p7_a118;
    ddp_claim.deduction_attribute10 := p7_a119;
    ddp_claim.deduction_attribute11 := p7_a120;
    ddp_claim.deduction_attribute12 := p7_a121;
    ddp_claim.deduction_attribute13 := p7_a122;
    ddp_claim.deduction_attribute14 := p7_a123;
    ddp_claim.deduction_attribute15 := p7_a124;
    ddp_claim.org_id := p7_a125;
    ddp_claim.legal_entity_id := p7_a126;
    ddp_claim.write_off_flag := p7_a127;
    ddp_claim.write_off_threshold_amount := p7_a128;
    ddp_claim.under_write_off_threshold := p7_a129;
    ddp_claim.customer_reason := p7_a130;
    ddp_claim.ship_to_cust_account_id := p7_a131;
    ddp_claim.amount_applied := p7_a132;
    ddp_claim.applied_receipt_id := p7_a133;
    ddp_claim.applied_receipt_number := p7_a134;
    ddp_claim.wo_rec_trx_id := p7_a135;
    ddp_claim.group_claim_id := p7_a136;
    ddp_claim.appr_wf_item_key := p7_a137;
    ddp_claim.cstl_wf_item_key := p7_a138;
    ddp_claim.batch_type := p7_a139;
    ddp_claim.tax_action := p7_a140;
    ddp_claim.close_status_id := p7_a141;
    ddp_claim.open_status_id := p7_a142;
    ddp_claim.pre_auth_deduction_number := p7_a143;
    ddp_claim.pre_auth_deduction_normalized := p7_a144;
    ddp_claim.offer_id := p7_a145;
    ddp_claim.settled_from := p7_a146;
    ddp_claim.approval_in_prog := p7_a147;




    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.update_claim(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_claim,
      p_event,
      p_mode,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure validate_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  DATE
    , p6_a17  DATE
    , p6_a18  NUMBER
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  VARCHAR2
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  DATE
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  DATE
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  DATE
    , p6_a43  NUMBER
    , p6_a44  VARCHAR2
    , p6_a45  NUMBER
    , p6_a46  VARCHAR2
    , p6_a47  NUMBER
    , p6_a48  NUMBER
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  VARCHAR2
    , p6_a55  NUMBER
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  NUMBER
    , p6_a59  NUMBER
    , p6_a60  VARCHAR2
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  DATE
    , p6_a68  VARCHAR2
    , p6_a69  NUMBER
    , p6_a70  NUMBER
    , p6_a71  VARCHAR2
    , p6_a72  NUMBER
    , p6_a73  NUMBER
    , p6_a74  DATE
    , p6_a75  VARCHAR2
    , p6_a76  NUMBER
    , p6_a77  VARCHAR2
    , p6_a78  NUMBER
    , p6_a79  VARCHAR2
    , p6_a80  DATE
    , p6_a81  VARCHAR2
    , p6_a82  VARCHAR2
    , p6_a83  DATE
    , p6_a84  NUMBER
    , p6_a85  DATE
    , p6_a86  NUMBER
    , p6_a87  DATE
    , p6_a88  NUMBER
    , p6_a89  NUMBER
    , p6_a90  NUMBER
    , p6_a91  NUMBER
    , p6_a92  VARCHAR2
    , p6_a93  VARCHAR2
    , p6_a94  VARCHAR2
    , p6_a95  VARCHAR2
    , p6_a96  VARCHAR2
    , p6_a97  VARCHAR2
    , p6_a98  VARCHAR2
    , p6_a99  VARCHAR2
    , p6_a100  VARCHAR2
    , p6_a101  VARCHAR2
    , p6_a102  VARCHAR2
    , p6_a103  VARCHAR2
    , p6_a104  VARCHAR2
    , p6_a105  VARCHAR2
    , p6_a106  VARCHAR2
    , p6_a107  VARCHAR2
    , p6_a108  VARCHAR2
    , p6_a109  VARCHAR2
    , p6_a110  VARCHAR2
    , p6_a111  VARCHAR2
    , p6_a112  VARCHAR2
    , p6_a113  VARCHAR2
    , p6_a114  VARCHAR2
    , p6_a115  VARCHAR2
    , p6_a116  VARCHAR2
    , p6_a117  VARCHAR2
    , p6_a118  VARCHAR2
    , p6_a119  VARCHAR2
    , p6_a120  VARCHAR2
    , p6_a121  VARCHAR2
    , p6_a122  VARCHAR2
    , p6_a123  VARCHAR2
    , p6_a124  VARCHAR2
    , p6_a125  NUMBER
    , p6_a126  NUMBER
    , p6_a127  VARCHAR2
    , p6_a128  NUMBER
    , p6_a129  VARCHAR2
    , p6_a130  VARCHAR2
    , p6_a131  NUMBER
    , p6_a132  NUMBER
    , p6_a133  NUMBER
    , p6_a134  VARCHAR2
    , p6_a135  NUMBER
    , p6_a136  NUMBER
    , p6_a137  VARCHAR2
    , p6_a138  VARCHAR2
    , p6_a139  VARCHAR2
    , p6_a140  VARCHAR2
    , p6_a141  NUMBER
    , p6_a142  NUMBER
    , p6_a143  VARCHAR2
    , p6_a144  VARCHAR2
    , p6_a145  NUMBER
    , p6_a146  VARCHAR2
    , p6_a147  VARCHAR2
  )

  as
    ddp_claim ozf_claim_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_claim.claim_id := p6_a0;
    ddp_claim.object_version_number := p6_a1;
    ddp_claim.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_claim.last_updated_by := p6_a3;
    ddp_claim.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_claim.created_by := p6_a5;
    ddp_claim.last_update_login := p6_a6;
    ddp_claim.request_id := p6_a7;
    ddp_claim.program_application_id := p6_a8;
    ddp_claim.program_update_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_claim.program_id := p6_a10;
    ddp_claim.created_from := p6_a11;
    ddp_claim.batch_id := p6_a12;
    ddp_claim.claim_number := p6_a13;
    ddp_claim.claim_type_id := p6_a14;
    ddp_claim.claim_class := p6_a15;
    ddp_claim.claim_date := rosetta_g_miss_date_in_map(p6_a16);
    ddp_claim.due_date := rosetta_g_miss_date_in_map(p6_a17);
    ddp_claim.owner_id := p6_a18;
    ddp_claim.history_event := p6_a19;
    ddp_claim.history_event_date := rosetta_g_miss_date_in_map(p6_a20);
    ddp_claim.history_event_description := p6_a21;
    ddp_claim.split_from_claim_id := p6_a22;
    ddp_claim.duplicate_claim_id := p6_a23;
    ddp_claim.split_date := rosetta_g_miss_date_in_map(p6_a24);
    ddp_claim.root_claim_id := p6_a25;
    ddp_claim.amount := p6_a26;
    ddp_claim.amount_adjusted := p6_a27;
    ddp_claim.amount_remaining := p6_a28;
    ddp_claim.amount_settled := p6_a29;
    ddp_claim.acctd_amount := p6_a30;
    ddp_claim.acctd_amount_remaining := p6_a31;
    ddp_claim.acctd_amount_adjusted := p6_a32;
    ddp_claim.acctd_amount_settled := p6_a33;
    ddp_claim.tax_amount := p6_a34;
    ddp_claim.tax_code := p6_a35;
    ddp_claim.tax_calculation_flag := p6_a36;
    ddp_claim.currency_code := p6_a37;
    ddp_claim.exchange_rate_type := p6_a38;
    ddp_claim.exchange_rate_date := rosetta_g_miss_date_in_map(p6_a39);
    ddp_claim.exchange_rate := p6_a40;
    ddp_claim.set_of_books_id := p6_a41;
    ddp_claim.original_claim_date := rosetta_g_miss_date_in_map(p6_a42);
    ddp_claim.source_object_id := p6_a43;
    ddp_claim.source_object_class := p6_a44;
    ddp_claim.source_object_type_id := p6_a45;
    ddp_claim.source_object_number := p6_a46;
    ddp_claim.cust_account_id := p6_a47;
    ddp_claim.cust_billto_acct_site_id := p6_a48;
    ddp_claim.cust_shipto_acct_site_id := p6_a49;
    ddp_claim.location_id := p6_a50;
    ddp_claim.pay_related_account_flag := p6_a51;
    ddp_claim.related_cust_account_id := p6_a52;
    ddp_claim.related_site_use_id := p6_a53;
    ddp_claim.relationship_type := p6_a54;
    ddp_claim.vendor_id := p6_a55;
    ddp_claim.vendor_site_id := p6_a56;
    ddp_claim.reason_type := p6_a57;
    ddp_claim.reason_code_id := p6_a58;
    ddp_claim.task_template_group_id := p6_a59;
    ddp_claim.status_code := p6_a60;
    ddp_claim.user_status_id := p6_a61;
    ddp_claim.sales_rep_id := p6_a62;
    ddp_claim.collector_id := p6_a63;
    ddp_claim.contact_id := p6_a64;
    ddp_claim.broker_id := p6_a65;
    ddp_claim.territory_id := p6_a66;
    ddp_claim.customer_ref_date := rosetta_g_miss_date_in_map(p6_a67);
    ddp_claim.customer_ref_number := p6_a68;
    ddp_claim.assigned_to := p6_a69;
    ddp_claim.receipt_id := p6_a70;
    ddp_claim.receipt_number := p6_a71;
    ddp_claim.doc_sequence_id := p6_a72;
    ddp_claim.doc_sequence_value := p6_a73;
    ddp_claim.gl_date := rosetta_g_miss_date_in_map(p6_a74);
    ddp_claim.payment_method := p6_a75;
    ddp_claim.voucher_id := p6_a76;
    ddp_claim.voucher_number := p6_a77;
    ddp_claim.payment_reference_id := p6_a78;
    ddp_claim.payment_reference_number := p6_a79;
    ddp_claim.payment_reference_date := rosetta_g_miss_date_in_map(p6_a80);
    ddp_claim.payment_status := p6_a81;
    ddp_claim.approved_flag := p6_a82;
    ddp_claim.approved_date := rosetta_g_miss_date_in_map(p6_a83);
    ddp_claim.approved_by := p6_a84;
    ddp_claim.settled_date := rosetta_g_miss_date_in_map(p6_a85);
    ddp_claim.settled_by := p6_a86;
    ddp_claim.effective_date := rosetta_g_miss_date_in_map(p6_a87);
    ddp_claim.custom_setup_id := p6_a88;
    ddp_claim.task_id := p6_a89;
    ddp_claim.country_id := p6_a90;
    ddp_claim.order_type_id := p6_a91;
    ddp_claim.comments := p6_a92;
    ddp_claim.attribute_category := p6_a93;
    ddp_claim.attribute1 := p6_a94;
    ddp_claim.attribute2 := p6_a95;
    ddp_claim.attribute3 := p6_a96;
    ddp_claim.attribute4 := p6_a97;
    ddp_claim.attribute5 := p6_a98;
    ddp_claim.attribute6 := p6_a99;
    ddp_claim.attribute7 := p6_a100;
    ddp_claim.attribute8 := p6_a101;
    ddp_claim.attribute9 := p6_a102;
    ddp_claim.attribute10 := p6_a103;
    ddp_claim.attribute11 := p6_a104;
    ddp_claim.attribute12 := p6_a105;
    ddp_claim.attribute13 := p6_a106;
    ddp_claim.attribute14 := p6_a107;
    ddp_claim.attribute15 := p6_a108;
    ddp_claim.deduction_attribute_category := p6_a109;
    ddp_claim.deduction_attribute1 := p6_a110;
    ddp_claim.deduction_attribute2 := p6_a111;
    ddp_claim.deduction_attribute3 := p6_a112;
    ddp_claim.deduction_attribute4 := p6_a113;
    ddp_claim.deduction_attribute5 := p6_a114;
    ddp_claim.deduction_attribute6 := p6_a115;
    ddp_claim.deduction_attribute7 := p6_a116;
    ddp_claim.deduction_attribute8 := p6_a117;
    ddp_claim.deduction_attribute9 := p6_a118;
    ddp_claim.deduction_attribute10 := p6_a119;
    ddp_claim.deduction_attribute11 := p6_a120;
    ddp_claim.deduction_attribute12 := p6_a121;
    ddp_claim.deduction_attribute13 := p6_a122;
    ddp_claim.deduction_attribute14 := p6_a123;
    ddp_claim.deduction_attribute15 := p6_a124;
    ddp_claim.org_id := p6_a125;
    ddp_claim.legal_entity_id := p6_a126;
    ddp_claim.write_off_flag := p6_a127;
    ddp_claim.write_off_threshold_amount := p6_a128;
    ddp_claim.under_write_off_threshold := p6_a129;
    ddp_claim.customer_reason := p6_a130;
    ddp_claim.ship_to_cust_account_id := p6_a131;
    ddp_claim.amount_applied := p6_a132;
    ddp_claim.applied_receipt_id := p6_a133;
    ddp_claim.applied_receipt_number := p6_a134;
    ddp_claim.wo_rec_trx_id := p6_a135;
    ddp_claim.group_claim_id := p6_a136;
    ddp_claim.appr_wf_item_key := p6_a137;
    ddp_claim.cstl_wf_item_key := p6_a138;
    ddp_claim.batch_type := p6_a139;
    ddp_claim.tax_action := p6_a140;
    ddp_claim.close_status_id := p6_a141;
    ddp_claim.open_status_id := p6_a142;
    ddp_claim.pre_auth_deduction_number := p6_a143;
    ddp_claim.pre_auth_deduction_normalized := p6_a144;
    ddp_claim.offer_id := p6_a145;
    ddp_claim.settled_from := p6_a146;
    ddp_claim.approval_in_prog := p6_a147;

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.validate_claim(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claim);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_claim_common_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  DATE
    , p6_a17  DATE
    , p6_a18  NUMBER
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  VARCHAR2
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  DATE
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  DATE
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  DATE
    , p6_a43  NUMBER
    , p6_a44  VARCHAR2
    , p6_a45  NUMBER
    , p6_a46  VARCHAR2
    , p6_a47  NUMBER
    , p6_a48  NUMBER
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  VARCHAR2
    , p6_a55  NUMBER
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  NUMBER
    , p6_a59  NUMBER
    , p6_a60  VARCHAR2
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  DATE
    , p6_a68  VARCHAR2
    , p6_a69  NUMBER
    , p6_a70  NUMBER
    , p6_a71  VARCHAR2
    , p6_a72  NUMBER
    , p6_a73  NUMBER
    , p6_a74  DATE
    , p6_a75  VARCHAR2
    , p6_a76  NUMBER
    , p6_a77  VARCHAR2
    , p6_a78  NUMBER
    , p6_a79  VARCHAR2
    , p6_a80  DATE
    , p6_a81  VARCHAR2
    , p6_a82  VARCHAR2
    , p6_a83  DATE
    , p6_a84  NUMBER
    , p6_a85  DATE
    , p6_a86  NUMBER
    , p6_a87  DATE
    , p6_a88  NUMBER
    , p6_a89  NUMBER
    , p6_a90  NUMBER
    , p6_a91  NUMBER
    , p6_a92  VARCHAR2
    , p6_a93  VARCHAR2
    , p6_a94  VARCHAR2
    , p6_a95  VARCHAR2
    , p6_a96  VARCHAR2
    , p6_a97  VARCHAR2
    , p6_a98  VARCHAR2
    , p6_a99  VARCHAR2
    , p6_a100  VARCHAR2
    , p6_a101  VARCHAR2
    , p6_a102  VARCHAR2
    , p6_a103  VARCHAR2
    , p6_a104  VARCHAR2
    , p6_a105  VARCHAR2
    , p6_a106  VARCHAR2
    , p6_a107  VARCHAR2
    , p6_a108  VARCHAR2
    , p6_a109  VARCHAR2
    , p6_a110  VARCHAR2
    , p6_a111  VARCHAR2
    , p6_a112  VARCHAR2
    , p6_a113  VARCHAR2
    , p6_a114  VARCHAR2
    , p6_a115  VARCHAR2
    , p6_a116  VARCHAR2
    , p6_a117  VARCHAR2
    , p6_a118  VARCHAR2
    , p6_a119  VARCHAR2
    , p6_a120  VARCHAR2
    , p6_a121  VARCHAR2
    , p6_a122  VARCHAR2
    , p6_a123  VARCHAR2
    , p6_a124  VARCHAR2
    , p6_a125  NUMBER
    , p6_a126  NUMBER
    , p6_a127  VARCHAR2
    , p6_a128  NUMBER
    , p6_a129  VARCHAR2
    , p6_a130  VARCHAR2
    , p6_a131  NUMBER
    , p6_a132  NUMBER
    , p6_a133  NUMBER
    , p6_a134  VARCHAR2
    , p6_a135  NUMBER
    , p6_a136  NUMBER
    , p6_a137  VARCHAR2
    , p6_a138  VARCHAR2
    , p6_a139  VARCHAR2
    , p6_a140  VARCHAR2
    , p6_a141  NUMBER
    , p6_a142  NUMBER
    , p6_a143  VARCHAR2
    , p6_a144  VARCHAR2
    , p6_a145  NUMBER
    , p6_a146  VARCHAR2
    , p6_a147  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  DATE
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  NUMBER
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  DATE
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  NUMBER
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  NUMBER
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  NUMBER
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  DATE
    , p7_a40 out nocopy  NUMBER
    , p7_a41 out nocopy  NUMBER
    , p7_a42 out nocopy  DATE
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  NUMBER
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  NUMBER
    , p7_a48 out nocopy  NUMBER
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  NUMBER
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  NUMBER
    , p7_a53 out nocopy  NUMBER
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  NUMBER
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  NUMBER
    , p7_a59 out nocopy  NUMBER
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  NUMBER
    , p7_a63 out nocopy  NUMBER
    , p7_a64 out nocopy  NUMBER
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  DATE
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  NUMBER
    , p7_a70 out nocopy  NUMBER
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  NUMBER
    , p7_a73 out nocopy  NUMBER
    , p7_a74 out nocopy  DATE
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  NUMBER
    , p7_a77 out nocopy  VARCHAR2
    , p7_a78 out nocopy  NUMBER
    , p7_a79 out nocopy  VARCHAR2
    , p7_a80 out nocopy  DATE
    , p7_a81 out nocopy  VARCHAR2
    , p7_a82 out nocopy  VARCHAR2
    , p7_a83 out nocopy  DATE
    , p7_a84 out nocopy  NUMBER
    , p7_a85 out nocopy  DATE
    , p7_a86 out nocopy  NUMBER
    , p7_a87 out nocopy  DATE
    , p7_a88 out nocopy  NUMBER
    , p7_a89 out nocopy  NUMBER
    , p7_a90 out nocopy  NUMBER
    , p7_a91 out nocopy  NUMBER
    , p7_a92 out nocopy  VARCHAR2
    , p7_a93 out nocopy  VARCHAR2
    , p7_a94 out nocopy  VARCHAR2
    , p7_a95 out nocopy  VARCHAR2
    , p7_a96 out nocopy  VARCHAR2
    , p7_a97 out nocopy  VARCHAR2
    , p7_a98 out nocopy  VARCHAR2
    , p7_a99 out nocopy  VARCHAR2
    , p7_a100 out nocopy  VARCHAR2
    , p7_a101 out nocopy  VARCHAR2
    , p7_a102 out nocopy  VARCHAR2
    , p7_a103 out nocopy  VARCHAR2
    , p7_a104 out nocopy  VARCHAR2
    , p7_a105 out nocopy  VARCHAR2
    , p7_a106 out nocopy  VARCHAR2
    , p7_a107 out nocopy  VARCHAR2
    , p7_a108 out nocopy  VARCHAR2
    , p7_a109 out nocopy  VARCHAR2
    , p7_a110 out nocopy  VARCHAR2
    , p7_a111 out nocopy  VARCHAR2
    , p7_a112 out nocopy  VARCHAR2
    , p7_a113 out nocopy  VARCHAR2
    , p7_a114 out nocopy  VARCHAR2
    , p7_a115 out nocopy  VARCHAR2
    , p7_a116 out nocopy  VARCHAR2
    , p7_a117 out nocopy  VARCHAR2
    , p7_a118 out nocopy  VARCHAR2
    , p7_a119 out nocopy  VARCHAR2
    , p7_a120 out nocopy  VARCHAR2
    , p7_a121 out nocopy  VARCHAR2
    , p7_a122 out nocopy  VARCHAR2
    , p7_a123 out nocopy  VARCHAR2
    , p7_a124 out nocopy  VARCHAR2
    , p7_a125 out nocopy  NUMBER
    , p7_a126 out nocopy  NUMBER
    , p7_a127 out nocopy  VARCHAR2
    , p7_a128 out nocopy  NUMBER
    , p7_a129 out nocopy  VARCHAR2
    , p7_a130 out nocopy  VARCHAR2
    , p7_a131 out nocopy  NUMBER
    , p7_a132 out nocopy  NUMBER
    , p7_a133 out nocopy  NUMBER
    , p7_a134 out nocopy  VARCHAR2
    , p7_a135 out nocopy  NUMBER
    , p7_a136 out nocopy  NUMBER
    , p7_a137 out nocopy  VARCHAR2
    , p7_a138 out nocopy  VARCHAR2
    , p7_a139 out nocopy  VARCHAR2
    , p7_a140 out nocopy  VARCHAR2
    , p7_a141 out nocopy  NUMBER
    , p7_a142 out nocopy  NUMBER
    , p7_a143 out nocopy  VARCHAR2
    , p7_a144 out nocopy  VARCHAR2
    , p7_a145 out nocopy  NUMBER
    , p7_a146 out nocopy  VARCHAR2
    , p7_a147 out nocopy  VARCHAR2
    , p_mode  VARCHAR2
  )

  as
    ddp_claim ozf_claim_pvt.claim_rec_type;
    ddx_claim ozf_claim_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_claim.claim_id := p6_a0;
    ddp_claim.object_version_number := p6_a1;
    ddp_claim.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_claim.last_updated_by := p6_a3;
    ddp_claim.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_claim.created_by := p6_a5;
    ddp_claim.last_update_login := p6_a6;
    ddp_claim.request_id := p6_a7;
    ddp_claim.program_application_id := p6_a8;
    ddp_claim.program_update_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_claim.program_id := p6_a10;
    ddp_claim.created_from := p6_a11;
    ddp_claim.batch_id := p6_a12;
    ddp_claim.claim_number := p6_a13;
    ddp_claim.claim_type_id := p6_a14;
    ddp_claim.claim_class := p6_a15;
    ddp_claim.claim_date := rosetta_g_miss_date_in_map(p6_a16);
    ddp_claim.due_date := rosetta_g_miss_date_in_map(p6_a17);
    ddp_claim.owner_id := p6_a18;
    ddp_claim.history_event := p6_a19;
    ddp_claim.history_event_date := rosetta_g_miss_date_in_map(p6_a20);
    ddp_claim.history_event_description := p6_a21;
    ddp_claim.split_from_claim_id := p6_a22;
    ddp_claim.duplicate_claim_id := p6_a23;
    ddp_claim.split_date := rosetta_g_miss_date_in_map(p6_a24);
    ddp_claim.root_claim_id := p6_a25;
    ddp_claim.amount := p6_a26;
    ddp_claim.amount_adjusted := p6_a27;
    ddp_claim.amount_remaining := p6_a28;
    ddp_claim.amount_settled := p6_a29;
    ddp_claim.acctd_amount := p6_a30;
    ddp_claim.acctd_amount_remaining := p6_a31;
    ddp_claim.acctd_amount_adjusted := p6_a32;
    ddp_claim.acctd_amount_settled := p6_a33;
    ddp_claim.tax_amount := p6_a34;
    ddp_claim.tax_code := p6_a35;
    ddp_claim.tax_calculation_flag := p6_a36;
    ddp_claim.currency_code := p6_a37;
    ddp_claim.exchange_rate_type := p6_a38;
    ddp_claim.exchange_rate_date := rosetta_g_miss_date_in_map(p6_a39);
    ddp_claim.exchange_rate := p6_a40;
    ddp_claim.set_of_books_id := p6_a41;
    ddp_claim.original_claim_date := rosetta_g_miss_date_in_map(p6_a42);
    ddp_claim.source_object_id := p6_a43;
    ddp_claim.source_object_class := p6_a44;
    ddp_claim.source_object_type_id := p6_a45;
    ddp_claim.source_object_number := p6_a46;
    ddp_claim.cust_account_id := p6_a47;
    ddp_claim.cust_billto_acct_site_id := p6_a48;
    ddp_claim.cust_shipto_acct_site_id := p6_a49;
    ddp_claim.location_id := p6_a50;
    ddp_claim.pay_related_account_flag := p6_a51;
    ddp_claim.related_cust_account_id := p6_a52;
    ddp_claim.related_site_use_id := p6_a53;
    ddp_claim.relationship_type := p6_a54;
    ddp_claim.vendor_id := p6_a55;
    ddp_claim.vendor_site_id := p6_a56;
    ddp_claim.reason_type := p6_a57;
    ddp_claim.reason_code_id := p6_a58;
    ddp_claim.task_template_group_id := p6_a59;
    ddp_claim.status_code := p6_a60;
    ddp_claim.user_status_id := p6_a61;
    ddp_claim.sales_rep_id := p6_a62;
    ddp_claim.collector_id := p6_a63;
    ddp_claim.contact_id := p6_a64;
    ddp_claim.broker_id := p6_a65;
    ddp_claim.territory_id := p6_a66;
    ddp_claim.customer_ref_date := rosetta_g_miss_date_in_map(p6_a67);
    ddp_claim.customer_ref_number := p6_a68;
    ddp_claim.assigned_to := p6_a69;
    ddp_claim.receipt_id := p6_a70;
    ddp_claim.receipt_number := p6_a71;
    ddp_claim.doc_sequence_id := p6_a72;
    ddp_claim.doc_sequence_value := p6_a73;
    ddp_claim.gl_date := rosetta_g_miss_date_in_map(p6_a74);
    ddp_claim.payment_method := p6_a75;
    ddp_claim.voucher_id := p6_a76;
    ddp_claim.voucher_number := p6_a77;
    ddp_claim.payment_reference_id := p6_a78;
    ddp_claim.payment_reference_number := p6_a79;
    ddp_claim.payment_reference_date := rosetta_g_miss_date_in_map(p6_a80);
    ddp_claim.payment_status := p6_a81;
    ddp_claim.approved_flag := p6_a82;
    ddp_claim.approved_date := rosetta_g_miss_date_in_map(p6_a83);
    ddp_claim.approved_by := p6_a84;
    ddp_claim.settled_date := rosetta_g_miss_date_in_map(p6_a85);
    ddp_claim.settled_by := p6_a86;
    ddp_claim.effective_date := rosetta_g_miss_date_in_map(p6_a87);
    ddp_claim.custom_setup_id := p6_a88;
    ddp_claim.task_id := p6_a89;
    ddp_claim.country_id := p6_a90;
    ddp_claim.order_type_id := p6_a91;
    ddp_claim.comments := p6_a92;
    ddp_claim.attribute_category := p6_a93;
    ddp_claim.attribute1 := p6_a94;
    ddp_claim.attribute2 := p6_a95;
    ddp_claim.attribute3 := p6_a96;
    ddp_claim.attribute4 := p6_a97;
    ddp_claim.attribute5 := p6_a98;
    ddp_claim.attribute6 := p6_a99;
    ddp_claim.attribute7 := p6_a100;
    ddp_claim.attribute8 := p6_a101;
    ddp_claim.attribute9 := p6_a102;
    ddp_claim.attribute10 := p6_a103;
    ddp_claim.attribute11 := p6_a104;
    ddp_claim.attribute12 := p6_a105;
    ddp_claim.attribute13 := p6_a106;
    ddp_claim.attribute14 := p6_a107;
    ddp_claim.attribute15 := p6_a108;
    ddp_claim.deduction_attribute_category := p6_a109;
    ddp_claim.deduction_attribute1 := p6_a110;
    ddp_claim.deduction_attribute2 := p6_a111;
    ddp_claim.deduction_attribute3 := p6_a112;
    ddp_claim.deduction_attribute4 := p6_a113;
    ddp_claim.deduction_attribute5 := p6_a114;
    ddp_claim.deduction_attribute6 := p6_a115;
    ddp_claim.deduction_attribute7 := p6_a116;
    ddp_claim.deduction_attribute8 := p6_a117;
    ddp_claim.deduction_attribute9 := p6_a118;
    ddp_claim.deduction_attribute10 := p6_a119;
    ddp_claim.deduction_attribute11 := p6_a120;
    ddp_claim.deduction_attribute12 := p6_a121;
    ddp_claim.deduction_attribute13 := p6_a122;
    ddp_claim.deduction_attribute14 := p6_a123;
    ddp_claim.deduction_attribute15 := p6_a124;
    ddp_claim.org_id := p6_a125;
    ddp_claim.legal_entity_id := p6_a126;
    ddp_claim.write_off_flag := p6_a127;
    ddp_claim.write_off_threshold_amount := p6_a128;
    ddp_claim.under_write_off_threshold := p6_a129;
    ddp_claim.customer_reason := p6_a130;
    ddp_claim.ship_to_cust_account_id := p6_a131;
    ddp_claim.amount_applied := p6_a132;
    ddp_claim.applied_receipt_id := p6_a133;
    ddp_claim.applied_receipt_number := p6_a134;
    ddp_claim.wo_rec_trx_id := p6_a135;
    ddp_claim.group_claim_id := p6_a136;
    ddp_claim.appr_wf_item_key := p6_a137;
    ddp_claim.cstl_wf_item_key := p6_a138;
    ddp_claim.batch_type := p6_a139;
    ddp_claim.tax_action := p6_a140;
    ddp_claim.close_status_id := p6_a141;
    ddp_claim.open_status_id := p6_a142;
    ddp_claim.pre_auth_deduction_number := p6_a143;
    ddp_claim.pre_auth_deduction_normalized := p6_a144;
    ddp_claim.offer_id := p6_a145;
    ddp_claim.settled_from := p6_a146;
    ddp_claim.approval_in_prog := p6_a147;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.check_claim_common_element(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claim,
      ddx_claim,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_claim.claim_id;
    p7_a1 := ddx_claim.object_version_number;
    p7_a2 := ddx_claim.last_update_date;
    p7_a3 := ddx_claim.last_updated_by;
    p7_a4 := ddx_claim.creation_date;
    p7_a5 := ddx_claim.created_by;
    p7_a6 := ddx_claim.last_update_login;
    p7_a7 := ddx_claim.request_id;
    p7_a8 := ddx_claim.program_application_id;
    p7_a9 := ddx_claim.program_update_date;
    p7_a10 := ddx_claim.program_id;
    p7_a11 := ddx_claim.created_from;
    p7_a12 := ddx_claim.batch_id;
    p7_a13 := ddx_claim.claim_number;
    p7_a14 := ddx_claim.claim_type_id;
    p7_a15 := ddx_claim.claim_class;
    p7_a16 := ddx_claim.claim_date;
    p7_a17 := ddx_claim.due_date;
    p7_a18 := ddx_claim.owner_id;
    p7_a19 := ddx_claim.history_event;
    p7_a20 := ddx_claim.history_event_date;
    p7_a21 := ddx_claim.history_event_description;
    p7_a22 := ddx_claim.split_from_claim_id;
    p7_a23 := ddx_claim.duplicate_claim_id;
    p7_a24 := ddx_claim.split_date;
    p7_a25 := ddx_claim.root_claim_id;
    p7_a26 := ddx_claim.amount;
    p7_a27 := ddx_claim.amount_adjusted;
    p7_a28 := ddx_claim.amount_remaining;
    p7_a29 := ddx_claim.amount_settled;
    p7_a30 := ddx_claim.acctd_amount;
    p7_a31 := ddx_claim.acctd_amount_remaining;
    p7_a32 := ddx_claim.acctd_amount_adjusted;
    p7_a33 := ddx_claim.acctd_amount_settled;
    p7_a34 := ddx_claim.tax_amount;
    p7_a35 := ddx_claim.tax_code;
    p7_a36 := ddx_claim.tax_calculation_flag;
    p7_a37 := ddx_claim.currency_code;
    p7_a38 := ddx_claim.exchange_rate_type;
    p7_a39 := ddx_claim.exchange_rate_date;
    p7_a40 := ddx_claim.exchange_rate;
    p7_a41 := ddx_claim.set_of_books_id;
    p7_a42 := ddx_claim.original_claim_date;
    p7_a43 := ddx_claim.source_object_id;
    p7_a44 := ddx_claim.source_object_class;
    p7_a45 := ddx_claim.source_object_type_id;
    p7_a46 := ddx_claim.source_object_number;
    p7_a47 := ddx_claim.cust_account_id;
    p7_a48 := ddx_claim.cust_billto_acct_site_id;
    p7_a49 := ddx_claim.cust_shipto_acct_site_id;
    p7_a50 := ddx_claim.location_id;
    p7_a51 := ddx_claim.pay_related_account_flag;
    p7_a52 := ddx_claim.related_cust_account_id;
    p7_a53 := ddx_claim.related_site_use_id;
    p7_a54 := ddx_claim.relationship_type;
    p7_a55 := ddx_claim.vendor_id;
    p7_a56 := ddx_claim.vendor_site_id;
    p7_a57 := ddx_claim.reason_type;
    p7_a58 := ddx_claim.reason_code_id;
    p7_a59 := ddx_claim.task_template_group_id;
    p7_a60 := ddx_claim.status_code;
    p7_a61 := ddx_claim.user_status_id;
    p7_a62 := ddx_claim.sales_rep_id;
    p7_a63 := ddx_claim.collector_id;
    p7_a64 := ddx_claim.contact_id;
    p7_a65 := ddx_claim.broker_id;
    p7_a66 := ddx_claim.territory_id;
    p7_a67 := ddx_claim.customer_ref_date;
    p7_a68 := ddx_claim.customer_ref_number;
    p7_a69 := ddx_claim.assigned_to;
    p7_a70 := ddx_claim.receipt_id;
    p7_a71 := ddx_claim.receipt_number;
    p7_a72 := ddx_claim.doc_sequence_id;
    p7_a73 := ddx_claim.doc_sequence_value;
    p7_a74 := ddx_claim.gl_date;
    p7_a75 := ddx_claim.payment_method;
    p7_a76 := ddx_claim.voucher_id;
    p7_a77 := ddx_claim.voucher_number;
    p7_a78 := ddx_claim.payment_reference_id;
    p7_a79 := ddx_claim.payment_reference_number;
    p7_a80 := ddx_claim.payment_reference_date;
    p7_a81 := ddx_claim.payment_status;
    p7_a82 := ddx_claim.approved_flag;
    p7_a83 := ddx_claim.approved_date;
    p7_a84 := ddx_claim.approved_by;
    p7_a85 := ddx_claim.settled_date;
    p7_a86 := ddx_claim.settled_by;
    p7_a87 := ddx_claim.effective_date;
    p7_a88 := ddx_claim.custom_setup_id;
    p7_a89 := ddx_claim.task_id;
    p7_a90 := ddx_claim.country_id;
    p7_a91 := ddx_claim.order_type_id;
    p7_a92 := ddx_claim.comments;
    p7_a93 := ddx_claim.attribute_category;
    p7_a94 := ddx_claim.attribute1;
    p7_a95 := ddx_claim.attribute2;
    p7_a96 := ddx_claim.attribute3;
    p7_a97 := ddx_claim.attribute4;
    p7_a98 := ddx_claim.attribute5;
    p7_a99 := ddx_claim.attribute6;
    p7_a100 := ddx_claim.attribute7;
    p7_a101 := ddx_claim.attribute8;
    p7_a102 := ddx_claim.attribute9;
    p7_a103 := ddx_claim.attribute10;
    p7_a104 := ddx_claim.attribute11;
    p7_a105 := ddx_claim.attribute12;
    p7_a106 := ddx_claim.attribute13;
    p7_a107 := ddx_claim.attribute14;
    p7_a108 := ddx_claim.attribute15;
    p7_a109 := ddx_claim.deduction_attribute_category;
    p7_a110 := ddx_claim.deduction_attribute1;
    p7_a111 := ddx_claim.deduction_attribute2;
    p7_a112 := ddx_claim.deduction_attribute3;
    p7_a113 := ddx_claim.deduction_attribute4;
    p7_a114 := ddx_claim.deduction_attribute5;
    p7_a115 := ddx_claim.deduction_attribute6;
    p7_a116 := ddx_claim.deduction_attribute7;
    p7_a117 := ddx_claim.deduction_attribute8;
    p7_a118 := ddx_claim.deduction_attribute9;
    p7_a119 := ddx_claim.deduction_attribute10;
    p7_a120 := ddx_claim.deduction_attribute11;
    p7_a121 := ddx_claim.deduction_attribute12;
    p7_a122 := ddx_claim.deduction_attribute13;
    p7_a123 := ddx_claim.deduction_attribute14;
    p7_a124 := ddx_claim.deduction_attribute15;
    p7_a125 := ddx_claim.org_id;
    p7_a126 := ddx_claim.legal_entity_id;
    p7_a127 := ddx_claim.write_off_flag;
    p7_a128 := ddx_claim.write_off_threshold_amount;
    p7_a129 := ddx_claim.under_write_off_threshold;
    p7_a130 := ddx_claim.customer_reason;
    p7_a131 := ddx_claim.ship_to_cust_account_id;
    p7_a132 := ddx_claim.amount_applied;
    p7_a133 := ddx_claim.applied_receipt_id;
    p7_a134 := ddx_claim.applied_receipt_number;
    p7_a135 := ddx_claim.wo_rec_trx_id;
    p7_a136 := ddx_claim.group_claim_id;
    p7_a137 := ddx_claim.appr_wf_item_key;
    p7_a138 := ddx_claim.cstl_wf_item_key;
    p7_a139 := ddx_claim.batch_type;
    p7_a140 := ddx_claim.tax_action;
    p7_a141 := ddx_claim.close_status_id;
    p7_a142 := ddx_claim.open_status_id;
    p7_a143 := ddx_claim.pre_auth_deduction_number;
    p7_a144 := ddx_claim.pre_auth_deduction_normalized;
    p7_a145 := ddx_claim.offer_id;
    p7_a146 := ddx_claim.settled_from;
    p7_a147 := ddx_claim.approval_in_prog;

  end;

  procedure check_claim_items(p_validation_mode  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  DATE
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  DATE
    , p1_a17  DATE
    , p1_a18  NUMBER
    , p1_a19  VARCHAR2
    , p1_a20  DATE
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  NUMBER
    , p1_a24  DATE
    , p1_a25  NUMBER
    , p1_a26  NUMBER
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  DATE
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  DATE
    , p1_a43  NUMBER
    , p1_a44  VARCHAR2
    , p1_a45  NUMBER
    , p1_a46  VARCHAR2
    , p1_a47  NUMBER
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  VARCHAR2
    , p1_a52  NUMBER
    , p1_a53  NUMBER
    , p1_a54  VARCHAR2
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  NUMBER
    , p1_a59  NUMBER
    , p1_a60  VARCHAR2
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  NUMBER
    , p1_a67  DATE
    , p1_a68  VARCHAR2
    , p1_a69  NUMBER
    , p1_a70  NUMBER
    , p1_a71  VARCHAR2
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  DATE
    , p1_a75  VARCHAR2
    , p1_a76  NUMBER
    , p1_a77  VARCHAR2
    , p1_a78  NUMBER
    , p1_a79  VARCHAR2
    , p1_a80  DATE
    , p1_a81  VARCHAR2
    , p1_a82  VARCHAR2
    , p1_a83  DATE
    , p1_a84  NUMBER
    , p1_a85  DATE
    , p1_a86  NUMBER
    , p1_a87  DATE
    , p1_a88  NUMBER
    , p1_a89  NUMBER
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  VARCHAR2
    , p1_a96  VARCHAR2
    , p1_a97  VARCHAR2
    , p1_a98  VARCHAR2
    , p1_a99  VARCHAR2
    , p1_a100  VARCHAR2
    , p1_a101  VARCHAR2
    , p1_a102  VARCHAR2
    , p1_a103  VARCHAR2
    , p1_a104  VARCHAR2
    , p1_a105  VARCHAR2
    , p1_a106  VARCHAR2
    , p1_a107  VARCHAR2
    , p1_a108  VARCHAR2
    , p1_a109  VARCHAR2
    , p1_a110  VARCHAR2
    , p1_a111  VARCHAR2
    , p1_a112  VARCHAR2
    , p1_a113  VARCHAR2
    , p1_a114  VARCHAR2
    , p1_a115  VARCHAR2
    , p1_a116  VARCHAR2
    , p1_a117  VARCHAR2
    , p1_a118  VARCHAR2
    , p1_a119  VARCHAR2
    , p1_a120  VARCHAR2
    , p1_a121  VARCHAR2
    , p1_a122  VARCHAR2
    , p1_a123  VARCHAR2
    , p1_a124  VARCHAR2
    , p1_a125  NUMBER
    , p1_a126  NUMBER
    , p1_a127  VARCHAR2
    , p1_a128  NUMBER
    , p1_a129  VARCHAR2
    , p1_a130  VARCHAR2
    , p1_a131  NUMBER
    , p1_a132  NUMBER
    , p1_a133  NUMBER
    , p1_a134  VARCHAR2
    , p1_a135  NUMBER
    , p1_a136  NUMBER
    , p1_a137  VARCHAR2
    , p1_a138  VARCHAR2
    , p1_a139  VARCHAR2
    , p1_a140  VARCHAR2
    , p1_a141  NUMBER
    , p1_a142  NUMBER
    , p1_a143  VARCHAR2
    , p1_a144  VARCHAR2
    , p1_a145  NUMBER
    , p1_a146  VARCHAR2
    , p1_a147  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_claim_rec ozf_claim_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_claim_rec.claim_id := p1_a0;
    ddp_claim_rec.object_version_number := p1_a1;
    ddp_claim_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_claim_rec.last_updated_by := p1_a3;
    ddp_claim_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_claim_rec.created_by := p1_a5;
    ddp_claim_rec.last_update_login := p1_a6;
    ddp_claim_rec.request_id := p1_a7;
    ddp_claim_rec.program_application_id := p1_a8;
    ddp_claim_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_claim_rec.program_id := p1_a10;
    ddp_claim_rec.created_from := p1_a11;
    ddp_claim_rec.batch_id := p1_a12;
    ddp_claim_rec.claim_number := p1_a13;
    ddp_claim_rec.claim_type_id := p1_a14;
    ddp_claim_rec.claim_class := p1_a15;
    ddp_claim_rec.claim_date := rosetta_g_miss_date_in_map(p1_a16);
    ddp_claim_rec.due_date := rosetta_g_miss_date_in_map(p1_a17);
    ddp_claim_rec.owner_id := p1_a18;
    ddp_claim_rec.history_event := p1_a19;
    ddp_claim_rec.history_event_date := rosetta_g_miss_date_in_map(p1_a20);
    ddp_claim_rec.history_event_description := p1_a21;
    ddp_claim_rec.split_from_claim_id := p1_a22;
    ddp_claim_rec.duplicate_claim_id := p1_a23;
    ddp_claim_rec.split_date := rosetta_g_miss_date_in_map(p1_a24);
    ddp_claim_rec.root_claim_id := p1_a25;
    ddp_claim_rec.amount := p1_a26;
    ddp_claim_rec.amount_adjusted := p1_a27;
    ddp_claim_rec.amount_remaining := p1_a28;
    ddp_claim_rec.amount_settled := p1_a29;
    ddp_claim_rec.acctd_amount := p1_a30;
    ddp_claim_rec.acctd_amount_remaining := p1_a31;
    ddp_claim_rec.acctd_amount_adjusted := p1_a32;
    ddp_claim_rec.acctd_amount_settled := p1_a33;
    ddp_claim_rec.tax_amount := p1_a34;
    ddp_claim_rec.tax_code := p1_a35;
    ddp_claim_rec.tax_calculation_flag := p1_a36;
    ddp_claim_rec.currency_code := p1_a37;
    ddp_claim_rec.exchange_rate_type := p1_a38;
    ddp_claim_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p1_a39);
    ddp_claim_rec.exchange_rate := p1_a40;
    ddp_claim_rec.set_of_books_id := p1_a41;
    ddp_claim_rec.original_claim_date := rosetta_g_miss_date_in_map(p1_a42);
    ddp_claim_rec.source_object_id := p1_a43;
    ddp_claim_rec.source_object_class := p1_a44;
    ddp_claim_rec.source_object_type_id := p1_a45;
    ddp_claim_rec.source_object_number := p1_a46;
    ddp_claim_rec.cust_account_id := p1_a47;
    ddp_claim_rec.cust_billto_acct_site_id := p1_a48;
    ddp_claim_rec.cust_shipto_acct_site_id := p1_a49;
    ddp_claim_rec.location_id := p1_a50;
    ddp_claim_rec.pay_related_account_flag := p1_a51;
    ddp_claim_rec.related_cust_account_id := p1_a52;
    ddp_claim_rec.related_site_use_id := p1_a53;
    ddp_claim_rec.relationship_type := p1_a54;
    ddp_claim_rec.vendor_id := p1_a55;
    ddp_claim_rec.vendor_site_id := p1_a56;
    ddp_claim_rec.reason_type := p1_a57;
    ddp_claim_rec.reason_code_id := p1_a58;
    ddp_claim_rec.task_template_group_id := p1_a59;
    ddp_claim_rec.status_code := p1_a60;
    ddp_claim_rec.user_status_id := p1_a61;
    ddp_claim_rec.sales_rep_id := p1_a62;
    ddp_claim_rec.collector_id := p1_a63;
    ddp_claim_rec.contact_id := p1_a64;
    ddp_claim_rec.broker_id := p1_a65;
    ddp_claim_rec.territory_id := p1_a66;
    ddp_claim_rec.customer_ref_date := rosetta_g_miss_date_in_map(p1_a67);
    ddp_claim_rec.customer_ref_number := p1_a68;
    ddp_claim_rec.assigned_to := p1_a69;
    ddp_claim_rec.receipt_id := p1_a70;
    ddp_claim_rec.receipt_number := p1_a71;
    ddp_claim_rec.doc_sequence_id := p1_a72;
    ddp_claim_rec.doc_sequence_value := p1_a73;
    ddp_claim_rec.gl_date := rosetta_g_miss_date_in_map(p1_a74);
    ddp_claim_rec.payment_method := p1_a75;
    ddp_claim_rec.voucher_id := p1_a76;
    ddp_claim_rec.voucher_number := p1_a77;
    ddp_claim_rec.payment_reference_id := p1_a78;
    ddp_claim_rec.payment_reference_number := p1_a79;
    ddp_claim_rec.payment_reference_date := rosetta_g_miss_date_in_map(p1_a80);
    ddp_claim_rec.payment_status := p1_a81;
    ddp_claim_rec.approved_flag := p1_a82;
    ddp_claim_rec.approved_date := rosetta_g_miss_date_in_map(p1_a83);
    ddp_claim_rec.approved_by := p1_a84;
    ddp_claim_rec.settled_date := rosetta_g_miss_date_in_map(p1_a85);
    ddp_claim_rec.settled_by := p1_a86;
    ddp_claim_rec.effective_date := rosetta_g_miss_date_in_map(p1_a87);
    ddp_claim_rec.custom_setup_id := p1_a88;
    ddp_claim_rec.task_id := p1_a89;
    ddp_claim_rec.country_id := p1_a90;
    ddp_claim_rec.order_type_id := p1_a91;
    ddp_claim_rec.comments := p1_a92;
    ddp_claim_rec.attribute_category := p1_a93;
    ddp_claim_rec.attribute1 := p1_a94;
    ddp_claim_rec.attribute2 := p1_a95;
    ddp_claim_rec.attribute3 := p1_a96;
    ddp_claim_rec.attribute4 := p1_a97;
    ddp_claim_rec.attribute5 := p1_a98;
    ddp_claim_rec.attribute6 := p1_a99;
    ddp_claim_rec.attribute7 := p1_a100;
    ddp_claim_rec.attribute8 := p1_a101;
    ddp_claim_rec.attribute9 := p1_a102;
    ddp_claim_rec.attribute10 := p1_a103;
    ddp_claim_rec.attribute11 := p1_a104;
    ddp_claim_rec.attribute12 := p1_a105;
    ddp_claim_rec.attribute13 := p1_a106;
    ddp_claim_rec.attribute14 := p1_a107;
    ddp_claim_rec.attribute15 := p1_a108;
    ddp_claim_rec.deduction_attribute_category := p1_a109;
    ddp_claim_rec.deduction_attribute1 := p1_a110;
    ddp_claim_rec.deduction_attribute2 := p1_a111;
    ddp_claim_rec.deduction_attribute3 := p1_a112;
    ddp_claim_rec.deduction_attribute4 := p1_a113;
    ddp_claim_rec.deduction_attribute5 := p1_a114;
    ddp_claim_rec.deduction_attribute6 := p1_a115;
    ddp_claim_rec.deduction_attribute7 := p1_a116;
    ddp_claim_rec.deduction_attribute8 := p1_a117;
    ddp_claim_rec.deduction_attribute9 := p1_a118;
    ddp_claim_rec.deduction_attribute10 := p1_a119;
    ddp_claim_rec.deduction_attribute11 := p1_a120;
    ddp_claim_rec.deduction_attribute12 := p1_a121;
    ddp_claim_rec.deduction_attribute13 := p1_a122;
    ddp_claim_rec.deduction_attribute14 := p1_a123;
    ddp_claim_rec.deduction_attribute15 := p1_a124;
    ddp_claim_rec.org_id := p1_a125;
    ddp_claim_rec.legal_entity_id := p1_a126;
    ddp_claim_rec.write_off_flag := p1_a127;
    ddp_claim_rec.write_off_threshold_amount := p1_a128;
    ddp_claim_rec.under_write_off_threshold := p1_a129;
    ddp_claim_rec.customer_reason := p1_a130;
    ddp_claim_rec.ship_to_cust_account_id := p1_a131;
    ddp_claim_rec.amount_applied := p1_a132;
    ddp_claim_rec.applied_receipt_id := p1_a133;
    ddp_claim_rec.applied_receipt_number := p1_a134;
    ddp_claim_rec.wo_rec_trx_id := p1_a135;
    ddp_claim_rec.group_claim_id := p1_a136;
    ddp_claim_rec.appr_wf_item_key := p1_a137;
    ddp_claim_rec.cstl_wf_item_key := p1_a138;
    ddp_claim_rec.batch_type := p1_a139;
    ddp_claim_rec.tax_action := p1_a140;
    ddp_claim_rec.close_status_id := p1_a141;
    ddp_claim_rec.open_status_id := p1_a142;
    ddp_claim_rec.pre_auth_deduction_number := p1_a143;
    ddp_claim_rec.pre_auth_deduction_normalized := p1_a144;
    ddp_claim_rec.offer_id := p1_a145;
    ddp_claim_rec.settled_from := p1_a146;
    ddp_claim_rec.approval_in_prog := p1_a147;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.check_claim_items(p_validation_mode,
      ddp_claim_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure complete_claim_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  DATE
    , p0_a17  DATE
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  DATE
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  DATE
    , p0_a43  NUMBER
    , p0_a44  VARCHAR2
    , p0_a45  NUMBER
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  DATE
    , p0_a68  VARCHAR2
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  VARCHAR2
    , p0_a78  NUMBER
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  DATE
    , p0_a84  NUMBER
    , p0_a85  DATE
    , p0_a86  NUMBER
    , p0_a87  DATE
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  VARCHAR2
    , p0_a93  VARCHAR2
    , p0_a94  VARCHAR2
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  VARCHAR2
    , p0_a98  VARCHAR2
    , p0_a99  VARCHAR2
    , p0_a100  VARCHAR2
    , p0_a101  VARCHAR2
    , p0_a102  VARCHAR2
    , p0_a103  VARCHAR2
    , p0_a104  VARCHAR2
    , p0_a105  VARCHAR2
    , p0_a106  VARCHAR2
    , p0_a107  VARCHAR2
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  VARCHAR2
    , p0_a111  VARCHAR2
    , p0_a112  VARCHAR2
    , p0_a113  VARCHAR2
    , p0_a114  VARCHAR2
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  VARCHAR2
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  NUMBER
    , p0_a126  NUMBER
    , p0_a127  VARCHAR2
    , p0_a128  NUMBER
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  NUMBER
    , p0_a132  NUMBER
    , p0_a133  NUMBER
    , p0_a134  VARCHAR2
    , p0_a135  NUMBER
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p0_a138  VARCHAR2
    , p0_a139  VARCHAR2
    , p0_a140  VARCHAR2
    , p0_a141  NUMBER
    , p0_a142  NUMBER
    , p0_a143  VARCHAR2
    , p0_a144  VARCHAR2
    , p0_a145  NUMBER
    , p0_a146  VARCHAR2
    , p0_a147  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  DATE
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  DATE
    , p1_a17 out nocopy  DATE
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  DATE
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  NUMBER
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  DATE
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  NUMBER
    , p1_a42 out nocopy  DATE
    , p1_a43 out nocopy  NUMBER
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  NUMBER
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  NUMBER
    , p1_a59 out nocopy  NUMBER
    , p1_a60 out nocopy  VARCHAR2
    , p1_a61 out nocopy  NUMBER
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  NUMBER
    , p1_a67 out nocopy  DATE
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  NUMBER
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  NUMBER
    , p1_a73 out nocopy  NUMBER
    , p1_a74 out nocopy  DATE
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  NUMBER
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  DATE
    , p1_a81 out nocopy  VARCHAR2
    , p1_a82 out nocopy  VARCHAR2
    , p1_a83 out nocopy  DATE
    , p1_a84 out nocopy  NUMBER
    , p1_a85 out nocopy  DATE
    , p1_a86 out nocopy  NUMBER
    , p1_a87 out nocopy  DATE
    , p1_a88 out nocopy  NUMBER
    , p1_a89 out nocopy  NUMBER
    , p1_a90 out nocopy  NUMBER
    , p1_a91 out nocopy  NUMBER
    , p1_a92 out nocopy  VARCHAR2
    , p1_a93 out nocopy  VARCHAR2
    , p1_a94 out nocopy  VARCHAR2
    , p1_a95 out nocopy  VARCHAR2
    , p1_a96 out nocopy  VARCHAR2
    , p1_a97 out nocopy  VARCHAR2
    , p1_a98 out nocopy  VARCHAR2
    , p1_a99 out nocopy  VARCHAR2
    , p1_a100 out nocopy  VARCHAR2
    , p1_a101 out nocopy  VARCHAR2
    , p1_a102 out nocopy  VARCHAR2
    , p1_a103 out nocopy  VARCHAR2
    , p1_a104 out nocopy  VARCHAR2
    , p1_a105 out nocopy  VARCHAR2
    , p1_a106 out nocopy  VARCHAR2
    , p1_a107 out nocopy  VARCHAR2
    , p1_a108 out nocopy  VARCHAR2
    , p1_a109 out nocopy  VARCHAR2
    , p1_a110 out nocopy  VARCHAR2
    , p1_a111 out nocopy  VARCHAR2
    , p1_a112 out nocopy  VARCHAR2
    , p1_a113 out nocopy  VARCHAR2
    , p1_a114 out nocopy  VARCHAR2
    , p1_a115 out nocopy  VARCHAR2
    , p1_a116 out nocopy  VARCHAR2
    , p1_a117 out nocopy  VARCHAR2
    , p1_a118 out nocopy  VARCHAR2
    , p1_a119 out nocopy  VARCHAR2
    , p1_a120 out nocopy  VARCHAR2
    , p1_a121 out nocopy  VARCHAR2
    , p1_a122 out nocopy  VARCHAR2
    , p1_a123 out nocopy  VARCHAR2
    , p1_a124 out nocopy  VARCHAR2
    , p1_a125 out nocopy  NUMBER
    , p1_a126 out nocopy  NUMBER
    , p1_a127 out nocopy  VARCHAR2
    , p1_a128 out nocopy  NUMBER
    , p1_a129 out nocopy  VARCHAR2
    , p1_a130 out nocopy  VARCHAR2
    , p1_a131 out nocopy  NUMBER
    , p1_a132 out nocopy  NUMBER
    , p1_a133 out nocopy  NUMBER
    , p1_a134 out nocopy  VARCHAR2
    , p1_a135 out nocopy  NUMBER
    , p1_a136 out nocopy  NUMBER
    , p1_a137 out nocopy  VARCHAR2
    , p1_a138 out nocopy  VARCHAR2
    , p1_a139 out nocopy  VARCHAR2
    , p1_a140 out nocopy  VARCHAR2
    , p1_a141 out nocopy  NUMBER
    , p1_a142 out nocopy  NUMBER
    , p1_a143 out nocopy  VARCHAR2
    , p1_a144 out nocopy  VARCHAR2
    , p1_a145 out nocopy  NUMBER
    , p1_a146 out nocopy  VARCHAR2
    , p1_a147 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_claim_rec ozf_claim_pvt.claim_rec_type;
    ddx_complete_rec ozf_claim_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_claim_rec.claim_id := p0_a0;
    ddp_claim_rec.object_version_number := p0_a1;
    ddp_claim_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_claim_rec.last_updated_by := p0_a3;
    ddp_claim_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_claim_rec.created_by := p0_a5;
    ddp_claim_rec.last_update_login := p0_a6;
    ddp_claim_rec.request_id := p0_a7;
    ddp_claim_rec.program_application_id := p0_a8;
    ddp_claim_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_claim_rec.program_id := p0_a10;
    ddp_claim_rec.created_from := p0_a11;
    ddp_claim_rec.batch_id := p0_a12;
    ddp_claim_rec.claim_number := p0_a13;
    ddp_claim_rec.claim_type_id := p0_a14;
    ddp_claim_rec.claim_class := p0_a15;
    ddp_claim_rec.claim_date := rosetta_g_miss_date_in_map(p0_a16);
    ddp_claim_rec.due_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_claim_rec.owner_id := p0_a18;
    ddp_claim_rec.history_event := p0_a19;
    ddp_claim_rec.history_event_date := rosetta_g_miss_date_in_map(p0_a20);
    ddp_claim_rec.history_event_description := p0_a21;
    ddp_claim_rec.split_from_claim_id := p0_a22;
    ddp_claim_rec.duplicate_claim_id := p0_a23;
    ddp_claim_rec.split_date := rosetta_g_miss_date_in_map(p0_a24);
    ddp_claim_rec.root_claim_id := p0_a25;
    ddp_claim_rec.amount := p0_a26;
    ddp_claim_rec.amount_adjusted := p0_a27;
    ddp_claim_rec.amount_remaining := p0_a28;
    ddp_claim_rec.amount_settled := p0_a29;
    ddp_claim_rec.acctd_amount := p0_a30;
    ddp_claim_rec.acctd_amount_remaining := p0_a31;
    ddp_claim_rec.acctd_amount_adjusted := p0_a32;
    ddp_claim_rec.acctd_amount_settled := p0_a33;
    ddp_claim_rec.tax_amount := p0_a34;
    ddp_claim_rec.tax_code := p0_a35;
    ddp_claim_rec.tax_calculation_flag := p0_a36;
    ddp_claim_rec.currency_code := p0_a37;
    ddp_claim_rec.exchange_rate_type := p0_a38;
    ddp_claim_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a39);
    ddp_claim_rec.exchange_rate := p0_a40;
    ddp_claim_rec.set_of_books_id := p0_a41;
    ddp_claim_rec.original_claim_date := rosetta_g_miss_date_in_map(p0_a42);
    ddp_claim_rec.source_object_id := p0_a43;
    ddp_claim_rec.source_object_class := p0_a44;
    ddp_claim_rec.source_object_type_id := p0_a45;
    ddp_claim_rec.source_object_number := p0_a46;
    ddp_claim_rec.cust_account_id := p0_a47;
    ddp_claim_rec.cust_billto_acct_site_id := p0_a48;
    ddp_claim_rec.cust_shipto_acct_site_id := p0_a49;
    ddp_claim_rec.location_id := p0_a50;
    ddp_claim_rec.pay_related_account_flag := p0_a51;
    ddp_claim_rec.related_cust_account_id := p0_a52;
    ddp_claim_rec.related_site_use_id := p0_a53;
    ddp_claim_rec.relationship_type := p0_a54;
    ddp_claim_rec.vendor_id := p0_a55;
    ddp_claim_rec.vendor_site_id := p0_a56;
    ddp_claim_rec.reason_type := p0_a57;
    ddp_claim_rec.reason_code_id := p0_a58;
    ddp_claim_rec.task_template_group_id := p0_a59;
    ddp_claim_rec.status_code := p0_a60;
    ddp_claim_rec.user_status_id := p0_a61;
    ddp_claim_rec.sales_rep_id := p0_a62;
    ddp_claim_rec.collector_id := p0_a63;
    ddp_claim_rec.contact_id := p0_a64;
    ddp_claim_rec.broker_id := p0_a65;
    ddp_claim_rec.territory_id := p0_a66;
    ddp_claim_rec.customer_ref_date := rosetta_g_miss_date_in_map(p0_a67);
    ddp_claim_rec.customer_ref_number := p0_a68;
    ddp_claim_rec.assigned_to := p0_a69;
    ddp_claim_rec.receipt_id := p0_a70;
    ddp_claim_rec.receipt_number := p0_a71;
    ddp_claim_rec.doc_sequence_id := p0_a72;
    ddp_claim_rec.doc_sequence_value := p0_a73;
    ddp_claim_rec.gl_date := rosetta_g_miss_date_in_map(p0_a74);
    ddp_claim_rec.payment_method := p0_a75;
    ddp_claim_rec.voucher_id := p0_a76;
    ddp_claim_rec.voucher_number := p0_a77;
    ddp_claim_rec.payment_reference_id := p0_a78;
    ddp_claim_rec.payment_reference_number := p0_a79;
    ddp_claim_rec.payment_reference_date := rosetta_g_miss_date_in_map(p0_a80);
    ddp_claim_rec.payment_status := p0_a81;
    ddp_claim_rec.approved_flag := p0_a82;
    ddp_claim_rec.approved_date := rosetta_g_miss_date_in_map(p0_a83);
    ddp_claim_rec.approved_by := p0_a84;
    ddp_claim_rec.settled_date := rosetta_g_miss_date_in_map(p0_a85);
    ddp_claim_rec.settled_by := p0_a86;
    ddp_claim_rec.effective_date := rosetta_g_miss_date_in_map(p0_a87);
    ddp_claim_rec.custom_setup_id := p0_a88;
    ddp_claim_rec.task_id := p0_a89;
    ddp_claim_rec.country_id := p0_a90;
    ddp_claim_rec.order_type_id := p0_a91;
    ddp_claim_rec.comments := p0_a92;
    ddp_claim_rec.attribute_category := p0_a93;
    ddp_claim_rec.attribute1 := p0_a94;
    ddp_claim_rec.attribute2 := p0_a95;
    ddp_claim_rec.attribute3 := p0_a96;
    ddp_claim_rec.attribute4 := p0_a97;
    ddp_claim_rec.attribute5 := p0_a98;
    ddp_claim_rec.attribute6 := p0_a99;
    ddp_claim_rec.attribute7 := p0_a100;
    ddp_claim_rec.attribute8 := p0_a101;
    ddp_claim_rec.attribute9 := p0_a102;
    ddp_claim_rec.attribute10 := p0_a103;
    ddp_claim_rec.attribute11 := p0_a104;
    ddp_claim_rec.attribute12 := p0_a105;
    ddp_claim_rec.attribute13 := p0_a106;
    ddp_claim_rec.attribute14 := p0_a107;
    ddp_claim_rec.attribute15 := p0_a108;
    ddp_claim_rec.deduction_attribute_category := p0_a109;
    ddp_claim_rec.deduction_attribute1 := p0_a110;
    ddp_claim_rec.deduction_attribute2 := p0_a111;
    ddp_claim_rec.deduction_attribute3 := p0_a112;
    ddp_claim_rec.deduction_attribute4 := p0_a113;
    ddp_claim_rec.deduction_attribute5 := p0_a114;
    ddp_claim_rec.deduction_attribute6 := p0_a115;
    ddp_claim_rec.deduction_attribute7 := p0_a116;
    ddp_claim_rec.deduction_attribute8 := p0_a117;
    ddp_claim_rec.deduction_attribute9 := p0_a118;
    ddp_claim_rec.deduction_attribute10 := p0_a119;
    ddp_claim_rec.deduction_attribute11 := p0_a120;
    ddp_claim_rec.deduction_attribute12 := p0_a121;
    ddp_claim_rec.deduction_attribute13 := p0_a122;
    ddp_claim_rec.deduction_attribute14 := p0_a123;
    ddp_claim_rec.deduction_attribute15 := p0_a124;
    ddp_claim_rec.org_id := p0_a125;
    ddp_claim_rec.legal_entity_id := p0_a126;
    ddp_claim_rec.write_off_flag := p0_a127;
    ddp_claim_rec.write_off_threshold_amount := p0_a128;
    ddp_claim_rec.under_write_off_threshold := p0_a129;
    ddp_claim_rec.customer_reason := p0_a130;
    ddp_claim_rec.ship_to_cust_account_id := p0_a131;
    ddp_claim_rec.amount_applied := p0_a132;
    ddp_claim_rec.applied_receipt_id := p0_a133;
    ddp_claim_rec.applied_receipt_number := p0_a134;
    ddp_claim_rec.wo_rec_trx_id := p0_a135;
    ddp_claim_rec.group_claim_id := p0_a136;
    ddp_claim_rec.appr_wf_item_key := p0_a137;
    ddp_claim_rec.cstl_wf_item_key := p0_a138;
    ddp_claim_rec.batch_type := p0_a139;
    ddp_claim_rec.tax_action := p0_a140;
    ddp_claim_rec.close_status_id := p0_a141;
    ddp_claim_rec.open_status_id := p0_a142;
    ddp_claim_rec.pre_auth_deduction_number := p0_a143;
    ddp_claim_rec.pre_auth_deduction_normalized := p0_a144;
    ddp_claim_rec.offer_id := p0_a145;
    ddp_claim_rec.settled_from := p0_a146;
    ddp_claim_rec.approval_in_prog := p0_a147;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.complete_claim_rec(ddp_claim_rec,
      ddx_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.claim_id;
    p1_a1 := ddx_complete_rec.object_version_number;
    p1_a2 := ddx_complete_rec.last_update_date;
    p1_a3 := ddx_complete_rec.last_updated_by;
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := ddx_complete_rec.created_by;
    p1_a6 := ddx_complete_rec.last_update_login;
    p1_a7 := ddx_complete_rec.request_id;
    p1_a8 := ddx_complete_rec.program_application_id;
    p1_a9 := ddx_complete_rec.program_update_date;
    p1_a10 := ddx_complete_rec.program_id;
    p1_a11 := ddx_complete_rec.created_from;
    p1_a12 := ddx_complete_rec.batch_id;
    p1_a13 := ddx_complete_rec.claim_number;
    p1_a14 := ddx_complete_rec.claim_type_id;
    p1_a15 := ddx_complete_rec.claim_class;
    p1_a16 := ddx_complete_rec.claim_date;
    p1_a17 := ddx_complete_rec.due_date;
    p1_a18 := ddx_complete_rec.owner_id;
    p1_a19 := ddx_complete_rec.history_event;
    p1_a20 := ddx_complete_rec.history_event_date;
    p1_a21 := ddx_complete_rec.history_event_description;
    p1_a22 := ddx_complete_rec.split_from_claim_id;
    p1_a23 := ddx_complete_rec.duplicate_claim_id;
    p1_a24 := ddx_complete_rec.split_date;
    p1_a25 := ddx_complete_rec.root_claim_id;
    p1_a26 := ddx_complete_rec.amount;
    p1_a27 := ddx_complete_rec.amount_adjusted;
    p1_a28 := ddx_complete_rec.amount_remaining;
    p1_a29 := ddx_complete_rec.amount_settled;
    p1_a30 := ddx_complete_rec.acctd_amount;
    p1_a31 := ddx_complete_rec.acctd_amount_remaining;
    p1_a32 := ddx_complete_rec.acctd_amount_adjusted;
    p1_a33 := ddx_complete_rec.acctd_amount_settled;
    p1_a34 := ddx_complete_rec.tax_amount;
    p1_a35 := ddx_complete_rec.tax_code;
    p1_a36 := ddx_complete_rec.tax_calculation_flag;
    p1_a37 := ddx_complete_rec.currency_code;
    p1_a38 := ddx_complete_rec.exchange_rate_type;
    p1_a39 := ddx_complete_rec.exchange_rate_date;
    p1_a40 := ddx_complete_rec.exchange_rate;
    p1_a41 := ddx_complete_rec.set_of_books_id;
    p1_a42 := ddx_complete_rec.original_claim_date;
    p1_a43 := ddx_complete_rec.source_object_id;
    p1_a44 := ddx_complete_rec.source_object_class;
    p1_a45 := ddx_complete_rec.source_object_type_id;
    p1_a46 := ddx_complete_rec.source_object_number;
    p1_a47 := ddx_complete_rec.cust_account_id;
    p1_a48 := ddx_complete_rec.cust_billto_acct_site_id;
    p1_a49 := ddx_complete_rec.cust_shipto_acct_site_id;
    p1_a50 := ddx_complete_rec.location_id;
    p1_a51 := ddx_complete_rec.pay_related_account_flag;
    p1_a52 := ddx_complete_rec.related_cust_account_id;
    p1_a53 := ddx_complete_rec.related_site_use_id;
    p1_a54 := ddx_complete_rec.relationship_type;
    p1_a55 := ddx_complete_rec.vendor_id;
    p1_a56 := ddx_complete_rec.vendor_site_id;
    p1_a57 := ddx_complete_rec.reason_type;
    p1_a58 := ddx_complete_rec.reason_code_id;
    p1_a59 := ddx_complete_rec.task_template_group_id;
    p1_a60 := ddx_complete_rec.status_code;
    p1_a61 := ddx_complete_rec.user_status_id;
    p1_a62 := ddx_complete_rec.sales_rep_id;
    p1_a63 := ddx_complete_rec.collector_id;
    p1_a64 := ddx_complete_rec.contact_id;
    p1_a65 := ddx_complete_rec.broker_id;
    p1_a66 := ddx_complete_rec.territory_id;
    p1_a67 := ddx_complete_rec.customer_ref_date;
    p1_a68 := ddx_complete_rec.customer_ref_number;
    p1_a69 := ddx_complete_rec.assigned_to;
    p1_a70 := ddx_complete_rec.receipt_id;
    p1_a71 := ddx_complete_rec.receipt_number;
    p1_a72 := ddx_complete_rec.doc_sequence_id;
    p1_a73 := ddx_complete_rec.doc_sequence_value;
    p1_a74 := ddx_complete_rec.gl_date;
    p1_a75 := ddx_complete_rec.payment_method;
    p1_a76 := ddx_complete_rec.voucher_id;
    p1_a77 := ddx_complete_rec.voucher_number;
    p1_a78 := ddx_complete_rec.payment_reference_id;
    p1_a79 := ddx_complete_rec.payment_reference_number;
    p1_a80 := ddx_complete_rec.payment_reference_date;
    p1_a81 := ddx_complete_rec.payment_status;
    p1_a82 := ddx_complete_rec.approved_flag;
    p1_a83 := ddx_complete_rec.approved_date;
    p1_a84 := ddx_complete_rec.approved_by;
    p1_a85 := ddx_complete_rec.settled_date;
    p1_a86 := ddx_complete_rec.settled_by;
    p1_a87 := ddx_complete_rec.effective_date;
    p1_a88 := ddx_complete_rec.custom_setup_id;
    p1_a89 := ddx_complete_rec.task_id;
    p1_a90 := ddx_complete_rec.country_id;
    p1_a91 := ddx_complete_rec.order_type_id;
    p1_a92 := ddx_complete_rec.comments;
    p1_a93 := ddx_complete_rec.attribute_category;
    p1_a94 := ddx_complete_rec.attribute1;
    p1_a95 := ddx_complete_rec.attribute2;
    p1_a96 := ddx_complete_rec.attribute3;
    p1_a97 := ddx_complete_rec.attribute4;
    p1_a98 := ddx_complete_rec.attribute5;
    p1_a99 := ddx_complete_rec.attribute6;
    p1_a100 := ddx_complete_rec.attribute7;
    p1_a101 := ddx_complete_rec.attribute8;
    p1_a102 := ddx_complete_rec.attribute9;
    p1_a103 := ddx_complete_rec.attribute10;
    p1_a104 := ddx_complete_rec.attribute11;
    p1_a105 := ddx_complete_rec.attribute12;
    p1_a106 := ddx_complete_rec.attribute13;
    p1_a107 := ddx_complete_rec.attribute14;
    p1_a108 := ddx_complete_rec.attribute15;
    p1_a109 := ddx_complete_rec.deduction_attribute_category;
    p1_a110 := ddx_complete_rec.deduction_attribute1;
    p1_a111 := ddx_complete_rec.deduction_attribute2;
    p1_a112 := ddx_complete_rec.deduction_attribute3;
    p1_a113 := ddx_complete_rec.deduction_attribute4;
    p1_a114 := ddx_complete_rec.deduction_attribute5;
    p1_a115 := ddx_complete_rec.deduction_attribute6;
    p1_a116 := ddx_complete_rec.deduction_attribute7;
    p1_a117 := ddx_complete_rec.deduction_attribute8;
    p1_a118 := ddx_complete_rec.deduction_attribute9;
    p1_a119 := ddx_complete_rec.deduction_attribute10;
    p1_a120 := ddx_complete_rec.deduction_attribute11;
    p1_a121 := ddx_complete_rec.deduction_attribute12;
    p1_a122 := ddx_complete_rec.deduction_attribute13;
    p1_a123 := ddx_complete_rec.deduction_attribute14;
    p1_a124 := ddx_complete_rec.deduction_attribute15;
    p1_a125 := ddx_complete_rec.org_id;
    p1_a126 := ddx_complete_rec.legal_entity_id;
    p1_a127 := ddx_complete_rec.write_off_flag;
    p1_a128 := ddx_complete_rec.write_off_threshold_amount;
    p1_a129 := ddx_complete_rec.under_write_off_threshold;
    p1_a130 := ddx_complete_rec.customer_reason;
    p1_a131 := ddx_complete_rec.ship_to_cust_account_id;
    p1_a132 := ddx_complete_rec.amount_applied;
    p1_a133 := ddx_complete_rec.applied_receipt_id;
    p1_a134 := ddx_complete_rec.applied_receipt_number;
    p1_a135 := ddx_complete_rec.wo_rec_trx_id;
    p1_a136 := ddx_complete_rec.group_claim_id;
    p1_a137 := ddx_complete_rec.appr_wf_item_key;
    p1_a138 := ddx_complete_rec.cstl_wf_item_key;
    p1_a139 := ddx_complete_rec.batch_type;
    p1_a140 := ddx_complete_rec.tax_action;
    p1_a141 := ddx_complete_rec.close_status_id;
    p1_a142 := ddx_complete_rec.open_status_id;
    p1_a143 := ddx_complete_rec.pre_auth_deduction_number;
    p1_a144 := ddx_complete_rec.pre_auth_deduction_normalized;
    p1_a145 := ddx_complete_rec.offer_id;
    p1_a146 := ddx_complete_rec.settled_from;
    p1_a147 := ddx_complete_rec.approval_in_prog;

  end;

  procedure create_claim_history(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  DATE
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  DATE
    , p7_a43  NUMBER
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  DATE
    , p7_a68  VARCHAR2
    , p7_a69  NUMBER
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  DATE
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  NUMBER
    , p7_a79  VARCHAR2
    , p7_a80  DATE
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  DATE
    , p7_a84  NUMBER
    , p7_a85  DATE
    , p7_a86  NUMBER
    , p7_a87  DATE
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  VARCHAR2
    , p7_a112  VARCHAR2
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  NUMBER
    , p7_a126  NUMBER
    , p7_a127  VARCHAR2
    , p7_a128  NUMBER
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  NUMBER
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  NUMBER
    , p7_a142  NUMBER
    , p7_a143  VARCHAR2
    , p7_a144  VARCHAR2
    , p7_a145  NUMBER
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p_event  VARCHAR2
    , x_need_to_create out nocopy  VARCHAR2
    , x_claim_history_id out nocopy  NUMBER
  )

  as
    ddp_claim ozf_claim_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claim.claim_id := p7_a0;
    ddp_claim.object_version_number := p7_a1;
    ddp_claim.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claim.last_updated_by := p7_a3;
    ddp_claim.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claim.created_by := p7_a5;
    ddp_claim.last_update_login := p7_a6;
    ddp_claim.request_id := p7_a7;
    ddp_claim.program_application_id := p7_a8;
    ddp_claim.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claim.program_id := p7_a10;
    ddp_claim.created_from := p7_a11;
    ddp_claim.batch_id := p7_a12;
    ddp_claim.claim_number := p7_a13;
    ddp_claim.claim_type_id := p7_a14;
    ddp_claim.claim_class := p7_a15;
    ddp_claim.claim_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_claim.due_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_claim.owner_id := p7_a18;
    ddp_claim.history_event := p7_a19;
    ddp_claim.history_event_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_claim.history_event_description := p7_a21;
    ddp_claim.split_from_claim_id := p7_a22;
    ddp_claim.duplicate_claim_id := p7_a23;
    ddp_claim.split_date := rosetta_g_miss_date_in_map(p7_a24);
    ddp_claim.root_claim_id := p7_a25;
    ddp_claim.amount := p7_a26;
    ddp_claim.amount_adjusted := p7_a27;
    ddp_claim.amount_remaining := p7_a28;
    ddp_claim.amount_settled := p7_a29;
    ddp_claim.acctd_amount := p7_a30;
    ddp_claim.acctd_amount_remaining := p7_a31;
    ddp_claim.acctd_amount_adjusted := p7_a32;
    ddp_claim.acctd_amount_settled := p7_a33;
    ddp_claim.tax_amount := p7_a34;
    ddp_claim.tax_code := p7_a35;
    ddp_claim.tax_calculation_flag := p7_a36;
    ddp_claim.currency_code := p7_a37;
    ddp_claim.exchange_rate_type := p7_a38;
    ddp_claim.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a39);
    ddp_claim.exchange_rate := p7_a40;
    ddp_claim.set_of_books_id := p7_a41;
    ddp_claim.original_claim_date := rosetta_g_miss_date_in_map(p7_a42);
    ddp_claim.source_object_id := p7_a43;
    ddp_claim.source_object_class := p7_a44;
    ddp_claim.source_object_type_id := p7_a45;
    ddp_claim.source_object_number := p7_a46;
    ddp_claim.cust_account_id := p7_a47;
    ddp_claim.cust_billto_acct_site_id := p7_a48;
    ddp_claim.cust_shipto_acct_site_id := p7_a49;
    ddp_claim.location_id := p7_a50;
    ddp_claim.pay_related_account_flag := p7_a51;
    ddp_claim.related_cust_account_id := p7_a52;
    ddp_claim.related_site_use_id := p7_a53;
    ddp_claim.relationship_type := p7_a54;
    ddp_claim.vendor_id := p7_a55;
    ddp_claim.vendor_site_id := p7_a56;
    ddp_claim.reason_type := p7_a57;
    ddp_claim.reason_code_id := p7_a58;
    ddp_claim.task_template_group_id := p7_a59;
    ddp_claim.status_code := p7_a60;
    ddp_claim.user_status_id := p7_a61;
    ddp_claim.sales_rep_id := p7_a62;
    ddp_claim.collector_id := p7_a63;
    ddp_claim.contact_id := p7_a64;
    ddp_claim.broker_id := p7_a65;
    ddp_claim.territory_id := p7_a66;
    ddp_claim.customer_ref_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_claim.customer_ref_number := p7_a68;
    ddp_claim.assigned_to := p7_a69;
    ddp_claim.receipt_id := p7_a70;
    ddp_claim.receipt_number := p7_a71;
    ddp_claim.doc_sequence_id := p7_a72;
    ddp_claim.doc_sequence_value := p7_a73;
    ddp_claim.gl_date := rosetta_g_miss_date_in_map(p7_a74);
    ddp_claim.payment_method := p7_a75;
    ddp_claim.voucher_id := p7_a76;
    ddp_claim.voucher_number := p7_a77;
    ddp_claim.payment_reference_id := p7_a78;
    ddp_claim.payment_reference_number := p7_a79;
    ddp_claim.payment_reference_date := rosetta_g_miss_date_in_map(p7_a80);
    ddp_claim.payment_status := p7_a81;
    ddp_claim.approved_flag := p7_a82;
    ddp_claim.approved_date := rosetta_g_miss_date_in_map(p7_a83);
    ddp_claim.approved_by := p7_a84;
    ddp_claim.settled_date := rosetta_g_miss_date_in_map(p7_a85);
    ddp_claim.settled_by := p7_a86;
    ddp_claim.effective_date := rosetta_g_miss_date_in_map(p7_a87);
    ddp_claim.custom_setup_id := p7_a88;
    ddp_claim.task_id := p7_a89;
    ddp_claim.country_id := p7_a90;
    ddp_claim.order_type_id := p7_a91;
    ddp_claim.comments := p7_a92;
    ddp_claim.attribute_category := p7_a93;
    ddp_claim.attribute1 := p7_a94;
    ddp_claim.attribute2 := p7_a95;
    ddp_claim.attribute3 := p7_a96;
    ddp_claim.attribute4 := p7_a97;
    ddp_claim.attribute5 := p7_a98;
    ddp_claim.attribute6 := p7_a99;
    ddp_claim.attribute7 := p7_a100;
    ddp_claim.attribute8 := p7_a101;
    ddp_claim.attribute9 := p7_a102;
    ddp_claim.attribute10 := p7_a103;
    ddp_claim.attribute11 := p7_a104;
    ddp_claim.attribute12 := p7_a105;
    ddp_claim.attribute13 := p7_a106;
    ddp_claim.attribute14 := p7_a107;
    ddp_claim.attribute15 := p7_a108;
    ddp_claim.deduction_attribute_category := p7_a109;
    ddp_claim.deduction_attribute1 := p7_a110;
    ddp_claim.deduction_attribute2 := p7_a111;
    ddp_claim.deduction_attribute3 := p7_a112;
    ddp_claim.deduction_attribute4 := p7_a113;
    ddp_claim.deduction_attribute5 := p7_a114;
    ddp_claim.deduction_attribute6 := p7_a115;
    ddp_claim.deduction_attribute7 := p7_a116;
    ddp_claim.deduction_attribute8 := p7_a117;
    ddp_claim.deduction_attribute9 := p7_a118;
    ddp_claim.deduction_attribute10 := p7_a119;
    ddp_claim.deduction_attribute11 := p7_a120;
    ddp_claim.deduction_attribute12 := p7_a121;
    ddp_claim.deduction_attribute13 := p7_a122;
    ddp_claim.deduction_attribute14 := p7_a123;
    ddp_claim.deduction_attribute15 := p7_a124;
    ddp_claim.org_id := p7_a125;
    ddp_claim.legal_entity_id := p7_a126;
    ddp_claim.write_off_flag := p7_a127;
    ddp_claim.write_off_threshold_amount := p7_a128;
    ddp_claim.under_write_off_threshold := p7_a129;
    ddp_claim.customer_reason := p7_a130;
    ddp_claim.ship_to_cust_account_id := p7_a131;
    ddp_claim.amount_applied := p7_a132;
    ddp_claim.applied_receipt_id := p7_a133;
    ddp_claim.applied_receipt_number := p7_a134;
    ddp_claim.wo_rec_trx_id := p7_a135;
    ddp_claim.group_claim_id := p7_a136;
    ddp_claim.appr_wf_item_key := p7_a137;
    ddp_claim.cstl_wf_item_key := p7_a138;
    ddp_claim.batch_type := p7_a139;
    ddp_claim.tax_action := p7_a140;
    ddp_claim.close_status_id := p7_a141;
    ddp_claim.open_status_id := p7_a142;
    ddp_claim.pre_auth_deduction_number := p7_a143;
    ddp_claim.pre_auth_deduction_normalized := p7_a144;
    ddp_claim.offer_id := p7_a145;
    ddp_claim.settled_from := p7_a146;
    ddp_claim.approval_in_prog := p7_a147;




    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.create_claim_history(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_claim,
      p_event,
      x_need_to_create,
      x_claim_history_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure validate_delete_claim(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_id  NUMBER
    , p_object_version_number  NUMBER
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_dependent_object_tbl ams_utility_pvt.dependent_objects_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.validate_delete_claim(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_object_id,
      p_object_version_number,
      ddx_dependent_object_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    ams_utility_pvt_w.rosetta_table_copy_out_p45(ddx_dependent_object_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      );



  end;

  procedure create_claim_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_DATE_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_VARCHAR2_TABLE_2000
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_NUMBER_TABLE
    , p7_a42 JTF_DATE_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_NUMBER_TABLE
    , p7_a46 JTF_VARCHAR2_TABLE_100
    , p7_a47 JTF_NUMBER_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_VARCHAR2_TABLE_100
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_VARCHAR2_TABLE_100
    , p7_a58 JTF_NUMBER_TABLE
    , p7_a59 JTF_NUMBER_TABLE
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_NUMBER_TABLE
    , p7_a63 JTF_NUMBER_TABLE
    , p7_a64 JTF_NUMBER_TABLE
    , p7_a65 JTF_NUMBER_TABLE
    , p7_a66 JTF_NUMBER_TABLE
    , p7_a67 JTF_DATE_TABLE
    , p7_a68 JTF_VARCHAR2_TABLE_100
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_NUMBER_TABLE
    , p7_a71 JTF_VARCHAR2_TABLE_100
    , p7_a72 JTF_NUMBER_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_DATE_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_DATE_TABLE
    , p7_a81 JTF_VARCHAR2_TABLE_100
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_DATE_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_DATE_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_DATE_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p7_a90 JTF_NUMBER_TABLE
    , p7_a91 JTF_NUMBER_TABLE
    , p7_a92 JTF_VARCHAR2_TABLE_2000
    , p7_a93 JTF_VARCHAR2_TABLE_100
    , p7_a94 JTF_VARCHAR2_TABLE_200
    , p7_a95 JTF_VARCHAR2_TABLE_200
    , p7_a96 JTF_VARCHAR2_TABLE_200
    , p7_a97 JTF_VARCHAR2_TABLE_200
    , p7_a98 JTF_VARCHAR2_TABLE_200
    , p7_a99 JTF_VARCHAR2_TABLE_200
    , p7_a100 JTF_VARCHAR2_TABLE_200
    , p7_a101 JTF_VARCHAR2_TABLE_200
    , p7_a102 JTF_VARCHAR2_TABLE_200
    , p7_a103 JTF_VARCHAR2_TABLE_200
    , p7_a104 JTF_VARCHAR2_TABLE_200
    , p7_a105 JTF_VARCHAR2_TABLE_200
    , p7_a106 JTF_VARCHAR2_TABLE_200
    , p7_a107 JTF_VARCHAR2_TABLE_200
    , p7_a108 JTF_VARCHAR2_TABLE_200
    , p7_a109 JTF_VARCHAR2_TABLE_100
    , p7_a110 JTF_VARCHAR2_TABLE_200
    , p7_a111 JTF_VARCHAR2_TABLE_200
    , p7_a112 JTF_VARCHAR2_TABLE_200
    , p7_a113 JTF_VARCHAR2_TABLE_200
    , p7_a114 JTF_VARCHAR2_TABLE_200
    , p7_a115 JTF_VARCHAR2_TABLE_200
    , p7_a116 JTF_VARCHAR2_TABLE_200
    , p7_a117 JTF_VARCHAR2_TABLE_200
    , p7_a118 JTF_VARCHAR2_TABLE_200
    , p7_a119 JTF_VARCHAR2_TABLE_200
    , p7_a120 JTF_VARCHAR2_TABLE_200
    , p7_a121 JTF_VARCHAR2_TABLE_200
    , p7_a122 JTF_VARCHAR2_TABLE_200
    , p7_a123 JTF_VARCHAR2_TABLE_200
    , p7_a124 JTF_VARCHAR2_TABLE_200
    , p7_a125 JTF_NUMBER_TABLE
    , p7_a126 JTF_NUMBER_TABLE
    , p7_a127 JTF_VARCHAR2_TABLE_100
    , p7_a128 JTF_NUMBER_TABLE
    , p7_a129 JTF_VARCHAR2_TABLE_100
    , p7_a130 JTF_VARCHAR2_TABLE_100
    , p7_a131 JTF_NUMBER_TABLE
    , p7_a132 JTF_NUMBER_TABLE
    , p7_a133 JTF_NUMBER_TABLE
    , p7_a134 JTF_VARCHAR2_TABLE_100
    , p7_a135 JTF_NUMBER_TABLE
    , p7_a136 JTF_NUMBER_TABLE
    , p7_a137 JTF_VARCHAR2_TABLE_300
    , p7_a138 JTF_VARCHAR2_TABLE_300
    , p7_a139 JTF_VARCHAR2_TABLE_100
    , p7_a140 JTF_VARCHAR2_TABLE_100
    , p7_a141 JTF_NUMBER_TABLE
    , p7_a142 JTF_NUMBER_TABLE
    , p7_a143 JTF_VARCHAR2_TABLE_100
    , p7_a144 JTF_VARCHAR2_TABLE_100
    , p7_a145 JTF_NUMBER_TABLE
    , p7_a146 JTF_VARCHAR2_TABLE_100
    , p7_a147 JTF_VARCHAR2_TABLE_100
    , x_error_index out nocopy  NUMBER
  )

  as
    ddp_claim_tbl ozf_claim_pvt.claim_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_claim_pvt_w.rosetta_table_copy_in_p3(ddp_claim_tbl, p7_a0
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
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      , p7_a90
      , p7_a91
      , p7_a92
      , p7_a93
      , p7_a94
      , p7_a95
      , p7_a96
      , p7_a97
      , p7_a98
      , p7_a99
      , p7_a100
      , p7_a101
      , p7_a102
      , p7_a103
      , p7_a104
      , p7_a105
      , p7_a106
      , p7_a107
      , p7_a108
      , p7_a109
      , p7_a110
      , p7_a111
      , p7_a112
      , p7_a113
      , p7_a114
      , p7_a115
      , p7_a116
      , p7_a117
      , p7_a118
      , p7_a119
      , p7_a120
      , p7_a121
      , p7_a122
      , p7_a123
      , p7_a124
      , p7_a125
      , p7_a126
      , p7_a127
      , p7_a128
      , p7_a129
      , p7_a130
      , p7_a131
      , p7_a132
      , p7_a133
      , p7_a134
      , p7_a135
      , p7_a136
      , p7_a137
      , p7_a138
      , p7_a139
      , p7_a140
      , p7_a141
      , p7_a142
      , p7_a143
      , p7_a144
      , p7_a145
      , p7_a146
      , p7_a147
      );


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.create_claim_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_claim_tbl,
      x_error_index);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_claim_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_DATE_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_VARCHAR2_TABLE_2000
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_NUMBER_TABLE
    , p7_a42 JTF_DATE_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_NUMBER_TABLE
    , p7_a46 JTF_VARCHAR2_TABLE_100
    , p7_a47 JTF_NUMBER_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_VARCHAR2_TABLE_100
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_VARCHAR2_TABLE_100
    , p7_a58 JTF_NUMBER_TABLE
    , p7_a59 JTF_NUMBER_TABLE
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_NUMBER_TABLE
    , p7_a63 JTF_NUMBER_TABLE
    , p7_a64 JTF_NUMBER_TABLE
    , p7_a65 JTF_NUMBER_TABLE
    , p7_a66 JTF_NUMBER_TABLE
    , p7_a67 JTF_DATE_TABLE
    , p7_a68 JTF_VARCHAR2_TABLE_100
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_NUMBER_TABLE
    , p7_a71 JTF_VARCHAR2_TABLE_100
    , p7_a72 JTF_NUMBER_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_DATE_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_DATE_TABLE
    , p7_a81 JTF_VARCHAR2_TABLE_100
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_DATE_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_DATE_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_DATE_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p7_a90 JTF_NUMBER_TABLE
    , p7_a91 JTF_NUMBER_TABLE
    , p7_a92 JTF_VARCHAR2_TABLE_2000
    , p7_a93 JTF_VARCHAR2_TABLE_100
    , p7_a94 JTF_VARCHAR2_TABLE_200
    , p7_a95 JTF_VARCHAR2_TABLE_200
    , p7_a96 JTF_VARCHAR2_TABLE_200
    , p7_a97 JTF_VARCHAR2_TABLE_200
    , p7_a98 JTF_VARCHAR2_TABLE_200
    , p7_a99 JTF_VARCHAR2_TABLE_200
    , p7_a100 JTF_VARCHAR2_TABLE_200
    , p7_a101 JTF_VARCHAR2_TABLE_200
    , p7_a102 JTF_VARCHAR2_TABLE_200
    , p7_a103 JTF_VARCHAR2_TABLE_200
    , p7_a104 JTF_VARCHAR2_TABLE_200
    , p7_a105 JTF_VARCHAR2_TABLE_200
    , p7_a106 JTF_VARCHAR2_TABLE_200
    , p7_a107 JTF_VARCHAR2_TABLE_200
    , p7_a108 JTF_VARCHAR2_TABLE_200
    , p7_a109 JTF_VARCHAR2_TABLE_100
    , p7_a110 JTF_VARCHAR2_TABLE_200
    , p7_a111 JTF_VARCHAR2_TABLE_200
    , p7_a112 JTF_VARCHAR2_TABLE_200
    , p7_a113 JTF_VARCHAR2_TABLE_200
    , p7_a114 JTF_VARCHAR2_TABLE_200
    , p7_a115 JTF_VARCHAR2_TABLE_200
    , p7_a116 JTF_VARCHAR2_TABLE_200
    , p7_a117 JTF_VARCHAR2_TABLE_200
    , p7_a118 JTF_VARCHAR2_TABLE_200
    , p7_a119 JTF_VARCHAR2_TABLE_200
    , p7_a120 JTF_VARCHAR2_TABLE_200
    , p7_a121 JTF_VARCHAR2_TABLE_200
    , p7_a122 JTF_VARCHAR2_TABLE_200
    , p7_a123 JTF_VARCHAR2_TABLE_200
    , p7_a124 JTF_VARCHAR2_TABLE_200
    , p7_a125 JTF_NUMBER_TABLE
    , p7_a126 JTF_NUMBER_TABLE
    , p7_a127 JTF_VARCHAR2_TABLE_100
    , p7_a128 JTF_NUMBER_TABLE
    , p7_a129 JTF_VARCHAR2_TABLE_100
    , p7_a130 JTF_VARCHAR2_TABLE_100
    , p7_a131 JTF_NUMBER_TABLE
    , p7_a132 JTF_NUMBER_TABLE
    , p7_a133 JTF_NUMBER_TABLE
    , p7_a134 JTF_VARCHAR2_TABLE_100
    , p7_a135 JTF_NUMBER_TABLE
    , p7_a136 JTF_NUMBER_TABLE
    , p7_a137 JTF_VARCHAR2_TABLE_300
    , p7_a138 JTF_VARCHAR2_TABLE_300
    , p7_a139 JTF_VARCHAR2_TABLE_100
    , p7_a140 JTF_VARCHAR2_TABLE_100
    , p7_a141 JTF_NUMBER_TABLE
    , p7_a142 JTF_NUMBER_TABLE
    , p7_a143 JTF_VARCHAR2_TABLE_100
    , p7_a144 JTF_VARCHAR2_TABLE_100
    , p7_a145 JTF_NUMBER_TABLE
    , p7_a146 JTF_VARCHAR2_TABLE_100
    , p7_a147 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_claim_tbl ozf_claim_pvt.claim_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_claim_pvt_w.rosetta_table_copy_in_p3(ddp_claim_tbl, p7_a0
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
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      , p7_a90
      , p7_a91
      , p7_a92
      , p7_a93
      , p7_a94
      , p7_a95
      , p7_a96
      , p7_a97
      , p7_a98
      , p7_a99
      , p7_a100
      , p7_a101
      , p7_a102
      , p7_a103
      , p7_a104
      , p7_a105
      , p7_a106
      , p7_a107
      , p7_a108
      , p7_a109
      , p7_a110
      , p7_a111
      , p7_a112
      , p7_a113
      , p7_a114
      , p7_a115
      , p7_a116
      , p7_a117
      , p7_a118
      , p7_a119
      , p7_a120
      , p7_a121
      , p7_a122
      , p7_a123
      , p7_a124
      , p7_a125
      , p7_a126
      , p7_a127
      , p7_a128
      , p7_a129
      , p7_a130
      , p7_a131
      , p7_a132
      , p7_a133
      , p7_a134
      , p7_a135
      , p7_a136
      , p7_a137
      , p7_a138
      , p7_a139
      , p7_a140
      , p7_a141
      , p7_a142
      , p7_a143
      , p7_a144
      , p7_a145
      , p7_a146
      , p7_a147
      );

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_pvt.update_claim_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_claim_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ozf_claim_pvt_w;

/
