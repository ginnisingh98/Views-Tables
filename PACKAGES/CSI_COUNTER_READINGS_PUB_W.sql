--------------------------------------------------------
--  DDL for Package CSI_COUNTER_READINGS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_READINGS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csipcrws.pls 120.10 2008/03/26 09:10:21 ngoutam ship $ */
  procedure capture_counter_reading(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_DATE_TABLE
    , p4_a2 in out nocopy JTF_DATE_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_NUMBER_TABLE
    , p4_a5 in out nocopy JTF_NUMBER_TABLE
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 in out nocopy JTF_NUMBER_TABLE
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a11 in out nocopy JTF_NUMBER_TABLE
    , p4_a12 in out nocopy JTF_NUMBER_TABLE
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
    , p4_a14 in out nocopy JTF_NUMBER_TABLE
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a16 in out nocopy JTF_NUMBER_TABLE
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a19 in out nocopy JTF_NUMBER_TABLE
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_NUMBER_TABLE
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a38 in out nocopy JTF_DATE_TABLE
    , p4_a39 in out nocopy JTF_NUMBER_TABLE
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_DATE_TABLE
    , p5_a3 in out nocopy JTF_NUMBER_TABLE
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_DATE_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_DATE_TABLE
    , p5_a12 in out nocopy JTF_NUMBER_TABLE
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a46 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a47 in out nocopy JTF_NUMBER_TABLE
    , p5_a48 in out nocopy JTF_NUMBER_TABLE
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a51 in out nocopy JTF_NUMBER_TABLE
    , p5_a52 in out nocopy JTF_NUMBER_TABLE
    , p5_a53 in out nocopy JTF_NUMBER_TABLE
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a55 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a56 in out nocopy JTF_NUMBER_TABLE
    , p5_a57 in out nocopy JTF_NUMBER_TABLE
    , p5_a58 in out nocopy JTF_NUMBER_TABLE
    , p5_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 in out nocopy JTF_DATE_TABLE
    , p6_a5 in out nocopy JTF_NUMBER_TABLE
    , p6_a6 in out nocopy JTF_DATE_TABLE
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_DATE_TABLE
    , p6_a9 in out nocopy JTF_NUMBER_TABLE
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 in out nocopy JTF_NUMBER_TABLE
    , p6_a29 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_counter_reading(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_DATE_TABLE
    , p4_a3 in out nocopy JTF_NUMBER_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 in out nocopy JTF_NUMBER_TABLE
    , p4_a8 in out nocopy JTF_NUMBER_TABLE
    , p4_a9 in out nocopy JTF_DATE_TABLE
    , p4_a10 in out nocopy JTF_NUMBER_TABLE
    , p4_a11 in out nocopy JTF_DATE_TABLE
    , p4_a12 in out nocopy JTF_NUMBER_TABLE
    , p4_a13 in out nocopy JTF_NUMBER_TABLE
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
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a44 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a46 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a47 in out nocopy JTF_NUMBER_TABLE
    , p4_a48 in out nocopy JTF_NUMBER_TABLE
    , p4_a49 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a50 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a51 in out nocopy JTF_NUMBER_TABLE
    , p4_a52 in out nocopy JTF_NUMBER_TABLE
    , p4_a53 in out nocopy JTF_NUMBER_TABLE
    , p4_a54 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a55 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a56 in out nocopy JTF_NUMBER_TABLE
    , p4_a57 in out nocopy JTF_NUMBER_TABLE
    , p4_a58 in out nocopy JTF_NUMBER_TABLE
    , p4_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end csi_counter_readings_pub_w;

/
