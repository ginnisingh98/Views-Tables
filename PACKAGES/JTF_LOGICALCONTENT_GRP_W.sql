--------------------------------------------------------
--  DDL for Package JTF_LOGICALCONTENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOGICALCONTENT_GRP_W" AUTHID CURRENT_USER as
  /* $Header: JTFGRLTS.pls 115.6 2004/07/09 18:50:47 applrt ship $ */
  procedure rosetta_table_copy_in_p3(t out jtf_logicalcontent_grp.obj_lgl_ctnt_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t jtf_logicalcontent_grp.obj_lgl_ctnt_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_NUMBER_TABLE
    );

  procedure save_delete_lgl_ctnt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_object_type_code  VARCHAR2
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
  );
end jtf_logicalcontent_grp_w;

 

/
