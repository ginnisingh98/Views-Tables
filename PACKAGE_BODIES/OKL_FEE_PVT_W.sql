--------------------------------------------------------
--  DDL for Package Body OKL_FEE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FEE_PVT_W" as
  /* $Header: OKLIFEEB.pls 120.2 2006/03/16 10:09:43 asawanka noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_fee_pvt.feev_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_2000
    , a37 JTF_VARCHAR2_TABLE_2000
    , a38 JTF_NUMBER_TABLE
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
          t(ddindx).parent_object_code := a18(indx);
          t(ddindx).parent_object_id := a19(indx);
          t(ddindx).stream_type_id := a20(indx);
          t(ddindx).fee_type := a21(indx);
          t(ddindx).structured_pricing := a22(indx);
          t(ddindx).rate_template_id := a23(indx);
          t(ddindx).rate_card_id := a24(indx);
          t(ddindx).lease_rate_factor := a25(indx);
          t(ddindx).target_arrears := a26(indx);
          t(ddindx).effective_from := a27(indx);
          t(ddindx).effective_to := a28(indx);
          t(ddindx).supplier_id := a29(indx);
          t(ddindx).rollover_quote_id := a30(indx);
          t(ddindx).initial_direct_cost := a31(indx);
          t(ddindx).fee_amount := a32(indx);
          t(ddindx).target_amount := a33(indx);
          t(ddindx).target_frequency := a34(indx);
          t(ddindx).short_description := a35(indx);
          t(ddindx).description := a36(indx);
          t(ddindx).comments := a37(indx);
          t(ddindx).payment_type_id := a38(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_fee_pvt.feev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_2000
    , a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , a38 out nocopy JTF_NUMBER_TABLE
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
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_2000();
    a37 := JTF_VARCHAR2_TABLE_2000();
    a38 := JTF_NUMBER_TABLE();
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
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_2000();
      a37 := JTF_VARCHAR2_TABLE_2000();
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
          a18(indx) := t(ddindx).parent_object_code;
          a19(indx) := t(ddindx).parent_object_id;
          a20(indx) := t(ddindx).stream_type_id;
          a21(indx) := t(ddindx).fee_type;
          a22(indx) := t(ddindx).structured_pricing;
          a23(indx) := t(ddindx).rate_template_id;
          a24(indx) := t(ddindx).rate_card_id;
          a25(indx) := t(ddindx).lease_rate_factor;
          a26(indx) := t(ddindx).target_arrears;
          a27(indx) := t(ddindx).effective_from;
          a28(indx) := t(ddindx).effective_to;
          a29(indx) := t(ddindx).supplier_id;
          a30(indx) := t(ddindx).rollover_quote_id;
          a31(indx) := t(ddindx).initial_direct_cost;
          a32(indx) := t(ddindx).fee_amount;
          a33(indx) := t(ddindx).target_amount;
          a34(indx) := t(ddindx).target_frequency;
          a35(indx) := t(ddindx).short_description;
          a36(indx) := t(ddindx).description;
          a37(indx) := t(ddindx).comments;
          a38(indx) := t(ddindx).payment_type_id;
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
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_300
    , p5_a36 JTF_VARCHAR2_TABLE_2000
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_NUMBER_TABLE
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
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a38 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_feev_tbl okl_fee_pvt.feev_tbl_type;
    ddx_feev_tbl okl_fee_pvt.feev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fee_pvt_w.rosetta_table_copy_in_p23(ddp_feev_tbl, p5_a0
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
    okl_fee_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_feev_tbl,
      ddx_feev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_fee_pvt_w.rosetta_table_copy_out_p23(ddx_feev_tbl, p6_a0
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
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_300
    , p5_a36 JTF_VARCHAR2_TABLE_2000
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_NUMBER_TABLE
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
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_NUMBER_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a38 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_feev_tbl okl_fee_pvt.feev_tbl_type;
    ddx_feev_tbl okl_fee_pvt.feev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fee_pvt_w.rosetta_table_copy_in_p23(ddp_feev_tbl, p5_a0
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
    okl_fee_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_feev_tbl,
      ddx_feev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_fee_pvt_w.rosetta_table_copy_out_p23(ddx_feev_tbl, p6_a0
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
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_300
    , p5_a36 JTF_VARCHAR2_TABLE_2000
    , p5_a37 JTF_VARCHAR2_TABLE_2000
    , p5_a38 JTF_NUMBER_TABLE
  )

  as
    ddp_feev_tbl okl_fee_pvt.feev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_fee_pvt_w.rosetta_table_copy_in_p23(ddp_feev_tbl, p5_a0
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
    okl_fee_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_feev_tbl);

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
    , p5_a19  NUMBER
    , p5_a20  NUMBER
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  VARCHAR2
    , p5_a27  DATE
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  NUMBER
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  NUMBER
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
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
  )

  as
    ddp_feev_rec okl_fee_pvt.feev_rec_type;
    ddx_feev_rec okl_fee_pvt.feev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_feev_rec.id := p5_a0;
    ddp_feev_rec.object_version_number := p5_a1;
    ddp_feev_rec.attribute_category := p5_a2;
    ddp_feev_rec.attribute1 := p5_a3;
    ddp_feev_rec.attribute2 := p5_a4;
    ddp_feev_rec.attribute3 := p5_a5;
    ddp_feev_rec.attribute4 := p5_a6;
    ddp_feev_rec.attribute5 := p5_a7;
    ddp_feev_rec.attribute6 := p5_a8;
    ddp_feev_rec.attribute7 := p5_a9;
    ddp_feev_rec.attribute8 := p5_a10;
    ddp_feev_rec.attribute9 := p5_a11;
    ddp_feev_rec.attribute10 := p5_a12;
    ddp_feev_rec.attribute11 := p5_a13;
    ddp_feev_rec.attribute12 := p5_a14;
    ddp_feev_rec.attribute13 := p5_a15;
    ddp_feev_rec.attribute14 := p5_a16;
    ddp_feev_rec.attribute15 := p5_a17;
    ddp_feev_rec.parent_object_code := p5_a18;
    ddp_feev_rec.parent_object_id := p5_a19;
    ddp_feev_rec.stream_type_id := p5_a20;
    ddp_feev_rec.fee_type := p5_a21;
    ddp_feev_rec.structured_pricing := p5_a22;
    ddp_feev_rec.rate_template_id := p5_a23;
    ddp_feev_rec.rate_card_id := p5_a24;
    ddp_feev_rec.lease_rate_factor := p5_a25;
    ddp_feev_rec.target_arrears := p5_a26;
    ddp_feev_rec.effective_from := p5_a27;
    ddp_feev_rec.effective_to := p5_a28;
    ddp_feev_rec.supplier_id := p5_a29;
    ddp_feev_rec.rollover_quote_id := p5_a30;
    ddp_feev_rec.initial_direct_cost := p5_a31;
    ddp_feev_rec.fee_amount := p5_a32;
    ddp_feev_rec.target_amount := p5_a33;
    ddp_feev_rec.target_frequency := p5_a34;
    ddp_feev_rec.short_description := p5_a35;
    ddp_feev_rec.description := p5_a36;
    ddp_feev_rec.comments := p5_a37;
    ddp_feev_rec.payment_type_id := p5_a38;


    -- here's the delegated call to the old PL/SQL routine
    okl_fee_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_feev_rec,
      ddx_feev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_feev_rec.id;
    p6_a1 := ddx_feev_rec.object_version_number;
    p6_a2 := ddx_feev_rec.attribute_category;
    p6_a3 := ddx_feev_rec.attribute1;
    p6_a4 := ddx_feev_rec.attribute2;
    p6_a5 := ddx_feev_rec.attribute3;
    p6_a6 := ddx_feev_rec.attribute4;
    p6_a7 := ddx_feev_rec.attribute5;
    p6_a8 := ddx_feev_rec.attribute6;
    p6_a9 := ddx_feev_rec.attribute7;
    p6_a10 := ddx_feev_rec.attribute8;
    p6_a11 := ddx_feev_rec.attribute9;
    p6_a12 := ddx_feev_rec.attribute10;
    p6_a13 := ddx_feev_rec.attribute11;
    p6_a14 := ddx_feev_rec.attribute12;
    p6_a15 := ddx_feev_rec.attribute13;
    p6_a16 := ddx_feev_rec.attribute14;
    p6_a17 := ddx_feev_rec.attribute15;
    p6_a18 := ddx_feev_rec.parent_object_code;
    p6_a19 := ddx_feev_rec.parent_object_id;
    p6_a20 := ddx_feev_rec.stream_type_id;
    p6_a21 := ddx_feev_rec.fee_type;
    p6_a22 := ddx_feev_rec.structured_pricing;
    p6_a23 := ddx_feev_rec.rate_template_id;
    p6_a24 := ddx_feev_rec.rate_card_id;
    p6_a25 := ddx_feev_rec.lease_rate_factor;
    p6_a26 := ddx_feev_rec.target_arrears;
    p6_a27 := ddx_feev_rec.effective_from;
    p6_a28 := ddx_feev_rec.effective_to;
    p6_a29 := ddx_feev_rec.supplier_id;
    p6_a30 := ddx_feev_rec.rollover_quote_id;
    p6_a31 := ddx_feev_rec.initial_direct_cost;
    p6_a32 := ddx_feev_rec.fee_amount;
    p6_a33 := ddx_feev_rec.target_amount;
    p6_a34 := ddx_feev_rec.target_frequency;
    p6_a35 := ddx_feev_rec.short_description;
    p6_a36 := ddx_feev_rec.description;
    p6_a37 := ddx_feev_rec.comments;
    p6_a38 := ddx_feev_rec.payment_type_id;
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
    , p5_a19  NUMBER
    , p5_a20  NUMBER
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  VARCHAR2
    , p5_a27  DATE
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  NUMBER
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  NUMBER
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
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
  )

  as
    ddp_feev_rec okl_fee_pvt.feev_rec_type;
    ddx_feev_rec okl_fee_pvt.feev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_feev_rec.id := p5_a0;
    ddp_feev_rec.object_version_number := p5_a1;
    ddp_feev_rec.attribute_category := p5_a2;
    ddp_feev_rec.attribute1 := p5_a3;
    ddp_feev_rec.attribute2 := p5_a4;
    ddp_feev_rec.attribute3 := p5_a5;
    ddp_feev_rec.attribute4 := p5_a6;
    ddp_feev_rec.attribute5 := p5_a7;
    ddp_feev_rec.attribute6 := p5_a8;
    ddp_feev_rec.attribute7 := p5_a9;
    ddp_feev_rec.attribute8 := p5_a10;
    ddp_feev_rec.attribute9 := p5_a11;
    ddp_feev_rec.attribute10 := p5_a12;
    ddp_feev_rec.attribute11 := p5_a13;
    ddp_feev_rec.attribute12 := p5_a14;
    ddp_feev_rec.attribute13 := p5_a15;
    ddp_feev_rec.attribute14 := p5_a16;
    ddp_feev_rec.attribute15 := p5_a17;
    ddp_feev_rec.parent_object_code := p5_a18;
    ddp_feev_rec.parent_object_id := p5_a19;
    ddp_feev_rec.stream_type_id := p5_a20;
    ddp_feev_rec.fee_type := p5_a21;
    ddp_feev_rec.structured_pricing := p5_a22;
    ddp_feev_rec.rate_template_id := p5_a23;
    ddp_feev_rec.rate_card_id := p5_a24;
    ddp_feev_rec.lease_rate_factor := p5_a25;
    ddp_feev_rec.target_arrears := p5_a26;
    ddp_feev_rec.effective_from := p5_a27;
    ddp_feev_rec.effective_to := p5_a28;
    ddp_feev_rec.supplier_id := p5_a29;
    ddp_feev_rec.rollover_quote_id := p5_a30;
    ddp_feev_rec.initial_direct_cost := p5_a31;
    ddp_feev_rec.fee_amount := p5_a32;
    ddp_feev_rec.target_amount := p5_a33;
    ddp_feev_rec.target_frequency := p5_a34;
    ddp_feev_rec.short_description := p5_a35;
    ddp_feev_rec.description := p5_a36;
    ddp_feev_rec.comments := p5_a37;
    ddp_feev_rec.payment_type_id := p5_a38;


    -- here's the delegated call to the old PL/SQL routine
    okl_fee_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_feev_rec,
      ddx_feev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_feev_rec.id;
    p6_a1 := ddx_feev_rec.object_version_number;
    p6_a2 := ddx_feev_rec.attribute_category;
    p6_a3 := ddx_feev_rec.attribute1;
    p6_a4 := ddx_feev_rec.attribute2;
    p6_a5 := ddx_feev_rec.attribute3;
    p6_a6 := ddx_feev_rec.attribute4;
    p6_a7 := ddx_feev_rec.attribute5;
    p6_a8 := ddx_feev_rec.attribute6;
    p6_a9 := ddx_feev_rec.attribute7;
    p6_a10 := ddx_feev_rec.attribute8;
    p6_a11 := ddx_feev_rec.attribute9;
    p6_a12 := ddx_feev_rec.attribute10;
    p6_a13 := ddx_feev_rec.attribute11;
    p6_a14 := ddx_feev_rec.attribute12;
    p6_a15 := ddx_feev_rec.attribute13;
    p6_a16 := ddx_feev_rec.attribute14;
    p6_a17 := ddx_feev_rec.attribute15;
    p6_a18 := ddx_feev_rec.parent_object_code;
    p6_a19 := ddx_feev_rec.parent_object_id;
    p6_a20 := ddx_feev_rec.stream_type_id;
    p6_a21 := ddx_feev_rec.fee_type;
    p6_a22 := ddx_feev_rec.structured_pricing;
    p6_a23 := ddx_feev_rec.rate_template_id;
    p6_a24 := ddx_feev_rec.rate_card_id;
    p6_a25 := ddx_feev_rec.lease_rate_factor;
    p6_a26 := ddx_feev_rec.target_arrears;
    p6_a27 := ddx_feev_rec.effective_from;
    p6_a28 := ddx_feev_rec.effective_to;
    p6_a29 := ddx_feev_rec.supplier_id;
    p6_a30 := ddx_feev_rec.rollover_quote_id;
    p6_a31 := ddx_feev_rec.initial_direct_cost;
    p6_a32 := ddx_feev_rec.fee_amount;
    p6_a33 := ddx_feev_rec.target_amount;
    p6_a34 := ddx_feev_rec.target_frequency;
    p6_a35 := ddx_feev_rec.short_description;
    p6_a36 := ddx_feev_rec.description;
    p6_a37 := ddx_feev_rec.comments;
    p6_a38 := ddx_feev_rec.payment_type_id;
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
    , p5_a19  NUMBER
    , p5_a20  NUMBER
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  VARCHAR2
    , p5_a27  DATE
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  NUMBER
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  NUMBER
  )

  as
    ddp_feev_rec okl_fee_pvt.feev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_feev_rec.id := p5_a0;
    ddp_feev_rec.object_version_number := p5_a1;
    ddp_feev_rec.attribute_category := p5_a2;
    ddp_feev_rec.attribute1 := p5_a3;
    ddp_feev_rec.attribute2 := p5_a4;
    ddp_feev_rec.attribute3 := p5_a5;
    ddp_feev_rec.attribute4 := p5_a6;
    ddp_feev_rec.attribute5 := p5_a7;
    ddp_feev_rec.attribute6 := p5_a8;
    ddp_feev_rec.attribute7 := p5_a9;
    ddp_feev_rec.attribute8 := p5_a10;
    ddp_feev_rec.attribute9 := p5_a11;
    ddp_feev_rec.attribute10 := p5_a12;
    ddp_feev_rec.attribute11 := p5_a13;
    ddp_feev_rec.attribute12 := p5_a14;
    ddp_feev_rec.attribute13 := p5_a15;
    ddp_feev_rec.attribute14 := p5_a16;
    ddp_feev_rec.attribute15 := p5_a17;
    ddp_feev_rec.parent_object_code := p5_a18;
    ddp_feev_rec.parent_object_id := p5_a19;
    ddp_feev_rec.stream_type_id := p5_a20;
    ddp_feev_rec.fee_type := p5_a21;
    ddp_feev_rec.structured_pricing := p5_a22;
    ddp_feev_rec.rate_template_id := p5_a23;
    ddp_feev_rec.rate_card_id := p5_a24;
    ddp_feev_rec.lease_rate_factor := p5_a25;
    ddp_feev_rec.target_arrears := p5_a26;
    ddp_feev_rec.effective_from := p5_a27;
    ddp_feev_rec.effective_to := p5_a28;
    ddp_feev_rec.supplier_id := p5_a29;
    ddp_feev_rec.rollover_quote_id := p5_a30;
    ddp_feev_rec.initial_direct_cost := p5_a31;
    ddp_feev_rec.fee_amount := p5_a32;
    ddp_feev_rec.target_amount := p5_a33;
    ddp_feev_rec.target_frequency := p5_a34;
    ddp_feev_rec.short_description := p5_a35;
    ddp_feev_rec.description := p5_a36;
    ddp_feev_rec.comments := p5_a37;
    ddp_feev_rec.payment_type_id := p5_a38;

    -- here's the delegated call to the old PL/SQL routine
    okl_fee_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_feev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_fee_pvt_w;

/
