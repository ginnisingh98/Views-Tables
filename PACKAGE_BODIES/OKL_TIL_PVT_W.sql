--------------------------------------------------------
--  DDL for Package Body OKL_TIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TIL_PVT_W" as
  /* $Header: OKLITILB.pls 120.4 2007/07/20 09:42:01 akrangan ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_til_pvt.til_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
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
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
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
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_VARCHAR2_TABLE_500
    , a44 JTF_VARCHAR2_TABLE_500
    , a45 JTF_VARCHAR2_TABLE_500
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_DATE_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).inv_receiv_line_code := a1(indx);
          t(ddindx).tai_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).tpl_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).acn_id_cost := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).til_id_reverses := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).quantity := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).receivables_invoice_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).amount_applied := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).date_bill_period_start := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).date_bill_period_end := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).inventory_org_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).isl_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).ibt_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).late_charge_rec_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).cll_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).qte_line_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).txs_trx_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).bank_acct_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).attribute_category := a30(indx);
          t(ddindx).attribute1 := a31(indx);
          t(ddindx).attribute2 := a32(indx);
          t(ddindx).attribute3 := a33(indx);
          t(ddindx).attribute4 := a34(indx);
          t(ddindx).attribute5 := a35(indx);
          t(ddindx).attribute6 := a36(indx);
          t(ddindx).attribute7 := a37(indx);
          t(ddindx).attribute8 := a38(indx);
          t(ddindx).attribute9 := a39(indx);
          t(ddindx).attribute10 := a40(indx);
          t(ddindx).attribute11 := a41(indx);
          t(ddindx).attribute12 := a42(indx);
          t(ddindx).attribute13 := a43(indx);
          t(ddindx).attribute14 := a44(indx);
          t(ddindx).attribute15 := a45(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).txl_ar_line_number := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).txs_trx_line_id := rosetta_g_miss_num_map(a52(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_til_pvt.til_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_VARCHAR2_TABLE_500
    , a44 out nocopy JTF_VARCHAR2_TABLE_500
    , a45 out nocopy JTF_VARCHAR2_TABLE_500
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
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
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
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
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_VARCHAR2_TABLE_500();
    a44 := JTF_VARCHAR2_TABLE_500();
    a45 := JTF_VARCHAR2_TABLE_500();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
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
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
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
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_VARCHAR2_TABLE_500();
      a44 := JTF_VARCHAR2_TABLE_500();
      a45 := JTF_VARCHAR2_TABLE_500();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).inv_receiv_line_code;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).tai_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).tpl_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).acn_id_cost);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).til_id_reverses);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).receivables_invoice_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).amount_applied);
          a14(indx) := t(ddindx).date_bill_period_start;
          a15(indx) := t(ddindx).date_bill_period_end;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a19(indx) := t(ddindx).program_update_date;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_org_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).isl_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).ibt_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).late_charge_rec_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).cll_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).qte_line_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).txs_trx_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).bank_acct_id);
          a30(indx) := t(ddindx).attribute_category;
          a31(indx) := t(ddindx).attribute1;
          a32(indx) := t(ddindx).attribute2;
          a33(indx) := t(ddindx).attribute3;
          a34(indx) := t(ddindx).attribute4;
          a35(indx) := t(ddindx).attribute5;
          a36(indx) := t(ddindx).attribute6;
          a37(indx) := t(ddindx).attribute7;
          a38(indx) := t(ddindx).attribute8;
          a39(indx) := t(ddindx).attribute9;
          a40(indx) := t(ddindx).attribute10;
          a41(indx) := t(ddindx).attribute11;
          a42(indx) := t(ddindx).attribute12;
          a43(indx) := t(ddindx).attribute13;
          a44(indx) := t(ddindx).attribute14;
          a45(indx) := t(ddindx).attribute15;
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a47(indx) := t(ddindx).creation_date;
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a49(indx) := t(ddindx).last_update_date;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).txl_ar_line_number);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).txs_trx_line_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_til_pvt.okl_txl_ar_inv_lns_tl_tbl_type, a0 JTF_NUMBER_TABLE
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
  procedure rosetta_table_copy_out_p5(t okl_til_pvt.okl_txl_ar_inv_lns_tl_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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

  procedure rosetta_table_copy_in_p8(t out nocopy okl_til_pvt.tilv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_3000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
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
    , a42 JTF_VARCHAR2_TABLE_500
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_DATE_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
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
          t(ddindx).kle_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).tpl_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).til_id_reverses := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).inv_receiv_line_code := a7(indx);
          t(ddindx).sty_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).tai_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).acn_id_cost := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).quantity := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).description := a14(indx);
          t(ddindx).receivables_invoice_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).date_bill_period_start := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).amount_applied := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).date_bill_period_end := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).isl_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).ibt_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).late_charge_rec_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).cll_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).qte_line_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).txs_trx_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).bank_acct_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).attribute_category := a27(indx);
          t(ddindx).attribute1 := a28(indx);
          t(ddindx).attribute2 := a29(indx);
          t(ddindx).attribute3 := a30(indx);
          t(ddindx).attribute4 := a31(indx);
          t(ddindx).attribute5 := a32(indx);
          t(ddindx).attribute6 := a33(indx);
          t(ddindx).attribute7 := a34(indx);
          t(ddindx).attribute8 := a35(indx);
          t(ddindx).attribute9 := a36(indx);
          t(ddindx).attribute10 := a37(indx);
          t(ddindx).attribute11 := a38(indx);
          t(ddindx).attribute12 := a39(indx);
          t(ddindx).attribute13 := a40(indx);
          t(ddindx).attribute14 := a41(indx);
          t(ddindx).attribute15 := a42(indx);
          t(ddindx).request_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a47(indx));
          t(ddindx).inventory_org_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a50(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).txl_ar_line_number := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).txs_trx_line_id := rosetta_g_miss_num_map(a55(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_til_pvt.tilv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a42 out nocopy JTF_VARCHAR2_TABLE_500
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_DATE_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
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
    a42 := JTF_VARCHAR2_TABLE_500();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_DATE_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_3000();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
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
      a42 := JTF_VARCHAR2_TABLE_500();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_DATE_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).error_message;
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).tpl_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).til_id_reverses);
          a7(indx) := t(ddindx).inv_receiv_line_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).tai_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).acn_id_cost);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).quantity);
          a14(indx) := t(ddindx).description;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).receivables_invoice_id);
          a16(indx) := t(ddindx).date_bill_period_start;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).amount_applied);
          a18(indx) := t(ddindx).date_bill_period_end;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).isl_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).ibt_id);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).late_charge_rec_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).cll_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).qte_line_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).txs_trx_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).bank_acct_id);
          a27(indx) := t(ddindx).attribute_category;
          a28(indx) := t(ddindx).attribute1;
          a29(indx) := t(ddindx).attribute2;
          a30(indx) := t(ddindx).attribute3;
          a31(indx) := t(ddindx).attribute4;
          a32(indx) := t(ddindx).attribute5;
          a33(indx) := t(ddindx).attribute6;
          a34(indx) := t(ddindx).attribute7;
          a35(indx) := t(ddindx).attribute8;
          a36(indx) := t(ddindx).attribute9;
          a37(indx) := t(ddindx).attribute10;
          a38(indx) := t(ddindx).attribute11;
          a39(indx) := t(ddindx).attribute12;
          a40(indx) := t(ddindx).attribute13;
          a41(indx) := t(ddindx).attribute14;
          a42(indx) := t(ddindx).attribute15;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a46(indx) := t(ddindx).program_update_date;
          a47(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_org_id);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a50(indx) := t(ddindx).creation_date;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a52(indx) := t(ddindx).last_update_date;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).txl_ar_line_number);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).txs_trx_line_id);
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
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
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
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
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
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_til_pvt.tilv_rec_type;
    ddx_tilv_rec okl_til_pvt.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);


    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec,
      ddx_tilv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tilv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tilv_rec.object_version_number);
    p6_a2 := ddx_tilv_rec.error_message;
    p6_a3 := ddx_tilv_rec.sfwt_flag;
    p6_a4 := rosetta_g_miss_num_map(ddx_tilv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tilv_rec.tpl_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tilv_rec.til_id_reverses);
    p6_a7 := ddx_tilv_rec.inv_receiv_line_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_tilv_rec.sty_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tilv_rec.tai_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tilv_rec.acn_id_cost);
    p6_a11 := rosetta_g_miss_num_map(ddx_tilv_rec.amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_tilv_rec.line_number);
    p6_a13 := rosetta_g_miss_num_map(ddx_tilv_rec.quantity);
    p6_a14 := ddx_tilv_rec.description;
    p6_a15 := rosetta_g_miss_num_map(ddx_tilv_rec.receivables_invoice_id);
    p6_a16 := ddx_tilv_rec.date_bill_period_start;
    p6_a17 := rosetta_g_miss_num_map(ddx_tilv_rec.amount_applied);
    p6_a18 := ddx_tilv_rec.date_bill_period_end;
    p6_a19 := rosetta_g_miss_num_map(ddx_tilv_rec.isl_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_tilv_rec.ibt_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_tilv_rec.late_charge_rec_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_tilv_rec.cll_id);
    p6_a23 := rosetta_g_miss_num_map(ddx_tilv_rec.inventory_item_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_tilv_rec.qte_line_id);
    p6_a25 := rosetta_g_miss_num_map(ddx_tilv_rec.txs_trx_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_tilv_rec.bank_acct_id);
    p6_a27 := ddx_tilv_rec.attribute_category;
    p6_a28 := ddx_tilv_rec.attribute1;
    p6_a29 := ddx_tilv_rec.attribute2;
    p6_a30 := ddx_tilv_rec.attribute3;
    p6_a31 := ddx_tilv_rec.attribute4;
    p6_a32 := ddx_tilv_rec.attribute5;
    p6_a33 := ddx_tilv_rec.attribute6;
    p6_a34 := ddx_tilv_rec.attribute7;
    p6_a35 := ddx_tilv_rec.attribute8;
    p6_a36 := ddx_tilv_rec.attribute9;
    p6_a37 := ddx_tilv_rec.attribute10;
    p6_a38 := ddx_tilv_rec.attribute11;
    p6_a39 := ddx_tilv_rec.attribute12;
    p6_a40 := ddx_tilv_rec.attribute13;
    p6_a41 := ddx_tilv_rec.attribute14;
    p6_a42 := ddx_tilv_rec.attribute15;
    p6_a43 := rosetta_g_miss_num_map(ddx_tilv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tilv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_tilv_rec.program_id);
    p6_a46 := ddx_tilv_rec.program_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_tilv_rec.org_id);
    p6_a48 := rosetta_g_miss_num_map(ddx_tilv_rec.inventory_org_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_tilv_rec.created_by);
    p6_a50 := ddx_tilv_rec.creation_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_tilv_rec.last_updated_by);
    p6_a52 := ddx_tilv_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tilv_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_tilv_rec.txl_ar_line_number);
    p6_a55 := rosetta_g_miss_num_map(ddx_tilv_rec.txs_trx_line_id);
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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
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
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddx_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl,
      ddx_tilv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_til_pvt_w.rosetta_table_copy_out_p8(ddx_tilv_tbl, p6_a0
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
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
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
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_til_pvt.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);

    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec);

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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
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
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl);

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
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
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
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  DATE
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  DATE
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
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
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_til_pvt.tilv_rec_type;
    ddx_tilv_rec okl_til_pvt.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);


    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec,
      ddx_tilv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tilv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tilv_rec.object_version_number);
    p6_a2 := ddx_tilv_rec.error_message;
    p6_a3 := ddx_tilv_rec.sfwt_flag;
    p6_a4 := rosetta_g_miss_num_map(ddx_tilv_rec.kle_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_tilv_rec.tpl_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tilv_rec.til_id_reverses);
    p6_a7 := ddx_tilv_rec.inv_receiv_line_code;
    p6_a8 := rosetta_g_miss_num_map(ddx_tilv_rec.sty_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_tilv_rec.tai_id);
    p6_a10 := rosetta_g_miss_num_map(ddx_tilv_rec.acn_id_cost);
    p6_a11 := rosetta_g_miss_num_map(ddx_tilv_rec.amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_tilv_rec.line_number);
    p6_a13 := rosetta_g_miss_num_map(ddx_tilv_rec.quantity);
    p6_a14 := ddx_tilv_rec.description;
    p6_a15 := rosetta_g_miss_num_map(ddx_tilv_rec.receivables_invoice_id);
    p6_a16 := ddx_tilv_rec.date_bill_period_start;
    p6_a17 := rosetta_g_miss_num_map(ddx_tilv_rec.amount_applied);
    p6_a18 := ddx_tilv_rec.date_bill_period_end;
    p6_a19 := rosetta_g_miss_num_map(ddx_tilv_rec.isl_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_tilv_rec.ibt_id);
    p6_a21 := rosetta_g_miss_num_map(ddx_tilv_rec.late_charge_rec_id);
    p6_a22 := rosetta_g_miss_num_map(ddx_tilv_rec.cll_id);
    p6_a23 := rosetta_g_miss_num_map(ddx_tilv_rec.inventory_item_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_tilv_rec.qte_line_id);
    p6_a25 := rosetta_g_miss_num_map(ddx_tilv_rec.txs_trx_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_tilv_rec.bank_acct_id);
    p6_a27 := ddx_tilv_rec.attribute_category;
    p6_a28 := ddx_tilv_rec.attribute1;
    p6_a29 := ddx_tilv_rec.attribute2;
    p6_a30 := ddx_tilv_rec.attribute3;
    p6_a31 := ddx_tilv_rec.attribute4;
    p6_a32 := ddx_tilv_rec.attribute5;
    p6_a33 := ddx_tilv_rec.attribute6;
    p6_a34 := ddx_tilv_rec.attribute7;
    p6_a35 := ddx_tilv_rec.attribute8;
    p6_a36 := ddx_tilv_rec.attribute9;
    p6_a37 := ddx_tilv_rec.attribute10;
    p6_a38 := ddx_tilv_rec.attribute11;
    p6_a39 := ddx_tilv_rec.attribute12;
    p6_a40 := ddx_tilv_rec.attribute13;
    p6_a41 := ddx_tilv_rec.attribute14;
    p6_a42 := ddx_tilv_rec.attribute15;
    p6_a43 := rosetta_g_miss_num_map(ddx_tilv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_tilv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_tilv_rec.program_id);
    p6_a46 := ddx_tilv_rec.program_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_tilv_rec.org_id);
    p6_a48 := rosetta_g_miss_num_map(ddx_tilv_rec.inventory_org_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_tilv_rec.created_by);
    p6_a50 := ddx_tilv_rec.creation_date;
    p6_a51 := rosetta_g_miss_num_map(ddx_tilv_rec.last_updated_by);
    p6_a52 := ddx_tilv_rec.last_update_date;
    p6_a53 := rosetta_g_miss_num_map(ddx_tilv_rec.last_update_login);
    p6_a54 := rosetta_g_miss_num_map(ddx_tilv_rec.txl_ar_line_number);
    p6_a55 := rosetta_g_miss_num_map(ddx_tilv_rec.txs_trx_line_id);
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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
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
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_3000
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddx_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl,
      ddx_tilv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_til_pvt_w.rosetta_table_copy_out_p8(ddx_tilv_tbl, p6_a0
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
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
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
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_til_pvt.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);

    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec);

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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
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
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl);

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
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
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
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  DATE := fnd_api.g_miss_date
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  DATE := fnd_api.g_miss_date
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
  )

  as
    ddp_tilv_rec okl_til_pvt.tilv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tilv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tilv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tilv_rec.error_message := p5_a2;
    ddp_tilv_rec.sfwt_flag := p5_a3;
    ddp_tilv_rec.kle_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tilv_rec.tpl_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tilv_rec.til_id_reverses := rosetta_g_miss_num_map(p5_a6);
    ddp_tilv_rec.inv_receiv_line_code := p5_a7;
    ddp_tilv_rec.sty_id := rosetta_g_miss_num_map(p5_a8);
    ddp_tilv_rec.tai_id := rosetta_g_miss_num_map(p5_a9);
    ddp_tilv_rec.acn_id_cost := rosetta_g_miss_num_map(p5_a10);
    ddp_tilv_rec.amount := rosetta_g_miss_num_map(p5_a11);
    ddp_tilv_rec.line_number := rosetta_g_miss_num_map(p5_a12);
    ddp_tilv_rec.quantity := rosetta_g_miss_num_map(p5_a13);
    ddp_tilv_rec.description := p5_a14;
    ddp_tilv_rec.receivables_invoice_id := rosetta_g_miss_num_map(p5_a15);
    ddp_tilv_rec.date_bill_period_start := rosetta_g_miss_date_in_map(p5_a16);
    ddp_tilv_rec.amount_applied := rosetta_g_miss_num_map(p5_a17);
    ddp_tilv_rec.date_bill_period_end := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tilv_rec.isl_id := rosetta_g_miss_num_map(p5_a19);
    ddp_tilv_rec.ibt_id := rosetta_g_miss_num_map(p5_a20);
    ddp_tilv_rec.late_charge_rec_id := rosetta_g_miss_num_map(p5_a21);
    ddp_tilv_rec.cll_id := rosetta_g_miss_num_map(p5_a22);
    ddp_tilv_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a23);
    ddp_tilv_rec.qte_line_id := rosetta_g_miss_num_map(p5_a24);
    ddp_tilv_rec.txs_trx_id := rosetta_g_miss_num_map(p5_a25);
    ddp_tilv_rec.bank_acct_id := rosetta_g_miss_num_map(p5_a26);
    ddp_tilv_rec.attribute_category := p5_a27;
    ddp_tilv_rec.attribute1 := p5_a28;
    ddp_tilv_rec.attribute2 := p5_a29;
    ddp_tilv_rec.attribute3 := p5_a30;
    ddp_tilv_rec.attribute4 := p5_a31;
    ddp_tilv_rec.attribute5 := p5_a32;
    ddp_tilv_rec.attribute6 := p5_a33;
    ddp_tilv_rec.attribute7 := p5_a34;
    ddp_tilv_rec.attribute8 := p5_a35;
    ddp_tilv_rec.attribute9 := p5_a36;
    ddp_tilv_rec.attribute10 := p5_a37;
    ddp_tilv_rec.attribute11 := p5_a38;
    ddp_tilv_rec.attribute12 := p5_a39;
    ddp_tilv_rec.attribute13 := p5_a40;
    ddp_tilv_rec.attribute14 := p5_a41;
    ddp_tilv_rec.attribute15 := p5_a42;
    ddp_tilv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_tilv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_tilv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tilv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_tilv_rec.org_id := rosetta_g_miss_num_map(p5_a47);
    ddp_tilv_rec.inventory_org_id := rosetta_g_miss_num_map(p5_a48);
    ddp_tilv_rec.created_by := rosetta_g_miss_num_map(p5_a49);
    ddp_tilv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a50);
    ddp_tilv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a51);
    ddp_tilv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a52);
    ddp_tilv_rec.last_update_login := rosetta_g_miss_num_map(p5_a53);
    ddp_tilv_rec.txl_ar_line_number := rosetta_g_miss_num_map(p5_a54);
    ddp_tilv_rec.txs_trx_line_id := rosetta_g_miss_num_map(p5_a55);

    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_rec);

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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
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
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_NUMBER_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_DATE_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_DATE_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
  )

  as
    ddp_tilv_tbl okl_til_pvt.tilv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_til_pvt_w.rosetta_table_copy_in_p8(ddp_tilv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_til_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tilv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_til_pvt_w;

/