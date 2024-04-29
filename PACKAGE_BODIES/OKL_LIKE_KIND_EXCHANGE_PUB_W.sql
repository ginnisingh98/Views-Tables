--------------------------------------------------------
--  DDL for Package Body OKL_LIKE_KIND_EXCHANGE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LIKE_KIND_EXCHANGE_PUB_W" as
  /* $Header: OKLULKXB.pls 120.1 2005/07/18 16:44:53 viselvar noship $ */
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

  procedure create_like_kind_exchange(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_corporate_book  VARCHAR2
    , p_tax_book  VARCHAR2
    , p_comments  VARCHAR2
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_2000
    , p9_a2 JTF_VARCHAR2_TABLE_2000
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  NUMBER := 0-1962.0724
  )

  as
    ddp_rep_asset_rec okl_like_kind_exchange_pub.rep_asset_rec_type;
    ddp_req_asset_tbl okl_like_kind_exchange_pub.req_asset_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_rep_asset_rec.rep_asset_id := rosetta_g_miss_num_map(p8_a0);
    ddp_rep_asset_rec.rep_asset_number := p8_a1;
    ddp_rep_asset_rec.book_type_code := p8_a2;
    ddp_rep_asset_rec.asset_category_id := rosetta_g_miss_num_map(p8_a3);
    ddp_rep_asset_rec.original_cost := rosetta_g_miss_num_map(p8_a4);
    ddp_rep_asset_rec.current_cost := rosetta_g_miss_num_map(p8_a5);
    ddp_rep_asset_rec.date_placed_in_service := rosetta_g_miss_date_in_map(p8_a6);
    ddp_rep_asset_rec.deprn_method := p8_a7;
    ddp_rep_asset_rec.life_in_months := rosetta_g_miss_num_map(p8_a8);

    okl_like_kind_exchange_pvt_w.rosetta_table_copy_in_p4(ddp_req_asset_tbl, p9_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_like_kind_exchange_pub.create_like_kind_exchange(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_corporate_book,
      p_tax_book,
      p_comments,
      ddp_rep_asset_rec,
      ddp_req_asset_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end okl_like_kind_exchange_pub_w;

/
