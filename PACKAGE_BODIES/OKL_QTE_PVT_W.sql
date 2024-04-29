--------------------------------------------------------
--  DDL for Package Body OKL_QTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QTE_PVT_W" as
  /* $Header: OKLIQTEB.pls 120.2 2007/11/02 21:02:17 rmunjulu ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_qte_pvt.qte_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_DATE_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
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
    , a60 JTF_VARCHAR2_TABLE_500
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_DATE_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_DATE_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_DATE_TABLE
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).qrs_code := a1(indx);
          t(ddindx).qst_code := a2(indx);
          t(ddindx).consolidated_qte_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).art_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).qtp_code := a6(indx);
          t(ddindx).trn_code := a7(indx);
          t(ddindx).pop_code_end := a8(indx);
          t(ddindx).pop_code_early := a9(indx);
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).date_effective_from := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).quote_number := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).purchase_percent := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).term := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).date_restructure_start := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).date_due := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).date_approved := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).date_restructure_end := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).remaining_payments := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).rent_amount := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).yield := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).residual_amount := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).principal_paydown_amount := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).payment_frequency := a25(indx);
          t(ddindx).early_termination_yn := a26(indx);
          t(ddindx).partial_yn := a27(indx);
          t(ddindx).preproceeds_yn := a28(indx);
          t(ddindx).summary_format_yn := a29(indx);
          t(ddindx).consolidated_yn := a30(indx);
          t(ddindx).date_requested := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).date_proposal := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).date_effective_to := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).date_accepted := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).payment_received_yn := a35(indx);
          t(ddindx).requested_by := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).approved_yn := a37(indx);
          t(ddindx).accepted_yn := a38(indx);
          t(ddindx).date_payment_received := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).approved_by := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a45(indx));
          t(ddindx).attribute_category := a46(indx);
          t(ddindx).attribute1 := a47(indx);
          t(ddindx).attribute2 := a48(indx);
          t(ddindx).attribute3 := a49(indx);
          t(ddindx).attribute4 := a50(indx);
          t(ddindx).attribute5 := a51(indx);
          t(ddindx).attribute6 := a52(indx);
          t(ddindx).attribute7 := a53(indx);
          t(ddindx).attribute8 := a54(indx);
          t(ddindx).attribute9 := a55(indx);
          t(ddindx).attribute10 := a56(indx);
          t(ddindx).attribute11 := a57(indx);
          t(ddindx).attribute12 := a58(indx);
          t(ddindx).attribute13 := a59(indx);
          t(ddindx).attribute14 := a60(indx);
          t(ddindx).attribute15 := a61(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a63(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a65(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).purchase_amount := rosetta_g_miss_num_map(a67(indx));
          t(ddindx).purchase_formula := a68(indx);
          t(ddindx).asset_value := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).residual_value := rosetta_g_miss_num_map(a70(indx));
          t(ddindx).unbilled_receivables := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).gain_loss := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).perdiem_amount := rosetta_g_miss_num_map(a73(indx));
          t(ddindx).currency_code := a74(indx);
          t(ddindx).currency_conversion_code := a75(indx);
          t(ddindx).currency_conversion_type := a76(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a77(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a78(indx));
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).repo_quote_indicator_yn := a80(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_qte_pvt.qte_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a60 out nocopy JTF_VARCHAR2_TABLE_500
    , a61 out nocopy JTF_VARCHAR2_TABLE_500
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_DATE_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_DATE_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_DATE_TABLE
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
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
    a60 := JTF_VARCHAR2_TABLE_500();
    a61 := JTF_VARCHAR2_TABLE_500();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_DATE_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_DATE_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_VARCHAR2_TABLE_200();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_VARCHAR2_TABLE_100();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_DATE_TABLE();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
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
      a60 := JTF_VARCHAR2_TABLE_500();
      a61 := JTF_VARCHAR2_TABLE_500();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_DATE_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_DATE_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_VARCHAR2_TABLE_200();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_VARCHAR2_TABLE_100();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_DATE_TABLE();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).qrs_code;
          a2(indx) := t(ddindx).qst_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).consolidated_qte_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).art_id);
          a6(indx) := t(ddindx).qtp_code;
          a7(indx) := t(ddindx).trn_code;
          a8(indx) := t(ddindx).pop_code_end;
          a9(indx) := t(ddindx).pop_code_early;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a11(indx) := t(ddindx).date_effective_from;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).quote_number);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).purchase_percent);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).term);
          a16(indx) := t(ddindx).date_restructure_start;
          a17(indx) := t(ddindx).date_due;
          a18(indx) := t(ddindx).date_approved;
          a19(indx) := t(ddindx).date_restructure_end;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).remaining_payments);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).rent_amount);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).yield);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).residual_amount);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).principal_paydown_amount);
          a25(indx) := t(ddindx).payment_frequency;
          a26(indx) := t(ddindx).early_termination_yn;
          a27(indx) := t(ddindx).partial_yn;
          a28(indx) := t(ddindx).preproceeds_yn;
          a29(indx) := t(ddindx).summary_format_yn;
          a30(indx) := t(ddindx).consolidated_yn;
          a31(indx) := t(ddindx).date_requested;
          a32(indx) := t(ddindx).date_proposal;
          a33(indx) := t(ddindx).date_effective_to;
          a34(indx) := t(ddindx).date_accepted;
          a35(indx) := t(ddindx).payment_received_yn;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).requested_by);
          a37(indx) := t(ddindx).approved_yn;
          a38(indx) := t(ddindx).accepted_yn;
          a39(indx) := t(ddindx).date_payment_received;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).approved_by);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a45(indx) := t(ddindx).program_update_date;
          a46(indx) := t(ddindx).attribute_category;
          a47(indx) := t(ddindx).attribute1;
          a48(indx) := t(ddindx).attribute2;
          a49(indx) := t(ddindx).attribute3;
          a50(indx) := t(ddindx).attribute4;
          a51(indx) := t(ddindx).attribute5;
          a52(indx) := t(ddindx).attribute6;
          a53(indx) := t(ddindx).attribute7;
          a54(indx) := t(ddindx).attribute8;
          a55(indx) := t(ddindx).attribute9;
          a56(indx) := t(ddindx).attribute10;
          a57(indx) := t(ddindx).attribute11;
          a58(indx) := t(ddindx).attribute12;
          a59(indx) := t(ddindx).attribute13;
          a60(indx) := t(ddindx).attribute14;
          a61(indx) := t(ddindx).attribute15;
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a63(indx) := t(ddindx).creation_date;
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a65(indx) := t(ddindx).last_update_date;
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a67(indx) := rosetta_g_miss_num_map(t(ddindx).purchase_amount);
          a68(indx) := t(ddindx).purchase_formula;
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).asset_value);
          a70(indx) := rosetta_g_miss_num_map(t(ddindx).residual_value);
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).unbilled_receivables);
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).gain_loss);
          a73(indx) := rosetta_g_miss_num_map(t(ddindx).perdiem_amount);
          a74(indx) := t(ddindx).currency_code;
          a75(indx) := t(ddindx).currency_conversion_code;
          a76(indx) := t(ddindx).currency_conversion_type;
          a77(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a78(indx) := t(ddindx).currency_conversion_date;
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          a80(indx) := t(ddindx).repo_quote_indicator_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_qte_pvt.okl_trx_quotes_tl_tbl_type, a0 JTF_NUMBER_TABLE
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
          t(ddindx).comments := a4(indx);
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
  procedure rosetta_table_copy_out_p5(t okl_qte_pvt.okl_trx_quotes_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
          a4(indx) := t(ddindx).comments;
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

  procedure rosetta_table_copy_in_p8(t out nocopy okl_qte_pvt.qtev_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_2000
    , a31 JTF_DATE_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_DATE_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
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
    , a54 JTF_VARCHAR2_TABLE_500
    , a55 JTF_VARCHAR2_TABLE_500
    , a56 JTF_VARCHAR2_TABLE_500
    , a57 JTF_DATE_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_DATE_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_DATE_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_DATE_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_NUMBER_TABLE
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_DATE_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).qrs_code := a3(indx);
          t(ddindx).qst_code := a4(indx);
          t(ddindx).qtp_code := a5(indx);
          t(ddindx).trn_code := a6(indx);
          t(ddindx).pop_code_end := a7(indx);
          t(ddindx).pop_code_early := a8(indx);
          t(ddindx).consolidated_qte_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).art_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).early_termination_yn := a13(indx);
          t(ddindx).partial_yn := a14(indx);
          t(ddindx).preproceeds_yn := a15(indx);
          t(ddindx).date_requested := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).date_proposal := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).date_effective_to := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).date_accepted := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).summary_format_yn := a20(indx);
          t(ddindx).consolidated_yn := a21(indx);
          t(ddindx).principal_paydown_amount := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).residual_amount := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).yield := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).rent_amount := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).date_restructure_end := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).date_restructure_start := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).term := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).purchase_percent := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).comments := a30(indx);
          t(ddindx).date_due := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).payment_frequency := a32(indx);
          t(ddindx).remaining_payments := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).date_effective_from := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).quote_number := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).requested_by := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).approved_yn := a37(indx);
          t(ddindx).accepted_yn := a38(indx);
          t(ddindx).payment_received_yn := a39(indx);
          t(ddindx).date_payment_received := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).attribute_category := a41(indx);
          t(ddindx).attribute1 := a42(indx);
          t(ddindx).attribute2 := a43(indx);
          t(ddindx).attribute3 := a44(indx);
          t(ddindx).attribute4 := a45(indx);
          t(ddindx).attribute5 := a46(indx);
          t(ddindx).attribute6 := a47(indx);
          t(ddindx).attribute7 := a48(indx);
          t(ddindx).attribute8 := a49(indx);
          t(ddindx).attribute9 := a50(indx);
          t(ddindx).attribute10 := a51(indx);
          t(ddindx).attribute11 := a52(indx);
          t(ddindx).attribute12 := a53(indx);
          t(ddindx).attribute13 := a54(indx);
          t(ddindx).attribute14 := a55(indx);
          t(ddindx).attribute15 := a56(indx);
          t(ddindx).date_approved := rosetta_g_miss_date_in_map(a57(indx));
          t(ddindx).approved_by := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a61(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a62(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a63(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a64(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a65(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a66(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a67(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a68(indx));
          t(ddindx).purchase_amount := rosetta_g_miss_num_map(a69(indx));
          t(ddindx).purchase_formula := a70(indx);
          t(ddindx).asset_value := rosetta_g_miss_num_map(a71(indx));
          t(ddindx).residual_value := rosetta_g_miss_num_map(a72(indx));
          t(ddindx).unbilled_receivables := rosetta_g_miss_num_map(a73(indx));
          t(ddindx).gain_loss := rosetta_g_miss_num_map(a74(indx));
          t(ddindx).perdiem_amount := rosetta_g_miss_num_map(a75(indx));
          t(ddindx).currency_code := a76(indx);
          t(ddindx).currency_conversion_code := a77(indx);
          t(ddindx).currency_conversion_type := a78(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a79(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a80(indx));
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a81(indx));
          t(ddindx).repo_quote_indicator_yn := a82(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_qte_pvt.qtev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a54 out nocopy JTF_VARCHAR2_TABLE_500
    , a55 out nocopy JTF_VARCHAR2_TABLE_500
    , a56 out nocopy JTF_VARCHAR2_TABLE_500
    , a57 out nocopy JTF_DATE_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_DATE_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_DATE_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_DATE_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_NUMBER_TABLE
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_DATE_TABLE
    , a81 out nocopy JTF_NUMBER_TABLE
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
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
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_2000();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
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
    a54 := JTF_VARCHAR2_TABLE_500();
    a55 := JTF_VARCHAR2_TABLE_500();
    a56 := JTF_VARCHAR2_TABLE_500();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_DATE_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_DATE_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_DATE_TABLE();
    a68 := JTF_NUMBER_TABLE();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_VARCHAR2_TABLE_200();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_NUMBER_TABLE();
    a76 := JTF_VARCHAR2_TABLE_100();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_NUMBER_TABLE();
    a80 := JTF_DATE_TABLE();
    a81 := JTF_NUMBER_TABLE();
    a82 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_2000();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
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
      a54 := JTF_VARCHAR2_TABLE_500();
      a55 := JTF_VARCHAR2_TABLE_500();
      a56 := JTF_VARCHAR2_TABLE_500();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_DATE_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_DATE_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_DATE_TABLE();
      a68 := JTF_NUMBER_TABLE();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_VARCHAR2_TABLE_200();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_NUMBER_TABLE();
      a76 := JTF_VARCHAR2_TABLE_100();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_NUMBER_TABLE();
      a80 := JTF_DATE_TABLE();
      a81 := JTF_NUMBER_TABLE();
      a82 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := t(ddindx).qrs_code;
          a4(indx) := t(ddindx).qst_code;
          a5(indx) := t(ddindx).qtp_code;
          a6(indx) := t(ddindx).trn_code;
          a7(indx) := t(ddindx).pop_code_end;
          a8(indx) := t(ddindx).pop_code_early;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).consolidated_qte_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).art_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a13(indx) := t(ddindx).early_termination_yn;
          a14(indx) := t(ddindx).partial_yn;
          a15(indx) := t(ddindx).preproceeds_yn;
          a16(indx) := t(ddindx).date_requested;
          a17(indx) := t(ddindx).date_proposal;
          a18(indx) := t(ddindx).date_effective_to;
          a19(indx) := t(ddindx).date_accepted;
          a20(indx) := t(ddindx).summary_format_yn;
          a21(indx) := t(ddindx).consolidated_yn;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).principal_paydown_amount);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).residual_amount);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).yield);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).rent_amount);
          a26(indx) := t(ddindx).date_restructure_end;
          a27(indx) := t(ddindx).date_restructure_start;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).term);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).purchase_percent);
          a30(indx) := t(ddindx).comments;
          a31(indx) := t(ddindx).date_due;
          a32(indx) := t(ddindx).payment_frequency;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).remaining_payments);
          a34(indx) := t(ddindx).date_effective_from;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).quote_number);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).requested_by);
          a37(indx) := t(ddindx).approved_yn;
          a38(indx) := t(ddindx).accepted_yn;
          a39(indx) := t(ddindx).payment_received_yn;
          a40(indx) := t(ddindx).date_payment_received;
          a41(indx) := t(ddindx).attribute_category;
          a42(indx) := t(ddindx).attribute1;
          a43(indx) := t(ddindx).attribute2;
          a44(indx) := t(ddindx).attribute3;
          a45(indx) := t(ddindx).attribute4;
          a46(indx) := t(ddindx).attribute5;
          a47(indx) := t(ddindx).attribute6;
          a48(indx) := t(ddindx).attribute7;
          a49(indx) := t(ddindx).attribute8;
          a50(indx) := t(ddindx).attribute9;
          a51(indx) := t(ddindx).attribute10;
          a52(indx) := t(ddindx).attribute11;
          a53(indx) := t(ddindx).attribute12;
          a54(indx) := t(ddindx).attribute13;
          a55(indx) := t(ddindx).attribute14;
          a56(indx) := t(ddindx).attribute15;
          a57(indx) := t(ddindx).date_approved;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).approved_by);
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a61(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a62(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a63(indx) := t(ddindx).program_update_date;
          a64(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a65(indx) := t(ddindx).creation_date;
          a66(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a67(indx) := t(ddindx).last_update_date;
          a68(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a69(indx) := rosetta_g_miss_num_map(t(ddindx).purchase_amount);
          a70(indx) := t(ddindx).purchase_formula;
          a71(indx) := rosetta_g_miss_num_map(t(ddindx).asset_value);
          a72(indx) := rosetta_g_miss_num_map(t(ddindx).residual_value);
          a73(indx) := rosetta_g_miss_num_map(t(ddindx).unbilled_receivables);
          a74(indx) := rosetta_g_miss_num_map(t(ddindx).gain_loss);
          a75(indx) := rosetta_g_miss_num_map(t(ddindx).perdiem_amount);
          a76(indx) := t(ddindx).currency_code;
          a77(indx) := t(ddindx).currency_conversion_code;
          a78(indx) := t(ddindx).currency_conversion_type;
          a79(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a80(indx) := t(ddindx).currency_conversion_date;
          a81(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          a82(indx) := t(ddindx).repo_quote_indicator_yn;
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
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  DATE
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
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  DATE
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  DATE
    , p6_a81 out nocopy  NUMBER
    , p6_a82 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  DATE := fnd_api.g_miss_date
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_qtev_rec okl_qte_pvt.qtev_rec_type;
    ddx_qtev_rec okl_qte_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qtev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qtev_rec.sfwt_flag := p5_a2;
    ddp_qtev_rec.qrs_code := p5_a3;
    ddp_qtev_rec.qst_code := p5_a4;
    ddp_qtev_rec.qtp_code := p5_a5;
    ddp_qtev_rec.trn_code := p5_a6;
    ddp_qtev_rec.pop_code_end := p5_a7;
    ddp_qtev_rec.pop_code_early := p5_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_qtev_rec.early_termination_yn := p5_a13;
    ddp_qtev_rec.partial_yn := p5_a14;
    ddp_qtev_rec.preproceeds_yn := p5_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_qtev_rec.summary_format_yn := p5_a20;
    ddp_qtev_rec.consolidated_yn := p5_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_qtev_rec.comments := p5_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_qtev_rec.payment_frequency := p5_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_qtev_rec.approved_yn := p5_a37;
    ddp_qtev_rec.accepted_yn := p5_a38;
    ddp_qtev_rec.payment_received_yn := p5_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_qtev_rec.attribute_category := p5_a41;
    ddp_qtev_rec.attribute1 := p5_a42;
    ddp_qtev_rec.attribute2 := p5_a43;
    ddp_qtev_rec.attribute3 := p5_a44;
    ddp_qtev_rec.attribute4 := p5_a45;
    ddp_qtev_rec.attribute5 := p5_a46;
    ddp_qtev_rec.attribute6 := p5_a47;
    ddp_qtev_rec.attribute7 := p5_a48;
    ddp_qtev_rec.attribute8 := p5_a49;
    ddp_qtev_rec.attribute9 := p5_a50;
    ddp_qtev_rec.attribute10 := p5_a51;
    ddp_qtev_rec.attribute11 := p5_a52;
    ddp_qtev_rec.attribute12 := p5_a53;
    ddp_qtev_rec.attribute13 := p5_a54;
    ddp_qtev_rec.attribute14 := p5_a55;
    ddp_qtev_rec.attribute15 := p5_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_qtev_rec.purchase_formula := p5_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_qtev_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_qtev_rec.currency_code := p5_a76;
    ddp_qtev_rec.currency_conversion_code := p5_a77;
    ddp_qtev_rec.currency_conversion_type := p5_a78;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_qtev_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_qtev_rec.repo_quote_indicator_yn := p5_a82;


    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_rec,
      ddx_qtev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_qtev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_qtev_rec.object_version_number);
    p6_a2 := ddx_qtev_rec.sfwt_flag;
    p6_a3 := ddx_qtev_rec.qrs_code;
    p6_a4 := ddx_qtev_rec.qst_code;
    p6_a5 := ddx_qtev_rec.qtp_code;
    p6_a6 := ddx_qtev_rec.trn_code;
    p6_a7 := ddx_qtev_rec.pop_code_end;
    p6_a8 := ddx_qtev_rec.pop_code_early;
    p6_a9 := rosetta_g_miss_num_map(ddx_qtev_rec.consolidated_qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_qtev_rec.khr_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_qtev_rec.art_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_qtev_rec.pdt_id);
    p6_a13 := ddx_qtev_rec.early_termination_yn;
    p6_a14 := ddx_qtev_rec.partial_yn;
    p6_a15 := ddx_qtev_rec.preproceeds_yn;
    p6_a16 := ddx_qtev_rec.date_requested;
    p6_a17 := ddx_qtev_rec.date_proposal;
    p6_a18 := ddx_qtev_rec.date_effective_to;
    p6_a19 := ddx_qtev_rec.date_accepted;
    p6_a20 := ddx_qtev_rec.summary_format_yn;
    p6_a21 := ddx_qtev_rec.consolidated_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_qtev_rec.principal_paydown_amount);
    p6_a23 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_amount);
    p6_a24 := rosetta_g_miss_num_map(ddx_qtev_rec.yield);
    p6_a25 := rosetta_g_miss_num_map(ddx_qtev_rec.rent_amount);
    p6_a26 := ddx_qtev_rec.date_restructure_end;
    p6_a27 := ddx_qtev_rec.date_restructure_start;
    p6_a28 := rosetta_g_miss_num_map(ddx_qtev_rec.term);
    p6_a29 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_percent);
    p6_a30 := ddx_qtev_rec.comments;
    p6_a31 := ddx_qtev_rec.date_due;
    p6_a32 := ddx_qtev_rec.payment_frequency;
    p6_a33 := rosetta_g_miss_num_map(ddx_qtev_rec.remaining_payments);
    p6_a34 := ddx_qtev_rec.date_effective_from;
    p6_a35 := rosetta_g_miss_num_map(ddx_qtev_rec.quote_number);
    p6_a36 := rosetta_g_miss_num_map(ddx_qtev_rec.requested_by);
    p6_a37 := ddx_qtev_rec.approved_yn;
    p6_a38 := ddx_qtev_rec.accepted_yn;
    p6_a39 := ddx_qtev_rec.payment_received_yn;
    p6_a40 := ddx_qtev_rec.date_payment_received;
    p6_a41 := ddx_qtev_rec.attribute_category;
    p6_a42 := ddx_qtev_rec.attribute1;
    p6_a43 := ddx_qtev_rec.attribute2;
    p6_a44 := ddx_qtev_rec.attribute3;
    p6_a45 := ddx_qtev_rec.attribute4;
    p6_a46 := ddx_qtev_rec.attribute5;
    p6_a47 := ddx_qtev_rec.attribute6;
    p6_a48 := ddx_qtev_rec.attribute7;
    p6_a49 := ddx_qtev_rec.attribute8;
    p6_a50 := ddx_qtev_rec.attribute9;
    p6_a51 := ddx_qtev_rec.attribute10;
    p6_a52 := ddx_qtev_rec.attribute11;
    p6_a53 := ddx_qtev_rec.attribute12;
    p6_a54 := ddx_qtev_rec.attribute13;
    p6_a55 := ddx_qtev_rec.attribute14;
    p6_a56 := ddx_qtev_rec.attribute15;
    p6_a57 := ddx_qtev_rec.date_approved;
    p6_a58 := rosetta_g_miss_num_map(ddx_qtev_rec.approved_by);
    p6_a59 := rosetta_g_miss_num_map(ddx_qtev_rec.org_id);
    p6_a60 := rosetta_g_miss_num_map(ddx_qtev_rec.request_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_qtev_rec.program_application_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_qtev_rec.program_id);
    p6_a63 := ddx_qtev_rec.program_update_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_qtev_rec.created_by);
    p6_a65 := ddx_qtev_rec.creation_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_qtev_rec.last_updated_by);
    p6_a67 := ddx_qtev_rec.last_update_date;
    p6_a68 := rosetta_g_miss_num_map(ddx_qtev_rec.last_update_login);
    p6_a69 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_amount);
    p6_a70 := ddx_qtev_rec.purchase_formula;
    p6_a71 := rosetta_g_miss_num_map(ddx_qtev_rec.asset_value);
    p6_a72 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_value);
    p6_a73 := rosetta_g_miss_num_map(ddx_qtev_rec.unbilled_receivables);
    p6_a74 := rosetta_g_miss_num_map(ddx_qtev_rec.gain_loss);
    p6_a75 := rosetta_g_miss_num_map(ddx_qtev_rec.perdiem_amount);
    p6_a76 := ddx_qtev_rec.currency_code;
    p6_a77 := ddx_qtev_rec.currency_conversion_code;
    p6_a78 := ddx_qtev_rec.currency_conversion_type;
    p6_a79 := rosetta_g_miss_num_map(ddx_qtev_rec.currency_conversion_rate);
    p6_a80 := ddx_qtev_rec.currency_conversion_date;
    p6_a81 := rosetta_g_miss_num_map(ddx_qtev_rec.legal_entity_id);
    p6_a82 := ddx_qtev_rec.repo_quote_indicator_yn;
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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_DATE_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_200
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_VARCHAR2_TABLE_100
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_DATE_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_DATE_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_DATE_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_NUMBER_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_DATE_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
    , p6_a82 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qtev_tbl okl_qte_pvt.qtev_tbl_type;
    ddx_qtev_tbl okl_qte_pvt.qtev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qte_pvt_w.rosetta_table_copy_in_p8(ddp_qtev_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_tbl,
      ddx_qtev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qte_pvt_w.rosetta_table_copy_out_p8(ddx_qtev_tbl, p6_a0
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
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  DATE := fnd_api.g_miss_date
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_qtev_rec okl_qte_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qtev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qtev_rec.sfwt_flag := p5_a2;
    ddp_qtev_rec.qrs_code := p5_a3;
    ddp_qtev_rec.qst_code := p5_a4;
    ddp_qtev_rec.qtp_code := p5_a5;
    ddp_qtev_rec.trn_code := p5_a6;
    ddp_qtev_rec.pop_code_end := p5_a7;
    ddp_qtev_rec.pop_code_early := p5_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_qtev_rec.early_termination_yn := p5_a13;
    ddp_qtev_rec.partial_yn := p5_a14;
    ddp_qtev_rec.preproceeds_yn := p5_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_qtev_rec.summary_format_yn := p5_a20;
    ddp_qtev_rec.consolidated_yn := p5_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_qtev_rec.comments := p5_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_qtev_rec.payment_frequency := p5_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_qtev_rec.approved_yn := p5_a37;
    ddp_qtev_rec.accepted_yn := p5_a38;
    ddp_qtev_rec.payment_received_yn := p5_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_qtev_rec.attribute_category := p5_a41;
    ddp_qtev_rec.attribute1 := p5_a42;
    ddp_qtev_rec.attribute2 := p5_a43;
    ddp_qtev_rec.attribute3 := p5_a44;
    ddp_qtev_rec.attribute4 := p5_a45;
    ddp_qtev_rec.attribute5 := p5_a46;
    ddp_qtev_rec.attribute6 := p5_a47;
    ddp_qtev_rec.attribute7 := p5_a48;
    ddp_qtev_rec.attribute8 := p5_a49;
    ddp_qtev_rec.attribute9 := p5_a50;
    ddp_qtev_rec.attribute10 := p5_a51;
    ddp_qtev_rec.attribute11 := p5_a52;
    ddp_qtev_rec.attribute12 := p5_a53;
    ddp_qtev_rec.attribute13 := p5_a54;
    ddp_qtev_rec.attribute14 := p5_a55;
    ddp_qtev_rec.attribute15 := p5_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_qtev_rec.purchase_formula := p5_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_qtev_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_qtev_rec.currency_code := p5_a76;
    ddp_qtev_rec.currency_conversion_code := p5_a77;
    ddp_qtev_rec.currency_conversion_type := p5_a78;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_qtev_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_qtev_rec.repo_quote_indicator_yn := p5_a82;

    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_rec);

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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_DATE_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_200
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_VARCHAR2_TABLE_100
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_DATE_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qtev_tbl okl_qte_pvt.qtev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qte_pvt_w.rosetta_table_copy_in_p8(ddp_qtev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_tbl);

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
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  DATE
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
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  NUMBER
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  NUMBER
    , p6_a63 out nocopy  DATE
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  DATE
    , p6_a66 out nocopy  NUMBER
    , p6_a67 out nocopy  DATE
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p6_a76 out nocopy  VARCHAR2
    , p6_a77 out nocopy  VARCHAR2
    , p6_a78 out nocopy  VARCHAR2
    , p6_a79 out nocopy  NUMBER
    , p6_a80 out nocopy  DATE
    , p6_a81 out nocopy  NUMBER
    , p6_a82 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  DATE := fnd_api.g_miss_date
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_qtev_rec okl_qte_pvt.qtev_rec_type;
    ddx_qtev_rec okl_qte_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qtev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qtev_rec.sfwt_flag := p5_a2;
    ddp_qtev_rec.qrs_code := p5_a3;
    ddp_qtev_rec.qst_code := p5_a4;
    ddp_qtev_rec.qtp_code := p5_a5;
    ddp_qtev_rec.trn_code := p5_a6;
    ddp_qtev_rec.pop_code_end := p5_a7;
    ddp_qtev_rec.pop_code_early := p5_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_qtev_rec.early_termination_yn := p5_a13;
    ddp_qtev_rec.partial_yn := p5_a14;
    ddp_qtev_rec.preproceeds_yn := p5_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_qtev_rec.summary_format_yn := p5_a20;
    ddp_qtev_rec.consolidated_yn := p5_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_qtev_rec.comments := p5_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_qtev_rec.payment_frequency := p5_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_qtev_rec.approved_yn := p5_a37;
    ddp_qtev_rec.accepted_yn := p5_a38;
    ddp_qtev_rec.payment_received_yn := p5_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_qtev_rec.attribute_category := p5_a41;
    ddp_qtev_rec.attribute1 := p5_a42;
    ddp_qtev_rec.attribute2 := p5_a43;
    ddp_qtev_rec.attribute3 := p5_a44;
    ddp_qtev_rec.attribute4 := p5_a45;
    ddp_qtev_rec.attribute5 := p5_a46;
    ddp_qtev_rec.attribute6 := p5_a47;
    ddp_qtev_rec.attribute7 := p5_a48;
    ddp_qtev_rec.attribute8 := p5_a49;
    ddp_qtev_rec.attribute9 := p5_a50;
    ddp_qtev_rec.attribute10 := p5_a51;
    ddp_qtev_rec.attribute11 := p5_a52;
    ddp_qtev_rec.attribute12 := p5_a53;
    ddp_qtev_rec.attribute13 := p5_a54;
    ddp_qtev_rec.attribute14 := p5_a55;
    ddp_qtev_rec.attribute15 := p5_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_qtev_rec.purchase_formula := p5_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_qtev_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_qtev_rec.currency_code := p5_a76;
    ddp_qtev_rec.currency_conversion_code := p5_a77;
    ddp_qtev_rec.currency_conversion_type := p5_a78;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_qtev_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_qtev_rec.repo_quote_indicator_yn := p5_a82;


    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_rec,
      ddx_qtev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_qtev_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_qtev_rec.object_version_number);
    p6_a2 := ddx_qtev_rec.sfwt_flag;
    p6_a3 := ddx_qtev_rec.qrs_code;
    p6_a4 := ddx_qtev_rec.qst_code;
    p6_a5 := ddx_qtev_rec.qtp_code;
    p6_a6 := ddx_qtev_rec.trn_code;
    p6_a7 := ddx_qtev_rec.pop_code_end;
    p6_a8 := ddx_qtev_rec.pop_code_early;
    p6_a9 := rosetta_g_miss_num_map(ddx_qtev_rec.consolidated_qte_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_qtev_rec.khr_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_qtev_rec.art_id);
    p6_a12 := rosetta_g_miss_num_map(ddx_qtev_rec.pdt_id);
    p6_a13 := ddx_qtev_rec.early_termination_yn;
    p6_a14 := ddx_qtev_rec.partial_yn;
    p6_a15 := ddx_qtev_rec.preproceeds_yn;
    p6_a16 := ddx_qtev_rec.date_requested;
    p6_a17 := ddx_qtev_rec.date_proposal;
    p6_a18 := ddx_qtev_rec.date_effective_to;
    p6_a19 := ddx_qtev_rec.date_accepted;
    p6_a20 := ddx_qtev_rec.summary_format_yn;
    p6_a21 := ddx_qtev_rec.consolidated_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_qtev_rec.principal_paydown_amount);
    p6_a23 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_amount);
    p6_a24 := rosetta_g_miss_num_map(ddx_qtev_rec.yield);
    p6_a25 := rosetta_g_miss_num_map(ddx_qtev_rec.rent_amount);
    p6_a26 := ddx_qtev_rec.date_restructure_end;
    p6_a27 := ddx_qtev_rec.date_restructure_start;
    p6_a28 := rosetta_g_miss_num_map(ddx_qtev_rec.term);
    p6_a29 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_percent);
    p6_a30 := ddx_qtev_rec.comments;
    p6_a31 := ddx_qtev_rec.date_due;
    p6_a32 := ddx_qtev_rec.payment_frequency;
    p6_a33 := rosetta_g_miss_num_map(ddx_qtev_rec.remaining_payments);
    p6_a34 := ddx_qtev_rec.date_effective_from;
    p6_a35 := rosetta_g_miss_num_map(ddx_qtev_rec.quote_number);
    p6_a36 := rosetta_g_miss_num_map(ddx_qtev_rec.requested_by);
    p6_a37 := ddx_qtev_rec.approved_yn;
    p6_a38 := ddx_qtev_rec.accepted_yn;
    p6_a39 := ddx_qtev_rec.payment_received_yn;
    p6_a40 := ddx_qtev_rec.date_payment_received;
    p6_a41 := ddx_qtev_rec.attribute_category;
    p6_a42 := ddx_qtev_rec.attribute1;
    p6_a43 := ddx_qtev_rec.attribute2;
    p6_a44 := ddx_qtev_rec.attribute3;
    p6_a45 := ddx_qtev_rec.attribute4;
    p6_a46 := ddx_qtev_rec.attribute5;
    p6_a47 := ddx_qtev_rec.attribute6;
    p6_a48 := ddx_qtev_rec.attribute7;
    p6_a49 := ddx_qtev_rec.attribute8;
    p6_a50 := ddx_qtev_rec.attribute9;
    p6_a51 := ddx_qtev_rec.attribute10;
    p6_a52 := ddx_qtev_rec.attribute11;
    p6_a53 := ddx_qtev_rec.attribute12;
    p6_a54 := ddx_qtev_rec.attribute13;
    p6_a55 := ddx_qtev_rec.attribute14;
    p6_a56 := ddx_qtev_rec.attribute15;
    p6_a57 := ddx_qtev_rec.date_approved;
    p6_a58 := rosetta_g_miss_num_map(ddx_qtev_rec.approved_by);
    p6_a59 := rosetta_g_miss_num_map(ddx_qtev_rec.org_id);
    p6_a60 := rosetta_g_miss_num_map(ddx_qtev_rec.request_id);
    p6_a61 := rosetta_g_miss_num_map(ddx_qtev_rec.program_application_id);
    p6_a62 := rosetta_g_miss_num_map(ddx_qtev_rec.program_id);
    p6_a63 := ddx_qtev_rec.program_update_date;
    p6_a64 := rosetta_g_miss_num_map(ddx_qtev_rec.created_by);
    p6_a65 := ddx_qtev_rec.creation_date;
    p6_a66 := rosetta_g_miss_num_map(ddx_qtev_rec.last_updated_by);
    p6_a67 := ddx_qtev_rec.last_update_date;
    p6_a68 := rosetta_g_miss_num_map(ddx_qtev_rec.last_update_login);
    p6_a69 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_amount);
    p6_a70 := ddx_qtev_rec.purchase_formula;
    p6_a71 := rosetta_g_miss_num_map(ddx_qtev_rec.asset_value);
    p6_a72 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_value);
    p6_a73 := rosetta_g_miss_num_map(ddx_qtev_rec.unbilled_receivables);
    p6_a74 := rosetta_g_miss_num_map(ddx_qtev_rec.gain_loss);
    p6_a75 := rosetta_g_miss_num_map(ddx_qtev_rec.perdiem_amount);
    p6_a76 := ddx_qtev_rec.currency_code;
    p6_a77 := ddx_qtev_rec.currency_conversion_code;
    p6_a78 := ddx_qtev_rec.currency_conversion_type;
    p6_a79 := rosetta_g_miss_num_map(ddx_qtev_rec.currency_conversion_rate);
    p6_a80 := ddx_qtev_rec.currency_conversion_date;
    p6_a81 := rosetta_g_miss_num_map(ddx_qtev_rec.legal_entity_id);
    p6_a82 := ddx_qtev_rec.repo_quote_indicator_yn;
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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_DATE_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_200
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_VARCHAR2_TABLE_100
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_DATE_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_NUMBER_TABLE
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_DATE_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_DATE_TABLE
    , p6_a66 out nocopy JTF_NUMBER_TABLE
    , p6_a67 out nocopy JTF_DATE_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_NUMBER_TABLE
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a71 out nocopy JTF_NUMBER_TABLE
    , p6_a72 out nocopy JTF_NUMBER_TABLE
    , p6_a73 out nocopy JTF_NUMBER_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a78 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_DATE_TABLE
    , p6_a81 out nocopy JTF_NUMBER_TABLE
    , p6_a82 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qtev_tbl okl_qte_pvt.qtev_tbl_type;
    ddx_qtev_tbl okl_qte_pvt.qtev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qte_pvt_w.rosetta_table_copy_in_p8(ddp_qtev_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_tbl,
      ddx_qtev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qte_pvt_w.rosetta_table_copy_out_p8(ddx_qtev_tbl, p6_a0
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
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  DATE := fnd_api.g_miss_date
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_qtev_rec okl_qte_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qtev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qtev_rec.sfwt_flag := p5_a2;
    ddp_qtev_rec.qrs_code := p5_a3;
    ddp_qtev_rec.qst_code := p5_a4;
    ddp_qtev_rec.qtp_code := p5_a5;
    ddp_qtev_rec.trn_code := p5_a6;
    ddp_qtev_rec.pop_code_end := p5_a7;
    ddp_qtev_rec.pop_code_early := p5_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_qtev_rec.early_termination_yn := p5_a13;
    ddp_qtev_rec.partial_yn := p5_a14;
    ddp_qtev_rec.preproceeds_yn := p5_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_qtev_rec.summary_format_yn := p5_a20;
    ddp_qtev_rec.consolidated_yn := p5_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_qtev_rec.comments := p5_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_qtev_rec.payment_frequency := p5_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_qtev_rec.approved_yn := p5_a37;
    ddp_qtev_rec.accepted_yn := p5_a38;
    ddp_qtev_rec.payment_received_yn := p5_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_qtev_rec.attribute_category := p5_a41;
    ddp_qtev_rec.attribute1 := p5_a42;
    ddp_qtev_rec.attribute2 := p5_a43;
    ddp_qtev_rec.attribute3 := p5_a44;
    ddp_qtev_rec.attribute4 := p5_a45;
    ddp_qtev_rec.attribute5 := p5_a46;
    ddp_qtev_rec.attribute6 := p5_a47;
    ddp_qtev_rec.attribute7 := p5_a48;
    ddp_qtev_rec.attribute8 := p5_a49;
    ddp_qtev_rec.attribute9 := p5_a50;
    ddp_qtev_rec.attribute10 := p5_a51;
    ddp_qtev_rec.attribute11 := p5_a52;
    ddp_qtev_rec.attribute12 := p5_a53;
    ddp_qtev_rec.attribute13 := p5_a54;
    ddp_qtev_rec.attribute14 := p5_a55;
    ddp_qtev_rec.attribute15 := p5_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_qtev_rec.purchase_formula := p5_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_qtev_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_qtev_rec.currency_code := p5_a76;
    ddp_qtev_rec.currency_conversion_code := p5_a77;
    ddp_qtev_rec.currency_conversion_type := p5_a78;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_qtev_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_qtev_rec.repo_quote_indicator_yn := p5_a82;

    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_rec);

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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_DATE_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_200
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_VARCHAR2_TABLE_100
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_DATE_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qtev_tbl okl_qte_pvt.qtev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qte_pvt_w.rosetta_table_copy_in_p8(ddp_qtev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_tbl);

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
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  DATE := fnd_api.g_miss_date
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  NUMBER := 0-1962.0724
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  NUMBER := 0-1962.0724
    , p5_a62  NUMBER := 0-1962.0724
    , p5_a63  DATE := fnd_api.g_miss_date
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  DATE := fnd_api.g_miss_date
    , p5_a66  NUMBER := 0-1962.0724
    , p5_a67  DATE := fnd_api.g_miss_date
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  NUMBER := 0-1962.0724
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  NUMBER := 0-1962.0724
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  NUMBER := 0-1962.0724
    , p5_a80  DATE := fnd_api.g_miss_date
    , p5_a81  NUMBER := 0-1962.0724
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_qtev_rec okl_qte_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qtev_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qtev_rec.sfwt_flag := p5_a2;
    ddp_qtev_rec.qrs_code := p5_a3;
    ddp_qtev_rec.qst_code := p5_a4;
    ddp_qtev_rec.qtp_code := p5_a5;
    ddp_qtev_rec.trn_code := p5_a6;
    ddp_qtev_rec.pop_code_end := p5_a7;
    ddp_qtev_rec.pop_code_early := p5_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p5_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p5_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p5_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p5_a12);
    ddp_qtev_rec.early_termination_yn := p5_a13;
    ddp_qtev_rec.partial_yn := p5_a14;
    ddp_qtev_rec.preproceeds_yn := p5_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p5_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_qtev_rec.summary_format_yn := p5_a20;
    ddp_qtev_rec.consolidated_yn := p5_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p5_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p5_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p5_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p5_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p5_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p5_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p5_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p5_a29);
    ddp_qtev_rec.comments := p5_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p5_a31);
    ddp_qtev_rec.payment_frequency := p5_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p5_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p5_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p5_a36);
    ddp_qtev_rec.approved_yn := p5_a37;
    ddp_qtev_rec.accepted_yn := p5_a38;
    ddp_qtev_rec.payment_received_yn := p5_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p5_a40);
    ddp_qtev_rec.attribute_category := p5_a41;
    ddp_qtev_rec.attribute1 := p5_a42;
    ddp_qtev_rec.attribute2 := p5_a43;
    ddp_qtev_rec.attribute3 := p5_a44;
    ddp_qtev_rec.attribute4 := p5_a45;
    ddp_qtev_rec.attribute5 := p5_a46;
    ddp_qtev_rec.attribute6 := p5_a47;
    ddp_qtev_rec.attribute7 := p5_a48;
    ddp_qtev_rec.attribute8 := p5_a49;
    ddp_qtev_rec.attribute9 := p5_a50;
    ddp_qtev_rec.attribute10 := p5_a51;
    ddp_qtev_rec.attribute11 := p5_a52;
    ddp_qtev_rec.attribute12 := p5_a53;
    ddp_qtev_rec.attribute13 := p5_a54;
    ddp_qtev_rec.attribute14 := p5_a55;
    ddp_qtev_rec.attribute15 := p5_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p5_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p5_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p5_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p5_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p5_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p5_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p5_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p5_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p5_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p5_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p5_a69);
    ddp_qtev_rec.purchase_formula := p5_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p5_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p5_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p5_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p5_a74);
    ddp_qtev_rec.perdiem_amount := rosetta_g_miss_num_map(p5_a75);
    ddp_qtev_rec.currency_code := p5_a76;
    ddp_qtev_rec.currency_conversion_code := p5_a77;
    ddp_qtev_rec.currency_conversion_type := p5_a78;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a79);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a80);
    ddp_qtev_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a81);
    ddp_qtev_rec.repo_quote_indicator_yn := p5_a82;

    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_rec);

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
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_500
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_NUMBER_TABLE
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_NUMBER_TABLE
    , p5_a63 JTF_DATE_TABLE
    , p5_a64 JTF_NUMBER_TABLE
    , p5_a65 JTF_DATE_TABLE
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_DATE_TABLE
    , p5_a68 JTF_NUMBER_TABLE
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_200
    , p5_a71 JTF_NUMBER_TABLE
    , p5_a72 JTF_NUMBER_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_NUMBER_TABLE
    , p5_a75 JTF_NUMBER_TABLE
    , p5_a76 JTF_VARCHAR2_TABLE_100
    , p5_a77 JTF_VARCHAR2_TABLE_100
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_NUMBER_TABLE
    , p5_a80 JTF_DATE_TABLE
    , p5_a81 JTF_NUMBER_TABLE
    , p5_a82 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_qtev_tbl okl_qte_pvt.qtev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qte_pvt_w.rosetta_table_copy_in_p8(ddp_qtev_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_qte_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qtev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_qte_pvt_w;

/
