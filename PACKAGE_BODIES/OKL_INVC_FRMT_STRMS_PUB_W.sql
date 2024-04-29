--------------------------------------------------------
--  DDL for Package Body OKL_INVC_FRMT_STRMS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INVC_FRMT_STRMS_PUB_W" as
  /* $Header: OKLUILSB.pls 120.1 2005/07/14 12:02:35 asawanka noship $ */
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

  procedure insert_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ilsv_tbl okl_invc_frmt_strms_pub.ilsv_tbl_type;
    ddx_ilsv_tbl okl_invc_frmt_strms_pub.ilsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ils_pvt_w.rosetta_table_copy_in_p5(ddp_ilsv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.insert_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_tbl,
      ddx_ilsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ils_pvt_w.rosetta_table_copy_out_p5(ddx_ilsv_tbl, p6_a0
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
      );
  end;

  procedure insert_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
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
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
  )

  as
    ddp_ilsv_rec okl_invc_frmt_strms_pub.ilsv_rec_type;
    ddx_ilsv_rec okl_invc_frmt_strms_pub.ilsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ilsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ilsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ilsv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ilsv_rec.inf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ilsv_rec.ilt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ilsv_rec.attribute_category := p5_a5;
    ddp_ilsv_rec.attribute1 := p5_a6;
    ddp_ilsv_rec.attribute2 := p5_a7;
    ddp_ilsv_rec.attribute3 := p5_a8;
    ddp_ilsv_rec.attribute4 := p5_a9;
    ddp_ilsv_rec.attribute5 := p5_a10;
    ddp_ilsv_rec.attribute6 := p5_a11;
    ddp_ilsv_rec.attribute7 := p5_a12;
    ddp_ilsv_rec.attribute8 := p5_a13;
    ddp_ilsv_rec.attribute9 := p5_a14;
    ddp_ilsv_rec.attribute10 := p5_a15;
    ddp_ilsv_rec.attribute11 := p5_a16;
    ddp_ilsv_rec.attribute12 := p5_a17;
    ddp_ilsv_rec.attribute13 := p5_a18;
    ddp_ilsv_rec.attribute14 := p5_a19;
    ddp_ilsv_rec.attribute15 := p5_a20;
    ddp_ilsv_rec.created_by := rosetta_g_miss_num_map(p5_a21);
    ddp_ilsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ilsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a23);
    ddp_ilsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ilsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a25);


    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.insert_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_rec,
      ddx_ilsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ilsv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ilsv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_ilsv_rec.sty_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_ilsv_rec.inf_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_ilsv_rec.ilt_id);
    p6_a5 := ddx_ilsv_rec.attribute_category;
    p6_a6 := ddx_ilsv_rec.attribute1;
    p6_a7 := ddx_ilsv_rec.attribute2;
    p6_a8 := ddx_ilsv_rec.attribute3;
    p6_a9 := ddx_ilsv_rec.attribute4;
    p6_a10 := ddx_ilsv_rec.attribute5;
    p6_a11 := ddx_ilsv_rec.attribute6;
    p6_a12 := ddx_ilsv_rec.attribute7;
    p6_a13 := ddx_ilsv_rec.attribute8;
    p6_a14 := ddx_ilsv_rec.attribute9;
    p6_a15 := ddx_ilsv_rec.attribute10;
    p6_a16 := ddx_ilsv_rec.attribute11;
    p6_a17 := ddx_ilsv_rec.attribute12;
    p6_a18 := ddx_ilsv_rec.attribute13;
    p6_a19 := ddx_ilsv_rec.attribute14;
    p6_a20 := ddx_ilsv_rec.attribute15;
    p6_a21 := rosetta_g_miss_num_map(ddx_ilsv_rec.created_by);
    p6_a22 := ddx_ilsv_rec.creation_date;
    p6_a23 := rosetta_g_miss_num_map(ddx_ilsv_rec.last_updated_by);
    p6_a24 := ddx_ilsv_rec.last_update_date;
    p6_a25 := rosetta_g_miss_num_map(ddx_ilsv_rec.last_update_login);
  end;

  procedure lock_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
  )

  as
    ddp_ilsv_tbl okl_invc_frmt_strms_pub.ilsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ils_pvt_w.rosetta_table_copy_in_p5(ddp_ilsv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.lock_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
  )

  as
    ddp_ilsv_rec okl_invc_frmt_strms_pub.ilsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ilsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ilsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ilsv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ilsv_rec.inf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ilsv_rec.ilt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ilsv_rec.attribute_category := p5_a5;
    ddp_ilsv_rec.attribute1 := p5_a6;
    ddp_ilsv_rec.attribute2 := p5_a7;
    ddp_ilsv_rec.attribute3 := p5_a8;
    ddp_ilsv_rec.attribute4 := p5_a9;
    ddp_ilsv_rec.attribute5 := p5_a10;
    ddp_ilsv_rec.attribute6 := p5_a11;
    ddp_ilsv_rec.attribute7 := p5_a12;
    ddp_ilsv_rec.attribute8 := p5_a13;
    ddp_ilsv_rec.attribute9 := p5_a14;
    ddp_ilsv_rec.attribute10 := p5_a15;
    ddp_ilsv_rec.attribute11 := p5_a16;
    ddp_ilsv_rec.attribute12 := p5_a17;
    ddp_ilsv_rec.attribute13 := p5_a18;
    ddp_ilsv_rec.attribute14 := p5_a19;
    ddp_ilsv_rec.attribute15 := p5_a20;
    ddp_ilsv_rec.created_by := rosetta_g_miss_num_map(p5_a21);
    ddp_ilsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ilsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a23);
    ddp_ilsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ilsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a25);

    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.lock_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ilsv_tbl okl_invc_frmt_strms_pub.ilsv_tbl_type;
    ddx_ilsv_tbl okl_invc_frmt_strms_pub.ilsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ils_pvt_w.rosetta_table_copy_in_p5(ddp_ilsv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.update_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_tbl,
      ddx_ilsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ils_pvt_w.rosetta_table_copy_out_p5(ddx_ilsv_tbl, p6_a0
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
      );
  end;

  procedure update_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
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
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
  )

  as
    ddp_ilsv_rec okl_invc_frmt_strms_pub.ilsv_rec_type;
    ddx_ilsv_rec okl_invc_frmt_strms_pub.ilsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ilsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ilsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ilsv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ilsv_rec.inf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ilsv_rec.ilt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ilsv_rec.attribute_category := p5_a5;
    ddp_ilsv_rec.attribute1 := p5_a6;
    ddp_ilsv_rec.attribute2 := p5_a7;
    ddp_ilsv_rec.attribute3 := p5_a8;
    ddp_ilsv_rec.attribute4 := p5_a9;
    ddp_ilsv_rec.attribute5 := p5_a10;
    ddp_ilsv_rec.attribute6 := p5_a11;
    ddp_ilsv_rec.attribute7 := p5_a12;
    ddp_ilsv_rec.attribute8 := p5_a13;
    ddp_ilsv_rec.attribute9 := p5_a14;
    ddp_ilsv_rec.attribute10 := p5_a15;
    ddp_ilsv_rec.attribute11 := p5_a16;
    ddp_ilsv_rec.attribute12 := p5_a17;
    ddp_ilsv_rec.attribute13 := p5_a18;
    ddp_ilsv_rec.attribute14 := p5_a19;
    ddp_ilsv_rec.attribute15 := p5_a20;
    ddp_ilsv_rec.created_by := rosetta_g_miss_num_map(p5_a21);
    ddp_ilsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ilsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a23);
    ddp_ilsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ilsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a25);


    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.update_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_rec,
      ddx_ilsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ilsv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ilsv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_ilsv_rec.sty_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_ilsv_rec.inf_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_ilsv_rec.ilt_id);
    p6_a5 := ddx_ilsv_rec.attribute_category;
    p6_a6 := ddx_ilsv_rec.attribute1;
    p6_a7 := ddx_ilsv_rec.attribute2;
    p6_a8 := ddx_ilsv_rec.attribute3;
    p6_a9 := ddx_ilsv_rec.attribute4;
    p6_a10 := ddx_ilsv_rec.attribute5;
    p6_a11 := ddx_ilsv_rec.attribute6;
    p6_a12 := ddx_ilsv_rec.attribute7;
    p6_a13 := ddx_ilsv_rec.attribute8;
    p6_a14 := ddx_ilsv_rec.attribute9;
    p6_a15 := ddx_ilsv_rec.attribute10;
    p6_a16 := ddx_ilsv_rec.attribute11;
    p6_a17 := ddx_ilsv_rec.attribute12;
    p6_a18 := ddx_ilsv_rec.attribute13;
    p6_a19 := ddx_ilsv_rec.attribute14;
    p6_a20 := ddx_ilsv_rec.attribute15;
    p6_a21 := rosetta_g_miss_num_map(ddx_ilsv_rec.created_by);
    p6_a22 := ddx_ilsv_rec.creation_date;
    p6_a23 := rosetta_g_miss_num_map(ddx_ilsv_rec.last_updated_by);
    p6_a24 := ddx_ilsv_rec.last_update_date;
    p6_a25 := rosetta_g_miss_num_map(ddx_ilsv_rec.last_update_login);
  end;

  procedure delete_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
  )

  as
    ddp_ilsv_tbl okl_invc_frmt_strms_pub.ilsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ils_pvt_w.rosetta_table_copy_in_p5(ddp_ilsv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.delete_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
  )

  as
    ddp_ilsv_rec okl_invc_frmt_strms_pub.ilsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ilsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ilsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ilsv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ilsv_rec.inf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ilsv_rec.ilt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ilsv_rec.attribute_category := p5_a5;
    ddp_ilsv_rec.attribute1 := p5_a6;
    ddp_ilsv_rec.attribute2 := p5_a7;
    ddp_ilsv_rec.attribute3 := p5_a8;
    ddp_ilsv_rec.attribute4 := p5_a9;
    ddp_ilsv_rec.attribute5 := p5_a10;
    ddp_ilsv_rec.attribute6 := p5_a11;
    ddp_ilsv_rec.attribute7 := p5_a12;
    ddp_ilsv_rec.attribute8 := p5_a13;
    ddp_ilsv_rec.attribute9 := p5_a14;
    ddp_ilsv_rec.attribute10 := p5_a15;
    ddp_ilsv_rec.attribute11 := p5_a16;
    ddp_ilsv_rec.attribute12 := p5_a17;
    ddp_ilsv_rec.attribute13 := p5_a18;
    ddp_ilsv_rec.attribute14 := p5_a19;
    ddp_ilsv_rec.attribute15 := p5_a20;
    ddp_ilsv_rec.created_by := rosetta_g_miss_num_map(p5_a21);
    ddp_ilsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ilsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a23);
    ddp_ilsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ilsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a25);

    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.delete_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_500
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
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
  )

  as
    ddp_ilsv_tbl okl_invc_frmt_strms_pub.ilsv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ils_pvt_w.rosetta_table_copy_in_p5(ddp_ilsv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.validate_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_invc_frmt_strms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
  )

  as
    ddp_ilsv_rec okl_invc_frmt_strms_pub.ilsv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ilsv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ilsv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ilsv_rec.sty_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ilsv_rec.inf_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ilsv_rec.ilt_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ilsv_rec.attribute_category := p5_a5;
    ddp_ilsv_rec.attribute1 := p5_a6;
    ddp_ilsv_rec.attribute2 := p5_a7;
    ddp_ilsv_rec.attribute3 := p5_a8;
    ddp_ilsv_rec.attribute4 := p5_a9;
    ddp_ilsv_rec.attribute5 := p5_a10;
    ddp_ilsv_rec.attribute6 := p5_a11;
    ddp_ilsv_rec.attribute7 := p5_a12;
    ddp_ilsv_rec.attribute8 := p5_a13;
    ddp_ilsv_rec.attribute9 := p5_a14;
    ddp_ilsv_rec.attribute10 := p5_a15;
    ddp_ilsv_rec.attribute11 := p5_a16;
    ddp_ilsv_rec.attribute12 := p5_a17;
    ddp_ilsv_rec.attribute13 := p5_a18;
    ddp_ilsv_rec.attribute14 := p5_a19;
    ddp_ilsv_rec.attribute15 := p5_a20;
    ddp_ilsv_rec.created_by := rosetta_g_miss_num_map(p5_a21);
    ddp_ilsv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ilsv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a23);
    ddp_ilsv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ilsv_rec.last_update_login := rosetta_g_miss_num_map(p5_a25);

    -- here's the delegated call to the old PL/SQL routine
    okl_invc_frmt_strms_pub.validate_invc_frmt_strms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ilsv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_invc_frmt_strms_pub_w;

/
