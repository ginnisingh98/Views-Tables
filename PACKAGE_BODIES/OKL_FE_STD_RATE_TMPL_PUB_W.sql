--------------------------------------------------------
--  DDL for Package Body OKL_FE_STD_RATE_TMPL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_STD_RATE_TMPL_PUB_W" as
  /* $Header: OKLUSRTB.pls 120.0 2005/07/07 10:46:41 viselvar noship $ */
  procedure get_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_srt_id  NUMBER
    , p_version_number  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  DATE
    , p7_a16 out nocopy  NUMBER
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  DATE
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  DATE
    , p7_a37 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
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
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  DATE
    , p8_a31 out nocopy  NUMBER
    , p8_a32 out nocopy  DATE
    , p8_a33 out nocopy  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  NUMBER
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  DATE
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  DATE
    , p9_a10 out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_DATE_TABLE
    , p10_a5 out nocopy JTF_DATE_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_NUMBER_TABLE
    , p10_a9 out nocopy JTF_DATE_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_DATE_TABLE
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_NUMBER_TABLE
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p11_a9 out nocopy JTF_NUMBER_TABLE
    , p11_a10 out nocopy JTF_NUMBER_TABLE
    , p11_a11 out nocopy JTF_DATE_TABLE
    , p11_a12 out nocopy JTF_DATE_TABLE
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_NUMBER_TABLE
    , p11_a15 out nocopy JTF_NUMBER_TABLE
    , p11_a16 out nocopy JTF_DATE_TABLE
    , p11_a17 out nocopy JTF_NUMBER_TABLE
    , p11_a18 out nocopy JTF_DATE_TABLE
    , p11_a19 out nocopy JTF_NUMBER_TABLE
    , p11_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p11_a35 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddx_srtv_rec okl_fe_std_rate_tmpl_pub.okl_srtv_rec;
    ddx_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddx_ech_rec okl_fe_std_rate_tmpl_pub.okl_ech_rec;
    ddx_ecl_tbl okl_fe_std_rate_tmpl_pub.okl_ecl_tbl;
    ddx_ecv_tbl okl_fe_std_rate_tmpl_pub.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    okl_fe_std_rate_tmpl_pub.get_version(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_srt_id,
      p_version_number,
      ddx_srtv_rec,
      ddx_srv_rec,
      ddx_ech_rec,
      ddx_ecl_tbl,
      ddx_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_srtv_rec.std_rate_tmpl_id;
    p7_a1 := ddx_srtv_rec.template_name;
    p7_a2 := ddx_srtv_rec.template_desc;
    p7_a3 := ddx_srtv_rec.object_version_number;
    p7_a4 := ddx_srtv_rec.org_id;
    p7_a5 := ddx_srtv_rec.currency_code;
    p7_a6 := ddx_srtv_rec.rate_card_yn;
    p7_a7 := ddx_srtv_rec.pricing_engine_code;
    p7_a8 := ddx_srtv_rec.orig_std_rate_tmpl_id;
    p7_a9 := ddx_srtv_rec.rate_type_code;
    p7_a10 := ddx_srtv_rec.frequency_code;
    p7_a11 := ddx_srtv_rec.index_id;
    p7_a12 := ddx_srtv_rec.default_yn;
    p7_a13 := ddx_srtv_rec.sts_code;
    p7_a14 := ddx_srtv_rec.effective_from_date;
    p7_a15 := ddx_srtv_rec.effective_to_date;
    p7_a16 := ddx_srtv_rec.srt_rate;
    p7_a17 := ddx_srtv_rec.attribute_category;
    p7_a18 := ddx_srtv_rec.attribute1;
    p7_a19 := ddx_srtv_rec.attribute2;
    p7_a20 := ddx_srtv_rec.attribute3;
    p7_a21 := ddx_srtv_rec.attribute4;
    p7_a22 := ddx_srtv_rec.attribute5;
    p7_a23 := ddx_srtv_rec.attribute6;
    p7_a24 := ddx_srtv_rec.attribute7;
    p7_a25 := ddx_srtv_rec.attribute8;
    p7_a26 := ddx_srtv_rec.attribute9;
    p7_a27 := ddx_srtv_rec.attribute10;
    p7_a28 := ddx_srtv_rec.attribute11;
    p7_a29 := ddx_srtv_rec.attribute12;
    p7_a30 := ddx_srtv_rec.attribute13;
    p7_a31 := ddx_srtv_rec.attribute14;
    p7_a32 := ddx_srtv_rec.attribute15;
    p7_a33 := ddx_srtv_rec.created_by;
    p7_a34 := ddx_srtv_rec.creation_date;
    p7_a35 := ddx_srtv_rec.last_updated_by;
    p7_a36 := ddx_srtv_rec.last_update_date;
    p7_a37 := ddx_srtv_rec.last_update_login;

    p8_a0 := ddx_srv_rec.std_rate_tmpl_ver_id;
    p8_a1 := ddx_srv_rec.object_version_number;
    p8_a2 := ddx_srv_rec.version_number;
    p8_a3 := ddx_srv_rec.std_rate_tmpl_id;
    p8_a4 := ddx_srv_rec.effective_from_date;
    p8_a5 := ddx_srv_rec.effective_to_date;
    p8_a6 := ddx_srv_rec.sts_code;
    p8_a7 := ddx_srv_rec.adj_mat_version_id;
    p8_a8 := ddx_srv_rec.srt_rate;
    p8_a9 := ddx_srv_rec.spread;
    p8_a10 := ddx_srv_rec.day_convention_code;
    p8_a11 := ddx_srv_rec.min_adj_rate;
    p8_a12 := ddx_srv_rec.max_adj_rate;
    p8_a13 := ddx_srv_rec.attribute_category;
    p8_a14 := ddx_srv_rec.attribute1;
    p8_a15 := ddx_srv_rec.attribute2;
    p8_a16 := ddx_srv_rec.attribute3;
    p8_a17 := ddx_srv_rec.attribute4;
    p8_a18 := ddx_srv_rec.attribute5;
    p8_a19 := ddx_srv_rec.attribute6;
    p8_a20 := ddx_srv_rec.attribute7;
    p8_a21 := ddx_srv_rec.attribute8;
    p8_a22 := ddx_srv_rec.attribute9;
    p8_a23 := ddx_srv_rec.attribute10;
    p8_a24 := ddx_srv_rec.attribute11;
    p8_a25 := ddx_srv_rec.attribute12;
    p8_a26 := ddx_srv_rec.attribute13;
    p8_a27 := ddx_srv_rec.attribute14;
    p8_a28 := ddx_srv_rec.attribute15;
    p8_a29 := ddx_srv_rec.created_by;
    p8_a30 := ddx_srv_rec.creation_date;
    p8_a31 := ddx_srv_rec.last_updated_by;
    p8_a32 := ddx_srv_rec.last_update_date;
    p8_a33 := ddx_srv_rec.last_update_login;

    p9_a0 := ddx_ech_rec.criteria_set_id;
    p9_a1 := ddx_ech_rec.object_version_number;
    p9_a2 := ddx_ech_rec.source_id;
    p9_a3 := ddx_ech_rec.source_object_code;
    p9_a4 := ddx_ech_rec.match_criteria_code;
    p9_a5 := ddx_ech_rec.validation_code;
    p9_a6 := ddx_ech_rec.created_by;
    p9_a7 := ddx_ech_rec.creation_date;
    p9_a8 := ddx_ech_rec.last_updated_by;
    p9_a9 := ddx_ech_rec.last_update_date;
    p9_a10 := ddx_ech_rec.last_update_login;

    okl_ecl_pvt_w.rosetta_table_copy_out_p1(ddx_ecl_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      );

    okl_ecv_pvt_w.rosetta_table_copy_out_p1(ddx_ecv_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      );
  end;

  procedure get_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_srt_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
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
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
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
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  DATE
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  DATE
    , p7_a33 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  NUMBER
    , p8_a7 out nocopy  DATE
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_DATE_TABLE
    , p9_a5 out nocopy JTF_DATE_TABLE
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_DATE_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_DATE_TABLE
    , p10_a12 out nocopy JTF_DATE_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_DATE_TABLE
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_DATE_TABLE
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_500
  )

  as
    ddx_srtv_rec okl_fe_std_rate_tmpl_pub.okl_srtv_rec;
    ddx_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddx_ech_rec okl_fe_std_rate_tmpl_pub.okl_ech_rec;
    ddx_ecl_tbl okl_fe_std_rate_tmpl_pub.okl_ecl_tbl;
    ddx_ecv_tbl okl_fe_std_rate_tmpl_pub.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    okl_fe_std_rate_tmpl_pub.get_version(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_srt_id,
      ddx_srtv_rec,
      ddx_srv_rec,
      ddx_ech_rec,
      ddx_ecl_tbl,
      ddx_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_srtv_rec.std_rate_tmpl_id;
    p6_a1 := ddx_srtv_rec.template_name;
    p6_a2 := ddx_srtv_rec.template_desc;
    p6_a3 := ddx_srtv_rec.object_version_number;
    p6_a4 := ddx_srtv_rec.org_id;
    p6_a5 := ddx_srtv_rec.currency_code;
    p6_a6 := ddx_srtv_rec.rate_card_yn;
    p6_a7 := ddx_srtv_rec.pricing_engine_code;
    p6_a8 := ddx_srtv_rec.orig_std_rate_tmpl_id;
    p6_a9 := ddx_srtv_rec.rate_type_code;
    p6_a10 := ddx_srtv_rec.frequency_code;
    p6_a11 := ddx_srtv_rec.index_id;
    p6_a12 := ddx_srtv_rec.default_yn;
    p6_a13 := ddx_srtv_rec.sts_code;
    p6_a14 := ddx_srtv_rec.effective_from_date;
    p6_a15 := ddx_srtv_rec.effective_to_date;
    p6_a16 := ddx_srtv_rec.srt_rate;
    p6_a17 := ddx_srtv_rec.attribute_category;
    p6_a18 := ddx_srtv_rec.attribute1;
    p6_a19 := ddx_srtv_rec.attribute2;
    p6_a20 := ddx_srtv_rec.attribute3;
    p6_a21 := ddx_srtv_rec.attribute4;
    p6_a22 := ddx_srtv_rec.attribute5;
    p6_a23 := ddx_srtv_rec.attribute6;
    p6_a24 := ddx_srtv_rec.attribute7;
    p6_a25 := ddx_srtv_rec.attribute8;
    p6_a26 := ddx_srtv_rec.attribute9;
    p6_a27 := ddx_srtv_rec.attribute10;
    p6_a28 := ddx_srtv_rec.attribute11;
    p6_a29 := ddx_srtv_rec.attribute12;
    p6_a30 := ddx_srtv_rec.attribute13;
    p6_a31 := ddx_srtv_rec.attribute14;
    p6_a32 := ddx_srtv_rec.attribute15;
    p6_a33 := ddx_srtv_rec.created_by;
    p6_a34 := ddx_srtv_rec.creation_date;
    p6_a35 := ddx_srtv_rec.last_updated_by;
    p6_a36 := ddx_srtv_rec.last_update_date;
    p6_a37 := ddx_srtv_rec.last_update_login;

    p7_a0 := ddx_srv_rec.std_rate_tmpl_ver_id;
    p7_a1 := ddx_srv_rec.object_version_number;
    p7_a2 := ddx_srv_rec.version_number;
    p7_a3 := ddx_srv_rec.std_rate_tmpl_id;
    p7_a4 := ddx_srv_rec.effective_from_date;
    p7_a5 := ddx_srv_rec.effective_to_date;
    p7_a6 := ddx_srv_rec.sts_code;
    p7_a7 := ddx_srv_rec.adj_mat_version_id;
    p7_a8 := ddx_srv_rec.srt_rate;
    p7_a9 := ddx_srv_rec.spread;
    p7_a10 := ddx_srv_rec.day_convention_code;
    p7_a11 := ddx_srv_rec.min_adj_rate;
    p7_a12 := ddx_srv_rec.max_adj_rate;
    p7_a13 := ddx_srv_rec.attribute_category;
    p7_a14 := ddx_srv_rec.attribute1;
    p7_a15 := ddx_srv_rec.attribute2;
    p7_a16 := ddx_srv_rec.attribute3;
    p7_a17 := ddx_srv_rec.attribute4;
    p7_a18 := ddx_srv_rec.attribute5;
    p7_a19 := ddx_srv_rec.attribute6;
    p7_a20 := ddx_srv_rec.attribute7;
    p7_a21 := ddx_srv_rec.attribute8;
    p7_a22 := ddx_srv_rec.attribute9;
    p7_a23 := ddx_srv_rec.attribute10;
    p7_a24 := ddx_srv_rec.attribute11;
    p7_a25 := ddx_srv_rec.attribute12;
    p7_a26 := ddx_srv_rec.attribute13;
    p7_a27 := ddx_srv_rec.attribute14;
    p7_a28 := ddx_srv_rec.attribute15;
    p7_a29 := ddx_srv_rec.created_by;
    p7_a30 := ddx_srv_rec.creation_date;
    p7_a31 := ddx_srv_rec.last_updated_by;
    p7_a32 := ddx_srv_rec.last_update_date;
    p7_a33 := ddx_srv_rec.last_update_login;

    p8_a0 := ddx_ech_rec.criteria_set_id;
    p8_a1 := ddx_ech_rec.object_version_number;
    p8_a2 := ddx_ech_rec.source_id;
    p8_a3 := ddx_ech_rec.source_object_code;
    p8_a4 := ddx_ech_rec.match_criteria_code;
    p8_a5 := ddx_ech_rec.validation_code;
    p8_a6 := ddx_ech_rec.created_by;
    p8_a7 := ddx_ech_rec.creation_date;
    p8_a8 := ddx_ech_rec.last_updated_by;
    p8_a9 := ddx_ech_rec.last_update_date;
    p8_a10 := ddx_ech_rec.last_update_login;

    okl_ecl_pvt_w.rosetta_table_copy_out_p1(ddx_ecl_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      );

    okl_ecv_pvt_w.rosetta_table_copy_out_p1(ddx_ecv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      );
  end;

  procedure create_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  NUMBER
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
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
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
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
  )

  as
    ddp_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddx_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srv_rec.std_rate_tmpl_ver_id := p5_a0;
    ddp_srv_rec.object_version_number := p5_a1;
    ddp_srv_rec.version_number := p5_a2;
    ddp_srv_rec.std_rate_tmpl_id := p5_a3;
    ddp_srv_rec.effective_from_date := p5_a4;
    ddp_srv_rec.effective_to_date := p5_a5;
    ddp_srv_rec.sts_code := p5_a6;
    ddp_srv_rec.adj_mat_version_id := p5_a7;
    ddp_srv_rec.srt_rate := p5_a8;
    ddp_srv_rec.spread := p5_a9;
    ddp_srv_rec.day_convention_code := p5_a10;
    ddp_srv_rec.min_adj_rate := p5_a11;
    ddp_srv_rec.max_adj_rate := p5_a12;
    ddp_srv_rec.attribute_category := p5_a13;
    ddp_srv_rec.attribute1 := p5_a14;
    ddp_srv_rec.attribute2 := p5_a15;
    ddp_srv_rec.attribute3 := p5_a16;
    ddp_srv_rec.attribute4 := p5_a17;
    ddp_srv_rec.attribute5 := p5_a18;
    ddp_srv_rec.attribute6 := p5_a19;
    ddp_srv_rec.attribute7 := p5_a20;
    ddp_srv_rec.attribute8 := p5_a21;
    ddp_srv_rec.attribute9 := p5_a22;
    ddp_srv_rec.attribute10 := p5_a23;
    ddp_srv_rec.attribute11 := p5_a24;
    ddp_srv_rec.attribute12 := p5_a25;
    ddp_srv_rec.attribute13 := p5_a26;
    ddp_srv_rec.attribute14 := p5_a27;
    ddp_srv_rec.attribute15 := p5_a28;
    ddp_srv_rec.created_by := p5_a29;
    ddp_srv_rec.creation_date := p5_a30;
    ddp_srv_rec.last_updated_by := p5_a31;
    ddp_srv_rec.last_update_date := p5_a32;
    ddp_srv_rec.last_update_login := p5_a33;


    -- here's the delegated call to the old PL/SQL routine
    okl_fe_std_rate_tmpl_pub.create_version(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srv_rec,
      ddx_srv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_srv_rec.std_rate_tmpl_ver_id;
    p6_a1 := ddx_srv_rec.object_version_number;
    p6_a2 := ddx_srv_rec.version_number;
    p6_a3 := ddx_srv_rec.std_rate_tmpl_id;
    p6_a4 := ddx_srv_rec.effective_from_date;
    p6_a5 := ddx_srv_rec.effective_to_date;
    p6_a6 := ddx_srv_rec.sts_code;
    p6_a7 := ddx_srv_rec.adj_mat_version_id;
    p6_a8 := ddx_srv_rec.srt_rate;
    p6_a9 := ddx_srv_rec.spread;
    p6_a10 := ddx_srv_rec.day_convention_code;
    p6_a11 := ddx_srv_rec.min_adj_rate;
    p6_a12 := ddx_srv_rec.max_adj_rate;
    p6_a13 := ddx_srv_rec.attribute_category;
    p6_a14 := ddx_srv_rec.attribute1;
    p6_a15 := ddx_srv_rec.attribute2;
    p6_a16 := ddx_srv_rec.attribute3;
    p6_a17 := ddx_srv_rec.attribute4;
    p6_a18 := ddx_srv_rec.attribute5;
    p6_a19 := ddx_srv_rec.attribute6;
    p6_a20 := ddx_srv_rec.attribute7;
    p6_a21 := ddx_srv_rec.attribute8;
    p6_a22 := ddx_srv_rec.attribute9;
    p6_a23 := ddx_srv_rec.attribute10;
    p6_a24 := ddx_srv_rec.attribute11;
    p6_a25 := ddx_srv_rec.attribute12;
    p6_a26 := ddx_srv_rec.attribute13;
    p6_a27 := ddx_srv_rec.attribute14;
    p6_a28 := ddx_srv_rec.attribute15;
    p6_a29 := ddx_srv_rec.created_by;
    p6_a30 := ddx_srv_rec.creation_date;
    p6_a31 := ddx_srv_rec.last_updated_by;
    p6_a32 := ddx_srv_rec.last_update_date;
    p6_a33 := ddx_srv_rec.last_update_login;
  end;

  procedure insert_srt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  DATE
    , p5_a15  DATE
    , p5_a16  NUMBER
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  DATE
    , p5_a35  NUMBER
    , p5_a36  DATE
    , p5_a37  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  DATE
    , p6_a6  VARCHAR2
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  NUMBER
    , p6_a30  DATE
    , p6_a31  NUMBER
    , p6_a32  DATE
    , p6_a33  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  DATE
    , p7_a16 out nocopy  NUMBER
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  DATE
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  DATE
    , p7_a37 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  DATE
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
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
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  DATE
    , p8_a31 out nocopy  NUMBER
    , p8_a32 out nocopy  DATE
    , p8_a33 out nocopy  NUMBER
  )

  as
    ddp_srtv_rec okl_fe_std_rate_tmpl_pub.okl_srtv_rec;
    ddp_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddx_srtv_rec okl_fe_std_rate_tmpl_pub.okl_srtv_rec;
    ddx_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srtv_rec.std_rate_tmpl_id := p5_a0;
    ddp_srtv_rec.template_name := p5_a1;
    ddp_srtv_rec.template_desc := p5_a2;
    ddp_srtv_rec.object_version_number := p5_a3;
    ddp_srtv_rec.org_id := p5_a4;
    ddp_srtv_rec.currency_code := p5_a5;
    ddp_srtv_rec.rate_card_yn := p5_a6;
    ddp_srtv_rec.pricing_engine_code := p5_a7;
    ddp_srtv_rec.orig_std_rate_tmpl_id := p5_a8;
    ddp_srtv_rec.rate_type_code := p5_a9;
    ddp_srtv_rec.frequency_code := p5_a10;
    ddp_srtv_rec.index_id := p5_a11;
    ddp_srtv_rec.default_yn := p5_a12;
    ddp_srtv_rec.sts_code := p5_a13;
    ddp_srtv_rec.effective_from_date := p5_a14;
    ddp_srtv_rec.effective_to_date := p5_a15;
    ddp_srtv_rec.srt_rate := p5_a16;
    ddp_srtv_rec.attribute_category := p5_a17;
    ddp_srtv_rec.attribute1 := p5_a18;
    ddp_srtv_rec.attribute2 := p5_a19;
    ddp_srtv_rec.attribute3 := p5_a20;
    ddp_srtv_rec.attribute4 := p5_a21;
    ddp_srtv_rec.attribute5 := p5_a22;
    ddp_srtv_rec.attribute6 := p5_a23;
    ddp_srtv_rec.attribute7 := p5_a24;
    ddp_srtv_rec.attribute8 := p5_a25;
    ddp_srtv_rec.attribute9 := p5_a26;
    ddp_srtv_rec.attribute10 := p5_a27;
    ddp_srtv_rec.attribute11 := p5_a28;
    ddp_srtv_rec.attribute12 := p5_a29;
    ddp_srtv_rec.attribute13 := p5_a30;
    ddp_srtv_rec.attribute14 := p5_a31;
    ddp_srtv_rec.attribute15 := p5_a32;
    ddp_srtv_rec.created_by := p5_a33;
    ddp_srtv_rec.creation_date := p5_a34;
    ddp_srtv_rec.last_updated_by := p5_a35;
    ddp_srtv_rec.last_update_date := p5_a36;
    ddp_srtv_rec.last_update_login := p5_a37;

    ddp_srv_rec.std_rate_tmpl_ver_id := p6_a0;
    ddp_srv_rec.object_version_number := p6_a1;
    ddp_srv_rec.version_number := p6_a2;
    ddp_srv_rec.std_rate_tmpl_id := p6_a3;
    ddp_srv_rec.effective_from_date := p6_a4;
    ddp_srv_rec.effective_to_date := p6_a5;
    ddp_srv_rec.sts_code := p6_a6;
    ddp_srv_rec.adj_mat_version_id := p6_a7;
    ddp_srv_rec.srt_rate := p6_a8;
    ddp_srv_rec.spread := p6_a9;
    ddp_srv_rec.day_convention_code := p6_a10;
    ddp_srv_rec.min_adj_rate := p6_a11;
    ddp_srv_rec.max_adj_rate := p6_a12;
    ddp_srv_rec.attribute_category := p6_a13;
    ddp_srv_rec.attribute1 := p6_a14;
    ddp_srv_rec.attribute2 := p6_a15;
    ddp_srv_rec.attribute3 := p6_a16;
    ddp_srv_rec.attribute4 := p6_a17;
    ddp_srv_rec.attribute5 := p6_a18;
    ddp_srv_rec.attribute6 := p6_a19;
    ddp_srv_rec.attribute7 := p6_a20;
    ddp_srv_rec.attribute8 := p6_a21;
    ddp_srv_rec.attribute9 := p6_a22;
    ddp_srv_rec.attribute10 := p6_a23;
    ddp_srv_rec.attribute11 := p6_a24;
    ddp_srv_rec.attribute12 := p6_a25;
    ddp_srv_rec.attribute13 := p6_a26;
    ddp_srv_rec.attribute14 := p6_a27;
    ddp_srv_rec.attribute15 := p6_a28;
    ddp_srv_rec.created_by := p6_a29;
    ddp_srv_rec.creation_date := p6_a30;
    ddp_srv_rec.last_updated_by := p6_a31;
    ddp_srv_rec.last_update_date := p6_a32;
    ddp_srv_rec.last_update_login := p6_a33;



    -- here's the delegated call to the old PL/SQL routine
    okl_fe_std_rate_tmpl_pub.insert_srt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srtv_rec,
      ddp_srv_rec,
      ddx_srtv_rec,
      ddx_srv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_srtv_rec.std_rate_tmpl_id;
    p7_a1 := ddx_srtv_rec.template_name;
    p7_a2 := ddx_srtv_rec.template_desc;
    p7_a3 := ddx_srtv_rec.object_version_number;
    p7_a4 := ddx_srtv_rec.org_id;
    p7_a5 := ddx_srtv_rec.currency_code;
    p7_a6 := ddx_srtv_rec.rate_card_yn;
    p7_a7 := ddx_srtv_rec.pricing_engine_code;
    p7_a8 := ddx_srtv_rec.orig_std_rate_tmpl_id;
    p7_a9 := ddx_srtv_rec.rate_type_code;
    p7_a10 := ddx_srtv_rec.frequency_code;
    p7_a11 := ddx_srtv_rec.index_id;
    p7_a12 := ddx_srtv_rec.default_yn;
    p7_a13 := ddx_srtv_rec.sts_code;
    p7_a14 := ddx_srtv_rec.effective_from_date;
    p7_a15 := ddx_srtv_rec.effective_to_date;
    p7_a16 := ddx_srtv_rec.srt_rate;
    p7_a17 := ddx_srtv_rec.attribute_category;
    p7_a18 := ddx_srtv_rec.attribute1;
    p7_a19 := ddx_srtv_rec.attribute2;
    p7_a20 := ddx_srtv_rec.attribute3;
    p7_a21 := ddx_srtv_rec.attribute4;
    p7_a22 := ddx_srtv_rec.attribute5;
    p7_a23 := ddx_srtv_rec.attribute6;
    p7_a24 := ddx_srtv_rec.attribute7;
    p7_a25 := ddx_srtv_rec.attribute8;
    p7_a26 := ddx_srtv_rec.attribute9;
    p7_a27 := ddx_srtv_rec.attribute10;
    p7_a28 := ddx_srtv_rec.attribute11;
    p7_a29 := ddx_srtv_rec.attribute12;
    p7_a30 := ddx_srtv_rec.attribute13;
    p7_a31 := ddx_srtv_rec.attribute14;
    p7_a32 := ddx_srtv_rec.attribute15;
    p7_a33 := ddx_srtv_rec.created_by;
    p7_a34 := ddx_srtv_rec.creation_date;
    p7_a35 := ddx_srtv_rec.last_updated_by;
    p7_a36 := ddx_srtv_rec.last_update_date;
    p7_a37 := ddx_srtv_rec.last_update_login;

    p8_a0 := ddx_srv_rec.std_rate_tmpl_ver_id;
    p8_a1 := ddx_srv_rec.object_version_number;
    p8_a2 := ddx_srv_rec.version_number;
    p8_a3 := ddx_srv_rec.std_rate_tmpl_id;
    p8_a4 := ddx_srv_rec.effective_from_date;
    p8_a5 := ddx_srv_rec.effective_to_date;
    p8_a6 := ddx_srv_rec.sts_code;
    p8_a7 := ddx_srv_rec.adj_mat_version_id;
    p8_a8 := ddx_srv_rec.srt_rate;
    p8_a9 := ddx_srv_rec.spread;
    p8_a10 := ddx_srv_rec.day_convention_code;
    p8_a11 := ddx_srv_rec.min_adj_rate;
    p8_a12 := ddx_srv_rec.max_adj_rate;
    p8_a13 := ddx_srv_rec.attribute_category;
    p8_a14 := ddx_srv_rec.attribute1;
    p8_a15 := ddx_srv_rec.attribute2;
    p8_a16 := ddx_srv_rec.attribute3;
    p8_a17 := ddx_srv_rec.attribute4;
    p8_a18 := ddx_srv_rec.attribute5;
    p8_a19 := ddx_srv_rec.attribute6;
    p8_a20 := ddx_srv_rec.attribute7;
    p8_a21 := ddx_srv_rec.attribute8;
    p8_a22 := ddx_srv_rec.attribute9;
    p8_a23 := ddx_srv_rec.attribute10;
    p8_a24 := ddx_srv_rec.attribute11;
    p8_a25 := ddx_srv_rec.attribute12;
    p8_a26 := ddx_srv_rec.attribute13;
    p8_a27 := ddx_srv_rec.attribute14;
    p8_a28 := ddx_srv_rec.attribute15;
    p8_a29 := ddx_srv_rec.created_by;
    p8_a30 := ddx_srv_rec.creation_date;
    p8_a31 := ddx_srv_rec.last_updated_by;
    p8_a32 := ddx_srv_rec.last_update_date;
    p8_a33 := ddx_srv_rec.last_update_login;
  end;

  procedure update_srt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  NUMBER
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
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
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
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  DATE
    , p6_a33 out nocopy  NUMBER
  )

  as
    ddp_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddx_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srv_rec.std_rate_tmpl_ver_id := p5_a0;
    ddp_srv_rec.object_version_number := p5_a1;
    ddp_srv_rec.version_number := p5_a2;
    ddp_srv_rec.std_rate_tmpl_id := p5_a3;
    ddp_srv_rec.effective_from_date := p5_a4;
    ddp_srv_rec.effective_to_date := p5_a5;
    ddp_srv_rec.sts_code := p5_a6;
    ddp_srv_rec.adj_mat_version_id := p5_a7;
    ddp_srv_rec.srt_rate := p5_a8;
    ddp_srv_rec.spread := p5_a9;
    ddp_srv_rec.day_convention_code := p5_a10;
    ddp_srv_rec.min_adj_rate := p5_a11;
    ddp_srv_rec.max_adj_rate := p5_a12;
    ddp_srv_rec.attribute_category := p5_a13;
    ddp_srv_rec.attribute1 := p5_a14;
    ddp_srv_rec.attribute2 := p5_a15;
    ddp_srv_rec.attribute3 := p5_a16;
    ddp_srv_rec.attribute4 := p5_a17;
    ddp_srv_rec.attribute5 := p5_a18;
    ddp_srv_rec.attribute6 := p5_a19;
    ddp_srv_rec.attribute7 := p5_a20;
    ddp_srv_rec.attribute8 := p5_a21;
    ddp_srv_rec.attribute9 := p5_a22;
    ddp_srv_rec.attribute10 := p5_a23;
    ddp_srv_rec.attribute11 := p5_a24;
    ddp_srv_rec.attribute12 := p5_a25;
    ddp_srv_rec.attribute13 := p5_a26;
    ddp_srv_rec.attribute14 := p5_a27;
    ddp_srv_rec.attribute15 := p5_a28;
    ddp_srv_rec.created_by := p5_a29;
    ddp_srv_rec.creation_date := p5_a30;
    ddp_srv_rec.last_updated_by := p5_a31;
    ddp_srv_rec.last_update_date := p5_a32;
    ddp_srv_rec.last_update_login := p5_a33;


    -- here's the delegated call to the old PL/SQL routine
    okl_fe_std_rate_tmpl_pub.update_srt(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srv_rec,
      ddx_srv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_srv_rec.std_rate_tmpl_ver_id;
    p6_a1 := ddx_srv_rec.object_version_number;
    p6_a2 := ddx_srv_rec.version_number;
    p6_a3 := ddx_srv_rec.std_rate_tmpl_id;
    p6_a4 := ddx_srv_rec.effective_from_date;
    p6_a5 := ddx_srv_rec.effective_to_date;
    p6_a6 := ddx_srv_rec.sts_code;
    p6_a7 := ddx_srv_rec.adj_mat_version_id;
    p6_a8 := ddx_srv_rec.srt_rate;
    p6_a9 := ddx_srv_rec.spread;
    p6_a10 := ddx_srv_rec.day_convention_code;
    p6_a11 := ddx_srv_rec.min_adj_rate;
    p6_a12 := ddx_srv_rec.max_adj_rate;
    p6_a13 := ddx_srv_rec.attribute_category;
    p6_a14 := ddx_srv_rec.attribute1;
    p6_a15 := ddx_srv_rec.attribute2;
    p6_a16 := ddx_srv_rec.attribute3;
    p6_a17 := ddx_srv_rec.attribute4;
    p6_a18 := ddx_srv_rec.attribute5;
    p6_a19 := ddx_srv_rec.attribute6;
    p6_a20 := ddx_srv_rec.attribute7;
    p6_a21 := ddx_srv_rec.attribute8;
    p6_a22 := ddx_srv_rec.attribute9;
    p6_a23 := ddx_srv_rec.attribute10;
    p6_a24 := ddx_srv_rec.attribute11;
    p6_a25 := ddx_srv_rec.attribute12;
    p6_a26 := ddx_srv_rec.attribute13;
    p6_a27 := ddx_srv_rec.attribute14;
    p6_a28 := ddx_srv_rec.attribute15;
    p6_a29 := ddx_srv_rec.created_by;
    p6_a30 := ddx_srv_rec.creation_date;
    p6_a31 := ddx_srv_rec.last_updated_by;
    p6_a32 := ddx_srv_rec.last_update_date;
    p6_a33 := ddx_srv_rec.last_update_login;
  end;

  procedure invalid_objects(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_version_id  NUMBER
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_obj_tbl okl_fe_std_rate_tmpl_pub.invalid_object_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_fe_std_rate_tmpl_pub.invalid_objects(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_version_id,
      ddx_obj_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_fe_std_rate_tmpl_pvt_w.rosetta_table_copy_out_p8(ddx_obj_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      );
  end;

  procedure calc_start_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  DATE
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  NUMBER
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
    , p5_a29  NUMBER
    , p5_a30  DATE
    , p5_a31  NUMBER
    , p5_a32  DATE
    , p5_a33  NUMBER
    , x_cal_eff_from out nocopy  DATE
  )

  as
    ddp_srv_rec okl_fe_std_rate_tmpl_pub.okl_srv_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_srv_rec.std_rate_tmpl_ver_id := p5_a0;
    ddp_srv_rec.object_version_number := p5_a1;
    ddp_srv_rec.version_number := p5_a2;
    ddp_srv_rec.std_rate_tmpl_id := p5_a3;
    ddp_srv_rec.effective_from_date := p5_a4;
    ddp_srv_rec.effective_to_date := p5_a5;
    ddp_srv_rec.sts_code := p5_a6;
    ddp_srv_rec.adj_mat_version_id := p5_a7;
    ddp_srv_rec.srt_rate := p5_a8;
    ddp_srv_rec.spread := p5_a9;
    ddp_srv_rec.day_convention_code := p5_a10;
    ddp_srv_rec.min_adj_rate := p5_a11;
    ddp_srv_rec.max_adj_rate := p5_a12;
    ddp_srv_rec.attribute_category := p5_a13;
    ddp_srv_rec.attribute1 := p5_a14;
    ddp_srv_rec.attribute2 := p5_a15;
    ddp_srv_rec.attribute3 := p5_a16;
    ddp_srv_rec.attribute4 := p5_a17;
    ddp_srv_rec.attribute5 := p5_a18;
    ddp_srv_rec.attribute6 := p5_a19;
    ddp_srv_rec.attribute7 := p5_a20;
    ddp_srv_rec.attribute8 := p5_a21;
    ddp_srv_rec.attribute9 := p5_a22;
    ddp_srv_rec.attribute10 := p5_a23;
    ddp_srv_rec.attribute11 := p5_a24;
    ddp_srv_rec.attribute12 := p5_a25;
    ddp_srv_rec.attribute13 := p5_a26;
    ddp_srv_rec.attribute14 := p5_a27;
    ddp_srv_rec.attribute15 := p5_a28;
    ddp_srv_rec.created_by := p5_a29;
    ddp_srv_rec.creation_date := p5_a30;
    ddp_srv_rec.last_updated_by := p5_a31;
    ddp_srv_rec.last_update_date := p5_a32;
    ddp_srv_rec.last_update_login := p5_a33;


    -- here's the delegated call to the old PL/SQL routine
    okl_fe_std_rate_tmpl_pub.calc_start_date(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_srv_rec,
      x_cal_eff_from);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_fe_std_rate_tmpl_pub_w;

/
