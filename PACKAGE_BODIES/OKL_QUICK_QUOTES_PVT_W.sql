--------------------------------------------------------
--  DDL for Package Body OKL_QUICK_QUOTES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QUICK_QUOTES_PVT_W" as
  /* $Header: OKLEQQHB.pls 120.3 2006/02/10 07:40:49 asawanka noship $ */
  procedure rosetta_table_copy_in_p8(t out nocopy okl_quick_quotes_pvt.rent_payments_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rate := a0(indx);
          t(ddindx).stub_amt := a1(indx);
          t(ddindx).stub_days := a2(indx);
          t(ddindx).periods := a3(indx);
          t(ddindx).periodic_amount := a4(indx);
          t(ddindx).start_date := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_quick_quotes_pvt.rent_payments_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rate;
          a1(indx) := t(ddindx).stub_amt;
          a2(indx) := t(ddindx).stub_days;
          a3(indx) := t(ddindx).periods;
          a4(indx) := t(ddindx).periodic_amount;
          a5(indx) := t(ddindx).start_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p10(t out nocopy okl_quick_quotes_pvt.fee_service_payments_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).payment_type := a0(indx);
          t(ddindx).periods := a1(indx);
          t(ddindx).periodic_amt := a2(indx);
          t(ddindx).start_date := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t okl_quick_quotes_pvt.fee_service_payments_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).payment_type;
          a1(indx) := t(ddindx).periods;
          a2(indx) := t(ddindx).periodic_amt;
          a3(indx) := t(ddindx).start_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p12(t out nocopy okl_quick_quotes_pvt.item_order_estimate_tbl, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_category := a0(indx);
          t(ddindx).description := a1(indx);
          t(ddindx).cost := a2(indx);
          t(ddindx).purchase_option_value := a3(indx);
          t(ddindx).rate_factor := a4(indx);
          t(ddindx).periods := a5(indx);
          t(ddindx).periodic_amt := a6(indx);
          t(ddindx).start_date := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t okl_quick_quotes_pvt.item_order_estimate_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).item_category;
          a1(indx) := t(ddindx).description;
          a2(indx) := t(ddindx).cost;
          a3(indx) := t(ddindx).purchase_option_value;
          a4(indx) := t(ddindx).rate_factor;
          a5(indx) := t(ddindx).periods;
          a6(indx) := t(ddindx).periodic_amt;
          a7(indx) := t(ddindx).start_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure create_quick_qte(p_api_version  NUMBER
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
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
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
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_500
    , p7_a4 JTF_VARCHAR2_TABLE_500
    , p7_a5 JTF_VARCHAR2_TABLE_500
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_VARCHAR2_TABLE_100
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_VARCHAR2_TABLE_300
    , p7_a29 JTF_VARCHAR2_TABLE_2000
    , p7_a30 JTF_VARCHAR2_TABLE_2000
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_NUMBER_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_qqhv_rec_type okl_quick_quotes_pvt.qqhv_rec_type;
    ddx_qqhv_rec_type okl_quick_quotes_pvt.qqhv_rec_type;
    ddp_qqlv_tbl_type okl_quick_quotes_pvt.qqlv_tbl_type;
    ddx_qqlv_tbl_type okl_quick_quotes_pvt.qqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqhv_rec_type.id := p5_a0;
    ddp_qqhv_rec_type.object_version_number := p5_a1;
    ddp_qqhv_rec_type.attribute_category := p5_a2;
    ddp_qqhv_rec_type.attribute1 := p5_a3;
    ddp_qqhv_rec_type.attribute2 := p5_a4;
    ddp_qqhv_rec_type.attribute3 := p5_a5;
    ddp_qqhv_rec_type.attribute4 := p5_a6;
    ddp_qqhv_rec_type.attribute5 := p5_a7;
    ddp_qqhv_rec_type.attribute6 := p5_a8;
    ddp_qqhv_rec_type.attribute7 := p5_a9;
    ddp_qqhv_rec_type.attribute8 := p5_a10;
    ddp_qqhv_rec_type.attribute9 := p5_a11;
    ddp_qqhv_rec_type.attribute10 := p5_a12;
    ddp_qqhv_rec_type.attribute11 := p5_a13;
    ddp_qqhv_rec_type.attribute12 := p5_a14;
    ddp_qqhv_rec_type.attribute13 := p5_a15;
    ddp_qqhv_rec_type.attribute14 := p5_a16;
    ddp_qqhv_rec_type.attribute15 := p5_a17;
    ddp_qqhv_rec_type.reference_number := p5_a18;
    ddp_qqhv_rec_type.expected_start_date := p5_a19;
    ddp_qqhv_rec_type.org_id := p5_a20;
    ddp_qqhv_rec_type.inv_org_id := p5_a21;
    ddp_qqhv_rec_type.currency_code := p5_a22;
    ddp_qqhv_rec_type.term := p5_a23;
    ddp_qqhv_rec_type.end_of_term_option_id := p5_a24;
    ddp_qqhv_rec_type.pricing_method := p5_a25;
    ddp_qqhv_rec_type.lease_opportunity_id := p5_a26;
    ddp_qqhv_rec_type.originating_vendor_id := p5_a27;
    ddp_qqhv_rec_type.program_agreement_id := p5_a28;
    ddp_qqhv_rec_type.sales_rep_id := p5_a29;
    ddp_qqhv_rec_type.sales_territory_id := p5_a30;
    ddp_qqhv_rec_type.structured_pricing := p5_a31;
    ddp_qqhv_rec_type.line_level_pricing := p5_a32;
    ddp_qqhv_rec_type.rate_template_id := p5_a33;
    ddp_qqhv_rec_type.rate_card_id := p5_a34;
    ddp_qqhv_rec_type.lease_rate_factor := p5_a35;
    ddp_qqhv_rec_type.target_rate_type := p5_a36;
    ddp_qqhv_rec_type.target_rate := p5_a37;
    ddp_qqhv_rec_type.target_amount := p5_a38;
    ddp_qqhv_rec_type.target_frequency := p5_a39;
    ddp_qqhv_rec_type.target_arrears := p5_a40;
    ddp_qqhv_rec_type.target_periods := p5_a41;
    ddp_qqhv_rec_type.iir := p5_a42;
    ddp_qqhv_rec_type.sub_iir := p5_a43;
    ddp_qqhv_rec_type.booking_yield := p5_a44;
    ddp_qqhv_rec_type.sub_booking_yield := p5_a45;
    ddp_qqhv_rec_type.pirr := p5_a46;
    ddp_qqhv_rec_type.sub_pirr := p5_a47;
    ddp_qqhv_rec_type.airr := p5_a48;
    ddp_qqhv_rec_type.sub_airr := p5_a49;
    ddp_qqhv_rec_type.short_description := p5_a50;
    ddp_qqhv_rec_type.description := p5_a51;
    ddp_qqhv_rec_type.comments := p5_a52;
    ddp_qqhv_rec_type.sts_code := p5_a53;


    okl_qql_pvt_w.rosetta_table_copy_in_p23(ddp_qqlv_tbl_type, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_quick_quotes_pvt.create_quick_qte(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_rec_type,
      ddx_qqhv_rec_type,
      ddp_qqlv_tbl_type,
      ddx_qqlv_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_qqhv_rec_type.id;
    p6_a1 := ddx_qqhv_rec_type.object_version_number;
    p6_a2 := ddx_qqhv_rec_type.attribute_category;
    p6_a3 := ddx_qqhv_rec_type.attribute1;
    p6_a4 := ddx_qqhv_rec_type.attribute2;
    p6_a5 := ddx_qqhv_rec_type.attribute3;
    p6_a6 := ddx_qqhv_rec_type.attribute4;
    p6_a7 := ddx_qqhv_rec_type.attribute5;
    p6_a8 := ddx_qqhv_rec_type.attribute6;
    p6_a9 := ddx_qqhv_rec_type.attribute7;
    p6_a10 := ddx_qqhv_rec_type.attribute8;
    p6_a11 := ddx_qqhv_rec_type.attribute9;
    p6_a12 := ddx_qqhv_rec_type.attribute10;
    p6_a13 := ddx_qqhv_rec_type.attribute11;
    p6_a14 := ddx_qqhv_rec_type.attribute12;
    p6_a15 := ddx_qqhv_rec_type.attribute13;
    p6_a16 := ddx_qqhv_rec_type.attribute14;
    p6_a17 := ddx_qqhv_rec_type.attribute15;
    p6_a18 := ddx_qqhv_rec_type.reference_number;
    p6_a19 := ddx_qqhv_rec_type.expected_start_date;
    p6_a20 := ddx_qqhv_rec_type.org_id;
    p6_a21 := ddx_qqhv_rec_type.inv_org_id;
    p6_a22 := ddx_qqhv_rec_type.currency_code;
    p6_a23 := ddx_qqhv_rec_type.term;
    p6_a24 := ddx_qqhv_rec_type.end_of_term_option_id;
    p6_a25 := ddx_qqhv_rec_type.pricing_method;
    p6_a26 := ddx_qqhv_rec_type.lease_opportunity_id;
    p6_a27 := ddx_qqhv_rec_type.originating_vendor_id;
    p6_a28 := ddx_qqhv_rec_type.program_agreement_id;
    p6_a29 := ddx_qqhv_rec_type.sales_rep_id;
    p6_a30 := ddx_qqhv_rec_type.sales_territory_id;
    p6_a31 := ddx_qqhv_rec_type.structured_pricing;
    p6_a32 := ddx_qqhv_rec_type.line_level_pricing;
    p6_a33 := ddx_qqhv_rec_type.rate_template_id;
    p6_a34 := ddx_qqhv_rec_type.rate_card_id;
    p6_a35 := ddx_qqhv_rec_type.lease_rate_factor;
    p6_a36 := ddx_qqhv_rec_type.target_rate_type;
    p6_a37 := ddx_qqhv_rec_type.target_rate;
    p6_a38 := ddx_qqhv_rec_type.target_amount;
    p6_a39 := ddx_qqhv_rec_type.target_frequency;
    p6_a40 := ddx_qqhv_rec_type.target_arrears;
    p6_a41 := ddx_qqhv_rec_type.target_periods;
    p6_a42 := ddx_qqhv_rec_type.iir;
    p6_a43 := ddx_qqhv_rec_type.sub_iir;
    p6_a44 := ddx_qqhv_rec_type.booking_yield;
    p6_a45 := ddx_qqhv_rec_type.sub_booking_yield;
    p6_a46 := ddx_qqhv_rec_type.pirr;
    p6_a47 := ddx_qqhv_rec_type.sub_pirr;
    p6_a48 := ddx_qqhv_rec_type.airr;
    p6_a49 := ddx_qqhv_rec_type.sub_airr;
    p6_a50 := ddx_qqhv_rec_type.short_description;
    p6_a51 := ddx_qqhv_rec_type.description;
    p6_a52 := ddx_qqhv_rec_type.comments;
    p6_a53 := ddx_qqhv_rec_type.sts_code;


    okl_qql_pvt_w.rosetta_table_copy_out_p23(ddx_qqlv_tbl_type, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      );
  end;

  procedure update_quick_qte(p_api_version  NUMBER
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
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
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
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_500
    , p7_a4 JTF_VARCHAR2_TABLE_500
    , p7_a5 JTF_VARCHAR2_TABLE_500
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_VARCHAR2_TABLE_100
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_VARCHAR2_TABLE_300
    , p7_a29 JTF_VARCHAR2_TABLE_2000
    , p7_a30 JTF_VARCHAR2_TABLE_2000
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_NUMBER_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_qqhv_rec_type okl_quick_quotes_pvt.qqhv_rec_type;
    ddx_qqhv_rec_type okl_quick_quotes_pvt.qqhv_rec_type;
    ddp_qqlv_tbl_type okl_quick_quotes_pvt.qqlv_tbl_type;
    ddx_qqlv_tbl_type okl_quick_quotes_pvt.qqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqhv_rec_type.id := p5_a0;
    ddp_qqhv_rec_type.object_version_number := p5_a1;
    ddp_qqhv_rec_type.attribute_category := p5_a2;
    ddp_qqhv_rec_type.attribute1 := p5_a3;
    ddp_qqhv_rec_type.attribute2 := p5_a4;
    ddp_qqhv_rec_type.attribute3 := p5_a5;
    ddp_qqhv_rec_type.attribute4 := p5_a6;
    ddp_qqhv_rec_type.attribute5 := p5_a7;
    ddp_qqhv_rec_type.attribute6 := p5_a8;
    ddp_qqhv_rec_type.attribute7 := p5_a9;
    ddp_qqhv_rec_type.attribute8 := p5_a10;
    ddp_qqhv_rec_type.attribute9 := p5_a11;
    ddp_qqhv_rec_type.attribute10 := p5_a12;
    ddp_qqhv_rec_type.attribute11 := p5_a13;
    ddp_qqhv_rec_type.attribute12 := p5_a14;
    ddp_qqhv_rec_type.attribute13 := p5_a15;
    ddp_qqhv_rec_type.attribute14 := p5_a16;
    ddp_qqhv_rec_type.attribute15 := p5_a17;
    ddp_qqhv_rec_type.reference_number := p5_a18;
    ddp_qqhv_rec_type.expected_start_date := p5_a19;
    ddp_qqhv_rec_type.org_id := p5_a20;
    ddp_qqhv_rec_type.inv_org_id := p5_a21;
    ddp_qqhv_rec_type.currency_code := p5_a22;
    ddp_qqhv_rec_type.term := p5_a23;
    ddp_qqhv_rec_type.end_of_term_option_id := p5_a24;
    ddp_qqhv_rec_type.pricing_method := p5_a25;
    ddp_qqhv_rec_type.lease_opportunity_id := p5_a26;
    ddp_qqhv_rec_type.originating_vendor_id := p5_a27;
    ddp_qqhv_rec_type.program_agreement_id := p5_a28;
    ddp_qqhv_rec_type.sales_rep_id := p5_a29;
    ddp_qqhv_rec_type.sales_territory_id := p5_a30;
    ddp_qqhv_rec_type.structured_pricing := p5_a31;
    ddp_qqhv_rec_type.line_level_pricing := p5_a32;
    ddp_qqhv_rec_type.rate_template_id := p5_a33;
    ddp_qqhv_rec_type.rate_card_id := p5_a34;
    ddp_qqhv_rec_type.lease_rate_factor := p5_a35;
    ddp_qqhv_rec_type.target_rate_type := p5_a36;
    ddp_qqhv_rec_type.target_rate := p5_a37;
    ddp_qqhv_rec_type.target_amount := p5_a38;
    ddp_qqhv_rec_type.target_frequency := p5_a39;
    ddp_qqhv_rec_type.target_arrears := p5_a40;
    ddp_qqhv_rec_type.target_periods := p5_a41;
    ddp_qqhv_rec_type.iir := p5_a42;
    ddp_qqhv_rec_type.sub_iir := p5_a43;
    ddp_qqhv_rec_type.booking_yield := p5_a44;
    ddp_qqhv_rec_type.sub_booking_yield := p5_a45;
    ddp_qqhv_rec_type.pirr := p5_a46;
    ddp_qqhv_rec_type.sub_pirr := p5_a47;
    ddp_qqhv_rec_type.airr := p5_a48;
    ddp_qqhv_rec_type.sub_airr := p5_a49;
    ddp_qqhv_rec_type.short_description := p5_a50;
    ddp_qqhv_rec_type.description := p5_a51;
    ddp_qqhv_rec_type.comments := p5_a52;
    ddp_qqhv_rec_type.sts_code := p5_a53;


    okl_qql_pvt_w.rosetta_table_copy_in_p23(ddp_qqlv_tbl_type, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_quick_quotes_pvt.update_quick_qte(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_rec_type,
      ddx_qqhv_rec_type,
      ddp_qqlv_tbl_type,
      ddx_qqlv_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_qqhv_rec_type.id;
    p6_a1 := ddx_qqhv_rec_type.object_version_number;
    p6_a2 := ddx_qqhv_rec_type.attribute_category;
    p6_a3 := ddx_qqhv_rec_type.attribute1;
    p6_a4 := ddx_qqhv_rec_type.attribute2;
    p6_a5 := ddx_qqhv_rec_type.attribute3;
    p6_a6 := ddx_qqhv_rec_type.attribute4;
    p6_a7 := ddx_qqhv_rec_type.attribute5;
    p6_a8 := ddx_qqhv_rec_type.attribute6;
    p6_a9 := ddx_qqhv_rec_type.attribute7;
    p6_a10 := ddx_qqhv_rec_type.attribute8;
    p6_a11 := ddx_qqhv_rec_type.attribute9;
    p6_a12 := ddx_qqhv_rec_type.attribute10;
    p6_a13 := ddx_qqhv_rec_type.attribute11;
    p6_a14 := ddx_qqhv_rec_type.attribute12;
    p6_a15 := ddx_qqhv_rec_type.attribute13;
    p6_a16 := ddx_qqhv_rec_type.attribute14;
    p6_a17 := ddx_qqhv_rec_type.attribute15;
    p6_a18 := ddx_qqhv_rec_type.reference_number;
    p6_a19 := ddx_qqhv_rec_type.expected_start_date;
    p6_a20 := ddx_qqhv_rec_type.org_id;
    p6_a21 := ddx_qqhv_rec_type.inv_org_id;
    p6_a22 := ddx_qqhv_rec_type.currency_code;
    p6_a23 := ddx_qqhv_rec_type.term;
    p6_a24 := ddx_qqhv_rec_type.end_of_term_option_id;
    p6_a25 := ddx_qqhv_rec_type.pricing_method;
    p6_a26 := ddx_qqhv_rec_type.lease_opportunity_id;
    p6_a27 := ddx_qqhv_rec_type.originating_vendor_id;
    p6_a28 := ddx_qqhv_rec_type.program_agreement_id;
    p6_a29 := ddx_qqhv_rec_type.sales_rep_id;
    p6_a30 := ddx_qqhv_rec_type.sales_territory_id;
    p6_a31 := ddx_qqhv_rec_type.structured_pricing;
    p6_a32 := ddx_qqhv_rec_type.line_level_pricing;
    p6_a33 := ddx_qqhv_rec_type.rate_template_id;
    p6_a34 := ddx_qqhv_rec_type.rate_card_id;
    p6_a35 := ddx_qqhv_rec_type.lease_rate_factor;
    p6_a36 := ddx_qqhv_rec_type.target_rate_type;
    p6_a37 := ddx_qqhv_rec_type.target_rate;
    p6_a38 := ddx_qqhv_rec_type.target_amount;
    p6_a39 := ddx_qqhv_rec_type.target_frequency;
    p6_a40 := ddx_qqhv_rec_type.target_arrears;
    p6_a41 := ddx_qqhv_rec_type.target_periods;
    p6_a42 := ddx_qqhv_rec_type.iir;
    p6_a43 := ddx_qqhv_rec_type.sub_iir;
    p6_a44 := ddx_qqhv_rec_type.booking_yield;
    p6_a45 := ddx_qqhv_rec_type.sub_booking_yield;
    p6_a46 := ddx_qqhv_rec_type.pirr;
    p6_a47 := ddx_qqhv_rec_type.sub_pirr;
    p6_a48 := ddx_qqhv_rec_type.airr;
    p6_a49 := ddx_qqhv_rec_type.sub_airr;
    p6_a50 := ddx_qqhv_rec_type.short_description;
    p6_a51 := ddx_qqhv_rec_type.description;
    p6_a52 := ddx_qqhv_rec_type.comments;
    p6_a53 := ddx_qqhv_rec_type.sts_code;


    okl_qql_pvt_w.rosetta_table_copy_out_p23(ddx_qqlv_tbl_type, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      );
  end;

  procedure delete_qql(p_api_version  NUMBER
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
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
  )

  as
    ddp_qqlv_rec_type okl_quick_quotes_pvt.qqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqlv_rec_type.id := p5_a0;
    ddp_qqlv_rec_type.object_version_number := p5_a1;
    ddp_qqlv_rec_type.attribute_category := p5_a2;
    ddp_qqlv_rec_type.attribute1 := p5_a3;
    ddp_qqlv_rec_type.attribute2 := p5_a4;
    ddp_qqlv_rec_type.attribute3 := p5_a5;
    ddp_qqlv_rec_type.attribute4 := p5_a6;
    ddp_qqlv_rec_type.attribute5 := p5_a7;
    ddp_qqlv_rec_type.attribute6 := p5_a8;
    ddp_qqlv_rec_type.attribute7 := p5_a9;
    ddp_qqlv_rec_type.attribute8 := p5_a10;
    ddp_qqlv_rec_type.attribute9 := p5_a11;
    ddp_qqlv_rec_type.attribute10 := p5_a12;
    ddp_qqlv_rec_type.attribute11 := p5_a13;
    ddp_qqlv_rec_type.attribute12 := p5_a14;
    ddp_qqlv_rec_type.attribute13 := p5_a15;
    ddp_qqlv_rec_type.attribute14 := p5_a16;
    ddp_qqlv_rec_type.attribute15 := p5_a17;
    ddp_qqlv_rec_type.quick_quote_id := p5_a18;
    ddp_qqlv_rec_type.type := p5_a19;
    ddp_qqlv_rec_type.basis := p5_a20;
    ddp_qqlv_rec_type.value := p5_a21;
    ddp_qqlv_rec_type.end_of_term_value_default := p5_a22;
    ddp_qqlv_rec_type.end_of_term_value := p5_a23;
    ddp_qqlv_rec_type.percentage_of_total_cost := p5_a24;
    ddp_qqlv_rec_type.item_category_id := p5_a25;
    ddp_qqlv_rec_type.item_category_set_id := p5_a26;
    ddp_qqlv_rec_type.lease_rate_factor := p5_a27;
    ddp_qqlv_rec_type.short_description := p5_a28;
    ddp_qqlv_rec_type.description := p5_a29;
    ddp_qqlv_rec_type.comments := p5_a30;

    -- here's the delegated call to the old PL/SQL routine
    okl_quick_quotes_pvt.delete_qql(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqlv_rec_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_qql(p_api_version  NUMBER
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
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_2000
    , p5_a30 JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_qqlv_tbl_type okl_quick_quotes_pvt.qqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qql_pvt_w.rosetta_table_copy_in_p23(ddp_qqlv_tbl_type, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_quick_quotes_pvt.delete_qql(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqlv_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure handle_quick_quote(p_api_version  NUMBER
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
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_500
    , p6_a4 JTF_VARCHAR2_TABLE_500
    , p6_a5 JTF_VARCHAR2_TABLE_500
    , p6_a6 JTF_VARCHAR2_TABLE_500
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_VARCHAR2_TABLE_300
    , p6_a29 JTF_VARCHAR2_TABLE_2000
    , p6_a30 JTF_VARCHAR2_TABLE_2000
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_DATE_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p_commit  VARCHAR2
    , create_yn  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  NUMBER
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_DATE_TABLE
    , p13_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_DATE_TABLE
    , p14_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_NUMBER_TABLE
    , p14_a7 out nocopy JTF_DATE_TABLE
    , p15_a0 out nocopy  NUMBER
    , p15_a1 out nocopy  NUMBER
    , p15_a2 out nocopy  VARCHAR2
    , p15_a3 out nocopy  VARCHAR2
    , p15_a4 out nocopy  VARCHAR2
    , p15_a5 out nocopy  VARCHAR2
    , p15_a6 out nocopy  VARCHAR2
    , p15_a7 out nocopy  VARCHAR2
    , p15_a8 out nocopy  VARCHAR2
    , p15_a9 out nocopy  VARCHAR2
    , p15_a10 out nocopy  VARCHAR2
    , p15_a11 out nocopy  VARCHAR2
    , p15_a12 out nocopy  VARCHAR2
    , p15_a13 out nocopy  VARCHAR2
    , p15_a14 out nocopy  VARCHAR2
    , p15_a15 out nocopy  VARCHAR2
    , p15_a16 out nocopy  VARCHAR2
    , p15_a17 out nocopy  VARCHAR2
    , p15_a18 out nocopy  VARCHAR2
    , p15_a19 out nocopy  DATE
    , p15_a20 out nocopy  NUMBER
    , p15_a21 out nocopy  NUMBER
    , p15_a22 out nocopy  VARCHAR2
    , p15_a23 out nocopy  NUMBER
    , p15_a24 out nocopy  NUMBER
    , p15_a25 out nocopy  VARCHAR2
    , p15_a26 out nocopy  NUMBER
    , p15_a27 out nocopy  NUMBER
    , p15_a28 out nocopy  NUMBER
    , p15_a29 out nocopy  NUMBER
    , p15_a30 out nocopy  NUMBER
    , p15_a31 out nocopy  VARCHAR2
    , p15_a32 out nocopy  VARCHAR2
    , p15_a33 out nocopy  NUMBER
    , p15_a34 out nocopy  NUMBER
    , p15_a35 out nocopy  NUMBER
    , p15_a36 out nocopy  VARCHAR2
    , p15_a37 out nocopy  NUMBER
    , p15_a38 out nocopy  NUMBER
    , p15_a39 out nocopy  VARCHAR2
    , p15_a40 out nocopy  VARCHAR2
    , p15_a41 out nocopy  NUMBER
    , p15_a42 out nocopy  NUMBER
    , p15_a43 out nocopy  NUMBER
    , p15_a44 out nocopy  NUMBER
    , p15_a45 out nocopy  NUMBER
    , p15_a46 out nocopy  NUMBER
    , p15_a47 out nocopy  NUMBER
    , p15_a48 out nocopy  NUMBER
    , p15_a49 out nocopy  NUMBER
    , p15_a50 out nocopy  VARCHAR2
    , p15_a51 out nocopy  VARCHAR2
    , p15_a52 out nocopy  VARCHAR2
    , p15_a53 out nocopy  VARCHAR2
    , p16_a0 out nocopy JTF_NUMBER_TABLE
    , p16_a1 out nocopy JTF_NUMBER_TABLE
    , p16_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a18 out nocopy JTF_NUMBER_TABLE
    , p16_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a21 out nocopy JTF_NUMBER_TABLE
    , p16_a22 out nocopy JTF_NUMBER_TABLE
    , p16_a23 out nocopy JTF_NUMBER_TABLE
    , p16_a24 out nocopy JTF_NUMBER_TABLE
    , p16_a25 out nocopy JTF_NUMBER_TABLE
    , p16_a26 out nocopy JTF_NUMBER_TABLE
    , p16_a27 out nocopy JTF_NUMBER_TABLE
    , p16_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p16_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p16_a30 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_qqhv_rec_type okl_quick_quotes_pvt.qqhv_rec_type;
    ddp_qqlv_tbl_type okl_quick_quotes_pvt.qqlv_tbl_type;
    ddp_cfh_rec_type okl_quick_quotes_pvt.cashflow_hdr_rec;
    ddp_cfl_tbl_type okl_quick_quotes_pvt.cashflow_level_tbl;
    ddx_payment_rec okl_quick_quotes_pvt.payment_rec_type;
    ddx_rent_payments_tbl okl_quick_quotes_pvt.rent_payments_tbl;
    ddx_fee_payments_tbl okl_quick_quotes_pvt.fee_service_payments_tbl;
    ddx_item_tbl okl_quick_quotes_pvt.item_order_estimate_tbl;
    ddx_qqhv_rec_type okl_quick_quotes_pvt.qqhv_rec_type;
    ddx_qqlv_tbl_type okl_quick_quotes_pvt.qqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqhv_rec_type.id := p5_a0;
    ddp_qqhv_rec_type.object_version_number := p5_a1;
    ddp_qqhv_rec_type.attribute_category := p5_a2;
    ddp_qqhv_rec_type.attribute1 := p5_a3;
    ddp_qqhv_rec_type.attribute2 := p5_a4;
    ddp_qqhv_rec_type.attribute3 := p5_a5;
    ddp_qqhv_rec_type.attribute4 := p5_a6;
    ddp_qqhv_rec_type.attribute5 := p5_a7;
    ddp_qqhv_rec_type.attribute6 := p5_a8;
    ddp_qqhv_rec_type.attribute7 := p5_a9;
    ddp_qqhv_rec_type.attribute8 := p5_a10;
    ddp_qqhv_rec_type.attribute9 := p5_a11;
    ddp_qqhv_rec_type.attribute10 := p5_a12;
    ddp_qqhv_rec_type.attribute11 := p5_a13;
    ddp_qqhv_rec_type.attribute12 := p5_a14;
    ddp_qqhv_rec_type.attribute13 := p5_a15;
    ddp_qqhv_rec_type.attribute14 := p5_a16;
    ddp_qqhv_rec_type.attribute15 := p5_a17;
    ddp_qqhv_rec_type.reference_number := p5_a18;
    ddp_qqhv_rec_type.expected_start_date := p5_a19;
    ddp_qqhv_rec_type.org_id := p5_a20;
    ddp_qqhv_rec_type.inv_org_id := p5_a21;
    ddp_qqhv_rec_type.currency_code := p5_a22;
    ddp_qqhv_rec_type.term := p5_a23;
    ddp_qqhv_rec_type.end_of_term_option_id := p5_a24;
    ddp_qqhv_rec_type.pricing_method := p5_a25;
    ddp_qqhv_rec_type.lease_opportunity_id := p5_a26;
    ddp_qqhv_rec_type.originating_vendor_id := p5_a27;
    ddp_qqhv_rec_type.program_agreement_id := p5_a28;
    ddp_qqhv_rec_type.sales_rep_id := p5_a29;
    ddp_qqhv_rec_type.sales_territory_id := p5_a30;
    ddp_qqhv_rec_type.structured_pricing := p5_a31;
    ddp_qqhv_rec_type.line_level_pricing := p5_a32;
    ddp_qqhv_rec_type.rate_template_id := p5_a33;
    ddp_qqhv_rec_type.rate_card_id := p5_a34;
    ddp_qqhv_rec_type.lease_rate_factor := p5_a35;
    ddp_qqhv_rec_type.target_rate_type := p5_a36;
    ddp_qqhv_rec_type.target_rate := p5_a37;
    ddp_qqhv_rec_type.target_amount := p5_a38;
    ddp_qqhv_rec_type.target_frequency := p5_a39;
    ddp_qqhv_rec_type.target_arrears := p5_a40;
    ddp_qqhv_rec_type.target_periods := p5_a41;
    ddp_qqhv_rec_type.iir := p5_a42;
    ddp_qqhv_rec_type.sub_iir := p5_a43;
    ddp_qqhv_rec_type.booking_yield := p5_a44;
    ddp_qqhv_rec_type.sub_booking_yield := p5_a45;
    ddp_qqhv_rec_type.pirr := p5_a46;
    ddp_qqhv_rec_type.sub_pirr := p5_a47;
    ddp_qqhv_rec_type.airr := p5_a48;
    ddp_qqhv_rec_type.sub_airr := p5_a49;
    ddp_qqhv_rec_type.short_description := p5_a50;
    ddp_qqhv_rec_type.description := p5_a51;
    ddp_qqhv_rec_type.comments := p5_a52;
    ddp_qqhv_rec_type.sts_code := p5_a53;

    okl_qql_pvt_w.rosetta_table_copy_in_p23(ddp_qqlv_tbl_type, p6_a0
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
      );

    ddp_cfh_rec_type.type_code := p7_a0;
    ddp_cfh_rec_type.stream_type_id := p7_a1;
    ddp_cfh_rec_type.status_code := p7_a2;
    ddp_cfh_rec_type.arrears_flag := p7_a3;
    ddp_cfh_rec_type.frequency_code := p7_a4;
    ddp_cfh_rec_type.dnz_periods := p7_a5;
    ddp_cfh_rec_type.dnz_periodic_amount := p7_a6;
    ddp_cfh_rec_type.parent_object_code := p7_a7;
    ddp_cfh_rec_type.parent_object_id := p7_a8;
    ddp_cfh_rec_type.quote_type_code := p7_a9;
    ddp_cfh_rec_type.quote_id := p7_a10;
    ddp_cfh_rec_type.cashflow_header_id := p7_a11;
    ddp_cfh_rec_type.cashflow_object_id := p7_a12;
    ddp_cfh_rec_type.cashflow_header_ovn := p7_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_cfl_tbl_type, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      );









    -- here's the delegated call to the old PL/SQL routine
    okl_quick_quotes_pvt.handle_quick_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_rec_type,
      ddp_qqlv_tbl_type,
      ddp_cfh_rec_type,
      ddp_cfl_tbl_type,
      p_commit,
      create_yn,
      ddx_payment_rec,
      ddx_rent_payments_tbl,
      ddx_fee_payments_tbl,
      ddx_item_tbl,
      ddx_qqhv_rec_type,
      ddx_qqlv_tbl_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











    p11_a0 := ddx_payment_rec.subsidy_amount;
    p11_a1 := ddx_payment_rec.financed_amount;
    p11_a2 := ddx_payment_rec.arrears_yn;
    p11_a3 := ddx_payment_rec.frequency_code;
    p11_a4 := ddx_payment_rec.pre_tax_irr;
    p11_a5 := ddx_payment_rec.after_tax_irr;
    p11_a6 := ddx_payment_rec.book_yield;
    p11_a7 := ddx_payment_rec.iir;
    p11_a8 := ddx_payment_rec.sub_pre_tax_irr;
    p11_a9 := ddx_payment_rec.sub_after_tax_irr;
    p11_a10 := ddx_payment_rec.sub_book_yield;
    p11_a11 := ddx_payment_rec.sub_iir;

    okl_quick_quotes_pvt_w.rosetta_table_copy_out_p8(ddx_rent_payments_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      );

    okl_quick_quotes_pvt_w.rosetta_table_copy_out_p10(ddx_fee_payments_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      );

    okl_quick_quotes_pvt_w.rosetta_table_copy_out_p12(ddx_item_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      );

    p15_a0 := ddx_qqhv_rec_type.id;
    p15_a1 := ddx_qqhv_rec_type.object_version_number;
    p15_a2 := ddx_qqhv_rec_type.attribute_category;
    p15_a3 := ddx_qqhv_rec_type.attribute1;
    p15_a4 := ddx_qqhv_rec_type.attribute2;
    p15_a5 := ddx_qqhv_rec_type.attribute3;
    p15_a6 := ddx_qqhv_rec_type.attribute4;
    p15_a7 := ddx_qqhv_rec_type.attribute5;
    p15_a8 := ddx_qqhv_rec_type.attribute6;
    p15_a9 := ddx_qqhv_rec_type.attribute7;
    p15_a10 := ddx_qqhv_rec_type.attribute8;
    p15_a11 := ddx_qqhv_rec_type.attribute9;
    p15_a12 := ddx_qqhv_rec_type.attribute10;
    p15_a13 := ddx_qqhv_rec_type.attribute11;
    p15_a14 := ddx_qqhv_rec_type.attribute12;
    p15_a15 := ddx_qqhv_rec_type.attribute13;
    p15_a16 := ddx_qqhv_rec_type.attribute14;
    p15_a17 := ddx_qqhv_rec_type.attribute15;
    p15_a18 := ddx_qqhv_rec_type.reference_number;
    p15_a19 := ddx_qqhv_rec_type.expected_start_date;
    p15_a20 := ddx_qqhv_rec_type.org_id;
    p15_a21 := ddx_qqhv_rec_type.inv_org_id;
    p15_a22 := ddx_qqhv_rec_type.currency_code;
    p15_a23 := ddx_qqhv_rec_type.term;
    p15_a24 := ddx_qqhv_rec_type.end_of_term_option_id;
    p15_a25 := ddx_qqhv_rec_type.pricing_method;
    p15_a26 := ddx_qqhv_rec_type.lease_opportunity_id;
    p15_a27 := ddx_qqhv_rec_type.originating_vendor_id;
    p15_a28 := ddx_qqhv_rec_type.program_agreement_id;
    p15_a29 := ddx_qqhv_rec_type.sales_rep_id;
    p15_a30 := ddx_qqhv_rec_type.sales_territory_id;
    p15_a31 := ddx_qqhv_rec_type.structured_pricing;
    p15_a32 := ddx_qqhv_rec_type.line_level_pricing;
    p15_a33 := ddx_qqhv_rec_type.rate_template_id;
    p15_a34 := ddx_qqhv_rec_type.rate_card_id;
    p15_a35 := ddx_qqhv_rec_type.lease_rate_factor;
    p15_a36 := ddx_qqhv_rec_type.target_rate_type;
    p15_a37 := ddx_qqhv_rec_type.target_rate;
    p15_a38 := ddx_qqhv_rec_type.target_amount;
    p15_a39 := ddx_qqhv_rec_type.target_frequency;
    p15_a40 := ddx_qqhv_rec_type.target_arrears;
    p15_a41 := ddx_qqhv_rec_type.target_periods;
    p15_a42 := ddx_qqhv_rec_type.iir;
    p15_a43 := ddx_qqhv_rec_type.sub_iir;
    p15_a44 := ddx_qqhv_rec_type.booking_yield;
    p15_a45 := ddx_qqhv_rec_type.sub_booking_yield;
    p15_a46 := ddx_qqhv_rec_type.pirr;
    p15_a47 := ddx_qqhv_rec_type.sub_pirr;
    p15_a48 := ddx_qqhv_rec_type.airr;
    p15_a49 := ddx_qqhv_rec_type.sub_airr;
    p15_a50 := ddx_qqhv_rec_type.short_description;
    p15_a51 := ddx_qqhv_rec_type.description;
    p15_a52 := ddx_qqhv_rec_type.comments;
    p15_a53 := ddx_qqhv_rec_type.sts_code;

    okl_qql_pvt_w.rosetta_table_copy_out_p23(ddx_qqlv_tbl_type, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      , p16_a5
      , p16_a6
      , p16_a7
      , p16_a8
      , p16_a9
      , p16_a10
      , p16_a11
      , p16_a12
      , p16_a13
      , p16_a14
      , p16_a15
      , p16_a16
      , p16_a17
      , p16_a18
      , p16_a19
      , p16_a20
      , p16_a21
      , p16_a22
      , p16_a23
      , p16_a24
      , p16_a25
      , p16_a26
      , p16_a27
      , p16_a28
      , p16_a29
      , p16_a30
      );
  end;

  procedure cancel_quick_quote(p_api_version  NUMBER
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
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
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
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
  )

  as
    ddp_qqhv_rec_type okl_quick_quotes_pvt.qqhv_rec_type;
    ddx_qqhv_rec_type okl_quick_quotes_pvt.qqhv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqhv_rec_type.id := p5_a0;
    ddp_qqhv_rec_type.object_version_number := p5_a1;
    ddp_qqhv_rec_type.attribute_category := p5_a2;
    ddp_qqhv_rec_type.attribute1 := p5_a3;
    ddp_qqhv_rec_type.attribute2 := p5_a4;
    ddp_qqhv_rec_type.attribute3 := p5_a5;
    ddp_qqhv_rec_type.attribute4 := p5_a6;
    ddp_qqhv_rec_type.attribute5 := p5_a7;
    ddp_qqhv_rec_type.attribute6 := p5_a8;
    ddp_qqhv_rec_type.attribute7 := p5_a9;
    ddp_qqhv_rec_type.attribute8 := p5_a10;
    ddp_qqhv_rec_type.attribute9 := p5_a11;
    ddp_qqhv_rec_type.attribute10 := p5_a12;
    ddp_qqhv_rec_type.attribute11 := p5_a13;
    ddp_qqhv_rec_type.attribute12 := p5_a14;
    ddp_qqhv_rec_type.attribute13 := p5_a15;
    ddp_qqhv_rec_type.attribute14 := p5_a16;
    ddp_qqhv_rec_type.attribute15 := p5_a17;
    ddp_qqhv_rec_type.reference_number := p5_a18;
    ddp_qqhv_rec_type.expected_start_date := p5_a19;
    ddp_qqhv_rec_type.org_id := p5_a20;
    ddp_qqhv_rec_type.inv_org_id := p5_a21;
    ddp_qqhv_rec_type.currency_code := p5_a22;
    ddp_qqhv_rec_type.term := p5_a23;
    ddp_qqhv_rec_type.end_of_term_option_id := p5_a24;
    ddp_qqhv_rec_type.pricing_method := p5_a25;
    ddp_qqhv_rec_type.lease_opportunity_id := p5_a26;
    ddp_qqhv_rec_type.originating_vendor_id := p5_a27;
    ddp_qqhv_rec_type.program_agreement_id := p5_a28;
    ddp_qqhv_rec_type.sales_rep_id := p5_a29;
    ddp_qqhv_rec_type.sales_territory_id := p5_a30;
    ddp_qqhv_rec_type.structured_pricing := p5_a31;
    ddp_qqhv_rec_type.line_level_pricing := p5_a32;
    ddp_qqhv_rec_type.rate_template_id := p5_a33;
    ddp_qqhv_rec_type.rate_card_id := p5_a34;
    ddp_qqhv_rec_type.lease_rate_factor := p5_a35;
    ddp_qqhv_rec_type.target_rate_type := p5_a36;
    ddp_qqhv_rec_type.target_rate := p5_a37;
    ddp_qqhv_rec_type.target_amount := p5_a38;
    ddp_qqhv_rec_type.target_frequency := p5_a39;
    ddp_qqhv_rec_type.target_arrears := p5_a40;
    ddp_qqhv_rec_type.target_periods := p5_a41;
    ddp_qqhv_rec_type.iir := p5_a42;
    ddp_qqhv_rec_type.sub_iir := p5_a43;
    ddp_qqhv_rec_type.booking_yield := p5_a44;
    ddp_qqhv_rec_type.sub_booking_yield := p5_a45;
    ddp_qqhv_rec_type.pirr := p5_a46;
    ddp_qqhv_rec_type.sub_pirr := p5_a47;
    ddp_qqhv_rec_type.airr := p5_a48;
    ddp_qqhv_rec_type.sub_airr := p5_a49;
    ddp_qqhv_rec_type.short_description := p5_a50;
    ddp_qqhv_rec_type.description := p5_a51;
    ddp_qqhv_rec_type.comments := p5_a52;
    ddp_qqhv_rec_type.sts_code := p5_a53;


    -- here's the delegated call to the old PL/SQL routine
    okl_quick_quotes_pvt.cancel_quick_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqhv_rec_type,
      ddx_qqhv_rec_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_qqhv_rec_type.id;
    p6_a1 := ddx_qqhv_rec_type.object_version_number;
    p6_a2 := ddx_qqhv_rec_type.attribute_category;
    p6_a3 := ddx_qqhv_rec_type.attribute1;
    p6_a4 := ddx_qqhv_rec_type.attribute2;
    p6_a5 := ddx_qqhv_rec_type.attribute3;
    p6_a6 := ddx_qqhv_rec_type.attribute4;
    p6_a7 := ddx_qqhv_rec_type.attribute5;
    p6_a8 := ddx_qqhv_rec_type.attribute6;
    p6_a9 := ddx_qqhv_rec_type.attribute7;
    p6_a10 := ddx_qqhv_rec_type.attribute8;
    p6_a11 := ddx_qqhv_rec_type.attribute9;
    p6_a12 := ddx_qqhv_rec_type.attribute10;
    p6_a13 := ddx_qqhv_rec_type.attribute11;
    p6_a14 := ddx_qqhv_rec_type.attribute12;
    p6_a15 := ddx_qqhv_rec_type.attribute13;
    p6_a16 := ddx_qqhv_rec_type.attribute14;
    p6_a17 := ddx_qqhv_rec_type.attribute15;
    p6_a18 := ddx_qqhv_rec_type.reference_number;
    p6_a19 := ddx_qqhv_rec_type.expected_start_date;
    p6_a20 := ddx_qqhv_rec_type.org_id;
    p6_a21 := ddx_qqhv_rec_type.inv_org_id;
    p6_a22 := ddx_qqhv_rec_type.currency_code;
    p6_a23 := ddx_qqhv_rec_type.term;
    p6_a24 := ddx_qqhv_rec_type.end_of_term_option_id;
    p6_a25 := ddx_qqhv_rec_type.pricing_method;
    p6_a26 := ddx_qqhv_rec_type.lease_opportunity_id;
    p6_a27 := ddx_qqhv_rec_type.originating_vendor_id;
    p6_a28 := ddx_qqhv_rec_type.program_agreement_id;
    p6_a29 := ddx_qqhv_rec_type.sales_rep_id;
    p6_a30 := ddx_qqhv_rec_type.sales_territory_id;
    p6_a31 := ddx_qqhv_rec_type.structured_pricing;
    p6_a32 := ddx_qqhv_rec_type.line_level_pricing;
    p6_a33 := ddx_qqhv_rec_type.rate_template_id;
    p6_a34 := ddx_qqhv_rec_type.rate_card_id;
    p6_a35 := ddx_qqhv_rec_type.lease_rate_factor;
    p6_a36 := ddx_qqhv_rec_type.target_rate_type;
    p6_a37 := ddx_qqhv_rec_type.target_rate;
    p6_a38 := ddx_qqhv_rec_type.target_amount;
    p6_a39 := ddx_qqhv_rec_type.target_frequency;
    p6_a40 := ddx_qqhv_rec_type.target_arrears;
    p6_a41 := ddx_qqhv_rec_type.target_periods;
    p6_a42 := ddx_qqhv_rec_type.iir;
    p6_a43 := ddx_qqhv_rec_type.sub_iir;
    p6_a44 := ddx_qqhv_rec_type.booking_yield;
    p6_a45 := ddx_qqhv_rec_type.sub_booking_yield;
    p6_a46 := ddx_qqhv_rec_type.pirr;
    p6_a47 := ddx_qqhv_rec_type.sub_pirr;
    p6_a48 := ddx_qqhv_rec_type.airr;
    p6_a49 := ddx_qqhv_rec_type.sub_airr;
    p6_a50 := ddx_qqhv_rec_type.short_description;
    p6_a51 := ddx_qqhv_rec_type.description;
    p6_a52 := ddx_qqhv_rec_type.comments;
    p6_a53 := ddx_qqhv_rec_type.sts_code;
  end;

end okl_quick_quotes_pvt_w;

/
