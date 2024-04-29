--------------------------------------------------------
--  DDL for Package IBE_COPY_LOGICALCONTENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_COPY_LOGICALCONTENT_GRP_W" AUTHID CURRENT_USER as
  /* $Header: IBEGRCTS.pls 120.0.12010000.1 2009/12/16 05:24:40 pgoutia noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ibe_copy_logicalcontent_grp.ids_list, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p2(t ibe_copy_logicalcontent_grp.ids_list, a0 out nocopy JTF_NUMBER_TABLE);

  procedure copy_lgl_ctnt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_type_code  VARCHAR2
    , p_from_product_id  NUMBER
    , p_from_context_ids JTF_NUMBER_TABLE
    , p_to_product_ids JTF_NUMBER_TABLE
    , x_copy_status out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure copy_lgl_ctnt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_type_code  VARCHAR2
    , p_from_product_id  NUMBER
    , p_from_context_ids JTF_NUMBER_TABLE
    , p_from_deliverable_ids JTF_NUMBER_TABLE
    , p_to_product_ids JTF_NUMBER_TABLE
    , x_copy_status out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ibe_copy_logicalcontent_grp_w;

/
