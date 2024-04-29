--------------------------------------------------------
--  DDL for Package Body OKL_ACC_GROUP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACC_GROUP_PUB_W" as
  /* $Header: OKLUAGCB.pls 120.1 2005/07/07 13:34:15 dkagrawa noship $ */
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

  procedure create_acc_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_DATE_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_DATE_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
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
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddp_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddx_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddx_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agcv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agcv_rec.acc_group_code := p5_a3;
    ddp_agcv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agcv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_agcv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    okl_agb_pvt_w.rosetta_table_copy_in_p5(ddp_agbv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.create_acc_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_rec,
      ddp_agbv_tbl,
      ddx_agcv_rec,
      ddx_agbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_agcv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_agcv_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_agcv_rec.code_combination_id);
    p7_a3 := ddx_agcv_rec.acc_group_code;
    p7_a4 := rosetta_g_miss_num_map(ddx_agcv_rec.org_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_agcv_rec.set_of_books_id);
    p7_a6 := rosetta_g_miss_num_map(ddx_agcv_rec.created_by);
    p7_a7 := ddx_agcv_rec.creation_date;
    p7_a8 := rosetta_g_miss_num_map(ddx_agcv_rec.last_updated_by);
    p7_a9 := ddx_agcv_rec.last_update_date;
    p7_a10 := rosetta_g_miss_num_map(ddx_agcv_rec.last_update_login);

    okl_agb_pvt_w.rosetta_table_copy_out_p5(ddx_agbv_tbl, p8_a0
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
      );
  end;

  procedure update_acc_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_DATE_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_DATE_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
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
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddp_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddx_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddx_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agcv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agcv_rec.acc_group_code := p5_a3;
    ddp_agcv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agcv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_agcv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    okl_agb_pvt_w.rosetta_table_copy_in_p5(ddp_agbv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.update_acc_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_rec,
      ddp_agbv_tbl,
      ddx_agcv_rec,
      ddx_agbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_agcv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_agcv_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_agcv_rec.code_combination_id);
    p7_a3 := ddx_agcv_rec.acc_group_code;
    p7_a4 := rosetta_g_miss_num_map(ddx_agcv_rec.org_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_agcv_rec.set_of_books_id);
    p7_a6 := rosetta_g_miss_num_map(ddx_agcv_rec.created_by);
    p7_a7 := ddx_agcv_rec.creation_date;
    p7_a8 := rosetta_g_miss_num_map(ddx_agcv_rec.last_updated_by);
    p7_a9 := ddx_agcv_rec.last_update_date;
    p7_a10 := rosetta_g_miss_num_map(ddx_agcv_rec.last_update_login);

    okl_agb_pvt_w.rosetta_table_copy_out_p5(ddx_agbv_tbl, p8_a0
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
      );
  end;

  procedure validate_acc_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_DATE_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_DATE_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddp_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agcv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agcv_rec.acc_group_code := p5_a3;
    ddp_agcv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agcv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_agcv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    okl_agb_pvt_w.rosetta_table_copy_in_p5(ddp_agbv_tbl, p6_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.validate_acc_group(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_rec,
      ddp_agbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_agcv_tbl okl_acc_group_pub.agcv_tbl_type;
    ddx_agcv_tbl okl_acc_group_pub.agcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agc_pvt_w.rosetta_table_copy_in_p5(ddp_agcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.create_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_tbl,
      ddx_agcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_agc_pvt_w.rosetta_table_copy_out_p5(ddx_agcv_tbl, p6_a0
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
      );
  end;

  procedure create_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddx_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agcv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agcv_rec.acc_group_code := p5_a3;
    ddp_agcv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agcv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_agcv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.create_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_rec,
      ddx_agcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_agcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_agcv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_agcv_rec.code_combination_id);
    p6_a3 := ddx_agcv_rec.acc_group_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_agcv_rec.org_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_agcv_rec.set_of_books_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_agcv_rec.created_by);
    p6_a7 := ddx_agcv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_agcv_rec.last_updated_by);
    p6_a9 := ddx_agcv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_agcv_rec.last_update_login);
  end;

  procedure lock_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_agcv_tbl okl_acc_group_pub.agcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agc_pvt_w.rosetta_table_copy_in_p5(ddp_agcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.lock_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agcv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agcv_rec.acc_group_code := p5_a3;
    ddp_agcv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agcv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_agcv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.lock_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_agcv_tbl okl_acc_group_pub.agcv_tbl_type;
    ddx_agcv_tbl okl_acc_group_pub.agcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agc_pvt_w.rosetta_table_copy_in_p5(ddp_agcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.update_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_tbl,
      ddx_agcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_agc_pvt_w.rosetta_table_copy_out_p5(ddx_agcv_tbl, p6_a0
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
      );
  end;

  procedure update_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddx_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agcv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agcv_rec.acc_group_code := p5_a3;
    ddp_agcv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agcv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_agcv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.update_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_rec,
      ddx_agcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_agcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_agcv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_agcv_rec.code_combination_id);
    p6_a3 := ddx_agcv_rec.acc_group_code;
    p6_a4 := rosetta_g_miss_num_map(ddx_agcv_rec.org_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_agcv_rec.set_of_books_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_agcv_rec.created_by);
    p6_a7 := ddx_agcv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_agcv_rec.last_updated_by);
    p6_a9 := ddx_agcv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_agcv_rec.last_update_login);
  end;

  procedure delete_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_agcv_tbl okl_acc_group_pub.agcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agc_pvt_w.rosetta_table_copy_in_p5(ddp_agcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.delete_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agcv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agcv_rec.acc_group_code := p5_a3;
    ddp_agcv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agcv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_agcv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.delete_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_agcv_tbl okl_acc_group_pub.agcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agc_pvt_w.rosetta_table_copy_in_p5(ddp_agcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.validate_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acc_ccid(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agcv_rec okl_acc_group_pub.agcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agcv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agcv_rec.acc_group_code := p5_a3;
    ddp_agcv_rec.org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_agcv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a5);
    ddp_agcv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.validate_acc_ccid(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddx_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agb_pvt_w.rosetta_table_copy_in_p5(ddp_agbv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.create_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_tbl,
      ddx_agbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_agb_pvt_w.rosetta_table_copy_out_p5(ddx_agbv_tbl, p6_a0
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
      );
  end;

  procedure create_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agbv_rec okl_acc_group_pub.agbv_rec_type;
    ddx_agbv_rec okl_acc_group_pub.agbv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agbv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agbv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agbv_rec.acc_group_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agbv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agbv_rec.date_balance := rosetta_g_miss_date_in_map(p5_a4);
    ddp_agbv_rec.amount := rosetta_g_miss_num_map(p5_a5);
    ddp_agbv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agbv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agbv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agbv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agbv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.create_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_rec,
      ddx_agbv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_agbv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_agbv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_agbv_rec.acc_group_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_agbv_rec.khr_id);
    p6_a4 := ddx_agbv_rec.date_balance;
    p6_a5 := rosetta_g_miss_num_map(ddx_agbv_rec.amount);
    p6_a6 := rosetta_g_miss_num_map(ddx_agbv_rec.created_by);
    p6_a7 := ddx_agbv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_agbv_rec.last_updated_by);
    p6_a9 := ddx_agbv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_agbv_rec.last_update_login);
  end;

  procedure lock_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agb_pvt_w.rosetta_table_copy_in_p5(ddp_agbv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.lock_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agbv_rec okl_acc_group_pub.agbv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agbv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agbv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agbv_rec.acc_group_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agbv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agbv_rec.date_balance := rosetta_g_miss_date_in_map(p5_a4);
    ddp_agbv_rec.amount := rosetta_g_miss_num_map(p5_a5);
    ddp_agbv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agbv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agbv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agbv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agbv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.lock_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddx_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agb_pvt_w.rosetta_table_copy_in_p5(ddp_agbv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.update_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_tbl,
      ddx_agbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_agb_pvt_w.rosetta_table_copy_out_p5(ddx_agbv_tbl, p6_a0
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
      );
  end;

  procedure update_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agbv_rec okl_acc_group_pub.agbv_rec_type;
    ddx_agbv_rec okl_acc_group_pub.agbv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agbv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agbv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agbv_rec.acc_group_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agbv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agbv_rec.date_balance := rosetta_g_miss_date_in_map(p5_a4);
    ddp_agbv_rec.amount := rosetta_g_miss_num_map(p5_a5);
    ddp_agbv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agbv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agbv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agbv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agbv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);


    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.update_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_rec,
      ddx_agbv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_agbv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_agbv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_agbv_rec.acc_group_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_agbv_rec.khr_id);
    p6_a4 := ddx_agbv_rec.date_balance;
    p6_a5 := rosetta_g_miss_num_map(ddx_agbv_rec.amount);
    p6_a6 := rosetta_g_miss_num_map(ddx_agbv_rec.created_by);
    p6_a7 := ddx_agbv_rec.creation_date;
    p6_a8 := rosetta_g_miss_num_map(ddx_agbv_rec.last_updated_by);
    p6_a9 := ddx_agbv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_agbv_rec.last_update_login);
  end;

  procedure delete_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agb_pvt_w.rosetta_table_copy_in_p5(ddp_agbv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.delete_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agbv_rec okl_acc_group_pub.agbv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agbv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agbv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agbv_rec.acc_group_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agbv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agbv_rec.date_balance := rosetta_g_miss_date_in_map(p5_a4);
    ddp_agbv_rec.amount := rosetta_g_miss_num_map(p5_a5);
    ddp_agbv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agbv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agbv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agbv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agbv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.delete_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_agbv_tbl okl_acc_group_pub.agbv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agb_pvt_w.rosetta_table_copy_in_p5(ddp_agbv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.validate_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_acc_bal(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
  )

  as
    ddp_agbv_rec okl_acc_group_pub.agbv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agbv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agbv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agbv_rec.acc_group_id := rosetta_g_miss_num_map(p5_a2);
    ddp_agbv_rec.khr_id := rosetta_g_miss_num_map(p5_a3);
    ddp_agbv_rec.date_balance := rosetta_g_miss_date_in_map(p5_a4);
    ddp_agbv_rec.amount := rosetta_g_miss_num_map(p5_a5);
    ddp_agbv_rec.created_by := rosetta_g_miss_num_map(p5_a6);
    ddp_agbv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_agbv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a8);
    ddp_agbv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_agbv_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);

    -- here's the delegated call to the old PL/SQL routine
    okl_acc_group_pub.validate_acc_bal(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agbv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_acc_group_pub_w;

/
