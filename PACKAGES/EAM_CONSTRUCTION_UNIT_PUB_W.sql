--------------------------------------------------------
--  DDL for Package EAM_CONSTRUCTION_UNIT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTRUCTION_UNIT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: EAMPCUWS.pls 120.0.12010000.2 2008/11/20 04:31:20 dsingire noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy eam_construction_unit_pub.cu_activity_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t eam_construction_unit_pub.cu_activity_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy eam_construction_unit_pub.cu_id_tbl, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t eam_construction_unit_pub.cu_id_tbl, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_construction_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_DATE_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , x_cu_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_construction_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_DATE_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , x_cu_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure copy_construction_unit(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_DATE_TABLE
    , p3_a6 JTF_DATE_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_NUMBER_TABLE
    , x_cu_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  VARCHAR2 := fnd_api.g_miss_char
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  VARCHAR2 := fnd_api.g_miss_char
    , p2_a14  VARCHAR2 := fnd_api.g_miss_char
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
  );
end eam_construction_unit_pub_w;

/
