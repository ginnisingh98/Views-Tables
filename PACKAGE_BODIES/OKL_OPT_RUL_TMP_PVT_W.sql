--------------------------------------------------------
--  DDL for Package Body OKL_OPT_RUL_TMP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPT_RUL_TMP_PVT_W" as
  /* $Header: OKLIRTMB.pls 120.2 2005/12/08 17:47:16 stmathew noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_ovd_id  NUMBER
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  NUMBER
    , p7_a15 out nocopy  NUMBER
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
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  DATE
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  DATE
    , p7_a39 out nocopy  NUMBER
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
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  NUMBER
    , p6_a0  VARCHAR2 := fnd_api.g_miss_char
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  DATE := fnd_api.g_miss_date
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_rgrv_rec okl_opt_rul_tmp_pvt.rgrv_rec_type;
    ddx_rgrv_rec okl_opt_rul_tmp_pvt.rgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_rgrv_rec.rgd_code := p6_a0;
    ddp_rgrv_rec.rule_id := rosetta_g_miss_num_map(p6_a1);
    ddp_rgrv_rec.object_version_number := rosetta_g_miss_num_map(p6_a2);
    ddp_rgrv_rec.sfwt_flag := p6_a3;
    ddp_rgrv_rec.object1_id1 := p6_a4;
    ddp_rgrv_rec.object2_id1 := p6_a5;
    ddp_rgrv_rec.object3_id1 := p6_a6;
    ddp_rgrv_rec.object1_id2 := p6_a7;
    ddp_rgrv_rec.object2_id2 := p6_a8;
    ddp_rgrv_rec.object3_id2 := p6_a9;
    ddp_rgrv_rec.jtot_object1_code := p6_a10;
    ddp_rgrv_rec.jtot_object2_code := p6_a11;
    ddp_rgrv_rec.jtot_object3_code := p6_a12;
    ddp_rgrv_rec.dnz_chr_id := rosetta_g_miss_num_map(p6_a13);
    ddp_rgrv_rec.rgp_id := rosetta_g_miss_num_map(p6_a14);
    ddp_rgrv_rec.priority := rosetta_g_miss_num_map(p6_a15);
    ddp_rgrv_rec.std_template_yn := p6_a16;
    ddp_rgrv_rec.comments := p6_a17;
    ddp_rgrv_rec.warn_yn := p6_a18;
    ddp_rgrv_rec.attribute_category := p6_a19;
    ddp_rgrv_rec.attribute1 := p6_a20;
    ddp_rgrv_rec.attribute2 := p6_a21;
    ddp_rgrv_rec.attribute3 := p6_a22;
    ddp_rgrv_rec.attribute4 := p6_a23;
    ddp_rgrv_rec.attribute5 := p6_a24;
    ddp_rgrv_rec.attribute6 := p6_a25;
    ddp_rgrv_rec.attribute7 := p6_a26;
    ddp_rgrv_rec.attribute8 := p6_a27;
    ddp_rgrv_rec.attribute9 := p6_a28;
    ddp_rgrv_rec.attribute10 := p6_a29;
    ddp_rgrv_rec.attribute11 := p6_a30;
    ddp_rgrv_rec.attribute12 := p6_a31;
    ddp_rgrv_rec.attribute13 := p6_a32;
    ddp_rgrv_rec.attribute14 := p6_a33;
    ddp_rgrv_rec.attribute15 := p6_a34;
    ddp_rgrv_rec.created_by := rosetta_g_miss_num_map(p6_a35);
    ddp_rgrv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a36);
    ddp_rgrv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a37);
    ddp_rgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a38);
    ddp_rgrv_rec.last_update_login := rosetta_g_miss_num_map(p6_a39);
    ddp_rgrv_rec.rule_information_category := p6_a40;
    ddp_rgrv_rec.rule_information1 := p6_a41;
    ddp_rgrv_rec.rule_information2 := p6_a42;
    ddp_rgrv_rec.rule_information3 := p6_a43;
    ddp_rgrv_rec.rule_information4 := p6_a44;
    ddp_rgrv_rec.rule_information5 := p6_a45;
    ddp_rgrv_rec.rule_information6 := p6_a46;
    ddp_rgrv_rec.rule_information7 := p6_a47;
    ddp_rgrv_rec.rule_information8 := p6_a48;
    ddp_rgrv_rec.rule_information9 := p6_a49;
    ddp_rgrv_rec.rule_information10 := p6_a50;
    ddp_rgrv_rec.rule_information11 := p6_a51;
    ddp_rgrv_rec.rule_information12 := p6_a52;
    ddp_rgrv_rec.rule_information13 := p6_a53;
    ddp_rgrv_rec.rule_information14 := p6_a54;
    ddp_rgrv_rec.rule_information15 := p6_a55;
    ddp_rgrv_rec.template_yn := p6_a56;
    ddp_rgrv_rec.ans_set_jtot_object_code := p6_a57;
    ddp_rgrv_rec.ans_set_jtot_object_id1 := p6_a58;
    ddp_rgrv_rec.ans_set_jtot_object_id2 := p6_a59;
    ddp_rgrv_rec.display_sequence := rosetta_g_miss_num_map(p6_a60);


    -- here's the delegated call to the old PL/SQL routine
    okl_opt_rul_tmp_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_ovd_id,
      ddp_rgrv_rec,
      ddx_rgrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_rgrv_rec.rgd_code;
    p7_a1 := rosetta_g_miss_num_map(ddx_rgrv_rec.rule_id);
    p7_a2 := rosetta_g_miss_num_map(ddx_rgrv_rec.object_version_number);
    p7_a3 := ddx_rgrv_rec.sfwt_flag;
    p7_a4 := ddx_rgrv_rec.object1_id1;
    p7_a5 := ddx_rgrv_rec.object2_id1;
    p7_a6 := ddx_rgrv_rec.object3_id1;
    p7_a7 := ddx_rgrv_rec.object1_id2;
    p7_a8 := ddx_rgrv_rec.object2_id2;
    p7_a9 := ddx_rgrv_rec.object3_id2;
    p7_a10 := ddx_rgrv_rec.jtot_object1_code;
    p7_a11 := ddx_rgrv_rec.jtot_object2_code;
    p7_a12 := ddx_rgrv_rec.jtot_object3_code;
    p7_a13 := rosetta_g_miss_num_map(ddx_rgrv_rec.dnz_chr_id);
    p7_a14 := rosetta_g_miss_num_map(ddx_rgrv_rec.rgp_id);
    p7_a15 := rosetta_g_miss_num_map(ddx_rgrv_rec.priority);
    p7_a16 := ddx_rgrv_rec.std_template_yn;
    p7_a17 := ddx_rgrv_rec.comments;
    p7_a18 := ddx_rgrv_rec.warn_yn;
    p7_a19 := ddx_rgrv_rec.attribute_category;
    p7_a20 := ddx_rgrv_rec.attribute1;
    p7_a21 := ddx_rgrv_rec.attribute2;
    p7_a22 := ddx_rgrv_rec.attribute3;
    p7_a23 := ddx_rgrv_rec.attribute4;
    p7_a24 := ddx_rgrv_rec.attribute5;
    p7_a25 := ddx_rgrv_rec.attribute6;
    p7_a26 := ddx_rgrv_rec.attribute7;
    p7_a27 := ddx_rgrv_rec.attribute8;
    p7_a28 := ddx_rgrv_rec.attribute9;
    p7_a29 := ddx_rgrv_rec.attribute10;
    p7_a30 := ddx_rgrv_rec.attribute11;
    p7_a31 := ddx_rgrv_rec.attribute12;
    p7_a32 := ddx_rgrv_rec.attribute13;
    p7_a33 := ddx_rgrv_rec.attribute14;
    p7_a34 := ddx_rgrv_rec.attribute15;
    p7_a35 := rosetta_g_miss_num_map(ddx_rgrv_rec.created_by);
    p7_a36 := ddx_rgrv_rec.creation_date;
    p7_a37 := rosetta_g_miss_num_map(ddx_rgrv_rec.last_updated_by);
    p7_a38 := ddx_rgrv_rec.last_update_date;
    p7_a39 := rosetta_g_miss_num_map(ddx_rgrv_rec.last_update_login);
    p7_a40 := ddx_rgrv_rec.rule_information_category;
    p7_a41 := ddx_rgrv_rec.rule_information1;
    p7_a42 := ddx_rgrv_rec.rule_information2;
    p7_a43 := ddx_rgrv_rec.rule_information3;
    p7_a44 := ddx_rgrv_rec.rule_information4;
    p7_a45 := ddx_rgrv_rec.rule_information5;
    p7_a46 := ddx_rgrv_rec.rule_information6;
    p7_a47 := ddx_rgrv_rec.rule_information7;
    p7_a48 := ddx_rgrv_rec.rule_information8;
    p7_a49 := ddx_rgrv_rec.rule_information9;
    p7_a50 := ddx_rgrv_rec.rule_information10;
    p7_a51 := ddx_rgrv_rec.rule_information11;
    p7_a52 := ddx_rgrv_rec.rule_information12;
    p7_a53 := ddx_rgrv_rec.rule_information13;
    p7_a54 := ddx_rgrv_rec.rule_information14;
    p7_a55 := ddx_rgrv_rec.rule_information15;
    p7_a56 := ddx_rgrv_rec.template_yn;
    p7_a57 := ddx_rgrv_rec.ans_set_jtot_object_code;
    p7_a58 := ddx_rgrv_rec.ans_set_jtot_object_id1;
    p7_a59 := ddx_rgrv_rec.ans_set_jtot_object_id2;
    p7_a60 := rosetta_g_miss_num_map(ddx_rgrv_rec.display_sequence);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_ovd_id  NUMBER
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
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_NUMBER_TABLE
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p7_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a35 out nocopy JTF_NUMBER_TABLE
    , p7_a36 out nocopy JTF_DATE_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_DATE_TABLE
    , p7_a39 out nocopy JTF_NUMBER_TABLE
    , p7_a40 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a60 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rgrv_tbl okl_opt_rul_tmp_pvt.rgrv_tbl_type;
    ddx_rgrv_tbl okl_opt_rul_tmp_pvt.rgrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_in_p2(ddp_rgrv_tbl, p6_a0
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
    okl_opt_rul_tmp_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_ovd_id,
      ddp_rgrv_tbl,
      ddx_rgrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_out_p2(ddx_rgrv_tbl, p7_a0
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
      , p7_a60
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
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
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
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
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_rgrv_rec okl_opt_rul_tmp_pvt.rgrv_rec_type;
    ddx_rgrv_rec okl_opt_rul_tmp_pvt.rgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgrv_rec.rgd_code := p5_a0;
    ddp_rgrv_rec.rule_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rgrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_rgrv_rec.sfwt_flag := p5_a3;
    ddp_rgrv_rec.object1_id1 := p5_a4;
    ddp_rgrv_rec.object2_id1 := p5_a5;
    ddp_rgrv_rec.object3_id1 := p5_a6;
    ddp_rgrv_rec.object1_id2 := p5_a7;
    ddp_rgrv_rec.object2_id2 := p5_a8;
    ddp_rgrv_rec.object3_id2 := p5_a9;
    ddp_rgrv_rec.jtot_object1_code := p5_a10;
    ddp_rgrv_rec.jtot_object2_code := p5_a11;
    ddp_rgrv_rec.jtot_object3_code := p5_a12;
    ddp_rgrv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rgrv_rec.rgp_id := rosetta_g_miss_num_map(p5_a14);
    ddp_rgrv_rec.priority := rosetta_g_miss_num_map(p5_a15);
    ddp_rgrv_rec.std_template_yn := p5_a16;
    ddp_rgrv_rec.comments := p5_a17;
    ddp_rgrv_rec.warn_yn := p5_a18;
    ddp_rgrv_rec.attribute_category := p5_a19;
    ddp_rgrv_rec.attribute1 := p5_a20;
    ddp_rgrv_rec.attribute2 := p5_a21;
    ddp_rgrv_rec.attribute3 := p5_a22;
    ddp_rgrv_rec.attribute4 := p5_a23;
    ddp_rgrv_rec.attribute5 := p5_a24;
    ddp_rgrv_rec.attribute6 := p5_a25;
    ddp_rgrv_rec.attribute7 := p5_a26;
    ddp_rgrv_rec.attribute8 := p5_a27;
    ddp_rgrv_rec.attribute9 := p5_a28;
    ddp_rgrv_rec.attribute10 := p5_a29;
    ddp_rgrv_rec.attribute11 := p5_a30;
    ddp_rgrv_rec.attribute12 := p5_a31;
    ddp_rgrv_rec.attribute13 := p5_a32;
    ddp_rgrv_rec.attribute14 := p5_a33;
    ddp_rgrv_rec.attribute15 := p5_a34;
    ddp_rgrv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_rgrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_rgrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_rgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_rgrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);
    ddp_rgrv_rec.rule_information_category := p5_a40;
    ddp_rgrv_rec.rule_information1 := p5_a41;
    ddp_rgrv_rec.rule_information2 := p5_a42;
    ddp_rgrv_rec.rule_information3 := p5_a43;
    ddp_rgrv_rec.rule_information4 := p5_a44;
    ddp_rgrv_rec.rule_information5 := p5_a45;
    ddp_rgrv_rec.rule_information6 := p5_a46;
    ddp_rgrv_rec.rule_information7 := p5_a47;
    ddp_rgrv_rec.rule_information8 := p5_a48;
    ddp_rgrv_rec.rule_information9 := p5_a49;
    ddp_rgrv_rec.rule_information10 := p5_a50;
    ddp_rgrv_rec.rule_information11 := p5_a51;
    ddp_rgrv_rec.rule_information12 := p5_a52;
    ddp_rgrv_rec.rule_information13 := p5_a53;
    ddp_rgrv_rec.rule_information14 := p5_a54;
    ddp_rgrv_rec.rule_information15 := p5_a55;
    ddp_rgrv_rec.template_yn := p5_a56;
    ddp_rgrv_rec.ans_set_jtot_object_code := p5_a57;
    ddp_rgrv_rec.ans_set_jtot_object_id1 := p5_a58;
    ddp_rgrv_rec.ans_set_jtot_object_id2 := p5_a59;
    ddp_rgrv_rec.display_sequence := rosetta_g_miss_num_map(p5_a60);


    -- here's the delegated call to the old PL/SQL routine
    okl_opt_rul_tmp_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgrv_rec,
      ddx_rgrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgrv_rec.rgd_code;
    p6_a1 := rosetta_g_miss_num_map(ddx_rgrv_rec.rule_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_rgrv_rec.object_version_number);
    p6_a3 := ddx_rgrv_rec.sfwt_flag;
    p6_a4 := ddx_rgrv_rec.object1_id1;
    p6_a5 := ddx_rgrv_rec.object2_id1;
    p6_a6 := ddx_rgrv_rec.object3_id1;
    p6_a7 := ddx_rgrv_rec.object1_id2;
    p6_a8 := ddx_rgrv_rec.object2_id2;
    p6_a9 := ddx_rgrv_rec.object3_id2;
    p6_a10 := ddx_rgrv_rec.jtot_object1_code;
    p6_a11 := ddx_rgrv_rec.jtot_object2_code;
    p6_a12 := ddx_rgrv_rec.jtot_object3_code;
    p6_a13 := rosetta_g_miss_num_map(ddx_rgrv_rec.dnz_chr_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_rgrv_rec.rgp_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_rgrv_rec.priority);
    p6_a16 := ddx_rgrv_rec.std_template_yn;
    p6_a17 := ddx_rgrv_rec.comments;
    p6_a18 := ddx_rgrv_rec.warn_yn;
    p6_a19 := ddx_rgrv_rec.attribute_category;
    p6_a20 := ddx_rgrv_rec.attribute1;
    p6_a21 := ddx_rgrv_rec.attribute2;
    p6_a22 := ddx_rgrv_rec.attribute3;
    p6_a23 := ddx_rgrv_rec.attribute4;
    p6_a24 := ddx_rgrv_rec.attribute5;
    p6_a25 := ddx_rgrv_rec.attribute6;
    p6_a26 := ddx_rgrv_rec.attribute7;
    p6_a27 := ddx_rgrv_rec.attribute8;
    p6_a28 := ddx_rgrv_rec.attribute9;
    p6_a29 := ddx_rgrv_rec.attribute10;
    p6_a30 := ddx_rgrv_rec.attribute11;
    p6_a31 := ddx_rgrv_rec.attribute12;
    p6_a32 := ddx_rgrv_rec.attribute13;
    p6_a33 := ddx_rgrv_rec.attribute14;
    p6_a34 := ddx_rgrv_rec.attribute15;
    p6_a35 := rosetta_g_miss_num_map(ddx_rgrv_rec.created_by);
    p6_a36 := ddx_rgrv_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_rgrv_rec.last_updated_by);
    p6_a38 := ddx_rgrv_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_rgrv_rec.last_update_login);
    p6_a40 := ddx_rgrv_rec.rule_information_category;
    p6_a41 := ddx_rgrv_rec.rule_information1;
    p6_a42 := ddx_rgrv_rec.rule_information2;
    p6_a43 := ddx_rgrv_rec.rule_information3;
    p6_a44 := ddx_rgrv_rec.rule_information4;
    p6_a45 := ddx_rgrv_rec.rule_information5;
    p6_a46 := ddx_rgrv_rec.rule_information6;
    p6_a47 := ddx_rgrv_rec.rule_information7;
    p6_a48 := ddx_rgrv_rec.rule_information8;
    p6_a49 := ddx_rgrv_rec.rule_information9;
    p6_a50 := ddx_rgrv_rec.rule_information10;
    p6_a51 := ddx_rgrv_rec.rule_information11;
    p6_a52 := ddx_rgrv_rec.rule_information12;
    p6_a53 := ddx_rgrv_rec.rule_information13;
    p6_a54 := ddx_rgrv_rec.rule_information14;
    p6_a55 := ddx_rgrv_rec.rule_information15;
    p6_a56 := ddx_rgrv_rec.template_yn;
    p6_a57 := ddx_rgrv_rec.ans_set_jtot_object_code;
    p6_a58 := ddx_rgrv_rec.ans_set_jtot_object_id1;
    p6_a59 := ddx_rgrv_rec.ans_set_jtot_object_id2;
    p6_a60 := rosetta_g_miss_num_map(ddx_rgrv_rec.display_sequence);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_2000
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
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
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
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
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rgrv_tbl okl_opt_rul_tmp_pvt.rgrv_tbl_type;
    ddx_rgrv_tbl okl_opt_rul_tmp_pvt.rgrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_in_p2(ddp_rgrv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_opt_rul_tmp_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgrv_tbl,
      ddx_rgrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_out_p2(ddx_rgrv_tbl, p6_a0
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
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
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
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
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
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  NUMBER := 0-1962.0724
  )

  as
    ddp_rgrv_rec okl_opt_rul_tmp_pvt.rgrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgrv_rec.rgd_code := p5_a0;
    ddp_rgrv_rec.rule_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rgrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_rgrv_rec.sfwt_flag := p5_a3;
    ddp_rgrv_rec.object1_id1 := p5_a4;
    ddp_rgrv_rec.object2_id1 := p5_a5;
    ddp_rgrv_rec.object3_id1 := p5_a6;
    ddp_rgrv_rec.object1_id2 := p5_a7;
    ddp_rgrv_rec.object2_id2 := p5_a8;
    ddp_rgrv_rec.object3_id2 := p5_a9;
    ddp_rgrv_rec.jtot_object1_code := p5_a10;
    ddp_rgrv_rec.jtot_object2_code := p5_a11;
    ddp_rgrv_rec.jtot_object3_code := p5_a12;
    ddp_rgrv_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a13);
    ddp_rgrv_rec.rgp_id := rosetta_g_miss_num_map(p5_a14);
    ddp_rgrv_rec.priority := rosetta_g_miss_num_map(p5_a15);
    ddp_rgrv_rec.std_template_yn := p5_a16;
    ddp_rgrv_rec.comments := p5_a17;
    ddp_rgrv_rec.warn_yn := p5_a18;
    ddp_rgrv_rec.attribute_category := p5_a19;
    ddp_rgrv_rec.attribute1 := p5_a20;
    ddp_rgrv_rec.attribute2 := p5_a21;
    ddp_rgrv_rec.attribute3 := p5_a22;
    ddp_rgrv_rec.attribute4 := p5_a23;
    ddp_rgrv_rec.attribute5 := p5_a24;
    ddp_rgrv_rec.attribute6 := p5_a25;
    ddp_rgrv_rec.attribute7 := p5_a26;
    ddp_rgrv_rec.attribute8 := p5_a27;
    ddp_rgrv_rec.attribute9 := p5_a28;
    ddp_rgrv_rec.attribute10 := p5_a29;
    ddp_rgrv_rec.attribute11 := p5_a30;
    ddp_rgrv_rec.attribute12 := p5_a31;
    ddp_rgrv_rec.attribute13 := p5_a32;
    ddp_rgrv_rec.attribute14 := p5_a33;
    ddp_rgrv_rec.attribute15 := p5_a34;
    ddp_rgrv_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_rgrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_rgrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_rgrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_rgrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);
    ddp_rgrv_rec.rule_information_category := p5_a40;
    ddp_rgrv_rec.rule_information1 := p5_a41;
    ddp_rgrv_rec.rule_information2 := p5_a42;
    ddp_rgrv_rec.rule_information3 := p5_a43;
    ddp_rgrv_rec.rule_information4 := p5_a44;
    ddp_rgrv_rec.rule_information5 := p5_a45;
    ddp_rgrv_rec.rule_information6 := p5_a46;
    ddp_rgrv_rec.rule_information7 := p5_a47;
    ddp_rgrv_rec.rule_information8 := p5_a48;
    ddp_rgrv_rec.rule_information9 := p5_a49;
    ddp_rgrv_rec.rule_information10 := p5_a50;
    ddp_rgrv_rec.rule_information11 := p5_a51;
    ddp_rgrv_rec.rule_information12 := p5_a52;
    ddp_rgrv_rec.rule_information13 := p5_a53;
    ddp_rgrv_rec.rule_information14 := p5_a54;
    ddp_rgrv_rec.rule_information15 := p5_a55;
    ddp_rgrv_rec.template_yn := p5_a56;
    ddp_rgrv_rec.ans_set_jtot_object_code := p5_a57;
    ddp_rgrv_rec.ans_set_jtot_object_id1 := p5_a58;
    ddp_rgrv_rec.ans_set_jtot_object_id2 := p5_a59;
    ddp_rgrv_rec.display_sequence := rosetta_g_miss_num_map(p5_a60);

    -- here's the delegated call to the old PL/SQL routine
    okl_opt_rul_tmp_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgrv_rec);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_2000
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
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
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
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
    , p5_a55 JTF_VARCHAR2_TABLE_500
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_VARCHAR2_TABLE_100
    , p5_a60 JTF_NUMBER_TABLE
  )

  as
    ddp_rgrv_tbl okl_opt_rul_tmp_pvt.rgrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_in_p2(ddp_rgrv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_opt_rul_tmp_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_opt_rul_tmp_pvt_w;

/
