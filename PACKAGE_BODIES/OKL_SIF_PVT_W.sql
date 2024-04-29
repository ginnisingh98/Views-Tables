--------------------------------------------------------
--  DDL for Package Body OKL_SIF_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIF_PVT_W" as
  /* $Header: OKLISIFB.pls 115.9 2002/12/23 06:41:51 smahapat noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_sif_pvt.sif_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
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
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_400
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).fasb_acct_treatment_method := a2(indx);
          t(ddindx).date_payments_commencement := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).country := a4(indx);
          t(ddindx).security_deposit_amount := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).date_delivery := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).irs_tax_treatment_method := a7(indx);
          t(ddindx).sif_mode := a8(indx);
          t(ddindx).pricing_template_name := a9(indx);
          t(ddindx).date_sec_deposit_collected := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).transaction_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).total_funding := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).sis_code := a13(indx);
          t(ddindx).khr_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).adjust := a15(indx);
          t(ddindx).implicit_interest_rate := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).adjustment_method := a17(indx);
          t(ddindx).date_processed := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).orp_code := a19(indx);
          t(ddindx).lending_rate := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).rvi_yn := a21(indx);
          t(ddindx).rvi_rate := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).stream_interface_attribute01 := a23(indx);
          t(ddindx).stream_interface_attribute02 := a24(indx);
          t(ddindx).stream_interface_attribute03 := a25(indx);
          t(ddindx).stream_interface_attribute04 := a26(indx);
          t(ddindx).stream_interface_attribute05 := a27(indx);
          t(ddindx).stream_interface_attribute06 := a28(indx);
          t(ddindx).stream_interface_attribute07 := a29(indx);
          t(ddindx).stream_interface_attribute08 := a30(indx);
          t(ddindx).stream_interface_attribute09 := a31(indx);
          t(ddindx).stream_interface_attribute10 := a32(indx);
          t(ddindx).stream_interface_attribute11 := a33(indx);
          t(ddindx).stream_interface_attribute12 := a34(indx);
          t(ddindx).stream_interface_attribute13 := a35(indx);
          t(ddindx).stream_interface_attribute14 := a36(indx);
          t(ddindx).stream_interface_attribute15 := a37(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a41(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).jtot_object1_code := a47(indx);
          t(ddindx).object1_id1 := a48(indx);
          t(ddindx).object1_id2 := a49(indx);
          t(ddindx).term := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).structure := a51(indx);
          t(ddindx).deal_type := a52(indx);
          t(ddindx).log_file := a53(indx);
          t(ddindx).first_payment := a54(indx);
          t(ddindx).last_payment := a55(indx);
          t(ddindx).sif_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).purpose_code := a57(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_sif_pvt.sif_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
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
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_400
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
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
    a40 := JTF_DATE_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_400();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
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
      a40 := JTF_DATE_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_400();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).fasb_acct_treatment_method;
          a3(indx) := t(ddindx).date_payments_commencement;
          a4(indx) := t(ddindx).country;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).security_deposit_amount);
          a6(indx) := t(ddindx).date_delivery;
          a7(indx) := t(ddindx).irs_tax_treatment_method;
          a8(indx) := t(ddindx).sif_mode;
          a9(indx) := t(ddindx).pricing_template_name;
          a10(indx) := t(ddindx).date_sec_deposit_collected;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_number);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).total_funding);
          a13(indx) := t(ddindx).sis_code;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a15(indx) := t(ddindx).adjust;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_interest_rate);
          a17(indx) := t(ddindx).adjustment_method;
          a18(indx) := t(ddindx).date_processed;
          a19(indx) := t(ddindx).orp_code;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).lending_rate);
          a21(indx) := t(ddindx).rvi_yn;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).rvi_rate);
          a23(indx) := t(ddindx).stream_interface_attribute01;
          a24(indx) := t(ddindx).stream_interface_attribute02;
          a25(indx) := t(ddindx).stream_interface_attribute03;
          a26(indx) := t(ddindx).stream_interface_attribute04;
          a27(indx) := t(ddindx).stream_interface_attribute05;
          a28(indx) := t(ddindx).stream_interface_attribute06;
          a29(indx) := t(ddindx).stream_interface_attribute07;
          a30(indx) := t(ddindx).stream_interface_attribute08;
          a31(indx) := t(ddindx).stream_interface_attribute09;
          a32(indx) := t(ddindx).stream_interface_attribute10;
          a33(indx) := t(ddindx).stream_interface_attribute11;
          a34(indx) := t(ddindx).stream_interface_attribute12;
          a35(indx) := t(ddindx).stream_interface_attribute13;
          a36(indx) := t(ddindx).stream_interface_attribute14;
          a37(indx) := t(ddindx).stream_interface_attribute15;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a40(indx) := t(ddindx).creation_date;
          a41(indx) := t(ddindx).last_update_date;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a46(indx) := t(ddindx).program_update_date;
          a47(indx) := t(ddindx).jtot_object1_code;
          a48(indx) := t(ddindx).object1_id1;
          a49(indx) := t(ddindx).object1_id2;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).term);
          a51(indx) := t(ddindx).structure;
          a52(indx) := t(ddindx).deal_type;
          a53(indx) := t(ddindx).log_file;
          a54(indx) := t(ddindx).first_payment;
          a55(indx) := t(ddindx).last_payment;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).sif_id);
          a57(indx) := t(ddindx).purpose_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_sif_pvt.sifv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_DATE_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_NUMBER_TABLE
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
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_400
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_200
    , a52 JTF_VARCHAR2_TABLE_200
    , a53 JTF_VARCHAR2_TABLE_200
    , a54 JTF_VARCHAR2_TABLE_200
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).fasb_acct_treatment_method := a2(indx);
          t(ddindx).date_payments_commencement := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).country := a4(indx);
          t(ddindx).security_deposit_amount := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).date_delivery := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).irs_tax_treatment_method := a7(indx);
          t(ddindx).sif_mode := a8(indx);
          t(ddindx).pricing_template_name := a9(indx);
          t(ddindx).date_sec_deposit_collected := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).transaction_number := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).total_funding := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).sis_code := a13(indx);
          t(ddindx).khr_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).adjust := a15(indx);
          t(ddindx).implicit_interest_rate := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).adjustment_method := a17(indx);
          t(ddindx).date_processed := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).orp_code := a19(indx);
          t(ddindx).lending_rate := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).rvi_yn := a21(indx);
          t(ddindx).rvi_rate := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).stream_interface_attribute01 := a23(indx);
          t(ddindx).stream_interface_attribute02 := a24(indx);
          t(ddindx).stream_interface_attribute03 := a25(indx);
          t(ddindx).stream_interface_attribute04 := a26(indx);
          t(ddindx).stream_interface_attribute05 := a27(indx);
          t(ddindx).stream_interface_attribute06 := a28(indx);
          t(ddindx).stream_interface_attribute07 := a29(indx);
          t(ddindx).stream_interface_attribute08 := a30(indx);
          t(ddindx).stream_interface_attribute09 := a31(indx);
          t(ddindx).stream_interface_attribute10 := a32(indx);
          t(ddindx).stream_interface_attribute11 := a33(indx);
          t(ddindx).stream_interface_attribute12 := a34(indx);
          t(ddindx).stream_interface_attribute13 := a35(indx);
          t(ddindx).stream_interface_attribute14 := a36(indx);
          t(ddindx).stream_interface_attribute15 := a37(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a40(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a41(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a44(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a45(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).jtot_object1_code := a47(indx);
          t(ddindx).object1_id1 := a48(indx);
          t(ddindx).object1_id2 := a49(indx);
          t(ddindx).term := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).structure := a51(indx);
          t(ddindx).deal_type := a52(indx);
          t(ddindx).log_file := a53(indx);
          t(ddindx).first_payment := a54(indx);
          t(ddindx).last_payment := a55(indx);
          t(ddindx).sif_id := rosetta_g_miss_num_map(a56(indx));
          t(ddindx).purpose_code := a57(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_sif_pvt.sifv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_NUMBER_TABLE
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
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_400
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_200
    , a52 out nocopy JTF_VARCHAR2_TABLE_200
    , a53 out nocopy JTF_VARCHAR2_TABLE_200
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_NUMBER_TABLE();
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
    a40 := JTF_DATE_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_400();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_200();
    a52 := JTF_VARCHAR2_TABLE_200();
    a53 := JTF_VARCHAR2_TABLE_200();
    a54 := JTF_VARCHAR2_TABLE_200();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_NUMBER_TABLE();
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
      a40 := JTF_DATE_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_400();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_200();
      a52 := JTF_VARCHAR2_TABLE_200();
      a53 := JTF_VARCHAR2_TABLE_200();
      a54 := JTF_VARCHAR2_TABLE_200();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).fasb_acct_treatment_method;
          a3(indx) := t(ddindx).date_payments_commencement;
          a4(indx) := t(ddindx).country;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).security_deposit_amount);
          a6(indx) := t(ddindx).date_delivery;
          a7(indx) := t(ddindx).irs_tax_treatment_method;
          a8(indx) := t(ddindx).sif_mode;
          a9(indx) := t(ddindx).pricing_template_name;
          a10(indx) := t(ddindx).date_sec_deposit_collected;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_number);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).total_funding);
          a13(indx) := t(ddindx).sis_code;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a15(indx) := t(ddindx).adjust;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).implicit_interest_rate);
          a17(indx) := t(ddindx).adjustment_method;
          a18(indx) := t(ddindx).date_processed;
          a19(indx) := t(ddindx).orp_code;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).lending_rate);
          a21(indx) := t(ddindx).rvi_yn;
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).rvi_rate);
          a23(indx) := t(ddindx).stream_interface_attribute01;
          a24(indx) := t(ddindx).stream_interface_attribute02;
          a25(indx) := t(ddindx).stream_interface_attribute03;
          a26(indx) := t(ddindx).stream_interface_attribute04;
          a27(indx) := t(ddindx).stream_interface_attribute05;
          a28(indx) := t(ddindx).stream_interface_attribute06;
          a29(indx) := t(ddindx).stream_interface_attribute07;
          a30(indx) := t(ddindx).stream_interface_attribute08;
          a31(indx) := t(ddindx).stream_interface_attribute09;
          a32(indx) := t(ddindx).stream_interface_attribute10;
          a33(indx) := t(ddindx).stream_interface_attribute11;
          a34(indx) := t(ddindx).stream_interface_attribute12;
          a35(indx) := t(ddindx).stream_interface_attribute13;
          a36(indx) := t(ddindx).stream_interface_attribute14;
          a37(indx) := t(ddindx).stream_interface_attribute15;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a40(indx) := t(ddindx).creation_date;
          a41(indx) := t(ddindx).last_update_date;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a44(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a45(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a46(indx) := t(ddindx).program_update_date;
          a47(indx) := t(ddindx).jtot_object1_code;
          a48(indx) := t(ddindx).object1_id1;
          a49(indx) := t(ddindx).object1_id2;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).term);
          a51(indx) := t(ddindx).structure;
          a52(indx) := t(ddindx).deal_type;
          a53(indx) := t(ddindx).log_file;
          a54(indx) := t(ddindx).first_payment;
          a55(indx) := t(ddindx).last_payment;
          a56(indx) := rosetta_g_miss_num_map(t(ddindx).sif_id);
          a57(indx) := t(ddindx).purpose_code;
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
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
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
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
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
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_sif_pvt.sifv_rec_type;
    ddx_sifv_rec okl_sif_pvt.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_sif_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec,
      ddx_sifv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sifv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sifv_rec.object_version_number);
    p6_a2 := ddx_sifv_rec.fasb_acct_treatment_method;
    p6_a3 := ddx_sifv_rec.date_payments_commencement;
    p6_a4 := ddx_sifv_rec.country;
    p6_a5 := rosetta_g_miss_num_map(ddx_sifv_rec.security_deposit_amount);
    p6_a6 := ddx_sifv_rec.date_delivery;
    p6_a7 := ddx_sifv_rec.irs_tax_treatment_method;
    p6_a8 := ddx_sifv_rec.sif_mode;
    p6_a9 := ddx_sifv_rec.pricing_template_name;
    p6_a10 := ddx_sifv_rec.date_sec_deposit_collected;
    p6_a11 := rosetta_g_miss_num_map(ddx_sifv_rec.transaction_number);
    p6_a12 := rosetta_g_miss_num_map(ddx_sifv_rec.total_funding);
    p6_a13 := ddx_sifv_rec.sis_code;
    p6_a14 := rosetta_g_miss_num_map(ddx_sifv_rec.khr_id);
    p6_a15 := ddx_sifv_rec.adjust;
    p6_a16 := rosetta_g_miss_num_map(ddx_sifv_rec.implicit_interest_rate);
    p6_a17 := ddx_sifv_rec.adjustment_method;
    p6_a18 := ddx_sifv_rec.date_processed;
    p6_a19 := ddx_sifv_rec.orp_code;
    p6_a20 := rosetta_g_miss_num_map(ddx_sifv_rec.lending_rate);
    p6_a21 := ddx_sifv_rec.rvi_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_sifv_rec.rvi_rate);
    p6_a23 := ddx_sifv_rec.stream_interface_attribute01;
    p6_a24 := ddx_sifv_rec.stream_interface_attribute02;
    p6_a25 := ddx_sifv_rec.stream_interface_attribute03;
    p6_a26 := ddx_sifv_rec.stream_interface_attribute04;
    p6_a27 := ddx_sifv_rec.stream_interface_attribute05;
    p6_a28 := ddx_sifv_rec.stream_interface_attribute06;
    p6_a29 := ddx_sifv_rec.stream_interface_attribute07;
    p6_a30 := ddx_sifv_rec.stream_interface_attribute08;
    p6_a31 := ddx_sifv_rec.stream_interface_attribute09;
    p6_a32 := ddx_sifv_rec.stream_interface_attribute10;
    p6_a33 := ddx_sifv_rec.stream_interface_attribute11;
    p6_a34 := ddx_sifv_rec.stream_interface_attribute12;
    p6_a35 := ddx_sifv_rec.stream_interface_attribute13;
    p6_a36 := ddx_sifv_rec.stream_interface_attribute14;
    p6_a37 := ddx_sifv_rec.stream_interface_attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_sifv_rec.created_by);
    p6_a39 := rosetta_g_miss_num_map(ddx_sifv_rec.last_updated_by);
    p6_a40 := ddx_sifv_rec.creation_date;
    p6_a41 := ddx_sifv_rec.last_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_sifv_rec.last_update_login);
    p6_a43 := rosetta_g_miss_num_map(ddx_sifv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_sifv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_sifv_rec.program_id);
    p6_a46 := ddx_sifv_rec.program_update_date;
    p6_a47 := ddx_sifv_rec.jtot_object1_code;
    p6_a48 := ddx_sifv_rec.object1_id1;
    p6_a49 := ddx_sifv_rec.object1_id2;
    p6_a50 := rosetta_g_miss_num_map(ddx_sifv_rec.term);
    p6_a51 := ddx_sifv_rec.structure;
    p6_a52 := ddx_sifv_rec.deal_type;
    p6_a53 := ddx_sifv_rec.log_file;
    p6_a54 := ddx_sifv_rec.first_payment;
    p6_a55 := ddx_sifv_rec.last_payment;
    p6_a56 := rosetta_g_miss_num_map(ddx_sifv_rec.sif_id);
    p6_a57 := ddx_sifv_rec.purpose_code;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
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
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
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
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_sif_pvt.sifv_tbl_type;
    ddx_sifv_tbl okl_sif_pvt.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
    okl_sif_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl,
      ddx_sifv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sif_pvt_w.rosetta_table_copy_out_p5(ddx_sifv_tbl, p6_a0
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
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
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
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_sif_pvt.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    okl_sif_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec);

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
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
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
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_sif_pvt.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
    okl_sif_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl);

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
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
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
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
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
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_sif_pvt.sifv_rec_type;
    ddx_sifv_rec okl_sif_pvt.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_sif_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec,
      ddx_sifv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sifv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sifv_rec.object_version_number);
    p6_a2 := ddx_sifv_rec.fasb_acct_treatment_method;
    p6_a3 := ddx_sifv_rec.date_payments_commencement;
    p6_a4 := ddx_sifv_rec.country;
    p6_a5 := rosetta_g_miss_num_map(ddx_sifv_rec.security_deposit_amount);
    p6_a6 := ddx_sifv_rec.date_delivery;
    p6_a7 := ddx_sifv_rec.irs_tax_treatment_method;
    p6_a8 := ddx_sifv_rec.sif_mode;
    p6_a9 := ddx_sifv_rec.pricing_template_name;
    p6_a10 := ddx_sifv_rec.date_sec_deposit_collected;
    p6_a11 := rosetta_g_miss_num_map(ddx_sifv_rec.transaction_number);
    p6_a12 := rosetta_g_miss_num_map(ddx_sifv_rec.total_funding);
    p6_a13 := ddx_sifv_rec.sis_code;
    p6_a14 := rosetta_g_miss_num_map(ddx_sifv_rec.khr_id);
    p6_a15 := ddx_sifv_rec.adjust;
    p6_a16 := rosetta_g_miss_num_map(ddx_sifv_rec.implicit_interest_rate);
    p6_a17 := ddx_sifv_rec.adjustment_method;
    p6_a18 := ddx_sifv_rec.date_processed;
    p6_a19 := ddx_sifv_rec.orp_code;
    p6_a20 := rosetta_g_miss_num_map(ddx_sifv_rec.lending_rate);
    p6_a21 := ddx_sifv_rec.rvi_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_sifv_rec.rvi_rate);
    p6_a23 := ddx_sifv_rec.stream_interface_attribute01;
    p6_a24 := ddx_sifv_rec.stream_interface_attribute02;
    p6_a25 := ddx_sifv_rec.stream_interface_attribute03;
    p6_a26 := ddx_sifv_rec.stream_interface_attribute04;
    p6_a27 := ddx_sifv_rec.stream_interface_attribute05;
    p6_a28 := ddx_sifv_rec.stream_interface_attribute06;
    p6_a29 := ddx_sifv_rec.stream_interface_attribute07;
    p6_a30 := ddx_sifv_rec.stream_interface_attribute08;
    p6_a31 := ddx_sifv_rec.stream_interface_attribute09;
    p6_a32 := ddx_sifv_rec.stream_interface_attribute10;
    p6_a33 := ddx_sifv_rec.stream_interface_attribute11;
    p6_a34 := ddx_sifv_rec.stream_interface_attribute12;
    p6_a35 := ddx_sifv_rec.stream_interface_attribute13;
    p6_a36 := ddx_sifv_rec.stream_interface_attribute14;
    p6_a37 := ddx_sifv_rec.stream_interface_attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_sifv_rec.created_by);
    p6_a39 := rosetta_g_miss_num_map(ddx_sifv_rec.last_updated_by);
    p6_a40 := ddx_sifv_rec.creation_date;
    p6_a41 := ddx_sifv_rec.last_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_sifv_rec.last_update_login);
    p6_a43 := rosetta_g_miss_num_map(ddx_sifv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_sifv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_sifv_rec.program_id);
    p6_a46 := ddx_sifv_rec.program_update_date;
    p6_a47 := ddx_sifv_rec.jtot_object1_code;
    p6_a48 := ddx_sifv_rec.object1_id1;
    p6_a49 := ddx_sifv_rec.object1_id2;
    p6_a50 := rosetta_g_miss_num_map(ddx_sifv_rec.term);
    p6_a51 := ddx_sifv_rec.structure;
    p6_a52 := ddx_sifv_rec.deal_type;
    p6_a53 := ddx_sifv_rec.log_file;
    p6_a54 := ddx_sifv_rec.first_payment;
    p6_a55 := ddx_sifv_rec.last_payment;
    p6_a56 := rosetta_g_miss_num_map(ddx_sifv_rec.sif_id);
    p6_a57 := ddx_sifv_rec.purpose_code;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
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
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
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
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_sif_pvt.sifv_tbl_type;
    ddx_sifv_tbl okl_sif_pvt.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
    okl_sif_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl,
      ddx_sifv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sif_pvt_w.rosetta_table_copy_out_p5(ddx_sifv_tbl, p6_a0
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
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
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
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_sif_pvt.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    okl_sif_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec);

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
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
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
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_sif_pvt.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
    okl_sif_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl);

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
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
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
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_sif_pvt.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    okl_sif_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec);

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
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
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
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_sif_pvt.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
    okl_sif_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_sif_pvt_w;

/
