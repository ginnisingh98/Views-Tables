--------------------------------------------------------
--  DDL for Package Body OKL_REPAIR_COSTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REPAIR_COSTS_PUB_W" as
  /* $Header: OKLURPCB.pls 115.3 2002/12/19 23:33:26 gkadarka noship $ */
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

  procedure insert_repair_costs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_rpcv_tbl okl_repair_costs_pub.rpcv_tbl_type;
    ddx_rpcv_tbl okl_repair_costs_pub.rpcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpc_pvt_w.rosetta_table_copy_in_p8(ddp_rpcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.insert_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_tbl,
      ddx_rpcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rpc_pvt_w.rosetta_table_copy_out_p8(ddx_rpcv_tbl, p6_a0
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
      );
  end;

  procedure insert_repair_costs(p_api_version  NUMBER
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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rpcv_rec okl_repair_costs_pub.rpcv_rec_type;
    ddx_rpcv_rec okl_repair_costs_pub.rpcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rpcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rpcv_rec.sfwt_flag := p5_a2;
    ddp_rpcv_rec.enabled_yn := p5_a3;
    ddp_rpcv_rec.cost := rosetta_g_miss_num_map(p5_a4);
    ddp_rpcv_rec.repair_type := p5_a5;
    ddp_rpcv_rec.description := p5_a6;
    ddp_rpcv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rpcv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rpcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rpcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_rpcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_rpcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_rpcv_rec.currency_code := p5_a13;
    ddp_rpcv_rec.currency_conversion_code := p5_a14;
    ddp_rpcv_rec.currency_conversion_type := p5_a15;
    ddp_rpcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_rpcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.insert_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_rec,
      ddx_rpcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rpcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rpcv_rec.object_version_number);
    p6_a2 := ddx_rpcv_rec.sfwt_flag;
    p6_a3 := ddx_rpcv_rec.enabled_yn;
    p6_a4 := rosetta_g_miss_num_map(ddx_rpcv_rec.cost);
    p6_a5 := ddx_rpcv_rec.repair_type;
    p6_a6 := ddx_rpcv_rec.description;
    p6_a7 := rosetta_g_miss_num_map(ddx_rpcv_rec.org_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_rpcv_rec.created_by);
    p6_a9 := ddx_rpcv_rec.creation_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_rpcv_rec.last_updated_by);
    p6_a11 := ddx_rpcv_rec.last_update_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_rpcv_rec.last_update_login);
    p6_a13 := ddx_rpcv_rec.currency_code;
    p6_a14 := ddx_rpcv_rec.currency_conversion_code;
    p6_a15 := ddx_rpcv_rec.currency_conversion_type;
    p6_a16 := rosetta_g_miss_num_map(ddx_rpcv_rec.currency_conversion_rate);
    p6_a17 := ddx_rpcv_rec.currency_conversion_date;
  end;

  procedure lock_repair_costs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
  )

  as
    ddp_rpcv_tbl okl_repair_costs_pub.rpcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpc_pvt_w.rosetta_table_copy_in_p8(ddp_rpcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.lock_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_repair_costs(p_api_version  NUMBER
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rpcv_rec okl_repair_costs_pub.rpcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rpcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rpcv_rec.sfwt_flag := p5_a2;
    ddp_rpcv_rec.enabled_yn := p5_a3;
    ddp_rpcv_rec.cost := rosetta_g_miss_num_map(p5_a4);
    ddp_rpcv_rec.repair_type := p5_a5;
    ddp_rpcv_rec.description := p5_a6;
    ddp_rpcv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rpcv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rpcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rpcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_rpcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_rpcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_rpcv_rec.currency_code := p5_a13;
    ddp_rpcv_rec.currency_conversion_code := p5_a14;
    ddp_rpcv_rec.currency_conversion_type := p5_a15;
    ddp_rpcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_rpcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.lock_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_repair_costs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_rpcv_tbl okl_repair_costs_pub.rpcv_tbl_type;
    ddx_rpcv_tbl okl_repair_costs_pub.rpcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpc_pvt_w.rosetta_table_copy_in_p8(ddp_rpcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.update_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_tbl,
      ddx_rpcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rpc_pvt_w.rosetta_table_copy_out_p8(ddx_rpcv_tbl, p6_a0
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
      );
  end;

  procedure update_repair_costs(p_api_version  NUMBER
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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rpcv_rec okl_repair_costs_pub.rpcv_rec_type;
    ddx_rpcv_rec okl_repair_costs_pub.rpcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rpcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rpcv_rec.sfwt_flag := p5_a2;
    ddp_rpcv_rec.enabled_yn := p5_a3;
    ddp_rpcv_rec.cost := rosetta_g_miss_num_map(p5_a4);
    ddp_rpcv_rec.repair_type := p5_a5;
    ddp_rpcv_rec.description := p5_a6;
    ddp_rpcv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rpcv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rpcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rpcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_rpcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_rpcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_rpcv_rec.currency_code := p5_a13;
    ddp_rpcv_rec.currency_conversion_code := p5_a14;
    ddp_rpcv_rec.currency_conversion_type := p5_a15;
    ddp_rpcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_rpcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.update_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_rec,
      ddx_rpcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_rpcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_rpcv_rec.object_version_number);
    p6_a2 := ddx_rpcv_rec.sfwt_flag;
    p6_a3 := ddx_rpcv_rec.enabled_yn;
    p6_a4 := rosetta_g_miss_num_map(ddx_rpcv_rec.cost);
    p6_a5 := ddx_rpcv_rec.repair_type;
    p6_a6 := ddx_rpcv_rec.description;
    p6_a7 := rosetta_g_miss_num_map(ddx_rpcv_rec.org_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_rpcv_rec.created_by);
    p6_a9 := ddx_rpcv_rec.creation_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_rpcv_rec.last_updated_by);
    p6_a11 := ddx_rpcv_rec.last_update_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_rpcv_rec.last_update_login);
    p6_a13 := ddx_rpcv_rec.currency_code;
    p6_a14 := ddx_rpcv_rec.currency_conversion_code;
    p6_a15 := ddx_rpcv_rec.currency_conversion_type;
    p6_a16 := rosetta_g_miss_num_map(ddx_rpcv_rec.currency_conversion_rate);
    p6_a17 := ddx_rpcv_rec.currency_conversion_date;
  end;

  procedure delete_repair_costs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
  )

  as
    ddp_rpcv_tbl okl_repair_costs_pub.rpcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpc_pvt_w.rosetta_table_copy_in_p8(ddp_rpcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.delete_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_repair_costs(p_api_version  NUMBER
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rpcv_rec okl_repair_costs_pub.rpcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rpcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rpcv_rec.sfwt_flag := p5_a2;
    ddp_rpcv_rec.enabled_yn := p5_a3;
    ddp_rpcv_rec.cost := rosetta_g_miss_num_map(p5_a4);
    ddp_rpcv_rec.repair_type := p5_a5;
    ddp_rpcv_rec.description := p5_a6;
    ddp_rpcv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rpcv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rpcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rpcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_rpcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_rpcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_rpcv_rec.currency_code := p5_a13;
    ddp_rpcv_rec.currency_conversion_code := p5_a14;
    ddp_rpcv_rec.currency_conversion_type := p5_a15;
    ddp_rpcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_rpcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.delete_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_repair_costs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_DATE_TABLE
  )

  as
    ddp_rpcv_tbl okl_repair_costs_pub.rpcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_rpc_pvt_w.rosetta_table_copy_in_p8(ddp_rpcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.validate_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_repair_costs(p_api_version  NUMBER
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rpcv_rec okl_repair_costs_pub.rpcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rpcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_rpcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_rpcv_rec.sfwt_flag := p5_a2;
    ddp_rpcv_rec.enabled_yn := p5_a3;
    ddp_rpcv_rec.cost := rosetta_g_miss_num_map(p5_a4);
    ddp_rpcv_rec.repair_type := p5_a5;
    ddp_rpcv_rec.description := p5_a6;
    ddp_rpcv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_rpcv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rpcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_rpcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_rpcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_rpcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);
    ddp_rpcv_rec.currency_code := p5_a13;
    ddp_rpcv_rec.currency_conversion_code := p5_a14;
    ddp_rpcv_rec.currency_conversion_type := p5_a15;
    ddp_rpcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_rpcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_repair_costs_pub.validate_repair_costs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rpcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_repair_costs_pub_w;

/
