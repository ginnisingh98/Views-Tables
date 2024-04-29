--------------------------------------------------------
--  DDL for Package Body CSE_WFM_TRX_GRP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_WFM_TRX_GRP_PVT_W" as
  /* $Header: CSEWBWWB.pls 120.1 2008/01/16 21:32:20 devijay ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure wfm_transactions(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a12 in out nocopy JTF_DATE_TABLE
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_DATE_TABLE
    , p5_a15 in out nocopy JTF_NUMBER_TABLE
    , p5_a16 in out nocopy JTF_DATE_TABLE
    , p5_a17 in out nocopy JTF_NUMBER_TABLE
    , p5_a18 in out nocopy JTF_NUMBER_TABLE
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_wfm_values_tbl cse_datastructures_pub.wfm_trx_values_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    cse_datastructures_pub_w.rosetta_table_copy_in_p56(ddp_wfm_values_tbl, p5_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    cse_wfm_trx_grp_pvt.wfm_transactions(p_api_version,
      p_commit,
      p_validation_level,
      p_init_msg_list,
      p_transaction_type,
      ddp_wfm_values_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cse_datastructures_pub_w.rosetta_table_copy_out_p56(ddp_wfm_values_tbl, p5_a0
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
      );



  end;

end cse_wfm_trx_grp_pvt_w;

/
