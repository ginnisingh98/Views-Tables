--------------------------------------------------------
--  DDL for Package Body OKL_VP_RULE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_RULE_PUB_W" as
  /* $Header: OKLURLGB.pls 120.4 2005/08/04 03:18:21 manumanu noship $ */
  procedure create_rule_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  NUMBER
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
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
  )

  as
    ddp_rgpv_rec okl_vp_rule_pub.rgpv_rec_type;
    ddx_rgpv_rec okl_vp_rule_pub.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := p5_a0;
    ddp_rgpv_rec.object_version_number := p5_a1;
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := p5_a6;
    ddp_rgpv_rec.chr_id := p5_a7;
    ddp_rgpv_rec.dnz_chr_id := p5_a8;
    ddp_rgpv_rec.parent_rgp_id := p5_a9;
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
    ddp_rgpv_rec.created_by := p5_a27;
    ddp_rgpv_rec.creation_date := p5_a28;
    ddp_rgpv_rec.last_updated_by := p5_a29;
    ddp_rgpv_rec.last_update_date := p5_a30;
    ddp_rgpv_rec.last_update_login := p5_a31;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_rule_pub.create_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgpv_rec.id;
    p6_a1 := ddx_rgpv_rec.object_version_number;
    p6_a2 := ddx_rgpv_rec.sfwt_flag;
    p6_a3 := ddx_rgpv_rec.rgd_code;
    p6_a4 := ddx_rgpv_rec.sat_code;
    p6_a5 := ddx_rgpv_rec.rgp_type;
    p6_a6 := ddx_rgpv_rec.cle_id;
    p6_a7 := ddx_rgpv_rec.chr_id;
    p6_a8 := ddx_rgpv_rec.dnz_chr_id;
    p6_a9 := ddx_rgpv_rec.parent_rgp_id;
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
    p6_a27 := ddx_rgpv_rec.created_by;
    p6_a28 := ddx_rgpv_rec.creation_date;
    p6_a29 := ddx_rgpv_rec.last_updated_by;
    p6_a30 := ddx_rgpv_rec.last_update_date;
    p6_a31 := ddx_rgpv_rec.last_update_login;
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
    ddp_rgpv_tbl okl_vp_rule_pub.rgpv_tbl_type;
    ddx_rgpv_tbl okl_vp_rule_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_a_pvt_w.rosetta_table_copy_in_p5(ddp_rgpv_tbl, p5_a0
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
    okl_vp_rule_pub.create_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_tbl,
      ddx_rgpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_a_pvt_w.rosetta_table_copy_out_p5(ddx_rgpv_tbl, p6_a0
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
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  NUMBER
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
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
  )

  as
    ddp_rgpv_rec okl_vp_rule_pub.rgpv_rec_type;
    ddx_rgpv_rec okl_vp_rule_pub.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := p5_a0;
    ddp_rgpv_rec.object_version_number := p5_a1;
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := p5_a6;
    ddp_rgpv_rec.chr_id := p5_a7;
    ddp_rgpv_rec.dnz_chr_id := p5_a8;
    ddp_rgpv_rec.parent_rgp_id := p5_a9;
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
    ddp_rgpv_rec.created_by := p5_a27;
    ddp_rgpv_rec.creation_date := p5_a28;
    ddp_rgpv_rec.last_updated_by := p5_a29;
    ddp_rgpv_rec.last_update_date := p5_a30;
    ddp_rgpv_rec.last_update_login := p5_a31;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_rule_pub.update_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgpv_rec.id;
    p6_a1 := ddx_rgpv_rec.object_version_number;
    p6_a2 := ddx_rgpv_rec.sfwt_flag;
    p6_a3 := ddx_rgpv_rec.rgd_code;
    p6_a4 := ddx_rgpv_rec.sat_code;
    p6_a5 := ddx_rgpv_rec.rgp_type;
    p6_a6 := ddx_rgpv_rec.cle_id;
    p6_a7 := ddx_rgpv_rec.chr_id;
    p6_a8 := ddx_rgpv_rec.dnz_chr_id;
    p6_a9 := ddx_rgpv_rec.parent_rgp_id;
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
    p6_a27 := ddx_rgpv_rec.created_by;
    p6_a28 := ddx_rgpv_rec.creation_date;
    p6_a29 := ddx_rgpv_rec.last_updated_by;
    p6_a30 := ddx_rgpv_rec.last_update_date;
    p6_a31 := ddx_rgpv_rec.last_update_login;
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
    ddp_rgpv_tbl okl_vp_rule_pub.rgpv_tbl_type;
    ddx_rgpv_tbl okl_vp_rule_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_a_pvt_w.rosetta_table_copy_in_p5(ddp_rgpv_tbl, p5_a0
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
    okl_vp_rule_pub.update_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_tbl,
      ddx_rgpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_okc_migration_a_pvt_w.rosetta_table_copy_out_p5(ddx_rgpv_tbl, p6_a0
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
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  NUMBER
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
  )

  as
    ddp_rgpv_rec okl_vp_rule_pub.rgpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.id := p5_a0;
    ddp_rgpv_rec.object_version_number := p5_a1;
    ddp_rgpv_rec.sfwt_flag := p5_a2;
    ddp_rgpv_rec.rgd_code := p5_a3;
    ddp_rgpv_rec.sat_code := p5_a4;
    ddp_rgpv_rec.rgp_type := p5_a5;
    ddp_rgpv_rec.cle_id := p5_a6;
    ddp_rgpv_rec.chr_id := p5_a7;
    ddp_rgpv_rec.dnz_chr_id := p5_a8;
    ddp_rgpv_rec.parent_rgp_id := p5_a9;
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
    ddp_rgpv_rec.created_by := p5_a27;
    ddp_rgpv_rec.creation_date := p5_a28;
    ddp_rgpv_rec.last_updated_by := p5_a29;
    ddp_rgpv_rec.last_update_date := p5_a30;
    ddp_rgpv_rec.last_update_login := p5_a31;

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_rule_pub.delete_rule_group(p_api_version,
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
    ddp_rgpv_tbl okl_vp_rule_pub.rgpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_okc_migration_a_pvt_w.rosetta_table_copy_in_p5(ddp_rgpv_tbl, p5_a0
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
    okl_vp_rule_pub.delete_rule_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_vp_rule_pub_w;

/
