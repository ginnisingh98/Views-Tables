--------------------------------------------------------
--  DDL for Package Body OKL_VP_CHANGE_REQUEST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_CHANGE_REQUEST_PVT_W" as
  /* $Header: OKLEVCRB.pls 120.0 2005/08/03 07:55:22 sjalasut noship $ */
  procedure create_change_request_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  DATE
    , p5_a7  DATE
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  DATE
    , p5_a11  DATE
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
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
    , p5_a35  DATE
    , p5_a36  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
  )

  as
    ddp_vcrv_rec okl_vp_change_request_pvt.vcrv_rec_type;
    ddx_vcrv_rec okl_vp_change_request_pvt.vcrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vcrv_rec.id := p5_a0;
    ddp_vcrv_rec.object_version_number := p5_a1;
    ddp_vcrv_rec.change_request_number := p5_a2;
    ddp_vcrv_rec.chr_id := p5_a3;
    ddp_vcrv_rec.change_type_code := p5_a4;
    ddp_vcrv_rec.status_code := p5_a5;
    ddp_vcrv_rec.request_date := p5_a6;
    ddp_vcrv_rec.effective_date := p5_a7;
    ddp_vcrv_rec.approved_date := p5_a8;
    ddp_vcrv_rec.rejected_date := p5_a9;
    ddp_vcrv_rec.ineffective_date := p5_a10;
    ddp_vcrv_rec.applied_date := p5_a11;
    ddp_vcrv_rec.attribute_category := p5_a12;
    ddp_vcrv_rec.attribute1 := p5_a13;
    ddp_vcrv_rec.attribute2 := p5_a14;
    ddp_vcrv_rec.attribute3 := p5_a15;
    ddp_vcrv_rec.attribute4 := p5_a16;
    ddp_vcrv_rec.attribute5 := p5_a17;
    ddp_vcrv_rec.attribute6 := p5_a18;
    ddp_vcrv_rec.attribute7 := p5_a19;
    ddp_vcrv_rec.attribute8 := p5_a20;
    ddp_vcrv_rec.attribute9 := p5_a21;
    ddp_vcrv_rec.attribute10 := p5_a22;
    ddp_vcrv_rec.attribute11 := p5_a23;
    ddp_vcrv_rec.attribute12 := p5_a24;
    ddp_vcrv_rec.attribute13 := p5_a25;
    ddp_vcrv_rec.attribute14 := p5_a26;
    ddp_vcrv_rec.attribute15 := p5_a27;
    ddp_vcrv_rec.request_id := p5_a28;
    ddp_vcrv_rec.program_application_id := p5_a29;
    ddp_vcrv_rec.program_id := p5_a30;
    ddp_vcrv_rec.program_update_date := p5_a31;
    ddp_vcrv_rec.created_by := p5_a32;
    ddp_vcrv_rec.creation_date := p5_a33;
    ddp_vcrv_rec.last_updated_by := p5_a34;
    ddp_vcrv_rec.last_update_date := p5_a35;
    ddp_vcrv_rec.last_update_login := p5_a36;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_change_request_pvt.create_change_request_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vcrv_rec,
      ddx_vcrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_vcrv_rec.id;
    p6_a1 := ddx_vcrv_rec.object_version_number;
    p6_a2 := ddx_vcrv_rec.change_request_number;
    p6_a3 := ddx_vcrv_rec.chr_id;
    p6_a4 := ddx_vcrv_rec.change_type_code;
    p6_a5 := ddx_vcrv_rec.status_code;
    p6_a6 := ddx_vcrv_rec.request_date;
    p6_a7 := ddx_vcrv_rec.effective_date;
    p6_a8 := ddx_vcrv_rec.approved_date;
    p6_a9 := ddx_vcrv_rec.rejected_date;
    p6_a10 := ddx_vcrv_rec.ineffective_date;
    p6_a11 := ddx_vcrv_rec.applied_date;
    p6_a12 := ddx_vcrv_rec.attribute_category;
    p6_a13 := ddx_vcrv_rec.attribute1;
    p6_a14 := ddx_vcrv_rec.attribute2;
    p6_a15 := ddx_vcrv_rec.attribute3;
    p6_a16 := ddx_vcrv_rec.attribute4;
    p6_a17 := ddx_vcrv_rec.attribute5;
    p6_a18 := ddx_vcrv_rec.attribute6;
    p6_a19 := ddx_vcrv_rec.attribute7;
    p6_a20 := ddx_vcrv_rec.attribute8;
    p6_a21 := ddx_vcrv_rec.attribute9;
    p6_a22 := ddx_vcrv_rec.attribute10;
    p6_a23 := ddx_vcrv_rec.attribute11;
    p6_a24 := ddx_vcrv_rec.attribute12;
    p6_a25 := ddx_vcrv_rec.attribute13;
    p6_a26 := ddx_vcrv_rec.attribute14;
    p6_a27 := ddx_vcrv_rec.attribute15;
    p6_a28 := ddx_vcrv_rec.request_id;
    p6_a29 := ddx_vcrv_rec.program_application_id;
    p6_a30 := ddx_vcrv_rec.program_id;
    p6_a31 := ddx_vcrv_rec.program_update_date;
    p6_a32 := ddx_vcrv_rec.created_by;
    p6_a33 := ddx_vcrv_rec.creation_date;
    p6_a34 := ddx_vcrv_rec.last_updated_by;
    p6_a35 := ddx_vcrv_rec.last_update_date;
    p6_a36 := ddx_vcrv_rec.last_update_login;
  end;

  procedure update_change_request_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  DATE
    , p5_a7  DATE
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  DATE
    , p5_a11  DATE
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
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
    , p5_a35  DATE
    , p5_a36  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
  )

  as
    ddp_vcrv_rec okl_vp_change_request_pvt.vcrv_rec_type;
    ddx_vcrv_rec okl_vp_change_request_pvt.vcrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vcrv_rec.id := p5_a0;
    ddp_vcrv_rec.object_version_number := p5_a1;
    ddp_vcrv_rec.change_request_number := p5_a2;
    ddp_vcrv_rec.chr_id := p5_a3;
    ddp_vcrv_rec.change_type_code := p5_a4;
    ddp_vcrv_rec.status_code := p5_a5;
    ddp_vcrv_rec.request_date := p5_a6;
    ddp_vcrv_rec.effective_date := p5_a7;
    ddp_vcrv_rec.approved_date := p5_a8;
    ddp_vcrv_rec.rejected_date := p5_a9;
    ddp_vcrv_rec.ineffective_date := p5_a10;
    ddp_vcrv_rec.applied_date := p5_a11;
    ddp_vcrv_rec.attribute_category := p5_a12;
    ddp_vcrv_rec.attribute1 := p5_a13;
    ddp_vcrv_rec.attribute2 := p5_a14;
    ddp_vcrv_rec.attribute3 := p5_a15;
    ddp_vcrv_rec.attribute4 := p5_a16;
    ddp_vcrv_rec.attribute5 := p5_a17;
    ddp_vcrv_rec.attribute6 := p5_a18;
    ddp_vcrv_rec.attribute7 := p5_a19;
    ddp_vcrv_rec.attribute8 := p5_a20;
    ddp_vcrv_rec.attribute9 := p5_a21;
    ddp_vcrv_rec.attribute10 := p5_a22;
    ddp_vcrv_rec.attribute11 := p5_a23;
    ddp_vcrv_rec.attribute12 := p5_a24;
    ddp_vcrv_rec.attribute13 := p5_a25;
    ddp_vcrv_rec.attribute14 := p5_a26;
    ddp_vcrv_rec.attribute15 := p5_a27;
    ddp_vcrv_rec.request_id := p5_a28;
    ddp_vcrv_rec.program_application_id := p5_a29;
    ddp_vcrv_rec.program_id := p5_a30;
    ddp_vcrv_rec.program_update_date := p5_a31;
    ddp_vcrv_rec.created_by := p5_a32;
    ddp_vcrv_rec.creation_date := p5_a33;
    ddp_vcrv_rec.last_updated_by := p5_a34;
    ddp_vcrv_rec.last_update_date := p5_a35;
    ddp_vcrv_rec.last_update_login := p5_a36;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_change_request_pvt.update_change_request_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vcrv_rec,
      ddx_vcrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_vcrv_rec.id;
    p6_a1 := ddx_vcrv_rec.object_version_number;
    p6_a2 := ddx_vcrv_rec.change_request_number;
    p6_a3 := ddx_vcrv_rec.chr_id;
    p6_a4 := ddx_vcrv_rec.change_type_code;
    p6_a5 := ddx_vcrv_rec.status_code;
    p6_a6 := ddx_vcrv_rec.request_date;
    p6_a7 := ddx_vcrv_rec.effective_date;
    p6_a8 := ddx_vcrv_rec.approved_date;
    p6_a9 := ddx_vcrv_rec.rejected_date;
    p6_a10 := ddx_vcrv_rec.ineffective_date;
    p6_a11 := ddx_vcrv_rec.applied_date;
    p6_a12 := ddx_vcrv_rec.attribute_category;
    p6_a13 := ddx_vcrv_rec.attribute1;
    p6_a14 := ddx_vcrv_rec.attribute2;
    p6_a15 := ddx_vcrv_rec.attribute3;
    p6_a16 := ddx_vcrv_rec.attribute4;
    p6_a17 := ddx_vcrv_rec.attribute5;
    p6_a18 := ddx_vcrv_rec.attribute6;
    p6_a19 := ddx_vcrv_rec.attribute7;
    p6_a20 := ddx_vcrv_rec.attribute8;
    p6_a21 := ddx_vcrv_rec.attribute9;
    p6_a22 := ddx_vcrv_rec.attribute10;
    p6_a23 := ddx_vcrv_rec.attribute11;
    p6_a24 := ddx_vcrv_rec.attribute12;
    p6_a25 := ddx_vcrv_rec.attribute13;
    p6_a26 := ddx_vcrv_rec.attribute14;
    p6_a27 := ddx_vcrv_rec.attribute15;
    p6_a28 := ddx_vcrv_rec.request_id;
    p6_a29 := ddx_vcrv_rec.program_application_id;
    p6_a30 := ddx_vcrv_rec.program_id;
    p6_a31 := ddx_vcrv_rec.program_update_date;
    p6_a32 := ddx_vcrv_rec.created_by;
    p6_a33 := ddx_vcrv_rec.creation_date;
    p6_a34 := ddx_vcrv_rec.last_updated_by;
    p6_a35 := ddx_vcrv_rec.last_update_date;
    p6_a36 := ddx_vcrv_rec.last_update_login;
  end;

  procedure create_change_request_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_400
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , x_request_status out nocopy  VARCHAR2
  )

  as
    ddp_vrrv_tbl okl_vp_change_request_pvt.vrrv_tbl_type;
    ddx_vrrv_tbl okl_vp_change_request_pvt.vrrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vrr_pvt_w.rosetta_table_copy_in_p2(ddp_vrrv_tbl, p5_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_vp_change_request_pvt.create_change_request_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vrrv_tbl,
      ddx_vrrv_tbl,
      x_request_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_vrr_pvt_w.rosetta_table_copy_out_p2(ddx_vrrv_tbl, p6_a0
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
      );

  end;

  procedure update_change_request_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_400
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_DATE_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , x_request_status out nocopy  VARCHAR2
  )

  as
    ddp_vrrv_tbl okl_vp_change_request_pvt.vrrv_tbl_type;
    ddx_vrrv_tbl okl_vp_change_request_pvt.vrrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vrr_pvt_w.rosetta_table_copy_in_p2(ddp_vrrv_tbl, p5_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_vp_change_request_pvt.update_change_request_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vrrv_tbl,
      ddx_vrrv_tbl,
      x_request_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_vrr_pvt_w.rosetta_table_copy_out_p2(ddx_vrrv_tbl, p6_a0
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
      );

  end;

  procedure delete_change_request_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_400
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
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
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , x_request_status out nocopy  VARCHAR2
  )

  as
    ddp_vrrv_tbl okl_vp_change_request_pvt.vrrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_vrr_pvt_w.rosetta_table_copy_in_p2(ddp_vrrv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_change_request_pvt.delete_change_request_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vrrv_tbl,
      x_request_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_change_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  DATE
    , p5_a7  DATE
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  DATE
    , p5_a11  DATE
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
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
    , p5_a35  DATE
    , p5_a36  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_400
    , p6_a5 JTF_VARCHAR2_TABLE_2000
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_VARCHAR2_TABLE_500
    , p6_a19 JTF_VARCHAR2_TABLE_500
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_DATE_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_DATE_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  DATE
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  DATE
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  DATE
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
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
    , p7_a28 out nocopy  NUMBER
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  NUMBER
    , p7_a31 out nocopy  DATE
    , p7_a32 out nocopy  NUMBER
    , p7_a33 out nocopy  DATE
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  DATE
    , p7_a36 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_DATE_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_DATE_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_DATE_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_vcrv_rec okl_vp_change_request_pvt.vcrv_rec_type;
    ddp_vrrv_tbl okl_vp_change_request_pvt.vrrv_tbl_type;
    ddx_vcrv_rec okl_vp_change_request_pvt.vcrv_rec_type;
    ddx_vrrv_tbl okl_vp_change_request_pvt.vrrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vcrv_rec.id := p5_a0;
    ddp_vcrv_rec.object_version_number := p5_a1;
    ddp_vcrv_rec.change_request_number := p5_a2;
    ddp_vcrv_rec.chr_id := p5_a3;
    ddp_vcrv_rec.change_type_code := p5_a4;
    ddp_vcrv_rec.status_code := p5_a5;
    ddp_vcrv_rec.request_date := p5_a6;
    ddp_vcrv_rec.effective_date := p5_a7;
    ddp_vcrv_rec.approved_date := p5_a8;
    ddp_vcrv_rec.rejected_date := p5_a9;
    ddp_vcrv_rec.ineffective_date := p5_a10;
    ddp_vcrv_rec.applied_date := p5_a11;
    ddp_vcrv_rec.attribute_category := p5_a12;
    ddp_vcrv_rec.attribute1 := p5_a13;
    ddp_vcrv_rec.attribute2 := p5_a14;
    ddp_vcrv_rec.attribute3 := p5_a15;
    ddp_vcrv_rec.attribute4 := p5_a16;
    ddp_vcrv_rec.attribute5 := p5_a17;
    ddp_vcrv_rec.attribute6 := p5_a18;
    ddp_vcrv_rec.attribute7 := p5_a19;
    ddp_vcrv_rec.attribute8 := p5_a20;
    ddp_vcrv_rec.attribute9 := p5_a21;
    ddp_vcrv_rec.attribute10 := p5_a22;
    ddp_vcrv_rec.attribute11 := p5_a23;
    ddp_vcrv_rec.attribute12 := p5_a24;
    ddp_vcrv_rec.attribute13 := p5_a25;
    ddp_vcrv_rec.attribute14 := p5_a26;
    ddp_vcrv_rec.attribute15 := p5_a27;
    ddp_vcrv_rec.request_id := p5_a28;
    ddp_vcrv_rec.program_application_id := p5_a29;
    ddp_vcrv_rec.program_id := p5_a30;
    ddp_vcrv_rec.program_update_date := p5_a31;
    ddp_vcrv_rec.created_by := p5_a32;
    ddp_vcrv_rec.creation_date := p5_a33;
    ddp_vcrv_rec.last_updated_by := p5_a34;
    ddp_vcrv_rec.last_update_date := p5_a35;
    ddp_vcrv_rec.last_update_login := p5_a36;

    okl_vrr_pvt_w.rosetta_table_copy_in_p2(ddp_vrrv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_vp_change_request_pvt.create_change_request(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vcrv_rec,
      ddp_vrrv_tbl,
      ddx_vcrv_rec,
      ddx_vrrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_vcrv_rec.id;
    p7_a1 := ddx_vcrv_rec.object_version_number;
    p7_a2 := ddx_vcrv_rec.change_request_number;
    p7_a3 := ddx_vcrv_rec.chr_id;
    p7_a4 := ddx_vcrv_rec.change_type_code;
    p7_a5 := ddx_vcrv_rec.status_code;
    p7_a6 := ddx_vcrv_rec.request_date;
    p7_a7 := ddx_vcrv_rec.effective_date;
    p7_a8 := ddx_vcrv_rec.approved_date;
    p7_a9 := ddx_vcrv_rec.rejected_date;
    p7_a10 := ddx_vcrv_rec.ineffective_date;
    p7_a11 := ddx_vcrv_rec.applied_date;
    p7_a12 := ddx_vcrv_rec.attribute_category;
    p7_a13 := ddx_vcrv_rec.attribute1;
    p7_a14 := ddx_vcrv_rec.attribute2;
    p7_a15 := ddx_vcrv_rec.attribute3;
    p7_a16 := ddx_vcrv_rec.attribute4;
    p7_a17 := ddx_vcrv_rec.attribute5;
    p7_a18 := ddx_vcrv_rec.attribute6;
    p7_a19 := ddx_vcrv_rec.attribute7;
    p7_a20 := ddx_vcrv_rec.attribute8;
    p7_a21 := ddx_vcrv_rec.attribute9;
    p7_a22 := ddx_vcrv_rec.attribute10;
    p7_a23 := ddx_vcrv_rec.attribute11;
    p7_a24 := ddx_vcrv_rec.attribute12;
    p7_a25 := ddx_vcrv_rec.attribute13;
    p7_a26 := ddx_vcrv_rec.attribute14;
    p7_a27 := ddx_vcrv_rec.attribute15;
    p7_a28 := ddx_vcrv_rec.request_id;
    p7_a29 := ddx_vcrv_rec.program_application_id;
    p7_a30 := ddx_vcrv_rec.program_id;
    p7_a31 := ddx_vcrv_rec.program_update_date;
    p7_a32 := ddx_vcrv_rec.created_by;
    p7_a33 := ddx_vcrv_rec.creation_date;
    p7_a34 := ddx_vcrv_rec.last_updated_by;
    p7_a35 := ddx_vcrv_rec.last_update_date;
    p7_a36 := ddx_vcrv_rec.last_update_login;

    okl_vrr_pvt_w.rosetta_table_copy_out_p2(ddx_vrrv_tbl, p8_a0
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
      );
  end;

  procedure abandon_change_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  DATE
    , p5_a7  DATE
    , p5_a8  DATE
    , p5_a9  DATE
    , p5_a10  DATE
    , p5_a11  DATE
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
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  DATE
    , p5_a32  NUMBER
    , p5_a33  DATE
    , p5_a34  NUMBER
    , p5_a35  DATE
    , p5_a36  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
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
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  DATE
    , p6_a36 out nocopy  NUMBER
  )

  as
    ddp_vcrv_rec okl_vp_change_request_pvt.vcrv_rec_type;
    ddx_vcrv_rec okl_vp_change_request_pvt.vcrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_vcrv_rec.id := p5_a0;
    ddp_vcrv_rec.object_version_number := p5_a1;
    ddp_vcrv_rec.change_request_number := p5_a2;
    ddp_vcrv_rec.chr_id := p5_a3;
    ddp_vcrv_rec.change_type_code := p5_a4;
    ddp_vcrv_rec.status_code := p5_a5;
    ddp_vcrv_rec.request_date := p5_a6;
    ddp_vcrv_rec.effective_date := p5_a7;
    ddp_vcrv_rec.approved_date := p5_a8;
    ddp_vcrv_rec.rejected_date := p5_a9;
    ddp_vcrv_rec.ineffective_date := p5_a10;
    ddp_vcrv_rec.applied_date := p5_a11;
    ddp_vcrv_rec.attribute_category := p5_a12;
    ddp_vcrv_rec.attribute1 := p5_a13;
    ddp_vcrv_rec.attribute2 := p5_a14;
    ddp_vcrv_rec.attribute3 := p5_a15;
    ddp_vcrv_rec.attribute4 := p5_a16;
    ddp_vcrv_rec.attribute5 := p5_a17;
    ddp_vcrv_rec.attribute6 := p5_a18;
    ddp_vcrv_rec.attribute7 := p5_a19;
    ddp_vcrv_rec.attribute8 := p5_a20;
    ddp_vcrv_rec.attribute9 := p5_a21;
    ddp_vcrv_rec.attribute10 := p5_a22;
    ddp_vcrv_rec.attribute11 := p5_a23;
    ddp_vcrv_rec.attribute12 := p5_a24;
    ddp_vcrv_rec.attribute13 := p5_a25;
    ddp_vcrv_rec.attribute14 := p5_a26;
    ddp_vcrv_rec.attribute15 := p5_a27;
    ddp_vcrv_rec.request_id := p5_a28;
    ddp_vcrv_rec.program_application_id := p5_a29;
    ddp_vcrv_rec.program_id := p5_a30;
    ddp_vcrv_rec.program_update_date := p5_a31;
    ddp_vcrv_rec.created_by := p5_a32;
    ddp_vcrv_rec.creation_date := p5_a33;
    ddp_vcrv_rec.last_updated_by := p5_a34;
    ddp_vcrv_rec.last_update_date := p5_a35;
    ddp_vcrv_rec.last_update_login := p5_a36;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_change_request_pvt.abandon_change_request(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_vcrv_rec,
      ddx_vcrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_vcrv_rec.id;
    p6_a1 := ddx_vcrv_rec.object_version_number;
    p6_a2 := ddx_vcrv_rec.change_request_number;
    p6_a3 := ddx_vcrv_rec.chr_id;
    p6_a4 := ddx_vcrv_rec.change_type_code;
    p6_a5 := ddx_vcrv_rec.status_code;
    p6_a6 := ddx_vcrv_rec.request_date;
    p6_a7 := ddx_vcrv_rec.effective_date;
    p6_a8 := ddx_vcrv_rec.approved_date;
    p6_a9 := ddx_vcrv_rec.rejected_date;
    p6_a10 := ddx_vcrv_rec.ineffective_date;
    p6_a11 := ddx_vcrv_rec.applied_date;
    p6_a12 := ddx_vcrv_rec.attribute_category;
    p6_a13 := ddx_vcrv_rec.attribute1;
    p6_a14 := ddx_vcrv_rec.attribute2;
    p6_a15 := ddx_vcrv_rec.attribute3;
    p6_a16 := ddx_vcrv_rec.attribute4;
    p6_a17 := ddx_vcrv_rec.attribute5;
    p6_a18 := ddx_vcrv_rec.attribute6;
    p6_a19 := ddx_vcrv_rec.attribute7;
    p6_a20 := ddx_vcrv_rec.attribute8;
    p6_a21 := ddx_vcrv_rec.attribute9;
    p6_a22 := ddx_vcrv_rec.attribute10;
    p6_a23 := ddx_vcrv_rec.attribute11;
    p6_a24 := ddx_vcrv_rec.attribute12;
    p6_a25 := ddx_vcrv_rec.attribute13;
    p6_a26 := ddx_vcrv_rec.attribute14;
    p6_a27 := ddx_vcrv_rec.attribute15;
    p6_a28 := ddx_vcrv_rec.request_id;
    p6_a29 := ddx_vcrv_rec.program_application_id;
    p6_a30 := ddx_vcrv_rec.program_id;
    p6_a31 := ddx_vcrv_rec.program_update_date;
    p6_a32 := ddx_vcrv_rec.created_by;
    p6_a33 := ddx_vcrv_rec.creation_date;
    p6_a34 := ddx_vcrv_rec.last_updated_by;
    p6_a35 := ddx_vcrv_rec.last_update_date;
    p6_a36 := ddx_vcrv_rec.last_update_login;
  end;

end okl_vp_change_request_pvt_w;

/
