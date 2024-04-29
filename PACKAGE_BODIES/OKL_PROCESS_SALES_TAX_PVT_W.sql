--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_SALES_TAX_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_SALES_TAX_PVT_W" as
  /* $Header: OKLEPSTB.pls 120.2 2007/07/13 01:20:47 rravikir noship $ */
  procedure rosetta_table_copy_in_p73(t out nocopy okl_process_sales_tax_pvt.tax_sources_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_VARCHAR2_TABLE_500
    , a35 JTF_VARCHAR2_TABLE_500
    , a36 JTF_VARCHAR2_TABLE_500
    , a37 JTF_VARCHAR2_TABLE_500
    , a38 JTF_VARCHAR2_TABLE_500
    , a39 JTF_VARCHAR2_TABLE_500
    , a40 JTF_VARCHAR2_TABLE_500
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_DATE_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_DATE_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_DATE_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_200
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_DATE_TABLE
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).khr_id := a1(indx);
          t(ddindx).kle_id := a2(indx);
          t(ddindx).line_name := a3(indx);
          t(ddindx).trx_id := a4(indx);
          t(ddindx).trx_line_id := a5(indx);
          t(ddindx).entity_code := a6(indx);
          t(ddindx).event_class_code := a7(indx);
          t(ddindx).trx_level_type := a8(indx);
          t(ddindx).adjusted_doc_entity_code := a9(indx);
          t(ddindx).adjusted_doc_event_class_code := a10(indx);
          t(ddindx).adjusted_doc_trx_id := a11(indx);
          t(ddindx).adjusted_doc_trx_line_id := a12(indx);
          t(ddindx).adjusted_doc_trx_level_type := a13(indx);
          t(ddindx).adjusted_doc_number := a14(indx);
          t(ddindx).adjusted_doc_date := a15(indx);
          t(ddindx).tax_call_type_code := a16(indx);
          t(ddindx).sty_id := a17(indx);
          t(ddindx).trx_business_category := a18(indx);
          t(ddindx).tax_line_status_code := a19(indx);
          t(ddindx).sel_id := a20(indx);
          t(ddindx).program_id := a21(indx);
          t(ddindx).request_id := a22(indx);
          t(ddindx).program_application_id := a23(indx);
          t(ddindx).program_update_date := a24(indx);
          t(ddindx).attribute_category := a25(indx);
          t(ddindx).attribute1 := a26(indx);
          t(ddindx).attribute2 := a27(indx);
          t(ddindx).attribute3 := a28(indx);
          t(ddindx).attribute4 := a29(indx);
          t(ddindx).attribute5 := a30(indx);
          t(ddindx).attribute6 := a31(indx);
          t(ddindx).attribute7 := a32(indx);
          t(ddindx).attribute8 := a33(indx);
          t(ddindx).attribute9 := a34(indx);
          t(ddindx).attribute10 := a35(indx);
          t(ddindx).attribute11 := a36(indx);
          t(ddindx).attribute12 := a37(indx);
          t(ddindx).attribute13 := a38(indx);
          t(ddindx).attribute14 := a39(indx);
          t(ddindx).attribute15 := a40(indx);
          t(ddindx).created_by := a41(indx);
          t(ddindx).creation_date := a42(indx);
          t(ddindx).last_updated_by := a43(indx);
          t(ddindx).last_update_date := a44(indx);
          t(ddindx).last_update_login := a45(indx);
          t(ddindx).object_version_number := a46(indx);
          t(ddindx).application_id := a47(indx);
          t(ddindx).assessable_value := a48(indx);
          t(ddindx).bill_to_cust_acct_id := a49(indx);
          t(ddindx).currency_conversion_date := a50(indx);
          t(ddindx).currency_conversion_rate := a51(indx);
          t(ddindx).currency_conversion_type := a52(indx);
          t(ddindx).default_taxation_country := a53(indx);
          t(ddindx).inventory_item_id := a54(indx);
          t(ddindx).legal_entity_id := a55(indx);
          t(ddindx).line_amt := a56(indx);
          t(ddindx).line_intended_use := a57(indx);
          t(ddindx).org_id := a58(indx);
          t(ddindx).product_category := a59(indx);
          t(ddindx).product_fisc_classification := a60(indx);
          t(ddindx).product_type := a61(indx);
          t(ddindx).ship_to_location_id := a62(indx);
          t(ddindx).total_tax := a63(indx);
          t(ddindx).trx_currency_code := a64(indx);
          t(ddindx).trx_date := a65(indx);
          t(ddindx).try_id := a66(indx);
          t(ddindx).user_defined_fisc_class := a67(indx);
          t(ddindx).ship_to_party_site_id := a68(indx);
          t(ddindx).ship_to_party_id := a69(indx);
          t(ddindx).bill_to_party_site_id := a70(indx);
          t(ddindx).bill_to_location_id := a71(indx);
          t(ddindx).bill_to_party_id := a72(indx);
          t(ddindx).ship_to_cust_acct_site_use_id := a73(indx);
          t(ddindx).bill_to_cust_acct_site_use_id := a74(indx);
          t(ddindx).tax_classification_code := a75(indx);
          t(ddindx).asset_number := a76(indx);
          t(ddindx).reported_yn := a77(indx);
          t(ddindx).tax_reporting_flag := a78(indx);
          t(ddindx).provnl_tax_determination_date := a79(indx);
          t(ddindx).alc_serialized_yn := a80(indx);
          t(ddindx).alc_serialized_total_tax := a81(indx);
          t(ddindx).alc_serialized_total_line_amt := a82(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p73;
  procedure rosetta_table_copy_out_p73(t okl_process_sales_tax_pvt.tax_sources_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_VARCHAR2_TABLE_500
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    , a36 out nocopy JTF_VARCHAR2_TABLE_500
    , a37 out nocopy JTF_VARCHAR2_TABLE_500
    , a38 out nocopy JTF_VARCHAR2_TABLE_500
    , a39 out nocopy JTF_VARCHAR2_TABLE_500
    , a40 out nocopy JTF_VARCHAR2_TABLE_500
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_DATE_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_DATE_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_200
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_DATE_TABLE
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_NUMBER_TABLE
    , a82 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_VARCHAR2_TABLE_500();
    a35 := JTF_VARCHAR2_TABLE_500();
    a36 := JTF_VARCHAR2_TABLE_500();
    a37 := JTF_VARCHAR2_TABLE_500();
    a38 := JTF_VARCHAR2_TABLE_500();
    a39 := JTF_VARCHAR2_TABLE_500();
    a40 := JTF_VARCHAR2_TABLE_500();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_DATE_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_300();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_300();
    a61 := JTF_VARCHAR2_TABLE_300();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_DATE_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_200();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_DATE_TABLE();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_VARCHAR2_TABLE_500();
      a35 := JTF_VARCHAR2_TABLE_500();
      a36 := JTF_VARCHAR2_TABLE_500();
      a37 := JTF_VARCHAR2_TABLE_500();
      a38 := JTF_VARCHAR2_TABLE_500();
      a39 := JTF_VARCHAR2_TABLE_500();
      a40 := JTF_VARCHAR2_TABLE_500();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_DATE_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_300();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_300();
      a61 := JTF_VARCHAR2_TABLE_300();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_DATE_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_200();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_DATE_TABLE();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).khr_id;
          a2(indx) := t(ddindx).kle_id;
          a3(indx) := t(ddindx).line_name;
          a4(indx) := t(ddindx).trx_id;
          a5(indx) := t(ddindx).trx_line_id;
          a6(indx) := t(ddindx).entity_code;
          a7(indx) := t(ddindx).event_class_code;
          a8(indx) := t(ddindx).trx_level_type;
          a9(indx) := t(ddindx).adjusted_doc_entity_code;
          a10(indx) := t(ddindx).adjusted_doc_event_class_code;
          a11(indx) := t(ddindx).adjusted_doc_trx_id;
          a12(indx) := t(ddindx).adjusted_doc_trx_line_id;
          a13(indx) := t(ddindx).adjusted_doc_trx_level_type;
          a14(indx) := t(ddindx).adjusted_doc_number;
          a15(indx) := t(ddindx).adjusted_doc_date;
          a16(indx) := t(ddindx).tax_call_type_code;
          a17(indx) := t(ddindx).sty_id;
          a18(indx) := t(ddindx).trx_business_category;
          a19(indx) := t(ddindx).tax_line_status_code;
          a20(indx) := t(ddindx).sel_id;
          a21(indx) := t(ddindx).program_id;
          a22(indx) := t(ddindx).request_id;
          a23(indx) := t(ddindx).program_application_id;
          a24(indx) := t(ddindx).program_update_date;
          a25(indx) := t(ddindx).attribute_category;
          a26(indx) := t(ddindx).attribute1;
          a27(indx) := t(ddindx).attribute2;
          a28(indx) := t(ddindx).attribute3;
          a29(indx) := t(ddindx).attribute4;
          a30(indx) := t(ddindx).attribute5;
          a31(indx) := t(ddindx).attribute6;
          a32(indx) := t(ddindx).attribute7;
          a33(indx) := t(ddindx).attribute8;
          a34(indx) := t(ddindx).attribute9;
          a35(indx) := t(ddindx).attribute10;
          a36(indx) := t(ddindx).attribute11;
          a37(indx) := t(ddindx).attribute12;
          a38(indx) := t(ddindx).attribute13;
          a39(indx) := t(ddindx).attribute14;
          a40(indx) := t(ddindx).attribute15;
          a41(indx) := t(ddindx).created_by;
          a42(indx) := t(ddindx).creation_date;
          a43(indx) := t(ddindx).last_updated_by;
          a44(indx) := t(ddindx).last_update_date;
          a45(indx) := t(ddindx).last_update_login;
          a46(indx) := t(ddindx).object_version_number;
          a47(indx) := t(ddindx).application_id;
          a48(indx) := t(ddindx).assessable_value;
          a49(indx) := t(ddindx).bill_to_cust_acct_id;
          a50(indx) := t(ddindx).currency_conversion_date;
          a51(indx) := t(ddindx).currency_conversion_rate;
          a52(indx) := t(ddindx).currency_conversion_type;
          a53(indx) := t(ddindx).default_taxation_country;
          a54(indx) := t(ddindx).inventory_item_id;
          a55(indx) := t(ddindx).legal_entity_id;
          a56(indx) := t(ddindx).line_amt;
          a57(indx) := t(ddindx).line_intended_use;
          a58(indx) := t(ddindx).org_id;
          a59(indx) := t(ddindx).product_category;
          a60(indx) := t(ddindx).product_fisc_classification;
          a61(indx) := t(ddindx).product_type;
          a62(indx) := t(ddindx).ship_to_location_id;
          a63(indx) := t(ddindx).total_tax;
          a64(indx) := t(ddindx).trx_currency_code;
          a65(indx) := t(ddindx).trx_date;
          a66(indx) := t(ddindx).try_id;
          a67(indx) := t(ddindx).user_defined_fisc_class;
          a68(indx) := t(ddindx).ship_to_party_site_id;
          a69(indx) := t(ddindx).ship_to_party_id;
          a70(indx) := t(ddindx).bill_to_party_site_id;
          a71(indx) := t(ddindx).bill_to_location_id;
          a72(indx) := t(ddindx).bill_to_party_id;
          a73(indx) := t(ddindx).ship_to_cust_acct_site_use_id;
          a74(indx) := t(ddindx).bill_to_cust_acct_site_use_id;
          a75(indx) := t(ddindx).tax_classification_code;
          a76(indx) := t(ddindx).asset_number;
          a77(indx) := t(ddindx).reported_yn;
          a78(indx) := t(ddindx).tax_reporting_flag;
          a79(indx) := t(ddindx).provnl_tax_determination_date;
          a80(indx) := t(ddindx).alc_serialized_yn;
          a81(indx) := t(ddindx).alc_serialized_total_tax;
          a82(indx) := t(ddindx).alc_serialized_total_line_amt;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p73;

  procedure rosetta_table_copy_in_p76(t out nocopy okl_process_sales_tax_pvt.tax_lines_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_500
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_DATE_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_DATE_TABLE
    , a70 JTF_DATE_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).txs_id := a1(indx);
          t(ddindx).tax_determine_date := a2(indx);
          t(ddindx).tax_rate_id := a3(indx);
          t(ddindx).tax_rate_code := a4(indx);
          t(ddindx).taxable_amt := a5(indx);
          t(ddindx).tax_exemption_id := a6(indx);
          t(ddindx).tax_rate := a7(indx);
          t(ddindx).tax_amt := a8(indx);
          t(ddindx).billed_yn := a9(indx);
          t(ddindx).tax_call_type_code := a10(indx);
          t(ddindx).program_id := a11(indx);
          t(ddindx).request_id := a12(indx);
          t(ddindx).program_application_id := a13(indx);
          t(ddindx).program_update_date := a14(indx);
          t(ddindx).attribute_category := a15(indx);
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
          t(ddindx).created_by := a31(indx);
          t(ddindx).creation_date := a32(indx);
          t(ddindx).last_updated_by := a33(indx);
          t(ddindx).last_update_date := a34(indx);
          t(ddindx).last_update_login := a35(indx);
          t(ddindx).object_version_number := a36(indx);
          t(ddindx).tax_date := a37(indx);
          t(ddindx).line_amt := a38(indx);
          t(ddindx).internal_organization_id := a39(indx);
          t(ddindx).application_id := a40(indx);
          t(ddindx).entity_code := a41(indx);
          t(ddindx).event_class_code := a42(indx);
          t(ddindx).event_type_code := a43(indx);
          t(ddindx).trx_id := a44(indx);
          t(ddindx).trx_line_id := a45(indx);
          t(ddindx).trx_level_type := a46(indx);
          t(ddindx).trx_line_number := a47(indx);
          t(ddindx).tax_line_number := a48(indx);
          t(ddindx).tax_regime_id := a49(indx);
          t(ddindx).tax_regime_code := a50(indx);
          t(ddindx).tax_id := a51(indx);
          t(ddindx).tax := a52(indx);
          t(ddindx).tax_status_id := a53(indx);
          t(ddindx).tax_status_code := a54(indx);
          t(ddindx).tax_apportionment_line_number := a55(indx);
          t(ddindx).legal_entity_id := a56(indx);
          t(ddindx).trx_number := a57(indx);
          t(ddindx).trx_date := a58(indx);
          t(ddindx).tax_jurisdiction_id := a59(indx);
          t(ddindx).tax_jurisdiction_code := a60(indx);
          t(ddindx).tax_type_code := a61(indx);
          t(ddindx).tax_currency_code := a62(indx);
          t(ddindx).taxable_amt_tax_curr := a63(indx);
          t(ddindx).trx_currency_code := a64(indx);
          t(ddindx).minimum_accountable_unit := a65(indx);
          t(ddindx).precision := a66(indx);
          t(ddindx).currency_conversion_type := a67(indx);
          t(ddindx).currency_conversion_rate := a68(indx);
          t(ddindx).currency_conversion_date := a69(indx);
          t(ddindx).tax_determination_date := a70(indx);
          t(ddindx).taxable_amount := a71(indx);
          t(ddindx).tax_amount := a72(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p76;
  procedure rosetta_table_copy_out_p76(t okl_process_sales_tax_pvt.tax_lines_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_DATE_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_DATE_TABLE
    , a70 out nocopy JTF_DATE_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_500();
    a19 := JTF_VARCHAR2_TABLE_500();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_100();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_DATE_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_DATE_TABLE();
    a70 := JTF_DATE_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_500();
      a19 := JTF_VARCHAR2_TABLE_500();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_100();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_DATE_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_DATE_TABLE();
      a70 := JTF_DATE_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).txs_id;
          a2(indx) := t(ddindx).tax_determine_date;
          a3(indx) := t(ddindx).tax_rate_id;
          a4(indx) := t(ddindx).tax_rate_code;
          a5(indx) := t(ddindx).taxable_amt;
          a6(indx) := t(ddindx).tax_exemption_id;
          a7(indx) := t(ddindx).tax_rate;
          a8(indx) := t(ddindx).tax_amt;
          a9(indx) := t(ddindx).billed_yn;
          a10(indx) := t(ddindx).tax_call_type_code;
          a11(indx) := t(ddindx).program_id;
          a12(indx) := t(ddindx).request_id;
          a13(indx) := t(ddindx).program_application_id;
          a14(indx) := t(ddindx).program_update_date;
          a15(indx) := t(ddindx).attribute_category;
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
          a31(indx) := t(ddindx).created_by;
          a32(indx) := t(ddindx).creation_date;
          a33(indx) := t(ddindx).last_updated_by;
          a34(indx) := t(ddindx).last_update_date;
          a35(indx) := t(ddindx).last_update_login;
          a36(indx) := t(ddindx).object_version_number;
          a37(indx) := t(ddindx).tax_date;
          a38(indx) := t(ddindx).line_amt;
          a39(indx) := t(ddindx).internal_organization_id;
          a40(indx) := t(ddindx).application_id;
          a41(indx) := t(ddindx).entity_code;
          a42(indx) := t(ddindx).event_class_code;
          a43(indx) := t(ddindx).event_type_code;
          a44(indx) := t(ddindx).trx_id;
          a45(indx) := t(ddindx).trx_line_id;
          a46(indx) := t(ddindx).trx_level_type;
          a47(indx) := t(ddindx).trx_line_number;
          a48(indx) := t(ddindx).tax_line_number;
          a49(indx) := t(ddindx).tax_regime_id;
          a50(indx) := t(ddindx).tax_regime_code;
          a51(indx) := t(ddindx).tax_id;
          a52(indx) := t(ddindx).tax;
          a53(indx) := t(ddindx).tax_status_id;
          a54(indx) := t(ddindx).tax_status_code;
          a55(indx) := t(ddindx).tax_apportionment_line_number;
          a56(indx) := t(ddindx).legal_entity_id;
          a57(indx) := t(ddindx).trx_number;
          a58(indx) := t(ddindx).trx_date;
          a59(indx) := t(ddindx).tax_jurisdiction_id;
          a60(indx) := t(ddindx).tax_jurisdiction_code;
          a61(indx) := t(ddindx).tax_type_code;
          a62(indx) := t(ddindx).tax_currency_code;
          a63(indx) := t(ddindx).taxable_amt_tax_curr;
          a64(indx) := t(ddindx).trx_currency_code;
          a65(indx) := t(ddindx).minimum_accountable_unit;
          a66(indx) := t(ddindx).precision;
          a67(indx) := t(ddindx).currency_conversion_type;
          a68(indx) := t(ddindx).currency_conversion_rate;
          a69(indx) := t(ddindx).currency_conversion_date;
          a70(indx) := t(ddindx).tax_determination_date;
          a71(indx) := t(ddindx).taxable_amount;
          a72(indx) := t(ddindx).tax_amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p76;

  procedure rosetta_table_copy_in_p80(t out nocopy okl_process_sales_tax_pvt.sty_id_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sty_id := a0(indx);
          t(ddindx).sty_code := a1(indx);
          t(ddindx).sty_purpose := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p80;
  procedure rosetta_table_copy_out_p80(t okl_process_sales_tax_pvt.sty_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).sty_id;
          a1(indx) := t(ddindx).sty_code;
          a2(indx) := t(ddindx).sty_purpose;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p80;

  procedure rosetta_table_copy_in_p81(t out nocopy okl_process_sales_tax_pvt.prev_tx_src_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).org_id := a1(indx);
          t(ddindx).application_id := a2(indx);
          t(ddindx).entity_code := a3(indx);
          t(ddindx).event_class_code := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p81;
  procedure rosetta_table_copy_out_p81(t okl_process_sales_tax_pvt.prev_tx_src_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).org_id;
          a2(indx) := t(ddindx).application_id;
          a3(indx) := t(ddindx).entity_code;
          a4(indx) := t(ddindx).event_class_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p81;

  procedure rosetta_table_copy_in_p83(t out nocopy okl_process_sales_tax_pvt.asset_level_det_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).fin_asset_id := a0(indx);
          t(ddindx).asset_number := a1(indx);
          t(ddindx).transfer_of_title := a2(indx);
          t(ddindx).sale_lease_back := a3(indx);
          t(ddindx).purchase_of_lease := a4(indx);
          t(ddindx).usage_of_equipment := a5(indx);
          t(ddindx).vendor_site_id := a6(indx);
          t(ddindx).age_of_equipment := a7(indx);
          t(ddindx).inv_item_id := a8(indx);
          t(ddindx).inv_org_id := a9(indx);
          t(ddindx).ship_to_site_use_id := a10(indx);
          t(ddindx).asset_pymnt_exist := a11(indx);
          t(ddindx).bill_to_party_site_id := a12(indx);
          t(ddindx).bill_to_location_id := a13(indx);
          t(ddindx).bill_to_party_id := a14(indx);
          t(ddindx).bill_to_site_use_id := a15(indx);
          t(ddindx).ship_to_party_site_id := a16(indx);
          t(ddindx).ship_to_location_id := a17(indx);
          t(ddindx).ship_to_party_id := a18(indx);
          t(ddindx).sty_id := a19(indx);
          t(ddindx).amount := a20(indx);
          t(ddindx).try_id := a21(indx);
          t(ddindx).trx_line_id := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p83;
  procedure rosetta_table_copy_out_p83(t okl_process_sales_tax_pvt.asset_level_det_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).fin_asset_id;
          a1(indx) := t(ddindx).asset_number;
          a2(indx) := t(ddindx).transfer_of_title;
          a3(indx) := t(ddindx).sale_lease_back;
          a4(indx) := t(ddindx).purchase_of_lease;
          a5(indx) := t(ddindx).usage_of_equipment;
          a6(indx) := t(ddindx).vendor_site_id;
          a7(indx) := t(ddindx).age_of_equipment;
          a8(indx) := t(ddindx).inv_item_id;
          a9(indx) := t(ddindx).inv_org_id;
          a10(indx) := t(ddindx).ship_to_site_use_id;
          a11(indx) := t(ddindx).asset_pymnt_exist;
          a12(indx) := t(ddindx).bill_to_party_site_id;
          a13(indx) := t(ddindx).bill_to_location_id;
          a14(indx) := t(ddindx).bill_to_party_id;
          a15(indx) := t(ddindx).bill_to_site_use_id;
          a16(indx) := t(ddindx).ship_to_party_site_id;
          a17(indx) := t(ddindx).ship_to_location_id;
          a18(indx) := t(ddindx).ship_to_party_id;
          a19(indx) := t(ddindx).sty_id;
          a20(indx) := t(ddindx).amount;
          a21(indx) := t(ddindx).try_id;
          a22(indx) := t(ddindx).trx_line_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p83;

  procedure get_billing_stream_types(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_org_id  NUMBER
    , p_sty_code  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_sty_id_tbl okl_process_sales_tax_pvt.sty_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_process_sales_tax_pvt.get_billing_stream_types(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_org_id,
      p_sty_code,
      ddx_sty_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_process_sales_tax_pvt_w.rosetta_table_copy_out_p80(ddx_sty_id_tbl, p7_a0
      , p7_a1
      , p7_a2
      );
  end;

  procedure get_tax_determinants(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_trx_id  NUMBER
    , p_source_trx_name  VARCHAR2
    , p_source_table  VARCHAR2
    , p8_a0 out nocopy  VARCHAR2
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
  )

  as
    ddx_tax_det_rec okl_process_sales_tax_pvt.tax_det_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okl_process_sales_tax_pvt.get_tax_determinants(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_trx_id,
      p_source_trx_name,
      p_source_table,
      ddx_tax_det_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_tax_det_rec.x_tax_code;
    p8_a1 := ddx_tax_det_rec.x_trx_business_category;
    p8_a2 := ddx_tax_det_rec.x_product_category;
    p8_a3 := ddx_tax_det_rec.x_product_type;
    p8_a4 := ddx_tax_det_rec.x_line_intended_use;
    p8_a5 := ddx_tax_det_rec.x_user_defined_fisc_class;
    p8_a6 := ddx_tax_det_rec.x_assessable_value;
    p8_a7 := ddx_tax_det_rec.x_default_taxation_country;
    p8_a8 := ddx_tax_det_rec.x_upstream_trx_reported_flag;
  end;

end okl_process_sales_tax_pvt_w;

/
