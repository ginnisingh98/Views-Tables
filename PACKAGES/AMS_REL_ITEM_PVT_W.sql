--------------------------------------------------------
--  DDL for Package AMS_REL_ITEM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_REL_ITEM_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswrits.pls 120.1 2005/06/28 16:13 appldev ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ams_rel_item_pvt.rel_item_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p3(t ams_rel_item_pvt.rel_item_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    );

  procedure create_rel_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
  );
  procedure update_rel_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
  );
  procedure delete_rel_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
  );
  procedure validate_rel_item_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
  );
  procedure validate_rel_item(p_api_version_number  NUMBER
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
    , p3_a5  DATE := fnd_api.g_miss_date
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  DATE := fnd_api.g_miss_date
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  DATE := fnd_api.g_miss_date
  );
end ams_rel_item_pvt_w;

 

/
