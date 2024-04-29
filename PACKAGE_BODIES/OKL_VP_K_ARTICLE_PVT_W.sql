--------------------------------------------------------
--  DDL for Package Body OKL_VP_K_ARTICLE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_K_ARTICLE_PVT_W" as
  /* $Header: OKLECARB.pls 120.2 2005/08/04 01:38:43 manumanu noship $ */
  procedure create_k_article(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  DATE
    , p5_a35  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
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
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
  )

  as
    ddp_catv_rec okl_vp_k_article_pvt.catv_rec_type;
    ddx_catv_rec okl_vp_k_article_pvt.catv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_catv_rec.id := p5_a0;
    ddp_catv_rec.chr_id := p5_a1;
    ddp_catv_rec.cle_id := p5_a2;
    ddp_catv_rec.cat_id := p5_a3;
    ddp_catv_rec.object_version_number := p5_a4;
    ddp_catv_rec.sfwt_flag := p5_a5;
    ddp_catv_rec.sav_sae_id := p5_a6;
    ddp_catv_rec.sav_sav_release := p5_a7;
    ddp_catv_rec.sbt_code := p5_a8;
    ddp_catv_rec.dnz_chr_id := p5_a9;
    ddp_catv_rec.comments := p5_a10;
    ddp_catv_rec.fulltext_yn := p5_a11;
    ddp_catv_rec.variation_description := p5_a12;
    ddp_catv_rec.name := p5_a13;
    ddp_catv_rec.attribute_category := p5_a14;
    ddp_catv_rec.attribute1 := p5_a15;
    ddp_catv_rec.attribute2 := p5_a16;
    ddp_catv_rec.attribute3 := p5_a17;
    ddp_catv_rec.attribute4 := p5_a18;
    ddp_catv_rec.attribute5 := p5_a19;
    ddp_catv_rec.attribute6 := p5_a20;
    ddp_catv_rec.attribute7 := p5_a21;
    ddp_catv_rec.attribute8 := p5_a22;
    ddp_catv_rec.attribute9 := p5_a23;
    ddp_catv_rec.attribute10 := p5_a24;
    ddp_catv_rec.attribute11 := p5_a25;
    ddp_catv_rec.attribute12 := p5_a26;
    ddp_catv_rec.attribute13 := p5_a27;
    ddp_catv_rec.attribute14 := p5_a28;
    ddp_catv_rec.attribute15 := p5_a29;
    ddp_catv_rec.cat_type := p5_a30;
    ddp_catv_rec.created_by := p5_a31;
    ddp_catv_rec.creation_date := p5_a32;
    ddp_catv_rec.last_updated_by := p5_a33;
    ddp_catv_rec.last_update_date := p5_a34;
    ddp_catv_rec.last_update_login := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_k_article_pvt.create_k_article(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_catv_rec,
      ddx_catv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_catv_rec.id;
    p6_a1 := ddx_catv_rec.chr_id;
    p6_a2 := ddx_catv_rec.cle_id;
    p6_a3 := ddx_catv_rec.cat_id;
    p6_a4 := ddx_catv_rec.object_version_number;
    p6_a5 := ddx_catv_rec.sfwt_flag;
    p6_a6 := ddx_catv_rec.sav_sae_id;
    p6_a7 := ddx_catv_rec.sav_sav_release;
    p6_a8 := ddx_catv_rec.sbt_code;
    p6_a9 := ddx_catv_rec.dnz_chr_id;
    p6_a10 := ddx_catv_rec.comments;
    p6_a11 := ddx_catv_rec.fulltext_yn;
    p6_a12 := ddx_catv_rec.variation_description;
    p6_a13 := ddx_catv_rec.name;
    p6_a14 := ddx_catv_rec.attribute_category;
    p6_a15 := ddx_catv_rec.attribute1;
    p6_a16 := ddx_catv_rec.attribute2;
    p6_a17 := ddx_catv_rec.attribute3;
    p6_a18 := ddx_catv_rec.attribute4;
    p6_a19 := ddx_catv_rec.attribute5;
    p6_a20 := ddx_catv_rec.attribute6;
    p6_a21 := ddx_catv_rec.attribute7;
    p6_a22 := ddx_catv_rec.attribute8;
    p6_a23 := ddx_catv_rec.attribute9;
    p6_a24 := ddx_catv_rec.attribute10;
    p6_a25 := ddx_catv_rec.attribute11;
    p6_a26 := ddx_catv_rec.attribute12;
    p6_a27 := ddx_catv_rec.attribute13;
    p6_a28 := ddx_catv_rec.attribute14;
    p6_a29 := ddx_catv_rec.attribute15;
    p6_a30 := ddx_catv_rec.cat_type;
    p6_a31 := ddx_catv_rec.created_by;
    p6_a32 := ddx_catv_rec.creation_date;
    p6_a33 := ddx_catv_rec.last_updated_by;
    p6_a34 := ddx_catv_rec.last_update_date;
    p6_a35 := ddx_catv_rec.last_update_login;
  end;

  procedure update_k_article(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  DATE
    , p5_a35  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
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
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
  )

  as
    ddp_catv_rec okl_vp_k_article_pvt.catv_rec_type;
    ddx_catv_rec okl_vp_k_article_pvt.catv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_catv_rec.id := p5_a0;
    ddp_catv_rec.chr_id := p5_a1;
    ddp_catv_rec.cle_id := p5_a2;
    ddp_catv_rec.cat_id := p5_a3;
    ddp_catv_rec.object_version_number := p5_a4;
    ddp_catv_rec.sfwt_flag := p5_a5;
    ddp_catv_rec.sav_sae_id := p5_a6;
    ddp_catv_rec.sav_sav_release := p5_a7;
    ddp_catv_rec.sbt_code := p5_a8;
    ddp_catv_rec.dnz_chr_id := p5_a9;
    ddp_catv_rec.comments := p5_a10;
    ddp_catv_rec.fulltext_yn := p5_a11;
    ddp_catv_rec.variation_description := p5_a12;
    ddp_catv_rec.name := p5_a13;
    ddp_catv_rec.attribute_category := p5_a14;
    ddp_catv_rec.attribute1 := p5_a15;
    ddp_catv_rec.attribute2 := p5_a16;
    ddp_catv_rec.attribute3 := p5_a17;
    ddp_catv_rec.attribute4 := p5_a18;
    ddp_catv_rec.attribute5 := p5_a19;
    ddp_catv_rec.attribute6 := p5_a20;
    ddp_catv_rec.attribute7 := p5_a21;
    ddp_catv_rec.attribute8 := p5_a22;
    ddp_catv_rec.attribute9 := p5_a23;
    ddp_catv_rec.attribute10 := p5_a24;
    ddp_catv_rec.attribute11 := p5_a25;
    ddp_catv_rec.attribute12 := p5_a26;
    ddp_catv_rec.attribute13 := p5_a27;
    ddp_catv_rec.attribute14 := p5_a28;
    ddp_catv_rec.attribute15 := p5_a29;
    ddp_catv_rec.cat_type := p5_a30;
    ddp_catv_rec.created_by := p5_a31;
    ddp_catv_rec.creation_date := p5_a32;
    ddp_catv_rec.last_updated_by := p5_a33;
    ddp_catv_rec.last_update_date := p5_a34;
    ddp_catv_rec.last_update_login := p5_a35;


    -- here's the delegated call to the old PL/SQL routine
    okl_vp_k_article_pvt.update_k_article(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_catv_rec,
      ddx_catv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_catv_rec.id;
    p6_a1 := ddx_catv_rec.chr_id;
    p6_a2 := ddx_catv_rec.cle_id;
    p6_a3 := ddx_catv_rec.cat_id;
    p6_a4 := ddx_catv_rec.object_version_number;
    p6_a5 := ddx_catv_rec.sfwt_flag;
    p6_a6 := ddx_catv_rec.sav_sae_id;
    p6_a7 := ddx_catv_rec.sav_sav_release;
    p6_a8 := ddx_catv_rec.sbt_code;
    p6_a9 := ddx_catv_rec.dnz_chr_id;
    p6_a10 := ddx_catv_rec.comments;
    p6_a11 := ddx_catv_rec.fulltext_yn;
    p6_a12 := ddx_catv_rec.variation_description;
    p6_a13 := ddx_catv_rec.name;
    p6_a14 := ddx_catv_rec.attribute_category;
    p6_a15 := ddx_catv_rec.attribute1;
    p6_a16 := ddx_catv_rec.attribute2;
    p6_a17 := ddx_catv_rec.attribute3;
    p6_a18 := ddx_catv_rec.attribute4;
    p6_a19 := ddx_catv_rec.attribute5;
    p6_a20 := ddx_catv_rec.attribute6;
    p6_a21 := ddx_catv_rec.attribute7;
    p6_a22 := ddx_catv_rec.attribute8;
    p6_a23 := ddx_catv_rec.attribute9;
    p6_a24 := ddx_catv_rec.attribute10;
    p6_a25 := ddx_catv_rec.attribute11;
    p6_a26 := ddx_catv_rec.attribute12;
    p6_a27 := ddx_catv_rec.attribute13;
    p6_a28 := ddx_catv_rec.attribute14;
    p6_a29 := ddx_catv_rec.attribute15;
    p6_a30 := ddx_catv_rec.cat_type;
    p6_a31 := ddx_catv_rec.created_by;
    p6_a32 := ddx_catv_rec.creation_date;
    p6_a33 := ddx_catv_rec.last_updated_by;
    p6_a34 := ddx_catv_rec.last_update_date;
    p6_a35 := ddx_catv_rec.last_update_login;
  end;

  procedure delete_k_article(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p5_a34  DATE
    , p5_a35  NUMBER
  )

  as
    ddp_catv_rec okl_vp_k_article_pvt.catv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_catv_rec.id := p5_a0;
    ddp_catv_rec.chr_id := p5_a1;
    ddp_catv_rec.cle_id := p5_a2;
    ddp_catv_rec.cat_id := p5_a3;
    ddp_catv_rec.object_version_number := p5_a4;
    ddp_catv_rec.sfwt_flag := p5_a5;
    ddp_catv_rec.sav_sae_id := p5_a6;
    ddp_catv_rec.sav_sav_release := p5_a7;
    ddp_catv_rec.sbt_code := p5_a8;
    ddp_catv_rec.dnz_chr_id := p5_a9;
    ddp_catv_rec.comments := p5_a10;
    ddp_catv_rec.fulltext_yn := p5_a11;
    ddp_catv_rec.variation_description := p5_a12;
    ddp_catv_rec.name := p5_a13;
    ddp_catv_rec.attribute_category := p5_a14;
    ddp_catv_rec.attribute1 := p5_a15;
    ddp_catv_rec.attribute2 := p5_a16;
    ddp_catv_rec.attribute3 := p5_a17;
    ddp_catv_rec.attribute4 := p5_a18;
    ddp_catv_rec.attribute5 := p5_a19;
    ddp_catv_rec.attribute6 := p5_a20;
    ddp_catv_rec.attribute7 := p5_a21;
    ddp_catv_rec.attribute8 := p5_a22;
    ddp_catv_rec.attribute9 := p5_a23;
    ddp_catv_rec.attribute10 := p5_a24;
    ddp_catv_rec.attribute11 := p5_a25;
    ddp_catv_rec.attribute12 := p5_a26;
    ddp_catv_rec.attribute13 := p5_a27;
    ddp_catv_rec.attribute14 := p5_a28;
    ddp_catv_rec.attribute15 := p5_a29;
    ddp_catv_rec.cat_type := p5_a30;
    ddp_catv_rec.created_by := p5_a31;
    ddp_catv_rec.creation_date := p5_a32;
    ddp_catv_rec.last_updated_by := p5_a33;
    ddp_catv_rec.last_update_date := p5_a34;
    ddp_catv_rec.last_update_login := p5_a35;

    -- here's the delegated call to the old PL/SQL routine
    okl_vp_k_article_pvt.delete_k_article(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_catv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_vp_k_article_pvt_w;

/
