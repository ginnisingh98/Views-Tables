--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPSTYPES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPSTYPES_PVT_W" as
  /* $Header: OKLESPSB.pls 120.1 2005/07/12 09:10:45 dkagrawa noship $ */
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

  procedure get_rec(x_no_data_found out nocopy  number
    , x_return_status out nocopy  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  DATE
    , p3_a2 out nocopy  DATE
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  NUMBER
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  DATE
    , p3_a10 out nocopy  NUMBER
    , p3_a11 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  DATE := fnd_api.g_miss_date
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_psyv_rec okl_setuppstypes_pvt.psyv_rec_type;
    ddx_no_data_found boolean;
    ddx_psyv_rec okl_setuppstypes_pvt.psyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_psyv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p0_a3);
    ddp_psyv_rec.accrual_yn := p0_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p0_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p0_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);




    -- here's the delegated call to the old PL/SQL routine
    okl_setuppstypes_pvt.get_rec(ddp_psyv_rec,
      ddx_no_data_found,
      x_return_status,
      ddx_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;


    p3_a0 := rosetta_g_miss_num_map(ddx_psyv_rec.id);
    p3_a1 := ddx_psyv_rec.from_date;
    p3_a2 := ddx_psyv_rec.to_date;
    p3_a3 := rosetta_g_miss_num_map(ddx_psyv_rec.object_version_number);
    p3_a4 := ddx_psyv_rec.accrual_yn;
    p3_a5 := rosetta_g_miss_num_map(ddx_psyv_rec.sty_id);
    p3_a6 := rosetta_g_miss_num_map(ddx_psyv_rec.pdt_id);
    p3_a7 := rosetta_g_miss_num_map(ddx_psyv_rec.created_by);
    p3_a8 := ddx_psyv_rec.creation_date;
    p3_a9 := ddx_psyv_rec.last_update_date;
    p3_a10 := rosetta_g_miss_num_map(ddx_psyv_rec.last_updated_by);
    p3_a11 := rosetta_g_miss_num_map(ddx_psyv_rec.last_update_login);
  end;

  procedure insert_pstypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  DATE
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  DATE
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
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
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_pdtv_rec okl_setuppstypes_pvt.pdtv_rec_type;
    ddp_psyv_rec okl_setuppstypes_pvt.psyv_rec_type;
    ddx_psyv_rec okl_setuppstypes_pvt.psyv_rec_type;
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

    ddp_psyv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p6_a3);
    ddp_psyv_rec.accrual_yn := p6_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p6_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p6_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setuppstypes_pvt.insert_pstypes(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec,
      ddp_psyv_rec,
      ddx_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_psyv_rec.id);
    p7_a1 := ddx_psyv_rec.from_date;
    p7_a2 := ddx_psyv_rec.to_date;
    p7_a3 := rosetta_g_miss_num_map(ddx_psyv_rec.object_version_number);
    p7_a4 := ddx_psyv_rec.accrual_yn;
    p7_a5 := rosetta_g_miss_num_map(ddx_psyv_rec.sty_id);
    p7_a6 := rosetta_g_miss_num_map(ddx_psyv_rec.pdt_id);
    p7_a7 := rosetta_g_miss_num_map(ddx_psyv_rec.created_by);
    p7_a8 := ddx_psyv_rec.creation_date;
    p7_a9 := ddx_psyv_rec.last_update_date;
    p7_a10 := rosetta_g_miss_num_map(ddx_psyv_rec.last_updated_by);
    p7_a11 := rosetta_g_miss_num_map(ddx_psyv_rec.last_update_login);
  end;

  procedure update_pstypes(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  DATE
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  DATE
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
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
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_pdtv_rec okl_setuppstypes_pvt.pdtv_rec_type;
    ddp_psyv_rec okl_setuppstypes_pvt.psyv_rec_type;
    ddx_psyv_rec okl_setuppstypes_pvt.psyv_rec_type;
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

    ddp_psyv_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_psyv_rec.from_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_psyv_rec.to_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_psyv_rec.object_version_number := rosetta_g_miss_num_map(p6_a3);
    ddp_psyv_rec.accrual_yn := p6_a4;
    ddp_psyv_rec.sty_id := rosetta_g_miss_num_map(p6_a5);
    ddp_psyv_rec.pdt_id := rosetta_g_miss_num_map(p6_a6);
    ddp_psyv_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_psyv_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_psyv_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_psyv_rec.last_updated_by := rosetta_g_miss_num_map(p6_a10);
    ddp_psyv_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setuppstypes_pvt.update_pstypes(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pdtv_rec,
      ddp_psyv_rec,
      ddx_psyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_psyv_rec.id);
    p7_a1 := ddx_psyv_rec.from_date;
    p7_a2 := ddx_psyv_rec.to_date;
    p7_a3 := rosetta_g_miss_num_map(ddx_psyv_rec.object_version_number);
    p7_a4 := ddx_psyv_rec.accrual_yn;
    p7_a5 := rosetta_g_miss_num_map(ddx_psyv_rec.sty_id);
    p7_a6 := rosetta_g_miss_num_map(ddx_psyv_rec.pdt_id);
    p7_a7 := rosetta_g_miss_num_map(ddx_psyv_rec.created_by);
    p7_a8 := ddx_psyv_rec.creation_date;
    p7_a9 := ddx_psyv_rec.last_update_date;
    p7_a10 := rosetta_g_miss_num_map(ddx_psyv_rec.last_updated_by);
    p7_a11 := rosetta_g_miss_num_map(ddx_psyv_rec.last_update_login);
  end;

end okl_setuppstypes_pvt_w;

/
