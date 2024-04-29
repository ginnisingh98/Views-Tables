--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_RELOCATION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_RELOCATION_PUB_W" as
  /* $Header: OKLUAREB.pls 120.3 2005/12/05 07:12:44 asawanka noship $ */
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

  procedure relocate_installed_item(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
  )

  as
    ddp_ialo_tbl okl_am_asset_relocation_pub.ialo_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_asset_relocation_pvt_w.rosetta_table_copy_in_p3(ddp_ialo_tbl, p5_a0
      , p5_a1
      , p5_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_am_asset_relocation_pub.relocate_installed_item(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ialo_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure relocate_fixed_asset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_falo_tbl okl_am_asset_relocation_pub.falo_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_asset_relocation_pvt_w.rosetta_table_copy_in_p1(ddp_falo_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_am_asset_relocation_pub.relocate_fixed_asset(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_falo_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure change_fa_location(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
  )

  as
    ddp_assets_tbl okl_am_asset_relocation_pub.falo_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_asset_relocation_pvt_w.rosetta_table_copy_in_p1(ddp_assets_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_am_asset_relocation_pub.change_fa_location(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_assets_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_am_asset_relocation_pub_w;

/
