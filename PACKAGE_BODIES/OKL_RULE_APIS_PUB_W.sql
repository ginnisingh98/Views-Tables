--------------------------------------------------------
--  DDL for Package Body OKL_RULE_APIS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RULE_APIS_PUB_W" as
  /* $Header: OKLURAPB.pls 120.2 2005/08/03 05:50:33 asawanka noship $ */
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

  procedure get_contract_rgs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_chr_id  NUMBER
    , p_cle_id  NUMBER
    , p_rgd_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_DATE_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_DATE_TABLE
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , x_rg_count out nocopy  NUMBER
  )

  as
    ddx_rgpv_tbl okl_rule_apis_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okl_rule_apis_pub.get_contract_rgs(p_api_version,
      p_init_msg_list,
      p_chr_id,
      p_cle_id,
      p_rgd_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_rgpv_tbl,
      x_rg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_okc_migration_pvt_w.rosetta_table_copy_out_p13(ddx_rgpv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      );

  end;

  procedure get_contract_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_rdf_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    , x_rule_count out nocopy  NUMBER
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  VARCHAR2 := fnd_api.g_miss_char
    , p2_a4  VARCHAR2 := fnd_api.g_miss_char
    , p2_a5  VARCHAR2 := fnd_api.g_miss_char
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  NUMBER := 0-1962.0724
    , p2_a8  NUMBER := 0-1962.0724
    , p2_a9  NUMBER := 0-1962.0724
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  VARCHAR2 := fnd_api.g_miss_char
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  VARCHAR2 := fnd_api.g_miss_char
    , p2_a27  NUMBER := 0-1962.0724
    , p2_a28  DATE := fnd_api.g_miss_date
    , p2_a29  NUMBER := 0-1962.0724
    , p2_a30  DATE := fnd_api.g_miss_date
    , p2_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_rgpv_rec okl_rule_apis_pub.rgpv_rec_type;
    ddx_rulv_tbl okl_rule_apis_pub.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_rgpv_rec.id := rosetta_g_miss_num_map(p2_a0);
    ddp_rgpv_rec.object_version_number := rosetta_g_miss_num_map(p2_a1);
    ddp_rgpv_rec.sfwt_flag := p2_a2;
    ddp_rgpv_rec.rgd_code := p2_a3;
    ddp_rgpv_rec.sat_code := p2_a4;
    ddp_rgpv_rec.rgp_type := p2_a5;
    ddp_rgpv_rec.cle_id := rosetta_g_miss_num_map(p2_a6);
    ddp_rgpv_rec.chr_id := rosetta_g_miss_num_map(p2_a7);
    ddp_rgpv_rec.dnz_chr_id := rosetta_g_miss_num_map(p2_a8);
    ddp_rgpv_rec.parent_rgp_id := rosetta_g_miss_num_map(p2_a9);
    ddp_rgpv_rec.comments := p2_a10;
    ddp_rgpv_rec.attribute_category := p2_a11;
    ddp_rgpv_rec.attribute1 := p2_a12;
    ddp_rgpv_rec.attribute2 := p2_a13;
    ddp_rgpv_rec.attribute3 := p2_a14;
    ddp_rgpv_rec.attribute4 := p2_a15;
    ddp_rgpv_rec.attribute5 := p2_a16;
    ddp_rgpv_rec.attribute6 := p2_a17;
    ddp_rgpv_rec.attribute7 := p2_a18;
    ddp_rgpv_rec.attribute8 := p2_a19;
    ddp_rgpv_rec.attribute9 := p2_a20;
    ddp_rgpv_rec.attribute10 := p2_a21;
    ddp_rgpv_rec.attribute11 := p2_a22;
    ddp_rgpv_rec.attribute12 := p2_a23;
    ddp_rgpv_rec.attribute13 := p2_a24;
    ddp_rgpv_rec.attribute14 := p2_a25;
    ddp_rgpv_rec.attribute15 := p2_a26;
    ddp_rgpv_rec.created_by := rosetta_g_miss_num_map(p2_a27);
    ddp_rgpv_rec.creation_date := rosetta_g_miss_date_in_map(p2_a28);
    ddp_rgpv_rec.last_updated_by := rosetta_g_miss_num_map(p2_a29);
    ddp_rgpv_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a30);
    ddp_rgpv_rec.last_update_login := rosetta_g_miss_num_map(p2_a31);







    -- here's the delegated call to the old PL/SQL routine
    okl_rule_apis_pub.get_contract_rules(p_api_version,
      p_init_msg_list,
      ddp_rgpv_rec,
      p_rdf_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_rulv_tbl,
      x_rule_count);

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

  procedure get_rule_disp_value(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
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
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  CHAR := fnd_api.g_miss_char
    , p2_a3  VARCHAR2 := fnd_api.g_miss_char
    , p2_a4  VARCHAR2 := fnd_api.g_miss_char
    , p2_a5  VARCHAR2 := fnd_api.g_miss_char
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  NUMBER := 0-1962.0724
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  NUMBER := 0-1962.0724
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  VARCHAR2 := fnd_api.g_miss_char
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  VARCHAR2 := fnd_api.g_miss_char
    , p2_a27  VARCHAR2 := fnd_api.g_miss_char
    , p2_a28  VARCHAR2 := fnd_api.g_miss_char
    , p2_a29  VARCHAR2 := fnd_api.g_miss_char
    , p2_a30  VARCHAR2 := fnd_api.g_miss_char
    , p2_a31  VARCHAR2 := fnd_api.g_miss_char
    , p2_a32  VARCHAR2 := fnd_api.g_miss_char
    , p2_a33  VARCHAR2 := fnd_api.g_miss_char
    , p2_a34  NUMBER := 0-1962.0724
    , p2_a35  DATE := fnd_api.g_miss_date
    , p2_a36  NUMBER := 0-1962.0724
    , p2_a37  DATE := fnd_api.g_miss_date
    , p2_a38  NUMBER := 0-1962.0724
    , p2_a39  VARCHAR2 := fnd_api.g_miss_char
    , p2_a40  VARCHAR2 := fnd_api.g_miss_char
    , p2_a41  VARCHAR2 := fnd_api.g_miss_char
    , p2_a42  VARCHAR2 := fnd_api.g_miss_char
    , p2_a43  VARCHAR2 := fnd_api.g_miss_char
    , p2_a44  VARCHAR2 := fnd_api.g_miss_char
    , p2_a45  VARCHAR2 := fnd_api.g_miss_char
    , p2_a46  VARCHAR2 := fnd_api.g_miss_char
    , p2_a47  VARCHAR2 := fnd_api.g_miss_char
    , p2_a48  VARCHAR2 := fnd_api.g_miss_char
    , p2_a49  VARCHAR2 := fnd_api.g_miss_char
    , p2_a50  VARCHAR2 := fnd_api.g_miss_char
    , p2_a51  VARCHAR2 := fnd_api.g_miss_char
    , p2_a52  VARCHAR2 := fnd_api.g_miss_char
    , p2_a53  VARCHAR2 := fnd_api.g_miss_char
    , p2_a54  VARCHAR2 := fnd_api.g_miss_char
    , p2_a55  VARCHAR2 := fnd_api.g_miss_char
    , p2_a56  VARCHAR2 := fnd_api.g_miss_char
    , p2_a57  VARCHAR2 := fnd_api.g_miss_char
    , p2_a58  VARCHAR2 := fnd_api.g_miss_char
    , p2_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_rule_apis_pub.rulv_rec_type;
    ddx_rulv_disp_rec okl_rule_apis_pub.rulv_disp_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_rulv_rec.id := rosetta_g_miss_num_map(p2_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p2_a1);
    ddp_rulv_rec.sfwt_flag := p2_a2;
    ddp_rulv_rec.object1_id1 := p2_a3;
    ddp_rulv_rec.object2_id1 := p2_a4;
    ddp_rulv_rec.object3_id1 := p2_a5;
    ddp_rulv_rec.object1_id2 := p2_a6;
    ddp_rulv_rec.object2_id2 := p2_a7;
    ddp_rulv_rec.object3_id2 := p2_a8;
    ddp_rulv_rec.jtot_object1_code := p2_a9;
    ddp_rulv_rec.jtot_object2_code := p2_a10;
    ddp_rulv_rec.jtot_object3_code := p2_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p2_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p2_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p2_a14);
    ddp_rulv_rec.std_template_yn := p2_a15;
    ddp_rulv_rec.comments := p2_a16;
    ddp_rulv_rec.warn_yn := p2_a17;
    ddp_rulv_rec.attribute_category := p2_a18;
    ddp_rulv_rec.attribute1 := p2_a19;
    ddp_rulv_rec.attribute2 := p2_a20;
    ddp_rulv_rec.attribute3 := p2_a21;
    ddp_rulv_rec.attribute4 := p2_a22;
    ddp_rulv_rec.attribute5 := p2_a23;
    ddp_rulv_rec.attribute6 := p2_a24;
    ddp_rulv_rec.attribute7 := p2_a25;
    ddp_rulv_rec.attribute8 := p2_a26;
    ddp_rulv_rec.attribute9 := p2_a27;
    ddp_rulv_rec.attribute10 := p2_a28;
    ddp_rulv_rec.attribute11 := p2_a29;
    ddp_rulv_rec.attribute12 := p2_a30;
    ddp_rulv_rec.attribute13 := p2_a31;
    ddp_rulv_rec.attribute14 := p2_a32;
    ddp_rulv_rec.attribute15 := p2_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p2_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p2_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p2_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p2_a38);
    ddp_rulv_rec.rule_information_category := p2_a39;
    ddp_rulv_rec.rule_information1 := p2_a40;
    ddp_rulv_rec.rule_information2 := p2_a41;
    ddp_rulv_rec.rule_information3 := p2_a42;
    ddp_rulv_rec.rule_information4 := p2_a43;
    ddp_rulv_rec.rule_information5 := p2_a44;
    ddp_rulv_rec.rule_information6 := p2_a45;
    ddp_rulv_rec.rule_information7 := p2_a46;
    ddp_rulv_rec.rule_information8 := p2_a47;
    ddp_rulv_rec.rule_information9 := p2_a48;
    ddp_rulv_rec.rule_information10 := p2_a49;
    ddp_rulv_rec.rule_information11 := p2_a50;
    ddp_rulv_rec.rule_information12 := p2_a51;
    ddp_rulv_rec.rule_information13 := p2_a52;
    ddp_rulv_rec.rule_information14 := p2_a53;
    ddp_rulv_rec.rule_information15 := p2_a54;
    ddp_rulv_rec.template_yn := p2_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p2_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p2_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p2_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p2_a59);





    -- here's the delegated call to the old PL/SQL routine
    okl_rule_apis_pub.get_rule_disp_value(p_api_version,
      p_init_msg_list,
      ddp_rulv_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_rulv_disp_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rulv_disp_rec.id);
    p6_a1 := ddx_rulv_disp_rec.rdf_code;
    p6_a2 := ddx_rulv_disp_rec.obj1_name;
    p6_a3 := ddx_rulv_disp_rec.obj1_descr;
    p6_a4 := ddx_rulv_disp_rec.obj1_status;
    p6_a5 := ddx_rulv_disp_rec.obj1_start_date;
    p6_a6 := ddx_rulv_disp_rec.obj1_end_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_rulv_disp_rec.obj1_org_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_rulv_disp_rec.obj1_inv_org_id);
    p6_a9 := ddx_rulv_disp_rec.obj1_book_type_code;
    p6_a10 := ddx_rulv_disp_rec.obj1_select;
    p6_a11 := ddx_rulv_disp_rec.obj2_name;
    p6_a12 := ddx_rulv_disp_rec.obj2_descr;
    p6_a13 := ddx_rulv_disp_rec.obj2_status;
    p6_a14 := ddx_rulv_disp_rec.obj2_start_date;
    p6_a15 := ddx_rulv_disp_rec.obj2_end_date;
    p6_a16 := rosetta_g_miss_num_map(ddx_rulv_disp_rec.obj2_org_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_rulv_disp_rec.obj2_inv_org_id);
    p6_a18 := ddx_rulv_disp_rec.obj2_book_type_code;
    p6_a19 := ddx_rulv_disp_rec.obj2_select;
    p6_a20 := ddx_rulv_disp_rec.obj3_name;
    p6_a21 := ddx_rulv_disp_rec.obj3_descr;
    p6_a22 := ddx_rulv_disp_rec.obj3_status;
    p6_a23 := ddx_rulv_disp_rec.obj3_start_date;
    p6_a24 := ddx_rulv_disp_rec.obj3_end_date;
    p6_a25 := rosetta_g_miss_num_map(ddx_rulv_disp_rec.obj3_org_id);
    p6_a26 := rosetta_g_miss_num_map(ddx_rulv_disp_rec.obj3_inv_org_id);
    p6_a27 := ddx_rulv_disp_rec.obj3_book_type_code;
    p6_a28 := ddx_rulv_disp_rec.obj3_select;
    p6_a29 := ddx_rulv_disp_rec.rul_info1_name;
    p6_a30 := ddx_rulv_disp_rec.rul_info1_select;
    p6_a31 := ddx_rulv_disp_rec.rul_info2_name;
    p6_a32 := ddx_rulv_disp_rec.rul_info2_select;
    p6_a33 := ddx_rulv_disp_rec.rul_info3_name;
    p6_a34 := ddx_rulv_disp_rec.rul_info3_select;
    p6_a35 := ddx_rulv_disp_rec.rul_info4_name;
    p6_a36 := ddx_rulv_disp_rec.rul_info4_select;
    p6_a37 := ddx_rulv_disp_rec.rul_info5_name;
    p6_a38 := ddx_rulv_disp_rec.rul_info5_select;
    p6_a39 := ddx_rulv_disp_rec.rul_info6_name;
    p6_a40 := ddx_rulv_disp_rec.rul_info6_select;
    p6_a41 := ddx_rulv_disp_rec.rul_info7_name;
    p6_a42 := ddx_rulv_disp_rec.rul_info7_select;
    p6_a43 := ddx_rulv_disp_rec.rul_info8_name;
    p6_a44 := ddx_rulv_disp_rec.rul_info8_select;
    p6_a45 := ddx_rulv_disp_rec.rul_info9_name;
    p6_a46 := ddx_rulv_disp_rec.rul_info9_select;
    p6_a47 := ddx_rulv_disp_rec.rul_info10_name;
    p6_a48 := ddx_rulv_disp_rec.rul_info10_select;
    p6_a49 := ddx_rulv_disp_rec.rul_info11_name;
    p6_a50 := ddx_rulv_disp_rec.rul_info11_select;
    p6_a51 := ddx_rulv_disp_rec.rul_info12_name;
    p6_a52 := ddx_rulv_disp_rec.rul_info12_select;
    p6_a53 := ddx_rulv_disp_rec.rul_info13_name;
    p6_a54 := ddx_rulv_disp_rec.rul_info13_select;
    p6_a55 := ddx_rulv_disp_rec.rul_info14_name;
    p6_a56 := ddx_rulv_disp_rec.rul_info14_select;
    p6_a57 := ddx_rulv_disp_rec.rul_info15_name;
    p6_a58 := ddx_rulv_disp_rec.rul_info15_select;
  end;

end okl_rule_apis_pub_w;

/
