--------------------------------------------------------
--  DDL for Package Body OKL_ACC_GEN_RULE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACC_GEN_RULE_PUB_W" as
  /* $Header: OKLUAGRB.pls 120.1 2005/07/07 13:33:56 dkagrawa noship $ */
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

  procedure create_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_500
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
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_DATE_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddp_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddx_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddx_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agrv_rec.ae_line_type := p5_a2;
    ddp_agrv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agrv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_agrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_agrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_agrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_agrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    okl_aul_pvt_w.rosetta_table_copy_in_p5(ddp_aulv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.create_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_rec,
      ddp_aulv_tbl,
      ddx_agrv_rec,
      ddx_aulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_agrv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_agrv_rec.object_version_number);
    p7_a2 := ddx_agrv_rec.ae_line_type;
    p7_a3 := rosetta_g_miss_num_map(ddx_agrv_rec.set_of_books_id);
    p7_a4 := rosetta_g_miss_num_map(ddx_agrv_rec.org_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_agrv_rec.created_by);
    p7_a6 := ddx_agrv_rec.creation_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_agrv_rec.last_updated_by);
    p7_a8 := ddx_agrv_rec.last_update_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_agrv_rec.last_update_login);

    okl_aul_pvt_w.rosetta_table_copy_out_p5(ddx_aulv_tbl, p8_a0
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
      );
  end;

  procedure update_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_500
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
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_DATE_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddp_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddx_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddx_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agrv_rec.ae_line_type := p5_a2;
    ddp_agrv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agrv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_agrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_agrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_agrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_agrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    okl_aul_pvt_w.rosetta_table_copy_in_p5(ddp_aulv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.update_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_rec,
      ddp_aulv_tbl,
      ddx_agrv_rec,
      ddx_aulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_agrv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_agrv_rec.object_version_number);
    p7_a2 := ddx_agrv_rec.ae_line_type;
    p7_a3 := rosetta_g_miss_num_map(ddx_agrv_rec.set_of_books_id);
    p7_a4 := rosetta_g_miss_num_map(ddx_agrv_rec.org_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_agrv_rec.created_by);
    p7_a6 := ddx_agrv_rec.creation_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_agrv_rec.last_updated_by);
    p7_a8 := ddx_agrv_rec.last_update_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_agrv_rec.last_update_login);

    okl_aul_pvt_w.rosetta_table_copy_out_p5(ddx_aulv_tbl, p8_a0
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
      );
  end;

  procedure validate_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_500
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
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddp_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agrv_rec.ae_line_type := p5_a2;
    ddp_agrv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agrv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_agrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_agrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_agrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_agrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    okl_aul_pvt_w.rosetta_table_copy_in_p5(ddp_aulv_tbl, p6_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.validate_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_rec,
      ddp_aulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_agrv_tbl okl_acc_gen_rule_pub.agrv_tbl_type;
    ddx_agrv_tbl okl_acc_gen_rule_pub.agrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agr_pvt_w.rosetta_table_copy_in_p5(ddp_agrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.create_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_tbl,
      ddx_agrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_agr_pvt_w.rosetta_table_copy_out_p5(ddx_agrv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );
  end;

  procedure create_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddx_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agrv_rec.ae_line_type := p5_a2;
    ddp_agrv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agrv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_agrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_agrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_agrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_agrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.create_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_rec,
      ddx_agrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_agrv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_agrv_rec.object_version_number);
    p6_a2 := ddx_agrv_rec.ae_line_type;
    p6_a3 := rosetta_g_miss_num_map(ddx_agrv_rec.set_of_books_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_agrv_rec.org_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_agrv_rec.created_by);
    p6_a6 := ddx_agrv_rec.creation_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_agrv_rec.last_updated_by);
    p6_a8 := ddx_agrv_rec.last_update_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_agrv_rec.last_update_login);
  end;

  procedure lock_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_agrv_tbl okl_acc_gen_rule_pub.agrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agr_pvt_w.rosetta_table_copy_in_p5(ddp_agrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.lock_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agrv_rec.ae_line_type := p5_a2;
    ddp_agrv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agrv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_agrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_agrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_agrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_agrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.lock_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_agrv_tbl okl_acc_gen_rule_pub.agrv_tbl_type;
    ddx_agrv_tbl okl_acc_gen_rule_pub.agrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agr_pvt_w.rosetta_table_copy_in_p5(ddp_agrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.update_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_tbl,
      ddx_agrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_agr_pvt_w.rosetta_table_copy_out_p5(ddx_agrv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );
  end;

  procedure update_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddx_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agrv_rec.ae_line_type := p5_a2;
    ddp_agrv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agrv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_agrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_agrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_agrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_agrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.update_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_rec,
      ddx_agrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_agrv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_agrv_rec.object_version_number);
    p6_a2 := ddx_agrv_rec.ae_line_type;
    p6_a3 := rosetta_g_miss_num_map(ddx_agrv_rec.set_of_books_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_agrv_rec.org_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_agrv_rec.created_by);
    p6_a6 := ddx_agrv_rec.creation_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_agrv_rec.last_updated_by);
    p6_a8 := ddx_agrv_rec.last_update_date;
    p6_a9 := rosetta_g_miss_num_map(ddx_agrv_rec.last_update_login);
  end;

  procedure delete_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_agrv_tbl okl_acc_gen_rule_pub.agrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agr_pvt_w.rosetta_table_copy_in_p5(ddp_agrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.delete_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agrv_rec.ae_line_type := p5_a2;
    ddp_agrv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agrv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_agrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_agrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_agrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_agrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.delete_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_NUMBER_TABLE
  )

  as
    ddp_agrv_tbl okl_acc_gen_rule_pub.agrv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agr_pvt_w.rosetta_table_copy_in_p5(ddp_agrv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.validate_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acc_gen_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
  )

  as
    ddp_agrv_rec okl_acc_gen_rule_pub.agrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agrv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agrv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agrv_rec.ae_line_type := p5_a2;
    ddp_agrv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agrv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agrv_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_agrv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_agrv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a7);
    ddp_agrv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_agrv_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.validate_acc_gen_rule(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddx_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aul_pvt_w.rosetta_table_copy_in_p5(ddp_aulv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.create_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_tbl,
      ddx_aulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_aul_pvt_w.rosetta_table_copy_out_p5(ddx_aulv_tbl, p6_a0
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
      );
  end;

  procedure create_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
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
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_aulv_rec okl_acc_gen_rule_pub.aulv_rec_type;
    ddx_aulv_rec okl_acc_gen_rule_pub.aulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aulv_rec.source := p5_a2;
    ddp_aulv_rec.segment := p5_a3;
    ddp_aulv_rec.segment_number := rosetta_g_miss_num_map(p5_a4);
    ddp_aulv_rec.constants := p5_a5;
    ddp_aulv_rec.attribute_category := p5_a6;
    ddp_aulv_rec.attribute1 := p5_a7;
    ddp_aulv_rec.attribute2 := p5_a8;
    ddp_aulv_rec.attribute3 := p5_a9;
    ddp_aulv_rec.attribute4 := p5_a10;
    ddp_aulv_rec.attribute5 := p5_a11;
    ddp_aulv_rec.attribute6 := p5_a12;
    ddp_aulv_rec.attribute7 := p5_a13;
    ddp_aulv_rec.attribute8 := p5_a14;
    ddp_aulv_rec.attribute9 := p5_a15;
    ddp_aulv_rec.attribute10 := p5_a16;
    ddp_aulv_rec.attribute11 := p5_a17;
    ddp_aulv_rec.attribute12 := p5_a18;
    ddp_aulv_rec.attribute13 := p5_a19;
    ddp_aulv_rec.attribute14 := p5_a20;
    ddp_aulv_rec.attribute15 := p5_a21;
    ddp_aulv_rec.agr_id := rosetta_g_miss_num_map(p5_a22);
    ddp_aulv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_aulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_aulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_aulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_aulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.create_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_rec,
      ddx_aulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aulv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aulv_rec.object_version_number);
    p6_a2 := ddx_aulv_rec.source;
    p6_a3 := ddx_aulv_rec.segment;
    p6_a4 := rosetta_g_miss_num_map(ddx_aulv_rec.segment_number);
    p6_a5 := ddx_aulv_rec.constants;
    p6_a6 := ddx_aulv_rec.attribute_category;
    p6_a7 := ddx_aulv_rec.attribute1;
    p6_a8 := ddx_aulv_rec.attribute2;
    p6_a9 := ddx_aulv_rec.attribute3;
    p6_a10 := ddx_aulv_rec.attribute4;
    p6_a11 := ddx_aulv_rec.attribute5;
    p6_a12 := ddx_aulv_rec.attribute6;
    p6_a13 := ddx_aulv_rec.attribute7;
    p6_a14 := ddx_aulv_rec.attribute8;
    p6_a15 := ddx_aulv_rec.attribute9;
    p6_a16 := ddx_aulv_rec.attribute10;
    p6_a17 := ddx_aulv_rec.attribute11;
    p6_a18 := ddx_aulv_rec.attribute12;
    p6_a19 := ddx_aulv_rec.attribute13;
    p6_a20 := ddx_aulv_rec.attribute14;
    p6_a21 := ddx_aulv_rec.attribute15;
    p6_a22 := rosetta_g_miss_num_map(ddx_aulv_rec.agr_id);
    p6_a23 := rosetta_g_miss_num_map(ddx_aulv_rec.created_by);
    p6_a24 := ddx_aulv_rec.creation_date;
    p6_a25 := rosetta_g_miss_num_map(ddx_aulv_rec.last_updated_by);
    p6_a26 := ddx_aulv_rec.last_update_date;
    p6_a27 := rosetta_g_miss_num_map(ddx_aulv_rec.last_update_login);
  end;

  procedure lock_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aul_pvt_w.rosetta_table_copy_in_p5(ddp_aulv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.lock_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_aulv_rec okl_acc_gen_rule_pub.aulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aulv_rec.source := p5_a2;
    ddp_aulv_rec.segment := p5_a3;
    ddp_aulv_rec.segment_number := rosetta_g_miss_num_map(p5_a4);
    ddp_aulv_rec.constants := p5_a5;
    ddp_aulv_rec.attribute_category := p5_a6;
    ddp_aulv_rec.attribute1 := p5_a7;
    ddp_aulv_rec.attribute2 := p5_a8;
    ddp_aulv_rec.attribute3 := p5_a9;
    ddp_aulv_rec.attribute4 := p5_a10;
    ddp_aulv_rec.attribute5 := p5_a11;
    ddp_aulv_rec.attribute6 := p5_a12;
    ddp_aulv_rec.attribute7 := p5_a13;
    ddp_aulv_rec.attribute8 := p5_a14;
    ddp_aulv_rec.attribute9 := p5_a15;
    ddp_aulv_rec.attribute10 := p5_a16;
    ddp_aulv_rec.attribute11 := p5_a17;
    ddp_aulv_rec.attribute12 := p5_a18;
    ddp_aulv_rec.attribute13 := p5_a19;
    ddp_aulv_rec.attribute14 := p5_a20;
    ddp_aulv_rec.attribute15 := p5_a21;
    ddp_aulv_rec.agr_id := rosetta_g_miss_num_map(p5_a22);
    ddp_aulv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_aulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_aulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_aulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_aulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.lock_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_DATE_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddx_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aul_pvt_w.rosetta_table_copy_in_p5(ddp_aulv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.update_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_tbl,
      ddx_aulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_aul_pvt_w.rosetta_table_copy_out_p5(ddx_aulv_tbl, p6_a0
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
      );
  end;

  procedure update_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
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
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_aulv_rec okl_acc_gen_rule_pub.aulv_rec_type;
    ddx_aulv_rec okl_acc_gen_rule_pub.aulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aulv_rec.source := p5_a2;
    ddp_aulv_rec.segment := p5_a3;
    ddp_aulv_rec.segment_number := rosetta_g_miss_num_map(p5_a4);
    ddp_aulv_rec.constants := p5_a5;
    ddp_aulv_rec.attribute_category := p5_a6;
    ddp_aulv_rec.attribute1 := p5_a7;
    ddp_aulv_rec.attribute2 := p5_a8;
    ddp_aulv_rec.attribute3 := p5_a9;
    ddp_aulv_rec.attribute4 := p5_a10;
    ddp_aulv_rec.attribute5 := p5_a11;
    ddp_aulv_rec.attribute6 := p5_a12;
    ddp_aulv_rec.attribute7 := p5_a13;
    ddp_aulv_rec.attribute8 := p5_a14;
    ddp_aulv_rec.attribute9 := p5_a15;
    ddp_aulv_rec.attribute10 := p5_a16;
    ddp_aulv_rec.attribute11 := p5_a17;
    ddp_aulv_rec.attribute12 := p5_a18;
    ddp_aulv_rec.attribute13 := p5_a19;
    ddp_aulv_rec.attribute14 := p5_a20;
    ddp_aulv_rec.attribute15 := p5_a21;
    ddp_aulv_rec.agr_id := rosetta_g_miss_num_map(p5_a22);
    ddp_aulv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_aulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_aulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_aulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_aulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.update_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_rec,
      ddx_aulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_aulv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_aulv_rec.object_version_number);
    p6_a2 := ddx_aulv_rec.source;
    p6_a3 := ddx_aulv_rec.segment;
    p6_a4 := rosetta_g_miss_num_map(ddx_aulv_rec.segment_number);
    p6_a5 := ddx_aulv_rec.constants;
    p6_a6 := ddx_aulv_rec.attribute_category;
    p6_a7 := ddx_aulv_rec.attribute1;
    p6_a8 := ddx_aulv_rec.attribute2;
    p6_a9 := ddx_aulv_rec.attribute3;
    p6_a10 := ddx_aulv_rec.attribute4;
    p6_a11 := ddx_aulv_rec.attribute5;
    p6_a12 := ddx_aulv_rec.attribute6;
    p6_a13 := ddx_aulv_rec.attribute7;
    p6_a14 := ddx_aulv_rec.attribute8;
    p6_a15 := ddx_aulv_rec.attribute9;
    p6_a16 := ddx_aulv_rec.attribute10;
    p6_a17 := ddx_aulv_rec.attribute11;
    p6_a18 := ddx_aulv_rec.attribute12;
    p6_a19 := ddx_aulv_rec.attribute13;
    p6_a20 := ddx_aulv_rec.attribute14;
    p6_a21 := ddx_aulv_rec.attribute15;
    p6_a22 := rosetta_g_miss_num_map(ddx_aulv_rec.agr_id);
    p6_a23 := rosetta_g_miss_num_map(ddx_aulv_rec.created_by);
    p6_a24 := ddx_aulv_rec.creation_date;
    p6_a25 := rosetta_g_miss_num_map(ddx_aulv_rec.last_updated_by);
    p6_a26 := ddx_aulv_rec.last_update_date;
    p6_a27 := rosetta_g_miss_num_map(ddx_aulv_rec.last_update_login);
  end;

  procedure delete_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aul_pvt_w.rosetta_table_copy_in_p5(ddp_aulv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.delete_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_aulv_rec okl_acc_gen_rule_pub.aulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aulv_rec.source := p5_a2;
    ddp_aulv_rec.segment := p5_a3;
    ddp_aulv_rec.segment_number := rosetta_g_miss_num_map(p5_a4);
    ddp_aulv_rec.constants := p5_a5;
    ddp_aulv_rec.attribute_category := p5_a6;
    ddp_aulv_rec.attribute1 := p5_a7;
    ddp_aulv_rec.attribute2 := p5_a8;
    ddp_aulv_rec.attribute3 := p5_a9;
    ddp_aulv_rec.attribute4 := p5_a10;
    ddp_aulv_rec.attribute5 := p5_a11;
    ddp_aulv_rec.attribute6 := p5_a12;
    ddp_aulv_rec.attribute7 := p5_a13;
    ddp_aulv_rec.attribute8 := p5_a14;
    ddp_aulv_rec.attribute9 := p5_a15;
    ddp_aulv_rec.attribute10 := p5_a16;
    ddp_aulv_rec.attribute11 := p5_a17;
    ddp_aulv_rec.attribute12 := p5_a18;
    ddp_aulv_rec.attribute13 := p5_a19;
    ddp_aulv_rec.attribute14 := p5_a20;
    ddp_aulv_rec.attribute15 := p5_a21;
    ddp_aulv_rec.agr_id := rosetta_g_miss_num_map(p5_a22);
    ddp_aulv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_aulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_aulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_aulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_aulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.delete_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
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
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_DATE_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_aulv_tbl okl_acc_gen_rule_pub.aulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_aul_pvt_w.rosetta_table_copy_in_p5(ddp_aulv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.validate_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acc_gen_rule_lns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  NUMBER := 0-1962.0724
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_aulv_rec okl_acc_gen_rule_pub.aulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_aulv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_aulv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_aulv_rec.source := p5_a2;
    ddp_aulv_rec.segment := p5_a3;
    ddp_aulv_rec.segment_number := rosetta_g_miss_num_map(p5_a4);
    ddp_aulv_rec.constants := p5_a5;
    ddp_aulv_rec.attribute_category := p5_a6;
    ddp_aulv_rec.attribute1 := p5_a7;
    ddp_aulv_rec.attribute2 := p5_a8;
    ddp_aulv_rec.attribute3 := p5_a9;
    ddp_aulv_rec.attribute4 := p5_a10;
    ddp_aulv_rec.attribute5 := p5_a11;
    ddp_aulv_rec.attribute6 := p5_a12;
    ddp_aulv_rec.attribute7 := p5_a13;
    ddp_aulv_rec.attribute8 := p5_a14;
    ddp_aulv_rec.attribute9 := p5_a15;
    ddp_aulv_rec.attribute10 := p5_a16;
    ddp_aulv_rec.attribute11 := p5_a17;
    ddp_aulv_rec.attribute12 := p5_a18;
    ddp_aulv_rec.attribute13 := p5_a19;
    ddp_aulv_rec.attribute14 := p5_a20;
    ddp_aulv_rec.attribute15 := p5_a21;
    ddp_aulv_rec.agr_id := rosetta_g_miss_num_map(p5_a22);
    ddp_aulv_rec.created_by := rosetta_g_miss_num_map(p5_a23);
    ddp_aulv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_aulv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a25);
    ddp_aulv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_aulv_rec.last_update_login := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_gen_rule_pub.validate_acc_gen_rule_lns(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_aulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_acc_gen_rule_pub_w;

/
