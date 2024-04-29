--------------------------------------------------------
--  DDL for Package Body OKL_LA_TRADEIN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_TRADEIN_PVT_W" as
  /* $Header: OKLETRIB.pls 120.0 2005/11/12 00:57:30 smereddy noship $ */
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

  procedure rosetta_table_copy_in_p6(t out nocopy okl_la_tradein_pvt.tradein_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).asset_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).asset_number := a2(indx);
          t(ddindx).tradein_amount := rosetta_g_miss_num_map(a3(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t okl_la_tradein_pvt.tradein_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).asset_id);
          a2(indx) := t(ddindx).asset_number;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).tradein_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy okl_la_tradein_pvt.asset_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).fin_asset_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).asset_number := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_la_tradein_pvt.asset_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).fin_asset_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a2(indx) := t(ddindx).asset_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure create_tradein(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
  )

  as
    ddp_tradein_rec okl_la_tradein_pvt.tradein_rec_type;
    ddx_tradein_rec okl_la_tradein_pvt.tradein_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_tradein_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_tradein_rec.asset_id := rosetta_g_miss_num_map(p6_a1);
    ddp_tradein_rec.asset_number := p6_a2;
    ddp_tradein_rec.tradein_amount := rosetta_g_miss_num_map(p6_a3);


    -- here's the delegated call to the old PL/SQL routine
    okl_la_tradein_pvt.create_tradein(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_tradein_rec,
      ddx_tradein_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_tradein_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_tradein_rec.asset_id);
    p7_a2 := ddx_tradein_rec.asset_number;
    p7_a3 := rosetta_g_miss_num_map(ddx_tradein_rec.tradein_amount);
  end;

  procedure create_tradein(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_200
    , p6_a3 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a3 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tradein_tbl okl_la_tradein_pvt.tradein_tbl_type;
    ddx_tradein_tbl okl_la_tradein_pvt.tradein_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_la_tradein_pvt_w.rosetta_table_copy_in_p6(ddp_tradein_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_la_tradein_pvt.create_tradein(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_tradein_tbl,
      ddx_tradein_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_la_tradein_pvt_w.rosetta_table_copy_out_p6(ddx_tradein_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );
  end;

  procedure delete_tradein(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
  )

  as
    ddp_tradein_rec okl_la_tradein_pvt.tradein_rec_type;
    ddx_tradein_rec okl_la_tradein_pvt.tradein_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_tradein_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_tradein_rec.asset_id := rosetta_g_miss_num_map(p6_a1);
    ddp_tradein_rec.asset_number := p6_a2;
    ddp_tradein_rec.tradein_amount := rosetta_g_miss_num_map(p6_a3);


    -- here's the delegated call to the old PL/SQL routine
    okl_la_tradein_pvt.delete_tradein(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_tradein_rec,
      ddx_tradein_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_tradein_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_tradein_rec.asset_id);
    p7_a2 := ddx_tradein_rec.asset_number;
    p7_a3 := rosetta_g_miss_num_map(ddx_tradein_rec.tradein_amount);
  end;

  procedure delete_tradein(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_200
    , p6_a3 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a3 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tradein_tbl okl_la_tradein_pvt.tradein_tbl_type;
    ddx_tradein_tbl okl_la_tradein_pvt.tradein_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_la_tradein_pvt_w.rosetta_table_copy_in_p6(ddp_tradein_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_la_tradein_pvt.delete_tradein(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_tradein_tbl,
      ddx_tradein_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_la_tradein_pvt_w.rosetta_table_copy_out_p6(ddx_tradein_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );
  end;

  procedure update_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_tradein_date  date
    , p_tradein_amount  NUMBER
    , p_tradein_desc  VARCHAR2
  )

  as
    ddp_tradein_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_tradein_date := rosetta_g_miss_date_in_map(p_tradein_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_la_tradein_pvt.update_contract(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_tradein_date,
      p_tradein_amount,
      p_tradein_desc);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end okl_la_tradein_pvt_w;

/
