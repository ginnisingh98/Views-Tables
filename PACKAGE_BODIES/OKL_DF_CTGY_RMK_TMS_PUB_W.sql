--------------------------------------------------------
--  DDL for Package Body OKL_DF_CTGY_RMK_TMS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DF_CTGY_RMK_TMS_PUB_W" as
  /* $Header: OKLUDCTB.pls 120.2 2005/12/08 18:01:51 stmathew noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure insert_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_dctv_tbl okl_df_ctgy_rmk_tms_pub.dctv_tbl_type;
    ddx_dctv_tbl okl_df_ctgy_rmk_tms_pub.dctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_dct_pvt_w.rosetta_table_copy_in_p5(ddp_dctv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.insert_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_tbl,
      ddx_dctv_tbl);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any






    okl_dct_pvt_w.rosetta_table_copy_out_p5(ddx_dctv_tbl, p6_a0
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
      );
  end;

  procedure insert_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_dctv_rec okl_df_ctgy_rmk_tms_pub.dctv_rec_type;
    ddx_dctv_rec okl_df_ctgy_rmk_tms_pub.dctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dctv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dctv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dctv_rec.rmr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_dctv_rec.ico_id := rosetta_g_miss_num_map(p5_a3);
    ddp_dctv_rec.iln_id := rosetta_g_miss_num_map(p5_a4);
    ddp_dctv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a5);
    ddp_dctv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a6);
    ddp_dctv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_dctv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_dctv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_dctv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_dctv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_dctv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);


    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.insert_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_rec,
      ddx_dctv_rec);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_dctv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_dctv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_dctv_rec.rmr_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_dctv_rec.ico_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_dctv_rec.iln_id);
    p6_a5 := ddx_dctv_rec.date_effective_from;
    p6_a6 := ddx_dctv_rec.date_effective_to;
    p6_a7 := rosetta_g_miss_num_map(ddx_dctv_rec.org_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_dctv_rec.created_by);
    p6_a9 := ddx_dctv_rec.creation_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_dctv_rec.last_updated_by);
    p6_a11 := ddx_dctv_rec.last_update_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_dctv_rec.last_update_login);
  end;

  procedure lock_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
  )

  as
    ddp_dctv_tbl okl_df_ctgy_rmk_tms_pub.dctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_dct_pvt_w.rosetta_table_copy_in_p5(ddp_dctv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.lock_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_tbl);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any





  end;

  procedure lock_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_dctv_rec okl_df_ctgy_rmk_tms_pub.dctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dctv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dctv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dctv_rec.rmr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_dctv_rec.ico_id := rosetta_g_miss_num_map(p5_a3);
    ddp_dctv_rec.iln_id := rosetta_g_miss_num_map(p5_a4);
    ddp_dctv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a5);
    ddp_dctv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a6);
    ddp_dctv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_dctv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_dctv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_dctv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_dctv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_dctv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);

    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.lock_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_rec);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any





  end;

  procedure update_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_dctv_tbl okl_df_ctgy_rmk_tms_pub.dctv_tbl_type;
    ddx_dctv_tbl okl_df_ctgy_rmk_tms_pub.dctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_dct_pvt_w.rosetta_table_copy_in_p5(ddp_dctv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.update_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_tbl,
      ddx_dctv_tbl);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any






    okl_dct_pvt_w.rosetta_table_copy_out_p5(ddx_dctv_tbl, p6_a0
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
      );
  end;

  procedure update_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_dctv_rec okl_df_ctgy_rmk_tms_pub.dctv_rec_type;
    ddx_dctv_rec okl_df_ctgy_rmk_tms_pub.dctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dctv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dctv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dctv_rec.rmr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_dctv_rec.ico_id := rosetta_g_miss_num_map(p5_a3);
    ddp_dctv_rec.iln_id := rosetta_g_miss_num_map(p5_a4);
    ddp_dctv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a5);
    ddp_dctv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a6);
    ddp_dctv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_dctv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_dctv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_dctv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_dctv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_dctv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);


    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.update_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_rec,
      ddx_dctv_rec);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_dctv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_dctv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_dctv_rec.rmr_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_dctv_rec.ico_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_dctv_rec.iln_id);
    p6_a5 := ddx_dctv_rec.date_effective_from;
    p6_a6 := ddx_dctv_rec.date_effective_to;
    p6_a7 := rosetta_g_miss_num_map(ddx_dctv_rec.org_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_dctv_rec.created_by);
    p6_a9 := ddx_dctv_rec.creation_date;
    p6_a10 := rosetta_g_miss_num_map(ddx_dctv_rec.last_updated_by);
    p6_a11 := ddx_dctv_rec.last_update_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_dctv_rec.last_update_login);
  end;

  procedure delete_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
  )

  as
    ddp_dctv_tbl okl_df_ctgy_rmk_tms_pub.dctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_dct_pvt_w.rosetta_table_copy_in_p5(ddp_dctv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.delete_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_tbl);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any





  end;

  procedure delete_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_dctv_rec okl_df_ctgy_rmk_tms_pub.dctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dctv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dctv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dctv_rec.rmr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_dctv_rec.ico_id := rosetta_g_miss_num_map(p5_a3);
    ddp_dctv_rec.iln_id := rosetta_g_miss_num_map(p5_a4);
    ddp_dctv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a5);
    ddp_dctv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a6);
    ddp_dctv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_dctv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_dctv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_dctv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_dctv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_dctv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);

    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.delete_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_rec);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any





  end;

  procedure validate_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
  )

  as
    ddp_dctv_tbl okl_df_ctgy_rmk_tms_pub.dctv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_dct_pvt_w.rosetta_table_copy_in_p5(ddp_dctv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.validate_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_tbl);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any





  end;

  procedure validate_df_ctgy_rmk_tms(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
  )

  as
    ddp_dctv_rec okl_df_ctgy_rmk_tms_pub.dctv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_dctv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_dctv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_dctv_rec.rmr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_dctv_rec.ico_id := rosetta_g_miss_num_map(p5_a3);
    ddp_dctv_rec.iln_id := rosetta_g_miss_num_map(p5_a4);
    ddp_dctv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a5);
    ddp_dctv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a6);
    ddp_dctv_rec.org_id := rosetta_g_miss_num_map(p5_a7);
    ddp_dctv_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_dctv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_dctv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a10);
    ddp_dctv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_dctv_rec.last_update_login := rosetta_g_miss_num_map(p5_a12);

    -- here's the delegated call to the old PL/SQL routine
    okl_df_ctgy_rmk_tms_pub.validate_df_ctgy_rmk_tms(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_dctv_rec);

    -- copy data back from the local variables to out nocopy or IN-OUT args, if any





  end;

end okl_df_ctgy_rmk_tms_pub_w;

/
