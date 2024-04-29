--------------------------------------------------------
--  DDL for Package CN_COMP_GRP_HIER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_GRP_HIER_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwcghrs.pls 115.4 2002/07/30 02:41:24 achung noship $ */
  procedure rosetta_table_copy_in_p1(t out cn_comp_grp_hier_pub.comp_group_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t cn_comp_grp_hier_pub.comp_group_tbl, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_NUMBER_TABLE
    , a7 out JTF_DATE_TABLE
    , a8 out JTF_DATE_TABLE
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_VARCHAR2_TABLE_100
    , a12 out JTF_VARCHAR2_TABLE_100
    );

  procedure get_comp_group_hier(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_comp_group_id  NUMBER
    , p_focus_cg_id  NUMBER
    , p_expand  CHAR
    , p_date  date
    , p8_a0 out JTF_VARCHAR2_TABLE_100
    , p8_a1 out JTF_VARCHAR2_TABLE_100
    , p8_a2 out JTF_NUMBER_TABLE
    , p8_a3 out JTF_NUMBER_TABLE
    , p8_a4 out JTF_VARCHAR2_TABLE_100
    , p8_a5 out JTF_VARCHAR2_TABLE_100
    , p8_a6 out JTF_NUMBER_TABLE
    , p8_a7 out JTF_DATE_TABLE
    , p8_a8 out JTF_DATE_TABLE
    , p8_a9 out JTF_NUMBER_TABLE
    , p8_a10 out JTF_NUMBER_TABLE
    , p8_a11 out JTF_VARCHAR2_TABLE_100
    , p8_a12 out JTF_VARCHAR2_TABLE_100
    , l_mgr_count out  NUMBER
    , x_period_year out  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , x_loading_status out  VARCHAR2
  );
end cn_comp_grp_hier_pub_w;

 

/
