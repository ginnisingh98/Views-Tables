--------------------------------------------------------
--  DDL for Package Body OZF_OFFR_PROD_DENORM_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFR_PROD_DENORM_PVT_OA" as
  /* $Header: ozfaodmb.pls 120.0 2005/08/31 09:43 gramanat noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ozf_offr_elig_prod_denorm_pvt.num_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t ozf_offr_elig_prod_denorm_pvt.num_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy ozf_offr_elig_prod_denorm_pvt.char_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_offr_elig_prod_denorm_pvt.char_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure find_party_elig(p_offers_tbl JTF_NUMBER_TABLE
    , p_party_id  NUMBER
    , p_cust_acct_id  NUMBER
    , p_cust_site_id  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_offers_tbl out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_offers_tbl ozf_offr_elig_prod_denorm_pvt.num_tbl_type;
    ddx_offers_tbl ozf_offr_elig_prod_denorm_pvt.num_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ozf_offr_prod_denorm_pvt_oa.rosetta_table_copy_in_p0(ddp_offers_tbl, p_offers_tbl);











    -- here's the delegated call to the old PL/SQL routine
    ozf_offr_elig_prod_denorm_pvt.find_party_elig(ddp_offers_tbl,
      p_party_id,
      p_cust_acct_id,
      p_cust_site_id,
      p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_offers_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    ozf_offr_prod_denorm_pvt_oa.rosetta_table_copy_out_p0(ddx_offers_tbl, x_offers_tbl);
  end;

  procedure find_product_elig(p_products_tbl JTF_NUMBER_TABLE
    , p_party_id  NUMBER
    , p_cust_acct_id  NUMBER
    , p_cust_site_id  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_offers_tbl out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_products_tbl ozf_offr_elig_prod_denorm_pvt.num_tbl_type;
    ddx_offers_tbl ozf_offr_elig_prod_denorm_pvt.num_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ozf_offr_prod_denorm_pvt_oa.rosetta_table_copy_in_p0(ddp_products_tbl, p_products_tbl);











    -- here's the delegated call to the old PL/SQL routine
    ozf_offr_elig_prod_denorm_pvt.find_product_elig(ddp_products_tbl,
      p_party_id,
      p_cust_acct_id,
      p_cust_site_id,
      p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_offers_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    ozf_offr_prod_denorm_pvt_oa.rosetta_table_copy_out_p0(ddx_offers_tbl, x_offers_tbl);
  end;

end ozf_offr_prod_denorm_pvt_oa;

/
