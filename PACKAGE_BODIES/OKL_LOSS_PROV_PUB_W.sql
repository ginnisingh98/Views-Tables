--------------------------------------------------------
--  DDL for Package Body OKL_LOSS_PROV_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOSS_PROV_PUB_W" as
  /* $Header: OKLULPVB.pls 120.5 2005/10/30 04:48:41 appldev noship $ */
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

  function submit_general_loss(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
  ) return number

  as
    ddp_glpv_rec okl_loss_prov_pub.glpv_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_glpv_rec.product_id := rosetta_g_miss_num_map(p5_a0);
    ddp_glpv_rec.bucket_id := rosetta_g_miss_num_map(p5_a1);
    ddp_glpv_rec.entry_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_glpv_rec.tax_deductible_local := p5_a3;
    ddp_glpv_rec.tax_deductible_corporate := p5_a4;
    ddp_glpv_rec.description := p5_a5;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_loss_prov_pub.submit_general_loss(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_glpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    return ddrosetta_retval;
  end;

  procedure specific_loss_provision(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
  )

  as
    ddp_slpv_rec okl_loss_prov_pub.slpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_slpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_slpv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_slpv_rec.amount := rosetta_g_miss_num_map(p5_a2);
    ddp_slpv_rec.description := p5_a3;
    ddp_slpv_rec.reverse_flag := p5_a4;
    ddp_slpv_rec.tax_deductible_local := p5_a5;
    ddp_slpv_rec.tax_deductible_corporate := p5_a6;
    ddp_slpv_rec.provision_date := rosetta_g_miss_date_in_map(p5_a7);

    -- here's the delegated call to the old PL/SQL routine
    okl_loss_prov_pub.specific_loss_provision(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_slpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure specific_loss_provision(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_reverse_flag  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_2000
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_DATE_TABLE
  )

  as
    ddp_slpv_tbl okl_loss_prov_pub.slpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    okl_loss_prov_pvt_w.rosetta_table_copy_in_p4(ddp_slpv_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_loss_prov_pub.specific_loss_provision(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      p_khr_id,
      p_reverse_flag,
      ddp_slpv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end okl_loss_prov_pub_w;

/
