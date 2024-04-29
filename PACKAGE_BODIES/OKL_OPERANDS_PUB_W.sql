--------------------------------------------------------
--  DDL for Package Body OKL_OPERANDS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPERANDS_PUB_W" as
  /* $Header: OKLUOPDB.pls 120.1 2005/07/18 10:30:36 asawanka noship $ */
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

  procedure insert_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_opdv_rec okl_operands_pub.opdv_rec_type;
    ddx_opdv_rec okl_operands_pub.opdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_opdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_opdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_opdv_rec.sfwt_flag := p5_a2;
    ddp_opdv_rec.fma_id := rosetta_g_miss_num_map(p5_a3);
    ddp_opdv_rec.dsf_id := rosetta_g_miss_num_map(p5_a4);
    ddp_opdv_rec.name := p5_a5;
    ddp_opdv_rec.description := p5_a6;
    ddp_opdv_rec.version := p5_a7;
    ddp_opdv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_opdv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_opdv_rec.source := p5_a10;
    ddp_opdv_rec.opd_type := p5_a11;
    ddp_opdv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_opdv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_opdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_opdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_opdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_opdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_operands_pub.insert_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_rec,
      ddx_opdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_opdv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_opdv_rec.object_version_number);
    p6_a2 := ddx_opdv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_opdv_rec.fma_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_opdv_rec.dsf_id);
    p6_a5 := ddx_opdv_rec.name;
    p6_a6 := ddx_opdv_rec.description;
    p6_a7 := ddx_opdv_rec.version;
    p6_a8 := ddx_opdv_rec.start_date;
    p6_a9 := ddx_opdv_rec.end_date;
    p6_a10 := ddx_opdv_rec.source;
    p6_a11 := ddx_opdv_rec.opd_type;
    p6_a12 := rosetta_g_miss_num_map(ddx_opdv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_opdv_rec.created_by);
    p6_a14 := ddx_opdv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_opdv_rec.last_updated_by);
    p6_a16 := ddx_opdv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_opdv_rec.last_update_login);
  end;

  procedure insert_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_opdv_tbl okl_operands_pub.opdv_tbl_type;
    ddx_opdv_tbl okl_operands_pub.opdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opd_pvt_w.rosetta_table_copy_in_p8(ddp_opdv_tbl, p5_a0
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
    okl_operands_pub.insert_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_tbl,
      ddx_opdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_opd_pvt_w.rosetta_table_copy_out_p8(ddx_opdv_tbl, p6_a0
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

  procedure lock_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_opdv_rec okl_operands_pub.opdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_opdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_opdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_opdv_rec.sfwt_flag := p5_a2;
    ddp_opdv_rec.fma_id := rosetta_g_miss_num_map(p5_a3);
    ddp_opdv_rec.dsf_id := rosetta_g_miss_num_map(p5_a4);
    ddp_opdv_rec.name := p5_a5;
    ddp_opdv_rec.description := p5_a6;
    ddp_opdv_rec.version := p5_a7;
    ddp_opdv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_opdv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_opdv_rec.source := p5_a10;
    ddp_opdv_rec.opd_type := p5_a11;
    ddp_opdv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_opdv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_opdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_opdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_opdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_opdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_operands_pub.lock_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_opdv_tbl okl_operands_pub.opdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opd_pvt_w.rosetta_table_copy_in_p8(ddp_opdv_tbl, p5_a0
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
    okl_operands_pub.lock_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_opdv_rec okl_operands_pub.opdv_rec_type;
    ddx_opdv_rec okl_operands_pub.opdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_opdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_opdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_opdv_rec.sfwt_flag := p5_a2;
    ddp_opdv_rec.fma_id := rosetta_g_miss_num_map(p5_a3);
    ddp_opdv_rec.dsf_id := rosetta_g_miss_num_map(p5_a4);
    ddp_opdv_rec.name := p5_a5;
    ddp_opdv_rec.description := p5_a6;
    ddp_opdv_rec.version := p5_a7;
    ddp_opdv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_opdv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_opdv_rec.source := p5_a10;
    ddp_opdv_rec.opd_type := p5_a11;
    ddp_opdv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_opdv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_opdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_opdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_opdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_opdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_operands_pub.update_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_rec,
      ddx_opdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_opdv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_opdv_rec.object_version_number);
    p6_a2 := ddx_opdv_rec.sfwt_flag;
    p6_a3 := rosetta_g_miss_num_map(ddx_opdv_rec.fma_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_opdv_rec.dsf_id);
    p6_a5 := ddx_opdv_rec.name;
    p6_a6 := ddx_opdv_rec.description;
    p6_a7 := ddx_opdv_rec.version;
    p6_a8 := ddx_opdv_rec.start_date;
    p6_a9 := ddx_opdv_rec.end_date;
    p6_a10 := ddx_opdv_rec.source;
    p6_a11 := ddx_opdv_rec.opd_type;
    p6_a12 := rosetta_g_miss_num_map(ddx_opdv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_opdv_rec.created_by);
    p6_a14 := ddx_opdv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_opdv_rec.last_updated_by);
    p6_a16 := ddx_opdv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_opdv_rec.last_update_login);
  end;

  procedure update_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_opdv_tbl okl_operands_pub.opdv_tbl_type;
    ddx_opdv_tbl okl_operands_pub.opdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opd_pvt_w.rosetta_table_copy_in_p8(ddp_opdv_tbl, p5_a0
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
    okl_operands_pub.update_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_tbl,
      ddx_opdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_opd_pvt_w.rosetta_table_copy_out_p8(ddx_opdv_tbl, p6_a0
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

  procedure delete_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_opdv_rec okl_operands_pub.opdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_opdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_opdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_opdv_rec.sfwt_flag := p5_a2;
    ddp_opdv_rec.fma_id := rosetta_g_miss_num_map(p5_a3);
    ddp_opdv_rec.dsf_id := rosetta_g_miss_num_map(p5_a4);
    ddp_opdv_rec.name := p5_a5;
    ddp_opdv_rec.description := p5_a6;
    ddp_opdv_rec.version := p5_a7;
    ddp_opdv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_opdv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_opdv_rec.source := p5_a10;
    ddp_opdv_rec.opd_type := p5_a11;
    ddp_opdv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_opdv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_opdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_opdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_opdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_opdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_operands_pub.delete_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_opdv_tbl okl_operands_pub.opdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opd_pvt_w.rosetta_table_copy_in_p8(ddp_opdv_tbl, p5_a0
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
    okl_operands_pub.delete_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_opdv_rec okl_operands_pub.opdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_opdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_opdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_opdv_rec.sfwt_flag := p5_a2;
    ddp_opdv_rec.fma_id := rosetta_g_miss_num_map(p5_a3);
    ddp_opdv_rec.dsf_id := rosetta_g_miss_num_map(p5_a4);
    ddp_opdv_rec.name := p5_a5;
    ddp_opdv_rec.description := p5_a6;
    ddp_opdv_rec.version := p5_a7;
    ddp_opdv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_opdv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_opdv_rec.source := p5_a10;
    ddp_opdv_rec.opd_type := p5_a11;
    ddp_opdv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_opdv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_opdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_opdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_opdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_opdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_operands_pub.validate_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_operands(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_2000
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_opdv_tbl okl_operands_pub.opdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_opd_pvt_w.rosetta_table_copy_in_p8(ddp_opdv_tbl, p5_a0
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
    okl_operands_pub.validate_operands(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_opdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_operands_pub_w;

/
