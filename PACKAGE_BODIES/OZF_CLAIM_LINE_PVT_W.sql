--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_LINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_LINE_PVT_W" as
  /* $Header: ozfwclnb.pls 120.1 2007/12/26 10:36:36 kpatro ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy ozf_claim_line_pvt.claim_line_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_2000
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_200
    , a65 JTF_VARCHAR2_TABLE_200
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_200
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_VARCHAR2_TABLE_200
    , a72 JTF_VARCHAR2_TABLE_200
    , a73 JTF_VARCHAR2_TABLE_200
    , a74 JTF_VARCHAR2_TABLE_200
    , a75 JTF_VARCHAR2_TABLE_200
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_DATE_TABLE
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_DATE_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).claim_line_id := a0(indx);
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
          t(ddindx).claim_id := a12(indx);
          t(ddindx).line_number := a13(indx);
          t(ddindx).split_from_claim_line_id := a14(indx);
          t(ddindx).amount := a15(indx);
          t(ddindx).claim_currency_amount := a16(indx);
          t(ddindx).acctd_amount := a17(indx);
          t(ddindx).currency_code := a18(indx);
          t(ddindx).exchange_rate_type := a19(indx);
          t(ddindx).exchange_rate_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).exchange_rate := a21(indx);
          t(ddindx).set_of_books_id := a22(indx);
          t(ddindx).valid_flag := a23(indx);
          t(ddindx).source_object_id := a24(indx);
          t(ddindx).source_object_line_id := a25(indx);
          t(ddindx).source_object_class := a26(indx);
          t(ddindx).source_object_type_id := a27(indx);
          t(ddindx).plan_id := a28(indx);
          t(ddindx).offer_id := a29(indx);
          t(ddindx).utilization_id := a30(indx);
          t(ddindx).payment_method := a31(indx);
          t(ddindx).payment_reference_id := a32(indx);
          t(ddindx).payment_reference_number := a33(indx);
          t(ddindx).payment_reference_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).voucher_id := a35(indx);
          t(ddindx).voucher_number := a36(indx);
          t(ddindx).payment_status := a37(indx);
          t(ddindx).approved_flag := a38(indx);
          t(ddindx).approved_date := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).approved_by := a40(indx);
          t(ddindx).settled_date := rosetta_g_miss_date_in_map(a41(indx));
          t(ddindx).settled_by := a42(indx);
          t(ddindx).performance_complete_flag := a43(indx);
          t(ddindx).performance_attached_flag := a44(indx);
          t(ddindx).select_cust_children_flag := a45(indx);
          t(ddindx).item_id := a46(indx);
          t(ddindx).item_description := a47(indx);
          t(ddindx).quantity := a48(indx);
          t(ddindx).quantity_uom := a49(indx);
          t(ddindx).rate := a50(indx);
          t(ddindx).activity_type := a51(indx);
          t(ddindx).activity_id := a52(indx);
          t(ddindx).related_cust_account_id := a53(indx);
          t(ddindx).buy_group_cust_account_id := a54(indx);
          t(ddindx).relationship_type := a55(indx);
          t(ddindx).earnings_associated_flag := a56(indx);
          t(ddindx).comments := a57(indx);
          t(ddindx).tax_code := a58(indx);
          t(ddindx).credit_to := a59(indx);
          t(ddindx).attribute_category := a60(indx);
          t(ddindx).attribute1 := a61(indx);
          t(ddindx).attribute2 := a62(indx);
          t(ddindx).attribute3 := a63(indx);
          t(ddindx).attribute4 := a64(indx);
          t(ddindx).attribute5 := a65(indx);
          t(ddindx).attribute6 := a66(indx);
          t(ddindx).attribute7 := a67(indx);
          t(ddindx).attribute8 := a68(indx);
          t(ddindx).attribute9 := a69(indx);
          t(ddindx).attribute10 := a70(indx);
          t(ddindx).attribute11 := a71(indx);
          t(ddindx).attribute12 := a72(indx);
          t(ddindx).attribute13 := a73(indx);
          t(ddindx).attribute14 := a74(indx);
          t(ddindx).attribute15 := a75(indx);
          t(ddindx).org_id := a76(indx);
          t(ddindx).update_from_tbl_flag := a77(indx);
          t(ddindx).tax_action := a78(indx);
          t(ddindx).sale_date := rosetta_g_miss_date_in_map(a79(indx));
          t(ddindx).item_type := a80(indx);
          t(ddindx).tax_amount := a81(indx);
          t(ddindx).claim_curr_tax_amount := a82(indx);
          t(ddindx).activity_line_id := a83(indx);
          t(ddindx).offer_type := a84(indx);
          t(ddindx).prorate_earnings_flag := a85(indx);
          t(ddindx).earnings_end_date := rosetta_g_miss_date_in_map(a86(indx));
          t(ddindx).buy_group_party_id := a87(indx);
          t(ddindx).acctd_tax_amount := a88(indx);
          t(ddindx).dpp_cust_account_id := a89(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_claim_line_pvt.claim_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_200
    , a65 out nocopy JTF_VARCHAR2_TABLE_200
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_200
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_VARCHAR2_TABLE_200
    , a72 out nocopy JTF_VARCHAR2_TABLE_200
    , a73 out nocopy JTF_VARCHAR2_TABLE_200
    , a74 out nocopy JTF_VARCHAR2_TABLE_200
    , a75 out nocopy JTF_VARCHAR2_TABLE_200
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_DATE_TABLE
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_NUMBER_TABLE
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_VARCHAR2_TABLE_100
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_VARCHAR2_TABLE_100
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
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_2000();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_200();
    a64 := JTF_VARCHAR2_TABLE_200();
    a65 := JTF_VARCHAR2_TABLE_200();
    a66 := JTF_VARCHAR2_TABLE_200();
    a67 := JTF_VARCHAR2_TABLE_200();
    a68 := JTF_VARCHAR2_TABLE_200();
    a69 := JTF_VARCHAR2_TABLE_200();
    a70 := JTF_VARCHAR2_TABLE_200();
    a71 := JTF_VARCHAR2_TABLE_200();
    a72 := JTF_VARCHAR2_TABLE_200();
    a73 := JTF_VARCHAR2_TABLE_200();
    a74 := JTF_VARCHAR2_TABLE_200();
    a75 := JTF_VARCHAR2_TABLE_200();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_DATE_TABLE();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_VARCHAR2_TABLE_100();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_DATE_TABLE();
    a87 := JTF_NUMBER_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_VARCHAR2_TABLE_100();
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
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_2000();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_200();
      a64 := JTF_VARCHAR2_TABLE_200();
      a65 := JTF_VARCHAR2_TABLE_200();
      a66 := JTF_VARCHAR2_TABLE_200();
      a67 := JTF_VARCHAR2_TABLE_200();
      a68 := JTF_VARCHAR2_TABLE_200();
      a69 := JTF_VARCHAR2_TABLE_200();
      a70 := JTF_VARCHAR2_TABLE_200();
      a71 := JTF_VARCHAR2_TABLE_200();
      a72 := JTF_VARCHAR2_TABLE_200();
      a73 := JTF_VARCHAR2_TABLE_200();
      a74 := JTF_VARCHAR2_TABLE_200();
      a75 := JTF_VARCHAR2_TABLE_200();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_DATE_TABLE();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_VARCHAR2_TABLE_100();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_DATE_TABLE();
      a87 := JTF_NUMBER_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).claim_line_id;
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
          a12(indx) := t(ddindx).claim_id;
          a13(indx) := t(ddindx).line_number;
          a14(indx) := t(ddindx).split_from_claim_line_id;
          a15(indx) := t(ddindx).amount;
          a16(indx) := t(ddindx).claim_currency_amount;
          a17(indx) := t(ddindx).acctd_amount;
          a18(indx) := t(ddindx).currency_code;
          a19(indx) := t(ddindx).exchange_rate_type;
          a20(indx) := t(ddindx).exchange_rate_date;
          a21(indx) := t(ddindx).exchange_rate;
          a22(indx) := t(ddindx).set_of_books_id;
          a23(indx) := t(ddindx).valid_flag;
          a24(indx) := t(ddindx).source_object_id;
          a25(indx) := t(ddindx).source_object_line_id;
          a26(indx) := t(ddindx).source_object_class;
          a27(indx) := t(ddindx).source_object_type_id;
          a28(indx) := t(ddindx).plan_id;
          a29(indx) := t(ddindx).offer_id;
          a30(indx) := t(ddindx).utilization_id;
          a31(indx) := t(ddindx).payment_method;
          a32(indx) := t(ddindx).payment_reference_id;
          a33(indx) := t(ddindx).payment_reference_number;
          a34(indx) := t(ddindx).payment_reference_date;
          a35(indx) := t(ddindx).voucher_id;
          a36(indx) := t(ddindx).voucher_number;
          a37(indx) := t(ddindx).payment_status;
          a38(indx) := t(ddindx).approved_flag;
          a39(indx) := t(ddindx).approved_date;
          a40(indx) := t(ddindx).approved_by;
          a41(indx) := t(ddindx).settled_date;
          a42(indx) := t(ddindx).settled_by;
          a43(indx) := t(ddindx).performance_complete_flag;
          a44(indx) := t(ddindx).performance_attached_flag;
          a45(indx) := t(ddindx).select_cust_children_flag;
          a46(indx) := t(ddindx).item_id;
          a47(indx) := t(ddindx).item_description;
          a48(indx) := t(ddindx).quantity;
          a49(indx) := t(ddindx).quantity_uom;
          a50(indx) := t(ddindx).rate;
          a51(indx) := t(ddindx).activity_type;
          a52(indx) := t(ddindx).activity_id;
          a53(indx) := t(ddindx).related_cust_account_id;
          a54(indx) := t(ddindx).buy_group_cust_account_id;
          a55(indx) := t(ddindx).relationship_type;
          a56(indx) := t(ddindx).earnings_associated_flag;
          a57(indx) := t(ddindx).comments;
          a58(indx) := t(ddindx).tax_code;
          a59(indx) := t(ddindx).credit_to;
          a60(indx) := t(ddindx).attribute_category;
          a61(indx) := t(ddindx).attribute1;
          a62(indx) := t(ddindx).attribute2;
          a63(indx) := t(ddindx).attribute3;
          a64(indx) := t(ddindx).attribute4;
          a65(indx) := t(ddindx).attribute5;
          a66(indx) := t(ddindx).attribute6;
          a67(indx) := t(ddindx).attribute7;
          a68(indx) := t(ddindx).attribute8;
          a69(indx) := t(ddindx).attribute9;
          a70(indx) := t(ddindx).attribute10;
          a71(indx) := t(ddindx).attribute11;
          a72(indx) := t(ddindx).attribute12;
          a73(indx) := t(ddindx).attribute13;
          a74(indx) := t(ddindx).attribute14;
          a75(indx) := t(ddindx).attribute15;
          a76(indx) := t(ddindx).org_id;
          a77(indx) := t(ddindx).update_from_tbl_flag;
          a78(indx) := t(ddindx).tax_action;
          a79(indx) := t(ddindx).sale_date;
          a80(indx) := t(ddindx).item_type;
          a81(indx) := t(ddindx).tax_amount;
          a82(indx) := t(ddindx).claim_curr_tax_amount;
          a83(indx) := t(ddindx).activity_line_id;
          a84(indx) := t(ddindx).offer_type;
          a85(indx) := t(ddindx).prorate_earnings_flag;
          a86(indx) := t(ddindx).earnings_end_date;
          a87(indx) := t(ddindx).buy_group_party_id;
          a88(indx) := t(ddindx).acctd_tax_amount;
          a89(indx) := t(ddindx).dpp_cust_account_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure check_create_line_hist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
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
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  VARCHAR2
    , p6_a32  NUMBER
    , p6_a33  VARCHAR2
    , p6_a34  DATE
    , p6_a35  NUMBER
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  DATE
    , p6_a40  NUMBER
    , p6_a41  DATE
    , p6_a42  NUMBER
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  NUMBER
    , p6_a47  VARCHAR2
    , p6_a48  NUMBER
    , p6_a49  VARCHAR2
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  NUMBER
    , p6_a55  VARCHAR2
    , p6_a56  VARCHAR2
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  VARCHAR2
    , p6_a61  VARCHAR2
    , p6_a62  VARCHAR2
    , p6_a63  VARCHAR2
    , p6_a64  VARCHAR2
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  VARCHAR2
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  VARCHAR2
    , p6_a74  VARCHAR2
    , p6_a75  VARCHAR2
    , p6_a76  NUMBER
    , p6_a77  VARCHAR2
    , p6_a78  VARCHAR2
    , p6_a79  DATE
    , p6_a80  VARCHAR2
    , p6_a81  NUMBER
    , p6_a82  NUMBER
    , p6_a83  NUMBER
    , p6_a84  VARCHAR2
    , p6_a85  VARCHAR2
    , p6_a86  DATE
    , p6_a87  NUMBER
    , p6_a88  NUMBER
    , p6_a89  VARCHAR2
    , p_object_attribute  VARCHAR2
    , x_create_hist_flag out nocopy  VARCHAR2
  )

  as
    ddp_claim_line_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_claim_line_rec.claim_line_id := p6_a0;
    ddp_claim_line_rec.object_version_number := p6_a1;
    ddp_claim_line_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_claim_line_rec.last_updated_by := p6_a3;
    ddp_claim_line_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_claim_line_rec.created_by := p6_a5;
    ddp_claim_line_rec.last_update_login := p6_a6;
    ddp_claim_line_rec.request_id := p6_a7;
    ddp_claim_line_rec.program_application_id := p6_a8;
    ddp_claim_line_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_claim_line_rec.program_id := p6_a10;
    ddp_claim_line_rec.created_from := p6_a11;
    ddp_claim_line_rec.claim_id := p6_a12;
    ddp_claim_line_rec.line_number := p6_a13;
    ddp_claim_line_rec.split_from_claim_line_id := p6_a14;
    ddp_claim_line_rec.amount := p6_a15;
    ddp_claim_line_rec.claim_currency_amount := p6_a16;
    ddp_claim_line_rec.acctd_amount := p6_a17;
    ddp_claim_line_rec.currency_code := p6_a18;
    ddp_claim_line_rec.exchange_rate_type := p6_a19;
    ddp_claim_line_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p6_a20);
    ddp_claim_line_rec.exchange_rate := p6_a21;
    ddp_claim_line_rec.set_of_books_id := p6_a22;
    ddp_claim_line_rec.valid_flag := p6_a23;
    ddp_claim_line_rec.source_object_id := p6_a24;
    ddp_claim_line_rec.source_object_line_id := p6_a25;
    ddp_claim_line_rec.source_object_class := p6_a26;
    ddp_claim_line_rec.source_object_type_id := p6_a27;
    ddp_claim_line_rec.plan_id := p6_a28;
    ddp_claim_line_rec.offer_id := p6_a29;
    ddp_claim_line_rec.utilization_id := p6_a30;
    ddp_claim_line_rec.payment_method := p6_a31;
    ddp_claim_line_rec.payment_reference_id := p6_a32;
    ddp_claim_line_rec.payment_reference_number := p6_a33;
    ddp_claim_line_rec.payment_reference_date := rosetta_g_miss_date_in_map(p6_a34);
    ddp_claim_line_rec.voucher_id := p6_a35;
    ddp_claim_line_rec.voucher_number := p6_a36;
    ddp_claim_line_rec.payment_status := p6_a37;
    ddp_claim_line_rec.approved_flag := p6_a38;
    ddp_claim_line_rec.approved_date := rosetta_g_miss_date_in_map(p6_a39);
    ddp_claim_line_rec.approved_by := p6_a40;
    ddp_claim_line_rec.settled_date := rosetta_g_miss_date_in_map(p6_a41);
    ddp_claim_line_rec.settled_by := p6_a42;
    ddp_claim_line_rec.performance_complete_flag := p6_a43;
    ddp_claim_line_rec.performance_attached_flag := p6_a44;
    ddp_claim_line_rec.select_cust_children_flag := p6_a45;
    ddp_claim_line_rec.item_id := p6_a46;
    ddp_claim_line_rec.item_description := p6_a47;
    ddp_claim_line_rec.quantity := p6_a48;
    ddp_claim_line_rec.quantity_uom := p6_a49;
    ddp_claim_line_rec.rate := p6_a50;
    ddp_claim_line_rec.activity_type := p6_a51;
    ddp_claim_line_rec.activity_id := p6_a52;
    ddp_claim_line_rec.related_cust_account_id := p6_a53;
    ddp_claim_line_rec.buy_group_cust_account_id := p6_a54;
    ddp_claim_line_rec.relationship_type := p6_a55;
    ddp_claim_line_rec.earnings_associated_flag := p6_a56;
    ddp_claim_line_rec.comments := p6_a57;
    ddp_claim_line_rec.tax_code := p6_a58;
    ddp_claim_line_rec.credit_to := p6_a59;
    ddp_claim_line_rec.attribute_category := p6_a60;
    ddp_claim_line_rec.attribute1 := p6_a61;
    ddp_claim_line_rec.attribute2 := p6_a62;
    ddp_claim_line_rec.attribute3 := p6_a63;
    ddp_claim_line_rec.attribute4 := p6_a64;
    ddp_claim_line_rec.attribute5 := p6_a65;
    ddp_claim_line_rec.attribute6 := p6_a66;
    ddp_claim_line_rec.attribute7 := p6_a67;
    ddp_claim_line_rec.attribute8 := p6_a68;
    ddp_claim_line_rec.attribute9 := p6_a69;
    ddp_claim_line_rec.attribute10 := p6_a70;
    ddp_claim_line_rec.attribute11 := p6_a71;
    ddp_claim_line_rec.attribute12 := p6_a72;
    ddp_claim_line_rec.attribute13 := p6_a73;
    ddp_claim_line_rec.attribute14 := p6_a74;
    ddp_claim_line_rec.attribute15 := p6_a75;
    ddp_claim_line_rec.org_id := p6_a76;
    ddp_claim_line_rec.update_from_tbl_flag := p6_a77;
    ddp_claim_line_rec.tax_action := p6_a78;
    ddp_claim_line_rec.sale_date := rosetta_g_miss_date_in_map(p6_a79);
    ddp_claim_line_rec.item_type := p6_a80;
    ddp_claim_line_rec.tax_amount := p6_a81;
    ddp_claim_line_rec.claim_curr_tax_amount := p6_a82;
    ddp_claim_line_rec.activity_line_id := p6_a83;
    ddp_claim_line_rec.offer_type := p6_a84;
    ddp_claim_line_rec.prorate_earnings_flag := p6_a85;
    ddp_claim_line_rec.earnings_end_date := rosetta_g_miss_date_in_map(p6_a86);
    ddp_claim_line_rec.buy_group_party_id := p6_a87;
    ddp_claim_line_rec.acctd_tax_amount := p6_a88;
    ddp_claim_line_rec.dpp_cust_account_id := p6_a89;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.check_create_line_hist(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_mode,
      ddp_claim_line_rec,
      p_object_attribute,
      x_create_hist_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure create_claim_line_tbl(p_api_version  NUMBER
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
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_VARCHAR2_TABLE_100
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_DATE_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_DATE_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_VARCHAR2_TABLE_100
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_VARCHAR2_TABLE_100
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_VARCHAR2_TABLE_300
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_VARCHAR2_TABLE_100
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_VARCHAR2_TABLE_2000
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_200
    , p7_a62 JTF_VARCHAR2_TABLE_200
    , p7_a63 JTF_VARCHAR2_TABLE_200
    , p7_a64 JTF_VARCHAR2_TABLE_200
    , p7_a65 JTF_VARCHAR2_TABLE_200
    , p7_a66 JTF_VARCHAR2_TABLE_200
    , p7_a67 JTF_VARCHAR2_TABLE_200
    , p7_a68 JTF_VARCHAR2_TABLE_200
    , p7_a69 JTF_VARCHAR2_TABLE_200
    , p7_a70 JTF_VARCHAR2_TABLE_200
    , p7_a71 JTF_VARCHAR2_TABLE_200
    , p7_a72 JTF_VARCHAR2_TABLE_200
    , p7_a73 JTF_VARCHAR2_TABLE_200
    , p7_a74 JTF_VARCHAR2_TABLE_200
    , p7_a75 JTF_VARCHAR2_TABLE_200
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_VARCHAR2_TABLE_100
    , p7_a79 JTF_DATE_TABLE
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_NUMBER_TABLE
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_VARCHAR2_TABLE_100
    , p7_a85 JTF_VARCHAR2_TABLE_100
    , p7_a86 JTF_DATE_TABLE
    , p7_a87 JTF_NUMBER_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_VARCHAR2_TABLE_100
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  )

  as
    ddp_claim_line_tbl ozf_claim_line_pvt.claim_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_claim_line_pvt_w.rosetta_table_copy_in_p1(ddp_claim_line_tbl, p7_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.create_claim_line_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_claim_line_tbl,
      p_mode,
      x_error_index);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure create_claim_line(p_api_version  NUMBER
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
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  DATE
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  DATE
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  DATE
    , p7_a80  VARCHAR2
    , p7_a81  NUMBER
    , p7_a82  NUMBER
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  DATE
    , p7_a87  NUMBER
    , p7_a88  NUMBER
    , p7_a89  VARCHAR2
    , p_mode  VARCHAR2
    , x_claim_line_id out nocopy  NUMBER
  )

  as
    ddp_claim_line_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claim_line_rec.claim_line_id := p7_a0;
    ddp_claim_line_rec.object_version_number := p7_a1;
    ddp_claim_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claim_line_rec.last_updated_by := p7_a3;
    ddp_claim_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claim_line_rec.created_by := p7_a5;
    ddp_claim_line_rec.last_update_login := p7_a6;
    ddp_claim_line_rec.request_id := p7_a7;
    ddp_claim_line_rec.program_application_id := p7_a8;
    ddp_claim_line_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claim_line_rec.program_id := p7_a10;
    ddp_claim_line_rec.created_from := p7_a11;
    ddp_claim_line_rec.claim_id := p7_a12;
    ddp_claim_line_rec.line_number := p7_a13;
    ddp_claim_line_rec.split_from_claim_line_id := p7_a14;
    ddp_claim_line_rec.amount := p7_a15;
    ddp_claim_line_rec.claim_currency_amount := p7_a16;
    ddp_claim_line_rec.acctd_amount := p7_a17;
    ddp_claim_line_rec.currency_code := p7_a18;
    ddp_claim_line_rec.exchange_rate_type := p7_a19;
    ddp_claim_line_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_claim_line_rec.exchange_rate := p7_a21;
    ddp_claim_line_rec.set_of_books_id := p7_a22;
    ddp_claim_line_rec.valid_flag := p7_a23;
    ddp_claim_line_rec.source_object_id := p7_a24;
    ddp_claim_line_rec.source_object_line_id := p7_a25;
    ddp_claim_line_rec.source_object_class := p7_a26;
    ddp_claim_line_rec.source_object_type_id := p7_a27;
    ddp_claim_line_rec.plan_id := p7_a28;
    ddp_claim_line_rec.offer_id := p7_a29;
    ddp_claim_line_rec.utilization_id := p7_a30;
    ddp_claim_line_rec.payment_method := p7_a31;
    ddp_claim_line_rec.payment_reference_id := p7_a32;
    ddp_claim_line_rec.payment_reference_number := p7_a33;
    ddp_claim_line_rec.payment_reference_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_claim_line_rec.voucher_id := p7_a35;
    ddp_claim_line_rec.voucher_number := p7_a36;
    ddp_claim_line_rec.payment_status := p7_a37;
    ddp_claim_line_rec.approved_flag := p7_a38;
    ddp_claim_line_rec.approved_date := rosetta_g_miss_date_in_map(p7_a39);
    ddp_claim_line_rec.approved_by := p7_a40;
    ddp_claim_line_rec.settled_date := rosetta_g_miss_date_in_map(p7_a41);
    ddp_claim_line_rec.settled_by := p7_a42;
    ddp_claim_line_rec.performance_complete_flag := p7_a43;
    ddp_claim_line_rec.performance_attached_flag := p7_a44;
    ddp_claim_line_rec.select_cust_children_flag := p7_a45;
    ddp_claim_line_rec.item_id := p7_a46;
    ddp_claim_line_rec.item_description := p7_a47;
    ddp_claim_line_rec.quantity := p7_a48;
    ddp_claim_line_rec.quantity_uom := p7_a49;
    ddp_claim_line_rec.rate := p7_a50;
    ddp_claim_line_rec.activity_type := p7_a51;
    ddp_claim_line_rec.activity_id := p7_a52;
    ddp_claim_line_rec.related_cust_account_id := p7_a53;
    ddp_claim_line_rec.buy_group_cust_account_id := p7_a54;
    ddp_claim_line_rec.relationship_type := p7_a55;
    ddp_claim_line_rec.earnings_associated_flag := p7_a56;
    ddp_claim_line_rec.comments := p7_a57;
    ddp_claim_line_rec.tax_code := p7_a58;
    ddp_claim_line_rec.credit_to := p7_a59;
    ddp_claim_line_rec.attribute_category := p7_a60;
    ddp_claim_line_rec.attribute1 := p7_a61;
    ddp_claim_line_rec.attribute2 := p7_a62;
    ddp_claim_line_rec.attribute3 := p7_a63;
    ddp_claim_line_rec.attribute4 := p7_a64;
    ddp_claim_line_rec.attribute5 := p7_a65;
    ddp_claim_line_rec.attribute6 := p7_a66;
    ddp_claim_line_rec.attribute7 := p7_a67;
    ddp_claim_line_rec.attribute8 := p7_a68;
    ddp_claim_line_rec.attribute9 := p7_a69;
    ddp_claim_line_rec.attribute10 := p7_a70;
    ddp_claim_line_rec.attribute11 := p7_a71;
    ddp_claim_line_rec.attribute12 := p7_a72;
    ddp_claim_line_rec.attribute13 := p7_a73;
    ddp_claim_line_rec.attribute14 := p7_a74;
    ddp_claim_line_rec.attribute15 := p7_a75;
    ddp_claim_line_rec.org_id := p7_a76;
    ddp_claim_line_rec.update_from_tbl_flag := p7_a77;
    ddp_claim_line_rec.tax_action := p7_a78;
    ddp_claim_line_rec.sale_date := rosetta_g_miss_date_in_map(p7_a79);
    ddp_claim_line_rec.item_type := p7_a80;
    ddp_claim_line_rec.tax_amount := p7_a81;
    ddp_claim_line_rec.claim_curr_tax_amount := p7_a82;
    ddp_claim_line_rec.activity_line_id := p7_a83;
    ddp_claim_line_rec.offer_type := p7_a84;
    ddp_claim_line_rec.prorate_earnings_flag := p7_a85;
    ddp_claim_line_rec.earnings_end_date := rosetta_g_miss_date_in_map(p7_a86);
    ddp_claim_line_rec.buy_group_party_id := p7_a87;
    ddp_claim_line_rec.acctd_tax_amount := p7_a88;
    ddp_claim_line_rec.dpp_cust_account_id := p7_a89;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.create_claim_line(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claim_line_rec,
      p_mode,
      x_claim_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure delete_claim_line_tbl(p_api_version  NUMBER
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
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_VARCHAR2_TABLE_100
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_DATE_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_DATE_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_VARCHAR2_TABLE_100
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_VARCHAR2_TABLE_100
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_VARCHAR2_TABLE_300
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_VARCHAR2_TABLE_100
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_VARCHAR2_TABLE_2000
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_200
    , p7_a62 JTF_VARCHAR2_TABLE_200
    , p7_a63 JTF_VARCHAR2_TABLE_200
    , p7_a64 JTF_VARCHAR2_TABLE_200
    , p7_a65 JTF_VARCHAR2_TABLE_200
    , p7_a66 JTF_VARCHAR2_TABLE_200
    , p7_a67 JTF_VARCHAR2_TABLE_200
    , p7_a68 JTF_VARCHAR2_TABLE_200
    , p7_a69 JTF_VARCHAR2_TABLE_200
    , p7_a70 JTF_VARCHAR2_TABLE_200
    , p7_a71 JTF_VARCHAR2_TABLE_200
    , p7_a72 JTF_VARCHAR2_TABLE_200
    , p7_a73 JTF_VARCHAR2_TABLE_200
    , p7_a74 JTF_VARCHAR2_TABLE_200
    , p7_a75 JTF_VARCHAR2_TABLE_200
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_VARCHAR2_TABLE_100
    , p7_a79 JTF_DATE_TABLE
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_NUMBER_TABLE
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_VARCHAR2_TABLE_100
    , p7_a85 JTF_VARCHAR2_TABLE_100
    , p7_a86 JTF_DATE_TABLE
    , p7_a87 JTF_NUMBER_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_VARCHAR2_TABLE_100
    , p_change_object_version  VARCHAR2
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  )

  as
    ddp_claim_line_tbl ozf_claim_line_pvt.claim_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_claim_line_pvt_w.rosetta_table_copy_in_p1(ddp_claim_line_tbl, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.delete_claim_line_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_claim_line_tbl,
      p_change_object_version,
      p_mode,
      x_error_index);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_claim_line_tbl(p_api_version  NUMBER
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
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_VARCHAR2_TABLE_100
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_VARCHAR2_TABLE_100
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_VARCHAR2_TABLE_100
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_VARCHAR2_TABLE_100
    , p7_a34 JTF_DATE_TABLE
    , p7_a35 JTF_NUMBER_TABLE
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_DATE_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_VARCHAR2_TABLE_100
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_VARCHAR2_TABLE_100
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_VARCHAR2_TABLE_300
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_VARCHAR2_TABLE_100
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_VARCHAR2_TABLE_2000
    , p7_a58 JTF_VARCHAR2_TABLE_100
    , p7_a59 JTF_VARCHAR2_TABLE_100
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_200
    , p7_a62 JTF_VARCHAR2_TABLE_200
    , p7_a63 JTF_VARCHAR2_TABLE_200
    , p7_a64 JTF_VARCHAR2_TABLE_200
    , p7_a65 JTF_VARCHAR2_TABLE_200
    , p7_a66 JTF_VARCHAR2_TABLE_200
    , p7_a67 JTF_VARCHAR2_TABLE_200
    , p7_a68 JTF_VARCHAR2_TABLE_200
    , p7_a69 JTF_VARCHAR2_TABLE_200
    , p7_a70 JTF_VARCHAR2_TABLE_200
    , p7_a71 JTF_VARCHAR2_TABLE_200
    , p7_a72 JTF_VARCHAR2_TABLE_200
    , p7_a73 JTF_VARCHAR2_TABLE_200
    , p7_a74 JTF_VARCHAR2_TABLE_200
    , p7_a75 JTF_VARCHAR2_TABLE_200
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_VARCHAR2_TABLE_100
    , p7_a79 JTF_DATE_TABLE
    , p7_a80 JTF_VARCHAR2_TABLE_100
    , p7_a81 JTF_NUMBER_TABLE
    , p7_a82 JTF_NUMBER_TABLE
    , p7_a83 JTF_NUMBER_TABLE
    , p7_a84 JTF_VARCHAR2_TABLE_100
    , p7_a85 JTF_VARCHAR2_TABLE_100
    , p7_a86 JTF_DATE_TABLE
    , p7_a87 JTF_NUMBER_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_VARCHAR2_TABLE_100
    , p_change_object_version  VARCHAR2
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  )

  as
    ddp_claim_line_tbl ozf_claim_line_pvt.claim_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_claim_line_pvt_w.rosetta_table_copy_in_p1(ddp_claim_line_tbl, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.update_claim_line_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_claim_line_tbl,
      p_change_object_version,
      p_mode,
      x_error_index);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_claim_line(p_api_version  NUMBER
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
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  DATE
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  DATE
    , p7_a42  NUMBER
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  DATE
    , p7_a80  VARCHAR2
    , p7_a81  NUMBER
    , p7_a82  NUMBER
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  DATE
    , p7_a87  NUMBER
    , p7_a88  NUMBER
    , p7_a89  VARCHAR2
    , p_mode  VARCHAR2
    , x_object_version out nocopy  NUMBER
  )

  as
    ddp_claim_line_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claim_line_rec.claim_line_id := p7_a0;
    ddp_claim_line_rec.object_version_number := p7_a1;
    ddp_claim_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claim_line_rec.last_updated_by := p7_a3;
    ddp_claim_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claim_line_rec.created_by := p7_a5;
    ddp_claim_line_rec.last_update_login := p7_a6;
    ddp_claim_line_rec.request_id := p7_a7;
    ddp_claim_line_rec.program_application_id := p7_a8;
    ddp_claim_line_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claim_line_rec.program_id := p7_a10;
    ddp_claim_line_rec.created_from := p7_a11;
    ddp_claim_line_rec.claim_id := p7_a12;
    ddp_claim_line_rec.line_number := p7_a13;
    ddp_claim_line_rec.split_from_claim_line_id := p7_a14;
    ddp_claim_line_rec.amount := p7_a15;
    ddp_claim_line_rec.claim_currency_amount := p7_a16;
    ddp_claim_line_rec.acctd_amount := p7_a17;
    ddp_claim_line_rec.currency_code := p7_a18;
    ddp_claim_line_rec.exchange_rate_type := p7_a19;
    ddp_claim_line_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p7_a20);
    ddp_claim_line_rec.exchange_rate := p7_a21;
    ddp_claim_line_rec.set_of_books_id := p7_a22;
    ddp_claim_line_rec.valid_flag := p7_a23;
    ddp_claim_line_rec.source_object_id := p7_a24;
    ddp_claim_line_rec.source_object_line_id := p7_a25;
    ddp_claim_line_rec.source_object_class := p7_a26;
    ddp_claim_line_rec.source_object_type_id := p7_a27;
    ddp_claim_line_rec.plan_id := p7_a28;
    ddp_claim_line_rec.offer_id := p7_a29;
    ddp_claim_line_rec.utilization_id := p7_a30;
    ddp_claim_line_rec.payment_method := p7_a31;
    ddp_claim_line_rec.payment_reference_id := p7_a32;
    ddp_claim_line_rec.payment_reference_number := p7_a33;
    ddp_claim_line_rec.payment_reference_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_claim_line_rec.voucher_id := p7_a35;
    ddp_claim_line_rec.voucher_number := p7_a36;
    ddp_claim_line_rec.payment_status := p7_a37;
    ddp_claim_line_rec.approved_flag := p7_a38;
    ddp_claim_line_rec.approved_date := rosetta_g_miss_date_in_map(p7_a39);
    ddp_claim_line_rec.approved_by := p7_a40;
    ddp_claim_line_rec.settled_date := rosetta_g_miss_date_in_map(p7_a41);
    ddp_claim_line_rec.settled_by := p7_a42;
    ddp_claim_line_rec.performance_complete_flag := p7_a43;
    ddp_claim_line_rec.performance_attached_flag := p7_a44;
    ddp_claim_line_rec.select_cust_children_flag := p7_a45;
    ddp_claim_line_rec.item_id := p7_a46;
    ddp_claim_line_rec.item_description := p7_a47;
    ddp_claim_line_rec.quantity := p7_a48;
    ddp_claim_line_rec.quantity_uom := p7_a49;
    ddp_claim_line_rec.rate := p7_a50;
    ddp_claim_line_rec.activity_type := p7_a51;
    ddp_claim_line_rec.activity_id := p7_a52;
    ddp_claim_line_rec.related_cust_account_id := p7_a53;
    ddp_claim_line_rec.buy_group_cust_account_id := p7_a54;
    ddp_claim_line_rec.relationship_type := p7_a55;
    ddp_claim_line_rec.earnings_associated_flag := p7_a56;
    ddp_claim_line_rec.comments := p7_a57;
    ddp_claim_line_rec.tax_code := p7_a58;
    ddp_claim_line_rec.credit_to := p7_a59;
    ddp_claim_line_rec.attribute_category := p7_a60;
    ddp_claim_line_rec.attribute1 := p7_a61;
    ddp_claim_line_rec.attribute2 := p7_a62;
    ddp_claim_line_rec.attribute3 := p7_a63;
    ddp_claim_line_rec.attribute4 := p7_a64;
    ddp_claim_line_rec.attribute5 := p7_a65;
    ddp_claim_line_rec.attribute6 := p7_a66;
    ddp_claim_line_rec.attribute7 := p7_a67;
    ddp_claim_line_rec.attribute8 := p7_a68;
    ddp_claim_line_rec.attribute9 := p7_a69;
    ddp_claim_line_rec.attribute10 := p7_a70;
    ddp_claim_line_rec.attribute11 := p7_a71;
    ddp_claim_line_rec.attribute12 := p7_a72;
    ddp_claim_line_rec.attribute13 := p7_a73;
    ddp_claim_line_rec.attribute14 := p7_a74;
    ddp_claim_line_rec.attribute15 := p7_a75;
    ddp_claim_line_rec.org_id := p7_a76;
    ddp_claim_line_rec.update_from_tbl_flag := p7_a77;
    ddp_claim_line_rec.tax_action := p7_a78;
    ddp_claim_line_rec.sale_date := rosetta_g_miss_date_in_map(p7_a79);
    ddp_claim_line_rec.item_type := p7_a80;
    ddp_claim_line_rec.tax_amount := p7_a81;
    ddp_claim_line_rec.claim_curr_tax_amount := p7_a82;
    ddp_claim_line_rec.activity_line_id := p7_a83;
    ddp_claim_line_rec.offer_type := p7_a84;
    ddp_claim_line_rec.prorate_earnings_flag := p7_a85;
    ddp_claim_line_rec.earnings_end_date := rosetta_g_miss_date_in_map(p7_a86);
    ddp_claim_line_rec.buy_group_party_id := p7_a87;
    ddp_claim_line_rec.acctd_tax_amount := p7_a88;
    ddp_claim_line_rec.dpp_cust_account_id := p7_a89;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.update_claim_line(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claim_line_rec,
      p_mode,
      x_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure validate_claim_line(p_api_version  NUMBER
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
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  VARCHAR2
    , p6_a32  NUMBER
    , p6_a33  VARCHAR2
    , p6_a34  DATE
    , p6_a35  NUMBER
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  DATE
    , p6_a40  NUMBER
    , p6_a41  DATE
    , p6_a42  NUMBER
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  NUMBER
    , p6_a47  VARCHAR2
    , p6_a48  NUMBER
    , p6_a49  VARCHAR2
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  NUMBER
    , p6_a55  VARCHAR2
    , p6_a56  VARCHAR2
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  VARCHAR2
    , p6_a61  VARCHAR2
    , p6_a62  VARCHAR2
    , p6_a63  VARCHAR2
    , p6_a64  VARCHAR2
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  VARCHAR2
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  VARCHAR2
    , p6_a74  VARCHAR2
    , p6_a75  VARCHAR2
    , p6_a76  NUMBER
    , p6_a77  VARCHAR2
    , p6_a78  VARCHAR2
    , p6_a79  DATE
    , p6_a80  VARCHAR2
    , p6_a81  NUMBER
    , p6_a82  NUMBER
    , p6_a83  NUMBER
    , p6_a84  VARCHAR2
    , p6_a85  VARCHAR2
    , p6_a86  DATE
    , p6_a87  NUMBER
    , p6_a88  NUMBER
    , p6_a89  VARCHAR2
  )

  as
    ddp_claim_line_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_claim_line_rec.claim_line_id := p6_a0;
    ddp_claim_line_rec.object_version_number := p6_a1;
    ddp_claim_line_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_claim_line_rec.last_updated_by := p6_a3;
    ddp_claim_line_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_claim_line_rec.created_by := p6_a5;
    ddp_claim_line_rec.last_update_login := p6_a6;
    ddp_claim_line_rec.request_id := p6_a7;
    ddp_claim_line_rec.program_application_id := p6_a8;
    ddp_claim_line_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_claim_line_rec.program_id := p6_a10;
    ddp_claim_line_rec.created_from := p6_a11;
    ddp_claim_line_rec.claim_id := p6_a12;
    ddp_claim_line_rec.line_number := p6_a13;
    ddp_claim_line_rec.split_from_claim_line_id := p6_a14;
    ddp_claim_line_rec.amount := p6_a15;
    ddp_claim_line_rec.claim_currency_amount := p6_a16;
    ddp_claim_line_rec.acctd_amount := p6_a17;
    ddp_claim_line_rec.currency_code := p6_a18;
    ddp_claim_line_rec.exchange_rate_type := p6_a19;
    ddp_claim_line_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p6_a20);
    ddp_claim_line_rec.exchange_rate := p6_a21;
    ddp_claim_line_rec.set_of_books_id := p6_a22;
    ddp_claim_line_rec.valid_flag := p6_a23;
    ddp_claim_line_rec.source_object_id := p6_a24;
    ddp_claim_line_rec.source_object_line_id := p6_a25;
    ddp_claim_line_rec.source_object_class := p6_a26;
    ddp_claim_line_rec.source_object_type_id := p6_a27;
    ddp_claim_line_rec.plan_id := p6_a28;
    ddp_claim_line_rec.offer_id := p6_a29;
    ddp_claim_line_rec.utilization_id := p6_a30;
    ddp_claim_line_rec.payment_method := p6_a31;
    ddp_claim_line_rec.payment_reference_id := p6_a32;
    ddp_claim_line_rec.payment_reference_number := p6_a33;
    ddp_claim_line_rec.payment_reference_date := rosetta_g_miss_date_in_map(p6_a34);
    ddp_claim_line_rec.voucher_id := p6_a35;
    ddp_claim_line_rec.voucher_number := p6_a36;
    ddp_claim_line_rec.payment_status := p6_a37;
    ddp_claim_line_rec.approved_flag := p6_a38;
    ddp_claim_line_rec.approved_date := rosetta_g_miss_date_in_map(p6_a39);
    ddp_claim_line_rec.approved_by := p6_a40;
    ddp_claim_line_rec.settled_date := rosetta_g_miss_date_in_map(p6_a41);
    ddp_claim_line_rec.settled_by := p6_a42;
    ddp_claim_line_rec.performance_complete_flag := p6_a43;
    ddp_claim_line_rec.performance_attached_flag := p6_a44;
    ddp_claim_line_rec.select_cust_children_flag := p6_a45;
    ddp_claim_line_rec.item_id := p6_a46;
    ddp_claim_line_rec.item_description := p6_a47;
    ddp_claim_line_rec.quantity := p6_a48;
    ddp_claim_line_rec.quantity_uom := p6_a49;
    ddp_claim_line_rec.rate := p6_a50;
    ddp_claim_line_rec.activity_type := p6_a51;
    ddp_claim_line_rec.activity_id := p6_a52;
    ddp_claim_line_rec.related_cust_account_id := p6_a53;
    ddp_claim_line_rec.buy_group_cust_account_id := p6_a54;
    ddp_claim_line_rec.relationship_type := p6_a55;
    ddp_claim_line_rec.earnings_associated_flag := p6_a56;
    ddp_claim_line_rec.comments := p6_a57;
    ddp_claim_line_rec.tax_code := p6_a58;
    ddp_claim_line_rec.credit_to := p6_a59;
    ddp_claim_line_rec.attribute_category := p6_a60;
    ddp_claim_line_rec.attribute1 := p6_a61;
    ddp_claim_line_rec.attribute2 := p6_a62;
    ddp_claim_line_rec.attribute3 := p6_a63;
    ddp_claim_line_rec.attribute4 := p6_a64;
    ddp_claim_line_rec.attribute5 := p6_a65;
    ddp_claim_line_rec.attribute6 := p6_a66;
    ddp_claim_line_rec.attribute7 := p6_a67;
    ddp_claim_line_rec.attribute8 := p6_a68;
    ddp_claim_line_rec.attribute9 := p6_a69;
    ddp_claim_line_rec.attribute10 := p6_a70;
    ddp_claim_line_rec.attribute11 := p6_a71;
    ddp_claim_line_rec.attribute12 := p6_a72;
    ddp_claim_line_rec.attribute13 := p6_a73;
    ddp_claim_line_rec.attribute14 := p6_a74;
    ddp_claim_line_rec.attribute15 := p6_a75;
    ddp_claim_line_rec.org_id := p6_a76;
    ddp_claim_line_rec.update_from_tbl_flag := p6_a77;
    ddp_claim_line_rec.tax_action := p6_a78;
    ddp_claim_line_rec.sale_date := rosetta_g_miss_date_in_map(p6_a79);
    ddp_claim_line_rec.item_type := p6_a80;
    ddp_claim_line_rec.tax_amount := p6_a81;
    ddp_claim_line_rec.claim_curr_tax_amount := p6_a82;
    ddp_claim_line_rec.activity_line_id := p6_a83;
    ddp_claim_line_rec.offer_type := p6_a84;
    ddp_claim_line_rec.prorate_earnings_flag := p6_a85;
    ddp_claim_line_rec.earnings_end_date := rosetta_g_miss_date_in_map(p6_a86);
    ddp_claim_line_rec.buy_group_party_id := p6_a87;
    ddp_claim_line_rec.acctd_tax_amount := p6_a88;
    ddp_claim_line_rec.dpp_cust_account_id := p6_a89;

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.validate_claim_line(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claim_line_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_claim_line_items(p0_a0  NUMBER
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
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  NUMBER
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  NUMBER
    , p0_a41  DATE
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  DATE
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  DATE
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_claim_line_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_claim_line_rec.claim_line_id := p0_a0;
    ddp_claim_line_rec.object_version_number := p0_a1;
    ddp_claim_line_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_claim_line_rec.last_updated_by := p0_a3;
    ddp_claim_line_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_claim_line_rec.created_by := p0_a5;
    ddp_claim_line_rec.last_update_login := p0_a6;
    ddp_claim_line_rec.request_id := p0_a7;
    ddp_claim_line_rec.program_application_id := p0_a8;
    ddp_claim_line_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_claim_line_rec.program_id := p0_a10;
    ddp_claim_line_rec.created_from := p0_a11;
    ddp_claim_line_rec.claim_id := p0_a12;
    ddp_claim_line_rec.line_number := p0_a13;
    ddp_claim_line_rec.split_from_claim_line_id := p0_a14;
    ddp_claim_line_rec.amount := p0_a15;
    ddp_claim_line_rec.claim_currency_amount := p0_a16;
    ddp_claim_line_rec.acctd_amount := p0_a17;
    ddp_claim_line_rec.currency_code := p0_a18;
    ddp_claim_line_rec.exchange_rate_type := p0_a19;
    ddp_claim_line_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a20);
    ddp_claim_line_rec.exchange_rate := p0_a21;
    ddp_claim_line_rec.set_of_books_id := p0_a22;
    ddp_claim_line_rec.valid_flag := p0_a23;
    ddp_claim_line_rec.source_object_id := p0_a24;
    ddp_claim_line_rec.source_object_line_id := p0_a25;
    ddp_claim_line_rec.source_object_class := p0_a26;
    ddp_claim_line_rec.source_object_type_id := p0_a27;
    ddp_claim_line_rec.plan_id := p0_a28;
    ddp_claim_line_rec.offer_id := p0_a29;
    ddp_claim_line_rec.utilization_id := p0_a30;
    ddp_claim_line_rec.payment_method := p0_a31;
    ddp_claim_line_rec.payment_reference_id := p0_a32;
    ddp_claim_line_rec.payment_reference_number := p0_a33;
    ddp_claim_line_rec.payment_reference_date := rosetta_g_miss_date_in_map(p0_a34);
    ddp_claim_line_rec.voucher_id := p0_a35;
    ddp_claim_line_rec.voucher_number := p0_a36;
    ddp_claim_line_rec.payment_status := p0_a37;
    ddp_claim_line_rec.approved_flag := p0_a38;
    ddp_claim_line_rec.approved_date := rosetta_g_miss_date_in_map(p0_a39);
    ddp_claim_line_rec.approved_by := p0_a40;
    ddp_claim_line_rec.settled_date := rosetta_g_miss_date_in_map(p0_a41);
    ddp_claim_line_rec.settled_by := p0_a42;
    ddp_claim_line_rec.performance_complete_flag := p0_a43;
    ddp_claim_line_rec.performance_attached_flag := p0_a44;
    ddp_claim_line_rec.select_cust_children_flag := p0_a45;
    ddp_claim_line_rec.item_id := p0_a46;
    ddp_claim_line_rec.item_description := p0_a47;
    ddp_claim_line_rec.quantity := p0_a48;
    ddp_claim_line_rec.quantity_uom := p0_a49;
    ddp_claim_line_rec.rate := p0_a50;
    ddp_claim_line_rec.activity_type := p0_a51;
    ddp_claim_line_rec.activity_id := p0_a52;
    ddp_claim_line_rec.related_cust_account_id := p0_a53;
    ddp_claim_line_rec.buy_group_cust_account_id := p0_a54;
    ddp_claim_line_rec.relationship_type := p0_a55;
    ddp_claim_line_rec.earnings_associated_flag := p0_a56;
    ddp_claim_line_rec.comments := p0_a57;
    ddp_claim_line_rec.tax_code := p0_a58;
    ddp_claim_line_rec.credit_to := p0_a59;
    ddp_claim_line_rec.attribute_category := p0_a60;
    ddp_claim_line_rec.attribute1 := p0_a61;
    ddp_claim_line_rec.attribute2 := p0_a62;
    ddp_claim_line_rec.attribute3 := p0_a63;
    ddp_claim_line_rec.attribute4 := p0_a64;
    ddp_claim_line_rec.attribute5 := p0_a65;
    ddp_claim_line_rec.attribute6 := p0_a66;
    ddp_claim_line_rec.attribute7 := p0_a67;
    ddp_claim_line_rec.attribute8 := p0_a68;
    ddp_claim_line_rec.attribute9 := p0_a69;
    ddp_claim_line_rec.attribute10 := p0_a70;
    ddp_claim_line_rec.attribute11 := p0_a71;
    ddp_claim_line_rec.attribute12 := p0_a72;
    ddp_claim_line_rec.attribute13 := p0_a73;
    ddp_claim_line_rec.attribute14 := p0_a74;
    ddp_claim_line_rec.attribute15 := p0_a75;
    ddp_claim_line_rec.org_id := p0_a76;
    ddp_claim_line_rec.update_from_tbl_flag := p0_a77;
    ddp_claim_line_rec.tax_action := p0_a78;
    ddp_claim_line_rec.sale_date := rosetta_g_miss_date_in_map(p0_a79);
    ddp_claim_line_rec.item_type := p0_a80;
    ddp_claim_line_rec.tax_amount := p0_a81;
    ddp_claim_line_rec.claim_curr_tax_amount := p0_a82;
    ddp_claim_line_rec.activity_line_id := p0_a83;
    ddp_claim_line_rec.offer_type := p0_a84;
    ddp_claim_line_rec.prorate_earnings_flag := p0_a85;
    ddp_claim_line_rec.earnings_end_date := rosetta_g_miss_date_in_map(p0_a86);
    ddp_claim_line_rec.buy_group_party_id := p0_a87;
    ddp_claim_line_rec.acctd_tax_amount := p0_a88;
    ddp_claim_line_rec.dpp_cust_account_id := p0_a89;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.check_claim_line_items(ddp_claim_line_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_claim_line_record(p0_a0  NUMBER
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
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  NUMBER
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  NUMBER
    , p0_a41  DATE
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  DATE
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  DATE
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  VARCHAR2
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
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  NUMBER
    , p1_a16  NUMBER
    , p1_a17  NUMBER
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  DATE
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  VARCHAR2
    , p1_a32  NUMBER
    , p1_a33  VARCHAR2
    , p1_a34  DATE
    , p1_a35  NUMBER
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  DATE
    , p1_a40  NUMBER
    , p1_a41  DATE
    , p1_a42  NUMBER
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  NUMBER
    , p1_a47  VARCHAR2
    , p1_a48  NUMBER
    , p1_a49  VARCHAR2
    , p1_a50  NUMBER
    , p1_a51  VARCHAR2
    , p1_a52  NUMBER
    , p1_a53  NUMBER
    , p1_a54  NUMBER
    , p1_a55  VARCHAR2
    , p1_a56  VARCHAR2
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  VARCHAR2
    , p1_a63  VARCHAR2
    , p1_a64  VARCHAR2
    , p1_a65  VARCHAR2
    , p1_a66  VARCHAR2
    , p1_a67  VARCHAR2
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  VARCHAR2
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  VARCHAR2
    , p1_a76  NUMBER
    , p1_a77  VARCHAR2
    , p1_a78  VARCHAR2
    , p1_a79  DATE
    , p1_a80  VARCHAR2
    , p1_a81  NUMBER
    , p1_a82  NUMBER
    , p1_a83  NUMBER
    , p1_a84  VARCHAR2
    , p1_a85  VARCHAR2
    , p1_a86  DATE
    , p1_a87  NUMBER
    , p1_a88  NUMBER
    , p1_a89  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_claim_line_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddp_complete_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_claim_line_rec.claim_line_id := p0_a0;
    ddp_claim_line_rec.object_version_number := p0_a1;
    ddp_claim_line_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_claim_line_rec.last_updated_by := p0_a3;
    ddp_claim_line_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_claim_line_rec.created_by := p0_a5;
    ddp_claim_line_rec.last_update_login := p0_a6;
    ddp_claim_line_rec.request_id := p0_a7;
    ddp_claim_line_rec.program_application_id := p0_a8;
    ddp_claim_line_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_claim_line_rec.program_id := p0_a10;
    ddp_claim_line_rec.created_from := p0_a11;
    ddp_claim_line_rec.claim_id := p0_a12;
    ddp_claim_line_rec.line_number := p0_a13;
    ddp_claim_line_rec.split_from_claim_line_id := p0_a14;
    ddp_claim_line_rec.amount := p0_a15;
    ddp_claim_line_rec.claim_currency_amount := p0_a16;
    ddp_claim_line_rec.acctd_amount := p0_a17;
    ddp_claim_line_rec.currency_code := p0_a18;
    ddp_claim_line_rec.exchange_rate_type := p0_a19;
    ddp_claim_line_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a20);
    ddp_claim_line_rec.exchange_rate := p0_a21;
    ddp_claim_line_rec.set_of_books_id := p0_a22;
    ddp_claim_line_rec.valid_flag := p0_a23;
    ddp_claim_line_rec.source_object_id := p0_a24;
    ddp_claim_line_rec.source_object_line_id := p0_a25;
    ddp_claim_line_rec.source_object_class := p0_a26;
    ddp_claim_line_rec.source_object_type_id := p0_a27;
    ddp_claim_line_rec.plan_id := p0_a28;
    ddp_claim_line_rec.offer_id := p0_a29;
    ddp_claim_line_rec.utilization_id := p0_a30;
    ddp_claim_line_rec.payment_method := p0_a31;
    ddp_claim_line_rec.payment_reference_id := p0_a32;
    ddp_claim_line_rec.payment_reference_number := p0_a33;
    ddp_claim_line_rec.payment_reference_date := rosetta_g_miss_date_in_map(p0_a34);
    ddp_claim_line_rec.voucher_id := p0_a35;
    ddp_claim_line_rec.voucher_number := p0_a36;
    ddp_claim_line_rec.payment_status := p0_a37;
    ddp_claim_line_rec.approved_flag := p0_a38;
    ddp_claim_line_rec.approved_date := rosetta_g_miss_date_in_map(p0_a39);
    ddp_claim_line_rec.approved_by := p0_a40;
    ddp_claim_line_rec.settled_date := rosetta_g_miss_date_in_map(p0_a41);
    ddp_claim_line_rec.settled_by := p0_a42;
    ddp_claim_line_rec.performance_complete_flag := p0_a43;
    ddp_claim_line_rec.performance_attached_flag := p0_a44;
    ddp_claim_line_rec.select_cust_children_flag := p0_a45;
    ddp_claim_line_rec.item_id := p0_a46;
    ddp_claim_line_rec.item_description := p0_a47;
    ddp_claim_line_rec.quantity := p0_a48;
    ddp_claim_line_rec.quantity_uom := p0_a49;
    ddp_claim_line_rec.rate := p0_a50;
    ddp_claim_line_rec.activity_type := p0_a51;
    ddp_claim_line_rec.activity_id := p0_a52;
    ddp_claim_line_rec.related_cust_account_id := p0_a53;
    ddp_claim_line_rec.buy_group_cust_account_id := p0_a54;
    ddp_claim_line_rec.relationship_type := p0_a55;
    ddp_claim_line_rec.earnings_associated_flag := p0_a56;
    ddp_claim_line_rec.comments := p0_a57;
    ddp_claim_line_rec.tax_code := p0_a58;
    ddp_claim_line_rec.credit_to := p0_a59;
    ddp_claim_line_rec.attribute_category := p0_a60;
    ddp_claim_line_rec.attribute1 := p0_a61;
    ddp_claim_line_rec.attribute2 := p0_a62;
    ddp_claim_line_rec.attribute3 := p0_a63;
    ddp_claim_line_rec.attribute4 := p0_a64;
    ddp_claim_line_rec.attribute5 := p0_a65;
    ddp_claim_line_rec.attribute6 := p0_a66;
    ddp_claim_line_rec.attribute7 := p0_a67;
    ddp_claim_line_rec.attribute8 := p0_a68;
    ddp_claim_line_rec.attribute9 := p0_a69;
    ddp_claim_line_rec.attribute10 := p0_a70;
    ddp_claim_line_rec.attribute11 := p0_a71;
    ddp_claim_line_rec.attribute12 := p0_a72;
    ddp_claim_line_rec.attribute13 := p0_a73;
    ddp_claim_line_rec.attribute14 := p0_a74;
    ddp_claim_line_rec.attribute15 := p0_a75;
    ddp_claim_line_rec.org_id := p0_a76;
    ddp_claim_line_rec.update_from_tbl_flag := p0_a77;
    ddp_claim_line_rec.tax_action := p0_a78;
    ddp_claim_line_rec.sale_date := rosetta_g_miss_date_in_map(p0_a79);
    ddp_claim_line_rec.item_type := p0_a80;
    ddp_claim_line_rec.tax_amount := p0_a81;
    ddp_claim_line_rec.claim_curr_tax_amount := p0_a82;
    ddp_claim_line_rec.activity_line_id := p0_a83;
    ddp_claim_line_rec.offer_type := p0_a84;
    ddp_claim_line_rec.prorate_earnings_flag := p0_a85;
    ddp_claim_line_rec.earnings_end_date := rosetta_g_miss_date_in_map(p0_a86);
    ddp_claim_line_rec.buy_group_party_id := p0_a87;
    ddp_claim_line_rec.acctd_tax_amount := p0_a88;
    ddp_claim_line_rec.dpp_cust_account_id := p0_a89;

    ddp_complete_rec.claim_line_id := p1_a0;
    ddp_complete_rec.object_version_number := p1_a1;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_complete_rec.last_updated_by := p1_a3;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_rec.created_by := p1_a5;
    ddp_complete_rec.last_update_login := p1_a6;
    ddp_complete_rec.request_id := p1_a7;
    ddp_complete_rec.program_application_id := p1_a8;
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_complete_rec.program_id := p1_a10;
    ddp_complete_rec.created_from := p1_a11;
    ddp_complete_rec.claim_id := p1_a12;
    ddp_complete_rec.line_number := p1_a13;
    ddp_complete_rec.split_from_claim_line_id := p1_a14;
    ddp_complete_rec.amount := p1_a15;
    ddp_complete_rec.claim_currency_amount := p1_a16;
    ddp_complete_rec.acctd_amount := p1_a17;
    ddp_complete_rec.currency_code := p1_a18;
    ddp_complete_rec.exchange_rate_type := p1_a19;
    ddp_complete_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p1_a20);
    ddp_complete_rec.exchange_rate := p1_a21;
    ddp_complete_rec.set_of_books_id := p1_a22;
    ddp_complete_rec.valid_flag := p1_a23;
    ddp_complete_rec.source_object_id := p1_a24;
    ddp_complete_rec.source_object_line_id := p1_a25;
    ddp_complete_rec.source_object_class := p1_a26;
    ddp_complete_rec.source_object_type_id := p1_a27;
    ddp_complete_rec.plan_id := p1_a28;
    ddp_complete_rec.offer_id := p1_a29;
    ddp_complete_rec.utilization_id := p1_a30;
    ddp_complete_rec.payment_method := p1_a31;
    ddp_complete_rec.payment_reference_id := p1_a32;
    ddp_complete_rec.payment_reference_number := p1_a33;
    ddp_complete_rec.payment_reference_date := rosetta_g_miss_date_in_map(p1_a34);
    ddp_complete_rec.voucher_id := p1_a35;
    ddp_complete_rec.voucher_number := p1_a36;
    ddp_complete_rec.payment_status := p1_a37;
    ddp_complete_rec.approved_flag := p1_a38;
    ddp_complete_rec.approved_date := rosetta_g_miss_date_in_map(p1_a39);
    ddp_complete_rec.approved_by := p1_a40;
    ddp_complete_rec.settled_date := rosetta_g_miss_date_in_map(p1_a41);
    ddp_complete_rec.settled_by := p1_a42;
    ddp_complete_rec.performance_complete_flag := p1_a43;
    ddp_complete_rec.performance_attached_flag := p1_a44;
    ddp_complete_rec.select_cust_children_flag := p1_a45;
    ddp_complete_rec.item_id := p1_a46;
    ddp_complete_rec.item_description := p1_a47;
    ddp_complete_rec.quantity := p1_a48;
    ddp_complete_rec.quantity_uom := p1_a49;
    ddp_complete_rec.rate := p1_a50;
    ddp_complete_rec.activity_type := p1_a51;
    ddp_complete_rec.activity_id := p1_a52;
    ddp_complete_rec.related_cust_account_id := p1_a53;
    ddp_complete_rec.buy_group_cust_account_id := p1_a54;
    ddp_complete_rec.relationship_type := p1_a55;
    ddp_complete_rec.earnings_associated_flag := p1_a56;
    ddp_complete_rec.comments := p1_a57;
    ddp_complete_rec.tax_code := p1_a58;
    ddp_complete_rec.credit_to := p1_a59;
    ddp_complete_rec.attribute_category := p1_a60;
    ddp_complete_rec.attribute1 := p1_a61;
    ddp_complete_rec.attribute2 := p1_a62;
    ddp_complete_rec.attribute3 := p1_a63;
    ddp_complete_rec.attribute4 := p1_a64;
    ddp_complete_rec.attribute5 := p1_a65;
    ddp_complete_rec.attribute6 := p1_a66;
    ddp_complete_rec.attribute7 := p1_a67;
    ddp_complete_rec.attribute8 := p1_a68;
    ddp_complete_rec.attribute9 := p1_a69;
    ddp_complete_rec.attribute10 := p1_a70;
    ddp_complete_rec.attribute11 := p1_a71;
    ddp_complete_rec.attribute12 := p1_a72;
    ddp_complete_rec.attribute13 := p1_a73;
    ddp_complete_rec.attribute14 := p1_a74;
    ddp_complete_rec.attribute15 := p1_a75;
    ddp_complete_rec.org_id := p1_a76;
    ddp_complete_rec.update_from_tbl_flag := p1_a77;
    ddp_complete_rec.tax_action := p1_a78;
    ddp_complete_rec.sale_date := rosetta_g_miss_date_in_map(p1_a79);
    ddp_complete_rec.item_type := p1_a80;
    ddp_complete_rec.tax_amount := p1_a81;
    ddp_complete_rec.claim_curr_tax_amount := p1_a82;
    ddp_complete_rec.activity_line_id := p1_a83;
    ddp_complete_rec.offer_type := p1_a84;
    ddp_complete_rec.prorate_earnings_flag := p1_a85;
    ddp_complete_rec.earnings_end_date := rosetta_g_miss_date_in_map(p1_a86);
    ddp_complete_rec.buy_group_party_id := p1_a87;
    ddp_complete_rec.acctd_tax_amount := p1_a88;
    ddp_complete_rec.dpp_cust_account_id := p1_a89;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.check_claim_line_record(ddp_claim_line_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_claim_line_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  NUMBER
    , p0_a2 out nocopy  DATE
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  DATE
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  DATE
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  NUMBER
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  NUMBER
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  DATE
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  DATE
    , p0_a40 out nocopy  NUMBER
    , p0_a41 out nocopy  DATE
    , p0_a42 out nocopy  NUMBER
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  NUMBER
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  NUMBER
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  VARCHAR2
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  VARCHAR2
    , p0_a61 out nocopy  VARCHAR2
    , p0_a62 out nocopy  VARCHAR2
    , p0_a63 out nocopy  VARCHAR2
    , p0_a64 out nocopy  VARCHAR2
    , p0_a65 out nocopy  VARCHAR2
    , p0_a66 out nocopy  VARCHAR2
    , p0_a67 out nocopy  VARCHAR2
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  VARCHAR2
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  VARCHAR2
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  VARCHAR2
    , p0_a76 out nocopy  NUMBER
    , p0_a77 out nocopy  VARCHAR2
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  DATE
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  NUMBER
    , p0_a82 out nocopy  NUMBER
    , p0_a83 out nocopy  NUMBER
    , p0_a84 out nocopy  VARCHAR2
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  DATE
    , p0_a87 out nocopy  NUMBER
    , p0_a88 out nocopy  NUMBER
    , p0_a89 out nocopy  VARCHAR2
  )

  as
    ddx_claim_line_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.init_claim_line_rec(ddx_claim_line_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_claim_line_rec.claim_line_id;
    p0_a1 := ddx_claim_line_rec.object_version_number;
    p0_a2 := ddx_claim_line_rec.last_update_date;
    p0_a3 := ddx_claim_line_rec.last_updated_by;
    p0_a4 := ddx_claim_line_rec.creation_date;
    p0_a5 := ddx_claim_line_rec.created_by;
    p0_a6 := ddx_claim_line_rec.last_update_login;
    p0_a7 := ddx_claim_line_rec.request_id;
    p0_a8 := ddx_claim_line_rec.program_application_id;
    p0_a9 := ddx_claim_line_rec.program_update_date;
    p0_a10 := ddx_claim_line_rec.program_id;
    p0_a11 := ddx_claim_line_rec.created_from;
    p0_a12 := ddx_claim_line_rec.claim_id;
    p0_a13 := ddx_claim_line_rec.line_number;
    p0_a14 := ddx_claim_line_rec.split_from_claim_line_id;
    p0_a15 := ddx_claim_line_rec.amount;
    p0_a16 := ddx_claim_line_rec.claim_currency_amount;
    p0_a17 := ddx_claim_line_rec.acctd_amount;
    p0_a18 := ddx_claim_line_rec.currency_code;
    p0_a19 := ddx_claim_line_rec.exchange_rate_type;
    p0_a20 := ddx_claim_line_rec.exchange_rate_date;
    p0_a21 := ddx_claim_line_rec.exchange_rate;
    p0_a22 := ddx_claim_line_rec.set_of_books_id;
    p0_a23 := ddx_claim_line_rec.valid_flag;
    p0_a24 := ddx_claim_line_rec.source_object_id;
    p0_a25 := ddx_claim_line_rec.source_object_line_id;
    p0_a26 := ddx_claim_line_rec.source_object_class;
    p0_a27 := ddx_claim_line_rec.source_object_type_id;
    p0_a28 := ddx_claim_line_rec.plan_id;
    p0_a29 := ddx_claim_line_rec.offer_id;
    p0_a30 := ddx_claim_line_rec.utilization_id;
    p0_a31 := ddx_claim_line_rec.payment_method;
    p0_a32 := ddx_claim_line_rec.payment_reference_id;
    p0_a33 := ddx_claim_line_rec.payment_reference_number;
    p0_a34 := ddx_claim_line_rec.payment_reference_date;
    p0_a35 := ddx_claim_line_rec.voucher_id;
    p0_a36 := ddx_claim_line_rec.voucher_number;
    p0_a37 := ddx_claim_line_rec.payment_status;
    p0_a38 := ddx_claim_line_rec.approved_flag;
    p0_a39 := ddx_claim_line_rec.approved_date;
    p0_a40 := ddx_claim_line_rec.approved_by;
    p0_a41 := ddx_claim_line_rec.settled_date;
    p0_a42 := ddx_claim_line_rec.settled_by;
    p0_a43 := ddx_claim_line_rec.performance_complete_flag;
    p0_a44 := ddx_claim_line_rec.performance_attached_flag;
    p0_a45 := ddx_claim_line_rec.select_cust_children_flag;
    p0_a46 := ddx_claim_line_rec.item_id;
    p0_a47 := ddx_claim_line_rec.item_description;
    p0_a48 := ddx_claim_line_rec.quantity;
    p0_a49 := ddx_claim_line_rec.quantity_uom;
    p0_a50 := ddx_claim_line_rec.rate;
    p0_a51 := ddx_claim_line_rec.activity_type;
    p0_a52 := ddx_claim_line_rec.activity_id;
    p0_a53 := ddx_claim_line_rec.related_cust_account_id;
    p0_a54 := ddx_claim_line_rec.buy_group_cust_account_id;
    p0_a55 := ddx_claim_line_rec.relationship_type;
    p0_a56 := ddx_claim_line_rec.earnings_associated_flag;
    p0_a57 := ddx_claim_line_rec.comments;
    p0_a58 := ddx_claim_line_rec.tax_code;
    p0_a59 := ddx_claim_line_rec.credit_to;
    p0_a60 := ddx_claim_line_rec.attribute_category;
    p0_a61 := ddx_claim_line_rec.attribute1;
    p0_a62 := ddx_claim_line_rec.attribute2;
    p0_a63 := ddx_claim_line_rec.attribute3;
    p0_a64 := ddx_claim_line_rec.attribute4;
    p0_a65 := ddx_claim_line_rec.attribute5;
    p0_a66 := ddx_claim_line_rec.attribute6;
    p0_a67 := ddx_claim_line_rec.attribute7;
    p0_a68 := ddx_claim_line_rec.attribute8;
    p0_a69 := ddx_claim_line_rec.attribute9;
    p0_a70 := ddx_claim_line_rec.attribute10;
    p0_a71 := ddx_claim_line_rec.attribute11;
    p0_a72 := ddx_claim_line_rec.attribute12;
    p0_a73 := ddx_claim_line_rec.attribute13;
    p0_a74 := ddx_claim_line_rec.attribute14;
    p0_a75 := ddx_claim_line_rec.attribute15;
    p0_a76 := ddx_claim_line_rec.org_id;
    p0_a77 := ddx_claim_line_rec.update_from_tbl_flag;
    p0_a78 := ddx_claim_line_rec.tax_action;
    p0_a79 := ddx_claim_line_rec.sale_date;
    p0_a80 := ddx_claim_line_rec.item_type;
    p0_a81 := ddx_claim_line_rec.tax_amount;
    p0_a82 := ddx_claim_line_rec.claim_curr_tax_amount;
    p0_a83 := ddx_claim_line_rec.activity_line_id;
    p0_a84 := ddx_claim_line_rec.offer_type;
    p0_a85 := ddx_claim_line_rec.prorate_earnings_flag;
    p0_a86 := ddx_claim_line_rec.earnings_end_date;
    p0_a87 := ddx_claim_line_rec.buy_group_party_id;
    p0_a88 := ddx_claim_line_rec.acctd_tax_amount;
    p0_a89 := ddx_claim_line_rec.dpp_cust_account_id;
  end;

  procedure complete_claim_line_rec(p0_a0  NUMBER
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
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  NUMBER
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  NUMBER
    , p0_a41  DATE
    , p0_a42  NUMBER
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  DATE
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  DATE
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  VARCHAR2
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
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  DATE
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  DATE
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  DATE
    , p1_a42 out nocopy  NUMBER
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  VARCHAR2
    , p1_a61 out nocopy  VARCHAR2
    , p1_a62 out nocopy  VARCHAR2
    , p1_a63 out nocopy  VARCHAR2
    , p1_a64 out nocopy  VARCHAR2
    , p1_a65 out nocopy  VARCHAR2
    , p1_a66 out nocopy  VARCHAR2
    , p1_a67 out nocopy  VARCHAR2
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  VARCHAR2
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  VARCHAR2
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  DATE
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  NUMBER
    , p1_a82 out nocopy  NUMBER
    , p1_a83 out nocopy  NUMBER
    , p1_a84 out nocopy  VARCHAR2
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  DATE
    , p1_a87 out nocopy  NUMBER
    , p1_a88 out nocopy  NUMBER
    , p1_a89 out nocopy  VARCHAR2
  )

  as
    ddp_claim_line_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddx_complete_rec ozf_claim_line_pvt.claim_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_claim_line_rec.claim_line_id := p0_a0;
    ddp_claim_line_rec.object_version_number := p0_a1;
    ddp_claim_line_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_claim_line_rec.last_updated_by := p0_a3;
    ddp_claim_line_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_claim_line_rec.created_by := p0_a5;
    ddp_claim_line_rec.last_update_login := p0_a6;
    ddp_claim_line_rec.request_id := p0_a7;
    ddp_claim_line_rec.program_application_id := p0_a8;
    ddp_claim_line_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_claim_line_rec.program_id := p0_a10;
    ddp_claim_line_rec.created_from := p0_a11;
    ddp_claim_line_rec.claim_id := p0_a12;
    ddp_claim_line_rec.line_number := p0_a13;
    ddp_claim_line_rec.split_from_claim_line_id := p0_a14;
    ddp_claim_line_rec.amount := p0_a15;
    ddp_claim_line_rec.claim_currency_amount := p0_a16;
    ddp_claim_line_rec.acctd_amount := p0_a17;
    ddp_claim_line_rec.currency_code := p0_a18;
    ddp_claim_line_rec.exchange_rate_type := p0_a19;
    ddp_claim_line_rec.exchange_rate_date := rosetta_g_miss_date_in_map(p0_a20);
    ddp_claim_line_rec.exchange_rate := p0_a21;
    ddp_claim_line_rec.set_of_books_id := p0_a22;
    ddp_claim_line_rec.valid_flag := p0_a23;
    ddp_claim_line_rec.source_object_id := p0_a24;
    ddp_claim_line_rec.source_object_line_id := p0_a25;
    ddp_claim_line_rec.source_object_class := p0_a26;
    ddp_claim_line_rec.source_object_type_id := p0_a27;
    ddp_claim_line_rec.plan_id := p0_a28;
    ddp_claim_line_rec.offer_id := p0_a29;
    ddp_claim_line_rec.utilization_id := p0_a30;
    ddp_claim_line_rec.payment_method := p0_a31;
    ddp_claim_line_rec.payment_reference_id := p0_a32;
    ddp_claim_line_rec.payment_reference_number := p0_a33;
    ddp_claim_line_rec.payment_reference_date := rosetta_g_miss_date_in_map(p0_a34);
    ddp_claim_line_rec.voucher_id := p0_a35;
    ddp_claim_line_rec.voucher_number := p0_a36;
    ddp_claim_line_rec.payment_status := p0_a37;
    ddp_claim_line_rec.approved_flag := p0_a38;
    ddp_claim_line_rec.approved_date := rosetta_g_miss_date_in_map(p0_a39);
    ddp_claim_line_rec.approved_by := p0_a40;
    ddp_claim_line_rec.settled_date := rosetta_g_miss_date_in_map(p0_a41);
    ddp_claim_line_rec.settled_by := p0_a42;
    ddp_claim_line_rec.performance_complete_flag := p0_a43;
    ddp_claim_line_rec.performance_attached_flag := p0_a44;
    ddp_claim_line_rec.select_cust_children_flag := p0_a45;
    ddp_claim_line_rec.item_id := p0_a46;
    ddp_claim_line_rec.item_description := p0_a47;
    ddp_claim_line_rec.quantity := p0_a48;
    ddp_claim_line_rec.quantity_uom := p0_a49;
    ddp_claim_line_rec.rate := p0_a50;
    ddp_claim_line_rec.activity_type := p0_a51;
    ddp_claim_line_rec.activity_id := p0_a52;
    ddp_claim_line_rec.related_cust_account_id := p0_a53;
    ddp_claim_line_rec.buy_group_cust_account_id := p0_a54;
    ddp_claim_line_rec.relationship_type := p0_a55;
    ddp_claim_line_rec.earnings_associated_flag := p0_a56;
    ddp_claim_line_rec.comments := p0_a57;
    ddp_claim_line_rec.tax_code := p0_a58;
    ddp_claim_line_rec.credit_to := p0_a59;
    ddp_claim_line_rec.attribute_category := p0_a60;
    ddp_claim_line_rec.attribute1 := p0_a61;
    ddp_claim_line_rec.attribute2 := p0_a62;
    ddp_claim_line_rec.attribute3 := p0_a63;
    ddp_claim_line_rec.attribute4 := p0_a64;
    ddp_claim_line_rec.attribute5 := p0_a65;
    ddp_claim_line_rec.attribute6 := p0_a66;
    ddp_claim_line_rec.attribute7 := p0_a67;
    ddp_claim_line_rec.attribute8 := p0_a68;
    ddp_claim_line_rec.attribute9 := p0_a69;
    ddp_claim_line_rec.attribute10 := p0_a70;
    ddp_claim_line_rec.attribute11 := p0_a71;
    ddp_claim_line_rec.attribute12 := p0_a72;
    ddp_claim_line_rec.attribute13 := p0_a73;
    ddp_claim_line_rec.attribute14 := p0_a74;
    ddp_claim_line_rec.attribute15 := p0_a75;
    ddp_claim_line_rec.org_id := p0_a76;
    ddp_claim_line_rec.update_from_tbl_flag := p0_a77;
    ddp_claim_line_rec.tax_action := p0_a78;
    ddp_claim_line_rec.sale_date := rosetta_g_miss_date_in_map(p0_a79);
    ddp_claim_line_rec.item_type := p0_a80;
    ddp_claim_line_rec.tax_amount := p0_a81;
    ddp_claim_line_rec.claim_curr_tax_amount := p0_a82;
    ddp_claim_line_rec.activity_line_id := p0_a83;
    ddp_claim_line_rec.offer_type := p0_a84;
    ddp_claim_line_rec.prorate_earnings_flag := p0_a85;
    ddp_claim_line_rec.earnings_end_date := rosetta_g_miss_date_in_map(p0_a86);
    ddp_claim_line_rec.buy_group_party_id := p0_a87;
    ddp_claim_line_rec.acctd_tax_amount := p0_a88;
    ddp_claim_line_rec.dpp_cust_account_id := p0_a89;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_line_pvt.complete_claim_line_rec(ddp_claim_line_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.claim_line_id;
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
    p1_a12 := ddx_complete_rec.claim_id;
    p1_a13 := ddx_complete_rec.line_number;
    p1_a14 := ddx_complete_rec.split_from_claim_line_id;
    p1_a15 := ddx_complete_rec.amount;
    p1_a16 := ddx_complete_rec.claim_currency_amount;
    p1_a17 := ddx_complete_rec.acctd_amount;
    p1_a18 := ddx_complete_rec.currency_code;
    p1_a19 := ddx_complete_rec.exchange_rate_type;
    p1_a20 := ddx_complete_rec.exchange_rate_date;
    p1_a21 := ddx_complete_rec.exchange_rate;
    p1_a22 := ddx_complete_rec.set_of_books_id;
    p1_a23 := ddx_complete_rec.valid_flag;
    p1_a24 := ddx_complete_rec.source_object_id;
    p1_a25 := ddx_complete_rec.source_object_line_id;
    p1_a26 := ddx_complete_rec.source_object_class;
    p1_a27 := ddx_complete_rec.source_object_type_id;
    p1_a28 := ddx_complete_rec.plan_id;
    p1_a29 := ddx_complete_rec.offer_id;
    p1_a30 := ddx_complete_rec.utilization_id;
    p1_a31 := ddx_complete_rec.payment_method;
    p1_a32 := ddx_complete_rec.payment_reference_id;
    p1_a33 := ddx_complete_rec.payment_reference_number;
    p1_a34 := ddx_complete_rec.payment_reference_date;
    p1_a35 := ddx_complete_rec.voucher_id;
    p1_a36 := ddx_complete_rec.voucher_number;
    p1_a37 := ddx_complete_rec.payment_status;
    p1_a38 := ddx_complete_rec.approved_flag;
    p1_a39 := ddx_complete_rec.approved_date;
    p1_a40 := ddx_complete_rec.approved_by;
    p1_a41 := ddx_complete_rec.settled_date;
    p1_a42 := ddx_complete_rec.settled_by;
    p1_a43 := ddx_complete_rec.performance_complete_flag;
    p1_a44 := ddx_complete_rec.performance_attached_flag;
    p1_a45 := ddx_complete_rec.select_cust_children_flag;
    p1_a46 := ddx_complete_rec.item_id;
    p1_a47 := ddx_complete_rec.item_description;
    p1_a48 := ddx_complete_rec.quantity;
    p1_a49 := ddx_complete_rec.quantity_uom;
    p1_a50 := ddx_complete_rec.rate;
    p1_a51 := ddx_complete_rec.activity_type;
    p1_a52 := ddx_complete_rec.activity_id;
    p1_a53 := ddx_complete_rec.related_cust_account_id;
    p1_a54 := ddx_complete_rec.buy_group_cust_account_id;
    p1_a55 := ddx_complete_rec.relationship_type;
    p1_a56 := ddx_complete_rec.earnings_associated_flag;
    p1_a57 := ddx_complete_rec.comments;
    p1_a58 := ddx_complete_rec.tax_code;
    p1_a59 := ddx_complete_rec.credit_to;
    p1_a60 := ddx_complete_rec.attribute_category;
    p1_a61 := ddx_complete_rec.attribute1;
    p1_a62 := ddx_complete_rec.attribute2;
    p1_a63 := ddx_complete_rec.attribute3;
    p1_a64 := ddx_complete_rec.attribute4;
    p1_a65 := ddx_complete_rec.attribute5;
    p1_a66 := ddx_complete_rec.attribute6;
    p1_a67 := ddx_complete_rec.attribute7;
    p1_a68 := ddx_complete_rec.attribute8;
    p1_a69 := ddx_complete_rec.attribute9;
    p1_a70 := ddx_complete_rec.attribute10;
    p1_a71 := ddx_complete_rec.attribute11;
    p1_a72 := ddx_complete_rec.attribute12;
    p1_a73 := ddx_complete_rec.attribute13;
    p1_a74 := ddx_complete_rec.attribute14;
    p1_a75 := ddx_complete_rec.attribute15;
    p1_a76 := ddx_complete_rec.org_id;
    p1_a77 := ddx_complete_rec.update_from_tbl_flag;
    p1_a78 := ddx_complete_rec.tax_action;
    p1_a79 := ddx_complete_rec.sale_date;
    p1_a80 := ddx_complete_rec.item_type;
    p1_a81 := ddx_complete_rec.tax_amount;
    p1_a82 := ddx_complete_rec.claim_curr_tax_amount;
    p1_a83 := ddx_complete_rec.activity_line_id;
    p1_a84 := ddx_complete_rec.offer_type;
    p1_a85 := ddx_complete_rec.prorate_earnings_flag;
    p1_a86 := ddx_complete_rec.earnings_end_date;
    p1_a87 := ddx_complete_rec.buy_group_party_id;
    p1_a88 := ddx_complete_rec.acctd_tax_amount;
    p1_a89 := ddx_complete_rec.dpp_cust_account_id;
  end;

end ozf_claim_line_pvt_w;

/
