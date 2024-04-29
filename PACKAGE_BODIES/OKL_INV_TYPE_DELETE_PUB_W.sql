--------------------------------------------------------
--  DDL for Package Body OKL_INV_TYPE_DELETE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INV_TYPE_DELETE_PUB_W" as
  /* $Header: OKLUITDB.pls 120.1 2005/07/14 12:03:36 asawanka noship $ */
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

  procedure delete_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ity_del_rec okl_inv_type_delete_pub.ity_del_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ity_del_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ity_del_rec.inf_id := rosetta_g_miss_num_map(p5_a1);
    ddp_ity_del_rec.name := p5_a2;
    ddp_ity_del_rec.description := p5_a3;
    ddp_ity_del_rec.group_asset_yn := p5_a4;
    ddp_ity_del_rec.group_by_contract_yn := p5_a5;

    -- here's the delegated call to the old PL/SQL routine
    okl_inv_type_delete_pub.delete_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ity_del_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_ity_del_tbl okl_inv_type_delete_pub.ity_del_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_inv_type_delete_pvt_w.rosetta_table_copy_in_p1(ddp_ity_del_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_inv_type_delete_pub.delete_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ity_del_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_inv_type_delete_pub_w;

/
