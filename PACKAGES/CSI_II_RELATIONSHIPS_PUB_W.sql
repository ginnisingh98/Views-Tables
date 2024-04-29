--------------------------------------------------------
--  DDL for Package CSI_II_RELATIONSHIPS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_II_RELATIONSHIPS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csipirws.pls 120.12 2008/01/15 03:34:28 devijay ship $ */
  procedure get_relationships(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_depth  NUMBER
    , p_time_stamp  date
    , p_active_relationship_only  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
  );
  procedure create_relationship(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 in out nocopy JTF_DATE_TABLE
    , p4_a7 in out nocopy JTF_DATE_TABLE
    , p4_a8 in out nocopy JTF_NUMBER_TABLE
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a26 in out nocopy JTF_NUMBER_TABLE
    , p4_a27 in out nocopy JTF_NUMBER_TABLE
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a29 in out nocopy JTF_NUMBER_TABLE
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_relationship(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_DATE_TABLE
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_200
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_NUMBER_TABLE
    , p4_a27 JTF_NUMBER_TABLE
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_NUMBER_TABLE
    , p4_a30 JTF_VARCHAR2_TABLE_100
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure expire_relationship(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_instance_id_lst out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  DATE := fnd_api.g_miss_date
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
  );
end csi_ii_relationships_pub_w;

/
