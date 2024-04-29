--------------------------------------------------------
--  DDL for Package AHL_UC_VALIDATION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_VALIDATION_PUB_W" AUTHID CURRENT_USER as
  /* $Header: AHLWUCVS.pls 115.0 2003/08/11 21:36:04 cxcheng noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ahl_uc_validation_pub.error_tbl_type, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p0(t ahl_uc_validation_pub.error_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000);

  procedure validate_completeness(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_unit_header_id  NUMBER
    , x_error_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure validate_complete_for_pos(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_csi_instance_id  NUMBER
    , x_error_tbl out nocopy JTF_VARCHAR2_TABLE_2000
  );
end ahl_uc_validation_pub_w;

 

/
