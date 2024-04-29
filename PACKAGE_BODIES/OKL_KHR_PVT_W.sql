--------------------------------------------------------
--  DDL for Package Body OKL_KHR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_KHR_PVT_W" as
  /* $Header: OKLIKHRB.pls 115.7 2002/12/20 19:17:39 avsingh noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_khr_pvt.khr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
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
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_DATE_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_DATE_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_DATE_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).isg_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).date_first_activity := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).syndicatable_yn := a6(indx);
          t(ddindx).salestype_yn := a7(indx);
          t(ddindx).date_refinanced := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).date_conversion_effective := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).date_deal_transferred := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).term_duration := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).datetime_proposal_effective := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).datetime_proposal_ineffective := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).date_proposal_accepted := rosetta_g_miss_date_in_map(a14(indx));
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
          t(ddindx).created_by := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a34(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).amd_code := a36(indx);
          t(ddindx).generate_accrual_yn := a37(indx);
          t(ddindx).generate_accrual_override_yn := a38(indx);
          t(ddindx).credit_act_yn := a39(indx);
          t(ddindx).converted_account_yn := a40(indx);
          t(ddindx).pre_tax_yield := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).after_tax_yield := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).implicit_interest_rate := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).implicit_non_idc_interest_rate := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).target_pre_tax_yield := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).target_after_tax_yield := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).target_implicit_interest_rate := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).target_implicit_nonidc_intrate := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).date_last_interim_interest_cal := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).deal_type := a50(indx);
          t(ddindx).pre_tax_irr := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).after_tax_irr := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).expected_delivery_date := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).accepted_date := rosetta_g_miss_date_in_map(a54(indx));
          t(ddindx).prefunding_eligible_yn := a55(indx);
          t(ddindx).revolving_credit_yn := a56(indx);
          t(ddindx).currency_conversion_type := a57(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a59(indx));
          t(ddindx).multi_gaap_yn := a60(indx);
          t(ddindx).recourse_code := a61(indx);
          t(ddindx).lessor_serv_org_code := a62(indx);
          t(ddindx).assignable_yn := a63(indx);
          t(ddindx).securitized_code := a64(indx);
          t(ddindx).securitization_type := a65(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_khr_pvt.khr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
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
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_DATE_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_DATE_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
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
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_DATE_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_DATE_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
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
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_DATE_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_DATE_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
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
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).isg_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := t(ddindx).date_first_activity;
          a6(indx) := t(ddindx).syndicatable_yn;
          a7(indx) := t(ddindx).salestype_yn;
          a8(indx) := t(ddindx).date_refinanced;
          a9(indx) := t(ddindx).date_conversion_effective;
          a10(indx) := t(ddindx).date_deal_transferred;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).term_duration);
          a12(indx) := t(ddindx).datetime_proposal_effective;
          a13(indx) := t(ddindx).datetime_proposal_ineffective;
          a14(indx) := t(ddindx).date_proposal_accepted;
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
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a32(indx) := t(ddindx).creation_date;
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a34(indx) := t(ddindx).last_update_date;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a36(indx) := t(ddindx).amd_code;
          a37(indx) := t(ddindx).generate_accrual_yn;
          a38(indx) := t(ddindx).generate_accrual_override_yn;
          a39(indx) := t(ddindx).credit_act_yn;
          a40(indx) := t(ddindx).converted_account_yn;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).pre_tax_yield);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).after_tax_yield);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_interest_rate);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_non_idc_interest_rate);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).target_pre_tax_yield);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).target_after_tax_yield);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).target_implicit_interest_rate);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).target_implicit_nonidc_intrate);
          a49(indx) := t(ddindx).date_last_interim_interest_cal;
          a50(indx) := t(ddindx).deal_type;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).pre_tax_irr);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).after_tax_irr);
          a53(indx) := t(ddindx).expected_delivery_date;
          a54(indx) := t(ddindx).accepted_date;
          a55(indx) := t(ddindx).prefunding_eligible_yn;
          a56(indx) := t(ddindx).revolving_credit_yn;
          a57(indx) := t(ddindx).currency_conversion_type;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a59(indx) := t(ddindx).currency_conversion_date;
          a60(indx) := t(ddindx).multi_gaap_yn;
          a61(indx) := t(ddindx).recourse_code;
          a62(indx) := t(ddindx).lessor_serv_org_code;
          a63(indx) := t(ddindx).assignable_yn;
          a64(indx) := t(ddindx).securitized_code;
          a65(indx) := t(ddindx).securitization_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_khr_pvt.okl_k_headers_h_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
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
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_DATE_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_DATE_TABLE
    , a55 JTF_DATE_TABLE
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_DATE_TABLE
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).isg_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).date_first_activity := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).syndicatable_yn := a7(indx);
          t(ddindx).salestype_yn := a8(indx);
          t(ddindx).date_refinanced := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).date_conversion_effective := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).date_deal_transferred := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).term_duration := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).datetime_proposal_effective := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).datetime_proposal_ineffective := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).date_proposal_accepted := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).attribute_category := a16(indx);
          t(ddindx).attribute1 := a17(indx);
          t(ddindx).attribute2 := a18(indx);
          t(ddindx).attribute3 := a19(indx);
          t(ddindx).attribute4 := a20(indx);
          t(ddindx).attribute5 := a21(indx);
          t(ddindx).attribute6 := a22(indx);
          t(ddindx).attribute7 := a23(indx);
          t(ddindx).attribute8 := a24(indx);
          t(ddindx).attribute9 := a25(indx);
          t(ddindx).attribute10 := a26(indx);
          t(ddindx).attribute11 := a27(indx);
          t(ddindx).attribute12 := a28(indx);
          t(ddindx).attribute13 := a29(indx);
          t(ddindx).attribute14 := a30(indx);
          t(ddindx).attribute15 := a31(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a35(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).amd_code := a37(indx);
          t(ddindx).generate_accrual_yn := a38(indx);
          t(ddindx).generate_accrual_override_yn := a39(indx);
          t(ddindx).credit_act_yn := a40(indx);
          t(ddindx).converted_account_yn := a41(indx);
          t(ddindx).pre_tax_yield := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).after_tax_yield := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).implicit_interest_rate := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).implicit_non_idc_interest_rate := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).target_pre_tax_yield := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).target_after_tax_yield := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).target_implicit_interest_rate := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).target_implicit_nonidc_intrate := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).date_last_interim_interest_cal := rosetta_g_miss_date_in_map(a50(indx));
          t(ddindx).deal_type := a51(indx);
          t(ddindx).pre_tax_irr := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).after_tax_irr := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).expected_delivery_date := rosetta_g_miss_date_in_map(a54(indx));
          t(ddindx).accepted_date := rosetta_g_miss_date_in_map(a55(indx));
          t(ddindx).prefunding_eligible_yn := a56(indx);
          t(ddindx).revolving_credit_yn := a57(indx);
          t(ddindx).currency_conversion_type := a58(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a59(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a60(indx));
          t(ddindx).multi_gaap_yn := a61(indx);
          t(ddindx).recourse_code := a62(indx);
          t(ddindx).lessor_serv_org_code := a63(indx);
          t(ddindx).assignable_yn := a64(indx);
          t(ddindx).securitized_code := a65(indx);
          t(ddindx).securitization_type := a66(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_khr_pvt.okl_k_headers_h_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_DATE_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_DATE_TABLE
    , a55 out nocopy JTF_DATE_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_DATE_TABLE
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
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
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_DATE_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_DATE_TABLE();
    a55 := JTF_DATE_TABLE();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_DATE_TABLE();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
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
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_DATE_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_DATE_TABLE();
      a55 := JTF_DATE_TABLE();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_DATE_TABLE();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).major_version);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).isg_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := t(ddindx).date_first_activity;
          a7(indx) := t(ddindx).syndicatable_yn;
          a8(indx) := t(ddindx).salestype_yn;
          a9(indx) := t(ddindx).date_refinanced;
          a10(indx) := t(ddindx).date_conversion_effective;
          a11(indx) := t(ddindx).date_deal_transferred;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).term_duration);
          a13(indx) := t(ddindx).datetime_proposal_effective;
          a14(indx) := t(ddindx).datetime_proposal_ineffective;
          a15(indx) := t(ddindx).date_proposal_accepted;
          a16(indx) := t(ddindx).attribute_category;
          a17(indx) := t(ddindx).attribute1;
          a18(indx) := t(ddindx).attribute2;
          a19(indx) := t(ddindx).attribute3;
          a20(indx) := t(ddindx).attribute4;
          a21(indx) := t(ddindx).attribute5;
          a22(indx) := t(ddindx).attribute6;
          a23(indx) := t(ddindx).attribute7;
          a24(indx) := t(ddindx).attribute8;
          a25(indx) := t(ddindx).attribute9;
          a26(indx) := t(ddindx).attribute10;
          a27(indx) := t(ddindx).attribute11;
          a28(indx) := t(ddindx).attribute12;
          a29(indx) := t(ddindx).attribute13;
          a30(indx) := t(ddindx).attribute14;
          a31(indx) := t(ddindx).attribute15;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a33(indx) := t(ddindx).creation_date;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a35(indx) := t(ddindx).last_update_date;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a37(indx) := t(ddindx).amd_code;
          a38(indx) := t(ddindx).generate_accrual_yn;
          a39(indx) := t(ddindx).generate_accrual_override_yn;
          a40(indx) := t(ddindx).credit_act_yn;
          a41(indx) := t(ddindx).converted_account_yn;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).pre_tax_yield);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).after_tax_yield);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_interest_rate);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_non_idc_interest_rate);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).target_pre_tax_yield);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).target_after_tax_yield);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).target_implicit_interest_rate);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).target_implicit_nonidc_intrate);
          a50(indx) := t(ddindx).date_last_interim_interest_cal;
          a51(indx) := t(ddindx).deal_type;
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).pre_tax_irr);
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).after_tax_irr);
          a54(indx) := t(ddindx).expected_delivery_date;
          a55(indx) := t(ddindx).accepted_date;
          a56(indx) := t(ddindx).prefunding_eligible_yn;
          a57(indx) := t(ddindx).revolving_credit_yn;
          a58(indx) := t(ddindx).currency_conversion_type;
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a60(indx) := t(ddindx).currency_conversion_date;
          a61(indx) := t(ddindx).multi_gaap_yn;
          a62(indx) := t(ddindx).recourse_code;
          a63(indx) := t(ddindx).lessor_serv_org_code;
          a64(indx) := t(ddindx).assignable_yn;
          a65(indx) := t(ddindx).securitized_code;
          a66(indx) := t(ddindx).securitization_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_khr_pvt.khrv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
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
    , a35 JTF_VARCHAR2_TABLE_500
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_DATE_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_DATE_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_DATE_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).isg_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).amd_code := a5(indx);
          t(ddindx).date_first_activity := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).generate_accrual_yn := a7(indx);
          t(ddindx).generate_accrual_override_yn := a8(indx);
          t(ddindx).date_refinanced := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).credit_act_yn := a10(indx);
          t(ddindx).term_duration := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).converted_account_yn := a12(indx);
          t(ddindx).date_conversion_effective := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).syndicatable_yn := a14(indx);
          t(ddindx).salestype_yn := a15(indx);
          t(ddindx).date_deal_transferred := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).datetime_proposal_effective := rosetta_g_miss_date_in_map(a17(indx));
          t(ddindx).datetime_proposal_ineffective := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).date_proposal_accepted := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).attribute_category := a20(indx);
          t(ddindx).attribute1 := a21(indx);
          t(ddindx).attribute2 := a22(indx);
          t(ddindx).attribute3 := a23(indx);
          t(ddindx).attribute4 := a24(indx);
          t(ddindx).attribute5 := a25(indx);
          t(ddindx).attribute6 := a26(indx);
          t(ddindx).attribute7 := a27(indx);
          t(ddindx).attribute8 := a28(indx);
          t(ddindx).attribute9 := a29(indx);
          t(ddindx).attribute10 := a30(indx);
          t(ddindx).attribute11 := a31(indx);
          t(ddindx).attribute12 := a32(indx);
          t(ddindx).attribute13 := a33(indx);
          t(ddindx).attribute14 := a34(indx);
          t(ddindx).attribute15 := a35(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a39(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).pre_tax_yield := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).after_tax_yield := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).implicit_interest_rate := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).implicit_non_idc_interest_rate := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).target_pre_tax_yield := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).target_after_tax_yield := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).target_implicit_interest_rate := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).target_implicit_nonidc_intrate := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).date_last_interim_interest_cal := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).deal_type := a50(indx);
          t(ddindx).pre_tax_irr := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).after_tax_irr := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).expected_delivery_date := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).accepted_date := rosetta_g_miss_date_in_map(a54(indx));
          t(ddindx).prefunding_eligible_yn := a55(indx);
          t(ddindx).revolving_credit_yn := a56(indx);
          t(ddindx).currency_conversion_type := a57(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a59(indx));
          t(ddindx).multi_gaap_yn := a60(indx);
          t(ddindx).recourse_code := a61(indx);
          t(ddindx).lessor_serv_org_code := a62(indx);
          t(ddindx).assignable_yn := a63(indx);
          t(ddindx).securitized_code := a64(indx);
          t(ddindx).securitization_type := a65(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_khr_pvt.khrv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_DATE_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_DATE_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
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
    a35 := JTF_VARCHAR2_TABLE_500();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_DATE_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_DATE_TABLE();
    a60 := JTF_VARCHAR2_TABLE_100();
    a61 := JTF_VARCHAR2_TABLE_100();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
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
      a35 := JTF_VARCHAR2_TABLE_500();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_DATE_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_DATE_TABLE();
      a60 := JTF_VARCHAR2_TABLE_100();
      a61 := JTF_VARCHAR2_TABLE_100();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
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
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).isg_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a5(indx) := t(ddindx).amd_code;
          a6(indx) := t(ddindx).date_first_activity;
          a7(indx) := t(ddindx).generate_accrual_yn;
          a8(indx) := t(ddindx).generate_accrual_override_yn;
          a9(indx) := t(ddindx).date_refinanced;
          a10(indx) := t(ddindx).credit_act_yn;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).term_duration);
          a12(indx) := t(ddindx).converted_account_yn;
          a13(indx) := t(ddindx).date_conversion_effective;
          a14(indx) := t(ddindx).syndicatable_yn;
          a15(indx) := t(ddindx).salestype_yn;
          a16(indx) := t(ddindx).date_deal_transferred;
          a17(indx) := t(ddindx).datetime_proposal_effective;
          a18(indx) := t(ddindx).datetime_proposal_ineffective;
          a19(indx) := t(ddindx).date_proposal_accepted;
          a20(indx) := t(ddindx).attribute_category;
          a21(indx) := t(ddindx).attribute1;
          a22(indx) := t(ddindx).attribute2;
          a23(indx) := t(ddindx).attribute3;
          a24(indx) := t(ddindx).attribute4;
          a25(indx) := t(ddindx).attribute5;
          a26(indx) := t(ddindx).attribute6;
          a27(indx) := t(ddindx).attribute7;
          a28(indx) := t(ddindx).attribute8;
          a29(indx) := t(ddindx).attribute9;
          a30(indx) := t(ddindx).attribute10;
          a31(indx) := t(ddindx).attribute11;
          a32(indx) := t(ddindx).attribute12;
          a33(indx) := t(ddindx).attribute13;
          a34(indx) := t(ddindx).attribute14;
          a35(indx) := t(ddindx).attribute15;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a37(indx) := t(ddindx).creation_date;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a39(indx) := t(ddindx).last_update_date;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).pre_tax_yield);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).after_tax_yield);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_interest_rate);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_non_idc_interest_rate);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).target_pre_tax_yield);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).target_after_tax_yield);
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).target_implicit_interest_rate);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).target_implicit_nonidc_intrate);
          a49(indx) := t(ddindx).date_last_interim_interest_cal;
          a50(indx) := t(ddindx).deal_type;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).pre_tax_irr);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).after_tax_irr);
          a53(indx) := t(ddindx).expected_delivery_date;
          a54(indx) := t(ddindx).accepted_date;
          a55(indx) := t(ddindx).prefunding_eligible_yn;
          a56(indx) := t(ddindx).revolving_credit_yn;
          a57(indx) := t(ddindx).currency_conversion_type;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a59(indx) := t(ddindx).currency_conversion_date;
          a60(indx) := t(ddindx).multi_gaap_yn;
          a61(indx) := t(ddindx).recourse_code;
          a62(indx) := t(ddindx).lessor_serv_org_code;
          a63(indx) := t(ddindx).assignable_yn;
          a64(indx) := t(ddindx).securitized_code;
          a65(indx) := t(ddindx).securitization_type;
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
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  DATE
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
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  DATE
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
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
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  DATE := fnd_api.g_miss_date
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_khrv_rec okl_khr_pvt.khrv_rec_type;
    ddx_khrv_rec okl_khr_pvt.khrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_khrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_khrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_khrv_rec.isg_id := rosetta_g_miss_num_map(p5_a2);
    ddp_khrv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_khrv_rec.pdt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_khrv_rec.amd_code := p5_a5;
    ddp_khrv_rec.date_first_activity := rosetta_g_miss_date_in_map(p5_a6);
    ddp_khrv_rec.generate_accrual_yn := p5_a7;
    ddp_khrv_rec.generate_accrual_override_yn := p5_a8;
    ddp_khrv_rec.date_refinanced := rosetta_g_miss_date_in_map(p5_a9);
    ddp_khrv_rec.credit_act_yn := p5_a10;
    ddp_khrv_rec.term_duration := rosetta_g_miss_num_map(p5_a11);
    ddp_khrv_rec.converted_account_yn := p5_a12;
    ddp_khrv_rec.date_conversion_effective := rosetta_g_miss_date_in_map(p5_a13);
    ddp_khrv_rec.syndicatable_yn := p5_a14;
    ddp_khrv_rec.salestype_yn := p5_a15;
    ddp_khrv_rec.date_deal_transferred := rosetta_g_miss_date_in_map(p5_a16);
    ddp_khrv_rec.datetime_proposal_effective := rosetta_g_miss_date_in_map(p5_a17);
    ddp_khrv_rec.datetime_proposal_ineffective := rosetta_g_miss_date_in_map(p5_a18);
    ddp_khrv_rec.date_proposal_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_khrv_rec.attribute_category := p5_a20;
    ddp_khrv_rec.attribute1 := p5_a21;
    ddp_khrv_rec.attribute2 := p5_a22;
    ddp_khrv_rec.attribute3 := p5_a23;
    ddp_khrv_rec.attribute4 := p5_a24;
    ddp_khrv_rec.attribute5 := p5_a25;
    ddp_khrv_rec.attribute6 := p5_a26;
    ddp_khrv_rec.attribute7 := p5_a27;
    ddp_khrv_rec.attribute8 := p5_a28;
    ddp_khrv_rec.attribute9 := p5_a29;
    ddp_khrv_rec.attribute10 := p5_a30;
    ddp_khrv_rec.attribute11 := p5_a31;
    ddp_khrv_rec.attribute12 := p5_a32;
    ddp_khrv_rec.attribute13 := p5_a33;
    ddp_khrv_rec.attribute14 := p5_a34;
    ddp_khrv_rec.attribute15 := p5_a35;
    ddp_khrv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_khrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_khrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_khrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_khrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_khrv_rec.pre_tax_yield := rosetta_g_miss_num_map(p5_a41);
    ddp_khrv_rec.after_tax_yield := rosetta_g_miss_num_map(p5_a42);
    ddp_khrv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a43);
    ddp_khrv_rec.implicit_non_idc_interest_rate := rosetta_g_miss_num_map(p5_a44);
    ddp_khrv_rec.target_pre_tax_yield := rosetta_g_miss_num_map(p5_a45);
    ddp_khrv_rec.target_after_tax_yield := rosetta_g_miss_num_map(p5_a46);
    ddp_khrv_rec.target_implicit_interest_rate := rosetta_g_miss_num_map(p5_a47);
    ddp_khrv_rec.target_implicit_nonidc_intrate := rosetta_g_miss_num_map(p5_a48);
    ddp_khrv_rec.date_last_interim_interest_cal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_khrv_rec.deal_type := p5_a50;
    ddp_khrv_rec.pre_tax_irr := rosetta_g_miss_num_map(p5_a51);
    ddp_khrv_rec.after_tax_irr := rosetta_g_miss_num_map(p5_a52);
    ddp_khrv_rec.expected_delivery_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_khrv_rec.accepted_date := rosetta_g_miss_date_in_map(p5_a54);
    ddp_khrv_rec.prefunding_eligible_yn := p5_a55;
    ddp_khrv_rec.revolving_credit_yn := p5_a56;
    ddp_khrv_rec.currency_conversion_type := p5_a57;
    ddp_khrv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_khrv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_khrv_rec.multi_gaap_yn := p5_a60;
    ddp_khrv_rec.recourse_code := p5_a61;
    ddp_khrv_rec.lessor_serv_org_code := p5_a62;
    ddp_khrv_rec.assignable_yn := p5_a63;
    ddp_khrv_rec.securitized_code := p5_a64;
    ddp_khrv_rec.securitization_type := p5_a65;


    -- here's the delegated call to the old PL/SQL routine
    okl_khr_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_rec,
      ddx_khrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_khrv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_khrv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_khrv_rec.isg_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_khrv_rec.khr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_khrv_rec.pdt_id);
    p6_a5 := ddx_khrv_rec.amd_code;
    p6_a6 := ddx_khrv_rec.date_first_activity;
    p6_a7 := ddx_khrv_rec.generate_accrual_yn;
    p6_a8 := ddx_khrv_rec.generate_accrual_override_yn;
    p6_a9 := ddx_khrv_rec.date_refinanced;
    p6_a10 := ddx_khrv_rec.credit_act_yn;
    p6_a11 := rosetta_g_miss_num_map(ddx_khrv_rec.term_duration);
    p6_a12 := ddx_khrv_rec.converted_account_yn;
    p6_a13 := ddx_khrv_rec.date_conversion_effective;
    p6_a14 := ddx_khrv_rec.syndicatable_yn;
    p6_a15 := ddx_khrv_rec.salestype_yn;
    p6_a16 := ddx_khrv_rec.date_deal_transferred;
    p6_a17 := ddx_khrv_rec.datetime_proposal_effective;
    p6_a18 := ddx_khrv_rec.datetime_proposal_ineffective;
    p6_a19 := ddx_khrv_rec.date_proposal_accepted;
    p6_a20 := ddx_khrv_rec.attribute_category;
    p6_a21 := ddx_khrv_rec.attribute1;
    p6_a22 := ddx_khrv_rec.attribute2;
    p6_a23 := ddx_khrv_rec.attribute3;
    p6_a24 := ddx_khrv_rec.attribute4;
    p6_a25 := ddx_khrv_rec.attribute5;
    p6_a26 := ddx_khrv_rec.attribute6;
    p6_a27 := ddx_khrv_rec.attribute7;
    p6_a28 := ddx_khrv_rec.attribute8;
    p6_a29 := ddx_khrv_rec.attribute9;
    p6_a30 := ddx_khrv_rec.attribute10;
    p6_a31 := ddx_khrv_rec.attribute11;
    p6_a32 := ddx_khrv_rec.attribute12;
    p6_a33 := ddx_khrv_rec.attribute13;
    p6_a34 := ddx_khrv_rec.attribute14;
    p6_a35 := ddx_khrv_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddx_khrv_rec.created_by);
    p6_a37 := ddx_khrv_rec.creation_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_khrv_rec.last_updated_by);
    p6_a39 := ddx_khrv_rec.last_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_khrv_rec.last_update_login);
    p6_a41 := rosetta_g_miss_num_map(ddx_khrv_rec.pre_tax_yield);
    p6_a42 := rosetta_g_miss_num_map(ddx_khrv_rec.after_tax_yield);
    p6_a43 := rosetta_g_miss_num_map(ddx_khrv_rec.implicit_interest_rate);
    p6_a44 := rosetta_g_miss_num_map(ddx_khrv_rec.implicit_non_idc_interest_rate);
    p6_a45 := rosetta_g_miss_num_map(ddx_khrv_rec.target_pre_tax_yield);
    p6_a46 := rosetta_g_miss_num_map(ddx_khrv_rec.target_after_tax_yield);
    p6_a47 := rosetta_g_miss_num_map(ddx_khrv_rec.target_implicit_interest_rate);
    p6_a48 := rosetta_g_miss_num_map(ddx_khrv_rec.target_implicit_nonidc_intrate);
    p6_a49 := ddx_khrv_rec.date_last_interim_interest_cal;
    p6_a50 := ddx_khrv_rec.deal_type;
    p6_a51 := rosetta_g_miss_num_map(ddx_khrv_rec.pre_tax_irr);
    p6_a52 := rosetta_g_miss_num_map(ddx_khrv_rec.after_tax_irr);
    p6_a53 := ddx_khrv_rec.expected_delivery_date;
    p6_a54 := ddx_khrv_rec.accepted_date;
    p6_a55 := ddx_khrv_rec.prefunding_eligible_yn;
    p6_a56 := ddx_khrv_rec.revolving_credit_yn;
    p6_a57 := ddx_khrv_rec.currency_conversion_type;
    p6_a58 := rosetta_g_miss_num_map(ddx_khrv_rec.currency_conversion_rate);
    p6_a59 := ddx_khrv_rec.currency_conversion_date;
    p6_a60 := ddx_khrv_rec.multi_gaap_yn;
    p6_a61 := ddx_khrv_rec.recourse_code;
    p6_a62 := ddx_khrv_rec.lessor_serv_org_code;
    p6_a63 := ddx_khrv_rec.assignable_yn;
    p6_a64 := ddx_khrv_rec.securitized_code;
    p6_a65 := ddx_khrv_rec.securitization_type;
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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
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
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_DATE_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_DATE_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_khrv_tbl okl_khr_pvt.khrv_tbl_type;
    ddx_khrv_tbl okl_khr_pvt.khrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_khr_pvt_w.rosetta_table_copy_in_p8(ddp_khrv_tbl, p5_a0
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
    okl_khr_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_tbl,
      ddx_khrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_khr_pvt_w.rosetta_table_copy_out_p8(ddx_khrv_tbl, p6_a0
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

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  DATE
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
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  DATE
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  DATE
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
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
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  DATE := fnd_api.g_miss_date
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_khrv_rec okl_khr_pvt.khrv_rec_type;
    ddx_khrv_rec okl_khr_pvt.khrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_khrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_khrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_khrv_rec.isg_id := rosetta_g_miss_num_map(p5_a2);
    ddp_khrv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_khrv_rec.pdt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_khrv_rec.amd_code := p5_a5;
    ddp_khrv_rec.date_first_activity := rosetta_g_miss_date_in_map(p5_a6);
    ddp_khrv_rec.generate_accrual_yn := p5_a7;
    ddp_khrv_rec.generate_accrual_override_yn := p5_a8;
    ddp_khrv_rec.date_refinanced := rosetta_g_miss_date_in_map(p5_a9);
    ddp_khrv_rec.credit_act_yn := p5_a10;
    ddp_khrv_rec.term_duration := rosetta_g_miss_num_map(p5_a11);
    ddp_khrv_rec.converted_account_yn := p5_a12;
    ddp_khrv_rec.date_conversion_effective := rosetta_g_miss_date_in_map(p5_a13);
    ddp_khrv_rec.syndicatable_yn := p5_a14;
    ddp_khrv_rec.salestype_yn := p5_a15;
    ddp_khrv_rec.date_deal_transferred := rosetta_g_miss_date_in_map(p5_a16);
    ddp_khrv_rec.datetime_proposal_effective := rosetta_g_miss_date_in_map(p5_a17);
    ddp_khrv_rec.datetime_proposal_ineffective := rosetta_g_miss_date_in_map(p5_a18);
    ddp_khrv_rec.date_proposal_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_khrv_rec.attribute_category := p5_a20;
    ddp_khrv_rec.attribute1 := p5_a21;
    ddp_khrv_rec.attribute2 := p5_a22;
    ddp_khrv_rec.attribute3 := p5_a23;
    ddp_khrv_rec.attribute4 := p5_a24;
    ddp_khrv_rec.attribute5 := p5_a25;
    ddp_khrv_rec.attribute6 := p5_a26;
    ddp_khrv_rec.attribute7 := p5_a27;
    ddp_khrv_rec.attribute8 := p5_a28;
    ddp_khrv_rec.attribute9 := p5_a29;
    ddp_khrv_rec.attribute10 := p5_a30;
    ddp_khrv_rec.attribute11 := p5_a31;
    ddp_khrv_rec.attribute12 := p5_a32;
    ddp_khrv_rec.attribute13 := p5_a33;
    ddp_khrv_rec.attribute14 := p5_a34;
    ddp_khrv_rec.attribute15 := p5_a35;
    ddp_khrv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_khrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_khrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_khrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_khrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_khrv_rec.pre_tax_yield := rosetta_g_miss_num_map(p5_a41);
    ddp_khrv_rec.after_tax_yield := rosetta_g_miss_num_map(p5_a42);
    ddp_khrv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a43);
    ddp_khrv_rec.implicit_non_idc_interest_rate := rosetta_g_miss_num_map(p5_a44);
    ddp_khrv_rec.target_pre_tax_yield := rosetta_g_miss_num_map(p5_a45);
    ddp_khrv_rec.target_after_tax_yield := rosetta_g_miss_num_map(p5_a46);
    ddp_khrv_rec.target_implicit_interest_rate := rosetta_g_miss_num_map(p5_a47);
    ddp_khrv_rec.target_implicit_nonidc_intrate := rosetta_g_miss_num_map(p5_a48);
    ddp_khrv_rec.date_last_interim_interest_cal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_khrv_rec.deal_type := p5_a50;
    ddp_khrv_rec.pre_tax_irr := rosetta_g_miss_num_map(p5_a51);
    ddp_khrv_rec.after_tax_irr := rosetta_g_miss_num_map(p5_a52);
    ddp_khrv_rec.expected_delivery_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_khrv_rec.accepted_date := rosetta_g_miss_date_in_map(p5_a54);
    ddp_khrv_rec.prefunding_eligible_yn := p5_a55;
    ddp_khrv_rec.revolving_credit_yn := p5_a56;
    ddp_khrv_rec.currency_conversion_type := p5_a57;
    ddp_khrv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_khrv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_khrv_rec.multi_gaap_yn := p5_a60;
    ddp_khrv_rec.recourse_code := p5_a61;
    ddp_khrv_rec.lessor_serv_org_code := p5_a62;
    ddp_khrv_rec.assignable_yn := p5_a63;
    ddp_khrv_rec.securitized_code := p5_a64;
    ddp_khrv_rec.securitization_type := p5_a65;


    -- here's the delegated call to the old PL/SQL routine
    okl_khr_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_rec,
      ddx_khrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_khrv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_khrv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_khrv_rec.isg_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_khrv_rec.khr_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_khrv_rec.pdt_id);
    p6_a5 := ddx_khrv_rec.amd_code;
    p6_a6 := ddx_khrv_rec.date_first_activity;
    p6_a7 := ddx_khrv_rec.generate_accrual_yn;
    p6_a8 := ddx_khrv_rec.generate_accrual_override_yn;
    p6_a9 := ddx_khrv_rec.date_refinanced;
    p6_a10 := ddx_khrv_rec.credit_act_yn;
    p6_a11 := rosetta_g_miss_num_map(ddx_khrv_rec.term_duration);
    p6_a12 := ddx_khrv_rec.converted_account_yn;
    p6_a13 := ddx_khrv_rec.date_conversion_effective;
    p6_a14 := ddx_khrv_rec.syndicatable_yn;
    p6_a15 := ddx_khrv_rec.salestype_yn;
    p6_a16 := ddx_khrv_rec.date_deal_transferred;
    p6_a17 := ddx_khrv_rec.datetime_proposal_effective;
    p6_a18 := ddx_khrv_rec.datetime_proposal_ineffective;
    p6_a19 := ddx_khrv_rec.date_proposal_accepted;
    p6_a20 := ddx_khrv_rec.attribute_category;
    p6_a21 := ddx_khrv_rec.attribute1;
    p6_a22 := ddx_khrv_rec.attribute2;
    p6_a23 := ddx_khrv_rec.attribute3;
    p6_a24 := ddx_khrv_rec.attribute4;
    p6_a25 := ddx_khrv_rec.attribute5;
    p6_a26 := ddx_khrv_rec.attribute6;
    p6_a27 := ddx_khrv_rec.attribute7;
    p6_a28 := ddx_khrv_rec.attribute8;
    p6_a29 := ddx_khrv_rec.attribute9;
    p6_a30 := ddx_khrv_rec.attribute10;
    p6_a31 := ddx_khrv_rec.attribute11;
    p6_a32 := ddx_khrv_rec.attribute12;
    p6_a33 := ddx_khrv_rec.attribute13;
    p6_a34 := ddx_khrv_rec.attribute14;
    p6_a35 := ddx_khrv_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddx_khrv_rec.created_by);
    p6_a37 := ddx_khrv_rec.creation_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_khrv_rec.last_updated_by);
    p6_a39 := ddx_khrv_rec.last_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_khrv_rec.last_update_login);
    p6_a41 := rosetta_g_miss_num_map(ddx_khrv_rec.pre_tax_yield);
    p6_a42 := rosetta_g_miss_num_map(ddx_khrv_rec.after_tax_yield);
    p6_a43 := rosetta_g_miss_num_map(ddx_khrv_rec.implicit_interest_rate);
    p6_a44 := rosetta_g_miss_num_map(ddx_khrv_rec.implicit_non_idc_interest_rate);
    p6_a45 := rosetta_g_miss_num_map(ddx_khrv_rec.target_pre_tax_yield);
    p6_a46 := rosetta_g_miss_num_map(ddx_khrv_rec.target_after_tax_yield);
    p6_a47 := rosetta_g_miss_num_map(ddx_khrv_rec.target_implicit_interest_rate);
    p6_a48 := rosetta_g_miss_num_map(ddx_khrv_rec.target_implicit_nonidc_intrate);
    p6_a49 := ddx_khrv_rec.date_last_interim_interest_cal;
    p6_a50 := ddx_khrv_rec.deal_type;
    p6_a51 := rosetta_g_miss_num_map(ddx_khrv_rec.pre_tax_irr);
    p6_a52 := rosetta_g_miss_num_map(ddx_khrv_rec.after_tax_irr);
    p6_a53 := ddx_khrv_rec.expected_delivery_date;
    p6_a54 := ddx_khrv_rec.accepted_date;
    p6_a55 := ddx_khrv_rec.prefunding_eligible_yn;
    p6_a56 := ddx_khrv_rec.revolving_credit_yn;
    p6_a57 := ddx_khrv_rec.currency_conversion_type;
    p6_a58 := rosetta_g_miss_num_map(ddx_khrv_rec.currency_conversion_rate);
    p6_a59 := ddx_khrv_rec.currency_conversion_date;
    p6_a60 := ddx_khrv_rec.multi_gaap_yn;
    p6_a61 := ddx_khrv_rec.recourse_code;
    p6_a62 := ddx_khrv_rec.lessor_serv_org_code;
    p6_a63 := ddx_khrv_rec.assignable_yn;
    p6_a64 := ddx_khrv_rec.securitized_code;
    p6_a65 := ddx_khrv_rec.securitization_type;
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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
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
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_DATE_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_DATE_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_DATE_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_DATE_TABLE
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_khrv_tbl okl_khr_pvt.khrv_tbl_type;
    ddx_khrv_tbl okl_khr_pvt.khrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_khr_pvt_w.rosetta_table_copy_in_p8(ddp_khrv_tbl, p5_a0
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
    okl_khr_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_tbl,
      ddx_khrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_khr_pvt_w.rosetta_table_copy_out_p8(ddx_khrv_tbl, p6_a0
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
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
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
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  DATE := fnd_api.g_miss_date
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_khrv_rec okl_khr_pvt.khrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_khrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_khrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_khrv_rec.isg_id := rosetta_g_miss_num_map(p5_a2);
    ddp_khrv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_khrv_rec.pdt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_khrv_rec.amd_code := p5_a5;
    ddp_khrv_rec.date_first_activity := rosetta_g_miss_date_in_map(p5_a6);
    ddp_khrv_rec.generate_accrual_yn := p5_a7;
    ddp_khrv_rec.generate_accrual_override_yn := p5_a8;
    ddp_khrv_rec.date_refinanced := rosetta_g_miss_date_in_map(p5_a9);
    ddp_khrv_rec.credit_act_yn := p5_a10;
    ddp_khrv_rec.term_duration := rosetta_g_miss_num_map(p5_a11);
    ddp_khrv_rec.converted_account_yn := p5_a12;
    ddp_khrv_rec.date_conversion_effective := rosetta_g_miss_date_in_map(p5_a13);
    ddp_khrv_rec.syndicatable_yn := p5_a14;
    ddp_khrv_rec.salestype_yn := p5_a15;
    ddp_khrv_rec.date_deal_transferred := rosetta_g_miss_date_in_map(p5_a16);
    ddp_khrv_rec.datetime_proposal_effective := rosetta_g_miss_date_in_map(p5_a17);
    ddp_khrv_rec.datetime_proposal_ineffective := rosetta_g_miss_date_in_map(p5_a18);
    ddp_khrv_rec.date_proposal_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_khrv_rec.attribute_category := p5_a20;
    ddp_khrv_rec.attribute1 := p5_a21;
    ddp_khrv_rec.attribute2 := p5_a22;
    ddp_khrv_rec.attribute3 := p5_a23;
    ddp_khrv_rec.attribute4 := p5_a24;
    ddp_khrv_rec.attribute5 := p5_a25;
    ddp_khrv_rec.attribute6 := p5_a26;
    ddp_khrv_rec.attribute7 := p5_a27;
    ddp_khrv_rec.attribute8 := p5_a28;
    ddp_khrv_rec.attribute9 := p5_a29;
    ddp_khrv_rec.attribute10 := p5_a30;
    ddp_khrv_rec.attribute11 := p5_a31;
    ddp_khrv_rec.attribute12 := p5_a32;
    ddp_khrv_rec.attribute13 := p5_a33;
    ddp_khrv_rec.attribute14 := p5_a34;
    ddp_khrv_rec.attribute15 := p5_a35;
    ddp_khrv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_khrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_khrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_khrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_khrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_khrv_rec.pre_tax_yield := rosetta_g_miss_num_map(p5_a41);
    ddp_khrv_rec.after_tax_yield := rosetta_g_miss_num_map(p5_a42);
    ddp_khrv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a43);
    ddp_khrv_rec.implicit_non_idc_interest_rate := rosetta_g_miss_num_map(p5_a44);
    ddp_khrv_rec.target_pre_tax_yield := rosetta_g_miss_num_map(p5_a45);
    ddp_khrv_rec.target_after_tax_yield := rosetta_g_miss_num_map(p5_a46);
    ddp_khrv_rec.target_implicit_interest_rate := rosetta_g_miss_num_map(p5_a47);
    ddp_khrv_rec.target_implicit_nonidc_intrate := rosetta_g_miss_num_map(p5_a48);
    ddp_khrv_rec.date_last_interim_interest_cal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_khrv_rec.deal_type := p5_a50;
    ddp_khrv_rec.pre_tax_irr := rosetta_g_miss_num_map(p5_a51);
    ddp_khrv_rec.after_tax_irr := rosetta_g_miss_num_map(p5_a52);
    ddp_khrv_rec.expected_delivery_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_khrv_rec.accepted_date := rosetta_g_miss_date_in_map(p5_a54);
    ddp_khrv_rec.prefunding_eligible_yn := p5_a55;
    ddp_khrv_rec.revolving_credit_yn := p5_a56;
    ddp_khrv_rec.currency_conversion_type := p5_a57;
    ddp_khrv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_khrv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_khrv_rec.multi_gaap_yn := p5_a60;
    ddp_khrv_rec.recourse_code := p5_a61;
    ddp_khrv_rec.lessor_serv_org_code := p5_a62;
    ddp_khrv_rec.assignable_yn := p5_a63;
    ddp_khrv_rec.securitized_code := p5_a64;
    ddp_khrv_rec.securitization_type := p5_a65;

    -- here's the delegated call to the old PL/SQL routine
    okl_khr_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
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
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_DATE_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_khrv_tbl okl_khr_pvt.khrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_khr_pvt_w.rosetta_table_copy_in_p8(ddp_khrv_tbl, p5_a0
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
    okl_khr_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_tbl);

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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
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
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  DATE := fnd_api.g_miss_date
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_khrv_rec okl_khr_pvt.khrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_khrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_khrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_khrv_rec.isg_id := rosetta_g_miss_num_map(p5_a2);
    ddp_khrv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_khrv_rec.pdt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_khrv_rec.amd_code := p5_a5;
    ddp_khrv_rec.date_first_activity := rosetta_g_miss_date_in_map(p5_a6);
    ddp_khrv_rec.generate_accrual_yn := p5_a7;
    ddp_khrv_rec.generate_accrual_override_yn := p5_a8;
    ddp_khrv_rec.date_refinanced := rosetta_g_miss_date_in_map(p5_a9);
    ddp_khrv_rec.credit_act_yn := p5_a10;
    ddp_khrv_rec.term_duration := rosetta_g_miss_num_map(p5_a11);
    ddp_khrv_rec.converted_account_yn := p5_a12;
    ddp_khrv_rec.date_conversion_effective := rosetta_g_miss_date_in_map(p5_a13);
    ddp_khrv_rec.syndicatable_yn := p5_a14;
    ddp_khrv_rec.salestype_yn := p5_a15;
    ddp_khrv_rec.date_deal_transferred := rosetta_g_miss_date_in_map(p5_a16);
    ddp_khrv_rec.datetime_proposal_effective := rosetta_g_miss_date_in_map(p5_a17);
    ddp_khrv_rec.datetime_proposal_ineffective := rosetta_g_miss_date_in_map(p5_a18);
    ddp_khrv_rec.date_proposal_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_khrv_rec.attribute_category := p5_a20;
    ddp_khrv_rec.attribute1 := p5_a21;
    ddp_khrv_rec.attribute2 := p5_a22;
    ddp_khrv_rec.attribute3 := p5_a23;
    ddp_khrv_rec.attribute4 := p5_a24;
    ddp_khrv_rec.attribute5 := p5_a25;
    ddp_khrv_rec.attribute6 := p5_a26;
    ddp_khrv_rec.attribute7 := p5_a27;
    ddp_khrv_rec.attribute8 := p5_a28;
    ddp_khrv_rec.attribute9 := p5_a29;
    ddp_khrv_rec.attribute10 := p5_a30;
    ddp_khrv_rec.attribute11 := p5_a31;
    ddp_khrv_rec.attribute12 := p5_a32;
    ddp_khrv_rec.attribute13 := p5_a33;
    ddp_khrv_rec.attribute14 := p5_a34;
    ddp_khrv_rec.attribute15 := p5_a35;
    ddp_khrv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_khrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_khrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_khrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_khrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_khrv_rec.pre_tax_yield := rosetta_g_miss_num_map(p5_a41);
    ddp_khrv_rec.after_tax_yield := rosetta_g_miss_num_map(p5_a42);
    ddp_khrv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a43);
    ddp_khrv_rec.implicit_non_idc_interest_rate := rosetta_g_miss_num_map(p5_a44);
    ddp_khrv_rec.target_pre_tax_yield := rosetta_g_miss_num_map(p5_a45);
    ddp_khrv_rec.target_after_tax_yield := rosetta_g_miss_num_map(p5_a46);
    ddp_khrv_rec.target_implicit_interest_rate := rosetta_g_miss_num_map(p5_a47);
    ddp_khrv_rec.target_implicit_nonidc_intrate := rosetta_g_miss_num_map(p5_a48);
    ddp_khrv_rec.date_last_interim_interest_cal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_khrv_rec.deal_type := p5_a50;
    ddp_khrv_rec.pre_tax_irr := rosetta_g_miss_num_map(p5_a51);
    ddp_khrv_rec.after_tax_irr := rosetta_g_miss_num_map(p5_a52);
    ddp_khrv_rec.expected_delivery_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_khrv_rec.accepted_date := rosetta_g_miss_date_in_map(p5_a54);
    ddp_khrv_rec.prefunding_eligible_yn := p5_a55;
    ddp_khrv_rec.revolving_credit_yn := p5_a56;
    ddp_khrv_rec.currency_conversion_type := p5_a57;
    ddp_khrv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_khrv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_khrv_rec.multi_gaap_yn := p5_a60;
    ddp_khrv_rec.recourse_code := p5_a61;
    ddp_khrv_rec.lessor_serv_org_code := p5_a62;
    ddp_khrv_rec.assignable_yn := p5_a63;
    ddp_khrv_rec.securitized_code := p5_a64;
    ddp_khrv_rec.securitization_type := p5_a65;

    -- here's the delegated call to the old PL/SQL routine
    okl_khr_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
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
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_DATE_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_khrv_tbl okl_khr_pvt.khrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_khr_pvt_w.rosetta_table_copy_in_p8(ddp_khrv_tbl, p5_a0
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
    okl_khr_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_tbl);

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
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  DATE := fnd_api.g_miss_date
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
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  DATE := fnd_api.g_miss_date
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  DATE := fnd_api.g_miss_date
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_khrv_rec okl_khr_pvt.khrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_khrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_khrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_khrv_rec.isg_id := rosetta_g_miss_num_map(p5_a2);
    ddp_khrv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_khrv_rec.pdt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_khrv_rec.amd_code := p5_a5;
    ddp_khrv_rec.date_first_activity := rosetta_g_miss_date_in_map(p5_a6);
    ddp_khrv_rec.generate_accrual_yn := p5_a7;
    ddp_khrv_rec.generate_accrual_override_yn := p5_a8;
    ddp_khrv_rec.date_refinanced := rosetta_g_miss_date_in_map(p5_a9);
    ddp_khrv_rec.credit_act_yn := p5_a10;
    ddp_khrv_rec.term_duration := rosetta_g_miss_num_map(p5_a11);
    ddp_khrv_rec.converted_account_yn := p5_a12;
    ddp_khrv_rec.date_conversion_effective := rosetta_g_miss_date_in_map(p5_a13);
    ddp_khrv_rec.syndicatable_yn := p5_a14;
    ddp_khrv_rec.salestype_yn := p5_a15;
    ddp_khrv_rec.date_deal_transferred := rosetta_g_miss_date_in_map(p5_a16);
    ddp_khrv_rec.datetime_proposal_effective := rosetta_g_miss_date_in_map(p5_a17);
    ddp_khrv_rec.datetime_proposal_ineffective := rosetta_g_miss_date_in_map(p5_a18);
    ddp_khrv_rec.date_proposal_accepted := rosetta_g_miss_date_in_map(p5_a19);
    ddp_khrv_rec.attribute_category := p5_a20;
    ddp_khrv_rec.attribute1 := p5_a21;
    ddp_khrv_rec.attribute2 := p5_a22;
    ddp_khrv_rec.attribute3 := p5_a23;
    ddp_khrv_rec.attribute4 := p5_a24;
    ddp_khrv_rec.attribute5 := p5_a25;
    ddp_khrv_rec.attribute6 := p5_a26;
    ddp_khrv_rec.attribute7 := p5_a27;
    ddp_khrv_rec.attribute8 := p5_a28;
    ddp_khrv_rec.attribute9 := p5_a29;
    ddp_khrv_rec.attribute10 := p5_a30;
    ddp_khrv_rec.attribute11 := p5_a31;
    ddp_khrv_rec.attribute12 := p5_a32;
    ddp_khrv_rec.attribute13 := p5_a33;
    ddp_khrv_rec.attribute14 := p5_a34;
    ddp_khrv_rec.attribute15 := p5_a35;
    ddp_khrv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_khrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_khrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_khrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_khrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_khrv_rec.pre_tax_yield := rosetta_g_miss_num_map(p5_a41);
    ddp_khrv_rec.after_tax_yield := rosetta_g_miss_num_map(p5_a42);
    ddp_khrv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a43);
    ddp_khrv_rec.implicit_non_idc_interest_rate := rosetta_g_miss_num_map(p5_a44);
    ddp_khrv_rec.target_pre_tax_yield := rosetta_g_miss_num_map(p5_a45);
    ddp_khrv_rec.target_after_tax_yield := rosetta_g_miss_num_map(p5_a46);
    ddp_khrv_rec.target_implicit_interest_rate := rosetta_g_miss_num_map(p5_a47);
    ddp_khrv_rec.target_implicit_nonidc_intrate := rosetta_g_miss_num_map(p5_a48);
    ddp_khrv_rec.date_last_interim_interest_cal := rosetta_g_miss_date_in_map(p5_a49);
    ddp_khrv_rec.deal_type := p5_a50;
    ddp_khrv_rec.pre_tax_irr := rosetta_g_miss_num_map(p5_a51);
    ddp_khrv_rec.after_tax_irr := rosetta_g_miss_num_map(p5_a52);
    ddp_khrv_rec.expected_delivery_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_khrv_rec.accepted_date := rosetta_g_miss_date_in_map(p5_a54);
    ddp_khrv_rec.prefunding_eligible_yn := p5_a55;
    ddp_khrv_rec.revolving_credit_yn := p5_a56;
    ddp_khrv_rec.currency_conversion_type := p5_a57;
    ddp_khrv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a58);
    ddp_khrv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a59);
    ddp_khrv_rec.multi_gaap_yn := p5_a60;
    ddp_khrv_rec.recourse_code := p5_a61;
    ddp_khrv_rec.lessor_serv_org_code := p5_a62;
    ddp_khrv_rec.assignable_yn := p5_a63;
    ddp_khrv_rec.securitized_code := p5_a64;
    ddp_khrv_rec.securitization_type := p5_a65;

    -- here's the delegated call to the old PL/SQL routine
    okl_khr_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_rec);

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
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_DATE_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
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
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_DATE_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_VARCHAR2_TABLE_100
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_khrv_tbl okl_khr_pvt.khrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_khr_pvt_w.rosetta_table_copy_in_p8(ddp_khrv_tbl, p5_a0
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
    okl_khr_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_khrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_khr_pvt_w;

/
