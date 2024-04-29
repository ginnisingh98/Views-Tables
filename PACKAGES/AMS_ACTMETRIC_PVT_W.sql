--------------------------------------------------------
--  DDL for Package AMS_ACTMETRIC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTMETRIC_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswamts.pls 120.2 2006/03/23 04:11 mayjain noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ams_actmetric_pvt.currency_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t ams_actmetric_pvt.currency_table, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p28(t out nocopy ams_actmetric_pvt.result_table, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p28(t ams_actmetric_pvt.result_table, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure init_actmetric_rec(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  DATE
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  DATE
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  NUMBER
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  VARCHAR2
    , p0_a10 in out nocopy  NUMBER
    , p0_a11 in out nocopy  VARCHAR2
    , p0_a12 in out nocopy  NUMBER
    , p0_a13 in out nocopy  NUMBER
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  NUMBER
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  NUMBER
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  NUMBER
    , p0_a22 in out nocopy  NUMBER
    , p0_a23 in out nocopy  DATE
    , p0_a24 in out nocopy  NUMBER
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  VARCHAR2
    , p0_a28 in out nocopy  NUMBER
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  NUMBER
    , p0_a31 in out nocopy  VARCHAR2
    , p0_a32 in out nocopy  NUMBER
    , p0_a33 in out nocopy  NUMBER
    , p0_a34 in out nocopy  NUMBER
    , p0_a35 in out nocopy  NUMBER
    , p0_a36 in out nocopy  NUMBER
    , p0_a37 in out nocopy  NUMBER
    , p0_a38 in out nocopy  NUMBER
    , p0_a39 in out nocopy  NUMBER
    , p0_a40 in out nocopy  DATE
    , p0_a41 in out nocopy  DATE
    , p0_a42 in out nocopy  NUMBER
    , p0_a43 in out nocopy  NUMBER
    , p0_a44 in out nocopy  NUMBER
    , p0_a45 in out nocopy  NUMBER
    , p0_a46 in out nocopy  NUMBER
    , p0_a47 in out nocopy  NUMBER
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  VARCHAR2
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  VARCHAR2
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  VARCHAR2
    , p0_a61 in out nocopy  VARCHAR2
    , p0_a62 in out nocopy  VARCHAR2
    , p0_a63 in out nocopy  VARCHAR2
    , p0_a64 in out nocopy  VARCHAR2
    , p0_a65 in out nocopy  VARCHAR2
    , p0_a66 in out nocopy  VARCHAR2
    , p0_a67 in out nocopy  VARCHAR2
    , p0_a68 in out nocopy  DATE
    , p0_a69 in out nocopy  NUMBER
    , p0_a70 in out nocopy  NUMBER
    , p0_a71 in out nocopy  VARCHAR2
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  VARCHAR2
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  VARCHAR2
    , p0_a76 in out nocopy  NUMBER
    , p0_a77 in out nocopy  VARCHAR2
  );
  procedure create_actmetric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_activity_metric_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  DATE := fnd_api.g_miss_date
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  DATE := fnd_api.g_miss_date
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  DATE := fnd_api.g_miss_date
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  NUMBER := 0-1962.0724
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_actmetric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  DATE := fnd_api.g_miss_date
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  DATE := fnd_api.g_miss_date
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  NUMBER := 0-1962.0724
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  DATE := fnd_api.g_miss_date
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  NUMBER := 0-1962.0724
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_actmetric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  DATE := fnd_api.g_miss_date
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  NUMBER := 0-1962.0724
    , p6_a29  NUMBER := 0-1962.0724
    , p6_a30  NUMBER := 0-1962.0724
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  NUMBER := 0-1962.0724
    , p6_a33  NUMBER := 0-1962.0724
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  NUMBER := 0-1962.0724
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  DATE := fnd_api.g_miss_date
    , p6_a41  DATE := fnd_api.g_miss_date
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  VARCHAR2 := fnd_api.g_miss_char
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  DATE := fnd_api.g_miss_date
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  NUMBER := 0-1962.0724
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  NUMBER := 0-1962.0724
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_actmetric_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  DATE := fnd_api.g_miss_date
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  DATE := fnd_api.g_miss_date
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  NUMBER := 0-1962.0724
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_actmetric_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  DATE := fnd_api.g_miss_date
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  DATE := fnd_api.g_miss_date
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  NUMBER := 0-1962.0724
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  NUMBER := 0-1962.0724
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  NUMBER := 0-1962.0724
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  NUMBER := 0-1962.0724
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  NUMBER := 0-1962.0724
    , p1_a22  NUMBER := 0-1962.0724
    , p1_a23  DATE := fnd_api.g_miss_date
    , p1_a24  NUMBER := 0-1962.0724
    , p1_a25  NUMBER := 0-1962.0724
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  NUMBER := 0-1962.0724
    , p1_a29  NUMBER := 0-1962.0724
    , p1_a30  NUMBER := 0-1962.0724
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  NUMBER := 0-1962.0724
    , p1_a33  NUMBER := 0-1962.0724
    , p1_a34  NUMBER := 0-1962.0724
    , p1_a35  NUMBER := 0-1962.0724
    , p1_a36  NUMBER := 0-1962.0724
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  NUMBER := 0-1962.0724
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  DATE := fnd_api.g_miss_date
    , p1_a41  DATE := fnd_api.g_miss_date
    , p1_a42  NUMBER := 0-1962.0724
    , p1_a43  NUMBER := 0-1962.0724
    , p1_a44  NUMBER := 0-1962.0724
    , p1_a45  NUMBER := 0-1962.0724
    , p1_a46  NUMBER := 0-1962.0724
    , p1_a47  NUMBER := 0-1962.0724
    , p1_a48  VARCHAR2 := fnd_api.g_miss_char
    , p1_a49  VARCHAR2 := fnd_api.g_miss_char
    , p1_a50  VARCHAR2 := fnd_api.g_miss_char
    , p1_a51  VARCHAR2 := fnd_api.g_miss_char
    , p1_a52  VARCHAR2 := fnd_api.g_miss_char
    , p1_a53  VARCHAR2 := fnd_api.g_miss_char
    , p1_a54  VARCHAR2 := fnd_api.g_miss_char
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  VARCHAR2 := fnd_api.g_miss_char
    , p1_a60  VARCHAR2 := fnd_api.g_miss_char
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  VARCHAR2 := fnd_api.g_miss_char
    , p1_a65  VARCHAR2 := fnd_api.g_miss_char
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  VARCHAR2 := fnd_api.g_miss_char
    , p1_a68  DATE := fnd_api.g_miss_date
    , p1_a69  NUMBER := 0-1962.0724
    , p1_a70  NUMBER := 0-1962.0724
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  VARCHAR2 := fnd_api.g_miss_char
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  VARCHAR2 := fnd_api.g_miss_char
    , p1_a75  VARCHAR2 := fnd_api.g_miss_char
    , p1_a76  NUMBER := 0-1962.0724
    , p1_a77  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure complete_actmetric_rec(p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  DATE
    , p1_a2 in out nocopy  NUMBER
    , p1_a3 in out nocopy  DATE
    , p1_a4 in out nocopy  NUMBER
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  NUMBER
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  VARCHAR2
    , p1_a9 in out nocopy  VARCHAR2
    , p1_a10 in out nocopy  NUMBER
    , p1_a11 in out nocopy  VARCHAR2
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  VARCHAR2
    , p1_a15 in out nocopy  NUMBER
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  NUMBER
    , p1_a18 in out nocopy  VARCHAR2
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  VARCHAR2
    , p1_a21 in out nocopy  NUMBER
    , p1_a22 in out nocopy  NUMBER
    , p1_a23 in out nocopy  DATE
    , p1_a24 in out nocopy  NUMBER
    , p1_a25 in out nocopy  NUMBER
    , p1_a26 in out nocopy  NUMBER
    , p1_a27 in out nocopy  VARCHAR2
    , p1_a28 in out nocopy  NUMBER
    , p1_a29 in out nocopy  NUMBER
    , p1_a30 in out nocopy  NUMBER
    , p1_a31 in out nocopy  VARCHAR2
    , p1_a32 in out nocopy  NUMBER
    , p1_a33 in out nocopy  NUMBER
    , p1_a34 in out nocopy  NUMBER
    , p1_a35 in out nocopy  NUMBER
    , p1_a36 in out nocopy  NUMBER
    , p1_a37 in out nocopy  NUMBER
    , p1_a38 in out nocopy  NUMBER
    , p1_a39 in out nocopy  NUMBER
    , p1_a40 in out nocopy  DATE
    , p1_a41 in out nocopy  DATE
    , p1_a42 in out nocopy  NUMBER
    , p1_a43 in out nocopy  NUMBER
    , p1_a44 in out nocopy  NUMBER
    , p1_a45 in out nocopy  NUMBER
    , p1_a46 in out nocopy  NUMBER
    , p1_a47 in out nocopy  NUMBER
    , p1_a48 in out nocopy  VARCHAR2
    , p1_a49 in out nocopy  VARCHAR2
    , p1_a50 in out nocopy  VARCHAR2
    , p1_a51 in out nocopy  VARCHAR2
    , p1_a52 in out nocopy  VARCHAR2
    , p1_a53 in out nocopy  VARCHAR2
    , p1_a54 in out nocopy  VARCHAR2
    , p1_a55 in out nocopy  VARCHAR2
    , p1_a56 in out nocopy  VARCHAR2
    , p1_a57 in out nocopy  VARCHAR2
    , p1_a58 in out nocopy  VARCHAR2
    , p1_a59 in out nocopy  VARCHAR2
    , p1_a60 in out nocopy  VARCHAR2
    , p1_a61 in out nocopy  VARCHAR2
    , p1_a62 in out nocopy  VARCHAR2
    , p1_a63 in out nocopy  VARCHAR2
    , p1_a64 in out nocopy  VARCHAR2
    , p1_a65 in out nocopy  VARCHAR2
    , p1_a66 in out nocopy  VARCHAR2
    , p1_a67 in out nocopy  VARCHAR2
    , p1_a68 in out nocopy  DATE
    , p1_a69 in out nocopy  NUMBER
    , p1_a70 in out nocopy  NUMBER
    , p1_a71 in out nocopy  VARCHAR2
    , p1_a72 in out nocopy  VARCHAR2
    , p1_a73 in out nocopy  VARCHAR2
    , p1_a74 in out nocopy  VARCHAR2
    , p1_a75 in out nocopy  VARCHAR2
    , p1_a76 in out nocopy  NUMBER
    , p1_a77 in out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  NUMBER := 0-1962.0724
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  DATE := fnd_api.g_miss_date
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  DATE := fnd_api.g_miss_date
    , p0_a41  DATE := fnd_api.g_miss_date
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
    , p0_a44  NUMBER := 0-1962.0724
    , p0_a45  NUMBER := 0-1962.0724
    , p0_a46  NUMBER := 0-1962.0724
    , p0_a47  NUMBER := 0-1962.0724
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  DATE := fnd_api.g_miss_date
    , p0_a69  NUMBER := 0-1962.0724
    , p0_a70  NUMBER := 0-1962.0724
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure convert_currency(x_return_status out nocopy  VARCHAR2
    , p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_date  date
    , p_from_amount  NUMBER
    , x_to_amount out nocopy  NUMBER
    , p_round  VARCHAR2
  );
  procedure convert_currency2(x_return_status out nocopy  VARCHAR2
    , p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_date  date
    , p_from_amount  NUMBER
    , x_to_amount out nocopy  NUMBER
    , p_from_amount2  NUMBER
    , x_to_amount2 out nocopy  NUMBER
    , p_round  VARCHAR2
  );
  procedure convert_currency_vector(x_return_status out nocopy  VARCHAR2
    , p_from_currency  VARCHAR2
    , p_to_currency  VARCHAR2
    , p_conv_date  date
    , p_amounts in out nocopy JTF_NUMBER_TABLE
    , p_round  VARCHAR2
  );
  procedure convert_currency_object(x_return_status out nocopy  VARCHAR2
    , p_object_id  NUMBER
    , p_object_type  VARCHAR2
    , p_conv_date  date
    , p_amounts in out nocopy JTF_NUMBER_TABLE
    , p_round  VARCHAR2
  );
  procedure get_results(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_metric_id  NUMBER
    , p_object_type  VARCHAR2
    , p_object_id  NUMBER
    , p_value_type  VARCHAR2
    , p_from_date  date
    , p_to_date  date
    , p_increment  NUMBER
    , p_interval_unit  VARCHAR2
    , p13_a0 out nocopy JTF_DATE_TABLE
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_NUMBER_TABLE
  );
end ams_actmetric_pvt_w;

 

/
