--------------------------------------------------------
--  DDL for Package Body OKL_FE_ADJ_MATRIX_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_ADJ_MATRIX_PUB_W" as
  /* $Header: OKLUPAMB.pls 120.0 2005/07/07 10:46:20 viselvar noship $ */
  procedure get_version(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_adj_mat_id  NUMBER
    , p_version_number  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  DATE
    , p7_a8 out nocopy  DATE
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
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  VARCHAR2
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
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  DATE
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  NUMBER
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
    ddx_pamv_rec okl_fe_adj_matrix_pub.okl_pamv_rec;
    ddx_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddx_ech_rec okl_fe_adj_matrix_pub.okl_ech_rec;
    ddx_ecl_tbl okl_fe_adj_matrix_pub.okl_ecl_tbl;
    ddx_ecv_tbl okl_fe_adj_matrix_pub.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    okl_fe_adj_matrix_pub.get_version(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_adj_mat_id,
      p_version_number,
      ddx_pamv_rec,
      ddx_pal_rec,
      ddx_ech_rec,
      ddx_ecl_tbl,
      ddx_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_pamv_rec.adj_mat_id;
    p7_a1 := ddx_pamv_rec.object_version_number;
    p7_a2 := ddx_pamv_rec.org_id;
    p7_a3 := ddx_pamv_rec.currency_code;
    p7_a4 := ddx_pamv_rec.adj_mat_type_code;
    p7_a5 := ddx_pamv_rec.orig_adj_mat_id;
    p7_a6 := ddx_pamv_rec.sts_code;
    p7_a7 := ddx_pamv_rec.effective_from_date;
    p7_a8 := ddx_pamv_rec.effective_to_date;
    p7_a9 := ddx_pamv_rec.attribute_category;
    p7_a10 := ddx_pamv_rec.attribute1;
    p7_a11 := ddx_pamv_rec.attribute2;
    p7_a12 := ddx_pamv_rec.attribute3;
    p7_a13 := ddx_pamv_rec.attribute4;
    p7_a14 := ddx_pamv_rec.attribute5;
    p7_a15 := ddx_pamv_rec.attribute6;
    p7_a16 := ddx_pamv_rec.attribute7;
    p7_a17 := ddx_pamv_rec.attribute8;
    p7_a18 := ddx_pamv_rec.attribute9;
    p7_a19 := ddx_pamv_rec.attribute10;
    p7_a20 := ddx_pamv_rec.attribute11;
    p7_a21 := ddx_pamv_rec.attribute12;
    p7_a22 := ddx_pamv_rec.attribute13;
    p7_a23 := ddx_pamv_rec.attribute14;
    p7_a24 := ddx_pamv_rec.attribute15;
    p7_a25 := ddx_pamv_rec.created_by;
    p7_a26 := ddx_pamv_rec.creation_date;
    p7_a27 := ddx_pamv_rec.last_updated_by;
    p7_a28 := ddx_pamv_rec.last_update_date;
    p7_a29 := ddx_pamv_rec.last_update_login;
    p7_a30 := ddx_pamv_rec.adj_mat_name;
    p7_a31 := ddx_pamv_rec.adj_mat_desc;

    p8_a0 := ddx_pal_rec.adj_mat_version_id;
    p8_a1 := ddx_pal_rec.object_version_number;
    p8_a2 := ddx_pal_rec.version_number;
    p8_a3 := ddx_pal_rec.adj_mat_id;
    p8_a4 := ddx_pal_rec.sts_code;
    p8_a5 := ddx_pal_rec.effective_from_date;
    p8_a6 := ddx_pal_rec.effective_to_date;
    p8_a7 := ddx_pal_rec.attribute_category;
    p8_a8 := ddx_pal_rec.attribute1;
    p8_a9 := ddx_pal_rec.attribute2;
    p8_a10 := ddx_pal_rec.attribute3;
    p8_a11 := ddx_pal_rec.attribute4;
    p8_a12 := ddx_pal_rec.attribute5;
    p8_a13 := ddx_pal_rec.attribute6;
    p8_a14 := ddx_pal_rec.attribute7;
    p8_a15 := ddx_pal_rec.attribute8;
    p8_a16 := ddx_pal_rec.attribute9;
    p8_a17 := ddx_pal_rec.attribute10;
    p8_a18 := ddx_pal_rec.attribute11;
    p8_a19 := ddx_pal_rec.attribute12;
    p8_a20 := ddx_pal_rec.attribute13;
    p8_a21 := ddx_pal_rec.attribute14;
    p8_a22 := ddx_pal_rec.attribute15;
    p8_a23 := ddx_pal_rec.created_by;
    p8_a24 := ddx_pal_rec.creation_date;
    p8_a25 := ddx_pal_rec.last_updated_by;
    p8_a26 := ddx_pal_rec.last_update_date;
    p8_a27 := ddx_pal_rec.last_update_login;

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
    , p_adj_mat_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  DATE
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
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  DATE
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  DATE
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
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
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
    ddx_pamv_rec okl_fe_adj_matrix_pub.okl_pamv_rec;
    ddx_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddx_ech_rec okl_fe_adj_matrix_pub.okl_ech_rec;
    ddx_ecl_tbl okl_fe_adj_matrix_pub.okl_ecl_tbl;
    ddx_ecv_tbl okl_fe_adj_matrix_pub.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    okl_fe_adj_matrix_pub.get_version(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_adj_mat_id,
      ddx_pamv_rec,
      ddx_pal_rec,
      ddx_ech_rec,
      ddx_ecl_tbl,
      ddx_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_pamv_rec.adj_mat_id;
    p6_a1 := ddx_pamv_rec.object_version_number;
    p6_a2 := ddx_pamv_rec.org_id;
    p6_a3 := ddx_pamv_rec.currency_code;
    p6_a4 := ddx_pamv_rec.adj_mat_type_code;
    p6_a5 := ddx_pamv_rec.orig_adj_mat_id;
    p6_a6 := ddx_pamv_rec.sts_code;
    p6_a7 := ddx_pamv_rec.effective_from_date;
    p6_a8 := ddx_pamv_rec.effective_to_date;
    p6_a9 := ddx_pamv_rec.attribute_category;
    p6_a10 := ddx_pamv_rec.attribute1;
    p6_a11 := ddx_pamv_rec.attribute2;
    p6_a12 := ddx_pamv_rec.attribute3;
    p6_a13 := ddx_pamv_rec.attribute4;
    p6_a14 := ddx_pamv_rec.attribute5;
    p6_a15 := ddx_pamv_rec.attribute6;
    p6_a16 := ddx_pamv_rec.attribute7;
    p6_a17 := ddx_pamv_rec.attribute8;
    p6_a18 := ddx_pamv_rec.attribute9;
    p6_a19 := ddx_pamv_rec.attribute10;
    p6_a20 := ddx_pamv_rec.attribute11;
    p6_a21 := ddx_pamv_rec.attribute12;
    p6_a22 := ddx_pamv_rec.attribute13;
    p6_a23 := ddx_pamv_rec.attribute14;
    p6_a24 := ddx_pamv_rec.attribute15;
    p6_a25 := ddx_pamv_rec.created_by;
    p6_a26 := ddx_pamv_rec.creation_date;
    p6_a27 := ddx_pamv_rec.last_updated_by;
    p6_a28 := ddx_pamv_rec.last_update_date;
    p6_a29 := ddx_pamv_rec.last_update_login;
    p6_a30 := ddx_pamv_rec.adj_mat_name;
    p6_a31 := ddx_pamv_rec.adj_mat_desc;

    p7_a0 := ddx_pal_rec.adj_mat_version_id;
    p7_a1 := ddx_pal_rec.object_version_number;
    p7_a2 := ddx_pal_rec.version_number;
    p7_a3 := ddx_pal_rec.adj_mat_id;
    p7_a4 := ddx_pal_rec.sts_code;
    p7_a5 := ddx_pal_rec.effective_from_date;
    p7_a6 := ddx_pal_rec.effective_to_date;
    p7_a7 := ddx_pal_rec.attribute_category;
    p7_a8 := ddx_pal_rec.attribute1;
    p7_a9 := ddx_pal_rec.attribute2;
    p7_a10 := ddx_pal_rec.attribute3;
    p7_a11 := ddx_pal_rec.attribute4;
    p7_a12 := ddx_pal_rec.attribute5;
    p7_a13 := ddx_pal_rec.attribute6;
    p7_a14 := ddx_pal_rec.attribute7;
    p7_a15 := ddx_pal_rec.attribute8;
    p7_a16 := ddx_pal_rec.attribute9;
    p7_a17 := ddx_pal_rec.attribute10;
    p7_a18 := ddx_pal_rec.attribute11;
    p7_a19 := ddx_pal_rec.attribute12;
    p7_a20 := ddx_pal_rec.attribute13;
    p7_a21 := ddx_pal_rec.attribute14;
    p7_a22 := ddx_pal_rec.attribute15;
    p7_a23 := ddx_pal_rec.created_by;
    p7_a24 := ddx_pal_rec.creation_date;
    p7_a25 := ddx_pal_rec.last_updated_by;
    p7_a26 := ddx_pal_rec.last_update_date;
    p7_a27 := ddx_pal_rec.last_update_login;

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
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
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
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
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
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
  )

  as
    ddp_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddx_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pal_rec.adj_mat_version_id := p5_a0;
    ddp_pal_rec.object_version_number := p5_a1;
    ddp_pal_rec.version_number := p5_a2;
    ddp_pal_rec.adj_mat_id := p5_a3;
    ddp_pal_rec.sts_code := p5_a4;
    ddp_pal_rec.effective_from_date := p5_a5;
    ddp_pal_rec.effective_to_date := p5_a6;
    ddp_pal_rec.attribute_category := p5_a7;
    ddp_pal_rec.attribute1 := p5_a8;
    ddp_pal_rec.attribute2 := p5_a9;
    ddp_pal_rec.attribute3 := p5_a10;
    ddp_pal_rec.attribute4 := p5_a11;
    ddp_pal_rec.attribute5 := p5_a12;
    ddp_pal_rec.attribute6 := p5_a13;
    ddp_pal_rec.attribute7 := p5_a14;
    ddp_pal_rec.attribute8 := p5_a15;
    ddp_pal_rec.attribute9 := p5_a16;
    ddp_pal_rec.attribute10 := p5_a17;
    ddp_pal_rec.attribute11 := p5_a18;
    ddp_pal_rec.attribute12 := p5_a19;
    ddp_pal_rec.attribute13 := p5_a20;
    ddp_pal_rec.attribute14 := p5_a21;
    ddp_pal_rec.attribute15 := p5_a22;
    ddp_pal_rec.created_by := p5_a23;
    ddp_pal_rec.creation_date := p5_a24;
    ddp_pal_rec.last_updated_by := p5_a25;
    ddp_pal_rec.last_update_date := p5_a26;
    ddp_pal_rec.last_update_login := p5_a27;


    -- here's the delegated call to the old PL/SQL routine
    okl_fe_adj_matrix_pub.create_version(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pal_rec,
      ddx_pal_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_pal_rec.adj_mat_version_id;
    p6_a1 := ddx_pal_rec.object_version_number;
    p6_a2 := ddx_pal_rec.version_number;
    p6_a3 := ddx_pal_rec.adj_mat_id;
    p6_a4 := ddx_pal_rec.sts_code;
    p6_a5 := ddx_pal_rec.effective_from_date;
    p6_a6 := ddx_pal_rec.effective_to_date;
    p6_a7 := ddx_pal_rec.attribute_category;
    p6_a8 := ddx_pal_rec.attribute1;
    p6_a9 := ddx_pal_rec.attribute2;
    p6_a10 := ddx_pal_rec.attribute3;
    p6_a11 := ddx_pal_rec.attribute4;
    p6_a12 := ddx_pal_rec.attribute5;
    p6_a13 := ddx_pal_rec.attribute6;
    p6_a14 := ddx_pal_rec.attribute7;
    p6_a15 := ddx_pal_rec.attribute8;
    p6_a16 := ddx_pal_rec.attribute9;
    p6_a17 := ddx_pal_rec.attribute10;
    p6_a18 := ddx_pal_rec.attribute11;
    p6_a19 := ddx_pal_rec.attribute12;
    p6_a20 := ddx_pal_rec.attribute13;
    p6_a21 := ddx_pal_rec.attribute14;
    p6_a22 := ddx_pal_rec.attribute15;
    p6_a23 := ddx_pal_rec.created_by;
    p6_a24 := ddx_pal_rec.creation_date;
    p6_a25 := ddx_pal_rec.last_updated_by;
    p6_a26 := ddx_pal_rec.last_update_date;
    p6_a27 := ddx_pal_rec.last_update_login;
  end;

  procedure insert_adj_mat(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  DATE
    , p5_a8  DATE
    , p5_a9  VARCHAR2
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
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  NUMBER
    , p6_a4  VARCHAR2
    , p6_a5  DATE
    , p6_a6  DATE
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
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
    , p6_a23  NUMBER
    , p6_a24  DATE
    , p6_a25  NUMBER
    , p6_a26  DATE
    , p6_a27  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  DATE
    , p7_a8 out nocopy  DATE
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
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  DATE
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  VARCHAR2
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
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  DATE
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  NUMBER
  )

  as
    ddp_pamv_rec okl_fe_adj_matrix_pub.okl_pamv_rec;
    ddp_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddx_pamv_rec okl_fe_adj_matrix_pub.okl_pamv_rec;
    ddx_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pamv_rec.adj_mat_id := p5_a0;
    ddp_pamv_rec.object_version_number := p5_a1;
    ddp_pamv_rec.org_id := p5_a2;
    ddp_pamv_rec.currency_code := p5_a3;
    ddp_pamv_rec.adj_mat_type_code := p5_a4;
    ddp_pamv_rec.orig_adj_mat_id := p5_a5;
    ddp_pamv_rec.sts_code := p5_a6;
    ddp_pamv_rec.effective_from_date := p5_a7;
    ddp_pamv_rec.effective_to_date := p5_a8;
    ddp_pamv_rec.attribute_category := p5_a9;
    ddp_pamv_rec.attribute1 := p5_a10;
    ddp_pamv_rec.attribute2 := p5_a11;
    ddp_pamv_rec.attribute3 := p5_a12;
    ddp_pamv_rec.attribute4 := p5_a13;
    ddp_pamv_rec.attribute5 := p5_a14;
    ddp_pamv_rec.attribute6 := p5_a15;
    ddp_pamv_rec.attribute7 := p5_a16;
    ddp_pamv_rec.attribute8 := p5_a17;
    ddp_pamv_rec.attribute9 := p5_a18;
    ddp_pamv_rec.attribute10 := p5_a19;
    ddp_pamv_rec.attribute11 := p5_a20;
    ddp_pamv_rec.attribute12 := p5_a21;
    ddp_pamv_rec.attribute13 := p5_a22;
    ddp_pamv_rec.attribute14 := p5_a23;
    ddp_pamv_rec.attribute15 := p5_a24;
    ddp_pamv_rec.created_by := p5_a25;
    ddp_pamv_rec.creation_date := p5_a26;
    ddp_pamv_rec.last_updated_by := p5_a27;
    ddp_pamv_rec.last_update_date := p5_a28;
    ddp_pamv_rec.last_update_login := p5_a29;
    ddp_pamv_rec.adj_mat_name := p5_a30;
    ddp_pamv_rec.adj_mat_desc := p5_a31;

    ddp_pal_rec.adj_mat_version_id := p6_a0;
    ddp_pal_rec.object_version_number := p6_a1;
    ddp_pal_rec.version_number := p6_a2;
    ddp_pal_rec.adj_mat_id := p6_a3;
    ddp_pal_rec.sts_code := p6_a4;
    ddp_pal_rec.effective_from_date := p6_a5;
    ddp_pal_rec.effective_to_date := p6_a6;
    ddp_pal_rec.attribute_category := p6_a7;
    ddp_pal_rec.attribute1 := p6_a8;
    ddp_pal_rec.attribute2 := p6_a9;
    ddp_pal_rec.attribute3 := p6_a10;
    ddp_pal_rec.attribute4 := p6_a11;
    ddp_pal_rec.attribute5 := p6_a12;
    ddp_pal_rec.attribute6 := p6_a13;
    ddp_pal_rec.attribute7 := p6_a14;
    ddp_pal_rec.attribute8 := p6_a15;
    ddp_pal_rec.attribute9 := p6_a16;
    ddp_pal_rec.attribute10 := p6_a17;
    ddp_pal_rec.attribute11 := p6_a18;
    ddp_pal_rec.attribute12 := p6_a19;
    ddp_pal_rec.attribute13 := p6_a20;
    ddp_pal_rec.attribute14 := p6_a21;
    ddp_pal_rec.attribute15 := p6_a22;
    ddp_pal_rec.created_by := p6_a23;
    ddp_pal_rec.creation_date := p6_a24;
    ddp_pal_rec.last_updated_by := p6_a25;
    ddp_pal_rec.last_update_date := p6_a26;
    ddp_pal_rec.last_update_login := p6_a27;



    -- here's the delegated call to the old PL/SQL routine
    okl_fe_adj_matrix_pub.insert_adj_mat(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pamv_rec,
      ddp_pal_rec,
      ddx_pamv_rec,
      ddx_pal_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_pamv_rec.adj_mat_id;
    p7_a1 := ddx_pamv_rec.object_version_number;
    p7_a2 := ddx_pamv_rec.org_id;
    p7_a3 := ddx_pamv_rec.currency_code;
    p7_a4 := ddx_pamv_rec.adj_mat_type_code;
    p7_a5 := ddx_pamv_rec.orig_adj_mat_id;
    p7_a6 := ddx_pamv_rec.sts_code;
    p7_a7 := ddx_pamv_rec.effective_from_date;
    p7_a8 := ddx_pamv_rec.effective_to_date;
    p7_a9 := ddx_pamv_rec.attribute_category;
    p7_a10 := ddx_pamv_rec.attribute1;
    p7_a11 := ddx_pamv_rec.attribute2;
    p7_a12 := ddx_pamv_rec.attribute3;
    p7_a13 := ddx_pamv_rec.attribute4;
    p7_a14 := ddx_pamv_rec.attribute5;
    p7_a15 := ddx_pamv_rec.attribute6;
    p7_a16 := ddx_pamv_rec.attribute7;
    p7_a17 := ddx_pamv_rec.attribute8;
    p7_a18 := ddx_pamv_rec.attribute9;
    p7_a19 := ddx_pamv_rec.attribute10;
    p7_a20 := ddx_pamv_rec.attribute11;
    p7_a21 := ddx_pamv_rec.attribute12;
    p7_a22 := ddx_pamv_rec.attribute13;
    p7_a23 := ddx_pamv_rec.attribute14;
    p7_a24 := ddx_pamv_rec.attribute15;
    p7_a25 := ddx_pamv_rec.created_by;
    p7_a26 := ddx_pamv_rec.creation_date;
    p7_a27 := ddx_pamv_rec.last_updated_by;
    p7_a28 := ddx_pamv_rec.last_update_date;
    p7_a29 := ddx_pamv_rec.last_update_login;
    p7_a30 := ddx_pamv_rec.adj_mat_name;
    p7_a31 := ddx_pamv_rec.adj_mat_desc;

    p8_a0 := ddx_pal_rec.adj_mat_version_id;
    p8_a1 := ddx_pal_rec.object_version_number;
    p8_a2 := ddx_pal_rec.version_number;
    p8_a3 := ddx_pal_rec.adj_mat_id;
    p8_a4 := ddx_pal_rec.sts_code;
    p8_a5 := ddx_pal_rec.effective_from_date;
    p8_a6 := ddx_pal_rec.effective_to_date;
    p8_a7 := ddx_pal_rec.attribute_category;
    p8_a8 := ddx_pal_rec.attribute1;
    p8_a9 := ddx_pal_rec.attribute2;
    p8_a10 := ddx_pal_rec.attribute3;
    p8_a11 := ddx_pal_rec.attribute4;
    p8_a12 := ddx_pal_rec.attribute5;
    p8_a13 := ddx_pal_rec.attribute6;
    p8_a14 := ddx_pal_rec.attribute7;
    p8_a15 := ddx_pal_rec.attribute8;
    p8_a16 := ddx_pal_rec.attribute9;
    p8_a17 := ddx_pal_rec.attribute10;
    p8_a18 := ddx_pal_rec.attribute11;
    p8_a19 := ddx_pal_rec.attribute12;
    p8_a20 := ddx_pal_rec.attribute13;
    p8_a21 := ddx_pal_rec.attribute14;
    p8_a22 := ddx_pal_rec.attribute15;
    p8_a23 := ddx_pal_rec.created_by;
    p8_a24 := ddx_pal_rec.creation_date;
    p8_a25 := ddx_pal_rec.last_updated_by;
    p8_a26 := ddx_pal_rec.last_update_date;
    p8_a27 := ddx_pal_rec.last_update_login;
  end;

  procedure update_adj_mat(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
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
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
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
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  NUMBER
  )

  as
    ddp_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddx_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pal_rec.adj_mat_version_id := p5_a0;
    ddp_pal_rec.object_version_number := p5_a1;
    ddp_pal_rec.version_number := p5_a2;
    ddp_pal_rec.adj_mat_id := p5_a3;
    ddp_pal_rec.sts_code := p5_a4;
    ddp_pal_rec.effective_from_date := p5_a5;
    ddp_pal_rec.effective_to_date := p5_a6;
    ddp_pal_rec.attribute_category := p5_a7;
    ddp_pal_rec.attribute1 := p5_a8;
    ddp_pal_rec.attribute2 := p5_a9;
    ddp_pal_rec.attribute3 := p5_a10;
    ddp_pal_rec.attribute4 := p5_a11;
    ddp_pal_rec.attribute5 := p5_a12;
    ddp_pal_rec.attribute6 := p5_a13;
    ddp_pal_rec.attribute7 := p5_a14;
    ddp_pal_rec.attribute8 := p5_a15;
    ddp_pal_rec.attribute9 := p5_a16;
    ddp_pal_rec.attribute10 := p5_a17;
    ddp_pal_rec.attribute11 := p5_a18;
    ddp_pal_rec.attribute12 := p5_a19;
    ddp_pal_rec.attribute13 := p5_a20;
    ddp_pal_rec.attribute14 := p5_a21;
    ddp_pal_rec.attribute15 := p5_a22;
    ddp_pal_rec.created_by := p5_a23;
    ddp_pal_rec.creation_date := p5_a24;
    ddp_pal_rec.last_updated_by := p5_a25;
    ddp_pal_rec.last_update_date := p5_a26;
    ddp_pal_rec.last_update_login := p5_a27;


    -- here's the delegated call to the old PL/SQL routine
    okl_fe_adj_matrix_pub.update_adj_mat(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pal_rec,
      ddx_pal_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_pal_rec.adj_mat_version_id;
    p6_a1 := ddx_pal_rec.object_version_number;
    p6_a2 := ddx_pal_rec.version_number;
    p6_a3 := ddx_pal_rec.adj_mat_id;
    p6_a4 := ddx_pal_rec.sts_code;
    p6_a5 := ddx_pal_rec.effective_from_date;
    p6_a6 := ddx_pal_rec.effective_to_date;
    p6_a7 := ddx_pal_rec.attribute_category;
    p6_a8 := ddx_pal_rec.attribute1;
    p6_a9 := ddx_pal_rec.attribute2;
    p6_a10 := ddx_pal_rec.attribute3;
    p6_a11 := ddx_pal_rec.attribute4;
    p6_a12 := ddx_pal_rec.attribute5;
    p6_a13 := ddx_pal_rec.attribute6;
    p6_a14 := ddx_pal_rec.attribute7;
    p6_a15 := ddx_pal_rec.attribute8;
    p6_a16 := ddx_pal_rec.attribute9;
    p6_a17 := ddx_pal_rec.attribute10;
    p6_a18 := ddx_pal_rec.attribute11;
    p6_a19 := ddx_pal_rec.attribute12;
    p6_a20 := ddx_pal_rec.attribute13;
    p6_a21 := ddx_pal_rec.attribute14;
    p6_a22 := ddx_pal_rec.attribute15;
    p6_a23 := ddx_pal_rec.created_by;
    p6_a24 := ddx_pal_rec.creation_date;
    p6_a25 := ddx_pal_rec.last_updated_by;
    p6_a26 := ddx_pal_rec.last_update_date;
    p6_a27 := ddx_pal_rec.last_update_login;
  end;

  procedure validate_adj_mat(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
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
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  DATE
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_DATE_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_DATE_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_VARCHAR2_TABLE_300
    , p8_a8 JTF_VARCHAR2_TABLE_300
    , p8_a9 JTF_NUMBER_TABLE
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_DATE_TABLE
    , p8_a12 JTF_DATE_TABLE
    , p8_a13 JTF_VARCHAR2_TABLE_100
    , p8_a14 JTF_NUMBER_TABLE
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_DATE_TABLE
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_DATE_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_VARCHAR2_TABLE_100
    , p8_a21 JTF_VARCHAR2_TABLE_500
    , p8_a22 JTF_VARCHAR2_TABLE_500
    , p8_a23 JTF_VARCHAR2_TABLE_500
    , p8_a24 JTF_VARCHAR2_TABLE_500
    , p8_a25 JTF_VARCHAR2_TABLE_500
    , p8_a26 JTF_VARCHAR2_TABLE_500
    , p8_a27 JTF_VARCHAR2_TABLE_500
    , p8_a28 JTF_VARCHAR2_TABLE_500
    , p8_a29 JTF_VARCHAR2_TABLE_500
    , p8_a30 JTF_VARCHAR2_TABLE_500
    , p8_a31 JTF_VARCHAR2_TABLE_500
    , p8_a32 JTF_VARCHAR2_TABLE_500
    , p8_a33 JTF_VARCHAR2_TABLE_500
    , p8_a34 JTF_VARCHAR2_TABLE_500
    , p8_a35 JTF_VARCHAR2_TABLE_500
  )

  as
    ddp_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddp_ech_rec okl_fe_adj_matrix_pub.okl_ech_rec;
    ddp_ecl_tbl okl_fe_adj_matrix_pub.okl_ecl_tbl;
    ddp_ecv_tbl okl_fe_adj_matrix_pub.okl_ecv_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pal_rec.adj_mat_version_id := p5_a0;
    ddp_pal_rec.object_version_number := p5_a1;
    ddp_pal_rec.version_number := p5_a2;
    ddp_pal_rec.adj_mat_id := p5_a3;
    ddp_pal_rec.sts_code := p5_a4;
    ddp_pal_rec.effective_from_date := p5_a5;
    ddp_pal_rec.effective_to_date := p5_a6;
    ddp_pal_rec.attribute_category := p5_a7;
    ddp_pal_rec.attribute1 := p5_a8;
    ddp_pal_rec.attribute2 := p5_a9;
    ddp_pal_rec.attribute3 := p5_a10;
    ddp_pal_rec.attribute4 := p5_a11;
    ddp_pal_rec.attribute5 := p5_a12;
    ddp_pal_rec.attribute6 := p5_a13;
    ddp_pal_rec.attribute7 := p5_a14;
    ddp_pal_rec.attribute8 := p5_a15;
    ddp_pal_rec.attribute9 := p5_a16;
    ddp_pal_rec.attribute10 := p5_a17;
    ddp_pal_rec.attribute11 := p5_a18;
    ddp_pal_rec.attribute12 := p5_a19;
    ddp_pal_rec.attribute13 := p5_a20;
    ddp_pal_rec.attribute14 := p5_a21;
    ddp_pal_rec.attribute15 := p5_a22;
    ddp_pal_rec.created_by := p5_a23;
    ddp_pal_rec.creation_date := p5_a24;
    ddp_pal_rec.last_updated_by := p5_a25;
    ddp_pal_rec.last_update_date := p5_a26;
    ddp_pal_rec.last_update_login := p5_a27;

    ddp_ech_rec.criteria_set_id := p6_a0;
    ddp_ech_rec.object_version_number := p6_a1;
    ddp_ech_rec.source_id := p6_a2;
    ddp_ech_rec.source_object_code := p6_a3;
    ddp_ech_rec.match_criteria_code := p6_a4;
    ddp_ech_rec.validation_code := p6_a5;
    ddp_ech_rec.created_by := p6_a6;
    ddp_ech_rec.creation_date := p6_a7;
    ddp_ech_rec.last_updated_by := p6_a8;
    ddp_ech_rec.last_update_date := p6_a9;
    ddp_ech_rec.last_update_login := p6_a10;

    okl_ecl_pvt_w.rosetta_table_copy_in_p1(ddp_ecl_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      );

    okl_ecv_pvt_w.rosetta_table_copy_in_p1(ddp_ecv_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_fe_adj_matrix_pub.validate_adj_mat(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pal_rec,
      ddp_ech_rec,
      ddp_ecl_tbl,
      ddp_ecv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








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
    ddx_obj_tbl okl_fe_adj_matrix_pub.invalid_object_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_fe_adj_matrix_pub.invalid_objects(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_version_id,
      ddx_obj_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_fe_adj_matrix_pvt_w.rosetta_table_copy_out_p6(ddx_obj_tbl, p6_a0
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
    , p5_a4  VARCHAR2
    , p5_a5  DATE
    , p5_a6  DATE
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
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
    , p5_a23  NUMBER
    , p5_a24  DATE
    , p5_a25  NUMBER
    , p5_a26  DATE
    , p5_a27  NUMBER
    , x_cal_eff_from out nocopy  DATE
  )

  as
    ddp_pal_rec okl_fe_adj_matrix_pub.okl_pal_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_pal_rec.adj_mat_version_id := p5_a0;
    ddp_pal_rec.object_version_number := p5_a1;
    ddp_pal_rec.version_number := p5_a2;
    ddp_pal_rec.adj_mat_id := p5_a3;
    ddp_pal_rec.sts_code := p5_a4;
    ddp_pal_rec.effective_from_date := p5_a5;
    ddp_pal_rec.effective_to_date := p5_a6;
    ddp_pal_rec.attribute_category := p5_a7;
    ddp_pal_rec.attribute1 := p5_a8;
    ddp_pal_rec.attribute2 := p5_a9;
    ddp_pal_rec.attribute3 := p5_a10;
    ddp_pal_rec.attribute4 := p5_a11;
    ddp_pal_rec.attribute5 := p5_a12;
    ddp_pal_rec.attribute6 := p5_a13;
    ddp_pal_rec.attribute7 := p5_a14;
    ddp_pal_rec.attribute8 := p5_a15;
    ddp_pal_rec.attribute9 := p5_a16;
    ddp_pal_rec.attribute10 := p5_a17;
    ddp_pal_rec.attribute11 := p5_a18;
    ddp_pal_rec.attribute12 := p5_a19;
    ddp_pal_rec.attribute13 := p5_a20;
    ddp_pal_rec.attribute14 := p5_a21;
    ddp_pal_rec.attribute15 := p5_a22;
    ddp_pal_rec.created_by := p5_a23;
    ddp_pal_rec.creation_date := p5_a24;
    ddp_pal_rec.last_updated_by := p5_a25;
    ddp_pal_rec.last_update_date := p5_a26;
    ddp_pal_rec.last_update_login := p5_a27;


    -- here's the delegated call to the old PL/SQL routine
    okl_fe_adj_matrix_pub.calc_start_date(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pal_rec,
      x_cal_eff_from);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_fe_adj_matrix_pub_w;

/
