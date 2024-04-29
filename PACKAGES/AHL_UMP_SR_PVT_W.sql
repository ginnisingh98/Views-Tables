--------------------------------------------------------
--  DDL for Package AHL_UMP_SR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_SR_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWUSRS.pls 120.0 2005/07/21 00:07 tamdas noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_ump_sr_pvt.sr_mr_association_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ahl_ump_sr_pvt.sr_mr_association_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure process_sr_mr_associations(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_request_id  NUMBER
    , p_object_version_number  NUMBER
    , p_request_number  VARCHAR2
    , p12_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a2 in out nocopy JTF_NUMBER_TABLE
    , p12_a3 in out nocopy JTF_NUMBER_TABLE
    , p12_a4 in out nocopy JTF_NUMBER_TABLE
    , p12_a5 in out nocopy JTF_NUMBER_TABLE
    , p12_a6 in out nocopy JTF_NUMBER_TABLE
    , p12_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a8 in out nocopy JTF_NUMBER_TABLE
    , p12_a9 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ahl_ump_sr_pvt_w;

 

/
