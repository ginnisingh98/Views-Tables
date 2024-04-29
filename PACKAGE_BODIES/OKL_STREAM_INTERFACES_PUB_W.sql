--------------------------------------------------------
--  DDL for Package Body OKL_STREAM_INTERFACES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAM_INTERFACES_PUB_W" as
  /* $Header: OKLUSIFB.pls 115.7 2002/12/23 06:42:47 smahapat noship $ */
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

  procedure insert_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddx_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.insert_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec,
      ddx_sifv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sifv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sifv_rec.object_version_number);
    p6_a2 := ddx_sifv_rec.fasb_acct_treatment_method;
    p6_a3 := ddx_sifv_rec.date_payments_commencement;
    p6_a4 := ddx_sifv_rec.country;
    p6_a5 := rosetta_g_miss_num_map(ddx_sifv_rec.security_deposit_amount);
    p6_a6 := ddx_sifv_rec.date_delivery;
    p6_a7 := ddx_sifv_rec.irs_tax_treatment_method;
    p6_a8 := ddx_sifv_rec.sif_mode;
    p6_a9 := ddx_sifv_rec.pricing_template_name;
    p6_a10 := ddx_sifv_rec.date_sec_deposit_collected;
    p6_a11 := rosetta_g_miss_num_map(ddx_sifv_rec.transaction_number);
    p6_a12 := rosetta_g_miss_num_map(ddx_sifv_rec.total_funding);
    p6_a13 := ddx_sifv_rec.sis_code;
    p6_a14 := rosetta_g_miss_num_map(ddx_sifv_rec.khr_id);
    p6_a15 := ddx_sifv_rec.adjust;
    p6_a16 := rosetta_g_miss_num_map(ddx_sifv_rec.implicit_interest_rate);
    p6_a17 := ddx_sifv_rec.adjustment_method;
    p6_a18 := ddx_sifv_rec.date_processed;
    p6_a19 := ddx_sifv_rec.orp_code;
    p6_a20 := rosetta_g_miss_num_map(ddx_sifv_rec.lending_rate);
    p6_a21 := ddx_sifv_rec.rvi_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_sifv_rec.rvi_rate);
    p6_a23 := ddx_sifv_rec.stream_interface_attribute01;
    p6_a24 := ddx_sifv_rec.stream_interface_attribute02;
    p6_a25 := ddx_sifv_rec.stream_interface_attribute03;
    p6_a26 := ddx_sifv_rec.stream_interface_attribute04;
    p6_a27 := ddx_sifv_rec.stream_interface_attribute05;
    p6_a28 := ddx_sifv_rec.stream_interface_attribute06;
    p6_a29 := ddx_sifv_rec.stream_interface_attribute07;
    p6_a30 := ddx_sifv_rec.stream_interface_attribute08;
    p6_a31 := ddx_sifv_rec.stream_interface_attribute09;
    p6_a32 := ddx_sifv_rec.stream_interface_attribute10;
    p6_a33 := ddx_sifv_rec.stream_interface_attribute11;
    p6_a34 := ddx_sifv_rec.stream_interface_attribute12;
    p6_a35 := ddx_sifv_rec.stream_interface_attribute13;
    p6_a36 := ddx_sifv_rec.stream_interface_attribute14;
    p6_a37 := ddx_sifv_rec.stream_interface_attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_sifv_rec.created_by);
    p6_a39 := rosetta_g_miss_num_map(ddx_sifv_rec.last_updated_by);
    p6_a40 := ddx_sifv_rec.creation_date;
    p6_a41 := ddx_sifv_rec.last_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_sifv_rec.last_update_login);
    p6_a43 := rosetta_g_miss_num_map(ddx_sifv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_sifv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_sifv_rec.program_id);
    p6_a46 := ddx_sifv_rec.program_update_date;
    p6_a47 := ddx_sifv_rec.jtot_object1_code;
    p6_a48 := ddx_sifv_rec.object1_id1;
    p6_a49 := ddx_sifv_rec.object1_id2;
    p6_a50 := rosetta_g_miss_num_map(ddx_sifv_rec.term);
    p6_a51 := ddx_sifv_rec.structure;
    p6_a52 := ddx_sifv_rec.deal_type;
    p6_a53 := ddx_sifv_rec.log_file;
    p6_a54 := ddx_sifv_rec.first_payment;
    p6_a55 := ddx_sifv_rec.last_payment;
    p6_a56 := rosetta_g_miss_num_map(ddx_sifv_rec.sif_id);
    p6_a57 := ddx_sifv_rec.purpose_code;
  end;

  procedure insert_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddx_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.insert_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl,
      ddx_sifv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sif_pvt_w.rosetta_table_copy_out_p5(ddx_sifv_tbl, p6_a0
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
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      );
  end;

  procedure lock_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.lock_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.lock_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddx_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.update_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec,
      ddx_sifv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sifv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sifv_rec.object_version_number);
    p6_a2 := ddx_sifv_rec.fasb_acct_treatment_method;
    p6_a3 := ddx_sifv_rec.date_payments_commencement;
    p6_a4 := ddx_sifv_rec.country;
    p6_a5 := rosetta_g_miss_num_map(ddx_sifv_rec.security_deposit_amount);
    p6_a6 := ddx_sifv_rec.date_delivery;
    p6_a7 := ddx_sifv_rec.irs_tax_treatment_method;
    p6_a8 := ddx_sifv_rec.sif_mode;
    p6_a9 := ddx_sifv_rec.pricing_template_name;
    p6_a10 := ddx_sifv_rec.date_sec_deposit_collected;
    p6_a11 := rosetta_g_miss_num_map(ddx_sifv_rec.transaction_number);
    p6_a12 := rosetta_g_miss_num_map(ddx_sifv_rec.total_funding);
    p6_a13 := ddx_sifv_rec.sis_code;
    p6_a14 := rosetta_g_miss_num_map(ddx_sifv_rec.khr_id);
    p6_a15 := ddx_sifv_rec.adjust;
    p6_a16 := rosetta_g_miss_num_map(ddx_sifv_rec.implicit_interest_rate);
    p6_a17 := ddx_sifv_rec.adjustment_method;
    p6_a18 := ddx_sifv_rec.date_processed;
    p6_a19 := ddx_sifv_rec.orp_code;
    p6_a20 := rosetta_g_miss_num_map(ddx_sifv_rec.lending_rate);
    p6_a21 := ddx_sifv_rec.rvi_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_sifv_rec.rvi_rate);
    p6_a23 := ddx_sifv_rec.stream_interface_attribute01;
    p6_a24 := ddx_sifv_rec.stream_interface_attribute02;
    p6_a25 := ddx_sifv_rec.stream_interface_attribute03;
    p6_a26 := ddx_sifv_rec.stream_interface_attribute04;
    p6_a27 := ddx_sifv_rec.stream_interface_attribute05;
    p6_a28 := ddx_sifv_rec.stream_interface_attribute06;
    p6_a29 := ddx_sifv_rec.stream_interface_attribute07;
    p6_a30 := ddx_sifv_rec.stream_interface_attribute08;
    p6_a31 := ddx_sifv_rec.stream_interface_attribute09;
    p6_a32 := ddx_sifv_rec.stream_interface_attribute10;
    p6_a33 := ddx_sifv_rec.stream_interface_attribute11;
    p6_a34 := ddx_sifv_rec.stream_interface_attribute12;
    p6_a35 := ddx_sifv_rec.stream_interface_attribute13;
    p6_a36 := ddx_sifv_rec.stream_interface_attribute14;
    p6_a37 := ddx_sifv_rec.stream_interface_attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_sifv_rec.created_by);
    p6_a39 := rosetta_g_miss_num_map(ddx_sifv_rec.last_updated_by);
    p6_a40 := ddx_sifv_rec.creation_date;
    p6_a41 := ddx_sifv_rec.last_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_sifv_rec.last_update_login);
    p6_a43 := rosetta_g_miss_num_map(ddx_sifv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_sifv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_sifv_rec.program_id);
    p6_a46 := ddx_sifv_rec.program_update_date;
    p6_a47 := ddx_sifv_rec.jtot_object1_code;
    p6_a48 := ddx_sifv_rec.object1_id1;
    p6_a49 := ddx_sifv_rec.object1_id2;
    p6_a50 := rosetta_g_miss_num_map(ddx_sifv_rec.term);
    p6_a51 := ddx_sifv_rec.structure;
    p6_a52 := ddx_sifv_rec.deal_type;
    p6_a53 := ddx_sifv_rec.log_file;
    p6_a54 := ddx_sifv_rec.first_payment;
    p6_a55 := ddx_sifv_rec.last_payment;
    p6_a56 := rosetta_g_miss_num_map(ddx_sifv_rec.sif_id);
    p6_a57 := ddx_sifv_rec.purpose_code;
  end;

  procedure update_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddx_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.update_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl,
      ddx_sifv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sif_pvt_w.rosetta_table_copy_out_p5(ddx_sifv_tbl, p6_a0
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
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      );
  end;

  procedure delete_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddx_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.delete_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec,
      ddx_sifv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sifv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sifv_rec.object_version_number);
    p6_a2 := ddx_sifv_rec.fasb_acct_treatment_method;
    p6_a3 := ddx_sifv_rec.date_payments_commencement;
    p6_a4 := ddx_sifv_rec.country;
    p6_a5 := rosetta_g_miss_num_map(ddx_sifv_rec.security_deposit_amount);
    p6_a6 := ddx_sifv_rec.date_delivery;
    p6_a7 := ddx_sifv_rec.irs_tax_treatment_method;
    p6_a8 := ddx_sifv_rec.sif_mode;
    p6_a9 := ddx_sifv_rec.pricing_template_name;
    p6_a10 := ddx_sifv_rec.date_sec_deposit_collected;
    p6_a11 := rosetta_g_miss_num_map(ddx_sifv_rec.transaction_number);
    p6_a12 := rosetta_g_miss_num_map(ddx_sifv_rec.total_funding);
    p6_a13 := ddx_sifv_rec.sis_code;
    p6_a14 := rosetta_g_miss_num_map(ddx_sifv_rec.khr_id);
    p6_a15 := ddx_sifv_rec.adjust;
    p6_a16 := rosetta_g_miss_num_map(ddx_sifv_rec.implicit_interest_rate);
    p6_a17 := ddx_sifv_rec.adjustment_method;
    p6_a18 := ddx_sifv_rec.date_processed;
    p6_a19 := ddx_sifv_rec.orp_code;
    p6_a20 := rosetta_g_miss_num_map(ddx_sifv_rec.lending_rate);
    p6_a21 := ddx_sifv_rec.rvi_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_sifv_rec.rvi_rate);
    p6_a23 := ddx_sifv_rec.stream_interface_attribute01;
    p6_a24 := ddx_sifv_rec.stream_interface_attribute02;
    p6_a25 := ddx_sifv_rec.stream_interface_attribute03;
    p6_a26 := ddx_sifv_rec.stream_interface_attribute04;
    p6_a27 := ddx_sifv_rec.stream_interface_attribute05;
    p6_a28 := ddx_sifv_rec.stream_interface_attribute06;
    p6_a29 := ddx_sifv_rec.stream_interface_attribute07;
    p6_a30 := ddx_sifv_rec.stream_interface_attribute08;
    p6_a31 := ddx_sifv_rec.stream_interface_attribute09;
    p6_a32 := ddx_sifv_rec.stream_interface_attribute10;
    p6_a33 := ddx_sifv_rec.stream_interface_attribute11;
    p6_a34 := ddx_sifv_rec.stream_interface_attribute12;
    p6_a35 := ddx_sifv_rec.stream_interface_attribute13;
    p6_a36 := ddx_sifv_rec.stream_interface_attribute14;
    p6_a37 := ddx_sifv_rec.stream_interface_attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_sifv_rec.created_by);
    p6_a39 := rosetta_g_miss_num_map(ddx_sifv_rec.last_updated_by);
    p6_a40 := ddx_sifv_rec.creation_date;
    p6_a41 := ddx_sifv_rec.last_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_sifv_rec.last_update_login);
    p6_a43 := rosetta_g_miss_num_map(ddx_sifv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_sifv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_sifv_rec.program_id);
    p6_a46 := ddx_sifv_rec.program_update_date;
    p6_a47 := ddx_sifv_rec.jtot_object1_code;
    p6_a48 := ddx_sifv_rec.object1_id1;
    p6_a49 := ddx_sifv_rec.object1_id2;
    p6_a50 := rosetta_g_miss_num_map(ddx_sifv_rec.term);
    p6_a51 := ddx_sifv_rec.structure;
    p6_a52 := ddx_sifv_rec.deal_type;
    p6_a53 := ddx_sifv_rec.log_file;
    p6_a54 := ddx_sifv_rec.first_payment;
    p6_a55 := ddx_sifv_rec.last_payment;
    p6_a56 := rosetta_g_miss_num_map(ddx_sifv_rec.sif_id);
    p6_a57 := ddx_sifv_rec.purpose_code;
  end;

  procedure delete_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddx_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.delete_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl,
      ddx_sifv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sif_pvt_w.rosetta_table_copy_out_p5(ddx_sifv_tbl, p6_a0
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
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      );
  end;

  procedure validate_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  NUMBER
    , p6_a40 out nocopy  DATE
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  NUMBER
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  NUMBER := 0-1962.0724
    , p5_a40  DATE := fnd_api.g_miss_date
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  NUMBER := 0-1962.0724
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddx_sifv_rec okl_stream_interfaces_pub.sifv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sifv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sifv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_sifv_rec.fasb_acct_treatment_method := p5_a2;
    ddp_sifv_rec.date_payments_commencement := rosetta_g_miss_date_in_map(p5_a3);
    ddp_sifv_rec.country := p5_a4;
    ddp_sifv_rec.security_deposit_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_sifv_rec.date_delivery := rosetta_g_miss_date_in_map(p5_a6);
    ddp_sifv_rec.irs_tax_treatment_method := p5_a7;
    ddp_sifv_rec.sif_mode := p5_a8;
    ddp_sifv_rec.pricing_template_name := p5_a9;
    ddp_sifv_rec.date_sec_deposit_collected := rosetta_g_miss_date_in_map(p5_a10);
    ddp_sifv_rec.transaction_number := rosetta_g_miss_num_map(p5_a11);
    ddp_sifv_rec.total_funding := rosetta_g_miss_num_map(p5_a12);
    ddp_sifv_rec.sis_code := p5_a13;
    ddp_sifv_rec.khr_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sifv_rec.adjust := p5_a15;
    ddp_sifv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p5_a16);
    ddp_sifv_rec.adjustment_method := p5_a17;
    ddp_sifv_rec.date_processed := rosetta_g_miss_date_in_map(p5_a18);
    ddp_sifv_rec.orp_code := p5_a19;
    ddp_sifv_rec.lending_rate := rosetta_g_miss_num_map(p5_a20);
    ddp_sifv_rec.rvi_yn := p5_a21;
    ddp_sifv_rec.rvi_rate := rosetta_g_miss_num_map(p5_a22);
    ddp_sifv_rec.stream_interface_attribute01 := p5_a23;
    ddp_sifv_rec.stream_interface_attribute02 := p5_a24;
    ddp_sifv_rec.stream_interface_attribute03 := p5_a25;
    ddp_sifv_rec.stream_interface_attribute04 := p5_a26;
    ddp_sifv_rec.stream_interface_attribute05 := p5_a27;
    ddp_sifv_rec.stream_interface_attribute06 := p5_a28;
    ddp_sifv_rec.stream_interface_attribute07 := p5_a29;
    ddp_sifv_rec.stream_interface_attribute08 := p5_a30;
    ddp_sifv_rec.stream_interface_attribute09 := p5_a31;
    ddp_sifv_rec.stream_interface_attribute10 := p5_a32;
    ddp_sifv_rec.stream_interface_attribute11 := p5_a33;
    ddp_sifv_rec.stream_interface_attribute12 := p5_a34;
    ddp_sifv_rec.stream_interface_attribute13 := p5_a35;
    ddp_sifv_rec.stream_interface_attribute14 := p5_a36;
    ddp_sifv_rec.stream_interface_attribute15 := p5_a37;
    ddp_sifv_rec.created_by := rosetta_g_miss_num_map(p5_a38);
    ddp_sifv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a39);
    ddp_sifv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a40);
    ddp_sifv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_sifv_rec.last_update_login := rosetta_g_miss_num_map(p5_a42);
    ddp_sifv_rec.request_id := rosetta_g_miss_num_map(p5_a43);
    ddp_sifv_rec.program_application_id := rosetta_g_miss_num_map(p5_a44);
    ddp_sifv_rec.program_id := rosetta_g_miss_num_map(p5_a45);
    ddp_sifv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_sifv_rec.jtot_object1_code := p5_a47;
    ddp_sifv_rec.object1_id1 := p5_a48;
    ddp_sifv_rec.object1_id2 := p5_a49;
    ddp_sifv_rec.term := rosetta_g_miss_num_map(p5_a50);
    ddp_sifv_rec.structure := p5_a51;
    ddp_sifv_rec.deal_type := p5_a52;
    ddp_sifv_rec.log_file := p5_a53;
    ddp_sifv_rec.first_payment := p5_a54;
    ddp_sifv_rec.last_payment := p5_a55;
    ddp_sifv_rec.sif_id := rosetta_g_miss_num_map(p5_a56);
    ddp_sifv_rec.purpose_code := p5_a57;


    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.validate_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_rec,
      ddx_sifv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sifv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_sifv_rec.object_version_number);
    p6_a2 := ddx_sifv_rec.fasb_acct_treatment_method;
    p6_a3 := ddx_sifv_rec.date_payments_commencement;
    p6_a4 := ddx_sifv_rec.country;
    p6_a5 := rosetta_g_miss_num_map(ddx_sifv_rec.security_deposit_amount);
    p6_a6 := ddx_sifv_rec.date_delivery;
    p6_a7 := ddx_sifv_rec.irs_tax_treatment_method;
    p6_a8 := ddx_sifv_rec.sif_mode;
    p6_a9 := ddx_sifv_rec.pricing_template_name;
    p6_a10 := ddx_sifv_rec.date_sec_deposit_collected;
    p6_a11 := rosetta_g_miss_num_map(ddx_sifv_rec.transaction_number);
    p6_a12 := rosetta_g_miss_num_map(ddx_sifv_rec.total_funding);
    p6_a13 := ddx_sifv_rec.sis_code;
    p6_a14 := rosetta_g_miss_num_map(ddx_sifv_rec.khr_id);
    p6_a15 := ddx_sifv_rec.adjust;
    p6_a16 := rosetta_g_miss_num_map(ddx_sifv_rec.implicit_interest_rate);
    p6_a17 := ddx_sifv_rec.adjustment_method;
    p6_a18 := ddx_sifv_rec.date_processed;
    p6_a19 := ddx_sifv_rec.orp_code;
    p6_a20 := rosetta_g_miss_num_map(ddx_sifv_rec.lending_rate);
    p6_a21 := ddx_sifv_rec.rvi_yn;
    p6_a22 := rosetta_g_miss_num_map(ddx_sifv_rec.rvi_rate);
    p6_a23 := ddx_sifv_rec.stream_interface_attribute01;
    p6_a24 := ddx_sifv_rec.stream_interface_attribute02;
    p6_a25 := ddx_sifv_rec.stream_interface_attribute03;
    p6_a26 := ddx_sifv_rec.stream_interface_attribute04;
    p6_a27 := ddx_sifv_rec.stream_interface_attribute05;
    p6_a28 := ddx_sifv_rec.stream_interface_attribute06;
    p6_a29 := ddx_sifv_rec.stream_interface_attribute07;
    p6_a30 := ddx_sifv_rec.stream_interface_attribute08;
    p6_a31 := ddx_sifv_rec.stream_interface_attribute09;
    p6_a32 := ddx_sifv_rec.stream_interface_attribute10;
    p6_a33 := ddx_sifv_rec.stream_interface_attribute11;
    p6_a34 := ddx_sifv_rec.stream_interface_attribute12;
    p6_a35 := ddx_sifv_rec.stream_interface_attribute13;
    p6_a36 := ddx_sifv_rec.stream_interface_attribute14;
    p6_a37 := ddx_sifv_rec.stream_interface_attribute15;
    p6_a38 := rosetta_g_miss_num_map(ddx_sifv_rec.created_by);
    p6_a39 := rosetta_g_miss_num_map(ddx_sifv_rec.last_updated_by);
    p6_a40 := ddx_sifv_rec.creation_date;
    p6_a41 := ddx_sifv_rec.last_update_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_sifv_rec.last_update_login);
    p6_a43 := rosetta_g_miss_num_map(ddx_sifv_rec.request_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_sifv_rec.program_application_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_sifv_rec.program_id);
    p6_a46 := ddx_sifv_rec.program_update_date;
    p6_a47 := ddx_sifv_rec.jtot_object1_code;
    p6_a48 := ddx_sifv_rec.object1_id1;
    p6_a49 := ddx_sifv_rec.object1_id2;
    p6_a50 := rosetta_g_miss_num_map(ddx_sifv_rec.term);
    p6_a51 := ddx_sifv_rec.structure;
    p6_a52 := ddx_sifv_rec.deal_type;
    p6_a53 := ddx_sifv_rec.log_file;
    p6_a54 := ddx_sifv_rec.first_payment;
    p6_a55 := ddx_sifv_rec.last_payment;
    p6_a56 := rosetta_g_miss_num_map(ddx_sifv_rec.sif_id);
    p6_a57 := ddx_sifv_rec.purpose_code;
  end;

  procedure validate_stream_interfaces(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_200
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_VARCHAR2_TABLE_500
    , p5_a31 JTF_VARCHAR2_TABLE_500
    , p5_a32 JTF_VARCHAR2_TABLE_500
    , p5_a33 JTF_VARCHAR2_TABLE_500
    , p5_a34 JTF_VARCHAR2_TABLE_500
    , p5_a35 JTF_VARCHAR2_TABLE_500
    , p5_a36 JTF_VARCHAR2_TABLE_500
    , p5_a37 JTF_VARCHAR2_TABLE_500
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p5_a40 JTF_DATE_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_DATE_TABLE
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_400
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_DATE_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_DATE_TABLE
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddx_sifv_tbl okl_stream_interfaces_pub.sifv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sif_pvt_w.rosetta_table_copy_in_p5(ddp_sifv_tbl, p5_a0
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
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_stream_interfaces_pub.validate_stream_interfaces(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sifv_tbl,
      ddx_sifv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sif_pvt_w.rosetta_table_copy_out_p5(ddx_sifv_tbl, p6_a0
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
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      );
  end;

end okl_stream_interfaces_pub_w;

/
