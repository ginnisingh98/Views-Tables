--------------------------------------------------------
--  DDL for Package Body OKL_INS_CLAIM_ASSET_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INS_CLAIM_ASSET_PUB_W" as
  /* $Header: OKLOCLAB.pls 115.2 2003/05/26 07:46:00 arajagop noship $ */
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

  procedure create_lease_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_DATE_TABLE
    , p5_a8 in out nocopy JTF_DATE_TABLE
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a25 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a29 in out nocopy JTF_DATE_TABLE
    , p5_a30 in out nocopy JTF_NUMBER_TABLE
    , p5_a31 in out nocopy JTF_NUMBER_TABLE
    , p5_a32 in out nocopy JTF_NUMBER_TABLE
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_DATE_TABLE
    , p5_a35 in out nocopy JTF_NUMBER_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_NUMBER_TABLE
    , p5_a38 in out nocopy JTF_DATE_TABLE
    , p5_a39 in out nocopy JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_NUMBER_TABLE
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_DATE_TABLE
    , p6_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a25 in out nocopy JTF_NUMBER_TABLE
    , p6_a26 in out nocopy JTF_NUMBER_TABLE
    , p6_a27 in out nocopy JTF_NUMBER_TABLE
    , p6_a28 in out nocopy JTF_DATE_TABLE
    , p6_a29 in out nocopy JTF_NUMBER_TABLE
    , p6_a30 in out nocopy JTF_DATE_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_DATE_TABLE
    , p6_a33 in out nocopy JTF_NUMBER_TABLE
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_NUMBER_TABLE
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a14 in out nocopy JTF_NUMBER_TABLE
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_NUMBER_TABLE
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 in out nocopy JTF_DATE_TABLE
    , p7_a19 in out nocopy JTF_DATE_TABLE
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_800
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a33 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a34 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a36 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a37 in out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a38 in out nocopy JTF_NUMBER_TABLE
    , p7_a39 in out nocopy JTF_NUMBER_TABLE
    , p7_a40 in out nocopy JTF_NUMBER_TABLE
    , p7_a41 in out nocopy JTF_NUMBER_TABLE
    , p7_a42 in out nocopy JTF_DATE_TABLE
    , p7_a43 in out nocopy JTF_NUMBER_TABLE
    , p7_a44 in out nocopy JTF_DATE_TABLE
    , p7_a45 in out nocopy JTF_NUMBER_TABLE
    , p7_a46 in out nocopy JTF_DATE_TABLE
    , p7_a47 in out nocopy JTF_NUMBER_TABLE
    , p7_a48 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a51 in out nocopy JTF_NUMBER_TABLE
    , p7_a52 in out nocopy JTF_DATE_TABLE
  )

  as
    ddpx_clmv_tbl okl_ins_claim_asset_pub.clmv_tbl_type;
    ddpx_acdv_tbl okl_ins_claim_asset_pub.acdv_tbl_type;
    ddpx_acnv_tbl okl_ins_claim_asset_pub.acnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_clm_pvt_w.rosetta_table_copy_in_p2(ddpx_clmv_tbl, p5_a0
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
      );

    okl_acd_pvt_w.rosetta_table_copy_in_p5(ddpx_acdv_tbl, p6_a0
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
      );

    okl_acn_pvt_w.rosetta_table_copy_in_p8(ddpx_acnv_tbl, p7_a0
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
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ins_claim_asset_pub.create_lease_claim(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddpx_clmv_tbl,
      ddpx_acdv_tbl,
      ddpx_acnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    okl_clm_pvt_w.rosetta_table_copy_out_p2(ddpx_clmv_tbl, p5_a0
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
      );

    okl_acd_pvt_w.rosetta_table_copy_out_p5(ddpx_acdv_tbl, p6_a0
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
      );

    okl_acn_pvt_w.rosetta_table_copy_out_p8(ddpx_acnv_tbl, p7_a0
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
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      );
  end;

  procedure hold_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lsm_id okl_ins_claim_asset_pub.stmid_rec_type_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ins_claim_asset_pvt_w.rosetta_table_copy_in_p4(ddp_lsm_id, p5_a0
      , p5_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_ins_claim_asset_pub.hold_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lsm_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_ins_claim_asset_pub_w;

/
