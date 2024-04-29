--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_RANKS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_RANKS_PUB_W" as
  /* $Header: asxwrnkb.pls 120.1 2006/01/23 11:12 solin noship $ */
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

  procedure create_rank(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_sales_lead_rank_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sales_lead_rank_rec as_sales_lead_ranks_pub.sales_lead_rank_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_sales_lead_rank_rec.rank_id := rosetta_g_miss_num_map(p7_a0);
    ddp_sales_lead_rank_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_sales_lead_rank_rec.last_update_login := rosetta_g_miss_num_map(p7_a2);
    ddp_sales_lead_rank_rec.created_by := rosetta_g_miss_num_map(p7_a3);
    ddp_sales_lead_rank_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_sales_lead_rank_rec.last_updated_by := rosetta_g_miss_num_map(p7_a5);
    ddp_sales_lead_rank_rec.min_score := rosetta_g_miss_num_map(p7_a6);
    ddp_sales_lead_rank_rec.max_score := rosetta_g_miss_num_map(p7_a7);
    ddp_sales_lead_rank_rec.enabled_flag := p7_a8;
    ddp_sales_lead_rank_rec.meaning := p7_a9;
    ddp_sales_lead_rank_rec.description := p7_a10;


    -- here's the delegated call to the old PL/SQL routine
    as_sales_lead_ranks_pub.create_rank(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sales_lead_rank_rec,
      x_sales_lead_rank_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_rank(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sales_lead_rank_rec as_sales_lead_ranks_pub.sales_lead_rank_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_sales_lead_rank_rec.rank_id := rosetta_g_miss_num_map(p7_a0);
    ddp_sales_lead_rank_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_sales_lead_rank_rec.last_update_login := rosetta_g_miss_num_map(p7_a2);
    ddp_sales_lead_rank_rec.created_by := rosetta_g_miss_num_map(p7_a3);
    ddp_sales_lead_rank_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_sales_lead_rank_rec.last_updated_by := rosetta_g_miss_num_map(p7_a5);
    ddp_sales_lead_rank_rec.min_score := rosetta_g_miss_num_map(p7_a6);
    ddp_sales_lead_rank_rec.max_score := rosetta_g_miss_num_map(p7_a7);
    ddp_sales_lead_rank_rec.enabled_flag := p7_a8;
    ddp_sales_lead_rank_rec.meaning := p7_a9;
    ddp_sales_lead_rank_rec.description := p7_a10;

    -- here's the delegated call to the old PL/SQL routine
    as_sales_lead_ranks_pub.update_rank(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sales_lead_rank_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end as_sales_lead_ranks_pub_w;

/
