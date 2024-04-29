--------------------------------------------------------
--  DDL for Package Body OZF_CLAIMS_HISTORY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIMS_HISTORY_PVT_W" as
  /* $Header: ozfwchib.pls 115.3 2003/12/02 23:54:12 yizhang noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_claims_history_pvt.claims_history_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_2000
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_DATE_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_DATE_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_DATE_TABLE
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_DATE_TABLE
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_DATE_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_DATE_TABLE
    , a85 JTF_NUMBER_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_DATE_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_NUMBER_TABLE
    , a93 JTF_VARCHAR2_TABLE_2000
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_VARCHAR2_TABLE_100
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
    , a109 JTF_VARCHAR2_TABLE_200
    , a110 JTF_VARCHAR2_TABLE_200
    , a111 JTF_VARCHAR2_TABLE_200
    , a112 JTF_VARCHAR2_TABLE_200
    , a113 JTF_VARCHAR2_TABLE_200
    , a114 JTF_VARCHAR2_TABLE_100
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
    , a125 JTF_VARCHAR2_TABLE_200
    , a126 JTF_VARCHAR2_TABLE_200
    , a127 JTF_VARCHAR2_TABLE_200
    , a128 JTF_VARCHAR2_TABLE_200
    , a129 JTF_VARCHAR2_TABLE_200
    , a130 JTF_NUMBER_TABLE
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_NUMBER_TABLE
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_NUMBER_TABLE
    , a138 JTF_VARCHAR2_TABLE_100
    , a139 JTF_NUMBER_TABLE
    , a140 JTF_NUMBER_TABLE
    , a141 JTF_VARCHAR2_TABLE_300
    , a142 JTF_VARCHAR2_TABLE_300
    , a143 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).claim_history_id := a0(indx);
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
          t(ddindx).claim_id := a13(indx);
          t(ddindx).claim_number := a14(indx);
          t(ddindx).claim_type_id := a15(indx);
          t(ddindx).claim_class := a16(indx);
          t(ddindx).claim_date := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).due_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).owner_id := a19(indx);
          t(ddindx).history_event := a20(indx);
          t(ddindx).history_event_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).history_event_description := a22(indx);
          t(ddindx).split_from_claim_id := a23(indx);
          t(ddindx).duplicate_claim_id := a24(indx);
          t(ddindx).split_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).root_claim_id := a26(indx);
          t(ddindx).amount := a27(indx);
          t(ddindx).amount_adjusted := a28(indx);
          t(ddindx).amount_remaining := a29(indx);
          t(ddindx).amount_settled := a30(indx);
          t(ddindx).acctd_amount := a31(indx);
          t(ddindx).acctd_amount_remaining := a32(indx);
          t(ddindx).acctd_amount_adjusted := a33(indx);
          t(ddindx).acctd_amount_settled := a34(indx);
          t(ddindx).tax_amount := a35(indx);
          t(ddindx).tax_code := a36(indx);
          t(ddindx).tax_calculation_flag := a37(indx);
          t(ddindx).currency_code := a38(indx);
          t(ddindx).exchange_rate_type := a39(indx);
          t(ddindx).exchange_rate_date := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).exchange_rate := a41(indx);
          t(ddindx).set_of_books_id := a42(indx);
          t(ddindx).original_claim_date := rosetta_g_miss_date_in_map(a43(indx));
          t(ddindx).source_object_id := a44(indx);
          t(ddindx).source_object_class := a45(indx);
          t(ddindx).source_object_type_id := a46(indx);
          t(ddindx).source_object_number := a47(indx);
          t(ddindx).cust_account_id := a48(indx);
          t(ddindx).cust_billto_acct_site_id := a49(indx);
          t(ddindx).cust_shipto_acct_site_id := a50(indx);
          t(ddindx).location_id := a51(indx);
          t(ddindx).pay_related_account_flag := a52(indx);
          t(ddindx).related_cust_account_id := a53(indx);
          t(ddindx).related_site_use_id := a54(indx);
          t(ddindx).relationship_type := a55(indx);
          t(ddindx).vendor_id := a56(indx);
          t(ddindx).vendor_site_id := a57(indx);
          t(ddindx).reason_type := a58(indx);
          t(ddindx).reason_code_id := a59(indx);
          t(ddindx).task_template_group_id := a60(indx);
          t(ddindx).status_code := a61(indx);
          t(ddindx).user_status_id := a62(indx);
          t(ddindx).sales_rep_id := a63(indx);
          t(ddindx).collector_id := a64(indx);
          t(ddindx).contact_id := a65(indx);
          t(ddindx).broker_id := a66(indx);
          t(ddindx).territory_id := a67(indx);
          t(ddindx).customer_ref_date := rosetta_g_miss_date_in_map(a68(indx));
          t(ddindx).customer_ref_number := a69(indx);
          t(ddindx).assigned_to := a70(indx);
          t(ddindx).receipt_id := a71(indx);
          t(ddindx).receipt_number := a72(indx);
          t(ddindx).doc_sequence_id := a73(indx);
          t(ddindx).doc_sequence_value := a74(indx);
          t(ddindx).gl_date := rosetta_g_miss_date_in_map(a75(indx));
          t(ddindx).payment_method := a76(indx);
          t(ddindx).voucher_id := a77(indx);
          t(ddindx).voucher_number := a78(indx);
          t(ddindx).payment_reference_id := a79(indx);
          t(ddindx).payment_reference_number := a80(indx);
          t(ddindx).payment_reference_date := rosetta_g_miss_date_in_map(a81(indx));
          t(ddindx).payment_status := a82(indx);
          t(ddindx).approved_flag := a83(indx);
          t(ddindx).approved_date := rosetta_g_miss_date_in_map(a84(indx));
          t(ddindx).approved_by := a85(indx);
          t(ddindx).settled_date := rosetta_g_miss_date_in_map(a86(indx));
          t(ddindx).settled_by := a87(indx);
          t(ddindx).effective_date := rosetta_g_miss_date_in_map(a88(indx));
          t(ddindx).custom_setup_id := a89(indx);
          t(ddindx).task_id := a90(indx);
          t(ddindx).country_id := a91(indx);
          t(ddindx).order_type_id := a92(indx);
          t(ddindx).comments := a93(indx);
          t(ddindx).letter_id := a94(indx);
          t(ddindx).letter_date := rosetta_g_miss_date_in_map(a95(indx));
          t(ddindx).task_source_object_id := a96(indx);
          t(ddindx).task_source_object_type_code := a97(indx);
          t(ddindx).attribute_category := a98(indx);
          t(ddindx).attribute1 := a99(indx);
          t(ddindx).attribute2 := a100(indx);
          t(ddindx).attribute3 := a101(indx);
          t(ddindx).attribute4 := a102(indx);
          t(ddindx).attribute5 := a103(indx);
          t(ddindx).attribute6 := a104(indx);
          t(ddindx).attribute7 := a105(indx);
          t(ddindx).attribute8 := a106(indx);
          t(ddindx).attribute9 := a107(indx);
          t(ddindx).attribute10 := a108(indx);
          t(ddindx).attribute11 := a109(indx);
          t(ddindx).attribute12 := a110(indx);
          t(ddindx).attribute13 := a111(indx);
          t(ddindx).attribute14 := a112(indx);
          t(ddindx).attribute15 := a113(indx);
          t(ddindx).deduction_attribute_category := a114(indx);
          t(ddindx).deduction_attribute1 := a115(indx);
          t(ddindx).deduction_attribute2 := a116(indx);
          t(ddindx).deduction_attribute3 := a117(indx);
          t(ddindx).deduction_attribute4 := a118(indx);
          t(ddindx).deduction_attribute5 := a119(indx);
          t(ddindx).deduction_attribute6 := a120(indx);
          t(ddindx).deduction_attribute7 := a121(indx);
          t(ddindx).deduction_attribute8 := a122(indx);
          t(ddindx).deduction_attribute9 := a123(indx);
          t(ddindx).deduction_attribute10 := a124(indx);
          t(ddindx).deduction_attribute11 := a125(indx);
          t(ddindx).deduction_attribute12 := a126(indx);
          t(ddindx).deduction_attribute13 := a127(indx);
          t(ddindx).deduction_attribute14 := a128(indx);
          t(ddindx).deduction_attribute15 := a129(indx);
          t(ddindx).org_id := a130(indx);
          t(ddindx).write_off_flag := a131(indx);
          t(ddindx).write_off_threshold_amount := a132(indx);
          t(ddindx).under_write_off_threshold := a133(indx);
          t(ddindx).customer_reason := a134(indx);
          t(ddindx).ship_to_cust_account_id := a135(indx);
          t(ddindx).amount_applied := a136(indx);
          t(ddindx).applied_receipt_id := a137(indx);
          t(ddindx).applied_receipt_number := a138(indx);
          t(ddindx).wo_rec_trx_id := a139(indx);
          t(ddindx).group_claim_id := a140(indx);
          t(ddindx).appr_wf_item_key := a141(indx);
          t(ddindx).cstl_wf_item_key := a142(indx);
          t(ddindx).batch_type := a143(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_claims_history_pvt.claims_history_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_2000
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_DATE_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_DATE_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_DATE_TABLE
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_VARCHAR2_TABLE_100
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_NUMBER_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_DATE_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_NUMBER_TABLE
    , a93 out nocopy JTF_VARCHAR2_TABLE_2000
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_NUMBER_TABLE
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a109 out nocopy JTF_VARCHAR2_TABLE_200
    , a110 out nocopy JTF_VARCHAR2_TABLE_200
    , a111 out nocopy JTF_VARCHAR2_TABLE_200
    , a112 out nocopy JTF_VARCHAR2_TABLE_200
    , a113 out nocopy JTF_VARCHAR2_TABLE_200
    , a114 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a125 out nocopy JTF_VARCHAR2_TABLE_200
    , a126 out nocopy JTF_VARCHAR2_TABLE_200
    , a127 out nocopy JTF_VARCHAR2_TABLE_200
    , a128 out nocopy JTF_VARCHAR2_TABLE_200
    , a129 out nocopy JTF_VARCHAR2_TABLE_200
    , a130 out nocopy JTF_NUMBER_TABLE
    , a131 out nocopy JTF_VARCHAR2_TABLE_100
    , a132 out nocopy JTF_NUMBER_TABLE
    , a133 out nocopy JTF_VARCHAR2_TABLE_100
    , a134 out nocopy JTF_VARCHAR2_TABLE_100
    , a135 out nocopy JTF_NUMBER_TABLE
    , a136 out nocopy JTF_NUMBER_TABLE
    , a137 out nocopy JTF_NUMBER_TABLE
    , a138 out nocopy JTF_VARCHAR2_TABLE_100
    , a139 out nocopy JTF_NUMBER_TABLE
    , a140 out nocopy JTF_NUMBER_TABLE
    , a141 out nocopy JTF_VARCHAR2_TABLE_300
    , a142 out nocopy JTF_VARCHAR2_TABLE_300
    , a143 out nocopy JTF_VARCHAR2_TABLE_100
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
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_VARCHAR2_TABLE_2000();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_DATE_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_DATE_TABLE();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_DATE_TABLE();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_DATE_TABLE();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_VARCHAR2_TABLE_100();
    a84 := JTF_DATE_TABLE();
    a85 := JTF_NUMBER_TABLE();
    a86 := JTF_DATE_TABLE();
    a87 := JTF_NUMBER_TABLE();
    a88 := JTF_DATE_TABLE();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_NUMBER_TABLE();
    a91 := JTF_NUMBER_TABLE();
    a92 := JTF_NUMBER_TABLE();
    a93 := JTF_VARCHAR2_TABLE_2000();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_DATE_TABLE();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_VARCHAR2_TABLE_100();
    a98 := JTF_VARCHAR2_TABLE_100();
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
    a109 := JTF_VARCHAR2_TABLE_200();
    a110 := JTF_VARCHAR2_TABLE_200();
    a111 := JTF_VARCHAR2_TABLE_200();
    a112 := JTF_VARCHAR2_TABLE_200();
    a113 := JTF_VARCHAR2_TABLE_200();
    a114 := JTF_VARCHAR2_TABLE_100();
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
    a125 := JTF_VARCHAR2_TABLE_200();
    a126 := JTF_VARCHAR2_TABLE_200();
    a127 := JTF_VARCHAR2_TABLE_200();
    a128 := JTF_VARCHAR2_TABLE_200();
    a129 := JTF_VARCHAR2_TABLE_200();
    a130 := JTF_NUMBER_TABLE();
    a131 := JTF_VARCHAR2_TABLE_100();
    a132 := JTF_NUMBER_TABLE();
    a133 := JTF_VARCHAR2_TABLE_100();
    a134 := JTF_VARCHAR2_TABLE_100();
    a135 := JTF_NUMBER_TABLE();
    a136 := JTF_NUMBER_TABLE();
    a137 := JTF_NUMBER_TABLE();
    a138 := JTF_VARCHAR2_TABLE_100();
    a139 := JTF_NUMBER_TABLE();
    a140 := JTF_NUMBER_TABLE();
    a141 := JTF_VARCHAR2_TABLE_300();
    a142 := JTF_VARCHAR2_TABLE_300();
    a143 := JTF_VARCHAR2_TABLE_100();
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
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_VARCHAR2_TABLE_2000();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_DATE_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_DATE_TABLE();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_DATE_TABLE();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_DATE_TABLE();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_VARCHAR2_TABLE_100();
      a84 := JTF_DATE_TABLE();
      a85 := JTF_NUMBER_TABLE();
      a86 := JTF_DATE_TABLE();
      a87 := JTF_NUMBER_TABLE();
      a88 := JTF_DATE_TABLE();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_NUMBER_TABLE();
      a91 := JTF_NUMBER_TABLE();
      a92 := JTF_NUMBER_TABLE();
      a93 := JTF_VARCHAR2_TABLE_2000();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_DATE_TABLE();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_VARCHAR2_TABLE_100();
      a98 := JTF_VARCHAR2_TABLE_100();
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
      a109 := JTF_VARCHAR2_TABLE_200();
      a110 := JTF_VARCHAR2_TABLE_200();
      a111 := JTF_VARCHAR2_TABLE_200();
      a112 := JTF_VARCHAR2_TABLE_200();
      a113 := JTF_VARCHAR2_TABLE_200();
      a114 := JTF_VARCHAR2_TABLE_100();
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
      a125 := JTF_VARCHAR2_TABLE_200();
      a126 := JTF_VARCHAR2_TABLE_200();
      a127 := JTF_VARCHAR2_TABLE_200();
      a128 := JTF_VARCHAR2_TABLE_200();
      a129 := JTF_VARCHAR2_TABLE_200();
      a130 := JTF_NUMBER_TABLE();
      a131 := JTF_VARCHAR2_TABLE_100();
      a132 := JTF_NUMBER_TABLE();
      a133 := JTF_VARCHAR2_TABLE_100();
      a134 := JTF_VARCHAR2_TABLE_100();
      a135 := JTF_NUMBER_TABLE();
      a136 := JTF_NUMBER_TABLE();
      a137 := JTF_NUMBER_TABLE();
      a138 := JTF_VARCHAR2_TABLE_100();
      a139 := JTF_NUMBER_TABLE();
      a140 := JTF_NUMBER_TABLE();
      a141 := JTF_VARCHAR2_TABLE_300();
      a142 := JTF_VARCHAR2_TABLE_300();
      a143 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).claim_history_id;
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
          a13(indx) := t(ddindx).claim_id;
          a14(indx) := t(ddindx).claim_number;
          a15(indx) := t(ddindx).claim_type_id;
          a16(indx) := t(ddindx).claim_class;
          a17(indx) := t(ddindx).claim_date;
          a18(indx) := t(ddindx).due_date;
          a19(indx) := t(ddindx).owner_id;
          a20(indx) := t(ddindx).history_event;
          a21(indx) := t(ddindx).history_event_date;
          a22(indx) := t(ddindx).history_event_description;
          a23(indx) := t(ddindx).split_from_claim_id;
          a24(indx) := t(ddindx).duplicate_claim_id;
          a25(indx) := t(ddindx).split_date;
          a26(indx) := t(ddindx).root_claim_id;
          a27(indx) := t(ddindx).amount;
          a28(indx) := t(ddindx).amount_adjusted;
          a29(indx) := t(ddindx).amount_remaining;
          a30(indx) := t(ddindx).amount_settled;
          a31(indx) := t(ddindx).acctd_amount;
          a32(indx) := t(ddindx).acctd_amount_remaining;
          a33(indx) := t(ddindx).acctd_amount_adjusted;
          a34(indx) := t(ddindx).acctd_amount_settled;
          a35(indx) := t(ddindx).tax_amount;
          a36(indx) := t(ddindx).tax_code;
          a37(indx) := t(ddindx).tax_calculation_flag;
          a38(indx) := t(ddindx).currency_code;
          a39(indx) := t(ddindx).exchange_rate_type;
          a40(indx) := t(ddindx).exchange_rate_date;
          a41(indx) := t(ddindx).exchange_rate;
          a42(indx) := t(ddindx).set_of_books_id;
          a43(indx) := t(ddindx).original_claim_date;
          a44(indx) := t(ddindx).source_object_id;
          a45(indx) := t(ddindx).source_object_class;
          a46(indx) := t(ddindx).source_object_type_id;
          a47(indx) := t(ddindx).source_object_number;
          a48(indx) := t(ddindx).cust_account_id;
          a49(indx) := t(ddindx).cust_billto_acct_site_id;
          a50(indx) := t(ddindx).cust_shipto_acct_site_id;
          a51(indx) := t(ddindx).location_id;
          a52(indx) := t(ddindx).pay_related_account_flag;
          a53(indx) := t(ddindx).related_cust_account_id;
          a54(indx) := t(ddindx).related_site_use_id;
          a55(indx) := t(ddindx).relationship_type;
          a56(indx) := t(ddindx).vendor_id;
          a57(indx) := t(ddindx).vendor_site_id;
          a58(indx) := t(ddindx).reason_type;
          a59(indx) := t(ddindx).reason_code_id;
          a60(indx) := t(ddindx).task_template_group_id;
          a61(indx) := t(ddindx).status_code;
          a62(indx) := t(ddindx).user_status_id;
          a63(indx) := t(ddindx).sales_rep_id;
          a64(indx) := t(ddindx).collector_id;
          a65(indx) := t(ddindx).contact_id;
          a66(indx) := t(ddindx).broker_id;
          a67(indx) := t(ddindx).territory_id;
          a68(indx) := t(ddindx).customer_ref_date;
          a69(indx) := t(ddindx).customer_ref_number;
          a70(indx) := t(ddindx).assigned_to;
          a71(indx) := t(ddindx).receipt_id;
          a72(indx) := t(ddindx).receipt_number;
          a73(indx) := t(ddindx).doc_sequence_id;
          a74(indx) := t(ddindx).doc_sequence_value;
          a75(indx) := t(ddindx).gl_date;
          a76(indx) := t(ddindx).payment_method;
          a77(indx) := t(ddindx).voucher_id;
          a78(indx) := t(ddindx).voucher_number;
          a79(indx) := t(ddindx).payment_reference_id;
          a80(indx) := t(ddindx).payment_reference_number;
          a81(indx) := t(ddindx).payment_reference_date;
          a82(indx) := t(ddindx).payment_status;
          a83(indx) := t(ddindx).approved_flag;
          a84(indx) := t(ddindx).approved_date;
          a85(indx) := t(ddindx).approved_by;
          a86(indx) := t(ddindx).settled_date;
          a87(indx) := t(ddindx).settled_by;
          a88(indx) := t(ddindx).effective_date;
          a89(indx) := t(ddindx).custom_setup_id;
          a90(indx) := t(ddindx).task_id;
          a91(indx) := t(ddindx).country_id;
          a92(indx) := t(ddindx).order_type_id;
          a93(indx) := t(ddindx).comments;
          a94(indx) := t(ddindx).letter_id;
          a95(indx) := t(ddindx).letter_date;
          a96(indx) := t(ddindx).task_source_object_id;
          a97(indx) := t(ddindx).task_source_object_type_code;
          a98(indx) := t(ddindx).attribute_category;
          a99(indx) := t(ddindx).attribute1;
          a100(indx) := t(ddindx).attribute2;
          a101(indx) := t(ddindx).attribute3;
          a102(indx) := t(ddindx).attribute4;
          a103(indx) := t(ddindx).attribute5;
          a104(indx) := t(ddindx).attribute6;
          a105(indx) := t(ddindx).attribute7;
          a106(indx) := t(ddindx).attribute8;
          a107(indx) := t(ddindx).attribute9;
          a108(indx) := t(ddindx).attribute10;
          a109(indx) := t(ddindx).attribute11;
          a110(indx) := t(ddindx).attribute12;
          a111(indx) := t(ddindx).attribute13;
          a112(indx) := t(ddindx).attribute14;
          a113(indx) := t(ddindx).attribute15;
          a114(indx) := t(ddindx).deduction_attribute_category;
          a115(indx) := t(ddindx).deduction_attribute1;
          a116(indx) := t(ddindx).deduction_attribute2;
          a117(indx) := t(ddindx).deduction_attribute3;
          a118(indx) := t(ddindx).deduction_attribute4;
          a119(indx) := t(ddindx).deduction_attribute5;
          a120(indx) := t(ddindx).deduction_attribute6;
          a121(indx) := t(ddindx).deduction_attribute7;
          a122(indx) := t(ddindx).deduction_attribute8;
          a123(indx) := t(ddindx).deduction_attribute9;
          a124(indx) := t(ddindx).deduction_attribute10;
          a125(indx) := t(ddindx).deduction_attribute11;
          a126(indx) := t(ddindx).deduction_attribute12;
          a127(indx) := t(ddindx).deduction_attribute13;
          a128(indx) := t(ddindx).deduction_attribute14;
          a129(indx) := t(ddindx).deduction_attribute15;
          a130(indx) := t(ddindx).org_id;
          a131(indx) := t(ddindx).write_off_flag;
          a132(indx) := t(ddindx).write_off_threshold_amount;
          a133(indx) := t(ddindx).under_write_off_threshold;
          a134(indx) := t(ddindx).customer_reason;
          a135(indx) := t(ddindx).ship_to_cust_account_id;
          a136(indx) := t(ddindx).amount_applied;
          a137(indx) := t(ddindx).applied_receipt_id;
          a138(indx) := t(ddindx).applied_receipt_number;
          a139(indx) := t(ddindx).wo_rec_trx_id;
          a140(indx) := t(ddindx).group_claim_id;
          a141(indx) := t(ddindx).appr_wf_item_key;
          a142(indx) := t(ddindx).cstl_wf_item_key;
          a143(indx) := t(ddindx).batch_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_claims_history(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  DATE
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  DATE
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  DATE
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  NUMBER
    , p7_a72  VARCHAR2
    , p7_a73  NUMBER
    , p7_a74  NUMBER
    , p7_a75  DATE
    , p7_a76  VARCHAR2
    , p7_a77  NUMBER
    , p7_a78  VARCHAR2
    , p7_a79  NUMBER
    , p7_a80  VARCHAR2
    , p7_a81  DATE
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  DATE
    , p7_a85  NUMBER
    , p7_a86  DATE
    , p7_a87  NUMBER
    , p7_a88  DATE
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  VARCHAR2
    , p7_a94  NUMBER
    , p7_a95  DATE
    , p7_a96  NUMBER
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
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  NUMBER
    , p7_a131  VARCHAR2
    , p7_a132  NUMBER
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  NUMBER
    , p7_a138  VARCHAR2
    , p7_a139  NUMBER
    , p7_a140  NUMBER
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , x_claim_history_id out nocopy  NUMBER
  )

  as
    ddp_claims_history_rec ozf_claims_history_pvt.claims_history_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claims_history_rec.claim_history_id := p7_a0;
    ddp_claims_history_rec.object_version_number := p7_a1;
    ddp_claims_history_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claims_history_rec.last_updated_by := p7_a3;
    ddp_claims_history_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claims_history_rec.created_by := p7_a5;
    ddp_claims_history_rec.last_update_login := p7_a6;
    ddp_claims_history_rec.request_id := p7_a7;
    ddp_claims_history_rec.program_application_id := p7_a8;
    ddp_claims_history_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claims_history_rec.program_id := p7_a10;
    ddp_claims_history_rec.created_from := p7_a11;
    ddp_claims_history_rec.batch_id := p7_a12;
    ddp_claims_history_rec.claim_id := p7_a13;
    ddp_claims_history_rec.claim_number := p7_a14;
    ddp_claims_history_rec.claim_type_id := p7_a15;
    ddp_claims_history_rec.claim_class := p7_a16;
    ddp_claims_history_rec.claim_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_claims_history_rec.due_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_claims_history_rec.owner_id := p7_a19;
    ddp_claims_history_rec.history_event := p7_a20;
    ddp_claims_history_rec.history_event_date := rosetta_g_miss_date_in_map(p7_a21);
    ddp_claims_history_rec.history_event_description := p7_a22;
    ddp_claims_history_rec.split_from_claim_id := p7_a23;
    ddp_claims_history_rec.duplicate_claim_id := p7_a24;
    ddp_claims_history_rec.split_date := rosetta_g_miss_date_in_map(p7_a25);
    ddp_claims_history_rec.root_claim_id := p7_a26;
    ddp_claims_history_rec.amount := p7_a27;
    ddp_claims_history_rec.amount_adjusted := p7_a28;
    ddp_claims_history_rec.amount_remaining := p7_a29;
    ddp_claims_history_rec.amount_settled := p7_a30;
    ddp_claims_history_rec.acctd_amount := p7_a31;
    ddp_claims_history_rec.acctd_amount_remaining := p7_a32;
    ddp_claims_history_rec.acctd_amount_adjusted := p7_a33;
    ddp_claims_history_rec.acctd_amount_settled := p7_a34;
    ddp_claims_history_rec.tax_amount := p7_a35;
    ddp_claims_history_rec.tax_code := p7_a36;
    ddp_claims_history_rec.tax_calculation_flag := p7_a37;
    ddp_claims_history_rec.currency_code := p7_a38;
    ddp_claims_history_rec.exchange_rate_type := p7_a39;
    ddp_claims_history_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_claims_history_rec.exchange_rate := p7_a41;
    ddp_claims_history_rec.set_of_books_id := p7_a42;
    ddp_claims_history_rec.original_claim_date := rosetta_g_miss_date_in_map(p7_a43);
    ddp_claims_history_rec.source_object_id := p7_a44;
    ddp_claims_history_rec.source_object_class := p7_a45;
    ddp_claims_history_rec.source_object_type_id := p7_a46;
    ddp_claims_history_rec.source_object_number := p7_a47;
    ddp_claims_history_rec.cust_account_id := p7_a48;
    ddp_claims_history_rec.cust_billto_acct_site_id := p7_a49;
    ddp_claims_history_rec.cust_shipto_acct_site_id := p7_a50;
    ddp_claims_history_rec.location_id := p7_a51;
    ddp_claims_history_rec.pay_related_account_flag := p7_a52;
    ddp_claims_history_rec.related_cust_account_id := p7_a53;
    ddp_claims_history_rec.related_site_use_id := p7_a54;
    ddp_claims_history_rec.relationship_type := p7_a55;
    ddp_claims_history_rec.vendor_id := p7_a56;
    ddp_claims_history_rec.vendor_site_id := p7_a57;
    ddp_claims_history_rec.reason_type := p7_a58;
    ddp_claims_history_rec.reason_code_id := p7_a59;
    ddp_claims_history_rec.task_template_group_id := p7_a60;
    ddp_claims_history_rec.status_code := p7_a61;
    ddp_claims_history_rec.user_status_id := p7_a62;
    ddp_claims_history_rec.sales_rep_id := p7_a63;
    ddp_claims_history_rec.collector_id := p7_a64;
    ddp_claims_history_rec.contact_id := p7_a65;
    ddp_claims_history_rec.broker_id := p7_a66;
    ddp_claims_history_rec.territory_id := p7_a67;
    ddp_claims_history_rec.customer_ref_date := rosetta_g_miss_date_in_map(p7_a68);
    ddp_claims_history_rec.customer_ref_number := p7_a69;
    ddp_claims_history_rec.assigned_to := p7_a70;
    ddp_claims_history_rec.receipt_id := p7_a71;
    ddp_claims_history_rec.receipt_number := p7_a72;
    ddp_claims_history_rec.doc_sequence_id := p7_a73;
    ddp_claims_history_rec.doc_sequence_value := p7_a74;
    ddp_claims_history_rec.gl_date := rosetta_g_miss_date_in_map(p7_a75);
    ddp_claims_history_rec.payment_method := p7_a76;
    ddp_claims_history_rec.voucher_id := p7_a77;
    ddp_claims_history_rec.voucher_number := p7_a78;
    ddp_claims_history_rec.payment_reference_id := p7_a79;
    ddp_claims_history_rec.payment_reference_number := p7_a80;
    ddp_claims_history_rec.payment_reference_date := rosetta_g_miss_date_in_map(p7_a81);
    ddp_claims_history_rec.payment_status := p7_a82;
    ddp_claims_history_rec.approved_flag := p7_a83;
    ddp_claims_history_rec.approved_date := rosetta_g_miss_date_in_map(p7_a84);
    ddp_claims_history_rec.approved_by := p7_a85;
    ddp_claims_history_rec.settled_date := rosetta_g_miss_date_in_map(p7_a86);
    ddp_claims_history_rec.settled_by := p7_a87;
    ddp_claims_history_rec.effective_date := rosetta_g_miss_date_in_map(p7_a88);
    ddp_claims_history_rec.custom_setup_id := p7_a89;
    ddp_claims_history_rec.task_id := p7_a90;
    ddp_claims_history_rec.country_id := p7_a91;
    ddp_claims_history_rec.order_type_id := p7_a92;
    ddp_claims_history_rec.comments := p7_a93;
    ddp_claims_history_rec.letter_id := p7_a94;
    ddp_claims_history_rec.letter_date := rosetta_g_miss_date_in_map(p7_a95);
    ddp_claims_history_rec.task_source_object_id := p7_a96;
    ddp_claims_history_rec.task_source_object_type_code := p7_a97;
    ddp_claims_history_rec.attribute_category := p7_a98;
    ddp_claims_history_rec.attribute1 := p7_a99;
    ddp_claims_history_rec.attribute2 := p7_a100;
    ddp_claims_history_rec.attribute3 := p7_a101;
    ddp_claims_history_rec.attribute4 := p7_a102;
    ddp_claims_history_rec.attribute5 := p7_a103;
    ddp_claims_history_rec.attribute6 := p7_a104;
    ddp_claims_history_rec.attribute7 := p7_a105;
    ddp_claims_history_rec.attribute8 := p7_a106;
    ddp_claims_history_rec.attribute9 := p7_a107;
    ddp_claims_history_rec.attribute10 := p7_a108;
    ddp_claims_history_rec.attribute11 := p7_a109;
    ddp_claims_history_rec.attribute12 := p7_a110;
    ddp_claims_history_rec.attribute13 := p7_a111;
    ddp_claims_history_rec.attribute14 := p7_a112;
    ddp_claims_history_rec.attribute15 := p7_a113;
    ddp_claims_history_rec.deduction_attribute_category := p7_a114;
    ddp_claims_history_rec.deduction_attribute1 := p7_a115;
    ddp_claims_history_rec.deduction_attribute2 := p7_a116;
    ddp_claims_history_rec.deduction_attribute3 := p7_a117;
    ddp_claims_history_rec.deduction_attribute4 := p7_a118;
    ddp_claims_history_rec.deduction_attribute5 := p7_a119;
    ddp_claims_history_rec.deduction_attribute6 := p7_a120;
    ddp_claims_history_rec.deduction_attribute7 := p7_a121;
    ddp_claims_history_rec.deduction_attribute8 := p7_a122;
    ddp_claims_history_rec.deduction_attribute9 := p7_a123;
    ddp_claims_history_rec.deduction_attribute10 := p7_a124;
    ddp_claims_history_rec.deduction_attribute11 := p7_a125;
    ddp_claims_history_rec.deduction_attribute12 := p7_a126;
    ddp_claims_history_rec.deduction_attribute13 := p7_a127;
    ddp_claims_history_rec.deduction_attribute14 := p7_a128;
    ddp_claims_history_rec.deduction_attribute15 := p7_a129;
    ddp_claims_history_rec.org_id := p7_a130;
    ddp_claims_history_rec.write_off_flag := p7_a131;
    ddp_claims_history_rec.write_off_threshold_amount := p7_a132;
    ddp_claims_history_rec.under_write_off_threshold := p7_a133;
    ddp_claims_history_rec.customer_reason := p7_a134;
    ddp_claims_history_rec.ship_to_cust_account_id := p7_a135;
    ddp_claims_history_rec.amount_applied := p7_a136;
    ddp_claims_history_rec.applied_receipt_id := p7_a137;
    ddp_claims_history_rec.applied_receipt_number := p7_a138;
    ddp_claims_history_rec.wo_rec_trx_id := p7_a139;
    ddp_claims_history_rec.group_claim_id := p7_a140;
    ddp_claims_history_rec.appr_wf_item_key := p7_a141;
    ddp_claims_history_rec.cstl_wf_item_key := p7_a142;
    ddp_claims_history_rec.batch_type := p7_a143;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claims_history_pvt.create_claims_history(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claims_history_rec,
      x_claim_history_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_claims_history(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  DATE
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  DATE
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  DATE
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  NUMBER
    , p7_a72  VARCHAR2
    , p7_a73  NUMBER
    , p7_a74  NUMBER
    , p7_a75  DATE
    , p7_a76  VARCHAR2
    , p7_a77  NUMBER
    , p7_a78  VARCHAR2
    , p7_a79  NUMBER
    , p7_a80  VARCHAR2
    , p7_a81  DATE
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  DATE
    , p7_a85  NUMBER
    , p7_a86  DATE
    , p7_a87  NUMBER
    , p7_a88  DATE
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  VARCHAR2
    , p7_a94  NUMBER
    , p7_a95  DATE
    , p7_a96  NUMBER
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
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  NUMBER
    , p7_a131  VARCHAR2
    , p7_a132  NUMBER
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  NUMBER
    , p7_a138  VARCHAR2
    , p7_a139  NUMBER
    , p7_a140  NUMBER
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_claims_history_rec ozf_claims_history_pvt.claims_history_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claims_history_rec.claim_history_id := p7_a0;
    ddp_claims_history_rec.object_version_number := p7_a1;
    ddp_claims_history_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claims_history_rec.last_updated_by := p7_a3;
    ddp_claims_history_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claims_history_rec.created_by := p7_a5;
    ddp_claims_history_rec.last_update_login := p7_a6;
    ddp_claims_history_rec.request_id := p7_a7;
    ddp_claims_history_rec.program_application_id := p7_a8;
    ddp_claims_history_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claims_history_rec.program_id := p7_a10;
    ddp_claims_history_rec.created_from := p7_a11;
    ddp_claims_history_rec.batch_id := p7_a12;
    ddp_claims_history_rec.claim_id := p7_a13;
    ddp_claims_history_rec.claim_number := p7_a14;
    ddp_claims_history_rec.claim_type_id := p7_a15;
    ddp_claims_history_rec.claim_class := p7_a16;
    ddp_claims_history_rec.claim_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_claims_history_rec.due_date := rosetta_g_miss_date_in_map(p7_a18);
    ddp_claims_history_rec.owner_id := p7_a19;
    ddp_claims_history_rec.history_event := p7_a20;
    ddp_claims_history_rec.history_event_date := rosetta_g_miss_date_in_map(p7_a21);
    ddp_claims_history_rec.history_event_description := p7_a22;
    ddp_claims_history_rec.split_from_claim_id := p7_a23;
    ddp_claims_history_rec.duplicate_claim_id := p7_a24;
    ddp_claims_history_rec.split_date := rosetta_g_miss_date_in_map(p7_a25);
    ddp_claims_history_rec.root_claim_id := p7_a26;
    ddp_claims_history_rec.amount := p7_a27;
    ddp_claims_history_rec.amount_adjusted := p7_a28;
    ddp_claims_history_rec.amount_remaining := p7_a29;
    ddp_claims_history_rec.amount_settled := p7_a30;
    ddp_claims_history_rec.acctd_amount := p7_a31;
    ddp_claims_history_rec.acctd_amount_remaining := p7_a32;
    ddp_claims_history_rec.acctd_amount_adjusted := p7_a33;
    ddp_claims_history_rec.acctd_amount_settled := p7_a34;
    ddp_claims_history_rec.tax_amount := p7_a35;
    ddp_claims_history_rec.tax_code := p7_a36;
    ddp_claims_history_rec.tax_calculation_flag := p7_a37;
    ddp_claims_history_rec.currency_code := p7_a38;
    ddp_claims_history_rec.exchange_rate_type := p7_a39;
    ddp_claims_history_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a40);
    ddp_claims_history_rec.exchange_rate := p7_a41;
    ddp_claims_history_rec.set_of_books_id := p7_a42;
    ddp_claims_history_rec.original_claim_date := rosetta_g_miss_date_in_map(p7_a43);
    ddp_claims_history_rec.source_object_id := p7_a44;
    ddp_claims_history_rec.source_object_class := p7_a45;
    ddp_claims_history_rec.source_object_type_id := p7_a46;
    ddp_claims_history_rec.source_object_number := p7_a47;
    ddp_claims_history_rec.cust_account_id := p7_a48;
    ddp_claims_history_rec.cust_billto_acct_site_id := p7_a49;
    ddp_claims_history_rec.cust_shipto_acct_site_id := p7_a50;
    ddp_claims_history_rec.location_id := p7_a51;
    ddp_claims_history_rec.pay_related_account_flag := p7_a52;
    ddp_claims_history_rec.related_cust_account_id := p7_a53;
    ddp_claims_history_rec.related_site_use_id := p7_a54;
    ddp_claims_history_rec.relationship_type := p7_a55;
    ddp_claims_history_rec.vendor_id := p7_a56;
    ddp_claims_history_rec.vendor_site_id := p7_a57;
    ddp_claims_history_rec.reason_type := p7_a58;
    ddp_claims_history_rec.reason_code_id := p7_a59;
    ddp_claims_history_rec.task_template_group_id := p7_a60;
    ddp_claims_history_rec.status_code := p7_a61;
    ddp_claims_history_rec.user_status_id := p7_a62;
    ddp_claims_history_rec.sales_rep_id := p7_a63;
    ddp_claims_history_rec.collector_id := p7_a64;
    ddp_claims_history_rec.contact_id := p7_a65;
    ddp_claims_history_rec.broker_id := p7_a66;
    ddp_claims_history_rec.territory_id := p7_a67;
    ddp_claims_history_rec.customer_ref_date := rosetta_g_miss_date_in_map(p7_a68);
    ddp_claims_history_rec.customer_ref_number := p7_a69;
    ddp_claims_history_rec.assigned_to := p7_a70;
    ddp_claims_history_rec.receipt_id := p7_a71;
    ddp_claims_history_rec.receipt_number := p7_a72;
    ddp_claims_history_rec.doc_sequence_id := p7_a73;
    ddp_claims_history_rec.doc_sequence_value := p7_a74;
    ddp_claims_history_rec.gl_date := rosetta_g_miss_date_in_map(p7_a75);
    ddp_claims_history_rec.payment_method := p7_a76;
    ddp_claims_history_rec.voucher_id := p7_a77;
    ddp_claims_history_rec.voucher_number := p7_a78;
    ddp_claims_history_rec.payment_reference_id := p7_a79;
    ddp_claims_history_rec.payment_reference_number := p7_a80;
    ddp_claims_history_rec.payment_reference_date := rosetta_g_miss_date_in_map(p7_a81);
    ddp_claims_history_rec.payment_status := p7_a82;
    ddp_claims_history_rec.approved_flag := p7_a83;
    ddp_claims_history_rec.approved_date := rosetta_g_miss_date_in_map(p7_a84);
    ddp_claims_history_rec.approved_by := p7_a85;
    ddp_claims_history_rec.settled_date := rosetta_g_miss_date_in_map(p7_a86);
    ddp_claims_history_rec.settled_by := p7_a87;
    ddp_claims_history_rec.effective_date := rosetta_g_miss_date_in_map(p7_a88);
    ddp_claims_history_rec.custom_setup_id := p7_a89;
    ddp_claims_history_rec.task_id := p7_a90;
    ddp_claims_history_rec.country_id := p7_a91;
    ddp_claims_history_rec.order_type_id := p7_a92;
    ddp_claims_history_rec.comments := p7_a93;
    ddp_claims_history_rec.letter_id := p7_a94;
    ddp_claims_history_rec.letter_date := rosetta_g_miss_date_in_map(p7_a95);
    ddp_claims_history_rec.task_source_object_id := p7_a96;
    ddp_claims_history_rec.task_source_object_type_code := p7_a97;
    ddp_claims_history_rec.attribute_category := p7_a98;
    ddp_claims_history_rec.attribute1 := p7_a99;
    ddp_claims_history_rec.attribute2 := p7_a100;
    ddp_claims_history_rec.attribute3 := p7_a101;
    ddp_claims_history_rec.attribute4 := p7_a102;
    ddp_claims_history_rec.attribute5 := p7_a103;
    ddp_claims_history_rec.attribute6 := p7_a104;
    ddp_claims_history_rec.attribute7 := p7_a105;
    ddp_claims_history_rec.attribute8 := p7_a106;
    ddp_claims_history_rec.attribute9 := p7_a107;
    ddp_claims_history_rec.attribute10 := p7_a108;
    ddp_claims_history_rec.attribute11 := p7_a109;
    ddp_claims_history_rec.attribute12 := p7_a110;
    ddp_claims_history_rec.attribute13 := p7_a111;
    ddp_claims_history_rec.attribute14 := p7_a112;
    ddp_claims_history_rec.attribute15 := p7_a113;
    ddp_claims_history_rec.deduction_attribute_category := p7_a114;
    ddp_claims_history_rec.deduction_attribute1 := p7_a115;
    ddp_claims_history_rec.deduction_attribute2 := p7_a116;
    ddp_claims_history_rec.deduction_attribute3 := p7_a117;
    ddp_claims_history_rec.deduction_attribute4 := p7_a118;
    ddp_claims_history_rec.deduction_attribute5 := p7_a119;
    ddp_claims_history_rec.deduction_attribute6 := p7_a120;
    ddp_claims_history_rec.deduction_attribute7 := p7_a121;
    ddp_claims_history_rec.deduction_attribute8 := p7_a122;
    ddp_claims_history_rec.deduction_attribute9 := p7_a123;
    ddp_claims_history_rec.deduction_attribute10 := p7_a124;
    ddp_claims_history_rec.deduction_attribute11 := p7_a125;
    ddp_claims_history_rec.deduction_attribute12 := p7_a126;
    ddp_claims_history_rec.deduction_attribute13 := p7_a127;
    ddp_claims_history_rec.deduction_attribute14 := p7_a128;
    ddp_claims_history_rec.deduction_attribute15 := p7_a129;
    ddp_claims_history_rec.org_id := p7_a130;
    ddp_claims_history_rec.write_off_flag := p7_a131;
    ddp_claims_history_rec.write_off_threshold_amount := p7_a132;
    ddp_claims_history_rec.under_write_off_threshold := p7_a133;
    ddp_claims_history_rec.customer_reason := p7_a134;
    ddp_claims_history_rec.ship_to_cust_account_id := p7_a135;
    ddp_claims_history_rec.amount_applied := p7_a136;
    ddp_claims_history_rec.applied_receipt_id := p7_a137;
    ddp_claims_history_rec.applied_receipt_number := p7_a138;
    ddp_claims_history_rec.wo_rec_trx_id := p7_a139;
    ddp_claims_history_rec.group_claim_id := p7_a140;
    ddp_claims_history_rec.appr_wf_item_key := p7_a141;
    ddp_claims_history_rec.cstl_wf_item_key := p7_a142;
    ddp_claims_history_rec.batch_type := p7_a143;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claims_history_pvt.update_claims_history(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claims_history_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_claims_history(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  DATE
    , p3_a10  NUMBER
    , p3_a11  VARCHAR2
    , p3_a12  NUMBER
    , p3_a13  NUMBER
    , p3_a14  VARCHAR2
    , p3_a15  NUMBER
    , p3_a16  VARCHAR2
    , p3_a17  DATE
    , p3_a18  DATE
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  DATE
    , p3_a22  VARCHAR2
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  DATE
    , p3_a26  NUMBER
    , p3_a27  NUMBER
    , p3_a28  NUMBER
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  DATE
    , p3_a41  NUMBER
    , p3_a42  NUMBER
    , p3_a43  DATE
    , p3_a44  NUMBER
    , p3_a45  VARCHAR2
    , p3_a46  NUMBER
    , p3_a47  VARCHAR2
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  NUMBER
    , p3_a52  VARCHAR2
    , p3_a53  NUMBER
    , p3_a54  NUMBER
    , p3_a55  VARCHAR2
    , p3_a56  NUMBER
    , p3_a57  NUMBER
    , p3_a58  VARCHAR2
    , p3_a59  NUMBER
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
    , p3_a62  NUMBER
    , p3_a63  NUMBER
    , p3_a64  NUMBER
    , p3_a65  NUMBER
    , p3_a66  NUMBER
    , p3_a67  NUMBER
    , p3_a68  DATE
    , p3_a69  VARCHAR2
    , p3_a70  NUMBER
    , p3_a71  NUMBER
    , p3_a72  VARCHAR2
    , p3_a73  NUMBER
    , p3_a74  NUMBER
    , p3_a75  DATE
    , p3_a76  VARCHAR2
    , p3_a77  NUMBER
    , p3_a78  VARCHAR2
    , p3_a79  NUMBER
    , p3_a80  VARCHAR2
    , p3_a81  DATE
    , p3_a82  VARCHAR2
    , p3_a83  VARCHAR2
    , p3_a84  DATE
    , p3_a85  NUMBER
    , p3_a86  DATE
    , p3_a87  NUMBER
    , p3_a88  DATE
    , p3_a89  NUMBER
    , p3_a90  NUMBER
    , p3_a91  NUMBER
    , p3_a92  NUMBER
    , p3_a93  VARCHAR2
    , p3_a94  NUMBER
    , p3_a95  DATE
    , p3_a96  NUMBER
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
    , p3_a129  VARCHAR2
    , p3_a130  NUMBER
    , p3_a131  VARCHAR2
    , p3_a132  NUMBER
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  NUMBER
    , p3_a136  NUMBER
    , p3_a137  NUMBER
    , p3_a138  VARCHAR2
    , p3_a139  NUMBER
    , p3_a140  NUMBER
    , p3_a141  VARCHAR2
    , p3_a142  VARCHAR2
    , p3_a143  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_claims_history_rec ozf_claims_history_pvt.claims_history_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_claims_history_rec.claim_history_id := p3_a0;
    ddp_claims_history_rec.object_version_number := p3_a1;
    ddp_claims_history_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_claims_history_rec.last_updated_by := p3_a3;
    ddp_claims_history_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_claims_history_rec.created_by := p3_a5;
    ddp_claims_history_rec.last_update_login := p3_a6;
    ddp_claims_history_rec.request_id := p3_a7;
    ddp_claims_history_rec.program_application_id := p3_a8;
    ddp_claims_history_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_claims_history_rec.program_id := p3_a10;
    ddp_claims_history_rec.created_from := p3_a11;
    ddp_claims_history_rec.batch_id := p3_a12;
    ddp_claims_history_rec.claim_id := p3_a13;
    ddp_claims_history_rec.claim_number := p3_a14;
    ddp_claims_history_rec.claim_type_id := p3_a15;
    ddp_claims_history_rec.claim_class := p3_a16;
    ddp_claims_history_rec.claim_date := rosetta_g_miss_date_in_map(p3_a17);
    ddp_claims_history_rec.due_date := rosetta_g_miss_date_in_map(p3_a18);
    ddp_claims_history_rec.owner_id := p3_a19;
    ddp_claims_history_rec.history_event := p3_a20;
    ddp_claims_history_rec.history_event_date := rosetta_g_miss_date_in_map(p3_a21);
    ddp_claims_history_rec.history_event_description := p3_a22;
    ddp_claims_history_rec.split_from_claim_id := p3_a23;
    ddp_claims_history_rec.duplicate_claim_id := p3_a24;
    ddp_claims_history_rec.split_date := rosetta_g_miss_date_in_map(p3_a25);
    ddp_claims_history_rec.root_claim_id := p3_a26;
    ddp_claims_history_rec.amount := p3_a27;
    ddp_claims_history_rec.amount_adjusted := p3_a28;
    ddp_claims_history_rec.amount_remaining := p3_a29;
    ddp_claims_history_rec.amount_settled := p3_a30;
    ddp_claims_history_rec.acctd_amount := p3_a31;
    ddp_claims_history_rec.acctd_amount_remaining := p3_a32;
    ddp_claims_history_rec.acctd_amount_adjusted := p3_a33;
    ddp_claims_history_rec.acctd_amount_settled := p3_a34;
    ddp_claims_history_rec.tax_amount := p3_a35;
    ddp_claims_history_rec.tax_code := p3_a36;
    ddp_claims_history_rec.tax_calculation_flag := p3_a37;
    ddp_claims_history_rec.currency_code := p3_a38;
    ddp_claims_history_rec.exchange_rate_type := p3_a39;
    ddp_claims_history_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p3_a40);
    ddp_claims_history_rec.exchange_rate := p3_a41;
    ddp_claims_history_rec.set_of_books_id := p3_a42;
    ddp_claims_history_rec.original_claim_date := rosetta_g_miss_date_in_map(p3_a43);
    ddp_claims_history_rec.source_object_id := p3_a44;
    ddp_claims_history_rec.source_object_class := p3_a45;
    ddp_claims_history_rec.source_object_type_id := p3_a46;
    ddp_claims_history_rec.source_object_number := p3_a47;
    ddp_claims_history_rec.cust_account_id := p3_a48;
    ddp_claims_history_rec.cust_billto_acct_site_id := p3_a49;
    ddp_claims_history_rec.cust_shipto_acct_site_id := p3_a50;
    ddp_claims_history_rec.location_id := p3_a51;
    ddp_claims_history_rec.pay_related_account_flag := p3_a52;
    ddp_claims_history_rec.related_cust_account_id := p3_a53;
    ddp_claims_history_rec.related_site_use_id := p3_a54;
    ddp_claims_history_rec.relationship_type := p3_a55;
    ddp_claims_history_rec.vendor_id := p3_a56;
    ddp_claims_history_rec.vendor_site_id := p3_a57;
    ddp_claims_history_rec.reason_type := p3_a58;
    ddp_claims_history_rec.reason_code_id := p3_a59;
    ddp_claims_history_rec.task_template_group_id := p3_a60;
    ddp_claims_history_rec.status_code := p3_a61;
    ddp_claims_history_rec.user_status_id := p3_a62;
    ddp_claims_history_rec.sales_rep_id := p3_a63;
    ddp_claims_history_rec.collector_id := p3_a64;
    ddp_claims_history_rec.contact_id := p3_a65;
    ddp_claims_history_rec.broker_id := p3_a66;
    ddp_claims_history_rec.territory_id := p3_a67;
    ddp_claims_history_rec.customer_ref_date := rosetta_g_miss_date_in_map(p3_a68);
    ddp_claims_history_rec.customer_ref_number := p3_a69;
    ddp_claims_history_rec.assigned_to := p3_a70;
    ddp_claims_history_rec.receipt_id := p3_a71;
    ddp_claims_history_rec.receipt_number := p3_a72;
    ddp_claims_history_rec.doc_sequence_id := p3_a73;
    ddp_claims_history_rec.doc_sequence_value := p3_a74;
    ddp_claims_history_rec.gl_date := rosetta_g_miss_date_in_map(p3_a75);
    ddp_claims_history_rec.payment_method := p3_a76;
    ddp_claims_history_rec.voucher_id := p3_a77;
    ddp_claims_history_rec.voucher_number := p3_a78;
    ddp_claims_history_rec.payment_reference_id := p3_a79;
    ddp_claims_history_rec.payment_reference_number := p3_a80;
    ddp_claims_history_rec.payment_reference_date := rosetta_g_miss_date_in_map(p3_a81);
    ddp_claims_history_rec.payment_status := p3_a82;
    ddp_claims_history_rec.approved_flag := p3_a83;
    ddp_claims_history_rec.approved_date := rosetta_g_miss_date_in_map(p3_a84);
    ddp_claims_history_rec.approved_by := p3_a85;
    ddp_claims_history_rec.settled_date := rosetta_g_miss_date_in_map(p3_a86);
    ddp_claims_history_rec.settled_by := p3_a87;
    ddp_claims_history_rec.effective_date := rosetta_g_miss_date_in_map(p3_a88);
    ddp_claims_history_rec.custom_setup_id := p3_a89;
    ddp_claims_history_rec.task_id := p3_a90;
    ddp_claims_history_rec.country_id := p3_a91;
    ddp_claims_history_rec.order_type_id := p3_a92;
    ddp_claims_history_rec.comments := p3_a93;
    ddp_claims_history_rec.letter_id := p3_a94;
    ddp_claims_history_rec.letter_date := rosetta_g_miss_date_in_map(p3_a95);
    ddp_claims_history_rec.task_source_object_id := p3_a96;
    ddp_claims_history_rec.task_source_object_type_code := p3_a97;
    ddp_claims_history_rec.attribute_category := p3_a98;
    ddp_claims_history_rec.attribute1 := p3_a99;
    ddp_claims_history_rec.attribute2 := p3_a100;
    ddp_claims_history_rec.attribute3 := p3_a101;
    ddp_claims_history_rec.attribute4 := p3_a102;
    ddp_claims_history_rec.attribute5 := p3_a103;
    ddp_claims_history_rec.attribute6 := p3_a104;
    ddp_claims_history_rec.attribute7 := p3_a105;
    ddp_claims_history_rec.attribute8 := p3_a106;
    ddp_claims_history_rec.attribute9 := p3_a107;
    ddp_claims_history_rec.attribute10 := p3_a108;
    ddp_claims_history_rec.attribute11 := p3_a109;
    ddp_claims_history_rec.attribute12 := p3_a110;
    ddp_claims_history_rec.attribute13 := p3_a111;
    ddp_claims_history_rec.attribute14 := p3_a112;
    ddp_claims_history_rec.attribute15 := p3_a113;
    ddp_claims_history_rec.deduction_attribute_category := p3_a114;
    ddp_claims_history_rec.deduction_attribute1 := p3_a115;
    ddp_claims_history_rec.deduction_attribute2 := p3_a116;
    ddp_claims_history_rec.deduction_attribute3 := p3_a117;
    ddp_claims_history_rec.deduction_attribute4 := p3_a118;
    ddp_claims_history_rec.deduction_attribute5 := p3_a119;
    ddp_claims_history_rec.deduction_attribute6 := p3_a120;
    ddp_claims_history_rec.deduction_attribute7 := p3_a121;
    ddp_claims_history_rec.deduction_attribute8 := p3_a122;
    ddp_claims_history_rec.deduction_attribute9 := p3_a123;
    ddp_claims_history_rec.deduction_attribute10 := p3_a124;
    ddp_claims_history_rec.deduction_attribute11 := p3_a125;
    ddp_claims_history_rec.deduction_attribute12 := p3_a126;
    ddp_claims_history_rec.deduction_attribute13 := p3_a127;
    ddp_claims_history_rec.deduction_attribute14 := p3_a128;
    ddp_claims_history_rec.deduction_attribute15 := p3_a129;
    ddp_claims_history_rec.org_id := p3_a130;
    ddp_claims_history_rec.write_off_flag := p3_a131;
    ddp_claims_history_rec.write_off_threshold_amount := p3_a132;
    ddp_claims_history_rec.under_write_off_threshold := p3_a133;
    ddp_claims_history_rec.customer_reason := p3_a134;
    ddp_claims_history_rec.ship_to_cust_account_id := p3_a135;
    ddp_claims_history_rec.amount_applied := p3_a136;
    ddp_claims_history_rec.applied_receipt_id := p3_a137;
    ddp_claims_history_rec.applied_receipt_number := p3_a138;
    ddp_claims_history_rec.wo_rec_trx_id := p3_a139;
    ddp_claims_history_rec.group_claim_id := p3_a140;
    ddp_claims_history_rec.appr_wf_item_key := p3_a141;
    ddp_claims_history_rec.cstl_wf_item_key := p3_a142;
    ddp_claims_history_rec.batch_type := p3_a143;




    -- here's the delegated call to the old PL/SQL routine
    ozf_claims_history_pvt.validate_claims_history(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_claims_history_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end ozf_claims_history_pvt_w;

/
