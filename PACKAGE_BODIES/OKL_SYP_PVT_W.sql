--------------------------------------------------------
--  DDL for Package Body OKL_SYP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SYP_PVT_W" as
  /* $Header: OKLISYPB.pls 120.15.12010000.2 2008/11/13 16:18:16 kkorrapo ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_syp_pvt.sypv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
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
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).delink_yn := a1(indx);
          t(ddindx).remk_subinventory := a2(indx);
          t(ddindx).remk_organization_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).remk_price_list_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).remk_process_code := a5(indx);
          t(ddindx).remk_item_template_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).remk_item_invoiced_code := a7(indx);
          t(ddindx).lease_inv_org_yn := a8(indx);
          t(ddindx).tax_upfront_yn := a9(indx);
          t(ddindx).tax_invoice_yn := a10(indx);
          t(ddindx).tax_schedule_yn := a11(indx);
          t(ddindx).tax_upfront_sty_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).category_set_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).validation_set_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).cancel_quotes_yn := a15(indx);
          t(ddindx).chk_accrual_previous_mnth_yn := a16(indx);
          t(ddindx).task_template_group_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).owner_type_code := a18(indx);
          t(ddindx).owner_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).item_inv_org_id := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).rpt_prod_book_type_code := a21(indx);
          t(ddindx).asst_add_book_type_code := a22(indx);
          t(ddindx).ccard_remittance_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).corporate_book := a24(indx);
          t(ddindx).tax_book_1 := a25(indx);
          t(ddindx).tax_book_2 := a26(indx);
          t(ddindx).depreciate_yn := a27(indx);
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).formula_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).asset_key_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).part_trmnt_apply_round_diff := a31(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a37(indx));
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
          t(ddindx).lseapp_seq_prefix_txt := a59(indx);
          t(ddindx).lseopp_seq_prefix_txt := a60(indx);
          t(ddindx).qckqte_seq_prefix_txt := a61(indx);
          t(ddindx).lseqte_seq_prefix_txt := a62(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_syp_pvt.sypv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
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
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
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
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
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
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
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
          a1(indx) := t(ddindx).delink_yn;
          a2(indx) := t(ddindx).remk_subinventory;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).remk_organization_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).remk_price_list_id);
          a5(indx) := t(ddindx).remk_process_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).remk_item_template_id);
          a7(indx) := t(ddindx).remk_item_invoiced_code;
          a8(indx) := t(ddindx).lease_inv_org_yn;
          a9(indx) := t(ddindx).tax_upfront_yn;
          a10(indx) := t(ddindx).tax_invoice_yn;
          a11(indx) := t(ddindx).tax_schedule_yn;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).tax_upfront_sty_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).category_set_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).validation_set_id);
          a15(indx) := t(ddindx).cancel_quotes_yn;
          a16(indx) := t(ddindx).chk_accrual_previous_mnth_yn;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).task_template_group_id);
          a18(indx) := t(ddindx).owner_type_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).owner_id);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).item_inv_org_id);
          a21(indx) := t(ddindx).rpt_prod_book_type_code;
          a22(indx) := t(ddindx).asst_add_book_type_code;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).ccard_remittance_id);
          a24(indx) := t(ddindx).corporate_book;
          a25(indx) := t(ddindx).tax_book_1;
          a26(indx) := t(ddindx).tax_book_2;
          a27(indx) := t(ddindx).depreciate_yn;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).formula_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).asset_key_id);
          a31(indx) := t(ddindx).part_trmnt_apply_round_diff;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a37(indx) := t(ddindx).program_update_date;
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
          a59(indx) := t(ddindx).lseapp_seq_prefix_txt;
          a60(indx) := t(ddindx).lseopp_seq_prefix_txt;
          a61(indx) := t(ddindx).qckqte_seq_prefix_txt;
          a62(indx) := t(ddindx).lseqte_seq_prefix_txt;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_syp_pvt.syp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_DATE_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
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
    , a46 JTF_VARCHAR2_TABLE_500
    , a47 JTF_VARCHAR2_TABLE_500
    , a48 JTF_VARCHAR2_TABLE_500
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_DATE_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).delink_yn := a1(indx);
          t(ddindx).remk_subinventory := a2(indx);
          t(ddindx).remk_organization_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).remk_price_list_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).remk_process_code := a5(indx);
          t(ddindx).remk_item_template_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).remk_item_invoiced_code := a7(indx);
          t(ddindx).lease_inv_org_yn := a8(indx);
          t(ddindx).tax_upfront_yn := a9(indx);
          t(ddindx).tax_invoice_yn := a10(indx);
          t(ddindx).tax_schedule_yn := a11(indx);
          t(ddindx).tax_upfront_sty_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).category_set_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).validation_set_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).cancel_quotes_yn := a15(indx);
          t(ddindx).chk_accrual_previous_mnth_yn := a16(indx);
          t(ddindx).task_template_group_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).owner_type_code := a18(indx);
          t(ddindx).owner_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).corporate_book := a20(indx);
          t(ddindx).tax_book_1 := a21(indx);
          t(ddindx).tax_book_2 := a22(indx);
          t(ddindx).depreciate_yn := a23(indx);
          t(ddindx).fa_location_id := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).formula_id := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).asset_key_id := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).part_trmnt_apply_round_diff := a27(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a33(indx));
          t(ddindx).attribute_category := a34(indx);
          t(ddindx).attribute1 := a35(indx);
          t(ddindx).attribute2 := a36(indx);
          t(ddindx).attribute3 := a37(indx);
          t(ddindx).attribute4 := a38(indx);
          t(ddindx).attribute5 := a39(indx);
          t(ddindx).attribute6 := a40(indx);
          t(ddindx).attribute7 := a41(indx);
          t(ddindx).attribute8 := a42(indx);
          t(ddindx).attribute9 := a43(indx);
          t(ddindx).attribute10 := a44(indx);
          t(ddindx).attribute11 := a45(indx);
          t(ddindx).attribute12 := a46(indx);
          t(ddindx).attribute13 := a47(indx);
          t(ddindx).attribute14 := a48(indx);
          t(ddindx).attribute15 := a49(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a51(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).item_inv_org_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).rpt_prod_book_type_code := a56(indx);
          t(ddindx).asst_add_book_type_code := a57(indx);
          t(ddindx).ccard_remittance_id := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).lseapp_seq_prefix_txt := a59(indx);
          t(ddindx).lseopp_seq_prefix_txt := a60(indx);
          t(ddindx).qckqte_seq_prefix_txt := a61(indx);
          t(ddindx).lseqte_seq_prefix_txt := a62(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_syp_pvt.syp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a46 out nocopy JTF_VARCHAR2_TABLE_500
    , a47 out nocopy JTF_VARCHAR2_TABLE_500
    , a48 out nocopy JTF_VARCHAR2_TABLE_500
    , a49 out nocopy JTF_VARCHAR2_TABLE_500
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_DATE_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
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
    a46 := JTF_VARCHAR2_TABLE_500();
    a47 := JTF_VARCHAR2_TABLE_500();
    a48 := JTF_VARCHAR2_TABLE_500();
    a49 := JTF_VARCHAR2_TABLE_500();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_DATE_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
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
      a46 := JTF_VARCHAR2_TABLE_500();
      a47 := JTF_VARCHAR2_TABLE_500();
      a48 := JTF_VARCHAR2_TABLE_500();
      a49 := JTF_VARCHAR2_TABLE_500();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_DATE_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
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
          a1(indx) := t(ddindx).delink_yn;
          a2(indx) := t(ddindx).remk_subinventory;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).remk_organization_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).remk_price_list_id);
          a5(indx) := t(ddindx).remk_process_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).remk_item_template_id);
          a7(indx) := t(ddindx).remk_item_invoiced_code;
          a8(indx) := t(ddindx).lease_inv_org_yn;
          a9(indx) := t(ddindx).tax_upfront_yn;
          a10(indx) := t(ddindx).tax_invoice_yn;
          a11(indx) := t(ddindx).tax_schedule_yn;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).tax_upfront_sty_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).category_set_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).validation_set_id);
          a15(indx) := t(ddindx).cancel_quotes_yn;
          a16(indx) := t(ddindx).chk_accrual_previous_mnth_yn;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).task_template_group_id);
          a18(indx) := t(ddindx).owner_type_code;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).owner_id);
          a20(indx) := t(ddindx).corporate_book;
          a21(indx) := t(ddindx).tax_book_1;
          a22(indx) := t(ddindx).tax_book_2;
          a23(indx) := t(ddindx).depreciate_yn;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).fa_location_id);
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).formula_id);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).asset_key_id);
          a27(indx) := t(ddindx).part_trmnt_apply_round_diff;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a33(indx) := t(ddindx).program_update_date;
          a34(indx) := t(ddindx).attribute_category;
          a35(indx) := t(ddindx).attribute1;
          a36(indx) := t(ddindx).attribute2;
          a37(indx) := t(ddindx).attribute3;
          a38(indx) := t(ddindx).attribute4;
          a39(indx) := t(ddindx).attribute5;
          a40(indx) := t(ddindx).attribute6;
          a41(indx) := t(ddindx).attribute7;
          a42(indx) := t(ddindx).attribute8;
          a43(indx) := t(ddindx).attribute9;
          a44(indx) := t(ddindx).attribute10;
          a45(indx) := t(ddindx).attribute11;
          a46(indx) := t(ddindx).attribute12;
          a47(indx) := t(ddindx).attribute13;
          a48(indx) := t(ddindx).attribute14;
          a49(indx) := t(ddindx).attribute15;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a51(indx) := t(ddindx).creation_date;
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a53(indx) := t(ddindx).last_update_date;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).item_inv_org_id);
          a56(indx) := t(ddindx).rpt_prod_book_type_code;
          a57(indx) := t(ddindx).asst_add_book_type_code;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).ccard_remittance_id);
          a59(indx) := t(ddindx).lseapp_seq_prefix_txt;
          a60(indx) := t(ddindx).lseopp_seq_prefix_txt;
          a61(indx) := t(ddindx).qckqte_seq_prefix_txt;
          a62(indx) := t(ddindx).lseqte_seq_prefix_txt;
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
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
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
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
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
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_syp_pvt.sypv_rec_type;
    ddx_sypv_rec okl_syp_pvt.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;


    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec,
      ddx_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sypv_rec.id);
    p6_a1 := ddx_sypv_rec.delink_yn;
    p6_a2 := ddx_sypv_rec.remk_subinventory;
    p6_a3 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_organization_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_price_list_id);
    p6_a5 := ddx_sypv_rec.remk_process_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_item_template_id);
    p6_a7 := ddx_sypv_rec.remk_item_invoiced_code;
    p6_a8 := ddx_sypv_rec.lease_inv_org_yn;
    p6_a9 := ddx_sypv_rec.tax_upfront_yn;
    p6_a10 := ddx_sypv_rec.tax_invoice_yn;
    p6_a11 := ddx_sypv_rec.tax_schedule_yn;
    p6_a12 := rosetta_g_miss_num_map(ddx_sypv_rec.tax_upfront_sty_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_sypv_rec.category_set_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_sypv_rec.validation_set_id);
    p6_a15 := ddx_sypv_rec.cancel_quotes_yn;
    p6_a16 := ddx_sypv_rec.chk_accrual_previous_mnth_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_sypv_rec.task_template_group_id);
    p6_a18 := ddx_sypv_rec.owner_type_code;
    p6_a19 := rosetta_g_miss_num_map(ddx_sypv_rec.owner_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_sypv_rec.item_inv_org_id);
    p6_a21 := ddx_sypv_rec.rpt_prod_book_type_code;
    p6_a22 := ddx_sypv_rec.asst_add_book_type_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_sypv_rec.ccard_remittance_id);
    p6_a24 := ddx_sypv_rec.corporate_book;
    p6_a25 := ddx_sypv_rec.tax_book_1;
    p6_a26 := ddx_sypv_rec.tax_book_2;
    p6_a27 := ddx_sypv_rec.depreciate_yn;
    p6_a28 := rosetta_g_miss_num_map(ddx_sypv_rec.fa_location_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_sypv_rec.formula_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_sypv_rec.asset_key_id);
    p6_a31 := ddx_sypv_rec.part_trmnt_apply_round_diff;
    p6_a32 := rosetta_g_miss_num_map(ddx_sypv_rec.object_version_number);
    p6_a33 := rosetta_g_miss_num_map(ddx_sypv_rec.org_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_sypv_rec.request_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_sypv_rec.program_application_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_sypv_rec.program_id);
    p6_a37 := ddx_sypv_rec.program_update_date;
    p6_a38 := ddx_sypv_rec.attribute_category;
    p6_a39 := ddx_sypv_rec.attribute1;
    p6_a40 := ddx_sypv_rec.attribute2;
    p6_a41 := ddx_sypv_rec.attribute3;
    p6_a42 := ddx_sypv_rec.attribute4;
    p6_a43 := ddx_sypv_rec.attribute5;
    p6_a44 := ddx_sypv_rec.attribute6;
    p6_a45 := ddx_sypv_rec.attribute7;
    p6_a46 := ddx_sypv_rec.attribute8;
    p6_a47 := ddx_sypv_rec.attribute9;
    p6_a48 := ddx_sypv_rec.attribute10;
    p6_a49 := ddx_sypv_rec.attribute11;
    p6_a50 := ddx_sypv_rec.attribute12;
    p6_a51 := ddx_sypv_rec.attribute13;
    p6_a52 := ddx_sypv_rec.attribute14;
    p6_a53 := ddx_sypv_rec.attribute15;
    p6_a54 := rosetta_g_miss_num_map(ddx_sypv_rec.created_by);
    p6_a55 := ddx_sypv_rec.creation_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_sypv_rec.last_updated_by);
    p6_a57 := ddx_sypv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_sypv_rec.last_update_login);
    p6_a59 := ddx_sypv_rec.lseapp_seq_prefix_txt;
    p6_a60 := ddx_sypv_rec.lseopp_seq_prefix_txt;
    p6_a61 := ddx_sypv_rec.qckqte_seq_prefix_txt;
    p6_a62 := ddx_sypv_rec.lseqte_seq_prefix_txt;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
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
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
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
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_syp_pvt.sypv_tbl_type;
    ddx_sypv_tbl okl_syp_pvt.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl,
      ddx_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_syp_pvt_w.rosetta_table_copy_out_p2(ddx_sypv_tbl, p6_a0
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
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
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
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_syp_pvt.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;

    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
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
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_syp_pvt.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
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
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
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
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_syp_pvt.sypv_rec_type;
    ddx_sypv_rec okl_syp_pvt.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;


    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec,
      ddx_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sypv_rec.id);
    p6_a1 := ddx_sypv_rec.delink_yn;
    p6_a2 := ddx_sypv_rec.remk_subinventory;
    p6_a3 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_organization_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_price_list_id);
    p6_a5 := ddx_sypv_rec.remk_process_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_item_template_id);
    p6_a7 := ddx_sypv_rec.remk_item_invoiced_code;
    p6_a8 := ddx_sypv_rec.lease_inv_org_yn;
    p6_a9 := ddx_sypv_rec.tax_upfront_yn;
    p6_a10 := ddx_sypv_rec.tax_invoice_yn;
    p6_a11 := ddx_sypv_rec.tax_schedule_yn;
    p6_a12 := rosetta_g_miss_num_map(ddx_sypv_rec.tax_upfront_sty_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_sypv_rec.category_set_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_sypv_rec.validation_set_id);
    p6_a15 := ddx_sypv_rec.cancel_quotes_yn;
    p6_a16 := ddx_sypv_rec.chk_accrual_previous_mnth_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_sypv_rec.task_template_group_id);
    p6_a18 := ddx_sypv_rec.owner_type_code;
    p6_a19 := rosetta_g_miss_num_map(ddx_sypv_rec.owner_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_sypv_rec.item_inv_org_id);
    p6_a21 := ddx_sypv_rec.rpt_prod_book_type_code;
    p6_a22 := ddx_sypv_rec.asst_add_book_type_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_sypv_rec.ccard_remittance_id);
    p6_a24 := ddx_sypv_rec.corporate_book;
    p6_a25 := ddx_sypv_rec.tax_book_1;
    p6_a26 := ddx_sypv_rec.tax_book_2;
    p6_a27 := ddx_sypv_rec.depreciate_yn;
    p6_a28 := rosetta_g_miss_num_map(ddx_sypv_rec.fa_location_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_sypv_rec.formula_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_sypv_rec.asset_key_id);
    p6_a31 := ddx_sypv_rec.part_trmnt_apply_round_diff;
    p6_a32 := rosetta_g_miss_num_map(ddx_sypv_rec.object_version_number);
    p6_a33 := rosetta_g_miss_num_map(ddx_sypv_rec.org_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_sypv_rec.request_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_sypv_rec.program_application_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_sypv_rec.program_id);
    p6_a37 := ddx_sypv_rec.program_update_date;
    p6_a38 := ddx_sypv_rec.attribute_category;
    p6_a39 := ddx_sypv_rec.attribute1;
    p6_a40 := ddx_sypv_rec.attribute2;
    p6_a41 := ddx_sypv_rec.attribute3;
    p6_a42 := ddx_sypv_rec.attribute4;
    p6_a43 := ddx_sypv_rec.attribute5;
    p6_a44 := ddx_sypv_rec.attribute6;
    p6_a45 := ddx_sypv_rec.attribute7;
    p6_a46 := ddx_sypv_rec.attribute8;
    p6_a47 := ddx_sypv_rec.attribute9;
    p6_a48 := ddx_sypv_rec.attribute10;
    p6_a49 := ddx_sypv_rec.attribute11;
    p6_a50 := ddx_sypv_rec.attribute12;
    p6_a51 := ddx_sypv_rec.attribute13;
    p6_a52 := ddx_sypv_rec.attribute14;
    p6_a53 := ddx_sypv_rec.attribute15;
    p6_a54 := rosetta_g_miss_num_map(ddx_sypv_rec.created_by);
    p6_a55 := ddx_sypv_rec.creation_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_sypv_rec.last_updated_by);
    p6_a57 := ddx_sypv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_sypv_rec.last_update_login);
    p6_a59 := ddx_sypv_rec.lseapp_seq_prefix_txt;
    p6_a60 := ddx_sypv_rec.lseopp_seq_prefix_txt;
    p6_a61 := ddx_sypv_rec.qckqte_seq_prefix_txt;
    p6_a62 := ddx_sypv_rec.lseqte_seq_prefix_txt;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
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
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
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
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_syp_pvt.sypv_tbl_type;
    ddx_sypv_tbl okl_syp_pvt.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl,
      ddx_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_syp_pvt_w.rosetta_table_copy_out_p2(ddx_sypv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
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
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_syp_pvt.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;

    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
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
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_syp_pvt.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
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
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_syp_pvt.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;

    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
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
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_syp_pvt.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_syp_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_syp_pvt_w;

/
