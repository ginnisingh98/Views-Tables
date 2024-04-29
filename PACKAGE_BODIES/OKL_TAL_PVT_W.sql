--------------------------------------------------------
--  DDL for Package Body OKL_TAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAL_PVT_W" as
  /* $Header: OKLITALB.pls 120.3.12010000.2 2010/04/29 15:05:41 rpillay ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_tal_pvt.tal_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_400
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_DATE_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_500
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
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_DATE_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_DATE_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_DATE_TABLE
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_NUMBER_TABLE
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
          t(ddindx).tas_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).ilo_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).ilo_id_old := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).iay_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).iay_id_new := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).dnz_khr_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).tal_type := a11(indx);
          t(ddindx).asset_number := a12(indx);
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).original_cost := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).current_units := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).manufacturer_name := a16(indx);
          t(ddindx).year_manufactured := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).supplier_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).used_asset_yn := a19(indx);
          t(ddindx).tag_number := a20(indx);
          t(ddindx).model_number := a21(indx);
          t(ddindx).corporate_book := a22(indx);
          t(ddindx).date_purchased := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).date_delivery := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).in_service_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).life_in_months := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).depreciation_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).depreciation_cost := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).deprn_method := a29(indx);
          t(ddindx).deprn_rate := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).salvage_value := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).percent_salvage_value := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).asset_key_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).fa_trx_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).fa_cost := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).attribute_category := a36(indx);
          t(ddindx).attribute1 := a37(indx);
          t(ddindx).attribute2 := a38(indx);
          t(ddindx).attribute3 := a39(indx);
          t(ddindx).attribute4 := a40(indx);
          t(ddindx).attribute5 := a41(indx);
          t(ddindx).attribute6 := a42(indx);
          t(ddindx).attribute7 := a43(indx);
          t(ddindx).attribute8 := a44(indx);
          t(ddindx).attribute9 := a45(indx);
          t(ddindx).attribute10 := a46(indx);
          t(ddindx).attribute11 := a47(indx);
          t(ddindx).attribute12 := a48(indx);
          t(ddindx).attribute13 := a49(indx);
          t(ddindx).attribute14 := a50(indx);
          t(ddindx).attribute15 := a51(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a55(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).depreciate_yn := a57(indx);
          t(ddindx).hold_period_days := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).old_salvage_value := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).new_residual_value := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).old_residual_value := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).units_retired := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).cost_retired := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).sale_proceeds := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).removal_cost := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).dnz_asset_id := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).date_due := rosetta_g_miss_date_in_map(a67(indx));
          t(ddindx).rep_asset_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).lke_asset_id := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).match_amount := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).split_into_singles_flag := a71(indx);
          t(ddindx).split_into_units := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).currency_code := a73(indx);
          t(ddindx).currency_conversion_type := a74(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a75(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a76(indx));
          t(ddindx).residual_shr_party_id := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).residual_shr_amount := rosetta_g_miss_num_map(a78(indx));
          t(ddindx).retirement_id := rosetta_g_miss_num_map(a79(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_tal_pvt.tal_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_400
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_500
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
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_DATE_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_DATE_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_DATE_TABLE
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_NUMBER_TABLE
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
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_400();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_500();
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
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_DATE_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_DATE_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_DATE_TABLE();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_NUMBER_TABLE();
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
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_400();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_500();
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
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_DATE_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_DATE_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_DATE_TABLE();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).tas_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).ilo_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).ilo_id_old);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).iay_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).iay_id_new);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_khr_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a11(indx) := t(ddindx).tal_type;
          a12(indx) := t(ddindx).asset_number;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).original_cost);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).current_units);
          a16(indx) := t(ddindx).manufacturer_name;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).year_manufactured);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).supplier_id);
          a19(indx) := t(ddindx).used_asset_yn;
          a20(indx) := t(ddindx).tag_number;
          a21(indx) := t(ddindx).model_number;
          a22(indx) := t(ddindx).corporate_book;
          a23(indx) := t(ddindx).date_purchased;
          a24(indx) := t(ddindx).date_delivery;
          a25(indx) := t(ddindx).in_service_date;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).life_in_months);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).depreciation_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).depreciation_cost);
          a29(indx) := t(ddindx).deprn_method;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).deprn_rate);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).salvage_value);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).percent_salvage_value);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).asset_key_id);
          a34(indx) := t(ddindx).fa_trx_date;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).fa_cost);
          a36(indx) := t(ddindx).attribute_category;
          a37(indx) := t(ddindx).attribute1;
          a38(indx) := t(ddindx).attribute2;
          a39(indx) := t(ddindx).attribute3;
          a40(indx) := t(ddindx).attribute4;
          a41(indx) := t(ddindx).attribute5;
          a42(indx) := t(ddindx).attribute6;
          a43(indx) := t(ddindx).attribute7;
          a44(indx) := t(ddindx).attribute8;
          a45(indx) := t(ddindx).attribute9;
          a46(indx) := t(ddindx).attribute10;
          a47(indx) := t(ddindx).attribute11;
          a48(indx) := t(ddindx).attribute12;
          a49(indx) := t(ddindx).attribute13;
          a50(indx) := t(ddindx).attribute14;
          a51(indx) := t(ddindx).attribute15;
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a53(indx) := t(ddindx).creation_date;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a55(indx) := t(ddindx).last_update_date;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a57(indx) := t(ddindx).depreciate_yn;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).hold_period_days);
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).old_salvage_value);
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).new_residual_value);
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).old_residual_value);
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).units_retired);
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).cost_retired);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).sale_proceeds);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).removal_cost);
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_asset_id);
          a67(indx) := t(ddindx).date_due;
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).rep_asset_id);
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).lke_asset_id);
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).match_amount);
          a71(indx) := t(ddindx).split_into_singles_flag;
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).split_into_units);
          a73(indx) := t(ddindx).currency_code;
          a74(indx) := t(ddindx).currency_conversion_type;
          a75(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a76(indx) := t(ddindx).currency_conversion_date;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).residual_shr_party_id);
          a78(indx) := rosetta_g_miss_num_map(t(ddindx).residual_shr_amount);
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).retirement_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_tal_pvt.okl_txl_assets_tl_tbl_type, a0 JTF_NUMBER_TABLE
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
  procedure rosetta_table_copy_out_p5(t okl_tal_pvt.okl_txl_assets_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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

  procedure rosetta_table_copy_in_p8(t out nocopy okl_tal_pvt.talv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
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
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_400
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
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
    , a53 JTF_VARCHAR2_TABLE_500
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_DATE_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_DATE_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_DATE_TABLE
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
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
          t(ddindx).tas_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).ilo_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).ilo_id_old := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).iay_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).iay_id_new := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).dnz_khr_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).tal_type := a12(indx);
          t(ddindx).asset_number := a13(indx);
          t(ddindx).description := a14(indx);
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).original_cost := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).current_units := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).manufacturer_name := a18(indx);
          t(ddindx).year_manufactured := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).supplier_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).used_asset_yn := a21(indx);
          t(ddindx).tag_number := a22(indx);
          t(ddindx).model_number := a23(indx);
          t(ddindx).corporate_book := a24(indx);
          t(ddindx).date_purchased := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).date_delivery := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).in_service_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).life_in_months := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).depreciation_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).depreciation_cost := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).deprn_method := a31(indx);
          t(ddindx).deprn_rate := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).salvage_value := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).percent_salvage_value := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).asset_key_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).fa_trx_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).fa_cost := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).attribute_category := a38(indx);
          t(ddindx).attribute1 := a39(indx);
          t(ddindx).attribute2 := a40(indx);
          t(ddindx).attribute3 := a41(indx);
          t(ddindx).attribute4 := a42(indx);
          t(ddindx).attribute5 := a43(indx);
          t(ddindx).attribute6 := a44(indx);
          t(ddindx).attribute7 := a45(indx);
          t(ddindx).attribute8 := a46(indx);
          t(ddindx).attribute9 := a47(indx);
          t(ddindx).attribute10 := a48(indx);
          t(ddindx).attribute11 := a49(indx);
          t(ddindx).attribute12 := a50(indx);
          t(ddindx).attribute13 := a51(indx);
          t(ddindx).attribute14 := a52(indx);
          t(ddindx).attribute15 := a53(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a55(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a57(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).depreciate_yn := a59(indx);
          t(ddindx).hold_period_days := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).old_salvage_value := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).new_residual_value := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).old_residual_value := rosetta_g_miss_num_map(a63(indx));
          t(ddindx).units_retired := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).cost_retired := rosetta_g_miss_num_map(a65(indx));
          t(ddindx).sale_proceeds := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).removal_cost := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).dnz_asset_id := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).date_due := rosetta_g_miss_date_in_map(a69(indx));
          t(ddindx).rep_asset_id := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).lke_asset_id := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).match_amount := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).split_into_singles_flag := a73(indx);
          t(ddindx).split_into_units := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).currency_code := a75(indx);
          t(ddindx).currency_conversion_type := a76(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a78(indx));
          t(ddindx).residual_shr_party_id := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).residual_shr_amount := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).retirement_id := rosetta_g_miss_num_map(a81(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_tal_pvt.talv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_400
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a53 out nocopy JTF_VARCHAR2_TABLE_500
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_DATE_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_DATE_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_DATE_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_DATE_TABLE
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_NUMBER_TABLE
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
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_400();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
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
    a53 := JTF_VARCHAR2_TABLE_500();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_DATE_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_DATE_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_DATE_TABLE();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_NUMBER_TABLE();
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
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_400();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
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
      a53 := JTF_VARCHAR2_TABLE_500();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_DATE_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_DATE_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_DATE_TABLE();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).tas_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).ilo_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).ilo_id_old);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).iay_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).iay_id_new);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_khr_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a12(indx) := t(ddindx).tal_type;
          a13(indx) := t(ddindx).asset_number;
          a14(indx) := t(ddindx).description;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).original_cost);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).current_units);
          a18(indx) := t(ddindx).manufacturer_name;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).year_manufactured);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).supplier_id);
          a21(indx) := t(ddindx).used_asset_yn;
          a22(indx) := t(ddindx).tag_number;
          a23(indx) := t(ddindx).model_number;
          a24(indx) := t(ddindx).corporate_book;
          a25(indx) := t(ddindx).date_purchased;
          a26(indx) := t(ddindx).date_delivery;
          a27(indx) := t(ddindx).in_service_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).life_in_months);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).depreciation_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).depreciation_cost);
          a31(indx) := t(ddindx).deprn_method;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).deprn_rate);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).salvage_value);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).percent_salvage_value);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).asset_key_id);
          a36(indx) := t(ddindx).fa_trx_date;
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).fa_cost);
          a38(indx) := t(ddindx).attribute_category;
          a39(indx) := t(ddindx).attribute1;
          a40(indx) := t(ddindx).attribute2;
          a41(indx) := t(ddindx).attribute3;
          a42(indx) := t(ddindx).attribute4;
          a43(indx) := t(ddindx).attribute5;
          a44(indx) := t(ddindx).attribute6;
          a45(indx) := t(ddindx).attribute7;
          a46(indx) := t(ddindx).attribute8;
          a47(indx) := t(ddindx).attribute9;
          a48(indx) := t(ddindx).attribute10;
          a49(indx) := t(ddindx).attribute11;
          a50(indx) := t(ddindx).attribute12;
          a51(indx) := t(ddindx).attribute13;
          a52(indx) := t(ddindx).attribute14;
          a53(indx) := t(ddindx).attribute15;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a55(indx) := t(ddindx).creation_date;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a57(indx) := t(ddindx).last_update_date;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a59(indx) := t(ddindx).depreciate_yn;
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).hold_period_days);
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).old_salvage_value);
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).new_residual_value);
          a63(indx) := rosetta_g_miss_num_map(t(ddindx).old_residual_value);
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).units_retired);
          a65(indx) := rosetta_g_miss_num_map(t(ddindx).cost_retired);
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).sale_proceeds);
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).removal_cost);
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_asset_id);
          a69(indx) := t(ddindx).date_due;
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).rep_asset_id);
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).lke_asset_id);
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).match_amount);
          a73(indx) := t(ddindx).split_into_singles_flag;
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).split_into_units);
          a75(indx) := t(ddindx).currency_code;
          a76(indx) := t(ddindx).currency_conversion_type;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a78(indx) := t(ddindx).currency_conversion_date;
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).residual_shr_party_id);
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).residual_shr_amount);
          a81(indx) := rosetta_g_miss_num_map(t(ddindx).retirement_id);
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
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
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
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  DATE
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  DATE
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
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
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_talv_rec okl_tal_pvt.talv_rec_type;
    ddx_talv_rec okl_tal_pvt.talv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_talv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_talv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_talv_rec.sfwt_flag := p5_a2;
    ddp_talv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_talv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_talv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_talv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_talv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_talv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_talv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_talv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_talv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_talv_rec.tal_type := p5_a12;
    ddp_talv_rec.asset_number := p5_a13;
    ddp_talv_rec.description := p5_a14;
    ddp_talv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_talv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_talv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_talv_rec.manufacturer_name := p5_a18;
    ddp_talv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_talv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_talv_rec.used_asset_yn := p5_a21;
    ddp_talv_rec.tag_number := p5_a22;
    ddp_talv_rec.model_number := p5_a23;
    ddp_talv_rec.corporate_book := p5_a24;
    ddp_talv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_talv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_talv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_talv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_talv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_talv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_talv_rec.deprn_method := p5_a31;
    ddp_talv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_talv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_talv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_talv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_talv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_talv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_talv_rec.attribute_category := p5_a38;
    ddp_talv_rec.attribute1 := p5_a39;
    ddp_talv_rec.attribute2 := p5_a40;
    ddp_talv_rec.attribute3 := p5_a41;
    ddp_talv_rec.attribute4 := p5_a42;
    ddp_talv_rec.attribute5 := p5_a43;
    ddp_talv_rec.attribute6 := p5_a44;
    ddp_talv_rec.attribute7 := p5_a45;
    ddp_talv_rec.attribute8 := p5_a46;
    ddp_talv_rec.attribute9 := p5_a47;
    ddp_talv_rec.attribute10 := p5_a48;
    ddp_talv_rec.attribute11 := p5_a49;
    ddp_talv_rec.attribute12 := p5_a50;
    ddp_talv_rec.attribute13 := p5_a51;
    ddp_talv_rec.attribute14 := p5_a52;
    ddp_talv_rec.attribute15 := p5_a53;
    ddp_talv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_talv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_talv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_talv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_talv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_talv_rec.depreciate_yn := p5_a59;
    ddp_talv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_talv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_talv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_talv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_talv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_talv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_talv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_talv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_talv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_talv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_talv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_talv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_talv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_talv_rec.split_into_singles_flag := p5_a73;
    ddp_talv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_talv_rec.currency_code := p5_a75;
    ddp_talv_rec.currency_conversion_type := p5_a76;
    ddp_talv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_talv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_talv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_talv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_talv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);


    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_rec,
      ddx_talv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_talv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_talv_rec.object_version_number);
    p6_a2 := ddx_talv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_talv_rec.tas_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_talv_rec.ilo_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_talv_rec.ilo_id_old);
    p6_a6 := rosetta_g_miss_num_map(ddx_talv_rec.iay_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_talv_rec.iay_id_new);
    p6_a8 := rosetta_g_miss_num_map(ddx_talv_rec.kle_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_talv_rec.dnz_khr_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_talv_rec.line_number);
    p6_a11 := rosetta_g_miss_num_map(ddx_talv_rec.org_id);
    p6_a12 := ddx_talv_rec.tal_type;
    p6_a13 := ddx_talv_rec.asset_number;
    p6_a14 := ddx_talv_rec.description;
    p6_a15 := rosetta_g_miss_num_map(ddx_talv_rec.fa_location_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_talv_rec.original_cost);
    p6_a17 := rosetta_g_miss_num_map(ddx_talv_rec.current_units);
    p6_a18 := ddx_talv_rec.manufacturer_name;
    p6_a19 := rosetta_g_miss_num_map(ddx_talv_rec.year_manufactured);
    p6_a20 := rosetta_g_miss_num_map(ddx_talv_rec.supplier_id);
    p6_a21 := ddx_talv_rec.used_asset_yn;
    p6_a22 := ddx_talv_rec.tag_number;
    p6_a23 := ddx_talv_rec.model_number;
    p6_a24 := ddx_talv_rec.corporate_book;
    p6_a25 := ddx_talv_rec.date_purchased;
    p6_a26 := ddx_talv_rec.date_delivery;
    p6_a27 := ddx_talv_rec.in_service_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_talv_rec.life_in_months);
    p6_a29 := rosetta_g_miss_num_map(ddx_talv_rec.depreciation_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_talv_rec.depreciation_cost);
    p6_a31 := ddx_talv_rec.deprn_method;
    p6_a32 := rosetta_g_miss_num_map(ddx_talv_rec.deprn_rate);
    p6_a33 := rosetta_g_miss_num_map(ddx_talv_rec.salvage_value);
    p6_a34 := rosetta_g_miss_num_map(ddx_talv_rec.percent_salvage_value);
    p6_a35 := rosetta_g_miss_num_map(ddx_talv_rec.asset_key_id);
    p6_a36 := ddx_talv_rec.fa_trx_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_talv_rec.fa_cost);
    p6_a38 := ddx_talv_rec.attribute_category;
    p6_a39 := ddx_talv_rec.attribute1;
    p6_a40 := ddx_talv_rec.attribute2;
    p6_a41 := ddx_talv_rec.attribute3;
    p6_a42 := ddx_talv_rec.attribute4;
    p6_a43 := ddx_talv_rec.attribute5;
    p6_a44 := ddx_talv_rec.attribute6;
    p6_a45 := ddx_talv_rec.attribute7;
    p6_a46 := ddx_talv_rec.attribute8;
    p6_a47 := ddx_talv_rec.attribute9;
    p6_a48 := ddx_talv_rec.attribute10;
    p6_a49 := ddx_talv_rec.attribute11;
    p6_a50 := ddx_talv_rec.attribute12;
    p6_a51 := ddx_talv_rec.attribute13;
    p6_a52 := ddx_talv_rec.attribute14;
    p6_a53 := ddx_talv_rec.attribute15;
    p6_a54 := rosetta_g_miss_num_map(ddx_talv_rec.created_by);
    p6_a55 := ddx_talv_rec.creation_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_talv_rec.last_updated_by);
    p6_a57 := ddx_talv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_talv_rec.last_update_login);
    p6_a59 := ddx_talv_rec.depreciate_yn;
    p6_a60 := rosetta_g_miss_num_map(ddx_talv_rec.hold_period_days);
    p6_a61 := rosetta_g_miss_num_map(ddx_talv_rec.old_salvage_value);
    p6_a62 := rosetta_g_miss_num_map(ddx_talv_rec.new_residual_value);
    p6_a63 := rosetta_g_miss_num_map(ddx_talv_rec.old_residual_value);
    p6_a64 := rosetta_g_miss_num_map(ddx_talv_rec.units_retired);
    p6_a65 := rosetta_g_miss_num_map(ddx_talv_rec.cost_retired);
    p6_a66 := rosetta_g_miss_num_map(ddx_talv_rec.sale_proceeds);
    p6_a67 := rosetta_g_miss_num_map(ddx_talv_rec.removal_cost);
    p6_a68 := rosetta_g_miss_num_map(ddx_talv_rec.dnz_asset_id);
    p6_a69 := ddx_talv_rec.date_due;
    p6_a70 := rosetta_g_miss_num_map(ddx_talv_rec.rep_asset_id);
    p6_a71 := rosetta_g_miss_num_map(ddx_talv_rec.lke_asset_id);
    p6_a72 := rosetta_g_miss_num_map(ddx_talv_rec.match_amount);
    p6_a73 := ddx_talv_rec.split_into_singles_flag;
    p6_a74 := rosetta_g_miss_num_map(ddx_talv_rec.split_into_units);
    p6_a75 := ddx_talv_rec.currency_code;
    p6_a76 := ddx_talv_rec.currency_conversion_type;
    p6_a77 := rosetta_g_miss_num_map(ddx_talv_rec.currency_conversion_rate);
    p6_a78 := ddx_talv_rec.currency_conversion_date;
    p6_a79 := rosetta_g_miss_num_map(ddx_talv_rec.residual_shr_party_id);
    p6_a80 := rosetta_g_miss_num_map(ddx_talv_rec.residual_shr_amount);
    p6_a81 := rosetta_g_miss_num_map(ddx_talv_rec.retirement_id);
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
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
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
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_DATE_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_talv_tbl okl_tal_pvt.talv_tbl_type;
    ddx_talv_tbl okl_tal_pvt.talv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_talv_tbl, p5_a0
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
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_tbl,
      ddx_talv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tal_pvt_w.rosetta_table_copy_out_p8(ddx_talv_tbl, p6_a0
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
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
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
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
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
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_talv_rec okl_tal_pvt.talv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_talv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_talv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_talv_rec.sfwt_flag := p5_a2;
    ddp_talv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_talv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_talv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_talv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_talv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_talv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_talv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_talv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_talv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_talv_rec.tal_type := p5_a12;
    ddp_talv_rec.asset_number := p5_a13;
    ddp_talv_rec.description := p5_a14;
    ddp_talv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_talv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_talv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_talv_rec.manufacturer_name := p5_a18;
    ddp_talv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_talv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_talv_rec.used_asset_yn := p5_a21;
    ddp_talv_rec.tag_number := p5_a22;
    ddp_talv_rec.model_number := p5_a23;
    ddp_talv_rec.corporate_book := p5_a24;
    ddp_talv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_talv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_talv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_talv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_talv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_talv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_talv_rec.deprn_method := p5_a31;
    ddp_talv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_talv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_talv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_talv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_talv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_talv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_talv_rec.attribute_category := p5_a38;
    ddp_talv_rec.attribute1 := p5_a39;
    ddp_talv_rec.attribute2 := p5_a40;
    ddp_talv_rec.attribute3 := p5_a41;
    ddp_talv_rec.attribute4 := p5_a42;
    ddp_talv_rec.attribute5 := p5_a43;
    ddp_talv_rec.attribute6 := p5_a44;
    ddp_talv_rec.attribute7 := p5_a45;
    ddp_talv_rec.attribute8 := p5_a46;
    ddp_talv_rec.attribute9 := p5_a47;
    ddp_talv_rec.attribute10 := p5_a48;
    ddp_talv_rec.attribute11 := p5_a49;
    ddp_talv_rec.attribute12 := p5_a50;
    ddp_talv_rec.attribute13 := p5_a51;
    ddp_talv_rec.attribute14 := p5_a52;
    ddp_talv_rec.attribute15 := p5_a53;
    ddp_talv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_talv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_talv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_talv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_talv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_talv_rec.depreciate_yn := p5_a59;
    ddp_talv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_talv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_talv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_talv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_talv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_talv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_talv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_talv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_talv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_talv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_talv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_talv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_talv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_talv_rec.split_into_singles_flag := p5_a73;
    ddp_talv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_talv_rec.currency_code := p5_a75;
    ddp_talv_rec.currency_conversion_type := p5_a76;
    ddp_talv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_talv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_talv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_talv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_talv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);

    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_rec);

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
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
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
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
  )

  as
    ddp_talv_tbl okl_tal_pvt.talv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_talv_tbl, p5_a0
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
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_tbl);

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
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
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
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  DATE
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  DATE
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
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
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_talv_rec okl_tal_pvt.talv_rec_type;
    ddx_talv_rec okl_tal_pvt.talv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_talv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_talv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_talv_rec.sfwt_flag := p5_a2;
    ddp_talv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_talv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_talv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_talv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_talv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_talv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_talv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_talv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_talv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_talv_rec.tal_type := p5_a12;
    ddp_talv_rec.asset_number := p5_a13;
    ddp_talv_rec.description := p5_a14;
    ddp_talv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_talv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_talv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_talv_rec.manufacturer_name := p5_a18;
    ddp_talv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_talv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_talv_rec.used_asset_yn := p5_a21;
    ddp_talv_rec.tag_number := p5_a22;
    ddp_talv_rec.model_number := p5_a23;
    ddp_talv_rec.corporate_book := p5_a24;
    ddp_talv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_talv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_talv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_talv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_talv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_talv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_talv_rec.deprn_method := p5_a31;
    ddp_talv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_talv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_talv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_talv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_talv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_talv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_talv_rec.attribute_category := p5_a38;
    ddp_talv_rec.attribute1 := p5_a39;
    ddp_talv_rec.attribute2 := p5_a40;
    ddp_talv_rec.attribute3 := p5_a41;
    ddp_talv_rec.attribute4 := p5_a42;
    ddp_talv_rec.attribute5 := p5_a43;
    ddp_talv_rec.attribute6 := p5_a44;
    ddp_talv_rec.attribute7 := p5_a45;
    ddp_talv_rec.attribute8 := p5_a46;
    ddp_talv_rec.attribute9 := p5_a47;
    ddp_talv_rec.attribute10 := p5_a48;
    ddp_talv_rec.attribute11 := p5_a49;
    ddp_talv_rec.attribute12 := p5_a50;
    ddp_talv_rec.attribute13 := p5_a51;
    ddp_talv_rec.attribute14 := p5_a52;
    ddp_talv_rec.attribute15 := p5_a53;
    ddp_talv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_talv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_talv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_talv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_talv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_talv_rec.depreciate_yn := p5_a59;
    ddp_talv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_talv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_talv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_talv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_talv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_talv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_talv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_talv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_talv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_talv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_talv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_talv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_talv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_talv_rec.split_into_singles_flag := p5_a73;
    ddp_talv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_talv_rec.currency_code := p5_a75;
    ddp_talv_rec.currency_conversion_type := p5_a76;
    ddp_talv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_talv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_talv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_talv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_talv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);


    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_rec,
      ddx_talv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_talv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_talv_rec.object_version_number);
    p6_a2 := ddx_talv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_talv_rec.tas_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_talv_rec.ilo_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_talv_rec.ilo_id_old);
    p6_a6 := rosetta_g_miss_num_map(ddx_talv_rec.iay_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_talv_rec.iay_id_new);
    p6_a8 := rosetta_g_miss_num_map(ddx_talv_rec.kle_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_talv_rec.dnz_khr_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_talv_rec.line_number);
    p6_a11 := rosetta_g_miss_num_map(ddx_talv_rec.org_id);
    p6_a12 := ddx_talv_rec.tal_type;
    p6_a13 := ddx_talv_rec.asset_number;
    p6_a14 := ddx_talv_rec.description;
    p6_a15 := rosetta_g_miss_num_map(ddx_talv_rec.fa_location_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_talv_rec.original_cost);
    p6_a17 := rosetta_g_miss_num_map(ddx_talv_rec.current_units);
    p6_a18 := ddx_talv_rec.manufacturer_name;
    p6_a19 := rosetta_g_miss_num_map(ddx_talv_rec.year_manufactured);
    p6_a20 := rosetta_g_miss_num_map(ddx_talv_rec.supplier_id);
    p6_a21 := ddx_talv_rec.used_asset_yn;
    p6_a22 := ddx_talv_rec.tag_number;
    p6_a23 := ddx_talv_rec.model_number;
    p6_a24 := ddx_talv_rec.corporate_book;
    p6_a25 := ddx_talv_rec.date_purchased;
    p6_a26 := ddx_talv_rec.date_delivery;
    p6_a27 := ddx_talv_rec.in_service_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_talv_rec.life_in_months);
    p6_a29 := rosetta_g_miss_num_map(ddx_talv_rec.depreciation_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_talv_rec.depreciation_cost);
    p6_a31 := ddx_talv_rec.deprn_method;
    p6_a32 := rosetta_g_miss_num_map(ddx_talv_rec.deprn_rate);
    p6_a33 := rosetta_g_miss_num_map(ddx_talv_rec.salvage_value);
    p6_a34 := rosetta_g_miss_num_map(ddx_talv_rec.percent_salvage_value);
    p6_a35 := rosetta_g_miss_num_map(ddx_talv_rec.asset_key_id);
    p6_a36 := ddx_talv_rec.fa_trx_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_talv_rec.fa_cost);
    p6_a38 := ddx_talv_rec.attribute_category;
    p6_a39 := ddx_talv_rec.attribute1;
    p6_a40 := ddx_talv_rec.attribute2;
    p6_a41 := ddx_talv_rec.attribute3;
    p6_a42 := ddx_talv_rec.attribute4;
    p6_a43 := ddx_talv_rec.attribute5;
    p6_a44 := ddx_talv_rec.attribute6;
    p6_a45 := ddx_talv_rec.attribute7;
    p6_a46 := ddx_talv_rec.attribute8;
    p6_a47 := ddx_talv_rec.attribute9;
    p6_a48 := ddx_talv_rec.attribute10;
    p6_a49 := ddx_talv_rec.attribute11;
    p6_a50 := ddx_talv_rec.attribute12;
    p6_a51 := ddx_talv_rec.attribute13;
    p6_a52 := ddx_talv_rec.attribute14;
    p6_a53 := ddx_talv_rec.attribute15;
    p6_a54 := rosetta_g_miss_num_map(ddx_talv_rec.created_by);
    p6_a55 := ddx_talv_rec.creation_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_talv_rec.last_updated_by);
    p6_a57 := ddx_talv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_talv_rec.last_update_login);
    p6_a59 := ddx_talv_rec.depreciate_yn;
    p6_a60 := rosetta_g_miss_num_map(ddx_talv_rec.hold_period_days);
    p6_a61 := rosetta_g_miss_num_map(ddx_talv_rec.old_salvage_value);
    p6_a62 := rosetta_g_miss_num_map(ddx_talv_rec.new_residual_value);
    p6_a63 := rosetta_g_miss_num_map(ddx_talv_rec.old_residual_value);
    p6_a64 := rosetta_g_miss_num_map(ddx_talv_rec.units_retired);
    p6_a65 := rosetta_g_miss_num_map(ddx_talv_rec.cost_retired);
    p6_a66 := rosetta_g_miss_num_map(ddx_talv_rec.sale_proceeds);
    p6_a67 := rosetta_g_miss_num_map(ddx_talv_rec.removal_cost);
    p6_a68 := rosetta_g_miss_num_map(ddx_talv_rec.dnz_asset_id);
    p6_a69 := ddx_talv_rec.date_due;
    p6_a70 := rosetta_g_miss_num_map(ddx_talv_rec.rep_asset_id);
    p6_a71 := rosetta_g_miss_num_map(ddx_talv_rec.lke_asset_id);
    p6_a72 := rosetta_g_miss_num_map(ddx_talv_rec.match_amount);
    p6_a73 := ddx_talv_rec.split_into_singles_flag;
    p6_a74 := rosetta_g_miss_num_map(ddx_talv_rec.split_into_units);
    p6_a75 := ddx_talv_rec.currency_code;
    p6_a76 := ddx_talv_rec.currency_conversion_type;
    p6_a77 := rosetta_g_miss_num_map(ddx_talv_rec.currency_conversion_rate);
    p6_a78 := ddx_talv_rec.currency_conversion_date;
    p6_a79 := rosetta_g_miss_num_map(ddx_talv_rec.residual_shr_party_id);
    p6_a80 := rosetta_g_miss_num_map(ddx_talv_rec.residual_shr_amount);
    p6_a81 := rosetta_g_miss_num_map(ddx_talv_rec.retirement_id);
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
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
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
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_DATE_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_talv_tbl okl_tal_pvt.talv_tbl_type;
    ddx_talv_tbl okl_tal_pvt.talv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_talv_tbl, p5_a0
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
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_tbl,
      ddx_talv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tal_pvt_w.rosetta_table_copy_out_p8(ddx_talv_tbl, p6_a0
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
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
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
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
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
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_talv_rec okl_tal_pvt.talv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_talv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_talv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_talv_rec.sfwt_flag := p5_a2;
    ddp_talv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_talv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_talv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_talv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_talv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_talv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_talv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_talv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_talv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_talv_rec.tal_type := p5_a12;
    ddp_talv_rec.asset_number := p5_a13;
    ddp_talv_rec.description := p5_a14;
    ddp_talv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_talv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_talv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_talv_rec.manufacturer_name := p5_a18;
    ddp_talv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_talv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_talv_rec.used_asset_yn := p5_a21;
    ddp_talv_rec.tag_number := p5_a22;
    ddp_talv_rec.model_number := p5_a23;
    ddp_talv_rec.corporate_book := p5_a24;
    ddp_talv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_talv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_talv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_talv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_talv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_talv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_talv_rec.deprn_method := p5_a31;
    ddp_talv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_talv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_talv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_talv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_talv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_talv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_talv_rec.attribute_category := p5_a38;
    ddp_talv_rec.attribute1 := p5_a39;
    ddp_talv_rec.attribute2 := p5_a40;
    ddp_talv_rec.attribute3 := p5_a41;
    ddp_talv_rec.attribute4 := p5_a42;
    ddp_talv_rec.attribute5 := p5_a43;
    ddp_talv_rec.attribute6 := p5_a44;
    ddp_talv_rec.attribute7 := p5_a45;
    ddp_talv_rec.attribute8 := p5_a46;
    ddp_talv_rec.attribute9 := p5_a47;
    ddp_talv_rec.attribute10 := p5_a48;
    ddp_talv_rec.attribute11 := p5_a49;
    ddp_talv_rec.attribute12 := p5_a50;
    ddp_talv_rec.attribute13 := p5_a51;
    ddp_talv_rec.attribute14 := p5_a52;
    ddp_talv_rec.attribute15 := p5_a53;
    ddp_talv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_talv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_talv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_talv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_talv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_talv_rec.depreciate_yn := p5_a59;
    ddp_talv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_talv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_talv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_talv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_talv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_talv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_talv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_talv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_talv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_talv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_talv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_talv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_talv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_talv_rec.split_into_singles_flag := p5_a73;
    ddp_talv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_talv_rec.currency_code := p5_a75;
    ddp_talv_rec.currency_conversion_type := p5_a76;
    ddp_talv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_talv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_talv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_talv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_talv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);

    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_rec);

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
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
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
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
  )

  as
    ddp_talv_tbl okl_tal_pvt.talv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_talv_tbl, p5_a0
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
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_tbl);

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
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
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
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  NUMBER := 0-1962.0724
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  DATE := fnd_api.g_miss_date
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  NUMBER := 0-1962.0724
  )

  as
    ddp_talv_rec okl_tal_pvt.talv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_talv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_talv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_talv_rec.sfwt_flag := p5_a2;
    ddp_talv_rec.tas_id := rosetta_g_miss_num_map(p5_a3);
    ddp_talv_rec.ilo_id := rosetta_g_miss_num_map(p5_a4);
    ddp_talv_rec.ilo_id_old := rosetta_g_miss_num_map(p5_a5);
    ddp_talv_rec.iay_id := rosetta_g_miss_num_map(p5_a6);
    ddp_talv_rec.iay_id_new := rosetta_g_miss_num_map(p5_a7);
    ddp_talv_rec.kle_id := rosetta_g_miss_num_map(p5_a8);
    ddp_talv_rec.dnz_khr_id := rosetta_g_miss_num_map(p5_a9);
    ddp_talv_rec.line_number := rosetta_g_miss_num_map(p5_a10);
    ddp_talv_rec.org_id := rosetta_g_miss_num_map(p5_a11);
    ddp_talv_rec.tal_type := p5_a12;
    ddp_talv_rec.asset_number := p5_a13;
    ddp_talv_rec.description := p5_a14;
    ddp_talv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a15);
    ddp_talv_rec.original_cost := rosetta_g_miss_num_map(p5_a16);
    ddp_talv_rec.current_units := rosetta_g_miss_num_map(p5_a17);
    ddp_talv_rec.manufacturer_name := p5_a18;
    ddp_talv_rec.year_manufactured := rosetta_g_miss_num_map(p5_a19);
    ddp_talv_rec.supplier_id := rosetta_g_miss_num_map(p5_a20);
    ddp_talv_rec.used_asset_yn := p5_a21;
    ddp_talv_rec.tag_number := p5_a22;
    ddp_talv_rec.model_number := p5_a23;
    ddp_talv_rec.corporate_book := p5_a24;
    ddp_talv_rec.date_purchased := rosetta_g_miss_date_in_map(p5_a25);
    ddp_talv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a26);
    ddp_talv_rec.in_service_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_talv_rec.life_in_months := rosetta_g_miss_num_map(p5_a28);
    ddp_talv_rec.depreciation_id := rosetta_g_miss_num_map(p5_a29);
    ddp_talv_rec.depreciation_cost := rosetta_g_miss_num_map(p5_a30);
    ddp_talv_rec.deprn_method := p5_a31;
    ddp_talv_rec.deprn_rate := rosetta_g_miss_num_map(p5_a32);
    ddp_talv_rec.salvage_value := rosetta_g_miss_num_map(p5_a33);
    ddp_talv_rec.percent_salvage_value := rosetta_g_miss_num_map(p5_a34);
    ddp_talv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a35);
    ddp_talv_rec.fa_trx_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_talv_rec.fa_cost := rosetta_g_miss_num_map(p5_a37);
    ddp_talv_rec.attribute_category := p5_a38;
    ddp_talv_rec.attribute1 := p5_a39;
    ddp_talv_rec.attribute2 := p5_a40;
    ddp_talv_rec.attribute3 := p5_a41;
    ddp_talv_rec.attribute4 := p5_a42;
    ddp_talv_rec.attribute5 := p5_a43;
    ddp_talv_rec.attribute6 := p5_a44;
    ddp_talv_rec.attribute7 := p5_a45;
    ddp_talv_rec.attribute8 := p5_a46;
    ddp_talv_rec.attribute9 := p5_a47;
    ddp_talv_rec.attribute10 := p5_a48;
    ddp_talv_rec.attribute11 := p5_a49;
    ddp_talv_rec.attribute12 := p5_a50;
    ddp_talv_rec.attribute13 := p5_a51;
    ddp_talv_rec.attribute14 := p5_a52;
    ddp_talv_rec.attribute15 := p5_a53;
    ddp_talv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_talv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_talv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_talv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_talv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_talv_rec.depreciate_yn := p5_a59;
    ddp_talv_rec.hold_period_days := rosetta_g_miss_num_map(p5_a60);
    ddp_talv_rec.old_salvage_value := rosetta_g_miss_num_map(p5_a61);
    ddp_talv_rec.new_residual_value := rosetta_g_miss_num_map(p5_a62);
    ddp_talv_rec.old_residual_value := rosetta_g_miss_num_map(p5_a63);
    ddp_talv_rec.units_retired := rosetta_g_miss_num_map(p5_a64);
    ddp_talv_rec.cost_retired := rosetta_g_miss_num_map(p5_a65);
    ddp_talv_rec.sale_proceeds := rosetta_g_miss_num_map(p5_a66);
    ddp_talv_rec.removal_cost := rosetta_g_miss_num_map(p5_a67);
    ddp_talv_rec.dnz_asset_id := rosetta_g_miss_num_map(p5_a68);
    ddp_talv_rec.date_due := rosetta_g_miss_date_in_map(p5_a69);
    ddp_talv_rec.rep_asset_id := rosetta_g_miss_num_map(p5_a70);
    ddp_talv_rec.lke_asset_id := rosetta_g_miss_num_map(p5_a71);
    ddp_talv_rec.match_amount := rosetta_g_miss_num_map(p5_a72);
    ddp_talv_rec.split_into_singles_flag := p5_a73;
    ddp_talv_rec.split_into_units := rosetta_g_miss_num_map(p5_a74);
    ddp_talv_rec.currency_code := p5_a75;
    ddp_talv_rec.currency_conversion_type := p5_a76;
    ddp_talv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_talv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_talv_rec.residual_shr_party_id := rosetta_g_miss_num_map(p5_a79);
    ddp_talv_rec.residual_shr_amount := rosetta_g_miss_num_map(p5_a80);
    ddp_talv_rec.retirement_id := rosetta_g_miss_num_map(p5_a81);

    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_rec);

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
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_400
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
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
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_NUMBER_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_NUMBER_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_NUMBER_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_DATE_TABLE
    , p5_a70 JTF_NUMBER_TABLE
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_NUMBER_TABLE
  )

  as
    ddp_talv_tbl okl_tal_pvt.talv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tal_pvt_w.rosetta_table_copy_in_p8(ddp_talv_tbl, p5_a0
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
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tal_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_talv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_tal_pvt_w;

/
