--------------------------------------------------------
--  DDL for Package Body OKL_PDT_STYS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PDT_STYS_PUB_W" as
  /* $Header: OKLUPSYB.pls 120.1 2005/07/18 10:32:04 asawanka noship $ */
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

  procedure insert_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  DATE
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_pdt_stys_pub.psyv_rec_type;
    ddx_psyv_rec okl_pdt_stys_pub.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.insert_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec,
      ddx_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_psyv_rec.id);
    p6_a1 := ddx_psyv_rec.from_date;
    p6_a2 := ddx_psyv_rec.to_date;
    p6_a3 := rosetta_g_miss_num_map(ddx_psyv_rec.object_version_number);
    p6_a4 := ddx_psyv_rec.accrual_yn;
    p6_a5 := rosetta_g_miss_num_map(ddx_psyv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_psyv_rec.pdt_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_psyv_rec.created_by);
    p6_a8 := ddx_psyv_rec.creation_date;
    p6_a9 := ddx_psyv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_psyv_rec.last_updated_by);
    p6_a11 := rosetta_g_miss_num_map(ddx_psyv_rec.last_update_login);
  end;

  procedure insert_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_DATE_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_pdt_stys_pub.psyv_tbl_type;
    ddx_psyv_tbl okl_pdt_stys_pub.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.insert_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl,
      ddx_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_psy_pvt_w.rosetta_table_copy_out_p2(ddx_psyv_tbl, p6_a0
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
      );
  end;

  procedure lock_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_pdt_stys_pub.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.lock_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_pdt_stys_pub.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.lock_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  DATE
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_pdt_stys_pub.psyv_rec_type;
    ddx_psyv_rec okl_pdt_stys_pub.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.update_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec,
      ddx_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_psyv_rec.id);
    p6_a1 := ddx_psyv_rec.from_date;
    p6_a2 := ddx_psyv_rec.to_date;
    p6_a3 := rosetta_g_miss_num_map(ddx_psyv_rec.object_version_number);
    p6_a4 := ddx_psyv_rec.accrual_yn;
    p6_a5 := rosetta_g_miss_num_map(ddx_psyv_rec.sty_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_psyv_rec.pdt_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_psyv_rec.created_by);
    p6_a8 := ddx_psyv_rec.creation_date;
    p6_a9 := ddx_psyv_rec.last_update_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_psyv_rec.last_updated_by);
    p6_a11 := rosetta_g_miss_num_map(ddx_psyv_rec.last_update_login);
  end;

  procedure update_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_DATE_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_pdt_stys_pub.psyv_tbl_type;
    ddx_psyv_tbl okl_pdt_stys_pub.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.update_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl,
      ddx_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_psy_pvt_w.rosetta_table_copy_out_p2(ddx_psyv_tbl, p6_a0
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
      );
  end;

  procedure delete_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_pdt_stys_pub.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.delete_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_pdt_stys_pub.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.delete_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_pdt_stys_pub.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_psyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_psyv_rec.accrual_yn := p5_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p5_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a11);

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.validate_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_pdt_stys(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_DATE_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
  )

  as
    ddp_psyv_tbl okl_pdt_stys_pub.psyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_psy_pvt_w.rosetta_table_copy_in_p2(ddp_psyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_pdt_stys_pub.validate_pdt_stys(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_psyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_pdt_stys_pub_w;

/
