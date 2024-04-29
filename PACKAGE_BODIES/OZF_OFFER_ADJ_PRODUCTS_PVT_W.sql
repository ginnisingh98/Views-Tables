--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_PRODUCTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_PRODUCTS_PVT_W" as
  /* $Header: ozfwoadpb.pls 120.0 2005/08/08 06:48 rssharma noship $ */
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

  procedure create_offer_adj_product(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , px_offer_adjustment_product_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
  )

  as
    ddp_adj_prod ozf_offer_adj_products_pvt.offer_adj_prod_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_adj_prod.offer_adjustment_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_adj_prod.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_adj_prod.offer_discount_line_id := rosetta_g_miss_num_map(p7_a2);
    ddp_adj_prod.off_discount_product_id := rosetta_g_miss_num_map(p7_a3);
    ddp_adj_prod.product_context := p7_a4;
    ddp_adj_prod.product_attribute := p7_a5;
    ddp_adj_prod.product_attr_value := p7_a6;
    ddp_adj_prod.excluder_flag := p7_a7;
    ddp_adj_prod.apply_discount_flag := p7_a8;
    ddp_adj_prod.include_volume_flag := p7_a9;
    ddp_adj_prod.object_version_number := rosetta_g_miss_num_map(p7_a10);
    ddp_adj_prod.last_update_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_adj_prod.last_updated_by := rosetta_g_miss_num_map(p7_a12);
    ddp_adj_prod.creation_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_adj_prod.created_by := rosetta_g_miss_num_map(p7_a14);
    ddp_adj_prod.last_update_login := rosetta_g_miss_num_map(p7_a15);


    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_products_pvt.create_offer_adj_product(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adj_prod,
      px_offer_adjustment_product_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_offer_adj_product(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
  )

  as
    ddp_adj_prod_rec ozf_offer_adj_products_pvt.offer_adj_prod_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_adj_prod_rec.offer_adjustment_product_id := rosetta_g_miss_num_map(p7_a0);
    ddp_adj_prod_rec.offer_adjustment_id := rosetta_g_miss_num_map(p7_a1);
    ddp_adj_prod_rec.offer_discount_line_id := rosetta_g_miss_num_map(p7_a2);
    ddp_adj_prod_rec.off_discount_product_id := rosetta_g_miss_num_map(p7_a3);
    ddp_adj_prod_rec.product_context := p7_a4;
    ddp_adj_prod_rec.product_attribute := p7_a5;
    ddp_adj_prod_rec.product_attr_value := p7_a6;
    ddp_adj_prod_rec.excluder_flag := p7_a7;
    ddp_adj_prod_rec.apply_discount_flag := p7_a8;
    ddp_adj_prod_rec.include_volume_flag := p7_a9;
    ddp_adj_prod_rec.object_version_number := rosetta_g_miss_num_map(p7_a10);
    ddp_adj_prod_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_adj_prod_rec.last_updated_by := rosetta_g_miss_num_map(p7_a12);
    ddp_adj_prod_rec.creation_date := rosetta_g_miss_date_in_map(p7_a13);
    ddp_adj_prod_rec.created_by := rosetta_g_miss_num_map(p7_a14);
    ddp_adj_prod_rec.last_update_login := rosetta_g_miss_num_map(p7_a15);

    -- here's the delegated call to the old PL/SQL routine
    ozf_offer_adj_products_pvt.update_offer_adj_product(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_adj_prod_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ozf_offer_adj_products_pvt_w;

/
