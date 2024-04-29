--------------------------------------------------------
--  DDL for Package IBE_LOGICALCONTENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_LOGICALCONTENT_GRP_W" AUTHID CURRENT_USER as
  /* $Header: IBEGRLTS.pls 115.1 2002/12/31 11:10:50 schak ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ibe_logicalcontent_grp.obj_lgl_ctnt_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t ibe_logicalcontent_grp.obj_lgl_ctnt_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    );

  procedure save_delete_lgl_ctnt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_object_type_code  VARCHAR2
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
  );
end ibe_logicalcontent_grp_w;

 

/
