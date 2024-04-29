--------------------------------------------------------
--  DDL for Package Body OKL_LA_ASSET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_ASSET_PVT_W" as
  /* $Header: OKLELAAB.pls 120.5.12010000.2 2010/04/29 16:32:10 rpillay ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_la_asset_pvt.fin_adj_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).p_top_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).p_asset_number := a1(indx);
          t(ddindx).p_new_yn := a2(indx);
          t(ddindx).p_dnz_chr_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).p_capital_reduction := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).p_capital_reduction_percent := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).p_oec := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).p_cap_down_pay_yn := a7(indx);
          t(ddindx).p_down_payment_receiver := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_la_asset_pvt.fin_adj_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).p_top_line_id);
          a1(indx) := t(ddindx).p_asset_number;
          a2(indx) := t(ddindx).p_new_yn;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).p_dnz_chr_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).p_capital_reduction);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).p_capital_reduction_percent);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).p_oec);
          a7(indx) := t(ddindx).p_cap_down_pay_yn;
          a8(indx) := t(ddindx).p_down_payment_receiver;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_la_asset_pvt.las_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).asset_number := a0(indx);
          t(ddindx).year_manufactured := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).manufacturer_name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).current_units := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).from_oec := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).to_oec := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).vendor_name := a7(indx);
          t(ddindx).from_residual_value := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).to_residual_value := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).from_start_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).from_end_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).from_date_terminated := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).to_start_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).to_end_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).to_date_terminated := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).sts_code := a16(indx);
          t(ddindx).location_id := a17(indx);
          t(ddindx).parent_line_id := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).p_order_by := a20(indx);
          t(ddindx).p_sort_by := a21(indx);
          t(ddindx).include_split_yn := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_la_asset_pvt.las_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).asset_number;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).year_manufactured);
          a2(indx) := t(ddindx).manufacturer_name;
          a3(indx) := t(ddindx).description;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).current_units);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).from_oec);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).to_oec);
          a7(indx) := t(ddindx).vendor_name;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).from_residual_value);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).to_residual_value);
          a10(indx) := t(ddindx).from_start_date;
          a11(indx) := t(ddindx).from_end_date;
          a12(indx) := t(ddindx).from_date_terminated;
          a13(indx) := t(ddindx).to_start_date;
          a14(indx) := t(ddindx).to_end_date;
          a15(indx) := t(ddindx).to_date_terminated;
          a16(indx) := t(ddindx).sts_code;
          a17(indx) := t(ddindx).location_id;
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).parent_line_id);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a20(indx) := t(ddindx).p_order_by;
          a21(indx) := t(ddindx).p_sort_by;
          a22(indx) := t(ddindx).include_split_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure generate_asset_summary(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_las_rec okl_la_asset_pvt.las_rec_type;
    ddx_las_tbl okl_la_asset_pvt.las_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_las_rec.asset_number := p5_a0;
    ddp_las_rec.year_manufactured := rosetta_g_miss_num_map(p5_a1);
    ddp_las_rec.manufacturer_name := p5_a2;
    ddp_las_rec.description := p5_a3;
    ddp_las_rec.current_units := rosetta_g_miss_num_map(p5_a4);
    ddp_las_rec.from_oec := rosetta_g_miss_num_map(p5_a5);
    ddp_las_rec.to_oec := rosetta_g_miss_num_map(p5_a6);
    ddp_las_rec.vendor_name := p5_a7;
    ddp_las_rec.from_residual_value := rosetta_g_miss_num_map(p5_a8);
    ddp_las_rec.to_residual_value := rosetta_g_miss_num_map(p5_a9);
    ddp_las_rec.from_start_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_las_rec.from_end_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_las_rec.from_date_terminated := rosetta_g_miss_date_in_map(p5_a12);
    ddp_las_rec.to_start_date := rosetta_g_miss_date_in_map(p5_a13);
    ddp_las_rec.to_end_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_las_rec.to_date_terminated := rosetta_g_miss_date_in_map(p5_a15);
    ddp_las_rec.sts_code := p5_a16;
    ddp_las_rec.location_id := p5_a17;
    ddp_las_rec.parent_line_id := rosetta_g_miss_num_map(p5_a18);
    ddp_las_rec.dnz_chr_id := rosetta_g_miss_num_map(p5_a19);
    ddp_las_rec.p_order_by := p5_a20;
    ddp_las_rec.p_sort_by := p5_a21;
    ddp_las_rec.include_split_yn := p5_a22;


    -- here's the delegated call to the old PL/SQL routine
    okl_la_asset_pvt.generate_asset_summary(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_las_rec,
      ddx_las_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_la_asset_pvt_w.rosetta_table_copy_out_p3(ddx_las_tbl, p6_a0
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
      );
  end;

  procedure update_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_id  NUMBER
    , p_date_delivery_expected  date
    , p_date_funding_expected  date
    , p_org_id  NUMBER
    , p_organization_id  NUMBER
  )

  as
    ddp_date_delivery_expected date;
    ddp_date_funding_expected date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_date_delivery_expected := rosetta_g_miss_date_in_map(p_date_delivery_expected);

    ddp_date_funding_expected := rosetta_g_miss_date_in_map(p_date_funding_expected);



    -- here's the delegated call to the old PL/SQL routine
    okl_la_asset_pvt.update_contract_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_id,
      ddp_date_delivery_expected,
      ddp_date_funding_expected,
      p_org_id,
      p_organization_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_fin_cap_cost(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_fin_adj_tbl okl_la_asset_pvt.fin_adj_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_la_asset_pvt_w.rosetta_table_copy_in_p2(ddp_fin_adj_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_la_asset_pvt.update_fin_cap_cost(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fin_adj_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure iscontractactive(p_dnz_chr_id  NUMBER
    , p_deal_type  VARCHAR2
    , p_sts_code  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_la_asset_pvt.iscontractactive(p_dnz_chr_id,
      p_deal_type,
      p_sts_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;


  end;

end okl_la_asset_pvt_w;

/
