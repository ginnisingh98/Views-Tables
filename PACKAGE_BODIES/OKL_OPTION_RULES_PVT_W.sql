--------------------------------------------------------
--  DDL for Package Body OKL_OPTION_RULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPTION_RULES_PVT_W" as
  /* $Header: OKLOORLB.pls 115.4 2002/12/24 04:11:08 sgorantl noship $ */
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

  procedure create_option_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_2000
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_DATE_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_DATE_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_DATE_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_DATE_TABLE
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddp_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddx_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddx_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_orlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_orlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_orlv_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_orlv_rec.srd_id_for := rosetta_g_miss_num_map(p5_a3);
    ddp_orlv_rec.rgr_rgd_code := p5_a4;
    ddp_orlv_rec.rgr_rdf_code := p5_a5;
    ddp_orlv_rec.lrg_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_orlv_rec.lrg_srd_id := rosetta_g_miss_num_map(p5_a7);
    ddp_orlv_rec.overall_instructions := p5_a8;
    ddp_orlv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_orlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_orlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_orlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_orlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    okl_ovd_pvt_w.rosetta_table_copy_in_p5(ddp_ovdv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.create_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_rec,
      ddp_ovdv_tbl,
      ddx_orlv_rec,
      ddx_ovdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_orlv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_orlv_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_orlv_rec.opt_id);
    p7_a3 := rosetta_g_miss_num_map(ddx_orlv_rec.srd_id_for);
    p7_a4 := ddx_orlv_rec.rgr_rgd_code;
    p7_a5 := ddx_orlv_rec.rgr_rdf_code;
    p7_a6 := rosetta_g_miss_num_map(ddx_orlv_rec.lrg_lse_id);
    p7_a7 := rosetta_g_miss_num_map(ddx_orlv_rec.lrg_srd_id);
    p7_a8 := ddx_orlv_rec.overall_instructions;
    p7_a9 := rosetta_g_miss_num_map(ddx_orlv_rec.created_by);
    p7_a10 := ddx_orlv_rec.creation_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_orlv_rec.last_updated_by);
    p7_a12 := ddx_orlv_rec.last_update_date;
    p7_a13 := rosetta_g_miss_num_map(ddx_orlv_rec.last_update_login);

    okl_ovd_pvt_w.rosetta_table_copy_out_p5(ddx_ovdv_tbl, p8_a0
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
      );
  end;

  procedure update_option_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_2000
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_DATE_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_DATE_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  DATE
    , p7_a13 out nocopy  NUMBER
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_DATE_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_DATE_TABLE
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddp_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddx_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddx_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_orlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_orlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_orlv_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_orlv_rec.srd_id_for := rosetta_g_miss_num_map(p5_a3);
    ddp_orlv_rec.rgr_rgd_code := p5_a4;
    ddp_orlv_rec.rgr_rdf_code := p5_a5;
    ddp_orlv_rec.lrg_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_orlv_rec.lrg_srd_id := rosetta_g_miss_num_map(p5_a7);
    ddp_orlv_rec.overall_instructions := p5_a8;
    ddp_orlv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_orlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_orlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_orlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_orlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    okl_ovd_pvt_w.rosetta_table_copy_in_p5(ddp_ovdv_tbl, p6_a0
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
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.update_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_rec,
      ddp_ovdv_tbl,
      ddx_orlv_rec,
      ddx_ovdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_orlv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_orlv_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_orlv_rec.opt_id);
    p7_a3 := rosetta_g_miss_num_map(ddx_orlv_rec.srd_id_for);
    p7_a4 := ddx_orlv_rec.rgr_rgd_code;
    p7_a5 := ddx_orlv_rec.rgr_rdf_code;
    p7_a6 := rosetta_g_miss_num_map(ddx_orlv_rec.lrg_lse_id);
    p7_a7 := rosetta_g_miss_num_map(ddx_orlv_rec.lrg_srd_id);
    p7_a8 := ddx_orlv_rec.overall_instructions;
    p7_a9 := rosetta_g_miss_num_map(ddx_orlv_rec.created_by);
    p7_a10 := ddx_orlv_rec.creation_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_orlv_rec.last_updated_by);
    p7_a12 := ddx_orlv_rec.last_update_date;
    p7_a13 := rosetta_g_miss_num_map(ddx_orlv_rec.last_update_login);

    okl_ovd_pvt_w.rosetta_table_copy_out_p5(ddx_ovdv_tbl, p8_a0
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
      );
  end;

  procedure validate_option_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_2000
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_DATE_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_DATE_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddp_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_orlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_orlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_orlv_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_orlv_rec.srd_id_for := rosetta_g_miss_num_map(p5_a3);
    ddp_orlv_rec.rgr_rgd_code := p5_a4;
    ddp_orlv_rec.rgr_rdf_code := p5_a5;
    ddp_orlv_rec.lrg_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_orlv_rec.lrg_srd_id := rosetta_g_miss_num_map(p5_a7);
    ddp_orlv_rec.overall_instructions := p5_a8;
    ddp_orlv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_orlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_orlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_orlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_orlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    okl_ovd_pvt_w.rosetta_table_copy_in_p5(ddp_ovdv_tbl, p6_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.validate_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_rec,
      ddp_ovdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_option_rules(p_api_version  NUMBER
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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_orlv_tbl okl_option_rules_pvt.orlv_tbl_type;
    ddx_orlv_tbl okl_option_rules_pvt.orlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_orl_pvt_w.rosetta_table_copy_in_p5(ddp_orlv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.create_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_tbl,
      ddx_orlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_orl_pvt_w.rosetta_table_copy_out_p5(ddx_orlv_tbl, p6_a0
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
      );
  end;

  procedure create_option_rules(p_api_version  NUMBER
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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddx_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_orlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_orlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_orlv_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_orlv_rec.srd_id_for := rosetta_g_miss_num_map(p5_a3);
    ddp_orlv_rec.rgr_rgd_code := p5_a4;
    ddp_orlv_rec.rgr_rdf_code := p5_a5;
    ddp_orlv_rec.lrg_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_orlv_rec.lrg_srd_id := rosetta_g_miss_num_map(p5_a7);
    ddp_orlv_rec.overall_instructions := p5_a8;
    ddp_orlv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_orlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_orlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_orlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_orlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.create_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_rec,
      ddx_orlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_orlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_orlv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_orlv_rec.opt_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_orlv_rec.srd_id_for);
    p6_a4 := ddx_orlv_rec.rgr_rgd_code;
    p6_a5 := ddx_orlv_rec.rgr_rdf_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_orlv_rec.lrg_lse_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_orlv_rec.lrg_srd_id);
    p6_a8 := ddx_orlv_rec.overall_instructions;
    p6_a9 := rosetta_g_miss_num_map(ddx_orlv_rec.created_by);
    p6_a10 := ddx_orlv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_orlv_rec.last_updated_by);
    p6_a12 := ddx_orlv_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_orlv_rec.last_update_login);
  end;

  procedure lock_option_rules(p_api_version  NUMBER
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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_orlv_tbl okl_option_rules_pvt.orlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_orl_pvt_w.rosetta_table_copy_in_p5(ddp_orlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.lock_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_option_rules(p_api_version  NUMBER
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_orlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_orlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_orlv_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_orlv_rec.srd_id_for := rosetta_g_miss_num_map(p5_a3);
    ddp_orlv_rec.rgr_rgd_code := p5_a4;
    ddp_orlv_rec.rgr_rdf_code := p5_a5;
    ddp_orlv_rec.lrg_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_orlv_rec.lrg_srd_id := rosetta_g_miss_num_map(p5_a7);
    ddp_orlv_rec.overall_instructions := p5_a8;
    ddp_orlv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_orlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_orlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_orlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_orlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.lock_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_option_rules(p_api_version  NUMBER
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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_orlv_tbl okl_option_rules_pvt.orlv_tbl_type;
    ddx_orlv_tbl okl_option_rules_pvt.orlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_orl_pvt_w.rosetta_table_copy_in_p5(ddp_orlv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.update_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_tbl,
      ddx_orlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_orl_pvt_w.rosetta_table_copy_out_p5(ddx_orlv_tbl, p6_a0
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
      );
  end;

  procedure update_option_rules(p_api_version  NUMBER
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
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddx_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_orlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_orlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_orlv_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_orlv_rec.srd_id_for := rosetta_g_miss_num_map(p5_a3);
    ddp_orlv_rec.rgr_rgd_code := p5_a4;
    ddp_orlv_rec.rgr_rdf_code := p5_a5;
    ddp_orlv_rec.lrg_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_orlv_rec.lrg_srd_id := rosetta_g_miss_num_map(p5_a7);
    ddp_orlv_rec.overall_instructions := p5_a8;
    ddp_orlv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_orlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_orlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_orlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_orlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.update_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_rec,
      ddx_orlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_orlv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_orlv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_orlv_rec.opt_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_orlv_rec.srd_id_for);
    p6_a4 := ddx_orlv_rec.rgr_rgd_code;
    p6_a5 := ddx_orlv_rec.rgr_rdf_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_orlv_rec.lrg_lse_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_orlv_rec.lrg_srd_id);
    p6_a8 := ddx_orlv_rec.overall_instructions;
    p6_a9 := rosetta_g_miss_num_map(ddx_orlv_rec.created_by);
    p6_a10 := ddx_orlv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_orlv_rec.last_updated_by);
    p6_a12 := ddx_orlv_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_orlv_rec.last_update_login);
  end;

  procedure delete_option_rules(p_api_version  NUMBER
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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_orlv_tbl okl_option_rules_pvt.orlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_orl_pvt_w.rosetta_table_copy_in_p5(ddp_orlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.delete_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_option_rules(p_api_version  NUMBER
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_orlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_orlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_orlv_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_orlv_rec.srd_id_for := rosetta_g_miss_num_map(p5_a3);
    ddp_orlv_rec.rgr_rgd_code := p5_a4;
    ddp_orlv_rec.rgr_rdf_code := p5_a5;
    ddp_orlv_rec.lrg_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_orlv_rec.lrg_srd_id := rosetta_g_miss_num_map(p5_a7);
    ddp_orlv_rec.overall_instructions := p5_a8;
    ddp_orlv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_orlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_orlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_orlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_orlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.delete_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_option_rules(p_api_version  NUMBER
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
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
  )

  as
    ddp_orlv_tbl okl_option_rules_pvt.orlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_orl_pvt_w.rosetta_table_copy_in_p5(ddp_orlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.validate_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_option_rules(p_api_version  NUMBER
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
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_orlv_rec okl_option_rules_pvt.orlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_orlv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_orlv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_orlv_rec.opt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_orlv_rec.srd_id_for := rosetta_g_miss_num_map(p5_a3);
    ddp_orlv_rec.rgr_rgd_code := p5_a4;
    ddp_orlv_rec.rgr_rdf_code := p5_a5;
    ddp_orlv_rec.lrg_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_orlv_rec.lrg_srd_id := rosetta_g_miss_num_map(p5_a7);
    ddp_orlv_rec.overall_instructions := p5_a8;
    ddp_orlv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_orlv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_orlv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_orlv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_orlv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.validate_option_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_orlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddx_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ovd_pvt_w.rosetta_table_copy_in_p5(ddp_ovdv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.create_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_tbl,
      ddx_ovdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ovd_pvt_w.rosetta_table_copy_out_p5(ddx_ovdv_tbl, p6_a0
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
      );
  end;

  procedure create_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_ovdv_rec okl_option_rules_pvt.ovdv_rec_type;
    ddx_ovdv_rec okl_option_rules_pvt.ovdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovdv_rec.context_intent := p5_a1;
    ddp_ovdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_ovdv_rec.orl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ovdv_rec.ove_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ovdv_rec.individual_instructions := p5_a5;
    ddp_ovdv_rec.copy_or_enter_flag := p5_a6;
    ddp_ovdv_rec.context_org := rosetta_g_miss_num_map(p5_a7);
    ddp_ovdv_rec.context_inv_org := rosetta_g_miss_num_map(p5_a8);
    ddp_ovdv_rec.context_asset_book := p5_a9;
    ddp_ovdv_rec.created_by := rosetta_g_miss_num_map(p5_a10);
    ddp_ovdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_ovdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a12);
    ddp_ovdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_ovdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a14);


    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.create_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_rec,
      ddx_ovdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ovdv_rec.id);
    p6_a1 := ddx_ovdv_rec.context_intent;
    p6_a2 := rosetta_g_miss_num_map(ddx_ovdv_rec.object_version_number);
    p6_a3 := rosetta_g_miss_num_map(ddx_ovdv_rec.orl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_ovdv_rec.ove_id);
    p6_a5 := ddx_ovdv_rec.individual_instructions;
    p6_a6 := ddx_ovdv_rec.copy_or_enter_flag;
    p6_a7 := rosetta_g_miss_num_map(ddx_ovdv_rec.context_org);
    p6_a8 := rosetta_g_miss_num_map(ddx_ovdv_rec.context_inv_org);
    p6_a9 := ddx_ovdv_rec.context_asset_book;
    p6_a10 := rosetta_g_miss_num_map(ddx_ovdv_rec.created_by);
    p6_a11 := ddx_ovdv_rec.creation_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_ovdv_rec.last_updated_by);
    p6_a13 := ddx_ovdv_rec.last_update_date;
    p6_a14 := rosetta_g_miss_num_map(ddx_ovdv_rec.last_update_login);
  end;

  procedure lock_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
  )

  as
    ddp_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ovd_pvt_w.rosetta_table_copy_in_p5(ddp_ovdv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.lock_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_ovdv_rec okl_option_rules_pvt.ovdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovdv_rec.context_intent := p5_a1;
    ddp_ovdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_ovdv_rec.orl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ovdv_rec.ove_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ovdv_rec.individual_instructions := p5_a5;
    ddp_ovdv_rec.copy_or_enter_flag := p5_a6;
    ddp_ovdv_rec.context_org := rosetta_g_miss_num_map(p5_a7);
    ddp_ovdv_rec.context_inv_org := rosetta_g_miss_num_map(p5_a8);
    ddp_ovdv_rec.context_asset_book := p5_a9;
    ddp_ovdv_rec.created_by := rosetta_g_miss_num_map(p5_a10);
    ddp_ovdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_ovdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a12);
    ddp_ovdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_ovdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a14);

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.lock_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddx_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ovd_pvt_w.rosetta_table_copy_in_p5(ddp_ovdv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.update_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_tbl,
      ddx_ovdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_ovd_pvt_w.rosetta_table_copy_out_p5(ddx_ovdv_tbl, p6_a0
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
      );
  end;

  procedure update_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  DATE
    , p6_a14 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_ovdv_rec okl_option_rules_pvt.ovdv_rec_type;
    ddx_ovdv_rec okl_option_rules_pvt.ovdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovdv_rec.context_intent := p5_a1;
    ddp_ovdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_ovdv_rec.orl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ovdv_rec.ove_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ovdv_rec.individual_instructions := p5_a5;
    ddp_ovdv_rec.copy_or_enter_flag := p5_a6;
    ddp_ovdv_rec.context_org := rosetta_g_miss_num_map(p5_a7);
    ddp_ovdv_rec.context_inv_org := rosetta_g_miss_num_map(p5_a8);
    ddp_ovdv_rec.context_asset_book := p5_a9;
    ddp_ovdv_rec.created_by := rosetta_g_miss_num_map(p5_a10);
    ddp_ovdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_ovdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a12);
    ddp_ovdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_ovdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a14);


    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.update_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_rec,
      ddx_ovdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ovdv_rec.id);
    p6_a1 := ddx_ovdv_rec.context_intent;
    p6_a2 := rosetta_g_miss_num_map(ddx_ovdv_rec.object_version_number);
    p6_a3 := rosetta_g_miss_num_map(ddx_ovdv_rec.orl_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_ovdv_rec.ove_id);
    p6_a5 := ddx_ovdv_rec.individual_instructions;
    p6_a6 := ddx_ovdv_rec.copy_or_enter_flag;
    p6_a7 := rosetta_g_miss_num_map(ddx_ovdv_rec.context_org);
    p6_a8 := rosetta_g_miss_num_map(ddx_ovdv_rec.context_inv_org);
    p6_a9 := ddx_ovdv_rec.context_asset_book;
    p6_a10 := rosetta_g_miss_num_map(ddx_ovdv_rec.created_by);
    p6_a11 := ddx_ovdv_rec.creation_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_ovdv_rec.last_updated_by);
    p6_a13 := ddx_ovdv_rec.last_update_date;
    p6_a14 := rosetta_g_miss_num_map(ddx_ovdv_rec.last_update_login);
  end;

  procedure delete_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
  )

  as
    ddp_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ovd_pvt_w.rosetta_table_copy_in_p5(ddp_ovdv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.delete_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_ovdv_rec okl_option_rules_pvt.ovdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovdv_rec.context_intent := p5_a1;
    ddp_ovdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_ovdv_rec.orl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ovdv_rec.ove_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ovdv_rec.individual_instructions := p5_a5;
    ddp_ovdv_rec.copy_or_enter_flag := p5_a6;
    ddp_ovdv_rec.context_org := rosetta_g_miss_num_map(p5_a7);
    ddp_ovdv_rec.context_inv_org := rosetta_g_miss_num_map(p5_a8);
    ddp_ovdv_rec.context_asset_book := p5_a9;
    ddp_ovdv_rec.created_by := rosetta_g_miss_num_map(p5_a10);
    ddp_ovdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_ovdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a12);
    ddp_ovdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_ovdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a14);

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.delete_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
  )

  as
    ddp_ovdv_tbl okl_option_rules_pvt.ovdv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_ovd_pvt_w.rosetta_table_copy_in_p5(ddp_ovdv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.validate_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_option_val_rules(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
  )

  as
    ddp_ovdv_rec okl_option_rules_pvt.ovdv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ovdv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ovdv_rec.context_intent := p5_a1;
    ddp_ovdv_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_ovdv_rec.orl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ovdv_rec.ove_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ovdv_rec.individual_instructions := p5_a5;
    ddp_ovdv_rec.copy_or_enter_flag := p5_a6;
    ddp_ovdv_rec.context_org := rosetta_g_miss_num_map(p5_a7);
    ddp_ovdv_rec.context_inv_org := rosetta_g_miss_num_map(p5_a8);
    ddp_ovdv_rec.context_asset_book := p5_a9;
    ddp_ovdv_rec.created_by := rosetta_g_miss_num_map(p5_a10);
    ddp_ovdv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_ovdv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a12);
    ddp_ovdv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_ovdv_rec.last_update_login := rosetta_g_miss_num_map(p5_a14);

    -- here's the delegated call to the old PL/SQL routine
    okl_option_rules_pvt.validate_option_val_rules(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ovdv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_option_rules_pvt_w;

/
