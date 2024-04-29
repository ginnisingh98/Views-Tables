--------------------------------------------------------
--  DDL for Package IBE_PHYSICALMAP_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PHYSICALMAP_GRP_W" AUTHID CURRENT_USER as
  /* $Header: IBEGRPSS.pls 115.4 2002/12/18 07:09:51 schak ship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ibe_physicalmap_grp.language_code_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p0(t ibe_physicalmap_grp.language_code_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p2(t out nocopy ibe_physicalmap_grp.msite_lang_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t ibe_physicalmap_grp.msite_lang_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ibe_physicalmap_grp.lgl_phys_map_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p3(t ibe_physicalmap_grp.lgl_phys_map_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p4(t out nocopy ibe_physicalmap_grp.msite_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p4(t ibe_physicalmap_grp.msite_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure save_physicalmap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attachment_id  NUMBER
    , p_msite_id  NUMBER
    , p_language_code_tbl JTF_VARCHAR2_TABLE_100
  );
  procedure save_physicalmap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attachment_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p_language_code_tbl JTF_VARCHAR2_TABLE_100
  );
  procedure delete_physicalmap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lgl_phys_map_id_tbl JTF_NUMBER_TABLE
  );
  procedure delete_attachment_msite(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attachment_id  NUMBER
    , p_msite_id_tbl JTF_NUMBER_TABLE
  );
  procedure save_physicalmap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_deliverable_id  NUMBER
    , p_old_content_key  VARCHAR2
    , p_new_content_key  VARCHAR2
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p_language_code_tbl JTF_VARCHAR2_TABLE_100
  );
end ibe_physicalmap_grp_w;

 

/
