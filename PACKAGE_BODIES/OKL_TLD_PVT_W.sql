--------------------------------------------------------
--  DDL for Package Body OKL_TLD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TLD_PVT_W" as
  /* $Header: OKLITLDB.pls 120.0 2007/07/17 06:15:56 gkhuntet noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_tld_pvt.tld_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
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
    , a47 JTF_VARCHAR2_TABLE_200
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_DATE_TABLE
    , a50 JTF_DATE_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_3000
    , a55 JTF_DATE_TABLE
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_DATE_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).bch_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).bcl_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).bsl_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).bgh_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).idx_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).sel_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).til_id_details := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).tld_id_reverses := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).line_detail_number := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).late_charge_yn := a12(indx);
          t(ddindx).date_calculation := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).fixed_rate_yn := a14(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).receivables_invoice_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).amount_applied := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).inventory_org_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a24(indx));
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
          t(ddindx).created_by := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).txl_ar_line_number := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).invoice_format_type := a47(indx);
          t(ddindx).invoice_format_line_type := a48(indx);
          t(ddindx).late_charge_assess_date := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).late_int_assess_date := rosetta_g_miss_date_in_map(a50(indx));
          t(ddindx).late_charge_ass_yn := a51(indx);
          t(ddindx).late_int_ass_yn := a52(indx);
          t(ddindx).investor_disb_status := a53(indx);
          t(ddindx).investor_disb_err_mg := a54(indx);
          t(ddindx).date_disbursed := rosetta_g_miss_date_in_map(a55(indx));
          t(ddindx).pay_status_code := a56(indx);
          t(ddindx).rbk_ori_invoice_number := a57(indx);
          t(ddindx).rbk_ori_invoice_line_number := a58(indx);
          t(ddindx).rbk_adjustment_date := rosetta_g_miss_date_in_map(a59(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).tax_amount := rosetta_g_miss_num_map(a62(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_tld_pvt.tld_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
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
    , a47 out nocopy JTF_VARCHAR2_TABLE_200
    , a48 out nocopy JTF_VARCHAR2_TABLE_200
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_DATE_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_3000
    , a55 out nocopy JTF_DATE_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_DATE_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
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
    a47 := JTF_VARCHAR2_TABLE_200();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_DATE_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_3000();
    a55 := JTF_DATE_TABLE();
    a56 := JTF_VARCHAR2_TABLE_300();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_DATE_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
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
      a47 := JTF_VARCHAR2_TABLE_200();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_DATE_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_3000();
      a55 := JTF_DATE_TABLE();
      a56 := JTF_VARCHAR2_TABLE_300();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_DATE_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).bch_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).bcl_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).bsl_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).bgh_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).idx_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).sel_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).til_id_details);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).tld_id_reverses);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).line_detail_number);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a12(indx) := t(ddindx).late_charge_yn;
          a13(indx) := t(ddindx).date_calculation;
          a14(indx) := t(ddindx).fixed_rate_yn;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).receivables_invoice_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).amount_applied);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a21(indx) := t(ddindx).program_update_date;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_org_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
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
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a42(indx) := t(ddindx).creation_date;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a44(indx) := t(ddindx).last_update_date;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).txl_ar_line_number);
          a47(indx) := t(ddindx).invoice_format_type;
          a48(indx) := t(ddindx).invoice_format_line_type;
          a49(indx) := t(ddindx).late_charge_assess_date;
          a50(indx) := t(ddindx).late_int_assess_date;
          a51(indx) := t(ddindx).late_charge_ass_yn;
          a52(indx) := t(ddindx).late_int_ass_yn;
          a53(indx) := t(ddindx).investor_disb_status;
          a54(indx) := t(ddindx).investor_disb_err_mg;
          a55(indx) := t(ddindx).date_disbursed;
          a56(indx) := t(ddindx).pay_status_code;
          a57(indx) := t(ddindx).rbk_ori_invoice_number;
          a58(indx) := t(ddindx).rbk_ori_invoice_line_number;
          a59(indx) := t(ddindx).rbk_adjustment_date;
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).tax_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_tld_pvt.okl_txd_ar_ln_dtls_tl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_3000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
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
          t(ddindx).error_message := a3(indx);
          t(ddindx).sfwt_flag := a4(indx);
          t(ddindx).description := a5(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_tld_pvt.okl_txd_ar_ln_dtls_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_3000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_3000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_3000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).language;
          a2(indx) := t(ddindx).source_lang;
          a3(indx) := t(ddindx).error_message;
          a4(indx) := t(ddindx).sfwt_flag;
          a5(indx) := t(ddindx).description;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a9(indx) := t(ddindx).last_update_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_tld_pvt.tldv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_3000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
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
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
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
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_200
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_DATE_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_3000
    , a58 JTF_DATE_TABLE
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_DATE_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
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
          t(ddindx).error_message := a2(indx);
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).bch_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).bgh_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).idx_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).tld_id_reverses := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).sel_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).til_id_details := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).bcl_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).bsl_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).line_detail_number := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).receivables_invoice_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).late_charge_yn := a16(indx);
          t(ddindx).description := a17(indx);
          t(ddindx).amount_applied := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).date_calculation := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).fixed_rate_yn := a20(indx);
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).attribute_category := a22(indx);
          t(ddindx).attribute1 := a23(indx);
          t(ddindx).attribute2 := a24(indx);
          t(ddindx).attribute3 := a25(indx);
          t(ddindx).attribute4 := a26(indx);
          t(ddindx).attribute5 := a27(indx);
          t(ddindx).attribute6 := a28(indx);
          t(ddindx).attribute7 := a29(indx);
          t(ddindx).attribute8 := a30(indx);
          t(ddindx).attribute9 := a31(indx);
          t(ddindx).attribute10 := a32(indx);
          t(ddindx).attribute11 := a33(indx);
          t(ddindx).attribute12 := a34(indx);
          t(ddindx).attribute13 := a35(indx);
          t(ddindx).attribute14 := a36(indx);
          t(ddindx).attribute15 := a37(indx);
          t(ddindx).request_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a41(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).inventory_org_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a45(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).txl_ar_line_number := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).invoice_format_type := a50(indx);
          t(ddindx).invoice_format_line_type := a51(indx);
          t(ddindx).late_charge_assess_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).late_int_assess_date := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).late_charge_ass_yn := a54(indx);
          t(ddindx).late_int_ass_yn := a55(indx);
          t(ddindx).investor_disb_status := a56(indx);
          t(ddindx).investor_disb_err_mg := a57(indx);
          t(ddindx).date_disbursed := rosetta_g_miss_date_in_map(a58(indx));
          t(ddindx).pay_status_code := a59(indx);
          t(ddindx).rbk_ori_invoice_number := a60(indx);
          t(ddindx).rbk_ori_invoice_line_number := a61(indx);
          t(ddindx).rbk_adjustment_date := rosetta_g_miss_date_in_map(a62(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).tax_amount := rosetta_g_miss_num_map(a65(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_tld_pvt.tldv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
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
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
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
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_200
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_3000
    , a58 out nocopy JTF_DATE_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_DATE_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_3000();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
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
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
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
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_200();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_3000();
    a58 := JTF_DATE_TABLE();
    a59 := JTF_VARCHAR2_TABLE_300();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_DATE_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_3000();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
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
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
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
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_200();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_3000();
      a58 := JTF_DATE_TABLE();
      a59 := JTF_VARCHAR2_TABLE_300();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_DATE_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).error_message;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).bch_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).bgh_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).idx_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).tld_id_reverses);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).sel_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).til_id_details);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).bcl_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).bsl_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).line_detail_number);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).receivables_invoice_id);
          a16(indx) := t(ddindx).late_charge_yn;
          a17(indx) := t(ddindx).description;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).amount_applied);
          a19(indx) := t(ddindx).date_calculation;
          a20(indx) := t(ddindx).fixed_rate_yn;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a22(indx) := t(ddindx).attribute_category;
          a23(indx) := t(ddindx).attribute1;
          a24(indx) := t(ddindx).attribute2;
          a25(indx) := t(ddindx).attribute3;
          a26(indx) := t(ddindx).attribute4;
          a27(indx) := t(ddindx).attribute5;
          a28(indx) := t(ddindx).attribute6;
          a29(indx) := t(ddindx).attribute7;
          a30(indx) := t(ddindx).attribute8;
          a31(indx) := t(ddindx).attribute9;
          a32(indx) := t(ddindx).attribute10;
          a33(indx) := t(ddindx).attribute11;
          a34(indx) := t(ddindx).attribute12;
          a35(indx) := t(ddindx).attribute13;
          a36(indx) := t(ddindx).attribute14;
          a37(indx) := t(ddindx).attribute15;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a41(indx) := t(ddindx).program_update_date;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_org_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a45(indx) := t(ddindx).creation_date;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a47(indx) := t(ddindx).last_update_date;
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).txl_ar_line_number);
          a50(indx) := t(ddindx).invoice_format_type;
          a51(indx) := t(ddindx).invoice_format_line_type;
          a52(indx) := t(ddindx).late_charge_assess_date;
          a53(indx) := t(ddindx).late_int_assess_date;
          a54(indx) := t(ddindx).late_charge_ass_yn;
          a55(indx) := t(ddindx).late_int_ass_yn;
          a56(indx) := t(ddindx).investor_disb_status;
          a57(indx) := t(ddindx).investor_disb_err_mg;
          a58(indx) := t(ddindx).date_disbursed;
          a59(indx) := t(ddindx).pay_status_code;
          a60(indx) := t(ddindx).rbk_ori_invoice_number;
          a61(indx) := t(ddindx).rbk_ori_invoice_line_number;
          a62(indx) := t(ddindx).rbk_adjustment_date;
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).tax_amount);
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
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  DATE
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
  )

  as
    ddp_tldv_rec okl_tld_pvt.tldv_rec_type;
    ddx_tldv_rec okl_tld_pvt.tldv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tldv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tldv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tldv_rec.error_message := p5_a2;
    ddp_tldv_rec.sfwt_flag := p5_a3;
    ddp_tldv_rec.bch_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tldv_rec.bgh_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tldv_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tldv_rec.tld_id_reverses := rosetta_g_miss_num_map(p5_a7);
    ddp_tldv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tldv_rec.sel_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tldv_rec.til_id_details := rosetta_g_miss_num_map(p5_a10);
    ddp_tldv_rec.bcl_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tldv_rec.bsl_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tldv_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tldv_rec.line_detail_number := rosetta_g_miss_num_map(p5_a14);
    ddp_tldv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tldv_rec.late_charge_yn := p5_a16;
    ddp_tldv_rec.description := p5_a17;
    ddp_tldv_rec.amount_applied := rosetta_g_miss_num_map(p5_a18);
    ddp_tldv_rec.date_calculation := rosetta_g_miss_date_in_map(p5_a19);
    ddp_tldv_rec.fixed_rate_yn := p5_a20;
    ddp_tldv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tldv_rec.attribute_category := p5_a22;
    ddp_tldv_rec.attribute1 := p5_a23;
    ddp_tldv_rec.attribute2 := p5_a24;
    ddp_tldv_rec.attribute3 := p5_a25;
    ddp_tldv_rec.attribute4 := p5_a26;
    ddp_tldv_rec.attribute5 := p5_a27;
    ddp_tldv_rec.attribute6 := p5_a28;
    ddp_tldv_rec.attribute7 := p5_a29;
    ddp_tldv_rec.attribute8 := p5_a30;
    ddp_tldv_rec.attribute9 := p5_a31;
    ddp_tldv_rec.attribute10 := p5_a32;
    ddp_tldv_rec.attribute11 := p5_a33;
    ddp_tldv_rec.attribute12 := p5_a34;
    ddp_tldv_rec.attribute13 := p5_a35;
    ddp_tldv_rec.attribute14 := p5_a36;
    ddp_tldv_rec.attribute15 := p5_a37;
    ddp_tldv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tldv_rec.program_application_id := rosetta_g_miss_num_map(p5_a39);
    ddp_tldv_rec.program_id := rosetta_g_miss_num_map(p5_a40);
    ddp_tldv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tldv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tldv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tldv_rec.created_by := rosetta_g_miss_num_map(p5_a44);
    ddp_tldv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_tldv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a46);
    ddp_tldv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_tldv_rec.last_update_login := rosetta_g_miss_num_map(p5_a48);
    ddp_tldv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a49);
    ddp_tldv_rec.invoice_format_type := p5_a50;
    ddp_tldv_rec.invoice_format_line_type := p5_a51;
    ddp_tldv_rec.late_charge_assess_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tldv_rec.late_int_assess_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tldv_rec.late_charge_ass_yn := p5_a54;
    ddp_tldv_rec.late_int_ass_yn := p5_a55;
    ddp_tldv_rec.investor_disb_status := p5_a56;
    ddp_tldv_rec.investor_disb_err_mg := p5_a57;
    ddp_tldv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tldv_rec.pay_status_code := p5_a59;
    ddp_tldv_rec.rbk_ori_invoice_number := p5_a60;
    ddp_tldv_rec.rbk_ori_invoice_line_number := p5_a61;
    ddp_tldv_rec.rbk_adjustment_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_tldv_rec.khr_id := rosetta_g_miss_num_map(p5_a63);
    ddp_tldv_rec.kle_id := rosetta_g_miss_num_map(p5_a64);
    ddp_tldv_rec.tax_amount := rosetta_g_miss_num_map(p5_a65);


    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_rec,
      ddx_tldv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tldv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tldv_rec.object_version_number);
    p6_a2 := ddx_tldv_rec.error_message;
    p6_a3 := ddx_tldv_rec.sfwt_flag;
    p6_a4 := rosetta_g_miss_num_map(ddx_tldv_rec.bch_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tldv_rec.bgh_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tldv_rec.idx_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tldv_rec.tld_id_reverses);
    p6_a8 := rosetta_g_miss_num_map(ddx_tldv_rec.sty_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tldv_rec.sel_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tldv_rec.til_id_details);
    p6_a11 := rosetta_g_miss_num_map(ddx_tldv_rec.bcl_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_tldv_rec.bsl_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_tldv_rec.amount);
    p6_a14 := rosetta_g_miss_num_map(ddx_tldv_rec.line_detail_number);
    p6_a15 := rosetta_g_miss_num_map(ddx_tldv_rec.receivables_invoice_id);
    p6_a16 := ddx_tldv_rec.late_charge_yn;
    p6_a17 := ddx_tldv_rec.description;
    p6_a18 := rosetta_g_miss_num_map(ddx_tldv_rec.amount_applied);
    p6_a19 := ddx_tldv_rec.date_calculation;
    p6_a20 := ddx_tldv_rec.fixed_rate_yn;
    p6_a21 := rosetta_g_miss_num_map(ddx_tldv_rec.inventory_item_id);
    p6_a22 := ddx_tldv_rec.attribute_category;
    p6_a23 := ddx_tldv_rec.attribute1;
    p6_a24 := ddx_tldv_rec.attribute2;
    p6_a25 := ddx_tldv_rec.attribute3;
    p6_a26 := ddx_tldv_rec.attribute4;
    p6_a27 := ddx_tldv_rec.attribute5;
    p6_a28 := ddx_tldv_rec.attribute6;
    p6_a29 := ddx_tldv_rec.attribute7;
    p6_a30 := ddx_tldv_rec.attribute8;
    p6_a31 := ddx_tldv_rec.attribute9;
    p6_a32 := ddx_tldv_rec.attribute10;
    p6_a33 := ddx_tldv_rec.attribute11;
    p6_a34 := ddx_tldv_rec.attribute12;
    p6_a35 := ddx_tldv_rec.attribute13;
    p6_a36 := ddx_tldv_rec.attribute14;
    p6_a37 := ddx_tldv_rec.attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_tldv_rec.request_id);
    p6_a39 := rosetta_g_miss_num_map(ddx_tldv_rec.program_application_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_tldv_rec.program_id);
    p6_a41 := ddx_tldv_rec.program_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_tldv_rec.org_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tldv_rec.inventory_org_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tldv_rec.created_by);
    p6_a45 := ddx_tldv_rec.creation_date;
    p6_a46 := rosetta_g_miss_num_map(ddx_tldv_rec.last_updated_by);
    p6_a47 := ddx_tldv_rec.last_update_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_tldv_rec.last_update_login);
    p6_a49 := rosetta_g_miss_num_map(ddx_tldv_rec.txl_ar_line_number);
    p6_a50 := ddx_tldv_rec.invoice_format_type;
    p6_a51 := ddx_tldv_rec.invoice_format_line_type;
    p6_a52 := ddx_tldv_rec.late_charge_assess_date;
    p6_a53 := ddx_tldv_rec.late_int_assess_date;
    p6_a54 := ddx_tldv_rec.late_charge_ass_yn;
    p6_a55 := ddx_tldv_rec.late_int_ass_yn;
    p6_a56 := ddx_tldv_rec.investor_disb_status;
    p6_a57 := ddx_tldv_rec.investor_disb_err_mg;
    p6_a58 := ddx_tldv_rec.date_disbursed;
    p6_a59 := ddx_tldv_rec.pay_status_code;
    p6_a60 := ddx_tldv_rec.rbk_ori_invoice_number;
    p6_a61 := ddx_tldv_rec.rbk_ori_invoice_line_number;
    p6_a62 := ddx_tldv_rec.rbk_adjustment_date;
    p6_a63 := rosetta_g_miss_num_map(ddx_tldv_rec.khr_id);
    p6_a64 := rosetta_g_miss_num_map(ddx_tldv_rec.kle_id);
    p6_a65 := rosetta_g_miss_num_map(ddx_tldv_rec.tax_amount);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_2000
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_3000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_300
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_DATE_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_3000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_DATE_TABLE
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddx_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tld_pvt_w.rosetta_table_copy_in_p8(ddp_tldv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_tbl,
      ddx_tldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tld_pvt_w.rosetta_table_copy_out_p8(ddx_tldv_tbl, p6_a0
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
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
  )

  as
    ddp_tldv_rec okl_tld_pvt.tldv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tldv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tldv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tldv_rec.error_message := p5_a2;
    ddp_tldv_rec.sfwt_flag := p5_a3;
    ddp_tldv_rec.bch_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tldv_rec.bgh_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tldv_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tldv_rec.tld_id_reverses := rosetta_g_miss_num_map(p5_a7);
    ddp_tldv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tldv_rec.sel_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tldv_rec.til_id_details := rosetta_g_miss_num_map(p5_a10);
    ddp_tldv_rec.bcl_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tldv_rec.bsl_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tldv_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tldv_rec.line_detail_number := rosetta_g_miss_num_map(p5_a14);
    ddp_tldv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tldv_rec.late_charge_yn := p5_a16;
    ddp_tldv_rec.description := p5_a17;
    ddp_tldv_rec.amount_applied := rosetta_g_miss_num_map(p5_a18);
    ddp_tldv_rec.date_calculation := rosetta_g_miss_date_in_map(p5_a19);
    ddp_tldv_rec.fixed_rate_yn := p5_a20;
    ddp_tldv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tldv_rec.attribute_category := p5_a22;
    ddp_tldv_rec.attribute1 := p5_a23;
    ddp_tldv_rec.attribute2 := p5_a24;
    ddp_tldv_rec.attribute3 := p5_a25;
    ddp_tldv_rec.attribute4 := p5_a26;
    ddp_tldv_rec.attribute5 := p5_a27;
    ddp_tldv_rec.attribute6 := p5_a28;
    ddp_tldv_rec.attribute7 := p5_a29;
    ddp_tldv_rec.attribute8 := p5_a30;
    ddp_tldv_rec.attribute9 := p5_a31;
    ddp_tldv_rec.attribute10 := p5_a32;
    ddp_tldv_rec.attribute11 := p5_a33;
    ddp_tldv_rec.attribute12 := p5_a34;
    ddp_tldv_rec.attribute13 := p5_a35;
    ddp_tldv_rec.attribute14 := p5_a36;
    ddp_tldv_rec.attribute15 := p5_a37;
    ddp_tldv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tldv_rec.program_application_id := rosetta_g_miss_num_map(p5_a39);
    ddp_tldv_rec.program_id := rosetta_g_miss_num_map(p5_a40);
    ddp_tldv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tldv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tldv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tldv_rec.created_by := rosetta_g_miss_num_map(p5_a44);
    ddp_tldv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_tldv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a46);
    ddp_tldv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_tldv_rec.last_update_login := rosetta_g_miss_num_map(p5_a48);
    ddp_tldv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a49);
    ddp_tldv_rec.invoice_format_type := p5_a50;
    ddp_tldv_rec.invoice_format_line_type := p5_a51;
    ddp_tldv_rec.late_charge_assess_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tldv_rec.late_int_assess_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tldv_rec.late_charge_ass_yn := p5_a54;
    ddp_tldv_rec.late_int_ass_yn := p5_a55;
    ddp_tldv_rec.investor_disb_status := p5_a56;
    ddp_tldv_rec.investor_disb_err_mg := p5_a57;
    ddp_tldv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tldv_rec.pay_status_code := p5_a59;
    ddp_tldv_rec.rbk_ori_invoice_number := p5_a60;
    ddp_tldv_rec.rbk_ori_invoice_line_number := p5_a61;
    ddp_tldv_rec.rbk_adjustment_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_tldv_rec.khr_id := rosetta_g_miss_num_map(p5_a63);
    ddp_tldv_rec.kle_id := rosetta_g_miss_num_map(p5_a64);
    ddp_tldv_rec.tax_amount := rosetta_g_miss_num_map(p5_a65);

    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_2000
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_3000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_300
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_DATE_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
  )

  as
    ddp_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tld_pvt_w.rosetta_table_copy_in_p8(ddp_tldv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_tbl);

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
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  DATE
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
  )

  as
    ddp_tldv_rec okl_tld_pvt.tldv_rec_type;
    ddx_tldv_rec okl_tld_pvt.tldv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tldv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tldv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tldv_rec.error_message := p5_a2;
    ddp_tldv_rec.sfwt_flag := p5_a3;
    ddp_tldv_rec.bch_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tldv_rec.bgh_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tldv_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tldv_rec.tld_id_reverses := rosetta_g_miss_num_map(p5_a7);
    ddp_tldv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tldv_rec.sel_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tldv_rec.til_id_details := rosetta_g_miss_num_map(p5_a10);
    ddp_tldv_rec.bcl_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tldv_rec.bsl_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tldv_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tldv_rec.line_detail_number := rosetta_g_miss_num_map(p5_a14);
    ddp_tldv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tldv_rec.late_charge_yn := p5_a16;
    ddp_tldv_rec.description := p5_a17;
    ddp_tldv_rec.amount_applied := rosetta_g_miss_num_map(p5_a18);
    ddp_tldv_rec.date_calculation := rosetta_g_miss_date_in_map(p5_a19);
    ddp_tldv_rec.fixed_rate_yn := p5_a20;
    ddp_tldv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tldv_rec.attribute_category := p5_a22;
    ddp_tldv_rec.attribute1 := p5_a23;
    ddp_tldv_rec.attribute2 := p5_a24;
    ddp_tldv_rec.attribute3 := p5_a25;
    ddp_tldv_rec.attribute4 := p5_a26;
    ddp_tldv_rec.attribute5 := p5_a27;
    ddp_tldv_rec.attribute6 := p5_a28;
    ddp_tldv_rec.attribute7 := p5_a29;
    ddp_tldv_rec.attribute8 := p5_a30;
    ddp_tldv_rec.attribute9 := p5_a31;
    ddp_tldv_rec.attribute10 := p5_a32;
    ddp_tldv_rec.attribute11 := p5_a33;
    ddp_tldv_rec.attribute12 := p5_a34;
    ddp_tldv_rec.attribute13 := p5_a35;
    ddp_tldv_rec.attribute14 := p5_a36;
    ddp_tldv_rec.attribute15 := p5_a37;
    ddp_tldv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tldv_rec.program_application_id := rosetta_g_miss_num_map(p5_a39);
    ddp_tldv_rec.program_id := rosetta_g_miss_num_map(p5_a40);
    ddp_tldv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tldv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tldv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tldv_rec.created_by := rosetta_g_miss_num_map(p5_a44);
    ddp_tldv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_tldv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a46);
    ddp_tldv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_tldv_rec.last_update_login := rosetta_g_miss_num_map(p5_a48);
    ddp_tldv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a49);
    ddp_tldv_rec.invoice_format_type := p5_a50;
    ddp_tldv_rec.invoice_format_line_type := p5_a51;
    ddp_tldv_rec.late_charge_assess_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tldv_rec.late_int_assess_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tldv_rec.late_charge_ass_yn := p5_a54;
    ddp_tldv_rec.late_int_ass_yn := p5_a55;
    ddp_tldv_rec.investor_disb_status := p5_a56;
    ddp_tldv_rec.investor_disb_err_mg := p5_a57;
    ddp_tldv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tldv_rec.pay_status_code := p5_a59;
    ddp_tldv_rec.rbk_ori_invoice_number := p5_a60;
    ddp_tldv_rec.rbk_ori_invoice_line_number := p5_a61;
    ddp_tldv_rec.rbk_adjustment_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_tldv_rec.khr_id := rosetta_g_miss_num_map(p5_a63);
    ddp_tldv_rec.kle_id := rosetta_g_miss_num_map(p5_a64);
    ddp_tldv_rec.tax_amount := rosetta_g_miss_num_map(p5_a65);


    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_rec,
      ddx_tldv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tldv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tldv_rec.object_version_number);
    p6_a2 := ddx_tldv_rec.error_message;
    p6_a3 := ddx_tldv_rec.sfwt_flag;
    p6_a4 := rosetta_g_miss_num_map(ddx_tldv_rec.bch_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tldv_rec.bgh_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tldv_rec.idx_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tldv_rec.tld_id_reverses);
    p6_a8 := rosetta_g_miss_num_map(ddx_tldv_rec.sty_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tldv_rec.sel_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tldv_rec.til_id_details);
    p6_a11 := rosetta_g_miss_num_map(ddx_tldv_rec.bcl_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_tldv_rec.bsl_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_tldv_rec.amount);
    p6_a14 := rosetta_g_miss_num_map(ddx_tldv_rec.line_detail_number);
    p6_a15 := rosetta_g_miss_num_map(ddx_tldv_rec.receivables_invoice_id);
    p6_a16 := ddx_tldv_rec.late_charge_yn;
    p6_a17 := ddx_tldv_rec.description;
    p6_a18 := rosetta_g_miss_num_map(ddx_tldv_rec.amount_applied);
    p6_a19 := ddx_tldv_rec.date_calculation;
    p6_a20 := ddx_tldv_rec.fixed_rate_yn;
    p6_a21 := rosetta_g_miss_num_map(ddx_tldv_rec.inventory_item_id);
    p6_a22 := ddx_tldv_rec.attribute_category;
    p6_a23 := ddx_tldv_rec.attribute1;
    p6_a24 := ddx_tldv_rec.attribute2;
    p6_a25 := ddx_tldv_rec.attribute3;
    p6_a26 := ddx_tldv_rec.attribute4;
    p6_a27 := ddx_tldv_rec.attribute5;
    p6_a28 := ddx_tldv_rec.attribute6;
    p6_a29 := ddx_tldv_rec.attribute7;
    p6_a30 := ddx_tldv_rec.attribute8;
    p6_a31 := ddx_tldv_rec.attribute9;
    p6_a32 := ddx_tldv_rec.attribute10;
    p6_a33 := ddx_tldv_rec.attribute11;
    p6_a34 := ddx_tldv_rec.attribute12;
    p6_a35 := ddx_tldv_rec.attribute13;
    p6_a36 := ddx_tldv_rec.attribute14;
    p6_a37 := ddx_tldv_rec.attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_tldv_rec.request_id);
    p6_a39 := rosetta_g_miss_num_map(ddx_tldv_rec.program_application_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_tldv_rec.program_id);
    p6_a41 := ddx_tldv_rec.program_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_tldv_rec.org_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tldv_rec.inventory_org_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tldv_rec.created_by);
    p6_a45 := ddx_tldv_rec.creation_date;
    p6_a46 := rosetta_g_miss_num_map(ddx_tldv_rec.last_updated_by);
    p6_a47 := ddx_tldv_rec.last_update_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_tldv_rec.last_update_login);
    p6_a49 := rosetta_g_miss_num_map(ddx_tldv_rec.txl_ar_line_number);
    p6_a50 := ddx_tldv_rec.invoice_format_type;
    p6_a51 := ddx_tldv_rec.invoice_format_line_type;
    p6_a52 := ddx_tldv_rec.late_charge_assess_date;
    p6_a53 := ddx_tldv_rec.late_int_assess_date;
    p6_a54 := ddx_tldv_rec.late_charge_ass_yn;
    p6_a55 := ddx_tldv_rec.late_int_ass_yn;
    p6_a56 := ddx_tldv_rec.investor_disb_status;
    p6_a57 := ddx_tldv_rec.investor_disb_err_mg;
    p6_a58 := ddx_tldv_rec.date_disbursed;
    p6_a59 := ddx_tldv_rec.pay_status_code;
    p6_a60 := ddx_tldv_rec.rbk_ori_invoice_number;
    p6_a61 := ddx_tldv_rec.rbk_ori_invoice_line_number;
    p6_a62 := ddx_tldv_rec.rbk_adjustment_date;
    p6_a63 := rosetta_g_miss_num_map(ddx_tldv_rec.khr_id);
    p6_a64 := rosetta_g_miss_num_map(ddx_tldv_rec.kle_id);
    p6_a65 := rosetta_g_miss_num_map(ddx_tldv_rec.tax_amount);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_2000
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_3000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_300
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_DATE_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_3000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_DATE_TABLE
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddx_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tld_pvt_w.rosetta_table_copy_in_p8(ddp_tldv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_tbl,
      ddx_tldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tld_pvt_w.rosetta_table_copy_out_p8(ddx_tldv_tbl, p6_a0
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
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
  )

  as
    ddp_tldv_rec okl_tld_pvt.tldv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tldv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tldv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tldv_rec.error_message := p5_a2;
    ddp_tldv_rec.sfwt_flag := p5_a3;
    ddp_tldv_rec.bch_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tldv_rec.bgh_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tldv_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tldv_rec.tld_id_reverses := rosetta_g_miss_num_map(p5_a7);
    ddp_tldv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tldv_rec.sel_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tldv_rec.til_id_details := rosetta_g_miss_num_map(p5_a10);
    ddp_tldv_rec.bcl_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tldv_rec.bsl_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tldv_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tldv_rec.line_detail_number := rosetta_g_miss_num_map(p5_a14);
    ddp_tldv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tldv_rec.late_charge_yn := p5_a16;
    ddp_tldv_rec.description := p5_a17;
    ddp_tldv_rec.amount_applied := rosetta_g_miss_num_map(p5_a18);
    ddp_tldv_rec.date_calculation := rosetta_g_miss_date_in_map(p5_a19);
    ddp_tldv_rec.fixed_rate_yn := p5_a20;
    ddp_tldv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tldv_rec.attribute_category := p5_a22;
    ddp_tldv_rec.attribute1 := p5_a23;
    ddp_tldv_rec.attribute2 := p5_a24;
    ddp_tldv_rec.attribute3 := p5_a25;
    ddp_tldv_rec.attribute4 := p5_a26;
    ddp_tldv_rec.attribute5 := p5_a27;
    ddp_tldv_rec.attribute6 := p5_a28;
    ddp_tldv_rec.attribute7 := p5_a29;
    ddp_tldv_rec.attribute8 := p5_a30;
    ddp_tldv_rec.attribute9 := p5_a31;
    ddp_tldv_rec.attribute10 := p5_a32;
    ddp_tldv_rec.attribute11 := p5_a33;
    ddp_tldv_rec.attribute12 := p5_a34;
    ddp_tldv_rec.attribute13 := p5_a35;
    ddp_tldv_rec.attribute14 := p5_a36;
    ddp_tldv_rec.attribute15 := p5_a37;
    ddp_tldv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tldv_rec.program_application_id := rosetta_g_miss_num_map(p5_a39);
    ddp_tldv_rec.program_id := rosetta_g_miss_num_map(p5_a40);
    ddp_tldv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tldv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tldv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tldv_rec.created_by := rosetta_g_miss_num_map(p5_a44);
    ddp_tldv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_tldv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a46);
    ddp_tldv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_tldv_rec.last_update_login := rosetta_g_miss_num_map(p5_a48);
    ddp_tldv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a49);
    ddp_tldv_rec.invoice_format_type := p5_a50;
    ddp_tldv_rec.invoice_format_line_type := p5_a51;
    ddp_tldv_rec.late_charge_assess_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tldv_rec.late_int_assess_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tldv_rec.late_charge_ass_yn := p5_a54;
    ddp_tldv_rec.late_int_ass_yn := p5_a55;
    ddp_tldv_rec.investor_disb_status := p5_a56;
    ddp_tldv_rec.investor_disb_err_mg := p5_a57;
    ddp_tldv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tldv_rec.pay_status_code := p5_a59;
    ddp_tldv_rec.rbk_ori_invoice_number := p5_a60;
    ddp_tldv_rec.rbk_ori_invoice_line_number := p5_a61;
    ddp_tldv_rec.rbk_adjustment_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_tldv_rec.khr_id := rosetta_g_miss_num_map(p5_a63);
    ddp_tldv_rec.kle_id := rosetta_g_miss_num_map(p5_a64);
    ddp_tldv_rec.tax_amount := rosetta_g_miss_num_map(p5_a65);

    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_2000
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_3000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_300
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_DATE_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
  )

  as
    ddp_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tld_pvt_w.rosetta_table_copy_in_p8(ddp_tldv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_tbl);

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
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  DATE := fnd_api.g_miss_date
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
  )

  as
    ddp_tldv_rec okl_tld_pvt.tldv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tldv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tldv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tldv_rec.error_message := p5_a2;
    ddp_tldv_rec.sfwt_flag := p5_a3;
    ddp_tldv_rec.bch_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tldv_rec.bgh_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tldv_rec.idx_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tldv_rec.tld_id_reverses := rosetta_g_miss_num_map(p5_a7);
    ddp_tldv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tldv_rec.sel_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tldv_rec.til_id_details := rosetta_g_miss_num_map(p5_a10);
    ddp_tldv_rec.bcl_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tldv_rec.bsl_id := rosetta_g_miss_num_map(p5_a12);
    ddp_tldv_rec.amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tldv_rec.line_detail_number := rosetta_g_miss_num_map(p5_a14);
    ddp_tldv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tldv_rec.late_charge_yn := p5_a16;
    ddp_tldv_rec.description := p5_a17;
    ddp_tldv_rec.amount_applied := rosetta_g_miss_num_map(p5_a18);
    ddp_tldv_rec.date_calculation := rosetta_g_miss_date_in_map(p5_a19);
    ddp_tldv_rec.fixed_rate_yn := p5_a20;
    ddp_tldv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tldv_rec.attribute_category := p5_a22;
    ddp_tldv_rec.attribute1 := p5_a23;
    ddp_tldv_rec.attribute2 := p5_a24;
    ddp_tldv_rec.attribute3 := p5_a25;
    ddp_tldv_rec.attribute4 := p5_a26;
    ddp_tldv_rec.attribute5 := p5_a27;
    ddp_tldv_rec.attribute6 := p5_a28;
    ddp_tldv_rec.attribute7 := p5_a29;
    ddp_tldv_rec.attribute8 := p5_a30;
    ddp_tldv_rec.attribute9 := p5_a31;
    ddp_tldv_rec.attribute10 := p5_a32;
    ddp_tldv_rec.attribute11 := p5_a33;
    ddp_tldv_rec.attribute12 := p5_a34;
    ddp_tldv_rec.attribute13 := p5_a35;
    ddp_tldv_rec.attribute14 := p5_a36;
    ddp_tldv_rec.attribute15 := p5_a37;
    ddp_tldv_rec.request_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tldv_rec.program_application_id := rosetta_g_miss_num_map(p5_a39);
    ddp_tldv_rec.program_id := rosetta_g_miss_num_map(p5_a40);
    ddp_tldv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tldv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tldv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tldv_rec.created_by := rosetta_g_miss_num_map(p5_a44);
    ddp_tldv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_tldv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a46);
    ddp_tldv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_tldv_rec.last_update_login := rosetta_g_miss_num_map(p5_a48);
    ddp_tldv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a49);
    ddp_tldv_rec.invoice_format_type := p5_a50;
    ddp_tldv_rec.invoice_format_line_type := p5_a51;
    ddp_tldv_rec.late_charge_assess_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tldv_rec.late_int_assess_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_tldv_rec.late_charge_ass_yn := p5_a54;
    ddp_tldv_rec.late_int_ass_yn := p5_a55;
    ddp_tldv_rec.investor_disb_status := p5_a56;
    ddp_tldv_rec.investor_disb_err_mg := p5_a57;
    ddp_tldv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tldv_rec.pay_status_code := p5_a59;
    ddp_tldv_rec.rbk_ori_invoice_number := p5_a60;
    ddp_tldv_rec.rbk_ori_invoice_line_number := p5_a61;
    ddp_tldv_rec.rbk_adjustment_date := rosetta_g_miss_date_in_map(p5_a62);
    ddp_tldv_rec.khr_id := rosetta_g_miss_num_map(p5_a63);
    ddp_tldv_rec.kle_id := rosetta_g_miss_num_map(p5_a64);
    ddp_tldv_rec.tax_amount := rosetta_g_miss_num_map(p5_a65);

    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_3000
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_2000
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_3000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_300
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_DATE_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
  )

  as
    ddp_tldv_tbl okl_tld_pvt.tldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tld_pvt_w.rosetta_table_copy_in_p8(ddp_tldv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tld_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_tld_pvt_w;

/
