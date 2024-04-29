--------------------------------------------------------
--  DDL for Package Body OKL_TCN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TCN_PVT_W" as
  /* $Header: OKLITCNB.pls 120.10.12010000.6 2008/11/12 23:56:03 apaul ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_tcn_pvt.tcn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
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
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_2000
    , a58 JTF_DATE_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_DATE_TABLE
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_DATE_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_200
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_200
    , a89 JTF_VARCHAR2_TABLE_100
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).khr_id_new := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).pvn_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).rbr_code := a4(indx);
          t(ddindx).rpy_code := a5(indx);
          t(ddindx).rvn_code := a6(indx);
          t(ddindx).trn_code := a7(indx);
          t(ddindx).qte_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).aes_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).code_combination_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).tcn_type := a11(indx);
          t(ddindx).rjn_code := a12(indx);
          t(ddindx).party_rel_id1_old := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).party_rel_id2_old := a14(indx);
          t(ddindx).party_rel_id1_new := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).party_rel_id2_new := a16(indx);
          t(ddindx).complete_transfer_yn := a17(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).date_accrual := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).accrual_status_yn := a24(indx);
          t(ddindx).update_status_yn := a25(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).tax_deductible_local := a28(indx);
          t(ddindx).tax_deductible_corporate := a29(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).currency_code := a32(indx);
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).khr_id_old := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a36(indx));
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
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).try_id := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).tsu_code := a55(indx);
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).description := a57(indx);
          t(ddindx).date_transaction_occurred := rosetta_g_miss_date_in_map(a58(indx));
          t(ddindx).trx_number := a59(indx);
          t(ddindx).tmt_evergreen_yn := a60(indx);
          t(ddindx).tmt_close_balances_yn := a61(indx);
          t(ddindx).tmt_accounting_entries_yn := a62(indx);
          t(ddindx).tmt_cancel_insurance_yn := a63(indx);
          t(ddindx).tmt_asset_disposition_yn := a64(indx);
          t(ddindx).tmt_amortization_yn := a65(indx);
          t(ddindx).tmt_asset_return_yn := a66(indx);
          t(ddindx).tmt_contract_updated_yn := a67(indx);
          t(ddindx).tmt_recycle_yn := a68(indx);
          t(ddindx).tmt_validated_yn := a69(indx);
          t(ddindx).tmt_streams_updated_yn := a70(indx);
          t(ddindx).accrual_activity := a71(indx);
          t(ddindx).tmt_split_asset_yn := a72(indx);
          t(ddindx).tmt_generic_flag1_yn := a73(indx);
          t(ddindx).tmt_generic_flag2_yn := a74(indx);
          t(ddindx).tmt_generic_flag3_yn := a75(indx);
          t(ddindx).currency_conversion_type := a76(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a78(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).source_trx_id := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).source_trx_type := a81(indx);
          t(ddindx).canceled_date := rosetta_g_miss_date_in_map(a82(indx));
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a83(indx));
          t(ddindx).accrual_reversal_date := rosetta_g_miss_date_in_map(a84(indx));
          t(ddindx).accounting_reversal_yn := a85(indx);
          t(ddindx).product_name := a86(indx);
          t(ddindx).book_classification_code := a87(indx);
          t(ddindx).tax_owner_code := a88(indx);
          t(ddindx).tmt_status_code := a89(indx);
          t(ddindx).representation_name := a90(indx);
          t(ddindx).representation_code := a91(indx);
          t(ddindx).upgrade_status_flag := a92(indx);
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a93(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_tcn_pvt.tcn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
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
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , a58 out nocopy JTF_DATE_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_DATE_TABLE
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_DATE_TABLE
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_VARCHAR2_TABLE_200
    , a87 out nocopy JTF_VARCHAR2_TABLE_100
    , a88 out nocopy JTF_VARCHAR2_TABLE_200
    , a89 out nocopy JTF_VARCHAR2_TABLE_100
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_VARCHAR2_TABLE_100
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_DATE_TABLE
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
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
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_2000();
    a58 := JTF_DATE_TABLE();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_DATE_TABLE();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_DATE_TABLE();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_DATE_TABLE();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_200();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_VARCHAR2_TABLE_200();
    a89 := JTF_VARCHAR2_TABLE_100();
    a90 := JTF_VARCHAR2_TABLE_100();
    a91 := JTF_VARCHAR2_TABLE_100();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
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
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_2000();
      a58 := JTF_DATE_TABLE();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_DATE_TABLE();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_DATE_TABLE();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_DATE_TABLE();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_200();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_VARCHAR2_TABLE_200();
      a89 := JTF_VARCHAR2_TABLE_100();
      a90 := JTF_VARCHAR2_TABLE_100();
      a91 := JTF_VARCHAR2_TABLE_100();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id_new);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).pvn_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a4(indx) := t(ddindx).rbr_code;
          a5(indx) := t(ddindx).rpy_code;
          a6(indx) := t(ddindx).rvn_code;
          a7(indx) := t(ddindx).trn_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).aes_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).code_combination_id);
          a11(indx) := t(ddindx).tcn_type;
          a12(indx) := t(ddindx).rjn_code;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).party_rel_id1_old);
          a14(indx) := t(ddindx).party_rel_id2_old;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).party_rel_id1_new);
          a16(indx) := t(ddindx).party_rel_id2_new;
          a17(indx) := t(ddindx).complete_transfer_yn;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a20(indx) := t(ddindx).creation_date;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a22(indx) := t(ddindx).last_update_date;
          a23(indx) := t(ddindx).date_accrual;
          a24(indx) := t(ddindx).accrual_status_yn;
          a25(indx) := t(ddindx).update_status_yn;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a28(indx) := t(ddindx).tax_deductible_local;
          a29(indx) := t(ddindx).tax_deductible_corporate;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a32(indx) := t(ddindx).currency_code;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id_old);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a36(indx) := t(ddindx).program_update_date;
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
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).try_id);
          a55(indx) := t(ddindx).tsu_code;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a57(indx) := t(ddindx).description;
          a58(indx) := t(ddindx).date_transaction_occurred;
          a59(indx) := t(ddindx).trx_number;
          a60(indx) := t(ddindx).tmt_evergreen_yn;
          a61(indx) := t(ddindx).tmt_close_balances_yn;
          a62(indx) := t(ddindx).tmt_accounting_entries_yn;
          a63(indx) := t(ddindx).tmt_cancel_insurance_yn;
          a64(indx) := t(ddindx).tmt_asset_disposition_yn;
          a65(indx) := t(ddindx).tmt_amortization_yn;
          a66(indx) := t(ddindx).tmt_asset_return_yn;
          a67(indx) := t(ddindx).tmt_contract_updated_yn;
          a68(indx) := t(ddindx).tmt_recycle_yn;
          a69(indx) := t(ddindx).tmt_validated_yn;
          a70(indx) := t(ddindx).tmt_streams_updated_yn;
          a71(indx) := t(ddindx).accrual_activity;
          a72(indx) := t(ddindx).tmt_split_asset_yn;
          a73(indx) := t(ddindx).tmt_generic_flag1_yn;
          a74(indx) := t(ddindx).tmt_generic_flag2_yn;
          a75(indx) := t(ddindx).tmt_generic_flag3_yn;
          a76(indx) := t(ddindx).currency_conversion_type;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a78(indx) := t(ddindx).currency_conversion_date;
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).source_trx_id);
          a81(indx) := t(ddindx).source_trx_type;
          a82(indx) := t(ddindx).canceled_date;
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          a84(indx) := t(ddindx).accrual_reversal_date;
          a85(indx) := t(ddindx).accounting_reversal_yn;
          a86(indx) := t(ddindx).product_name;
          a87(indx) := t(ddindx).book_classification_code;
          a88(indx) := t(ddindx).tax_owner_code;
          a89(indx) := t(ddindx).tmt_status_code;
          a90(indx) := t(ddindx).representation_name;
          a91(indx) := t(ddindx).representation_code;
          a92(indx) := t(ddindx).upgrade_status_flag;
          a93(indx) := t(ddindx).transaction_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_tcn_pvt.tcnv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_100
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
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_VARCHAR2_TABLE_500
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_DATE_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_DATE_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_2000
    , a58 JTF_DATE_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_DATE_TABLE
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_DATE_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_200
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_200
    , a89 JTF_VARCHAR2_TABLE_100
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_DATE_TABLE
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
          t(ddindx).rbr_code := a2(indx);
          t(ddindx).rpy_code := a3(indx);
          t(ddindx).rvn_code := a4(indx);
          t(ddindx).trn_code := a5(indx);
          t(ddindx).khr_id_new := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).pvn_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).qte_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).aes_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).code_combination_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).tax_deductible_local := a12(indx);
          t(ddindx).tax_deductible_corporate := a13(indx);
          t(ddindx).date_accrual := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).accrual_status_yn := a15(indx);
          t(ddindx).update_status_yn := a16(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).currency_code := a18(indx);
          t(ddindx).attribute_category := a19(indx);
          t(ddindx).attribute1 := a20(indx);
          t(ddindx).attribute2 := a21(indx);
          t(ddindx).attribute3 := a22(indx);
          t(ddindx).attribute4 := a23(indx);
          t(ddindx).attribute5 := a24(indx);
          t(ddindx).attribute6 := a25(indx);
          t(ddindx).attribute7 := a26(indx);
          t(ddindx).attribute8 := a27(indx);
          t(ddindx).attribute9 := a28(indx);
          t(ddindx).attribute10 := a29(indx);
          t(ddindx).attribute11 := a30(indx);
          t(ddindx).attribute12 := a31(indx);
          t(ddindx).attribute13 := a32(indx);
          t(ddindx).attribute14 := a33(indx);
          t(ddindx).attribute15 := a34(indx);
          t(ddindx).tcn_type := a35(indx);
          t(ddindx).rjn_code := a36(indx);
          t(ddindx).party_rel_id1_old := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).party_rel_id2_old := a38(indx);
          t(ddindx).party_rel_id1_new := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).party_rel_id2_new := a40(indx);
          t(ddindx).complete_transfer_yn := a41(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).khr_id_old := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a48(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a50(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).try_id := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).tsu_code := a55(indx);
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).description := a57(indx);
          t(ddindx).date_transaction_occurred := rosetta_g_miss_date_in_map(a58(indx));
          t(ddindx).trx_number := a59(indx);
          t(ddindx).tmt_evergreen_yn := a60(indx);
          t(ddindx).tmt_close_balances_yn := a61(indx);
          t(ddindx).tmt_accounting_entries_yn := a62(indx);
          t(ddindx).tmt_cancel_insurance_yn := a63(indx);
          t(ddindx).tmt_asset_disposition_yn := a64(indx);
          t(ddindx).tmt_amortization_yn := a65(indx);
          t(ddindx).tmt_asset_return_yn := a66(indx);
          t(ddindx).tmt_contract_updated_yn := a67(indx);
          t(ddindx).tmt_recycle_yn := a68(indx);
          t(ddindx).tmt_validated_yn := a69(indx);
          t(ddindx).tmt_streams_updated_yn := a70(indx);
          t(ddindx).accrual_activity := a71(indx);
          t(ddindx).tmt_split_asset_yn := a72(indx);
          t(ddindx).tmt_generic_flag1_yn := a73(indx);
          t(ddindx).tmt_generic_flag2_yn := a74(indx);
          t(ddindx).tmt_generic_flag3_yn := a75(indx);
          t(ddindx).currency_conversion_type := a76(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a78(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).source_trx_id := rosetta_g_miss_num_map(a80(indx));
          t(ddindx).source_trx_type := a81(indx);
          t(ddindx).canceled_date := rosetta_g_miss_date_in_map(a82(indx));
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a83(indx));
          t(ddindx).accrual_reversal_date := rosetta_g_miss_date_in_map(a84(indx));
          t(ddindx).accounting_reversal_yn := a85(indx);
          t(ddindx).product_name := a86(indx);
          t(ddindx).book_classification_code := a87(indx);
          t(ddindx).tax_owner_code := a88(indx);
          t(ddindx).tmt_status_code := a89(indx);
          t(ddindx).representation_name := a90(indx);
          t(ddindx).representation_code := a91(indx);
          t(ddindx).upgrade_status_flag := a92(indx);
          t(ddindx).transaction_date := rosetta_g_miss_date_in_map(a93(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_tcn_pvt.tcnv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_VARCHAR2_TABLE_500
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_DATE_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_DATE_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , a58 out nocopy JTF_DATE_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_DATE_TABLE
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_NUMBER_TABLE
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_DATE_TABLE
    , a83 out nocopy JTF_NUMBER_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_VARCHAR2_TABLE_200
    , a87 out nocopy JTF_VARCHAR2_TABLE_100
    , a88 out nocopy JTF_VARCHAR2_TABLE_200
    , a89 out nocopy JTF_VARCHAR2_TABLE_100
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_VARCHAR2_TABLE_100
    , a92 out nocopy JTF_VARCHAR2_TABLE_100
    , a93 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_100();
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
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_VARCHAR2_TABLE_500();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_DATE_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_DATE_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_2000();
    a58 := JTF_DATE_TABLE();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_VARCHAR2_TABLE_100();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_VARCHAR2_TABLE_100();
    a73 := JTF_VARCHAR2_TABLE_100();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_DATE_TABLE();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_NUMBER_TABLE();
    a81 := JTF_VARCHAR2_TABLE_100();
    a82 := JTF_DATE_TABLE();
    a83 := JTF_NUMBER_TABLE();
    a84 := JTF_DATE_TABLE();
    a85 := JTF_VARCHAR2_TABLE_100();
    a86 := JTF_VARCHAR2_TABLE_200();
    a87 := JTF_VARCHAR2_TABLE_100();
    a88 := JTF_VARCHAR2_TABLE_200();
    a89 := JTF_VARCHAR2_TABLE_100();
    a90 := JTF_VARCHAR2_TABLE_100();
    a91 := JTF_VARCHAR2_TABLE_100();
    a92 := JTF_VARCHAR2_TABLE_100();
    a93 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_100();
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
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_VARCHAR2_TABLE_500();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_DATE_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_DATE_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_2000();
      a58 := JTF_DATE_TABLE();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_VARCHAR2_TABLE_100();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_VARCHAR2_TABLE_100();
      a73 := JTF_VARCHAR2_TABLE_100();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_DATE_TABLE();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_NUMBER_TABLE();
      a81 := JTF_VARCHAR2_TABLE_100();
      a82 := JTF_DATE_TABLE();
      a83 := JTF_NUMBER_TABLE();
      a84 := JTF_DATE_TABLE();
      a85 := JTF_VARCHAR2_TABLE_100();
      a86 := JTF_VARCHAR2_TABLE_200();
      a87 := JTF_VARCHAR2_TABLE_100();
      a88 := JTF_VARCHAR2_TABLE_200();
      a89 := JTF_VARCHAR2_TABLE_100();
      a90 := JTF_VARCHAR2_TABLE_100();
      a91 := JTF_VARCHAR2_TABLE_100();
      a92 := JTF_VARCHAR2_TABLE_100();
      a93 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).rbr_code;
          a3(indx) := t(ddindx).rpy_code;
          a4(indx) := t(ddindx).rvn_code;
          a5(indx) := t(ddindx).trn_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id_new);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).pvn_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).aes_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).code_combination_id);
          a12(indx) := t(ddindx).tax_deductible_local;
          a13(indx) := t(ddindx).tax_deductible_corporate;
          a14(indx) := t(ddindx).date_accrual;
          a15(indx) := t(ddindx).accrual_status_yn;
          a16(indx) := t(ddindx).update_status_yn;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a18(indx) := t(ddindx).currency_code;
          a19(indx) := t(ddindx).attribute_category;
          a20(indx) := t(ddindx).attribute1;
          a21(indx) := t(ddindx).attribute2;
          a22(indx) := t(ddindx).attribute3;
          a23(indx) := t(ddindx).attribute4;
          a24(indx) := t(ddindx).attribute5;
          a25(indx) := t(ddindx).attribute6;
          a26(indx) := t(ddindx).attribute7;
          a27(indx) := t(ddindx).attribute8;
          a28(indx) := t(ddindx).attribute9;
          a29(indx) := t(ddindx).attribute10;
          a30(indx) := t(ddindx).attribute11;
          a31(indx) := t(ddindx).attribute12;
          a32(indx) := t(ddindx).attribute13;
          a33(indx) := t(ddindx).attribute14;
          a34(indx) := t(ddindx).attribute15;
          a35(indx) := t(ddindx).tcn_type;
          a36(indx) := t(ddindx).rjn_code;
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).party_rel_id1_old);
          a38(indx) := t(ddindx).party_rel_id2_old;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).party_rel_id1_new);
          a40(indx) := t(ddindx).party_rel_id2_new;
          a41(indx) := t(ddindx).complete_transfer_yn;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id_old);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a48(indx) := t(ddindx).program_update_date;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a50(indx) := t(ddindx).creation_date;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a52(indx) := t(ddindx).last_update_date;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).try_id);
          a55(indx) := t(ddindx).tsu_code;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a57(indx) := t(ddindx).description;
          a58(indx) := t(ddindx).date_transaction_occurred;
          a59(indx) := t(ddindx).trx_number;
          a60(indx) := t(ddindx).tmt_evergreen_yn;
          a61(indx) := t(ddindx).tmt_close_balances_yn;
          a62(indx) := t(ddindx).tmt_accounting_entries_yn;
          a63(indx) := t(ddindx).tmt_cancel_insurance_yn;
          a64(indx) := t(ddindx).tmt_asset_disposition_yn;
          a65(indx) := t(ddindx).tmt_amortization_yn;
          a66(indx) := t(ddindx).tmt_asset_return_yn;
          a67(indx) := t(ddindx).tmt_contract_updated_yn;
          a68(indx) := t(ddindx).tmt_recycle_yn;
          a69(indx) := t(ddindx).tmt_validated_yn;
          a70(indx) := t(ddindx).tmt_streams_updated_yn;
          a71(indx) := t(ddindx).accrual_activity;
          a72(indx) := t(ddindx).tmt_split_asset_yn;
          a73(indx) := t(ddindx).tmt_generic_flag1_yn;
          a74(indx) := t(ddindx).tmt_generic_flag2_yn;
          a75(indx) := t(ddindx).tmt_generic_flag3_yn;
          a76(indx) := t(ddindx).currency_conversion_type;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a78(indx) := t(ddindx).currency_conversion_date;
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a80(indx) := rosetta_g_miss_num_map(t(ddindx).source_trx_id);
          a81(indx) := t(ddindx).source_trx_type;
          a82(indx) := t(ddindx).canceled_date;
          a83(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          a84(indx) := t(ddindx).accrual_reversal_date;
          a85(indx) := t(ddindx).accounting_reversal_yn;
          a86(indx) := t(ddindx).product_name;
          a87(indx) := t(ddindx).book_classification_code;
          a88(indx) := t(ddindx).tax_owner_code;
          a89(indx) := t(ddindx).tmt_status_code;
          a90(indx) := t(ddindx).representation_name;
          a91(indx) := t(ddindx).representation_code;
          a92(indx) := t(ddindx).upgrade_status_flag;
          a93(indx) := t(ddindx).transaction_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
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
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  VARCHAR2
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
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  DATE
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  VARCHAR2
    , p6_a82 out nocopy  DATE
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  DATE
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_tcn_pvt.tcnv_rec_type;
    ddx_tcnv_rec okl_tcn_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);


    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec,
      ddx_tcnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p6_a2 := ddx_tcnv_rec.rbr_code;
    p6_a3 := ddx_tcnv_rec.rpy_code;
    p6_a4 := ddx_tcnv_rec.rvn_code;
    p6_a5 := ddx_tcnv_rec.trn_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p6_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p6_a12 := ddx_tcnv_rec.tax_deductible_local;
    p6_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p6_a14 := ddx_tcnv_rec.date_accrual;
    p6_a15 := ddx_tcnv_rec.accrual_status_yn;
    p6_a16 := ddx_tcnv_rec.update_status_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p6_a18 := ddx_tcnv_rec.currency_code;
    p6_a19 := ddx_tcnv_rec.attribute_category;
    p6_a20 := ddx_tcnv_rec.attribute1;
    p6_a21 := ddx_tcnv_rec.attribute2;
    p6_a22 := ddx_tcnv_rec.attribute3;
    p6_a23 := ddx_tcnv_rec.attribute4;
    p6_a24 := ddx_tcnv_rec.attribute5;
    p6_a25 := ddx_tcnv_rec.attribute6;
    p6_a26 := ddx_tcnv_rec.attribute7;
    p6_a27 := ddx_tcnv_rec.attribute8;
    p6_a28 := ddx_tcnv_rec.attribute9;
    p6_a29 := ddx_tcnv_rec.attribute10;
    p6_a30 := ddx_tcnv_rec.attribute11;
    p6_a31 := ddx_tcnv_rec.attribute12;
    p6_a32 := ddx_tcnv_rec.attribute13;
    p6_a33 := ddx_tcnv_rec.attribute14;
    p6_a34 := ddx_tcnv_rec.attribute15;
    p6_a35 := ddx_tcnv_rec.tcn_type;
    p6_a36 := ddx_tcnv_rec.rjn_code;
    p6_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p6_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p6_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p6_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p6_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p6_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p6_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p6_a48 := ddx_tcnv_rec.program_update_date;
    p6_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p6_a50 := ddx_tcnv_rec.creation_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p6_a52 := ddx_tcnv_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p6_a55 := ddx_tcnv_rec.tsu_code;
    p6_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p6_a57 := ddx_tcnv_rec.description;
    p6_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p6_a59 := ddx_tcnv_rec.trx_number;
    p6_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p6_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p6_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p6_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p6_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p6_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p6_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p6_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p6_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p6_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p6_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;
    p6_a71 := ddx_tcnv_rec.accrual_activity;
    p6_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p6_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p6_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p6_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p6_a76 := ddx_tcnv_rec.currency_conversion_type;
    p6_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p6_a78 := ddx_tcnv_rec.currency_conversion_date;
    p6_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p6_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p6_a81 := ddx_tcnv_rec.source_trx_type;
    p6_a82 := ddx_tcnv_rec.canceled_date;
    p6_a83 := rosetta_g_miss_num_map(ddx_tcnv_rec.legal_entity_id);
    p6_a84 := ddx_tcnv_rec.accrual_reversal_date;
    p6_a85 := ddx_tcnv_rec.accounting_reversal_yn;
    p6_a86 := ddx_tcnv_rec.product_name;
    p6_a87 := ddx_tcnv_rec.book_classification_code;
    p6_a88 := ddx_tcnv_rec.tax_owner_code;
    p6_a89 := ddx_tcnv_rec.tmt_status_code;
    p6_a90 := ddx_tcnv_rec.representation_name;
    p6_a91 := ddx_tcnv_rec.representation_code;
    p6_a92 := ddx_tcnv_rec.upgrade_status_flag;
    p6_a93 := ddx_tcnv_rec.transaction_date;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_2000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_VARCHAR2_TABLE_100
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_VARCHAR2_TABLE_100
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_DATE_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_VARCHAR2_TABLE_100
    , p5_a86 JTF_VARCHAR2_TABLE_200
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_VARCHAR2_TABLE_200
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_VARCHAR2_TABLE_100
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_tcnv_tbl okl_tcn_pvt.tcnv_tbl_type;
    ddx_tcnv_tbl okl_tcn_pvt.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_tbl,
      ddx_tcnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcn_pvt_w.rosetta_table_copy_out_p5(ddx_tcnv_tbl, p6_a0
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
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_tcn_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);

    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_2000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_VARCHAR2_TABLE_100
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_VARCHAR2_TABLE_100
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_DATE_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_VARCHAR2_TABLE_100
    , p5_a86 JTF_VARCHAR2_TABLE_200
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_VARCHAR2_TABLE_200
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_VARCHAR2_TABLE_100
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_DATE_TABLE
  )

  as
    ddp_tcnv_tbl okl_tcn_pvt.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_tbl);

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
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
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
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  DATE
    , p6_a59 out nocopy  VARCHAR2
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
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  NUMBER
    , p6_a78 out nocopy  DATE
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  NUMBER
    , p6_a81 out nocopy  VARCHAR2
    , p6_a82 out nocopy  DATE
    , p6_a83 out nocopy  NUMBER
    , p6_a84 out nocopy  DATE
    , p6_a85 out nocopy  VARCHAR2
    , p6_a86 out nocopy  VARCHAR2
    , p6_a87 out nocopy  VARCHAR2
    , p6_a88 out nocopy  VARCHAR2
    , p6_a89 out nocopy  VARCHAR2
    , p6_a90 out nocopy  VARCHAR2
    , p6_a91 out nocopy  VARCHAR2
    , p6_a92 out nocopy  VARCHAR2
    , p6_a93 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_tcn_pvt.tcnv_rec_type;
    ddx_tcnv_rec okl_tcn_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);


    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec,
      ddx_tcnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tcnv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tcnv_rec.object_version_number);
    p6_a2 := ddx_tcnv_rec.rbr_code;
    p6_a3 := ddx_tcnv_rec.rpy_code;
    p6_a4 := ddx_tcnv_rec.rvn_code;
    p6_a5 := ddx_tcnv_rec.trn_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_new);
    p6_a7 := rosetta_g_miss_num_map(ddx_tcnv_rec.pvn_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_tcnv_rec.pdt_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tcnv_rec.qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tcnv_rec.aes_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tcnv_rec.code_combination_id);
    p6_a12 := ddx_tcnv_rec.tax_deductible_local;
    p6_a13 := ddx_tcnv_rec.tax_deductible_corporate;
    p6_a14 := ddx_tcnv_rec.date_accrual;
    p6_a15 := ddx_tcnv_rec.accrual_status_yn;
    p6_a16 := ddx_tcnv_rec.update_status_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_tcnv_rec.amount);
    p6_a18 := ddx_tcnv_rec.currency_code;
    p6_a19 := ddx_tcnv_rec.attribute_category;
    p6_a20 := ddx_tcnv_rec.attribute1;
    p6_a21 := ddx_tcnv_rec.attribute2;
    p6_a22 := ddx_tcnv_rec.attribute3;
    p6_a23 := ddx_tcnv_rec.attribute4;
    p6_a24 := ddx_tcnv_rec.attribute5;
    p6_a25 := ddx_tcnv_rec.attribute6;
    p6_a26 := ddx_tcnv_rec.attribute7;
    p6_a27 := ddx_tcnv_rec.attribute8;
    p6_a28 := ddx_tcnv_rec.attribute9;
    p6_a29 := ddx_tcnv_rec.attribute10;
    p6_a30 := ddx_tcnv_rec.attribute11;
    p6_a31 := ddx_tcnv_rec.attribute12;
    p6_a32 := ddx_tcnv_rec.attribute13;
    p6_a33 := ddx_tcnv_rec.attribute14;
    p6_a34 := ddx_tcnv_rec.attribute15;
    p6_a35 := ddx_tcnv_rec.tcn_type;
    p6_a36 := ddx_tcnv_rec.rjn_code;
    p6_a37 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_old);
    p6_a38 := ddx_tcnv_rec.party_rel_id2_old;
    p6_a39 := rosetta_g_miss_num_map(ddx_tcnv_rec.party_rel_id1_new);
    p6_a40 := ddx_tcnv_rec.party_rel_id2_new;
    p6_a41 := ddx_tcnv_rec.complete_transfer_yn;
    p6_a42 := rosetta_g_miss_num_map(ddx_tcnv_rec.org_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tcnv_rec.request_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_application_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_tcnv_rec.khr_id_old);
    p6_a47 := rosetta_g_miss_num_map(ddx_tcnv_rec.program_id);
    p6_a48 := ddx_tcnv_rec.program_update_date;
    p6_a49 := rosetta_g_miss_num_map(ddx_tcnv_rec.created_by);
    p6_a50 := ddx_tcnv_rec.creation_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_updated_by);
    p6_a52 := ddx_tcnv_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tcnv_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_tcnv_rec.try_id);
    p6_a55 := ddx_tcnv_rec.tsu_code;
    p6_a56 := rosetta_g_miss_num_map(ddx_tcnv_rec.set_of_books_id);
    p6_a57 := ddx_tcnv_rec.description;
    p6_a58 := ddx_tcnv_rec.date_transaction_occurred;
    p6_a59 := ddx_tcnv_rec.trx_number;
    p6_a60 := ddx_tcnv_rec.tmt_evergreen_yn;
    p6_a61 := ddx_tcnv_rec.tmt_close_balances_yn;
    p6_a62 := ddx_tcnv_rec.tmt_accounting_entries_yn;
    p6_a63 := ddx_tcnv_rec.tmt_cancel_insurance_yn;
    p6_a64 := ddx_tcnv_rec.tmt_asset_disposition_yn;
    p6_a65 := ddx_tcnv_rec.tmt_amortization_yn;
    p6_a66 := ddx_tcnv_rec.tmt_asset_return_yn;
    p6_a67 := ddx_tcnv_rec.tmt_contract_updated_yn;
    p6_a68 := ddx_tcnv_rec.tmt_recycle_yn;
    p6_a69 := ddx_tcnv_rec.tmt_validated_yn;
    p6_a70 := ddx_tcnv_rec.tmt_streams_updated_yn;
    p6_a71 := ddx_tcnv_rec.accrual_activity;
    p6_a72 := ddx_tcnv_rec.tmt_split_asset_yn;
    p6_a73 := ddx_tcnv_rec.tmt_generic_flag1_yn;
    p6_a74 := ddx_tcnv_rec.tmt_generic_flag2_yn;
    p6_a75 := ddx_tcnv_rec.tmt_generic_flag3_yn;
    p6_a76 := ddx_tcnv_rec.currency_conversion_type;
    p6_a77 := rosetta_g_miss_num_map(ddx_tcnv_rec.currency_conversion_rate);
    p6_a78 := ddx_tcnv_rec.currency_conversion_date;
    p6_a79 := rosetta_g_miss_num_map(ddx_tcnv_rec.chr_id);
    p6_a80 := rosetta_g_miss_num_map(ddx_tcnv_rec.source_trx_id);
    p6_a81 := ddx_tcnv_rec.source_trx_type;
    p6_a82 := ddx_tcnv_rec.canceled_date;
    p6_a83 := rosetta_g_miss_num_map(ddx_tcnv_rec.legal_entity_id);
    p6_a84 := ddx_tcnv_rec.accrual_reversal_date;
    p6_a85 := ddx_tcnv_rec.accounting_reversal_yn;
    p6_a86 := ddx_tcnv_rec.product_name;
    p6_a87 := ddx_tcnv_rec.book_classification_code;
    p6_a88 := ddx_tcnv_rec.tax_owner_code;
    p6_a89 := ddx_tcnv_rec.tmt_status_code;
    p6_a90 := ddx_tcnv_rec.representation_name;
    p6_a91 := ddx_tcnv_rec.representation_code;
    p6_a92 := ddx_tcnv_rec.upgrade_status_flag;
    p6_a93 := ddx_tcnv_rec.transaction_date;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_2000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_VARCHAR2_TABLE_100
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_VARCHAR2_TABLE_100
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_DATE_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_VARCHAR2_TABLE_100
    , p5_a86 JTF_VARCHAR2_TABLE_200
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_VARCHAR2_TABLE_200
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_VARCHAR2_TABLE_100
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_tcnv_tbl okl_tcn_pvt.tcnv_tbl_type;
    ddx_tcnv_tbl okl_tcn_pvt.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_tbl,
      ddx_tcnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tcn_pvt_w.rosetta_table_copy_out_p5(ddx_tcnv_tbl, p6_a0
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
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_tcn_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);

    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_2000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_VARCHAR2_TABLE_100
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_VARCHAR2_TABLE_100
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_DATE_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_VARCHAR2_TABLE_100
    , p5_a86 JTF_VARCHAR2_TABLE_200
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_VARCHAR2_TABLE_200
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_VARCHAR2_TABLE_100
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_DATE_TABLE
  )

  as
    ddp_tcnv_tbl okl_tcn_pvt.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_tbl);

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
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  DATE := fnd_api.g_miss_date
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  NUMBER := 0-1962.0724
    , p5_a78  DATE := fnd_api.g_miss_date
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  NUMBER := 0-1962.0724
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  DATE := fnd_api.g_miss_date
    , p5_a83  NUMBER := 0-1962.0724
    , p5_a84  DATE := fnd_api.g_miss_date
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  DATE := fnd_api.g_miss_date
  )

  as
    ddp_tcnv_rec okl_tcn_pvt.tcnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tcnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tcnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tcnv_rec.rbr_code := p5_a2;
    ddp_tcnv_rec.rpy_code := p5_a3;
    ddp_tcnv_rec.rvn_code := p5_a4;
    ddp_tcnv_rec.trn_code := p5_a5;
    ddp_tcnv_rec.khr_id_new := rosetta_g_miss_num_map(p5_a6);
    ddp_tcnv_rec.pvn_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tcnv_rec.pdt_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tcnv_rec.qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tcnv_rec.aes_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tcnv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a11);
    ddp_tcnv_rec.tax_deductible_local := p5_a12;
    ddp_tcnv_rec.tax_deductible_corporate := p5_a13;
    ddp_tcnv_rec.date_accrual := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tcnv_rec.accrual_status_yn := p5_a15;
    ddp_tcnv_rec.update_status_yn := p5_a16;
    ddp_tcnv_rec.amount := rosetta_g_miss_num_map(p5_a17);
    ddp_tcnv_rec.currency_code := p5_a18;
    ddp_tcnv_rec.attribute_category := p5_a19;
    ddp_tcnv_rec.attribute1 := p5_a20;
    ddp_tcnv_rec.attribute2 := p5_a21;
    ddp_tcnv_rec.attribute3 := p5_a22;
    ddp_tcnv_rec.attribute4 := p5_a23;
    ddp_tcnv_rec.attribute5 := p5_a24;
    ddp_tcnv_rec.attribute6 := p5_a25;
    ddp_tcnv_rec.attribute7 := p5_a26;
    ddp_tcnv_rec.attribute8 := p5_a27;
    ddp_tcnv_rec.attribute9 := p5_a28;
    ddp_tcnv_rec.attribute10 := p5_a29;
    ddp_tcnv_rec.attribute11 := p5_a30;
    ddp_tcnv_rec.attribute12 := p5_a31;
    ddp_tcnv_rec.attribute13 := p5_a32;
    ddp_tcnv_rec.attribute14 := p5_a33;
    ddp_tcnv_rec.attribute15 := p5_a34;
    ddp_tcnv_rec.tcn_type := p5_a35;
    ddp_tcnv_rec.rjn_code := p5_a36;
    ddp_tcnv_rec.party_rel_id1_old := rosetta_g_miss_num_map(p5_a37);
    ddp_tcnv_rec.party_rel_id2_old := p5_a38;
    ddp_tcnv_rec.party_rel_id1_new := rosetta_g_miss_num_map(p5_a39);
    ddp_tcnv_rec.party_rel_id2_new := p5_a40;
    ddp_tcnv_rec.complete_transfer_yn := p5_a41;
    ddp_tcnv_rec.org_id := rosetta_g_miss_num_map(p5_a42);
    ddp_tcnv_rec.khr_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tcnv_rec.request_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tcnv_rec.program_application_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tcnv_rec.khr_id_old := rosetta_g_miss_num_map(p5_a46);
    ddp_tcnv_rec.program_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tcnv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_tcnv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tcnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tcnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tcnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tcnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tcnv_rec.try_id := rosetta_g_miss_num_map(p5_a54);
    ddp_tcnv_rec.tsu_code := p5_a55;
    ddp_tcnv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a56);
    ddp_tcnv_rec.description := p5_a57;
    ddp_tcnv_rec.date_transaction_occurred := rosetta_g_miss_date_in_map(p5_a58);
    ddp_tcnv_rec.trx_number := p5_a59;
    ddp_tcnv_rec.tmt_evergreen_yn := p5_a60;
    ddp_tcnv_rec.tmt_close_balances_yn := p5_a61;
    ddp_tcnv_rec.tmt_accounting_entries_yn := p5_a62;
    ddp_tcnv_rec.tmt_cancel_insurance_yn := p5_a63;
    ddp_tcnv_rec.tmt_asset_disposition_yn := p5_a64;
    ddp_tcnv_rec.tmt_amortization_yn := p5_a65;
    ddp_tcnv_rec.tmt_asset_return_yn := p5_a66;
    ddp_tcnv_rec.tmt_contract_updated_yn := p5_a67;
    ddp_tcnv_rec.tmt_recycle_yn := p5_a68;
    ddp_tcnv_rec.tmt_validated_yn := p5_a69;
    ddp_tcnv_rec.tmt_streams_updated_yn := p5_a70;
    ddp_tcnv_rec.accrual_activity := p5_a71;
    ddp_tcnv_rec.tmt_split_asset_yn := p5_a72;
    ddp_tcnv_rec.tmt_generic_flag1_yn := p5_a73;
    ddp_tcnv_rec.tmt_generic_flag2_yn := p5_a74;
    ddp_tcnv_rec.tmt_generic_flag3_yn := p5_a75;
    ddp_tcnv_rec.currency_conversion_type := p5_a76;
    ddp_tcnv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a77);
    ddp_tcnv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a78);
    ddp_tcnv_rec.chr_id := rosetta_g_miss_num_map(p5_a79);
    ddp_tcnv_rec.source_trx_id := rosetta_g_miss_num_map(p5_a80);
    ddp_tcnv_rec.source_trx_type := p5_a81;
    ddp_tcnv_rec.canceled_date := rosetta_g_miss_date_in_map(p5_a82);
    ddp_tcnv_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a83);
    ddp_tcnv_rec.accrual_reversal_date := rosetta_g_miss_date_in_map(p5_a84);
    ddp_tcnv_rec.accounting_reversal_yn := p5_a85;
    ddp_tcnv_rec.product_name := p5_a86;
    ddp_tcnv_rec.book_classification_code := p5_a87;
    ddp_tcnv_rec.tax_owner_code := p5_a88;
    ddp_tcnv_rec.tmt_status_code := p5_a89;
    ddp_tcnv_rec.representation_name := p5_a90;
    ddp_tcnv_rec.representation_code := p5_a91;
    ddp_tcnv_rec.upgrade_status_flag := p5_a92;
    ddp_tcnv_rec.transaction_date := rosetta_g_miss_date_in_map(p5_a93);

    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_2000
    , p5_a58 JTF_DATE_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_VARCHAR2_TABLE_100
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_VARCHAR2_TABLE_100
    , p5_a73 JTF_VARCHAR2_TABLE_100
    , p5_a74 JTF_VARCHAR2_TABLE_100
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_DATE_TABLE
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_NUMBER_TABLE
    , p5_a81 JTF_VARCHAR2_TABLE_100
    , p5_a82 JTF_DATE_TABLE
    , p5_a83 JTF_NUMBER_TABLE
    , p5_a84 JTF_DATE_TABLE
    , p5_a85 JTF_VARCHAR2_TABLE_100
    , p5_a86 JTF_VARCHAR2_TABLE_200
    , p5_a87 JTF_VARCHAR2_TABLE_100
    , p5_a88 JTF_VARCHAR2_TABLE_200
    , p5_a89 JTF_VARCHAR2_TABLE_100
    , p5_a90 JTF_VARCHAR2_TABLE_100
    , p5_a91 JTF_VARCHAR2_TABLE_100
    , p5_a92 JTF_VARCHAR2_TABLE_100
    , p5_a93 JTF_DATE_TABLE
  )

  as
    ddp_tcnv_tbl okl_tcn_pvt.tcnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tcn_pvt_w.rosetta_table_copy_in_p5(ddp_tcnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tcn_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tcnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_tcn_pvt_w;

/
