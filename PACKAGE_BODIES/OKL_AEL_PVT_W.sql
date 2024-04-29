--------------------------------------------------------
--  DDL for Package Body OKL_AEL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AEL_PVT_W" as
  /* $Header: OKLIAELB.pls 120.2 2005/12/02 12:58:22 dkagrawa noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_ael_pvt.ael_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_800
    , a18 JTF_VARCHAR2_TABLE_800
    , a19 JTF_VARCHAR2_TABLE_800
    , a20 JTF_VARCHAR2_TABLE_800
    , a21 JTF_VARCHAR2_TABLE_800
    , a22 JTF_VARCHAR2_TABLE_800
    , a23 JTF_VARCHAR2_TABLE_800
    , a24 JTF_VARCHAR2_TABLE_800
    , a25 JTF_VARCHAR2_TABLE_800
    , a26 JTF_VARCHAR2_TABLE_800
    , a27 JTF_VARCHAR2_TABLE_800
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_DATE_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_DATE_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ae_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).code_combination_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).ae_header_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).currency_conversion_type := a3(indx);
          t(ddindx).org_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).ae_line_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).ae_line_type_code := a6(indx);
          t(ddindx).source_table := a7(indx);
          t(ddindx).source_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).currency_code := a10(indx);
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).entered_dr := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).entered_cr := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).accounted_dr := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).accounted_cr := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).reference1 := a17(indx);
          t(ddindx).reference2 := a18(indx);
          t(ddindx).reference3 := a19(indx);
          t(ddindx).reference4 := a20(indx);
          t(ddindx).reference5 := a21(indx);
          t(ddindx).reference6 := a22(indx);
          t(ddindx).reference7 := a23(indx);
          t(ddindx).reference8 := a24(indx);
          t(ddindx).reference9 := a25(indx);
          t(ddindx).reference10 := a26(indx);
          t(ddindx).description := a27(indx);
          t(ddindx).third_party_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).third_party_sub_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).stat_amount := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).ussgl_transaction_code := a31(indx);
          t(ddindx).subledger_doc_sequence_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).accounting_error_code := a33(indx);
          t(ddindx).gl_transfer_error_code := a34(indx);
          t(ddindx).gl_sl_link_id := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).taxable_entered_dr := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).taxable_entered_cr := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).taxable_accounted_dr := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).taxable_accounted_cr := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).applied_from_trx_hdr_table := a40(indx);
          t(ddindx).applied_from_trx_hdr_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).applied_to_trx_hdr_table := a42(indx);
          t(ddindx).applied_to_trx_hdr_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).tax_link_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a50(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a52(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a53(indx));
          t(ddindx).account_overlay_source_id := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).subledger_doc_sequence_value := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).tax_code_id := rosetta_g_miss_num_map(a56(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_ael_pvt.ael_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_800
    , a18 out nocopy JTF_VARCHAR2_TABLE_800
    , a19 out nocopy JTF_VARCHAR2_TABLE_800
    , a20 out nocopy JTF_VARCHAR2_TABLE_800
    , a21 out nocopy JTF_VARCHAR2_TABLE_800
    , a22 out nocopy JTF_VARCHAR2_TABLE_800
    , a23 out nocopy JTF_VARCHAR2_TABLE_800
    , a24 out nocopy JTF_VARCHAR2_TABLE_800
    , a25 out nocopy JTF_VARCHAR2_TABLE_800
    , a26 out nocopy JTF_VARCHAR2_TABLE_800
    , a27 out nocopy JTF_VARCHAR2_TABLE_800
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_DATE_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_DATE_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_800();
    a18 := JTF_VARCHAR2_TABLE_800();
    a19 := JTF_VARCHAR2_TABLE_800();
    a20 := JTF_VARCHAR2_TABLE_800();
    a21 := JTF_VARCHAR2_TABLE_800();
    a22 := JTF_VARCHAR2_TABLE_800();
    a23 := JTF_VARCHAR2_TABLE_800();
    a24 := JTF_VARCHAR2_TABLE_800();
    a25 := JTF_VARCHAR2_TABLE_800();
    a26 := JTF_VARCHAR2_TABLE_800();
    a27 := JTF_VARCHAR2_TABLE_800();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_DATE_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_DATE_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_800();
      a18 := JTF_VARCHAR2_TABLE_800();
      a19 := JTF_VARCHAR2_TABLE_800();
      a20 := JTF_VARCHAR2_TABLE_800();
      a21 := JTF_VARCHAR2_TABLE_800();
      a22 := JTF_VARCHAR2_TABLE_800();
      a23 := JTF_VARCHAR2_TABLE_800();
      a24 := JTF_VARCHAR2_TABLE_800();
      a25 := JTF_VARCHAR2_TABLE_800();
      a26 := JTF_VARCHAR2_TABLE_800();
      a27 := JTF_VARCHAR2_TABLE_800();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_DATE_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_DATE_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).ae_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).code_combination_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).ae_header_id);
          a3(indx) := t(ddindx).currency_conversion_type;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).ae_line_number);
          a6(indx) := t(ddindx).ae_line_type_code;
          a7(indx) := t(ddindx).source_table;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).source_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a10(indx) := t(ddindx).currency_code;
          a11(indx) := t(ddindx).currency_conversion_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).entered_dr);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).entered_cr);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).accounted_dr);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).accounted_cr);
          a17(indx) := t(ddindx).reference1;
          a18(indx) := t(ddindx).reference2;
          a19(indx) := t(ddindx).reference3;
          a20(indx) := t(ddindx).reference4;
          a21(indx) := t(ddindx).reference5;
          a22(indx) := t(ddindx).reference6;
          a23(indx) := t(ddindx).reference7;
          a24(indx) := t(ddindx).reference8;
          a25(indx) := t(ddindx).reference9;
          a26(indx) := t(ddindx).reference10;
          a27(indx) := t(ddindx).description;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).third_party_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).third_party_sub_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).stat_amount);
          a31(indx) := t(ddindx).ussgl_transaction_code;
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).subledger_doc_sequence_id);
          a33(indx) := t(ddindx).accounting_error_code;
          a34(indx) := t(ddindx).gl_transfer_error_code;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).gl_sl_link_id);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).taxable_entered_dr);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).taxable_entered_cr);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).taxable_accounted_dr);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).taxable_accounted_cr);
          a40(indx) := t(ddindx).applied_from_trx_hdr_table;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).applied_from_trx_hdr_id);
          a42(indx) := t(ddindx).applied_to_trx_hdr_table;
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).applied_to_trx_hdr_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).tax_link_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a47(indx) := t(ddindx).program_update_date;
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a50(indx) := t(ddindx).creation_date;
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a52(indx) := t(ddindx).last_update_date;
          a53(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).account_overlay_source_id);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).subledger_doc_sequence_value);
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).tax_code_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_ael_pvt.aelv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_800
    , a17 JTF_VARCHAR2_TABLE_800
    , a18 JTF_VARCHAR2_TABLE_800
    , a19 JTF_VARCHAR2_TABLE_800
    , a20 JTF_VARCHAR2_TABLE_800
    , a21 JTF_VARCHAR2_TABLE_800
    , a22 JTF_VARCHAR2_TABLE_800
    , a23 JTF_VARCHAR2_TABLE_800
    , a24 JTF_VARCHAR2_TABLE_800
    , a25 JTF_VARCHAR2_TABLE_800
    , a26 JTF_VARCHAR2_TABLE_800
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_DATE_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_DATE_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ae_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).ae_header_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).currency_conversion_type := a3(indx);
          t(ddindx).code_combination_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).ae_line_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).ae_line_type_code := a7(indx);
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).entered_dr := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).entered_cr := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).accounted_dr := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).accounted_cr := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).source_table := a14(indx);
          t(ddindx).source_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).reference1 := a16(indx);
          t(ddindx).reference2 := a17(indx);
          t(ddindx).reference3 := a18(indx);
          t(ddindx).reference4 := a19(indx);
          t(ddindx).reference5 := a20(indx);
          t(ddindx).reference6 := a21(indx);
          t(ddindx).reference7 := a22(indx);
          t(ddindx).reference8 := a23(indx);
          t(ddindx).reference9 := a24(indx);
          t(ddindx).reference10 := a25(indx);
          t(ddindx).description := a26(indx);
          t(ddindx).third_party_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).third_party_sub_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).stat_amount := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).ussgl_transaction_code := a30(indx);
          t(ddindx).subledger_doc_sequence_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).accounting_error_code := a32(indx);
          t(ddindx).gl_transfer_error_code := a33(indx);
          t(ddindx).gl_sl_link_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).taxable_entered_dr := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).taxable_entered_cr := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).taxable_accounted_dr := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).taxable_accounted_cr := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).applied_from_trx_hdr_table := a39(indx);
          t(ddindx).applied_from_trx_hdr_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).applied_to_trx_hdr_table := a41(indx);
          t(ddindx).applied_to_trx_hdr_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).tax_link_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).currency_code := a44(indx);
          t(ddindx).program_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a46(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a47(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a48(indx));
          t(ddindx).aeh_tbl_index := rosetta_g_miss_num_map(a49(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a51(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a53(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).account_overlay_source_id := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).subledger_doc_sequence_value := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).tax_code_id := rosetta_g_miss_num_map(a57(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_ael_pvt.aelv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_800
    , a17 out nocopy JTF_VARCHAR2_TABLE_800
    , a18 out nocopy JTF_VARCHAR2_TABLE_800
    , a19 out nocopy JTF_VARCHAR2_TABLE_800
    , a20 out nocopy JTF_VARCHAR2_TABLE_800
    , a21 out nocopy JTF_VARCHAR2_TABLE_800
    , a22 out nocopy JTF_VARCHAR2_TABLE_800
    , a23 out nocopy JTF_VARCHAR2_TABLE_800
    , a24 out nocopy JTF_VARCHAR2_TABLE_800
    , a25 out nocopy JTF_VARCHAR2_TABLE_800
    , a26 out nocopy JTF_VARCHAR2_TABLE_800
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_DATE_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_DATE_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_800();
    a17 := JTF_VARCHAR2_TABLE_800();
    a18 := JTF_VARCHAR2_TABLE_800();
    a19 := JTF_VARCHAR2_TABLE_800();
    a20 := JTF_VARCHAR2_TABLE_800();
    a21 := JTF_VARCHAR2_TABLE_800();
    a22 := JTF_VARCHAR2_TABLE_800();
    a23 := JTF_VARCHAR2_TABLE_800();
    a24 := JTF_VARCHAR2_TABLE_800();
    a25 := JTF_VARCHAR2_TABLE_800();
    a26 := JTF_VARCHAR2_TABLE_800();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_DATE_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_DATE_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_800();
      a17 := JTF_VARCHAR2_TABLE_800();
      a18 := JTF_VARCHAR2_TABLE_800();
      a19 := JTF_VARCHAR2_TABLE_800();
      a20 := JTF_VARCHAR2_TABLE_800();
      a21 := JTF_VARCHAR2_TABLE_800();
      a22 := JTF_VARCHAR2_TABLE_800();
      a23 := JTF_VARCHAR2_TABLE_800();
      a24 := JTF_VARCHAR2_TABLE_800();
      a25 := JTF_VARCHAR2_TABLE_800();
      a26 := JTF_VARCHAR2_TABLE_800();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_DATE_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_DATE_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).ae_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).ae_header_id);
          a3(indx) := t(ddindx).currency_conversion_type;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).code_combination_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).ae_line_number);
          a7(indx) := t(ddindx).ae_line_type_code;
          a8(indx) := t(ddindx).currency_conversion_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).entered_dr);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).entered_cr);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).accounted_dr);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).accounted_cr);
          a14(indx) := t(ddindx).source_table;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).source_id);
          a16(indx) := t(ddindx).reference1;
          a17(indx) := t(ddindx).reference2;
          a18(indx) := t(ddindx).reference3;
          a19(indx) := t(ddindx).reference4;
          a20(indx) := t(ddindx).reference5;
          a21(indx) := t(ddindx).reference6;
          a22(indx) := t(ddindx).reference7;
          a23(indx) := t(ddindx).reference8;
          a24(indx) := t(ddindx).reference9;
          a25(indx) := t(ddindx).reference10;
          a26(indx) := t(ddindx).description;
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).third_party_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).third_party_sub_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).stat_amount);
          a30(indx) := t(ddindx).ussgl_transaction_code;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).subledger_doc_sequence_id);
          a32(indx) := t(ddindx).accounting_error_code;
          a33(indx) := t(ddindx).gl_transfer_error_code;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).gl_sl_link_id);
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).taxable_entered_dr);
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).taxable_entered_cr);
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).taxable_accounted_dr);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).taxable_accounted_cr);
          a39(indx) := t(ddindx).applied_from_trx_hdr_table;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).applied_from_trx_hdr_id);
          a41(indx) := t(ddindx).applied_to_trx_hdr_table;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).applied_to_trx_hdr_id);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).tax_link_id);
          a44(indx) := t(ddindx).currency_code;
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a46(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a47(indx) := t(ddindx).program_update_date;
          a48(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a49(indx) := rosetta_g_miss_num_map(t(ddindx).aeh_tbl_index);
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a51(indx) := t(ddindx).creation_date;
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a53(indx) := t(ddindx).last_update_date;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).account_overlay_source_id);
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).subledger_doc_sequence_value);
          a57(indx) := rosetta_g_miss_num_map(t(ddindx).tax_code_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy okl_ael_pvt.ae_line_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t okl_ael_pvt.ae_line_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy okl_ael_pvt.account_overlay_source_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_ael_pvt.account_overlay_source_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_ael_pvt.subledger_doc_seq_value_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_ael_pvt.subledger_doc_seq_value_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out nocopy okl_ael_pvt.tax_code_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okl_ael_pvt.tax_code_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy okl_ael_pvt.ae_line_number_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t okl_ael_pvt.ae_line_number_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p11(t out nocopy okl_ael_pvt.code_combination_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_ael_pvt.code_combination_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p12(t out nocopy okl_ael_pvt.ae_header_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t okl_ael_pvt.ae_header_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p13(t out nocopy okl_ael_pvt.currency_conversion_type_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t okl_ael_pvt.currency_conversion_type_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p14(t out nocopy okl_ael_pvt.ae_line_type_code_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p14;
  procedure rosetta_table_copy_out_p14(t okl_ael_pvt.ae_line_type_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p14;

  procedure rosetta_table_copy_in_p15(t out nocopy okl_ael_pvt.source_table_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t okl_ael_pvt.source_table_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure rosetta_table_copy_in_p16(t out nocopy okl_ael_pvt.source_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p16;
  procedure rosetta_table_copy_out_p16(t okl_ael_pvt.source_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p16;

  procedure rosetta_table_copy_in_p17(t out nocopy okl_ael_pvt.object_version_number_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t okl_ael_pvt.object_version_number_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure rosetta_table_copy_in_p18(t out nocopy okl_ael_pvt.currency_code_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p18;
  procedure rosetta_table_copy_out_p18(t okl_ael_pvt.currency_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p18;

  procedure rosetta_table_copy_in_p19(t out nocopy okl_ael_pvt.currency_conversion_date_typ, a0 JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_date_in_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t okl_ael_pvt.currency_conversion_date_typ, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_date_in_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p20(t out nocopy okl_ael_pvt.currency_conversion_rate_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t okl_ael_pvt.currency_conversion_rate_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure rosetta_table_copy_in_p21(t out nocopy okl_ael_pvt.entered_dr_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t okl_ael_pvt.entered_dr_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure rosetta_table_copy_in_p22(t out nocopy okl_ael_pvt.entered_cr_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p22;
  procedure rosetta_table_copy_out_p22(t okl_ael_pvt.entered_cr_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p22;

  procedure rosetta_table_copy_in_p23(t out nocopy okl_ael_pvt.accounted_dr_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_ael_pvt.accounted_dr_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure rosetta_table_copy_in_p24(t out nocopy okl_ael_pvt.accounted_cr_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p24;
  procedure rosetta_table_copy_out_p24(t okl_ael_pvt.accounted_cr_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p24;

  procedure rosetta_table_copy_in_p25(t out nocopy okl_ael_pvt.reference1_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p25;
  procedure rosetta_table_copy_out_p25(t okl_ael_pvt.reference1_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p25;

  procedure rosetta_table_copy_in_p26(t out nocopy okl_ael_pvt.reference2_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t okl_ael_pvt.reference2_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p27(t out nocopy okl_ael_pvt.reference3_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p27;
  procedure rosetta_table_copy_out_p27(t okl_ael_pvt.reference3_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p27;

  procedure rosetta_table_copy_in_p28(t out nocopy okl_ael_pvt.reference4_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p28;
  procedure rosetta_table_copy_out_p28(t okl_ael_pvt.reference4_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p28;

  procedure rosetta_table_copy_in_p29(t out nocopy okl_ael_pvt.reference5_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p29;
  procedure rosetta_table_copy_out_p29(t okl_ael_pvt.reference5_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p29;

  procedure rosetta_table_copy_in_p30(t out nocopy okl_ael_pvt.reference6_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p30;
  procedure rosetta_table_copy_out_p30(t okl_ael_pvt.reference6_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p30;

  procedure rosetta_table_copy_in_p31(t out nocopy okl_ael_pvt.reference7_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t okl_ael_pvt.reference7_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p31;

  procedure rosetta_table_copy_in_p32(t out nocopy okl_ael_pvt.reference8_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p32;
  procedure rosetta_table_copy_out_p32(t okl_ael_pvt.reference8_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p32;

  procedure rosetta_table_copy_in_p33(t out nocopy okl_ael_pvt.reference9_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p33;
  procedure rosetta_table_copy_out_p33(t okl_ael_pvt.reference9_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p33;

  procedure rosetta_table_copy_in_p34(t out nocopy okl_ael_pvt.reference10_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p34;
  procedure rosetta_table_copy_out_p34(t okl_ael_pvt.reference10_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p34;

  procedure rosetta_table_copy_in_p35(t out nocopy okl_ael_pvt.description_typ, a0 JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p35;
  procedure rosetta_table_copy_out_p35(t okl_ael_pvt.description_typ, a0 out nocopy JTF_VARCHAR2_TABLE_800) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_800();
  else
      a0 := JTF_VARCHAR2_TABLE_800();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p35;

  procedure rosetta_table_copy_in_p36(t out nocopy okl_ael_pvt.third_party_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p36;
  procedure rosetta_table_copy_out_p36(t okl_ael_pvt.third_party_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p36;

  procedure rosetta_table_copy_in_p37(t out nocopy okl_ael_pvt.third_party_sub_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p37;
  procedure rosetta_table_copy_out_p37(t okl_ael_pvt.third_party_sub_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p37;

  procedure rosetta_table_copy_in_p38(t out nocopy okl_ael_pvt.stat_amount_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p38;
  procedure rosetta_table_copy_out_p38(t okl_ael_pvt.stat_amount_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p38;

  procedure rosetta_table_copy_in_p39(t out nocopy okl_ael_pvt.ussgl_transaction_code_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p39;
  procedure rosetta_table_copy_out_p39(t okl_ael_pvt.ussgl_transaction_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p39;

  procedure rosetta_table_copy_in_p40(t out nocopy okl_ael_pvt.subledger_doc_sequence_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p40;
  procedure rosetta_table_copy_out_p40(t okl_ael_pvt.subledger_doc_sequence_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p40;

  procedure rosetta_table_copy_in_p41(t out nocopy okl_ael_pvt.accounting_error_code_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t okl_ael_pvt.accounting_error_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure rosetta_table_copy_in_p42(t out nocopy okl_ael_pvt.gl_transfer_error_code_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p42;
  procedure rosetta_table_copy_out_p42(t okl_ael_pvt.gl_transfer_error_code_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p42;

  procedure rosetta_table_copy_in_p43(t out nocopy okl_ael_pvt.gl_sl_link_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p43;
  procedure rosetta_table_copy_out_p43(t okl_ael_pvt.gl_sl_link_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p43;

  procedure rosetta_table_copy_in_p44(t out nocopy okl_ael_pvt.taxable_entered_dr_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p44;
  procedure rosetta_table_copy_out_p44(t okl_ael_pvt.taxable_entered_dr_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p44;

  procedure rosetta_table_copy_in_p45(t out nocopy okl_ael_pvt.taxable_entered_cr_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p45;
  procedure rosetta_table_copy_out_p45(t okl_ael_pvt.taxable_entered_cr_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p45;

  procedure rosetta_table_copy_in_p46(t out nocopy okl_ael_pvt.taxable_accounted_dr_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p46;
  procedure rosetta_table_copy_out_p46(t okl_ael_pvt.taxable_accounted_dr_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p46;

  procedure rosetta_table_copy_in_p47(t out nocopy okl_ael_pvt.taxable_accounted_cr_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p47;
  procedure rosetta_table_copy_out_p47(t okl_ael_pvt.taxable_accounted_cr_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p47;

  procedure rosetta_table_copy_in_p48(t out nocopy okl_ael_pvt.applied_from_trx_hdr_tab_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p48;
  procedure rosetta_table_copy_out_p48(t okl_ael_pvt.applied_from_trx_hdr_tab_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p48;

  procedure rosetta_table_copy_in_p49(t out nocopy okl_ael_pvt.applied_from_trx_hdr_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p49;
  procedure rosetta_table_copy_out_p49(t okl_ael_pvt.applied_from_trx_hdr_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p49;

  procedure rosetta_table_copy_in_p50(t out nocopy okl_ael_pvt.applied_to_trx_hdr_table_typ, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p50;
  procedure rosetta_table_copy_out_p50(t okl_ael_pvt.applied_to_trx_hdr_table_typ, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p50;

  procedure rosetta_table_copy_in_p51(t out nocopy okl_ael_pvt.applied_to_trx_hdr_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p51;
  procedure rosetta_table_copy_out_p51(t okl_ael_pvt.applied_to_trx_hdr_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p51;

  procedure rosetta_table_copy_in_p52(t out nocopy okl_ael_pvt.tax_link_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p52;
  procedure rosetta_table_copy_out_p52(t okl_ael_pvt.tax_link_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p52;

  procedure rosetta_table_copy_in_p53(t out nocopy okl_ael_pvt.org_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p53;
  procedure rosetta_table_copy_out_p53(t okl_ael_pvt.org_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p53;

  procedure rosetta_table_copy_in_p54(t out nocopy okl_ael_pvt.program_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p54;
  procedure rosetta_table_copy_out_p54(t okl_ael_pvt.program_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p54;

  procedure rosetta_table_copy_in_p55(t out nocopy okl_ael_pvt.program_application_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p55;
  procedure rosetta_table_copy_out_p55(t okl_ael_pvt.program_application_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p55;

  procedure rosetta_table_copy_in_p56(t out nocopy okl_ael_pvt.program_update_date_typ, a0 JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_date_in_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p56;
  procedure rosetta_table_copy_out_p56(t okl_ael_pvt.program_update_date_typ, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_date_in_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p56;

  procedure rosetta_table_copy_in_p57(t out nocopy okl_ael_pvt.request_id_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p57;
  procedure rosetta_table_copy_out_p57(t okl_ael_pvt.request_id_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p57;

  procedure rosetta_table_copy_in_p58(t out nocopy okl_ael_pvt.created_by_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p58;
  procedure rosetta_table_copy_out_p58(t okl_ael_pvt.created_by_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p58;

  procedure rosetta_table_copy_in_p59(t out nocopy okl_ael_pvt.creation_date_typ, a0 JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_date_in_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p59;
  procedure rosetta_table_copy_out_p59(t okl_ael_pvt.creation_date_typ, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_date_in_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p59;

  procedure rosetta_table_copy_in_p60(t out nocopy okl_ael_pvt.last_updated_by_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p60;
  procedure rosetta_table_copy_out_p60(t okl_ael_pvt.last_updated_by_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p60;

  procedure rosetta_table_copy_in_p61(t out nocopy okl_ael_pvt.last_update_date_typ, a0 JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_date_in_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p61;
  procedure rosetta_table_copy_out_p61(t okl_ael_pvt.last_update_date_typ, a0 out nocopy JTF_DATE_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
  else
      a0 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_date_in_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p61;

  procedure rosetta_table_copy_in_p62(t out nocopy okl_ael_pvt.last_update_login_typ, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p62;
  procedure rosetta_table_copy_out_p62(t okl_ael_pvt.last_update_login_typ, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p62;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_ael_pvt.aelv_rec_type;
    ddx_aelv_rec okl_ael_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);


    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec,
      ddx_aelv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aelv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_header_id);
    p6_a3 := ddx_aelv_rec.currency_conversion_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_aelv_rec.code_combination_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_aelv_rec.org_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_number);
    p6_a7 := ddx_aelv_rec.ae_line_type_code;
    p6_a8 := ddx_aelv_rec.currency_conversion_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_aelv_rec.currency_conversion_rate);
    p6_a10 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_dr);
    p6_a11 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_cr);
    p6_a12 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_dr);
    p6_a13 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_cr);
    p6_a14 := ddx_aelv_rec.source_table;
    p6_a15 := rosetta_g_miss_num_map(ddx_aelv_rec.source_id);
    p6_a16 := ddx_aelv_rec.reference1;
    p6_a17 := ddx_aelv_rec.reference2;
    p6_a18 := ddx_aelv_rec.reference3;
    p6_a19 := ddx_aelv_rec.reference4;
    p6_a20 := ddx_aelv_rec.reference5;
    p6_a21 := ddx_aelv_rec.reference6;
    p6_a22 := ddx_aelv_rec.reference7;
    p6_a23 := ddx_aelv_rec.reference8;
    p6_a24 := ddx_aelv_rec.reference9;
    p6_a25 := ddx_aelv_rec.reference10;
    p6_a26 := ddx_aelv_rec.description;
    p6_a27 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_sub_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_aelv_rec.stat_amount);
    p6_a30 := ddx_aelv_rec.ussgl_transaction_code;
    p6_a31 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_id);
    p6_a32 := ddx_aelv_rec.accounting_error_code;
    p6_a33 := ddx_aelv_rec.gl_transfer_error_code;
    p6_a34 := rosetta_g_miss_num_map(ddx_aelv_rec.gl_sl_link_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_dr);
    p6_a36 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_cr);
    p6_a37 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_dr);
    p6_a38 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_cr);
    p6_a39 := ddx_aelv_rec.applied_from_trx_hdr_table;
    p6_a40 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_from_trx_hdr_id);
    p6_a41 := ddx_aelv_rec.applied_to_trx_hdr_table;
    p6_a42 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_to_trx_hdr_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_link_id);
    p6_a44 := ddx_aelv_rec.currency_code;
    p6_a45 := rosetta_g_miss_num_map(ddx_aelv_rec.program_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_aelv_rec.program_application_id);
    p6_a47 := ddx_aelv_rec.program_update_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_aelv_rec.request_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_aelv_rec.aeh_tbl_index);
    p6_a50 := rosetta_g_miss_num_map(ddx_aelv_rec.created_by);
    p6_a51 := ddx_aelv_rec.creation_date;
    p6_a52 := rosetta_g_miss_num_map(ddx_aelv_rec.last_updated_by);
    p6_a53 := ddx_aelv_rec.last_update_date;
    p6_a54 := rosetta_g_miss_num_map(ddx_aelv_rec.last_update_login);
    p6_a55 := rosetta_g_miss_num_map(ddx_aelv_rec.account_overlay_source_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_value);
    p6_a57 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_code_id);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddx_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl,
      ddx_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ael_pvt_w.rosetta_table_copy_out_p5(ddx_aelv_tbl, p6_a0
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
      );
  end;

  procedure insert_row_perf(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddx_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.insert_row_perf(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl,
      ddx_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ael_pvt_w.rosetta_table_copy_out_p5(ddx_aelv_tbl, p6_a0
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
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_ael_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);

    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl);

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
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  DATE
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  DATE
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  DATE
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_ael_pvt.aelv_rec_type;
    ddx_aelv_rec okl_ael_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);


    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec,
      ddx_aelv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aelv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_header_id);
    p6_a3 := ddx_aelv_rec.currency_conversion_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_aelv_rec.code_combination_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_aelv_rec.org_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_aelv_rec.ae_line_number);
    p6_a7 := ddx_aelv_rec.ae_line_type_code;
    p6_a8 := ddx_aelv_rec.currency_conversion_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_aelv_rec.currency_conversion_rate);
    p6_a10 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_dr);
    p6_a11 := rosetta_g_miss_num_map(ddx_aelv_rec.entered_cr);
    p6_a12 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_dr);
    p6_a13 := rosetta_g_miss_num_map(ddx_aelv_rec.accounted_cr);
    p6_a14 := ddx_aelv_rec.source_table;
    p6_a15 := rosetta_g_miss_num_map(ddx_aelv_rec.source_id);
    p6_a16 := ddx_aelv_rec.reference1;
    p6_a17 := ddx_aelv_rec.reference2;
    p6_a18 := ddx_aelv_rec.reference3;
    p6_a19 := ddx_aelv_rec.reference4;
    p6_a20 := ddx_aelv_rec.reference5;
    p6_a21 := ddx_aelv_rec.reference6;
    p6_a22 := ddx_aelv_rec.reference7;
    p6_a23 := ddx_aelv_rec.reference8;
    p6_a24 := ddx_aelv_rec.reference9;
    p6_a25 := ddx_aelv_rec.reference10;
    p6_a26 := ddx_aelv_rec.description;
    p6_a27 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_aelv_rec.third_party_sub_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_aelv_rec.stat_amount);
    p6_a30 := ddx_aelv_rec.ussgl_transaction_code;
    p6_a31 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_id);
    p6_a32 := ddx_aelv_rec.accounting_error_code;
    p6_a33 := ddx_aelv_rec.gl_transfer_error_code;
    p6_a34 := rosetta_g_miss_num_map(ddx_aelv_rec.gl_sl_link_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_dr);
    p6_a36 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_entered_cr);
    p6_a37 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_dr);
    p6_a38 := rosetta_g_miss_num_map(ddx_aelv_rec.taxable_accounted_cr);
    p6_a39 := ddx_aelv_rec.applied_from_trx_hdr_table;
    p6_a40 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_from_trx_hdr_id);
    p6_a41 := ddx_aelv_rec.applied_to_trx_hdr_table;
    p6_a42 := rosetta_g_miss_num_map(ddx_aelv_rec.applied_to_trx_hdr_id);
    p6_a43 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_link_id);
    p6_a44 := ddx_aelv_rec.currency_code;
    p6_a45 := rosetta_g_miss_num_map(ddx_aelv_rec.program_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_aelv_rec.program_application_id);
    p6_a47 := ddx_aelv_rec.program_update_date;
    p6_a48 := rosetta_g_miss_num_map(ddx_aelv_rec.request_id);
    p6_a49 := rosetta_g_miss_num_map(ddx_aelv_rec.aeh_tbl_index);
    p6_a50 := rosetta_g_miss_num_map(ddx_aelv_rec.created_by);
    p6_a51 := ddx_aelv_rec.creation_date;
    p6_a52 := rosetta_g_miss_num_map(ddx_aelv_rec.last_updated_by);
    p6_a53 := ddx_aelv_rec.last_update_date;
    p6_a54 := rosetta_g_miss_num_map(ddx_aelv_rec.last_update_login);
    p6_a55 := rosetta_g_miss_num_map(ddx_aelv_rec.account_overlay_source_id);
    p6_a56 := rosetta_g_miss_num_map(ddx_aelv_rec.subledger_doc_sequence_value);
    p6_a57 := rosetta_g_miss_num_map(ddx_aelv_rec.tax_code_id);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_800
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_DATE_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_DATE_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_DATE_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddx_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl,
      ddx_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ael_pvt_w.rosetta_table_copy_out_p5(ddx_aelv_tbl, p6_a0
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
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_ael_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);

    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl);

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
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  DATE := fnd_api.g_miss_date
    , p5_a48  NUMBER := 0-1962.0724
    , p5_a49  NUMBER := 0-1962.0724
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  DATE := fnd_api.g_miss_date
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  DATE := fnd_api.g_miss_date
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  NUMBER := 0-1962.0724
  )

  as
    ddp_aelv_rec okl_ael_pvt.aelv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aelv_rec.ae_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_aelv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aelv_rec.ae_header_id := rosetta_g_miss_num_map(p5_a2);
    ddp_aelv_rec.currency_conversion_type := p5_a3;
    ddp_aelv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_aelv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_aelv_rec.ae_line_number := rosetta_g_miss_num_map(p5_a6);
    ddp_aelv_rec.ae_line_type_code := p5_a7;
    ddp_aelv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_aelv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_aelv_rec.entered_dr := rosetta_g_miss_num_map(p5_a10);
    ddp_aelv_rec.entered_cr := rosetta_g_miss_num_map(p5_a11);
    ddp_aelv_rec.accounted_dr := rosetta_g_miss_num_map(p5_a12);
    ddp_aelv_rec.accounted_cr := rosetta_g_miss_num_map(p5_a13);
    ddp_aelv_rec.source_table := p5_a14;
    ddp_aelv_rec.source_id := rosetta_g_miss_num_map(p5_a15);
    ddp_aelv_rec.reference1 := p5_a16;
    ddp_aelv_rec.reference2 := p5_a17;
    ddp_aelv_rec.reference3 := p5_a18;
    ddp_aelv_rec.reference4 := p5_a19;
    ddp_aelv_rec.reference5 := p5_a20;
    ddp_aelv_rec.reference6 := p5_a21;
    ddp_aelv_rec.reference7 := p5_a22;
    ddp_aelv_rec.reference8 := p5_a23;
    ddp_aelv_rec.reference9 := p5_a24;
    ddp_aelv_rec.reference10 := p5_a25;
    ddp_aelv_rec.description := p5_a26;
    ddp_aelv_rec.third_party_id := rosetta_g_miss_num_map(p5_a27);
    ddp_aelv_rec.third_party_sub_id := rosetta_g_miss_num_map(p5_a28);
    ddp_aelv_rec.stat_amount := rosetta_g_miss_num_map(p5_a29);
    ddp_aelv_rec.ussgl_transaction_code := p5_a30;
    ddp_aelv_rec.subledger_doc_sequence_id := rosetta_g_miss_num_map(p5_a31);
    ddp_aelv_rec.accounting_error_code := p5_a32;
    ddp_aelv_rec.gl_transfer_error_code := p5_a33;
    ddp_aelv_rec.gl_sl_link_id := rosetta_g_miss_num_map(p5_a34);
    ddp_aelv_rec.taxable_entered_dr := rosetta_g_miss_num_map(p5_a35);
    ddp_aelv_rec.taxable_entered_cr := rosetta_g_miss_num_map(p5_a36);
    ddp_aelv_rec.taxable_accounted_dr := rosetta_g_miss_num_map(p5_a37);
    ddp_aelv_rec.taxable_accounted_cr := rosetta_g_miss_num_map(p5_a38);
    ddp_aelv_rec.applied_from_trx_hdr_table := p5_a39;
    ddp_aelv_rec.applied_from_trx_hdr_id := rosetta_g_miss_num_map(p5_a40);
    ddp_aelv_rec.applied_to_trx_hdr_table := p5_a41;
    ddp_aelv_rec.applied_to_trx_hdr_id := rosetta_g_miss_num_map(p5_a42);
    ddp_aelv_rec.tax_link_id := rosetta_g_miss_num_map(p5_a43);
    ddp_aelv_rec.currency_code := p5_a44;
    ddp_aelv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_aelv_rec.program_application_id := rosetta_g_miss_num_map(p5_a46);
    ddp_aelv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a47);
    ddp_aelv_rec.request_id := rosetta_g_miss_num_map(p5_a48);
    ddp_aelv_rec.aeh_tbl_index := rosetta_g_miss_num_map(p5_a49);
    ddp_aelv_rec.created_by := rosetta_g_miss_num_map(p5_a50);
    ddp_aelv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a51);
    ddp_aelv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a52);
    ddp_aelv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a53);
    ddp_aelv_rec.last_update_login := rosetta_g_miss_num_map(p5_a54);
    ddp_aelv_rec.account_overlay_source_id := rosetta_g_miss_num_map(p5_a55);
    ddp_aelv_rec.subledger_doc_sequence_value := rosetta_g_miss_num_map(p5_a56);
    ddp_aelv_rec.tax_code_id := rosetta_g_miss_num_map(p5_a57);

    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_rec);

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
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_800
    , p5_a17 JTF_VARCHAR2_TABLE_800
    , p5_a18 JTF_VARCHAR2_TABLE_800
    , p5_a19 JTF_VARCHAR2_TABLE_800
    , p5_a20 JTF_VARCHAR2_TABLE_800
    , p5_a21 JTF_VARCHAR2_TABLE_800
    , p5_a22 JTF_VARCHAR2_TABLE_800
    , p5_a23 JTF_VARCHAR2_TABLE_800
    , p5_a24 JTF_VARCHAR2_TABLE_800
    , p5_a25 JTF_VARCHAR2_TABLE_800
    , p5_a26 JTF_VARCHAR2_TABLE_800
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_VARCHAR2_TABLE_100
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_NUMBER_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_DATE_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_DATE_TABLE
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_NUMBER_TABLE
  )

  as
    ddp_aelv_tbl okl_ael_pvt.aelv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ael_pvt_w.rosetta_table_copy_in_p5(ddp_aelv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ael_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aelv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_ael_pvt_w;

/
