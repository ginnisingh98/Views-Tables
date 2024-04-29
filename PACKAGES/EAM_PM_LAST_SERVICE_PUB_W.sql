--------------------------------------------------------
--  DDL for Package EAM_PM_LAST_SERVICE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PM_LAST_SERVICE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: EAMWPLSS.pls 120.2 2008/01/26 01:51:28 devijay ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy eam_pm_last_service_pub.pm_last_service_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t eam_pm_last_service_pub.pm_last_service_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure process_pm_last_service(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p_actv_assoc_id  NUMBER
  );
end eam_pm_last_service_pub_w;

/
