--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPRODUCTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPRODUCTS_PVT_W" as
  /* $Header: OKLESPDB.pls 120.3 2005/10/30 04:08:24 appldev noship $ */
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

  procedure rosetta_table_copy_in_p56(t out nocopy okl_setupproducts_pvt.pdt_parameters_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_VARCHAR2_TABLE_500
    , a19 JTF_VARCHAR2_TABLE_500
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).name := a1(indx);
          t(ddindx).from_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).to_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).version := a4(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).aes_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).ptl_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).legacy_product_yn := a8(indx);
          t(ddindx).attribute_category := a9(indx);
          t(ddindx).attribute1 := a10(indx);
          t(ddindx).attribute2 := a11(indx);
          t(ddindx).attribute3 := a12(indx);
          t(ddindx).attribute4 := a13(indx);
          t(ddindx).attribute5 := a14(indx);
          t(ddindx).attribute6 := a15(indx);
          t(ddindx).attribute7 := a16(indx);
          t(ddindx).attribute8 := a17(indx);
          t(ddindx).attribute9 := a18(indx);
          t(ddindx).attribute10 := a19(indx);
          t(ddindx).attribute11 := a20(indx);
          t(ddindx).attribute12 := a21(indx);
          t(ddindx).attribute13 := a22(indx);
          t(ddindx).attribute14 := a23(indx);
          t(ddindx).attribute15 := a24(indx);
          t(ddindx).product_subclass := a25(indx);
          t(ddindx).deal_type := a26(indx);
          t(ddindx).tax_owner := a27(indx);
          t(ddindx).reporting_pdt_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).reporting_product := a29(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p56;
  procedure rosetta_table_copy_out_p56(t okl_setupproducts_pvt.pdt_parameters_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_VARCHAR2_TABLE_500
    , a19 out nocopy JTF_VARCHAR2_TABLE_500
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_VARCHAR2_TABLE_500();
    a19 := JTF_VARCHAR2_TABLE_500();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_VARCHAR2_TABLE_500();
      a19 := JTF_VARCHAR2_TABLE_500();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_200();
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
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).from_date;
          a3(indx) := t(ddindx).to_date;
          a4(indx) := t(ddindx).version;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).aes_id);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).ptl_id);
          a8(indx) := t(ddindx).legacy_product_yn;
          a9(indx) := t(ddindx).attribute_category;
          a10(indx) := t(ddindx).attribute1;
          a11(indx) := t(ddindx).attribute2;
          a12(indx) := t(ddindx).attribute3;
          a13(indx) := t(ddindx).attribute4;
          a14(indx) := t(ddindx).attribute5;
          a15(indx) := t(ddindx).attribute6;
          a16(indx) := t(ddindx).attribute7;
          a17(indx) := t(ddindx).attribute8;
          a18(indx) := t(ddindx).attribute9;
          a19(indx) := t(ddindx).attribute10;
          a20(indx) := t(ddindx).attribute11;
          a21(indx) := t(ddindx).attribute12;
          a22(indx) := t(ddindx).attribute13;
          a23(indx) := t(ddindx).attribute14;
          a24(indx) := t(ddindx).attribute15;
          a25(indx) := t(ddindx).product_subclass;
          a26(indx) := t(ddindx).deal_type;
          a27(indx) := t(ddindx).tax_owner;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).reporting_pdt_id);
          a29(indx) := t(ddindx).reporting_product;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p56;

  procedure get_rec(x_return_status out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  NUMBER
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  DATE
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  DATE
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  VARCHAR2
    , p3_a15 out nocopy  VARCHAR2
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  VARCHAR2
    , p3_a28 out nocopy  NUMBER
    , p3_a29 out nocopy  DATE
    , p3_a30 out nocopy  NUMBER
    , p3_a31 out nocopy  DATE
    , p3_a32 out nocopy  NUMBER
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
    ddp_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
    ddx_no_data_found boolean;
    ddx_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
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
    okl_setupproducts_pvt.get_rec(ddp_pdtv_rec,
      x_return_status,
      ddx_no_data_found,
      ddx_pdtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p3_a0 := rosetta_g_miss_num_map(ddx_pdtv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_pdtv_rec.object_version_number);
    p3_a2 := rosetta_g_miss_num_map(ddx_pdtv_rec.aes_id);
    p3_a3 := rosetta_g_miss_num_map(ddx_pdtv_rec.ptl_id);
    p3_a4 := ddx_pdtv_rec.name;
    p3_a5 := ddx_pdtv_rec.description;
    p3_a6 := rosetta_g_miss_num_map(ddx_pdtv_rec.reporting_pdt_id);
    p3_a7 := ddx_pdtv_rec.product_status_code;
    p3_a8 := ddx_pdtv_rec.legacy_product_yn;
    p3_a9 := ddx_pdtv_rec.from_date;
    p3_a10 := ddx_pdtv_rec.version;
    p3_a11 := ddx_pdtv_rec.to_date;
    p3_a12 := ddx_pdtv_rec.attribute_category;
    p3_a13 := ddx_pdtv_rec.attribute1;
    p3_a14 := ddx_pdtv_rec.attribute2;
    p3_a15 := ddx_pdtv_rec.attribute3;
    p3_a16 := ddx_pdtv_rec.attribute4;
    p3_a17 := ddx_pdtv_rec.attribute5;
    p3_a18 := ddx_pdtv_rec.attribute6;
    p3_a19 := ddx_pdtv_rec.attribute7;
    p3_a20 := ddx_pdtv_rec.attribute8;
    p3_a21 := ddx_pdtv_rec.attribute9;
    p3_a22 := ddx_pdtv_rec.attribute10;
    p3_a23 := ddx_pdtv_rec.attribute11;
    p3_a24 := ddx_pdtv_rec.attribute12;
    p3_a25 := ddx_pdtv_rec.attribute13;
    p3_a26 := ddx_pdtv_rec.attribute14;
    p3_a27 := ddx_pdtv_rec.attribute15;
    p3_a28 := rosetta_g_miss_num_map(ddx_pdtv_rec.created_by);
    p3_a29 := ddx_pdtv_rec.creation_date;
    p3_a30 := rosetta_g_miss_num_map(ddx_pdtv_rec.last_updated_by);
    p3_a31 := ddx_pdtv_rec.last_update_date;
    p3_a32 := rosetta_g_miss_num_map(ddx_pdtv_rec.last_update_login);
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
    ddp_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
    ddx_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
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
    okl_setupproducts_pvt.insert_products(p_api_version,
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
    ddp_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
    ddx_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
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
    okl_setupproducts_pvt.update_products(p_api_version,
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

  procedure product_approval_process(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
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
    ddp_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
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
    okl_setupproducts_pvt.product_approval_process(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_product(p_api_version  NUMBER
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
    ddp_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
    ddx_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
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
    okl_setupproducts_pvt.validate_product(p_api_version,
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
    , p8_a28 out nocopy  NUMBER
    , p8_a29 out nocopy  VARCHAR2
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
    ddp_pdtv_rec okl_setupproducts_pvt.pdtv_rec_type;
    ddp_product_date date;
    ddp_pdt_parameter_rec okl_setupproducts_pvt.pdt_parameters_rec_type;
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
    okl_setupproducts_pvt.getpdt_parameters(p_api_version,
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
    p8_a28 := rosetta_g_miss_num_map(ddp_pdt_parameter_rec.reporting_pdt_id);
    p8_a29 := ddp_pdt_parameter_rec.reporting_product;
  end;

end okl_setupproducts_pvt_w;

/
