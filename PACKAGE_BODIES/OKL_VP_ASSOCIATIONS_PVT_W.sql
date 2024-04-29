--------------------------------------------------------
--  DDL for Package Body OKL_VP_ASSOCIATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_ASSOCIATIONS_PVT_W" as
  /* $Header: OKLEVASB.pls 120.1 2005/10/30 04:58:05 appldev noship $ */
  procedure create_vp_associations(p_api_version  NUMBER
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
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  DATE
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
  )

  as
    ddp_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddx_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vasv_rec.id := p5_a0;
    ddp_vasv_rec.chr_id := p5_a1;
    ddp_vasv_rec.crs_id := p5_a2;
    ddp_vasv_rec.object_version_number := p5_a3;
    ddp_vasv_rec.start_date := p5_a4;
    ddp_vasv_rec.end_date := p5_a5;
    ddp_vasv_rec.description := p5_a6;
    ddp_vasv_rec.assoc_object_type_code := p5_a7;
    ddp_vasv_rec.assoc_object_id := p5_a8;
    ddp_vasv_rec.assoc_object_version := p5_a9;
    ddp_vasv_rec.attribute_category := p5_a10;
    ddp_vasv_rec.attribute1 := p5_a11;
    ddp_vasv_rec.attribute2 := p5_a12;
    ddp_vasv_rec.attribute3 := p5_a13;
    ddp_vasv_rec.attribute4 := p5_a14;
    ddp_vasv_rec.attribute5 := p5_a15;
    ddp_vasv_rec.attribute6 := p5_a16;
    ddp_vasv_rec.attribute7 := p5_a17;
    ddp_vasv_rec.attribute8 := p5_a18;
    ddp_vasv_rec.attribute9 := p5_a19;
    ddp_vasv_rec.attribute10 := p5_a20;
    ddp_vasv_rec.attribute11 := p5_a21;
    ddp_vasv_rec.attribute12 := p5_a22;
    ddp_vasv_rec.attribute13 := p5_a23;
    ddp_vasv_rec.attribute14 := p5_a24;
    ddp_vasv_rec.attribute15 := p5_a25;
    ddp_vasv_rec.request_id := p5_a26;
    ddp_vasv_rec.program_application_id := p5_a27;
    ddp_vasv_rec.program_id := p5_a28;
    ddp_vasv_rec.program_update_date := p5_a29;
    ddp_vasv_rec.created_by := p5_a30;
    ddp_vasv_rec.creation_date := p5_a31;
    ddp_vasv_rec.last_updated_by := p5_a32;
    ddp_vasv_rec.last_update_date := p5_a33;
    ddp_vasv_rec.last_update_login := p5_a34;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.create_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_rec,
      ddx_vasv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_vasv_rec.id;
    p6_a1 := ddx_vasv_rec.chr_id;
    p6_a2 := ddx_vasv_rec.crs_id;
    p6_a3 := ddx_vasv_rec.object_version_number;
    p6_a4 := ddx_vasv_rec.start_date;
    p6_a5 := ddx_vasv_rec.end_date;
    p6_a6 := ddx_vasv_rec.description;
    p6_a7 := ddx_vasv_rec.assoc_object_type_code;
    p6_a8 := ddx_vasv_rec.assoc_object_id;
    p6_a9 := ddx_vasv_rec.assoc_object_version;
    p6_a10 := ddx_vasv_rec.attribute_category;
    p6_a11 := ddx_vasv_rec.attribute1;
    p6_a12 := ddx_vasv_rec.attribute2;
    p6_a13 := ddx_vasv_rec.attribute3;
    p6_a14 := ddx_vasv_rec.attribute4;
    p6_a15 := ddx_vasv_rec.attribute5;
    p6_a16 := ddx_vasv_rec.attribute6;
    p6_a17 := ddx_vasv_rec.attribute7;
    p6_a18 := ddx_vasv_rec.attribute8;
    p6_a19 := ddx_vasv_rec.attribute9;
    p6_a20 := ddx_vasv_rec.attribute10;
    p6_a21 := ddx_vasv_rec.attribute11;
    p6_a22 := ddx_vasv_rec.attribute12;
    p6_a23 := ddx_vasv_rec.attribute13;
    p6_a24 := ddx_vasv_rec.attribute14;
    p6_a25 := ddx_vasv_rec.attribute15;
    p6_a26 := ddx_vasv_rec.request_id;
    p6_a27 := ddx_vasv_rec.program_application_id;
    p6_a28 := ddx_vasv_rec.program_id;
    p6_a29 := ddx_vasv_rec.program_update_date;
    p6_a30 := ddx_vasv_rec.created_by;
    p6_a31 := ddx_vasv_rec.creation_date;
    p6_a32 := ddx_vasv_rec.last_updated_by;
    p6_a33 := ddx_vasv_rec.last_update_date;
    p6_a34 := ddx_vasv_rec.last_update_login;
  end;

  procedure create_vp_associations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
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
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddx_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vas_pvt_w.rosetta_table_copy_in_p2(ddp_vasv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.create_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_tbl,
      ddx_vasv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_vas_pvt_w.rosetta_table_copy_out_p2(ddx_vasv_tbl, p6_a0
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
      );
  end;

  procedure lock_vp_associations(p_api_version  NUMBER
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
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  DATE
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
  )

  as
    ddp_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vasv_rec.id := p5_a0;
    ddp_vasv_rec.chr_id := p5_a1;
    ddp_vasv_rec.crs_id := p5_a2;
    ddp_vasv_rec.object_version_number := p5_a3;
    ddp_vasv_rec.start_date := p5_a4;
    ddp_vasv_rec.end_date := p5_a5;
    ddp_vasv_rec.description := p5_a6;
    ddp_vasv_rec.assoc_object_type_code := p5_a7;
    ddp_vasv_rec.assoc_object_id := p5_a8;
    ddp_vasv_rec.assoc_object_version := p5_a9;
    ddp_vasv_rec.attribute_category := p5_a10;
    ddp_vasv_rec.attribute1 := p5_a11;
    ddp_vasv_rec.attribute2 := p5_a12;
    ddp_vasv_rec.attribute3 := p5_a13;
    ddp_vasv_rec.attribute4 := p5_a14;
    ddp_vasv_rec.attribute5 := p5_a15;
    ddp_vasv_rec.attribute6 := p5_a16;
    ddp_vasv_rec.attribute7 := p5_a17;
    ddp_vasv_rec.attribute8 := p5_a18;
    ddp_vasv_rec.attribute9 := p5_a19;
    ddp_vasv_rec.attribute10 := p5_a20;
    ddp_vasv_rec.attribute11 := p5_a21;
    ddp_vasv_rec.attribute12 := p5_a22;
    ddp_vasv_rec.attribute13 := p5_a23;
    ddp_vasv_rec.attribute14 := p5_a24;
    ddp_vasv_rec.attribute15 := p5_a25;
    ddp_vasv_rec.request_id := p5_a26;
    ddp_vasv_rec.program_application_id := p5_a27;
    ddp_vasv_rec.program_id := p5_a28;
    ddp_vasv_rec.program_update_date := p5_a29;
    ddp_vasv_rec.created_by := p5_a30;
    ddp_vasv_rec.creation_date := p5_a31;
    ddp_vasv_rec.last_updated_by := p5_a32;
    ddp_vasv_rec.last_update_date := p5_a33;
    ddp_vasv_rec.last_update_login := p5_a34;

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.lock_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_vp_associations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
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
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
  )

  as
    ddp_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vas_pvt_w.rosetta_table_copy_in_p2(ddp_vasv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.lock_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_vp_associations(p_api_version  NUMBER
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
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  DATE
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
  )

  as
    ddp_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddx_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vasv_rec.id := p5_a0;
    ddp_vasv_rec.chr_id := p5_a1;
    ddp_vasv_rec.crs_id := p5_a2;
    ddp_vasv_rec.object_version_number := p5_a3;
    ddp_vasv_rec.start_date := p5_a4;
    ddp_vasv_rec.end_date := p5_a5;
    ddp_vasv_rec.description := p5_a6;
    ddp_vasv_rec.assoc_object_type_code := p5_a7;
    ddp_vasv_rec.assoc_object_id := p5_a8;
    ddp_vasv_rec.assoc_object_version := p5_a9;
    ddp_vasv_rec.attribute_category := p5_a10;
    ddp_vasv_rec.attribute1 := p5_a11;
    ddp_vasv_rec.attribute2 := p5_a12;
    ddp_vasv_rec.attribute3 := p5_a13;
    ddp_vasv_rec.attribute4 := p5_a14;
    ddp_vasv_rec.attribute5 := p5_a15;
    ddp_vasv_rec.attribute6 := p5_a16;
    ddp_vasv_rec.attribute7 := p5_a17;
    ddp_vasv_rec.attribute8 := p5_a18;
    ddp_vasv_rec.attribute9 := p5_a19;
    ddp_vasv_rec.attribute10 := p5_a20;
    ddp_vasv_rec.attribute11 := p5_a21;
    ddp_vasv_rec.attribute12 := p5_a22;
    ddp_vasv_rec.attribute13 := p5_a23;
    ddp_vasv_rec.attribute14 := p5_a24;
    ddp_vasv_rec.attribute15 := p5_a25;
    ddp_vasv_rec.request_id := p5_a26;
    ddp_vasv_rec.program_application_id := p5_a27;
    ddp_vasv_rec.program_id := p5_a28;
    ddp_vasv_rec.program_update_date := p5_a29;
    ddp_vasv_rec.created_by := p5_a30;
    ddp_vasv_rec.creation_date := p5_a31;
    ddp_vasv_rec.last_updated_by := p5_a32;
    ddp_vasv_rec.last_update_date := p5_a33;
    ddp_vasv_rec.last_update_login := p5_a34;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.update_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_rec,
      ddx_vasv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_vasv_rec.id;
    p6_a1 := ddx_vasv_rec.chr_id;
    p6_a2 := ddx_vasv_rec.crs_id;
    p6_a3 := ddx_vasv_rec.object_version_number;
    p6_a4 := ddx_vasv_rec.start_date;
    p6_a5 := ddx_vasv_rec.end_date;
    p6_a6 := ddx_vasv_rec.description;
    p6_a7 := ddx_vasv_rec.assoc_object_type_code;
    p6_a8 := ddx_vasv_rec.assoc_object_id;
    p6_a9 := ddx_vasv_rec.assoc_object_version;
    p6_a10 := ddx_vasv_rec.attribute_category;
    p6_a11 := ddx_vasv_rec.attribute1;
    p6_a12 := ddx_vasv_rec.attribute2;
    p6_a13 := ddx_vasv_rec.attribute3;
    p6_a14 := ddx_vasv_rec.attribute4;
    p6_a15 := ddx_vasv_rec.attribute5;
    p6_a16 := ddx_vasv_rec.attribute6;
    p6_a17 := ddx_vasv_rec.attribute7;
    p6_a18 := ddx_vasv_rec.attribute8;
    p6_a19 := ddx_vasv_rec.attribute9;
    p6_a20 := ddx_vasv_rec.attribute10;
    p6_a21 := ddx_vasv_rec.attribute11;
    p6_a22 := ddx_vasv_rec.attribute12;
    p6_a23 := ddx_vasv_rec.attribute13;
    p6_a24 := ddx_vasv_rec.attribute14;
    p6_a25 := ddx_vasv_rec.attribute15;
    p6_a26 := ddx_vasv_rec.request_id;
    p6_a27 := ddx_vasv_rec.program_application_id;
    p6_a28 := ddx_vasv_rec.program_id;
    p6_a29 := ddx_vasv_rec.program_update_date;
    p6_a30 := ddx_vasv_rec.created_by;
    p6_a31 := ddx_vasv_rec.creation_date;
    p6_a32 := ddx_vasv_rec.last_updated_by;
    p6_a33 := ddx_vasv_rec.last_update_date;
    p6_a34 := ddx_vasv_rec.last_update_login;
  end;

  procedure update_vp_associations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
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
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddx_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vas_pvt_w.rosetta_table_copy_in_p2(ddp_vasv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.update_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_tbl,
      ddx_vasv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_vas_pvt_w.rosetta_table_copy_out_p2(ddx_vasv_tbl, p6_a0
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
      );
  end;

  procedure delete_vp_associations(p_api_version  NUMBER
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
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  DATE
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
  )

  as
    ddp_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vasv_rec.id := p5_a0;
    ddp_vasv_rec.chr_id := p5_a1;
    ddp_vasv_rec.crs_id := p5_a2;
    ddp_vasv_rec.object_version_number := p5_a3;
    ddp_vasv_rec.start_date := p5_a4;
    ddp_vasv_rec.end_date := p5_a5;
    ddp_vasv_rec.description := p5_a6;
    ddp_vasv_rec.assoc_object_type_code := p5_a7;
    ddp_vasv_rec.assoc_object_id := p5_a8;
    ddp_vasv_rec.assoc_object_version := p5_a9;
    ddp_vasv_rec.attribute_category := p5_a10;
    ddp_vasv_rec.attribute1 := p5_a11;
    ddp_vasv_rec.attribute2 := p5_a12;
    ddp_vasv_rec.attribute3 := p5_a13;
    ddp_vasv_rec.attribute4 := p5_a14;
    ddp_vasv_rec.attribute5 := p5_a15;
    ddp_vasv_rec.attribute6 := p5_a16;
    ddp_vasv_rec.attribute7 := p5_a17;
    ddp_vasv_rec.attribute8 := p5_a18;
    ddp_vasv_rec.attribute9 := p5_a19;
    ddp_vasv_rec.attribute10 := p5_a20;
    ddp_vasv_rec.attribute11 := p5_a21;
    ddp_vasv_rec.attribute12 := p5_a22;
    ddp_vasv_rec.attribute13 := p5_a23;
    ddp_vasv_rec.attribute14 := p5_a24;
    ddp_vasv_rec.attribute15 := p5_a25;
    ddp_vasv_rec.request_id := p5_a26;
    ddp_vasv_rec.program_application_id := p5_a27;
    ddp_vasv_rec.program_id := p5_a28;
    ddp_vasv_rec.program_update_date := p5_a29;
    ddp_vasv_rec.created_by := p5_a30;
    ddp_vasv_rec.creation_date := p5_a31;
    ddp_vasv_rec.last_updated_by := p5_a32;
    ddp_vasv_rec.last_update_date := p5_a33;
    ddp_vasv_rec.last_update_login := p5_a34;

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.delete_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_vp_associations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
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
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
  )

  as
    ddp_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vas_pvt_w.rosetta_table_copy_in_p2(ddp_vasv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.delete_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_vp_associations(p_api_version  NUMBER
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
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  DATE
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
  )

  as
    ddp_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vasv_rec.id := p5_a0;
    ddp_vasv_rec.chr_id := p5_a1;
    ddp_vasv_rec.crs_id := p5_a2;
    ddp_vasv_rec.object_version_number := p5_a3;
    ddp_vasv_rec.start_date := p5_a4;
    ddp_vasv_rec.end_date := p5_a5;
    ddp_vasv_rec.description := p5_a6;
    ddp_vasv_rec.assoc_object_type_code := p5_a7;
    ddp_vasv_rec.assoc_object_id := p5_a8;
    ddp_vasv_rec.assoc_object_version := p5_a9;
    ddp_vasv_rec.attribute_category := p5_a10;
    ddp_vasv_rec.attribute1 := p5_a11;
    ddp_vasv_rec.attribute2 := p5_a12;
    ddp_vasv_rec.attribute3 := p5_a13;
    ddp_vasv_rec.attribute4 := p5_a14;
    ddp_vasv_rec.attribute5 := p5_a15;
    ddp_vasv_rec.attribute6 := p5_a16;
    ddp_vasv_rec.attribute7 := p5_a17;
    ddp_vasv_rec.attribute8 := p5_a18;
    ddp_vasv_rec.attribute9 := p5_a19;
    ddp_vasv_rec.attribute10 := p5_a20;
    ddp_vasv_rec.attribute11 := p5_a21;
    ddp_vasv_rec.attribute12 := p5_a22;
    ddp_vasv_rec.attribute13 := p5_a23;
    ddp_vasv_rec.attribute14 := p5_a24;
    ddp_vasv_rec.attribute15 := p5_a25;
    ddp_vasv_rec.request_id := p5_a26;
    ddp_vasv_rec.program_application_id := p5_a27;
    ddp_vasv_rec.program_id := p5_a28;
    ddp_vasv_rec.program_update_date := p5_a29;
    ddp_vasv_rec.created_by := p5_a30;
    ddp_vasv_rec.creation_date := p5_a31;
    ddp_vasv_rec.last_updated_by := p5_a32;
    ddp_vasv_rec.last_update_date := p5_a33;
    ddp_vasv_rec.last_update_login := p5_a34;

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.validate_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_vp_associations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
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
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
  )

  as
    ddp_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vas_pvt_w.rosetta_table_copy_in_p2(ddp_vasv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.validate_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure copy_vp_associations(p_api_version  NUMBER
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
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  DATE
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
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
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
  )

  as
    ddp_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddx_vasv_rec okl_vp_associations_pvt.vasv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vasv_rec.id := p5_a0;
    ddp_vasv_rec.chr_id := p5_a1;
    ddp_vasv_rec.crs_id := p5_a2;
    ddp_vasv_rec.object_version_number := p5_a3;
    ddp_vasv_rec.start_date := p5_a4;
    ddp_vasv_rec.end_date := p5_a5;
    ddp_vasv_rec.description := p5_a6;
    ddp_vasv_rec.assoc_object_type_code := p5_a7;
    ddp_vasv_rec.assoc_object_id := p5_a8;
    ddp_vasv_rec.assoc_object_version := p5_a9;
    ddp_vasv_rec.attribute_category := p5_a10;
    ddp_vasv_rec.attribute1 := p5_a11;
    ddp_vasv_rec.attribute2 := p5_a12;
    ddp_vasv_rec.attribute3 := p5_a13;
    ddp_vasv_rec.attribute4 := p5_a14;
    ddp_vasv_rec.attribute5 := p5_a15;
    ddp_vasv_rec.attribute6 := p5_a16;
    ddp_vasv_rec.attribute7 := p5_a17;
    ddp_vasv_rec.attribute8 := p5_a18;
    ddp_vasv_rec.attribute9 := p5_a19;
    ddp_vasv_rec.attribute10 := p5_a20;
    ddp_vasv_rec.attribute11 := p5_a21;
    ddp_vasv_rec.attribute12 := p5_a22;
    ddp_vasv_rec.attribute13 := p5_a23;
    ddp_vasv_rec.attribute14 := p5_a24;
    ddp_vasv_rec.attribute15 := p5_a25;
    ddp_vasv_rec.request_id := p5_a26;
    ddp_vasv_rec.program_application_id := p5_a27;
    ddp_vasv_rec.program_id := p5_a28;
    ddp_vasv_rec.program_update_date := p5_a29;
    ddp_vasv_rec.created_by := p5_a30;
    ddp_vasv_rec.creation_date := p5_a31;
    ddp_vasv_rec.last_updated_by := p5_a32;
    ddp_vasv_rec.last_update_date := p5_a33;
    ddp_vasv_rec.last_update_login := p5_a34;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.copy_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_rec,
      ddx_vasv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_vasv_rec.id;
    p6_a1 := ddx_vasv_rec.chr_id;
    p6_a2 := ddx_vasv_rec.crs_id;
    p6_a3 := ddx_vasv_rec.object_version_number;
    p6_a4 := ddx_vasv_rec.start_date;
    p6_a5 := ddx_vasv_rec.end_date;
    p6_a6 := ddx_vasv_rec.description;
    p6_a7 := ddx_vasv_rec.assoc_object_type_code;
    p6_a8 := ddx_vasv_rec.assoc_object_id;
    p6_a9 := ddx_vasv_rec.assoc_object_version;
    p6_a10 := ddx_vasv_rec.attribute_category;
    p6_a11 := ddx_vasv_rec.attribute1;
    p6_a12 := ddx_vasv_rec.attribute2;
    p6_a13 := ddx_vasv_rec.attribute3;
    p6_a14 := ddx_vasv_rec.attribute4;
    p6_a15 := ddx_vasv_rec.attribute5;
    p6_a16 := ddx_vasv_rec.attribute6;
    p6_a17 := ddx_vasv_rec.attribute7;
    p6_a18 := ddx_vasv_rec.attribute8;
    p6_a19 := ddx_vasv_rec.attribute9;
    p6_a20 := ddx_vasv_rec.attribute10;
    p6_a21 := ddx_vasv_rec.attribute11;
    p6_a22 := ddx_vasv_rec.attribute12;
    p6_a23 := ddx_vasv_rec.attribute13;
    p6_a24 := ddx_vasv_rec.attribute14;
    p6_a25 := ddx_vasv_rec.attribute15;
    p6_a26 := ddx_vasv_rec.request_id;
    p6_a27 := ddx_vasv_rec.program_application_id;
    p6_a28 := ddx_vasv_rec.program_id;
    p6_a29 := ddx_vasv_rec.program_update_date;
    p6_a30 := ddx_vasv_rec.created_by;
    p6_a31 := ddx_vasv_rec.creation_date;
    p6_a32 := ddx_vasv_rec.last_updated_by;
    p6_a33 := ddx_vasv_rec.last_update_date;
    p6_a34 := ddx_vasv_rec.last_update_login;
  end;

  procedure copy_vp_associations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_500
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
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddx_vasv_tbl okl_vp_associations_pvt.vasv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vas_pvt_w.rosetta_table_copy_in_p2(ddp_vasv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_associations_pvt.copy_vp_associations(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vasv_tbl,
      ddx_vasv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_vas_pvt_w.rosetta_table_copy_out_p2(ddx_vasv_tbl, p6_a0
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
      );
  end;

end okl_vp_associations_pvt_w;

/
