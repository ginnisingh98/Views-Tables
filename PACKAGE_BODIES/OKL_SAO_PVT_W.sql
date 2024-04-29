--------------------------------------------------------
--  DDL for Package Body OKL_SAO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SAO_PVT_W" as
  /* $Header: OKLISAOB.pls 120.5.12010000.3 2009/06/02 10:34:33 racheruv ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_sao_pvt.sao_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
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
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
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
    , a41 JTF_VARCHAR2_TABLE_500
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_DATE_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).cc_rep_currency_code := a1(indx);
          t(ddindx).code_combination_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).ael_rep_currency_code := a3(indx);
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).rec_ccid := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).realized_gain_ccid := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).realized_loss_ccid := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).tax_ccid := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).cross_currency_ccid := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).rounding_ccid := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).ar_clearing_ccid := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).payables_ccid := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).liablity_ccid := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).pre_payment_ccid := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).fut_date_pay_ccid := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).cc_rounding_rule := a17(indx);
          t(ddindx).cc_precision := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).cc_min_acct_unit := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).dis_taken_ccid := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).ap_clearing_ccid := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).ael_rounding_rule := a22(indx);
          t(ddindx).ael_precision := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).ael_min_acct_unit := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).attribute_category := a26(indx);
          t(ddindx).attribute1 := a27(indx);
          t(ddindx).attribute2 := a28(indx);
          t(ddindx).attribute3 := a29(indx);
          t(ddindx).attribute4 := a30(indx);
          t(ddindx).attribute5 := a31(indx);
          t(ddindx).attribute6 := a32(indx);
          t(ddindx).attribute7 := a33(indx);
          t(ddindx).attribute8 := a34(indx);
          t(ddindx).attribute9 := a35(indx);
          t(ddindx).attribute10 := a36(indx);
          t(ddindx).attribute11 := a37(indx);
          t(ddindx).attribute12 := a38(indx);
          t(ddindx).attribute13 := a39(indx);
          t(ddindx).attribute14 := a40(indx);
          t(ddindx).attribute15 := a41(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a43(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a45(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).cc_apply_rounding_difference := a47(indx);
          t(ddindx).ael_apply_rounding_difference := a48(indx);
          t(ddindx).accrual_reversal_days := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).lke_hold_days := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).stm_apply_rounding_difference := a51(indx);
          t(ddindx).stm_rounding_rule := a52(indx);
          t(ddindx).validate_khr_start_date := a53(indx);
          t(ddindx).account_derivation := a54(indx);
          t(ddindx).isg_arrears_pay_dates_option := a55(indx);
          t(ddindx).pay_dist_set_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).secondary_rep_method := a57(indx);
          t(ddindx).amort_inc_adj_rev_dt_yn := a58(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_sao_pvt.sao_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
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
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a41 out nocopy JTF_VARCHAR2_TABLE_500
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_DATE_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
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
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
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
    a41 := JTF_VARCHAR2_TABLE_500();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_DATE_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
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
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
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
      a41 := JTF_VARCHAR2_TABLE_500();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_DATE_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
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
          a1(indx) := t(ddindx).cc_rep_currency_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).code_combination_id);
          a3(indx) := t(ddindx).ael_rep_currency_code;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).rec_ccid);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).realized_gain_ccid);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).realized_loss_ccid);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).tax_ccid);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).cross_currency_ccid);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).rounding_ccid);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).ar_clearing_ccid);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).payables_ccid);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).liablity_ccid);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).pre_payment_ccid);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).fut_date_pay_ccid);
          a17(indx) := t(ddindx).cc_rounding_rule;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).cc_precision);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).cc_min_acct_unit);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).dis_taken_ccid);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).ap_clearing_ccid);
          a22(indx) := t(ddindx).ael_rounding_rule;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).ael_precision);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).ael_min_acct_unit);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a26(indx) := t(ddindx).attribute_category;
          a27(indx) := t(ddindx).attribute1;
          a28(indx) := t(ddindx).attribute2;
          a29(indx) := t(ddindx).attribute3;
          a30(indx) := t(ddindx).attribute4;
          a31(indx) := t(ddindx).attribute5;
          a32(indx) := t(ddindx).attribute6;
          a33(indx) := t(ddindx).attribute7;
          a34(indx) := t(ddindx).attribute8;
          a35(indx) := t(ddindx).attribute9;
          a36(indx) := t(ddindx).attribute10;
          a37(indx) := t(ddindx).attribute11;
          a38(indx) := t(ddindx).attribute12;
          a39(indx) := t(ddindx).attribute13;
          a40(indx) := t(ddindx).attribute14;
          a41(indx) := t(ddindx).attribute15;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a43(indx) := t(ddindx).creation_date;
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a45(indx) := t(ddindx).last_update_date;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a47(indx) := t(ddindx).cc_apply_rounding_difference;
          a48(indx) := t(ddindx).ael_apply_rounding_difference;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).accrual_reversal_days);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).lke_hold_days);
          a51(indx) := t(ddindx).stm_apply_rounding_difference;
          a52(indx) := t(ddindx).stm_rounding_rule;
          a53(indx) := t(ddindx).validate_khr_start_date;
          a54(indx) := t(ddindx).account_derivation;
          a55(indx) := t(ddindx).isg_arrears_pay_dates_option;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).pay_dist_set_id);
          a57(indx) := t(ddindx).secondary_rep_method;
          a58(indx) := t(ddindx).amort_inc_adj_rev_dt_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_sao_pvt.saov_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
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
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
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
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_DATE_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).set_of_books_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).code_combination_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).cc_rep_currency_code := a4(indx);
          t(ddindx).ael_rep_currency_code := a5(indx);
          t(ddindx).rec_ccid := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).realized_gain_ccid := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).realized_loss_ccid := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).tax_ccid := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).cross_currency_ccid := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).rounding_ccid := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).ar_clearing_ccid := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).payables_ccid := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).liablity_ccid := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).pre_payment_ccid := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).fut_date_pay_ccid := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).dis_taken_ccid := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).ap_clearing_ccid := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).ael_rounding_rule := a19(indx);
          t(ddindx).ael_precision := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).ael_min_acct_unit := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).cc_rounding_rule := a22(indx);
          t(ddindx).cc_precision := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).cc_min_acct_unit := rosetta_g_miss_num_map(a24(indx));
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
          t(ddindx).org_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a43(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a45(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).cc_apply_rounding_difference := a47(indx);
          t(ddindx).ael_apply_rounding_difference := a48(indx);
          t(ddindx).accrual_reversal_days := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).lke_hold_days := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).stm_apply_rounding_difference := a51(indx);
          t(ddindx).stm_rounding_rule := a52(indx);
          t(ddindx).validate_khr_start_date := a53(indx);
          t(ddindx).account_derivation := a54(indx);
          t(ddindx).isg_arrears_pay_dates_option := a55(indx);
          t(ddindx).pay_dist_set_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).secondary_rep_method := a57(indx);
          t(ddindx).amort_inc_adj_rev_dt_yn := a58(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_sao_pvt.saov_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_DATE_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
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
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
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
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_DATE_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
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
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
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
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_DATE_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
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
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).set_of_books_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).code_combination_id);
          a4(indx) := t(ddindx).cc_rep_currency_code;
          a5(indx) := t(ddindx).ael_rep_currency_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).rec_ccid);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).realized_gain_ccid);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).realized_loss_ccid);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).tax_ccid);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).cross_currency_ccid);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).rounding_ccid);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).ar_clearing_ccid);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).payables_ccid);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).liablity_ccid);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).pre_payment_ccid);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).fut_date_pay_ccid);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).dis_taken_ccid);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).ap_clearing_ccid);
          a19(indx) := t(ddindx).ael_rounding_rule;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).ael_precision);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).ael_min_acct_unit);
          a22(indx) := t(ddindx).cc_rounding_rule;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).cc_precision);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).cc_min_acct_unit);
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
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a43(indx) := t(ddindx).creation_date;
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a45(indx) := t(ddindx).last_update_date;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a47(indx) := t(ddindx).cc_apply_rounding_difference;
          a48(indx) := t(ddindx).ael_apply_rounding_difference;
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).accrual_reversal_days);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).lke_hold_days);
          a51(indx) := t(ddindx).stm_apply_rounding_difference;
          a52(indx) := t(ddindx).stm_rounding_rule;
          a53(indx) := t(ddindx).validate_khr_start_date;
          a54(indx) := t(ddindx).account_derivation;
          a55(indx) := t(ddindx).isg_arrears_pay_dates_option;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).pay_dist_set_id);
          a57(indx) := t(ddindx).secondary_rep_method;
          a58(indx) := t(ddindx).amort_inc_adj_rev_dt_yn;
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
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
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
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
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
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  DATE
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
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
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_saov_rec okl_sao_pvt.saov_rec_type;
    ddx_saov_rec okl_sao_pvt.saov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_saov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_saov_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_saov_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a2);
    ddp_saov_rec.code_combination_id := rosetta_g_miss_num_map(p5_a3);
    ddp_saov_rec.cc_rep_currency_code := p5_a4;
    ddp_saov_rec.ael_rep_currency_code := p5_a5;
    ddp_saov_rec.rec_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_saov_rec.realized_gain_ccid := rosetta_g_miss_num_map(p5_a7);
    ddp_saov_rec.realized_loss_ccid := rosetta_g_miss_num_map(p5_a8);
    ddp_saov_rec.tax_ccid := rosetta_g_miss_num_map(p5_a9);
    ddp_saov_rec.cross_currency_ccid := rosetta_g_miss_num_map(p5_a10);
    ddp_saov_rec.rounding_ccid := rosetta_g_miss_num_map(p5_a11);
    ddp_saov_rec.ar_clearing_ccid := rosetta_g_miss_num_map(p5_a12);
    ddp_saov_rec.payables_ccid := rosetta_g_miss_num_map(p5_a13);
    ddp_saov_rec.liablity_ccid := rosetta_g_miss_num_map(p5_a14);
    ddp_saov_rec.pre_payment_ccid := rosetta_g_miss_num_map(p5_a15);
    ddp_saov_rec.fut_date_pay_ccid := rosetta_g_miss_num_map(p5_a16);
    ddp_saov_rec.dis_taken_ccid := rosetta_g_miss_num_map(p5_a17);
    ddp_saov_rec.ap_clearing_ccid := rosetta_g_miss_num_map(p5_a18);
    ddp_saov_rec.ael_rounding_rule := p5_a19;
    ddp_saov_rec.ael_precision := rosetta_g_miss_num_map(p5_a20);
    ddp_saov_rec.ael_min_acct_unit := rosetta_g_miss_num_map(p5_a21);
    ddp_saov_rec.cc_rounding_rule := p5_a22;
    ddp_saov_rec.cc_precision := rosetta_g_miss_num_map(p5_a23);
    ddp_saov_rec.cc_min_acct_unit := rosetta_g_miss_num_map(p5_a24);
    ddp_saov_rec.attribute_category := p5_a25;
    ddp_saov_rec.attribute1 := p5_a26;
    ddp_saov_rec.attribute2 := p5_a27;
    ddp_saov_rec.attribute3 := p5_a28;
    ddp_saov_rec.attribute4 := p5_a29;
    ddp_saov_rec.attribute5 := p5_a30;
    ddp_saov_rec.attribute6 := p5_a31;
    ddp_saov_rec.attribute7 := p5_a32;
    ddp_saov_rec.attribute8 := p5_a33;
    ddp_saov_rec.attribute9 := p5_a34;
    ddp_saov_rec.attribute10 := p5_a35;
    ddp_saov_rec.attribute11 := p5_a36;
    ddp_saov_rec.attribute12 := p5_a37;
    ddp_saov_rec.attribute13 := p5_a38;
    ddp_saov_rec.attribute14 := p5_a39;
    ddp_saov_rec.attribute15 := p5_a40;
    ddp_saov_rec.org_id := rosetta_g_miss_num_map(p5_a41);
    ddp_saov_rec.created_by := rosetta_g_miss_num_map(p5_a42);
    ddp_saov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_saov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a44);
    ddp_saov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_saov_rec.last_update_login := rosetta_g_miss_num_map(p5_a46);
    ddp_saov_rec.cc_apply_rounding_difference := p5_a47;
    ddp_saov_rec.ael_apply_rounding_difference := p5_a48;
    ddp_saov_rec.accrual_reversal_days := rosetta_g_miss_num_map(p5_a49);
    ddp_saov_rec.lke_hold_days := rosetta_g_miss_num_map(p5_a50);
    ddp_saov_rec.stm_apply_rounding_difference := p5_a51;
    ddp_saov_rec.stm_rounding_rule := p5_a52;
    ddp_saov_rec.validate_khr_start_date := p5_a53;
    ddp_saov_rec.account_derivation := p5_a54;
    ddp_saov_rec.isg_arrears_pay_dates_option := p5_a55;
    ddp_saov_rec.pay_dist_set_id := rosetta_g_miss_num_map(p5_a56);
    ddp_saov_rec.secondary_rep_method := p5_a57;
    ddp_saov_rec.amort_inc_adj_rev_dt_yn := p5_a58;


    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_rec,
      ddx_saov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_saov_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_saov_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_saov_rec.set_of_books_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_saov_rec.code_combination_id);
    p6_a4 := ddx_saov_rec.cc_rep_currency_code;
    p6_a5 := ddx_saov_rec.ael_rep_currency_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_saov_rec.rec_ccid);
    p6_a7 := rosetta_g_miss_num_map(ddx_saov_rec.realized_gain_ccid);
    p6_a8 := rosetta_g_miss_num_map(ddx_saov_rec.realized_loss_ccid);
    p6_a9 := rosetta_g_miss_num_map(ddx_saov_rec.tax_ccid);
    p6_a10 := rosetta_g_miss_num_map(ddx_saov_rec.cross_currency_ccid);
    p6_a11 := rosetta_g_miss_num_map(ddx_saov_rec.rounding_ccid);
    p6_a12 := rosetta_g_miss_num_map(ddx_saov_rec.ar_clearing_ccid);
    p6_a13 := rosetta_g_miss_num_map(ddx_saov_rec.payables_ccid);
    p6_a14 := rosetta_g_miss_num_map(ddx_saov_rec.liablity_ccid);
    p6_a15 := rosetta_g_miss_num_map(ddx_saov_rec.pre_payment_ccid);
    p6_a16 := rosetta_g_miss_num_map(ddx_saov_rec.fut_date_pay_ccid);
    p6_a17 := rosetta_g_miss_num_map(ddx_saov_rec.dis_taken_ccid);
    p6_a18 := rosetta_g_miss_num_map(ddx_saov_rec.ap_clearing_ccid);
    p6_a19 := ddx_saov_rec.ael_rounding_rule;
    p6_a20 := rosetta_g_miss_num_map(ddx_saov_rec.ael_precision);
    p6_a21 := rosetta_g_miss_num_map(ddx_saov_rec.ael_min_acct_unit);
    p6_a22 := ddx_saov_rec.cc_rounding_rule;
    p6_a23 := rosetta_g_miss_num_map(ddx_saov_rec.cc_precision);
    p6_a24 := rosetta_g_miss_num_map(ddx_saov_rec.cc_min_acct_unit);
    p6_a25 := ddx_saov_rec.attribute_category;
    p6_a26 := ddx_saov_rec.attribute1;
    p6_a27 := ddx_saov_rec.attribute2;
    p6_a28 := ddx_saov_rec.attribute3;
    p6_a29 := ddx_saov_rec.attribute4;
    p6_a30 := ddx_saov_rec.attribute5;
    p6_a31 := ddx_saov_rec.attribute6;
    p6_a32 := ddx_saov_rec.attribute7;
    p6_a33 := ddx_saov_rec.attribute8;
    p6_a34 := ddx_saov_rec.attribute9;
    p6_a35 := ddx_saov_rec.attribute10;
    p6_a36 := ddx_saov_rec.attribute11;
    p6_a37 := ddx_saov_rec.attribute12;
    p6_a38 := ddx_saov_rec.attribute13;
    p6_a39 := ddx_saov_rec.attribute14;
    p6_a40 := ddx_saov_rec.attribute15;
    p6_a41 := rosetta_g_miss_num_map(ddx_saov_rec.org_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_saov_rec.created_by);
    p6_a43 := ddx_saov_rec.creation_date;
    p6_a44 := rosetta_g_miss_num_map(ddx_saov_rec.last_updated_by);
    p6_a45 := ddx_saov_rec.last_update_date;
    p6_a46 := rosetta_g_miss_num_map(ddx_saov_rec.last_update_login);
    p6_a47 := ddx_saov_rec.cc_apply_rounding_difference;
    p6_a48 := ddx_saov_rec.ael_apply_rounding_difference;
    p6_a49 := rosetta_g_miss_num_map(ddx_saov_rec.accrual_reversal_days);
    p6_a50 := rosetta_g_miss_num_map(ddx_saov_rec.lke_hold_days);
    p6_a51 := ddx_saov_rec.stm_apply_rounding_difference;
    p6_a52 := ddx_saov_rec.stm_rounding_rule;
    p6_a53 := ddx_saov_rec.validate_khr_start_date;
    p6_a54 := ddx_saov_rec.account_derivation;
    p6_a55 := ddx_saov_rec.isg_arrears_pay_dates_option;
    p6_a56 := rosetta_g_miss_num_map(ddx_saov_rec.pay_dist_set_id);
    p6_a57 := ddx_saov_rec.secondary_rep_method;
    p6_a58 := ddx_saov_rec.amort_inc_adj_rev_dt_yn;
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
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_DATE_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_saov_tbl okl_sao_pvt.saov_tbl_type;
    ddx_saov_tbl okl_sao_pvt.saov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sao_pvt_w.rosetta_table_copy_in_p5(ddp_saov_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_tbl,
      ddx_saov_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sao_pvt_w.rosetta_table_copy_out_p5(ddx_saov_tbl, p6_a0
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
      );
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
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
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
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_saov_rec okl_sao_pvt.saov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_saov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_saov_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_saov_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a2);
    ddp_saov_rec.code_combination_id := rosetta_g_miss_num_map(p5_a3);
    ddp_saov_rec.cc_rep_currency_code := p5_a4;
    ddp_saov_rec.ael_rep_currency_code := p5_a5;
    ddp_saov_rec.rec_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_saov_rec.realized_gain_ccid := rosetta_g_miss_num_map(p5_a7);
    ddp_saov_rec.realized_loss_ccid := rosetta_g_miss_num_map(p5_a8);
    ddp_saov_rec.tax_ccid := rosetta_g_miss_num_map(p5_a9);
    ddp_saov_rec.cross_currency_ccid := rosetta_g_miss_num_map(p5_a10);
    ddp_saov_rec.rounding_ccid := rosetta_g_miss_num_map(p5_a11);
    ddp_saov_rec.ar_clearing_ccid := rosetta_g_miss_num_map(p5_a12);
    ddp_saov_rec.payables_ccid := rosetta_g_miss_num_map(p5_a13);
    ddp_saov_rec.liablity_ccid := rosetta_g_miss_num_map(p5_a14);
    ddp_saov_rec.pre_payment_ccid := rosetta_g_miss_num_map(p5_a15);
    ddp_saov_rec.fut_date_pay_ccid := rosetta_g_miss_num_map(p5_a16);
    ddp_saov_rec.dis_taken_ccid := rosetta_g_miss_num_map(p5_a17);
    ddp_saov_rec.ap_clearing_ccid := rosetta_g_miss_num_map(p5_a18);
    ddp_saov_rec.ael_rounding_rule := p5_a19;
    ddp_saov_rec.ael_precision := rosetta_g_miss_num_map(p5_a20);
    ddp_saov_rec.ael_min_acct_unit := rosetta_g_miss_num_map(p5_a21);
    ddp_saov_rec.cc_rounding_rule := p5_a22;
    ddp_saov_rec.cc_precision := rosetta_g_miss_num_map(p5_a23);
    ddp_saov_rec.cc_min_acct_unit := rosetta_g_miss_num_map(p5_a24);
    ddp_saov_rec.attribute_category := p5_a25;
    ddp_saov_rec.attribute1 := p5_a26;
    ddp_saov_rec.attribute2 := p5_a27;
    ddp_saov_rec.attribute3 := p5_a28;
    ddp_saov_rec.attribute4 := p5_a29;
    ddp_saov_rec.attribute5 := p5_a30;
    ddp_saov_rec.attribute6 := p5_a31;
    ddp_saov_rec.attribute7 := p5_a32;
    ddp_saov_rec.attribute8 := p5_a33;
    ddp_saov_rec.attribute9 := p5_a34;
    ddp_saov_rec.attribute10 := p5_a35;
    ddp_saov_rec.attribute11 := p5_a36;
    ddp_saov_rec.attribute12 := p5_a37;
    ddp_saov_rec.attribute13 := p5_a38;
    ddp_saov_rec.attribute14 := p5_a39;
    ddp_saov_rec.attribute15 := p5_a40;
    ddp_saov_rec.org_id := rosetta_g_miss_num_map(p5_a41);
    ddp_saov_rec.created_by := rosetta_g_miss_num_map(p5_a42);
    ddp_saov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_saov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a44);
    ddp_saov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_saov_rec.last_update_login := rosetta_g_miss_num_map(p5_a46);
    ddp_saov_rec.cc_apply_rounding_difference := p5_a47;
    ddp_saov_rec.ael_apply_rounding_difference := p5_a48;
    ddp_saov_rec.accrual_reversal_days := rosetta_g_miss_num_map(p5_a49);
    ddp_saov_rec.lke_hold_days := rosetta_g_miss_num_map(p5_a50);
    ddp_saov_rec.stm_apply_rounding_difference := p5_a51;
    ddp_saov_rec.stm_rounding_rule := p5_a52;
    ddp_saov_rec.validate_khr_start_date := p5_a53;
    ddp_saov_rec.account_derivation := p5_a54;
    ddp_saov_rec.isg_arrears_pay_dates_option := p5_a55;
    ddp_saov_rec.pay_dist_set_id := rosetta_g_miss_num_map(p5_a56);
    ddp_saov_rec.secondary_rep_method := p5_a57;
    ddp_saov_rec.amort_inc_adj_rev_dt_yn := p5_a58;

    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_rec);

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
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_saov_tbl okl_sao_pvt.saov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sao_pvt_w.rosetta_table_copy_in_p5(ddp_saov_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





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
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
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
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  DATE
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  DATE
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
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
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_saov_rec okl_sao_pvt.saov_rec_type;
    ddx_saov_rec okl_sao_pvt.saov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_saov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_saov_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_saov_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a2);
    ddp_saov_rec.code_combination_id := rosetta_g_miss_num_map(p5_a3);
    ddp_saov_rec.cc_rep_currency_code := p5_a4;
    ddp_saov_rec.ael_rep_currency_code := p5_a5;
    ddp_saov_rec.rec_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_saov_rec.realized_gain_ccid := rosetta_g_miss_num_map(p5_a7);
    ddp_saov_rec.realized_loss_ccid := rosetta_g_miss_num_map(p5_a8);
    ddp_saov_rec.tax_ccid := rosetta_g_miss_num_map(p5_a9);
    ddp_saov_rec.cross_currency_ccid := rosetta_g_miss_num_map(p5_a10);
    ddp_saov_rec.rounding_ccid := rosetta_g_miss_num_map(p5_a11);
    ddp_saov_rec.ar_clearing_ccid := rosetta_g_miss_num_map(p5_a12);
    ddp_saov_rec.payables_ccid := rosetta_g_miss_num_map(p5_a13);
    ddp_saov_rec.liablity_ccid := rosetta_g_miss_num_map(p5_a14);
    ddp_saov_rec.pre_payment_ccid := rosetta_g_miss_num_map(p5_a15);
    ddp_saov_rec.fut_date_pay_ccid := rosetta_g_miss_num_map(p5_a16);
    ddp_saov_rec.dis_taken_ccid := rosetta_g_miss_num_map(p5_a17);
    ddp_saov_rec.ap_clearing_ccid := rosetta_g_miss_num_map(p5_a18);
    ddp_saov_rec.ael_rounding_rule := p5_a19;
    ddp_saov_rec.ael_precision := rosetta_g_miss_num_map(p5_a20);
    ddp_saov_rec.ael_min_acct_unit := rosetta_g_miss_num_map(p5_a21);
    ddp_saov_rec.cc_rounding_rule := p5_a22;
    ddp_saov_rec.cc_precision := rosetta_g_miss_num_map(p5_a23);
    ddp_saov_rec.cc_min_acct_unit := rosetta_g_miss_num_map(p5_a24);
    ddp_saov_rec.attribute_category := p5_a25;
    ddp_saov_rec.attribute1 := p5_a26;
    ddp_saov_rec.attribute2 := p5_a27;
    ddp_saov_rec.attribute3 := p5_a28;
    ddp_saov_rec.attribute4 := p5_a29;
    ddp_saov_rec.attribute5 := p5_a30;
    ddp_saov_rec.attribute6 := p5_a31;
    ddp_saov_rec.attribute7 := p5_a32;
    ddp_saov_rec.attribute8 := p5_a33;
    ddp_saov_rec.attribute9 := p5_a34;
    ddp_saov_rec.attribute10 := p5_a35;
    ddp_saov_rec.attribute11 := p5_a36;
    ddp_saov_rec.attribute12 := p5_a37;
    ddp_saov_rec.attribute13 := p5_a38;
    ddp_saov_rec.attribute14 := p5_a39;
    ddp_saov_rec.attribute15 := p5_a40;
    ddp_saov_rec.org_id := rosetta_g_miss_num_map(p5_a41);
    ddp_saov_rec.created_by := rosetta_g_miss_num_map(p5_a42);
    ddp_saov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_saov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a44);
    ddp_saov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_saov_rec.last_update_login := rosetta_g_miss_num_map(p5_a46);
    ddp_saov_rec.cc_apply_rounding_difference := p5_a47;
    ddp_saov_rec.ael_apply_rounding_difference := p5_a48;
    ddp_saov_rec.accrual_reversal_days := rosetta_g_miss_num_map(p5_a49);
    ddp_saov_rec.lke_hold_days := rosetta_g_miss_num_map(p5_a50);
    ddp_saov_rec.stm_apply_rounding_difference := p5_a51;
    ddp_saov_rec.stm_rounding_rule := p5_a52;
    ddp_saov_rec.validate_khr_start_date := p5_a53;
    ddp_saov_rec.account_derivation := p5_a54;
    ddp_saov_rec.isg_arrears_pay_dates_option := p5_a55;
    ddp_saov_rec.pay_dist_set_id := rosetta_g_miss_num_map(p5_a56);
    ddp_saov_rec.secondary_rep_method := p5_a57;
    ddp_saov_rec.amort_inc_adj_rev_dt_yn := p5_a58;


    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_rec,
      ddx_saov_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_saov_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_saov_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_saov_rec.set_of_books_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_saov_rec.code_combination_id);
    p6_a4 := ddx_saov_rec.cc_rep_currency_code;
    p6_a5 := ddx_saov_rec.ael_rep_currency_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_saov_rec.rec_ccid);
    p6_a7 := rosetta_g_miss_num_map(ddx_saov_rec.realized_gain_ccid);
    p6_a8 := rosetta_g_miss_num_map(ddx_saov_rec.realized_loss_ccid);
    p6_a9 := rosetta_g_miss_num_map(ddx_saov_rec.tax_ccid);
    p6_a10 := rosetta_g_miss_num_map(ddx_saov_rec.cross_currency_ccid);
    p6_a11 := rosetta_g_miss_num_map(ddx_saov_rec.rounding_ccid);
    p6_a12 := rosetta_g_miss_num_map(ddx_saov_rec.ar_clearing_ccid);
    p6_a13 := rosetta_g_miss_num_map(ddx_saov_rec.payables_ccid);
    p6_a14 := rosetta_g_miss_num_map(ddx_saov_rec.liablity_ccid);
    p6_a15 := rosetta_g_miss_num_map(ddx_saov_rec.pre_payment_ccid);
    p6_a16 := rosetta_g_miss_num_map(ddx_saov_rec.fut_date_pay_ccid);
    p6_a17 := rosetta_g_miss_num_map(ddx_saov_rec.dis_taken_ccid);
    p6_a18 := rosetta_g_miss_num_map(ddx_saov_rec.ap_clearing_ccid);
    p6_a19 := ddx_saov_rec.ael_rounding_rule;
    p6_a20 := rosetta_g_miss_num_map(ddx_saov_rec.ael_precision);
    p6_a21 := rosetta_g_miss_num_map(ddx_saov_rec.ael_min_acct_unit);
    p6_a22 := ddx_saov_rec.cc_rounding_rule;
    p6_a23 := rosetta_g_miss_num_map(ddx_saov_rec.cc_precision);
    p6_a24 := rosetta_g_miss_num_map(ddx_saov_rec.cc_min_acct_unit);
    p6_a25 := ddx_saov_rec.attribute_category;
    p6_a26 := ddx_saov_rec.attribute1;
    p6_a27 := ddx_saov_rec.attribute2;
    p6_a28 := ddx_saov_rec.attribute3;
    p6_a29 := ddx_saov_rec.attribute4;
    p6_a30 := ddx_saov_rec.attribute5;
    p6_a31 := ddx_saov_rec.attribute6;
    p6_a32 := ddx_saov_rec.attribute7;
    p6_a33 := ddx_saov_rec.attribute8;
    p6_a34 := ddx_saov_rec.attribute9;
    p6_a35 := ddx_saov_rec.attribute10;
    p6_a36 := ddx_saov_rec.attribute11;
    p6_a37 := ddx_saov_rec.attribute12;
    p6_a38 := ddx_saov_rec.attribute13;
    p6_a39 := ddx_saov_rec.attribute14;
    p6_a40 := ddx_saov_rec.attribute15;
    p6_a41 := rosetta_g_miss_num_map(ddx_saov_rec.org_id);
    p6_a42 := rosetta_g_miss_num_map(ddx_saov_rec.created_by);
    p6_a43 := ddx_saov_rec.creation_date;
    p6_a44 := rosetta_g_miss_num_map(ddx_saov_rec.last_updated_by);
    p6_a45 := ddx_saov_rec.last_update_date;
    p6_a46 := rosetta_g_miss_num_map(ddx_saov_rec.last_update_login);
    p6_a47 := ddx_saov_rec.cc_apply_rounding_difference;
    p6_a48 := ddx_saov_rec.ael_apply_rounding_difference;
    p6_a49 := rosetta_g_miss_num_map(ddx_saov_rec.accrual_reversal_days);
    p6_a50 := rosetta_g_miss_num_map(ddx_saov_rec.lke_hold_days);
    p6_a51 := ddx_saov_rec.stm_apply_rounding_difference;
    p6_a52 := ddx_saov_rec.stm_rounding_rule;
    p6_a53 := ddx_saov_rec.validate_khr_start_date;
    p6_a54 := ddx_saov_rec.account_derivation;
    p6_a55 := ddx_saov_rec.isg_arrears_pay_dates_option;
    p6_a56 := rosetta_g_miss_num_map(ddx_saov_rec.pay_dist_set_id);
    p6_a57 := ddx_saov_rec.secondary_rep_method;
    p6_a58 := ddx_saov_rec.amort_inc_adj_rev_dt_yn;
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
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_DATE_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_saov_tbl okl_sao_pvt.saov_tbl_type;
    ddx_saov_tbl okl_sao_pvt.saov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sao_pvt_w.rosetta_table_copy_in_p5(ddp_saov_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_tbl,
      ddx_saov_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sao_pvt_w.rosetta_table_copy_out_p5(ddx_saov_tbl, p6_a0
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
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
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
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_saov_rec okl_sao_pvt.saov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_saov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_saov_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_saov_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a2);
    ddp_saov_rec.code_combination_id := rosetta_g_miss_num_map(p5_a3);
    ddp_saov_rec.cc_rep_currency_code := p5_a4;
    ddp_saov_rec.ael_rep_currency_code := p5_a5;
    ddp_saov_rec.rec_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_saov_rec.realized_gain_ccid := rosetta_g_miss_num_map(p5_a7);
    ddp_saov_rec.realized_loss_ccid := rosetta_g_miss_num_map(p5_a8);
    ddp_saov_rec.tax_ccid := rosetta_g_miss_num_map(p5_a9);
    ddp_saov_rec.cross_currency_ccid := rosetta_g_miss_num_map(p5_a10);
    ddp_saov_rec.rounding_ccid := rosetta_g_miss_num_map(p5_a11);
    ddp_saov_rec.ar_clearing_ccid := rosetta_g_miss_num_map(p5_a12);
    ddp_saov_rec.payables_ccid := rosetta_g_miss_num_map(p5_a13);
    ddp_saov_rec.liablity_ccid := rosetta_g_miss_num_map(p5_a14);
    ddp_saov_rec.pre_payment_ccid := rosetta_g_miss_num_map(p5_a15);
    ddp_saov_rec.fut_date_pay_ccid := rosetta_g_miss_num_map(p5_a16);
    ddp_saov_rec.dis_taken_ccid := rosetta_g_miss_num_map(p5_a17);
    ddp_saov_rec.ap_clearing_ccid := rosetta_g_miss_num_map(p5_a18);
    ddp_saov_rec.ael_rounding_rule := p5_a19;
    ddp_saov_rec.ael_precision := rosetta_g_miss_num_map(p5_a20);
    ddp_saov_rec.ael_min_acct_unit := rosetta_g_miss_num_map(p5_a21);
    ddp_saov_rec.cc_rounding_rule := p5_a22;
    ddp_saov_rec.cc_precision := rosetta_g_miss_num_map(p5_a23);
    ddp_saov_rec.cc_min_acct_unit := rosetta_g_miss_num_map(p5_a24);
    ddp_saov_rec.attribute_category := p5_a25;
    ddp_saov_rec.attribute1 := p5_a26;
    ddp_saov_rec.attribute2 := p5_a27;
    ddp_saov_rec.attribute3 := p5_a28;
    ddp_saov_rec.attribute4 := p5_a29;
    ddp_saov_rec.attribute5 := p5_a30;
    ddp_saov_rec.attribute6 := p5_a31;
    ddp_saov_rec.attribute7 := p5_a32;
    ddp_saov_rec.attribute8 := p5_a33;
    ddp_saov_rec.attribute9 := p5_a34;
    ddp_saov_rec.attribute10 := p5_a35;
    ddp_saov_rec.attribute11 := p5_a36;
    ddp_saov_rec.attribute12 := p5_a37;
    ddp_saov_rec.attribute13 := p5_a38;
    ddp_saov_rec.attribute14 := p5_a39;
    ddp_saov_rec.attribute15 := p5_a40;
    ddp_saov_rec.org_id := rosetta_g_miss_num_map(p5_a41);
    ddp_saov_rec.created_by := rosetta_g_miss_num_map(p5_a42);
    ddp_saov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_saov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a44);
    ddp_saov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_saov_rec.last_update_login := rosetta_g_miss_num_map(p5_a46);
    ddp_saov_rec.cc_apply_rounding_difference := p5_a47;
    ddp_saov_rec.ael_apply_rounding_difference := p5_a48;
    ddp_saov_rec.accrual_reversal_days := rosetta_g_miss_num_map(p5_a49);
    ddp_saov_rec.lke_hold_days := rosetta_g_miss_num_map(p5_a50);
    ddp_saov_rec.stm_apply_rounding_difference := p5_a51;
    ddp_saov_rec.stm_rounding_rule := p5_a52;
    ddp_saov_rec.validate_khr_start_date := p5_a53;
    ddp_saov_rec.account_derivation := p5_a54;
    ddp_saov_rec.isg_arrears_pay_dates_option := p5_a55;
    ddp_saov_rec.pay_dist_set_id := rosetta_g_miss_num_map(p5_a56);
    ddp_saov_rec.secondary_rep_method := p5_a57;
    ddp_saov_rec.amort_inc_adj_rev_dt_yn := p5_a58;

    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_rec);

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
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_saov_tbl okl_sao_pvt.saov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sao_pvt_w.rosetta_table_copy_in_p5(ddp_saov_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_tbl);

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
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
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
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  DATE := fnd_api.g_miss_date
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_saov_rec okl_sao_pvt.saov_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_saov_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_saov_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_saov_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a2);
    ddp_saov_rec.code_combination_id := rosetta_g_miss_num_map(p5_a3);
    ddp_saov_rec.cc_rep_currency_code := p5_a4;
    ddp_saov_rec.ael_rep_currency_code := p5_a5;
    ddp_saov_rec.rec_ccid := rosetta_g_miss_num_map(p5_a6);
    ddp_saov_rec.realized_gain_ccid := rosetta_g_miss_num_map(p5_a7);
    ddp_saov_rec.realized_loss_ccid := rosetta_g_miss_num_map(p5_a8);
    ddp_saov_rec.tax_ccid := rosetta_g_miss_num_map(p5_a9);
    ddp_saov_rec.cross_currency_ccid := rosetta_g_miss_num_map(p5_a10);
    ddp_saov_rec.rounding_ccid := rosetta_g_miss_num_map(p5_a11);
    ddp_saov_rec.ar_clearing_ccid := rosetta_g_miss_num_map(p5_a12);
    ddp_saov_rec.payables_ccid := rosetta_g_miss_num_map(p5_a13);
    ddp_saov_rec.liablity_ccid := rosetta_g_miss_num_map(p5_a14);
    ddp_saov_rec.pre_payment_ccid := rosetta_g_miss_num_map(p5_a15);
    ddp_saov_rec.fut_date_pay_ccid := rosetta_g_miss_num_map(p5_a16);
    ddp_saov_rec.dis_taken_ccid := rosetta_g_miss_num_map(p5_a17);
    ddp_saov_rec.ap_clearing_ccid := rosetta_g_miss_num_map(p5_a18);
    ddp_saov_rec.ael_rounding_rule := p5_a19;
    ddp_saov_rec.ael_precision := rosetta_g_miss_num_map(p5_a20);
    ddp_saov_rec.ael_min_acct_unit := rosetta_g_miss_num_map(p5_a21);
    ddp_saov_rec.cc_rounding_rule := p5_a22;
    ddp_saov_rec.cc_precision := rosetta_g_miss_num_map(p5_a23);
    ddp_saov_rec.cc_min_acct_unit := rosetta_g_miss_num_map(p5_a24);
    ddp_saov_rec.attribute_category := p5_a25;
    ddp_saov_rec.attribute1 := p5_a26;
    ddp_saov_rec.attribute2 := p5_a27;
    ddp_saov_rec.attribute3 := p5_a28;
    ddp_saov_rec.attribute4 := p5_a29;
    ddp_saov_rec.attribute5 := p5_a30;
    ddp_saov_rec.attribute6 := p5_a31;
    ddp_saov_rec.attribute7 := p5_a32;
    ddp_saov_rec.attribute8 := p5_a33;
    ddp_saov_rec.attribute9 := p5_a34;
    ddp_saov_rec.attribute10 := p5_a35;
    ddp_saov_rec.attribute11 := p5_a36;
    ddp_saov_rec.attribute12 := p5_a37;
    ddp_saov_rec.attribute13 := p5_a38;
    ddp_saov_rec.attribute14 := p5_a39;
    ddp_saov_rec.attribute15 := p5_a40;
    ddp_saov_rec.org_id := rosetta_g_miss_num_map(p5_a41);
    ddp_saov_rec.created_by := rosetta_g_miss_num_map(p5_a42);
    ddp_saov_rec.creation_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_saov_rec.last_updated_by := rosetta_g_miss_num_map(p5_a44);
    ddp_saov_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a45);
    ddp_saov_rec.last_update_login := rosetta_g_miss_num_map(p5_a46);
    ddp_saov_rec.cc_apply_rounding_difference := p5_a47;
    ddp_saov_rec.ael_apply_rounding_difference := p5_a48;
    ddp_saov_rec.accrual_reversal_days := rosetta_g_miss_num_map(p5_a49);
    ddp_saov_rec.lke_hold_days := rosetta_g_miss_num_map(p5_a50);
    ddp_saov_rec.stm_apply_rounding_difference := p5_a51;
    ddp_saov_rec.stm_rounding_rule := p5_a52;
    ddp_saov_rec.validate_khr_start_date := p5_a53;
    ddp_saov_rec.account_derivation := p5_a54;
    ddp_saov_rec.isg_arrears_pay_dates_option := p5_a55;
    ddp_saov_rec.pay_dist_set_id := rosetta_g_miss_num_map(p5_a56);
    ddp_saov_rec.secondary_rep_method := p5_a57;
    ddp_saov_rec.amort_inc_adj_rev_dt_yn := p5_a58;

    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_rec);

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
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
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
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_saov_tbl okl_sao_pvt.saov_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sao_pvt_w.rosetta_table_copy_in_p5(ddp_saov_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sao_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_saov_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_sao_pvt_w;

/
