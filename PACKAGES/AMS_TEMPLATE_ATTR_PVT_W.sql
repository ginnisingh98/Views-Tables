--------------------------------------------------------
--  DDL for Package AMS_TEMPLATE_ATTR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TEMPLATE_ATTR_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswpats.pls 120.1 2005/06/28 16:14 appldev ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ams_template_attr_pvt.template_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ams_template_attr_pvt.template_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_template_attr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_template_attribute_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_template_attr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_template_attr(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  DATE := fnd_api.g_miss_date
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  DATE := fnd_api.g_miss_date
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_template_attr_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_template_attr_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
  );
end ams_template_attr_pvt_w;

 

/
