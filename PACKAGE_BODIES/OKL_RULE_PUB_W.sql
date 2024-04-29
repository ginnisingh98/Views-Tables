--------------------------------------------------------
--  DDL for Package Body OKL_RULE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RULE_PUB_W" as
  /* $Header: OKLURULB.pls 120.2 2005/08/03 05:51:32 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_rule_pub.rulv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
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
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
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
    , a54 JTF_VARCHAR2_TABLE_500
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_NUMBER_TABLE
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
          t(ddindx).object1_id1 := a3(indx);
          t(ddindx).object2_id1 := a4(indx);
          t(ddindx).object3_id1 := a5(indx);
          t(ddindx).object1_id2 := a6(indx);
          t(ddindx).object2_id2 := a7(indx);
          t(ddindx).object3_id2 := a8(indx);
          t(ddindx).jtot_object1_code := a9(indx);
          t(ddindx).jtot_object2_code := a10(indx);
          t(ddindx).jtot_object3_code := a11(indx);
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).rgp_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).priority := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).std_template_yn := a15(indx);
          t(ddindx).comments := a16(indx);
          t(ddindx).warn_yn := a17(indx);
          t(ddindx).attribute_category := a18(indx);
          t(ddindx).attribute1 := a19(indx);
          t(ddindx).attribute2 := a20(indx);
          t(ddindx).attribute3 := a21(indx);
          t(ddindx).attribute4 := a22(indx);
          t(ddindx).attribute5 := a23(indx);
          t(ddindx).attribute6 := a24(indx);
          t(ddindx).attribute7 := a25(indx);
          t(ddindx).attribute8 := a26(indx);
          t(ddindx).attribute9 := a27(indx);
          t(ddindx).attribute10 := a28(indx);
          t(ddindx).attribute11 := a29(indx);
          t(ddindx).attribute12 := a30(indx);
          t(ddindx).attribute13 := a31(indx);
          t(ddindx).attribute14 := a32(indx);
          t(ddindx).attribute15 := a33(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a35(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a36(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a37(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).rule_information_category := a39(indx);
          t(ddindx).rule_information1 := a40(indx);
          t(ddindx).rule_information2 := a41(indx);
          t(ddindx).rule_information3 := a42(indx);
          t(ddindx).rule_information4 := a43(indx);
          t(ddindx).rule_information5 := a44(indx);
          t(ddindx).rule_information6 := a45(indx);
          t(ddindx).rule_information7 := a46(indx);
          t(ddindx).rule_information8 := a47(indx);
          t(ddindx).rule_information9 := a48(indx);
          t(ddindx).rule_information10 := a49(indx);
          t(ddindx).rule_information11 := a50(indx);
          t(ddindx).rule_information12 := a51(indx);
          t(ddindx).rule_information13 := a52(indx);
          t(ddindx).rule_information14 := a53(indx);
          t(ddindx).rule_information15 := a54(indx);
          t(ddindx).template_yn := a55(indx);
          t(ddindx).ans_set_jtot_object_code := a56(indx);
          t(ddindx).ans_set_jtot_object_id1 := a57(indx);
          t(ddindx).ans_set_jtot_object_id2 := a58(indx);
          t(ddindx).display_sequence := rosetta_g_miss_num_map(a59(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_rule_pub.rulv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a54 out nocopy JTF_VARCHAR2_TABLE_500
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_NUMBER_TABLE
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
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
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
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
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
    a54 := JTF_VARCHAR2_TABLE_500();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_VARCHAR2_TABLE_100();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
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
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
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
      a54 := JTF_VARCHAR2_TABLE_500();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_VARCHAR2_TABLE_100();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).sfwt_flag;
          a3(indx) := t(ddindx).object1_id1;
          a4(indx) := t(ddindx).object2_id1;
          a5(indx) := t(ddindx).object3_id1;
          a6(indx) := t(ddindx).object1_id2;
          a7(indx) := t(ddindx).object2_id2;
          a8(indx) := t(ddindx).object3_id2;
          a9(indx) := t(ddindx).jtot_object1_code;
          a10(indx) := t(ddindx).jtot_object2_code;
          a11(indx) := t(ddindx).jtot_object3_code;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).rgp_id);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).priority);
          a15(indx) := t(ddindx).std_template_yn;
          a16(indx) := t(ddindx).comments;
          a17(indx) := t(ddindx).warn_yn;
          a18(indx) := t(ddindx).attribute_category;
          a19(indx) := t(ddindx).attribute1;
          a20(indx) := t(ddindx).attribute2;
          a21(indx) := t(ddindx).attribute3;
          a22(indx) := t(ddindx).attribute4;
          a23(indx) := t(ddindx).attribute5;
          a24(indx) := t(ddindx).attribute6;
          a25(indx) := t(ddindx).attribute7;
          a26(indx) := t(ddindx).attribute8;
          a27(indx) := t(ddindx).attribute9;
          a28(indx) := t(ddindx).attribute10;
          a29(indx) := t(ddindx).attribute11;
          a30(indx) := t(ddindx).attribute12;
          a31(indx) := t(ddindx).attribute13;
          a32(indx) := t(ddindx).attribute14;
          a33(indx) := t(ddindx).attribute15;
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a35(indx) := t(ddindx).creation_date;
          a36(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a37(indx) := t(ddindx).last_update_date;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a39(indx) := t(ddindx).rule_information_category;
          a40(indx) := t(ddindx).rule_information1;
          a41(indx) := t(ddindx).rule_information2;
          a42(indx) := t(ddindx).rule_information3;
          a43(indx) := t(ddindx).rule_information4;
          a44(indx) := t(ddindx).rule_information5;
          a45(indx) := t(ddindx).rule_information6;
          a46(indx) := t(ddindx).rule_information7;
          a47(indx) := t(ddindx).rule_information8;
          a48(indx) := t(ddindx).rule_information9;
          a49(indx) := t(ddindx).rule_information10;
          a50(indx) := t(ddindx).rule_information11;
          a51(indx) := t(ddindx).rule_information12;
          a52(indx) := t(ddindx).rule_information13;
          a53(indx) := t(ddindx).rule_information14;
          a54(indx) := t(ddindx).rule_information15;
          a55(indx) := t(ddindx).template_yn;
          a56(indx) := t(ddindx).ans_set_jtot_object_code;
          a57(indx) := t(ddindx).ans_set_jtot_object_id1;
          a58(indx) := t(ddindx).ans_set_jtot_object_id2;
          a59(indx) := rosetta_g_miss_num_map(t(ddindx).display_sequence);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  CHAR
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
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
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  NUMBER
    , p_euro_conv_yn  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  CHAR := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_rule_pub.rulv_rec_type;
    ddx_rulv_rec okl_rule_pub.rulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rulv_rec.sfwt_flag := p5_a2;
    ddp_rulv_rec.object1_id1 := p5_a3;
    ddp_rulv_rec.object2_id1 := p5_a4;
    ddp_rulv_rec.object3_id1 := p5_a5;
    ddp_rulv_rec.object1_id2 := p5_a6;
    ddp_rulv_rec.object2_id2 := p5_a7;
    ddp_rulv_rec.object3_id2 := p5_a8;
    ddp_rulv_rec.jtot_object1_code := p5_a9;
    ddp_rulv_rec.jtot_object2_code := p5_a10;
    ddp_rulv_rec.jtot_object3_code := p5_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p5_a14);
    ddp_rulv_rec.std_template_yn := p5_a15;
    ddp_rulv_rec.comments := p5_a16;
    ddp_rulv_rec.warn_yn := p5_a17;
    ddp_rulv_rec.attribute_category := p5_a18;
    ddp_rulv_rec.attribute1 := p5_a19;
    ddp_rulv_rec.attribute2 := p5_a20;
    ddp_rulv_rec.attribute3 := p5_a21;
    ddp_rulv_rec.attribute4 := p5_a22;
    ddp_rulv_rec.attribute5 := p5_a23;
    ddp_rulv_rec.attribute6 := p5_a24;
    ddp_rulv_rec.attribute7 := p5_a25;
    ddp_rulv_rec.attribute8 := p5_a26;
    ddp_rulv_rec.attribute9 := p5_a27;
    ddp_rulv_rec.attribute10 := p5_a28;
    ddp_rulv_rec.attribute11 := p5_a29;
    ddp_rulv_rec.attribute12 := p5_a30;
    ddp_rulv_rec.attribute13 := p5_a31;
    ddp_rulv_rec.attribute14 := p5_a32;
    ddp_rulv_rec.attribute15 := p5_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_rulv_rec.rule_information_category := p5_a39;
    ddp_rulv_rec.rule_information1 := p5_a40;
    ddp_rulv_rec.rule_information2 := p5_a41;
    ddp_rulv_rec.rule_information3 := p5_a42;
    ddp_rulv_rec.rule_information4 := p5_a43;
    ddp_rulv_rec.rule_information5 := p5_a44;
    ddp_rulv_rec.rule_information6 := p5_a45;
    ddp_rulv_rec.rule_information7 := p5_a46;
    ddp_rulv_rec.rule_information8 := p5_a47;
    ddp_rulv_rec.rule_information9 := p5_a48;
    ddp_rulv_rec.rule_information10 := p5_a49;
    ddp_rulv_rec.rule_information11 := p5_a50;
    ddp_rulv_rec.rule_information12 := p5_a51;
    ddp_rulv_rec.rule_information13 := p5_a52;
    ddp_rulv_rec.rule_information14 := p5_a53;
    ddp_rulv_rec.rule_information15 := p5_a54;
    ddp_rulv_rec.template_yn := p5_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p5_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p5_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p5_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p5_a59);



    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.create_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_rec,
      ddx_rulv_rec,
      p_euro_conv_yn);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rulv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rulv_rec.object_version_number);
    p6_a2 := ddx_rulv_rec.sfwt_flag;
    p6_a3 := ddx_rulv_rec.object1_id1;
    p6_a4 := ddx_rulv_rec.object2_id1;
    p6_a5 := ddx_rulv_rec.object3_id1;
    p6_a6 := ddx_rulv_rec.object1_id2;
    p6_a7 := ddx_rulv_rec.object2_id2;
    p6_a8 := ddx_rulv_rec.object3_id2;
    p6_a9 := ddx_rulv_rec.jtot_object1_code;
    p6_a10 := ddx_rulv_rec.jtot_object2_code;
    p6_a11 := ddx_rulv_rec.jtot_object3_code;
    p6_a12 := rosetta_g_miss_num_map(ddx_rulv_rec.dnz_chr_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_rulv_rec.rgp_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_rulv_rec.priority);
    p6_a15 := ddx_rulv_rec.std_template_yn;
    p6_a16 := ddx_rulv_rec.comments;
    p6_a17 := ddx_rulv_rec.warn_yn;
    p6_a18 := ddx_rulv_rec.attribute_category;
    p6_a19 := ddx_rulv_rec.attribute1;
    p6_a20 := ddx_rulv_rec.attribute2;
    p6_a21 := ddx_rulv_rec.attribute3;
    p6_a22 := ddx_rulv_rec.attribute4;
    p6_a23 := ddx_rulv_rec.attribute5;
    p6_a24 := ddx_rulv_rec.attribute6;
    p6_a25 := ddx_rulv_rec.attribute7;
    p6_a26 := ddx_rulv_rec.attribute8;
    p6_a27 := ddx_rulv_rec.attribute9;
    p6_a28 := ddx_rulv_rec.attribute10;
    p6_a29 := ddx_rulv_rec.attribute11;
    p6_a30 := ddx_rulv_rec.attribute12;
    p6_a31 := ddx_rulv_rec.attribute13;
    p6_a32 := ddx_rulv_rec.attribute14;
    p6_a33 := ddx_rulv_rec.attribute15;
    p6_a34 := rosetta_g_miss_num_map(ddx_rulv_rec.created_by);
    p6_a35 := ddx_rulv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_rulv_rec.last_updated_by);
    p6_a37 := ddx_rulv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_rulv_rec.last_update_login);
    p6_a39 := ddx_rulv_rec.rule_information_category;
    p6_a40 := ddx_rulv_rec.rule_information1;
    p6_a41 := ddx_rulv_rec.rule_information2;
    p6_a42 := ddx_rulv_rec.rule_information3;
    p6_a43 := ddx_rulv_rec.rule_information4;
    p6_a44 := ddx_rulv_rec.rule_information5;
    p6_a45 := ddx_rulv_rec.rule_information6;
    p6_a46 := ddx_rulv_rec.rule_information7;
    p6_a47 := ddx_rulv_rec.rule_information8;
    p6_a48 := ddx_rulv_rec.rule_information9;
    p6_a49 := ddx_rulv_rec.rule_information10;
    p6_a50 := ddx_rulv_rec.rule_information11;
    p6_a51 := ddx_rulv_rec.rule_information12;
    p6_a52 := ddx_rulv_rec.rule_information13;
    p6_a53 := ddx_rulv_rec.rule_information14;
    p6_a54 := ddx_rulv_rec.rule_information15;
    p6_a55 := ddx_rulv_rec.template_yn;
    p6_a56 := ddx_rulv_rec.ans_set_jtot_object_code;
    p6_a57 := ddx_rulv_rec.ans_set_jtot_object_id1;
    p6_a58 := ddx_rulv_rec.ans_set_jtot_object_id2;
    p6_a59 := rosetta_g_miss_num_map(ddx_rulv_rec.display_sequence);

  end;

  procedure create_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  CHAR
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
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
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  CHAR := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_rule_pub.rulv_rec_type;
    ddx_rulv_rec okl_rule_pub.rulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rulv_rec.sfwt_flag := p5_a2;
    ddp_rulv_rec.object1_id1 := p5_a3;
    ddp_rulv_rec.object2_id1 := p5_a4;
    ddp_rulv_rec.object3_id1 := p5_a5;
    ddp_rulv_rec.object1_id2 := p5_a6;
    ddp_rulv_rec.object2_id2 := p5_a7;
    ddp_rulv_rec.object3_id2 := p5_a8;
    ddp_rulv_rec.jtot_object1_code := p5_a9;
    ddp_rulv_rec.jtot_object2_code := p5_a10;
    ddp_rulv_rec.jtot_object3_code := p5_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p5_a14);
    ddp_rulv_rec.std_template_yn := p5_a15;
    ddp_rulv_rec.comments := p5_a16;
    ddp_rulv_rec.warn_yn := p5_a17;
    ddp_rulv_rec.attribute_category := p5_a18;
    ddp_rulv_rec.attribute1 := p5_a19;
    ddp_rulv_rec.attribute2 := p5_a20;
    ddp_rulv_rec.attribute3 := p5_a21;
    ddp_rulv_rec.attribute4 := p5_a22;
    ddp_rulv_rec.attribute5 := p5_a23;
    ddp_rulv_rec.attribute6 := p5_a24;
    ddp_rulv_rec.attribute7 := p5_a25;
    ddp_rulv_rec.attribute8 := p5_a26;
    ddp_rulv_rec.attribute9 := p5_a27;
    ddp_rulv_rec.attribute10 := p5_a28;
    ddp_rulv_rec.attribute11 := p5_a29;
    ddp_rulv_rec.attribute12 := p5_a30;
    ddp_rulv_rec.attribute13 := p5_a31;
    ddp_rulv_rec.attribute14 := p5_a32;
    ddp_rulv_rec.attribute15 := p5_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_rulv_rec.rule_information_category := p5_a39;
    ddp_rulv_rec.rule_information1 := p5_a40;
    ddp_rulv_rec.rule_information2 := p5_a41;
    ddp_rulv_rec.rule_information3 := p5_a42;
    ddp_rulv_rec.rule_information4 := p5_a43;
    ddp_rulv_rec.rule_information5 := p5_a44;
    ddp_rulv_rec.rule_information6 := p5_a45;
    ddp_rulv_rec.rule_information7 := p5_a46;
    ddp_rulv_rec.rule_information8 := p5_a47;
    ddp_rulv_rec.rule_information9 := p5_a48;
    ddp_rulv_rec.rule_information10 := p5_a49;
    ddp_rulv_rec.rule_information11 := p5_a50;
    ddp_rulv_rec.rule_information12 := p5_a51;
    ddp_rulv_rec.rule_information13 := p5_a52;
    ddp_rulv_rec.rule_information14 := p5_a53;
    ddp_rulv_rec.rule_information15 := p5_a54;
    ddp_rulv_rec.template_yn := p5_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p5_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p5_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p5_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p5_a59);


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.create_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_rec,
      ddx_rulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rulv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rulv_rec.object_version_number);
    p6_a2 := ddx_rulv_rec.sfwt_flag;
    p6_a3 := ddx_rulv_rec.object1_id1;
    p6_a4 := ddx_rulv_rec.object2_id1;
    p6_a5 := ddx_rulv_rec.object3_id1;
    p6_a6 := ddx_rulv_rec.object1_id2;
    p6_a7 := ddx_rulv_rec.object2_id2;
    p6_a8 := ddx_rulv_rec.object3_id2;
    p6_a9 := ddx_rulv_rec.jtot_object1_code;
    p6_a10 := ddx_rulv_rec.jtot_object2_code;
    p6_a11 := ddx_rulv_rec.jtot_object3_code;
    p6_a12 := rosetta_g_miss_num_map(ddx_rulv_rec.dnz_chr_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_rulv_rec.rgp_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_rulv_rec.priority);
    p6_a15 := ddx_rulv_rec.std_template_yn;
    p6_a16 := ddx_rulv_rec.comments;
    p6_a17 := ddx_rulv_rec.warn_yn;
    p6_a18 := ddx_rulv_rec.attribute_category;
    p6_a19 := ddx_rulv_rec.attribute1;
    p6_a20 := ddx_rulv_rec.attribute2;
    p6_a21 := ddx_rulv_rec.attribute3;
    p6_a22 := ddx_rulv_rec.attribute4;
    p6_a23 := ddx_rulv_rec.attribute5;
    p6_a24 := ddx_rulv_rec.attribute6;
    p6_a25 := ddx_rulv_rec.attribute7;
    p6_a26 := ddx_rulv_rec.attribute8;
    p6_a27 := ddx_rulv_rec.attribute9;
    p6_a28 := ddx_rulv_rec.attribute10;
    p6_a29 := ddx_rulv_rec.attribute11;
    p6_a30 := ddx_rulv_rec.attribute12;
    p6_a31 := ddx_rulv_rec.attribute13;
    p6_a32 := ddx_rulv_rec.attribute14;
    p6_a33 := ddx_rulv_rec.attribute15;
    p6_a34 := rosetta_g_miss_num_map(ddx_rulv_rec.created_by);
    p6_a35 := ddx_rulv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_rulv_rec.last_updated_by);
    p6_a37 := ddx_rulv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_rulv_rec.last_update_login);
    p6_a39 := ddx_rulv_rec.rule_information_category;
    p6_a40 := ddx_rulv_rec.rule_information1;
    p6_a41 := ddx_rulv_rec.rule_information2;
    p6_a42 := ddx_rulv_rec.rule_information3;
    p6_a43 := ddx_rulv_rec.rule_information4;
    p6_a44 := ddx_rulv_rec.rule_information5;
    p6_a45 := ddx_rulv_rec.rule_information6;
    p6_a46 := ddx_rulv_rec.rule_information7;
    p6_a47 := ddx_rulv_rec.rule_information8;
    p6_a48 := ddx_rulv_rec.rule_information9;
    p6_a49 := ddx_rulv_rec.rule_information10;
    p6_a50 := ddx_rulv_rec.rule_information11;
    p6_a51 := ddx_rulv_rec.rule_information12;
    p6_a52 := ddx_rulv_rec.rule_information13;
    p6_a53 := ddx_rulv_rec.rule_information14;
    p6_a54 := ddx_rulv_rec.rule_information15;
    p6_a55 := ddx_rulv_rec.template_yn;
    p6_a56 := ddx_rulv_rec.ans_set_jtot_object_code;
    p6_a57 := ddx_rulv_rec.ans_set_jtot_object_id1;
    p6_a58 := ddx_rulv_rec.ans_set_jtot_object_id2;
    p6_a59 := rosetta_g_miss_num_map(ddx_rulv_rec.display_sequence);
  end;

  procedure create_rule(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_500
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
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p_euro_conv_yn  VARCHAR2
  )

  as
    ddp_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddx_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rule_pub_w.rosetta_table_copy_in_p2(ddp_rulv_tbl, p5_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.create_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_tbl,
      ddx_rulv_tbl,
      p_euro_conv_yn);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rule_pub_w.rosetta_table_copy_out_p2(ddx_rulv_tbl, p6_a0
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
      );

  end;

  procedure create_rule(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_500
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
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddx_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rule_pub_w.rosetta_table_copy_in_p2(ddp_rulv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.create_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_tbl,
      ddx_rulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rule_pub_w.rosetta_table_copy_out_p2(ddx_rulv_tbl, p6_a0
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
      );
  end;

  procedure update_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  CHAR
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
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
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  CHAR := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_rule_pub.rulv_rec_type;
    ddx_rulv_rec okl_rule_pub.rulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rulv_rec.sfwt_flag := p5_a2;
    ddp_rulv_rec.object1_id1 := p5_a3;
    ddp_rulv_rec.object2_id1 := p5_a4;
    ddp_rulv_rec.object3_id1 := p5_a5;
    ddp_rulv_rec.object1_id2 := p5_a6;
    ddp_rulv_rec.object2_id2 := p5_a7;
    ddp_rulv_rec.object3_id2 := p5_a8;
    ddp_rulv_rec.jtot_object1_code := p5_a9;
    ddp_rulv_rec.jtot_object2_code := p5_a10;
    ddp_rulv_rec.jtot_object3_code := p5_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p5_a14);
    ddp_rulv_rec.std_template_yn := p5_a15;
    ddp_rulv_rec.comments := p5_a16;
    ddp_rulv_rec.warn_yn := p5_a17;
    ddp_rulv_rec.attribute_category := p5_a18;
    ddp_rulv_rec.attribute1 := p5_a19;
    ddp_rulv_rec.attribute2 := p5_a20;
    ddp_rulv_rec.attribute3 := p5_a21;
    ddp_rulv_rec.attribute4 := p5_a22;
    ddp_rulv_rec.attribute5 := p5_a23;
    ddp_rulv_rec.attribute6 := p5_a24;
    ddp_rulv_rec.attribute7 := p5_a25;
    ddp_rulv_rec.attribute8 := p5_a26;
    ddp_rulv_rec.attribute9 := p5_a27;
    ddp_rulv_rec.attribute10 := p5_a28;
    ddp_rulv_rec.attribute11 := p5_a29;
    ddp_rulv_rec.attribute12 := p5_a30;
    ddp_rulv_rec.attribute13 := p5_a31;
    ddp_rulv_rec.attribute14 := p5_a32;
    ddp_rulv_rec.attribute15 := p5_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_rulv_rec.rule_information_category := p5_a39;
    ddp_rulv_rec.rule_information1 := p5_a40;
    ddp_rulv_rec.rule_information2 := p5_a41;
    ddp_rulv_rec.rule_information3 := p5_a42;
    ddp_rulv_rec.rule_information4 := p5_a43;
    ddp_rulv_rec.rule_information5 := p5_a44;
    ddp_rulv_rec.rule_information6 := p5_a45;
    ddp_rulv_rec.rule_information7 := p5_a46;
    ddp_rulv_rec.rule_information8 := p5_a47;
    ddp_rulv_rec.rule_information9 := p5_a48;
    ddp_rulv_rec.rule_information10 := p5_a49;
    ddp_rulv_rec.rule_information11 := p5_a50;
    ddp_rulv_rec.rule_information12 := p5_a51;
    ddp_rulv_rec.rule_information13 := p5_a52;
    ddp_rulv_rec.rule_information14 := p5_a53;
    ddp_rulv_rec.rule_information15 := p5_a54;
    ddp_rulv_rec.template_yn := p5_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p5_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p5_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p5_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p5_a59);


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.update_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_rec,
      ddx_rulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rulv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rulv_rec.object_version_number);
    p6_a2 := ddx_rulv_rec.sfwt_flag;
    p6_a3 := ddx_rulv_rec.object1_id1;
    p6_a4 := ddx_rulv_rec.object2_id1;
    p6_a5 := ddx_rulv_rec.object3_id1;
    p6_a6 := ddx_rulv_rec.object1_id2;
    p6_a7 := ddx_rulv_rec.object2_id2;
    p6_a8 := ddx_rulv_rec.object3_id2;
    p6_a9 := ddx_rulv_rec.jtot_object1_code;
    p6_a10 := ddx_rulv_rec.jtot_object2_code;
    p6_a11 := ddx_rulv_rec.jtot_object3_code;
    p6_a12 := rosetta_g_miss_num_map(ddx_rulv_rec.dnz_chr_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_rulv_rec.rgp_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_rulv_rec.priority);
    p6_a15 := ddx_rulv_rec.std_template_yn;
    p6_a16 := ddx_rulv_rec.comments;
    p6_a17 := ddx_rulv_rec.warn_yn;
    p6_a18 := ddx_rulv_rec.attribute_category;
    p6_a19 := ddx_rulv_rec.attribute1;
    p6_a20 := ddx_rulv_rec.attribute2;
    p6_a21 := ddx_rulv_rec.attribute3;
    p6_a22 := ddx_rulv_rec.attribute4;
    p6_a23 := ddx_rulv_rec.attribute5;
    p6_a24 := ddx_rulv_rec.attribute6;
    p6_a25 := ddx_rulv_rec.attribute7;
    p6_a26 := ddx_rulv_rec.attribute8;
    p6_a27 := ddx_rulv_rec.attribute9;
    p6_a28 := ddx_rulv_rec.attribute10;
    p6_a29 := ddx_rulv_rec.attribute11;
    p6_a30 := ddx_rulv_rec.attribute12;
    p6_a31 := ddx_rulv_rec.attribute13;
    p6_a32 := ddx_rulv_rec.attribute14;
    p6_a33 := ddx_rulv_rec.attribute15;
    p6_a34 := rosetta_g_miss_num_map(ddx_rulv_rec.created_by);
    p6_a35 := ddx_rulv_rec.creation_date;
    p6_a36 := rosetta_g_miss_num_map(ddx_rulv_rec.last_updated_by);
    p6_a37 := ddx_rulv_rec.last_update_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_rulv_rec.last_update_login);
    p6_a39 := ddx_rulv_rec.rule_information_category;
    p6_a40 := ddx_rulv_rec.rule_information1;
    p6_a41 := ddx_rulv_rec.rule_information2;
    p6_a42 := ddx_rulv_rec.rule_information3;
    p6_a43 := ddx_rulv_rec.rule_information4;
    p6_a44 := ddx_rulv_rec.rule_information5;
    p6_a45 := ddx_rulv_rec.rule_information6;
    p6_a46 := ddx_rulv_rec.rule_information7;
    p6_a47 := ddx_rulv_rec.rule_information8;
    p6_a48 := ddx_rulv_rec.rule_information9;
    p6_a49 := ddx_rulv_rec.rule_information10;
    p6_a50 := ddx_rulv_rec.rule_information11;
    p6_a51 := ddx_rulv_rec.rule_information12;
    p6_a52 := ddx_rulv_rec.rule_information13;
    p6_a53 := ddx_rulv_rec.rule_information14;
    p6_a54 := ddx_rulv_rec.rule_information15;
    p6_a55 := ddx_rulv_rec.template_yn;
    p6_a56 := ddx_rulv_rec.ans_set_jtot_object_code;
    p6_a57 := ddx_rulv_rec.ans_set_jtot_object_id1;
    p6_a58 := ddx_rulv_rec.ans_set_jtot_object_id2;
    p6_a59 := rosetta_g_miss_num_map(ddx_rulv_rec.display_sequence);
  end;

  procedure update_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_edit_mode  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  CHAR
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  NUMBER
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  DATE
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  DATE
    , p7_a38 out nocopy  NUMBER
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  CHAR := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_rule_pub.rulv_rec_type;
    ddx_rulv_rec okl_rule_pub.rulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rulv_rec.sfwt_flag := p5_a2;
    ddp_rulv_rec.object1_id1 := p5_a3;
    ddp_rulv_rec.object2_id1 := p5_a4;
    ddp_rulv_rec.object3_id1 := p5_a5;
    ddp_rulv_rec.object1_id2 := p5_a6;
    ddp_rulv_rec.object2_id2 := p5_a7;
    ddp_rulv_rec.object3_id2 := p5_a8;
    ddp_rulv_rec.jtot_object1_code := p5_a9;
    ddp_rulv_rec.jtot_object2_code := p5_a10;
    ddp_rulv_rec.jtot_object3_code := p5_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p5_a14);
    ddp_rulv_rec.std_template_yn := p5_a15;
    ddp_rulv_rec.comments := p5_a16;
    ddp_rulv_rec.warn_yn := p5_a17;
    ddp_rulv_rec.attribute_category := p5_a18;
    ddp_rulv_rec.attribute1 := p5_a19;
    ddp_rulv_rec.attribute2 := p5_a20;
    ddp_rulv_rec.attribute3 := p5_a21;
    ddp_rulv_rec.attribute4 := p5_a22;
    ddp_rulv_rec.attribute5 := p5_a23;
    ddp_rulv_rec.attribute6 := p5_a24;
    ddp_rulv_rec.attribute7 := p5_a25;
    ddp_rulv_rec.attribute8 := p5_a26;
    ddp_rulv_rec.attribute9 := p5_a27;
    ddp_rulv_rec.attribute10 := p5_a28;
    ddp_rulv_rec.attribute11 := p5_a29;
    ddp_rulv_rec.attribute12 := p5_a30;
    ddp_rulv_rec.attribute13 := p5_a31;
    ddp_rulv_rec.attribute14 := p5_a32;
    ddp_rulv_rec.attribute15 := p5_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_rulv_rec.rule_information_category := p5_a39;
    ddp_rulv_rec.rule_information1 := p5_a40;
    ddp_rulv_rec.rule_information2 := p5_a41;
    ddp_rulv_rec.rule_information3 := p5_a42;
    ddp_rulv_rec.rule_information4 := p5_a43;
    ddp_rulv_rec.rule_information5 := p5_a44;
    ddp_rulv_rec.rule_information6 := p5_a45;
    ddp_rulv_rec.rule_information7 := p5_a46;
    ddp_rulv_rec.rule_information8 := p5_a47;
    ddp_rulv_rec.rule_information9 := p5_a48;
    ddp_rulv_rec.rule_information10 := p5_a49;
    ddp_rulv_rec.rule_information11 := p5_a50;
    ddp_rulv_rec.rule_information12 := p5_a51;
    ddp_rulv_rec.rule_information13 := p5_a52;
    ddp_rulv_rec.rule_information14 := p5_a53;
    ddp_rulv_rec.rule_information15 := p5_a54;
    ddp_rulv_rec.template_yn := p5_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p5_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p5_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p5_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p5_a59);



    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.update_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_rec,
      p_edit_mode,
      ddx_rulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_rulv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_rulv_rec.object_version_number);
    p7_a2 := ddx_rulv_rec.sfwt_flag;
    p7_a3 := ddx_rulv_rec.object1_id1;
    p7_a4 := ddx_rulv_rec.object2_id1;
    p7_a5 := ddx_rulv_rec.object3_id1;
    p7_a6 := ddx_rulv_rec.object1_id2;
    p7_a7 := ddx_rulv_rec.object2_id2;
    p7_a8 := ddx_rulv_rec.object3_id2;
    p7_a9 := ddx_rulv_rec.jtot_object1_code;
    p7_a10 := ddx_rulv_rec.jtot_object2_code;
    p7_a11 := ddx_rulv_rec.jtot_object3_code;
    p7_a12 := rosetta_g_miss_num_map(ddx_rulv_rec.dnz_chr_id);
    p7_a13 := rosetta_g_miss_num_map(ddx_rulv_rec.rgp_id);
    p7_a14 := rosetta_g_miss_num_map(ddx_rulv_rec.priority);
    p7_a15 := ddx_rulv_rec.std_template_yn;
    p7_a16 := ddx_rulv_rec.comments;
    p7_a17 := ddx_rulv_rec.warn_yn;
    p7_a18 := ddx_rulv_rec.attribute_category;
    p7_a19 := ddx_rulv_rec.attribute1;
    p7_a20 := ddx_rulv_rec.attribute2;
    p7_a21 := ddx_rulv_rec.attribute3;
    p7_a22 := ddx_rulv_rec.attribute4;
    p7_a23 := ddx_rulv_rec.attribute5;
    p7_a24 := ddx_rulv_rec.attribute6;
    p7_a25 := ddx_rulv_rec.attribute7;
    p7_a26 := ddx_rulv_rec.attribute8;
    p7_a27 := ddx_rulv_rec.attribute9;
    p7_a28 := ddx_rulv_rec.attribute10;
    p7_a29 := ddx_rulv_rec.attribute11;
    p7_a30 := ddx_rulv_rec.attribute12;
    p7_a31 := ddx_rulv_rec.attribute13;
    p7_a32 := ddx_rulv_rec.attribute14;
    p7_a33 := ddx_rulv_rec.attribute15;
    p7_a34 := rosetta_g_miss_num_map(ddx_rulv_rec.created_by);
    p7_a35 := ddx_rulv_rec.creation_date;
    p7_a36 := rosetta_g_miss_num_map(ddx_rulv_rec.last_updated_by);
    p7_a37 := ddx_rulv_rec.last_update_date;
    p7_a38 := rosetta_g_miss_num_map(ddx_rulv_rec.last_update_login);
    p7_a39 := ddx_rulv_rec.rule_information_category;
    p7_a40 := ddx_rulv_rec.rule_information1;
    p7_a41 := ddx_rulv_rec.rule_information2;
    p7_a42 := ddx_rulv_rec.rule_information3;
    p7_a43 := ddx_rulv_rec.rule_information4;
    p7_a44 := ddx_rulv_rec.rule_information5;
    p7_a45 := ddx_rulv_rec.rule_information6;
    p7_a46 := ddx_rulv_rec.rule_information7;
    p7_a47 := ddx_rulv_rec.rule_information8;
    p7_a48 := ddx_rulv_rec.rule_information9;
    p7_a49 := ddx_rulv_rec.rule_information10;
    p7_a50 := ddx_rulv_rec.rule_information11;
    p7_a51 := ddx_rulv_rec.rule_information12;
    p7_a52 := ddx_rulv_rec.rule_information13;
    p7_a53 := ddx_rulv_rec.rule_information14;
    p7_a54 := ddx_rulv_rec.rule_information15;
    p7_a55 := ddx_rulv_rec.template_yn;
    p7_a56 := ddx_rulv_rec.ans_set_jtot_object_code;
    p7_a57 := ddx_rulv_rec.ans_set_jtot_object_id1;
    p7_a58 := ddx_rulv_rec.ans_set_jtot_object_id2;
    p7_a59 := rosetta_g_miss_num_map(ddx_rulv_rec.display_sequence);
  end;

  procedure update_rule(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_500
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
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddx_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rule_pub_w.rosetta_table_copy_in_p2(ddp_rulv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.update_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_tbl,
      ddx_rulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rule_pub_w.rosetta_table_copy_out_p2(ddx_rulv_tbl, p6_a0
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
      );
  end;

  procedure update_rule(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_500
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
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_NUMBER_TABLE
    , p_edit_mode  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a34 out nocopy JTF_NUMBER_TABLE
    , p7_a35 out nocopy JTF_DATE_TABLE
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_DATE_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddx_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rule_pub_w.rosetta_table_copy_in_p2(ddp_rulv_tbl, p5_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.update_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_tbl,
      p_edit_mode,
      ddx_rulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_rule_pub_w.rosetta_table_copy_out_p2(ddx_rulv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      );
  end;

  procedure validate_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  CHAR := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_rule_pub.rulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rulv_rec.sfwt_flag := p5_a2;
    ddp_rulv_rec.object1_id1 := p5_a3;
    ddp_rulv_rec.object2_id1 := p5_a4;
    ddp_rulv_rec.object3_id1 := p5_a5;
    ddp_rulv_rec.object1_id2 := p5_a6;
    ddp_rulv_rec.object2_id2 := p5_a7;
    ddp_rulv_rec.object3_id2 := p5_a8;
    ddp_rulv_rec.jtot_object1_code := p5_a9;
    ddp_rulv_rec.jtot_object2_code := p5_a10;
    ddp_rulv_rec.jtot_object3_code := p5_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p5_a14);
    ddp_rulv_rec.std_template_yn := p5_a15;
    ddp_rulv_rec.comments := p5_a16;
    ddp_rulv_rec.warn_yn := p5_a17;
    ddp_rulv_rec.attribute_category := p5_a18;
    ddp_rulv_rec.attribute1 := p5_a19;
    ddp_rulv_rec.attribute2 := p5_a20;
    ddp_rulv_rec.attribute3 := p5_a21;
    ddp_rulv_rec.attribute4 := p5_a22;
    ddp_rulv_rec.attribute5 := p5_a23;
    ddp_rulv_rec.attribute6 := p5_a24;
    ddp_rulv_rec.attribute7 := p5_a25;
    ddp_rulv_rec.attribute8 := p5_a26;
    ddp_rulv_rec.attribute9 := p5_a27;
    ddp_rulv_rec.attribute10 := p5_a28;
    ddp_rulv_rec.attribute11 := p5_a29;
    ddp_rulv_rec.attribute12 := p5_a30;
    ddp_rulv_rec.attribute13 := p5_a31;
    ddp_rulv_rec.attribute14 := p5_a32;
    ddp_rulv_rec.attribute15 := p5_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_rulv_rec.rule_information_category := p5_a39;
    ddp_rulv_rec.rule_information1 := p5_a40;
    ddp_rulv_rec.rule_information2 := p5_a41;
    ddp_rulv_rec.rule_information3 := p5_a42;
    ddp_rulv_rec.rule_information4 := p5_a43;
    ddp_rulv_rec.rule_information5 := p5_a44;
    ddp_rulv_rec.rule_information6 := p5_a45;
    ddp_rulv_rec.rule_information7 := p5_a46;
    ddp_rulv_rec.rule_information8 := p5_a47;
    ddp_rulv_rec.rule_information9 := p5_a48;
    ddp_rulv_rec.rule_information10 := p5_a49;
    ddp_rulv_rec.rule_information11 := p5_a50;
    ddp_rulv_rec.rule_information12 := p5_a51;
    ddp_rulv_rec.rule_information13 := p5_a52;
    ddp_rulv_rec.rule_information14 := p5_a53;
    ddp_rulv_rec.rule_information15 := p5_a54;
    ddp_rulv_rec.template_yn := p5_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p5_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p5_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p5_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p5_a59);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.validate_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rule(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_500
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
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_NUMBER_TABLE
  )

  as
    ddp_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rule_pub_w.rosetta_table_copy_in_p2(ddp_rulv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.validate_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  CHAR := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_rule_pub.rulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rulv_rec.sfwt_flag := p5_a2;
    ddp_rulv_rec.object1_id1 := p5_a3;
    ddp_rulv_rec.object2_id1 := p5_a4;
    ddp_rulv_rec.object3_id1 := p5_a5;
    ddp_rulv_rec.object1_id2 := p5_a6;
    ddp_rulv_rec.object2_id2 := p5_a7;
    ddp_rulv_rec.object3_id2 := p5_a8;
    ddp_rulv_rec.jtot_object1_code := p5_a9;
    ddp_rulv_rec.jtot_object2_code := p5_a10;
    ddp_rulv_rec.jtot_object3_code := p5_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p5_a14);
    ddp_rulv_rec.std_template_yn := p5_a15;
    ddp_rulv_rec.comments := p5_a16;
    ddp_rulv_rec.warn_yn := p5_a17;
    ddp_rulv_rec.attribute_category := p5_a18;
    ddp_rulv_rec.attribute1 := p5_a19;
    ddp_rulv_rec.attribute2 := p5_a20;
    ddp_rulv_rec.attribute3 := p5_a21;
    ddp_rulv_rec.attribute4 := p5_a22;
    ddp_rulv_rec.attribute5 := p5_a23;
    ddp_rulv_rec.attribute6 := p5_a24;
    ddp_rulv_rec.attribute7 := p5_a25;
    ddp_rulv_rec.attribute8 := p5_a26;
    ddp_rulv_rec.attribute9 := p5_a27;
    ddp_rulv_rec.attribute10 := p5_a28;
    ddp_rulv_rec.attribute11 := p5_a29;
    ddp_rulv_rec.attribute12 := p5_a30;
    ddp_rulv_rec.attribute13 := p5_a31;
    ddp_rulv_rec.attribute14 := p5_a32;
    ddp_rulv_rec.attribute15 := p5_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_rulv_rec.rule_information_category := p5_a39;
    ddp_rulv_rec.rule_information1 := p5_a40;
    ddp_rulv_rec.rule_information2 := p5_a41;
    ddp_rulv_rec.rule_information3 := p5_a42;
    ddp_rulv_rec.rule_information4 := p5_a43;
    ddp_rulv_rec.rule_information5 := p5_a44;
    ddp_rulv_rec.rule_information6 := p5_a45;
    ddp_rulv_rec.rule_information7 := p5_a46;
    ddp_rulv_rec.rule_information8 := p5_a47;
    ddp_rulv_rec.rule_information9 := p5_a48;
    ddp_rulv_rec.rule_information10 := p5_a49;
    ddp_rulv_rec.rule_information11 := p5_a50;
    ddp_rulv_rec.rule_information12 := p5_a51;
    ddp_rulv_rec.rule_information13 := p5_a52;
    ddp_rulv_rec.rule_information14 := p5_a53;
    ddp_rulv_rec.rule_information15 := p5_a54;
    ddp_rulv_rec.template_yn := p5_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p5_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p5_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p5_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p5_a59);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.delete_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_rule(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_500
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
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_NUMBER_TABLE
  )

  as
    ddp_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rule_pub_w.rosetta_table_copy_in_p2(ddp_rulv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.delete_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  CHAR := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  DATE := fnd_api.g_miss_date
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
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
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_rule_pub.rulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rulv_rec.sfwt_flag := p5_a2;
    ddp_rulv_rec.object1_id1 := p5_a3;
    ddp_rulv_rec.object2_id1 := p5_a4;
    ddp_rulv_rec.object3_id1 := p5_a5;
    ddp_rulv_rec.object1_id2 := p5_a6;
    ddp_rulv_rec.object2_id2 := p5_a7;
    ddp_rulv_rec.object3_id2 := p5_a8;
    ddp_rulv_rec.jtot_object1_code := p5_a9;
    ddp_rulv_rec.jtot_object2_code := p5_a10;
    ddp_rulv_rec.jtot_object3_code := p5_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p5_a14);
    ddp_rulv_rec.std_template_yn := p5_a15;
    ddp_rulv_rec.comments := p5_a16;
    ddp_rulv_rec.warn_yn := p5_a17;
    ddp_rulv_rec.attribute_category := p5_a18;
    ddp_rulv_rec.attribute1 := p5_a19;
    ddp_rulv_rec.attribute2 := p5_a20;
    ddp_rulv_rec.attribute3 := p5_a21;
    ddp_rulv_rec.attribute4 := p5_a22;
    ddp_rulv_rec.attribute5 := p5_a23;
    ddp_rulv_rec.attribute6 := p5_a24;
    ddp_rulv_rec.attribute7 := p5_a25;
    ddp_rulv_rec.attribute8 := p5_a26;
    ddp_rulv_rec.attribute9 := p5_a27;
    ddp_rulv_rec.attribute10 := p5_a28;
    ddp_rulv_rec.attribute11 := p5_a29;
    ddp_rulv_rec.attribute12 := p5_a30;
    ddp_rulv_rec.attribute13 := p5_a31;
    ddp_rulv_rec.attribute14 := p5_a32;
    ddp_rulv_rec.attribute15 := p5_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p5_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a38);
    ddp_rulv_rec.rule_information_category := p5_a39;
    ddp_rulv_rec.rule_information1 := p5_a40;
    ddp_rulv_rec.rule_information2 := p5_a41;
    ddp_rulv_rec.rule_information3 := p5_a42;
    ddp_rulv_rec.rule_information4 := p5_a43;
    ddp_rulv_rec.rule_information5 := p5_a44;
    ddp_rulv_rec.rule_information6 := p5_a45;
    ddp_rulv_rec.rule_information7 := p5_a46;
    ddp_rulv_rec.rule_information8 := p5_a47;
    ddp_rulv_rec.rule_information9 := p5_a48;
    ddp_rulv_rec.rule_information10 := p5_a49;
    ddp_rulv_rec.rule_information11 := p5_a50;
    ddp_rulv_rec.rule_information12 := p5_a51;
    ddp_rulv_rec.rule_information13 := p5_a52;
    ddp_rulv_rec.rule_information14 := p5_a53;
    ddp_rulv_rec.rule_information15 := p5_a54;
    ddp_rulv_rec.template_yn := p5_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p5_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p5_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p5_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p5_a59);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.lock_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_rule(p_api_version  NUMBER
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
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_500
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
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
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
    , p5_a54 JTF_VARCHAR2_TABLE_500
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_NUMBER_TABLE
  )

  as
    ddp_rulv_tbl okl_rule_pub.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rule_pub_w.rosetta_table_copy_in_p2(ddp_rulv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.lock_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_rule_group(p_api_version  NUMBER
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
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
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
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
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
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_rule_pub.rgpv_rec_type;
    ddx_rgpv_rec okl_rule_pub.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.create_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rgpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rgpv_rec.object_version_number);
    p6_a2 := ddx_rgpv_rec.sfwt_flag;
    p6_a3 := ddx_rgpv_rec.rgd_code;
    p6_a4 := ddx_rgpv_rec.sat_code;
    p6_a5 := ddx_rgpv_rec.rgp_type;
    p6_a6 := rosetta_g_miss_num_map(ddx_rgpv_rec.cle_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_rgpv_rec.chr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_rgpv_rec.dnz_chr_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_rgpv_rec.parent_rgp_id);
    p6_a10 := ddx_rgpv_rec.comments;
    p6_a11 := ddx_rgpv_rec.attribute_category;
    p6_a12 := ddx_rgpv_rec.attribute1;
    p6_a13 := ddx_rgpv_rec.attribute2;
    p6_a14 := ddx_rgpv_rec.attribute3;
    p6_a15 := ddx_rgpv_rec.attribute4;
    p6_a16 := ddx_rgpv_rec.attribute5;
    p6_a17 := ddx_rgpv_rec.attribute6;
    p6_a18 := ddx_rgpv_rec.attribute7;
    p6_a19 := ddx_rgpv_rec.attribute8;
    p6_a20 := ddx_rgpv_rec.attribute9;
    p6_a21 := ddx_rgpv_rec.attribute10;
    p6_a22 := ddx_rgpv_rec.attribute11;
    p6_a23 := ddx_rgpv_rec.attribute12;
    p6_a24 := ddx_rgpv_rec.attribute13;
    p6_a25 := ddx_rgpv_rec.attribute14;
    p6_a26 := ddx_rgpv_rec.attribute15;
    p6_a27 := rosetta_g_miss_num_map(ddx_rgpv_rec.created_by);
    p6_a28 := ddx_rgpv_rec.creation_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_rgpv_rec.last_updated_by);
    p6_a30 := ddx_rgpv_rec.last_update_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_rgpv_rec.last_update_login);
  end;

  procedure create_rule_group(p_api_version  NUMBER
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
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
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
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rgpv_tbl okl_rule_pub.rgpv_tbl_type;
    ddx_rgpv_tbl okl_rule_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p13(ddp_rgpv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.create_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_tbl,
      ddx_rgpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p13(ddx_rgpv_tbl, p6_a0
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
      );
  end;

  procedure update_rule_group(p_api_version  NUMBER
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
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
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
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
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
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_rule_pub.rgpv_rec_type;
    ddx_rgpv_rec okl_rule_pub.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.update_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rgpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rgpv_rec.object_version_number);
    p6_a2 := ddx_rgpv_rec.sfwt_flag;
    p6_a3 := ddx_rgpv_rec.rgd_code;
    p6_a4 := ddx_rgpv_rec.sat_code;
    p6_a5 := ddx_rgpv_rec.rgp_type;
    p6_a6 := rosetta_g_miss_num_map(ddx_rgpv_rec.cle_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_rgpv_rec.chr_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_rgpv_rec.dnz_chr_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_rgpv_rec.parent_rgp_id);
    p6_a10 := ddx_rgpv_rec.comments;
    p6_a11 := ddx_rgpv_rec.attribute_category;
    p6_a12 := ddx_rgpv_rec.attribute1;
    p6_a13 := ddx_rgpv_rec.attribute2;
    p6_a14 := ddx_rgpv_rec.attribute3;
    p6_a15 := ddx_rgpv_rec.attribute4;
    p6_a16 := ddx_rgpv_rec.attribute5;
    p6_a17 := ddx_rgpv_rec.attribute6;
    p6_a18 := ddx_rgpv_rec.attribute7;
    p6_a19 := ddx_rgpv_rec.attribute8;
    p6_a20 := ddx_rgpv_rec.attribute9;
    p6_a21 := ddx_rgpv_rec.attribute10;
    p6_a22 := ddx_rgpv_rec.attribute11;
    p6_a23 := ddx_rgpv_rec.attribute12;
    p6_a24 := ddx_rgpv_rec.attribute13;
    p6_a25 := ddx_rgpv_rec.attribute14;
    p6_a26 := ddx_rgpv_rec.attribute15;
    p6_a27 := rosetta_g_miss_num_map(ddx_rgpv_rec.created_by);
    p6_a28 := ddx_rgpv_rec.creation_date;
    p6_a29 := rosetta_g_miss_num_map(ddx_rgpv_rec.last_updated_by);
    p6_a30 := ddx_rgpv_rec.last_update_date;
    p6_a31 := rosetta_g_miss_num_map(ddx_rgpv_rec.last_update_login);
  end;

  procedure update_rule_group(p_api_version  NUMBER
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
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
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
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_DATE_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rgpv_tbl okl_rule_pub.rgpv_tbl_type;
    ddx_rgpv_tbl okl_rule_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p13(ddp_rgpv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.update_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_tbl,
      ddx_rgpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p13(ddx_rgpv_tbl, p6_a0
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
      );
  end;

  procedure delete_rule_group(p_api_version  NUMBER
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
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_rule_pub.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.delete_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_rule_group(p_api_version  NUMBER
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
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
  )

  as
    ddp_rgpv_tbl okl_rule_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p13(ddp_rgpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.delete_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_rule_group(p_api_version  NUMBER
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
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_rule_pub.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.lock_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_rule_group(p_api_version  NUMBER
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
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
  )

  as
    ddp_rgpv_tbl okl_rule_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p13(ddp_rgpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.lock_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rule_group(p_api_version  NUMBER
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
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  DATE := fnd_api.g_miss_date
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  DATE := fnd_api.g_miss_date
    , p5_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_rule_pub.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p5_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p5_a9);
    ddp_rgpv_rec.comments := p5_a10;
    ddp_rgpv_rec.attribute_category := p5_a11;
    ddp_rgpv_rec.attribute1 := p5_a12;
    ddp_rgpv_rec.attribute2 := p5_a13;
    ddp_rgpv_rec.attribute3 := p5_a14;
    ddp_rgpv_rec.attribute4 := p5_a15;
    ddp_rgpv_rec.attribute5 := p5_a16;
    ddp_rgpv_rec.attribute6 := p5_a17;
    ddp_rgpv_rec.attribute7 := p5_a18;
    ddp_rgpv_rec.attribute8 := p5_a19;
    ddp_rgpv_rec.attribute9 := p5_a20;
    ddp_rgpv_rec.attribute10 := p5_a21;
    ddp_rgpv_rec.attribute11 := p5_a22;
    ddp_rgpv_rec.attribute12 := p5_a23;
    ddp_rgpv_rec.attribute13 := p5_a24;
    ddp_rgpv_rec.attribute14 := p5_a25;
    ddp_rgpv_rec.attribute15 := p5_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p5_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a31);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.validate_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rule_group(p_api_version  NUMBER
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
    , p5_a10 JTF_VARCHAR2_TABLE_2000
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_DATE_TABLE
    , p5_a31 JTF_NUMBER_TABLE
  )

  as
    ddp_rgpv_tbl okl_rule_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p13(ddp_rgpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.validate_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_rule_pub.rmpv_rec_type;
    ddx_rmpv_rec okl_rule_pub.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.create_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec,
      ddx_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rmpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rmpv_rec.rgp_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_rmpv_rec.rrd_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_rmpv_rec.cpl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_rmpv_rec.dnz_chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_rmpv_rec.object_version_number);
    p6_a6 := rosetta_g_miss_num_map(ddx_rmpv_rec.created_by);
    p6_a7 := ddx_rmpv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_rmpv_rec.last_updated_by);
    p6_a9 := ddx_rmpv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_rmpv_rec.last_update_login);
  end;

  procedure create_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rmpv_tbl okl_rule_pub.rmpv_tbl_type;
    ddx_rmpv_tbl okl_rule_pub.rmpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p15(ddp_rmpv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.create_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_tbl,
      ddx_rmpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p15(ddx_rmpv_tbl, p6_a0
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
      );
  end;

  procedure update_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_rule_pub.rmpv_rec_type;
    ddx_rmpv_rec okl_rule_pub.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.update_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec,
      ddx_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rmpv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rmpv_rec.rgp_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_rmpv_rec.rrd_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_rmpv_rec.cpl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_rmpv_rec.dnz_chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_rmpv_rec.object_version_number);
    p6_a6 := rosetta_g_miss_num_map(ddx_rmpv_rec.created_by);
    p6_a7 := ddx_rmpv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_rmpv_rec.last_updated_by);
    p6_a9 := ddx_rmpv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_rmpv_rec.last_update_login);
  end;

  procedure update_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rmpv_tbl okl_rule_pub.rmpv_tbl_type;
    ddx_rmpv_tbl okl_rule_pub.rmpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p15(ddp_rmpv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.update_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_tbl,
      ddx_rmpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_out_p15(ddx_rmpv_tbl, p6_a0
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
      );
  end;

  procedure delete_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_rule_pub.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.delete_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_rmpv_tbl okl_rule_pub.rmpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p15(ddp_rmpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.delete_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_rule_pub.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.lock_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_rmpv_tbl okl_rule_pub.rmpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p15(ddp_rmpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.lock_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_rmpv_rec okl_rule_pub.rmpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rmpv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rmpv_rec.rgp_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rmpv_rec.rrd_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rmpv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rmpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_rmpv_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_rmpv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rmpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rmpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rmpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rmpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.validate_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rg_mode_pty_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_rmpv_tbl okl_rule_pub.rmpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_pvt_w.rosetta_table_copy_in_p15(ddp_rmpv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rule_pub.validate_rg_mode_pty_role(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rmpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_rule_pub_w;

/
