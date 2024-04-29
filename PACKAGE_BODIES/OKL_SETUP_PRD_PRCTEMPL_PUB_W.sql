--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_PRD_PRCTEMPL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_PRD_PRCTEMPL_PUB_W" as
  /* $Header: OKLUPPEB.pls 120.2 2005/10/30 04:49:29 appldev noship $ */
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

  procedure insert_prd_price_tmpls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_pitv_rec okl_setup_prd_prctempl_pub.pitv_rec_type;
    ddx_pitv_rec okl_setup_prd_prctempl_pub.pitv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pitv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pitv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pitv_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_pitv_rec.template_name := p5_a3;
    ddp_pitv_rec.template_path := p5_a4;
    ddp_pitv_rec.version := p5_a5;
    ddp_pitv_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pitv_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_pitv_rec.description := p5_a8;
    ddp_pitv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pitv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pitv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_pitv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_pitv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prd_prctempl_pub.insert_prd_price_tmpls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pitv_rec,
      ddx_pitv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pitv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pitv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_pitv_rec.pdt_id);
    p6_a3 := ddx_pitv_rec.template_name;
    p6_a4 := ddx_pitv_rec.template_path;
    p6_a5 := ddx_pitv_rec.version;
    p6_a6 := ddx_pitv_rec.start_date;
    p6_a7 := ddx_pitv_rec.end_date;
    p6_a8 := ddx_pitv_rec.description;
    p6_a9 := rosetta_g_miss_num_map(ddx_pitv_rec.created_by);
    p6_a10 := ddx_pitv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_pitv_rec.last_updated_by);
    p6_a12 := ddx_pitv_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_pitv_rec.last_update_login);
  end;

  procedure update_prd_price_tmpls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_pitv_rec okl_setup_prd_prctempl_pub.pitv_rec_type;
    ddx_pitv_rec okl_setup_prd_prctempl_pub.pitv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pitv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pitv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pitv_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_pitv_rec.template_name := p5_a3;
    ddp_pitv_rec.template_path := p5_a4;
    ddp_pitv_rec.version := p5_a5;
    ddp_pitv_rec.start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_pitv_rec.end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_pitv_rec.description := p5_a8;
    ddp_pitv_rec.created_by := rosetta_g_miss_num_map(p5_a9);
    ddp_pitv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_pitv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a11);
    ddp_pitv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a12);
    ddp_pitv_rec.last_update_login := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prd_prctempl_pub.update_prd_price_tmpls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pitv_rec,
      ddx_pitv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pitv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pitv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_pitv_rec.pdt_id);
    p6_a3 := ddx_pitv_rec.template_name;
    p6_a4 := ddx_pitv_rec.template_path;
    p6_a5 := ddx_pitv_rec.version;
    p6_a6 := ddx_pitv_rec.start_date;
    p6_a7 := ddx_pitv_rec.end_date;
    p6_a8 := ddx_pitv_rec.description;
    p6_a9 := rosetta_g_miss_num_map(ddx_pitv_rec.created_by);
    p6_a10 := ddx_pitv_rec.creation_date;
    p6_a11 := rosetta_g_miss_num_map(ddx_pitv_rec.last_updated_by);
    p6_a12 := ddx_pitv_rec.last_update_date;
    p6_a13 := rosetta_g_miss_num_map(ddx_pitv_rec.last_update_login);
  end;

  procedure insert_prd_price_tmpls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_400
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_pitv_tbl okl_setup_prd_prctempl_pub.pitv_tbl_type;
    ddx_pitv_tbl okl_setup_prd_prctempl_pub.pitv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pit_pvt_w.rosetta_table_copy_in_p5(ddp_pitv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prd_prctempl_pub.insert_prd_price_tmpls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pitv_tbl,
      ddx_pitv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pit_pvt_w.rosetta_table_copy_out_p5(ddx_pitv_tbl, p6_a0
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
      );
  end;

  procedure update_prd_price_tmpls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_400
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_DATE_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_pitv_tbl okl_setup_prd_prctempl_pub.pitv_tbl_type;
    ddx_pitv_tbl okl_setup_prd_prctempl_pub.pitv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pit_pvt_w.rosetta_table_copy_in_p5(ddp_pitv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prd_prctempl_pub.update_prd_price_tmpls(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pitv_tbl,
      ddx_pitv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pit_pvt_w.rosetta_table_copy_out_p5(ddx_pitv_tbl, p6_a0
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
      );
  end;

  procedure check_product_constraints(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_validated out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
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
    , p5_a29  DATE := fnd_api.g_miss_date
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  DATE := fnd_api.g_miss_date
    , p5_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_pdtv_rec okl_setup_prd_prctempl_pub.pdtv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pdtv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_pdtv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_pdtv_rec.aes_id := rosetta_g_miss_num_map(p5_a2);
    ddp_pdtv_rec.ptl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_pdtv_rec.name := p5_a4;
    ddp_pdtv_rec.description := p5_a5;
    ddp_pdtv_rec.reporting_pdt_id := rosetta_g_miss_num_map(p5_a6);
    ddp_pdtv_rec.product_status_code := p5_a7;
    ddp_pdtv_rec.legacy_product_yn := p5_a8;
    ddp_pdtv_rec.from_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_pdtv_rec.version := p5_a10;
    ddp_pdtv_rec.to_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_pdtv_rec.attribute_category := p5_a12;
    ddp_pdtv_rec.attribute1 := p5_a13;
    ddp_pdtv_rec.attribute2 := p5_a14;
    ddp_pdtv_rec.attribute3 := p5_a15;
    ddp_pdtv_rec.attribute4 := p5_a16;
    ddp_pdtv_rec.attribute5 := p5_a17;
    ddp_pdtv_rec.attribute6 := p5_a18;
    ddp_pdtv_rec.attribute7 := p5_a19;
    ddp_pdtv_rec.attribute8 := p5_a20;
    ddp_pdtv_rec.attribute9 := p5_a21;
    ddp_pdtv_rec.attribute10 := p5_a22;
    ddp_pdtv_rec.attribute11 := p5_a23;
    ddp_pdtv_rec.attribute12 := p5_a24;
    ddp_pdtv_rec.attribute13 := p5_a25;
    ddp_pdtv_rec.attribute14 := p5_a26;
    ddp_pdtv_rec.attribute15 := p5_a27;
    ddp_pdtv_rec.created_by := rosetta_g_miss_num_map(p5_a28);
    ddp_pdtv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a29);
    ddp_pdtv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a30);
    ddp_pdtv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a31);
    ddp_pdtv_rec.last_update_login := rosetta_g_miss_num_map(p5_a32);


    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prd_prctempl_pub.check_product_constraints(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec,
      x_validated);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_product_constraints(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_2000
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_DATE_TABLE
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
    , p5_a29 JTF_DATE_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_DATE_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , x_validated out nocopy  VARCHAR2
  )

  as
    ddp_pdtv_tbl okl_setup_prd_prctempl_pub.pdtv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pdt_pvt_w.rosetta_table_copy_in_p5(ddp_pdtv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_setup_prd_prctempl_pub.check_product_constraints(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_tbl,
      x_validated);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_setup_prd_prctempl_pub_w;

/
