--------------------------------------------------------
--  DDL for Package AMS_SCRIPTING_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCRIPTING_PUB_W" AUTHID CURRENT_USER as
  /* $Header: amswscrs.pls 115.5 2002/12/27 15:47:31 mayjain noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ams_scripting_pub.ams_party_tbl_type, a0 JTF_VARCHAR2_TABLE_400
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t ams_scripting_pub.ams_party_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy ams_scripting_pub.ams_person_profile_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p6(t ams_scripting_pub.ams_person_profile_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_customer(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_party_id in out nocopy  NUMBER
    , p_b2b_flag  VARCHAR2
    , p_import_list_header_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  VARCHAR2
    , p10_a4  VARCHAR2
    , p10_a5  VARCHAR2
    , p10_a6  VARCHAR2
    , p10_a7  VARCHAR2
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , p10_a24  VARCHAR2
    , p10_a25  VARCHAR2
    , x_new_party out nocopy  VARCHAR2
    , p_component_name out nocopy  VARCHAR2
  );
  procedure update_person_profile(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_party_id  NUMBER
    , p_profile_id in out nocopy  NUMBER
    , p9_a0  DATE
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  DATE
    , p9_a5  NUMBER
    , p9_a6  VARCHAR2
    , p9_a7  NUMBER
    , p9_a8  NUMBER
    , p9_a9  VARCHAR2
    , p_party_object_version_number in out nocopy  NUMBER
  );
end ams_scripting_pub_w;

 

/
