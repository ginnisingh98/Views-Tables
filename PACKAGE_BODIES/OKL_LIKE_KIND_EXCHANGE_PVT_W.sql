--------------------------------------------------------
--  DDL for Package Body OKL_LIKE_KIND_EXCHANGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LIKE_KIND_EXCHANGE_PVT_W" as
  /* $Header: OKLELKXB.pls 120.1 2005/07/11 14:18:23 asawanka noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy okl_like_kind_exchange_pvt.rep_asset_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rep_asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).rep_asset_number := a1(indx);
          t(ddindx).book_type_code := a2(indx);
          t(ddindx).asset_category_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).original_cost := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).current_cost := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).date_placed_in_service := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).deprn_method := a7(indx);
          t(ddindx).life_in_months := rosetta_g_miss_num_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_like_kind_exchange_pvt.rep_asset_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_2000();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_2000();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).rep_asset_id);
          a1(indx) := t(ddindx).rep_asset_number;
          a2(indx) := t(ddindx).book_type_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).asset_category_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).original_cost);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).current_cost);
          a6(indx) := t(ddindx).date_placed_in_service;
          a7(indx) := t(ddindx).deprn_method;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).life_in_months);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy okl_like_kind_exchange_pvt.req_asset_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).req_asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).req_asset_number := a1(indx);
          t(ddindx).book_type_code := a2(indx);
          t(ddindx).asset_category_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).original_cost := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).date_retired := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).proceeds_of_sale := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).gain_loss_amount := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).balance_sale_proceeds := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).balance_gain_loss := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).match_amount := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t okl_like_kind_exchange_pvt.req_asset_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_2000();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_2000();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).req_asset_id);
          a1(indx) := t(ddindx).req_asset_number;
          a2(indx) := t(ddindx).book_type_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).asset_category_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).original_cost);
          a5(indx) := t(ddindx).date_retired;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).proceeds_of_sale);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).gain_loss_amount);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).balance_sale_proceeds);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).balance_gain_loss);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).match_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

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
    ddp_rep_asset_rec okl_like_kind_exchange_pvt.rep_asset_rec_type;
    ddp_req_asset_tbl okl_like_kind_exchange_pvt.req_asset_tbl_type;
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
    okl_like_kind_exchange_pvt.create_like_kind_exchange(p_api_version,
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

end okl_like_kind_exchange_pvt_w;

/
