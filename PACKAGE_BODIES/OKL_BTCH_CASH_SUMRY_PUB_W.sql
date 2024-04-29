--------------------------------------------------------
--  DDL for Package Body OKL_BTCH_CASH_SUMRY_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BTCH_CASH_SUMRY_PUB_W" as
  /* $Header: OKLUBASB.pls 115.4 2003/11/11 02:00:54 rgalipo noship $ */
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

  procedure okl_batch_sumry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out NOCOPY VARCHAR2
    , x_msg_count out NOCOPY NUMBER
    , x_msg_data out NOCOPY VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_btch_tbl okl_btch_cash_sumry_pub.okl_btch_sumry_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_btch_cash_sumry_pvt_w.rosetta_table_copy_in_p13(ddp_btch_tbl, p5_a0
      , p5_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_btch_cash_sumry_pub.okl_batch_sumry(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btch_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_btch_cash_sumry_pub_w;

/
