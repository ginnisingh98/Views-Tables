--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPRODUCTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPRODUCTS_PUB_W" as
  /* $Header: OKLUSPDB.pls 120.1 2005/10/07 05:46:33 dkagrawa noship $ */
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

  procedure get_rec(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  NUMBER
    , p4_a2 out nocopy  NUMBER
    , p4_a3 out nocopy  NUMBER
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  NUMBER
    , p4_a7 out nocopy  VARCHAR2
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  DATE
    , p4_a10 out nocopy  VARCHAR2
    , p4_a11 out nocopy  DATE
    , p4_a12 out nocopy  VARCHAR2
    , p4_a13 out nocopy  VARCHAR2
    , p4_a14 out nocopy  VARCHAR2
    , p4_a15 out nocopy  VARCHAR2
    , p4_a16 out nocopy  VARCHAR2
    , p4_a17 out nocopy  VARCHAR2
    , p4_a18 out nocopy  VARCHAR2
    , p4_a19 out nocopy  VARCHAR2
    , p4_a20 out nocopy  VARCHAR2
    , p4_a21 out nocopy  VARCHAR2
    , p4_a22 out nocopy  VARCHAR2
    , p4_a23 out nocopy  VARCHAR2
    , p4_a24 out nocopy  VARCHAR2
    , p4_a25 out nocopy  VARCHAR2
    , p4_a26 out nocopy  VARCHAR2
    , p4_a27 out nocopy  VARCHAR2
    , p4_a28 out nocopy  NUMBER
    , p4_a29 out nocopy  DATE
    , p4_a30 out nocopy  NUMBER
    , p4_a31 out nocopy  DATE
    , p4_a32 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  DATE := fnd_api.g_miss_date
    , p0_a32  NUMBER := 0-1962.0724
  )

  as
    ddp_pdtv_rec okl_setupproducts_pub.pdtv_rec_type;
    ddx_no_data_found boolean;
    ddx_pdtv_rec okl_setupproducts_pub.pdtv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pdtv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_pdtv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_pdtv_rec.aes_id := rosetta_g_miss_num_map(p0_a2);
    ddp_pdtv_rec.ptl_id := rosetta_g_miss_num_map(p0_a3);
    ddp_pdtv_rec.name := p0_a4;
    ddp_pdtv_rec.description := p0_a5;
    ddp_pdtv_rec.reporting_pdt_id := rosetta_g_miss_num_map(p0_a6);
    ddp_pdtv_rec.product_status_code := p0_a7;
    ddp_pdtv_rec.legacy_product_yn := p0_a8;
    ddp_pdtv_rec.from_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_pdtv_rec.version := p0_a10;
    ddp_pdtv_rec.to_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_pdtv_rec.attribute_category := p0_a12;
    ddp_pdtv_rec.attribute1 := p0_a13;
    ddp_pdtv_rec.attribute2 := p0_a14;
    ddp_pdtv_rec.attribute3 := p0_a15;
    ddp_pdtv_rec.attribute4 := p0_a16;
    ddp_pdtv_rec.attribute5 := p0_a17;
    ddp_pdtv_rec.attribute6 := p0_a18;
    ddp_pdtv_rec.attribute7 := p0_a19;
    ddp_pdtv_rec.attribute8 := p0_a20;
    ddp_pdtv_rec.attribute9 := p0_a21;
    ddp_pdtv_rec.attribute10 := p0_a22;
    ddp_pdtv_rec.attribute11 := p0_a23;
    ddp_pdtv_rec.attribute12 := p0_a24;
    ddp_pdtv_rec.attribute13 := p0_a25;
    ddp_pdtv_rec.attribute14 := p0_a26;
    ddp_pdtv_rec.attribute15 := p0_a27;
    ddp_pdtv_rec.created_by := rosetta_g_miss_num_map(p0_a28);
    ddp_pdtv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_pdtv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a30);
    ddp_pdtv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a31);
    ddp_pdtv_rec.last_update_login := rosetta_g_miss_num_map(p0_a32);





    -- here's the delegated call to the old PL/SQL routine
    okl_setupproducts_pub.get_rec(ddp_pdtv_rec,
      x_return_status,
      x_msg_data,
      ddx_no_data_found,
      ddx_pdtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p4_a0 := rosetta_g_miss_num_map(ddx_pdtv_rec.id);
    p4_a1 := rosetta_g_miss_num_map(ddx_pdtv_rec.object_version_number);
    p4_a2 := rosetta_g_miss_num_map(ddx_pdtv_rec.aes_id);
    p4_a3 := rosetta_g_miss_num_map(ddx_pdtv_rec.ptl_id);
    p4_a4 := ddx_pdtv_rec.name;
    p4_a5 := ddx_pdtv_rec.description;
    p4_a6 := rosetta_g_miss_num_map(ddx_pdtv_rec.reporting_pdt_id);
    p4_a7 := ddx_pdtv_rec.product_status_code;
    p4_a8 := ddx_pdtv_rec.legacy_product_yn;
    p4_a9 := ddx_pdtv_rec.from_date;
    p4_a10 := ddx_pdtv_rec.version;
    p4_a11 := ddx_pdtv_rec.to_date;
    p4_a12 := ddx_pdtv_rec.attribute_category;
    p4_a13 := ddx_pdtv_rec.attribute1;
    p4_a14 := ddx_pdtv_rec.attribute2;
    p4_a15 := ddx_pdtv_rec.attribute3;
    p4_a16 := ddx_pdtv_rec.attribute4;
    p4_a17 := ddx_pdtv_rec.attribute5;
    p4_a18 := ddx_pdtv_rec.attribute6;
    p4_a19 := ddx_pdtv_rec.attribute7;
    p4_a20 := ddx_pdtv_rec.attribute8;
    p4_a21 := ddx_pdtv_rec.attribute9;
    p4_a22 := ddx_pdtv_rec.attribute10;
    p4_a23 := ddx_pdtv_rec.attribute11;
    p4_a24 := ddx_pdtv_rec.attribute12;
    p4_a25 := ddx_pdtv_rec.attribute13;
    p4_a26 := ddx_pdtv_rec.attribute14;
    p4_a27 := ddx_pdtv_rec.attribute15;
    p4_a28 := rosetta_g_miss_num_map(ddx_pdtv_rec.created_by);
    p4_a29 := ddx_pdtv_rec.creation_date;
    p4_a30 := rosetta_g_miss_num_map(ddx_pdtv_rec.last_updated_by);
    p4_a31 := ddx_pdtv_rec.last_update_date;
    p4_a32 := rosetta_g_miss_num_map(ddx_pdtv_rec.last_update_login);
  end;

  procedure getpdt_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_product_date  date
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  DATE
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  NUMBER
    , p8_a31 out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  DATE := fnd_api.g_miss_date
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  DATE := fnd_api.g_miss_date
    , p6_a32  NUMBER := 0-1962.0724
  )

  as
    ddx_no_data_found boolean;
    ddp_pdtv_rec okl_setupproducts_pub.pdtv_rec_type;
    ddp_product_date date;
    ddp_pdt_parameter_rec okl_setupproducts_pub.pdt_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_pdtv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_pdtv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_pdtv_rec.aes_id := rosetta_g_miss_num_map(p6_a2);
    ddp_pdtv_rec.ptl_id := rosetta_g_miss_num_map(p6_a3);
    ddp_pdtv_rec.name := p6_a4;
    ddp_pdtv_rec.description := p6_a5;
    ddp_pdtv_rec.reporting_pdt_id := rosetta_g_miss_num_map(p6_a6);
    ddp_pdtv_rec.product_status_code := p6_a7;
    ddp_pdtv_rec.legacy_product_yn := p6_a8;
    ddp_pdtv_rec.from_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_pdtv_rec.version := p6_a10;
    ddp_pdtv_rec.to_date := rosetta_g_miss_date_in_map(p6_a11);
    ddp_pdtv_rec.attribute_category := p6_a12;
    ddp_pdtv_rec.attribute1 := p6_a13;
    ddp_pdtv_rec.attribute2 := p6_a14;
    ddp_pdtv_rec.attribute3 := p6_a15;
    ddp_pdtv_rec.attribute4 := p6_a16;
    ddp_pdtv_rec.attribute5 := p6_a17;
    ddp_pdtv_rec.attribute6 := p6_a18;
    ddp_pdtv_rec.attribute7 := p6_a19;
    ddp_pdtv_rec.attribute8 := p6_a20;
    ddp_pdtv_rec.attribute9 := p6_a21;
    ddp_pdtv_rec.attribute10 := p6_a22;
    ddp_pdtv_rec.attribute11 := p6_a23;
    ddp_pdtv_rec.attribute12 := p6_a24;
    ddp_pdtv_rec.attribute13 := p6_a25;
    ddp_pdtv_rec.attribute14 := p6_a26;
    ddp_pdtv_rec.attribute15 := p6_a27;
    ddp_pdtv_rec.created_by := rosetta_g_miss_num_map(p6_a28);
    ddp_pdtv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a29);
    ddp_pdtv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a30);
    ddp_pdtv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a31);
    ddp_pdtv_rec.last_update_login := rosetta_g_miss_num_map(p6_a32);

    ddp_product_date := rosetta_g_miss_date_in_map(p_product_date);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupproducts_pub.getpdt_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      ddx_no_data_found,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec,
      ddp_product_date,
      ddp_pdt_parameter_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;





    p8_a0 := rosetta_g_miss_num_map(ddp_pdt_parameter_rec.id);
    p8_a1 := ddp_pdt_parameter_rec.name;
    p8_a2 := ddp_pdt_parameter_rec.from_date;
    p8_a3 := ddp_pdt_parameter_rec.to_date;
    p8_a4 := ddp_pdt_parameter_rec.version;
    p8_a5 := rosetta_g_miss_num_map(ddp_pdt_parameter_rec.object_version_number);
    p8_a6 := rosetta_g_miss_num_map(ddp_pdt_parameter_rec.aes_id);
    p8_a7 := rosetta_g_miss_num_map(ddp_pdt_parameter_rec.ptl_id);
    p8_a8 := ddp_pdt_parameter_rec.legacy_product_yn;
    p8_a9 := ddp_pdt_parameter_rec.attribute_category;
    p8_a10 := ddp_pdt_parameter_rec.attribute1;
    p8_a11 := ddp_pdt_parameter_rec.attribute2;
    p8_a12 := ddp_pdt_parameter_rec.attribute3;
    p8_a13 := ddp_pdt_parameter_rec.attribute4;
    p8_a14 := ddp_pdt_parameter_rec.attribute5;
    p8_a15 := ddp_pdt_parameter_rec.attribute6;
    p8_a16 := ddp_pdt_parameter_rec.attribute7;
    p8_a17 := ddp_pdt_parameter_rec.attribute8;
    p8_a18 := ddp_pdt_parameter_rec.attribute9;
    p8_a19 := ddp_pdt_parameter_rec.attribute10;
    p8_a20 := ddp_pdt_parameter_rec.attribute11;
    p8_a21 := ddp_pdt_parameter_rec.attribute12;
    p8_a22 := ddp_pdt_parameter_rec.attribute13;
    p8_a23 := ddp_pdt_parameter_rec.attribute14;
    p8_a24 := ddp_pdt_parameter_rec.attribute15;
    p8_a25 := ddp_pdt_parameter_rec.product_subclass;
    p8_a26 := ddp_pdt_parameter_rec.deal_type;
    p8_a27 := ddp_pdt_parameter_rec.tax_owner;
    p8_a28 := ddp_pdt_parameter_rec.revenue_recognition_method;
    p8_a29 := ddp_pdt_parameter_rec.interest_calculation_basis;
    p8_a30 := rosetta_g_miss_num_map(ddp_pdt_parameter_rec.reporting_pdt_id);
    p8_a31 := ddp_pdt_parameter_rec.reporting_product;
  end;

  procedure insert_products(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
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
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
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
    ddp_pdtv_rec okl_setupproducts_pub.pdtv_rec_type;
    ddx_pdtv_rec okl_setupproducts_pub.pdtv_rec_type;
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
    okl_setupproducts_pub.insert_products(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec,
      ddx_pdtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pdtv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pdtv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_pdtv_rec.aes_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_pdtv_rec.ptl_id);
    p6_a4 := ddx_pdtv_rec.name;
    p6_a5 := ddx_pdtv_rec.description;
    p6_a6 := rosetta_g_miss_num_map(ddx_pdtv_rec.reporting_pdt_id);
    p6_a7 := ddx_pdtv_rec.product_status_code;
    p6_a8 := ddx_pdtv_rec.legacy_product_yn;
    p6_a9 := ddx_pdtv_rec.from_date;
    p6_a10 := ddx_pdtv_rec.version;
    p6_a11 := ddx_pdtv_rec.to_date;
    p6_a12 := ddx_pdtv_rec.attribute_category;
    p6_a13 := ddx_pdtv_rec.attribute1;
    p6_a14 := ddx_pdtv_rec.attribute2;
    p6_a15 := ddx_pdtv_rec.attribute3;
    p6_a16 := ddx_pdtv_rec.attribute4;
    p6_a17 := ddx_pdtv_rec.attribute5;
    p6_a18 := ddx_pdtv_rec.attribute6;
    p6_a19 := ddx_pdtv_rec.attribute7;
    p6_a20 := ddx_pdtv_rec.attribute8;
    p6_a21 := ddx_pdtv_rec.attribute9;
    p6_a22 := ddx_pdtv_rec.attribute10;
    p6_a23 := ddx_pdtv_rec.attribute11;
    p6_a24 := ddx_pdtv_rec.attribute12;
    p6_a25 := ddx_pdtv_rec.attribute13;
    p6_a26 := ddx_pdtv_rec.attribute14;
    p6_a27 := ddx_pdtv_rec.attribute15;
    p6_a28 := rosetta_g_miss_num_map(ddx_pdtv_rec.created_by);
    p6_a29 := ddx_pdtv_rec.creation_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_pdtv_rec.last_updated_by);
    p6_a31 := ddx_pdtv_rec.last_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_pdtv_rec.last_update_login);
  end;

  procedure update_products(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
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
    , p6_a29 out nocopy  DATE
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  DATE
    , p6_a32 out nocopy  NUMBER
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
    ddp_pdtv_rec okl_setupproducts_pub.pdtv_rec_type;
    ddx_pdtv_rec okl_setupproducts_pub.pdtv_rec_type;
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
    okl_setupproducts_pub.update_products(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec,
      ddx_pdtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pdtv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_pdtv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_pdtv_rec.aes_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_pdtv_rec.ptl_id);
    p6_a4 := ddx_pdtv_rec.name;
    p6_a5 := ddx_pdtv_rec.description;
    p6_a6 := rosetta_g_miss_num_map(ddx_pdtv_rec.reporting_pdt_id);
    p6_a7 := ddx_pdtv_rec.product_status_code;
    p6_a8 := ddx_pdtv_rec.legacy_product_yn;
    p6_a9 := ddx_pdtv_rec.from_date;
    p6_a10 := ddx_pdtv_rec.version;
    p6_a11 := ddx_pdtv_rec.to_date;
    p6_a12 := ddx_pdtv_rec.attribute_category;
    p6_a13 := ddx_pdtv_rec.attribute1;
    p6_a14 := ddx_pdtv_rec.attribute2;
    p6_a15 := ddx_pdtv_rec.attribute3;
    p6_a16 := ddx_pdtv_rec.attribute4;
    p6_a17 := ddx_pdtv_rec.attribute5;
    p6_a18 := ddx_pdtv_rec.attribute6;
    p6_a19 := ddx_pdtv_rec.attribute7;
    p6_a20 := ddx_pdtv_rec.attribute8;
    p6_a21 := ddx_pdtv_rec.attribute9;
    p6_a22 := ddx_pdtv_rec.attribute10;
    p6_a23 := ddx_pdtv_rec.attribute11;
    p6_a24 := ddx_pdtv_rec.attribute12;
    p6_a25 := ddx_pdtv_rec.attribute13;
    p6_a26 := ddx_pdtv_rec.attribute14;
    p6_a27 := ddx_pdtv_rec.attribute15;
    p6_a28 := rosetta_g_miss_num_map(ddx_pdtv_rec.created_by);
    p6_a29 := ddx_pdtv_rec.creation_date;
    p6_a30 := rosetta_g_miss_num_map(ddx_pdtv_rec.last_updated_by);
    p6_a31 := ddx_pdtv_rec.last_update_date;
    p6_a32 := rosetta_g_miss_num_map(ddx_pdtv_rec.last_update_login);
  end;

end okl_setupproducts_pub_w;

/
