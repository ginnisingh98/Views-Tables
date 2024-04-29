--------------------------------------------------------
--  DDL for Package Body OKL_ASSET_SUBSIDY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ASSET_SUBSIDY_PVT_W" as
  /* $Header: OKLEASBB.pls 115.1 2003/10/16 07:55:26 avsingh noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy okl_asset_subsidy_pvt.asb_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).subsidy_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).subsidy_cle_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).subsidy_override_amount := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).asset_cle_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).cpl_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).vendor_name := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_asset_subsidy_pvt.asb_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).subsidy_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).subsidy_cle_id);
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).subsidy_override_amount);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).asset_cle_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_id);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a10(indx) := t(ddindx).vendor_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_asb_rec okl_asset_subsidy_pvt.asb_rec_type;
    ddx_asb_rec okl_asset_subsidy_pvt.asb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_asb_rec.subsidy_id := rosetta_g_miss_num_map(p5_a0);
    ddp_asb_rec.subsidy_cle_id := rosetta_g_miss_num_map(p5_a1);
    ddp_asb_rec.name := p5_a2;
    ddp_asb_rec.description := p5_a3;
    ddp_asb_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_asb_rec.subsidy_override_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_asb_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_asb_rec.asset_cle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_asb_rec.cpl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_asb_rec.vendor_id := rosetta_g_miss_num_map(p5_a9);
    ddp_asb_rec.vendor_name := p5_a10;


    -- here's the delegated call to the old PL/SQL routine
    okl_asset_subsidy_pvt.create_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_rec,
      ddx_asb_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_cle_id);
    p6_a2 := ddx_asb_rec.name;
    p6_a3 := ddx_asb_rec.description;
    p6_a4 := rosetta_g_miss_num_map(ddx_asb_rec.amount);
    p6_a5 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_override_amount);
    p6_a6 := rosetta_g_miss_num_map(ddx_asb_rec.dnz_chr_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_asb_rec.asset_cle_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_asb_rec.cpl_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_asb_rec.vendor_id);
    p6_a10 := ddx_asb_rec.vendor_name;
  end;

  procedure create_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_asb_tbl okl_asset_subsidy_pvt.asb_tbl_type;
    ddx_asb_tbl okl_asset_subsidy_pvt.asb_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_asset_subsidy_pvt_w.rosetta_table_copy_in_p1(ddp_asb_tbl, p5_a0
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
    okl_asset_subsidy_pvt.create_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_tbl,
      ddx_asb_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_asset_subsidy_pvt_w.rosetta_table_copy_out_p1(ddx_asb_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      );
  end;

  procedure update_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_asb_rec okl_asset_subsidy_pvt.asb_rec_type;
    ddx_asb_rec okl_asset_subsidy_pvt.asb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_asb_rec.subsidy_id := rosetta_g_miss_num_map(p5_a0);
    ddp_asb_rec.subsidy_cle_id := rosetta_g_miss_num_map(p5_a1);
    ddp_asb_rec.name := p5_a2;
    ddp_asb_rec.description := p5_a3;
    ddp_asb_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_asb_rec.subsidy_override_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_asb_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_asb_rec.asset_cle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_asb_rec.cpl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_asb_rec.vendor_id := rosetta_g_miss_num_map(p5_a9);
    ddp_asb_rec.vendor_name := p5_a10;


    -- here's the delegated call to the old PL/SQL routine
    okl_asset_subsidy_pvt.update_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_rec,
      ddx_asb_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_cle_id);
    p6_a2 := ddx_asb_rec.name;
    p6_a3 := ddx_asb_rec.description;
    p6_a4 := rosetta_g_miss_num_map(ddx_asb_rec.amount);
    p6_a5 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_override_amount);
    p6_a6 := rosetta_g_miss_num_map(ddx_asb_rec.dnz_chr_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_asb_rec.asset_cle_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_asb_rec.cpl_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_asb_rec.vendor_id);
    p6_a10 := ddx_asb_rec.vendor_name;
  end;

  procedure update_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_asb_tbl okl_asset_subsidy_pvt.asb_tbl_type;
    ddx_asb_tbl okl_asset_subsidy_pvt.asb_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_asset_subsidy_pvt_w.rosetta_table_copy_in_p1(ddp_asb_tbl, p5_a0
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
    okl_asset_subsidy_pvt.update_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_tbl,
      ddx_asb_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_asset_subsidy_pvt_w.rosetta_table_copy_out_p1(ddx_asb_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      );
  end;

  procedure delete_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_asb_rec okl_asset_subsidy_pvt.asb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_asb_rec.subsidy_id := rosetta_g_miss_num_map(p5_a0);
    ddp_asb_rec.subsidy_cle_id := rosetta_g_miss_num_map(p5_a1);
    ddp_asb_rec.name := p5_a2;
    ddp_asb_rec.description := p5_a3;
    ddp_asb_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_asb_rec.subsidy_override_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_asb_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_asb_rec.asset_cle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_asb_rec.cpl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_asb_rec.vendor_id := rosetta_g_miss_num_map(p5_a9);
    ddp_asb_rec.vendor_name := p5_a10;

    -- here's the delegated call to the old PL/SQL routine
    okl_asset_subsidy_pvt.delete_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_asb_tbl okl_asset_subsidy_pvt.asb_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_asset_subsidy_pvt_w.rosetta_table_copy_in_p1(ddp_asb_tbl, p5_a0
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
    okl_asset_subsidy_pvt.delete_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_asb_rec okl_asset_subsidy_pvt.asb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_asb_rec.subsidy_id := rosetta_g_miss_num_map(p5_a0);
    ddp_asb_rec.subsidy_cle_id := rosetta_g_miss_num_map(p5_a1);
    ddp_asb_rec.name := p5_a2;
    ddp_asb_rec.description := p5_a3;
    ddp_asb_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_asb_rec.subsidy_override_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_asb_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_asb_rec.asset_cle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_asb_rec.cpl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_asb_rec.vendor_id := rosetta_g_miss_num_map(p5_a9);
    ddp_asb_rec.vendor_name := p5_a10;

    -- here's the delegated call to the old PL/SQL routine
    okl_asset_subsidy_pvt.validate_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_asb_tbl okl_asset_subsidy_pvt.asb_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_asset_subsidy_pvt_w.rosetta_table_copy_in_p1(ddp_asb_tbl, p5_a0
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
    okl_asset_subsidy_pvt.validate_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure calculate_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_asb_rec okl_asset_subsidy_pvt.asb_rec_type;
    ddx_asb_rec okl_asset_subsidy_pvt.asb_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_asb_rec.subsidy_id := rosetta_g_miss_num_map(p5_a0);
    ddp_asb_rec.subsidy_cle_id := rosetta_g_miss_num_map(p5_a1);
    ddp_asb_rec.name := p5_a2;
    ddp_asb_rec.description := p5_a3;
    ddp_asb_rec.amount := rosetta_g_miss_num_map(p5_a4);
    ddp_asb_rec.subsidy_override_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_asb_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a6);
    ddp_asb_rec.asset_cle_id := rosetta_g_miss_num_map(p5_a7);
    ddp_asb_rec.cpl_id := rosetta_g_miss_num_map(p5_a8);
    ddp_asb_rec.vendor_id := rosetta_g_miss_num_map(p5_a9);
    ddp_asb_rec.vendor_name := p5_a10;


    -- here's the delegated call to the old PL/SQL routine
    okl_asset_subsidy_pvt.calculate_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_rec,
      ddx_asb_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_cle_id);
    p6_a2 := ddx_asb_rec.name;
    p6_a3 := ddx_asb_rec.description;
    p6_a4 := rosetta_g_miss_num_map(ddx_asb_rec.amount);
    p6_a5 := rosetta_g_miss_num_map(ddx_asb_rec.subsidy_override_amount);
    p6_a6 := rosetta_g_miss_num_map(ddx_asb_rec.dnz_chr_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_asb_rec.asset_cle_id);
    p6_a8 := rosetta_g_miss_num_map(ddx_asb_rec.cpl_id);
    p6_a9 := rosetta_g_miss_num_map(ddx_asb_rec.vendor_id);
    p6_a10 := ddx_asb_rec.vendor_name;
  end;

  procedure calculate_asset_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_asb_tbl okl_asset_subsidy_pvt.asb_tbl_type;
    ddx_asb_tbl okl_asset_subsidy_pvt.asb_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_asset_subsidy_pvt_w.rosetta_table_copy_in_p1(ddp_asb_tbl, p5_a0
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
    okl_asset_subsidy_pvt.calculate_asset_subsidy(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_asb_tbl,
      ddx_asb_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_asset_subsidy_pvt_w.rosetta_table_copy_out_p1(ddx_asb_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      );
  end;

end okl_asset_subsidy_pvt_w;

/
