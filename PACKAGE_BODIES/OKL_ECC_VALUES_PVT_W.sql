--------------------------------------------------------
--  DDL for Package Body OKL_ECC_VALUES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ECC_VALUES_PVT_W" as
  /* $Header: OKLEECVB.pls 120.1 2005/10/30 04:58:25 appldev noship $ */
  procedure remove_ec_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  DATE
    , p5_a12  NUMBER
  )

  as
    ddp_ecl_rec okl_ecc_values_pvt.okl_ecl_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ecl_rec.criteria_id := p5_a0;
    ddp_ecl_rec.object_version_number := p5_a1;
    ddp_ecl_rec.criteria_set_id := p5_a2;
    ddp_ecl_rec.crit_cat_def_id := p5_a3;
    ddp_ecl_rec.effective_from_date := p5_a4;
    ddp_ecl_rec.effective_to_date := p5_a5;
    ddp_ecl_rec.match_criteria_code := p5_a6;
    ddp_ecl_rec.is_new_flag := p5_a7;
    ddp_ecl_rec.created_by := p5_a8;
    ddp_ecl_rec.creation_date := p5_a9;
    ddp_ecl_rec.last_updated_by := p5_a10;
    ddp_ecl_rec.last_update_date := p5_a11;
    ddp_ecl_rec.last_update_login := p5_a12;

    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_values_pvt.remove_ec_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ecl_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure handle_eligibility_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  DATE
    , p5_a8  NUMBER
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_DATE_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_DATE_TABLE
    , p8_a5 out nocopy JTF_DATE_TABLE
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_DATE_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_VARCHAR2_TABLE_100
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_300
    , p9_a8 JTF_VARCHAR2_TABLE_300
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_DATE_TABLE
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_DATE_TABLE
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_DATE_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p9_a20 JTF_VARCHAR2_TABLE_100
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
    , p9_a35 JTF_VARCHAR2_TABLE_500
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_DATE_TABLE
    , p10_a12 out nocopy JTF_DATE_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_DATE_TABLE
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_DATE_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p_source_eff_from  DATE
    , p_source_eff_to  DATE
  )

  as
    ddp_ech_rec okl_ecc_values_pvt.okl_ech_rec;
    ddx_ech_rec okl_ecc_values_pvt.okl_ech_rec;
    ddp_ecl_tbl okl_ecc_values_pvt.okl_ecl_tbl;
    ddx_ecl_tbl okl_ecc_values_pvt.okl_ecl_tbl;
    ddp_ecv_tbl okl_ecc_values_pvt.okl_ecv_tbl;
    ddx_ecv_tbl okl_ecc_values_pvt.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ech_rec.criteria_set_id := p5_a0;
    ddp_ech_rec.object_version_number := p5_a1;
    ddp_ech_rec.source_id := p5_a2;
    ddp_ech_rec.source_object_code := p5_a3;
    ddp_ech_rec.match_criteria_code := p5_a4;
    ddp_ech_rec.validation_code := p5_a5;
    ddp_ech_rec.created_by := p5_a6;
    ddp_ech_rec.creation_date := p5_a7;
    ddp_ech_rec.last_updated_by := p5_a8;
    ddp_ech_rec.last_update_date := p5_a9;
    ddp_ech_rec.last_update_login := p5_a10;


    okl_ecl_pvt_w.rosetta_table_copy_in_p1(ddp_ecl_tbl, p7_a0
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
      );


    okl_ecv_pvt_w.rosetta_table_copy_in_p1(ddp_ecv_tbl, p9_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_values_pvt.handle_eligibility_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ech_rec,
      ddx_ech_rec,
      ddp_ecl_tbl,
      ddx_ecl_tbl,
      ddp_ecv_tbl,
      ddx_ecv_tbl,
      p_source_eff_from,
      p_source_eff_to);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_ech_rec.criteria_set_id;
    p6_a1 := ddx_ech_rec.object_version_number;
    p6_a2 := ddx_ech_rec.source_id;
    p6_a3 := ddx_ech_rec.source_object_code;
    p6_a4 := ddx_ech_rec.match_criteria_code;
    p6_a5 := ddx_ech_rec.validation_code;
    p6_a6 := ddx_ech_rec.created_by;
    p6_a7 := ddx_ech_rec.creation_date;
    p6_a8 := ddx_ech_rec.last_updated_by;
    p6_a9 := ddx_ech_rec.last_update_date;
    p6_a10 := ddx_ech_rec.last_update_login;


    okl_ecl_pvt_w.rosetta_table_copy_out_p1(ddx_ecl_tbl, p8_a0
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
      );


    okl_ecv_pvt_w.rosetta_table_copy_out_p1(ddx_ecv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      );


  end;

  procedure get_eligibility_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_id  NUMBER
    , p_source_type  VARCHAR2
    , p_eff_from  DATE
    , p_eff_to  DATE
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  DATE
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_DATE_TABLE
    , p10_a5 out nocopy JTF_DATE_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_DATE_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_DATE_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a9 out nocopy JTF_NUMBER_TABLE
    , p11_a10 out nocopy JTF_NUMBER_TABLE
    , p11_a11 out nocopy JTF_DATE_TABLE
    , p11_a12 out nocopy JTF_DATE_TABLE
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_DATE_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_DATE_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddx_ech_rec okl_ecc_values_pvt.okl_ech_rec;
    ddx_ecl_tbl okl_ecc_values_pvt.okl_ecl_tbl;
    ddx_ecv_tbl okl_ecc_values_pvt.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_values_pvt.get_eligibility_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_id,
      p_source_type,
      p_eff_from,
      p_eff_to,
      ddx_ech_rec,
      ddx_ecl_tbl,
      ddx_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_ech_rec.criteria_set_id;
    p9_a1 := ddx_ech_rec.object_version_number;
    p9_a2 := ddx_ech_rec.source_id;
    p9_a3 := ddx_ech_rec.source_object_code;
    p9_a4 := ddx_ech_rec.match_criteria_code;
    p9_a5 := ddx_ech_rec.validation_code;
    p9_a6 := ddx_ech_rec.created_by;
    p9_a7 := ddx_ech_rec.creation_date;
    p9_a8 := ddx_ech_rec.last_updated_by;
    p9_a9 := ddx_ech_rec.last_update_date;
    p9_a10 := ddx_ech_rec.last_update_login;

    okl_ecl_pvt_w.rosetta_table_copy_out_p1(ddx_ecl_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      );

    okl_ecv_pvt_w.rosetta_table_copy_out_p1(ddx_ecv_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      );
  end;

  procedure get_eligibility_criteria(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_id  NUMBER
    , p_source_type  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  DATE
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  DATE
    , p7_a10 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_DATE_TABLE
    , p8_a5 out nocopy JTF_DATE_TABLE
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_DATE_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_DATE_TABLE
    , p9_a12 out nocopy JTF_DATE_TABLE
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_NUMBER_TABLE
    , p9_a16 out nocopy JTF_DATE_TABLE
    , p9_a17 out nocopy JTF_NUMBER_TABLE
    , p9_a18 out nocopy JTF_DATE_TABLE
    , p9_a19 out nocopy JTF_NUMBER_TABLE
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddx_ech_rec okl_ecc_values_pvt.okl_ech_rec;
    ddx_ecl_tbl okl_ecc_values_pvt.okl_ecl_tbl;
    ddx_ecv_tbl okl_ecc_values_pvt.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okl_ecc_values_pvt.get_eligibility_criteria(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_source_id,
      p_source_type,
      ddx_ech_rec,
      ddx_ecl_tbl,
      ddx_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_ech_rec.criteria_set_id;
    p7_a1 := ddx_ech_rec.object_version_number;
    p7_a2 := ddx_ech_rec.source_id;
    p7_a3 := ddx_ech_rec.source_object_code;
    p7_a4 := ddx_ech_rec.match_criteria_code;
    p7_a5 := ddx_ech_rec.validation_code;
    p7_a6 := ddx_ech_rec.created_by;
    p7_a7 := ddx_ech_rec.creation_date;
    p7_a8 := ddx_ech_rec.last_updated_by;
    p7_a9 := ddx_ech_rec.last_update_date;
    p7_a10 := ddx_ech_rec.last_update_login;

    okl_ecl_pvt_w.rosetta_table_copy_out_p1(ddx_ecl_tbl, p8_a0
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
      );

    okl_ecv_pvt_w.rosetta_table_copy_out_p1(ddx_ecv_tbl, p9_a0
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
      );
  end;

end okl_ecc_values_pvt_w;

/
