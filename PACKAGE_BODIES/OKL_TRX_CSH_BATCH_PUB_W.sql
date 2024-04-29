--------------------------------------------------------
--  DDL for Package Body OKL_TRX_CSH_BATCH_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRX_CSH_BATCH_PUB_W" as
  /* $Header: OKLUBTCB.pls 120.6 2007/09/28 06:49:55 varangan ship $ */
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

  procedure insert_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_btcv_tbl okl_trx_csh_batch_pub.btcv_tbl_type;
    ddx_btcv_tbl okl_trx_csh_batch_pub.btcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_btc_pvt_w.rosetta_table_copy_in_p8(ddp_btcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.insert_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_tbl,
      ddx_btcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_btc_pvt_w.rosetta_table_copy_out_p8(ddx_btcv_tbl, p6_a0
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
      );
  end;

  procedure insert_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  )

  as
    ddp_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddx_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_btcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_btcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_btcv_rec.sfwt_flag := p5_a2;
    ddp_btcv_rec.name := p5_a3;
    ddp_btcv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a4);
    ddp_btcv_rec.date_gl_requested := rosetta_g_miss_date_in_map(p5_a5);
    ddp_btcv_rec.date_deposit := rosetta_g_miss_date_in_map(p5_a6);
    ddp_btcv_rec.batch_qty := rosetta_g_miss_num_map(p5_a7);
    ddp_btcv_rec.batch_total := rosetta_g_miss_num_map(p5_a8);
    ddp_btcv_rec.batch_currency := p5_a9;
    ddp_btcv_rec.irm_id := rosetta_g_miss_num_map(p5_a10);
    ddp_btcv_rec.description := p5_a11;
    ddp_btcv_rec.attribute_category := p5_a12;
    ddp_btcv_rec.attribute1 := p5_a13;
    ddp_btcv_rec.attribute2 := p5_a14;
    ddp_btcv_rec.attribute3 := p5_a15;
    ddp_btcv_rec.attribute4 := p5_a16;
    ddp_btcv_rec.attribute5 := p5_a17;
    ddp_btcv_rec.attribute6 := p5_a18;
    ddp_btcv_rec.attribute7 := p5_a19;
    ddp_btcv_rec.attribute8 := p5_a20;
    ddp_btcv_rec.attribute9 := p5_a21;
    ddp_btcv_rec.attribute10 := p5_a22;
    ddp_btcv_rec.attribute11 := p5_a23;
    ddp_btcv_rec.attribute12 := p5_a24;
    ddp_btcv_rec.attribute13 := p5_a25;
    ddp_btcv_rec.attribute14 := p5_a26;
    ddp_btcv_rec.attribute15 := p5_a27;
    ddp_btcv_rec.request_id := rosetta_g_miss_num_map(p5_a28);
    ddp_btcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a29);
    ddp_btcv_rec.program_id := rosetta_g_miss_num_map(p5_a30);
    ddp_btcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_btcv_rec.org_id := rosetta_g_miss_num_map(p5_a32);
    ddp_btcv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_btcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_btcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_btcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_btcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_btcv_rec.trx_status_code := p5_a38;
    ddp_btcv_rec.currency_conversion_type := p5_a39;
    ddp_btcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a40);
    ddp_btcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_btcv_rec.remit_bank_id := rosetta_g_miss_num_map(p5_a42);


    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.insert_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_rec,
      ddx_btcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_btcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_btcv_rec.object_version_number);
    p6_a2 := ddx_btcv_rec.sfwt_flag;
    p6_a3 := ddx_btcv_rec.name;
    p6_a4 := ddx_btcv_rec.date_entered;
    p6_a5 := ddx_btcv_rec.date_gl_requested;
    p6_a6 := ddx_btcv_rec.date_deposit;
    p6_a7 := rosetta_g_miss_num_map(ddx_btcv_rec.batch_qty);
    p6_a8 := rosetta_g_miss_num_map(ddx_btcv_rec.batch_total);
    p6_a9 := ddx_btcv_rec.batch_currency;
    p6_a10 := rosetta_g_miss_num_map(ddx_btcv_rec.irm_id);
    p6_a11 := ddx_btcv_rec.description;
    p6_a12 := ddx_btcv_rec.attribute_category;
    p6_a13 := ddx_btcv_rec.attribute1;
    p6_a14 := ddx_btcv_rec.attribute2;
    p6_a15 := ddx_btcv_rec.attribute3;
    p6_a16 := ddx_btcv_rec.attribute4;
    p6_a17 := ddx_btcv_rec.attribute5;
    p6_a18 := ddx_btcv_rec.attribute6;
    p6_a19 := ddx_btcv_rec.attribute7;
    p6_a20 := ddx_btcv_rec.attribute8;
    p6_a21 := ddx_btcv_rec.attribute9;
    p6_a22 := ddx_btcv_rec.attribute10;
    p6_a23 := ddx_btcv_rec.attribute11;
    p6_a24 := ddx_btcv_rec.attribute12;
    p6_a25 := ddx_btcv_rec.attribute13;
    p6_a26 := ddx_btcv_rec.attribute14;
    p6_a27 := ddx_btcv_rec.attribute15;
    p6_a28 := rosetta_g_miss_num_map(ddx_btcv_rec.request_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_btcv_rec.program_application_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_btcv_rec.program_id);
    p6_a31 := ddx_btcv_rec.program_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_btcv_rec.org_id);
    p6_a33 := rosetta_g_miss_num_map(ddx_btcv_rec.created_by);
    p6_a34 := ddx_btcv_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_btcv_rec.last_updated_by);
    p6_a36 := ddx_btcv_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_btcv_rec.last_update_login);
    p6_a38 := ddx_btcv_rec.trx_status_code;
    p6_a39 := ddx_btcv_rec.currency_conversion_type;
    p6_a40 := rosetta_g_miss_num_map(ddx_btcv_rec.currency_conversion_rate);
    p6_a41 := ddx_btcv_rec.currency_conversion_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_btcv_rec.remit_bank_id);
  end;

  procedure lock_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
  )

  as
    ddp_btcv_tbl okl_trx_csh_batch_pub.btcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_btc_pvt_w.rosetta_table_copy_in_p8(ddp_btcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.lock_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  )

  as
    ddp_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_btcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_btcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_btcv_rec.sfwt_flag := p5_a2;
    ddp_btcv_rec.name := p5_a3;
    ddp_btcv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a4);
    ddp_btcv_rec.date_gl_requested := rosetta_g_miss_date_in_map(p5_a5);
    ddp_btcv_rec.date_deposit := rosetta_g_miss_date_in_map(p5_a6);
    ddp_btcv_rec.batch_qty := rosetta_g_miss_num_map(p5_a7);
    ddp_btcv_rec.batch_total := rosetta_g_miss_num_map(p5_a8);
    ddp_btcv_rec.batch_currency := p5_a9;
    ddp_btcv_rec.irm_id := rosetta_g_miss_num_map(p5_a10);
    ddp_btcv_rec.description := p5_a11;
    ddp_btcv_rec.attribute_category := p5_a12;
    ddp_btcv_rec.attribute1 := p5_a13;
    ddp_btcv_rec.attribute2 := p5_a14;
    ddp_btcv_rec.attribute3 := p5_a15;
    ddp_btcv_rec.attribute4 := p5_a16;
    ddp_btcv_rec.attribute5 := p5_a17;
    ddp_btcv_rec.attribute6 := p5_a18;
    ddp_btcv_rec.attribute7 := p5_a19;
    ddp_btcv_rec.attribute8 := p5_a20;
    ddp_btcv_rec.attribute9 := p5_a21;
    ddp_btcv_rec.attribute10 := p5_a22;
    ddp_btcv_rec.attribute11 := p5_a23;
    ddp_btcv_rec.attribute12 := p5_a24;
    ddp_btcv_rec.attribute13 := p5_a25;
    ddp_btcv_rec.attribute14 := p5_a26;
    ddp_btcv_rec.attribute15 := p5_a27;
    ddp_btcv_rec.request_id := rosetta_g_miss_num_map(p5_a28);
    ddp_btcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a29);
    ddp_btcv_rec.program_id := rosetta_g_miss_num_map(p5_a30);
    ddp_btcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_btcv_rec.org_id := rosetta_g_miss_num_map(p5_a32);
    ddp_btcv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_btcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_btcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_btcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_btcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_btcv_rec.trx_status_code := p5_a38;
    ddp_btcv_rec.currency_conversion_type := p5_a39;
    ddp_btcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a40);
    ddp_btcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_btcv_rec.remit_bank_id := rosetta_g_miss_num_map(p5_a42);

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.lock_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_DATE_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_btcv_tbl okl_trx_csh_batch_pub.btcv_tbl_type;
    ddx_btcv_tbl okl_trx_csh_batch_pub.btcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_btc_pvt_w.rosetta_table_copy_in_p8(ddp_btcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.update_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_tbl,
      ddx_btcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_btc_pvt_w.rosetta_table_copy_out_p8(ddx_btcv_tbl, p6_a0
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
      );
  end;

  procedure update_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  )

  as
    ddp_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddx_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_btcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_btcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_btcv_rec.sfwt_flag := p5_a2;
    ddp_btcv_rec.name := p5_a3;
    ddp_btcv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a4);
    ddp_btcv_rec.date_gl_requested := rosetta_g_miss_date_in_map(p5_a5);
    ddp_btcv_rec.date_deposit := rosetta_g_miss_date_in_map(p5_a6);
    ddp_btcv_rec.batch_qty := rosetta_g_miss_num_map(p5_a7);
    ddp_btcv_rec.batch_total := rosetta_g_miss_num_map(p5_a8);
    ddp_btcv_rec.batch_currency := p5_a9;
    ddp_btcv_rec.irm_id := rosetta_g_miss_num_map(p5_a10);
    ddp_btcv_rec.description := p5_a11;
    ddp_btcv_rec.attribute_category := p5_a12;
    ddp_btcv_rec.attribute1 := p5_a13;
    ddp_btcv_rec.attribute2 := p5_a14;
    ddp_btcv_rec.attribute3 := p5_a15;
    ddp_btcv_rec.attribute4 := p5_a16;
    ddp_btcv_rec.attribute5 := p5_a17;
    ddp_btcv_rec.attribute6 := p5_a18;
    ddp_btcv_rec.attribute7 := p5_a19;
    ddp_btcv_rec.attribute8 := p5_a20;
    ddp_btcv_rec.attribute9 := p5_a21;
    ddp_btcv_rec.attribute10 := p5_a22;
    ddp_btcv_rec.attribute11 := p5_a23;
    ddp_btcv_rec.attribute12 := p5_a24;
    ddp_btcv_rec.attribute13 := p5_a25;
    ddp_btcv_rec.attribute14 := p5_a26;
    ddp_btcv_rec.attribute15 := p5_a27;
    ddp_btcv_rec.request_id := rosetta_g_miss_num_map(p5_a28);
    ddp_btcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a29);
    ddp_btcv_rec.program_id := rosetta_g_miss_num_map(p5_a30);
    ddp_btcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_btcv_rec.org_id := rosetta_g_miss_num_map(p5_a32);
    ddp_btcv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_btcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_btcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_btcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_btcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_btcv_rec.trx_status_code := p5_a38;
    ddp_btcv_rec.currency_conversion_type := p5_a39;
    ddp_btcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a40);
    ddp_btcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_btcv_rec.remit_bank_id := rosetta_g_miss_num_map(p5_a42);


    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.update_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_rec,
      ddx_btcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_btcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_btcv_rec.object_version_number);
    p6_a2 := ddx_btcv_rec.sfwt_flag;
    p6_a3 := ddx_btcv_rec.name;
    p6_a4 := ddx_btcv_rec.date_entered;
    p6_a5 := ddx_btcv_rec.date_gl_requested;
    p6_a6 := ddx_btcv_rec.date_deposit;
    p6_a7 := rosetta_g_miss_num_map(ddx_btcv_rec.batch_qty);
    p6_a8 := rosetta_g_miss_num_map(ddx_btcv_rec.batch_total);
    p6_a9 := ddx_btcv_rec.batch_currency;
    p6_a10 := rosetta_g_miss_num_map(ddx_btcv_rec.irm_id);
    p6_a11 := ddx_btcv_rec.description;
    p6_a12 := ddx_btcv_rec.attribute_category;
    p6_a13 := ddx_btcv_rec.attribute1;
    p6_a14 := ddx_btcv_rec.attribute2;
    p6_a15 := ddx_btcv_rec.attribute3;
    p6_a16 := ddx_btcv_rec.attribute4;
    p6_a17 := ddx_btcv_rec.attribute5;
    p6_a18 := ddx_btcv_rec.attribute6;
    p6_a19 := ddx_btcv_rec.attribute7;
    p6_a20 := ddx_btcv_rec.attribute8;
    p6_a21 := ddx_btcv_rec.attribute9;
    p6_a22 := ddx_btcv_rec.attribute10;
    p6_a23 := ddx_btcv_rec.attribute11;
    p6_a24 := ddx_btcv_rec.attribute12;
    p6_a25 := ddx_btcv_rec.attribute13;
    p6_a26 := ddx_btcv_rec.attribute14;
    p6_a27 := ddx_btcv_rec.attribute15;
    p6_a28 := rosetta_g_miss_num_map(ddx_btcv_rec.request_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_btcv_rec.program_application_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_btcv_rec.program_id);
    p6_a31 := ddx_btcv_rec.program_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_btcv_rec.org_id);
    p6_a33 := rosetta_g_miss_num_map(ddx_btcv_rec.created_by);
    p6_a34 := ddx_btcv_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_btcv_rec.last_updated_by);
    p6_a36 := ddx_btcv_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_btcv_rec.last_update_login);
    p6_a38 := ddx_btcv_rec.trx_status_code;
    p6_a39 := ddx_btcv_rec.currency_conversion_type;
    p6_a40 := rosetta_g_miss_num_map(ddx_btcv_rec.currency_conversion_rate);
    p6_a41 := ddx_btcv_rec.currency_conversion_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_btcv_rec.remit_bank_id);
  end;

  procedure delete_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
  )

  as
    ddp_btcv_tbl okl_trx_csh_batch_pub.btcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_btc_pvt_w.rosetta_table_copy_in_p8(ddp_btcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.delete_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  )

  as
    ddp_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_btcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_btcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_btcv_rec.sfwt_flag := p5_a2;
    ddp_btcv_rec.name := p5_a3;
    ddp_btcv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a4);
    ddp_btcv_rec.date_gl_requested := rosetta_g_miss_date_in_map(p5_a5);
    ddp_btcv_rec.date_deposit := rosetta_g_miss_date_in_map(p5_a6);
    ddp_btcv_rec.batch_qty := rosetta_g_miss_num_map(p5_a7);
    ddp_btcv_rec.batch_total := rosetta_g_miss_num_map(p5_a8);
    ddp_btcv_rec.batch_currency := p5_a9;
    ddp_btcv_rec.irm_id := rosetta_g_miss_num_map(p5_a10);
    ddp_btcv_rec.description := p5_a11;
    ddp_btcv_rec.attribute_category := p5_a12;
    ddp_btcv_rec.attribute1 := p5_a13;
    ddp_btcv_rec.attribute2 := p5_a14;
    ddp_btcv_rec.attribute3 := p5_a15;
    ddp_btcv_rec.attribute4 := p5_a16;
    ddp_btcv_rec.attribute5 := p5_a17;
    ddp_btcv_rec.attribute6 := p5_a18;
    ddp_btcv_rec.attribute7 := p5_a19;
    ddp_btcv_rec.attribute8 := p5_a20;
    ddp_btcv_rec.attribute9 := p5_a21;
    ddp_btcv_rec.attribute10 := p5_a22;
    ddp_btcv_rec.attribute11 := p5_a23;
    ddp_btcv_rec.attribute12 := p5_a24;
    ddp_btcv_rec.attribute13 := p5_a25;
    ddp_btcv_rec.attribute14 := p5_a26;
    ddp_btcv_rec.attribute15 := p5_a27;
    ddp_btcv_rec.request_id := rosetta_g_miss_num_map(p5_a28);
    ddp_btcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a29);
    ddp_btcv_rec.program_id := rosetta_g_miss_num_map(p5_a30);
    ddp_btcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_btcv_rec.org_id := rosetta_g_miss_num_map(p5_a32);
    ddp_btcv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_btcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_btcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_btcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_btcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_btcv_rec.trx_status_code := p5_a38;
    ddp_btcv_rec.currency_conversion_type := p5_a39;
    ddp_btcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a40);
    ddp_btcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_btcv_rec.remit_bank_id := rosetta_g_miss_num_map(p5_a42);

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.delete_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_2000
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_VARCHAR2_TABLE_500
    , p5_a19 JTF_VARCHAR2_TABLE_500
    , p5_a20 JTF_VARCHAR2_TABLE_500
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
    , p5_a23 JTF_VARCHAR2_TABLE_500
    , p5_a24 JTF_VARCHAR2_TABLE_500
    , p5_a25 JTF_VARCHAR2_TABLE_500
    , p5_a26 JTF_VARCHAR2_TABLE_500
    , p5_a27 JTF_VARCHAR2_TABLE_500
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_DATE_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
  )

  as
    ddp_btcv_tbl okl_trx_csh_batch_pub.btcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_btc_pvt_w.rosetta_table_copy_in_p8(ddp_btcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.validate_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_trx_csh_batch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  )

  as
    ddp_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_btcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_btcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_btcv_rec.sfwt_flag := p5_a2;
    ddp_btcv_rec.name := p5_a3;
    ddp_btcv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a4);
    ddp_btcv_rec.date_gl_requested := rosetta_g_miss_date_in_map(p5_a5);
    ddp_btcv_rec.date_deposit := rosetta_g_miss_date_in_map(p5_a6);
    ddp_btcv_rec.batch_qty := rosetta_g_miss_num_map(p5_a7);
    ddp_btcv_rec.batch_total := rosetta_g_miss_num_map(p5_a8);
    ddp_btcv_rec.batch_currency := p5_a9;
    ddp_btcv_rec.irm_id := rosetta_g_miss_num_map(p5_a10);
    ddp_btcv_rec.description := p5_a11;
    ddp_btcv_rec.attribute_category := p5_a12;
    ddp_btcv_rec.attribute1 := p5_a13;
    ddp_btcv_rec.attribute2 := p5_a14;
    ddp_btcv_rec.attribute3 := p5_a15;
    ddp_btcv_rec.attribute4 := p5_a16;
    ddp_btcv_rec.attribute5 := p5_a17;
    ddp_btcv_rec.attribute6 := p5_a18;
    ddp_btcv_rec.attribute7 := p5_a19;
    ddp_btcv_rec.attribute8 := p5_a20;
    ddp_btcv_rec.attribute9 := p5_a21;
    ddp_btcv_rec.attribute10 := p5_a22;
    ddp_btcv_rec.attribute11 := p5_a23;
    ddp_btcv_rec.attribute12 := p5_a24;
    ddp_btcv_rec.attribute13 := p5_a25;
    ddp_btcv_rec.attribute14 := p5_a26;
    ddp_btcv_rec.attribute15 := p5_a27;
    ddp_btcv_rec.request_id := rosetta_g_miss_num_map(p5_a28);
    ddp_btcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a29);
    ddp_btcv_rec.program_id := rosetta_g_miss_num_map(p5_a30);
    ddp_btcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_btcv_rec.org_id := rosetta_g_miss_num_map(p5_a32);
    ddp_btcv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_btcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_btcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_btcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_btcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_btcv_rec.trx_status_code := p5_a38;
    ddp_btcv_rec.currency_conversion_type := p5_a39;
    ddp_btcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a40);
    ddp_btcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_btcv_rec.remit_bank_id := rosetta_g_miss_num_map(p5_a42);

    -- here's the delegated call to the old PL/SQL routine
    okl_trx_csh_batch_pub.validate_trx_csh_batch(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure handle_batch_receipt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_VARCHAR2_TABLE_100
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_DATE_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_VARCHAR2_TABLE_200
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_VARCHAR2_TABLE_200
    , p7_a17 JTF_VARCHAR2_TABLE_200
    , p7_a18 JTF_VARCHAR2_TABLE_200
    , p7_a19 JTF_VARCHAR2_TABLE_200
    , p7_a20 JTF_VARCHAR2_TABLE_200
    , p7_a21 JTF_VARCHAR2_TABLE_200
    , p7_a22 JTF_VARCHAR2_TABLE_200
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  DATE := fnd_api.g_miss_date
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
  )

  as
    ddp_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddx_btcv_rec okl_trx_csh_batch_pub.btcv_rec_type;
    ddp_btch_lines_tbl okl_trx_csh_batch_pub.okl_btch_dtls_tbl_type;
    ddx_btch_lines_tbl okl_trx_csh_batch_pub.okl_btch_dtls_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_btcv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_btcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_btcv_rec.sfwt_flag := p5_a2;
    ddp_btcv_rec.name := p5_a3;
    ddp_btcv_rec.date_entered := rosetta_g_miss_date_in_map(p5_a4);
    ddp_btcv_rec.date_gl_requested := rosetta_g_miss_date_in_map(p5_a5);
    ddp_btcv_rec.date_deposit := rosetta_g_miss_date_in_map(p5_a6);
    ddp_btcv_rec.batch_qty := rosetta_g_miss_num_map(p5_a7);
    ddp_btcv_rec.batch_total := rosetta_g_miss_num_map(p5_a8);
    ddp_btcv_rec.batch_currency := p5_a9;
    ddp_btcv_rec.irm_id := rosetta_g_miss_num_map(p5_a10);
    ddp_btcv_rec.description := p5_a11;
    ddp_btcv_rec.attribute_category := p5_a12;
    ddp_btcv_rec.attribute1 := p5_a13;
    ddp_btcv_rec.attribute2 := p5_a14;
    ddp_btcv_rec.attribute3 := p5_a15;
    ddp_btcv_rec.attribute4 := p5_a16;
    ddp_btcv_rec.attribute5 := p5_a17;
    ddp_btcv_rec.attribute6 := p5_a18;
    ddp_btcv_rec.attribute7 := p5_a19;
    ddp_btcv_rec.attribute8 := p5_a20;
    ddp_btcv_rec.attribute9 := p5_a21;
    ddp_btcv_rec.attribute10 := p5_a22;
    ddp_btcv_rec.attribute11 := p5_a23;
    ddp_btcv_rec.attribute12 := p5_a24;
    ddp_btcv_rec.attribute13 := p5_a25;
    ddp_btcv_rec.attribute14 := p5_a26;
    ddp_btcv_rec.attribute15 := p5_a27;
    ddp_btcv_rec.request_id := rosetta_g_miss_num_map(p5_a28);
    ddp_btcv_rec.program_application_id := rosetta_g_miss_num_map(p5_a29);
    ddp_btcv_rec.program_id := rosetta_g_miss_num_map(p5_a30);
    ddp_btcv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_btcv_rec.org_id := rosetta_g_miss_num_map(p5_a32);
    ddp_btcv_rec.created_by := rosetta_g_miss_num_map(p5_a33);
    ddp_btcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a34);
    ddp_btcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a35);
    ddp_btcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_btcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a37);
    ddp_btcv_rec.trx_status_code := p5_a38;
    ddp_btcv_rec.currency_conversion_type := p5_a39;
    ddp_btcv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a40);
    ddp_btcv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_btcv_rec.remit_bank_id := rosetta_g_miss_num_map(p5_a42);


    okl_btch_cash_applic_w.rosetta_table_copy_in_p13(ddp_btch_lines_tbl, p7_a0
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
    okl_trx_csh_batch_pub.handle_batch_receipt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_btcv_rec,
      ddx_btcv_rec,
      ddp_btch_lines_tbl,
      ddx_btch_lines_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_btcv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_btcv_rec.object_version_number);
    p6_a2 := ddx_btcv_rec.sfwt_flag;
    p6_a3 := ddx_btcv_rec.name;
    p6_a4 := ddx_btcv_rec.date_entered;
    p6_a5 := ddx_btcv_rec.date_gl_requested;
    p6_a6 := ddx_btcv_rec.date_deposit;
    p6_a7 := rosetta_g_miss_num_map(ddx_btcv_rec.batch_qty);
    p6_a8 := rosetta_g_miss_num_map(ddx_btcv_rec.batch_total);
    p6_a9 := ddx_btcv_rec.batch_currency;
    p6_a10 := rosetta_g_miss_num_map(ddx_btcv_rec.irm_id);
    p6_a11 := ddx_btcv_rec.description;
    p6_a12 := ddx_btcv_rec.attribute_category;
    p6_a13 := ddx_btcv_rec.attribute1;
    p6_a14 := ddx_btcv_rec.attribute2;
    p6_a15 := ddx_btcv_rec.attribute3;
    p6_a16 := ddx_btcv_rec.attribute4;
    p6_a17 := ddx_btcv_rec.attribute5;
    p6_a18 := ddx_btcv_rec.attribute6;
    p6_a19 := ddx_btcv_rec.attribute7;
    p6_a20 := ddx_btcv_rec.attribute8;
    p6_a21 := ddx_btcv_rec.attribute9;
    p6_a22 := ddx_btcv_rec.attribute10;
    p6_a23 := ddx_btcv_rec.attribute11;
    p6_a24 := ddx_btcv_rec.attribute12;
    p6_a25 := ddx_btcv_rec.attribute13;
    p6_a26 := ddx_btcv_rec.attribute14;
    p6_a27 := ddx_btcv_rec.attribute15;
    p6_a28 := rosetta_g_miss_num_map(ddx_btcv_rec.request_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_btcv_rec.program_application_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_btcv_rec.program_id);
    p6_a31 := ddx_btcv_rec.program_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_btcv_rec.org_id);
    p6_a33 := rosetta_g_miss_num_map(ddx_btcv_rec.created_by);
    p6_a34 := ddx_btcv_rec.creation_date;
    p6_a35 := rosetta_g_miss_num_map(ddx_btcv_rec.last_updated_by);
    p6_a36 := ddx_btcv_rec.last_update_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_btcv_rec.last_update_login);
    p6_a38 := ddx_btcv_rec.trx_status_code;
    p6_a39 := ddx_btcv_rec.currency_conversion_type;
    p6_a40 := rosetta_g_miss_num_map(ddx_btcv_rec.currency_conversion_rate);
    p6_a41 := ddx_btcv_rec.currency_conversion_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_btcv_rec.remit_bank_id);


    okl_btch_cash_applic_w.rosetta_table_copy_out_p13(ddx_btch_lines_tbl, p8_a0
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

end okl_trx_csh_batch_pub_w;

/
