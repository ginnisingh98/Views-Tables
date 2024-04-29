--------------------------------------------------------
--  DDL for Package Body OKL_SEC_INVESTOR_REVENUE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_INVESTOR_REVENUE_PVT_W" as
  /* $Header: OKLESZRB.pls 120.2 2005/10/30 03:21:04 appldev noship $ */
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

  procedure rosetta_table_copy_in_p20(t out nocopy okl_sec_investor_revenue_pvt.szr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).top_line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).kle_sty_subclass := a2(indx);
          t(ddindx).kle_percent_stake := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).kle_amount_stake := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).cle_lse_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).cle_date_terminated := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).cle_start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).cle_end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).cle_currency_code := a10(indx);
          t(ddindx).cle_sts_code := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p20;
  procedure rosetta_table_copy_out_p20(t okl_sec_investor_revenue_pvt.szr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
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
        a11.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).top_line_id);
          a2(indx) := t(ddindx).kle_sty_subclass;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).kle_percent_stake);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).kle_amount_stake);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).cle_lse_id);
          a7(indx) := t(ddindx).cle_date_terminated;
          a8(indx) := t(ddindx).cle_start_date;
          a9(indx) := t(ddindx).cle_end_date;
          a10(indx) := t(ddindx).cle_currency_code;
          a11(indx) := t(ddindx).cle_sts_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p20;

  procedure create_investor_revenue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_szr_rec okl_sec_investor_revenue_pvt.szr_rec_type;
    ddx_szr_rec okl_sec_investor_revenue_pvt.szr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_szr_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_szr_rec.top_line_id := rosetta_g_miss_num_map(p5_a1);
    ddp_szr_rec.kle_sty_subclass := p5_a2;
    ddp_szr_rec.kle_percent_stake := rosetta_g_miss_num_map(p5_a3);
    ddp_szr_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_szr_rec.kle_amount_stake := rosetta_g_miss_num_map(p5_a5);
    ddp_szr_rec.cle_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_szr_rec.cle_date_terminated := rosetta_g_miss_date_in_map(p5_a7);
    ddp_szr_rec.cle_start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_szr_rec.cle_end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_szr_rec.cle_currency_code := p5_a10;
    ddp_szr_rec.cle_sts_code := p5_a11;


    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_revenue_pvt.create_investor_revenue(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_szr_rec,
      ddx_szr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_szr_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_szr_rec.top_line_id);
    p6_a2 := ddx_szr_rec.kle_sty_subclass;
    p6_a3 := rosetta_g_miss_num_map(ddx_szr_rec.kle_percent_stake);
    p6_a4 := rosetta_g_miss_num_map(ddx_szr_rec.dnz_chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_szr_rec.kle_amount_stake);
    p6_a6 := rosetta_g_miss_num_map(ddx_szr_rec.cle_lse_id);
    p6_a7 := ddx_szr_rec.cle_date_terminated;
    p6_a8 := ddx_szr_rec.cle_start_date;
    p6_a9 := ddx_szr_rec.cle_end_date;
    p6_a10 := ddx_szr_rec.cle_currency_code;
    p6_a11 := ddx_szr_rec.cle_sts_code;
  end;

  procedure update_investor_revenue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_szr_rec okl_sec_investor_revenue_pvt.szr_rec_type;
    ddx_szr_rec okl_sec_investor_revenue_pvt.szr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_szr_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_szr_rec.top_line_id := rosetta_g_miss_num_map(p5_a1);
    ddp_szr_rec.kle_sty_subclass := p5_a2;
    ddp_szr_rec.kle_percent_stake := rosetta_g_miss_num_map(p5_a3);
    ddp_szr_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_szr_rec.kle_amount_stake := rosetta_g_miss_num_map(p5_a5);
    ddp_szr_rec.cle_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_szr_rec.cle_date_terminated := rosetta_g_miss_date_in_map(p5_a7);
    ddp_szr_rec.cle_start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_szr_rec.cle_end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_szr_rec.cle_currency_code := p5_a10;
    ddp_szr_rec.cle_sts_code := p5_a11;


    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_revenue_pvt.update_investor_revenue(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_szr_rec,
      ddx_szr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_szr_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_szr_rec.top_line_id);
    p6_a2 := ddx_szr_rec.kle_sty_subclass;
    p6_a3 := rosetta_g_miss_num_map(ddx_szr_rec.kle_percent_stake);
    p6_a4 := rosetta_g_miss_num_map(ddx_szr_rec.dnz_chr_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_szr_rec.kle_amount_stake);
    p6_a6 := rosetta_g_miss_num_map(ddx_szr_rec.cle_lse_id);
    p6_a7 := ddx_szr_rec.cle_date_terminated;
    p6_a8 := ddx_szr_rec.cle_start_date;
    p6_a9 := ddx_szr_rec.cle_end_date;
    p6_a10 := ddx_szr_rec.cle_currency_code;
    p6_a11 := ddx_szr_rec.cle_sts_code;
  end;

  procedure delete_investor_revenue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_szr_rec okl_sec_investor_revenue_pvt.szr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_szr_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_szr_rec.top_line_id := rosetta_g_miss_num_map(p5_a1);
    ddp_szr_rec.kle_sty_subclass := p5_a2;
    ddp_szr_rec.kle_percent_stake := rosetta_g_miss_num_map(p5_a3);
    ddp_szr_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a4);
    ddp_szr_rec.kle_amount_stake := rosetta_g_miss_num_map(p5_a5);
    ddp_szr_rec.cle_lse_id := rosetta_g_miss_num_map(p5_a6);
    ddp_szr_rec.cle_date_terminated := rosetta_g_miss_date_in_map(p5_a7);
    ddp_szr_rec.cle_start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_szr_rec.cle_end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_szr_rec.cle_currency_code := p5_a10;
    ddp_szr_rec.cle_sts_code := p5_a11;

    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_revenue_pvt.delete_investor_revenue(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_szr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_investor_revenue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_szr_tbl okl_sec_investor_revenue_pvt.szr_tbl_type;
    ddx_szr_tbl okl_sec_investor_revenue_pvt.szr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sec_investor_revenue_pvt_w.rosetta_table_copy_in_p20(ddp_szr_tbl, p5_a0
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
      , p5_a11
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_revenue_pvt.create_investor_revenue(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_szr_tbl,
      ddx_szr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sec_investor_revenue_pvt_w.rosetta_table_copy_out_p20(ddx_szr_tbl, p6_a0
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
      , p6_a11
      );
  end;

  procedure update_investor_revenue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_szr_tbl okl_sec_investor_revenue_pvt.szr_tbl_type;
    ddx_szr_tbl okl_sec_investor_revenue_pvt.szr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sec_investor_revenue_pvt_w.rosetta_table_copy_in_p20(ddp_szr_tbl, p5_a0
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
      , p5_a11
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_revenue_pvt.update_investor_revenue(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_szr_tbl,
      ddx_szr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sec_investor_revenue_pvt_w.rosetta_table_copy_out_p20(ddx_szr_tbl, p6_a0
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
      , p6_a11
      );
  end;

  procedure delete_investor_revenue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_szr_tbl okl_sec_investor_revenue_pvt.szr_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sec_investor_revenue_pvt_w.rosetta_table_copy_in_p20(ddp_szr_tbl, p5_a0
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
      , p5_a11
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_revenue_pvt.delete_investor_revenue(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_szr_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_sec_investor_revenue_pvt_w;

/
