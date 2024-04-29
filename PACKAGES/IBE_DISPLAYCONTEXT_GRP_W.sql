--------------------------------------------------------
--  DDL for Package IBE_DISPLAYCONTEXT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DISPLAYCONTEXT_GRP_W" AUTHID CURRENT_USER as
  /* $Header: IBEGRCXS.pls 115.4 2002/12/18 07:07:52 schak ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ibe_displaycontext_grp.display_context_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t ibe_displaycontext_grp.display_context_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure save_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  VARCHAR2
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  NUMBER
  );
  procedure save_delete_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 in out nocopy JTF_NUMBER_TABLE
  );
  procedure delete_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  VARCHAR2
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  NUMBER
  );
  procedure insert_row(x_rowid in out nocopy  VARCHAR2
    , x_context_id  NUMBER
    , x_object_version_number  NUMBER
    , x_access_name  VARCHAR2
    , x_context_type_code  VARCHAR2
    , x_item_id  NUMBER
    , x_name  VARCHAR2
    , x_description  VARCHAR2
    , x_creation_date  date
    , x_created_by  NUMBER
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_component_type_code  VARCHAR2
  );
  procedure update_row(x_context_id  NUMBER
    , x_object_version_number  NUMBER
    , x_access_name  VARCHAR2
    , x_context_type_code  VARCHAR2
    , x_item_id  NUMBER
    , x_name  VARCHAR2
    , x_description  VARCHAR2
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_component_type_code  VARCHAR2
  );
end ibe_displaycontext_grp_w;

 

/
