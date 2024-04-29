--------------------------------------------------------
--  DDL for Package AMW_SCOPE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_SCOPE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amwwscps.pls 120.0 2005/05/31 18:17:58 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy amw_scope_pvt.sub_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p1(t amw_scope_pvt.sub_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p3(t out nocopy amw_scope_pvt.sub_new_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t amw_scope_pvt.sub_new_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy amw_scope_pvt.lob_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p5(t amw_scope_pvt.lob_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p7(t out nocopy amw_scope_pvt.lob_new_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t amw_scope_pvt.lob_new_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p9(t out nocopy amw_scope_pvt.org_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p9(t amw_scope_pvt.org_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p11(t out nocopy amw_scope_pvt.process_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p11(t amw_scope_pvt.process_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p13(t out nocopy amw_scope_pvt.proc_hier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p13(t amw_scope_pvt.proc_hier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure add_scope(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
    , p_sub_vs  VARCHAR2
    , p_lob_vs  VARCHAR2
    , p8_a0 JTF_VARCHAR2_TABLE_200
    , p9_a0 JTF_VARCHAR2_TABLE_200
    , p10_a0 JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure populate_custom_hierarchy(p0_a0 JTF_NUMBER_TABLE
    , p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
  );
  procedure generate_organization_list(p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure generate_subsidiary_list(p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p_sub_vs  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure generate_lob_list(p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p_sub_vs  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p_lob_vs  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
  );
  procedure populate_process_hierarchy(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_entity_type  VARCHAR2
    , p_entity_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure populate_denormalized_tables(p_entity_type  VARCHAR2
    , p_entity_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p3_a0 JTF_NUMBER_TABLE
    , p_mode  VARCHAR2
  );
  procedure manage_processes(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_entity_type  VARCHAR2
    , p_entity_id  NUMBER
    , p_organization_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end amw_scope_pvt_w;

 

/
