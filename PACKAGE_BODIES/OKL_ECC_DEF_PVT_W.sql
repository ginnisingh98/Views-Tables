--------------------------------------------------------
--  DDL for Package Body OKL_ECC_DEF_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECC_DEF_PVT_W" as
  /* $Header: OKLEECCB.pls 120.1 2005/10/30 04:58:22 appldev noship $ */
  procedure create_ecc(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eccv_rec okl_ecc_def_pvt.okl_eccv_rec;
    ddx_eccv_rec okl_ecc_def_pvt.okl_eccv_rec;
    ddp_eco_tbl okl_ecc_def_pvt.okl_eco_tbl;
    ddx_eco_tbl okl_ecc_def_pvt.okl_eco_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eccv_rec.crit_cat_def_id := p5_a0;
    ddp_eccv_rec.object_version_number := p5_a1;
    ddp_eccv_rec.ecc_ac_flag := p5_a2;
    ddp_eccv_rec.orig_crit_cat_def_id := p5_a3;
    ddp_eccv_rec.crit_cat_name := p5_a4;
    ddp_eccv_rec.crit_cat_desc := p5_a5;
    ddp_eccv_rec.sfwt_flag := p5_a6;
    ddp_eccv_rec.value_type_code := p5_a7;
    ddp_eccv_rec.data_type_code := p5_a8;
    ddp_eccv_rec.enabled_yn := p5_a9;
    ddp_eccv_rec.seeded_yn := p5_a10;
    ddp_eccv_rec.function_id := p5_a11;
    ddp_eccv_rec.source_yn := p5_a12;
    ddp_eccv_rec.sql_statement := p5_a13;
    ddp_eccv_rec.created_by := p5_a14;
    ddp_eccv_rec.creation_date := p5_a15;
    ddp_eccv_rec.last_updated_by := p5_a16;
    ddp_eccv_rec.last_update_date := p5_a17;
    ddp_eccv_rec.last_update_login := p5_a18;


    okl_eco_pvt_w.rosetta_table_copy_in_p1(ddp_eco_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_def_pvt.create_ecc(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eccv_rec,
      ddx_eccv_rec,
      ddp_eco_tbl,
      ddx_eco_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_eccv_rec.crit_cat_def_id;
    p6_a1 := ddx_eccv_rec.object_version_number;
    p6_a2 := ddx_eccv_rec.ecc_ac_flag;
    p6_a3 := ddx_eccv_rec.orig_crit_cat_def_id;
    p6_a4 := ddx_eccv_rec.crit_cat_name;
    p6_a5 := ddx_eccv_rec.crit_cat_desc;
    p6_a6 := ddx_eccv_rec.sfwt_flag;
    p6_a7 := ddx_eccv_rec.value_type_code;
    p6_a8 := ddx_eccv_rec.data_type_code;
    p6_a9 := ddx_eccv_rec.enabled_yn;
    p6_a10 := ddx_eccv_rec.seeded_yn;
    p6_a11 := ddx_eccv_rec.function_id;
    p6_a12 := ddx_eccv_rec.source_yn;
    p6_a13 := ddx_eccv_rec.sql_statement;
    p6_a14 := ddx_eccv_rec.created_by;
    p6_a15 := ddx_eccv_rec.creation_date;
    p6_a16 := ddx_eccv_rec.last_updated_by;
    p6_a17 := ddx_eccv_rec.last_update_date;
    p6_a18 := ddx_eccv_rec.last_update_login;


    okl_eco_pvt_w.rosetta_table_copy_out_p1(ddx_eco_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      );
  end;

  procedure update_ecc(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
    , p5_a17  DATE
    , p5_a18  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_DATE_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_eccv_rec okl_ecc_def_pvt.okl_eccv_rec;
    ddx_eccv_rec okl_ecc_def_pvt.okl_eccv_rec;
    ddp_eco_tbl okl_ecc_def_pvt.okl_eco_tbl;
    ddx_eco_tbl okl_ecc_def_pvt.okl_eco_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_eccv_rec.crit_cat_def_id := p5_a0;
    ddp_eccv_rec.object_version_number := p5_a1;
    ddp_eccv_rec.ecc_ac_flag := p5_a2;
    ddp_eccv_rec.orig_crit_cat_def_id := p5_a3;
    ddp_eccv_rec.crit_cat_name := p5_a4;
    ddp_eccv_rec.crit_cat_desc := p5_a5;
    ddp_eccv_rec.sfwt_flag := p5_a6;
    ddp_eccv_rec.value_type_code := p5_a7;
    ddp_eccv_rec.data_type_code := p5_a8;
    ddp_eccv_rec.enabled_yn := p5_a9;
    ddp_eccv_rec.seeded_yn := p5_a10;
    ddp_eccv_rec.function_id := p5_a11;
    ddp_eccv_rec.source_yn := p5_a12;
    ddp_eccv_rec.sql_statement := p5_a13;
    ddp_eccv_rec.created_by := p5_a14;
    ddp_eccv_rec.creation_date := p5_a15;
    ddp_eccv_rec.last_updated_by := p5_a16;
    ddp_eccv_rec.last_update_date := p5_a17;
    ddp_eccv_rec.last_update_login := p5_a18;


    okl_eco_pvt_w.rosetta_table_copy_in_p1(ddp_eco_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_def_pvt.update_ecc(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_eccv_rec,
      ddx_eccv_rec,
      ddp_eco_tbl,
      ddx_eco_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_eccv_rec.crit_cat_def_id;
    p6_a1 := ddx_eccv_rec.object_version_number;
    p6_a2 := ddx_eccv_rec.ecc_ac_flag;
    p6_a3 := ddx_eccv_rec.orig_crit_cat_def_id;
    p6_a4 := ddx_eccv_rec.crit_cat_name;
    p6_a5 := ddx_eccv_rec.crit_cat_desc;
    p6_a6 := ddx_eccv_rec.sfwt_flag;
    p6_a7 := ddx_eccv_rec.value_type_code;
    p6_a8 := ddx_eccv_rec.data_type_code;
    p6_a9 := ddx_eccv_rec.enabled_yn;
    p6_a10 := ddx_eccv_rec.seeded_yn;
    p6_a11 := ddx_eccv_rec.function_id;
    p6_a12 := ddx_eccv_rec.source_yn;
    p6_a13 := ddx_eccv_rec.sql_statement;
    p6_a14 := ddx_eccv_rec.created_by;
    p6_a15 := ddx_eccv_rec.creation_date;
    p6_a16 := ddx_eccv_rec.last_updated_by;
    p6_a17 := ddx_eccv_rec.last_update_date;
    p6_a18 := ddx_eccv_rec.last_update_login;


    okl_eco_pvt_w.rosetta_table_copy_out_p1(ddx_eco_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      );
  end;

end okl_ecc_def_pvt_w;

/
