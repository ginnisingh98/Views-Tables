--------------------------------------------------------
--  DDL for Package Body OKL_SEC_INVESTOR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_INVESTOR_PVT_W" as
  /* $Header: OKLUSZIB.pls 115.2 2003/10/22 23:15:46 ashariff noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy okl_sec_investor_pvt.inv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_400
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_DATE_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cpl_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).cpl_cpl_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).cpl_chr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).cpl_cle_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).cpl_rle_code := a4(indx);
          t(ddindx).cpl_dnz_chr_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).cpl_object1_id1 := a6(indx);
          t(ddindx).cpl_object1_id2 := a7(indx);
          t(ddindx).cpl_jtot_object1_code := a8(indx);
          t(ddindx).cle_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).cle_lse_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).cle_line_number := a11(indx);
          t(ddindx).cle_sts_code := a12(indx);
          t(ddindx).cle_comments := a13(indx);
          t(ddindx).cle_date_terminated := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).cle_start_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).cle_end_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).kle_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).kle_percent_stake := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).kle_percent := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).kle_evergreen_percent := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).kle_amount_stake := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).kle_date_sold := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).kle_delivered_date := rosetta_g_miss_date_in_map(a23(indx));
          t(ddindx).kle_amount := rosetta_g_miss_num_map(a24(indx));
          t(ddindx).kle_date_funding := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).kle_date_funding_required := rosetta_g_miss_date_in_map(a26(indx));
          t(ddindx).kle_date_accepted := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).kle_date_delivery_expected := rosetta_g_miss_date_in_map(a28(indx));
          t(ddindx).kle_capital_amount := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).name := a30(indx);
          t(ddindx).description := a31(indx);
          t(ddindx).date_pay_investor_start := rosetta_g_miss_date_in_map(a32(indx));
          t(ddindx).pay_investor_frequency := a33(indx);
          t(ddindx).pay_investor_event := a34(indx);
          t(ddindx).pay_investor_remittance_days := rosetta_g_miss_num_map(a35(indx));
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).bill_to_site_use_id := rosetta_g_miss_num_map(a37(indx));
          t(ddindx).cust_acct_id := rosetta_g_miss_num_map(a38(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_sec_investor_pvt.inv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_400
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_2000();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_400();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_2000();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_400();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
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
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_cpl_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_chr_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_cle_id);
          a4(indx) := t(ddindx).cpl_rle_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_dnz_chr_id);
          a6(indx) := t(ddindx).cpl_object1_id1;
          a7(indx) := t(ddindx).cpl_object1_id2;
          a8(indx) := t(ddindx).cpl_jtot_object1_code;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).cle_id);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).cle_lse_id);
          a11(indx) := t(ddindx).cle_line_number;
          a12(indx) := t(ddindx).cle_sts_code;
          a13(indx) := t(ddindx).cle_comments;
          a14(indx) := t(ddindx).cle_date_terminated;
          a15(indx) := t(ddindx).cle_start_date;
          a16(indx) := t(ddindx).cle_end_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).kle_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).kle_percent_stake);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).kle_percent);
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).kle_evergreen_percent);
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).kle_amount_stake);
          a22(indx) := t(ddindx).kle_date_sold;
          a23(indx) := t(ddindx).kle_delivered_date;
          a24(indx) := rosetta_g_miss_num_map(t(ddindx).kle_amount);
          a25(indx) := t(ddindx).kle_date_funding;
          a26(indx) := t(ddindx).kle_date_funding_required;
          a27(indx) := t(ddindx).kle_date_accepted;
          a28(indx) := t(ddindx).kle_date_delivery_expected;
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).kle_capital_amount);
          a30(indx) := t(ddindx).name;
          a31(indx) := t(ddindx).description;
          a32(indx) := t(ddindx).date_pay_investor_start;
          a33(indx) := t(ddindx).pay_investor_frequency;
          a34(indx) := t(ddindx).pay_investor_event;
          a35(indx) := rosetta_g_miss_num_map(t(ddindx).pay_investor_remittance_days);
          a36(indx) := t(ddindx).start_date;
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).bill_to_site_use_id);
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).cust_acct_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_investor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_400
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_inv_tbl okl_sec_investor_pvt.inv_tbl_type;
    ddx_inv_tbl okl_sec_investor_pvt.inv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sec_investor_pvt_w.rosetta_table_copy_in_p1(ddp_inv_tbl, p5_a0
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
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_pvt.create_investor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_inv_tbl,
      ddx_inv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sec_investor_pvt_w.rosetta_table_copy_out_p1(ddx_inv_tbl, p6_a0
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
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      );
  end;

  procedure update_investor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_400
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_DATE_TABLE
    , p6_a26 out nocopy JTF_DATE_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_inv_tbl okl_sec_investor_pvt.inv_tbl_type;
    ddx_inv_tbl okl_sec_investor_pvt.inv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sec_investor_pvt_w.rosetta_table_copy_in_p1(ddp_inv_tbl, p5_a0
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
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_pvt.update_investor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_inv_tbl,
      ddx_inv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sec_investor_pvt_w.rosetta_table_copy_out_p1(ddx_inv_tbl, p6_a0
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
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      );
  end;

  procedure delete_investor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_DATE_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_DATE_TABLE
    , p5_a26 JTF_DATE_TABLE
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_400
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_VARCHAR2_TABLE_100
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
  )

  as
    ddp_inv_tbl okl_sec_investor_pvt.inv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sec_investor_pvt_w.rosetta_table_copy_in_p1(ddp_inv_tbl, p5_a0
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
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_sec_investor_pvt.delete_investor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_inv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_sec_investor_pvt_w;

/
