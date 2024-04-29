--------------------------------------------------------
--  DDL for Package Body OKL_AM_RECYCLE_TRMNT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_RECYCLE_TRMNT_PUB_W" as
  /* $Header: OKLURTXB.pls 120.1 2005/07/07 12:49:12 asawanka noship $ */
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

  procedure recycle_termination(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
  )

  as
    ddp_recy_rec okl_am_recycle_trmnt_pub.recy_rec_type;
    ddx_recy_rec okl_am_recycle_trmnt_pub.recy_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_recy_rec.p_contract_id := rosetta_g_miss_num_map(p5_a0);
    ddp_recy_rec.p_contract_number := p5_a1;
    ddp_recy_rec.p_contract_status := p5_a2;
    ddp_recy_rec.p_transaction_id := rosetta_g_miss_num_map(p5_a3);
    ddp_recy_rec.p_transaction_status := p5_a4;
    ddp_recy_rec.p_tmt_recycle_yn := p5_a5;
    ddp_recy_rec.p_transaction_date := rosetta_g_miss_date_in_map(p5_a6);


    -- here's the delegated call to the old PL/SQL routine
    okl_am_recycle_trmnt_pub.recycle_termination(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_recy_rec,
      ddx_recy_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_recy_rec.p_contract_id);
    p6_a1 := ddx_recy_rec.p_contract_number;
    p6_a2 := ddx_recy_rec.p_contract_status;
    p6_a3 := rosetta_g_miss_num_map(ddx_recy_rec.p_transaction_id);
    p6_a4 := ddx_recy_rec.p_transaction_status;
    p6_a5 := ddx_recy_rec.p_tmt_recycle_yn;
    p6_a6 := ddx_recy_rec.p_transaction_date;
  end;

  procedure recycle_termination(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_recy_tbl okl_am_recycle_trmnt_pub.recy_tbl_type;
    ddx_recy_tbl okl_am_recycle_trmnt_pub.recy_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_recycle_trmnt_pvt_w.rosetta_table_copy_in_p13(ddp_recy_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_am_recycle_trmnt_pub.recycle_termination(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_recy_tbl,
      ddx_recy_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_recycle_trmnt_pvt_w.rosetta_table_copy_out_p13(ddx_recy_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );
  end;

end okl_am_recycle_trmnt_pub_w;

/