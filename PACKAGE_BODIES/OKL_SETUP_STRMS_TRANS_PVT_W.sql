--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_STRMS_TRANS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_STRMS_TRANS_PVT_W" as
  /* $Header: OKLESMNB.pls 120.1 2005/07/12 09:10:12 dkagrawa noship $ */
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

  procedure insert_translations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_400
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_VARCHAR2_TABLE_400
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_400
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_DATE_TABLE
    , p2_a10 JTF_DATE_TABLE
    , p2_a11 JTF_VARCHAR2_TABLE_300
    , p2_a12 JTF_VARCHAR2_TABLE_300
    , p2_a13 JTF_VARCHAR2_TABLE_300
    , p2_a14 JTF_VARCHAR2_TABLE_300
    , p2_a15 JTF_VARCHAR2_TABLE_300
    , p2_a16 JTF_VARCHAR2_TABLE_300
    , p2_a17 JTF_VARCHAR2_TABLE_300
    , p2_a18 JTF_VARCHAR2_TABLE_300
    , p2_a19 JTF_VARCHAR2_TABLE_300
    , p2_a20 JTF_VARCHAR2_TABLE_300
    , p2_a21 JTF_VARCHAR2_TABLE_300
    , p2_a22 JTF_VARCHAR2_TABLE_300
    , p2_a23 JTF_VARCHAR2_TABLE_300
    , p2_a24 JTF_VARCHAR2_TABLE_300
    , p2_a25 JTF_VARCHAR2_TABLE_300
    , p2_a26 JTF_NUMBER_TABLE
    , p2_a27 JTF_DATE_TABLE
    , p2_a28 JTF_NUMBER_TABLE
    , p2_a29 JTF_DATE_TABLE
    , p2_a30 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 out nocopy JTF_DATE_TABLE
    , p3_a10 out nocopy JTF_DATE_TABLE
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a26 out nocopy JTF_NUMBER_TABLE
    , p3_a27 out nocopy JTF_DATE_TABLE
    , p3_a28 out nocopy JTF_NUMBER_TABLE
    , p3_a29 out nocopy JTF_DATE_TABLE
    , p3_a30 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sgnv_tbl okl_setup_strms_trans_pvt.sgnv_tbl_type;
    ddx_sgnv_tbl okl_setup_strms_trans_pvt.sgnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_sgt_pvt_w.rosetta_table_copy_in_p2(ddp_sgnv_tbl, p2_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_setup_strms_trans_pvt.insert_translations(p_api_version,
      p_init_msg_list,
      ddp_sgnv_tbl,
      ddx_sgnv_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    okl_sgt_pvt_w.rosetta_table_copy_out_p2(ddx_sgnv_tbl, p3_a0
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
      );



  end;

  procedure update_translations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_400
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_VARCHAR2_TABLE_400
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_400
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_DATE_TABLE
    , p2_a10 JTF_DATE_TABLE
    , p2_a11 JTF_VARCHAR2_TABLE_300
    , p2_a12 JTF_VARCHAR2_TABLE_300
    , p2_a13 JTF_VARCHAR2_TABLE_300
    , p2_a14 JTF_VARCHAR2_TABLE_300
    , p2_a15 JTF_VARCHAR2_TABLE_300
    , p2_a16 JTF_VARCHAR2_TABLE_300
    , p2_a17 JTF_VARCHAR2_TABLE_300
    , p2_a18 JTF_VARCHAR2_TABLE_300
    , p2_a19 JTF_VARCHAR2_TABLE_300
    , p2_a20 JTF_VARCHAR2_TABLE_300
    , p2_a21 JTF_VARCHAR2_TABLE_300
    , p2_a22 JTF_VARCHAR2_TABLE_300
    , p2_a23 JTF_VARCHAR2_TABLE_300
    , p2_a24 JTF_VARCHAR2_TABLE_300
    , p2_a25 JTF_VARCHAR2_TABLE_300
    , p2_a26 JTF_NUMBER_TABLE
    , p2_a27 JTF_DATE_TABLE
    , p2_a28 JTF_NUMBER_TABLE
    , p2_a29 JTF_DATE_TABLE
    , p2_a30 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_VARCHAR2_TABLE_400
    , p3_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a9 out nocopy JTF_DATE_TABLE
    , p3_a10 out nocopy JTF_DATE_TABLE
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a26 out nocopy JTF_NUMBER_TABLE
    , p3_a27 out nocopy JTF_DATE_TABLE
    , p3_a28 out nocopy JTF_NUMBER_TABLE
    , p3_a29 out nocopy JTF_DATE_TABLE
    , p3_a30 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sgnv_tbl okl_setup_strms_trans_pvt.sgnv_tbl_type;
    ddx_sgnv_tbl okl_setup_strms_trans_pvt.sgnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_sgt_pvt_w.rosetta_table_copy_in_p2(ddp_sgnv_tbl, p2_a0
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
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_setup_strms_trans_pvt.update_translations(p_api_version,
      p_init_msg_list,
      ddp_sgnv_tbl,
      ddx_sgnv_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    okl_sgt_pvt_w.rosetta_table_copy_out_p2(ddx_sgnv_tbl, p3_a0
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
      );



  end;

  procedure delete_translations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_400
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_VARCHAR2_TABLE_400
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_400
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_DATE_TABLE
    , p2_a10 JTF_DATE_TABLE
    , p2_a11 JTF_VARCHAR2_TABLE_300
    , p2_a12 JTF_VARCHAR2_TABLE_300
    , p2_a13 JTF_VARCHAR2_TABLE_300
    , p2_a14 JTF_VARCHAR2_TABLE_300
    , p2_a15 JTF_VARCHAR2_TABLE_300
    , p2_a16 JTF_VARCHAR2_TABLE_300
    , p2_a17 JTF_VARCHAR2_TABLE_300
    , p2_a18 JTF_VARCHAR2_TABLE_300
    , p2_a19 JTF_VARCHAR2_TABLE_300
    , p2_a20 JTF_VARCHAR2_TABLE_300
    , p2_a21 JTF_VARCHAR2_TABLE_300
    , p2_a22 JTF_VARCHAR2_TABLE_300
    , p2_a23 JTF_VARCHAR2_TABLE_300
    , p2_a24 JTF_VARCHAR2_TABLE_300
    , p2_a25 JTF_VARCHAR2_TABLE_300
    , p2_a26 JTF_NUMBER_TABLE
    , p2_a27 JTF_DATE_TABLE
    , p2_a28 JTF_NUMBER_TABLE
    , p2_a29 JTF_DATE_TABLE
    , p2_a30 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sgnv_tbl okl_setup_strms_trans_pvt.sgnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_sgt_pvt_w.rosetta_table_copy_in_p2(ddp_sgnv_tbl, p2_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_setup_strms_trans_pvt.delete_translations(p_api_version,
      p_init_msg_list,
      ddp_sgnv_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_setup_strms_trans_pvt_w;

/
