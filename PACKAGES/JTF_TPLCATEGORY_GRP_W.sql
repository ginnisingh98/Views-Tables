--------------------------------------------------------
--  DDL for Package JTF_TPLCATEGORY_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TPLCATEGORY_GRP_W" AUTHID CURRENT_USER as
  /* $Header: JTFGRTGS.pls 115.6 2004/07/09 18:51:10 applrt ship $ */
  procedure rosetta_table_copy_in_p2(t out jtf_tplcategory_grp.category_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p2(t jtf_tplcategory_grp.category_id_tbl_type, a0 out JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p3(t out jtf_tplcategory_grp.template_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p3(t jtf_tplcategory_grp.template_id_tbl_type, a0 out JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p4(t out jtf_tplcategory_grp.tpl_ctg_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p4(t jtf_tplcategory_grp.tpl_ctg_id_tbl_type, a0 out JTF_NUMBER_TABLE);

  procedure add_tpl_ctg(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_template_id  NUMBER
    , p_category_id_tbl JTF_NUMBER_TABLE
  );
  procedure delete_tpl_ctg_relation(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_tpl_ctg_id_tbl JTF_NUMBER_TABLE
  );
  procedure add_ctg_tpl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_category_id  NUMBER
    , p_template_id_tbl JTF_NUMBER_TABLE
  );
end jtf_tplcategory_grp_w;

 

/
