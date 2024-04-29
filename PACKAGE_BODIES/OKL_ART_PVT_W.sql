--------------------------------------------------------
--  DDL for Package Body OKL_ART_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ART_PVT_W" as
  /* $Header: OKLIARTB.pls 120.3 2007/11/14 19:35:38 rmunjulu ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_art_pvt.art_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
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
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_DATE_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).security_dep_trx_ap_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).iso_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).rna_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).rmr_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).ars_code := a6(indx);
          t(ddindx).imr_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).art1_code := a8(indx);
          t(ddindx).date_return_due := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).date_return_notified := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).relocate_asset_yn := a11(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).voluntary_yn := a13(indx);
          t(ddindx).commmercially_reas_sale_yn := a14(indx);
          t(ddindx).date_repossession_required := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).date_repossession_actual := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).date_hold_until := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).date_returned := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).date_title_returned := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a24(indx));
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
          t(ddindx).floor_price := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).new_item_number := a47(indx);
          t(ddindx).new_item_price := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).asset_relocated_yn := a49(indx);
          t(ddindx).repurchase_agmt_yn := a50(indx);
          t(ddindx).like_kind_yn := a51(indx);
          t(ddindx).currency_code := a52(indx);
          t(ddindx).currency_conversion_code := a53(indx);
          t(ddindx).currency_conversion_type := a54(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a56(indx));
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).asset_fmv_amount := rosetta_g_miss_num_map(a58(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_art_pvt.art_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
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
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_DATE_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
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
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
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
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_DATE_TABLE();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
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
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_DATE_TABLE();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).security_dep_trx_ap_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).iso_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).rna_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).rmr_id);
          a6(indx) := t(ddindx).ars_code;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).imr_id);
          a8(indx) := t(ddindx).art1_code;
          a9(indx) := t(ddindx).date_return_due;
          a10(indx) := t(ddindx).date_return_notified;
          a11(indx) := t(ddindx).relocate_asset_yn;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a13(indx) := t(ddindx).voluntary_yn;
          a14(indx) := t(ddindx).commmercially_reas_sale_yn;
          a15(indx) := t(ddindx).date_repossession_required;
          a16(indx) := t(ddindx).date_repossession_actual;
          a17(indx) := t(ddindx).date_hold_until;
          a18(indx) := t(ddindx).date_returned;
          a19(indx) := t(ddindx).date_title_returned;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
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
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a42(indx) := t(ddindx).creation_date;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a44(indx) := t(ddindx).last_update_date;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).floor_price);
          a47(indx) := t(ddindx).new_item_number;
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).new_item_price);
          a49(indx) := t(ddindx).asset_relocated_yn;
          a50(indx) := t(ddindx).repurchase_agmt_yn;
          a51(indx) := t(ddindx).like_kind_yn;
          a52(indx) := t(ddindx).currency_code;
          a53(indx) := t(ddindx).currency_conversion_code;
          a54(indx) := t(ddindx).currency_conversion_type;
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a56(indx) := t(ddindx).currency_conversion_date;
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).asset_fmv_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_art_pvt.okl_asset_returns_tl_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
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
          t(ddindx).comments := a4(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).new_item_description := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_art_pvt.okl_asset_returns_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
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
    a10 := JTF_VARCHAR2_TABLE_2000();
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
      a10 := JTF_VARCHAR2_TABLE_2000();
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
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).comments;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a10(indx) := t(ddindx).new_item_description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_art_pvt.artv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_2000
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
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_DATE_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_2000
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_DATE_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
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
          t(ddindx).rmr_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).imr_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).rna_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).iso_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).security_dep_trx_ap_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).ars_code := a9(indx);
          t(ddindx).art1_code := a10(indx);
          t(ddindx).date_returned := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).date_title_returned := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).date_return_due := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).date_return_notified := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).relocate_asset_yn := a15(indx);
          t(ddindx).voluntary_yn := a16(indx);
          t(ddindx).date_repossession_required := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).date_repossession_actual := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).date_hold_until := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).commmercially_reas_sale_yn := a20(indx);
          t(ddindx).comments := a21(indx);
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
          t(ddindx).org_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a44(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).floor_price := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).new_item_number := a49(indx);
          t(ddindx).new_item_price := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).asset_relocated_yn := a51(indx);
          t(ddindx).new_item_description := a52(indx);
          t(ddindx).repurchase_agmt_yn := a53(indx);
          t(ddindx).like_kind_yn := a54(indx);
          t(ddindx).currency_code := a55(indx);
          t(ddindx).currency_conversion_code := a56(indx);
          t(ddindx).currency_conversion_type := a57(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a59(indx));
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).asset_fmv_amount := rosetta_g_miss_num_map(a61(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_art_pvt.artv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_2000
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
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_DATE_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_DATE_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_2000();
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
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_DATE_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_2000();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_DATE_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_2000();
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
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_DATE_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_2000();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_DATE_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).rmr_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).imr_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).rna_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).iso_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).security_dep_trx_ap_id);
          a9(indx) := t(ddindx).ars_code;
          a10(indx) := t(ddindx).art1_code;
          a11(indx) := t(ddindx).date_returned;
          a12(indx) := t(ddindx).date_title_returned;
          a13(indx) := t(ddindx).date_return_due;
          a14(indx) := t(ddindx).date_return_notified;
          a15(indx) := t(ddindx).relocate_asset_yn;
          a16(indx) := t(ddindx).voluntary_yn;
          a17(indx) := t(ddindx).date_repossession_required;
          a18(indx) := t(ddindx).date_repossession_actual;
          a19(indx) := t(ddindx).date_hold_until;
          a20(indx) := t(ddindx).commmercially_reas_sale_yn;
          a21(indx) := t(ddindx).comments;
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
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a42(indx) := t(ddindx).program_update_date;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a44(indx) := t(ddindx).creation_date;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a46(indx) := t(ddindx).last_update_date;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).floor_price);
          a49(indx) := t(ddindx).new_item_number;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).new_item_price);
          a51(indx) := t(ddindx).asset_relocated_yn;
          a52(indx) := t(ddindx).new_item_description;
          a53(indx) := t(ddindx).repurchase_agmt_yn;
          a54(indx) := t(ddindx).like_kind_yn;
          a55(indx) := t(ddindx).currency_code;
          a56(indx) := t(ddindx).currency_conversion_code;
          a57(indx) := t(ddindx).currency_conversion_type;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a59(indx) := t(ddindx).currency_conversion_date;
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).asset_fmv_amount);
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
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
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
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
  )

  as
    ddp_artv_rec okl_art_pvt.artv_rec_type;
    ddx_artv_rec okl_art_pvt.artv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_artv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_artv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_artv_rec.sfwt_flag := p5_a2;
    ddp_artv_rec.rmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_artv_rec.imr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_artv_rec.rna_id := rosetta_g_miss_num_map(p5_a5);
    ddp_artv_rec.kle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_artv_rec.iso_id := rosetta_g_miss_num_map(p5_a7);
    ddp_artv_rec.security_dep_trx_ap_id := rosetta_g_miss_num_map(p5_a8);
    ddp_artv_rec.ars_code := p5_a9;
    ddp_artv_rec.art1_code := p5_a10;
    ddp_artv_rec.date_returned := rosetta_g_miss_date_in_map(p5_a11);
    ddp_artv_rec.date_title_returned := rosetta_g_miss_date_in_map(p5_a12);
    ddp_artv_rec.date_return_due := rosetta_g_miss_date_in_map(p5_a13);
    ddp_artv_rec.date_return_notified := rosetta_g_miss_date_in_map(p5_a14);
    ddp_artv_rec.relocate_asset_yn := p5_a15;
    ddp_artv_rec.voluntary_yn := p5_a16;
    ddp_artv_rec.date_repossession_required := rosetta_g_miss_date_in_map(p5_a17);
    ddp_artv_rec.date_repossession_actual := rosetta_g_miss_date_in_map(p5_a18);
    ddp_artv_rec.date_hold_until := rosetta_g_miss_date_in_map(p5_a19);
    ddp_artv_rec.commmercially_reas_sale_yn := p5_a20;
    ddp_artv_rec.comments := p5_a21;
    ddp_artv_rec.attribute_category := p5_a22;
    ddp_artv_rec.attribute1 := p5_a23;
    ddp_artv_rec.attribute2 := p5_a24;
    ddp_artv_rec.attribute3 := p5_a25;
    ddp_artv_rec.attribute4 := p5_a26;
    ddp_artv_rec.attribute5 := p5_a27;
    ddp_artv_rec.attribute6 := p5_a28;
    ddp_artv_rec.attribute7 := p5_a29;
    ddp_artv_rec.attribute8 := p5_a30;
    ddp_artv_rec.attribute9 := p5_a31;
    ddp_artv_rec.attribute10 := p5_a32;
    ddp_artv_rec.attribute11 := p5_a33;
    ddp_artv_rec.attribute12 := p5_a34;
    ddp_artv_rec.attribute13 := p5_a35;
    ddp_artv_rec.attribute14 := p5_a36;
    ddp_artv_rec.attribute15 := p5_a37;
    ddp_artv_rec.org_id := rosetta_g_miss_num_map(p5_a38);
    ddp_artv_rec.request_id := rosetta_g_miss_num_map(p5_a39);
    ddp_artv_rec.program_application_id := rosetta_g_miss_num_map(p5_a40);
    ddp_artv_rec.program_id := rosetta_g_miss_num_map(p5_a41);
    ddp_artv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_artv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_artv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_artv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_artv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_artv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_artv_rec.floor_price := rosetta_g_miss_num_map(p5_a48);
    ddp_artv_rec.new_item_number := p5_a49;
    ddp_artv_rec.new_item_price := rosetta_g_miss_num_map(p5_a50);
    ddp_artv_rec.asset_relocated_yn := p5_a51;
    ddp_artv_rec.new_item_description := p5_a52;
    ddp_artv_rec.repurchase_agmt_yn := p5_a53;
    ddp_artv_rec.like_kind_yn := p5_a54;
    ddp_artv_rec.currency_code := p5_a55;
    ddp_artv_rec.currency_conversion_code := p5_a56;
    ddp_artv_rec.currency_conversion_type := p5_a57;
    ddp_artv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_artv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_artv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a60);
    ddp_artv_rec.asset_fmv_amount := rosetta_g_miss_num_map(p5_a61);


    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_rec,
      ddx_artv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_artv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_artv_rec.object_version_number);
    p6_a2 := ddx_artv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_artv_rec.rmr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_artv_rec.imr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_artv_rec.rna_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_artv_rec.kle_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_artv_rec.iso_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_artv_rec.security_dep_trx_ap_id);
    p6_a9 := ddx_artv_rec.ars_code;
    p6_a10 := ddx_artv_rec.art1_code;
    p6_a11 := ddx_artv_rec.date_returned;
    p6_a12 := ddx_artv_rec.date_title_returned;
    p6_a13 := ddx_artv_rec.date_return_due;
    p6_a14 := ddx_artv_rec.date_return_notified;
    p6_a15 := ddx_artv_rec.relocate_asset_yn;
    p6_a16 := ddx_artv_rec.voluntary_yn;
    p6_a17 := ddx_artv_rec.date_repossession_required;
    p6_a18 := ddx_artv_rec.date_repossession_actual;
    p6_a19 := ddx_artv_rec.date_hold_until;
    p6_a20 := ddx_artv_rec.commmercially_reas_sale_yn;
    p6_a21 := ddx_artv_rec.comments;
    p6_a22 := ddx_artv_rec.attribute_category;
    p6_a23 := ddx_artv_rec.attribute1;
    p6_a24 := ddx_artv_rec.attribute2;
    p6_a25 := ddx_artv_rec.attribute3;
    p6_a26 := ddx_artv_rec.attribute4;
    p6_a27 := ddx_artv_rec.attribute5;
    p6_a28 := ddx_artv_rec.attribute6;
    p6_a29 := ddx_artv_rec.attribute7;
    p6_a30 := ddx_artv_rec.attribute8;
    p6_a31 := ddx_artv_rec.attribute9;
    p6_a32 := ddx_artv_rec.attribute10;
    p6_a33 := ddx_artv_rec.attribute11;
    p6_a34 := ddx_artv_rec.attribute12;
    p6_a35 := ddx_artv_rec.attribute13;
    p6_a36 := ddx_artv_rec.attribute14;
    p6_a37 := ddx_artv_rec.attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_artv_rec.org_id);
    p6_a39 := rosetta_g_miss_num_map(ddx_artv_rec.request_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_artv_rec.program_application_id);
    p6_a41 := rosetta_g_miss_num_map(ddx_artv_rec.program_id);
    p6_a42 := ddx_artv_rec.program_update_date;
    p6_a43 := rosetta_g_miss_num_map(ddx_artv_rec.created_by);
    p6_a44 := ddx_artv_rec.creation_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_artv_rec.last_updated_by);
    p6_a46 := ddx_artv_rec.last_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_artv_rec.last_update_login);
    p6_a48 := rosetta_g_miss_num_map(ddx_artv_rec.floor_price);
    p6_a49 := ddx_artv_rec.new_item_number;
    p6_a50 := rosetta_g_miss_num_map(ddx_artv_rec.new_item_price);
    p6_a51 := ddx_artv_rec.asset_relocated_yn;
    p6_a52 := ddx_artv_rec.new_item_description;
    p6_a53 := ddx_artv_rec.repurchase_agmt_yn;
    p6_a54 := ddx_artv_rec.like_kind_yn;
    p6_a55 := ddx_artv_rec.currency_code;
    p6_a56 := ddx_artv_rec.currency_conversion_code;
    p6_a57 := ddx_artv_rec.currency_conversion_type;
    p6_a58 := rosetta_g_miss_num_map(ddx_artv_rec.currency_conversion_rate);
    p6_a59 := ddx_artv_rec.currency_conversion_date;
    p6_a60 := rosetta_g_miss_num_map(ddx_artv_rec.legal_entity_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_artv_rec.asset_fmv_amount);
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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_2000
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
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_2000
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
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_artv_tbl okl_art_pvt.artv_tbl_type;
    ddx_artv_tbl okl_art_pvt.artv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_art_pvt_w.rosetta_table_copy_in_p8(ddp_artv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_tbl,
      ddx_artv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_art_pvt_w.rosetta_table_copy_out_p8(ddx_artv_tbl, p6_a0
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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
  )

  as
    ddp_artv_rec okl_art_pvt.artv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_artv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_artv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_artv_rec.sfwt_flag := p5_a2;
    ddp_artv_rec.rmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_artv_rec.imr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_artv_rec.rna_id := rosetta_g_miss_num_map(p5_a5);
    ddp_artv_rec.kle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_artv_rec.iso_id := rosetta_g_miss_num_map(p5_a7);
    ddp_artv_rec.security_dep_trx_ap_id := rosetta_g_miss_num_map(p5_a8);
    ddp_artv_rec.ars_code := p5_a9;
    ddp_artv_rec.art1_code := p5_a10;
    ddp_artv_rec.date_returned := rosetta_g_miss_date_in_map(p5_a11);
    ddp_artv_rec.date_title_returned := rosetta_g_miss_date_in_map(p5_a12);
    ddp_artv_rec.date_return_due := rosetta_g_miss_date_in_map(p5_a13);
    ddp_artv_rec.date_return_notified := rosetta_g_miss_date_in_map(p5_a14);
    ddp_artv_rec.relocate_asset_yn := p5_a15;
    ddp_artv_rec.voluntary_yn := p5_a16;
    ddp_artv_rec.date_repossession_required := rosetta_g_miss_date_in_map(p5_a17);
    ddp_artv_rec.date_repossession_actual := rosetta_g_miss_date_in_map(p5_a18);
    ddp_artv_rec.date_hold_until := rosetta_g_miss_date_in_map(p5_a19);
    ddp_artv_rec.commmercially_reas_sale_yn := p5_a20;
    ddp_artv_rec.comments := p5_a21;
    ddp_artv_rec.attribute_category := p5_a22;
    ddp_artv_rec.attribute1 := p5_a23;
    ddp_artv_rec.attribute2 := p5_a24;
    ddp_artv_rec.attribute3 := p5_a25;
    ddp_artv_rec.attribute4 := p5_a26;
    ddp_artv_rec.attribute5 := p5_a27;
    ddp_artv_rec.attribute6 := p5_a28;
    ddp_artv_rec.attribute7 := p5_a29;
    ddp_artv_rec.attribute8 := p5_a30;
    ddp_artv_rec.attribute9 := p5_a31;
    ddp_artv_rec.attribute10 := p5_a32;
    ddp_artv_rec.attribute11 := p5_a33;
    ddp_artv_rec.attribute12 := p5_a34;
    ddp_artv_rec.attribute13 := p5_a35;
    ddp_artv_rec.attribute14 := p5_a36;
    ddp_artv_rec.attribute15 := p5_a37;
    ddp_artv_rec.org_id := rosetta_g_miss_num_map(p5_a38);
    ddp_artv_rec.request_id := rosetta_g_miss_num_map(p5_a39);
    ddp_artv_rec.program_application_id := rosetta_g_miss_num_map(p5_a40);
    ddp_artv_rec.program_id := rosetta_g_miss_num_map(p5_a41);
    ddp_artv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_artv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_artv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_artv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_artv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_artv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_artv_rec.floor_price := rosetta_g_miss_num_map(p5_a48);
    ddp_artv_rec.new_item_number := p5_a49;
    ddp_artv_rec.new_item_price := rosetta_g_miss_num_map(p5_a50);
    ddp_artv_rec.asset_relocated_yn := p5_a51;
    ddp_artv_rec.new_item_description := p5_a52;
    ddp_artv_rec.repurchase_agmt_yn := p5_a53;
    ddp_artv_rec.like_kind_yn := p5_a54;
    ddp_artv_rec.currency_code := p5_a55;
    ddp_artv_rec.currency_conversion_code := p5_a56;
    ddp_artv_rec.currency_conversion_type := p5_a57;
    ddp_artv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_artv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_artv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a60);
    ddp_artv_rec.asset_fmv_amount := rosetta_g_miss_num_map(p5_a61);

    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_2000
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
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
  )

  as
    ddp_artv_tbl okl_art_pvt.artv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_art_pvt_w.rosetta_table_copy_in_p8(ddp_artv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_tbl);

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
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
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
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
  )

  as
    ddp_artv_rec okl_art_pvt.artv_rec_type;
    ddx_artv_rec okl_art_pvt.artv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_artv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_artv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_artv_rec.sfwt_flag := p5_a2;
    ddp_artv_rec.rmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_artv_rec.imr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_artv_rec.rna_id := rosetta_g_miss_num_map(p5_a5);
    ddp_artv_rec.kle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_artv_rec.iso_id := rosetta_g_miss_num_map(p5_a7);
    ddp_artv_rec.security_dep_trx_ap_id := rosetta_g_miss_num_map(p5_a8);
    ddp_artv_rec.ars_code := p5_a9;
    ddp_artv_rec.art1_code := p5_a10;
    ddp_artv_rec.date_returned := rosetta_g_miss_date_in_map(p5_a11);
    ddp_artv_rec.date_title_returned := rosetta_g_miss_date_in_map(p5_a12);
    ddp_artv_rec.date_return_due := rosetta_g_miss_date_in_map(p5_a13);
    ddp_artv_rec.date_return_notified := rosetta_g_miss_date_in_map(p5_a14);
    ddp_artv_rec.relocate_asset_yn := p5_a15;
    ddp_artv_rec.voluntary_yn := p5_a16;
    ddp_artv_rec.date_repossession_required := rosetta_g_miss_date_in_map(p5_a17);
    ddp_artv_rec.date_repossession_actual := rosetta_g_miss_date_in_map(p5_a18);
    ddp_artv_rec.date_hold_until := rosetta_g_miss_date_in_map(p5_a19);
    ddp_artv_rec.commmercially_reas_sale_yn := p5_a20;
    ddp_artv_rec.comments := p5_a21;
    ddp_artv_rec.attribute_category := p5_a22;
    ddp_artv_rec.attribute1 := p5_a23;
    ddp_artv_rec.attribute2 := p5_a24;
    ddp_artv_rec.attribute3 := p5_a25;
    ddp_artv_rec.attribute4 := p5_a26;
    ddp_artv_rec.attribute5 := p5_a27;
    ddp_artv_rec.attribute6 := p5_a28;
    ddp_artv_rec.attribute7 := p5_a29;
    ddp_artv_rec.attribute8 := p5_a30;
    ddp_artv_rec.attribute9 := p5_a31;
    ddp_artv_rec.attribute10 := p5_a32;
    ddp_artv_rec.attribute11 := p5_a33;
    ddp_artv_rec.attribute12 := p5_a34;
    ddp_artv_rec.attribute13 := p5_a35;
    ddp_artv_rec.attribute14 := p5_a36;
    ddp_artv_rec.attribute15 := p5_a37;
    ddp_artv_rec.org_id := rosetta_g_miss_num_map(p5_a38);
    ddp_artv_rec.request_id := rosetta_g_miss_num_map(p5_a39);
    ddp_artv_rec.program_application_id := rosetta_g_miss_num_map(p5_a40);
    ddp_artv_rec.program_id := rosetta_g_miss_num_map(p5_a41);
    ddp_artv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_artv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_artv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_artv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_artv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_artv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_artv_rec.floor_price := rosetta_g_miss_num_map(p5_a48);
    ddp_artv_rec.new_item_number := p5_a49;
    ddp_artv_rec.new_item_price := rosetta_g_miss_num_map(p5_a50);
    ddp_artv_rec.asset_relocated_yn := p5_a51;
    ddp_artv_rec.new_item_description := p5_a52;
    ddp_artv_rec.repurchase_agmt_yn := p5_a53;
    ddp_artv_rec.like_kind_yn := p5_a54;
    ddp_artv_rec.currency_code := p5_a55;
    ddp_artv_rec.currency_conversion_code := p5_a56;
    ddp_artv_rec.currency_conversion_type := p5_a57;
    ddp_artv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_artv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_artv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a60);
    ddp_artv_rec.asset_fmv_amount := rosetta_g_miss_num_map(p5_a61);


    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_rec,
      ddx_artv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_artv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_artv_rec.object_version_number);
    p6_a2 := ddx_artv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_artv_rec.rmr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_artv_rec.imr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_artv_rec.rna_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_artv_rec.kle_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_artv_rec.iso_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_artv_rec.security_dep_trx_ap_id);
    p6_a9 := ddx_artv_rec.ars_code;
    p6_a10 := ddx_artv_rec.art1_code;
    p6_a11 := ddx_artv_rec.date_returned;
    p6_a12 := ddx_artv_rec.date_title_returned;
    p6_a13 := ddx_artv_rec.date_return_due;
    p6_a14 := ddx_artv_rec.date_return_notified;
    p6_a15 := ddx_artv_rec.relocate_asset_yn;
    p6_a16 := ddx_artv_rec.voluntary_yn;
    p6_a17 := ddx_artv_rec.date_repossession_required;
    p6_a18 := ddx_artv_rec.date_repossession_actual;
    p6_a19 := ddx_artv_rec.date_hold_until;
    p6_a20 := ddx_artv_rec.commmercially_reas_sale_yn;
    p6_a21 := ddx_artv_rec.comments;
    p6_a22 := ddx_artv_rec.attribute_category;
    p6_a23 := ddx_artv_rec.attribute1;
    p6_a24 := ddx_artv_rec.attribute2;
    p6_a25 := ddx_artv_rec.attribute3;
    p6_a26 := ddx_artv_rec.attribute4;
    p6_a27 := ddx_artv_rec.attribute5;
    p6_a28 := ddx_artv_rec.attribute6;
    p6_a29 := ddx_artv_rec.attribute7;
    p6_a30 := ddx_artv_rec.attribute8;
    p6_a31 := ddx_artv_rec.attribute9;
    p6_a32 := ddx_artv_rec.attribute10;
    p6_a33 := ddx_artv_rec.attribute11;
    p6_a34 := ddx_artv_rec.attribute12;
    p6_a35 := ddx_artv_rec.attribute13;
    p6_a36 := ddx_artv_rec.attribute14;
    p6_a37 := ddx_artv_rec.attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_artv_rec.org_id);
    p6_a39 := rosetta_g_miss_num_map(ddx_artv_rec.request_id);
    p6_a40 := rosetta_g_miss_num_map(ddx_artv_rec.program_application_id);
    p6_a41 := rosetta_g_miss_num_map(ddx_artv_rec.program_id);
    p6_a42 := ddx_artv_rec.program_update_date;
    p6_a43 := rosetta_g_miss_num_map(ddx_artv_rec.created_by);
    p6_a44 := ddx_artv_rec.creation_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_artv_rec.last_updated_by);
    p6_a46 := ddx_artv_rec.last_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_artv_rec.last_update_login);
    p6_a48 := rosetta_g_miss_num_map(ddx_artv_rec.floor_price);
    p6_a49 := ddx_artv_rec.new_item_number;
    p6_a50 := rosetta_g_miss_num_map(ddx_artv_rec.new_item_price);
    p6_a51 := ddx_artv_rec.asset_relocated_yn;
    p6_a52 := ddx_artv_rec.new_item_description;
    p6_a53 := ddx_artv_rec.repurchase_agmt_yn;
    p6_a54 := ddx_artv_rec.like_kind_yn;
    p6_a55 := ddx_artv_rec.currency_code;
    p6_a56 := ddx_artv_rec.currency_conversion_code;
    p6_a57 := ddx_artv_rec.currency_conversion_type;
    p6_a58 := rosetta_g_miss_num_map(ddx_artv_rec.currency_conversion_rate);
    p6_a59 := ddx_artv_rec.currency_conversion_date;
    p6_a60 := rosetta_g_miss_num_map(ddx_artv_rec.legal_entity_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_artv_rec.asset_fmv_amount);
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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_2000
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
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_2000
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
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_DATE_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_artv_tbl okl_art_pvt.artv_tbl_type;
    ddx_artv_tbl okl_art_pvt.artv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_art_pvt_w.rosetta_table_copy_in_p8(ddp_artv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_tbl,
      ddx_artv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_art_pvt_w.rosetta_table_copy_out_p8(ddx_artv_tbl, p6_a0
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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
  )

  as
    ddp_artv_rec okl_art_pvt.artv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_artv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_artv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_artv_rec.sfwt_flag := p5_a2;
    ddp_artv_rec.rmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_artv_rec.imr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_artv_rec.rna_id := rosetta_g_miss_num_map(p5_a5);
    ddp_artv_rec.kle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_artv_rec.iso_id := rosetta_g_miss_num_map(p5_a7);
    ddp_artv_rec.security_dep_trx_ap_id := rosetta_g_miss_num_map(p5_a8);
    ddp_artv_rec.ars_code := p5_a9;
    ddp_artv_rec.art1_code := p5_a10;
    ddp_artv_rec.date_returned := rosetta_g_miss_date_in_map(p5_a11);
    ddp_artv_rec.date_title_returned := rosetta_g_miss_date_in_map(p5_a12);
    ddp_artv_rec.date_return_due := rosetta_g_miss_date_in_map(p5_a13);
    ddp_artv_rec.date_return_notified := rosetta_g_miss_date_in_map(p5_a14);
    ddp_artv_rec.relocate_asset_yn := p5_a15;
    ddp_artv_rec.voluntary_yn := p5_a16;
    ddp_artv_rec.date_repossession_required := rosetta_g_miss_date_in_map(p5_a17);
    ddp_artv_rec.date_repossession_actual := rosetta_g_miss_date_in_map(p5_a18);
    ddp_artv_rec.date_hold_until := rosetta_g_miss_date_in_map(p5_a19);
    ddp_artv_rec.commmercially_reas_sale_yn := p5_a20;
    ddp_artv_rec.comments := p5_a21;
    ddp_artv_rec.attribute_category := p5_a22;
    ddp_artv_rec.attribute1 := p5_a23;
    ddp_artv_rec.attribute2 := p5_a24;
    ddp_artv_rec.attribute3 := p5_a25;
    ddp_artv_rec.attribute4 := p5_a26;
    ddp_artv_rec.attribute5 := p5_a27;
    ddp_artv_rec.attribute6 := p5_a28;
    ddp_artv_rec.attribute7 := p5_a29;
    ddp_artv_rec.attribute8 := p5_a30;
    ddp_artv_rec.attribute9 := p5_a31;
    ddp_artv_rec.attribute10 := p5_a32;
    ddp_artv_rec.attribute11 := p5_a33;
    ddp_artv_rec.attribute12 := p5_a34;
    ddp_artv_rec.attribute13 := p5_a35;
    ddp_artv_rec.attribute14 := p5_a36;
    ddp_artv_rec.attribute15 := p5_a37;
    ddp_artv_rec.org_id := rosetta_g_miss_num_map(p5_a38);
    ddp_artv_rec.request_id := rosetta_g_miss_num_map(p5_a39);
    ddp_artv_rec.program_application_id := rosetta_g_miss_num_map(p5_a40);
    ddp_artv_rec.program_id := rosetta_g_miss_num_map(p5_a41);
    ddp_artv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_artv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_artv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_artv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_artv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_artv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_artv_rec.floor_price := rosetta_g_miss_num_map(p5_a48);
    ddp_artv_rec.new_item_number := p5_a49;
    ddp_artv_rec.new_item_price := rosetta_g_miss_num_map(p5_a50);
    ddp_artv_rec.asset_relocated_yn := p5_a51;
    ddp_artv_rec.new_item_description := p5_a52;
    ddp_artv_rec.repurchase_agmt_yn := p5_a53;
    ddp_artv_rec.like_kind_yn := p5_a54;
    ddp_artv_rec.currency_code := p5_a55;
    ddp_artv_rec.currency_conversion_code := p5_a56;
    ddp_artv_rec.currency_conversion_type := p5_a57;
    ddp_artv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_artv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_artv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a60);
    ddp_artv_rec.asset_fmv_amount := rosetta_g_miss_num_map(p5_a61);

    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_2000
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
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
  )

  as
    ddp_artv_tbl okl_art_pvt.artv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_art_pvt_w.rosetta_table_copy_in_p8(ddp_artv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_tbl);

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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
  )

  as
    ddp_artv_rec okl_art_pvt.artv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_artv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_artv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_artv_rec.sfwt_flag := p5_a2;
    ddp_artv_rec.rmr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_artv_rec.imr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_artv_rec.rna_id := rosetta_g_miss_num_map(p5_a5);
    ddp_artv_rec.kle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_artv_rec.iso_id := rosetta_g_miss_num_map(p5_a7);
    ddp_artv_rec.security_dep_trx_ap_id := rosetta_g_miss_num_map(p5_a8);
    ddp_artv_rec.ars_code := p5_a9;
    ddp_artv_rec.art1_code := p5_a10;
    ddp_artv_rec.date_returned := rosetta_g_miss_date_in_map(p5_a11);
    ddp_artv_rec.date_title_returned := rosetta_g_miss_date_in_map(p5_a12);
    ddp_artv_rec.date_return_due := rosetta_g_miss_date_in_map(p5_a13);
    ddp_artv_rec.date_return_notified := rosetta_g_miss_date_in_map(p5_a14);
    ddp_artv_rec.relocate_asset_yn := p5_a15;
    ddp_artv_rec.voluntary_yn := p5_a16;
    ddp_artv_rec.date_repossession_required := rosetta_g_miss_date_in_map(p5_a17);
    ddp_artv_rec.date_repossession_actual := rosetta_g_miss_date_in_map(p5_a18);
    ddp_artv_rec.date_hold_until := rosetta_g_miss_date_in_map(p5_a19);
    ddp_artv_rec.commmercially_reas_sale_yn := p5_a20;
    ddp_artv_rec.comments := p5_a21;
    ddp_artv_rec.attribute_category := p5_a22;
    ddp_artv_rec.attribute1 := p5_a23;
    ddp_artv_rec.attribute2 := p5_a24;
    ddp_artv_rec.attribute3 := p5_a25;
    ddp_artv_rec.attribute4 := p5_a26;
    ddp_artv_rec.attribute5 := p5_a27;
    ddp_artv_rec.attribute6 := p5_a28;
    ddp_artv_rec.attribute7 := p5_a29;
    ddp_artv_rec.attribute8 := p5_a30;
    ddp_artv_rec.attribute9 := p5_a31;
    ddp_artv_rec.attribute10 := p5_a32;
    ddp_artv_rec.attribute11 := p5_a33;
    ddp_artv_rec.attribute12 := p5_a34;
    ddp_artv_rec.attribute13 := p5_a35;
    ddp_artv_rec.attribute14 := p5_a36;
    ddp_artv_rec.attribute15 := p5_a37;
    ddp_artv_rec.org_id := rosetta_g_miss_num_map(p5_a38);
    ddp_artv_rec.request_id := rosetta_g_miss_num_map(p5_a39);
    ddp_artv_rec.program_application_id := rosetta_g_miss_num_map(p5_a40);
    ddp_artv_rec.program_id := rosetta_g_miss_num_map(p5_a41);
    ddp_artv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a42);
    ddp_artv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_artv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_artv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_artv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_artv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_artv_rec.floor_price := rosetta_g_miss_num_map(p5_a48);
    ddp_artv_rec.new_item_number := p5_a49;
    ddp_artv_rec.new_item_price := rosetta_g_miss_num_map(p5_a50);
    ddp_artv_rec.asset_relocated_yn := p5_a51;
    ddp_artv_rec.new_item_description := p5_a52;
    ddp_artv_rec.repurchase_agmt_yn := p5_a53;
    ddp_artv_rec.like_kind_yn := p5_a54;
    ddp_artv_rec.currency_code := p5_a55;
    ddp_artv_rec.currency_conversion_code := p5_a56;
    ddp_artv_rec.currency_conversion_type := p5_a57;
    ddp_artv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_artv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_artv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a60);
    ddp_artv_rec.asset_fmv_amount := rosetta_g_miss_num_map(p5_a61);

    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_2000
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
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_DATE_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_2000
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
  )

  as
    ddp_artv_tbl okl_art_pvt.artv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_art_pvt_w.rosetta_table_copy_in_p8(ddp_artv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_art_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_artv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_art_pvt_w;

/
