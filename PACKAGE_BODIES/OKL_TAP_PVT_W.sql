--------------------------------------------------------
--  DDL for Package Body OKL_TAP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAP_PVT_W" as
  /* $Header: OKLITAPB.pls 120.2 2007/11/06 07:35:09 veramach ship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy okl_tap_pvt.tap_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_DATE_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_500
    , a46 JTF_VARCHAR2_TABLE_500
    , a47 JTF_VARCHAR2_TABLE_500
    , a48 JTF_VARCHAR2_TABLE_500
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_500
    , a51 JTF_VARCHAR2_TABLE_500
    , a52 JTF_VARCHAR2_TABLE_500
    , a53 JTF_VARCHAR2_TABLE_500
    , a54 JTF_VARCHAR2_TABLE_500
    , a55 JTF_VARCHAR2_TABLE_500
    , a56 JTF_VARCHAR2_TABLE_500
    , a57 JTF_VARCHAR2_TABLE_500
    , a58 JTF_VARCHAR2_TABLE_500
    , a59 JTF_VARCHAR2_TABLE_500
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_DATE_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_DATE_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).currency_code := a1(indx);
          t(ddindx).payment_method_code := a2(indx);
          t(ddindx).funding_type_code := a3(indx);
          t(ddindx).invoice_category_code := a4(indx);
          t(ddindx).ipvs_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).ccf_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).cct_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).cplv_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).pox_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).ippt_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).code_combination_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).qte_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).art_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).tcn_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).vpa_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).ipt_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).tap_id_reverses := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).date_entered := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).date_invoiced := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).trx_status_code := a22(indx);
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).try_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).date_requisition := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).date_funding_approved := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).invoice_number := a28(indx);
          t(ddindx).date_gl := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).workflow_yn := a30(indx);
          t(ddindx).match_required_yn := a31(indx);
          t(ddindx).ipt_frequency := a32(indx);
          t(ddindx).consolidate_yn := a33(indx);
          t(ddindx).wait_vendor_invoice_yn := a34(indx);
          t(ddindx).request_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a38(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).currency_conversion_type := a40(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).attribute_category := a44(indx);
          t(ddindx).attribute1 := a45(indx);
          t(ddindx).attribute2 := a46(indx);
          t(ddindx).attribute3 := a47(indx);
          t(ddindx).attribute4 := a48(indx);
          t(ddindx).attribute5 := a49(indx);
          t(ddindx).attribute6 := a50(indx);
          t(ddindx).attribute7 := a51(indx);
          t(ddindx).attribute8 := a52(indx);
          t(ddindx).attribute9 := a53(indx);
          t(ddindx).attribute10 := a54(indx);
          t(ddindx).attribute11 := a55(indx);
          t(ddindx).attribute12 := a56(indx);
          t(ddindx).attribute13 := a57(indx);
          t(ddindx).attribute14 := a58(indx);
          t(ddindx).attribute15 := a59(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a61(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a63(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).invoice_type := a65(indx);
          t(ddindx).pay_group_lookup_code := a66(indx);
          t(ddindx).vendor_invoice_number := a67(indx);
          t(ddindx).nettable_yn := a68(indx);
          t(ddindx).asset_tap_id := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a71(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_tap_pvt.tap_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_500
    , a46 out nocopy JTF_VARCHAR2_TABLE_500
    , a47 out nocopy JTF_VARCHAR2_TABLE_500
    , a48 out nocopy JTF_VARCHAR2_TABLE_500
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_VARCHAR2_TABLE_500
    , a51 out nocopy JTF_VARCHAR2_TABLE_500
    , a52 out nocopy JTF_VARCHAR2_TABLE_500
    , a53 out nocopy JTF_VARCHAR2_TABLE_500
    , a54 out nocopy JTF_VARCHAR2_TABLE_500
    , a55 out nocopy JTF_VARCHAR2_TABLE_500
    , a56 out nocopy JTF_VARCHAR2_TABLE_500
    , a57 out nocopy JTF_VARCHAR2_TABLE_500
    , a58 out nocopy JTF_VARCHAR2_TABLE_500
    , a59 out nocopy JTF_VARCHAR2_TABLE_500
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_DATE_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_DATE_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_500();
    a46 := JTF_VARCHAR2_TABLE_500();
    a47 := JTF_VARCHAR2_TABLE_500();
    a48 := JTF_VARCHAR2_TABLE_500();
    a49 := JTF_VARCHAR2_TABLE_500();
    a50 := JTF_VARCHAR2_TABLE_500();
    a51 := JTF_VARCHAR2_TABLE_500();
    a52 := JTF_VARCHAR2_TABLE_500();
    a53 := JTF_VARCHAR2_TABLE_500();
    a54 := JTF_VARCHAR2_TABLE_500();
    a55 := JTF_VARCHAR2_TABLE_500();
    a56 := JTF_VARCHAR2_TABLE_500();
    a57 := JTF_VARCHAR2_TABLE_500();
    a58 := JTF_VARCHAR2_TABLE_500();
    a59 := JTF_VARCHAR2_TABLE_500();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_DATE_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_DATE_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_VARCHAR2_TABLE_300();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_500();
      a46 := JTF_VARCHAR2_TABLE_500();
      a47 := JTF_VARCHAR2_TABLE_500();
      a48 := JTF_VARCHAR2_TABLE_500();
      a49 := JTF_VARCHAR2_TABLE_500();
      a50 := JTF_VARCHAR2_TABLE_500();
      a51 := JTF_VARCHAR2_TABLE_500();
      a52 := JTF_VARCHAR2_TABLE_500();
      a53 := JTF_VARCHAR2_TABLE_500();
      a54 := JTF_VARCHAR2_TABLE_500();
      a55 := JTF_VARCHAR2_TABLE_500();
      a56 := JTF_VARCHAR2_TABLE_500();
      a57 := JTF_VARCHAR2_TABLE_500();
      a58 := JTF_VARCHAR2_TABLE_500();
      a59 := JTF_VARCHAR2_TABLE_500();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_DATE_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_DATE_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_VARCHAR2_TABLE_300();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).currency_code;
          a2(indx) := t(ddindx).payment_method_code;
          a3(indx) := t(ddindx).funding_type_code;
          a4(indx) := t(ddindx).invoice_category_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).ipvs_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).ccf_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).cct_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).cplv_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).pox_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).ippt_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).code_combination_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).art_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).tcn_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).vpa_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).ipt_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).tap_id_reverses);
          a19(indx) := t(ddindx).date_entered;
          a20(indx) := t(ddindx).date_invoiced;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a22(indx) := t(ddindx).trx_status_code;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).try_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a26(indx) := t(ddindx).date_requisition;
          a27(indx) := t(ddindx).date_funding_approved;
          a28(indx) := t(ddindx).invoice_number;
          a29(indx) := t(ddindx).date_gl;
          a30(indx) := t(ddindx).workflow_yn;
          a31(indx) := t(ddindx).match_required_yn;
          a32(indx) := t(ddindx).ipt_frequency;
          a33(indx) := t(ddindx).consolidate_yn;
          a34(indx) := t(ddindx).wait_vendor_invoice_yn;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a38(indx) := t(ddindx).program_update_date;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a40(indx) := t(ddindx).currency_conversion_type;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a42(indx) := t(ddindx).currency_conversion_date;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a44(indx) := t(ddindx).attribute_category;
          a45(indx) := t(ddindx).attribute1;
          a46(indx) := t(ddindx).attribute2;
          a47(indx) := t(ddindx).attribute3;
          a48(indx) := t(ddindx).attribute4;
          a49(indx) := t(ddindx).attribute5;
          a50(indx) := t(ddindx).attribute6;
          a51(indx) := t(ddindx).attribute7;
          a52(indx) := t(ddindx).attribute8;
          a53(indx) := t(ddindx).attribute9;
          a54(indx) := t(ddindx).attribute10;
          a55(indx) := t(ddindx).attribute11;
          a56(indx) := t(ddindx).attribute12;
          a57(indx) := t(ddindx).attribute13;
          a58(indx) := t(ddindx).attribute14;
          a59(indx) := t(ddindx).attribute15;
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a61(indx) := t(ddindx).creation_date;
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a63(indx) := t(ddindx).last_update_date;
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a65(indx) := t(ddindx).invoice_type;
          a66(indx) := t(ddindx).pay_group_lookup_code;
          a67(indx) := t(ddindx).vendor_invoice_number;
          a68(indx) := t(ddindx).nettable_yn;
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).asset_tap_id);
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          a71(indx) := t(ddindx).transaction_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_tap_pvt.okltrxapinvoicestltbltype, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).language := a1(indx);
          t(ddindx).source_lang := a2(indx);
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a9(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_tap_pvt.okltrxapinvoicestltbltype, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).source_lang;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).description;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_tap_pvt.tapv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_DATE_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_DATE_TABLE
    , a32 JTF_VARCHAR2_TABLE_2000
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_500
    , a39 JTF_VARCHAR2_TABLE_500
    , a40 JTF_VARCHAR2_TABLE_500
    , a41 JTF_VARCHAR2_TABLE_500
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_VARCHAR2_TABLE_500
    , a44 JTF_VARCHAR2_TABLE_500
    , a45 JTF_VARCHAR2_TABLE_500
    , a46 JTF_VARCHAR2_TABLE_500
    , a47 JTF_VARCHAR2_TABLE_500
    , a48 JTF_VARCHAR2_TABLE_500
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_500
    , a51 JTF_VARCHAR2_TABLE_500
    , a52 JTF_VARCHAR2_TABLE_500
    , a53 JTF_DATE_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_DATE_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_DATE_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_DATE_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).sfwt_flag := a2(indx);
          t(ddindx).cct_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).currency_code := a4(indx);
          t(ddindx).ccf_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).funding_type_code := a6(indx);
          t(ddindx).khr_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).art_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).tap_id_reverses := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).ippt_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).code_combination_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).ipvs_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).tcn_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).vpa_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).ipt_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).qte_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).invoice_category_code := a17(indx);
          t(ddindx).payment_method_code := a18(indx);
          t(ddindx).cplv_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).pox_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).date_invoiced := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).invoice_number := a23(indx);
          t(ddindx).date_funding_approved := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).date_gl := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).workflow_yn := a26(indx);
          t(ddindx).match_required_yn := a27(indx);
          t(ddindx).ipt_frequency := a28(indx);
          t(ddindx).consolidate_yn := a29(indx);
          t(ddindx).wait_vendor_invoice_yn := a30(indx);
          t(ddindx).date_requisition := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).description := a32(indx);
          t(ddindx).currency_conversion_type := a33(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a35(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).attribute_category := a37(indx);
          t(ddindx).attribute1 := a38(indx);
          t(ddindx).attribute2 := a39(indx);
          t(ddindx).attribute3 := a40(indx);
          t(ddindx).attribute4 := a41(indx);
          t(ddindx).attribute5 := a42(indx);
          t(ddindx).attribute6 := a43(indx);
          t(ddindx).attribute7 := a44(indx);
          t(ddindx).attribute8 := a45(indx);
          t(ddindx).attribute9 := a46(indx);
          t(ddindx).attribute10 := a47(indx);
          t(ddindx).attribute11 := a48(indx);
          t(ddindx).attribute12 := a49(indx);
          t(ddindx).attribute13 := a50(indx);
          t(ddindx).attribute14 := a51(indx);
          t(ddindx).attribute15 := a52(indx);
          t(ddindx).date_entered := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).trx_status_code := a54(indx);
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).try_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a60(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a63(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a65(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).invoice_type := a67(indx);
          t(ddindx).pay_group_lookup_code := a68(indx);
          t(ddindx).vendor_invoice_number := a69(indx);
          t(ddindx).nettable_yn := a70(indx);
          t(ddindx).asset_tap_id := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a73(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_tap_pvt.tapv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_500
    , a39 out nocopy JTF_VARCHAR2_TABLE_500
    , a40 out nocopy JTF_VARCHAR2_TABLE_500
    , a41 out nocopy JTF_VARCHAR2_TABLE_500
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_VARCHAR2_TABLE_500
    , a44 out nocopy JTF_VARCHAR2_TABLE_500
    , a45 out nocopy JTF_VARCHAR2_TABLE_500
    , a46 out nocopy JTF_VARCHAR2_TABLE_500
    , a47 out nocopy JTF_VARCHAR2_TABLE_500
    , a48 out nocopy JTF_VARCHAR2_TABLE_500
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_VARCHAR2_TABLE_500
    , a51 out nocopy JTF_VARCHAR2_TABLE_500
    , a52 out nocopy JTF_VARCHAR2_TABLE_500
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_DATE_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_DATE_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_DATE_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_VARCHAR2_TABLE_2000();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_500();
    a39 := JTF_VARCHAR2_TABLE_500();
    a40 := JTF_VARCHAR2_TABLE_500();
    a41 := JTF_VARCHAR2_TABLE_500();
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_VARCHAR2_TABLE_500();
    a44 := JTF_VARCHAR2_TABLE_500();
    a45 := JTF_VARCHAR2_TABLE_500();
    a46 := JTF_VARCHAR2_TABLE_500();
    a47 := JTF_VARCHAR2_TABLE_500();
    a48 := JTF_VARCHAR2_TABLE_500();
    a49 := JTF_VARCHAR2_TABLE_500();
    a50 := JTF_VARCHAR2_TABLE_500();
    a51 := JTF_VARCHAR2_TABLE_500();
    a52 := JTF_VARCHAR2_TABLE_500();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_DATE_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_DATE_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_DATE_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_VARCHAR2_TABLE_300();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_300();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_VARCHAR2_TABLE_2000();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_500();
      a39 := JTF_VARCHAR2_TABLE_500();
      a40 := JTF_VARCHAR2_TABLE_500();
      a41 := JTF_VARCHAR2_TABLE_500();
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_VARCHAR2_TABLE_500();
      a44 := JTF_VARCHAR2_TABLE_500();
      a45 := JTF_VARCHAR2_TABLE_500();
      a46 := JTF_VARCHAR2_TABLE_500();
      a47 := JTF_VARCHAR2_TABLE_500();
      a48 := JTF_VARCHAR2_TABLE_500();
      a49 := JTF_VARCHAR2_TABLE_500();
      a50 := JTF_VARCHAR2_TABLE_500();
      a51 := JTF_VARCHAR2_TABLE_500();
      a52 := JTF_VARCHAR2_TABLE_500();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_DATE_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_DATE_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_DATE_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_VARCHAR2_TABLE_300();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_300();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).cct_id);
          a4(indx) := t(ddindx).currency_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).ccf_id);
          a6(indx) := t(ddindx).funding_type_code;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).art_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).tap_id_reverses);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).ippt_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).code_combination_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).ipvs_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).tcn_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).vpa_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).ipt_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a17(indx) := t(ddindx).invoice_category_code;
          a18(indx) := t(ddindx).payment_method_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).cplv_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).pox_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a22(indx) := t(ddindx).date_invoiced;
          a23(indx) := t(ddindx).invoice_number;
          a24(indx) := t(ddindx).date_funding_approved;
          a25(indx) := t(ddindx).date_gl;
          a26(indx) := t(ddindx).workflow_yn;
          a27(indx) := t(ddindx).match_required_yn;
          a28(indx) := t(ddindx).ipt_frequency;
          a29(indx) := t(ddindx).consolidate_yn;
          a30(indx) := t(ddindx).wait_vendor_invoice_yn;
          a31(indx) := t(ddindx).date_requisition;
          a32(indx) := t(ddindx).description;
          a33(indx) := t(ddindx).currency_conversion_type;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a35(indx) := t(ddindx).currency_conversion_date;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a37(indx) := t(ddindx).attribute_category;
          a38(indx) := t(ddindx).attribute1;
          a39(indx) := t(ddindx).attribute2;
          a40(indx) := t(ddindx).attribute3;
          a41(indx) := t(ddindx).attribute4;
          a42(indx) := t(ddindx).attribute5;
          a43(indx) := t(ddindx).attribute6;
          a44(indx) := t(ddindx).attribute7;
          a45(indx) := t(ddindx).attribute8;
          a46(indx) := t(ddindx).attribute9;
          a47(indx) := t(ddindx).attribute10;
          a48(indx) := t(ddindx).attribute11;
          a49(indx) := t(ddindx).attribute12;
          a50(indx) := t(ddindx).attribute13;
          a51(indx) := t(ddindx).attribute14;
          a52(indx) := t(ddindx).attribute15;
          a53(indx) := t(ddindx).date_entered;
          a54(indx) := t(ddindx).trx_status_code;
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).try_id);
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a60(indx) := t(ddindx).program_update_date;
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a63(indx) := t(ddindx).creation_date;
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a65(indx) := t(ddindx).last_update_date;
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a67(indx) := t(ddindx).invoice_type;
          a68(indx) := t(ddindx).pay_group_lookup_code;
          a69(indx) := t(ddindx).vendor_invoice_number;
          a70(indx) := t(ddindx).nettable_yn;
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).asset_tap_id);
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          a73(indx) := t(ddindx).transaction_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  DATE
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  DATE := fnd_api.g_miss_date
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tapv_rec okl_tap_pvt.tapv_rec_type;
    ddx_tapv_rec okl_tap_pvt.tapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tapv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tapv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tapv_rec.sfwt_flag := p5_a2;
    ddp_tapv_rec.cct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tapv_rec.currency_code := p5_a4;
    ddp_tapv_rec.ccf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tapv_rec.funding_type_code := p5_a6;
    ddp_tapv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tapv_rec.art_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tapv_rec.tap_id_reverses := rosetta_g_miss_num_map(p5_a9);
    ddp_tapv_rec.ippt_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tapv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tapv_rec.ipvs_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tapv_rec.tcn_id := rosetta_g_miss_num_map(p5_a13);
    ddp_tapv_rec.vpa_id := rosetta_g_miss_num_map(p5_a14);
    ddp_tapv_rec.ipt_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tapv_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_tapv_rec.invoice_category_code := p5_a17;
    ddp_tapv_rec.payment_method_code := p5_a18;
    ddp_tapv_rec.cplv_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tapv_rec.pox_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tapv_rec.amount := rosetta_g_miss_num_map(p5_a21);
    ddp_tapv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a22);
    ddp_tapv_rec.invoice_number := p5_a23;
    ddp_tapv_rec.date_funding_approved := rosetta_g_miss_date_in_map(p5_a24);
    ddp_tapv_rec.date_gl := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tapv_rec.workflow_yn := p5_a26;
    ddp_tapv_rec.match_required_yn := p5_a27;
    ddp_tapv_rec.ipt_frequency := p5_a28;
    ddp_tapv_rec.consolidate_yn := p5_a29;
    ddp_tapv_rec.wait_vendor_invoice_yn := p5_a30;
    ddp_tapv_rec.date_requisition := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tapv_rec.description := p5_a32;
    ddp_tapv_rec.currency_conversion_type := p5_a33;
    ddp_tapv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a34);
    ddp_tapv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tapv_rec.vendor_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tapv_rec.attribute_category := p5_a37;
    ddp_tapv_rec.attribute1 := p5_a38;
    ddp_tapv_rec.attribute2 := p5_a39;
    ddp_tapv_rec.attribute3 := p5_a40;
    ddp_tapv_rec.attribute4 := p5_a41;
    ddp_tapv_rec.attribute5 := p5_a42;
    ddp_tapv_rec.attribute6 := p5_a43;
    ddp_tapv_rec.attribute7 := p5_a44;
    ddp_tapv_rec.attribute8 := p5_a45;
    ddp_tapv_rec.attribute9 := p5_a46;
    ddp_tapv_rec.attribute10 := p5_a47;
    ddp_tapv_rec.attribute11 := p5_a48;
    ddp_tapv_rec.attribute12 := p5_a49;
    ddp_tapv_rec.attribute13 := p5_a50;
    ddp_tapv_rec.attribute14 := p5_a51;
    ddp_tapv_rec.attribute15 := p5_a52;
    ddp_tapv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tapv_rec.trx_status_code := p5_a54;
    ddp_tapv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a55);
    ddp_tapv_rec.try_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tapv_rec.request_id := rosetta_g_miss_num_map(p5_a57);
    ddp_tapv_rec.program_application_id := rosetta_g_miss_num_map(p5_a58);
    ddp_tapv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_tapv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a60);
    ddp_tapv_rec.org_id := rosetta_g_miss_num_map(p5_a61);
    ddp_tapv_rec.created_by := rosetta_g_miss_num_map(p5_a62);
    ddp_tapv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_tapv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a64);
    ddp_tapv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_tapv_rec.last_update_login := rosetta_g_miss_num_map(p5_a66);
    ddp_tapv_rec.invoice_type := p5_a67;
    ddp_tapv_rec.pay_group_lookup_code := p5_a68;
    ddp_tapv_rec.vendor_invoice_number := p5_a69;
    ddp_tapv_rec.nettable_yn := p5_a70;
    ddp_tapv_rec.asset_tap_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tapv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a72);
    ddp_tapv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);


    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_rec,
      ddx_tapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tapv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tapv_rec.object_version_number);
    p6_a2 := ddx_tapv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_tapv_rec.cct_id);
    p6_a4 := ddx_tapv_rec.currency_code;
    p6_a5 := rosetta_g_miss_num_map(ddx_tapv_rec.ccf_id);
    p6_a6 := ddx_tapv_rec.funding_type_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_tapv_rec.khr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_tapv_rec.art_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tapv_rec.tap_id_reverses);
    p6_a10 := rosetta_g_miss_num_map(ddx_tapv_rec.ippt_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tapv_rec.code_combination_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_tapv_rec.ipvs_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_tapv_rec.tcn_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_tapv_rec.vpa_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_tapv_rec.ipt_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_tapv_rec.qte_id);
    p6_a17 := ddx_tapv_rec.invoice_category_code;
    p6_a18 := ddx_tapv_rec.payment_method_code;
    p6_a19 := rosetta_g_miss_num_map(ddx_tapv_rec.cplv_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_tapv_rec.pox_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_tapv_rec.amount);
    p6_a22 := ddx_tapv_rec.date_invoiced;
    p6_a23 := ddx_tapv_rec.invoice_number;
    p6_a24 := ddx_tapv_rec.date_funding_approved;
    p6_a25 := ddx_tapv_rec.date_gl;
    p6_a26 := ddx_tapv_rec.workflow_yn;
    p6_a27 := ddx_tapv_rec.match_required_yn;
    p6_a28 := ddx_tapv_rec.ipt_frequency;
    p6_a29 := ddx_tapv_rec.consolidate_yn;
    p6_a30 := ddx_tapv_rec.wait_vendor_invoice_yn;
    p6_a31 := ddx_tapv_rec.date_requisition;
    p6_a32 := ddx_tapv_rec.description;
    p6_a33 := ddx_tapv_rec.currency_conversion_type;
    p6_a34 := rosetta_g_miss_num_map(ddx_tapv_rec.currency_conversion_rate);
    p6_a35 := ddx_tapv_rec.currency_conversion_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_tapv_rec.vendor_id);
    p6_a37 := ddx_tapv_rec.attribute_category;
    p6_a38 := ddx_tapv_rec.attribute1;
    p6_a39 := ddx_tapv_rec.attribute2;
    p6_a40 := ddx_tapv_rec.attribute3;
    p6_a41 := ddx_tapv_rec.attribute4;
    p6_a42 := ddx_tapv_rec.attribute5;
    p6_a43 := ddx_tapv_rec.attribute6;
    p6_a44 := ddx_tapv_rec.attribute7;
    p6_a45 := ddx_tapv_rec.attribute8;
    p6_a46 := ddx_tapv_rec.attribute9;
    p6_a47 := ddx_tapv_rec.attribute10;
    p6_a48 := ddx_tapv_rec.attribute11;
    p6_a49 := ddx_tapv_rec.attribute12;
    p6_a50 := ddx_tapv_rec.attribute13;
    p6_a51 := ddx_tapv_rec.attribute14;
    p6_a52 := ddx_tapv_rec.attribute15;
    p6_a53 := ddx_tapv_rec.date_entered;
    p6_a54 := ddx_tapv_rec.trx_status_code;
    p6_a55 := rosetta_g_miss_num_map(ddx_tapv_rec.set_of_books_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_tapv_rec.try_id);
    p6_a57 := rosetta_g_miss_num_map(ddx_tapv_rec.request_id);
    p6_a58 := rosetta_g_miss_num_map(ddx_tapv_rec.program_application_id);
    p6_a59 := rosetta_g_miss_num_map(ddx_tapv_rec.program_id);
    p6_a60 := ddx_tapv_rec.program_update_date;
    p6_a61 := rosetta_g_miss_num_map(ddx_tapv_rec.org_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_tapv_rec.created_by);
    p6_a63 := ddx_tapv_rec.creation_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_tapv_rec.last_updated_by);
    p6_a65 := ddx_tapv_rec.last_update_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_tapv_rec.last_update_login);
    p6_a67 := ddx_tapv_rec.invoice_type;
    p6_a68 := ddx_tapv_rec.pay_group_lookup_code;
    p6_a69 := ddx_tapv_rec.vendor_invoice_number;
    p6_a70 := ddx_tapv_rec.nettable_yn;
    p6_a71 := rosetta_g_miss_num_map(ddx_tapv_rec.asset_tap_id);
    p6_a72 := rosetta_g_miss_num_map(ddx_tapv_rec.legal_entity_id);
    p6_a73 := ddx_tapv_rec.transaction_date;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_2000
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_DATE_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_VARCHAR2_TABLE_300
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_300
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_DATE_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_DATE_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_tapv_tbl okl_tap_pvt.tapv_tbl_type;
    ddx_tapv_tbl okl_tap_pvt.tapv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tap_pvt_w.rosetta_table_copy_in_p8(ddp_tapv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_tbl,
      ddx_tapv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tap_pvt_w.rosetta_table_copy_out_p8(ddx_tapv_tbl, p6_a0
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
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  DATE := fnd_api.g_miss_date
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tapv_rec okl_tap_pvt.tapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tapv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tapv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tapv_rec.sfwt_flag := p5_a2;
    ddp_tapv_rec.cct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tapv_rec.currency_code := p5_a4;
    ddp_tapv_rec.ccf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tapv_rec.funding_type_code := p5_a6;
    ddp_tapv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tapv_rec.art_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tapv_rec.tap_id_reverses := rosetta_g_miss_num_map(p5_a9);
    ddp_tapv_rec.ippt_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tapv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tapv_rec.ipvs_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tapv_rec.tcn_id := rosetta_g_miss_num_map(p5_a13);
    ddp_tapv_rec.vpa_id := rosetta_g_miss_num_map(p5_a14);
    ddp_tapv_rec.ipt_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tapv_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_tapv_rec.invoice_category_code := p5_a17;
    ddp_tapv_rec.payment_method_code := p5_a18;
    ddp_tapv_rec.cplv_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tapv_rec.pox_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tapv_rec.amount := rosetta_g_miss_num_map(p5_a21);
    ddp_tapv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a22);
    ddp_tapv_rec.invoice_number := p5_a23;
    ddp_tapv_rec.date_funding_approved := rosetta_g_miss_date_in_map(p5_a24);
    ddp_tapv_rec.date_gl := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tapv_rec.workflow_yn := p5_a26;
    ddp_tapv_rec.match_required_yn := p5_a27;
    ddp_tapv_rec.ipt_frequency := p5_a28;
    ddp_tapv_rec.consolidate_yn := p5_a29;
    ddp_tapv_rec.wait_vendor_invoice_yn := p5_a30;
    ddp_tapv_rec.date_requisition := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tapv_rec.description := p5_a32;
    ddp_tapv_rec.currency_conversion_type := p5_a33;
    ddp_tapv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a34);
    ddp_tapv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tapv_rec.vendor_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tapv_rec.attribute_category := p5_a37;
    ddp_tapv_rec.attribute1 := p5_a38;
    ddp_tapv_rec.attribute2 := p5_a39;
    ddp_tapv_rec.attribute3 := p5_a40;
    ddp_tapv_rec.attribute4 := p5_a41;
    ddp_tapv_rec.attribute5 := p5_a42;
    ddp_tapv_rec.attribute6 := p5_a43;
    ddp_tapv_rec.attribute7 := p5_a44;
    ddp_tapv_rec.attribute8 := p5_a45;
    ddp_tapv_rec.attribute9 := p5_a46;
    ddp_tapv_rec.attribute10 := p5_a47;
    ddp_tapv_rec.attribute11 := p5_a48;
    ddp_tapv_rec.attribute12 := p5_a49;
    ddp_tapv_rec.attribute13 := p5_a50;
    ddp_tapv_rec.attribute14 := p5_a51;
    ddp_tapv_rec.attribute15 := p5_a52;
    ddp_tapv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tapv_rec.trx_status_code := p5_a54;
    ddp_tapv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a55);
    ddp_tapv_rec.try_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tapv_rec.request_id := rosetta_g_miss_num_map(p5_a57);
    ddp_tapv_rec.program_application_id := rosetta_g_miss_num_map(p5_a58);
    ddp_tapv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_tapv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a60);
    ddp_tapv_rec.org_id := rosetta_g_miss_num_map(p5_a61);
    ddp_tapv_rec.created_by := rosetta_g_miss_num_map(p5_a62);
    ddp_tapv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_tapv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a64);
    ddp_tapv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_tapv_rec.last_update_login := rosetta_g_miss_num_map(p5_a66);
    ddp_tapv_rec.invoice_type := p5_a67;
    ddp_tapv_rec.pay_group_lookup_code := p5_a68;
    ddp_tapv_rec.vendor_invoice_number := p5_a69;
    ddp_tapv_rec.nettable_yn := p5_a70;
    ddp_tapv_rec.asset_tap_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tapv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a72);
    ddp_tapv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);

    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_2000
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_DATE_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_VARCHAR2_TABLE_300
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_300
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
  )

  as
    ddp_tapv_tbl okl_tap_pvt.tapv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tap_pvt_w.rosetta_table_copy_in_p8(ddp_tapv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  DATE
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  DATE := fnd_api.g_miss_date
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tapv_rec okl_tap_pvt.tapv_rec_type;
    ddx_tapv_rec okl_tap_pvt.tapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tapv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tapv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tapv_rec.sfwt_flag := p5_a2;
    ddp_tapv_rec.cct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tapv_rec.currency_code := p5_a4;
    ddp_tapv_rec.ccf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tapv_rec.funding_type_code := p5_a6;
    ddp_tapv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tapv_rec.art_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tapv_rec.tap_id_reverses := rosetta_g_miss_num_map(p5_a9);
    ddp_tapv_rec.ippt_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tapv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tapv_rec.ipvs_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tapv_rec.tcn_id := rosetta_g_miss_num_map(p5_a13);
    ddp_tapv_rec.vpa_id := rosetta_g_miss_num_map(p5_a14);
    ddp_tapv_rec.ipt_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tapv_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_tapv_rec.invoice_category_code := p5_a17;
    ddp_tapv_rec.payment_method_code := p5_a18;
    ddp_tapv_rec.cplv_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tapv_rec.pox_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tapv_rec.amount := rosetta_g_miss_num_map(p5_a21);
    ddp_tapv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a22);
    ddp_tapv_rec.invoice_number := p5_a23;
    ddp_tapv_rec.date_funding_approved := rosetta_g_miss_date_in_map(p5_a24);
    ddp_tapv_rec.date_gl := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tapv_rec.workflow_yn := p5_a26;
    ddp_tapv_rec.match_required_yn := p5_a27;
    ddp_tapv_rec.ipt_frequency := p5_a28;
    ddp_tapv_rec.consolidate_yn := p5_a29;
    ddp_tapv_rec.wait_vendor_invoice_yn := p5_a30;
    ddp_tapv_rec.date_requisition := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tapv_rec.description := p5_a32;
    ddp_tapv_rec.currency_conversion_type := p5_a33;
    ddp_tapv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a34);
    ddp_tapv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tapv_rec.vendor_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tapv_rec.attribute_category := p5_a37;
    ddp_tapv_rec.attribute1 := p5_a38;
    ddp_tapv_rec.attribute2 := p5_a39;
    ddp_tapv_rec.attribute3 := p5_a40;
    ddp_tapv_rec.attribute4 := p5_a41;
    ddp_tapv_rec.attribute5 := p5_a42;
    ddp_tapv_rec.attribute6 := p5_a43;
    ddp_tapv_rec.attribute7 := p5_a44;
    ddp_tapv_rec.attribute8 := p5_a45;
    ddp_tapv_rec.attribute9 := p5_a46;
    ddp_tapv_rec.attribute10 := p5_a47;
    ddp_tapv_rec.attribute11 := p5_a48;
    ddp_tapv_rec.attribute12 := p5_a49;
    ddp_tapv_rec.attribute13 := p5_a50;
    ddp_tapv_rec.attribute14 := p5_a51;
    ddp_tapv_rec.attribute15 := p5_a52;
    ddp_tapv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tapv_rec.trx_status_code := p5_a54;
    ddp_tapv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a55);
    ddp_tapv_rec.try_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tapv_rec.request_id := rosetta_g_miss_num_map(p5_a57);
    ddp_tapv_rec.program_application_id := rosetta_g_miss_num_map(p5_a58);
    ddp_tapv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_tapv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a60);
    ddp_tapv_rec.org_id := rosetta_g_miss_num_map(p5_a61);
    ddp_tapv_rec.created_by := rosetta_g_miss_num_map(p5_a62);
    ddp_tapv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_tapv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a64);
    ddp_tapv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_tapv_rec.last_update_login := rosetta_g_miss_num_map(p5_a66);
    ddp_tapv_rec.invoice_type := p5_a67;
    ddp_tapv_rec.pay_group_lookup_code := p5_a68;
    ddp_tapv_rec.vendor_invoice_number := p5_a69;
    ddp_tapv_rec.nettable_yn := p5_a70;
    ddp_tapv_rec.asset_tap_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tapv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a72);
    ddp_tapv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);


    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_rec,
      ddx_tapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tapv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tapv_rec.object_version_number);
    p6_a2 := ddx_tapv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_tapv_rec.cct_id);
    p6_a4 := ddx_tapv_rec.currency_code;
    p6_a5 := rosetta_g_miss_num_map(ddx_tapv_rec.ccf_id);
    p6_a6 := ddx_tapv_rec.funding_type_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_tapv_rec.khr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_tapv_rec.art_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tapv_rec.tap_id_reverses);
    p6_a10 := rosetta_g_miss_num_map(ddx_tapv_rec.ippt_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tapv_rec.code_combination_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_tapv_rec.ipvs_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_tapv_rec.tcn_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_tapv_rec.vpa_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_tapv_rec.ipt_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_tapv_rec.qte_id);
    p6_a17 := ddx_tapv_rec.invoice_category_code;
    p6_a18 := ddx_tapv_rec.payment_method_code;
    p6_a19 := rosetta_g_miss_num_map(ddx_tapv_rec.cplv_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_tapv_rec.pox_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_tapv_rec.amount);
    p6_a22 := ddx_tapv_rec.date_invoiced;
    p6_a23 := ddx_tapv_rec.invoice_number;
    p6_a24 := ddx_tapv_rec.date_funding_approved;
    p6_a25 := ddx_tapv_rec.date_gl;
    p6_a26 := ddx_tapv_rec.workflow_yn;
    p6_a27 := ddx_tapv_rec.match_required_yn;
    p6_a28 := ddx_tapv_rec.ipt_frequency;
    p6_a29 := ddx_tapv_rec.consolidate_yn;
    p6_a30 := ddx_tapv_rec.wait_vendor_invoice_yn;
    p6_a31 := ddx_tapv_rec.date_requisition;
    p6_a32 := ddx_tapv_rec.description;
    p6_a33 := ddx_tapv_rec.currency_conversion_type;
    p6_a34 := rosetta_g_miss_num_map(ddx_tapv_rec.currency_conversion_rate);
    p6_a35 := ddx_tapv_rec.currency_conversion_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_tapv_rec.vendor_id);
    p6_a37 := ddx_tapv_rec.attribute_category;
    p6_a38 := ddx_tapv_rec.attribute1;
    p6_a39 := ddx_tapv_rec.attribute2;
    p6_a40 := ddx_tapv_rec.attribute3;
    p6_a41 := ddx_tapv_rec.attribute4;
    p6_a42 := ddx_tapv_rec.attribute5;
    p6_a43 := ddx_tapv_rec.attribute6;
    p6_a44 := ddx_tapv_rec.attribute7;
    p6_a45 := ddx_tapv_rec.attribute8;
    p6_a46 := ddx_tapv_rec.attribute9;
    p6_a47 := ddx_tapv_rec.attribute10;
    p6_a48 := ddx_tapv_rec.attribute11;
    p6_a49 := ddx_tapv_rec.attribute12;
    p6_a50 := ddx_tapv_rec.attribute13;
    p6_a51 := ddx_tapv_rec.attribute14;
    p6_a52 := ddx_tapv_rec.attribute15;
    p6_a53 := ddx_tapv_rec.date_entered;
    p6_a54 := ddx_tapv_rec.trx_status_code;
    p6_a55 := rosetta_g_miss_num_map(ddx_tapv_rec.set_of_books_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_tapv_rec.try_id);
    p6_a57 := rosetta_g_miss_num_map(ddx_tapv_rec.request_id);
    p6_a58 := rosetta_g_miss_num_map(ddx_tapv_rec.program_application_id);
    p6_a59 := rosetta_g_miss_num_map(ddx_tapv_rec.program_id);
    p6_a60 := ddx_tapv_rec.program_update_date;
    p6_a61 := rosetta_g_miss_num_map(ddx_tapv_rec.org_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_tapv_rec.created_by);
    p6_a63 := ddx_tapv_rec.creation_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_tapv_rec.last_updated_by);
    p6_a65 := ddx_tapv_rec.last_update_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_tapv_rec.last_update_login);
    p6_a67 := ddx_tapv_rec.invoice_type;
    p6_a68 := ddx_tapv_rec.pay_group_lookup_code;
    p6_a69 := ddx_tapv_rec.vendor_invoice_number;
    p6_a70 := ddx_tapv_rec.nettable_yn;
    p6_a71 := rosetta_g_miss_num_map(ddx_tapv_rec.asset_tap_id);
    p6_a72 := rosetta_g_miss_num_map(ddx_tapv_rec.legal_entity_id);
    p6_a73 := ddx_tapv_rec.transaction_date;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_2000
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_DATE_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_VARCHAR2_TABLE_300
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_300
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_DATE_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_DATE_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_tapv_tbl okl_tap_pvt.tapv_tbl_type;
    ddx_tapv_tbl okl_tap_pvt.tapv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tap_pvt_w.rosetta_table_copy_in_p8(ddp_tapv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_tbl,
      ddx_tapv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tap_pvt_w.rosetta_table_copy_out_p8(ddx_tapv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  DATE := fnd_api.g_miss_date
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tapv_rec okl_tap_pvt.tapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tapv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tapv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tapv_rec.sfwt_flag := p5_a2;
    ddp_tapv_rec.cct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tapv_rec.currency_code := p5_a4;
    ddp_tapv_rec.ccf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tapv_rec.funding_type_code := p5_a6;
    ddp_tapv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tapv_rec.art_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tapv_rec.tap_id_reverses := rosetta_g_miss_num_map(p5_a9);
    ddp_tapv_rec.ippt_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tapv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tapv_rec.ipvs_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tapv_rec.tcn_id := rosetta_g_miss_num_map(p5_a13);
    ddp_tapv_rec.vpa_id := rosetta_g_miss_num_map(p5_a14);
    ddp_tapv_rec.ipt_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tapv_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_tapv_rec.invoice_category_code := p5_a17;
    ddp_tapv_rec.payment_method_code := p5_a18;
    ddp_tapv_rec.cplv_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tapv_rec.pox_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tapv_rec.amount := rosetta_g_miss_num_map(p5_a21);
    ddp_tapv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a22);
    ddp_tapv_rec.invoice_number := p5_a23;
    ddp_tapv_rec.date_funding_approved := rosetta_g_miss_date_in_map(p5_a24);
    ddp_tapv_rec.date_gl := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tapv_rec.workflow_yn := p5_a26;
    ddp_tapv_rec.match_required_yn := p5_a27;
    ddp_tapv_rec.ipt_frequency := p5_a28;
    ddp_tapv_rec.consolidate_yn := p5_a29;
    ddp_tapv_rec.wait_vendor_invoice_yn := p5_a30;
    ddp_tapv_rec.date_requisition := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tapv_rec.description := p5_a32;
    ddp_tapv_rec.currency_conversion_type := p5_a33;
    ddp_tapv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a34);
    ddp_tapv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tapv_rec.vendor_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tapv_rec.attribute_category := p5_a37;
    ddp_tapv_rec.attribute1 := p5_a38;
    ddp_tapv_rec.attribute2 := p5_a39;
    ddp_tapv_rec.attribute3 := p5_a40;
    ddp_tapv_rec.attribute4 := p5_a41;
    ddp_tapv_rec.attribute5 := p5_a42;
    ddp_tapv_rec.attribute6 := p5_a43;
    ddp_tapv_rec.attribute7 := p5_a44;
    ddp_tapv_rec.attribute8 := p5_a45;
    ddp_tapv_rec.attribute9 := p5_a46;
    ddp_tapv_rec.attribute10 := p5_a47;
    ddp_tapv_rec.attribute11 := p5_a48;
    ddp_tapv_rec.attribute12 := p5_a49;
    ddp_tapv_rec.attribute13 := p5_a50;
    ddp_tapv_rec.attribute14 := p5_a51;
    ddp_tapv_rec.attribute15 := p5_a52;
    ddp_tapv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tapv_rec.trx_status_code := p5_a54;
    ddp_tapv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a55);
    ddp_tapv_rec.try_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tapv_rec.request_id := rosetta_g_miss_num_map(p5_a57);
    ddp_tapv_rec.program_application_id := rosetta_g_miss_num_map(p5_a58);
    ddp_tapv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_tapv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a60);
    ddp_tapv_rec.org_id := rosetta_g_miss_num_map(p5_a61);
    ddp_tapv_rec.created_by := rosetta_g_miss_num_map(p5_a62);
    ddp_tapv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_tapv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a64);
    ddp_tapv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_tapv_rec.last_update_login := rosetta_g_miss_num_map(p5_a66);
    ddp_tapv_rec.invoice_type := p5_a67;
    ddp_tapv_rec.pay_group_lookup_code := p5_a68;
    ddp_tapv_rec.vendor_invoice_number := p5_a69;
    ddp_tapv_rec.nettable_yn := p5_a70;
    ddp_tapv_rec.asset_tap_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tapv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a72);
    ddp_tapv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);

    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_2000
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_DATE_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_VARCHAR2_TABLE_300
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_300
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
  )

  as
    ddp_tapv_tbl okl_tap_pvt.tapv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tap_pvt_w.rosetta_table_copy_in_p8(ddp_tapv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  DATE := fnd_api.g_miss_date
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tapv_rec okl_tap_pvt.tapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tapv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tapv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tapv_rec.sfwt_flag := p5_a2;
    ddp_tapv_rec.cct_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tapv_rec.currency_code := p5_a4;
    ddp_tapv_rec.ccf_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tapv_rec.funding_type_code := p5_a6;
    ddp_tapv_rec.khr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tapv_rec.art_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tapv_rec.tap_id_reverses := rosetta_g_miss_num_map(p5_a9);
    ddp_tapv_rec.ippt_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tapv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tapv_rec.ipvs_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tapv_rec.tcn_id := rosetta_g_miss_num_map(p5_a13);
    ddp_tapv_rec.vpa_id := rosetta_g_miss_num_map(p5_a14);
    ddp_tapv_rec.ipt_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tapv_rec.qte_id := rosetta_g_miss_num_map(p5_a16);
    ddp_tapv_rec.invoice_category_code := p5_a17;
    ddp_tapv_rec.payment_method_code := p5_a18;
    ddp_tapv_rec.cplv_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tapv_rec.pox_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tapv_rec.amount := rosetta_g_miss_num_map(p5_a21);
    ddp_tapv_rec.date_invoiced := rosetta_g_miss_date_in_map(p5_a22);
    ddp_tapv_rec.invoice_number := p5_a23;
    ddp_tapv_rec.date_funding_approved := rosetta_g_miss_date_in_map(p5_a24);
    ddp_tapv_rec.date_gl := rosetta_g_miss_date_in_map(p5_a25);
    ddp_tapv_rec.workflow_yn := p5_a26;
    ddp_tapv_rec.match_required_yn := p5_a27;
    ddp_tapv_rec.ipt_frequency := p5_a28;
    ddp_tapv_rec.consolidate_yn := p5_a29;
    ddp_tapv_rec.wait_vendor_invoice_yn := p5_a30;
    ddp_tapv_rec.date_requisition := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tapv_rec.description := p5_a32;
    ddp_tapv_rec.currency_conversion_type := p5_a33;
    ddp_tapv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a34);
    ddp_tapv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_tapv_rec.vendor_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tapv_rec.attribute_category := p5_a37;
    ddp_tapv_rec.attribute1 := p5_a38;
    ddp_tapv_rec.attribute2 := p5_a39;
    ddp_tapv_rec.attribute3 := p5_a40;
    ddp_tapv_rec.attribute4 := p5_a41;
    ddp_tapv_rec.attribute5 := p5_a42;
    ddp_tapv_rec.attribute6 := p5_a43;
    ddp_tapv_rec.attribute7 := p5_a44;
    ddp_tapv_rec.attribute8 := p5_a45;
    ddp_tapv_rec.attribute9 := p5_a46;
    ddp_tapv_rec.attribute10 := p5_a47;
    ddp_tapv_rec.attribute11 := p5_a48;
    ddp_tapv_rec.attribute12 := p5_a49;
    ddp_tapv_rec.attribute13 := p5_a50;
    ddp_tapv_rec.attribute14 := p5_a51;
    ddp_tapv_rec.attribute15 := p5_a52;
    ddp_tapv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tapv_rec.trx_status_code := p5_a54;
    ddp_tapv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a55);
    ddp_tapv_rec.try_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tapv_rec.request_id := rosetta_g_miss_num_map(p5_a57);
    ddp_tapv_rec.program_application_id := rosetta_g_miss_num_map(p5_a58);
    ddp_tapv_rec.program_id := rosetta_g_miss_num_map(p5_a59);
    ddp_tapv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a60);
    ddp_tapv_rec.org_id := rosetta_g_miss_num_map(p5_a61);
    ddp_tapv_rec.created_by := rosetta_g_miss_num_map(p5_a62);
    ddp_tapv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_tapv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a64);
    ddp_tapv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_tapv_rec.last_update_login := rosetta_g_miss_num_map(p5_a66);
    ddp_tapv_rec.invoice_type := p5_a67;
    ddp_tapv_rec.pay_group_lookup_code := p5_a68;
    ddp_tapv_rec.vendor_invoice_number := p5_a69;
    ddp_tapv_rec.nettable_yn := p5_a70;
    ddp_tapv_rec.asset_tap_id := rosetta_g_miss_num_map(p5_a71);
    ddp_tapv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a72);
    ddp_tapv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a73);

    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_2000
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_DATE_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_VARCHAR2_TABLE_300
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_300
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_DATE_TABLE
  )

  as
    ddp_tapv_tbl okl_tap_pvt.tapv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tap_pvt_w.rosetta_table_copy_in_p8(ddp_tapv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tap_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tapv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_tap_pvt_w;

/
