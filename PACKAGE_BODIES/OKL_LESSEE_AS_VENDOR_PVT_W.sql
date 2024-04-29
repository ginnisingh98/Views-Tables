--------------------------------------------------------
--  DDL for Package Body OKL_LESSEE_AS_VENDOR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LESSEE_AS_VENDOR_PVT_W" as
  /* $Header: OKLELVPB.pls 115.0 2003/10/09 00:55:26 cklee noship $ */
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

  procedure create_lessee_as_vendor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  DATE
    , p7_a28 out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  VARCHAR2 := fnd_api.g_miss_char
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  VARCHAR2 := fnd_api.g_miss_char
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
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
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  DATE := fnd_api.g_miss_date
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  DATE := fnd_api.g_miss_date
    , p6_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_ppydv_rec okl_lessee_as_vendor_pvt.ppydv_rec_type;
    ddx_ppydv_rec okl_lessee_as_vendor_pvt.ppydv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_ppydv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_ppydv_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_ppydv_rec.cpl_id := rosetta_g_miss_num_map(p6_a2);
    ddp_ppydv_rec.vendor_id := rosetta_g_miss_num_map(p6_a3);
    ddp_ppydv_rec.pay_site_id := rosetta_g_miss_num_map(p6_a4);
    ddp_ppydv_rec.payment_term_id := rosetta_g_miss_num_map(p6_a5);
    ddp_ppydv_rec.payment_method_code := p6_a6;
    ddp_ppydv_rec.pay_group_code := p6_a7;
    ddp_ppydv_rec.attribute_category := p6_a8;
    ddp_ppydv_rec.attribute1 := p6_a9;
    ddp_ppydv_rec.attribute2 := p6_a10;
    ddp_ppydv_rec.attribute3 := p6_a11;
    ddp_ppydv_rec.attribute4 := p6_a12;
    ddp_ppydv_rec.attribute5 := p6_a13;
    ddp_ppydv_rec.attribute6 := p6_a14;
    ddp_ppydv_rec.attribute7 := p6_a15;
    ddp_ppydv_rec.attribute8 := p6_a16;
    ddp_ppydv_rec.attribute9 := p6_a17;
    ddp_ppydv_rec.attribute10 := p6_a18;
    ddp_ppydv_rec.attribute11 := p6_a19;
    ddp_ppydv_rec.attribute12 := p6_a20;
    ddp_ppydv_rec.attribute13 := p6_a21;
    ddp_ppydv_rec.attribute14 := p6_a22;
    ddp_ppydv_rec.attribute15 := p6_a23;
    ddp_ppydv_rec.created_by := rosetta_g_miss_num_map(p6_a24);
    ddp_ppydv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a25);
    ddp_ppydv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a26);
    ddp_ppydv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a27);
    ddp_ppydv_rec.last_update_login := rosetta_g_miss_num_map(p6_a28);


    -- here's the delegated call to the old PL/SQL routine
    okl_lessee_as_vendor_pvt.create_lessee_as_vendor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_ppydv_rec,
      ddx_ppydv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_ppydv_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_ppydv_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_ppydv_rec.cpl_id);
    p7_a3 := rosetta_g_miss_num_map(ddx_ppydv_rec.vendor_id);
    p7_a4 := rosetta_g_miss_num_map(ddx_ppydv_rec.pay_site_id);
    p7_a5 := rosetta_g_miss_num_map(ddx_ppydv_rec.payment_term_id);
    p7_a6 := ddx_ppydv_rec.payment_method_code;
    p7_a7 := ddx_ppydv_rec.pay_group_code;
    p7_a8 := ddx_ppydv_rec.attribute_category;
    p7_a9 := ddx_ppydv_rec.attribute1;
    p7_a10 := ddx_ppydv_rec.attribute2;
    p7_a11 := ddx_ppydv_rec.attribute3;
    p7_a12 := ddx_ppydv_rec.attribute4;
    p7_a13 := ddx_ppydv_rec.attribute5;
    p7_a14 := ddx_ppydv_rec.attribute6;
    p7_a15 := ddx_ppydv_rec.attribute7;
    p7_a16 := ddx_ppydv_rec.attribute8;
    p7_a17 := ddx_ppydv_rec.attribute9;
    p7_a18 := ddx_ppydv_rec.attribute10;
    p7_a19 := ddx_ppydv_rec.attribute11;
    p7_a20 := ddx_ppydv_rec.attribute12;
    p7_a21 := ddx_ppydv_rec.attribute13;
    p7_a22 := ddx_ppydv_rec.attribute14;
    p7_a23 := ddx_ppydv_rec.attribute15;
    p7_a24 := rosetta_g_miss_num_map(ddx_ppydv_rec.created_by);
    p7_a25 := ddx_ppydv_rec.creation_date;
    p7_a26 := rosetta_g_miss_num_map(ddx_ppydv_rec.last_updated_by);
    p7_a27 := ddx_ppydv_rec.last_update_date;
    p7_a28 := rosetta_g_miss_num_map(ddx_ppydv_rec.last_update_login);
  end;

  procedure update_lessee_as_vendor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
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
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  DATE
    , p6_a28 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  DATE := fnd_api.g_miss_date
    , p5_a28  NUMBER := 0-1962.0724
  )

  as
    ddp_ppydv_rec okl_lessee_as_vendor_pvt.ppydv_rec_type;
    ddx_ppydv_rec okl_lessee_as_vendor_pvt.ppydv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ppydv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ppydv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_ppydv_rec.cpl_id := rosetta_g_miss_num_map(p5_a2);
    ddp_ppydv_rec.vendor_id := rosetta_g_miss_num_map(p5_a3);
    ddp_ppydv_rec.pay_site_id := rosetta_g_miss_num_map(p5_a4);
    ddp_ppydv_rec.payment_term_id := rosetta_g_miss_num_map(p5_a5);
    ddp_ppydv_rec.payment_method_code := p5_a6;
    ddp_ppydv_rec.pay_group_code := p5_a7;
    ddp_ppydv_rec.attribute_category := p5_a8;
    ddp_ppydv_rec.attribute1 := p5_a9;
    ddp_ppydv_rec.attribute2 := p5_a10;
    ddp_ppydv_rec.attribute3 := p5_a11;
    ddp_ppydv_rec.attribute4 := p5_a12;
    ddp_ppydv_rec.attribute5 := p5_a13;
    ddp_ppydv_rec.attribute6 := p5_a14;
    ddp_ppydv_rec.attribute7 := p5_a15;
    ddp_ppydv_rec.attribute8 := p5_a16;
    ddp_ppydv_rec.attribute9 := p5_a17;
    ddp_ppydv_rec.attribute10 := p5_a18;
    ddp_ppydv_rec.attribute11 := p5_a19;
    ddp_ppydv_rec.attribute12 := p5_a20;
    ddp_ppydv_rec.attribute13 := p5_a21;
    ddp_ppydv_rec.attribute14 := p5_a22;
    ddp_ppydv_rec.attribute15 := p5_a23;
    ddp_ppydv_rec.created_by := rosetta_g_miss_num_map(p5_a24);
    ddp_ppydv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ppydv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a26);
    ddp_ppydv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a27);
    ddp_ppydv_rec.last_update_login := rosetta_g_miss_num_map(p5_a28);


    -- here's the delegated call to the old PL/SQL routine
    okl_lessee_as_vendor_pvt.update_lessee_as_vendor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ppydv_rec,
      ddx_ppydv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ppydv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_ppydv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_ppydv_rec.cpl_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_ppydv_rec.vendor_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_ppydv_rec.pay_site_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_ppydv_rec.payment_term_id);
    p6_a6 := ddx_ppydv_rec.payment_method_code;
    p6_a7 := ddx_ppydv_rec.pay_group_code;
    p6_a8 := ddx_ppydv_rec.attribute_category;
    p6_a9 := ddx_ppydv_rec.attribute1;
    p6_a10 := ddx_ppydv_rec.attribute2;
    p6_a11 := ddx_ppydv_rec.attribute3;
    p6_a12 := ddx_ppydv_rec.attribute4;
    p6_a13 := ddx_ppydv_rec.attribute5;
    p6_a14 := ddx_ppydv_rec.attribute6;
    p6_a15 := ddx_ppydv_rec.attribute7;
    p6_a16 := ddx_ppydv_rec.attribute8;
    p6_a17 := ddx_ppydv_rec.attribute9;
    p6_a18 := ddx_ppydv_rec.attribute10;
    p6_a19 := ddx_ppydv_rec.attribute11;
    p6_a20 := ddx_ppydv_rec.attribute12;
    p6_a21 := ddx_ppydv_rec.attribute13;
    p6_a22 := ddx_ppydv_rec.attribute14;
    p6_a23 := ddx_ppydv_rec.attribute15;
    p6_a24 := rosetta_g_miss_num_map(ddx_ppydv_rec.created_by);
    p6_a25 := ddx_ppydv_rec.creation_date;
    p6_a26 := rosetta_g_miss_num_map(ddx_ppydv_rec.last_updated_by);
    p6_a27 := ddx_ppydv_rec.last_update_date;
    p6_a28 := rosetta_g_miss_num_map(ddx_ppydv_rec.last_update_login);
  end;

end okl_lessee_as_vendor_pvt_w;

/
