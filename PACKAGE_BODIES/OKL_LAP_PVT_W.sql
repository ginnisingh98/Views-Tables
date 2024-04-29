--------------------------------------------------------
--  DDL for Package Body OKL_LAP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LAP_PVT_W" as
  /* $Header: OKLILAPB.pls 120.4 2006/11/08 14:57:07 ssdeshpa noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_lap_pvt.lapv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_DATE_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_2000
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).attribute_category := a2(indx);
          t(ddindx).attribute1 := a3(indx);
          t(ddindx).attribute2 := a4(indx);
          t(ddindx).attribute3 := a5(indx);
          t(ddindx).attribute4 := a6(indx);
          t(ddindx).attribute5 := a7(indx);
          t(ddindx).attribute6 := a8(indx);
          t(ddindx).attribute7 := a9(indx);
          t(ddindx).attribute8 := a10(indx);
          t(ddindx).attribute9 := a11(indx);
          t(ddindx).attribute10 := a12(indx);
          t(ddindx).attribute11 := a13(indx);
          t(ddindx).attribute12 := a14(indx);
          t(ddindx).attribute13 := a15(indx);
          t(ddindx).attribute14 := a16(indx);
          t(ddindx).attribute15 := a17(indx);
          t(ddindx).reference_number := a18(indx);
          t(ddindx).application_status := a19(indx);
          t(ddindx).valid_from := a20(indx);
          t(ddindx).valid_to := a21(indx);
          t(ddindx).org_id := a22(indx);
          t(ddindx).inv_org_id := a23(indx);
          t(ddindx).prospect_id := a24(indx);
          t(ddindx).prospect_address_id := a25(indx);
          t(ddindx).cust_acct_id := a26(indx);
          t(ddindx).industry_class := a27(indx);
          t(ddindx).industry_code := a28(indx);
          t(ddindx).currency_code := a29(indx);
          t(ddindx).currency_conversion_type := a30(indx);
          t(ddindx).currency_conversion_rate := a31(indx);
          t(ddindx).currency_conversion_date := a32(indx);
          t(ddindx).leaseapp_template_id := a33(indx);
          t(ddindx).parent_leaseapp_id := a34(indx);
          t(ddindx).credit_line_id := a35(indx);
          t(ddindx).program_agreement_id := a36(indx);
          t(ddindx).master_lease_id := a37(indx);
          t(ddindx).sales_rep_id := a38(indx);
          t(ddindx).sales_territory_id := a39(indx);
          t(ddindx).originating_vendor_id := a40(indx);
          t(ddindx).lease_opportunity_id := a41(indx);
          t(ddindx).short_description := a42(indx);
          t(ddindx).comments := a43(indx);
          t(ddindx).cr_exp_days := a44(indx);
          t(ddindx).action := a45(indx);
          t(ddindx).orig_status := a46(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_lap_pvt.lapv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_DATE_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_2000
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
    a5 := JTF_VARCHAR2_TABLE_500();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
    a8 := JTF_VARCHAR2_TABLE_500();
    a9 := JTF_VARCHAR2_TABLE_500();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_DATE_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_2000();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      a5 := JTF_VARCHAR2_TABLE_500();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
      a8 := JTF_VARCHAR2_TABLE_500();
      a9 := JTF_VARCHAR2_TABLE_500();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_DATE_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_2000();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
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
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).attribute_category;
          a3(indx) := t(ddindx).attribute1;
          a4(indx) := t(ddindx).attribute2;
          a5(indx) := t(ddindx).attribute3;
          a6(indx) := t(ddindx).attribute4;
          a7(indx) := t(ddindx).attribute5;
          a8(indx) := t(ddindx).attribute6;
          a9(indx) := t(ddindx).attribute7;
          a10(indx) := t(ddindx).attribute8;
          a11(indx) := t(ddindx).attribute9;
          a12(indx) := t(ddindx).attribute10;
          a13(indx) := t(ddindx).attribute11;
          a14(indx) := t(ddindx).attribute12;
          a15(indx) := t(ddindx).attribute13;
          a16(indx) := t(ddindx).attribute14;
          a17(indx) := t(ddindx).attribute15;
          a18(indx) := t(ddindx).reference_number;
          a19(indx) := t(ddindx).application_status;
          a20(indx) := t(ddindx).valid_from;
          a21(indx) := t(ddindx).valid_to;
          a22(indx) := t(ddindx).org_id;
          a23(indx) := t(ddindx).inv_org_id;
          a24(indx) := t(ddindx).prospect_id;
          a25(indx) := t(ddindx).prospect_address_id;
          a26(indx) := t(ddindx).cust_acct_id;
          a27(indx) := t(ddindx).industry_class;
          a28(indx) := t(ddindx).industry_code;
          a29(indx) := t(ddindx).currency_code;
          a30(indx) := t(ddindx).currency_conversion_type;
          a31(indx) := t(ddindx).currency_conversion_rate;
          a32(indx) := t(ddindx).currency_conversion_date;
          a33(indx) := t(ddindx).leaseapp_template_id;
          a34(indx) := t(ddindx).parent_leaseapp_id;
          a35(indx) := t(ddindx).credit_line_id;
          a36(indx) := t(ddindx).program_agreement_id;
          a37(indx) := t(ddindx).master_lease_id;
          a38(indx) := t(ddindx).sales_rep_id;
          a39(indx) := t(ddindx).sales_territory_id;
          a40(indx) := t(ddindx).originating_vendor_id;
          a41(indx) := t(ddindx).lease_opportunity_id;
          a42(indx) := t(ddindx).short_description;
          a43(indx) := t(ddindx).comments;
          a44(indx) := t(ddindx).cr_exp_days;
          a45(indx) := t(ddindx).action;
          a46(indx) := t(ddindx).orig_status;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_300
    , p5_a43 JTF_VARCHAR2_TABLE_2000
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lapv_tbl okl_lap_pvt.lapv_tbl_type;
    ddx_lapv_tbl okl_lap_pvt.lapv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lap_pvt_w.rosetta_table_copy_in_p23(ddp_lapv_tbl, p5_a0
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
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lap_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_tbl,
      ddx_lapv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lap_pvt_w.rosetta_table_copy_out_p23(ddx_lapv_tbl, p6_a0
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
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_300
    , p5_a43 JTF_VARCHAR2_TABLE_2000
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_DATE_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_DATE_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_NUMBER_TABLE
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lapv_tbl okl_lap_pvt.lapv_tbl_type;
    ddx_lapv_tbl okl_lap_pvt.lapv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lap_pvt_w.rosetta_table_copy_in_p23(ddp_lapv_tbl, p5_a0
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
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_lap_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_tbl,
      ddx_lapv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_lap_pvt_w.rosetta_table_copy_out_p23(ddx_lapv_tbl, p6_a0
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
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_DATE_TABLE
    , p5_a21 JTF_DATE_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_DATE_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_VARCHAR2_TABLE_300
    , p5_a43 JTF_VARCHAR2_TABLE_2000
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_lapv_tbl okl_lap_pvt.lapv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_lap_pvt_w.rosetta_table_copy_in_p23(ddp_lapv_tbl, p5_a0
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
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_lap_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lap_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lap_pvt.lapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_lap_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddx_lapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lap_pvt.lapv_rec_type;
    ddx_lapv_rec okl_lap_pvt.lapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;


    -- here's the delegated call to the old PL/SQL routine
    okl_lap_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec,
      ddx_lapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_lapv_rec.id;
    p6_a1 := ddx_lapv_rec.object_version_number;
    p6_a2 := ddx_lapv_rec.attribute_category;
    p6_a3 := ddx_lapv_rec.attribute1;
    p6_a4 := ddx_lapv_rec.attribute2;
    p6_a5 := ddx_lapv_rec.attribute3;
    p6_a6 := ddx_lapv_rec.attribute4;
    p6_a7 := ddx_lapv_rec.attribute5;
    p6_a8 := ddx_lapv_rec.attribute6;
    p6_a9 := ddx_lapv_rec.attribute7;
    p6_a10 := ddx_lapv_rec.attribute8;
    p6_a11 := ddx_lapv_rec.attribute9;
    p6_a12 := ddx_lapv_rec.attribute10;
    p6_a13 := ddx_lapv_rec.attribute11;
    p6_a14 := ddx_lapv_rec.attribute12;
    p6_a15 := ddx_lapv_rec.attribute13;
    p6_a16 := ddx_lapv_rec.attribute14;
    p6_a17 := ddx_lapv_rec.attribute15;
    p6_a18 := ddx_lapv_rec.reference_number;
    p6_a19 := ddx_lapv_rec.application_status;
    p6_a20 := ddx_lapv_rec.valid_from;
    p6_a21 := ddx_lapv_rec.valid_to;
    p6_a22 := ddx_lapv_rec.org_id;
    p6_a23 := ddx_lapv_rec.inv_org_id;
    p6_a24 := ddx_lapv_rec.prospect_id;
    p6_a25 := ddx_lapv_rec.prospect_address_id;
    p6_a26 := ddx_lapv_rec.cust_acct_id;
    p6_a27 := ddx_lapv_rec.industry_class;
    p6_a28 := ddx_lapv_rec.industry_code;
    p6_a29 := ddx_lapv_rec.currency_code;
    p6_a30 := ddx_lapv_rec.currency_conversion_type;
    p6_a31 := ddx_lapv_rec.currency_conversion_rate;
    p6_a32 := ddx_lapv_rec.currency_conversion_date;
    p6_a33 := ddx_lapv_rec.leaseapp_template_id;
    p6_a34 := ddx_lapv_rec.parent_leaseapp_id;
    p6_a35 := ddx_lapv_rec.credit_line_id;
    p6_a36 := ddx_lapv_rec.program_agreement_id;
    p6_a37 := ddx_lapv_rec.master_lease_id;
    p6_a38 := ddx_lapv_rec.sales_rep_id;
    p6_a39 := ddx_lapv_rec.sales_territory_id;
    p6_a40 := ddx_lapv_rec.originating_vendor_id;
    p6_a41 := ddx_lapv_rec.lease_opportunity_id;
    p6_a42 := ddx_lapv_rec.short_description;
    p6_a43 := ddx_lapv_rec.comments;
    p6_a44 := ddx_lapv_rec.cr_exp_days;
    p6_a45 := ddx_lapv_rec.action;
    p6_a46 := ddx_lapv_rec.orig_status;
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  DATE
    , p5_a21  DATE
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  NUMBER
    , p5_a40  NUMBER
    , p5_a41  NUMBER
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
  )

  as
    ddp_lapv_rec okl_lap_pvt.lapv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lapv_rec.id := p5_a0;
    ddp_lapv_rec.object_version_number := p5_a1;
    ddp_lapv_rec.attribute_category := p5_a2;
    ddp_lapv_rec.attribute1 := p5_a3;
    ddp_lapv_rec.attribute2 := p5_a4;
    ddp_lapv_rec.attribute3 := p5_a5;
    ddp_lapv_rec.attribute4 := p5_a6;
    ddp_lapv_rec.attribute5 := p5_a7;
    ddp_lapv_rec.attribute6 := p5_a8;
    ddp_lapv_rec.attribute7 := p5_a9;
    ddp_lapv_rec.attribute8 := p5_a10;
    ddp_lapv_rec.attribute9 := p5_a11;
    ddp_lapv_rec.attribute10 := p5_a12;
    ddp_lapv_rec.attribute11 := p5_a13;
    ddp_lapv_rec.attribute12 := p5_a14;
    ddp_lapv_rec.attribute13 := p5_a15;
    ddp_lapv_rec.attribute14 := p5_a16;
    ddp_lapv_rec.attribute15 := p5_a17;
    ddp_lapv_rec.reference_number := p5_a18;
    ddp_lapv_rec.application_status := p5_a19;
    ddp_lapv_rec.valid_from := p5_a20;
    ddp_lapv_rec.valid_to := p5_a21;
    ddp_lapv_rec.org_id := p5_a22;
    ddp_lapv_rec.inv_org_id := p5_a23;
    ddp_lapv_rec.prospect_id := p5_a24;
    ddp_lapv_rec.prospect_address_id := p5_a25;
    ddp_lapv_rec.cust_acct_id := p5_a26;
    ddp_lapv_rec.industry_class := p5_a27;
    ddp_lapv_rec.industry_code := p5_a28;
    ddp_lapv_rec.currency_code := p5_a29;
    ddp_lapv_rec.currency_conversion_type := p5_a30;
    ddp_lapv_rec.currency_conversion_rate := p5_a31;
    ddp_lapv_rec.currency_conversion_date := p5_a32;
    ddp_lapv_rec.leaseapp_template_id := p5_a33;
    ddp_lapv_rec.parent_leaseapp_id := p5_a34;
    ddp_lapv_rec.credit_line_id := p5_a35;
    ddp_lapv_rec.program_agreement_id := p5_a36;
    ddp_lapv_rec.master_lease_id := p5_a37;
    ddp_lapv_rec.sales_rep_id := p5_a38;
    ddp_lapv_rec.sales_territory_id := p5_a39;
    ddp_lapv_rec.originating_vendor_id := p5_a40;
    ddp_lapv_rec.lease_opportunity_id := p5_a41;
    ddp_lapv_rec.short_description := p5_a42;
    ddp_lapv_rec.comments := p5_a43;
    ddp_lapv_rec.cr_exp_days := p5_a44;
    ddp_lapv_rec.action := p5_a45;
    ddp_lapv_rec.orig_status := p5_a46;

    -- here's the delegated call to the old PL/SQL routine
    okl_lap_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lapv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_lap_pvt_w;

/
