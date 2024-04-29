--------------------------------------------------------
--  DDL for Package JTF_DISPLAYCONTEXT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DISPLAYCONTEXT_GRP_W" AUTHID CURRENT_USER as
  /* $Header: JTFGRCXS.pls 115.6 2004/07/09 18:50:32 applrt ship $ */
  procedure rosetta_table_copy_in_p3(t out jtf_displaycontext_grp.display_context_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t jtf_displaycontext_grp.display_context_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_200
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_NUMBER_TABLE
    );

  procedure save_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  VARCHAR2
    , p6_a1 in out  NUMBER
    , p6_a2 in out  NUMBER
    , p6_a3 in out  VARCHAR2
    , p6_a4 in out  VARCHAR2
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  NUMBER
  );
  procedure save_delete_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_VARCHAR2_TABLE_100
    , p6_a1 in out JTF_NUMBER_TABLE
    , p6_a2 in out JTF_NUMBER_TABLE
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
    , p6_a4 in out JTF_VARCHAR2_TABLE_100
    , p6_a5 in out JTF_VARCHAR2_TABLE_200
    , p6_a6 in out JTF_VARCHAR2_TABLE_100
    , p6_a7 in out JTF_NUMBER_TABLE
  );
  procedure delete_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  VARCHAR2
    , p6_a1 in out  NUMBER
    , p6_a2 in out  NUMBER
    , p6_a3 in out  VARCHAR2
    , p6_a4 in out  VARCHAR2
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  NUMBER
  );
end jtf_displaycontext_grp_w;

 

/
