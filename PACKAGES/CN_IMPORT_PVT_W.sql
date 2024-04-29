--------------------------------------------------------
--  DDL for Package CN_IMPORT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMPORT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwimpb.pls 120.3 2005/09/14 03:39 vensrini noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy cn_import_pvt.char_data_set_type, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p0(t cn_import_pvt.char_data_set_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000);

  procedure rosetta_table_copy_in_p1(t out nocopy cn_import_pvt.num_data_set_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t cn_import_pvt.num_data_set_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure client_stage_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_imp_header_id  NUMBER
    , p_data JTF_VARCHAR2_TABLE_2000
    , p_row_count  NUMBER
    , p_map_obj_ver  NUMBER
    , p_org_id  NUMBER
  );
end cn_import_pvt_w;

 

/
