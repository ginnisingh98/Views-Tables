--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_RATE_FACTORS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_RATE_FACTORS_PVT_W" as
  /* $Header: OKLELRFB.pls 120.1 2005/09/30 10:59:51 asawanka noship $ */
  procedure handle_lrf_ents(p_api_version  NUMBER
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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
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
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_VARCHAR2_TABLE_500
    , p7_a27 JTF_VARCHAR2_TABLE_500
    , p7_a28 JTF_VARCHAR2_TABLE_500
    , p7_a29 JTF_VARCHAR2_TABLE_500
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_DATE_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddp_lrfv_tbl okl_lease_rate_factors_pvt.lrfv_tbl_type;
    ddx_lrfv_tbl okl_lease_rate_factors_pvt.lrfv_tbl_type;
    ddp_lrlv_tbl okl_lease_rate_factors_pvt.okl_lrlv_tbl;
    ddx_lrlv_tbl okl_lease_rate_factors_pvt.okl_lrlv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lrf_pvt_w.rosetta_table_copy_in_p28(ddp_lrfv_tbl, p5_a0
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
      );


    okl_lrl_pvt_w.rosetta_table_copy_in_p1(ddp_lrlv_tbl, p7_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_factors_pvt.handle_lrf_ents(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrfv_tbl,
      ddx_lrfv_tbl,
      ddp_lrlv_tbl,
      ddx_lrlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lrf_pvt_w.rosetta_table_copy_out_p28(ddx_lrfv_tbl, p6_a0
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
      );


    okl_lrl_pvt_w.rosetta_table_copy_out_p1(ddx_lrlv_tbl, p8_a0
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
      );
  end;

  procedure remove_lrs_factor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
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
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
  )

  as
    ddp_lrfv_rec okl_lease_rate_factors_pvt.lrfv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrfv_rec.id := p5_a0;
    ddp_lrfv_rec.object_version_number := p5_a1;
    ddp_lrfv_rec.lrt_id := p5_a2;
    ddp_lrfv_rec.term_in_months := p5_a3;
    ddp_lrfv_rec.residual_value_percent := p5_a4;
    ddp_lrfv_rec.interest_rate := p5_a5;
    ddp_lrfv_rec.lease_rate_factor := p5_a6;
    ddp_lrfv_rec.created_by := p5_a7;
    ddp_lrfv_rec.creation_date := p5_a8;
    ddp_lrfv_rec.last_updated_by := p5_a9;
    ddp_lrfv_rec.last_update_date := p5_a10;
    ddp_lrfv_rec.last_update_login := p5_a11;
    ddp_lrfv_rec.attribute_category := p5_a12;
    ddp_lrfv_rec.attribute1 := p5_a13;
    ddp_lrfv_rec.attribute2 := p5_a14;
    ddp_lrfv_rec.attribute3 := p5_a15;
    ddp_lrfv_rec.attribute4 := p5_a16;
    ddp_lrfv_rec.attribute5 := p5_a17;
    ddp_lrfv_rec.attribute6 := p5_a18;
    ddp_lrfv_rec.attribute7 := p5_a19;
    ddp_lrfv_rec.attribute8 := p5_a20;
    ddp_lrfv_rec.attribute9 := p5_a21;
    ddp_lrfv_rec.attribute10 := p5_a22;
    ddp_lrfv_rec.attribute11 := p5_a23;
    ddp_lrfv_rec.attribute12 := p5_a24;
    ddp_lrfv_rec.attribute13 := p5_a25;
    ddp_lrfv_rec.attribute14 := p5_a26;
    ddp_lrfv_rec.attribute15 := p5_a27;
    ddp_lrfv_rec.is_new_flag := p5_a28;
    ddp_lrfv_rec.rate_set_version_id := p5_a29;

    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_factors_pvt.remove_lrs_factor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrfv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure remove_lrs_level(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  DATE
    , p5_a11  NUMBER
    , p5_a12  DATE
    , p5_a13  NUMBER
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
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
  )

  as
    ddp_lrlv_rec okl_lease_rate_factors_pvt.okl_lrlv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrlv_rec.rate_set_level_id := p5_a0;
    ddp_lrlv_rec.object_version_number := p5_a1;
    ddp_lrlv_rec.residual_percent := p5_a2;
    ddp_lrlv_rec.rate_set_id := p5_a3;
    ddp_lrlv_rec.rate_set_version_id := p5_a4;
    ddp_lrlv_rec.rate_set_factor_id := p5_a5;
    ddp_lrlv_rec.sequence_number := p5_a6;
    ddp_lrlv_rec.periods := p5_a7;
    ddp_lrlv_rec.lease_rate_factor := p5_a8;
    ddp_lrlv_rec.created_by := p5_a9;
    ddp_lrlv_rec.creation_date := p5_a10;
    ddp_lrlv_rec.last_updated_by := p5_a11;
    ddp_lrlv_rec.last_update_date := p5_a12;
    ddp_lrlv_rec.last_update_login := p5_a13;
    ddp_lrlv_rec.attribute_category := p5_a14;
    ddp_lrlv_rec.attribute1 := p5_a15;
    ddp_lrlv_rec.attribute2 := p5_a16;
    ddp_lrlv_rec.attribute3 := p5_a17;
    ddp_lrlv_rec.attribute4 := p5_a18;
    ddp_lrlv_rec.attribute5 := p5_a19;
    ddp_lrlv_rec.attribute6 := p5_a20;
    ddp_lrlv_rec.attribute7 := p5_a21;
    ddp_lrlv_rec.attribute8 := p5_a22;
    ddp_lrlv_rec.attribute9 := p5_a23;
    ddp_lrlv_rec.attribute10 := p5_a24;
    ddp_lrlv_rec.attribute11 := p5_a25;
    ddp_lrlv_rec.attribute12 := p5_a26;
    ddp_lrlv_rec.attribute13 := p5_a27;
    ddp_lrlv_rec.attribute14 := p5_a28;
    ddp_lrlv_rec.attribute15 := p5_a29;

    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_factors_pvt.remove_lrs_level(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure handle_lease_rate_factors(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  DATE
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  DATE
    , p6_a18  NUMBER
    , p6_a19  DATE
    , p6_a20  NUMBER
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_VARCHAR2_TABLE_500
    , p7_a27 JTF_VARCHAR2_TABLE_500
    , p7_a28 JTF_VARCHAR2_TABLE_100
    , p7_a29 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_DATE_TABLE
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_VARCHAR2_TABLE_100
    , p9_a15 JTF_VARCHAR2_TABLE_500
    , p9_a16 JTF_VARCHAR2_TABLE_500
    , p9_a17 JTF_VARCHAR2_TABLE_500
    , p9_a18 JTF_VARCHAR2_TABLE_500
    , p9_a19 JTF_VARCHAR2_TABLE_500
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
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_DATE_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_DATE_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddp_lrtv_rec okl_lease_rate_factors_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_factors_pvt.okl_lrvv_rec;
    ddp_lrfv_tbl okl_lease_rate_factors_pvt.lrfv_tbl_type;
    ddx_lrfv_tbl okl_lease_rate_factors_pvt.lrfv_tbl_type;
    ddp_lrlv_tbl okl_lease_rate_factors_pvt.okl_lrlv_tbl;
    ddx_lrlv_tbl okl_lease_rate_factors_pvt.okl_lrlv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;

    ddp_lrvv_rec.rate_set_version_id := p6_a0;
    ddp_lrvv_rec.object_version_number := p6_a1;
    ddp_lrvv_rec.arrears_yn := p6_a2;
    ddp_lrvv_rec.effective_from_date := p6_a3;
    ddp_lrvv_rec.effective_to_date := p6_a4;
    ddp_lrvv_rec.rate_set_id := p6_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p6_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p6_a7;
    ddp_lrvv_rec.adj_mat_version_id := p6_a8;
    ddp_lrvv_rec.version_number := p6_a9;
    ddp_lrvv_rec.lrs_rate := p6_a10;
    ddp_lrvv_rec.rate_tolerance := p6_a11;
    ddp_lrvv_rec.residual_tolerance := p6_a12;
    ddp_lrvv_rec.deferred_pmts := p6_a13;
    ddp_lrvv_rec.advance_pmts := p6_a14;
    ddp_lrvv_rec.sts_code := p6_a15;
    ddp_lrvv_rec.created_by := p6_a16;
    ddp_lrvv_rec.creation_date := p6_a17;
    ddp_lrvv_rec.last_updated_by := p6_a18;
    ddp_lrvv_rec.last_update_date := p6_a19;
    ddp_lrvv_rec.last_update_login := p6_a20;
    ddp_lrvv_rec.attribute_category := p6_a21;
    ddp_lrvv_rec.attribute1 := p6_a22;
    ddp_lrvv_rec.attribute2 := p6_a23;
    ddp_lrvv_rec.attribute3 := p6_a24;
    ddp_lrvv_rec.attribute4 := p6_a25;
    ddp_lrvv_rec.attribute5 := p6_a26;
    ddp_lrvv_rec.attribute6 := p6_a27;
    ddp_lrvv_rec.attribute7 := p6_a28;
    ddp_lrvv_rec.attribute8 := p6_a29;
    ddp_lrvv_rec.attribute9 := p6_a30;
    ddp_lrvv_rec.attribute10 := p6_a31;
    ddp_lrvv_rec.attribute11 := p6_a32;
    ddp_lrvv_rec.attribute12 := p6_a33;
    ddp_lrvv_rec.attribute13 := p6_a34;
    ddp_lrvv_rec.attribute14 := p6_a35;
    ddp_lrvv_rec.attribute15 := p6_a36;
    ddp_lrvv_rec.standard_rate := p6_a37;

    okl_lrf_pvt_w.rosetta_table_copy_in_p28(ddp_lrfv_tbl, p7_a0
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
      );


    okl_lrl_pvt_w.rosetta_table_copy_in_p1(ddp_lrlv_tbl, p9_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_factors_pvt.handle_lease_rate_factors(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddp_lrvv_rec,
      ddp_lrfv_tbl,
      ddx_lrfv_tbl,
      ddp_lrlv_tbl,
      ddx_lrlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_lrf_pvt_w.rosetta_table_copy_out_p28(ddx_lrfv_tbl, p8_a0
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
      );


    okl_lrl_pvt_w.rosetta_table_copy_out_p1(ddx_lrlv_tbl, p10_a0
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
      );
  end;

  procedure handle_lrf_submit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  DATE
    , p5_a14  NUMBER
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  DATE
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  DATE
    , p6_a18  NUMBER
    , p6_a19  DATE
    , p6_a20  NUMBER
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_DATE_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_100
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_VARCHAR2_TABLE_500
    , p7_a19 JTF_VARCHAR2_TABLE_500
    , p7_a20 JTF_VARCHAR2_TABLE_500
    , p7_a21 JTF_VARCHAR2_TABLE_500
    , p7_a22 JTF_VARCHAR2_TABLE_500
    , p7_a23 JTF_VARCHAR2_TABLE_500
    , p7_a24 JTF_VARCHAR2_TABLE_500
    , p7_a25 JTF_VARCHAR2_TABLE_500
    , p7_a26 JTF_VARCHAR2_TABLE_500
    , p7_a27 JTF_VARCHAR2_TABLE_500
    , p7_a28 JTF_VARCHAR2_TABLE_100
    , p7_a29 JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_DATE_TABLE
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_VARCHAR2_TABLE_100
    , p9_a15 JTF_VARCHAR2_TABLE_500
    , p9_a16 JTF_VARCHAR2_TABLE_500
    , p9_a17 JTF_VARCHAR2_TABLE_500
    , p9_a18 JTF_VARCHAR2_TABLE_500
    , p9_a19 JTF_VARCHAR2_TABLE_500
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
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_DATE_TABLE
    , p10_a11 out nocopy JTF_NUMBER_TABLE
    , p10_a12 out nocopy JTF_DATE_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddp_lrtv_rec okl_lease_rate_factors_pvt.lrtv_rec_type;
    ddp_lrvv_rec okl_lease_rate_factors_pvt.okl_lrvv_rec;
    ddp_lrfv_tbl okl_lease_rate_factors_pvt.lrfv_tbl_type;
    ddx_lrfv_tbl okl_lease_rate_factors_pvt.lrfv_tbl_type;
    ddp_lrlv_tbl okl_lease_rate_factors_pvt.okl_lrlv_tbl;
    ddx_lrlv_tbl okl_lease_rate_factors_pvt.okl_lrlv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lrtv_rec.id := p5_a0;
    ddp_lrtv_rec.object_version_number := p5_a1;
    ddp_lrtv_rec.sfwt_flag := p5_a2;
    ddp_lrtv_rec.try_id := p5_a3;
    ddp_lrtv_rec.pdt_id := p5_a4;
    ddp_lrtv_rec.rate := p5_a5;
    ddp_lrtv_rec.frq_code := p5_a6;
    ddp_lrtv_rec.arrears_yn := p5_a7;
    ddp_lrtv_rec.start_date := p5_a8;
    ddp_lrtv_rec.end_date := p5_a9;
    ddp_lrtv_rec.name := p5_a10;
    ddp_lrtv_rec.description := p5_a11;
    ddp_lrtv_rec.created_by := p5_a12;
    ddp_lrtv_rec.creation_date := p5_a13;
    ddp_lrtv_rec.last_updated_by := p5_a14;
    ddp_lrtv_rec.last_update_date := p5_a15;
    ddp_lrtv_rec.last_update_login := p5_a16;
    ddp_lrtv_rec.attribute_category := p5_a17;
    ddp_lrtv_rec.attribute1 := p5_a18;
    ddp_lrtv_rec.attribute2 := p5_a19;
    ddp_lrtv_rec.attribute3 := p5_a20;
    ddp_lrtv_rec.attribute4 := p5_a21;
    ddp_lrtv_rec.attribute5 := p5_a22;
    ddp_lrtv_rec.attribute6 := p5_a23;
    ddp_lrtv_rec.attribute7 := p5_a24;
    ddp_lrtv_rec.attribute8 := p5_a25;
    ddp_lrtv_rec.attribute9 := p5_a26;
    ddp_lrtv_rec.attribute10 := p5_a27;
    ddp_lrtv_rec.attribute11 := p5_a28;
    ddp_lrtv_rec.attribute12 := p5_a29;
    ddp_lrtv_rec.attribute13 := p5_a30;
    ddp_lrtv_rec.attribute14 := p5_a31;
    ddp_lrtv_rec.attribute15 := p5_a32;
    ddp_lrtv_rec.sts_code := p5_a33;
    ddp_lrtv_rec.org_id := p5_a34;
    ddp_lrtv_rec.currency_code := p5_a35;
    ddp_lrtv_rec.lrs_type_code := p5_a36;
    ddp_lrtv_rec.end_of_term_id := p5_a37;
    ddp_lrtv_rec.orig_rate_set_id := p5_a38;

    ddp_lrvv_rec.rate_set_version_id := p6_a0;
    ddp_lrvv_rec.object_version_number := p6_a1;
    ddp_lrvv_rec.arrears_yn := p6_a2;
    ddp_lrvv_rec.effective_from_date := p6_a3;
    ddp_lrvv_rec.effective_to_date := p6_a4;
    ddp_lrvv_rec.rate_set_id := p6_a5;
    ddp_lrvv_rec.end_of_term_ver_id := p6_a6;
    ddp_lrvv_rec.std_rate_tmpl_ver_id := p6_a7;
    ddp_lrvv_rec.adj_mat_version_id := p6_a8;
    ddp_lrvv_rec.version_number := p6_a9;
    ddp_lrvv_rec.lrs_rate := p6_a10;
    ddp_lrvv_rec.rate_tolerance := p6_a11;
    ddp_lrvv_rec.residual_tolerance := p6_a12;
    ddp_lrvv_rec.deferred_pmts := p6_a13;
    ddp_lrvv_rec.advance_pmts := p6_a14;
    ddp_lrvv_rec.sts_code := p6_a15;
    ddp_lrvv_rec.created_by := p6_a16;
    ddp_lrvv_rec.creation_date := p6_a17;
    ddp_lrvv_rec.last_updated_by := p6_a18;
    ddp_lrvv_rec.last_update_date := p6_a19;
    ddp_lrvv_rec.last_update_login := p6_a20;
    ddp_lrvv_rec.attribute_category := p6_a21;
    ddp_lrvv_rec.attribute1 := p6_a22;
    ddp_lrvv_rec.attribute2 := p6_a23;
    ddp_lrvv_rec.attribute3 := p6_a24;
    ddp_lrvv_rec.attribute4 := p6_a25;
    ddp_lrvv_rec.attribute5 := p6_a26;
    ddp_lrvv_rec.attribute6 := p6_a27;
    ddp_lrvv_rec.attribute7 := p6_a28;
    ddp_lrvv_rec.attribute8 := p6_a29;
    ddp_lrvv_rec.attribute9 := p6_a30;
    ddp_lrvv_rec.attribute10 := p6_a31;
    ddp_lrvv_rec.attribute11 := p6_a32;
    ddp_lrvv_rec.attribute12 := p6_a33;
    ddp_lrvv_rec.attribute13 := p6_a34;
    ddp_lrvv_rec.attribute14 := p6_a35;
    ddp_lrvv_rec.attribute15 := p6_a36;
    ddp_lrvv_rec.standard_rate := p6_a37;

    okl_lrf_pvt_w.rosetta_table_copy_in_p28(ddp_lrfv_tbl, p7_a0
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
      );


    okl_lrl_pvt_w.rosetta_table_copy_in_p1(ddp_lrlv_tbl, p9_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lease_rate_factors_pvt.handle_lrf_submit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lrtv_rec,
      ddp_lrvv_rec,
      ddp_lrfv_tbl,
      ddx_lrfv_tbl,
      ddp_lrlv_tbl,
      ddx_lrlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_lrf_pvt_w.rosetta_table_copy_out_p28(ddx_lrfv_tbl, p8_a0
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
      );


    okl_lrl_pvt_w.rosetta_table_copy_out_p1(ddx_lrlv_tbl, p10_a0
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
      );
  end;

end okl_lease_rate_factors_pvt_w;

/
