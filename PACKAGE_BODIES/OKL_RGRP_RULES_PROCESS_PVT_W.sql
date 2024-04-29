--------------------------------------------------------
--  DDL for Package Body OKL_RGRP_RULES_PROCESS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RGRP_RULES_PROCESS_PVT_W" as
  /* $Header: OKLERGRB.pls 120.1 2005/07/11 14:20:11 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_rgrp_rules_process_pvt.rgr_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_VARCHAR2_TABLE_100
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
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
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
    , a54 JTF_VARCHAR2_TABLE_500
    , a55 JTF_VARCHAR2_TABLE_500
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rgd_code := a0(indx);
          t(ddindx).rule_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).sfwt_flag := a3(indx);
          t(ddindx).object1_id1 := a4(indx);
          t(ddindx).object2_id1 := a5(indx);
          t(ddindx).object3_id1 := a6(indx);
          t(ddindx).object1_id2 := a7(indx);
          t(ddindx).object2_id2 := a8(indx);
          t(ddindx).object3_id2 := a9(indx);
          t(ddindx).jtot_object1_code := a10(indx);
          t(ddindx).jtot_object2_code := a11(indx);
          t(ddindx).jtot_object3_code := a12(indx);
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).rgp_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).priority := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).std_template_yn := a16(indx);
          t(ddindx).comments := a17(indx);
          t(ddindx).warn_yn := a18(indx);
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
          t(ddindx).created_by := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a38(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a39(indx));
          t(ddindx).rule_information_category := a40(indx);
          t(ddindx).rule_information1 := a41(indx);
          t(ddindx).rule_information2 := a42(indx);
          t(ddindx).rule_information3 := a43(indx);
          t(ddindx).rule_information4 := a44(indx);
          t(ddindx).rule_information5 := a45(indx);
          t(ddindx).rule_information6 := a46(indx);
          t(ddindx).rule_information7 := a47(indx);
          t(ddindx).rule_information8 := a48(indx);
          t(ddindx).rule_information9 := a49(indx);
          t(ddindx).rule_information10 := a50(indx);
          t(ddindx).rule_information11 := a51(indx);
          t(ddindx).rule_information12 := a52(indx);
          t(ddindx).rule_information13 := a53(indx);
          t(ddindx).rule_information14 := a54(indx);
          t(ddindx).rule_information15 := a55(indx);
          t(ddindx).template_yn := a56(indx);
          t(ddindx).ans_set_jtot_object_code := a57(indx);
          t(ddindx).ans_set_jtot_object_id1 := a58(indx);
          t(ddindx).ans_set_jtot_object_id2 := a59(indx);
          t(ddindx).display_sequence := rosetta_g_miss_num_map(a60(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_rgrp_rules_process_pvt.rgr_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a54 out nocopy JTF_VARCHAR2_TABLE_500
    , a55 out nocopy JTF_VARCHAR2_TABLE_500
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_VARCHAR2_TABLE_100
    , a60 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_VARCHAR2_TABLE_100();
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
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_VARCHAR2_TABLE_100();
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
    a54 := JTF_VARCHAR2_TABLE_500();
    a55 := JTF_VARCHAR2_TABLE_500();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_VARCHAR2_TABLE_100();
    a60 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_VARCHAR2_TABLE_100();
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
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_VARCHAR2_TABLE_100();
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
      a54 := JTF_VARCHAR2_TABLE_500();
      a55 := JTF_VARCHAR2_TABLE_500();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_VARCHAR2_TABLE_100();
      a60 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rgd_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).rule_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := t(ddindx).sfwt_flag;
          a4(indx) := t(ddindx).object1_id1;
          a5(indx) := t(ddindx).object2_id1;
          a6(indx) := t(ddindx).object3_id1;
          a7(indx) := t(ddindx).object1_id2;
          a8(indx) := t(ddindx).object2_id2;
          a9(indx) := t(ddindx).object3_id2;
          a10(indx) := t(ddindx).jtot_object1_code;
          a11(indx) := t(ddindx).jtot_object2_code;
          a12(indx) := t(ddindx).jtot_object3_code;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).rgp_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).priority);
          a16(indx) := t(ddindx).std_template_yn;
          a17(indx) := t(ddindx).comments;
          a18(indx) := t(ddindx).warn_yn;
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
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a36(indx) := t(ddindx).creation_date;
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a38(indx) := t(ddindx).last_update_date;
          a39(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a40(indx) := t(ddindx).rule_information_category;
          a41(indx) := t(ddindx).rule_information1;
          a42(indx) := t(ddindx).rule_information2;
          a43(indx) := t(ddindx).rule_information3;
          a44(indx) := t(ddindx).rule_information4;
          a45(indx) := t(ddindx).rule_information5;
          a46(indx) := t(ddindx).rule_information6;
          a47(indx) := t(ddindx).rule_information7;
          a48(indx) := t(ddindx).rule_information8;
          a49(indx) := t(ddindx).rule_information9;
          a50(indx) := t(ddindx).rule_information10;
          a51(indx) := t(ddindx).rule_information11;
          a52(indx) := t(ddindx).rule_information12;
          a53(indx) := t(ddindx).rule_information13;
          a54(indx) := t(ddindx).rule_information14;
          a55(indx) := t(ddindx).rule_information15;
          a56(indx) := t(ddindx).template_yn;
          a57(indx) := t(ddindx).ans_set_jtot_object_code;
          a58(indx) := t(ddindx).ans_set_jtot_object_id1;
          a59(indx) := t(ddindx).ans_set_jtot_object_id2;
          a60(indx) := rosetta_g_miss_num_map(t(ddindx).display_sequence);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_rgrp_rules_process_pvt.rgr_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).rule_code := a1(indx);
          t(ddindx).rgd_code := a2(indx);
          t(ddindx).new_yn := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_rgrp_rules_process_pvt.rgr_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).rule_code;
          a2(indx) := t(ddindx).rgd_code;
          a3(indx) := t(ddindx).new_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure process_rule_group_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_line_id  NUMBER
    , p_cpl_id  NUMBER
    , p_rrd_id  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_VARCHAR2_TABLE_100
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_200
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_VARCHAR2_TABLE_2000
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_500
    , p9_a21 JTF_VARCHAR2_TABLE_500
    , p9_a22 JTF_VARCHAR2_TABLE_500
    , p9_a23 JTF_VARCHAR2_TABLE_500
    , p9_a24 JTF_VARCHAR2_TABLE_500
    , p9_a25 JTF_VARCHAR2_TABLE_500
    , p9_a26 JTF_VARCHAR2_TABLE_500
    , p9_a27 JTF_VARCHAR2_TABLE_500
    , p9_a28 JTF_VARCHAR2_TABLE_500
    , p9_a29 JTF_VARCHAR2_TABLE_500
    , p9_a30 JTF_VARCHAR2_TABLE_500
    , p9_a31 JTF_VARCHAR2_TABLE_500
    , p9_a32 JTF_VARCHAR2_TABLE_500
    , p9_a33 JTF_VARCHAR2_TABLE_500
    , p9_a34 JTF_VARCHAR2_TABLE_500
    , p9_a35 JTF_NUMBER_TABLE
    , p9_a36 JTF_DATE_TABLE
    , p9_a37 JTF_NUMBER_TABLE
    , p9_a38 JTF_DATE_TABLE
    , p9_a39 JTF_NUMBER_TABLE
    , p9_a40 JTF_VARCHAR2_TABLE_100
    , p9_a41 JTF_VARCHAR2_TABLE_500
    , p9_a42 JTF_VARCHAR2_TABLE_500
    , p9_a43 JTF_VARCHAR2_TABLE_500
    , p9_a44 JTF_VARCHAR2_TABLE_500
    , p9_a45 JTF_VARCHAR2_TABLE_500
    , p9_a46 JTF_VARCHAR2_TABLE_500
    , p9_a47 JTF_VARCHAR2_TABLE_500
    , p9_a48 JTF_VARCHAR2_TABLE_500
    , p9_a49 JTF_VARCHAR2_TABLE_500
    , p9_a50 JTF_VARCHAR2_TABLE_500
    , p9_a51 JTF_VARCHAR2_TABLE_500
    , p9_a52 JTF_VARCHAR2_TABLE_500
    , p9_a53 JTF_VARCHAR2_TABLE_500
    , p9_a54 JTF_VARCHAR2_TABLE_500
    , p9_a55 JTF_VARCHAR2_TABLE_500
    , p9_a56 JTF_VARCHAR2_TABLE_100
    , p9_a57 JTF_VARCHAR2_TABLE_100
    , p9_a58 JTF_VARCHAR2_TABLE_100
    , p9_a59 JTF_VARCHAR2_TABLE_100
    , p9_a60 JTF_NUMBER_TABLE
  )

  as
    ddp_rgr_tbl okl_rgrp_rules_process_pvt.rgr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_in_p2(ddp_rgr_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rgrp_rules_process_pvt.process_rule_group_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_line_id,
      p_cpl_id,
      p_rrd_id,
      ddp_rgr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure process_template_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_id  NUMBER
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_VARCHAR2_TABLE_200
    , p6_a8 JTF_VARCHAR2_TABLE_200
    , p6_a9 JTF_VARCHAR2_TABLE_200
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_VARCHAR2_TABLE_2000
    , p6_a18 JTF_VARCHAR2_TABLE_100
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_DATE_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_VARCHAR2_TABLE_500
    , p6_a44 JTF_VARCHAR2_TABLE_500
    , p6_a45 JTF_VARCHAR2_TABLE_500
    , p6_a46 JTF_VARCHAR2_TABLE_500
    , p6_a47 JTF_VARCHAR2_TABLE_500
    , p6_a48 JTF_VARCHAR2_TABLE_500
    , p6_a49 JTF_VARCHAR2_TABLE_500
    , p6_a50 JTF_VARCHAR2_TABLE_500
    , p6_a51 JTF_VARCHAR2_TABLE_500
    , p6_a52 JTF_VARCHAR2_TABLE_500
    , p6_a53 JTF_VARCHAR2_TABLE_500
    , p6_a54 JTF_VARCHAR2_TABLE_500
    , p6_a55 JTF_VARCHAR2_TABLE_500
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_VARCHAR2_TABLE_100
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rgr_tbl okl_rgrp_rules_process_pvt.rgr_tbl_type;
    ddx_rgr_tbl okl_rgrp_rules_process_pvt.rgr_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_in_p2(ddp_rgr_tbl, p6_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rgrp_rules_process_pvt.process_template_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_id,
      ddp_rgr_tbl,
      ddx_rgr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_out_p3(ddx_rgr_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );
  end;

end okl_rgrp_rules_process_pvt_w;

/
