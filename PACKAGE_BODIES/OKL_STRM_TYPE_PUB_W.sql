--------------------------------------------------------
--  DDL for Package Body OKL_STRM_TYPE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STRM_TYPE_PUB_W" as
  /* $Header: OKLUSTYB.pls 120.3 2008/01/29 17:23:14 gkadarka ship $ */
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

  procedure insert_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
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
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  NUMBER := 0-1962.0724
  )

  as
    ddp_styv_rec okl_strm_type_pub.styv_rec_type;
    ddx_styv_rec okl_strm_type_pub.styv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_styv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_styv_rec.name := p5_a1;
    ddp_styv_rec.version := p5_a2;
    ddp_styv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_styv_rec.code := p5_a4;
    ddp_styv_rec.sfwt_flag := p5_a5;
    ddp_styv_rec.stream_type_scope := p5_a6;
    ddp_styv_rec.description := p5_a7;
    ddp_styv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_styv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_styv_rec.billable_yn := p5_a10;
    ddp_styv_rec.taxable_default_yn := p5_a11;
    ddp_styv_rec.customization_level := p5_a12;
    ddp_styv_rec.stream_type_class := p5_a13;
    ddp_styv_rec.stream_type_subclass := p5_a14;
    ddp_styv_rec.accrual_yn := p5_a15;
    ddp_styv_rec.capitalize_yn := p5_a16;
    ddp_styv_rec.periodic_yn := p5_a17;
    ddp_styv_rec.fundable_yn := p5_a18;
    ddp_styv_rec.allocation_factor := p5_a19;
    ddp_styv_rec.attribute_category := p5_a20;
    ddp_styv_rec.attribute1 := p5_a21;
    ddp_styv_rec.attribute2 := p5_a22;
    ddp_styv_rec.attribute3 := p5_a23;
    ddp_styv_rec.attribute4 := p5_a24;
    ddp_styv_rec.attribute5 := p5_a25;
    ddp_styv_rec.attribute6 := p5_a26;
    ddp_styv_rec.attribute7 := p5_a27;
    ddp_styv_rec.attribute8 := p5_a28;
    ddp_styv_rec.attribute9 := p5_a29;
    ddp_styv_rec.attribute10 := p5_a30;
    ddp_styv_rec.attribute11 := p5_a31;
    ddp_styv_rec.attribute12 := p5_a32;
    ddp_styv_rec.attribute13 := p5_a33;
    ddp_styv_rec.attribute14 := p5_a34;
    ddp_styv_rec.attribute15 := p5_a35;
    ddp_styv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_styv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_styv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_styv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_styv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_styv_rec.stream_type_purpose := p5_a41;
    ddp_styv_rec.contingency := p5_a42;
    ddp_styv_rec.short_description := p5_a43;
    ddp_styv_rec.contingency_id := rosetta_g_miss_num_map(p5_a44);


    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.insert_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_rec,
      ddx_styv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_styv_rec.id);
    p6_a1 := ddx_styv_rec.name;
    p6_a2 := ddx_styv_rec.version;
    p6_a3 := rosetta_g_miss_num_map(ddx_styv_rec.object_version_number);
    p6_a4 := ddx_styv_rec.code;
    p6_a5 := ddx_styv_rec.sfwt_flag;
    p6_a6 := ddx_styv_rec.stream_type_scope;
    p6_a7 := ddx_styv_rec.description;
    p6_a8 := ddx_styv_rec.start_date;
    p6_a9 := ddx_styv_rec.end_date;
    p6_a10 := ddx_styv_rec.billable_yn;
    p6_a11 := ddx_styv_rec.taxable_default_yn;
    p6_a12 := ddx_styv_rec.customization_level;
    p6_a13 := ddx_styv_rec.stream_type_class;
    p6_a14 := ddx_styv_rec.stream_type_subclass;
    p6_a15 := ddx_styv_rec.accrual_yn;
    p6_a16 := ddx_styv_rec.capitalize_yn;
    p6_a17 := ddx_styv_rec.periodic_yn;
    p6_a18 := ddx_styv_rec.fundable_yn;
    p6_a19 := ddx_styv_rec.allocation_factor;
    p6_a20 := ddx_styv_rec.attribute_category;
    p6_a21 := ddx_styv_rec.attribute1;
    p6_a22 := ddx_styv_rec.attribute2;
    p6_a23 := ddx_styv_rec.attribute3;
    p6_a24 := ddx_styv_rec.attribute4;
    p6_a25 := ddx_styv_rec.attribute5;
    p6_a26 := ddx_styv_rec.attribute6;
    p6_a27 := ddx_styv_rec.attribute7;
    p6_a28 := ddx_styv_rec.attribute8;
    p6_a29 := ddx_styv_rec.attribute9;
    p6_a30 := ddx_styv_rec.attribute10;
    p6_a31 := ddx_styv_rec.attribute11;
    p6_a32 := ddx_styv_rec.attribute12;
    p6_a33 := ddx_styv_rec.attribute13;
    p6_a34 := ddx_styv_rec.attribute14;
    p6_a35 := ddx_styv_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddx_styv_rec.created_by);
    p6_a37 := ddx_styv_rec.creation_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_styv_rec.last_updated_by);
    p6_a39 := ddx_styv_rec.last_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_styv_rec.last_update_login);
    p6_a41 := ddx_styv_rec.stream_type_purpose;
    p6_a42 := ddx_styv_rec.contingency;
    p6_a43 := ddx_styv_rec.short_description;
    p6_a44 := rosetta_g_miss_num_map(ddx_styv_rec.contingency_id);
  end;

  procedure insert_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_600
    , p5_a44 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a44 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_styv_tbl okl_strm_type_pub.styv_tbl_type;
    ddx_styv_tbl okl_strm_type_pub.styv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sty_pvt_w.rosetta_table_copy_in_p8(ddp_styv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.insert_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_tbl,
      ddx_styv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sty_pvt_w.rosetta_table_copy_out_p8(ddx_styv_tbl, p6_a0
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
      );
  end;

  procedure lock_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  NUMBER := 0-1962.0724
  )

  as
    ddp_styv_rec okl_strm_type_pub.styv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_styv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_styv_rec.name := p5_a1;
    ddp_styv_rec.version := p5_a2;
    ddp_styv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_styv_rec.code := p5_a4;
    ddp_styv_rec.sfwt_flag := p5_a5;
    ddp_styv_rec.stream_type_scope := p5_a6;
    ddp_styv_rec.description := p5_a7;
    ddp_styv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_styv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_styv_rec.billable_yn := p5_a10;
    ddp_styv_rec.taxable_default_yn := p5_a11;
    ddp_styv_rec.customization_level := p5_a12;
    ddp_styv_rec.stream_type_class := p5_a13;
    ddp_styv_rec.stream_type_subclass := p5_a14;
    ddp_styv_rec.accrual_yn := p5_a15;
    ddp_styv_rec.capitalize_yn := p5_a16;
    ddp_styv_rec.periodic_yn := p5_a17;
    ddp_styv_rec.fundable_yn := p5_a18;
    ddp_styv_rec.allocation_factor := p5_a19;
    ddp_styv_rec.attribute_category := p5_a20;
    ddp_styv_rec.attribute1 := p5_a21;
    ddp_styv_rec.attribute2 := p5_a22;
    ddp_styv_rec.attribute3 := p5_a23;
    ddp_styv_rec.attribute4 := p5_a24;
    ddp_styv_rec.attribute5 := p5_a25;
    ddp_styv_rec.attribute6 := p5_a26;
    ddp_styv_rec.attribute7 := p5_a27;
    ddp_styv_rec.attribute8 := p5_a28;
    ddp_styv_rec.attribute9 := p5_a29;
    ddp_styv_rec.attribute10 := p5_a30;
    ddp_styv_rec.attribute11 := p5_a31;
    ddp_styv_rec.attribute12 := p5_a32;
    ddp_styv_rec.attribute13 := p5_a33;
    ddp_styv_rec.attribute14 := p5_a34;
    ddp_styv_rec.attribute15 := p5_a35;
    ddp_styv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_styv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_styv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_styv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_styv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_styv_rec.stream_type_purpose := p5_a41;
    ddp_styv_rec.contingency := p5_a42;
    ddp_styv_rec.short_description := p5_a43;
    ddp_styv_rec.contingency_id := rosetta_g_miss_num_map(p5_a44);

    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.lock_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_600
    , p5_a44 JTF_NUMBER_TABLE
  )

  as
    ddp_styv_tbl okl_strm_type_pub.styv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sty_pvt_w.rosetta_table_copy_in_p8(ddp_styv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.lock_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  DATE
    , p6_a9 out nocopy  DATE
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
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  DATE
    , p6_a40 out nocopy  NUMBER
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  NUMBER := 0-1962.0724
  )

  as
    ddp_styv_rec okl_strm_type_pub.styv_rec_type;
    ddx_styv_rec okl_strm_type_pub.styv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_styv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_styv_rec.name := p5_a1;
    ddp_styv_rec.version := p5_a2;
    ddp_styv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_styv_rec.code := p5_a4;
    ddp_styv_rec.sfwt_flag := p5_a5;
    ddp_styv_rec.stream_type_scope := p5_a6;
    ddp_styv_rec.description := p5_a7;
    ddp_styv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_styv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_styv_rec.billable_yn := p5_a10;
    ddp_styv_rec.taxable_default_yn := p5_a11;
    ddp_styv_rec.customization_level := p5_a12;
    ddp_styv_rec.stream_type_class := p5_a13;
    ddp_styv_rec.stream_type_subclass := p5_a14;
    ddp_styv_rec.accrual_yn := p5_a15;
    ddp_styv_rec.capitalize_yn := p5_a16;
    ddp_styv_rec.periodic_yn := p5_a17;
    ddp_styv_rec.fundable_yn := p5_a18;
    ddp_styv_rec.allocation_factor := p5_a19;
    ddp_styv_rec.attribute_category := p5_a20;
    ddp_styv_rec.attribute1 := p5_a21;
    ddp_styv_rec.attribute2 := p5_a22;
    ddp_styv_rec.attribute3 := p5_a23;
    ddp_styv_rec.attribute4 := p5_a24;
    ddp_styv_rec.attribute5 := p5_a25;
    ddp_styv_rec.attribute6 := p5_a26;
    ddp_styv_rec.attribute7 := p5_a27;
    ddp_styv_rec.attribute8 := p5_a28;
    ddp_styv_rec.attribute9 := p5_a29;
    ddp_styv_rec.attribute10 := p5_a30;
    ddp_styv_rec.attribute11 := p5_a31;
    ddp_styv_rec.attribute12 := p5_a32;
    ddp_styv_rec.attribute13 := p5_a33;
    ddp_styv_rec.attribute14 := p5_a34;
    ddp_styv_rec.attribute15 := p5_a35;
    ddp_styv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_styv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_styv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_styv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_styv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_styv_rec.stream_type_purpose := p5_a41;
    ddp_styv_rec.contingency := p5_a42;
    ddp_styv_rec.short_description := p5_a43;
    ddp_styv_rec.contingency_id := rosetta_g_miss_num_map(p5_a44);


    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.update_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_rec,
      ddx_styv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_styv_rec.id);
    p6_a1 := ddx_styv_rec.name;
    p6_a2 := ddx_styv_rec.version;
    p6_a3 := rosetta_g_miss_num_map(ddx_styv_rec.object_version_number);
    p6_a4 := ddx_styv_rec.code;
    p6_a5 := ddx_styv_rec.sfwt_flag;
    p6_a6 := ddx_styv_rec.stream_type_scope;
    p6_a7 := ddx_styv_rec.description;
    p6_a8 := ddx_styv_rec.start_date;
    p6_a9 := ddx_styv_rec.end_date;
    p6_a10 := ddx_styv_rec.billable_yn;
    p6_a11 := ddx_styv_rec.taxable_default_yn;
    p6_a12 := ddx_styv_rec.customization_level;
    p6_a13 := ddx_styv_rec.stream_type_class;
    p6_a14 := ddx_styv_rec.stream_type_subclass;
    p6_a15 := ddx_styv_rec.accrual_yn;
    p6_a16 := ddx_styv_rec.capitalize_yn;
    p6_a17 := ddx_styv_rec.periodic_yn;
    p6_a18 := ddx_styv_rec.fundable_yn;
    p6_a19 := ddx_styv_rec.allocation_factor;
    p6_a20 := ddx_styv_rec.attribute_category;
    p6_a21 := ddx_styv_rec.attribute1;
    p6_a22 := ddx_styv_rec.attribute2;
    p6_a23 := ddx_styv_rec.attribute3;
    p6_a24 := ddx_styv_rec.attribute4;
    p6_a25 := ddx_styv_rec.attribute5;
    p6_a26 := ddx_styv_rec.attribute6;
    p6_a27 := ddx_styv_rec.attribute7;
    p6_a28 := ddx_styv_rec.attribute8;
    p6_a29 := ddx_styv_rec.attribute9;
    p6_a30 := ddx_styv_rec.attribute10;
    p6_a31 := ddx_styv_rec.attribute11;
    p6_a32 := ddx_styv_rec.attribute12;
    p6_a33 := ddx_styv_rec.attribute13;
    p6_a34 := ddx_styv_rec.attribute14;
    p6_a35 := ddx_styv_rec.attribute15;
    p6_a36 := rosetta_g_miss_num_map(ddx_styv_rec.created_by);
    p6_a37 := ddx_styv_rec.creation_date;
    p6_a38 := rosetta_g_miss_num_map(ddx_styv_rec.last_updated_by);
    p6_a39 := ddx_styv_rec.last_update_date;
    p6_a40 := rosetta_g_miss_num_map(ddx_styv_rec.last_update_login);
    p6_a41 := ddx_styv_rec.stream_type_purpose;
    p6_a42 := ddx_styv_rec.contingency;
    p6_a43 := ddx_styv_rec.short_description;
    p6_a44 := rosetta_g_miss_num_map(ddx_styv_rec.contingency_id);
  end;

  procedure update_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_600
    , p5_a44 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a8 out nocopy JTF_DATE_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_DATE_TABLE
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a44 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_styv_tbl okl_strm_type_pub.styv_tbl_type;
    ddx_styv_tbl okl_strm_type_pub.styv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sty_pvt_w.rosetta_table_copy_in_p8(ddp_styv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.update_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_tbl,
      ddx_styv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_sty_pvt_w.rosetta_table_copy_out_p8(ddx_styv_tbl, p6_a0
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
      );
  end;

  procedure delete_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  NUMBER := 0-1962.0724
  )

  as
    ddp_styv_rec okl_strm_type_pub.styv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_styv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_styv_rec.name := p5_a1;
    ddp_styv_rec.version := p5_a2;
    ddp_styv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_styv_rec.code := p5_a4;
    ddp_styv_rec.sfwt_flag := p5_a5;
    ddp_styv_rec.stream_type_scope := p5_a6;
    ddp_styv_rec.description := p5_a7;
    ddp_styv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_styv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_styv_rec.billable_yn := p5_a10;
    ddp_styv_rec.taxable_default_yn := p5_a11;
    ddp_styv_rec.customization_level := p5_a12;
    ddp_styv_rec.stream_type_class := p5_a13;
    ddp_styv_rec.stream_type_subclass := p5_a14;
    ddp_styv_rec.accrual_yn := p5_a15;
    ddp_styv_rec.capitalize_yn := p5_a16;
    ddp_styv_rec.periodic_yn := p5_a17;
    ddp_styv_rec.fundable_yn := p5_a18;
    ddp_styv_rec.allocation_factor := p5_a19;
    ddp_styv_rec.attribute_category := p5_a20;
    ddp_styv_rec.attribute1 := p5_a21;
    ddp_styv_rec.attribute2 := p5_a22;
    ddp_styv_rec.attribute3 := p5_a23;
    ddp_styv_rec.attribute4 := p5_a24;
    ddp_styv_rec.attribute5 := p5_a25;
    ddp_styv_rec.attribute6 := p5_a26;
    ddp_styv_rec.attribute7 := p5_a27;
    ddp_styv_rec.attribute8 := p5_a28;
    ddp_styv_rec.attribute9 := p5_a29;
    ddp_styv_rec.attribute10 := p5_a30;
    ddp_styv_rec.attribute11 := p5_a31;
    ddp_styv_rec.attribute12 := p5_a32;
    ddp_styv_rec.attribute13 := p5_a33;
    ddp_styv_rec.attribute14 := p5_a34;
    ddp_styv_rec.attribute15 := p5_a35;
    ddp_styv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_styv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_styv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_styv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_styv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_styv_rec.stream_type_purpose := p5_a41;
    ddp_styv_rec.contingency := p5_a42;
    ddp_styv_rec.short_description := p5_a43;
    ddp_styv_rec.contingency_id := rosetta_g_miss_num_map(p5_a44);

    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.delete_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_600
    , p5_a44 JTF_NUMBER_TABLE
  )

  as
    ddp_styv_tbl okl_strm_type_pub.styv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sty_pvt_w.rosetta_table_copy_in_p8(ddp_styv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.delete_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  DATE := fnd_api.g_miss_date
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  NUMBER := 0-1962.0724
  )

  as
    ddp_styv_rec okl_strm_type_pub.styv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_styv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_styv_rec.name := p5_a1;
    ddp_styv_rec.version := p5_a2;
    ddp_styv_rec.object_version_number := rosetta_g_miss_num_map(p5_a3);
    ddp_styv_rec.code := p5_a4;
    ddp_styv_rec.sfwt_flag := p5_a5;
    ddp_styv_rec.stream_type_scope := p5_a6;
    ddp_styv_rec.description := p5_a7;
    ddp_styv_rec.start_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_styv_rec.end_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_styv_rec.billable_yn := p5_a10;
    ddp_styv_rec.taxable_default_yn := p5_a11;
    ddp_styv_rec.customization_level := p5_a12;
    ddp_styv_rec.stream_type_class := p5_a13;
    ddp_styv_rec.stream_type_subclass := p5_a14;
    ddp_styv_rec.accrual_yn := p5_a15;
    ddp_styv_rec.capitalize_yn := p5_a16;
    ddp_styv_rec.periodic_yn := p5_a17;
    ddp_styv_rec.fundable_yn := p5_a18;
    ddp_styv_rec.allocation_factor := p5_a19;
    ddp_styv_rec.attribute_category := p5_a20;
    ddp_styv_rec.attribute1 := p5_a21;
    ddp_styv_rec.attribute2 := p5_a22;
    ddp_styv_rec.attribute3 := p5_a23;
    ddp_styv_rec.attribute4 := p5_a24;
    ddp_styv_rec.attribute5 := p5_a25;
    ddp_styv_rec.attribute6 := p5_a26;
    ddp_styv_rec.attribute7 := p5_a27;
    ddp_styv_rec.attribute8 := p5_a28;
    ddp_styv_rec.attribute9 := p5_a29;
    ddp_styv_rec.attribute10 := p5_a30;
    ddp_styv_rec.attribute11 := p5_a31;
    ddp_styv_rec.attribute12 := p5_a32;
    ddp_styv_rec.attribute13 := p5_a33;
    ddp_styv_rec.attribute14 := p5_a34;
    ddp_styv_rec.attribute15 := p5_a35;
    ddp_styv_rec.created_by := rosetta_g_miss_num_map(p5_a36);
    ddp_styv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_styv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a38);
    ddp_styv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a39);
    ddp_styv_rec.last_update_login := rosetta_g_miss_num_map(p5_a40);
    ddp_styv_rec.stream_type_purpose := p5_a41;
    ddp_styv_rec.contingency := p5_a42;
    ddp_styv_rec.short_description := p5_a43;
    ddp_styv_rec.contingency_id := rosetta_g_miss_num_map(p5_a44);

    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.validate_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_strm_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
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
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_DATE_TABLE
    , p5_a40 JTF_NUMBER_TABLE
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_600
    , p5_a44 JTF_NUMBER_TABLE
  )

  as
    ddp_styv_tbl okl_strm_type_pub.styv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_sty_pvt_w.rosetta_table_copy_in_p8(ddp_styv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_strm_type_pub.validate_strm_type(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_styv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_strm_type_pub_w;

/
