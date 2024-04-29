--------------------------------------------------------
--  DDL for Package Body OKL_CURE_REPORT_AMT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_REPORT_AMT_PUB_W" as
  /* $Header: OKLUCRAB.pls 120.1 2005/07/08 10:34:48 dkagrawa noship $ */
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

  procedure insert_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_VARCHAR2_TABLE_300
    , p5_a34 JTF_VARCHAR2_TABLE_300
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_crav_tbl okl_cure_report_amt_pub.crav_tbl_type;
    ddx_crav_tbl okl_cure_report_amt_pub.crav_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cra_pvt_w.rosetta_table_copy_in_p2(ddp_crav_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.insert_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_tbl,
      ddx_crav_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cra_pvt_w.rosetta_table_copy_out_p2(ddx_crav_tbl, p6_a0
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
      );
  end;

  procedure insert_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
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
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_crav_rec okl_cure_report_amt_pub.crav_rec_type;
    ddx_crav_rec okl_cure_report_amt_pub.crav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crav_rec.cure_report_amount_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crav_rec.cure_amount_id := rosetta_g_miss_num_map(p5_a1);
    ddp_crav_rec.cure_report_id := rosetta_g_miss_num_map(p5_a2);
    ddp_crav_rec.request_type := p5_a3;
    ddp_crav_rec.cures_in_possession := rosetta_g_miss_num_map(p5_a4);
    ddp_crav_rec.claimed_cure_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_crav_rec.past_due_amount := rosetta_g_miss_num_map(p5_a6);
    ddp_crav_rec.eligible_cure_amount := rosetta_g_miss_num_map(p5_a7);
    ddp_crav_rec.repurchase_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_crav_rec.outstanding_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_crav_rec.times_cured := rosetta_g_miss_num_map(p5_a10);
    ddp_crav_rec.payments_remaining := rosetta_g_miss_num_map(p5_a11);
    ddp_crav_rec.status := p5_a12;
    ddp_crav_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_crav_rec.org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crav_rec.request_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crav_rec.program_application_id := rosetta_g_miss_num_map(p5_a16);
    ddp_crav_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_crav_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_crav_rec.attribute_category := p5_a19;
    ddp_crav_rec.attribute1 := p5_a20;
    ddp_crav_rec.attribute2 := p5_a21;
    ddp_crav_rec.attribute3 := p5_a22;
    ddp_crav_rec.attribute4 := p5_a23;
    ddp_crav_rec.attribute5 := p5_a24;
    ddp_crav_rec.attribute6 := p5_a25;
    ddp_crav_rec.attribute7 := p5_a26;
    ddp_crav_rec.attribute8 := p5_a27;
    ddp_crav_rec.attribute9 := p5_a28;
    ddp_crav_rec.attribute10 := p5_a29;
    ddp_crav_rec.attribute11 := p5_a30;
    ddp_crav_rec.attribute12 := p5_a31;
    ddp_crav_rec.attribute13 := p5_a32;
    ddp_crav_rec.attribute14 := p5_a33;
    ddp_crav_rec.attribute15 := p5_a34;
    ddp_crav_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_crav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_crav_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.insert_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_rec,
      ddx_crav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_crav_rec.cure_report_amount_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_crav_rec.cure_amount_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_crav_rec.cure_report_id);
    p6_a3 := ddx_crav_rec.request_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_crav_rec.cures_in_possession);
    p6_a5 := rosetta_g_miss_num_map(ddx_crav_rec.claimed_cure_amount);
    p6_a6 := rosetta_g_miss_num_map(ddx_crav_rec.past_due_amount);
    p6_a7 := rosetta_g_miss_num_map(ddx_crav_rec.eligible_cure_amount);
    p6_a8 := rosetta_g_miss_num_map(ddx_crav_rec.repurchase_amount);
    p6_a9 := rosetta_g_miss_num_map(ddx_crav_rec.outstanding_amount);
    p6_a10 := rosetta_g_miss_num_map(ddx_crav_rec.times_cured);
    p6_a11 := rosetta_g_miss_num_map(ddx_crav_rec.payments_remaining);
    p6_a12 := ddx_crav_rec.status;
    p6_a13 := rosetta_g_miss_num_map(ddx_crav_rec.object_version_number);
    p6_a14 := rosetta_g_miss_num_map(ddx_crav_rec.org_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_crav_rec.request_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_crav_rec.program_application_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_crav_rec.program_id);
    p6_a18 := ddx_crav_rec.program_update_date;
    p6_a19 := ddx_crav_rec.attribute_category;
    p6_a20 := ddx_crav_rec.attribute1;
    p6_a21 := ddx_crav_rec.attribute2;
    p6_a22 := ddx_crav_rec.attribute3;
    p6_a23 := ddx_crav_rec.attribute4;
    p6_a24 := ddx_crav_rec.attribute5;
    p6_a25 := ddx_crav_rec.attribute6;
    p6_a26 := ddx_crav_rec.attribute7;
    p6_a27 := ddx_crav_rec.attribute8;
    p6_a28 := ddx_crav_rec.attribute9;
    p6_a29 := ddx_crav_rec.attribute10;
    p6_a30 := ddx_crav_rec.attribute11;
    p6_a31 := ddx_crav_rec.attribute12;
    p6_a32 := ddx_crav_rec.attribute13;
    p6_a33 := ddx_crav_rec.attribute14;
    p6_a34 := ddx_crav_rec.attribute15;
    p6_a35 := rosetta_g_miss_num_map(ddx_crav_rec.created_by);
    p6_a36 := ddx_crav_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_crav_rec.last_updated_by);
    p6_a38 := ddx_crav_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_crav_rec.last_update_login);
  end;

  procedure lock_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_VARCHAR2_TABLE_300
    , p5_a34 JTF_VARCHAR2_TABLE_300
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
  )

  as
    ddp_crav_tbl okl_cure_report_amt_pub.crav_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cra_pvt_w.rosetta_table_copy_in_p2(ddp_crav_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.lock_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_crav_rec okl_cure_report_amt_pub.crav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crav_rec.cure_report_amount_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crav_rec.cure_amount_id := rosetta_g_miss_num_map(p5_a1);
    ddp_crav_rec.cure_report_id := rosetta_g_miss_num_map(p5_a2);
    ddp_crav_rec.request_type := p5_a3;
    ddp_crav_rec.cures_in_possession := rosetta_g_miss_num_map(p5_a4);
    ddp_crav_rec.claimed_cure_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_crav_rec.past_due_amount := rosetta_g_miss_num_map(p5_a6);
    ddp_crav_rec.eligible_cure_amount := rosetta_g_miss_num_map(p5_a7);
    ddp_crav_rec.repurchase_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_crav_rec.outstanding_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_crav_rec.times_cured := rosetta_g_miss_num_map(p5_a10);
    ddp_crav_rec.payments_remaining := rosetta_g_miss_num_map(p5_a11);
    ddp_crav_rec.status := p5_a12;
    ddp_crav_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_crav_rec.org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crav_rec.request_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crav_rec.program_application_id := rosetta_g_miss_num_map(p5_a16);
    ddp_crav_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_crav_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_crav_rec.attribute_category := p5_a19;
    ddp_crav_rec.attribute1 := p5_a20;
    ddp_crav_rec.attribute2 := p5_a21;
    ddp_crav_rec.attribute3 := p5_a22;
    ddp_crav_rec.attribute4 := p5_a23;
    ddp_crav_rec.attribute5 := p5_a24;
    ddp_crav_rec.attribute6 := p5_a25;
    ddp_crav_rec.attribute7 := p5_a26;
    ddp_crav_rec.attribute8 := p5_a27;
    ddp_crav_rec.attribute9 := p5_a28;
    ddp_crav_rec.attribute10 := p5_a29;
    ddp_crav_rec.attribute11 := p5_a30;
    ddp_crav_rec.attribute12 := p5_a31;
    ddp_crav_rec.attribute13 := p5_a32;
    ddp_crav_rec.attribute14 := p5_a33;
    ddp_crav_rec.attribute15 := p5_a34;
    ddp_crav_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_crav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_crav_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.lock_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_VARCHAR2_TABLE_300
    , p5_a34 JTF_VARCHAR2_TABLE_300
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_NUMBER_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_DATE_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_crav_tbl okl_cure_report_amt_pub.crav_tbl_type;
    ddx_crav_tbl okl_cure_report_amt_pub.crav_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cra_pvt_w.rosetta_table_copy_in_p2(ddp_crav_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.update_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_tbl,
      ddx_crav_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_cra_pvt_w.rosetta_table_copy_out_p2(ddx_crav_tbl, p6_a0
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
      );
  end;

  procedure update_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
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
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_crav_rec okl_cure_report_amt_pub.crav_rec_type;
    ddx_crav_rec okl_cure_report_amt_pub.crav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crav_rec.cure_report_amount_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crav_rec.cure_amount_id := rosetta_g_miss_num_map(p5_a1);
    ddp_crav_rec.cure_report_id := rosetta_g_miss_num_map(p5_a2);
    ddp_crav_rec.request_type := p5_a3;
    ddp_crav_rec.cures_in_possession := rosetta_g_miss_num_map(p5_a4);
    ddp_crav_rec.claimed_cure_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_crav_rec.past_due_amount := rosetta_g_miss_num_map(p5_a6);
    ddp_crav_rec.eligible_cure_amount := rosetta_g_miss_num_map(p5_a7);
    ddp_crav_rec.repurchase_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_crav_rec.outstanding_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_crav_rec.times_cured := rosetta_g_miss_num_map(p5_a10);
    ddp_crav_rec.payments_remaining := rosetta_g_miss_num_map(p5_a11);
    ddp_crav_rec.status := p5_a12;
    ddp_crav_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_crav_rec.org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crav_rec.request_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crav_rec.program_application_id := rosetta_g_miss_num_map(p5_a16);
    ddp_crav_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_crav_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_crav_rec.attribute_category := p5_a19;
    ddp_crav_rec.attribute1 := p5_a20;
    ddp_crav_rec.attribute2 := p5_a21;
    ddp_crav_rec.attribute3 := p5_a22;
    ddp_crav_rec.attribute4 := p5_a23;
    ddp_crav_rec.attribute5 := p5_a24;
    ddp_crav_rec.attribute6 := p5_a25;
    ddp_crav_rec.attribute7 := p5_a26;
    ddp_crav_rec.attribute8 := p5_a27;
    ddp_crav_rec.attribute9 := p5_a28;
    ddp_crav_rec.attribute10 := p5_a29;
    ddp_crav_rec.attribute11 := p5_a30;
    ddp_crav_rec.attribute12 := p5_a31;
    ddp_crav_rec.attribute13 := p5_a32;
    ddp_crav_rec.attribute14 := p5_a33;
    ddp_crav_rec.attribute15 := p5_a34;
    ddp_crav_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_crav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_crav_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);


    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.update_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_rec,
      ddx_crav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_crav_rec.cure_report_amount_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_crav_rec.cure_amount_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_crav_rec.cure_report_id);
    p6_a3 := ddx_crav_rec.request_type;
    p6_a4 := rosetta_g_miss_num_map(ddx_crav_rec.cures_in_possession);
    p6_a5 := rosetta_g_miss_num_map(ddx_crav_rec.claimed_cure_amount);
    p6_a6 := rosetta_g_miss_num_map(ddx_crav_rec.past_due_amount);
    p6_a7 := rosetta_g_miss_num_map(ddx_crav_rec.eligible_cure_amount);
    p6_a8 := rosetta_g_miss_num_map(ddx_crav_rec.repurchase_amount);
    p6_a9 := rosetta_g_miss_num_map(ddx_crav_rec.outstanding_amount);
    p6_a10 := rosetta_g_miss_num_map(ddx_crav_rec.times_cured);
    p6_a11 := rosetta_g_miss_num_map(ddx_crav_rec.payments_remaining);
    p6_a12 := ddx_crav_rec.status;
    p6_a13 := rosetta_g_miss_num_map(ddx_crav_rec.object_version_number);
    p6_a14 := rosetta_g_miss_num_map(ddx_crav_rec.org_id);
    p6_a15 := rosetta_g_miss_num_map(ddx_crav_rec.request_id);
    p6_a16 := rosetta_g_miss_num_map(ddx_crav_rec.program_application_id);
    p6_a17 := rosetta_g_miss_num_map(ddx_crav_rec.program_id);
    p6_a18 := ddx_crav_rec.program_update_date;
    p6_a19 := ddx_crav_rec.attribute_category;
    p6_a20 := ddx_crav_rec.attribute1;
    p6_a21 := ddx_crav_rec.attribute2;
    p6_a22 := ddx_crav_rec.attribute3;
    p6_a23 := ddx_crav_rec.attribute4;
    p6_a24 := ddx_crav_rec.attribute5;
    p6_a25 := ddx_crav_rec.attribute6;
    p6_a26 := ddx_crav_rec.attribute7;
    p6_a27 := ddx_crav_rec.attribute8;
    p6_a28 := ddx_crav_rec.attribute9;
    p6_a29 := ddx_crav_rec.attribute10;
    p6_a30 := ddx_crav_rec.attribute11;
    p6_a31 := ddx_crav_rec.attribute12;
    p6_a32 := ddx_crav_rec.attribute13;
    p6_a33 := ddx_crav_rec.attribute14;
    p6_a34 := ddx_crav_rec.attribute15;
    p6_a35 := rosetta_g_miss_num_map(ddx_crav_rec.created_by);
    p6_a36 := ddx_crav_rec.creation_date;
    p6_a37 := rosetta_g_miss_num_map(ddx_crav_rec.last_updated_by);
    p6_a38 := ddx_crav_rec.last_update_date;
    p6_a39 := rosetta_g_miss_num_map(ddx_crav_rec.last_update_login);
  end;

  procedure delete_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_VARCHAR2_TABLE_300
    , p5_a34 JTF_VARCHAR2_TABLE_300
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
  )

  as
    ddp_crav_tbl okl_cure_report_amt_pub.crav_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cra_pvt_w.rosetta_table_copy_in_p2(ddp_crav_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.delete_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_crav_rec okl_cure_report_amt_pub.crav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crav_rec.cure_report_amount_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crav_rec.cure_amount_id := rosetta_g_miss_num_map(p5_a1);
    ddp_crav_rec.cure_report_id := rosetta_g_miss_num_map(p5_a2);
    ddp_crav_rec.request_type := p5_a3;
    ddp_crav_rec.cures_in_possession := rosetta_g_miss_num_map(p5_a4);
    ddp_crav_rec.claimed_cure_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_crav_rec.past_due_amount := rosetta_g_miss_num_map(p5_a6);
    ddp_crav_rec.eligible_cure_amount := rosetta_g_miss_num_map(p5_a7);
    ddp_crav_rec.repurchase_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_crav_rec.outstanding_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_crav_rec.times_cured := rosetta_g_miss_num_map(p5_a10);
    ddp_crav_rec.payments_remaining := rosetta_g_miss_num_map(p5_a11);
    ddp_crav_rec.status := p5_a12;
    ddp_crav_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_crav_rec.org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crav_rec.request_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crav_rec.program_application_id := rosetta_g_miss_num_map(p5_a16);
    ddp_crav_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_crav_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_crav_rec.attribute_category := p5_a19;
    ddp_crav_rec.attribute1 := p5_a20;
    ddp_crav_rec.attribute2 := p5_a21;
    ddp_crav_rec.attribute3 := p5_a22;
    ddp_crav_rec.attribute4 := p5_a23;
    ddp_crav_rec.attribute5 := p5_a24;
    ddp_crav_rec.attribute6 := p5_a25;
    ddp_crav_rec.attribute7 := p5_a26;
    ddp_crav_rec.attribute8 := p5_a27;
    ddp_crav_rec.attribute9 := p5_a28;
    ddp_crav_rec.attribute10 := p5_a29;
    ddp_crav_rec.attribute11 := p5_a30;
    ddp_crav_rec.attribute12 := p5_a31;
    ddp_crav_rec.attribute13 := p5_a32;
    ddp_crav_rec.attribute14 := p5_a33;
    ddp_crav_rec.attribute15 := p5_a34;
    ddp_crav_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_crav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_crav_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.delete_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_300
    , p5_a20 JTF_VARCHAR2_TABLE_300
    , p5_a21 JTF_VARCHAR2_TABLE_300
    , p5_a22 JTF_VARCHAR2_TABLE_300
    , p5_a23 JTF_VARCHAR2_TABLE_300
    , p5_a24 JTF_VARCHAR2_TABLE_300
    , p5_a25 JTF_VARCHAR2_TABLE_300
    , p5_a26 JTF_VARCHAR2_TABLE_300
    , p5_a27 JTF_VARCHAR2_TABLE_300
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_VARCHAR2_TABLE_300
    , p5_a31 JTF_VARCHAR2_TABLE_300
    , p5_a32 JTF_VARCHAR2_TABLE_300
    , p5_a33 JTF_VARCHAR2_TABLE_300
    , p5_a34 JTF_VARCHAR2_TABLE_300
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_DATE_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_NUMBER_TABLE
  )

  as
    ddp_crav_tbl okl_cure_report_amt_pub.crav_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_cra_pvt_w.rosetta_table_copy_in_p2(ddp_crav_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.validate_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_cure_report_amt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  DATE := fnd_api.g_miss_date
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  NUMBER := 0-1962.0724
  )

  as
    ddp_crav_rec okl_cure_report_amt_pub.crav_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_crav_rec.cure_report_amount_id := rosetta_g_miss_num_map(p5_a0);
    ddp_crav_rec.cure_amount_id := rosetta_g_miss_num_map(p5_a1);
    ddp_crav_rec.cure_report_id := rosetta_g_miss_num_map(p5_a2);
    ddp_crav_rec.request_type := p5_a3;
    ddp_crav_rec.cures_in_possession := rosetta_g_miss_num_map(p5_a4);
    ddp_crav_rec.claimed_cure_amount := rosetta_g_miss_num_map(p5_a5);
    ddp_crav_rec.past_due_amount := rosetta_g_miss_num_map(p5_a6);
    ddp_crav_rec.eligible_cure_amount := rosetta_g_miss_num_map(p5_a7);
    ddp_crav_rec.repurchase_amount := rosetta_g_miss_num_map(p5_a8);
    ddp_crav_rec.outstanding_amount := rosetta_g_miss_num_map(p5_a9);
    ddp_crav_rec.times_cured := rosetta_g_miss_num_map(p5_a10);
    ddp_crav_rec.payments_remaining := rosetta_g_miss_num_map(p5_a11);
    ddp_crav_rec.status := p5_a12;
    ddp_crav_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_crav_rec.org_id := rosetta_g_miss_num_map(p5_a14);
    ddp_crav_rec.request_id := rosetta_g_miss_num_map(p5_a15);
    ddp_crav_rec.program_application_id := rosetta_g_miss_num_map(p5_a16);
    ddp_crav_rec.program_id := rosetta_g_miss_num_map(p5_a17);
    ddp_crav_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_crav_rec.attribute_category := p5_a19;
    ddp_crav_rec.attribute1 := p5_a20;
    ddp_crav_rec.attribute2 := p5_a21;
    ddp_crav_rec.attribute3 := p5_a22;
    ddp_crav_rec.attribute4 := p5_a23;
    ddp_crav_rec.attribute5 := p5_a24;
    ddp_crav_rec.attribute6 := p5_a25;
    ddp_crav_rec.attribute7 := p5_a26;
    ddp_crav_rec.attribute8 := p5_a27;
    ddp_crav_rec.attribute9 := p5_a28;
    ddp_crav_rec.attribute10 := p5_a29;
    ddp_crav_rec.attribute11 := p5_a30;
    ddp_crav_rec.attribute12 := p5_a31;
    ddp_crav_rec.attribute13 := p5_a32;
    ddp_crav_rec.attribute14 := p5_a33;
    ddp_crav_rec.attribute15 := p5_a34;
    ddp_crav_rec.created_by := rosetta_g_miss_num_map(p5_a35);
    ddp_crav_rec.creation_date := rosetta_g_miss_date_in_map(p5_a36);
    ddp_crav_rec.last_updated_by := rosetta_g_miss_num_map(p5_a37);
    ddp_crav_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a38);
    ddp_crav_rec.last_update_login := rosetta_g_miss_num_map(p5_a39);

    -- here's the delegated call to the old PL/SQL routine
    okl_cure_report_amt_pub.validate_cure_report_amt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_crav_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_cure_report_amt_pub_w;

/
