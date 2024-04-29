--------------------------------------------------------
--  DDL for Package AHL_PRD_PRINT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_PRINT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWPPRS.pls 120.0 2005/07/05 00:10 bachandr noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ahl_prd_print_pvt.workorder_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t ahl_prd_print_pvt.workorder_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure gen_wo_xml(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_workorders_tbl JTF_NUMBER_TABLE
    , p_employee_id  NUMBER
    , p_user_role  VARCHAR2
    , p_material_req_flag  VARCHAR2
    , x_xml_data out nocopy  CLOB
    , p_concurrent_flag  VARCHAR2
  );
end ahl_prd_print_pvt_w;

 

/
