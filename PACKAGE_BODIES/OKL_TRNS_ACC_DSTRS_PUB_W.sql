--------------------------------------------------------
--  DDL for Package Body OKL_TRNS_ACC_DSTRS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRNS_ACC_DSTRS_PUB_W" as
  /* $Header: OKLUTABB.pls 120.1 2005/07/20 10:11:58 dkagrawa noship $ */
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

  procedure insert_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
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
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  DATE
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
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
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tabv_rec okl_trns_acc_dstrs_pub.tabv_rec_type;
    ddx_tabv_rec okl_trns_acc_dstrs_pub.tabv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tabv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tabv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tabv_rec.template_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tabv_rec.cr_dr_flag := p5_a3;
    ddp_tabv_rec.ae_line_type := p5_a4;
    ddp_tabv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tabv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tabv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tabv_rec.currency_code := p5_a8;
    ddp_tabv_rec.currency_conversion_type := p5_a9;
    ddp_tabv_rec.source_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tabv_rec.source_table := p5_a11;
    ddp_tabv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_tabv_rec.accounted_amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tabv_rec.gl_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tabv_rec.percentage := rosetta_g_miss_num_map(p5_a15);
    ddp_tabv_rec.comments := p5_a16;
    ddp_tabv_rec.post_request_id := rosetta_g_miss_num_map(p5_a17);
    ddp_tabv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tabv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_tabv_rec.attribute_category := p5_a20;
    ddp_tabv_rec.attribute1 := p5_a21;
    ddp_tabv_rec.attribute2 := p5_a22;
    ddp_tabv_rec.attribute3 := p5_a23;
    ddp_tabv_rec.attribute4 := p5_a24;
    ddp_tabv_rec.attribute5 := p5_a25;
    ddp_tabv_rec.attribute6 := p5_a26;
    ddp_tabv_rec.attribute7 := p5_a27;
    ddp_tabv_rec.attribute8 := p5_a28;
    ddp_tabv_rec.attribute9 := p5_a29;
    ddp_tabv_rec.attribute10 := p5_a30;
    ddp_tabv_rec.attribute11 := p5_a31;
    ddp_tabv_rec.attribute12 := p5_a32;
    ddp_tabv_rec.attribute13 := p5_a33;
    ddp_tabv_rec.attribute14 := p5_a34;
    ddp_tabv_rec.attribute15 := p5_a35;
    ddp_tabv_rec.request_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tabv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tabv_rec.program_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tabv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tabv_rec.created_by := rosetta_g_miss_num_map(p5_a40);
    ddp_tabv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tabv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a42);
    ddp_tabv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_tabv_rec.last_update_login := rosetta_g_miss_num_map(p5_a44);
    ddp_tabv_rec.aet_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tabv_rec.posted_yn := p5_a46;
    ddp_tabv_rec.ae_creation_error := p5_a47;
    ddp_tabv_rec.gl_reversal_flag := p5_a48;
    ddp_tabv_rec.reverse_event_flag := p5_a49;
    ddp_tabv_rec.draft_yn := p5_a50;
    ddp_tabv_rec.draft_version := rosetta_g_miss_num_map(p5_a51);
    ddp_tabv_rec.original_dist_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tabv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tabv_rec.post_to_gl := p5_a54;


    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.insert_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_rec,
      ddx_tabv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tabv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tabv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_tabv_rec.template_id);
    p6_a3 := ddx_tabv_rec.cr_dr_flag;
    p6_a4 := ddx_tabv_rec.ae_line_type;
    p6_a5 := rosetta_g_miss_num_map(ddx_tabv_rec.org_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tabv_rec.set_of_books_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tabv_rec.code_combination_id);
    p6_a8 := ddx_tabv_rec.currency_code;
    p6_a9 := ddx_tabv_rec.currency_conversion_type;
    p6_a10 := rosetta_g_miss_num_map(ddx_tabv_rec.source_id);
    p6_a11 := ddx_tabv_rec.source_table;
    p6_a12 := rosetta_g_miss_num_map(ddx_tabv_rec.amount);
    p6_a13 := rosetta_g_miss_num_map(ddx_tabv_rec.accounted_amount);
    p6_a14 := ddx_tabv_rec.gl_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_tabv_rec.percentage);
    p6_a16 := ddx_tabv_rec.comments;
    p6_a17 := rosetta_g_miss_num_map(ddx_tabv_rec.post_request_id);
    p6_a18 := ddx_tabv_rec.currency_conversion_date;
    p6_a19 := rosetta_g_miss_num_map(ddx_tabv_rec.currency_conversion_rate);
    p6_a20 := ddx_tabv_rec.attribute_category;
    p6_a21 := ddx_tabv_rec.attribute1;
    p6_a22 := ddx_tabv_rec.attribute2;
    p6_a23 := ddx_tabv_rec.attribute3;
    p6_a24 := ddx_tabv_rec.attribute4;
    p6_a25 := ddx_tabv_rec.attribute5;
    p6_a26 := ddx_tabv_rec.attribute6;
    p6_a27 := ddx_tabv_rec.attribute7;
    p6_a28 := ddx_tabv_rec.attribute8;
    p6_a29 := ddx_tabv_rec.attribute9;
    p6_a30 := ddx_tabv_rec.attribute10;
    p6_a31 := ddx_tabv_rec.attribute11;
    p6_a32 := ddx_tabv_rec.attribute12;
    p6_a33 := ddx_tabv_rec.attribute13;
    p6_a34 := ddx_tabv_rec.attribute14;
    p6_a35 := ddx_tabv_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddx_tabv_rec.request_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_tabv_rec.program_application_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_tabv_rec.program_id);
    p6_a39 := ddx_tabv_rec.program_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_tabv_rec.created_by);
    p6_a41 := ddx_tabv_rec.creation_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_tabv_rec.last_updated_by);
    p6_a43 := ddx_tabv_rec.last_update_date;
    p6_a44 := rosetta_g_miss_num_map(ddx_tabv_rec.last_update_login);
    p6_a45 := rosetta_g_miss_num_map(ddx_tabv_rec.aet_id);
    p6_a46 := ddx_tabv_rec.posted_yn;
    p6_a47 := ddx_tabv_rec.ae_creation_error;
    p6_a48 := ddx_tabv_rec.gl_reversal_flag;
    p6_a49 := ddx_tabv_rec.reverse_event_flag;
    p6_a50 := ddx_tabv_rec.draft_yn;
    p6_a51 := rosetta_g_miss_num_map(ddx_tabv_rec.draft_version);
    p6_a52 := rosetta_g_miss_num_map(ddx_tabv_rec.original_dist_id);
    p6_a53 := rosetta_g_miss_num_map(ddx_tabv_rec.accounting_event_id);
    p6_a54 := ddx_tabv_rec.post_to_gl;
  end;

  procedure insert_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_300
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_DATE_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tabv_tbl okl_trns_acc_dstrs_pub.tabv_tbl_type;
    ddx_tabv_tbl okl_trns_acc_dstrs_pub.tabv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tab_pvt_w.rosetta_table_copy_in_p5(ddp_tabv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.insert_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_tbl,
      ddx_tabv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tab_pvt_w.rosetta_table_copy_out_p5(ddx_tabv_tbl, p6_a0
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
      );
  end;

  procedure lock_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
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
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tabv_rec okl_trns_acc_dstrs_pub.tabv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tabv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tabv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tabv_rec.template_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tabv_rec.cr_dr_flag := p5_a3;
    ddp_tabv_rec.ae_line_type := p5_a4;
    ddp_tabv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tabv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tabv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tabv_rec.currency_code := p5_a8;
    ddp_tabv_rec.currency_conversion_type := p5_a9;
    ddp_tabv_rec.source_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tabv_rec.source_table := p5_a11;
    ddp_tabv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_tabv_rec.accounted_amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tabv_rec.gl_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tabv_rec.percentage := rosetta_g_miss_num_map(p5_a15);
    ddp_tabv_rec.comments := p5_a16;
    ddp_tabv_rec.post_request_id := rosetta_g_miss_num_map(p5_a17);
    ddp_tabv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tabv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_tabv_rec.attribute_category := p5_a20;
    ddp_tabv_rec.attribute1 := p5_a21;
    ddp_tabv_rec.attribute2 := p5_a22;
    ddp_tabv_rec.attribute3 := p5_a23;
    ddp_tabv_rec.attribute4 := p5_a24;
    ddp_tabv_rec.attribute5 := p5_a25;
    ddp_tabv_rec.attribute6 := p5_a26;
    ddp_tabv_rec.attribute7 := p5_a27;
    ddp_tabv_rec.attribute8 := p5_a28;
    ddp_tabv_rec.attribute9 := p5_a29;
    ddp_tabv_rec.attribute10 := p5_a30;
    ddp_tabv_rec.attribute11 := p5_a31;
    ddp_tabv_rec.attribute12 := p5_a32;
    ddp_tabv_rec.attribute13 := p5_a33;
    ddp_tabv_rec.attribute14 := p5_a34;
    ddp_tabv_rec.attribute15 := p5_a35;
    ddp_tabv_rec.request_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tabv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tabv_rec.program_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tabv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tabv_rec.created_by := rosetta_g_miss_num_map(p5_a40);
    ddp_tabv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tabv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a42);
    ddp_tabv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_tabv_rec.last_update_login := rosetta_g_miss_num_map(p5_a44);
    ddp_tabv_rec.aet_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tabv_rec.posted_yn := p5_a46;
    ddp_tabv_rec.ae_creation_error := p5_a47;
    ddp_tabv_rec.gl_reversal_flag := p5_a48;
    ddp_tabv_rec.reverse_event_flag := p5_a49;
    ddp_tabv_rec.draft_yn := p5_a50;
    ddp_tabv_rec.draft_version := rosetta_g_miss_num_map(p5_a51);
    ddp_tabv_rec.original_dist_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tabv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tabv_rec.post_to_gl := p5_a54;

    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.lock_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_300
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tabv_tbl okl_trns_acc_dstrs_pub.tabv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tab_pvt_w.rosetta_table_copy_in_p5(ddp_tabv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.lock_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
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
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  DATE
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  DATE
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  NUMBER
    , p6_a52 out nocopy  NUMBER
    , p6_a53 out nocopy  NUMBER
    , p6_a54 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
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
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tabv_rec okl_trns_acc_dstrs_pub.tabv_rec_type;
    ddx_tabv_rec okl_trns_acc_dstrs_pub.tabv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tabv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tabv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tabv_rec.template_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tabv_rec.cr_dr_flag := p5_a3;
    ddp_tabv_rec.ae_line_type := p5_a4;
    ddp_tabv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tabv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tabv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tabv_rec.currency_code := p5_a8;
    ddp_tabv_rec.currency_conversion_type := p5_a9;
    ddp_tabv_rec.source_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tabv_rec.source_table := p5_a11;
    ddp_tabv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_tabv_rec.accounted_amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tabv_rec.gl_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tabv_rec.percentage := rosetta_g_miss_num_map(p5_a15);
    ddp_tabv_rec.comments := p5_a16;
    ddp_tabv_rec.post_request_id := rosetta_g_miss_num_map(p5_a17);
    ddp_tabv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tabv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_tabv_rec.attribute_category := p5_a20;
    ddp_tabv_rec.attribute1 := p5_a21;
    ddp_tabv_rec.attribute2 := p5_a22;
    ddp_tabv_rec.attribute3 := p5_a23;
    ddp_tabv_rec.attribute4 := p5_a24;
    ddp_tabv_rec.attribute5 := p5_a25;
    ddp_tabv_rec.attribute6 := p5_a26;
    ddp_tabv_rec.attribute7 := p5_a27;
    ddp_tabv_rec.attribute8 := p5_a28;
    ddp_tabv_rec.attribute9 := p5_a29;
    ddp_tabv_rec.attribute10 := p5_a30;
    ddp_tabv_rec.attribute11 := p5_a31;
    ddp_tabv_rec.attribute12 := p5_a32;
    ddp_tabv_rec.attribute13 := p5_a33;
    ddp_tabv_rec.attribute14 := p5_a34;
    ddp_tabv_rec.attribute15 := p5_a35;
    ddp_tabv_rec.request_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tabv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tabv_rec.program_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tabv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tabv_rec.created_by := rosetta_g_miss_num_map(p5_a40);
    ddp_tabv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tabv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a42);
    ddp_tabv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_tabv_rec.last_update_login := rosetta_g_miss_num_map(p5_a44);
    ddp_tabv_rec.aet_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tabv_rec.posted_yn := p5_a46;
    ddp_tabv_rec.ae_creation_error := p5_a47;
    ddp_tabv_rec.gl_reversal_flag := p5_a48;
    ddp_tabv_rec.reverse_event_flag := p5_a49;
    ddp_tabv_rec.draft_yn := p5_a50;
    ddp_tabv_rec.draft_version := rosetta_g_miss_num_map(p5_a51);
    ddp_tabv_rec.original_dist_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tabv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tabv_rec.post_to_gl := p5_a54;


    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.update_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_rec,
      ddx_tabv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_tabv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_tabv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_tabv_rec.template_id);
    p6_a3 := ddx_tabv_rec.cr_dr_flag;
    p6_a4 := ddx_tabv_rec.ae_line_type;
    p6_a5 := rosetta_g_miss_num_map(ddx_tabv_rec.org_id);
    p6_a6 := rosetta_g_miss_num_map(ddx_tabv_rec.set_of_books_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_tabv_rec.code_combination_id);
    p6_a8 := ddx_tabv_rec.currency_code;
    p6_a9 := ddx_tabv_rec.currency_conversion_type;
    p6_a10 := rosetta_g_miss_num_map(ddx_tabv_rec.source_id);
    p6_a11 := ddx_tabv_rec.source_table;
    p6_a12 := rosetta_g_miss_num_map(ddx_tabv_rec.amount);
    p6_a13 := rosetta_g_miss_num_map(ddx_tabv_rec.accounted_amount);
    p6_a14 := ddx_tabv_rec.gl_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_tabv_rec.percentage);
    p6_a16 := ddx_tabv_rec.comments;
    p6_a17 := rosetta_g_miss_num_map(ddx_tabv_rec.post_request_id);
    p6_a18 := ddx_tabv_rec.currency_conversion_date;
    p6_a19 := rosetta_g_miss_num_map(ddx_tabv_rec.currency_conversion_rate);
    p6_a20 := ddx_tabv_rec.attribute_category;
    p6_a21 := ddx_tabv_rec.attribute1;
    p6_a22 := ddx_tabv_rec.attribute2;
    p6_a23 := ddx_tabv_rec.attribute3;
    p6_a24 := ddx_tabv_rec.attribute4;
    p6_a25 := ddx_tabv_rec.attribute5;
    p6_a26 := ddx_tabv_rec.attribute6;
    p6_a27 := ddx_tabv_rec.attribute7;
    p6_a28 := ddx_tabv_rec.attribute8;
    p6_a29 := ddx_tabv_rec.attribute9;
    p6_a30 := ddx_tabv_rec.attribute10;
    p6_a31 := ddx_tabv_rec.attribute11;
    p6_a32 := ddx_tabv_rec.attribute12;
    p6_a33 := ddx_tabv_rec.attribute13;
    p6_a34 := ddx_tabv_rec.attribute14;
    p6_a35 := ddx_tabv_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddx_tabv_rec.request_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_tabv_rec.program_application_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_tabv_rec.program_id);
    p6_a39 := ddx_tabv_rec.program_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_tabv_rec.created_by);
    p6_a41 := ddx_tabv_rec.creation_date;
    p6_a42 := rosetta_g_miss_num_map(ddx_tabv_rec.last_updated_by);
    p6_a43 := ddx_tabv_rec.last_update_date;
    p6_a44 := rosetta_g_miss_num_map(ddx_tabv_rec.last_update_login);
    p6_a45 := rosetta_g_miss_num_map(ddx_tabv_rec.aet_id);
    p6_a46 := ddx_tabv_rec.posted_yn;
    p6_a47 := ddx_tabv_rec.ae_creation_error;
    p6_a48 := ddx_tabv_rec.gl_reversal_flag;
    p6_a49 := ddx_tabv_rec.reverse_event_flag;
    p6_a50 := ddx_tabv_rec.draft_yn;
    p6_a51 := rosetta_g_miss_num_map(ddx_tabv_rec.draft_version);
    p6_a52 := rosetta_g_miss_num_map(ddx_tabv_rec.original_dist_id);
    p6_a53 := rosetta_g_miss_num_map(ddx_tabv_rec.accounting_event_id);
    p6_a54 := ddx_tabv_rec.post_to_gl;
  end;

  procedure update_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_300
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
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
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_DATE_TABLE
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_DATE_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_NUMBER_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tabv_tbl okl_trns_acc_dstrs_pub.tabv_tbl_type;
    ddx_tabv_tbl okl_trns_acc_dstrs_pub.tabv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tab_pvt_w.rosetta_table_copy_in_p5(ddp_tabv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.update_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_tbl,
      ddx_tabv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tab_pvt_w.rosetta_table_copy_out_p5(ddx_tabv_tbl, p6_a0
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
      );
  end;

  procedure delete_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
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
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tabv_rec okl_trns_acc_dstrs_pub.tabv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tabv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tabv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tabv_rec.template_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tabv_rec.cr_dr_flag := p5_a3;
    ddp_tabv_rec.ae_line_type := p5_a4;
    ddp_tabv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tabv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tabv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tabv_rec.currency_code := p5_a8;
    ddp_tabv_rec.currency_conversion_type := p5_a9;
    ddp_tabv_rec.source_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tabv_rec.source_table := p5_a11;
    ddp_tabv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_tabv_rec.accounted_amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tabv_rec.gl_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tabv_rec.percentage := rosetta_g_miss_num_map(p5_a15);
    ddp_tabv_rec.comments := p5_a16;
    ddp_tabv_rec.post_request_id := rosetta_g_miss_num_map(p5_a17);
    ddp_tabv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tabv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_tabv_rec.attribute_category := p5_a20;
    ddp_tabv_rec.attribute1 := p5_a21;
    ddp_tabv_rec.attribute2 := p5_a22;
    ddp_tabv_rec.attribute3 := p5_a23;
    ddp_tabv_rec.attribute4 := p5_a24;
    ddp_tabv_rec.attribute5 := p5_a25;
    ddp_tabv_rec.attribute6 := p5_a26;
    ddp_tabv_rec.attribute7 := p5_a27;
    ddp_tabv_rec.attribute8 := p5_a28;
    ddp_tabv_rec.attribute9 := p5_a29;
    ddp_tabv_rec.attribute10 := p5_a30;
    ddp_tabv_rec.attribute11 := p5_a31;
    ddp_tabv_rec.attribute12 := p5_a32;
    ddp_tabv_rec.attribute13 := p5_a33;
    ddp_tabv_rec.attribute14 := p5_a34;
    ddp_tabv_rec.attribute15 := p5_a35;
    ddp_tabv_rec.request_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tabv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tabv_rec.program_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tabv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tabv_rec.created_by := rosetta_g_miss_num_map(p5_a40);
    ddp_tabv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tabv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a42);
    ddp_tabv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_tabv_rec.last_update_login := rosetta_g_miss_num_map(p5_a44);
    ddp_tabv_rec.aet_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tabv_rec.posted_yn := p5_a46;
    ddp_tabv_rec.ae_creation_error := p5_a47;
    ddp_tabv_rec.gl_reversal_flag := p5_a48;
    ddp_tabv_rec.reverse_event_flag := p5_a49;
    ddp_tabv_rec.draft_yn := p5_a50;
    ddp_tabv_rec.draft_version := rosetta_g_miss_num_map(p5_a51);
    ddp_tabv_rec.original_dist_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tabv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tabv_rec.post_to_gl := p5_a54;

    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.delete_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_300
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tabv_tbl okl_trns_acc_dstrs_pub.tabv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tab_pvt_w.rosetta_table_copy_in_p5(ddp_tabv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.delete_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
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
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  DATE := fnd_api.g_miss_date
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  DATE := fnd_api.g_miss_date
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  NUMBER := 0-1962.0724
    , p5_a52  NUMBER := 0-1962.0724
    , p5_a53  NUMBER := 0-1962.0724
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tabv_rec okl_trns_acc_dstrs_pub.tabv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tabv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_tabv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_tabv_rec.template_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tabv_rec.cr_dr_flag := p5_a3;
    ddp_tabv_rec.ae_line_type := p5_a4;
    ddp_tabv_rec.org_id := rosetta_g_miss_num_map(p5_a5);
    ddp_tabv_rec.set_of_books_id := rosetta_g_miss_num_map(p5_a6);
    ddp_tabv_rec.code_combination_id := rosetta_g_miss_num_map(p5_a7);
    ddp_tabv_rec.currency_code := p5_a8;
    ddp_tabv_rec.currency_conversion_type := p5_a9;
    ddp_tabv_rec.source_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tabv_rec.source_table := p5_a11;
    ddp_tabv_rec.amount := rosetta_g_miss_num_map(p5_a12);
    ddp_tabv_rec.accounted_amount := rosetta_g_miss_num_map(p5_a13);
    ddp_tabv_rec.gl_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_tabv_rec.percentage := rosetta_g_miss_num_map(p5_a15);
    ddp_tabv_rec.comments := p5_a16;
    ddp_tabv_rec.post_request_id := rosetta_g_miss_num_map(p5_a17);
    ddp_tabv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_tabv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a19);
    ddp_tabv_rec.attribute_category := p5_a20;
    ddp_tabv_rec.attribute1 := p5_a21;
    ddp_tabv_rec.attribute2 := p5_a22;
    ddp_tabv_rec.attribute3 := p5_a23;
    ddp_tabv_rec.attribute4 := p5_a24;
    ddp_tabv_rec.attribute5 := p5_a25;
    ddp_tabv_rec.attribute6 := p5_a26;
    ddp_tabv_rec.attribute7 := p5_a27;
    ddp_tabv_rec.attribute8 := p5_a28;
    ddp_tabv_rec.attribute9 := p5_a29;
    ddp_tabv_rec.attribute10 := p5_a30;
    ddp_tabv_rec.attribute11 := p5_a31;
    ddp_tabv_rec.attribute12 := p5_a32;
    ddp_tabv_rec.attribute13 := p5_a33;
    ddp_tabv_rec.attribute14 := p5_a34;
    ddp_tabv_rec.attribute15 := p5_a35;
    ddp_tabv_rec.request_id := rosetta_g_miss_num_map(p5_a36);
    ddp_tabv_rec.program_application_id := rosetta_g_miss_num_map(p5_a37);
    ddp_tabv_rec.program_id := rosetta_g_miss_num_map(p5_a38);
    ddp_tabv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tabv_rec.created_by := rosetta_g_miss_num_map(p5_a40);
    ddp_tabv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a41);
    ddp_tabv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a42);
    ddp_tabv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a43);
    ddp_tabv_rec.last_update_login := rosetta_g_miss_num_map(p5_a44);
    ddp_tabv_rec.aet_id := rosetta_g_miss_num_map(p5_a45);
    ddp_tabv_rec.posted_yn := p5_a46;
    ddp_tabv_rec.ae_creation_error := p5_a47;
    ddp_tabv_rec.gl_reversal_flag := p5_a48;
    ddp_tabv_rec.reverse_event_flag := p5_a49;
    ddp_tabv_rec.draft_yn := p5_a50;
    ddp_tabv_rec.draft_version := rosetta_g_miss_num_map(p5_a51);
    ddp_tabv_rec.original_dist_id := rosetta_g_miss_num_map(p5_a52);
    ddp_tabv_rec.accounting_event_id := rosetta_g_miss_num_map(p5_a53);
    ddp_tabv_rec.post_to_gl := p5_a54;

    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.validate_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_trns_acc_dstrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_2000
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_VARCHAR2_TABLE_500
    , p5_a22 JTF_VARCHAR2_TABLE_500
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
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_DATE_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_DATE_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_NUMBER_TABLE
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_300
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_100
    , p5_a50 JTF_VARCHAR2_TABLE_100
    , p5_a51 JTF_NUMBER_TABLE
    , p5_a52 JTF_NUMBER_TABLE
    , p5_a53 JTF_NUMBER_TABLE
    , p5_a54 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tabv_tbl okl_trns_acc_dstrs_pub.tabv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tab_pvt_w.rosetta_table_copy_in_p5(ddp_tabv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_trns_acc_dstrs_pub.validate_trns_acc_dstrs(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tabv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_trns_acc_dstrs_pub_w;

/
