--------------------------------------------------------
--  DDL for Package AMS_ITEM_OWNER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ITEM_OWNER_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswinvs.pls 120.3 2006/05/04 03:16 inanaiah ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ams_item_owner_pvt.item_owner_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t ams_item_owner_pvt.item_owner_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy ams_item_owner_pvt.error_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t ams_item_owner_pvt.error_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_item_owner(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_item_owner_id out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  DATE
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  NUMBER
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  VARCHAR2
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  NUMBER
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  VARCHAR2
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  NUMBER
    , p10_a42 out nocopy  VARCHAR2
    , p10_a43 out nocopy  VARCHAR2
    , p10_a44 out nocopy  VARCHAR2
    , p10_a45 out nocopy  VARCHAR2
    , p10_a46 out nocopy  VARCHAR2
    , p10_a47 out nocopy  VARCHAR2
    , p10_a48 out nocopy  VARCHAR2
    , p10_a49 out nocopy  VARCHAR2
    , p10_a50 out nocopy  VARCHAR2
    , p10_a51 out nocopy  VARCHAR2
    , p10_a52 out nocopy  VARCHAR2
    , p10_a53 out nocopy  VARCHAR2
    , p10_a54 out nocopy  VARCHAR2
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  VARCHAR2
    , p10_a58 out nocopy  VARCHAR2
    , p10_a59 out nocopy  VARCHAR2
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , x_item_return_status out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a5  VARCHAR2 := fnd_api.g_miss_char
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  DATE := fnd_api.g_miss_date
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  VARCHAR2 := fnd_api.g_miss_char
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  NUMBER := 0-1962.0724
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  NUMBER := 0-1962.0724
    , p9_a34  NUMBER := 0-1962.0724
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  NUMBER := 0-1962.0724
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  VARCHAR2 := fnd_api.g_miss_char
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_item_owner(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  DATE
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  NUMBER
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  VARCHAR2
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  NUMBER
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  VARCHAR2
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  NUMBER
    , p10_a42 out nocopy  VARCHAR2
    , p10_a43 out nocopy  VARCHAR2
    , p10_a44 out nocopy  VARCHAR2
    , p10_a45 out nocopy  VARCHAR2
    , p10_a46 out nocopy  VARCHAR2
    , p10_a47 out nocopy  VARCHAR2
    , p10_a48 out nocopy  VARCHAR2
    , p10_a49 out nocopy  VARCHAR2
    , p10_a50 out nocopy  VARCHAR2
    , p10_a51 out nocopy  VARCHAR2
    , p10_a52 out nocopy  VARCHAR2
    , p10_a53 out nocopy  VARCHAR2
    , p10_a54 out nocopy  VARCHAR2
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  VARCHAR2
    , p10_a58 out nocopy  VARCHAR2
    , p10_a59 out nocopy  VARCHAR2
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , x_item_return_status out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a5  VARCHAR2 := fnd_api.g_miss_char
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  DATE := fnd_api.g_miss_date
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  VARCHAR2 := fnd_api.g_miss_char
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  NUMBER := 0-1962.0724
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  NUMBER := 0-1962.0724
    , p9_a34  NUMBER := 0-1962.0724
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  NUMBER := 0-1962.0724
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  VARCHAR2 := fnd_api.g_miss_char
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_item_owner(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  DATE := fnd_api.g_miss_date
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
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
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  NUMBER := 0-1962.0724
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  VARCHAR2 := fnd_api.g_miss_char
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
  );
end ams_item_owner_pvt_w;

 

/
