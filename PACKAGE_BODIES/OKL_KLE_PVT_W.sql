--------------------------------------------------------
--  DDL for Package Body OKL_KLE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_KLE_PVT_W" as
  /* $Header: OKLIKLEB.pls 115.6 2002/12/20 19:18:13 avsingh noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_kle_pvt.kle_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_500
    , a56 JTF_VARCHAR2_TABLE_500
    , a57 JTF_VARCHAR2_TABLE_500
    , a58 JTF_VARCHAR2_TABLE_500
    , a59 JTF_VARCHAR2_TABLE_500
    , a60 JTF_VARCHAR2_TABLE_500
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_VARCHAR2_TABLE_500
    , a63 JTF_VARCHAR2_TABLE_500
    , a64 JTF_VARCHAR2_TABLE_500
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_500
    , a67 JTF_VARCHAR2_TABLE_500
    , a68 JTF_VARCHAR2_TABLE_500
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_DATE_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_DATE_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_DATE_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_NUMBER_TABLE
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_NUMBER_TABLE
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
          t(ddindx).sty_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).lao_amount := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).fee_charge := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).title_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).date_residual_last_review := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).date_last_reamortisation := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).termination_purchase_amount := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).date_last_cleanup := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).remarketed_amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).date_remarketed := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).remarket_margin := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).repurchased_amount := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).date_repurchased := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).gain_loss := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).floor_amount := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).previous_contract := a18(indx);
          t(ddindx).tracked_residual := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).date_title_received := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).estimated_oec := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).residual_percentage := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).capital_reduction := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).vendor_advance_paid := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).tradein_amount := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).delivered_date := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).year_of_manufacture := a27(indx);
          t(ddindx).initial_direct_cost := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).occupancy := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).date_last_inspection := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).date_next_inspection_due := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).weighted_average_life := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).bond_equivalent_yield := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).refinance_amount := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).year_built := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).coverage_ratio := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).gross_square_footage := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).net_rentable := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).date_letter_acceptance := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).date_commitment_expiration := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).date_appraisal := rosetta_g_miss_date_in_map(a41(indx));
          t(ddindx).appraisal_value := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).residual_value := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).coverage := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).lrv_amount := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).lrs_percent := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).evergreen_percent := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).percent_stake := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).amount_stake := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).date_sold := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).sty_id_for := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).attribute_category := a54(indx);
          t(ddindx).attribute1 := a55(indx);
          t(ddindx).attribute2 := a56(indx);
          t(ddindx).attribute3 := a57(indx);
          t(ddindx).attribute4 := a58(indx);
          t(ddindx).attribute5 := a59(indx);
          t(ddindx).attribute6 := a60(indx);
          t(ddindx).attribute7 := a61(indx);
          t(ddindx).attribute8 := a62(indx);
          t(ddindx).attribute9 := a63(indx);
          t(ddindx).attribute10 := a64(indx);
          t(ddindx).attribute11 := a65(indx);
          t(ddindx).attribute12 := a66(indx);
          t(ddindx).attribute13 := a67(indx);
          t(ddindx).attribute14 := a68(indx);
          t(ddindx).attribute15 := a69(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a71(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a73(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).nty_code := a75(indx);
          t(ddindx).fcg_code := a76(indx);
          t(ddindx).prc_code := a77(indx);
          t(ddindx).re_lease_yn := a78(indx);
          t(ddindx).prescribed_asset_yn := a79(indx);
          t(ddindx).credit_tenant_yn := a80(indx);
          t(ddindx).secured_deal_yn := a81(indx);
          t(ddindx).clg_id := rosetta_g_miss_num_map(a82(indx));
          t(ddindx).date_funding := rosetta_g_miss_date_in_map(a83(indx));
          t(ddindx).date_funding_required := rosetta_g_miss_date_in_map(a84(indx));
          t(ddindx).date_accepted := rosetta_g_miss_date_in_map(a85(indx));
          t(ddindx).date_delivery_expected := rosetta_g_miss_date_in_map(a86(indx));
          t(ddindx).oec := rosetta_g_miss_num_map(a87(indx));
          t(ddindx).capital_amount := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).residual_grnty_amount := rosetta_g_miss_num_map(a89(indx));
          t(ddindx).residual_code := a90(indx);
          t(ddindx).rvi_premium := rosetta_g_miss_num_map(a91(indx));
          t(ddindx).credit_nature := a92(indx);
          t(ddindx).capitalized_interest := rosetta_g_miss_num_map(a93(indx));
          t(ddindx).capital_reduction_percent := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).date_pay_investor_start := rosetta_g_miss_date_in_map(a95(indx));
          t(ddindx).pay_investor_frequency := a96(indx);
          t(ddindx).pay_investor_event := a97(indx);
          t(ddindx).pay_investor_remittance_days := rosetta_g_miss_num_map(a98(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_kle_pvt.kle_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_500
    , a56 out nocopy JTF_VARCHAR2_TABLE_500
    , a57 out nocopy JTF_VARCHAR2_TABLE_500
    , a58 out nocopy JTF_VARCHAR2_TABLE_500
    , a59 out nocopy JTF_VARCHAR2_TABLE_500
    , a60 out nocopy JTF_VARCHAR2_TABLE_500
    , a61 out nocopy JTF_VARCHAR2_TABLE_500
    , a62 out nocopy JTF_VARCHAR2_TABLE_500
    , a63 out nocopy JTF_VARCHAR2_TABLE_500
    , a64 out nocopy JTF_VARCHAR2_TABLE_500
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_500
    , a67 out nocopy JTF_VARCHAR2_TABLE_500
    , a68 out nocopy JTF_VARCHAR2_TABLE_500
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_DATE_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_DATE_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_NUMBER_TABLE
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_NUMBER_TABLE
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
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_500();
    a56 := JTF_VARCHAR2_TABLE_500();
    a57 := JTF_VARCHAR2_TABLE_500();
    a58 := JTF_VARCHAR2_TABLE_500();
    a59 := JTF_VARCHAR2_TABLE_500();
    a60 := JTF_VARCHAR2_TABLE_500();
    a61 := JTF_VARCHAR2_TABLE_500();
    a62 := JTF_VARCHAR2_TABLE_500();
    a63 := JTF_VARCHAR2_TABLE_500();
    a64 := JTF_VARCHAR2_TABLE_500();
    a65 := JTF_VARCHAR2_TABLE_500();
    a66 := JTF_VARCHAR2_TABLE_500();
    a67 := JTF_VARCHAR2_TABLE_500();
    a68 := JTF_VARCHAR2_TABLE_500();
    a69 := JTF_VARCHAR2_TABLE_500();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_DATE_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_DATE_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_DATE_TABLE();
    a84 := JTF_DATE_TABLE();
    a85 := JTF_DATE_TABLE();
    a86 := JTF_DATE_TABLE();
    a87 := JTF_NUMBER_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_VARCHAR2_TABLE_100();
    a91 := JTF_NUMBER_TABLE();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_NUMBER_TABLE();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_DATE_TABLE();
    a96 := JTF_VARCHAR2_TABLE_100();
    a97 := JTF_VARCHAR2_TABLE_100();
    a98 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_500();
      a56 := JTF_VARCHAR2_TABLE_500();
      a57 := JTF_VARCHAR2_TABLE_500();
      a58 := JTF_VARCHAR2_TABLE_500();
      a59 := JTF_VARCHAR2_TABLE_500();
      a60 := JTF_VARCHAR2_TABLE_500();
      a61 := JTF_VARCHAR2_TABLE_500();
      a62 := JTF_VARCHAR2_TABLE_500();
      a63 := JTF_VARCHAR2_TABLE_500();
      a64 := JTF_VARCHAR2_TABLE_500();
      a65 := JTF_VARCHAR2_TABLE_500();
      a66 := JTF_VARCHAR2_TABLE_500();
      a67 := JTF_VARCHAR2_TABLE_500();
      a68 := JTF_VARCHAR2_TABLE_500();
      a69 := JTF_VARCHAR2_TABLE_500();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_DATE_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_DATE_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_DATE_TABLE();
      a84 := JTF_DATE_TABLE();
      a85 := JTF_DATE_TABLE();
      a86 := JTF_DATE_TABLE();
      a87 := JTF_NUMBER_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_VARCHAR2_TABLE_100();
      a91 := JTF_NUMBER_TABLE();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_NUMBER_TABLE();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_DATE_TABLE();
      a96 := JTF_VARCHAR2_TABLE_100();
      a97 := JTF_VARCHAR2_TABLE_100();
      a98 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).lao_amount);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).fee_charge);
          a6(indx) := t(ddindx).title_date;
          a7(indx) := t(ddindx).date_residual_last_review;
          a8(indx) := t(ddindx).date_last_reamortisation;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).termination_purchase_amount);
          a10(indx) := t(ddindx).date_last_cleanup;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).remarketed_amount);
          a12(indx) := t(ddindx).date_remarketed;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).remarket_margin);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).repurchased_amount);
          a15(indx) := t(ddindx).date_repurchased;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).gain_loss);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).floor_amount);
          a18(indx) := t(ddindx).previous_contract;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).tracked_residual);
          a20(indx) := t(ddindx).date_title_received;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).estimated_oec);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).residual_percentage);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).capital_reduction);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_advance_paid);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).tradein_amount);
          a26(indx) := t(ddindx).delivered_date;
          a27(indx) := t(ddindx).year_of_manufacture;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).initial_direct_cost);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).occupancy);
          a30(indx) := t(ddindx).date_last_inspection;
          a31(indx) := t(ddindx).date_next_inspection_due;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).weighted_average_life);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).bond_equivalent_yield);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).refinance_amount);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).year_built);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).coverage_ratio);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).gross_square_footage);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).net_rentable);
          a39(indx) := t(ddindx).date_letter_acceptance;
          a40(indx) := t(ddindx).date_commitment_expiration;
          a41(indx) := t(ddindx).date_appraisal;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).appraisal_value);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).residual_value);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).coverage);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).lrv_amount);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).lrs_percent);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).evergreen_percent);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).percent_stake);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).amount_stake);
          a52(indx) := t(ddindx).date_sold;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id_for);
          a54(indx) := t(ddindx).attribute_category;
          a55(indx) := t(ddindx).attribute1;
          a56(indx) := t(ddindx).attribute2;
          a57(indx) := t(ddindx).attribute3;
          a58(indx) := t(ddindx).attribute4;
          a59(indx) := t(ddindx).attribute5;
          a60(indx) := t(ddindx).attribute6;
          a61(indx) := t(ddindx).attribute7;
          a62(indx) := t(ddindx).attribute8;
          a63(indx) := t(ddindx).attribute9;
          a64(indx) := t(ddindx).attribute10;
          a65(indx) := t(ddindx).attribute11;
          a66(indx) := t(ddindx).attribute12;
          a67(indx) := t(ddindx).attribute13;
          a68(indx) := t(ddindx).attribute14;
          a69(indx) := t(ddindx).attribute15;
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a71(indx) := t(ddindx).creation_date;
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a73(indx) := t(ddindx).last_update_date;
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a75(indx) := t(ddindx).nty_code;
          a76(indx) := t(ddindx).fcg_code;
          a77(indx) := t(ddindx).prc_code;
          a78(indx) := t(ddindx).re_lease_yn;
          a79(indx) := t(ddindx).prescribed_asset_yn;
          a80(indx) := t(ddindx).credit_tenant_yn;
          a81(indx) := t(ddindx).secured_deal_yn;
          a82(indx) := rosetta_g_miss_num_map(t(ddindx).clg_id);
          a83(indx) := t(ddindx).date_funding;
          a84(indx) := t(ddindx).date_funding_required;
          a85(indx) := t(ddindx).date_accepted;
          a86(indx) := t(ddindx).date_delivery_expected;
          a87(indx) := rosetta_g_miss_num_map(t(ddindx).oec);
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).capital_amount);
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).residual_grnty_amount);
          a90(indx) := t(ddindx).residual_code;
          a91(indx) := rosetta_g_miss_num_map(t(ddindx).rvi_premium);
          a92(indx) := t(ddindx).credit_nature;
          a93(indx) := rosetta_g_miss_num_map(t(ddindx).capitalized_interest);
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).capital_reduction_percent);
          a95(indx) := t(ddindx).date_pay_investor_start;
          a96(indx) := t(ddindx).pay_investor_frequency;
          a97(indx) := t(ddindx).pay_investor_event;
          a98(indx) := rosetta_g_miss_num_map(t(ddindx).pay_investor_remittance_days);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_kle_pvt.okl_k_lines_h_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_500
    , a57 JTF_VARCHAR2_TABLE_500
    , a58 JTF_VARCHAR2_TABLE_500
    , a59 JTF_VARCHAR2_TABLE_500
    , a60 JTF_VARCHAR2_TABLE_500
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_VARCHAR2_TABLE_500
    , a63 JTF_VARCHAR2_TABLE_500
    , a64 JTF_VARCHAR2_TABLE_500
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_500
    , a67 JTF_VARCHAR2_TABLE_500
    , a68 JTF_VARCHAR2_TABLE_500
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_500
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_DATE_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_DATE_TABLE
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_DATE_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_NUMBER_TABLE
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_NUMBER_TABLE
    , a96 JTF_DATE_TABLE
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).major_version := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).lao_amount := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).fee_charge := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).title_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).date_residual_last_review := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).date_last_reamortisation := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).termination_purchase_amount := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).date_last_cleanup := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).remarketed_amount := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).date_remarketed := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).remarket_margin := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).repurchased_amount := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).date_repurchased := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).gain_loss := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).floor_amount := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).previous_contract := a19(indx);
          t(ddindx).tracked_residual := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).date_title_received := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).estimated_oec := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).residual_percentage := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).capital_reduction := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).vendor_advance_paid := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).tradein_amount := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).delivered_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).year_of_manufacture := a28(indx);
          t(ddindx).initial_direct_cost := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).occupancy := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).date_last_inspection := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).date_next_inspection_due := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).weighted_average_life := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).bond_equivalent_yield := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).refinance_amount := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).year_built := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).coverage_ratio := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).gross_square_footage := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).net_rentable := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).date_letter_acceptance := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).date_commitment_expiration := rosetta_g_miss_date_in_map(a41(indx));
          t(ddindx).date_appraisal := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).appraisal_value := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).residual_value := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).coverage := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).lrv_amount := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).lrs_percent := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).evergreen_percent := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).percent_stake := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).amount_stake := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).date_sold := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).sty_id_for := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).attribute_category := a55(indx);
          t(ddindx).attribute1 := a56(indx);
          t(ddindx).attribute2 := a57(indx);
          t(ddindx).attribute3 := a58(indx);
          t(ddindx).attribute4 := a59(indx);
          t(ddindx).attribute5 := a60(indx);
          t(ddindx).attribute6 := a61(indx);
          t(ddindx).attribute7 := a62(indx);
          t(ddindx).attribute8 := a63(indx);
          t(ddindx).attribute9 := a64(indx);
          t(ddindx).attribute10 := a65(indx);
          t(ddindx).attribute11 := a66(indx);
          t(ddindx).attribute12 := a67(indx);
          t(ddindx).attribute13 := a68(indx);
          t(ddindx).attribute14 := a69(indx);
          t(ddindx).attribute15 := a70(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a72(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a73(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a74(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a75(indx));
          t(ddindx).nty_code := a76(indx);
          t(ddindx).fcg_code := a77(indx);
          t(ddindx).prc_code := a78(indx);
          t(ddindx).re_lease_yn := a79(indx);
          t(ddindx).prescribed_asset_yn := a80(indx);
          t(ddindx).credit_tenant_yn := a81(indx);
          t(ddindx).secured_deal_yn := a82(indx);
          t(ddindx).clg_id := rosetta_g_miss_num_map(a83(indx));
          t(ddindx).date_funding := rosetta_g_miss_date_in_map(a84(indx));
          t(ddindx).date_funding_required := rosetta_g_miss_date_in_map(a85(indx));
          t(ddindx).date_accepted := rosetta_g_miss_date_in_map(a86(indx));
          t(ddindx).date_delivery_expected := rosetta_g_miss_date_in_map(a87(indx));
          t(ddindx).oec := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).capital_amount := rosetta_g_miss_num_map(a89(indx));
          t(ddindx).residual_grnty_amount := rosetta_g_miss_num_map(a90(indx));
          t(ddindx).residual_code := a91(indx);
          t(ddindx).rvi_premium := rosetta_g_miss_num_map(a92(indx));
          t(ddindx).credit_nature := a93(indx);
          t(ddindx).capitalized_interest := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).capital_reduction_percent := rosetta_g_miss_num_map(a95(indx));
          t(ddindx).date_pay_investor_start := rosetta_g_miss_date_in_map(a96(indx));
          t(ddindx).pay_investor_frequency := a97(indx);
          t(ddindx).pay_investor_event := a98(indx);
          t(ddindx).pay_investor_remittance_days := rosetta_g_miss_num_map(a99(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_kle_pvt.okl_k_lines_h_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_500
    , a57 out nocopy JTF_VARCHAR2_TABLE_500
    , a58 out nocopy JTF_VARCHAR2_TABLE_500
    , a59 out nocopy JTF_VARCHAR2_TABLE_500
    , a60 out nocopy JTF_VARCHAR2_TABLE_500
    , a61 out nocopy JTF_VARCHAR2_TABLE_500
    , a62 out nocopy JTF_VARCHAR2_TABLE_500
    , a63 out nocopy JTF_VARCHAR2_TABLE_500
    , a64 out nocopy JTF_VARCHAR2_TABLE_500
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_500
    , a67 out nocopy JTF_VARCHAR2_TABLE_500
    , a68 out nocopy JTF_VARCHAR2_TABLE_500
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_500
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_DATE_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_DATE_TABLE
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_DATE_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_VARCHAR2_TABLE_100
    , a92 out nocopy JTF_NUMBER_TABLE
    , a93 out nocopy JTF_VARCHAR2_TABLE_100
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_NUMBER_TABLE
    , a96 out nocopy JTF_DATE_TABLE
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
    , a99 out nocopy JTF_NUMBER_TABLE
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
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_500();
    a57 := JTF_VARCHAR2_TABLE_500();
    a58 := JTF_VARCHAR2_TABLE_500();
    a59 := JTF_VARCHAR2_TABLE_500();
    a60 := JTF_VARCHAR2_TABLE_500();
    a61 := JTF_VARCHAR2_TABLE_500();
    a62 := JTF_VARCHAR2_TABLE_500();
    a63 := JTF_VARCHAR2_TABLE_500();
    a64 := JTF_VARCHAR2_TABLE_500();
    a65 := JTF_VARCHAR2_TABLE_500();
    a66 := JTF_VARCHAR2_TABLE_500();
    a67 := JTF_VARCHAR2_TABLE_500();
    a68 := JTF_VARCHAR2_TABLE_500();
    a69 := JTF_VARCHAR2_TABLE_500();
    a70 := JTF_VARCHAR2_TABLE_500();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_DATE_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_DATE_TABLE();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_VARCHAR2_TABLE_100();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_VARCHAR2_TABLE_100();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_DATE_TABLE();
    a85 := JTF_DATE_TABLE();
    a86 := JTF_DATE_TABLE();
    a87 := JTF_DATE_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_NUMBER_TABLE();
    a91 := JTF_VARCHAR2_TABLE_100();
    a92 := JTF_NUMBER_TABLE();
    a93 := JTF_VARCHAR2_TABLE_100();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_NUMBER_TABLE();
    a96 := JTF_DATE_TABLE();
    a97 := JTF_VARCHAR2_TABLE_100();
    a98 := JTF_VARCHAR2_TABLE_100();
    a99 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_500();
      a57 := JTF_VARCHAR2_TABLE_500();
      a58 := JTF_VARCHAR2_TABLE_500();
      a59 := JTF_VARCHAR2_TABLE_500();
      a60 := JTF_VARCHAR2_TABLE_500();
      a61 := JTF_VARCHAR2_TABLE_500();
      a62 := JTF_VARCHAR2_TABLE_500();
      a63 := JTF_VARCHAR2_TABLE_500();
      a64 := JTF_VARCHAR2_TABLE_500();
      a65 := JTF_VARCHAR2_TABLE_500();
      a66 := JTF_VARCHAR2_TABLE_500();
      a67 := JTF_VARCHAR2_TABLE_500();
      a68 := JTF_VARCHAR2_TABLE_500();
      a69 := JTF_VARCHAR2_TABLE_500();
      a70 := JTF_VARCHAR2_TABLE_500();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_DATE_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_DATE_TABLE();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_VARCHAR2_TABLE_100();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_VARCHAR2_TABLE_100();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_DATE_TABLE();
      a85 := JTF_DATE_TABLE();
      a86 := JTF_DATE_TABLE();
      a87 := JTF_DATE_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_NUMBER_TABLE();
      a91 := JTF_VARCHAR2_TABLE_100();
      a92 := JTF_NUMBER_TABLE();
      a93 := JTF_VARCHAR2_TABLE_100();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_NUMBER_TABLE();
      a96 := JTF_DATE_TABLE();
      a97 := JTF_VARCHAR2_TABLE_100();
      a98 := JTF_VARCHAR2_TABLE_100();
      a99 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).major_version);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).lao_amount);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).fee_charge);
          a7(indx) := t(ddindx).title_date;
          a8(indx) := t(ddindx).date_residual_last_review;
          a9(indx) := t(ddindx).date_last_reamortisation;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).termination_purchase_amount);
          a11(indx) := t(ddindx).date_last_cleanup;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).remarketed_amount);
          a13(indx) := t(ddindx).date_remarketed;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).remarket_margin);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).repurchased_amount);
          a16(indx) := t(ddindx).date_repurchased;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).gain_loss);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).floor_amount);
          a19(indx) := t(ddindx).previous_contract;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).tracked_residual);
          a21(indx) := t(ddindx).date_title_received;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).estimated_oec);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).residual_percentage);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).capital_reduction);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_advance_paid);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).tradein_amount);
          a27(indx) := t(ddindx).delivered_date;
          a28(indx) := t(ddindx).year_of_manufacture;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).initial_direct_cost);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).occupancy);
          a31(indx) := t(ddindx).date_last_inspection;
          a32(indx) := t(ddindx).date_next_inspection_due;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).weighted_average_life);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).bond_equivalent_yield);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).refinance_amount);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).year_built);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).coverage_ratio);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).gross_square_footage);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).net_rentable);
          a40(indx) := t(ddindx).date_letter_acceptance;
          a41(indx) := t(ddindx).date_commitment_expiration;
          a42(indx) := t(ddindx).date_appraisal;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).appraisal_value);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).residual_value);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).coverage);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).lrv_amount);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).lrs_percent);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).evergreen_percent);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).percent_stake);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).amount_stake);
          a53(indx) := t(ddindx).date_sold;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id_for);
          a55(indx) := t(ddindx).attribute_category;
          a56(indx) := t(ddindx).attribute1;
          a57(indx) := t(ddindx).attribute2;
          a58(indx) := t(ddindx).attribute3;
          a59(indx) := t(ddindx).attribute4;
          a60(indx) := t(ddindx).attribute5;
          a61(indx) := t(ddindx).attribute6;
          a62(indx) := t(ddindx).attribute7;
          a63(indx) := t(ddindx).attribute8;
          a64(indx) := t(ddindx).attribute9;
          a65(indx) := t(ddindx).attribute10;
          a66(indx) := t(ddindx).attribute11;
          a67(indx) := t(ddindx).attribute12;
          a68(indx) := t(ddindx).attribute13;
          a69(indx) := t(ddindx).attribute14;
          a70(indx) := t(ddindx).attribute15;
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a72(indx) := t(ddindx).creation_date;
          a73(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a74(indx) := t(ddindx).last_update_date;
          a75(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a76(indx) := t(ddindx).nty_code;
          a77(indx) := t(ddindx).fcg_code;
          a78(indx) := t(ddindx).prc_code;
          a79(indx) := t(ddindx).re_lease_yn;
          a80(indx) := t(ddindx).prescribed_asset_yn;
          a81(indx) := t(ddindx).credit_tenant_yn;
          a82(indx) := t(ddindx).secured_deal_yn;
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).clg_id);
          a84(indx) := t(ddindx).date_funding;
          a85(indx) := t(ddindx).date_funding_required;
          a86(indx) := t(ddindx).date_accepted;
          a87(indx) := t(ddindx).date_delivery_expected;
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).oec);
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).capital_amount);
          a90(indx) := rosetta_g_miss_num_map(t(ddindx).residual_grnty_amount);
          a91(indx) := t(ddindx).residual_code;
          a92(indx) := rosetta_g_miss_num_map(t(ddindx).rvi_premium);
          a93(indx) := t(ddindx).credit_nature;
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).capitalized_interest);
          a95(indx) := rosetta_g_miss_num_map(t(ddindx).capital_reduction_percent);
          a96(indx) := t(ddindx).date_pay_investor_start;
          a97(indx) := t(ddindx).pay_investor_frequency;
          a98(indx) := t(ddindx).pay_investor_event;
          a99(indx) := rosetta_g_miss_num_map(t(ddindx).pay_investor_remittance_days);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_kle_pvt.klev_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_DATE_TABLE
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_DATE_TABLE
    , a49 JTF_DATE_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_DATE_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_VARCHAR2_TABLE_500
    , a63 JTF_VARCHAR2_TABLE_500
    , a64 JTF_VARCHAR2_TABLE_500
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_500
    , a67 JTF_VARCHAR2_TABLE_500
    , a68 JTF_VARCHAR2_TABLE_500
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_500
    , a71 JTF_VARCHAR2_TABLE_500
    , a72 JTF_VARCHAR2_TABLE_500
    , a73 JTF_VARCHAR2_TABLE_500
    , a74 JTF_VARCHAR2_TABLE_500
    , a75 JTF_VARCHAR2_TABLE_500
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_DATE_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_DATE_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_DATE_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_NUMBER_TABLE
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_NUMBER_TABLE
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
          t(ddindx).kle_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).prc_code := a4(indx);
          t(ddindx).fcg_code := a5(indx);
          t(ddindx).nty_code := a6(indx);
          t(ddindx).estimated_oec := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).lao_amount := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).title_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).fee_charge := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).lrs_percent := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).initial_direct_cost := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).percent_stake := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).percent := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).evergreen_percent := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).amount_stake := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).occupancy := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).coverage := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).residual_percentage := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).date_last_inspection := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).date_sold := rosetta_g_miss_date_in_map(a21(indx));
          t(ddindx).lrv_amount := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).capital_reduction := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).date_next_inspection_due := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).date_residual_last_review := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).date_last_reamortisation := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).vendor_advance_paid := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).weighted_average_life := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).tradein_amount := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).bond_equivalent_yield := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).termination_purchase_amount := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).refinance_amount := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).year_built := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).delivered_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).credit_tenant_yn := a35(indx);
          t(ddindx).date_last_cleanup := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).year_of_manufacture := a37(indx);
          t(ddindx).coverage_ratio := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).remarketed_amount := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).gross_square_footage := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).prescribed_asset_yn := a41(indx);
          t(ddindx).date_remarketed := rosetta_g_miss_date_in_map(a42(indx));
          t(ddindx).net_rentable := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).remarket_margin := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).date_letter_acceptance := rosetta_g_miss_date_in_map(a45(indx));
          t(ddindx).repurchased_amount := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).date_commitment_expiration := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).date_repurchased := rosetta_g_miss_date_in_map(a48(indx));
          t(ddindx).date_appraisal := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).residual_value := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).appraisal_value := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).secured_deal_yn := a52(indx);
          t(ddindx).gain_loss := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).floor_amount := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).re_lease_yn := a55(indx);
          t(ddindx).previous_contract := a56(indx);
          t(ddindx).tracked_residual := rosetta_g_miss_num_map(a57(indx));
          t(ddindx).date_title_received := rosetta_g_miss_date_in_map(a58(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a59(indx));
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
          t(ddindx).sty_id_for := rosetta_g_miss_num_map(a76(indx));
          t(ddindx).clg_id := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a78(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a79(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a81(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a82(indx));
          t(ddindx).date_funding := rosetta_g_miss_date_in_map(a83(indx));
          t(ddindx).date_funding_required := rosetta_g_miss_date_in_map(a84(indx));
          t(ddindx).date_accepted := rosetta_g_miss_date_in_map(a85(indx));
          t(ddindx).date_delivery_expected := rosetta_g_miss_date_in_map(a86(indx));
          t(ddindx).oec := rosetta_g_miss_num_map(a87(indx));
          t(ddindx).capital_amount := rosetta_g_miss_num_map(a88(indx));
          t(ddindx).residual_grnty_amount := rosetta_g_miss_num_map(a89(indx));
          t(ddindx).residual_code := a90(indx);
          t(ddindx).rvi_premium := rosetta_g_miss_num_map(a91(indx));
          t(ddindx).credit_nature := a92(indx);
          t(ddindx).capitalized_interest := rosetta_g_miss_num_map(a93(indx));
          t(ddindx).capital_reduction_percent := rosetta_g_miss_num_map(a94(indx));
          t(ddindx).date_pay_investor_start := rosetta_g_miss_date_in_map(a95(indx));
          t(ddindx).pay_investor_frequency := a96(indx);
          t(ddindx).pay_investor_event := a97(indx);
          t(ddindx).pay_investor_remittance_days := rosetta_g_miss_num_map(a98(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_kle_pvt.klev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_DATE_TABLE
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_DATE_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_500
    , a62 out nocopy JTF_VARCHAR2_TABLE_500
    , a63 out nocopy JTF_VARCHAR2_TABLE_500
    , a64 out nocopy JTF_VARCHAR2_TABLE_500
    , a65 out nocopy JTF_VARCHAR2_TABLE_500
    , a66 out nocopy JTF_VARCHAR2_TABLE_500
    , a67 out nocopy JTF_VARCHAR2_TABLE_500
    , a68 out nocopy JTF_VARCHAR2_TABLE_500
    , a69 out nocopy JTF_VARCHAR2_TABLE_500
    , a70 out nocopy JTF_VARCHAR2_TABLE_500
    , a71 out nocopy JTF_VARCHAR2_TABLE_500
    , a72 out nocopy JTF_VARCHAR2_TABLE_500
    , a73 out nocopy JTF_VARCHAR2_TABLE_500
    , a74 out nocopy JTF_VARCHAR2_TABLE_500
    , a75 out nocopy JTF_VARCHAR2_TABLE_500
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_DATE_TABLE
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_NUMBER_TABLE
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_DATE_TABLE();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_DATE_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_500();
    a62 := JTF_VARCHAR2_TABLE_500();
    a63 := JTF_VARCHAR2_TABLE_500();
    a64 := JTF_VARCHAR2_TABLE_500();
    a65 := JTF_VARCHAR2_TABLE_500();
    a66 := JTF_VARCHAR2_TABLE_500();
    a67 := JTF_VARCHAR2_TABLE_500();
    a68 := JTF_VARCHAR2_TABLE_500();
    a69 := JTF_VARCHAR2_TABLE_500();
    a70 := JTF_VARCHAR2_TABLE_500();
    a71 := JTF_VARCHAR2_TABLE_500();
    a72 := JTF_VARCHAR2_TABLE_500();
    a73 := JTF_VARCHAR2_TABLE_500();
    a74 := JTF_VARCHAR2_TABLE_500();
    a75 := JTF_VARCHAR2_TABLE_500();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_NUMBER_TABLE();
    a79 := JTF_DATE_TABLE();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_DATE_TABLE();
    a82 := JTF_NUMBER_TABLE();
    a83 := JTF_DATE_TABLE();
    a84 := JTF_DATE_TABLE();
    a85 := JTF_DATE_TABLE();
    a86 := JTF_DATE_TABLE();
    a87 := JTF_NUMBER_TABLE();
    a88 := JTF_NUMBER_TABLE();
    a89 := JTF_NUMBER_TABLE();
    a90 := JTF_VARCHAR2_TABLE_100();
    a91 := JTF_NUMBER_TABLE();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_NUMBER_TABLE();
    a94 := JTF_NUMBER_TABLE();
    a95 := JTF_DATE_TABLE();
    a96 := JTF_VARCHAR2_TABLE_100();
    a97 := JTF_VARCHAR2_TABLE_100();
    a98 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_DATE_TABLE();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_DATE_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_500();
      a62 := JTF_VARCHAR2_TABLE_500();
      a63 := JTF_VARCHAR2_TABLE_500();
      a64 := JTF_VARCHAR2_TABLE_500();
      a65 := JTF_VARCHAR2_TABLE_500();
      a66 := JTF_VARCHAR2_TABLE_500();
      a67 := JTF_VARCHAR2_TABLE_500();
      a68 := JTF_VARCHAR2_TABLE_500();
      a69 := JTF_VARCHAR2_TABLE_500();
      a70 := JTF_VARCHAR2_TABLE_500();
      a71 := JTF_VARCHAR2_TABLE_500();
      a72 := JTF_VARCHAR2_TABLE_500();
      a73 := JTF_VARCHAR2_TABLE_500();
      a74 := JTF_VARCHAR2_TABLE_500();
      a75 := JTF_VARCHAR2_TABLE_500();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_NUMBER_TABLE();
      a79 := JTF_DATE_TABLE();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_DATE_TABLE();
      a82 := JTF_NUMBER_TABLE();
      a83 := JTF_DATE_TABLE();
      a84 := JTF_DATE_TABLE();
      a85 := JTF_DATE_TABLE();
      a86 := JTF_DATE_TABLE();
      a87 := JTF_NUMBER_TABLE();
      a88 := JTF_NUMBER_TABLE();
      a89 := JTF_NUMBER_TABLE();
      a90 := JTF_VARCHAR2_TABLE_100();
      a91 := JTF_NUMBER_TABLE();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_NUMBER_TABLE();
      a94 := JTF_NUMBER_TABLE();
      a95 := JTF_DATE_TABLE();
      a96 := JTF_VARCHAR2_TABLE_100();
      a97 := JTF_VARCHAR2_TABLE_100();
      a98 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a4(indx) := t(ddindx).prc_code;
          a5(indx) := t(ddindx).fcg_code;
          a6(indx) := t(ddindx).nty_code;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).estimated_oec);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).lao_amount);
          a9(indx) := t(ddindx).title_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).fee_charge);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).lrs_percent);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).initial_direct_cost);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).percent_stake);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).percent);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).evergreen_percent);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).amount_stake);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).occupancy);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).coverage);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).residual_percentage);
          a20(indx) := t(ddindx).date_last_inspection;
          a21(indx) := t(ddindx).date_sold;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).lrv_amount);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).capital_reduction);
          a24(indx) := t(ddindx).date_next_inspection_due;
          a25(indx) := t(ddindx).date_residual_last_review;
          a26(indx) := t(ddindx).date_last_reamortisation;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_advance_paid);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).weighted_average_life);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).tradein_amount);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).bond_equivalent_yield);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).termination_purchase_amount);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).refinance_amount);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).year_built);
          a34(indx) := t(ddindx).delivered_date;
          a35(indx) := t(ddindx).credit_tenant_yn;
          a36(indx) := t(ddindx).date_last_cleanup;
          a37(indx) := t(ddindx).year_of_manufacture;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).coverage_ratio);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).remarketed_amount);
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).gross_square_footage);
          a41(indx) := t(ddindx).prescribed_asset_yn;
          a42(indx) := t(ddindx).date_remarketed;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).net_rentable);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).remarket_margin);
          a45(indx) := t(ddindx).date_letter_acceptance;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).repurchased_amount);
          a47(indx) := t(ddindx).date_commitment_expiration;
          a48(indx) := t(ddindx).date_repurchased;
          a49(indx) := t(ddindx).date_appraisal;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).residual_value);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).appraisal_value);
          a52(indx) := t(ddindx).secured_deal_yn;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).gain_loss);
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).floor_amount);
          a55(indx) := t(ddindx).re_lease_yn;
          a56(indx) := t(ddindx).previous_contract;
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).tracked_residual);
          a58(indx) := t(ddindx).date_title_received;
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
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
          a76(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id_for);
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).clg_id);
          a78(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a79(indx) := t(ddindx).creation_date;
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a81(indx) := t(ddindx).last_update_date;
          a82(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a83(indx) := t(ddindx).date_funding;
          a84(indx) := t(ddindx).date_funding_required;
          a85(indx) := t(ddindx).date_accepted;
          a86(indx) := t(ddindx).date_delivery_expected;
          a87(indx) := rosetta_g_miss_num_map(t(ddindx).oec);
          a88(indx) := rosetta_g_miss_num_map(t(ddindx).capital_amount);
          a89(indx) := rosetta_g_miss_num_map(t(ddindx).residual_grnty_amount);
          a90(indx) := t(ddindx).residual_code;
          a91(indx) := rosetta_g_miss_num_map(t(ddindx).rvi_premium);
          a92(indx) := t(ddindx).credit_nature;
          a93(indx) := rosetta_g_miss_num_map(t(ddindx).capitalized_interest);
          a94(indx) := rosetta_g_miss_num_map(t(ddindx).capital_reduction_percent);
          a95(indx) := t(ddindx).date_pay_investor_start;
          a96(indx) := t(ddindx).pay_investor_frequency;
          a97(indx) := t(ddindx).pay_investor_event;
          a98(indx) := rosetta_g_miss_num_map(t(ddindx).pay_investor_remittance_days);
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
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  NUMBER
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  NUMBER
    , p6_a79 out nocopy  DATE
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  DATE
    , p6_a82 out nocopy  NUMBER
    , p6_a83 out nocopy  DATE
    , p6_a84 out nocopy  DATE
    , p6_a85 out nocopy  DATE
    , p6_a86 out nocopy  DATE
    , p6_a87 out nocopy  NUMBER
    , p6_a88 out nocopy  NUMBER
    , p6_a89 out nocopy  NUMBER
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  NUMBER
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  NUMBER
    , p6_a94 out nocopy  NUMBER
    , p6_a95 out nocopy  DATE
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  )

  as
    ddp_klev_rec okl_kle_pvt.klev_rec_type;
    ddx_klev_rec okl_kle_pvt.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_klev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p5_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p5_a3);
    ddp_klev_rec.prc_code := p5_a4;
    ddp_klev_rec.fcg_code := p5_a5;
    ddp_klev_rec.nty_code := p5_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p5_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p5_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p5_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p5_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p5_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p5_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p5_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p5_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p5_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p5_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p5_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p5_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p5_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p5_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p5_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p5_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p5_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p5_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p5_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p5_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p5_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p5_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_klev_rec.credit_tenant_yn := p5_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p5_a36);
    ddp_klev_rec.year_of_manufacture := p5_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p5_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p5_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p5_a40);
    ddp_klev_rec.prescribed_asset_yn := p5_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p5_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p5_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p5_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p5_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p5_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p5_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p5_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p5_a51);
    ddp_klev_rec.secured_deal_yn := p5_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p5_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p5_a54);
    ddp_klev_rec.re_lease_yn := p5_a55;
    ddp_klev_rec.previous_contract := p5_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p5_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p5_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p5_a59);
    ddp_klev_rec.attribute_category := p5_a60;
    ddp_klev_rec.attribute1 := p5_a61;
    ddp_klev_rec.attribute2 := p5_a62;
    ddp_klev_rec.attribute3 := p5_a63;
    ddp_klev_rec.attribute4 := p5_a64;
    ddp_klev_rec.attribute5 := p5_a65;
    ddp_klev_rec.attribute6 := p5_a66;
    ddp_klev_rec.attribute7 := p5_a67;
    ddp_klev_rec.attribute8 := p5_a68;
    ddp_klev_rec.attribute9 := p5_a69;
    ddp_klev_rec.attribute10 := p5_a70;
    ddp_klev_rec.attribute11 := p5_a71;
    ddp_klev_rec.attribute12 := p5_a72;
    ddp_klev_rec.attribute13 := p5_a73;
    ddp_klev_rec.attribute14 := p5_a74;
    ddp_klev_rec.attribute15 := p5_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p5_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p5_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p5_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p5_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p5_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p5_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p5_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p5_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p5_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p5_a89);
    ddp_klev_rec.residual_code := p5_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p5_a91);
    ddp_klev_rec.credit_nature := p5_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p5_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p5_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p5_a95);
    ddp_klev_rec.pay_investor_frequency := p5_a96;
    ddp_klev_rec.pay_investor_event := p5_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p5_a98);


    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_rec,
      ddx_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_klev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_klev_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_klev_rec.kle_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id);
    p6_a4 := ddx_klev_rec.prc_code;
    p6_a5 := ddx_klev_rec.fcg_code;
    p6_a6 := ddx_klev_rec.nty_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_klev_rec.estimated_oec);
    p6_a8 := rosetta_g_miss_num_map(ddx_klev_rec.lao_amount);
    p6_a9 := ddx_klev_rec.title_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_klev_rec.fee_charge);
    p6_a11 := rosetta_g_miss_num_map(ddx_klev_rec.lrs_percent);
    p6_a12 := rosetta_g_miss_num_map(ddx_klev_rec.initial_direct_cost);
    p6_a13 := rosetta_g_miss_num_map(ddx_klev_rec.percent_stake);
    p6_a14 := rosetta_g_miss_num_map(ddx_klev_rec.percent);
    p6_a15 := rosetta_g_miss_num_map(ddx_klev_rec.evergreen_percent);
    p6_a16 := rosetta_g_miss_num_map(ddx_klev_rec.amount_stake);
    p6_a17 := rosetta_g_miss_num_map(ddx_klev_rec.occupancy);
    p6_a18 := rosetta_g_miss_num_map(ddx_klev_rec.coverage);
    p6_a19 := rosetta_g_miss_num_map(ddx_klev_rec.residual_percentage);
    p6_a20 := ddx_klev_rec.date_last_inspection;
    p6_a21 := ddx_klev_rec.date_sold;
    p6_a22 := rosetta_g_miss_num_map(ddx_klev_rec.lrv_amount);
    p6_a23 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction);
    p6_a24 := ddx_klev_rec.date_next_inspection_due;
    p6_a25 := ddx_klev_rec.date_residual_last_review;
    p6_a26 := ddx_klev_rec.date_last_reamortisation;
    p6_a27 := rosetta_g_miss_num_map(ddx_klev_rec.vendor_advance_paid);
    p6_a28 := rosetta_g_miss_num_map(ddx_klev_rec.weighted_average_life);
    p6_a29 := rosetta_g_miss_num_map(ddx_klev_rec.tradein_amount);
    p6_a30 := rosetta_g_miss_num_map(ddx_klev_rec.bond_equivalent_yield);
    p6_a31 := rosetta_g_miss_num_map(ddx_klev_rec.termination_purchase_amount);
    p6_a32 := rosetta_g_miss_num_map(ddx_klev_rec.refinance_amount);
    p6_a33 := rosetta_g_miss_num_map(ddx_klev_rec.year_built);
    p6_a34 := ddx_klev_rec.delivered_date;
    p6_a35 := ddx_klev_rec.credit_tenant_yn;
    p6_a36 := ddx_klev_rec.date_last_cleanup;
    p6_a37 := ddx_klev_rec.year_of_manufacture;
    p6_a38 := rosetta_g_miss_num_map(ddx_klev_rec.coverage_ratio);
    p6_a39 := rosetta_g_miss_num_map(ddx_klev_rec.remarketed_amount);
    p6_a40 := rosetta_g_miss_num_map(ddx_klev_rec.gross_square_footage);
    p6_a41 := ddx_klev_rec.prescribed_asset_yn;
    p6_a42 := ddx_klev_rec.date_remarketed;
    p6_a43 := rosetta_g_miss_num_map(ddx_klev_rec.net_rentable);
    p6_a44 := rosetta_g_miss_num_map(ddx_klev_rec.remarket_margin);
    p6_a45 := ddx_klev_rec.date_letter_acceptance;
    p6_a46 := rosetta_g_miss_num_map(ddx_klev_rec.repurchased_amount);
    p6_a47 := ddx_klev_rec.date_commitment_expiration;
    p6_a48 := ddx_klev_rec.date_repurchased;
    p6_a49 := ddx_klev_rec.date_appraisal;
    p6_a50 := rosetta_g_miss_num_map(ddx_klev_rec.residual_value);
    p6_a51 := rosetta_g_miss_num_map(ddx_klev_rec.appraisal_value);
    p6_a52 := ddx_klev_rec.secured_deal_yn;
    p6_a53 := rosetta_g_miss_num_map(ddx_klev_rec.gain_loss);
    p6_a54 := rosetta_g_miss_num_map(ddx_klev_rec.floor_amount);
    p6_a55 := ddx_klev_rec.re_lease_yn;
    p6_a56 := ddx_klev_rec.previous_contract;
    p6_a57 := rosetta_g_miss_num_map(ddx_klev_rec.tracked_residual);
    p6_a58 := ddx_klev_rec.date_title_received;
    p6_a59 := rosetta_g_miss_num_map(ddx_klev_rec.amount);
    p6_a60 := ddx_klev_rec.attribute_category;
    p6_a61 := ddx_klev_rec.attribute1;
    p6_a62 := ddx_klev_rec.attribute2;
    p6_a63 := ddx_klev_rec.attribute3;
    p6_a64 := ddx_klev_rec.attribute4;
    p6_a65 := ddx_klev_rec.attribute5;
    p6_a66 := ddx_klev_rec.attribute6;
    p6_a67 := ddx_klev_rec.attribute7;
    p6_a68 := ddx_klev_rec.attribute8;
    p6_a69 := ddx_klev_rec.attribute9;
    p6_a70 := ddx_klev_rec.attribute10;
    p6_a71 := ddx_klev_rec.attribute11;
    p6_a72 := ddx_klev_rec.attribute12;
    p6_a73 := ddx_klev_rec.attribute13;
    p6_a74 := ddx_klev_rec.attribute14;
    p6_a75 := ddx_klev_rec.attribute15;
    p6_a76 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id_for);
    p6_a77 := rosetta_g_miss_num_map(ddx_klev_rec.clg_id);
    p6_a78 := rosetta_g_miss_num_map(ddx_klev_rec.created_by);
    p6_a79 := ddx_klev_rec.creation_date;
    p6_a80 := rosetta_g_miss_num_map(ddx_klev_rec.last_updated_by);
    p6_a81 := ddx_klev_rec.last_update_date;
    p6_a82 := rosetta_g_miss_num_map(ddx_klev_rec.last_update_login);
    p6_a83 := ddx_klev_rec.date_funding;
    p6_a84 := ddx_klev_rec.date_funding_required;
    p6_a85 := ddx_klev_rec.date_accepted;
    p6_a86 := ddx_klev_rec.date_delivery_expected;
    p6_a87 := rosetta_g_miss_num_map(ddx_klev_rec.oec);
    p6_a88 := rosetta_g_miss_num_map(ddx_klev_rec.capital_amount);
    p6_a89 := rosetta_g_miss_num_map(ddx_klev_rec.residual_grnty_amount);
    p6_a90 := ddx_klev_rec.residual_code;
    p6_a91 := rosetta_g_miss_num_map(ddx_klev_rec.rvi_premium);
    p6_a92 := ddx_klev_rec.credit_nature;
    p6_a93 := rosetta_g_miss_num_map(ddx_klev_rec.capitalized_interest);
    p6_a94 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction_percent);
    p6_a95 := ddx_klev_rec.date_pay_investor_start;
    p6_a96 := ddx_klev_rec.pay_investor_frequency;
    p6_a97 := ddx_klev_rec.pay_investor_event;
    p6_a98 := rosetta_g_miss_num_map(ddx_klev_rec.pay_investor_remittance_days);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a76 out nocopy JTF_NUMBER_TABLE
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_NUMBER_TABLE
    , p6_a79 out nocopy JTF_DATE_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_DATE_TABLE
    , p6_a82 out nocopy JTF_NUMBER_TABLE
    , p6_a83 out nocopy JTF_DATE_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_DATE_TABLE
    , p6_a86 out nocopy JTF_DATE_TABLE
    , p6_a87 out nocopy JTF_NUMBER_TABLE
    , p6_a88 out nocopy JTF_NUMBER_TABLE
    , p6_a89 out nocopy JTF_NUMBER_TABLE
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_NUMBER_TABLE
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_NUMBER_TABLE
    , p6_a94 out nocopy JTF_NUMBER_TABLE
    , p6_a95 out nocopy JTF_DATE_TABLE
    , p6_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a98 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_klev_tbl okl_kle_pvt.klev_tbl_type;
    ddx_klev_tbl okl_kle_pvt.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p5_a0
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
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_tbl,
      ddx_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_klev_tbl, p6_a0
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
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  DATE
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  NUMBER
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  VARCHAR2
    , p6_a67 out nocopy  VARCHAR2
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  VARCHAR2
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  VARCHAR2
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  NUMBER
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  NUMBER
    , p6_a79 out nocopy  DATE
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  DATE
    , p6_a82 out nocopy  NUMBER
    , p6_a83 out nocopy  DATE
    , p6_a84 out nocopy  DATE
    , p6_a85 out nocopy  DATE
    , p6_a86 out nocopy  DATE
    , p6_a87 out nocopy  NUMBER
    , p6_a88 out nocopy  NUMBER
    , p6_a89 out nocopy  NUMBER
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  NUMBER
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  NUMBER
    , p6_a94 out nocopy  NUMBER
    , p6_a95 out nocopy  DATE
    , p6_a96 out nocopy  VARCHAR2
    , p6_a97 out nocopy  VARCHAR2
    , p6_a98 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  )

  as
    ddp_klev_rec okl_kle_pvt.klev_rec_type;
    ddx_klev_rec okl_kle_pvt.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_klev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p5_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p5_a3);
    ddp_klev_rec.prc_code := p5_a4;
    ddp_klev_rec.fcg_code := p5_a5;
    ddp_klev_rec.nty_code := p5_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p5_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p5_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p5_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p5_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p5_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p5_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p5_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p5_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p5_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p5_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p5_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p5_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p5_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p5_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p5_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p5_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p5_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p5_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p5_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p5_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p5_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p5_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_klev_rec.credit_tenant_yn := p5_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p5_a36);
    ddp_klev_rec.year_of_manufacture := p5_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p5_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p5_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p5_a40);
    ddp_klev_rec.prescribed_asset_yn := p5_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p5_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p5_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p5_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p5_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p5_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p5_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p5_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p5_a51);
    ddp_klev_rec.secured_deal_yn := p5_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p5_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p5_a54);
    ddp_klev_rec.re_lease_yn := p5_a55;
    ddp_klev_rec.previous_contract := p5_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p5_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p5_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p5_a59);
    ddp_klev_rec.attribute_category := p5_a60;
    ddp_klev_rec.attribute1 := p5_a61;
    ddp_klev_rec.attribute2 := p5_a62;
    ddp_klev_rec.attribute3 := p5_a63;
    ddp_klev_rec.attribute4 := p5_a64;
    ddp_klev_rec.attribute5 := p5_a65;
    ddp_klev_rec.attribute6 := p5_a66;
    ddp_klev_rec.attribute7 := p5_a67;
    ddp_klev_rec.attribute8 := p5_a68;
    ddp_klev_rec.attribute9 := p5_a69;
    ddp_klev_rec.attribute10 := p5_a70;
    ddp_klev_rec.attribute11 := p5_a71;
    ddp_klev_rec.attribute12 := p5_a72;
    ddp_klev_rec.attribute13 := p5_a73;
    ddp_klev_rec.attribute14 := p5_a74;
    ddp_klev_rec.attribute15 := p5_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p5_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p5_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p5_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p5_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p5_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p5_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p5_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p5_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p5_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p5_a89);
    ddp_klev_rec.residual_code := p5_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p5_a91);
    ddp_klev_rec.credit_nature := p5_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p5_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p5_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p5_a95);
    ddp_klev_rec.pay_investor_frequency := p5_a96;
    ddp_klev_rec.pay_investor_event := p5_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p5_a98);


    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_rec,
      ddx_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_klev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_klev_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_klev_rec.kle_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id);
    p6_a4 := ddx_klev_rec.prc_code;
    p6_a5 := ddx_klev_rec.fcg_code;
    p6_a6 := ddx_klev_rec.nty_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_klev_rec.estimated_oec);
    p6_a8 := rosetta_g_miss_num_map(ddx_klev_rec.lao_amount);
    p6_a9 := ddx_klev_rec.title_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_klev_rec.fee_charge);
    p6_a11 := rosetta_g_miss_num_map(ddx_klev_rec.lrs_percent);
    p6_a12 := rosetta_g_miss_num_map(ddx_klev_rec.initial_direct_cost);
    p6_a13 := rosetta_g_miss_num_map(ddx_klev_rec.percent_stake);
    p6_a14 := rosetta_g_miss_num_map(ddx_klev_rec.percent);
    p6_a15 := rosetta_g_miss_num_map(ddx_klev_rec.evergreen_percent);
    p6_a16 := rosetta_g_miss_num_map(ddx_klev_rec.amount_stake);
    p6_a17 := rosetta_g_miss_num_map(ddx_klev_rec.occupancy);
    p6_a18 := rosetta_g_miss_num_map(ddx_klev_rec.coverage);
    p6_a19 := rosetta_g_miss_num_map(ddx_klev_rec.residual_percentage);
    p6_a20 := ddx_klev_rec.date_last_inspection;
    p6_a21 := ddx_klev_rec.date_sold;
    p6_a22 := rosetta_g_miss_num_map(ddx_klev_rec.lrv_amount);
    p6_a23 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction);
    p6_a24 := ddx_klev_rec.date_next_inspection_due;
    p6_a25 := ddx_klev_rec.date_residual_last_review;
    p6_a26 := ddx_klev_rec.date_last_reamortisation;
    p6_a27 := rosetta_g_miss_num_map(ddx_klev_rec.vendor_advance_paid);
    p6_a28 := rosetta_g_miss_num_map(ddx_klev_rec.weighted_average_life);
    p6_a29 := rosetta_g_miss_num_map(ddx_klev_rec.tradein_amount);
    p6_a30 := rosetta_g_miss_num_map(ddx_klev_rec.bond_equivalent_yield);
    p6_a31 := rosetta_g_miss_num_map(ddx_klev_rec.termination_purchase_amount);
    p6_a32 := rosetta_g_miss_num_map(ddx_klev_rec.refinance_amount);
    p6_a33 := rosetta_g_miss_num_map(ddx_klev_rec.year_built);
    p6_a34 := ddx_klev_rec.delivered_date;
    p6_a35 := ddx_klev_rec.credit_tenant_yn;
    p6_a36 := ddx_klev_rec.date_last_cleanup;
    p6_a37 := ddx_klev_rec.year_of_manufacture;
    p6_a38 := rosetta_g_miss_num_map(ddx_klev_rec.coverage_ratio);
    p6_a39 := rosetta_g_miss_num_map(ddx_klev_rec.remarketed_amount);
    p6_a40 := rosetta_g_miss_num_map(ddx_klev_rec.gross_square_footage);
    p6_a41 := ddx_klev_rec.prescribed_asset_yn;
    p6_a42 := ddx_klev_rec.date_remarketed;
    p6_a43 := rosetta_g_miss_num_map(ddx_klev_rec.net_rentable);
    p6_a44 := rosetta_g_miss_num_map(ddx_klev_rec.remarket_margin);
    p6_a45 := ddx_klev_rec.date_letter_acceptance;
    p6_a46 := rosetta_g_miss_num_map(ddx_klev_rec.repurchased_amount);
    p6_a47 := ddx_klev_rec.date_commitment_expiration;
    p6_a48 := ddx_klev_rec.date_repurchased;
    p6_a49 := ddx_klev_rec.date_appraisal;
    p6_a50 := rosetta_g_miss_num_map(ddx_klev_rec.residual_value);
    p6_a51 := rosetta_g_miss_num_map(ddx_klev_rec.appraisal_value);
    p6_a52 := ddx_klev_rec.secured_deal_yn;
    p6_a53 := rosetta_g_miss_num_map(ddx_klev_rec.gain_loss);
    p6_a54 := rosetta_g_miss_num_map(ddx_klev_rec.floor_amount);
    p6_a55 := ddx_klev_rec.re_lease_yn;
    p6_a56 := ddx_klev_rec.previous_contract;
    p6_a57 := rosetta_g_miss_num_map(ddx_klev_rec.tracked_residual);
    p6_a58 := ddx_klev_rec.date_title_received;
    p6_a59 := rosetta_g_miss_num_map(ddx_klev_rec.amount);
    p6_a60 := ddx_klev_rec.attribute_category;
    p6_a61 := ddx_klev_rec.attribute1;
    p6_a62 := ddx_klev_rec.attribute2;
    p6_a63 := ddx_klev_rec.attribute3;
    p6_a64 := ddx_klev_rec.attribute4;
    p6_a65 := ddx_klev_rec.attribute5;
    p6_a66 := ddx_klev_rec.attribute6;
    p6_a67 := ddx_klev_rec.attribute7;
    p6_a68 := ddx_klev_rec.attribute8;
    p6_a69 := ddx_klev_rec.attribute9;
    p6_a70 := ddx_klev_rec.attribute10;
    p6_a71 := ddx_klev_rec.attribute11;
    p6_a72 := ddx_klev_rec.attribute12;
    p6_a73 := ddx_klev_rec.attribute13;
    p6_a74 := ddx_klev_rec.attribute14;
    p6_a75 := ddx_klev_rec.attribute15;
    p6_a76 := rosetta_g_miss_num_map(ddx_klev_rec.sty_id_for);
    p6_a77 := rosetta_g_miss_num_map(ddx_klev_rec.clg_id);
    p6_a78 := rosetta_g_miss_num_map(ddx_klev_rec.created_by);
    p6_a79 := ddx_klev_rec.creation_date;
    p6_a80 := rosetta_g_miss_num_map(ddx_klev_rec.last_updated_by);
    p6_a81 := ddx_klev_rec.last_update_date;
    p6_a82 := rosetta_g_miss_num_map(ddx_klev_rec.last_update_login);
    p6_a83 := ddx_klev_rec.date_funding;
    p6_a84 := ddx_klev_rec.date_funding_required;
    p6_a85 := ddx_klev_rec.date_accepted;
    p6_a86 := ddx_klev_rec.date_delivery_expected;
    p6_a87 := rosetta_g_miss_num_map(ddx_klev_rec.oec);
    p6_a88 := rosetta_g_miss_num_map(ddx_klev_rec.capital_amount);
    p6_a89 := rosetta_g_miss_num_map(ddx_klev_rec.residual_grnty_amount);
    p6_a90 := ddx_klev_rec.residual_code;
    p6_a91 := rosetta_g_miss_num_map(ddx_klev_rec.rvi_premium);
    p6_a92 := ddx_klev_rec.credit_nature;
    p6_a93 := rosetta_g_miss_num_map(ddx_klev_rec.capitalized_interest);
    p6_a94 := rosetta_g_miss_num_map(ddx_klev_rec.capital_reduction_percent);
    p6_a95 := ddx_klev_rec.date_pay_investor_start;
    p6_a96 := ddx_klev_rec.pay_investor_frequency;
    p6_a97 := ddx_klev_rec.pay_investor_event;
    p6_a98 := rosetta_g_miss_num_map(ddx_klev_rec.pay_investor_remittance_days);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_DATE_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_NUMBER_TABLE
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a76 out nocopy JTF_NUMBER_TABLE
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_NUMBER_TABLE
    , p6_a79 out nocopy JTF_DATE_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_DATE_TABLE
    , p6_a82 out nocopy JTF_NUMBER_TABLE
    , p6_a83 out nocopy JTF_DATE_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_DATE_TABLE
    , p6_a86 out nocopy JTF_DATE_TABLE
    , p6_a87 out nocopy JTF_NUMBER_TABLE
    , p6_a88 out nocopy JTF_NUMBER_TABLE
    , p6_a89 out nocopy JTF_NUMBER_TABLE
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_NUMBER_TABLE
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_NUMBER_TABLE
    , p6_a94 out nocopy JTF_NUMBER_TABLE
    , p6_a95 out nocopy JTF_DATE_TABLE
    , p6_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a98 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_klev_tbl okl_kle_pvt.klev_tbl_type;
    ddx_klev_tbl okl_kle_pvt.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p5_a0
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
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_tbl,
      ddx_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_klev_tbl, p6_a0
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
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  )

  as
    ddp_klev_rec okl_kle_pvt.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_klev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p5_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p5_a3);
    ddp_klev_rec.prc_code := p5_a4;
    ddp_klev_rec.fcg_code := p5_a5;
    ddp_klev_rec.nty_code := p5_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p5_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p5_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p5_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p5_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p5_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p5_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p5_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p5_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p5_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p5_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p5_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p5_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p5_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p5_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p5_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p5_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p5_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p5_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p5_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p5_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p5_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p5_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_klev_rec.credit_tenant_yn := p5_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p5_a36);
    ddp_klev_rec.year_of_manufacture := p5_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p5_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p5_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p5_a40);
    ddp_klev_rec.prescribed_asset_yn := p5_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p5_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p5_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p5_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p5_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p5_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p5_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p5_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p5_a51);
    ddp_klev_rec.secured_deal_yn := p5_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p5_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p5_a54);
    ddp_klev_rec.re_lease_yn := p5_a55;
    ddp_klev_rec.previous_contract := p5_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p5_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p5_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p5_a59);
    ddp_klev_rec.attribute_category := p5_a60;
    ddp_klev_rec.attribute1 := p5_a61;
    ddp_klev_rec.attribute2 := p5_a62;
    ddp_klev_rec.attribute3 := p5_a63;
    ddp_klev_rec.attribute4 := p5_a64;
    ddp_klev_rec.attribute5 := p5_a65;
    ddp_klev_rec.attribute6 := p5_a66;
    ddp_klev_rec.attribute7 := p5_a67;
    ddp_klev_rec.attribute8 := p5_a68;
    ddp_klev_rec.attribute9 := p5_a69;
    ddp_klev_rec.attribute10 := p5_a70;
    ddp_klev_rec.attribute11 := p5_a71;
    ddp_klev_rec.attribute12 := p5_a72;
    ddp_klev_rec.attribute13 := p5_a73;
    ddp_klev_rec.attribute14 := p5_a74;
    ddp_klev_rec.attribute15 := p5_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p5_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p5_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p5_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p5_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p5_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p5_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p5_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p5_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p5_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p5_a89);
    ddp_klev_rec.residual_code := p5_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p5_a91);
    ddp_klev_rec.credit_nature := p5_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p5_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p5_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p5_a95);
    ddp_klev_rec.pay_investor_frequency := p5_a96;
    ddp_klev_rec.pay_investor_event := p5_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p5_a98);

    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
  )

  as
    ddp_klev_tbl okl_kle_pvt.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p5_a0
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
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  )

  as
    ddp_klev_rec okl_kle_pvt.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_klev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p5_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p5_a3);
    ddp_klev_rec.prc_code := p5_a4;
    ddp_klev_rec.fcg_code := p5_a5;
    ddp_klev_rec.nty_code := p5_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p5_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p5_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p5_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p5_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p5_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p5_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p5_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p5_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p5_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p5_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p5_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p5_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p5_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p5_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p5_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p5_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p5_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p5_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p5_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p5_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p5_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p5_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_klev_rec.credit_tenant_yn := p5_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p5_a36);
    ddp_klev_rec.year_of_manufacture := p5_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p5_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p5_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p5_a40);
    ddp_klev_rec.prescribed_asset_yn := p5_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p5_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p5_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p5_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p5_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p5_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p5_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p5_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p5_a51);
    ddp_klev_rec.secured_deal_yn := p5_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p5_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p5_a54);
    ddp_klev_rec.re_lease_yn := p5_a55;
    ddp_klev_rec.previous_contract := p5_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p5_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p5_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p5_a59);
    ddp_klev_rec.attribute_category := p5_a60;
    ddp_klev_rec.attribute1 := p5_a61;
    ddp_klev_rec.attribute2 := p5_a62;
    ddp_klev_rec.attribute3 := p5_a63;
    ddp_klev_rec.attribute4 := p5_a64;
    ddp_klev_rec.attribute5 := p5_a65;
    ddp_klev_rec.attribute6 := p5_a66;
    ddp_klev_rec.attribute7 := p5_a67;
    ddp_klev_rec.attribute8 := p5_a68;
    ddp_klev_rec.attribute9 := p5_a69;
    ddp_klev_rec.attribute10 := p5_a70;
    ddp_klev_rec.attribute11 := p5_a71;
    ddp_klev_rec.attribute12 := p5_a72;
    ddp_klev_rec.attribute13 := p5_a73;
    ddp_klev_rec.attribute14 := p5_a74;
    ddp_klev_rec.attribute15 := p5_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p5_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p5_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p5_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p5_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p5_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p5_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p5_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p5_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p5_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p5_a89);
    ddp_klev_rec.residual_code := p5_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p5_a91);
    ddp_klev_rec.credit_nature := p5_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p5_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p5_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p5_a95);
    ddp_klev_rec.pay_investor_frequency := p5_a96;
    ddp_klev_rec.pay_investor_event := p5_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p5_a98);

    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
  )

  as
    ddp_klev_tbl okl_kle_pvt.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p5_a0
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
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  DATE := fnd_api.g_miss_date
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  NUMBER := 0-1962.0724
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  NUMBER := 0-1962.0724
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  NUMBER := 0-1962.0724
    , p5_a79  DATE := fnd_api.g_miss_date
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  DATE := fnd_api.g_miss_date
    , p5_a82  NUMBER := 0-1962.0724
    , p5_a83  DATE := fnd_api.g_miss_date
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  DATE := fnd_api.g_miss_date
    , p5_a86  DATE := fnd_api.g_miss_date
    , p5_a87  NUMBER := 0-1962.0724
    , p5_a88  NUMBER := 0-1962.0724
    , p5_a89  NUMBER := 0-1962.0724
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  NUMBER := 0-1962.0724
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  NUMBER := 0-1962.0724
    , p5_a94  NUMBER := 0-1962.0724
    , p5_a95  DATE := fnd_api.g_miss_date
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  NUMBER := 0-1962.0724
  )

  as
    ddp_klev_rec okl_kle_pvt.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_klev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p5_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p5_a3);
    ddp_klev_rec.prc_code := p5_a4;
    ddp_klev_rec.fcg_code := p5_a5;
    ddp_klev_rec.nty_code := p5_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p5_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p5_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p5_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p5_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p5_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p5_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p5_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p5_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p5_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p5_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p5_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p5_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p5_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p5_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p5_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p5_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p5_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p5_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p5_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p5_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p5_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p5_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_klev_rec.credit_tenant_yn := p5_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p5_a36);
    ddp_klev_rec.year_of_manufacture := p5_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p5_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p5_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p5_a40);
    ddp_klev_rec.prescribed_asset_yn := p5_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p5_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p5_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p5_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p5_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p5_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p5_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p5_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p5_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p5_a51);
    ddp_klev_rec.secured_deal_yn := p5_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p5_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p5_a54);
    ddp_klev_rec.re_lease_yn := p5_a55;
    ddp_klev_rec.previous_contract := p5_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p5_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p5_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p5_a59);
    ddp_klev_rec.attribute_category := p5_a60;
    ddp_klev_rec.attribute1 := p5_a61;
    ddp_klev_rec.attribute2 := p5_a62;
    ddp_klev_rec.attribute3 := p5_a63;
    ddp_klev_rec.attribute4 := p5_a64;
    ddp_klev_rec.attribute5 := p5_a65;
    ddp_klev_rec.attribute6 := p5_a66;
    ddp_klev_rec.attribute7 := p5_a67;
    ddp_klev_rec.attribute8 := p5_a68;
    ddp_klev_rec.attribute9 := p5_a69;
    ddp_klev_rec.attribute10 := p5_a70;
    ddp_klev_rec.attribute11 := p5_a71;
    ddp_klev_rec.attribute12 := p5_a72;
    ddp_klev_rec.attribute13 := p5_a73;
    ddp_klev_rec.attribute14 := p5_a74;
    ddp_klev_rec.attribute15 := p5_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p5_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p5_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p5_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p5_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p5_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p5_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p5_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p5_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p5_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p5_a89);
    ddp_klev_rec.residual_code := p5_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p5_a91);
    ddp_klev_rec.credit_nature := p5_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p5_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p5_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p5_a95);
    ddp_klev_rec.pay_investor_frequency := p5_a96;
    ddp_klev_rec.pay_investor_event := p5_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p5_a98);

    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_DATE_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_500
    , p5_a62 JTF_VARCHAR2_TABLE_500
    , p5_a63 JTF_VARCHAR2_TABLE_500
    , p5_a64 JTF_VARCHAR2_TABLE_500
    , p5_a65 JTF_VARCHAR2_TABLE_500
    , p5_a66 JTF_VARCHAR2_TABLE_500
    , p5_a67 JTF_VARCHAR2_TABLE_500
    , p5_a68 JTF_VARCHAR2_TABLE_500
    , p5_a69 JTF_VARCHAR2_TABLE_500
    , p5_a70 JTF_VARCHAR2_TABLE_500
    , p5_a71 JTF_VARCHAR2_TABLE_500
    , p5_a72 JTF_VARCHAR2_TABLE_500
    , p5_a73 JTF_VARCHAR2_TABLE_500
    , p5_a74 JTF_VARCHAR2_TABLE_500
    , p5_a75 JTF_VARCHAR2_TABLE_500
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_NUMBER_TABLE
    , p5_a79 JTF_DATE_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_DATE_TABLE
    , p5_a82 JTF_NUMBER_TABLE
    , p5_a83 JTF_DATE_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_DATE_TABLE
    , p5_a86 JTF_DATE_TABLE
    , p5_a87 JTF_NUMBER_TABLE
    , p5_a88 JTF_NUMBER_TABLE
    , p5_a89 JTF_NUMBER_TABLE
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_NUMBER_TABLE
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_NUMBER_TABLE
    , p5_a94 JTF_NUMBER_TABLE
    , p5_a95 JTF_DATE_TABLE
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_NUMBER_TABLE
  )

  as
    ddp_klev_tbl okl_kle_pvt.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p5_a0
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
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_kle_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_kle_pvt_w;

/
