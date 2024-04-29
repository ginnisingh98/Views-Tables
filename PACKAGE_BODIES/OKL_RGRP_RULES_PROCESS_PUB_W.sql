--------------------------------------------------------
--  DDL for Package Body OKL_RGRP_RULES_PROCESS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RGRP_RULES_PROCESS_PUB_W" as
  /* $Header: OKLURGRB.pls 120.1 2005/07/18 15:58:11 viselvar noship $ */
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

  procedure process_rule_group_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_line_id  NUMBER
    , p_cpl_id  NUMBER
    , p_rrd_id  NUMBER
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_VARCHAR2_TABLE_100
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_200
    , p9_a8 JTF_VARCHAR2_TABLE_200
    , p9_a9 JTF_VARCHAR2_TABLE_200
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_VARCHAR2_TABLE_2000
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_500
    , p9_a21 JTF_VARCHAR2_TABLE_500
    , p9_a22 JTF_VARCHAR2_TABLE_500
    , p9_a23 JTF_VARCHAR2_TABLE_500
    , p9_a24 JTF_VARCHAR2_TABLE_500
    , p9_a25 JTF_VARCHAR2_TABLE_500
    , p9_a26 JTF_VARCHAR2_TABLE_500
    , p9_a27 JTF_VARCHAR2_TABLE_500
    , p9_a28 JTF_VARCHAR2_TABLE_500
    , p9_a29 JTF_VARCHAR2_TABLE_500
    , p9_a30 JTF_VARCHAR2_TABLE_500
    , p9_a31 JTF_VARCHAR2_TABLE_500
    , p9_a32 JTF_VARCHAR2_TABLE_500
    , p9_a33 JTF_VARCHAR2_TABLE_500
    , p9_a34 JTF_VARCHAR2_TABLE_500
    , p9_a35 JTF_NUMBER_TABLE
    , p9_a36 JTF_DATE_TABLE
    , p9_a37 JTF_NUMBER_TABLE
    , p9_a38 JTF_DATE_TABLE
    , p9_a39 JTF_NUMBER_TABLE
    , p9_a40 JTF_VARCHAR2_TABLE_100
    , p9_a41 JTF_VARCHAR2_TABLE_500
    , p9_a42 JTF_VARCHAR2_TABLE_500
    , p9_a43 JTF_VARCHAR2_TABLE_500
    , p9_a44 JTF_VARCHAR2_TABLE_500
    , p9_a45 JTF_VARCHAR2_TABLE_500
    , p9_a46 JTF_VARCHAR2_TABLE_500
    , p9_a47 JTF_VARCHAR2_TABLE_500
    , p9_a48 JTF_VARCHAR2_TABLE_500
    , p9_a49 JTF_VARCHAR2_TABLE_500
    , p9_a50 JTF_VARCHAR2_TABLE_500
    , p9_a51 JTF_VARCHAR2_TABLE_500
    , p9_a52 JTF_VARCHAR2_TABLE_500
    , p9_a53 JTF_VARCHAR2_TABLE_500
    , p9_a54 JTF_VARCHAR2_TABLE_500
    , p9_a55 JTF_VARCHAR2_TABLE_500
    , p9_a56 JTF_VARCHAR2_TABLE_100
    , p9_a57 JTF_VARCHAR2_TABLE_100
    , p9_a58 JTF_VARCHAR2_TABLE_100
    , p9_a59 JTF_VARCHAR2_TABLE_100
    , p9_a60 JTF_NUMBER_TABLE
  )

  as
    ddp_rgr_tbl okl_rgrp_rules_process_pub.rgr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_in_p2(ddp_rgr_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      , p9_a55
      , p9_a56
      , p9_a57
      , p9_a58
      , p9_a59
      , p9_a60
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_rgrp_rules_process_pub.process_rule_group_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_line_id,
      p_cpl_id,
      p_rrd_id,
      ddp_rgr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure process_template_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_id  NUMBER
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_VARCHAR2_TABLE_200
    , p6_a8 JTF_VARCHAR2_TABLE_200
    , p6_a9 JTF_VARCHAR2_TABLE_200
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_VARCHAR2_TABLE_2000
    , p6_a18 JTF_VARCHAR2_TABLE_100
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_DATE_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_VARCHAR2_TABLE_500
    , p6_a44 JTF_VARCHAR2_TABLE_500
    , p6_a45 JTF_VARCHAR2_TABLE_500
    , p6_a46 JTF_VARCHAR2_TABLE_500
    , p6_a47 JTF_VARCHAR2_TABLE_500
    , p6_a48 JTF_VARCHAR2_TABLE_500
    , p6_a49 JTF_VARCHAR2_TABLE_500
    , p6_a50 JTF_VARCHAR2_TABLE_500
    , p6_a51 JTF_VARCHAR2_TABLE_500
    , p6_a52 JTF_VARCHAR2_TABLE_500
    , p6_a53 JTF_VARCHAR2_TABLE_500
    , p6_a54 JTF_VARCHAR2_TABLE_500
    , p6_a55 JTF_VARCHAR2_TABLE_500
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_VARCHAR2_TABLE_100
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rgr_tbl okl_rgrp_rules_process_pub.rgr_tbl_type;
    ddx_rgr_tbl okl_rgrp_rules_process_pub.rgr_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_in_p2(ddp_rgr_tbl, p6_a0
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
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_rgrp_rules_process_pub.process_template_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_id,
      ddp_rgr_tbl,
      ddx_rgr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_rgrp_rules_process_pvt_w.rosetta_table_copy_out_p3(ddx_rgr_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );
  end;

end okl_rgrp_rules_process_pub_w;

/
