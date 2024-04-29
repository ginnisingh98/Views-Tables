--------------------------------------------------------
--  DDL for Package Body OKL_SIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIL_PVT_W" as
  /* $Header: OKLISILB.pls 120.2 2005/10/11 06:38:16 rgooty noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_sil_pvt.sil_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_500
    , a36 JTF_VARCHAR2_TABLE_2000
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
    , a48 JTF_DATE_TABLE
    , a49 JTF_DATE_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_DATE_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).state_depre_dmnshing_value_rt := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).book_depre_dmnshing_value_rt := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).residual_guarantee_method := a3(indx);
          t(ddindx).residual_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).fed_depre_term := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).fed_depre_dmnshing_value_rate := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).fed_depre_adr_conve := a7(indx);
          t(ddindx).state_depre_basis_percent := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).state_depre_method := a9(indx);
          t(ddindx).purchase_option := a10(indx);
          t(ddindx).purchase_option_amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).asset_cost := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).state_depre_term := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).state_depre_adr_convent := a14(indx);
          t(ddindx).fed_depre_method := a15(indx);
          t(ddindx).residual_amount := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).fed_depre_salvage := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).date_fed_depre := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).book_salvage := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).book_adr_convention := a20(indx);
          t(ddindx).state_depre_salvage := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).fed_depre_basis_percent := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).book_basis_percent := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).date_delivery := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).book_term := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).residual_guarantee_amount := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).date_funding := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).date_book := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).date_state_depre := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).book_method := a30(indx);
          t(ddindx).stream_interface_attribute08 := a31(indx);
          t(ddindx).stream_interface_attribute03 := a32(indx);
          t(ddindx).stream_interface_attribute01 := a33(indx);
          t(ddindx).index_number := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).stream_interface_attribute05 := a35(indx);
          t(ddindx).description := a36(indx);
          t(ddindx).stream_interface_attribute10 := a37(indx);
          t(ddindx).stream_interface_attribute06 := a38(indx);
          t(ddindx).stream_interface_attribute09 := a39(indx);
          t(ddindx).stream_interface_attribute07 := a40(indx);
          t(ddindx).stream_interface_attribute14 := a41(indx);
          t(ddindx).stream_interface_attribute12 := a42(indx);
          t(ddindx).stream_interface_attribute15 := a43(indx);
          t(ddindx).stream_interface_attribute02 := a44(indx);
          t(ddindx).stream_interface_attribute11 := a45(indx);
          t(ddindx).stream_interface_attribute04 := a46(indx);
          t(ddindx).stream_interface_attribute13 := a47(indx);
          t(ddindx).date_start := rosetta_g_miss_date_in_map(a48(indx));
          t(ddindx).date_lending := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).sif_id := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).sil_type := a53(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a56(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a57(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).residual_guarantee_type := a59(indx);
          t(ddindx).down_payment_amount := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).capitalize_down_payment_yn := a61(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_sil_pvt.sil_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    , a36 out nocopy JTF_VARCHAR2_TABLE_2000
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
    , a48 out nocopy JTF_DATE_TABLE
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_DATE_TABLE
    , a57 out nocopy JTF_DATE_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_500();
    a36 := JTF_VARCHAR2_TABLE_2000();
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
    a48 := JTF_DATE_TABLE();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_DATE_TABLE();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_500();
      a36 := JTF_VARCHAR2_TABLE_2000();
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
      a48 := JTF_DATE_TABLE();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_DATE_TABLE();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).state_depre_dmnshing_value_rt);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).book_depre_dmnshing_value_rt);
          a3(indx) := t(ddindx).residual_guarantee_method;
          a4(indx) := t(ddindx).residual_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).fed_depre_term);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).fed_depre_dmnshing_value_rate);
          a7(indx) := t(ddindx).fed_depre_adr_conve;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).state_depre_basis_percent);
          a9(indx) := t(ddindx).state_depre_method;
          a10(indx) := t(ddindx).purchase_option;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).purchase_option_amount);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).asset_cost);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).state_depre_term);
          a14(indx) := t(ddindx).state_depre_adr_convent;
          a15(indx) := t(ddindx).fed_depre_method;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).residual_amount);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).fed_depre_salvage);
          a18(indx) := t(ddindx).date_fed_depre;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).book_salvage);
          a20(indx) := t(ddindx).book_adr_convention;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).state_depre_salvage);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).fed_depre_basis_percent);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).book_basis_percent);
          a24(indx) := t(ddindx).date_delivery;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).book_term);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).residual_guarantee_amount);
          a27(indx) := t(ddindx).date_funding;
          a28(indx) := t(ddindx).date_book;
          a29(indx) := t(ddindx).date_state_depre;
          a30(indx) := t(ddindx).book_method;
          a31(indx) := t(ddindx).stream_interface_attribute08;
          a32(indx) := t(ddindx).stream_interface_attribute03;
          a33(indx) := t(ddindx).stream_interface_attribute01;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).index_number);
          a35(indx) := t(ddindx).stream_interface_attribute05;
          a36(indx) := t(ddindx).description;
          a37(indx) := t(ddindx).stream_interface_attribute10;
          a38(indx) := t(ddindx).stream_interface_attribute06;
          a39(indx) := t(ddindx).stream_interface_attribute09;
          a40(indx) := t(ddindx).stream_interface_attribute07;
          a41(indx) := t(ddindx).stream_interface_attribute14;
          a42(indx) := t(ddindx).stream_interface_attribute12;
          a43(indx) := t(ddindx).stream_interface_attribute15;
          a44(indx) := t(ddindx).stream_interface_attribute02;
          a45(indx) := t(ddindx).stream_interface_attribute11;
          a46(indx) := t(ddindx).stream_interface_attribute04;
          a47(indx) := t(ddindx).stream_interface_attribute13;
          a48(indx) := t(ddindx).date_start;
          a49(indx) := t(ddindx).date_lending;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).sif_id);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a53(indx) := t(ddindx).sil_type;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a56(indx) := t(ddindx).creation_date;
          a57(indx) := t(ddindx).last_update_date;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a59(indx) := t(ddindx).residual_guarantee_type;
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).down_payment_amount);
          a61(indx) := t(ddindx).capitalize_down_payment_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_sil_pvt.silv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_500
    , a36 JTF_VARCHAR2_TABLE_2000
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
    , a48 JTF_DATE_TABLE
    , a49 JTF_DATE_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_DATE_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).state_depre_dmnshing_value_rt := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).book_depre_dmnshing_value_rt := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).residual_guarantee_method := a3(indx);
          t(ddindx).residual_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).fed_depre_term := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).fed_depre_dmnshing_value_rate := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).fed_depre_adr_conve := a7(indx);
          t(ddindx).state_depre_basis_percent := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).state_depre_method := a9(indx);
          t(ddindx).purchase_option := a10(indx);
          t(ddindx).purchase_option_amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).asset_cost := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).state_depre_term := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).state_depre_adr_convent := a14(indx);
          t(ddindx).fed_depre_method := a15(indx);
          t(ddindx).residual_amount := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).fed_depre_salvage := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).date_fed_depre := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).book_salvage := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).book_adr_convention := a20(indx);
          t(ddindx).state_depre_salvage := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).fed_depre_basis_percent := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).book_basis_percent := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).date_delivery := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).book_term := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).residual_guarantee_amount := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).date_funding := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).date_book := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).date_state_depre := rosetta_g_miss_date_in_map(a29(indx));
          t(ddindx).book_method := a30(indx);
          t(ddindx).stream_interface_attribute08 := a31(indx);
          t(ddindx).stream_interface_attribute03 := a32(indx);
          t(ddindx).stream_interface_attribute01 := a33(indx);
          t(ddindx).index_number := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).stream_interface_attribute05 := a35(indx);
          t(ddindx).description := a36(indx);
          t(ddindx).stream_interface_attribute10 := a37(indx);
          t(ddindx).stream_interface_attribute06 := a38(indx);
          t(ddindx).stream_interface_attribute09 := a39(indx);
          t(ddindx).stream_interface_attribute07 := a40(indx);
          t(ddindx).stream_interface_attribute14 := a41(indx);
          t(ddindx).stream_interface_attribute12 := a42(indx);
          t(ddindx).stream_interface_attribute15 := a43(indx);
          t(ddindx).stream_interface_attribute02 := a44(indx);
          t(ddindx).stream_interface_attribute11 := a45(indx);
          t(ddindx).stream_interface_attribute04 := a46(indx);
          t(ddindx).stream_interface_attribute13 := a47(indx);
          t(ddindx).date_start := rosetta_g_miss_date_in_map(a48(indx));
          t(ddindx).date_lending := rosetta_g_miss_date_in_map(a49(indx));
          t(ddindx).sif_id := rosetta_g_miss_num_map(a50(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a51(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a52(indx));
          t(ddindx).sil_type := a53(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a54(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a55(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a56(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a57(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a58(indx));
          t(ddindx).residual_guarantee_type := a59(indx);
          t(ddindx).down_payment_amount := rosetta_g_miss_num_map(a60(indx));
          t(ddindx).capitalize_down_payment_yn := a61(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_sil_pvt.silv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_DATE_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    , a36 out nocopy JTF_VARCHAR2_TABLE_2000
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
    , a48 out nocopy JTF_DATE_TABLE
    , a49 out nocopy JTF_DATE_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_DATE_TABLE
    , a57 out nocopy JTF_DATE_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_DATE_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_500();
    a36 := JTF_VARCHAR2_TABLE_2000();
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
    a48 := JTF_DATE_TABLE();
    a49 := JTF_DATE_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_DATE_TABLE();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_DATE_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_500();
      a36 := JTF_VARCHAR2_TABLE_2000();
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
      a48 := JTF_DATE_TABLE();
      a49 := JTF_DATE_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_DATE_TABLE();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).state_depre_dmnshing_value_rt);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).book_depre_dmnshing_value_rt);
          a3(indx) := t(ddindx).residual_guarantee_method;
          a4(indx) := t(ddindx).residual_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).fed_depre_term);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).fed_depre_dmnshing_value_rate);
          a7(indx) := t(ddindx).fed_depre_adr_conve;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).state_depre_basis_percent);
          a9(indx) := t(ddindx).state_depre_method;
          a10(indx) := t(ddindx).purchase_option;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).purchase_option_amount);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).asset_cost);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).state_depre_term);
          a14(indx) := t(ddindx).state_depre_adr_convent;
          a15(indx) := t(ddindx).fed_depre_method;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).residual_amount);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).fed_depre_salvage);
          a18(indx) := t(ddindx).date_fed_depre;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).book_salvage);
          a20(indx) := t(ddindx).book_adr_convention;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).state_depre_salvage);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).fed_depre_basis_percent);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).book_basis_percent);
          a24(indx) := t(ddindx).date_delivery;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).book_term);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).residual_guarantee_amount);
          a27(indx) := t(ddindx).date_funding;
          a28(indx) := t(ddindx).date_book;
          a29(indx) := t(ddindx).date_state_depre;
          a30(indx) := t(ddindx).book_method;
          a31(indx) := t(ddindx).stream_interface_attribute08;
          a32(indx) := t(ddindx).stream_interface_attribute03;
          a33(indx) := t(ddindx).stream_interface_attribute01;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).index_number);
          a35(indx) := t(ddindx).stream_interface_attribute05;
          a36(indx) := t(ddindx).description;
          a37(indx) := t(ddindx).stream_interface_attribute10;
          a38(indx) := t(ddindx).stream_interface_attribute06;
          a39(indx) := t(ddindx).stream_interface_attribute09;
          a40(indx) := t(ddindx).stream_interface_attribute07;
          a41(indx) := t(ddindx).stream_interface_attribute14;
          a42(indx) := t(ddindx).stream_interface_attribute12;
          a43(indx) := t(ddindx).stream_interface_attribute15;
          a44(indx) := t(ddindx).stream_interface_attribute02;
          a45(indx) := t(ddindx).stream_interface_attribute11;
          a46(indx) := t(ddindx).stream_interface_attribute04;
          a47(indx) := t(ddindx).stream_interface_attribute13;
          a48(indx) := t(ddindx).date_start;
          a49(indx) := t(ddindx).date_lending;
          a50(indx) := rosetta_g_miss_num_map(t(ddindx).sif_id);
          a51(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a52(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a53(indx) := t(ddindx).sil_type;
          a54(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a55(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a56(indx) := t(ddindx).creation_date;
          a57(indx) := t(ddindx).last_update_date;
          a58(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a59(indx) := t(ddindx).residual_guarantee_type;
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).down_payment_amount);
          a61(indx) := t(ddindx).capitalize_down_payment_yn;
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
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
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
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  DATE
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  DATE := fnd_api.g_miss_date
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_silv_rec okl_sil_pvt.silv_rec_type;
    ddx_silv_rec okl_sil_pvt.silv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_silv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_silv_rec.state_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a1);
    ddp_silv_rec.book_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a2);
    ddp_silv_rec.residual_guarantee_method := p5_a3;
    ddp_silv_rec.residual_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_silv_rec.fed_depre_term := rosetta_g_miss_num_map(p5_a5);
    ddp_silv_rec.fed_depre_dmnshing_value_rate := rosetta_g_miss_num_map(p5_a6);
    ddp_silv_rec.fed_depre_adr_conve := p5_a7;
    ddp_silv_rec.state_depre_basis_percent := rosetta_g_miss_num_map(p5_a8);
    ddp_silv_rec.state_depre_method := p5_a9;
    ddp_silv_rec.purchase_option := p5_a10;
    ddp_silv_rec.purchase_option_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_silv_rec.asset_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_silv_rec.state_depre_term := rosetta_g_miss_num_map(p5_a13);
    ddp_silv_rec.state_depre_adr_convent := p5_a14;
    ddp_silv_rec.fed_depre_method := p5_a15;
    ddp_silv_rec.residual_amount := rosetta_g_miss_num_map(p5_a16);
    ddp_silv_rec.fed_depre_salvage := rosetta_g_miss_num_map(p5_a17);
    ddp_silv_rec.date_fed_depre := rosetta_g_miss_date_in_map(p5_a18);
    ddp_silv_rec.book_salvage := rosetta_g_miss_num_map(p5_a19);
    ddp_silv_rec.book_adr_convention := p5_a20;
    ddp_silv_rec.state_depre_salvage := rosetta_g_miss_num_map(p5_a21);
    ddp_silv_rec.fed_depre_basis_percent := rosetta_g_miss_num_map(p5_a22);
    ddp_silv_rec.book_basis_percent := rosetta_g_miss_num_map(p5_a23);
    ddp_silv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a24);
    ddp_silv_rec.book_term := rosetta_g_miss_num_map(p5_a25);
    ddp_silv_rec.residual_guarantee_amount := rosetta_g_miss_num_map(p5_a26);
    ddp_silv_rec.date_funding := rosetta_g_miss_date_in_map(p5_a27);
    ddp_silv_rec.date_book := rosetta_g_miss_date_in_map(p5_a28);
    ddp_silv_rec.date_state_depre := rosetta_g_miss_date_in_map(p5_a29);
    ddp_silv_rec.book_method := p5_a30;
    ddp_silv_rec.stream_interface_attribute08 := p5_a31;
    ddp_silv_rec.stream_interface_attribute03 := p5_a32;
    ddp_silv_rec.stream_interface_attribute01 := p5_a33;
    ddp_silv_rec.index_number := rosetta_g_miss_num_map(p5_a34);
    ddp_silv_rec.stream_interface_attribute05 := p5_a35;
    ddp_silv_rec.description := p5_a36;
    ddp_silv_rec.stream_interface_attribute10 := p5_a37;
    ddp_silv_rec.stream_interface_attribute06 := p5_a38;
    ddp_silv_rec.stream_interface_attribute09 := p5_a39;
    ddp_silv_rec.stream_interface_attribute07 := p5_a40;
    ddp_silv_rec.stream_interface_attribute14 := p5_a41;
    ddp_silv_rec.stream_interface_attribute12 := p5_a42;
    ddp_silv_rec.stream_interface_attribute15 := p5_a43;
    ddp_silv_rec.stream_interface_attribute02 := p5_a44;
    ddp_silv_rec.stream_interface_attribute11 := p5_a45;
    ddp_silv_rec.stream_interface_attribute04 := p5_a46;
    ddp_silv_rec.stream_interface_attribute13 := p5_a47;
    ddp_silv_rec.date_start := rosetta_g_miss_date_in_map(p5_a48);
    ddp_silv_rec.date_lending := rosetta_g_miss_date_in_map(p5_a49);
    ddp_silv_rec.sif_id := rosetta_g_miss_num_map(p5_a50);
    ddp_silv_rec.object_version_number := rosetta_g_miss_num_map(p5_a51);
    ddp_silv_rec.kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_silv_rec.sil_type := p5_a53;
    ddp_silv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_silv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a55);
    ddp_silv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a56);
    ddp_silv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_silv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_silv_rec.residual_guarantee_type := p5_a59;
    ddp_silv_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a60);
    ddp_silv_rec.capitalize_down_payment_yn := p5_a61;


    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_rec,
      ddx_silv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_silv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_silv_rec.state_depre_dmnshing_value_rt);
    p6_a2 := rosetta_g_miss_num_map(ddx_silv_rec.book_depre_dmnshing_value_rt);
    p6_a3 := ddx_silv_rec.residual_guarantee_method;
    p6_a4 := ddx_silv_rec.residual_date;
    p6_a5 := rosetta_g_miss_num_map(ddx_silv_rec.fed_depre_term);
    p6_a6 := rosetta_g_miss_num_map(ddx_silv_rec.fed_depre_dmnshing_value_rate);
    p6_a7 := ddx_silv_rec.fed_depre_adr_conve;
    p6_a8 := rosetta_g_miss_num_map(ddx_silv_rec.state_depre_basis_percent);
    p6_a9 := ddx_silv_rec.state_depre_method;
    p6_a10 := ddx_silv_rec.purchase_option;
    p6_a11 := rosetta_g_miss_num_map(ddx_silv_rec.purchase_option_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_silv_rec.asset_cost);
    p6_a13 := rosetta_g_miss_num_map(ddx_silv_rec.state_depre_term);
    p6_a14 := ddx_silv_rec.state_depre_adr_convent;
    p6_a15 := ddx_silv_rec.fed_depre_method;
    p6_a16 := rosetta_g_miss_num_map(ddx_silv_rec.residual_amount);
    p6_a17 := rosetta_g_miss_num_map(ddx_silv_rec.fed_depre_salvage);
    p6_a18 := ddx_silv_rec.date_fed_depre;
    p6_a19 := rosetta_g_miss_num_map(ddx_silv_rec.book_salvage);
    p6_a20 := ddx_silv_rec.book_adr_convention;
    p6_a21 := rosetta_g_miss_num_map(ddx_silv_rec.state_depre_salvage);
    p6_a22 := rosetta_g_miss_num_map(ddx_silv_rec.fed_depre_basis_percent);
    p6_a23 := rosetta_g_miss_num_map(ddx_silv_rec.book_basis_percent);
    p6_a24 := ddx_silv_rec.date_delivery;
    p6_a25 := rosetta_g_miss_num_map(ddx_silv_rec.book_term);
    p6_a26 := rosetta_g_miss_num_map(ddx_silv_rec.residual_guarantee_amount);
    p6_a27 := ddx_silv_rec.date_funding;
    p6_a28 := ddx_silv_rec.date_book;
    p6_a29 := ddx_silv_rec.date_state_depre;
    p6_a30 := ddx_silv_rec.book_method;
    p6_a31 := ddx_silv_rec.stream_interface_attribute08;
    p6_a32 := ddx_silv_rec.stream_interface_attribute03;
    p6_a33 := ddx_silv_rec.stream_interface_attribute01;
    p6_a34 := rosetta_g_miss_num_map(ddx_silv_rec.index_number);
    p6_a35 := ddx_silv_rec.stream_interface_attribute05;
    p6_a36 := ddx_silv_rec.description;
    p6_a37 := ddx_silv_rec.stream_interface_attribute10;
    p6_a38 := ddx_silv_rec.stream_interface_attribute06;
    p6_a39 := ddx_silv_rec.stream_interface_attribute09;
    p6_a40 := ddx_silv_rec.stream_interface_attribute07;
    p6_a41 := ddx_silv_rec.stream_interface_attribute14;
    p6_a42 := ddx_silv_rec.stream_interface_attribute12;
    p6_a43 := ddx_silv_rec.stream_interface_attribute15;
    p6_a44 := ddx_silv_rec.stream_interface_attribute02;
    p6_a45 := ddx_silv_rec.stream_interface_attribute11;
    p6_a46 := ddx_silv_rec.stream_interface_attribute04;
    p6_a47 := ddx_silv_rec.stream_interface_attribute13;
    p6_a48 := ddx_silv_rec.date_start;
    p6_a49 := ddx_silv_rec.date_lending;
    p6_a50 := rosetta_g_miss_num_map(ddx_silv_rec.sif_id);
    p6_a51 := rosetta_g_miss_num_map(ddx_silv_rec.object_version_number);
    p6_a52 := rosetta_g_miss_num_map(ddx_silv_rec.kle_id);
    p6_a53 := ddx_silv_rec.sil_type;
    p6_a54 := rosetta_g_miss_num_map(ddx_silv_rec.created_by);
    p6_a55 := rosetta_g_miss_num_map(ddx_silv_rec.last_updated_by);
    p6_a56 := ddx_silv_rec.creation_date;
    p6_a57 := ddx_silv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_silv_rec.last_update_login);
    p6_a59 := ddx_silv_rec.residual_guarantee_type;
    p6_a60 := rosetta_g_miss_num_map(ddx_silv_rec.down_payment_amount);
    p6_a61 := ddx_silv_rec.capitalize_down_payment_yn;
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
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_2000
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_DATE_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_DATE_TABLE
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_silv_tbl okl_sil_pvt.silv_tbl_type;
    ddx_silv_tbl okl_sil_pvt.silv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sil_pvt_w.rosetta_table_copy_in_p5(ddp_silv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_tbl,
      ddx_silv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sil_pvt_w.rosetta_table_copy_out_p5(ddx_silv_tbl, p6_a0
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
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  DATE := fnd_api.g_miss_date
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_silv_rec okl_sil_pvt.silv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_silv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_silv_rec.state_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a1);
    ddp_silv_rec.book_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a2);
    ddp_silv_rec.residual_guarantee_method := p5_a3;
    ddp_silv_rec.residual_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_silv_rec.fed_depre_term := rosetta_g_miss_num_map(p5_a5);
    ddp_silv_rec.fed_depre_dmnshing_value_rate := rosetta_g_miss_num_map(p5_a6);
    ddp_silv_rec.fed_depre_adr_conve := p5_a7;
    ddp_silv_rec.state_depre_basis_percent := rosetta_g_miss_num_map(p5_a8);
    ddp_silv_rec.state_depre_method := p5_a9;
    ddp_silv_rec.purchase_option := p5_a10;
    ddp_silv_rec.purchase_option_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_silv_rec.asset_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_silv_rec.state_depre_term := rosetta_g_miss_num_map(p5_a13);
    ddp_silv_rec.state_depre_adr_convent := p5_a14;
    ddp_silv_rec.fed_depre_method := p5_a15;
    ddp_silv_rec.residual_amount := rosetta_g_miss_num_map(p5_a16);
    ddp_silv_rec.fed_depre_salvage := rosetta_g_miss_num_map(p5_a17);
    ddp_silv_rec.date_fed_depre := rosetta_g_miss_date_in_map(p5_a18);
    ddp_silv_rec.book_salvage := rosetta_g_miss_num_map(p5_a19);
    ddp_silv_rec.book_adr_convention := p5_a20;
    ddp_silv_rec.state_depre_salvage := rosetta_g_miss_num_map(p5_a21);
    ddp_silv_rec.fed_depre_basis_percent := rosetta_g_miss_num_map(p5_a22);
    ddp_silv_rec.book_basis_percent := rosetta_g_miss_num_map(p5_a23);
    ddp_silv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a24);
    ddp_silv_rec.book_term := rosetta_g_miss_num_map(p5_a25);
    ddp_silv_rec.residual_guarantee_amount := rosetta_g_miss_num_map(p5_a26);
    ddp_silv_rec.date_funding := rosetta_g_miss_date_in_map(p5_a27);
    ddp_silv_rec.date_book := rosetta_g_miss_date_in_map(p5_a28);
    ddp_silv_rec.date_state_depre := rosetta_g_miss_date_in_map(p5_a29);
    ddp_silv_rec.book_method := p5_a30;
    ddp_silv_rec.stream_interface_attribute08 := p5_a31;
    ddp_silv_rec.stream_interface_attribute03 := p5_a32;
    ddp_silv_rec.stream_interface_attribute01 := p5_a33;
    ddp_silv_rec.index_number := rosetta_g_miss_num_map(p5_a34);
    ddp_silv_rec.stream_interface_attribute05 := p5_a35;
    ddp_silv_rec.description := p5_a36;
    ddp_silv_rec.stream_interface_attribute10 := p5_a37;
    ddp_silv_rec.stream_interface_attribute06 := p5_a38;
    ddp_silv_rec.stream_interface_attribute09 := p5_a39;
    ddp_silv_rec.stream_interface_attribute07 := p5_a40;
    ddp_silv_rec.stream_interface_attribute14 := p5_a41;
    ddp_silv_rec.stream_interface_attribute12 := p5_a42;
    ddp_silv_rec.stream_interface_attribute15 := p5_a43;
    ddp_silv_rec.stream_interface_attribute02 := p5_a44;
    ddp_silv_rec.stream_interface_attribute11 := p5_a45;
    ddp_silv_rec.stream_interface_attribute04 := p5_a46;
    ddp_silv_rec.stream_interface_attribute13 := p5_a47;
    ddp_silv_rec.date_start := rosetta_g_miss_date_in_map(p5_a48);
    ddp_silv_rec.date_lending := rosetta_g_miss_date_in_map(p5_a49);
    ddp_silv_rec.sif_id := rosetta_g_miss_num_map(p5_a50);
    ddp_silv_rec.object_version_number := rosetta_g_miss_num_map(p5_a51);
    ddp_silv_rec.kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_silv_rec.sil_type := p5_a53;
    ddp_silv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_silv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a55);
    ddp_silv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a56);
    ddp_silv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_silv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_silv_rec.residual_guarantee_type := p5_a59;
    ddp_silv_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a60);
    ddp_silv_rec.capitalize_down_payment_yn := p5_a61;

    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_rec);

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
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_2000
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_DATE_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_silv_tbl okl_sil_pvt.silv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sil_pvt_w.rosetta_table_copy_in_p5(ddp_silv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_tbl);

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
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
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
    , p6_a48 out nocopy  DATE
    , p6_a49 out nocopy  DATE
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  NUMBER
    , p6_a56 out nocopy  DATE
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  DATE := fnd_api.g_miss_date
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_silv_rec okl_sil_pvt.silv_rec_type;
    ddx_silv_rec okl_sil_pvt.silv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_silv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_silv_rec.state_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a1);
    ddp_silv_rec.book_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a2);
    ddp_silv_rec.residual_guarantee_method := p5_a3;
    ddp_silv_rec.residual_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_silv_rec.fed_depre_term := rosetta_g_miss_num_map(p5_a5);
    ddp_silv_rec.fed_depre_dmnshing_value_rate := rosetta_g_miss_num_map(p5_a6);
    ddp_silv_rec.fed_depre_adr_conve := p5_a7;
    ddp_silv_rec.state_depre_basis_percent := rosetta_g_miss_num_map(p5_a8);
    ddp_silv_rec.state_depre_method := p5_a9;
    ddp_silv_rec.purchase_option := p5_a10;
    ddp_silv_rec.purchase_option_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_silv_rec.asset_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_silv_rec.state_depre_term := rosetta_g_miss_num_map(p5_a13);
    ddp_silv_rec.state_depre_adr_convent := p5_a14;
    ddp_silv_rec.fed_depre_method := p5_a15;
    ddp_silv_rec.residual_amount := rosetta_g_miss_num_map(p5_a16);
    ddp_silv_rec.fed_depre_salvage := rosetta_g_miss_num_map(p5_a17);
    ddp_silv_rec.date_fed_depre := rosetta_g_miss_date_in_map(p5_a18);
    ddp_silv_rec.book_salvage := rosetta_g_miss_num_map(p5_a19);
    ddp_silv_rec.book_adr_convention := p5_a20;
    ddp_silv_rec.state_depre_salvage := rosetta_g_miss_num_map(p5_a21);
    ddp_silv_rec.fed_depre_basis_percent := rosetta_g_miss_num_map(p5_a22);
    ddp_silv_rec.book_basis_percent := rosetta_g_miss_num_map(p5_a23);
    ddp_silv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a24);
    ddp_silv_rec.book_term := rosetta_g_miss_num_map(p5_a25);
    ddp_silv_rec.residual_guarantee_amount := rosetta_g_miss_num_map(p5_a26);
    ddp_silv_rec.date_funding := rosetta_g_miss_date_in_map(p5_a27);
    ddp_silv_rec.date_book := rosetta_g_miss_date_in_map(p5_a28);
    ddp_silv_rec.date_state_depre := rosetta_g_miss_date_in_map(p5_a29);
    ddp_silv_rec.book_method := p5_a30;
    ddp_silv_rec.stream_interface_attribute08 := p5_a31;
    ddp_silv_rec.stream_interface_attribute03 := p5_a32;
    ddp_silv_rec.stream_interface_attribute01 := p5_a33;
    ddp_silv_rec.index_number := rosetta_g_miss_num_map(p5_a34);
    ddp_silv_rec.stream_interface_attribute05 := p5_a35;
    ddp_silv_rec.description := p5_a36;
    ddp_silv_rec.stream_interface_attribute10 := p5_a37;
    ddp_silv_rec.stream_interface_attribute06 := p5_a38;
    ddp_silv_rec.stream_interface_attribute09 := p5_a39;
    ddp_silv_rec.stream_interface_attribute07 := p5_a40;
    ddp_silv_rec.stream_interface_attribute14 := p5_a41;
    ddp_silv_rec.stream_interface_attribute12 := p5_a42;
    ddp_silv_rec.stream_interface_attribute15 := p5_a43;
    ddp_silv_rec.stream_interface_attribute02 := p5_a44;
    ddp_silv_rec.stream_interface_attribute11 := p5_a45;
    ddp_silv_rec.stream_interface_attribute04 := p5_a46;
    ddp_silv_rec.stream_interface_attribute13 := p5_a47;
    ddp_silv_rec.date_start := rosetta_g_miss_date_in_map(p5_a48);
    ddp_silv_rec.date_lending := rosetta_g_miss_date_in_map(p5_a49);
    ddp_silv_rec.sif_id := rosetta_g_miss_num_map(p5_a50);
    ddp_silv_rec.object_version_number := rosetta_g_miss_num_map(p5_a51);
    ddp_silv_rec.kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_silv_rec.sil_type := p5_a53;
    ddp_silv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_silv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a55);
    ddp_silv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a56);
    ddp_silv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_silv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_silv_rec.residual_guarantee_type := p5_a59;
    ddp_silv_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a60);
    ddp_silv_rec.capitalize_down_payment_yn := p5_a61;


    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_rec,
      ddx_silv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_silv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_silv_rec.state_depre_dmnshing_value_rt);
    p6_a2 := rosetta_g_miss_num_map(ddx_silv_rec.book_depre_dmnshing_value_rt);
    p6_a3 := ddx_silv_rec.residual_guarantee_method;
    p6_a4 := ddx_silv_rec.residual_date;
    p6_a5 := rosetta_g_miss_num_map(ddx_silv_rec.fed_depre_term);
    p6_a6 := rosetta_g_miss_num_map(ddx_silv_rec.fed_depre_dmnshing_value_rate);
    p6_a7 := ddx_silv_rec.fed_depre_adr_conve;
    p6_a8 := rosetta_g_miss_num_map(ddx_silv_rec.state_depre_basis_percent);
    p6_a9 := ddx_silv_rec.state_depre_method;
    p6_a10 := ddx_silv_rec.purchase_option;
    p6_a11 := rosetta_g_miss_num_map(ddx_silv_rec.purchase_option_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_silv_rec.asset_cost);
    p6_a13 := rosetta_g_miss_num_map(ddx_silv_rec.state_depre_term);
    p6_a14 := ddx_silv_rec.state_depre_adr_convent;
    p6_a15 := ddx_silv_rec.fed_depre_method;
    p6_a16 := rosetta_g_miss_num_map(ddx_silv_rec.residual_amount);
    p6_a17 := rosetta_g_miss_num_map(ddx_silv_rec.fed_depre_salvage);
    p6_a18 := ddx_silv_rec.date_fed_depre;
    p6_a19 := rosetta_g_miss_num_map(ddx_silv_rec.book_salvage);
    p6_a20 := ddx_silv_rec.book_adr_convention;
    p6_a21 := rosetta_g_miss_num_map(ddx_silv_rec.state_depre_salvage);
    p6_a22 := rosetta_g_miss_num_map(ddx_silv_rec.fed_depre_basis_percent);
    p6_a23 := rosetta_g_miss_num_map(ddx_silv_rec.book_basis_percent);
    p6_a24 := ddx_silv_rec.date_delivery;
    p6_a25 := rosetta_g_miss_num_map(ddx_silv_rec.book_term);
    p6_a26 := rosetta_g_miss_num_map(ddx_silv_rec.residual_guarantee_amount);
    p6_a27 := ddx_silv_rec.date_funding;
    p6_a28 := ddx_silv_rec.date_book;
    p6_a29 := ddx_silv_rec.date_state_depre;
    p6_a30 := ddx_silv_rec.book_method;
    p6_a31 := ddx_silv_rec.stream_interface_attribute08;
    p6_a32 := ddx_silv_rec.stream_interface_attribute03;
    p6_a33 := ddx_silv_rec.stream_interface_attribute01;
    p6_a34 := rosetta_g_miss_num_map(ddx_silv_rec.index_number);
    p6_a35 := ddx_silv_rec.stream_interface_attribute05;
    p6_a36 := ddx_silv_rec.description;
    p6_a37 := ddx_silv_rec.stream_interface_attribute10;
    p6_a38 := ddx_silv_rec.stream_interface_attribute06;
    p6_a39 := ddx_silv_rec.stream_interface_attribute09;
    p6_a40 := ddx_silv_rec.stream_interface_attribute07;
    p6_a41 := ddx_silv_rec.stream_interface_attribute14;
    p6_a42 := ddx_silv_rec.stream_interface_attribute12;
    p6_a43 := ddx_silv_rec.stream_interface_attribute15;
    p6_a44 := ddx_silv_rec.stream_interface_attribute02;
    p6_a45 := ddx_silv_rec.stream_interface_attribute11;
    p6_a46 := ddx_silv_rec.stream_interface_attribute04;
    p6_a47 := ddx_silv_rec.stream_interface_attribute13;
    p6_a48 := ddx_silv_rec.date_start;
    p6_a49 := ddx_silv_rec.date_lending;
    p6_a50 := rosetta_g_miss_num_map(ddx_silv_rec.sif_id);
    p6_a51 := rosetta_g_miss_num_map(ddx_silv_rec.object_version_number);
    p6_a52 := rosetta_g_miss_num_map(ddx_silv_rec.kle_id);
    p6_a53 := ddx_silv_rec.sil_type;
    p6_a54 := rosetta_g_miss_num_map(ddx_silv_rec.created_by);
    p6_a55 := rosetta_g_miss_num_map(ddx_silv_rec.last_updated_by);
    p6_a56 := ddx_silv_rec.creation_date;
    p6_a57 := ddx_silv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_silv_rec.last_update_login);
    p6_a59 := ddx_silv_rec.residual_guarantee_type;
    p6_a60 := rosetta_g_miss_num_map(ddx_silv_rec.down_payment_amount);
    p6_a61 := ddx_silv_rec.capitalize_down_payment_yn;
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
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_2000
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_DATE_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_DATE_TABLE
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_NUMBER_TABLE
    , p6_a56 out nocopy JTF_DATE_TABLE
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a60 out nocopy JTF_NUMBER_TABLE
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_silv_tbl okl_sil_pvt.silv_tbl_type;
    ddx_silv_tbl okl_sil_pvt.silv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sil_pvt_w.rosetta_table_copy_in_p5(ddp_silv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_tbl,
      ddx_silv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sil_pvt_w.rosetta_table_copy_out_p5(ddx_silv_tbl, p6_a0
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
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  DATE := fnd_api.g_miss_date
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_silv_rec okl_sil_pvt.silv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_silv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_silv_rec.state_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a1);
    ddp_silv_rec.book_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a2);
    ddp_silv_rec.residual_guarantee_method := p5_a3;
    ddp_silv_rec.residual_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_silv_rec.fed_depre_term := rosetta_g_miss_num_map(p5_a5);
    ddp_silv_rec.fed_depre_dmnshing_value_rate := rosetta_g_miss_num_map(p5_a6);
    ddp_silv_rec.fed_depre_adr_conve := p5_a7;
    ddp_silv_rec.state_depre_basis_percent := rosetta_g_miss_num_map(p5_a8);
    ddp_silv_rec.state_depre_method := p5_a9;
    ddp_silv_rec.purchase_option := p5_a10;
    ddp_silv_rec.purchase_option_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_silv_rec.asset_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_silv_rec.state_depre_term := rosetta_g_miss_num_map(p5_a13);
    ddp_silv_rec.state_depre_adr_convent := p5_a14;
    ddp_silv_rec.fed_depre_method := p5_a15;
    ddp_silv_rec.residual_amount := rosetta_g_miss_num_map(p5_a16);
    ddp_silv_rec.fed_depre_salvage := rosetta_g_miss_num_map(p5_a17);
    ddp_silv_rec.date_fed_depre := rosetta_g_miss_date_in_map(p5_a18);
    ddp_silv_rec.book_salvage := rosetta_g_miss_num_map(p5_a19);
    ddp_silv_rec.book_adr_convention := p5_a20;
    ddp_silv_rec.state_depre_salvage := rosetta_g_miss_num_map(p5_a21);
    ddp_silv_rec.fed_depre_basis_percent := rosetta_g_miss_num_map(p5_a22);
    ddp_silv_rec.book_basis_percent := rosetta_g_miss_num_map(p5_a23);
    ddp_silv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a24);
    ddp_silv_rec.book_term := rosetta_g_miss_num_map(p5_a25);
    ddp_silv_rec.residual_guarantee_amount := rosetta_g_miss_num_map(p5_a26);
    ddp_silv_rec.date_funding := rosetta_g_miss_date_in_map(p5_a27);
    ddp_silv_rec.date_book := rosetta_g_miss_date_in_map(p5_a28);
    ddp_silv_rec.date_state_depre := rosetta_g_miss_date_in_map(p5_a29);
    ddp_silv_rec.book_method := p5_a30;
    ddp_silv_rec.stream_interface_attribute08 := p5_a31;
    ddp_silv_rec.stream_interface_attribute03 := p5_a32;
    ddp_silv_rec.stream_interface_attribute01 := p5_a33;
    ddp_silv_rec.index_number := rosetta_g_miss_num_map(p5_a34);
    ddp_silv_rec.stream_interface_attribute05 := p5_a35;
    ddp_silv_rec.description := p5_a36;
    ddp_silv_rec.stream_interface_attribute10 := p5_a37;
    ddp_silv_rec.stream_interface_attribute06 := p5_a38;
    ddp_silv_rec.stream_interface_attribute09 := p5_a39;
    ddp_silv_rec.stream_interface_attribute07 := p5_a40;
    ddp_silv_rec.stream_interface_attribute14 := p5_a41;
    ddp_silv_rec.stream_interface_attribute12 := p5_a42;
    ddp_silv_rec.stream_interface_attribute15 := p5_a43;
    ddp_silv_rec.stream_interface_attribute02 := p5_a44;
    ddp_silv_rec.stream_interface_attribute11 := p5_a45;
    ddp_silv_rec.stream_interface_attribute04 := p5_a46;
    ddp_silv_rec.stream_interface_attribute13 := p5_a47;
    ddp_silv_rec.date_start := rosetta_g_miss_date_in_map(p5_a48);
    ddp_silv_rec.date_lending := rosetta_g_miss_date_in_map(p5_a49);
    ddp_silv_rec.sif_id := rosetta_g_miss_num_map(p5_a50);
    ddp_silv_rec.object_version_number := rosetta_g_miss_num_map(p5_a51);
    ddp_silv_rec.kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_silv_rec.sil_type := p5_a53;
    ddp_silv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_silv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a55);
    ddp_silv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a56);
    ddp_silv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_silv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_silv_rec.residual_guarantee_type := p5_a59;
    ddp_silv_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a60);
    ddp_silv_rec.capitalize_down_payment_yn := p5_a61;

    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_rec);

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
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_2000
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_DATE_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_silv_tbl okl_sil_pvt.silv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sil_pvt_w.rosetta_table_copy_in_p5(ddp_silv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_tbl);

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
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a48  DATE := fnd_api.g_miss_date
    , p5_a49  DATE := fnd_api.g_miss_date
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  NUMBER := 0-1962.0724
    , p5_a56  DATE := fnd_api.g_miss_date
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_silv_rec okl_sil_pvt.silv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_silv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_silv_rec.state_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a1);
    ddp_silv_rec.book_depre_dmnshing_value_rt := rosetta_g_miss_num_map(p5_a2);
    ddp_silv_rec.residual_guarantee_method := p5_a3;
    ddp_silv_rec.residual_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_silv_rec.fed_depre_term := rosetta_g_miss_num_map(p5_a5);
    ddp_silv_rec.fed_depre_dmnshing_value_rate := rosetta_g_miss_num_map(p5_a6);
    ddp_silv_rec.fed_depre_adr_conve := p5_a7;
    ddp_silv_rec.state_depre_basis_percent := rosetta_g_miss_num_map(p5_a8);
    ddp_silv_rec.state_depre_method := p5_a9;
    ddp_silv_rec.purchase_option := p5_a10;
    ddp_silv_rec.purchase_option_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_silv_rec.asset_cost := rosetta_g_miss_num_map(p5_a12);
    ddp_silv_rec.state_depre_term := rosetta_g_miss_num_map(p5_a13);
    ddp_silv_rec.state_depre_adr_convent := p5_a14;
    ddp_silv_rec.fed_depre_method := p5_a15;
    ddp_silv_rec.residual_amount := rosetta_g_miss_num_map(p5_a16);
    ddp_silv_rec.fed_depre_salvage := rosetta_g_miss_num_map(p5_a17);
    ddp_silv_rec.date_fed_depre := rosetta_g_miss_date_in_map(p5_a18);
    ddp_silv_rec.book_salvage := rosetta_g_miss_num_map(p5_a19);
    ddp_silv_rec.book_adr_convention := p5_a20;
    ddp_silv_rec.state_depre_salvage := rosetta_g_miss_num_map(p5_a21);
    ddp_silv_rec.fed_depre_basis_percent := rosetta_g_miss_num_map(p5_a22);
    ddp_silv_rec.book_basis_percent := rosetta_g_miss_num_map(p5_a23);
    ddp_silv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a24);
    ddp_silv_rec.book_term := rosetta_g_miss_num_map(p5_a25);
    ddp_silv_rec.residual_guarantee_amount := rosetta_g_miss_num_map(p5_a26);
    ddp_silv_rec.date_funding := rosetta_g_miss_date_in_map(p5_a27);
    ddp_silv_rec.date_book := rosetta_g_miss_date_in_map(p5_a28);
    ddp_silv_rec.date_state_depre := rosetta_g_miss_date_in_map(p5_a29);
    ddp_silv_rec.book_method := p5_a30;
    ddp_silv_rec.stream_interface_attribute08 := p5_a31;
    ddp_silv_rec.stream_interface_attribute03 := p5_a32;
    ddp_silv_rec.stream_interface_attribute01 := p5_a33;
    ddp_silv_rec.index_number := rosetta_g_miss_num_map(p5_a34);
    ddp_silv_rec.stream_interface_attribute05 := p5_a35;
    ddp_silv_rec.description := p5_a36;
    ddp_silv_rec.stream_interface_attribute10 := p5_a37;
    ddp_silv_rec.stream_interface_attribute06 := p5_a38;
    ddp_silv_rec.stream_interface_attribute09 := p5_a39;
    ddp_silv_rec.stream_interface_attribute07 := p5_a40;
    ddp_silv_rec.stream_interface_attribute14 := p5_a41;
    ddp_silv_rec.stream_interface_attribute12 := p5_a42;
    ddp_silv_rec.stream_interface_attribute15 := p5_a43;
    ddp_silv_rec.stream_interface_attribute02 := p5_a44;
    ddp_silv_rec.stream_interface_attribute11 := p5_a45;
    ddp_silv_rec.stream_interface_attribute04 := p5_a46;
    ddp_silv_rec.stream_interface_attribute13 := p5_a47;
    ddp_silv_rec.date_start := rosetta_g_miss_date_in_map(p5_a48);
    ddp_silv_rec.date_lending := rosetta_g_miss_date_in_map(p5_a49);
    ddp_silv_rec.sif_id := rosetta_g_miss_num_map(p5_a50);
    ddp_silv_rec.object_version_number := rosetta_g_miss_num_map(p5_a51);
    ddp_silv_rec.kle_id := rosetta_g_miss_num_map(p5_a52);
    ddp_silv_rec.sil_type := p5_a53;
    ddp_silv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_silv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a55);
    ddp_silv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a56);
    ddp_silv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_silv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_silv_rec.residual_guarantee_type := p5_a59;
    ddp_silv_rec.down_payment_amount := rosetta_g_miss_num_map(p5_a60);
    ddp_silv_rec.capitalize_down_payment_yn := p5_a61;

    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_rec);

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
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_2000
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_VARCHAR2_TABLE_500
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_DATE_TABLE
    , p5_a49 JTF_DATE_TABLE
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_NUMBER_TABLE
    , p5_a56 JTF_DATE_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_NUMBER_TABLE
    , p5_a61 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_silv_tbl okl_sil_pvt.silv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sil_pvt_w.rosetta_table_copy_in_p5(ddp_silv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sil_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_silv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_sil_pvt_w;

/
