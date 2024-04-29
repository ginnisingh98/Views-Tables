--------------------------------------------------------
--  DDL for Package Body OKL_PAY_CURE_REFUNDS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_CURE_REFUNDS_PVT_W" as
  /* $Header: OKLEPCRB.pls 115.5 2003/04/25 03:50:22 nmakhani noship $ */
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

  procedure rosetta_table_copy_in_p8(t out nocopy okl_pay_cure_refunds_pvt.pay_cure_refunds_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).refund_number := a0(indx);
          t(ddindx).vendor_site_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).invoice_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).pay_terms := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).payment_method_code := a5(indx);
          t(ddindx).currency := a6(indx);
          t(ddindx).refund_header_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).refund_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).description := a9(indx);
          t(ddindx).received_amount := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).negotiated_amount := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).offset_amount := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).offset_contract := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).refund_amount_due := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).refund_amount := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).refund_type := a16(indx);
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).vendor_site_cure_due := rosetta_g_miss_num_map(a18(indx));
          t(ddindx).vendor_cure_due := rosetta_g_miss_num_map(a19(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okl_pay_cure_refunds_pvt.pay_cure_refunds_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).refund_number;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_site_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a3(indx) := t(ddindx).invoice_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).pay_terms);
          a5(indx) := t(ddindx).payment_method_code;
          a6(indx) := t(ddindx).currency;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).refund_header_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).refund_id);
          a9(indx) := t(ddindx).description;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).received_amount);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).negotiated_amount);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).offset_amount);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).offset_contract);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).refund_amount_due);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).refund_amount);
          a16(indx) := t(ddindx).refund_type;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_site_cure_due);
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_cure_due);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure create_refund_hdr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_cure_refund_header_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_pay_cure_refunds_rec okl_pay_cure_refunds_pvt.pay_cure_refunds_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_pay_cure_refunds_rec.refund_number := p3_a0;
    ddp_pay_cure_refunds_rec.vendor_site_id := rosetta_g_miss_num_map(p3_a1);
    ddp_pay_cure_refunds_rec.chr_id := rosetta_g_miss_num_map(p3_a2);
    ddp_pay_cure_refunds_rec.invoice_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_pay_cure_refunds_rec.pay_terms := rosetta_g_miss_num_map(p3_a4);
    ddp_pay_cure_refunds_rec.payment_method_code := p3_a5;
    ddp_pay_cure_refunds_rec.currency := p3_a6;
    ddp_pay_cure_refunds_rec.refund_header_id := rosetta_g_miss_num_map(p3_a7);
    ddp_pay_cure_refunds_rec.refund_id := rosetta_g_miss_num_map(p3_a8);
    ddp_pay_cure_refunds_rec.description := p3_a9;
    ddp_pay_cure_refunds_rec.received_amount := rosetta_g_miss_num_map(p3_a10);
    ddp_pay_cure_refunds_rec.negotiated_amount := rosetta_g_miss_num_map(p3_a11);
    ddp_pay_cure_refunds_rec.offset_amount := rosetta_g_miss_num_map(p3_a12);
    ddp_pay_cure_refunds_rec.offset_contract := rosetta_g_miss_num_map(p3_a13);
    ddp_pay_cure_refunds_rec.refund_amount_due := rosetta_g_miss_num_map(p3_a14);
    ddp_pay_cure_refunds_rec.refund_amount := rosetta_g_miss_num_map(p3_a15);
    ddp_pay_cure_refunds_rec.refund_type := p3_a16;
    ddp_pay_cure_refunds_rec.vendor_id := rosetta_g_miss_num_map(p3_a17);
    ddp_pay_cure_refunds_rec.vendor_site_cure_due := rosetta_g_miss_num_map(p3_a18);
    ddp_pay_cure_refunds_rec.vendor_cure_due := rosetta_g_miss_num_map(p3_a19);





    -- here's the delegated call to the old PL/SQL routine
    okl_pay_cure_refunds_pvt.create_refund_hdr(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_pay_cure_refunds_rec,
      x_cure_refund_header_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_refund_hdr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_pay_cure_refunds_rec okl_pay_cure_refunds_pvt.pay_cure_refunds_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_pay_cure_refunds_rec.refund_number := p3_a0;
    ddp_pay_cure_refunds_rec.vendor_site_id := rosetta_g_miss_num_map(p3_a1);
    ddp_pay_cure_refunds_rec.chr_id := rosetta_g_miss_num_map(p3_a2);
    ddp_pay_cure_refunds_rec.invoice_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_pay_cure_refunds_rec.pay_terms := rosetta_g_miss_num_map(p3_a4);
    ddp_pay_cure_refunds_rec.payment_method_code := p3_a5;
    ddp_pay_cure_refunds_rec.currency := p3_a6;
    ddp_pay_cure_refunds_rec.refund_header_id := rosetta_g_miss_num_map(p3_a7);
    ddp_pay_cure_refunds_rec.refund_id := rosetta_g_miss_num_map(p3_a8);
    ddp_pay_cure_refunds_rec.description := p3_a9;
    ddp_pay_cure_refunds_rec.received_amount := rosetta_g_miss_num_map(p3_a10);
    ddp_pay_cure_refunds_rec.negotiated_amount := rosetta_g_miss_num_map(p3_a11);
    ddp_pay_cure_refunds_rec.offset_amount := rosetta_g_miss_num_map(p3_a12);
    ddp_pay_cure_refunds_rec.offset_contract := rosetta_g_miss_num_map(p3_a13);
    ddp_pay_cure_refunds_rec.refund_amount_due := rosetta_g_miss_num_map(p3_a14);
    ddp_pay_cure_refunds_rec.refund_amount := rosetta_g_miss_num_map(p3_a15);
    ddp_pay_cure_refunds_rec.refund_type := p3_a16;
    ddp_pay_cure_refunds_rec.vendor_id := rosetta_g_miss_num_map(p3_a17);
    ddp_pay_cure_refunds_rec.vendor_site_cure_due := rosetta_g_miss_num_map(p3_a18);
    ddp_pay_cure_refunds_rec.vendor_cure_due := rosetta_g_miss_num_map(p3_a19);




    -- here's the delegated call to the old PL/SQL routine
    okl_pay_cure_refunds_pvt.update_refund_hdr(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_pay_cure_refunds_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_refund_headers(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_cure_refund_header_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_pay_cure_refunds_rec okl_pay_cure_refunds_pvt.pay_cure_refunds_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_pay_cure_refunds_rec.refund_number := p3_a0;
    ddp_pay_cure_refunds_rec.vendor_site_id := rosetta_g_miss_num_map(p3_a1);
    ddp_pay_cure_refunds_rec.chr_id := rosetta_g_miss_num_map(p3_a2);
    ddp_pay_cure_refunds_rec.invoice_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_pay_cure_refunds_rec.pay_terms := rosetta_g_miss_num_map(p3_a4);
    ddp_pay_cure_refunds_rec.payment_method_code := p3_a5;
    ddp_pay_cure_refunds_rec.currency := p3_a6;
    ddp_pay_cure_refunds_rec.refund_header_id := rosetta_g_miss_num_map(p3_a7);
    ddp_pay_cure_refunds_rec.refund_id := rosetta_g_miss_num_map(p3_a8);
    ddp_pay_cure_refunds_rec.description := p3_a9;
    ddp_pay_cure_refunds_rec.received_amount := rosetta_g_miss_num_map(p3_a10);
    ddp_pay_cure_refunds_rec.negotiated_amount := rosetta_g_miss_num_map(p3_a11);
    ddp_pay_cure_refunds_rec.offset_amount := rosetta_g_miss_num_map(p3_a12);
    ddp_pay_cure_refunds_rec.offset_contract := rosetta_g_miss_num_map(p3_a13);
    ddp_pay_cure_refunds_rec.refund_amount_due := rosetta_g_miss_num_map(p3_a14);
    ddp_pay_cure_refunds_rec.refund_amount := rosetta_g_miss_num_map(p3_a15);
    ddp_pay_cure_refunds_rec.refund_type := p3_a16;
    ddp_pay_cure_refunds_rec.vendor_id := rosetta_g_miss_num_map(p3_a17);
    ddp_pay_cure_refunds_rec.vendor_site_cure_due := rosetta_g_miss_num_map(p3_a18);
    ddp_pay_cure_refunds_rec.vendor_cure_due := rosetta_g_miss_num_map(p3_a19);





    -- here's the delegated call to the old PL/SQL routine
    okl_pay_cure_refunds_pvt.create_refund_headers(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_pay_cure_refunds_rec,
      x_cure_refund_header_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_refund_headers(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  VARCHAR2 := fnd_api.g_miss_char
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  NUMBER := 0-1962.0724
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_pay_cure_refunds_rec okl_pay_cure_refunds_pvt.pay_cure_refunds_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_pay_cure_refunds_rec.refund_number := p3_a0;
    ddp_pay_cure_refunds_rec.vendor_site_id := rosetta_g_miss_num_map(p3_a1);
    ddp_pay_cure_refunds_rec.chr_id := rosetta_g_miss_num_map(p3_a2);
    ddp_pay_cure_refunds_rec.invoice_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_pay_cure_refunds_rec.pay_terms := rosetta_g_miss_num_map(p3_a4);
    ddp_pay_cure_refunds_rec.payment_method_code := p3_a5;
    ddp_pay_cure_refunds_rec.currency := p3_a6;
    ddp_pay_cure_refunds_rec.refund_header_id := rosetta_g_miss_num_map(p3_a7);
    ddp_pay_cure_refunds_rec.refund_id := rosetta_g_miss_num_map(p3_a8);
    ddp_pay_cure_refunds_rec.description := p3_a9;
    ddp_pay_cure_refunds_rec.received_amount := rosetta_g_miss_num_map(p3_a10);
    ddp_pay_cure_refunds_rec.negotiated_amount := rosetta_g_miss_num_map(p3_a11);
    ddp_pay_cure_refunds_rec.offset_amount := rosetta_g_miss_num_map(p3_a12);
    ddp_pay_cure_refunds_rec.offset_contract := rosetta_g_miss_num_map(p3_a13);
    ddp_pay_cure_refunds_rec.refund_amount_due := rosetta_g_miss_num_map(p3_a14);
    ddp_pay_cure_refunds_rec.refund_amount := rosetta_g_miss_num_map(p3_a15);
    ddp_pay_cure_refunds_rec.refund_type := p3_a16;
    ddp_pay_cure_refunds_rec.vendor_id := rosetta_g_miss_num_map(p3_a17);
    ddp_pay_cure_refunds_rec.vendor_site_cure_due := rosetta_g_miss_num_map(p3_a18);
    ddp_pay_cure_refunds_rec.vendor_cure_due := rosetta_g_miss_num_map(p3_a19);




    -- here's the delegated call to the old PL/SQL routine
    okl_pay_cure_refunds_pvt.update_refund_headers(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_pay_cure_refunds_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_refund_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_DATE_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_VARCHAR2_TABLE_100
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_2000
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_NUMBER_TABLE
    , p3_a15 JTF_NUMBER_TABLE
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_NUMBER_TABLE
    , p3_a19 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_pay_cure_refunds_tbl okl_pay_cure_refunds_pvt.pay_cure_refunds_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_pay_cure_refunds_pvt_w.rosetta_table_copy_in_p8(ddp_pay_cure_refunds_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_pay_cure_refunds_pvt.create_refund_details(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_pay_cure_refunds_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure update_refund_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_DATE_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_VARCHAR2_TABLE_100
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_2000
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_NUMBER_TABLE
    , p3_a15 JTF_NUMBER_TABLE
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_NUMBER_TABLE
    , p3_a19 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_pay_cure_refunds_tbl okl_pay_cure_refunds_pvt.pay_cure_refunds_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_pay_cure_refunds_pvt_w.rosetta_table_copy_in_p8(ddp_pay_cure_refunds_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_pay_cure_refunds_pvt.update_refund_details(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_pay_cure_refunds_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure delete_refund_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_DATE_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_VARCHAR2_TABLE_100
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_2000
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , p3_a13 JTF_NUMBER_TABLE
    , p3_a14 JTF_NUMBER_TABLE
    , p3_a15 JTF_NUMBER_TABLE
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_NUMBER_TABLE
    , p3_a19 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_pay_cure_refunds_tbl okl_pay_cure_refunds_pvt.pay_cure_refunds_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_pay_cure_refunds_pvt_w.rosetta_table_copy_in_p8(ddp_pay_cure_refunds_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_pay_cure_refunds_pvt.delete_refund_details(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_pay_cure_refunds_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_pay_cure_refunds_pvt_w;

/
