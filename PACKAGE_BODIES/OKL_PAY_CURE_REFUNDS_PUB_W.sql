--------------------------------------------------------
--  DDL for Package Body OKL_PAY_CURE_REFUNDS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_CURE_REFUNDS_PUB_W" as
  /* $Header: OKLUPCRB.pls 115.5 2003/04/25 03:50:15 nmakhani noship $ */
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
    ddp_pay_cure_refunds_rec okl_pay_cure_refunds_pub.pay_cure_refunds_rec_type;
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
    okl_pay_cure_refunds_pub.create_refund_hdr(p_api_version,
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
    ddp_pay_cure_refunds_rec okl_pay_cure_refunds_pub.pay_cure_refunds_rec_type;
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
    okl_pay_cure_refunds_pub.update_refund_hdr(p_api_version,
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
    ddp_pay_cure_refunds_rec okl_pay_cure_refunds_pub.pay_cure_refunds_rec_type;
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
    okl_pay_cure_refunds_pub.create_refund_headers(p_api_version,
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
    ddp_pay_cure_refunds_rec okl_pay_cure_refunds_pub.pay_cure_refunds_rec_type;
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
    okl_pay_cure_refunds_pub.update_refund_headers(p_api_version,
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
    ddp_pay_cure_refunds_tbl okl_pay_cure_refunds_pub.pay_cure_refunds_tbl_type;
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
    okl_pay_cure_refunds_pub.create_refund_details(p_api_version,
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
    ddp_pay_cure_refunds_tbl okl_pay_cure_refunds_pub.pay_cure_refunds_tbl_type;
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
    okl_pay_cure_refunds_pub.update_refund_details(p_api_version,
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
    ddp_pay_cure_refunds_tbl okl_pay_cure_refunds_pub.pay_cure_refunds_tbl_type;
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
    okl_pay_cure_refunds_pub.delete_refund_details(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_pay_cure_refunds_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_pay_cure_refunds_pub_w;

/
