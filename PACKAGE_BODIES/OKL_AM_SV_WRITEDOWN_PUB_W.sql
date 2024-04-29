--------------------------------------------------------
--  DDL for Package Body OKL_AM_SV_WRITEDOWN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SV_WRITEDOWN_PUB_W" as
  /* $Header: OKLUSVWB.pls 120.1 2005/07/07 12:49:40 asawanka noship $ */
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

  procedure create_salvage_value_trx(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , x_salvage_value_status out nocopy  VARCHAR2
  )

  as
    ddp_assets_tbl okl_am_sv_writedown_pub.assets_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_sv_writedown_pvt_w.rosetta_table_copy_in_p1(ddp_assets_tbl, p5_a0
      , p5_a1
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_am_sv_writedown_pub.create_salvage_value_trx(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_assets_tbl,
      x_salvage_value_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_am_sv_writedown_pub_w;

/
