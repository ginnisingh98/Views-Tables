--------------------------------------------------------
--  DDL for Package Body OKL_VALIDATION_SET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VALIDATION_SET_PVT_W" as
  /* $Header: OKLEVLSB.pls 120.3 2005/09/20 06:24:41 ssdeshpa noship $ */
  procedure create_vls(p_api_version  NUMBER
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
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
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
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_500
    , p7_a4 JTF_VARCHAR2_TABLE_500
    , p7_a5 JTF_VARCHAR2_TABLE_500
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_VARCHAR2_TABLE_100
    , p7_a21 JTF_VARCHAR2_TABLE_300
    , p7_a22 JTF_VARCHAR2_TABLE_2000
    , p7_a23 JTF_VARCHAR2_TABLE_2000
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_vlsv_rec okl_validation_set_pvt.vlsv_rec_type;
    ddx_vlsv_rec okl_validation_set_pvt.vlsv_rec_type;
    ddp_vldv_tbl okl_validation_set_pvt.vldv_tbl_type;
    ddx_vldv_tbl okl_validation_set_pvt.vldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vlsv_rec.id := p5_a0;
    ddp_vlsv_rec.object_version_number := p5_a1;
    ddp_vlsv_rec.attribute_category := p5_a2;
    ddp_vlsv_rec.attribute1 := p5_a3;
    ddp_vlsv_rec.attribute2 := p5_a4;
    ddp_vlsv_rec.attribute3 := p5_a5;
    ddp_vlsv_rec.attribute4 := p5_a6;
    ddp_vlsv_rec.attribute5 := p5_a7;
    ddp_vlsv_rec.attribute6 := p5_a8;
    ddp_vlsv_rec.attribute7 := p5_a9;
    ddp_vlsv_rec.attribute8 := p5_a10;
    ddp_vlsv_rec.attribute9 := p5_a11;
    ddp_vlsv_rec.attribute10 := p5_a12;
    ddp_vlsv_rec.attribute11 := p5_a13;
    ddp_vlsv_rec.attribute12 := p5_a14;
    ddp_vlsv_rec.attribute13 := p5_a15;
    ddp_vlsv_rec.attribute14 := p5_a16;
    ddp_vlsv_rec.attribute15 := p5_a17;
    ddp_vlsv_rec.org_id := p5_a18;
    ddp_vlsv_rec.validation_set_name := p5_a19;
    ddp_vlsv_rec.effective_from := p5_a20;
    ddp_vlsv_rec.effective_to := p5_a21;
    ddp_vlsv_rec.short_description := p5_a22;
    ddp_vlsv_rec.description := p5_a23;
    ddp_vlsv_rec.comments := p5_a24;


    okl_vld_pvt_w.rosetta_table_copy_in_p23(ddp_vldv_tbl, p7_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_validation_set_pvt.create_vls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vlsv_rec,
      ddx_vlsv_rec,
      ddp_vldv_tbl,
      ddx_vldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_vlsv_rec.id;
    p6_a1 := ddx_vlsv_rec.object_version_number;
    p6_a2 := ddx_vlsv_rec.attribute_category;
    p6_a3 := ddx_vlsv_rec.attribute1;
    p6_a4 := ddx_vlsv_rec.attribute2;
    p6_a5 := ddx_vlsv_rec.attribute3;
    p6_a6 := ddx_vlsv_rec.attribute4;
    p6_a7 := ddx_vlsv_rec.attribute5;
    p6_a8 := ddx_vlsv_rec.attribute6;
    p6_a9 := ddx_vlsv_rec.attribute7;
    p6_a10 := ddx_vlsv_rec.attribute8;
    p6_a11 := ddx_vlsv_rec.attribute9;
    p6_a12 := ddx_vlsv_rec.attribute10;
    p6_a13 := ddx_vlsv_rec.attribute11;
    p6_a14 := ddx_vlsv_rec.attribute12;
    p6_a15 := ddx_vlsv_rec.attribute13;
    p6_a16 := ddx_vlsv_rec.attribute14;
    p6_a17 := ddx_vlsv_rec.attribute15;
    p6_a18 := ddx_vlsv_rec.org_id;
    p6_a19 := ddx_vlsv_rec.validation_set_name;
    p6_a20 := ddx_vlsv_rec.effective_from;
    p6_a21 := ddx_vlsv_rec.effective_to;
    p6_a22 := ddx_vlsv_rec.short_description;
    p6_a23 := ddx_vlsv_rec.description;
    p6_a24 := ddx_vlsv_rec.comments;


    okl_vld_pvt_w.rosetta_table_copy_out_p23(ddx_vldv_tbl, p8_a0
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
      );
  end;

  procedure update_vls(p_api_version  NUMBER
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
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
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
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_500
    , p7_a4 JTF_VARCHAR2_TABLE_500
    , p7_a5 JTF_VARCHAR2_TABLE_500
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_VARCHAR2_TABLE_100
    , p7_a21 JTF_VARCHAR2_TABLE_300
    , p7_a22 JTF_VARCHAR2_TABLE_2000
    , p7_a23 JTF_VARCHAR2_TABLE_2000
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_vlsv_rec okl_validation_set_pvt.vlsv_rec_type;
    ddx_vlsv_rec okl_validation_set_pvt.vlsv_rec_type;
    ddp_vldv_tbl okl_validation_set_pvt.vldv_tbl_type;
    ddx_vldv_tbl okl_validation_set_pvt.vldv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vlsv_rec.id := p5_a0;
    ddp_vlsv_rec.object_version_number := p5_a1;
    ddp_vlsv_rec.attribute_category := p5_a2;
    ddp_vlsv_rec.attribute1 := p5_a3;
    ddp_vlsv_rec.attribute2 := p5_a4;
    ddp_vlsv_rec.attribute3 := p5_a5;
    ddp_vlsv_rec.attribute4 := p5_a6;
    ddp_vlsv_rec.attribute5 := p5_a7;
    ddp_vlsv_rec.attribute6 := p5_a8;
    ddp_vlsv_rec.attribute7 := p5_a9;
    ddp_vlsv_rec.attribute8 := p5_a10;
    ddp_vlsv_rec.attribute9 := p5_a11;
    ddp_vlsv_rec.attribute10 := p5_a12;
    ddp_vlsv_rec.attribute11 := p5_a13;
    ddp_vlsv_rec.attribute12 := p5_a14;
    ddp_vlsv_rec.attribute13 := p5_a15;
    ddp_vlsv_rec.attribute14 := p5_a16;
    ddp_vlsv_rec.attribute15 := p5_a17;
    ddp_vlsv_rec.org_id := p5_a18;
    ddp_vlsv_rec.validation_set_name := p5_a19;
    ddp_vlsv_rec.effective_from := p5_a20;
    ddp_vlsv_rec.effective_to := p5_a21;
    ddp_vlsv_rec.short_description := p5_a22;
    ddp_vlsv_rec.description := p5_a23;
    ddp_vlsv_rec.comments := p5_a24;


    okl_vld_pvt_w.rosetta_table_copy_in_p23(ddp_vldv_tbl, p7_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_validation_set_pvt.update_vls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vlsv_rec,
      ddx_vlsv_rec,
      ddp_vldv_tbl,
      ddx_vldv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_vlsv_rec.id;
    p6_a1 := ddx_vlsv_rec.object_version_number;
    p6_a2 := ddx_vlsv_rec.attribute_category;
    p6_a3 := ddx_vlsv_rec.attribute1;
    p6_a4 := ddx_vlsv_rec.attribute2;
    p6_a5 := ddx_vlsv_rec.attribute3;
    p6_a6 := ddx_vlsv_rec.attribute4;
    p6_a7 := ddx_vlsv_rec.attribute5;
    p6_a8 := ddx_vlsv_rec.attribute6;
    p6_a9 := ddx_vlsv_rec.attribute7;
    p6_a10 := ddx_vlsv_rec.attribute8;
    p6_a11 := ddx_vlsv_rec.attribute9;
    p6_a12 := ddx_vlsv_rec.attribute10;
    p6_a13 := ddx_vlsv_rec.attribute11;
    p6_a14 := ddx_vlsv_rec.attribute12;
    p6_a15 := ddx_vlsv_rec.attribute13;
    p6_a16 := ddx_vlsv_rec.attribute14;
    p6_a17 := ddx_vlsv_rec.attribute15;
    p6_a18 := ddx_vlsv_rec.org_id;
    p6_a19 := ddx_vlsv_rec.validation_set_name;
    p6_a20 := ddx_vlsv_rec.effective_from;
    p6_a21 := ddx_vlsv_rec.effective_to;
    p6_a22 := ddx_vlsv_rec.short_description;
    p6_a23 := ddx_vlsv_rec.description;
    p6_a24 := ddx_vlsv_rec.comments;


    okl_vld_pvt_w.rosetta_table_copy_out_p23(ddx_vldv_tbl, p8_a0
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
      );
  end;

  procedure delete_vls(p_api_version  NUMBER
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
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
  )

  as
    ddp_vlsv_rec okl_validation_set_pvt.vlsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vlsv_rec.id := p5_a0;
    ddp_vlsv_rec.object_version_number := p5_a1;
    ddp_vlsv_rec.attribute_category := p5_a2;
    ddp_vlsv_rec.attribute1 := p5_a3;
    ddp_vlsv_rec.attribute2 := p5_a4;
    ddp_vlsv_rec.attribute3 := p5_a5;
    ddp_vlsv_rec.attribute4 := p5_a6;
    ddp_vlsv_rec.attribute5 := p5_a7;
    ddp_vlsv_rec.attribute6 := p5_a8;
    ddp_vlsv_rec.attribute7 := p5_a9;
    ddp_vlsv_rec.attribute8 := p5_a10;
    ddp_vlsv_rec.attribute9 := p5_a11;
    ddp_vlsv_rec.attribute10 := p5_a12;
    ddp_vlsv_rec.attribute11 := p5_a13;
    ddp_vlsv_rec.attribute12 := p5_a14;
    ddp_vlsv_rec.attribute13 := p5_a15;
    ddp_vlsv_rec.attribute14 := p5_a16;
    ddp_vlsv_rec.attribute15 := p5_a17;
    ddp_vlsv_rec.org_id := p5_a18;
    ddp_vlsv_rec.validation_set_name := p5_a19;
    ddp_vlsv_rec.effective_from := p5_a20;
    ddp_vlsv_rec.effective_to := p5_a21;
    ddp_vlsv_rec.short_description := p5_a22;
    ddp_vlsv_rec.description := p5_a23;
    ddp_vlsv_rec.comments := p5_a24;

    -- here's the delegated call to the old PL/SQL routine
    okl_validation_set_pvt.delete_vls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vlsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_vld(p_api_version  NUMBER
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
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  NUMBER
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
  )

  as
    ddp_vldv_rec okl_validation_set_pvt.vldv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vldv_rec.id := p5_a0;
    ddp_vldv_rec.object_version_number := p5_a1;
    ddp_vldv_rec.attribute_category := p5_a2;
    ddp_vldv_rec.attribute1 := p5_a3;
    ddp_vldv_rec.attribute2 := p5_a4;
    ddp_vldv_rec.attribute3 := p5_a5;
    ddp_vldv_rec.attribute4 := p5_a6;
    ddp_vldv_rec.attribute5 := p5_a7;
    ddp_vldv_rec.attribute6 := p5_a8;
    ddp_vldv_rec.attribute7 := p5_a9;
    ddp_vldv_rec.attribute8 := p5_a10;
    ddp_vldv_rec.attribute9 := p5_a11;
    ddp_vldv_rec.attribute10 := p5_a12;
    ddp_vldv_rec.attribute11 := p5_a13;
    ddp_vldv_rec.attribute12 := p5_a14;
    ddp_vldv_rec.attribute13 := p5_a15;
    ddp_vldv_rec.attribute14 := p5_a16;
    ddp_vldv_rec.attribute15 := p5_a17;
    ddp_vldv_rec.validation_set_id := p5_a18;
    ddp_vldv_rec.function_id := p5_a19;
    ddp_vldv_rec.failure_severity := p5_a20;
    ddp_vldv_rec.short_description := p5_a21;
    ddp_vldv_rec.description := p5_a22;
    ddp_vldv_rec.comments := p5_a23;

    -- here's the delegated call to the old PL/SQL routine
    okl_validation_set_pvt.delete_vld(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vldv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  function validate_header(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
  ) return varchar2

  as
    ddp_vlsv_rec okl_validation_set_pvt.vlsv_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval varchar2(4000);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_vlsv_rec.id := p0_a0;
    ddp_vlsv_rec.object_version_number := p0_a1;
    ddp_vlsv_rec.attribute_category := p0_a2;
    ddp_vlsv_rec.attribute1 := p0_a3;
    ddp_vlsv_rec.attribute2 := p0_a4;
    ddp_vlsv_rec.attribute3 := p0_a5;
    ddp_vlsv_rec.attribute4 := p0_a6;
    ddp_vlsv_rec.attribute5 := p0_a7;
    ddp_vlsv_rec.attribute6 := p0_a8;
    ddp_vlsv_rec.attribute7 := p0_a9;
    ddp_vlsv_rec.attribute8 := p0_a10;
    ddp_vlsv_rec.attribute9 := p0_a11;
    ddp_vlsv_rec.attribute10 := p0_a12;
    ddp_vlsv_rec.attribute11 := p0_a13;
    ddp_vlsv_rec.attribute12 := p0_a14;
    ddp_vlsv_rec.attribute13 := p0_a15;
    ddp_vlsv_rec.attribute14 := p0_a16;
    ddp_vlsv_rec.attribute15 := p0_a17;
    ddp_vlsv_rec.org_id := p0_a18;
    ddp_vlsv_rec.validation_set_name := p0_a19;
    ddp_vlsv_rec.effective_from := p0_a20;
    ddp_vlsv_rec.effective_to := p0_a21;
    ddp_vlsv_rec.short_description := p0_a22;
    ddp_vlsv_rec.description := p0_a23;
    ddp_vlsv_rec.comments := p0_a24;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_validation_set_pvt.validate_header(ddp_vlsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    return ddrosetta_retval;
  end;

end okl_validation_set_pvt_w;

/
