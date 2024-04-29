--------------------------------------------------------
--  DDL for Package Body OKL_TMPT_SET_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TMPT_SET_PUB_W" as
  /* $Header: OKLUAESB.pls 120.2 2005/10/30 03:47:59 appldev noship $ */
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

  procedure create_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_200
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_DATE_TABLE
    , p6_a18 JTF_DATE_TABLE
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_500
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_DATE_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_DATE_TABLE
    , p6_a41 JTF_NUMBER_TABLE
    , p6_a42 JTF_VARCHAR2_TABLE_100
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_2000
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
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
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  DATE
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 out nocopy JTF_DATE_TABLE
    , p9_a18 out nocopy JTF_DATE_TABLE
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p9_a36 out nocopy JTF_NUMBER_TABLE
    , p9_a37 out nocopy JTF_NUMBER_TABLE
    , p9_a38 out nocopy JTF_DATE_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_DATE_TABLE
    , p9_a41 out nocopy JTF_NUMBER_TABLE
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p10_a26 out nocopy JTF_NUMBER_TABLE
    , p10_a27 out nocopy JTF_NUMBER_TABLE
    , p10_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a29 out nocopy JTF_DATE_TABLE
    , p10_a30 out nocopy JTF_NUMBER_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddp_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddp_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddx_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddx_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddx_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aesv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aesv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aesv_rec.name := p5_a2;
    ddp_aesv_rec.description := p5_a3;
    ddp_aesv_rec.version := p5_a4;
    ddp_aesv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_aesv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_aesv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aesv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_aesv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_aesv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_aesv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aesv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_aesv_rec.gts_id := rosetta_g_miss_num_map(p5_a13);

    okl_avl_pvt_w.rosetta_table_copy_in_p5(ddp_avlv_tbl, p6_a0
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
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      );

    okl_atl_pvt_w.rosetta_table_copy_in_p5(ddp_atlv_tbl, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.create_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_rec,
      ddp_avlv_tbl,
      ddp_atlv_tbl,
      ddx_aesv_rec,
      ddx_avlv_tbl,
      ddx_atlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_aesv_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_aesv_rec.object_version_number);
    p8_a2 := ddx_aesv_rec.name;
    p8_a3 := ddx_aesv_rec.description;
    p8_a4 := ddx_aesv_rec.version;
    p8_a5 := ddx_aesv_rec.start_date;
    p8_a6 := ddx_aesv_rec.end_date;
    p8_a7 := rosetta_g_miss_num_map(ddx_aesv_rec.org_id);
    p8_a8 := rosetta_g_miss_num_map(ddx_aesv_rec.created_by);
    p8_a9 := ddx_aesv_rec.creation_date;
    p8_a10 := rosetta_g_miss_num_map(ddx_aesv_rec.last_updated_by);
    p8_a11 := ddx_aesv_rec.last_update_date;
    p8_a12 := rosetta_g_miss_num_map(ddx_aesv_rec.last_update_login);
    p8_a13 := rosetta_g_miss_num_map(ddx_aesv_rec.gts_id);

    okl_avl_pvt_w.rosetta_table_copy_out_p5(ddx_avlv_tbl, p9_a0
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
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      );

    okl_atl_pvt_w.rosetta_table_copy_out_p5(ddx_atlv_tbl, p10_a0
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
      );
  end;

  procedure update_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_200
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_DATE_TABLE
    , p6_a18 JTF_DATE_TABLE
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_500
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_DATE_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_DATE_TABLE
    , p6_a41 JTF_NUMBER_TABLE
    , p6_a42 JTF_VARCHAR2_TABLE_100
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_2000
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
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
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  DATE
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 out nocopy JTF_DATE_TABLE
    , p9_a18 out nocopy JTF_DATE_TABLE
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p9_a36 out nocopy JTF_NUMBER_TABLE
    , p9_a37 out nocopy JTF_NUMBER_TABLE
    , p9_a38 out nocopy JTF_DATE_TABLE
    , p9_a39 out nocopy JTF_NUMBER_TABLE
    , p9_a40 out nocopy JTF_DATE_TABLE
    , p9_a41 out nocopy JTF_NUMBER_TABLE
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_NUMBER_TABLE
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p10_a26 out nocopy JTF_NUMBER_TABLE
    , p10_a27 out nocopy JTF_NUMBER_TABLE
    , p10_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a29 out nocopy JTF_DATE_TABLE
    , p10_a30 out nocopy JTF_NUMBER_TABLE
    , p10_a31 out nocopy JTF_DATE_TABLE
    , p10_a32 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddp_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddp_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddx_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddx_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddx_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aesv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aesv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aesv_rec.name := p5_a2;
    ddp_aesv_rec.description := p5_a3;
    ddp_aesv_rec.version := p5_a4;
    ddp_aesv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_aesv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_aesv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aesv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_aesv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_aesv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_aesv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aesv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_aesv_rec.gts_id := rosetta_g_miss_num_map(p5_a13);

    okl_avl_pvt_w.rosetta_table_copy_in_p5(ddp_avlv_tbl, p6_a0
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
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      );

    okl_atl_pvt_w.rosetta_table_copy_in_p5(ddp_atlv_tbl, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.update_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_rec,
      ddp_avlv_tbl,
      ddp_atlv_tbl,
      ddx_aesv_rec,
      ddx_avlv_tbl,
      ddx_atlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_aesv_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_aesv_rec.object_version_number);
    p8_a2 := ddx_aesv_rec.name;
    p8_a3 := ddx_aesv_rec.description;
    p8_a4 := ddx_aesv_rec.version;
    p8_a5 := ddx_aesv_rec.start_date;
    p8_a6 := ddx_aesv_rec.end_date;
    p8_a7 := rosetta_g_miss_num_map(ddx_aesv_rec.org_id);
    p8_a8 := rosetta_g_miss_num_map(ddx_aesv_rec.created_by);
    p8_a9 := ddx_aesv_rec.creation_date;
    p8_a10 := rosetta_g_miss_num_map(ddx_aesv_rec.last_updated_by);
    p8_a11 := ddx_aesv_rec.last_update_date;
    p8_a12 := rosetta_g_miss_num_map(ddx_aesv_rec.last_update_login);
    p8_a13 := rosetta_g_miss_num_map(ddx_aesv_rec.gts_id);

    okl_avl_pvt_w.rosetta_table_copy_out_p5(ddx_avlv_tbl, p9_a0
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
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      );

    okl_atl_pvt_w.rosetta_table_copy_out_p5(ddx_atlv_tbl, p10_a0
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
      );
  end;

  procedure validate_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_200
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_DATE_TABLE
    , p6_a18 JTF_DATE_TABLE
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_500
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_DATE_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_DATE_TABLE
    , p6_a41 JTF_NUMBER_TABLE
    , p6_a42 JTF_VARCHAR2_TABLE_100
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_2000
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
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
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_DATE_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_DATE_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddp_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddp_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aesv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aesv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aesv_rec.name := p5_a2;
    ddp_aesv_rec.description := p5_a3;
    ddp_aesv_rec.version := p5_a4;
    ddp_aesv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_aesv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_aesv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aesv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_aesv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_aesv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_aesv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aesv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_aesv_rec.gts_id := rosetta_g_miss_num_map(p5_a13);

    okl_avl_pvt_w.rosetta_table_copy_in_p5(ddp_avlv_tbl, p6_a0
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
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      );

    okl_atl_pvt_w.rosetta_table_copy_in_p5(ddp_atlv_tbl, p7_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.validate_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_rec,
      ddp_avlv_tbl,
      ddp_atlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aesv_tbl okl_tmpt_set_pub.aesv_tbl_type;
    ddx_aesv_tbl okl_tmpt_set_pub.aesv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aes_pvt_w.rosetta_table_copy_in_p5(ddp_aesv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.create_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_tbl,
      ddx_aesv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_aes_pvt_w.rosetta_table_copy_out_p5(ddx_aesv_tbl, p6_a0
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
      );
  end;

  procedure create_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddx_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aesv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aesv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aesv_rec.name := p5_a2;
    ddp_aesv_rec.description := p5_a3;
    ddp_aesv_rec.version := p5_a4;
    ddp_aesv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_aesv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_aesv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aesv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_aesv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_aesv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_aesv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aesv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_aesv_rec.gts_id := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.create_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_rec,
      ddx_aesv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aesv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aesv_rec.object_version_number);
    p6_a2 := ddx_aesv_rec.name;
    p6_a3 := ddx_aesv_rec.description;
    p6_a4 := ddx_aesv_rec.version;
    p6_a5 := ddx_aesv_rec.start_date;
    p6_a6 := ddx_aesv_rec.end_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_aesv_rec.org_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_aesv_rec.created_by);
    p6_a9 := ddx_aesv_rec.creation_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_aesv_rec.last_updated_by);
    p6_a11 := ddx_aesv_rec.last_update_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_aesv_rec.last_update_login);
    p6_a13 := rosetta_g_miss_num_map(ddx_aesv_rec.gts_id);
  end;

  procedure lock_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_aesv_tbl okl_tmpt_set_pub.aesv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aes_pvt_w.rosetta_table_copy_in_p5(ddp_aesv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.lock_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aesv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aesv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aesv_rec.name := p5_a2;
    ddp_aesv_rec.description := p5_a3;
    ddp_aesv_rec.version := p5_a4;
    ddp_aesv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_aesv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_aesv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aesv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_aesv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_aesv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_aesv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aesv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_aesv_rec.gts_id := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.lock_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aesv_tbl okl_tmpt_set_pub.aesv_tbl_type;
    ddx_aesv_tbl okl_tmpt_set_pub.aesv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aes_pvt_w.rosetta_table_copy_in_p5(ddp_aesv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.update_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_tbl,
      ddx_aesv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_aes_pvt_w.rosetta_table_copy_out_p5(ddx_aesv_tbl, p6_a0
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
      );
  end;

  procedure update_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddx_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aesv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aesv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aesv_rec.name := p5_a2;
    ddp_aesv_rec.description := p5_a3;
    ddp_aesv_rec.version := p5_a4;
    ddp_aesv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_aesv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_aesv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aesv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_aesv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_aesv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_aesv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aesv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_aesv_rec.gts_id := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.update_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_rec,
      ddx_aesv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aesv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aesv_rec.object_version_number);
    p6_a2 := ddx_aesv_rec.name;
    p6_a3 := ddx_aesv_rec.description;
    p6_a4 := ddx_aesv_rec.version;
    p6_a5 := ddx_aesv_rec.start_date;
    p6_a6 := ddx_aesv_rec.end_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_aesv_rec.org_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_aesv_rec.created_by);
    p6_a9 := ddx_aesv_rec.creation_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_aesv_rec.last_updated_by);
    p6_a11 := ddx_aesv_rec.last_update_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_aesv_rec.last_update_login);
    p6_a13 := rosetta_g_miss_num_map(ddx_aesv_rec.gts_id);
  end;

  procedure delete_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_aesv_tbl okl_tmpt_set_pub.aesv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aes_pvt_w.rosetta_table_copy_in_p5(ddp_aesv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.delete_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aesv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aesv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aesv_rec.name := p5_a2;
    ddp_aesv_rec.description := p5_a3;
    ddp_aesv_rec.version := p5_a4;
    ddp_aesv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_aesv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_aesv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aesv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_aesv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_aesv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_aesv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aesv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_aesv_rec.gts_id := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.delete_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_aesv_tbl okl_tmpt_set_pub.aesv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aes_pvt_w.rosetta_table_copy_in_p5(ddp_aesv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.validate_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_tmpt_set(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_aesv_rec okl_tmpt_set_pub.aesv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aesv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aesv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aesv_rec.name := p5_a2;
    ddp_aesv_rec.description := p5_a3;
    ddp_aesv_rec.version := p5_a4;
    ddp_aesv_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_aesv_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_aesv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_aesv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_aesv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_aesv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_aesv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_aesv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_aesv_rec.gts_id := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.validate_tmpt_set(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aesv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_template(p_api_version  NUMBER
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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddx_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_avl_pvt_w.rosetta_table_copy_in_p5(ddp_avlv_tbl, p5_a0
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
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.create_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_tbl,
      ddx_avlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_avl_pvt_w.rosetta_table_copy_out_p5(ddx_avlv_tbl, p6_a0
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
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      );
  end;

  procedure create_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
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
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
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
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_avlv_rec okl_tmpt_set_pub.avlv_rec_type;
    ddx_avlv_rec okl_tmpt_set_pub.avlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_avlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_avlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_avlv_rec.try_id := rosetta_g_miss_num_map(p5_a2);
    ddp_avlv_rec.aes_id := rosetta_g_miss_num_map(p5_a3);
    ddp_avlv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_avlv_rec.fma_id := rosetta_g_miss_num_map(p5_a5);
    ddp_avlv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_avlv_rec.fac_code := p5_a7;
    ddp_avlv_rec.syt_code := p5_a8;
    ddp_avlv_rec.post_to_gl := p5_a9;
    ddp_avlv_rec.advance_arrears := p5_a10;
    ddp_avlv_rec.memo_yn := p5_a11;
    ddp_avlv_rec.prior_year_yn := p5_a12;
    ddp_avlv_rec.name := p5_a13;
    ddp_avlv_rec.description := p5_a14;
    ddp_avlv_rec.version := p5_a15;
    ddp_avlv_rec.factoring_synd_flag := p5_a16;
    ddp_avlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_avlv_rec.end_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_avlv_rec.accrual_yn := p5_a19;
    ddp_avlv_rec.attribute_category := p5_a20;
    ddp_avlv_rec.attribute1 := p5_a21;
    ddp_avlv_rec.attribute2 := p5_a22;
    ddp_avlv_rec.attribute3 := p5_a23;
    ddp_avlv_rec.attribute4 := p5_a24;
    ddp_avlv_rec.attribute5 := p5_a25;
    ddp_avlv_rec.attribute6 := p5_a26;
    ddp_avlv_rec.attribute7 := p5_a27;
    ddp_avlv_rec.attribute8 := p5_a28;
    ddp_avlv_rec.attribute9 := p5_a29;
    ddp_avlv_rec.attribute10 := p5_a30;
    ddp_avlv_rec.attribute11 := p5_a31;
    ddp_avlv_rec.attribute12 := p5_a32;
    ddp_avlv_rec.attribute13 := p5_a33;
    ddp_avlv_rec.attribute14 := p5_a34;
    ddp_avlv_rec.attribute15 := p5_a35;
    ddp_avlv_rec.org_id := rosetta_g_miss_num_map(p5_a36);
    ddp_avlv_rec.created_by := rosetta_g_miss_num_map(p5_a37);
    ddp_avlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_avlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_avlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_avlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a41);
    ddp_avlv_rec.inv_code := p5_a42;


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.create_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_rec,
      ddx_avlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_avlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_avlv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_avlv_rec.try_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_avlv_rec.aes_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_avlv_rec.sty_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_avlv_rec.fma_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_avlv_rec.set_of_books_id);
    p6_a7 := ddx_avlv_rec.fac_code;
    p6_a8 := ddx_avlv_rec.syt_code;
    p6_a9 := ddx_avlv_rec.post_to_gl;
    p6_a10 := ddx_avlv_rec.advance_arrears;
    p6_a11 := ddx_avlv_rec.memo_yn;
    p6_a12 := ddx_avlv_rec.prior_year_yn;
    p6_a13 := ddx_avlv_rec.name;
    p6_a14 := ddx_avlv_rec.description;
    p6_a15 := ddx_avlv_rec.version;
    p6_a16 := ddx_avlv_rec.factoring_synd_flag;
    p6_a17 := ddx_avlv_rec.start_date;
    p6_a18 := ddx_avlv_rec.end_date;
    p6_a19 := ddx_avlv_rec.accrual_yn;
    p6_a20 := ddx_avlv_rec.attribute_category;
    p6_a21 := ddx_avlv_rec.attribute1;
    p6_a22 := ddx_avlv_rec.attribute2;
    p6_a23 := ddx_avlv_rec.attribute3;
    p6_a24 := ddx_avlv_rec.attribute4;
    p6_a25 := ddx_avlv_rec.attribute5;
    p6_a26 := ddx_avlv_rec.attribute6;
    p6_a27 := ddx_avlv_rec.attribute7;
    p6_a28 := ddx_avlv_rec.attribute8;
    p6_a29 := ddx_avlv_rec.attribute9;
    p6_a30 := ddx_avlv_rec.attribute10;
    p6_a31 := ddx_avlv_rec.attribute11;
    p6_a32 := ddx_avlv_rec.attribute12;
    p6_a33 := ddx_avlv_rec.attribute13;
    p6_a34 := ddx_avlv_rec.attribute14;
    p6_a35 := ddx_avlv_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddx_avlv_rec.org_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_avlv_rec.created_by);
    p6_a38 := ddx_avlv_rec.creation_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_avlv_rec.last_updated_by);
    p6_a40 := ddx_avlv_rec.last_update_date;
    p6_a41 := rosetta_g_miss_num_map(ddx_avlv_rec.last_update_login);
    p6_a42 := ddx_avlv_rec.inv_code;
  end;

  procedure lock_template(p_api_version  NUMBER
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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_avl_pvt_w.rosetta_table_copy_in_p5(ddp_avlv_tbl, p5_a0
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
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.lock_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
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
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_avlv_rec okl_tmpt_set_pub.avlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_avlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_avlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_avlv_rec.try_id := rosetta_g_miss_num_map(p5_a2);
    ddp_avlv_rec.aes_id := rosetta_g_miss_num_map(p5_a3);
    ddp_avlv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_avlv_rec.fma_id := rosetta_g_miss_num_map(p5_a5);
    ddp_avlv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_avlv_rec.fac_code := p5_a7;
    ddp_avlv_rec.syt_code := p5_a8;
    ddp_avlv_rec.post_to_gl := p5_a9;
    ddp_avlv_rec.advance_arrears := p5_a10;
    ddp_avlv_rec.memo_yn := p5_a11;
    ddp_avlv_rec.prior_year_yn := p5_a12;
    ddp_avlv_rec.name := p5_a13;
    ddp_avlv_rec.description := p5_a14;
    ddp_avlv_rec.version := p5_a15;
    ddp_avlv_rec.factoring_synd_flag := p5_a16;
    ddp_avlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_avlv_rec.end_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_avlv_rec.accrual_yn := p5_a19;
    ddp_avlv_rec.attribute_category := p5_a20;
    ddp_avlv_rec.attribute1 := p5_a21;
    ddp_avlv_rec.attribute2 := p5_a22;
    ddp_avlv_rec.attribute3 := p5_a23;
    ddp_avlv_rec.attribute4 := p5_a24;
    ddp_avlv_rec.attribute5 := p5_a25;
    ddp_avlv_rec.attribute6 := p5_a26;
    ddp_avlv_rec.attribute7 := p5_a27;
    ddp_avlv_rec.attribute8 := p5_a28;
    ddp_avlv_rec.attribute9 := p5_a29;
    ddp_avlv_rec.attribute10 := p5_a30;
    ddp_avlv_rec.attribute11 := p5_a31;
    ddp_avlv_rec.attribute12 := p5_a32;
    ddp_avlv_rec.attribute13 := p5_a33;
    ddp_avlv_rec.attribute14 := p5_a34;
    ddp_avlv_rec.attribute15 := p5_a35;
    ddp_avlv_rec.org_id := rosetta_g_miss_num_map(p5_a36);
    ddp_avlv_rec.created_by := rosetta_g_miss_num_map(p5_a37);
    ddp_avlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_avlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_avlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_avlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a41);
    ddp_avlv_rec.inv_code := p5_a42;

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.lock_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_template(p_api_version  NUMBER
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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_DATE_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddx_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_avl_pvt_w.rosetta_table_copy_in_p5(ddp_avlv_tbl, p5_a0
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
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.update_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_tbl,
      ddx_avlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_avl_pvt_w.rosetta_table_copy_out_p5(ddx_avlv_tbl, p6_a0
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
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      );
  end;

  procedure update_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
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
    , p6_a17 out nocopy  DATE
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
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
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_avlv_rec okl_tmpt_set_pub.avlv_rec_type;
    ddx_avlv_rec okl_tmpt_set_pub.avlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_avlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_avlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_avlv_rec.try_id := rosetta_g_miss_num_map(p5_a2);
    ddp_avlv_rec.aes_id := rosetta_g_miss_num_map(p5_a3);
    ddp_avlv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_avlv_rec.fma_id := rosetta_g_miss_num_map(p5_a5);
    ddp_avlv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_avlv_rec.fac_code := p5_a7;
    ddp_avlv_rec.syt_code := p5_a8;
    ddp_avlv_rec.post_to_gl := p5_a9;
    ddp_avlv_rec.advance_arrears := p5_a10;
    ddp_avlv_rec.memo_yn := p5_a11;
    ddp_avlv_rec.prior_year_yn := p5_a12;
    ddp_avlv_rec.name := p5_a13;
    ddp_avlv_rec.description := p5_a14;
    ddp_avlv_rec.version := p5_a15;
    ddp_avlv_rec.factoring_synd_flag := p5_a16;
    ddp_avlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_avlv_rec.end_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_avlv_rec.accrual_yn := p5_a19;
    ddp_avlv_rec.attribute_category := p5_a20;
    ddp_avlv_rec.attribute1 := p5_a21;
    ddp_avlv_rec.attribute2 := p5_a22;
    ddp_avlv_rec.attribute3 := p5_a23;
    ddp_avlv_rec.attribute4 := p5_a24;
    ddp_avlv_rec.attribute5 := p5_a25;
    ddp_avlv_rec.attribute6 := p5_a26;
    ddp_avlv_rec.attribute7 := p5_a27;
    ddp_avlv_rec.attribute8 := p5_a28;
    ddp_avlv_rec.attribute9 := p5_a29;
    ddp_avlv_rec.attribute10 := p5_a30;
    ddp_avlv_rec.attribute11 := p5_a31;
    ddp_avlv_rec.attribute12 := p5_a32;
    ddp_avlv_rec.attribute13 := p5_a33;
    ddp_avlv_rec.attribute14 := p5_a34;
    ddp_avlv_rec.attribute15 := p5_a35;
    ddp_avlv_rec.org_id := rosetta_g_miss_num_map(p5_a36);
    ddp_avlv_rec.created_by := rosetta_g_miss_num_map(p5_a37);
    ddp_avlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_avlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_avlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_avlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a41);
    ddp_avlv_rec.inv_code := p5_a42;


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.update_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_rec,
      ddx_avlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_avlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_avlv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_avlv_rec.try_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_avlv_rec.aes_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_avlv_rec.sty_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_avlv_rec.fma_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_avlv_rec.set_of_books_id);
    p6_a7 := ddx_avlv_rec.fac_code;
    p6_a8 := ddx_avlv_rec.syt_code;
    p6_a9 := ddx_avlv_rec.post_to_gl;
    p6_a10 := ddx_avlv_rec.advance_arrears;
    p6_a11 := ddx_avlv_rec.memo_yn;
    p6_a12 := ddx_avlv_rec.prior_year_yn;
    p6_a13 := ddx_avlv_rec.name;
    p6_a14 := ddx_avlv_rec.description;
    p6_a15 := ddx_avlv_rec.version;
    p6_a16 := ddx_avlv_rec.factoring_synd_flag;
    p6_a17 := ddx_avlv_rec.start_date;
    p6_a18 := ddx_avlv_rec.end_date;
    p6_a19 := ddx_avlv_rec.accrual_yn;
    p6_a20 := ddx_avlv_rec.attribute_category;
    p6_a21 := ddx_avlv_rec.attribute1;
    p6_a22 := ddx_avlv_rec.attribute2;
    p6_a23 := ddx_avlv_rec.attribute3;
    p6_a24 := ddx_avlv_rec.attribute4;
    p6_a25 := ddx_avlv_rec.attribute5;
    p6_a26 := ddx_avlv_rec.attribute6;
    p6_a27 := ddx_avlv_rec.attribute7;
    p6_a28 := ddx_avlv_rec.attribute8;
    p6_a29 := ddx_avlv_rec.attribute9;
    p6_a30 := ddx_avlv_rec.attribute10;
    p6_a31 := ddx_avlv_rec.attribute11;
    p6_a32 := ddx_avlv_rec.attribute12;
    p6_a33 := ddx_avlv_rec.attribute13;
    p6_a34 := ddx_avlv_rec.attribute14;
    p6_a35 := ddx_avlv_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddx_avlv_rec.org_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_avlv_rec.created_by);
    p6_a38 := ddx_avlv_rec.creation_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_avlv_rec.last_updated_by);
    p6_a40 := ddx_avlv_rec.last_update_date;
    p6_a41 := rosetta_g_miss_num_map(ddx_avlv_rec.last_update_login);
    p6_a42 := ddx_avlv_rec.inv_code;
  end;

  procedure delete_template(p_api_version  NUMBER
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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_avl_pvt_w.rosetta_table_copy_in_p5(ddp_avlv_tbl, p5_a0
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
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.delete_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
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
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_avlv_rec okl_tmpt_set_pub.avlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_avlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_avlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_avlv_rec.try_id := rosetta_g_miss_num_map(p5_a2);
    ddp_avlv_rec.aes_id := rosetta_g_miss_num_map(p5_a3);
    ddp_avlv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_avlv_rec.fma_id := rosetta_g_miss_num_map(p5_a5);
    ddp_avlv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_avlv_rec.fac_code := p5_a7;
    ddp_avlv_rec.syt_code := p5_a8;
    ddp_avlv_rec.post_to_gl := p5_a9;
    ddp_avlv_rec.advance_arrears := p5_a10;
    ddp_avlv_rec.memo_yn := p5_a11;
    ddp_avlv_rec.prior_year_yn := p5_a12;
    ddp_avlv_rec.name := p5_a13;
    ddp_avlv_rec.description := p5_a14;
    ddp_avlv_rec.version := p5_a15;
    ddp_avlv_rec.factoring_synd_flag := p5_a16;
    ddp_avlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_avlv_rec.end_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_avlv_rec.accrual_yn := p5_a19;
    ddp_avlv_rec.attribute_category := p5_a20;
    ddp_avlv_rec.attribute1 := p5_a21;
    ddp_avlv_rec.attribute2 := p5_a22;
    ddp_avlv_rec.attribute3 := p5_a23;
    ddp_avlv_rec.attribute4 := p5_a24;
    ddp_avlv_rec.attribute5 := p5_a25;
    ddp_avlv_rec.attribute6 := p5_a26;
    ddp_avlv_rec.attribute7 := p5_a27;
    ddp_avlv_rec.attribute8 := p5_a28;
    ddp_avlv_rec.attribute9 := p5_a29;
    ddp_avlv_rec.attribute10 := p5_a30;
    ddp_avlv_rec.attribute11 := p5_a31;
    ddp_avlv_rec.attribute12 := p5_a32;
    ddp_avlv_rec.attribute13 := p5_a33;
    ddp_avlv_rec.attribute14 := p5_a34;
    ddp_avlv_rec.attribute15 := p5_a35;
    ddp_avlv_rec.org_id := rosetta_g_miss_num_map(p5_a36);
    ddp_avlv_rec.created_by := rosetta_g_miss_num_map(p5_a37);
    ddp_avlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_avlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_avlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_avlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a41);
    ddp_avlv_rec.inv_code := p5_a42;

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.delete_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_template(p_api_version  NUMBER
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
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_2000
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_DATE_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_avlv_tbl okl_tmpt_set_pub.avlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_avl_pvt_w.rosetta_table_copy_in_p5(ddp_avlv_tbl, p5_a0
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
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.validate_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
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
    , p5_a17  DATE := fnd_api.g_miss_date
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_avlv_rec okl_tmpt_set_pub.avlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_avlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_avlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_avlv_rec.try_id := rosetta_g_miss_num_map(p5_a2);
    ddp_avlv_rec.aes_id := rosetta_g_miss_num_map(p5_a3);
    ddp_avlv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_avlv_rec.fma_id := rosetta_g_miss_num_map(p5_a5);
    ddp_avlv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_avlv_rec.fac_code := p5_a7;
    ddp_avlv_rec.syt_code := p5_a8;
    ddp_avlv_rec.post_to_gl := p5_a9;
    ddp_avlv_rec.advance_arrears := p5_a10;
    ddp_avlv_rec.memo_yn := p5_a11;
    ddp_avlv_rec.prior_year_yn := p5_a12;
    ddp_avlv_rec.name := p5_a13;
    ddp_avlv_rec.description := p5_a14;
    ddp_avlv_rec.version := p5_a15;
    ddp_avlv_rec.factoring_synd_flag := p5_a16;
    ddp_avlv_rec.start_date := rosetta_g_miss_date_in_map(p5_a17);
    ddp_avlv_rec.end_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_avlv_rec.accrual_yn := p5_a19;
    ddp_avlv_rec.attribute_category := p5_a20;
    ddp_avlv_rec.attribute1 := p5_a21;
    ddp_avlv_rec.attribute2 := p5_a22;
    ddp_avlv_rec.attribute3 := p5_a23;
    ddp_avlv_rec.attribute4 := p5_a24;
    ddp_avlv_rec.attribute5 := p5_a25;
    ddp_avlv_rec.attribute6 := p5_a26;
    ddp_avlv_rec.attribute7 := p5_a27;
    ddp_avlv_rec.attribute8 := p5_a28;
    ddp_avlv_rec.attribute9 := p5_a29;
    ddp_avlv_rec.attribute10 := p5_a30;
    ddp_avlv_rec.attribute11 := p5_a31;
    ddp_avlv_rec.attribute12 := p5_a32;
    ddp_avlv_rec.attribute13 := p5_a33;
    ddp_avlv_rec.attribute14 := p5_a34;
    ddp_avlv_rec.attribute15 := p5_a35;
    ddp_avlv_rec.org_id := rosetta_g_miss_num_map(p5_a36);
    ddp_avlv_rec.created_by := rosetta_g_miss_num_map(p5_a37);
    ddp_avlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_avlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_avlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_avlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a41);
    ddp_avlv_rec.inv_code := p5_a42;

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.validate_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_avlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
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
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
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
  )

  as
    ddp_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddx_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_atl_pvt_w.rosetta_table_copy_in_p5(ddp_atlv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.create_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_tbl,
      ddx_atlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_atl_pvt_w.rosetta_table_copy_out_p5(ddx_atlv_tbl, p6_a0
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
      );
  end;

  procedure create_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
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
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_atlv_rec okl_tmpt_set_pub.atlv_rec_type;
    ddx_atlv_rec okl_tmpt_set_pub.atlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_atlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_atlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_atlv_rec.avl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_atlv_rec.crd_code := p5_a3;
    ddp_atlv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_atlv_rec.ae_line_type := p5_a5;
    ddp_atlv_rec.sequence_number := rosetta_g_miss_num_map(p5_a6);
    ddp_atlv_rec.description := p5_a7;
    ddp_atlv_rec.percentage := rosetta_g_miss_num_map(p5_a8);
    ddp_atlv_rec.account_builder_yn := p5_a9;
    ddp_atlv_rec.attribute_category := p5_a10;
    ddp_atlv_rec.attribute1 := p5_a11;
    ddp_atlv_rec.attribute2 := p5_a12;
    ddp_atlv_rec.attribute3 := p5_a13;
    ddp_atlv_rec.attribute4 := p5_a14;
    ddp_atlv_rec.attribute5 := p5_a15;
    ddp_atlv_rec.attribute6 := p5_a16;
    ddp_atlv_rec.attribute7 := p5_a17;
    ddp_atlv_rec.attribute8 := p5_a18;
    ddp_atlv_rec.attribute9 := p5_a19;
    ddp_atlv_rec.attribute10 := p5_a20;
    ddp_atlv_rec.attribute11 := p5_a21;
    ddp_atlv_rec.attribute12 := p5_a22;
    ddp_atlv_rec.attribute13 := p5_a23;
    ddp_atlv_rec.attribute14 := p5_a24;
    ddp_atlv_rec.attribute15 := p5_a25;
    ddp_atlv_rec.avl_tbl_index := rosetta_g_miss_num_map(p5_a26);
    ddp_atlv_rec.org_id := rosetta_g_miss_num_map(p5_a27);
    ddp_atlv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_atlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_atlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_atlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_atlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.create_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_rec,
      ddx_atlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_atlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_atlv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_atlv_rec.avl_id);
    p6_a3 := ddx_atlv_rec.crd_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_atlv_rec.code_combination_id);
    p6_a5 := ddx_atlv_rec.ae_line_type;
    p6_a6 := rosetta_g_miss_num_map(ddx_atlv_rec.sequence_number);
    p6_a7 := ddx_atlv_rec.description;
    p6_a8 := rosetta_g_miss_num_map(ddx_atlv_rec.percentage);
    p6_a9 := ddx_atlv_rec.account_builder_yn;
    p6_a10 := ddx_atlv_rec.attribute_category;
    p6_a11 := ddx_atlv_rec.attribute1;
    p6_a12 := ddx_atlv_rec.attribute2;
    p6_a13 := ddx_atlv_rec.attribute3;
    p6_a14 := ddx_atlv_rec.attribute4;
    p6_a15 := ddx_atlv_rec.attribute5;
    p6_a16 := ddx_atlv_rec.attribute6;
    p6_a17 := ddx_atlv_rec.attribute7;
    p6_a18 := ddx_atlv_rec.attribute8;
    p6_a19 := ddx_atlv_rec.attribute9;
    p6_a20 := ddx_atlv_rec.attribute10;
    p6_a21 := ddx_atlv_rec.attribute11;
    p6_a22 := ddx_atlv_rec.attribute12;
    p6_a23 := ddx_atlv_rec.attribute13;
    p6_a24 := ddx_atlv_rec.attribute14;
    p6_a25 := ddx_atlv_rec.attribute15;
    p6_a26 := rosetta_g_miss_num_map(ddx_atlv_rec.avl_tbl_index);
    p6_a27 := rosetta_g_miss_num_map(ddx_atlv_rec.org_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_atlv_rec.created_by);
    p6_a29 := ddx_atlv_rec.creation_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_atlv_rec.last_updated_by);
    p6_a31 := ddx_atlv_rec.last_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_atlv_rec.last_update_login);
  end;

  procedure lock_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
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
  )

  as
    ddp_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_atl_pvt_w.rosetta_table_copy_in_p5(ddp_atlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.lock_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_atlv_rec okl_tmpt_set_pub.atlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_atlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_atlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_atlv_rec.avl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_atlv_rec.crd_code := p5_a3;
    ddp_atlv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_atlv_rec.ae_line_type := p5_a5;
    ddp_atlv_rec.sequence_number := rosetta_g_miss_num_map(p5_a6);
    ddp_atlv_rec.description := p5_a7;
    ddp_atlv_rec.percentage := rosetta_g_miss_num_map(p5_a8);
    ddp_atlv_rec.account_builder_yn := p5_a9;
    ddp_atlv_rec.attribute_category := p5_a10;
    ddp_atlv_rec.attribute1 := p5_a11;
    ddp_atlv_rec.attribute2 := p5_a12;
    ddp_atlv_rec.attribute3 := p5_a13;
    ddp_atlv_rec.attribute4 := p5_a14;
    ddp_atlv_rec.attribute5 := p5_a15;
    ddp_atlv_rec.attribute6 := p5_a16;
    ddp_atlv_rec.attribute7 := p5_a17;
    ddp_atlv_rec.attribute8 := p5_a18;
    ddp_atlv_rec.attribute9 := p5_a19;
    ddp_atlv_rec.attribute10 := p5_a20;
    ddp_atlv_rec.attribute11 := p5_a21;
    ddp_atlv_rec.attribute12 := p5_a22;
    ddp_atlv_rec.attribute13 := p5_a23;
    ddp_atlv_rec.attribute14 := p5_a24;
    ddp_atlv_rec.attribute15 := p5_a25;
    ddp_atlv_rec.avl_tbl_index := rosetta_g_miss_num_map(p5_a26);
    ddp_atlv_rec.org_id := rosetta_g_miss_num_map(p5_a27);
    ddp_atlv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_atlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_atlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_atlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_atlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.lock_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
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
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
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
  )

  as
    ddp_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddx_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_atl_pvt_w.rosetta_table_copy_in_p5(ddp_atlv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.update_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_tbl,
      ddx_atlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_atl_pvt_w.rosetta_table_copy_out_p5(ddx_atlv_tbl, p6_a0
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
      );
  end;

  procedure update_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
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
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_atlv_rec okl_tmpt_set_pub.atlv_rec_type;
    ddx_atlv_rec okl_tmpt_set_pub.atlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_atlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_atlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_atlv_rec.avl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_atlv_rec.crd_code := p5_a3;
    ddp_atlv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_atlv_rec.ae_line_type := p5_a5;
    ddp_atlv_rec.sequence_number := rosetta_g_miss_num_map(p5_a6);
    ddp_atlv_rec.description := p5_a7;
    ddp_atlv_rec.percentage := rosetta_g_miss_num_map(p5_a8);
    ddp_atlv_rec.account_builder_yn := p5_a9;
    ddp_atlv_rec.attribute_category := p5_a10;
    ddp_atlv_rec.attribute1 := p5_a11;
    ddp_atlv_rec.attribute2 := p5_a12;
    ddp_atlv_rec.attribute3 := p5_a13;
    ddp_atlv_rec.attribute4 := p5_a14;
    ddp_atlv_rec.attribute5 := p5_a15;
    ddp_atlv_rec.attribute6 := p5_a16;
    ddp_atlv_rec.attribute7 := p5_a17;
    ddp_atlv_rec.attribute8 := p5_a18;
    ddp_atlv_rec.attribute9 := p5_a19;
    ddp_atlv_rec.attribute10 := p5_a20;
    ddp_atlv_rec.attribute11 := p5_a21;
    ddp_atlv_rec.attribute12 := p5_a22;
    ddp_atlv_rec.attribute13 := p5_a23;
    ddp_atlv_rec.attribute14 := p5_a24;
    ddp_atlv_rec.attribute15 := p5_a25;
    ddp_atlv_rec.avl_tbl_index := rosetta_g_miss_num_map(p5_a26);
    ddp_atlv_rec.org_id := rosetta_g_miss_num_map(p5_a27);
    ddp_atlv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_atlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_atlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_atlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_atlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);


    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.update_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_rec,
      ddx_atlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_atlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_atlv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_atlv_rec.avl_id);
    p6_a3 := ddx_atlv_rec.crd_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_atlv_rec.code_combination_id);
    p6_a5 := ddx_atlv_rec.ae_line_type;
    p6_a6 := rosetta_g_miss_num_map(ddx_atlv_rec.sequence_number);
    p6_a7 := ddx_atlv_rec.description;
    p6_a8 := rosetta_g_miss_num_map(ddx_atlv_rec.percentage);
    p6_a9 := ddx_atlv_rec.account_builder_yn;
    p6_a10 := ddx_atlv_rec.attribute_category;
    p6_a11 := ddx_atlv_rec.attribute1;
    p6_a12 := ddx_atlv_rec.attribute2;
    p6_a13 := ddx_atlv_rec.attribute3;
    p6_a14 := ddx_atlv_rec.attribute4;
    p6_a15 := ddx_atlv_rec.attribute5;
    p6_a16 := ddx_atlv_rec.attribute6;
    p6_a17 := ddx_atlv_rec.attribute7;
    p6_a18 := ddx_atlv_rec.attribute8;
    p6_a19 := ddx_atlv_rec.attribute9;
    p6_a20 := ddx_atlv_rec.attribute10;
    p6_a21 := ddx_atlv_rec.attribute11;
    p6_a22 := ddx_atlv_rec.attribute12;
    p6_a23 := ddx_atlv_rec.attribute13;
    p6_a24 := ddx_atlv_rec.attribute14;
    p6_a25 := ddx_atlv_rec.attribute15;
    p6_a26 := rosetta_g_miss_num_map(ddx_atlv_rec.avl_tbl_index);
    p6_a27 := rosetta_g_miss_num_map(ddx_atlv_rec.org_id);
    p6_a28 := rosetta_g_miss_num_map(ddx_atlv_rec.created_by);
    p6_a29 := ddx_atlv_rec.creation_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_atlv_rec.last_updated_by);
    p6_a31 := ddx_atlv_rec.last_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_atlv_rec.last_update_login);
  end;

  procedure delete_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
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
  )

  as
    ddp_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_atl_pvt_w.rosetta_table_copy_in_p5(ddp_atlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.delete_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_atlv_rec okl_tmpt_set_pub.atlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_atlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_atlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_atlv_rec.avl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_atlv_rec.crd_code := p5_a3;
    ddp_atlv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_atlv_rec.ae_line_type := p5_a5;
    ddp_atlv_rec.sequence_number := rosetta_g_miss_num_map(p5_a6);
    ddp_atlv_rec.description := p5_a7;
    ddp_atlv_rec.percentage := rosetta_g_miss_num_map(p5_a8);
    ddp_atlv_rec.account_builder_yn := p5_a9;
    ddp_atlv_rec.attribute_category := p5_a10;
    ddp_atlv_rec.attribute1 := p5_a11;
    ddp_atlv_rec.attribute2 := p5_a12;
    ddp_atlv_rec.attribute3 := p5_a13;
    ddp_atlv_rec.attribute4 := p5_a14;
    ddp_atlv_rec.attribute5 := p5_a15;
    ddp_atlv_rec.attribute6 := p5_a16;
    ddp_atlv_rec.attribute7 := p5_a17;
    ddp_atlv_rec.attribute8 := p5_a18;
    ddp_atlv_rec.attribute9 := p5_a19;
    ddp_atlv_rec.attribute10 := p5_a20;
    ddp_atlv_rec.attribute11 := p5_a21;
    ddp_atlv_rec.attribute12 := p5_a22;
    ddp_atlv_rec.attribute13 := p5_a23;
    ddp_atlv_rec.attribute14 := p5_a24;
    ddp_atlv_rec.attribute15 := p5_a25;
    ddp_atlv_rec.avl_tbl_index := rosetta_g_miss_num_map(p5_a26);
    ddp_atlv_rec.org_id := rosetta_g_miss_num_map(p5_a27);
    ddp_atlv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_atlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_atlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_atlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_atlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.delete_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
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
  )

  as
    ddp_atlv_tbl okl_tmpt_set_pub.atlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_atl_pvt_w.rosetta_table_copy_in_p5(ddp_atlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.validate_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_tmpt_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_atlv_rec okl_tmpt_set_pub.atlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_atlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_atlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_atlv_rec.avl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_atlv_rec.crd_code := p5_a3;
    ddp_atlv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a4);
    ddp_atlv_rec.ae_line_type := p5_a5;
    ddp_atlv_rec.sequence_number := rosetta_g_miss_num_map(p5_a6);
    ddp_atlv_rec.description := p5_a7;
    ddp_atlv_rec.percentage := rosetta_g_miss_num_map(p5_a8);
    ddp_atlv_rec.account_builder_yn := p5_a9;
    ddp_atlv_rec.attribute_category := p5_a10;
    ddp_atlv_rec.attribute1 := p5_a11;
    ddp_atlv_rec.attribute2 := p5_a12;
    ddp_atlv_rec.attribute3 := p5_a13;
    ddp_atlv_rec.attribute4 := p5_a14;
    ddp_atlv_rec.attribute5 := p5_a15;
    ddp_atlv_rec.attribute6 := p5_a16;
    ddp_atlv_rec.attribute7 := p5_a17;
    ddp_atlv_rec.attribute8 := p5_a18;
    ddp_atlv_rec.attribute9 := p5_a19;
    ddp_atlv_rec.attribute10 := p5_a20;
    ddp_atlv_rec.attribute11 := p5_a21;
    ddp_atlv_rec.attribute12 := p5_a22;
    ddp_atlv_rec.attribute13 := p5_a23;
    ddp_atlv_rec.attribute14 := p5_a24;
    ddp_atlv_rec.attribute15 := p5_a25;
    ddp_atlv_rec.avl_tbl_index := rosetta_g_miss_num_map(p5_a26);
    ddp_atlv_rec.org_id := rosetta_g_miss_num_map(p5_a27);
    ddp_atlv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_atlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_atlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_atlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_atlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);

    -- here's the delegated call to the old PL/SQL routine
    okl_tmpt_set_pub.validate_tmpt_lines(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_atlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_tmpt_set_pub_w;

/
