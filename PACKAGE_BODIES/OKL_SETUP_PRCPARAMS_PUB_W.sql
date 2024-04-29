--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_PRCPARAMS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_PRCPARAMS_PUB_W" as
  /* $Header: OKLUPPRB.pls 115.0 2004/07/02 02:38:23 sgorantl noship $ */
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

  procedure create_price_parm(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  DATE
    , p3_a5 out nocopy  DATE
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  VARCHAR2
    , p3_a15 out nocopy  VARCHAR2
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  NUMBER
    , p3_a28 out nocopy  NUMBER
    , p3_a29 out nocopy  DATE
    , p3_a30 out nocopy  DATE
    , p3_a31 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  VARCHAR2 := fnd_api.g_miss_char
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p2_a28  NUMBER := 0-1962.0724
    , p2_a29  DATE := fnd_api.g_miss_date
    , p2_a30  DATE := fnd_api.g_miss_date
    , p2_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_sppv_rec okl_setup_prcparams_pub.sppv_rec_type;
    ddx_sppv_rec okl_setup_prcparams_pub.sppv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_sppv_rec.id := rosetta_g_miss_num_map(p2_a0);
    ddp_sppv_rec.object_version_number := rosetta_g_miss_num_map(p2_a1);
    ddp_sppv_rec.name := p2_a2;
    ddp_sppv_rec.version := p2_a3;
    ddp_sppv_rec.date_start := rosetta_g_miss_date_in_map(p2_a4);
    ddp_sppv_rec.date_end := rosetta_g_miss_date_in_map(p2_a5);
    ddp_sppv_rec.description := p2_a6;
    ddp_sppv_rec.sps_code := p2_a7;
    ddp_sppv_rec.dyp_code := p2_a8;
    ddp_sppv_rec.array_yn := p2_a9;
    ddp_sppv_rec.xml_tag := p2_a10;
    ddp_sppv_rec.attribute_category := p2_a11;
    ddp_sppv_rec.attribute1 := p2_a12;
    ddp_sppv_rec.attribute2 := p2_a13;
    ddp_sppv_rec.attribute3 := p2_a14;
    ddp_sppv_rec.attribute4 := p2_a15;
    ddp_sppv_rec.attribute5 := p2_a16;
    ddp_sppv_rec.attribute6 := p2_a17;
    ddp_sppv_rec.attribute7 := p2_a18;
    ddp_sppv_rec.attribute8 := p2_a19;
    ddp_sppv_rec.attribute9 := p2_a20;
    ddp_sppv_rec.attribute10 := p2_a21;
    ddp_sppv_rec.attribute11 := p2_a22;
    ddp_sppv_rec.attribute12 := p2_a23;
    ddp_sppv_rec.attribute13 := p2_a24;
    ddp_sppv_rec.attribute14 := p2_a25;
    ddp_sppv_rec.attribute15 := p2_a26;
    ddp_sppv_rec.created_by := rosetta_g_miss_num_map(p2_a27);
    ddp_sppv_rec.last_updated_by := rosetta_g_miss_num_map(p2_a28);
    ddp_sppv_rec.creation_date := rosetta_g_miss_date_in_map(p2_a29);
    ddp_sppv_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a30);
    ddp_sppv_rec.last_update_login := rosetta_g_miss_num_map(p2_a31);





    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prcparams_pub.create_price_parm(p_api_version,
      p_init_msg_list,
      ddp_sppv_rec,
      ddx_sppv_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := rosetta_g_miss_num_map(ddx_sppv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_sppv_rec.object_version_number);
    p3_a2 := ddx_sppv_rec.name;
    p3_a3 := ddx_sppv_rec.version;
    p3_a4 := ddx_sppv_rec.date_start;
    p3_a5 := ddx_sppv_rec.date_end;
    p3_a6 := ddx_sppv_rec.description;
    p3_a7 := ddx_sppv_rec.sps_code;
    p3_a8 := ddx_sppv_rec.dyp_code;
    p3_a9 := ddx_sppv_rec.array_yn;
    p3_a10 := ddx_sppv_rec.xml_tag;
    p3_a11 := ddx_sppv_rec.attribute_category;
    p3_a12 := ddx_sppv_rec.attribute1;
    p3_a13 := ddx_sppv_rec.attribute2;
    p3_a14 := ddx_sppv_rec.attribute3;
    p3_a15 := ddx_sppv_rec.attribute4;
    p3_a16 := ddx_sppv_rec.attribute5;
    p3_a17 := ddx_sppv_rec.attribute6;
    p3_a18 := ddx_sppv_rec.attribute7;
    p3_a19 := ddx_sppv_rec.attribute8;
    p3_a20 := ddx_sppv_rec.attribute9;
    p3_a21 := ddx_sppv_rec.attribute10;
    p3_a22 := ddx_sppv_rec.attribute11;
    p3_a23 := ddx_sppv_rec.attribute12;
    p3_a24 := ddx_sppv_rec.attribute13;
    p3_a25 := ddx_sppv_rec.attribute14;
    p3_a26 := ddx_sppv_rec.attribute15;
    p3_a27 := rosetta_g_miss_num_map(ddx_sppv_rec.created_by);
    p3_a28 := rosetta_g_miss_num_map(ddx_sppv_rec.last_updated_by);
    p3_a29 := ddx_sppv_rec.creation_date;
    p3_a30 := ddx_sppv_rec.last_update_date;
    p3_a31 := rosetta_g_miss_num_map(ddx_sppv_rec.last_update_login);



  end;

  procedure update_price_parm(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  DATE
    , p3_a5 out nocopy  DATE
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  VARCHAR2
    , p3_a15 out nocopy  VARCHAR2
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  NUMBER
    , p3_a28 out nocopy  NUMBER
    , p3_a29 out nocopy  DATE
    , p3_a30 out nocopy  DATE
    , p3_a31 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  VARCHAR2 := fnd_api.g_miss_char
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p2_a28  NUMBER := 0-1962.0724
    , p2_a29  DATE := fnd_api.g_miss_date
    , p2_a30  DATE := fnd_api.g_miss_date
    , p2_a31  NUMBER := 0-1962.0724
  )

  as
    ddp_sppv_rec okl_setup_prcparams_pub.sppv_rec_type;
    ddx_sppv_rec okl_setup_prcparams_pub.sppv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_sppv_rec.id := rosetta_g_miss_num_map(p2_a0);
    ddp_sppv_rec.object_version_number := rosetta_g_miss_num_map(p2_a1);
    ddp_sppv_rec.name := p2_a2;
    ddp_sppv_rec.version := p2_a3;
    ddp_sppv_rec.date_start := rosetta_g_miss_date_in_map(p2_a4);
    ddp_sppv_rec.date_end := rosetta_g_miss_date_in_map(p2_a5);
    ddp_sppv_rec.description := p2_a6;
    ddp_sppv_rec.sps_code := p2_a7;
    ddp_sppv_rec.dyp_code := p2_a8;
    ddp_sppv_rec.array_yn := p2_a9;
    ddp_sppv_rec.xml_tag := p2_a10;
    ddp_sppv_rec.attribute_category := p2_a11;
    ddp_sppv_rec.attribute1 := p2_a12;
    ddp_sppv_rec.attribute2 := p2_a13;
    ddp_sppv_rec.attribute3 := p2_a14;
    ddp_sppv_rec.attribute4 := p2_a15;
    ddp_sppv_rec.attribute5 := p2_a16;
    ddp_sppv_rec.attribute6 := p2_a17;
    ddp_sppv_rec.attribute7 := p2_a18;
    ddp_sppv_rec.attribute8 := p2_a19;
    ddp_sppv_rec.attribute9 := p2_a20;
    ddp_sppv_rec.attribute10 := p2_a21;
    ddp_sppv_rec.attribute11 := p2_a22;
    ddp_sppv_rec.attribute12 := p2_a23;
    ddp_sppv_rec.attribute13 := p2_a24;
    ddp_sppv_rec.attribute14 := p2_a25;
    ddp_sppv_rec.attribute15 := p2_a26;
    ddp_sppv_rec.created_by := rosetta_g_miss_num_map(p2_a27);
    ddp_sppv_rec.last_updated_by := rosetta_g_miss_num_map(p2_a28);
    ddp_sppv_rec.creation_date := rosetta_g_miss_date_in_map(p2_a29);
    ddp_sppv_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a30);
    ddp_sppv_rec.last_update_login := rosetta_g_miss_num_map(p2_a31);





    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prcparams_pub.update_price_parm(p_api_version,
      p_init_msg_list,
      ddp_sppv_rec,
      ddx_sppv_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := rosetta_g_miss_num_map(ddx_sppv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_sppv_rec.object_version_number);
    p3_a2 := ddx_sppv_rec.name;
    p3_a3 := ddx_sppv_rec.version;
    p3_a4 := ddx_sppv_rec.date_start;
    p3_a5 := ddx_sppv_rec.date_end;
    p3_a6 := ddx_sppv_rec.description;
    p3_a7 := ddx_sppv_rec.sps_code;
    p3_a8 := ddx_sppv_rec.dyp_code;
    p3_a9 := ddx_sppv_rec.array_yn;
    p3_a10 := ddx_sppv_rec.xml_tag;
    p3_a11 := ddx_sppv_rec.attribute_category;
    p3_a12 := ddx_sppv_rec.attribute1;
    p3_a13 := ddx_sppv_rec.attribute2;
    p3_a14 := ddx_sppv_rec.attribute3;
    p3_a15 := ddx_sppv_rec.attribute4;
    p3_a16 := ddx_sppv_rec.attribute5;
    p3_a17 := ddx_sppv_rec.attribute6;
    p3_a18 := ddx_sppv_rec.attribute7;
    p3_a19 := ddx_sppv_rec.attribute8;
    p3_a20 := ddx_sppv_rec.attribute9;
    p3_a21 := ddx_sppv_rec.attribute10;
    p3_a22 := ddx_sppv_rec.attribute11;
    p3_a23 := ddx_sppv_rec.attribute12;
    p3_a24 := ddx_sppv_rec.attribute13;
    p3_a25 := ddx_sppv_rec.attribute14;
    p3_a26 := ddx_sppv_rec.attribute15;
    p3_a27 := rosetta_g_miss_num_map(ddx_sppv_rec.created_by);
    p3_a28 := rosetta_g_miss_num_map(ddx_sppv_rec.last_updated_by);
    p3_a29 := ddx_sppv_rec.creation_date;
    p3_a30 := ddx_sppv_rec.last_update_date;
    p3_a31 := rosetta_g_miss_num_map(ddx_sppv_rec.last_update_login);



  end;

  procedure create_price_parm(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_VARCHAR2_TABLE_200
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_DATE_TABLE
    , p2_a5 JTF_DATE_TABLE
    , p2_a6 JTF_VARCHAR2_TABLE_2000
    , p2_a7 JTF_VARCHAR2_TABLE_100
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_VARCHAR2_TABLE_100
    , p2_a10 JTF_VARCHAR2_TABLE_200
    , p2_a11 JTF_VARCHAR2_TABLE_100
    , p2_a12 JTF_VARCHAR2_TABLE_500
    , p2_a13 JTF_VARCHAR2_TABLE_500
    , p2_a14 JTF_VARCHAR2_TABLE_500
    , p2_a15 JTF_VARCHAR2_TABLE_500
    , p2_a16 JTF_VARCHAR2_TABLE_500
    , p2_a17 JTF_VARCHAR2_TABLE_500
    , p2_a18 JTF_VARCHAR2_TABLE_500
    , p2_a19 JTF_VARCHAR2_TABLE_500
    , p2_a20 JTF_VARCHAR2_TABLE_500
    , p2_a21 JTF_VARCHAR2_TABLE_500
    , p2_a22 JTF_VARCHAR2_TABLE_500
    , p2_a23 JTF_VARCHAR2_TABLE_500
    , p2_a24 JTF_VARCHAR2_TABLE_500
    , p2_a25 JTF_VARCHAR2_TABLE_500
    , p2_a26 JTF_VARCHAR2_TABLE_500
    , p2_a27 JTF_NUMBER_TABLE
    , p2_a28 JTF_NUMBER_TABLE
    , p2_a29 JTF_DATE_TABLE
    , p2_a30 JTF_DATE_TABLE
    , p2_a31 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_DATE_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a27 out nocopy JTF_NUMBER_TABLE
    , p3_a28 out nocopy JTF_NUMBER_TABLE
    , p3_a29 out nocopy JTF_DATE_TABLE
    , p3_a30 out nocopy JTF_DATE_TABLE
    , p3_a31 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sppv_tbl okl_setup_prcparams_pub.sppv_tbl_type;
    ddx_sppv_tbl okl_setup_prcparams_pub.sppv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_spp_pvt_w.rosetta_table_copy_in_p5(ddp_sppv_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      , p2_a19
      , p2_a20
      , p2_a21
      , p2_a22
      , p2_a23
      , p2_a24
      , p2_a25
      , p2_a26
      , p2_a27
      , p2_a28
      , p2_a29
      , p2_a30
      , p2_a31
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prcparams_pub.create_price_parm(p_api_version,
      p_init_msg_list,
      ddp_sppv_tbl,
      ddx_sppv_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    okl_spp_pvt_w.rosetta_table_copy_out_p5(ddx_sppv_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      );



  end;

  procedure update_price_parm(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_VARCHAR2_TABLE_200
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_DATE_TABLE
    , p2_a5 JTF_DATE_TABLE
    , p2_a6 JTF_VARCHAR2_TABLE_2000
    , p2_a7 JTF_VARCHAR2_TABLE_100
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_VARCHAR2_TABLE_100
    , p2_a10 JTF_VARCHAR2_TABLE_200
    , p2_a11 JTF_VARCHAR2_TABLE_100
    , p2_a12 JTF_VARCHAR2_TABLE_500
    , p2_a13 JTF_VARCHAR2_TABLE_500
    , p2_a14 JTF_VARCHAR2_TABLE_500
    , p2_a15 JTF_VARCHAR2_TABLE_500
    , p2_a16 JTF_VARCHAR2_TABLE_500
    , p2_a17 JTF_VARCHAR2_TABLE_500
    , p2_a18 JTF_VARCHAR2_TABLE_500
    , p2_a19 JTF_VARCHAR2_TABLE_500
    , p2_a20 JTF_VARCHAR2_TABLE_500
    , p2_a21 JTF_VARCHAR2_TABLE_500
    , p2_a22 JTF_VARCHAR2_TABLE_500
    , p2_a23 JTF_VARCHAR2_TABLE_500
    , p2_a24 JTF_VARCHAR2_TABLE_500
    , p2_a25 JTF_VARCHAR2_TABLE_500
    , p2_a26 JTF_VARCHAR2_TABLE_500
    , p2_a27 JTF_NUMBER_TABLE
    , p2_a28 JTF_NUMBER_TABLE
    , p2_a29 JTF_DATE_TABLE
    , p2_a30 JTF_DATE_TABLE
    , p2_a31 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_DATE_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a27 out nocopy JTF_NUMBER_TABLE
    , p3_a28 out nocopy JTF_NUMBER_TABLE
    , p3_a29 out nocopy JTF_DATE_TABLE
    , p3_a30 out nocopy JTF_DATE_TABLE
    , p3_a31 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sppv_tbl okl_setup_prcparams_pub.sppv_tbl_type;
    ddx_sppv_tbl okl_setup_prcparams_pub.sppv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_spp_pvt_w.rosetta_table_copy_in_p5(ddp_sppv_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      , p2_a19
      , p2_a20
      , p2_a21
      , p2_a22
      , p2_a23
      , p2_a24
      , p2_a25
      , p2_a26
      , p2_a27
      , p2_a28
      , p2_a29
      , p2_a30
      , p2_a31
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prcparams_pub.update_price_parm(p_api_version,
      p_init_msg_list,
      ddp_sppv_tbl,
      ddx_sppv_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    okl_spp_pvt_w.rosetta_table_copy_out_p5(ddx_sppv_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      );



  end;

end okl_setup_prcparams_pub_w;

/
