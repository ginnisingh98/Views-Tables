--------------------------------------------------------
--  DDL for Package Body OKL_STREAMS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAMS_PVT_W" as
  /* $Header: OKLOSTMB.pls 120.3 2005/09/02 12:41:03 mansrini noship $ */
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

  procedure create_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_DATE_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_DATE_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_DATE_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  DATE
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  DATE
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  NUMBER
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_DATE_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_DATE_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_DATE_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_NUMBER_TABLE
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddx_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddx_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_stmv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_stmv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_stmv_rec.kle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := rosetta_g_miss_num_map(p5_a6);
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_stmv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_stmv_rec.request_id := rosetta_g_miss_num_map(p5_a18);
    ddp_stmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a21);
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := rosetta_g_miss_num_map(p5_a23);
    ddp_stmv_rec.source_id := rosetta_g_miss_num_map(p5_a24);
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := rosetta_g_miss_num_map(p5_a26);
    ddp_stmv_rec.link_hist_stream_id := rosetta_g_miss_num_map(p5_a27);

    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.create_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec,
      ddp_selv_tbl,
      ddx_stmv_rec,
      ddx_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_stmv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_stmv_rec.sty_id);
    p7_a2 := rosetta_g_miss_num_map(ddx_stmv_rec.khr_id);
    p7_a3 := rosetta_g_miss_num_map(ddx_stmv_rec.kle_id);
    p7_a4 := ddx_stmv_rec.sgn_code;
    p7_a5 := ddx_stmv_rec.say_code;
    p7_a6 := rosetta_g_miss_num_map(ddx_stmv_rec.transaction_number);
    p7_a7 := ddx_stmv_rec.active_yn;
    p7_a8 := rosetta_g_miss_num_map(ddx_stmv_rec.object_version_number);
    p7_a9 := rosetta_g_miss_num_map(ddx_stmv_rec.created_by);
    p7_a10 := ddx_stmv_rec.creation_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_stmv_rec.last_updated_by);
    p7_a12 := ddx_stmv_rec.last_update_date;
    p7_a13 := ddx_stmv_rec.date_current;
    p7_a14 := ddx_stmv_rec.date_working;
    p7_a15 := ddx_stmv_rec.date_history;
    p7_a16 := ddx_stmv_rec.comments;
    p7_a17 := rosetta_g_miss_num_map(ddx_stmv_rec.program_id);
    p7_a18 := rosetta_g_miss_num_map(ddx_stmv_rec.request_id);
    p7_a19 := rosetta_g_miss_num_map(ddx_stmv_rec.program_application_id);
    p7_a20 := ddx_stmv_rec.program_update_date;
    p7_a21 := rosetta_g_miss_num_map(ddx_stmv_rec.last_update_login);
    p7_a22 := ddx_stmv_rec.purpose_code;
    p7_a23 := rosetta_g_miss_num_map(ddx_stmv_rec.stm_id);
    p7_a24 := rosetta_g_miss_num_map(ddx_stmv_rec.source_id);
    p7_a25 := ddx_stmv_rec.source_table;
    p7_a26 := rosetta_g_miss_num_map(ddx_stmv_rec.trx_id);
    p7_a27 := rosetta_g_miss_num_map(ddx_stmv_rec.link_hist_stream_id);

    okl_sel_pvt_w.rosetta_table_copy_out_p5(ddx_selv_tbl, p8_a0
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
      );
  end;

  procedure create_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_DATE_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_DATE_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_DATE_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_DATE_TABLE
    , p7_a13 out nocopy JTF_DATE_TABLE
    , p7_a14 out nocopy JTF_DATE_TABLE
    , p7_a15 out nocopy JTF_DATE_TABLE
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a17 out nocopy JTF_NUMBER_TABLE
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_NUMBER_TABLE
    , p7_a20 out nocopy JTF_DATE_TABLE
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_DATE_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_DATE_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_DATE_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_NUMBER_TABLE
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a24 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddx_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddx_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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

    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.create_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl,
      ddp_selv_tbl,
      ddx_stmv_tbl,
      ddx_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_stm_pvt_w.rosetta_table_copy_out_p5(ddx_stmv_tbl, p7_a0
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
      );

    okl_sel_pvt_w.rosetta_table_copy_out_p5(ddx_selv_tbl, p8_a0
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
      );
  end;

  procedure create_streams_perf(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_DATE_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_DATE_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_DATE_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_DATE_TABLE
    , p7_a13 out nocopy JTF_DATE_TABLE
    , p7_a14 out nocopy JTF_DATE_TABLE
    , p7_a15 out nocopy JTF_DATE_TABLE
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a17 out nocopy JTF_NUMBER_TABLE
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_NUMBER_TABLE
    , p7_a20 out nocopy JTF_DATE_TABLE
    , p7_a21 out nocopy JTF_NUMBER_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_DATE_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_DATE_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_DATE_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_NUMBER_TABLE
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a24 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddx_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddx_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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

    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.create_streams_perf(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl,
      ddp_selv_tbl,
      ddx_stmv_tbl,
      ddx_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_stm_pvt_w.rosetta_table_copy_out_p5(ddx_stmv_tbl, p7_a0
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
      );

    okl_sel_pvt_w.rosetta_table_copy_out_p5(ddx_selv_tbl, p8_a0
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
      );
  end;

  procedure update_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_DATE_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_DATE_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_DATE_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  DATE
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  DATE
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  NUMBER
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  NUMBER
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  NUMBER
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_DATE_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_DATE_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_DATE_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_NUMBER_TABLE
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddx_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddx_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_stmv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_stmv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_stmv_rec.kle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := rosetta_g_miss_num_map(p5_a6);
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_stmv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_stmv_rec.request_id := rosetta_g_miss_num_map(p5_a18);
    ddp_stmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a21);
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := rosetta_g_miss_num_map(p5_a23);
    ddp_stmv_rec.source_id := rosetta_g_miss_num_map(p5_a24);
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := rosetta_g_miss_num_map(p5_a26);
    ddp_stmv_rec.link_hist_stream_id := rosetta_g_miss_num_map(p5_a27);

    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.update_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec,
      ddp_selv_tbl,
      ddx_stmv_rec,
      ddx_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_stmv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_stmv_rec.sty_id);
    p7_a2 := rosetta_g_miss_num_map(ddx_stmv_rec.khr_id);
    p7_a3 := rosetta_g_miss_num_map(ddx_stmv_rec.kle_id);
    p7_a4 := ddx_stmv_rec.sgn_code;
    p7_a5 := ddx_stmv_rec.say_code;
    p7_a6 := rosetta_g_miss_num_map(ddx_stmv_rec.transaction_number);
    p7_a7 := ddx_stmv_rec.active_yn;
    p7_a8 := rosetta_g_miss_num_map(ddx_stmv_rec.object_version_number);
    p7_a9 := rosetta_g_miss_num_map(ddx_stmv_rec.created_by);
    p7_a10 := ddx_stmv_rec.creation_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_stmv_rec.last_updated_by);
    p7_a12 := ddx_stmv_rec.last_update_date;
    p7_a13 := ddx_stmv_rec.date_current;
    p7_a14 := ddx_stmv_rec.date_working;
    p7_a15 := ddx_stmv_rec.date_history;
    p7_a16 := ddx_stmv_rec.comments;
    p7_a17 := rosetta_g_miss_num_map(ddx_stmv_rec.program_id);
    p7_a18 := rosetta_g_miss_num_map(ddx_stmv_rec.request_id);
    p7_a19 := rosetta_g_miss_num_map(ddx_stmv_rec.program_application_id);
    p7_a20 := ddx_stmv_rec.program_update_date;
    p7_a21 := rosetta_g_miss_num_map(ddx_stmv_rec.last_update_login);
    p7_a22 := ddx_stmv_rec.purpose_code;
    p7_a23 := rosetta_g_miss_num_map(ddx_stmv_rec.stm_id);
    p7_a24 := rosetta_g_miss_num_map(ddx_stmv_rec.source_id);
    p7_a25 := ddx_stmv_rec.source_table;
    p7_a26 := rosetta_g_miss_num_map(ddx_stmv_rec.trx_id);
    p7_a27 := rosetta_g_miss_num_map(ddx_stmv_rec.link_hist_stream_id);

    okl_sel_pvt_w.rosetta_table_copy_out_p5(ddx_selv_tbl, p8_a0
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
      );
  end;

  procedure validate_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_2000
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_DATE_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_DATE_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_DATE_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_DATE_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_stmv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_stmv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_stmv_rec.kle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := rosetta_g_miss_num_map(p5_a6);
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_stmv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_stmv_rec.request_id := rosetta_g_miss_num_map(p5_a18);
    ddp_stmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a21);
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := rosetta_g_miss_num_map(p5_a23);
    ddp_stmv_rec.source_id := rosetta_g_miss_num_map(p5_a24);
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := rosetta_g_miss_num_map(p5_a26);
    ddp_stmv_rec.link_hist_stream_id := rosetta_g_miss_num_map(p5_a27);

    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p6_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.validate_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec,
      ddp_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddx_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
    okl_streams_pvt.create_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl,
      ddx_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_stm_pvt_w.rosetta_table_copy_out_p5(ddx_stmv_tbl, p6_a0
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

  procedure create_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddx_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_stmv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_stmv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_stmv_rec.kle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := rosetta_g_miss_num_map(p5_a6);
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_stmv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_stmv_rec.request_id := rosetta_g_miss_num_map(p5_a18);
    ddp_stmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a21);
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := rosetta_g_miss_num_map(p5_a23);
    ddp_stmv_rec.source_id := rosetta_g_miss_num_map(p5_a24);
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := rosetta_g_miss_num_map(p5_a26);
    ddp_stmv_rec.link_hist_stream_id := rosetta_g_miss_num_map(p5_a27);


    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.create_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec,
      ddx_stmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_stmv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_stmv_rec.sty_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_stmv_rec.khr_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_stmv_rec.kle_id);
    p6_a4 := ddx_stmv_rec.sgn_code;
    p6_a5 := ddx_stmv_rec.say_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_stmv_rec.transaction_number);
    p6_a7 := ddx_stmv_rec.active_yn;
    p6_a8 := rosetta_g_miss_num_map(ddx_stmv_rec.object_version_number);
    p6_a9 := rosetta_g_miss_num_map(ddx_stmv_rec.created_by);
    p6_a10 := ddx_stmv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_stmv_rec.last_updated_by);
    p6_a12 := ddx_stmv_rec.last_update_date;
    p6_a13 := ddx_stmv_rec.date_current;
    p6_a14 := ddx_stmv_rec.date_working;
    p6_a15 := ddx_stmv_rec.date_history;
    p6_a16 := ddx_stmv_rec.comments;
    p6_a17 := rosetta_g_miss_num_map(ddx_stmv_rec.program_id);
    p6_a18 := rosetta_g_miss_num_map(ddx_stmv_rec.request_id);
    p6_a19 := rosetta_g_miss_num_map(ddx_stmv_rec.program_application_id);
    p6_a20 := ddx_stmv_rec.program_update_date;
    p6_a21 := rosetta_g_miss_num_map(ddx_stmv_rec.last_update_login);
    p6_a22 := ddx_stmv_rec.purpose_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_stmv_rec.stm_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_stmv_rec.source_id);
    p6_a25 := ddx_stmv_rec.source_table;
    p6_a26 := rosetta_g_miss_num_map(ddx_stmv_rec.trx_id);
    p6_a27 := rosetta_g_miss_num_map(ddx_stmv_rec.link_hist_stream_id);
  end;

  procedure lock_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
    okl_streams_pvt.lock_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_stmv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_stmv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_stmv_rec.kle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := rosetta_g_miss_num_map(p5_a6);
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_stmv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_stmv_rec.request_id := rosetta_g_miss_num_map(p5_a18);
    ddp_stmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a21);
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := rosetta_g_miss_num_map(p5_a23);
    ddp_stmv_rec.source_id := rosetta_g_miss_num_map(p5_a24);
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := rosetta_g_miss_num_map(p5_a26);
    ddp_stmv_rec.link_hist_stream_id := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.lock_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddx_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
    okl_streams_pvt.update_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl,
      ddx_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_stm_pvt_w.rosetta_table_copy_out_p5(ddx_stmv_tbl, p6_a0
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

  procedure update_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddx_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_stmv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_stmv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_stmv_rec.kle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := rosetta_g_miss_num_map(p5_a6);
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_stmv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_stmv_rec.request_id := rosetta_g_miss_num_map(p5_a18);
    ddp_stmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a21);
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := rosetta_g_miss_num_map(p5_a23);
    ddp_stmv_rec.source_id := rosetta_g_miss_num_map(p5_a24);
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := rosetta_g_miss_num_map(p5_a26);
    ddp_stmv_rec.link_hist_stream_id := rosetta_g_miss_num_map(p5_a27);


    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.update_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec,
      ddx_stmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_stmv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_stmv_rec.sty_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_stmv_rec.khr_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_stmv_rec.kle_id);
    p6_a4 := ddx_stmv_rec.sgn_code;
    p6_a5 := ddx_stmv_rec.say_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_stmv_rec.transaction_number);
    p6_a7 := ddx_stmv_rec.active_yn;
    p6_a8 := rosetta_g_miss_num_map(ddx_stmv_rec.object_version_number);
    p6_a9 := rosetta_g_miss_num_map(ddx_stmv_rec.created_by);
    p6_a10 := ddx_stmv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_stmv_rec.last_updated_by);
    p6_a12 := ddx_stmv_rec.last_update_date;
    p6_a13 := ddx_stmv_rec.date_current;
    p6_a14 := ddx_stmv_rec.date_working;
    p6_a15 := ddx_stmv_rec.date_history;
    p6_a16 := ddx_stmv_rec.comments;
    p6_a17 := rosetta_g_miss_num_map(ddx_stmv_rec.program_id);
    p6_a18 := rosetta_g_miss_num_map(ddx_stmv_rec.request_id);
    p6_a19 := rosetta_g_miss_num_map(ddx_stmv_rec.program_application_id);
    p6_a20 := ddx_stmv_rec.program_update_date;
    p6_a21 := rosetta_g_miss_num_map(ddx_stmv_rec.last_update_login);
    p6_a22 := ddx_stmv_rec.purpose_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_stmv_rec.stm_id);
    p6_a24 := rosetta_g_miss_num_map(ddx_stmv_rec.source_id);
    p6_a25 := ddx_stmv_rec.source_table;
    p6_a26 := rosetta_g_miss_num_map(ddx_stmv_rec.trx_id);
    p6_a27 := rosetta_g_miss_num_map(ddx_stmv_rec.link_hist_stream_id);
  end;

  procedure delete_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
    okl_streams_pvt.delete_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_stmv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_stmv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_stmv_rec.kle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := rosetta_g_miss_num_map(p5_a6);
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_stmv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_stmv_rec.request_id := rosetta_g_miss_num_map(p5_a18);
    ddp_stmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a21);
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := rosetta_g_miss_num_map(p5_a23);
    ddp_stmv_rec.source_id := rosetta_g_miss_num_map(p5_a24);
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := rosetta_g_miss_num_map(p5_a26);
    ddp_stmv_rec.link_hist_stream_id := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.delete_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
  )

  as
    ddp_stmv_tbl okl_streams_pvt.stmv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_stm_pvt_w.rosetta_table_copy_in_p5(ddp_stmv_tbl, p5_a0
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
    okl_streams_pvt.validate_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  NUMBER := 0-1962.0724
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
  )

  as
    ddp_stmv_rec okl_streams_pvt.stmv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_stmv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_stmv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_stmv_rec.khr_id := rosetta_g_miss_num_map(p5_a2);
    ddp_stmv_rec.kle_id := rosetta_g_miss_num_map(p5_a3);
    ddp_stmv_rec.sgn_code := p5_a4;
    ddp_stmv_rec.say_code := p5_a5;
    ddp_stmv_rec.transaction_number := rosetta_g_miss_num_map(p5_a6);
    ddp_stmv_rec.active_yn := p5_a7;
    ddp_stmv_rec.object_version_number := rosetta_g_miss_num_map(p5_a8);
    ddp_stmv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_stmv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_stmv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_stmv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_stmv_rec.date_current := rosetta_g_miss_date_in_map(p5_a13);
    ddp_stmv_rec.date_working := rosetta_g_miss_date_in_map(p5_a14);
    ddp_stmv_rec.date_history := rosetta_g_miss_date_in_map(p5_a15);
    ddp_stmv_rec.comments := p5_a16;
    ddp_stmv_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_stmv_rec.request_id := rosetta_g_miss_num_map(p5_a18);
    ddp_stmv_rec.program_application_id := rosetta_g_miss_num_map(p5_a19);
    ddp_stmv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a20);
    ddp_stmv_rec.last_update_login := rosetta_g_miss_num_map(p5_a21);
    ddp_stmv_rec.purpose_code := p5_a22;
    ddp_stmv_rec.stm_id := rosetta_g_miss_num_map(p5_a23);
    ddp_stmv_rec.source_id := rosetta_g_miss_num_map(p5_a24);
    ddp_stmv_rec.source_table := p5_a25;
    ddp_stmv_rec.trx_id := rosetta_g_miss_num_map(p5_a26);
    ddp_stmv_rec.link_hist_stream_id := rosetta_g_miss_num_map(p5_a27);

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.validate_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_stmv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddx_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.create_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl,
      ddx_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sel_pvt_w.rosetta_table_copy_out_p5(ddx_selv_tbl, p6_a0
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
      );
  end;

  procedure create_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_streams_pvt.selv_rec_type;
    ddx_selv_rec okl_streams_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);


    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.create_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec,
      ddx_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_selv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_selv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_selv_rec.stm_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_selv_rec.amount);
    p6_a4 := ddx_selv_rec.comments;
    p6_a5 := ddx_selv_rec.accrued_yn;
    p6_a6 := ddx_selv_rec.stream_element_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_selv_rec.program_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_selv_rec.request_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_selv_rec.program_application_id);
    p6_a10 := ddx_selv_rec.program_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_selv_rec.se_line_number);
    p6_a12 := ddx_selv_rec.date_billed;
    p6_a13 := rosetta_g_miss_num_map(ddx_selv_rec.created_by);
    p6_a14 := ddx_selv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_selv_rec.last_updated_by);
    p6_a16 := ddx_selv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_selv_rec.last_update_login);
    p6_a18 := rosetta_g_miss_num_map(ddx_selv_rec.parent_index);
    p6_a19 := rosetta_g_miss_num_map(ddx_selv_rec.sel_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_selv_rec.source_id);
    p6_a21 := ddx_selv_rec.source_table;
    p6_a22 := ddx_selv_rec.bill_adj_flag;
    p6_a23 := ddx_selv_rec.accrual_adj_flag;
    p6_a24 := ddx_selv_rec.date_disbursed;
  end;

  procedure lock_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.lock_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_streams_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.lock_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddx_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.update_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl,
      ddx_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sel_pvt_w.rosetta_table_copy_out_p5(ddx_selv_tbl, p6_a0
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
      );
  end;

  procedure update_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_streams_pvt.selv_rec_type;
    ddx_selv_rec okl_streams_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);


    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.update_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec,
      ddx_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_selv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_selv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_selv_rec.stm_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_selv_rec.amount);
    p6_a4 := ddx_selv_rec.comments;
    p6_a5 := ddx_selv_rec.accrued_yn;
    p6_a6 := ddx_selv_rec.stream_element_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_selv_rec.program_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_selv_rec.request_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_selv_rec.program_application_id);
    p6_a10 := ddx_selv_rec.program_update_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_selv_rec.se_line_number);
    p6_a12 := ddx_selv_rec.date_billed;
    p6_a13 := rosetta_g_miss_num_map(ddx_selv_rec.created_by);
    p6_a14 := ddx_selv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_selv_rec.last_updated_by);
    p6_a16 := ddx_selv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_selv_rec.last_update_login);
    p6_a18 := rosetta_g_miss_num_map(ddx_selv_rec.parent_index);
    p6_a19 := rosetta_g_miss_num_map(ddx_selv_rec.sel_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_selv_rec.source_id);
    p6_a21 := ddx_selv_rec.source_table;
    p6_a22 := ddx_selv_rec.bill_adj_flag;
    p6_a23 := ddx_selv_rec.accrual_adj_flag;
    p6_a24 := ddx_selv_rec.date_disbursed;
  end;

  procedure delete_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.delete_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_streams_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.delete_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_2000
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_DATE_TABLE
  )

  as
    ddp_selv_tbl okl_streams_pvt.selv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sel_pvt_w.rosetta_table_copy_in_p5(ddp_selv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.validate_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_stream_elements(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  DATE := fnd_api.g_miss_date
  )

  as
    ddp_selv_rec okl_streams_pvt.selv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_selv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_selv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_selv_rec.stm_id := rosetta_g_miss_num_map(p5_a2);
    ddp_selv_rec.amount := rosetta_g_miss_num_map(p5_a3);
    ddp_selv_rec.comments := p5_a4;
    ddp_selv_rec.accrued_yn := p5_a5;
    ddp_selv_rec.stream_element_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_selv_rec.program_id := rosetta_g_miss_num_map(p5_a7);
    ddp_selv_rec.request_id := rosetta_g_miss_num_map(p5_a8);
    ddp_selv_rec.program_application_id := rosetta_g_miss_num_map(p5_a9);
    ddp_selv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_selv_rec.se_line_number := rosetta_g_miss_num_map(p5_a11);
    ddp_selv_rec.date_billed := rosetta_g_miss_date_in_map(p5_a12);
    ddp_selv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_selv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_selv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_selv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_selv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);
    ddp_selv_rec.parent_index := rosetta_g_miss_num_map(p5_a18);
    ddp_selv_rec.sel_id := rosetta_g_miss_num_map(p5_a19);
    ddp_selv_rec.source_id := rosetta_g_miss_num_map(p5_a20);
    ddp_selv_rec.source_table := p5_a21;
    ddp_selv_rec.bill_adj_flag := p5_a22;
    ddp_selv_rec.accrual_adj_flag := p5_a23;
    ddp_selv_rec.date_disbursed := rosetta_g_miss_date_in_map(p5_a24);

    -- here's the delegated call to the old PL/SQL routine
    okl_streams_pvt.validate_stream_elements(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_selv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_streams_pvt_w;

/
