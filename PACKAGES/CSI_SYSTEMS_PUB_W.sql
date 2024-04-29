--------------------------------------------------------
--  DDL for Package CSI_SYSTEMS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_SYSTEMS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csipsyws.pls 120.10 2008/01/15 03:35:02 devijay ship $ */
  procedure get_systems(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_time_stamp  date
    , p_active_systems_only  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_DATE_TABLE
    , p7_a16 out nocopy JTF_DATE_TABLE
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a44 out nocopy JTF_NUMBER_TABLE
    , p7_a45 out nocopy JTF_NUMBER_TABLE
    , p7_a46 out nocopy JTF_NUMBER_TABLE
    , p7_a47 out nocopy JTF_NUMBER_TABLE
    , p7_a48 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure create_system(p_api_version  NUMBER
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
    , x_system_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  DATE := fnd_api.g_miss_date
    , p4_a16  DATE := fnd_api.g_miss_date
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  NUMBER := 0-1962.0724
    , p4_a45  NUMBER := 0-1962.0724
    , p4_a46  NUMBER := 0-1962.0724
    , p4_a47  NUMBER := 0-1962.0724
    , p4_a48  DATE := fnd_api.g_miss_date
  );
  procedure update_system(p_api_version  NUMBER
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  DATE := fnd_api.g_miss_date
    , p4_a16  DATE := fnd_api.g_miss_date
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  NUMBER := 0-1962.0724
    , p4_a45  NUMBER := 0-1962.0724
    , p4_a46  NUMBER := 0-1962.0724
    , p4_a47  NUMBER := 0-1962.0724
    , p4_a48  DATE := fnd_api.g_miss_date
  );
  procedure expire_system(p_api_version  NUMBER
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
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  DATE := fnd_api.g_miss_date
    , p4_a16  DATE := fnd_api.g_miss_date
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  NUMBER := 0-1962.0724
    , p4_a45  NUMBER := 0-1962.0724
    , p4_a46  NUMBER := 0-1962.0724
    , p4_a47  NUMBER := 0-1962.0724
    , p4_a48  DATE := fnd_api.g_miss_date
  );
end csi_systems_pub_w;

/
