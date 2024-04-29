--------------------------------------------------------
--  DDL for Package Body OKL_RULE_EXTRACT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RULE_EXTRACT_PUB_W" as
  /* $Header: OKLUREXB.pls 115.8 2003/10/14 18:51:35 ashariff noship $ */
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

  procedure get_subclass_rgs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_sc_rg_tbl okl_rule_extract_pub.sc_rg_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_rule_extract_pub.get_subclass_rgs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddx_sc_rg_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rule_extract_pvt_w.rosetta_table_copy_out_p24(ddx_sc_rg_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );
  end;

  procedure get_rg_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_rgd_code  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_rg_rules_tbl okl_rule_extract_pub.rg_rules_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_rule_extract_pub.get_rg_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_rgd_code,
      ddx_rg_rules_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_rule_extract_pvt_w.rosetta_table_copy_out_p26(ddx_rg_rules_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );
  end;

  procedure get_rule_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_rgd_code  VARCHAR2
    , p_rgs_code  VARCHAR2
    , p_buy_or_sell  VARCHAR2
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_rule_segment_tbl okl_rule_extract_pub.rule_segment_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okl_rule_extract_pub.get_rule_def(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_rgd_code,
      p_rgs_code,
      p_buy_or_sell,
      ddx_rule_segment_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_rule_extract_pvt_w.rosetta_table_copy_out_p28(ddx_rule_segment_tbl, p8_a0
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
      );
  end;

  procedure get_rules_metadata(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_rgd_code  VARCHAR2
    , p_rgs_code  VARCHAR2
    , p_buy_or_sell  VARCHAR2
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p_party_id  NUMBER
    , p_template_table  VARCHAR2
    , p_rule_id_column  VARCHAR2
    , p_entity_column  VARCHAR2
    , p14_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_1000
    , p14_a26 out nocopy JTF_VARCHAR2_TABLE_1000
    , p14_a27 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_rule_segment_tbl okl_rule_extract_pub.rule_segment_tbl_type2;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    -- here's the delegated call to the old PL/SQL routine
    okl_rule_extract_pub.get_rules_metadata(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_rgd_code,
      p_rgs_code,
      p_buy_or_sell,
      p_contract_id,
      p_line_id,
      p_party_id,
      p_template_table,
      p_rule_id_column,
      p_entity_column,
      ddx_rule_segment_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    okl_rule_extract_pvt_w.rosetta_table_copy_out_p30(ddx_rule_segment_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      , p14_a10
      , p14_a11
      , p14_a12
      , p14_a13
      , p14_a14
      , p14_a15
      , p14_a16
      , p14_a17
      , p14_a18
      , p14_a19
      , p14_a20
      , p14_a21
      , p14_a22
      , p14_a23
      , p14_a24
      , p14_a25
      , p14_a26
      , p14_a27
      );
  end;

end okl_rule_extract_pub_w;

/
