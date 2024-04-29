--------------------------------------------------------
--  DDL for Package Body OKL_TBC_DEFINITIONS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TBC_DEFINITIONS_PUB_W" as
  /* $Header: OKLUTBCB.pls 120.6 2007/03/12 10:24:48 asawanka noship $ */
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

  procedure insert_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
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
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tbcv_rec okl_tbc_definitions_pub.tbcv_rec_type;
    ddx_tbcv_rec okl_tbc_definitions_pub.tbcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tbcv_rec.result_code := p5_a0;
    ddp_tbcv_rec.purchase_option_code := p5_a1;
    ddp_tbcv_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tbcv_rec.try_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tbcv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tbcv_rec.int_disclosed_code := p5_a5;
    ddp_tbcv_rec.title_trnsfr_code := p5_a6;
    ddp_tbcv_rec.sale_lease_back_code := p5_a7;
    ddp_tbcv_rec.lease_purchased_code := p5_a8;
    ddp_tbcv_rec.equip_usage_code := p5_a9;
    ddp_tbcv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tbcv_rec.age_of_equip_from := rosetta_g_miss_num_map(p5_a11);
    ddp_tbcv_rec.age_of_equip_to := rosetta_g_miss_num_map(p5_a12);
    ddp_tbcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_tbcv_rec.attribute_category := p5_a14;
    ddp_tbcv_rec.attribute1 := p5_a15;
    ddp_tbcv_rec.attribute2 := p5_a16;
    ddp_tbcv_rec.attribute3 := p5_a17;
    ddp_tbcv_rec.attribute4 := p5_a18;
    ddp_tbcv_rec.attribute5 := p5_a19;
    ddp_tbcv_rec.attribute6 := p5_a20;
    ddp_tbcv_rec.attribute7 := p5_a21;
    ddp_tbcv_rec.attribute8 := p5_a22;
    ddp_tbcv_rec.attribute9 := p5_a23;
    ddp_tbcv_rec.attribute10 := p5_a24;
    ddp_tbcv_rec.attribute11 := p5_a25;
    ddp_tbcv_rec.attribute12 := p5_a26;
    ddp_tbcv_rec.attribute13 := p5_a27;
    ddp_tbcv_rec.attribute14 := p5_a28;
    ddp_tbcv_rec.attribute15 := p5_a29;
    ddp_tbcv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_tbcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tbcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_tbcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tbcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_tbcv_rec.tax_attribute_def_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tbcv_rec.result_type_code := p5_a36;
    ddp_tbcv_rec.book_class_code := p5_a37;
    ddp_tbcv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a38);
    ddp_tbcv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tbcv_rec.tax_country_code := p5_a40;
    ddp_tbcv_rec.term_quote_type_code := p5_a41;
    ddp_tbcv_rec.term_quote_reason_code := p5_a42;
    ddp_tbcv_rec.expire_flag := p5_a43;


    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.insert_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_rec,
      ddx_tbcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_tbcv_rec.result_code;
    p6_a1 := ddx_tbcv_rec.purchase_option_code;
    p6_a2 := rosetta_g_miss_num_map(ddx_tbcv_rec.pdt_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_tbcv_rec.try_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tbcv_rec.sty_id);
    p6_a5 := ddx_tbcv_rec.int_disclosed_code;
    p6_a6 := ddx_tbcv_rec.title_trnsfr_code;
    p6_a7 := ddx_tbcv_rec.sale_lease_back_code;
    p6_a8 := ddx_tbcv_rec.lease_purchased_code;
    p6_a9 := ddx_tbcv_rec.equip_usage_code;
    p6_a10 := rosetta_g_miss_num_map(ddx_tbcv_rec.vendor_site_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tbcv_rec.age_of_equip_from);
    p6_a12 := rosetta_g_miss_num_map(ddx_tbcv_rec.age_of_equip_to);
    p6_a13 := rosetta_g_miss_num_map(ddx_tbcv_rec.object_version_number);
    p6_a14 := ddx_tbcv_rec.attribute_category;
    p6_a15 := ddx_tbcv_rec.attribute1;
    p6_a16 := ddx_tbcv_rec.attribute2;
    p6_a17 := ddx_tbcv_rec.attribute3;
    p6_a18 := ddx_tbcv_rec.attribute4;
    p6_a19 := ddx_tbcv_rec.attribute5;
    p6_a20 := ddx_tbcv_rec.attribute6;
    p6_a21 := ddx_tbcv_rec.attribute7;
    p6_a22 := ddx_tbcv_rec.attribute8;
    p6_a23 := ddx_tbcv_rec.attribute9;
    p6_a24 := ddx_tbcv_rec.attribute10;
    p6_a25 := ddx_tbcv_rec.attribute11;
    p6_a26 := ddx_tbcv_rec.attribute12;
    p6_a27 := ddx_tbcv_rec.attribute13;
    p6_a28 := ddx_tbcv_rec.attribute14;
    p6_a29 := ddx_tbcv_rec.attribute15;
    p6_a30 := rosetta_g_miss_num_map(ddx_tbcv_rec.created_by);
    p6_a31 := ddx_tbcv_rec.creation_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_tbcv_rec.last_updated_by);
    p6_a33 := ddx_tbcv_rec.last_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_tbcv_rec.last_update_login);
    p6_a35 := rosetta_g_miss_num_map(ddx_tbcv_rec.tax_attribute_def_id);
    p6_a36 := ddx_tbcv_rec.result_type_code;
    p6_a37 := ddx_tbcv_rec.book_class_code;
    p6_a38 := ddx_tbcv_rec.date_effective_from;
    p6_a39 := ddx_tbcv_rec.date_effective_to;
    p6_a40 := ddx_tbcv_rec.tax_country_code;
    p6_a41 := ddx_tbcv_rec.term_quote_type_code;
    p6_a42 := ddx_tbcv_rec.term_quote_reason_code;
    p6_a43 := ddx_tbcv_rec.expire_flag;
  end;

  procedure insert_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_300
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tbcv_tbl okl_tbc_definitions_pub.tbcv_tbl_type;
    ddx_tbcv_tbl okl_tbc_definitions_pub.tbcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tbc_pvt_w.rosetta_table_copy_in_p2(ddp_tbcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.insert_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_tbl,
      ddx_tbcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tbc_pvt_w.rosetta_table_copy_out_p2(ddx_tbcv_tbl, p6_a0
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
      );
  end;

  procedure lock_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tbcv_rec okl_tbc_definitions_pub.tbcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tbcv_rec.result_code := p5_a0;
    ddp_tbcv_rec.purchase_option_code := p5_a1;
    ddp_tbcv_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tbcv_rec.try_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tbcv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tbcv_rec.int_disclosed_code := p5_a5;
    ddp_tbcv_rec.title_trnsfr_code := p5_a6;
    ddp_tbcv_rec.sale_lease_back_code := p5_a7;
    ddp_tbcv_rec.lease_purchased_code := p5_a8;
    ddp_tbcv_rec.equip_usage_code := p5_a9;
    ddp_tbcv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tbcv_rec.age_of_equip_from := rosetta_g_miss_num_map(p5_a11);
    ddp_tbcv_rec.age_of_equip_to := rosetta_g_miss_num_map(p5_a12);
    ddp_tbcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_tbcv_rec.attribute_category := p5_a14;
    ddp_tbcv_rec.attribute1 := p5_a15;
    ddp_tbcv_rec.attribute2 := p5_a16;
    ddp_tbcv_rec.attribute3 := p5_a17;
    ddp_tbcv_rec.attribute4 := p5_a18;
    ddp_tbcv_rec.attribute5 := p5_a19;
    ddp_tbcv_rec.attribute6 := p5_a20;
    ddp_tbcv_rec.attribute7 := p5_a21;
    ddp_tbcv_rec.attribute8 := p5_a22;
    ddp_tbcv_rec.attribute9 := p5_a23;
    ddp_tbcv_rec.attribute10 := p5_a24;
    ddp_tbcv_rec.attribute11 := p5_a25;
    ddp_tbcv_rec.attribute12 := p5_a26;
    ddp_tbcv_rec.attribute13 := p5_a27;
    ddp_tbcv_rec.attribute14 := p5_a28;
    ddp_tbcv_rec.attribute15 := p5_a29;
    ddp_tbcv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_tbcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tbcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_tbcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tbcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_tbcv_rec.tax_attribute_def_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tbcv_rec.result_type_code := p5_a36;
    ddp_tbcv_rec.book_class_code := p5_a37;
    ddp_tbcv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a38);
    ddp_tbcv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tbcv_rec.tax_country_code := p5_a40;
    ddp_tbcv_rec.term_quote_type_code := p5_a41;
    ddp_tbcv_rec.term_quote_reason_code := p5_a42;
    ddp_tbcv_rec.expire_flag := p5_a43;

    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.lock_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_300
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tbcv_tbl okl_tbc_definitions_pub.tbcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tbc_pvt_w.rosetta_table_copy_in_p2(ddp_tbcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.lock_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
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
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  DATE
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  DATE
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tbcv_rec okl_tbc_definitions_pub.tbcv_rec_type;
    ddx_tbcv_rec okl_tbc_definitions_pub.tbcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tbcv_rec.result_code := p5_a0;
    ddp_tbcv_rec.purchase_option_code := p5_a1;
    ddp_tbcv_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tbcv_rec.try_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tbcv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tbcv_rec.int_disclosed_code := p5_a5;
    ddp_tbcv_rec.title_trnsfr_code := p5_a6;
    ddp_tbcv_rec.sale_lease_back_code := p5_a7;
    ddp_tbcv_rec.lease_purchased_code := p5_a8;
    ddp_tbcv_rec.equip_usage_code := p5_a9;
    ddp_tbcv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tbcv_rec.age_of_equip_from := rosetta_g_miss_num_map(p5_a11);
    ddp_tbcv_rec.age_of_equip_to := rosetta_g_miss_num_map(p5_a12);
    ddp_tbcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_tbcv_rec.attribute_category := p5_a14;
    ddp_tbcv_rec.attribute1 := p5_a15;
    ddp_tbcv_rec.attribute2 := p5_a16;
    ddp_tbcv_rec.attribute3 := p5_a17;
    ddp_tbcv_rec.attribute4 := p5_a18;
    ddp_tbcv_rec.attribute5 := p5_a19;
    ddp_tbcv_rec.attribute6 := p5_a20;
    ddp_tbcv_rec.attribute7 := p5_a21;
    ddp_tbcv_rec.attribute8 := p5_a22;
    ddp_tbcv_rec.attribute9 := p5_a23;
    ddp_tbcv_rec.attribute10 := p5_a24;
    ddp_tbcv_rec.attribute11 := p5_a25;
    ddp_tbcv_rec.attribute12 := p5_a26;
    ddp_tbcv_rec.attribute13 := p5_a27;
    ddp_tbcv_rec.attribute14 := p5_a28;
    ddp_tbcv_rec.attribute15 := p5_a29;
    ddp_tbcv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_tbcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tbcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_tbcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tbcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_tbcv_rec.tax_attribute_def_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tbcv_rec.result_type_code := p5_a36;
    ddp_tbcv_rec.book_class_code := p5_a37;
    ddp_tbcv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a38);
    ddp_tbcv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tbcv_rec.tax_country_code := p5_a40;
    ddp_tbcv_rec.term_quote_type_code := p5_a41;
    ddp_tbcv_rec.term_quote_reason_code := p5_a42;
    ddp_tbcv_rec.expire_flag := p5_a43;


    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.update_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_rec,
      ddx_tbcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_tbcv_rec.result_code;
    p6_a1 := ddx_tbcv_rec.purchase_option_code;
    p6_a2 := rosetta_g_miss_num_map(ddx_tbcv_rec.pdt_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_tbcv_rec.try_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_tbcv_rec.sty_id);
    p6_a5 := ddx_tbcv_rec.int_disclosed_code;
    p6_a6 := ddx_tbcv_rec.title_trnsfr_code;
    p6_a7 := ddx_tbcv_rec.sale_lease_back_code;
    p6_a8 := ddx_tbcv_rec.lease_purchased_code;
    p6_a9 := ddx_tbcv_rec.equip_usage_code;
    p6_a10 := rosetta_g_miss_num_map(ddx_tbcv_rec.vendor_site_id);
    p6_a11 := rosetta_g_miss_num_map(ddx_tbcv_rec.age_of_equip_from);
    p6_a12 := rosetta_g_miss_num_map(ddx_tbcv_rec.age_of_equip_to);
    p6_a13 := rosetta_g_miss_num_map(ddx_tbcv_rec.object_version_number);
    p6_a14 := ddx_tbcv_rec.attribute_category;
    p6_a15 := ddx_tbcv_rec.attribute1;
    p6_a16 := ddx_tbcv_rec.attribute2;
    p6_a17 := ddx_tbcv_rec.attribute3;
    p6_a18 := ddx_tbcv_rec.attribute4;
    p6_a19 := ddx_tbcv_rec.attribute5;
    p6_a20 := ddx_tbcv_rec.attribute6;
    p6_a21 := ddx_tbcv_rec.attribute7;
    p6_a22 := ddx_tbcv_rec.attribute8;
    p6_a23 := ddx_tbcv_rec.attribute9;
    p6_a24 := ddx_tbcv_rec.attribute10;
    p6_a25 := ddx_tbcv_rec.attribute11;
    p6_a26 := ddx_tbcv_rec.attribute12;
    p6_a27 := ddx_tbcv_rec.attribute13;
    p6_a28 := ddx_tbcv_rec.attribute14;
    p6_a29 := ddx_tbcv_rec.attribute15;
    p6_a30 := rosetta_g_miss_num_map(ddx_tbcv_rec.created_by);
    p6_a31 := ddx_tbcv_rec.creation_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_tbcv_rec.last_updated_by);
    p6_a33 := ddx_tbcv_rec.last_update_date;
    p6_a34 := rosetta_g_miss_num_map(ddx_tbcv_rec.last_update_login);
    p6_a35 := rosetta_g_miss_num_map(ddx_tbcv_rec.tax_attribute_def_id);
    p6_a36 := ddx_tbcv_rec.result_type_code;
    p6_a37 := ddx_tbcv_rec.book_class_code;
    p6_a38 := ddx_tbcv_rec.date_effective_from;
    p6_a39 := ddx_tbcv_rec.date_effective_to;
    p6_a40 := ddx_tbcv_rec.tax_country_code;
    p6_a41 := ddx_tbcv_rec.term_quote_type_code;
    p6_a42 := ddx_tbcv_rec.term_quote_reason_code;
    p6_a43 := ddx_tbcv_rec.expire_flag;
  end;

  procedure update_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_300
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_DATE_TABLE
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_DATE_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_DATE_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tbcv_tbl okl_tbc_definitions_pub.tbcv_tbl_type;
    ddx_tbcv_tbl okl_tbc_definitions_pub.tbcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tbc_pvt_w.rosetta_table_copy_in_p2(ddp_tbcv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.update_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_tbl,
      ddx_tbcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_tbc_pvt_w.rosetta_table_copy_out_p2(ddx_tbcv_tbl, p6_a0
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
      );
  end;

  procedure delete_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tbcv_rec okl_tbc_definitions_pub.tbcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tbcv_rec.result_code := p5_a0;
    ddp_tbcv_rec.purchase_option_code := p5_a1;
    ddp_tbcv_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tbcv_rec.try_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tbcv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tbcv_rec.int_disclosed_code := p5_a5;
    ddp_tbcv_rec.title_trnsfr_code := p5_a6;
    ddp_tbcv_rec.sale_lease_back_code := p5_a7;
    ddp_tbcv_rec.lease_purchased_code := p5_a8;
    ddp_tbcv_rec.equip_usage_code := p5_a9;
    ddp_tbcv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tbcv_rec.age_of_equip_from := rosetta_g_miss_num_map(p5_a11);
    ddp_tbcv_rec.age_of_equip_to := rosetta_g_miss_num_map(p5_a12);
    ddp_tbcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_tbcv_rec.attribute_category := p5_a14;
    ddp_tbcv_rec.attribute1 := p5_a15;
    ddp_tbcv_rec.attribute2 := p5_a16;
    ddp_tbcv_rec.attribute3 := p5_a17;
    ddp_tbcv_rec.attribute4 := p5_a18;
    ddp_tbcv_rec.attribute5 := p5_a19;
    ddp_tbcv_rec.attribute6 := p5_a20;
    ddp_tbcv_rec.attribute7 := p5_a21;
    ddp_tbcv_rec.attribute8 := p5_a22;
    ddp_tbcv_rec.attribute9 := p5_a23;
    ddp_tbcv_rec.attribute10 := p5_a24;
    ddp_tbcv_rec.attribute11 := p5_a25;
    ddp_tbcv_rec.attribute12 := p5_a26;
    ddp_tbcv_rec.attribute13 := p5_a27;
    ddp_tbcv_rec.attribute14 := p5_a28;
    ddp_tbcv_rec.attribute15 := p5_a29;
    ddp_tbcv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_tbcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tbcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_tbcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tbcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_tbcv_rec.tax_attribute_def_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tbcv_rec.result_type_code := p5_a36;
    ddp_tbcv_rec.book_class_code := p5_a37;
    ddp_tbcv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a38);
    ddp_tbcv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tbcv_rec.tax_country_code := p5_a40;
    ddp_tbcv_rec.term_quote_type_code := p5_a41;
    ddp_tbcv_rec.term_quote_reason_code := p5_a42;
    ddp_tbcv_rec.expire_flag := p5_a43;

    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.delete_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_300
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tbcv_tbl okl_tbc_definitions_pub.tbcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tbc_pvt_w.rosetta_table_copy_in_p2(ddp_tbcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.delete_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  DATE := fnd_api.g_miss_date
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  DATE := fnd_api.g_miss_date
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_tbcv_rec okl_tbc_definitions_pub.tbcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_tbcv_rec.result_code := p5_a0;
    ddp_tbcv_rec.purchase_option_code := p5_a1;
    ddp_tbcv_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_tbcv_rec.try_id := rosetta_g_miss_num_map(p5_a3);
    ddp_tbcv_rec.sty_id := rosetta_g_miss_num_map(p5_a4);
    ddp_tbcv_rec.int_disclosed_code := p5_a5;
    ddp_tbcv_rec.title_trnsfr_code := p5_a6;
    ddp_tbcv_rec.sale_lease_back_code := p5_a7;
    ddp_tbcv_rec.lease_purchased_code := p5_a8;
    ddp_tbcv_rec.equip_usage_code := p5_a9;
    ddp_tbcv_rec.vendor_site_id := rosetta_g_miss_num_map(p5_a10);
    ddp_tbcv_rec.age_of_equip_from := rosetta_g_miss_num_map(p5_a11);
    ddp_tbcv_rec.age_of_equip_to := rosetta_g_miss_num_map(p5_a12);
    ddp_tbcv_rec.object_version_number := rosetta_g_miss_num_map(p5_a13);
    ddp_tbcv_rec.attribute_category := p5_a14;
    ddp_tbcv_rec.attribute1 := p5_a15;
    ddp_tbcv_rec.attribute2 := p5_a16;
    ddp_tbcv_rec.attribute3 := p5_a17;
    ddp_tbcv_rec.attribute4 := p5_a18;
    ddp_tbcv_rec.attribute5 := p5_a19;
    ddp_tbcv_rec.attribute6 := p5_a20;
    ddp_tbcv_rec.attribute7 := p5_a21;
    ddp_tbcv_rec.attribute8 := p5_a22;
    ddp_tbcv_rec.attribute9 := p5_a23;
    ddp_tbcv_rec.attribute10 := p5_a24;
    ddp_tbcv_rec.attribute11 := p5_a25;
    ddp_tbcv_rec.attribute12 := p5_a26;
    ddp_tbcv_rec.attribute13 := p5_a27;
    ddp_tbcv_rec.attribute14 := p5_a28;
    ddp_tbcv_rec.attribute15 := p5_a29;
    ddp_tbcv_rec.created_by := rosetta_g_miss_num_map(p5_a30);
    ddp_tbcv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_tbcv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a32);
    ddp_tbcv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a33);
    ddp_tbcv_rec.last_update_login := rosetta_g_miss_num_map(p5_a34);
    ddp_tbcv_rec.tax_attribute_def_id := rosetta_g_miss_num_map(p5_a35);
    ddp_tbcv_rec.result_type_code := p5_a36;
    ddp_tbcv_rec.book_class_code := p5_a37;
    ddp_tbcv_rec.date_effective_from := rosetta_g_miss_date_in_map(p5_a38);
    ddp_tbcv_rec.date_effective_to := rosetta_g_miss_date_in_map(p5_a39);
    ddp_tbcv_rec.tax_country_code := p5_a40;
    ddp_tbcv_rec.term_quote_type_code := p5_a41;
    ddp_tbcv_rec.term_quote_reason_code := p5_a42;
    ddp_tbcv_rec.expire_flag := p5_a43;

    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.validate_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_tbc_definition(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_300
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , p5_a28 JTF_VARCHAR2_TABLE_500
    , p5_a29 JTF_VARCHAR2_TABLE_500
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_100
    , p5_a38 JTF_DATE_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_tbcv_tbl okl_tbc_definitions_pub.tbcv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_tbc_pvt_w.rosetta_table_copy_in_p2(ddp_tbcv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_tbc_definitions_pub.validate_tbc_definition(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_tbcv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_tbc_definitions_pub_w;

/
